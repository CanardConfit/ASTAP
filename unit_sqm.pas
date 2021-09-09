unit unit_sqm;



{$mode delphi}

interface

uses
   Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
   LCLIntf, Buttons,{for for getkeystate, selectobject, openURL}
   astap_main, unit_annotation,unit_hjd,unit_stack;

type

  { Tform_sqm1 }

  Tform_sqm1 = class(TForm)
    message1: TLabel;
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
  private

  public

  end;

var
  form_sqm1: Tform_sqm1;


function calculate_sqm(get_bk,get_his : boolean) : boolean; {calculate sqky background value}


implementation


{$R *.lfm}

var
  site_lat_radians,site_long_radians  : double;



function calculate_sqm(get_bk,get_his : boolean) : boolean; {calculate sky background value}
var
  airm, correction,alt : double;
begin
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
    if pedestal>=cblack then begin beep; pedestal:=0; {prevent errors} end;
    sqmfloat:=flux_magn_offset-ln((cblack-pedestal)/sqr(cdelt2*3600){flux per arc sec})*2.511886432/ln(10);
    alt:=calculate_altitude(1 {astrometric_to_apparent_or_reverse},{var} ra0,dec0);{convert centalt string to double or calculate altitude from observer location}

    centalt:=inttostr(round(alt));{for reporting in menu sqm1}
    if alt<>0 then
    begin
      airm:=airmass_calc(alt);
      correction:= atmospheric_absorption(airm)- 0.28 {absorption at zenith};
      sqmfloat:=sqmfloat+correction;
      result:=true;
    end;
  end;
end;


procedure display_sqm;
begin
  with form_sqm1 do
  begin
    date_to_jd(date_obs,exposure);{convert date-OBS to jd_start and jd_mid}

    if jd_start<=2400000 then {no date, found year <1858}
    begin
      message1.caption:='Error converting date obs.';
      sqm1.caption:='?';
      exit;
    end;

    {calc}
    if calculate_sqm(true {get backgr},false{get histogr})=false then {failure in calculating sqm value}
    begin
      if centalt='0' then message1.caption:='Could not retrieve or calculate altitude. Enter the default geographic location';
      sqm1.caption:='?';
      exit;
    end
    else  message1.caption:='';

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
  form_sqm1.close;   {normal this form is not loaded}
  mainwindow.setfocus;

  mainwindow.save_settings1Click(nil);{save pedestal value}
end;

procedure Tform_sqm1.pedestal1Exit(Sender: TObject);
begin
  pedestal:=round(strtofloat2(pedestal1.Text));
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

    date_obs:=date_obs1.Text;
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
  date_obs:=date_obs1.text;
  display_sqm;
end;

procedure Tform_sqm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  set_some_defaults;
end;


procedure Tform_sqm1.FormShow(Sender: TObject);{han.k}
begin
  esc_pressed:=false;{reset from cancel}

  date_obs1.Text:=date_obs;

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

