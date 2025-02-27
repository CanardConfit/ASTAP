unit unit_threaded_calibration;
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface
uses
  Classes, SysUtils, astap_main;  // Include necessary units

procedure Calibrate_image(var dest, source : Timage_array;mode:string;flat_norm_value,flatnorm11,flatnorm12,flatnorm21,flatnorm22:double);//calibrate img dest with source


implementation
uses
   math;

var
  THREAD_COUNT: Integer;

type
  TcalibrateThread = class(TThread)
  private
    FRowStart, FRowEnd, Fcolors, Fheight_max, Fwidth_max: Integer;
    dest, source, count: ^Timage_array;
    Fmode: string;
    Fflat_norm_value,Fflatnorm11,Fflatnorm12,Fflatnorm21,Fflatnorm22: double;
  protected
    procedure Execute; override;
  public
    constructor Create(RowStart, RowEnd: Integer; var ArrDest, ArrSource: Timage_array;colors,height_d, width_d: integer; mode :string; flat_norm_value, flatnorm11,flatnorm12,flatnorm21,flatnorm22:double);
  end;


constructor TcalibrateThread.Create(RowStart, RowEnd: Integer; var ArrDest, ArrSource: Timage_array;colors, height_d, width_d: integer;mode:string; flat_norm_value,flatnorm11,flatnorm12,flatnorm21,flatnorm22:double);
begin
  inherited Create(True); // Create suspended
  FreeOnTerminate := False;
  FRowStart := RowStart;
  FRowEnd := RowEnd;
  dest := @ArrDest;
  source := @ArrSource;
  Fcolors:=colors;
  Fheight_max := height_d;
  Fwidth_max := width_d;
  Fmode:=mode;
  Fflat_norm_value:= flat_norm_value;
  Fflatnorm11:= flatnorm11;
  Fflatnorm12:= flatnorm12;
  Fflatnorm21:= flatnorm21;
  Fflatnorm22:= flatnorm22;
end;

procedure TcalibrateThread.Execute;
var
  c,h, w, col : Integer;
  flat_factor : double;
begin
  if Fmode='-' then  //subtract dark
  begin
  for h := FRowStart to FRowEnd do
    for w := 0 to Fwidth_max - 1 do
      dest^[0,h,w]:=dest^[0,h,w]- source^[0,h,w];
  end
  else
  if Fmode='/' then  //monochrome images (or weird images already in colour)
  begin
    for c := 0 to Fcolors-1 do {do all colors}
      for h := FRowStart to FRowEnd do
        for w := 0 to Fwidth_max - 1 do
        begin
          flat_factor := Fflat_norm_value / (source^[0,h,w] + 0.001);  {bias is already combined in flat in combine_flat}
          flat_factor:=min(4.0,max(flat_factor,-4.0)); {un-used sensor area? Prevent huge gain of areas only containing noise and no flat-light value resulting in very strong disturbing noise or high value if dark is missing. Typical problem for converted RAW's by Libraw}
          dest^[0,h,w]:=dest^[0,h,w]* flat_factor;
        end;
  end
  else
  if Fmode='O' then //osc
  begin
    for h := FRowStart to FRowEnd do
      for w := 0 to Fwidth_max - 1 do
      begin //thread the red, green and blue pixels seperately
        //bias is already combined in flat in combine_flat
        if odd(w) then
        begin
          if odd(h) then
            flat_factor :=  FflatNorm11 / (source^[0, h , w] + 0.001)  //normalise flat for colour 11
          else
            flat_factor :=  FflatNorm12 / (source^[0, h , w] + 0.001)  //normalise flat for colour 12
        end
        else
        begin
          if odd(h) then
            flat_factor :=  FflatNorm21 / (source^[0, h , w] + 0.001) //normalise flat for colour 21
          else
            flat_factor :=  FflatNorm22 / (source^[0, h , w] + 0.001) //normalise flat for colour 22
        end;
        flat_factor:=min(4,max(flat_factor,-4)); {un-used sensor area? Prevent huge gain of areas only containing noise and no flat-light value resulting in very strong disturbing noise or high value if dark is missing. Typical problem for converted RAW's by Libraw}
        dest^[0,h,w]:=dest^[0,h,w]* flat_factor;
      end;
  end
end;

procedure Calibrate_image(var dest, source : Timage_array;mode:string;flat_norm_value,flatnorm11,flatnorm12,flatnorm21,flatnorm22:double);//calibrate img dest with source
var
  Threads: array of TcalibrateThread;
  i, RowStart, RowEnd, RowsPerThread,colors, height_d,width_d: Integer;
begin
  colors := Length(dest);
  height_d := Length(dest[0]);
  width_d := Length(dest[0, 0]);

  // Limit thread count to available CPU cores or height
  THREAD_COUNT := Min(System.CPUCount, height_d);

 // THREAD_COUNT :=2;

  SetLength(Threads, THREAD_COUNT);
  RowsPerThread := height_d div THREAD_COUNT;

  // Create and start threads
  for i := 0 to THREAD_COUNT - 1 do
  begin
    RowStart := i * RowsPerThread;
    RowEnd := (i + 1) * RowsPerThread - 1;
    if i = THREAD_COUNT - 1 then
      RowEnd := height_d - 1;


    Threads[i] := TcalibrateThread.Create(RowStart, RowEnd, dest, source,colors, height_d,width_d,mode,flat_norm_value,flatnorm11,flatnorm12,flatnorm21,flatnorm22);
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

