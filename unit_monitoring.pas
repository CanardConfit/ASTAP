unit unit_monitoring;
{Copyright (C) 2017, 2024 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

{$mode delphi}

interface

uses
  Classes, SysUtils,forms,fileutil,
  graphics, LCLIntf,math;


procedure monitoring(path :string);{stack live average}
procedure report_delta; {report delta error}

var
  live_monitoring: boolean=false; {used to inhibit solving while live_stacking}

implementation

uses unit_stack, astap_main,unit_stack_routines,unit_astrometric_solving,unit_star_align,unit_inspector_plot, unit_hjd;

var
  latest_time : integer=0;

function file_available(monitor_directory:string; out filen: string ) : boolean; {check if fits file is available and report the filename}
Var
  Info : TSearchRec;
  Count : Longint;
  i     : integer;
  f     : file;
Begin
  result:=false;
  Count:=0;
  If SysUtils.FindFirst (monitor_directory+ {$ifdef mswindows}'\' {$else} {unix} '/' {$endif}+'*', faAnyFile-faDirectory,Info)=0 then
  begin
    Repeat
      Inc(Count);
      With Info do
      begin
      //  SR.FindData.ftLastWriteTime
        if ((time>latest_time) and (image_file_name(name){readable image name?} )) then
        begin
          result:=true;
          filen:=name;
          latest_time:=time;
        end;
      end;
    Until SysUtils.FindNext(info)<>0;
    SysUtils.FindClose(Info);
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
end;


procedure report_delta; {report delta error}
var
  distance,deltaRA,deltaDEC,az_solution,alt_solution,az_target,alt_target,jd_now,lat,long,angle,angle1,angle2,angle_mid,fov : double;
  wdiv2,hdiv2,x,y,rx,ry : integer;
  direction : string;
begin
  if ((head.naxis=0) or (head.cd1_1=0)) then exit;
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
      label_latitude1.Visible:=true;
      label_longitude1.Visible:=true;
      monitor_latitude1.visible:=true;
      monitor_longitude1.visible:=true;

      ang_sep(head.ra0,head.dec0,ra_target,dec_target ,distance);{calculate distance in radians}
      target_distance1.caption :='Distance: '+floattostrF(distance*180/pi,ffFixed,0,3)+'°';

      deltaRA:=fnmodulo((ra_target-head.ra0)*12/pi,24);
      if deltaRA>12 then begin direction:='W'; deltaRa:=24-deltaRA;end else begin direction:='E'; end;
      delta_ra1.caption :='Δα:  '+floattostrF(deltaRA,ffFixed,0,3)+'h '+direction;

      deltaDec:=(dec_target-head.dec0)*180/pi;
      if deltaDec>0 then begin direction:='N' end else begin direction:='S'; end;
      delta_dec1.caption:='Δδ:  '+floattostrF(abs(deltaDec),ffFixed,0,3)+'° '+direction;


      jd_now:=calc_jd_now;
      lat:=strtofloat2(lat_default)*pi/180;
      long:=strtofloat2(long_default)*pi/180;
      altitude_and_refraction(lat,long,jd_now,10 {temp},1010 {pressure},head.ra0,head.dec0,az_solution,alt_solution);{In formulas the longitude is positive to west!!!. }
      altitude_and_refraction(lat,long,jd_now,10 {temp},1010 {pressure},ra_target,dec_target,az_target,alt_target);{In formulas the longitude is positive to west!!!. }

      target_altitude1.visible:=true;
      target_azimuth1.visible:=true;
      target_altitude1.caption:='A:  '+floattostrF(alt_target,ffFixed,0,1)+'°';
      target_azimuth1.caption:='H:  '+floattostrF(az_target,ffFixed,0,1)+'°';


      {draw arrow}
      with stackmenu1.direction_arrow1 do
      begin
        canvas.brush.color:=clmenu;
        Canvas.FillRect(rect(0,0,width,height));
        mainform1.image1.Canvas.Pen.mode:=pmXor;
        Canvas.Pen.Color := clred;
        canvas.pen.Width:=5;
        Canvas.brush.Style:=bsClear;
        wdiv2:=width div 2;
        hdiv2:=height div 2;

        if ((lat=0) and (long=0)) then
        begin
          canvas.font.size:=14;
          canvas.textout(10,hdiv2+30,'Set latitude and longitude!!');
        end;

        //show where the image sensor is
        Canvas.brush.Style:=bsDiagCross;
        canvas.brush.color:=clred;
        fov:=head.height*head.cdelt2;
        rx:=round(wdiv2+wdiv2*(az_target-az_solution)/fov);
        ry:=round(hdiv2-hdiv2*(alt_target-alt_solution)/fov);
        rectangle(canvas.handle,rx-wdiv2+10,ry-hdiv2+10,rx+wdiv2-10,ry+hdiv2-10);


        //arrow
        Canvas.brush.Style:=bsclear;
        fov:=head.height*head.cdelt2;
        rx:=round(wdiv2+wdiv2*(az_target-az_solution)/fov);
        ry:=round(hdiv2-hdiv2*(alt_target-alt_solution)/fov);
        rectangle(canvas.handle,rx-wdiv2+10,ry-hdiv2+10,rx+wdiv2-10,ry+hdiv2-10);

        ellipse(canvas.handle,wdiv2-8,hdiv2-8,wdiv2+8+1,hdiv2+8+1);
        moveToex(Canvas.handle,wdiv2,hdiv2,nil);

        angle:=arctan2(alt_target-alt_solution, az_target-az_solution);//calculate direction to target
        x:=round(0.95*wdiv2*cos(angle));
        y:=round(0.95*wdiv2*sin(angle));
        lineTo(Canvas.handle,hdiv2+x,wdiv2-y); // arrow line. Note y counts from top to bottom, so minus sign

        angle1:=angle+(180+20)*pi/180;
        angle_mid:=angle+90*pi/180;
        angle2:=angle-20*pi/180;

        x:=x+round(30*cos(angle1));
        y:=y+round(30*sin(angle1));
        lineTo(Canvas.handle,hdiv2+x,wdiv2-y); // arrowhead. Note y counts from top to bottom, so minus sign.
        x:=x+round(21*cos(angle_mid));
        y:=y+round(21*sin(angle_mid));
        lineTo(Canvas.handle,hdiv2+x,wdiv2-y); // arrowhead. Note y counts from top to bottom, so minus sign
        x:=x+round(30*cos(angle2));
        y:=y+round(30*sin(angle2));
        lineTo(Canvas.handle,hdiv2+x,wdiv2-y); // arrowhead. Note y counts from top to bottom, so minus sign

      end;
    end;//target specified
  end;
end;


procedure monitoring(path :string);{monitoring a directory}
var
  counter       : integer;
  count         : integer=0;
  solver        :  boolean;
begin
  with stackmenu1 do
  begin

    esc_pressed:=false;

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
          if ((esc_pressed) or (load_image(filename2,img_loaded,head,mainform1.memo1.lines,false,false {plot})=false)) then
          begin

            if esc_pressed=false then
            begin
              memo2_message('Error loading file'); {can't load}
              continue; {repeat loop}
            end;
            live_monitoring1.font.style:=[];
            live_monitoring:=false;
            exit;
          end;
          memo2_message('Loading file: '+filename2) ;

          if monitor_applydarkflat1.checked then
          begin
            apply_dark_and_flat(img_loaded,head);{apply dark, flat if required, renew if different head.exposure or ccd temp}
            {these global variables are passed-on in procedure to protect against overwriting}
            update_text(mainform1.memo1.lines,'CALSTAT =',#39+head.calstat+#39);
            if ((pos('D',head.calstat)>0) or (pos('F',head.calstat)>0))  then {status of dark application}
              memo2_message('Calibration status '+head.calstat+'. Used '+inttostr(head.dark_count)+' darks, '+inttostr(head.flat_count)+' flats, '+inttostr(head.flatdark_count)+' flat-darks') ;
          end;


          Application.ProcessMessages;
          if esc_pressed then exit;

          if ((head.naxis3=1) and (mainform1.preview_demosaic1.checked)) then
             demosaic_advanced(img_loaded) {demosaic and set levels}
          else
            plot_histogram(img_loaded,true {update}); {plot histogram, set sliders}

          plot_fits(mainform1.image1,false);{plot real}

          monitor_date1.caption:= DateTimeToStr(FileDateToDateTime(latest_time));

          solver:=false;
          case stackmenu1.monitor_action1.itemindex of 1: CCDinspector(img_loaded, head,mainform1.memo1.lines,30,true {screenplot},false,strtofloat(measuring_angle));
                                                       2: CCDinspector(img_loaded, head,mainform1.memo1.lines,30,true {screenplot},true,strtofloat(measuring_angle));
                                                       3: form_inspection1.aberration_inspector1Click(nil);
                                                       4: solver:=true;
                                                       5: form_inspection1.background_contour1Click(nil);
          end;{case}
          if solver then
          begin
            mainform1.astrometric_solve_image1Click(nil);
            report_delta;
          end
          else
          begin
            target_distance1.visible:=false;
            raposition1.visible:=false;
            decposition1.visible:=false;
            delta_ra1.visible:=false;
            delta_dec1.visible:=false;
            label_latitude1.Visible:=false;
            label_longitude1.Visible:=false;
            monitor_latitude1.visible:=false;
            monitor_longitude1.visible:=false;
          end;


        finally
        end;
      end
      else
      begin
        wait(1000);{wait 1 second unless something happens}
        if count=0 then live_monitoring1.caption:='  ▶'
        else
        if count=1 then live_monitoring1.caption:='▶  '
        else
        if count=2 then live_monitoring1.caption:=' ▶ ';

        inc(count);
        if count>2 then count:=0;

      end;

    end;{live average}

    until esc_pressed;

    live_monitoring:=false;
    live_monitoring1.font.style:=[];
    memo2_message('Monitoring stopped.');

    counterL:=counter;
  end;{with stackmenu1}
end;


end.

