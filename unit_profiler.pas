unit unit_profiler;

{Usage:
profiler_start;
   do some processing1
profile_log(do some processing1);
   do some processing2
profile_log(do some processing2);
memo2_message(plog);
}

interface

uses
{$IFDEF WINDOWS}
Windows,
{$ENDIF}
{$IFDEF UNIX}
ctypes, unixtype, Unix,
{$ENDIF}
SysUtils;


procedure profiler_start;//reset profiler time. Clear clears the log
procedure profiler_log(message: string); //log duration with message in string plog

var
  plog:string=''; //will contain the logged messages and duration time



implementation

var
  StartTime: Int64;

function GetMicroseconds: Int64;
{$IFDEF WINDOWS}
var
  Freq, Count: Int64;
begin
  QueryPerformanceFrequency(Freq);
  QueryPerformanceCounter(Count);
  Result := (Count * 1000000) div Freq;
end;
{$ELSE}
var
  tv: timeval;
begin
  fpgettimeofday(@tv, nil);
  Result := (Int64(tv.tv_sec) * 1000000) + tv.tv_usec;
end;
{$ENDIF}


function DateTimeToMilliseconds(aDateTime: TDateTime): Int64;
var
  TimeStamp: TTimeStamp;
begin
  {Call DateTimeToTimeStamp to convert DateTime to TimeStamp:}
  TimeStamp:= DateTimeToTimeStamp (aDateTime);
  Result:= TimeStamp.Time;
end;


procedure profiler_start;//reset profiler time. Clear clears the log
begin
  plog:='';
  starttime:=GetMicroseconds;
end;

procedure profiler_log(message: string);//log duration with message in string plog
begin
  plog:=plog+Format(message+', duration: %d µs', [GetMicroseconds - starttime])+#13+#10;
  starttime:=GetMicroseconds;//reset start time for next measurement
end;


end.

