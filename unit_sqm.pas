unit unit_sqm;
{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. }


{$mode delphi}

interface

uses
   Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
   LCLIntf, Buttons,{for for getkeystate, selectobject, openURL}
   astap_main, unit_annotation,unit_hjd,unit_stack;

type

  { Tform_sqm1 }

  Tform_sqm1 = class(TForm)
    green_message1: TLabel;
    sqm_applydf1: TCheckBox;
    error_message1: TLabel;
    sqm1: TEdit;
    date_label1: TLabel;
    date_obs1: TEdit;
    help_sqm_measurement1: TLabel;
    altitude_label1: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    pedestal1: TEdit;
    background1: TEdit;
    altitude1: TEdit;
    sqm_label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    label_start_mid1: TLabel;
    latitude1: TEdit;
    longitude1: TEdit;
    ok1: TButton;
    procedure date_obs1Exit(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure help_sqm_measurement1Click(Sender: TObject);
    procedure latitude1Change(Sender: TObject);
    procedure latitude1Exit(Sender: TObject);
    procedure longitude1Change(Sender: TObject);
    procedure longitude1Exit(Sender: TObject);
    procedure ok1Click(Sender: TObject);
    procedure pedestal1Exit(Sender: TObject);
    procedure sqm_applydf1Change(Sender: TObject);
  private

  public

  end;

var
  form_sqm1: Tform_sqm1;

  sqm_applyDF: boolean;

function calculate_sqm(get_bk,get_his : boolean) : boolean; {calculate sqky background value}


implementation


{$R *.lfm}

var
  site_lat_radians,site_long_radians  : double;



function calculate_sqm(get_bk,get_his : boolean) : boolean; {calculate sky background value}
var
  airm, correction,alt : double;
   bayer  : boolean;
begin
//  if ((bayerpat<>'') or (head.naxis3>1)) then {can not process colour or OSC images}
//  begin
//    result:=false;
//    exit;
//  end;
  bayer:=((bayerpat<>'') and (Xbinning=1));
  if bayer then
  begin
    form_sqm1.green_message1.caption:='This OSC image is automatically binned 2x2.'+#10;
    application.processmessages;
    backup_img; {move viewer data to img_backup}
    bin_X2X3X4(2);
  end
  else
  form_sqm1.green_message1.caption:='';

  if ((flux_magn_offset=0) or (flux_aperture<>99){calibration was for point sources})  then {calibrate and ready for extendend sources}
  begin
    annulus_radius:=14;{calibrate for extended objects using full star flux}
    flux_aperture:=99;{calibrate for extended objects}
    plot_and_measure_stars(true {calibration},false {plot stars},false{report lim magnitude});
  end;
  result:=false;
  if flux_magn_offset>0 then
  begin
    if get_bk then get_background(0,img_loaded,get_his {histogram},false {calculate also noise level} ,{var}cblack,star_level);

    if (pos('D',head.calstat)>0) then
    begin
      if pedestal>0 then
      begin
        form_sqm1.green_message1.caption:=form_sqm1.error_message1.caption+'Dark already applied! Pedestal should be zero.'+#10;
        pedestal:=0; {prevent wrong values}
      end;
    end
    else
    if pedestal=0 then
      form_sqm1.error_message1.caption:=form_sqm1.error_message1.caption+'Pedestal value missing!'+#10;

    if pedestal>=cblack then
    begin
      form_sqm1.error_message1.caption:=form_sqm1.error_message1.caption+'Too high pedestal value!'+#10;
      beep;
      pedestal:=0; {prevent errors}
    end;

    sqmfloat:=flux_magn_offset-ln((cblack-pedestal)/sqr(head.cdelt2*3600){flux per arc sec})*2.511886432/ln(10);
    alt:=calculate_altitude(1 {astrometric_to_apparent_or_reverse},{var} head.ra0,head.dec0);{convert centalt string to double or calculate altitude from observer location}

    centalt:=inttostr(round(alt));{for reporting in menu sqm1}
    if alt<>0 then
    begin
      airm:=airmass_calc(alt);
      correction:= atmospheric_absorption(airm)- 0.28 {absorption at zenith};
      sqmfloat:=sqmfloat+correction;
      result:=true;
    end;
  end;

  if bayer then
  begin
    restore_img;
  end;
end;


procedure display_sqm;
var
  update_hist : boolean;
begin
  with form_sqm1 do
  begin
    update_hist:=false;
    error_message1.caption:='';

    date_to_jd(head.date_obs,head.exposure);{convert date-OBS to jd_start and jd_mid}

    if jd_start<=2400000 then {no date, found year <1858}
    begin
      error_message1.caption:='Error converting date obs.'+#10;
      sqm1.caption:='?';
      exit;
    end;

    if head.naxis3>1 then {no date, found year <1858}
    begin
      error_message1.caption:=error_message1.caption+'Can not process colour images!!'+#10;
      sqm1.caption:='?';
      exit;
    end;

    if sqm_applydf1.checked then
    begin
      analyse_listview(stackmenu1.listview2,false {light},false {full fits},false{refresh});{analyse dark tab, by loading=false the loaded img will not be effected. Calstat will not be effected}
      analyse_listview(stackmenu1.listview3,false {light},false {full fits},false{refresh});{analyse flat tab, by loading=false the loaded img will not be effected}
      apply_dark_and_flat(img_loaded);{apply dark, flat if required, renew if different head.exposure or ccd temp}

      if pos('D',head.calstat)>0  then {status of dark application}
      begin
        memo2_message('Calibration status '+head.calstat+'. Used '+inttostr(head.dark_count)+' darks, '+inttostr(head.flat_count)+' flats, '+inttostr(head.flatdark_count)+' flat-darks') ;

        update_text('CALSTAT =',#39+head.calstat+#39);
        pedestal:=0;{pedestal no longer required}
        update_hist:=true; {dark is applied, update histogram for background measurement}
      end
      else
      error_message1.caption:=error_message1.caption+'No darks found. Result invalid!'+#10; {error}
    end;

    {calc}
    if calculate_sqm(true {get backgr},update_hist{get histogr})=false then {failure in calculating sqm value}
    begin
      if centalt='0' then error_message1.caption:=error_message1.caption+'Could not retrieve or calculate altitude. Enter the default geographic location'+#10;
      sqm1.caption:='?';
      exit;
    end;

    {report}
    pedestal1.caption:=inttostr(pedestal);
    background1.caption:=inttostr(round(cblack));
    altitude1.caption:=centalt;
    sqm1.caption:=floattostrF(sqmfloat,ffFixed,0,2)
  end;
end;


procedure Tform_sqm1.help_sqm_measurement1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#sqm');
end;


procedure Tform_sqm1.latitude1Change(Sender: TObject);{han.k}
var
  errordecode:boolean;
begin
  sitelat:=latitude1.Text;
  dec_text_to_radians(sitelat,site_lat_radians,errordecode);
  if errordecode then latitude1.color:=clred else latitude1.color:=clwindow;
end;

procedure Tform_sqm1.latitude1Exit(Sender: TObject);
begin
  display_sqm;
end;


procedure Tform_sqm1.longitude1Change(Sender: TObject);{han.k}
var
  errordecode:boolean;
begin
  sitelong:=longitude1.Text;
  dec_text_to_radians(sitelong,site_long_radians,errordecode);
  if errordecode then longitude1.color:=clred else longitude1.color:=clwindow;

end;

procedure Tform_sqm1.longitude1Exit(Sender: TObject);
begin
  display_sqm;
end;

procedure Tform_sqm1.ok1Click(Sender: TObject);
begin
  form_sqm1.close;   {normally this form is not loaded}
  mainwindow.setfocus;

  mainwindow.save_settings1Click(nil);{save pedestal value}
end;

procedure Tform_sqm1.pedestal1Exit(Sender: TObject);
begin
  pedestal:=round(strtofloat2(pedestal1.Text));
  display_sqm;
end;

procedure Tform_sqm1.sqm_applydf1Change(Sender: TObject);
begin
  pedestal1.enabled:=sqm_applydf1.checked=false;
  display_sqm;
end;


procedure set_some_defaults; {wil be set if annotate button is clicked or when form is closed}
begin
  with form_sqm1 do
  begin
    {latitude, longitude}
    sitelat:=latitude1.Text;
    sitelong:=longitude1.Text;

    lat_default:=sitelat;
    long_default:=sitelong;

    head.date_obs:=date_obs1.Text;
    sqm_applyDF:=sqm_applyDF1.checked;
  end;
end;


procedure Tform_sqm1.FormKeyPress(Sender: TObject; var Key: char);{han.k}
begin {set form keypreview:=on}
  if key=#27 then
  begin
    form_sqm1.ok1Click(nil);
  end;
end;

procedure Tform_sqm1.date_obs1Exit(Sender: TObject);
begin
  head.date_obs:=date_obs1.text;
   display_sqm;
end;



procedure Tform_sqm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  set_some_defaults;
end;


procedure Tform_sqm1.FormShow(Sender: TObject);{han.k}
begin
  esc_pressed:=false;{reset from cancel}

  sqm_applyDF1.checked:=sqm_applyDF;
  date_obs1.Text:=head.date_obs;

  {latitude, longitude}
  if sitelat='' then {use values from previous time}
  begin
    sitelat:=lat_default;
    sitelong:=long_default;
  end;

  latitude1.Text:=trim(sitelat); {copy the string to tedit}
  longitude1.Text:=trim(sitelong);

  display_sqm;
end;




end.

