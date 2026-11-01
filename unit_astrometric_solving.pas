unit unit_astrometric_solving;
{Copyright (C) 2017-2026 by Han Kleijn, www.hnsky.org
email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

//  This source code is available at:
// Master:
//   https://sourceforge.net/p/astap-program/
// Irregularly updated:
//   https://github.com/han-k59/astap


{ASTAP is using a linear astrometric solution for both stacking and solving.  The method is based on what is traditionally is called "reducing the plate measurements.
The first step is to find star matches between a test image and a reference image. The reference image is either created from a star database or from another reference image.
The star positions x, y are to be calculated in standard coordinates which are equivalent to the x,y pixel positions. The x,y positions are measured relative to the image center.

The test image center, size and orientation position will be different compared with the reference image. The required conversion from reference image [x,y] star positions to the
same stars on the test image can be written as:

Xref : = a*xtest + b*ytest + c
Yref:=   d*xtest + e*ytest + f

The factors, a,b,c,d,e,f are called the six plate constants and will be slightly different different for each star. They describe the conversion of  the test image standard coordinates
to the reference image standard coordinates. Using a least squares routine the best solution fit can be calculated if at least three matching star positions are found.

With the solution and the equatorial center position of the reference image the test image center equatorial position, α and δ can be calculated.

Making from the test image center small one pixel steps in x and y and using the differences in α, δ to calculate the image scale and orientation.

For astrometric solving (plate solving), this "reducing the plate measurement" is done against star positions extracted from a database. The resulting absolute astrometric solution
will allow specification of the α, δ equatorial positions of each pixel. For star alignment this "reducing the plate measurement" is done against the reference image. The resulting
six plate constants are a relative astrometric solution. The position of the reference image is not required. Pixels of the solved image can be stacked with reference image using
the six plate constants only.

To automate this process rather than using reference stars the matching reference objects are the center positions of quads made of four close stars. Comparing the length ratios
of the sides of the quads allows automated matching.

Below is a brief flowchart of the ASTAP astrometric solving process:
}

//                                                  =>ASTAP  astronomical plate solving method by Han Kleijn <=

//      => Image <=                                                             |  => Star database <=
//1)   Find background, noise and star level                                    |
//                                                                              |
//2)   Find stars and their CCD x, y position (standard coordinates)            | Extract the same amount of stars (area corrected) from the area of interest
//                                                                              | Convert the α, δ equatorial coordinates into standard coordinates
//                                                                              | (CCD pixel x,y coordinates for optical projection), rigid method

//3)   Use the extracted stars to construct the smallest irregular tetrahedrons | Use the extracted stars to construct the smallest irregular tetrahedrons
//      figures of four stars called quads. Calculate the six distance between  | figures of four stars called quads. Calculate the six distance between
//      the four stars and the mean x,y position of the quad                    | the four stars and the mean x,y position of the quad
//                                                                              |
//4)   For each quad sort the six quad distances.                               | For each quad sort the six quad distances.
//      Label them all where d1 is the longest and d6 the shortest distance.    | Label them all where d1 is the longest and d6 the shortest distance.
//                                                                              |
//5)   Scale the six quad star distances as (d1, d2/d1,d3/d1,d4/d1,d5/d1,d6/d1) | Scale the six quad star distances as (d1, d2/d1,d3/d1,d4/d1,d5/d1,d6/d1)
//      These are the image hash codes.                                         | These are the database hash codes.

//                           => matching process <=
//6)                         Find quad hash code matches where the five ratios d2/d1 to d6/d1 match within a small tolerance.

//7)                  For matching quad hash codes, calculate the longest side ratios d1_found/d1_reference. Calculate the median ratio.
//                           Compare the quad's longest side ratios with the median value and remove quads outside a small tolerance.

//8)                         From the remaining matching quads, prepare the "A" matrix/array containing the x,y center positions of the test image quads in standard coordinates
//                           and  the array X_ref, Y_ref containing the x, y center positions of the reference image tetrahedrons in standard coordinates.

//                           A:                  Sx:         X_ref:
//                           [x1 y1  1]          [a1]         [X1]
//                           [x2 y2  1]    *     [b1]    =    [X2]
//                           [x3 y3  1]          [c1]         [X3]
//                           [x4 y4  1]                       [X4]
//                           [.. .. ..]                       [..]
//                           [xn yn  1]                       [Xn]


//                           A:                  Sx:         Y_ref:
//                           [x1 y1  1]          [a2]         [Y1]
//                           [x2 y2  1]    *     [b2]    =    [Y2]
//                           [x3 y3  1]          [c2]         [Y3]
//                           [x4 y4  1]                       [Y4]
//                           [.. .. ..]                       [..]
//                           [xn yn  1]                       [Yn]

//                           Find the solution matrices Sx and Sy of this overdetermined system of linear equations. (LSQ_FIT)

//                           The solutions Sx and Sy describe the six parameter solution, X_ref:=a1*x + b1*y + c1 and Y_ref:=a2*x + b2*y +c2.


//                           With the solution calculate the test image center equatorial position α (crval1), δ (crval2).

//                           Calculate from the solution the pixel size in x (cdelt1) and y (cdelt2) and at the image center position the rotation of the x-axis (crota1)
//                           and y-axis (crota2) relative to the celestial north using goniometric formulas. Convert these to cd1_1,cd1_2,cd_2_1, cd2_2.

//                           This is the final solution. The solution vector (for position, scale, rotation) can be stored as the FITS keywords crval1, crval2, cd1_1,cd1_2,cd_2_1, cd2_2.

// Notes:
// For a low faint star count (<30) the star patterns can be slightly different between image and database due to small magnitude differences.
// For these cases it can be beneficial to extract triples (three stars patterns) from the found quads (four star patterns) but stricter tolerances are required to avoid false detections.


interface

uses  Classes, SysUtils, Controls, Forms, Math, StdCtrls,
      unit_star_align, unit_star_database, astap_main, unit_stack, unit_annotation, unit_stars_wide_field, unit_calc_trans_cubic, unit_profiler,unit_contour;

function solve_image(img: Timage_array; var hd: Theader; memo: TStrings; const ra_start,dec_start:double; get_hist{update hist}, check_patternfilter: boolean): boolean; {find match between image and star database}
procedure bin_and_find_stars(img: Timage_array; var head: theader; binfactor: integer; cropping, hfd_min: double; max_stars: integer; get_hist{update hist}: boolean; out starlist3: Tstar_list; out mean_hfd: double;  out short_warning: string);{bin, measure background, find stars}
function report_binning(Height: double): integer;{select the binning}
function position_angle(ra1, dec1, ra0, dec0: double): double;//Position angle of a body at ra1,dec1 as seen at ra0,dec0. Rigorous method
procedure equatorial_standard(ra0, dec0, ra, Dec, cdelt: double; out xx, yy: double);
function read_stars(telescope_ra, telescope_dec, search_field: double; database_type, nrstars_required: integer; out starlist: Tstar_list): boolean;{read star from star database}
procedure bin_mono_and_crop(var binning: integer; crop {0..1}: double; img: Timage_array; out img2: Timage_array); // Make mono, bin and crop


var
  star1: array[0..2] of array of single;
threadvar
  mag2: double; {magnitude of star found. Every thread of the spiral search has its own copy, solve_image copies the value of the solution to the main thread}

implementation

uses
  unit_mtpcpu;{GetSystemCoreCount}

threadvar
  wide_pinned       : boolean;       {set in the worker threads of the spiral search. read_stars then uses pinned_wide_stars}
  pinned_wide_stars : array of single;{the wide field stars of the spiral search, see search_worker}

function distance_to_string(dist, inp: double): string; {angular distance to string intended for RA and DEC. Unit is based on dist}
begin
  if abs(dist) < pi / (180 * 60) then {unit seconds}
    Result := floattostrF(inp * 3600 * 180 / pi, ffFixed, 0, 1) + '"'
  else
  if abs(dist) < pi / 180 then {unit minutes}
    Result := floattostrF(inp * 60 * 180 / pi, ffFixed, 0, 1) + #39
  else
    Result := floattostrF(inp * 180 / pi, ffFixed, 0, 1) + 'd'; {° symbol is converted to unicode by tmemo}
end;


function position_angle(ra1, dec1, ra0, dec0: double): double;
  //Position angle between a line from ra0,dec0 to ra1,dec1 and a line from ra0, dec0 to the celestial north . Rigorous method
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
  sinDeltaRa, cosDeltaRa, sinDec0, cosDec0, sinDec1, cosDec1: double;
begin
  sincos(ra1 - ra0, sinDeltaRa, cosDeltaRa);
  sincos(dec0, sinDec0, cosDec0);
  sincos(dec1, sinDec1, cosDec1);
  Result := arctan2(cosDec1 * sinDeltaRa, sinDec1 * cosDec0 - cosDec1 * sinDec0 * cosDeltaRa);
end;


{transformation of equatorial coordinates into CCD pixel coordinates for optical projection, rigid method}
{head.ra0,head.dec0: right ascension and declination of the optical axis}
{ra,dec:   right ascension and declination}
{xx,yy :   CCD coordinates}
{cdelt:    CCD scale in arcsec per pixel}
procedure equatorial_standard(ra0, dec0, ra, Dec, cdelt: double; out xx, yy: double);
var
  dv, sin_dec0, cos_dec0, sin_dec, cos_dec, sin_deltaRA, cos_deltaRA: double;
begin
  sincos(dec0, sin_dec0, cos_dec0);
  sincos(Dec, sin_dec, cos_dec);
  sincos(ra - ra0, sin_deltaRA, cos_deltaRA);
  dv := (cos_dec0 * cos_dec * cos_deltaRA + sin_dec0 * sin_dec) * cdelt / (3600 * 180 / pi); {cdelt/(3600*180/pi), factor for conversion standard coordinates to CCD pixels}
  xx := -cos_dec * sin_deltaRA / dv;{tangent of the angle in RA}
  yy := -(sin_dec0 * cos_dec * cos_deltaRA - cos_dec0 * sin_dec) / dv;{tangent of the angle in DEC}
end;


{transformation from CCD coordinates into equatorial coordinates}
{ra0, dec0: right ascension and declination of the optical axis       }
{x,y     : CCD coordinates                                           }
{cdelt:  : scale of CCD pixel in arc seconds                         }
{ra,dec  : right ascension and declination                           }
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

{$INLINE ON}
{transformation from CCD coordinates into equatorial coordinates}
{ra0,dec0: right ascension and declination of the optical axis       }
{x,y     : CCD coordinates                                           }
{cdelt:  : scale of CCD pixel in arc seconds                         }
{ra,dec  : right ascension and declination                           }
procedure standard_equatorial(ra0, dec0, x, y, cdelt: double; out ra, Dec: double); inline;{transformation from CCD coordinates into equatorial coordinates}
var
  sin_dec0, cos_dec0, delta: double;
begin
  sincos(dec0, sin_dec0, cos_dec0);
  x := x * cdelt / (3600 * 180 / pi);//scale CCD pixels to standard coordinates (tang angle)
  y := y * cdelt / (3600 * 180 / pi);

  delta := cos_dec0 - y * sin_dec0;
  ra := ra0 + arctan2(-x, delta); //atan2 is required for images containing celestial pole
  Dec := arctan((sin_dec0 + y * cos_dec0) / sqrt(sqr(x) + sqr(delta)));
  if ra > pi * 2 then ra := ra - pi * 2;  //prevent values above 2*pi which confuses the direction detection later
  if ra < 0 then ra := ra + pi * 2;
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


function read_stars(telescope_ra, telescope_dec, search_field: double; database_type, nrstars_required: integer; out starlist: Tstar_list): boolean;{read star from star database}
{Called by the threads of the spiral search. Uses only the star database reader of the calling thread and the threadvar mag2}
var
  B_V, ra2, dec2, frac1, frac2, frac3, frac4, sep: double;
  nrstars, area1, area2, area3, area4, nrstars_required2, Count: integer;
  reader : pointer;{the star database reader of this thread}
  m2     : double; {magnitude, local copy of the threadvar mag2}
  wide   : array of single;{the wide field stars. An own reference, so the array stays valid while it is read}
begin
  Result := False;{assume failure}
  database_read_error := False;{set by the database reader if a tile can not be read}
  nrstars := 0;{set counters at zero}
  ra2 := 0; {define ra2 value. Prevent ra2 = -nan(0xffffffffffde9) run time failure when first header record is read}

  SetLength(starlist, 2, nrstars_required);{set array length}

  if database_type > 1 then {1476 or 290 files}
  begin
   {Assume the search field is at a crossing of four tiles. The search field area, by definition 100% is split in 8%, 15%, 20%, 57% area for each tile.
    There are 500 stars required. It will then retrieve 8% x 500, 15% x 500, 20% x 500, 57% x 500 stars from each tile under the condition these stars are within the green area.
    This will work assuming the star density within the green area is reasonable homogene.}
    reader := star_database_reader;{look up the threadvars once, not for every star}
    m2 := mag2;
    find_areas(telescope_ra, telescope_dec, search_field,{var} area1, area2, area3, area4, frac1, frac2, frac3, frac4);{find up to four star database areas for the square image}

    if area1 <> 0 then {read 1th area}
    begin
      if open_database(telescope_dec, area1) = False then
        exit;{open database file or reset buffer}
      nrstars_required2 := min(nrstars_required, trunc(nrstars_required * frac1));
      while ((nrstars < nrstars_required2) and (readdatabase1476_reader(reader, telescope_ra, telescope_dec, search_field, {var} ra2, dec2, m2, B_V))) do {star 290 file database read. Read up to nrstars_required}
      begin {add star}
        equatorial_standard(telescope_ra, telescope_dec, ra2, dec2, 1, starlist[0, nrstars]{x}, starlist[1, nrstars]{y});{store star CCD x,y position}
        Inc(nrstars);
      end;
    end;

    if area2 <> 0 then {read 2th area}
    begin
      if open_database(telescope_dec, area2) = False then
        exit; {open database file or reset buffer}
      nrstars_required2 := min(nrstars_required, trunc(nrstars_required * (frac1 + frac2)));
      {prevent round up errors resulting in error starlist}
      while ((nrstars < nrstars_required2) and (readdatabase1476_reader(reader, telescope_ra, telescope_dec, search_field, {var} ra2, dec2, m2, B_V))) do {star 290 file database read. Read up to nrstars_required}
      begin {add star}
        equatorial_standard(telescope_ra, telescope_dec, ra2, dec2, 1, starlist[0, nrstars]{x}, starlist[1, nrstars]{y});{store star CCD x,y position}
        Inc(nrstars);
      end;
    end;

    if area3 <> 0 then {read 3th area}
    begin
      if open_database(telescope_dec, area3) = False then
        exit; {open database file or reset buffer}
      nrstars_required2 := min(nrstars_required, trunc(nrstars_required * (frac1 + frac2 + frac3)));
      while ((nrstars < nrstars_required2) and (readdatabase1476_reader(reader, telescope_ra, telescope_dec, search_field, {var} ra2, dec2, m2, B_V))) do {star 290 file database read. Read up to nrstars_required}
      begin {add star}
        equatorial_standard(telescope_ra, telescope_dec, ra2, dec2, 1, starlist[0, nrstars]{x}, starlist[1, nrstars]{y});{store star CCD x,y position}
        Inc(nrstars);
      end;
    end;

    if area4 <> 0 then {read 4th area}
    begin
      if open_database(telescope_dec, area4) = False then
        exit; {open database file}
      nrstars_required2 := min(nrstars_required, trunc(nrstars_required *(frac1 + frac2 + frac3 + frac4)));
      while ((nrstars < nrstars_required2) and (readdatabase1476_reader(reader, telescope_ra, telescope_dec, search_field, {var} ra2, dec2, m2, B_V))) do{star 290 file database read. Read up to nrstars_required}
      begin {add star}
        equatorial_standard(telescope_ra, telescope_dec, ra2, dec2, 1, starlist[0, nrstars]{x}, starlist[1, nrstars]{y});{store star CCD x,y position}
        Inc(nrstars);
      end;
    end;
    mag2 := m2;{magnitude reached}
  end
  else
  begin {wide field database, database_type=1}
    if wide_pinned then
      wide := pinned_wide_stars {worker thread of the spiral search, see search_worker. Do not read the globals, the main thread may change them meanwhile}
    else
    begin
      if wide_database <> name_database then read_stars_wide_field; {load wide field stars array}
      if wide_database <> name_database then exit;{2026 fix: the file could not be read}
      wide := wide_field_stars;
    end;
    if length(wide) < 3 then exit;{2026 fix: no stars. Before, wide_field_stars[-3] was read below}
    Count := 0;
    cos_telescope_dec := cos(telescope_dec);
    while ((nrstars < nrstars_required) and (Count < length(wide) div 3)) do{star 290 file database read. Read up to nrstars_required}
    begin
      ra2 := wide[Count * 3 + 1];  {contains: mag1, ra1,dec1, mag2,ra2,dec2,mag3........}
      dec2 := wide[Count * 3 + 2];
      ang_sep(ra2, dec2, telescope_ra, telescope_dec, sep); {angular seperation. Required for large field of view around the pole. Can not use simple formulas anymore}
      if ((sep < search_field * 0.5 * 0.9 * (2 / sqrt(pi))) and (sep < pi / 2)) then {factor 2/sqrt(pi) is to adapt circle search field to surface square. Factor 0.9 is a fiddle factor for trees, house and dark corners. Factor <pi/2 is the limit for procedure equatorial_standard}
      begin
        equatorial_standard(telescope_ra, telescope_dec, ra2, dec2, 1, starlist[0, nrstars]{x}, starlist[1, nrstars]{y});{store star CCD x,y position}
        Inc(nrstars);
      end;
      Inc(Count);
    end;
    mag2 := wide[(Count - 1) * 3];{for reporting of highest magnitude used for solving}
  end;
  //  memo2_message('testareas'+#9+floattostr4(telescope_ra*12/pi)+#9+floattostr4(telescope_dec*180/pi)+#9+inttostr(maga)+#9+inttostr(magb)+#9+inttostr(magc)+#9+inttostr(magd)+#9+floattostr4(frac1)+#9+floattostr4(frac2)+#9+floattostr4(frac3)+#9+floattostr4(frac4)+#9+inttostr(area1)+#9+inttostr(area2)+#9+inttostr(area3)+#9+inttostr(area4));

  if database_read_error then exit;{a tile could not be read completely. A shorter star list would give a different or no solution, so report a failure}

  if nrstars < nrstars_required then
    SetLength(starlist, 2, nrstars); {fix array length on data for case less stars are found}
  Result := True;{no errors}

  //for testing
  //  equatorial_standard(telescope_ra,telescope_dec,head.ra0,head.dec0,1,correctionX,correctionY);{calculate correction for x,y position of database center and image center}
  //  plot_stars_used_for_solving(correctionX,correctionY); {plot image stars and database stars used for the solution}
end;


procedure bin_mono_and_crop(var binning: integer; crop {0..1}: double; img: Timage_array; out img2: Timage_array);// Make mono, bin and crop
var
  fitsX, fitsY, k, w, h, shiftX, shiftY, nrcolors, width5, height5, i, j, x, y: integer;
  val: single;
begin
  nrcolors := Length(img);
  width5 := Length(img[0, 0]);{width}
  height5 := Length(img[0]); {height}

  w := trunc(crop * width5 / binning);  {dimensions after binning and crop}
  h := trunc(crop * height5 / binning);

  try
    setlength(img2, 1, h, w); {set length of image array}
  except
    img2:=img;//panic, not enough memory, try without binning
    binning:=1;
    memo2_message('Not enough memory for binning!');
    warning_str:='Not enough memory for binning!'; //for command line usage
    exit;
  end;

  shiftX := round(width5 * (1 - crop) / 2); {crop is 0.9, shift is 0.05*head.width}
  shiftY := round(height5 * (1 - crop) / 2); {crop is 0.9, start at 0.05*head.height}

  if binning = 1 then
  begin
    for fitsY := 0 to h - 1 do
      for fitsX := 0 to w - 1 do
      begin
        val := 0;
        for k := 0 to nrcolors - 1 do {all colors and make mono}
          val := val + img[k, shiftY + fitsY, shiftX + fitsx];
        img2[0, fitsY, fitsX] := val / nrcolors;
      end;
  end
  else
  if binning = 2 then
  begin
    for fitsY := 0 to h - 1 do
      for fitsX := 0 to w - 1 do
      begin
        val := 0;
        for k := 0 to nrcolors - 1 do {all colors}
          val := val + (img[k, shiftY + fitsY * 2, shiftX + fitsX * 2] +
            img[k, shiftY + fitsY * 2 + 1, shiftX + fitsX * 2] +
            img[k, shiftY + fitsY * 2, shiftX + fitsX * 2 + 1] +
            img[k, shiftY + fitsY * 2 + 1, shiftX + fitsX * 2 + 1]) / 4;
        img2[0, fitsY, fitsX] := val / nrcolors;
      end;
  end
  else
  if binning = 3 then
  begin
    for fitsY := 0 to h - 1 do {bin & mono image}
      for fitsX := 0 to w - 1 do
      begin
        val := 0;
        for k := 0 to nrcolors - 1 do {all colors}
          val := val + (img[k, shiftY + fitsY * 3, shiftX + fitsX * 3] +
            img[k, shiftY + fitsY * 3, shiftX + fitsX * 3 + 1] +
            img[k, shiftY + fitsY * 3, shiftX + fitsX * 3 + 2] +
            img[k, shiftY + fitsY * 3 + 1, shiftX + fitsX * 3] +
            img[k, shiftY + fitsY * 3 + 1, shiftX + fitsX * 3 + 1] +
            img[k, shiftY + fitsY * 3 + 1, shiftX + fitsX * 3 + 2] +
            img[k, shiftY + fitsY * 3 + 2, shiftX + fitsX * 3] +
            img[k, shiftY + fitsY * 3 + 2, shiftX + fitsX * 3 + 1] +
            img[k, shiftY + fitsY * 3 + 2, shiftX + fitsX * 3 + 2]) / 9;
        img2[0, fitsY, fitsX] := val / nrcolors;
      end;
  end
  else
  if binning = 4 then
  begin
    for fitsY := 0 to h - 1 do //bin & mono image
      for fitsX := 0 to w - 1 do
      begin
        val := 0;
        for k := 0 to nrcolors - 1 do
          //all colors to mono. Test shows this loop doesn't introduce much delay for mono images
          val := val + (img[k, shiftY + fitsY * 4, shiftX + fitsX * 4] +
            img[k, shiftY + fitsY * 4, shiftX + fitsX * 4 + 1] +
            img[k, shiftY + fitsY * 4, shiftX + fitsX * 4 + 2] +
            img[k, shiftY + fitsY * 4, shiftX + fitsX * 4 + 3] +
            img[k, shiftY + fitsY * 4 + 1, shiftX + fitsX * 4] +
            img[k, shiftY + fitsY * 4 + 1, shiftX + fitsX * 4 + 1] +
            img[k, shiftY + fitsY * 4 + 1, shiftX + fitsX * 4 + 2] +
            img[k, shiftY + fitsY * 4 + 1, shiftX + fitsX * 4 + 3] +
            img[k, shiftY + fitsY * 4 + 2, shiftX + fitsX * 4] +
            img[k, shiftY + fitsY * 4 + 2, shiftX + fitsX * 4 + 1] +
            img[k, shiftY + fitsY * 4 + 2, shiftX + fitsX * 4 + 2] +
            img[k, shiftY + fitsY * 4 + 2, shiftX + fitsX * 4 + 3] +
            img[k, shiftY + fitsY * 4 + 3, shiftX + fitsX * 4] +
            img[k, shiftY + fitsY * 4 + 3, shiftX + fitsX * 4 + 1] +
            img[k, shiftY + fitsY * 4 + 3, shiftX + fitsX * 4 + 2] +
            img[k, shiftY + fitsY * 4 + 3, shiftX + fitsX * 4 + 3]) / 16;
        img2[0, fitsY, fitsX] := val / nrcolors; //mono result
      end;

  end
  else
  begin //any bin factor. This routine is at bin 4x4 about twice slower then the above routine
    for fitsY := 0 to h - 1 do
      for fitsX := 0 to w - 1 do
      begin
        val := 0;
        x := shiftX + fitsX * binning;
        y := shiftY + fitsY * binning;
        for k := 0 to nrcolors - 1 do
          {all colors to mono. Test shows this loop doesn't introduce much delay for mono images}
        begin
          for i := 0 to binning - 1 do
            for j := 0 to binning - 1 do
              val := val + img[k, y + i, x + j];
        end;
        img2[0, fitsY, fitsX] := val / (nrcolors * sqr(binning)); //mono result
      end;
  end;
end;


procedure convert_image_to_new_mono_image(var img: Timage_array; out img_mono :Timage_array);//convert colour image to a new mono image
var
   fitsX,fitsY,width2,height2: integer;
begin
  if length(img)<3 then exit;{prevent run time error mono images}
  height2:=length(img[0]);
  width2:=length(img[0,0]);
  memo2_message('Creating a mono duplicate for star detection.');
  setlength(img_mono,1,height2,width2);{set length of image array mono}

  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
      img_mono[0,fitsY,fitsX]:=(img[0,fitsY,fitsX]+img[1,fitsY,fitsX]+img[2,fitsY,fitsX])/3;
end;


procedure bin_and_find_stars(img: Timage_array; var head: theader; binfactor: integer; cropping, hfd_min: double; max_stars: integer;  get_hist{update hist}: boolean; out starlist3: Tstar_list; out mean_hfd: double; out short_warning: string);{bin, measure background, find stars}
var
  width5, height5, nrstars, i: integer;
  img_binned                : Timage_array;
begin
  short_warning := '';{clear string}

  width5 := length(img[0, 0]);{width}
  height5 := length(img[0]);{height}


  if ((binfactor > 1) or (cropping < 1)) then
  begin
    if binfactor > 1 then memo2_message('Creating grayscale x ' + IntToStr(binfactor) + ' binning image for solving or star alignment.');
    if cropping <> 1 then memo2_message('Cropping image x ' + floattostrF(cropping, ffFixed, 0, 2));

    bin_mono_and_crop(binfactor, cropping, img, img_binned); //{Make mono, bin and crop}

    {test routine, to show bin result}
    //    img_loaded:=img_binned;
    //    head.naxis3:=1;
    //    head.width:=length(img_binned[0,0]);
    //    head.height:=length(img_binned[0]);
    //    plot_image(mainform1.image1,true,true);//plot real
    //    exit;  }


    get_background(0, img_binned, head, max_stars,True {calc hist}, True {calculate also standard deviation background});{get back ground}


    find_stars(img_binned, head, hfd_min, max_stars, starlist3, mean_hfd); {find stars of the image and put them in a list}
    mean_hfd:=mean_hfd*binfactor;//correct for binning

//    profiler_start;
//    find_stars(img_binned, head, hfd_min, max_stars, starlist3, mean_hfd); {find stars of the image and put them in a list}
//    profiler_log('time used');
//    memo2_message(plog);

    if ((length(img_binned[0]) < 960) and  (stackmenu1.downsample_for_solving1.Text <> '0'){auto}) then
    begin
      short_warning := 'Warning, remaining image dimensions too low! '; {for FITS header and solution. Dimensions should be equal or better the about 1280x960}
      memo2_message('█ █ █ █ █ █ Warning, remaining image dimensions too low! Try to REDUCE OR REMOVE DOWNSAMPLING. Set this option in stack menu, tab alignment.');
    end;

    nrstars := Length(starlist3[0]);
    for i := 0 to nrstars - 1 do {correct star positions for binning and cropping. Simplest method}
    begin
      starlist3[0, i] := (binfactor - 1) * 0.5 + starlist3[0, i] * binfactor + (width5 * (1 - cropping) / 2);  //correct star positions for binfactor/ cropping. Position [3.5,3,5] becomes after 2x2 binfactor [1,1] after x2 [3,3]. So correct for 0.5 pixel
      starlist3[1, i] := (binfactor - 1) * 0.5 + starlist3[1, i] * binfactor + (height5 * (1 - cropping) / 2);
      // For zero based indexing:
      // A star of 2x2 pixels at position [2.5,2.5] is after 2x2 binfactor at position [1,1]. If doubled to [2,2] then the position has 0.5 pixel shifted.
      // A star of 3x3 pixels at position [4,4] is after 3x3 binfactor at position [1,1]. If tripled to [3,3] then the position has 1.0 pixel shifted.
      // A star of 4x4 pixels at position [5.5,5.5] is after 4x4 binfactor at position [1,1]. If quadruped to [4,4] then the position has 1.5 pixel shifted.
      // So positions measured in a binned image should be corrected as x:=(binfactor-1)*0.5+binfactor*x and y:=(binfactor-1)*0.5+binfactor*y
    end;
  end
  else
  begin
    if ((height5 > 2500) and (stackmenu1.downsample_for_solving1.Text <> '0'){auto}) then
    begin
      short_warning := 'Warning, increase downsampling!! '; {for FITS header and solution}
      memo2_message('Info: DOWNSAMPLING IS RECOMMENDED FOR LARGE IMAGES. Set this option in stack menu, tab alignment.');
    end
    else
    if height5 < 960 then
    begin
      short_warning := 'Warning, small image dimensions! ';{for FITS header and solution. Dimensions should be equal or better the about 1280x960}
      memo2_message('█ █ █ █ █ █ Warning, small image dimensions!');
    end;

    if length(img)>=3 then //colour to mono, equalise background
    begin
      if duplicate(img,img_binned)=false then exit;//work with img_binned to protect the orginal image
      if length(img)>=3 then convert_image_to_new_mono_image(img,img_binned);

      if stackmenu1.star_trails_as_stars1.checked=false then
      begin
        get_background(0, img_binned, head, max_stars,true {calc hist}, True {calculate also standard deviation background});{get back ground}
        find_stars(img_binned, head, hfd_min, max_stars, starlist3, mean_hfd);
      end
      else
         trail(commandline_execution=false{plot}, img,head,strtofloat2(stackmenu1.contour_gaussian1.text),strtofloat2(stackmenu1.contour_sigma1.text),starlist3);
    end
    else //no change applied to the image
    begin
      if stackmenu1.star_trails_as_stars1.checked=false then
      begin
        get_background(0, img, head, max_stars,get_hist {calc hist}, True {calculate also standard deviation background});{get back ground}
        find_stars(img, head, hfd_min, max_stars, starlist3, mean_hfd) {find stars of the image and put them in a list}
      end
      else
         trail(commandline_execution=false{plot}, img,head,strtofloat2(stackmenu1.contour_gaussian1.text),strtofloat2(stackmenu1.contour_sigma1.text),starlist3);
    end;
  end;
  //  for i:=0 to length(starlist3[0])-1 do
  //          log_to_file('d:\temp\referenceA1.txt',floattostr(starlist3[0,i])+', '+floattostr(starlist3[1,i]));

end;


function report_binning_astrometric(Height, arcsec_per_px: double): integer;{select the binning}
begin
  Result := strtoint2(stackmenu1.downsample_for_solving1.Text, 0);
  if Result <= 0 then  {zero gives -1, Auto is 0}
  begin //auto
    if Height > 2500 then
      Result := 2
    else
      Result := 1;
    Result := max(Result, round(1.5 / arcsec_per_px)); //pixelscale should be larger then 1"/px
  end;
  Result := min(16, Result);//16 max. Too much anyhow
end;


function report_binning(Height: double): integer;{select the binning}
begin
  Result := min(16, strtoint2(stackmenu1.downsample_for_solving1.Text, 0)); //16 max. Too much anyhow
  if Result <= 0 then  {zero gives -1, Auto is 0}
  begin
    if Height > 2500 then Result := 2
    else
      Result := 1;
  end;
end;

procedure create_grid_list(width2, height2, nrpoints: integer; out grid_list: TStarArray);// Create list of nbpoints x nbpoints positions in the image  equally spread. Positions relative to the image center.
var
  middleX, middleY: double;
  s, x, y, counter: integer;
begin
  middleX := width2 / 2;
  middleY := height2 / 2;
  setlength(grid_list, nrpoints * nrpoints);
  counter := 0;
  for y := 0 to nrpoints - 1 do
  begin
    for x := 0 to nrpoints - 1 do
    begin
      grid_list[counter].x := -middleX + x * width2 / (nrpoints - 1);
      grid_list[counter].y := -middleY + y * height2 / (nrpoints - 1);
      Inc(counter);
    end;
  end;
end;


function add_sip(hd: Theader; memo: TStrings; ra_database, dec_database: double): boolean;
var
  stars_measured, stars_reference: TStarArray;
  trans_sky_to_pixel, trans_pixel_to_sky: Ttrans;
  len, i: integer;
  succ: boolean;
  err_mess: string;
  ra_t, dec_t, SIN_dec_t, COS_dec_t, SIN_dec_ref, COS_dec_ref, det,
  delta_ra, SIN_delta_ra, COS_delta_ra, H, dRa, dDec: double;
begin
  Result := True;// assume success

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

  len := length(b_Xrefpositions);
  if len < 20 then
  begin
    memo2_message('Not enough quads for calculating SIP.');
    exit(False);
  end;
  setlength(stars_measured, len);
  setlength(stars_reference, len);

  sincos(hd.dec0, SIN_dec_ref, COS_dec_ref);{ For 5. Conversion (RA,DEC) -> x,y image in fits range 1..max}

  for i := 0 to len - 1 do
  begin
    stars_measured[i].x := 1 + A_XYpositions[0, i] - hd.crpix1; //position as seen from center at crpix1, crpix2, in fits range 1..width
    stars_measured[i].y := 1 + A_XYpositions[1, i] - hd.crpix2;

    standard_equatorial(ra_database, dec_database,
                        b_Xrefpositions[i], {x reference star}
                        b_Yrefpositions[i], {y reference star}
                        1, {CCD scale}
                        ra_t, dec_t); //calculate back to the reference star positions


    {5. Conversion (RA,DEC) -> x,y image in fits range 1..max}
    sincos(dec_t, SIN_dec_t, COS_dec_t);
    //  sincos(hd.dec0,SIN_dec_ref,COS_dec_ref);{Required but for speed executed outside the for loop}

    delta_ra := ra_t - hd.ra0;
    sincos(delta_ra, SIN_delta_ra, COS_delta_ra);

    H := SIN_dec_t * sin_dec_ref + COS_dec_t * COS_dec_ref * COS_delta_ra;
    dRA := (COS_dec_t * SIN_delta_ra / H) * 180 / pi;
    dDEC := ((SIN_dec_t * COS_dec_ref - COS_dec_t * SIN_dec_ref * COS_delta_ra) / H) * 180 / pi;

    det := hd.cd2_2 * hd.cd1_1 - hd.cd1_2 * hd.cd2_1;
    stars_reference[i].x := -(hd.cd1_2 * dDEC - hd.cd2_2 * dRA) / det;
    stars_reference[i].y := +(hd.cd1_1 * dDEC - hd.cd2_1 * dRA) / det;

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
  AP_order := 3; //third order
  AP_0_0 := trans_sky_to_pixel.x00;
  AP_0_1 := trans_sky_to_pixel.x01;
  AP_0_2 := trans_sky_to_pixel.x02;
  AP_0_3 := trans_sky_to_pixel.x03;
  AP_1_0 := -1 + trans_sky_to_pixel.x10;
  AP_1_1 := trans_sky_to_pixel.x11;
  AP_1_2 := trans_sky_to_pixel.x12;
  AP_2_0 := trans_sky_to_pixel.x20;
  AP_2_1 := trans_sky_to_pixel.x21;
  AP_3_0 := trans_sky_to_pixel.x30;

  BP_0_0 := trans_sky_to_pixel.y00;
  BP_0_1 := -1 + trans_sky_to_pixel.y01;
  BP_0_2 := trans_sky_to_pixel.y02;
  BP_0_3 := trans_sky_to_pixel.y03;
  BP_1_0 := trans_sky_to_pixel.y10;
  BP_1_1 := trans_sky_to_pixel.y11;
  BP_1_2 := trans_sky_to_pixel.y12;
  BP_2_0 := trans_sky_to_pixel.y20;
  BP_2_1 := trans_sky_to_pixel.y21;
  BP_3_0 := trans_sky_to_pixel.y30;


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
  A_order := 3;
  A_0_0 := trans_pixel_to_sky.x00;
  A_0_1 := trans_pixel_to_sky.x01;
  A_0_2 := trans_pixel_to_sky.x02;
  A_0_3 := trans_pixel_to_sky.x03;
  A_1_0 := -1 + trans_pixel_to_sky.x10;
  A_1_1 := trans_pixel_to_sky.x11;
  A_1_2 := trans_pixel_to_sky.x12;
  A_2_0 := trans_pixel_to_sky.x20;
  A_2_1 := trans_pixel_to_sky.x21;
  A_3_0 := trans_pixel_to_sky.x30;

  B_0_0 := trans_pixel_to_sky.y00;
  B_0_1 := -1 + trans_pixel_to_sky.y01;
  B_0_2 := trans_pixel_to_sky.y02;
  B_0_3 := trans_pixel_to_sky.y03;
  B_1_0 := trans_pixel_to_sky.y10;
  B_1_1 := trans_pixel_to_sky.y11;
  B_1_2 := trans_pixel_to_sky.y12;
  B_2_0 := trans_pixel_to_sky.y20;
  B_2_1 := trans_pixel_to_sky.y21;
  B_3_0 := trans_pixel_to_sky.y30;

  update_sip_coefficients(memo);//update all sip coefficients in memo
end;



{##################################### Multi-threaded spiral search ##########################################
 The same design as the spiral search of astap_cli (unit_command_line_solving).

 The squared spiral is walked step by step as before (make_position) and the positions are searched by search_spiral:

 - One thread (solve_show_log, ASTAP_THREADS=1, or no thread manager): the original serial loop. The progress is shown
   before each position and Application.ProcessMessages is called after each position, as before.
 - More threads: the positions are handed out in spiral order. Each thread takes the next position, searches it and takes
   the next one. The main thread searches too and calls Application.ProcessMessages after each of its positions, so the GUI
   stays as responsive as with the serial search and the Esc key still works. The number of threads grows with the ring of
   the spiral: one thread for the start position (ring 0), 4 for ring 1 (8 positions), 8 for ring 2 (16 positions),
   4*r for ring r, up to the maximum. So a solve near the start position, the normal case, runs on one thread like before.
   A blind search gets all threads.
   If several positions give a solution, the lowest position wins. Positions are handed out in increasing order, so all
   lower positions are searched as well and the result is the same as the serial search gives.

 Positions are made when a thread needs one, so the spiral is not stored. Only the positions in progress or not yet
 reported are kept (window). The distance to report is decided when the position is made, in spiral order, with the
 same rule as the serial search.

 Every thread has its own copy of the search state (threadvars quad_star_distances1, solution_vectorX, mag2, ... in
 unit_star_align and this unit) and its own star database reader. The star database tiles are shared, see unit_star_database.
 Worker threads never use the LCL: no memo2_message, no captions, no Application. All settings are read by the main thread
 before the search (Tsearch). The main thread reports the progress (search distance), the number of threads and the
 warnings in spiral order.

 Lessons from astap_cli: Sleep(1) lasts 15.6 ms on Windows, so the main thread waits for an event, not with Sleep.
 WaitForThreadTerminate(h,0) waits forever on Windows, so threads are only joined after they reported to be finished.}


//################################ Debugging the spiral search ###############################################
//
// SWITCH: remove the // in front of the next line to search with one thread only. Then the original serial loop runs in the
// main thread and breakpoints, stepping and watches behave as before the threads were added. The compiler gives a warning as
// long as the switch is on, so it is not forgotten in a release. Put the // back when done.
//{$DEFINE solve_one_thread}
//
// (Without recompiling: the environment variable ASTAP_THREADS=1 does the same. Ticking "show log" (solve_show_log) also
// gives one thread, since the log of every search step must stay in spiral order.)
//
// If a problem only shows with more threads: compare the result and log of one thread with the normal multi-threaded run.
// Apart from the "Spiral search: N threads." lines and the timing they must be identical. A difference is the bug report.
//
// Debugging with threads:
// - A breakpoint in solve_step, read_stars, find_quads, find_fit, find_offset_and_rotation or the star database reader can be
//   hit by any search thread. The debugger stops all threads; View, Debug windows, Threads shows which one stopped. Stepping
//   may jump between threads. A conditional breakpoint like pos.count=123 stops at one spiral position.
// - A watch on a threadvar (mag2, solution_vectorX, quad_star_distances1, ...) shows the copy of the thread that stopped, or
//   nothing if the debugger can not read threadvars. Local variables are more reliable.
// - An exception in a worker thread is kept and raised again by the main thread after the search (only if the serial search
//   would have reached that position), so its stack trace is lost. Let the debugger stop at all exceptions to see where it
//   was raised.
// - Pausing at a breakpoint is safe. The search has no time outs.
//
// Rules for changes in the code that the search threads run (solve_step, read_stars, find_quads, find_fit,
// find_fit_using_hash, clip_and_refit, find_offset_and_rotation, lsq_fit and the star database reader):
// - No LCL: no memo2_message, no stackmenu1 or mainform1 controls, no Application. A temporary debug memo2_message there works
//   with one thread but can crash or garble memo2 with more threads. Use the switch above, or test like the other log lines:
//   if ((solve_show_log) and (defer_quad_warning=false)) then memo2_message(...)
// - A new global variable that this code writes must be a threadvar. A global that it only reads must be set before the
//   search starts, or be passed in Tsearch like the other settings. The main thread calls Application.ProcessMessages during
//   the search, so the user can start other actions that change globals.
// - A new result the caller needs (like mag2 or nr_references) must be copied into Tsearch in solve_step (under the lock) and
//   back into the main thread variable in solve_image. Otherwise the main thread keeps the value of the last position it
//   searched itself.
// - Never use an out parameter for a value that must survive between calls. An out value is undefined at the start of the
//   call (this gave the "Used stars down to magnitude: 1194530529..." bug, mag2 in the star database reader).
// - The Debug build options -gt (trash variables), -Cr and -Co find such errors early.
//###############################################################################################################

{$IFDEF solve_one_thread}
  {$WARNING solve_one_thread is on: the spiral search uses one thread. For debugging only}
{$ENDIF}

type
  Tposition = record {one position of the spiral}
    ra, dec      : double;
    ring         : integer;{ring of the spiral, max(|x|,|y|)}
    count, x, y  : integer;{spiral counter and spiral x,y, for the log}
    report_deg   : double; {distance in degrees to report before this position, -1 for none}
    threads      : integer;{number of threads to report before this position, 0 for none}
    done         : boolean;{searched}
    warn         : integer;{bucket overflow warnings of this position}
  end;

  Tsearch = record {one spiral search, shared by the threads}
    {parameters, set by the main thread before the search and read only during the search}
    ra_seed, dec_seed, step_size, radius   : double;{radius in degrees}
    max_distance                           : integer;{in steps}
    search_field2                          : double;
    database_type, nrstars_required2, nrstars_image, minimum_quads : integer;
    quad_tolerance                         : double;
    second_pass                            : boolean;
    width2, height2                        : integer;
    centerX, centerY, crota2_rad, cdelt1_arcsec, cdelt2_arcsec, fov_org : double;
    max_threads                            : integer;
    keep_starlist                          : boolean;{keep the database stars of the solution, for plot_stars_used_for_solving}
    info_message                           : string; {for the tray icon and popup notifier}
    quads2                                 : Tstar_list;{quads of the image. Each worker thread keeps its own reference}
    db_name, db_path                       : string;    {the star database. Pinned in the worker threads, see pin_star_database}
    wide_stars                             : array of single;{the wide field stars, for a W08 database}
    exception_mask                         : TFPUExceptionMask;{floating point settings of the main thread. The LCL may change them, a new thread starts with the defaults}
    round_mode                             : TFPURoundingMode;
    precision_mode                         : TFPUPrecisionMode;

    lock                                   : TRTLCriticalSection;{guards all fields below, except where noted}
    {spiral walk}
    spiral_x, spiral_y, spiral_dx, spiral_dy, count : integer;
    walk_done                              : boolean;{the spiral is walked to max_distance}
    distance                               : double;{last distance reported in degrees}
    threads_reported                       : integer;{last number of threads reported, 0 for none}
    {positions. Position i is window[i and (length(window)-1)] for base<=i<made}
    window                                 : array of Tposition;
    base, made                             : integer;{positions below base are reported. Positions below made are made}
    next, stop_at                          : integer;{next position to hand out. No position at or above stop_at is started}
    {results}
    best                                   : integer;{lowest position with a solution, high(integer) if none}
    first_error                            : integer;{lowest position where the star database could not be read}
    error_is_read                          : boolean;{first_error is a read error, not a missing database file}
    error_dec                              : double; {declination of position first_error}
    exc                                    : TObject;{exception of the lowest position that raised one}
    exc_idx                                : integer;
    {result of position best}
    ra_database, dec_database, mag2        : double;
    solution_vectorX, solution_vectorY     : Tsolution_vector;
    nr_references, nr_references2          : integer;
    A_XYpositions, quads1, starlist1       : Tstar_list;
    b_Xrefpositions, b_Yrefpositions       : array of double;
    {worker threads}
    running                                : integer;{worker threads not finished}
    workers                                : array of TThreadID;{main thread only}
    nworkers                               : integer;   {main thread only}
    event                                  : PRTLEvent; {set by a worker after each position and when it ends}
    {main thread only}
    threads_shown                          : integer;{number of threads last reported}
    aborted                                : boolean;{Esc pressed}
  end;
  Psearch = ^Tsearch;

var
  popupnotifier_visible: boolean = False;{main thread only}


function threads_available: boolean; {false if the program has no thread manager. For Linux and macOS the program has to use unit cthreads}
{$IFDEF UNIX}
var
  tm : TThreadManager;
{$ENDIF}
begin
  {$IFDEF UNIX}
  GetThreadManager(tm);
  result:=assigned(tm.InitManager);{only set by cthreads. Without it BeginThread would stop the program with runtime error 232}
  {$ELSE}
  result:=true;
  {$ENDIF}
end;


function solve_thread_count: integer; {maximum number of threads for the spiral search}
begin
  {$IFDEF solve_one_thread}
  exit(1);{debugging switch, see "Debugging the spiral search" above}
  {$ENDIF}
  if solve_show_log then exit(1);{the log of every search step must be in spiral order}
  if threads_available=false then exit(1);
  result:=StrToIntDef(GetEnvironmentVariable('ASTAP_THREADS'),0);{for testing}
  if result<=0 then result:=GetSystemCoreCount;{physical cores. Hyperthreading gives no gain for the search, measured with astap_cli on a Ryzen 5 2600}
  {$IFDEF CPU32}
  result:=min(result,16);{32 bit, limited address space}
  {$ELSE}
  result:=min(result,64);
  {$ENDIF}
  result:=max(1,result);
end;


function copy_starlist(const a: Tstar_list): Tstar_list; {independent copy of a two dimensional array}
var
  i : integer;
begin
  result:=nil;
  setlength(result,length(a));
  for i:=0 to high(a) do result[i]:=copy(a[i]);
end;


function ring_threads(c: Psearch; ring: integer): integer; {number of threads for a ring of the spiral. Ring 0: 1 thread, ring 1 (8 positions): 4 threads, ring 2 (16 positions): 8 threads...}
begin
  result:=min(c^.max_threads,max(1,4*ring));
end;


function make_position(c: Psearch): boolean; {walk the squared spiral to the next position within the search circle and add it. Result false at the end of the spiral. Call under c^.lock}
var
  dec_database, ra_database, flip, extra, ra_database_offset, seperation : double;
  spiral_t, i, cap, newcap : integer;
  found        : boolean;
  new_window   : array of Tposition;
  p            : ^Tposition;
begin
  result:=false;
  while c^.walk_done=false do
  begin
    {begin spiral routine, find a new squared spiral position position}
    if c^.count <> 0 then {first do nothing, start with [0 0] then start with [1 0],[1 1],[0 1],[-1 1],[-1 0],[-1 -1],[0 -1],[1 -1],[2 -1].[2 0] ..............}
    begin {start spiral around [0 0]}
      if ((c^.spiral_x = c^.spiral_y) or ((c^.spiral_x < 0) and (c^.spiral_x = -c^.spiral_y)) or ((c^.spiral_x > 0) and (c^.spiral_x = 1 - c^.spiral_y))) then {turning point}
      begin {swap dx by negative dy and dy by negative dx}
        spiral_t := c^.spiral_dx;
        c^.spiral_dx := -c^.spiral_dy;
        c^.spiral_dy := spiral_t;
      end;
      c^.spiral_x := c^.spiral_x + c^.spiral_dx;{walk through square}
      c^.spiral_y := c^.spiral_y + c^.spiral_dy;{walk through square}
    end;{end spiral around [0 0]}

    {adapt search field to matrix position, +0+0/+1+0,+1+1,+0+1,-1+1,-1+0,-1-1,+0-1,+1-1..}
    dec_database := c^.step_size * c^.spiral_y + c^.dec_seed;
    flip := 0;
    if dec_database > +pi / 2 then
    begin
      dec_database := pi - dec_database;
      flip := pi;
    end {crossed the pole}
    else
    if dec_database < -pi / 2 then
    begin
      dec_database := -pi - dec_database;
      flip := pi;
    end;

    if dec_database > 0 then extra := c^.step_size / 2  else  extra := -c^.step_size / 2;{use the distance furthest away from the pole}

    found:=false;
    ra_database:=0;
    seperation:=0;
    ra_database_offset := (c^.step_size * c^.spiral_x / cos(dec_database - extra)); {step larger near pole. This ra_database is an offset from zero}
    if ((ra_database_offset <= +pi / 2 + c^.step_size / 2) and (ra_database_offset >= -pi / 2)) then  {step_size for overlap}
    begin
      ra_database := fnmodulo(flip + c^.ra_seed + ra_database_offset, 2 * pi);{add offset to ra after the if statement! Otherwise no symmetrical search}
      ang_sep(ra_database, dec_database, c^.ra_seed, c^.dec_seed, {out}seperation); {calculates angular separation. according formula 9.1 old Meeus or 16.1 new Meeus, version 2018-5-23}
      found:=(seperation <= c^.radius * pi / 180 + c^.step_size / 2); {Use only the circular area withing the square area}
    end;{ra in range}

    if found then
    begin
      cap:=length(c^.window);
      if c^.made-c^.base>=cap then {window full, double it}
      begin
        newcap:=max(64,2*cap);
        new_window:=nil;
        setlength(new_window,newcap);
        for i:=c^.base to c^.made-1 do new_window[i and (newcap-1)]:=c^.window[i and (cap-1)];
        c^.window:=new_window;
        cap:=newcap;
      end;
      p:=@c^.window[c^.made and (cap-1)];
      p^.ra:=ra_database;
      p^.dec:=dec_database;
      p^.ring:=max(abs(c^.spiral_x),abs(c^.spiral_y));
      p^.count:=c^.count;
      p^.x:=c^.spiral_x;
      p^.y:=c^.spiral_y;
      p^.done:=false;
      p^.warn:=0;
      if seperation * 180 / pi > c^.distance + c^.fov_org then {new distance reached. Update once in the square spiral, so not too often since it cost CPU time}
      begin
        c^.distance := seperation * 180 / pi;
        p^.report_deg:=c^.distance;
      end
      else
        p^.report_deg:=-1;
      if ((c^.second_pass=false) and (ring_threads(c,p^.ring)<>c^.threads_reported)) then {report the number of threads where it changes. Not for the second pass, a check of the solution}
      begin
        c^.threads_reported:=ring_threads(c,p^.ring);
        p^.threads:=c^.threads_reported;
      end
      else
        p^.threads:=0;
      inc(c^.made);
    end;
    inc(c^.count);{step further in spiral}
    if c^.spiral_x > c^.max_distance then c^.walk_done:=true;{squared spiral}
    if found then exit(true);
  end;
end;


procedure keep_exception(c: Psearch; idx: integer; exc: TObject); {keep the exception of the lowest position. Call under c^.lock}
begin
  if idx<c^.exc_idx then
  begin
    if c^.exc<>nil then c^.exc.Free;
    c^.exc:=exc;
    c^.exc_idx:=idx;
  end
  else
    exc.Free;
  if idx<c^.stop_at then c^.stop_at:=idx;
end;


function claim_position(c: Psearch; out pos: Tposition): integer; {take the next position in spiral order. Result -1 if there is none}
begin
  result:=-1;
  EnterCriticalSection(c^.lock);
  try
    try
      if c^.next<c^.stop_at then
      begin
        while ((c^.next>=c^.made) and make_position(c)) do ;
        if c^.next<c^.made then
        begin
          result:=c^.next;
          pos:=c^.window[result and (length(c^.window)-1)];
          inc(c^.next);
        end;
      end;
    except {out of memory for the window}
      keep_exception(c,c^.made,TObject(AcquireExceptionObject));
      result:=-1;
    end;
  finally
    LeaveCriticalSection(c^.lock);
  end;
end;


function solve_step(c: Psearch; idx: integer; const pos: Tposition): boolean; {search one spiral position: read the database stars, make quads and try to match. Runs on any thread. Result true if the search can stop here: a solution or a database error}
var
  starlist1         : Tstar_list;
  i, nstars_visible : integer;
  xi, yi            : double;
  a_xy, q1, s1      : Tstar_list;
  b_x, b_y          : array of double;
begin
  result:=false;
  quad_star_distances2:=c^.quads2;{the quads of the image. Restore them, an action started by Application.ProcessMessages could have replaced them}

  {read nrstars_required stars from database. If search field is oversized, number of required stars increases with the power of the oversize factor. So the star density will be the same as in the image to solve}
  if read_stars(pos.ra, pos.dec, c^.search_field2, c^.database_type, c^.nrstars_required2,{out} starlist1) = False then
  begin
    EnterCriticalSection(c^.lock);
    if idx<c^.first_error then
    begin
      c^.first_error:=idx;
      c^.error_is_read:=database_read_error;
      c^.error_dec:=pos.dec;
    end;
    LeaveCriticalSection(c^.lock);
    exit(true);
  end;

  //mod 2025 ###################################################
  if c^.second_pass then  //2025 first solution found, filter out stars for the second match. Avoid that stars outside the image boundaries are used to create database quads
  begin //keep only stars which are visible in the image according the first solution
    nstars_visible := 0;

    for i := 0 to Length(starlist1[0]) - 1 do
    begin
      rotate(c^.crota2_rad, starlist1[0, i] / c^.cdelt1_arcsec, starlist1[1, i] / c^.cdelt2_arcsec, xi, yi);{rotate to screen orientation}
      xi := c^.centerX - xi;
      yi := c^.centerY - yi;
      if ((xi > 0) and (xi < c^.width2) and (yi > 0) and (yi < c^.height2)) then //within image boundaries
      begin
        starlist1[0, nstars_visible] := starlist1[0, i];
        starlist1[1, nstars_visible] := starlist1[1, i];
        Inc(nstars_visible);
      end;
    end;
    setlength(starlist1, 2, nstars_visible);
  end; //keep only stars visible in image
  //mod 2025 ###################################################

  find_quads(False,c^.nrstars_image, starlist1, quad_star_distances1); {find quads for reference image/database.}

  if ((solve_show_log) and (defer_quad_warning=false)) then {global variable set in find stars. Only with one thread}
    memo2_message('Search '+ inttostr(pos.count) + ', [' + IntToStr(pos.x) + ',' + IntToStr(pos.y) + '],' + #9 + 'position: ' +
                 #9 + prepare_ra(pos.ra, ': ') + #9 + prepare_dec(pos.dec, '° ') +
                 #9 + ' Down to magn ' + floattostrF(mag2 / 10, ffFixed, 0, 1) +
                 #9 + ' ' + IntToStr(length(starlist1[0])) + ' database stars' +
                 #9 + ' ' + IntToStr(length(quad_star_distances1[0])) + ' database quads to compare.');

  if find_offset_and_rotation(c^.minimum_quads {>=3}, c^.quad_tolerance) then {find an solution}
  begin
    a_xy:=copy_starlist(A_XYpositions);{copies for add_sip. Made before taking the lock, so running out of memory can not leave the lock taken}
    b_x:=copy(b_Xrefpositions);
    b_y:=copy(b_Yrefpositions);
    q1:=copy_starlist(quad_star_distances1);
    if c^.keep_starlist then s1:=copy_starlist(starlist1) else s1:=nil;
    EnterCriticalSection(c^.lock);
    if idx<c^.best then {the lowest position wins, as in the serial search}
    begin
      c^.best:=idx;
      c^.ra_database:=pos.ra;
      c^.dec_database:=pos.dec;
      c^.mag2:=mag2;
      c^.solution_vectorX:=solution_vectorX;
      c^.solution_vectorY:=solution_vectorY;
      c^.nr_references:=nr_references;
      c^.nr_references2:=nr_references2;
      c^.A_XYpositions:=a_xy;
      c^.b_Xrefpositions:=b_x;
      c^.b_Yrefpositions:=b_y;
      c^.quads1:=q1;
      c^.starlist1:=s1;
    end;
    LeaveCriticalSection(c^.lock);
    result:=true;
  end;
end;


procedure run_step(c: Psearch; idx: integer; const pos: Tposition); {search one position in a parallel search and register the result. Does not raise}
var
  stop : boolean;
  exc  : TObject;
  p    : ^Tposition;
begin
  quad_warnings:=0;
  defer_quad_warning:=true;{find_quads may not use memo2 from a worker thread. The main thread reports the warning in search order}
  exc:=nil;
  try
    stop:=solve_step(c,idx,pos);
  except
    exc:=TObject(AcquireExceptionObject);{raised by the main thread if the serial search would have reached this position, see search_spiral}
    stop:=true;
  end;
  defer_quad_warning:=false;

  EnterCriticalSection(c^.lock);
  try
    if exc<>nil then keep_exception(c,idx,exc);
    p:=@c^.window[idx and (length(c^.window)-1)];{idx>=base, since base only passes positions that are done}
    p^.warn:=quad_warnings;
    p^.done:=true;
    if ((stop) and (idx<c^.stop_at)) then c^.stop_at:=idx;{no positions above this one are needed any more}
  finally
    LeaveCriticalSection(c^.lock);
  end;
end;


function search_worker(p: pointer): ptrint; {worker thread of the spiral search. Uses no LCL}
var
  c   : Psearch;
  idx : integer;
  pos : Tposition;
begin
  c:=Psearch(p);
  try
    try
      SetExceptionMask(c^.exception_mask);{the same floating point behaviour as the main thread, else a position could raise here and give a NaN in the main thread}
      SetRoundMode(c^.round_mode);
      SetPrecisionMode(c^.precision_mode);
      pin_star_database(c^.db_name,c^.db_path,c^.database_type);{read the database of this search, also if the main thread selects an other one meanwhile}
      pinned_wide_stars:=c^.wide_stars;
      wide_pinned:=true;
      quad_star_distances2:=c^.quads2;{the quads of the image. An own reference, so they stay valid even if the main thread replaces its copy}
      repeat
        idx:=claim_position(c,pos);
        if idx<0 then break;
        run_step(c,idx,pos);{does not raise}
        RTLEventSetEvent(c^.event);{wake the main thread to report the progress}
      until false;
    finally
      close_star_database;{detach this thread from the shared tile cache and close its file}
      unpin_star_database;
      wide_pinned:=false;
      pinned_wide_stars:=nil;{free the threadvars of this thread}
      quad_star_distances1:=nil;
      quad_star_distances2:=nil;
      A_XYpositions:=nil;
      b_Xrefpositions:=nil;
      b_Yrefpositions:=nil;
    end;
  except {should not happen. An exception may not leave a thread, it would end the program}
  end;
  EnterCriticalSection(c^.lock);
  dec(c^.running);
  LeaveCriticalSection(c^.lock);
  RTLEventSetEvent(c^.event);{the main thread joins this thread only after running is 0, so c^ is still valid here}
  result:=0;
end;


function add_worker(c: Psearch): boolean; {start one more worker thread. Main thread only}
var
  h : TThreadID;
begin
  EnterCriticalSection(c^.lock);
  inc(c^.running);
  LeaveCriticalSection(c^.lock);
  h:=BeginThread(TThreadFunc(@search_worker),c);
  result:=(h<>TThreadID(0));
  if result then
  begin
    c^.workers[c^.nworkers]:=h;
    inc(c^.nworkers);
  end
  else
  begin {no more threads possible, continue with the threads running}
    EnterCriticalSection(c^.lock);
    dec(c^.running);
    c^.max_threads:=c^.nworkers+1;{also lowers the number reported for the next rings}
    LeaveCriticalSection(c^.lock);
  end;
end;


procedure report_position(c: Psearch; const p: Tposition); {main thread only. Report the number of threads, the search distance and warnings of a position}
var
  distancestr, threads_str : string;
begin
  if p.threads>0 then
  begin
    if p.threads>1 then memo2_message('Spiral search: '+IntToStr(p.threads)+' threads.');{only for a parallel search}
    c^.threads_shown:=p.threads;
  end;

  if p.report_deg>=0 then {new distance reached. Update once in the square spiral, so not too often since it cost CPU time}
  begin
    distancestr := IntToStr(round(p.report_deg)) + '°';
    if c^.threads_shown>1 then threads_str:='   ('+IntToStr(c^.threads_shown)+' threads)' else threads_str:='';
    {show on stackmenu what's happening}
    stackmenu1.actual_search_distance1.Caption := distancestr;
    stackmenu1.Caption := 'Search distance:  ' + distancestr + threads_str;
    mainform1.Caption := 'Search distance:  ' + distancestr + threads_str;

    if commandline_execution then {command line execution}
    begin
      {$ifdef CPUARM}
       { tray icon  gives a fatal execution error in the old compiler for armhf}
      {$else}
      mainform1.TrayIcon1.hint := distancestr + c^.info_message;
      {$endif}

      if p.report_deg > 2 * c^.fov_org then {prevent flash for short distance solving}
      begin
        if popupnotifier_visible = False then
        begin
          mainform1.popupnotifier1.Visible := True;
          popupnotifier_visible := True;
        end; {activate only once}
        mainform1.popupnotifier1.Text := distancestr + c^.info_message;
      end;
    end;
  end; {info reporting}

  if p.warn>0 then memo2_message('Warning, bucket size increased!');{found by a worker thread}
end;


procedure report_progress(c: Psearch); {main thread only. Report the searched positions in spiral order, up to the position where the serial search would have stopped}
var
  limit, n, i : integer;
  p           : ^Tposition;
  list        : array of Tposition;
begin
  n:=0;
  list:=nil;
  EnterCriticalSection(c^.lock);
  try {collect under the lock, report without it}
    limit:=min(c^.best,min(c^.first_error,c^.exc_idx));
    while ((c^.base<c^.made) and (c^.base<=limit)) do
    begin
      p:=@c^.window[c^.base and (length(c^.window)-1)];
      if p^.done=false then break;
      if ((p^.threads>0) or (p^.report_deg>=0) or (p^.warn>0)) then
      begin
        if n>=length(list) then setlength(list,max(16,2*n));
        list[n]:=p^;
        inc(n);
      end;
      inc(c^.base);
    end;
  finally
    LeaveCriticalSection(c^.lock);
  end;
  for i:=0 to n-1 do report_position(c,list[i]);
end;


procedure wait_for_workers(c: Psearch; pump: boolean); {main thread only. Wait until all worker threads are finished, keep the GUI responsive if pump is true. Then join them}
var
  i, n : integer;
  exc  : TObject;
begin
  exc:=nil;
  repeat
    EnterCriticalSection(c^.lock);
    n:=c^.running;
    LeaveCriticalSection(c^.lock);
    if n=0 then break;
    if pump then
    try
      report_progress(c);
      Application.ProcessMessages;
      if esc_pressed then
      begin
        EnterCriticalSection(c^.lock);
        c^.stop_at:=-1;{start no new positions}
        LeaveCriticalSection(c^.lock);
      end;
    except {keep waiting for the workers, they use c^. Raise it after the join}
      exc:=TObject(AcquireExceptionObject);
      pump:=false;
    end;
    RTLEventWaitFor(c^.event,10);{a worker sets the event after each position and when it ends. Not Sleep, that lasts 15.6 ms on Windows}
  until false;
  for i:=0 to c^.nworkers-1 do
  begin
    WaitForThreadTerminate(c^.workers[i],-1);{the thread has ended or is ending, so no time out needed. Do not use 0, that waits forever on Windows}
    CloseThread(c^.workers[i]);
  end;
  c^.nworkers:=0;
  if exc<>nil then raise exc;
end;


procedure search_spiral(c: Psearch); {search the spiral. Result in c^.best, c^.first_error, c^.aborted. Main thread only}
var
  idx    : integer;
  pos    : Tposition;
  exc    : TObject;
  stop, normal_end : boolean;
begin
  c^.spiral_x:=0;
  c^.spiral_y:=0;
  c^.spiral_dx:=0;{first step size x}
  c^.spiral_dy:=-1;{first step size y}
  c^.count:=0;{search field counter}
  c^.walk_done:=false;
  c^.distance:=0;{required for reporting not too often}
  c^.threads_reported:=0;
  c^.threads_shown:=0;
  c^.base:=0;
  c^.made:=0;
  c^.next:=0;
  c^.stop_at:=high(integer);
  c^.best:=high(integer);
  c^.first_error:=high(integer);
  c^.error_is_read:=false;
  c^.exc:=nil;
  c^.exc_idx:=high(integer);
  c^.running:=0;
  c^.nworkers:=0;
  c^.aborted:=false;
  setlength(c^.workers,max(0,c^.max_threads-1));

  InitCriticalSection(c^.lock);
  try
  try
    if c^.max_threads<=1 then
    begin {one thread, the serial search in spiral order as before}
      repeat
        idx:=claim_position(c,pos);
        if idx<0 then break;
        report_position(c,pos);
        stop:=solve_step(c,idx,pos);
        c^.base:=idx+1;{reported}
        if c^.first_error=idx then break;{star database error. Stop at once, as before}
        Application.ProcessMessages;
        if esc_pressed then
        begin
          c^.aborted:=true;
          break;
        end;
      until stop;
    end
    else
    begin {threads are added as the search moves outwards}
      c^.event:=RTLEventCreate;
      normal_end:=false;
      try
        try
          repeat
            idx:=claim_position(c,pos);
            if idx<0 then break;
            while c^.nworkers+1<ring_threads(c,pos.ring) do
              if add_worker(c)=false then break;
            run_step(c,idx,pos);{the main thread searches too}
            report_progress(c);
            Application.ProcessMessages;{keep the GUI responsive and see the Esc key}
            if esc_pressed then break;
          until false;
          normal_end:=true;
        finally {also after an exception in this thread: stop the workers and wait for them before the search record is released}
          EnterCriticalSection(c^.lock);
          c^.stop_at:=-1;{start no new positions. Positions in progress are finished}
          LeaveCriticalSection(c^.lock);
          wait_for_workers(c,normal_end);
        end;
      finally
        RTLEventDestroy(c^.event);
        c^.event:=nil;
      end;
      if esc_pressed then
        c^.aborted:=true
      else
        report_progress(c);
    end;
  except {an exception of the main thread leaves the search. Free a kept exception of a worker}
    if c^.exc<>nil then
    begin
      c^.exc.Free;
      c^.exc:=nil;
    end;
    raise;
  end;
  finally
    DoneCriticalSection(c^.lock);
  end;

  if c^.exc<>nil then
  begin
    exc:=c^.exc;
    c^.exc:=nil;
    if ((c^.aborted=false) and (c^.exc_idx<min(c^.best,c^.first_error))) then
      raise exc {the serial search would have stopped with this exception}
    else
      exc.Free;{a thread that ran ahead of the solution}
  end;
end;


function solve_image(img: Timage_array; var hd: Theader; memo: TStrings; const ra_start,dec_start:double; get_hist{update hist}, check_patternfilter: boolean): boolean; {find match between image and star database}
var
  nrstars_image, nrstars_required, max_distance, nr_quads,
  minimum_quads, binning, match_nr, max_stars, i, database_density, limit, err : integer;
  search_field, step_size, ra_database, dec_database, radius, fov2, fov_org,
  max_fov, fov_min, oversize, oversize2, sep_search, ra7, dec7,
  centerX, centerY, correctionX, correctionY, cropping, min_star_size_arcsec, hfd_min,
  quad_tolerance, mount_sep,
  mount_ra_sep, mount_dec_sep,pixel_aspect_ratio, crota1_rad, crota2_rad, flipped_image,
  arcsec_per_px, mean_hfd, cdelt1_arcsec, cdelt2_arcsec,vfov,
  ra_seed, dec_seed, ra_solved, dec_solved                                           : double;
  solution, go_ahead, autoFOV                              : boolean;
  startTick: qword;{for timing/speed purposes}
  info_message, popup_warningG05, popup_warningSample, suggest_str,
  solved_in, offset_found, ra_offset_str, dec_offset_str, mount_info_str,
  mount_offset_str, warning_downsample: string;
  starlist1, starlist2  : Tstar_list;
  quads_image : Tstar_list;{the quads of the image. Own reference, an action started by Application.ProcessMessages during the search could replace quad_star_distances2}
  srch      : Tsearch;{the spiral search}
var {with value}
  quads_str: string = ' quads';
begin
  Screen.Cursor := crHourglass;
  {$IfDef Darwin}
  {$else}
  application.ProcessMessages;
  {$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  Result := False;
  esc_pressed := False;
  warning_str := '';{for header}
  srch:=Default(Tsearch);{the spiral search}
  centerX:=0;{set by the first solution and only used for the second pass. Initialised since they are copied to the search record before}
  centerY:=0;
  crota2_rad:=0;
  cdelt1_arcsec:=1;
  cdelt2_arcsec:=1;
  starlist1:=nil;
  startTick := GetTickCount64;
  popup_warningG05 := '';

  if check_patternfilter then {for OSC images with low dimensions only}
  begin
    check_pattern_filter(img);
    get_hist := True; {update required}
  end;

  quad_tolerance := strtofloat2(stackmenu1.quad_tolerance1.Text);  //  quad_tolerance := min(quad_tolerance, 0.01);//  prevent too high tolerances set by command line

  max_stars := strtoint2(stackmenu1.max_stars1.Text, 500); {maximum star to process, if so filter out brightest stars later}


  if ((fov_specified = False) and (hd.cdelt2 <> 0)) then  {no fov in native command line and hd.cdelt2 in header}
    fov_org := apply_arctan(hd.Height * abs(hd.cdelt2))  {calculate FOV. PI can give negative hd.cdelt2}
  else
    fov_org := min(180, strtofloat2(stackmenu1.search_fov1.Text)); {use specfied FOV in stackmenu. 180 max to prevent runtime errors later}


  if select_star_database(stackmenu1.star_database1.Text, fov_org) = False then  {select database prior to cropping selection}
  begin
    Result := False;
    errorlevel := 32;{no star database}
    Screen.Cursor := crDefault;    { back to normal }
    exit;
  end
  else
  begin
    memo2_message('Using star database ' + uppercase(name_database));

    if ((fov_org > 30) and (database_type <> 001)) then
      warning_str := warning_str + 'Very large FOV, use W08 database! '
    else
    if ((fov_org > 6) and (database_type = 1476)) then
      warning_str := warning_str + 'Large FOV, use G05 (or V05) database! ';

    if warning_str <> '' then memo2_message(warning_str);
    popup_warningG05 := #10 + warning_str;
  end;

  if database_type = 1476 then {.1476 database}
    max_fov := 5.142857143   {warning FOV should be less the database tiles dimensions, so <=5.142857143 degrees. Otherwise a tile beyond next tile could be selected}
  else  {.1476 database}
  if database_type = 290 then {.290 database}
    max_fov := 9.53 {warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected}
  else
    max_fov := 180;

  val(copy(name_database, 2, 2), database_density, err);
  if ((err <> 0) or (database_density = 17) or (database_density = 18)) then  //old databases V17, G17, G18, H17, H18
    database_density := 9999
  else
    database_density := database_density * 100;


  min_star_size_arcsec := strtofloat2(stackmenu1.min_star_size1.Text);  {arc sec};
  autoFOV := (fov_org = 0);{specified auto FOV}

  repeat {autoFOV loop}
    ra_seed  := ra_start;  // start position search;
    dec_seed := dec_start; // start position search;

    if autoFOV then
    begin
      if fov_org = 0 then
      begin
        if database_type <> 001 then
        begin
          fov_org := 9.5;
          fov_min := 0.38;
        end
        else
        begin
          fov_org := 90;
          fov_min := 12;
        end;
      end
      else
        fov_org := fov_org / 1.5;
      memo2_message('Trying FOV: ' + floattostrF(fov_org, ffFixed, 0, 1));
    end;
    if fov_org > max_fov then
    begin
      cropping := max_fov / fov_org;
      fov2 := max_fov; {temporary cropped image, adjust FOV to adapt}
    end
    else
    begin
      cropping := 1;
      fov2 := fov_org;
    end;
    ;

    limit := round(database_density * sqr(fov2) * hd.Width / hd.Height); //limit in stars per square degree. limit=density*surface_full_image
    if limit < max_stars then
    begin
      max_stars := limit;//reduce the number of stars to use.
      memo2_message('Database limit for this FOV is ' + IntToStr(max_stars) + ' stars.');
    end;

    arcsec_per_px := fov_org * 3600 / hd.Height;//arc sec per pixel unbinned

    binning := report_binning_astrometric(hd.Height * cropping, arcsec_per_px); {select binning on dimensions of cropped image}
    hfd_min := max(0.8, min_star_size_arcsec / (binning * arcsec_per_px)); {to ignore hot pixels which are too small}

    bin_and_find_stars(img, hd, binning, cropping, hfd_min, max_stars, get_hist{update hist},  starlist2, mean_hfd, warning_downsample);  {bin, measure background, find stars. Do this every repeat since hfd_min is adapted}

    nrstars_image := Length(starlist2[0]);

    if ((hd.xpixsz <> 0) and (hd.ypixsz <> 0) and (abs(hd.xpixsz - hd.ypixsz) > 0.1)) then //non-square pixels, correct. Remove in future?
    begin //very very rare. Example QHY6 camera
      memo2_message('Rare none square pixels specified.');
      pixel_aspect_ratio := hd.xpixsz / hd.ypixsz;
      for i := 0 to nrstars_image - 1 do {correct star positions for non-square pixels}
      begin
        starlist2[0, i] := hd.Width / 2 + (starlist2[0, i] - hd.Width / 2) * pixel_aspect_ratio;
      end;
    end
    else
      pixel_aspect_ratio := 1;// this is the case in 99.95% of the cases

    {report advice}
    if length(warning_downsample) > 0 then
    begin
      popup_warningSample := #10 + warning_downsample; {warning for popup notifier}
    end
    else
      popup_warningSample := '';


    {prepare popupnotifier1 text}
    if stackmenu1.force_oversize1.Checked = False then info_message := '▶▶' {normal}
    else
      info_message := '▶'; {slow}

    info_message := ' [' + stackmenu1.radius_search1.Text + '°]' + #9 + info_message + #9 + IntToStr(nrstars_image) + ' 🟊' +
                     #10 + '↕ ' + floattostrf(fov_org,ffFixed,0,2)+ '°' +#9+ #9 + IntToStr(binning)+'x'+IntToStr(binning)+' ⇒ '+IntToStr(hd.Width)+'x'+IntToStr(hd.Height)+ popup_warningG05 + popup_warningSample+
                     #10 + mainform1.ra1.Text + 'h, '+ mainform1.dec1.Text + '° ' + #9 +{for tray icon} extractfilename(filename2) +
                     #10 + extractfileDir(filename2);

    nrstars_required := round(nrstars_image * (hd.Height / hd.Width)); {A little less. The square search field is based on height only.}

    solution := False; {assume no match is found}
    go_ahead := (nrstars_image >= 5); {bare minimum. Should be more but let's try}


    if go_ahead then {enough stars, lets find quads}
    begin
      find_quads(False,nrstars_image, starlist2, quad_star_distances2); {find star quads for new image. Quads are binning independent}
      quads_image:=quad_star_distances2;
      quads_str := ' quads';

      //   for i:=0 to length(quad_star_distances2[0])-1 do
      //   begin
      //        memo2_message(#9+floattostr(quad_star_distances2[0,i])+#9+floattostr(quad_star_distances2[1,i])+#9+floattostr(quad_star_distances2[2,i])+#9+floattostr(quad_star_distances2[3,i])+#9+
      //                     floattostr(quad_star_distances2[4,i])+#9+floattostr(quad_star_distances2[5,i])+#9+floattostr(quad_star_distances2[6,i])+#9+floattostr(quad_star_distances2[7,i])   );
      //   end;
      //   exit;



      nr_quads := Length(quad_star_distances2[0]);
      go_ahead := nr_quads >= 3; {enough quads?}

      {The step size is fixed. If a low amount of stars are detected, the search window (so the database read area) is increased up to 200% guaranteeing that all quads of the image are compared with the database quads while stepping through the sky}
      if nrstars_image < 35 then oversize := 2 {make dimensions of square search window twice then the image height}
      else
        if nrstars_image > 140 {at least 100 quads} then oversize := 1 {make dimensions of square search window equal to the image height}
      else
        oversize := 2 * sqrt(35 / nrstars_image); {calculate between 35 th=2 and 140 th=1, quads are area related so take sqrt to get oversize}

      if stackmenu1.force_oversize1.Checked then oversize := 2;

      oversize := min(oversize, max_fov / fov2);//limit request to database to 1 tile so 5.142857143 degrees for 1476 database or 9.53 degrees for type 290 database. Otherwise a tile beyond next tile could be selected}
      radius := strtofloat2(stackmenu1.radius_search1.Text);{radius search field}
      minimum_quads := 3 + nrstars_image div 140 {prevent false detections for star rich images, 3 quads give the 3 center quad references and is the bare minimum. It possible to use one quad and four star positions but it in not reliable}
    end
    else
    begin
      memo2_message('Only ' + IntToStr(nrstars_image) + ' stars found in image. Abort');
      errorlevel := 2;
    end;

    if go_ahead then
    begin
      search_field := fov2 * (pi / 180);

      STEP_SIZE := search_field;{fixed step size search spiral}
      if database_type = 1 then
      begin {make small steps for wide field images. Much more reliable}
        step_size := step_size * 0.1;
        max_distance := round(radius / (0.1 * fov2 + 0.00001)); {expressed in steps}
        memo2_message('Wide field, making small steps for reliable solving.');
      end
      else
        max_distance := round(radius / (fov2 + 0.00001));{expressed in steps}

      memo2_message(IntToStr(nrstars_image) + ' stars, ' + IntToStr(nr_quads) +  quads_str + ' selected in the image. ' + IntToStr(round(nrstars_required * sqr(oversize))) +
        ' database stars, ' + IntToStr(round(nr_quads * nrstars_required * sqr(oversize) / nrstars_image)) +
        ' database' + quads_str + ' required for the ' + floattostrF(oversize * fov2, ffFixed, 0, 2) +
        '° square search window. ' + 'Step size ' +  floattostrF(fov2, FFfixed, 0, 2) + '°. Oversize ' + floattostrF(oversize, FFfixed, 0, 2));

      stackmenu1.Memo2.Lines.BeginUpdate; {do not update tmemo, very very slow and slows down program}
      stackmenu1.Memo2.disablealign;{prevent paint messages from other controls to update tmemo and make it grey. Mod 2021-06-26}

      match_nr := 0;

      if ((database_type = 1) and (wide_database <> name_database)) then {wide field database. Load it here, before threads of the search would need it}
        read_stars_wide_field;

      repeat {Maximum accuracy loop. In case math is found on a corner, do a second solve. Result will be more accurate using all stars of the image}
        solution:=false;//could be true from a single lock. Super rare.

        {read nrstars_required stars from database. If search field is oversized, number of required stars increases with the power of the oversize factor. So the star density will be the same as in the image to solve}
        if match_nr = 0 then
        begin
          oversize2 := oversize;
        end
        else
          oversize2 := min(max_fov / fov2, max(oversize, sqrt(sqr(hd.Width / hd.Height) + sqr(1)))); //Use full image for solution for second solve but limit to one tile max to prevent tile selection problems.

        {the squared spiral around ra_seed, dec_seed. It is walked and searched by search_spiral, on several threads if available. All settings are passed in srch, the threads do not read the GUI}
        srch.ra_seed:=ra_seed;
        srch.dec_seed:=dec_seed;
        srch.step_size:=step_size;
        srch.radius:=radius;
        srch.max_distance:=max_distance;
        srch.search_field2:=search_field * oversize2;
        srch.database_type:=database_type;
        srch.nrstars_required2:=round(nrstars_required * oversize2 * oversize2); //nr of stars requested request from database
        srch.nrstars_image:=nrstars_image;
        srch.minimum_quads:=minimum_quads;
        srch.quad_tolerance:=quad_tolerance;
        srch.second_pass:=(match_nr = 1);
        srch.width2:=hd.Width;
        srch.height2:=hd.Height;
        srch.centerX:=centerX;
        srch.centerY:=centerY;
        srch.crota2_rad:=crota2_rad;
        srch.cdelt1_arcsec:=cdelt1_arcsec;
        srch.cdelt2_arcsec:=cdelt2_arcsec;
        srch.fov_org:=fov_org;
        srch.keep_starlist:=solve_show_log;
        srch.info_message:=info_message;
        srch.quads2:=quads_image;
        srch.db_name:=name_database;
        srch.db_path:=database_path;
        srch.wide_stars:=wide_field_stars;
        srch.exception_mask:=GetExceptionMask;
        srch.round_mode:=GetRoundMode;
        srch.precision_mode:=GetPrecisionMode;
        srch.max_threads:=solve_thread_count;
        tile_cache_threads:=srch.max_threads;{memory budget of the star database cache}

        search_spiral(@srch);
        tile_cache_threads:=1;{the memory budget for the next solve or annotation. Tiles in the cache stay until space is needed}

        if srch.aborted then {Esc pressed}
        begin
          stackmenu1.Memo2.enablealign; {allow paint messages from other controls to update tmemo. Mod 2021-06-26}
          stackmenu1.Memo2.Lines.EndUpdate;
          Screen.Cursor := crDefault;    { back to normal }
          exit;
        end;

        if srch.first_error < srch.best then {the database could not be read at a position before the solution, if any}
        begin
          stackmenu1.Memo2.enablealign; {allow paint messages from other controls to update tmemo. 2026 fix, before the memo stayed in BeginUpdate}
          stackmenu1.Memo2.Lines.EndUpdate;
          Screen.Cursor := crDefault;    { back to normal, also during the message box }
          if srch.error_is_read then
            application.messagebox( PChar('Could not read the star database at ' + database_path + ' !' + LineEnding + 'Disk read error or not enough memory.'), PChar('ASTAP error:'), 0)
          else
          {$IFDEF linux}
           //keep till 2026
           if ((name_database='d50') and (srch.error_dec>pi*(90-15)/180)) then //Files 3502,3503 and 3601.1476 had permission error. Star database fixed on 2023-11-27
             application.messagebox(pchar('Star database file permission error near pole. Update the D50 database to correct !!'), pchar('ASTAP error:'),0)
           else
          {$ENDIF}
          application.messagebox( PChar('No star database found at ' + database_path + ' !' + LineEnding + 'Download and install one star database.'), PChar('ASTAP error:'), 0);
          errorlevel := 33;{read error star database}
          exit; {no stars}
        end;

        solution:=(srch.best < high(integer));
        if solution then {copy the result of the solution position into the variables of this thread}
        begin
          ra_database:=srch.ra_database;
          dec_database:=srch.dec_database;
          mag2:=srch.mag2;
          solution_vectorX:=srch.solution_vectorX;
          solution_vectorY:=srch.solution_vectorY;
          nr_references:=srch.nr_references;
          nr_references2:=srch.nr_references2;
          A_XYpositions:=srch.A_XYpositions;
          b_Xrefpositions:=srch.b_Xrefpositions;
          b_Yrefpositions:=srch.b_Yrefpositions;
          quad_star_distances1:=srch.quads1;
          starlist1:=srch.starlist1;{only kept for solve_show_log}
        end;

        if solution then
        begin
          centerX := (hd.Width - 1) / 2;{center image in 0..hd.width-1 range}
          centerY := (hd.Height - 1) / 2;{center image in 0..hd.height-1 range}

          standard_equatorial(ra_database, dec_database,
            (solution_vectorX[0] * (centerX) + solution_vectorX[1] * (centerY) + solution_vectorX[2]), {x}
            (solution_vectorY[0] * (centerX) + solution_vectorY[1] * (centerY) + solution_vectorY[2]), {y}
            1, {CCD scale}  ra_solved, dec_solved {put the calculated image center equatorial position into the start search position});
          ra_seed  := ra_solved;       // re-seed the max-accuracy second pass
          dec_seed := dec_solved;

          //current_dist:=sqrt(sqr(solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY) +solution_vectorX[2]) + sqr(solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY) +solution_vectorY[2]))/3600; {current distance telescope and image center in degrees}

          //mod 2025 ############################################################
          if solution_vectorX[0] * solution_vectorY[1] - solution_vectorX[1] * solution_vectorY[0] > 0 then // flipped?
            flipped_image := -1 //change rotation for flipped image, {Flipped image. Either flipped vertical or horizontal but not both. Flipped both horizontal and vertical is equal to 180 degrees rotation and is not seen as flipped}
          else
            flipped_image := +1;//not flipped

          // position +1 pixels in direction hd.crpix2
          standard_equatorial(ra_database, dec_database,
            (solution_vectorX[0] * (centerX) + solution_vectorX[1] * (centerY + 1) + solution_vectorX[2]), {x}
            (solution_vectorY[0] * (centerX) + solution_vectorY[1] * (centerY + 1) + solution_vectorY[2]), {y}  1, {CCD scale}  ra7, dec7{equatorial position}); // the position 1 pixel away

          crota2_rad := -position_angle(ra7, dec7, ra_solved, dec_solved); //Position angle of the image +Y axis (to ra7,dec7, one pixel along CRPIX2) measured at the image center from north eastwards. Negated for the CROTA2 convention. Rigorous method.
          cdelt1_arcsec := flipped_image * sqrt(sqr(solution_vectorX[0]) + sqr(solution_vectorX[1])); // unit arcsec
          cdelt2_arcsec := sqrt(sqr(solution_vectorY[0]) + sqr(solution_vectorY[1])); //unit arcsec
          //mod 2025 ############################################################

          Inc(match_nr);
        end
        else
          match_nr := 0;//This will rarely happen for the second solve
      until ((solution = False) {or (current_dist<fov2*0.05)} {within 5% if image height from center} or (match_nr >= 2)); {Maximum accuracy loop. After match possible on a corner do a second solve using the found hd.ra0,hd.dec0 for maximum accuracy USING ALL STARS}

      stackmenu1.Memo2.enablealign;
      {allow paint messages from other controls to update tmemo. Mod 2021-06-26}
      stackmenu1.Memo2.Lines.EndUpdate;
    end; {enough quads in image}

  until ((autoFOV = False) or (solution) or (fov2 <= fov_min)); {loop for autoFOV from 9.5 to 0.37 degrees. Will lock between 9.5*1.25 downto  0.37/1.25  or 11.9 downto 0.3 degrees}

  //memo2_message(plog);//write log of profiler


  if solution then
  begin
    hd.ra0 := ra_solved;//store solution in header
    hd.dec0 := dec_solved;
    hd.crpix1 := centerX + 1;{center image in fits coordinate range 1..hd.width}
    hd.crpix2 := centery + 1;

    ang_sep(ra_start, dec_start, ra_solved, dec_solved, sep_search); //calculate search offset

    memo2_message(IntToStr(nr_references) + ' of ' +  IntToStr(nr_references2) + quads_str + ' selected matching within ' + floattostr(quad_tolerance) + ' tolerance.' //  3 quads are required giving 3 center quad references}
      + '  Solution["] x:=' + floattostr6(solution_vectorX[0]) + 'x+ ' + floattostr6(solution_vectorX[1]) + 'y+ ' + floattostr6( solution_vectorX[2])
      + ',  y:=' + floattostr6(solution_vectorY[0]) + 'x+ ' + floattostr6(solution_vectorY[1]) + 'y+ ' +   floattostr6(solution_vectorY[2]));
    //  following doesn't give maximum angle accuracy, so is not used.
    //    hd.cd1_1:= - solution_vectorX[0]/3600;{/3600, arcsec to degrees conversion}
    //    hd.cd1_2:= - solution_vectorX[1]/3600;
    //    hd.cd2_1:= + solution_vectorY[0]/3600;
    //    hd.cd2_2:= + solution_vectorY[1]/3600;


    hd.cdelt2 := cdelt2_arcsec / 3600; //convert from arc seconds to degrees
    hd.cdelt1 := cdelt1_arcsec / 3600; //convert from arc seconds to degrees

    // position 1*flipped_image  pixels in direction hd.crpix1
    standard_equatorial(ra_database, dec_database,
      (solution_vectorX[0] * (centerX + flipped_image) + solution_vectorX[1] * (centerY) + solution_vectorX[2]), {x}  //A pixel_aspect_ratio unequal of 1 is very rare, none square pixels
      (solution_vectorY[0] * (centerX + flipped_image) + solution_vectorY[1] * (centerY) + solution_vectorY[2]), {y}
      1, {CCD scale} ra7, dec7{equatorial position});

    crota1_rad := pi/2 - position_angle(ra7, dec7, ra_solved,dec_solved); //PA of the image +X axis (one pixel along CRPIX1, sign corrected for a flipped image), converted from north-referenced to the CROTA1 convention.
    if crota1_rad > pi then crota1_rad := crota1_rad - 2 * pi;//keep within range -pi to +pi


    hd.cd1_1 := +hd.cdelt1 * cos(crota1_rad);
    hd.cd1_2 := -hd.cdelt1 * sin(crota1_rad) * flipped_image;
    hd.cd2_1 := +hd.cdelt2 * sin(crota2_rad) * flipped_image;
    hd.cd2_2 := +hd.cdelt2 * cos(crota2_rad);

    hd.crota2 := crota2_rad * 180 / pi;//convert to degrees
    hd.crota1 := crota1_rad * 180 / pi;


    solved_in := ' Solved in ' + floattostr(round((GetTickCount64 - startTick) / 100) / 10) +' sec.';{make string to report in FITS header.}

    offset_found :={' Δ was '}distance_to_string(sep_search {scale selection}, sep_search) + '.';

    if ra_mount < 99 then {mount position known and specified. Calculate mount offset}
    begin
      mount_ra_sep :=fnmodulo(ra_mount-hd.ra0,2*pi); if mount_ra_sep >pi then mount_ra_sep :=mount_ra_sep-2*pi;//2026 fix, map to range -pi..+pi. The old expression pi*frac((ra_mount-head.ra0)/pi) removed multiples of pi instead of 2*pi and reported a wrong offset when the mount RA and solution RA are on opposite sides of 0h RA
      mount_ra_sep:=mount_ra_sep * cos((hd.dec0+dec_mount)*0.5 {average dec});//only used for scaling

      mount_dec_sep := dec_mount - hd.dec0;
      mount_sep := sqrt(sqr(mount_ra_sep) + sqr(mount_dec_sep));  //mount_sep is only used for scaling}

      ra_offset_str := distance_to_string(mount_sep, mount_ra_sep);
      dec_offset_str := distance_to_string(mount_sep, mount_dec_sep);
      mount_offset_str := ' Mount offset RA=' + ra_offset_str + ', DEC=' + dec_offset_str;{ascii}
      mount_info_str := ' Mount Δα=' + ra_offset_str + ',  Δδ=' + dec_offset_str + '. ' + #9;
    end
    else
      mount_info_str := '';{no mount info}

    memo2_message('Solution found: ' + prepare_ra8(hd.ra0, ': ') + #9 + prepare_dec2(hd.dec0, '° ') + #9 + solved_in + #9 + ' Δ was ' + offset_found + #9 +  mount_info_str + ' Used stars down to magnitude: ' + floattostrF(mag2 / 10, ffFixed, 0, 1));
    mainform1.Caption := ('Solution found:    ' +  prepare_ra(hd.ra0, ': ') + '     ' + prepare_dec(hd.dec0, '° '));
    Result := True;

    memo.BeginUpdate;

    if ((stackmenu1.add_sip1.Checked) and
      (add_sip(hd, memo, ra_database, dec_database)))
    then //takes about 50 ms sec due to the header update. Calculations are very fast
    begin //SIP added
      update_text(memo, 'CTYPE1  =', #39 + 'RA---TAN-SIP' + #39 + '       / TAN (gnomic) projection + SIP distortions      ');
      update_text(memo, 'CTYPE2  =', #39 + 'DEC--TAN-SIP' + #39 + '       / TAN (gnomic) projection + SIP distortions      ');
      mainform1.Polynomial1.ItemIndex := 1;//switch to sip
    end
    else
    begin //No SIP added.
      update_text(memo, 'CTYPE1  =', #39 + 'RA---TAN' + #39 + '           / first parameter RA,    projection TANgential   ');
      update_text(memo, 'CTYPE2  =', #39 + 'DEC--TAN' + #39 + '           / second parameter DEC,  projection TANgential   ');
    end;

    update_text(memo, 'HFD_MEAN= ',floattostr2(mean_hfd)+'                / Mean HFD. Could be higher then median HFD.     ');//just for info
    update_text(memo, 'CUNIT1  =', #39 + 'deg     ' + #39 + '           / Unit of coordinates                            ');

    update_text(memo, 'EQUINOX =','              2000.0 / Equinox of coordinates                         ');  {the equinox is 2000 since the database is in 2000}

    update_float(memo, 'CRPIX1  =', ' / X of reference pixel                           ', False, hd.crpix1);
    update_float(memo, 'CRPIX2  =', ' / Y of reference pixel                           ', False, hd.crpix2);

    update_float(memo, 'CRVAL1  =', ' / RA of reference pixel (deg)                    ', False, hd.ra0 * 180 / pi);
    update_float(memo, 'CRVAL2  =', ' / DEC of reference pixel (deg)                   ', False, hd.dec0 * 180 / pi);

    update_float(memo, 'CDELT1  =', ' / X pixel size (deg)                             ', False, hd.cdelt1);
    update_float(memo, 'CDELT2  =', ' / Y pixel size (deg)                             ', False, hd.cdelt2);

    update_float(memo, 'CROTA1  =', ' / Image twist X axis (deg)                       ', False, hd.crota1);
    update_float(memo, 'CROTA2  =', ' / Image twist Y axis (deg) E of N if not flipped.', False, hd.crota2);


    update_float(memo, 'CD1_1   =', ' / CD matrix to convert (x,y) to (Ra, Dec)        ', False, hd.cd1_1);
    update_float(memo, 'CD1_2   =', ' / CD matrix to convert (x,y) to (Ra, Dec)        ', False, hd.cd1_2);
    update_float(memo, 'CD2_1   =', ' / CD matrix to convert (x,y) to (Ra, Dec)        ', False, hd.cd2_1);
    update_float(memo, 'CD2_2   =', ' / CD matrix to convert (x,y) to (Ra, Dec)        ', False, hd.cd2_2);
    update_text(memo, 'PLTSOLVD=', '                   T / Astrometric solved by ASTAP v' + astap_version + '.       ');

    update_text(memo, 'COMMENT 7', solved_in + ' Offset ' + offset_found + mount_offset_str);
    memo.EndUpdate;

    if solve_show_log then {global variable set in find stars}
    begin
      equatorial_standard(ra_database, dec_database, hd.ra0, hd.dec0, 1,
        correctionX, correctionY); {calculate correction for x,y position of database center and image center}
      plot_stars_used_for_solving(starlist1, starlist2, hd, correctionX, correctionY); {plot image stars and database stars used for the solution}
      memo2_message('See viewer image for imaged stars used (red) and database stars used (yellow)');
    end;

    vfov:=apply_arctan(hd.Height * hd.cdelt2);
    if ((fov_org > 1.05 * (vfov)) or (fov_org < 0.95 * (vfov)))  then    //in astap hd.cdelt2 is always positive. No need for absolute function
    begin
      if hd.xpixsz <> 0 then suggest_str := 'Warning inexact scale! Set FOV=' + floattostrF(hd.Height * hd.cdelt2, ffFixed, 0, 2) + 'd or scale=' + floattostrF(hd.cdelt2 * 3600, ffFixed, 0, 1) +
                                            '"/pix or FL=' +  IntToStr(round((180 / (pi * 1000) * hd.xpixsz / hd.cdelt2))) + 'mm '
      else
        suggest_str := 'Warning inexact scale! Set FOV=' + floattostrF( hd.Height * hd.cdelt2, ffFixed, 0, 2) + 'd or scale=' + floattostrF( hd.cdelt2 * 3600, ffFixed, 0, 1) + '"/pix ';
      memo2_message(suggest_str);
      warning_str := suggest_str + warning_str;
    end;
  end
  else
  begin
    memo2_message('No solution found!  :(');
    mainform1.Caption := 'No solution found!  :(';
    update_text(memo, 'PLTSOLVD=', '                   F / No plate solution found.   ');
    remove_key(memo, 'COMMENT 7', False{all});
  end;

  warning_str := warning_str + warning_downsample; {add the last warning from loop autoFOV}
  if warning_str <> '' then
  begin
    update_longstr(memo, 'WARNING =', warning_str);
    {update or insert long str including single quotes}
    memo2_message(warning_str);
  end;

  Screen.Cursor := crDefault;    { back to normal }
end;


begin
end.
