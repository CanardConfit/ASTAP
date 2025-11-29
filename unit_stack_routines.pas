unit unit_stack_routines;
{Copyright (C) 2017, 2024 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

{$mode delphi}
interface
uses
  Classes, SysUtils,forms, math, unit_stack, astap_main, unit_star_align,clipbrd;

procedure stack_LRGB( var files_to_process : array of TfileToDo; out counter : integer );{stack LRGB mode}
procedure stack_average(process_as_osc:integer; var files_to_process : array of TfileToDo; out counter : integer);{stack average}

procedure stack_mosaic(process_as_osc:integer; var files_to_process : array of TfileToDo; max_dev_backgr: double; out frame_counter : integer);{mosaic/tile mode}

procedure stack_sigmaclip(process_as_osc:integer; var files_to_process : array of TfileToDo; out counter : integer); {stack using sigma clip average}
procedure calibration_and_alignment(process_as_osc:integer; var files_to_process : array of TfileToDo; out counter : integer); {calibration_and_alignment only}

procedure astrometric_to_vector(headA, headB : theader);{convert astrometric solution to vector solution}
function test_bayer_matrix(img: Timage_array) :boolean;  {test statistical if image has a bayer matrix. Execution time about 1ms for 3040x2016 image}
procedure stack_comet(process_as_osc:integer; var files_to_process : array of TfileToDo; out counter : integer); {stack using sigma clip average}
procedure calc_newx_newy(headA, headB : theader; vector_based : boolean; fitsXfloat,fitsYfloat: double; out  x_new_float,  y_new_float : double); {apply either vector or astrometric correction. Fits in 1..width, out range 0..width-1}

var
  SIN_dec0,    // image to add
  COS_dec0,    // image to add
  SIN_dec2,    // reference image
  COS_dec2     : double;// reference image


implementation

uses unit_astrometric_solving, unit_contour,unit_threaded_stacking_step1,unit_threaded_stacking_step2,unit_threaded_stacking_step3,unit_threaded_mosaic;


procedure calc_newx_newy(headA, headB : theader; vector_based : boolean; fitsXfloat,fitsYfloat: double; out  x_new_float,  y_new_float : double); {apply either vector or astrometric correction. Fits in 1..width, out range 0..width-1}
var
  u,u0,v,v0,dRa,dDec,delta,ra_new,dec_new,delta_ra,det,gamma,SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,h  : double;
begin
  if vector_based then {vector based correction}
  begin
     x_new_float:=solution_vectorX[0]*(fitsxfloat-1)+solution_vectorX[1]*(fitsYfloat-1)+solution_vectorX[2]; {correction x:=aX+bY+c  x_new_float in image array range 0..headA.width-1}
     y_new_float:=solution_vectorY[0]*(fitsxfloat-1)+solution_vectorY[1]*(fitsYfloat-1)+solution_vectorY[2]; {correction y:=aX+bY+c}
  end
  else
  begin {astrometric based correction}
    {6. Conversion (x,y) -> (RA,DEC)  for image to be added}
    u0:=fitsXfloat-headA.crpix1;
    v0:=fitsYfloat-headA.crpix2;

    if a_order>=2 then {apply SIP correction up third order}
    begin
      u:=u0 + a_0_0+ a_0_1*v0 + a_0_2*v0*v0 + a_0_3*v0*v0*v0 + a_1_0*u0 + a_1_1*u0*v0 + a_1_2*u0*v0*v0 + a_2_0*u0*u0 + a_2_1*u0*u0*v0 + a_3_0*u0*u0*u0 ; {SIP correction for second or third order}
      v:=v0 + b_0_0+ b_0_1*v0 + b_0_2*v0*v0 + b_0_3*v0*v0*v0 + b_1_0*u0 + b_1_1*u0*v0 + b_1_2*u0*v0*v0 + b_2_0*u0*u0 + b_2_1*u0*u0*v0 + b_3_0*u0*u0*u0 ; {SIP correction for second or third order}
    end
    else
    begin
      u:=u0;
      v:=v0;
    end;

    if sin_dec0>999 then sincos(headA.dec0,SIN_dec0,COS_dec0);//Do this only once since it is for each pixel the same. Set sin_dec0=1000 in advance of a loop.

    dRa :=(headA.cd1_1 * u +headA.cd1_2 * v)*pi/180;
    dDec:=(headA.cd2_1 * u +headA.cd2_2 * v)*pi/180;
    delta:=COS_dec0 - dDec*SIN_dec0;
    gamma:=sqrt(dRa*dRa+delta*delta);
    RA_new:=headA.ra0+arctan(Dra/delta);
    DEC_new:=arctan((SIN_dec0+dDec*COS_dec0)/gamma);


   {5. Conversion (RA,DEC) -> (x,y) of reference image}
    sincos(dec_new,SIN_dec_new,COS_dec_new);
    if sin_dec2>999 then sincos(headB.dec0,SIN_dec2,COS_dec2); //Do this only once since it is for each pixel the same. Set sin_dec0=1000 in advance of a loop.

    delta_ra:=RA_new-headB.ra0;
    sincos(delta_ra,SIN_delta_ra,COS_delta_ra);

    H := SIN_dec_new*SIN_dec2 + COS_dec_new*COS_dec2*COS_delta_ra;
    dRA := (COS_dec_new*SIN_delta_ra / H)*180/pi;
    dDEC:= ((SIN_dec_new*COS_dec2 - COS_dec_new*SIN_dec2*COS_delta_ra ) / H)*180/pi;

    det:=headB.CD2_2*headB.CD1_1 - headB.CD1_2*headB.CD2_1;

    u0:= - (headB.CD1_2*dDEC - headB.CD2_2*dRA) / det;
    v0:= + (headB.CD1_1*dDEC - headB.CD2_1*dRA) / det;

    if ap_order>=2 then {apply SIP correction up to third order}
    begin
      x_new_float:=(headB.crpix1 + u0+ap_0_1*v0+ ap_0_2*v0*v0+ ap_0_3*v0*v0*v0 +ap_1_0*u0 + ap_1_1*u0*v0+  ap_1_2*u0*v0*v0+ ap_2_0*u0*u0 + ap_2_1*u0*u0*v0+  ap_3_0*u0*u0*u0)-1;{3th order SIP correction, fits count from 1, image from zero therefore subtract 1}
      y_new_float:=(headB.crpix2 + v0+bp_0_1*v0+ bp_0_2*v0*v0+ bp_0_3*v0*v0*v0 +bp_1_0*u0 + bp_1_1*u0*v0+  bp_1_2*u0*v0*v0+ bp_2_0*u0*u0 + bp_2_1*u0*u0*v0+  bp_3_0*u0*u0*u0)-1;{3th order SIP correction}
    end
    else
    begin
      x_new_float:=(headB.crpix1 + u0)-1; {in image array range 0..width-1}
      y_new_float:=(headB.crpix2 + v0)-1;
    end;
  end;{astrometric}
end;{calc_newx_newy}


procedure astrometric_to_vector(headA, headB : theader);{convert astrometric solution to vector solution}
var
  flipped,flipped_reference  : boolean;
  centerX,centerY            : double;
  x_new_float, y_new_float   : double;
begin
  a_order:=0; {SIP correction should be zero by definition}

  sin_dec0:=1000;sin_dec2:=1000;//force a recalculation of sin_dec and cos_dec values for the new image to process. Used in procedure calc_newx_newy

  calc_newx_newy(headA, headB,false,headA.crpix1, headA.crpix2,x_new_float, y_new_float) ;//this will only work well for 1th orde solutions
  centerX:=x_new_float;
  centerY:=y_new_float;

  calc_newx_newy(headA, headB, false,headA.crpix1+1, headA.crpix2,x_new_float, y_new_float); {move one pixel in X}

  solution_vectorX[0]:=+(x_new_float- centerX);
  solution_vectorX[1]:=-(y_new_float- centerY);

  calc_newx_newy(headA, headB, false,headA.crpix1, headA.crpix2+1,x_new_float, y_new_float);{move one pixel in Y}

  solution_vectorY[0]:=-(x_new_float- centerX);
  solution_vectorY[1]:=+(y_new_float- centerY);


  flipped:=headA.cd1_1*headA.cd2_2 - headA.cd1_2*headA.cd2_1>0; {Flipped image. Either flipped vertical or horizontal but not both. Flipped both horizontal and vertical is equal to 180 degrees rotation and is not seen as flipped}
  flipped_reference:=headB.cd1_1*headB.cd2_2 - headB.cd1_2*headB.cd2_1>0; {flipped reference image}

  if flipped<>flipped_reference then {this can happen is user try to add images from a diffent camera/setup}
  begin
    solution_vectorX[1]:=-solution_vectorX[1];
    solution_vectorY[0]:=-solution_vectorY[0];
  end;

  //  centerX:=solution_vectorX[0]*crpix1 + solution_vectorX[1]*crpix2 + solution_vectorX[2] therefore ==>
  //  solution_vectorX[2]:=centerX - solution_vectorX[0]*(crpix1-1) - solution_vectorX[1]*(crpix2-1)
  solution_vectorX[2]:=centerX - solution_vectorX[0]*(headA.crpix1-1) - solution_vectorX[1]*(headA.crpix2-1);//in range 0..width-1
  solution_vectorY[2]:=centerY - solution_vectorY[0]*(headA.crpix1-1) - solution_vectorY[1]*(headA.crpix2-1);

  if stackmenu1.solve_show_log1.checked then memo2_message('Astrometric vector solution '+solution_str)
end;


procedure calculate_manual_vector(c: integer); //calculate the vector drift for the image scale one and 0..h, 0..w range.
var
  ra1,dec1,x1,y1,shiftX,shiftY : double;
  dummy : string;
begin
  if head.cd1_1=0 then //pure manual stacking
  begin
    solution_vectorX[0]:=1;
    solution_vectorX[1]:=0;
    solution_vectorX[2]:=referenceX{-1}-(strtofloat2(stackmenu1.ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]){-1}); {calculate correction. The two subtractions are neutralizing each other}
    solution_vectorY[0]:=0;
    solution_vectorY[1]:=1;
    solution_vectorY[2]:=referenceY{-1} - (strtofloat2(stackmenu1.ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]){-1});//the two subtractions are neutralizing each other
  end
  else
  begin
//    sincos(head.dec0,SIN_dec0,COS_dec0);//intilialize SIN_dec0,COS_dec0
//    astrometric_to_vector(head,head_ref);{convert 1th order astrometric solution to a vector solution}
    astrometric_to_vector(head_ref,head);{convert 1th order astrometric solution to a vector solution}

    dummy:=stackmenu1.ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X];
    dummy:=stackmenu1.ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y];


    //convert the astroid position to ra, dec
    pixel_to_celestial(head,strtofloat2(stackmenu1.ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]),
                            strtofloat2(stackmenu1.ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]),1 {formalism},  ra1,dec1 );
    //calculate the astroid position to x,y coordinated of the reference image
    celestial_to_pixel(head_ref, ra1,dec1,true,x1,y1);//ra,dec  ref image to fitsX,fitsY second image


    //convert the center based solution to solution with origin at 0,0
    if solution_vectorX[0]<0  then
       solution_vectorX[2]:=solution_vectorX[2]+head.width-1;

    if solution_vectorY[1]<0  then
       solution_vectorY[2]:=solution_vectorY[2]+head.height-1;


    shiftX:=x1 {-1} - referenceX{-1}; //The asteroid correction. The two subtractions are neutralizing each other
    shiftY:=y1 {-1} - referenceY{-1}; //The asteroid correction. The two subtractions are neutralizing each other

    solution_vectorX[2]:=solution_vectorX[2]+shiftx;
    solution_vectorY[2]:=solution_vectorY[2]+shifty;
  end;
end;


procedure stack_LRGB(var files_to_process : array of TfileToDo; out counter : integer ); {LRGB method, files_to_process_LRGB should contain [REFERENCE, R,G,B,R2,G2,B2,L]}
var
  fitsX,fitsY,c,width_max, height_max, binning,max_stars,col,x_trunc,y_trunc  : integer;
  background_r, background_g, background_b, background_l,
  background_r2,background_g2,background_b2,
  rgbsum,red_f,green_f,blue_f, value ,colr, colg,colb, mean_hfd,
  rr_factor_1, rg_factor_1, rb_factor_1,
  gr_factor_1, gg_factor_1, gb_factor_1,
  br_factor_1, bg_factor_1, bb_factor_1,
  rr_factor_2, rg_factor_2, rb_factor_2,
  gr_factor_2, gg_factor_2, gb_factor_2,
  br_factor_2, bg_factor_2, bb_factor_2,
  saturated_level,hfd_min,tempval,tempval2,
  aa,bb,cc,dd,ee,ff,
  col1,col2,x_new,y_new,x_frac,y_frac                                                      : double;
  init, solution,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,use_sip : boolean;
  warning               : string;
  starlist1,starlist2   : Tstar_list;
  img_temp,img_average  : Timage_array;
begin
  with stackmenu1 do
  begin

    {move often used setting to booleans. Great speed improved if use in a loop and read many times}
    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometric_alignment1.checked;
    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}
    max_stars:=strtoint2(stackmenu1.max_stars1.text,500);{maximum star to process, if so filter out brightest stars later}
    use_sip:=stackmenu1.add_sip1.checked;

    counter:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_start_first:=1E99;{begin observations in Julian day}
    jd_end_last:=0;{end observations in Julian day}

    init:=false;

    {LRGB method}
    begin
      memo2_message('Combining colours.');
      rr_factor_1:=strtofloat2(rr1.text);
      rg_factor_1:=strtofloat2(rg1.text);
      rb_factor_1:=strtofloat2(rb1.text);

      gr_factor_1:=strtofloat2(gr1.text);
      gg_factor_1:=strtofloat2(gg1.text);
      gb_factor_1:=strtofloat2(gb1.text);

      br_factor_1:=strtofloat2(br1.text);
      bg_factor_1:=strtofloat2(bg1.text);
      bb_factor_1:=strtofloat2(bb1.text);

      rr_factor_2:=strtofloat2(rr2.text);
      rg_factor_2:=strtofloat2(rg2.text);
      rb_factor_2:=strtofloat2(rb2.text);

      gr_factor_2:=strtofloat2(gr2.text);
      gg_factor_2:=strtofloat2(gg2.text);
      gb_factor_2:=strtofloat2(gb2.text);

      br_factor_2:=strtofloat2(br2.text);
      bg_factor_2:=strtofloat2(bg2.text);
      bb_factor_2:=strtofloat2(bb2.text);

      background_r:=0;
      background_g:=0;
      background_b:=0;
      background_l:=0;

      counterR:=0;
      counterR2:=0;
      counterG:=0;
      counterG2:=0;
      counterB:=0;
      counterB2:=0;


      for c:=0 to length(files_to_process)-1 do  {should contain reference,r,g,b,r2,g2,b2,gb,l}
      begin
        if c=7 then {all colour files added, correct for the number of pixel values added at one pixel. This can also happen if one colour has an angle and two pixel fit in one!!}
        begin {fix RGB stack}
          memo2_message('Correcting the number of pixels added together.');
          for col:=0 to 5 do  //do 2 x 3colours
          begin
            if ((img_temp[col,height_max div 2 ,width_max div 2]>0) or (img_temp[col,(height_max div 2)+2,(width_max div 2) +2]>0) ) then //quick shortcut there is data
            begin
              for fitsY:=0 to height_max-1 do
              for fitsX:=0 to width_max-1 do
              begin
                tempval:=img_temp[col,fitsY,fitsX];
                if tempval>0 then //Note tempval>1 is very very rare. In 99.99% cases tempval is 1 and no more then one pixel combined. Seen more then one pixel only for astrometric stacking
                   img_average[col,fitsY,fitsX]:=500+img_average[col,fitsY,fitsX]/tempval {scale to one image by diving by the number of pixels added}
                 else
                 img_average[col,fitsY,fitsX]:=0;//This will set all colours of a single pixel to zero if one of the colour is saturated and marked by image_temp[]:=-9;
              end;
            end;
          end;
          memo2_message('Applying black spot filter on the interim RRGGBB image.');
          black_spot_filter_for_aligned(img_average); //Black spot filter for 6 colour, 2 rgb

          //combine the 2 x RGB
          for col:=0 to 2 do
            if
            (
            ((img_temp[col  ,height_max div 2 ,width_max div 2]>0) or (img_temp[col  ,(height_max div 2)+2,(width_max div 2)+2]>0)) and
            ((img_temp[col+3,height_max div 2 ,width_max div 2]>0) or (img_temp[col+3,(height_max div 2)  ,(width_max div 2)+2]>0)) //check at two places to avoid black spot
             ) then //there is twice RGB data
            begin
              for fitsY:=0 to height_max-1 do
                for fitsX:=0 to width_max-1 do
                begin
                  img_average[col,fitsY,fitsX]:= img_average[col,fitsY,fitsX]+ img_average[col+3,fitsY,fitsX]-500;
                end;
            end
            else
            begin
              if ((img_temp[col,height_max div 2 ,width_max div 2]=0) and (img_temp[col+3,height_max div 2 ,width_max div 2]>0)) then //only second RGB data
              for fitsY:=0 to height_max-1 do
                for fitsX:=0 to width_max-1 do
                  img_average[col,fitsY,fitsX]:= img_average[col+3,fitsY,fitsX];
            end;
            //else nothing to do  only first contains RGB data
            setlength(img_average,3,height_max,width_max);{throw away second RGB storage space}
        end;{c=7, all colour files added}

        if length(files_to_process[c].name)>0 then // file available
        begin
          try { Do some lengthy operation }
            filename2:=files_to_process[c].name;
            if c=0 then memo2_message('Loading reference image: "'+filename2+'".');
            if c=1 then memo2_message('Adding red1 file: "'+filename2+'"  to final image.');
            if c=2 then memo2_message('Adding green1 file: "'+filename2+'"  to final image.');
            if c=3 then memo2_message('Adding blue1 file: "'+filename2+'"  to final image.');
            if c=4 then memo2_message('Adding red2 file: "'+filename2+'"  to final image.');
            if c=5 then memo2_message('Adding green2 file: "'+filename2+'"  to final image.');
            if c=6 then memo2_message('Adding blue2 file: "'+filename2+'"  to final image.');
            if c=7 then memo2_message('Using luminance file: "'+filename2+'"  for final image.');

            {load image}
            Application.ProcessMessages;
            if esc_pressed then begin memo2_message('ESC pressed.');exit;end;
            if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainform1.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;

            if init=false then
              head_ref:=head;{backup solution}

            if use_sip=false then a_order:=0; //stop using SIP from the header in astrometric mode
            saturated_level:=head.datamax_org*0.97;{130}

            if c=1 then
            begin
               get_background(0,img_loaded,head,true,false);{unknown, do not calculate noise_level}
               background_r:=head.backgr;
               //cblack:=round( background_r);
               counterR:=head.light_count ;counterRdark:=head.dark_count; counterRflat:=head.flat_count; counterRbias:=head.flatdark_count; exposureR:=round(head.exposure);temperatureR:=head.set_temperature;{for historical reasons}
            end;
            if c=2 then
            begin
              get_background(0,img_loaded,head,true,false);{unknown, do not calculate noise_level}
              background_g:=head.backgr;
              //cblack:=round( background_g);
              counterG:=head.light_count;counterGdark:=head.dark_count; counterGflat:=head.flat_count; counterGbias:=head.flatdark_count; exposureG:=round(head.exposure);temperatureG:=head.set_temperature;
            end;
            if c=3 then
            begin
              get_background(0,img_loaded,head,true,false);{unknown, do not calculate noise_level}
              background_b:=head.backgr;
              //cblack:=round( background_b);
              counterB:=head.light_count; counterBdark:=head.dark_count; counterBflat:=head.flat_count; counterBbias:=head.flatdark_count; exposureB:=round(head.exposure);temperatureB:=head.set_temperature;
            end;
            if c=4 then
            begin
               get_background(0,img_loaded,head,true,false);{unknown, do not calculate noise_level}
               background_r2:=head.backgr;
               //cblack:=round( background_r);
               counterR2:=head.light_count ;counterR2dark:=head.dark_count; counterR2flat:=head.flat_count; counterR2bias:=head.flatdark_count; exposureR2:=round(head.exposure);temperatureR2:=head.set_temperature;{for historical reasons}
            end;
            if c=5 then
            begin
              get_background(0,img_loaded,head,true,false);{unknown, do not calculate noise_level}
              background_g2:=head.backgr;
              //cblack:=round( background_g);
              counterG2:=head.light_count;counterG2dark:=head.dark_count; counterG2flat:=head.flat_count; counterG2bias:=head.flatdark_count; exposureG2:=round(head.exposure);temperatureG2:=head.set_temperature;
            end;
            if c=6 then
            begin
              get_background(0,img_loaded,head,true,false);{unknown, do not calculate noise_level}
              background_b2:=head.backgr;
              //cblack:=round( background_b);
              counterB2:=head.light_count; counterB2dark:=head.dark_count; counterB2flat:=head.flat_count; counterB2bias:=head.flatdark_count; exposureB2:=round(head.exposure);temperatureB2:=head.set_temperature;
            end;

            if c=7 then {Luminance}
            begin
              get_background(0,img_loaded,head,true,false);{unknown, do not calculate noise_level}
              background_L:=head.backgr;
              //cblack:=round( background_L);
              counterL:=head.light_count; counterLdark:=head.dark_count; counterLflat:=head.flat_count; counterLbias:=head.flatdark_count; exposureL:=round(head.exposure);temperatureL:=head.set_temperature;
            end;

            if use_astrometry_internal then {internal solver, create new solutions for the R, G, B and L stacked images if required}
            begin
              memo2_message('Preparing astrometric solution for interim file: '+filename2);
              if head.cd1_1=0 then solution:= update_solution_and_save(img_loaded,head,mainform1.memo1.lines) else solution:=true;
              if solution=false {load astrometry.net solution succesfull} then begin memo2_message('Abort, No astrometric solution for '+filename2); exit;end;{no solution found}
            end
            else
            if init=false then {first image}
            begin
              if ((use_manual_align) or (use_ephemeris_alignment)) then
              begin
                referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
                referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
              end
              else
              begin
                binning:=report_binning(head.height);{select binning based on the height of the light}
                bin_and_find_stars(img_loaded,head, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist2,mean_hfd,warning);{bin, measure background, find stars}
                max_stars:=length(starlist2[0]); //adapt max_stars to reference image
                find_quads(false,length(starlist2[0]),starlist2,quad_star_distances2);{find quads for reference image/database}
              end;
            end;

            if init=false then {init}
            begin
              height_max:=head.height;
              width_max:=head.width;

              setlength(img_average,6,height_max,width_max);{2 x 3 colours}
              setlength(img_temp,6,height_max,width_max);   {2 x 3 colours}

              for fitsY:=0 to height_max-1 do
                for fitsX:=0 to width_max-1 do
                  for col:=0 to 2+3 do //rgb x 2 is 6 colours
                  begin
                    img_average[col,fitsY,fitsX]:=0; //clear img_average
                    img_temp[col,fitsY,fitsX]:=0;//clear counter
                  end;
            end;{init, c=0}

            solution:=true;{assume solution is found}
            if use_astrometry_internal then sincos(head.dec0,SIN_dec0,COS_dec0) {do this in advance since it is for each pixel the same}
            else
            begin {align using star match}
              if init=true then {second image}
              begin
                if ((use_manual_align) or (use_ephemeris_alignment)) then
                begin {manual alignment}
                  calculate_manual_vector(c);//includes memo2_message with solution vector
                end
                else
                begin{internal alignment}
                  bin_and_find_stars(img_loaded,head, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist1,mean_hfd,warning);{bin, measure background, find stars}
                  find_quads(false,length(starlist2[0]),starlist1,quad_star_distances1);{find star quads for new image}
                  if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then //Find the solution for inverse mapping. So from reference image to each new source image
                    memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.  ' +solution_str)
                  else
                  begin
                    memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
                    files_to_process[c].name:=''; {remove file from list}
                   solution:=false;
                    ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[L_result]:=6;{mark 3th column with exclaimation}
                    ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_result]:='No match';{no stack result}
                  end;
                end;{internal alignment}
              end
              else
              reset_solution_vectors(1);{no influence on the first image}

            end;{using star match}
            init:=true;{initialize for first image done}
            if ((c<>0) and (solution)) then  {do not add reference channel c=0, in most case luminance file.}
            begin
              inc(counter);{count number of colour files involved}
              //Julian days are  -- NOT ---  calculated in apply_dark_and_flat as in the other routines
              date_to_jd(head.date_obs,head.date_avg,head.exposure);{convert head.date_obs string and head.exposure time to global variables jd_start (julian day start head.exposure) and jd_mid (julian day middle of the head.exposure)}
              jd_start_first:=min(jd_start,jd_start_first);{find the begin date}
              jd_end_last:=max(jd_end,jd_end_last);{find latest end time}
              jd_sum:=jd_sum+jd_mid;{sum julian days of images at midpoint exposure}

              if use_astrometry_internal then
                astrometric_to_vector(head_ref,head);{convert 1th order astrometric solution to vector solution}


              aa:=solution_vectorX[0];//move to local variable for minor faster processing
              bb:=solution_vectorX[1];
              cc:=solution_vectorX[2];
              dd:=solution_vectorY[0];
              ee:=solution_vectorY[1];
              ff:=solution_vectorY[2];



              for fitsY:=0 to head.height-1 do //cycle in reference image dimensions and find source pixel
              for fitsX:=0 to head.width-1 do
              begin
                // Inverse Mapping (a.k.a. Backward Mapping) Instead of mapping source → destination (forward), you loop over destination pixels and figure out where they came from in the original image
                // This procedure is using reverse mapping. So the transfer function from destination to source image is known. See e.g. https://www.cs.princeton.edu/courses/archive/spr11/cos426/notes/cos426_s11_lecture03_warping.pdf
                x_new:=aa*fitsx+bb*fitsY+cc; {correction x:=aX+bY+c  result in image array range 0..head.width-1}
                y_new:=dd*fitsx+ee*fitsY+ff; {correction y:=aX+bY+c}

                x_trunc:=trunc(x_new);
                y_trunc:=trunc(y_new);
                if ((x_trunc>0) and (x_trunc<width_max-1) and (y_trunc>0) and (y_trunc<height_max-1)) then
                begin
                  x_frac :=frac(x_new);
                  y_frac :=frac(y_new);

                  // Resample the source image
                  // Bilinearly interpolate four closest pixels of the source
                  value:=        (img_loaded[0,y_trunc  ,x_trunc  ]) * (1-x_frac)*(1-y_frac);{pixel left top,    1}
                  value:=value + (img_loaded[0,y_trunc  ,x_trunc+1]) * (  x_frac)*(1-y_frac);{pixel right top,   2}
                  value:=value + (img_loaded[0,y_trunc+1,x_trunc  ]) * (1-x_frac)*(  y_frac);{pixel left bottom, 3}
                  value:=value + (img_loaded[0,y_trunc+1,x_trunc+1]) * (  x_frac)*(  y_frac);{pixel right bottom,4}

                  if value>saturated_level then {saturation, mark all three colors as black spot (<=0) to maintain star colour}
                  begin
                    for col:=0 to 2+3 do
                      img_temp[col,fitsY,fitsX]:=-9;//mark all colours as saturated if one colour is saturated.
                  end
                  else
                  begin //not saturated
                    if c=1 {red} then
                    begin
                      value:=(value-background_r);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if rr_factor_1>0.00001 then begin img_average[0,fitsY,fitsX]:=img_average[0,fitsY,fitsX] + rr_factor_1*value;{execute only if greater then zero for speed}img_temp[0,fitsY,fitsX]:=img_temp[0,fitsY,fitsX]+1; end;
                      if rg_factor_1>0.00001 then begin img_average[1,fitsY,fitsX]:=img_average[1,fitsY,fitsX] + rg_factor_1*value; img_temp[1,fitsY,fitsX]:=img_temp[1,fitsY,fitsX]+1; end;
                      if rb_factor_1>0.00001 then begin img_average[2,fitsY,fitsX]:=img_average[2,fitsY,fitsX] + rb_factor_1*value; img_temp[2,fitsY,fitsX]:=img_temp[2,fitsY,fitsX]+1; end;
                    end;
                    if c=2 {green} then
                    begin
                      value:=(value-background_g);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if gr_factor_1>0.00001 then begin img_average[0,fitsY,fitsX]:=img_average[0,fitsY,fitsX] + gr_factor_1*value;{execute only if greater then zero for speed}img_temp[0,fitsY,fitsX]:=img_temp[0,fitsY,fitsX]+1;  end;
                      if gg_factor_1>0.00001 then begin img_average[1,fitsY,fitsX]:=img_average[1,fitsY,fitsX] + gg_factor_1*value;img_temp[1,fitsY,fitsX]:=img_temp[1,fitsY,fitsX]+1; end;
                      if gb_factor_1>0.00001 then begin img_average[2,fitsY,fitsX]:=img_average[2,fitsY,fitsX] + gb_factor_1*value;img_temp[2,fitsY,fitsX]:=img_temp[2,fitsY,fitsX]+1; end;
                    end;
                    if c=3 {blue}  then
                    begin
                      value:=(value-background_b);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if br_factor_1>0.00001 then begin img_average[0,fitsY,fitsX]:=img_average[0,fitsY,fitsX] + br_factor_1*value;{execute only if greater then zero for speed}img_temp[0,fitsY,fitsX]:=img_temp[0,fitsY,fitsX]+1;  end;
                      if bg_factor_1>0.00001 then begin img_average[1,fitsY,fitsX]:=img_average[1,fitsY,fitsX] + bg_factor_1*value; img_temp[1,fitsY,fitsX]:=img_temp[1,fitsY,fitsX]+1;end;
                      if bb_factor_1>0.00001 then begin img_average[2,fitsY,fitsX]:=img_average[2,fitsY,fitsX] + bb_factor_1*value; img_temp[2,fitsY,fitsX]:=img_temp[2,fitsY,fitsX]+1;end;
                    end;

                    if c=4 {red2} then
                    begin
                      value:=(value-background_r2);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if rr_factor_2>0.00001 then begin img_average[0+3,fitsY,fitsX]:=img_average[0+3,fitsY,fitsX] + rr_factor_2*value;{execute only if greater then zero for speed}img_temp[0+3,fitsY,fitsX]:=img_temp[0+3,fitsY,fitsX]+1; end;
                      if rg_factor_2>0.00001 then begin img_average[1+3,fitsY,fitsX]:=img_average[1+3,fitsY,fitsX] + rg_factor_2*value; img_temp[1+3,fitsY,fitsX]:=img_temp[1+3,fitsY,fitsX]+1; end;
                      if rb_factor_2>0.00001 then begin img_average[2+3,fitsY,fitsX]:=img_average[2+3,fitsY,fitsX] + rb_factor_2*value; img_temp[2+3,fitsY,fitsX]:=img_temp[2+3,fitsY,fitsX]+1; end;
                    end;
                    if c=5 {green3} then
                    begin
                      value:=(value-background_g2);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if gr_factor_2>0.00001 then begin img_average[0+3,fitsY,fitsX]:=img_average[0+3,fitsY,fitsX] + gr_factor_2*value;{execute only if greater then zero for speed}img_temp[0+3,fitsY,fitsX]:=img_temp[0+3,fitsY,fitsX]+1;  end;
                      if gg_factor_2>0.00001 then begin img_average[1+3,fitsY,fitsX]:=img_average[1+3,fitsY,fitsX] + gg_factor_2*value;img_temp[1+3,fitsY,fitsX]:=img_temp[1+3,fitsY,fitsX]+1; end;
                      if gb_factor_2>0.00001 then begin img_average[2+3,fitsY,fitsX]:=img_average[2+3,fitsY,fitsX] + gb_factor_2*value;img_temp[2+3,fitsY,fitsX]:=img_temp[2+3,fitsY,fitsX]+1; end;
                    end;
                    if c=6 {blue2}  then
                    begin
                      value:=(value-background_b2);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if br_factor_2>0.00001 then begin img_average[0+3,fitsY,fitsX]:=img_average[0+3,fitsY,fitsX] + br_factor_2*value;{execute only if greater then zero for speed}img_temp[0+3,fitsY,fitsX]:=img_temp[0+3,fitsY,fitsX]+1;  end;
                      if bg_factor_2>0.00001 then begin img_average[1+3,fitsY,fitsX]:=img_average[1+3,fitsY,fitsX] + bg_factor_2*value; img_temp[1+3,fitsY,fitsX]:=img_temp[1+3,fitsY,fitsX]+1;end;
                      if bb_factor_2>0.00001 then begin img_average[2+3,fitsY,fitsX]:=img_average[2+3,fitsY,fitsX] + bb_factor_2*value; img_temp[2+3,fitsY,fitsX]:=img_temp[2+3,fitsY,fitsX]+1;end;
                    end;
                  end;//not saturated

                  if c=7 {Luminance} then
                  begin
                    {r:=l* r/(r+g+b)}

                    colr:=img_average[0,fitsY,fitsX] - 475; {lowest_most_common is around 450 to 500}
                    colg:=img_average[1,fitsY,fitsX] - 475;
                    colb:=img_average[2,fitsY,fitsX] - 475;

                    rgbsum:=colr+colg+colb;
                    if rgbsum<0.1 then begin rgbsum:=0.1; red_f:=rgbsum/3; green_f:=red_f; blue_f:=red_f;end
                    else
                    begin
                      red_f:=colr/rgbsum;   if red_f<0   then red_f:=0;  if red_f>1 then   red_f:=1;
                      green_f:=colg/rgbsum; if green_f<0 then green_f:=0;if green_f>1 then green_f:=1;
                      blue_f:=colb/rgbsum;  if blue_f<0  then blue_f:=0; if blue_f>1 then  blue_f:=1;
                    end;

                    img_average[0,fitsY,fitsX]:=1000+(value - background_l)*(red_f);
                    img_average[1,fitsY,fitsX]:=1000+(value - background_l)*(green_f);
                    img_average[2,fitsY,fitsX]:=1000+(value - background_l)*(blue_f);
                  end;
                end;
              end;//for fits:=0 ....
            end;

            progress_indicator(0.94+c/100,' LRGB');{show progress, 95..99%}
            except
              beep;
          end;{try}
        end;
      end;
      if counter<>0 then
      begin
        head:=head_ref; {restore solution. Works only if no oversize is used}
        head.naxis3:=3;{three colours}
        head.naxis :=3;{three dimensions. Header will be updated in the save routine}
        img_loaded:=img_average;
        head.width:=width_max;
        head.height:=height_max;
        sum_exp:=exposureR+exposureG+exposureG+exposureL+exposureRGB;
      end;
    end;{LRGB}
  end;{with stackmenu1}
end;


function test_bayer_matrix(img: Timage_array) :boolean;  {test statistical if image has a bayer matrix. Execution time about 1ms for 3040x2016 image}
var
  fitsX,w,h,middleY,step_size       : integer;
  p11,p12,p21,p22                   : array of double;
  m11,m12,m21,m22,lowest,highest    : double;
const
  steps=100;
begin
  //  colors:=Length(img); {colors}
  w:=Length(img[0,0]);    {width}
  h:=Length(img[0]); {height}

  middleY:=h div 2;
  step_size:=w div steps;
  if odd(step_size) then step_size:=step_size-1;{make even so it ends up at the correct location of the 2x2 matrix}

  SetLength(p11,steps);
  SetLength(p12,steps);
  SetLength(p21,steps);
  SetLength(p22,steps);

  for fitsX:=0 to steps-1   do  {test one horizontal line and take 100 samples of the bayer matrix}
  begin
    p11[fitsX]:=img[0,middleY,step_size*fitsX];
    p12[fitsX]:=img[0,middleY,step_size*fitsX+1];
    p21[fitsX]:=img[0,middleY+1,step_size*fitsX];
    p22[fitsX]:=img[0,middleY+1,step_size*fitsX+1];
  end;

  m11:=Smedian(p11,steps);
  m12:=Smedian(p12,steps);
  m21:=Smedian(p21,steps);
  m22:=Smedian(p22,steps);
  lowest:=min(min(m11,m12),min(m21,m22));
  highest:=max(max(m11,m12),max(m21,m22));

  result:=highest-lowest>100;

  p11:=nil;
  p12:=nil;
  p21:=nil;
  p22:=nil;
end;


function calc_weightF: double; {calculate weighting factor for different exposure duration and gain}
var
  gain1,gain2 : double;
begin
  if head.exposure<>0 then result:=head.exposure/head_ref.exposure else result:=1;{influence of each image depending on the exposure_time}

  if head.egain<>head_ref.egain then {rare}
  begin  {check egain}
    gain1:=strtofloat1(head_ref.egain);
    gain2:=strtofloat1(head.egain);
    if gain1<>0 then
        result:=result*gain2/gain1; {-e/adu}
    if abs(gain2-gain1)>0.01 then //warn only if there is a large egain difference
      memo2_message('█ █ █ █ █ █ Warning light with different EGAIN!! '+copy(head.egain,1,5)+' ínstead of '+copy(head_ref.egain,1,5)+' [e-/ADU]. Will try to compensate accordingly. █ █ █ █ █ █');
  end
  else
  begin  {check gain/iso}
    if head.gain<>head_ref.gain then {rare}
      memo2_message('█ █ █ █ █ █ Warning light with different GAIN!! '+head.gain+' ínstead of '+head_ref.gain+'. Can not compensate unless EGAIN [e-/ADU] is added manually to header. █ █ █ █ █ █');
  end;
end;

procedure compensate_solar_drift(head : theader; var solution_vectorX,solution_vectorY : Tsolution_vector);//compendate movement solar objects
var
  ra_movement,dec_movement,posX,posY,SIN_dec_ref,COS_dec_ref : double;
begin
  ra_movement:=(jd_mid-jd_mid_reference)*strtofloat2(stackmenu1.solar_drift_ra1.text {arcsec/hour})*(pi/180)*24/3600;//ra movement in radians

  sincos(head.dec0,SIN_dec_ref,COS_dec_ref);
  ra_movement:=ra_movement/COS_dec_ref;//convert angular distance to ra distance
  dec_movement:=(jd_mid-jd_mid_reference)*strtofloat2(stackmenu1.solar_drift_dec1.text {arcsec/hour})*(pi/180)*24/3600;//dec movement in radians

  celestial_to_pixel(head,head.ra0 + ra_movement,head.dec0 + dec_movement,true, posX,posY); //calculate drift of center of image by asteroid
  if sign(head_ref.cd1_1)<>sign(head.cd1_1) then
     solution_vectorX[2]:=solution_vectorX[2]-(head.crpix1-posX)//correct for asteroid movement
  else
     solution_vectorX[2]:=solution_vectorX[2]+(head.crpix1-posX);//correct for asteroid movement

  if sign(head_ref.cd2_2)<>sign(head.cd2_2) then
    solution_vectorY[2]:=solution_vectorY[2]-(head.crpix2-posY) //correct for asteroid movement
  else
    solution_vectorY[2]:=solution_vectorY[2]+(head.crpix2-posY);//correct for asteroid movement
end;


procedure calculate_required_dimensions(head_ref,head: theader; var x_min,x_max,y_min,y_max: double);//for image stitching mode
var
  ra,dec,x,y : double;
  formalism : integer;
begin
//  formalism:=mainform1.Polynomial1.itemindex;
  formalism:=0;
  pixel_to_celestial(head,1,1,formalism , ra, dec); //left bottom
  celestial_to_pixel(head_ref, ra,dec,false, x,y);//ra,dec to fitsX,fitsY. Do not use SIP to prevent very large errors outside the image.
  x_min:=min(x_min,x);
  x_max:=max(x_max,x);
  y_min:=min(y_min,y);
  y_max:=max(y_max,y);
  pixel_to_celestial(head,head.width,1,formalism , ra, dec);  //right bottom
  celestial_to_pixel(head_ref, ra,dec,false, x,y);//ra,dec to fitsX,fitsY. Do not use SIP to prevent very large errors outside the image.
  x_min:=min(x_min,x);
  x_max:=max(x_max,x);
  y_min:=min(y_min,y);
  y_max:=max(y_max,y);
  pixel_to_celestial(head,1,head.height,formalism , ra, dec); //left top
  celestial_to_pixel(head_ref, ra,dec,false, x,y);//ra,dec to fitsX,fitsY. Do not use SIP to prevent very large errors outside the image.
  x_min:=min(x_min,x);
  x_max:=max(x_max,x);
  y_min:=min(y_min,y);
  y_max:=max(y_max,y);
  pixel_to_celestial(head,head.width,head.height,formalism, ra, dec); //right top
  celestial_to_pixel(head_ref, ra,dec,false, x,y);//ra,dec to fitsX,fitsY. Do not use SIP to prevent very large errors outside the image.
  x_min:=min(x_min,x);
  x_max:=max(x_max,x);
  y_min:=min(y_min,y);
  y_max:=max(y_max,y);
end;


function minimum_distance_borders(fitsX,fitsY,w,h: integer): single;
begin
  result:=min(fitsX,w-fitsX);
  result:=min(fitsY,result);
  result:=min(h-fitsY,result);
end;


procedure stack_mosaic(process_as_osc:integer; var files_to_process : array of TfileToDo; max_dev_backgr: double; out frame_counter : integer);{mosaic/tile mode}
var
    fitsX,fitsY,c,width_max, height_max,x_new,y_new,col, cropW,cropH,iterations,greylevels,nrframes,formalism   : integer;
    value, dummy,median,median2,delta_median,correction,maxlevel,mean,noise,hotpixels,coverage,
    raMiddle,decMiddle,  x_min,x_max,y_min,y_max,total_fov,fw,fh     : double; //for mosaic
    x_new_float, y_new_float : double;
    tempval                                                          : single;
    init, vector_based,merge_overlap,equalise_background             : boolean;
    background_correction,background_correction_center,background    : array[0..2] of double;
    counter_overlap                                                  : array[0..2] of integer;
    bck                                                              : array[0..3] of double;
    img_temp,img_average : Timage_array;

begin
  with stackmenu1 do
  begin
    //find dimensions of this package
    memo2_message('Analysing and calculating celestial field-of-view dimensions.');
    x_min:=0;//for mosaic mode
    x_max:=0;
    y_min:=0;
    y_max:=0;
    formalism:=1;//Force use of SIP    mainform1.Polynomial1.itemindex;

    nrframes:=0;
    total_fov:=0;
    init:=false;

    for c:=0 to length(files_to_process)-1 do
      if length(files_to_process[c].name)>0 then
      begin
        if load_fits(files_to_process[c].name,true {light},false{load data},false {update memo} ,0,mainform1.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;

        if init=false then
        begin
          head_ref:=head;{backup solution}
          init:=true;
        end;

        calculate_required_dimensions(head_ref,head, x_min,x_max,y_min,y_max);
        total_fov:=total_fov+head.cdelt1*head.cdelt2*head.width*head.height;
        inc(nrframes);
      end;

    if abs(x_max-x_min)<1 then begin memo2_message('Abort. Failed to calculate mosaic dimensions!');exit;end;

    {move often used setting to booleans. Great speed improved if use in a loop and read many times}
    merge_overlap:=merge_overlap1.checked;
    Equalise_background:=Equalise_background1.checked;
    frame_counter:=0;
    sum_exp:=0;
    sum_temp:=0;
    init:=false;
    dummy:=0;

    for c:=0 to length(files_to_process)-1 do
    if length(files_to_process[c].name)>0 then
    begin

      try { Do some lengthy operation }
        ListView1.Selected :=nil; {remove any selection}
        ListView1.ItemIndex := files_to_process[c].listviewindex;{show wich file is processed}
        Listview1.Items[files_to_process[c].listviewindex].MakeVisible(False);{scroll to selected item}

        filename2:=files_to_process[c].name;

        Application.ProcessMessages;

        {load image}
        if esc_pressed then begin memo2_message('ESC pressed.');exit;end;
        if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainform1.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;

        if init=true then
        begin
           // not for mosaic||| if init=true then   if ((old_width<>head.width) or (old_height<>head.height)) then memo2_message('█ █ █ █ █ █  Warning different size image!');
           if head.naxis3>length(img_average) {head.naxis3} then begin memo2_message('█ █ █ █ █ █  Abort!! Can'+#39+'t combine mono and colour files.'); exit;end;
        end;

        if init=false then
        begin
          head_ref:=head;{backup solution}

          fw:=head.cdelt1*abs(x_max-x_min);
          fh:=head.cdelt2*abs(y_max-y_min);
          coverage:=total_fov/(fw*fh);
          if coverage<0.5 then
           begin memo2_message('█ █ █ █ █ █  Abort!! Too many missing tiles. Field is '+floattostrF(fw,FFFixed,0,1)+'x'+floattostrF(fh,FFfixed,0,1)+
                                              '°. Coverage only '+floattostrF(coverage*100,FFfixed,0,1)+ '%. Is there in outlier in the image list? Check image α, δ positions. For multiple mosaics is classify on "Light object" set?'); exit;end;

          pixel_to_celestial(head,(x_min+x_max)/2,(y_min+y_max)/2,formalism, raMiddle, decMiddle);//find middle of mosaic
          //sincos(decMiddle,SIN_dec_ref,COS_dec_ref);// as procedure initalise_var1, set middle of the mosaic

          head_ref.ra0:=raMiddle;// set middle of the mosaic
          head_ref.dec0:=decMiddle;// set middle of the mosaic
          head_ref.crpix1:=abs(x_max-x_min)/2;
          head_ref.crpix2:=abs(y_max-y_min)/2;


          width_max:=abs(round(x_max-x_min));
          height_max:=abs(round(y_max-y_min));

          setlength(img_average,head.naxis3,height_max,width_max);
          setlength(img_temp,1,height_max,width_max);{gray}

          for fitsY:=0 to height_max-1 do
            for fitsX:=0 to width_max-1 do
            begin
              for col:=0 to head.naxis3-1 do
              begin
                img_average[col,fitsY,fitsX]:=0; {clear img_average}
              end;
              img_temp[0,fitsY,fitsX]:=0; {clear img_temp}
            end;
        end;

        memo2_message('Adding file: '+inttostr(frame_counter+1)+'-'+nr_selected1.caption+' "'+filename2+'"  to mosaic.');     // Using '+inttostr(dark_count)+' dark(s), '+inttostr(flat_count)+' flat(s), '+inttostr(flatdark_count)+' flat-dark(s)') ;
        if a_order=0 then Memo2_message('█ █ █ █ █ █  Warning. Image distortion correction is not working. SIP terms are not in the image header. Refresh astrometrical solutions with SIP option check marked!! █ █ █ █ █ █');

        Application.ProcessMessages;
        if esc_pressed then exit;


        if process_as_osc>0 then {do demosaic bayer}
        begin
          if head.naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
          else
             demosaic_bayer(img_loaded); {convert OSC image to colour}
            {head.naxis3 is now 3}
        end;

        vector_based:=false;
        sin_dec0:=1000;sin_dec2:=1000;//force a recalculation of sin_dec and cos_dec values for the new image to process. Used in procedure calc_newx_newy.

        if a_order=0 then //no SIP from astronomy.net
        begin
          astrometric_to_vector(head,head_ref);//convert astrometric solution to vector solution
          vector_based:=true;
        end
        else
          sin_dec0:=1000;sin_dec2:=1000;//force a recalculation of sin_dec and cos_dec values for the new image to process. Used in procedure calc_newx_newy
        ap_order:=0;// don't correct for RA to XY for mosaic !!!

        //In prcedure mosaic_loops_threaded the img_loaded is placed on the large canvas img_average using the astrometric solution.
        //So img_loaded x,y -> ra,dec and then ra,dec -> x,y of img_average using calc_newx_newy. Img_average is distortion free so SIP ap_order is set to zero.
        //This procedure mosaic_loops_threaded is called for each img_loaded till all images are stitched on img_average.
        mosaic_loops_threaded(head,head_ref,img_loaded,img_average,img_temp, stackmenu1.mosaic_crop1.Position,frame_counter,nrframes{for progress calc}, max_dev_backgr, init,vector_based, equalise_background,merge_overlap);

        application.processmessages;
        if esc_pressed then exit;

        init:=true;
        inc(frame_counter);
        sum_exp:=sum_exp+head.exposure;
        sum_temp:=sum_temp+head.set_temperature;


      finally
      end;
    end;//loop through the files

    if frame_counter<>0 then
    begin
      head_ref.naxis3:= head.naxis3; {store colour info in reference header. could be modified by OSC conversion}
      head_ref.naxis:=  head.naxis;  {store colour info in reference header}
      head:=head_ref;{restore solution variable of reference image for annotation and mount pointer. Works only if not resized}
      head.height:=height_max;
      head.width:=width_max;
      setlength(img_loaded,head.naxis3,head.height,head.width);{new size}

      For fitsY:=0 to head.height-1 do
      for fitsX:=0 to head.width-1 do
      begin {pixel loop}
        tempval:=img_temp[0,fitsY,fitsX]; {if <>0 then something was written}
        for col:=0 to head.naxis3-1 do
        begin {colour loop}
          if tempval<>0 then img_loaded[col,fitsY,fitsX]:=img_average[col,fitsY,fitsX] {no divide}
          else
          begin { black spot filter or missing value filter due to image rotation}
            if ((fitsX>0) and (img_temp[0,fitsY,fitsX-1]<>0)) then img_loaded[col,fitsY,fitsX]:=img_loaded[col,fitsY,fitsX-1]{take nearest pixel x-1 as replacement}
            else
            if ((fitsY>0) and (img_temp[0,fitsY-1,fitsX]<>0)) then img_loaded[col,fitsY,fitsX]:=img_loaded[col,fitsY-1,fitsX]{take nearest pixel y-1 as replacement}
            else
            img_loaded[col,fitsY,fitsX]:=0;{clear img_loaded since it is resized}
          end; {black spot}
        end;{colour loop}
      end;{pixel loop}
    end; {frame_counter<>0}

  end;{with stackmenu1}
  {arrays will be nilled later. This is done for early exits}

  a_order:=0;
end;


procedure stack_average(process_as_osc :integer; var files_to_process : array of TfileToDo; out counter : integer);{stack average}
var
    fitsX,fitsY,c,width_max, height_max,old_width, old_height,x_new,y_new,col,binning,max_stars,old_naxis3,mm,ccc                  : integer;
    background, weightF,hfd_min,aa,bb,cc,dd,ee,ff,pedestal,dummy,mean_hfd                                                      : double;
    init, solution,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,use_sip,solar_drift_compensation,
    use_star_alignment                                                                                                         : boolean;
    tempval                                                                                                                    : single;
    warning             : string;
    starlist1,starlist2 : Tstar_list;
    img_temp,img_average,img_early,dummy_img : Timage_array;

    val:single;

begin
  with stackmenu1 do
  begin
    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometric_alignment1.checked;
    use_star_alignment:=use_star_alignment1.checked;

    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}
    max_stars:=strtoint2(stackmenu1.max_stars1.text,500);{maximum star to process, if so filter out brightest stars later}
    use_sip:=stackmenu1.add_sip1.checked;
    solar_drift_compensation:=((solar_drift_compensation1.checked) and (use_astrometry_internal));

    counter:=0;
    sum_exp:=0;
    sum_temp:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_start_first:=1E99;{begin observations in Julian day}
    jd_end_last:=0;{end observations in Julian day}

    init:=false;

    {simple average}
    begin
      for c:=0 to length(files_to_process)-1 do
      if length(files_to_process[c].name)>0 then
      begin

        try { Do some lengthy operation }
          ListView1.Selected :=nil; {remove any selection}
          ListView1.ItemIndex := files_to_process[c].listviewindex;{show wich file is processed}
          Listview1.Items[files_to_process[c].listviewindex].MakeVisible(False);{scroll to selected item}

          filename2:=files_to_process[c].name;

          Application.ProcessMessages;
          {load image}
          if esc_pressed then begin memo2_message('ESC pressed.');exit;end;
          if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainform1.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;

          if init=false then
          begin {init is false, first image}

            old_width:=head.width;
            old_height:=head.height;
            old_naxis3:=head.naxis3;

            //add_long_comment(mainform1.memo1.lines,'Reference file was ' + filename2);
            head_ref:=head;{backup solution}

            if ((bayerpat='') and (process_as_osc=2 {forced})) then
               if stackmenu1.bayer_pattern1.Text='auto' then memo2_message('█ █ █ █ █ █ Warning, Bayer colour pattern not in the header! Check colours and if wrong set Bayer pattern manually in tab "stack alignment". █ █ █ █ █ █')
               else
               if test_bayer_matrix(img_loaded)=false then  memo2_message('█ █ █ █ █ █ Warning, grayscale image converted to colour! Un-check option "convert OSC to colour". █ █ █ █ █ █');
          end
          else
          begin {second, third .... image}
            if ((old_width<>head.width) or (old_height<>head.height)) then memo2_message('█ █ █ █ █ █  Warning different size image!');
            if head.naxis3>old_naxis3 then begin memo2_message('█ █ █ █ █ █  Abort!! Can'+#39+'t combine colour to mono files.'); exit;end;
          end;
          if use_sip=false then a_order:=0; //stop using SIP from the header in astrometric mode



          apply_dark_and_flat(img_loaded,head);{apply dark, flat if required, renew if different head.exposure or ccd temp}

          memo2_message('Adding file: '+inttostr(counter+1)+'-'+nr_selected1.caption+' "'+filename2+'"  to average. Using '+inttostr(head.dark_count)+' darks, '+inttostr(head.flat_count)+' flats, '+inttostr(head.flatdark_count)+' flat-darks') ;
          Application.ProcessMessages;
          if esc_pressed then exit;

          if process_as_osc>0 then {do demosaic bayer}
          begin
            if head.naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
            else
              demosaic_bayer(img_loaded); {convert OSC image to colour}
          end;

          solution:=true;
          if init=false then {init, first (reference) image}
          begin
            //Julian days are already calculated in apply_dark_and_flat
            jd_mid_reference:=jd_mid; //for ephemeris stacking and astrometric option "compensate solar movement". Julian dates are calculated in apply_dark_and_flat
            height_max:=head.height;
            width_max:=head.width;
            binning:=report_binning(head.height);{select binning based on the height of the first light. Do this after demosaic since SuperPixel also bins}

            setlength(img_average,head.naxis3,height_max,width_max);
            setlength(img_temp,1,height_max,width_max);
            for fitsY:=0 to height_max-1 do
              for fitsX:=0 to width_max-1 do
              begin
                for col:=0 to head.naxis3-1 do
                  img_average[col,fitsY,fitsX]:=0; {clear img_average}
                img_temp[0,fitsY,fitsX]:=0; {clear img_temp}
              end;

            if use_star_alignment then
            begin
              bin_and_find_stars(img_loaded, head,binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist2,mean_hfd,warning);{bin, measure background, find stars}
              max_stars:=length(starlist2[0]); //adapt max_stars to reference image
              find_quads(false,length(starlist2[0]),starlist2, quad_star_distances2);{find quads for reference image}
            end
            else
            begin
              get_background(0,img_loaded,head,true,false);//get background. For internal alignment this is calculated in bin_and_find_stars
              if ((use_manual_align) or (use_ephemeris_alignment)) then   //equals use_astrometry_internal=false
              begin
                referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
                referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
              end;
            end;
            reset_solution_vectors(1);{no influence on the first image}
            pedestal:=max(500,head.backgr);{prevent image noise could go below zero. After applying dark the average value could be close to zero for dark sites}
            head.datamax_org:=head.datamax_org+(pedestal-head.backgr); if head.datamax_org>$FFFF then  head.datamax_org:=$FFFF; {note head.datamax_org is already corrected in apply dark}
          end {init, c=0}
          else
          begin //init is true
            if use_star_alignment then {internal alignment}
            begin
              bin_and_find_stars(img_loaded,head, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist1,mean_hfd,warning);{bin, measure background, find stars}
              find_quads(false,length(starlist2[0]),starlist1, quad_star_distances1);{find star quads for new image}

              if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then //Find the solution for inverse mapping. So from reference image to each new source image
                 memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.  '+solution_str)
              else
              begin
                memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
                files_to_process[c].name:=''; {remove file from list}
                solution:=false;
                ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[L_result]:=6;{mark 3th column with exclaimation}
                ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[2]:='No match';{no stack result}
              end;
            end
            else
            begin
              get_background(0,img_loaded,head,true,false);//get background. For internal alignment this is calculated in bin_and_find_stars
              if ((use_manual_align) or (use_ephemeris_alignment)) then
              begin {manual alignment}
                calculate_manual_vector(c);//includes memo2_message with solution vector
              end;
            end
          end;

          init:=true;{initialize for first image done}

          if solution then
          begin
            inc(counter);
            sum_exp:=sum_exp+head.exposure;
            sum_temp:=sum_temp+head.set_temperature;

            weightF:=calc_weightF;{calculate weighting factor for different exposure duration and gain}

            //Julian days are already calculated in apply_dark_and_flat
            jd_start_first:=min(jd_start,jd_start_first);{find the begin date}
            jd_end_last:=max(jd_end,jd_end_last);{find latest end time}
            jd_sum:=jd_sum+jd_mid;{sum julian days of images at midpoint exposure}
            airmass_sum:=airmass_sum+airmass;

            if use_astrometry_internal then
              astrometric_to_vector(head_ref,head);{convert 1th order astrometric solution to vector solution}

            background:=head.backgr;//calculated in bin_find_stars/get_background()

            if solar_drift_compensation then
              compensate_solar_drift(head, {var} solution_vectorX,solution_vectorY);//compensate movement solar objects

            stack_arrays( img_average, img_loaded, img_temp, solution_vectorX,solution_vectorY, background, weightf);//add B to A

          end; //end solution

          progress_indicator(0.1+0.89*counter/images_checked,' Stacking');{show progress}
          finally
        end;
      end;

      if counter<>0 then
      begin
        head_ref.naxis3:= head.naxis3; {store colour info in reference header}
        head_ref.naxis:=  head.naxis;  {store colour info in reference header}
        head_ref.datamax_org:= head.datamax_org;  {for 8 bit files, they are now 500 minimum}
        head:=head_ref;{restore solution variable of reference image for annotation and mount pointer. Works only if not resized}
        head.pedestal:=pedestal;
        head.height:=height_max;
        head.width:=width_max;

        for fitsY:=0 to height_max-1 do //this runs in 0.15 sec. Threaded version takes 0.43 sec
          for fitsX:=0 to width_max-1 do
          begin
            val:=img_temp[0,fitsY,fitsX];
           if val>0 then
              for col:=0 to head.naxis3-1 do
                img_loaded[col,fitsY,fitsX]:=pedestal+img_average[col,fitsY,fitsX]/val;//scale to one image by diving by the number of pixels added
          end;



      end; {counter<>0}
    end;{simple average}
  end;{with stackmenu1}

  {arrays will be nilled later. This is done for early exits}
end;


procedure stack_sigmaclip(process_as_osc:integer; var files_to_process : array of TfileToDo; out counter : integer); {stack using sigma clip average}
type
   tsolution  = record
     solution_vectorX : Tsolution_vector {array[0..2] of double};
     solution_vectorY : Tsolution_vector;
     cblack : double;
   end;
var
    solutions      : array of tsolution;
    fitsX,fitsY,c,width_max, height_max, old_width, old_height,x_new,y_new,col ,binning,max_stars,old_naxis3,ccc        : integer;
    variance_factor, value,weightF,hfd_min,dummy,mean_hfd                                                              : double;
    init, solution,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,use_sip, solar_drift_compensation,
    use_star_alignment                                                                                                 : boolean;
    tempval, sumpix, newpix, background, pedestal,val                                                                  : single;
    warning     : string;
    starlist1,starlist2 : Tstar_list;
    img_temp,img_average,img_final,img_variance,img_early,dummy_img : Timage_array;
begin
  with stackmenu1 do
  begin
    {move often used setting to booleans. Great speed improved if use in a loop and read many times}
    variance_factor:=sqr(strtofloat2(stackmenu1.sd_factor1.text));

    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}
    max_stars:=strtoint2(stackmenu1.max_stars1.text,500);{maximum star to process, if so filter out brightest stars later}
    use_sip:=stackmenu1.add_sip1.checked;


    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometric_alignment1.checked;
    use_star_alignment:=use_star_alignment1.checked;

    solar_drift_compensation:=((solar_drift_compensation1.checked) and (use_astrometry_internal));

    counter:=0;
    sum_exp:=0;
    sum_temp:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_start_first:=1E99;{begin observations in Julian day}
    jd_end_last:=0;{end observations in Julian day}

    {light average}
    begin
      setlength(solutions,length(files_to_process));
      init:=false;
      for c:=0 to length(files_to_process)-1 do
      if length(files_to_process[c].name)>0 then
      begin
      try { Do some lengthy operation }
        ListView1.Selected :=nil; {remove any selection}
        ListView1.ItemIndex := files_to_process[c].listviewindex;{show wich file is processed}
        Listview1.Items[files_to_process[c].listviewindex].MakeVisible(False);{scroll to selected item}

        filename2:=files_to_process[c].name;

        {load image}
        Application.ProcessMessages;
        if esc_pressed then begin memo2_message('ESC pressed.');exit;end;
        if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainform1.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;

        if init=false then {first image}
        begin
          old_width:=head.width;
          old_height:=head.height;
          old_naxis3:=head.naxis3;

          head_ref:=head;{backup solution}

          if ((bayerpat='') and (process_as_osc=2 {forced})) then
             if stackmenu1.bayer_pattern1.Text='auto' then memo2_message('█ █ █ █ █ █ Warning, Bayer colour pattern not in the header! Check colours and if wrong set Bayer pattern manually in tab "stack alignment". █ █ █ █ █ █')
             else
             if test_bayer_matrix(img_loaded)=false then  memo2_message('█ █ █ █ █ █ Warning, grayscale image converted to colour! Un-check option "convert OSC to colour". █ █ █ █ █ █');
        end
        else
        begin {second, third, ... image}
          if ((old_width<>head.width) or (old_height<>head.height)) then memo2_message('█ █ █ █ █ █  Warning different size image!');
          if head.naxis3>old_naxis3 then begin memo2_message('█ █ █ █ █ █  Abort!! Can'+#39+'t combine colour to mono files.'); exit;end;
        end;

        if use_sip=false then a_order:=0; //stop using SIP from the header in astrometric mode

        apply_dark_and_flat(img_loaded,head);{apply dark, flat if required, renew if different head.exposure or ccd temp}

        memo2_message('Adding light file: '+inttostr(counter+1)+'-'+nr_selected1.caption+' "'+filename2+' dark compensated to light average. Using '+inttostr(head.dark_count)+' dark(s), '+inttostr(head.flat_count)+' flat(s), '+inttostr(head.flatdark_count)+' flat-dark(s)') ;
        Application.ProcessMessages;
        if esc_pressed then exit;

        if process_as_osc>0 then {do demosaic bayer}
        begin
          if head.naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
          else
             demosaic_bayer(img_loaded); {convert OSC image to colour}
            {head.naxis3 is now 3}
        end;

        solution:=true;
        if init=false then
        begin
          jd_mid_reference:=jd_mid; //for  "compensate solar movement". Julian dates are calculated in apply_dark_and_flat
          height_max:=head.height;
          width_max:=head.width;
          setlength(img_average,head.naxis3,height_max,width_max);
          setlength(img_temp,head.naxis3,height_max,width_max);
          for fitsY:=0 to height_max-1 do
            for fitsX:=0 to width_max-1 do
              for col:=0 to head.naxis3-1 do
              begin
                img_average[col,fitsY,fitsX]:=0; {clear img_average}
                img_temp[col,fitsY,fitsX]:=0; {clear img_temp}
              end;

          binning:=report_binning(head.height);{select binning based on the height of the first light. Do this after demosaic since SuperPixel also bins}

          if use_star_alignment then
          begin
            bin_and_find_stars(img_loaded, head,binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist2,mean_hfd,warning);{bin, measure background, find stars}
            max_stars:=length(starlist2[0]); //adapt max_stars to reference image
            find_quads(false,length(starlist2[0]),starlist2, quad_star_distances2);{find quads for reference image}
          end
          else
          begin
            get_background(0,img_loaded,head,true,false);//get background. For internal alignment this is calculated in bin_and_find_stars
            if ((use_manual_align) or (use_ephemeris_alignment)) then   //equals use_astrometry_internal=false
            begin
              referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
              referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
            end;
          end;
          reset_solution_vectors(1);{no influence on the first image}
          solutions[c].solution_vectorX:= solution_vectorX; {store solutions for later}
          solutions[c].solution_vectorY:= solution_vectorY;
          pedestal:=max(500,head.backgr);{prevent image noise could go below zero. After applying dark the average value could be close to zero for dark sites}
          head.datamax_org:=head.datamax_org+(pedestal-head.backgr); if head.datamax_org>$FFFF then  head.datamax_org:=$FFFF; {note head.datamax_org is already corrected in apply dark}
        end {init, c=0}
        else
        begin //second image
          if use_star_alignment then {internal alignment}
          begin{internal alignment}
            bin_and_find_stars(img_loaded,head, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist1,mean_hfd,warning);{bin, measure background, find stars}
            find_quads(false,length(starlist2[0]),starlist1, quad_star_distances1);{find star quads for new image}
            if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then //Find the solution for inverse mapping. So from reference image to each new source image
            begin
              memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.  '+solution_str);
              solutions[c].solution_vectorX:= solution_vectorX;{store solutions}
              solutions[c].solution_vectorY:= solution_vectorY;
            end
            else
            begin
              memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
              files_to_process[c].name:=''; {remove file from list}
              solution:=false;
              ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[L_result]:=6;{mark 3th column with exclamation}
              ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_result]:='No match';{no stack result}
            end
          end{internal alignment}
          else
          begin
            get_background(0,img_loaded,head,true,false);//get background. For internal alignment this is calculated in bin_and_find_stars
            if ((use_manual_align) or (use_ephemeris_alignment)) then //<> use_astrometry_internal
            begin {manual alignment}
              calculate_manual_vector(c);//includes memo2_message with solution vector
              solutions[c].solution_vectorX:= solution_vectorX;{store solutions}
              solutions[c].solution_vectorY:= solution_vectorY;
            end;
          end;
        end;

        init:=true;{initialize for first image done}

        if solution then
        begin
          if use_astrometry_internal then sincos(head.dec0,SIN_dec0,COS_dec0); {do this in advance since it is for each pixel the same}
          solutions[c].cblack:=head.backgr;//store background

          inc(counter);
          sum_exp:=sum_exp+head.exposure;
          sum_temp:=sum_temp+head.set_temperature;
          weightF:=calc_weightF;{calculate weighting factor for different exposure duration and gain}
          {1}

          //Julian days are already calculated in apply_dark_and_flat
          jd_start_first:=min(jd_start,jd_start_first);{find the begin date}
          jd_end_last:=max(jd_end,jd_end_last);{find latest end time}
          jd_sum:=jd_sum+jd_mid;{sum julian days of images at midpoint exposure}
          airmass_sum:=airmass_sum+airmass;

          background:=head.backgr;

          if use_astrometry_internal then
            astrometric_to_vector(head_ref,head);{convert 1th order astrometric solution to vector solution}

          if solar_drift_compensation then
            compensate_solar_drift(head, {var} solution_vectorX,solution_vectorY);//compensate movement solar objects

          stack_arrays(img_average, img_loaded, img_temp, solution_vectorX,solution_vectorY, background, weightf);//add B to A

        end;//solution

        progress_indicator(0.1+0.3333*0.9*counter/images_checked,' ■□□');{show progress}
        finally
        end;
      end;{try}
      if counter<>0 then //this is unthreaded faster then threaded
      for fitsY:=0 to height_max-1 do
        for fitsX:=0 to width_max-1 do
        begin
          val:=img_temp[0,fitsY,fitsX];
          if val>0 then
            for col:=0 to head.naxis3-1 do
               img_average[col,fitsY,fitsX]:=img_average[col,fitsY,fitsX]/val;//scale to one image by diving by the number of pixels added
        end;
    end;  {light average}

    {standard deviation of light images}  {stack using sigma clip average}
    begin {standard deviation}
      counter:=0;

      init:=false;
      for c:=0 to length(files_to_process)-1 do
      if length(files_to_process[c].name)>0 then
      begin
        try { Do some lengthy operation }
          ListView1.Selected :=nil; {remove any selection}
          ListView1.ItemIndex := files_to_process[c].listviewindex;{show wich file is processed}
          Listview1.Items[files_to_process[c].listviewindex].MakeVisible(False); {scroll to selected item}

          filename2:=files_to_process[c].name;

          {load image}
          Application.ProcessMessages;
          if esc_pressed then begin memo2_message('ESC pressed.');exit;end;
          if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainform1.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;

          if init=false then
          begin
            {not required. Done in first step}
          end;

          apply_dark_and_flat(img_loaded,head);{apply dark, flat if required, renew if different head.exposure or ccd temp}

          memo2_message('Calculating pixels σ of light file '+inttostr(counter+1)+'-'+nr_selected1.caption+' '+filename2+' Using '+inttostr(head.dark_count)+' dark(s), '+inttostr(head.flat_count)+' flat(s), '+inttostr(head.flatdark_count)+' flat-dark(s)') ;
          Application.ProcessMessages;
          if esc_pressed then exit;

          if process_as_osc>0 then {do demosaic bayer}
          begin
            if head.naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
            else
               demosaic_bayer(img_loaded); {convert OSC image to colour}
              {head.naxis3 is now 3}
          end;
          if init=false then {init (2) for standard deviation step}
          begin
            jd_mid_reference:=jd_mid; //for  "compensate solar movement". Julian dates are calculated in apply_dark_and_flat
            setlength(img_variance,head.naxis3,height_max,width_max);{mono}
            for fitsY:=0 to height_max-1 do
            for fitsX:=0 to width_max-1 do
            begin
              for col:=0 to head.naxis3-1 do img_variance[col,fitsY,fitsX]:=0; {clear img_average}
            end;
          end;{c=0}

          inc(counter);

          if use_astrometry_internal then  sincos(head.dec0,SIN_dec0,COS_dec0) {do this in advance since it is for each pixel the same}
          else
          begin {align using star match, read saved solution vectors}
            solution_vectorX:=solutions[c].solution_vectorX; {restore solution}
            solution_vectorY:=solutions[c].solution_vectorY;
          end;
          init:=true;{initialize for first image done}
          background:=solutions[c].cblack;
          weightF:=calc_weightF;{calculate weighting factor for different exposure duration and gain}
          {2}

          if use_astrometry_internal then
            astrometric_to_vector(head_ref,head);{convert 1th order astrometric solution to vector solution}

          if solar_drift_compensation then
            compensate_solar_drift(head, {var} solution_vectorX,solution_vectorY);//compensate movement solar objects

          variance_array(img_variance, img_loaded, img_average,img_temp, solution_vectorX,solution_vectorY, background, weightf);//add B to A

          progress_indicator(0.10+0.3+0.33333*0.9*counter/images_checked,' ■■□');{show progress}
        finally
        end;
      end;{try}
      if counter<>0 then
        For fitsY:=0 to height_max-1 do
          for fitsX:=0 to width_max-1 do
          begin
            val:=img_temp[0,fitsY,fitsX];{re-use the img_temp from light average}
            if val<>0 then
            for col:=0 to head.naxis3-1 do
              img_variance[col,fitsY,fitsX]:=1+img_variance[col,fitsY,fitsX]/val; {the extra 1 is for saturated images giving a SD=0}{scale to one image by diving by the number of pixels tested}
            end;
    end; {standard deviation of light images}


    {throw out the outliers of light-dark images}  {stack using sigma clip average}
    begin
      counter:=0;
      init:=false;
      for c:=0 to length(files_to_process)-1 do
      if length(files_to_process[c].name)>0 then
      begin
        try { Do some lengthy operation }
          ListView1.Selected :=nil; {remove any selection}
          ListView1.ItemIndex := files_to_process[c].listviewindex;{show wich file is processed}
          Listview1.Items[files_to_process[c].listviewindex].MakeVisible(False);{scroll to selected item}

          filename2:=files_to_process[c].name;

          {load file}
          Application.ProcessMessages;
          if esc_pressed then begin memo2_message('ESC pressed.');exit;end;
          if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainform1.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;

          apply_dark_and_flat(img_loaded,head);{apply dark, flat if required, renew if different head.exposure or ccd temp}

          memo2_message('Combining '+inttostr(counter+1)+'-'+nr_selected1.caption+' "'+filename2+'", ignoring outliers. Using '+inttostr(head.dark_count)+' dark(s), '+inttostr(head.flat_count)+' flat(s), '+inttostr(head.flatdark_count)+' flat-dark(s)') ;
          Application.ProcessMessages;
          if esc_pressed then exit;

          if process_as_osc>0 then {do demosaic bayer}
          begin
            if head.naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
            else
              demosaic_bayer(img_loaded); {convert OSC image to colour}
              {head.naxis3 is now 3}
           end;

          if init=false then {init, (3) step throw outliers out}
          begin
            jd_mid_reference:=jd_mid; //for  "compensate solar movement". Julian dates are calculated in apply_dark_and_flat
            setlength(img_temp,head.naxis3,height_max,width_max);
            setlength(img_final,head.naxis3,height_max,width_max);
            for fitsY:=0 to height_max-1 do
            for fitsX:=0 to width_max-1 do
            begin
              for col:=0 to head.naxis3-1 do
              begin
                img_temp[col,fitsY,fitsX]:=0; {clear img_temp}
                img_final[col,fitsY,fitsX]:=0; {clear img_temp}
              end;
            end;
          end;{init}

          inc(counter);

          if use_astrometry_internal then  sincos(head.dec0,SIN_dec0,COS_dec0) {do this in advance since it is for each pixel the same}
          else
          begin {align using star match, read saved solution vectors}
            solution_vectorX:=solutions[c].solution_vectorX; {restore solution}
            solution_vectorY:=solutions[c].solution_vectorY;
          end;
          init:=true;{initialize for first image done}
          background:=solutions[c].cblack;
          weightF:=calc_weightF;{calculate weighting factor for different exposure duration and gain}
          {3}

          if use_astrometry_internal then
            astrometric_to_vector(head_ref,head);{convert 1th order astrometric solution to vector solution}

          if solar_drift_compensation then
            compensate_solar_drift(head, {var} solution_vectorX,solution_vectorY);//compensate movement solar objects

          //phase 3
          finalise_array(img_final, img_loaded, img_average,img_variance,img_temp, solution_vectorX,solution_vectorY, background, weightf,variance_factor);//add B to A

          progress_indicator(0.1+0.6+0.33333*0.9*counter/images_checked,' ■■■');{show progress}
          finally
        end;
      end;

     {scale to number of pixels}
      if counter<>0 then
      begin
        head_ref.naxis3:= head.naxis3; {store colour info in reference header. could be modified by OSC conversion}
        head_ref.naxis:=  head.naxis;  {store colour info in reference header}
        head_ref.datamax_org:= head.datamax_org;  {for 8 bit files, they are now 500 minimum}
        head:=head_ref;{restore solution variable of reference image for annotation and mount pointer. Works only if not oversized}
        head.pedestal:=pedestal;
        head.height:=height_max;
        head.width:=width_max;
        for col:=0 to head.naxis3-1 do //this runs unthreaded 0.13 sec. with col as third loop 0.15 sec. Threaded takes 0.43 sec.
          for fitsY:=0 to height_max-1 do
              for fitsX:=0 to width_max-1 do
              begin
                val:=img_temp[col,fitsY,fitsX];
                if val>0 then
                    img_loaded[col,fitsY,fitsX]:=pedestal+img_final[col,fitsY,fitsX]/val;//scale to one image by diving by the number of pixels added
              end;
      end;{counter<>0}

      //restore_solution(true);{restore solution variable of reference image for annotation and mount pointer}

    end;{throw out the outliers of light-dark images}
  end;{with stackmenu1}
  {image arrays will be nilled later. This is done for early exits}

  solutions:=nil;
end;   {stack using sigma clip average}



procedure stack_comet(process_as_osc:integer; var files_to_process : array of TfileToDo; out counter : integer); {stack comets using ephemeris method. Comet is stacked aligned. Driting stars are surpressed except for first frame}
type
   tsolution  = record
     solution_vectorX : Tsolution_vector {array[0..2] of double};
     solution_vectorY : Tsolution_vector;
     cblack : array[0..2] of single;
   end;
var
    solutions      : array of tsolution;
    fitsX,fitsY,c,width_max, height_max, old_width, old_height,x_new,y_new,col, old_naxis3,
    height_maxS,width_maxS                                                                                   : integer;
    value,weightF,hfd_min,aa,bb,cc,dd,ee,ff,delta_JD_required,target_background, JD_reference, hfd_measured  : double;
    init, solution,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,use_sip   : boolean;
    jd_fraction                                                                        : single;
    background_correction : array[0..2] of single;
    img_temp,img_final,img_variance : Timage_array;
begin
  with stackmenu1 do
  begin
    {move often used setting to booleans. Great speed improved if use in a loop and read many times}
    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}
    use_sip:=stackmenu1.add_sip1.checked;

    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometric_alignment1.checked;

    counter:=0;
    sum_exp:=0;
    sum_temp:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_start_first:=1E99;{begin observations in Julian day}
    jd_end_last:=0;{end observations in Julian day}

    {find the JD moment when the pixel is at max value}
    begin
      setlength(solutions,length(files_to_process));
      init:=false;
      for c:=0 to length(files_to_process)-1 do
      if length(files_to_process[c].name)>0 then
      begin
      try { Do some lengthy operation }
        ListView1.Selected :=nil; {remove any selection}
        ListView1.ItemIndex := files_to_process[c].listviewindex;{show wich file is processed}
        Listview1.Items[files_to_process[c].listviewindex].MakeVisible(False);{scroll to selected item}

        filename2:=files_to_process[c].name;

        {load image}
        Application.ProcessMessages;
        if esc_pressed then begin memo2_message('ESC pressed.');exit;end;
        if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainform1.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;
        if init=false then {first image}
        begin
          old_width:=head.width;
          old_height:=head.height;
          old_naxis3:=head.naxis3;

          head_ref:=head;{backup solution}
          //sincos(head_ref.dec0,SIN_dec_ref,COS_dec_ref);{do this in advance to reduce calculations since  it is for each pixel the same. For blink header "head" is used instead of "head_ref"}

          if ((bayerpat='') and (process_as_osc=2 {forced})) then
             if stackmenu1.bayer_pattern1.Text='auto' then memo2_message('█ █ █ █ █ █ Warning, Bayer colour pattern not in the header! Check colours and if wrong set Bayer pattern manually in tab "stack alignment". █ █ █ █ █ █')
             else
             if test_bayer_matrix(img_loaded)=false then  memo2_message('█ █ █ █ █ █ Warning, grayscale image converted to colour! Un-check option "convert OSC to colour". █ █ █ █ █ █');
        end
        else
        begin {second, third, ... image}
          if ((old_width<>head.width) or (old_height<>head.height)) then memo2_message('█ █ █ █ █ █  Warning different size image!');
          if head.naxis3>old_naxis3 then begin memo2_message('█ █ █ █ █ █  Abort!! Can'+#39+'t combine colour to mono files.'); exit;end;
        end;

        if use_sip=false then a_order:=0; //stop using SIP from the header in astrometric mode

        apply_dark_and_flat(img_loaded,head);{apply dark, flat if required, renew if different head.exposure or ccd temp}

        memo2_message('Registrating drifting stars movements: '+inttostr(counter+1)+'-'+nr_selected1.caption+' "'+filename2+' dark compensated to light average. Using '+inttostr(head.dark_count)+' dark(s), '+inttostr(head.flat_count)+' flat(s), '+inttostr(head.flatdark_count)+' flat-dark(s)') ;
        Application.ProcessMessages;
        if esc_pressed then exit;

        if process_as_osc>0 then {do demosaic bayer}
        begin
          if head.naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
          else
             demosaic_bayer(img_loaded); {convert OSC image to colour}
            {head.naxis3 is now 3}
        end;

        //calculate background for best quality drifting star supression
        begin //for making all background the same for better sigma clip function
          memo2_message('Measuring background for all colours');
          for col:=0 to head.naxis3-1 do /// for all colours
          begin
            get_background(col, img_loaded,head, True {update_hist}, False {calculate noise level});
            solutions[c].cblack[col]:=head.backgr;
          end;

        end;

        if init=false then
        begin
          referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
          referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}

          height_max:=head.height;
          width_max:=head.width;

          setlength(img_variance,2,height_max,width_max);//two colour array
          for fitsY:=0 to height_max-1 do
            for fitsX:=0 to width_max-1 do
            begin
              img_variance[0,fitsY,fitsX]:=0;//will be used for storing the max value during time period
              img_variance[1,fitsY,fitsX]:=0;//will be used for storing the time (jd_fraction) when maximum occurs
            end;
          target_background:=max(500,solutions[c].cblack[0]); //target for all images. Background of reference image or when lower then 500 then 500.
          memo2_message('Target background for all images is '+floattostrF(target_background,FFFixed,0,0));
        end;{init, c=0}

        solution:=true;

        if init=true then {second image}
          calculate_manual_vector(c)//includes memo2_message with solution vector


        else
        begin {first image}
          reset_solution_vectors(1);{no influence on the first image}
          solutions[c].solution_vectorX:= solution_vectorX; {store solutions for later}
          solutions[c].solution_vectorY:= solution_vectorY;
         end;


        init:=true;{initialize for first image done}
        if solution then
        begin
          inc(counter);
          sum_exp:=sum_exp+head.exposure;
          sum_temp:=sum_temp+head.set_temperature;

          weightF:=calc_weightF;{calculate weighting factor for different exposure duration and gain}
          for col:=0 to head.naxis3-1 do
            background_correction[col]:=solutions[c].cblack[col] - target_background;//for sigma clip. First try to get backgrounds equal for more effective sigma clip

          head.datamax_org:=min($FFFF,head.datamax_org-background_correction[0]);{note head.datamax_org is already corrected in apply dark}
          {1}

          //Julian days are already calculated in apply_dark_and_flat
          jd_start_first:=min(jd_start,jd_start_first);{find the begin date}
          jd_end_last:=max(jd_end,jd_end_last);{find latest end time}
          jd_sum:=jd_sum+jd_mid;{sum julian days of images at midpoint exposure}
          airmass_sum:=airmass_sum+airmass;


          jd_fraction:=frac(jd_mid);//Take fraction because single has not enough resolution for JD

          if counter=1 then JD_reference:=jd_Start  // JD of reference image. Can not use JD_start_first since it can go back in time by the min() function
          else
          if counter=2 then
          begin
             //calculate drift compared to the reference image
             hfd_measured:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_hfd]);
             if hfd_measured<=0 then //quick analyse was activated
             begin
               analyse_image(img_loaded, head, 10 {snr_min}, 0); {find background, number of stars, median HFD}
               hfd_measured:=head.hfd_median;
             end;
             delta_JD_required:= abs(jd_start-jd_reference)* 3*hfd_measured/sqrt(sqr(solution_vectorX[2])+sqr(solution_vectorY[2]));
             memo2_message('For stars 3*HFD drift takes '+ floattostrF(delta_JD_required*24*3600,FFFixed,4,0)+'sec');
          end;

          height_maxS:=head.height;
          width_maxS:=head.width;


          aa:=solution_vectorX[0];//move to local variable for minor faster processing
          bb:=solution_vectorX[1];
          cc:=solution_vectorX[2];
          dd:=solution_vectorY[0];
          ee:=solution_vectorY[1];
          ff:=solution_vectorY[2];

          //Inverse Mapping (a.k.a. Backward Mapping) Instead of mapping source → destination (forward), you loop over destination pixels and figure out where they came from in the original image
          for fitsY:=0 to height_max-1 do {cycle through destination image}
          for fitsX:=0 to width_max-1  do
          begin
            x_new:=round(aa*(fitsx)+bb*(fitsY)+cc); {correction x:=aX+bY+c  x_new_float in image array range 0..head.width-1}
            y_new:=round(dd*(fitsx)+ee*(fitsY)+ff); {correction y:=aX+bY+c}


            if ((x_new>=0) and (x_new<=width_maxS-1) and (y_new>=0) and (y_new<=height_maxS-1)) then
            begin
              value:=0;
              for col:=0 to head.naxis3-1 do //do all colours
                value:=value+(img_loaded[col,y_new,x_new]- background_correction[col]) *weightF; //sum red, green/blue
              if value>img_variance[0,fitsY,fitsX] then
              begin
                img_variance[0,fitsY,fitsX]:=value; // Find the highest value for this (final) pixel position
                img_variance[1,fitsY,fitsX]:=jd_fraction; // The time this highest value occurs Take fraction because single float has not enough resolution for JD
              end;

            end;
          end;

        end;//solution
        progress_indicator(0.1+0.5*0.9*counter/images_checked,' ■□');{show progress}
        finally
        end;
      end;{try}
    end;  {find the JD moment when the pixel is at max value}

    // combine images but throw out the moments when a star is drifting to each pixel. This moment is detected by the max value and recorded in phase 1 in img_variance.
    begin
      counter:=0;
      init:=false;
      for c:=0 to length(files_to_process)-1 do
      if length(files_to_process[c].name)>0 then
      begin
        try { Do some lengthy operation }
          ListView1.Selected :=nil; {remove any selection}
          ListView1.ItemIndex := files_to_process[c].listviewindex;{show wich file is processed}
          Listview1.Items[files_to_process[c].listviewindex].MakeVisible(False);{scroll to selected item}

          filename2:=files_to_process[c].name;

          {load file}
          Application.ProcessMessages;
          if esc_pressed then begin memo2_message('ESC pressed.');exit;end;
          if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainform1.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;
          apply_dark_and_flat(img_loaded,head);{apply dark, flat if required, renew if different head.exposure or ccd temp}

          date_to_jd(head.date_obs,head.date_avg,head.exposure);{convert head.date_obs string and head.exposure time to global variables jd_start (julian day start head.exposure) and jd_mid (julian day middle of the head.exposure)}
          jd_fraction:=frac(jd_mid);//Take fraction because single has not enough resolution for JD


          memo2_message('Combining '+inttostr(counter+1)+'-'+nr_selected1.caption+' "'+filename2+'", ignoring moving stars. Using '+inttostr(head.dark_count)+' dark(s), '+inttostr(head.flat_count)+' flat(s), '+inttostr(head.flatdark_count)+' flat-dark(s)') ;
          Application.ProcessMessages;
          if esc_pressed then exit;

          if process_as_osc>0 then {do demosaic bayer}
          begin
            if head.naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
            else
              demosaic_bayer(img_loaded); {convert OSC image to colour}
              {head.naxis3 is now 3}
           end;

          if init=false then {init, (3) step throw outliers out}
          begin
            setlength(img_temp,1,height_max,width_max);
            setlength(img_final,head.naxis3,height_max,width_max);
            for fitsY:=0 to height_max-1 do
            for fitsX:=0 to width_max-1 do
            begin
              for col:=0 to head.naxis3-1 do
                img_final[col,fitsY,fitsX]:=0; {clear final}
              img_temp[0,fitsY,fitsX]:=0; {clear counter}
            end;
          end;{init}

          inc(counter);

          if use_astrometry_internal then  sincos(head.dec0,SIN_dec0,COS_dec0) {do this in advance since it is for each pixel the same}
          else
          begin {align using star match, read saved solution vectors}
            if ((use_manual_align) or (use_ephemeris_alignment)) then
            begin
              if init=false then {3}
              begin
                reset_solution_vectors(1);{no influence on the first image}
              end
              else
              begin
                calculate_manual_vector(c);
              end;
            end
            else
            begin  {reuse solution from first step average}
              solution_vectorX:=solutions[c].solution_vectorX; {restore solution}
              solution_vectorY:=solutions[c].solution_vectorY;
            end;
          end;

          weightF:=calc_weightF;{calculate weighting factor for different exposure duration and gain}

          for col:=0 to head.naxis3-1 do /// for all colours
            background_correction[col]:=solutions[c].cblack[col] - target_background;//try to get backgrounds equal
          head.datamax_org:=min($FFFF,head.datamax_org-background_correction[0]);

          aa:=solution_vectorX[0];//move to local variable for minor faster processing
          bb:=solution_vectorX[1];
          cc:=solution_vectorX[2];
          dd:=solution_vectorY[0];
          ee:=solution_vectorY[1];
          ff:=solution_vectorY[2];

          //phase 2
          for fitsY:=0 to height_max-1 do {cycle through destination image}
          for fitsX:=0 to width_max-1  do
          begin
            x_new:=round(aa*(fitsx)+bb*(fitsY)+cc); {correction x:=aX+bY+c}
            y_new:=round(dd*(fitsx)+ee*(fitsY)+ff); {correction y:=aX+bY+c}

            if ((x_new>=0) and (x_new<=width_maxS-1) and (y_new>=0) and (y_new<=height_maxS-1)) then
            begin
              if ((init=false) or (abs(jd_fraction{when is star spot is passing by} - img_variance[1,fitsY,fitsX])>delta_JD_required)) then // Avoid streaks. Skip stacking when star is passing by
              begin
                for col:=0 to head.naxis3-1 do {do all colors}
                begin
                  value:=(img_loaded[col,y_new,x_new]- background_correction[col])*weightF;
                  img_final[col,fitsY,fitsX]:=img_final[col,fitsY,fitsX]+ value;{dark and flat, flat dark already applied}
                  img_temp[0,fitsY,fitsX]:=img_temp[0,fitsY,fitsX]+weightF {norm 1};{count the number of image pixels added=samples}
                end;
              end;
            end;
          end;

          init:=true;{initialize for first image done}

          progress_indicator(0.1+0.45+0.5*0.9*counter/images_checked,' ■■');{show progress}
          finally
        end;
      end;

     {scale to number of pixels}
      if counter<>0 then
      begin
        head_ref.naxis3:= head.naxis3; {store colour info in reference header. could be modified by OSC conversion}
        head_ref.naxis:=  head.naxis;  {store colour info in reference header}
        head_ref.datamax_org:= head.datamax_org;  {for 8 bit files, they are now 500 minimum}
        head:=head_ref;{restore solution variable of reference image for annotation and mount pointer. Works only if not oversized}
        head.height:=height_max;
        head.width:=width_max;

        for fitsY:=0 to height_max-1 do //this runs in 0.15 sec. Threaded version takes 0.43 sec
          for fitsX:=0 to width_max-1 do
          begin
            value:=img_temp[0,fitsY,fitsX];
           if value>0 then
              for col:=0 to head.naxis3-1 do
                img_loaded[col,fitsY,fitsX]:={pedestal+}img_final[col,fitsY,fitsX]/value;//scale to one image by diving by the number of pixels added
          end;



      end;{counter<>0}
    end;// combine images but throw out the moments when a star is at the pixel. This moment is detected by the max value.
  end;{with stackmenu1}
  {image arrays will be nilled later. This is done for early exits}

  solutions:=nil;
end;   {comet and stars sharp}


procedure calibration_and_alignment(process_as_osc :integer; var files_to_process : array of TfileToDo; out counter : integer); {calibration_and_alignment only}
var
    fitsX,fitsY,c, old_width, old_height,col, binning, max_stars,old_naxis3,height_average,width_average,ccc  : integer;
    background, hfd_min,pedestal,mean_hfd,value                                                           : double;
    init, solution,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,use_sip,use_star_alignment: boolean;
    warning             : string;
    starlist1,starlist2 : Tstar_list;
    img_temp,img_average: Timage_array;

begin
  with stackmenu1 do
  begin
    {move often used settings to booleans. Great speed improved if use in a loop and read many times}
    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}
    max_stars:=strtoint2(stackmenu1.max_stars1.text,500);{maximum star to process, if so filter out brightest stars later}
    use_sip:=stackmenu1.add_sip1.checked;


    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometric_alignment1.checked;
    use_star_alignment:=use_star_alignment1.checked;

    {light average}
    begin
      counter:=0;
      sum_exp:=0;

      init:=false;
      for c:=0 to length(files_to_process)-1 do
      if length(files_to_process[c].name)>0 then
      begin
      try { Do some lengthy operation }
        ListView1.Selected :=nil; {remove any selection}
        ListView1.ItemIndex := files_to_process[c].listviewindex;{show wich file is processed}
        Listview1.Items[files_to_process[c].listviewindex].MakeVisible(False);{scroll to selected item}

        filename2:=files_to_process[c].name;

        {load image}
        Application.ProcessMessages;
        if esc_pressed then begin memo2_message('ESC pressed.');exit;end;

        if load_fits(filename2,true {light},true,true {init=false} {update memo for saving},0,mainform1.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;

        if init=false then {first image}
        begin
          old_width:=head.width;
          old_height:=head.height;
          old_naxis3:=head.naxis3;

          head_ref:=head;{backup solution}
          //sincos(head_ref.dec0,SIN_dec_ref,COS_dec_ref);{do this in advance to reduce calculations since  it is for each pixel the same. For blink header "head" is used instead of "head_ref"}

          if ((bayerpat='') and (process_as_osc=2 {forced})) then
             if stackmenu1.bayer_pattern1.Text='auto' then memo2_message('█ █ █ █ █ █ Warning, Bayer colour pattern not in the header! Check colours and if wrong set Bayer pattern manually in tab "stack alignment". █ █ █ █ █ █')
             else
             if test_bayer_matrix(img_loaded)=false then  memo2_message('█ █ █ █ █ █ Warning, grayscale image converted to colour! Un-check option "convert OSC to colour". █ █ █ █ █ █');
        end
        else
        begin {second, third ... image}
          if ((old_width<>head.width) or (old_height<>head.height)) then memo2_message('█ █ █ █ █ █  Warning different size image!');
          if head.naxis3>old_naxis3 then begin memo2_message('█ █ █ █ █ █  Abort!! Can'+#39+'t combine colour to mono files.'); exit;end;
        end;

        if use_sip=false then a_order:=0; //stop using SIP from the header in astrometric mode
        apply_dark_and_flat(img_loaded,head);{apply dark, flat if required, renew if different head.exposure or ccd temp}

        memo2_message('Calibrating and aligning file: '+inttostr(counter+1)+'-'+nr_selected1.caption+' "'+filename2+' dark compensated to light average. Using '+inttostr(head.dark_count)+' dark(s), '+inttostr(head.flat_count)+' flat(s), '+inttostr(head.flatdark_count)+' flat-dark(s)') ;
        Application.ProcessMessages;
        if esc_pressed then exit;

        if process_as_osc>0 then {do demosaic bayer}
        begin
          if head.naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
          else
            demosaic_bayer(img_loaded); {convert OSC image to colour}
            {head.naxis3 is now 3}
        end
        else
        if bayerpat<>'' then memo2_message('█ █ █ █ █ █ Warning, alignment (shifting, rotating) will ruin Bayer pattern!! Select calibrate only for photometry or checkmark "Convert OSC image to colour" █ █ █ █ █ █');


        solution:=true;
        if init=false then {init, first (reference) image}
        begin
          //Julian days are already calculated in apply_dark_and_flat
          jd_mid_reference:=jd_mid; //for ephemeris stacking and astrometric option "compensate solar movement". Julian dates are calculated in apply_dark_and_flat
          binning:=report_binning(head.height);{select binning based on the height of the first light. Do this after demosaic since SuperPixel also bins}

          height_average:=head.height;//of first source image
          width_average:=head.width;
          setlength(img_average,head.naxis3,height_average,width_average);
          setlength(img_temp,1,height_average,width_average);

          if use_star_alignment then
          begin
          //Find the equations for image destignation to image source!. Use this later to take four pixels fractions back to the reference image (inverse mapping).
          bin_and_find_stars(img_loaded, head,binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist2,mean_hfd,warning);{bin, measure background, find stars}
          max_stars:=length(starlist2[0]); //adapt max_stars to reference image
          find_quads(false,length(starlist2[0]),starlist2, quad_star_distances2);{find quads for reference image}
          end
          else
          begin
            get_background(0,img_loaded,head,true,false);//get background. For internal alignment this is calculated in bin_and_find_stars
            if ((use_manual_align) or (use_ephemeris_alignment)) then   //equals use_astrometry_internal=false
            begin
              referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
              referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
            end;
          end;
          reset_solution_vectors(1);{no influence on the first image}
          pedestal:=max(500,head.backgr);{prevent image noise could go below zero. After applying dark the average value could be close to zero for dark sites}
          head.datamax_org:=head.datamax_org+(pedestal-head.backgr); if head.datamax_org>$FFFF then  head.datamax_org:=$FFFF; {note head.datamax_org is already corrected in apply dark}
        end {init, c=0}
        else
        begin //init is true
          if use_star_alignment then {internal alignment}
          begin
            //Find the equations for image destignation to image source!. Use this later to take four pixels fractions back to the reference image (inverse mapping).
            bin_and_find_stars(img_loaded,head, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist1,mean_hfd,warning);{bin, measure background, find stars}
            find_quads(false,length(starlist2[0]),starlist1, quad_star_distances1);{find star quads for new image}

            if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then //Find the solution for inverse mapping. So from reference image to each new source image
               memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.  '+solution_str)
            else
            begin
              memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
              files_to_process[c].name:=''; {remove file from list}
              solution:=false;
              ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[L_result]:=6;{mark 3th column with exclaimation}
              ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[2]:='No match';{no stack result}
            end;
          end
          else
          begin
            get_background(0,img_loaded,head,true,false);//get background. For internal alignment this is calculated in bin_and_find_stars
            if ((use_manual_align) or (use_ephemeris_alignment)) then
            begin {manual alignment}
              calculate_manual_vector(c);//includes memo2_message with solution vector
            end;
          end
        end;

        init:=true;{initialize for first image done}


        if solution then
        begin
//          if use_astrometry_internal then
//            sincos(head.dec0,SIN_dec0,COS_dec0); {do this in advance since it is for each pixel the same}
          if use_astrometry_internal then
            astrometric_to_vector(head_ref,head);{convert 1th order astrometric solution to vector solution}

          inc(counter);
          background:=head.backgr;//calculated in bin_find_stars



          for fitsY:=0 to height_average-1 do
            for fitsX:=0 to width_average-1 do
            begin
              img_temp[0,fitsY,fitsX]:=0; {clear pixel count}
              for col:=0 to head.naxis3-1 do
                img_average[col,fitsY,fitsX]:=pedestal-background; {clear img_average}
            end;

          //not the most efficient but it uses the standard procedures
          stack_arrays( img_average, img_loaded, img_temp, solution_vectorX,solution_vectorY, 0 {background},1{ weightf});//add B to A

         for col:=0 to head.naxis3-1 do //this runs unthreaded 0.13 sec. with col as third loop 0.15 sec. Threaded takes 0.43 sec.  In colour about 3 time longer
           for fitsY:=0 to height_average-1 do
             for fitsX:=0 to width_average-1 do
             begin
               value:=img_temp[0,fitsY,fitsX];
               if value>0 then
                  img_loaded[col,fitsY,fitsX]:=pedestal+img_average[col,fitsY,fitsX]/value;//scale to one image by diving by the number of pixels added
               end;

          {save}
          filename2:=ChangeFileExt(Filename2,'_aligned.fit');{rename}
          head.pedestal:=pedestal;

          mainform1.Memo1.Lines.beginUpdate;

          if head_ref.cd1_1<>0 then
          begin //use the solution of the reference image
            update_float(mainform1.memo1.lines,'CRPIX1  =',' / X of reference pixel                           ',false,head_ref.crpix1);
            update_float(mainform1.memo1.lines,'CRPIX2  =',' / Y of reference pixel                           ',false ,head_ref.crpix2);

            update_float(mainform1.memo1.lines,'CRVAL1  =',' / RA of reference pixel (deg)                    ',false ,head_ref.ra0*180/pi);
            update_float(mainform1.memo1.lines,'CRVAL2  =',' / DEC of reference pixel (deg)                   ',false ,head_ref.dec0*180/pi);


            update_float(mainform1.memo1.lines,'CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head_ref.cd1_1);
            update_float(mainform1.memo1.lines,'CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head_ref.cd1_2);
            update_float(mainform1.memo1.lines,'CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head_ref.cd2_1);
            update_float(mainform1.memo1.lines,'CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head_ref.cd2_2);

            if head_ref.crota1<>0 then
            begin
              update_float(mainform1.memo1.lines,'CROTA1  =',' / Image twist X axis (deg)                       ',false ,head_ref.crota1);
              update_float(mainform1.memo1.lines,'CROTA2  =',' / Image twist Y axis (deg) E of N if not flipped.',false ,head_ref.crota2);
            end;
            if head_ref.crota1<>0 then
            begin
              update_float(mainform1.memo1.lines,'CDELT1  =',' / X pixel size (deg)                             ',false ,head_ref.cdelt1);
              update_float(mainform1.memo1.lines,'CDELT2  =',' / Y pixel size (deg)                             ',false ,head_ref.cdelt2);
            end;
          end;//update solution
          update_text(mainform1.memo1.lines,'COMMENT 1','  Calibrated & aligned by ASTAP. www.hnsky.org');
          update_integer(mainform1.memo1.lines,'PEDESTAL=',' / Value added during calibration or stacking     ',round(head.pedestal));//pedestal value added during calibration or stacking
          update_text(mainform1.memo1.lines,'CALSTAT =', #39 + head.calstat+#39); {calibration status.}
          update_integer(mainform1.memo1.lines,'DARK_CNT=',' / Darks used for luminance.               ' ,head.dark_count);{for interim lum,red,blue...files. Compatible with master darks}
          update_integer(mainform1.memo1.lines,'FLAT_CNT=',' / Flats used for luminance.               ' ,head.flat_count);{for interim lum,red,blue...files. Compatible with master flats}
          update_integer(mainform1.memo1.lines,'BIAS_CNT=',' / Flat-darks used for luminance.          ' ,head.flatdark_count);{for interim lum,red,blue...files. Compatible with master flats}
          mainform1.Memo1.Lines.EndUpdate;

          { ASTAP keyword standard:}
          { interim files can contain keywords: head.exposure, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
          { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

          if save_fits(img_loaded,mainform1.memo1.lines,head,filename2,true)=false then exit;//exit if save error
          memo2_message('New aligned image created: '+filename2);
          report_results(object_name,inttostr(round(head.exposure)),0,-1 {color icon}, 5 {stack icon});{report result in tab result using modified filename2}
          progress_indicator(0.1+0.9*counter/images_checked,'Cal');{show progress}
        end;
        finally
        end;
      end;{try}
    end;{}
  end;  {with stackmenu1}

  //use solution of reference image. if any
  head.cd1_1:=head_ref.cd1_1;
  head.cd1_2:=head_ref.cd1_2;
  head.cd2_1:=head_ref.cd2_1;
  head.cd2_2:=head_ref.cd2_2;
  head.ra0:=head_ref.ra0;
  head.dec0:=head_ref.dec0;
  head.cdelt1:=head_ref.cdelt1;
  head.cdelt2:=head_ref.cdelt2;
  head.crota1:=head_ref.crota1;//redundant
  head.crota2:=head_ref.crota2;
  head.crpix1:=head_ref.crpix1;
  head.crpix2:=head_ref.crpix2;

  plot_histogram(img_loaded, True {update}); {plot histogram, set sliders}
  plot_image(mainform1.image1,true);{update to last image, activate memo1}

  {arrays will be nilled later. This is done for early exits}
end;   {calibration and alignment}




end.

