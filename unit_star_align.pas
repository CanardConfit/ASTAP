unit unit_star_align;
{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
   Classes, SysUtils,Graphics,math,
   astap_main, unit_stack;
type
   star_list= array of array of double;
   solution_vector   = array[0..2] of double;


var
   starlist1, starlist2                   :star_list;
   quad_star_distances1, quad_star_distances2: star_list;
   A_XYpositions                          : star_list;
   b_Xrefpositions,b_Yrefpositions        :  array of double;
   quad_smallest                          : double;
   nr_references,nr_references2               : integer;
   solution_vectorX, solution_vectorY,solution_cblack   : solution_vector ;

   Savefile: file of solution_vector;{to save solution if required for second and third step stacking}

procedure find_stars(img :image_array;hfd_min:double;out starlist1: star_list);{find stars and put them in a list}
procedure find_quads(starlist :star_list; min_leng:double; out quad_smallest:double; out quad_star_distances :star_list);  {build quads using closest stars, revised 2020-9-28}
procedure find_quads_xy(starlist :star_list; out starlistquads :star_list);  {FOR DISPLAY ONLY, build quads using closest stars, revised 2020-9-28}
function find_offset_and_rotation(minimum_quads: integer;tolerance:double) : boolean; {find difference between ref image and new image}
procedure reset_solution_vectors(factor: double); {reset the solution vectors}
procedure display_quads(starlistquads :star_list);{draw quads}

implementation

uses  unit_annotation;

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


procedure display_quads(starlistquads :star_list);{display quads in the viewer}
var
   i, nrquads,x,y, flipx,flipy: integer;
begin
  if fits_file=false then exit; {file loaded?}
  mainwindow.image1.Canvas.Pen.Mode := pmMerge;
  mainwindow.image1.Canvas.Pen.width := round(1+head.height/mainwindow.image1.height);{thickness lines}
  mainwindow.image1.Canvas.brush.Style:=bsClear;

  if mainwindow.flip_horizontal1.Checked=true then
  begin
    flipx:=-1;
    x:=head.width;
  end
  else
  begin
    flipx:=1;
    x:=0;
  end;
  if mainwindow.flip_vertical1.Checked=false then
  begin
    flipy:=-1;
    y:=head.height;
  end
  else
  begin
    flipy:=1;
    y:=0;
  end;

  nrquads:=Length(starlistquads[0])-1;

  for i:=0 to  nrquads do
  begin
    mainwindow.image1.Canvas.Pen.Color :=$606060 +random($9F9F9F);
    if odd(i) then mainwindow.image1.Canvas.Pen.Style := pssolid
       else  mainwindow.image1.Canvas.Pen.Style := psdot;
    mainwindow.image1.Canvas.moveto(x+flipx*round(starlistquads[0,i]),y+flipy*round(starlistquads[1,i]));{move to star 1}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[2,i]),y+flipy*round(starlistquads[3,i]));{draw line star1-star2}

    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[4,i]),y+flipy*round(starlistquads[5,i]));{draw line star2-star3}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[0,i]),y+flipy*round(starlistquads[1,i]));{draw line star3-star1}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[6,i]),y+flipy*round(starlistquads[7,i]));{draw line star1-star4}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[4,i]),y+flipy*round(starlistquads[5,i]));{draw line star4-star3}
    mainwindow.image1.Canvas.moveto(x+flipx*round(starlistquads[6,i]),y+flipy*round(starlistquads[7,i]));{move to star4}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[2,i]),y+flipy*round(starlistquads[3,i]));{draw line star4-star2}
  end;
end;


procedure find_quads(starlist :star_list; min_leng:double; out quad_smallest:double; out quad_star_distances :star_list);  {build quads using closest stars, revised 2020-9-28}
var
   i,j,k,nrstars_min_one,j_used1,j_used2,j_used3,nrquads,buffersize         : integer;
   distance,distance1,distance2,distance3,x1,x2,x3,x4,xt,y1,y2,y3,y4,yt,
   dist1,dist2,dist3,dist4,dist5,dist6,dummy,distx                          : double;
   identical_quad : boolean;
begin

  buffersize:=Length(starlist[0]);{number of quads will be equal (super rare) or lower}
  nrstars_min_one:=buffersize-1;
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
       On E :Exception do
       begin
         memo2_message(E.Message+ ' exception in procedure calc_quad_distances');{bug in fpc 3.20? Sets in once case the last elements of array to zero for file 4254816 new_image.fit'}
         stackmenu1.Memo2.enablealign;{allow paint messages from other controls to update tmemo. Mod 2021-06-26}
         stackmenu1.Memo2.Lines.EndUpdate; {update memo2}
       end;
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


procedure find_quads_xy(starlist :star_list; out starlistquads :star_list);  {FOR DISPLAY ONLY, build quads using closest stars, revised 2020-9-28}
var
   i,j,k,nrstars_min_one,j_used1,j_used2,j_used3,nrquads,buffersize               : integer;
   distance,distance1,distance2,distance3{,dummy },x1,x2,x3,x4,xt,y1,y2,y3,y4,yt  : double;
   identical_quad : boolean;
begin
  nrstars_min_one:=Length(starlist[0])-1;
  buffersize:=nrstars_min_one;{number of quads will be lower}
  quad_smallest:=9999999;

  if nrstars_min_one<3 then
  begin {not enough stars for quads}
    SetLength(starlistquads,10,0);
    exit;
  end;

  nrquads:=0;
  SetLength(starlistquads,10,buffersize);{set array length to buffer size}

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
        distance:=sqr(starlist[0,j]-starlist[0,i])+ sqr(starlist[1,j]-starlist[1,i]);

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

    starlistquads[0,nrquads]:=x1; {copy first star position to the quad array}
    starlistquads[1,nrquads]:=y1;
    starlistquads[2,nrquads]:=x2; {copy the second star position to the quad array}
    starlistquads[3,nrquads]:=y2;
    starlistquads[4,nrquads]:=x3;
    starlistquads[5,nrquads]:=y3;
    starlistquads[6,nrquads]:=x4;
    starlistquads[7,nrquads]:=y4;

    xt:=(x1+x2+x3+x4)/4; {mean x position quad}
    yt:=(y1+y2+y3+y4)/4; {mean y position quad}

    identical_quad:=false;
    if nrquads>=1 then {already a quad stored}
    begin
     k:=0;
     repeat {check for identical quads}
       if ( (abs(xt-starlistquads[8,k])<1) and
            (abs(yt-starlistquads[9,k])<1) ) then {same center position, found identical quad already in the list}
           begin
             identical_quad:=true;
             k:=999999999;{stop}
           end;

       inc(k);
     until k>=nrquads;
    end;

    if identical_quad=false then  {new quad found}
    begin
      starlistquads[8,nrquads]:=xt;{store mean x position}
      starlistquads[9,nrquads]:=yt;{store mean y position}
      inc(nrquads); {new unique quad found}
    end;
  end;{i}

  SetLength(starlistquads,10,nrquads);{reduce array length to number quads one shorter since last entry is not filled}
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
    end;
    result:=true;{3 or more references}
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
   //  For testing:
   //  memo2_message(#9+floattostr(snr_list[i])+#9+floattostr(starlist2[0,count])+ #9 +floattostr(starlist2[1,count]));
   //  mainwindow.image1.Canvas.Pen.Mode := pmMerge;
   //  mainwindow.image1.Canvas.Pen.width := round(1+head.height/mainwindow.image1.height);{thickness lines}
   //  mainwindow.image1.Canvas.brush.Style:=bsClear;
   //  mainwindow.image1.Canvas.Pen.Color := clred;
   //  mainwindow.image1.Canvas.Rectangle(round(starlist1[0,i])-15,head.height-round(starlist1[1,i])-15, round(starlist1[0,i])+15, head.height-round(starlist1[1,i])+15);{indicate hfd with rectangle}

       inc(count);
     end;
  setlength(starlist1,2,count);{reduce length to used length}
end;


procedure find_stars(img :image_array;hfd_min:double;out starlist1: star_list);{find stars and put them in a list}
var
   fitsX, fitsY,nrstars,radius,i,j,max_stars,retries,m,n,xci,yci,sqr_radius : integer;
   hfd1,star_fwhm,snr,xc,yc,highest_snr,flux, detection_level               : double;
   img_sa     : image_array;
   snr_list        : array of double;

// flip_vertical,flip_horizontal  : boolean;
// starX,starY :integer;
   startTick2  : qword;{for timing/speed purposes}
const
    buffersize=5000;{5000}
begin
  {for testing}
//   mainwindow.image1.Canvas.Pen.Mode := pmMerge;
//   mainwindow.image1.Canvas.Pen.width := round(1+head.height/mainwindow.image1.height);{thickness lines}
//   mainwindow.image1.Canvas.brush.Style:=bsClear;
//   mainwindow.image1.Canvas.font.color:=$FF;
//   mainwindow.image1.Canvas.font.size:=10;
//   mainwindow.image1.Canvas.Pen.Color := $FF;
//   flip_vertical:=mainwindow.flip_vertical1.Checked;
//   flip_horizontal:=mainwindow.Flip_horizontal1.Checked;

 // hfd_min:=4;


  max_stars:=strtoint(stackmenu1.max_stars1.text);{maximum star to process, if so filter out brightest stars later}
  solve_show_log:=stackmenu1.solve_show_log1.Checked;{show details, global variable}
  if solve_show_log then begin memo2_message('Start finding stars');   startTick2 := gettickcount64;end;


  SetLength(starlist1,2,buffersize);{set array length}
  setlength(snr_list,buffersize);{set array length}

  setlength(img_sa,1,head.width,head.height);{set length of image array}

  detection_level:=max(3.5*noise_level[0],star_level); {level above background. Start with a high value}
  retries:=2; {try up to three times to get enough stars from the image}
  repeat
    highest_snr:=0;
    nrstars:=0;{set counters at zero}

    for fitsY:=0 to head.height-1 do
      for fitsX:=0 to head.width-1  do
        img_sa[0,fitsX,fitsY]:=-1;{mark as star free area}

    for fitsY:=0 to head.height-1-1 do
    begin
      for fitsX:=0 to head.width-1-1  do
      begin
        if (( img_sa[0,fitsX,fitsY]<=0){star free area} and (img[0,fitsX,fitsY]-cblack>detection_level){star}) then {new star, at least 3.5 * sigma above noise level}
        begin
          HFD(img,fitsX,fitsY,14{annulus radius},99 {flux aperture restriction}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if ((hfd1<=10) and (snr>10) and (hfd1>hfd_min) {0.8 is two pixels minimum} ) then
          begin
            {for testing}
          //  if flip_vertical=false  then  starY:=round(head.height-yc) else starY:=round(yc);
          //  if flip_horizontal=true then starX:=round(head.width-xc)  else starX:=round(xc);
          //  size:=round(5*hfd1);
          //  mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
          //  mainwindow.image1.Canvas.textout(starX+size,starY+size,floattostrf(hfd1, ffgeneral, 2,1));{add hfd as text}
          //  mainwindow.image1.Canvas.textout(starX+size,starY+size,floattostrf(snr, ffgeneral, 2,1));{add hfd as text}

            radius:=round(3.0*hfd1);{for marking star area. A value between 2.5*hfd and 3.5*hfd gives same performance. Note in practice a star PSF has larger wings then predicted by a Gaussian function}
            sqr_radius:=sqr(radius);
            xci:=round(xc);{star center as integer}
            yci:=round(yc);
            for n:=-radius to +radius do {mark the whole circular star area as occupied to prevent double detection's}
              for m:=-radius to +radius do
              begin
                j:=n+yci;
                i:=m+xci;
                if ((j>=0) and (i>=0) and (j<head.height) and (i<head.width) and (sqr(m)+sqr(n)<=sqr_radius)) then
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

    if solve_show_log then memo2_message(inttostr(nrstars)+' stars found of the requested '+inttostr(max_stars)+'. Background value is '+inttostr(round(cblack))+ '. Detection level used '+inttostr( round(detection_level))
                                                          +' above background. Star level is '+inttostr(round(star_level))+' above background. Noise level is '+floattostrF(noise_level[0],ffFixed,0,0));

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

//  if ((xy_sqr_ratio<0.98) or (xy_sqr_ratio>1.02)) then {dimensions x, y are not the same, something wrong. Mod 2021-6-26, changed it from 0.99 to 0.98 because of problem solving some images like M20 }
  if ((xy_sqr_ratio<0.9) or (xy_sqr_ratio>1.1)) then {dimensions x, y are not the same, something wrong. Mod 2021-6-26, changed it from 0.99 to 0.98 because of problem solving some images like M20 }
  begin
    result:=false;
    reset_solution_vectors(0.001);{nullify}
    if solve_show_log then {global variable set in find stars} memo2_message('Solution skipped on XY ratio: '+ floattostr(xy_sqr_ratio));
  end;
end;

end.

