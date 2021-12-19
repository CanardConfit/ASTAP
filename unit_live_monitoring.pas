unit unit_live_monitoring;
{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License (LGPL) as published
by the Free Software Foundation, either version 3 of the License, or(at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License (LGPL) along with this program. If not, see <http://www.gnu.org/licenses/>.}

{$mode delphi}

interface

uses
  Classes, SysUtils,forms,fileutil,
  graphics,
  math;

procedure monitoring(path :string);{stack live average}

const
  live_monitoring: boolean=false; {used to inhibit solving while live_stacking}

implementation

uses unit_stack, astap_main,unit_stack_routines,unit_astrometric_solving,unit_star_align,unit_inspector_plot;

var
  latest_time : integer=0;



function file_available(monitor_directory:string; out filen: string ) : boolean; {check if fits file is available and report the filename}
Var Info : TSearchRec;
    Count : Longint;
    i     : integer;
    f     : file;
    ex    : string;

const
  extensions : array[0..44] of string=
                (('.fit'),('.fits'),('*.FIT'),('.FITS'),('.RAW'),('.raw'),('.CRW'),('.crw'),('.CR2'),('.cr2'),('.CR3'),('.cr3'),('.KDC'),('.kdc'),('.DCR'),
                 ('.dcr'),('.MRW'),('.mrw'),('.ARW'),('.arw'),('.NEF'),('.nef'),('.NRW'),('.nrw'),('.DNG'),('.dng'),('.ORF'),('.orf'),('.PTX'),('.ptx'),('.PEF'),
                 ('.pef'),('.RW2'),('.rw2'),('.SRW'),('.srw'),('.RAF'),('.raf'),
                 ('*.png'),('.PNG'),('.jpg'),('(.JPG'),('.tif'),('.tiff'),('.TIF'));


Begin
  result:=false;
  Count:=0;
  If FindFirst (monitor_directory+ {$ifdef mswindows}'\' {$else} {unix} '/' {$endif}+'*', faAnyFile-faDirectory,Info)=0 then
  begin
    Repeat
      Inc(Count);
      With Info do
      begin
      //  SR.FindData.ftLastWriteTime
        if time>latest_time then
        begin
          ex:=extractfileext(name);
          i:=-1;
          repeat
            inc(i);
          until ((i>44) or (ex=extensions[i]));
          if i>44 then continue;{no know image extension, continue with repeat}

          result:=true;
          filen:=name;
          latest_time:=time;
        end;
      end;
    Until FindNext(info)<>0;
    FindClose(Info);
  end;


  if result then
  begin
    filen:= monitor_directory+ {$ifdef mswindows}'\' {$else} {unix} '/' {$endif}+filen;
    {check if free for reading}
    assign(f,filen);
    {$I-}
    reset(f); {prepare for reading}
    {$I+}
    result:=(IOresult=0); {report if file is accessible}
    if result then
      close(f);
  end;
End;


procedure monitoring(path :string);{monitoring a directory}
var
     counter:  integer;
//    init, solution, vector_based,waiting,transition_image,colour_correction :boolean;
//    file_ext,filen                    :  string;
//    multiply_red,multiply_green,multiply_blue,add_valueR,add_valueG,add_valueB,largest,scaleR,scaleG,scaleB,dum :single; {for colour correction}
//    warning  : string;
begin

  with stackmenu1 do
  begin

    esc_pressed:=false;
//    total_counter:=0;
    latest_time:=0;{for finding files}

    {Prepare for dark and flats}
    analyse_listview(stackmenu1.listview2,false {light},false {full fits},false{refresh});{analyse dark tab, by loading=false the loaded img will not be effected. Calstat will not be effected}
    analyse_listview(stackmenu1.listview3,false {light},false {full fits},false{refresh});{analyse flat tab, by loading=false the loaded img will not be effected}


    {live stacking}
    repeat
    begin
      if file_available(path,filename2 {file found}) then
      begin
        try { Do some lengthy operation }
//          waiting:=false;

          Application.ProcessMessages;
          {load image}


          if ((esc_pressed) or (load_image(false,false {plot})=false)) then
          begin
            if esc_pressed=false then memo2_message('Error loading file'); {can't load}
            live_monitoring1.font.style:=[];
            live_monitoring:=false;
            exit;
          end;
          memo2_message('Loading file: '+filename2) ;

          apply_dark_and_flat(filter_name,{round(exposure),set_temperature,width2,}{var} dark_count,flat_count,flatdark_count,img_loaded);{apply dark, flat if required, renew if different exposure or ccd temp}
          {these global variables are passed-on in procedure to protect against overwriting}


          Application.ProcessMessages;
          if esc_pressed then exit;

          if make_osc_color1.checked then
             demosaic_bayer(img_loaded); {convert OSC image to colour}

          use_histogram(img_loaded,true {update}); {plot histogram, set sliders}

          plot_fits(mainwindow.image1,false,true{do not show header in memo1});{plot real}

          monitor_date1.caption:= DateTimeToStr(FileDateToDateTime(latest_time));

          case stackmenu1.monitor_action1.itemindex of 1: CCDinspector(30,false,strtofloat(measuring_angle));
                                                       2: CCDinspector(30,true,strtofloat(measuring_angle));
                                                       3: form_inspection1.aberration_inspector1Click(nil);
          end;{case}


        finally
        end;
      end
      else
      wait(1000);{wait 1 second unless something happens}

    end;{live average}

    until esc_pressed;

    live_monitoring:=false;
    live_monitoring1.font.style:=[];
    memo2_message('Live stack stopped. Save result if required');

    counterL:=counter;
  end;{with stackmenu1}
end;


end.

