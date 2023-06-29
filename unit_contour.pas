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


procedure contour(plot : boolean; img_bk : image_array; var head: theader; blur, sigmafactor : double; out restore_req: boolean);//find contour and satellite lines in an image
//procedure draw_streak_line(slope,intercept: double);//draw line y = slope * x + intercept
function line_distance(fitsX,fitsY,slope,intercept: double) : double;

procedure add_to_storage;//add streaks to storage
procedure clear_storage;//clear streak storage

var
  streak_lines : array of array of double; // storage for streaks of one image
  nr_streak_lines : integer;

  all_streak_lines: array of array of double; //extra storage for all streaks for stacking;
  streak_index_start  : integer;

implementation

uses unit_stack,unit_gaussian_blur;



procedure draw_streak_line(slope,intercept: double);//draw line y = slope * x + intercept
var
   x,y, x1,y1,x2,y2: double;
   w,h             : integer;
   flipV,fliph     : boolean;
begin
  with mainwindow do
  begin
    Flipv:=mainwindow.flip_vertical1.Checked;
    Fliph:=mainwindow.Flip_horizontal1.Checked;
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

  mainwindow.image1.Canvas.MoveTo(round(x1),round(y1));
  mainwindow.image1.Canvas.lineTo(round(x2),round(y2));
end;


function line_distance(fitsX,fitsY,slope,intercept: double) : double;
begin
  //y:=ax+c   => 0=by+ax+c
  //0:=-y+ax+c and  b=-1
  //distance:=abs(a.fitsX+b.fitsY+c)/sqrt(sqr(a)+sqr(b))        See https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
  result:=abs(slope*fitsX -fitsY + intercept)/sqrt(sqr(slope)+1);
end;


procedure add_to_storage;//add streaks to storage
var
  i,len :integer;
begin
  len:=length(all_streak_lines);

  streak_index_start:=len;

  setlength(all_streak_lines,len+ nr_streak_lines,2);
  for i:=0 to nr_streak_lines-1 do
  begin
    all_streak_lines[i+len]:= streak_lines[i];
  end;
end;


procedure clear_storage; //clear streak storage
begin
  all_streak_lines:=nil;
  streak_index_start:=0;
end;

procedure contour( plot : boolean;img_bk : image_array; var head: theader; blur, sigmafactor : double; out restore_req: boolean);//find contour and satellite lines in an image
var
  fitsX,fitsY,w,h,fontsize,minX,minY,maxX,maxY,x,y,detection_grid  : integer;
  detection_level,surface,{leng,}maxleng,slope, intercept,sd       : double;

  Fliph, Flipv                     : boolean;
  img_sa                           : image_array;
  contour_array                    : array of array of integer;
  contour_array2                   : star_list;
  bg,sd_bg                         : double;


     procedure mark_pixel(x,y : integer);{flip if required for plotting. From array to image1 coordinates}
     begin
   //    show_marker_shape(mainwindow.shape_alignment_marker1,1,10,10,10{minimum},X,Y);
       if Fliph       then x:=w-x;
       if Flipv=false then y:=h-y;
       mainwindow.image1.Canvas.pixels[x,y]:=clYellow;
    //   application.processmessages;

     end;

     procedure writetext(x,y : integer; tex :string);
     begin
       if Fliph       then x:=w-x;
       if Flipv=false then y:=h-y;
       mainwindow.image1.Canvas.textout(x,y,tex);{}
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

          if ((xx>=0) and (xx<w) and (yy>=0) and (yy<h)) then
            result:=img_bk[0,xx,yy]>detection_level
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
        setlength(contour_array,2,4*w+1);

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

          img_sa[0,fx,fy]:=img_sa[0,fx,fy]+1;//mark as inspected/used
          if img_sa[0,fx,fy]>1 then break;//is looping local
          inc(counter);



        until (((fx=startX) and (fy=startY)) or (counter>4*w));

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
                img_sa[0,k,contour_array[1,i]]:=+1;//mark as inspected/used
                surface:=surface+1;
               //mark_pixelCustom(k,contour_array[1,i],clblue);
              // application.processmessages;
              end;
            end;
          end;
        end;
        if surface>100 then
        begin
          maxleng:=sqrt(sqr(maxY-minY)+sqr(maxX-minX));
          if ((maxleng>300) and (sqr(maxleng)/surface>10)) then
          begin
            setlength(contour_array2,2,counterC);
            for i:=0 to counterC-1 do //convert to an array of singles instead of integers
            begin
              contour_array2[0,i]:=contour_array[0,i];
              contour_array2[1,i]:=contour_array[1,i];
            end;

            trendline_without_outliers(contour_array2,counterC,slope, intercept,sd);

            if plot then writetext(min(w-600,contour_array[0,counterC div 2]),contour_array[1,counterC div 2],' Y='+floattostrf(slope,ffgeneral,5,5)+'*X + '+Floattostrf(intercept,ffgeneral,5,5)+ ',  sd='+ Floattostrf(sd,ffgeneral,4,4));
            memo2_message('Streak found: '+filename2+',  Y='+floattostrf(slope,ffgeneral,5,5)+'*X + '+Floattostrf(intercept,ffgeneral,5,5)+ ',  sd='+ Floattostrf(sd,ffgeneral,5,5));

            contour_array2:=nil;

            streak_lines[nr_streak_lines,0]:=slope;
            streak_lines[nr_streak_lines,1]:=intercept;
            inc(nr_streak_lines);

            if nr_streak_lines>=length(streak_lines) then
                 setlength(streak_lines,nr_streak_lines+20,2); //get more memory

            if plot then
            begin
              mainwindow.image1.Canvas.Pen.Color := clred;
              draw_streak_line(slope,intercept);//draw satellite streak

              mainwindow.image1.Canvas.pen.color:=clyellow;
            end;

          end;
        end;
      end;
begin
  if head.naxis3>1 then {colour image}
  begin
    convert_mono(img_bk,head);
    get_hist(0,img_bk);{get histogram of img and his_total. Required to get correct background value}

    restore_req:=true;
  end
  else
  if (bayerpat<>'') then {raw Bayer image}
  begin
    check_pattern_filter(img_bk);
    restore_req:=true;
  end;

  w:=head.Width-1;
  h:=head.height-1;


  streak_lines:=nil;
  nr_streak_lines:=0;
  setlength(streak_lines,20,2);//allow 20 streak lines

  with mainwindow do
  begin
    if plot then
    begin
      Flipv:=mainwindow.flip_vertical1.Checked;
      Fliph:=mainwindow.Flip_horizontal1.Checked;

      image1.Canvas.Pen.Mode := pmMerge;
      image1.Canvas.brush.Style:=bsClear;
      image1.Canvas.font.color:=clLime;
      image1.Canvas.Pen.Color := clYellow;
      image1.Canvas.Pen.width := round(1+head.height/image1.height);{thickness lines}
      fontsize:=round(max(10,8*head.height/image1.height));{adapt font to image dimensions}
      image1.Canvas.font.size:=fontsize;

    end;

    setlength(img_sa,1,head.width,head.height);{set length of image array}

    gaussian_blur2(img_bk, blur);{apply gaussian blur }
    // get_hist(0,img_bk);{get histogram of img_bk and his_total. Required to get correct background value}
    get_background(0,img_bk,{cblack=0} false{histogram is already available},true {calculate noise level},{out}bck);{calculate background level from peek histogram}

    detection_level:=sigmafactor*bck.noise_level+ bck.backgr;
    detection_grid:=strtoint2(stackmenu1.detection_grid1.text);

    for fitsY:=0 to h do
      for fitsX:=0 to w  do
        img_sa[0,fitsX,fitsY]:=-1;{mark as star free area}


    for fitsY:=0 to h  do
    begin
      for fitsX:=0 to w do
      begin
        if ((detection_grid<=0) or (frac(fitsX/detection_grid)=0) or (frac(fitsy/detection_grid)=0)) then //overlay of vertical and horizontal lines
        if (( img_sa[0,fitsX,fitsY]<0){untested area}  and (img_bk[0,fitsX,fitsY]>detection_level){star}) then {new star}
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

  end;{with mainwindow}

  img_sa:=nil;{free mem}
end;


end.

