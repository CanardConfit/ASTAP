unit unit_hjd;
{ Converts Julian day to Heliocentric Julian Day. Difference is maximum +- 500 sec / 8.3 minutes }

{Copyright (C) 2019 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

{This program is free software: you can redistribute it and/or modify
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
  Classes, SysUtils, math;

function JD_to_HJD(jd,ra_object,dec_object: double): double;{conversion JD to HJD}  {see https://en.wikipedia.org/wiki/Heliocentric_Julian_Day}
procedure EQU_GAL(ra,dec:double;var l,b: double);{equatorial to galactic coordinates}


implementation

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

procedure precession(jd, ra1,dec1 : double; var ra2,dec2 : double); {precession correction,  simple formula, new Meeus chapter precession}
var
  t,dra,ddec,sin_ra1,cos_ra1,m,n,n2  : double;

begin
  t:=(jd-2451545)/36525; {time in julian centuries since j2000 }
  m:=3.075+0.00186*t;{seconds}
  n:=1.33621-0.00057*t; {seconds}
  n2:=20.043-0.0085*t;{arcsec}
  sincos(ra1,sin_ra1,cos_ra1);
  dra:=(m + n *sin_ra1*tan(dec1))*pi/(3600*12);{yearly ra drift in radians}
  ddec:=n2*cos_ra1*pi/(3600*180); {yearly dec drift in radians}
  ra2:=ra1+(dra*t*100);{multiply with number of years is t*100}
  dec2:=dec1+(ddec*t*100);
end;

function JD_to_HJD(jd,ra_object,dec_object: double): double;{conversion Julian Day to Heliocentric Julian Day}
var                                                         {see https://en.wikipedia.org/wiki/Heliocentric_Julian_Day}
  ra_sun, dec_sun : double;
  sin_dec_object,cos_dec_object,sin_dec_sun,cos_dec_sun : double;
begin
  sun(jd,ra_sun,dec_sun);{get sun position in equinox of date coordinates}

  precession(2451545 -(jd-2451545){go back to J2000},ra_sun,dec_sun,ra_sun,dec_sun );{convert sun position from mean to J2000}

  sincos(dec_object,sin_dec_object,cos_dec_object);
  sincos(dec_sun,sin_dec_sun,cos_dec_sun);

  result:=jd - 500{sec}*(1/(24*3600))*(sin_dec_object* sin_dec_sun + cos_dec_object * cos_dec_sun * cos(ra_object -  ra_sun));  {assume 500 sec travel time Sun- Earth}
end;


procedure EQU_GAL(ra,dec:double;var l,b: double);{equatorial to galactic coordinates}
const
  {North_galactic pole (J2000)}
  pole_ra : double = 192.8595*pi/180;
  pole_dec: double =  27.1283*pi/180;
  posangle: double =  32.9319*pi/180;

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


end.

