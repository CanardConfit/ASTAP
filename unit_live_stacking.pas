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
  Classes, SysUtils,forms;

procedure stack_live(oversize:integer; path :string);{stack live average}

const
  pause_pressed: boolean=false;

implementation

uses unit_stack, astap_main,unit_stack_routines,unit_astrometric_solving,unit_star_align,math;

const
  oldra0  :double=0;
  olddec0 :double=0;

function find_file(stack_directory:string) : string;
var
  searchResult : TSearchRec;

begin
  if findfirst(stack_directory+PathDelim+'*.fit*', faAnyFile, searchResult) = 0 then
  begin
    result:= stack_directory+PathDelim+searchResult.Name;
    // Must free up resources used by these successful finds
    FindClose(searchResult);
  end
  else
  result:='';
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

procedure stack_live(oversize:integer; path :string);{stack live average}
var
    fitsX,fitsY,c,width_max, height_max,x, old_width, old_height,x_new,y_new,col           : integer;
    background_correction, flat_factor,  h,dRA, dDec,det, delta,gamma,ra_new, dec_new, sin_dec_new,cos_dec_new,delta_ra,SIN_delta_ra,COS_delta_ra,u0,v0,u,v, value, weightF,distance    : double;
    init, solution,use_star_alignment,use_manual_alignment, use_astrometry_internal, use_astrometry_net,vector_based :boolean;

    counter :  integer;

    procedure reset_var;{reset variables  including init:=false}
    begin
      init:=false;
      counter:=0;
      sum_exp:=0;
      jd_sum:=0;{sum of Julian midpoints}
      jd_start:=9999999999;{start observations in Julian day}
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

    mainwindow.memo1.visible:=false;{Hide header}


    {live stack specific}

    background_correction:=0;



    {live stacking}
    repeat
    begin
//      for c:=0 to length(files_to_process)-1 do
//      if length(files_to_process[c].name)>0 then
      filename2:=find_file(path);
      if ((filename2<>'') and (pause_pressed=false)) then


      begin

        try { Do some lengthy operation }
         // ListView1.Selected :=nil; {remove any selection}
         // ListView1.ItemIndex := files_to_process[c].listviewindex;{show wich file is processed}
        //  Listview1.Items[files_to_process[c].listviewindex].MakeVisible(False);{scroll to selected item}

         // filename2:=files_to_process[c].name;

          Application.ProcessMessages;



          {load image}
          if ((esc_pressed) or (load_fits(filename2,true {light},true,true {reset var},img_loaded)=false)) then begin memo2_message('Error');{can't load} exit;end;

          {test of mount has moved}
          ang_sep(ra0,dec0,oldra0,olddec0 ,distance);{calculate distance in radians}
          oldra0:=ra0;olddec0:=dec0;
          if distance>(20/3600)*(pi/180) then
          begin
            reset_var; {reset variables including init:=false}
            memo2_message('New telescope position. New stack started');
          end;

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
          begin
//             if drizzle_mode<>2 {<>Bayer drizzle}  then
             demosaic_bayer {convert OSC image to colour}
//             else naxis3:=3;{for bayer drizzle, demosaic will be done later}
             {naxis3 is now 3}
          end;

          if init=true then   if ((old_width<>width2) or (old_height<>height2)) then memo2_message('█ █ █ █ █ █  Warning different size image!');

          if ((use_astrometry_internal) or (use_astrometry_net)) then
          begin {get_solution}
            if use_astrometry_net then if load_wcs_solution(filename2)=false {load astrometry.net solution succesfull} then
                       begin memo2_message('Abort, sequence error. No WCS solution found, exit.'); exit;end;{no solution found}
          end
          else {internal star alignment}
          if init=false then {first image}
          begin
            if use_manual_alignment then
            begin
              referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[11+5]); {reference offset}
              referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[11+6]); {reference offset}
            end
            else
            begin
              get_background(0,img_loaded,true,true {new since flat is applied, calculate also noise_level}, {var} cblack,star_level);
              find_stars(img_loaded,starlist1);{find stars and put them in a list}
              find_tetrahedrons_ref;{find tetrahedrons for reference image}
//              pedestal:=cblack;{correct for difference in background, use cblack from first image as reference. Some images have very high background values up to 32000 with 6000 noise, so fixed pedestal of 1000 is not possible}
//              if pedestal<500 then pedestal:=500;{prevent image noise could go below zero}
//              background_correction:=pedestal-cblack;
//              datamax_org:=datamax_org+background_correction; if datamax_org>$FFFF then  datamax_org:=$FFFF; {note datamax_org is already corrected in apply dark}
            end;
          end;


          if init=false then {init}
          begin
            memo2_message('Reference image, largest with best HFD is: '+filename2);
            image_path:=ExtractFilePath(filename2); {for saving later}
            width_max:=width2+oversize*2;
            height_max:=height2+oversize*2;

         //   if drizzle_mode=1 then {drizzle} begin width_max:=width_max+width_max; height_max:=height_max+height_max end;
            setlength(img_average,naxis3,width_max,height_max);
//            setlength(img_temp,naxis3,width_max,height_max);
            for fitsY:=0 to height_max-1 do
              for fitsX:=0 to width_max-1 do
                for col:=0 to naxis3-1 do
                begin
                  img_average[col,fitsX,fitsY]:=0; {clear img_average}
//                  img_temp[col,fitsX,fitsY]:=0; {clear img_temp}
                end;
            old_width:=width2;
            old_height:=height2;

            if use_manual_alignment then
            begin
              referenceX:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[11+5]); {reference offset}
              referenceY:=strtofloat2(ListView1.Items.item[files_to_process[c].listviewindex].subitems.Strings[11+6]); {reference offset}
            end;
          end;{init, c=0}

          solution:=true;
          if ((use_astrometry_internal) or (use_astrometry_net)) then sincos(dec0,SIN_dec0,COS_dec0) {do this in advance since it is for each pixel the same}
          else
          begin {align using star match}
            if init=true then {second image}
            begin
              begin{internal alignment}
               // get_background(0,img_loaded,true,true {unknown, calculate also noise_level} , {var} cblack,star_level);
               // background_correction:=pedestal-cblack;
               // datamax_org:=datamax_org+background_correction; if datamax_org>$FFFF then  datamax_org:=$FFFF; {note datamax_org is already corrected in apply dark}

                find_stars(img_loaded,starlist2);{find stars and put them in a list}
                find_tetrahedrons_new;{find triangels for new image}
                if find_offset_and_rotation(3,strtofloat2(stackmenu1.tetrahedron_tolerance1.text),false{do not save solution}) then {find difference between ref image and new image}
                memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' tetrahedrons selected matching within '+stackmenu1.tetrahedron_tolerance1.text+' tolerance.'
                     +'  Solution x:='+floattostr2(solution_vectorX[0])+'*x+ '+floattostr2(solution_vectorX[1])+'*y+ '+floattostr2(solution_vectorX[2])
                     +',  y:='+floattostr2(solution_vectorY[0])+'*x+ '+floattostr2(solution_vectorY[1])+'*y+ '+floattostr2(solution_vectorY[2]) )

                  else
                  begin
                    memo2_message('Not enough tetrahedron matches <3 or inconsistent solution, skipping this image.');
                    files_to_process[c].name:=''; {remove file from list}
                    solution:=false;
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

            date_obs_to_jd;{convert date-obs to jd}
            if jd<jd_start then jd_start:=jd;
            jd_sum:=jd_sum+jd+exposure/(2*24*3600);{sum julian days of images at midpoint exposure. Add half exposure in days to get midpoint}

            vector_based:=true;

            //if drizzle_mode=0 then
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
            end
          end;
          stackmenu1.files_live_stacked1.caption:='Counter '+inttostr(counter);{Show progress}

          if RenameFile(filename2,ChangeFileExt(filename2,'.fts'))=false then {mark files as done, beep if failure}
             beep;


          if counter=1 then getfits_histogram(0);{get histogram R,G,B YES, plot histogram YES, set min & max YES}
          CD1_1:=0;{kill any existing north arrow during plotting. Most likely wrong after stacking}
          height2:=height_max;
          width2:=width_max;
          img_loaded:=img_average;

          plot_fits(mainwindow.image1,false,false{do not show header in memo1});{plot real}
           finally
        end;
      end
      else
      begin  {pause}
        if ((mainwindow.memo1.visible=false) and (counter>0)) then
        begin
          counterL:=counter;
          update_header;
          if pause_pressed then memo2_message('Live stack is suspended.')
          else
             memo2_message('Live stack is waiting for files.');

        end;

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

