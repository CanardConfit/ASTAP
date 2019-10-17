unit unit_inspector_plot;

{$mode delphi}

interface

uses
  Classes, SysUtils,astap_main, unit_stack;

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
 fitsX,fitsY,size, i, j,nhfd    : integer;
 hfd1,star_fwhm,snr,flux,xc,yc  : double;
 hfd_values  : hfd_array;

 begin
  if fits_file=false then exit; {file loaded?}

  nhfd:=0;{set counters at zero}
  SetLength(hfd_values,3,4000);{will contain x,y,hfd}

  get_background(0,img_loaded,true{ calculate histogram},true {calculate noise level},{var}cblack,star_level);{calculate background level from peek histogram}

  setlength(img_temp,1,width2,height2);{set length of image array}
  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1  do
      img_temp[0,fitsX,fitsY]:=-1;{mark as not surveyed}

  for fitsY:=0 to height2-1-1  do
  begin
    for fitsX:=0 to width2-1-1 do
    begin
      if (( img_temp[0,fitsX,fitsY]<=0){area not surveyed} and (img_loaded[0,fitsX,fitsY]- cblack>star_level{ 3.5*noise_level}){star}) then {new star}
      begin
        HFD(img_loaded,fitsX,fitsY, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
        if (hfd1>=0.8) {two pixels minimum} and (hfd1<99) then
        begin
          size:=round(3*hfd1);
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
  img_temp:=nil;{free mem}

  plot(nhfd,hfd_values);
  hfd_values:=nil;
end;


end.


