unit unit_dss;
{calculates to RA/DEC from a DSS image pixel position}

{By han_kleijn@hnsky.org. (c) 2001, 2002, 2003, for non-commercial use only }
{For updates have a look to www.hnsky.org}

interface

uses math;

var  {input}
     x_coeff: array[0..19] of double;{amdx1 ..20}
     y_coeff: array[0..19] of double;{amdy1 ..20}
     ppo_coeff: array[0..5] of double;{ppo1 ..6}
     x_pixel_offset: integer; {cnpix1}
     y_pixel_offset: integer; {cnpix2}
     x_pixel_size  : double;  {xpixelSZ}
     y_pixel_size  : double;  {ypixelSZ}
     plate_ra      : double;  {PLTRA  ..H  ..M ..S}
     plate_dec     : double;  {PLTDEC ..SN ..D ..M ..S}
     dec_sign      : double;

Procedure DSSPOS (xpix ,ypix : double; var xpos, ypos : double);

implementation


Procedure DSSPOS (xpix ,ypix : double; var xpos, ypos: double);
{  Mathematical solution based of DSSPOS.C of WCStools
   Documentation, to some extent, is online at
   http://tdc-www.harvard.edu/software/wcstools/libwcs.wcs.html
   For non-commercial purposes only.

   Routine to determine accurate position for pixel coordinates
   returns 0 if successful otherwise 1 = angle too large for projection }

{    (* Input: *)
     double xpix ;      (* x pixel number  (RA or long without rotation) *)
     double ypix ;      (* y pixel number  (dec or lat without rotation) *)
    (* Output: *)
    double  *xpos ;      (* Right ascension or longitude in radians *)
    double  *ypos ;      (* Declination or latitude in radians *)}
  var
     x ,y ,xmm ,ymm ,xmm2 ,ymm2 ,xmm3 ,ymm3 ,x2y2,
     xi, xir, eta, etar ,raoff ,ra ,dec,
     ctan ,ccos : double;

  const
    cons2r : double= 3600*180/pi; {206264.8062470964}
    twopi  : double= 2*pi;
  begin

    //* Convert from image pixels to plate pixels */
    x := xpix + x_pixel_offset -1.0+0.5; {2013 reintroduced original -1.0+0.5 factors}
    y := ypix + y_pixel_offset -1.0+0.5;

   {Convert from pixels to millimeters }
    xmm := ( ppo_coeff[2] -x * x_pixel_size )/1000.0;
    ymm := (y * y_pixel_size - ppo_coeff[5] )/1000.0;
    xmm2 := xmm * xmm ;
    ymm2 := ymm * ymm ;
    xmm3 := xmm * xmm2 ;
    ymm3 := ymm * ymm2 ;
    x2y2 := xmm2 + ymm2 ;

   {Compute coordinates from x,y and plate model }

    xi :=  x_coeff[ 0] * xmm  + x_coeff[ 1]* ymm +
           x_coeff[ 2]              + x_coeff[ 3] * xmm2 +
           x_coeff[ 4] * xmm * ymm  + x_coeff[ 5] * ymm2 +
           x_coeff[ 6] * (x2y2 )    + x_coeff[ 7] * xmm3 +
           x_coeff[ 8] * xmm2 * ymm + x_coeff[ 9] * xmm * ymm2 +
           x_coeff[10] * ymm3       + x_coeff[11] * xmm *(x2y2 )+
           x_coeff[12] * xmm * x2y2 * x2y2 ;

  {  Ignore magnitude and color terms+ wcs->x_coeff[13]*mag	+ wcs->x_coeff[14]*mag*mag + wcs->x_coeff[15]*mag*mag*mag + wcs->x_coeff[16]*mag*xmm +	wcs->x_coeff[17]*mag*x2y2 + wcs->x_coeff[18]*mag*xmm*x2y2 + wcs->x_coeff[19]*color; }

    eta := y_coeff[ 0] * ymm  + y_coeff[ 1] * xmm +
           y_coeff[ 2]             + y_coeff[ 3] * ymm2 +
           y_coeff[ 4] * xmm *ymm  + y_coeff[ 5] * xmm2 +
           y_coeff[ 6] * (x2y2 )   + y_coeff[ 7] * ymm3 +
           y_coeff[ 8] * ymm2 *xmm + y_coeff[ 9] * ymm * xmm2 +
           y_coeff[10] * xmm3      + y_coeff[11] * ymm *(x2y2 )+
           y_coeff[12] * ymm * x2y2 * x2y2 ;

    {Ignore magnitude and color terms+ wcs->y_coeff[13]*mag	+ wcs->y_coeff[14]*mag*mag +wcs->y_coeff[15]*mag*mag*mag + wcs->y_coeff[16]*mag*ymm + wcs->y_coeff[17]*mag*x2y2)	+ wcs->y_coeff[18]*mag*ymm*x2y2 +wcs->y_coeff[19]*color;}

    {Convert to radians }
    xir := xi / cons2r ;
    etar := eta / cons2r ;

    (* Convert to RA and Dec *)
    ctan := sin ( plate_dec )/cos(plate_dec );{tan is sin/cos}
    ccos := cos ( plate_dec );

    raoff := arctan2(xir / ccos ,1.0-etar *ctan );
    ra := raoff + plate_ra ;
    if (ra <0.0) then ra := ra +twopi ;
    xpos := ra  ;

    dec := arctan (cos (raoff )*((etar +ctan )/(1.0-(etar *ctan ))));
    ypos := dec  ;
  END;

end.
