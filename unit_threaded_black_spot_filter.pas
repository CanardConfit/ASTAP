unit unit_threaded_black_spot_filter;
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils, astap_main, unit_star_align;  // Include necessary units

procedure black_spot_filter(var dest, source, arrayA: Timage_array; pedestal : single);// correct black spots due to alignment. The pixel count is in arrayA


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
//  for h := FRowStart to FRowEnd do
//    for w := 0 to Fwidth_source - 1 do
//    begin
//      x_new := Round(Faa * w + Fbb * h + Fcc);//correction x:=aX+bY+c
//      y_new := Round(Fdd * w + Fee * h + Fff);//correction y:=aX+bY+c

//      if ((x_new >= 0) and (x_new < Fwidth_dest) and (y_new >= 0) and (y_new < Fheight_dest)) then
//      begin
//        for col := 0 to Fcolors - 1 do
//          dest^[col,y_new,x_new]:=dest^[col,y_new,x_new]+ (source^[col,h,w]-Fbackground)*Fweightf;//Sum flux only. image loaded is already corrected with dark and flat}{NOTE: fits arrayA from 1, image from zero

//        arrayA^[0,y_new,x_new]:=arrayA^[0,y_new,x_new]+FweightF{typical 1}
//      end;
//    end;

  for h:=0 to Fheight_dest-1 do
  for w:=0 to Fwidth_dest-1 do
  begin {pixel loop}
    tempval:=arrayA^[0,h,w];
    for col:=0 to Fcolors-1 do
    begin {colour loop}
      if tempval<>0 then dest^[col,h,w]:=Fpedestal+source^[col,h,w]/tempval {scale to one image by diving by the number of pixels added}
      else
      begin { black spot filter or missing value filter due to image rotation}
        if ((w>0) and (arrayA^[0,h,w-1]<>0)) then dest^[col,h,w]:=Fpedestal+dest^[col,h,w-1]{take nearest pixel x-1 as replacement}
        else
        if ((h>0) and (arrayA^[0,h-1,w]<>0)) then dest^[col,h,w]:=Fpedestal+dest^[col,h-1,w]{take nearest pixel y-1 as replacement}
        else
        dest^[col,h,w]:=0;{clear img_loaded since it is resized}
      end; {black spot}
    end;{colour loop}
  end;{pixel loop}









end;

procedure black_spot_filter(var dest, source, arrayA: Timage_array; pedestal : single);// add source to dest
var
  THREAD_COUNT: Integer;
  Threads: array of TcombineArrayThread;
  i, RowStart, RowEnd, RowsPerThread,colors,height_dest,width_dest : Integer;

begin
  colors := Length(dest);
  height_dest := Length(dest[0]);
  width_dest := Length(dest[0, 0]);

  // Limit thread arrayA to available CPU cores or height
  THREAD_COUNT := Min(System.CPUCount, height_dest);

 // THREAD_COUNT :=1;

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

