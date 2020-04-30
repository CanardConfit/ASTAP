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
  live_stacking: boolean=false; {used to inhibit solving while live_stacking}

implementation

uses unit_stack, astap_main,unit_stack_routines,unit_astrometric_solving,unit_star_align,math;

const
  oldra0  :double=0;
  olddec0 :double=0;
  oldexposure:double=0;
var
  memo1_text : string;{for backup header}


function file_available(stack_directory:string; var filen: string ) : boolean; {check if fits file is available and report the filename}
var
   thefiles : Tstringlist;
   f : file;
begin
  try
  //No need to create the stringlist; the function does that for you
  theFiles := FindAllFiles(stack_directory, '*.fit;*.fits;*.FIT;*.FITS;'+
                                            '*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP;*.tif;*.tiff;*.TIF;'+
                                            '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef', false {search subdirectories}); //find images
  if TheFiles.count>0 then
  begin
    filen:=TheFiles[0];

    {check if free for reading}
    assign(f,filen);
    {$I-}
    reset(f); {prepare for reading}
    {$I+}
    result:=(IOresult=0); {report if file is accessible}
    if result then close(f);
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
  update_text ('DATE-OBS=',#39+JdToDate(jd_stop)+#39);{give end point exposures}
  update_float('JD-AVG  =',' / Julian Day of the observation mid-point.       ', jd_sum/counterL);{give midpoint of exposures}
  date_avg:=JdToDate(jd_sum/counterL); {update date_avg for asteroid annotation}
  update_text ('DATE-AVG=',#39+date_avg+#39);{give midpoint of exposures}
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
    result:=convert_load_raw(filen,img_loaded) {raw}
  else
    result:=load_tiffpngJPEG(filename2,img_loaded);
end;
function date_string: string;
Var YY,MO,DD : Word;
    HH,MM,SS,MS: Word;
begin
  DecodeDate(date,YY,MO,DD);
  DecodeTime(Time,HH,MM,SS,MS);
  result:=inttostr(YY)+
          inttostr(MO)+
          inttostr(DD)+'_'+
          inttostr(HH)+
          inttostr(MM)+
          inttostr(SS);
end;

procedure stack_live(oversize:integer; path :string);{stack live average}
var
    fitsX,fitsY,c,width_max, height_max,x, old_width, old_height,x_new,y_new,col,binning, counter,total_counter,bad_counter :  integer;
    flat_factor, distance,hfd_min      : double;
    init, solution, vector_based,waiting,transition_image,colour_correction :boolean;
    file_ext,filen                    :  string;
    multiply_red,multiply_green,multiply_blue,add_valueR,add_valueG,add_valueB,largest,scaleR,scaleG,scaleB,dum :single; {for colour correction}


    procedure reset_var;{reset variables  including init:=false}
    begin
      init:=false;
      counter:=0;
      bad_counter:=0;
      sum_exp:=0;
      jd_sum:=0;{sum of Julian midpoints}
      jd_stop:=0;{end observations in Julian day}

      dark_exposure:=987654321;{not done indication}
      dark_temperature:=987654321;
      flat_filter:='987654321';{not done indication}

    end;

begin

  with stackmenu1 do
  begin
    live_stacking:=true;{to block other instruction like solve button}
    reset_var; {reset variables  including init:=false}

    binning:=report_binning;{select binning}

    pause_pressed:=false;
    esc_pressed:=false;
    total_counter:=0;

    mainwindow.memo1.visible:=false;{Hide header}

    colour_correction:=((stackmenu1.make_osc_color1.checked) and (stackmenu1.osc_colour_smooth1.checked));
    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}


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
          if ((esc_pressed) or (load_thefile(filename2)=false)) then
          begin
            if esc_pressed=false then memo2_message('Error loading file'); {can't load}
            live_stacking_pause1.font.style:=[];
            live_stacking1.font.style:=[];
            live_stacking:=false;
            exit;
          end;

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
              if ((bayerpat='') and (make_osc_color1.checked)) then
                if stackmenu1.bayer_pattern1.Text='auto' then memo2_message('█ █ █ █ █ █ Warning, Bayer colour pattern not in the header! Check colours and if wrong set Bayer pattern manually in tab "stack alignment". █ █ █ █ █ █')
                else
                if test_bayer_matrix(img_loaded)=false then  memo2_message('█ █ █ █ █ █ Warning, monochrome image converted to colour! Un-check option "convert OSC to colour". █ █ █ █ █ █');
            end;

            apply_dark_flat(filter_name,{round(exposure),set_temperature,width2,}{var} dark_count,flat_count,flatdark_count);{apply dark, flat if required, renew if different exposure or ccd temp}
            {these global variables are passed-on in procedure to protect against overwriting}

            memo2_message('Adding file: '+inttostr(counter+1)+' "'+filename2+'"  to average. Using '+inttostr(dark_count)+' darks, '+inttostr(flat_count)+' flats, '+inttostr(flatdark_count)+' flat-darks') ;
//            Application.ProcessMessages;
//            if esc_pressed then exit;

            if make_osc_color1.checked then
               demosaic_bayer; {convert OSC image to colour}

            if init=true then   if ((old_width<>width2) or (old_height<>height2)) then memo2_message('█ █ █ █ █ █  Warning different size image!');

            if init=false then {first image}
            begin
              bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,true{update hist},starlist1);{bin, measure background, find stars}
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

              if colour_correction then
              begin
                memo2_message('Using first reference image to determine colour adjustment factors.');
                stackmenu1.auto_background_level1Click(nil);

                {do factor math behind so "subtract view from file" works in correct direction}
                add_valueR:=strtofloat2(stackmenu1.add_valueR1.Text);
                add_valueG:=strtofloat2(stackmenu1.add_valueG1.Text);
                add_valueB:=strtofloat2(stackmenu1.add_valueB1.Text);

                multiply_red:=strtofloat2(stackmenu1.multiply_red1.Text);
                multiply_green:=strtofloat2(stackmenu1.multiply_green1.Text);
                multiply_blue:=strtofloat2(stackmenu1.multiply_blue1.Text);

                {prevent clamping to 65535}
                scaleR:=(65535+add_valueR)*multiply_red/65535;{range 0..1, if above 1 then final value could be above 65535}
                scaleG:=(65535+add_valueG)*multiply_green/65535;
                scaleB:=(65535+add_valueB)*multiply_blue/65535;
                largest:=scaleR;
                if scaleG>largest then largest:=scaleG;
                if scaleB>largest then largest:=scaleB;
                {use largest to scale to maximum 65535}
              end;
            end;{init, c=0}

            solution:=true;

            {align using star match}
            if init=true then {second image}
            begin{internal alignment}
              bin_and_find_stars(img_loaded, binning,1  {cropping},hfd_min,true{update hist},starlist2);{bin, measure background, find stars}

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
              date_to_jd(date_obs);{convert date-obs to jd}
              if jd>jd_stop then jd_stop:=jd;
              jd_sum:=jd_sum+jd-exposure/(2*24*3600);{sum julian days of images at midpoint exposure. Add half exposure in days to get midpoint}

              vector_based:=true;

              if colour_correction=false then {no colour correction}
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
                      img_average[col,x_new,y_new]:=(img_average[col,x_new,y_new]*(counter-1)+ img_loaded[col,fitsX-1,fitsY-1])/counter;{image loaded is already corrected with dark and flat}{NOTE: fits count from 1, image from zero}
                    end;
                  end;
                end;
              end

              else {colour correction}
              begin
                for fitsY:=1 to height2 do {skip outside "bad" pixels if mosaic mode}
                for fitsX:=1 to width2  do
                begin
                  calc_newx_newy(vector_based,fitsX,fitsY);{apply correction}
                  x_new_float:=x_new_float+oversize;y_new_float:=y_new_float+oversize;
                  x_new:=round(x_new_float);y_new:=round(y_new_float);
                  if ((x_new>=0) and (x_new<=width_max-1) and (y_new>=0) and (y_new<=height_max-1)) then
                  begin
                    dum:=img_loaded[0,fitsX-1,fitsY-1];
                      if dum<>0 then {signal}
                      begin
                      dum:=(dum+add_valueR)*multiply_red/largest;
                        if dum<0 then dum:=0;
                       img_average[0,x_new,y_new]:=(img_average[0,x_new,y_new]*(counter-1)+ dum)/counter;
                      end;
                    if naxis3>1 then {colour}
                    begin
                      dum:=img_loaded[1,fitsX-1,fitsY-1];   if dum<>0 then {signal} begin dum:=(dum+add_valueG)*multiply_green/largest; if dum<0 then dum:=0; img_average[1,x_new,y_new]:=(img_average[1,x_new,y_new]*(counter-1)+ dum)/counter;end;
                    end;
                    if naxis3>2 then {colour}
                    begin
                      dum:=img_loaded[2,fitsX-1,fitsY-1]; if dum<>0 then {signal} begin dum:=(dum+add_valueB)*multiply_blue/largest; if dum<0 then dum:=0; img_average[2,x_new,y_new]:=(img_average[2,x_new,y_new]*(counter-1)+ dum)/counter;end;
                    end;
                  end;
                end;
              end;


              CD1_1:=0;{kill any existing north arrow during plotting. Most likely wrong after stacking}
              height2:=height_max;
              width2:=width_max;
              img_loaded:=img_average;{copy the pointer. Both have now access to the data!!}

              if counter=1 then {set range correct}
                   getfits_histogram(img_loaded,0);{get histogram R,G,B YES, plot histogram YES, set min & max YES}

              plot_fits(mainwindow.image1,false,false{do not show header in memo1});{plot real}

            end
            else
            inc(bad_counter);

            stackmenu1.files_live_stacked1.caption:=inttostr(counter)+' stacked, '+inttostr(bad_counter)+ ' failures ' ;{Show progress}
            application.hint:=inttostr(counter)+' stacked, '+inttostr(bad_counter)+ ' failures ' ;{Show progress}
          end; {no transition image}
          file_ext:=ExtractFileExt(filename2);
          if pos('_@',filename2)=0 then filen:=copy(filename2,1,length(filename2)-length(file_ext))+'_@'+ date_string {function} +file_ext+'_' {mark file with date for SGP since the file name will not change if first file is renamed}
                                   else filen:=copy(filename2,1,length(filename2)-length(file_ext))+file_ext+'_'; {already marked with date}
          if RenameFile(filename2,filen)=false then {mark files as done with file extension+'_', beep if failure}
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

    live_stacking:=false;
    live_stacking_pause1.font.style:=[];
    live_stacking1.font.style:=[];
    memo2_message('Live stack stopped. Save result if required');

    counterL:=counter;
    if counter>0 then update_header;

    memo1_text:='';{release memory}
  end;{with stackmenu1}
end;


end.

