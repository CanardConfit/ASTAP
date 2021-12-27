unit unit_asteroid;
{Copyright (C) 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
   Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
   LCLIntf, ColorBox, Buttons,{for for getkeystate, selectobject, openURL}
   math, astap_main, unit_stack, unit_ephemerides;

type

  { Tform_asteroids1 }

  Tform_asteroids1 = class(TForm)
    add_annotations1: TCheckBox;
    annotate_asteroids1: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    cancel_button1: TButton;
    ColorBox1: TColorBox;
    date_label1: TLabel;
    date_obs1: TEdit;
    download_mpcorb1: TLabel;
    file_to_add1: TButton;
    file_to_add2: TButton;
    Group_Box1: TGroupBox;
    Group_Box2: TGroupBox;
    help_asteroid_annotation1: TLabel;
    label_start_mid1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    latitude1: TEdit;
    longitude1: TEdit;
    max_magn_asteroids1: TEdit;
    annotation_size1: TEdit;
    max_nr_asteroids1: TEdit;
    mpcorb_filedate1: TLabel;
    mpcorb_filedate2: TLabel;
    mpcorb_path2: TLabel;
    mpcorb_path1: TLabel;
    OpenDialog1: TOpenDialog;
    showfullnames1: TCheckBox;
    add_subtitle1: TCheckBox;
    font_follows_diameter1: TCheckBox;
    showmagnitude1: TCheckBox;
    max_magn_asteroids2: TUpDown;
    annotation_size2: TUpDown;
    up_to_magn1: TLabel;
    up_to_number1: TLabel;
    procedure annotate_asteroids1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure cancel_button1Click(Sender: TObject);
    procedure download_mpcorb1Click(Sender: TObject);
    procedure file_to_add1Click(Sender: TObject);
    procedure file_to_add2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure Group_Box1Click(Sender: TObject);
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
   cometels_path : string='CometEls.txt';
   font_follows_diameter:boolean=false;
   showfullnames: boolean=true;
   showmagnitude: boolean=false;
   add_annotations: boolean=false;{annotation to the fits header}
   add_date: boolean=true;

procedure plot_mpcorb(maxcount : integer;maxmag:double;add_annot :boolean) ;{read MPCORB.dat}{han.k}

implementation

uses unit_hjd; {for polar2}

{$R *.lfm}

var
   X_pln,Y_pln,Z_pln : double; {of planet}

   wtime2actual: double;
   midpoint    : boolean;
   site_lat_radians,site_long_radians  : double;

const
   sun200_calculated : boolean=false; {sun200 calculated for comets}

VAR TEQX    : double;
    ph_earth, vh_earth : r3_array;{helio centric earth vector}
    ph_pln             : r3_array;{helio centric planet vector}

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
  dec_text_to_radians(longitude1.Text,site_long_radians,errordecode);
  if errordecode then longitude1.color:=clred else longitude1.color:=clwindow;
end;


procedure parallax_xyz(wtime,latitude : double;var x,y,z: double);  {X,Y,Z in AU, parallax can be 8.8 arcsec  per au distance. See new meeus page 78}
const
  AE=149597870.700; {ae has been fixed to the value 149597870.700 km as adopted by the International Astronomical Union in 2012.  Note average earth distance is 149597870.662 * 1.000001018 see meeus new 379}
var
  sin_latitude_corrected,
  cos_latitude_corrected,
  height_above_sea,
  flatteningearth,
  x_observ,y_observ,z_observ,u :double;
begin
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


procedure minor_planet(sun_earth_vector:boolean;julian:double;year,month:integer;day,a_e, a_or_q,a_i,a_ohm,a_w,a_M :double;var RA3,DEC3,DELTA,sun_delta:double);
{ Comet hale bopp
  YEAR:=1997;
  MONTH:=03;
  D:=29.74151986;
  Q:= 0.901891;   Perihelion distance q in AU, AORQ
  ECC:= 0.994952; Eccentricity e
  INC2:= 89.0445; Inclination i, OrbInc
  LAN:= 283.2449; Longitude of the ascending node, Anode
  AOP:= 130.5115; Argument of perihelion, Perih}
const
  TAU=499.004782;
var
  JSTAT,I : integer;
  x_pln,y_pln,z_pln,TL,R, epoch,mjd : double;
  U : U_array;
  pv : r6_array;
begin
  if sun_earth_vector=false then
  begin
    sla_EPV (julian-2400000.5{mjd}, ph_earth,vh_earth);{helocentric position earth including light time correction, high accuracy for years 1900 to 2100}
    sun200_calculated:=true;
  end;
  epoch:= julian_calc(year,month,day,0,0,0)-2400000.5; {MJD}
  mjd:=julian-2400000.5;

  if a_M<1E98 then {asteroid. Use a_M, mean anomoly as an indicator for minor planet or comet, The mean anomoly of a comet is in princple zero and at perihelion}
  orbit (mjd, 2 {minor planet}, epoch, a_i*pi/180, a_ohm*pi/180,a_w*pi/180, a_or_q,a_e,a_M*pi/180, 0, PV, JSTAT) //Determine the position and velocity.
  else
  orbit (mjd, 3 {comet}       , epoch, a_i*pi/180, a_ohm*pi/180,a_w*pi/180,a_or_q, a_e,0           , 0, PV, JSTAT);//Determine the position and velocity.

  if (Jstat <> 0) then
  begin
    exit;
  end;
  {  Option JFORM := 2, suitable for minor planets:;
  *;
  *       EPOCH  := epoch of elements (TT MJD);
  *       ORBINC := inclination i (radians);
  *       ANODE  := longitude of the ascend;
  *       PERIH  := argument of perihelion, little omega (radians);
  *       AORQ   := mean distance, a (AU);
  *       E      := eccentricity, e (range 0 to <1);
  *       AORL   := mean anomaly M (radians);
  *;
  *     Option JFORM := 3, suitable for comets:;
  *;
  *       EPOCH  := epoch of elements and perihelion (TT MJD);
  *       ORBINC := inclination i (radians);
  *       ANODE  := longitude of the ascend;
  *       PERIH  := argument of perihelion, little omega (radians);
  *       AORQ   := perihelion distance, q (AU);
  *       E      := eccentricity, e (range 0 to 10);}

  R:=sqrt(sqr(pv[1]-ph_earth[1])+sqr(pv[2]-ph_earth[2])+sqr(pv[3]-ph_earth[3]));{geometric distance minor planet and Earth in AU}
  TL:=TAU*R;//  Light time (sec);
  x_pln:=pv[1]-ph_earth[1]-TL*(pv[4]);{ Correct position for planetary aberration. Use the speed values to correct for light traveling time. The PV_earth is already corrected for aberration!!}
  y_pln:=pv[2]-ph_earth[2]-TL*(pv[5]);
  z_pln:=pv[3]-ph_earth[3]-TL*(pv[6]);

  PARALLAX_XYZ(wtime2actual,site_lat_radians,X_pln,Y_pln,Z_pln);{correct parallax  X, Y, Z in AE. This should be done in Jnow so there is a small error in J2000 }
  polar2(x_pln,y_pln,z_pln,delta,dec3,ra3) ;

  ph_pln[1]:=pv[1];{store for illumination calculation}
  ph_pln[2]:=pv[2];
  ph_pln[3]:=pv[3];
  sun_delta:=sqrt(sqr(pv[1])+sqr(pv[2])+sqr(pv[3]));
end;


procedure illum2( x,y,z, xe,ye,Ze: double; out R_SP,R_EP,elong,phi,phase: double);
var
  xp,yp,zp, re, c_phi : double;
begin
  xp:=x-xe; yp:=y-ye; zp:=z-ze; //minor planet geocentric position

  {Compute the distances in the Sun-Earth-planet triangle}
  r_sp:= sqrt(sqr(x)+sqr(y)+sqr(z));    {Distance Sun and minor planet}
  re  := sqrt(sqr(xe)+sqr(ye)+sqr(ze)); {Distance Sun and Earth}
  r_ep:= sqrt(sqr(xp)+sqr(yp)+sqr(zp)); {Distance Earth and minor planet}

  elong:=(180/pi)*arccos( ( r_ep*r_ep + re*re - r_sp*r_sp ) / ( 2.0*r_ep*re ) );{calculation elongation, phase angle and phase}
  c_phi:=( sqr(r_ep) + sqr(r_sp) - sqr(re) ) / (2.0*r_ep*r_sp);
  phi  :=(180/pi)*arccos( c_phi );{phase angle in degrees}
  phase:= 100*0.5*(1.0+c_phi); {0..100}
end;


function illum_planet : double; { Get phase angle comet. Only valid is comet routine is called first.}
var
  r_sp,r_ep,elong,phi1,phase1 :double;
begin
  illum2(ph_pln[1],ph_pln[2],ph_pln[3],ph_earth[1],ph_earth[2],ph_earth[3],r_sp,r_ep,elong,phi1, phase1 );{ heliocentric positions minor planet and earth}
  result:=phi1*pi/180;
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


function fnmodulo(x,range: double):double;
begin
  {range should be 2*pi or 24 hours or 0 .. 360}
  result:=range*frac(x/range);
  if result<0 then result:=result+range;   {do not like negative numbers}
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


procedure convert_MPCORB_line(txt : string; var desn,name: string; var yy,mm,dd,a_e,a_a,a_i,a_ohm,a_w,a_M,h,g: double);{read asteroid, han.k}
var
  code2           : integer;
  degrees_to_perihelion,c_epochdelta           : double;
  date_regel                                             : STRING[5];
  centuryA,monthA,dayA                                   :string[2];
const
   Gauss_gravitational_constant: double=0.01720209895*180/pi;
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
    dd:=strtofloat(dayA);  {epoch day}

    a_M:=strtofloat(copy(txt,27,35-27+1));   {27 -  35  f9.5   Mean anomaly at the epoch, in degrees}
    a_w:=strtofloat(copy(txt,38,46-38+1));   {38 -  46  f9.5   Argument of perihelion, J2000.0 (degrees)}
    a_ohm:=strtofloat(copy(txt,49,57-49+1)); {49 -  57  f9.5   Longitude of the ascending node, J2000.0  (degrees)}
    a_i:=strtofloat(copy(txt,60,68-60+1));   {60 -  68  f9.5   Inclination to the ecliptic, J2000.0 (degrees)}

    a_e:=strtofloat(copy(txt,71,79-71+1));   {71 -  79  f9.7   Orbital eccentricity}

    a_a:=strtofloat(copy(txt,93,103-93+1));  {93 - 103  f11.7  Semimajor axis (AU)}
  end;
end;


procedure convert_comet_line(txt : string; var desn,name: string; var yy,mm,dd, ecc,q,inc2,lan,aop,M_anom,H,k: double); {han.k}
var
  error1          : integer;
  g               : double;
begin
  desn:='';{assume failure}
  //date_regel:=copy(txt,21,25-21+1); {21 -  25  a5     Epoch (in packed form, .0 TT), see http://www.minorplanetcenter.net/iau/info/MPOrbitFormat.html}
  yy:=strtofloat(copy(txt,15,4));{epoch year}
  if ((yy>1900) and (yy<2200)) then {do only data}
  begin
    name:=copy(txt,103,39);
    desn:=copy(txt,159,10);

    H:=strtofloat(copy(txt,91,5));   {   Absolute magnitude, H}

    val(copy(txt,97,4),g,error1);
    k:=g*2.5; { Comet activity}

    yy:=strtofloat(copy(txt,15,4));{epoch year}
    mm:=strtofloat(copy(txt,20,2));{epoch month}
    dd:=strtofloat(copy(txt,23,7));{epoch day}

    q:=strtofloat(copy(txt,31,9)); {q}
    ecc:=strtofloat(copy(txt,41,9));
    aop:=strtofloat(copy(txt,51,9));
    lan:=strtofloat(copy(txt,61,9));
    inc2:=strtofloat(copy(txt,71,9));
    M_anom:=1E99;{Should be zero since comet values are give at perihelion. But label this as a a comet by abnormal value 1E99}

    {Hale Bopp
      Q:= 0.91468400000000005; Perihelion distance q in AU;
      ECC:= 0.99492999999999998; Eccentricity e
      INC2:= 88.987200000000001; Inclination i
      LAN:= 283.36720000000003;  Longitude of the ascending node
      AOP:= 130.62989999999999;  Argument of perihelion}
  end;
end;


procedure plot_mpcorb(maxcount : integer;maxmag:double;add_annot :boolean) ;{read MPCORB.dat}{han.k}
const
  a_g : double =0.15;{asteroid_slope_factor}
  siderealtime2000=(280.46061837)*pi/180;{[radians], sidereal time at 2000 jan 1.5 UT (12 hours) =Jd 2451545 at meridian greenwich, see new meeus 11.4}
  earth_angular_velocity = pi*2*1.00273790935; {about(365.25+1)/365.25) or better (365.2421874+1)/365.2421874 velocity dailly. See new Meeus page 83}
var
  txtf : textfile;
  count,fontsize           : integer;
  yy,mm,dd,h,a_or_q, DELTA,sun_delta,ra2,dec2,mag,phase,delta_t,
  SIN_dec_ref,COS_dec_ref,c_k,fov,cos_telescope_dec,u0,v0 ,a_e,a_a,a_i,a_ohm,a_w,a_M   : double;
  desn,name,s, thetext1,thetext2,fontsize_str:string;
  flip_horizontal, flip_vertical,form_existing, errordecode,sip : boolean;

      procedure plot_asteroid(sizebox :integer);
      var
        dra,ddec, delta_ra,det,SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,hh : double;
        x,y,x2,y2                                                                               : integer;
      begin

       {5. Conversion (RA,DEC) -> (x,y)}
        sincos(dec2,SIN_dec_new,COS_dec_new);{sincos is faster then separate sin and cos functions}
        delta_ra:=ra2-head.ra0;
        sincos(delta_ra,SIN_delta_ra,COS_delta_ra);
        HH := SIN_dec_new*sin_dec_ref + COS_dec_new*COS_dec_ref*COS_delta_ra;
        dRA := (COS_dec_new*SIN_delta_ra / HH)*180/pi;
        dDEC:= ((SIN_dec_new*COS_dec_ref - COS_dec_new*SIN_dec_ref*COS_delta_ra ) / HH)*180/pi;
        det:=head.cd2_2*head.cd1_1 - head.cd1_2*head.cd2_1;

        u0:= - (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
        v0:= + (head.cd1_1*dDEC - head.cd2_1*dRA) / det;

        if sip then {apply SIP correction}
        begin
           x:=round(head.crpix1 + u0 + ap_0_0 + ap_0_1*v0+ ap_0_2*v0*v0+ ap_0_3*v0*v0*v0 +ap_1_0*u0 + ap_1_1*u0*v0+  ap_1_2*u0*v0*v0+ ap_2_0*u0*u0 + ap_2_1*u0*u0*v0+  ap_3_0*u0*u0*u0); {3th order SIP correction, fits count from 1, image from zero therefore subtract 1}
           y:=round(head.crpix2 + v0 + bp_0_0 + bp_0_1*v0+ bp_0_2*v0*v0+ bp_0_3*v0*v0*v0 +bp_1_0*u0 + bp_1_1*u0*v0+  bp_1_2*u0*v0*v0+ bp_2_0*u0*u0 + bp_2_1*u0*u0*v0+  bp_3_0*u0*u0*u0); {3th order SIP correction}
        end
        else
        begin
          x:=round(head.crpix1 + u0); {in FITS range 1..width}
          y:=round(head.crpix2 + v0);
        end;

        if ((x>-50) and (x<=head.width+50) and (y>-50) and (y<=head.height+50)) then {within image1 with some overlap}
        begin
          {annotate}
           if flip_horizontal then x2:=(head.width)-x else x2:=x;
           if flip_vertical   then y2:=y         else y2:=(head.height)-y;

           if showfullnames then thetext1:=trim(name) else thetext1:=trim(desn)+'('+floattostrF(mag,ffgeneral,3,1)+')';
           if showmagnitude then thetext2:='{'+inttostr(round(mag*10))+'}' {add magnitude in next field} else thetext2:='';

           if add_annot then
           begin                         //floattostrF2(median_bottom_right,0,2)
              add_text ('ANNOTATE=',#39+inttostr(x+1-sizebox)+';'+inttostr(y+1-sizebox)+';'+inttostr(x+1+sizebox)+';'+inttostr(y+1+sizebox)+';-'+fontsize_str {-1 or larger}+';'{boldness}+thetext1+';'+thetext2+';'+#39); {store in FITS coordinates 1..}
              annotated:=true;{header contains annotations}
           end;
           plot_the_annotation(x+1-sizebox {x1},y+1-sizebox {y1},x+1+sizebox{x2},y+1+sizebox{y2},-max(1,round(fontsize*10/12)/10){typ},thetext1,thetext2); {plot annotation}
        end;
      end;
      procedure read_and_plot(asteroid: boolean; path :string);
      begin
        assignfile(txtf,path);
        try
          Reset(txtf);
          while ((not EOF(txtf)) and (count<maxcount) and (esc_pressed=false)) do   {loop}
          begin
            ReadLn(txtf, s);
           if length(s)>10 then
           begin

             if asteroid then  convert_MPCORB_line(s, {var} desn,name, yy,mm,dd,a_e,a_or_q {a},a_i,a_ohm,a_w,a_M,H,a_g){read MPC asteroid}
                         else  convert_comet_line (s, {var} desn,name, yy,mm,dd,a_e ,a_or_q {q},a_i,a_ohm,a_w,a_M,H,c_k); {read MPC comet}
             if ((desn<>'') and (a_or_q<>0)) then {data line}
             begin
               try
                 inc(count);

                 {comet is indicated by a_M:=1E99, Mean anomoly, an abnormal value}
                 minor_planet(sun200_calculated,jd_mid+delta_t{delta_t in days},round(yy),round(mm),dd,a_e,a_or_q,a_i,a_ohm,a_w,a_M,{var} ra2,dec2,delta,sun_delta);

                 if sqr( (ra2-head.ra0)*cos_telescope_dec)  + sqr(dec2-head.dec0)< sqr(fov) then {within the image FOV}
                 begin
                   if asteroid then
                   begin
                     mag:=h+ ln(delta*sun_delta)*5/ln(10);  {log(x) = ln(x)/ln(10)}

                     phase:=illum_planet; { Get phase comet. Only valid if comet routine is called first.}
                     mag:=mag+asteroid_magn_comp(a_g{asteroid_slope_factor},phase);
                     {slope factor =0.15
                      angle object-sun-earth of 0   => 0   magnitude
                                                5      0.42
                                               10      0.65
                                               15      0.83
                                               20      1}
                   end
                   else
                   begin {comet magnitude}
                     mag:=H+ ln(delta)*5/ln(10)+ c_k*ln(sun_delta)/ln(10) ;
                   end;

                   if mag<=maxmag then
                   begin
                     if asteroid then plot_asteroid(annotation_diameter) else plot_asteroid(annotation_diameter*5);
                   end;

                   if frac(count/10000)=0 then
                   begin
                     if  form_existing then  form_asteroids1.caption:=inttostr(count);
                     application.processmessages;{check for esc}
                   end;
                 end;{within FOV}
               except
               end;
             end;
           end;{longer then 10}
        end;
        finally
          CloseFile(txtf);
        end;
      end;

begin
  if fits_file=false then exit;
  if head.cd1_1=0 then begin memo2_message('Abort, first solve the image!');exit;end;
  cos_telescope_dec:=cos(head.dec0);
  fov:=1.5*sqrt(sqr(0.5*head.width*head.cdelt1)+sqr(0.5*head.height*head.cdelt2))*pi/180; {field of view with 50% extra}
  flip_vertical:=mainwindow.flip_vertical1.Checked;
  flip_horizontal:=mainwindow.flip_horizontal1.Checked;
  mainwindow.image1.Canvas.brush.Style:=bsClear;
  form_existing:=assigned(form_asteroids1);{form existing}

  {$ifdef mswindows}
  mainwindow.image1.Canvas.Font.Name :='default';
  {$endif}
  {$ifdef linux}
  mainwindow.image1.Canvas.Font.Name :='DejaVu Sans';
  {$endif}
  {$ifdef darwin} {MacOS}
  mainwindow.image1.Canvas.Font.Name :='Helvetica';
  {$endif}

  mainwindow.image1.canvas.pen.color:=annotation_color;{color circel}
  mainwindow.image1.Canvas.font.color:=annotation_color;
  fontsize:=round(min(20,max(10,head.height*20/4176)));

  if font_follows_diameter then
  begin
    fontsize:=max(annotation_diameter,fontsize);
    mainwindow.image1.Canvas.Pen.width := 1+annotation_diameter div 10;{thickness lines}
  end;
  mainwindow.image1.Canvas.font.size:=fontsize;
  str(max(1,fontsize/12):0:1,fontsize_str); {store font size for header annotations}

  if date_avg<>'' then
    date_to_jd(date_avg,0 {head.exposure}){convert date-AVG to jd_mid be using head.exposure=0}
  else
    date_to_jd(head.date_obs,head.exposure);{convert date-OBS to jd_start and jd_mid}

  if jd_start<=2400000 then {no date, found year <1858}
  begin
    mainwindow.error_label1.caption:=('Error converting date-obs or date-avg from the FITS header');
    mainwindow.error_label1.visible:=true;
    memo2_message(filename2+ ' Error converting date-obs or date-avg from the FITS header');
    exit;
  end;

  dec_text_to_radians(sitelat,site_lat_radians,errordecode);
  if errordecode then memo2_message('Warning observatory latitude not found in the fits header');

  dec_text_to_radians(sitelong,site_long_radians,errordecode); {longitude is in degrees, not in hours. East is positive according ESA standard and diffractionlimited}
                                                               {see https://indico.esa.int/event/124/attachments/711/771/06_ESA-SSA-NEO-RS-0003_1_6_FITS_keyword_requirements_2014-08-01.pdf}
  if errordecode then memo2_message('Warning observatory longitude not found in the fits header');

  delta_t:=deltaT_calc(jd_mid); {calculate delta_T in days}

  wtime2actual:=fnmodulo(site_long_radians+siderealtime2000 +(jd_mid-2451545 )* earth_angular_velocity,2*pi);{Local sidereal time. As in the FITS header in ASTAP the site longitude is positive if east and has to be added to the time}

  sun200_calculated:=false;
  count:=0;
  sincos(head.dec0,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}

  if add_annot then
  begin
     remove_key('ANNOTATE',true{all});{remove key annotate words from header}
     annotated:=false;
  end;

  if mpcorb_path<>'' then
  begin
    if  fileexists(mpcorb_path) then
      read_and_plot(true,mpcorb_path)
    else
      memo2_message('MPCORB.DAT file not found: '+ mpcorb_path+'   Set path in menu CTRL+Q' );
  end;

  count:=0;

  if cometels_path<>'' then
  begin
    if fileexists(cometels_path) then
      read_and_plot(false,cometels_path)
    else
      memo2_message('CometEls.txt file not found: '+ cometels_path+'   Set path in menu CTRL+Q' );
  end;

  {write some info at bottom screen}

  if form_existing then
  begin
    with mainwindow do
    begin
      if add_date then
      begin
        mainwindow.image1.Canvas.textout(round(0.5*fontsize),head.height-round(4*fontsize),'Position[α,δ]:  '+mainwindow.ra1.text+'    '+mainwindow.dec1.text);{}
        mainwindow.image1.Canvas.textout(round(0.5*fontsize),head.height-round(2*fontsize),'Midpoint date: '+JdToDate(jd_mid)+', total exp: '+inttostr(round(head.exposure))+'s');{}
      end;
    end;
  end;
end;


function test_mpcorb : boolean;
begin
  if fileExists(form_asteroids1.mpcorb_path1.caption)=false then
  begin
    form_asteroids1.mpcorb_path1.Font.color:=clred;
    form_asteroids1.mpcorb_filedate1.caption:='No MPCORB.DAT file';
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

function test_cometels : boolean;
begin
  if fileExists(form_asteroids1.mpcorb_path2.caption)=false then
  begin
    form_asteroids1.mpcorb_path2.Font.color:=clred;
    form_asteroids1.mpcorb_filedate2.caption:='No CometEls.txt file';
    result:=false;
    exit;
  end
  else
  begin
    form_asteroids1.mpcorb_filedate2.caption:=DateTimeToStr(FileDateToDateTime(FileAge(form_asteroids1.mpcorb_path2.caption)));
    form_asteroids1.mpcorb_path2.font.color:=clgreen;
    result:=true;
  end;
end;


procedure set_some_defaults; {wil be set if annotate button is clicked or when form is closed}
begin
  with form_asteroids1 do
  begin
    {latitude, longitude}
    sitelat:=latitude1.Text;
    sitelong:=longitude1.Text;

    lat_default:=sitelat;
    long_default:=sitelong;

    if midpoint=false then
      head.date_obs:=date_obs1.Text
    else
      date_avg:=date_obs1.Text;

    annotation_color:=ColorBox1.selected;
    annotation_diameter:=form_asteroids1.annotation_size2.Position div 2;
  end;
end;


procedure Tform_asteroids1.annotate_asteroids1Click(Sender: TObject); {han.k}
var maxcount : integer;
    maxmag   : double;
    Save_Cursor: TCursor;


begin
  set_some_defaults;

  font_follows_diameter:=font_follows_diameter1.checked;


  maxcount_asteroid:=max_nr_asteroids1.text;
  maxcount:=strtoint(form_asteroids1.max_nr_asteroids1.text);

  maxmag_asteroid:=max_magn_asteroids1.text;
  maxmag:=strtofloat2(form_asteroids1.max_magn_asteroids1.text);

  showfullnames:=form_asteroids1.showfullnames1.checked;
  showmagnitude:=form_asteroids1.showmagnitude1.checked;

  add_annotations:=form_asteroids1.add_annotations1.checked;

  add_date:=form_asteroids1.add_subtitle1.checked;

  if ((test_mpcorb=false) and (test_cometels=false)) then begin exit; end;{file not found}

  mpcorb_path:=form_asteroids1.mpcorb_path1.caption;
  cometels_path:=form_asteroids1.mpcorb_path2.caption;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  plot_mpcorb(maxcount,maxmag,add_annotations);
  Screen.Cursor:= Save_Cursor;

  form_asteroids1.close;   {normal this form is not loaded}
  mainwindow.setfocus;
end;


procedure Tform_asteroids1.BitBtn1Click(Sender: TObject);
begin
  mpcorb_path1.caption:='';
  mpcorb_path:='';
  test_mpcorb;
end;


procedure Tform_asteroids1.BitBtn2Click(Sender: TObject);
begin
  mpcorb_path2.caption:='';
  cometels_path:='';
  test_cometels;
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
  opendialog1.Filter := 'MPCORB.DAT(*.DAT*)|*.dat;*.DAT';
  if opendialog1.execute then
  begin
    mpcorb_path1.caption:=OpenDialog1.Files[0];
    test_mpcorb;
  end;
end;


procedure Tform_asteroids1.file_to_add2Click(Sender: TObject);
begin
  OpenDialog1.Title := 'Select CometEls.txt to use';
  OpenDialog1.Options := [ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := 'CometEls.txt file (Com*.txt)|Com*.txt';
  if opendialog1.execute then
  begin
    mpcorb_path2.caption:=OpenDialog1.Files[0];
    test_cometels;
  end;
end;


procedure Tform_asteroids1.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
   set_some_defaults;
end;


procedure Tform_asteroids1.FormKeyPress(Sender: TObject; var Key: char);{han.k}
begin {set form keypreview:=on}
  if key=#27 then
  begin
    esc_pressed:=true;
  end;
end;


procedure Tform_asteroids1.FormShow(Sender: TObject);{han.k}
begin
  esc_pressed:=false;{reset from cancel}

  mpcorb_path1.caption:=mpcorb_path;
  test_mpcorb;
  mpcorb_path2.caption:=cometels_path;
  test_cometels;
  if date_avg<>'' then
  begin
     date_label1.caption:='DATE_AVG';
     label_start_mid1.caption:='Midpoint of the observation';
     date_obs1.Text:=date_avg;
     midpoint:=true;
  end
  else
  begin
    date_label1.caption:='DATE_OBS';
    label_start_mid1.caption:='Start of the observation';
    date_obs1.Text:=head.date_obs;
    midpoint:=false;
  end;

  max_nr_asteroids1.text:=maxcount_asteroid;
  max_magn_asteroids1.text:=maxmag_asteroid;

  {latitude, longitude}
  if sitelat='' then {use values from previous time}
  begin
    sitelat:=lat_default;
    sitelong:=long_default;
  end;

  latitude1.Text:=trim(sitelat); {copy the string to tedit}
  longitude1.Text:=trim(sitelong);


  showfullnames1.Checked:=showfullnames;
  showmagnitude1.Checked:=showmagnitude;
  add_annotations1.Checked:=add_annotations;

  form_asteroids1.add_subtitle1.checked:=add_date;

  ColorBox1.selected:=annotation_color;
  annotation_size2.position:=annotation_diameter*2;
  font_follows_diameter1.checked:=font_follows_diameter;

end;


procedure Tform_asteroids1.Group_Box1Click(Sender: TObject);
begin
  mpcorb_path:='';
end;



end.

