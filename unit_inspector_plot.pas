unit unit_inspector_plot;

{$mode delphi}

interface

uses
  Classes, SysUtils,math,astap_main, unit_stack, unit_annotation,graphics;

type
  hfd_array   = array of array of integer;

procedure CCDinspector_analyse(detype: char);

implementation



procedure filter_hfd(var mean,min_value,max_value : single; nr : integer; hfd_values: hfd_array); {filter array of hfd values}
var
  i,j,nr_closest,nr_second_closest,a,b,c,dummy:  integer;
  closest_distance,second_closest_distance,distance_sqr   : single;

begin


  {local filtering. Take median of three closest stars}
  max_value:=0;
  min_value:=65535;
  mean:=0;
  for i:=0 to nr-1 do
  begin
    closest_distance:=999999;
    second_closest_distance:=999999;
    nr_closest:=0;

    for j:=0 to nr-1 do
    begin
      if i<>j then
      begin
         distance_sqr:=(sqr(hfd_values[0,i]-hfd_values[0,j])+sqr(hfd_values[1,i]-hfd_values[1,j]));
         if distance_sqr<closest_distance then
         begin
           second_closest_distance:=closest_distance;
           closest_distance:=distance_sqr;
           nr_second_closest:=nr_closest;
           nr_closest:=j;
         end
         else
         if distance_sqr<second_closest_distance then
         begin
           second_closest_distance:=distance_sqr;
           nr_second_closest:=j;
         end;
      end;
    end;
    {find median of three stars}
    a:=hfd_values[2,i];
    b:=hfd_values[2,nr_closest];
    c:=hfd_values[2,nr_second_closest];

    if a<b then begin dummy:=b; b:=a; a:=dummy; end;{sort in sequence a,b,c wher a is the largest}
    if a<c then begin dummy:=c; c:=a; a:=dummy; end;{sort in sequence a,b,c wher a is the largest}
    if b<c then begin dummy:=c; c:=b; b:=dummy; end;{sort in sequence a,b,c wher a is the largest}

    hfd_values[2,i]:=b;  {hfd*100, place median value in this cell}

//    if b=701 then
//     beep;

    if max_value<b then max_value:=b;
    if min_value>b then min_value:=b;
     mean:=mean+b;
  end;
  mean:=mean/nr;
 {usefull length is nr}
end;

procedure voronoi_plot(min_value,max_value : single; nr:integer;hfd_values: hfd_array);
var
    i,j,size,fitsx,fitsY,col,x,y,x2,y2,nr2,nr3,w,h,scaledown,nr_closest,nr_second_closest,med_position,a,b,c,dummy:  integer;
    img_hfd: image_array;
    zeros_left : boolean;

begin
  scaledown:=1+ width2 div 1000;
  w:=(width2 div scaledown)+1;
  h:=(height2 div scaledown)+1;

  setlength(img_hfd,1,w,h);{set length of image array}
  for fitsY:=0 to h-1  do
    for fitsX:=0 to w-1 do
      img_hfd[0,fitsX,fitsY]:=0;{clear array}


  size:=0;
  repeat
    zeros_left:=false;
    for i:=0 to nr-1 do
    begin
      col:=hfd_values[2,i];

      for x:=-size to size do
      for y:=-size to size do
      if round(sqrt(sqr(x)+sqr(y)))=size then
      begin
        x2:=hfd_values[0,i] div scaledown + x;
        y2:=hfd_values[1,i] div scaledown + y;
        if ((x2>=0) and (x2<w) and (y2>=0) and (y2<h)) then
          if  img_hfd[ 0,x2,y2]=0 then {not used yet}
          begin
            img_hfd[ 0,x2,y2]:=col;
            zeros_left:=true;
          end;
      end;
    end;
    inc(size);
  until ((zeros_left=false) or (size>h/5));

  if naxis>1 then setlength(img_loaded,1,width2,height2);
  naxis3:=1;
  for fitsY:=0 to height2-1  do
    for fitsX:=0 to width2-1 do
      img_loaded[0,fitsX,fitsY]:={img_loaded[0,fitsX,fitsY]}+img_hfd[0,fitsX div scaledown,fitsY div scaledown];


  img_hfd:=nil;{free memory}

  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}

  cblack:=min_value;
  cwhite:=max_value;
  mainwindow.minimum1.position:=round(min_value);
  mainwindow.maximum1.position:=round(max_value);
 end;



procedure contour_plot(mean: single; nr:integer;hfd_values: hfd_array);
var
    i,fitsx,fitsY,x,y,w,h,x2,y2,scaledown : integer;
    img_hfd: image_array;
    cols,min_value,max_value,step_adjust  : single;
    distance,factor,influence, sum_influence,pixels_per_star: double;

begin
  scaledown:=1+ width2 div 1000;
  w:=(width2 div scaledown)+1;
  h:=(height2 div scaledown)+1;

  setlength(img_hfd,1,w,h);{set length of image array}
  for fitsY:=0 to h-1  do
    for fitsX:=0 to w-1 do
      img_hfd[0,fitsX,fitsY]:=0;{clear array}

  max_value:=0;
  min_value:=65535;

  pixels_per_star:=w*h/nr;

  factor:=2*sqrt(pixels_per_star); {take the square root to get calculate the average distance in pixels between the stars/measuring points}
  for x:=0 to w-1 do
  for y:=0 to h-1 do
  begin
    cols:=mean;
    sum_influence:=0;
    for i:=0 to nr-1 do {go through all points}
    begin
      x2:=hfd_values[0,i] div scaledown;
      y2:=hfd_values[1,i] div scaledown;
      distance:=sqrt(sqr(x2-x)+sqr(y2-y));
      influence:=factor/(factor+distance);
      sum_influence:=sum_influence+influence;
      cols:=cols+hfd_values[2,i]*influence;
    end;
    cols:=cols/sum_influence;
    if max_value<cols then max_value:=cols;
    if min_value>cols then min_value:=cols;
    img_hfd[ 0,x,y]:=cols;

  end;

  if naxis>1 then setlength(img_loaded,1,width2,height2);
  naxis3:=1;

  {introduce rounding to show layers}
  step_adjust:=((max_value-min_value)/60);

  {convert back}
  for fitsY:=0 to height2-1  do
    for fitsX:=0 to width2-1 do
      img_loaded[0,fitsX,fitsY]:=(1/step_adjust)*round(step_adjust*img_hfd[0,fitsX div scaledown,fitsY div scaledown]);


  img_hfd:=nil;{free memory}

  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}

  cblack:=min_value;
  cwhite:=max_value;
  mainwindow.minimum1.position:=round(min_value);
  mainwindow.maximum1.position:=round(max_value);
end;


procedure CCDinspector_analyse(detype: char);
var
 fitsX,fitsY,size, i, j,nhfd,retries,max_stars,fontsize,starX,starY  : integer;
 hfd1,star_fwhm,snr,flux,xc,yc,detection_level  : double;
 mean, min_value,max_value : single;
 hfd_values  : hfd_array;
 Fliphorizontal, Flipvertical: boolean;

 begin
  if fits_file=false then exit; {file loaded?}

  max_stars:=1000;

  SetLength(hfd_values,3,4000);{will contain x,y,hfd}
  setlength(img_temp,1,width2,height2);{set length of image array}

  get_background(0,img_loaded,true{ calculate histogram},true {calculate noise level},{var}cblack,star_level);{calculate background level from peek histogram}

  detection_level:=star_level; {level above background. Start with a high value}

  retries:=2; {try up to three times to get enough stars from the image}
  repeat
    nhfd:=0;{set counters at zero}

    for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1  do
        img_temp[0,fitsX,fitsY]:=-1;{mark as not surveyed}

    for fitsY:=0 to height2-1-1  do
    begin
      for fitsX:=0 to width2-1-1 do
      begin
        if (( img_temp[0,fitsX,fitsY]<=0){area not surveyed} and (img_loaded[0,fitsX,fitsY]- cblack>detection_level){star}) then {new star}
        begin
          HFD(img_loaded,fitsX,fitsY,14{box size}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if (hfd1>=1.3) {not a hotpixel} and (snr>30) and (hfd1<99) then
          begin

  //          if ((hfd1>7) and (hfd1<7.5)) then
//              beep;

            size:=round(5*hfd1);{for marking area. For inspector use factor 5 instead of 3}
            for j:=fitsY to fitsY+size do {mark the whole star area as surveyed}
              for i:=fitsX-size to fitsX+size do
                if ((j>=0) and (i>=0) and (j<height2) and (i<width2)) then {mark the area of the star square and prevent double detections}
                  img_temp[0,i,j]:=1;



            {store values}
            if ((img_loaded[0,round(xc),round(yc)]<65000) and
                  (img_loaded[0,round(xc-1),round(yc)]<65000) and
                  (img_loaded[0,round(xc+1),round(yc)]<65000) and
                  (img_loaded[0,round(xc),round(yc-1)]<65000) and
                  (img_loaded[0,round(xc),round(yc+1)]<65000) and

                  (img_loaded[0,round(xc-1),round(yc-1)]<65000) and
                  (img_loaded[0,round(xc-1),round(yc+1)]<65000) and
                  (img_loaded[0,round(xc+1),round(yc-1)]<65000) and
                  (img_loaded[0,round(xc+1),round(yc+1)]<65000)  ) then {not saturated}
            begin
              if nhfd>=length(hfd_values)-1 then
                  SetLength(hfd_values,3,nhfd+100);{adapt length if required}
              hfd_values[0,nhfd]:=round(xc);
              hfd_values[1,nhfd]:=round(yc);
              hfd_values[2,nhfd]:=round(hfd1*100);
              inc(nhfd);

            end;
          end;
        end;
      end;
    end;

    dec(retries);{try again with lower detection level}
    if retries =1 then begin if 15*noise_level[0]<star_level then detection_level:=15*noise_level[0] else retries:= 0; {skip retries 1} end; {lower  detection level}
    if retries =0 then begin if  5*noise_level[0]<star_level then detection_level:= 5*noise_level[0] else retries:=-1; {skip retries 0} end; {lowest detection level}

  until ((nhfd>=max_stars) or (retries<0));{reduce dection level till enough stars are found. Note that faint stars have less positional accuracy}

  img_temp:=nil;{free mem}


  if nhfd<10 then
   begin
     memo2_message('Abort, only '+inttostr(nhfd)+' usefull stars!');
     exit;
   end;

  if detype<>'A' then
      filter_hfd(mean, min_value,max_value ,nhfd, hfd_values); {apply the median value for each three grouped stars}


  if detype='V' then voronoi_plot(min_value,max_value,nhfd,hfd_values)
  else
  if detype='2' then contour_plot(mean,nhfd,hfd_values);

  Flipvertical:=mainwindow.flip_vertical1.Checked;
  Fliphorizontal:=mainwindow.Flip_horizontal1.Checked;
  size:=max(1,height2 div 1000);{font size, 1 is 9x5 pixels}

  for i:=0 to nhfd-1 do {plot rectangles later since the routine can be run three times to find the correct detection_level and overlapping rectangle could occur}
   begin
     if Fliphorizontal     then starX:=width2-hfd_values[0,i]   else starX:=hfd_values[0,i];
     if Flipvertical       then starY:=height2-hfd_values[1,i] else starY:=hfd_values[1,i];
     annotation_to_array(floattostrf(hfd_values[2,i]/100 , ffgeneral, 2,1){text},true,round(img_loaded[0,starX,starY]+550){luminance},size,starX+6,starY,img_loaded);{string to image array as annotation, result is flicker free since the annotion is plotted as the rest of the image}
  end;

  hfd_values:=nil;

  plot_fits(mainwindow.image1,false,true);

end;


end.


