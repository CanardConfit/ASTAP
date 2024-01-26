unit unit_command_line_solving;
{Copyright (C) 2017, 2024 by Han Kleijn, www.hnsky.org
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

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,math;

type
  image_array = array of array of array of Single;
  star_list   = array of array of double;
  solution_vector   = array[0..2] of double;

var
   quad_star_distances1, quad_star_distances2: star_list;
   A_XYpositions                          : star_list;
   b_Xrefpositions,b_Yrefpositions        :  array of double;
   quad_smallest                          : double;
   nr_references,nr_references2               : integer;
   solution_vectorX, solution_vectorY,solution_cblack   : solution_vector ;
   Savefile: file of solution_vector;{to save solution if required for second and third step stacking}


procedure find_stars(img :image_array;hfd_min:double;out starlist1: star_list);{find stars and put them in a list}
procedure find_quads(starlist :star_list; min_leng:double; out quad_smallest:double; out quad_star_distances :star_list);  {build quads using closest stars, revised 2020-9-28}
function find_offset_and_rotation(minimum_quads: integer;tolerance:double) : boolean; {find difference between ref image and new image}
procedure reset_solution_vectors(factor: double); {reset the solution vectors}

function SMedian(list: array of double; leng: integer): double;{get median of an array of double. Taken from CCDciel code but slightly modified}

function solve_image(img :image_array ) : boolean;{find match between image and star database}
procedure bin_and_find_stars(img :image_array;binning:integer;cropping,hfd_min:double;get_hist{update hist}:boolean; out starlist3:star_list; out short_warning : string);{bin, measure background, find stars}
function report_binning(height:double) : integer;{select the binning}
var
  star1   : array[0..2] of array of single;


implementation

uses
  unit_command_line_general,
  unit_command_line_star_database,unit_command_line_stars_wide_field;

var
  mag2  : double; {magnitude of star found}


procedure ang_sep(ra1,dec1,ra2,dec2 : double;out sep: double);{calculates angular separation. according formula 9.1 old Meeus or 16.1 new Meeus, version 2018-5-23}
var sin_dec1,cos_dec1,sin_dec2,cos_dec2,cos_sep:double;
begin
  sincos(dec1,sin_dec1,cos_dec1);{use sincos function for speed}
  sincos(dec2,sin_dec2,cos_dec2);

  cos_sep:=min(1,sin_dec1*sin_dec2+ cos_dec1*cos_dec2*cos(ra1-ra2));{min function to prevent run time errors for 1.000000000002}
  sep:=arccos(cos_sep);
end;


procedure QuickSort(var A: array of double; iLo, iHi: Integer) ;{ Fast quick sort. Sorts elements in the array list with indices between lo and hi}
var
  Lo, Hi : integer;
  Pivot, T: double;{ pivot, T, T2 are the same type as the elements of array }
begin
  Lo := iLo;
  Hi := iHi;
  Pivot := A[(Lo + Hi) div 2];
  repeat
    while A[Lo] < Pivot do Inc(Lo) ;
    while A[Hi] > Pivot do Dec(Hi) ;
    if Lo <= Hi then
    begin {swap}
      T := A[Lo];
      A[Lo] := A[Hi];
      A[Hi] := T;
      Inc(Lo) ;
      Dec(Hi) ;
    end;
  until Lo > Hi;
  if Hi > iLo then QuickSort(A, iLo, Hi) ;  {executes itself recursively}
  if Lo < iHi then QuickSort(A, Lo, iHi) ;  {executes itself recursively}
end;


function SMedian(list: array of double; leng: integer): double;{get median of an array of double. Taken from CCDciel code but slightly modified}
var
  mid : integer;
begin
 if leng=0 then result:=nan
 else
   if leng=1 then result:=list[0]
   else
   begin
     quickSort(list,0,leng-1);
     mid := (leng-1) div 2; //(high(list) - low(list)) div 2;
     if Odd(leng) then
     begin
       if leng<=3 then  result:=list[mid]
       else
       begin
         result:=(list[mid-1]+list[mid]+list[mid+1])/3;
       end;
     end
     else
     result:=(list[mid]+list[mid+1])/2;
  end;
end;


{   lsq_fit:                                                                                                                                     }
{   Find the solution vector of an overdetermined system of linear equations according to the method of least squares using GIVENS rotations     }
{                                                                                                                                                }
{   Solve x of A x = b with the least-squares method                                                                                             }
{   In matrix calculations, b_matrix[0..nr_columns-1,0..nr_equations-1]:=solution_vector[0..2] * A_XYpositions[0..nr_columns-1,0..nr_equations-1]}
{                                                                                                                              }
{   see also Montenbruck & Pfleger, Astronomy on the personal computer}
procedure lsq_fit( A_matrix: star_list; {[, 0..3,0..nr_equations-1]} b_matrix  : array of double;{equations result, b=A*s}  out x_matrix: solution_vector );
  const tiny = 1E-10;  {accuracy}
  var i,j,k, nr_equations,nr_columns  : integer;
      p,q,h                           : double;
      temp_matrix                     : star_list;

begin
  nr_equations:=length(A_matrix[0]);
  nr_columns:=length(A_matrix);{should be 3 for this application}

  temp_matrix:=A_matrix; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
  setlength(temp_matrix,nr_columns,nr_equations);{duplicate A_matrix to protect data in A_matrix}

  for j:=0 to nr_columns-1 do {loop over columns of temp_matrix}
  {eliminate matrix elements A[i,j] with i>j from column j}
    for i:=j+1 to nr_equations-1 do
      if temp_matrix[j,i]<>0 then
      begin{calculate p, q and new temp_matrix[j,j]; set temp_matrix[j,i]=0}
        if abs(temp_matrix[j,j])<tiny*abs(temp_matrix[j,i]) then
        begin
          p:=0;
          q:=1;
          temp_matrix[j,j]:=-temp_matrix[j,i];
          temp_matrix[j,i]:=0;

        end
        else
        begin
          h:=sqrt(temp_matrix[j,j]*temp_matrix[j,j]+temp_matrix[j,i]*temp_matrix[j,i]);
          if temp_matrix[j,j]<0 then h:=-h;
          p:=temp_matrix[j,j]/h;
          q:=-temp_matrix[j,i]/h;
          temp_matrix[j,j]:=h;
          temp_matrix[j,i]:=0;

        end;
        {calculate the rest of the line}
        for k:=j+1 to nr_columns-1 do
        begin
          h:= p*temp_matrix[k,j] - q*temp_matrix[k,i];
          temp_matrix[k,i] := q*temp_matrix[k,j] + p*temp_matrix[k,i];
          temp_matrix[k,j] := h;
        end;
        h:= p*b_matrix[j] - q*b_matrix[i];
        b_matrix[i] := q*b_matrix[j] + p*b_matrix[i];
        b_matrix[j] := h;
      end;

  for i:=0 to nr_columns-1 do x_matrix[i]:=0; //2022, extra precaution to zero x_matrix

  for i:= nr_columns-1 downto 0 do {back substitution}
  begin
    H:=b_matrix[i];
    for k:=i+1 to nr_columns-1 do
            h:=h-temp_matrix[k,i]*x_matrix[k];
    if temp_matrix[i,i]<>0 then x_matrix[i] := h/temp_matrix[i,i]
    else
    x_matrix[i]:=9999999999999999; //v2022. Prevent runtime error dividing by zero. Should normally not happen. In case of zero due to wrong double star detection by using triples force a failure

    {solution vector x:=x_matrix[0]x+x_matrix[1]y+x_matrix[2]}
  end;
end; {lsq_fit}


procedure QuickSort_starlist(var A: star_list; iLo, iHi: Integer) ;{ Fast quick sort. Sorts elements in the array list with indices between lo and hi, sort in X only}
var
  Lo, Hi : integer;
  Pivot, Tx,Ty: double;{ pivot, T are the same type as the elements of array }
begin
  Lo := iLo;
  Hi := iHi;
  Pivot := A[0,(Lo + Hi) div 2];
  repeat
    while A[0,Lo] < Pivot do Inc(Lo) ; {sort in X only}
    while A[0,Hi] > Pivot do Dec(Hi) ;
    if Lo <= Hi then
    begin {swap}
      Tx := A[0,Lo];
      Ty := A[1,Lo];
      A[0,Lo] := A[0,Hi];
      A[1,Lo] := A[1,Hi];
      A[0,Hi] := Tx;
      A[1,Hi] := Ty;
      Inc(Lo) ;
      Dec(Hi) ;
    end;
  until Lo > Hi;
  if Hi > iLo then QuickSort_starlist(A, iLo, Hi) ;  {executes itself recursively}
  if Lo < iHi then QuickSort_starlist(A, Lo, iHi) ;  {executes itself recursively}
end;


procedure find_quads(starlist :star_list; min_leng:double; out quad_smallest:double; out quad_star_distances :star_list);  {build quads using closest stars, revised 2022-4-10}
var
   i,j,k,nrstars,j_used1,j_used2,j_used3,nrquads,Sstart,Send,tolerance  : integer;
   distance,distance1,distance2,distance3,x1,x2,x3,x4,xt,y1,y2,y3,y4,yt,
   dist1,dist2,dist3,dist4,dist5,dist6,dummy,disty                          : double;
   identical_quad : boolean;
begin

  nrstars:=Length(starlist[0]);{number of quads will be equal (super rare) or lower}
  quad_smallest:=9999999;


  if nrstars<4 then
  begin {not enough stars for quads}
    SetLength(quad_star_distances,8,0);
    exit;
  end;

  if nrstars>=150 then
  begin
    quickSort_starlist(starlist,0,nrstars-1); {sort in X only}
    tolerance:=round(0.5*sqrt(nrstars));{tolerance band is about twice the every star distance}
  end
  else
  tolerance:=1;{switch pre-filtering in X off}

  nrquads:=0;
  SetLength(quad_star_distances,8,nrstars);{will contain the six distances and the central position}

  j_used1:=0;{give it a default value}
  j_used2:=0;
  j_used3:=0;

  for i:=0 to nrstars-1 do
  begin
    distance1:=1E99;{distance closest star}
    distance2:=1E99;{distance second closest star}
    distance3:=1E99;{distance third closest star}


    Sstart:=max(0,i-(nrstars div tolerance));
    Send:=min(nrstars-1,i+(nrstars div tolerance)); {search in a limited X band only. The stars list is sorted in X. Search speed increases with about 30%}

    for j:=Sstart to Send do {find closest stars}
    begin
      if j<>i{not the first star} then
      begin
        disty:=sqr(starlist[1,j]-starlist[1,i]);
        if disty<distance3 then {pre-check to increase processing speed with a small amount}
        begin
          distance:=sqr(starlist[0,j]-starlist[0,i])+distY ;{square distances are used}
          if distance>1 then {not an identical star. Mod 2021-6-25}
          begin
            if distance<distance1 then
            begin
              distance3:=distance2;{distance third closest star}
              j_used3:=j_used2;{remember the star position in the list}

              distance2:=distance1;{distance second closest star}
              j_used2:=j_used1;{remember the star position in the list}

              distance1:=distance;{distance closest star}
              j_used1:=j;{mark later as used}
            end
            else
            if distance<distance2 then
            begin
              distance3:=distance2;{distance third closest star}
              j_used3:=j_used2;{remember the star position in the list}

              distance2:=distance;{distance second closest star}
              j_used2:=j;
            end
            else
            if distance<distance3 then
            begin
              distance3:=distance;{third closest star}
              j_used3:=j;{remember the star position in the list}
            end;
          end;{not an identical star. Mod 2021-6-25}

        end; {pre-check}
      end;
    end;{j}

    x1:=starlist[0,i]; {copy first star position to the quad array}
    y1:=starlist[1,i];

    x2:=starlist[0,j_used1]; {copy the second star position to the quad array}
    y2:=starlist[1,j_used1];

    x3:=starlist[0,j_used2];
    y3:=starlist[1,j_used2];

    x4:=starlist[0,j_used3];
    y4:=starlist[1,j_used3];

    xt:=(x1+x2+x3+x4)/4; {mean x position quad}
    yt:=(y1+y2+y3+y4)/4; {mean y position quad}

    identical_quad:=false;
    if nrquads>=1 then {already a quad stored}
    begin
     k:=0;
     repeat {check for identical quads}
       if ( (abs(xt-quad_star_distances[6,k])<1) and
            (abs(yt-quad_star_distances[7,k])<1) ) then {same center position, found identical quad already in the list}
           begin
             identical_quad:=true;
             k:=999999999;{stop}
           end;

       inc(k);
     until k>=nrquads;
    end;

    if identical_quad=false then  {new quad found}
    begin
      try {sort the six distances on length. Largest first and scale the others relative to largest distance}
        begin
          dist1:=sqrt(distance1);{distance star1-star2, use previous value already calculated}
          dist2:=sqrt(distance2);{distance star1-star3}
          dist3:=sqrt(distance3);{distance star1-star4}
          dist4:=sqrt(sqr(x2-x3)+ sqr(y2-y3));{distance star2-star3}
          dist5:=sqrt(sqr(x2-x4)+ sqr(y2-y4));{distance star2-star4}
          dist6:=sqrt(sqr(x3-x4)+ sqr(y3-y4));{distance star3-star4}
          {sort six distances on size in five steps}
          for j:=1 to 5 do {sort on distance}
          begin
            if dist6>dist5 then begin dummy:=dist5; dist5:=dist6; dist6:=dummy; end;
            if dist5>dist4 then begin dummy:=dist4; dist4:=dist5; dist5:=dummy; end;
            if dist4>dist3 then begin dummy:=dist3; dist3:=dist4; dist4:=dummy; end;
            if dist3>dist2 then begin dummy:=dist2; dist2:=dist3; dist3:=dummy; end;
            if dist2>dist1 then begin dummy:=dist1; dist1:=dist2; dist2:=dummy; end;
          end;
          quad_star_distances[0,nrquads]:=dist1;{largest distance}
          quad_star_distances[1,nrquads]:=dist2/dist1;{scale relative to largest distance}
          quad_star_distances[2,nrquads]:=dist3/dist1;
          quad_star_distances[3,nrquads]:=dist4/dist1;
          quad_star_distances[4,nrquads]:=dist5/dist1;
          quad_star_distances[5,nrquads]:=dist6/dist1;

          if dist1<quad_smallest then quad_smallest:=dist1;{measure the smallest}
        end;
     except
     end;
      if dist1>min_leng then {large enough for earth based telescope}
      begin
        quad_star_distances[6,nrquads]:=xt;{store mean x position}
        quad_star_distances[7,nrquads]:=yt;{store mean y position}
        inc(nrquads); {new unique quad found}
      end;
    end;
  end;{i}

  SetLength(quad_star_distances,8,nrquads);{adapt to the number found}
end;


function find_fit( minimum_count: integer; quad_tolerance: double) : boolean;
var
   nrquads1,nrquads2, i,j,k: integer;
   median_ratio : double;
   matchList1, matchlist2  : array of array of integer;
   ratios                  : array of double;
begin
  result:=false; {assume failure}
  nrquads1:=Length(quad_star_distances1[0]);
  nrquads2:=Length(quad_star_distances2[0]);

  {minimum_count required, 6 for stacking, 3 for plate solving}
  if ((nrquads1<minimum_count) or (nrquads2< minimum_count)) then begin nr_references:=0; exit; end;{no solution abort before run time errors}

  {Find a tolerance resulting in 6 or more of the best matching quads}
  setlength(matchlist2,2,1000);
  nr_references2:=0;
  i:=0;
  repeat
    j:=0;
    repeat
      if abs(quad_star_distances1[1,i] - quad_star_distances2[1,j])<=quad_tolerance then {all length are scaled to the longest length so scale independent}
      if abs(quad_star_distances1[2,i] - quad_star_distances2[2,j])<=quad_tolerance then
      if abs(quad_star_distances1[3,i] - quad_star_distances2[3,j])<=quad_tolerance then
      if abs(quad_star_distances1[4,i] - quad_star_distances2[4,j])<=quad_tolerance then
      if abs(quad_star_distances1[5,i] - quad_star_distances2[5,j])<=quad_tolerance then
      begin
        matchlist2[0,nr_references2]:=i;{store match position}
        matchlist2[1,nr_references2]:=j;
        inc(nr_references2);
        if nr_references2>=length(matchlist2[0]) then setlength(matchlist2,2,nr_references2+1000);{get more space}
      end;
      inc(j);
    until j>=nrquads2;{j loop}
    inc(i);
  until i>=nrquads1;{i loop}

 //memo2_message('Found '+inttostr( nr_references2)+ ' references');

  if nr_references2< minimum_count then begin nr_references:=0; exit; end;{no solution abort before run time errors}


  setlength(ratios,nr_references2);
  {calculate median of the longest lenght ratio for matching quads}
  for k:=0 to nr_references2-1 do
    ratios[k]:=quad_star_distances1[0,matchlist2[0,k]]/quad_star_distances2[0,matchlist2[1,k]]; {ratio between largest length of found and reference quad}
  median_ratio:=smedian(ratios,nr_references2);

  {calculate median absolute deviation of the longest length ratio for matching quads}
//  for k:=0 to nr_references2-1 do {find standard deviation orientation quads}
//    deviations[k]:=abs(median_ratio1-ratios[k]);
//  mad:=smedian(deviations);{mad is about 0.67499 *sigma for a normal distribution}
//  memo2_message('mad :'+floattostr6(mad));

  nr_references:=0;
  setlength(matchlist1,2,1000);
  for k:=0 to nr_references2-1 do {throw outliers out}
  begin
    if  abs(median_ratio-ratios[k])<=quad_tolerance*median_ratio then
    begin
      matchlist1[0,nr_references]:=matchlist2[0,k];{copy match position which are <3*SD}
      matchlist1[1,nr_references]:=matchlist2[1,k];
      inc(nr_references);
      if nr_references>=length(matchlist1[0]) then setlength(matchlist1,2,nr_references+1000);{get more space if running out of space}
    end
    else
    if solve_show_log then memo2_message('quad outlier removed due to abnormal size: '+floattostr6(100*ratios[k]/median_ratio)+'%');
  end;
  ratios:=nil; {free mem}
  {outliers in largest length removed}

  if (nr_references>=3) then {use 3 quads center position}
  begin
    {fill equations}
    setlength(A_XYpositions,3,nr_references);
    setlength(b_Xrefpositions,nr_references);
    setlength(b_Yrefpositions,nr_references);

    for k:=0 to nr_references-1 do
    begin
      A_XYpositions[0,k]:=quad_star_distances2[6,matchlist1[1,k]]; {average x position of quad}
      A_XYpositions[1,k]:=quad_star_distances2[7,matchlist1[1,k]]; {average y position of quad}
      A_XYpositions[2,k]:=1;

      b_Xrefpositions[k]:=quad_star_distances1[6,matchlist1[0,k]]; {x position of ref quad}
      b_Yrefpositions[k]:=quad_star_distances1[7,matchlist1[0,k]]; {Y position of ref quad}

      {in matrix calculations, b_refpositionX[0..2,0..nr_equations-1]:=solution_vectorX[0..2] * A_XYpositions[0..2,0..nr_equations-1]}
      {                        b_refpositionY[0..2,0..nr_equations-1]:=solution_matrixY[0..2] * A_XYpositions[0..2,0..nr_equations-1]}
    end;
    result:=true;{3 or more references}
  end;
  // else It is possible to use one quad and the four star positions but it is not reliable.
  matchlist2:=nil;
  matchlist1:=nil;
end;


procedure get_brightest_stars(nr_stars_required: integer;{500} highest_snr: double;snr_list : array of double; var starlist1 : star_list);{ get the brightest star from a star list}
const
   range=200;
var
  snr_histogram : array [0..range] of integer;
  i,count,nrstars, snr_scaled: integer;
  snr_required : double;

begin
  for i:=0 to length(snr_histogram)-1 do snr_histogram[i]:=0; {clear snr histogram}
  for i:=0 to length(snr_list)-1 do
  begin
  //  memo2_message(#9+inttostr(i)+#9+floattostr6(snr_list[i])) ;
    snr_scaled:=trunc(snr_list[i]*range/highest_snr);
    snr_histogram[snr_scaled]:=snr_histogram[snr_scaled]+1;{count how often this snr value is measured}
  end;
  count:=0;
  i:=range+1;
  repeat
    dec(i);
    count:=count+snr_histogram[i];
  //  memo2_message(#9+inttostr(snr_histogram[i])+ #9 +inttostr(i));
  until ((i<=0) or (count>=nr_stars_required));

  snr_required:=highest_snr*i/range;

  count:=0;
  nrstars:=length(starlist1[0]);
  for i:=0 to nrstars-1 do
    if snr_list[i]>=snr_required then {preserve brightest stars}
    begin
      starlist1[0,count]:=starlist1[0,i];{overwrite in the same array}
      starlist1[1,count]:=starlist1[1,i];
   //   memo2_message(#9+floattostr(snr_list[i])+#9+floattostr(starlist2[0,count])+ #9 +floattostr(starlist2[1,count]));
      inc(count);
     //  For testing:
     //  mainwindow.image1.Canvas.Pen.Mode := pmMerge;
     //  mainwindow.image1.Canvas.Pen.width := round(1+height2/mainwindow.image1.height);{thickness lines}
     //  mainwindow.image1.Canvas.brush.Style:=bsClear;
     //  mainwindow.image1.Canvas.Pen.Color := clred;
     //  mainwindow.image1.Canvas.Rectangle(round(starlist1[0,i])-15,height2-round(starlist1[1,i])-15, round(starlist1[0,i])+15, height2-round(starlist1[1,i])+15);{indicate hfd with rectangle}
     end;
  setlength(starlist1,2,count);{reduce length to used length}
end;


procedure find_stars(img :image_array;hfd_min:double;out starlist1: star_list);{find stars and put them in a list}
var
   fitsX, fitsY,nrstars,radius,i,j,retries,m,n,xci,yci,sqr_radius : integer;
   hfd1,star_fwhm,snr,xc,yc,highest_snr,flux, detection_level               : double;
   img_sa     : image_array;
   snr_list        : array of double;
   startTick2  : qword;{for timing/speed purposes}
const
    buffersize=5000;{5000}
begin
  if solve_show_log then begin memo2_message('Start finding stars');   startTick2 := gettickcount64;end;
  SetLength(starlist1,2,buffersize);{set array length}
  setlength(snr_list,buffersize);{set array length}

  setlength(img_sa,1,height2,width2);{set length of image array}

  retries:=3; {try up to four times to get enough stars from the image}
  repeat
    if retries=3 then
      begin if star_level >30*noise_level[0] then detection_level:=star_level  else retries:=2;{skip} end;//stars are dominant
    if retries=2 then
      begin if star_level2>30*noise_level[0] then detection_level:=star_level2 else retries:=1;{skip} end;//stars are dominant
    if retries=1 then
      begin detection_level:=30*noise_level[0]; end;
    if retries=0 then
      begin detection_level:= 7*noise_level[0]; end;

    highest_snr:=0;
    nrstars:=0;{set counters at zero}

    for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1  do
        img_sa[0,fitsY,fitsX]:=-1;{mark as star free area}

    for fitsY:=0 to height2-1-1 do
    begin
      for fitsX:=0 to width2-1-1  do
      begin
        if (( img_sa[0,fitsY,fitsX]<=0){star free area} and (img[0,fitsY,fitsX]-cblack>detection_level){star}) then {new star, at least 3.5 * sigma above noise level}
        begin
          HFD(img,fitsX,fitsY,14{annulus radius}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if ((hfd1<=10) and (snr>10) and (hfd1>hfd_min) {0.8 is two pixels minimum} ) then
          begin
            radius:=round(3.0*hfd1);{for marking star area. A value between 2.5*hfd and 3.5*hfd gives same performance. Note in practice a star PSF has larger wings then predicted by a Gaussian function}
            sqr_radius:=sqr(radius);
            xci:=round(xc);{star center as integer}
            yci:=round(yc);
            for n:=-radius to +radius do {mark the whole circular star area as occupied to prevent double detection's}
              for m:=-radius to +radius do
              begin
                j:=n+yci;
                i:=m+xci;
                if ((j>=0) and (i>=0) and (j<height2) and (i<width2) and (sqr(m)+sqr(n)<=sqr_radius)) then
                  img_sa[0,j,i]:=1;
              end;

            {store values}
            inc(nrstars);
            if nrstars>=length(starlist1[0]) then
            begin
              SetLength(starlist1,2,nrstars+buffersize);{adapt array size if required}
              setlength(snr_list,nrstars+buffersize);{adapt array size if required}
            end;
            starlist1[0,nrstars-1]:=xc; {store star position}
            starlist1[1,nrstars-1]:=yc;
            snr_list[nrstars-1]:=snr;{store SNR}

            if  snr>highest_snr then highest_snr:=snr;{find to highest snr value}
          end;
        end;
      end;
    end;

    if solve_show_log then memo2_message(inttostr(nrstars)+' stars found of the requested '+inttostr(max_stars)+'. Background value is '+inttostr(round(cblack))+ '. Detection level used '+inttostr( round(detection_level))
                                                          +' above background. Star level is '+inttostr(round(star_level))+' above background. Noise level is '+floattostrF(noise_level[0],ffFixed,0,0));

    dec(retries);{Try again with lower detection level}
  until ((nrstars>=max_stars) or (retries<0));{reduce dection level till enough stars are found. Note that faint stars have less positional accuracy}

  img_sa:=nil;{free mem}

  SetLength(starlist1,2,nrstars);{set length correct}
  setlength(snr_list,nrstars);{set length correct}

  if nrstars>max_stars then {reduce number of stars if too high}
  begin
    if solve_show_log then memo2_message('Selecting the '+ inttostr(max_stars)+' brightest stars only.');
    get_brightest_stars(max_stars, highest_snr, snr_list, starlist1);
  end;
  if solve_show_log then memo2_message('Finding stars done in '+ inttostr(gettickcount64 - startTick2)+ ' ms');
end;

procedure reset_solution_vectors(factor: double); {reset the solution vectors}
begin
  solution_vectorX[0]:=factor;{should be one} // x:=s[1]x+s[2]y+s[3] }
  solution_vectorX[1]:=0;
  solution_vectorX[2]:=0;

  solution_vectorY[0]:=0; // y:=s[1]x+s[2]y+s[3]
  solution_vectorY[1]:=factor;{should be one}
  solution_vectorY[2]:=0;
end;


function find_offset_and_rotation(minimum_quads: integer;tolerance:double) : boolean; {find difference between ref image and new image}
var
  xy_sqr_ratio   : double;
begin
  if find_fit(minimum_quads, tolerance)=false then
  begin
    result:=false;
    reset_solution_vectors(0.001);{nullify}
    exit;
  end;
  result:=true;{2 quads are required giving 8 star references or 3 quads giving 3 center quad references}

  {in matrix calculations, b_refpositionX[0..2,0..nr_equations-1]:=solution_vectorX[0..2] * A_XYpositions[0..2,0..nr_equations-1]}
  {                        b_refpositionY[0..2,0..nr_equations-1]:=solution_matrixY[0..2] * A_XYpositions[0..2,0..nr_equations-1]}

  {find solution vector for X:=ax+by+c  / b_Xref:=solution[0]x+solution[1]y+solution[2]}
   lsq_fit( A_XYpositions {[0..2,0..nr_equations-1]},b_Xrefpositions, solution_vectorX {[0..2]} );

  {find solution vector for Y:=ax+by+c  / b_Yref:=solution[0]x+solution[1]y+solution[2]}
  lsq_fit( A_XYpositions {0..2,[0..nr_equations-1]},b_Yrefpositions, solution_vectorY {[0..2]});

   xy_sqr_ratio:=(sqr(solution_vectorX[0])+sqr(solution_vectorX[1]) ) / (0.00000001+ sqr(solution_vectorY[0])+sqr(solution_vectorY[1]) );

  if ((xy_sqr_ratio<0.9) or (xy_sqr_ratio>1.1)) then {dimensions x, y are not the same, something wrong.}
  begin
    result:=false;
    reset_solution_vectors(0.001);{nullify}
    if solve_show_log then {global variable set in find stars} memo2_message('Solution skipped on XY ratio: '+ floattostr(xy_sqr_ratio));
  end;
end;


function floattostrF2(const x:double; width1,decimals1 :word): string;
begin
  str(x:width1:decimals1,result);
  if formatSettings.decimalseparator<>'.' then result:=StringReplace(result,'.',formatSettings.decimalseparator,[]); {replaces dot by komma}
end;


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
  result:= floattostrF2(inp*180/pi,0,1)+'d';
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
{ra0,dec0: right ascension and declination of the optical axis}
{ra,dec:   right ascension and declination}
{xx,yy :   CCD coordinates}
{cdelt:    CCD scale in arcsec per pixel}
{$INLINE ON}
procedure equatorial_standard(ra0,dec0,ra,dec, cdelt : double; out xx,yy: double); inline;
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
procedure standard_equatorial(ra0,dec0,x,y,cdelt: double; out ra,dec : double); {transformation from CCD coordinates into equatorial coordinates}
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


function read_stars(telescope_ra,telescope_dec,search_field : double; nrstars_required: integer; out starlist: star_list; out nrstars:integer): boolean;{read star from star database}
var
   Bp_Rp, ra2,dec2,
   frac1,frac2,frac3,frac4,sep                      : double;
   area1,area2,area3,area4,nrstars_required2,count  : integer;
//   correctionX,correctionY : double;
begin
  result:=false;{assume failure}
  nrstars:=0;{set counters at zero}
  ra2:=0; {define ra2 value. Prevent ra2 = -nan(0xffffffffffde9) run time failure when first header record is read}

  SetLength(starlist,2,nrstars_required);{set array length}

  if database_type<>001 then {1476 or 290 files}
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
  begin {wide field database}
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
//  equatorial_standard(telescope_ra,telescope_dec,ra0,dec0,1,correctionX,correctionY);{calculate correction for x,y position of database center and image center}
//  plot_stars_used_for_solving(correctionX,correctionY); {plot image stars and database stars used for the solution}
end;


procedure check_pattern_filter(var img: image_array); {normalize bayer pattern. Colour shifts due to not using a white light source for the flat frames are avoided.}
var
  fitsX,fitsY,col,h,w,counter1,counter2, counter3,counter4 : integer;
  value1,value2,value3,value4,maxval : double;
  oddx, oddy :boolean;
begin
  col:=length(img);{the real number of colours}
  h:=length(img[0]);{height}
  w:=length(img[0,0]);{width}

  if col>1 then
  begin
    memo2_message('Skipping check pattern filter. This filter works only for raw OSC images!');
    exit;
  end
  else
    memo2_message('Applying check pattern filter.');

  value1:=0; value2:=0; value3:=0; value4:=0;
  counter1:=0; counter2:=0; counter3:=0; counter4:=0;

  for fitsY:=(h div 4) to (h*3) div 4 do {use one quarter of the image to find factors. Works also a little better if no dark-flat is subtracted. It also works better if boarder is black}
    for fitsX:=(w div 4) to (w*3) div 4 do
    begin
      oddX:=odd(fitsX);
      oddY:=odd(fitsY);
      if ((oddX=false) and (oddY=false)) then begin value1:=value1+img[0,fitsY,fitsX]; inc(counter1) end else {separate counters for case odd() dimensions are used}
      if ((oddX=true)  and (oddY=false)) then begin value2:=value2+img[0,fitsY,fitsX]; inc(counter2) end else
      if ((oddX=false) and (oddY=true))  then begin value3:=value3+img[0,fitsY,fitsX]; inc(counter3) end else
      if ((oddX=true)  and (oddY=true))  then begin value4:=value4+img[0,fitsY,fitsX]; inc(counter4) end;
    end;

  {now normalise the bayer pattern pixels}
  value1:=value1/counter1;
  value2:=value2/counter2;
  value3:=value3/counter3;
  value4:=value4/counter4;
  maxval:=max(max(value1,value2),max(value3,value4));
  value1:=maxval/value1;
  value2:=maxval/value2;
  value3:=maxval/value3;
  value4:=maxval/value4;

  for fitsY:=0 to h-1 do
    for fitsX:=0 to w-1 do
    begin
      oddX:=odd(fitsX);
      oddY:=odd(fitsY);
      if ((value1<>1) and (oddX=false) and (oddY=false)) then img[0,fitsY,fitsX]:=round(img[0,fitsY,fitsX]*value1) else
      if ((value2<>1) and (oddX=true)  and (oddY=false)) then img[0,fitsY,fitsX]:=round(img[0,fitsY,fitsX]*value2) else
      if ((value3<>1) and (oddX=false) and (oddY=true))  then img[0,fitsY,fitsX]:=round(img[0,fitsY,fitsX]*value3) else
      if ((value4<>1) and (oddX=true)  and (oddY=true))  then img[0,fitsY,fitsX]:=round(img[0,fitsY,fitsX]*value4);
    end;
end;


procedure binX1_crop(crop {0..1}:double; img : image_array; var img2: image_array);{crop image, make mono, no binning}
  var fitsX,fitsY,k, w,h,  shiftX,shiftY: integer;
      val       : single;
begin
  w:=trunc(crop*width2);  {cropped}
  h:=trunc(crop*height2);

  setlength(img2,1,h,w); {set length of image array}

  shiftX:=round(width2*(1-crop)/2); {crop is 0.9, shift is 0.05*width2}
  shiftY:=round(height2*(1-crop)/2); {crop is 0.9, start at 0.05*height2}

  for fitsY:=0 to h-1 do
    for fitsX:=0 to w-1  do
    begin
      val:=0;
      for k:=0 to naxis3-1 do {all colors and make mono}
         val:=val + img[k,shiftY+fitsY   ,shiftX+fitsX];
      img2[0,fitsY,fitsX]:=val/naxis3;
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
   width5:=Length(img[0,0]);    {width}
   height5:=Length(img[0]); {height}

   w:=trunc(crop*width5/2);  {half size & cropped. Use trunc for image 1391 pixels wide like M27 test image. Otherwise exception error}
   h:=trunc(crop*height5/2);

   setlength(img2,1,h,w);{set length of image array}

   shiftX:=round(width5*(1-crop)/2); {crop is 0.9, shift is 0.05*width2}
   shiftY:=round(height5*(1-crop)/2); {crop is 0.9, start at 0.05*height2}

   for fitsY:=0 to h-1 do
      for fitsX:=0 to w-1  do
     begin
       val:=0;
       for k:=0 to nrcolors-1 do {all colors}
         val:=val+(img[k,shiftY+fitsY*2   ,shiftX+fitsX*2]+
                   img[k,shiftY+fitsy*2 +1,shiftX+fitsX*2]+
                   img[k,shiftY+fitsy*2   ,shiftX+fitsX*2+1]+
                   img[k,shiftY+fitsy*2 +1,shiftX+fitsX*2+1])/4;
       img2[0,fitsY,fitsX]:=val/nrcolors;
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
  width5:=Length(img[0,0]);    {width}
  height5:=Length(img[0]); {height}

  w:=trunc(crop*width5/3);  {1/3 size and cropped}
  h:=trunc(crop*height5/3);

  setlength(img2,1,h,w); {set length of image array}

  shiftX:=round(width5*(1-crop)/2); {crop is 0.9, shift is 0.05*width2}
  shiftY:=round(height5*(1-crop)/2); {crop is 0.9, start at 0.05*height2}

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
  width2:=w;
  height2:=h;
  naxis3:=1;
end;


procedure binX4_crop(crop {0..1}:double;img : image_array; var img2: image_array);{combine values of 16 pixels and crop is required. Result is mono}
  var fitsX,fitsY,k, w,h,  shiftX,shiftY,nrcolors,width5,height5: integer;
      val       : single;
begin
  nrcolors:=Length(img);
  width5:=Length(img[0,0]);    {width}
  height5:=Length(img[0]); {height}

  w:=trunc(crop*width5/4);  {1/4 size and cropped}
  h:=trunc(crop*height5/4);

  setlength(img2,1,h,w); {set length of image array}

  shiftX:=round(width5*(1-crop)/2); {crop is 0.9, shift is 0.05*width2}
  shiftY:=round(height5*(1-crop)/2); {crop is 0.9, start at 0.05*height2}

  for fitsY:=0 to h-1 do {bin & mono image}
    for fitsX:=0 to w-1  do
    begin
      val:=0;
      for k:=0 to nrcolors-1 do {all colors}
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
         img2[0,fitsY,fitsX]:=val/nrcolors;
    end;
  width2:=w;
  height2:=h;
  naxis3:=1;
end;


procedure bin_and_find_stars(img :image_array;binning:integer;cropping,hfd_min:double;get_hist{update hist}:boolean; out starlist3:star_list; out short_warning : string);{bin, measure background, find stars}
var
  old_width,old_height,old_naxis3,nrstars,i : integer;
  img_binned : image_array;

begin
  short_warning:='';{clear string}

  if ((binning>1) or (cropping<1)) then
  begin
    old_width:=width2;
    old_height:=height2;
    old_naxis3:=naxis3;
    if binning>1 then memo2_message('Creating grayscale x '+inttostr(binning)+' binning image for solving/star alignment.');
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

    get_background(0,img_binned,true {load hist},true {calculate also standard deviation background},{var}cblack,star_level,star_level2 );{get back ground}
    find_stars(img_binned,hfd_min,starlist3); {find stars of the image and put them in a list}
    img_binned:=nil;
    nrstars:=Length(starlist3[0]);

    if height2<960 then
    begin
      short_warning:='Warning, remaining image dimensions too low! ';  {for FITS header and solution. Dimensions should be equal or better the about 1280x960}
      memo2_message('Warning, remaining image dimensions too low! Try to REDUCE OR REMOVE DOWNSAMPLING.');
    end;

    width2:=old_width; {restore to original size}
    height2:=old_height;
    naxis3:=old_naxis3;

    for i:=0 to nrstars-1 do {correct star positions for cropping. Simplest method}
    begin
      starlist3[0,i]:=(binning-1)*0.5+starlist3[0,i]*binning +(width2*(1-cropping)/2);//correct star positions for binning/ cropping. Position [3.5,3,5] becomes after 2x2 binning [1,1] after x2 [3,3]. So correct for 0.5 pixel
      starlist3[1,i]:=(binning-1)*0.5+starlist3[1,i]*binning +(height2*(1-cropping)/2);
      // For zero based indexing:
      // A star of 2x2 pixels at position [2.5,2.5] is after 2x2 binning at position [1,1]. If doubled to [2,2] then the position has 0.5 pixel shifted.
      // A star of 3x3 pixels at position [4,4] is after 3x3 binning at position [1,1]. If tripled to [3,3] then the position has 1.0 pixel shifted.
      // A star of 4x4 pixels at position [5.5,5.5] is after 4x4 binning at position [1,1]. If quadruped to [4,4] then the position has 1.5 pixel shifted.
      // So positions measured in a binned image should be corrected as x:=(binning-1)*0.5+binning*x and y:=(binning-1)*0.5+binning*y


    end;
  end
  else
  begin
    if height2>2500 then
    begin
      short_warning:='Warning, increase downsampling!! '; {for FITS header and solution}
      memo2_message('Info: DOWNSAMPLING IS RECOMMENDED FOR LARGE IMAGES. Set this option in stack menu, tab alignment.');
    end
    else
    if height2<960 then
    begin
     short_warning:='Warning, small image dimensions!! ';  {for FITS header and solution. Dimensions should be equal or better the about 1280x960}
     memo2_message('█ █ █ █ █ █ Warning, small image dimensions!!');
    end;

    get_background(0,img,get_hist {load hist},true {calculate also standard deviation background}, {var} cblack,star_level,star_level2);{get back ground}
    find_stars(img,hfd_min,starlist3); {find stars of the image and put them in a list}
  end;
end;


function report_binning(height:double) : integer;{select the binning}
begin
  result:=downsample_for_solving1;
  if result<=0 then  {zero gives -1, Auto is 0}
  begin
    if height>2500 then result:=2
    else
     result:=1;
  end;
end;


function solve_image(img :image_array) : boolean;{find match between image and star database}
var
  nrstars,nrstars_required,count,max_distance,nr_quads, minimum_quads,database_stars,binning,match_nr,
  spiral_x, spiral_y, spiral_dx, spiral_dy,spiral_t,database_density,limit,err                                       : integer;
  search_field,step_size,ra_database,dec_database,telescope_ra_offset,radius,fov2,fov_org, max_fov,fov_min,
  oversize,sep_search,seperation,ra7,dec7,centerX,centerY,cropping, min_star_size_arcsec,hfd_min,delta_ra,current_dist,
  quad_tolerance,dummy, extrastars,flip,extra,distance,flipped_image                                                 : double;
  solution, go_ahead ,autoFOV                                                                                        : boolean;
  startTick  : qword;{for timing/speed purposes}
  distancestr,oversize_mess,mess,suggest_str, warning_downsample, solved_in, offset_found,ra_offset,dec_offset,mount_info,mount_offset : string;
  starlist1,starlist2 : star_list;

begin
  result:=false;
  esc_pressed:=false;
  warning_str:='';{for header}
  startTick := GetTickCount64;
  quad_tolerance:=strtofloat2(quad_tolerance1);

  if ((fov_specified=false) and (cdelt2<>0)) then {no FOV in native command line and cdelt2 in header}
    fov_org:=min(180,height2*abs(cdelt2)) {calculate FOV. PI can give negative CDELT2}
  else
   fov_org:=min(180,strtofloat2(search_fov1));{use specfied FOV in stackmenu. 180 max to prevent runtime errors later}

  if select_star_database(star_database1,fov_org)=false then {select database prior to cropping selection}
  begin
    result:=false;
    memo2_message('Error, no star database found at '+database_path+' ! Download and install a star database.');
    errorlevel:=32;{no star database}
    exit;
  end
  else
  begin
    //stackmenu1.star_database1.text:=name_database;
    memo2_message('Using star database '+uppercase(name_database));

    if ((fov_org>30) and (database_type<>001)) then
      warning_str:=warning_str+'Wide field image, use W08 database! '
    else
    if ((fov_org>6) and (database_type=1476)) then
      warning_str:=warning_str+'Large FOV, use G05 database! ';

    if warning_str<>'' then memo2_message(warning_str);
  end;

  if check_pattern_filter1 then {for OSC images with low dimensions only}
    check_pattern_filter(img);


  if  database_type=1476  then {.1476 database}
    max_fov:=5.142857143 {warning FOV should be less the database tiles dimensions, so <=5.142857143 degrees. Otherwise a tile beyond next tile could be selected}
  else  {.1476 database}
  if  database_type=290  then {.290 database}
    max_fov:=9.53 {warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected}
  else
    max_fov:=180;

  dec_radians:=dec0; {store temporary}
  ra_radians:=ra0;
  min_star_size_arcsec:=strtofloat2(min_star_size1); {arc sec};
  autoFOV:=(fov_org=0);{specified auto FOV}

  if max_stars=0 then max_stars:=500;// temporary. Remove in 2024;

  val(copy(name_database,2,2),database_density,err);
  if ((err<>0) or
      (database_density=17) or (database_density=18)) then //old databases V17, G17, G18, H17, H18
    database_density:=9999
  else
    database_density:=database_density*100;

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
    end;

    limit:=round(database_density*sqr(fov2)*width2/height2);//limit in stars per square degree. limit=density*surface_full_image
    if limit<max_stars then
    begin
       max_stars:=limit;//reduce the number of stars to use.
       memo2_message('Database limit for this FOV is '+inttostr(max_stars)+' stars.');
    end;

    binning:=report_binning(height2*max_fov/max(fov_org{could be zero},max_fov)); {select binning on dimensions of cropped image only}
    hfd_min:=max(0.8,min_star_size_arcsec/(binning*fov_org*3600/height2) );{to ignore hot pixels which are too small}
    bin_and_find_stars(img,binning,cropping,hfd_min,true{update hist}, starlist2, warning_downsample);{bin, measure background, find stars. Do this every repeat since hfd_min is adapted}
    nrstars:=Length(starlist2[0]);

     {prepare popupnotifier1 text}
    if force_oversize1=false then mess:=' normal' else mess:=' slow';
    memo2_message('ASTAP solver version CLI-'+astap_version+#10+
                  'Search radius: '+ radius_search1+' degrees, '+#10+
                  'Start position: '+prepare_ra(ra0,': ')+', '+prepare_dec(dec0,'d ')+#10+
                  'Image height: '+floattostrf2(fov_org,0,2)+' degrees'+#10+
                  'Binning: '+inttostr(binning)+'x'+inttostr(binning)+#10+
                  'Image dimensions: '+inttostr(width2)+'x'+inttostr(height2)+#10+
                  'Quad tolerance: '+quad_tolerance1+#10+
                  'Minimum star size: '+min_star_size1+'"' +#10+
                  'Speed:'+mess);

    nrstars_required:=round(nrstars*(height2/width2));{square search field based on height.}

    solution:=false; {assume no match is found}
    go_ahead:=(nrstars>=6); {bare minimum for three quads}

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

      if force_oversize1 then
      begin
        oversize:=2;
        oversize_mess:='Search window at 200%'
      end
      else
      oversize_mess:='Search window at '+ inttostr(round((oversize)*100)) +'% based on the number of quads. Step size at 100% of image height';

      radius:=strtofloat2(radius_search1);{radius search field}
      memo2_message(inttostr(nrstars)+' stars, '+inttostr(nr_quads)+' quads selected in the image. '+inttostr(nrstars_required)+' database stars, '+inttostr(round(nr_quads*nrstars_required/nrstars))+' database quads required for the square search field of '+floattostrF2(fov2,0,1)+'d. '+oversize_mess );

      minimum_quads:=3 + nr_quads div 100; {prevent false detections for star rich images, 3 quads give the 3 center quad references and is the bare minimum. It possible to use one quad and four star positions but it in not reliable}
    end
    else
    begin
      memo2_message('Only '+inttostr(nrstars)+' stars found in image. Abort');
      errorlevel:=2;
    end;

    if go_ahead then
    begin
      search_field:=fov2*(pi/180);
      STEP_SIZE:=search_field;{fixed step size search spiral. Prior to version 0.9.211 this was reduced for small star counts}
      if database_type=1 then
      begin {make smal steps for wide field images. Much more reliable}
        step_size:=step_size*0.1;
        max_distance:=round(radius/(0.1*fov2+0.00001)); {expressed in steps}
        memo2_message('Wide field, making small steps for reliable solving.');
      end
      else
      max_distance:=round(radius/(fov2+0.00001));{expressed in steps}

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

          telescope_ra_offset:= (STEP_SIZE*spiral_x/cos(dec_database-extra));{step larger near pole. This ra_database is an offsett from zero}
          if ((telescope_ra_offset<=+pi/2+step_size/2) and (telescope_ra_offset>=-pi/2)) then  {step_size for overlap}
          begin
            ra_database:=fnmodulo(flip+ra_radians+telescope_ra_offset,2*pi);{add offset to ra after the if statement! Otherwise no symmetrical search}

            ang_sep(ra_database,dec_database,ra_radians,dec_radians, {out}seperation);{calculates angular separation. according formula 9.1 old Meeus or 16.1 new Meeus, version 2018-5-23}
            if seperation<=radius*pi/180+step_size/2 then {Use only the circular area withing the square area}
            begin

              {info reporting}
              //stackmenu1.field1.caption:= '['+inttostr(spiral_x)+','+inttostr(spiral_y)+']';{show on stackmenu what's happening}
              if seperation*180/pi>distance+fov_org then {new distance reached. Update once in the square spiral, so not too often since it cost CPU time}
              begin
                distance:=seperation*180/pi;
                distancestr:=inttostr(round(seperation*180/pi))+'d,';{show on stackmenu what's happening}
                write(distancestr);
              end; {info reporting}

              {If a low amount of  quads are detected, the search window (so the database read area) is increased up to 200% guaranteeing that all quads of the image are compared with the database quads while stepping through the sky}
              {read nrstars_required stars from database. If search field is oversized, number of required stars increases with the power of the oversize factor. So the star density will be the same as in the image to solve}
              extrastars:=1/1.1;{star with a factor of one}
              repeat {loop to add extra stars if too many too small quads are excluding. Note the database is made by a space telescope with a resolution exceeding all earth telescopes}
                extrastars:=extrastars*1.1;
                if read_stars(ra_database,dec_database,search_field*oversize,round(nrstars_required*oversize*oversize*extrastars),{out} starlist1 ,{out}database_stars)= false then
                begin
                  memo2_message('Error, no star database found at '+database_path+' ! Download and install a star database.');
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
                memo2_message('Search '+ inttostr(count)+', ['+inttostr(spiral_x)+','+inttostr(spiral_y)+'], position: '+ prepare_ra(ra_database,': ')+prepare_dec(dec_database,'d ')+#9+' Down to magn '+ floattostrF2(mag2/10,0,1) +#9+' '+inttostr(database_stars)+' database stars' +#9+' '+inttostr(length(quad_star_distances1[0]))+' database quads to compare.');

              // for testing purposes
              // create supplement lines for sky coverage testing and write to log using -log
              // memo2.add(floattostr(ra_database*12/pi)+',,,'+floattostr(dec_database*180/pi)+',,,,'+inttostr(count)+',,-99'); {create hnsky supplement to test sky coverage}

               solution:=find_offset_and_rotation(minimum_quads {>=3},quad_tolerance);{find an solution}
            end; {within search circle. Otherwise the search is within a kind of square}
          end;{ra in range}
          inc(count);{step further in spiral}
        until ((solution) or (spiral_x>max_distance));{squared spiral search}

        if solution then
        begin
          centerX:=(width2-1)/2 ;{center image in 0..width2-1 range}
          centerY:=(height2-1)/2;{center image in 0..height2-1 range}

          standard_equatorial( ra_database,dec_database,
              (solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY) +solution_vectorX[2]), {x}
              (solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY) +solution_vectorY[2]), {y}
              1, {CCD scale}
              ra_radians ,dec_radians {center equatorial position});
          current_dist:=sqrt(sqr(solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY) +solution_vectorX[2]) + sqr(solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY) +solution_vectorY[2]))/3600; {current distance telescope and image center in degrees}
          inc(match_nr);
        end;
      until ((solution=false) or (current_dist<fov2*0.05){within 5% if image height from center}  or (match_nr>=2));{Maximum accurcy loop. After match possible on a corner do a second solve using the found ra0,dec0 for maximum accuracy USING ALL STARS}


    end; {enough quads in image}
  until ((autoFOV=false) or (solution) or (fov2<=fov_min)); {loop for autoFOV from 9.5 to 0.37 degrees. Will lock between 9.5*1.25 downto  0.37/1.25  or 11.9 downto 0.3 degrees}


  if solution then
  begin
    ang_sep(ra_radians,dec_radians,ra0,dec0, sep_search);{calculate search offset}
    ra0:=ra_radians;//store solution
    dec0:=dec_radians;
    crpix1:=centerX+1;{center image in fits coordinate range 1..width2}
    crpix2:=centery+1;

    memo2_message(#10+inttostr(nr_references)+ ' of '+ inttostr(nr_references2)+' quads selected matching within '+quad_tolerance1+' tolerance.'  {2 quads are required giving 8 star references or 3 quads giving 3 center quad references}
                 +#10+'Solution["] x:='+floattostr6(solution_vectorX[0])+'*x+ '+floattostr6(solution_vectorX[1])+'*y+ '+floattostr6(solution_vectorX[2])
                   +',  y:='+floattostr6(solution_vectorY[0])+'*x+ '+floattostr6(solution_vectorY[1])+'*y+ '+floattostr6(solution_vectorY[2]) );
    //  following doesn't give maximum angle accuracy, so is not used.
    //    cd1_1:= - solution_vectorX[0]/3600;{/3600, arcsec to degrees conversion}
    //    cd1_2:= - solution_vectorX[1]/3600;
    //    cd2_1:= + solution_vectorY[0]/3600;
    //    cd2_2:= + solution_vectorY[1]/3600;

    //New 2023 method for correct rotation angle/annotation near to the celestial pole.
    if solution_vectorX[0]*solution_vectorY[1] - solution_vectorX[1]*solution_vectorY[0] >0 then // flipped?
    flipped_image:=-1 //change rotation for flipped image, {Flipped image. Either flipped vertical or horizontal but not both. Flipped both horizontal and vertical is equal to 180 degrees rotation and is not seen as flipped}
    else
    flipped_image:=+1;//not flipped

    // position +1 pixels in direction hd.crpix2
    standard_equatorial( ra_database,dec_database, (solution_vectorX[0]*(centerX) + solution_vectorX[1]*(centerY+1) +solution_vectorX[2]), {x}
                                                   (solution_vectorY[0]*(centerX) + solution_vectorY[1]*(centerY+1) +solution_vectorY[2]), {y}
                                                    1, {CCD scale}  ra7 ,dec7{equatorial position}); // the position 10 pixels away

    //See book Meeus, Astronomical Algorithms, formula 46.5, angle of moon limb. See also https://astronomy.stackexchange.com/questions/25306/measuring-misalignment-between-two-positions-on-sky
//    crota2:=-arctan2(cos(dec7)*sin(ra7-ra_radians),sin(dec7)*cos(dec_radians) - cos(dec7)*sin(dec_radians)*cos(ra7-ra_radians));//Accurate formula. Angle between line between the two positions and north as seen at hd.ra0, hd.dec0
    crota2:=-position_angle(ra7,dec7,ra_radians,dec_radians);//Position angle between a line from ra0,dec0 to ra1,dec1 and a line from ra0, dec0 to the celestial north . Rigorous method


    // position 1*flipped_image  pixels in direction hd.crpix1
    standard_equatorial( ra_database,dec_database,(solution_vectorX[0]*(centerX+flipped_image) + solution_vectorX[1]*(centerY) +solution_vectorX[2]), {x} //A pixel_aspect_ratio unequal of 1 is very rare, none square pixels
                                                  (solution_vectorY[0]*(centerX+flipped_image) + solution_vectorY[1]*(centerY) +solution_vectorY[2]), {y}
                                                  1, {CCD scale} ra7 ,dec7{equatorial position});

    //See book Meeus, Astronomical Algorithms, formula 46.5, angle of moon limb. See also https://astronomy.stackexchange.com/questions/25306/measuring-misalignment-between-two-positions-on-sky
//    crota1:=+arctan2(sin(dec7)*cos(dec_radians) - cos(dec7)*sin(dec_radians)*cos(ra7-ra_radians),cos(dec7)*sin(ra7-ra_radians));//Accurate formula. See calculation hd.crota2, arguments arctan swapped
    crota1:=pi/2-position_angle(ra7,dec7,ra_radians,dec_radians);//Position angle between a line from ra0,dec0 to ra1,dec1 and a line from ra0, dec0 to the celestial north . Rigorous method
    if crota1>pi then crota1:=crota1-2*pi;//keep within range -pi to +pi

    cdelt1:=flipped_image*sqrt(sqr(solution_vectorX[0])+sqr(solution_vectorX[1]))/3600; // from unit arcsec to degrees
    cdelt2:=sqrt(sqr(solution_vectorY[0])+sqr(solution_vectorY[1]))/3600;



    cd1_1:=+cdelt1*cos(crota1);
    cd1_2:=-cdelt1*sin(crota1)*flipped_image;
    cd2_1:=+cdelt2*sin(crota2)*flipped_image;
    cd2_2:=+cdelt2*cos(crota2);

    crota2:=crota2*180/pi;//convert to degrees
    crota1:=crota1*180/pi;
    //end new 2023 method


    solved_in:='Solved in '+ floattostr(round((GetTickCount64 - startTick)/100)/10)+' sec';{make string to report in FITS header.}

    offset_found:=distance_to_string(sep_search ,sep_search)+'.';
    if ra_mount<99 then {mount position known and specified}
    begin
      ra_offset:=distance_to_string(sep_search, pi*frac((ra_mount-ra0)/pi) * cos((dec0+dec_mount)*0.5 {average dec}));
      dec_offset:=distance_to_string(sep_search,dec_mount-dec0);

      mount_offset:=' Mount offset RA='+ra_offset+', DEC='+dec_offset;{ascii}
      mount_info:=' Mount Δα='+ra_offset+ ',  Δδ='+dec_offset+'. ';
    end
    else
    begin
      mount_offset:='';
      mount_info:='';
    end;

    memo2_message('Solution found: '+  prepare_ra(ra0,': ')+' '+prepare_dec(dec0,'d ') +#10+solved_in+' Δ was '+offset_found+' '+ mount_info+' Used stars down to magnitude: '+floattostrF2(mag2/10,0,1) );
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
    update_text   ('PLTSOLVD=','                   T / Astrometric solved by ASTAP_CLI v'+astap_version+'.   ');
    update_text   ('COMMENT 7', solved_in+' Offset was '+offset_found+mount_offset);



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
    update_text   ('PLTSOLVD=','                   F / No plate solution found.   ');
    remove_key('COMMENT 7',false{all});
  end;

  warning_str:=warning_str + warning_downsample; {add the last warning from loop autoFOV}

//No longer required for the new D50.. databases
//  if nrstars_required>database_stars+4 then
//  begin
//    memo2_message('Warning, reached the limit of the star database!');
//    warning_str:=warning_str+' Star database limit was reached!';
//  end;

  if warning_str<>'' then
  begin
    update_longstr('WARNING =',warning_str);{update or insert long str including single quotes}
  end;

  if database_type=1 then wide_field_stars:=nil; {free wide_field_database}
end;

end.

