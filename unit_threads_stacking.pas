unit unit_threads_stacking;

interface

uses
  Classes, SysUtils, astap_main;  // Include necessary units

procedure Add_Array(var dest, source, count: Timage_array; aa,bb,cc,dd,ee,ff, background, weightf: double);// add source to dest


implementation
uses
  math;

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


begin
end.

