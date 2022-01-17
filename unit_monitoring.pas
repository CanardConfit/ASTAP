unit unit_monitoring;
{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

{$mode delphi}

interface

uses
  Classes, SysUtils,forms,fileutil,
  graphics;


procedure monitoring(path :string);{stack live average}
procedure report_delta; {report delta error}

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

procedure report_delta; {report delta error}
var
   distance,deltaRA,deltaDEC : double;
   direction : string;
begin
  if fits_file=false then exit;
  with stackmenu1 do
  begin
    raposition1.visible:=true;
    decposition1.visible:=true;
    raposition1.caption:='  '+prepare_ra(head.ra0,': ');{show center of image}
    decposition1.caption:=prepare_dec(head.dec0,'° ');

    if copy(target1.caption,1,1)<>'-' then {target option and object is set}
    begin
      target_distance1.visible:=true;
      delta_ra1.visible:=true;
      delta_dec1.visible:=true;
      ang_sep(head.ra0,head.dec0,ra_target,dec_target ,distance);{calculate distance in radians}
      target_distance1.caption :='Distance: '+floattostrF(distance*180/pi,ffFixed,0,3)+'°';

      deltaRA:=fnmodulo((ra_target-head.ra0)*12/pi,24);
      if deltaRA>12 then begin direction:='W'; deltaRa:=24-deltaRA;end else begin direction:='E'; end;
      delta_ra1.caption :='Δα   '+floattostrF(deltaRA,ffFixed,0,3)+'h '+direction;

      deltaDec:=(dec_target-head.dec0)*180/pi;
      if deltaDec>0 then begin direction:='N' end else begin direction:='S'; end;
      delta_dec1.caption:='Δδ   '+floattostrF(deltaDec,ffFixed,0,3)+'° '+direction;
    end;
  end;

end;

procedure monitoring(path :string);{monitoring a directory}
var
     counter :  integer;
     solver  :   boolean;
begin
  with stackmenu1 do
  begin

    esc_pressed:=false;
    latest_time:=0;{for finding files}

    if monitor_applydarkflat1.checked then   {Prepare for dark and flats}
    begin
      analyse_listview(stackmenu1.listview2,false {light},false {full fits},false{refresh});{analyse dark tab, by loading=false the loaded img will not be effected. Calstat will not be effected}
      analyse_listview(stackmenu1.listview3,false {light},false {full fits},false{refresh});{analyse flat tab, by loading=false the loaded img will not be effected}
    end;

    {live stacking}
    repeat
    begin
      if file_available(path,filename2 {file found}) then
      begin
        try { Do some lengthy operation }
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

          if monitor_applydarkflat1.checked then
          begin
            apply_dark_and_flat(img_loaded);{apply dark, flat if required, renew if different head.exposure or ccd temp}
            {these global variables are passed-on in procedure to protect against overwriting}
            update_text('CALSTAT =',#39+head.calstat+#39);
            if ((pos('D',head.calstat)>0) or (pos('F',head.calstat)>0))  then {status of dark application}
              memo2_message('Calibration status '+head.calstat+'. Used '+inttostr(head.dark_count)+' darks, '+inttostr(head.flat_count)+' flats, '+inttostr(head.flatdark_count)+' flat-darks') ;
          end;


          Application.ProcessMessages;
          if esc_pressed then exit;

          if make_osc_color1.checked then
             demosaic_bayer(img_loaded); {convert OSC image to colour}

          use_histogram(img_loaded,true {update}); {plot histogram, set sliders}

          plot_fits(mainwindow.image1,false,true{do not show header in memo1});{plot real}

          monitor_date1.caption:= DateTimeToStr(FileDateToDateTime(latest_time));

          solver:=false;
          case stackmenu1.monitor_action1.itemindex of 1: CCDinspector(30,false,strtofloat(measuring_angle));
                                                       2: CCDinspector(30,true,strtofloat(measuring_angle));
                                                       3: form_inspection1.aberration_inspector1Click(nil);
                                                       4: solver:=true;
          end;{case}
          if solver then
          begin
            mainwindow.astrometric_solve_image1Click(nil);
            report_delta;
          end
          else
          begin
            target_distance1.visible:=false;
            raposition1.visible:=false;
            decposition1.visible:=false;
            delta_ra1.visible:=false;
            delta_dec1.visible:=false;
          end;


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

