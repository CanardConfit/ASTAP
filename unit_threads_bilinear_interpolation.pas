unit unit_threads_bilinear_interpolation;

interface

uses
  Classes, SysUtils, astap_main;

type
  TDemosaicThread = class(TThread)
  private
    FImg: ^TImage_Array;
    FImgTemp: ^TImage_Array;
    FPattern: Integer;
    FStartY, FEndY: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(var Img, ImgTemp: TImage_Array; Pattern, StartY, EndY: Integer);
  end;

procedure demosaic_bilinear_interpolation(var img: TImage_Array; pattern: Integer); {make from sensor bayer pattern the three colors}

implementation

uses Math;

constructor TDemosaicThread.Create(var Img, ImgTemp: TImage_Array; Pattern, StartY, EndY: Integer);
begin
  inherited Create(True); // Create suspended
  FImg := @Img;
  FImgTemp := @ImgTemp;
  FPattern := Pattern;
  FStartY := StartY;
  FEndY := EndY;
  FreeOnTerminate := False; // Prevent automatic destruction
end;

procedure TDemosaicThread.Execute;
var
  x, y, offsetx, offsety: Integer;
  red, green_odd, green_even, blue: Boolean;
begin
  case FPattern of
    0: begin offsetx := 0; offsety := 0; end; // 'GRBG'
    1: begin offsetx := 0; offsety := 1; end; // 'BGGR'
    2: begin offsetx := 1; offsety := 0; end; // 'RGGB'
    3: begin offsetx := 1; offsety := 1; end; // 'GBRG'
    else Exit;
  end;

  for  y := Max(1, FStartY)  to Min(FEndY, Head.Height - 2) do // -2 = -1 -1
          //for deBayer you have calculate over a range of three pixels. So for the pixel between two green sensitive pixels you have to allocate the average green of
          //the neighboring pixels. So FendY should only be limited at the top and bottom otherwise you get black lines
  begin
    for x := 1 to Head.Width - 2 do
    begin  //http://cilab.knu.ac.kr/English/research/Color/Interpolation.htm ,  Bilinear interpolation
      try
        green_even := ((Odd(x + 1 + offsetX)) and (Odd(y + 1 + offsetY)));//even(i) function is odd(i+1), even is here for array position not fits position
        green_odd  := ((Odd(x + offsetX)) and (Odd(y + offsetY)));
        red        := ((Odd(x + offsetX)) and (Odd(y + 1 + offsetY)));
        blue       := ((Odd(x + 1 + offsetX)) and (Odd(y + offsetY)));

        if green_odd then
        begin
          FImgTemp^[0, y, x] := (FImg^[0, y - 1, x] + FImg^[0, y + 1, x])/ 2; //red neighbor pixels
          FImgTemp^[1, y, x] := FImg^[0, y, x];
          FImgTemp^[2, y, x] := (FImg^[0, y, x - 1] + FImg^[0, y, x + 1])/ 2; //blue neighbor pixels
        end
        else if green_even then
        begin
          FImgTemp^[0, y, x] := (FImg^[0, y, x - 1] + FImg^[0, y, x + 1])/ 2;;//red neighbor pixels
          FImgTemp^[1, y, x] := FImg^[0, y, x];
          FImgTemp^[2, y, x] := (FImg^[0, y - 1, x] + FImg^[0, y + 1, x])/ 2; //blue neighbor pixels
        end
        else if red then
        begin
          FImgTemp^[0, y, x] := FImg^[0, y, x];
          FImgTemp^[1, y, x] := (FImg^[0, y, x - 1] + FImg^[0, y, x + 1] + FImg^[0, y - 1, x] + FImg^[0, y + 1, x])/ 4; {green neighbours}
          FImgTemp^[2, y, x] := (FImg^[0, y - 1, x - 1] + FImg^[0, y + 1, x - 1] + FImg^[0, y - 1, x + 1] + FImg^[0, y + 1, x + 1])/ 4; {blue neighbor pixels }
        end
        else if blue then
        begin
          FImgTemp^[0, y, x] := (FImg^[0, y - 1, x - 1] + FImg^[0, y + 1, x - 1] + FImg^[0, y - 1, x + 1] + FImg^[0, y + 1, x + 1]) / 4;
          FImgTemp^[1, y, x] := (FImg^[0, y, x - 1] + FImg^[0, y, x + 1] + FImg^[0, y - 1, x] + FImg^[0, y + 1, x]) / 4;
          FImgTemp^[2, y, x] := FImg^[0, y, x];
        end;
      except
        // Handle potential out-of-bounds access safely
      end;
    end;//x loop
  end;//x loop
end;

procedure demosaic_bilinear_interpolation(var img: TImage_Array; pattern: Integer);{make from sensor bayer pattern the three colors}
var
  NumThreads : integer;
  Threads: array of TDemosaicThread;
  img_temp2: TImage_Array;
  i, StartY, EndY, SectionHeight: Integer;
begin
//  SetLength(img_temp2, 3, Head.Height, Head.Width);
  SetLength(img_Temp2, 3, Length(img[0]), Length(img[0, 0])); // Set length of image array color

  // Limit thread arrayA to available CPU cores or height
  NumThreads := System.CPUCount;  // Adjust based on CPU cores

  //NumThreads := 1;

  SectionHeight := Head.Height div NumThreads;
  if odd(SectionHeight) then SectionHeight:=SectionHeight+1;//Keep always even for correct handling Bayer pattern

  SetLength(Threads, NumThreads);

  // Create and start threads
  for i := 0 to NumThreads - 1 do
  begin
    StartY := i * SectionHeight;
    EndY := min((i + 1) * SectionHeight - 1, Length(img[0])) ;

    Threads[i] := TDemosaicThread.Create(img, img_temp2, pattern, StartY, EndY);
    Threads[i].Start;
  end;

  // Wait for all threads to finish
  for i := 0 to NumThreads - 1 do
  begin
    Threads[i].WaitFor;
    Threads[i].Free;
  end;

  // Copy the result back
  img := img_temp2;
end;

end.
