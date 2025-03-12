unit unit_threaded_demosaic_astroc_bilinear_interpolation;

{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils, Math,unit_mtpcpu;

type
  TImage_Array = array of array of array of Single;

  { TDemosaicThread }
  TDemosaicThread = class(TThread)
  private
    img, img_temp2: ^TImage_Array;
    FStartY, FEndY: Integer;
    Fpattern, Fsaturation : integer;
    FSaturationRatio: Double;
  protected
    procedure Execute; override;
  public
    constructor Create(var imgSrc, imgDst: TImage_Array;  saturation,pattern, StartY, EndY: Integer);
    property SaturationRatio: Double read FSaturationRatio;
  end;

procedure Demosaic_AstroC_Bilinear_Interpolation(var img: TImage_Array; saturation, pattern: Integer);

implementation

uses unit_stack;

{ TDemosaicThread }

constructor TDemosaicThread.Create(var imgSrc, imgDst: TImage_Array; saturation,pattern, StartY, EndY: Integer);
begin
  inherited Create(False);
  img := @imgSrc;
  img_temp2 := @imgDst;
  FStartY := StartY;
  FEndY := EndY;
  Fpattern := pattern;
  Fsaturation:=saturation;
  FreeOnTerminate := False;
end;

procedure TDemosaicThread.Execute;
var
  x, y, counter,w,h: Integer;
  offsetX, offsetY, fitsX,fitsY,x2,y2,sat_counter: Integer;
  green_even, green_odd, red, blue: Boolean;
  a1, a2, a3, a4, a5, a6, a7, a8,  average1,average2,average3,luminance,r,g,b,colred,colgreen,colblue,rgb,lowest: Single;
  bg, sqr_dist: Double;
const
  step = 5;
begin
  // Set offsets based on Bayer pattern
  case Fpattern of
    0: begin offsetX := 0; offsetY := 0; end;
    1: begin offsetX := 0; offsetY := 1; end;
    2: begin offsetX := 1; offsetY := 0; end;
    3: begin offsetX := 1; offsetY := 1; end;
  else
    Exit;
  end;

  h:= Length(img^[0]);
  w:= Length(img^[0,0]);
  bg := 0;
  counter := 0;


  // Process image section
  for y := Max(1, FStartY) to Min(FEndY, Length(img^[0]) - 2) do
  begin
    for x := 1 to Length(img^[0, 0]) - 2 do
    begin
      try
      green_even:= ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );{even(i) function is odd(i+1), even is here for array position not fits position}
      green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
      red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
      blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );
      if green_odd then
                 begin
                   a1:=img^[0,y-1,x  ];
                   a2:=img^[0,y+1,x  ];
                   average1:=(a1+a2)/2;{red neighbor pixels };

                   average2:=(img^[0,  y  ,x] );

                   a3:=img^[0,y  ,x-1];
                   a4:=img^[0,y  ,x+1];
                   average3:=(a3+a4)/2; {blue neighbor pixels }

                   if ((a1>Fsaturation) or (a2>Fsaturation) or (a3>Fsaturation) or (a4>Fsaturation)) {saturation} then
                   begin
                     img_temp2^[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2^[1,y,x]:=$FFFFFF;{marker pixel as saturated}
                   end
                   else
                   begin
                     img_temp2^[0,y,x]:=average1;
                     img_temp2^[1,y,x]:=average2;
                     img_temp2^[2,y,x]:=average3;
                   end;
                 end
      else
      if green_even then
                    begin
                      a1:=img^[0,y  ,x-1];
                      a2:=img^[0,y  ,x+1];
                      average1:=(a1+a2)/2;{red neighbor pixels };

                      average2:=     (img^[0,  y  ,x] );

                      a3:=img^[0,y-1,x  ];
                      a4:=img^[0,y+1,x  ];
                      average3:=(a3+a4)/2; {blue neighbor pixels };

                     if ((a1>Fsaturation) or (a2>Fsaturation) or (a3>Fsaturation) or (a4>Fsaturation)) {saturation} then
                     begin
                       img_temp2^[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                       img_temp2^[1,y,x]:=$FFFFFF;{marker pixel as saturated}
                     end
                     else
                     begin
                       img_temp2^[0,y,x]:=average1;
                       img_temp2^[1,y,x]:=average2;
                       img_temp2^[2,y,x]:=average3;

                     end;
                   end
      else
      if red then begin
                   average1:=(img^[0,  y  ,x]);

                   a1:= img^[0,y  ,x-1];
                   a2:= img^[0,y  ,x+1];
                   a3:= img^[0,y-1,x  ];
                   a4:= img^[0,y+1,x  ];{green neighbours}
                   average2:=(a1+a2+a3+a4)/4;


                   a5:= img^[0,y-1,x-1];
                   a6:= img^[0,y+1,x-1];
                   a7:= img^[0,y-1,x+1];
                   a8:= img^[0,y+1,x+1];{blue neighbours}
                   average3:=(a5+a6+a7+a8)/4;

                   if ((a1>Fsaturation) or (a2>Fsaturation) or (a3>Fsaturation) or (a4>Fsaturation) or
                       (a5>Fsaturation) or (a6>Fsaturation) or (a7>Fsaturation) or (a8>Fsaturation) ) then {saturation}
                   begin
                     img_temp2^[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2^[1,y,x]:=$FFFFFF;{marker pixel as saturated}

                   end
                   else
                   begin
                     img_temp2^[0,y,x]:=average1;
                     img_temp2^[1,y,x]:=average2;
                     img_temp2^[2,y,x]:=average3;

                     {calculate background}
                     bg:=bg+average1+average2+average3;
                     inc(counter,3); {added red, green, blue values}
                   end;
      end
      else
      if blue then
                 begin
                   average1:=(img^[0,  y  ,x]);

                   a1:= img^[0,y-1,x-1];
                   a2:= img^[0,y+1,x-1];
                   a3:= img^[0,y-1,x+1];
                   a4:= img^[0,y+1,x+1];{red neighbours}
                   average1:=(a1+a2+a3+a4)/4;

                   a5:= img^[0,y  ,x-1];
                   a6:= img^[0,y  ,x+1];
                   a7:= img^[0,y-1,x  ];
                   a8:= img^[0,y+1,x  ];{green neighbours}
                   average2:=(a5+a6+a7+a8)/4;

                   average3:=img^[0,  y  ,x];

                   if ((a1>Fsaturation) or (a2>Fsaturation) or (a3>Fsaturation) or (a4>Fsaturation) or
                       (a5>Fsaturation) or (a6>Fsaturation) or (a7>Fsaturation) or (a8>Fsaturation) ) then {saturation}
                   begin
                     img_temp2^[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2^[1,y,x]:=$FFFFFF;{marker pixel as saturated}
                   end
                   else
                   begin
                     img_temp2^[0,y,x]:=average1;
                     img_temp2^[1,y,x]:=average2;
                     img_temp2^[2,y,x]:=average3;

                   end;
                 end;
      except
      end;

    end;{x loop}
  end;{y loop}


  if counter>0 then {not fully saturated image}
  begin
  {correct colour saturated pixels }

    bg:=bg/counter; {background (for this part of the image, could cause problem using threads}
    sat_counter:=0;
    for fitsY:=FStartY to FEndY-1 do
    for fitsX:= 1 to w - 2 do
    if img_temp2^[1,fitsY,fitsX]=$FFFFFF {marker saturated} then
    begin
      colred:=0;
      colgreen:=0;
      colblue:=0;
      counter:=0;
      inc(sat_counter);
      luminance:=img_temp2^[0,fitsY,fitsX];
      luminance:=luminance-bg;{luminance above background}
      begin
        for y:=-step to step do
        for x:=-step to step do
        begin
           x2:=fitsX+x;
           y2:=fitsY+y;


           if ((x2>=0) and (x2<w) and (y2>=0) and (y2<h) ) then {within image}
           begin
             sqr_dist:=x*x+y*y;
             if sqr_dist<=step*step then {circle only}
             begin
               g:= img_temp2^[1,y2,x2];
               if g<>$FFFFFF {not saturated pixel} then
               begin
                 r:= img_temp2^[0,y2,x2];
                 B:= img_temp2^[2,y2,x2];

                 if (r-bg)>0 {signal} then colred  :=colred+   (r-bg); {bg=average red and will be little above the background since stars are included in the average}
                 if (g-bg)>0 then colgreen:=colgreen+ (g-bg);
                 if (b-bg)>0 then colblue:= colblue + (b-bg);
                 inc(counter);
               end;
             end;
           end;
         end;
      end;

      rgb:=0;
      if counter>=1 then
      begin
        colred:=colred/counter;{scale using the number of data points=count}
        colgreen:=colgreen/counter;
        colblue:=colblue/counter;
        if colred>colblue then lowest:=colblue else lowest:=colred;
        if colgreen<lowest {purple} then colgreen:=lowest; {prevent purple stars, purple stars are physical not possible}
        rgb:=(colred+colgreen+colblue+0.00001)/3; {0.00001, prevent dividing by zero}
        img_temp2^[0,  fitsY  ,fitsX  ]:=bg+ luminance*colred/rgb;
        img_temp2^[1,  fitsY  ,fitsX  ]:=bg+ luminance*colgreen/rgb;
        img_temp2^[2,  fitsY  ,fitsX  ]:=bg+ luminance*colblue/rgb;
      end
      else
      begin
       img_temp2^[1,  fitsY  ,fitsX  ]:=img_temp2^[0,  fitsY  ,fitsX  ];
       img_temp2^[2,  fitsY  ,fitsX  ]:=img_temp2^[0,  fitsY  ,fitsX  ];

      end;
    end;
  end{not full saturated}
  else
  begin {fully saturated image}

    for fitsY:=0 to h-1 do
    for fitsX:=0 to w-1 do
    begin
      img_temp2^[0,  fitsY  ,fitsX  ]:=Fsaturation;
      img_temp2^[1,  fitsY  ,fitsX  ]:=Fsaturation;
      img_temp2^[2,  fitsY  ,fitsX  ]:=Fsaturation;
    end;
  end;
  FSaturationRatio := sat_counter / ((FEndY - FStartY) * Length(img^[0][0]));
//  if sat_counter/(FStartY * FEndY)>0.1 then memo2_message('█ █ █ █ █ █  More than 10% of the image is saturated and will give poor results!! Try demosaic method AstroSimple and exposure shorter next time. █ █ █ █ █ █ ');
end;


procedure Demosaic_AstroC_Bilinear_Interpolation(var img: TImage_Array; saturation, pattern: Integer);
var
  Threads: array of TDemosaicThread;
  i, NumThreads, SectionHeight, StartY, EndY: Integer;
  img_temp2: TImage_Array;
  warning_given : boolean;
begin
  // Limit threads to available CPU logical cores or height
  {$ifdef mswindows}
  NumThreads := Min(System.CPUCount, Length(img[0]));//work in Windows and Linux virtual machine but not in native Linux or Darwin and returns then 1.
  {$else} {unix}
  NumThreads := Min(GetSystemThreadCount, Length(img[0]));
  {$endif}

  SectionHeight := Length(img[0]) div NumThreads;
  if Odd(SectionHeight) then Inc(SectionHeight);

  SetLength(img_temp2, 3, Length(img[0]), Length(img[0, 0]));

  SetLength(Threads, NumThreads);
  for i := 0 to NumThreads - 1 do
  begin
    StartY := i * SectionHeight;
    EndY := Min((i + 1) * SectionHeight - 1, Length(img[0]) - 1);

    Threads[i] := TDemosaicThread.Create(img, img_temp2, saturation,pattern, StartY, EndY);
    Threads[i].Start;
  end;

  warning_given:=false;

  for i := 0 to NumThreads - 1 do
  begin
    Threads[i].WaitFor;
    if ((warning_given=false) and (Threads[i].SaturationRatio> 0.1)) then
    begin
      memo2_message('█ █ █ █ █ █  More than 10% of the image is saturated and will give poor results!! Try demosaic method AstroSimple and exposure shorter next time. █ █ █ █ █ █ ');
      warning_given:=true;
    end;
    Threads[i].Free;
  end;

  img:=img_temp2;
end;


end.

