unit unit_asteroid;
{taken from HNSKY unit. Routines (c) by Springer-Nature unless indicated otherwise by han.k}

{Software code is Copyright (C) 1998 by Springer-Nature, Berlin Heidelberg and originates the code described in the book Astronomy on the Personal Computer,
 ISBN 3-540-63521-1 3rd edition 1998. Authors Oliver Montenbruck and Thomas Pleger.
 Reproduced with written permission of SNCSC (Springer-Nature) dated 2019-3-27 under the conditions specified in the letter below.

Modified for the HNSKY planetarium program by Han Kleijn, www.hnsky.org email: han.k.. at...hnsky.org

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

Springer Nature letter dated 2019-3-27:
*** Johannes Kleijn
*** Netherlands
*** 27/03/2019
*** Dear Mr Kleijn,
*** Re: Your permission request dated: 26 March 2019, your reference: Johannes Kleijn (“Licensee”), our reference: Springer Nature Customer Service Center GmbH (“SNCSC”)
***     acting as a commissionaire agent of Springer Nature Ltd (the PUBLISHER)
*** Request for permission to use: Software code from Astronomy on the Personal Computer, 978-3-540-63521-5, 3rd Edition, 1998 by Montenbruck, Oliver (“Licensed Material”)
*** to be published in the Astronomy Program HNSky http://www.hnsky.org/software.htm under a GPL3 License.
*** This permission covers:
*** •Non-exclusive
*** •Electronic rights only
*** •The English language
*** •Distribution in the following territory: Worldwide
*** •For the avoidance of doubt, derivative rights are excluded from this licence
*** •Copyright fee: gratis
*** This permission is subject to the following conditions:
*** 1. An acknowledgement is made as follows: 'AUTHOR, TITLE, published [YEAR] [publisher - as it appears on our copyright page] reproduced with permission of SNCSC'.
*** 2. This permission does not apply to quotations, figures or tables from other sources which may be part of the material to be used. If the book acknowledgements or credit
***    line on any part of the material you have requested indicates that it was reprinted or adapted by SNCSC with permission from another source, then you should also seek
***    permission from that source to reuse the material.
*** 3. This permission is only valid if no personal rights, trademarks, or competitive products are infringed.
*** 4. The Licensee may not make the Licensed Material available in a manner intended to allow or invite a third party to download, extract, redistribute, republish or access
***    the Licensed Material as a standalone file.
*** 5. This permission is personal to you and may not be sublicensed, assigned, or transferred by you without SNCSC’s written permission, unless specified and agreed with SNCSC.
*** 6. Delivery and use of the Licensed Material must be in a format that retains the integrity of the text. Figures, illustrations, and tables may be altered minimally to serve
***    your work. Any other abbreviations, additions, deletions and/or any other alterations shall be made only with prior written authorization of SNCSC.
*** 7. We do not routinely require a complimentary copy of your product on publication; however we reserve the right to receive a free copy on request at a later stage.
*** 8. We may terminate this licence with immediate effect on written notice to you for any reason. Upon termination of this licence for any reason, all rights in this licence
***    shall immediately revert to SNCSC.
*** 9. This licence shall be governed by, and shall be construed in accordance with, the laws of the Federal Republic of Germany.
*** Yours sincerely
*** Springer Nature Permissions Team
*** On behalf of SNCSC}



{$mode delphi}

interface

uses
   Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
   LCLIntf, ColorBox,{for for getkeystate, selectobject, openURL}
   math, astap_main, unit_stack;

type

  { Tform_asteroids1 }

  Tform_asteroids1 = class(TForm)
    add_annotations1: TCheckBox;
    annotate_asteroids1: TButton;
    cancel_button1: TButton;
    ColorBox1: TColorBox;
    date_label1: TLabel;
    date_obs1: TEdit;
    download_mpcorb1: TLabel;
    file_to_add1: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    help_asteroid_annotation1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    latitude1: TEdit;
    longitude1: TEdit;
    max_magn_asteroids1: TEdit;
    max_nr_asteroids1: TEdit;
    mpcorb_filedate1: TLabel;
    mpcorb_path1: TLabel;
    OpenDialog1: TOpenDialog;
    showfullnames1: TCheckBox;
    add_subtitle1: TCheckBox;
    UpDown1: TUpDown;
    up_to_magn1: TLabel;
    up_to_number1: TLabel;
    procedure annotate_asteroids1Click(Sender: TObject);
    procedure cancel_button1Click(Sender: TObject);
    procedure download_mpcorb1Click(Sender: TObject);
    procedure file_to_add1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure help_asteroid_annotation1Click(Sender: TObject);
    procedure latitude1Change(Sender: TObject);
    procedure longitude1Change(Sender: TObject);
  private

  public

  end;

var
  form_asteroids1: Tform_asteroids1;


const
   maxcount_asteroid : string='10000';
   maxmag_asteroid : string='17';
   mpcorb_path : string='MPCORB.DAT';
   showfullnames: boolean=true;
   add_annotations: boolean=false;{annotation to the fits header}
   add_date: boolean=true;

procedure plot_mpcorb(maxcount : integer;maxmag:double;add_annot :boolean) ;{read MPCORB.dat}{han.k}

implementation

{$R *.lfm}
type
  double33= array[1..3,1..3] of double;

var
   x_sun,y_sun,z_sun : double; {of earth}
   X_pln,Y_pln,Z_pln : double; {of planet}

   wtime2actual: double;
   midpoint    : boolean;
   site_lat_radians,site_long_radians  : double;

const
   sun200_calculated : boolean=false; {sun200 calculated for comets}
   siderealtime2000=(280.46061837)*pi/180;{[radians],  90 degrees shifted sidereal time at 2000 jan 1.5 UT (12 hours) =Jd 2451545 at meridian greenwich, see new meeus 11.4}
   earth_angular_velocity = pi*2*1.00273790935; {about(365.25+1)/365.25) or better (365.2421874+1)/365.2421874 velocity dailly. See new Meeus page 83}
   AE=149597870.700; {ae has been fixed to the value 149597870.700 km as adopted by the International Astronomical Union in 2012.  Note average earth distance is 149597870.662 * 1.000001018 see meeus new 379}


VAR DAY : INTEGER;
    HOUR, T, TEQX,  XP_ecl_helio,YP_ecl_helio,ZP_ecl_helio, XS,YS,ZS,xe,ye,ze {earth},xeb,yeb,zeb {earth tov Bary centre},
                    xsb,ysb,zsb, {Sun t.o.v Bary centre} xa,ya,za {astroid}, sun_geodist, L,B,R,LS,BS,RS,
                    VX,VY,VZ {comet}     : double;



procedure Tform_asteroids1.help_asteroid_annotation1Click(Sender: TObject); {han.k}
begin
  openurl('http://www.hnsky.org/astap.htm#asteroid_annotation');
end;

procedure Tform_asteroids1.latitude1Change(Sender: TObject);{han.k}
var
  errordecode:boolean;
begin
  dec_text_to_radians(latitude1.Text,site_lat_radians,errordecode);
  if errordecode then latitude1.color:=clred else latitude1.color:=clwindow;
end;

procedure Tform_asteroids1.longitude1Change(Sender: TObject);{han.k}
var
  errordecode:boolean;
begin
  ra_text_to_radians(longitude1.Text,site_long_radians,errordecode);
  if errordecode then longitude1.color:=clred else longitude1.color:=clwindow;
end;


(*---------------------------------------------------------------------------*)
(* ACS: Arcus-Cosinus-Funktion (Gradmass)                                    *)
(*---------------------------------------------------------------------------*)
FUNCTION ACS(X:double):double;
CONST RAD=0.0174532925199433; EPS=1E-7; C=90.0;
BEGIN
  IF ABS(X)=1.0
   THEN ACS:=C-X*C
   ELSE IF (ABS(X)>EPS) THEN ACS:=C-ARCTAN(X/SQRT((1.0-X)*(1.0+X)))/RAD
                         ELSE ACS:=C-X/RAD;
END;

(*-----------------------------------------------------------------------*)
(* SN: sine function (degrees)                                           *)
(*-----------------------------------------------------------------------*)
FUNCTION SN(X:double):double;
CONST RAD=0.0174532925199433;
BEGIN
  SN:=SIN(X*RAD)
END;
(*-----------------------------------------------------------------------*)
(* CS: cosine function (degrees)                                         *)
(*-----------------------------------------------------------------------*)
FUNCTION CS(X:double):double;
CONST RAD=0.0174532925199433;
BEGIN
  CS:=COS(X*RAD)
END;
(*-----------------------------------------------------------------------*)
(* TN: tangent function (degrees)                                        *)
(*-----------------------------------------------------------------------*)
FUNCTION TN(X:double):double;
CONST RAD=0.0174532925199433;
VAR XX: double;
BEGIN
  XX:=X*RAD; TN:=SIN(XX)/COS(XX);
END;
(*-----------------------------------------------------------------------*)
(* ATN: arctangent function (degrees)                                    *)
(*-----------------------------------------------------------------------*)
FUNCTION ATN(X:double):double;
CONST RAD=0.0174532925199433;
BEGIN
  ATN:=ARCTAN(X)/RAD
END;

(*-----------------------------------------------------------------------*)
(* ATN2: arctangent of y/x for two arguments                             *)
(*       (correct quadrant; -180 deg <= ATN2 <= +180 deg)                *)
(*-----------------------------------------------------------------------*)
FUNCTION ATN2(Y,X:double):double;
  CONST RAD=0.0174532925199433;
  VAR   AX,AY,PHI: double;
  BEGIN
    IF (X=0.0) AND (Y=0.0)
      THEN ATN2:=0.0
      ELSE
        BEGIN
          AX:=ABS(X); AY:=ABS(Y);
          IF (AX>AY)
            THEN PHI:=ARCTAN(AY/AX)/RAD
            ELSE PHI:=90.0-ARCTAN(AX/AY)/RAD;
          IF (X<0.0) THEN PHI:=180.0-PHI;
          IF (Y<0.0) THEN PHI:=-PHI;
          ATN2:=PHI;
        END;
  END;


(*-----------------------------------------------------------------------*)
(* SUN200: ecliptic coordinates L,B,R (in deg and AU) of the             *)
(*         Sun referred to the mean equinox of date                      *)
(*         (T: time in Julian centuries since J2000)                     *)
(*         (   = (JED-2451545.0)/36525             )                     *)
(*-----------------------------------------------------------------------*)
PROCEDURE SUN200(T:double;VAR L,B,R:double);
  CONST P2=6.283185307;
  VAR C3,S3:          ARRAY [-1..7] OF double;
      C,S:            ARRAY [-8..0] OF double;
      M2,M3,M4,M5,M6: double;
      D,A,UU:         double;
      U,V,DL,DR,DB:   double;
      I:              INTEGER;

  FUNCTION FRAC(X:double):double;
    (* for some compilers TRUNC has to be replaced by LONG_TRUNC *)
    (* or INT (Turbo-Pascal) if the routine is used with T<-24   *)
    BEGIN  X:=X-TRUNC(X); IF (X<0) THEN X:=X+1.0; FRAC:=X  END;

  PROCEDURE ADDTHE(C1,S1,C2,S2:double; VAR C,S:double);
    BEGIN  C:=C1*C2-S1*S2; S:=S1*C2+C1*S2; END;

  PROCEDURE TERM(I1,I,IT:INTEGER;DLC,DLS,DRC,DRS,DBC,DBS:double);
    BEGIN
      IF IT=0 THEN ADDTHE(C3[I1],S3[I1],C[I],S[I],U,V)
              ELSE BEGIN U:=U*T; V:=V*T END;
      DL:=DL+DLC*U+DLS*V; DR:=DR+DRC*U+DRS*V; DB:=DB+DBC*U+DBS*V;
    END;


  PROCEDURE PERTVEN;  (* Keplerian terms and perturbations by Venus *)
    VAR I: INTEGER;
    BEGIN
      C[0]:=1.0; S[0]:=0.0; C[-1]:=COS(M2); S[-1]:=-SIN(M2);
      FOR I:=-1 DOWNTO -5 DO ADDTHE(C[I],S[I],C[-1],S[-1],C[I-1],S[I-1]);
      TERM(1, 0,0,-0.22,6892.76,-16707.37, -0.54, 0.00, 0.00);
      TERM(1, 0,1,-0.06, -17.35,    42.04, -0.15, 0.00, 0.00);
      TERM(1, 0,2,-0.01,  -0.05,     0.13, -0.02, 0.00, 0.00);
      TERM(2, 0,0, 0.00,  71.98,  -139.57,  0.00, 0.00, 0.00);
      TERM(2, 0,1, 0.00,  -0.36,     0.70,  0.00, 0.00, 0.00);
      TERM(3, 0,0, 0.00,   1.04,    -1.75,  0.00, 0.00, 0.00);
      TERM(0,-1,0, 0.03,  -0.07,    -0.16, -0.07, 0.02,-0.02);
      TERM(1,-1,0, 2.35,  -4.23,    -4.75, -2.64, 0.00, 0.00);
      TERM(1,-2,0,-0.10,   0.06,     0.12,  0.20, 0.02, 0.00);
      TERM(2,-1,0,-0.06,  -0.03,     0.20, -0.01, 0.01,-0.09);
      TERM(2,-2,0,-4.70,   2.90,     8.28, 13.42, 0.01,-0.01);
      TERM(3,-2,0, 1.80,  -1.74,    -1.44, -1.57, 0.04,-0.06);
      TERM(3,-3,0,-0.67,   0.03,     0.11,  2.43, 0.01, 0.00);
      TERM(4,-2,0, 0.03,  -0.03,     0.10,  0.09, 0.01,-0.01);
      TERM(4,-3,0, 1.51,  -0.40,    -0.88, -3.36, 0.18,-0.10);
      TERM(4,-4,0,-0.19,  -0.09,    -0.38,  0.77, 0.00, 0.00);
      TERM(5,-3,0, 0.76,  -0.68,     0.30,  0.37, 0.01, 0.00);
      TERM(5,-4,0,-0.14,  -0.04,    -0.11,  0.43,-0.03, 0.00);
      TERM(5,-5,0,-0.05,  -0.07,    -0.31,  0.21, 0.00, 0.00);
      TERM(6,-4,0, 0.15,  -0.04,    -0.06, -0.21, 0.01, 0.00);
      TERM(6,-5,0,-0.03,  -0.03,    -0.09,  0.09,-0.01, 0.00);
      TERM(6,-6,0, 0.00,  -0.04,    -0.18,  0.02, 0.00, 0.00);
      TERM(7,-5,0,-0.12,  -0.03,    -0.08,  0.31,-0.02,-0.01);
    END;

  PROCEDURE PERTMAR;  (* perturbations by Mars *)
    VAR I: INTEGER;
    BEGIN
      C[-1]:=COS(M4); S[-1]:=-SIN(M4);
      FOR I:=-1 DOWNTO -7 DO ADDTHE(C[I],S[I],C[-1],S[-1],C[I-1],S[I-1]);
      TERM(1,-1,0,-0.22,   0.17,    -0.21, -0.27, 0.00, 0.00);
      TERM(1,-2,0,-1.66,   0.62,     0.16,  0.28, 0.00, 0.00);
      TERM(2,-2,0, 1.96,   0.57,    -1.32,  4.55, 0.00, 0.01);
      TERM(2,-3,0, 0.40,   0.15,    -0.17,  0.46, 0.00, 0.00);
      TERM(2,-4,0, 0.53,   0.26,     0.09, -0.22, 0.00, 0.00);
      TERM(3,-3,0, 0.05,   0.12,    -0.35,  0.15, 0.00, 0.00);
      TERM(3,-4,0,-0.13,  -0.48,     1.06, -0.29, 0.01, 0.00);
      TERM(3,-5,0,-0.04,  -0.20,     0.20, -0.04, 0.00, 0.00);
      TERM(4,-4,0, 0.00,  -0.03,     0.10,  0.04, 0.00, 0.00);
      TERM(4,-5,0, 0.05,  -0.07,     0.20,  0.14, 0.00, 0.00);
      TERM(4,-6,0,-0.10,   0.11,    -0.23, -0.22, 0.00, 0.00);
      TERM(5,-7,0,-0.05,   0.00,     0.01, -0.14, 0.00, 0.00);
      TERM(5,-8,0, 0.05,   0.01,    -0.02,  0.10, 0.00, 0.00);
    END;

  PROCEDURE PERTJUP;  (* perturbations by Jupiter *)
    VAR I: INTEGER;
    BEGIN
      C[-1]:=COS(M5); S[-1]:=-SIN(M5);
      FOR I:=-1 DOWNTO -3 DO ADDTHE(C[I],S[I],C[-1],S[-1],C[I-1],S[I-1]);
      TERM(-1,-1,0,0.01,   0.07,     0.18, -0.02, 0.00,-0.02);
      TERM(0,-1,0,-0.31,   2.58,     0.52,  0.34, 0.02, 0.00);
      TERM(1,-1,0,-7.21,  -0.06,     0.13,-16.27, 0.00,-0.02);
      TERM(1,-2,0,-0.54,  -1.52,     3.09, -1.12, 0.01,-0.17);
      TERM(1,-3,0,-0.03,  -0.21,     0.38, -0.06, 0.00,-0.02);
      TERM(2,-1,0,-0.16,   0.05,    -0.18, -0.31, 0.01, 0.00);
      TERM(2,-2,0, 0.14,  -2.73,     9.23,  0.48, 0.00, 0.00);
      TERM(2,-3,0, 0.07,  -0.55,     1.83,  0.25, 0.01, 0.00);
      TERM(2,-4,0, 0.02,  -0.08,     0.25,  0.06, 0.00, 0.00);
      TERM(3,-2,0, 0.01,  -0.07,     0.16,  0.04, 0.00, 0.00);
      TERM(3,-3,0,-0.16,  -0.03,     0.08, -0.64, 0.00, 0.00);
      TERM(3,-4,0,-0.04,  -0.01,     0.03, -0.17, 0.00, 0.00);
    END;

  PROCEDURE PERTSAT;  (* perturbations by Saturn *)
    BEGIN
      C[-1]:=COS(M6); S[-1]:=-SIN(M6);
      ADDTHE(C[-1],S[-1],C[-1],S[-1],C[-2],S[-2]);
      TERM(0,-1,0, 0.00,   0.32,     0.01,  0.00, 0.00, 0.00);
      TERM(1,-1,0,-0.08,  -0.41,     0.97, -0.18, 0.00,-0.01);
      TERM(1,-2,0, 0.04,   0.10,    -0.23,  0.10, 0.00, 0.00);
      TERM(2,-2,0, 0.04,   0.10,    -0.35,  0.13, 0.00, 0.00);
    END;

  PROCEDURE PERTMOO;  (* difference between the Earth-Moon      *)
    BEGIN             (* barycenter and the center of the Earth *)
      DL := DL +  6.45*SIN(D) - 0.42*SIN(D-A) + 0.18*SIN(D+A)
                              + 0.17*SIN(D-M3) - 0.06*SIN(D+M3);
      DR := DR + 30.76*COS(D) - 3.06*COS(D-A)+ 0.85*COS(D+A)
                              - 0.58*COS(D+M3) + 0.57*COS(D-M3);
      DB := DB + 0.576*SIN(UU);
    END;

  BEGIN  (* SUN200 *)

    DL:=0.0; DR:=0.0; DB:=0.0;
    M2:=P2*FRAC(0.1387306+162.5485917*T);
    M3:=P2*FRAC(0.9931266+99.9973604*T);
    M4:=P2*FRAC(0.0543250+ 53.1666028*T);
    M5:=P2*FRAC(0.0551750+ 8.4293972*T);
    M6:=P2*FRAC(0.8816500+  3.3938722*T); D :=P2*FRAC(0.8274+1236.8531*T);
    A :=P2*FRAC(0.3749+1325.5524*T);      UU:=P2*FRAC(0.2591+1342.2278*T);
    C3[0]:=1.0;     S3[0]:=0.0;
    C3[1]:=COS(M3); S3[1]:=SIN(M3);  C3[-1]:=C3[1]; S3[-1]:=-S3[1];
    FOR I:=2 TO 7 DO ADDTHE(C3[I-1],S3[I-1],C3[1],S3[1],C3[I],S3[I]);
    PERTVEN; PERTMAR; PERTJUP; PERTSAT; PERTMOO;
    DL:=DL + 6.40*SIN(P2*(0.6983+0.0561*T))+1.87*SIN(P2*(0.5764+0.4174*T))
           + 0.27*SIN(P2*(0.4189+0.3306*T))+0.20*SIN(P2*(0.3581+2.4814*T));
    L:= 360.0*FRAC(0.7859453 + M3/P2 + ((6191.2+1.1*T)*T+DL)/1296.0E3 );
    R:= 1.0001398 - 0.0000007*T  +  DR*1E-6;
    B:= DB/3600.0;

  END;   (* SUN200 *)

(*-----------------------------------------------------------------------*)
(* CART: conversion of polar coordinates (r,theta,phi)                   *)
(*       into cartesian coordinates (x,y,z)                              *)
(*       (theta in [-90 deg,+90 deg]; phi in [-360 deg,+360 deg])        *)
(*-----------------------------------------------------------------------*)
PROCEDURE CART(R,THETA,PHI: double; VAR X,Y,Z: double);
  VAR RCST : double;
  BEGIN
    RCST := R*CS(THETA);
    X    := RCST*CS(PHI); Y := RCST*SN(PHI); Z := R*SN(THETA)
  END;


(*-----------------------------------------------------------------------*)
(* GAUSVEC: calculation of the Gaussian vectors (P,Q,R) from             *)
(*          ecliptic orbital elements:                                   *)
(*          LAN = longitude of the ascending node                        *)
(*          INC = inclination                                            *)
(*          AOP = argument of perihelion                                 *)
(*-----------------------------------------------------------------------*)
PROCEDURE GAUSVEC(LAN,INC,AOP:double;VAR PQR:double33);
  VAR C1,S1,C2,S2,C3,S3: double;
  BEGIN
    C1:=CS(AOP);  C2:=CS(INC);  C3:=CS(LAN);
    S1:=SN(AOP);  S2:=SN(INC);  S3:=SN(LAN);
    PQR[1,1]:=+C1*C3-S1*C2*S3; PQR[1,2]:=-S1*C3-C1*C2*S3; PQR[1,3]:=+S2*S3;
    PQR[2,1]:=+C1*S3+S1*C2*C3; PQR[2,2]:=-S1*S3+C1*C2*C3; PQR[2,3]:=-S2*C3;
    PQR[3,1]:=+S1*S2;          PQR[3,2]:=+C1*S2;          PQR[3,3]:=+C2;
  END;


(*-----------------------------------------------------------------------*)
(* ORBECL: transformation of coordinates XX,YY referred to the           *)
(*         orbital plane into ecliptic coordinates X,Y,Z using           *)
(*         Gaussian vectors PQR                                          *)
(*-----------------------------------------------------------------------*)
PROCEDURE ORBECL(XX,YY:double;PQR:double33;VAR X,Y,Z:double);
  BEGIN
    X:=PQR[1,1]*XX+PQR[1,2]*YY;
    Y:=PQR[2,1]*XX+PQR[2,2]*YY;
    Z:=PQR[3,1]*XX+PQR[3,2]*YY;
  END;

(*-----------------------------------------------------------------------*)
(* HYPANOM: calculation of the eccentric anomaly H=HYPANOM(MH,ECC) from  *)
(*          mean anomaly MH and eccentricity ECC for                     *)
(*          hyperbolic orbits                                            *)
(*-----------------------------------------------------------------------*)
FUNCTION HYPANOM(MH,ECC:double):double;
  CONST EPS=1E-10; MAXIT=15;
  VAR   H,F,EXH,SINHH,COSHH: double;
        I                  : INTEGER;
  BEGIN
    H:=LN(2.0*ABS(MH)/ECC+1.8); IF (MH<0.0) THEN H:=-H;
    EXH:=EXP(H); SINHH:=0.5*(EXH-1.0/EXH); COSHH:=0.5*(EXH+1.0/EXH);
    F := ECC*SINHH-H-MH; I:=0;
    WHILE ( (ABS(F)>EPS*(1.0+ABS(H+MH))) AND (I<MAXIT) )  DO
      BEGIN
        H := H - F / (ECC*COSHH-1.0);
        EXH:=EXP(H); SINHH:=0.5*(EXH-1.0/EXH); COSHH:=0.5*(EXH+1.0/EXH);
        F := ECC*SINHH-H-MH; I:=I+1;
      END;
    HYPANOM:=H;
//    IF (I=MAXIT) THEN  {writeln(' convergence problems in HYPANOM');}
//                        mainwindow.statusbar1.Caption:=(naam2+' convergence problems in HYPANOM');
  END;



(*-----------------------------------------------------------------------*)
(* HYPERB: calculation of the position and velocity vector               *)
(*         for hyperbolic orbits                                         *)
(*                                                                       *)
(*   T0   time of perihelion passage             X,Y   position          *)
(*   T    time                                   VX,VY velocity          *)
(*   A    semimajor axis (arbitrary sign)                                *)
(*   ECC  eccentricity                                                   *)
(*   (T0,T in julian centuries since J2000)                              *)
(*-----------------------------------------------------------------------*)
PROCEDURE HYPERB(T0,T,A,ECC:double;VAR X,Y,VX,VY:double);
  CONST KGAUSS = 0.01720209895;
  VAR K,MH,H,EXH,COSHH,SINHH,RHO,FAC: double;
  BEGIN
    A   := ABS(A);
    K   := KGAUSS / SQRT(A);
    MH  := K*36525.0*(T-T0)/A;
    H   := HYPANOM(MH,ECC);
    EXH := EXP(H);   COSHH:=0.5*(EXH+1.0/EXH);  SINHH:=0.5*(EXH-1.0/EXH);
    FAC := SQRT((ECC+1.0)*(ECC-1.0));   RHO := ECC*COSHH-1.0;
    X   := A*(ECC-COSHH);  Y  := A*FAC*SINHH;
    VX  :=-K*SINHH/RHO;    VY := K*FAC*COSHH/RHO;
  END;


(*-----------------------------------------------------------------------*)
(* ECCANOM: calculation of the eccentric anomaly E=ECCANOM(MAN,ECC)      *)
(*          from the mean anomaly MAN and the eccentricity ECC.          *)
(*          (solution of Kepler's equation by Newton's method)           *)
(*          (E, MAN in degrees)                                          *)
(*-----------------------------------------------------------------------*)
FUNCTION ECCANOM(MAN,ECC:double):double;
  CONST PI=3.141592654; TWOPI=6.283185308; RAD=0.0174532925199433;
        EPS = 1E-11; MAXIT = 15;
  VAR M,E,F: double;
      I    : INTEGER;
  BEGIN
    M:=MAN/360.0;  M:=TWOPI*(M-TRUNC(M)); IF M<0 THEN M:=M+TWOPI;
    IF (ECC<0.8) THEN E:=M ELSE E:=PI;
    F := E - ECC*SIN(E) - M; I:=0;
    WHILE ( (ABS(F)>EPS) AND (I<MAXIT) ) DO
      BEGIN
        E := E - F / (1.0-ECC*COS(E));  F := E-ECC*SIN(E)-M; I:=I+1;
      END;
    ECCANOM:=E/RAD;
//    IF (I=MAXIT) THEN  {writeln(' convergence problems in ECCANOM');}
//                        mainwindow.statusbar1.Caption:=(naam2+' convergence problems in ECCANOM');
  END;
(*-----------------------------------------------------------------------*)
(*  STUMPFF: calculation of Stumpff's functions C1 = sin(E)/E ,          *)
(*           C2 = (1-cos(E))/(E**2) and C3 = (E-sin(E))/(E**3)           *)
(*           for argument E2=E**2                                        *)
(*           (E: eccentric anomaly in radian)                            *)
(*-----------------------------------------------------------------------*)
PROCEDURE STUMPFF(E2:double;VAR C1,C2,C3:double);
  CONST EPS=1E-12;
  VAR N,ADD: double;
  BEGIN
    C1:=0.0; C2:=0.0; C3:=0.0; ADD:=1.0; N:=1.0;
    REPEAT
      C1:=C1+ADD; ADD:=ADD/(2.0*N);
      C2:=C2+ADD; ADD:=ADD/(2.0*N+1.0);
      C3:=C3+ADD; ADD:=-E2*ADD; N:=N+1.0;
    UNTIL ABS(ADD)<EPS;
  END;



(*-----------------------------------------------------------------------*)
(* CUBR: cube root                                                       *)
(*-----------------------------------------------------------------------*)
FUNCTION CUBR(X:double):double;
  BEGIN
    IF (X=0.0)  THEN CUBR:=0.0  ELSE CUBR:=EXP(LN(X)/3.0)
  END;

(*-----------------------------------------------------------------------*)
(* PARAB: calculation of position and velocity for                       *)
(*        parabolic and near parabolic orbits according to Stumpff       *)
(*                                                                       *)
(*        T0   time of perihelion passage         X,Y    position        *)
(*        T    time                              VX,VY  velocity         *)
(*        Q    perihelion distance                                       *)
(*        ECC  eccentricity                                              *)
(*        (T0,T in julian centuries since J2000)                         *)
(*-----------------------------------------------------------------------*)
PROCEDURE PARAB(T0,T,Q,ECC:double;VAR X,Y,VX,VY:double);
  CONST EPS    = 1E-9;
        KGAUSS = 0.01720209895;
        MAXIT  = 15;
  VAR E2,E20,FAC,C1,C2,C3,K,TAU,A,U,U2: double;
      R: double;
      I: INTEGER;
  BEGIN
    E2:=0.0;  FAC:=0.5*ECC;  I:=0;
    K   := KGAUSS / SQRT(Q*(1.0+ECC));
    TAU := KGAUSS * 36525.0*(T-T0);
    REPEAT
      I:=I+1;
      E20:=E2;
      A:=1.5*SQRT(FAC/(Q*Q*Q))*TAU;  A:=CUBR(SQRT(A*A+1.0)+A);
      U:=A-1.0/A;  U2:=U*U;  E2:=U2*(1.0-ECC)/FAC;
      STUMPFF(E2,C1,C2,C3); FAC:=3.0*ECC*C3;
    UNTIL (ABS(E2-E20)<EPS)OR(I>MAXIT);
//    IF (I=MAXIT) THEN  {writeln(' convergence problems in PARAB');}
//                       mainwindow.statusbar1.Caption:=(naam2+' convergence problems in PARAB');
    R :=Q*(1.0+U2*C2*ECC/FAC);
    X :=Q*(1.0-U2*C2/FAC);          VY:= K*(X/R+ECC);
    Y :=Q*SQRT((1.0+ECC)/FAC)*U*C1; VX:=-K*Y/R;
  END;

(*-----------------------------------------------------------------------*)
(* ELLIP: calculation of position and velocity vector                    *)
(*        for elliptic orbits                                            *)
(*                                                                       *)
(*        M    mean anomaly in degrees       X,Y    position   (in AU)   *)
(*        A    semimajor axis                VX,VY  velocity (in AU/day) *)
(*        ECC  eccentricity                                              *)
(*-----------------------------------------------------------------------*)
PROCEDURE ELLIP(M,A,ECC:double;VAR X,Y,VX,VY:double);
  CONST KGAUSS = 0.01720209895;
  VAR K,E,C,S,FAC,RHO: double;
  BEGIN

    K  := KGAUSS / SQRT(A);
    E  := ECCANOM(M,ECC);   C:=CS(E); S:=SN(E);
    FAC:= SQRT((1.0-ECC)*(1+ECC));  RHO:=1.0-ECC*C;
    X := A*(C-ECC); Y :=A*FAC*S;   VX:=-K*S/RHO;   VY:=K*FAC*C/RHO;
  END;


(*-----------------------------------------------------------------------*)
(* KEPLER: calculation of position and velocity for unperturbed          *)
(*         elliptic, parabolic and hyperbolic orbits                     *)
(*                                                                       *)
(*        T0   time of perihelion passage         X,Y,Z     position     *)
(*        T    time                               VX,VY,VZ  velocity     *)
(*        Q    perihelion distance                                       *)
(*        ECC  eccentricity                                              *)
(*        PQR  matrix of Gaussian vectors                                *)
(*        (T0,T in Julian centuries since J2000)                         *)
(*-----------------------------------------------------------------------*)
PROCEDURE KEPLER(T0,T,Q,ECC:double;PQR:double33;VAR X,Y,Z,VX,VY,VZ:double);
  CONST M0=5.0; EPS=0.1;
        KGAUSS = 0.01720209895; DEG = 57.29577951;
  VAR M,DELTA,TAU,INVAX,XX,YY,VVX,VVY: double;
  BEGIN
    DELTA := ABS(1.0-ECC);
    INVAX := DELTA / Q;
    TAU   := KGAUSS*36525.0*(T-T0);
    M     := DEG*TAU*SQRT(INVAX*INVAX*INVAX);
    IF ( (M<M0) AND (DELTA<EPS) )
      THEN  PARAB(T0,T,Q,ECC,XX,YY,VVX,VVY)
      ELSE IF (ECC<1.0)
             THEN ELLIP (M,1.0/INVAX,ECC,XX,YY,VVX,VVY)
             ELSE HYPERB(T0,T,1.0/INVAX,ECC,XX,YY,VVX,VVY);
    ORBECL(XX,YY,PQR,X,Y,Z); ORBECL(VVX,VVY,PQR,VX,VY,VZ);
  END;
(*--------------------------------------------------------------------------*)

(*-----------------------------------------------------------------------*)
(* POLAR2: conversion of cartesian coordinates (x,y,z)                    *)
(*        into polar coordinates (r,theta,phi)                           *)
(*        (theta in [-pi/2 deg,+pi/2]; phi in [0 ,+ 2*pi radians]        *)
(*-----------------------------------------------------------------------*)
PROCEDURE POLAR2(X,Y,Z:double;VAR R,THETA,PHI:double);
  VAR RHO: double;
  BEGIN
    RHO:=X*X+Y*Y;  R:=SQRT(RHO+Z*Z);
    PHI:=arctan2(Y,X); IF PHI<0 THEN PHI:=PHI+2*pi;
    RHO:=SQRT(RHO); THETA:=arctan2(Z,RHO);
  END;


(*-----------------------------------------------------------------------*)
(* ECLEQU: Conversion of ecliptic into equatorial coordinates            *)
(*         (T: equinox in Julian centuries since J2000)                  *)
(*-----------------------------------------------------------------------*)
PROCEDURE ECLEQU(T:double;VAR X,Y,Z:double);
  VAR EPS,C,S,V: double;
  BEGIN
    EPS:=23.43929111-(46.8150+(0.00059-0.001813*T)*T)*T/3600.0;
    C:=CS(EPS);  S:=SN(EPS);
    V:=+C*Y-S*Z;  Z:=+S*Y+C*Z;  Y:=V;
  END;
(*-----------------------------------------------------------------------*)
(* PMATECL: calculates the precession matrix A[i,j] for                  *)
(*          transforming ecliptic coordinates from equinox T1 to T2      *)
(*          ( T=(JD-2451545.0)/36525 )                                   *)
(*-----------------------------------------------------------------------*)
PROCEDURE PMATECL(T1,T2:double;VAR A: double33);
  CONST SEC=3600.0;
  VAR DT,PPI,PI,PA: double;
      C1,S1,C2,S2,C3,S3: double;
  BEGIN
    DT:=T2-T1;
    PPI := 174.876383889 +( ((3289.4789+0.60622*T1)*T1) +
              ((-869.8089-0.50491*T1) + 0.03536*DT)*DT )/SEC;
    PI  := ( (47.0029-(0.06603-0.000598*T1)*T1)+
             ((-0.03302+0.000598*T1)+0.000060*DT)*DT )*DT/SEC;
    PA  := ( (5029.0966+(2.22226-0.000042*T1)*T1)+
             ((1.11113-0.000042*T1)-0.000006*DT)*DT )*DT/SEC;
    C1:=CS(PPI+PA);  C2:=CS(PI);  C3:=CS(PPI);
    S1:=SN(PPI+PA);  S2:=SN(PI);  S3:=SN(PPI);
    A[1,1]:=+C1*C3+S1*C2*S3; A[1,2]:=+C1*S3-S1*C2*C3; A[1,3]:=-S1*S2;
    A[2,1]:=+S1*C3-C1*C2*S3; A[2,2]:=+S1*S3+C1*C2*C3; A[2,3]:=+C1*S2;
    A[3,1]:=+S2*S3;          A[3,2]:=-S2*C3;          A[3,3]:=+C2;
  END;
(*---------------------------------------------------------------------------*)
(* PMATEQU: Berechnung der Praezessionsmatrix A[i,j] fuer                    *)
(*          aequatoriale Koordinaten vom Aequinoktium T1 nach T2             *)
(*          ( T=(JD-2451545.0)/36525 )                                       *)
(*---------------------------------------------------------------------------*)
PROCEDURE PMATEQU(T1,T2:double; var a:double33);
  CONST SEC=3600.0;
  VAR DT,ZETA,Z,THETA: double;
      C1,S1,C2,S2,C3,S3: double;
  BEGIN
   DT:=T2-T1;
    ZETA  :=  ( (2306.2181+(1.39656-0.000139*T1)*T1)+
                ((0.30188-0.000345*T1)+0.017998*DT)*DT )*DT/SEC;
    Z     :=  ZETA + ( (0.79280+0.000411*T1)+0.000205*DT)*DT*DT/SEC;
    THETA :=  ( (2004.3109-(0.85330+0.000217*T1)*T1)-
                ((0.42665+0.000217*T1)+0.041833*DT)*DT )*DT/SEC;
    C1:=CS(Z);  C2:=CS(THETA);  C3:=CS(ZETA);
    S1:=SN(Z);  S2:=SN(THETA);  S3:=SN(ZETA);
    A[1,1]:=-S1*S3+C1*C2*C3; A[1,2]:=-S1*C3-C1*C2*S3; A[1,3]:=-C1*S2;
    A[2,1]:=+C1*S3+S1*C2*C3; A[2,2]:=+C1*C3-S1*C2*S3; A[2,3]:=-S1*S2;
    A[3,1]:=+S2*C3;          A[3,2]:=-S2*S3;          A[3,3]:=+C2;
  END;

(*-----------------------------------------------------------------------*)
(* PRECART: calculate change of coordinates due to precession            *)
(*          for given transformation matrix A[i,j]                       *)
(*          (to be used with PMATECL und PMATEQU)                        *)
(*-----------------------------------------------------------------------*)
PROCEDURE PRECART(A:double33;VAR X,Y,Z:double);
  VAR U,V,W: double;
  BEGIN
    U := A[1,1]*X+A[1,2]*Y+A[1,3]*Z;
    V := A[2,1]*X+A[2,2]*Y+A[2,3]*Z;
    W := A[3,1]*X+A[3,2]*Y+A[3,3]*Z;
    X:=U; Y:=V; Z:=W;
  END;

PROCEDURE PARALLAX_XYZ(WTIME,latitude : double;var X,Y,Z: double); { {X,Y,Z in AU,  By Han Kleijn}
{wtime= Sidereal time at greenwich - longitude, equals azimuth position of the sky for the observer.
{ wtime:=limit_radialen((-longitude*pi/180)+siderealtime2000 +(julian-2451545 )* earth_angular_velocity,2*pi);
{ siderealtime2000=(280.46061837-90)*pi/180       earth_angular_velocity=pi*2*1.00273790935}
{see also new meeus page 78}
{parallax can be 8.8 arcsec  per au distance. }
var
    sin_latitude_corrected,
    cos_latitude_corrected,
    height_above_sea,
    flatteningearth,
    x_observ,y_observ,z_observ,u :double;

Begin
  height_above_sea:=100;{meters}
  flatteningearth:=0.99664719; {earth is not perfect round}

  u:=arctan(flatteningearth*sin(latitude)/cos(latitude)); {tan:=sin/cos}
  sin_latitude_corrected:=flatteningearth*sin(u)+height_above_sea*sin(latitude)/6378140;
  cos_latitude_corrected:=cos(u)+height_above_sea*cos(latitude)/6378140;
  {above values are very close to sin(latitude) and cos(latitude)}

  X_observ := (6378.14/AE)*cos_latitude_corrected * COS(wtime);
  Y_observ := (6378.14/AE)*cos_latitude_corrected * SIN(wtime);
  Z_observ := (6378.14/AE)*sin_latitude_corrected;
  X:=X-X_observ; Y:=Y-Y_observ; Z:=Z-Z_observ;
end;

(*-----------------------------------------------------------------------*)
(* MJD: Modified Julian Date                                             *)
(*      The routine is valid for any date since 4713 BC.                 *)
(*      Julian calendar is used up to 1582 October 4,                    *)
(*      Gregorian calendar is used from 1582 October 15 onwards.         *)
(*-----------------------------------------------------------------------*)
FUNCTION MJD(DAY,MONTH,YEAR:INTEGER;HOUR:double):double;
  VAR A: double; B: INTEGER;
  BEGIN
    A:=10000.0*YEAR+100.0*MONTH+DAY;
    IF (MONTH<=2) THEN BEGIN MONTH:=MONTH+12; YEAR:=YEAR-1 END;
    IF (A<=15821004.1)
      THEN B:=-2+TRUNC((YEAR+4716)/4)-1179
      ELSE B:=TRUNC(YEAR/400)-TRUNC(YEAR/100)+TRUNC(YEAR/4);
    A:=365.0*YEAR-679004.0;
    MJD:=A+B+TRUNC(30.6001*(MONTH+1))+DAY+HOUR/24.0;
  END;


PROCEDURE COMET(sun:boolean;equinox:INTEGER;julian:double;year,month:integer;d,ecc,q,inc2,lan,aop,teqx0:double;
                var RA,DEC,DELTA,sun_delta:double);
{sun calculate sun or uses values from call to planet(0 ....)}
{equinox  on which basis e.g 2000}
{julian   julian date                                         }
{year, month, d, e,q,q,inc2,lan,aop,teqx0   comet parameters  }
{output:  ra,dec calculated coordinates   }
{         delta0 distance in au           }
{                      }
var
   A,AS2,PQR :double33; {array[1..3,1..3]}
   {VX,VY,VZ,}fac,t0,delta0 :double;
BEGIN (* COMET *)
{ YEAR:=1986;
{ MONTH:=2;
{ D:=9.43867;
{ Q:= 0.5870992;{    ! Perihelion distance q in AU;}
{ ECC:= 0.9672725;{  ! Eccentricity e}
{ INC2:= 162.23932;{ ! Inclination i}
{ LAN:= 58.14397; {  ! Longitude of the ascending node}
{ AOP:= 111.84658;{  ! Argument of perihelion}
{ TEQX0:=1950.0;{    ! Equinox for the orbital elements}


  T:=(julian-2400000.5-51544.5)/36525.0;{calculate time}

  DAY:=TRUNC(D); HOUR:=24.0*(D-DAY);
  T0 := ( MJD(DAY,MONTH,YEAR,HOUR) - 51544.5) / 36525.0;
  TEQX0 := (TEQX0-2000.0)/100.0;
  GAUSVEC(LAN,INC2,AOP,PQR);
  TEQX := (equinox-2000.0)/100.0;

  (* ecliptic coordinates of the sun, equinox TEQX        *)
  if sun=false then   {position sun already calculated for this time}
  begin
    SUN200 (T,LS,BS,RS);
    CART (RS,BS,LS,XS,YS,ZS);{sun heliocentric ecliptic coordinates equinox date=T}
    sun200_calculated:=true;
  end;

  (* heliocentric ecliptic coordinates of the comet       *)
  KEPLER (T0,T,Q,ECC,PQR,X_pln,Y_pln,Z_pln,VX,VY,VZ);
  PMATECL (TEQX0,T,A);    (* calculate precession matrix         *){for comet to ecliptic equinox T}
  PRECART (A,X_pln,Y_pln,Z_pln);  PRECART (A,VX,VY,VZ); { POLAR (X,Y,Z,R,B,L);}

  sun_DELTA := SQRT ( X_pln*X_pln + Y_pln*Y_pln + Z_pln*Z_pln );
  xa:=x_pln; ya:=y_pln; za:=z_pln;{helio centric position comets, equinox of date for function illuminate later and also comet velocity calculation}

  (* geometric geocentric coordinates of the comet        *)
  X_pln:=X_pln+XS;  Y_pln:=Y_pln+YS;   Z_pln:=Z_pln+ZS;    DELTA0 := SQRT ( X_pln*X_pln + Y_pln*Y_pln + Z_pln*Z_pln );

  (* first order correction for light travel time         *)

  FAC:=0.00578*DELTA0;  X_pln:=X_pln-FAC*VX;   Y_pln:=Y_pln-FAC*VY;   Z_pln:=Z_pln-FAC*VZ;

  ECLEQU (T,X_pln,Y_pln,Z_pln);{convert ecliptic equinox t  to equatorial equinox t}

  PARALLAX_XYZ(wtime2actual,site_lat_radians,X_pln,Y_pln,Z_pln);{correct parallax  in correct equinox. X, Y, Z in AE}

  PMATEQU (T,TEQX,AS2);{prepare equinox t to desired teqx}
  PRECART (AS2,X_pln,Y_pln,Z_pln); {change equinox}

  POLAR2(X_pln,Y_pln,Z_pln ,DELTA,DEC,RA);{radialen polar2}
END;



PROCEDURE ILLUM2( X,Y,Z, XE,YE,ZE: double; VAR R_SP,R_EP,ELONG,PHI,phase: double);

  VAR   XP,YP,ZP, RE, C_PHI : double;

  BEGIN
    (* Compute the planet's geocentric position *)

    XP:=X-XE; YP:=Y-YE; ZP:=Z-ZE;

    (* Compute the distances in the Sun-Earth-planet triangle *)

    R_SP:= SQRT (  X*X  +  Y*Y  +  Z*Z  ); (* Entfernung Sonne-Planet *)
    RE  := SQRT ( XE*XE + YE*YE + ZE*ZE );   (* Entfernung Sonne-Erde   *)
    R_EP:= SQRT ( XP*XP + YP*YP + ZP*ZP );   (* Entfernung Erde-Planet  *)

    (* Berechnung von Elongation, Phasenwinkel und Phase *)

    ELONG := ACS ( ( R_EP*R_EP + RE*RE - R_SP*R_SP ) / ( 2.0*R_EP*RE ) );

    C_PHI := ( R_EP*R_EP + R_SP*R_SP - RE*RE ) / ( 2.0*R_EP*R_SP ) ;
    PHI   := ACS ( C_PHI );   {phasewinkel}
    phase := 100*0.5*(1.0+C_PHI); {0..100}
  END;


function illum_comet : double ; { Get phase angle comet. Only valid is comet routine is called first.}
var
    R_SP,R_EP,elong,phi1,phase1 :double;
begin
  illum2(xa,ya,za,-xs,-ys,-zs, R_SP,R_EP,elong,phi1, phase1 );{ xa is heliocentric asteriod}
                             { -xs helio centric earth, calculated from sun200}
  illum_comet:=phi1*pi/180;
end;

Function asteroid_magn_comp(g ,b :double):double; {Magnitude change by phase asteroid, New meeus 32.14} {han.k}
      {g = slope parameter,  b= angle sun-asteroid-earth}
var b2,q1,q2 :double;
begin
  b2:=sin(b*0.5)/cos(b*0.5); {tan is sin/cos}
  q1:=EXP(-3.33*EXP(0.63*LN(b2+0.00000001))); {power :=EXP(tweedevar*LN(eerstevar))}
  q2:=EXP(-1.87*EXP(1.22*LN(b2+0.00000001)));
  asteroid_magn_comp:= -2.5*ln( (1-g)*q1  + g*q2 )/ln(10);
end;


//A brief header is given below:
//Des'n     H     G   Epoch     M        Peri.(w)  Node(ohm)    Incl.       e            n           a        Reference #Obs #Opp    Arc    rms  Perts   Computer
//----------------------------------------------------------------------------------------------------------------------------------------------------------------
//00001    3.4   0.15 K205V 162.68631   73.73161   80.28698   10.58862  0.0775571  0.21406009   2.7676569  0 MPO492748  6751 115 1801-2019 0.60 M-v 30h Williams   0000      (1) Ceres              20190915
//00002    4.2   0.15 K205V 144.97567  310.20237  173.02474   34.83293  0.2299723  0.21334458   2.7738415  0 MPO492748  8027 109 1821-2019 0.58 M-v 28h Williams   0000      (2) Pallas             20190812
//00003    5.2   0.15 K205V 125.43538  248.06618  169.85147   12.99105  0.2569364  0.22612870   2.6682853  0 MPO525910  7020 106 1821-2020 0.59 M-v 38h Williams   0000      (3) Juno               20200109
//00004    3.0   0.15 K205V 204.32771  150.87483  103.80908    7.14190  0.0885158  0.27150657   2.3620141  0 MPO525910  6941 102 1821-2019 0.60 M-p 18h Williams   0000      (4) Vesta              20191229
//00005    6.9   0.15 K205V  17.84635  358.64840  141.57102    5.36742  0.1909134  0.23866119   2.5740373  0 MPO525910  2784  77 1845-2020 0.53 M-v 38h Williams   0000      (5) Astraea            20200105
//00006    5.7   0.15 K205V 190.68653  239.73624  138.64343   14.73966  0.2032188  0.26107303   2.4245327  0 MPO525910  5745  90 1848-2020 0.53 M-v 38h Williams   0007      (6) Hebe               20200110

//; Readable designation       yyyymmdd.ddd    e         a [ae]       i        ohm        w   Equinox M-anomaly  H     G
//;--------------------------------------------------------------------------------------------------------------------------
//     (1) Ceres              |20200531.000|0.0775571|  2.7676569| 10.58862| 80.28698| 73.73161|2000|162.68631| 3.4 | 0.15|J1


function strtofloat(st: string) : double; {han.k}
var
  error2 : integer;
begin

  val(st,result,error2);
end;

Function  limit_radialen(z,range:double):double; {han.k}
begin
  {range should be 2*pi or 24 hours}
  z:=range*frac(z/(range));{quick method for big numbers}
  while z<0 do z:=z+range;
  limit_radialen:=z;
end;



function deltaT_calc(jd: double) : double; {in seconds} {han.k}
var
   year   : integer;
   y,u,t  : double;
begin
  y:=(2000 +(JD-2451544.5)/365.25);
  year:=round(y);


  if ((year>=2016) and (year<=2020)) then
  begin
    t:=y-2016;
    result:=(68.3+t*0.54);{seconds}  // (71-68.3)/5 = 0.54
  end
  else
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
    //result:=(-20+32*u*u-0.5628*t);{seconds}
  end
  else
  if ((year>=2150) and (year<=2999)) then
  begin        // End of Espenak range
    u:=(y-1820)/100;
    result:=(-20+32*u*u);{seconds}
  end
  else
  result:=0;

  result:=result/(24*3600);{convert results to days}
end;
procedure convert_MPCORB_line(txt : string; var desn,name: string; var H,G,yy,mm,dd,M,Peri,Node,a_incl,a_ecc,a_a: double); {han.k}
var
  code2           : integer;
  date_regel      : STRING[5];
  centuryA,monthA,dayA:string[2];
begin
  desn:='';{assume failure}

  date_regel:=copy(txt,21,25-21+1); {21 -  25  a5     Epoch (in packed form, .0 TT), see http://www.minorplanetcenter.net/iau/info/MPOrbitFormat.html}
   //    date_regel:='J9611';
   //   1996 Jan. 1    = J9611
   //   1996 Jan. 10   = J961A
   //   1996 Sept.30   = J969U
   //   1996 Oct. 1    = J96A1
   //   2001 Oct. 22   = K01AM

  str(Ord(date_regel[1])-55:2,centuryA); // 'A'=65

  code2:=Ord(date_regel[4]);
  if code2<65 then code2:=code2-48 {1..9} else code2:=code2-55; {A..Z}
  monthA := Formatfloat('00', code2);{convert to string with 2 digits}

  code2:=Ord(date_regel[5]);
  if code2<65 then code2:=code2-48 {1..9} else code2:=code2-55; {A..Z}
  dayA := Formatfloat('00', code2); {convert to string with 2 digits}

  if ((centuryA='19') or (centuryA='20') or (centuryA='21')) then {do only data}
  begin
    name:=copy(txt,167,194-167+1);
    desn:=copy(txt,1,5);

    H:=strtofloat(copy(txt,8,12-8+1));   { 8 -  12  f5.2   Absolute magnitude, H}
    G:=strtofloat(copy(txt,14,19-14+1)); {14 -  19  f5.2   Slope parameter, G}

    yy:=strtofloat(centuryA+date_regel[2]+date_regel[3]);{epoch year}
    mm:=strtofloat(monthA);{epoch month}
    dd:=strtofloat(dayA);{epoch day}

    M:=strtofloat(copy(txt,27,35-27+1)); {27 -  35  f9.5   Mean anomaly at the epoch, in degrees}
    peri:=strtofloat(copy(txt,38,46-38+1)); {38 -  46  f9.5   Argument of perihelion, J2000.0 (degrees)}
    node:=strtofloat(copy(txt,49,57-49+1)); {49 -  57  f9.5   Longitude of the ascending node, J2000.0  (degrees)}
    a_incl:=strtofloat(copy(txt,60,68-60+1)); {60 -  68  f9.5   Inclination to the ecliptic, J2000.0 (degrees)}

    a_ecc:=strtofloat(copy(txt,71,79-71+1)); {71 -  79  f9.7   Orbital eccentricity}

    a_a:=strtofloat(copy(txt,93,103-93+1)); {93 - 103  f11.7  Semimajor axis (AU)}
  end;
end;

procedure plot_mpcorb(maxcount : integer;maxmag:double;add_annot :boolean) ;{read MPCORB.dat}{han.k}
const
   a_g : double =0.15;{asteroid_slope_factor}
   Gauss_gravitational_constant: double=0.01720209895*180/pi;

var txtf : textfile;
    count,fontsize            : integer;
    yy,mm,dd,a_h,a_anm,Peri,Node,a_incl,a_ecc,a_a,c_q, DELTA,sun_delta,degrees_to_perihelion,c_epochdelta,ra2,dec2,mag,phase,delta_t : double;
    SIN_dec_ref,COS_dec_ref          : double;
    desn,name,s, thetext:string;
    flip_horizontal, flip_vertical,form_existing, errordecode : boolean;

  procedure plot_asteroid;
  var
    fitsX,fitsY,dra,ddec, delta_ra,det,SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,hh : double;
    x,y,x2,y2,len                                                                           : integer;
  begin

   {5. Conversion (RA,DEC) -> (x,y)}
    sincos(dec2,SIN_dec_new,COS_dec_new);{sincos is faster then seperate sin and cos functions}
    delta_ra:=ra2-ra0;
    sincos(delta_ra,SIN_delta_ra,COS_delta_ra);
    HH := SIN_dec_new*sin_dec_ref + COS_dec_new*COS_dec_ref*COS_delta_ra;
    dRA := (COS_dec_new*SIN_delta_ra / HH)*180/pi;
    dDEC:= ((SIN_dec_new*COS_dec_ref - COS_dec_new*SIN_dec_ref*COS_delta_ra ) / HH)*180/pi;
    det:=CD2_2*CD1_1 - CD1_2*CD2_1;
    fitsX:= +crpix1 - (CD1_2*dDEC - CD2_2*dRA) / det; {1..width2}
    fitsY:= +crpix2 + (CD1_1*dDEC - CD2_1*dRA) / det; {1..height2}


    x:=round(fitsX-1); {0..width2-1}
    y:=round(fitsY-1); {0..height2-1}

    if ((x>-50) and (x<=width2+50) and (y>-50) and (y<=height2+50)) then {within image1 with some overlap}
    begin
      {annotate}
       if flip_horizontal then x2:=(width2-1)-x else x2:=x;
       if flip_vertical   then y2:=y         else y2:=(height2-1)-y;

       len:=20;
       if showfullnames then thetext:=trim(name) else thetext:=trim(desn)+'('+floattostrF(mag,ffgeneral,3,1)+')';

       if add_annot then
       begin                         //floattostrF2(median_bottom_right,0,2)
          add_text ('ANNOTATE=',#39+floattostrF2(fitsX-len,0,2)+';'+floattostrF2(fitsY-len,0,2)+';'+floattostrF2(fitsX+len,0,2)+';'+floattostrF2(fitsY+len,0,2)+';-1;'{boldness}+thetext+';'+#39);
          annotated:=true;{header contains annotations}
       end
       else
       begin
         mainwindow.image1.Canvas.textout(x2+len,y2,thetext);
         mainwindow.image1.canvas.ellipse(x2-len,y2-len,x2+1+len,y2+1+len);{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
       end;
    end;
  end;

begin
  if fits_file=false then exit;
  if cd1_1=0 then begin memo2_message('Abort, first solve the image!');exit;end;

  flip_vertical:=mainwindow.Flipvertical1.Checked;
  flip_horizontal:=mainwindow.Fliphorizontal1.Checked;
  mainwindow.image1.Canvas.brush.Style:=bsClear;

  form_existing:=assigned(form_asteroids1);{form existing}

  mainwindow.image1.canvas.pen.color:=annotation_color;{color circel}
  mainwindow.image1.Canvas.font.color:=annotation_color;
  mainwindow.image1.Canvas.font.size:=12;

  if date_avg<>'' then
  begin
    date_to_jd(date_avg);{convert date-AVG to jd}
    midpoint:=true;
  end
  else
  begin
    date_to_jd(date_obs);{convert date-OBS to jd}
    midpoint:=false;
  end;

  if jd<=10 then {no date found}
  begin
    mainwindow.error_label1.caption:=('Error converting date-obs from FITS header');
    mainwindow.error_label1.visible:=true;
  end;

  if midpoint=false then
     jd:=jd-exposure/(2*24*3600);{sum julian days of images at midpoint exposure. Add half exposure in days to get midpoint}

  dec_text_to_radians(sitelat,site_lat_radians,errordecode);
  if errordecode then memo2_message('Warning observatory latitude not found in the fits header');

  ra_text_to_radians(sitelong,site_long_radians,errordecode);
  if errordecode then memo2_message('Warning observatory longitude not found in the fits header');

  delta_t:=deltaT_calc(jd); {calculate delta_T in days}

  wtime2actual:=limit_radialen((-site_long_radians)+siderealtime2000 +(jd-2451545 )* earth_angular_velocity,2*pi);
        {change by time & longitude in 0 ..pi*2, simular as siderial time}
        {2451545...for making dayofyear not to big, otherwise small errors occur in sin and cos}

  sun200_calculated:=false;
  count:=0;
  sincos(dec0,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}

  if add_annot then
         remove_key('ANNOTATE',true{all});{remove key annotate words from header}

  assignfile(txtf,mpcorb_path);
  try
    Reset(txtf);
    while ((not EOF(txtf)) and (count<maxcount) and (esc_pressed=false)) do   {loop}
    begin
      ReadLn(txtf, s);
      convert_MPCORB_line(s, {var} desn,name, a_h,a_g,yy,mm,dd,a_anm,Peri,Node,a_incl,a_ecc,a_a);
      if desn<>'' then {data line}
      begin
        try
         inc(count);

         {convert to comet elements}
         c_q := a_a * ( 1 - a_ecc); {semi-major axis (q)}

         {find days to nearest perihelion date}
         if a_anm>180 then degrees_to_perihelion:=360-a_anm {future perihelion is nearer}
                      else degrees_to_perihelion:=-a_anm;   {past perihelion is nearer}

          c_epochdelta:=degrees_to_perihelion /(Gauss_gravitational_constant /( a_a * sqrt( a_a ) ));{days to nearest perihelion date}

          comet(sun200_calculated,2000,jd+delta_t{delta_t in days},round(yy),round(mm),dd+c_epochdelta,a_ecc,c_q,a_incl,node,peri,2000,{var} ra2,dec2,delta,sun_delta);

          //if count<10 then memo2_message(desn+' '+prepare_ra(ra2,' ')+',   '+prepare_dec(dec2,' ') );


          mag:=a_h+ ln(delta*sun_delta)*5/ln(10);  {log(x) = ln(x)/ln(10)}

          phase:=illum_comet; { Get phase comet. Only valid is comet routine is called first.}
          mag:=mag+asteroid_magn_comp(a_g{asteroid_slope_factor},phase);

         {slope factor =0.15
          angle object-sun-earth of 0   => 0   magnitude
                                    5      0.42
                                   10      0.65
                                   15      0.83
                                   20      1}

          if mag<=maxmag then
          begin
             plot_asteroid;
          end;

          if frac(count/10000)=0 then
          begin
             if  form_existing then  form_asteroids1.caption:=inttostr(count);
            application.processmessages;{check for esc}
          end;
        except
        end;
      end;
    end;
  finally
    CloseFile(txtf);
  end;

  {write some info at bottom screen}

  if form_existing then
  begin
    with mainwindow do
    begin
      if add_date then
      begin
       fontsize:=20;
       image1.Canvas.font.size:=20;
       image1.Canvas.textout(round(fontsize),height2-round(2*fontsize),'Midpoint date: '+JdToDate(jd)+'    Position[α,δ]:   '+ra1.text+'      '+dec1.text);{}
      end;
    end;
    if add_annot then plot_annotations(0,0);{plot annotation from the header}
  end;

end;

{ Tform_asteroids1 }

function test_mpcorb : boolean;
begin
  if fileExists(form_asteroids1.mpcorb_path1.caption)=false then
  begin
    form_asteroids1.mpcorb_path1.Font.color:=clred;
    form_asteroids1.mpcorb_filedate1.caption:='Error, file MPCORB.DAT not found !!!';
    result:=false;
    exit;
  end
  else
  begin
    form_asteroids1.mpcorb_filedate1.caption:=DateTimeToStr(FileDateToDateTime(FileAge(form_asteroids1.mpcorb_path1.caption)));
    form_asteroids1.mpcorb_path1.font.color:=clgreen;
    result:=true;
  end;
end;

procedure Tform_asteroids1.annotate_asteroids1Click(Sender: TObject); {han.k}
var errordecode: boolean;
    maxcount : integer;
    maxmag   : double;
    Save_Cursor: TCursor;


begin
  if test_mpcorb=false then begin exit; end;{file not found}


  mpcorb_path:=form_asteroids1.mpcorb_path1.caption;

  date_avg:=date_obs1.Text;

  maxcount_asteroid:=max_nr_asteroids1.text;
  maxcount:=strtoint(form_asteroids1.max_nr_asteroids1.text);

  maxmag_asteroid:=max_magn_asteroids1.text;
  maxmag:=strtofloat2(form_asteroids1.max_magn_asteroids1.text);

  annotation_color:=ColorBox1.selected;

  showfullnames:=form_asteroids1.showfullnames1.checked;

  add_annotations:=form_asteroids1.add_annotations1.checked;

  add_date:=form_asteroids1.add_subtitle1.checked;

  {latitude, longitude}
  sitelat:=latitude1.Text;
  sitelong:=longitude1.Text;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  plot_mpcorb(maxcount,maxmag,add_annotations);
  Screen.Cursor:= Save_Cursor;

  form_asteroids1.close;   {normal this form is not loaded}
  mainwindow.setfocus;
end;

procedure Tform_asteroids1.cancel_button1Click(Sender: TObject); {han.k}
begin
  esc_pressed:=true;
  form_asteroids1.close;   {normal this form is not loaded}
  mainwindow.setfocus;
end;

procedure Tform_asteroids1.download_mpcorb1Click(Sender: TObject);
begin
  openurl('https://minorplanetcenter.net/iau/MPCORB.html');
end;

procedure Tform_asteroids1.file_to_add1Click(Sender: TObject); {han.k}
begin
  OpenDialog1.Title := 'Select MPCORB.DAT to use';
  OpenDialog1.Options := [ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := 'MPCORB.DAT file (*.DAT*)|*.dat;*.DAT';
  if opendialog1.execute then
  begin
    mpcorb_path1.caption:=OpenDialog1.Files[0];
    test_mpcorb;
  end;
end;

procedure Tform_asteroids1.FormKeyPress(Sender: TObject; var Key: char);{han.k}
begin
  if key=#27 then
  begin
    esc_pressed:=true;
  end;
end;

procedure Tform_asteroids1.FormShow(Sender: TObject);{han.k}
var
  errordecode: boolean;
begin
  esc_pressed:=false;{reset from cancel}

  mpcorb_path1.caption:=mpcorb_path;
  test_mpcorb;
  if date_avg<>'' then
  begin
     date_label1.caption:='DATE_AVG';
     date_obs1.Text:=date_avg;
     midpoint:=true;
  end
  else
  begin
    date_label1.caption:='DATE_OBS';
    date_obs1.Text:=date_obs;
    midpoint:=false;
  end;

  max_nr_asteroids1.text:=maxcount_asteroid;
  max_magn_asteroids1.text:=maxmag_asteroid;

  {latitude, longitude}
  latitude1.Text:=trim(sitelat); {copy the string to tedit}
  longitude1.Text:=trim(sitelong);


  showfullnames1.Checked:=showfullnames;
  add_annotations1.Checked:=add_annotations;

  form_asteroids1.add_subtitle1.checked:=add_date;

  ColorBox1.selected:=annotation_color;

end;



end.

