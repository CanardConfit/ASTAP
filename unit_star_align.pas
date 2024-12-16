unit unit_star_align;
{Copyright (C) 2017, 2024 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
   Classes, SysUtils,Graphics,math,
   astap_main, unit_stack;
type
   solution_vector   = array[0..2] of double;

type
    Tstar_long_record = record
                   nr   : integer;//star number
                   x,y  : double;
                 end;

var
   //starlist2,
   quad_star_distances1, quad_star_distances2: star_list;
   A_XYpositions                          : star_list;
   b_Xrefpositions,b_Yrefpositions        : array of double;
   nr_references,nr_references2           : integer;
   solution_vectorX, solution_vectorY,solution_cblack   : solution_vector ;

   Savefile: file of solution_vector;{to save solution if required for second and third step stacking}

procedure find_stars(img :image_array; hfd_min:double; max_stars :integer;out starlist1: star_list);{find stars and put them in a list}
procedure find_quads(starlist :star_list; out quad_star_distances :star_list); {find more quads build quads using closest stars}
procedure find_triples_using_quads(starlist :star_list;  out quad_star_distances :star_list);  {Find triples and store as quads. Triples are extracted from quads to maximize the number of triples and cope with low amount of detectable stars. For a low star count (<30) the star patterns can be different between image and database due to small magnitude differences. V 2022-9-23}
procedure find_quads_xy(starlist :star_list; out starlistquads :star_list);  {FOR DISPLAY ONLY, build quads using closest stars, revised 2020-9-28}
function find_offset_and_rotation(minimum_quads: integer;tolerance:double) : boolean; {find difference between ref image and new image}
procedure reset_solution_vectors(factor: double); {reset the solution vectors}
procedure display_quads(starlistquads :star_list);{draw quads}
function solution_str: string;

implementation

uses  unit_annotation;


function floattostr6b(x:double):string;//always with dot decimal seperator. Float to string with 6 decimals
begin
  str(x:5:5,result);
end;

function solution_str: string;
begin
  result:='Solution[px] x:='+floattostr6(solution_vectorX[0])+'x+ '+floattostr6(solution_vectorX[1])+'y+ '+floattostr6(solution_vectorX[2])
                   +',  y:='+floattostr6(solution_vectorY[0])+'x+ '+floattostr6(solution_vectorY[1])+'y+ '+floattostr6(solution_vectorY[2]);
end;

{   lsq_fit:                                                                                                                                     }
{   Find the solution vector of an overdetermined system of linear equations according to the method of least squares using GIVENS rotations     }
{                                                                                                                                                }
{   Solve x of A x = b with the least-squares method                                                                                             }
{   In matrix calculations, b_matrix[0..nr_columns-1,0..nr_equations-1]:=solution_vector[0..2] * A_XYpositions[0..nr_columns-1,0..nr_equations-1]}
{                                                                                                                              }
{   see also Montenbruck & Pfleger, Astronomy on the personal computer}
function lsq_fit( A_matrix: star_list; {[, 0..3,0..nr_equations-1]} b_matrix  : array of double;{equations result, b=A*s}  out x_matrix: solution_vector ): boolean;
  const tiny = 1E-10;  {accuracy}
  var i,j,k, nr_equations,nr_columns,hhh  : integer;
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
          // Notes:
          // Zero the left bottom corner of the matrix
          // Residuals are r1..rn
          // The sum of the sqr(residuals) should be minimised.
          // Take two numbers where (p^2+q^2) = 1.
          // Then (r1^2+r2^2) = (p^2+q^2)*(r1^2+r2^2)
          // Choose p and h as follows:
          // p = +A11/h
          // q = -A21/h
          // where h= +-sqrt(A11^2+A21^2)
          // A21=q*A11+p*A21 = (-A21*A11 + A21*A11)/h=0
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
    if abs(temp_matrix[i,i])>1E-30 then x_matrix[i] := h/temp_matrix[i,i]
    else
    exit(false);//Prevent runtime error dividing by zero. Should normally not happen. In case of zero due to wrong double star detection by using triples force a failure

    {solution vector x:=x_matrix[0]x+x_matrix[1]y+x_matrix[2]}
  end;
  result:=true;
end; {lsq_fit}


procedure display_quads(starlistquads :star_list);{display quads in the viewer}
var
   i, nrquads,x,y, flipx,flipy: integer;
begin
  if head.naxis=0 then exit; {file loaded?}
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

  mainwindow.image1.Canvas.Pen.mode:=pmXor;

  for i:=0 to nrquads do
  begin
    mainwindow.image1.Canvas.Pen.Color :=$606060 +random($9F9F9F);
    if odd(i) then mainwindow.image1.Canvas.Pen.Style := pssolid
       else  mainwindow.image1.Canvas.Pen.Style := psdot;

    try
    mainwindow.image1.Canvas.moveto(x+flipx*round(starlistquads[0,i]),y+flipy*round(starlistquads[1,i]));{move to star 1}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[2,i]),y+flipy*round(starlistquads[3,i]));{draw line star1-star2}

    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[4,i]),y+flipy*round(starlistquads[5,i]));{draw line star2-star3}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[0,i]),y+flipy*round(starlistquads[1,i]));{draw line star3-star1}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[6,i]),y+flipy*round(starlistquads[7,i]));{draw line star1-star4}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[4,i]),y+flipy*round(starlistquads[5,i]));{draw line star4-star3}
    mainwindow.image1.Canvas.moveto(x+flipx*round(starlistquads[6,i]),y+flipy*round(starlistquads[7,i]));{move to star4}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlistquads[2,i]),y+flipy*round(starlistquads[3,i]));{draw line star4-star2}

    except
    end;
  end;
  memo2_message(inttostr( nrquads)+ ' quads found.');
end;


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

{procedure QuickSort_records_on_X(var A: array of Tstar_long_record; iLo, iHi: Integer) ;// Fast quick sort. Sorts elements in the array A containing records with indices between lo and hi
var
  Lo, Hi : integer;
  Pivot : double;
  T: Tstar_long_record;
begin
  Lo := iLo;
  Hi := iHi;
  Pivot := A[(Lo + Hi) div 2].x;
  repeat
    while A[Lo].x < Pivot do Inc(Lo) ;
    while A[Hi].x > Pivot do Dec(Hi) ;
    if Lo <= Hi then
    begin //swap
      T := A[Lo];
      A[Lo] := A[Hi];
      A[Hi] := T;
      Inc(Lo) ;
      Dec(Hi) ;
    end;
  until Lo > Hi;
  if Hi > iLo then QuickSort_records_on_X(A, iLo, Hi) ; //executes itself recursively
  if Lo < iHi then QuickSort_records_on_X(A, Lo, iHi) ; //executes itself recursively
end;
}
{procedure QuickSort_records_on_Y(var A: array of Tstar_long_record; iLo, iHi: Integer) ;// Fast quick sort. Sorts elements in the array A containing records with indices between lo and hi
var
  Lo, Hi : integer;
  Pivot : double;
  T: Tstar_long_record;
begin
  Lo := iLo;
  Hi := iHi;
  Pivot := A[(Lo + Hi) div 2].y;
  repeat
    while A[Lo].y < Pivot do Inc(Lo) ;
    while A[Hi].y > Pivot do Dec(Hi) ;
    if Lo <= Hi then
    begin //swap
      T := A[Lo];
      A[Lo] := A[Hi];
      A[Hi] := T;
      Inc(Lo) ;
      Dec(Hi) ;
    end;
  until Lo > Hi;
  if Hi > iLo then QuickSort_records_on_Y(A, iLo, Hi) ; //{executes itself recursively
  if Lo < iHi then QuickSort_records_on_Y(A, Lo, iHi) ; //executes itself recursively
end;
}

{
//Advanced but slower. Not used
procedure find_quads(starlist :star_list; out quad_star_distances :star_list);  //build quads using closest stars, revised 2024-12-16
var
   nrstars,i,j,k,j_index1,j_index2,j_index3,nrquads,neighbourdistance,m,n,Xposition,YpositionRef, Yposition,starnr : integer;
   distance,distance1,distance2,distance3,x1,x2,x3,x4,xt,y1,y2,y3,y4,yt  : double;
   dist1,dist2,dist3,dist4,dist5,dist6,dummy,disty                          : double;
   identical_quad : boolean;
   star_list_sorted_X, star_list_sorted_Y: array of Tstar_long_record;
   index_y_stars: array of integer;
begin
  nrstars:=Length(starlist[0]);

  if nrstars<4 then
  begin //not enough stars for quads
    SetLength(quad_star_distances,8,0);
    exit;
  end;

  setlength(star_list_sorted_X,nrstars);
  setlength(star_list_sorted_Y,nrstars);
  for i:=0 to nrstars-1 do
  begin
    star_list_sorted_X[i].nr:=i; //give it a star number
    star_list_sorted_Y[i].nr:=i; //give it a star number
    star_list_sorted_X[i].x:=starlist[0,i]; //store X
    star_list_sorted_Y[i].x:=starlist[0,i];
    star_list_sorted_X[i].y:=starlist[1,i];
    star_list_sorted_Y[i].y:=starlist[1,i];
  end;
  QuickSort_records_on_X(star_list_sorted_X, 0,nrstars-1);
  QuickSort_records_on_Y(star_list_sorted_Y, 0,nrstars-1);

  setlength(index_y_stars,nrstars);
  for i:=0 to nrstars-1 do
       index_y_stars[star_list_sorted_Y[i].nr]:=i;


  //memo2_message(inttostr(nrstars_min_one+1)+' stars found.');

  neighbourdistance:=2*round(sqrt(Length(starlist[0])));


//  neighbourdistance:=strtoint(mainwindow.Edit1.caption);

  nrquads:=0;
  SetLength(quad_star_distances,8,nrstars);//will contain the six distances and the central position

  j_index1:=0;//give it a default value
  j_index2:=0;
  j_index3:=0;

  for i:=0 to nrstars-1 do
  begin
    x1:=star_list_sorted_X[i].x; //1e star position
    y1:=star_list_sorted_X[i].y;
    YpositionRef:=index_y_stars[star_list_sorted_X[i].nr];

    distance1:=1E99;//distance closest star
    distance2:=1E99;//distance second closest star
    distance3:=1E99;//distance third closest star

    //restrict search area in X and Y by a square with sides of neighbour distance. So ± neighbour stars in X and ± neighbour stars in Y
    for k:=-neighbourdistance to neighbourdistance do //use all stars close in X
    begin
      if k<>0 then //not the same star
      begin
        j:=i+k;
        if ((j>0) and (j<=nrstars-1)) then
        begin
          starnr:= star_list_sorted_X[j].nr;//new star with simular X value
          Yposition:=index_y_stars[starnr];//the corresponding Y position

          if  abs(YpositionRef- Yposition)<=neighbourdistance then //simular Y position
          begin
            distance:=sqr( star_list_sorted_X[j].x - x1)+ distY ;

            if distance<distance1 then
            begin
              distance3:=distance2;//distance third closest star
              j_index3:=j_index2;

              distance2:=distance1;//distance second closest star
              j_index2:=j_index1;

              distance1:=distance;//distance closest star
              j_index1:=j;//mark later as used
            end
            else
            if distance<distance2 then
            begin
              distance3:=distance2;//distance third closest star
              j_index3:=j_index2;

              distance2:=distance;//distance second closest star
              j_index2:=j;
            end
            else
            if distance<distance3 then
            begin
              distance3:=distance;//third closest star
              j_index3:=j;
            end;

          end;
        end;
      end;
    end;

    if  distance3<1E99 then //found enough stars in the restricted area
    begin

      x2:=star_list_sorted_X[j_index1].x;//2e star position
      y2:=star_list_sorted_X[j_index1].y;//2e star position

      x3:=star_list_sorted_X[j_index2].x;//3e star position
      y3:=star_list_sorted_X[j_index2].y;//3e star position

      x4:=star_list_sorted_X[j_index3].x;//4e star position
      y4:=star_list_sorted_X[j_index3].y;//4e star position

      xt:=(x1+x2+x3+x4)/4; //mean x position quad
      yt:=(y1+y2+y3+y4)/4; //mean y position quad


      identical_quad:=false;
      for k:=0 to nrquads-1 do // check for an identical quad
      begin
        if ( (abs(xt-quad_star_distances[6,k])<1) and
             (abs(yt-quad_star_distances[7,k])<1) ) then //same center position, found identical quad already in the list
        begin
          identical_quad:=true;
          break;//stop searching
        end;
      end;

      if identical_quad=false then  //new quad found
      begin
        dist1:=sqrt(distance1);//distance star1-star2, use previous value already calculated
        dist2:=sqrt(distance2);//distance star1-star3
        dist3:=sqrt(distance3);//distance star1-star4
        dist4:=sqrt(sqr(x2-x3)+ sqr(y2-y3));//distance star2-star3
        dist5:=sqrt(sqr(x2-x4)+ sqr(y2-y4));//distance star2-star4
        dist6:=sqrt(sqr(x3-x4)+ sqr(y3-y4));//distance star3-star4
        //sort six distances on size in five steps
        for j:=1 to 5 do //sort on distance
        begin
          if dist6>dist5 then begin dummy:=dist5; dist5:=dist6; dist6:=dummy; end;
          if dist5>dist4 then begin dummy:=dist4; dist4:=dist5; dist5:=dummy; end;
          if dist4>dist3 then begin dummy:=dist3; dist3:=dist4; dist4:=dummy; end;
          if dist3>dist2 then begin dummy:=dist2; dist2:=dist3; dist3:=dummy; end;
          if dist2>dist1 then begin dummy:=dist1; dist1:=dist2; dist2:=dummy; end;
        end;
        quad_star_distances[0,nrquads]:=dist1;//largest distance
        quad_star_distances[1,nrquads]:=dist2/dist1;//cale relative to largest distance
        quad_star_distances[2,nrquads]:=dist3/dist1;
        quad_star_distances[3,nrquads]:=dist4/dist1;
        quad_star_distances[4,nrquads]:=dist5/dist1;
        quad_star_distances[5,nrquads]:=dist6/dist1;

        quad_star_distances[6,nrquads]:=xt;//store mean x position
        quad_star_distances[7,nrquads]:=yt;//store mean y position
        inc(nrquads);//new unique quad found
      end;
    end;
  end;
  SetLength(quad_star_distances,8,nrquads);//adapt to the number found
end;
}

procedure find_quads(starlist :star_list; out quad_star_distances :star_list);  {build quads using closest stars, revised 2022-4-10}
var
   i,j,k,nrstars,j_index1,j_index2,j_index3,nrquads,Sstart,Send,tolerance  : integer;
   distance,distance1,distance2,distance3,x1,x2,x3,x4,xt,y1,y2,y3,y4,yt,
   dist1,dist2,dist3,dist4,dist5,dist6,dummy,disty                          : double;
   identical_quad : boolean;
begin

  nrstars:=Length(starlist[0]);{number of quads will lower}

  if nrstars<4 then
  begin {not enough stars for quads}
    SetLength(quad_star_distances,8,0);
    exit;
  end;

  if nrstars>=150 then
  begin
    quickSort_starlist(starlist,0,nrstars-1); {sort in X only}
    tolerance:=round(0.5*sqrt(nrstars));{resulting tolerance band will be about twice the average star distance assuming the stars are equally distributed}
  end
  else
  tolerance:=1;{switch off pre-filtering in X}

  nrquads:=0;
  SetLength(quad_star_distances,8,nrstars);{will contain the six distances and the central position}

  j_index1:=0;{set a default value}
  j_index2:=0;
  j_index3:=0;

  for i:=0 to nrstars-1 do
  begin
    distance1:=1E99;{distance closest star}
    distance2:=1E99;{distance second closest star}
    distance3:=1E99;{distance third closest star}

    Sstart:=max(0,i-(nrstars div tolerance));
    Send:=min(nrstars-1,i+(nrstars div tolerance)); {search in a limited X band only. The stars list are sorted in X. Search speed increases with about 30%}

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
              j_index3:=j_index2;{remember the star position in the list}

              distance2:=distance1;{distance second closest star}
              j_index2:=j_index1;{remember the star position in the list}

              distance1:=distance;{distance closest star}
              j_index1:=j;{mark later as used}
            end
            else
            if distance<distance2 then
            begin
              distance3:=distance2;{distance third closest star}
              j_index3:=j_index2;{remember the star position in the list}

              distance2:=distance;{distance second closest star}
              j_index2:=j;
            end
            else
            if distance<distance3 then
            begin
              distance3:=distance;{third closest star}
              j_index3:=j;{remember the star position in the list}
            end;
          end;{not an identical star. Mod 2021-6-25}

        end; {pre-check}
      end;
    end;{j}

    x1:=starlist[0,i]; {copy first star position to the quad array}
    y1:=starlist[1,i];

    x2:=starlist[0,j_index1]; {copy the second star position to the quad array}
    y2:=starlist[1,j_index1];

    x3:=starlist[0,j_index2];
    y3:=starlist[1,j_index2];

    x4:=starlist[0,j_index3];
    y4:=starlist[1,j_index3];


    xt:=(x1+x2+x3+x4)/4; {mean x position quad}
    yt:=(y1+y2+y3+y4)/4; {mean y position quad}

    identical_quad:=false;
    for k:=0 to nrquads-1 do // check for an identical quad
    begin
      if ( (abs(xt-quad_star_distances[6,k])<1) and
           (abs(yt-quad_star_distances[7,k])<1) ) then //same center position, found identical quad already in the list
      begin
        identical_quad:=true;
        break;//stop searching
      end;
    end;

    if identical_quad=false then  {new quad found}
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
      quad_star_distances[6,nrquads]:=xt;{store mean x position}
      quad_star_distances[7,nrquads]:=yt;{store mean y position}
      inc(nrquads); {new unique quad found}
    end;
  end;{i}
  SetLength(quad_star_distances,8,nrquads);{adapt to the number found}
end;


procedure find_triples_using_quads(starlist :star_list; out quad_star_distances :star_list);  {Find triples and store as quads. Triples are extracted from quads to maximize the number of triples and cope with low amount of detectable stars. For a low star count (<30) the star patterns can be different between image and database due to small magnitude differences. V 2022-9-23}
var
   i,j,k,nrstars,j_index1,j_index2,j_index3,nrquads,Sstart,Send,tolerance, nrrealquads  : integer;
   distance,distance1,distance2,distance3,x1a,x2a,x3a,x4a,xt,y1a,y2a,y3a,y4a,yt,

   {dist4,dist5,dist6,}dummy,disty,
   dist12,dist13,dist14,dist23,dist24,dist34, quad_tolerance                                : double;

   identical_quad : boolean;
   quad_centers :   star_list;

          procedure get_triple(x1,y1,x2,y2,x3,y3,dist1,dist2,dist3: double);
          var
            j,k : integer;
          begin
            xt:=(x1+x2+x3)/3; {mean x position triple 123}
            yt:=(y1+y2+y3)/3; {mean y position triple 123}

            identical_quad:=false;
            for k:=0 to nrquads-1 do // check for an identical quad
            begin
              if ( (abs(xt-quad_star_distances[6,k])<1) and
                   (abs(yt-quad_star_distances[7,k])<1) ) then //same center position, found identical quad already in the list
              begin
                identical_quad:=true;
                break;//stop searching
              end;
            end;

            if identical_quad=false then  {new triple found}
            begin //quad-triples method. sort the distances on length. Largest first and scale the others relative to largest distance}

              {sort six distances on size in five steps}
              for j:=1 to 2 do {sort on distance}
              begin
                if dist3>dist2 then begin dummy:=dist2; dist2:=dist3; dist3:=dummy; end;
                if dist2>dist1 then begin dummy:=dist1; dist1:=dist2; dist2:=dummy; end;
              end;
              //store triple in quad record
              quad_star_distances[0,nrquads]:=dist1;{largest distance}
              quad_star_distances[1,nrquads]:=dist2/dist1;{scale relative to largest distance}
              quad_star_distances[2,nrquads]:=dist3/dist1;

              quad_star_distances[3,nrquads]:=0; //fill the rest of quad record with zeros
              quad_star_distances[4,nrquads]:=0;
              quad_star_distances[5,nrquads]:=0;
              quad_star_distances[6,nrquads]:=xt; {mean x position triple} ;{store mean x position}
              quad_star_distances[7,nrquads]:=yt;{store mean y position}
              inc(nrquads); {new unique quad found}
          end;//123
          end;

begin
  nrstars:=Length(starlist[0]);{number of quads will be equal (super rare) or lower}

  if nrstars<4 then
  begin {not enough stars for quads}
    SetLength(quad_star_distances,8,0);
    exit;
  end;

  if nrstars>=150 then
  begin
    quickSort_starlist(starlist,0,nrstars-1); {sort in X only}
    tolerance:=round(0.5*sqrt(nrstars));{resulting tolerance band will be about twice the average star distance assuming the stars are equally distributed}
  end
  else
  tolerance:=1;{switch pre-filtering in X off}

  nrquads:=0;//triples as quads
  nrrealquads:=0;//real quads
  SetLength(quad_star_distances,8,nrstars*4);{will contain the six distances and the central position of the triples stored as quads}
  SetLength(quad_centers,2,nrstars);{temporary storage for quad center to check for duplicates}

  j_index1:=0;{give it a default value}
  j_index2:=0;
  j_index3:=0;

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
              j_index3:=j_index2;{remember the star position in the list}

              distance2:=distance1;{distance second closest star}
              j_index2:=j_index1;{remember the star position in the list}

              distance1:=distance;{distance closest star}
              j_index1:=j;{mark later as used}
            end
            else
            if distance<distance2 then
            begin
              distance3:=distance2;{distance third closest star}
              j_index3:=j_index2;{remember the star position in the list}

              distance2:=distance;{distance second closest star}
              j_index2:=j;
            end
            else
            if distance<distance3 then
            begin
              distance3:=distance;{third closest star}
              j_index3:=j;{remember the star position in the list}
            end;
          end;{not an identical star. Mod 2021-6-25}

        end; {pre-check}
      end;
    end;{j}

    x1a:=starlist[0,i]; {copy first star position to the quad array}
    y1a:=starlist[1,i];
    x2a:=starlist[0,j_index1]; {copy the second star position to the quad array}
    y2a:=starlist[1,j_index1];
    x3a:=starlist[0,j_index2];
    y3a:=starlist[1,j_index2];
    x4a:=starlist[0,j_index3];
    y4a:=starlist[1,j_index3];


    xt:=(x1a+x2a+x3a+x4a)/4; {mean x position quad with stars 1234}
    yt:=(y1a+y2a+y3a+y4a)/4; {mean y position quad with stars 1234}

    identical_quad:=false;
    for k:=0 to nrrealquads-1 do // check for an identical quad
    begin
      if ( (abs(xt-quad_centers[0,k])<1) and
           (abs(yt-quad_centers[1,k])<1) ) then //same center position, found identical quad already in the list
      begin
        identical_quad:=true;
        break;//stop searching
      end;
    end;

    if identical_quad=false then  {new quad found}
    begin //quad-triples method. Split the found quad in four triples and store as quad. This will help for below 30 faint stars where due magnitude differences the database show some different stars and therefore patterns}

      quad_centers[0,nrrealquads]:=xt; //store previously found quad center
      quad_centers[1,nrrealquads]:=yt;
      inc( nrrealquads);

      dist12:=sqrt(distance1);
      dist13:=sqrt(distance2);
      dist14:=sqrt(distance3);
      dist23:=sqrt(sqr(x2a-x3a)+ sqr(y2a-y3a));{distance star2-star3}
      dist24:=sqrt(sqr(x2a-x4a)+ sqr(y2a-y4a));{distance star2-star4}
      dist34:=sqrt(sqr(x3a-x4a)+ sqr(y3a-y4a));{distance star3-star4}

      get_triple(x1a,y1a,x2a,y2a,x3a,y3a,dist12,dist23,dist13);//stars 123
      get_triple(x1a,y1a,x2a,y2a,x4a,y4a,dist12,dist24,dist14);//stars 124
      get_triple(x1a,y1a,x3a,y3a,x4a,y4a,dist13,dist34,dist14);//stars 134
      get_triple(x2a,y2a,x3a,y3a,x4a,y4a,dist23,dist34,dist24);//stars 234
    end;
  end;{i}
  quad_centers:=nil;//free mem

  SetLength(quad_star_distances,8,nrquads);{adapt to the number found}
end;


procedure find_quads_xy(starlist :star_list; out starlistquads :star_list);  {FOR DISPLAY ONLY, build quads using closest stars, revised 2020-9-28}
var
   i,j,k,nrstars_min_one,j_index1,j_index2,j_index3,nrquads         : integer;
   distance,distance1,distance2,distance3,x1,x2,x3,x4,xt,y1,y2,y3,y4,yt  : double;
   identical_quad : boolean;
begin
  nrstars_min_one:=Length(starlist[0])-1;

  if nrstars_min_one<3 then
  begin {not enough stars for quads}
    SetLength(starlistquads,10,0);
    exit;
  end;

  nrquads:=0;
  SetLength(starlistquads,10,nrstars_min_one);{number of quads will be lower}

  j_index1:=0;{give it a default value}
  j_index2:=0;
  j_index3:=0;

  for i:=0 to nrstars_min_one do
  begin
    distance1:=1E99;{distance closest star}
    distance2:=1E99;{distance second closest star}
    distance3:=1E99;{distance third closest star}

    for j:=0 to nrstars_min_one do {find closest stars}
    begin
      if j<>i{not the first star} then // note the use of continue slows down loop
      begin
        distance:=sqr(starlist[0,j]-starlist[0,i])+ sqr(starlist[1,j]-starlist[1,i]);

        if distance<distance1 then
        begin
          distance3:=distance2;{distance third closest star}
          j_index3:=j_index2;

          distance2:=distance1;{distance second closest star}
          j_index2:=j_index1;

          distance1:=distance;{distance closest star}
          j_index1:=j;{mark later as used}
        end
        else
        if distance<distance2 then
        begin
          distance3:=distance2;{distance third closest star}
          j_index3:=j_index2;

          distance2:=distance;{distance second closest star}
          j_index2:=j;
        end
        else
        if distance<distance3 then
        begin
          distance3:=distance;{third closest star}
          j_index3:=j;
        end;
      end;
    end;{j}

    x1:=starlist[0,i]; {1e star position}
    y1:=starlist[1,i];

    x2:=starlist[0,j_index1]; {2e star position}
    y2:=starlist[1,j_index1];

    x3:=starlist[0,j_index2];
    y3:=starlist[1,j_index2];

    x4:=starlist[0,j_index3];
    y4:=starlist[1,j_index3];

    xt:=(x1+x2+x3+x4)/4; {mean x position quad}
    yt:=(y1+y2+y3+y4)/4; {mean y position quad}

    identical_quad:=false;
    for k:=0 to nrquads-1 do // check for an identical quad
    begin
      if ( (abs(xt-starlistquads[8,k])<1) and
           (abs(yt-starlistquads[9,k])<1) ) then // same center position, found an identical quad already in the list
      begin
        identical_quad:=true;
        break;//stop searching
      end;
    end;

    if identical_quad=false then  {new quad found}
    begin
      starlistquads[0,nrquads]:=x1; {copy first star position to the quad array}
      starlistquads[1,nrquads]:=y1;
      starlistquads[2,nrquads]:=x2; {copy the second star position to the quad array}
      starlistquads[3,nrquads]:=y2;
      starlistquads[4,nrquads]:=x3;
      starlistquads[5,nrquads]:=y3;
      starlistquads[6,nrquads]:=x4;
      starlistquads[7,nrquads]:=y4;

      starlistquads[8,nrquads]:=xt;{store mean x position}
      starlistquads[9,nrquads]:=yt;{store mean y position}
      inc(nrquads); {new unique quad found}
    end;
  end;{i}
  SetLength(starlistquads,10,nrquads);{reduce array length to number quads one shorter since last entry is not filled}
end;


{
not used
procedure find_quads_xynew(starlist :star_list; out starlistquads :star_list);  //FOR DISPLAY ONLY, build quads using closest stars, revised 2024-12-16
var
   i,j,k,nrstars_min_one,j_index1,j_index2,j_index3,nrquads,neighbourdistance,m,n,Xposition,YpositionRef, Yposition,starnr : integer;
   distance,distance1,distance2,distance3,x1,x2,x3,x4,xt,y1,y2,y3,y4,yt  : double;
   identical_quad : boolean;

   star_list_sorted_X, star_list_sorted_Y: array of Tstar_long_record;
   index_y_stars: array of integer;
begin
  nrstars_min_one:=Length(starlist[0])-1;

  if nrstars_min_one<3 then
  begin //not enough stars for quads
    SetLength(starlistquads,10,0);
    exit;
  end;

  setlength(star_list_sorted_X,nrstars_min_one+1);
  setlength(star_list_sorted_Y,nrstars_min_one+1);
  for i:=0 to nrstars_min_one do
  begin
    star_list_sorted_X[i].nr:=i; //give it a star number
    star_list_sorted_Y[i].nr:=i; //give it a star number
    star_list_sorted_X[i].x:=starlist[0,i]; //store X
    star_list_sorted_Y[i].x:=starlist[0,i];
    star_list_sorted_X[i].y:=starlist[1,i];
    star_list_sorted_Y[i].y:=starlist[1,i];
  end;
  QuickSort_records_on_X(star_list_sorted_X, 0,nrstars_min_one);
  QuickSort_records_on_Y(star_list_sorted_Y, 0,nrstars_min_one);

  setlength(index_y_stars,nrstars_min_one+1);
  for i:=0 to nrstars_min_one do
       index_y_stars[star_list_sorted_Y[i].nr]:=i;


  //memo2_message(inttostr(nrstars_min_one+1)+' stars found.');

  neighbourdistance:=2*round(sqrt(Length(starlist[0])));


//  neighbourdistance:=strtoint(mainwindow.Edit1.caption);

  nrquads:=0;
  SetLength(starlistquads,10,nrstars_min_one);//number of quads will be lower

  j_index1:=0;//give it a default value
  j_index2:=0;
  j_index3:=0;

  for i:=0 to nrstars_min_one do
  begin
    x1:=star_list_sorted_X[i].x; //1e star position
    y1:=star_list_sorted_X[i].y;
    YpositionRef:=index_y_stars[star_list_sorted_X[i].nr];

    distance1:=1E99;//distance closest star
    distance2:=1E99;//distance second closest star
    distance3:=1E99;//distance third closest star

    //restrict search area in X and Y by a square with sides of neighbour distance. So ± neighbour stars in X and ± neighbour stars in Y
    for k:=-neighbourdistance to neighbourdistance do //use all stars close in X
    begin
      if k<>0 then //not the same star
      begin
        j:=i+k;
        if ((j>0) and (j<=nrstars_min_one)) then
        begin
          starnr:= star_list_sorted_X[j].nr;//new star with simular X value
          Yposition:=index_y_stars[starnr];//the corresponding Y position

          if  abs(YpositionRef- Yposition)<=neighbourdistance then //simular Y position
          begin
            distance:=sqr( star_list_sorted_X[j].x - x1)+ sqr( star_list_sorted_X[j].y-y1);

            if distance<distance1 then
            begin
              distance3:=distance2;//distance third closest star
              j_index3:=j_index2;

              distance2:=distance1;//distance second closest star
              j_index2:=j_index1;

              distance1:=distance;//distance closest star
              j_index1:=j;//mark later as used
            end
            else
            if distance<distance2 then
            begin
              distance3:=distance2;//distance third closest star
              j_index3:=j_index2;

              distance2:=distance;//distance second closest star
              j_index2:=j;
            end
            else
            if distance<distance3 then
            begin
              distance3:=distance;//third closest star
              j_index3:=j;
            end;
          end;
        end;
      end;
    end;

    if  distance3<1E99 then //found enough stars in the restricted area
    begin

      x2:=star_list_sorted_X[j_index1].x;//2e star position
      y2:=star_list_sorted_X[j_index1].y;//2e star position

      x3:=star_list_sorted_X[j_index2].x;//3e star position
      y3:=star_list_sorted_X[j_index2].y;//3e star position

      x4:=star_list_sorted_X[j_index3].x;//4e star position
      y4:=star_list_sorted_X[j_index3].y;//4e star position

      xt:=(x1+x2+x3+x4)/4; //mean x position quad
      yt:=(y1+y2+y3+y4)/4; //mean y position quad

      identical_quad:=false;
      for k:=0 to nrquads-1 do // check for an identical quad
      begin
        if ( (abs(xt-starlistquads[8,k])<1) and
             (abs(yt-starlistquads[9,k])<1) ) then // same center position, found an identical quad already in the list
        begin
          identical_quad:=true;
          break;//stop searching
        end;
      end;

      if identical_quad=false then  //new quad found
      begin
        starlistquads[0,nrquads]:=x1; //copy first star position to the quad array
        starlistquads[1,nrquads]:=y1;
        starlistquads[2,nrquads]:=x2; //copy the second star position to the quad array
        starlistquads[3,nrquads]:=y2;
        starlistquads[4,nrquads]:=x3;
        starlistquads[5,nrquads]:=y3;
        starlistquads[6,nrquads]:=x4;
        starlistquads[7,nrquads]:=y4;

        starlistquads[8,nrquads]:=xt;//store mean x position
        starlistquads[9,nrquads]:=yt;//store mean y position
        inc(nrquads); //new unique quad found
      end;
    end;
  end;

  SetLength(starlistquads,10,nrquads);//reduce array length to number quads one shorter since last entry is not filled
end;
}



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
    repeat          {database}                         {image }
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
      matchlist1[0,nr_references]:=matchlist2[0,k];{copy match position within tolerance}
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

      b_Xrefpositions[k]:=quad_star_distances1[6,matchlist1[0,k]]; {x position of ref quad/database}
      b_Yrefpositions[k]:=quad_star_distances1[7,matchlist1[0,k]]; {Y position of ref quad}

      {in matrix calculations, b_refpositionX[0..2,0..nr_equations-1]:=solution_vectorX[0..2] * A_XYpositions[0..2,0..nr_equations-1]}
      {                        b_refpositionY[0..2,0..nr_equations-1]:=solution_matrixY[0..2] * A_XYpositions[0..2,0..nr_equations-1]}
    end;
    result:=true;{3 or more references}



  end;
//  else
//  if solve_show_log then {global variable set in find stars}
//     memo2_message('Found matches: '+inttostr(nr_references));
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

//procedure hfd_filter(var nrstars : integer; var hfd_list,snr_list : array of double; var starlist1 : star_list);//filter out hot pixels
//var
//  median_hfd : double;
//  i,count :integer;
//begin
//  median_hfd:=smedian(hfd_list,nrstars);
//  count:=0;
//  for i:=0 to nrstars-1 do
//  begin
//    if hfd_list[i]>median_hfd*0.6 then
//    begin
//      starlist1[0,count]:=starlist1[0,i];{overwrite in the same array}
//      starlist1[1,count]:=starlist1[1,i];
//      snr_list[count]:=snr_list[i];
//      inc(count);
//    end;
//  end;
//  nrstars:=count;
//end;

procedure find_stars(img :image_array; hfd_min:double; max_stars :integer;out starlist1: star_list);{find stars and put them in a list}
var
   fitsX, fitsY,nrstars,radius,i,j,retries,m,n,xci,yci,sqr_radius,width2,height2,k : integer;
   hfd1,star_fwhm,snr,xc,yc,highest_snr,flux, detection_level : double;
   img_sa     : image_array;
   snr_list   : array of double;

// flip_vertical,flip_horizontal  : boolean;
// starX,starY :integer;
   startTick2  : qword;{for timing/speed purposes}
const
    buffersize=5000;{5000}
begin
  {for testing}
//   mainwindow.image1.Canvas.Pen.Mode := pmMerge;
//   mainwindow.image1.Canvas.Pen.width := round(1+hd.height/mainwindow.image1.height);{thickness lines}
//   mainwindow.image1.Canvas.brush.Style:=bsClear;
//   mainwindow.image1.Canvas.font.color:=$FF;
//   mainwindow.image1.Canvas.font.size:=10;
//   mainwindow.image1.Canvas.Pen.Color := $FF;
//   flip_vertical:=mainwindow.flip_vertical1.Checked;
//   flip_horizontal:=mainwindow.Flip_horizontal1.Checked;

  width2:=length(img[0,0]);{width}
  height2:=length(img[0]);{height}

  solve_show_log:=stackmenu1.solve_show_log1.Checked;{show details, global variable}
  if solve_show_log then begin memo2_message('Start finding stars');   startTick2 := gettickcount64;end;


  SetLength(starlist1,2,buffersize);{set array length}
  setlength(snr_list,buffersize);{set array length}

  setlength(img_sa,1,height2,width2);{set length of image array}

  retries:=3; {try up to four times to get enough stars from the image}
  repeat
    if retries=3 then
      begin if bck.star_level >30*bck.noise_level then detection_level:=bck.star_level  else retries:=2;{skip} end;//stars are dominant
    if retries=2 then
      begin if bck.star_level2>30*bck.noise_level then detection_level:=bck.star_level2 else retries:=1;{skip} end;//stars are dominant
    if retries=1 then
      begin detection_level:=30*bck.noise_level; end;
    if retries=0 then
      begin detection_level:= 7*bck.noise_level; end;

    highest_snr:=0;
    nrstars:=0;{set counters at zero}

    for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1  do
        img_sa[0,fitsY,fitsX]:=-1;{mark as star free area}

    for fitsY:=0 to height2-1-1 do
    begin
      for fitsX:=0 to width2-1-1  do
      begin
        if (( img_sa[0,fitsY,fitsX]<=0){star free area} and (img[0,fitsY,fitsX]- bck.backgr{cblack}>detection_level){star}) then {new star, at least 3.5 * sigma above noise level}
        begin
          HFD(img,fitsX,fitsY,14{annulus radius},99 {flux aperture restriction},0 {adu_e}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if ((hfd1<=10) and (snr>10) and (hfd1>hfd_min) {0.8 is two pixels minimum} ) then
          begin
            {for testing}
          //  if flip_vertical=false  then  starY:=round(height2-yc) else starY:=round(yc);
          //  if flip_horizontal=true then starX:=round(width2-xc)  else starX:=round(xc);
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

    if solve_show_log then memo2_message(inttostr(nrstars)+' stars found of the requested '+inttostr(max_stars)+'. Background value is '+inttostr(round(bck.backgr))+ '. Detection level used '+inttostr( round(detection_level))
                                                          +' above background. Star level is '+inttostr(round(bck.star_level))+' above background. Noise level is '+floattostrF(bck.noise_level,ffFixed,0,0));

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
  xy_sqr_ratio   :  double;
begin
  result:=false; //assume failure

  tolerance:=min(tolerance,0.008);//prevent too high tolerances

  {3 quads required giving 3 center quad references}
  if find_fit(minimum_quads, tolerance)=false then
  begin
    reset_solution_vectors(0.001);{nullify}
    exit;
  end;

  {in matrix calculations, b_refpositionX[0..2,0..nr_equations-1]:=solution_vectorX[0..2] * A_XYpositions[0..2,0..nr_equations-1]}
  {                        b_refpositionY[0..2,0..nr_equations-1]:=solution_matrixY[0..2] * A_XYpositions[0..2,0..nr_equations-1]}

  {find solution vector for X:=ax+by+c  / b_Xref:=solution[0]x+solution[1]y+solution[2]}
  if (lsq_fit( A_XYpositions {[0..2,0..nr_equations-1]},b_Xrefpositions, solution_vectorX {[0..2]}))=false then begin reset_solution_vectors(0.001);exit; end;

  {find solution vector for Y:=ax+by+c  / b_Yref:=solution[0]x+solution[1]y+solution[2]}
  if (lsq_fit( A_XYpositions {0..2,[0..nr_equations-1]},b_Yrefpositions, solution_vectorY {[0..2]}))=false then begin reset_solution_vectors(0.001);exit; end;

  xy_sqr_ratio:=(sqr(solution_vectorX[0])+sqr(solution_vectorX[1]) ) / (0.00000001+ sqr(solution_vectorY[0])+sqr(solution_vectorY[1]) ); //last check
  if ((xy_sqr_ratio<0.9) or (xy_sqr_ratio>1.1)) then {dimensions x, y are not the same, something wrong.}
  begin
    reset_solution_vectors(0.001);{nullify}
    if solve_show_log then {global variable set in find stars} memo2_message('Solution skipped on XY ratio: '+ floattostr(xy_sqr_ratio));
  end
  else
    result:=true;
end;


end.

