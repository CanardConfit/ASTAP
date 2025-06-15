unit unit_threaded_demosaic_astrom_bilinear_interpolation;
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }
interface

uses
  Classes, SysUtils, astap_main, unit_mtpcpu;

type
  TDemosaicThread = class(TThread)
  private
    FImg: ^TImage_Array;  //You're storing a pointer to Img, not a copy of it.
    FImgTemp: ^TImage_Array;
    FPattern: Integer;
    FStartY, FEndY: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(var Img, ImgTemp: TImage_Array; Pattern, StartY, EndY: Integer);
  end;

procedure demosaic_astroM_bilinear_interpolation(var img : Timage_array;pattern: integer);{make from sensor bayer pattern the three colors}

implementation

uses Math;

constructor TDemosaicThread.Create(var Img, ImgTemp: TImage_Array; Pattern, StartY, EndY: Integer);
begin
  inherited Create(True); // Create suspended
  FImg := @Img; //You're storing a pointer to Img, not a copy of it.  Your are avoiding a full copy of the arrays will be stored in each thread, consuming more memory.
  FImgTemp := @ImgTemp;
  FPattern := Pattern;
  FStartY := StartY;
  FEndY := EndY;
  FreeOnTerminate := False; // Prevent automatic destruction
end;

procedure TDemosaicThread.Execute;
var
  x, y,xx,yy, offsetx, offsety,w,h,count : Integer;
  red, green_odd, green_even, blue : Boolean;
  a1,a2,a3,a4,a5,a6,a7,a8, average1,average2,average3,luminance,signal,signal2,bg : single;

begin
  case FPattern of
    0: begin offsetx := 0; offsety := 0; end; // 'GRBG'
    1: begin offsetx := 0; offsety := 1; end; // 'BGGR'
    2: begin offsetx := 1; offsety := 0; end; // 'RGGB'
    3: begin offsetx := 1; offsety := 1; end; // 'GBRG'
    else Exit;
  end;


  h:= Length(Fimg^[0]);
  w:= Length(Fimg^[0,0]);

  {calculate mean background value}
  count:=0;
  bg:=0;

  for yy:= 1 to 29 do
  for xx:=1 to 99 do
  begin
    y:=(h*yy) div 30;
    x:=(w*xx) div 100;
    bg:=bg+Fimg^[0,y,x]+
           Fimg^[0,y  ,x+1  ]+
           Fimg^[0,y+1,x  ]+
           Fimg^[0,y+1,x+1];
    inc(count,4)
  end;
  bg:=bg/count;{average background value}

  signal:=0.5*bg;     {2 values   140,100  average is 120, delta is 20/120 is 16.7%}
  signal2:=signal/1.67; {4 values   140,100,100,100  average is 110, delta 30/110 is 27.2%, so factor 1.67 difference}

  for  y := Max(1, FStartY)  to Min(FEndY, h - 2) do // -2 = -1 -1
          //for deBayer you have calculate over a range of three pixels. So for the pixel between two green sensitive pixels you have to allocate the average green of
          //the neighboring pixels. So FendY should only be limited at the top and bottom otherwise you get black lines
  begin
    for x := 1 to w - 2 do
    begin  //Bilinear interpolation
      try
      green_even:= ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );{even(i) function is odd(i+1), even is here for array position not fits position. Place here otherwise stars get tail}
      green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
      red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
      blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );

      if green_odd then
                 begin
                   a1:=FImg^[0,y-1,x  ];
                   a2:=FImg^[0,y+1,x  ];
                   average1:=(a1+a2)/2;{red neighbor pixels };

                   average2:=(FImg^[0,  y  ,x] );

                   a3:=FImg^[0,y  ,x-1];
                   a4:=FImg^[0,y  ,x+1];
                   average3:=(a3+a4)/2; {blue neighbor pixels }

                   if ((a1>average1+signal) or (a2>average1+signal) or (a3>average2+signal) or (a4>average2+signal)) {severe magnitude_slope} then
                   begin
                     luminance:=(average1+average2+average3)/3;
                     Fimgtemp^[0,y,x]:=luminance;{remove color info, keep luminace}
                     Fimgtemp^[1,y,x]:=luminance;
                     Fimgtemp^[2,y,x]:=luminance;
                   end
                   else
                   begin
                     Fimgtemp^[0,y,x]:=average1;
                     Fimgtemp^[1,y,x]:=average2;
                     Fimgtemp^[2,y,x]:=average3;

                   end;
                 end
      else
      if green_even then
                    begin
                      a1:=FImg^[0,y  ,x-1];
                      a2:=FImg^[0,y  ,x+1];
                      average1:=(a1+a2)/2;{red neighbor pixels };

                      average2:=     (FImg^[0,  y  ,x] );

                      a3:=FImg^[0,y-1,x  ];
                      a4:=FImg^[0,y+1,x  ];
                      average3:=(a3+a4)/2; {blue neighbor pixels };

                      if ((a1>average1+signal) or (a2>average1+signal) or (a3>average2+signal) or (a4>average2+signal)) {severe magnitude_slope} then
                     begin
                       luminance:=(average1+average2+average3)/3;
                       Fimgtemp^[0,y,x]:=luminance;{remove color info, keep luminace}
                       Fimgtemp^[1,y,x]:=luminance;
                       Fimgtemp^[2,y,x]:=luminance;
                     end
                     else
                     begin
                       Fimgtemp^[0,y,x]:=average1;
                       Fimgtemp^[1,y,x]:=average2;
                       Fimgtemp^[2,y,x]:=average3;

                     end;
                   end
      else
      if red then begin
                   average1:=(FImg^[0,  y  ,x]);

                   a1:= FImg^[0,y  ,x-1];
                   a2:= FImg^[0,y  ,x+1];
                   a3:= FImg^[0,y-1,x  ];
                   a4:= FImg^[0,y+1,x  ];{green neighbours}
                   average2:=(a1+a2+a3+a4)/4;


                   a5:= FImg^[0,y-1,x-1];
                   a6:= FImg^[0,y+1,x-1];
                   a7:= FImg^[0,y-1,x+1];
                   a8:= FImg^[0,y+1,x+1];{blue neighbours}
                   average3:=(a5+a6+a7+a8)/4;

                   if ((a1>average2+signal2) or (a2>average2+signal2) or (a3>average2+signal2) or (a4>average2+signal2) or
                       (a5>average3+signal2) or (a6>average3+signal2) or (a7>average3+signal2) or (a8>average3+signal2) ) then {severe magnitude_slope}
                   begin
                     luminance:=(average1+average2+average3)/3;
                     Fimgtemp^[0,y,x]:=luminance;{remove color info, keep luminace}
                     Fimgtemp^[1,y,x]:=luminance;
                     Fimgtemp^[2,y,x]:=luminance;
                   end
                   else
                   begin
                     Fimgtemp^[0,y,x]:=average1;
                     Fimgtemp^[1,y,x]:=average2;
                     Fimgtemp^[2,y,x]:=average3;
                   end;

      end

      else
      if blue then
                 begin
                   average1:=(FImg^[0,  y  ,x]);

                   a1:= FImg^[0,y-1,x-1];
                   a2:= FImg^[0,y+1,x-1];
                   a3:= FImg^[0,y-1,x+1];
                   a4:= FImg^[0,y+1,x+1];{red neighbours}
                   average1:=(a1+a2+a3+a4)/4;

                   a5:= FImg^[0,y  ,x-1];
                   a6:= FImg^[0,y  ,x+1];
                   a7:= FImg^[0,y-1,x  ];
                   a8:= FImg^[0,y+1,x  ];{green neighbours}
                   average2:=(a5+a6+a7+a8)/4;

                   average3:=FImg^[0,  y  ,x];

                   if ((a1>average1+signal2) or (a2>average1+signal2) or (a3>average1+signal2) or (a4>average1+signal2) or
                       (a5>average2+signal2) or (a6>average2+signal2) or (a7>average2+signal2) or (a8>average2+signal2) ) then {severe magnitude_slope}
                   begin
                     luminance:=(average1+average2+average3)/3;
                     Fimgtemp^[0,y,x]:=luminance;{remove color info, keep luminace}
                     Fimgtemp^[1,y,x]:=luminance;
                     Fimgtemp^[2,y,x]:=luminance;
                   end
                   else
                   begin
                     Fimgtemp^[0,y,x]:=average1;
                     Fimgtemp^[1,y,x]:=average2;
                     Fimgtemp^[2,y,x]:=average3;


                   end;
                 end;
      except
      end;
    end;{x loop}
  end;{y loop}


end;

procedure demosaic_astroM_bilinear_interpolation(var img:  Timage_array;pattern: integer);{make from sensor bayer pattern the three colors}
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
  NumThreads := Min(System.CPUCount, Length(img[0]));//work in Windows and Linux virtual machine but not in native Linux or Darwin and returns then 1.
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

  // Copy the result back
  img := img_temp2;
end;


end.
