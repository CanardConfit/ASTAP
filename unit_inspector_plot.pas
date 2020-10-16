unit unit_inspector_plot;

{$mode delphi}

interface

uses
  Classes, SysUtils,math,astap_main, unit_stack;

type
  hfd_array   = array of array of integer;

procedure plot(nr:integer;hfd_values: hfd_array);
procedure CCDinspector_analyse;

implementation

procedure plot(nr:integer;hfd_values: hfd_array);
var
    i,size,fitsx,fitsY,x,y,x2,y2,nr2,w,h,scaledown,max_value,col : integer;
    img_hfd: image_array;
    zeros_left : boolean;
    variance,mean,diff   : single;
    hfd_values2: hfd_array;

begin
  {remove outliers}
  mean:=0;
  for i:=0 to nr-1 do
    mean:=mean+ hfd_values[ 2,i];
  mean:=mean/nr;
  variance:=0;
  for i:=0 to nr-1 do
    variance:=variance+sqr(mean-hfd_values[ 2,i]);
  variance:=variance/nr;

  setlength(hfd_values2,3,nr+1);
  nr2:=0;
  for i:=0 to nr-1 do
  begin
    diff:=mean-hfd_values[ 2,i];
    if (
    ((diff<0) and (sqr(mean-hfd_values[ 2,i])<variance*sqr(2.0))) {<sd*2.0}
    or
    ((diff>0) and (sqr(mean-hfd_values[ 2,i])<variance*sqr(0.5))) ){remove too small stars} then
    begin
      hfd_values2[0,nr2]:=hfd_values[0,i];
      hfd_values2[1,nr2]:=hfd_values[1,i];
      hfd_values2[2,nr2]:=hfd_values[2,i];
      inc(nr2);
    end;
  end;

  scaledown:=1+ width2 div 1000;
  w:=(width2 div scaledown)+1;
  h:=(height2 div scaledown)+1;

  setlength(img_hfd,1,w,h);{set length of image array}
  for fitsY:=0 to h-1  do
    for fitsX:=0 to w-1 do
      img_hfd[0,fitsX,fitsY]:=0;{clear array}

  size:=0;
  max_value:=0;
  repeat
    zeros_left:=false;
    for i:=0 to nr2-1 do
    begin
      col:=hfd_values2[2,i];
      if col>130 then {hfd>1.3}
      begin
        if max_value<col then max_value:=col;
        for x:=-size to size do
        for y:=-size to size do
        if round(sqrt(sqr(x)+sqr(y)))=size then
        begin
          x2:=hfd_values2[0,i] div scaledown + x;
          y2:=hfd_values2[1,i] div scaledown + y;
          if ((x2>=0) and (x2<w) and (y2>=0) and (y2<h)) then
            if  img_hfd[ 0,x2,y2]=0 then {not used yet}
            begin
              img_hfd[ 0,x2,y2]:=col;
              zeros_left:=true;
            end;
        end;
      end;
    end;
    inc(size);
  until ((zeros_left=false) or (size>h/5));

  hfd_values2:=nil;{free memory}

  if naxis>1 then setlength(img_loaded,1,width2,height2);
  naxis3:=1;
  for fitsY:=0 to height2-1  do
    for fitsX:=0 to width2-1 do
      img_loaded[0,fitsX,fitsY]:={img_loaded[0,fitsX,fitsY]}+img_hfd[0,fitsX div scaledown,fitsY div scaledown];

  cblack:=0;
  cwhite:=max_value;
  mainwindow.minimum1.position:=0;
  mainwindow.maximum1.position:=max_value;

  plot_fits(mainwindow.image1,false,true);
end;


procedure CCDinspector_analyse;
var
 fitsX,fitsY,size, i, j,nhfd,retries,max_stars  : integer;
 hfd1,star_fwhm,snr,flux,xc,yc,detection_level  : double;
 hfd_values  : hfd_array;

 begin
  if fits_file=false then exit; {file loaded?}

  max_stars:=500;

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
          if (hfd1>=0.8) {two pixels minimum} and (hfd1<99) then
          begin
            size:=round(3*hfd1);{for marking area}
            for j:=fitsY to fitsY+size do {mark the whole star area as surveyed}
              for i:=fitsX-size to fitsX+size do
                if ((j>=0) and (i>=0) and (j<height2) and (i<width2)) then {mark the area of the star square and prevent double detections}
                  img_temp[0,i,j]:=1;

            {store values}

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

    dec(retries);{try again with lower detection level}
    if retries =1 then begin if 15*noise_level[0]<star_level then detection_level:=15*noise_level[0] else retries:= 0; {skip retries 1} end; {lower  detection level}
    if retries =0 then begin if  5*noise_level[0]<star_level then detection_level:= 5*noise_level[0] else retries:=-1; {skip retries 0} end; {lowest detection level}

  until ((nhfd>=max_stars) or (retries<0));{reduce dection level till enough stars are found. Note that faint stars have less positional accuracy}

  img_temp:=nil;{free mem}
  plot(nhfd,hfd_values);
  hfd_values:=nil;
end;


end.


