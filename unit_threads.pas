unit unit_threads;

interface

uses
  Classes, SysUtils, astap_main;  // Include necessary units

procedure Add_Array(var dest, source, count: Timage_array; aa,bb,cc,dd,ee,ff, background, weightf: double);// add source to dest
procedure Calibrate_image(var dest, source : Timage_array;mode:string;flat_norm_value,flatnorm11,flatnorm12,flatnorm21,flatnorm22:double);//calibrate img dest with source


type
  TLoadThread = class(TThread)
  private
    FFileName: string;
    FLight, FLoadData, FUpdateMemo: Boolean;
    FGetExt: Integer;
    FMemo: TStrings;
    FHead: ^Theader;
    FTargetArray: ^Timage_array;
    FSuccess: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(const FileName: string; Light, LoadData, UpdateMemo: Boolean;
      GetExt: Integer; const Memo: TStrings; var Head: Theader; var TargetArray: Timage_array);
    function WasSuccessful: Boolean;
  end;



implementation
uses
   DateUtils, math
   //,{$IFDEF MSWINDOWS} Windows {$ENDIF}
   ;

var
  THREAD_COUNT: Integer;

type
  TAddThread = class(TThread)
  private
    FRowStart, FRowEnd, Fcolors,Fheight_dest, Fwidth_dest, Fheight_source, Fwidth_source: Integer;
    Faa, Fbb, Fcc, Fdd, Fee, Fff, Fbackground, Fweightf: double;
    dest, source, count: ^Timage_array;
  protected
    procedure Execute; override;
  public
    constructor Create(RowStart, RowEnd: Integer; var ArrDest, ArrSource, Arrcount: Timage_array; aa,bb,cc,dd,ee,ff, background, weightf: double; colors,height_dest, width_dest,width_source: integer);
  end;


constructor TAddThread.Create(RowStart, RowEnd: Integer; var ArrDest, ArrSource, Arrcount: Timage_array;  aa,bb,cc,dd,ee,ff, background, weightf: double;colors, height_dest,width_dest,width_source: integer);
begin
  inherited Create(True); // Create suspended
  FreeOnTerminate := False;
  FRowStart := RowStart;
  FRowEnd := RowEnd;
  dest := @ArrDest;
  source := @ArrSource;
  count := @Arrcount;
  faa := aa;
  fbb := bb;
  fcc := cc;
  fdd := dd;
  fee := ee;
  fff := ff;
  fbackground := background;
  Fweightf := weightf;
  Fcolors:=colors;
  Fheight_dest:=height_dest;
  Fwidth_dest:=width_dest;
  Fwidth_source:=width_source;
end;


procedure TAddThread.Execute;
var
  h, w, col, x_new, y_new: Integer;
begin
  for h := FRowStart to FRowEnd do
    for w := 0 to Fwidth_source - 1 do
    begin
      x_new := Round(Faa * w + Fbb * h + Fcc);
      y_new := Round(Fdd * w + Fee * h + Fff);

      if ((x_new >= 0) and (x_new < Fwidth_dest) and (y_new >= 0) and (y_new < Fheight_dest)) then
      begin
        for col := 0 to Fcolors - 1 do
        begin
          dest^[col,y_new,x_new]:=dest^[col,y_new,x_new]+ (source^[col,h,w]-Fbackground)*Fweightf;//Sum flux only. image loaded is already corrected with dark and flat}{NOTE: fits count from 1, image from zero
        end;
        count^[0,y_new,x_new]:=count^[0,y_new,x_new]+FweightF{typical 1}
      end;
    end;
end;

procedure Add_Array(var dest, source, count: Timage_array; aa,bb,cc,dd,ee,ff, background, weightf: double);// add source to dest
var
  Threads: array of TAddThread;
  i, RowStart, RowEnd, RowsPerThread,colors,height_dest,width_dest, height_source, width_source: Integer;

begin
  colors := Length(dest);
  height_dest := Length(dest[0]);
  width_dest := Length(dest[0, 0]);
  height_source := Length(source[0]);
  width_source := Length(source[0, 0]);

  // Limit thread count to available CPU cores or height
  THREAD_COUNT := Min(System.CPUCount, height_source);

 // THREAD_COUNT :=2;

  SetLength(Threads, THREAD_COUNT);
  RowsPerThread := height_source div THREAD_COUNT;

  // Create and start threads
  for i := 0 to THREAD_COUNT - 1 do
  begin
    RowStart := i * RowsPerThread;
    RowEnd := (i + 1) * RowsPerThread - 1;
    if i = THREAD_COUNT - 1 then
      RowEnd := height_source - 1;


    Threads[i] := TAddThread.Create(RowStart, RowEnd, dest, source, count, aa,bb,cc,dd,ee,ff, background, weightf,colors, height_dest,width_dest,width_source);
    Threads[i].Start;
  end;

  // Wait for all threads to finish
  for i := 0 to THREAD_COUNT - 1 do
  begin
    Threads[i].WaitFor;
    Threads[i].Free;
  end;
end;

//=====================================================================================================================================

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

//=====================================================================================================================================


constructor TLoadThread.Create(const FileName: string; Light, LoadData, UpdateMemo: Boolean; GetExt: Integer; const Memo: TStrings; var Head: Theader; var TargetArray: Timage_array);
begin
  inherited Create(False);  // Start immediately
  FreeOnTerminate := False;
  FFileName := FileName;
  FLight := Light;
  FLoadData := LoadData;
  FUpdateMemo := UpdateMemo;
  FGetExt := GetExt;
  FMemo := Memo;
  FHead := @Head;
  FTargetArray := @TargetArray;
  FSuccess := False; // Default to failure until proven otherwise
end;

procedure TLoadThread.Execute;
begin
  // Call the function and store the success result
  FSuccess := load_fits(FFileName, FLight, FLoadData, FUpdateMemo, FGetExt, FMemo, FHead^, FTargetArray^);
end;

function TLoadThread.WasSuccessful: Boolean;
begin
  Result := FSuccess;
end;

begin
end.

