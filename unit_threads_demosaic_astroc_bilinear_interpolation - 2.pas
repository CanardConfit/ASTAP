unit unit_threads_demosaic_astroC_bilinear_interpolation;

interface

uses
  Classes, SysUtils, math;

type
  Timage_array = array of array of array of Single;

  TDemosaicThread = class(TThread)
  private
    FStartY, FEndY: Integer;
    img, img_temp2: Timage_array;
    pattern: Integer;
    saturation: Single;

  protected
    procedure Execute; override;
  public
    constructor Create(var AImg, AImgTemp2: Timage_array; APattern, AStartY, AEndY: Integer); reintroduce;
  end;


procedure Demosaic_AstroC_Bilinear_Interpolation(var img: TImage_Array; saturation, pattern: Integer);
procedure demosaic_astroC_bilinear_interpolationOld(var img:Timage_array;saturation {saturation point}, pattern: integer);{make from sensor bayer pattern the three colors}

implementation

uses unit_stack;

{ TDemosaicThread }

constructor TDemosaicThread.Create(var AImg, AImgTemp2: Timage_array; APattern, AStartY, AEndY: Integer);
begin
  inherited Create(True);
  img := AImg;
  img_temp2 := AImgTemp2;
  pattern := APattern;
  FStartY := AStartY;
  FEndY := AEndY;
  FreeOnTerminate := True;
end;

procedure TDemosaicThread.Execute;
var
  x, y, x2, y2, fitsX, fitsY, sat_counter,counter: Integer;
  offsetx, offsety: Integer;
  red, green_odd, green_even, blue: Boolean;
  a1, a2, a3, a4, a5, a6, a7, a8, average1, average2, average3, luminance, r, g, b, colred, colgreen, colblue, rgb, lowest: Single;
  bg, sqr_dist: Double;
const
  step = 5;
begin
  case pattern of
    0: begin offsetx := 0; offsety := 0; end;
    1: begin offsetx := 0; offsety := 1; end;
    2: begin offsetx := 1; offsety := 0; end;
    3: begin offsetx := 1; offsety := 1; end;
    else Exit;
  end;

  bg := 0;
  counter := 0;

  for y := Max(1, FStartY) to Min(FEndY, Length(img[0]) - 2) do
  begin
    for x := 1 to Length(img[0][0]) - 2 do
    begin
      try
        green_even := ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );
        green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
        red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
        blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );

        if green_odd then
        begin
          a1 := img[0, y-1, x];
          a2 := img[0, y+1, x];
          average1 := (a1 + a2) / 2;
          average2 := img[0, y, x];
          a3 := img[0, y, x-1];
          a4 := img[0, y, x+1];
          average3 := (a3 + a4) / 2;

          if ((a1 > saturation) or (a2 > saturation) or (a3 > saturation) or (a4 > saturation)) then
          begin
            img_temp2[0, y, x] := (average1 + average2 + average3) / 3;
            img_temp2[1, y, x] := $FFFFFF;
          end
          else
          begin
            img_temp2[0, y, x] := average1;
            img_temp2[1, y, x] := average2;
            img_temp2[2, y, x] := average3;
          end;
        end;
      except
      end;
    end;
  end;

  img := img_temp2;
  exit;
  if counter > 0 then
  begin
    bg := bg / counter;
    sat_counter := 0;
    for fitsY := 0 to Length(img[0]) - 1 do
    for fitsX := 0 to Length(img[0][0]) - 1 do
    if img_temp2[1, fitsY, fitsX] = $FFFFFF then
    begin
      colred := 0;
      colgreen := 0;
      colblue := 0;
      counter := 0;
      inc(sat_counter);
      luminance := img_temp2[0, fitsY, fitsX];
      luminance := luminance - bg;

      for y := -step to step do
      for x := -step to step do
      begin
        x2 := fitsX + x;
        y2 := fitsY + y;

        if ((x2 >= 0) and (x2 < Length(img[0][0])) and (y2 >= 0) and (y2 < Length(img[0]))) then
        begin
          sqr_dist := x * x + y * y;
          if sqr_dist <= step * step then
          begin
            g := img_temp2[1, y2, x2];
            if g <> $FFFFFF then
            begin
              r := img_temp2[0, y2, x2];
              b := img_temp2[2, y2, x2];
              if (r - bg) > 0 then colred := colred + (r - bg);
              if (g - bg) > 0 then colgreen := colgreen + (g - bg);
              if (b - bg) > 0 then colblue := colblue + (b - bg);
              inc(counter);
            end;
          end;
        end;
      end;

      if counter >= 1 then
      begin
        colred := colred / counter;
        colgreen := colgreen / counter;
        colblue := colblue / counter;
        if colred > colblue then lowest := colblue else lowest := colred;
        if colgreen < lowest then colgreen := lowest;
        rgb := (colred + colgreen + colblue + 0.00001) / 3;
        img[0, fitsY, fitsX] := bg + luminance * colred / rgb;
        img[1, fitsY, fitsX] := bg + luminance * colgreen / rgb;
        img[2, fitsY, fitsX] := bg + luminance * colblue / rgb;
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


procedure demosaic_astroC_bilinear_interpolationOld(var img:Timage_array;saturation {saturation point}, pattern: integer);{make from sensor bayer pattern the three colors}
var
    X,Y,offsetx, offsety, counter,fitsX,fitsY,x2,y2,sat_counter,h,w : integer;
    red,green_odd,green_even,blue : boolean;
    img_temp2 : Timage_array;
    a1,a2,a3,a4,a5,a6,a7,a8, average1,average2,average3,luminance, r,g,b,colred,colgreen,colblue,rgb,lowest: single;
    bg, sqr_dist   :  double;
const
  step = 5;
begin
  case pattern  of
     0: begin offsetx:=0; offsety:=0; end;
     1: begin offsetx:=0; offsety:=1; end;
     2: begin offsetx:=1; offsety:=0; end;
     3: begin offsetx:=1; offsety:=1; end;
     else exit;
  end;

  h:= Length(img[0]);
  w:= Length(img[0,0]);

  SetLength(img_Temp2, 3, h, w); // Set length of image array color

  bg:=0;
  counter:=0;{prevent divide by zero for fully saturated images}

  for y := 1 to h-2 do   {-2 = -1 -1}
  begin
    for x:=1 to w-2 do
    begin

      try
      green_even:= ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );{even(i) function is odd(i+1), even is here for array position not fits position}
      green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
      red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
      blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );
      if green_odd then
                 begin
                   a1:=img[0,y-1,x  ];
                   a2:=img[0,y+1,x  ];
                   average1:=(a1+a2)/2;{red neighbor pixels };

                   average2:=(img[0,  y  ,x] );

                   a3:=img[0,y  ,x-1];
                   a4:=img[0,y  ,x+1];
                   average3:=(a3+a4)/2; {blue neighbor pixels }

                   if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation)) {saturation} then
                   begin
                     img_temp2[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2[1,y,x]:=$FFFFFF;{marker pixel as saturated}
                   end
                   else
                   begin
                     img_temp2[0,y,x]:=average1;
                     img_temp2[1,y,x]:=average2;
                     img_temp2[2,y,x]:=average3;
                   end;
                 end
      else
      if green_even then
                    begin
                      a1:=img[0,y  ,x-1];
                      a2:=img[0,y  ,x+1];
                      average1:=(a1+a2)/2;{red neighbor pixels };

                      average2:=     (img[0,  y  ,x] );

                      a3:=img[0,y-1,x  ];
                      a4:=img[0,y+1,x  ];
                      average3:=(a3+a4)/2; {blue neighbor pixels };

                     if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation)) {saturation} then
                     begin
                       img_temp2[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                       img_temp2[1,y,x]:=$FFFFFF;{marker pixel as saturated}
                     end
                     else
                     begin
                       img_temp2[0,y,x]:=average1;
                       img_temp2[1,y,x]:=average2;
                       img_temp2[2,y,x]:=average3;

                     end;
                   end
      else
      if red then begin
                   average1:=(img[0,  y  ,x]);

                   a1:= img[0,y  ,x-1];
                   a2:= img[0,y  ,x+1];
                   a3:= img[0,y-1,x  ];
                   a4:= img[0,y+1,x  ];{green neighbours}
                   average2:=(a1+a2+a3+a4)/4;


                   a5:= img[0,y-1,x-1];
                   a6:= img[0,y+1,x-1];
                   a7:= img[0,y-1,x+1];
                   a8:= img[0,y+1,x+1];{blue neighbours}
                   average3:=(a5+a6+a7+a8)/4;

                   if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation) or
                       (a5>saturation) or (a6>saturation) or (a7>saturation) or (a8>saturation) ) then {saturation}
                   begin
                     img_temp2[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2[1,y,x]:=$FFFFFF;{marker pixel as saturated}

                   end
                   else
                   begin
                     img_temp2[0,y,x]:=average1;
                     img_temp2[1,y,x]:=average2;
                     img_temp2[2,y,x]:=average3;

                     {calculate background}
                     bg:=bg+average1+average2+average3;
                     inc(counter,3); {added red, green, blue values}
                   end;
      end
      else
      if blue then
                 begin
                   average1:=(img[0,  y  ,x]);

                   a1:= img[0,y-1,x-1];
                   a2:= img[0,y+1,x-1];
                   a3:= img[0,y-1,x+1];
                   a4:= img[0,y+1,x+1];{red neighbours}
                   average1:=(a1+a2+a3+a4)/4;

                   a5:= img[0,y  ,x-1];
                   a6:= img[0,y  ,x+1];
                   a7:= img[0,y-1,x  ];
                   a8:= img[0,y+1,x  ];{green neighbours}
                   average2:=(a5+a6+a7+a8)/4;

                   average3:=img[0,  y  ,x];

                   if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation) or
                       (a5>saturation) or (a6>saturation) or (a7>saturation) or (a8>saturation) ) then {saturation}
                   begin
                     img_temp2[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2[1,y,x]:=$FFFFFF;{marker pixel as saturated}
                   end
                   else
                   begin
                     img_temp2[0,y,x]:=average1;
                     img_temp2[1,y,x]:=average2;
                     img_temp2[2,y,x]:=average3;

                   end;
                 end;
      except
      end;

    end;{x loop}
  end;{y loop}

  img:=img_temp2;

  if counter>0 then {not fully saturated image}
  begin
  {correct colour saturated pixels }

    bg:=bg/counter; {background}
    sat_counter:=0;
    for fitsY:=0 to h-1 do
    for fitsX:=0 to w-1 do
    if img_temp2[1,fitsY,fitsX]=$FFFFFF {marker saturated} then
    begin
      colred:=0;
      colgreen:=0;
      colblue:=0;
      counter:=0;
      inc(sat_counter);
      luminance:=img_temp2[0,fitsY,fitsX];
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
               g:= img_temp2[1,y2,x2];
               if g<>$FFFFFF {not saturated pixel} then
               begin
                 r:= img_temp2[0,y2,x2];
                 B:= img_temp2[2,y2,x2];

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
        img[0,  fitsY  ,fitsX  ]:=bg+ luminance*colred/rgb;
        img[1,  fitsY  ,fitsX  ]:=bg+ luminance*colgreen/rgb;
        img[2,  fitsY  ,fitsX  ]:=bg+ luminance*colblue/rgb;
      end
      else
      begin
       img[1,  fitsY  ,fitsX  ]:=img_temp2[0,  fitsY  ,fitsX  ];
       img[2,  fitsY  ,fitsX  ]:=img_temp2[0,  fitsY  ,fitsX  ];

      end;
    end;
  end{not full saturated}
  else
  begin {fully saturated image}
    for fitsY:=0 to h-1 do
    for fitsX:=0 to w-1 do
    begin
      img[0,  fitsY  ,fitsX  ]:=saturation;
      img[1,  fitsY  ,fitsX  ]:=saturation;
      img[2,  fitsY  ,fitsX  ]:=saturation;
    end;
  end;

  if sat_counter/(w*h)>0.1 then memo2_message('█ █ █ █ █ █  More than 10% of the image is saturated and will give poor results!! Try demosaic method AstroSimple and exposure shorter next time. █ █ █ █ █ █ ');
end;

end.

