unit unit_inspector_plot;

{Copyright (C) 2018, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. }

{$mode Delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLintf, StdCtrls,
  Buttons, math, astap_main, unit_stack, unit_annotation,
  clipbrd; {for copy to clipboard}

type

  { Tform_inspection1 }

  Tform_inspection1 = class(TForm)
    bayer_label1: TLabel;
    to_clipboard1: TCheckBox;
    normalise_mode1: TComboBox;
    show_distortion1: TBitBtn;
    aberration_inspector1: TBitBtn;
    tilt1: TBitBtn;
    background_values1: TBitBtn;
    extra_stars1: TCheckBox;
    contour1: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    help_uncheck_outliers1: TLabel;
    hfd_button1: TButton;
    rectangle1: TRadioButton;
    triangle1: TRadioButton;
    roundness_button1: TButton;
    measuring_angle1: TComboBox;
    undo_button1: TBitBtn;
    values1: TCheckBox;
    vectors1: TCheckBox;
    voronoi1: TCheckBox;
    procedure aberration_inspector1Click(Sender: TObject);
    procedure background_values1Click(Sender: TObject);
    procedure close_button1Click(Sender: TObject);
    procedure contour1Change(Sender: TObject);
    procedure extra_stars1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure help_uncheck_outliers1Click(Sender: TObject);
    procedure hfd_button1Click(Sender: TObject);
    procedure measuring_angle1Change(Sender: TObject);
    procedure normalise_mode1Change(Sender: TObject);
    procedure show_distortion1Click(Sender: TObject);
    procedure tilt1Click(Sender: TObject);
    procedure triangle1Change(Sender: TObject);
    procedure undo_button1Click(Sender: TObject);
    procedure values1Change(Sender: TObject);
    procedure vectors1Change(Sender: TObject);
    procedure voronoi1Change(Sender: TObject);
  private

  public

  end;

var
  form_inspection1: Tform_inspection1;


type
  hfd_array   = array of array of integer;

var
  contour_check: boolean=false;
  voronoi_check: boolean=false;
  values_check: boolean=true;
  vectors_check: boolean=true;
  bayer_image  : boolean=false;
  extra_stars  : boolean=false;
  three_corners: boolean=false;
  measuring_angle : string='0';
  normalise_mode: integer=0; {auto}
  insp_left: integer=100;
  insp_top: integer=100;


procedure CCDinspector(snr_min: double; triangle : boolean; measuring_angle: double);

implementation
{$R *.lfm}

var
   executed : integer; {1 image changed (refresh required), 2 array changed(restore required)}


function fnmodulo2(x,range: double):double;   {specifiy range=2*pi fore -pi..pi or range=360 for -180.. 180}
begin
  result:=x;
  while result<-range/2 do result:=result+range;
  while result>+range/2 do result:=result-range;
end;

procedure flip_xy(fliph,flipv :boolean; var x,y : integer);{flip if required for plotting. From array to image1 coordinates}
begin
 if Fliph       then x:=head.width-x;
 if Flipv=false then y:=head.height-y;
end;



procedure CCDinspector(snr_min: double; triangle : boolean; measuring_angle: double);
var
 fitsX,fitsY,size,radius, i,j,starX,starY, retries,max_stars,x_centered,y_centered,starX2,starY2,
 nhfd,nhfd_center,nhfd_outer_ring,nhfd_top_left,nhfd_top_right,nhfd_bottom_left,nhfd_bottom_right,
 x1,x2,x3,x4,y1,y2,y3,y4,fontsize,text_height,text_width,n,m,xci,yci,sqr_radius,left_margin                         : integer;

 hfd1,star_fwhm,snr,flux,xc,yc, median_worst,median_best,scale_factor, detection_level,
 hfd_median, median_center, median_outer_ring, median_bottom_left, median_bottom_right,
 median_top_left, median_top_right,hfd_min,tilt_value, aspect,theangle,theradius,screw1,screw2,screw3                       : double;
 hfdlist, hfdlist_top_left,hfdlist_top_right,hfdlist_bottom_left,hfdlist_bottom_right,  hfdlist_center,hfdlist_outer_ring  : array of double;
 starlistXY    :array of array of integer;
 mess1,mess2,hfd_value,hfd_arcsec      : string;
 Save_Cursor:TCursor;
 Fliph, Flipv,restore_req  : boolean;
 img_bk,img_sa                             : image_array;

var {################# initialised variables #########################}
 len : integer=1000;
begin
  if fits_file=false then exit; {file loaded?}
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  restore_req:=false;
  if head.naxis3>1 then {colour image}
  begin
    img_bk:=img_loaded; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
    setlength(img_bk,head.naxis3,head.width,head.height);{force a duplication}
    convert_mono(img_loaded);
    get_hist(0,img_loaded);{get histogram of img_loaded and his_total. Required to get correct background value}
    restore_req:=true;
  end
  else
  if bayer_image then {raw Bayer image}
  begin
    img_bk:=img_loaded; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
    setlength(img_bk,head.naxis3,head.width,head.height);{force a duplication}
    normalize_OSC_flat(img_loaded);
    get_hist(0,img_loaded);{get histogram of img_loaded and his_total. Required to get correct background value}
    restore_req:=true;
  end;

  max_stars:=500;

  with mainwindow do
  begin
    Flipv:=mainwindow.flip_vertical1.Checked;
    Fliph:=mainwindow.Flip_horizontal1.Checked;


    image1.Canvas.Pen.Mode := pmMerge;
    image1.Canvas.brush.Style:=bsClear;
    image1.Canvas.font.color:=clyellow;
    image1.Canvas.Pen.Color := clred;
    image1.Canvas.Pen.width := round(1+head.height/image1.height);{thickness lines}
    fontsize:=round(max(10,8*head.height/image1.height));{adapt font to image dimensions}
    image1.Canvas.font.size:=fontsize;

    hfd_median:=0;
    median_center:=0;
    median_outer_ring:=0;
    median_bottom_left:=0;
    median_bottom_right:=0;
    median_top_left:=0;
    median_top_right:=0;


    SetLength(hfdlist,len*4);{set array length on a starting value}
    SetLength(starlistXY,2,len*4);{x,y positions}

    SetLength(hfdlist_center,len);
    SetLength(hfdlist_outer_ring,len*2);

    SetLength(hfdlist_top_left,len);
    SetLength(hfdlist_top_right,len);
    SetLength(hfdlist_bottom_left,len);
    SetLength(hfdlist_bottom_right,len);
    setlength(img_sa,1,head.width,head.height);{set length of image array}

    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}
    get_background(0,img_loaded,{cblack=0} false{histogram is already available},true {calculate noise level},{var}cblack,star_level);{calculate background level from peek histogram}

    detection_level:=max(3.5*noise_level[0],star_level); {level above background. Start with a high value}
    retries:=2; {try up to three times to get enough stars from the image}
    repeat
      nhfd:=0;{set counters at zero}
      nhfd_top_left:=0;
      nhfd_top_right:=0;
      nhfd_bottom_left:=0;
      nhfd_bottom_right:=0;
      nhfd_center:=0;
      nhfd_outer_ring:=0;


      for fitsY:=0 to head.height-1 do
        for fitsX:=0 to head.width-1  do
          img_sa[0,fitsX,fitsY]:=-1;{mark as star free area}

      for fitsY:=0 to head.height-1-1  do
      begin
        for fitsX:=0 to head.width-1-1 do
        begin
          if (( img_sa[0,fitsX,fitsY]<=0){area not occupied by a star}  and (img_loaded[0,fitsX,fitsY]- cblack>detection_level){star}) then {new star}
          begin
            HFD(img_loaded,fitsX,fitsY,14{annulus radius},99 {flux aperture restriction}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}

            if ((hfd1<=30) and (snr>snr_min {30}) and (hfd1>hfd_min) ) then
            begin

              radius:=round(3.0*hfd1);{for marking star area. A value between 2.5*hfd and 3.5*hfd gives same performance. Note in practice a star PSF has larger wings then predicted by a Gaussian function}
              sqr_radius:=sqr(radius);
              xci:=round(xc);{star center as integer}
              yci:=round(yc);

              for n:=-radius to +radius do {mark the whole circular star area as occupied to prevent double detection's}
                for m:=-radius to +radius do
                begin
                  j:=n+yci;
                  i:=m+xci;
                  if ((j>=0) and (i>=0) and (j<head.height) and (i<head.width) and (sqr(m)+sqr(n)<=sqr_radius)) then
                    img_sa[0,i,j]:=1;
                end;

              if ((img_loaded[0,round(xc),round(yc)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc-1),round(yc)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc+1),round(yc)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc),round(yc-1)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc),round(yc+1)]<head.datamax_org-1) and

                  (img_loaded[0,round(xc-1),round(yc-1)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc-1),round(yc+1)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc+1),round(yc-1)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc+1),round(yc+1)]<head.datamax_org-1)  ) then {not saturated}
              begin

                starX:=round(xc);
                starY:=round(yc);
    //            if Fliphorizontal     then starX:=round(head.width-xc)   else starX:=round(xc);
    //            if Flipvertical=false then  starY:=round(head.height-yc) else starY:=round(yc);

    //            mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
    //            mainwindow.image1.Canvas.textout(starX+size,starY+size,floattostrf(hfd1, ffgeneral, 2,1));{add hfd as text}

                {store values}
                hfdlist[nhfd]:=hfd1;

                starlistXY[0,nhfd]:=starX; {store star position in image coordinates, not FITS coordinates}
                starlistXY[1,nhfd]:=starY;
                inc(nhfd); if nhfd>=length(hfdlist) then
                begin
                  SetLength(hfdlist,nhfd+100); {adapt length if required and store hfd value}
                  SetLength(starlistXY,2,nhfd+100);{adapt array size if required}
                end;

              end;
            end;
          end;
        end;
      end;

      dec(retries);{prepare for trying with lower detection level}
      if detection_level<=7*noise_level[0] then retries:= -1 {stop}
      else
      detection_level:=max(6.999*noise_level[0],min(30*noise_level[0],detection_level*6.999/30)); {very high -> 30 -> 7 -> stop.  Or  60 -> 14 -> 7.0. Or for very short exposures 3.5 -> stop}

    until ((nhfd>=max_stars) or (retries<0));{reduce detection level till enough stars are found. Note that faint stars have less positional accuracy}

    if restore_req then {raw Bayer image or colour image}
    begin
      memo2_message('Restoring image');
      img_loaded:=nil;
      img_loaded:=img_bk; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
      get_hist(0,img_loaded);{get histogram of img_loaded and his_total}
    end;

    if triangle then
    begin
      screw1:=fnmodulo2(measuring_angle,360); {make -180 to 180 range}
      screw2:=fnmodulo2(measuring_angle+120,360);
      screw3:=fnmodulo2(measuring_angle-120,360);
    end;


    if nhfd>0 then
    begin
      for i:=0 to nhfd-1 do {plot rectangles later since the routine can be run three times to find the correct detection_level and overlapping rectangle could occur}
      begin
        hfd1:=hfdlist[i];
        size:=round(5*hfd1);

        starX:=starlistXY[0,i];
        starY:=starlistXY[1,i];

        starX2:=starX;
        starY2:=starY;
        flip_xy(fliph,flipv,starX2,starY2); {from array to image coordinates}

        mainwindow.image1.Canvas.Rectangle(starX2-size,starY2-size, starX2+size, starY2+size);{indicate hfd with rectangle}
        mainwindow.image1.Canvas.textout(starX2+size,starY2+size,floattostrf(hfd1, ffgeneral, 2,1));{add hfd as text}

        if  sqr(starX - (head.width div 2) )+sqr(starY - (head.height div 2))<sqr(0.25)*(sqr(head.width div 2)+sqr(head.height div 2))  then begin hfdlist_center[nhfd_center]:=hfd1; inc(nhfd_center); if nhfd_center>=length( hfdlist_center) then  SetLength( hfdlist_center,nhfd_center+100);end {store center(<25% diameter) HFD values}
        else
        begin
          if  sqr(starX - (head.width div 2) )+sqr(starY - (head.height div 2))>sqr(0.75)*(sqr(head.width div 2)+sqr(head.height div 2)) then begin hfdlist_outer_ring[nhfd_outer_ring]:=hfd1; inc(nhfd_outer_ring); if nhfd_outer_ring>=length(hfdlist_outer_ring) then  SetLength(hfdlist_outer_ring,nhfd_outer_ring+100); end;{store out ring (>75% diameter) HFD values}
          if triangle=false then
          begin
            if ( (starX<(head.width div 2)) and (starY<(head.height div 2)) ) then begin  hfdlist_bottom_left [nhfd_bottom_left] :=hfd1; inc(nhfd_bottom_left); if nhfd_bottom_left>=length(hfdlist_bottom_left)   then SetLength(hfdlist_bottom_left,nhfd_bottom_left+100);  end;{store corner HFD values}
            if ( (starX>(head.width div 2)) and (starY<(head.height div 2)) ) then begin  hfdlist_bottom_right[nhfd_bottom_right]:=hfd1; inc(nhfd_bottom_right);if nhfd_bottom_right>=length(hfdlist_bottom_right) then SetLength(hfdlist_bottom_right,nhfd_bottom_right+100);end;
            if ( (starX>(head.width div 2)) and (starY>(head.height div 2)) ) then begin  hfdlist_top_right[nhfd_top_right]:=hfd1;       inc(nhfd_top_right);   if nhfd_top_right>=length(hfdlist_top_right)       then SetLength(hfdlist_top_right,nhfd_top_right+100);      end;
            if ( (starX<(head.width div 2)) and (starY>(head.height div 2)) ) then begin  hfdlist_top_left[nhfd_top_left]:=hfd1;         inc(nhfd_top_left);    if nhfd_top_left>=length(hfdlist_top_left)         then SetLength(hfdlist_top_left,nhfd_top_left+100);        end;
          end
          else
          begin
            x_centered:=starX- (head.width div 2); {array coordinates}
            y_centered:=starY- (head.height div 2);
            theangle:=arctan2(y_centered,x_centered)*180/pi;{angle in array}
            theradius:=sqrt(sqr(x_centered)+sqr(x_centered));


            if ( (abs(fnmodulo2(theangle-screw1,360))<30) and (theradius<head.height div 2) ) then begin  hfdlist_bottom_left [nhfd_bottom_left] :=hfd1; inc(nhfd_bottom_left); if nhfd_bottom_left>=length(hfdlist_bottom_left)   then SetLength(hfdlist_bottom_left,nhfd_bottom_left+100);  end;{store corner HFD values}
            if ( (abs(fnmodulo2(theangle-screw2,360))<30) and (theradius<head.height div 2) ) then begin  hfdlist_bottom_right[nhfd_bottom_right]:=hfd1; inc(nhfd_bottom_right);if nhfd_bottom_right>=length(hfdlist_bottom_right) then SetLength(hfdlist_bottom_right,nhfd_bottom_right+100);end;
            if ( (abs(fnmodulo2(theangle-screw3,360))<30) and (theradius<head.height div 2) ) then begin  hfdlist_top_right[nhfd_top_right]:=hfd1;       inc(nhfd_top_right);   if nhfd_top_right>=length(hfdlist_top_right)       then SetLength(hfdlist_top_right,nhfd_top_right+100);      end;
          end

        end;

      end;

      if ((nhfd_center>0) and (nhfd_outer_ring>0)) then  {enough information for curvature calculation}
      begin
        median_center:=SMedian(hfdlist_center,nhfd_center);
        median_outer_ring:=SMedian(hfdlist_outer_ring,nhfd_outer_ring);
        mess1:='  Off-axis aberration[HFD]='+floattostrF(median_outer_ring-(median_center),ffFixed,0,2);{}
      end
      else
      mess1:='';

      hfd_median:=SMedian(hfdList,nhfd {use length});


      if ((triangle=true) and (nhfd_top_right>0)  and (nhfd_bottom_left>0) and (nhfd_bottom_right>0)) then  {enough information for tilt calculation}
      begin
        median_top_right:=SMedian(hfdList_top_right,nhfd_top_right);
        median_bottom_left:=SMedian(hfdList_bottom_left,nhfd_bottom_left);
        median_bottom_right:=SMedian(hfdList_bottom_right,nhfd_bottom_right);
        median_best:=min(median_top_right,min(median_bottom_left,median_bottom_right));{find best corner}
        median_worst:=max(median_top_right,max(median_bottom_left,median_bottom_right));{find worst corner}

        scale_factor:=head.width*0.35/median_worst;
        x1:=round(-median_bottom_left*scale_factor*sin(screw1*pi/180)+head.width/2);
        y1:=round(-median_bottom_left*scale_factor*cos(screw1*pi/180)+head.height/2);{calculate coordinates}


        x2:=round(-median_bottom_right*scale_factor*sin(screw2*pi/180)+head.width/2);
        y2:=round(-median_bottom_right*scale_factor*cos(screw2*pi/180)+head.height/2);

        x3:=round(-median_top_right*scale_factor*sin(screw3*pi/180)+head.width/2);
        y3:=round(-median_top_right*scale_factor*cos(screw3*pi/180)+head.height/2);

        flip_xy(fliph,flipv,x1,y1); {from array to image coordinates}
        flip_xy(fliph,flipv,x2,y2);
        flip_xy(fliph,flipv,x3,y3);

        image1.Canvas.Pen.width :=image1.Canvas.Pen.width*2;{thickness lines}

        image1.Canvas.pen.color:=clyellow;

        image1.Canvas.moveto(x1,y1);{draw triangle}
        image1.Canvas.lineto(x2,y2);{draw triangle}
        image1.Canvas.lineto(x3,y3);{draw triangle}
        image1.Canvas.lineto(x1,y1);{draw triangle}

        image1.Canvas.lineto(head.width div 2,head.height div 2);{draw diagonal}
        image1.Canvas.lineto(x2,y2);{draw diagonal}
        image1.Canvas.lineto(head.width div 2,head.height div 2);{draw diagonal}
        image1.Canvas.lineto(x3,y3);{draw diagonal}

        tilt_value:=100*(median_worst-median_best)/hfd_median;
        mess2:='  Tilt[HFD]='+floattostrF(median_worst-median_best,ffFixed,0,2)+' ('+floattostrF(tilt_value,ffFixed,0,0)+'%';{estimate tilt value}
        if tilt_value<5 then mess2:=mess2+' none)'
        else
        if tilt_value<10 then mess2:=mess2+' almost none)'
        else
        if tilt_value<15 then mess2:=mess2+' mild)'
        else
        if tilt_value<20 then mess2:=mess2+' moderate)'
        else
        if tilt_value<30 then mess2:=mess2+' severe)'
        else
        mess2:=mess2+' extreme)';


        fontsize:=fontsize*4;
        image1.Canvas.font.size:=fontsize;
        image1.Canvas.textout(x3,y3,floattostrF(median_top_right,ffFixed,0,2));
        image1.Canvas.textout(x1,y1,floattostrF(median_bottom_left,ffFixed,0,2));
        image1.Canvas.textout(x2,y2,floattostrF(median_bottom_right,ffFixed,0,2));
        image1.Canvas.textout(head.width div 2,head.height div 2,floattostrF(median_center,ffFixed,0,2));
      end
      else
      if ((triangle=false) and (nhfd_top_left>0) and (nhfd_top_right>0) and (nhfd_bottom_left>0) and (nhfd_bottom_right>0)) then  {enough information for tilt calculation}
      begin
        median_top_left:=SMedian(hfdList_top_left,nhfd_top_left);
        median_top_right:=SMedian(hfdList_top_right,nhfd_top_right);
        median_bottom_left:=SMedian(hfdList_bottom_left,nhfd_bottom_left);
        median_bottom_right:=SMedian(hfdList_bottom_right,nhfd_bottom_right);
        median_best:=min(min(median_top_left, median_top_right),min(median_bottom_left,median_bottom_right));{find best corner}
        median_worst:=max(max(median_top_left, median_top_right),max(median_bottom_left,median_bottom_right));{find worst corner}

        scale_factor:=head.width*0.25/median_worst;
        x1:=round(-median_bottom_left*scale_factor+head.width/2);y1:=round(-median_bottom_left*scale_factor+head.height/2);{calculate coordinates counter clockwise}
        x2:=round(+median_bottom_right*scale_factor+head.width/2);y2:=round(-median_bottom_right*scale_factor+head.height/2);
        x3:=round(+median_top_right*scale_factor+head.width/2);y3:=round(+median_top_right*scale_factor+head.height/2);
        x4:=round(-median_top_left*scale_factor+head.width/2);y4:=round(+median_top_left*scale_factor+head.height/2);

        flip_xy(fliph,flipv,x1,y1); {from array to image coordinates}
        flip_xy(fliph,flipv,x2,y2);
        flip_xy(fliph,flipv,x3,y3);
        flip_xy(fliph,flipv,x4,y4);


        image1.Canvas.Pen.width :=image1.Canvas.Pen.width*2;{thickness lines}

        image1.Canvas.pen.color:=clyellow;

        image1.Canvas.moveto(x1,y1);{draw trapezium}
        image1.Canvas.lineto(x2,y2);{draw trapezium}
        image1.Canvas.lineto(x3,y3);{draw trapezium}
        image1.Canvas.lineto(x4,y4);{draw trapezium}
        image1.Canvas.lineto(x1,y1);{draw trapezium}

        image1.Canvas.lineto(head.width div 2,head.height div 2);{draw diagonal}
        image1.Canvas.lineto(x2,y2);{draw diagonal}
        image1.Canvas.lineto(head.width div 2,head.height div 2);{draw diagonal}
        image1.Canvas.lineto(x3,y3);{draw diagonal}
        image1.Canvas.lineto(head.width div 2,head.height div 2);{draw diagonal}
        image1.Canvas.lineto(x4,y4);{draw diagonal}

        tilt_value:=100*(median_worst-median_best)/hfd_median;
        mess2:='  Tilt[HFD]='+floattostrF(median_worst-median_best,ffFixed,0,2)+' ('+floattostrF(tilt_value,ffFixed,0,0)+'%';{estimate tilt value}
        if tilt_value<5 then mess2:=mess2+' none)'
        else
        if tilt_value<10 then mess2:=mess2+' almost none)'
        else
        if tilt_value<15 then mess2:=mess2+' mild)'
        else
        if tilt_value<20 then mess2:=mess2+' moderate)'
        else
        if tilt_value<30 then mess2:=mess2+' severe)'
        else
        mess2:=mess2+' extreme)';

        fontsize:=fontsize*4;
        image1.Canvas.font.size:=fontsize;
        image1.Canvas.textout(x4,y4,floattostrF(median_top_left,ffFixed,0,2));
        image1.Canvas.textout(x3,y3,floattostrF(median_top_right,ffFixed,0,2));
        image1.Canvas.textout(x1,y1,floattostrF(median_bottom_left,ffFixed,0,2));
        image1.Canvas.textout(x2,y2,floattostrF(median_bottom_right,ffFixed,0,2));
        image1.Canvas.textout(head.width div 2,head.height div 2,floattostrF(median_center,ffFixed,0,2));
      end
      else
      begin
        mess2:='';
      end;

      str(hfd_median:0:1,hfd_value);
      if head.cdelt2<>0 then begin str(hfd_median*abs(head.cdelt2)*3600:0:1,hfd_arcsec); hfd_arcsec:=' ('+hfd_arcsec+'")'; end else hfd_arcsec:='';
      mess2:='Median HFD='+hfd_value+hfd_arcsec+ mess2+'  Stars='+ inttostr(nhfd)+mess1 ;

      text_width:=mainwindow.image1.Canvas.textwidth(mess2);{Calculate textwidth. This also works for 4k with "make everything bigger"}
      fontsize:=trunc(fontsize*(head.width*0.9)/text_width);{use 90% of width}
      image1.Canvas.font.size:=fontsize;
      image1.Canvas.font.color:=clwhite;
      text_height:=mainwindow.image1.Canvas.textheight('T');{the correct text height, also for 4k with "make everything bigger"}

      left_margin:=min(head.width div 20,round(fontsize*2));{twice font size but not more then 5% of width. Required for small images}
      image1.Canvas.textout(left_margin,head.height-text_height,mess2);{median HFD and tilt indication}

      memo2_message(mess2);{for stacking live}
    end
    else
      image1.Canvas.textout(round(fontsize*2),head.height- round(fontsize*4),'No stars detected');
  end;{with mainwindow}

  hfdlist:=nil;{release memory}

  hfdlist_center:=nil;
  hfdlist_outer_ring:=nil;

  hfdlist_top_left:=nil;
  hfdlist_top_right:=nil;
  hfdlist_bottom_left:=nil;
  hfdlist_bottom_right:=nil;

  starlistXY:=nil;

  img_sa:=nil;{free mem}

  Screen.Cursor:= Save_Cursor;
end;


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
    i,j,size,fitsx,fitsY,col,x,y,x2,y2,w,h,scaledown:  integer;
    img_hfd: image_array;
    zeros_left : boolean;

begin
  scaledown:=1+ head.width div 1000;
  w:=(head.width div scaledown)+1;
  h:=(head.height div scaledown)+1;

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

  if head.naxis>1 then setlength(img_loaded,1,head.width,head.height);
  head.naxis3:=1;
  for fitsY:=0 to head.height-1  do
    for fitsX:=0 to head.width-1 do
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
  scaledown:=1+ head.width div 1000;
  w:=(head.width div scaledown)+1;
  h:=(head.height div scaledown)+1;

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

  if head.naxis>1 then setlength(img_loaded,1,head.width,head.height);
  head.naxis3:=1;

  {introduce rounding to show layers}
  step_adjust:=((max_value-min_value)/60);

  {convert back}
  for fitsY:=0 to head.height-1  do
    for fitsX:=0 to head.width-1 do
      img_loaded[0,fitsX,fitsY]:=(1/step_adjust)*round(step_adjust*img_hfd[0,fitsX div scaledown,fitsY div scaledown]);


  img_hfd:=nil;{free memory}

  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}

  cblack:=min_value-5;
  cwhite:=max_value+5;
  mainwindow.minimum1.position:=round(min_value-5);{+5, -5 for very flat fields}
  mainwindow.maximum1.position:=round(max_value+5);
end;


procedure measure_star_aspect(img: image_array;x1,y1: double; rs:integer;  out aspect : double; out orientation : integer); {measures the aspect of a single star}
var
  i, j,angle,pixel_counter,a,bk ,orientationMin, orientationMax : integer;
  val,r,themax,themin,g,delta_angle,val2,mean_angle,distance : double;
  data : array[-51..51,-51..51] of double;
  function value_subpixel(x1,y1:double):double; {calculate image pixel value on subpixel level}
  var
    x_trunc,y_trunc: integer;
    x_frac,y_frac  : double;
  begin
    x_trunc:=trunc(x1);
    y_trunc:=trunc(y1);
    if ((x_trunc<=0) or (x_trunc>=(head.width-2)) or (y_trunc<=0) or (y_trunc>=(head.height-2))) then begin result:=0; exit;end;
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
  aspect:=999;{failure indication}
  rs:=min(rs,51);

  pixel_counter:=0;
  if ((x1-rs>=0) and (x1+rs<=head.width) and (y1-rs>0) and (y1+rs<head.height))  then {measurement within screen}
  begin

    for i:=-rs to rs do
    for j:=-rs to rs do
    begin
      val:=value_subpixel(x1+i,y1+j)- star_bg {from procedure hfd};

      if val>7*sd_bg {from procedure hfd} then
      begin
        val:=sqrt(val);{reduce contrast}
        r:=sqrt(sqr(i)+sqr(j));{distance}
        data[i,j]:=val*(r);
        inc(pixel_counter); {how many pixels are illuminated}
      end
      else
      data[i,j]:=0;

    end;
    if pixel_counter<4 then
    begin
      exit; {not enough pixels}
    end;

    themax:=0;
    themin:=1E99;
    for angle:=0 to 179 do {rotate 180 degr}
    begin
      val2:=0;
      distance:=0;
      for i:=-rs to rs do
      for j:=-rs to rs do
      begin
        if data[i,j]>0 then
        begin
          g:=arctan2(j,i);
          delta_angle:=((angle*pi/180) - g);
          //split star with a line with "angle" and measure the sum (average) of distances to line. This distance will be smallest if the line splits the star in the length
          // Distance to split line is r*sin(delta_angle). r is already included in the data.
          distance:=distance+data[i,j]*abs(sin(delta_angle));{add to get sum of the distances}
          //  img_loaded[0,round(x1+i),round(y1+j)]:=50000;
        end;
      end;
      if distance>themax then
      begin
        themax:=distance;
        orientationMax:=angle;
      end;
      if distance<themin then
      begin
        themin:=distance;
        orientationMin:=angle;
      end;
    end;

    orientation:=orientationMin;

    aspect:=themax/(themin+0.00001);

    if aspect>5 then aspect:=999; {failure}
  //  memo2_message(#9+floattostr(aspect)+#9+ inttostr(round(orientationMax))+#9+ inttostr(orientationMin));

  end;
end;


procedure plot_vector(x,y,r,orientation : double);
var sinO,cosO,xstep,ystep              : double;
    wd                                 : integer;
begin
  wd:=max(1,head.height div 1000);
  mainwindow.image1.canvas.Pen.Color := clred;
  mainwindow.image1.canvas.Pen.width := wd;

  r:=r*wd;
  sincos(orientation,sinO,cosO);
  xstep:=r*cosO;
  ystep:=r*sinO;

  if mainwindow.flip_horizontal1.checked then
  begin
    x:=head.width-x;
    xstep:=-xstep;
  end;

  if mainwindow.flip_vertical1.checked=false then
  begin
    y:=head.height-y;
    ystep:=-ystep;
  end;

  moveToex(mainwindow.image1.Canvas.handle,round(x-xstep),round(y-ystep),nil);
  lineTo(mainwindow.image1.Canvas.handle,round(x+xstep),round(y+ystep)); {line}
end;


procedure CCDinspector_analyse(detype: char; aspect,values,vectors: boolean);
var
 fitsX,fitsY,size,radius, i, j,nhfd,retries,max_stars,starX,starY,font_luminance,n,m,xci,yci,sqr_radius,orientation    : integer;
 hfd1,star_fwhm,snr,flux,xc,yc,detection_level,med                                                                     : double;
 mean, min_value,max_value : single;
 hfd_values  : hfd_array; {array of integers}
 hfds        : array of double;
 Fliphorizontal, Flipvertical: boolean;
 mess: string;
 img_sa : image_array;

begin
  if fits_file=false then exit; {file loaded?}

  max_stars:=1000;

  SetLength(hfd_values,4,4000);{will contain x,y,hfd}
  setlength(img_sa,1,head.width,head.height);{set length of image array}

  get_background(0,img_loaded,false{ calculate histogram},true {calculate noise level},{var}cblack,star_level);{calculate background level from peek histogram}

  detection_level:=max(3.5*noise_level[0],star_level); {level above background. Start with a high value}

  retries:=2; {try up to three times to get enough stars from the image}
  repeat
    nhfd:=0;{set counters at zero}

    for fitsY:=0 to head.height-1 do
      for fitsX:=0 to head.width-1  do
        img_sa[0,fitsX,fitsY]:=-1;{mark as star free area}

    for fitsY:=0 to head.height-1-1  do
    begin
      for fitsX:=0 to head.width-1-1 do
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
                if ((j>=0) and (i>=0) and (j<head.height) and (i<head.width) and (sqr(m)+sqr(n)<=sqr_radius)) then
                  img_sa[0,i,j]:=1;
              end;

            if aspect then measure_star_aspect(img_loaded,xc,yc,round(hfd1*1.5),{out} hfd1 {aspect},orientation);{store the star aspect in hfd1}
//            if aspect then measure_star_aspect(img_loaded,xc,yc,round(hfd1*2),{out} hfd1,orientation);{store the star aspect in hfd1}

            {store values}
            if hfd1<>999 then
            if ( ((img_loaded[0,round(xc),round(yc)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc-1),round(yc)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc+1),round(yc)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc),round(yc-1)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc),round(yc+1)]<head.datamax_org-1) and

                  (img_loaded[0,round(xc-1),round(yc-1)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc-1),round(yc+1)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc+1),round(yc-1)]<head.datamax_org-1) and
                  (img_loaded[0,round(xc+1),round(yc+1)]<head.datamax_org-1)){not saturated}
                  or ((aspect))  )
                  then
            begin

              if nhfd>=length(hfd_values)-1 then
                  SetLength(hfd_values,4,nhfd+100);{adapt length if required}
              hfd_values[0,nhfd]:=round(xc);
              hfd_values[1,nhfd]:=round(yc);
              hfd_values[2,nhfd]:=round(hfd1*100);
              hfd_values[3,nhfd]:=orientation;
              inc(nhfd);

            end;
          end;
        end;
      end;
    end;

    dec(retries);{prepare for trying with lower detection level}
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

  if detype<>' ' then {contour or voronoi}
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
  size:=max(1,head.height div 1000);{font size, 1 is 9x5 pixels}


  setlength(hfds,nhfd);

  for i:=0 to nhfd-1 do {plot rectangles later since the routine can be run three times to find the correct detection_level and overlapping rectangle could occur}
   begin
     if values then
     begin
       if Fliphorizontal     then starX:=head.width-hfd_values[0,i]   else starX:=hfd_values[0,i];
       if Flipvertical       then starY:=head.height-hfd_values[1,i] else starY:=hfd_values[1,i];
       annotation_to_array(floattostrf(hfd_values[2,i]/100 , ffgeneral, 2,1){text},true{transparent},round(img_loaded[0,starX,starY]+font_luminance){luminance},size,starX+round(hfd_values[2,i]/30),starY,img_loaded);{string to image array as annotation. Text should be far enough of stars since the text influences the HFD measurment.}
     end;
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

  plot_fits(mainwindow.image1,false,true);{plot image included text in pixel data}

  if ((aspect) and (vectors)) then
  for i:=0 to nhfd-1 do {plot rectangles later since the routine can be run three times to find the correct detection_level and overlapping rectangle could occur}
  begin
      plot_vector(hfd_values[0,i],hfd_values[1,i],20*(hfd_values[2,i]/100-1) {aspect},hfd_values[3,i]*pi/180);
  end;

  hfd_values:=nil;


end;


procedure Tform_inspection1.hfd_button1Click(Sender: TObject);
var
  j: integer;
  Save_Cursor:TCursor;
  demode : char;
  aspect : boolean;
begin
  Save_Cursor := Screen.Cursor;
  screen.Cursor := crHourglass;    { Show hourglass cursor }

  form_inspection1.undo_button1Click(nil);{undo if required}
  backup_img;
  executed:=2;{restore required to undo}

  if contour_check then demode:='2'
  else
  if voronoi_check then demode:='V'
  else
  demode:=' ';

  if sender=nil {F3 hidden main menu} then
    aspect:=true
  else
    aspect:=((sender=hfd_button1)=false);

  if nrbits=8 then {convert to 16 bit}
  begin
    nrbits:=16;
    head.datamax_org:=65535;
  end;

  if head.naxis3>1 then
  begin
    convert_mono(img_loaded);
    get_hist(0,img_loaded);{get histogram of img_loaded and his_total. Required after box blur to get correct background value}
  end
  else
  if bayer_image then {raw Bayer image}
  begin
    normalize_OSC_flat(img_loaded);
    get_hist(0,img_loaded);{get histogram of img_loaded and his_total. Required after box blur to get correct background value}
  end;

  CCDinspector_analyse(demode,aspect {unroundness or HFD mode}, values_check,vectors_check);

  {$ifdef mswindows}
  filename2:=ExtractFileDir(filename2)+'\hfd_values.fit';
  {$ELSE}{linux}
  filename2:=ExtractFileDir(filename2)+'/hfd_values.fit';
  {$ENDIF}
  mainwindow.memo1.lines.clear;
  for j:=0 to 10 do {create an header with fixed sequence}
    if (j<>5)  then {skip head.naxis3 for mono images}
        mainwindow.memo1.lines.add(head1[j]); {add lines to empthy memo1}
  mainwindow.memo1.lines.add(head1[27]); {add end}

  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);
  if head.naxis3=1 then  remove_key('NAXIS3  ',false{all});{remove key word in header. Some program don't like naxis3=1}

  update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer('DATAMAX =',' / Maximum data value                             ' ,round(cwhite));
  update_text   ('COMMENT 1','  Written by ASTAP, Astrometric STAcking Program. www.hnsky.org');
  if demode='V'  then update_text   ('COMMENT G','  Grey values indicate measured values * 100');


  Screen.Cursor := Save_Cursor;  { Always restore to normal }
end;

procedure Tform_inspection1.measuring_angle1Change(Sender: TObject);
begin
  measuring_angle:=measuring_angle1.text;
end;

procedure check_bayer;
begin
  with form_inspection1 do
  begin
    if normalise_mode=2 then
    begin
      bayer_label1.caption:='Normal image';
      bayer_image:=false;
    end
    else
    if normalise_mode=1 then
    begin
      bayer_label1.caption:='Bayer matrix image';
      bayer_image:=true;
    end
    else {auto}
    begin
      if ((head.naxis3=1) and (bayerpat<>'')) then
      begin
        bayer_label1.caption:='Bayer matrix image';
        bayer_image:=true;
      end
      else
      begin
        bayer_label1.caption:='Normal image';
        bayer_image:=false;
      end;
    end;
  end;
end;

procedure Tform_inspection1.normalise_mode1Change(Sender: TObject);
begin
  normalise_mode:=normalise_mode1.ItemIndex;
  check_bayer;
end;


procedure Tform_inspection1.show_distortion1Click(Sender: TObject);
var
  stars_measured,i :integer;
  report : string;
begin
  form_inspection1.undo_button1Click(nil);{undo if required}
  executed:=1;{only refresh required to undo}

  if calculate_undisturbed_image_scale then
    measure_distortion(true {plot},stars_measured);{measure or plot distortion}

  if to_clipboard1.checked then
  begin
    report:='x database'+#9+'y database'+#9+'x measured'#9+'y measured'+#10;
    for i:=0 to length(distortion_data[0])-1 do
    report:=report+floattostr(distortion_data[0,i])+#9+floattostr(distortion_data[1,i])+#9+floattostr(distortion_data[2,i])+#9+floattostr(distortion_data[3,i])+#10;
    Clipboard.AsText:=report;
  end;
  distortion_data:=nil;
end;


procedure Tform_inspection1.tilt1Click(Sender: TObject);
begin
  form_inspection1.undo_button1Click(nil);{undo if required}
  executed:=1;{only refresh required to undo}

  if extra_stars=false then
    CCDinspector(30,three_corners,strtofloat(measuring_angle))
  else
    CCDinspector(10,three_corners,strtofloat(measuring_angle));
end;


procedure Tform_inspection1.triangle1Change(Sender: TObject);
begin
  three_corners:=triangle1.checked;
end;


procedure Tform_inspection1.undo_button1Click(Sender: TObject);
begin
  if executed=1 then plot_fits(mainwindow.image1,false,true) {only refresh required}
  else
  if mainwindow.Undo1.enabled then
  begin
    restore_img;
  end;
  executed:=0;
end;


procedure Tform_inspection1.values1Change(Sender: TObject);
begin
  values_check:=values1.checked;
end;


procedure Tform_inspection1.vectors1Change(Sender: TObject);
begin
  vectors_check:=vectors1.checked;
end;


procedure Tform_inspection1.voronoi1Change(Sender: TObject);
begin
  voronoi_check:=voronoi1.checked;
  if ((voronoi_check) and (contour_check)) then contour1.checked:=false;
end;


procedure Tform_inspection1.close_button1Click(Sender: TObject);
begin
  form_inspection1.close;   {normal this form is not loaded}
  mainwindow.setfocus;
end;

procedure Tform_inspection1.contour1Change(Sender: TObject);
begin
  contour_check:=contour1.checked;
  if ((voronoi_check) and (contour_check)) then voronoi1.checked:=false;
end;

procedure Tform_inspection1.extra_stars1Change(Sender: TObject);
begin
  extra_stars:=extra_stars1.checked;
end;

procedure Tform_inspection1.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  insp_left:=left;
  insp_top:=top;
  mainwindow.setfocus;
end;


procedure Tform_inspection1.background_values1Click(Sender: TObject);
var
 tx,ty,fontsize,halfstepX,halfstepY,stepX,stepY: integer;
 X,Y,stepsizeX,stepsizeY,median,median_center,factor          : double;
 Save_Cursor:TCursor;
 img_bk                                    : image_array;
 Flipvertical, Fliphorizontal, restore_req  : boolean;
 detext  : string;
begin
  if fits_file=false then exit; {file loaded?}

  form_inspection1.undo_button1Click(nil);{undo if required}
  executed:=1;{only refresh required to undo}

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  restore_req:=false;
  if head.naxis3>1 then {colour image}
  begin
    img_bk:=img_loaded; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
    setlength(img_bk,head.naxis3,head.width,head.height);{force a duplication to a backup image}
    convert_mono(img_loaded);
    get_hist(0,img_loaded);{get histogram of img_loaded and his_total. Required to get correct background value}
    restore_req:=true;{restore original image later}
  end
  else
  if bayer_image then {raw Bayer image}
  begin
    img_bk:=img_loaded; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
    setlength(img_bk,head.naxis3,head.width,head.height);{force a duplication to a backup image}
    normalize_OSC_flat(img_loaded);
    get_hist(0,img_loaded);{get histogram of img_loaded and his_total. Required to get correct background value}
    restore_req:=true; {restore original image later}
  end;


  with mainwindow do
  begin
    Flipvertical:=mainwindow.flip_vertical1.Checked;
    Fliphorizontal:=mainwindow.Flip_horizontal1.Checked;


    image1.Canvas.Pen.Mode := pmMerge;
    image1.Canvas.brush.Style:=bsClear;
    image1.Canvas.font.color:=clyellow;
    fontsize:=round(max(7,head.width/115));{adapt font to image dimensions}
    image1.Canvas.font.size:=fontsize;

    stepX:=trunc(head.width/(fontsize*6));{115/6 => 19  steps maximum, reduce if image is too small for font to fit}
    stepY:=trunc(stepX*head.height/head.width);       {stepY in ratio,typical 13 steps}

    if odd(stepX)=false then stepX:=stepX+1; {make odd}
    if odd(stepY)=false then stepY:=stepY+1; {make odd}

    stepsizeX:=head.width/stepX;{stepsizeX is a double value}
    stepsizeY:=head.height/stepY;{stepsizeY is a double value}

    halfstepX:=round(stepsizeX/2);
    halfstepY:=round(stepsizeY/2);

    median_center:=median_background(img_loaded,0{color},trunc(stepsizeX){size},trunc(stepsizeY),head.width div 2,head.height div 2);{find median value of an area at position x,y with sizeX,sizeY}

    Y:=halfstepY;
    repeat

      X:=halfstepX;
      repeat
        median:=median_background(img_loaded,0{color},trunc(stepsizeX){size},trunc(stepsizeY),round(X),round(Y));{find median value of an area at position x,y with sizeX,sizeY}
        factor:=median/median_center;
        if abs(1-factor)>0.03 then image1.Canvas.font.color:=$00A5FF {dark orange} else image1.Canvas.font.color:=clYellow;
        detext:=floattostrf(factor, ffgeneral, 3,3);

        tx:=round(X);
        ty:=round(Y);

        if Flipvertical=false then  tY:=head.height-tY;
        if Fliphorizontal then tX:=head.width-tX;

        tx:=round(X)-( mainwindow.image1.canvas.Textwidth(detext) div 2);{make text centered at x, y}
        ty:=round(Y)-( mainwindow.image1.canvas.Textheight(detext) div 2);
        mainwindow.image1.Canvas.textout(tX,tY,detext);{add as text}

        X:=X+stepsizeX;

      until X>=head.width-1;

      Y:=Y+stepsizeY;
    until Y>=head.height-1;

    if restore_req then {restore backup image for raw Bayer image or colour image}
    begin
      memo2_message('Restoring image');
      img_loaded:=nil;
      img_loaded:=img_bk; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
      get_hist(0,img_loaded);{get histogram of img_loaded and his_total}
    end;
  end;
  Screen.Cursor:= Save_Cursor;
end;


procedure Tform_inspection1.aberration_inspector1Click(Sender: TObject);
var fitsX,fitsY,col, widthN,heightN                : integer;
    Save_Cursor:TCursor;
var  {################# initialised variables #########################}
   side :integer=250;
const
   gap=4;
begin
  if fits_file then
  begin
   Save_Cursor := Screen.Cursor;
   Screen.Cursor := crHourglass;    { Show hourglass cursor }

   form_inspection1.undo_button1Click(nil);{undo if required}
   backup_img;
   executed:=2;{restore required to undo}

   side:=min(side,head.height div 3);
   side:=min(side,head.width div 3);

   widthN:=3*side+2*gap;
   heightN:=widthN;
   setlength(img_temp,head.naxis3,widthN,heightN);{set length of image array}

   for col:=0 to head.naxis3-1 do
    for fitsY:=0 to heightN-1 do
      for fitsX:=0 to widthN-1 do {clear img_temp for the gaps}
         img_temp[col,fitsX,fitsY]:=0;


   for col:=0 to head.naxis3-1 do
   for fitsY:=0 to side-1 do
     for fitsX:=0 to side-1 do {copy corner}
        img_temp[col,fitsX,fitsY]:=img_loaded[col,fitsX,fitsY];

   for col:=0 to head.naxis3-1 do
   for fitsY:=0 to side-1 do
     for fitsX:=0 to side-1 do {copy corner}
        img_temp[col,fitsX+side+gap,fitsY]:=img_loaded[col,fitsX+(head.width div 2)-(side div 2),fitsY];


   for col:=0 to head.naxis3-1 do
   for fitsY:=0 to side-1 do
     for fitsX:=0 to side-1 do {copy corner}
        img_temp[col,fitsX+2*(side+gap),fitsY]:=img_loaded[col,fitsX+head.width-side,fitsY];




   for col:=0 to head.naxis3-1 do
   for fitsY:=0 to side-1 do
     for fitsX:=0 to side-1 do {copy corner}
        img_temp[col,fitsX,fitsY+(side+gap)]:=img_loaded[col,fitsX,fitsY +(head.height div 2) - (side div 2) ];

   for col:=0 to head.naxis3-1 do
   for fitsY:=0 to side-1 do
     for fitsX:=0 to side-1 do {copy corner}
        img_temp[col,fitsX+side+gap,fitsY+(side+gap)]:=img_loaded[col,fitsX+(head.width div 2)-(side div 2),fitsY +(head.height div 2) - (side div 2) ];


   for col:=0 to head.naxis3-1 do
   for fitsY:=0 to side-1 do
     for fitsX:=0 to side-1 do {copy corner}
        img_temp[col,fitsX+2*(side+gap),fitsY+(side+gap)]:=img_loaded[col,fitsX+head.width-side,fitsY +(head.height div 2) - (side div 2) ];




   for col:=0 to head.naxis3-1 do
   for fitsY:=0 to side-1 do
     for fitsX:=0 to side-1 do {copy corner}
        img_temp[col,fitsX,fitsY+2*(side+gap)]:=img_loaded[col,fitsX,fitsY + head.height - side];

   for col:=0 to head.naxis3-1 do
   for fitsY:=0 to side-1 do
     for fitsX:=0 to side-1 do {copy corner}
        img_temp[col,fitsX+side+gap,fitsY+2*(side+gap)]:=img_loaded[col,fitsX+(head.width div 2)-(side div 2),fitsY + head.height - side];


   for col:=0 to head.naxis3-1 do
   for fitsY:=0 to side-1 do
     for fitsX:=0 to side-1 do {copy corner}
        img_temp[col,fitsX+2*(side+gap),fitsY+2*(side+gap)]:=img_loaded[col,fitsX+head.width-side,fitsY + head.height - side];


//   setlength(img_loaded,head.naxis3,head.width,head.height);{set length of image array}
//   img_loaded[0]:=img_temp[0];
//   if head.naxis3>1 then img_loaded[1]:=img_temp[1];
//   if head.naxis3>2 then img_loaded[2]:=img_temp[2];

//   img_temp:=nil; {free memory}

   img_loaded:=nil;{release memory}
   img_loaded:=img_temp;

   head.width:=widthN;
   head.height:=heightN;

   update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
   update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);

   if head.cd1_1<>0 then {remove solution}
   begin
     remove_key('CD1_1   =',true{one});
     remove_key('CD1_2   =',true{one});
     remove_key('CD2_1   =',true{one});
     remove_key('CD2_2   =',true{one});
     head.cd1_1:=0;
   end;

   update_text   ('COMMENT A','  Aberration view '+filename2);

   filename2:=ChangeFileExt(filename2,'_aberration_view.fits');
   plot_fits(mainwindow.image1,true,true);
   image_move_to_center:=true;

   Screen.Cursor:=Save_Cursor;
  end;
end;


procedure Tform_inspection1.FormKeyPress(Sender: TObject; var Key: char);
begin
  if key=#27 then close_button1Click(sender)
  else
  if key=#26 then {ctrl+Z}
       form_inspection1.undo_button1Click(nil);
end;


procedure Tform_inspection1.FormShow(Sender: TObject);
begin
  form_inspection1.left:=insp_left;
  form_inspection1.top:=insp_top;

  executed:=0;
  contour1.checked:=contour_check;
  voronoi1.checked:=voronoi_check;
  values1.checked:=values_check;
  vectors1.checked:=vectors_check;
  show_distortion1.enabled:=head.cd1_1<>0;
//  bayer_image1.checked:=bayer_image;
  normalise_mode1.ItemIndex:=normalise_mode;
  check_bayer;
  triangle1.checked:=three_corners;
  extra_stars1.checked:=extra_stars;
  measuring_angle1.text:=measuring_angle;
end;


procedure Tform_inspection1.help_uncheck_outliers1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#inspector');
end;


end.

