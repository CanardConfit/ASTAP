unit unit_astrometric_solving;
{Copyright (C) 2017, 2025 by Han Kleijn, www.hnsky.org
email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }


{ASTAP is using a linear astrometric solution for both stacking and solving.  The method is based on what traditionally is called "reducing the plate measurements.
First step is to find star matches between a test image and a reference image. The reference image is either created from a star database or a reference image.
The star positions x, y are to be calculated in standard coordinates which is equivalent to the x,y pixel position. The x,y position are measured relative to the image center.

The test image center, size and orientation position will be different compared with the reference image. The required conversion from test image [x,y] star positions to the
same stars on the test images can be written as:

Xref : = a*xtest + b*ytest + c
Yref:=   d*xtest + e*ytest + f

The factors, a,b,c,d,e,f are called the six plate constants and will be slightly different different for each star. They describe the conversion of  the test image standard coordinates
to the reference image standard coordinates. Using a least square routine the best solution fit can calculated if at least three matching star positions are found since there are three unknowns.

With the solution and the equatorial center position of the reference image the test image center equatorial position, α and δ can be calculated.

Make from the test image center small one pixel steps in x, y and use the differences in α, δ to calculate the image scale and orientation.

For astrometric solving (plate solving), this "reducing the plate measurement" is done against star positions extracted from a database. The resulting absolute astrometric solution
will allow specification of the α, δ equatorial positions of each pixel. For star alignment this "reducing the plate measurement" is done against a reference image. The resulting
six plate constants are a relative astrometric solution. The position of the reference image is not required. Pixels of the solved image can be stacked with reference image using
the six plate constants only.

To automate this process rather then using reference stars the matching reference objects are the center positions of quads made of four close stars. Comparing the length ratios
of the sides of the quads allows automated matching.

Below a brief flowchart of the ASTAP astrometric solving process:
}

//                                                  =>ASTAP  astronomical plate solving method by Han Kleijn <=
//
//      => Image <=         	                                                 |	=> Star database <=
//1) 	Find background, noise and star level                                    |
//                                                                               |
//2) 	Find stars and their CCD x, y position (standard coordinates) 	         | Extract the same amount of stars (area corrected) from the area of interest
//                                                                               | Convert the α, δ equatorial coordinates into standard coordinates
//                                                                               | (CCD pixel x,y coordinates for optical projection), rigid method
//
//3) 	Use the extracted stars to construct the smallest irregular tetrahedrons | Use the extracted stars to construct the smallest irregular tetrahedrons
//      figures of four  star called quads. Calculate the six distance between   | figures of four  star called quads. Calculate the six distance between
//      the four stars and the mean x,y position of the quad                     | the four stars and the mean x,y position of the quad
//                                                                               |
//4) 	For each quad sort the six quad distances.                      	 | For each quad sort the six quad distances.
//      Label them all where d1 is the longest and d6 the shortest distance.     | Label them all where d1 is the longest and d6 the shortest distance.
//                                                                               |
//5) 	Scale the six quad star distances as (d1, d2/d1,d3/d1,d4/d1,d5/d1,d6/d1) | Scale the six quad star distances as (d1, d2/d1,d3/d1,d4/d1,d5/d1,d6/d1)
//      These are the image hash codes.                                          | These are the database hash codes.
//
//                           => matching process <=
//6)                         Find quad hash code matches where the five ratios d2/d1 to d6/d1 match within a small tolerance.
//
//7) 		             For matching quad hash codes, calculate the longest side ratios d1_found/d1_reference. Calculate the median ratio.
//                           Compare the quads longest side ratios with the median value and remove quads outside a small tolerance.
//
//8)                         From the remaining matching quads, prepare the "A" matrix/array containing the x,y center positions of the test image quads in standard coordinates
//                           and  the array X_ref, Y_ref containing the x, y center positions of the reference imagete trahedrons in standard coordinates.
//
//                           A:                  Sx:         X_ref:
//                           [x1 y1  1]          [a1]         [X1]
//                           [x2 y2  1]    *     [b1]    =    [X2]
//                           [x3 y3  1]          [c1]         [X3]
//                           [x4 y4  1]                       [X4]
//                           [.. .. ..]                       [..]
//                           [xn yn  1]                       [Xn]
//
//
//                           A:                  Sx:         Y_ref:
//                           [x1 y1  1]          [a2]         [Y1]
//                           [x2 y2  1]    *     [b2]    =    [Y2]
//                           [x3 y3  1]          [c2]         [Y3]
//                           [x4 y4  1]                       [Y4]
//                           [.. .. ..]                       [..]
//                           [xn yn  1]                       [Yn]
//
//                           Find the solution matrices Sx and Sy of this overdetermined system of linear equations. (LSQ_FIT)
//
//                           The solutions Sx and Sy describe the six parameter solution, X_ref:=a1*x + b1*y + c1 and Y_ref:=a2*x + b2*y +c2.
//
//
//                           With the solution calculate the test image center equatorial position α (crval1), δ (crval2).
//
//                           Calculate from the solution the pixel size in x (cdelt1) an y (cdelt2) and at the image center position the rotation of the x-axis (crota1)
//                           and y-axis (crota2) relative to the celestial north using goniometric formulas. Convert these to cd1_1,cd1_2,cd_2_1, cd2_2.
//
//                           This is the final solution. The solution vector (for position, scale, rotation) can be stored as the FITS keywords crval1, crval2, cd1_1,cd1_2,cd_2_1, cd2_2.
//
// Notes:
// For a low faint star count (<30) the star patterns can be slightly different between image and database due to small magnitude differences.
// For these cases it can be beneficial to extract triples (three stars patterns) from the found quads (four star patterns) but stricter tolerances are required to avoid false detections.


interface

uses   Classes,SysUtils,controls,forms,math,stdctrls,
       unit_star_align, unit_star_database, astap_main, unit_stack, unit_annotation,unit_stars_wide_field, unit_calc_trans_cubic,unit_profiler;

function solve_image(img :Timage_array;var hd: Theader;memo:tstrings; get_hist{update hist},check_patternfilter :boolean) : boolean;{find match between image and star database}
procedure bin_and_find_stars(img :Timage_array;var head:theader; binfactor:integer;cropping,hfd_min:double;max_stars:integer;get_hist{update hist}:boolean; out starlist3:Tstar_list; out mean_hfd: double; out short_warning : string);{bin, measure background, find stars}

function report_binning(height :double) : integer;{select the binning}
function position_angle(ra1,dec1,ra0,dec0 : double): double;//Position angle of a body at ra1,dec1 as seen at ra0,dec0. Rigorous method
procedure equatorial_standard(ra0,dec0,ra,dec, cdelt : double; out xx,yy: double);
function read_stars(telescope_ra,telescope_dec,search_field : double; database_type,nrstars_required: integer;out starlist : Tstar_list): boolean;{read star from star database}
procedure bin_mono_and_crop(binning: integer; crop {0..1}:double;img : Timage_array; out img2: Timage_array); // Make mono, bin and crop


var
  star1   : array[0..2] of array of single;
  mag2  : double; {magnitude of star found}

implementation

function distance_to_string(dist, inp:double):string; {angular distance to string intended for RA and DEC. Unit is based on dist}
begin
  if abs(dist)<pi/(180*60) then {unit seconds}
      result:= floattostrF(inp*3600*180/pi,ffFixed,0,1)+'"'
  else
  if abs(dist)<pi/180 then {unit minutes}
      result:= floattostrF(inp*60*180/pi,ffFixed,0,1)+#39
  else
  result:= floattostrF(inp*180/pi,ffFixed,0,1)+'d';  {° symbol is converted to unicode by tmemo}
end;


function position_angle(ra1,dec1,ra0,dec0 : double): double;//Position angle between a line from ra0,dec0 to ra1,dec1 and a line from ra0, dec0 to the celestial north . Rigorous method
//See book Meeus, Astronomical Algorithms, formula 46.5 edition 1991 or 48.5 edition 1998, angle of moon limb or page 116 edition 1998.
//See also https://astronomy.stackexchange.com/questions/25306/measuring-misalignment-between-two-positions-on-sky
//   PA=arctan2(cos(δ0)sin(α1−α0), sin(δ1)cos(δ0)−sin(δ0)cos(δ1)cos(α1−α0))      In lazarus the function is arctan2(y/x)
//   is seen at point α0,δ0. This means you are calculating the angle at point α0,δ0 (the reference point) towards point α1,δ1 (the target point).
//   To clarify:
//     Point α0,δ0 (Reference Point): This is where the observation is made from, or the point of reference.
//     Point α1,δ1 (Target Point): This is the point towards which the position angle is being measured.
//     Position Angle (PA): This is the angle measured at the reference point α0,δ0, going from the direction of the North Celestial Pole towards the target point α1,δ1, measured eastward (or counter-clockwise).
//     So in your observational scenario, if you were at point α0,δ0 and wanted to determine the direction to point α1,δ1, the PA would tell you the angle to rotate from the north, moving eastward, to align with the target point.

var
  sinDeltaRa,cosDeltaRa,
  sinDec0,cosDec0,
  sinDec1,cosDec1 : double;
begin
  sincos(ra1-ra0,sinDeltaRa,cosDeltaRa);
  sincos(dec0,sinDec0,cosDec0);
  sincos(dec1,sinDec1,cosDec1);
  result:=arctan2(cosDec1*sinDeltaRa,sinDec1*cosDec0 - cosDec1*sinDec0*cosDeltaRa);
end;


{transformation of equatorial coordinates into CCD pixel coordinates for optical projection, rigid method}
{head.ra0,head.dec0: right ascension and declination of the optical axis}
{ra,dec:   right ascension and declination}
{xx,yy :   CCD coordinates}
{cdelt:    CCD scale in arcsec per pixel}
procedure equatorial_standard(ra0,dec0,ra,dec, cdelt : double; out xx,yy: double);
var dv,sin_dec0,cos_dec0,sin_dec ,cos_dec,sin_deltaRA,cos_deltaRA: double;
begin
  sincos(dec0  ,sin_dec0 ,cos_dec0);
  sincos(dec   ,sin_dec  ,cos_dec );
  sincos(ra-ra0, sin_deltaRA,cos_deltaRA);
  dv  := (cos_dec0 * cos_dec * cos_deltaRA + sin_dec0 * sin_dec) * cdelt/(3600*180/pi); {cdelt/(3600*180/pi), factor for conversion standard coordinates to CCD pixels}
  xx := - cos_dec *sin_deltaRA / dv;{tangent of the angle in RA}
  yy := -(sin_dec0 * cos_dec * cos_deltaRA - cos_dec0 * sin_dec) / dv;  {tangent of the angle in DEC}
end;


{transformation from CCD coordinates into equatorial coordinates}
{ra0, dec0: right ascension and declination of the optical axis       }
{x,y     : CCD coordinates                                           }
{cdelt:  : scale of CCD pixel in arc seconds                         }
{ra,dec  : right ascension and declination                           }
//{$INLINE off}
{$INLINE ON}
{procedure standard_equatorialold(ra0,dec0,x,y,cdelt: double; out ra,dec : double); inline; //transformation from CCD coordinates into equatorial coordinates
var sin_dec0 ,cos_dec0,delta : double;
begin
  sincos(dec0  ,sin_dec0 ,cos_dec0);
  x:=x *cdelt/ (3600*180/pi); //scale CCD pixels to standard coordinates (tang angle)
  y:=y *cdelt/ (3600*180/pi);

  ra  := ra0 + arctan2 (-x, cos_DEC0- y*sin_DEC0); //atan2 is required for images containing celestial pole
  dec := arcsin ( (sin_dec0+y*cos_dec0)/sqrt(1.0+x*x+y*y) );

  if ra>pi*2 then ra:=ra-pi*2; //prevent values above 2*pi which confuses the direction detection later
  if ra<0 then ra:=ra+pi*2;
end;
}

{transformation from CCD coordinates into equatorial coordinates}
{ra0,dec0: right ascension and declination of the optical axis       }
{x,y     : CCD coordinates                                           }
{cdelt:  : scale of CCD pixel in arc seconds                         }
{ra,dec  : right ascension and declination                           }
{$INLINE ON}
procedure standard_equatorial(ra0,dec0,x,y,cdelt: double; out ra,dec : double); inline;{transformation from CCD coordinates into equatorial coordinates}
var sin_dec0 ,cos_dec0,delta : double;
begin
  sincos(dec0  ,sin_dec0 ,cos_dec0);
  x:=x *cdelt/ (3600*180/pi);//scale CCD pixels to standard coordinates (tang angle)
  y:=y *cdelt/ (3600*180/pi);

  delta:=cos_dec0-y*sin_dec0;
  ra:=ra0+arctan2(-x,delta); //atan2 is required for images containing celestial pole
  dec:=arctan((sin_dec0+y*cos_dec0)/sqrt(sqr(x)+sqr(delta)));
  if ra>pi*2 then ra:=ra-pi*2; //prevent values above 2*pi which confuses the direction detection later
  if ra<0 then ra:=ra+pi*2;
end;


//procedure give_spiral_position(position : integer; out x,y : integer); {give x,y position of square spiral as function of input value}
//var i,dx,dy,t,count: integer;
//begin
//  x :=0;{star position}
//  y :=0;
//  dx := 0;{first step size x}
//  dy := -1;{first step size y}
//  count:=0;

//  for i:=0 to 10000*10000  {maximum width*height} do
//  begin
//    if  count>=position then exit; {exit and give x and y position}
//    inc(count);
//    if ( (x = y) or ((x < 0) and (x = -y)) or ((x > 0) and (x = 1-y))) then {turning point}
//    begin {swap dx by negative dy and dy by negative dx}
//       t:=dx;
//      dx := -dy;
//      dy := t;
//    end;
//     x :=x+ dx;{walk through square}
//     y :=y+ dy;{walk through square}
//  end;{for loop}
//end;


function read_stars(telescope_ra,telescope_dec,search_field : double; database_type,nrstars_required: integer;out starlist : Tstar_list): boolean;{read star from star database}
var
   Bp_Rp, ra2,dec2,
   frac1,frac2,frac3,frac4,sep                      : double;
   nrstars,area1,area2,area3,area4,nrstars_required2,count  : integer;
begin
  result:=false;{assume failure}
  nrstars:=0;{set counters at zero}
  ra2:=0; {define ra2 value. Prevent ra2 = -nan(0xffffffffffde9) run time failure when first header record is read}

  SetLength(starlist,2,nrstars_required);{set array length}

  if database_type>1 then {1476 or 290 files}
  begin
    {Assume the search field is at a crossing of four tiles. The search field area, by definition 100% is split in 8%, 15%, 20%, 57% area for each tile.
     There are 500 stars required. It will then retrieve 8% x 500, 15% x 500, 20% x 500, 57% x 500 stars from each tile under the condition these stars are within the green area.
     This will work assuming the star density within the green area is reasonable homogene.}
    find_areas( telescope_ra,telescope_dec, search_field,{var} area1,area2,area3,area4, frac1,frac2,frac3,frac4);{find up to four star database areas for the square image}

    {read 1th area}
    if area1<>0 then {read 1th area}
    begin
      if open_database(telescope_dec,area1)=false then
        exit;{open database file or reset buffer}
      nrstars_required2:=min(nrstars_required,trunc(nrstars_required * frac1));
      while ((nrstars<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, search_field, {var} ra2,dec2, mag2,Bp_Rp)) ) do {star 290 file database read. Read up to nrstars_required}
      begin {add star}
        equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist[0,nrstars]{x},starlist[1,nrstars]{y});{store star CCD x,y position}
        inc(nrstars);
      end;
    end;

    if area2<>0 then {read 2th area}
    begin
      if open_database(telescope_dec,area2)=false then
        exit; {open database file or reset buffer}
      nrstars_required2:=min(nrstars_required,trunc(nrstars_required * (frac1+frac2)));{prevent round up errors resulting in error starlist}
      while ((nrstars<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, search_field, {var} ra2,dec2, mag2,Bp_Rp)) ) do {star 290 file database read. Read up to nrstars_required}
      begin {add star}
        equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist[0,nrstars]{x},starlist[1,nrstars]{y});{store star CCD x,y position}
        inc(nrstars);
      end;
    end;

    if area3<>0 then {read 3th area}
    begin
      if open_database(telescope_dec,area3)=false then
        exit; {open database file or reset buffer}
      nrstars_required2:=min(nrstars_required,trunc(nrstars_required * (frac1+frac2+frac3)));
      while ((nrstars<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, search_field, {var} ra2,dec2, mag2,Bp_Rp)) ) do {star 290 file database read. Read up to nrstars_required}
      begin {add star}
        equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist[0,nrstars]{x},starlist[1,nrstars]{y});{store star CCD x,y position}
        inc(nrstars);
      end;
    end;

    if area4<>0 then {read 4th area}
    begin
      if open_database(telescope_dec,area4)=false then
       exit; {open database file}
      nrstars_required2:=min(nrstars_required,trunc(nrstars_required * (frac1+frac2+frac3+frac4)));
      while ((nrstars<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, search_field, {var} ra2,dec2, mag2,Bp_Rp)) ) do{star 290 file database read. Read up to nrstars_required}
      begin {add star}
        equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist[0,nrstars]{x},starlist[1,nrstars]{y});{store star CCD x,y position}
        inc(nrstars);
      end;
    end;
  end
  else
  begin {wide field database, database_type=1}
    if wide_database<>name_database then read_stars_wide_field;{load wide field stars array}
    count:=0;
    cos_telescope_dec:=cos(telescope_dec);
    while ((nrstars<nrstars_required) and  (count<length(wide_field_stars) div 3) ) do{star 290 file database read. Read up to nrstars_required}
    begin
      ra2:=wide_field_stars[count*3+1];{contains: mag1, ra1,dec1, mag2,ra2,dec2,mag3........}
      dec2:=wide_field_stars[count*3+2];
      ang_sep(ra2,dec2,telescope_ra,telescope_dec, sep);{angular seperation. Required for large field of view around the pole. Can not use simple formulas anymore}
      if ((sep<search_field*0.5*0.9*(2/sqrt(pi))) and  (sep<pi/2)) then  {factor 2/sqrt(pi) is to adapt circle search field to surface square. Factor 0.9 is a fiddle factor for trees, house and dark corners. Factor <pi/2 is the limit for procedure equatorial_standard}
      begin
        equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist[0,nrstars]{x},starlist[1,nrstars]{y});{store star CCD x,y position}
        inc(nrstars);
      end;
      inc(count);
    end;
    mag2:=wide_field_stars[(count-1)*3];{for reporting of highest magnitude used for solving}
  end;
  //  memo2_message('testareas'+#9+floattostr4(telescope_ra*12/pi)+#9+floattostr4(telescope_dec*180/pi)+#9+inttostr(maga)+#9+inttostr(magb)+#9+inttostr(magc)+#9+inttostr(magd)+#9+floattostr4(frac1)+#9+floattostr4(frac2)+#9+floattostr4(frac3)+#9+floattostr4(frac4)+#9+inttostr(area1)+#9+inttostr(area2)+#9+inttostr(area3)+#9+inttostr(area4));

  if nrstars<nrstars_required then
       SetLength(starlist,2,nrstars); {fix array length on data for case less stars are found}
  result:=true;{no errors}

  //for testing
//  equatorial_standard(telescope_ra,telescope_dec,head.ra0,head.dec0,1,correctionX,correctionY);{calculate correction for x,y position of database center and image center}
//  plot_stars_used_for_solving(correctionX,correctionY); {plot image stars and database stars used for the solution}
end;


procedure bin_mono_and_crop(binning: integer; crop {0..1}:double;img : Timage_array; out img2: Timage_array);// Make mono, bin and crop
var
  fitsX,fitsY,k, w,h, shiftX,shiftY,nrcolors,width5,height5,i,j,x,y: integer;
  val       : single;
begin
  nrcolors:=Length(img);
  width5:=Length(img[0,0]);{width}
  height5:=Length(img[0]); {height}

  w:=trunc(crop*width5/binning);  {dimensions after binning and crop}
  h:=trunc(crop*height5/binning);

  setlength(img2,1,h,w); {set length of image array}

  shiftX:=round(width5*(1-crop)/2); {crop is 0.9, shift is 0.05*head.width}
  shiftY:=round(height5*(1-crop)/2); {crop is 0.9, start at 0.05*head.height}

  if binning=1 then
  begin
    for fitsY:=0 to h-1 do
      for fitsX:=0 to w-1  do
      begin
        val:=0;
        for k:=0 to nrcolors-1 do {all colors and make mono}
           val:=val + img[k ,shiftY+fitsY,shiftX+fitsx];
        img2[0,fitsY,fitsX]:=val/nrcolors;
      end;
  end
  else
  if binning=2 then
  begin
    for fitsY:=0 to h-1 do
       for fitsX:=0 to w-1  do
      begin
        val:=0;
        for k:=0 to nrcolors-1 do {all colors}
          val:=val+(img[k,shiftY+fitsY*2   ,shiftX+fitsX*2]+
                    img[k,shiftY+fitsY*2 +1,shiftX+fitsX*2]+
                    img[k,shiftY+fitsY*2   ,shiftX+fitsX*2+1]+
                    img[k,shiftY+fitsY*2 +1,shiftX+fitsX*2+1])/4;
        img2[0,fitsY,fitsX]:=val/nrcolors;
      end;
  end
  else
  if binning=3 then
  begin
    for fitsY:=0 to h-1 do {bin & mono image}
      for fitsX:=0 to w-1  do
      begin
        val:=0;
        for k:=0 to nrcolors-1 do {all colors}
          val:=val+(img[k,shiftY+fitsY*3   ,shiftX+fitsX*3  ]+
                    img[k,shiftY+fitsY*3   ,shiftX+fitsX*3+1]+
                    img[k,shiftY+fitsY*3   ,shiftX+fitsX*3+2]+
                    img[k,shiftY+fitsY*3 +1,shiftX+fitsX*3  ]+
                    img[k,shiftY+fitsY*3 +1,shiftX+fitsX*3+1]+
                    img[k,shiftY+fitsY*3 +1,shiftX+fitsX*3+2]+
                    img[k,shiftY+fitsY*3 +2,shiftX+fitsX*3  ]+
                    img[k,shiftY+fitsY*3 +2,shiftX+fitsX*3+1]+
                    img[k,shiftY+fitsY*3 +2,shiftX+fitsX*3+2])/9;
        img2[0,fitsY,fitsX]:=val/nrcolors;
      end;
  end
  else
  if binning=4 then
  begin
    for fitsY:=0 to h-1 do //bin & mono image
      for fitsX:=0 to w-1  do
      begin
        val:=0;
        for k:=0 to nrcolors-1 do //all colors to mono. Test shows this loop doesn't introduce much delay for mono images
          val:=val+(img[k,shiftY+fitsY*4   ,shiftX+fitsX*4  ]+
                    img[k,shiftY+fitsY*4   ,shiftX+fitsX*4+1]+
                    img[k,shiftY+fitsY*4   ,shiftX+fitsX*4+2]+
                    img[k,shiftY+fitsY*4   ,shiftX+fitsX*4+3]+
                    img[k,shiftY+fitsY*4 +1,shiftX+fitsX*4  ]+
                    img[k,shiftY+fitsY*4 +1,shiftX+fitsX*4+1]+
                    img[k,shiftY+fitsY*4 +1,shiftX+fitsX*4+2]+
                    img[k,shiftY+fitsY*4 +1,shiftX+fitsX*4+3]+
                    img[k,shiftY+fitsY*4 +2,shiftX+fitsX*4  ]+
                    img[k,shiftY+fitsY*4 +2,shiftX+fitsX*4+1]+
                    img[k,shiftY+fitsY*4 +2,shiftX+fitsX*4+2]+
                    img[k,shiftY+fitsY*4 +2,shiftX+fitsX*4+3]+
                    img[k,shiftY+fitsY*4 +3,shiftX+fitsX*4  ]+
                    img[k,shiftY+fitsY*4 +3,shiftX+fitsX*4+1]+
                    img[k,shiftY+fitsY*4 +3,shiftX+fitsX*4+2]+
                    img[k,shiftY+fitsY*4 +3,shiftX+fitsX*4+3])/16;
        img2[0,fitsY,fitsX]:=val/nrcolors; //mono result
      end;

  end
  else
  begin //any bin factor. This routine is at bin 4x4 about twice slower then the above routine
    for fitsY:=0 to h-1 do
      for fitsX:=0 to w-1  do
      begin
        val:=0;
        x:=shiftX+fitsX*binning;
        y:=shiftY+fitsY*binning;
        for k:=0 to nrcolors-1 do {all colors to mono. Test shows this loop doesn't introduce much delay for mono images}
        begin
          for i:=0 to binning-1 do
          for j:=0 to binning-1 do
             val:=val + img[k,y+i   ,x+j];
        end;
        img2[0,fitsY,fitsX]:=val/(nrcolors*sqr(binning)); //mono result
      end;
  end;
end;


procedure bin_and_find_stars(img :Timage_array;var head:theader; binfactor:integer;cropping,hfd_min:double;max_stars:integer;get_hist{update hist}:boolean; out starlist3:Tstar_list; out mean_hfd: double; out short_warning : string);{bin, measure background, find stars}
var
  width5,height5,nrstars,i : integer;
  img_binned : Timage_array;
begin
  short_warning:='';{clear string}

  width5:=length(img[0,0]);{width}
  height5:=length(img[0]);{height}

  if ((binfactor>1) or (cropping<1)) then
  begin
    if binfactor>1 then memo2_message('Creating grayscale x '+inttostr(binfactor)+' binning image for solving or star alignment.');
    if cropping<>1 then memo2_message('Cropping image x '+floattostrF(cropping,ffFixed,0,2));

    bin_mono_and_crop(binfactor, cropping,img,img_binned); //{Make mono, bin and crop}

    {test routine, to show bin result}
    //    img_loaded:=img_binned;
    //    head.naxis3:=1;
    //    head.width:=length(img_binned[0,0]);
    //    head.height:=length(img_binned[0]);
    //    plot_fits(mainform1.image1,true,true);//plot real
    //    exit;  }

    get_background(0,img_binned,head ,true {load hist},true {calculate also standard deviation background});{get back ground}
    find_stars(img_binned,head,hfd_min,max_stars,starlist3,mean_hfd); {find stars of the image and put them in a list}

    if ((length(img_binned[0])<960) and (stackmenu1.downsample_for_solving1.text<>'0'){auto}) then
    begin
      short_warning:='Warning, remaining image dimensions too low! ';  {for FITS header and solution. Dimensions should be equal or better the about 1280x960}
      memo2_message('█ █ █ █ █ █ Warning, remaining image dimensions too low! Try to REDUCE OR REMOVE DOWNSAMPLING. Set this option in stack menu, tab alignment.');
    end;
    img_binned:=nil;

    nrstars:=Length(starlist3[0]);
    for i:=0 to nrstars-1 do {correct star positions for binning and cropping. Simplest method}
    begin
      starlist3[0,i]:=(binfactor-1)*0.5+starlist3[0,i]*binfactor +(width5*(1-cropping)/2);//correct star positions for binfactor/ cropping. Position [3.5,3,5] becomes after 2x2 binfactor [1,1] after x2 [3,3]. So correct for 0.5 pixel
      starlist3[1,i]:=(binfactor-1)*0.5+starlist3[1,i]*binfactor +(height5*(1-cropping)/2);
      // For zero based indexing:
      // A star of 2x2 pixels at position [2.5,2.5] is after 2x2 binfactor at position [1,1]. If doubled to [2,2] then the position has 0.5 pixel shifted.
      // A star of 3x3 pixels at position [4,4] is after 3x3 binfactor at position [1,1]. If tripled to [3,3] then the position has 1.0 pixel shifted.
      // A star of 4x4 pixels at position [5.5,5.5] is after 4x4 binfactor at position [1,1]. If quadruped to [4,4] then the position has 1.5 pixel shifted.
      // So positions measured in a binned image should be corrected as x:=(binfactor-1)*0.5+binfactor*x and y:=(binfactor-1)*0.5+binfactor*y
    end;
  end
  else
  begin
    if ((height5>2500) and (stackmenu1.downsample_for_solving1.text<>'0'){auto}) then
    begin
      short_warning:='Warning, increase downsampling!! '; {for FITS header and solution}
      memo2_message('Info: DOWNSAMPLING IS RECOMMENDED FOR LARGE IMAGES. Set this option in stack menu, tab alignment.');
    end
    else
    if height5<960 then
    begin
      short_warning:='Warning, small image dimensions! ';  {for FITS header and solution. Dimensions should be equal or better the about 1280x960}
      memo2_message('█ █ █ █ █ █ Warning, small image dimensions!');
    end;

    get_background(0,img,head,get_hist {load hist},true {calculate also standard deviation background});{get back ground}
    find_stars(img,head,hfd_min,max_stars,starlist3, mean_hfd); {find stars of the image and put them in a list}
  end;

 //  for i:=0 to length(starlist3[0])-1 do
 //          log_to_file('d:\temp\referenceA1.txt',floattostr(starlist3[0,i])+', '+floattostr(starlist3[1,i]));

end;


function report_binning_astrometric(height,arcsec_per_px:double) : integer;{select the binning}
begin
  result:=strtoint2(stackmenu1.downsample_for_solving1.text,0);
  if result<=0 then  {zero gives -1, Auto is 0}
  begin //auto
    if height>2500 then
      result:=2
    else
      result:=1;
    result:=max(result, round(1.5/arcsec_per_px));//pixelscale should be larger then 1"/px
  end;
  result:=min(16,result);//16 max. Too much anyhow
end;


function report_binning(height:double) : integer;{select the binning}
begin
  result:=min(16,strtoint2(stackmenu1.downsample_for_solving1.text,0));//16 max. Too much anyhow
  if result<=0 then  {zero gives -1, Auto is 0}
  begin
    if height>2500 then result:=2
    else
     result:=1;
  end;
end;

procedure create_grid_list( width2, height2, nrpoints : integer; out grid_list : TStarArray); // Create list of nbpoints x nbpoints positions in the image  equally spread. Positions relative to the image center.
var
  middleX,middleY : Double;
  s, x, y,counter : integer;
begin
  middleX:=width2/2;
  middleY:=height2/2;
  setlength(grid_list,nrpoints*nrpoints);
  counter:=0;
  for y := 0 to nrpoints-1 do
  begin
    for x := 0 to nrpoints-1 do
    begin
      grid_list[counter].x := -middleX+x*width2/(nrpoints-1);
      grid_list[counter].y := -middleY+y*height2/(nrpoints-1);
      inc(counter);
    end;
  end;
end;


function add_sip(hd: Theader;memo:tstrings; ra_database,dec_database:double) : boolean;
var
  stars_measured,stars_reference                        : TStarArray;
  trans_sky_to_pixel,trans_pixel_to_sky  : Ttrans;
  len,i                                  : integer;
  succ: boolean;
  err_mess: string;
  ra_t,dec_t,  SIN_dec_t,COS_dec_t, SIN_dec_ref,COS_dec_ref,det, delta_ra,SIN_delta_ra,COS_delta_ra, H, dRa,dDec : double;
begin
  result:=true;// assume success

  {1) Solve the image with the 1th order solver.
   2) Get the x,y coordinates of the detected stars= "stars_measured"
   3) Get the x,y coordinates of the reference stars= "stars_reference"
   4) Shift the x,y coordinates of "stars_measured" to the center of the image. so position [0,0] is at CRPIX1, CRPIX2.
   5) Convert reference stars coordinates to the same coordinate system as the measured stars.
      In my case I had to convert the quad x,y coordinates to ra, dec and then convert these to image position using the original first order solution
   6) Now both the "stars_measured" and "stars_reference" positions match with stars in the image except for distortion. Position [0,0] is at CRPIX1, CRPIX2.
   7) For pixel_to_sky  call:  Calc_Trans_Cubic(stars_measured,  stars_reference,...).   The trans array will work for pixel to sky.
   8) For sky_to_pixel  call:  Calc_Trans_Cubic(stars_reference,  stars_measured,...)    The trans array will work for sky to pixel.
   }

  len:=length(b_Xrefpositions);
  if len<20 then
  begin
    memo2_message('Not enough quads for calculating SIP.');
    exit(false);
  end;
  setlength(stars_measured,len);
  setlength(stars_reference,len);


  sincos(hd.dec0,SIN_dec_ref,COS_dec_ref);;{ For 5. Conversion (RA,DEC) -> x,y image in fits range 1..max}

  for i:=0 to len-1 do
  begin
    stars_measured[i].x:=1+A_XYpositions[0,i]-hd.crpix1;//position as seen from center at crpix1, crpix2, in fits range 1..width
    stars_measured[i].y:=1+A_XYpositions[1,i]-hd.crpix2;

    standard_equatorial( ra_database,dec_database,
                         b_Xrefpositions[i], {x reference star}
                         b_Yrefpositions[i], {y reference star}
                         1, {CCD scale}
                         ra_t,dec_t) ; //calculate back to the reference star positions


    {5. Conversion (RA,DEC) -> x,y image in fits range 1..max}
    sincos(dec_t,SIN_dec_t,COS_dec_t);
//  sincos(hd.dec0,SIN_dec_ref,COS_dec_ref);{Required but for speed executed outside the for loop}

    delta_ra:=ra_t-hd.ra0;
    sincos(delta_ra,SIN_delta_ra,COS_delta_ra);

    H := SIN_dec_t*sin_dec_ref + COS_dec_t*COS_dec_ref*COS_delta_ra;
    dRA := (COS_dec_t*SIN_delta_ra / H)*180/pi;
    dDEC:= ((SIN_dec_t*COS_dec_ref - COS_dec_t*SIN_dec_ref*COS_delta_ra ) / H)*180/pi;

    det:=hd.cd2_2*hd.cd1_1 - hd.cd1_2*hd.cd2_1;
    stars_reference[i].x:= - (hd.cd1_2*dDEC - hd.cd2_2*dRA) / det;
    stars_reference[i].y:= + (hd.cd1_1*dDEC - hd.cd2_1*dRA) / det;

  end;

  succ:=Calc_Trans_Cubic(stars_reference,     // First array of s_star structure we match the output trans_sky_to_pixel takes their coords into those of array B
                         stars_measured,      // Second array of s_star structure we match
                         trans_sky_to_pixel,  // Transfer coefficients for stars_measured positions to stars_reference positions. Fits range 1..max
                         err_mess             // any error message
                            );
  if succ=false then
  begin
    memo2_message(err_mess);
    exit(false);
  end;


  {sky to pixel coefficients}
  AP_order:=3; //third order
  AP_0_0:=trans_sky_to_pixel.x00;
  AP_0_1:=trans_sky_to_pixel.x01;
  AP_0_2:=trans_sky_to_pixel.x02;
  AP_0_3:=trans_sky_to_pixel.x03;
  AP_1_0:=-1+trans_sky_to_pixel.x10;
  AP_1_1:=trans_sky_to_pixel.x11;
  AP_1_2:=trans_sky_to_pixel.x12;
  AP_2_0:=trans_sky_to_pixel.x20;
  AP_2_1:=trans_sky_to_pixel.x21;
  AP_3_0:=trans_sky_to_pixel.x30;

  BP_0_0:=trans_sky_to_pixel.y00;
  BP_0_1:=-1+trans_sky_to_pixel.y01;
  BP_0_2:=trans_sky_to_pixel.y02;
  BP_0_3:=trans_sky_to_pixel.y03;
  BP_1_0:=trans_sky_to_pixel.y10;
  BP_1_1:=trans_sky_to_pixel.y11;
  BP_1_2:=trans_sky_to_pixel.y12;
  BP_2_0:=trans_sky_to_pixel.y20;
  BP_2_1:=trans_sky_to_pixel.y21;
  BP_3_0:=trans_sky_to_pixel.y30;


  //inverse transformation calculation
  //swap the arrays for inverse factors. This works as long the offset is small like in this situation
  succ:=Calc_Trans_Cubic(stars_measured,      // reference
                         stars_reference,      // distorted
                         trans_pixel_to_sky,  // Transfer coefficients for stars_measured positions to stars_reference positions
                         err_mess             // any error message
                         );

  if succ=false then
  begin
    memo2_message(err_mess);
    exit(false);
  end;

  // SIP definitions https://irsa.ipac.caltech.edu/data/SPITZER/docs/files/spitzer/shupeADASS.pdf

  //Pixel to sky coefficients
  A_order:=3;
  A_0_0:=trans_pixel_to_sky.x00;
  A_0_1:=trans_pixel_to_sky.x01;
  A_0_2:=trans_pixel_to_sky.x02;
  A_0_3:=trans_pixel_to_sky.x03;
  A_1_0:=-1+ trans_pixel_to_sky.x10;
  A_1_1:=trans_pixel_to_sky.x11;
  A_1_2:=trans_pixel_to_sky.x12;
  A_2_0:=trans_pixel_to_sky.x20;
  A_2_1:=trans_pixel_to_sky.x21;
  A_3_0:=trans_pixel_to_sky.x30;

  B_0_0:=trans_pixel_to_sky.y00;
  B_0_1:=-1+trans_pixel_to_sky.y01;
  B_0_2:=trans_pixel_to_sky.y02;
  B_0_3:=trans_pixel_to_sky.y03;
  B_1_0:=trans_pixel_to_sky.y10;
  B_1_1:=trans_pixel_to_sky.y11;
  B_1_2:=trans_pixel_to_sky.y12;
  B_2_0:=trans_pixel_to_sky.y20;
  B_2_1:=trans_pixel_to_sky.y21;
  B_3_0:=trans_pixel_to_sky.y30;


  update_integer(memo,'A_ORDER =',' / Polynomial order, axis 1. Pixel to Sky         ',3);
  update_float(memo,'A_0_0   =',' / SIP coefficient                                ',false,A_0_0);
  update_float(memo,'A_1_0   =',' / SIP coefficient                                ',false,A_1_0);
  update_float(memo,'A_0_1   =',' / SIP coefficient                                ',false,A_0_1);
  update_float(memo,'A_2_0   =',' / SIP coefficient                                ',false,A_2_0);
  update_float(memo,'A_1_1   =',' / SIP coefficient                                ',false,A_1_1);
  update_float(memo,'A_0_2   =',' / SIP coefficient                                ',false,A_0_2);
  update_float(memo,'A_3_0   =',' / SIP coefficient                                ',false,A_3_0);
  update_float(memo,'A_2_1   =',' / SIP coefficient                                ',false,A_2_1);
  update_float(memo,'A_1_2   =',' / SIP coefficient                                ',false,A_1_2);
  update_float(memo,'A_0_3   =',' / SIP coefficient                                ',false,A_0_3);


  update_integer(memo,'B_ORDER =',' / Polynomial order, axis 2. Pixel to sky.        ',3);
  update_float(memo,'B_0_0   =',' / SIP coefficient                                ',false ,B_0_0);
  update_float(memo,'B_0_1   =',' / SIP coefficient                                ',false ,B_0_1);
  update_float(memo,'B_1_0   =',' / SIP coefficient                                ',false ,B_1_0);
  update_float(memo,'B_2_0   =',' / SIP coefficient                                ',false ,B_2_0);
  update_float(memo,'B_1_1   =',' / SIP coefficient                                ',false ,B_1_1);
  update_float(memo,'B_0_2   =',' / SIP coefficient                                ',false ,B_0_2);
  update_float(memo,'B_3_0   =',' / SIP coefficient                                ',false ,B_3_0);
  update_float(memo,'B_2_1   =',' / SIP coefficient                                ',false ,B_2_1);
  update_float(memo,'B_1_2   =',' / SIP coefficient                                ',false ,B_1_2);
  update_float(memo,'B_0_3   =',' / SIP coefficient                                ',false ,B_0_3);

  update_integer(memo,'AP_ORDER=',' / Inv polynomial order, axis 1. Sky to pixel.      ',3);
  update_float(memo,'AP_0_0  =',' / SIP coefficient                                ',false,AP_0_0);
  update_float(memo,'AP_1_0  =',' / SIP coefficient                                ',false,AP_1_0);
  update_float(memo,'AP_0_1  =',' / SIP coefficient                                ',false,AP_0_1);
  update_float(memo,'AP_2_0  =',' / SIP coefficient                                ',false,AP_2_0);
  update_float(memo,'AP_1_1  =',' / SIP coefficient                                ',false,AP_1_1);
  update_float(memo,'AP_0_2  =',' / SIP coefficient                                ',false,AP_0_2);
  update_float(memo,'AP_3_0  =',' / SIP coefficient                                ',false,AP_3_0);
  update_float(memo,'AP_2_1  =',' / SIP coefficient                                ',false,AP_2_1);
  update_float(memo,'AP_1_2  =',' / SIP coefficient                                ',false,AP_1_2);
  update_float(memo,'AP_0_3  =',' / SIP coefficient                                ',false,AP_0_3);

  update_integer(memo,'BP_ORDER=',' / Inv polynomial order, axis 2. Sky to pixel.    ',3);
  update_float(memo,'BP_0_0  =',' / SIP coefficient                                ',false,BP_0_0);
  update_float(memo,'BP_1_0  =',' / SIP coefficient                                ',false,BP_1_0);
  update_float(memo,'BP_0_1  =',' / SIP coefficient                                ',false,BP_0_1);
  update_float(memo,'BP_2_0  =',' / SIP coefficient                                ',false,BP_2_0);
  update_float(memo,'BP_1_1  =',' / SIP coefficient                                ',false,BP_1_1);
  update_float(memo,'BP_0_2  =',' / SIP coefficient                                ',false,BP_0_2);
  update_float(memo,'BP_3_0  =',' / SIP coefficient                                ',false,BP_3_0);
  update_float(memo,'BP_2_1  =',' / SIP coefficient                                ',false,BP_2_1);
  update_float(memo,'BP_1_2  =',' / SIP coefficient                                ',false,BP_1_2);
  update_float(memo,'BP_0_3  =',' / SIP coefficient                                ',false,BP_0_3);
end;

procedure  keep_only_in_image(hd : theader; ra_database,dec_database : double; var starlist1 : Tstar_list);//keep only the database stars visible in the image using the first solution
var
   i, count,iw,ih                   : integer;
   xi,yi,scale,angle,ra7,dec7,crota2,centerX,centerY: double;
   starlistC         : tstar_list;
begin
  setlength(starlistC,2,Length(starlist1[0]));
  scale:=sqrt(sqr(solution_vectorX[0])+sqr(solution_vectorX[1]));
  iw:=hd.width;//scale of database
  ih:=hd.height;
//  angle:=arctan(

    // position +1 pixels in direction hd.crpix2
  standard_equatorial( ra_database,dec_database, (solution_vectorX[0]*(centerX) + solution_vectorX[1]*((hd.width-1)/2+1) +solution_vectorX[2]), {x}
                                                 (solution_vectorY[0]*(centerX) + solution_vectorY[1]*((hd.height-1)/2+1) +solution_vectorY[2]), {y}
                                                  1, {CCD scale}  ra7 ,dec7{equatorial position}); // the position 1 pixel away

  crota2:=-position_angle(ra7,dec7,ra_radians,dec_radians);//Position angle between a line from ra0,dec0 to ra1,dec1 and a line from ra0, dec0 to the celestial north . Rigorous method


  count:=0;
  for i:=0 to Length(starlist1[0])  do
  begin
     rotate((crota2)*pi/180,starlist1[0,i],starlist1[1,i],xi,yi);{rotate to screen orientation}

    if ((xi>0) and (xi<iw) and (yi>0) and (yi<ih)) then //within image boundaries
    begin
      starlistC[0,count]:=starlist1[0,i];
      starlistC[1,count]:=starlist1[1,i];
      inc(count);
    end;
  end;
  setlength(starlistC,2,count);
  starlist1:=starlistC;

end;




function solve_image(img :Timage_array;var hd: Theader;memo:tstrings; get_hist{update hist},check_patternfilter :boolean) : boolean;{find match between image and star database}
var
  nrstars,nrstars_required,nrstars_required2,count,max_distance,nr_quads, minimum_quads,binning,match_nr,
  spiral_x, spiral_y, spiral_dx, spiral_dy,spiral_t,max_stars,i, database_density,limit,err  : integer;
  search_field,step_size,ra_database,dec_database,ra_database_offset,radius,fov2,fov_org, max_fov,fov_min,oversize,oversize2,
  sep_search,seperation,ra7,dec7,centerX,centerY,correctionX,correctionY,cropping, min_star_size_arcsec,hfd_min,
  quad_tolerance,dummy, flip, extra,distance,mount_sep, mount_ra_sep,mount_dec_sep,ra_start,dec_start,pixel_aspect_ratio,
  crota1,crota2,flipped_image,arcsec_per_px,mean_hfd,xi,yi,scale,cdelt1,cdelt2  : double;
  solution, go_ahead, autoFOV,use_triples,yes_use_triples         : boolean;
  startTick  : qword;{for timing/speed purposes}
  distancestr,mess,info_message,popup_warningG05,popup_warningSample,suggest_str, solved_in,
  offset_found,ra_offset_str,dec_offset_str,mount_info_str,mount_offset_str,warning_downsample   : string;
  starlist1,starlist2                                                                            : Tstar_list;

  yy: integer;
var {with value}
  quads_str: string=' quads';
const
   popupnotifier_visible : boolean=false;


begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  result:=false;
  esc_pressed:=false;
  warning_str:='';{for header}
  startTick := GetTickCount64;
  popup_warningG05:='';

  if check_patternfilter then {for OSC images with low dimensions only}
  begin
    check_pattern_filter(img);
    get_hist:=true; {update required}
  end;

  quad_tolerance:=strtofloat2(stackmenu1.quad_tolerance1.text);
  quad_tolerance:=min(quad_tolerance,0.01);//prevent too high tolerances set by command line

  max_stars:=strtoint2(stackmenu1.max_stars1.text,500);{maximum star to process, if so filter out brightest stars later}
  use_triples:=stackmenu1.use_triples1.checked;

  ra_start:=ra_radians;//start position search;
  dec_start:=dec_radians;//start position search;

  if ((fov_specified=false) and (hd.cdelt2<>0)) then {no fov in native command line and hd.cdelt2 in header}
    fov_org:=min(180,hd.height*abs(hd.cdelt2)) {calculate FOV. PI can give negative hd.cdelt2}
  else
    fov_org:=min(180,strtofloat2(stackmenu1.search_fov1.text));{use specfied FOV in stackmenu. 180 max to prevent runtime errors later}


  if select_star_database(stackmenu1.star_database1.text,fov_org)=false then {select database prior to cropping selection}
  begin
    result:=false;
    errorlevel:=32;{no star database}
    exit;
  end
  else
  begin
    memo2_message('Using star database '+uppercase(name_database));

    if ((fov_org>30) and (database_type<>001)) then
      warning_str:=warning_str+'Very large FOV, use W08 database! '
    else
    if ((fov_org>6) and (database_type=1476)) then
      warning_str:=warning_str+'Large FOV, use G05 (or V05) database! ';

    if warning_str<>'' then memo2_message(warning_str);
     popup_warningG05:=#10+warning_str;
  end;

  if  database_type=1476  then {.1476 database}
    max_fov:=5.142857143 {warning FOV should be less the database tiles dimensions, so <=5.142857143 degrees. Otherwise a tile beyond next tile could be selected}
  else  {.1476 database}
  if  database_type=290  then {.290 database}
    max_fov:=9.53 {warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected}
  else
    max_fov:=180;

  if max_stars=0 then max_stars:=500;// temporary. Remove in 2024;

  val(copy(name_database,2,2),database_density,err);
  if ((err<>0) or
      (database_density=17) or (database_density=18)) then //old databases V17, G17, G18, H17, H18
    database_density:=9999
  else
    database_density:=database_density*100;


  min_star_size_arcsec:=strtofloat2(stackmenu1.min_star_size1.text); {arc sec};
  autoFOV:=(fov_org=0);{specified auto FOV}

  repeat {autoFOV loop}
    if autoFOV then
    begin
      if fov_org=0 then
      begin
        if database_type<>001 then
        begin
          fov_org:=9.5;
          fov_min:=0.38;
        end
        else
        begin
          fov_org:=90;
          fov_min:=12;
        end
      end
      else fov_org:=fov_org/1.5;
      memo2_message('Trying FOV: '+floattostrF(fov_org,ffFixed,0,1));
    end;
    if fov_org>max_fov then
    begin
      cropping:=max_fov/fov_org;
      fov2:=max_fov; {temporary cropped image, adjust FOV to adapt}
    end
    else
    begin
      cropping:=1;
      fov2:=fov_org;
    end;;

    limit:=round(database_density*sqr(fov2)*hd.width/hd.height);//limit in stars per square degree. limit=density*surface_full_image
    if limit<max_stars then
    begin
       max_stars:=limit;//reduce the number of stars to use.
       memo2_message('Database limit for this FOV is '+inttostr(max_stars)+' stars.');
    end;

    arcsec_per_px:=fov_org*3600/hd.height;//arc sec per pixel unbinned

    binning:=report_binning_astrometric(hd.height*cropping,arcsec_per_px); {select binning on dimensions of cropped image}
    hfd_min:=max(0.8,min_star_size_arcsec/(binning*arcsec_per_px) );{to ignore hot pixels which are too small}

    bin_and_find_stars(img,hd,binning,cropping,hfd_min,max_stars,get_hist{update hist}, starlist2, mean_hfd,warning_downsample);{bin, measure background, find stars. Do this every repeat since hfd_min is adapted}

    nrstars:=Length(starlist2[0]);

    if ((hd.xpixsz<>0) and (hd.ypixsz<>0) and (abs(hd.xpixsz-hd.ypixsz)>0.1)) then //non-square pixels, correct. Remove in future?
    begin //very very rare. Example QHY6 camera
      memo2_message('Rare none square pixels specified.');
      pixel_aspect_ratio:=hd.xpixsz/hd.ypixsz;
      for i:=0 to nrstars-1 do {correct star positions for non-square pixels}
      begin
        starlist2[0,i]:=hd.width/2+(starlist2[0,i]-hd.width/2)*pixel_aspect_ratio;
      end;
    end
    else
    pixel_aspect_ratio:=1;// this is the case in 99.95% of the cases

    {report advice}
    if length(warning_downsample)>0  then
    begin
       popup_warningSample:=#10+warning_downsample; {warning for popup notifier}
    end
    else
      popup_warningSample:='';


    {prepare popupnotifier1 text}
    if stackmenu1.force_oversize1.checked=false then info_message:='▶▶' {normal} else info_message:='▶'; {slow}
    info_message:= ' [' +stackmenu1.radius_search1.text+'°]'+#9+info_message+#9+inttostr(nrstars)+' 🟊' +
                    #10+'↕ '+floattostrf(fov_org,ffFixed,0,2)+'°'+ #9+#9+inttostr(binning)+'x'+inttostr(binning)+' ⇒ '+inttostr(hd.width)+'x'+inttostr(hd.height)+
                    popup_warningG05+popup_warningSample+
                    #10+mainform1.ra1.text+'h, '+mainform1.dec1.text+'° '+#9+{for tray icon} extractfilename(filename2)+
                    #10+extractfileDir(filename2);

    nrstars_required:=round(nrstars*(hd.height/hd.width));{A little less. The square search field is based on height only.}

    solution:=false; {assume no match is found}
    go_ahead:=(nrstars>=5); {bare minimum. Should be more but let's try}


    if go_ahead then {enough stars, lets find quads}
    begin
      yes_use_triples:=((nrstars<30) and  (use_triples));

      if yes_use_triples then
      begin
        find_triples_using_quads(starlist2,quad_star_distances2); {find star triples for new image. Quads are binning independent}

        quad_tolerance:=0.002;
        quads_str:=' triples';
         if solve_show_log then memo2_message('For triples the hash code tolerance is forced to '+floattostr(quad_tolerance)+'.');
      end
      else
      begin
        find_quads(false,starlist2,quad_star_distances2);{find star quads for new image. Quads are binning independent}
        quads_str:=' quads';

     //   for i:=0 to length(quad_star_distances2[0])-1 do
     //   begin
     //        memo2_message(#9+floattostr(quad_star_distances2[0,i])+#9+floattostr(quad_star_distances2[1,i])+#9+floattostr(quad_star_distances2[2,i])+#9+floattostr(quad_star_distances2[3,i])+#9+
     //                     floattostr(quad_star_distances2[4,i])+#9+floattostr(quad_star_distances2[5,i])+#9+floattostr(quad_star_distances2[6,i])+#9+floattostr(quad_star_distances2[7,i])   );
     //   end;
     //   exit;

      end;


      nr_quads:=Length(quad_star_distances2[0]);
      go_ahead:=nr_quads>=3; {enough quads?}

      {The step size is fixed. If a low amount of stars are detected, the search window (so the database read area) is increased up to 200% guaranteeing that all quads of the image are compared with the database quads while stepping through the sky}
      if nrstars<35  then oversize:=2 {make dimensions of square search window twice then the image height}
      else
      if nrstars>140 {at least 100 quads} then oversize:=1 {make dimensions of square search window equal to the image height}
      else
      oversize:=2*sqrt(35/nrstars);{calculate between 35 th=2 and 140 th=1, quads are area related so take sqrt to get oversize}

      if stackmenu1.force_oversize1.checked then oversize:=2;

      oversize:=min(oversize,max_fov/fov2);//limit request to database to 1 tile so 5.142857143 degrees for 1476 database or 9.53 degrees for type 290 database. Otherwise a tile beyond next tile could be selected}
      radius:=strtofloat2(stackmenu1.radius_search1.text);{radius search field}

      if yes_use_triples=false then
         minimum_quads:=3 + nrstars div 140 {prevent false detections for star rich images, 3 quads give the 3 center quad references and is the bare minimum. It possible to use one quad and four star positions but it in not reliable}
      else
         minimum_quads:=4 + nrstars div 140; //one quad is equivalent to 4 triples

    end
    else
    begin
      memo2_message('Only '+inttostr(nrstars)+' stars found in image. Abort');
      errorlevel:=2;
    end;

    if go_ahead then
    begin
      search_field:=fov2*(pi/180);

      STEP_SIZE:=search_field;{fixed step size search spiral}
      if database_type=1 then
      begin {make small steps for wide field images. Much more reliable}
        step_size:=step_size*0.1;
        max_distance:=round(radius/(0.1*fov2+0.00001)); {expressed in steps}
        memo2_message('Wide field, making small steps for reliable solving.');
      end
      else
      max_distance:=round(radius/(fov2+0.00001));{expressed in steps}

      memo2_message(inttostr(nrstars)+' stars, '+inttostr(nr_quads)+quads_str+' selected in the image. '+inttostr(round(nrstars_required*sqr(oversize)))+' database stars, '
                               +inttostr(round(nr_quads*nrstars_required*sqr(oversize)/nrstars))+' database'+quads_str+' required for the '+floattostrF(oversize*fov2,ffFixed,0,2)+'° square search window. '
                              +'Step size '+floattostrF(fov2,FFfixed,0,2) +'°. Oversize '+floattostrF(oversize,FFfixed,0,2) );

      stackmenu1.Memo2.Lines.BeginUpdate;{do not update tmemo, very very slow and slows down program}
      stackmenu1.Memo2.disablealign;{prevent paint messages from other controls to update tmemo and make it grey. Mod 2021-06-26}

      match_nr:=0;

      repeat {Maximum accuracy loop. In case math is found on a corner, do a second solve. Result will be more accurate using all stars of the image}
        count:=0;{search field counter}
        distance:=0; {required for reporting no too often}
        {spiral variables}
        spiral_x :=0;
        spiral_y :=0;
        spiral_dx := 0;{first step size x}
        spiral_dy := -1;{first step size y}

        repeat {search in squared spiral}
          {begin spiral routine, find a new squared spiral position position}
          if count<>0 then {first do nothing, start with [0 0] then start with [1 0],[1 1],[0 1],[-1 1],[-1 0],[-1 -1],[0 -1],[1 -1],[2 -1].[2 0] ..............}
          begin {start spiral around [0 0]}
            if ( (spiral_x = spiral_y) or ((spiral_x < 0) and (spiral_x = -spiral_y)) or ((spiral_x > 0) and (spiral_x = 1-spiral_y))) then {turning point}
            begin {swap dx by negative dy and dy by negative dx}
              spiral_t:=spiral_dx;
              spiral_dx := -spiral_dy;
              spiral_dy := spiral_t;
            end;
            spiral_x :=spiral_x+ spiral_dx;{walk through square}
            spiral_y :=spiral_y+ spiral_dy;{walk through square}
          end;{end spiral around [0 0]}
          {adapt search field to matrix position, +0+0/+1+0,+1+1,+0+1,-1+1,-1+0,-1-1,+0-1,+1-1..}


          dec_database:=STEP_SIZE*spiral_y+dec_radians;
          flip:=0;
          if dec_database>+pi/2 then  begin dec_database:=pi-dec_database; flip:=pi; end {crossed the pole}
          else
          if dec_database<-pi/2 then  begin dec_database:=-pi-dec_database; flip:=pi; end;


          if dec_database>0 then extra:=step_size/2 else extra:=-step_size/2;{use the distance furthest away from the pole}

          ra_database_offset:= (STEP_SIZE*spiral_x/cos(dec_database-extra));{step larger near pole. This ra_database is an offset from zero}
          if ((ra_database_offset<=+pi/2+step_size/2) and (ra_database_offset>=-pi/2)) then  {step_size for overlap}
          begin
            ra_database:=fnmodulo(flip+ra_radians+ra_database_offset,2*pi);{add offset to ra after the if statement! Otherwise no symmetrical search}
            ang_sep(ra_database,dec_database,ra_radians,dec_radians, {out}seperation);{calculates angular separation. according formula 9.1 old Meeus or 16.1 new Meeus, version 2018-5-23}

            //if solve_show_log then
            //begin
            //  memo2_message('Read database at: '+prepare_ra(ra_database,' ')+',  '+prepare_dec(dec_database,' '));
            //end;

            if seperation<=radius*pi/180+step_size/2 then {Use only the circular area withing the square area}
            begin
              {info reporting}
              if seperation*180/pi>distance+fov_org then {new distance reached. Update once in the square spiral, so not too often since it cost CPU time}
              begin
                distance:=seperation*180/pi;
                distancestr:=inttostr(round(seperation*180/pi))+'°';{show on stackmenu what's happening}

                stackmenu1.actual_search_distance1.caption:=distancestr;
                stackmenu1.caption:= 'Search distance:  '+distancestr;
                mainform1.caption:= 'Search distance:  '+distancestr;

                if commandline_execution then {command line execution}
                begin
                   {$ifdef CPUARM}
                   { tray icon  gives a fatal execution error in the old compiler for armhf}
                   {$else}
                   mainform1.TrayIcon1.hint:=distancestr+info_message;
                   {$endif}

                   if distance>2*fov_org then {prevent flash for short distance solving}
                   begin
                     if popupnotifier_visible=false then begin mainform1.popupnotifier1.visible:=true; popupnotifier_visible:=true; end; {activate only once}
                     mainform1.popupnotifier1.text:=distancestr+info_message;
                   end;
                end;
              end; {info reporting}

              {read nrstars_required stars from database. If search field is oversized, number of required stars increases with the power of the oversize factor. So the star density will be the same as in the image to solve}
              if match_nr=0  then
              begin
                oversize2:=oversize
              end
              else
                oversize2:=min(max_fov/fov2, max(oversize, sqrt(sqr(hd.width/hd.height)+sqr(1)))); //Use full image for solution for second solve but limit to one tile max to prevent tile selection problems.
              nrstars_required2:=round(nrstars_required*oversize2*oversize2); //nr of stars requested request from database

              //profiler_start;

              if read_stars(ra_database,dec_database,search_field*oversize2,database_type,nrstars_required2,{out} starlist1)= false then
              begin
                {$IFDEF linux}
                 //keep till 2026
                 if ((name_database='d50') and (dec_database>pi*(90-15)/180)) then //Files 3502,3503 and 3601.1476 had permission error. Star database fixed on 2023-11-27
                   application.messagebox(pchar('Star database file permission error near pole. Update the D50 database to correct !!'), pchar('ASTAP error:'),0)
                 else
                {$ENDIF}
                application.messagebox(pchar('No star database found at '+database_path+' !'+#13+'Download and install one star database.'), pchar('ASTAP error:'),0);
                errorlevel:=33;{read error star database}
                exit; {no stars}
              end;

              //profiler_log('Find_stars');


              //mod 2025 ###################################################
              if match_nr=1 then //2025 first solution found, filter out stars for the second match. Avoid that stars outside the image boundaries are used to create database quads
              begin //keep only stars which are visible in the image according the first solution
                count:=0;
                for i:=0 to Length(starlist1[0])-1  do
                begin
                  rotate(crota2,starlist1[0,i]/cdelt1,starlist1[1,i]/cdelt2,xi,yi);{rotate to screen orientation}
                  xi:=centerX-xi;
                  yi:=centerY-yi;
                  if ((xi>0) and (xi<hd.width) and (yi>0) and (yi<hd.height)) then //within image boundaries
                  begin
                    starlist1[0,count]:=starlist1[0,i];
                    starlist1[1,count]:=starlist1[1,i];
                    inc(count);
                  end;
                end;
                setlength(starlist1,2,count);
              end; //keep only stars visible in image
              //mod 2025 ###################################################

              //profiler_start(true);

              if yes_use_triples then
                find_triples_using_quads(starlist1,quad_star_distances1){find quads for reference image/database. Filter out too small quads for Earth based telescopes}
              else
                find_quads(false,starlist1, quad_star_distances1);{find quads for reference image/database.}

              //profiler_log('Find_quads1');

              if solve_show_log then {global variable set in find stars}
                memo2_message('Search '+ inttostr(count)+', ['+inttostr(spiral_x)+','+inttostr(spiral_y)+'],'+#9+'position: '+#9+ prepare_ra(ra_database,': ')+#9+prepare_dec(dec_database,'° ')+#9+' Down to magn '+ floattostrF(mag2/10,ffFixed,0,1) +#9+' '+inttostr(length(starlist1[0]))+' database stars' +#9+' '+inttostr(length(quad_star_distances1[0]))+' database quads to compare.'+mess);

              //profiler_start;

              // for testing purposes
              // for testing create supplement hnsky planetarium program
              //stackmenu1.memo2.lines.add(floattostr(ra_database*12/pi)+',,,'+floattostr(dec_database*180/pi)+',,,,'+inttostr(count)+',,-8,'+floattostr( step_size*600*180/pi)+',' +floattostr(step_size*600*180/pi));
              // stackmenu1.memo2.lines.add(floattostr(ra_database*12/pi)+',,,'+floattostr(dec_database*180/pi)+',,,,'+inttostr(count)+',,-99');

              //profiler_start(true);
              solution:=find_offset_and_rotation(minimum_quads {>=3},quad_tolerance);{find an solution}
              //profiler_log('Find_offset and rotation');

              // for testing purpose
              //equatorial_standard(ra_database,dec_database,hd.ra0,hd.dec0,1,correctionX,correctionY);{calculate correction for x,y position of database center and image center}
              //head.cdelt1:=-head.cdelt1;
              //head.cdelt2:=-head.cdelt2;
              //plot_stars_used_for_solving(correctionX,correctionY); {plot image stars and database stars used for the solution}
              //exit;

              Application.ProcessMessages;
              if esc_pressed then
              begin
                stackmenu1.Memo2.enablealign;{allow paint messages from other controls to update tmemo. Mod 2021-06-26}
                stackmenu1.Memo2.Lines.EndUpdate;
                Screen.Cursor:=crDefault;    { back to normal }
                exit;
              end;
            end;{within search circle. Otherwise the search is within a kind of square}
          end;{within RA range}

          inc(count);{step further in spiral}

        until ((solution) or (spiral_x>max_distance));{squared spiral search}

        if solution then
        begin
          centerX:=(hd.width-1)/2 ;{center image in 0..hd.width-1 range}
          centerY:=(hd.height-1)/2;{center image in 0..hd.height-1 range}

          standard_equatorial( ra_database,dec_database,
              (solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY) +solution_vectorX[2]), {x}
              (solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY) +solution_vectorY[2]), {y}
              1, {CCD scale}
              ra_radians ,dec_radians {put the calculated image center equatorial position into the start search position});
          //current_dist:=sqrt(sqr(solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY) +solution_vectorX[2]) + sqr(solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY) +solution_vectorY[2]))/3600; {current distance telescope and image center in degrees}

          //mod 2025 ############################################################
          if solution_vectorX[0]*solution_vectorY[1] - solution_vectorX[1]*solution_vectorY[0] >0 then // flipped?
          flipped_image:=-1 //change rotation for flipped image, {Flipped image. Either flipped vertical or horizontal but not both. Flipped both horizontal and vertical is equal to 180 degrees rotation and is not seen as flipped}
          else
          flipped_image:=+1;//not flipped

          // position +1 pixels in direction hd.crpix2
          standard_equatorial( ra_database,dec_database, (solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY+1) +solution_vectorX[2]), {x}
                                                         (solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY+1) +solution_vectorY[2]), {y}
                                                          1, {CCD scale}  ra7 ,dec7{equatorial position}); // the position 1 pixel away

          crota2:=-position_angle(ra7,dec7,ra_radians,dec_radians);//Position angle between a line from ra0,dec0 to ra1,dec1 and a line from ra0, dec0 to the celestial north . Rigorous method
          cdelt1:=flipped_image*sqrt(sqr(solution_vectorX[0])+sqr(solution_vectorX[1])); // unit arcsec
          cdelt2:=sqrt(sqr(solution_vectorY[0])+sqr(solution_vectorY[1])); //unit arcsec
          //mod 2025 ############################################################

          inc(match_nr);
        end
        else
        match_nr:=0;//This should not happen for the second solve but just in case

      until ((solution=false) {or (current_dist<fov2*0.05)}{within 5% if image height from center}  or (match_nr>=2));{Maximum accuracy loop. After match possible on a corner do a second solve using the found hd.ra0,hd.dec0 for maximum accuracy USING ALL STARS}

      stackmenu1.Memo2.enablealign;{allow paint messages from other controls to update tmemo. Mod 2021-06-26}
      stackmenu1.Memo2.Lines.EndUpdate;
    end; {enough quads in image}

  until ((autoFOV=false) or (solution) or (fov2<=fov_min)); {loop for autoFOV from 9.5 to 0.37 degrees. Will lock between 9.5*1.25 downto  0.37/1.25  or 11.9 downto 0.3 degrees}

  //memo2_message(plog);//write log of profiler


  if solution then
  begin
    hd.ra0:=ra_radians;//store solution in header
    hd.dec0:=dec_radians;
    hd.crpix1:=centerX+1;{center image in fits coordinate range 1..hd.width}
    hd.crpix2:=centery+1;

    ang_sep(ra_radians,dec_radians,ra_start,dec_start, sep_search);//calculate search offset

    memo2_message(inttostr(nr_references)+ ' of '+ inttostr(nr_references2)+quads_str+' selected matching within '+floattostr(quad_tolerance)+' tolerance.'  //  3 quads are required giving 3 center quad references}
                   +'  Solution["] x:='+floattostr6(solution_vectorX[0])+'x+ '+floattostr6(solution_vectorX[1])+'y+ '+floattostr6(solution_vectorX[2])
                   +',  y:='+floattostr6(solution_vectorY[0])+'x+ '+floattostr6(solution_vectorY[1])+'y+ '+floattostr6(solution_vectorY[2]) );
    //  following doesn't give maximum angle accuracy, so is not used.
    //    hd.cd1_1:= - solution_vectorX[0]/3600;{/3600, arcsec to degrees conversion}
    //    hd.cd1_2:= - solution_vectorX[1]/3600;
    //    hd.cd2_1:= + solution_vectorY[0]/3600;
    //    hd.cd2_2:= + solution_vectorY[1]/3600;


    hd.cdelt2:=cdelt2/3600; //convert from arc seconds to degrees
    hd.cdelt1:=cdelt1/3600; //convert from arc seconds to degrees

    // position 1*flipped_image  pixels in direction hd.crpix1
    standard_equatorial( ra_database,dec_database,(solution_vectorX[0]*(centerX+flipped_image) + solution_vectorX[1]*(centerY) +solution_vectorX[2]), {x} //A pixel_aspect_ratio unequal of 1 is very rare, none square pixels
                                                  (solution_vectorY[0]*(centerX+flipped_image) + solution_vectorY[1]*(centerY) +solution_vectorY[2]), {y}
                                                  1, {CCD scale} ra7 ,dec7{equatorial position});

    crota1:=pi/2-position_angle(ra7,dec7,hd.ra0,hd.dec0);//Position angle between a line from ra0,dec0 to ra1,dec1 and a line from ra0, dec0 to the celestial north . Rigorous method
    if crota1>pi then crota1:=crota1-2*pi;//keep within range -pi to +pi


    hd.cd1_1:=+hd.cdelt1*cos(crota1);
    hd.cd1_2:=-hd.cdelt1*sin(crota1)*flipped_image;
    hd.cd2_1:=+hd.cdelt2*sin(crota2)*flipped_image;
    hd.cd2_2:=+hd.cdelt2*cos(crota2);

    hd.crota2:=crota2*180/pi;//convert to degrees
    hd.crota1:=crota1*180/pi;


    solved_in:=' Solved in '+ floattostr(round((GetTickCount64 - startTick)/100)/10)+' sec.';{make string to report in FITS header.}

    offset_found:={' Δ was '}distance_to_string(sep_search {scale selection},sep_search)+'.';

    if ra_mount<99 then {mount position known and specified. Calculate mount offset}
    begin
      mount_ra_sep:=pi*frac((ra_mount-ra_radians)/pi) * cos((dec_mount+dec_radians)*0.5 {average dec});//total mount error. Only used for scaling
      mount_dec_sep:=dec_mount-dec_radians;
      mount_sep:=sqrt(sqr(mount_ra_sep)+sqr(mount_dec_sep));//mount_sep is only used for scaling}

      ra_offset_str:=distance_to_string(mount_sep, mount_ra_sep);
      dec_offset_str:=distance_to_string(mount_sep, mount_dec_sep);
      mount_offset_str:=' Mount offset RA='+ra_offset_str+', DEC='+dec_offset_str;{ascii}
      mount_info_str:=' Mount Δα='+ra_offset_str+ ',  Δδ='+dec_offset_str+'. '+#9;
    end
    else
    mount_info_str:='';{no mount info}

    memo2_message('Solution found: '+  prepare_ra8(hd.ra0,': ')+#9+prepare_dec2(hd.dec0,'° ') +#9+ solved_in+#9+' Δ was '+offset_found+#9+ mount_info_str+' Used stars down to magnitude: '+floattostrF(mag2/10,ffFixed,0,1) );
    mainform1.caption:=('Solution found:    '+  prepare_ra(hd.ra0,': ')+'     '+prepare_dec(hd.dec0,'° ')  );
    result:=true;

    memo.BeginUpdate;

    if ((stackmenu1.add_sip1.checked) and
      (add_sip(hd,memo,ra_database,dec_database))) then //takes about 50 ms sec due to the header update. Calculations are very fast
    begin //SIP added
      update_text(memo,'CTYPE1  =',#39+'RA---TAN-SIP'+#39+'       / TAN (gnomic) projection + SIP distortions      ');
      update_text(memo,'CTYPE2  =',#39+'DEC--TAN-SIP'+#39+'       / TAN (gnomic) projection + SIP distortions      ');
      mainform1.Polynomial1.itemindex:=1;//switch to sip
    end
    else
    begin //No SIP added.
      update_text(memo,'CTYPE1  =',#39+'RA---TAN'+#39+'           / first parameter RA,    projection TANgential   ');
      update_text(memo,'CTYPE2  =',#39+'DEC--TAN'+#39+'           / second parameter DEC,  projection TANgential   ');
    end;

    update_text(memo,'CUNIT1  =',#39+'deg     '+#39+'           / Unit of coordinates                            ');

    update_text(memo,'EQUINOX =','              2000.0 / Equinox of coordinates                         ');{the equinox is 2000 since the database is in 2000}

    update_float(memo,'CRPIX1  =',' / X of reference pixel                           ',false,hd.crpix1);
    update_float(memo,'CRPIX2  =',' / Y of reference pixel                           ',false ,hd.crpix2);

    update_float(memo,'CRVAL1  =',' / RA of reference pixel (deg)                    ',false ,hd.ra0*180/pi);
    update_float(memo,'CRVAL2  =',' / DEC of reference pixel (deg)                   ',false ,hd.dec0*180/pi);

    update_float(memo,'CDELT1  =',' / X pixel size (deg)                             ',false ,hd.cdelt1);
    update_float(memo,'CDELT2  =',' / Y pixel size (deg)                             ',false ,hd.cdelt2);

    update_float(memo,'CROTA1  =',' / Image twist X axis (deg)                       ',false ,hd.crota1);
    update_float(memo,'CROTA2  =',' / Image twist Y axis (deg) E of N if not flipped.',false ,hd.crota2);


    update_float(memo,'CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,hd.cd1_1);
    update_float(memo,'CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,hd.cd1_2);
    update_float(memo,'CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,hd.cd2_1);
    update_float(memo,'CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,hd.cd2_2);
    update_text(memo,'PLTSOLVD=','                   T / Astrometric solved by ASTAP v'+astap_version+'.       ');
    update_text(memo,'COMMENT 7', solved_in+' Offset '+offset_found+mount_offset_str);
    memo.EndUpdate;

    if solve_show_log then {global variable set in find stars}
    begin
      equatorial_standard(ra_database,dec_database,hd.ra0,hd.dec0,1,correctionX,correctionY);{calculate correction for x,y position of database center and image center}
      plot_stars_used_for_solving(starlist1,starlist2,hd,correctionX,correctionY); {plot image stars and database stars used for the solution}
      memo2_message('See viewer image for image stars used (red) and database star used (yellow)');
    end;

    if ( (fov_org>1.05*(hd.height*hd.cdelt2) ) or (fov_org<0.95*(hd.height*hd.cdelt2)) ) then    //in astap hd.cdelt2 is always positive. No need for absolute function
    begin
      if hd.xpixsz<>0 then suggest_str:='Warning inexact scale! Set FOV='+floattostrF(hd.height*hd.cdelt2,ffFixed,0,2)+'d or scale='+floattostrF(hd.cdelt2*3600,ffFixed,0,1)+'"/pix or FL='+inttostr(round((180/(pi*1000)*hd.xpixsz/hd.cdelt2)) )+'mm '
                      else suggest_str:='Warning inexact scale! Set FOV='+floattostrF(hd.height*hd.cdelt2,ffFixed,0,2)+'d or scale='+floattostrF(hd.cdelt2*3600,ffFixed,0,1)+'"/pix ';
      memo2_message(suggest_str);
      warning_str:=suggest_str+warning_str;
    end;
  end
  else
  begin
    memo2_message('No solution found!  :(');
    mainform1.caption:='No solution found!  :(';
    update_text(memo,'PLTSOLVD=','                   F / No plate solution found.   ');
    remove_key(memo,'COMMENT 7',false{all});
  end;

  warning_str:=warning_str + warning_downsample; {add the last warning from loop autoFOV}
  if warning_str<>'' then
  begin
    update_longstr(memo,'WARNING =',warning_str);{update or insert long str including single quotes}
    memo2_message(warning_str);
  end;

  Screen.Cursor:=crDefault;    { back to normal }
end;


begin
end.
