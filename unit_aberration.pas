unit unit_aberration;

{$mode delphi}

interface

uses
  Classes, SysUtils,math;

procedure aberration_correction_equatorial(julian_et: double;var ra,dec : double);{J2000 equinox}
procedure nutation_correction_equatorial(julian_et: double;var ra,dec : double);{mean equinox, add nutation M&P page 125}
procedure J2000_to_apparent(jd: double;var ra,dec : double);{without refraction}

implementation

uses unit_hjd, unit_ephemerides;



function deltaT_calc(jd: double) : double; {Difference between dynamic time and UTC in days}
var
   year   : integer;
   y,u,t  : double;
begin
  y:=(2000 +(JD-2451544.5)/365.25);
  year:=round(y);

  if ((year>=2021) and (year<=2024)) then
  begin
    t:=y-2021;
    result:=(71+t*0.5);{seconds}  // (73-71)/4 = 0.5
  end
  else
  if ((year>=2025) and (year<=2049)) then
  begin
    t:=y-2000;
    result:=(61.46+t*(0.32217+t*(0.005589)));{seconds}
  end
  else
  if ((year>=2050) and (year<=2149)) then
  begin
    u:=(y-1820)/100;
    t:=2150-y;
    result:=(-20+32*u*u-0.5788*t);{seconds}
  end
  else
  result:=0;

  result:=result/(24*3600);{convert results to days}
end;





(*-----------------------------------------------------------------------*)
(* NUTEQU: transformation of mean to true coordinates                    *)
(*         (including terms >0.1" according to IAU 1980)                 *)
(*         T = (JD-2451545.0)/36525.0                                    *)
(*-----------------------------------------------------------------------*)
PROCEDURE NUTEQU(T:double; VAR X,Y,Z:double);
CONST ARC=206264.8062;          (* arcseconds per radian = 3600*180/pi *)
      P2 =6.283185307;          (* 2*pi                                *)
VAR   LS,D,F,N,EPS : double;
      DPSI,DEPS,C,S: double;
      DX,DY,DZ     : double;
  FUNCTION FRAC(X:double):double;
    BEGIN  FRAC:=X-TRUNC(X) END;
BEGIN
  LS  := P2*FRAC(0.993133+  99.997306*T); (* mean anomaly Sun          *)
  D   := P2*FRAC(0.827362+1236.853087*T); (* diff. longitude Moon-Sun  *)
  F   := P2*FRAC(0.259089+1342.227826*T); (* mean argument of latitude *)
  N   := P2*FRAC(0.347346-   5.372447*T); (* longit. ascending node    *)
  EPS := 0.4090928-2.2696E-4*T;           (* obliquity of the ecliptic *)
  DPSI := ( -17.200*SIN(N)   - 1.319*SIN(2*(F-D+N)) - 0.227*SIN(2*(F+N))
            + 0.206*SIN(2*N) + 0.143*SIN(LS) ) / ARC;
  DEPS := ( + 9.203*COS(N)   + 0.574*COS(2*(F-D+N)) + 0.098*COS(2*(F+N))
            - 0.090*COS(2*N)                 ) / ARC;
  C := DPSI*COS(EPS);  S := DPSI*SIN(EPS);
  DX := -(C*Y+S*Z); DY := (C*X-DEPS*Z); DZ := (S*X+DEPS*Y);
  X:=X + DX;
  Y:=Y + DY;
  Z:=Z + DZ;
END;


(*-----------------------------------------------------------------------*)
(* CART2: conversion of polar coordinates (r,theta,phi)                   *)
(*       into cartesian coordinates (x,y,z)                              *)
(*       (theta in [-pi/2.. pi/2 rad]; phi in [-pi*2,+pi*2 rad])         *)
(*-----------------------------------------------------------------------*)
procedure cart2(R,THETA,PHI: double; out X,Y,Z: double);
  VAR RCST : double;
      cos_theta,sin_theta :double;
      cos_phi,sin_phi     :double;
begin
  sincos(theta,sin_theta,cos_theta);
  sincos(phi  ,sin_phi  ,cos_phi);
  RCST := R*COS_THETA;
  X    := RCST*COS_PHI; Y := RCST*SIN_PHI; Z := R*SIN_THETA;
end;


(*-----------------------------------------------------------------------*)
(* ABERRAT: velocity vector of the Earth in equatorial coordinates       *)
(*          (in units of the velocity of light)                          *)
(*-----------------------------------------------------------------------*)
PROCEDURE ABERRAT(T: double; out VX,VY,VZ: double);{velocity vector of the Earth in equatorial coordinates, and units of the velocity of light}
  CONST P2=6.283185307;
  VAR L,CL: double;
  FUNCTION FRAC(X:double):double;
    BEGIN
      X:=X-TRUNC(X);
      IF (X<0) THEN X:=X+1;
      FRAC:=X;
    END;
BEGIN
  L := P2*FRAC(0.27908+100.00214*T);
  CL:=COS(L);
  VX := -0.994E-4*SIN(L);
  VY := +0.912E-4*CL;
  VZ := +0.395E-4*CL;
END;


(*----------------------------------------------------------------*)
(* EQUHOR: conversion of equatorial into horizontal coordinates   *)
(*   DEC  : declination (-pi/2 .. +pi/2)                          *)
(*   TAU  : hour angle (0 .. 2*pi)                                *)
(*   PHI  : geographical latitude (in rad)                        *)
(*   H    : altitude (in rad)                                     *)
(*   AZ   : azimuth (0 deg .. 2*pi rad, counted S->W->N->E->S)    *)
(*----------------------------------------------------------------*)
PROCEDURE EQUHOR2 (DEC,TAU,PHI: double; out H,AZ: double);
  VAR COS_PHI,SIN_PHI, COS_DEC,SIN_DEC,COS_TAU, SIN_TAU, X,Y,Z, DUMMY: double;
BEGIN
  SINCOS(PHI,SIN_PHI,COS_PHI);
  SINCOS(DEC,SIN_DEC,COS_DEC);
  SINCOS(TAU,SIN_TAU,COS_TAU);
  X:=COS_DEC*SIN_PHI*COS_TAU - SIN_DEC*COS_PHI;
  Y:=COS_DEC*SIN_TAU;
  Z:=COS_DEC*COS_PHI*COS_TAU + SIN_DEC*SIN_PHI;
  POLAR2(X,Y,Z, DUMMY,H,AZ)
END;


procedure nutation_correction_equatorial(julian_et: double;var ra,dec : double);{mean equinox, add nutation M&P page 125}
var r,x0,y0,z0,vx,vy,vz,dum1,dum2 : double;
    ph_earth, vh_earth : r3_array;{helio centric earth vector}

begin
  cart2(1,dec,ra,x0,y0,z0); {make cartesian coordinates}

  NUTEQU((julian_et-2451545.0)/36525.0 ,x0,y0,z0);{add nutation}

  polar2(x0,y0,z0,r,dec,ra);
end;


procedure aberration_correction_equatorial(julian_et: double;var ra,dec : double);{J2000 equinox}
var r,x0,y0,z0,vx,vy,vz,dum1,dum2 : double;
    pb_earth, vb_earth : r3_array;{barycentric earth vector}
    ph_earth, vh_earth : r3_array;{heliocentric earth vector}

begin
  //http://www.bbastrodesigns.com/coordErrors.html  Gives same value within a fraction of arcsec.
  //2020-1-1, JD=2458850.50000, RA,DEC position 12:00:00, 40:00:00, precession +00:01:01.45, -00:06:40.8, Nutation -00:00:01.1,  +00:00:06.6, Annual aberration +00:00:00.29, -00:00:14.3
  //2020-1-1, JD=2458850.50000  RA,DEC position 06:00:00, 40:00:00, precession +00:01:23.92, -00:00:01.2, Nutation -00:00:01.38, -00:00:01.7, Annual aberration +00:00:01.79, +00:00:01.0
  //2030-6-1, JD=2462654.50000  RA,DEC position 06:00:00, 40:00:00, precession +00:02:07.63, -00°00'02.8",Nutation +00:00:01.32, -0°00'02.5", Annual aberration -00:00:01.65, +00°00'01.10"

//  Meeus Astronomical algorithms. Example 22.a and 20.b
//  2028-11-13.19     JD 2462088.69
//  J2000, RA=41.054063, DEC=49.22775
//  Mean   RA=41.547214, DEC=49.348483
//  True   RA=41.55996122, DEC=49.35207022  {error  with Astronomy on the computer 0.23" and -0.06"}
//  Nutation ["]   RA 15.843, DEC	6.218
//  Aberration["]  RA 30.047, DEC	6.696

  cart2(1,dec,ra,x0,y0,z0); {make cartesian coordinates}

  ABERRAT((julian_et-2451545.0)/36525.0,vx,vy,vz);{ABERRAT: velocity vector of the Earth in equatorial coordinates and units of the velocity of light}
//  x0:=x0+VX;{apply aberration,(v_earth/speed_light)*180/pi=20.5"}
//  y0:=y0+VY;
//  z0:=z0+VZ;

  sla_EPV (julian_et-2400000.5{mjd}, ph_earth,vh_earth , pb_earth,vb_earth {AU/day});{barycentric position earth including light time correction, high accuracy for years 1900 to 2100}
  x0:=x0+vb_earth[1]*0.00577552; {conversion from AU/day to speed of light, about 1/173} {apply aberration,(v_earth/speed_light)*180/pi=20.5"}
  y0:=y0+vb_earth[2]*0.00577552; {conversion from AU/day to speed of light, about 1/173}
  z0:=z0+vb_earth[3]*0.00577552; {conversion from AU/day to speed of light, about 1/173}

  polar2(x0,y0,z0,r,dec,ra);
end;


procedure J2000_to_apparent(jd: double;var ra,dec : double);{without refraction}
var
  jde : double; {Julian day based on dynamic time}
begin
  jde:=jd+deltaT_calc(jd);// difference between dynamic time and UTC in days
  aberration_correction_equatorial(jde,ra,dec);{aberration correction in J2000 equinox, See ook meeus pagine 148. De Earth velocity terms are for J2000 and not Jnow}
  precession3(2451545 {J2000},jde,ra,dec); {precession, from J2000 to Jnow}
  nutation_correction_equatorial(jde,ra,dec);{mean equinox.  M&P page 125}
end;


end.

