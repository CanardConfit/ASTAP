//based on lazarus/components/multithreadprocs/mtpcpu.pas

{
 **********************************************************************
  This file is part of the Free Pascal run time library.

  See the file COPYING.FPC, included in this distribution,
  for details about the license.
 **********************************************************************

  System depending code for light weight threads.

  Copyright (C) 2008 Mattias Gaertner mattias@freepascal.org

  2026-10-30: GetSystemThreadCount counts the processors this process may use (affinity mask, also correct in virtual
  machines and containers). GetSystemCoreCount added. The same unit for ASTAP and astap_cli.
}
unit unit_mtpcpu;

{$mode objfpc}{$H+}
{$inline on}

interface

{$IF defined(windows)}
uses Windows;
{$ELSEIF defined(freebsd) or defined(darwin)}
uses ctypes, sysctl;
{$ELSEIF defined(android)}
uses ctypes;
{$ELSEIF defined(linux)}
uses syscall;
{$ENDIF}

function GetSystemThreadCount: integer; {logical processors (hardware threads) this process may use. At least 1}
function GetSystemCoreCount: integer;   {physical cores this process may use. The same as GetSystemThreadCount for processors without hyperthreading or if unknown. At least 1}

procedure CallLocalProc(AProc, Frame: Pointer; Param1: PtrInt;
  Param2, Param3: Pointer); inline;

implementation

{$IF defined(android)}
function sysconf(i: cint): clong; cdecl; external 'c' name 'sysconf';
const
  _SC_NPROCESSORS_ONLN = 97; {Android's C library (bionic) numbers this differently from glibc (84)}
{$ENDIF}


{$IF defined(linux) and not defined(android)}
{Linux without the C library, so a program without threads can stay statically linked.
 The processors are taken from the affinity mask of the process. The kernel only puts processors in it that are online, so
 a virtual machine that configures more processors than it provides (VMware reports 128) is counted correctly. The mask is
 also limited by taskset and docker --cpuset-cpus. A CPU quota (docker --cpus) is applied as well.}
type
  Tcpu_mask = array of byte;

var
  cached_threads : integer=0;
  cached_cores   : integer=0;


function min(a,b: integer): integer; inline;
begin
  if a<b then result:=a else result:=b;
end;


function int_to_str(i: integer): string;
begin
  str(i,result);
end;


function trim(const s: string): string;
var
  a, b : integer;
begin
  a:=1;
  b:=length(s);
  while ((a<=b) and (s[a]<=' ')) do inc(a);
  while ((b>=a) and (s[b]<=' ')) do dec(b);
  result:=copy(s,a,b-a+1);
end;


function read_line(const filename: string): string; {first line of a small text file such as in /sys. '' if it can not be read}
var
  f : text;
begin
  result:='';
  {$push}{$I-}
  assign(f,filename);
  reset(f);
  if ioresult=0 then
  begin
    readln(f,result);
    if ioresult<>0 then result:='';
    close(f);
    if ioresult<>0 then ;
  end;
  {$pop}
end;


function affinity_mask(out mask: Tcpu_mask): boolean; {the processors this process may run on, one bit per processor}
var
  size : integer;
  res  : TSysResult;
begin
  size:=128;{1024 processors}
  repeat
    setlength(mask,size);
    fillchar(mask[0],size,0);
    res:=do_syscall(syscall_nr_sched_getaffinity,0,size,TSysParam(@mask[0]));
    if res>0 then
    begin
      setlength(mask,res);{bytes written by the kernel}
      exit(true);
    end;
    size:=size*2;{EINVAL: the kernel supports more processors than the mask holds}
  until size>8192;
  mask:=nil;
  result:=false;
end;


function mask_has(const mask: Tcpu_mask; cpu: integer): boolean; inline;
begin
  result:=((cpu div 8)<length(mask)) and ((mask[cpu div 8] and (1 shl (cpu mod 8)))<>0);
end;


function count_list(const s: string): integer; {number of processors in a list such as "0-5,8,10-11" (/sys/devices/system/cpu/online). 0 if empty or invalid}
var
  p, a, b, code : integer;
  part, rest    : string;
begin
  result:=0;
  rest:=trim(s);
  while rest<>'' do
  begin
    p:=pos(',',rest);
    if p=0 then p:=length(rest)+1;
    part:=copy(rest,1,p-1);
    delete(rest,1,p);
    p:=pos('-',part);
    if p>0 then
    begin
      val(copy(part,1,p-1),a,code); if code<>0 then exit(0);
      val(copy(part,p+1,length(part)),b,code); if code<>0 then exit(0);
    end
    else
    begin
      val(part,a,code); if code<>0 then exit(0);
      b:=a;
    end;
    if b>=a then result:=result+b-a+1;
  end;
end;


function quota_limit: integer; {processors allowed by a cgroup CPU quota (docker --cpus), rounded up. 0 if there is no quota}
var
  s : string;
  p, code : integer;
  quota, period : int64;
begin
  result:=0;
  s:=trim(read_line('/sys/fs/cgroup/cpu.max'));{cgroup v2: "max 100000" or "200000 100000"}
  if s<>'' then
  begin
    p:=pos(' ',s);
    if ((p>0) and (copy(s,1,p-1)<>'max')) then
    begin
      val(copy(s,1,p-1),quota,code);
      if code=0 then val(copy(s,p+1,length(s)),period,code);
      if ((code=0) and (quota>0) and (period>0)) then result:=(quota+period-1) div period;
    end;
    exit;
  end;
  s:=trim(read_line('/sys/fs/cgroup/cpu/cpu.cfs_quota_us'));{cgroup v1, -1 is no quota}
  val(s,quota,code);
  if ((code<>0) or (quota<=0)) then exit;
  val(trim(read_line('/sys/fs/cgroup/cpu/cpu.cfs_period_us')),period,code);
  if ((code=0) and (period>0)) then result:=(quota+period-1) div period;
end;


function first_number(const s: string): integer; {first number of a list such as "0,6" or "0-1". -1 if none}
var
  i, code : integer;
begin
  i:=1;
  while ((i<=length(s)) and (s[i] in ['0'..'9'])) do inc(i);
  if i=1 then exit(-1);
  val(copy(s,1,i-1),result,code);
  if code<>0 then result:=-1;
end;


procedure count_linux; {sets cached_threads and cached_cores}
var
  mask      : Tcpu_mask;
  cpu, first, threads, cores, quota : integer;
  core_seen : array of boolean;
  known     : boolean;
begin
  threads:=0;
  cores:=0;
  known:=true;
  if affinity_mask(mask) then
  begin
    setlength(core_seen,length(mask)*8);
    for cpu:=0 to length(mask)*8-1 do
      if mask_has(mask,cpu) then
      begin
        inc(threads);
        {the hardware threads of one core list the same siblings, e.g. "0,6" for processors 0 and 6. The lowest one identifies the core}
        first:=first_number(read_line('/sys/devices/system/cpu/cpu'+int_to_str(cpu)+'/topology/thread_siblings_list'));
        if ((first<0) or (first>=length(core_seen))) then
          known:=false
        else
        if not core_seen[first] then
        begin
          core_seen[first]:=true;
          inc(cores);
        end;
      end;
  end;
  if threads=0 then threads:=count_list(read_line('/sys/devices/system/cpu/online'));{no affinity mask, very unusual}
  if threads<=0 then threads:=1;
  if ((not known) or (cores<=0) or (cores>threads)) then cores:=threads;{topology not readable, e.g. in some containers}

  quota:=quota_limit;
  if quota>0 then
  begin
    threads:=min(threads,quota);
    cores:=min(cores,quota);
  end;
  cached_cores:=cores;
  cached_threads:=threads;
end;
{$ENDIF}


{$IF defined(windows)}
type
  TLogicalProcessorInformation = packed record {SYSTEM_LOGICAL_PROCESSOR_INFORMATION, 24 bytes for 32 bit, 32 bytes for 64 bit programs}
    ProcessorMask : PtrUInt;
    Relationship  : DWORD;   {0 = RelationProcessorCore}
    {$IFDEF CPU64}
    padding       : DWORD;   {the union below is aligned at 8 bytes}
    {$ENDIF}
    Reserved      : array[0..1] of QWord; {union of ProcessorCore.Flags, NumaNode and Cache}
  end;

  TGetLogicalProcessorInformation = function(Buffer: pointer; var ReturnLength: DWORD): BOOL; stdcall;


function process_mask: PtrUInt; {processors this process may use. 0 if unknown}
var
  ProcessAffinityMask, SystemAffinityMask: DWORD_PTR;
begin
  if GetProcessAffinityMask(GetCurrentProcess, ProcessAffinityMask, SystemAffinityMask) then
    result:=PtrUInt(ProcessAffinityMask)
  else
    result:=0;
end;


function count_bits(m: PtrUInt): integer;
begin
  result:=0;
  while m<>0 do
  begin
    inc(result);
    m:=m and (m-1);{clear the lowest bit}
  end;
end;
{$ENDIF}


{$IF defined(freebsd) or defined(darwin)}
function sysctl_int(const name: pchar): integer; {0 if not available}
var
  t   : cint;
  len : csize_t;
begin
  t:=0;
  len:=sizeof(t);
  if fpsysctlbyname(name,@t,@len,nil,0)<>0 then t:=0;
  result:=t;
end;
{$ENDIF}


function GetSystemThreadCount: integer;
{$IF defined(windows)}
var
  SystemInfo: SYSTEM_INFO;
begin
  result:=count_bits(process_mask);{all bits, so up to 64 for a 64 bit program (one processor group)}
  if result<=0 then
  begin
    //can't get the affinity mask so we just report the total number of processors
    GetSystemInfo(SystemInfo);
    result:=SystemInfo.dwNumberOfProcessors;
  end;
  if result<1 then result:=1;
end;
{$ELSEIF defined(freebsd) or defined(darwin)}
type
  PSysCtl = {$IF FPC_FULLVERSION>=30200}pcint{$ELSE}pchar{$ENDIF};
var
  mib: array[0..1] of cint;
  len: csize_t;
  t: cint;
begin
  t:=0;
  mib[0] := CTL_HW;
  mib[1] := HW_NCPU;
  len := sizeof(t);
  fpsysctl(PSysCtl(@mib), 2, @t, @len, Nil, 0);
  result:=t;
  if result<1 then result:=1;
end;
{$ELSEIF defined(android)}
begin
  result:=sysconf(_SC_NPROCESSORS_ONLN);
  if result<1 then result:=1;
end;
{$ELSEIF defined(linux)}
begin
  if cached_threads=0 then count_linux;
  result:=cached_threads;
end;
{$ELSE}
begin
  result:=1;
end;
{$ENDIF}


function GetSystemCoreCount: integer;
{$IF defined(windows)}
var
  buf      : array of TLogicalProcessorInformation;
  len      : DWORD;
  i, n     : integer;
  pmask    : PtrUInt;
  get_info : TGetLogicalProcessorInformation;
begin
  result:=0;
  pmask:=process_mask;
  len:=0;
  get_info:=TGetLogicalProcessorInformation(GetProcAddress(GetModuleHandle('kernel32.dll'),'GetLogicalProcessorInformation'));{loaded at run time, Windows XP SP2 and older do not have it}
  if assigned(get_info) then get_info(nil,len);{fails and returns the required size}
  if len>0 then
  begin
    setlength(buf,len div sizeof(TLogicalProcessorInformation)+1);
    if get_info(@buf[0],len) then
    begin
      n:=len div sizeof(TLogicalProcessorInformation);
      for i:=0 to n-1 do
        if ((buf[i].Relationship=0{RelationProcessorCore}) and ((pmask=0) or ((buf[i].ProcessorMask and pmask)<>0))) then
          inc(result);{a core with at least one processor this process may use}
    end;
  end;
  n:=GetSystemThreadCount;
  if ((result<=0) or (result>n)) then result:=n;
end;
{$ELSEIF defined(freebsd) or defined(darwin)}
var
  n : integer;
begin
  n:=GetSystemThreadCount;
  {$IFDEF darwin}
  result:=sysctl_int('hw.physicalcpu');
  {$ELSE}
  result:=sysctl_int('kern.smp.cores');
  {$ENDIF}
  if ((result<=0) or (result>n)) then result:=n;
end;
{$ELSEIF defined(android)}
begin
  result:=GetSystemThreadCount;{ARM processors have no hyperthreading}
end;
{$ELSEIF defined(linux)}
begin
  if cached_cores=0 then count_linux;
  result:=cached_cores;
end;
{$ELSE}
begin
  result:=1;
end;
{$ENDIF}


procedure CallLocalProc(AProc, Frame: Pointer; Param1: PtrInt;
  Param2, Param3: Pointer); inline;
type
  PointerLocal = procedure(_EBP: Pointer; Param1: PtrInt;
                           Param2, Param3: Pointer);
begin
  PointerLocal(AProc)(Frame, Param1, Param2, Param3);
end;

end.
