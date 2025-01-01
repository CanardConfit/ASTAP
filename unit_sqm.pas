unit unit_sqm;
{Copyright (C) 2017, 2024 by Han Kleijn, www.hnsky.org
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
    bortle1: TLabel;
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
    procedure sqm_applydf1Click(Sender: TObject);
  private

  public

  end;

var
  form_sqm1: Tform_sqm1;

  sqm_applyDF: boolean;

function calculate_sqm(img: image_array; headx : theader; get_bk,get_his : boolean; var pedestal2 : integer) : boolean; {calculate sky background value}


implementation


{$R *.lfm}

var
  site_lat_radians,site_long_radians  : double;
  backup_made                         : boolean;


function calculate_sqm(img: image_array; headx : theader; get_bk,get_his : boolean; var pedestal2 : integer) : boolean; {calculate sky background value}
var
  correction,az,airm         : double;
  bayer,form_exist           : boolean;
begin
  form_exist:=form_sqm1<>nil;   {see form_sqm1.FormClose action to make this working reliable}

  bayer:=((bayerpat<>'') and (headx.Xbinning=1));

  if form_exist then
  begin
    if bayer then
    begin
      form_sqm1.green_message1.caption:='This OSC image is automatically binned 2x2.'+#10;
      application.processmessages;
      if backup_made=false then //else the backup is already made in applyDF1
      begin
        backup_img; {move viewer data to img_backup}
        backup_made:=true;
      end;
      bin_X2X3X4(img,headx,mainwindow.memo1.lines,2); //bin 2x2
    end
    else
      form_sqm1.green_message1.caption:='';
  end;

  if ((headx.mzero=0) or (headx.mzero_radius<>99){calibration was for point sources})  then {calibrate and ready for extendend sources}
  begin
    annulus_radius:=14;{calibrate for extended objects using full star flux}
    headx.mzero_radius:=99;{calibrate for extended objects}
    plot_and_measure_stars(img,mainwindow.Memo1.lines,headx,true {calibration},false {plot stars},false{report lim magnitude});
  end;
  result:=false;
  if headx.mzero>0 then
  begin
    if get_bk then get_background(0,img,headX, get_his {histogram},false {calculate also noise level});

    if (pos('D',headx.calstat)>0) then
    begin
      if pedestal2>0 then
      begin
        if form_exist then form_sqm1.green_message1.caption:=form_sqm1.error_message1.caption+'Dark already applied! Pedestal value ignored.'+#10 else memo2_message('Dark already applied! Pedestal value ignored.');
        pedestal2:=0; {prevent wrong values}
      end;
    end
    else
    if pedestal2=0 then
       if form_exist then form_sqm1.error_message1.caption:=form_sqm1.error_message1.caption+'Pedestal value missing!'+#10
       else
       begin
         memo2_message('Pedestal value missing!');
         warning_str:=warning_str+'Pedestal value missing!';
       end;

    if pedestal2>=headX.backgr then
    begin
      if form_exist then form_sqm1.error_message1.caption:=form_sqm1.error_message1.caption+'Too high pedestal value!'+#10 else
      begin
        memo2_message('Too high pedestal value!');
        warning_str:=warning_str+'Too high pedestal value!';
      end;
      beep;
      pedestal2:=0; {prevent errors}
    end;

    headX.sqmfloat:=headx.mzero - ln((headX.backgr-pedestal2-headx.pedestal)/sqr(headx.cdelt2*3600){flux per arc sec})*2.5/ln(10) ;// +headx.pedestal was the value added calibration calibration

    calculate_az_alt(1 {force calculation from ra, dec} ,head,{out}az,altitudefloat);

    if altitudefloat>0 then
    begin
      airm:=airmass_calc(altitudefloat);
      correction:= atmospheric_absorption(airm)- 0.28 {correction at zenith is defined as zero by subtracting 0.28};
      headX.sqmfloat:=headX.sqmfloat+correction;
      result:=true;
    end
    else
    begin
      memo2_message('Negative altitude calculated!');
      warning_str:=warning_str+'Negative altitude calculated!';
    end;

  end
  else
  begin
    memo2_message('MZERO calibration failure!');
    warning_str:=warning_str+'MZERO calibration failure!';
  end;
  if backup_made then
  begin
    restore_img;
    head.sqmfloat:=headX.sqmfloat;
    head.backgr:=headX.backgr;
    backup_made:=false;
  end;
end;


function bortle(sqm: double): string;
begin
  //https://en.wikipedia.org/wiki/Bortle_scale
  //https://www.cleardarksky.com/lp/ChrSprPkPAlp.html
  if sqm>21.99 then result:='Bortle 1, excellent dark-sky site'
  else
  if sqm>21.89 then result:='Bortle 2, truly dark site'
  else
  if sqm>21.69 then result:='Bortle 3, dark rural sky'
  else
  if sqm>21.25 then result:='Bortle 4, rural sky'
  else
  if sqm>20.49 then result:='Bortle 4.5, rural/suburban sky'
  else
  if sqm>19.50 then result:='Bortle 5, suburban sky'
  else
  if sqm>18.94 then result:='Bortle 6, bright suburban sky'
  else
  if sqm>18.38 then result:='Bortle=7, suburban/urban sky'
  else
  if sqm>17.80 then result:='Bortle 8, city sky'
  else
  result:='Bortle 9, inner-city sky';
end;

procedure display_sqm;
var
  update_hist : boolean;
  pedestal2   : integer;
begin
  with form_sqm1 do
  begin
    update_hist:=false;
    error_message1.caption:='';

    date_to_jd(head.date_obs,head.date_avg,head.exposure);{convert date-OBS to jd_start and jd_mid}

    if jd_start<=2400000 then {no date, found year <1858}
    begin
      error_message1.caption:='Error converting DATE-OBS.'+#10;
      sqm1.caption:='?';
      bortle1.caption:='';
      exit;
    end;

    if head.naxis3>1 then {no date, found year <1858}
    begin
      error_message1.caption:=error_message1.caption+'Can not process colour images!!'+#10;
      sqm1.caption:='?';
      bortle1.caption:='';
      exit;
    end;

    pedestal2:=pedestal;{protect pedestal setting}
    if sqm_applydf1.checked then
    begin
      analyse_listview(stackmenu1.listview2,false {light},false {full fits},false{refresh});{analyse dark tab, by loading=false the loaded img will not be effected. Calstat will not be effected}
      analyse_listview(stackmenu1.listview3,false {light},false {full fits},false{refresh});{analyse flat tab, by loading=false the loaded img will not be effected}

      if  form_sqm1<>nil then   {see form_sqm1.FormClose action to make this working reliable}
      begin
        backup_img;
        backup_made:=true;//required in calculateSQM for 2x2 bining OSC
      end;
      apply_dark_and_flat(img_loaded,head);{apply dark, flat if required, renew if different head.exposure or ccd temp}

      if pos('D',head.calstat)>0  then {status of dark application}
      begin
        memo2_message('Calibration status '+head.calstat+'. Used '+inttostr(head.dark_count)+' darks, '+inttostr(head.flat_count)+' flats, '+inttostr(head.flatdark_count)+' flat-darks') ;

        update_text(mainwindow.memo1.lines,'CALSTAT =',#39+head.calstat+#39);
        pedestal2:=0;{pedestal no longer required}
        update_hist:=true; {dark is applied, update histogram for background measurement}
      end
      else
      error_message1.caption:=error_message1.caption+'No darks found. Result invalid!'+#10; {error}
    end;

    {calc}
    if calculate_sqm(img_loaded,head,true {get backgr},update_hist{get histogr},{var} pedestal2)=false then {failure in calculating sqm value}
    begin
      if altitudefloat<1 then error_message1.caption:=warning_str;
      warning_str:=''; //clear error message

      //error_message1.caption+'Could not retrieve or calculate altitude. Enter the default geographic location'+#10;
      sqm1.caption:='?';
      bortle1.caption:='';
      exit;
    end;

    {report}
    background1.caption:=inttostr(round(head.backgr));
    altitude1.caption:=inttostr(round(altitudefloat));
    sqm1.caption:=floattostrF(head.sqmfloat,ffFixed,0,2);
    bortle1.caption:=bortle(head.sqmfloat);
  end;
end;


procedure Tform_sqm1.help_sqm_measurement1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#sqm');
end;


procedure Tform_sqm1.latitude1Change(Sender: TObject);{han.k}
begin
end;

procedure Tform_sqm1.latitude1Exit(Sender: TObject);
var
  errordecode:boolean;
begin
  sitelat:=latitude1.Text;
  dec_text_to_radians(sitelat,site_lat_radians,errordecode);
  if errordecode then latitude1.color:=clred else latitude1.color:=clwindow;
  display_sqm;
end;


procedure Tform_sqm1.longitude1Change(Sender: TObject);{han.k}
begin
end;

procedure Tform_sqm1.longitude1Exit(Sender: TObject);
var
    errordecode:boolean;
begin
  sitelong:=longitude1.Text;
  dec_text_to_radians(sitelong,site_long_radians,errordecode);
  if errordecode then longitude1.color:=clred else longitude1.color:=clwindow;
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


procedure Tform_sqm1.sqm_applydf1Click(Sender: TObject);
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
  CloseAction := caFree; {required for later testing if form exists, https://wiki.freepascal.org/Testing,_if_form_exists}
  Form_sqm1 := nil;
end;


procedure Tform_sqm1.FormShow(Sender: TObject);{han.k}
begin
  esc_pressed:=false;{reset from cancel}
  backup_made:=false;

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
  pedestal1.Text:=inttostr(pedestal);

  display_sqm;
end;




end.

