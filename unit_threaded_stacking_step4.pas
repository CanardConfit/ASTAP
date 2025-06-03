unit unit_threaded_stacking_step4;
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils, astap_main, unit_star_align, unit_mtpcpu;  // Include necessary units

procedure scale_array(out dest: Timage_array; source, arrayA: Timage_array; pedestal : single);// correct with weight factor and add pedestal


implementation
uses
  math;

type
  TcombineArrayThread = class(TThread)
  private
    Fcolors,Fheight_dest, Fwidth_dest: Integer;
    Fpedestal             : single;
    dest, source, arrayA: ^Timage_array;
  protected
    procedure Execute; override;
  public
    constructor Create(var ArrDest, ArrSource, ArrA: Timage_array; pedestal : single;colors, height_dest,width_dest: integer);
  end;


constructor TcombineArrayThread.Create(var ArrDest, ArrSource, ArrA: Timage_array; pedestal : single;colors, height_dest,width_dest: integer);
begin
  inherited Create(True); // Create suspended
  FreeOnTerminate := False;
  dest := @ArrDest;
  source := @ArrSource;
  arrayA := @ArrA;


  fpedestal:= pedestal;
  Fcolors:=colors;
  Fheight_dest:=height_dest;
  Fwidth_dest:=width_dest;
end;


procedure TcombineArrayThread.Execute;
var
  tempval : single;
  h,w,col : integer;
begin
  if length(arrayA^)=1 then //version for average
  begin
    for h:=0 to Fheight_dest-1 do
      for w:=0 to Fwidth_dest-1 do
      begin {pixel loop}
        tempval:=arrayA^[0,h,w];
        for col:=0 to Fcolors-1 do
        begin {colour loop}
          if tempval<>0 then
            dest^[col,h,w]:=Fpedestal+source^[col,h,w]/tempval {scale to one image by diving by the number of pixels added}
          else
            dest^[col,h,w]:=Fpedestal;
        end; //scale array
      end;{pixel loop}
  end
  else
  begin //scale array for sigma clip
    for col:=0 to Fcolors-1 do {do one or three colors} {compensate for number of pixel values added per position}
      for h:=0 to Fheight_dest-1 do
        for w:=0 to Fwidth_dest-1 do
        begin
          tempval:=arrayA^[col,h,w];
          if tempval<>0 then
            dest^[col,h,w]:=Fpedestal+source^[col,h,w]/tempval {scale to one image by diving by the number of pixels added}
          else
            dest^[col,h,w]:=Fpedestal;{clear img_loaded since it is resized}
        end; //scale array for sigma clip
  end;
end;

procedure scale_array(out dest: Timage_array; source, arrayA: Timage_array; pedestal : single);// add source to dest
var
  THREAD_COUNT: Integer;
  Threads: array of TcombineArrayThread;
  i, RowStart, RowEnd, RowsPerThread,colors,height_dest,width_dest : Integer;

begin
  colors := Length(source);
  height_dest := Length(source[0]);
  width_dest := Length(source[0, 0]);

  setlength(dest,colors,height_dest,width_dest);{new size}

  // Limit thread arrayA to available CPU cores or height
  {$ifdef mswindows}
  THREAD_COUNT := Min(System.CPUCount, height_dest);//work in Windows and Linux virtual machine but not in native Linux or Darwin and return then 1.
  {$else} {unix}
  THREAD_COUNT := Min(GetSystemThreadCount, height_dest);  //unit_mtpcpu;
  {$endif}

  SetLength(Threads, THREAD_COUNT);
  RowsPerThread := height_dest div THREAD_COUNT;

  // Create and start threads
  for i := 0 to THREAD_COUNT - 1 do
  begin
    RowStart := i * RowsPerThread;
    RowEnd := (i + 1) * RowsPerThread - 1;
    if i = THREAD_COUNT - 1 then
      RowEnd := height_dest - 1;


    Threads[i] := TcombineArrayThread.Create(dest, source, arrayA,pedestal,colors, height_dest,width_dest);
    Threads[i].Start;
  end;

  // Wait for all threads to finish
  for i := 0 to THREAD_COUNT - 1 do
  begin
    Threads[i].WaitFor;
    Threads[i].Free;
  end;
end;


begin
end.

