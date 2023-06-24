unit unit_contour;

//{$mode Delphi}

interface

uses
  Classes, SysUtils,graphics,forms,math,controls,lclintf,fpcanvas,
  astap_main;


procedure contour(var img : image_array; var head: theader; blur, sigmafactor : double);//find contour and satellite lines in an image
procedure wipe_streaks(var img: image_array);

var
  streak_lines : star_list;
  nr_streak_lines : integer;

implementation

uses unit_stack,unit_gaussian_blur;

function line_distance(fitsX,fitsY,slope,intercept: double) : double;
begin
  //y:=ax+c
  //0:=-y+ax+c   b=-1
  //distance:=abs(a.fitsX+b.fitsY+c)/sqrt(sqr(a)+sqr(b))
  result:=abs(slope*fitsX -fitsY + intercept)/sqrt(sqr(slope)+1)
end;

procedure wipe_streaks(var img: image_array);
var
  fitsX,fitsY, i,col       : integer;
begin
  for i:=0 to nr_streak_lines-1 do
  for fitsY:=0 to head.height-1 do {skip outside "bad" pixels if mosaic mode}
  for fitsX:=0 to head.width-1  do
  begin
    if line_distance(fitsX,fitsY,streak_lines[0,i],streak_lines[1,i])<=6 then
      for col:=0 to head.naxis3-1 do {all colors}
      begin
        img[col,fitsX,fitsY]:=0;
      end;
  end;
end;



procedure contour(var img : image_array; var head: theader; blur, sigmafactor : double);//find contour and satellite lines in an image
var
fitsX,fitsY, oldNaxis3,w,h,fontsize,minX,minY,maxX,maxY    : integer;
detection_level,surface,leng,maxleng,slope, intercept,sd    : double;

Fliph, Flipv,restore_req         : boolean;
img_bk,img_sa                    : image_array;
contour_array                    : array of array of integer;
contour_array2                   : star_list;

     procedure mark_pixel(x,y : integer);{flip if required for plotting. From array to image1 coordinates}
     begin
//       show_marker_shape(mainwindow.shape_alignment_marker1,1,10,10,10{minimum},X,Y);
       if Fliph       then x:=w-x;
       if Flipv=false then y:=h-y;
       mainwindow.image1.Canvas.pixels[x,y]:=clYellow;

     end;

     procedure mark_pixelCustom(x,y,col : integer);{flip if required for plotting. From array to image1 coordinates}
     begin
//       show_marker_shape(mainwindow.shape_alignment_marker1,1,20,20,10{minimum},X,Y);
       if Fliph       then x:=w-x;
       if Flipv=false then y:=h-y;
       mainwindow.image1.Canvas.pixels[x,y]:=col;
 //      application.processmessages;
     end;

     procedure writetext(x,y : integer; tex :string);
     begin
       if Fliph       then x:=w-x;
       if Flipv=false then y:=h-y;
       mainwindow.image1.Canvas.textout(x,y,tex);{}
     end;

     procedure line(slope,intercept: double);//draw line y = slope * x + intercept
     var
        x,y, x1,y1,x2,y2: double;
     begin

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



     procedure find_contour(fx,fy : integer);//mark counter according Theo Pavlidis' Algorithm, https://www.imageprocessingplace.com/downloads_V3/root_downloads/tutorials/contour_tracing_Abeer_George_Ghuneim/theo.html
        function img_protected(xx,yy :integer) : boolean;//return true if pixel is above detection level but avoids errors by reading outside the image.
        begin
          if ((xx>=0) and (xx<w) and (yy>=0) and (yy<h)) then
            result:=img[0,xx,yy]- bck.backgr>detection_level
          else
            result:=false;
        end;
     var detection                                               : boolean;
         direction, counter,counterC,startX,startY,rotated,i,j,k : integer;

     begin
       //test p1,p2,p3
       direction:=1;// north
       startX:=fx;
       startY:=fy;
       counter:=0;
       counterC:=0;
       rotated:=0;
       setlength(contour_array,2,4*w+1);


      // img_sa[0,fx,fy]:=+1;//mark as inspected/used


       repeat
         detection:=false;

    //      if fx=149-1 then
    //       if fy=35-1 then
    //       beep;
    //    if counter>2000 then
     //   beep;


         if direction=1 {north} then
         begin
           if img_protected(fx-1,fy+1) then begin { img_sa[0,fx,fy+1]:=+1; img_sa[0,fx-1,fy]:=+1;}{mark as inspected}  fx:=fx-1;fy:=fy+1; direction:=4;{east} detection:=true; end  //p1
           else
           if img_protected(fx,fy+1) then begin fx:=fx;fy:=fy+1;detection:=true; end  //p2
           else
           if img_protected(fx+1,fy+1) then begin  {img_sa[0,fx,fy+1]:=+1; img_sa[0,fx+1,fy]:=+1;}{mark as inspected}  fx:=fx+1;fy:=fy+1;direction:=2;{west}detection:=true; end  //p3
         end
         else
         if direction=4 {east} then
         begin
           if img_protected(fx-1,fy-1) then begin  {img_sa[0,fx,fy-1]:=+1; img_sa[0,fx-1,fy]:=+1;}{mark as inspected}  fx:=fx-1;fy:=fy-1; direction:=3;{south} detection:=true; end  //p1
           else
           if img_protected(fx-1,fy) then begin fx:=fx-1;fy:=fy; detection:=true; end  //p2
           else
           if img_protected(fx-1,fy+1) then begin  {img_sa[0,fx,fy+1]:=+1; img_sa[0,fx-1,fy]:=+1;}{mark as inspected}   fx:=fx-1;fy:=fy+1;direction:=1;{north}detection:=true; end  //p3
         end
         else
         if direction=2 {west} then
         begin
           if img_protected(fx+1,fy+1) then begin  {img_sa[0,fx,fy+1]:=+1; img_sa[0,fx+1,fy]:=+1;}{mark as inspected}   fx:=fx+1;fy:=fy+1; direction:=1;{north} detection:=true; end  //p1
           else
           if img_protected(fx+1,fy) then begin fx:=fx+1;fy:=fy;detection:=true; end  //p2
           else
           if img_protected(fx+1,fy-1) then begin  {img_sa[0,fx,fy-1]:=+1; img_sa[0,fx+1,fy]:=+1;}{mark as inspected}   fx:=fx+1;fy:=fy-1; direction:=3;{south} detection:=true; end  //p3
         end
         else
         if direction=3 {south} then
         begin
           if img_protected(fx+1,fy-1) then begin { img_sa[0,fx,fy-1]:=+1; img_sa[0,fx+1,fy]:=+1;}{mark as inspected}   fx:=fx+1;fy:=fy-1; direction:=2;{west}detection:=true;end  //p1
           else
           if img_protected(fx,fy-1) then begin fx:=fx;fy:=fy-1;detection:=true; end  //p2
           else
           if img_protected(fx-1,fy-1) then begin  {img_sa[0,fx,fy-1]:=+1; img_sa[0,fx-1,fy]:=+1;}{mark as inspected}   fx:=fx-1;fy:=fy-1;direction:=4;{east}detection:=true; end  //p3
         end;

         if detection=false then
         begin
           inc(direction);//change direction
           if direction>4 then direction:=1;//east to north
           inc(rotated);//rotate 3 times max
         end
         else
         begin
//           if img_sa[0,fx,fy]>0 then //break, already done
  //            exit;
           rotated:=0;
           mark_pixel(fx,fy);

//           application.processmessages;

           contour_array[0,counterC]:=fx;
           contour_array[1,counterC]:=fy;
           inc(counterC);
         end;
         img_sa[0,fx,fy]:=img_sa[0,fx,fy]+1;//mark as inspected/used
         if img_sa[0,fx,fy]>2 then break;//loop
         inc(counter);
        // if counter>900 then
        // beep;


       until ({((fx=startX) and (fy=startY)) or }(rotated>3) or (counter>4*w));


//       application.processmessages;
 //      if esc_pressed then exit;


//       if counter>4*w then
//       begin
//         for i:=0 to 4*w-1 do
//         begin
//           mark_pixelCustom(contour_array[0,i],contour_array[1,i],clREd);
//           application.processmessages;
//           if esc_pressed then exit;
       //    if img_sa[0,contour_array[0,i],contour_array[1,i]]>0 then
       //    beep;
//         end;
//         exit;
//      end;


      //mark inner of contour
       surface:=0;
       leng:=0;
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
               if img_sa[0,k,contour_array[1,i]]<0 then
               begin
               img_sa[0,k,contour_array[1,i]]:=+1;//mark as inspected/used
               surface:=surface+1;
    //             mark_pixelCustom(k,contour_array[1,i],clblue);
   //              application.processmessages;
               end;
             end;
           end;
         end;
       end;
       if surface>100 then
       begin
         maxleng:=sqrt(sqr(maxY-minY)+sqr(maxX-minX));
         if ((maxleng>100) and (sqr(maxleng)/surface>10)) then
         begin
           setlength(contour_array2,2,counterC);
           for i:=0 to counterC-1 do //convert to an array of singles instead of integers
           begin
             contour_array2[0,i]:=contour_array[0,i];
             contour_array2[1,i]:=contour_array[1,i];
           end;

           trendline_without_outliers(contour_array2,counterC,slope, intercept,sd);

           writetext(contour_array[0,counterC div 2],contour_array[1,counterC div 2],inttostr(round(maxleng))+' Y='+floattostrf(slope,ffgeneral,4,4)+'*X + '+Floattostrf(intercept,ffgeneral,4,4)+ ',  sd='+ Floattostrf(sd,ffgeneral,4,4));
           contour_array2:=nil;

           leng:=length(streak_lines[0]);
           streak_lines[0,nr_streak_lines]:=slope;
           streak_lines[1,nr_streak_lines]:=intercept;
           inc(nr_streak_lines);
           if nr_streak_lines>=length(streak_lines[0]) then
                 setlength(streak_lines,2,nr_streak_lines+10); //get more memory

           mainwindow.image1.Canvas.Pen.Color := clred;
           line(slope,intercept);//draw satellite streak
           mainwindow.image1.Canvas.pen.color:=clyellow;
         end;
       end;

     end;


begin
 if head.naxis=0 then exit; {file loaded?}
 Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

 img_bk:=img; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
 setlength(img_bk,head.naxis3,head.width,head.height);{force a duplication}

 oldNaxis3:=head.naxis3;//for case it is converted to mono

 if head.naxis3>1 then {colour image}
 begin
   img_bk:=img; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
   setlength(img_bk,head.naxis3,head.width,head.height);{force a duplication}
   convert_mono(img,head);
   get_hist(0,img);{get histogram of img and his_total. Required to get correct background value}

   restore_req:=true;
 end
 else
 if (bayerpat<>'') then {raw Bayer image}
 begin
   check_pattern_filter(img);
   restore_req:=true;
 end;

 w:=head.Width-1;
 h:=head.height-1;


 streak_lines:=nil;
 nr_streak_lines:=0;
 setlength(streak_lines,2,20);//allow 20 streak lines

 with mainwindow do
 begin
   Flipv:=mainwindow.flip_vertical1.Checked;
   Fliph:=mainwindow.Flip_horizontal1.Checked;


//    image1.Canvas.Pen.Mode := pmMerge;
//    image1.Canvas.Pen.Mode := pmNotXor;
   image1.Canvas.Pen.Mode := pmMerge;
   image1.Canvas.brush.Style:=bsClear;
   image1.Canvas.font.color:=clLime;
   image1.Canvas.Pen.Color := clred;
   image1.Canvas.Pen.width := round(1+head.height/image1.height);{thickness lines}
   fontsize:=round(max(10,8*head.height/image1.height));{adapt font to image dimensions}
   image1.Canvas.font.size:=fontsize;

   setlength(img_sa,1,head.width,head.height);{set length of image array}

   gaussian_blur2(img, blur);{apply gaussian blur }
  // get_hist(0,img);{get histogram of img and his_total. Required to get correct background value}
   get_background(0,img,{cblack=0} false{histogram is already available},true {calculate noise level},{out}bck);{calculate background level from peek histogram}

   detection_level:=sigmafactor*bck.noise_level;


   image1.Canvas.Pen.width :=image1.Canvas.Pen.width*2;{thickness lines}
   image1.Canvas.pen.color:=clyellow;

   for fitsY:=0 to head.height-1 do
     for fitsX:=0 to head.width-1  do
       img_sa[0,fitsX,fitsY]:=-1;{mark as star free area}


   for fitsY:=0 to head.height-1-1  do
   begin
     for fitsX:=0 to head.width-1-1 do
     begin
       if (( img_sa[0,fitsX,fitsY]<0){area not occupied by a shape}  and (img[0,fitsX,fitsY]- bck.backgr>detection_level){star}) then {new star}
       begin
         //mark_pixel(fitsX,fitsY);
         find_contour(fitsX,fitsY);

     //    exit;
      //   if fitsX=70-1 then
      //   if fitsY=34-1 then
      //   exit;
         if frac(fitsY/100)= 0 then
         begin
           application.processmessages;
           if esc_pressed then break;
         end;
       end;
     end;
   end;

//   memo2_message('Restoring image');
//   img:=nil;
//   img:=img_bk; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}

   if restore_req then {raw Bayer image or colour image}
   begin
     head.naxis3:=oldNaxis3;
     get_hist(0,img);{get histogram of img and his_total}
   end;

 end;{with mainwindow}
 img_sa:=nil;{free mem}
 Screen.Cursor:=crDefault;
end;


end.

