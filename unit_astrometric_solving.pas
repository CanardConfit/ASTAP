unit unit_astrometric_solving;
{Copyright (C) 2018, 2019 by Han Kleijn, www.hnsky.org
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

To automate this process rather then using reference stars the matching reference objects are the center positions of tetrahedrons made of four close stars. Comparing the length ratios
of the sides of the tetrahedrons allows automated matching.

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
//3) 	Use the extracted stars to construct the smallest irregular tetrahedrons | Uses the stars to construct the smallest irregular tetrahedrons of four
//      of four  star (quads). Calculate the length of the six tetrahedron edges | stars (quads). Calculate the length of the six tetrahedron edges
//      in pixels and the mean x,y position of the tetrahedrons.                 | in pixels and the mean x, y position of the tetrahedrons.
//                                                                               |
//4) 	Sort the six tetrahedron edges on length for each tetrahedron. 	         | Sort the six tetrahedron edges on length for each tetrahedron.
//      e1 is the longest and e6 shortest.                                       | e1 is the longest and e6 shortest.
//                                                                               |
//5) 	Scale the tetrahedron edges as (e1, e2/e1,e3/e1,e4/e1,e5/e1,e6/e1)       | Scale the tetrahedron edges as (e1, e2/e1,e3/e1,e4/e1,e5/e1,e6/e1)
//
//                           => matching process <=
//6)                         Find tetrahedrons matches where edges e2/e1 to e6/e1 match within a small tolerance.
//
//7) 		             For matching tetrahedrons, calculate the size ratio e1_found/e1_reference and find μ (mean), σ (standard deviation) of these ratios.
//                           Remove the outlier tetrahedrons with a ratio above 3 * σ.
//
//8)                         From the remaining matching tetrahedrons, prepare the "A"matrix/array containing the x,y center positions of the test image tetrahedrons in standard coordinates
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
       unit_star_align, unit_290, astap_main, unit_stack, unit_annotation;

function solve_image(img :image_array; get_hist{update hist}:boolean) : boolean;{find match between image and star database}
procedure bin_and_find_stars(img :image_array;binning:integer;cropping:double;get_hist{update hist}:boolean; var starlist3:star_list);{bin, measure background, find stars}
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
  ra  := ra0 + arctan (-x / (cos_DEC0- y*sin_DEC0) );
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


  nrstars:=0;{set counters at zero}
  SetLength(starlist1,2,nrstars_required);{set array length}


  find_areas( telescope_ra,telescope_dec, search_field,{var} area1,area2,area3,area4, frac1,frac2,frac3,frac4);{find up to four star database areas for the square image}

  {read 1th area}
  if area1<>0 then {read 1th area}
  begin
  nrstars_required2:=min(nrstars_required,trunc(nrstars_required * frac1));
  while ((nrstars<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, search_field,area1, {var} ra2,dec2, mag2,Bp_Rp)) ) do{star 290 file database read. Read up to nrstars_required}
  begin {add star}
    equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist1[0,nrstars]{x},starlist1[1,nrstars]{y});{store star CCD x,y position}
    inc(nrstars);
  end;
  close_star_database;{close reader, so next time same file is read from beginning}
  end;

  if area2<>0 then {read 2th area}
  begin
    nrstars_required2:=min(nrstars_required,trunc(nrstars_required * (frac1+frac2)));{prevent round up errors resulting in error starlist1}
    while ((nrstars<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, search_field,area2, {var} ra2,dec2, mag2,Bp_Rp)) ) do{star 290 file database read. Read up to nrstars_required}
    begin {add star}
      equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist1[0,nrstars]{x},starlist1[1,nrstars]{y});{store star CCD x,y position}
      inc(nrstars);
    end;
    close_star_database;{close reader, so next time same file is read from beginning}
  end;

  if area3<>0 then {read 3th area}
  begin
    nrstars_required2:=min(nrstars_required,trunc(nrstars_required * (frac1+frac2+frac3)));
    while ((nrstars<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, search_field,area3, {var} ra2,dec2, mag2,Bp_Rp)) ) do{star 290 file database read. Read up to nrstars_required}
    begin {add star}
      equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist1[0,nrstars]{x},starlist1[1,nrstars]{y});{store star CCD x,y position}
      inc(nrstars);
    end;
    close_star_database;{close reader, so next time same file is read from beginning}
  end;

  if area4<>0 then {read 4th area}
  begin
    nrstars_required2:=min(nrstars_required,trunc(nrstars_required * (frac1+frac2+frac3+frac4)));
    while ((nrstars<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, search_field,area4, {var} ra2,dec2, mag2,Bp_Rp)) ) do{star 290 file database read. Read up to nrstars_required}
    begin {add star}
      equatorial_standard(telescope_ra,telescope_dec,ra2,dec2,1,starlist1[0,nrstars]{x},starlist1[1,nrstars]{y});{store star CCD x,y position}
      inc(nrstars);
    end;
    close_star_database;{close reader, so next time same file is read from beginning}
  end;



  if nrstars<nrstars_required then
       SetLength(starlist1,2,nrstars); {fix array length on data for case less stars are found}

  result:=files_available;
end;

//procedure set_trayicon(i:integer);
//var aBMP: TBitmap; {uses unit graphics}
//begin
//  aBMP:=tBitmap.Create;
//  mainwindow.ImageList1.GetBitmap(i, aBMP);
//  mainwindow.TrayIcon1.icon.assign(aBMP);
//  aBMP.Free;
//end;


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


procedure binX2_crop(crop {0..1}:double; img : image_array; var img2: image_array);{combine values of 4 pixels and crop is required}
  var fitsX,fitsY,k, w,h,  shiftX,shiftY: integer;
      val       : single;
begin
   w:=trunc(crop*width2/2);  {half size & cropped. Use trunc for image 1391 pixels wide like M27 test image. Otherwise exception error}
   h:=trunc(crop*height2/2);

   setlength(img2,1,w,h); {set length of image array}

   shiftX:=round(width2*(1-crop)/2); {crop is 0.9, shift is 0.05*width2}
   shiftY:=round(height2*(1-crop)/2); {crop is 0.9, start at 0.05*height2}

   for fitsY:=0 to h-1 do
      for fitsX:=0 to w-1  do
     begin
       val:=0;
       for k:=0 to naxis3-1 do {all colors}
         val:=val+(img[k,shiftX+fitsx*2   ,shiftY+fitsY*2]+
                   img[k,shiftX+fitsx*2 +1,shiftY+fitsY*2]+
                   img[k,shiftX+fitsx*2   ,shiftY+fitsY*2+1]+
                   img[k,shiftX+fitsx*2 +1,shiftY+fitsY*2+1])/4;
       img2[0,fitsX,fitsY]:=val/naxis3;
     end;

   width2:=w;
   height2:=h;
   naxis3:=1;
 end;

procedure binX3_crop(crop {0..1}:double; img : image_array; var img2: image_array);{combine values of 9 pixels and crop is required}
  var fitsX,fitsY,k, w,h,  shiftX,shiftY: integer;
      val       : single;
begin
  w:=trunc(crop*width2/3);  {1/3 size and cropped}
  h:=trunc(crop*height2/3);

  setlength(img2,1,w,h); {set length of image array}

  shiftX:=round(width2*(1-crop)/2); {crop is 0.9, shift is 0.05*width2}
  shiftY:=round(height2*(1-crop)/2); {crop is 0.9, start at 0.05*height2}

  for fitsY:=0 to h-1 do {bin & mono image}
    for fitsX:=0 to w-1  do
    begin
      val:=0;
      for k:=0 to naxis3-1 do {all colors}
                     val:=val+(img[k,shiftX+fitsX*3   ,shiftY+fitsY*3  ]+
                               img[k,shiftX+fitsX*3   ,shiftY+fitsY*3+1]+
                               img[k,shiftX+fitsX*3   ,shiftY+fitsY*3+2]+
                               img[k,shiftX+fitsX*3 +1,shiftY+fitsY*3  ]+
                               img[k,shiftX+fitsX*3 +1,shiftY+fitsY*3+1]+
                               img[k,shiftX+fitsX*3 +1,shiftY+fitsY*3+2]+
                               img[k,shiftX+fitsX*3 +2,shiftY+fitsY*3  ]+
                               img[k,shiftX+fitsX*3 +2,shiftY+fitsY*3+1]+
                               img[k,shiftX+fitsX*3 +2,shiftY+fitsY*3+2])/9;
       img2[0,fitsX,fitsY]:=val/naxis3;
    end;
  width2:=w;
  height2:=h;
end;

procedure binX4_crop(crop {0..1}:double;img : image_array; var img2: image_array);{combine values of 16 pixels and crop is required}
  var fitsX,fitsY,k, w,h,  shiftX,shiftY: integer;
      val       : single;
begin
  w:=trunc(crop*width2/4);  {1/4 size and cropped}
  h:=trunc(crop*height2/4);

  setlength(img2,1,w,h); {set length of image array}

  shiftX:=round(width2*(1-crop)/2); {crop is 0.9, shift is 0.05*width2}
  shiftY:=round(height2*(1-crop)/2); {crop is 0.9, start at 0.05*height2}

  for fitsY:=0 to h-1 do {bin & mono image}
    for fitsX:=0 to w-1  do
    begin
      val:=0;
      for k:=0 to naxis3-1 do {all colors}
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
         img2[0,fitsX,fitsY]:=val/naxis3;
    end;
  width2:=w;
  height2:=h;
end;

procedure bin_and_find_stars(img :image_array;binning:integer;cropping:double;get_hist{update hist}:boolean; var starlist3:star_list);{bin, measure background, find stars}
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
    find_stars(img_binned,starlist3); {find stars of the image and put them in a list}
    img_binned:=nil;
    nrstars:=Length(starlist3[0])-1;

    if width2<1000 then memo2_message('Info: REDUCE OR REMOVE DOWNSAMPLING IS RECOMMENDED. Set this option in stack menu, tab alignment.');
    width2:=old_width; {restore to original size}
    height2:=old_height;
    naxis3:=old_naxis3;


    for i:=1 to nrstars do {correct star positions for cropping. Simplest method}
    begin
      starlist3[0,i]:={(binning-1)/2} + starlist3[0,i]*binning+(width2*(1-cropping)/2);{correct star positions for binning/ cropping}
      starlist3[1,i]:={(binning-1)/2} + starlist3[1,i]*binning+(height2*(1-cropping)/2);
    end;
  end
  else
  begin
    if height2>2500 then memo2_message('Info: DOWNSAMPLING IS RECOMMENDED FOR LARGE IMAGES. Set this option in stack menu, tab alignment.');
    get_background(0,img_loaded,get_hist {load hist},true {calculate also standard deviation background}, {var} cblack,star_level);{get back ground}
    find_stars(img,starlist3); {find stars of the image and put them in a list}
    //nrstars:=Length(starlist3[0])-1;
  end;
end;

function report_binning : integer;{select the binning}
begin
  result:=stackmenu1.downsample_for_solving1.itemindex;
  if result<=0 then  {zero gives -1, Auto is 0}
  begin
    if height2>5000 then result:=4
    else
    if height2>2500 then result:=2
    else
     result:=1;
  end;
end;

function solve_image(img :image_array;get_hist{update hist}:boolean) : boolean;{find match between image and star database}
var
  nrstars,nrstars_required,count,max_distance,nr_tetrahedrons, minimum_tetrahedrons,i,database_stars,distance,binning : integer;
  search_field,step_size,telescope_ra,telescope_dec,telescope_ra_offset,radius,fov, max_fov,oversize,sep,ra7,dec7,centerX,centerY,correctionX,correctionY,cropping, flat_factor: double;
  solution, go_ahead,solve_show_log  : boolean;
  Save_Cursor     : TCursor;
  startTick  : qword;{for timing/speed purposes}
  distancestr,oversize_mess,mess,info_message  :string;
  spiral_x, spiral_y, spiral_dx, spiral_dy,spiral_t : integer;
  {trayicon_visible,}autoFOV : boolean;
const
   popupnotifier_visible : boolean=false;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  result:=false;
  esc_pressed:=false;
  startTick := GetTickCount64;

  if stackmenu1.calibrate_prior_solving1.checked then
  begin
    memo2_message('Calibrating image prior to solving.');
    apply_dark_flat(filter_name,round(exposure),set_temperature,width2,{var} dark_count,flat_count,flatdark_count,flat_factor);{apply dark, flat if required, renew if different exposure or ccd temp}
  end;

//  binning:=stackmenu1.downsample_for_solving1.itemindex;
//  if binning<=0 then  {zero gives -1, Auto is 0}
//  begin
//    if height2>5000 then binning:=4
//    else
//    if height2>2500 then binning:=2
//    else
//    binning:=1;
//  end;

  binning:=report_binning;

  if stackmenu1.force_oversize1.checked=false then info_message:='▶▶' {normal} else info_message:='▶'; {slow}
  info_message:= ' [' +stackmenu1.radius_search1.text+'°]'+#9+#9+info_message+
                  #10+'↕ '+stackmenu1.search_fov1.text+'°'+ #9+#9+inttostr(binning)+'x'+inttostr(binning)+' ⇒ '+inttostr(width2)+'x'+inttostr(height2)+
                  #10+mainwindow.ra1.text+'h,'+mainwindow.dec1.text+'°'+{for tray icon}
                  #10+filename2;

//  trayicon_visible:=mainwindow.TrayIcon1.visible;



  max_fov:=strtofloat(stackmenu1.max_fov1.caption);{for very large images only}
  max_fov:=min(max_fov,9.53);{warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected}


  if ((fov_specified=false) and (cdelt2<>0)) then {no fov in native command line and cdelt2 in header}
    fov:=height2*cdelt2 {calculate FOV}
  else
   fov:=strtofloat2(stackmenu1.search_fov1.text);{use specfied FOV in stackmenu}

  autoFOV:=(fov=0);{specified auto FOV}

  repeat {autoFOV loop}
    if autoFOV then
    begin
      if fov=0 then fov:=9.5 else fov:=fov/1.5;
      memo2_message('Trying FOV: '+floattostrF2(fov,0,1));
    end;

    if fov>max_fov then
    begin
      cropping:=max_fov/fov;
      fov:=max_fov; {temporary cropped image, adjust FOV to adapt}
    end
    else cropping:=1;


//    if ((binning>1) or (cropping<1)) then
//    begin
//      old_width:=width2;
//      old_height:=height2;
//      old_naxis3:=naxis3;
//      if binning>1 then memo2_message('Creating monochromatic x '+inttostr(binning)+' binning image to solve.');
//      if cropping<>1 then memo2_message('Cropping image x '+floattostrF2(cropping,0,2));

//      if binning=2 then binX2_crop(cropping,img,img_binned) {combine values of 4 pixels, default option if 3 and 4 are not specified}
//      else
//      if binning=3 then binX3_crop(cropping,img,img_binned) {combine values of 9 pixels}
//      else
//      if binning=4 then binX4_crop(cropping,img,img_binned) {combine values of 16 pixels}
//      else
//      if binning=1 then binX1_crop(cropping,img,img_binned); {crop image, no binning}

      {test routine, to show bin result}
     //    img_loaded:=img_binned;
     //    naxis3:=1;
     //    plot_fits(mainwindow.image1,true);{plot real}
     //    exit;

//      get_background(0,img_binned,true {load hist},true {calculate also standard deviation background},{var}cblack,star_level );{get back ground}
//      find_stars(img_binned,starlist2); {find stars of the image and put them in a list}
//      img_binned:=nil;
//      nrstars:=Length(starlist2[0])-1;

//      if width2<1000 then memo2_message('Info: REDUCE OR REMOVE DOWNSAMPLING IS RECOMMENDED. Set this option in stack menu, tab alignment.');
//      width2:=old_width; {restore to original size}
//      height2:=old_height;
//      naxis3:=old_naxis3;


//      for i:=1 to nrstars do {correct star positions for cropping. Simplest method}
//      begin
//        starlist2[0,i]:={(binning-1)/2} + starlist2[0,i]*binning+(width2*(1-cropping)/2);{correct star positions for binning/ cropping}
//        starlist2[1,i]:={(binning-1)/2} + starlist2[1,i]*binning+(height2*(1-cropping)/2);
//      end;
//    end
//    else
//    begin

//      if height2>2500 then memo2_message('Info: DOWNSAMPLING IS RECOMMENDED FOR LARGE IMAGES. Set this option in stack menu, tab alignment.');
//      get_background(0,img_loaded,get_hist {load hist},true {calculate also standard deviation background}, {var} cblack,star_level);{get back ground}
//      find_stars(img,starlist2); {find stars of the image and put them in a list}
//      nrstars:=Length(starlist2[0])-1;
//    end;

    bin_and_find_stars(img,binning,cropping,get_hist{update hist}, starlist2);{bin, measure background, find stars}

    nrstars:=Length(starlist2[0])-1;
    nrstars_required:=round(nrstars*(height2/width2)*1.25);{square search field based on height. The 1.25 is an emperical value to compensate for missing stars in the image due to double stars, distortions and so on. The star database should have therefore a little higher density to show the same reference stars}
  //  nrstars_required:=round(nrstars*(height2/width2)*factorX);{square search field based on height. The 1.25 is an emperical value to compensate for missing stars in the image due to double stars, distortions and so on. The star database should have therefore a little higher density to show the same reference stars}

    solve_show_log:=stackmenu1.solve_show_log1.Checked;{show details}
    solution:=false; {assume no match is found}
    go_ahead:=(nrstars>=6); {should be more but let's try}

    if go_ahead then {enough stars, lets find tetrahedrons}
    begin
      find_tetrahedrons_new;{find tetrahedrons for new image}
      nr_tetrahedrons:=Length(starlisttetrahedrons2[0]);
      go_ahead:=nr_tetrahedrons>=3; {enough tetrahedrons?}

      {from version 0.9.212, the step size is fixed. If a low amount of  tetrahedrons are detected, the search window (so the database read area) is increased up to 200% guaranteeing that all tetrahedrons of the image are compared with the database tetrahedrons while stepping through the sky}
      if nr_tetrahedrons<25  then oversize:=2 {make dimensions of square search window twice then the image height}
      else
      if nr_tetrahedrons>100 then oversize:=1 {make dimensions of square search window equal to the image height}
      else
      oversize:=2*sqrt(25/nr_tetrahedrons);{calculate between 25 th=2 and 100 th=1, tetrahedrons are area related so take sqrt to get oversize}

      if stackmenu1.force_oversize1.checked then
      begin
        oversize:=2;
        oversize_mess:='Search window at 200%'
      end
      else
      oversize_mess:='Search window at '+ inttostr(round((oversize)*100)) +'% based on the number of tetrahedrons. Step size at 100% of image height';

      radius:=strtofloat2(stackmenu1.radius_search1.text);{radius search field}

      max_distance:=round(radius/(fov+0.00001));
      memo2_message(inttostr(nrstars)+' stars selected and '+inttostr(nr_tetrahedrons)+' tetrahedrons selected in the image. '+inttostr(nrstars_required)+' database stars required for the square search field of '+floattostrF2(fov,0,1)+'°. '+oversize_mess );

      if nr_tetrahedrons>500 then minimum_tetrahedrons:=10 else {prevent false detections for star rich images}
      if nr_tetrahedrons>200 then minimum_tetrahedrons:=6 else  {prevent false detections for star rich images}
      minimum_tetrahedrons:=3;

    end
    else memo2_message('Only '+inttostr(nrstars)+' stars found in image. Abort');

    if go_ahead then
    begin
      if select_star_database(stackmenu1.star_database1.text)=false then
      begin
        result:=false;
        application.messagebox(pchar('No star database found in the program directory!'+#13+'Download the g17 (or g16 or g18) and install'), pchar('ASTAP error:'),0);
        exit;
      end
      else stackmenu1.star_database1.text:=name_star;

      search_field:=fov*(pi/180);
      STEP_SIZE:=search_field;{fixed step size search spiral. Prior to version 0.9.211 this was reduced for small star counts}


      memo2_message('Using star database '+name_star);

      count:=0;{search field counter}
      stackmenu1.Memo2.Lines.BeginUpdate;{do not update tmemo, very very slow and slows down program}

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
            //telescope_ra:= telescope_ra+ra_radians;
            telescope_ra:=fnmodulo(ra_radians+telescope_ra_offset,2*pi);{add offset to ra after the if statement! Otherwise no symmetrical search}

            {info reporting}
            stackmenu1.field1.caption:= '['+inttostr(spiral_x)+','+inttostr(spiral_y)+']';{show on stackmenu what's happening}
            if ((spiral_x>distance) or (spiral_y>distance)) then {new distance reached. Update once in the square spiral, so not too often since it cost CPU time}
            begin
              distance:=max(spiral_x,spiral_y);{update status}
              distancestr:=inttostr(  round((distance) * fov{/overlap}))+'°';{show on stackmenu what's happening}
              stackmenu1.actual_search_distance1.caption:=distancestr;
              stackmenu1.caption:= 'Search distance:  '+distancestr;
              mainwindow.caption:= 'Search distance:  '+distancestr;

              if command_execution then {command line execution}
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
            end;
            {info reporting}

            {from version 0.9.212, the step size is fixed. If a low amount of  tetrahedrons are detected, the search window (so the database read area) is increased up to 200% guaranteeing that all tetrahedrons of the image are compared with the database tetrahedrons while stepping through the sky}
            {read nrstars_required stars from database. If search field is oversized, number of required stars increases with the power of the oversize factor. So the star density will be the same as in the image to solve}
            if read_stars(telescope_ra,telescope_dec,search_field*oversize,round(nrstars_required*oversize*oversize) ,{var}database_stars)= false then
            begin
              application.messagebox(pchar('Error, some of the 290 star database files are missing!'+#13+'Download the g17 (or g16 or g18) and extract the files to the program directory.'),0 );
              exit; {no stars}
            end;

            find_tetrahedrons_ref;{find star tetrahedrons, use database as reference image}
            if solve_show_log then
            begin
              if (nrstars_required>database_stars) then  mess:=#9+' Warning, reached maximum magnitude of star database!' else mess:='';
              memo2_message('Search '+ inttostr(count)+', ['+inttostr(spiral_x)+','+inttostr(spiral_y)+'],'+#9+'position: '+#9+ prepare_ra(telescope_ra,':')+#9+prepare_dec(telescope_dec,'d')+#9+' Up to magn '+ floattostrF2(mag2/10,0,1) +#9+' '+inttostr(length(starlisttetrahedrons1[0]))+' database tetrahedrons to compare.'+mess);
            end;

            // for testing purposes
            // create supplement lines for sky coverage testing
            // stackmenu1.memo2.lines.add(floattostr(telescope_ra*12/pi)+',,,'+floattostr(telescope_dec*180/pi)+',,,,'+inttostr(count)+',,-99'); {create hnsky supplement to test sky coverage}

            if length(starlisttetrahedrons1[0])>=3 then {enough pyramaids, lets try to find a match}
               solution:=find_offset_and_rotation(minimum_tetrahedrons {>=3},strtofloat2(stackmenu1.tetrahedron_tolerance1.text),false);{find an solution}

            Application.ProcessMessages;
            if esc_pressed then  begin  stackmenu1.Memo2.Lines.EndUpdate; Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
          end;{ra in range}
        end;{dec within range}
        inc(count);{step further in spiral}

      until ((solution) or (spiral_x>max_distance));
      stackmenu1.Memo2.Lines.EndUpdate;

    end; {enough tetrahedrons in image}

  until ((autoFOV=false) or (solution) or (fov<=0.56)); {loop for autoFOV}

  if solution then
  begin
    memo2_message(inttostr(nr_references)+ ' of '+ inttostr(nr_references2)+' tetrahedrons selected matching within '+stackmenu1.tetrahedron_tolerance1.text+' tolerance.'
                   +'  Solution x:='+floattostr2(solution_vectorX[0])+'*x+ '+floattostr2(solution_vectorX[1])+'*y+ '+floattostr2(solution_vectorX[2])
                   +',  y:='+floattostr2(solution_vectorY[0])+'*x+ '+floattostr2(solution_vectorY[1])+'*y+ '+floattostr2(solution_vectorY[2]) );
    centerX:=(width2-1)/2 ;{center image in 0..width2-1 range}
    centerY:=(height2-1)/2;{center image in 0..height2-1 range}
    crpix1:=centerX+1;{center image in fits coordinate range 1..width2}
    crpix2:=centery+1;

    standard_equatorial( telescope_ra,telescope_dec,
        (solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY) +solution_vectorX[2]), {x}
        (solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY) +solution_vectorY[2]), {y}
        1, {CCD scale}
        ra0 ,dec0{center equatorial position});

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

    cd1_1:=(ra7-ra0)*cos(dec0)*(180/pi);
    cd2_1:=(dec7-dec0)*(180/pi);

    //make 1 step in direction crpix2
    standard_equatorial( telescope_ra,telescope_dec,
        (solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY+1) +solution_vectorX[2]), {x}
        (solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY+1) +solution_vectorY[2]), {y}
         1, {CCD scale}
        ra7 ,dec7{center equatorial position});

    cd1_2:=(ra7-ra0)*cos(dec0)*(180/pi);
    cd2_2:=(dec7-dec0)*(180/pi);

    new_to_old_WCS;
    solved_in:=' Solved in '+ floattostr(round((GetTickCount64 - startTick)/100)/10)+' sec.';{make string to report in FITS header.}
    ang_sep(ra_radians,dec_radians,ra0,dec0, sep);
    offset_found:=' Offset was '+floattostrF2(sep*180/pi,0,3)+' deg.';
    memo2_message('Solution found: '+  prepare_ra(ra0,':')+#9+prepare_dec(dec0,'d') +#9+ solved_in+offset_found+#9+' Used stars up to magnitude: '+floattostrF2(mag2/10,0,1) );
    mainwindow.caption:=('Solution found:    '+  prepare_ra(ra0,':')+'     '+prepare_dec(dec0,'d')  );
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
    update_text   ('COMMENT 1', solved_in+offset_found);

    if solve_show_log then
    begin
      equatorial_standard(telescope_ra,telescope_dec,ra0,dec0,1,correctionX,correctionY);{calculate correction for x,y position of database center and image center}
      plot_stars_used_for_solving(correctionX,correctionY); {plot image stars and database stars used for the solution}
      memo2_message('See viewer image for image stars used (red) and database star used (yellow)');
    end;

  end
  else
  begin
    if (nrstars_required>database_stars) then memo2_message('Warning, reached maximum magnitude of star database!');
    memo2_message('No solution found!  :(');
    mainwindow.caption:='No solution found!  :(';
    update_text   ('PLTSOLVD=','                   F / No plate solution found.   ');
    update_text   ('COMMENT 1','                                                  ');
  end;
  Screen.Cursor :=Save_Cursor;    { back to normal }
end;



begin
end.
