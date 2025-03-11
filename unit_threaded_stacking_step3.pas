unit unit_threaded_stacking_step3;
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils, astap_main, unit_star_align,unit_mtpcpu;  // Include necessary units

procedure finalise_array(var dest, source, arrayA,arrayB,arrayC: Timage_array; solution_vectorX,solution_vectorY : Tsolution_vector; background, weightf,variance_factor: double);// add source to dest


implementation
uses
  math;

type
  TfinalArrayThread = class(TThread)
  private
    FRowStart, FRowEnd, Fcolors,Fheight_dest, Fwidth_dest, Fheight_source, Fwidth_source: Integer;
    Faa, Fbb, Fcc, Fdd, Fee, Fff, Fbackground, Fweightf,Fvariance_factor: double;
    dest, source, arrayA,arrayB,arrayC: ^Timage_array;
  protected
    procedure Execute; override;
  public
    constructor Create(RowStart, RowEnd: Integer; var ArrDest, ArrSource, ArrA,ArrB,ArrC: Timage_array; solution_vectorX,solution_vectorY : Tsolution_vector; background, weightf,variance_factor: double; colors,height_dest, width_dest,width_source: integer);
  end;


constructor TfinalArrayThread.Create(RowStart, RowEnd: Integer; var ArrDest, ArrSource, ArrA,ArrB,ArrC: Timage_array; solution_vectorX,solution_vectorY : Tsolution_vector; background, weightf,variance_factor: double;colors, height_dest,width_dest,width_source: integer);
begin
  inherited Create(True); // Create suspended
  FreeOnTerminate := False;
  FRowStart := RowStart;
  FRowEnd := RowEnd;
  dest := @ArrDest;
  source := @ArrSource;
  arrayA := @ArrA;
  arrayB := @ArrB;
  arrayC := @ArrC;
  Faa:=solution_vectorX[0]; //move to local variables for some speed improvement
  Fbb:=solution_vectorX[1];
  Fcc:=solution_vectorX[2];
  Fdd:=solution_vectorY[0];
  Fee:=solution_vectorY[1];
  Fff:=solution_vectorY[2];

  fbackground := background;
  Fweightf := weightf;
  Fcolors:=colors;
  Fheight_dest:=height_dest;
  Fwidth_dest:=width_dest;
  Fwidth_source:=width_source;
  Fvariance_factor:=variance_factor;
end;


procedure TfinalArrayThread.Execute;
var
  h, w, col, x_new, y_new: Integer;
  value : single;
begin
 //combine excluding outliers
  for h := FRowStart to FRowEnd do
    for w := 0 to Fwidth_source - 1 do
    begin
      x_new := Round(Faa * w + Fbb * h + Fcc);//correction x:=aX+bY+c
      y_new := Round(Fdd * w + Fee * h + Fff);//correction y:=aX+bY+c

      if ((x_new >= 0) and (x_new < Fwidth_dest) and (y_new >= 0) and (y_new < Fheight_dest)) then
      begin
        for col := 0 to Fcolors - 1 do
        begin
//          img_final, img_loaded, img_average,img_variance, img_temp
//           dest      source      arrayA      arrayB          arrayC

          value:=(source^[col,h,w]- Fbackground)*FweightF;
          if sqr (value - arrayA^[col,y_new,x_new])< Fvariance_factor*{sd sqr}( arrayB^[col,y_new,x_new])  then {not an outlier}
          begin
            dest^[col,y_new,x_new]:=dest^[col,y_new,x_new]+ value;{dark and flat, flat dark already applied}
            arrayC^[col,y_new,x_new]:=arrayC^[col,y_new,x_new]+FweightF {norm 1};{count the number of image pixels added=samples}
          end;
        end;
      end;
  end;

end;

procedure finalise_array(var dest, source, arrayA,arrayB,arrayC: Timage_array; solution_vectorX,solution_vectorY : Tsolution_vector; background, weightf,variance_factor: double);// add source to dest
var
  THREAD_COUNT: Integer;
  Threads: array of TfinalArrayThread;
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
      RowEnd := height_source - 1;


    Threads[i] := TfinalArrayThread.Create(RowStart, RowEnd, dest, source, arrayA,arrayB,arrayC, solution_vectorX,solution_vectorY, background, weightf,variance_factor{doubles},colors, height_dest,width_dest,width_source);
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

