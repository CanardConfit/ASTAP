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


procedure contour( plot : boolean;img : Timage_array; var head: theader; blur, sigmafactor : double);//find contour and satellite lines in an image
function line_distance(fitsX,fitsY,slope,intercept: double) : double;
procedure trendline_without_outliers(xylist: Tstar_list; len{length xylist} : integer; filter_sigma : double; out  slope, intercept,sd: double);//find linear trendline Y = magnitude_slope*X + intercept. Remove outliers in step 2

//procedure add_to_storage;//add streaks to storage
//procedure clear_storage;//clear streak storage

type
   streak =record
     slope     : double;
     intercept : double;
   end;

var
  streak_lines : array of streak; // storage for streaks of one image
  nr_streak_lines : integer;


implementation

uses unit_stack,unit_gaussian_blur,unit_astrometric_solving;



procedure draw_streak_line(slope,intercept: double);//draw line y = slope * x + intercept
var
   x,y, x1,y1,x2,y2: double;
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


procedure trendline(xylist: Tstar_list; len{length xylist} : integer; out  slope, intercept:double); //find linear trendline Y = magnitude_slope*X + intercept
var                                                                   //idea from https://stackoverflow.com/questions/43224/how-do-i-calculate-a-trendline-for-a-graph

   // Method "Ordinary Least Squares Linear Regression"  or simply: "OLS fit" or "Trendline by least-squares minimization"
   // This is the standard closed-form solution for linear regression using OLS. It's equivalent to what's found in statistical software like Excel’s LINEST, Python's linregress, and R’s lm().
   // Why "Ordinary"?  Because it's based on minimizing vertical errors (Y-axis), assuming:
   // Errors are only in Y (not in X)     Residuals are normally distributed   Homoscedasticity (equal variance)

  sumX,sumX2,sumY, sumXY,median,mad  : double;
  count, i                           : integer;

  median_array                  : array of double;

begin
  count:=0;
  sumX:=0;
  sumX2:=0;
  sumY:=0;
  sumXY:=0;

  for i:=0 to  len-1 do
  begin
    inc(count);
    //memo2_message(#9+floattostr(xylist[0,i])+#9+floattostr(xylist[1,i]));
    sumX:=sumX+xylist[0,i]; //sum X= sum B_V values = sum star colours;
    sumX2:=sumx2+sqr(xylist[0,i]);
    sumY:=sumY+xylist[1,i]; //sum Y, sum delta magnitudes;
    sumXY:=sumXY+xylist[0,i]*xylist[1,i];
  end;

  Slope:=(count*sumXY - sumX*sumY) / (count*sumX2 - sqr(sumX));   // b = (n*Σ(xy) - ΣxΣy) / (n*Σ(x^2) - (Σx)^2)
  Intercept:= (sumY - Slope * sumX)/count;                        // a = (Σy - bΣx)/n
end;


procedure trendline_without_outliers(xylist: Tstar_list; len{length xylist} : integer; filter_sigma : double; out  slope, intercept,sd: double);//find linear trendline Y = magnitude_slope*X + intercept. Remove outliers in step 2
var
  e        : double;
  xylist2  : Tstar_list;
  counter,i  : integer;
begin
  trendline(xylist, len{length xylist}, {out}  slope, intercept);

  // find standard deviation
  sd:=0;
  for i:=0 to len-1 do
    sd:=sd + sqr(slope*xylist[0,i] - xylist[1,i] + intercept)/(sqr(slope)+1);// sum the sqr line distance. Note the line distance is abs(slope*fitsX -fitsY + intercept)/sqrt(sqr(slope)+1), See https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
  sd:=sqrt(sd/len); //sd

  //calculate the trendline but ignore outliers in Y (b-v)
  setlength(xylist2,2,len);
  counter:=0;
  for i:=0 to len-1 do
  begin
    e:=abs(xylist[1,i]{y original} - (slope * xylist[0,i]+intercept{y mean}));  //calculate absolute error
    if e<filter_sigma *sd then //not an outlier keep 86.64%
    begin
      xylist2[0,counter]:=xylist[0,i];// xy list without outliers
      xylist2[1,counter]:=xylist[1,i];
      inc(counter)
    end;
  end;

  trendline(xylist2, counter{length xylist2}, {out}  slope, intercept);
  xylist2:=nil;
end;



procedure contour( plot : boolean;img : Timage_array; var head: theader; blur, sigmafactor : double);//find contour and satellite lines in an image
var
  fitsX,fitsY,ww,hh,fontsize,minX,minY,maxX,maxY,x,y,detection_grid,binning  : integer;
  detection_level,surface,{leng,}maxleng,slope, intercept,sd                 : double;
  restore_his, Fliph, Flipv            : boolean;
  img_sa,img_bk                        : Timage_array;
  contour_array                    : array of array of integer;
  contour_array2                   : Tstar_list;
  bg,sd_bg                         : double;


     procedure mark_pixel(x,y : integer);{flip if required for plotting. From array to image1 coordinates}
     begin
   //    show_marker_shape(mainform1.shape_var1,1,10,10,10{minimum},X,Y);
       if Fliph       then x:=ww-1-x;
       if Flipv=false then y:=hh-1-y;
       mainform1.image1.Canvas.pixels[x*binning,y*binning]:=clYellow;
    //   application.processmessages;

     end;
     procedure mark_pixel_blue(x,y : integer);{flip if required for plotting. From array to image1 coordinates}
     begin
   //    show_marker_shape(mainform1.shape_var1,1,10,10,10{minimum},X,Y);
       if Fliph       then x:=ww-1-x;
       if Flipv=false then y:=hh-1-y;
       mainform1.image1.Canvas.pixels[x*binning,y*binning]:=clBlue;
   //   application.processmessages;
     end;


     procedure writetext(x,y : integer; tex :string);
     begin
       if Fliph       then x:=ww-1-x;
       if Flipv=false then y:=hh-1-y;
       mainform1.image1.Canvas.textout(min(ww*binning-600,x*binning),y*binning,tex);{}
     end;

//    procedure local_background(x1,y1:integer; out bg,sd: double);
//     var
//       i,counter,startX,stopX,startY,stopY : integer;
//       mad_bg : double;
//       background : array [0..100] of double;
//     begin
//       startX:=max(0,x1-14);
//       startY:=max(0,y1-14);
//       stopX:=min(w,x1+14);
//       stopY:=min(h,y1+14);

//       counter:=0;
//       for i:=startX to stopX do {calculate the mean outside the the detection area}
//       begin
//         background[counter]:=img_bk[0,i,startY];
//         inc(counter);
//       end;
//       for i:=startX to stopX do {calculate the mean outside the the detection area}
//       begin
//         background[counter]:=img_bk[0,i,stopY];
//         inc(counter);
//       end;
//       for i:=startY-1 to stopY-1 do {calculate the mean outside the the detection area}
//       begin
//         background[counter]:=img_bk[0,startX,i];
//         inc(counter);
//       end;
//}

//       bg:=Smedian(background,counter);
//       for i:=0 to counter-1 do background[i]:=abs(background[i] - bg);{fill background with offsets}
//       mad_bg:=Smedian(background,counter); //median absolute deviation (MAD)
//       sd:=mad_bg*1.4826; {Conversion from mad to sd for a normal distribution. See https://en.wikipedia.org/wiki/Median_absolute_deviation}
//       {star_bg, sd_bg and r_aperture are global variables}
//     end;


     procedure find_contour(fx,fy : integer);// Moore Neighbor Contour Tracing Algorithm
        function img_protected(xx,yy :integer) : boolean;//return true if pixel is above detection level but avoids errors by reading outside the image.
        begin

          if ((xx>=0) and (xx<ww-1) and (yy>=0) and (yy<hh-1)) then
            result:=img_bk[0,yy,xx]>detection_level
          else
            result:=false;
        end;
     var detection                                               : boolean;
         direction, counter,counterC,startX,startY,i,j,k,offset  : integer;

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
          if img_sa[0,fy,fx]>1 then break;//is looping local
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
                if img_sa[0,contour_array[1,i],k]<0 then
                begin
                  surface:=surface+1;
                  img_sa[0,contour_array[1,i],k]:=+1;//mark as inspected/used
                end;

            //   mark_pixel_blue(k,contour_array[1,i]);
               //application.processmessages;
              end;
            end;
          end;
        end;
        if surface>200*2 then
        begin
          maxleng:=sqrt(sqr(maxY-minY)+sqr(maxX-minX));
                    //writetext(contour_array[0,i],contour_array[1,i],floattostr(surface)+ ', '+floattostr(maxleng)+ ', '+floattostr(sqr(maxleng)/surface));
          if ((maxleng>200) and (sqr(maxleng)/surface>10)) then
          begin
            setlength(contour_array2,2,counterC);
            for i:=0 to counterC-1 do //convert to an array of singles instead of integers
            begin
              contour_array2[0,i]:=contour_array[0,i];
              contour_array2[1,i]:=contour_array[1,i];
              //memo2_message(#9+floattostr(contour_array[0,i])+#9+floattostr(contour_array[1,i]));
            end;


            trendline_without_outliers(contour_array2,counterC,1.5,slope, intercept,sd);
            intercept:=intercept*binning;
            sd:=sd*binning;

            if sd<10 then
            begin  // A real line, sd max is about line thickness plus a nearby star.
              if plot then
              begin
                mainform1.image1.Canvas.Pen.mode:=pmXor;
                mainform1.image1.Canvas.Pen.Color := clred;
                draw_streak_line(slope,intercept);//draw satellite streak

                mainform1.image1.Canvas.pen.color:=clyellow;
              end;
               if plot then writetext(min(ww*binning,contour_array[0,counterC div 2]),contour_array[1,counterC div 2],' Y='+floattostrf(slope,FFgeneral,5,0)+'*X + '+Floattostrf(intercept,FFgeneral,5,0)+ ',  σ='+ Floattostrf(sd,FFgeneral,3,0));
              memo2_message('Streak found: '+filename2+',     Y='+floattostrf(slope,FFgeneral,5,0)+'*X + '+Floattostrf(intercept,FFgeneral,5,0)+ ',  σ='+ Floattostrf(sd,FFgeneral,3,0));

              contour_array2:=nil;

              streak_lines[nr_streak_lines].slope:=slope;
              streak_lines[nr_streak_lines].intercept:=intercept;
              inc(nr_streak_lines);

              if nr_streak_lines>=length(streak_lines) then
                   setlength(streak_lines,nr_streak_lines+20); //get more memory


            end;

          end;
        end;
      end;
begin
  restore_his:=false;
  binning:=1;
  if head.naxis3>1 then {colour image}
  begin
    memo2_message('Converting image to mono');
    bin_mono_and_crop(1 {binning}, 1{cropping}, img, img_bk);// Make mono, bin and crop
    get_hist(0,img_bk);{get histogram of img and his_total. Required to get correct background value}
    restore_his:=true;
  end
  else
  if (bayerpat<>'') then {raw Bayer image}
  begin
    memo2_message('Binning raw image for streak detection');
    bin_mono_and_crop(2 {binning}, 1{cropping}, img {out}, img_bk);// Make mono, bin and crop
    get_hist(0,img_bk);{get histogram of img and his_total. Required to get correct background value}
    restore_his:=true;
    binning:=2;
  end
  else
    img_bk:=img; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}

  ww:=Length(img_bk[0,0]);    {width}
  hh:=Length(img_bk[0]); {height}

  streak_lines:=nil;
  nr_streak_lines:=0;
  setlength(streak_lines,20);//allow 20 streak lines

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

    setlength(img_sa,1,hh,ww);{set length of image array}

    gaussian_blur2(img_bk, blur);{apply gaussian blur }
    get_background(0,img_bk,head,{cblack=0} false{histogram is already available},true {calculate noise level});{calculate background level from peek histogram}

    detection_level:=sigmafactor*head.noise_level+ head.backgr;
    detection_grid:=strtoint2(stackmenu1.detection_grid1.text,400) div binning;

    for fitsY:=0 to hh-1 do
      for fitsX:=0 to ww-1  do
        img_sa[0,fitsY,fitsX]:=-1;{mark as star free area}


    for fitsY:=0 to hh-1  do
    begin
      for fitsX:=0 to ww-1 do
      begin
        if ((detection_grid<=0) or (frac(fitsX/detection_grid)=0) or (frac(fitsy/detection_grid)=0)) then //overlay of vertical and horizontal lines
        if (( img_sa[0,fitsY,fitsX]<0){untested area}  and (img_bk[0,fitsY,fitsX]>detection_level){star}) then {new star}
        begin
          find_contour(fitsX,fitsY);
          if frac(fitsY/300)= 0 then
          begin
            application.processmessages;
            if esc_pressed then break;
          end;
        end;
      end;
    end;

  end;{with mainform1}

  if restore_his then
  begin
    img_bk:=nil;
    get_hist(0,img);{get histogram of img and his_total}
  end;


  img_sa:=nil;{free mem}
end;


end.

