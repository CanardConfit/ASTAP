unit unit_live_stacking;
{Copyright (C) 2019 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

{$mode delphi}

interface

uses
  Classes, SysUtils,forms,fileutil;

procedure stack_live(oversize:integer; path :string);{stack live average}

const
  pause_pressed: boolean=false;

implementation

uses unit_stack, astap_main,unit_stack_routines,unit_astrometric_solving,unit_star_align,math;

const
  oldra0  :double=0;
  olddec0 :double=0;
  oldexposure:double=0;

function file_available(stack_directory:string; var filen: string ) : boolean; {check if fits file is available and report the filename}
var
   thefiles : Tstringlist;
begin
  try
  //No need to create the stringlist; the function does that for you
  theFiles := FindAllFiles(stack_directory, '*.fit;*.fits;*.FIT;*.FITS;'+
                                            '*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP;*.tif*;*.TIF;'+
                                            '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef', true); //find images

  if TheFiles.count>0 then
  begin
    filen:=TheFiles[0];
    result:=true;
  end
  else
    result:=false;
  finally
    thefiles.Free;
  end;
end;



procedure update_header;
begin
  mainwindow.Memo1.Text:=memo1_text;{use saved fits header first FITS file}
  update_text('COMMENT 1','  Written by Astrometric Stacking Program. www.hnsky.org');
  update_text   ('HISTORY 1','  Stacking method LIVE STACKING');
  update_integer('EXPTIME =',' / Total luminance exposure time in seconds.      ' ,round(sum_exp));
  update_text ('CALSTAT =',#39+calstat+#39); {calibration status}
  update_text ('DATE-OBS=',#39+JdToDate(jd_start)+#39);{give start point exposures}
  update_float('JD-AVG  =',' / Julian Day of the observation mid-point.       ', jd_sum/counterL);{give midpoint of exposures}
  update_text ('DATE-AVG=',#39+JdToDate(jd_sum/counterL)+#39);{give midpoint of exposures}
  update_integer('LIGH_CNT=',' / Light frames combined.                  ' ,counterL); {for interim lum,red,blue...files.}
  update_integer('DARK_CNT=',' / Darks used for luminance.               ' ,dark_count);{for interim lum,red,blue...files. Compatible with master darks}
  update_integer('FLAT_CNT=',' / Flats used for luminance.               ' ,flat_count);{for interim lum,red,blue...files. Compatible with master flats}
  update_integer('BIAS_CNT=',' / Flat-darks used for luminance.          ' ,flatdark_count);{for interim lum,red,blue...files. Compatible with master flats}

  mainwindow.memo1.visible:=true;{Show new header again}

end;

function  load_thefile(filen:string) : boolean;
var
   ext1 : string;
begin
  ext1:=uppercase(ExtractFileExt(filen));

  if ((ext1='.FIT') or (ext1='.FITS')) then
    result:= load_fits(filen,true {light},true,true {reset var},img_loaded)
  else
  if check_raw_file_extension(ext1) then {check if extension is from raw file}
    result:=convert_load_raw(filen) {raw}
  else
    result:=load_tiffpngJPEG(filename2,img_loaded);
end;

procedure stack_live(oversize:integer; path :string);{stack live average}
var
    fitsX,fitsY,c,width_max, height_max,x, old_width, old_height,x_new,y_new,col           : integer;
    {background_correction,} flat_factor,  h,dRA, dDec,det, delta,gamma,ra_new, dec_new, sin_dec_new,cos_dec_new,delta_ra,SIN_delta_ra,COS_delta_ra,u0,v0,u,v, value, weightF,distance    : double;
    init, solution,use_star_alignment,use_manual_alignment, use_astrometry_internal, use_astrometry_net,vector_based,waiting,transition_image :boolean;

    counter,total_counter,bad_counter :  integer;

    procedure reset_var;{reset variables  including init:=false}
    begin
      init:=false;
      counter:=0;
      bad_counter:=0;
      sum_exp:=0;
      jd_sum:=0;{sum of Julian midpoints}
      jd_start:=9999999999;{start observations in Julian day}

      dark_exposure:=987654321;{not done indication}
      dark_temperature:=987654321;
      flat_filter:='987654321';{not done indication}

    end;

begin
  with stackmenu1 do
  begin
    use_star_alignment:=stackmenu1.use_star_alignment1.checked;
    use_manual_alignment:=stackmenu1.use_manual_alignment1.checked;
    use_astrometry_internal:=use_astrometry_internal1.checked;
    use_astrometry_net:=use_astrometry_net1.checked;

    reset_var; {reset variables  including init:=false}


    pause_pressed:=false;
    esc_pressed:=false;
    total_counter:=0;

    mainwindow.memo1.visible:=false;{Hide header}

//   (file_available2(path,filename2 {file found}));

    {live stacking}
    repeat
    begin
      if ((pause_pressed=false) and (file_available(path,filename2 {file found}))) then
      begin
        try { Do some lengthy operation }
          waiting:=false;
          transition_image:=false;

          Application.ProcessMessages;
          {load image}
          if ((esc_pressed) or (load_thefile(filename2)=false)) then begin memo2_message('Error');{can't load} exit;end;

          ang_sep(ra0,dec0,oldra0,olddec0 ,distance); {calculate distance in radians.   {test of mount has moved}
          oldra0:=ra0;olddec0:=dec0;
          if distance>(0.2*pi/180) then
          begin
            reset_var; {reset variables including init:=false}
            if total_counter<>0 then {new position not caused by start}
            begin
              transition_image:=true; {image with possible slewing involved}
              memo2_message('New telescope position at distance '+floattostrF2(distance*180/pi,0,2)+'°. New stack started. First transition image will be skipped');
            end;
          end
          else
          {test if exposure has changed}
          if exposure<>oldexposure then
          begin
            reset_var; {reset variables including init:=false}
            memo2_message('New exposure time. New stack started');
          end;
          oldexposure:=exposure;

          if transition_image=false then {else skip this image, could slewed during this image}
          begin
            if init=false then
           begin
              initialise1;{set variables correct. Do this before apply dark}
              initialise2;{set variables correct}

              memo1_text:=mainwindow.Memo1.Text;{save fits header first FITS file}
              if ((make_osc_color1.checked) and (test_bayer_matrix(img_loaded)=false)) then memo2_message('█ █ █ █ █ █ Warning, not an OSC image! █ █ █ █ █ █');
              if ((make_osc_color1.checked=false) and (test_bayer_matrix(img_loaded)=true)) then memo2_message('█ █ █ █ █ █ Warning, OSC image is stacked as monochrome! Check mark convert OSC to colour. █ █ █ █ █ █');
            end;

            apply_dark_flat(filter_name,round(exposure),set_temperature,width2,{var} dark_count,flat_count,flatdark_count,flat_factor);{apply dark, flat if required, renew if different exposure or ccd temp}
            {these global variables are passed-on in procedure to protect against overwriting}

            memo2_message('Adding file: '+inttostr(counter)+' "'+filename2+'"  to average. Using '+inttostr(dark_count)+' darks, '+inttostr(flat_count)+' flats, '+inttostr(flatdark_count)+' flat-darks') ;
            Application.ProcessMessages;
            if esc_pressed then exit;

            if make_osc_color1.checked then
               demosaic_bayer; {convert OSC image to colour}

            if init=true then   if ((old_width<>width2) or (old_height<>height2)) then memo2_message('█ █ █ █ █ █  Warning different size image!');

            if ((use_astrometry_internal) or (use_astrometry_net)) then
            begin {get_solution}
              if use_astrometry_net then if load_wcs_solution(filename2)=false {load astrometry.net solution succesfull} then
                         begin memo2_message('Abort, sequence error. No WCS solution found, exit.'); exit;end;{no solution found}
            end
            else {internal star alignment}
            if init=false then {first image}
            begin
              get_background(0,img_loaded,true,true {new since flat is applied, calculate also noise_level}, {var} cblack,star_level);
              find_stars(img_loaded,starlist1);{find stars and put them in a list}
              find_tetrahedrons_ref;{find tetrahedrons for reference image}
            end;


            if init=false then {init}
            begin
              memo2_message('Reference image is: '+filename2);
              image_path:=ExtractFilePath(filename2); {for saving later}
              width_max:=width2+oversize*2;
              height_max:=height2+oversize*2;

              setlength(img_average,naxis3,width_max,height_max);
              for fitsY:=0 to height_max-1 do
                for fitsX:=0 to width_max-1 do
                  for col:=0 to naxis3-1 do
                  begin
                    img_average[col,fitsX,fitsY]:=0; {clear img_average}
                  end;
              old_width:=width2;
              old_height:=height2;

            end;{init, c=0}

            solution:=true;

            {align using star match}
            if init=true then {second image}
            begin{internal alignment}
              get_background(0,img_loaded,true,true {unknown, calculate also noise_level} , {var} cblack,star_level);

              find_stars(img_loaded,starlist2);{find stars and put them in a list}
              find_tetrahedrons_new;{find triangels for new image}
              if find_offset_and_rotation(3,strtofloat2(stackmenu1.tetrahedron_tolerance1.text),false{do not save solution}) then {find difference between ref image and new image}
              memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' tetrahedrons selected matching within '+stackmenu1.tetrahedron_tolerance1.text+' tolerance.'
                     +'  Solution x:='+floattostr2(solution_vectorX[0])+'*x+ '+floattostr2(solution_vectorX[1])+'*y+ '+floattostr2(solution_vectorX[2])
                     +',  y:='+floattostr2(solution_vectorY[0])+'*x+ '+floattostr2(solution_vectorY[1])+'*y+ '+floattostr2(solution_vectorY[2]) )

               else
               begin
                 memo2_message('Not enough tetrahedron matches <3 or inconsistent solution, skipping this image.');
                 solution:=false;
               end;
             end{internal alignment}
             else
               reset_solution_vectors(1);{no influence on the first image}

            init:=true;{initialize for first image done}

            if solution then
            begin
              inc(counter);
              inc(total_counter);
              sum_exp:=sum_exp+exposure;
              if exposure<>0 then weightF:=exposure/exposure_ref else weightF:=1;{influence of each image depending on the exposure_time}

              date_obs_to_jd;{convert date-obs to jd}
              if jd<jd_start then jd_start:=jd;
              jd_sum:=jd_sum+jd+exposure/(2*24*3600);{sum julian days of images at midpoint exposure. Add half exposure in days to get midpoint}

              vector_based:=true;

              begin
                for fitsY:=1 to height2 do {skip outside "bad" pixels if mosaic mode}
                for fitsX:=1 to width2  do
                begin
                  calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
                  x_new_float:=x_new_float+oversize;y_new_float:=y_new_float+oversize;
                  x_new:=round(x_new_float);y_new:=round(y_new_float);
                  if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
                  begin
                    for col:=0 to naxis3-1 do {all colors}
                    begin
                      {serial stacking}
                      img_average[col,x_new,y_new]:=(img_average[col,x_new,y_new]*(counter-1)+ img_loaded[col,fitsX-1,fitsY-1])/(counter);{image loaded is already corrected with dark and flat}{NOTE: fits count from 1, image from zero}
                    end;
                  end;
                end;
              end;
              if counter=1 then getfits_histogram(0);{get histogram R,G,B YES, plot histogram YES, set min & max YES}
              CD1_1:=0;{kill any existing north arrow during plotting. Most likely wrong after stacking}
              height2:=height_max;
              width2:=width_max;
              img_loaded:=img_average;

              plot_fits(mainwindow.image1,false,false{do not show header in memo1});{plot real}

            end
            else
            inc(bad_counter);

            stackmenu1.files_live_stacked1.caption:=inttostr(counter)+' stacked, '+inttostr(bad_counter)+ ' failures ' ;{Show progress}
            application.hint:=inttostr(counter)+' stacked, '+inttostr(bad_counter)+ ' failures ' ;{Show progress}
          end; {no transition image}
  //
             if RenameFile(filename2,ChangeFileExt(filename2,ExtractFileExt(filename2)+'_' ))=false then {mark files as done, beep if failure}
//             if RenameFile(filename2,ChangeFileExt(filename2,'.fts'))=false then {mark files as done, beep if failure}
             beep;


        finally
        end;
      end
      else
      begin  {pause or no files}
        if waiting=false then {do this only once}
          begin
            if ((pause_pressed) and (counter>0)) then
          begin
            counterL:=counter;
            update_header;
            memo2_message('Live stack is suspended.')
          end
          else
          memo2_message('Live stack is waiting for files.');
        end;
        waiting:=true;
        Application.ProcessMessages;
        sleep(1000); {no new files, wait some time}
      end;

    end;{live average}

    until esc_pressed;

    counterL:=counter;
    if counter>0 then update_header;
  end;{with stackmenu1}
end;


end.

