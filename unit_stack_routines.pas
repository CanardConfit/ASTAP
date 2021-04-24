unit unit_stack_routines;
{Copyright (C) 2017, 2010 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
}
{$mode delphi}
interface
uses
  Classes, SysUtils,forms, math, unit_stack, astap_main, unit_star_align,unit_gaussian_blur;

procedure stack_LRGB(oversize:integer; var files_to_process : array of TfileToDo; out counter : integer );{stack LRGB mode}
procedure stack_average(oversize:integer; var files_to_process : array of TfileToDo; out counter : integer);{stack average}
procedure stack_mosaic(oversize:integer; var files_to_process : array of TfileToDo;max_dev_backgr: double; out counter : integer);{stack mosaic/tile mode}
procedure stack_sigmaclip(oversize:integer; var files_to_process : array of TfileToDo; out counter : integer); {stack using sigma clip average}
procedure calibration_and_alignment(oversize:integer; var files_to_process : array of TfileToDo; out counter : integer); {calibration_and_alignment only}

{$inline on}  {!!! Set this off for debugging}
procedure calc_newx_newy(vector_based : boolean; fitsXfloat,fitsYfloat: double); inline; {apply either vector or astrometric correction}
procedure astrometric_to_vector; {convert astrometric solution to vector solution}
procedure initialise_var1;{set variables correct}
procedure initialise_var2;{set variables correct}
function test_bayer_matrix(img: image_array) :boolean;  {test statistical if image has a bayer matrix. Execution time about 1ms for 3040x2016 image}

var
  pedestal_s : double;{target background value}

var
  SIN_dec0,COS_dec0,x_new_float,y_new_float,ra_ref,dec_ref,SIN_dec_ref,COS_dec_ref,crpix1_ref, crpix2_ref, CD1_1_ref, CD1_2_ref,CD2_1_ref,CD2_2_ref,exposure_ref,
  ap_0_1_ref,ap_0_2_ref,ap_0_3_ref,ap_1_0_ref,ap_1_1_ref, ap_1_2_ref,ap_2_0_ref,ap_2_1_ref,ap_3_0_ref, bp_0_1_ref,bp_0_2_ref,bp_0_3_ref,bp_1_0_ref,bp_1_1_ref,bp_1_2_ref,bp_2_0_ref,bp_2_1_ref,bp_3_0_ref   : double;


implementation

uses unit_astrometric_solving;


procedure  calc_newx_newy(vector_based : boolean; fitsXfloat,fitsYfloat: double); inline; {apply either vector or astrometric correction}
var
  u,u0,v,v0,dRa,dDec,delta,ra_new,dec_new,delta_ra,det,gamma,SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,h: double;
Begin

  if vector_based then {vector based correction}
  begin
     x_new_float:=solution_vectorX[0]*(fitsxfloat-1)+solution_vectorX[1]*(fitsYfloat-1)+solution_vectorX[2]; {correction x:=aX+bY+c  x_new_float in image array range 0..width2-1}
     y_new_float:=solution_vectorY[0]*(fitsxfloat-1)+solution_vectorY[1]*(fitsYfloat-1)+solution_vectorY[2]; {correction y:=aX+bY+c}
  end
  else
  begin {astrometric based correction}
    {6. Conversion (x,y) -> (RA,DEC)  for image to be added}
    u0:=fitsXfloat-crpix1;
    v0:=fitsYfloat-crpix2;

    if a_order>=2 then {apply SIP correction up second order}
    begin
      u:=u0 + a_2_0*u0*u0 + a_0_2*v0*v0 + a_1_1*u0*v0; {SIP correction}
      v:=v0 + b_2_0*u0*u0 + b_0_2*v0*v0 + b_1_1*u0*v0; {SIP correction}
    end
    else
    begin
      u:=u0;
      v:=v0;
    end;

    dRa :=(cd1_1 * u +cd1_2 * v)*pi/180;
    dDec:=(cd2_1 * u +cd2_2 * v)*pi/180;
    delta:=COS_dec0 - dDec*SIN_dec0;
    gamma:=sqrt(dRa*dRa+delta*delta);
    RA_new:=ra0+arctan(Dra/delta);
    DEC_new:=arctan((SIN_dec0+dDec*COS_dec0)/gamma);


   {5. Conversion (RA,DEC) -> (x,y) of reference image}
    sincos(dec_new,SIN_dec_new,COS_dec_new);{sincos is faster then seperate sin and cos functions}
    delta_ra:=RA_new-ra_ref;
    sincos(delta_ra,SIN_delta_ra,COS_delta_ra);

    H := SIN_dec_new*sin_dec_ref + COS_dec_new*COS_dec_ref*COS_delta_ra;
    dRA := (COS_dec_new*SIN_delta_ra / H)*180/pi;
    dDEC:= ((SIN_dec_new*COS_dec_ref - COS_dec_new*SIN_dec_ref*COS_delta_ra ) / H)*180/pi;

    det:=CD2_2_ref*CD1_1_ref - CD1_2_ref*CD2_1_ref;

    u0:= - (CD1_2_ref*dDEC - CD2_2_ref*dRA) / det;
    v0:= + (CD1_1_ref*dDEC - CD2_1_ref*dRA) / det;

    if a_order>=2 then {apply SIP correction up to second order}
    begin
      x_new_float:=(CRPIX1_ref + u0+ap_0_1*v0+ ap_0_2*v0*v0+ + ap_0_3*v0*v0*v0 +ap_1_0*u0 + ap_1_1*u0*v0+  ap_1_2*u0*v0*v0+ ap_2_0*u0*u0 + ap_2_1*u0*u0*v0+  ap_3_0*u0*u0*u0)-1;{3th order SIP correction, fits count from 1, image from zero therefore subtract 1}
      y_new_float:=(CRPIX2_ref + v0+bp_0_1*v0+ bp_0_2*v0*v0+ + bp_0_3*v0*v0*v0 +bp_1_0*u0 + bp_1_1*u0*v0+  bp_1_2*u0*v0*v0+ bp_2_0*u0*u0 + bp_2_1*u0*u0*v0+  bp_3_0*u0*u0*u0)-1;{3th order SIP correction}
    end
    else
    begin
      x_new_float:=(CRPIX1_ref + u0)-1; {in image array range 0..width-1}
      y_new_float:=(CRPIX2_ref + v0)-1;
    end;
  end;{astrometric}
end;{calc_newx_newy}

procedure astrometric_to_vector;{convert astrometric solution to vector solution}
var
  flipped,flipped_reference  : boolean;

begin
  a_order:=0; {SIP correction should be zero by definition}

  calc_newx_newy(false,1,1) ;
  solution_vectorX[2]:=x_new_float;
  solution_vectorY[2]:=y_new_float;

  calc_newx_newy(false,2, 1); {move one pixel in X}

  solution_vectorX[0]:=+(x_new_float- solution_vectorX[2]);
  solution_vectorX[1]:=-(y_new_float- solution_vectorY[2]);

  calc_newx_newy(false,1, 2);{move one pixel in Y}
  solution_vectorY[0]:=-(x_new_float- solution_vectorX[2]);
  solution_vectorY[1]:=+(y_new_float- solution_vectorY[2]);

  flipped:=(cd1_1/cd2_2)>0; {flipped image. Either flipped vertical or horizontal but not both. Flipped both horizontal and vertical is equal to 180 degrees rotation and is not seen as flipped}
  flipped_reference:=(cd1_1_ref/cd2_2_ref)>0; {flipped reference image}
  if flipped<>flipped_reference then {this can happen is user try to add images from a diffent camera/setup}
  begin
    solution_vectorX[1]:=-solution_vectorX[1];
    solution_vectorY[0]:=-solution_vectorY[0];
  end;
end;

procedure initialise_var1;{set variables correct}
begin
  ra_ref:=ra0;
  dec_ref:=dec0;
  sincos(dec_ref,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}
  crpix1_ref:=crpix1;
  crpix2_ref:=crpix2;
  CD1_1_ref:=CD1_1;
  CD1_2_ref:=CD1_2;
  CD2_1_ref:=CD2_1;
  CD2_2_ref:=CD2_2;

  exposure_ref:=exposure;
end;

procedure initialise_var2;{set variables correct}
begin
  ap_0_1_ref:=ap_0_1;{store polynomial first fits }
  ap_0_2_ref:=ap_0_2;
  ap_0_3_ref:=ap_0_3;
  ap_1_0_ref:=ap_1_0;
  ap_1_1_ref:=ap_1_1;
  ap_1_2_ref:=ap_1_2;
  ap_2_0_ref:=ap_2_0;
  ap_2_1_ref:=ap_2_1;
  ap_3_0_ref:=ap_3_0;

  bp_0_1_ref:=bp_0_1;
  bp_0_2_ref:=bp_0_2;
  bp_0_3_ref:=bp_0_3;
  bp_1_0_ref:=bp_1_0;
  bp_1_1_ref:=bp_1_1;
  bp_2_1_ref:=bp_2_1;
  bp_2_0_ref:=bp_2_0;
  bp_2_1_ref:=bp_2_1;
  bp_3_0_ref:=bp_3_0;
end;

procedure stack_LRGB(oversize:integer; var files_to_process : array of TfileToDo; out counter : integer );{stack LRGB mode}
var
  fitsX,fitsY,c,width_max, height_max, x_new,y_new, binning,oversizeV  : integer;
  background_r, background_g, background_b, background_l ,
  rgbsum,red_f,green_f,blue_f, value ,colr, colg,colb, red_add,green_add,blue_add,
  rr_factor, rg_factor, rb_factor,
  gr_factor, gg_factor, gb_factor,
  br_factor, bg_factor, bb_factor,
  saturated_level,hfd_min                         : double;
  init, solution,use_star_alignment,use_manual_align,use_ephemeris_alignment,
  use_astrometry_internal,vector_based :boolean;

begin
  with stackmenu1 do
  begin

    {move often uses setting to booleans. Great speed improved if use in a loop and read many times}
    use_star_alignment:=stackmenu1.use_star_alignment1.checked;
    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometry_internal1.checked;
    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}

    counter:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_stop:=0;{end observations in Julian day}

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
          memo2_message('Applying black spot filter on interim RGB image.');
          black_spot_filter(img_average);
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
            if ((esc_pressed) or (load_fits(filename2,true {light},true,0,img_loaded)=false)) then begin memo2_message('Error');exit;end;

            if init=false then
            begin
              backup_header;{backup header and solution}

              initialise_var1;{set variables correct, do this before apply dark}
              initialise_var2;{set variables correct}
            end;

            saturated_level:=datamax_org*0.97;{130}

            if c=1 then
            begin
               get_background(0,img_loaded,true,false, {var} background_r,star_level);{unknown, do not calculate noise_level}
               cblack:=round( background_r);
               counterR:=light_count ;counterRdark:=dark_count; counterRflat:=flat_count; counterRbias:=flatdark_count; exposureR:=round(exposure);temperatureR:=set_temperature;{for historical reasons}
            end;
            if c=2 then
            begin
              get_background(0,img_loaded,true,false, {var} background_g,star_level);{unknown, do not calculate noise_level}
              cblack:=round( background_g);
              counterG:=light_count;counterGdark:=dark_count; counterGflat:=flat_count; counterGbias:=flatdark_count; exposureG:=round(exposure);temperatureG:=set_temperature;
            end;
            if c=3 then
            begin
              get_background(0,img_loaded,true,false, {var} background_b,star_level);{unknown, do not calculate noise_level}
              cblack:=round( background_b);
              counterB:=light_count; counterBdark:=dark_count; counterBflat:=flat_count; counterBbias:=flatdark_count; exposureB:=round(exposure);temperatureB:=set_temperature;
            end;
            if c=4 then
            begin
              get_background(0,img_loaded,true,false, {var} background_r,star_level);{unknown, do not calculate noise_level}
              cblack:=round( background_r);
              background_g:=background_r;
              background_b:=background_r;
              counterRGB:=light_count; counterRGBdark:=dark_count; counterRGBflat:=flat_count; counterRGBbias:=flatdark_count; exposureRGB:=round(exposure);;temperatureRGB:=set_temperature;
            end;
            if c=5 then {Luminance}
            begin
              get_background(0,img_loaded,true,false, {var} background_L,star_level);{unknown, do not calculate noise_level}
              cblack:=round( background_L);
              counterL:=light_count; counterLdark:=dark_count; counterLflat:=flat_count; counterLbias:=flatdark_count; exposureL:=round(exposure);temperatureL:=set_temperature;
            end;

            if use_astrometry_internal then {internal solver, create new solutions for the R, G, B and L stacked images if required}
            begin
              memo2_message('Preparing astrometric solution for interim file: '+filename2);
              if cd1_1=0 then solution:= create_internal_solution(img_loaded) else solution:=true;
              if solution=false {load astrometry.net solution succesfull} then begin memo2_message('Abort, No astrometric solution for '+filename2); exit;end;{no solution found}
              //if c=0 then cdelt2_lum:=cdelt2;
              //if ((c=1) or (c=2)  or (c=3) or (c=4)) then
              //begin
              //  if cdelt2>cdelt2_lum*1.01 then memo2_message('█ █ █ █ █ █  Warning!! RGB images have a larger pixel size ('+floattostrF(cdelt2*3600,ffgeneral,3,2)+'arcsec) then the luminance image ('+floattostrF(cdelt2_lum*3600,ffgeneral,3,2)+'arcsec). If the stack result is poor, select in tab "stack method" the 3x3 mean or 5x5 mean filter for smoothing interim RGB.');
              //end;
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
                binning:=report_binning;{select binning based on the height of the light}
                bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,true{update hist},starlist1);{bin, measure background, find stars}
                find_quads(starlist1,0, quad_smallest,quad_star_distances1);{find quads for reference image/database}
              end;
            end;

            if init=false then {init}
            begin
              if oversize<0 then {shrink a lot, adapt in ratio}
              begin
                oversize:=max(oversize,-round((width2-100)/2) );{minimum image width is 100}
                oversizeV:=round(oversize*height2/width2);{vertical shrinkage in pixels}
                height_max:=height2+oversizeV*2;
              end
              else
              begin
                oversizeV:=oversize;
                height_max:=height2+oversize*2;
              end;
              width_max:=width2+oversize*2;

              setlength(img_average,3,width_max,height_max);{will be color}
              setlength(img_temp,3,width_max,height_max);{mono}
              for fitsY:=0 to height_max-1 do
                for fitsX:=0 to width_max-1 do
                begin
                  img_average[0,fitsX,fitsY]:=500; {clear img_average. Set default at 500}
                  img_average[1,fitsX,fitsY]:=500; {clear img_average}
                  img_average[2,fitsX,fitsY]:=500; {clear img_average}
                  img_temp[0,fitsX,fitsY]:=0;
                  img_temp[1,fitsX,fitsY]:=0; {clear img_temp}
                  img_temp[2,fitsX,fitsY]:=0; {clear img_temp}
                end;
            end;{init, c=0}

            solution:=true;{assume solution is found}
            if use_astrometry_internal then sincos(dec0,SIN_dec0,COS_dec0) {do this in advance since it is for each pixel the same}
            else
            begin {align using star match}
              if init=true then {second image}
              begin
                if ((use_manual_align) or (use_ephemeris_alignment)) then
                begin {manual alignment}
                  solution_vectorX[2]:=referenceX-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {calculate correction}
                  solution_vectorY[2]:=referenceY-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]);
                  memo2_message('Solution x:=x+'+floattostr6(solution_vectorX[2])+',  y:=y+'+floattostr6(solution_vectorY[2]));
                end
                else
                begin{internal alignment}
                  bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,true{update hist},starlist2);{bin, measure background, find stars}

                  find_quads(starlist2,0, quad_smallest,quad_star_distances2);{find star quads for new image}
                  if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then {find difference between ref image and new image}
                  memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.'
                       +'  Solution x:='+floattostr6(solution_vectorX[0])+'*x+ '+floattostr6(solution_vectorX[1])+'*y+ '+floattostr6(solution_vectorX[2])
                       +',  y:='+floattostr6(solution_vectorY[0])+'*x+ '+floattostr6(solution_vectorY[1])+'*y+ '+floattostr6(solution_vectorY[2]) )

                    else
                    begin
                      memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
                      files_to_process[c].name:=''; {remove file from list}
                     solution:=false;
                      ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[2]:=6;{mark 3th column with exclaimation}
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
              date_to_jd(date_obs);{convert date-obs to jd}
              if jd>jd_stop then jd_stop:=jd;
              jd_sum:=jd_sum+jd+exposure/(2*24*3600);{sum julian days of images at midpoint exposure. Add half exposure in days to get midpoint}

              vector_based:=((use_star_alignment) or (use_manual_align) or (use_ephemeris_alignment));
              if ((vector_based=false) and (a_order=0)) then {no SIP from astronomy.net}
              begin
                astrometric_to_vector;{convert astrometric solution to vector solution}
                vector_based:=true;
              end;

              for fitsY:=1 to height2 do {skip outside pixels if color}
              for fitsX:=1 to width2 do
              begin
                calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
                x_new:=round(x_new_float+oversize);y_new:=round(y_new_float+oversizeV);
                if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
                begin
                  if c=1 {red} then
                  begin
                    value:=img_loaded[0,fitsX-1,fitsY-1];
                    if value>saturated_level then {saturation, mark all three colors as black spot (<=0) to maintain star colour}
                    begin
                      img_temp[0,x_new,y_new]:=-99999; {saturation marker, process later as black spot}
                      img_temp[1,x_new,y_new]:=-99999; {saturation marker}
                      img_temp[2,x_new,y_new]:=-99999; {saturation marker}
                      img_average[0,x_new,y_new]:=0;
                      img_average[1,x_new,y_new]:=0;
                      img_average[2,x_new,y_new]:=0;
                    end
                    else
                    begin
                      value:=(value-background_r);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if rr_factor>0.00001 then begin img_average[0,x_new,y_new]:=img_average[0,x_new,y_new] + rr_factor*value;{execute only if greater then zero for speed} end;
                      if rg_factor>0.00001 then begin img_average[1,x_new,y_new]:=img_average[1,x_new,y_new] + rg_factor*value; end;
                      if rb_factor>0.00001 then begin img_average[2,x_new,y_new]:=img_average[2,x_new,y_new] + rb_factor*value; end;
                    end;
                  end;
                  if c=2 {green} then
                  begin
                    value:=img_loaded[0,fitsX-1,fitsY-1];
                    if value>saturated_level then {saturation, mark all three colors as black spot (<=0) to maintain star colour}
                    begin
                      img_temp[0,x_new,y_new]:=-99999; {saturation marker, process later as black spot}
                      img_temp[1,x_new,y_new]:=-99999; {saturation marker}
                      img_temp[2,x_new,y_new]:=-99999; {saturation marker}
                      img_average[0,x_new,y_new]:=0;
                      img_average[1,x_new,y_new]:=0;
                      img_average[2,x_new,y_new]:=0;
                    end
                    else
                    begin
                      value:=(value-background_g);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if gr_factor>0.00001 then begin img_average[0,x_new,y_new]:=img_average[0,x_new,y_new] + gr_factor*value;{execute only if greater then zero for speed} end;
                      if gg_factor>0.00001 then begin img_average[1,x_new,y_new]:=img_average[1,x_new,y_new] + gg_factor*value; end;
                      if gb_factor>0.00001 then begin img_average[2,x_new,y_new]:=img_average[2,x_new,y_new] + gb_factor*value;  end;
                    end;
                  end;
                  if c=3 {blue}  then
                  begin
                    value:=img_loaded[0,fitsX-1,fitsY-1];
                    if value>saturated_level then {saturation, mark all three colors as black spot (<=0) to maintain star colour}
                    begin
                      img_temp[0,x_new,y_new]:=-99999; {saturation marker, process later as black spot}
                      img_temp[1,x_new,y_new]:=-99999; {saturation marker}
                      img_temp[2,x_new,y_new]:=-99999; {saturation marker}
                      img_average[0,x_new,y_new]:=0;
                      img_average[1,x_new,y_new]:=0;
                      img_average[2,x_new,y_new]:=0;
                    end
                    else
                    begin
                      value:=(value-background_b);{image loaded is already corrected with dark and flat. Normalize background to level 500}{NOTE: fits count from 1, image from zero}
                      if br_factor>0.00001 then begin img_average[0,x_new,y_new]:=img_average[0,x_new,y_new] + br_factor*value;{execute only if greater then zero for speed} end;
                      if bg_factor>0.00001 then begin img_average[1,x_new,y_new]:=img_average[1,x_new,y_new] + bg_factor*value; end;
                      if bb_factor>0.00001 then begin img_average[2,x_new,y_new]:=img_average[2,x_new,y_new] + bb_factor*value; end;
                    end;
                  end;
                  if c=4 {RGB image, naxis3=3}   then
                  begin
                    begin img_average[0,x_new,y_new]:=img_average[0,x_new,y_new] + img_loaded[0,fitsX-1,fitsY-1]-background_r; end;
                    begin img_average[1,x_new,y_new]:=img_average[1,x_new,y_new] + img_loaded[1,fitsX-1,fitsY-1]-background_g; end;
                    begin img_average[2,x_new,y_new]:=img_average[2,x_new,y_new] + img_loaded[2,fitsX-1,fitsY-1]-background_b; end;

//                    if ((x_new=1908) and (y_new=604)) then
//                    beep;

                  end;
                  if c=5 {Luminance} then
                  begin
                    {rgb is already blurred}
                    {r:=l*(0.33+r)/(r+g+b)}

//                  if ((x_new=1908) and (y_new=604)) then
//                  beep;

                    colr:=img_average[0,x_new,y_new] - 475 + red_add; {lowest_most_common is around 450 to 500}
                    colg:=img_average[1,x_new,y_new] - 475 + green_add;
                    colb:=img_average[2,x_new,y_new] - 475 + blue_add;


                    rgbsum:=colr+colg+colb;
                    if rgbsum<0.1 then begin rgbsum:=0.1; red_f:=rgbsum/3; green_f:=red_f; blue_f:=red_f;end
                    else
                    begin
                      red_f:=colr/rgbsum;   if red_f<0   then red_f:=0;  if red_f>1 then   red_f:=1;
                      green_f:=colg/rgbsum; if green_f<0 then green_f:=0;if green_f>1 then green_f:=1;
                      blue_f:=colb/rgbsum;  if blue_f<0  then blue_f:=0; if blue_f>1 then  blue_f:=1;
                    end;

                    img_average[0,x_new,y_new]:=1000+(img_loaded[0,fitsX-1,fitsY-1] - background_l)*(red_f);
                    img_average[1,x_new,y_new]:=1000+(img_loaded[0,fitsX-1,fitsY-1] - background_l)*(green_f);
                    img_average[2,x_new,y_new]:=1000+(img_loaded[0,fitsX-1,fitsY-1] - background_l)*(blue_f);
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
        naxis3:=3;
        img_loaded:=img_average;
        width2:=width_max;
        height2:=height_max;
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
  w:=Length(img[0]);    {width}
  h:=Length(img[0][0]); {height}

  middleY:=h div 2;
  step_size:=w div steps;
  if odd(step_size) then step_size:=step_size-1;{make even so it ends up at the correct location of the 2x2 matrix}

  SetLength(p11,steps);
  SetLength(p12,steps);
  SetLength(p21,steps);
  SetLength(p22,steps);

  for fitsX:=0 to steps-1   do  {test one horizontal line and take 100 samples of the bayer matrix}
  begin
    p11[fitsX]:=img[0,step_size*fitsX,middleY];
    p12[fitsX]:=img[0,step_size*fitsX+1,middleY];
    p21[fitsX]:=img[0,step_size*fitsX,middleY+1];
    p22[fitsX]:=img[0,step_size*fitsX+1,middleY+1];
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


procedure stack_average(oversize:integer; var files_to_process : array of TfileToDo; out counter : integer);{stack average}
var
  fitsX,fitsY,c,width_max, height_max,old_width, old_height,x_new,y_new,col,binning,oversizeV    : integer;
  background_correction, weightF,hfd_min                                                         : double;
  init, solution,use_star_alignment,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,vector_based : boolean;
  tempval   : single;
begin

  with stackmenu1 do
  begin
    use_star_alignment:=stackmenu1.use_star_alignment1.checked;
    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometry_internal1.checked;
    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}

    counter:=0;
    sum_exp:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_stop:=0;{end observations in Julian day}

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
          if ((esc_pressed) or (load_fits(filename2,true {light},true,0,img_loaded)=false)) then begin memo2_message('Error');{can't load} exit;end;

          if init=true then {first file done}
          begin
             if ((old_width<>width2) or (old_height<>height2)) then memo2_message('█ █ █ █ █ █  Warning different size image!');
             if naxis3>length(img_average) {naxis3} then begin memo2_message('█ █ █ █ █ █  Abort!! Can'+#39+'t combine colour to mono files.'); exit;end;
          end;

          if init=false then
          begin
            binning:=report_binning;{select binning based on the height of the first light}

            backup_header;{backup header and solution}

            initialise_var1;{set variables correct. Do this before apply dark}
            initialise_var2;{set variables correct}
            if ((bayerpat='') and (make_osc_color1.checked)) then
               if stackmenu1.bayer_pattern1.Text='auto' then memo2_message('█ █ █ █ █ █ Warning, Bayer colour pattern not in the header! Check colours and if wrong set Bayer pattern manually in tab "stack alignment". █ █ █ █ █ █')
               else
               if test_bayer_matrix(img_loaded)=false then  memo2_message('█ █ █ █ █ █ Warning, grayscale image converted to colour! Un-check option "convert OSC to colour". █ █ █ █ █ █');
          end;

          apply_dark_flat(filter_name,{var} dark_count,flat_count,flatdark_count);{apply dark, flat if required, renew if different exposure or ccd temp}
          {these global variables are passed-on in procedure to protect against overwriting}

          memo2_message('Adding file: '+inttostr(c+1)+'-'+nr_selected1.caption+' "'+filename2+'"  to average. Using '+inttostr(dark_count)+' darks, '+inttostr(flat_count)+' flats, '+inttostr(flatdark_count)+' flat-darks') ;
          Application.ProcessMessages;
          if esc_pressed then exit;

          if make_osc_color1.checked then {do demosaic bayer}
          begin
            if naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
            else
            demosaic_bayer(img_loaded); {convert OSC image to colour}
           {naxis3 is now 3}
          end;

          if ((init=false ) and (use_astrometry_internal=false)) then {first image and not astrometry_internal}
          begin
            if ((use_manual_align) or (use_ephemeris_alignment)) then
            begin
              referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
              referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
            end
            else
            begin
              bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,true{update hist},starlist1);{bin, measure background, find stars}
              find_quads(starlist1,0, quad_smallest,quad_star_distances1);{find quads for reference image}
              pedestal_s:=cblack;{correct for difference in background, use cblack from first image as reference. Some images have very high background values up to 32000 with 6000 noise, so fixed pedestal_s of 1000 is not possible}
              if pedestal_s<500 then pedestal_s:=500;{prevent image noise could go below zero}
              background_correction:=pedestal_s-cblack;
              datamax_org:=datamax_org+background_correction; if datamax_org>$FFFF then  datamax_org:=$FFFF; {note datamax_org is already corrected in apply dark}
            end;
          end;

          if init=false then {init}
          begin
            if oversize<0 then {shrink a lot, adapt in ratio}
            begin
              oversize:=max(oversize,-round((width2-100)/2) );{minimum image width is 100}
              oversizeV:=round(oversize*height2/width2);
              height_max:=height2+oversizeV*2;
            end
            else
            begin
              oversizeV:=oversize;
              height_max:=height2+oversize*2;
            end;
            width_max:=width2+oversize*2;

            setlength(img_average,naxis3,width_max,height_max);
            setlength(img_temp,1,width_max,height_max);
            for fitsY:=0 to height_max-1 do
              for fitsX:=0 to width_max-1 do
              begin
                for col:=0 to naxis3-1 do
                  img_average[col,fitsX,fitsY]:=0; {clear img_average}
                img_temp[0,fitsX,fitsY]:=0; {clear img_temp}
              end;
            old_width:=width2;
            old_height:=height2;

            if ((use_manual_align) or (use_ephemeris_alignment)) then
            begin
              referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
              referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
            end;
          end;{init, c=0}

          solution:=true;
          if use_astrometry_internal then sincos(dec0,SIN_dec0,COS_dec0) {do this in advance since it is for each pixel the same}
          else
          begin {align using star match}
            if init=true then {second image}
            begin
              if ((use_manual_align) or (use_ephemeris_alignment)) then
              begin {manual alignment}
                solution_vectorX[2]:=referenceX-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {calculate correction}
                solution_vectorY[2]:=referenceY-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]);
                memo2_message('Solution x:=x+'+floattostr6(solution_vectorX[2])+',  y:=y+'+floattostr6(solution_vectorY[2]));
              end
              else
              begin{internal alignment}
                bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,true{update hist},starlist2);{bin, measure background, find stars}

                background_correction:=pedestal_s-cblack;
                datamax_org:=datamax_org+background_correction; if datamax_org>$FFFF then  datamax_org:=$FFFF; {note datamax_org is already corrected in apply dark}

                find_quads(starlist2,0,quad_smallest,quad_star_distances2);{find star quads for new image}
                if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then {find difference between ref image and new image}
                memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.'
                     +'  Solution x:='+floattostr6(solution_vectorX[0])+'*x+ '+floattostr6(solution_vectorX[1])+'*y+ '+floattostr6(solution_vectorX[2])
                     +',  y:='+floattostr6(solution_vectorY[0])+'*x+ '+floattostr6(solution_vectorY[1])+'*y+ '+floattostr6(solution_vectorY[2]) )

                  else
                  begin
                    memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
                    files_to_process[c].name:=''; {remove file from list}
                    solution:=false;
                    ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[2]:=6;{mark 3th column with exclaimation}
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
            sum_exp:=sum_exp+exposure;
            if exposure<>0 then weightF:=exposure/exposure_ref else weightF:=1;{influence of each image depending on the exposure_time}

            date_to_jd(date_obs);{convert date-obs to jd}
            if jd>jd_stop then jd_stop:=jd;
            jd_sum:=jd_sum+jd+exposure/(2*24*3600);{sum julian days of images at midpoint exposure. Add half exposure in days to get midpoint}

            vector_based:=((use_star_alignment) or (use_manual_align) or (use_ephemeris_alignment));
            if ((vector_based=false) and (a_order=0)) then {no SIP from astronomy.net}
            begin
              astrometric_to_vector;{convert astrometric solution to vector solution}
              vector_based:=true;
            end;

            for fitsY:=1 to height2 do {skip outside "bad" pixels if mosaic mode}
            for fitsX:=1 to width2  do
            begin
              calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
              x_new_float:=x_new_float+oversize;y_new_float:=y_new_float+oversizeV;
              x_new:=round(x_new_float);y_new:=round(y_new_float);
              if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
              begin
                for col:=0 to naxis3-1 do {all colors}
                img_average[col,x_new,y_new]:=img_average[col,x_new,y_new]+ img_loaded[col,fitsX-1,fitsY-1] +background_correction;{image loaded is already corrected with dark and flat}{NOTE: fits count from 1, image from zero}
                img_temp[0,x_new,y_new]:=img_temp[0,x_new,y_new]+weightF{typical 1};{count the number of image pixels added=samples.}
              end;
            end;

          end;
          progress_indicator(10+89*counter/(length(files_to_Process){ListView1.items.count}),' Stacking');{show progress}
          finally
        end;
      end;

      if counter<>0 then
      begin
        height2:=height_max;
        width2:=width_max;
        setlength(img_loaded,naxis3,width2,height2);{new size}

        For fitsY:=0 to height2-1 do
        for fitsX:=0 to width2-1 do
        begin {pixel loop}
          tempval:=img_temp[0,fitsX,fitsY];
          for col:=0 to naxis3-1 do
          begin {colour loop}
            if tempval<>0 then img_loaded[col,fitsX,fitsY]:=img_average[col,fitsX,fitsY]/tempval {scale to one image by diving by the number of pixels added}
            else
            begin { black spot filter or missing value filter due to image rotation}
              if ((fitsX>0) and (img_temp[0,fitsX-1,fitsY]<>0)) then img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX-1,fitsY]{take nearest pixel x-1 as replacement}
              else
              if ((fitsY>0) and (img_temp[0,fitsX,fitsY-1]<>0)) then img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX,fitsY-1]{take nearest pixel y-1 as replacement}
              else
              img_loaded[col,fitsX,fitsY]:=0;{clear img_loaded since it is resized}
            end; {black spot}
          end;{colour loop}
        end;{pixel loop}
      end; {counter<>0}

    end;{simple average}
  end;{with stackmenu1}
  {arrays will be nilled later. This is done for early exits}
end;


function minimum_distance_borders(fitsX,fitsY,w,h: integer): single;
begin
  result:=min(fitsX,w-fitsX);
  result:=min(fitsY,result);
  result:=min(h-fitsY,result);
end;


procedure stack_mosaic(oversize:integer; var files_to_process : array of TfileToDo; max_dev_backgr: double; out counter : integer);{mosaic/tile mode}
var
    fitsX,fitsY,c,width_max, height_max,x_new,y_new,col, cropW,cropH,iterations        : integer;
    value, dummy,median,median2,delta_median,correction,maxlevel,mean,noise : double;
    tempval                                                        : single;
    init, vector_based,merge_overlap,equalise_background           : boolean;
    background_correction,background_correction_center,background    : array[0..2] of double;
    counter_overlap                                                  : array[0..2] of integer;
begin
  with stackmenu1 do
  begin
    {move often uses setting to booleans. Great speed improved if use in a loop and read many times}
    merge_overlap:=merge_overlap1.checked;
    Equalise_background:=Equalise_background1.checked;
    counter:=0;
    sum_exp:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_stop:=0;{end observations in Julian day}
    init:=false;

    dummy:=0;

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
          if ((esc_pressed) or  (load_fits(filename2,true {light},true,0,img_loaded)=false)) then  begin memo2_message('Error');{can't load} exit;end;

          if init=true then
          begin
             // not for mosaic||| if init=true then   if ((old_width<>width2) or (old_height<>height2)) then memo2_message('█ █ █ █ █ █  Warning different size image!');
             if naxis3>length(img_average) {naxis3} then begin memo2_message('█ █ █ █ █ █  Abort!! Can'+#39+'t combine mono and colour files.'); exit;end;
          end;

          if init=false then
          begin
            backup_header;{backup header and solution}
            initialise_var1;{set variables correct}
            initialise_var2;{set variables correct}
          end;

          memo2_message('Adding file: '+inttostr(c+1)+'-'+nr_selected1.caption+' "'+filename2+'"  to mosaic.');             // Using '+inttostr(dark_count)+' dark(s), '+inttostr(flat_count)+' flat(s), '+inttostr(flatdark_count)+' flat-dark(s)') ;
          Application.ProcessMessages;
          if esc_pressed then exit;

          if init=false then {init}
          begin
            oversize:=width2*mosaic_width1.position div 2;{increase the oversize to have space for the tiles}
            width_max:=width2+oversize*2;
            height_max:=height2+oversize*2;

            setlength(img_average,naxis3,width_max,height_max);
            setlength(img_temp,1,width_max,height_max);{gray}

            for fitsY:=0 to height_max-1 do
              for fitsX:=0 to width_max-1 do
              begin
                for col:=0 to naxis3-1 do
                begin
                  img_average[col,fitsX,fitsY]:=0; {clear img_average}
                end;
                img_temp[0,fitsX,fitsY]:=0; {clear img_temp}
              end;
          end;{init, c=0}

          for col:=0 to naxis3-1 do {calculate background and noise if required}
          begin
            if equalise_background then
            begin
                background[col]:=mode(img_loaded,col,round(0.2*width2),round(0.8*width2),round(0.2*height2),round(0.8*height2),32000); {most common 80% center}
                background_correction_center[col]:=1000 - background[col] ;
              end
            else
            begin
              background[col]:=0;
              background_correction_center[col]:=0;
            end;
          end;

          sincos(dec0,SIN_dec0,COS_dec0); {Alway astrometric. Do this in advance since it is for each pixel the same}

          {solutions are already added in unit_stack}
          begin
            inc(counter);
            sum_exp:=sum_exp+exposure;

            date_to_jd(date_obs);{convert date-obs to jd}
            if jd>jd_stop then jd_stop:=jd;
            jd_sum:=jd_sum+jd+exposure/(2*24*3600);{sum julian days of images at midpoint exposure. Add half exposure in days to get midpoint}

            vector_based:=false;
            if a_order=0 then {no SIP from astronomy.net}
            begin
              astrometric_to_vector;{convert astrometric solution to vector solution}
              vector_based:=true;
            end;

            cropW:=trunc(stackmenu1.mosaic_crop1.Position*width2/200);
            cropH:=trunc(stackmenu1.mosaic_crop1.Position*height2/200);


            background_correction[0]:=0;
            background_correction[1]:=0;
            background_correction[2]:=0;

            if init=true then {check image overlap intensisty differance}
            begin
            counter_overlap[0]:=0;
            counter_overlap[1]:=0;
            counter_overlap[2]:=0;

              for fitsY:=1+1+cropH to height2-1-cropH do {skip outside "bad" pixels if mosaic mode. Don't use the pixel at borders, so crop is minimum 1 pixel}
              for fitsX:=1+1+cropW to width2-1-cropW  do
              begin
                calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
                x_new:=round(x_new_float+oversize);y_new:=round(y_new_float+oversize);
                if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
                begin
                  if img_loaded[0,fitsX-1,fitsY-1]>0.0001 then {not a black area around image}
                  begin
                    if img_average[0,x_new,y_new]<>0 then {filled pixel}
                    begin
                      for col:=0 to naxis3-1 do {all colors}
                      begin
                        correction:=round(img_average[col,x_new,y_new]-(img_loaded[col,fitsX-1,fitsY-1]+background_correction_center[col]) );
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

            for fitsY:=1+1+cropH to height2-1-cropH do {skip outside "bad" pixels if mosaic mode. Don't use the pixel at borders, so crop is minimum 1 pixel}
            for fitsX:=1+1+cropW to width2-1-cropW  do
            begin
              calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
              x_new:=round(x_new_float+oversize);y_new:=round(y_new_float+oversize);
              if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
              begin
                if img_loaded[0,fitsX-1,fitsY-1]>0.0001 then {not a black area around image}
                begin
                  dummy:=1+minimum_distance_borders(fitsX,fitsY,width2,height2);{minimum distance borders}
                  if img_temp[0,x_new,y_new]=0 then {blank pixel}
                  begin
                     for col:=0 to naxis3-1 do {all colors}
                     img_average[col,x_new,y_new]:=img_loaded[col,fitsX-1,fitsY-1]+background_correction_center[col] +background_correction[col];{image loaded is already corrected with dark and flat}{NOTE: fits count from 1, image from zero}
                     img_temp[0,x_new,y_new]:=dummy;

                  end
                  else
                  begin {already pixel filled, try to make an average}
                    for col:=0 to naxis3-1 do {all colors}
                    begin
                      median:=background_correction_center[col] +background_correction[col]+median_background(img_loaded,col,15,fitsX-1,fitsY-1);{find median value in sizeXsize matrix of img_loaded}

                      if merge_overlap=false then {method 2}
                      begin
                        median2:=median_background(img_average,col,15,x_new,y_new);{find median value of the destignation img_average}
                        delta_median:=median-median2;
                        img_average[col,x_new,y_new]:= img_average[col,x_new,y_new]+ delta_median*(1-img_temp[0,x_new,y_new]{distance border}/(dummy+img_temp[0,x_new,y_new]));{adapt overlap}
                      end
                      else
                      begin {method 1}
                        value:=img_loaded[col,fitsX-1,fitsY-1]+background_correction_center[col];
                        local_sd(fitsX-1-15 ,fitsY-1-15, fitsX-1+15,fitsY-1+15,col,img_loaded, {var} noise,mean, iterations);{local noise recheck every 10 th pixel}
                        maxlevel:=median+noise*5;
                        if ((value<maxlevel) and
                          (img_loaded[col,fitsX-1-1,fitsY-1]<maxlevel) and (img_loaded[col,fitsX-1+1,fitsY-1]<maxlevel) and (img_loaded[col,fitsX-1,fitsY-1-1]<maxlevel) and (img_loaded[col,fitsX-1,fitsY-1+1]<maxlevel) {check nearest pixels}
                           ) then {not a star, prevent double stars at overlap area}
                           img_average[col,x_new,y_new]:=+img_average[col,x_new,y_new]*img_temp[0,x_new,y_new]{distance border}/(dummy+img_temp[0,x_new,y_new])
                                                        +(value+background_correction[col])*dummy/(dummy+img_temp[0,x_new,y_new]);{calculate value between the existing and new value depending on BORDER DISTANCE}
                       end;
                    end;
                    img_temp[0,x_new,y_new]:=dummy;
                  end;
                end;
              end;
            end;

          end;
          progress_indicator(10+89*counter/length(files_to_process){(ListView1.items.count)},' Stacking');{show progress}
        finally
        end;
      end;

      if counter<>0 then
      begin
        height2:=height_max;
        width2:=width_max;
        setlength(img_loaded,naxis3,width2,height2);{new size}

        For fitsY:=0 to height2-1 do
        for fitsX:=0 to width2-1 do
        begin {pixel loop}
          tempval:=img_temp[0,fitsX,fitsY]; {if <>0 then something was written}
          for col:=0 to naxis3-1 do
          begin {colour loop}
            if tempval<>0 then img_loaded[col,fitsX,fitsY]:=img_average[col,fitsX,fitsY] {no divide}
            else
            begin { black spot filter or missing value filter due to image rotation}
              if ((fitsX>0) and (img_temp[0,fitsX-1,fitsY]<>0)) then img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX-1,fitsY]{take nearest pixel x-1 as replacement}
              else
              if ((fitsY>0) and (img_temp[0,fitsX,fitsY-1]<>0)) then img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX,fitsY-1]{take nearest pixel y-1 as replacement}
              else
              img_loaded[col,fitsX,fitsY]:=0;{clear img_loaded since it is resized}
            end; {black spot}
          end;{colour loop}
        end;{pixel loop}
      end; {counter<>0}

    end;{mosaic mode}
  end;{with stackmenu1}
  {arrays will be nilled later. This is done for early exits}
end;


procedure stack_sigmaclip(oversize:integer; var files_to_process : array of TfileToDo; out counter : integer); {stack using sigma clip average}
type
   tsolution  = record
     solution_vectorX : solution_vector {array[0..2] of double};
     solution_vectorY : solution_vector;
     cblack : double;
   end;

var
    solutions      : array of tsolution;

var
    fitsX,fitsY,c,width_max, height_max, old_width, old_height,x_new,y_new,col ,binning,oversizeV         : integer;
    background_correction, variance_factor, value,weightF,hfd_min                                         : double;
    init, solution, use_star_alignment,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,vector_based :boolean;


begin
  with stackmenu1 do
  begin
    {move often uses setting to booleans. Great speed improved if use in a loop and read many times}
    variance_factor:=sqr(strtofloat2(stackmenu1.sd_factor1.text));

    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}

    use_star_alignment:=stackmenu1.use_star_alignment1.checked;
    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometry_internal1.checked;

    counter:=0;
    sum_exp:=0;
    jd_sum:=0;{sum of Julian midpoints}
    jd_stop:=0;{end observations in Julian day}

    init:=false;
    background_correction:=0;{required for astrometric alignment}
    {light average}
    begin
      counter:=0;
      sum_exp:=0;
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
        if ((esc_pressed) or (load_fits(filename2,true {light},true,0,img_loaded)=false)) then begin memo2_message('Error');{can't load} exit;end;

        if init=true then
        begin
           if ((old_width<>width2) or (old_height<>height2)) then memo2_message('█ █ █ █ █ █  Warning different size image!');
           if naxis3>length(img_average) {naxis3} then begin memo2_message('█ █ █ █ █ █  Abort!! Can'+#39+'t combine mono and colour files.'); exit;end;
        end;


        if init=false then {phase (1) average}
        begin
          binning:=report_binning;{select binning based on the height of the light}
          backup_header;{backup header and solution}
          initialise_var1;{set variables correct}
          initialise_var2;{set variables correct}
          if ((bayerpat='') and (make_osc_color1.checked)) then
             if stackmenu1.bayer_pattern1.Text='auto' then memo2_message('█ █ █ █ █ █ Warning, Bayer colour pattern not in the header! Check colours and if wrong set Bayer pattern manually in tab "stack alignment". █ █ █ █ █ █')
             else
             if test_bayer_matrix(img_loaded)=false then  memo2_message('█ █ █ █ █ █ Warning, grayscale image converted to colour! Un-check option "convert OSC to colour". █ █ █ █ █ █');
        end;

        apply_dark_flat(filter_name,{var} dark_count,flat_count,flatdark_count);{apply dark, flat if required, renew if different exposure or ccd temp}
        {these global variables are passed-on in procedure to protect against overwriting}

        memo2_message('Adding light file: '+inttostr(c+1)+'-'+nr_selected1.caption+' "'+filename2+' dark compensated to light average. Using '+inttostr(dark_count)+' dark(s), '+inttostr(flat_count)+' flat(s), '+inttostr(flatdark_count)+' flat-dark(s)') ;
        Application.ProcessMessages;
        if esc_pressed then exit;

        if make_osc_color1.checked then {do demosaic bayer}
        begin
          if naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
          else
          demosaic_bayer(img_loaded); {convert OSC image to colour}
         {naxis3 is now 3}
        end;

        if ((init=false ) and (use_astrometry_internal=false)) then {first image and not astrometry_internal}
        begin
          if ((use_manual_align) or (use_ephemeris_alignment)) then
          begin
            referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
            referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
          end
          else
          begin
            bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,true{update hist},starlist1);{bin, measure background, find stars}

            find_quads(starlist1,0,quad_smallest,quad_star_distances1);{find quads for reference image}
            pedestal_s:=cblack;{correct for difference in background, use cblack from first image as reference. Some images have very high background values up to 32000 with 6000 noise, so fixed pedestal_s of 1000 is not possible}
            if pedestal_s<500 then pedestal_s:=500;{prevent image noise could go below zero}
            background_correction:=pedestal_s-cblack;
            datamax_org:=datamax_org+background_correction; if datamax_org>$FFFF then  datamax_org:=$FFFF; {note datamax_org is already corrected in apply dark}
          end;
        end;

        if init=false then {init}
        begin
          if oversize<0 then {shrink, adapt in ratio}
          begin
            oversize:=max(oversize,-round((width2-100)/2) );{minimum image width is 100}
            oversizeV:=round(oversize*height2/width2);{vertical}
            height_max:=height2+oversizeV*2;
          end
          else
          begin
            oversizeV:=oversize;
            height_max:=height2+oversize*2;
          end;
          width_max:=width2+oversize*2;

          setlength(img_average,naxis3,width_max,height_max);
          setlength(img_temp,naxis3,width_max,height_max);
            for fitsY:=0 to height_max-1 do
             for fitsX:=0 to width_max-1 do
               for col:=0 to naxis3-1 do
               begin
                 img_average[col,fitsX,fitsY]:=0; {clear img_average}
                 img_temp[col,fitsX,fitsY]:=0; {clear img_temp}
               end;
          old_width:=width2;
          old_height:=height2;
        end;{init, c=0}

        solution:=true;
        if use_astrometry_internal then sincos(dec0,SIN_dec0,COS_dec0) {do this in advance since it is for each pixel the same}
        else
        begin {align using star match}
           if init=true then {second image}
              begin
                if ((use_manual_align) or (use_ephemeris_alignment)) then
                begin {manual alignment}
                  solution_vectorX[2]:=referenceX-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {calculate correction}
                  solution_vectorY[2]:=referenceY-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]);
                  memo2_message('Solution x:=x+'+floattostr6(solution_vectorX[2])+',  y:=y+'+floattostr6(solution_vectorY[2]));
                end
                else
                begin{internal alignment}
                  bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,true{update hist},starlist2);{bin, measure background, find stars}

                  background_correction:=pedestal_s-cblack;{correct later for difference in background}
                  datamax_org:=datamax_org+background_correction; if datamax_org>$FFFF then  datamax_org:=$FFFF; {note datamax_org is already corrected in apply dark}

                  find_quads(starlist2,0,quad_smallest,quad_star_distances2);{find star quads for new image}
                  if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then {find difference between ref image and new image}
                  begin
                    memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.'
                       +'  Solution x:='+floattostr6(solution_vectorX[0])+'*x+ '+floattostr6(solution_vectorX[1])+'*y+ '+floattostr6(solution_vectorX[2])
                       +',  y:='+floattostr6(solution_vectorY[0])+'*x+ '+floattostr6(solution_vectorY[1])+'*y+ '+floattostr6(solution_vectorY[2]) );

                    solutions[c].solution_vectorX:= solution_vectorX;{store solutions}
                    solutions[c].solution_vectorY:= solution_vectorY;
                    solutions[c].cblack:=cblack;


                  end
                    else
                    begin
                      memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
                      files_to_process[c].name:=''; {remove file from list}
                      solution:=false;
                      ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[2]:=6;{mark 3th column with exclamation}
                      ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_result]:='no solution';{no stack result}
                    end;
                 end;{internal alignment}
              end
              else
              begin {first image}
                reset_solution_vectors(1);{no influence on the first image}
                solutions[c].solution_vectorX:= solution_vectorX; {store solutions for later}
                solutions[c].solution_vectorY:= solution_vectorY;
                solutions[c].cblack:=cblack;
               end;

        end;
        init:=true;{initialize for first image done}

        if solution then
        begin
          inc(counter);
          sum_exp:=sum_exp+exposure;
          if exposure<>0 then weightF:=exposure/exposure_ref else weightF:=1;{influence of each image depending on the exposure_time}

          date_to_jd(date_obs);{convert date-obs to jd}
          if jd>jd_stop then jd_stop:=jd;
          jd_sum:=jd_sum+jd+exposure/(2*24*3600);{sum julian days of images at midpoint exposure. Add half exposure in days to get midpoint}

          vector_based:=((use_star_alignment) or (use_manual_align) or (use_ephemeris_alignment));
          if ((vector_based=false) and (a_order=0)) then {no SIP from astronomy.net}
          begin
            astrometric_to_vector;{convert astrometric solution to vector solution}
            vector_based:=true;
          end;

          for fitsY:=1 to height2 do {skip outside "bad" pixels if mosaic mode}
          for fitsX:=1 to width2  do
          begin
            calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
            x_new:=round(x_new_float+oversize);y_new:=round(y_new_float+oversizeV);

            if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
            begin
              for col:=0 to naxis3-1 do
              begin
                img_average[col,x_new,y_new]:=img_average[col,x_new,y_new]+ img_loaded[col,fitsX-1,fitsY-1]+background_correction;{Note fits count from 1, image from zero}
                img_temp[col,x_new,y_new]:=img_temp[col,x_new,y_new]+weightF {norm 1};{count the number of image pixels added=samples}
              end;
            end;
          end;
        end;
        progress_indicator(10+round(0.3333*90*(counter)/length(files_to_process){(ListView1.items.count)}),' ■□□');{show progress}
        finally
        end;
      end;{try}
      if counter<>0 then
      For fitsY:=0 to height_max-1 do
        for fitsX:=0 to width_max-1 do
            for col:=0 to naxis3-1 do
            if img_temp[col,fitsX,fitsY]<>0 then
               img_average[col,fitsX,fitsY]:=img_average[col,fitsX,fitsY]/img_temp[col,fitsX,fitsY];{scale to one image by diving by the number of pixels added}
//      img_loaded[col,fitsX,fitsY]:=img_average[col,fitsX,fitsY]

    end;  {light average}

//    plot_fits(mainwindow.image1,true,true);{plot real}
//    exit;


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
          if ((esc_pressed) or (load_fits(filename2,true {light},true,0,img_loaded)=false)) then begin memo2_message('Error');{can't load} exit;end;

          if init=false then
          begin
            {not required. Done in first step}
          end;

          apply_dark_flat(filter_name, {var} dark_count,flat_count,flatdark_count);{apply dark, flat if required, renew if different exposure or ccd temp}
          {these global variables are passed-on in procedure to protect against overwriting}

          memo2_message('Calculating pixels σ of light file '+inttostr(c+1)+'-'+nr_selected1.caption+' '+filename2+' Using '+inttostr(dark_count)+' dark(s), '+inttostr(flat_count)+' flat(s), '+inttostr(flatdark_count)+' flat-dark(s)') ;
          Application.ProcessMessages;
          if esc_pressed then exit;

          if make_osc_color1.checked then {do demosaic bayer}
          begin
            if naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
            else
            demosaic_bayer(img_loaded); {convert OSC image to colour}
           {naxis3 is now 3}
          end;

          if init=false then {init (2) for standard deviation step}
          begin
            setlength(img_variance,naxis3,width_max,height_max);{mono}
            for fitsY:=0 to height_max-1 do
            for fitsX:=0 to width_max-1 do
            begin
              for col:=0 to naxis3-1 do img_variance[col,fitsX,fitsY]:=0; {clear img_average}
            end;
            old_width:=width2;
            old_height:=height2;
          end;{c=0}

          inc(counter);

          if use_astrometry_internal then  sincos(dec0,SIN_dec0,COS_dec0) {do this in advance since it is for each pixel the same}
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
                solution_vectorX[2]:=referenceX-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {calculate correction}
                solution_vectorY[2]:=referenceY-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]);
              end;
            end
            else
            begin  {reuse solution from first step average}
              solution_vectorX:=solutions[c].solution_vectorX; {restore solution}
              solution_vectorY:=solutions[c].solution_vectorY;
              cblack:=solutions[c].cblack;
              background_correction:=pedestal_s-cblack;{correction for difference in background}
              datamax_org:=datamax_org+background_correction; if datamax_org>$FFFF then  datamax_org:=$FFFF; {note datamax_org is already corrected in apply dark}
            end;
          end;
          init:=true;{initialize for first image done}

          vector_based:=((use_star_alignment) or (use_manual_align) or (use_ephemeris_alignment));
          if ((vector_based=false) and (a_order=0)) then {no SIP from astronomy.net}
          begin
            astrometric_to_vector;{convert astrometric solution to vector solution}
            vector_based:=true;
          end;

          for fitsY:=1 to height2 do {skip outside "bad" pixels if mosaic mode}
          for fitsX:=1 to width2  do
          begin
            calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
            x_new:=round(x_new_float+oversize);y_new:=round(y_new_float+oversizeV);
            if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
            begin
              for col:=0 to naxis3-1 do img_variance[col,x_new,y_new]:=img_variance[col,x_new,y_new] +  sqr( img_loaded[col,fitsX-1,fitsY-1]+ background_correction - img_average[col,x_new,y_new]); {Without flats, sd in sqr, work with sqr factors to avoid sqrt functions for speed}
            end;
          end;
          progress_indicator(10+30+round(0.33333*90*(counter)/length(files_to_process){(ListView1.items.count)}),' ■■□');{show progress}
        finally
        end;
      end;{try}
      if counter<>0 then
        For fitsY:=0 to height_max-1 do
          for fitsX:=0 to width_max-1 do
            for col:=0 to naxis3-1 do
              if img_temp[col,fitsX,fitsY]<>0 then {reuse the img_temp from light average}
                 img_variance[col,fitsX,fitsY]:=1+img_variance[col,fitsX,fitsY]/img_temp[col,fitsX,fitsY]; {the extra 1 is for saturated images giving a SD=0}{scale to one image by diving by the number of pixels tested}
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
          if ((esc_pressed) or (load_fits(filename2,true {light},true,0,img_loaded)=false)) then begin memo2_message('Error');{can't load} exit;end;

          apply_dark_flat(filter_name, {var} dark_count,flat_count,flatdark_count);{apply dark, flat if required, renew if different exposure or ccd temp}

          memo2_message('Combining '+inttostr(c+1)+'-'+nr_selected1.caption+' "'+filename2+'", ignoring outliers. Using '+inttostr(dark_count)+' dark(s), '+inttostr(flat_count)+' flat(s), '+inttostr(flatdark_count)+' flat-dark(s)') ;
          Application.ProcessMessages;
          if esc_pressed then exit;

          if make_osc_color1.checked then {do demosaic bayer}
          begin
            if naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
            else
            demosaic_bayer(img_loaded); {convert OSC image to colour}
           {naxis3 is now 3}
          end;

          if init=false then {init, (3) step throw outliers out}
          begin
            setlength(img_temp,naxis3,width_max,height_max);
            setlength(img_final,naxis3,width_max,height_max);
            for fitsY:=0 to height_max-1 do
            for fitsX:=0 to width_max-1 do
            begin
              for col:=0 to naxis3-1 do
              begin
                img_temp[col,fitsX,fitsY]:=0; {clear img_temp}
                img_final[col,fitsX,fitsY]:=0; {clear img_temp}
              end;
            end;
            old_width:=width2;
            old_height:=height2;
          end;{init}

          inc(counter);

          if use_astrometry_internal then  sincos(dec0,SIN_dec0,COS_dec0) {do this in advance since it is for each pixel the same}
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
                solution_vectorX[2]:=referenceX-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {calculate correction}
                solution_vectorY[2]:=referenceY-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]);
              end;
            end
            else
            begin  {reuse solution from first step average}
              solution_vectorX:=solutions[c].solution_vectorX; {restore solution}
              solution_vectorY:=solutions[c].solution_vectorY;
              cblack:=solutions[c].cblack;
              background_correction:=pedestal_s-cblack;{correct for difference in background}
              datamax_org:=datamax_org+background_correction; if datamax_org>$FFFF then  datamax_org:=$FFFF; {note datamax_org is already corrected in apply dark}
            end;
          end;
          init:=true;{initialize for first image done}

          vector_based:=((use_star_alignment) or (use_manual_align) or (use_ephemeris_alignment));
          if ((vector_based=false) and (a_order=0)) then {no SIP from astronomy.net}
          begin
            astrometric_to_vector;{convert astrometric solution to vector solution}
            vector_based:=true;
          end;

          for fitsY:=1 to height2 do
          for fitsX:=1 to width2  do
          begin
            calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
            x_new:=round(x_new_float+oversize);y_new:=round(y_new_float+oversizeV);
            if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
            begin
              for col:=0 to naxis3-1 do {do all colors}
              begin
                value:=img_loaded[col,fitsX-1,fitsY-1]+ background_correction;
       //         if(( fitsx=100) and (fitsY=100)) then
      //          beep;
                if sqr (value - img_average[col,x_new,y_new])< variance_factor*{sd sqr}( img_variance[col,x_new,y_new])  then {not an outlier}
                begin
                  img_final[col,x_new,y_new]:=img_final[col,x_new,y_new]+ value;{dark and flat, flat dark already applied}
                  img_temp[col,x_new,y_new]:=img_temp[col,x_new,y_new]+weightF {norm 1};{count the number of image pixels added=samples}
                end;
              end;
            end;
          end;

          progress_indicator(10+60+round(0.33333*90*(counter)/length(files_to_process){(ListView1.items.count)}),' ■■■');{show progress}
          finally
        end;
      end;

     {scale to number of pixels}
      if counter<>0 then
      begin
        height2:=height_max;
        width2:=width_max;
        setlength(img_loaded,naxis3,width2,height2);{new size}

        for col:=0 to naxis3-1 do {do one or three colors} {compensate for number of pixel values added per position}
          For fitsY:=0 to height2-1 do
            for fitsX:=0 to width2-1 do
            if img_temp[col,fitsX,fitsY]<>0 then img_loaded[col,fitsX,fitsY]:=img_final[col,fitsX,fitsY]/img_temp[col,fitsX,fitsY] {scale to one image by diving by the number of pixels added}
            else
            begin { black spot filter. Note for this version img_temp is counting for each color since they could be different}
              if ((fitsX>0) and (fitsY>0)) then {black spot filter, fix black spots which show up if one image is rotated}
              begin
                if ((img_temp[col,fitsX-1,fitsY]<>0){and (img_temp[col,fitsX,fitsY-1]<>0)}{keep borders nice for last pixel right}) then img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX-1,fitsY]{take nearest pixel x-1 as replacement}
                else
                if img_temp[col,fitsX,fitsY-1]<>0 then img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX,fitsY-1]{take nearest pixel y-1 as replacement}
                else
                img_loaded[col,fitsX,fitsY]:=0;{clear img_loaded since it is resized}
              end {fill black spots}
              else
              img_loaded[col,fitsX,fitsY]:=0;{clear img_loaded since it is resized}
            end; {black spot filter}
      end;{counter<>0}
    end;{throw out the outliers of light-dark images}

  end;{with stackmenu1}
  {image arrays will be nilled later. This is done for early exits}

  solutions:=nil;


end;   {stack using sigma clip average}

procedure calibration_and_alignment(oversize:integer; var files_to_process : array of TfileToDo; out counter : integer); {calibration_and_alignment only}
var
    fitsX,fitsY,c,width_max, height_max, old_width, old_height,x_new,y_new,col, binning, oversizeV   : integer;
    background_correction, hfd_min      : double;
    init, solution, use_star_alignment,use_manual_align,use_ephemeris_alignment, use_astrometry_internal,vector_based :boolean;
begin
  with stackmenu1 do
  begin
    {move often uses setting to booleans. Great speed improved if use in a loop and read many times}
    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}

    use_star_alignment:=stackmenu1.use_star_alignment1.checked;
    use_manual_align:=stackmenu1.use_manual_alignment1.checked;
    use_ephemeris_alignment:=stackmenu1.use_ephemeris_alignment1.checked;
    use_astrometry_internal:=use_astrometry_internal1.checked;

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
        if ((esc_pressed) or (load_fits(filename2,true {light},true,0,img_loaded)=false)) then begin memo2_message('Error');{can't load} exit;end;

        if init=true then
        begin
           if ((old_width<>width2) or (old_height<>height2)) then memo2_message('█ █ █ █ █ █  Warning different size image!');
           if naxis3>length(img_average) {naxis3} then begin memo2_message('█ █ █ █ █ █  Abort!! Can'+#39+'t combine mono and colour files.'); exit;end;
        end;


        if init=false then
        begin
          binning:=report_binning;{select binning based on the height of the light}
          backup_header;{backup header and solution}
          initialise_var1;{set variables correct}
          initialise_var2;{set variables correct}
          if ((bayerpat='') and (make_osc_color1.checked)) then
             if stackmenu1.bayer_pattern1.Text='auto' then memo2_message('█ █ █ █ █ █ Warning, Bayer colour pattern not in the header! Check colours and if wrong set Bayer pattern manually in tab "stack alignment". █ █ █ █ █ █')
             else
             if test_bayer_matrix(img_loaded)=false then  memo2_message('█ █ █ █ █ █ Warning, grayscale image converted to colour! Un-check option "convert OSC to colour". █ █ █ █ █ █');
        end;

        apply_dark_flat(filter_name,{var} dark_count,flat_count,flatdark_count);{apply dark, flat if required, renew if different exposure or ccd temp}
        {these global variables are passed-on in procedure to protect against overwriting}

        memo2_message('Calibrating and aligning file: '+inttostr(c+1)+'-'+nr_selected1.caption+' "'+filename2+' dark compensated to light average. Using '+inttostr(dark_count)+' dark(s), '+inttostr(flat_count)+' flat(s), '+inttostr(flatdark_count)+' flat-dark(s)') ;
        Application.ProcessMessages;
        if esc_pressed then exit;

        if make_osc_color1.checked then {do demosaic bayer}
        begin
          if naxis3>1 then memo2_message('█ █ █ █ █ █ Warning, light is already in colour ! Will skip demosaic. █ █ █ █ █ █')
          else
          demosaic_bayer(img_loaded); {convert OSC image to colour}
         {naxis3 is now 3}
        end;

        if ((init=false ) and (use_astrometry_internal=false)) then {first image and not astrometry_internal}
        begin
          if ((use_manual_align) or (use_ephemeris_alignment)) then
          begin
            referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
            referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
          end
          else
          begin
            bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,true{update hist},starlist1);{bin, measure background, find stars}
            find_quads(starlist1,0,quad_smallest,quad_star_distances1);{find quads for reference image}
            pedestal_s:=cblack;{correct for difference in background, use cblack from first image as reference. Some images have very high background values up to 32000 with 6000 noise, so fixed pedestal_s of 1000 is not possible}
            if pedestal_s<500 then pedestal_s:=500;{prevent image noise could go below zero}
            background_correction:=pedestal_s-cblack;
            datamax_org:=datamax_org+background_correction; if datamax_org>$FFFF then  datamax_org:=$FFFF; {note datamax_org is already corrected in apply dark}
          end;
        end;


        if init=false then {init}
        begin
          if oversize<0 then {shrink a lot, adapt in ratio}
          begin
            oversize:=max(oversize,-round((width2-100)/2) );{minimum image width is 100}
            oversizeV:=round(oversize*height2/width2);{vertical shrinkage in pixels}
            height_max:=height2+oversizeV*2;
          end
          else
          begin
            oversizeV:=oversize;
            height_max:=height2+oversize*2;
          end;
          width_max:=width2+oversize*2;


          setlength(img_average,naxis3,width_max,height_max);
          setlength(img_temp,naxis3,width_max,height_max);
          for fitsY:=0 to height_max-1 do
            for fitsX:=0 to width_max-1 do
              for col:=0 to naxis3-1 do
              begin
                img_average[col,fitsX,fitsY]:=0; {clear img_average}
                img_temp[col,fitsX,fitsY]:=0; {clear img_temp}
              end;
          old_width:=width2;
          old_height:=height2;

          if ((use_manual_align) or (use_ephemeris_alignment)) then
          begin
            referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {reference offset}
            referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]); {reference offset}
          end;
        end;{init, c=0}

        solution:=true;
        if use_astrometry_internal then sincos(dec0,SIN_dec0,COS_dec0) {do this in advance since it is for each pixel the same}
        else
        begin {align using star match}
          if init=true then {second image}
          begin
            if ((use_manual_align) or (use_ephemeris_alignment)) then
            begin {manual alignment}
              solution_vectorX[2]:=referenceX-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_X]); {calculate correction}
              solution_vectorY[2]:=referenceY-strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[L_Y]);
              memo2_message('Solution x:=x+'+floattostr6(solution_vectorX[2])+',  y:=y+'+floattostr6(solution_vectorY[2]));
            end
            else
            begin{internal alignment}
              bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,true{update hist},starlist2);{bin, measure background, find stars}

              background_correction:=pedestal_s-cblack;
              datamax_org:=datamax_org+background_correction; if datamax_org>$FFFF then  datamax_org:=$FFFF; {note datamax_org is already corrected in apply dark}

              find_quads(starlist2,0,quad_smallest,quad_star_distances2);{find star quads for new image}
              if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then {find difference between ref image and new image}
              memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.'
                   +'  Solution x:='+floattostr6(solution_vectorX[0])+'*x+ '+floattostr6(solution_vectorX[1])+'*y+ '+floattostr6(solution_vectorX[2])
                   +',  y:='+floattostr6(solution_vectorY[0])+'*x+ '+floattostr6(solution_vectorY[1])+'*y+ '+floattostr6(solution_vectorY[2]) )

                else
                begin
                  memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
                  files_to_process[c].name:=''; {remove file from list}
                  solution:=false;
                  ListView1.Items.item[files_to_process[c].listviewindex].SubitemImages[2]:=6;{mark 3th column with exclaimation}
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

          vector_based:=((use_star_alignment) or (use_manual_align) or (use_ephemeris_alignment));
          if ((vector_based=false) and (a_order=0)) then {no SIP from astronomy.net}
          begin
            astrometric_to_vector;{convert astrometric solution to vector solution}
            vector_based:=true;
          end;

          for fitsY:=1 to height2 do {skip outside "bad" pixels if mosaic mode}
          for fitsX:=1 to width2  do
          begin
            calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
            x_new:=round(x_new_float+oversize);y_new:=round(y_new_float+oversizeV);

            if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
            begin
              for col:=0 to naxis3-1 do
              begin
                img_average[col,x_new,y_new]:=img_average[col,x_new,y_new]+ img_loaded[col,fitsX-1,fitsY-1]+background_correction;{Note fits count from 1, image from zero}
                img_temp[col,x_new,y_new]:=img_temp[col,x_new,y_new]+1;{count the number of image pixels added=samples}
              end;
            end;
          end;
        end;


        {scale to number of pixels}
        height2:=height_max;
        width2:=width_max;
        setlength(img_loaded,naxis3,width2,height2);{new size}

        for col:=0 to naxis3-1 do {do one or three colors} {compensate for number of pixel values added per position}
          For fitsY:=0 to height2-1 do
            for fitsX:=0 to width2-1 do
            if img_temp[col,fitsX,fitsY]<>0 then img_loaded[col,fitsX,fitsY]:=img_average[col,fitsX,fitsY]/img_temp[col,fitsX,fitsY] {scale to one image by diving by the number of pixels added}
            else
            begin { black spot filter. Note for this version img_temp is counting for each color since they could be different}
              if ((fitsX>0) and (fitsY>0)) then {black spot filter, fix black spots which show up if one image is rotated}
              begin
                if ((img_temp[col,fitsX-1,fitsY]<>0){and (img_temp[col,fitsX,fitsY-1]<>0)}{keep borders nice for last pixel right}) then img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX-1,fitsY]{take nearest pixel x-1 as replacement}
                else
                if img_temp[col,fitsX,fitsY-1]<>0 then img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX,fitsY-1]{take nearest pixel y-1 as replacement}
                else
                img_loaded[col,fitsX,fitsY]:=0;{clear img_loaded since it is resized}
              end {fill black spots}
              else
              img_loaded[col,fitsX,fitsY]:=0;{clear img_loaded since it is resized}
            end; {black spot filter}

        {save}
        filename2:=ChangeFileExt(Filename2,'_aligned.fit');{rename}

        restore_header;
        update_text   ('COMMENT 1','  Calibrated & aligned by ASTAP. www.hnsky.org');
        update_text   ('CALSTAT =',#39+calstat+#39); {calibration status}
        add_integer('DARK_CNT=',' / Darks used for luminance.               ' ,dark_count);{for interim lum,red,blue...files. Compatible with master darks}
        add_integer('FLAT_CNT=',' / Flats used for luminance.               ' ,flat_count);{for interim lum,red,blue...files. Compatible with master flats}
        add_integer('BIAS_CNT=',' / Flat-darks used for luminance.          ' ,flatdark_count);{for interim lum,red,blue...files. Compatible with master flats}
         { ASTAP keyword standard:}
         { interim files can contain keywords: EXPOSURE, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
         { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

        if nrbits=16 then
          save_fits(img_loaded,filename2,16,true)
        else
        save_fits(img_loaded,filename2,-32,true);
         memo2_message('New aligned image created: '+filename2);
        report_results('?',inttostr(round(exposure)),0,999 {color icon});{report result in tab result using modified filename2}
        progress_indicator(10+round(90*(counter)/length(files_to_process){(ListView1.items.count)}),'Cal');{show progress}
        finally
        end;
      end;{try}
    end;{}
  end;  {with stackmenu1}
  {arrays will be nilled later. This is done for early exits}
end;   {calibration and alignment}



end.

