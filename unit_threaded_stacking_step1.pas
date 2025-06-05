unit unit_threaded_stacking_step1;
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils, astap_main, unit_star_align, unit_mtpcpu;  // Include necessary units

procedure stack_arrays(var dest, source, arrayA: Timage_array; solution_vectorX,solution_vectorY : Tsolution_vector; background, weightf: double);// add source to dest


implementation
uses
  math;

type
  TcombineArrayThread = class(TThread)
  private
    FRowStart, FRowEnd, Fcolors,Fheight_dest, Fwidth_dest, Fheight_source, Fwidth_source: Integer;
    Faa, Fbb, Fcc, Fdd, Fee, Fff, Fbackground, Fweightf,Fvariance_factor: double;
    dest, source, arrayA: ^Timage_array;
  protected
    procedure Execute; override;
  public
    constructor Create(RowStart, RowEnd: Integer; var ArrDest, ArrSource, ArrA: Timage_array; solution_vectorX,solution_vectorY : Tsolution_vector; background, weightf: double; colors, width_dest,height_source,width_source: integer);
  end;


constructor TcombineArrayThread.Create(RowStart, RowEnd: Integer; var ArrDest, ArrSource, ArrA: Timage_array; solution_vectorX,solution_vectorY : Tsolution_vector; background, weightf: double;colors, width_dest,height_source,width_source: integer);
begin
  inherited Create(True); // Create suspended
  FreeOnTerminate := False;
  FRowStart := RowStart;
  FRowEnd := RowEnd;
  dest := @ArrDest;
  source := @ArrSource;
  arrayA := @ArrA;
  Faa:=solution_vectorX[0]; //move to local variables for some speed improvement
  Fbb:=solution_vectorX[1];
  Fcc:=solution_vectorX[2];
  Fdd:=solution_vectorY[0];
  Fee:=solution_vectorY[1];
  Fff:=solution_vectorY[2];

  fbackground := background;
  Fweightf := weightf;
  Fcolors:=colors;
  Fwidth_dest:=width_dest;
  Fwidth_source:=width_source;
  Fheight_source:=height_source;

end;


procedure TcombineArrayThread.Execute;
var
  h, w, col, x_trunc,y_trunc  : Integer;
  x_frac,y_frac,x_new, y_new  : double;
  val                         : single;
begin
  //Inverse Mapping (a.k.a. Backward Mapping) Instead of mapping source → destination (forward), you loop over destination pixels and figure out where they came from in the original image
  for h := FRowStart to FRowEnd do
    for w := 0 to Fwidth_source - 1 do  // This procedure is using reverse mapping. So the transfer function from destination to source image is known. See e.g. https://www.cs.princeton.edu/courses/archive/spr11/cos426/notes/cos426_s11_lecture03_warping.pdf
    begin //find source image position
      x_new := Faa * w + Fbb * h + Fcc;//correction x:=aX+bY+c
      y_new := Fdd * w + Fee * h + Fff;//correction y:=aX+bY+c

      x_trunc:=trunc(x_new);
      y_trunc:=trunc(y_new);
      if ((x_trunc > 0) and (x_trunc < Fwidth_source-1) and (y_trunc > 0) and (y_trunc < Fheight_source-1)) then
      begin
        x_frac :=frac(x_new);
        y_frac :=frac(y_new);

        for col := 0 to Fcolors - 1 do //resample the source image
        begin //Bilinearly interpolate four closest pixels of the source
          val:=      (source^[col,y_trunc  ,x_trunc  ]) * (1-x_frac)*(1-y_frac);{pixel left top,    1}
          val:=val + (source^[col,y_trunc  ,x_trunc+1]) * (  x_frac)*(1-y_frac);{pixel right top,   2}
          val:=val + (source^[col,y_trunc+1,x_trunc  ]) * (1-x_frac)*(  y_frac);{pixel left bottom, 3}
          val:=val + (source^[col,y_trunc+1,x_trunc+1]) * (  x_frac)*(  y_frac);{pixel right bottom,4}
          dest^[col,h,w]:=dest^[col,h,w]+(val-Fbackground)*FweightF;//Sum flux only. image loaded is already corrected with dark and flat}{NOTE: fits arrayA from 1, image from zero
        end;
        arrayA^[0,h,w]:=arrayA^[0,h,w]+FweightF;{WeightF is typically 1. Calculate the sum of the weights}
      end;
    end;
end;


procedure stack_arrays(var dest, source, arrayA: Timage_array; solution_vectorX,solution_vectorY : Tsolution_vector; background, weightf: double);// add source to dest
var
  THREAD_COUNT: Integer;
  Threads: array of TcombineArrayThread;
  i, RowStart, RowEnd, RowsPerThread,colors,height_dest,width_dest, height_source, width_source: Integer;

begin
  colors := Length(dest);
  height_dest := Length(dest[0]);
  width_dest := Length(dest[0, 0]);
  height_source := Length(source[0]);
  width_source := Length(source[0, 0]);

  // Limit threads to available CPU logical cores or height
  {$ifdef mswindows}
  THREAD_COUNT := Min(System.CPUCount, height_source);//work in Windows and Linux virtual machine but not in native Linux or Darwin and return then 1.
  {$else} {unix}
  THREAD_COUNT := Min(GetSystemThreadCount, height_source);
  {$endif}

  SetLength(Threads, THREAD_COUNT);
  RowsPerThread := height_source div THREAD_COUNT;

  // Create and start threads
  for i := 0 to THREAD_COUNT - 1 do
  begin
    RowStart := i * RowsPerThread;
    RowEnd := (i + 1) * RowsPerThread - 1;
    if i = THREAD_COUNT - 1 then
      RowEnd := height_dest - 1;


    Threads[i] := TcombineArrayThread.Create(RowStart, RowEnd, dest, source, arrayA, solution_vectorX,solution_vectorY, background, weightf{doubles},colors, width_dest,height_source,width_source);
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

