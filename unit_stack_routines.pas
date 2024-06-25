unit unit_stack_routines;
{Copyright (C) 2017, 2024 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

{$mode delphi}
interface
uses
  Classes, SysUtils,forms, math, unit_stack, astap_main, unit_star_align;

procedure stack_LRGB( var files_to_process : array of TfileToDo; out counter : integer );{stack LRGB mode}
procedure stack_average(process_as_osc:integer; var files_to_process : array of TfileToDo; out counter : integer);{stack average}

procedure stack_mosaic(process_as_osc:integer; var files_to_process : array of TfileToDo; max_dev_backgr: double; out counter : integer);{mosaic/tile mode}

procedure stack_sigmaclip(process_as_osc:integer; var files_to_process : array of TfileToDo; out counter : integer); {stack using sigma clip average}
procedure calibration_and_alignment(process_as_osc:integer; var files_to_process : array of TfileToDo; out counter : integer); {calibration_and_alignment only}

{$inline on}  {!!! Set this off for debugging}
procedure calc_newx_newy(vector_based : boolean; fitsXfloat,fitsYfloat: double); inline; {apply either vector or astrometric correction}
procedure astrometric_to_vector; {convert astrometric solution to vector solution}
procedure initialise_calc_sincos_dec0;{set variables correct}
function test_bayer_matrix(img: image_array) :boolean;  {test statistical if image has a bayer matrix. Execution time about 1ms for 3040x2016 image}
procedure stack_comet(process_as_osc:integer; var files_to_process : array of TfileToDo; out counter : integer); {stack using sigma clip average}

var
  pedestal_s : double;{target background value}

var
  SIN_dec0,COS_dec0,x_new_float,y_new_float,SIN_dec_ref,COS_dec_ref : double;
  gain_refxxx: string;


implementation

uses unit_astrometric_solving, unit_contour;


procedure  calc_newx_newy(vector_based : boolean; fitsXfloat,fitsYfloat: double); inline; {apply either vector or astrometric correction. Fits in 1..width, out range 0..width-1}
var
  u,u0,v,v0,dRa,dDec,delta,ra_new,dec_new,delta_ra,det,gamma,SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,h: double;
Begin

  if vector_based then {vector based correction}
  begin
     x_new_float:=solution_vectorX[0]*(fitsxfloat-1)+solution_vectorX[1]*(fitsYfloat-1)+solution_vectorX[2]; {correction x:=aX+bY+c  x_new_float in image array range 0..head.width-1}
     y_new_float:=solution_vectorY[0]*(fitsxfloat-1)+solution_vectorY[1]*(fitsYfloat-1)+solution_vectorY[2]; {correction y:=aX+bY+c}
  end
  else
  begin {astrometric based correction}
    {6. Conversion (x,y) -> (RA,DEC)  for image to be added}
    u0:=fitsXfloat-head.crpix1;
    v0:=fitsYfloat-head.crpix2;

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

    dRa :=(head.cd1_1 * u +head.cd1_2 * v)*pi/180;
    dDec:=(head.cd2_1 * u +head.cd2_2 * v)*pi/180;
    delta:=COS_dec0 - dDec*SIN_dec0;
    gamma:=sqrt(dRa*dRa+delta*delta);
    RA_new:=head.ra0+arctan(Dra/delta);
    DEC_new:=arctan((SIN_dec0+dDec*COS_dec0)/gamma);


   {5. Conversion (RA,DEC) -> (x,y) of reference image}
    sincos(dec_new,SIN_dec_new,COS_dec_new);{sincos is faster then separate sin and cos functions}
    //sincos(head_ref.dec0,SIN_dec_ref,COS_dec_ref); Alread done during initialisaion
    delta_ra:=RA_new-head_ref.ra0;
    sincos(delta_ra,SIN_delta_ra,COS_delta_ra);

    H := SIN_dec_new*sin_dec_ref + COS_dec_new*COS_dec_ref*COS_delta_ra;
    dRA := (COS_dec_new*SIN_delta_ra / H)*180/pi;
    dDEC:= ((SIN_dec_new*COS_dec_ref - COS_dec_new*SIN_dec_ref*COS_delta_ra ) / H)*180/pi;

    det:=head_ref.CD2_2*head_ref.CD1_1 - head_ref.CD1_2*head_ref.CD2_1;

    u0:= - (head_ref.CD1_2*dDEC - head_ref.CD2_2*dRA) / det;
    v0:= + (head_ref.CD1_1*dDEC - head_ref.CD2_1*dRA) / det;

    if ap_order>=2 then {apply SIP correction up to second order}
    begin
      x_new_float:=(head_ref.crpix1 + u0+ap_0_1*v0+ ap_0_2*v0*v0+ ap_0_3*v0*v0*v0 +ap_1_0*u0 + ap_1_1*u0*v0+  ap_1_2*u0*v0*v0+ ap_2_0*u0*u0 + ap_2_1*u0*u0*v0+  ap_3_0*u0*u0*u0)-1;{3th order SIP correction, fits count from 1, image from zero therefore subtract 1}
      y_new_float:=(head_ref.crpix2 + v0+bp_0_1*v0+ bp_0_2*v0*v0+ bp_0_3*v0*v0*v0 +bp_1_0*u0 + bp_1_1*u0*v0+  bp_1_2*u0*v0*v0+ bp_2_0*u0*u0 + bp_2_1*u0*u0*v0+  bp_3_0*u0*u0*u0)-1;{3th order SIP correction}
    end
    else
    begin
      x_new_float:=(head_ref.crpix1 + u0)-1; {in image array range 0..width-1}
      y_new_float:=(head_ref.crpix2 + v0)-1;
    end;
  end;{astrometric}
end;{calc_newx_newy}


procedure astrometric_to_vector;{convert astrometric solution to vector solution}
var
  flipped,flipped_reference  : boolean;
  centerX,centerY,scale_correctionX,scale_correctionY    : double;

begin
  a_order:=0; {SIP correction should be zero by definition}

  calc_newx_newy(false,head.crpix1, head.crpix2) ;//this will only work well for 1th orde solutions
  centerX:=x_new_float;
  centerY:=y_new_float;

  calc_newx_newy(false,head.crpix1+1, head.crpix2); {move one pixel in X}

  solution_vectorX[0]:=+(x_new_float- centerX);
  solution_vectorX[1]:=-(y_new_float- centerY);

  calc_newx_newy(false,head.crpix1, head.crpix2+1);{move one pixel in Y}

  solution_vectorY[0]:=-(x_new_float- centerX);
  solution_vectorY[1]:=+(y_new_float- centerY);

 //Correction for image distortion. The solution was extracted by comparison the distorted image with a linear star database. The solution factors are then typical a tiny amount smaller then "one"
  scale_correctionX:=sqrt(sqr(solution_vectorX[0])+sqr(solution_vectorX[1]));//for scale to "one"
  scale_correctionX:=scale_correctionX*head_ref.cdelt1/head.cdelt1;//relative scale to reference image. Note a temperature change is followed by a focus correction and therefore a change in image scale.
  solution_vectorX[0]:=solution_vectorX[0]/scale_correctionX;//apply correction
  solution_vectorX[1]:=solution_vectorX[1]/scale_correctionX;

  scale_correctionY:=sqrt(sqr(solution_vectorY[0])+sqr(solution_vectorY[1]));//for scale to "one"
  scale_correctionY:=scale_correctionY*head_ref.cdelt2/head.cdelt2;//relative scale to reference image. Note a temperature change is followed by a focus correction and therefore a change in image scale.
  solution_vectorY[0]:=solution_vectorY[0]/scale_correctionY;//apply correction
  solution_vectorY[1]:=solution_vectorY[1]/scale_correctionY;


  calc_newx_newy(false,(head.crpix1)*(1-scale_correctionX)+1, (head.crpix2)*(1-scale_correctionY)+1);
  solution_vectorX[2]:=  x_new_float;//range 0..width-1
  solution_vectorY[2]:=  Y_new_float;

  flipped:=head.cd1_1*head.cd2_2 - head.cd1_2*head.cd2_1>0; {Flipped image. Either flipped vertical or horizontal but not both. Flipped both horizontal and vertical is equal to 180 degrees rotation and is not seen as flipped}
  flipped_reference:=head_ref.cd1_1*head_ref.cd2_2 - head_ref.cd1_2*head_ref.cd2_1>0; {flipped reference image}

  if flipped<>flipped_reference then {this can happen is user try to add images from a diffent camera/setup}
  begin
    solution_vectorX[1]:=-solution_vectorX[1];
    solution_vectorY[0]:=-solution_vectorY[0];
  end;
  if stackmenu1.solve_show_log1.checked then memo2_message('Astrometric vector solution '+solution_str)
end;


procedure initialise_calc_sincos_dec0;{set variables correct}
begin
  sincos(head.dec0,SIN_dec_ref,COS_dec_ref);{do this in advance to reduce calculations since  it is for each pixel the same. For blink header "head" is used instead of "head_ref"}
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
//    pixel_to_celestial(head,1,1,1 {formalism},  ra1,dec1 );

    sincos(head.dec0,SIN_dec0,COS_dec0);//intilialize SIN_dec0,COS_dec0
    astrometric_to_vector;{convert 1th order astrometric solution to a vector solution}

    dummy:=stackmenu1.ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X];
    dummy:=stackmenu1.ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y];


    //convert the astroid position to ra, dec
    pixel_to_celestial(head,strtofloat2(stackmenu1.ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]),strtofloat2(stackmenu1.ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]),1 {formalism},  ra1,dec1 );
    //calculate the astroid position to x,y coordinated of the reference image
    celestial_to_pixel(head_ref, ra1,dec1,x1,y1);//ra,dec  ref image to fitsX,fitsY second image


    //convert the center based solution to solution with origin at 0,0
    if solution_vectorX[0]<0  then
       solution_vectorX[2]:=solution_vectorX[2]+head.width-1;

    if solution_vectorY[1]<0  then
       solution_vectorY[2]:=solution_vectorY[2]+head.height-1;


    shiftX:=x1 {-1} - referenceX{-1}; //The asteroid correction. The two subtractions are neutralizing each other
    shiftY:=y1 {-1} - referenceY{-1}; //The asteroid correction. The two subtractions are neutralizing each other

    solution_vectorX[2]:=solution_vectorX[2]-shiftx;
    solution_vectorY[2]:=solution_vectorY[2]-shifty;
  end;
end;



procedure stack_LRGB(var files_to_process : array of TfileToDo; out counter : integer );{stack LRGB mode}
var
  fitsX,fitsY,c,width_max, height_max, x_new,y_new, binning,max_stars,col  : integer;
  background_r, background_g, background_b, background_l ,
  rgbsum,red_f,green_f,blue_f, value ,colr, colg,colb, red_add,green_add,blue_add,
  rr_factor, rg_factor, rb_factor,
  gr_factor, gg_factor, gb_factor,
  br_factor, bg_factor, bb_factor,
  saturated_level,hfd_min,tempval,aa,bb,cc,dd,ee,ff                                        : double;
  init, solution,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,use_sip : boolean;
  warning             : string;
  starlist1,starlist2 : star_list;
  img_temp,img_average : image_array;
begin
  with stackmenu1 do
  begin

    {move often uses setting to booleans. Great speed improved if use in a loop and read many times}
    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometry_alignment1.checked;
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
      rr_factor:=strtofloat2(rr1.text);
      rg_factor:=strtofloat2(rg1.text);
      rb_factor:=strtofloat2(rb1.text);

      gr_factor:=strtofloat2(gr1.text);
      gg_factor:=strtofloat2(gg1.text);
      gb_factor:=strtofloat2(gb1.text);

      br_factor:=strtofloat2(br1.text);
      bg_factor:=strtofloat2(bg1.text);
      bb_factor:=strtofloat2(bb1.text);


      background_r:=0;
      background_g:=0;
      background_b:=0;
      background_l:=0;
      red_add:=strtofloat2(red_filter_add1.text);
      green_add:=strtofloat2(green_filter_add1.text);
      blue_add:=strtofloat2(blue_filter_add1.text);


      for c:=0 to length(files_to_process)-1 do  {should contain reference,r,g,b,rgb,l}
      begin
        if c=5 then {all colour files added, correct for the number of pixel values added at one pixel. This can also happen if one colour has an angle and two pixel fit in one!!}
        begin {fix RGB stack}
          memo2_message('Correcting the number of pixels added together.');
          for fitsY:=0 to height_max-1 do
          for fitsX:=0 to width_max-1 do
          for col:=0 to 2 do
          begin
            tempval:=img_temp[col,fitsY,fitsX];
            if tempval>0 then //Note tempval>1 is very very rare. In 99.99% cases tempval is 1 and no more then one pixel combined. Seen more then one pixel only for astrometric stacking
               img_average[col,fitsY,fitsX]:=500+img_average[col,fitsY,fitsX]/tempval {scale to one image by diving by the number of pixels added}
             else
             img_average[col,fitsY,fitsX]:=0;//This will set all colours of a single pixel to zero if one of the colour is saturated and marked by image_temp[]:=-9;
          end;
          memo2_message('Applying black spot filter on interim RGB image.');
          black_spot_filter(img_average); //Black spot filter and add bias. Note for 99,99% zero means black spot but it could also be coincidence
        end;{c=5, all colour files added}

        if length(files_to_process[c].name)>0 then
        begin
          try { Do some lengthy operation }
            filename2:=files_to_process[c].name;
            if c=0 then memo2_message('Loading reference image: "'+filename2+'".');
            if c=1 then memo2_message('Adding red file: "'+filename2+'"  to final image.');
            if c=2 then memo2_message('Adding green file: "'+filename2+'"  to final image.');
            if c=3 then memo2_message('Adding blue file: "'+filename2+'"  to final image.');
            if c=4 then memo2_message('Adding RGB file: "'+filename2+'"  to final image.');
            if c=5 then memo2_message('Using luminance file: "'+filename2+'"  for final image.');

            {load image}
            Application.ProcessMessages;
            if esc_pressed then begin memo2_message('ESC pressed.');exit;end;
            if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainwindow.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;

            if init=false then
            begin
              head_ref:=head;{backup solution}
              initialise_calc_sincos_dec0;{set variables correct, do this before apply dark}
             // initialise_var2;{set variables correct}
            end;

            if use_sip=false then a_order:=0; //stop using SIP from the header in astrometric mode
            saturated_level:=head.datamax_org*0.97;{130}

            if c=1 then
            begin
               get_background(0,img_loaded,true,false, {out} bck);{unknown, do not calculate noise_level}
               background_r:=bck.backgr;
               //cblack:=round( background_r);
               counterR:=head.light_count ;counterRdark:=head.dark_count; counterRflat:=head.flat_count; counterRbias:=head.flatdark_count; exposureR:=round(head.exposure);temperatureR:=head.set_temperature;{for historical reasons}
            end;
            if c=2 then
            begin
              get_background(0,img_loaded,true,false, {out} bck);{unknown, do not calculate noise_level}
              background_g:=bck.backgr;
              //cblack:=round( background_g);
              counterG:=head.light_count;counterGdark:=head.dark_count; counterGflat:=head.flat_count; counterGbias:=head.flatdark_count; exposureG:=round(head.exposure);temperatureG:=head.set_temperature;
            end;
            if c=3 then
            begin
              get_background(0,img_loaded,true,false, {out} bck);{unknown, do not calculate noise_level}
              background_b:=bck.backgr;
              //cblack:=round( background_b);
              counterB:=head.light_count; counterBdark:=head.dark_count; counterBflat:=head.flat_count; counterBbias:=head.flatdark_count; exposureB:=round(head.exposure);temperatureB:=head.set_temperature;
            end;
            if c=4 then
            begin
              get_background(0,img_loaded,true,false, {out} bck);{unknown, do not calculate noise_level}
              background_r:=bck.backgr;

              //cblack:=round( background_r);
              background_g:=background_r;
              background_b:=background_r;
              counterRGB:=head.light_count; counterRGBdark:=head.dark_count; counterRGBflat:=head.flat_count; counterRGBbias:=head.flatdark_count; exposureRGB:=round(head.exposure);;temperatureRGB:=head.set_temperature;
            end;
            if c=5 then {Luminance}
            begin
              get_background(0,img_loaded,true,false, {out} bck);{unknown, do not calculate noise_level}
              background_L:=bck.backgr;
              //cblack:=round( background_L);
              counterL:=head.light_count; counterLdark:=head.dark_count; counterLflat:=head.flat_count; counterLbias:=head.flatdark_count; exposureL:=round(head.exposure);temperatureL:=head.set_temperature;
            end;

            if use_astrometry_internal then {internal solver, create new solutions for the R, G, B and L stacked images if required}
            begin
              memo2_message('Preparing astrometric solution for interim file: '+filename2);
              if head.cd1_1=0 then solution:= update_solution_and_save(img_loaded,head,mainwindow.memo1.lines) else solution:=true;
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
                bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist1,warning);{bin, measure background, find stars}
                find_quads(starlist1,quad_star_distances1);{find quads for reference image/database}
              end;
            end;

            if init=false then {init}
            begin
              height_max:=head.height;
              width_max:=head.width;

              setlength(img_average,3,height_max,width_max);{will be color}
              setlength(img_temp,3,height_max,width_max);

              for fitsY:=0 to height_max-1 do
                for fitsX:=0 to width_max-1 do
                  for col:=0 to 2 do
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
                  bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist2,warning);{bin, measure background, find stars}

                  find_quads(starlist2,quad_star_distances2);{find star quads for new image}
                  if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then {find difference between ref image and new image}
                    memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.  ' +solution_str)
                  else
                  begin
                    memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
                    files_to_process[c].name:=''; {remove file from list}
                   solution:=false;
                    ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[L_result]:=6;{mark 3th column with exclaimation}
                    ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_result]:='no solution';{no stack result}
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
              date_to_jd(head.date_obs,head.date_avg,head.exposure);{convert head.date_obs string and head.exposure time to global variables jd_start (julian day start head.exposure) and jd_mid (julian day middle of the head.exposure)}
              jd_start_first:=min(jd_start,jd_start_first);{find the begin date}
              jd_end_last:=max(jd_end,jd_end_last);{find latest end time}
              jd_sum:=jd_sum+jd_mid;{sum julian days of images at midpoint exposure}

              if use_astrometry_internal then
                 astrometric_to_vector;{convert 1th order astrometric solution to vector solution}

              aa:=solution_vectorX[0];//move to local variable for minor faster processing
              bb:=solution_vectorX[1];
              cc:=solution_vectorX[2];
              dd:=solution_vectorY[0];
              ee:=solution_vectorY[1];
              ff:=solution_vectorY[2];


              for fitsY:=0 to head.height-1 do {skip outside pixels if color}
              for fitsX:=0 to head.width-1 do
              begin
                x_new:=round(aa*(fitsx)+bb*(fitsY)+cc); {correction x:=aX+bY+c  result in image array range 0..head.width-1}
                y_new:=round(dd*(fitsx)+ee*(fitsY)+ff); {correction y:=aX+bY+c}

                if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
                begin
                  if c=1 {red} then
                  begin
                    value:=img_loaded[0,fitsY,fitsX];
                    if value>saturated_level then {saturation, mark all three colors as black spot (<=0) to maintain star colour}
                    begin
                      for col:=0 to 2 do
                        img_temp[col,y_new,x_new]:=-9;//mark all colours as saturated if one colour is saturated.
                    end
                    else
                    begin
                      value:=(value-background_r);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if rr_factor>0.00001 then begin img_average[0,y_new,x_new]:=img_average[0,y_new,x_new] + rr_factor*value;{execute only if greater then zero for speed}img_temp[0,y_new,x_new]:=img_temp[0,y_new,x_new]+1; end;
                      if rg_factor>0.00001 then begin img_average[1,y_new,x_new]:=img_average[1,y_new,x_new] + rg_factor*value; img_temp[1,y_new,x_new]:=img_temp[1,y_new,x_new]+1; end;
                      if rb_factor>0.00001 then begin img_average[2,y_new,x_new]:=img_average[2,y_new,x_new] + rb_factor*value; img_temp[2,y_new,x_new]:=img_temp[2,y_new,x_new]+1; end;
                    end;
                  end;
                  if c=2 {green} then
                  begin
                    value:=img_loaded[0,fitsY,fitsX];
                    if value>saturated_level then {saturation, mark all three colors as black spot (<=0) to maintain star colour}
                    begin
                      for col:=0 to 2 do
                         img_temp[col,y_new,x_new]:=-9;//mark all colours as saturated if one colour is saturated.
                    end
                    else
                    begin
                      value:=(value-background_g);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if gr_factor>0.00001 then begin img_average[0,y_new,x_new]:=img_average[0,y_new,x_new] + gr_factor*value;{execute only if greater then zero for speed}img_temp[0,y_new,x_new]:=img_temp[0,y_new,x_new]+1;  end;
                      if gg_factor>0.00001 then begin img_average[1,y_new,x_new]:=img_average[1,y_new,x_new] + gg_factor*value;img_temp[1,y_new,x_new]:=img_temp[1,y_new,x_new]+1; end;
                      if gb_factor>0.00001 then begin img_average[2,y_new,x_new]:=img_average[2,y_new,x_new] + gb_factor*value;img_temp[2,y_new,x_new]:=img_temp[2,y_new,x_new]+1; end;
                    end;
                  end;
                  if c=3 {blue}  then
                  begin
                    value:=img_loaded[0,fitsY,fitsX];
                    if value>saturated_level then {saturation, mark all three colors as black spot (<=0) to maintain star colour}
                    begin
                      for col:=0 to 2 do
                         img_temp[col,y_new,x_new]:=-9;//mark all colours as saturated if one colour is saturated.
                    end
                    else
                    begin
                      value:=(value-background_b);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if br_factor>0.00001 then begin img_average[0,y_new,x_new]:=img_average[0,y_new,x_new] + br_factor*value;{execute only if greater then zero for speed}img_temp[0,y_new,x_new]:=img_temp[0,y_new,x_new]+1;  end;
                      if bg_factor>0.00001 then begin img_average[1,y_new,x_new]:=img_average[1,y_new,x_new] + bg_factor*value; img_temp[1,y_new,x_new]:=img_temp[1,y_new,x_new]+1;end;
                      if bb_factor>0.00001 then begin img_average[2,y_new,x_new]:=img_average[2,y_new,x_new] + bb_factor*value; img_temp[2,y_new,x_new]:=img_temp[2,y_new,x_new]+1;end;
                    end;
                  end;
                  if c=4 {RGB image, naxis3=3}   then
                  begin
                    begin img_average[0,y_new,x_new]:=img_average[0,y_new,x_new] + img_loaded[0,fitsY,fitsX]-background_r; img_temp[0,y_new,x_new]:=img_temp[0,y_new,x_new]+1; end;
                    begin img_average[1,y_new,x_new]:=img_average[1,y_new,x_new] + img_loaded[1,fitsY,fitsX]-background_g; img_temp[1,y_new,x_new]:=img_temp[1,y_new,x_new]+1; end;
                    begin img_average[2,y_new,x_new]:=img_average[2,y_new,x_new] + img_loaded[2,fitsY,fitsX]-background_b; img_temp[2,y_new,x_new]:=img_temp[2,y_new,x_new]+1; end;
                  end;
                  if c=5 {Luminance} then
                  begin
                    {r:=l*(0.33+r)/(r+g+b)}
                    colr:=img_average[0,y_new,x_new] - 475 + red_add; {lowest_most_common is around 450 to 500}
                    colg:=img_average[1,y_new,x_new] - 475 + green_add;
                    colb:=img_average[2,y_new,x_new] - 475 + blue_add;

                    rgbsum:=colr+colg+colb;
                    if rgbsum<0.1 then begin rgbsum:=0.1; red_f:=rgbsum/3; green_f:=red_f; blue_f:=red_f;end
                    else
                    begin
                      red_f:=colr/rgbsum;   if red_f<0   then red_f:=0;  if red_f>1 then   red_f:=1;
                      green_f:=colg/rgbsum; if green_f<0 then green_f:=0;if green_f>1 then green_f:=1;
                      blue_f:=colb/rgbsum;  if blue_f<0  then blue_f:=0; if blue_f>1 then  blue_f:=1;
                    end;

                    img_average[0,y_new,x_new]:=1000+(img_loaded[0,fitsY,fitsX] - background_l)*(red_f);
                    img_average[1,y_new,x_new]:=1000+(img_loaded[0,fitsY,fitsX] - background_l)*(green_f);
                    img_average[2,y_new,x_new]:=1000+(img_loaded[0,fitsY,fitsX] - background_l)*(blue_f);
                  end;
                end;
              end;
            end;
            progress_indicator(94+c,' LRGB');{show progress, 95..99}
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


function test_bayer_matrix(img: image_array) :boolean;  {test statistical if image has a bayer matrix. Execution time about 1ms for 3040x2016 image}
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


procedure stack_average(process_as_osc :integer; var files_to_process : array of TfileToDo; out counter : integer);{stack average}
var
    fitsX,fitsY,c,width_max, height_max,old_width, old_height,x_new,y_new,col,binning,max_stars,old_naxis3                     : integer;
    background_correction, weightF,hfd_min,aa,bb,cc,dd,ee,ff                                                                   : double;
    init, solution,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,use_sip                                   : boolean;
    tempval                                                                                                                    : single;
    warning             : string;
    starlist1,starlist2 : star_list;
    img_temp,img_average : image_array;
begin
  with stackmenu1 do
  begin
    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometry_alignment1.checked;

    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}
    max_stars:=strtoint2(stackmenu1.max_stars1.text,500);{maximum star to process, if so filter out brightest stars later}
    use_sip:=stackmenu1.add_sip1.checked;

    counter:=0;
    sum_exp:=0;
    sum_temp:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_start_first:=1E99;{begin observations in Julian day}
    jd_end_last:=0;{end observations in Julian day}

    init:=false;

    background_correction:=0;
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
          if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainwindow.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;
          if init=false then
          begin {init is false, first image}
            old_width:=head.width;
            old_height:=head.height;
            old_naxis3:=head.naxis3;

            add_text(mainwindow.memo1.lines,'COMMENT 9', '  Reference file was ' + filename2);
            head_ref:=head;{backup solution}
            initialise_calc_sincos_dec0;{set variables correct. Do this before apply dark}
            //initialise_var2;{set variables correct}
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

          if init=false then {init}
          begin
            jd_mid_reference:=jd_mid; //for ephemeris stacking
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

            if ((use_manual_align) or (use_ephemeris_alignment)) then
            begin
              referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
              referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
            end
            else
            if  use_astrometry_internal=false then
            begin
              bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist1,warning);{bin, measure background, find stars}
              find_quads(starlist1, quad_star_distances1);{find quads for reference image}
              pedestal_s:=bck.backgr;{correct for difference in background, use cblack from first image as reference. Some images have very high background values up to 32000 with 6000 noise, so fixed pedestal_s of 1000 is not possible}
              if pedestal_s<500 then
                pedestal_s:=500;{prevent image noise could go below zero}
              background_correction:=pedestal_s-bck.backgr;
              head.datamax_org:=head.datamax_org+background_correction; if head.datamax_org>$FFFF then  head.datamax_org:=$FFFF; {note head.datamax_org is already corrected in apply dark}
              head.pedestal:=background_correction;
            end;
          end;{init, c=0}

          solution:=true;
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
                bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist2,warning);{bin, measure background, find stars}

                background_correction:=pedestal_s-bck.backgr;
                head.datamax_org:=head.datamax_org+background_correction; if head.datamax_org>$FFFF then  head.datamax_org:=$FFFF; {note head.datamax_org is already corrected in apply dark}
                head.pedestal:=background_correction;


                find_quads(starlist2, quad_star_distances2);{find star quads for new image}
                if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then {find difference between ref image and new image}
                   memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.  '+solution_str)
                else
                begin
                  memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
                  files_to_process[c].name:=''; {remove file from list}
                  solution:=false;
                  ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[L_result]:=6;{mark 3th column with exclaimation}
                  ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[2]:='no solution';{no stack result}
                end;
              end;{internal alignment}
            end
            else
            reset_solution_vectors(1);{no influence on the first image}

          end;
          init:=true;{initialize for first image done}

          if solution then
          begin
            inc(counter);
            sum_exp:=sum_exp+head.exposure;
            sum_temp:=sum_temp+head.set_temperature;

            weightF:=calc_weightF;{calculate weighting factor for different exposure duration and gain}

            date_to_jd(head.date_obs,head.date_avg,head.exposure);{convert head.date_obs string and head.exposure time to global variables jd_start (julian day start head.exposure) and jd_mid (julian day middle of the head.exposure)}
            jd_start_first:=min(jd_start,jd_start_first);{find the begin date}
            jd_end_last:=max(jd_end,jd_end_last);{find latest end time}
            jd_sum:=jd_sum+jd_mid;{sum julian days of images at midpoint exposure}
            airmass_sum:=airmass_sum+airmass;

            if use_astrometry_internal then
              astrometric_to_vector;{convert 1th order astrometric solution to vector solution}

            aa:=solution_vectorX[0]; //move to local variables for some speed improvement
            bb:=solution_vectorX[1];
            cc:=solution_vectorX[2];
            dd:=solution_vectorY[0];
            ee:=solution_vectorY[1];
            ff:=solution_vectorY[2];

            for fitsY:=0 to head.height-1 do {skip outside "bad" pixels if mosaic mode}
            for fitsX:=0 to head.width-1  do
            begin
              x_new:=round(aa*(fitsx)+bb*(fitsY)+cc); {correction x:=aX+bY+c  x_new_float in image array range 0..head.width-1}
              y_new:=round(dd*(fitsx)+ee*(fitsY)+ff); {correction y:=aX+bY+c}

              if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
              begin
                for col:=0 to head.naxis3-1 do {all colors}
                  img_average[col,y_new,x_new]:=img_average[col,y_new,x_new]+ img_loaded[col,fitsY,fitsX]*weightf;{image loaded is already corrected with dark and flat}{NOTE: fits count from 1, image from zero}

                img_temp[0,y_new,x_new]:=img_temp[0,y_new,x_new]+weightF{typical 1};{count the number of image pixels added=samples.}
              end;
            end;

          end;

          progress_indicator(10+89*counter/images_selected,' Stacking');{show progress}
          finally
        end;
      end;

      if counter<>0 then
      begin
        head_ref.naxis3:= head.naxis3; {store colour info in reference header}
        head_ref.naxis:=  head.naxis;  {store colour info in reference header}
        head_ref.datamax_org:= head.datamax_org;  {for 8 bit files, they are now 500 minimum}
        head:=head_ref;{restore solution variable of reference image for annotation and mount pointer. Works only if not resized}
        head.height:=height_max;
        head.width:=width_max;
        setlength(img_loaded,head.naxis3,head.height,head.width);{new size}

        for fitsY:=0 to head.height-1 do
        for fitsX:=0 to head.width-1 do
        begin {pixel loop}
          tempval:=img_temp[0,fitsY,fitsX];
          for col:=0 to head.naxis3-1 do
          begin {colour loop}
            if tempval<>0 then img_loaded[col,fitsY,fitsX]:=background_correction+img_average[col,fitsY,fitsX]/tempval {scale to one image by diving by the number of pixels added}
            else
            begin { black spot filter or missing value filter due to image rotation}
              if ((fitsX>0) and (img_temp[0,fitsY,fitsX-1]<>0)) then img_loaded[col,fitsY,fitsX]:=background_correction+img_loaded[col,fitsY,fitsX-1]{take nearest pixel x-1 as replacement}
              else
              if ((fitsY>0) and (img_temp[0,fitsY-1,fitsX]<>0)) then img_loaded[col,fitsY,fitsX]:=background_correction+img_loaded[col,fitsY-1,fitsX]{take nearest pixel y-1 as replacement}
              else
              img_loaded[col,fitsY,fitsX]:=0;{clear img_loaded since it is resized}
            end; {black spot}
          end;{colour loop}
        end;{pixel loop}
      end; {counter<>0}
    end;{simple average}
  end;{with stackmenu1}
  {arrays will be nilled later. This is done for early exits}
end;


procedure calculate_required_dimensions(head_ref,head: theader; var x_min,x_max,y_min,y_max: double);//for image stitching mode
var
  ra,dec,x,y : double;
  formalism : integer;
begin
  formalism:=mainwindow.Polynomial1.itemindex;
  pixel_to_celestial(head,1,1,formalism , ra, dec); //left bottom
  celestial_to_pixel(head_ref, ra,dec, x,y);{ra,dec to fitsX,fitsY}
  x_min:=min(x_min,x);
  x_max:=max(x_max,x);
  y_min:=min(y_min,y);
  y_max:=max(y_max,y);
  pixel_to_celestial(head,head.width,1,formalism , ra, dec);  //right bottom
  celestial_to_pixel(head_ref, ra,dec, x,y);{ra,dec to fitsX,fitsY}
  x_min:=min(x_min,x);
  x_max:=max(x_max,x);
  y_min:=min(y_min,y);
  y_max:=max(y_max,y);
  pixel_to_celestial(head,1,head.height,formalism , ra, dec); //left top
  celestial_to_pixel(head_ref, ra,dec, x,y);{ra,dec to fitsX,fitsY}
  x_min:=min(x_min,x);
  x_max:=max(x_max,x);
  y_min:=min(y_min,y);
  y_max:=max(y_max,y);
  pixel_to_celestial(head,head.width,head.height,formalism, ra, dec); //right top
  celestial_to_pixel(head_ref, ra,dec, x,y);{ra,dec to fitsX,fitsY}
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


procedure stack_mosaic(process_as_osc:integer; var files_to_process : array of TfileToDo; max_dev_backgr: double; out counter : integer);{mosaic/tile mode}
var
    fitsX,fitsY,c,width_max, height_max,x_new,y_new,col, cropW,cropH,iterations,greylevels,count,formalism   : integer;
    value, dummy,median,median2,delta_median,correction,maxlevel,mean,noise,hotpixels,coverage,
    raMiddle,decMiddle,  x_min,x_max,y_min,y_max,total_fov,fw,fh     : double; //for mosaic

    tempval                                                          : single;
    init, vector_based,merge_overlap,equalise_background,use_sip     : boolean;
    background_correction,background_correction_center,background    : array[0..2] of double;
    counter_overlap                                                  : array[0..2] of integer;
    bck                                                              : array[0..3] of double;
    oldsip                                                           : boolean;
    img_temp,img_average : image_array;

begin
  with stackmenu1 do
  begin
    //find dimensions of this package
    memo2_message('Analysing and calculating celestial field-of-view dimensions.');
    x_min:=0;//for mosaic mode
    x_max:=0;
    y_min:=0;
    y_max:=0;
    formalism:=mainwindow.Polynomial1.itemindex;

    count:=0;
    total_fov:=0;
    init:=false;
    oldsip:=sip;
    sip:=false;//prevent large error due to sip outside image
    for c:=0 to length(files_to_process)-1 do
      if length(files_to_process[c].name)>0 then
      begin
        if load_fits(files_to_process[c].name,true {light},false{load data},false {update memo} ,0,mainwindow.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;
        if init=false then
        begin
          head_ref:=head;{backup solution}
          init:=true;
        end;

        calculate_required_dimensions(head_ref,head, x_min,x_max,y_min,y_max);
        total_fov:=total_fov+head.cdelt1*head.cdelt2*head.width*head.height;
        inc(count);
      end;
    sip:=oldsip;
    if abs(x_max-x_min)<1 then begin memo2_message('Abort. Failed to calculate mosaic dimensions!');exit;end;


    {move often uses setting to booleans. Great speed improved if use in a loop and read many times}
    merge_overlap:=merge_overlap1.checked;
    Equalise_background:=Equalise_background1.checked;
    counter:=0;
    sum_exp:=0;
    sum_temp:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_start_first:=1E99;{begin observations in Julian day}
    jd_end_last:=0;{end observations in Julian day}
    init:=false;
    use_sip:=stackmenu1.add_sip1.checked;
    dummy:=0;

    if stackmenu1.classify_object1.Checked then memo2_message('█ █ █ █ █ █  Will make more then one mosaic based "Light object". Uncheck classify on "Light object" if required !!█ █ █ █ █ █  ');
    {mosaic mode}
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
          if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainwindow.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;

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
            sincos(decMiddle,SIN_dec_ref,COS_dec_ref);// as procedure initalise_var1, set middle of the mosaic
            head_ref.ra0:=raMiddle;// set middle of the mosaic
            head_ref.crpix1:=abs(x_max-x_min)/2;
            head_ref.crpix2:=abs(y_max-y_min)/2;
          end;

          if use_sip=false then
                    a_order:=0; //stop using SIP from the header in astrometric mode

          memo2_message('Adding file: '+inttostr(counter+1)+'-'+nr_selected1.caption+' "'+filename2+'"  to mosaic.');     // Using '+inttostr(dark_count)+' dark(s), '+inttostr(flat_count)+' flat(s), '+inttostr(flatdark_count)+' flat-dark(s)') ;
          if a_order=0 then Memo2_message('█ █ █ █ █ █  Warning. Image distortion correction not working. Either the option SIP not checkmarked or SIP terms not in the image header. Activate SIP and refresh astrometrical solutions with SIP checkmarked!! █ █ █ █ █ █');

          Application.ProcessMessages;
          if esc_pressed then exit;


          if process_as_osc>0 then {do demosaic bayer}
          begin
            if head.naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
            else
               demosaic_bayer(img_loaded); {convert OSC image to colour}
              {head.naxis3 is now 3}
          end;

          if init=false then {init}
          begin
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
          end;{init, c=0}

          for col:=0 to head.naxis3-1 do {calculate background and noise if required}
          begin
            if equalise_background then
            begin //measure background in all four corners
              bck[0]:=mode(img_loaded,false{ellipse shape},col,0,round(0.2*head.width),  0,round(0.2*head.height),32000,greylevels);
              bck[1]:=mode(img_loaded,false{ellipse shape},col,0,round(0.2*head.width),  round(0.8*head.height),head.height-1,32000,greylevels) ;
              bck[2]:=mode(img_loaded,false{ellipse shape},col,round(0.8*head.width),head.width-1,  0,round(0.2*head.height),32000,greylevels) ;
              bck[3]:=mode(img_loaded,false{ellipse shape},col,round(0.8*head.width),head.width-1,  round(0.8*head.height),head.height-1,32000,greylevels) ;

              background[col]:=smedian(bck,4);
              background_correction_center[col]:=1000 - background[col] ;
            end
            else
            begin
              background[col]:=0;
              background_correction_center[col]:=0;
            end;
          end;

          sincos(head.dec0,SIN_dec0,COS_dec0); {Alway astrometric. Do this in advance since it is for each pixel the same}

          {solutions are already added in unit_stack}
          begin
            inc(counter);
            sum_exp:=sum_exp+head.exposure;
            sum_temp:=sum_temp+head.set_temperature;

            date_to_jd(head.date_obs,head.date_avg,head.exposure);{convert head.date_obs string and head.exposure time to global variables jd_start (julian day start head.exposure) and jd_mid (julian day middle of the head.exposure)}
            jd_start_first:=min(jd_start,jd_start_first);{find the begin date}
            jd_end_last:=max(jd_end,jd_end_last);{find latest end time}
            jd_sum:=jd_sum+jd_mid;{sum julian days of images at midpoint exposure}

            vector_based:=false;
            if a_order=0 then {no SIP from astronomy.net}
            begin
              astrometric_to_vector;{convert astrometric solution to vector solution}
              vector_based:=true;
            end;
            ap_order:=0;// don't correct for RA to XY for mosaic !!!

            cropW:=trunc(stackmenu1.mosaic_crop1.Position*head.width/200);
            cropH:=trunc(stackmenu1.mosaic_crop1.Position*head.height/200);


            background_correction[0]:=0;
            background_correction[1]:=0;
            background_correction[2]:=0;

            if init=true then {check image overlap intensisty differance}
            begin
            counter_overlap[0]:=0;
            counter_overlap[1]:=0;
            counter_overlap[2]:=0;

              for fitsY:=(1+cropH) to head.height-(1+1+cropH) do {skip outside "bad" pixels if mosaic mode. Don't use the pixel at borders, so crop is minimum 1 pixel}
              for fitsX:=(1+cropW) to head.width-(1+1+cropW)  do
              begin
                calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
                x_new:=round(x_new_float); y_new:=round(y_new_float);

                if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
                begin
                  if img_loaded[0,fitsY,fitsX]>0.0001 then {not a black area around image}
                  begin
                    if img_average[0,y_new,x_new]<>0 then {filled pixel}
                    begin
                      for col:=0 to head.naxis3-1 do {all colors}
                      begin
                        correction:=round(img_average[col,y_new,x_new]-(img_loaded[col,fitsY,fitsX]+background_correction_center[col]) );
                        if abs(correction)<max_dev_backgr*1.5 then {acceptable offset based on the lowest and highest background measured earlier}
                        begin
                           background_correction[col]:=background_correction[col]+correction;
                           counter_overlap[col]:=counter_overlap[col]+1;
                        end;
                      end;
                    end;
                  end;
                end;
              end;

              if counter_overlap[0]>0 then background_correction[0]:=background_correction[0]/counter_overlap[0];
              if counter_overlap[1]>0 then background_correction[1]:=background_correction[1]/counter_overlap[1];
              if counter_overlap[2]>0 then background_correction[2]:=background_correction[2]/counter_overlap[2];
            end;

            init:=true;{initialize for first image done}

            for fitsY:=1+cropH to head.height-(1+1+cropH) do {skip outside "bad" pixels if mosaic mode. Don't use the pixel at borders, so crop is minimum 1 pixel}
            for fitsX:=1+cropW to head.width-(1+1+cropW)  do
            begin
              calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
              x_new:=round(x_new_float);y_new:=round(y_new_float);

              if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
              begin
                if img_loaded[0,fitsY,fitsX]>0.0001 then {not a black area around image}
                begin
                  dummy:=1+minimum_distance_borders(fitsX,fitsY,head.width,head.height);{minimum distance borders}
                  if img_temp[0,y_new,x_new]=0 then {blank pixel}
                  begin
                     for col:=0 to head.naxis3-1 do {all colors}
                     img_average[col,y_new,x_new]:=img_loaded[col,fitsY,fitsX]+background_correction_center[col] +background_correction[col];{image loaded is already corrected with dark and flat}{NOTE: fits count from 1, image from zero}
                     img_temp[0,y_new,x_new]:=dummy;

                  end
                  else
                  begin {already pixel filled, try to make an average}
                    for col:=0 to head.naxis3-1 do {all colors}
                    begin
                      median:=background_correction_center[col] +background_correction[col]+median_background(img_loaded,col,15,15,fitsX,fitsY);{find median value in sizeXsize matrix of img_loaded}

                      if merge_overlap=false then {method 2}
                      begin
                        median2:=median_background(img_average,col,15,15,x_new,y_new);{find median value of the destignation img_average}
                        delta_median:=median-median2;
                        img_average[col,y_new,x_new]:= img_average[col,y_new,x_new]+ delta_median*(1-img_temp[0,y_new,x_new]{distance border}/(dummy+img_temp[0,y_new,x_new]));{adapt overlap}
                      end
                      else
                      begin {method 1}
                        value:=img_loaded[col,fitsY,fitsX]+background_correction_center[col];
                        local_sd(fitsX-15 ,fitsY-15, fitsX+15,fitsY+15,col,img_loaded, {var} noise,mean, iterations);{local noise recheck every 10 th pixel}
                        maxlevel:=median+noise*5;
                        if ((value<maxlevel) and
                          (img_loaded[col,fitsY,fitsX-1]<maxlevel) and (img_loaded[col,fitsY,fitsX+1]<maxlevel) and (img_loaded[col,fitsY-1,fitsX]<maxlevel) and (img_loaded[col,fitsY+1,fitsX]<maxlevel) {check nearest pixels}
                           ) then {not a star, prevent double stars at overlap area}
                           img_average[col,y_new,x_new]:=+img_average[col,y_new,x_new]*img_temp[0,y_new,x_new]{distance border}/(dummy+img_temp[0,y_new,x_new])
                                                        +(value+background_correction[col])*dummy/(dummy+img_temp[0,y_new,x_new]);{calculate value between the existing and new value depending on BORDER DISTANCE}
                       end;
                    end;
                    img_temp[0,y_new,x_new]:=dummy;
                  end;
                end;
              end;
            end;

          end;
          progress_indicator(10+89*counter/images_selected{length(files_to_process)}{(ListView1.items.count)},' Stacking');{show progress}
        finally
        end;
      end;

      if counter<>0 then
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
      end; {counter<>0}

    end;{mosaic mode}
  end;{with stackmenu1}
  {arrays will be nilled later. This is done for early exits}

  //disable sip
  mainwindow.Polynomial1.itemindex:=0;//switch to WCS
  a_order:=0;
end;


procedure stack_sigmaclip(process_as_osc:integer; var files_to_process : array of TfileToDo; out counter : integer); {stack using sigma clip average}
type
   tsolution  = record
     solution_vectorX : solution_vector {array[0..2] of double};
     solution_vectorY : solution_vector;
     cblack : double;
   end;
var
    solutions      : array of tsolution;
    fitsX,fitsY,c,width_max, height_max, old_width, old_height,x_new,y_new,col ,binning,max_stars,old_naxis3      : integer;
    variance_factor, value,weightF,hfd_min,aa,bb,cc,dd,ee,ff                                                      : double;
    init, solution,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,use_sip                      : boolean;
    tempval, sumpix, newpix,target_background,background_correction                                               : single;
    warning     : string;
    starlist1,starlist2 : star_list;
    img_temp,img_average,img_final,img_variance : image_array;
begin
  with stackmenu1 do
  begin
    {move often uses setting to booleans. Great speed improved if use in a loop and read many times}
    variance_factor:=sqr(strtofloat2(stackmenu1.sd_factor1.text));

    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}
    max_stars:=strtoint2(stackmenu1.max_stars1.text,500);{maximum star to process, if so filter out brightest stars later}
    use_sip:=stackmenu1.add_sip1.checked;

    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometry_alignment1.checked;

    counter:=0;
    sum_exp:=0;
    sum_temp:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_start_first:=1E99;{begin observations in Julian day}
    jd_end_last:=0;{end observations in Julian day}


    init:=false;
    background_correction:=0;{required for astrometric alignment}
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
        if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainwindow.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;
        if init=false then {first image}
        begin
          old_width:=head.width;
          old_height:=head.height;
          old_naxis3:=head.naxis3;

          head_ref:=head;{backup solution}
          initialise_calc_sincos_dec0;{set variables correct}
          //initialise_var2;{set variables correct}
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
        if use_astrometry_internal then
        begin //for making all background the same for better sigma clip function
          get_background(0, img_loaded, True {update_hist}, False {calculate noise level}, {var} bck);
          solutions[c].cblack:=bck.backgr;  //background after applying dark and flats!! Not the same as in listview1
        end;

        if init=false then
        begin
          binning:=report_binning(head.height);{select binning based on the height of the first light. Do this after demosaic since SuperPixel also bins}

          if  use_astrometry_internal=false then {first image and not astrometry_internal}
          begin
            if ((use_manual_align) or (use_ephemeris_alignment)) then
            begin
              referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
              referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
            end
            else
            begin
              bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist1,warning);{bin, measure background, find stars}
              find_quads(starlist1, quad_star_distances1);{find quads for reference image}
            end;
          end;

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
             target_background:=max(500,bck.backgr); //target for all images. Background of reference image or when lower then 500 then 500.
           memo2_message('Target background for all images is '+floattostrF(target_background,FFFixed,0,0));
        end;{init, c=0}

        solution:=true;
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
                  bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist2,warning);{bin, measure background, find stars}
                  find_quads(starlist2, quad_star_distances2);{find star quads for new image}
                  if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then {find difference between ref image and new image}
                  begin
                    memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.  '+solution_str);
                    solutions[c].solution_vectorX:= solution_vectorX;{store solutions}
                    solutions[c].solution_vectorY:= solution_vectorY;
                    solutions[c].cblack:=bck.backgr;
                  end
                    else
                    begin
                      memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
                      files_to_process[c].name:=''; {remove file from list}
                      solution:=false;
                      ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[L_result]:=6;{mark 3th column with exclamation}
                      ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_result]:='no solution';{no stack result}
                    end;
                 end;{internal alignment}
              end
              else
              begin {first image}
                reset_solution_vectors(1);{no influence on the first image}
                solutions[c].solution_vectorX:= solution_vectorX; {store solutions for later}
                solutions[c].solution_vectorY:= solution_vectorY;
                solutions[c].cblack:=bck.backgr;
               end;

        end;
        init:=true;{initialize for first image done}

        if solution then
        begin
          inc(counter);
          sum_exp:=sum_exp+head.exposure;
          sum_temp:=sum_temp+head.set_temperature;

          weightF:=calc_weightF;{calculate weighting factor for different exposure duration and gain}
          background_correction:=solutions[c].cblack - target_background;//for sigma clip. First try to get backgrounds equal for more effective sigma clip
          head.datamax_org:=min($FFFF,head.datamax_org-background_correction);{note head.datamax_org is already corrected in apply dark}
          {1}

          date_to_jd(head.date_obs,head.date_avg,head.exposure);{convert head.date_obs string and head.exposure time to global variables jd_start (julian day start head.exposure) and jd_mid (julian day middle of the head.exposure)}
          jd_start_first:=min(jd_start,jd_start_first);{find the begin date}
          jd_end_last:=max(jd_end,jd_end_last);{find latest end time}
          jd_sum:=jd_sum+jd_mid;{sum julian days of images at midpoint exposure}
          airmass_sum:=airmass_sum+airmass;


          if use_astrometry_internal then
             astrometric_to_vector;{convert 1th order astrometric solution to vector solution}

          aa:=solution_vectorX[0];//move to local variable for minor faster processing
          bb:=solution_vectorX[1];
          cc:=solution_vectorX[2];
          dd:=solution_vectorY[0];
          ee:=solution_vectorY[1];
          ff:=solution_vectorY[2];

          for fitsY:=0 to head.height-1 do {average}
          for fitsX:=0 to head.width-1  do
          begin
            x_new:=round(aa*(fitsx)+bb*(fitsY)+cc); {correction x:=aX+bY+c  x_new_float in image array range 0..head.width-1}
            y_new:=round(dd*(fitsx)+ee*(fitsY)+ff); {correction y:=aX+bY+c}

            if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
            begin
              for col:=0 to head.naxis3-1 do
              begin
                img_average[col,y_new,x_new]:=img_average[col,y_new,x_new]+ (img_loaded[col,fitsY,fitsX]- background_correction) *weightF;{Note fits count from 1, image from zero}
                img_temp[col,y_new,x_new]:=img_temp[col,y_new,x_new]+weightF {norm 1};{count the number of image pixels added=samples}
              end;
            end;
          end;

        end;
        progress_indicator(10+round(0.3333*90*(counter)/images_selected),' ■□□');{show progress}
        finally
        end;
      end;{try}
      if counter<>0 then
      for fitsY:=0 to height_max-1 do
        for fitsX:=0 to width_max-1 do
            for col:=0 to head.naxis3-1 do
            if img_temp[col,fitsY,fitsX]<>0 then
               img_average[col,fitsY,fitsX]:=img_average[col,fitsY,fitsX]/img_temp[col,fitsY,fitsX];{scale to one image by diving by the number of pixels added}
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
          if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainwindow.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;
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
            if ((use_manual_align) or (use_ephemeris_alignment)) then
            begin
              if init=false then
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
              bck.backgr:=solutions[c].cblack;
            end;
          end;
          init:=true;{initialize for first image done}

          weightF:=calc_weightF;{calculate weighting factor for different exposure duration and gain}
          background_correction:=solutions[c].cblack - target_background;//for sigma clip. First try to get backgrounds equal for more effective sigma clip
          head.datamax_org:=min($FFFF,head.datamax_org-background_correction);{note head.datamax_org is already corrected in apply dark}
          {2}

          if use_astrometry_internal then
             astrometric_to_vector;{convert 1th order astrometric solution to vector solution}

          aa:=solution_vectorX[0];//move to local variable for minor faster processing
          bb:=solution_vectorX[1];
          cc:=solution_vectorX[2];
          dd:=solution_vectorY[0];
          ee:=solution_vectorY[1];
          ff:=solution_vectorY[2];


          for fitsY:=0 to head.height-1 do {skip outside "bad" pixels if mosaic mode}
          for fitsX:=0 to head.width-1  do
          begin
            x_new:=round(aa*(fitsx)+bb*(fitsY)+cc); {correction x:=aX+bY+c  x_new_float in image array range 0..head.width-1}
            y_new:=round(dd*(fitsx)+ee*(fitsY)+ff); {correction y:=aX+bY+c}

            if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
            begin
              for col:=0 to head.naxis3-1 do img_variance[col,y_new,x_new]:=img_variance[col,y_new,x_new] +  sqr( (img_loaded[col,fitsY,fitsX]- background_correction)*weightF - img_average[col,y_new,x_new]); {Without flats, sd in sqr, work with sqr factors to avoid sqrt functions for speed}
            end;
          end;

          progress_indicator(10+30+round(0.33333*90*(counter)/images_selected{length(files_to_process)}{(ListView1.items.count)}),' ■■□');{show progress}
        finally
        end;
      end;{try}
      if counter<>0 then
        For fitsY:=0 to height_max-1 do
          for fitsX:=0 to width_max-1 do
            for col:=0 to head.naxis3-1 do
              if img_temp[col,fitsY,fitsX]<>0 then {reuse the img_temp from light average}
                 img_variance[col,fitsY,fitsX]:=1+img_variance[col,fitsY,fitsX]/img_temp[col,fitsY,fitsX]; {the extra 1 is for saturated images giving a SD=0}{scale to one image by diving by the number of pixels tested}
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
          if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainwindow.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;
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
              bck.backgr:=solutions[c].cblack;
            end;
          end;
          init:=true;{initialize for first image done}

          weightF:=calc_weightF;{calculate weighting factor for different exposure duration and gain}
          background_correction:=solutions[c].cblack - target_background;//for sigma clip. First try to get backgrounds equal for more effective sigma clip
          head.datamax_org:=min($FFFF,head.datamax_org-background_correction);
          {3}

          if use_astrometry_internal then
             astrometric_to_vector;{convert 1th order astrometric solution to vector solution}

          aa:=solution_vectorX[0];//move to local variable for minor faster processing
          bb:=solution_vectorX[1];
          cc:=solution_vectorX[2];
          dd:=solution_vectorY[0];
          ee:=solution_vectorY[1];
          ff:=solution_vectorY[2];

           //phase 3
          for fitsY:=0 to head.height-1 do
          for fitsX:=0 to head.width-1  do
          begin
            x_new:=round(aa*(fitsx)+bb*(fitsY)+cc); {correction x:=aX+bY+c  x_new_float in image array range 0..head.width-1}
            y_new:=round(dd*(fitsx)+ee*(fitsY)+ff); {correction y:=aX+bY+c}

            if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
            begin
              for col:=0 to head.naxis3-1 do {do all colors}
              begin
                value:=(img_loaded[col,fitsY,fitsX]- background_correction)*weightF;
                if sqr (value - img_average[col,y_new,x_new])< variance_factor*{sd sqr}( img_variance[col,y_new,x_new])  then {not an outlier}
                begin
                  img_final[col,y_new,x_new]:=img_final[col,y_new,x_new]+ value;{dark and flat, flat dark already applied}
                  img_temp[col,y_new,x_new]:=img_temp[col,y_new,x_new]+weightF {norm 1};{count the number of image pixels added=samples}
                end;
              end;
            end;
          end;

          progress_indicator(10+60+round(0.33333*90*(counter)/images_selected{length(files_to_process)}{(ListView1.items.count)}),' ■■■');{show progress}
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
        setlength(img_loaded,head.naxis3,head.height,head.width);{new size}

        for col:=0 to head.naxis3-1 do {do one or three colors} {compensate for number of pixel values added per position}
          For fitsY:=0 to head.height-1 do
            for fitsX:=0 to head.width-1 do
            begin
              tempval:=img_temp[col,fitsY,fitsX];
              if tempval<>0 then img_loaded[col,fitsY,fitsX]:={background_correction+}img_final[col,fitsY,fitsX]/tempval {scale to one image by diving by the number of pixels added}
              else
              begin { black spot filter. Note for this version img_temp is counting for each color since they could be different}
                if ((fitsX>0) and (fitsY>0)) then {black spot filter, fix black spots which show up if one image is rotated}
                begin
                  if img_temp[col,fitsY,fitsX-1]<>0 then img_loaded[col,fitsY,fitsX]:={background_correction+}img_loaded[col,fitsY,fitsX-1]{take nearest pixel x-1 as replacement}
                  else
                  if img_temp[col,fitsY-1,fitsX]<>0 then img_loaded[col,fitsY,fitsX]:={background_correction+}img_loaded[col,fitsY-1,fitsX]{take nearest pixel y-1 as replacement}
                  else
                  img_loaded[col,fitsY,fitsX]:=0;{clear img_loaded since it is resized}
                end {fill black spots}
                else
                img_loaded[col,fitsY,fitsX]:=0;{clear img_loaded since it is resized}
              end; {black spot filter}
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
     solution_vectorX : solution_vector {array[0..2] of double};
     solution_vectorY : solution_vector;
     cblack : array[0..2] of single;
   end;
var
    solutions      : array of tsolution;
    fitsX,fitsY,c,width_max, height_max, old_width, old_height,x_new,y_new,col, old_naxis3     : integer;
    value,weightF,hfd_min,aa,bb,cc,dd,ee,ff,delta_JD_required,target_background, JD_reference   : double;
    init, solution,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,use_sip   : boolean;
    tempval,jd_fraction                                                                        : single;
    background_correction : array[0..2] of single;
    img_temp,img_final,img_variance : image_array;
begin
  with stackmenu1 do
  begin
    {move often uses setting to booleans. Great speed improved if use in a loop and read many times}
    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}
    use_sip:=stackmenu1.add_sip1.checked;

    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometry_alignment1.checked;

    counter:=0;
    sum_exp:=0;
    sum_temp:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_start_first:=1E99;{begin observations in Julian day}
    jd_end_last:=0;{end observations in Julian day}


    init:=false;
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
        if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainwindow.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;
        if init=false then {first image}
        begin
          old_width:=head.width;
          old_height:=head.height;
          old_naxis3:=head.naxis3;

          head_ref:=head;{backup solution}
          initialise_calc_sincos_dec0;{set variables correct}
          //initialise_var2;{set variables correct}
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
            get_background(col, img_loaded, True {update_hist}, False {calculate noise level}, {var} bck);
            solutions[c].cblack[col]:=bck.backgr;
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

          date_to_jd(head.date_obs,head.date_avg,head.exposure);{convert head.date_obs string and head.exposure time to global variables jd_start (julian day start head.exposure) and jd_mid (julian day middle of the head.exposure)}
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
             delta_JD_required:= abs(jd_start-jd_reference)* 3*strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_hfd])/sqrt(sqr(solution_vectorX[2])+sqr(solution_vectorY[2]));
             memo2_message('For stars 3*HFD drift takes '+ floattostrF(delta_JD_required*24*3600,FFFixed,4,0)+'sec');
          end;


          aa:=solution_vectorX[0];//move to local variable for minor faster processing
          bb:=solution_vectorX[1];
          cc:=solution_vectorX[2];
          dd:=solution_vectorY[0];
          ee:=solution_vectorY[1];
          ff:=solution_vectorY[2];


          for fitsY:=0 to head.height-1 do {average}
          for fitsX:=0 to head.width-1  do
          begin
            x_new:=round(aa*(fitsx)+bb*(fitsY)+cc); {correction x:=aX+bY+c  x_new_float in image array range 0..head.width-1}
            y_new:=round(dd*(fitsx)+ee*(fitsY)+ff); {correction y:=aX+bY+c}


            if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
            begin
              value:=0;
              for col:=0 to head.naxis3-1 do //do all colours
                value:=value+(img_loaded[col,fitsY,fitsX]- background_correction[col]) *weightF; //sum red, green/blue
              if value>img_variance[0,y_new,x_new] then
              begin
                img_variance[0,y_new,x_new]:=value; // Find the highest value for this (final) pixel position
                img_variance[1,y_new,x_new]:=jd_fraction; // The time this highest value occurs Take fraction because single float has not enough resolution for JD
              end;

            end;
          end;

        end;//solution
        progress_indicator(10+round(0.5*90*(counter)/images_selected),' ■□');{show progress}
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
          if load_fits(filename2,true {light},true,init=false {update memo only for first ref img},0,mainwindow.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;
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


          {phase 2}
//          if use_astrometry_internal then
//             astrometric_to_vector;{convert 1th order astrometric solution to vector solution}

          aa:=solution_vectorX[0];//move to local variable for minor faster processing
          bb:=solution_vectorX[1];
          cc:=solution_vectorX[2];
          dd:=solution_vectorY[0];
          ee:=solution_vectorY[1];
          ff:=solution_vectorY[2];


           //phase 2
          for fitsY:=0 to head.height-1 do
          for fitsX:=0 to head.width-1  do
          begin
            x_new:=round(aa*(fitsx)+bb*(fitsY)+cc); {correction x:=aX+bY+c  x_new_float in image array range 0..head.width-1}
            y_new:=round(dd*(fitsx)+ee*(fitsY)+ff); {correction y:=aX+bY+c}

            if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
            begin
              if ((init=false) or (abs(jd_fraction{when is star spot is passing by} - img_variance[1,y_new,x_new])>delta_JD_required )) then // Avoid streaks. Skip stacking when star is passing by
              begin
                for col:=0 to head.naxis3-1 do {do all colors}
                begin
                  value:=(img_loaded[col,fitsY,fitsX]- background_correction[col])*weightF;
                  img_final[col,y_new,x_new]:=img_final[col,y_new,x_new]+ value;{dark and flat, flat dark already applied}
                  img_temp[0,y_new,x_new]:=img_temp[0,y_new,x_new]+weightF {norm 1};{count the number of image pixels added=samples}
                end;
              end;
            end;
          end;

          init:=true;{initialize for first image done}

          progress_indicator(10+45+round(0.5*90*(counter)/images_selected{length(files_to_process)}{(ListView1.items.count)}),' ■■');{show progress}
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
        setlength(img_loaded,head.naxis3,head.height,head.width);{new size}

        for col:=0 to head.naxis3-1 do {do one or three colors} {compensate for number of pixel values added per position}
          For fitsY:=0 to head.height-1 do
            for fitsX:=0 to head.width-1 do
            begin
              tempval:=img_temp[0,fitsY,fitsX];
              if tempval<>0 then img_loaded[col,fitsY,fitsX]:={background_correction+}img_final[col,fitsY,fitsX]/tempval {scale to one image by diving by the number of pixels added}
              else
              begin { black spot filter. Note for this version img_temp is counting for each color since they could be different}
                if ((fitsX>0) and (fitsY>0)) then {black spot filter, fix black spots which show up if one image is rotated}
                begin
                  if img_temp[0,fitsY,fitsX-1]<>0 then img_loaded[col,fitsY,fitsX]:={background_correction+}img_loaded[col,fitsY,fitsX-1]{take nearest pixel x-1 as replacement}
                  else
                  if img_temp[0,fitsY-1,fitsX]<>0 then img_loaded[col,fitsY,fitsX]:={background_correction+}img_loaded[col,fitsY-1,fitsX]{take nearest pixel y-1 as replacement}
                  else
                  img_loaded[col,fitsY,fitsX]:=0;{clear img_loaded since it is resized}
                end {fill black spots}
                else
                img_loaded[col,fitsY,fitsX]:=0;{clear img_loaded since it is resized}
              end; {black spot filter}
            end;
      end;{counter<>0}
    end;// combine images but throw out the moments when a star is at the pixel. This moment is detected by the max value.
  end;{with stackmenu1}
  {image arrays will be nilled later. This is done for early exits}

  solutions:=nil;
end;   {comet and stars sharp}


procedure calibration_and_alignment(process_as_osc :integer; var files_to_process : array of TfileToDo; out counter : integer); {calibration_and_alignment only}
var
    fitsX,fitsY,c,width_max, height_max, old_width, old_height,x_new,y_new,col, binning, max_stars,old_naxis3  : integer;
    background_correction, hfd_min,aa,bb,cc,dd,ee,ff                                                           : double;
    init, solution,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,use_sip                   : boolean;
    warning             : string;
    starlist1,starlist2 : star_list;
    img_temp,img_average : image_array;
begin
  with stackmenu1 do
  begin
    {move often uses setting to booleans. Great speed improved if use in a loop and read many times}
    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}
    max_stars:=strtoint2(stackmenu1.max_stars1.text,500);{maximum star to process, if so filter out brightest stars later}
    use_sip:=stackmenu1.add_sip1.checked;


    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometry_alignment1.checked;

    init:=false;
    background_correction:=0;{required for astrometric alignment}
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

        if load_fits(filename2,true {light},true,true {init=false} {update memo for saving},0,mainwindow.memo1.Lines,head,img_loaded)=false then begin memo2_message('Error loading '+filename2);exit;end;

        if init=false then {first image}
        begin
          old_width:=head.width;
          old_height:=head.height;
          old_naxis3:=head.naxis3;

          head_ref:=head;{backup solution}
          initialise_calc_sincos_dec0;{set variables correct}
          //initialise_var2;{set variables correct}
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

        if init=false then binning:=report_binning(head.height);{select binning based on the height of the first light. Do this after demosaic since SuperPixel also bins}
        if ((init=false ) and (use_astrometry_internal=false)) then {first image and not astrometry_internal}
        begin
          if ((use_manual_align) or (use_ephemeris_alignment)) then
          begin
            referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
            referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
          end
          else
          begin
            bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist1,warning);{bin, measure background, find stars}
            find_quads(starlist1, quad_star_distances1);{find quads for reference image}
            pedestal_s:=bck.backgr;{correct for difference in background, use cblack from first image as reference. Some images have very high background values up to 32000 with 6000 noise, so fixed pedestal_s of 1000 is not possible}
            if pedestal_s<500 then
              pedestal_s:=500;{prevent image noise could go below zero}
            background_correction:=pedestal_s-bck.backgr;
            head.datamax_org:=head.datamax_org+background_correction; if head.datamax_org>$FFFF then  head.datamax_org:=$FFFF; {note head.datamax_org is already corrected in apply dark}
            head.pedestal:=background_correction;
          end;
        end;


        if init=false then {init}
        begin
          height_max:=head.height;
          width_max:=head.width;

          setlength(img_average,head.naxis3,height_max,width_max);
          setlength(img_temp,head.naxis3,height_max,width_max);
          {clearing image_average and img_temp is done for each image. See below}

          if ((use_manual_align) or (use_ephemeris_alignment)) then
          begin
            referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
            referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
          end;
        end;{init, c=0}

        {clearing image_average and img_temp is done for each image}
        for fitsY:=0 to height_max-1 do
          for fitsX:=0 to width_max-1 do
            for col:=0 to head.naxis3-1 do
            begin
              img_average[col,fitsY,fitsX]:=0; {clear img_average}
              img_temp[col,fitsY,fitsX]:=0; {clear img_temp}
            end;


        solution:=true;
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
              bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,max_stars,true{update hist},starlist2,warning);{bin, measure background, find stars}

              background_correction:=pedestal_s-bck.backgr;
              head.datamax_org:=head.datamax_org+background_correction; if head.datamax_org>$FFFF then  head.datamax_org:=$FFFF; {note head.datamax_org is already corrected in apply dark}
              head.pedestal:=background_correction;

              find_quads(starlist2, quad_star_distances2);{find star quads for new image}
              if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then {find difference between ref image and new image}
                memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.  '+solution_str)
              else
              begin
                memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
                files_to_process[c].name:=''; {remove file from list}
                solution:=false;
                ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[L_result]:=6;{mark 3th column with exclaimation}
                ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[2]:='no solution';{no stack result}
              end;
            end;{internal alignment}
          end
          else
          reset_solution_vectors(1);{no influence on the first image}
        end;
        init:=true;{initialize for first image done}

        if solution then
        begin
          inc(counter);

          if use_astrometry_internal then
             astrometric_to_vector;{convert 1th order astrometric solution to vector solution}

          aa:=solution_vectorX[0];//move to local variable for minor faster processing
          bb:=solution_vectorX[1];
          cc:=solution_vectorX[2];
          dd:=solution_vectorY[0];
          ee:=solution_vectorY[1];
          ff:=solution_vectorY[2];


          for fitsY:=0 to head.height-1 do {skip outside "bad" pixels if mosaic mode}
          for fitsX:=0 to head.width-1 do
          begin
            x_new:=round(aa*(fitsx)+bb*(fitsY)+cc); {correction x:=aX+bY+c  result in image array range 0..head.width-1}
            y_new:=round(dd*(fitsx)+ee*(fitsY)+ff); {correction y:=aX+bY+c}

            if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
            begin
              for col:=0 to head.naxis3-1 do
              begin
                img_average[col,y_new,x_new]:=img_average[col,y_new,x_new]+ img_loaded[col,fitsY,fitsX]+background_correction;{Note fits count from 1, image from zero}
                img_temp[col,y_new,x_new]:=img_temp[col,y_new,x_new]+1;{count the number of image pixels added=samples}
              end;
            end;
          end;
        end;


        {scale to number of pixels}
        head.height:=height_max;
        head.width:=width_max;
        setlength(img_loaded,head.naxis3,head.height,head.width);{new size}

        for col:=0 to head.naxis3-1 do {do one or three colors} {compensate for number of pixel values added per position}
          For fitsY:=0 to head.height-1 do
            for fitsX:=0 to head.width-1 do
            begin
            if img_temp[col,fitsY,fitsX]<>0 then img_loaded[col,fitsY,fitsX]:=img_average[col,fitsY,fitsX]/img_temp[col,fitsY,fitsX] {scale to one image by diving by the number of pixels added}
            else
            begin { black spot filter. Note for this version img_temp is counting for each color since they could be different}
              if ((fitsX>0) and (fitsY>0)) then {black spot filter, fix black spots which show up if one image is rotated}
              begin
                if ((img_temp[col,fitsY,fitsX-1]<>0){and (img_temp[col,fitsY-1,fitsX]<>0)}{keep borders nice for last pixel right}) then img_loaded[col,fitsY,fitsX]:=img_loaded[col,fitsY,fitsX-1]{take nearest pixel x-1 as replacement}
                else
                if img_temp[col,fitsY-1,fitsX]<>0 then img_loaded[col,fitsY,fitsX]:=img_loaded[col,fitsY-1,fitsX]{take nearest pixel y-1 as replacement}
                else
                img_loaded[col,fitsY,fitsX]:=0;{clear img_loaded since it is resized}
              end {fill black spots}
              else
              img_loaded[col,fitsY,fitsX]:=0;{clear img_loaded since it is resized}
            end; {black spot filter}

            end;

        {save}
        filename2:=ChangeFileExt(Filename2,'_aligned.fit');{rename}

        if head.cd1_1<>0 then
        begin
          {quick and dirty method to roughly correct existing solutions}
          head.crpix1:=solution_vectorX[0]*(head.crpix1-1)+solution_vectorX[1]*(head.crpix2-1)+solution_vectorX[2];{correct for marker_position at ra_dec position}
          head.crpix2:=solution_vectorY[0]*(head.crpix1-1)+solution_vectorY[1]*(head.crpix2-1)+solution_vectorY[2];

          mainwindow.Memo1.Lines.EndUpdate;
          update_float(mainwindow.memo1.lines,'CRPIX1  =',' / X of reference pixel                           ',false ,head.crpix1);
          update_float(mainwindow.memo1.lines,'CRPIX2  =',' / Y of reference pixel                           ',false ,head.crpix2);
          update_text(mainwindow.memo1.lines,'COMMENT S','  After alignment only CRPIX1 & CRPIX2 existing solution corrected.');
          mainwindow.Memo1.Lines.EndUpdate;
        end;



        update_text(mainwindow.memo1.lines,'COMMENT 1','  Calibrated & aligned by ASTAP. www.hnsky.org');
        update_float(mainwindow.memo1.lines,'PEDESTAL=',' / Value added during calibration or stacking     ',false ,head.pedestal);//pedestal value added during calibration or stacking
        update_integer(mainwindow.memo1.lines,'DARK_CNT=',' / Darks used for luminance.               ' ,head.dark_count);{for interim lum,red,blue...files. Compatible with master darks}
        update_integer(mainwindow.memo1.lines,'FLAT_CNT=',' / Flats used for luminance.               ' ,head.flat_count);{for interim lum,red,blue...files. Compatible with master flats}
        update_integer(mainwindow.memo1.lines,'BIAS_CNT=',' / Flat-darks used for luminance.          ' ,head.flatdark_count);{for interim lum,red,blue...files. Compatible with master flats}
         { ASTAP keyword standard:}
         { interim files can contain keywords: head.exposure, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
         { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

        if nrbits=16 then
        begin
          if save_fits(img_loaded,mainwindow.memo1.lines,filename2,16,true)=false then exit;//exit if save error
        end
        else
        begin
          if save_fits(img_loaded,mainwindow.memo1.lines,filename2,-32,true)=false then exit;//exit if save error
        end;
         memo2_message('New aligned image created: '+filename2);
        report_results(object_name,inttostr(round(head.exposure)),0,999 {color icon});{report result in tab result using modified filename2}
        progress_indicator(10+round(90*(counter)/images_selected{length(files_to_process)}{(ListView1.items.count)}),'Cal');{show progress}
        finally
        end;
      end;{try}
    end;{}
  end;  {with stackmenu1}

  plot_fits(mainwindow.image1,true,true);{update to last image, activate memo1}

  {arrays will be nilled later. This is done for early exits}
end;   {calibration and alignment}



end.

