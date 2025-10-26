unit unit_threaded_demosaic_astrosimple;
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/. }
interface

uses
  Classes, SysUtils, astap_main, unit_mtpcpu;

type
  TDemosaicThread = class(TThread)
  private
    FImg    : ^TImage_Array;//You're storing a pointer to Img, not a copy of it.
    FImgTemp: ^TImage_Array;//You're storing a pointer to Img, not a copy of it.
    FPattern: Integer;
    FStartY, FEndY: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(var Img, ImgTemp: TImage_Array; Pattern, StartY, EndY: Integer);
  end;

procedure demosaic_astrosimple(var img:Timage_array;pattern: integer);{Spread each colour pixel to 2x2. Works well for astro oversampled images. Idea by Han.k}

implementation

uses Math;

constructor TDemosaicThread.Create(var Img, ImgTemp: TImage_Array; Pattern, StartY, EndY: Integer);
begin
  inherited Create(True); // Create suspended
  FImg := @Img; //You're storing a pointer to Img, not a copy of it.  Your are avoiding a full copy of the arrays will be stored in each thread, consuming more memory.
  FImgTemp := @ImgTemp;//You're storing a pointer to Img, not a copy of it.  Your are avoiding a full copy of the arrays will be stored in each thread, consuming more memory.
  FPattern := Pattern;
  FStartY := StartY;
  FEndY := EndY;
  FreeOnTerminate := False; // Prevent automatic destruction
end;

procedure TDemosaicThread.Execute;
var
  x, y, offsetx, offsety,w,h: Integer;
  red, green_odd, green_even, blue: Boolean;
  value : single;
begin
  case FPattern of
    0: begin offsetx := 0; offsety := 0; end; // 'GRBG'
    1: begin offsetx := 0; offsety := 1; end; // 'BGGR'
    2: begin offsetx := 1; offsety := 0; end; // 'RGGB'
    3: begin offsetx := 1; offsety := 1; end; // 'GBRG'
    else Exit;
  end;


  h:= Length(FImgTemp^[0]);
  w:= Length(FImgTemp^[0,0]);

  for  y := Max(1, FStartY)  to Min(FEndY, h - 2) do // -2 = -1 -1
          //for deBayer you have calculate over a range of three pixels. So for the pixel between two green sensitive pixels you have to allocate the average green of
          //the neighboring pixels. So FendY should only be limited at the top and bottom otherwise you get black lines
  begin
    for x := 1 to w - 2 do
    begin
      try
      green_even:= ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );{even(i) function is odd(i+1), even is here for array position not fits position}
      green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
      red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
      blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );

      value:=Fimg^[0,y,x];

      if ((green_odd) or (green_even)) then
      begin
        value:=value/2;
        FImgTemp^[1,y  ,x]  :=FImgTemp^[1,y  ,x]+value;
        FImgTemp^[1,y+1,x]  :=FImgTemp^[1,y+1,x]+value;
        FImgTemp^[1,y  ,x+1]:=FImgTemp^[1,y  ,x+1]+value;
        FImgTemp^[1,y+1,x+1]:=FImgTemp^[1,y+1,x+1]+value;
      end
      else
      if red then
      begin
        FImgTemp^[0,y  ,x]:=value;
        FImgTemp^[0,y  ,x+1]:=value;
        FImgTemp^[0,y+1,x]:=value;
        FImgTemp^[0,y+1,x+1]:=value;
      end
      else
      if blue then
      begin
        FImgTemp^[2,y  ,x]:=value;
        FImgTemp^[2,y  ,x+1]:=value;
        FImgTemp^[2,y+1,x]:=value;
        FImgTemp^[2,y+1,x+1]:=value;
      end;
      except
      end;
    end;{x loop}
  end;{y loop}
end;


procedure demosaic_astrosimple(var img: Timage_array;pattern: integer);{Spread each colour pixel to 2x2. Works well for astro oversampled images. Idea by Han.k}
var
  NumThreads : integer;
  Threads: array of TDemosaicThread;
  img_temp2: TImage_Array;
  i, StartY, EndY, SectionHeight: Integer;
begin
  //  SetLength(img_temp2, 3, Head.Height, Head.Width);
    SetLength(img_Temp2, 3, Length(Img[0]), Length(img[0, 0])); // Set length of image array color

  // Limit threads to available CPU logical cores or height
  {$ifdef mswindows}
  NumThreads := Min(System.CPUCount, Length(img[0]));//work in Windows and Linux virtual machine but not in native Linux or Darwin and return then 1.
  {$else} {unix}
  NumThreads := Min(GetSystemThreadCount, Length(img[0]));
  {$endif}

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

  img := img_temp2;  //Link result to img

end;


end.
