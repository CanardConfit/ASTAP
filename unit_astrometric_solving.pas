unit unit_astrometric_solving;
{Copyright (C) 2018, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

{This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

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
//4) 	For each quad sort the six quad distances on size.                   	 | For each quad sort the six quad distances on size.
//      d1 is the longest and d6 the shortest.                                   | d1 is the longest and d6 the shortest.
//                                                                               |
//5) 	Scale the quad star distance as (d1, d2/d1,d3/d1,d4/d1,d5/d1,d6/d1)      | Scale the quad star distance as (d1, d2/d1,d3/d1,d4/d1,d5/d1,d6/d1)
//      These are the image hash codes.                                          | These are the database hash codes.
//
//                           => matching process <=
//6)                         Find quad hash code matches where the distances d2/d1 to d6/d1 match within a small tolerance.
//
//7) 		             For matching quad hash codes, calculate the size ratios d1_found/d1_reference. Calculate the median ratio. Compare the quads ratios with the median value and remove quads outside a small tolerance.
//
//8)                         From the remaining matching quads, prepare the "A"matrix/array containing the x,y center positions of the test image quads in standard coordinates
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
//                           With the solution calculate the test image center equatorial position α, δ.
//
//                           Make from the image center small one pixel steps in x, y and use the differences in α, δ to calculate the image scale and orientation.
//
//                           This is the final solution. The solution vector (for position, scale, rotation) can be stored as the FITS keywords crval1, crval2, cd1_1,cd1_2,cd_2_1, cd2_2.


interface

uses   Classes,SysUtils,controls,forms,math,
       unit_star_align, unit_star_database, astap_main, unit_stack, unit_annotation;

function solve_image(img :image_array; get_hist{update hist}:boolean) : boolean;{find match between image and star database}
procedure bin_and_find_stars(img :image_array;binning:integer;cropping,hfd_min:double;get_hist{update hist}:boolean; var starlist3:star_list);{bin, measure background, find stars}
function report_binning : integer;{select the binning}

var
  star1   : array[0..2] of array of single;
  solved_in, offset_found : string;

implementation
var
  mag2  : double; {magnitude of star found}

function fnmodulo (x,range: double):double;
begin
  {range should be 2*pi or 24 hours or 0 .. 360}
  x:=range *frac(X /range); {quick method for big numbers}
  if x<0 then x:=x+range;   {do not like negative numbers}
  fnmodulo:=x;
end;

function distance_to_string(dist, inp:double):string; {angular distance to string intended for RA and DEC. Unit is based on dist}
begin
  if abs(dist)<pi/(180*60) then {unit seconds}
      result:= floattostrF2(inp*3600*180/pi,0,1)+'"'
  else
  if abs(dist)<pi/180 then {unit minutes}
      result:= floattostrF2(inp*60*180/pi,0,1)+#39
  else
  result:= floattostrF2(inp*180/pi,0,1)+'°';
end;

{transformation of equatorial coordinates into CCD pixel coordinates for optical projection, rigid method}
{ra0,dec0: right ascension and declination of the optical axis}
{ra,dec:   right ascension and declination}
{xx,yy :   CCD coordinates}
{cdelt:    CCD scale in arcsec per pixel}
procedure equatorial_standard(ra0,dec0,ra,dec, cdelt : double; var xx,yy: double);
var dv,sin_dec0,cos_dec0,sin_dec ,cos_dec,sin_deltaRA,cos_deltaRA: double;
begin
  sincos(dec0  ,sin_dec0 ,cos_dec0);
  sincos(dec   ,sin_dec  ,cos_dec );
  sincos(ra-ra0, sin_deltaRA,cos_deltaRA);
  dv  := (cos_dec0 * cos_dec * cos_deltaRA + sin_dec0 * sin_dec) * cdelt/(3600*180/pi); {cdelt/(3600*180/pi), factor for onversion standard coordinates to CCD pixels}
  xx := - cos_dec *sin_deltaRA / dv;{tangent of the angle in RA}
  yy := -(sin_dec0 * cos_dec * cos_deltaRA - cos_dec0 * sin_dec) / dv;  {tangent of the angle in DEC}
end;


{transformation from CCD coordinates into equatorial coordinates}
{ra0,dec0: right ascension and declination of the optical axis       }
{x,y     : CCD coordinates                                           }
{cdelt:  : scale of CCD pixel in arc seconds                         }
{ra,dec  : right ascension and declination                           }
procedure standard_equatorial(ra0,dec0,x,y,cdelt: double; var ra,dec : double); {transformation from CCD coordinates into equatorial coordinates}
var sin_dec0 ,cos_dec0 : double;
begin
  sincos(dec0  ,sin_dec0 ,cos_dec0);
  x:=x *cdelt/ (3600*180/pi);{scale CCD pixels to standard coordinates (tang angle)}
  y:=y *cdelt/ (3600*180/pi);

  ra  := ra0 + arctan2 (-x, cos_DEC0- y*sin_DEC0);{atan2 is required for images containing celestial pole}
  if ra>pi*2 then ra:=ra-pi*2; {prevent values above 2*pi which confuses the direction detection later}
  if ra<0 then ra:=ra+pi*2;
  dec := arcsin ( (sin_dec0+y*cos_dec0)/sqrt(1.0+x*x+y*y) );
end;


//procedure give_spiral_position(position : integer; var x,y : integer); {give x,y position of square spiral as function of input value}
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


function read_stars(telescope_ra,telescope_dec,search_field : double; nrstars_required: integer; var nrstars:integer): boolean;{read star from star database}
var
   Bp_Rp, ra2,dec2,
   frac1,frac2,frac3,frac4  : double;
   area1,area2,area3,area4,nrstars_required2  : integer;
begin
  result:=false;{assume failure}
  nrstars:=0;{set counters at zero}
  ra2:=0; {define ra2 value. Prevent ra2 = -nan(0xffffffffffde9) run time failure when first header record is read}

  SetLength(starlist1,2,nrstars_required);{set array length}

  find_areas( telescope_ra,telescope_dec, search_field,{var} area1,area2,area3,area4, frac1,frac2,frac3,frac4);{find up to four star database areas for the square image}

  {read 1th area}
  if area1<>0 then {read 1th area}
  begin
    if open_database(telescope_dec,area1)=false then
      exit;{open database file or reset buffer}
    nrstars_required2:=min(nrstars_required,trunc(nrstars_required * frac1));
    while ((nrstars<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, search_field, {var} ra2,dec2, mag2,Bp_Rp)) ) do{star 290 file database read. Read up to nrstars_required}
    begin {add star}
      equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist1[0,nrstars]{x},starlist1[1,nrstars]{y});{store star CCD x,y position}
      inc(nrstars);
    end;
  end;

  if area2<>0 then {read 2th area}
  begin
    if open_database(telescope_dec,area2)=false then
      exit; {open database file or reset buffer}
    nrstars_required2:=min(nrstars_required,trunc(nrstars_required * (frac1+frac2)));{prevent round up errors resulting in error starlist1}
    while ((nrstars<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, search_field, {var} ra2,dec2, mag2,Bp_Rp)) ) do{star 290 file database read. Read up to nrstars_required}
    begin {add star}
      equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist1[0,nrstars]{x},starlist1[1,nrstars]{y});{store star CCD x,y position}
      inc(nrstars);
    end;
  end;

  if area3<>0 then {read 3th area}
  begin
    if open_database(telescope_dec,area3)=false then
      exit; {open database file or reset buffer}
    nrstars_required2:=min(nrstars_required,trunc(nrstars_required * (frac1+frac2+frac3)));
    while ((nrstars<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, search_field, {var} ra2,dec2, mag2,Bp_Rp)) ) do{star 290 file database read. Read up to nrstars_required}
    begin {add star}
      equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist1[0,nrstars]{x},starlist1[1,nrstars]{y});{store star CCD x,y position}
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
      equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist1[0,nrstars]{x},starlist1[1,nrstars]{y});{store star CCD x,y position}
      inc(nrstars);
    end;
  end;

  //memo2_message(inttostr(area1)+' '+inttostr(area2)+' '+inttostr(area3)+' '+inttostr(area4));

  if nrstars<nrstars_required then
       SetLength(starlist1,2,nrstars); {fix array length on data for case less stars are found}

  result:=true;{no errors}
end;


procedure binX1_crop(crop {0..1}:double; img : image_array; var img2: image_array);{crop image, make mono, no binning}
  var fitsX,fitsY,k, w,h,  shiftX,shiftY: integer;
      val       : single;
begin
  w:=trunc(crop*width2);  {cropped}
  h:=trunc(crop*height2);

  setlength(img2,1,w,h); {set length of image array}

  shiftX:=round(width2*(1-crop)/2); {crop is 0.9, shift is 0.05*width2}
  shiftY:=round(height2*(1-crop)/2); {crop is 0.9, start at 0.05*height2}

  for fitsY:=0 to h-1 do
    for fitsX:=0 to w-1  do
    begin
      val:=0;
      for k:=0 to naxis3-1 do {all colors and make mono}
         val:=val + img[k,shiftX+fitsx   ,shiftY+fitsY];
      img2[0,fitsX,fitsY]:=val/naxis3;
    end;
  width2:=w;
  height2:=h;
  naxis3:=1;
end;


procedure binX2_crop(crop {0..1}:double; img : image_array; var img2: image_array);{combine values of 4 pixels and crop is required, Result is mono}
  var fitsX,fitsY,k, w,h,  shiftX,shiftY,nrcolors,width5,height5: integer;
      val       : single;
begin
   nrcolors:=Length(img);
   width5:=Length(img[0]);    {width}
   height5:=Length(img[0][0]); {height}

   w:=trunc(crop*width5/2);  {half size & cropped. Use trunc for image 1391 pixels wide like M27 test image. Otherwise exception error}
   h:=trunc(crop*height5/2);

   setlength(img2,1,w,h); {set length of image array}

   shiftX:=round(width5*(1-crop)/2); {crop is 0.9, shift is 0.05*width2}
   shiftY:=round(height5*(1-crop)/2); {crop is 0.9, start at 0.05*height2}

   for fitsY:=0 to h-1 do
      for fitsX:=0 to w-1  do
     begin
       val:=0;
       for k:=0 to nrcolors-1 do {all colors}
         val:=val+(img[k,shiftX+fitsx*2   ,shiftY+fitsY*2]+
                   img[k,shiftX+fitsx*2 +1,shiftY+fitsY*2]+
                   img[k,shiftX+fitsx*2   ,shiftY+fitsY*2+1]+
                   img[k,shiftX+fitsx*2 +1,shiftY+fitsY*2+1])/4;
       img2[0,fitsX,fitsY]:=val/nrcolors;
     end;

   width2:=w;
   height2:=h;
   naxis3:=1;
 end;

procedure binX3_crop(crop {0..1}:double; img : image_array; var img2: image_array);{combine values of 9 pixels and crop is required. Result is mono}
  var fitsX,fitsY,k, w,h,  shiftX,shiftY,nrcolors,width5,height5: integer;
      val       : single;
begin
  nrcolors:=Length(img);
  width5:=Length(img[0]);    {width}
  height5:=Length(img[0][0]); {height}

  w:=trunc(crop*width5/3);  {1/3 size and cropped}
  h:=trunc(crop*height5/3);

  setlength(img2,1,w,h); {set length of image array}

  shiftX:=round(width5*(1-crop)/2); {crop is 0.9, shift is 0.05*width2}
  shiftY:=round(height5*(1-crop)/2); {crop is 0.9, start at 0.05*height2}

  for fitsY:=0 to h-1 do {bin & mono image}
    for fitsX:=0 to w-1  do
    begin
      val:=0;
      for k:=0 to nrcolors-1 do {all colors}
                     val:=val+(img[k,shiftX+fitsX*3   ,shiftY+fitsY*3  ]+
                               img[k,shiftX+fitsX*3   ,shiftY+fitsY*3+1]+
                               img[k,shiftX+fitsX*3   ,shiftY+fitsY*3+2]+
                               img[k,shiftX+fitsX*3 +1,shiftY+fitsY*3  ]+
                               img[k,shiftX+fitsX*3 +1,shiftY+fitsY*3+1]+
                               img[k,shiftX+fitsX*3 +1,shiftY+fitsY*3+2]+
                               img[k,shiftX+fitsX*3 +2,shiftY+fitsY*3  ]+
                               img[k,shiftX+fitsX*3 +2,shiftY+fitsY*3+1]+
                               img[k,shiftX+fitsX*3 +2,shiftY+fitsY*3+2])/9;
       img2[0,fitsX,fitsY]:=val/nrcolors;
    end;
  width2:=w;
  height2:=h;
  naxis3:=1;
end;


procedure binX4_crop(crop {0..1}:double;img : image_array; var img2: image_array);{combine values of 16 pixels and crop is required. Result is mono}
  var fitsX,fitsY,k, w,h,  shiftX,shiftY,nrcolors,width5,height5: integer;
      val       : single;
begin
  nrcolors:=Length(img);
  width5:=Length(img[0]);    {width}
  height5:=Length(img[0][0]); {height}

  w:=trunc(crop*width5/4);  {1/4 size and cropped}
  h:=trunc(crop*height5/4);

  setlength(img2,1,w,h); {set length of image array}

  shiftX:=round(width5*(1-crop)/2); {crop is 0.9, shift is 0.05*width2}
  shiftY:=round(height5*(1-crop)/2); {crop is 0.9, start at 0.05*height2}

  for fitsY:=0 to h-1 do {bin & mono image}
    for fitsX:=0 to w-1  do
    begin
      val:=0;
      for k:=0 to nrcolors-1 do {all colors}
                     val:=val+(img[k,shiftX+fitsX*4   ,shiftY+fitsY*4  ]+
                               img[k,shiftX+fitsX*4   ,shiftY+fitsY*4+1]+
                               img[k,shiftX+fitsX*4   ,shiftY+fitsY*4+2]+
                               img[k,shiftX+fitsX*4   ,shiftY+fitsY*4+3]+
                               img[k,shiftX+fitsX*4 +1,shiftY+fitsY*4  ]+
                               img[k,shiftX+fitsX*4 +1,shiftY+fitsY*4+1]+
                               img[k,shiftX+fitsX*4 +1,shiftY+fitsY*4+2]+
                               img[k,shiftX+fitsX*4 +1,shiftY+fitsY*4+3]+
                               img[k,shiftX+fitsX*4 +2,shiftY+fitsY*4  ]+
                               img[k,shiftX+fitsX*4 +2,shiftY+fitsY*4+1]+
                               img[k,shiftX+fitsX*4 +2,shiftY+fitsY*4+2]+
                               img[k,shiftX+fitsX*4 +2,shiftY+fitsY*4+3]+
                               img[k,shiftX+fitsX*4 +3,shiftY+fitsY*4  ]+
                               img[k,shiftX+fitsX*4 +3,shiftY+fitsY*4+1]+
                               img[k,shiftX+fitsX*4 +3,shiftY+fitsY*4+2]+
                               img[k,shiftX+fitsX*4 +3,shiftY+fitsY*4+3])/16;
         img2[0,fitsX,fitsY]:=val/nrcolors;
    end;
  width2:=w;
  height2:=h;
  naxis3:=1;
end;


procedure bin_and_find_stars(img :image_array;binning:integer;cropping,hfd_min:double;get_hist{update hist}:boolean; var starlist3:star_list);{bin, measure background, find stars}
var
  old_width,old_height,old_naxis3,nrstars,i : integer;
  img_binned : image_array;

begin
  if ((binning>1) or (cropping<1)) then
  begin
    old_width:=width2;
    old_height:=height2;
    old_naxis3:=naxis3;
    if binning>1 then memo2_message('Creating monochromatic x '+inttostr(binning)+' binning image for solving/star alignment.');
    if cropping<>1 then memo2_message('Cropping image x '+floattostrF2(cropping,0,2));

    if binning=2 then binX2_crop(cropping,img,img_binned) {combine values of 4 pixels, default option if 3 and 4 are not specified}
    else
    if binning=3 then binX3_crop(cropping,img,img_binned) {combine values of 9 pixels}
    else
    if binning=4 then binX4_crop(cropping,img,img_binned) {combine values of 16 pixels}
    else
    if binning=1 then binX1_crop(cropping,img,img_binned); {crop image, no binning}

    {test routine, to show bin result}
    //    img_loaded:=img_binned;
    //    naxis3:=1;
    //    plot_fits(mainwindow.image1,true);{plot real}
    //    exit;

    get_background(0,img_binned,true {load hist},true {calculate also standard deviation background},{var}cblack,star_level );{get back ground}
    find_stars(img_binned,hfd_min,starlist3); {find stars of the image and put them in a list}
    img_binned:=nil;
    nrstars:=Length(starlist3[0]);

    if width2<980 then memo2_message('Info: REDUCE OR REMOVE DOWNSAMPLING IS RECOMMENDED. Set this option in stack menu, tab alignment.');
    width2:=old_width; {restore to original size}
    height2:=old_height;
    naxis3:=old_naxis3;

    for i:=0 to nrstars-1 do {correct star positions for cropping. Simplest method}
    begin
      starlist3[0,i]:=starlist3[0,i]*binning+(width2*(1-cropping)/2);{correct star positions for binning/ cropping}
      starlist3[1,i]:=starlist3[1,i]*binning+(height2*(1-cropping)/2);
    end;
  end
  else
  begin
    if height2>2500 then memo2_message('Info: DOWNSAMPLING IS RECOMMENDED FOR LARGE IMAGES. Set this option in stack menu, tab alignment.');
    get_background(0,img,get_hist {load hist},true {calculate also standard deviation background}, {var} cblack,star_level);{get back ground}
    find_stars(img,hfd_min,starlist3); {find stars of the image and put them in a list}
  end;
end;


function report_binning : integer;{select the binning}
begin
  result:=stackmenu1.downsample_for_solving1.itemindex;
  if result<=0 then  {zero gives -1, Auto is 0}
  begin
    if height2>2500 then result:=2
    else
     result:=1;
  end;
end;


function solve_image(img :image_array;get_hist{update hist}:boolean) : boolean;{find match between image and star database}
var
  nrstars,nrstars_required,count,max_distance,nr_quads, minimum_quads,i,database_stars,distance,binning,match_nr,
  spiral_x, spiral_y, spiral_dx, spiral_dy,spiral_t                                                                  : integer;
  search_field,step_size,telescope_ra,telescope_dec,telescope_ra_offset,radius,fov2,fov_org, max_fov,oversize,sep,
  ra7,dec7,centerX,centerY,correctionX,correctionY,cropping, min_star_size_arcsec,hfd_min,delta_ra,current_dist,
  quad_tolerance,dummy, extrastars                                                                                   : double;
  solution, go_ahead ,autoFOV      : boolean;
  Save_Cursor                      : TCursor;
  startTick  : qword;{for timing/speed purposes}
  distancestr,oversize_mess,mess,info_message,warning,suggest_str,memo1_backup,database_uppercase  :string;
const
   popupnotifier_visible : boolean=false;

begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  result:=false;
  esc_pressed:=false;
  warning_str:='';{for header}
  startTick := GetTickCount64;

  if stackmenu1.calibrate_prior_solving1.checked then
  begin
    memo2_message('Calibrating image prior to solving.');
    memo1_backup:=mainwindow.Memo1.Text;{save header text prior to apply dark, flats}
    apply_dark_flat(filter_name,{var} dark_count,flat_count,flatdark_count);{apply dark, flat if required, renew if different exposure or ccd temp. This will clear the header in load_fits}
    mainwindow.Memo1.Text:=memo1_backup;{restore header}
  end;

  binning:=report_binning;
  if height2<960 then warning_str:='Warning, small image!! ';  {for FITS header and solution. Dimensions should be equal or better the about 1280x960}
  if ((binning>1) and (height2<960*binning))   then warning_str:=warning_str+'Warning, downsample factor too high!! '; {for FITS header and solution}
  if (height2>2500*binning) then warning_str:=warning_str+'Warning, increase downsampling!! '; {for FITS header and solution}

  if length(warning_str)>0  then
  begin
     memo2_message(warning_str);
     warning:=#10+warning_str;
  end
  else warning:='';

  quad_tolerance:=strtofloat2(stackmenu1.quad_tolerance1.text);
  if file290 then {.290 database}
    max_fov:=9.53 {warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected}
  else  {.1476 database}
    max_fov:=5.142857143; {warning FOV should be less the database tiles dimensions, so <=5.142857143 degrees. Otherwise a tile beyond next tile could be selected}


  min_star_size_arcsec:=strtofloat2(stackmenu1.min_star_size1.text); {arc sec};

  if ((fov_specified=false) and (cdelt2<>0)) then {no fov in native command line and cdelt2 in header}
    fov_org:=height2*abs(cdelt2) {calculate FOV. PI can give negative CDELT2}
  else
    fov_org:=min(180,strtofloat2(stackmenu1.search_fov1.text));{use specfied FOV in stackmenu. 180 max to prevent runtime errors later}

  autoFOV:=(fov_org=0);{specified auto FOV}

  repeat {autoFOV loop}
    if autoFOV then
    begin
      if fov_org=0 then fov_org:=9.5 else fov_org:=fov_org/1.5;
      memo2_message('Trying FOV: '+floattostrF2(fov_org,0,1));
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
    end;


    hfd_min:=max(0.8,min_star_size_arcsec/(binning*fov_org*3600/height2) );{to ignore hot pixels which are too small}
    bin_and_find_stars(img,binning,cropping,hfd_min,get_hist{update hist}, starlist2);{bin, measure background, find stars. Do this every repeat since hfd_min is adapted}
    nrstars:=Length(starlist2[0]);

    {prepare popupnotifier1 text}
    if stackmenu1.force_oversize1.checked=false then info_message:='▶▶' {normal} else info_message:='▶'; {slow}
    info_message:= ' [' +stackmenu1.radius_search1.text+'°]'+#9+#9+info_message+#9+#9+inttostr(nrstars)+' 🟊' +
                    #10+'↕ '+floattostrf2(fov_org,0,2)+'°'+ #9+#9+inttostr(binning)+'x'+inttostr(binning)+' ⇒ '+inttostr(width2)+'x'+inttostr(height2)+
                    warning+
                    #10+mainwindow.ra1.text+'h,'+mainwindow.dec1.text+'°'+{for tray icon}
                    #10+filename2;

//      nrstars_required:=round(nrstars*(height2/width2)*1.125);{square search field based on height. The 1.125 is an emperical value to compensate for missing stars in the image due to double stars, distortions and so on. The star database should have therefore a little higher density to show the same reference stars}
    nrstars_required:=round(nrstars*(height2/width2));{square search field based on height.}

    solution:=false; {assume no match is found}
    go_ahead:=(nrstars>=5); {bare minimum for two quads}

    if go_ahead then {enough stars, lets find quads}
    begin
      find_quads(starlist2,0 {min length}, quad_smallest,quad_star_distances2);{find star quads for new image. Quads and quad_smallest are binning independend}
      nr_quads:=Length(quad_star_distances2[0]);
      go_ahead:=nr_quads>=3; {enough quads?}

      {The step size is fixed. If a low amount of  quads are detected, the search window (so the database read area) is increased up to 200% guaranteeing that all quads of the image are compared with the database quads while stepping through the sky}
      if nr_quads<25  then oversize:=2 {make dimensions of square search window twice then the image height}
      else
      if nr_quads>100 then oversize:=1 {make dimensions of square search window equal to the image height}
      else
      oversize:=2*sqrt(25/nr_quads);{calculate between 25 th=2 and 100 th=1, quads are area related so take sqrt to get oversize}

      if stackmenu1.force_oversize1.checked then
      begin
        oversize:=2;
        oversize_mess:='Search window at 200%'
      end
      else
      oversize_mess:='Search window at '+ inttostr(round((oversize)*100)) +'% based on the number of quads. Step size at 100% of image height';

      radius:=strtofloat2(stackmenu1.radius_search1.text);{radius search field}

      max_distance:=round(radius/(fov2+0.00001));
      memo2_message(inttostr(nrstars)+' stars, '+inttostr(nr_quads)+' quads selected in the image. '+inttostr(nrstars_required)+' database stars, '+inttostr(round(nr_quads*nrstars_required/nrstars))+' database quads required for the square search field of '+floattostrF2(fov2,0,1)+'°. '+oversize_mess );

      if nr_quads>500 then minimum_quads:=10 else {prevent false detections for star rich images}
      if nr_quads>200 then minimum_quads:=6 else  {prevent false detections for star rich images}
      minimum_quads:=3; {3 quads giving 3 center quad references}

    end
    else
    begin
      memo2_message('Only '+inttostr(nrstars)+' stars found in image. Abort');
      errorlevel:=2;
    end;

    if go_ahead then
    begin
      if select_star_database(lowercase(stackmenu1.star_database1.text))=false then
      begin
        result:=false;
        application.messagebox(pchar('No star database found at '+database_path+' !'+#13+'Download the h18 (or h17, v17) and install'), pchar('ASTAP error:'),0);
        errorlevel:=32;{no star database}
        exit;
      end
      else
      begin
        database_uppercase:=uppercase(name_database);
        stackmenu1.star_database1.text:=database_uppercase;
        memo2_message('Using star database '+database_uppercase);
      end;

      search_field:=fov2*(pi/180);
      STEP_SIZE:=search_field;{fixed step size search spiral. Prior to version 0.9.211 this was reduced for small star counts}
      stackmenu1.Memo2.Lines.BeginUpdate;{do not update tmemo, very very slow and slows down program}
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
          end;{end spiral around [0 0]

          {adapt search field to matrix position, +0+0/+1+0,+1+1,+0+1,-1+1,-1+0,-1-1,+0-1,+1-1..}
          telescope_dec:=STEP_SIZE*spiral_y+dec_radians;

          if ((telescope_dec<=pi/2+search_field) and (telescope_dec>=-pi/2-search_field)) then {within dec range}
          begin {dec withing range}
            telescope_ra_offset:= (STEP_SIZE*spiral_x/cos(telescope_dec));{step larger near pole. This telescope_ra is an offsett from zero}

            if ((telescope_ra_offset<=pi+search_field*2 {required for 180 degrees coverage}) and (telescope_ra_offset>=-pi-search_field*2) ) then {ra and dec within in range, near poles ra goes  much faster}
            begin
              telescope_ra:=fnmodulo(ra_radians+telescope_ra_offset,2*pi);{add offset to ra after the if statement! Otherwise no symmetrical search}

              {info reporting}
              stackmenu1.field1.caption:= '['+inttostr(spiral_x)+','+inttostr(spiral_y)+']';{show on stackmenu what's happening}
              if ((spiral_x>distance) or (spiral_y>distance)) then {new distance reached. Update once in the square spiral, so not too often since it cost CPU time}
              begin
                distance:=max(spiral_x,spiral_y);{update status}
                distancestr:=inttostr(  round((distance) * fov2))+'°';{show on stackmenu what's happening}
                stackmenu1.actual_search_distance1.caption:=distancestr;
                stackmenu1.caption:= 'Search distance:  '+distancestr;
                mainwindow.caption:= 'Search distance:  '+distancestr;

                if commandline_execution then {command line execution}
                begin
                   {$ifdef CPUARM}
                   { tray icon  gives a fatal execution error in the old compiler for armhf}
                   {$else}
                   mainwindow.TrayIcon1.hint:=distancestr+info_message;
                   {$endif}

                   if distance>2 then {prevent flash for short distance solving}
                   begin
                     if popupnotifier_visible=false then begin mainwindow.popupnotifier1.visible:=true; popupnotifier_visible:=true; end; {activate only once}
                     mainwindow.popupnotifier1.text:=distancestr+info_message;
                   end;
                end;
              end; {info reporting}


              {If a low amount of  quads are detected, the search window (so the database read area) is increased up to 200% guaranteeing that all quads of the image are compared with the database quads while stepping through the sky}
              {read nrstars_required stars from database. If search field is oversized, number of required stars increases with the power of the oversize factor. So the star density will be the same as in the image to solve}
              extrastars:=1/1.1;{star with a factor of one}
              repeat {loop to add extra stars if too many too small quads are excluding. Note the database is made by a space telescope with a resolution exceeding all earth telescopes}
                extrastars:=extrastars*1.1;
                if read_stars(telescope_ra,telescope_dec,search_field*oversize,round(nrstars_required*oversize*oversize*extrastars) ,{var}database_stars)= false then
                begin
                  application.messagebox(pchar('No star database found at '+database_path+' !'+#13+'Download the h18 (or h17, v17) and install'), pchar('ASTAP error:'),0);
                  errorlevel:=33;{read error star database}
                  exit; {no stars}
                end;
                find_quads(starlist1,quad_smallest*(fov_org*3600/height2 {pixelsize in"})*0.99 {filter value to exclude too small quads, convert pixels to arcsec as in database}, dummy,quad_star_distances1);{find quads for reference image/database. Filter out too small quads for Earth based telescopes}
                                     {Note quad_smallest is binning independent value. Don't use cdelt2 for pixelsize calculation since fov_specified could be true making cdelt2 unreliable or fov=auto}
              until ((nrstars_required>database_stars) {No more stars available in the database}
                      or (nr_quads<1.1*Length(quad_star_distances1[0])*nrstars/nrstars_required) {Enough quads found. The amount quads could be too low because due to filtering out too small database quads (center m13, M16)in routine find_quads}
                      or (extrastars>15)) {Go up this factor maximum};

              if ((solve_show_log) and  (extrastars>1)) then memo2_message('Too many small quads excluded due to higher resolution database, increased the number of stars with '+inttostr(round((extrastars-1)*100))+'%');

              if solve_show_log then {global variable set in find stars}
                memo2_message('Search '+ inttostr(count)+', ['+inttostr(spiral_x)+','+inttostr(spiral_y)+'],'+#9+'position: '+#9+ prepare_ra(telescope_ra,': ')+#9+prepare_dec(telescope_dec,'° ')+#9+' Up to magn '+ floattostrF2(mag2/10,0,1) +#9+' '+inttostr(database_stars)+' database stars' +#9+' '+inttostr(length(quad_star_distances1[0]))+' database quads to compare.'+mess);

              // for testing purposes
              // create supplement lines for sky coverage testing
              // stackmenu1.memo2.lines.add(floattostr(telescope_ra*12/pi)+',,,'+floattostr(telescope_dec*180/pi)+',,,,'+inttostr(count)+',,-99'); {create hnsky supplement to test sky coverage}

               solution:=find_offset_and_rotation(minimum_quads {>=3},quad_tolerance,false);{find an solution}

              Application.ProcessMessages;
              if esc_pressed then  begin  stackmenu1.Memo2.Lines.EndUpdate; Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
            end;{ra in range}
          end;{dec within range}
          inc(count);{step further in spiral}

        until ((solution) or (spiral_x>max_distance));{squared spiral search}

        if solution then
        begin
          centerX:=(width2-1)/2 ;{center image in 0..width2-1 range}
          centerY:=(height2-1)/2;{center image in 0..height2-1 range}
          crpix1:=centerX+1;{center image in fits coordinate range 1..width2}
          crpix2:=centery+1;

          standard_equatorial( telescope_ra,telescope_dec,
              (solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY) +solution_vectorX[2]), {x}
              (solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY) +solution_vectorY[2]), {y}
              1, {CCD scale}
              ra0 ,dec0{center equatorial position});
          if match_nr=0 then ang_sep(ra_radians,dec_radians,ra0,dec0, sep);{offset found}
          ra_radians:=ra0;
          dec_radians:=dec0;
          current_dist:=sqrt(sqr(solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY) +solution_vectorX[2]) + sqr(solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY) +solution_vectorY[2]))/3600; {current distance telescope and image center in degrees}
          inc(match_nr);
        end;
      until ((solution=false) or (current_dist<fov2*0.05){within 5% if image height from center}  or (match_nr>=2));{Maximum accurcy loop. After match possible on a corner do a second solve using the found ra0,dec0 for maximum accuracy USING ALL STARS}

      stackmenu1.Memo2.Lines.EndUpdate;
    end; {enough quads in image}
  until ((autoFOV=false) or (solution) or (fov2<=0.38)); {loop for autoFOV from 9.5 to 0.37 degrees. Will lock between 9.5*1.25 downto  0.37/1.25  or 11.9 downto 0.3 degrees}

  if solution then
  begin
    memo2_message(inttostr(nr_references)+ ' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.'  {2 quads are required giving 8 star references or 3 quads giving 3 center quad references}
                   +'  Solution["] x:='+floattostr6(solution_vectorX[0])+'*x+ '+floattostr6(solution_vectorX[1])+'*y+ '+floattostr6(solution_vectorX[2])
                   +',  y:='+floattostr6(solution_vectorY[0])+'*x+ '+floattostr6(solution_vectorY[1])+'*y+ '+floattostr6(solution_vectorY[2]) );
    //  following doesn't give maximum angle accuracy, so is not used.
    //    cd1_1:= - solution_vectorX[0]/3600;{/3600, arcsec to degrees conversion}
    //    cd1_2:= - solution_vectorX[1]/3600;
    //    cd2_1:= + solution_vectorY[0]/3600;
    //    cd2_2:= + solution_vectorY[1]/3600;

    // rather then using the solution vector directly, for maximum accuracy find the vector for the center of the image.
    //make 1 step in direction crpix1
    standard_equatorial( telescope_ra,telescope_dec,
        (solution_vectorX[0]*(centerX+1) + solution_vectorX[1]*(centerY) +solution_vectorX[2]), {x}
        (solution_vectorY[0]*(centerX+1) + solution_vectorY[1]*(centerY) +solution_vectorY[2]), {y}
        1, {CCD scale}
        ra7 ,dec7{center equatorial position});

    delta_ra:=ra7-ra0;
    if delta_ra>+pi then delta_ra:=2*pi-delta_ra; {359-> 1,    +2:=360 - (359- 1)}
    if delta_ra<-pi then delta_ra:=delta_ra-2*pi; {1  -> 359,  -2:=(1-359) -360  }
    cd1_1:=(delta_ra)*cos(dec0)*(180/pi);
    cd2_1:=(dec7-dec0)*(180/pi);

    //make 1 step in direction crpix2
    standard_equatorial( telescope_ra,telescope_dec,
        (solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY+1) +solution_vectorX[2]), {x}
        (solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY+1) +solution_vectorY[2]), {y}
         1, {CCD scale}
        ra7 ,dec7{center equatorial position});

    delta_ra:=ra7-ra0;
    if delta_ra>+pi then delta_ra:=2*pi-delta_ra; {359-> 1,    +2:=360 - (359- 1)}
    if delta_ra<-pi then delta_ra:=delta_ra-2*pi; {1  -> 359,  -2:=(1-359) -360  }
    cd1_2:=(delta_ra)*cos(dec0)*(180/pi);
    cd2_2:=(dec7-dec0)*(180/pi);

    new_to_old_WCS;
    solved_in:=' Solved in '+ floattostr(round((GetTickCount64 - startTick)/100)/10)+' sec.';{make string to report in FITS header.}

    offset_found:=' Δ was '+distance_to_string(sep {scale selection},sep)+'.';
    if ra_mount<99 then {mount position known and specified}
       offset_found:=offset_found+#9+ ' Mount offset Δα='+distance_to_string(dec_mount-dec0,(ra_mount-ra0)*cos(dec0))+ ', Δδ='+distance_to_string(dec_mount-dec0,dec_mount-dec0);
//    offset_found:=' Δ was '+floattostrF2(sep*60*180/pi,0,2)+#39+'.'+#9+ '  Mount offset  Δα='+floattostrF2((ra_mount-ra0)*cos(dec0)*60*180/pi,0,2)+#39 + ',  Δδ='+floattostrF2((ra_mount-ra0)*60*180/pi,0,2)+#39;

    memo2_message('Solution found: '+  prepare_ra(ra0,': ')+#9+prepare_dec(dec0,'° ') +#9+ solved_in+#9+offset_found+#9+' Used stars up to magnitude: '+floattostrF2(mag2/10,0,1) );
    mainwindow.caption:=('Solution found:    '+  prepare_ra(ra0,': ')+'     '+prepare_dec(dec0,'° ')  );
    result:=true;

    update_text ('CTYPE1  =',#39+'RA---TAN'+#39+'           / first parameter RA  ,  projection TANgential   ');
    update_text ('CTYPE2  =',#39+'DEC--TAN'+#39+'           / second parameter DEC,  projection TANgential   ');
    update_text ('CUNIT1  =',#39+'deg     '+#39+'           / Unit of coordinates                            ');

    update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,crpix1);
    update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,crpix2);

    update_float  ('CRVAL1  =',' / RA of reference pixel (deg)                    ' ,ra0*180/pi);
    update_float  ('CRVAL2  =',' / DEC of reference pixel (deg)                   ' ,dec0*180/pi);

    update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,cdelt1);
    update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,cdelt2);

    update_float  ('CROTA1  =',' / Image twist of X axis        (deg)             ' ,crota1);
    update_float  ('CROTA2  =',' / Image twist of Y axis        (deg)             ' ,crota2);

    update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_1);
    update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_2);
    update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_1);
    update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_2);
    update_text   ('PLTSOLVD=','                   T / ASTAP internal solver      ');
    update_text   ('COMMENT 6', solved_in+offset_found);

    if solve_show_log then {global variable set in find stars}
    begin
      equatorial_standard(telescope_ra,telescope_dec,ra0,dec0,1,correctionX,correctionY);{calculate correction for x,y position of database center and image center}
      plot_stars_used_for_solving(correctionX,correctionY); {plot image stars and database stars used for the solution}
      memo2_message('See viewer image for image stars used (red) and database star used (yellow)');
    end;

    if ( (fov_org>1.05*(height2*cdelt2) ) or (fov_org<0.95*(height2*cdelt2)) ) then
    begin
      if xpixsz<>0 then suggest_str:='Warning scale was inaccurate! Set FOV='+floattostrF2(height2*cdelt2,0,2)+'d, scale='+floattostrF2(cdelt2*3600,0,1)+'", FL='+inttostr(round((180/(pi*1000)*xpixsz/cdelt2)) )+'mm'
                   else suggest_str:='Warning scale was inaccurate! Set FOV='+floattostrF2(height2*cdelt2,0,2)+'d, scale='+floattostrF2(cdelt2*3600,0,1)+'"';
      memo2_message(suggest_str);
      warning_str:=suggest_str+warning_str;
    end;
  end
  else
  begin
    memo2_message('No solution found!  :(');
    mainwindow.caption:='No solution found!  :(';
    update_text   ('PLTSOLVD=','                   F / No plate solution found.   ');
    remove_key('COMMENT 6',false{all});
  end;

  if nrstars_required>database_stars+4 then
  begin
    memo2_message('Warning, reached maximum magnitude of star database!');
    warning_str:=warning_str+' Star database limit was reached!';
  end;

  if warning_str<>'' then
  begin
    update_longstr('WARNING =',warning_str);{update or insert long str including single quotes}
  end;

  Screen.Cursor :=Save_Cursor;    { back to normal }
end;


begin
end.
