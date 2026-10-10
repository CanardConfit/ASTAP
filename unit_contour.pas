unit unit_contour;// Moore Neighbor Contour Tracing Algorithm
{Copyright (C) 2023 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }


interface

uses
  Classes, SysUtils,graphics,forms,math,controls,lclintf,fpcanvas,
  astap_main;


procedure trail( plot : boolean;img : Timage_array; var head: theader; blur, sigmafactor : double; out starlist :Tstar_list);//find trails in an image

type
   streak =record
     slope     : double;
     intercept : double;
   end;

var
  streak_lines : array of streak; // storage for streaks of one image


implementation

uses unit_stack,unit_threaded_gaussian_blur,unit_astrometric_solving, unit_transformation, unit_star_align;



procedure draw_streak_line(slope,intercept: double);//draw line y = slope * x + intercept
var
   x1,y1,x2,y2     : double;
   w,h             : integer;
   flipV,fliph     : boolean;
begin
  with mainform1 do
  begin
    Flipv:=mainform1.flip_vertical1.Checked;
    Fliph:=mainform1.Flip_horizontal1.Checked;
    w:=image1.Canvas.Width-1;
    h:=image1.Canvas.height-1;
  end;


  //start point line
  x1:=0;
  y1:=intercept;
  if y1>h then
  begin
    y1:=h;
    x1:=(h-intercept)/slope;
  end
  else
  if y1<0 then
  begin
    y1:=0;
    x1:=(-intercept)/slope;
  end;

  //end point line
  x2:=w-1;
  y2:=slope*(w-1)+intercept;
  if y2>h then
  begin
    y2:=h;
    x2:=(h-intercept)/slope;
  end
  else
  if y2<0 then
  begin
    y2:=0;
    x2:=(-intercept)/slope;
  end;

  //draw
  if Fliph then
  begin
    x1:=w-x1;
    x2:=w-x2;
  end;
  if Flipv=false then
  begin
    y1:=h-y1;
    y2:=h-y2;
  end;

  mainform1.image1.Canvas.MoveTo(round(x1),round(y1));
  mainform1.image1.Canvas.lineTo(round(x2),round(y2));
end;


function line_distance(fitsX,fitsY,slope,intercept: double) : double;
begin
  //y:=ax+c   => 0=by+ax+c
  //0:=-y+ax+c and  b=-1
  //distance:=abs(a.fitsX+b.fitsY+c)/sqrt(sqr(a)+sqr(b))        See https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
  result:=abs(slope*fitsX -fitsY + intercept)/sqrt(sqr(slope)+1);
end;



procedure trail( plot : boolean;img : Timage_array; var head: theader; blur, sigmafactor : double; out starlist :Tstar_list);//find trails/streaks in an image
var
  fitsX,fitsY,ww,hh,fontsize,minX,minY,maxX,maxY,detection_grid,binning,nrstars,maxnr_stars,i,surface,max_stars    : integer;
  detection_level, maxleng, averageX,averageY,length_div_width                                                     : double;
  restore_his, Fliph, Flipv,dostop     : boolean;
  img_sa,img_bk                        : Timage_array;
  contour_array                        : array of array of integer;


     procedure mark_pixel(x,y : integer);{flip if required for plotting. From array to image1 coordinates}
     begin
       if Fliph       then x:=ww-1-x;
       if Flipv=false then y:=hh-1-y;
       mainform1.image1.Canvas.pixels[x*binning,y*binning]:=clYellow;
     end;
     procedure mark_pixel_blue(x,y : integer);{flip if required for plotting. From array to image1 coordinates}
     begin
       if Fliph       then x:=ww-1-x;
       if Flipv=false then y:=hh-1-y;
       mainform1.image1.Canvas.pixels[x*binning,y*binning]:=clBlue;
     end;

     procedure mark_pixel_blueBOX(x,y : integer);{flip if required for plotting. From array to image1 coordinates}
     const
       size=25;
     begin
       if Fliph       then x:=ww-1-x;
       if Flipv=false then y:=hh-1-y;
       mainform1.image1.Canvas.Rectangle(X-size,Y-size, X+size, Y+size);{indicate with rectangle}
     end;


     procedure writetext(x,y : integer; tex :string);
     begin
       if Fliph       then x:=ww-1-x;
       if Flipv=false then y:=hh-1-y;
       mainform1.image1.Canvas.textout(min(ww*binning-600,x*binning),y*binning,tex);{}
     end;


     procedure find_contour(fx,fy : integer);// Moore Neighbor Contour Tracing Algorithm
        function img_protected(xx,yy :integer) : boolean;//return true if pixel is above detection level but avoids errors by reading outside the image.
        begin

          if ((xx>=0) and (xx<ww-1) and (yy>=0) and (yy<hh-1)) then
            result:=img_bk[0,yy,xx]>detection_level
          else
            result:=false;
        end;
     var detection                                               : boolean;
         direction, counter,counterC,startX,startY,i,j,k         : integer;

     const
       newdirection : array[0..7] of integer=(-1,0,0,+1,+1,+2,+2,-1);//delta directions
       directions : array[0..7,0..1] of integer=((-1,-1), //3 south east, direction
                                                 (-1,0),  //0 east
                                                 (-1,+1), //0 north east
                                                 (0,+1),  //1, north
                                                 (+1,+1), //1 north west
                                                 (+1,0),  //2 west
                                                 (+1,-1), //2 south west
                                                 (0,-1)); //3 south

      begin
        direction:=1;// , north=0, west=1, south=2. east=3
        startX:=fx;
        startY:=fy;
        counter:=0;
        counterC:=0;
        setlength(contour_array,2,4*ww);

        repeat
         detection:=false;

         for i:=0 to 7 do
         begin
           j:=((i+direction*2) and $7);
           if img_protected(fx+directions[j,0],fy+directions[j,1])then //pixel detected
           begin
             fx:=fx+directions[j,0];
             fy:=fy+directions[j,1];
             detection:=true;
             direction:=direction+newdirection[i]; //new direction
             break;
           end;
          end;

          if detection=false then
            break
          else
          begin
            if plot then mark_pixel(fx,fy);
            contour_array[0,counterC]:=fx;
            contour_array[1,counterC]:=fy;
            inc(counterC);
          end;

          img_sa[0,fy,fx]:=img_sa[0,fy,fx]+1;//mark as inspected/used
          if img_sa[0,fy,fx]>2 then break;//is looping local
          inc(counter);
        until (((fx=startX) and (fy=startY)) or (counter>4*ww));

        //mark inner of contour
        surface:=0;
        maxX:=0;
        minX:=999999;
        maxY:=0;
        minY:=999999;
        for i:=0 to counterC-1 do
        begin
          minX:=min(contour_array[0,i],minX);
          maxX:=max(contour_array[0,i],maxX);
          minY:=min(contour_array[1,i],minY);
          maxY:=max(contour_array[1,i],maxY);

          for j:=0 to counterC-1 do
          begin //mark inner of contour
            if contour_array[1,i]=contour_array[1,j] then //y position the same
            begin
              for k:=min(contour_array[0,i],contour_array[0,j]) to max(contour_array[0,i],contour_array[0,j]) do //mark space between the mininum and maximum x values. With two pixel extra overlap.
              begin
                if img_sa[0,contour_array[1,i],k]=0 then
                begin
                  surface:=surface+1;
                  img_sa[0,contour_array[1,i],k]:=+1;//mark as inspected/used
                end;
              end;
            end;
          end;
        end;

        maxleng:=sqrt(sqr(maxY-minY)+sqr(maxX-minX));
        if ((maxleng>detection_grid) and (surface>5)) then

        begin
          //writetext(contour_array[0,i],contour_array[1,i],floattostr(surface)+ ', '+floattostr(maxleng)+ ', '+floattostr(sqr(maxleng)/surface));
          if  sqr(maxleng)/surface>length_div_width then  //length is much larger then width.
          begin
            averageX:=0;
            averageY:=0;

            for i:=0 to counterC-1 do //calc center position
            begin
              averageX:=averageX+contour_array[0,i];
              averageY:=averageY+contour_array[1,i];
            end;
            averageX:= averageX/(counterC);
            averageY:= averageY/(counterC);

            starlist[0,nrstars]:=averageX;
            starlist[1,nrstars]:=averageY;
            inc(nrstars);

            writetext(round(averageX),round(averageY),inttostr(round(maxleng)) );
          end;
        end;
      end;


begin
  restore_his:=false;
  binning:=1;
  max_stars:=strtoint2(stackmenu1.max_stars1.Text,500);

  if stackmenu1.star_trails_as_stars1.checked=false then
    length_div_width:=10
  else
    length_div_width:=3;// width/length

  if head.naxis3>1 then {colour image}
  begin
    memo2_message('Converting image to mono');
    bin_mono_and_crop(binning, 1{cropping}, img, img_bk);// Make mono, bin and crop
    get_hist(0,img_bk);{get histogram of img and his_total. Required to get correct background value}
    restore_his:=true;
  end
  else
  if (bayerpat<>'') then {raw Bayer image}
  begin
    binning:=2;
    memo2_message('Binning raw image for streak detection');
    bin_mono_and_crop(binning, 1{cropping}, img {out}, img_bk);// Make mono, bin and crop
    get_hist(0,img_bk);{get histogram of img and his_total. Required to get correct background value}
    restore_his:=true;
  end
  else
    duplicate(img,img_bk); //protect img

  ww:=Length(img_bk[0,0]);    {width}
  hh:=Length(img_bk[0]); {height}

  with mainform1 do
  begin
    if plot then
    begin
      Flipv:=mainform1.flip_vertical1.Checked;
      Fliph:=mainform1.Flip_horizontal1.Checked;

      image1.Canvas.Pen.Mode := pmMerge;
      image1.Canvas.brush.Style:=bsClear;
      image1.Canvas.font.color:=clLime;
      image1.Canvas.Pen.Color := clYellow;
      image1.Canvas.Pen.width := round(1+head.height/image1.height);{thickness lines}
      fontsize:=round(max(10,8*head.height/image1.height));{adapt font to image dimensions}
      image1.Canvas.font.size:=fontsize;
    end;

    setlength(img_sa,1,hh,ww);//In case the length is set to a larger length than the current one, the new elements are zeroed out for a dynamic array. See https://www.freepascal.org/docs-html/rtl/system/setlength.html.

    gaussian_blur_threaded(img_bk, blur);{apply gaussian blur }
    get_background(0,img_bk,head,max_stars,{cblack=0} false{histogram is already available},true {calculate noise level});{calculate background level from peek histogram}

    detection_level:=sigmafactor*head.noise_level+ head.backgr;
    detection_grid:=strtoint2(stackmenu1.detection_grid1.text,400) div binning;

    nrstars:=0;
    maxnr_stars:=strtoint2(stackmenu1.max_stars1.Text,500);
    setlength(starlist,2,maxnr_stars);//three fields, x,y,magn

    dostop:=false;

    for fitsY:=0 to hh-1  do
    begin
      for fitsX:=0 to ww-1 do
      begin
        if ((detection_grid<=0) or (frac(fitsX/detection_grid)=0) or (frac(fitsy/detection_grid)=0)) then //overlay of vertical and horizontal lines
        if (( img_sa[0,fitsY,fitsX]=0){untested area}  and (img_bk[0,fitsY,fitsX]>detection_level){star}) then {new star}
        begin
          find_contour(fitsX,fitsY);
          if frac(fitsY/300)= 0 then
          begin
            application.processmessages;
            if esc_pressed then break;
          end;
          if nrstars>=maxnr_stars-1 then //enough stars
          begin
             dostop:=true;
             break;
          end;

        end;
      end;
      if dostop then //enough stars
         break;
    end;

//  setlength(maxleng_array2,nrstars);
//  for i:=0 to nrstars-1 do maxleng_array2[i]:=maxleng_array[i];//duplicate because smedian sorts array.
//  med_length:=smedian(maxleng_array2,nrstars);

    setlength(starlist,2,nrstars);



//   keep only the brightest
//   get_brightest_stars(maxnr_stars2 div 10 { 1/10 of max stars setting}, magn_max, starlist);{ Extract the brightest star from a star list}
//   memo2_message(inttostr(length(starlist[0]))+' trails detected, limited to 1/10 of max nr stars setting.');

   if plot then
  for i:=0 to length(starlist[0])-1 do
  begin
    mark_pixel_blueBox(round(starlist[0,i]),round(starlist[1,i]));
   // writetext(round(starlist[0,i]),round(starlist[1,i]),inttostr(i){+', '+ inttostr(round(maxleng_array[i]))+ ', '+ floattostr2(starlist[2,i])} );
  end;




  end;{with mainform1}

  if restore_his then
  begin
    get_hist(0,img);{get histogram of img and his_total}
  end;


{  for fitsY:=0 to hh-1  do
   begin
     for fitsX:=0 to ww-1 do
      begin
        if img_sa[0,fitsY,fitsX]>0 then
          img[0,fitsY,fitsX]:=img_sa[0,fitsY,fitsX]*5000;
      end;
   end;
  plot_image(mainform1.image1, False);}

end;




end.

