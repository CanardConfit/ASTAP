unit unit_inspector_plot;

{$mode delphi}

interface

uses
  Classes, SysUtils,math,astap_main, unit_stack, unit_annotation,graphics;

type
  hfd_array   = array of array of integer;

procedure CCDinspector_analyse(detype: char; aspect: boolean);

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
 {useful length is nr}
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

  cblack:=min_value-5;
  cwhite:=max_value+5;
  mainwindow.minimum1.position:=round(min_value-5);{+5, -5 for very flat fields}
  mainwindow.maximum1.position:=round(max_value+5);
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

  cblack:=min_value-5;
  cwhite:=max_value+5;
  mainwindow.minimum1.position:=round(min_value-5);{+5, -5 for very flat fields}
  mainwindow.maximum1.position:=round(max_value+5);
end;


procedure measure_star_aspect( img: image_array;x1,y1: double; rs:integer;  out aspect : double); {measures the aspect of a single star}
var
  i, j,pixel_counter,a,b,k,inside_counter,outside_counter,missing_inside : integer;
  val, average_distance,average_distance_circle,r_circle,meas,ecc,r,
  ns,ew,nw_se,ne_sw,themax,themin,max_value : double;
  function value_subpixel(x1,y1:double):double; {calculate image pixel value on subpixel level}
  var
    x_trunc,y_trunc: integer;
    x_frac,y_frac  : double;
  begin
    x_trunc:=trunc(x1);
    y_trunc:=trunc(y1);
    if ((x_trunc<=0) or (x_trunc>=(width2-2)) or (y_trunc<=0) or (y_trunc>=(height2-2))) then begin result:=0; exit;end;
    x_frac :=frac(x1);
    y_frac :=frac(y1);
    try
      result:=         (img[0,x_trunc  ,y_trunc  ]) * (1-x_frac)*(1-y_frac);{pixel left top, 1}
      result:=result + (img[0,x_trunc+1,y_trunc  ]) * (  x_frac)*(1-y_frac);{pixel right top, 2}
      result:=result + (img[0,x_trunc  ,y_trunc+1]) * (1-x_frac)*(  y_frac);{pixel left bottom, 3}
      result:=result + (img[0,x_trunc+1,y_trunc+1]) * (  x_frac)*(  y_frac);{pixel right bottom, 4}
    except
    end;
  end;

begin
  aspect:=-99;{failure indication}
  pixel_counter:=0;
  inside_counter:=0;
  outside_counter:=0;
  ns:=0;{north south}
  ew:=0;
  nw_se:=0; {north west or south east}
  ne_sw:=0;
  if ((x1-rs>=0) and (x1+rs<=width2) and (y1-rs>0) and (y1+rs<height2))  then {measurement within screen}
  begin

    max_value:=value_subpixel(x1,y1)- star_bg {from procedure hfd};
    for i:=-rs to rs do
    for j:=-rs to rs do
    begin
      val:=value_subpixel(x1+i,y1+j)- star_bg {from procedure hfd};


      if val>4*sd_bg {from procedure hfd} then
      begin
        val:=sqrt(val);{reduce contrast}
        r:=sqrt(sqr(i)+sqr(j));{distance}
        if abs(j)>=abs(i) then  ns:=ns+val*r;
        if abs(j)<=abs(i) then   ew:=ew+val*r;
        if j*i>=0 then  nw_se:=nw_se+val*r;
        if j*i<=0 then  ne_sw:=ne_sw+val*r;

        inc(pixel_counter); {how many pixels are illuminated}
      end;
    end;
    if pixel_counter<4 then
    begin
      exit; {not enough pixels}
    end;
    themax:=max(max(ns,ew),max(nw_se,ne_sw));
    themin:=min(min(ns,ew),min(nw_se,ne_sw));

    aspect:=themax/(themin+0.00001);
  end;
end;


procedure CCDinspector_analyse(detype: char; aspect: boolean);
var
 fitsX,fitsY,size,radius, i, j,nhfd,retries,max_stars,starX,starY,font_luminance,n,m,xci,yci,sqr_radius   : integer;
 hfd1,star_fwhm,snr,flux,xc,yc,detection_level,med                                                        : double;
 mean, min_value,max_value : single;
 hfd_values  : hfd_array;
 hfds        : array of double;
 Fliphorizontal, Flipvertical: boolean;
 mess: string;
 img_sa : image_array;

begin
  if fits_file=false then exit; {file loaded?}

  max_stars:=1000;

  SetLength(hfd_values,3,4000);{will contain x,y,hfd}
  setlength(img_sa,1,width2,height2);{set length of image array}

  get_background(0,img_loaded,false{ calculate histogram},true {calculate noise level},{var}cblack,star_level);{calculate background level from peek histogram}

  detection_level:=max(3.5*noise_level[0],star_level); {level above background. Start with a high value}

  retries:=2; {try up to three times to get enough stars from the image}
  repeat
    nhfd:=0;{set counters at zero}

    for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1  do
        img_sa[0,fitsX,fitsY]:=-1;{mark as star free area}

    for fitsY:=0 to height2-1-1  do
    begin
      for fitsX:=0 to width2-1-1 do
      begin
        if (( img_sa[0,fitsX,fitsY]<=0){area not occupied by a star} and (img_loaded[0,fitsX,fitsY]- cblack>detection_level){star}) then {new star}
        begin
          HFD(img_loaded,fitsX,fitsY,14{annulus radius},99 {flux aperture restriction}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if (hfd1>=1.3) {not a hotpixel} and (snr>30) and (hfd1<99) then
          begin


            radius:=round(5.0*hfd1);{for marking area. For inspector use factor 5 instead of 3}
            sqr_radius:=sqr(radius);
            xci:=round(xc);{star center as integer}
            yci:=round(yc);
            for n:=-radius to +radius do {mark the whole circular star area as occupied to prevent double detection's}
              for m:=-radius to +radius do
              begin
                j:=n+yci;
                i:=m+xci;
                if ((j>=0) and (i>=0) and (j<height2) and (i<width2) and (sqr(m)+sqr(n)<=sqr_radius)) then
                  img_sa[0,i,j]:=1;
              end;

            if aspect then  measure_star_aspect(img_loaded,xc,yc,round(hfd1*1.5),{out} hfd1);{store the star aspect in hfd1}

            {store values}
            if  ( ((img_loaded[0,round(xc),round(yc)]<datamax_org-1) and
                  (img_loaded[0,round(xc-1),round(yc)]<datamax_org-1) and
                  (img_loaded[0,round(xc+1),round(yc)]<datamax_org-1) and
                  (img_loaded[0,round(xc),round(yc-1)]<datamax_org-1) and
                  (img_loaded[0,round(xc),round(yc+1)]<datamax_org-1) and

                  (img_loaded[0,round(xc-1),round(yc-1)]<datamax_org-1) and
                  (img_loaded[0,round(xc-1),round(yc+1)]<datamax_org-1) and
                  (img_loaded[0,round(xc+1),round(yc-1)]<datamax_org-1) and
                  (img_loaded[0,round(xc+1),round(yc+1)]<datamax_org-1)){not saturated}
                  or ((aspect) and (hfd1>0)) )
                  then
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

    dec(retries);{In principle not required. Try again with lower detection level}
    if detection_level<=7*noise_level[0] then retries:= -1 {stop}
    else
    detection_level:=max(6.999*noise_level[0],min(30*noise_level[0],detection_level*6.999/30)); {very high -> 30 -> 7 -> stop.  Or  60 -> 14 -> 7.0. Or for very short exposures 3.5 -> stop}

  until ((nhfd>=max_stars) or (retries<0));{reduce dection level till enough stars are found. Note that faint stars have less positional accuracy}

  img_sa:=nil;{free mem}


  if nhfd<10 then
   begin
     memo2_message('Abort, only '+inttostr(nhfd)+' useful stars!');
     exit;
   end;

  if detype<>'A' then
  begin
     filter_hfd(mean, min_value,max_value ,nhfd, hfd_values); {apply the median value for each three grouped stars}
     font_luminance:=100;
  end
  else
  font_luminance:=500;



  if detype='V' then voronoi_plot(min_value,max_value,nhfd,hfd_values)
  else
  if detype='2' then contour_plot(mean,nhfd,hfd_values);

  Flipvertical:=mainwindow.flip_vertical1.Checked;
  Fliphorizontal:=mainwindow.Flip_horizontal1.Checked;
  size:=max(1,height2 div 1000);{font size, 1 is 9x5 pixels}


  setlength(hfds,nhfd);

  for i:=0 to nhfd-1 do {plot rectangles later since the routine can be run three times to find the correct detection_level and overlapping rectangle could occur}
   begin
     if Fliphorizontal     then starX:=width2-hfd_values[0,i]   else starX:=hfd_values[0,i];
     if Flipvertical       then starY:=height2-hfd_values[1,i] else starY:=hfd_values[1,i];
     annotation_to_array(floattostrf(hfd_values[2,i]/100 , ffgeneral, 2,1){text},true{transparent},round(img_loaded[0,starX,starY]+font_luminance){luminance},size,starX+round(hfd_values[2,i]/30),starY,img_loaded);{string to image array as annotation. Text should be far enough of stars since the text influences the HFD measurment.}

     hfds[i]:=hfd_values[2,i];
  end;

  quickSort(hfds,0,nhfd-1);

  med:=hfds[round((nhfd-1)*0.9)];

  hfds:=nil;{free memory}

  if aspect then
     mess:='10% of the aspect ratio measurements is worse or equal then '
  else
     mess:='10% of the HFD measurements is worse or equal then ';
  mess:=mess+floattostrf(med/100 , ffgeneral, 2,1);
  memo2_message(mess);
  annotation_to_array(mess,true {transparent},65535,size*2 {size},5,10+size*2*9,img_loaded); {report median value}
  hfd_values:=nil;

  plot_fits(mainwindow.image1,false,true);{plot image included text in pixel data}

end;


end.


