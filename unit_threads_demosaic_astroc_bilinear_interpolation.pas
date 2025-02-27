unit unit_threads_demosaic_astroC_bilinear_interpolation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math;

type
  TImage_Array = array of array of array of Single;

  { TDemosaicThread }
  TDemosaicThread = class(TThread)
  private
    var img, img_temp2: TImage_Array;
    var FStartY, FEndY, pattern: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(var imgSrc, imgDst: TImage_Array; patternType, StartY, EndY: Integer);
  end;

procedure Demosaic_AstroC_Bilinear_Interpolation(var img: TImage_Array; saturation, pattern: Integer);

implementation

{ TDemosaicThread }

constructor TDemosaicThread.Create(var imgSrc, imgDst: TImage_Array; patternType, StartY, EndY: Integer);
begin
  inherited Create(False);
  img := imgSrc;
  img_temp2 := imgDst;
  FStartY := StartY;
  FEndY := EndY;
  pattern := patternType;
  FreeOnTerminate := False;
end;

procedure TDemosaicThread.Execute;
var
  x, y: Integer;
  offsetX, offsetY: Integer;
  green_even, green_odd, red, blue: Boolean;
  a1, a2, a3, a4, a5, a6, a7, a8, avg1, avg2, avg3: Single;
begin
  // Set offsets based on Bayer pattern
  case pattern of
    0: begin offsetX := 0; offsetY := 0; end;
    1: begin offsetX := 0; offsetY := 1; end;
    2: begin offsetX := 1; offsetY := 0; end;
    3: begin offsetX := 1; offsetY := 1; end;
  else
    Exit;
  end;

  // Process image section
  for y := Max(1, FStartY) to Min(FEndY, Length(img[0]) - 2) do
  begin
    for x := 1 to Length(img[0, 0]) - 2 do
    begin
      try
        green_even := ((odd(x + 1 + offsetX)) and (odd(y + 1 + offsetY)));
        green_odd := ((odd(x + offsetX)) and (odd(y + offsetY)));
        red := ((odd(x + offsetX)) and (odd(y + 1 + offsetY)));
        blue := ((odd(x + 1 + offsetX)) and (odd(y + offsetY)));

        if green_odd then
        begin
          a1 := img[0, y - 1, x];
          a2 := img[0, y + 1, x];
          avg1 := (a1 + a2) / 2;

          avg2 := img[0, y, x];

          a3 := img[0, y, x - 1];
          a4 := img[0, y, x + 1];
          avg3 := (a3 + a4) / 2;

          img_temp2[0, y, x] := avg1;
          img_temp2[1, y, x] := avg2;
          img_temp2[2, y, x] := avg3;
        end
        else if green_even then
        begin
          a1 := img[0, y, x - 1];
          a2 := img[0, y, x + 1];
          avg1 := (a1 + a2) / 2;

          avg2 := img[0, y, x];

          a3 := img[0, y - 1, x];
          a4 := img[0, y + 1, x];
          avg3 := (a3 + a4) / 2;

          img_temp2[0, y, x] := avg1;
          img_temp2[1, y, x] := avg2;
          img_temp2[2, y, x] := avg3;
        end
        else if red then
        begin
          avg1 := img[0, y, x];

          a1 := img[0, y, x - 1];
          a2 := img[0, y, x + 1];
          a3 := img[0, y - 1, x];
          a4 := img[0, y + 1, x];
          avg2 := (a1 + a2 + a3 + a4) / 4;

          a5 := img[0, y - 1, x - 1];
          a6 := img[0, y + 1, x - 1];
          a7 := img[0, y - 1, x + 1];
          a8 := img[0, y + 1, x + 1];
          avg3 := (a5 + a6 + a7 + a8) / 4;

          img_temp2[0, y, x] := avg1;
          img_temp2[1, y, x] := avg2;
          img_temp2[2, y, x] := avg3;
        end
        else if blue then
        begin
          avg3 := img[0, y, x];

          a1 := img[0, y - 1, x - 1];
          a2 := img[0, y + 1, x - 1];
          a3 := img[0, y - 1, x + 1];
          a4 := img[0, y + 1, x + 1];
          avg1 := (a1 + a2 + a3 + a4) / 4;

          a5 := img[0, y, x - 1];
          a6 := img[0, y, x + 1];
          a7 := img[0, y - 1, x];
          a8 := img[0, y + 1, x];
          avg2 := (a5 + a6 + a7 + a8) / 4;

          img_temp2[0, y, x] := avg1;
          img_temp2[1, y, x] := avg2;
          img_temp2[2, y, x] := avg3;
        end;
      except
      end;
    end;
  end;
end;

procedure Demosaic_AstroC_Bilinear_Interpolation(var img: TImage_Array; saturation, pattern: Integer);
var
  Threads: array of TDemosaicThread;
  i, NumThreads, SectionHeight, StartY, EndY: Integer;
  img_temp2: TImage_Array;
begin
  NumThreads := System.CPUCount;
  SectionHeight := Length(img[0]) div NumThreads;
  if Odd(SectionHeight) then Inc(SectionHeight);

  SetLength(Threads, NumThreads);
  SetLength(img_temp2, 3, Length(img[0]), Length(img[0, 0]));

  for i := 0 to NumThreads - 1 do
  begin
    StartY := i * SectionHeight;
    EndY := Min((i + 1) * SectionHeight - 1, Length(img[0]) - 1);

    Threads[i] := TDemosaicThread.Create(img, img_temp2, pattern, StartY, EndY);
    Threads[i].Start;
  end;

  for i := 0 to NumThreads - 1 do
  begin
    Threads[i].WaitFor;
    Threads[i].Free;
  end;

  img := img_temp2;
end;

end.

