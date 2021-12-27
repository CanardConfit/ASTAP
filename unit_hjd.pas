unit unit_hjd;
{ Converts Julian day to Heliocentric Julian Day. Difference is maximum +- 500 sec / 8.3 minutes }

{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

{$mode delphi}

interface

uses
  Classes, SysUtils, math;

var
  ra_mean : double=0;
  dec_mean: double=0;

function JD_to_HJD(jd,ra_object,dec_object: double): double;{conversion JD to HJD}  {see https://en.wikipedia.org/wiki/Heliocentric_Julian_Day}
procedure equ_gal(ra,dec:double;out l,b: double);{equatorial to galactic coordinates}
function airmass_calc(h: double): double; // where h is apparent altitude in degrees.
function atmospheric_absorption(airmass: double):double;{magnitudes}
function calculate_altitude(calc_mode : integer;ra3,dec3 : double): double;{convert centalt string to double or calculate altitude from observer location. Unit degrees}
procedure polar2(x,y,z:double;out r,theta,phi:double);

implementation
uses
  astap_main, unit_stack, unit_ephemerides,unit_asteroid;


{ sun:      low precision solar coordinates (approx. 1')               }
{           jd : julian day                                            }
{           ra : right ascension (in radians; equinox of date)         }
{           dec: declination (in radians; equinox of date)             }
{           Factors from "Astronomy on the personal computer"          }
procedure sun(jd:real; var ra,dec: double); {jd  var ra 0..2*pi, dec [0..pi/2] of Sun equinox of date}
  const
    cos_ecl=cos(23.43929111*pi/180);{obliquity of ecliptic}
    sin_ecl=sin(23.43929111*pi/180);{obliquity of ecliptic}
  var
    angle,l,m,dl,sin_l,cos_l,y,z,rho,t: double;

  begin
    t:=(jd-2451545)/36525; {time in julian centuries since j2000 }
    m  := 2*pi*frac(0.993133+99.997361*t);
    dl:= 6893.0*sin(m)+72.0*sin(2*m);
    angle:=frac(0.7859453 + m/(2*pi) + (6191.2*t+dl)/1296e3);{orbit position}
    if angle<0 then angle:=angle+1;   {frac(-1.1) is -0.1, should become 0.9}
    l := 2*pi*angle; {orbit position in radians}
    sincos(l,sin_l,cos_l);
    y:=cos_ecl*sin_l;{convert helio to geocentric coordinates}
    z:=sin_ecl*sin_l;
    rho:=sqrt(1.0-z*z);
    dec := arctan(z/rho);
    ra  := 2*arctan(y/(cos_l+rho));
    if (ra<0) then ra:=ra+(2*pi);
  end;


//procedure precession(jd, ra1,dec1 : double; var ra2,dec2 : double); {precession correction,  simple formula, new Meeus chapter precession}
//var
//  t,dra,ddec,sin_ra1,cos_ra1,m,n,n2  : double;

//begin
//  t:=(jd-2451545)/36525; {time in julian centuries since j2000 }
//  m:=3.075+0.00186*t;{seconds}
//  n:=1.33621-0.00057*t; {seconds}
//  n2:=20.043-0.0085*t;{arcsec}
//  sincos(ra1,sin_ra1,cos_ra1);
//  dra:=(m + n *sin_ra1*tan(dec1))*pi/(3600*12);{yearly ra drift in radians}
//  ddec:=n2*cos_ra1*pi/(3600*180); {yearly dec drift in radians}
//  ra2:=ra1+(dra*t*100);{multiply with number of years is t*100}
//  dec2:=dec1+(ddec*t*100);
//end;


function JD_to_HJD(jd,ra_object,dec_object: double): double;{conversion Julian Day to Heliocentric Julian Day}
var                                                         {see https://en.wikipedia.org/wiki/Heliocentric_Julian_Day}
  ra_sun, dec_sun : double;
  sin_dec_object,cos_dec_object,sin_dec_sun,cos_dec_sun : double;
begin
  sun(jd,ra_sun,dec_sun);{get sun position in equinox of date coordinates}
  precession3(jd, 2451545 {J2000},ra_sun,dec_sun); {precession}
  sincos(dec_object,sin_dec_object,cos_dec_object);
  sincos(dec_sun,sin_dec_sun,cos_dec_sun);

  result:=jd - 500{sec}*(1/(24*3600))*(sin_dec_object* sin_dec_sun + cos_dec_object * cos_dec_sun * cos(ra_object -  ra_sun));  {assume 500 sec travel time Sun- Earth}
end;


procedure equ_gal(ra,dec:double;out l,b: double);{equatorial to galactic coordinates}
const
  {North_galactic pole (J2000)}
  pole_ra : double = (12+51/60+26.27549/3600)*pi/12; {12h51m26.27549    https://www.aanda.org/articles/aa/pdf/2011/02/aa14961-10.pdf }
  pole_dec: double = (27+7/60+41.7043/3600)*pi/180; {+27◦07′41.7043′′}
  posangle: double = (122.93191857-90)*pi/180; {122.93191857◦}

// Converting between galactic to equatorial coordinates
// The galactic north pole is at RA = 12:51.4, Dec = +27:07 (2000.0),
// the galactic center at RA = 17:45.6, Dec = -28:56 (2000.0).
// The inclination of the galactic equator to the celestial equator is thus 62.9°.
// The intersection, or node line, of the two equators is at
// RA = 282.25°, Dec = 0:00 (2000.0), and at l = 33°, b=0.
var
  sin_b, cos_b, sin_pole_dec, cos_pole_dec :double;
begin
  sincos(pole_dec,sin_pole_dec, cos_pole_dec);
  b:=arcsin(cos(dec)*cos_pole_dec*cos(ra - pole_ra) + sin(dec)*sin_pole_dec);
  sincos(b,sin_b, cos_b);
  l:=arctan2(  (sin(dec) - sin_b *sin_pole_dec ) , (cos(dec)*cos_pole_dec*sin(ra - pole_ra)) )  + posangle;
end;


function fnmodulo(x,range: double):double;
begin
  {range should be 2*pi or 24 hours or 0 .. 360}
  result:=range*frac(x/range);
  if result<0 then result:=result+range;   {do not like negative numbers}
end;

//function altitude(ra3,dec3 {2000},lat,long,julian:double):double;{conversion ra & dec to altitude only. This routine is created for speed, only the altitude is calculated}
//{input RA [0..2pi], DEC [-pi/2..+pi/2],lat[-pi/2..pi/2], long[-pi..pi] West positive, East negative !!,time[0..2*pi]}
//var t5,wtime2actual : double;
//    sin_lat,cos_lat,sin_dec,cos_dec:double;
//const
//  siderealtime2000=(280.46061837)*pi/180;{[radians],  90 degrees shifted sidereal time at 2000 jan 1.5 UT (12 hours) =Jd 2451545 at meridian greenwich, see new meeus 11.4}
//  earth_angular_velocity = pi*2*1.00273790935; {about(365.25+1)/365.25) or better (365.2421874+1)/365.2421874 velocity dailly. See new Meeus page 83}

//begin
//  wtime2actual:=fnmodulo((long)+siderealtime2000 +(julian-2451545 )* earth_angular_velocity,2*pi); {As in the FITS header in ASTAP the site longitude is positive if east and has to be added to the time}
        {change by time & longitude in 0 ..pi*2, simular as siderial time}
        {2451545...for making dayofyear not to big, otherwise small errors occur in sin and cos}

//  precession3(2451545 {J2000},julian,ra3,dec3); {precession, from J2000 to Jnow}

//  t5:=wtime2actual-ra3;
//  sincos(lat,sin_lat,cos_lat);
//  sincos(dec3,sin_dec,cos_dec);
//  try
//  {***** altitude calculation from RA&DEC, meeus new 12.5 *******}
//  result:=arcsin(SIN_LAT*SIN_DEC+COS_LAT*COS_DEC*COS(T5));
//  except
//  {ignore floating point errors outside builder}
//  end;
//end;


{-----------------------------------------------------------------------}
{ POLAR2: conversion of cartesian coordinates (x,y,z)                   }
{        into polar coordinates (r,theta,phi)                           }
{        (theta in [-pi/2 deg,+pi/2]; phi in [0 ,+ 2*pi radians]        }
{-----------------------------------------------------------------------}
procedure polar2(x,y,z:double;out r,theta,phi:double);
var rho: double;
begin
  rho:=x*x+y*y;  r:=sqrt(rho+z*z);
  phi:=arctan2(y,x);
  if phi<0 then phi:=phi+2*pi;
  rho:=sqrt(rho);
  theta:=arctan2(z,rho);
end;


{----------------------------------------------------------------}
{ EQUHOR: conversion of equatorial into horizontal coordinates   }
{   DEC  : declination (-pi/2 .. +pi/2)                          }
{   TAU  : hour angle (0 .. 2*pi)                                }
{   PHI  : geographical latitude (in rad)                        }
{   H    : altitude (in rad)                                     }
{   AZ   : azimuth (0 deg .. 2*pi rad, counted S->W->N->E->S)    }
{----------------------------------------------------------------}
procedure equhor2 (dec,tau,phi: double; out h,az: double);
var cos_phi,sin_phi, cos_dec,sin_dec,cos_tau, sin_tau, x,y,z, dummy: double;
begin
  sincos(phi,sin_phi,cos_phi);
  sincos(dec,sin_dec,cos_dec);
  sincos(tau,sin_tau,cos_tau);
  x:=cos_dec*sin_phi*cos_tau - sin_dec*cos_phi;
  y:=cos_dec*sin_tau;
  z:=cos_dec*cos_phi*cos_tau + sin_dec*sin_phi;
  polar2(x,y,z, dummy,h,az)
end;


PROCEDURE RA_AZ(RA,de,LAT,LONG,t:double;out azimuth2,altitude2: double);{conversion ra & dec to altitude,azimuth}
{input RA [0..2pi], DEC [-pi/2..+pi/2],lat[-0.5*pi..0.5*pi],long[0..2*pi],time[0..2*pi]}
begin
  EQUHOR2(de,ra-long-t,lat, {var:} altitude2,azimuth2);
  azimuth2:=pi-azimuth2;
  if azimuth2<0 then azimuth2:=azimuth2+2*Pi;
end;


PROCEDURE AZ_RA(AZ,ALT,LAT,LONG,t:double;out ra,dcr: double);{conversion az,alt to ra,dec}
{input AZ [0..2pi], ALT [-pi/2..+pi/2],lat[-0.5*pi..0.5*pi],long[0..2pi],time[0..2*pi]}
begin
  EQUHOR2(alt,az,lat,{var:} dcr,ra);
  ra:=pi-ra+long +t;
  while ra<0 do ra:=ra+2*pi;
  while ra>=2*pi do ra:=ra-2*pi;
end;


function atmospheric_refraction(altitude_real,p {mbar},t {celsius} :double):double;  {atmospheric refraction}
var  hn  :real;
begin
  hn:=(altitude_real*(180/pi)+10.3/(altitude_real*(180/pi)+5.11))*pi/180;
                 {watch out with radians and degrees!!!!!!  carefully with factors}
  result:=((p/1010)*283/(273+t))*(pi/180)* (1.02/60)/(sin(hn)/cos(hn) ); {note: tan(x) = sin(x)/cos(x)}
 {bases on meeus 1991 page 102, formula 15.4}
end;


function altitude_and_refraction(lat,long,julian,temperature:double;calc_mode: integer; ra3,dec3: double):double;{altitude calculation and correction ra, dec for refraction}
{input RA [0..2pi], DEC [-pi/2..+pi/2],lat[-pi/2..pi/2], long[-pi..pi] West NEGATIVE, East POSTIVE !!,time[0..2*pi]}
var wtime2actual,azimuth2,altitude2: double;
const
  siderealtime2000=(280.46061837)*pi/180;{[radians],sidereal time at 2000 jan 1.5 UT (12 hours) =Jd 2451545 at meridian greenwich, see new meeus 11.4}
  earth_angular_velocity = pi*2*1.00273790935; {about(365.25+1)/365.25) or better (365.2421874+1)/365.2421874 velocity dailly. See new Meeus page 83}

begin
  wtime2actual:=fnmodulo(+long+siderealtime2000 +(julian-2451545 )* earth_angular_velocity,2*pi);{Local sidereal time. As in the FITS header in ASTAP the site longitude is positive if east and has to be added to the time}
  RA_AZ(ra3,dec3,lat,0,wtime2actual,{var} azimuth2,altitude2);{conversion ra & dec to altitude,azimuth}

 {correct for temperature and correct head.ra0, head.dec0 for refraction}
  if temperature>=100 {999} then temperature:=10 {default temperature celsius};
  result:=atmospheric_refraction(altitude2,1010 {mbar},temperature {celsius});{apparant altitude}
  if calc_mode=2 then result:=altitude2+result {astrometric to apparent}
  else
  begin {calc_mode=3, apparent to astrometric}
    if calc_mode=3 then result:=altitude2 {no refaction compensation}
    else
    result:=altitude2-result; {apparent to astrometric !!!!}

    AZ_RA(azimuth2,result,LAT,0,wtime2actual, {var} ra_mean,dec_mean);{conversion az,alt to ra_mean,dec_mean reverse corrected for refraction}

//    RA_AZ((23+9/60)*pi/12,(-6-43/60)*pi/180,(38+55/60)*pi/180,-(5+8/60)*pi/12,(8+(34)/60)*pi/12,{var} azimuth2,altitude2);{conversion ra & dec to altitude,azimuth}
//    RA_AZ2((23+9/60)*pi/12,(-6-43/60)*pi/180,(38+55/60)*pi/180,0,(8-5+(34-8)/60)*pi/12,{var} azimuth2,altitude2);{conversion ra & dec to altitude,azimuth}
//    RA_AZ2((23+9/60)*pi/12,(-6-43/60)*pi/180,(38+55/60)*pi/180,+(5+8/60)*pi/12,(8+(34)/60)*pi/12,{var} azimuth2,altitude2);{conversion ra & dec to altitude,azimuth}
//    AZ_RA(AZIMUTH2,ALTITUDE2,39*pi/180,0,(8-5+(34-8)/60)*pi/12, {var} ra_mean,dec_mean);{conversion az,alt to ra_mean,dec_mean reverse corrected for refraction}
//    AZ_RA2(AZIMUTH2,ALTITUDE2,39*pi/180,0,(8-5+(34-8)/60)*pi/12, {var} ra_mean,dec_mean);{conversion az,alt to ra_mean,dec_mean reverse corrected for refraction}
//    AZ_RA2(AZIMUTH2,ALTITUDE2,39*pi/180,+(5+8/60)*pi/12,(8+(34)/60)*pi/12, {var} ra_mean,dec_mean);{conversion az,alt to ra_mean,dec_mean reverse corrected for refraction}
//    beep;
  end;
end;


function calculate_altitude(calc_mode : integer;ra3,dec3 : double): double;{convert centalt string to double or calculate altitude from observer location. Unit degrees}
var
  site_lat_radians,site_long_radians : double;
  errordecode  : boolean;
  err          : integer;
begin
  {calc_mode 1: use CENTALT from header or if not available calculate it}
  {calc_mode 2: calculate it, apply refration astrometric to apparent}
  {calc_mode 3: calculate it, no refaction compensation}
  {calc_mode 4: calculate it, apply refration apparent to astrometric!!}
  result:=strtofloat2(centalt);

  if (((result=0) or (calc_mode>1)) and (head.cd1_1<>0)) then {calculate from observation location, image center and time the altitude}
  begin
    if sitelat='' then
    begin
      sitelat:=lat_default;
      sitelong:=long_default;
    end;
    val(sitelat,site_lat_radians,err); {try to process  3.7E+01}
    if err=0 then
      begin site_lat_radians:=site_lat_radians*pi/180; errordecode:=false end
    else  {try to process string 37 00 00}
      dec_text_to_radians(sitelat,site_lat_radians,errordecode);
    if errordecode=false then
    begin
      val(sitelong,site_long_radians,err); {try to process  3.7E+01}
      if err=0 then
        begin site_long_radians:=site_long_radians*pi/180; errordecode:=false end
      else  {try to process string  37 00 00}
        dec_text_to_radians(sitelong,site_long_radians,errordecode);
      if errordecode=false then
      begin
        if jd_start=0 then date_to_jd(head.date_obs,head.exposure);{convert date-obs to jd_start, jd_mid}
        if jd_mid>2400000 then {valid JD}
        begin
          precession3(2451545 {J2000},jd_mid,ra3,dec3); {precession, from J2000 to Jnow}
          result:=(180/pi)*altitude_and_refraction(site_lat_radians,site_long_radians,jd_mid,focus_temp, calc_mode, ra3,dec3);{In formulas the longitude is positive to west!!!. }
        end
        else memo2_message('Error decoding Julian day!');
      end;
    end;
    if errordecode then memo2_message('Error decoding site longitude or latitude!');
  end;
end;


function airmass_calc(h: double): double; // where h is apparent altitude in degrees.
begin
  // Pickering, 2002, https://en.wikipedia.org/wiki/Air_mass_(astronomy)
  if h>=0.0000001 then
    result := 1 / sin((pi/180) * (h + (244 / (165 + 47 * power(h,1.1)))))
  else
    result:=999;
end;


function atmospheric_absorption(airmass: double):double;{magnitudes}
{The Extinction, Scattering, Absorption due to the atmosphere expressed in magnitudes.
 Reference http://www.icq.eps.harvard.edu/ICQExtinct.html
 see also https://www.skyandtelescope.com/astronomy-resources/transparency-and-atmospheric-extinction/}
 var
  a_ozon,a_ray,a_aer : double;
begin
  a_ozon:=airmass*0.016; {Schaefer's (1992) value Aoz =0.016 magnitudes per air mass for the small ozone component contributing to atmospheric extinction.}
  a_ray:=airmass*0.1451; {Rayleigh scattering by air molecules. Expressed in magnitudes}
  a_aer:=airmass*0.120; {Extinction due to aerosol scattering is due to particulates including dust, water droplets and manmade pollutants. Expressed in magnitudes}
  result:=a_ozon+a_ray+a_aer;{Total extinction, scattering, absorption due to the atmosphere expressed in magnitudes}
end;


end.

