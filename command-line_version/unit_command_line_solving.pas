unit unit_command_line_solving;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,math;

type
  image_array = array of array of array of Single;
  star_list   = array of array of double;
  solution_vector   = array[0..2] of double;

var
   starlist1, starlist2                   : star_list;
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

function solve_image(img :image_array; get_hist{update hist}:boolean) : boolean;{find match between image and star database}
procedure bin_and_find_stars(img :image_array;binning:integer;cropping,hfd_min:double;get_hist{update hist}:boolean; out starlist3:star_list; out short_warning : string);{bin, measure background, find stars}
function report_binning(height:double) : integer;{select the binning}
var
  star1   : array[0..2] of array of single;


implementation

uses
  unit_command_line_general,
  unit_command_line_star_database;

var
  mag2  : double; {magnitude of star found}


procedure ang_sep(ra1,dec1,ra2,dec2 : double;out sep: double);{calculates angular separation. according formula 9.1 old Meeus or 16.1 new Meeus, version 2018-5-23}
var sin_dec1,cos_dec1,sin_dec2,cos_dec2,cos_sep:double;
begin
  sincos(dec1,sin_dec1,cos_dec1);{use sincos function for speed}
  sincos(dec2,sin_dec2,cos_dec2);

  cos_sep:=sin_dec1*sin_dec2+ cos_dec1*cos_dec2*cos(ra1-ra2);
  sep:=arccos(cos_sep);
end;



procedure quicksort(var list: array of double; lo,hi: integer);{ Fast quick sort. Sorts elements in the array list with indices between lo and hi}
  procedure sort ( left, right : integer); {processing takes place in the sort procedure which executes itself recursively.}
  var
    i, j       : integer;
    tmp, pivot : double;    { tmp & pivot are the same type as the elements of array }
  begin
    i:=left;
    j:=right;
    pivot := list[(left + right) div 2];
    repeat
      while pivot > list[i] do inc(i);
      while pivot < list[j] do dec(j);
      if i<=j Then Begin
        tmp:=list[i]; list[i]:=list[j]; list[j]:=tmp; {swap}
        dec(j); inc(i);
      end;
    until i>j;
    if left<j then sort(left,j);
    if i<right then sort(i,right);
  end;
begin {quicksort};
  sort(lo,hi);
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
{   In matrix calculations, b_matrix[0..nr_equations-1,0..nr_columns-1]:=solution_vector[0..2] * A_XYpositions[0..nr_equations-1,0..nr_columns-1]}
{                                                                                                                              }
{   see also Montenbruck & Pfleger, Astronomy on the personal computer}
procedure lsq_fit( A_matrix: star_list; {[0..nr_equations-1, 0..3]}
                       b_matrix  : array of double;{equations result, b=A*s}
                       var x_matrix: array of double );
  const tiny = 1E-10;  {accuracy}
  var i,j,k, nr_equations,nr_columns  : integer;
      p,q,h                           : double;
      temp_matrix                     : star_list;

begin
  nr_equations:=length(A_matrix);
  nr_columns:=length(A_matrix[nr_equations-1]);{should be 3 for this application}

  temp_matrix:=A_matrix; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
  setlength(temp_matrix,nr_equations,nr_columns);{duplicate A_matrix to protect data in A_matrix}

  for j:=0 to nr_columns-1 do {loop over columns of temp_matrix}
  {eliminate matrix elements A[i,j] with i>j from column j}
    for i:=j+1 to nr_equations-1 do
      if temp_matrix[i,j]<>0 then
      begin{calculate p, q and new temp_matrix[j,j]; set temp_matrix[i,j]=0}
        if abs(temp_matrix[j,j])<tiny*abs(temp_matrix[i,j]) then
        begin
          p:=0;
          q:=1;
          temp_matrix[j,j]:=-temp_matrix[i,j];
          temp_matrix[i,i]:=0;
        end
        else
        begin
          h:=sqrt(temp_matrix[j,j]*temp_matrix[j,j]+temp_matrix[i,j]*temp_matrix[i,j]);
          if temp_matrix[j,j]<0 then h:=-h;
          p:=temp_matrix[j,j]/h;
          q:=-temp_matrix[i,j]/h;
          temp_matrix[j,j]:=h;
          temp_matrix[i,j]:=0;
        end;
        {calculate the rest of the line}
        for k:=j+1 to nr_columns-1 do
        begin
          h:= p*temp_matrix[j,k] - q*temp_matrix[i,k];
          temp_matrix[i,k] := q*temp_matrix[j,k] + p*temp_matrix[i,k];
          temp_matrix[j,k] := h;
        end;
        h:= p*b_matrix[j] - q*b_matrix[i];
        b_matrix[i] := q*b_matrix[j] + p*b_matrix[i];
        b_matrix[j] := h;
      end;

  for i:= nr_columns-1 downto 0 do {back substitution}
  begin
    H:=b_matrix[i];
    for k:=i+1 to nr_columns-1 do h:=h-temp_matrix[i,k]*x_matrix[k];
    x_matrix[i] := h/temp_matrix[i,i];
    {solution vector x:=x_matrix[0]x+x_matrix[1]y+x_matrix[2]}
  end;
end; {lsq_fit}


procedure find_quads(starlist :star_list; min_leng:double; out quad_smallest:double; out quad_star_distances :star_list);  {build quads using closest stars, revised 2020-9-28}
var
   i,j,k,nrstars_min_one,j_used1,j_used2,j_used3,nrquads,buffersize               : integer;
   distance,distance1,distance2,distance3{,dummy },x1,x2,x3,x4,xt,y1,y2,y3,y4,yt,
   dist1,dist2,dist3,dist4,dist5,dist6,distx, dummy  :double;
   identical_quad : boolean;
begin
  nrstars_min_one:=Length(starlist[0])-1;
  buffersize:=nrstars_min_one;{number of quads will be lower}
  quad_smallest:=9999999;

  if nrstars_min_one<3 then
  begin {not enough stars for quads}
    SetLength(quad_star_distances,8,0);
    exit;
  end;

  nrquads:=0;
  SetLength(quad_star_distances,8,buffersize);{will contain the six distances and the central position}

  j_used1:=0;{give it a default value}
  j_used2:=0;
  j_used3:=0;

  for i:=0 to nrstars_min_one do
  begin
    distance1:=1E99;{distance closest star}
    distance2:=1E99;{distance second closest star}
    distance3:=1E99;{distance third closest star}

    for j:=0 to nrstars_min_one do {find closest stars}
    begin
      if j<>i{not the first star} then
      begin
        distx:=sqr(starlist[0,j]-starlist[0,i]);
        if distx<distance3 then {pre-check to increase processing speed with a small amount}
        begin
          distance:=distx + sqr(starlist[1,j]-starlist[1,i]);
          if distance>1 then {not an identical star. Mod 2021-6-25}
          begin
            if distance<distance1 then
            begin
              distance3:=distance2;{distance third closest star}
              j_used3:=j_used2;

              distance2:=distance1;{distance second closest star}
              j_used2:=j_used1;

              distance1:=distance;{distance closest star}
              j_used1:=j;{mark later as used}
            end
            else
            if distance<distance2 then
            begin
              distance3:=distance2;{distance third closest star}
              j_used3:=j_used2;

              distance2:=distance;{distance second closest star}
              j_used2:=j;
            end
            else
            if distance<distance3 then
            begin
              distance3:=distance;{third closest star}
              j_used3:=j;
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
       //memo2_message('Exception in procedure calc_quad_distances');{bug in fpc 3.20? Sets in once case the last elements of array to zero for file 4254816 new_image.fit'}
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
    setlength(A_XYpositions,nr_references,3);
    setlength(b_Xrefpositions,nr_references);
    setlength(b_Yrefpositions,nr_references);

    for k:=0 to nr_references-1 do
    begin
      A_XYpositions[k,0]:=quad_star_distances2[6,matchlist1[1,k]]; {average x position of quad}
      A_XYpositions[k,1]:=quad_star_distances2[7,matchlist1[1,k]]; {average y position of quad}
      A_XYpositions[k,2]:=1;

      b_Xrefpositions[k]:=quad_star_distances1[6,matchlist1[0,k]]; {x position of ref quad}
      b_Yrefpositions[k]:=quad_star_distances1[7,matchlist1[0,k]]; {Y position of ref quad}

      {in matrix calculations, b_refpositionX[0..nr_equations-1,0..2]:=solution_vectorX[0..2] * A_XYpositions[0..nr_equations-1,0..2]}
      {                        b_refpositionY[0..nr_equations-1,0..2]:=solution_matrixY[0..2] * A_XYpositions[0..nr_equations-1,0..2]}
      result:=true;{3 or more references}
    end;
  end;
//  else
//  if ((nr_references>=2) and (nrquads1<10) and (nrquads2<10)) then {use 8 stars of 2 quads as reference. Solver requires 3 equations minimum}
//  begin
//    {fill equations}
//    setlength(A_XYpositions,nr_references*4,3);{use 4 stars as reference instead of quads center}
//    setlength(b_Xrefpositions,nr_references*4);
//    setlength(b_Yrefpositions,nr_references*4);

//    for k:=0 to (nr_references*4)-1 do {use 2 * 4 stars of 2 quads}
//    begin
//      kd4:=k div 4;
//      A_XYpositions[kd4,0]:=starlistquads2[0,matchlist1[1,kd4]]; {x position of star}
//      A_XYpositions[kd4,1]:=starlistquads2[1,matchlist1[1,kd4]]; {y position of star}
//      A_XYpositions[kd4,2]:=1;
//      A_XYpositions[kd4+1,0]:=starlistquads2[2,matchlist1[1,kd4]]; {x position of star}
//      A_XYpositions[kd4+1,1]:=starlistquads2[3,matchlist1[1,kd4]]; {y position of star}
//      A_XYpositions[kd4+1,2]:=1;
//      A_XYpositions[kd4+2,0]:=starlistquads2[4,matchlist1[1,kd4]]; {x position of star}
//      A_XYpositions[kd4+2,1]:=starlistquads2[5,matchlist1[1,kd4]]; {y position of star}
//      A_XYpositions[kd4+2,2]:=1;
//      A_XYpositions[kd4+3,0]:=starlistquads2[6,matchlist1[1,kd4]]; {x position of star}
//      A_XYpositions[kd4+3,1]:=starlistquads2[7,matchlist1[1,kd4]]; {y position of star}
//      A_XYpositions[kd4+3,2]:=1;

//      b_Xrefpositions[kd4]:=starlistquads1[0,matchlist1[0,kd4]]; {x position of ref star}
//      b_Yrefpositions[kd4]:=starlistquads1[1,matchlist1[0,kd4]]; {Y position of ref star}
//      b_Xrefpositions[kd4+1]:=starlistquads1[2,matchlist1[0,kd4]]; {x position of ref star}
//      b_Yrefpositions[kd4+1]:=starlistquads1[3,matchlist1[0,kd4]]; {Y position of ref star}
//      b_Xrefpositions[kd4+2]:=starlistquads1[4,matchlist1[0,kd4]]; {x position of ref star}
//      b_Yrefpositions[kd4+2]:=starlistquads1[5,matchlist1[0,kd4]]; {Y position of ref star}
//      b_Xrefpositions[kd4+3]:=starlistquads1[6,matchlist1[0,kd4]]; {x position of ref star}
//      b_Yrefpositions[kd4+3]:=starlistquads1[7,matchlist1[0,kd4]]; {Y position of ref star}
//      result:=true;{8 star references from 2 quads}
//    end;
// end;
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
   fitsX, fitsY,nrstars,diam,i,j, max_stars,retries,m,n,xci,yci,sqr_diam         : integer;
   hfd1,star_fwhm,snr,xc,yc,highest_snr,flux, detection_level                    : double;
   img_sa          : image_array;
   snr_list        : array of double;
   startTick2      : qword;{for timing/speed purposes}
const
    buffersize=5000;{5000}
begin



  max_stars:=strtoint(max_stars1);{maximum star to process, if so filter out brightest stars later}
  if solve_show_log then begin memo2_message('Start finding stars');   startTick2 := gettickcount64;end;
  SetLength(starlist1,2,buffersize);{set array length}
  setlength(snr_list,buffersize);{set array length}

  setlength(img_sa,1,width2,height2);{set length of image array}

  detection_level:=max(3.5*noise_level[0],star_level); {level above background. Start with a high value}
  retries:=2; {try up to three times to get enough stars from the image}
  repeat
    highest_snr:=0;
    nrstars:=0;{set counters at zero}

    for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1  do
        img_sa[0,fitsX,fitsY]:=-1;{mark as not surveyed}

    for fitsY:=0 to height2-1-1 do
    begin
      for fitsX:=0 to width2-1-1  do
      begin
        if (( img_sa[0,fitsX,fitsY]<=0){star free area} and (img[0,fitsX,fitsY]-cblack>detection_level){star}) then {new star, at least 3.5 * sigma above noise level}
        begin
          HFD(img,fitsX,fitsY,14{box size}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if ((hfd1<=10) and (snr>10) and (hfd1>hfd_min) {0.8 is two pixels minimum} ) then
          begin
            diam:=round(3.0*hfd1);{for marking star area. Emperical a value between 2.5*hfd and 3.5*hfd gives same performance. Note in practise a star PSF has larger wings then predicted by a Gaussian function}
            sqr_diam:=sqr(diam);
            xci:=round(xc);{star center as integer}
            yci:=round(yc);
            for n:=-diam to +diam do {mark the whole circular star area width diameter "diam" as occupied to prevent double detections}
              for m:=-diam to +diam do
              begin
                j:=n+yci;
                i:=m+xci;
                if ((j>=0) and (i>=0) and (j<height2) and (i<width2) and ( (sqr(m)+sqr(n))<=sqr_diam)) then
                  img_sa[0,i,j]:=1;
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

    if solve_show_log then memo2_message(inttostr(nrstars)+' stars found of the requested '+inttostr(max_stars)+'. Background value is '+inttostr(round(cblack))+ '. Detection level used '+inttostr( round(detection_level))+' above background. Star level is '+inttostr(round(star_level))+' above background. Noise level is '+floattostrF2(noise_level[0],0,0));

    dec(retries);{In principle not required. Try again with lower detection level}
    if detection_level<=7*noise_level[0] then retries:= -1 {stop}
    else
    detection_level:=max(6.999*noise_level[0],min(30*noise_level[0],detection_level*6.999/30)); {very high -> 30 -> 7 -> stop.  Or  60 -> 14 -> 7.0. Or for very short exposures 3.5 -> stop}

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

  {in matrix calculations, b_refpositionX[0..nr_equations-1,0..2]:=solution_vectorX[0..2] * A_XYpositions[0..nr_equations-1,0..2]}
  {                        b_refpositionY[0..nr_equations-1,0..2]:=solution_vectorY[0..2] * A_XYpositions[0..nr_equations-1,0..2]}

  {find solution vector for X:=ax+by+c  / b_Xref:=solution[0]x+solution[1]y+solution[2]}
   lsq_fit( A_XYpositions {[0..nr_equations-1, 0..2]},b_Xrefpositions, solution_vectorX {[0..2]} );

  {find solution vector for Y:=ax+by+c  / b_Yref:=solution[0]x+solution[1]y+solution[2]}
  lsq_fit( A_XYpositions {[0..nr_equations-1, 0..2]},b_Yrefpositions, solution_vectorY {[0..2]} );


  xy_sqr_ratio:=(sqr(solution_vectorX[0])+sqr(solution_vectorX[1]) ) / (0.00000001+ sqr(solution_vectorY[0])+sqr(solution_vectorY[1]) );

  if ((xy_sqr_ratio<0.98) or (xy_sqr_ratio>1.02)) then {dimensions x, y are not the same, something wrong. Mod 2021-6-26, changed it from 0.99 to 0.98 because of problem solving some images like M20 }
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


function read_stars(telescope_ra,telescope_dec,search_field : double; nrstars_required: integer; out nrstars:integer): boolean;{read star from star database}
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

    get_background(0,img_binned,true {load hist},true {calculate also standard deviation background},{var}cblack,star_level );{get back ground}
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
      starlist3[0,i]:=starlist3[0,i]*binning+(width2*(1-cropping)/2);{correct star positions for binning/ cropping}
      starlist3[1,i]:=starlist3[1,i]*binning+(height2*(1-cropping)/2);
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

    get_background(0,img,get_hist {load hist},true {calculate also standard deviation background}, {var} cblack,star_level);{get back ground}
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


function solve_image(img :image_array;get_hist{update hist}:boolean) : boolean;{find match between image and star database}
var
  nrstars,nrstars_required,count,max_distance,nr_quads, minimum_quads,database_stars,distance,binning,match_nr,
  spiral_x, spiral_y, spiral_dx, spiral_dy,spiral_t                                                                  : integer;
  search_field,step_size,telescope_ra,telescope_dec,telescope_ra_offset,radius,fov2,fov_org, max_fov,oversize,sep,
  ra7,dec7,centerX,centerY,cropping, min_star_size_arcsec,hfd_min,delta_ra,current_dist,
  quad_tolerance,dummy, extrastars                                                                                   : double;
  solution, go_ahead ,autoFOV      : boolean;
  startTick  : qword;{for timing/speed purposes}
  distancestr,oversize_mess,mess,suggest_str, warning_downsample, solved_in, offset_found,ra_offset,dec_offset,mount_info,mount_offset : string;


begin
  result:=false;
  esc_pressed:=false;
  warning_str:='';{for header}
  startTick := GetTickCount64;

  quad_tolerance:=strtofloat2(quad_tolerance1);

  if ((fov_specified=false) and (cdelt2<>0)) then {no fov in native command line and cdelt2 in header}
    fov_org:=height2*abs(cdelt2) {calculate FOV. PI can give negative CDELT2}
  else
   fov_org:=min(180,strtofloat2(search_fov1));{use specfied FOV in stackmenu. 180 max to prevent runtime errors later}


  if select_star_database(star_database1)=false then
  begin
    result:=false;
    memo2_message('Error, no star database found at '+database_path+' ! Download the h18 (or h17, v17) and install.');
    errorlevel:=32;{no star database}
    exit;
  end
  else
  begin {sets also file290 do this before cropping selection}
    star_database1:=name_database;
    memo2_message('Using star database '+uppercase(name_database));
    if ((fov_org>6) and (file290=false)) then
    begin
      warning_str:=warning_str+'Large FOV, use V17 or G17 database! ';
      memo2_message(warning_str);
    end;
  end;

  if file290 then {.290 database}
    max_fov:=9.53 {warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected}
  else  {.1476 database}
    max_fov:=5.142857143; {warning FOV should be less the database tiles dimensions, so <=5.142857143 degrees. Otherwise a tile beyond next tile could be selected}

  dec_radians:=dec0; {store temporary}
  ra_radians:=ra0;
  min_star_size_arcsec:=strtofloat2(min_star_size1); {arc sec};
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


    binning:=report_binning(height2*max_fov/max(fov_org{could be zero},max_fov)); {select binning on dimensions of cropped image only}
    hfd_min:=max(0.8,min_star_size_arcsec/(binning*fov_org*3600/height2) );{to ignore hot pixels which are too small}
    bin_and_find_stars(img,binning,cropping,hfd_min,get_hist{update hist}, starlist2, warning_downsample);{bin, measure background, find stars. Do this every repeat since hfd_min is adapted}
    nrstars:=Length(starlist2[0]);

     {prepare popupnotifier1 text}
    if force_oversize1=false then mess:=' normal' else mess:=' slow';
    memo2_message('ASTAP solver '+version+#10+
                  'Search radius: '+ radius_search1+' degrees, '+#10+
                  'Start position: '+prepare_ra(ra0,': ')+', '+prepare_dec(dec0,'d ')+#10+
                  'Image height: '+floattostrf2(fov_org,0,2)+' degrees'+#10+
                  'Binning: '+inttostr(binning)+'x'+inttostr(binning)+#10+
                  'Image dimensions:'+inttostr(width2)+'x'+inttostr(height2)+#10+
                  'Quad tolerance:'+quad_tolerance1+#10+
                  'Minimum star size:'+min_star_size1+'"' +#10+
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

      max_distance:=round(radius/(fov2+0.00001));

      memo2_message(inttostr(nrstars)+' stars, '+inttostr(nr_quads)+' quads selected in the image. '+inttostr(nrstars_required)+' database stars, '+inttostr(round(nr_quads*nrstars_required/nrstars))+' database quads required for the square search field of '+floattostrF2(fov2,0,1)+'d. '+oversize_mess );

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
      search_field:=fov2*(pi/180);
      STEP_SIZE:=search_field;{fixed step size search spiral. Prior to version 0.9.211 this was reduced for small star counts}
      //stackmenu1.Memo2.Lines.BeginUpdate;{do not update tmemo, very very slow and slows down program}
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
          telescope_dec:=STEP_SIZE*spiral_y+dec_radians;

          if ((telescope_dec<=pi/2+search_field) and (telescope_dec>=-pi/2-search_field)) then {within dec range}
          begin {dec withing range}
            telescope_ra_offset:= (STEP_SIZE*spiral_x/cos(telescope_dec));{step larger near pole. This telescope_ra is an offsett from zero}

            if ((telescope_ra_offset<=pi+search_field*2 {required for 180 degrees coverage}) and (telescope_ra_offset>=-pi-search_field*2) ) then {ra and dec within in range, near poles ra goes  much faster}
            begin
              telescope_ra:=fnmodulo(ra_radians+telescope_ra_offset,2*pi);{add offset to ra after the if statement! Otherwise no symmetrical search}

              {info reporting}
              //stackmenu1.field1.caption:= '['+inttostr(spiral_x)+','+inttostr(spiral_y)+']';{show on stackmenu what's happening}
              if ((spiral_x>distance) or (spiral_y>distance)) then {new distance reached. Update once in the square spiral, so not too often since it cost CPU time}
              begin
                distance:=max(spiral_x,spiral_y);{update status}
                distancestr:=inttostr(  round((distance) * fov2))+'d,';{show on stackmenu what's happening}
                write(distancestr);
              end; {info reporting}


              {If a low amount of  quads are detected, the search window (so the database read area) is increased up to 200% guaranteeing that all quads of the image are compared with the database quads while stepping through the sky}
              {read nrstars_required stars from database. If search field is oversized, number of required stars increases with the power of the oversize factor. So the star density will be the same as in the image to solve}
              extrastars:=1/1.1;{star with a factor of one}
              repeat {loop to add extra stars if too many too small quads are excluding. Note the database is made by a space telescope with a resolution exceeding all earth telescopes}
                extrastars:=extrastars*1.1;
                if read_stars(telescope_ra,telescope_dec,search_field*oversize,round(nrstars_required*oversize*oversize*extrastars) ,{var}database_stars)= false then
                begin
                  memo2_message('Error, no star database found at '+database_path+' ! Download the h18 (or h17, v17) and install.');
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
                memo2_message('Search '+ inttostr(count)+', ['+inttostr(spiral_x)+','+inttostr(spiral_y)+'], position: '+ prepare_ra(telescope_ra,': ')+prepare_dec(telescope_dec,'d ')+#9+' Down to magn '+ floattostrF2(mag2/10,0,1) +#9+' '+inttostr(database_stars)+' database stars' +#9+' '+inttostr(length(quad_star_distances1[0]))+' database quads to compare.');

              // for testing purposes
              // create supplement lines for sky coverage testing
              // stackmenu1.memo2.lines.add(floattostr(telescope_ra*12/pi)+',,,'+floattostr(telescope_dec*180/pi)+',,,,'+inttostr(count)+',,-99'); {create hnsky supplement to test sky coverage}

               solution:=find_offset_and_rotation(minimum_quads {>=3},quad_tolerance);{find an solution}
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
    end; {enough quads in image}
  until ((autoFOV=false) or (solution) or (fov2<=0.38)); {loop for autoFOV from 9.5 to 0.37 degrees. Will lock between 9.5*1.25 downto  0.37/1.25  or 11.9 downto 0.3 degrees}

  if solution then
  begin
    memo2_message(#10+inttostr(nr_references)+ ' of '+ inttostr(nr_references2)+' quads selected matching within '+quad_tolerance1+' tolerance.'  {2 quads are required giving 8 star references or 3 quads giving 3 center quad references}
                 +#10+'Solution["] x:='+floattostr6(solution_vectorX[0])+'*x+ '+floattostr6(solution_vectorX[1])+'*y+ '+floattostr6(solution_vectorX[2])
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
    solved_in:='Solved in '+ floattostr(round((GetTickCount64 - startTick)/100)/10)+' sec';{make string to report in FITS header.}

    offset_found:=distance_to_string(sep ,sep)+'.';

    if ra_mount<99 then {mount position known and specified}
    begin
      ra_offset:=distance_to_string(dec_mount-dec0,(ra_mount-ra0)*cos(dec0));
      dec_offset:=distance_to_string(dec_mount-dec0,dec_mount-dec0);
      mount_offset:=' Mount offset RA='+ra_offset+', DEC='+dec_offset;{ascii}
      mount_info:=' Mount offset Δα='+ra_offset+ ',  Δδ='+dec_offset+'. ';
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
    update_text   ('PLTSOLVD=','                   T / ASTAP internal solver      ');
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

  if nrstars_required>database_stars+4 then
  begin
    memo2_message('Warning, reached maximum magnitude of star database!');
    warning_str:=warning_str+' Star database limit was reached!';
  end;

  if warning_str<>'' then
  begin
    update_longstr('WARNING =',warning_str);{update or insert long str including single quotes}
  end;
end;

end.

