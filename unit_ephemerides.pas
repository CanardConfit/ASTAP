unit unit_ephemerides;

{*
*  These PASCAL routines where created by Han Kleijn. www.hnsky.org for the ASTAP program and are based on Fortran code from https://github.com/scottransom/pyslalib
*
*  Copyright (C) See each routine
*
*  License:
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330,
*    Boston, MA  02111-1307  USA
*
*-}




interface

uses
  Classes, SysUtils, math;

type
  U_array = array[1..13] of double;
  r6_array = array[1..6] of double;
  r3_array = array[1..3] of double;
  r3x3_array = array[1..3,1..3] of double;


procedure sla_EPV (DATE : double; out PH, VH{, PB, VB} : r3_array); //  J2000 heliocentric and barycentric Earth position and velocity. Light speed corrected.
procedure sla_PLANET(DATE : double;  NP: integer; out PV: r6_array; out JSTAT: integer); // J2000 heliocentric position and velocity of planets 1..8 based on original Simon et al Fortran code. Pluto removed.
procedure orbit(DATE : double; JFORM : integer; EPOCH : double; ORBINC, ANODE,PERIH, AORQ, E, AORL, DM : double; out PV :r6_array; out JSTAT : integer) ;//Heliocentric position and velocity of a planet, asteroid or comet
procedure precession3(JD0, JD1: double; var RA, DC : double); {precession}

{based on planet.f, planel.f, el2ue.f, ue2pv.f,pv2ue.f, epv.f, prec.f, dcs2c, dmxv.f, dcc2s.f}

implementation

function mod2(const a, b: double): double;
begin
  result:= a - b * Int(a / b);
end;


//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

{*+;
*     - - - - - -;
*      U E 2 P V;
*     - - - - - -;
*;
*  Heliocentric position and velocity of a planet, asteroid or comet,;
*  starting from orbital elements in the "universal variables" form.
*;
*  Given:;
*     DATE     d       date, Modified Julian Date (JD-2400000.5);
*;
*  Given and ed:;
*     U        d(13)   universal orbital elements (updated; Note 1);
*;
*       given    (1)   combined mass (M+m);
*         "      (2)   total energy of the orbit (alpha);
*         "      (3)   reference (osculating) epoch (t0);
*         "    (4-6)   position at reference epoch (r0);
*         "    (7-9)   velocity at reference epoch (v0);
*         "     (10)   heliocentric distance at reference epoch;
*         "     (11)   r0.v0;
*     ed  (12)   date (t);
*         "     (13)   universal eccentric anomaly (psi) of date;
*;
*  ed:;
*     PV       d(6)    position (AU) and velocity (AU/s);
*     JSTAT    i       status:  0 := OK;
*                              -1 := radius vector zero;
*                              -2 := failed to converge;
*;
*  Notes;
*;
*  1  The "universal" elements are those which define the orbit for the;
*     purposes of the method of universal variables (see reference).
*     They consist of the combined mass of the two bodies, an epoch,;
*     and the position and velocity vectors (arbitrary reference frame);
*     at that epoch.0  The parameter set used here;
*     quantities that can, in fact, be derived from the other;
*     information.  This approach is taken to avoiding unnecessary
*     computation and loss of accuracy.0  The supplementary quantities;
*     are (i) alpha, which is proportional to the total energy of the;
*     orbit, (ii) the heliocentric distance at epoch, (iii) the;
*     outwards component of the velocity at the given epoch, (iv) an;
*     estimate of psi, the "universal eccentric anomaly" at a given;
*     date and (v) that date.
*;
*  2  The companion routine is sla_EL2UE.0  This takes the conventional;
*     orbital elements and transforms them into the set of numbers;
*     needed by the present routine.0  A single prediction requires one;
*     one  to sla_EL2UE followed by one  to the present routine;;
*     for convenience, the two s are packaged as the routine;
*     sla_PLANEL.0  Multiple predictions may be made by again;
*     ing sla_EL2UE once, but then ing the present routine;
*     multiple times, which is faster than multiple s to sla_PLANEL.
*;
*     It is not obligatory to use sla_EL2UE to ob;
*     However, it should be noted that because sla_EL2UE performs its;
*     own validation, no checks on the contents of the array U are made;
*     by the present routine.
*;
*  3  DATE is the instant for which the prediction is required.0  It is;
*     in the TT timescale (formerly Ephemeris Time, ET) and is a;
*     Modified Julian Date (JD-2400000.5).
*;
*  4  The universal elements supplied in the array U are in canonical;
*     units (solar masses, AU and canonical days).0  The position and;
*     velocity are not sensitive to the choice of reference frame.0  The;
*     sla_EL2UE routine in fact produces coordinates with respect to the;
*     J2000 equator and equinox.
*;
// *  5  The algorithm was originally adapted from the EPHSLA program of
*     D.H.P.Jones (private communication, 1996).0  The method is based;
*     on Stumpff's Universal Variables.
*;
*  Reference:  Everhart, E.0 & Pitkin, E.T., Am.J.Phys.0 51, 712, 1983.
*;
*  P.T.Wallace   Starlink   22 October 2005;
*;
*  Copyright (C) 2005 Rutherford Appleton Laboratory;
*;
*  License:;
*     This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published b;
*    the Free Software Foundation; either version 2 of the License, or;
*    (at your option) any later version.
*;
*     This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of;
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.0  See the;
*    GNU General Public License for more details.
*;
*    You should have received a copy of the GNU General Public License;
*     along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330, ;
*    Boston, MA  02111-1307  USA;
*;
*-;
}

procedure sla_UE2PV (DATE : double; U : u_array; out PV :r6_array; out JSTAT :integer);

const
  //*  Gaussian gravitational constant (exact);
  GCON=0.01720209895;
  //*  Canonical days to seconds;
  CD2S=GCON/86400;
var

  //*  Test value for solution and maximum number of iterations;

  TEST:double=1E-13;
  NITMAX:integer=25;
  I,NIT,N: integer;
  R0, SIGMA0, T, PSI, DT, W,CM,ALPHA,T0: double;
  P0: array[0..3] of double;
  V0: array[1..3] of double;
  TOL,PSJ,PSJ2,BETA,S0,S1,S2,S3,FF,R,FLAST,PLAST,F,G,FD,GD : double;
begin
  // Unpack the parameters.;
  CM := U[1];
  ALPHA := U[2];
  T0 := U[3];
  for  I := 1 to 3  do begin
  P0[I] := U[I+3];
  V0[I] := U[I+6];
  end;
  R0 := U[10];
  SIGMA0 := U[11];
  T := U[12];
  PSI := U[13];
  //*  Approximately update the universal eccentric anomaly.
  PSI := PSI+(DATE-T)*GCON/R0;
  //*  Time from reference epoch to date (in Canonical Days: a canonical;
  //*  day is 58.1324409...0 days, defined as 1/GCON).
  DT := (DATE-T0)*GCON;
  //*  Refine the universal eccentric anomaly, psi.
  NIT := 1;
  W := 1;
  TOL := 0;
  while  ABS(W)> TOL do
  begin
  //*     Form half angles until BETA small enough.
    N := 0;
    PSJ := PSI;
    PSJ2 := PSJ*PSJ;
    BETA := ALPHA*PSJ2;
    while  ABS(BETA)>0.7  Do
    begin
      N := N+1;
      BETA := BETA/4;
      PSJ := PSJ/2;
      PSJ2 := PSJ2/4;
    end;
    //     Calculate Universal Variables S0,S1,S2,S3 by nested series.
    S3 := PSJ*PSJ2*((((((BETA/210+1)
                           *BETA/156+1)
                           *BETA/110+1)
                           *BETA/72+1)
                           *BETA/42+1)
                           *BETA/20+1)/6;
    S2 := PSJ2*((((((BETA/182+1)
                       *BETA/132+1)
                       *BETA/90+1)
                       *BETA/56+1)
                       *BETA/30+1)
                       *BETA/12+1)/2;
    S1 := PSJ+ALPHA*S3;
    S0 := 1+ALPHA*S2;
    //     Unfor   :=  to *     Undo the angle-halving.  do begin
    TOL := TEST;
    while  N>0 do
    begin
      S3 := 2*(S0*S3+PSJ*S2);
      S2 := 2*S1*S1;
      S1 := 2*S0*S1;
      S0 := 2*S0*S0-1;
      PSJ := PSJ+PSJ;
      TOL := TOL+TOL;
      N := N-1;
    end;
    //     Values of F and F' corresponding to the current value of psi;
    FF := R0*S1+SIGMA0*S2+CM*S3-DT;
    R := R0*S0+SIGMA0*S1+CM*S2;
    //     If first iteration, create dummy "last F".
    if ( NIT = 1) then  FLAST := FF;
    //     Check for sign change.
    if  FF*FLAST<0E0  then
    begin // Sign change:  get psi adjustment using secant method;
      W := FF*(PLAST-PSI)/(FLAST-FF);   {plast is set in a few lines further down}
    end
    else
    begin // No sign change:  use Newton-Raphson method instead;
      if (R = 0E0) then
      begin //  Null radius vector.
        JSTAT := -1;
        exit;
      end;
      W := FF/R;
    end;
    //     Save the last psi and F values.
    PLAST := PSI;
    FLAST := FF;
    //     Apply the Newton-Raphson or secant adjustment to psi.
    PSI := PSI-W;
    //     Next iteration, unless too many already.
    if (NIT > NITMAX) then
    begin  //  Failed to converge.
      JSTAT := -2;
      exit;
    end;

    NIT := NIT+1;
  end;  // DO WHILE (ABS(W).GE.TOL)


  //  Project the position and velocity vectors (scaling velocity to AU/s);
  W := CM*S2;
  F := 1-W/R0;
  G := DT-CM*S3;
  FD := -CM*S1/(R0*R);
  GD := 1-W/R;
  for  I := 1 to 3  do
  begin
    PV[I] := P0[I]*F+V0[I]*G;
    PV[I+3] := CD2S*(P0[I]*FD+V0[I]*GD);
  end;
  //   Update the parameters to allow speedy predicti;
  U[12] := DATE;
  U[13] := PSI;
  //  OK exit.
  JSTAT := 0;
  exit;
end;


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------



{*+;
*     - - - - - -;
*      P V 2 U E;
*     - - - - - -;
*;
*  Construct a universal element set based on an instantaneous position;
*  and velocity.
*;
*  Given:;
*     PV        d(6)   heliocentric x,y,z,xdot,ydot,zdot of date,;
*                      (AU,AU/s; Note 1);
*     DATE      d      date (TT Modified Julian Date := JD-2400000.5);
*     PMASS     d      mass of the planet (Sun:=1; Note 2);
*;
*  ed:;
*     U         d(13)  universal orbital elements (Note 3);
*;
*                 (1)  combined mass (M+m);
*                 (2)  total energy of the orbit (alpha);
*                 (3)  reference (osculating) epoch (t0);
*               (4-6)  position at reference epoch (r0);
*               (7-9)  velocity at reference epoch (v0);
*                (10)  heliocentric distance at reference epoch;
*                (11)  r0.v0;
*                (12)  date (t);
*                (13)  universal eccentric anomaly (psi) of date, approx;
*;
*     JSTAT     i      status:  0 := OK;
*                              -1 := illegal PMASS;
*                              -2 := too close to Sun;
*                              -3 := too slow;
*;
*  Notes;
*;
*  1  The PV 6-vector can be with respect to any chosen inertial frame,;
*     and the resulting universal-element set will be with respect to;

*     of epoch J2000.
*;
*  2  The mass, PMASS, is important only for the larger planets.0  For;
*     most purposes (e.g.0 asteroids) use 0.0  Values less than zero;
*     are illegal.
*;
*  3  The "universal" elements are those which define the orbit for the;
*     purposes of the method of universal variables (see reference).
*     They consist of the combined mass of the two bodies, an epoch,;
*     and the position and velocity vectors (arbitrary reference frame);
*     at that epoch.0  The parameter set used here;
*     quantities that can, in fact, be derived from the other;
*     information.  This approach is taken to avoiding unnecessary
*     computation and loss of accuracy.0  The supplementary quantities;
*     are (i) alpha, which is proportional to the total energy of the;
*     orbit, (ii) the heliocentric distance at epoch, (iii) the;
*     outwards component of the velocity at the given epoch, (iv) an;
*     estimate of psi, the "universal eccentric anomaly" at a given;
*     date and (v) that date.
*;
*  Reference:  Everhart, E.0 & Pitkin, E.T., Am.J.Phys.0 51, 712, 1983.
*;
*  P.T.Wallace   Starlink   18 March 1999;
*;
*  Copyright (C) 1999 Rutherford Appleton Laboratory;
*;
*  License:;
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published b;
*    the Free Software Foundation; either version 2 of the License, or;
*    (at your option) any later version.
*;
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of;
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.0  See the;
*    GNU General Public License for more details.
*;
*    You should have received a copy of the GNU General Public License;
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330, ;
*    Boston, MA  02111-1307  USA;
*;
*-;}

procedure sla_PV2UE (PV : r6_array; DATE,PMASS : double; out U : u_array; out JSTAT : integer);
const
//  Gaussian gravitational constant (exact);
  GCON=0.01720209895;
//  Canonical days to seconds;
  CD2S=GCON/86400;
//  Minimum allowed distance (AU) and speed (AU per canonical day);
  RMIN=1E-3;
  VMIN=1E-3;
var
  T0,CM,X,Y,Z,XD,YD,ZD,R,V2,V,ALPHA,RDV: double;

begin
  //  Reference epoch.
  T0 := DATE;
  //  Combined mass (mu:=M+m).
  if PMASS<0E0 then
  begin
    // Negative PMASS.
    JSTAT:=-1;
    exit;
  end;
  CM := 1+PMASS;
  // Unpack the state vector, expressing velocity in AU per canonical day.
  X := PV[1];
  Y := PV[2];
  Z := PV[3];
  XD := PV[4]/CD2S;
  YD := PV[5]/CD2S;
  ZD := PV[6]/CD2S;
  // Heliocentric distance, and speed.
  R := SQRT(X*X+Y*Y+Z*Z);
  V2 := XD*XD+YD*YD+ZD*ZD;
  V := SQRT(V2);
  //  Reject unreasonably small values.
  if (R<RMIN) then
  begin //Too close.
    JSTAT:=-2;
    exit;
  end;
  if (V<VMIN) then
  begin// Too slow.
    JSTAT:=-3;
    exit;
  end;
  //  Total energy of the orbit.
  ALPHA := V2-2*CM/R;
  //  Outward component of velocity.
  RDV := X*XD+Y*YD+Z*ZD;
  //  Construct the universal-element set.
  U[1] := CM;
  U[2] := ALPHA;
  U[3] := T0;
  U[4] := X;
  U[5] := Y;
  U[6] := Z;
  U[7] := XD;
  U[8] := YD;
  U[9] := ZD;
  U[10] := R;
  U[11] := RDV;
  U[12] := T0;
  U[13] := 0;

  JSTAT := 0;
  exit;
end;

//-----------------------------------------------------------------------------------------------------------------------------------------------
{*+;
*     - - - - - -;
*      E L 2 U E;
*     - - - - - -;
*;
*  Transform conventional osculating orbital elements into "universal";
*  form.
*;
*  Given:;
*     DATE    d      epoch (TT MJD) of osculation (Note 3);
*     JFORM   i      choice of element set (1-3, Note 6);
*     EPOCH   d      epoch (TT MJD) of the elements;
*     ORBINC  d      inclination (radians);
*     ANODE   d      longitude of the ascend;//
*     PERIH   d      longitude or argument of perihelion (radians);
*     AORQ    d      mean distance or perihelion distance (AU);
*     E       d      eccentricity;
*     AORL    d      mean anomaly or longitude (radians, JFORM:=1,2 only);
*     DM      d      daily motion (radians, JFORM:=1 only);
*;
*  ed:;
*     U       d(13)  universal orbital elements (Note 1);
*;
*               (1)  combined mass (M+m);
*               (2)  total energy of the orbit (alpha);
*               (3)  reference (osculating) epoch (t0);
*             (4-6)  position at reference epoch (r0);
*             (7-9)  velocity at reference epoch (v0);
*              (10)  heliocentric distance at reference epoch;
*              (11)  r0.v0;
*              (12)  date (t);
*              (13)  universal eccentric anomaly (psi) of date, approx;
*;
*     JSTAT   i      status:  0 := OK;
*                            -1 := illegal JFORM;
*                            -2 := illegal E;
*                            -3 := illegal AORQ;
*                            -4 := illegal DM;
*                            -5 := numerical error;
*;
*  ed:  sla_UE2PV, sla_PV2UE;
*;
*  Notes;
*;
*  1  The "universal" elements are those which define the orbit for the;
*     purposes of the method of universal variables (see reference).
*     They consist of the combined mass of the two bodies, an epoch,;
*     and the position and velocity vectors (arbitrary reference frame);
*     at that epoch.0  The parameter set used here;
*     quantities that can, in fact, be derived from the other;
*     information.  This approach is taken to avoiding unnecessary
*     computation and loss of accuracy.0  The supplementary quantities;
*     are (i) alpha, which is proportional to the total energy of the;
*     orbit, (ii) the heliocentric distance at epoch, (iii) the;
*     outwards component of the velocity at the given epoch, (iv) an;
*     estimate of psi, the "universal eccentric anomaly" at a given;
*     date and (v) that date.
*;
*  2  The companion routine is sla_UE2PV.0  This takes the set of numbers;
*     that the present routine outputs and uses them to derive the;
*     object's position and velocity.0  A single prediction requires one;
*      to the present routine followed by one  to sla_UE2PV;;
*     for convenience, the two s are packaged as the routine;
*     sla_PLANEL.0  Multiple predictions may be made by again ing the;
*     present routine once, but then ing sla_UE2PV multiple times,;
*     which is faster than multiple s to sla_PLANEL.
*;
*  3  DATE is the epoch of osculation.0  It is in the TT timescale;
*     (formerly Ephemeris Time, ET) and is a Modified Julian Date;
*     (JD-2400000.5).
*;
*  4  The supplied orbital elements are with respect to the J2000;
*     ecliptic and equinox.0  The position and vel;
*     ed in the array U are with respect to the mean equator and;
*     equinox of epoch J2000, and are for the perihelion prior to the;
*     specified epoch.
*;
*  5  The universal elements ed in the array U are in canonical;
*     units (solar masses, AU and canonical days).
*;
*  6  Three different element-format options are available:
*;
*     Option JFORM:=1, suitable for the major planets:;
*;
*     EPOCH  := epoch of elements (TT MJD);
*     ORBINC := inclination i (radians);
*     ANODE  = longitude of the ascend;//
*     PERIH  := longitude of perihelion, curly pi (radians);
*     AORQ   := mean distance, a (AU);
*     E      := eccentricity, e (range 0 to <1);
*     AORL   := mean longitude L (radians);
*     DM     := daily motion (radians);
*;
*     Option JFORM:=2, suitable for minor planets:;
*;
*     EPOCH  := epoch of elements (TT MJD);
*     ORBINC := inclination i (radians);
*     ANODE  = longitude of the ascend;//
*     PERIH  := argument of perihelion, little omega (radians);
*     AORQ   := mean distance, a (AU);
*     E      := eccentricity, e (range 0 to <1);
*     AORL   := mean anomaly M (radians);
*;
*     Option JFORM:=3, suitable for comets:;
*;
*     EPOCH  := epoch of perihelion (TT MJD);
*     ORBINC := inclination i (radians);
*     ANODE  = longitude of the ascend;//
*     PERIH  := argument of perihelion, little omega (radians);
*     AORQ   := perihelion distance, q (AU);
*     E      := eccentricity, e (range 0 to 10);
*;
*  7  Unused elements (DM for JFORM:=2, AORL and DM for JFORM:=3) are;
*     not accessed.
*;
// *  8  The algorithm was originally adapted from the EPHSLA program of
*     D.H.P.Jones (private communication, 1996).0  The method is based;
*     on Stumpff's Universal Variables.
*;
*  Reference:  Everhart & Pitkin, Am.J.Phys.0 51, 712 (1983).
*;
*  Last revision:   8 September 2005;
*;
*  Copyright P.T.Wallace.0  All rights reserved.
*;
*  License:;
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published b;
*    the Free Software Foundation; either version 2 of the License, or;
*    (at your option) any later version.
*;
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of;
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.0  See the;
*    GNU General Public License for more details.
*;
*    You should have received a copy of the GNU General Public License;
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330, ;
*    Boston, MA  02111-1307  USA;
*;
*-;
}

procedure sla_EL2UE (DATE : double; JFORM : integer; EPOCH : double; ORBINC, ANODE,PERIH, AORQ, E, AORL, DM : double; out U :U_array; out JSTAT : integer) ;

//  Gaussian gravitational constant (exact);
var
  GCON:double=0.01720209895;
  //  Sin and cos of J2000 mean obliquity (IAU 1976);
  SE:double=0.3977771559319137;
  CE:double=0.9174820620691818;
  J: integer;
  PHT,ARGPH,Q,W,CM,ALPHA,PHS,SW,CW,SI,CI,SO,CO,X,Y,Z,PX,PY,PZ,VX,VY,VZ,DT,FC,FP,PSI: double;
  UL : U_array;
  PV : r6_array;

begin
//  Validate arguments.
if ((JFORM<1) or (JFORM > 3)) then
begin
  JSTAT := -1;
  exit;
end;
if ((E<0E0) or (E > 10E0) or ((E>=1E0) and (JFORM<>3))) then
begin
  JSTAT := -2;
  exit;
end;
if (AORQ<=0E0) then
begin
  JSTAT := -3;
  exit;
end;
if ((JFORM = 1) and (DM<=0E0)) then
begin
  JSTAT := -4;
  exit;
end;
//;
//  Transform elements into standard form:;
//;
//  PHT   := epoch of perihelion passage;
//*  ARGPH := argument of perihelion (little omega);
//*  Q     := perihelion distance (q);
//*  CM    := combined mass, M+m (mu);
if (JFORM = 1) then
begin
//*     Major planet.;
  PHT := EPOCH-(AORL-PERIH)/DM;
  ARGPH := PERIH-ANODE;
  Q := AORQ*(1-E);
  W := DM/GCON;
  CM := W*W*AORQ*AORQ*AORQ;
  end
  else
  if (JFORM = 2) then
  begin
    //     Minor planet.;
    PHT := EPOCH-AORL*SQRT(AORQ*AORQ*AORQ)/GCON;
    ARGPH := PERIH;
    Q := AORQ*(1-E);
    CM := 1;
  end
  else
  begin
  //*     Comet.;
    PHT := EPOCH;
    ARGPH := PERIH;
    Q := AORQ;
    CM := 1;
  end;
  //*  The universal variable alpha.  This is proportional to the total;
  //*  energy of the orbit:  -ve for an ellipse, zero for a parabola,;
  //*  +ve for a hyperbola.;
  ALPHA := CM*(E-1)/Q;
  //  Speed at perihelion.;
  PHS := SQRT(ALPHA+2*CM/Q);
  {*  In a Cartesian coordinate system which has the x-axis pointing;
   *  to perihelion and the z-axis normal to the orbit (such that the;
   *  object orbits counter-clockwise as seen from +ve z), the;
   *  perihelion position and velocity vectors are:;
   *;
   *    position   [Q,0,0];
   *    velocity   [0,PHS,0];
   *;
   *  To express the results in J2000 equatorial coordinates we make a;
   *  series of four rotations of the Cartesian axes:;
   *;
   *           axis      Euler angle;
   *;
   *     1      z        argument of perihelion (little omega);
   *     2      x        inclination (i);
   *     3      z        longitude of the ascend;//
   *     4      x        J2000 obliquity (epsilon);
   *;
   *  In each case the rotation is clockwise as seen from the +ve end;//
   *  the axis concerned.;
   *  Functions of the Euler angles.;}
  SW := SIN(ARGPH);
  CW := COS(ARGPH);
  SI := SIN(ORBINC);
  CI := COS(ORBINC);
  SO := SIN(ANODE);
  CO := COS(ANODE);
  //  Position at perihelion (AU).;
  X := Q*CW;
  Y := Q*SW;
  Z := Y*SI;
  Y := Y*CI;
  PX := X*CO-Y*SO;
  Y := X*SO+Y*CO;
  PY := Y*CE-Z*SE;
  PZ := Y*SE+Z*CE;
  //  Velocity at perihelion (AU per canonical day).;
  X := -PHS*SW;
  Y := PHS*CW;
  Z := Y*SI;
  Y := Y*CI;
  VX := X*CO-Y*SO;
  Y := X*SO+Y*CO;
  VY := Y*CE-Z*SE;
  VZ := Y*SE+Z*CE;
  //  Time from perihelion to date (in Canonical Days: a canonical day;
  //  is 58.1324409...0 days, defined as 1/GCON).
  DT := (DATE-PHT)*GCON;
  //*  First approximation to the Universal Eccentric Anomaly, PSI,;
  //*  based on the circle (FC) and parabola (FP) values.;
  FC := DT/Q;
  W := power((3*DT+SQRT(9*DT*DT+8*Q*Q*Q)),(1/3));
  FP := W-2*Q/W;
  PSI := (1-E)*FC+E*FP;
  //  Assemble local copy of element set.;
  UL[1] := CM;
  UL[2] := ALPHA;
  UL[3] := PHT;
  UL[4] := PX;
  UL[5] := PY;
  UL[6] := PZ;
  UL[7] := VX;
  UL[8] := VY;
  UL[9] := VZ;
  UL[10] := Q;
  UL[11] := 0;
  UL[12] := DATE;
  UL[13] := PSI;

  //*  Predict position+velocity at epoch of osculation.;
  sla_UE2PV(DATE,UL,PV,J);
  if (J<>0) then
  begin
    JSTAT:= -5;
    exit;
  end;

  //  Convert back to universal elements.
  sla_PV2UE(PV,DATE,CM-1,U,J);
  if (J<>0) then
  begin
    JSTAT:= -5;
    exit;
  end;

  JSTAT := 0;
end;

//-----------------------------------------------------------------------------------------------------------------------------------------------









{
*     - - - - - - -;
*      P L A N E L;
*     - - - - - - -;
*;
*  Heliocentric position and velocity of a planet, asteroid or comet,;
*  starting from orbital elements.0;
*;
*  Given:;
*     DATE     d     date, Modified Julian Date (JD - 2400000.5, Note 1);
*     JFORM    i     choice of element set (1-3; Note 3);
*     EPOCH    d     epoch of elements (TT MJD, Note 4);
*     ORBINC   d     inclination (radians);
*     ANODE    d     longitude of the ascend;//
*     PERIH    d     longitude or argument of perihelion (radians);
*     AORQ     d     mean distance or perihelion distance (AU);
*     E        d     eccentricity;
*     AORL     d     mean anomaly or longitude (radians, JFORM:=1,2 only);
*     DM       d     daily motion (radians, JFORM:=1 only);
*;
*  ed:;
*     PV       d(6)  heliocentric x,y,z,xdot,ydot,zdot of date,;
*                                     J2000 equatorial triad (AU,AU/s);
*     JSTAT    i     status:  0 := OK;
*                            -1 := illegal JFORM;
*                            -2 := illegal E;
*                            -3 := illegal AORQ;
*                            -4 := illegal DM;
*                            -5 := numerical error;
*;
*  ed:  sla_EL2UE, sla_UE2PV;
*;
*  Notes;
*;
*  1  DATE is the instant for which the prediction is required.0  It is;
*     in the TT timescale (formerly Ephemeris Time, ET) and is a;
*     Modified Julian Date (JD-2400000.5).0;
*;
*  2  The elements are with respect to the J2000 ecliptic and equinox.0;
*;
*  3  A choice of three different element-set options is available:;
*;
*     Option JFORM := 1, suitable for the major planets:;
*;
*       EPOCH  := epoch of elements (TT MJD);
*       ORBINC := inclination i (radians);
*       ANODE  = longitude of the ascend;//
*       PERIH  := longitude of perihelion, curly pi (radians);
*       AORQ   := mean distance, a (AU);
*       E      := eccentricity, e (range 0 to <1);
*       AORL   := mean longitude L (radians);
*       DM     := daily motion (radians);
*;
*     Option JFORM := 2, suitable for minor planets:;
*;
*       EPOCH  := epoch of elements (TT MJD);
*       ORBINC := inclination i (radians);
*       ANODE  = longitude of the ascend;//
*       PERIH  := argument of perihelion, little omega (radians);
*       AORQ   := mean distance, a (AU);
*       E      := eccentricity, e (range 0 to <1);
*       AORL   := mean anomaly M (radians);
*;
*     Option JFORM := 3, suitable for comets:;
*;
*       EPOCH  := epoch of elements and perihelion (TT MJD);
*       ORBINC := inclination i (radians);
*       ANODE  = longitude of the ascend;//
*       PERIH  := argument of perihelion, little omega (radians);
*       AORQ   := perihelion distance, q (AU);
*       E      := eccentricity, e (range 0 to 10);
*;
*     Unused arguments (DM for JFORM:=2, AORL and DM for JFORM:=3) are not;
*     accessed.0;
*;
*  4  Each of the three element sets defines an unperturbed heliocentric;
*     orbit.0  For a given epoch of observation, the position of the body;
*     in its orbit can be predicted from these elements, which are;
*     ed "osculating elements", using standard two-body analytical;
*     solutions.0  However, due to planetary perturbations, a given set;
*     of osculating elements remains usable for only as long as the;
*     unperturbed orbit that it describes is an adequate approximation;
*     to reality.0  Attached to such a set of elements is a date ed;
*     the "osculating epoch", at which the elements are, momentarily,;
*     a perfect representation of the instantaneous position and;
*     velocity of the body.0;
*;
*     Therefore, for any given problem there are up to three different;
*     epochs in play, and it is vital to distinguish clearly between;
*     them:;
*;
*     0.0 The epoch of observation:  the moment in time for which the;
*       position of the body is to be predicted.0;
*;
*     0.0 The epoch defining the position of the body:  the moment in time;
*       at which, in the absence of purturbations, the specified;
*       position (mean longitude, mean anomaly, or perihelion) is;
*       reached.0;
*;
*     0.0 The osculating epoch:  the moment in time at which the given;
*       elements are correct.0;
*;
*     For the major-planet and minor-planet cases it is usual to make;
*     the epoch that defines the position of the body the same as the;
*     epoch of osculation.0  Thus, only two different epochs are;
*     involved:  the epoch of the elements and the epoch of observation.0;
*;
*     For comets, the epoch of perihelion fixes the position in the;
*     orbit and in general a different epoch of osculation will be;
*     chosen.0  Thus, all three types of epoch are involved.0;
*;
*     For the present routine:;
*;
*     0.0 The epoch of observation is the argument DATE.0;
*;
*     0.0 The epoch defining the position of the body is the argument;
*       EPOCH.0;
*;
*     0.0 The osculating epoch is not used and is assumed to be close;
*       enough to the epoch of observation to deliver adequate accuracy.0;
*       If not, a preliminary  to sla_PERTEL may be used to update;
*       the element-set (and its associated osculating epoch) by;
*       applying planetary perturbations.0;
*;
*  5  The reference frame for the result is with respect to the mean;
*     equator and equinox of epoch J2000.0;
*;
*  6  The algorithm was originally adapted from the EPHSLA program of
*     D.H.P.Jones (private communication, 1996).0  The method is based;
*     on Stumpff's Universal Variables.0;
*;
*  Reference:  Everhart, E.0 & Pitkin, E.T., Am.J.Phys.0 51, 712, 1983.0;
*;
*  P.T.Wallace   Starlink   31 December 2002;
*;
*  Copyright (C) 2002 Rutherford Appleton Laboratory;
*;
*  License:;
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published b;
*    the Free Software Foundation; either version 2 of the License, or;
*    (at your option) any later version.0;
*;
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of;
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.0  See the;
*    GNU General Public License for more details.0;
*;
*    You should have received a copy of the GNU General Public License;
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330, ;
*    Boston, MA  02111-1307  USA;
*;
}


procedure sla_PLANEL ( DATE: double; JFORM: integer; EPOCH : double; ORBINC, ANODE, PERIH,AORQ, E, AORL, DM: double;out PV: r6_array; out  JSTAT : integer);
var
U: U_array;
J: integer;
begin
  // line not converted// *  Validate elements and convert to "universal va;
  sla_EL2UE(DATE,JFORM, EPOCH,ORBINC,ANODE,PERIH,AORQ,E,AORL,DM,U,J);
  //  Determine the position and velocity.0;
  if (J = 0) then
  begin
    sla_UE2PV(DATE,U,PV,J);
    if (J<>0) then  J:=-5;
  end;
  //  Wrap up.0;
  JSTAT := J;
end;

//----------------------------------------------------------------------------------------

{*+
*     - - - - - -
*      D C C 2 S
*     - - - - - -
*
*  Cartesian to spherical coordinates (double precision)
*
*  Given:
*     V     d(3)   x,y,z vector
*
*  Returned:
*     A,B   d      spherical coordinates in radians
*
*  The spherical coordinates are longitude (+ve anticlockwise looking
*  from the +ve latitude pole) and latitude.  The Cartesian coordinates
*  are right handed, with the x axis at zero longitude and latitude, and
*  the z axis at the +ve latitude pole.
*
*  If V is null, zero A and B are returned.  At either pole, zero A is
*  returned.
*
*  Last revision:   22 July 2004
*
*  Copyright P.T.Wallace.  All rights reserved.
*
*  License:
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330,
*    Boston, MA  02111-1307  USA
*
*-}

procedure sla_DCC2S (V : r3_array; out  A, B : double);
var
  X,Y,Z,R: double;
begin
  X := V[1];
  Y := V[2];
  Z := V[3];
  R := SQRT(X*X+Y*Y);
  if (R = 0) then
  begin
  A := 0;
  end
  else
  begin
    A := ARCTAN2(Y,X);
  end;
  if (Z = 0) then
  begin
    B := 0;
  end
  else
  begin
    B := ARCTAN2(Z,R);
  end;
end;//


//---------------------------------------------------------------------------------------------------
{*+
*     - - - - -
*      D M X V
*     - - - - -
*
*  Performs the 3-D forward unitary transformation:
*
*     vector VB = matrix DM * vector VA
*
*  (double precision)
*
*  Given:
*     DM       dp(3,3)    matrix
*     VA       dp(3)      vector
*
*  Returned:
*     VB       dp(3)      result vector
*
*  To comply with the ANSI Fortran 77 standard, VA and VB must be
*  different arrays.  However, the routine is coded so as to work
*  properly on many platforms even if this rule is violated.
*
*  Last revision:   26 December 2004
*
*  Copyright P.T.Wallace.  All rights reserved.
*
*  License:
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330,
*    Boston, MA  02111-1307  USA
*
*-}

procedure sla_DMXV (DM : r3x3_array; VA : r3_array; out VB : r3_array);
var
  I,J: integer;
  w  : double;
  VW : r3_array;
begin
  //  Matrix DM * vector VA -> vector VW;
  for  J := 1 to 3  do
  begin
    W:=0;
    for  I := 1 to 3  do
    begin
      W:=W+DM[J,I]*VA[I];
    end;
    VW[J]:=W;
  end;
  //  Vector VW -> vector VB;
  for  J := 1 to 3  do
  begin
    VB[J]:=VW[J];
  end;
end;//

//--------------------------------------------------------------------------------------------

{*+
*     - - - - - -
*      D C S 2 C
*     - - - - - -
*
*  Spherical coordinates to direction cosines (double precision)
*
*  Given:
*     A,B       d      spherical coordinates in radians
*                         (RA,Dec), (long,lat) etc.
*
*  Returned:
*     V         d(3)   x,y,z unit vector
*
*  The spherical coordinates are longitude (+ve anticlockwise looking
*  from the +ve latitude pole) and latitude.  The Cartesian coordinates
*  are right handed, with the x axis at zero longitude and latitude, and
*  the z axis at the +ve latitude pole.
*
*  Last revision:   26 December 2004
*
*  Copyright P.T.Wallace.  All rights reserved.
*
*  License:
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330,
*    Boston, MA  02111-1307  USA
*
*-}

procedure sla_DCS2C (A, B : double; out V : r3_array);
var
  COSB: double;
begin
  COSB := COS(B);
  V[1] := COS(A)*COSB;
  V[2] := SIN(A)*COSB;
  V[3] := SIN(B);
end;//

//-------------------------------------------------------------------------------------------

{*+
*     - - - - - - -
*      D E U L E R
*     - - - - - - -
*
*  Form a rotation matrix from the Euler angles - three successive
*  rotations about specified Cartesian axes (double precision)
*
*  Given:
*    ORDER   string  specifies about which axes the rotations occur
*    PHI     d       1st rotation (radians)
*    THETA   d       2nd rotation (   "   )
*    PSI     d       3rd rotation (   "   )
*
*  Returned:
*    RMAT    d(3,3)  rotation matrix
*
*  A rotation is positive when the reference frame rotates
*  anticlockwise as seen looking towards the origin from the
*  positive region of the specified axis.
*
*  The characters of ORDER define which axes the three successive
*  rotations are about.  A typical value is 'ZXZ', indicating that
*  RMAT is to become the direction cosine matrix corresponding to
*  rotations of the reference frame through PHI radians about the
*  old Z-axis, followed by THETA radians about the resulting X-axis,
*  then PSI radians about the resulting Z-axis.
*
*  The axis names can be any of the following, in any order or
*  combination:  X, Y, Z, uppercase or lowercase, 1, 2, 3.  Normal
*  axis labelling/numbering conventions apply;  the xyz (=123)
*  triad is right-handed.  Thus, the 'ZXZ' example given above
*  could be written 'zxz' or '313' (or even 'ZxZ' or '3xZ').  ORDER
*  is terminated by length or by the first unrecognized character.
*
*  Fewer than three rotations are acceptable, in which case the later
*  angle arguments are ignored.  If all rotations are zero, the
*  identity matrix is produced.
*
*  P.T.Wallace   Starlink   23 May 1997
*
*  Copyright (C) 1997 Rutherford Appleton Laboratory
*
*  License:
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330,
*    Boston, MA  02111-1307  USA
*}



procedure sla_DEULER (ORDER : ansistring; PHI, THETA, PSI : double; out RMAT :r3x3_array);
var
  J,I,L,N,K: integer;
  ANGLE, S, C, W: double;
  RESULT,ROTN,WM: r3x3_array;
begin

  //  Initialize result matrix;
  for  J := 1 to 3  do
  begin
    for  I := 1 to 3  do
    begin
      if (I<>J) then
      begin
        RESULT[I,J] := 0;
      end
      else
      begin
        RESULT[I,J] := 1;
      end;
    end;
  end;
  //  Establish length of axis string;
  L := length(ORDER);
  //  Look at each character of axis string until finished;
  for  N := 1 to 3  do
  begin
    if (N<=L) then
    begin
    // Initialize rotation matrix for the current rotation;
    for  J := 1 to 3  do
    begin
      for  I := 1 to 3  do
      begin
        if (I<>J) then
        begin
          ROTN[I,J] := 0;
        end else begin
        ROTN[I,J] := 1;
      end;
    end;
    end;
    //  Pick up the appropriate Euler angle and take sine & cosine;
    if (N = 1) then
    begin
      ANGLE := PHI;
    end
    else
    if (N = 2) then
    begin
      ANGLE := THETA;
    end
    else
    begin
      ANGLE := PSI;
    end;
    S := SIN(ANGLE);
    C := COS(ANGLE);

    //    Identify the axis;
    if ORDER[N]= 'X' THEN
    //  Matrix for x-rotation;
    begin
      ROTN[2,2] := C;
      ROTN[2,3] := S;
      ROTN[3,2] := -S;
      ROTN[3,3] := C;
    end
    else
    if ORDER[N]= 'Y' THEN
    //   Matrix for y-rotation;
    BEGIN
      ROTN[1,1] := C;
      ROTN[1,3] := -S;
      ROTN[3,1] := S;
      ROTN[3,3] := C;
    end
    else
    if ORDER[N]= 'Z' THEN
    //     Matrix for z-rotation;
    BEGIN

      ROTN[1,1] := C;
      ROTN[1,2] := S;
      ROTN[2,1] := -S;
      ROTN[2,2] := C;
    end
    else
    begin
    //  Unrecognized character - fake end;
      L := 0;
    end;

    //   Apply the current rotation (matrix ROTN x matrix RESULT);
    for  I := 1 to 3  do
    begin
      for  J := 1 to 3  do
      begin
        W := 0;
        for  K := 1 to 3  do
        begin
          W := W+ROTN[I,K]*RESULT[K,J];
        end;
        WM[I,J] := W;
      end;
    end;
    for  J := 1 to 3  do
    begin
      for  I := 1 to 3  do
      begin
        RESULT[I,J] := WM[I,J];
      end;
    end;
    end;
  end;
  // Copy the result;
  for  J := 1 to 3  do
  begin
    for  I := 1 to 3  do
    begin
      RMAT[I,J] := RESULT[I,J];
    end;
  end;
end;//



//-------------------------------------------------------------------------------------------

{*+
*     - - - - -
*      P R E C
*     - - - - -
*
*  Form the matrix of precession between two epochs (IAU 1976, FK5)
*  (double precision)
*
*  Given:
*     EP0    dp         beginning epoch
*     EP1    dp         ending epoch
*
*  Returned:
*     RMATP  dp(3,3)    precession matrix
*
*  Notes:
*
*     1)  The epochs are TDB (loosely ET) Julian epochs.
*
*     2)  The matrix is in the sense   V(EP1)  =  RMATP * V(EP0)
*
*     3)  Though the matrix method itself is rigorous, the precession
*         angles are expressed through canonical polynomials which are
*         valid only for a limited time span.  There are also known
*         errors in the IAU precession rate.  The absolute accuracy
*         of the present formulation is better than 0.1 arcsec from
*         1960AD to 2040AD, better than 1 arcsec from 1640AD to 2360AD,
*         and remains below 3 arcsec for the whole of the period
*         500BC to 3000AD.  The errors exceed 10 arcsec outside the
*         range 1200BC to 3900AD, exceed 100 arcsec outside 4200BC to
*         5600AD and exceed 1000 arcsec outside 6800BC to 8200AD.
*         The SLALIB routine sla_PRECL implements a more elaborate
*         model which is suitable for problems spanning several
*         thousand years.
*
*  References:
*     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
*      equations (6) & (7), p283.
*     Kaplan,G.H., 1981. USNO circular no. 163, pA2.
*
*  Called:  sla_DEULER
*
*  P.T.Wallace   Starlink   23 August 1996
*
*  Copyright (C) 1996 Rutherford Appleton Laboratory
*
*  License:
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330,
*    Boston, MA  02111-1307  USA
*
*-}

procedure sla_PREC (EP0, EP1 : double;out RMATP :r3x3_array);
const
  // Arc seconds to radians;
  AS2R=pi/(3600*180);
var
  T0,T,TAS2R,W,ZETA,Z,THETA: double;
begin
  //  Interval between basic epoch J2000.0 and beginning epoch (JC);
  T0 := (EP0-2000)/100;
  //  Interval over which precession required (JC);
  T := (EP1-EP0)/100;
  //  Euler angles;
  TAS2R := T*AS2R;
  W := 2306.2181+(1.39656-0.000139*T0)*T0;
  ZETA := (W+((0.30188-0.000344*T0)+0.017998*T)*T)*TAS2R;{result in radians}
  Z := (W+((1.09468+0.000066*T0)+0.018203*T)*T)*TAS2R;{result in radians}
  THETA := ((2004.3109+(-0.85330-0.000217*T0)*T0)+((-0.42665-0.000217*T0)-0.041833*T)*T)*TAS2R;{result in radians}
  //  Rotation matrix;
  sla_DEULER('ZYZ',-ZETA,THETA,-Z,RMATP);
end;//

//-----------------------------------------------------------------------------------------------------------------------------------------------------

procedure precession3(JD0, JD1: double; var RA, DC : double); {precession}
var
  RMATP: r3x3_array;
  V1,V2: r3_array;
  x,y,z : double;
begin

  //  Generate appropriate precession matrix;
  sla_PREC(2000+(jd0 - 2451545) / 365.25,2000+(jd1 - 2451545) / 365.25,RMATP);             // EP1=2000D0 + (DATE-51544.5D0)/365.25D0

  //*     Convert RA,Dec to x,y,z;
  sla_DCS2C(RA,DC,V1);

  //*     Precess;
  sla_DMXV(RMATP,V1,V2);

  //*     Back to RA,Dec;
  sla_DCC2S(V2,RA,DC);

 //make range 0.. 2*pi
   RA:=RA mod (2*pi);
   IF RA<0 then RA:=RA+2*pi;

end;


//-----------------------------------------------------------------------------------------------------------------------------------------------------


{For this Pascal version minor Pluto has been removed. Pluto position will be retrieved as a minor planet}
{*+
*     - - - - - - -
*      P L A N E T
*     - - - - - - -
*
*  Approximate heliocentric position and velocity of a specified
*  major planet.
*
*  Given:
*     DATE      d      Modified Julian Date (JD - 2400000.5)
*     NP        i      planet (1=Mercury, 2=Venus, 3=EMB ... 8=Neptune)
*
*  Returned:
*     PV        d(6)   heliocentric x,y,z,xdot,ydot,zdot, J2000
*                                           equatorial triad (AU,AU/s)
*     JSTAT     i      status: +1 = warning: date out of range
*                               0 = OK
*                              -1 = illegal NP (outside 1-9)
*                              -2 = solution didn't converge
*
*  Called:  sla_PLANEL
*
*  Notes
*
*  1  The epoch, DATE, is in the TDB timescale and is a Modified
*     Julian Date (JD-2400000.5).
*
*  2  The reference frame is equatorial and is with respect to the
*     mean equinox and ecliptic of epoch J2000.
*
*  3  If an NP value outside the range 1-9 is supplied, an error
*     status (JSTAT = -1) is returned and the PV vector set to zeroes.
*
*  4  The algorithm for obtaining the mean elements of the planets
*     from Mercury to Neptune is due to J.L. Simon, P. Bretagnon,
*     J. Chapront, M. Chapront-Touze, G. Francou and J. Laskar
*     (Bureau des Longitudes, Paris).  The (completely different)
*     algorithm for calculating the ecliptic coordinates of Pluto
*     is by Meeus.
*
*  5  Comparisons of the present routine with the JPL DE200 ephemeris
*     give the following RMS errors over the interval 1960-2025:
*
*                      position (km)     speed (metre/sec)
*
*        Mercury            334               0.437
*        Venus             1060               0.855
*        EMB               2010               0.815
*        Mars              7690               1.98
*        Jupiter          71700               7.70
*        Saturn          199000              19.4
*        Uranus          564000              16.4
*        Neptune         158000              14.4
*
*     From comparisons with DE102, Simon et al quote the following
*     longitude accuracies over the interval 1800-2200:
*
*        Mercury                 4"
*        Venus                   5"
*        EMB                     6"
*        Mars                   17"
*        Jupiter                71"
*        Saturn                 81"
*        Uranus                 86"
*        Neptune                11"
*
*
*     Over the period 1000-3000 the accuracy
*     is better than 1.5 times that over 1800-2200.  Outside the
*     period 1000-3000 the accuracy declines.  For Pluto the
*     accuracy declines rapidly outside the period 1885-2099.
*     Outside these ranges (1885-2099 for Pluto, 1000-3000 for
*     the rest) a "date out of range" warning status (JSTAT=+1)
*     is returned.
*
*  6  The algorithms for (i) Mercury through Neptune and (ii) Pluto
*     are completely independent.  In the Mercury through Neptune
*     case, the present SLALIB implementation differs from the
*     original Simon et al Fortran code in the following respects.
*
*     *  The date is supplied as a Modified Julian Date rather
*        than a Julian Date (MJD = JD - 2400000.5).
*
*     *  The result is returned only in equatorial Cartesian form;
*        the ecliptic longitude, latitude and radius vector are not
*        returned.
*
*     *  The velocity is in AU per second, not AU per day.
*
*     *  Different error/warning status values are used.
*
*     *  Kepler's equation is not solved inline.
*
*     *  Polynomials in T are nested to minimize rounding errors.
*
*     *  Explicit double-precision constants are used to avoid
*        mixed-mode expressions.
*
*     *  There are other, cosmetic, changes to comply with
*        Starlink/SLALIB style guidelines.
*
*     None of the above changes affects the result significantly.
*
*  7  For NP=3 the result is for the Earth-Moon Barycentre.  To
*     obtain the heliocentric position and velocity of the Earth,
*     either use the SLALIB routine sla_EVP (or sla_EPV) or call
*     sla_DMOON and subtract 0.012150581 times the geocentric Moon
*     vector from the EMB vector produced by the present routine.
*     (The Moon vector should be precessed to J2000 first, but this
*     can be omitted for modern epochs without introducing significant
*     inaccuracy.)
*
*  References:  Simon et al., Astron. Astrophys. 282, 663 (1994).
*               Meeus, Astronomical Algorithms, Willmann-Bell (1991).
*
*  This revision:  19 June 2004
*
*  Copyright (C) 2004 P.T.Wallace.  All rights reserved.
*
*  License:
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330,
*    Boston, MA  02111-1307  USA
*
*-}
procedure sla_PLANET (DATE : double;  NP: integer; out PV: r6_array; out JSTAT: integer);
var
  //  -----------------------;
  //  Mercury through Neptune;
  //  -----------------------;

  { Planetary inverse masses}
  AMAS : array[1..8] of double= (( 6023600),(408523.5),328900.5,3098710,1047.355,3498.5,22869,19314);

  //;
  //  Tables giving the mean Keplerian elements, limited to T**2 terms:;
  //;
  //         A       semi-major axis (AU);
  //         DLM     mean longitude (degree and arcsecond);
  //         E       eccentricity;
  //         PI      longitude of the perihelion (degree and arcsecond);
  //         DINC    inclination (degree and arcsecond);
  //         OMEGA   longitude of the ascend;//
  //;
  A : array[1..8,1..3] of double =(
  (  0.3870983098,             0,      0),
  (  0.7233298200,             0,      0),
  (  1.0000010178,             0,      0),
  (  1.5236793419,           3E-10,      0),
  (  5.2026032092,       19132E-10,  -39E-10),
  (  9.5549091915, -0.0000213896,  444E-10),
  ( 19.2184460618,       -3716E-10,  979E-10),
  ( 30.1103868694,      -16635E-10,  686E-10));
  //;
  DLM : array[1..8,1..3] of double=(
  ( 252.25090552, 5381016286.88982,  -1.92789),
  ( 181.97980085, 2106641364.33548,   0.59381),
  ( 100.46645683, 1295977422.83429,  -2.04411),
  ( 355.43299958,  689050774.93988,   0.94264),
  (  34.35151874,  109256603.77991, -30.60378),
  (  50.07744430,   43996098.55732,  75.61614),
  ( 314.05500511,   15424811.93933,  -1.75083),
  ( 304.34866548,    7865503.20744,   0.21103));
  //;
   E : array[1..8,1..3] of double=(
  ( 0.2056317526,  0.0002040653,      -28349E-10),
  ( 0.0067719164, -0.0004776521,       98127E-10),
  ( 0.0167086342, -0.0004203654, -0.0000126734),
  ( 0.0934006477,  0.0009048438,      -80641E-10),
  ( 0.0484979255,  0.0016322542, -0.0000471366),
  ( 0.0555481426, -0.0034664062, -0.0000643639),
  ( 0.0463812221, -0.0002729293,  0.0000078913),
  ( 0.0094557470,  0.0000603263,            0 ));
  //;
  PI : array[01..8,1..3] of double=(
  (  77.45611904,  5719.11590,   -4.83016),
  ( 131.56370300,   175.48640, -498.48184),
  ( 102.93734808, 11612.35290,   53.27577),
  ( 336.06023395, 15980.45908,  -62.32800),
  (  14.33120687,  7758.75163,  259.95938),
  (  93.05723748, 20395.49439,  190.25952),
  ( 173.00529106,  3215.56238,  -34.09288),
  (  48.12027554,  1050.71912,   27.39717));
  //;
  DINC : array[01..8,1..3] of double=(
  ( 7.00498625, -214.25629,   0.28977),
  ( 3.39466189,  -30.84437, -11.67836),
  (          0,  469.97289,  -3.35053),
  ( 1.84972648, -293.31722,  -8.11830),
  ( 1.30326698,  -71.55890,  11.95297),
  ( 2.48887878,   91.85195, -17.66225),
  ( 0.77319689,  -60.72723,   1.25759),
  ( 1.76995259,    8.12333,   0.08135));
  //;
  OMEGA : array[01..8,1..3] of double=(
  (  48.33089304,  -4515.21727,  -31.79892),
  (  76.67992019, -10008.48154,  -51.32614),
  ( 174.87317577,  -8679.27034,   15.34191),
  (  49.55809321, -10620.90088, -230.57416),
  ( 100.46440702,   6362.03561,  326.52178),
  ( 113.66550252,  -9240.19942,  -66.23743),
  (  74.00595701,   2669.15033,  145.93964),
  ( 131.78405702,   -221.94322,   -0.78728));
  //;
  //  Tables for trigonometric terms to be added to the mean elements;
  //  of the semi-major axes.0;
  //;
  DKP : array[1..8,1..9] of double=(
  ( 69613, 75645, 88306, 59899, 15746, 71087, 142173,  3086,    0),
  ( 21863, 32794, 26934, 10931, 26250, 43725,  53867, 28939,    0),
  ( 16002, 21863, 32004, 10931, 14529, 16368,  15318, 32794,    0),
  ( 6345,   7818, 15636,  7077,  8184, 14163,   1107,  4872,    0),
  ( 1760,   1454,  1167,   880,   287,  2640,     19,  2047, 1454),
  (  574,      0,   880,   287,    19,  1760,   1167,   306,  574),
  (  204,      0,   177,  1265,     4,   385,    200,   208,  204),
  (    0,    102,   106,     4,    98,  1367,    487,   204,    0 ));
  //;
  CA  : array[1..8,1..9] of double=(
  (      4,    -13,    11,    -9,    -9,    -3,    -1,     4,    0),
  (   -156,     59,   -42,     6,    19,   -20,   -10,   -12,    0),
  (     64,   -152,    62,    -8,    32,   -41,    19,   -11,    0),
  (    124,    621,  -145,   208,    54,   -57,    30,    15,    0),
  ( -23437,  -2634,  6601,  6259, -1507, -1821,  2620, -2115,-1489),
  (  62911,-119919, 79336, 17814,-24241, 12068,  8306, -4893, 8902),
  ( 389061,-262125,-44088,  8387,-22976, -2093,  -615, -9720, 6633),
  (-412235,-157046,-31430, 37817, -9740,   -13, -7449,  9644,    0 ));
  //;
  SA  : array[1..8,1..9] of double=(
  (     -29,    -1,     9,     6,    -6,     5,     4,     0,    0),
  (     -48,  -125,   -26,   -37,    18,   -13,   -20,    -2,    0),
  (    -150,   -46,    68,    54,    14,    24,   -28,    22,    0),
  (    -621,   532,  -694,   -20,   192,   -94,    71,   -73,    0),
  (  -14614,-19828, -5869,  1881, -4372, -2255,   782,   930,  913),
  (  139737,     0, 24667, 51123, -5102,  7429, -4095, -1976,-9566),
  ( -138081,     0, 37205,-49039,-41901,-33872,-27037,-12474,18797),
  (       0, 28492,133236, 69654, 52322,-49577,-26430, -3593,    0 ));
  //;
  //  Tables giving the trigonometric terms to be added to the mean;
  //  elements of the mean longitudes.0;
  //;
  DKQ  : array[1..8,1..10] of double=(
  (  3086, 15746, 69613, 59899, 75645, 88306, 12661, 2658,  0,   0),
  ( 21863, 32794, 10931,    73,  4387, 26934,  1473, 2157,  0,   0),
  (    10, 16002, 21863, 10931,  1473, 32004,  4387,   73,  0,   0),
  (    10,  6345,  7818,  1107, 15636,  7077,  8184,  532, 10,   0),
  (    19,  1760,  1454,   287,  1167,   880,   574, 2640, 19,1454),
  (    19,   574,   287,   306,  1760,    12,    31,   38, 19, 574),
  (     4,   204,   177,     8,    31,   200,  1265,  102,  4, 204),
  (     4,   102,   106,     8,    98,  1367,   487,  204,  4, 102));
  //;
  CLO  : array[1..8,1..10] of double=(
  (     21,   -95, -157,   41,   -5,   42,   23,   30,     0,    0),
  (   -160,  -313, -235,   60,  -74,  -76,  -27,   34,     0,    0),
  (   -325,  -322,  -79,  232,  -52,   97,   55,  -41,     0,    0),
  (   2268,  -979,  802,  602, -668,  -33,  345,  201,   -55,    0),
  (   7610, -4997,-7689,-5841,-2617, 1115, -748, -607,  6074,  354),
  ( -18549, 30125,20012, -730,  824,   23, 1289, -352,-14767,-2062),
  (-135245,-14594, 4197,-4030,-5630,-2898, 2540, -306,  2939, 1986),
  (  89948,  2103, 8963, 2695, 3682, 1648,  866, -154, -1963, -283));
  //;
  SLO : array[1..8,1..10] of double=(
  (   -342,   136,  -23,   62,   66,  -52,  -33,   17,     0,    0),
  (    524,  -149,  -35,  117,  151,  122,  -71,  -62,     0,    0),
  (   -105,  -137,  258,   35, -116,  -88, -112,  -80,     0,    0),
  (    854,  -205, -936, -240,  140, -341,  -97, -232,   536,    0),
  ( -56980,  8016, 1012, 1448,-3024,-3710,  318,  503,  3767,  577),
  ( 138606,-13478,-4964, 1441,-1319,-1482,  427, 1236, -9167,-1918),
  (  71234,-41116, 5334,-4935,-1848,   66,  434,-1748,  3780, -701),
  ( -47645, 11647, 2166, 3194,  679,    0, -244, -419, -2531,   48));

var
  //  Coefficients for latitude, longitude, radius vector;
   DL : double;
const
  //  2Pi, deg to radians, arcsec to radians;
  D2PI= 6.2831853071795864769252867;
  AS2R=4.848136811095359935899141023579E-6;
  //  Gaussian gravitational constant (exact);
  GCON=0.01720209895;
var
  I,J : integer;
  T,DA,DE,DPE,DI,DOM,DMU,ARGA,ARGL,DM   : double;
begin
  //  Validate the planet number.;
  if ((NP<1) or (NP > 8)) then {without Pluto, mod Han Kleijn}
  begin
    JSTAT:=-1;
    for  I := 1 to 6  do
    begin
      PV[I]:=0;
    end;
  end
  else
  begin
    //        -----------------------;
    //        Mercury through Neptune;
    //        -----------------------;
    //        Time: Julian millennia since J2000.;
    T:=(DATE-51544.5)/365250;
    //        OK status unless remote epoch.;
    if (ABS(T)<=1E0) then
    begin
      JSTAT:=0;
    end
    else
    begin
      JSTAT:=1;
    end;
    //        Compute the mean elements.;
    DA:=A[NP,1]+(A[NP,2]+A[NP,3]*T)*T;
    DL:=(3600*DLM[NP,1]+(DLM[NP,2]+DLM[NP,3]*T)*T)*AS2R;
    DE:=E[NP,1]+(E[NP,2]+E[NP,3]*T)*T;
    DPE:=MOD2((3600*PI[NP,1]+(PI[NP,2]+PI[NP,3]*T)*T)*AS2R, D2PI);
    DI:=(3600*DINC[NP,1]+(DINC[NP,2]+DINC[NP,3]*T)*T)*AS2R;
    DOM:=mod2((3600*OMEGA[NP,1]+(OMEGA[NP,2]+OMEGA[NP,3]*T)*T)*AS2R,D2PI) ;


    //    Apply the trigonometric terms.;
    DMU:=0.35953620*T;
    for  J := 1 to 8  do
    begin
      ARGA:=DKP[NP,J]*DMU;
      ARGL:=DKQ[NP,J]*DMU;
      DA:=DA+(CA[NP,J]*COS(ARGA)+SA[NP,J]*SIN(ARGA))*1E-7;
      DL:=DL+(CLO[NP,J]*COS(ARGL)+SLO[NP,J]*SIN(ARGL))*1E-7;
    end;
    ARGA:=DKP[NP,9]*DMU;
    DA:=DA+T*(CA[NP,9]*COS(ARGA)+SA[NP,9]*SIN(ARGA))*1E-7;
    for  J := 9 to 10  do
    begin
      ARGL:=DKQ[NP,J]*DMU;
      DL:=DL+T*(CLO[NP,J]*COS(ARGL)+SLO[NP,J]*SIN(ARGL))*1E-7;
    end;
    DL:=MOD2(DL,D2PI);
    //        Daily motion.;
    DM:=GCON*SQRT((1+1/AMAS[NP])/(DA*DA*DA));
    //        Make the prediction;
    sla_PLANEL(DATE,1,DATE,DI,DOM,DPE,DA,DE,DL,DM,PV,J);
    if (J<0) then
      JSTAT:=-2;
   end;
end;
//-----------------------------------------------------------------------------------------------------------------------------------------------------

procedure orbit(date : double; JFORM : integer; EPOCH : double; ORBINC, ANODE,PERIH, AORQ, E, AORL, DM : double; out PV :r6_array; out JSTAT : integer) ;//Heliocentric position and velocity of a planet, asteroid or comet
var
   U :U_array;
begin
  sla_EL2UE (date{mjd}, JFORM, EPOCH, ORBINC, ANODE,PERIH, AORQ, E, AORL,DM,{out} U , JSTAT);
  //  Determine the position and velocity.;
  if (Jstat = 0) then
  begin
    sla_UE2PV(date{mjd},U,PV,Jstat);
    if (Jstat<>0) then  Jstat:=-5;
  end;
end;


//---------------------------------------------------------------------------------------------------------------------------------------------



{*+;
*  - - - -;
*   E P V;
*  - - - -;
*;
*  Earth position and velocity, heliocentric and barycentric, with;
*  respect to the Barycentric Celestial Reference System.
*;
*  Given:;
*     DATE      d         date, TDB Modified Julian Date (Note 1);
*;
*  ed:;
*     PH        d(3)      heliocentric Earth position (AU);
*     VH        d(3)      heliocentric Earth velocity (AU,AU/day);
*     PB        d(3)      barycentric Earth position (AU);
*     VB        d(3)      barycentric Earth velocity (AU/day);
*;
*  Notes:;
*;
*  1) The date is TDB as an MJD (:=JD-2400000.5).0  TT can be used instead;
*     of TDB in most applications.
*;
*  2) On , the arrays PH, VH, PV, PB contain the following:;
*;
*        PH(1)    x       );
*        PH(2)    y       ) heliocentric position, AU;
*        PH(3)    z       );
*;
*        VH[1]    xdot    );
*        VH[2]    ydot    ) heliocentric velocity, AU/d;
*        VH[3]    zdot    );
*;
*        PB[1]    x       );
*        PB[2]    y       ) barycentric position, AU;
*        PB[3]    z       );
*;
*        VB[1]    xdot    );
*        VB[2]    ydot    ) barycentric velocity, AU/d;
*        VB[3]    zdot    );
*;
*     The vectors are with respect to the Barycentric Celestial;
*     Reference System (BCRS); velocities are in AU per TDB day.
*;
*  3) The routine is a SIMPLIFIED SOLUTION from the planetary theory;
*     VSOP2000 (X.0 Moisson, P.0 Bretagnon, 2001, Celes.0 Mechanics &;
*     Dyn.0 Astron., 80, 3/4, 205-213) and is an adaptation of original;
*     Fortran code supplied by P.0 Bretagnon (private comm., 2000).
*;
*  4) Comparisons over the time span 1900-2100 with this simplified;
*     solution and the JPL DE405 ephemeris give the following results:;
*;
*                                RMS    max;
*           Heliocentric:;
*              position error    3.7   11.2   km;
*              velocity error    1.4    5.0   mm/s;
*;
*           Barycentric:;
*              position error    4.6   13.4   km;
*              velocity error    1.4    4.9   mm/s;
*;
*     The results deteriorate outside this time span.
*;
*  5) The routine sla_EVP is faster but less accurate.0  The present;
*     routine targets the case where high accuracy is more important;
*     than CPU time, yet the extra complication of reading a pre-;
*     computed ephemeris is not justified.
*;
*  Last revision:   7 April 2005;
*;
*  Copyright P.T.Wallace.0  All rights reserved.
*;
*;
*  License:;
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published b;
*    the Free Software Foundation; either version 2 of the License, or;
*    (at your option) any later version.
*;
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of;
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.0  See the;
*    GNU General Public License for more details.
*;
*    You should have received a copy of the GNU General Public License;
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330, ;
*    Boston, MA  02111-1307  USA;
*;
*-----------------------------------------------------------------------;}


procedure sla_EPV (DATE : double; out PH, VH {, PB, VB }: r3_array);

{*  ----------------------
*  Ephemeris Coefficients
*  ----------------------
*
*  The coefficients are stored in arrays of dimension (3,n,3).  There
*  are separate sets of arrays for (i) the Sun to Earth vector and
*  (ii) the Solar-System barycenter to Sun vector.  Each of these two
*  sets contains separate arrays for the terms (n in number) in each
*  power of time (in Julian years since J2000): T^0, T^1 and T^2.
*  Within each array, all the Cartesian x-components, elements (i,j,1),
*  appear first, followed by all the y-components, elements (i,j,2) and
*  finally all the z-components, elements (i,j,3).  At the lowest level
*  are groups of three coefficients.  The first coefficient in each
*  group, element (1,j,k), is the amplitude of the term, the second,
*  element (2,j,k), is the phase and the third, element (3,j,k), is the
*  frequency.
*
*  The naming scheme is such that a block
*
*     DOUBLE PRECISION bn(3,Mbn,3)
*
*  applies to body b and time exponent n:
*
*    . b can be either E (Earth with respect to Sun) or S (Sun with
*      respect to Solar-System Barycenter)
*
*    . n can be 0, 1 or 2, for T^0, T^1 or T^2
*
*  For example, array E2(3,ME2,3) contains the coefficients for
*  the T^2 terms for the Sun-to-Earth vector.
*
*  There is no requirement for the X, Y and Z models for a particular
*  block to use the same number of coefficients.  The number actually
*  used is parameterized, the number of terms being used called NbnX,
*  NbnY, and NbnZ respectively.  The parameter Mbn is the biggest of
*  the three, and defines the array size.  Unused elements are not
*  initialized and are never accessed.
*}


  {Notes on the Pascal version:
  In $mode objfpc it is possible to write the coeffcients arrays without zeros so without the unused areas.
  But the resulting executable is about 20k larger. So the current setup using simple rectangle arrays is
  more efficient.}

const
  {specify useful range of data the arrays. The remainder of the arrays is filled with zero's}
  NE0 : array[1..3] of integer =(501,501,137);ME0 =501;
  NE1 : array[1..3] of integer =( 79, 80, 12);ME1 = 80;
  NE2 : array[1..3] of integer =(  5,  5,  3);ME2 =  5;
  NS0 : array[1..3] of integer =(212,213, 69);MS0 =213;
  NS1 : array[1..3] of integer =( 50, 50, 14);MS1 = 50;
  NS2 : array[1..3] of integer =(  9,  9,  2);MS2 =  9;

const
  E0: array[1..3,1..ME0,1..3] of double= {501}
  //  Sun-to-Earth, T^0, X
  // DATA ((E0(I,J,1),I=1,3),J=  1, 10) /
  (((  0.9998292878132E+00, 0.1753485171504E+01, 0.6283075850446E+01),
  (  0.8352579567414E-02, 0.1710344404582E+01, 0.1256615170089E+02),
  (  0.5611445335148E-02, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.1046664295572E-03, 0.1667225416770E+01, 0.1884922755134E+02),
  (  0.3110842534677E-04, 0.6687513390251E+00, 0.8399684731857E+02),
  (  0.2552413503550E-04, 0.5830637358413E+00, 0.5296909721118E+00),
  (  0.2137207845781E-04, 0.1092330954011E+01, 0.1577343543434E+01),
  (  0.1680240182951E-04, 0.4955366134987E+00, 0.6279552690824E+01),
  (  0.1679012370795E-04, 0.6153014091901E+01, 0.6286599010068E+01),
  (  0.1445526946777E-04, 0.3472744100492E+01, 0.2352866153506E+01 ),
  //DATA ((E0(I,J,1),I=1,3),J= 11, 20)),
  (  0.1091038246184E-04, 0.3689845786119E+01, 0.5223693906222E+01),
  (  0.9344399733932E-05, 0.6073934645672E+01, 0.1203646072878E+02),
  (  0.8993182910652E-05, 0.3175705249069E+01, 0.1021328554739E+02),
  (  0.5665546034116E-05, 0.2152484672246E+01, 0.1059381944224E+01),
  (  0.6844146703035E-05, 0.1306964099750E+01, 0.5753384878334E+01),
  (  0.7346610905565E-05, 0.4354980070466E+01, 0.3981490189893E+00),
  (  0.6815396474414E-05, 0.2218229211267E+01, 0.4705732307012E+01),
  (  0.6112787253053E-05, 0.5384788425458E+01, 0.6812766822558E+01),
  (  0.4518120711239E-05, 0.6087604012291E+01, 0.5884926831456E+01),
  (  0.4521963430706E-05, 0.1279424524906E+01, 0.6256777527156E+01),
  //DATA ((E0(I,J,1),I=1,3),J= 21, 30)),
  (  0.4497426764085E-05, 0.5369129144266E+01, 0.6309374173736E+01),
  (  0.4062190566959E-05, 0.5436473303367E+00, 0.6681224869435E+01),
  (  0.5412193480192E-05, 0.7867838528395E+00, 0.7755226100720E+00),
  (  0.5469839049386E-05, 0.1461440311134E+01, 0.1414349524433E+02),
  (  0.5205264083477E-05, 0.4432944696116E+01, 0.7860419393880E+01),
  (  0.2149759935455E-05, 0.4502237496846E+01, 0.1150676975667E+02),
  (  0.2279109618501E-05, 0.1239441308815E+01, 0.7058598460518E+01),
  (  0.2259282939683E-05, 0.3272430985331E+01, 0.4694002934110E+01),
  (  0.2558950271319E-05, 0.2265471086404E+01, 0.1216800268190E+02),
  (  0.2561581447555E-05, 0.1454740653245E+01, 0.7099330490126E+00),
  //DATA ((E0(I,J,1),I=1,3),J= 31, 40)),
  (  0.1781441115440E-05, 0.2962068630206E+01, 0.7962980379786E+00),
  (  0.1612005874644E-05, 0.1473255041006E+01, 0.5486777812467E+01),
  (  0.1818630667105E-05, 0.3743903293447E+00, 0.6283008715021E+01),
  (  0.1818601377529E-05, 0.6274174354554E+01, 0.6283142985870E+01),
  (  0.1554475925257E-05, 0.1624110906816E+01, 0.2513230340178E+02),
  (  0.2090948029241E-05, 0.5852052276256E+01, 0.1179062909082E+02),
  (  0.2000176345460E-05, 0.4072093298513E+01, 0.1778984560711E+02),
  (  0.1289535917759E-05, 0.5217019331069E+01, 0.7079373888424E+01),
  (  0.1281135307881E-05, 0.4802054538934E+01, 0.3738761453707E+01),
  (  0.1518229005692E-05, 0.8691914742502E+00, 0.2132990797783E+00),
  //DATA ((E0(I,J,1),I=1,3),J= 41, 50)),
  (  0.9450128579027E-06, 0.4601859529950E+01, 0.1097707878456E+02),
  (  0.7781119494996E-06, 0.1844352816694E+01, 0.8827390247185E+01),
  (  0.7733407759912E-06, 0.3582790154750E+01, 0.5507553240374E+01),
  (  0.7350644318120E-06, 0.2695277788230E+01, 0.1589072916335E+01),
  (  0.6535928827023E-06, 0.3651327986142E+01, 0.1176985366291E+02),
  (  0.6324624183656E-06, 0.2241302375862E+01, 0.6262300422539E+01),
  (  0.6298565300557E-06, 0.4407122406081E+01, 0.6303851278352E+01),
  (  0.8587037089179E-06, 0.3024307223119E+01, 0.1672837615881E+03),
  (  0.8299954491035E-06, 0.6192539428237E+01, 0.3340612434717E+01),
  (  0.6311263503401E-06, 0.2014758795416E+01, 0.7113454667900E-02),
  //DATA ((E0(I,J,1),I=1,3),J= 51, 60)),
  (  0.6005646745452E-06, 0.3399500503397E+01, 0.4136910472696E+01),
  (  0.7917715109929E-06, 0.2493386877837E+01, 0.6069776770667E+01),
  (  0.7556958099685E-06, 0.4159491740143E+01, 0.6496374930224E+01),
  (  0.6773228244949E-06, 0.4034162934230E+01, 0.9437762937313E+01),
  (  0.5370708577847E-06, 0.1562219163734E+01, 0.1194447056968E+01),
  (  0.5710804266203E-06, 0.2662730803386E+01, 0.6282095334605E+01),
  (  0.5709824583726E-06, 0.3985828430833E+01, 0.6284056366286E+01),
  (  0.5143950896447E-06, 0.1308144688689E+01, 0.6290189305114E+01),
  (  0.5088010604546E-06, 0.5352817214804E+01, 0.6275962395778E+01),
  (  0.4960369085172E-06, 0.2644267922349E+01, 0.6127655567643E+01),
  //DATA ((E0(I,J,1),I=1,3),J= 61, 70)),
  (  0.4803137891183E-06, 0.4008844192080E+01, 0.6438496133249E+01),
  (  0.5731747768225E-06, 0.3794550174597E+01, 0.3154687086868E+01),
  (  0.4735947960579E-06, 0.6107118308982E+01, 0.3128388763578E+01),
  (  0.4808348796625E-06, 0.4771458618163E+01, 0.8018209333619E+00),
  (  0.4115073743137E-06, 0.3327111335159E+01, 0.8429241228195E+01),
  (  0.5230575889287E-06, 0.5305708551694E+01, 0.1336797263425E+02),
  (  0.5133977889215E-06, 0.5784230738814E+01, 0.1235285262111E+02),
  (  0.5065815825327E-06, 0.2052064793679E+01, 0.1185621865188E+02),
  (  0.4339831593868E-06, 0.3644994195830E+01, 0.1726015463500E+02),
  (  0.3952928638953E-06, 0.4930376436758E+01, 0.5481254917084E+01),
  //DATA ((E0(I,J,1),I=1,3),J= 71, 80)),
  (  0.4898498111942E-06, 0.4542084219731E+00, 0.9225539266174E+01),
  (  0.4757490209328E-06, 0.3161126388878E+01, 0.5856477690889E+01),
  (  0.4727701669749E-06, 0.6214993845446E+00, 0.2544314396739E+01),
  (  0.3800966681863E-06, 0.3040132339297E+01, 0.4265981595566E+00),
  (  0.3257301077939E-06, 0.8064977360087E+00, 0.3930209696940E+01),
  (  0.3255810528674E-06, 0.1974147981034E+01, 0.2146165377750E+01),
  (  0.3252029748187E-06, 0.2845924913135E+01, 0.4164311961999E+01),
  (  0.3255505635308E-06, 0.3017900824120E+01, 0.5088628793478E+01),
  (  0.2801345211990E-06, 0.6109717793179E+01, 0.1256967486051E+02),
  (  0.3688987740970E-06, 0.2911550235289E+01, 0.1807370494127E+02),
  //DATA ((E0(I,J,1),I=1,3),J= 81, 90)),
  (  0.2475153429458E-06, 0.2179146025856E+01, 0.2629832328990E-01),
  (  0.3033457749150E-06, 0.1994161050744E+01, 0.4535059491685E+01),
  (  0.2186743763110E-06, 0.5125687237936E+01, 0.1137170464392E+02),
  (  0.2764777032774E-06, 0.4822646860252E+00, 0.1256262854127E+02),
  (  0.2199028768592E-06, 0.4637633293831E+01, 0.1255903824622E+02),
  (  0.2046482824760E-06, 0.1467038733093E+01, 0.7084896783808E+01),
  (  0.2611209147507E-06, 0.3044718783485E+00, 0.7143069561767E+02),
  (  0.2286079656818E-06, 0.4764220356805E+01, 0.8031092209206E+01),
  (  0.1855071202587E-06, 0.3383637774428E+01, 0.1748016358760E+01),
  (  0.2324669506784E-06, 0.6189088449251E+01, 0.1831953657923E+02),
  //DATA ((E0(I,J,1),I=1,3),J= 91,100)),
  (  0.1709528015688E-06, 0.5874966729774E+00, 0.4933208510675E+01),
  (  0.2168156875828E-06, 0.4302994009132E+01, 0.1044738781244E+02),
  (  0.2106675556535E-06, 0.3800475419891E+01, 0.7477522907414E+01),
  (  0.1430213830465E-06, 0.1294660846502E+01, 0.2942463415728E+01),
  (  0.1388396901944E-06, 0.4594797202114E+01, 0.8635942003952E+01),
  (  0.1922258844190E-06, 0.4943044543591E+00, 0.1729818233119E+02),
  (  0.1888460058292E-06, 0.2426943912028E+01, 0.1561374759853E+03),
  (  0.1789449386107E-06, 0.1582973303499E+00, 0.1592596075957E+01),
  (  0.1360803685374E-06, 0.5197240440504E+01, 0.1309584267300E+02),
  (  0.1504038014709E-06, 0.3120360916217E+01, 0.1649636139783E+02),
  //DATA ((E0(I,J,1),I=1,3),J=101,110)),
  (  0.1382769533389E-06, 0.6164702888205E+01, 0.7632943190217E+01),
  (  0.1438059769079E-06, 0.1437423770979E+01, 0.2042657109477E+02),
  (  0.1326303260037E-06, 0.3609688799679E+01, 0.1213955354133E+02),
  (  0.1159244950540E-06, 0.5463018167225E+01, 0.5331357529664E+01),
  (  0.1433118149136E-06, 0.6028909912097E+01, 0.7342457794669E+01),
  (  0.1234623148594E-06, 0.3109645574997E+01, 0.6279485555400E+01),
  (  0.1233949875344E-06, 0.3539359332866E+01, 0.6286666145492E+01),
  (  0.9927196061299E-07, 0.1259321569772E+01, 0.7234794171227E+01),
  (  0.1242302191316E-06, 0.1065949392609E+01, 0.1511046609763E+02),
  (  0.1098402195201E-06, 0.2192508743837E+01, 0.1098880815746E+02),
  //DATA ((E0(I,J,1),I=1,3),J=111,120)),
  (  0.1158191395315E-06, 0.4054411278650E+01, 0.5729506548653E+01),
  (  0.9048475596241E-07, 0.5429764748518E+01, 0.9623688285163E+01),
  (  0.8889853269023E-07, 0.5046586206575E+01, 0.6148010737701E+01),
  (  0.1048694242164E-06, 0.2628858030806E+01, 0.6836645152238E+01),
  (  0.1112308378646E-06, 0.4177292719907E+01, 0.1572083878776E+02),
  (  0.8631729709901E-07, 0.1601345232557E+01, 0.6418140963190E+01),
  (  0.8527816951664E-07, 0.2463888997513E+01, 0.1471231707864E+02),
  (  0.7892139456991E-07, 0.3154022088718E+01, 0.2118763888447E+01),
  (  0.1051782905236E-06, 0.4795035816088E+01, 0.1349867339771E+01),
  (  0.1048219943164E-06, 0.2952983395230E+01, 0.5999216516294E+01),
  //DATA ((E0(I,J,1),I=1,3),J=121,130)),
  (  0.7435760775143E-07, 0.5420547991464E+01, 0.6040347114260E+01),
  (  0.9869574106949E-07, 0.3695646753667E+01, 0.6566935184597E+01),
  (  0.9156886364226E-07, 0.3922675306609E+01, 0.5643178611111E+01),
  (  0.7006834356188E-07, 0.1233968624861E+01, 0.6525804586632E+01),
  (  0.9806170182601E-07, 0.1919542280684E+01, 0.2122839202813E+02),
  (  0.9052289673607E-07, 0.4615902724369E+01, 0.4690479774488E+01),
  (  0.7554200867893E-07, 0.1236863719072E+01, 0.1253985337760E+02),
  (  0.8215741286498E-07, 0.3286800101559E+00, 0.1097355562493E+02),
  (  0.7185178575397E-07, 0.5880942158367E+01, 0.6245048154254E+01),
  (  0.7130726476180E-07, 0.7674871987661E+00, 0.6321103546637E+01),
  //DATA ((E0(I,J,1),I=1,3),J=131,140)),
  (  0.6650894461162E-07, 0.6987129150116E+00, 0.5327476111629E+01),
  (  0.7396888823688E-07, 0.3576824794443E+01, 0.5368044267797E+00),
  (  0.7420588884775E-07, 0.5033615245369E+01, 0.2354323048545E+02),
  (  0.6141181642908E-07, 0.9449927045673E+00, 0.1296430071988E+02),
  (  0.6373557924058E-07, 0.6206342280341E+01, 0.9517183207817E+00),
  (  0.6359474329261E-07, 0.5036079095757E+01, 0.1990745094947E+01),
  (  0.5740173582646E-07, 0.6105106371350E+01, 0.9555997388169E+00),
  (  0.7019864084602E-07, 0.7237747359018E+00, 0.5225775174439E+00),
  (  0.6398054487042E-07, 0.3976367969666E+01, 0.2407292145756E+02),
  (  0.7797092650498E-07, 0.4305423910623E+01, 0.2200391463820E+02),
  //DATA ((E0(I,J,1),I=1,3),J=141,150)),
  (  0.6466760000900E-07, 0.3500136825200E+01, 0.5230807360890E+01),
  (  0.7529417043890E-07, 0.3514779246100E+01, 0.1842262939178E+02),
  (  0.6924571140892E-07, 0.2743457928679E+01, 0.1554202828031E+00),
  (  0.6220798650222E-07, 0.2242598118209E+01, 0.1845107853235E+02),
  (  0.5870209391853E-07, 0.2332832707527E+01, 0.6398972393349E+00),
  (  0.6263953473888E-07, 0.2191105358956E+01, 0.6277552955062E+01),
  (  0.6257781390012E-07, 0.4457559396698E+01, 0.6288598745829E+01),
  (  0.5697304945123E-07, 0.3499234761404E+01, 0.1551045220144E+01),
  (  0.6335438746791E-07, 0.6441691079251E+00, 0.5216580451554E+01),
  (  0.6377258441152E-07, 0.2252599151092E+01, 0.5650292065779E+01),
  //DATA ((E0(I,J,1),I=1,3),J=151,160)),
  (  0.6484841818165E-07, 0.1992812417646E+01, 0.1030928125552E+00),
  (  0.4735551485250E-07, 0.3744672082942E+01, 0.1431416805965E+02),
  (  0.4628595996170E-07, 0.1334226211745E+01, 0.5535693017924E+00),
  (  0.6258152336933E-07, 0.4395836159154E+01, 0.2608790314060E+02),
  (  0.6196171366594E-07, 0.2587043007997E+01, 0.8467247584405E+02),
  (  0.6159556952126E-07, 0.4782499769128E+01, 0.2394243902548E+03),
  (  0.4987741172394E-07, 0.7312257619924E+00, 0.7771377146812E+02),
  (  0.5459280703142E-07, 0.3001376372532E+01, 0.6179983037890E+01),
  (  0.4863461189999E-07, 0.3767222128541E+01, 0.9027992316901E+02),
  (  0.5349912093158E-07, 0.3663594450273E+01, 0.6386168663001E+01),
  //DATA ((E0(I,J,1),I=1,3),J=161,170)),
  (  0.5673725607806E-07, 0.4331187919049E+01, 0.6915859635113E+01),
  (  0.4745485060512E-07, 0.5816195745518E+01, 0.6282970628506E+01),
  (  0.4745379005326E-07, 0.8323672435672E+00, 0.6283181072386E+01),
  (  0.4049002796321E-07, 0.3785023976293E+01, 0.6254626709878E+01),
  (  0.4247084014515E-07, 0.2378220728783E+01, 0.7875671926403E+01),
  (  0.4026912363055E-07, 0.2864103423269E+01, 0.6311524991013E+01),
  (  0.4062935011774E-07, 0.2415408595975E+01, 0.3634620989887E+01),
  (  0.5347771048509E-07, 0.3343479309801E+01, 0.2515860172507E+02),
  (  0.4829494136505E-07, 0.2821742398262E+01, 0.5760498333002E+01),
  (  0.4342554404599E-07, 0.5624662458712E+01, 0.7238675589263E+01),
  //DATA ((E0(I,J,1),I=1,3),J=171,180)),
  (  0.4021599184361E-07, 0.5557250275009E+00, 0.1101510648075E+02),
  (  0.4104900474558E-07, 0.3296691780005E+01, 0.6709674010002E+01),
  (  0.4376532905131E-07, 0.3814443999443E+01, 0.6805653367890E+01),
  (  0.3314590480650E-07, 0.3560229189250E+01, 0.1259245002418E+02),
  (  0.3232421839643E-07, 0.5185389180568E+01, 0.1066495398892E+01),
  (  0.3541176318876E-07, 0.3921381909679E+01, 0.9917696840332E+01),
  (  0.3689831242681E-07, 0.4190658955386E+01, 0.1192625446156E+02),
  (  0.3890605376774E-07, 0.5546023371097E+01, 0.7478166569050E-01),
  (  0.3038559339780E-07, 0.6231032794494E+01, 0.1256621883632E+02),
  (  0.3137083969782E-07, 0.6207063419190E+01, 0.4292330755499E+01),
  //DATA ((E0(I,J,1),I=1,3),J=181,190)),
  (  0.4024004081854E-07, 0.1195257375713E+01, 0.1334167431096E+02),
  (  0.3300234879283E-07, 0.1804694240998E+01, 0.1057540660594E+02),
  (  0.3635399155575E-07, 0.5597811343500E+01, 0.6208294184755E+01),
  (  0.3032668691356E-07, 0.3191059366530E+01, 0.1805292951336E+02),
  (  0.2809652069058E-07, 0.4094348032570E+01, 0.3523159621801E-02),
  (  0.3696955383823E-07, 0.5219282738794E+01, 0.5966683958112E+01),
  (  0.3562894142503E-07, 0.1037247544554E+01, 0.6357857516136E+01),
  (  0.3510598524148E-07, 0.1430020816116E+01, 0.6599467742779E+01),
  (  0.3617736142953E-07, 0.3002911403677E+01, 0.6019991944201E+01),
  (  0.2624524910730E-07, 0.2437046757292E+01, 0.6702560555334E+01),
  //DATA ((E0(I,J,1),I=1,3),J=191,200)),
  (  0.2535824204490E-07, 0.1581594689647E+01, 0.3141537925223E+02),
  (  0.3519787226257E-07, 0.5379863121521E+01, 0.2505706758577E+03),
  (  0.2578406709982E-07, 0.4904222639329E+01, 0.1673046366289E+02),
  (  0.3423887981473E-07, 0.3646448997315E+01, 0.6546159756691E+01),
  (  0.2776083886467E-07, 0.3307829300144E+01, 0.1272157198369E+02),
  (  0.3379592818379E-07, 0.1747541251125E+01, 0.1494531617769E+02),
  (  0.3050255426284E-07, 0.1784689432607E-01, 0.4732030630302E+01),
  (  0.2652378350236E-07, 0.4420055276260E+01, 0.5863591145557E+01),
  (  0.2374498173768E-07, 0.3629773929208E+01, 0.2388894113936E+01),
  (  0.2716451255140E-07, 0.3079623706780E+01, 0.1202934727411E+02),
  //DATA ((E0(I,J,1),I=1,3),J=201,210)),
  (  0.3038583699229E-07, 0.3312487903507E+00, 0.1256608456547E+02),
  (  0.2220681228760E-07, 0.5265520401774E+01, 0.1336244973887E+02),
  (  0.3044156540912E-07, 0.4766664081250E+01, 0.2908881142201E+02),
  (  0.2731859923561E-07, 0.5069146530691E+01, 0.1391601904066E+02),
  (  0.2285603018171E-07, 0.5954935112271E+01, 0.6076890225335E+01),
  (  0.2025006454555E-07, 0.4061789589267E+01, 0.4701116388778E+01),
  (  0.2012597519804E-07, 0.2485047705241E+01, 0.6262720680387E+01),
  (  0.2003406962258E-07, 0.4163779209320E+01, 0.6303431020504E+01),
  (  0.2207863441371E-07, 0.6923839133828E+00, 0.6489261475556E+01),
  (  0.2481374305624E-07, 0.5944173595676E+01, 0.1204357418345E+02),
  //DATA ((E0(I,J,1),I=1,3),J=211,220)),
  (  0.2130923288870E-07, 0.4641013671967E+01, 0.5746271423666E+01),
  (  0.2446370543391E-07, 0.6125796518757E+01, 0.1495633313810E+00),
  (  0.1932492759052E-07, 0.2234572324504E+00, 0.1352175143971E+02),
  (  0.2600122568049E-07, 0.4281012405440E+01, 0.4590910121555E+01),
  (  0.2431754047488E-07, 0.1429943874870E+00, 0.1162474756779E+01),
  (  0.1875902869209E-07, 0.9781803816948E+00, 0.6279194432410E+01),
  (  0.1874381139426E-07, 0.5670368130173E+01, 0.6286957268481E+01),
  (  0.2156696047173E-07, 0.2008985006833E+01, 0.1813929450232E+02),
  (  0.1965076182484E-07, 0.2566186202453E+00, 0.4686889479442E+01),
  (  0.2334816372359E-07, 0.4408121891493E+01, 0.1002183730415E+02),
  //DATA ((E0(I,J,1),I=1,3),J=221,230)),
  (  0.1869937408802E-07, 0.5272745038656E+01, 0.2427287361862E+00),
  (  0.2436236460883E-07, 0.4407720479029E+01, 0.9514313292143E+02),
  (  0.1761365216611E-07, 0.1943892315074E+00, 0.1351787002167E+02),
  (  0.2156289480503E-07, 0.1418570924545E+01, 0.6037244212485E+01),
  (  0.2164748979255E-07, 0.4724603439430E+01, 0.2301353951334E+02),
  (  0.2222286670853E-07, 0.2400266874598E+01, 0.1266924451345E+02),
  (  0.2070901414929E-07, 0.5230348028732E+01, 0.6528907488406E+01),
  (  0.1792745177020E-07, 0.2099190328945E+01, 0.6819880277225E+01),
  (  0.1841802068445E-07, 0.3467527844848E+00, 0.6514761976723E+02),
  (  0.1578401631718E-07, 0.7098642356340E+00, 0.2077542790660E-01),
  //DATA ((E0(I,J,1),I=1,3),J=231,240)),
  (  0.1561690152531E-07, 0.5943349620372E+01, 0.6272439236156E+01),
  (  0.1558591045463E-07, 0.7040653478980E+00, 0.6293712464735E+01),
  (  0.1737356469576E-07, 0.4487064760345E+01, 0.1765478049437E+02),
  (  0.1434755619991E-07, 0.2993391570995E+01, 0.1102062672231E+00),
  (  0.1482187806654E-07, 0.2278049198251E+01, 0.1052268489556E+01),
  (  0.1424812827089E-07, 0.1682114725827E+01, 0.1311972100268E+02),
  (  0.1380282448623E-07, 0.3262668602579E+01, 0.1017725758696E+02),
  (  0.1811481244566E-07, 0.3187771221777E+01, 0.1887552587463E+02),
  (  0.1504446185696E-07, 0.5650162308647E+01, 0.7626583626240E-01),
  (  0.1740776154137E-07, 0.5487068607507E+01, 0.1965104848470E+02),
  //DATA ((E0(I,J,1),I=1,3),J=241,250)),
  (  0.1374339536251E-07, 0.5745688172201E+01, 0.6016468784579E+01),
  (  0.1761377477704E-07, 0.5748060203659E+01, 0.2593412433514E+02),
  (  0.1535138225795E-07, 0.6226848505790E+01, 0.9411464614024E+01),
  (  0.1788140543676E-07, 0.6189318878563E+01, 0.3301902111895E+02),
  (  0.1375002807996E-07, 0.5371812884394E+01, 0.6327837846670E+00),
  (  0.1242115758632E-07, 0.1471687569712E+01, 0.3894181736510E+01),
  (  0.1450977333938E-07, 0.4143836662127E+01, 0.1277945078067E+02),
  (  0.1297579575023E-07, 0.9003477661957E+00, 0.6549682916313E+01),
  (  0.1462667934821E-07, 0.5760505536428E+01, 0.1863592847156E+02),
  (  0.1381774374799E-07, 0.1085471729463E+01, 0.2379164476796E+01),
  //DATA ((E0(I,J,1),I=1,3),J=251,260)),
  (  0.1682333169307E-07, 0.5409870870133E+01, 0.1620077269078E+02),
  (  0.1190812918837E-07, 0.1397205174601E+01, 0.1149965630200E+02),
  (  0.1221434762106E-07, 0.9001804809095E+00, 0.1257326515556E+02),
  (  0.1549934644860E-07, 0.4262528275544E+01, 0.1820933031200E+02),
  (  0.1252138953050E-07, 0.1411642012027E+01, 0.6993008899458E+01),
  (  0.1237078905387E-07, 0.2844472403615E+01, 0.2435678079171E+02),
  (  0.1446953389615E-07, 0.5295835522223E+01, 0.3813291813120E-01),
  (  0.1388446457170E-07, 0.4969428135497E+01, 0.2458316379602E+00),
  (  0.1019339179228E-07, 0.2491369561806E+01, 0.6112403035119E+01),
  (  0.1258880815343E-07, 0.4679426248976E+01, 0.5429879531333E+01),
  //DATA ((E0(I,J,1),I=1,3),J=261,270)),
  (  0.1297768238261E-07, 0.1074509953328E+01, 0.1249137003520E+02),
  (  0.9913505718094E-08, 0.4735097918224E+01, 0.6247047890016E+01),
  (  0.9830453155969E-08, 0.4158649187338E+01, 0.6453748665772E+01),
  (  0.1192615865309E-07, 0.3438208613699E+01, 0.6290122169689E+01),
  (  0.9835874798277E-08, 0.1913300781229E+01, 0.6319103810876E+01),
  (  0.9639087569277E-08, 0.9487683644125E+00, 0.8273820945392E+01),
  (  0.1175716107001E-07, 0.3228141664287E+01, 0.6276029531202E+01),
  (  0.1018926508678E-07, 0.2216607854300E+01, 0.1254537627298E+02),
  (  0.9500087869225E-08, 0.2625116459733E+01, 0.1256517118505E+02),
  (  0.9664192916575E-08, 0.5860562449214E+01, 0.6259197520765E+01),
  //DATA ((E0(I,J,1),I=1,3),J=271,280)),
  (  0.9612858712203E-08, 0.7885682917381E+00, 0.6306954180126E+01),
  (  0.1117645675413E-07, 0.3932148831189E+01, 0.1779695906178E+02),
  (  0.1158864052160E-07, 0.9995605521691E+00, 0.1778273215245E+02),
  (  0.9021043467028E-08, 0.5263769742673E+01, 0.6172869583223E+01),
  (  0.8836134773563E-08, 0.1496843220365E+01, 0.1692165728891E+01),
  (  0.1045872200691E-07, 0.7009039517214E+00, 0.2204125344462E+00),
  (  0.1211463487798E-07, 0.4041544938511E+01, 0.8257698122054E+02),
  (  0.8541990804094E-08, 0.1447586692316E+01, 0.6393282117669E+01),
  (  0.1038720703636E-07, 0.4594249718112E+00, 0.1550861511662E+02),
  (  0.1126722351445E-07, 0.3925550579036E+01, 0.2061856251104E+00),
  //DATA ((E0(I,J,1),I=1,3),J=281,290)),
  (  0.8697373859631E-08, 0.4411341856037E+01, 0.9491756770005E+00),
  (  0.8869380028441E-08, 0.2402659724813E+01, 0.3903911373650E+01),
  (  0.9247014693258E-08, 0.1401579743423E+01, 0.6267823317922E+01),
  (  0.9205062930950E-08, 0.5245978000814E+01, 0.6298328382969E+01),
  (  0.8000745038049E-08, 0.3590803356945E+01, 0.2648454860559E+01),
  (  0.9168973650819E-08, 0.2470150501679E+01, 0.1498544001348E+03),
  (  0.1075444949238E-07, 0.1328606161230E+01, 0.3694923081589E+02),
  (  0.7817298525817E-08, 0.6162256225998E+01, 0.4804209201333E+01),
  (  0.9541469226356E-08, 0.3942568967039E+01, 0.1256713221673E+02),
  (  0.9821910122027E-08, 0.2360246287233E+00, 0.1140367694411E+02),
  //DATA ((E0(I,J,1),I=1,3),J=291,300)),
  (  0.9897822023777E-08, 0.4619805634280E+01, 0.2280573557157E+02),
  (  0.7737289283765E-08, 0.3784727847451E+01, 0.7834121070590E+01),
  (  0.9260204034710E-08, 0.2223352487601E+01, 0.2787043132925E+01),
  (  0.7320252888486E-08, 0.1288694636874E+01, 0.6282655592598E+01),
  (  0.7319785780946E-08, 0.5359869567774E+01, 0.6283496108294E+01),
  (  0.7147219933778E-08, 0.5516616675856E+01, 0.1725663147538E+02),
  (  0.7946502829878E-08, 0.2630459984567E+01, 0.1241073141809E+02),
  (  0.9001711808932E-08, 0.2849815827227E+01, 0.6281591679874E+01),
  (  0.8994041507257E-08, 0.3795244450750E+01, 0.6284560021018E+01),
  (  0.8298582787358E-08, 0.5236413127363E+00, 0.1241658836951E+02),
  //DATA ((E0(I,J,1),I=1,3),J=301,310)),
  (  0.8526596520710E-08, 0.4794605424426E+01, 0.1098419223922E+02),
  (  0.8209822103197E-08, 0.1578752370328E+01, 0.1096996532989E+02),
  (  0.6357049861094E-08, 0.5708926113761E+01, 0.1596186371003E+01),
  (  0.7370473179049E-08, 0.3842402530241E+01, 0.4061219149443E+01),
  (  0.7232154664726E-08, 0.3067548981535E+01, 0.1610006857377E+03),
  (  0.6328765494903E-08, 0.1313930030069E+01, 0.1193336791622E+02),
  (  0.8030064908595E-08, 0.3488500408886E+01, 0.8460828644453E+00),
  (  0.6275464259232E-08, 0.1532061626198E+01, 0.8531963191132E+00),
  (  0.7051897446325E-08, 0.3285859929993E+01, 0.5849364236221E+01),
  (  0.6161593705428E-08, 0.1477341999464E+01, 0.5573142801433E+01),
  //DATA ((E0(I,J,1),I=1,3),J=311,320)),
  (  0.7754683957278E-08, 0.1586118663096E+01, 0.8662240327241E+01),
  (  0.5889928990701E-08, 0.1304887868803E+01, 0.1232342296471E+02),
  (  0.5705756047075E-08, 0.4555333589350E+01, 0.1258692712880E+02),
  (  0.5964178808332E-08, 0.3001762842062E+01, 0.5333900173445E+01),
  (  0.6712446027467E-08, 0.4886780007595E+01, 0.1171295538178E+02),
  (  0.5941809275464E-08, 0.4701509603824E+01, 0.9779108567966E+01),
  (  0.5466993627395E-08, 0.4588357817278E+01, 0.1884211409667E+02),
  (  0.6340512090980E-08, 0.1164543038893E+01, 0.5217580628120E+02),
  (  0.6325505710045E-08, 0.3919171259645E+01, 0.1041998632314E+02),
  (  0.6164789509685E-08, 0.2143828253542E+01, 0.6151533897323E+01),
  //DATA ((E0(I,J,1),I=1,3),J=321,330)),
  (  0.5263330812430E-08, 0.6066564434241E+01, 0.1885275071096E+02),
  (  0.5597087780221E-08, 0.2926316429472E+01, 0.4337116142245E+00),
  (  0.5396556236817E-08, 0.3244303591505E+01, 0.6286362197481E+01),
  (  0.5396615148223E-08, 0.3404304703662E+01, 0.6279789503410E+01),
  (  0.7091832443341E-08, 0.8532377803192E+00, 0.4907302013889E+01),
  (  0.6572352589782E-08, 0.4901966774419E+01, 0.1176433076753E+02),
  (  0.5960236060795E-08, 0.1874672315797E+01, 0.1422690933580E-01),
  (  0.5125480043511E-08, 0.3735726064334E+01, 0.1245594543367E+02),
  (  0.5928241866410E-08, 0.4502033899935E+01, 0.6414617803568E+01),
  (  0.5249600357424E-08, 0.4372334799878E+01, 0.1151388321134E+02),
  //DATA ((E0(I,J,1),I=1,3),J=331,340)),
  (  0.6059171276087E-08, 0.2581617302908E+01, 0.6062663316000E+01),
  (  0.5295235081662E-08, 0.2974811513158E+01, 0.3496032717521E+01),
  (  0.5820561875933E-08, 0.1796073748244E+00, 0.2838593341516E+00),
  (  0.4754696606440E-08, 0.1981998136973E+01, 0.3104930017775E+01),
  (  0.6385053548955E-08, 0.2559174171605E+00, 0.6133512519065E+01),
  (  0.6589828273941E-08, 0.2750967106776E+01, 0.4087944051283E+02),
  (  0.5383376567189E-08, 0.6325947523578E+00, 0.2248384854122E+02),
  (  0.5928941683538E-08, 0.1672304519067E+01, 0.1581959461667E+01),
  (  0.4816060709794E-08, 0.3512566172575E+01, 0.9388005868221E+01),
  (  0.6003381586512E-08, 0.5610932219189E+01, 0.5326786718777E+01),
  //DATA ((E0(I,J,1),I=1,3),J=341,350)),
  (  0.5504225393105E-08, 0.4037501131256E+01, 0.6503488384892E+01),
  (  0.5353772620129E-08, 0.6122774968240E+01, 0.1735668374386E+03),
  (  0.5786253768544E-08, 0.5527984999515E+01, 0.1350651127443E+00),
  (  0.5065706702002E-08, 0.9980765573624E+00, 0.1248988586463E+02),
  (  0.5972838885276E-08, 0.6044489493203E+01, 0.2673594526851E+02),
  (  0.5323585877961E-08, 0.3924265998147E+01, 0.4171425416666E+01),
  (  0.5210772682858E-08, 0.6220111376901E+01, 0.2460261242967E+02),
  (  0.4726549040535E-08, 0.3716043206862E+01, 0.7232251527446E+01),
  (  0.6029425105059E-08, 0.8548704071116E+00, 0.3227113045244E+03),
  (  0.4481542826513E-08, 0.1426925072829E+01, 0.5547199253223E+01),
  //DATA ((E0(I,J,1),I=1,3),J=351,360)),
  (  0.5836024505068E-08, 0.7135651752625E-01, 0.7285056171570E+02),
  (  0.4137046613272E-08, 0.5330767643283E+01, 0.1087398597200E+02),
  (  0.5171977473924E-08, 0.4494262335353E+00, 0.1884570439172E+02),
  (  0.5694429833732E-08, 0.2952369582215E+01, 0.9723862754494E+02),
  (  0.4009158925298E-08, 0.3500003416535E+01, 0.6244942932314E+01),
  (  0.4784939596873E-08, 0.6196709413181E+01, 0.2929661536378E+02),
  (  0.3983725022610E-08, 0.5103690031897E+01, 0.4274518229222E+01),
  (  0.3870535232462E-08, 0.3187569587401E+01, 0.6321208768577E+01),
  (  0.5140501213951E-08, 0.1668924357457E+01, 0.1232032006293E+02),
  (  0.3849034819355E-08, 0.4445722510309E+01, 0.1726726808967E+02),
  //DATA ((E0(I,J,1),I=1,3),J=361,370)),
  (  0.4002383075060E-08, 0.5226224152423E+01, 0.7018952447668E+01),
  (  0.3890719543549E-08, 0.4371166550274E+01, 0.1491901785440E+02),
  (  0.4887084607881E-08, 0.5973556689693E+01, 0.1478866649112E+01),
  (  0.3739939287592E-08, 0.2089084714600E+01, 0.6922973089781E+01),
  (  0.5031925918209E-08, 0.4658371936827E+01, 0.1715706182245E+02),
  (  0.4387748764954E-08, 0.4825580552819E+01, 0.2331413144044E+03),
  (  0.4147398098865E-08, 0.3739003524998E+01, 0.1376059875786E+02),
  (  0.3719089993586E-08, 0.1148941386536E+01, 0.6297302759782E+01),
  (  0.3934238461056E-08, 0.1559893008343E+01, 0.7872148766781E+01),
  (  0.3672471375622E-08, 0.5516145383612E+01, 0.6268848941110E+01),
  //DATA ((E0(I,J,1),I=1,3),J=371,380)),
  (  0.3768911277583E-08, 0.6116053700563E+01, 0.4157198507331E+01),
  (  0.4033388417295E-08, 0.5076821746017E+01, 0.1567108171867E+02),
  (  0.3764194617832E-08, 0.8164676232075E+00, 0.3185192151914E+01),
  (  0.4840628226284E-08, 0.1360479453671E+01, 0.1252801878276E+02),
  (  0.4949443923785E-08, 0.2725622229926E+01, 0.1617106187867E+03),
  (  0.4117393089971E-08, 0.6054459628492E+00, 0.5642198095270E+01),
  (  0.3925754020428E-08, 0.8570462135210E+00, 0.2139354194808E+02),
  (  0.3630551757923E-08, 0.3552067338279E+01, 0.6294805223347E+01),
  (  0.3627274802357E-08, 0.3096565085313E+01, 0.6271346477544E+01),
  (  0.3806143885093E-08, 0.6367751709777E+00, 0.1725304118033E+02),
  //DATA ((E0(I,J,1),I=1,3),J=381,390)),
  (  0.4433254641565E-08, 0.4848461503937E+01, 0.7445550607224E+01),
  (  0.3712319846576E-08, 0.1331950643655E+01, 0.4194847048887E+00),
  (  0.3849847534783E-08, 0.4958368297746E+00, 0.9562891316684E+00),
  (  0.3483955430165E-08, 0.2237215515707E+01, 0.1161697602389E+02),
  (  0.3961912730982E-08, 0.3332402188575E+01, 0.2277943724828E+02),
  (  0.3419978244481E-08, 0.5785600576016E+01, 0.1362553364512E+02),
  (  0.3329417758177E-08, 0.9812676559709E-01, 0.1685848245639E+02),
  (  0.4207206893193E-08, 0.9494780468236E+00, 0.2986433403208E+02),
  (  0.3268548976410E-08, 0.1739332095686E+00, 0.5749861718712E+01),
  (  0.3321880082685E-08, 0.1423354800666E+01, 0.6279143387820E+01),
  //DATA ((E0(I,J,1),I=1,3),J=391,400)),
  (  0.4503173010852E-08, 0.2314972675293E+00, 0.1385561574497E+01),
  (  0.4316599090954E-08, 0.1012646782616E+00, 0.4176041334900E+01),
  (  0.3283493323850E-08, 0.5233306881265E+01, 0.6287008313071E+01),
  (  0.3164033542343E-08, 0.4005597257511E+01, 0.2099539292909E+02),
  (  0.4159720956725E-08, 0.5365676242020E+01, 0.5905702259363E+01),
  (  0.3565176892217E-08, 0.4284440620612E+01, 0.3932462625300E-02),
  (  0.3514440950221E-08, 0.4270562636575E+01, 0.7335344340001E+01),
  (  0.3540596871909E-08, 0.5953553201060E+01, 0.1234573916645E+02),
  (  0.2960769905118E-08, 0.1115180417718E+01, 0.2670964694522E+02),
  (  0.2962213739684E-08, 0.3863811918186E+01, 0.6408777551755E+00),
  //DATA ((E0(I,J,1),I=1,3),J=401,410)),
  (  0.3883556700251E-08, 0.1268617928302E+01, 0.6660449441528E+01),
  (  0.2919225516346E-08, 0.4908605223265E+01, 0.1375773836557E+01),
  (  0.3115158863370E-08, 0.3744519976885E+01, 0.3802769619140E-01),
  (  0.4099438144212E-08, 0.4173244670532E+01, 0.4480965020977E+02),
  (  0.2899531858964E-08, 0.5910601428850E+01, 0.2059724391010E+02),
  (  0.3289733429855E-08, 0.2488050078239E+01, 0.1081813534213E+02),
  (  0.3933075612875E-08, 0.1122363652883E+01, 0.3773735910827E+00),
  (  0.3021403764467E-08, 0.4951973724904E+01, 0.2982630633589E+02),
  (  0.2798598949757E-08, 0.5117057845513E+01, 0.1937891852345E+02),
  (  0.3397421302707E-08, 0.6104159180476E+01, 0.6923953605621E+01),
  //DATA ((E0(I,J,1),I=1,3),J=411,420)),
  (  0.3720398002179E-08, 0.1184933429829E+01, 0.3066615496545E+02),
  (  0.3598484186267E-08, 0.3505282086105E+01, 0.6147450479709E+01),
  (  0.3694594027310E-08, 0.2286651088141E+01, 0.2636725487657E+01),
  (  0.2680444152969E-08, 0.1871816775482E+00, 0.6816289982179E+01),
  (  0.3497574865641E-08, 0.3143251755431E+01, 0.6418701221183E+01),
  (  0.3130274129494E-08, 0.2462167316018E+01, 0.1235996607578E+02),
  (  0.3241119069551E-08, 0.4256374004686E+01, 0.1652265972112E+02),
  (  0.2601960842061E-08, 0.4970362941425E+01, 0.1045450126711E+02),
  (  0.2690601527504E-08, 0.2372657824898E+01, 0.3163918923335E+00),
  (  0.2908688152664E-08, 0.4232652627721E+01, 0.2828699048865E+02),
  //DATA ((E0(I,J,1),I=1,3),J=421,430)),
  (  0.3120456131875E-08, 0.3925747001137E+00, 0.2195415756911E+02),
  (  0.3148855423384E-08, 0.3093478330445E+01, 0.1172006883645E+02),
  (  0.3051044261017E-08, 0.5560948248212E+01, 0.6055599646783E+01),
  (  0.2826006876660E-08, 0.5072790310072E+01, 0.5120601093667E+01),
  (  0.3100034191711E-08, 0.4998530231096E+01, 0.1799603123222E+02),
  (  0.2398771640101E-08, 0.2561739802176E+01, 0.6255674361143E+01),
  (  0.2384002842728E-08, 0.4087420284111E+01, 0.6310477339748E+01),
  (  0.2842146517568E-08, 0.2515048217955E+01, 0.5469525544182E+01),
  (  0.2847674371340E-08, 0.5235326497443E+01, 0.1034429499989E+02),
  (  0.2903722140764E-08, 0.1088200795797E+01, 0.6510552054109E+01),
  //DATA ((E0(I,J,1),I=1,3),J=431,440)),
  (  0.3187610710605E-08, 0.4710624424816E+01, 0.1693792562116E+03),
  (  0.3048869992813E-08, 0.2857975896445E+00, 0.8390110365991E+01),
  (  0.2860216950984E-08, 0.2241619020815E+01, 0.2243449970715E+00),
  (  0.2701117683113E-08, 0.6651573305272E-01, 0.6129297044991E+01),
  (  0.2509891590152E-08, 0.1285135324585E+01, 0.1044027435778E+02),
  (  0.2623200252223E-08, 0.2981229834530E+00, 0.6436854655901E+01),
  (  0.2622541669202E-08, 0.6122470726189E+01, 0.9380959548977E+01),
  (  0.2818435667099E-08, 0.4251087148947E+01, 0.5934151399930E+01),
  (  0.2365196797465E-08, 0.3465070460790E+01, 0.2470570524223E+02),
  (  0.2358704646143E-08, 0.5791603815350E+01, 0.8671969964381E+01),
  //DATA ((E0(I,J,1),I=1,3),J=441,450)),
  (  0.2388299481390E-08, 0.4142483772941E+01, 0.7096626156709E+01),
  (  0.1996041217224E-08, 0.2101901889496E+01, 0.1727188400790E+02),
  (  0.2687593060336E-08, 0.1526689456959E+01, 0.7075506709219E+02),
  (  0.2618913670810E-08, 0.2397684236095E+01, 0.6632000300961E+01),
  (  0.2571523050364E-08, 0.5751929456787E+00, 0.6206810014183E+01),
  (  0.2582135006946E-08, 0.5595464352926E+01, 0.4873985990671E+02),
  (  0.2372530190361E-08, 0.5092689490655E+01, 0.1590676413561E+02),
  (  0.2357178484712E-08, 0.4444363527851E+01, 0.3097883698531E+01),
  (  0.2451590394723E-08, 0.3108251687661E+01, 0.6612329252343E+00),
  (  0.2370045949608E-08, 0.2608133861079E+01, 0.3459636466239E+02),
  //DATA ((E0(I,J,1),I=1,3),J=451,460)),
  (  0.2268997267358E-08, 0.3639717753384E+01, 0.2844914056730E-01),
  (  0.1731432137906E-08, 0.1741898445707E+00, 0.2019909489111E+02),
  (  0.1629869741622E-08, 0.3902225646724E+01, 0.3035599730800E+02),
  (  0.2206215801974E-08, 0.4971131250731E+01, 0.6281667977667E+01),
  (  0.2205469554680E-08, 0.1677462357110E+01, 0.6284483723224E+01),
  (  0.2148792362509E-08, 0.4236259604006E+01, 0.1980482729015E+02),
  (  0.1873733657847E-08, 0.5926814998687E+01, 0.2876692439167E+02),
  (  0.2026573758959E-08, 0.4349643351962E+01, 0.2449240616245E+02),
  (  0.1807770325110E-08, 0.5700940482701E+01, 0.2045286941806E+02),
  (  0.1881174408581E-08, 0.6601286363430E+00, 0.2358125818164E+02),
  //DATA ((E0(I,J,1),I=1,3),J=461,470)),
  (  0.1368023671690E-08, 0.2211098592752E+01, 0.2473415438279E+02),
  (  0.1720017916280E-08, 0.4942488551129E+01, 0.1679593901136E+03),
  (  0.1702427665131E-08, 0.1452233856386E+01, 0.3338575901272E+03),
  (  0.1414032510054E-08, 0.5525357721439E+01, 0.1624205518357E+03),
  (  0.1652626045364E-08, 0.4108794283624E+01, 0.8956999012000E+02),
  (  0.1642957769686E-08, 0.7344335209984E+00, 0.5267006960365E+02),
  (  0.1614952403624E-08, 0.3541213951363E+01, 0.3332657872986E+02),
  (  0.1535988291188E-08, 0.4031094072151E+01, 0.3852657435933E+02),
  (  0.1593193738177E-08, 0.4185136203609E+01, 0.2282781046519E+03),
  (  0.1074569126382E-08, 0.1720485636868E+01, 0.8397383534231E+02),
  //DATA ((E0(I,J,1),I=1,3),J=471,480)),
  (  0.1074408214509E-08, 0.2758613420318E+01, 0.8401985929482E+02),
  (  0.9700199670465E-09, 0.4216686842097E+01, 0.7826370942180E+02),
  (  0.1258433517061E-08, 0.2575068876639E+00, 0.3115650189215E+03),
  (  0.1240303229539E-08, 0.4800844956756E+00, 0.1784300471910E+03),
  (  0.9018345948127E-09, 0.3896756361552E+00, 0.5886454391678E+02),
  (  0.1135301432805E-08, 0.3700805023550E+00, 0.7842370451713E+02),
  (  0.9215887951370E-09, 0.4364579276638E+01, 0.1014262087719E+03),
  (  0.1055401054147E-08, 0.2156564222111E+01, 0.5660027930059E+02),
  (  0.1008725979831E-08, 0.5454015785234E+01, 0.4245678405627E+02),
  (  0.7217398104321E-09, 0.1597772562175E+01, 0.2457074661053E+03),
  //DATA ((E0(I,J,1),I=1,3),J=481,490)),
  (  0.6912033134447E-09, 0.5824090621461E+01, 0.1679936946371E+03),
  (  0.6833881523549E-09, 0.3578778482835E+01, 0.6053048899753E+02),
  (  0.4887304205142E-09, 0.3724362812423E+01, 0.9656299901946E+02),
  (  0.5173709754788E-09, 0.5422427507933E+01, 0.2442876000072E+03),
  (  0.4671353097145E-09, 0.2396106924439E+01, 0.1435713242844E+03),
  (  0.5652608439480E-09, 0.2804028838685E+01, 0.8365903305582E+02),
  (  0.5604061331253E-09, 0.1638816006247E+01, 0.8433466158131E+02),
  (  0.4712723365400E-09, 0.8979003224474E+00, 0.3164282286739E+03),
  (  0.4909967465112E-09, 0.3210426725516E+01, 0.4059982187939E+03),
  (  0.4771358267658E-09, 0.5308027211629E+01, 0.1805255418145E+03),
  //DATA ((E0(I,J,1),I=1,3),J=491,500)),
  (  0.3943451445989E-09, 0.2195145341074E+01, 0.2568537517081E+03),
  (  0.3952109120244E-09, 0.5081189491586E+01, 0.2449975330562E+03),
  (  0.3788134594789E-09, 0.4345171264441E+01, 0.1568131045107E+03),
  (  0.3738330190479E-09, 0.2613062847997E+01, 0.3948519331910E+03),
  (  0.3099866678136E-09, 0.2846760817689E+01, 0.1547176098872E+03),
  (  0.2002962716768E-09, 0.4921360989412E+01, 0.2268582385539E+03),
  (  0.2198291338754E-09, 0.1130360117454E+00, 0.1658638954901E+03),
  (  0.1491958330784E-09, 0.4228195232278E+01, 0.2219950288015E+03),
  (  0.1475384076173E-09, 0.3005721811604E+00, 0.3052819430710E+03),
  (  0.1661626624624E-09, 0.7830125621203E+00, 0.2526661704812E+03),
  //DATA ((E0(I,J,1),I=1,3),J=501,NE0X)),
  (  0.9015823460025E-10, 0.3807792942715E+01, 0.4171445043968E+03)),

  //*  Sun-to-Earth, T^0, Y	),
  //DATA ((E0(I,J,2),I=1,3),J=  1, 10)),
  ((  0.9998921098898E+00, 0.1826583913846E+00, 0.6283075850446E+01),
  ( -0.2442700893735E-01, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.8352929742915E-02, 0.1395277998680E+00, 0.1256615170089E+02),
  (  0.1046697300177E-03, 0.9641423109763E-01, 0.1884922755134E+02),
  (  0.3110841876663E-04, 0.5381140401712E+01, 0.8399684731857E+02),
  (  0.2570269094593E-04, 0.5301016407128E+01, 0.5296909721118E+00),
  (  0.2147389623610E-04, 0.2662510869850E+01, 0.1577343543434E+01),
  (  0.1680344384050E-04, 0.5207904119704E+01, 0.6279552690824E+01),
  (  0.1679117312193E-04, 0.4582187486968E+01, 0.6286599010068E+01),
  (  0.1440512068440E-04, 0.1900688517726E+01, 0.2352866153506E+01),
  //DATA ((E0(I,J,2),I=1,3),J= 11, 20)),
  (  0.1135139664999E-04, 0.5273108538556E+01, 0.5223693906222E+01),
  (  0.9345482571018E-05, 0.4503047687738E+01, 0.1203646072878E+02),
  (  0.9007418719568E-05, 0.1605621059637E+01, 0.1021328554739E+02),
  (  0.5671536712314E-05, 0.5812849070861E+00, 0.1059381944224E+01),
  (  0.7451401861666E-05, 0.2807346794836E+01, 0.3981490189893E+00),
  (  0.6393470057114E-05, 0.6029224133855E+01, 0.5753384878334E+01),
  (  0.6814275881697E-05, 0.6472990145974E+00, 0.4705732307012E+01),
  (  0.6113705628887E-05, 0.3813843419700E+01, 0.6812766822558E+01),
  (  0.4503851367273E-05, 0.4527804370996E+01, 0.5884926831456E+01),
  (  0.4522249141926E-05, 0.5991783029224E+01, 0.6256777527156E+01),
  //DATA ((E0(I,J,2),I=1,3),J= 21, 30)),
  (  0.4501794307018E-05, 0.3798703844397E+01, 0.6309374173736E+01),
  (  0.5514927480180E-05, 0.3961257833388E+01, 0.5507553240374E+01),
  (  0.4062862799995E-05, 0.5256247296369E+01, 0.6681224869435E+01),
  (  0.5414900429712E-05, 0.5499032014097E+01, 0.7755226100720E+00),
  (  0.5463153987424E-05, 0.6173092454097E+01, 0.1414349524433E+02),
  (  0.5071611859329E-05, 0.2870244247651E+01, 0.7860419393880E+01),
  (  0.2195112094455E-05, 0.2952338617201E+01, 0.1150676975667E+02),
  (  0.2279139233919E-05, 0.5951775132933E+01, 0.7058598460518E+01),
  (  0.2278386100876E-05, 0.4845456398785E+01, 0.4694002934110E+01),
  (  0.2559088003308E-05, 0.6945321117311E+00, 0.1216800268190E+02),
  //DATA ((E0(I,J,2),I=1,3),J= 31, 40)),
  (  0.2561079286856E-05, 0.6167224608301E+01, 0.7099330490126E+00),
  (  0.1792755796387E-05, 0.1400122509632E+01, 0.7962980379786E+00),
  (  0.1818715656502E-05, 0.4703347611830E+01, 0.6283142985870E+01),
  (  0.1818744924791E-05, 0.5086748900237E+01, 0.6283008715021E+01),
  (  0.1554518791390E-05, 0.5331008042713E-01, 0.2513230340178E+02),
  (  0.2063265737239E-05, 0.4283680484178E+01, 0.1179062909082E+02),
  (  0.1497613520041E-05, 0.6074207826073E+01, 0.5486777812467E+01),
  (  0.2000617940427E-05, 0.2501426281450E+01, 0.1778984560711E+02),
  (  0.1289731195580E-05, 0.3646340599536E+01, 0.7079373888424E+01),
  (  0.1282657998934E-05, 0.3232864804902E+01, 0.3738761453707E+01),
  //DATA ((E0(I,J,2),I=1,3),J= 41, 50)),
  (  0.1528915968658E-05, 0.5581433416669E+01, 0.2132990797783E+00),
  (  0.1187304098432E-05, 0.5453576453694E+01, 0.9437762937313E+01),
  (  0.7842782928118E-06, 0.2823953922273E+00, 0.8827390247185E+01),
  (  0.7352892280868E-06, 0.1124369580175E+01, 0.1589072916335E+01),
  (  0.6570189360797E-06, 0.2089154042840E+01, 0.1176985366291E+02),
  (  0.6324967590410E-06, 0.6704855581230E+00, 0.6262300422539E+01),
  (  0.6298289872283E-06, 0.2836414855840E+01, 0.6303851278352E+01),
  (  0.6476686465855E-06, 0.4852433866467E+00, 0.7113454667900E-02),
  (  0.8587034651234E-06, 0.1453511005668E+01, 0.1672837615881E+03),
  (  0.8068948788113E-06, 0.9224087798609E+00, 0.6069776770667E+01),
  //DATA ((E0(I,J,2),I=1,3),J= 51, 60)),
  (  0.8353786011661E-06, 0.4631707184895E+01, 0.3340612434717E+01),
  (  0.6009324532132E-06, 0.1829498827726E+01, 0.4136910472696E+01),
  (  0.7558158559566E-06, 0.2588596800317E+01, 0.6496374930224E+01),
  (  0.5809279504503E-06, 0.5516818853476E+00, 0.1097707878456E+02),
  (  0.5374131950254E-06, 0.6275674734960E+01, 0.1194447056968E+01),
  (  0.5711160507326E-06, 0.1091905956872E+01, 0.6282095334605E+01),
  (  0.5710183170746E-06, 0.2415001635090E+01, 0.6284056366286E+01),
  (  0.5144373590610E-06, 0.6020336443438E+01, 0.6290189305114E+01),
  (  0.5103108927267E-06, 0.3775634564605E+01, 0.6275962395778E+01),
  (  0.4960654697891E-06, 0.1073450946756E+01, 0.6127655567643E+01),
  //DATA ((E0(I,J,2),I=1,3),J= 61, 70)),
  (  0.4786385689280E-06, 0.2431178012310E+01, 0.6438496133249E+01),
  (  0.6109911263665E-06, 0.5343356157914E+01, 0.3154687086868E+01),
  (  0.4839898944024E-06, 0.5830833594047E-01, 0.8018209333619E+00),
  (  0.4734822623919E-06, 0.4536080134821E+01, 0.3128388763578E+01),
  (  0.4834741473290E-06, 0.2585090489754E+00, 0.7084896783808E+01),
  (  0.5134858581156E-06, 0.4213317172603E+01, 0.1235285262111E+02),
  (  0.5064004264978E-06, 0.4814418806478E+00, 0.1185621865188E+02),
  (  0.3753476772761E-06, 0.1599953399788E+01, 0.8429241228195E+01),
  (  0.4935264014283E-06, 0.2157417556873E+01, 0.2544314396739E+01),
  (  0.3950929600897E-06, 0.3359394184254E+01, 0.5481254917084E+01),
  //DATA ((E0(I,J,2),I=1,3),J= 71, 80)),
  (  0.4895849789777E-06, 0.5165704376558E+01, 0.9225539266174E+01),
  (  0.4215241688886E-06, 0.2065368800993E+01, 0.1726015463500E+02),
  (  0.3796773731132E-06, 0.1468606346612E+01, 0.4265981595566E+00),
  (  0.3114178142515E-06, 0.3615638079474E+01, 0.2146165377750E+01),
  (  0.3260664220838E-06, 0.4417134922435E+01, 0.4164311961999E+01),
  (  0.3976996123008E-06, 0.4700866883004E+01, 0.5856477690889E+01),
  (  0.2801459672924E-06, 0.4538902060922E+01, 0.1256967486051E+02),
  (  0.3638931868861E-06, 0.1334197991475E+01, 0.1807370494127E+02),
  (  0.2487013269476E-06, 0.3749275558275E+01, 0.2629832328990E-01),
  (  0.3034165481994E-06, 0.4236622030873E+00, 0.4535059491685E+01),
  //DATA ((E0(I,J,2),I=1,3),J= 81, 90)),
  (  0.2676278825586E-06, 0.5970848007811E+01, 0.3930209696940E+01),
  (  0.2764903818918E-06, 0.5194636754501E+01, 0.1256262854127E+02),
  (  0.2485149930507E-06, 0.1002434207846E+01, 0.5088628793478E+01),
  (  0.2199305540941E-06, 0.3066773098403E+01, 0.1255903824622E+02),
  (  0.2571106500435E-06, 0.7588312459063E+00, 0.1336797263425E+02),
  (  0.2049751817158E-06, 0.3444977434856E+01, 0.1137170464392E+02),
  (  0.2599707296297E-06, 0.1873128542205E+01, 0.7143069561767E+02),
  (  0.1785018072217E-06, 0.5015891306615E+01, 0.1748016358760E+01),
  (  0.2324833891115E-06, 0.4618271239730E+01, 0.1831953657923E+02),
  (  0.1709711119545E-06, 0.5300003455669E+01, 0.4933208510675E+01),
  //DATA ((E0(I,J,2),I=1,3),J= 91,100)),
  (  0.2107159351716E-06, 0.2229819815115E+01, 0.7477522907414E+01),
  (  0.1750333080295E-06, 0.6161485880008E+01, 0.1044738781244E+02),
  (  0.2000598210339E-06, 0.2967357299999E+01, 0.8031092209206E+01),
  (  0.1380920248681E-06, 0.3027007923917E+01, 0.8635942003952E+01),
  (  0.1412460470299E-06, 0.6037597163798E+01, 0.2942463415728E+01),
  (  0.1888459803001E-06, 0.8561476243374E+00, 0.1561374759853E+03),
  (  0.1788370542585E-06, 0.4869736290209E+01, 0.1592596075957E+01),
  (  0.1360893296167E-06, 0.3626411886436E+01, 0.1309584267300E+02),
  (  0.1506846530160E-06, 0.1550975377427E+01, 0.1649636139783E+02),
  (  0.1800913376176E-06, 0.2075826033190E+01, 0.1729818233119E+02),
  //DATA ((E0(I,J,2),I=1,3),J=101,110)),
  (  0.1436261390649E-06, 0.6148876420255E+01, 0.2042657109477E+02),
  (  0.1220227114151E-06, 0.4382583879906E+01, 0.7632943190217E+01),
  (  0.1337883603592E-06, 0.2036644327361E+01, 0.1213955354133E+02),
  (  0.1159326650738E-06, 0.3892276994687E+01, 0.5331357529664E+01),
  (  0.1352853128569E-06, 0.1447950649744E+01, 0.1673046366289E+02),
  (  0.1433408296083E-06, 0.4457854692961E+01, 0.7342457794669E+01),
  (  0.1234701666518E-06, 0.1538818147151E+01, 0.6279485555400E+01),
  (  0.1234027192007E-06, 0.1968523220760E+01, 0.6286666145492E+01),
  (  0.1244024091797E-06, 0.5779803499985E+01, 0.1511046609763E+02),
  (  0.1097934945516E-06, 0.6210975221388E+00, 0.1098880815746E+02),
  //DATA ((E0(I,J,2),I=1,3),J=111,120)),
  (  0.1254611329856E-06, 0.2591963807998E+01, 0.1572083878776E+02),
  (  0.1158247286784E-06, 0.2483612812670E+01, 0.5729506548653E+01),
  (  0.9039078252960E-07, 0.3857554579796E+01, 0.9623688285163E+01),
  (  0.9108024978836E-07, 0.5826368512984E+01, 0.7234794171227E+01),
  (  0.8887068108436E-07, 0.3475694573987E+01, 0.6148010737701E+01),
  (  0.8632374035438E-07, 0.3059070488983E-01, 0.6418140963190E+01),
  (  0.7893186992967E-07, 0.1583194837728E+01, 0.2118763888447E+01),
  (  0.8297650201172E-07, 0.8519770534637E+00, 0.1471231707864E+02),
  (  0.1019759578988E-06, 0.1319598738732E+00, 0.1349867339771E+01),
  (  0.1010037696236E-06, 0.9937860115618E+00, 0.6836645152238E+01),
  //DATA ((E0(I,J,2),I=1,3),J=121,130)),
  (  0.1047727548266E-06, 0.1382138405399E+01, 0.5999216516294E+01),
  (  0.7351993881086E-07, 0.3833397851735E+01, 0.6040347114260E+01),
  (  0.9868771092341E-07, 0.2124913814390E+01, 0.6566935184597E+01),
  (  0.7007321959390E-07, 0.5946305343763E+01, 0.6525804586632E+01),
  (  0.6861411679709E-07, 0.4574654977089E+01, 0.7238675589263E+01),
  (  0.7554519809614E-07, 0.5949232686844E+01, 0.1253985337760E+02),
  (  0.9541880448335E-07, 0.3495242990564E+01, 0.2122839202813E+02),
  (  0.7185606722155E-07, 0.4310113471661E+01, 0.6245048154254E+01),
  (  0.7131360871710E-07, 0.5480309323650E+01, 0.6321103546637E+01),
  (  0.6651142021039E-07, 0.5411097713654E+01, 0.5327476111629E+01),
  //DATA ((E0(I,J,2),I=1,3),J=131,140)),
  (  0.8538618213667E-07, 0.1827849973951E+01, 0.1101510648075E+02),
  (  0.8634954288044E-07, 0.5443584943349E+01, 0.5643178611111E+01),
  (  0.7449415051484E-07, 0.2011535459060E+01, 0.5368044267797E+00),
  (  0.7421047599169E-07, 0.3464562529249E+01, 0.2354323048545E+02),
  (  0.6140694354424E-07, 0.5657556228815E+01, 0.1296430071988E+02),
  (  0.6353525143033E-07, 0.3463816593821E+01, 0.1990745094947E+01),
  (  0.6221964013447E-07, 0.1532259498697E+01, 0.9517183207817E+00),
  (  0.5852480257244E-07, 0.1375396598875E+01, 0.9555997388169E+00),
  (  0.6398637498911E-07, 0.2405645801972E+01, 0.2407292145756E+02),
  (  0.7039744069878E-07, 0.5397541799027E+01, 0.5225775174439E+00),
  //DATA ((E0(I,J,2),I=1,3),J=141,150)),
  (  0.6977997694382E-07, 0.4762347105419E+01, 0.1097355562493E+02),
  (  0.7460629558396E-07, 0.2711944692164E+01, 0.2200391463820E+02),
  (  0.5376577536101E-07, 0.2352980430239E+01, 0.1431416805965E+02),
  (  0.7530607893556E-07, 0.1943940180699E+01, 0.1842262939178E+02),
  (  0.6822928971605E-07, 0.4337651846959E+01, 0.1554202828031E+00),
  (  0.6220772380094E-07, 0.6716871369278E+00, 0.1845107853235E+02),
  (  0.6586950799043E-07, 0.2229714460505E+01, 0.5216580451554E+01),
  (  0.5873800565771E-07, 0.7627013920580E+00, 0.6398972393349E+00),
  (  0.6264346929745E-07, 0.6202785478961E+00, 0.6277552955062E+01),
  (  0.6257929115669E-07, 0.2886775596668E+01, 0.6288598745829E+01),
  //DATA ((E0(I,J,2),I=1,3),J=151,160)),
  (  0.5343536033409E-07, 0.1977241012051E+01, 0.4690479774488E+01),
  (  0.5587849781714E-07, 0.1922923484825E+01, 0.1551045220144E+01),
  (  0.6905100845603E-07, 0.3570757164631E+01, 0.1030928125552E+00),
  (  0.6178957066649E-07, 0.5197558947765E+01, 0.5230807360890E+01),
  (  0.6187270224331E-07, 0.8193497368922E+00, 0.5650292065779E+01),
  (  0.5385664291426E-07, 0.5406336665586E+01, 0.7771377146812E+02),
  (  0.6329363917926E-07, 0.2837760654536E+01, 0.2608790314060E+02),
  (  0.4546018761604E-07, 0.2933580297050E+01, 0.5535693017924E+00),
  (  0.6196091049375E-07, 0.4157871494377E+01, 0.8467247584405E+02),
  (  0.6159555108218E-07, 0.3211703561703E+01, 0.2394243902548E+03),
  //DATA ((E0(I,J,2),I=1,3),J=161,170)),
  (  0.4995340539317E-07, 0.1459098102922E+01, 0.4732030630302E+01),
  (  0.5457031243572E-07, 0.1430457676136E+01, 0.6179983037890E+01),
  (  0.4863461418397E-07, 0.2196425916730E+01, 0.9027992316901E+02),
  (  0.5342947626870E-07, 0.2086612890268E+01, 0.6386168663001E+01),
  (  0.5674296648439E-07, 0.2760204966535E+01, 0.6915859635113E+01),
  (  0.4745783120161E-07, 0.4245368971862E+01, 0.6282970628506E+01),
  (  0.4745676961198E-07, 0.5544725787016E+01, 0.6283181072386E+01),
  (  0.4049796869973E-07, 0.2213984363586E+01, 0.6254626709878E+01),
  (  0.4248333596940E-07, 0.8075781952896E+00, 0.7875671926403E+01),
  (  0.4027178070205E-07, 0.1293268540378E+01, 0.6311524991013E+01),
  //DATA ((E0(I,J,2),I=1,3),J=171,180)),
  (  0.4066543943476E-07, 0.3986141175804E+01, 0.3634620989887E+01),
  (  0.4858863787880E-07, 0.1276112738231E+01, 0.5760498333002E+01),
  (  0.5277398263530E-07, 0.4916111741527E+01, 0.2515860172507E+02),
  (  0.4105635656559E-07, 0.1725805864426E+01, 0.6709674010002E+01),
  (  0.4376781925772E-07, 0.2243642442106E+01, 0.6805653367890E+01),
  (  0.3235827894693E-07, 0.3614135118271E+01, 0.1066495398892E+01),
  (  0.3073244740308E-07, 0.2460873393460E+01, 0.5863591145557E+01),
  (  0.3088609271373E-07, 0.5678431771790E+01, 0.9917696840332E+01),
  (  0.3393022279836E-07, 0.3814017477291E+01, 0.1391601904066E+02),
  (  0.3038686508802E-07, 0.4660216229171E+01, 0.1256621883632E+02),
  //DATA ((E0(I,J,2),I=1,3),J=181,190)),
  (  0.4019677752497E-07, 0.5906906243735E+01, 0.1334167431096E+02),
  (  0.3288834998232E-07, 0.9536146445882E+00, 0.1620077269078E+02),
  (  0.3889973794631E-07, 0.3942205097644E+01, 0.7478166569050E-01),
  (  0.3050438987141E-07, 0.1624810271286E+01, 0.1805292951336E+02),
  (  0.3601142564638E-07, 0.4030467142575E+01, 0.6208294184755E+01),
  (  0.3689015557141E-07, 0.3648878818694E+01, 0.5966683958112E+01),
  (  0.3563471893565E-07, 0.5749584017096E+01, 0.6357857516136E+01),
  (  0.2776183170667E-07, 0.2630124187070E+01, 0.3523159621801E-02),
  (  0.2922350530341E-07, 0.1790346403629E+01, 0.1272157198369E+02),
  (  0.3511076917302E-07, 0.6142198301611E+01, 0.6599467742779E+01),
  //DATA ((E0(I,J,2),I=1,3),J=191,200)),
  (  0.3619351007632E-07, 0.1432421386492E+01, 0.6019991944201E+01),
  (  0.2561254711098E-07, 0.2302822475792E+01, 0.1259245002418E+02),
  (  0.2626903942920E-07, 0.8660470994571E+00, 0.6702560555334E+01),
  (  0.2550187397083E-07, 0.6069721995383E+01, 0.1057540660594E+02),
  (  0.2535873526138E-07, 0.1079020331795E-01, 0.3141537925223E+02),
  (  0.3519786153847E-07, 0.3809066902283E+01, 0.2505706758577E+03),
  (  0.3424651492873E-07, 0.2075435114417E+01, 0.6546159756691E+01),
  (  0.2372676630861E-07, 0.2057803120154E+01, 0.2388894113936E+01),
  (  0.2710980779541E-07, 0.1510068488010E+01, 0.1202934727411E+02),
  (  0.3038710889704E-07, 0.5043617528901E+01, 0.1256608456547E+02),
  //DATA ((E0(I,J,2),I=1,3),J=201,210)),
  (  0.2220364130585E-07, 0.3694793218205E+01, 0.1336244973887E+02),
  (  0.3025880825460E-07, 0.5450618999049E-01, 0.2908881142201E+02),
  (  0.2784493486864E-07, 0.3381164084502E+01, 0.1494531617769E+02),
  (  0.2294414142438E-07, 0.4382309025210E+01, 0.6076890225335E+01),
  (  0.2012723294724E-07, 0.9142212256518E+00, 0.6262720680387E+01),
  (  0.2036357831958E-07, 0.5676172293154E+01, 0.4701116388778E+01),
  (  0.2003474823288E-07, 0.2592767977625E+01, 0.6303431020504E+01),
  (  0.2207144900109E-07, 0.5404976271180E+01, 0.6489261475556E+01),
  (  0.2481664905135E-07, 0.4373284587027E+01, 0.1204357418345E+02),
  (  0.2674949182295E-07, 0.5859182188482E+01, 0.4590910121555E+01),
  //DATA ((E0(I,J,2),I=1,3),J=211,220)),
  (  0.2450554720322E-07, 0.4555381557451E+01, 0.1495633313810E+00),
  (  0.2601975986457E-07, 0.3933165584959E+01, 0.1965104848470E+02),
  (  0.2199860022848E-07, 0.5227977189087E+01, 0.1351787002167E+02),
  (  0.2448121172316E-07, 0.4858060353949E+01, 0.1162474756779E+01),
  (  0.1876014864049E-07, 0.5690546553605E+01, 0.6279194432410E+01),
  (  0.1874513219396E-07, 0.4099539297446E+01, 0.6286957268481E+01),
  (  0.2156380842559E-07, 0.4382594769913E+00, 0.1813929450232E+02),
  (  0.1981691240061E-07, 0.1829784152444E+01, 0.4686889479442E+01),
  (  0.2329992648539E-07, 0.2836254278973E+01, 0.1002183730415E+02),
  (  0.1765184135302E-07, 0.2803494925833E+01, 0.4292330755499E+01),
  //DATA ((E0(I,J,2),I=1,3),J=221,230)),
  (  0.2436368366085E-07, 0.2836897959677E+01, 0.9514313292143E+02),
  (  0.2164089203889E-07, 0.6127522446024E+01, 0.6037244212485E+01),
  (  0.1847755034221E-07, 0.3683163635008E+01, 0.2427287361862E+00),
  (  0.1674798769966E-07, 0.3316993867246E+00, 0.1311972100268E+02),
  (  0.2222542124356E-07, 0.8294097805480E+00, 0.1266924451345E+02),
  (  0.2071074505925E-07, 0.3659492220261E+01, 0.6528907488406E+01),
  (  0.1608224471835E-07, 0.4774492067182E+01, 0.1352175143971E+02),
  (  0.1857583439071E-07, 0.2873120597682E+01, 0.8662240327241E+01),
  (  0.1793018836159E-07, 0.5282441177929E+00, 0.6819880277225E+01),
  (  0.1575391221692E-07, 0.1320789654258E+01, 0.1102062672231E+00),
  //DATA ((E0(I,J,2),I=1,3),J=231,240)),
  (  0.1840132009557E-07, 0.1917110916256E+01, 0.6514761976723E+02),
  (  0.1760917288281E-07, 0.2972635937132E+01, 0.5746271423666E+01),
  (  0.1561779518516E-07, 0.4372569261981E+01, 0.6272439236156E+01),
  (  0.1558687885205E-07, 0.5416424926425E+01, 0.6293712464735E+01),
  (  0.1951359382579E-07, 0.3094448898752E+01, 0.2301353951334E+02),
  (  0.1569144275614E-07, 0.2802103689808E+01, 0.1765478049437E+02),
  (  0.1479130389462E-07, 0.2136435020467E+01, 0.2077542790660E-01),
  (  0.1467828510764E-07, 0.7072627435674E+00, 0.1052268489556E+01),
  (  0.1627627337440E-07, 0.3947607143237E+01, 0.6327837846670E+00),
  (  0.1503498479758E-07, 0.4079248909190E+01, 0.7626583626240E-01),
  //DATA ((E0(I,J,2),I=1,3),J=241,250)),
  (  0.1297967708237E-07, 0.6269637122840E+01, 0.1149965630200E+02),
  (  0.1374416896634E-07, 0.4175657970702E+01, 0.6016468784579E+01),
  (  0.1783812325219E-07, 0.1476540547560E+01, 0.3301902111895E+02),
  (  0.1525884228756E-07, 0.4653477715241E+01, 0.9411464614024E+01),
  (  0.1451067396763E-07, 0.2573001128225E+01, 0.1277945078067E+02),
  (  0.1297713111950E-07, 0.5612799618771E+01, 0.6549682916313E+01),
  (  0.1462784012820E-07, 0.4189661623870E+01, 0.1863592847156E+02),
  (  0.1384185980007E-07, 0.2656915472196E+01, 0.2379164476796E+01),
  (  0.1221497599801E-07, 0.5612515760138E+01, 0.1257326515556E+02),
  (  0.1560574525896E-07, 0.4783414317919E+01, 0.1887552587463E+02),
  //DATA ((E0(I,J,2),I=1,3),J=251,260)),
  (  0.1544598372036E-07, 0.2694431138063E+01, 0.1820933031200E+02),
  (  0.1531678928696E-07, 0.4105103489666E+01, 0.2593412433514E+02),
  (  0.1349321503795E-07, 0.3082437194015E+00, 0.5120601093667E+01),
  (  0.1252030290917E-07, 0.6124072334087E+01, 0.6993008899458E+01),
  (  0.1459243816687E-07, 0.3733103981697E+01, 0.3813291813120E-01),
  (  0.1226103625262E-07, 0.1267127706817E+01, 0.2435678079171E+02),
  (  0.1019449641504E-07, 0.4367790112269E+01, 0.1725663147538E+02),
  (  0.1380789433607E-07, 0.3387201768700E+01, 0.2458316379602E+00),
  (  0.1019453421658E-07, 0.9204143073737E+00, 0.6112403035119E+01),
  (  0.1297929434405E-07, 0.5786874896426E+01, 0.1249137003520E+02),
  //DATA ((E0(I,J,2),I=1,3),J=261,270)),
  (  0.9912677786097E-08, 0.3164232870746E+01, 0.6247047890016E+01),
  (  0.9829386098599E-08, 0.2586762413351E+01, 0.6453748665772E+01),
  (  0.1226807746104E-07, 0.6239068436607E+01, 0.5429879531333E+01),
  (  0.1192691755997E-07, 0.1867380051424E+01, 0.6290122169689E+01),
  (  0.9836499227081E-08, 0.3424716293727E+00, 0.6319103810876E+01),
  (  0.9642862564285E-08, 0.5661372990657E+01, 0.8273820945392E+01),
  (  0.1165184404862E-07, 0.5768367239093E+01, 0.1778273215245E+02),
  (  0.1175794418818E-07, 0.1657351222943E+01, 0.6276029531202E+01),
  (  0.1018948635601E-07, 0.6458292350865E+00, 0.1254537627298E+02),
  (  0.9500383606676E-08, 0.1054306140741E+01, 0.1256517118505E+02),
  //DATA ((E0(I,J,2),I=1,3),J=271,280)),
  (  0.1227512202906E-07, 0.2505278379114E+01, 0.2248384854122E+02),
  (  0.9664792009993E-08, 0.4289737277000E+01, 0.6259197520765E+01),
  (  0.9613285666331E-08, 0.5500597673141E+01, 0.6306954180126E+01),
  (  0.1117906736211E-07, 0.2361405953468E+01, 0.1779695906178E+02),
  (  0.9611378640782E-08, 0.2851310576269E+01, 0.2061856251104E+00),
  (  0.8845354852370E-08, 0.6208777705343E+01, 0.1692165728891E+01),
  (  0.1054046966600E-07, 0.5413091423934E+01, 0.2204125344462E+00),
  (  0.1215539124483E-07, 0.5613969479755E+01, 0.8257698122054E+02),
  (  0.9932460955209E-08, 0.1106124877015E+01, 0.1017725758696E+02),
  (  0.8785804715043E-08, 0.2869224476477E+01, 0.9491756770005E+00),
  //DATA ((E0(I,J,2),I=1,3),J=281,290)),
  (  0.8538084097562E-08, 0.6159640899344E+01, 0.6393282117669E+01),
  (  0.8648994369529E-08, 0.1374901198784E+01, 0.4804209201333E+01),
  (  0.1039063219067E-07, 0.5171080641327E+01, 0.1550861511662E+02),
  (  0.8867983926439E-08, 0.8317320304902E+00, 0.3903911373650E+01),
  (  0.8327495955244E-08, 0.3605591969180E+01, 0.6172869583223E+01),
  (  0.9243088356133E-08, 0.6114299196843E+01, 0.6267823317922E+01),
  (  0.9205657357835E-08, 0.3675153683737E+01, 0.6298328382969E+01),
  (  0.1033269714606E-07, 0.3313328813024E+01, 0.5573142801433E+01),
  (  0.8001706275552E-08, 0.2019980960053E+01, 0.2648454860559E+01),
  (  0.9171858254191E-08, 0.8992015524177E+00, 0.1498544001348E+03),
  //DATA ((E0(I,J,2),I=1,3),J=291,300)),
  (  0.1075327150242E-07, 0.2898669963648E+01, 0.3694923081589E+02),
  (  0.9884866689828E-08, 0.4946715904478E+01, 0.1140367694411E+02),
  (  0.9541835576677E-08, 0.2371787888469E+01, 0.1256713221673E+02),
  (  0.7739903376237E-08, 0.2213775190612E+01, 0.7834121070590E+01),
  (  0.7311962684106E-08, 0.3429378787739E+01, 0.1192625446156E+02),
  (  0.9724904869624E-08, 0.6195878564404E+01, 0.2280573557157E+02),
  (  0.9251628983612E-08, 0.6511509527390E+00, 0.2787043132925E+01),
  (  0.7320763787842E-08, 0.6001083639421E+01, 0.6282655592598E+01),
  (  0.7320296650962E-08, 0.3789073265087E+01, 0.6283496108294E+01),
  (  0.7947032271039E-08, 0.1059659582204E+01, 0.1241073141809E+02),
  //DATA ((E0(I,J,2),I=1,3),J=301,310)),
  (  0.9005277053115E-08, 0.1280315624361E+01, 0.6281591679874E+01),
  (  0.8995601652048E-08, 0.2224439106766E+01, 0.6284560021018E+01),
  (  0.8288040568796E-08, 0.5234914433867E+01, 0.1241658836951E+02),
  (  0.6359381347255E-08, 0.4137989441490E+01, 0.1596186371003E+01),
  (  0.8699572228626E-08, 0.1758411009497E+01, 0.6133512519065E+01),
  (  0.6456797542736E-08, 0.5919285089994E+01, 0.1685848245639E+02),
  (  0.7424573475452E-08, 0.5414616938827E+01, 0.4061219149443E+01),
  (  0.7235671196168E-08, 0.1496516557134E+01, 0.1610006857377E+03),
  (  0.8104015182733E-08, 0.1919918242764E+01, 0.8460828644453E+00),
  (  0.8098576535937E-08, 0.3819615855458E+01, 0.3894181736510E+01),
  //DATA ((E0(I,J,2),I=1,3),J=311,320)),
  (  0.6275292346625E-08, 0.6244264115141E+01, 0.8531963191132E+00),
  (  0.6052432989112E-08, 0.5037731872610E+00, 0.1567108171867E+02),
  (  0.5705651535817E-08, 0.2984557271995E+01, 0.1258692712880E+02),
  (  0.5789650115138E-08, 0.6087038140697E+01, 0.1193336791622E+02),
  (  0.5512132153377E-08, 0.5855668994076E+01, 0.1232342296471E+02),
  (  0.7388890819102E-08, 0.2443128574740E+01, 0.4907302013889E+01),
  (  0.5467593991798E-08, 0.3017561234194E+01, 0.1884211409667E+02),
  (  0.6388519802999E-08, 0.5887386712935E+01, 0.5217580628120E+02),
  (  0.6106777149944E-08, 0.3483461059895E+00, 0.1422690933580E-01),
  (  0.7383420275489E-08, 0.5417387056707E+01, 0.2358125818164E+02),
  //DATA ((E0(I,J,2),I=1,3),J=321,330)),
  (  0.5505208141738E-08, 0.2848193644783E+01, 0.1151388321134E+02),
  (  0.6310757462877E-08, 0.2349882520828E+01, 0.1041998632314E+02),
  (  0.6166904929691E-08, 0.5728575944077E+00, 0.6151533897323E+01),
  (  0.5263442042754E-08, 0.4495796125937E+01, 0.1885275071096E+02),
  (  0.5591828082629E-08, 0.1355441967677E+01, 0.4337116142245E+00),
  (  0.5397051680497E-08, 0.1673422864307E+01, 0.6286362197481E+01),
  (  0.5396992745159E-08, 0.1833502206373E+01, 0.6279789503410E+01),
  (  0.6572913000726E-08, 0.3331122065824E+01, 0.1176433076753E+02),
  (  0.5123421866413E-08, 0.2165327142679E+01, 0.1245594543367E+02),
  (  0.5930495725999E-08, 0.2931146089284E+01, 0.6414617803568E+01),
  //DATA ((E0(I,J,2),I=1,3),J=331,340)),
  (  0.6431797403933E-08, 0.4134407994088E+01, 0.1350651127443E+00),
  (  0.5003182207604E-08, 0.3805420303749E+01, 0.1096996532989E+02),
  (  0.5587731032504E-08, 0.1082469260599E+01, 0.6062663316000E+01),
  (  0.5935263407816E-08, 0.8384333678401E+00, 0.5326786718777E+01),
  (  0.4756019827760E-08, 0.3552588749309E+01, 0.3104930017775E+01),
  (  0.6599951172637E-08, 0.4320826409528E+01, 0.4087944051283E+02),
  (  0.5902606868464E-08, 0.4811879454445E+01, 0.5849364236221E+01),
  (  0.5921147809031E-08, 0.9942628922396E-01, 0.1581959461667E+01),
  (  0.5505382581266E-08, 0.2466557607764E+01, 0.6503488384892E+01),
  (  0.5353771071862E-08, 0.4551978748683E+01, 0.1735668374386E+03),
  //DATA ((E0(I,J,2),I=1,3),J=341,350)),
  (  0.5063282210946E-08, 0.5710812312425E+01, 0.1248988586463E+02),
  (  0.5926120403383E-08, 0.1333998428358E+01, 0.2673594526851E+02),
  (  0.5211016176149E-08, 0.4649315360760E+01, 0.2460261242967E+02),
  (  0.5347075084894E-08, 0.5512754081205E+01, 0.4171425416666E+01),
  (  0.4872609773574E-08, 0.1308025299938E+01, 0.5333900173445E+01),
  (  0.4727711321420E-08, 0.2144908368062E+01, 0.7232251527446E+01),
  (  0.6029426018652E-08, 0.5567259412084E+01, 0.3227113045244E+03),
  (  0.4321485284369E-08, 0.5230667156451E+01, 0.9388005868221E+01),
  (  0.4476406760553E-08, 0.6134081115303E+01, 0.5547199253223E+01),
  (  0.5835268277420E-08, 0.4783808492071E+01, 0.7285056171570E+02),
  //DATA ((E0(I,J,2),I=1,3),J=351,360)),
  (  0.5172183602748E-08, 0.5161817911099E+01, 0.1884570439172E+02),
  (  0.5693571465184E-08, 0.1381646203111E+01, 0.9723862754494E+02),
  (  0.4060634965349E-08, 0.3876705259495E+00, 0.4274518229222E+01),
  (  0.3967398770473E-08, 0.5029491776223E+01, 0.3496032717521E+01),
  (  0.3943754005255E-08, 0.1923162955490E+01, 0.6244942932314E+01),
  (  0.4781323427824E-08, 0.4633332586423E+01, 0.2929661536378E+02),
  (  0.3871483781204E-08, 0.1616650009743E+01, 0.6321208768577E+01),
  (  0.5141741733997E-08, 0.9817316704659E-01, 0.1232032006293E+02),
  (  0.4002385978497E-08, 0.3656161212139E+01, 0.7018952447668E+01),
  (  0.4901092604097E-08, 0.4404098713092E+01, 0.1478866649112E+01),
  //DATA ((E0(I,J,2),I=1,3),J=361,370)),
  (  0.3740932630345E-08, 0.5181188732639E+00, 0.6922973089781E+01),
  (  0.4387283718538E-08, 0.3254859566869E+01, 0.2331413144044E+03),
  (  0.5019197802033E-08, 0.3086773224677E+01, 0.1715706182245E+02),
  (  0.3834931695175E-08, 0.2797882673542E+01, 0.1491901785440E+02),
  (  0.3760413942497E-08, 0.2892676280217E+01, 0.1726726808967E+02),
  (  0.3719717204628E-08, 0.5861046025739E+01, 0.6297302759782E+01),
  (  0.4145623530149E-08, 0.2168239627033E+01, 0.1376059875786E+02),
  (  0.3932788425380E-08, 0.6271811124181E+01, 0.7872148766781E+01),
  (  0.3686377476857E-08, 0.3936853151404E+01, 0.6268848941110E+01),
  (  0.3779077950339E-08, 0.1404148734043E+01, 0.4157198507331E+01),
  //DATA ((E0(I,J,2),I=1,3),J=371,380)),
  (  0.4091334550598E-08, 0.2452436180854E+01, 0.9779108567966E+01),
  (  0.3926694536146E-08, 0.6102292739040E+01, 0.1098419223922E+02),
  (  0.4841000253289E-08, 0.6072760457276E+01, 0.1252801878276E+02),
  (  0.4949340130240E-08, 0.1154832815171E+01, 0.1617106187867E+03),
  (  0.3761557737360E-08, 0.5527545321897E+01, 0.3185192151914E+01),
  (  0.3647396268188E-08, 0.1525035688629E+01, 0.6271346477544E+01),
  (  0.3932405074189E-08, 0.5570681040569E+01, 0.2139354194808E+02),
  (  0.3631322501141E-08, 0.1981240601160E+01, 0.6294805223347E+01),
  (  0.4130007425139E-08, 0.2050060880201E+01, 0.2195415756911E+02),
  (  0.4433905965176E-08, 0.3277477970321E+01, 0.7445550607224E+01),
  //DATA ((E0(I,J,2),I=1,3),J=381,390)),
  (  0.3851814176947E-08, 0.5210690074886E+01, 0.9562891316684E+00),
  (  0.3485807052785E-08, 0.6653274904611E+00, 0.1161697602389E+02),
  (  0.3979772816991E-08, 0.1767941436148E+01, 0.2277943724828E+02),
  (  0.3402607460500E-08, 0.3421746306465E+01, 0.1087398597200E+02),
  (  0.4049993000926E-08, 0.1127144787547E+01, 0.3163918923335E+00),
  (  0.3420511182382E-08, 0.4214794779161E+01, 0.1362553364512E+02),
  (  0.3640772365012E-08, 0.5324905497687E+01, 0.1725304118033E+02),
  (  0.3323037987501E-08, 0.6135761838271E+01, 0.6279143387820E+01),
  (  0.4503141663637E-08, 0.1802305450666E+01, 0.1385561574497E+01),
  (  0.4314560055588E-08, 0.4812299731574E+01, 0.4176041334900E+01),
  //DATA ((E0(I,J,2),I=1,3),J=391,400)),
  (  0.3294226949110E-08, 0.3657547059723E+01, 0.6287008313071E+01),
  (  0.3215657197281E-08, 0.4866676894425E+01, 0.5749861718712E+01),
  (  0.4129362656266E-08, 0.3809342558906E+01, 0.5905702259363E+01),
  (  0.3137762976388E-08, 0.2494635174443E+01, 0.2099539292909E+02),
  (  0.3514010952384E-08, 0.2699961831678E+01, 0.7335344340001E+01),
  (  0.3327607571530E-08, 0.3318457714816E+01, 0.5436992986000E+01),
  (  0.3541066946675E-08, 0.4382703582466E+01, 0.1234573916645E+02),
  (  0.3216179847052E-08, 0.5271066317054E+01, 0.3802769619140E-01),
  (  0.2959045059570E-08, 0.5819591585302E+01, 0.2670964694522E+02),
  (  0.3884040326665E-08, 0.5980934960428E+01, 0.6660449441528E+01),
  //DATA ((E0(I,J,2),I=1,3),J=401,410)),
  (  0.2922027539886E-08, 0.3337290282483E+01, 0.1375773836557E+01),
  (  0.4110846382042E-08, 0.5742978187327E+01, 0.4480965020977E+02),
  (  0.2934508411032E-08, 0.2278075804200E+01, 0.6408777551755E+00),
  (  0.3966896193000E-08, 0.5835747858477E+01, 0.3773735910827E+00),
  (  0.3286695827610E-08, 0.5838898193902E+01, 0.3932462625300E-02),
  (  0.3720643094196E-08, 0.1122212337858E+01, 0.1646033343740E+02),
  (  0.3285508906174E-08, 0.9182250996416E+00, 0.1081813534213E+02),
  (  0.3753880575973E-08, 0.5174761973266E+01, 0.5642198095270E+01),
  (  0.3022129385587E-08, 0.3381611020639E+01, 0.2982630633589E+02),
  (  0.2798569205621E-08, 0.3546193723922E+01, 0.1937891852345E+02),
  //DATA ((E0(I,J,2),I=1,3),J=411,420)),
  (  0.3397872070505E-08, 0.4533203197934E+01, 0.6923953605621E+01),
  (  0.3708099772977E-08, 0.2756168198616E+01, 0.3066615496545E+02),
  (  0.3599283541510E-08, 0.1934395469918E+01, 0.6147450479709E+01),
  (  0.3688702753059E-08, 0.7149920971109E+00, 0.2636725487657E+01),
  (  0.2681084724003E-08, 0.4899819493154E+01, 0.6816289982179E+01),
  (  0.3495993460759E-08, 0.1572418915115E+01, 0.6418701221183E+01),
  (  0.3130770324995E-08, 0.8912190180489E+00, 0.1235996607578E+02),
  (  0.2744353821941E-08, 0.3800821940055E+01, 0.2059724391010E+02),
  (  0.2842732906341E-08, 0.2644717440029E+01, 0.2828699048865E+02),
  (  0.3046882682154E-08, 0.3987793020179E+01, 0.6055599646783E+01),
  //DATA ((E0(I,J,2),I=1,3),J=421,430)),
  (  0.2399072455143E-08, 0.9908826440764E+00, 0.6255674361143E+01),
  (  0.2384306274204E-08, 0.2516149752220E+01, 0.6310477339748E+01),
  (  0.2977324500559E-08, 0.5849195642118E+01, 0.1652265972112E+02),
  (  0.3062835258972E-08, 0.1681660100162E+01, 0.1172006883645E+02),
  (  0.3109682589231E-08, 0.5804143987737E+00, 0.2751146787858E+02),
  (  0.2903920355299E-08, 0.5800768280123E+01, 0.6510552054109E+01),
  (  0.2823221989212E-08, 0.9241118370216E+00, 0.5469525544182E+01),
  (  0.3187949696649E-08, 0.3139776445735E+01, 0.1693792562116E+03),
  (  0.2922559771655E-08, 0.3549440782984E+01, 0.2630839062450E+00),
  (  0.2436302066603E-08, 0.4735540696319E+01, 0.3946258593675E+00),
  //DATA ((E0(I,J,2),I=1,3),J=431,440)),
  (  0.3049473043606E-08, 0.4998289124561E+01, 0.8390110365991E+01),
  (  0.2863682575784E-08, 0.6709515671102E+00, 0.2243449970715E+00),
  (  0.2641750517966E-08, 0.5410978257284E+01, 0.2986433403208E+02),
  (  0.2704093466243E-08, 0.4778317207821E+01, 0.6129297044991E+01),
  (  0.2445522177011E-08, 0.6009020662222E+01, 0.1171295538178E+02),
  (  0.2623608810230E-08, 0.5010449777147E+01, 0.6436854655901E+01),
  (  0.2079259704053E-08, 0.5980943768809E+01, 0.2019909489111E+02),
  (  0.2820225596771E-08, 0.2679965110468E+01, 0.5934151399930E+01),
  (  0.2365221950927E-08, 0.1894231148810E+01, 0.2470570524223E+02),
  (  0.2359682077149E-08, 0.4220752950780E+01, 0.8671969964381E+01),
  //DATA ((E0(I,J,2),I=1,3),J=441,450)),
  (  0.2387577137206E-08, 0.2571783940617E+01, 0.7096626156709E+01),
  (  0.1982102089816E-08, 0.5169765997119E+00, 0.1727188400790E+02),
  (  0.2687502389925E-08, 0.6239078264579E+01, 0.7075506709219E+02),
  (  0.2207751669135E-08, 0.2031184412677E+01, 0.4377611041777E+01),
  (  0.2618370214274E-08, 0.8266079985979E+00, 0.6632000300961E+01),
  (  0.2591951887361E-08, 0.8819350522008E+00, 0.4873985990671E+02),
  (  0.2375055656248E-08, 0.3520944177789E+01, 0.1590676413561E+02),
  (  0.2472019978911E-08, 0.1551431908671E+01, 0.6612329252343E+00),
  (  0.2368157127199E-08, 0.4178610147412E+01, 0.3459636466239E+02),
  (  0.1764846605693E-08, 0.1506764000157E+01, 0.1980094587212E+02),
  //DATA ((E0(I,J,2),I=1,3),J=451,460)),
  (  0.2291769608798E-08, 0.2118250611782E+01, 0.2844914056730E-01),
  (  0.2209997316943E-08, 0.3363255261678E+01, 0.2666070658668E+00),
  (  0.2292699097923E-08, 0.4200423956460E+00, 0.1484170571900E-02),
  (  0.1629683015329E-08, 0.2331362582487E+01, 0.3035599730800E+02),
  (  0.2206492862426E-08, 0.3400274026992E+01, 0.6281667977667E+01),
  (  0.2205746568257E-08, 0.1066051230724E+00, 0.6284483723224E+01),
  (  0.2026310767991E-08, 0.2779066487979E+01, 0.2449240616245E+02),
  (  0.1762977622163E-08, 0.9951450691840E+00, 0.2045286941806E+02),
  (  0.1368535049606E-08, 0.6402447365817E+00, 0.2473415438279E+02),
  (  0.1720598775450E-08, 0.2303524214705E+00, 0.1679593901136E+03),
  //DATA ((E0(I,J,2),I=1,3),J=461,470)),
  (  0.1702429015449E-08, 0.6164622655048E+01, 0.3338575901272E+03),
  (  0.1414033197685E-08, 0.3954561185580E+01, 0.1624205518357E+03),
  (  0.1573768958043E-08, 0.2028286308984E+01, 0.3144167757552E+02),
  (  0.1650705184447E-08, 0.2304040666128E+01, 0.5267006960365E+02),
  (  0.1651087618855E-08, 0.2538461057280E+01, 0.8956999012000E+02),
  (  0.1616409518983E-08, 0.5111054348152E+01, 0.3332657872986E+02),
  (  0.1537175173581E-08, 0.5601130666603E+01, 0.3852657435933E+02),
  (  0.1593191980553E-08, 0.2614340453411E+01, 0.2282781046519E+03),
  (  0.1499480170643E-08, 0.3624721577264E+01, 0.2823723341956E+02),
  (  0.1493807843235E-08, 0.4214569879008E+01, 0.2876692439167E+02),
  //DATA ((E0(I,J,2),I=1,3),J=471,480)),
  (  0.1074571199328E-08, 0.1496911744704E+00, 0.8397383534231E+02),
  (  0.1074406983417E-08, 0.1187817671922E+01, 0.8401985929482E+02),
  (  0.9757576855851E-09, 0.2655703035858E+01, 0.7826370942180E+02),
  (  0.1258432887565E-08, 0.4969896184844E+01, 0.3115650189215E+03),
  (  0.1240336343282E-08, 0.5192460776926E+01, 0.1784300471910E+03),
  (  0.9016107005164E-09, 0.1960356923057E+01, 0.5886454391678E+02),
  (  0.1135392360918E-08, 0.5082427809068E+01, 0.7842370451713E+02),
  (  0.9216046089565E-09, 0.2793775037273E+01, 0.1014262087719E+03),
  (  0.1061276615030E-08, 0.3726144311409E+01, 0.5660027930059E+02),
  (  0.1010110596263E-08, 0.7404080708937E+00, 0.4245678405627E+02),
  //DATA ((E0(I,J,2),I=1,3),J=481,490)),
  (  0.7217424756199E-09, 0.2697449980577E-01, 0.2457074661053E+03),
  (  0.6912003846756E-09, 0.4253296276335E+01, 0.1679936946371E+03),
  (  0.6871814664847E-09, 0.5148072412354E+01, 0.6053048899753E+02),
  (  0.4887158016343E-09, 0.2153581148294E+01, 0.9656299901946E+02),
  (  0.5161802866314E-09, 0.3852750634351E+01, 0.2442876000072E+03),
  (  0.5652599559057E-09, 0.1233233356270E+01, 0.8365903305582E+02),
  (  0.4710812608586E-09, 0.5610486976767E+01, 0.3164282286739E+03),
  (  0.4909977500324E-09, 0.1639629524123E+01, 0.4059982187939E+03),
  (  0.4772641839378E-09, 0.3737100368583E+01, 0.1805255418145E+03),
  (  0.4487562567153E-09, 0.1158417054478E+00, 0.8433466158131E+02),
  //DATA ((E0(I,J,2),I=1,3),J=491,500)),
  (  0.3943441230497E-09, 0.6243502862796E+00, 0.2568537517081E+03),
  (  0.3952236913598E-09, 0.3510377382385E+01, 0.2449975330562E+03),
  (  0.3788898363417E-09, 0.5916128302299E+01, 0.1568131045107E+03),
  (  0.3738329328831E-09, 0.1042266763456E+01, 0.3948519331910E+03),
  (  0.2451199165151E-09, 0.1166788435700E+01, 0.1435713242844E+03),
  (  0.2436734402904E-09, 0.3254726114901E+01, 0.2268582385539E+03),
  (  0.2213605274325E-09, 0.1687210598530E+01, 0.1658638954901E+03),
  (  0.1491521204829E-09, 0.2657541786794E+01, 0.2219950288015E+03),
  (  0.1474995329744E-09, 0.5013089805819E+01, 0.3052819430710E+03),
  (  0.1661939475656E-09, 0.5495315428418E+01, 0.2526661704812E+03),
  //DATA ((E0(I,J,2),I=1,3),J=501,NE0Y)),
  (  0.9015946748003E-10, 0.2236989966505E+01, 0.4171445043968E+03)),
  //  Sun-to-Earth, T^0, Z	),
  //DATA ((E0(I,J,3),I=1,3),J=  1, 10)),
  ((  0.2796207639075E-05, 0.3198701560209E+01, 0.8433466158131E+02),
  (  0.1016042198142E-05, 0.5422360395913E+01, 0.5507553240374E+01),
  (  0.8044305033647E-06, 0.3880222866652E+01, 0.5223693906222E+01),
  (  0.4385347909274E-06, 0.3704369937468E+01, 0.2352866153506E+01),
  (  0.3186156414906E-06, 0.3999639363235E+01, 0.1577343543434E+01),
  (  0.2272412285792E-06, 0.3984738315952E+01, 0.1047747311755E+01),
  (  0.1645620103007E-06, 0.3565412516841E+01, 0.5856477690889E+01),
  (  0.1815836921166E-06, 0.4984507059020E+01, 0.6283075850446E+01),
  (  0.1447461676364E-06, 0.3702753570108E+01, 0.9437762937313E+01),
  (  0.1430760876382E-06, 0.3409658712357E+01, 0.1021328554739E+02),
  //DATA ((E0(I,J,3),I=1,3),J= 11, 20)),
  (  0.1120445753226E-06, 0.4829561570246E+01, 0.1414349524433E+02),
  (  0.1090232840797E-06, 0.2080729178066E+01, 0.6812766822558E+01),
  (  0.9715727346551E-07, 0.3476295881948E+01, 0.4694002934110E+01),
  (  0.1036267136217E-06, 0.4056639536648E+01, 0.7109288135493E+02),
  (  0.8752665271340E-07, 0.4448159519911E+01, 0.5753384878334E+01),
  (  0.8331864956004E-07, 0.4991704044208E+01, 0.7084896783808E+01),
  (  0.6901658670245E-07, 0.4325358994219E+01, 0.6275962395778E+01),
  (  0.9144536848998E-07, 0.1141826375363E+01, 0.6620890113188E+01),
  (  0.7205085037435E-07, 0.3624344170143E+01, 0.5296909721118E+00),
  (  0.7697874654176E-07, 0.5554257458998E+01, 0.1676215758509E+03),
  //DATA ((E0(I,J,3),I=1,3),J= 21, 30)),
  (  0.5197545738384E-07, 0.6251760961735E+01, 0.1807370494127E+02),
  (  0.5031345378608E-07, 0.2497341091913E+01, 0.4705732307012E+01),
  (  0.4527110205840E-07, 0.2335079920992E+01, 0.6309374173736E+01),
  (  0.4753355798089E-07, 0.7094148987474E+00, 0.5884926831456E+01),
  (  0.4296951977516E-07, 0.1101916352091E+01, 0.6681224869435E+01),
  (  0.3855341568387E-07, 0.1825495405486E+01, 0.5486777812467E+01),
  (  0.5253930970990E-07, 0.4424740687208E+01, 0.7860419393880E+01),
  (  0.4024630496471E-07, 0.5120498157053E+01, 0.1336797263425E+02),
  (  0.4061069791453E-07, 0.6029771435451E+01, 0.3930209696940E+01),
  (  0.3797883804205E-07, 0.4435193600836E+00, 0.3154687086868E+01),
  //DATA ((E0(I,J,3),I=1,3),J= 31, 40)),
  (  0.2933033225587E-07, 0.5124157356507E+01, 0.1059381944224E+01),
  (  0.3503000930426E-07, 0.5421830162065E+01, 0.6069776770667E+01),
  (  0.3670096214050E-07, 0.4582101667297E+01, 0.1219403291462E+02),
  (  0.2905609437008E-07, 0.1926566420072E+01, 0.1097707878456E+02),
  (  0.2466827821713E-07, 0.6090174539834E+00, 0.6496374930224E+01),
  (  0.2691647295332E-07, 0.1393432595077E+01, 0.2200391463820E+02),
  (  0.2150554667946E-07, 0.4308671715951E+01, 0.5643178611111E+01),
  (  0.2237481922680E-07, 0.8133968269414E+00, 0.8635942003952E+01),
  (  0.1817741038157E-07, 0.3755205127454E+01, 0.3340612434717E+01),
  (  0.2227820762132E-07, 0.2759558596664E+01, 0.1203646072878E+02),
  //DATA ((E0(I,J,3),I=1,3),J= 41, 50)),
  (  0.1944713772307E-07, 0.5699645869121E+01, 0.1179062909082E+02),
  (  0.1527340520662E-07, 0.1986749091746E+01, 0.3981490189893E+00),
  (  0.1577282574914E-07, 0.3205017217983E+01, 0.5088628793478E+01),
  (  0.1424738825424E-07, 0.6256747903666E+01, 0.2544314396739E+01),
  (  0.1616563121701E-07, 0.2601671259394E+00, 0.1729818233119E+02),
  (  0.1401210391692E-07, 0.4686939173506E+01, 0.7058598460518E+01),
  (  0.1488726974214E-07, 0.2815862451372E+01, 0.2593412433514E+02),
  (  0.1692626442388E-07, 0.4956894109797E+01, 0.1564752902480E+03),
  (  0.1123571582910E-07, 0.2381192697696E+01, 0.3738761453707E+01),
  (  0.9903308606317E-08, 0.4294851657684E+01, 0.9225539266174E+01),
  //DATA ((E0(I,J,3),I=1,3),J= 51, 60)),
  (  0.9174533187191E-08, 0.3075171510642E+01, 0.4164311961999E+01),
  (  0.8645985631457E-08, 0.5477534821633E+00, 0.8429241228195E+01),
  ( -0.1085876492688E-07, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.9264309077815E-08, 0.5968571670097E+01, 0.7079373888424E+01),
  (  0.8243116984954E-08, 0.1489098777643E+01, 0.1044738781244E+02),
  (  0.8268102113708E-08, 0.3512977691983E+01, 0.1150676975667E+02),
  (  0.9043613988227E-08, 0.1290704408221E+00, 0.1101510648075E+02),
  (  0.7432912038789E-08, 0.1991086893337E+01, 0.2608790314060E+02),
  (  0.8586233727285E-08, 0.4238357924414E+01, 0.2986433403208E+02),
  (  0.7612230060131E-08, 0.2911090150166E+01, 0.4732030630302E+01),
  //DATA ((E0(I,J,3),I=1,3),J= 61, 70)),
  (  0.7097787751408E-08, 0.1908938392390E+01, 0.8031092209206E+01),
  (  0.7640237040175E-08, 0.6129219000168E+00, 0.7962980379786E+00),
  (  0.7070445688081E-08, 0.1380417036651E+01, 0.2146165377750E+01),
  (  0.7690770957702E-08, 0.1680504249084E+01, 0.2122839202813E+02),
  (  0.8051292542594E-08, 0.5127423484511E+01, 0.2942463415728E+01),
  (  0.5902709104515E-08, 0.2020274190917E+01, 0.7755226100720E+00),
  (  0.5134567496462E-08, 0.2606778676418E+01, 0.1256615170089E+02),
  (  0.5525802046102E-08, 0.1613011769663E+01, 0.8018209333619E+00),
  (  0.5880724784221E-08, 0.4604483417236E+01, 0.4690479774488E+01),
  (  0.5211699081370E-08, 0.5718964114193E+01, 0.8827390247185E+01),
  //DATA ((E0(I,J,3),I=1,3),J= 71, 80)),
  (  0.4891849573562E-08, 0.3689658932196E+01, 0.2132990797783E+00),
  (  0.5150246069997E-08, 0.4099769855122E+01, 0.6480980550449E+02),
  (  0.5102434319633E-08, 0.5660834602509E+01, 0.3379454372902E+02),
  (  0.5083405254252E-08, 0.9842221218974E+00, 0.4136910472696E+01),
  (  0.4206562585682E-08, 0.1341363634163E+00, 0.3128388763578E+01),
  (  0.4663249683579E-08, 0.8130132735866E+00, 0.5216580451554E+01),
  (  0.4099474416530E-08, 0.5791497770644E+01, 0.4265981595566E+00),
  (  0.4628251220767E-08, 0.1249802769331E+01, 0.1572083878776E+02),
  (  0.5024068728142E-08, 0.4795684802743E+01, 0.6290189305114E+01),
  (  0.5120234327758E-08, 0.3810420387208E+01, 0.5230807360890E+01),
  //DATA ((E0(I,J,3),I=1,3),J= 81, 90)),
  (  0.5524029815280E-08, 0.1029264714351E+01, 0.2397622045175E+03),
  (  0.4757415718860E-08, 0.3528044781779E+01, 0.1649636139783E+02),
  (  0.3915786131127E-08, 0.5593889282646E+01, 0.1589072916335E+01),
  (  0.4869053149991E-08, 0.3299636454433E+01, 0.7632943190217E+01),
  (  0.3649365703729E-08, 0.1286049002584E+01, 0.6206810014183E+01),
  (  0.3992493949002E-08, 0.3100307589464E+01, 0.2515860172507E+02),
  (  0.3320247477418E-08, 0.6212683940807E+01, 0.1216800268190E+02),
  (  0.3287123739696E-08, 0.4699118445928E+01, 0.7234794171227E+01),
  (  0.3472776811103E-08, 0.2630507142004E+01, 0.7342457794669E+01),
  (  0.3423253294767E-08, 0.2946432844305E+01, 0.9623688285163E+01),
  //DATA ((E0(I,J,3),I=1,3),J= 91,100)),
  (  0.3896173898244E-08, 0.1224834179264E+01, 0.6438496133249E+01),
  (  0.3388455337924E-08, 0.1543807616351E+01, 0.1494531617769E+02),
  (  0.3062704716523E-08, 0.1191777572310E+01, 0.8662240327241E+01),
  (  0.3270075600400E-08, 0.5483498767737E+01, 0.1194447056968E+01),
  (  0.3101209215259E-08, 0.8000833804348E+00, 0.3772475342596E+02),
  (  0.2780883347311E-08, 0.4077980721888E+00, 0.5863591145557E+01),
  (  0.2903605931824E-08, 0.2617490302147E+01, 0.1965104848470E+02),
  (  0.2682014743119E-08, 0.2634703158290E+01, 0.7238675589263E+01),
  (  0.2534360108492E-08, 0.6102446114873E+01, 0.6836645152238E+01),
  (  0.2392564882509E-08, 0.3681820208691E+01, 0.5849364236221E+01),
  //DATA ((E0(I,J,3),I=1,3),J=101,110)),
  (  0.2656667254856E-08, 0.6216045388886E+01, 0.6133512519065E+01),
  (  0.2331242096773E-08, 0.5864949777744E+01, 0.4535059491685E+01),
  (  0.2287898363668E-08, 0.4566628532802E+01, 0.7477522907414E+01),
  (  0.2336944521306E-08, 0.2442722126930E+01, 0.1137170464392E+02),
  (  0.3156632236269E-08, 0.1626628050682E+01, 0.2509084901204E+03),
  (  0.2982612402766E-08, 0.2803604512609E+01, 0.1748016358760E+01),
  (  0.2774031674807E-08, 0.4654002897158E+01, 0.8223916695780E+02),
  (  0.2295236548638E-08, 0.4326518333253E+01, 0.3378142627421E+00),
  (  0.2190714699873E-08, 0.4519614578328E+01, 0.2908881142201E+02),
  (  0.2191495845045E-08, 0.3012626912549E+01, 0.1673046366289E+02),
  //DATA ((E0(I,J,3),I=1,3),J=111,120)),
  (  0.2492901628386E-08, 0.1290101424052E+00, 0.1543797956245E+03),
  (  0.1993778064319E-08, 0.3864046799414E+01, 0.1778984560711E+02),
  (  0.1898146479022E-08, 0.5053777235891E+01, 0.2042657109477E+02),
  (  0.1918280127634E-08, 0.2222470192548E+01, 0.4165496312290E+02),
  (  0.1916351061607E-08, 0.8719067257774E+00, 0.7737595720538E+02),
  (  0.1834720181466E-08, 0.4031491098040E+01, 0.2358125818164E+02),
  (  0.1249201523806E-08, 0.5938379466835E+01, 0.3301902111895E+02),
  (  0.1477304050539E-08, 0.6544722606797E+00, 0.9548094718417E+02),
  (  0.1264316431249E-08, 0.2059072853236E+01, 0.8399684731857E+02),
  (  0.1203526495039E-08, 0.3644813532605E+01, 0.4558517281984E+02),
  //DATA ((E0(I,J,3),I=1,3),J=121,130)),
  (  0.9221681059831E-09, 0.3241815055602E+01, 0.7805158573086E+02),
  (  0.7849278367646E-09, 0.5043812342457E+01, 0.5217580628120E+02),
  (  0.7983392077387E-09, 0.5000024502753E+01, 0.1501922143975E+03),
  (  0.7925395431654E-09, 0.1398734871821E-01, 0.9061773743175E+02),
  (  0.7640473285886E-09, 0.5067111723130E+01, 0.4951538251678E+02),
  (  0.5398937754482E-09, 0.5597382200075E+01, 0.1613385000004E+03),
  (  0.5626247550193E-09, 0.2601338209422E+01, 0.7318837597844E+02),
  (  0.5525197197855E-09, 0.5814832109256E+01, 0.1432335100216E+03),
  (  0.5407629837898E-09, 0.3384820609076E+01, 0.3230491187871E+03),
  (  0.3856739119801E-09, 0.1072391840473E+01, 0.2334791286671E+03),
  //DATA ((E0(I,J,3),I=1,3),J=131,NE0Z)),
  (  0.3856425239987E-09, 0.2369540393327E+01, 0.1739046517013E+03),
  (  0.4350867755983E-09, 0.5255575751082E+01, 0.1620484330494E+03),
  (  0.3844113924996E-09, 0.5482356246182E+01, 0.9757644180768E+02),
  (  0.2854869155431E-09, 0.9573634763143E+00, 0.1697170704744E+03),
  (  0.1719227671416E-09, 0.1887203025202E+01, 0.2265204242912E+03),
  (  0.1527846879755E-09, 0.3982183931157E+01, 0.3341954043900E+03),
  (  0.1128229264847E-09, 0.2787457156298E+01, 0.3119028331842E+03),
  (                0    ,               0,                   0    ), {not used}
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    ),
  (                0    ,               0,                   0    )));


  //*  Sun-to-Earth, T^1, X	),
  E1: array[1..3,1..ME1,1..3] of double = {80}
  //DATA ((E1(I,J,1),I=1,3),J=  1, 10)),
  (((  0.1234046326004E-05, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.5150068824701E-06, 0.6002664557501E+01, 0.1256615170089E+02),
  (  0.1290743923245E-07, 0.5959437664199E+01, 0.1884922755134E+02),
  (  0.1068615564952E-07, 0.2015529654209E+01, 0.6283075850446E+01),
  (  0.2079619142538E-08, 0.1732960531432E+01, 0.6279552690824E+01),
  (  0.2078009243969E-08, 0.4915604476996E+01, 0.6286599010068E+01),
  (  0.6206330058856E-09, 0.3616457953824E+00, 0.4705732307012E+01),
  (  0.5989335313746E-09, 0.3802607304474E+01, 0.6256777527156E+01),
  (  0.5958495663840E-09, 0.2845866560031E+01, 0.6309374173736E+01),
  (  0.4866923261539E-09, 0.5213203771824E+01, 0.7755226100720E+00),
  //DATA ((E1(I,J,1),I=1,3),J= 11, 20)),
  (  0.4267785823142E-09, 0.4368189727818E+00, 0.1059381944224E+01),
  (  0.4610675141648E-09, 0.1837249181372E-01, 0.7860419393880E+01),
  (  0.3626989993973E-09, 0.2161590545326E+01, 0.5753384878334E+01),
  (  0.3563071194389E-09, 0.1452631954746E+01, 0.5884926831456E+01),
  (  0.3557015642807E-09, 0.4470593393054E+01, 0.6812766822558E+01),
  (  0.3210412089122E-09, 0.5195926078314E+01, 0.6681224869435E+01),
  (  0.2875473577986E-09, 0.5916256610193E+01, 0.2513230340178E+02),
  (  0.2842913681629E-09, 0.1149902426047E+01, 0.6127655567643E+01),
  (  0.2751248215916E-09, 0.5502088574662E+01, 0.6438496133249E+01),
  (  0.2481432881127E-09, 0.2921989846637E+01, 0.5486777812467E+01),
  //DATA ((E1(I,J,1),I=1,3),J= 21, 30)),
  (  0.2059885976560E-09, 0.3718070376585E+01, 0.7079373888424E+01),
  (  0.2015522342591E-09, 0.5979395259740E+01, 0.6290189305114E+01),
  (  0.1995364084253E-09, 0.6772087985494E+00, 0.6275962395778E+01),
  (  0.1957436436943E-09, 0.2899210654665E+01, 0.5507553240374E+01),
  (  0.1651609818948E-09, 0.6228206482192E+01, 0.1150676975667E+02),
  (  0.1822980550699E-09, 0.1469348746179E+01, 0.1179062909082E+02),
  (  0.1675223159760E-09, 0.3813910555688E+01, 0.7058598460518E+01),
  (  0.1706491764745E-09, 0.3004380506684E+00, 0.7113454667900E-02),
  (  0.1392952362615E-09, 0.1440393973406E+01, 0.7962980379786E+00),
  (  0.1209868266342E-09, 0.4150425791727E+01, 0.4694002934110E+01),
  //DATA ((E1(I,J,1),I=1,3),J= 31, 40)),
  (  0.1009827202611E-09, 0.3290040429843E+01, 0.3738761453707E+01),
  (  0.1047261388602E-09, 0.4229590090227E+01, 0.6282095334605E+01),
  (  0.1047006652004E-09, 0.2418967680575E+01, 0.6284056366286E+01),
  (  0.9609993143095E-10, 0.4627943659201E+01, 0.6069776770667E+01),
  (  0.9590900593873E-10, 0.1894393939924E+01, 0.4136910472696E+01),
  (  0.9146249188071E-10, 0.2010647519562E+01, 0.6496374930224E+01),
  (  0.8545274480290E-10, 0.5529846956226E-01, 0.1194447056968E+01),
  (  0.8224377881194E-10, 0.1254304102174E+01, 0.1589072916335E+01),
  (  0.6183529510410E-10, 0.3360862168815E+01, 0.8827390247185E+01),
  (  0.6259255147141E-10, 0.4755628243179E+01, 0.8429241228195E+01),
  //DATA ((E1(I,J,1),I=1,3),J= 41, 50)),
  (  0.5539291694151E-10, 0.5371746955142E+01, 0.4933208510675E+01),
  (  0.7328259466314E-10, 0.4927699613906E+00, 0.4535059491685E+01),
  (  0.6017835843560E-10, 0.5776682001734E-01, 0.1255903824622E+02),
  (  0.7079827775243E-10, 0.4395059432251E+01, 0.5088628793478E+01),
  (  0.5170358878213E-10, 0.5154062619954E+01, 0.1176985366291E+02),
  (  0.4872301838682E-10, 0.6289611648973E+00, 0.6040347114260E+01),
  (  0.5249869411058E-10, 0.5617272046949E+01, 0.3154687086868E+01),
  (  0.4716172354411E-10, 0.3965901800877E+01, 0.5331357529664E+01),
  (  0.4871214940964E-10, 0.4627507050093E+01, 0.1256967486051E+02),
  (  0.4598076850751E-10, 0.6023631226459E+01, 0.6525804586632E+01),
  //DATA ((E1(I,J,1),I=1,3),J= 51, 60)),
  (  0.4562196089485E-10, 0.4138562084068E+01, 0.3930209696940E+01),
  (  0.4325493872224E-10, 0.1330845906564E+01, 0.7632943190217E+01),
  (  0.5673781176748E-10, 0.2558752615657E+01, 0.5729506548653E+01),
  (  0.3961436642503E-10, 0.2728071734630E+01, 0.7234794171227E+01),
  (  0.5101868209058E-10, 0.4113444965144E+01, 0.6836645152238E+01),
  (  0.5257043167676E-10, 0.6195089830590E+01, 0.8031092209206E+01),
  (  0.5076613989393E-10, 0.2305124132918E+01, 0.7477522907414E+01),
  (  0.3342169352778E-10, 0.5415998155071E+01, 0.1097707878456E+02),
  (  0.3545881983591E-10, 0.3727160564574E+01, 0.4164311961999E+01),
  (  0.3364063738599E-10, 0.2901121049204E+00, 0.1137170464392E+02),
  //DATA ((E1(I,J,1),I=1,3),J= 61, 70)),
  (  0.3357039670776E-10, 0.1652229354331E+01, 0.5223693906222E+01),
  (  0.4307412268687E-10, 0.4938909587445E+01, 0.1592596075957E+01),
  (  0.3405769115435E-10, 0.2408890766511E+01, 0.3128388763578E+01),
  (  0.3001926198480E-10, 0.4862239006386E+01, 0.1748016358760E+01),
  (  0.2778264787325E-10, 0.5241168661353E+01, 0.7342457794669E+01),
  (  0.2676159480666E-10, 0.3423593942199E+01, 0.2146165377750E+01),
  (  0.2954273399939E-10, 0.1881721265406E+01, 0.5368044267797E+00),
  (  0.3309362888795E-10, 0.1931525677349E+01, 0.8018209333619E+00),
  (  0.2810283608438E-10, 0.2414659495050E+01, 0.5225775174439E+00),
  (  0.3378045637764E-10, 0.4238019163430E+01, 0.1554202828031E+00),
  //DATA ((E1(I,J,1),I=1,3),J= 71,NE1X)),
  (  0.2558134979840E-10, 0.1828225235805E+01, 0.5230807360890E+01),
  (  0.2273755578447E-10, 0.5858184283998E+01, 0.7084896783808E+01),
  (  0.2294176037690E-10, 0.4514589779057E+01, 0.1726015463500E+02),
  (  0.2533506099435E-10, 0.2355717851551E+01, 0.5216580451554E+01),
  (  0.2716685375812E-10, 0.2221003625100E+01, 0.8635942003952E+01),
  (  0.2419043435198E-10, 0.5955704951635E+01, 0.4690479774488E+01),
  (  0.2521232544812E-10, 0.1395676848521E+01, 0.5481254917084E+01),
  (  0.2630195021491E-10, 0.5727468918743E+01, 0.2629832328990E-01),
  (  0.2548395840944E-10, 0.2628351859400E-03, 0.1349867339771E+01),
  (                0    ,               0    ,               0    )),

  //*  Sun-to-Earth, T^1, Y	),
  //DATA ((E1(I,J,2),I=1,3),J=  1, 10)),
  ((  0.9304690546528E-06, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.5150715570663E-06, 0.4431807116294E+01, 0.1256615170089E+02),
  (  0.1290825411056E-07, 0.4388610039678E+01, 0.1884922755134E+02),
  (  0.4645466665386E-08, 0.5827263376034E+01, 0.6283075850446E+01),
  (  0.2079625310718E-08, 0.1621698662282E+00, 0.6279552690824E+01),
  (  0.2078189850907E-08, 0.3344713435140E+01, 0.6286599010068E+01),
  (  0.6207190138027E-09, 0.5074049319576E+01, 0.4705732307012E+01),
  (  0.5989826532569E-09, 0.2231842216620E+01, 0.6256777527156E+01),
  (  0.5961360812618E-09, 0.1274975769045E+01, 0.6309374173736E+01),
  (  0.4874165471016E-09, 0.3642277426779E+01, 0.7755226100720E+00),
  //DATA ((E1(I,J,2),I=1,3),J= 11, 20)),
  (  0.4283834034360E-09, 0.5148765510106E+01, 0.1059381944224E+01),
  (  0.4652389287529E-09, 0.4715794792175E+01, 0.7860419393880E+01),
  (  0.3751707476401E-09, 0.6617207370325E+00, 0.5753384878334E+01),
  (  0.3559998806198E-09, 0.6155548875404E+01, 0.5884926831456E+01),
  (  0.3558447558857E-09, 0.2898827297664E+01, 0.6812766822558E+01),
  (  0.3211116927106E-09, 0.3625813502509E+01, 0.6681224869435E+01),
  (  0.2875609914672E-09, 0.4345435813134E+01, 0.2513230340178E+02),
  (  0.2843109704069E-09, 0.5862263940038E+01, 0.6127655567643E+01),
  (  0.2744676468427E-09, 0.3926419475089E+01, 0.6438496133249E+01),
  (  0.2481285237789E-09, 0.1351976572828E+01, 0.5486777812467E+01),
  //DATA ((E1(I,J,2),I=1,3),J= 21, 30)),
  (  0.2060338481033E-09, 0.2147556998591E+01, 0.7079373888424E+01),
  (  0.2015822358331E-09, 0.4408358972216E+01, 0.6290189305114E+01),
  (  0.2001195944195E-09, 0.5385829822531E+01, 0.6275962395778E+01),
  (  0.1953667642377E-09, 0.1304933746120E+01, 0.5507553240374E+01),
  (  0.1839744078713E-09, 0.6173567228835E+01, 0.1179062909082E+02),
  (  0.1643334294845E-09, 0.4635942997523E+01, 0.1150676975667E+02),
  (  0.1768051018652E-09, 0.5086283558874E+01, 0.7113454667900E-02),
  (  0.1674874205489E-09, 0.2243332137241E+01, 0.7058598460518E+01),
  (  0.1421445397609E-09, 0.6186899771515E+01, 0.7962980379786E+00),
  (  0.1255163958267E-09, 0.5730238465658E+01, 0.4694002934110E+01),
  //DATA ((E1(I,J,2),I=1,3),J= 31, 40)),
  (  0.1013945281961E-09, 0.1726055228402E+01, 0.3738761453707E+01),
  (  0.1047294335852E-09, 0.2658801228129E+01, 0.6282095334605E+01),
  (  0.1047103879392E-09, 0.8481047835035E+00, 0.6284056366286E+01),
  (  0.9530343962826E-10, 0.3079267149859E+01, 0.6069776770667E+01),
  (  0.9604637611690E-10, 0.3258679792918E+00, 0.4136910472696E+01),
  (  0.9153518537177E-10, 0.4398599886584E+00, 0.6496374930224E+01),
  (  0.8562458214922E-10, 0.4772686794145E+01, 0.1194447056968E+01),
  (  0.8232525360654E-10, 0.5966220721679E+01, 0.1589072916335E+01),
  (  0.6150223411438E-10, 0.1780985591923E+01, 0.8827390247185E+01),
  (  0.6272087858000E-10, 0.3184305429012E+01, 0.8429241228195E+01),
  //DATA ((E1(I,J,2),I=1,3),J= 41, 50)),
  (  0.5540476311040E-10, 0.3801260595433E+01, 0.4933208510675E+01),
  (  0.7331901699361E-10, 0.5205948591865E+01, 0.4535059491685E+01),
  (  0.6018528702791E-10, 0.4770139083623E+01, 0.1255903824622E+02),
  (  0.5150530724804E-10, 0.3574796899585E+01, 0.1176985366291E+02),
  (  0.6471933741811E-10, 0.2679787266521E+01, 0.5088628793478E+01),
  (  0.5317460644174E-10, 0.9528763345494E+00, 0.3154687086868E+01),
  (  0.4832187748783E-10, 0.5329322498232E+01, 0.6040347114260E+01),
  (  0.4716763555110E-10, 0.2395235316466E+01, 0.5331357529664E+01),
  (  0.4871509139861E-10, 0.3056663648823E+01, 0.1256967486051E+02),
  (  0.4598417696768E-10, 0.4452762609019E+01, 0.6525804586632E+01),
  //DATA ((E1(I,J,2),I=1,3),J= 51, 60)),
  (  0.5674189533175E-10, 0.9879680872193E+00, 0.5729506548653E+01),
  (  0.4073560328195E-10, 0.5939127696986E+01, 0.7632943190217E+01),
  (  0.5040994945359E-10, 0.4549875824510E+01, 0.8031092209206E+01),
  (  0.5078185134679E-10, 0.7346659893982E+00, 0.7477522907414E+01),
  (  0.3769343537061E-10, 0.1071317188367E+01, 0.7234794171227E+01),
  (  0.4980331365299E-10, 0.2500345341784E+01, 0.6836645152238E+01),
  (  0.3458236594757E-10, 0.3825159450711E+01, 0.1097707878456E+02),
  (  0.3578859493602E-10, 0.5299664791549E+01, 0.4164311961999E+01),
  (  0.3370504646419E-10, 0.5002316301593E+01, 0.1137170464392E+02),
  (  0.3299873338428E-10, 0.2526123275282E+01, 0.3930209696940E+01),
  //DATA ((E1(I,J,2),I=1,3),J= 61, 70)),
  (  0.4304917318409E-10, 0.3368078557132E+01, 0.1592596075957E+01),
  (  0.3402418753455E-10, 0.8385495425800E+00, 0.3128388763578E+01),
  (  0.2778460572146E-10, 0.3669905203240E+01, 0.7342457794669E+01),
  (  0.2782710128902E-10, 0.2691664812170E+00, 0.1748016358760E+01),
  (  0.2711725179646E-10, 0.4707487217718E+01, 0.5296909721118E+00),
  (  0.2981760946340E-10, 0.3190260867816E+00, 0.5368044267797E+00),
  (  0.2811672977772E-10, 0.3196532315372E+01, 0.7084896783808E+01),
  (  0.2863454474467E-10, 0.2263240324780E+00, 0.5223693906222E+01),
  (  0.3333464634051E-10, 0.3498451685065E+01, 0.8018209333619E+00),
  (  0.3312991747609E-10, 0.5839154477412E+01, 0.1554202828031E+00),
  //DATA ((E1(I,J,2),I=1,3),J= 71,NE1Y)),
  (  0.2813255564006E-10, 0.8268044346621E+00, 0.5225775174439E+00),
  (  0.2665098083966E-10, 0.3934021725360E+01, 0.5216580451554E+01),
  (  0.2349795705216E-10, 0.5197620913779E+01, 0.2146165377750E+01),
  (  0.2330352293961E-10, 0.2984999231807E+01, 0.1726015463500E+02),
  (  0.2728001683419E-10, 0.6521679638544E+00, 0.8635942003952E+01),
  (  0.2484061007669E-10, 0.3468955561097E+01, 0.5230807360890E+01),
  (  0.2646328768427E-10, 0.1013724533516E+01, 0.2629832328990E-01),
  (  0.2518630264831E-10, 0.6108081057122E+01, 0.5481254917084E+01),
  (  0.2421901455384E-10, 0.1651097776260E+01, 0.1349867339771E+01),
  (  0.6348533267831E-11, 0.3220226560321E+01, 0.8433466158131E+02)),

  //  Sun-to-Earth, T^1, Z	),
  //DATA ((E1(I,J,3),I=1,3),J=  1, 10)),
  ((  0.2278290449966E-05, 0.3413716033863E+01, 0.6283075850446E+01),
  (  0.5429458209830E-07, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.1903240492525E-07, 0.3370592358297E+01, 0.1256615170089E+02),
  (  0.2385409276743E-09, 0.3327914718416E+01, 0.1884922755134E+02),
  (  0.8676928342573E-10, 0.1824006811264E+01, 0.5223693906222E+01),
  (  0.7765442593544E-10, 0.3888564279247E+01, 0.5507553240374E+01),
  (  0.7066158332715E-10, 0.5194267231944E+01, 0.2352866153506E+01),
  (  0.7092175288657E-10, 0.2333246960021E+01, 0.8399684731857E+02),
  (  0.5357582213535E-10, 0.2224031176619E+01, 0.5296909721118E+00),
  (  0.3828035865021E-10, 0.2156710933584E+01, 0.6279552690824E+01),
  //DATA ((E1(I,J,3),I=1,3),J= 11,NE1Z)),
  (  0.3824857220427E-10, 0.1529755219915E+01, 0.6286599010068E+01),
  (  0.3286995181628E-10, 0.4879512900483E+01, 0.1021328554739E+02),
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    ),{not used}
  (                0    ,               0    ,               0    )));{not used}

  //Sun-to-Earth, T^2, X
  //DATA ((E2(I,J,1),I=1,3),J=  1,NE2X) /
  E2: array[1..3,1..ME2,1..3] of double=    {5}
  ((( -0.4143818297913E-10, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.2171497694435E-10, 0.4398225628264E+01, 0.1256615170089E+02),
  (  0.9845398442516E-11, 0.2079720838384E+00, 0.6283075850446E+01),
  (  0.9256833552682E-12, 0.4191264694361E+01, 0.1884922755134E+02),
  (  0.1022049384115E-12, 0.5381133195658E+01, 0.8399684731857E+02)),

  //*  Sun-to-Earth, T^2, Y	),
  //DATA ((E2(I,J,2),I=1,3),J=  1,NE2Y)),
  ((  0.5063375872532E-10, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.2173815785980E-10, 0.2827805833053E+01, 0.1256615170089E+02),
  (  0.1010231999920E-10, 0.4634612377133E+01, 0.6283075850446E+01),
  (  0.9259745317636E-12, 0.2620612076189E+01, 0.1884922755134E+02),
  (  0.1022202095812E-12, 0.3809562326066E+01, 0.8399684731857E+02)),

  //*  Sun-to-Earth, T^2, Z	),
  //DATA ((E2(I,J,3),I=1,3),J=  1,NE2Z)),
  ((  0.9722666114891E-10, 0.5152219582658E+01, 0.6283075850446E+01),
  ( -0.3494819171909E-11, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.6713034376076E-12, 0.6440188750495E+00, 0.1256615170089E+02),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    )));



  //*  SSB-to-Sun, T^0, X	),
  //DATA ((S0(I,J,1),I=1,3),J=  1, 10)),
{  S0 : array[1..3,1..MS0,1..3] of double=
  (((  0.4956757536410E-02, 0.3741073751789E+01, 0.5296909721118E+00),
  (  0.2718490072522E-02, 0.4016011511425E+01, 0.2132990797783E+00),
  (  0.1546493974344E-02, 0.2170528330642E+01, 0.3813291813120E-01),
  (  0.8366855276341E-03, 0.2339614075294E+01, 0.7478166569050E-01),
  (  0.2936777942117E-03, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.1201317439469E-03, 0.4090736353305E+01, 0.1059381944224E+01),
  (  0.7578550887230E-04, 0.3241518088140E+01, 0.4265981595566E+00),
  (  0.1941787367773E-04, 0.1012202064330E+01, 0.2061856251104E+00),
  (  0.1889227765991E-04, 0.3892520416440E+01, 0.2204125344462E+00),
  (  0.1937896968613E-04, 0.4797779441161E+01, 0.1495633313810E+00),
  //DATA ((S0(I,J,1),I=1,3),J= 11, 20)),
  (  0.1434506110873E-04, 0.3868960697933E+01, 0.5225775174439E+00),
  (  0.1406659911580E-04, 0.4759766557397E+00, 0.5368044267797E+00),
  (  0.1179022300202E-04, 0.7774961520598E+00, 0.7626583626240E-01),
  (  0.8085864460959E-05, 0.3254654471465E+01, 0.3664874755930E-01),
  (  0.7622752967615E-05, 0.4227633103489E+01, 0.3961708870310E-01),
  (  0.6209171139066E-05, 0.2791828325711E+00, 0.7329749511860E-01),
  (  0.4366435633970E-05, 0.4440454875925E+01, 0.1589072916335E+01),
  (  0.3792124889348E-05, 0.5156393842356E+01, 0.7113454667900E-02),
  (  0.3154548963402E-05, 0.6157005730093E+01, 0.4194847048887E+00),
  (  0.3088359882942E-05, 0.2494567553163E+01, 0.6398972393349E+00),
  //DATA ((S0(I,J,1),I=1,3),J= 21, 30)),
  (  0.2788440902136E-05, 0.4934318747989E+01, 0.1102062672231E+00),
  (  0.3039928456376E-05, 0.4895077702640E+01, 0.6283075850446E+01),
  (  0.2272258457679E-05, 0.5278394064764E+01, 0.1030928125552E+00),
  (  0.2162007057957E-05, 0.5802978019099E+01, 0.3163918923335E+00),
  (  0.1767632855737E-05, 0.3415346595193E-01, 0.1021328554739E+02),
  (  0.1349413459362E-05, 0.2001643230755E+01, 0.1484170571900E-02),
  (  0.1170141900476E-05, 0.2424750491620E+01, 0.6327837846670E+00),
  (  0.1054355266820E-05, 0.3123311487576E+01, 0.4337116142245E+00),
  (  0.9800822461610E-06, 0.3026258088130E+01, 0.1052268489556E+01),
  (  0.1091203749931E-05, 0.3157811670347E+01, 0.1162474756779E+01),
  //DATA ((S0(I,J,1),I=1,3),J= 31, 40)),
  (  0.6960236715913E-06, 0.8219570542313E+00, 0.1066495398892E+01),
  (  0.5689257296909E-06, 0.1323052375236E+01, 0.9491756770005E+00),
  (  0.6613172135802E-06, 0.2765348881598E+00, 0.8460828644453E+00),
  (  0.6277702517571E-06, 0.5794064466382E+01, 0.1480791608091E+00),
  (  0.6304884066699E-06, 0.7323555380787E+00, 0.2243449970715E+00),
  (  0.4897850467382E-06, 0.3062464235399E+01, 0.3340612434717E+01),
  (  0.3759148598786E-06, 0.4588290469664E+01, 0.3516457698740E-01),
  (  0.3110520548195E-06, 0.1374299536572E+01, 0.6373574839730E-01),
  (  0.3064708359780E-06, 0.4222267485047E+01, 0.1104591729320E-01),
  (  0.2856347168241E-06, 0.3714202944973E+01, 0.1510475019529E+00),
  //DATA ((S0(I,J,1),I=1,3),J= 41, 50)),
  (  0.2840945514288E-06, 0.2847972875882E+01, 0.4110125927500E-01),
  (  0.2378951599405E-06, 0.3762072563388E+01, 0.2275259891141E+00),
  (  0.2714229481417E-06, 0.1036049980031E+01, 0.2535050500000E-01),
  (  0.2323551717307E-06, 0.4682388599076E+00, 0.8582758298370E-01),
  (  0.1881790512219E-06, 0.4790565425418E+01, 0.2118763888447E+01),
  (  0.2261353968371E-06, 0.1669144912212E+01, 0.7181332454670E-01),
  (  0.2214546389848E-06, 0.3937717281614E+01, 0.2968341143800E-02),
  (  0.2184915594933E-06, 0.1129169845099E+00, 0.7775000683430E-01),
  (  0.2000164937936E-06, 0.4030009638488E+01, 0.2093666171530E+00),
  (  0.1966105136719E-06, 0.8745955786834E+00, 0.2172315424036E+00),
  //DATA ((S0(I,J,1),I=1,3),J= 51, 60)),
  (  0.1904742332624E-06, 0.5919743598964E+01, 0.2022531624851E+00),
  (  0.1657399705031E-06, 0.2549141484884E+01, 0.7358765972222E+00),
  (  0.1574070533987E-06, 0.5277533020230E+01, 0.7429900518901E+00),
  (  0.1832261651039E-06, 0.3064688127777E+01, 0.3235053470014E+00),
  (  0.1733615346569E-06, 0.3011432799094E+01, 0.1385174140878E+00),
  (  0.1549124014496E-06, 0.4005569132359E+01, 0.5154640627760E+00),
  (  0.1637044713838E-06, 0.1831375966632E+01, 0.8531963191132E+00),
  (  0.1123420082383E-06, 0.1180270407578E+01, 0.1990721704425E+00),
  (  0.1083754165740E-06, 0.3414101320863E+00, 0.5439178814476E+00),
  (  0.1156638012655E-06, 0.6130479452594E+00, 0.5257585094865E+00),
  //DATA ((S0(I,J,1),I=1,3),J= 61, 70)),
  (  0.1142548785134E-06, 0.3724761948846E+01, 0.5336234347371E+00),
  (  0.7921463895965E-07, 0.2435425589361E+01, 0.1478866649112E+01),
  (  0.7428600285231E-07, 0.3542144398753E+01, 0.2164800718209E+00),
  (  0.8323211246747E-07, 0.3525058072354E+01, 0.1692165728891E+01),
  (  0.7257595116312E-07, 0.1364299431982E+01, 0.2101180877357E+00),
  (  0.7111185833236E-07, 0.2460478875808E+01, 0.4155522422634E+00),
  (  0.6868090383716E-07, 0.4397327670704E+01, 0.1173197218910E+00),
  (  0.7226419974175E-07, 0.4042647308905E+01, 0.1265567569334E+01),
  (  0.6955642383177E-07, 0.2865047906085E+01, 0.9562891316684E+00),
  (  0.7492139296331E-07, 0.5014278994215E+01, 0.1422690933580E-01),
  //DATA ((S0(I,J,1),I=1,3),J= 71, 80)),
  (  0.6598363128857E-07, 0.2376730020492E+01, 0.6470106940028E+00),
  (  0.7381147293385E-07, 0.3272990384244E+01, 0.1581959461667E+01),
  (  0.6402909624032E-07, 0.5302290955138E+01, 0.9597935788730E-01),
  (  0.6237454263857E-07, 0.5444144425332E+01, 0.7084920306520E-01),
  (  0.5241198544016E-07, 0.4215359579205E+01, 0.5265099800692E+00),
  (  0.5144463853918E-07, 0.1218916689916E+00, 0.5328719641544E+00),
  (  0.5868164772299E-07, 0.2369402002213E+01, 0.7871412831580E-01),
  (  0.6233195669151E-07, 0.1254922242403E+01, 0.2608790314060E+02),
  (  0.6068463791422E-07, 0.5679713760431E+01, 0.1114304132498E+00),
  (  0.4359361135065E-07, 0.6097219641646E+00, 0.1375773836557E+01),
  //DATA ((S0(I,J,1),I=1,3),J= 81, 90)),
  (  0.4686510366826E-07, 0.4786231041431E+01, 0.1143987543936E+00),
  (  0.3758977287225E-07, 0.1167368068139E+01, 0.1596186371003E+01),
  (  0.4282051974778E-07, 0.1519471064319E+01, 0.2770348281756E+00),
  (  0.5153765386113E-07, 0.1860532322984E+01, 0.2228608264996E+00),
  (  0.4575129387188E-07, 0.7632857887158E+00, 0.1465949902372E+00),
  (  0.3326844933286E-07, 0.1298219485285E+01, 0.5070101000000E-01),
  (  0.3748617450984E-07, 0.1046510321062E+01, 0.4903339079539E+00),
  (  0.2816756661499E-07, 0.3434522346190E+01, 0.2991266627620E+00),
  (  0.3412750405039E-07, 0.2523766270318E+01, 0.3518164938661E+00),
  (  0.2655796761776E-07, 0.2904422260194E+01, 0.6256703299991E+00),
  //DATA ((S0(I,J,1),I=1,3),J= 91,100)),
  (  0.2963597929458E-07, 0.5923900431149E+00, 0.1099462426779E+00),
  (  0.2539523734781E-07, 0.4851947722567E+01, 0.1256615170089E+02),
  (  0.2283087914139E-07, 0.3400498595496E+01, 0.6681224869435E+01),
  (  0.2321309799331E-07, 0.5789099148673E+01, 0.3368040641550E-01),
  (  0.2549657649750E-07, 0.3991856479792E-01, 0.1169588211447E+01),
  (  0.2290462303977E-07, 0.2788567577052E+01, 0.1045155034888E+01),
  (  0.1945398522914E-07, 0.3290896998176E+01, 0.1155361302111E+01),
  (  0.1849171512638E-07, 0.2698060129367E+01, 0.4452511715700E-02),
  (  0.1647199834254E-07, 0.3016735644085E+01, 0.4408250688924E+00),
  (  0.1529530765273E-07, 0.5573043116178E+01, 0.6521991896920E-01),
  //DATA ((S0(I,J,1),I=1,3),J=101,110)),
  (  0.1433199339978E-07, 0.1481192356147E+01, 0.9420622223326E+00),
  (  0.1729134193602E-07, 0.1422817538933E+01, 0.2108507877249E+00),
  (  0.1716463931346E-07, 0.3469468901855E+01, 0.2157473718317E+00),
  (  0.1391206061378E-07, 0.6122436220547E+01, 0.4123712502208E+00),
  (  0.1404746661924E-07, 0.1647765641936E+01, 0.4258542984690E-01),
  (  0.1410452399455E-07, 0.5989729161964E+01, 0.2258291676434E+00),
  (  0.1089828772168E-07, 0.2833705509371E+01, 0.4226656969313E+00),
  (  0.1047374564948E-07, 0.5090690007331E+00, 0.3092784376656E+00),
  (  0.1358279126532E-07, 0.5128990262836E+01, 0.7923417740620E-01),
  (  0.1020456476148E-07, 0.9632772880808E+00, 0.1456308687557E+00),
  //DATA ((S0(I,J,1),I=1,3),J=111,120)),
  (  0.1033428735328E-07, 0.3223779318418E+01, 0.1795258541446E+01),
  (  0.1412435841540E-07, 0.2410271572721E+01, 0.1525316725248E+00),
  (  0.9722759371574E-08, 0.2333531395690E+01, 0.8434341241180E-01),
  (  0.9657334084704E-08, 0.6199270974168E+01, 0.1272681024002E+01),
  (  0.1083641148690E-07, 0.2864222292929E+01, 0.7032915397480E-01),
  (  0.1067318403838E-07, 0.5833458866568E+00, 0.2123349582968E+00),
  (  0.1062366201976E-07, 0.4307753989494E+01, 0.2142632012598E+00),
  (  0.1236364149266E-07, 0.2873917870593E+01, 0.1847279083684E+00),
  (  0.1092759489593E-07, 0.2959887266733E+01, 0.1370332435159E+00),
  (  0.8912069362899E-08, 0.5141213702562E+01, 0.2648454860559E+01),
  //DATA ((S0(I,J,1),I=1,3),J=121,130)),
  (  0.9656467707970E-08, 0.4532182462323E+01, 0.4376440768498E+00),
  (  0.8098386150135E-08, 0.2268906338379E+01, 0.2880807454688E+00),
  (  0.7857714675000E-08, 0.4055544260745E+01, 0.2037373330570E+00),
  (  0.7288455940646E-08, 0.5357901655142E+01, 0.1129145838217E+00),
  (  0.9450595950552E-08, 0.4264926963939E+01, 0.5272426800584E+00),
  (  0.9381718247537E-08, 0.7489366976576E-01, 0.5321392641652E+00),
  (  0.7079052646038E-08, 0.1923311052874E+01, 0.6288513220417E+00),
  (  0.9259004415344E-08, 0.2970256853438E+01, 0.1606092486742E+00),
  (  0.8259801499742E-08, 0.3327056314697E+01, 0.8389694097774E+00),
  (  0.6476334355779E-08, 0.2954925505727E+01, 0.2008557621224E+01),
  //DATA ((S0(I,J,1),I=1,3),J=131,140)),
  (  0.5984021492007E-08, 0.9138753105829E+00, 0.2042657109477E+02),
  (  0.5989546863181E-08, 0.3244464082031E+01, 0.2111650433779E+01),
  (  0.6233108606023E-08, 0.4995232638403E+00, 0.4305306221819E+00),
  (  0.6877299149965E-08, 0.2834987233449E+01, 0.9561746721300E-02),
  (  0.8311234227190E-08, 0.2202951835758E+01, 0.3801276407308E+00),
  (  0.6599472832414E-08, 0.4478581462618E+01, 0.1063314406849E+01),
  (  0.6160491096549E-08, 0.5145858696411E+01, 0.1368660381889E+01),
  (  0.6164772043891E-08, 0.3762976697911E+00, 0.4234171675140E+00),
  (  0.6363248684450E-08, 0.3162246718685E+01, 0.1253008786510E-01),
  (  0.6448587520999E-08, 0.3442693302119E+01, 0.5287268506303E+00),
  //DATA ((S0(I,J,1),I=1,3),J=141,150)),
  (  0.6431662283977E-08, 0.8977549136606E+00, 0.5306550935933E+00),
  (  0.6351223158474E-08, 0.4306447410369E+01, 0.5217580628120E+02),
  (  0.5476721393451E-08, 0.3888529177855E+01, 0.2221856701002E+01),
  (  0.5341772572619E-08, 0.2655560662512E+01, 0.7466759693650E-01),
  (  0.5337055758302E-08, 0.5164990735946E+01, 0.7489573444450E-01),
  (  0.5373120816787E-08, 0.6041214553456E+01, 0.1274714967946E+00),
  (  0.5392351705426E-08, 0.9177763485932E+00, 0.1055449481598E+01),
  (  0.6688495850205E-08, 0.3089608126937E+01, 0.2213766559277E+00),
  (  0.5072003660362E-08, 0.4311316541553E+01, 0.2132517061319E+00),
  (  0.5070726650455E-08, 0.5790675464444E+00, 0.2133464534247E+00),
  //DATA ((S0(I,J,1),I=1,3),J=151,160)),
  (  0.5658012950032E-08, 0.2703945510675E+01, 0.7287631425543E+00),
  (  0.4835509924854E-08, 0.2975422976065E+01, 0.7160067364790E-01),
  (  0.6479821978012E-08, 0.1324168733114E+01, 0.2209183458640E-01),
  (  0.6230636494980E-08, 0.2860103632836E+01, 0.3306188016693E+00),
  (  0.4649239516213E-08, 0.4832259763403E+01, 0.7796265773310E-01),
  (  0.6487325792700E-08, 0.2726165825042E+01, 0.3884652414254E+00),
  (  0.4682823682770E-08, 0.6966602455408E+00, 0.1073608853559E+01),
  (  0.5704230804976E-08, 0.5669634104606E+01, 0.8731175355560E-01),
  (  0.6125413585489E-08, 0.1513386538915E+01, 0.7605151500000E-01),
  (  0.6035825038187E-08, 0.1983509168227E+01, 0.9846002785331E+00),
  //DATA ((S0(I,J,1),I=1,3),J=161,170)),
  (  0.4331123462303E-08, 0.2782892992807E+01, 0.4297791515992E+00),
  (  0.4681107685143E-08, 0.5337232886836E+01, 0.2127790306879E+00),
  (  0.4669105829655E-08, 0.5837133792160E+01, 0.2138191288687E+00),
  (  0.5138823602365E-08, 0.3080560200507E+01, 0.7233337363710E-01),
  (  0.4615856664534E-08, 0.1661747897471E+01, 0.8603097737811E+00),
  (  0.4496916702197E-08, 0.2112508027068E+01, 0.7381754420900E-01),
  (  0.4278479042945E-08, 0.5716528462627E+01, 0.7574578717200E-01),
  (  0.3840525503932E-08, 0.6424172726492E+00, 0.3407705765729E+00),
  (  0.4866636509685E-08, 0.4919244697715E+01, 0.7722995774390E-01),
  (  0.3526100639296E-08, 0.2550821052734E+01, 0.6225157782540E-01),
  //DATA ((S0(I,J,1),I=1,3),J=171,180)),
  (  0.3939558488075E-08, 0.3939331491710E+01, 0.5268983110410E-01),
  (  0.4041268772576E-08, 0.2275337571218E+01, 0.3503323232942E+00),
  (  0.3948761842853E-08, 0.1999324200790E+01, 0.1451108196653E+00),
  (  0.3258394550029E-08, 0.9121001378200E+00, 0.5296435984654E+00),
  (  0.3257897048761E-08, 0.3428428660869E+01, 0.5297383457582E+00),
  (  0.3842559031298E-08, 0.6132927720035E+01, 0.9098186128426E+00),
  (  0.3109920095448E-08, 0.7693650193003E+00, 0.3932462625300E-02),
  (  0.3132237775119E-08, 0.3621293854908E+01, 0.2346394437820E+00),
  (  0.3942189421510E-08, 0.4841863659733E+01, 0.3180992042600E-02),
  (  0.3796972285340E-08, 0.1814174994268E+01, 0.1862120789403E+00),
  //DATA ((S0(I,J,1),I=1,3),J=181,190)),
  (  0.3995640233688E-08, 0.1386990406091E+01, 0.4549093064213E+00),
  (  0.2875013727414E-08, 0.9178318587177E+00, 0.1905464808669E+01),
  (  0.3073719932844E-08, 0.2688923811835E+01, 0.3628624111593E+00),
  (  0.2731016580075E-08, 0.1188259127584E+01, 0.2131850110243E+00),
  (  0.2729549896546E-08, 0.3702160634273E+01, 0.2134131485323E+00),
  (  0.3339372892449E-08, 0.7199163960331E+00, 0.2007689919132E+00),
  (  0.2898833764204E-08, 0.1916709364999E+01, 0.5291709230214E+00),
  (  0.2894536549362E-08, 0.2424043195547E+01, 0.5302110212022E+00),
  (  0.3096872473843E-08, 0.4445894977497E+01, 0.2976424921901E+00),
  (  0.2635672326810E-08, 0.3814366984117E+01, 0.1485980103780E+01),
  //DATA ((S0(I,J,1),I=1,3),J=191,200)),
  (  0.3649302697001E-08, 0.2924200596084E+01, 0.6044726378023E+00),
  (  0.3127954585895E-08, 0.1842251648327E+01, 0.1084620721060E+00),
  (  0.2616040173947E-08, 0.4155841921984E+01, 0.1258454114666E+01),
  (  0.2597395859860E-08, 0.1158045978874E+00, 0.2103781122809E+00),
  (  0.2593286172210E-08, 0.4771850408691E+01, 0.2162200472757E+00),
  (  0.2481823585747E-08, 0.4608842558889E+00, 0.1062562936266E+01),
  (  0.2742219550725E-08, 0.1538781127028E+01, 0.5651155736444E+00),
  (  0.3199558469610E-08, 0.3226647822878E+00, 0.7036329877322E+00),
  (  0.2666088542957E-08, 0.1967991731219E+00, 0.1400015846597E+00),
  (  0.2397067430580E-08, 0.3707036669873E+01, 0.2125476091956E+00),
  //DATA ((S0(I,J,1),I=1,3),J=201,210)),
  (  0.2376570772738E-08, 0.1182086628042E+01, 0.2140505503610E+00),
  (  0.2547228007887E-08, 0.4906256820629E+01, 0.1534957940063E+00),
  (  0.2265575594114E-08, 0.3414949866857E+01, 0.2235935264888E+00),
  (  0.2464381430585E-08, 0.4599122275378E+01, 0.2091065926078E+00),
  (  0.2433408527044E-08, 0.2830751145445E+00, 0.2174915669488E+00),
  (  0.2443605509076E-08, 0.4212046432538E+01, 0.1739420156204E+00),
  (  0.2319779262465E-08, 0.9881978408630E+00, 0.7530171478090E-01),
  (  0.2284622835465E-08, 0.5565347331588E+00, 0.7426161660010E-01),
  (  0.2467268750783E-08, 0.5655708150766E+00, 0.2526561439362E+00),
  (  0.2808513492782E-08, 0.1418405053408E+01, 0.5636314030725E+00),
  //DATA ((S0(I,J,1),I=1,3),J=211,NS0X)),
  (  0.2329528932532E-08, 0.4069557545675E+01, 0.1056200952181E+01),
  (  0.9698639532817E-09, 0.1074134313634E+01, 0.7826370942180E+02),
  (                0    ,               0    ,               0    )),

  //*  SSB-to-Sun, T^0, Y	),
  //DATA ((S0(I,J,2),I=1,3),J=  1, 10)),
  ((  0.4955392320126E-02, 0.2170467313679E+01, 0.5296909721118E+00),
  (  0.2722325167392E-02, 0.2444433682196E+01, 0.2132990797783E+00),
  (  0.1546579925346E-02, 0.5992779281546E+00, 0.3813291813120E-01),
  (  0.8363140252966E-03, 0.7687356310801E+00, 0.7478166569050E-01),
  (  0.3385792683603E-03, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.1201192221613E-03, 0.2520035601514E+01, 0.1059381944224E+01),
  (  0.7587125720554E-04, 0.1669954006449E+01, 0.4265981595566E+00),
  (  0.1964155361250E-04, 0.5707743963343E+01, 0.2061856251104E+00),
  (  0.1891900364909E-04, 0.2320960679937E+01, 0.2204125344462E+00),
  (  0.1937373433356E-04, 0.3226940689555E+01, 0.1495633313810E+00),
  //DATA ((S0(I,J,2),I=1,3),J= 11, 20)),
  (  0.1437139941351E-04, 0.2301626908096E+01, 0.5225775174439E+00),
  (  0.1406267683099E-04, 0.5188579265542E+01, 0.5368044267797E+00),
  (  0.1178703080346E-04, 0.5489483248476E+01, 0.7626583626240E-01),
  (  0.8079835186041E-05, 0.1683751835264E+01, 0.3664874755930E-01),
  (  0.7623253594652E-05, 0.2656400462961E+01, 0.3961708870310E-01),
  (  0.6248667483971E-05, 0.4992775362055E+01, 0.7329749511860E-01),
  (  0.4366353695038E-05, 0.2869706279678E+01, 0.1589072916335E+01),
  (  0.3829101568895E-05, 0.3572131359950E+01, 0.7113454667900E-02),
  (  0.3175733773908E-05, 0.4535372530045E+01, 0.4194847048887E+00),
  (  0.3092437902159E-05, 0.9230153317909E+00, 0.6398972393349E+00),
  //DATA ((S0(I,J,2),I=1,3),J= 21, 30)),
  (  0.2874168812154E-05, 0.3363143761101E+01, 0.1102062672231E+00),
  (  0.3040119321826E-05, 0.3324250895675E+01, 0.6283075850446E+01),
  (  0.2699723308006E-05, 0.2917882441928E+00, 0.1030928125552E+00),
  (  0.2134832683534E-05, 0.4220997202487E+01, 0.3163918923335E+00),
  (  0.1770412139433E-05, 0.4747318496462E+01, 0.1021328554739E+02),
  (  0.1377264209373E-05, 0.4305058462401E+00, 0.1484170571900E-02),
  (  0.1127814538960E-05, 0.8538177240740E+00, 0.6327837846670E+00),
  (  0.1055608090130E-05, 0.1551800742580E+01, 0.4337116142245E+00),
  (  0.9802673861420E-06, 0.1459646735377E+01, 0.1052268489556E+01),
  (  0.1090329461951E-05, 0.1587351228711E+01, 0.1162474756779E+01),
  //DATA ((S0(I,J,2),I=1,3),J= 31, 40)),
  (  0.6959590025090E-06, 0.5534442628766E+01, 0.1066495398892E+01),
  (  0.5664914529542E-06, 0.6030673003297E+01, 0.9491756770005E+00),
  (  0.6607787763599E-06, 0.4989507233927E+01, 0.8460828644453E+00),
  (  0.6269725742838E-06, 0.4222951804572E+01, 0.1480791608091E+00),
  (  0.6301889697863E-06, 0.5444316669126E+01, 0.2243449970715E+00),
  (  0.4891042662861E-06, 0.1490552839784E+01, 0.3340612434717E+01),
  (  0.3457083123290E-06, 0.3030475486049E+01, 0.3516457698740E-01),
  (  0.3032559967314E-06, 0.2652038793632E+01, 0.1104591729320E-01),
  (  0.2841133988903E-06, 0.1276744786829E+01, 0.4110125927500E-01),
  (  0.2855564444432E-06, 0.2143368674733E+01, 0.1510475019529E+00),
  //DATA ((S0(I,J,2),I=1,3),J= 41, 50)),
  (  0.2765157135038E-06, 0.5444186109077E+01, 0.6373574839730E-01),
  (  0.2382312465034E-06, 0.2190521137593E+01, 0.2275259891141E+00),
  (  0.2808060365077E-06, 0.5735195064841E+01, 0.2535050500000E-01),
  (  0.2332175234405E-06, 0.9481985524859E-01, 0.7181332454670E-01),
  (  0.2322488199659E-06, 0.5180499361533E+01, 0.8582758298370E-01),
  (  0.1881850258423E-06, 0.3219788273885E+01, 0.2118763888447E+01),
  (  0.2196111392808E-06, 0.2366941159761E+01, 0.2968341143800E-02),
  (  0.2183810335519E-06, 0.4825445110915E+01, 0.7775000683430E-01),
  (  0.2002733093326E-06, 0.2457148995307E+01, 0.2093666171530E+00),
  (  0.1967111767229E-06, 0.5586291545459E+01, 0.2172315424036E+00),
  //DATA ((S0(I,J,2),I=1,3),J= 51, 60)),
  (  0.1568473250543E-06, 0.3708003123320E+01, 0.7429900518901E+00),
  (  0.1852528314300E-06, 0.4310638151560E+01, 0.2022531624851E+00),
  (  0.1832111226447E-06, 0.1494665322656E+01, 0.3235053470014E+00),
  (  0.1746805502310E-06, 0.1451378500784E+01, 0.1385174140878E+00),
  (  0.1555730966650E-06, 0.1068040418198E+01, 0.7358765972222E+00),
  (  0.1554883462559E-06, 0.2442579035461E+01, 0.5154640627760E+00),
  (  0.1638380568746E-06, 0.2597913420625E+00, 0.8531963191132E+00),
  (  0.1159938593640E-06, 0.5834512021280E+01, 0.1990721704425E+00),
  (  0.1083427965695E-06, 0.5054033177950E+01, 0.5439178814476E+00),
  (  0.1156480369431E-06, 0.5325677432457E+01, 0.5257585094865E+00),
  //DATA ((S0(I,J,2),I=1,3),J= 61, 70)),
  (  0.1141308860095E-06, 0.2153403923857E+01, 0.5336234347371E+00),
  (  0.7913146470946E-07, 0.8642846847027E+00, 0.1478866649112E+01),
  (  0.7439752463733E-07, 0.1970628496213E+01, 0.2164800718209E+00),
  (  0.7280277104079E-07, 0.6073307250609E+01, 0.2101180877357E+00),
  (  0.8319567719136E-07, 0.1954371928334E+01, 0.1692165728891E+01),
  (  0.7137705549290E-07, 0.8904989440909E+00, 0.4155522422634E+00),
  (  0.6900825396225E-07, 0.2825717714977E+01, 0.1173197218910E+00),
  (  0.7245757216635E-07, 0.2481677513331E+01, 0.1265567569334E+01),
  (  0.6961165696255E-07, 0.1292955312978E+01, 0.9562891316684E+00),
  (  0.7571804456890E-07, 0.3427517575069E+01, 0.1422690933580E-01),
  //DATA ((S0(I,J,2),I=1,3),J= 71, 80)),
  (  0.6605425721904E-07, 0.8052192701492E+00, 0.6470106940028E+00),
  (  0.7375477357248E-07, 0.1705076390088E+01, 0.1581959461667E+01),
  (  0.7041664951470E-07, 0.4848356967891E+00, 0.9597935788730E-01),
  (  0.6322199535763E-07, 0.3878069473909E+01, 0.7084920306520E-01),
  (  0.5244380279191E-07, 0.2645560544125E+01, 0.5265099800692E+00),
  (  0.5143125704988E-07, 0.4834486101370E+01, 0.5328719641544E+00),
  (  0.5871866319373E-07, 0.7981472548900E+00, 0.7871412831580E-01),
  (  0.6300822573871E-07, 0.5979398788281E+01, 0.2608790314060E+02),
  (  0.6062154271548E-07, 0.4108655402756E+01, 0.1114304132498E+00),
  (  0.4361912339976E-07, 0.5322624319280E+01, 0.1375773836557E+01),
  //DATA ((S0(I,J,2),I=1,3),J= 81, 90)),
  (  0.4417005920067E-07, 0.6240817359284E+01, 0.2770348281756E+00),
  (  0.4686806749936E-07, 0.3214977301156E+01, 0.1143987543936E+00),
  (  0.3758892132305E-07, 0.5879809634765E+01, 0.1596186371003E+01),
  (  0.5151351332319E-07, 0.2893377688007E+00, 0.2228608264996E+00),
  (  0.4554683578572E-07, 0.5475427144122E+01, 0.1465949902372E+00),
  (  0.3442381385338E-07, 0.5992034796640E+01, 0.5070101000000E-01),
  (  0.2831093954933E-07, 0.5367350273914E+01, 0.3092784376656E+00),
  (  0.3756267090084E-07, 0.5758171285420E+01, 0.4903339079539E+00),
  (  0.2816374679892E-07, 0.1863718700923E+01, 0.2991266627620E+00),
  (  0.3419307025569E-07, 0.9524347534130E+00, 0.3518164938661E+00),
  //DATA ((S0(I,J,2),I=1,3),J= 91,100)),
  (  0.2904250494239E-07, 0.5304471615602E+01, 0.1099462426779E+00),
  (  0.2471734511206E-07, 0.1297069793530E+01, 0.6256703299991E+00),
  (  0.2539620831872E-07, 0.3281126083375E+01, 0.1256615170089E+02),
  (  0.2281017868007E-07, 0.1829122133165E+01, 0.6681224869435E+01),
  (  0.2275319473335E-07, 0.5797198160181E+01, 0.3932462625300E-02),
  (  0.2547755368442E-07, 0.4752697708330E+01, 0.1169588211447E+01),
  (  0.2285979669317E-07, 0.1223205292886E+01, 0.1045155034888E+01),
  (  0.1913386560994E-07, 0.1757532993389E+01, 0.1155361302111E+01),
  (  0.1809020525147E-07, 0.4246116108791E+01, 0.3368040641550E-01),
  (  0.1649213300201E-07, 0.1445162890627E+01, 0.4408250688924E+00),
  //DATA ((S0(I,J,2),I=1,3),J=101,110)),
  (  0.1834972793932E-07, 0.1126917567225E+01, 0.4452511715700E-02),
  (  0.1439550648138E-07, 0.6160756834764E+01, 0.9420622223326E+00),
  (  0.1487645457041E-07, 0.4358761931792E+01, 0.4123712502208E+00),
  (  0.1731729516660E-07, 0.6134456753344E+01, 0.2108507877249E+00),
  (  0.1717747163567E-07, 0.1898186084455E+01, 0.2157473718317E+00),
  (  0.1418190430374E-07, 0.4180286741266E+01, 0.6521991896920E-01),
  (  0.1404844134873E-07, 0.7654053565412E-01, 0.4258542984690E-01),
  (  0.1409842846538E-07, 0.4418612420312E+01, 0.2258291676434E+00),
  (  0.1090948346291E-07, 0.1260615686131E+01, 0.4226656969313E+00),
  (  0.1357577323612E-07, 0.3558248818690E+01, 0.7923417740620E-01),
  //DATA ((S0(I,J,2),I=1,3),J=111,120)),
  (  0.1018154061960E-07, 0.5676087241256E+01, 0.1456308687557E+00),
  (  0.1412073972109E-07, 0.8394392632422E+00, 0.1525316725248E+00),
  (  0.1030938326496E-07, 0.1653593274064E+01, 0.1795258541446E+01),
  (  0.1180081567104E-07, 0.1285802592036E+01, 0.7032915397480E-01),
  (  0.9708510575650E-08, 0.7631889488106E+00, 0.8434341241180E-01),
  (  0.9637689663447E-08, 0.4630642649176E+01, 0.1272681024002E+01),
  (  0.1068910429389E-07, 0.5294934032165E+01, 0.2123349582968E+00),
  (  0.1063716179336E-07, 0.2736266800832E+01, 0.2142632012598E+00),
  (  0.1234858713814E-07, 0.1302891146570E+01, 0.1847279083684E+00),
  (  0.8912631189738E-08, 0.3570415993621E+01, 0.2648454860559E+01),
  //DATA ((S0(I,J,2),I=1,3),J=121,130)),
  (  0.1036378285534E-07, 0.4236693440949E+01, 0.1370332435159E+00),
  (  0.9667798501561E-08, 0.2960768892398E+01, 0.4376440768498E+00),
  (  0.8108314201902E-08, 0.6987781646841E+00, 0.2880807454688E+00),
  (  0.7648364324628E-08, 0.2499017863863E+01, 0.2037373330570E+00),
  (  0.7286136828406E-08, 0.3787426951665E+01, 0.1129145838217E+00),
  (  0.9448237743913E-08, 0.2694354332983E+01, 0.5272426800584E+00),
  (  0.9374276106428E-08, 0.4787121277064E+01, 0.5321392641652E+00),
  (  0.7100226287462E-08, 0.3530238792101E+00, 0.6288513220417E+00),
  (  0.9253056659571E-08, 0.1399478925664E+01, 0.1606092486742E+00),
  (  0.6636432145504E-08, 0.3479575438447E+01, 0.1368660381889E+01),
  //DATA ((S0(I,J,2),I=1,3),J=131,140)),
  (  0.6469975312932E-08, 0.1383669964800E+01, 0.2008557621224E+01),
  (  0.7335849729765E-08, 0.1243698166898E+01, 0.9561746721300E-02),
  (  0.8743421205855E-08, 0.3776164289301E+01, 0.3801276407308E+00),
  (  0.5993635744494E-08, 0.5627122113596E+01, 0.2042657109477E+02),
  (  0.5981008479693E-08, 0.1674336636752E+01, 0.2111650433779E+01),
  (  0.6188535145838E-08, 0.5214925208672E+01, 0.4305306221819E+00),
  (  0.6596074017566E-08, 0.2907653268124E+01, 0.1063314406849E+01),
  (  0.6630815126226E-08, 0.2127643669658E+01, 0.8389694097774E+00),
  (  0.6156772830040E-08, 0.5082160803295E+01, 0.4234171675140E+00),
  (  0.6446960563014E-08, 0.1872100916905E+01, 0.5287268506303E+00),
  //DATA ((S0(I,J,2),I=1,3),J=141,150)),
  (  0.6429324424668E-08, 0.5610276103577E+01, 0.5306550935933E+00),
  (  0.6302232396465E-08, 0.1592152049607E+01, 0.1253008786510E-01),
  (  0.6399244436159E-08, 0.2746214421532E+01, 0.5217580628120E+02),
  (  0.5474965172558E-08, 0.2317666374383E+01, 0.2221856701002E+01),
  (  0.5339293190692E-08, 0.1084724961156E+01, 0.7466759693650E-01),
  (  0.5334733683389E-08, 0.3594106067745E+01, 0.7489573444450E-01),
  (  0.5392665782110E-08, 0.5630254365606E+01, 0.1055449481598E+01),
  (  0.6682075673789E-08, 0.1518480041732E+01, 0.2213766559277E+00),
  (  0.5079130495960E-08, 0.2739765115711E+01, 0.2132517061319E+00),
  (  0.5077759793261E-08, 0.5290711290094E+01, 0.2133464534247E+00),
  //DATA ((S0(I,J,2),I=1,3),J=151,160)),
  (  0.4832037368310E-08, 0.1404473217200E+01, 0.7160067364790E-01),
  (  0.6463279674802E-08, 0.6038381695210E+01, 0.2209183458640E-01),
  (  0.6240592771560E-08, 0.1290170653666E+01, 0.3306188016693E+00),
  (  0.4672013521493E-08, 0.3261895939677E+01, 0.7796265773310E-01),
  (  0.6500650750348E-08, 0.1154522312095E+01, 0.3884652414254E+00),
  (  0.6344161389053E-08, 0.6206111545062E+01, 0.7605151500000E-01),
  (  0.4682518370646E-08, 0.5409118796685E+01, 0.1073608853559E+01),
  (  0.5329460015591E-08, 0.1202985784864E+01, 0.7287631425543E+00),
  (  0.5701588675898E-08, 0.4098715257064E+01, 0.8731175355560E-01),
  (  0.6030690867211E-08, 0.4132033218460E+00, 0.9846002785331E+00),
  //DATA ((S0(I,J,2),I=1,3),J=161,170)),
  (  0.4336256312655E-08, 0.1211415991827E+01, 0.4297791515992E+00),
  (  0.4688498808975E-08, 0.3765479072409E+01, 0.2127790306879E+00),
  (  0.4675578609335E-08, 0.4265540037226E+01, 0.2138191288687E+00),
  (  0.4225578112158E-08, 0.5237566010676E+01, 0.3407705765729E+00),
  (  0.5139422230028E-08, 0.1507173079513E+01, 0.7233337363710E-01),
  (  0.4619995093571E-08, 0.9023957449848E-01, 0.8603097737811E+00),
  (  0.4494776255461E-08, 0.5414930552139E+00, 0.7381754420900E-01),
  (  0.4274026276788E-08, 0.4145735303659E+01, 0.7574578717200E-01),
  (  0.5018141789353E-08, 0.3344408829055E+01, 0.3180992042600E-02),
  (  0.4866163952181E-08, 0.3348534657607E+01, 0.7722995774390E-01),
  //DATA ((S0(I,J,2),I=1,3),J=171,180)),
  (  0.4111986020501E-08, 0.4198823597220E+00, 0.1451108196653E+00),
  (  0.3356142784950E-08, 0.5609144747180E+01, 0.1274714967946E+00),
  (  0.4070575554551E-08, 0.7028411059224E+00, 0.3503323232942E+00),
  (  0.3257451857278E-08, 0.5624697983086E+01, 0.5296435984654E+00),
  (  0.3256973703026E-08, 0.1857842076707E+01, 0.5297383457582E+00),
  (  0.3830771508640E-08, 0.4562887279931E+01, 0.9098186128426E+00),
  (  0.3725024005962E-08, 0.2358058692652E+00, 0.1084620721060E+00),
  (  0.3136763921756E-08, 0.2049731526845E+01, 0.2346394437820E+00),
  (  0.3795147256194E-08, 0.2432356296933E+00, 0.1862120789403E+00),
  (  0.2877342229911E-08, 0.5631101279387E+01, 0.1905464808669E+01),
  //DATA ((S0(I,J,2),I=1,3),J=181,190)),
  (  0.3076931798805E-08, 0.1117615737392E+01, 0.3628624111593E+00),
  (  0.2734765945273E-08, 0.5899826516955E+01, 0.2131850110243E+00),
  (  0.2733405296885E-08, 0.2130562964070E+01, 0.2134131485323E+00),
  (  0.2898552353410E-08, 0.3462387048225E+00, 0.5291709230214E+00),
  (  0.2893736103681E-08, 0.8534352781543E+00, 0.5302110212022E+00),
  (  0.3095717734137E-08, 0.2875061429041E+01, 0.2976424921901E+00),
  (  0.2636190425832E-08, 0.2242512846659E+01, 0.1485980103780E+01),
  (  0.3645512095537E-08, 0.1354016903958E+01, 0.6044726378023E+00),
  (  0.2808173547723E-08, 0.6705114365631E-01, 0.6225157782540E-01),
  (  0.2625012866888E-08, 0.4775705748482E+01, 0.5268983110410E-01),
  //DATA ((S0(I,J,2),I=1,3),J=191,200)),
  (  0.2572233995651E-08, 0.2638924216139E+01, 0.1258454114666E+01),
  (  0.2604238824792E-08, 0.4826358927373E+01, 0.2103781122809E+00),
  (  0.2596886385239E-08, 0.3200388483118E+01, 0.2162200472757E+00),
  (  0.3228057304264E-08, 0.5384848409563E+01, 0.2007689919132E+00),
  (  0.2481601798252E-08, 0.5173373487744E+01, 0.1062562936266E+01),
  (  0.2745977498864E-08, 0.6250966149853E+01, 0.5651155736444E+00),
  (  0.2669878833811E-08, 0.4906001352499E+01, 0.1400015846597E+00),
  (  0.3203986611711E-08, 0.5034333010005E+01, 0.7036329877322E+00),
  (  0.3354961227212E-08, 0.6108262423137E+01, 0.4549093064213E+00),
  (  0.2400407324558E-08, 0.2135399294955E+01, 0.2125476091956E+00),
  //DATA ((S0(I,J,2),I=1,3),J=201,210)),
  (  0.2379905859802E-08, 0.5893721933961E+01, 0.2140505503610E+00),
  (  0.2550844302187E-08, 0.3331940762063E+01, 0.1534957940063E+00),
  (  0.2268824211001E-08, 0.1843418461035E+01, 0.2235935264888E+00),
  (  0.2464700891204E-08, 0.3029548547230E+01, 0.2091065926078E+00),
  (  0.2436814726024E-08, 0.4994717970364E+01, 0.2174915669488E+00),
  (  0.2443623894745E-08, 0.2645102591375E+01, 0.1739420156204E+00),
  (  0.2318701783838E-08, 0.5700547397897E+01, 0.7530171478090E-01),
  (  0.2284448700256E-08, 0.5268898905872E+01, 0.7426161660010E-01),
  (  0.2468848123510E-08, 0.5276280575078E+01, 0.2526561439362E+00),
  (  0.2814052350303E-08, 0.6130168623475E+01, 0.5636314030725E+00),
  //DATA ((S0(I,J,2),I=1,3),J=211,NS0Y)),
  (  0.2243662755220E-08, 0.6631692457995E+00, 0.8886590321940E-01),
  (  0.2330795855941E-08, 0.2499435487702E+01, 0.1056200952181E+01),
  (  0.9757679038404E-09, 0.5796846023126E+01, 0.7826370942180E+02)),


  //  SSB-to-Sun, T^0, Z	),
  //DATA ((S0(I,J,3),I=1,3),J=  1, 10)),
  ((  0.1181255122986E-03, 0.4607918989164E+00, 0.2132990797783E+00),
  (  0.1127777651095E-03, 0.4169146331296E+00, 0.5296909721118E+00),
  (  0.4777754401806E-04, 0.4582657007130E+01, 0.3813291813120E-01),
  (  0.1129354285772E-04, 0.5758735142480E+01, 0.7478166569050E-01),
  ( -0.1149543637123E-04, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.3298730512306E-05, 0.5978801994625E+01, 0.4265981595566E+00),
  (  0.2733376706079E-05, 0.7665413691040E+00, 0.1059381944224E+01),
  (  0.9426389657270E-06, 0.3710201265838E+01, 0.2061856251104E+00),
  (  0.8187517749552E-06, 0.3390675605802E+00, 0.2204125344462E+00),
  (  0.4080447871819E-06, 0.4552296640088E+00, 0.5225775174439E+00),
  //DATA ((S0(I,J,3),I=1,3),J= 11, 20)),
  (  0.3169973017028E-06, 0.3445455899321E+01, 0.5368044267797E+00),
  (  0.2438098615549E-06, 0.5664675150648E+01, 0.3664874755930E-01),
  (  0.2601897517235E-06, 0.1931894095697E+01, 0.1495633313810E+00),
  (  0.2314558080079E-06, 0.3666319115574E+00, 0.3961708870310E-01),
  (  0.1962549548002E-06, 0.3167411699020E+01, 0.7626583626240E-01),
  (  0.2180518287925E-06, 0.1544420746580E+01, 0.7113454667900E-02),
  (  0.1451382442868E-06, 0.1583756740070E+01, 0.1102062672231E+00),
  (  0.1358439007389E-06, 0.5239941758280E+01, 0.6398972393349E+00),
  (  0.1050585898028E-06, 0.2266958352859E+01, 0.3163918923335E+00),
  (  0.1050029870186E-06, 0.2711495250354E+01, 0.4194847048887E+00),
  //DATA ((S0(I,J,3),I=1,3),J= 21, 30)),
  (  0.9934920679800E-07, 0.1116208151396E+01, 0.1589072916335E+01),
  (  0.1048395331560E-06, 0.3408619600206E+01, 0.1021328554739E+02),
  (  0.8370147196668E-07, 0.3810459401087E+01, 0.2535050500000E-01),
  (  0.7989856510998E-07, 0.3769910473647E+01, 0.7329749511860E-01),
  (  0.5441221655233E-07, 0.2416994903374E+01, 0.1030928125552E+00),
  (  0.4610812906784E-07, 0.5858503336994E+01, 0.4337116142245E+00),
  (  0.3923022803444E-07, 0.3354170010125E+00, 0.1484170571900E-02),
  (  0.2610725582128E-07, 0.5410600646324E+01, 0.6327837846670E+00),
  (  0.2455279767721E-07, 0.6120216681403E+01, 0.1162474756779E+01),
  (  0.2375530706525E-07, 0.6055443426143E+01, 0.1052268489556E+01),
  //DATA ((S0(I,J,3),I=1,3),J= 31, 40)),
  (  0.1782967577553E-07, 0.3146108708004E+01, 0.8460828644453E+00),
  (  0.1581687095238E-07, 0.6255496089819E+00, 0.3340612434717E+01),
  (  0.1594657672461E-07, 0.3782604300261E+01, 0.1066495398892E+01),
  (  0.1563448615040E-07, 0.1997775733196E+01, 0.2022531624851E+00),
  (  0.1463624258525E-07, 0.1736316792088E+00, 0.3516457698740E-01),
  (  0.1331585056673E-07, 0.4331941830747E+01, 0.9491756770005E+00),
  (  0.1130634557637E-07, 0.6152017751825E+01, 0.2968341143800E-02),
  (  0.1028949607145E-07, 0.2101792614637E+00, 0.2275259891141E+00),
  (  0.1024074971618E-07, 0.4071833211074E+01, 0.5070101000000E-01),
  (  0.8826956060303E-08, 0.4861633688145E+00, 0.2093666171530E+00),
  //DATA ((S0(I,J,3),I=1,3),J= 41, 50)),
  (  0.8572230171541E-08, 0.5268190724302E+01, 0.4110125927500E-01),
  (  0.7649332643544E-08, 0.5134543417106E+01, 0.2608790314060E+02),
  (  0.8581673291033E-08, 0.2920218146681E+01, 0.1480791608091E+00),
  (  0.8430589300938E-08, 0.3604576619108E+01, 0.2172315424036E+00),
  (  0.7776165501012E-08, 0.3772942249792E+01, 0.6373574839730E-01),
  (  0.8311070234408E-08, 0.6200412329888E+01, 0.3235053470014E+00),
  (  0.6927365212582E-08, 0.4543353113437E+01, 0.8531963191132E+00),
  (  0.6791574208598E-08, 0.2882188406238E+01, 0.7181332454670E-01),
  (  0.5593100811839E-08, 0.1776646892780E+01, 0.7429900518901E+00),
  (  0.4553381853021E-08, 0.3949617611240E+01, 0.7775000683430E-01),
  //DATA ((S0(I,J,3),I=1,3),J= 51, 60)),
  (  0.5758000450068E-08, 0.3859251775075E+01, 0.1990721704425E+00),
  (  0.4281283457133E-08, 0.1466294631206E+01, 0.2118763888447E+01),
  (  0.4206935661097E-08, 0.5421776011706E+01, 0.1104591729320E-01),
  (  0.4213751641837E-08, 0.3412048993322E+01, 0.2243449970715E+00),
  (  0.5310506239878E-08, 0.5421641370995E+00, 0.5154640627760E+00),
  (  0.3827450341320E-08, 0.8887314524995E+00, 0.1510475019529E+00),
  (  0.4292435241187E-08, 0.1405043757194E+01, 0.1422690933580E-01),
  (  0.3189780702289E-08, 0.1060049293445E+01, 0.1173197218910E+00),
  (  0.3226611928069E-08, 0.6270858897442E+01, 0.2164800718209E+00),
  (  0.2893897608830E-08, 0.5117563223301E+01, 0.6470106940028E+00),
  //DATA ((S0(I,J,3),I=1,3),J= 61,NS0Z)),
  (  0.3239852024578E-08, 0.4079092237983E+01, 0.2101180877357E+00),
  (  0.2956892222200E-08, 0.1594917021704E+01, 0.3092784376656E+00),
  (  0.2980177912437E-08, 0.5258787667564E+01, 0.4155522422634E+00),
  (  0.3163725690776E-08, 0.3854589225479E+01, 0.8582758298370E-01),
  (  0.2662262399118E-08, 0.3561326430187E+01, 0.5257585094865E+00),
  (  0.2766689135729E-08, 0.3180732086830E+00, 0.1385174140878E+00),
  (  0.2411600278464E-08, 0.3324798335058E+01, 0.5439178814476E+00),
  (  0.2483527695131E-08, 0.4169069291947E+00, 0.5336234347371E+00),
  (  0.7788777276590E-09, 0.1900569908215E+01, 0.5217580628120E+02),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    )));



  // *  SSB-to-Sun, T^1, X	),
  //DATA ((S1(I,J,1),I=1,3),J=  1, 10)),
  S1 : array[1..3,1..MS1,1..3] of double=
  ((( -0.1296310361520E-07, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.8975769009438E-08, 0.1128891609250E+01, 0.4265981595566E+00),
  (  0.7771113441307E-08, 0.2706039877077E+01, 0.2061856251104E+00),
  (  0.7538303866642E-08, 0.2191281289498E+01, 0.2204125344462E+00),
  (  0.6061384579336E-08, 0.3248167319958E+01, 0.1059381944224E+01),
  (  0.5726994235594E-08, 0.5569981398610E+01, 0.5225775174439E+00),
  (  0.5616492836424E-08, 0.5057386614909E+01, 0.5368044267797E+00),
  (  0.1010881584769E-08, 0.3473577116095E+01, 0.7113454667900E-02),
  (  0.7259606157626E-09, 0.3651858593665E+00, 0.6398972393349E+00),
  (  0.8755095026935E-09, 0.1662835408338E+01, 0.4194847048887E+00),
  //DATA ((S1(I,J,1),I=1,3),J= 11, 20)),
  (  0.5370491182812E-09, 0.1327673878077E+01, 0.4337116142245E+00),
  (  0.5743773887665E-09, 0.4250200846687E+01, 0.2132990797783E+00),
  (  0.4408103140300E-09, 0.3598752574277E+01, 0.1589072916335E+01),
  (  0.3101892374445E-09, 0.4887822983319E+01, 0.1052268489556E+01),
  (  0.3209453713578E-09, 0.9702272295114E+00, 0.5296909721118E+00),
  (  0.3017228286064E-09, 0.5484462275949E+01, 0.1066495398892E+01),
  (  0.3200700038601E-09, 0.2846613338643E+01, 0.1495633313810E+00),
  (  0.2137637279911E-09, 0.5692163292729E+00, 0.3163918923335E+00),
  (  0.1899686386727E-09, 0.2061077157189E+01, 0.2275259891141E+00),
  (  0.1401994545308E-09, 0.4177771136967E+01, 0.1102062672231E+00),
  //DATA ((S1(I,J,1),I=1,3),J= 21, 30)),
  (  0.1578057810499E-09, 0.5782460597335E+01, 0.7626583626240E-01),
  (  0.1237713253351E-09, 0.5705900866881E+01, 0.5154640627760E+00),
  (  0.1313076837395E-09, 0.5163438179576E+01, 0.3664874755930E-01),
  (  0.1184963304860E-09, 0.3054804427242E+01, 0.6327837846670E+00),
  (  0.1238130878565E-09, 0.2317292575962E+01, 0.3961708870310E-01),
  (  0.1015959527736E-09, 0.2194643645526E+01, 0.7329749511860E-01),
  (  0.9017954423714E-10, 0.2868603545435E+01, 0.1990721704425E+00),
  (  0.8668024955603E-10, 0.4923849675082E+01, 0.5439178814476E+00),
  (  0.7756083930103E-10, 0.3014334135200E+01, 0.9491756770005E+00),
  (  0.7536503401741E-10, 0.2704886279769E+01, 0.1030928125552E+00),
  //DATA ((S1(I,J,1),I=1,3),J= 31, 40)),
  (  0.5483308679332E-10, 0.6010983673799E+01, 0.8531963191132E+00),
  (  0.5184339620428E-10, 0.1952704573291E+01, 0.2093666171530E+00),
  (  0.5108658712030E-10, 0.2958575786649E+01, 0.2172315424036E+00),
  (  0.5019424524650E-10, 0.1736317621318E+01, 0.2164800718209E+00),
  (  0.4909312625978E-10, 0.3167216416257E+01, 0.2101180877357E+00),
  (  0.4456638901107E-10, 0.7697579923471E+00, 0.3235053470014E+00),
  (  0.4227030350925E-10, 0.3490910137928E+01, 0.6373574839730E-01),
  (  0.4095456040093E-10, 0.5178888984491E+00, 0.6470106940028E+00),
  (  0.4990537041422E-10, 0.3323887668974E+01, 0.1422690933580E-01),
  (  0.4321170010845E-10, 0.4288484987118E+01, 0.7358765972222E+00),
  //DATA ((S1(I,J,1),I=1,3),J= 41,NS1X)),
  (  0.3544072091802E-10, 0.6021051579251E+01, 0.5265099800692E+00),
  (  0.3480198638687E-10, 0.4600027054714E+01, 0.5328719641544E+00),
  (  0.3440287244435E-10, 0.4349525970742E+01, 0.8582758298370E-01),
  (  0.3330628322713E-10, 0.2347391505082E+01, 0.1104591729320E-01),
  (  0.2973060707184E-10, 0.4789409286400E+01, 0.5257585094865E+00),
  (  0.2932606766089E-10, 0.5831693799927E+01, 0.5336234347371E+00),
  (  0.2876972310953E-10, 0.2692638514771E+01, 0.1173197218910E+00),
  (  0.2827488278556E-10, 0.2056052487960E+01, 0.2022531624851E+00),
  (  0.2515028239756E-10, 0.7411863262449E+00, 0.9597935788730E-01),
  (  0.2853033744415E-10, 0.3948481024894E+01, 0.2118763888447E+01)),

  //*  SSB-to-Sun, T^1, Y	),
  //DATA ((S1(I,J,2),I=1,3),J=  1, 10)),
  ((  0.8989047573576E-08, 0.5840593672122E+01, 0.4265981595566E+00),
  (  0.7815938401048E-08, 0.1129664707133E+01, 0.2061856251104E+00),
  (  0.7550926713280E-08, 0.6196589104845E+00, 0.2204125344462E+00),
  (  0.6056556925895E-08, 0.1677494667846E+01, 0.1059381944224E+01),
  (  0.5734142698204E-08, 0.4000920852962E+01, 0.5225775174439E+00),
  (  0.5614341822459E-08, 0.3486722577328E+01, 0.5368044267797E+00),
  (  0.1028678147656E-08, 0.1877141024787E+01, 0.7113454667900E-02),
  (  0.7270792075266E-09, 0.5077167301739E+01, 0.6398972393349E+00),
  (  0.8734141726040E-09, 0.9069550282609E-01, 0.4194847048887E+00),
  (  0.5377371402113E-09, 0.6039381844671E+01, 0.4337116142245E+00),
  //DATA ((S1(I,J,2),I=1,3),J= 11, 20)),
  (  0.4729719431571E-09, 0.2153086311760E+01, 0.2132990797783E+00),
  (  0.4458052820973E-09, 0.5059830025565E+01, 0.5296909721118E+00),
  (  0.4406855467908E-09, 0.2027971692630E+01, 0.1589072916335E+01),
  (  0.3101659310977E-09, 0.3317677981860E+01, 0.1052268489556E+01),
  (  0.3016749232545E-09, 0.3913703482532E+01, 0.1066495398892E+01),
  (  0.3198541352656E-09, 0.1275513098525E+01, 0.1495633313810E+00),
  (  0.2142065389871E-09, 0.5301351614597E+01, 0.3163918923335E+00),
  (  0.1902615247592E-09, 0.4894943352736E+00, 0.2275259891141E+00),
  (  0.1613410990871E-09, 0.2449891130437E+01, 0.1102062672231E+00),
  (  0.1576992165097E-09, 0.4211421447633E+01, 0.7626583626240E-01),
  //DATA ((S1(I,J,2),I=1,3),J= 21, 30)),
  (  0.1241637259894E-09, 0.4140803368133E+01, 0.5154640627760E+00),
  (  0.1313974830355E-09, 0.3591920305503E+01, 0.3664874755930E-01),
  (  0.1181697118258E-09, 0.1506314382788E+01, 0.6327837846670E+00),
  (  0.1238239742779E-09, 0.7461405378404E+00, 0.3961708870310E-01),
  (  0.1010107068241E-09, 0.6271010795475E+00, 0.7329749511860E-01),
  (  0.9226316616509E-10, 0.1259158839583E+01, 0.1990721704425E+00),
  (  0.8664946419555E-10, 0.3353244696934E+01, 0.5439178814476E+00),
  (  0.7757230468978E-10, 0.1447677295196E+01, 0.9491756770005E+00),
  (  0.7693168628139E-10, 0.1120509896721E+01, 0.1030928125552E+00),
  (  0.5487897454612E-10, 0.4439380426795E+01, 0.8531963191132E+00),
  //DATA ((S1(I,J,2),I=1,3),J= 31, 40)),
  (  0.5196118677218E-10, 0.3788856619137E+00, 0.2093666171530E+00),
  (  0.5110853339935E-10, 0.1386879372016E+01, 0.2172315424036E+00),
  (  0.5027804534813E-10, 0.1647881805466E+00, 0.2164800718209E+00),
  (  0.4922485922674E-10, 0.1594315079862E+01, 0.2101180877357E+00),
  (  0.6155599524400E-10, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.4447147832161E-10, 0.5480720918976E+01, 0.3235053470014E+00),
  (  0.4144691276422E-10, 0.1931371033660E+01, 0.6373574839730E-01),
  (  0.4099950625452E-10, 0.5229611294335E+01, 0.6470106940028E+00),
  (  0.5060541682953E-10, 0.1731112486298E+01, 0.1422690933580E-01),
  (  0.4293615946300E-10, 0.2714571038925E+01, 0.7358765972222E+00),
  //DATA ((S1(I,J,2),I=1,3),J= 41,NS1Y)),
  (  0.3545659845763E-10, 0.4451041444634E+01, 0.5265099800692E+00),
  (  0.3479112041196E-10, 0.3029385448081E+01, 0.5328719641544E+00),
  (  0.3438516493570E-10, 0.2778507143731E+01, 0.8582758298370E-01),
  (  0.3297341285033E-10, 0.7898709807584E+00, 0.1104591729320E-01),
  (  0.2972585818015E-10, 0.3218785316973E+01, 0.5257585094865E+00),
  (  0.2931707295017E-10, 0.4260731012098E+01, 0.5336234347371E+00),
  (  0.2897198149403E-10, 0.1120753978101E+01, 0.1173197218910E+00),
  (  0.2832293240878E-10, 0.4597682717827E+00, 0.2022531624851E+00),
  (  0.2864348326612E-10, 0.2169939928448E+01, 0.9597935788730E-01),
  (  0.2852714675471E-10, 0.2377659870578E+01, 0.2118763888447E+01)),

  //  SSB-to-Sun, T^1, Z	),
  //DATA ((S1(I,J,3),I=1,3),J=  1, 10)),
  ((  0.5444220475678E-08, 0.1803825509310E+01, 0.2132990797783E+00),
  (  0.3883412695596E-08, 0.4668616389392E+01, 0.5296909721118E+00),
  (  0.1334341434551E-08, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.3730001266883E-09, 0.5401405918943E+01, 0.2061856251104E+00),
  (  0.2894929197956E-09, 0.4932415609852E+01, 0.2204125344462E+00),
  (  0.2857950357701E-09, 0.3154625362131E+01, 0.7478166569050E-01),
  (  0.2499226432292E-09, 0.3657486128988E+01, 0.4265981595566E+00),
  (  0.1937705443593E-09, 0.5740434679002E+01, 0.1059381944224E+01),
  (  0.1374894396320E-09, 0.1712857366891E+01, 0.5368044267797E+00),
  (  0.1217248678408E-09, 0.2312090870932E+01, 0.5225775174439E+00),
  //DATA ((S1(I,J,3),I=1,3),J= 11,NS1Z)),
  (  0.7961052740870E-10, 0.5283368554163E+01, 0.3813291813120E-01),
  (  0.4979225949689E-10, 0.4298290471860E+01, 0.4194847048887E+00),
  (  0.4388552286597E-10, 0.6145515047406E+01, 0.7113454667900E-02),
  (  0.2586835212560E-10, 0.3019448001809E+01, 0.6398972393349E+00),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    )));



  //*  SSB-to-Sun, T^2, X	),
  //DATA ((S2(I,J,1),I=1,3),J=  1,NS2X)),
  S2 : array[1..3,1..MS2,1..3] of double=
  (((  0.1603551636587E-11, 0.4404109410481E+01, 0.2061856251104E+00),
  (  0.1556935889384E-11, 0.4818040873603E+00, 0.2204125344462E+00),
  (  0.1182594414915E-11, 0.9935762734472E+00, 0.5225775174439E+00),
  (  0.1158794583180E-11, 0.3353180966450E+01, 0.5368044267797E+00),
  (  0.9597358943932E-12, 0.5567045358298E+01, 0.2132990797783E+00),
  (  0.6511516579605E-12, 0.5630872420788E+01, 0.4265981595566E+00),
  (  0.7419792747688E-12, 0.2156188581957E+01, 0.5296909721118E+00),
  (  0.3951972655848E-12, 0.1981022541805E+01, 0.1059381944224E+01),
  (  0.4478223877045E-12, 0.0000000000000E+00, 0.0000000000000E+00)),

  // *  SSB-to-Sun, T^2, Y	),
  //DATA ((S2(I,J,2),I=1,3),J=  1,NS2Y)),
  ((  0.1609114495091E-11, 0.2831096993481E+01, 0.2061856251104E+00),
  (  0.1560330784946E-11, 0.5193058213906E+01, 0.2204125344462E+00),
  (  0.1183535479202E-11, 0.5707003443890E+01, 0.5225775174439E+00),
  (  0.1158183066182E-11, 0.1782400404928E+01, 0.5368044267797E+00),
  (  0.1032868027407E-11, 0.4036925452011E+01, 0.2132990797783E+00),
  (  0.6540142847741E-12, 0.4058241056717E+01, 0.4265981595566E+00),
  (  0.7305236491596E-12, 0.6175401942957E+00, 0.5296909721118E+00),
  ( -0.5580725052968E-12, 0.0000000000000E+00, 0.0000000000000E+00),
  (  0.3946122651015E-12, 0.4108265279171E+00, 0.1059381944224E+01)),


  //*  SSB-to-Sun, T^2, Z	),
  //DATA ((S2(I,J,3),I=1,3),J=  1,NS2Z)),
  ((  0.3749920358054E-12, 0.3230285558668E+01, 0.2132990797783E+00),
  (  0.2735037220939E-12, 0.6154322683046E+01, 0.5296909721118E+00),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    ),
  (                0    ,               0    ,               0    )));   }

  //*  Days per Julian year;
  DJY = 365.25 ;
  //*  Reference epoch (J2000), MJD;
  DJM0 = 51544.5;

var
  T, T2, XYZ, XYZD, A, B, C, CT, P, CP : double;
  HP, HV, BP, BV : array[1..3] of double;
  X, Y, Z : double;
  J, K: integer;
  {*;
  *  Matrix elements for orienting the analytical model to DE405/ICRF.
  *;
  *  The corresponding Euler angles are:;
  *;
  *                        d  '  ";
  *    1st rotation    -  23 26 21.4091 about the x-axis  (obliquity);
  *    2nd rotation    +         0.0475 about the z-axis  (RA offset);
  *;
  *  These were obtained empiriy, by comparisons with DE405 over;
  *  1900-2100.
  *; }

const
  AM12= +0.000000211284;
  AM13= -0.000000091603;
  AM21= -0.000000230286;
  AM22= +0.917482137087;
  AM23= -0.397776982902;
  AM32= +0.397776982902;
  AM33= +0.917482137087;

//  * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;

begin

  //*  Time since reference epoch, years.
  T := ( DATE - DJM0 ) / DJY;
  T2 := T*T;

  for  K := 1 to 3  do {loop for X, Y,Z}
  begin
    //     Initialize position and velocity component.
    XYZ := 0;
    XYZD := 0;
    {*     ------------------------------------------------;
    *     Obtain component of Sun to Earth ecliptic vector;
    *     ------------------------------------------------;
    *     Sun to Earth, T^0 terms.}
    for  J := 1 to NE0[K]  do
    begin
      A := E0[K,J,1];//for Pascal swap the three terms. Was in Fortran A := E0[1,J,K];
      B := E0[K,J,2];//for Pascal swap the three terms, Was in Fortran A := E0[2,J,K];
      C := E0[K,J,3];//for Pascal swap the three terms. Was in Fortran A := E0[3,J,K];
      P := B + C*T;
      XYZ  := XYZ  + A*COS(P);
      XYZD := XYZD - A*C*SIN(P);
    end;
    //     Sun to Earth, T^1 terms.
    for  J := 1 to NE1[K]  do
    begin
      A := E1[K,J,1];
      B := E1[K,J,2];
      C := E1[K,J,3];
      CT := C*T;
      P := B + CT;
      CP := COS(P);
      XYZ  := XYZ  + A*T*CP;
      XYZD := XYZD + A*(CP-CT*SIN(P));
      end;
      //     Sun to Earth, T^2 terms.
      for  J := 1 to NE2[K]  do
      begin
        A := E2[K,J,1];
        B := E2[K,J,2];
        C := E2[K,J,3];

        CT := C*T;
        P := B + CT;
        CP := COS(P);
        XYZ  := XYZ  + A*T2*CP;
        XYZD := XYZD + A*T*(2*CP-CT*SIN(P));
      end;
      //     Heliocentric Earth position and velocity component.
      HP[K] := XYZ;
      HV[K] := XYZD / DJY;



    {*     ------------------------------------------------;
    *     Obtain component of SSB to Earth ecliptic vector;
    *     ------------------------------------------------;
    *     SSB to Sun, T^0 terms.}
{   for  J := 1 to NS0[K]  do
    begin
      A := S0[K,J,1];
      B := S0[K,J,2];
      C := S0[K,J,3];

      P := B + C*T;
      XYZ  := XYZ  + A*COS(P);
      XYZD := XYZD - A*C*SIN(P);
    end;
    //     SSB to Sun, T^1 terms.
    for  J := 1 to NS1[K]  do
    begin
      A := S1[K,J,1];
      B := S1[K,J,2];
      C := S1[K,J,3];

      CT := C*T;
      P := B + CT;
      CP := COS(P);
      XYZ  := XYZ  + A*T*CP;
      XYZD := XYZD + A*(CP-CT*SIN(P));
    end;
    //     SSB to Sun, T^2 terms.
    for  J := 1 to NS2[K]  do
    begin
      A := S2[K,J,1];
      B := S2[K,J,2];
      C := S2[K,J,3];

      CT := C*T;
      P := B + CT;
      CP := COS(P);
      XYZ  := XYZ  + A*T2*CP;
      XYZD := XYZD + A*T*(2*CP-CT*SIN(P));
    end;
    //     Barycentric Earth position and velocity component.
    BP[K] := XYZ;
    BV[K] := XYZD / DJY;}
    //     Next Cartesian component.
  end; {loop for X, Y,Z}


  //  Rotate from ecliptic to ICRS coordinates and  the results.
  {heliocentric}
  X := HP[1];
  Y := HP[2];
  Z := HP[3];
  PH[1] :=      X + AM12*Y + AM13*Z;
  PH[2] := AM21*X + AM22*Y + AM23*Z;
  PH[3] :=          AM32*Y + AM33*Z;
  X := HV[1];
  Y := HV[2];
  Z := HV[3];
  VH[1] :=      X + AM12*Y + AM13*Z;
  VH[2] := AM21*X + AM22*Y + AM23*Z;
  VH[3] :=          AM32*Y + AM33*Z;

  // Barycentric Earth position
{ X := BP[1];
  Y := BP[2];
  Z := BP[3];
  PB[1] :=      X + AM12*Y + AM13*Z;
  PB[2] := AM21*X + AM22*Y + AM23*Z;
  PB[3] :=          AM32*Y + AM33*Z;
  X := BV[1];
  Y := BV[2];
  Z := BV[3];
  VB[1] :=      X + AM12*Y + AM13*Z;
  VB[2] := AM21*X + AM22*Y + AM23*Z;
  VB[3] :=          AM32*Y + AM33*Z;}
  end;

end.

