unit unit_star_align;
{Copyright (C) 2017-2026 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
   Classes, SysUtils,Graphics,math,
   astap_main, unit_stack;
type
   Tsolution_vector   = array[0..2] of double;

type
    Tstar_long_record = record
                   nr   : integer;//star number
                   x,y  : double;
                 end;

var
   quad_star_distances1, quad_star_distances2: Tstar_list;
   A_XYpositions                          : Tstar_list;
   b_Xrefpositions,b_Yrefpositions        : array of double;
   nr_references,nr_references2           : integer;
   solution_vectorX, solution_vectorY,solution_cblack   : Tsolution_vector ;

   Savefile: file of Tsolution_vector;{to save solution if required for second and third step stacking}
   //starlistquadsDisplay : Tstar_list;

procedure find_stars(img :Timage_array;head: theader; hfd_min:double; max_stars :integer;out starlistI: Tstar_list; out mean_hfd: double);{find stars and put them in a list}
procedure find_quads(display: boolean; nrstars_image:integer; starlist :Tstar_list; out quads :Tstar_list); //build quads using closest stars, revised 2025
function find_offset_and_rotation(minimum_quads: integer;tolerance:double) : boolean; {find difference between ref image and new image}
procedure reset_solution_vectors(factor: double); {reset the solution vectors}
procedure display_quads(starlistquads :Tstar_list);{draw quads}
function solution_str: string;
procedure QuickSort_starlist(var A: Tstar_list; iLo, iHi: Integer) ;{ Fast quick sort. Sorts elements in the array list with indices between lo and hi, sort in X only}
procedure SigmaClippedMeanFromHistogram(img :Timage_array; colour,startx,stopx,starty,stopy, upperlimit, maxIterations: integer; convergenceThreshold : double; out meanv,stdev : double);


implementation

uses  unit_annotation, unit_profiler;


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
{   In matrix calculations, b_matrix[0..nr_columns-1,0..nr_equations-1]:=Tsolution_vector[0..2] * A_XYpositions[0..nr_columns-1,0..nr_equations-1]}
{                                                                                                                              }
{   see also Montenbruck & Pfleger, Astronomy on the personal computer}
function lsq_fit( A_matrix: Tstar_list; {[, 0..3,0..nr_equations-1]} b_matrix  : array of double;{equations result, b=A*s}  out x_matrix: Tsolution_vector ): boolean;
  const tiny = 1E-10;  {accuracy}
  var i,j,k, nr_equations,nr_columns  : integer;
      p,q,h                           : double;
      temp_matrix                     : Tstar_list;

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


procedure display_quads(starlistquads :Tstar_list);{display quads in the viewer}
var
   i, nrquads,x,y, flipx,flipy: integer;
begin
  if head.naxis=0 then exit; {file loaded?}
  mainform1.image1.Canvas.Pen.Mode := pmMerge;
  mainform1.image1.Canvas.Pen.width := round(1+head.height/mainform1.image1.height);{thickness lines}
  mainform1.image1.Canvas.brush.Style:=bsClear;

  if mainform1.flip_horizontal1.Checked=true then
  begin
    flipx:=-1;
    x:=head.width;
  end
  else
  begin
    flipx:=1;
    x:=0;
  end;
  if mainform1.flip_vertical1.Checked=false then
  begin
    flipy:=-1;
    y:=head.height;
  end
  else
  begin
    flipy:=1;
    y:=0;
  end;

  nrquads:=high(starlistquads[0]);

  mainform1.image1.Canvas.Pen.mode:=pmXor;

  for i:=0 to nrquads do
  begin
    mainform1.image1.Canvas.Pen.Color :=$606060 +random($9F9F9F);
    if odd(i) then mainform1.image1.Canvas.Pen.Style := pssolid
       else  mainform1.image1.Canvas.Pen.Style := psdot;

    try
    mainform1.image1.Canvas.moveto(x+flipx*round(starlistquads[0,i]),y+flipy*round(starlistquads[1,i]));{move to star 1}
    mainform1.image1.Canvas.lineto(x+flipx*round(starlistquads[2,i]),y+flipy*round(starlistquads[3,i]));{draw line star1-star2}

    mainform1.image1.Canvas.lineto(x+flipx*round(starlistquads[4,i]),y+flipy*round(starlistquads[5,i]));{draw line star2-star3}
    mainform1.image1.Canvas.lineto(x+flipx*round(starlistquads[0,i]),y+flipy*round(starlistquads[1,i]));{draw line star3-star1}
    mainform1.image1.Canvas.lineto(x+flipx*round(starlistquads[6,i]),y+flipy*round(starlistquads[7,i]));{draw line star1-star4}
    mainform1.image1.Canvas.lineto(x+flipx*round(starlistquads[4,i]),y+flipy*round(starlistquads[5,i]));{draw line star4-star3}
    mainform1.image1.Canvas.moveto(x+flipx*round(starlistquads[6,i]),y+flipy*round(starlistquads[7,i]));{move to star4}
    mainform1.image1.Canvas.lineto(x+flipx*round(starlistquads[2,i]),y+flipy*round(starlistquads[3,i]));{draw line star4-star2}

    except
    end;
  end;
  memo2_message(inttostr( nrquads+1)+ ' quads found.');
end;


procedure QuickSort_starlist(var A: Tstar_list; iLo, iHi: Integer) ;{ Fast quick sort. Sorts elements in the array list with indices between lo and hi, sort in X only}
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


procedure QuickSort_starlist_onSNR(var A: Tstar_list; iLo, iHi: Integer) ;{ Fast quick sort. Sorts elements in the array list with indices between lo and hi, sort in SNRy}
var
  Lo, Hi : integer;
  Pivot, Tx,Ty,Tsnr: double;{ pivot, T are the same type as the elements of array }
begin
  Lo := iLo;
  Hi := iHi;
  Pivot := A[2,(Lo + Hi) div 2];//on SNR
  repeat
    while A[2,Lo] > Pivot do Inc(Lo) ; {sort on SNR DESCENDING, highest SNR first}
    while A[2,Hi] < Pivot do Dec(Hi) ;
    if Lo <= Hi then
    begin {swap}
      Tx := A[0,Lo];
      Ty := A[1,Lo];
      Tsnr := A[2,Lo];

      A[0,Lo] := A[0,Hi];
      A[1,Lo] := A[1,Hi];
      A[2,Lo] := A[2,Hi];

      A[0,Hi] := Tx;
      A[1,Hi] := Ty;
      A[2,Hi] := Tsnr;

      Inc(Lo) ;
      Dec(Hi) ;
    end;
  until Lo > Hi;
  if Hi > iLo then QuickSort_starlist_onSNR(A, iLo, Hi) ;  {executes itself recursively}
  if Lo < iHi then QuickSort_starlist_onSNR(A, Lo, iHi) ;  {executes itself recursively}
end;


procedure find_many_quads(display: boolean; starlist: Tstar_list; out quads: Tstar_list; mode: integer {use 5, 6, 7 closest stars});
var
  i, j, k, q, nrstars, nrquads, num_closest, num_quads_per_group, insert_pos: integer;
  distance, temp, xt, yt, dist1, dist2, dist3, dist4, dist5, dist6, dx, dy: double;
  identical_quad: boolean;
  closest_indices: array of integer;
  closest_distances: array of double;
  quad_indices: array[0..3] of integer;
  x1, y1, x2, y2, x3, y3, x4, y4: double;
  StarsX, StarsY: PDouble;// Direct pointers for faster array access
  QuadsX, QuadsY: PDouble;// Direct pointers for faster array access
begin
  nrstars := Length(starlist[0]);
  // Initialize direct pointers
  StarsX := @starlist[0, 0]; //this give a tiny improvement in speed
  StarsY := @starlist[1, 0];

  case mode of // Configure based on mode
    5: begin
      num_closest := 5; //collect 5 close stars
      num_quads_per_group := 5; // create 5 quads from the 5 stars
       end;
    6: begin
         num_closest := 6;//collect 6 close stars
         num_quads_per_group := 15;  // C(6,4) = 15
       end;
    7: begin
         num_closest := 7; //collect 7 close stars
         num_quads_per_group := 35;  // C(7,4) = 35
       end;
  end;

  nrquads := 0;
  SetLength(quads, 8, nrstars * num_quads_per_group);
  SetLength(closest_indices, num_closest);
  SetLength(closest_distances, num_closest);

  for i := 0 to nrstars - 1 do
  begin
    closest_distances[0] := 0; // Reference star distance is zero
    closest_indices[0] := i;// Reference star
    for j := 1 to num_closest - 1 do // Initialize closest distances to a very large value

    begin
      closest_indices[j] := -1;
      closest_distances[j] := 1E99;
    end;

    x1 := StarsX[i]; // Reference star
    y1 := StarsY[i];

    for j := 0 to nrstars - 1 do
    begin
      if i <> j then
      begin
        dx := StarsX[j] - x1;
        dy := StarsY[j] - y1;
        distance := dx * dx + dy * dy;
        if distance > 1 then
        begin
          // Fixed insertion sort: find position, then shift
          insert_pos := -1;
          for k := num_closest - 1 downto 1 do
          begin
            if distance < closest_distances[k] then
              insert_pos := k
            else
              break;
          end;
          if insert_pos >= 0 then
          begin
            for k := num_closest - 1 downto insert_pos + 1 do
            begin
              closest_distances[k] := closest_distances[k - 1];
              closest_indices[k] := closest_indices[k - 1];
            end;
            closest_distances[insert_pos] := distance;
            closest_indices[insert_pos] := j;
          end;
        end;
      end;
    end;

    if closest_indices[num_closest - 1] <> -1 then
    begin
      // Move pointer assignment outside the quad loop
      QuadsX := @quads[6, 0];
      QuadsY := @quads[7, 0];

      for q := 0 to num_quads_per_group - 1 do
      begin
        case mode of
          5: //5 quads from 5 closest stars
            case q of
                 0:  begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=2; quad_indices[3]:=3; end;//exclude 4
                 1:  begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=2; quad_indices[3]:=4; end;//exclude 3
                 2:  begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=3; quad_indices[3]:=4; end;//exclude 2
                 3:  begin quad_indices[0]:=0; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=4; end;//exclude 1
                 4:  begin quad_indices[0]:=1; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=4; end;//exclude 0
            end;//case
          6: //15 quads from 6 closest stars, all C(6,4)=15 combinations of 4 from indices 0..5
              case q of
                0:  begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=2; quad_indices[3]:=3; end;//exclude 4,5
                1:  begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=2; quad_indices[3]:=4; end;//exclude 3,5
                2:  begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=2; quad_indices[3]:=5; end;//exclude 3,4
                3:  begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=3; quad_indices[3]:=4; end;//exclude 2,5
                4:  begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=3; quad_indices[3]:=5; end;//exclude 2,4
                5:  begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=4; quad_indices[3]:=5; end;//exclude 2,3
                6:  begin quad_indices[0]:=0; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=4; end;//exclude 1,5
                7:  begin quad_indices[0]:=0; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=5; end;//exclude 1,4
                8:  begin quad_indices[0]:=0; quad_indices[1]:=2; quad_indices[2]:=4; quad_indices[3]:=5; end;//exclude 1,3
                9:  begin quad_indices[0]:=0; quad_indices[1]:=3; quad_indices[2]:=4; quad_indices[3]:=5; end;//exclude 1,2
                10: begin quad_indices[0]:=1; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=4; end;//exclude 0,5
                11: begin quad_indices[0]:=1; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=5; end;//exclude 0,4
                12: begin quad_indices[0]:=1; quad_indices[1]:=2; quad_indices[2]:=4; quad_indices[3]:=5; end;//exclude 0,3
                13: begin quad_indices[0]:=1; quad_indices[1]:=3; quad_indices[2]:=4; quad_indices[3]:=5; end;//exclude 0,2
                14: begin quad_indices[0]:=2; quad_indices[1]:=3; quad_indices[2]:=4; quad_indices[3]:=5; end;//exclude 0,1
              end;
          7: // //35 quads from 7 closest stars, C(7,4)=35 combinations of 4 from indices 0..6
            case q of
               0: begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=2; quad_indices[3]:=3; end; //exclude 4,5,6
               1: begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=2; quad_indices[3]:=4; end; //exclude 3,5,6
               2: begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=2; quad_indices[3]:=5; end; //exclude 3,4,6
               3: begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=2; quad_indices[3]:=6; end; //exclude 3,4,5
               4: begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=3; quad_indices[3]:=4; end; //exclude 2,5,6
               5: begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=3; quad_indices[3]:=5; end; //exclude 2,4,6
               6: begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=3; quad_indices[3]:=6; end; //exclude 2,4,5
               7: begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=4; quad_indices[3]:=5; end; //exclude 2,3,6
               8: begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=4; quad_indices[3]:=6; end; //exclude 2,3,5
               9: begin quad_indices[0]:=0; quad_indices[1]:=1; quad_indices[2]:=5; quad_indices[3]:=6; end; //exclude 2,3,4
              10: begin quad_indices[0]:=0; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=4; end; //exclude 1,5,6
              11: begin quad_indices[0]:=0; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=5; end; //exclude 1,4,6
              12: begin quad_indices[0]:=0; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=6; end; //exclude 1,4,5
              13: begin quad_indices[0]:=0; quad_indices[1]:=2; quad_indices[2]:=4; quad_indices[3]:=5; end; //exclude 1,3,6
              14: begin quad_indices[0]:=0; quad_indices[1]:=2; quad_indices[2]:=4; quad_indices[3]:=6; end; //exclude 1,3,5
              15: begin quad_indices[0]:=0; quad_indices[1]:=2; quad_indices[2]:=5; quad_indices[3]:=6; end; //exclude 1,3,4
              16: begin quad_indices[0]:=0; quad_indices[1]:=3; quad_indices[2]:=4; quad_indices[3]:=5; end; //exclude 1,2,6
              17: begin quad_indices[0]:=0; quad_indices[1]:=3; quad_indices[2]:=4; quad_indices[3]:=6; end; //exclude 1,2,5
              18: begin quad_indices[0]:=0; quad_indices[1]:=3; quad_indices[2]:=5; quad_indices[3]:=6; end; //exclude 1,2,4
              19: begin quad_indices[0]:=0; quad_indices[1]:=4; quad_indices[2]:=5; quad_indices[3]:=6; end; //exclude 1,2,3
              20: begin quad_indices[0]:=1; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=4; end; //exclude 0,5,6
              21: begin quad_indices[0]:=1; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=5; end; //exclude 0,4,6
              22: begin quad_indices[0]:=1; quad_indices[1]:=2; quad_indices[2]:=3; quad_indices[3]:=6; end; //exclude 0,4,5
              23: begin quad_indices[0]:=1; quad_indices[1]:=2; quad_indices[2]:=4; quad_indices[3]:=5; end; //exclude 0,3,6
              24: begin quad_indices[0]:=1; quad_indices[1]:=2; quad_indices[2]:=4; quad_indices[3]:=6; end; //exclude 0,3,5
              25: begin quad_indices[0]:=1; quad_indices[1]:=2; quad_indices[2]:=5; quad_indices[3]:=6; end; //exclude 0,3,4
              26: begin quad_indices[0]:=1; quad_indices[1]:=3; quad_indices[2]:=4; quad_indices[3]:=5; end; //exclude 0,2,6
              27: begin quad_indices[0]:=1; quad_indices[1]:=3; quad_indices[2]:=4; quad_indices[3]:=6; end; //exclude 0,2,5
              28: begin quad_indices[0]:=1; quad_indices[1]:=3; quad_indices[2]:=5; quad_indices[3]:=6; end; //exclude 0,2,4
              29: begin quad_indices[0]:=1; quad_indices[1]:=4; quad_indices[2]:=5; quad_indices[3]:=6; end; //exclude 0,2,3
              30: begin quad_indices[0]:=2; quad_indices[1]:=3; quad_indices[2]:=4; quad_indices[3]:=5; end; //exclude 0,1,6
              31: begin quad_indices[0]:=2; quad_indices[1]:=3; quad_indices[2]:=4; quad_indices[3]:=6; end; //exclude 0,1,5
              32: begin quad_indices[0]:=2; quad_indices[1]:=3; quad_indices[2]:=5; quad_indices[3]:=6; end; //exclude 0,1,4
              33: begin quad_indices[0]:=2; quad_indices[1]:=4; quad_indices[2]:=5; quad_indices[3]:=6; end; //exclude 0,1,3
              34: begin quad_indices[0]:=3; quad_indices[1]:=4; quad_indices[2]:=5; quad_indices[3]:=6; end; //exclude 0,1,2
            end;
        end; // case mode

        // Get star positions for the quad
        x1 := StarsX[closest_indices[quad_indices[0]]];
        y1 := StarsY[closest_indices[quad_indices[0]]];
        x2 := StarsX[closest_indices[quad_indices[1]]];
        y2 := StarsY[closest_indices[quad_indices[1]]];
        x3 := StarsX[closest_indices[quad_indices[2]]];
        y3 := StarsY[closest_indices[quad_indices[2]]];
        x4 := StarsX[closest_indices[quad_indices[3]]];
        y4 := StarsY[closest_indices[quad_indices[3]]];

        // Calculate quad center
        xt := (x1 + x2 + x3 + x4) * 0.25;
        yt := (y1 + y2 + y3 + y4) * 0.25;

        // Check for duplicates
        identical_quad := false;
        for k := 0 to nrquads - 1 do
        begin
          if (abs(xt - QuadsX[k]) < 1) and (abs(yt - QuadsY[k]) < 6) then
          begin
            identical_quad := true;
            break;
          end;
        end;

        if not identical_quad then
        begin // Calculate pairwise distances
          dx := x1-x2; dy := y1-y2; dist1 := sqrt(dx*dx + dy*dy);
          dx := x1-x3; dy := y1-y3; dist2 := sqrt(dx*dx + dy*dy);
          dx := x1-x4; dy := y1-y4; dist3 := sqrt(dx*dx + dy*dy);
          dx := x2-x3; dy := y2-y3; dist4 := sqrt(dx*dx + dy*dy);
          dx := x2-x4; dy := y2-y4; dist5 := sqrt(dx*dx + dy*dy);
          dx := x3-x4; dy := y3-y4; dist6 := sqrt(dx*dx + dy*dy);

          // Optimized bubble sort for 6 elements
          if dist2 > dist1 then begin temp:=dist1; dist1:=dist2; dist2:=temp; end;
          if dist3 > dist2 then begin temp:=dist2; dist2:=dist3; dist3:=temp; end;
          if dist4 > dist3 then begin temp:=dist3; dist3:=dist4; dist4:=temp; end;
          if dist5 > dist4 then begin temp:=dist4; dist4:=dist5; dist5:=temp; end;
          if dist6 > dist5 then begin temp:=dist5; dist5:=dist6; dist6:=temp; end;
          if dist2 > dist1 then begin temp:=dist1; dist1:=dist2; dist2:=temp; end;
          if dist3 > dist2 then begin temp:=dist2; dist2:=dist3; dist3:=temp; end;
          if dist4 > dist3 then begin temp:=dist3; dist3:=dist4; dist4:=temp; end;
          if dist5 > dist4 then begin temp:=dist4; dist4:=dist5; dist5:=temp; end;
          if dist2 > dist1 then begin temp:=dist1; dist1:=dist2; dist2:=temp; end;
          if dist3 > dist2 then begin temp:=dist2; dist2:=dist3; dist3:=temp; end;
          if dist4 > dist3 then begin temp:=dist3; dist3:=dist4; dist4:=temp; end;
          if dist2 > dist1 then begin temp:=dist1; dist1:=dist2; dist2:=temp; end;
          if dist3 > dist2 then begin temp:=dist2; dist2:=dist3; dist3:=temp; end;
          if dist2 > dist1 then begin temp:=dist1; dist1:=dist2; dist2:=temp; end;
          //end optimized bubble sort

          // Store the quad
          if display = false then
          begin
            quads[0, nrquads] := dist1;
            quads[1, nrquads] := dist2 / dist1;
            quads[2, nrquads] := dist3 / dist1;
            quads[3, nrquads] := dist4 / dist1;
            quads[4, nrquads] := dist5 / dist1;
            quads[5, nrquads] := dist6 / dist1;
            quads[6, nrquads] := xt;
            quads[7, nrquads] := yt;
          end
          else
          begin //for display purposes
            quads[0, nrquads] := x1; {copy first star position to the quad array}
            quads[1, nrquads] := y1;
            quads[2, nrquads] := x2; {copy the second star position to the quad array}
            quads[3, nrquads] := y2;
            quads[4, nrquads] := x3;
            quads[5, nrquads] := y3;
            quads[6, nrquads] := x4;
            quads[7, nrquads] := y4;
          end;
          inc(nrquads);
        end;
      end; // quad loop
    end; // enough stars
  end; // star loop

  SetLength(quads, 8, nrquads);
end;


procedure find_quads(display: boolean;nrstars_image:integer; starlist :Tstar_list; out quads :Tstar_list); //build quads using closest stars, revised 2026
const
  bucket_capacity = 5; // Max quads per bucket, increase to 20 if overflows occur
  GRID_INV = 0.2; // Pre-calculated inverse of grid_size (1.0 / 5.0)
var
   i, j, k, nrstars, j_index1, j_index2, j_index3, nrquads, Sstart, Send, bandw,
   hash_x, hash_y, idx, hash_table_len                : integer;
   distance, distance1, distance2, distance3, x1, x2, x3, x4, xt, y1, y2, y3, y4, yt,
   dist1, dist2, dist3, dist4, dist5, dist6, temp, disty, dx          : double;
   identical_quad: boolean;
   hash_table: array of array of integer; // Fixed-size buckets
   bucket_counts: array of integer; // Number of quads in each bucket
   max_bucket_size: integer; // Debug: track largest bucket
   overflow_count: integer; // Debug: count bucket overflows
   StarsX, StarsY: PDouble;
   QuadsX, QuadsY: PDouble;
begin
  nrstars := Length(starlist[0]); //number of quads will lower

  if ((nrstars_image<15) and (nrstars>6)) then //base the quad groups size selection on the number of stars in the image and not on the number of database stars since the database field could be larger
  begin
    find_many_quads(display,starlist, {out} quads,7 {group size});//Find fifteen times more quads by using closest groups of six stars.
    exit;
  end
  else
  if ((nrstars_image<30) and (nrstars>5)) then //base the quad groups size selection on the number of stars in the image and not on the number of database stars since the database field could be larger
  begin
    find_many_quads(display,starlist, {out} quads,6 {group size});//Find fifteen times more quads by using closest groups of six stars.
    exit;
  end
  else
  if ((nrstars_image<60) and (nrstars>4)) then
  begin
    find_many_quads(display,starlist, {out} quads,5 {group size});//Find five times more quads by using closest groups of five stars.
    exit;
  end;

  if nrstars < 4 then
  begin {not enough stars for quads}
    SetLength(quads, 8, 0);
    exit;
  end;

  // Array access:     starlist[0, j]  →  Calculate: base + 0*row_stride + j*element_size
  // Pointer access:   StarsX[j]       →  Calculate: pointer + j*element_size. About 10% faster
  // Initialize direct pointers
  StarsX := @starlist[0, 0]; // this makes the procedure only about 0.25% faster for 500 stars
  StarsY := @starlist[1, 0];

  if nrstars >= 150 then
  begin
    quickSort_starlist(starlist, 0, nrstars - 1); //sort in X only
    bandw := round(2 * sqrt(nrstars)); //resulting tolerance band will be about twice the average star distance assuming the stars are equally distributed
  end
  else
    bandw := nrstars; //switch off pre-filtering in X

  // Initialize hash table and debug counters
  hash_table_len := nrstars * 2; // Cache hash_table length
  SetLength(hash_table, hash_table_len, bucket_capacity); // 1000 buckets for ~500 stars. In hash table design, the number of buckets is often set to 1–2 times the expected number of entries to achieve a load factor (entries ÷ buckets) of 0.5–1.0, minimizing collisions. Here, with ~350–400 quads, nrstars * 2 = 1000 gives a load factor of ~0.4, which is ideal for performance.
  SetLength(bucket_counts, hash_table_len);
  for i := 0 to hash_table_len - 1 do  bucket_counts[i] := 0; // Initialize counts
  max_bucket_size := 0;
  overflow_count := 0;

  nrquads := 0;
  SetLength(quads, 8, nrstars); //will contain the six distances and the central position or if display is true then eight x,y positions and central position

  j_index1 := 0; //set a default value
  j_index2 := 0;
  j_index3 := 0;

  for i := 0 to nrstars - 1 do
  begin
    distance1 := 1E99; //distance closest star
    distance2 := 1E99; //distance second closest star
    distance3 := 1E99; //distance third closest star

    Sstart := max(0, i - bandw);
    Send := min(nrstars - 1, i + bandw); //search in a limited X band only. The stars list are sorted in X. Search speed increases with about 30%

    x1 := StarsX[i]; // first star position quad array
    y1 := StarsY[i];

    for j := Sstart to Send do //find closest stars
    begin
      if j<>i then //do not check the star with itself
      begin
        disty := sqr(StarsY[j] - y1);
        if disty < distance3 then //pre-check to increase processing speed with a small amount
        begin
          distance := sqr(StarsX[j] - x1) + disty; {square distances are used}
          if distance > 1 then //not an identical star. Mod 2021-6-25
          begin
            if distance < distance1 then
            begin
              distance3 := distance2;//{distance third closest star
              j_index3 := j_index2; //remember the star position in the list

              distance2 := distance1; //distance second closest star
              j_index2 := j_index1; //remember the star position in the list

              distance1 := distance; //distance closest star
              j_index1 := j; //mark later as used
            end
            else if distance < distance2 then
            begin
              distance3 := distance2; //distance third closest star
              j_index3 := j_index2; //remember the star position in the list

              distance2 := distance; //{distance second closest star}
              j_index2 := j;
            end
            else if distance < distance3 then
            begin
              distance3 := distance; //third closest star
              j_index3 := j; //remember the star position in the list
            end;
          end;//{not an identical star. Mod 2021-6-25
        end; //pre-check

      end;//j<>i
    end;

    if distance3 < 1E99 then //found 4 stars in the restricted area
    begin
      x2 := StarsX[j_index1]; // second star position quad array
      y2 := StarsY[j_index1];

      x3 := StarsX[j_index2];
      y3 := StarsY[j_index2];

      x4 := StarsX[j_index3];
      y4 := StarsY[j_index3];

      xt := (x1 + x2 + x3 + x4) * 0.25; //mean x position quad. Multiply should be a little faster then divide but no practical difference
      yt := (y1 + y2 + y3 + y4) * 0.25; //mean y position quad

      // Check for duplicate quad using hash table
      identical_quad := False;
      hash_x := Trunc(xt * GRID_INV); // Multiply instead of divide
      hash_y := Trunc(yt * GRID_INV);
      idx := Abs(hash_x * 31 + hash_y) mod hash_table_len; // Use cached length

      QuadsX := @quads[6, 0];
      QuadsY := @quads[7, 0];

      for k := 0 to bucket_counts[idx] - 1 do //check only quad_distances which have the same idx
      begin
        j := hash_table[idx, k]; // Use j as temp variable for quad index
        if (abs(xt - QuadsX[j]) < 1) and
           (abs(yt - QuadsY[j]) < 1) then
        begin
          identical_quad := True;
          break;
        end;
      end;
      // end Check for duplicate quad using hash table

      if identical_quad = false then {new quad found}
      begin
        dist1 := sqrt(distance1); //distance star1-star2, use previous value already calculated
        dist2 := sqrt(distance2); //distance star1-star3
        dist3 := sqrt(distance3); //distance star1-star4

        // OPTIMIZATION: Calculate dx, dy once and reuse
        dx := x2 - x3; disty := y2 - y3;
        dist4 := sqrt(dx * dx + disty * disty); //distance star2-star3
        dx := x2 - x4; disty := y2 - y4;
        dist5 := sqrt(dx * dx + disty * disty); //distance star2-star4
        dx := x3 - x4; disty := y3 - y4;
        dist6 := sqrt(dx * dx + disty * disty); //distance star3-star4

        // Optimized bubble sort for 6 elements (5 passes max)
        if dist2 > dist1 then begin temp := dist1; dist1 := dist2; dist2 := temp; end;
        if dist3 > dist2 then begin temp := dist2; dist2 := dist3; dist3 := temp; end;
        if dist4 > dist3 then begin temp := dist3; dist3 := dist4; dist4 := temp; end;
        if dist5 > dist4 then begin temp := dist4; dist4 := dist5; dist5 := temp; end;
        if dist6 > dist5 then begin temp := dist5; dist5 := dist6; dist6 := temp; end;

        if dist2 > dist1 then begin temp := dist1; dist1 := dist2; dist2 := temp; end;
        if dist3 > dist2 then begin temp := dist2; dist2 := dist3; dist3 := temp; end;
        if dist4 > dist3 then begin temp := dist3; dist3 := dist4; dist4 := temp; end;
        if dist5 > dist4 then begin temp := dist4; dist4 := dist5; dist5 := temp; end;

        if dist2 > dist1 then begin temp := dist1; dist1 := dist2; dist2 := temp; end;
        if dist3 > dist2 then begin temp := dist2; dist2 := dist3; dist3 := temp; end;
        if dist4 > dist3 then begin temp := dist3; dist3 := dist4; dist4 := temp; end;

        if dist2 > dist1 then begin temp := dist1; dist1 := dist2; dist2 := temp; end;
        if dist3 > dist2 then begin temp := dist2; dist2 := dist3; dist3 := temp; end;

        if dist2 > dist1 then begin temp := dist1; dist1 := dist2; dist2 := temp; end;
        //end optimized bubble sort

        if display = false then
        begin
          quads[0, nrquads] := dist1; //largest distance
          quads[1, nrquads] := dist2 / dist1; //scale relative to largest distance
          quads[2, nrquads] := dist3 / dist1;
          quads[3, nrquads] := dist4 / dist1;
          quads[4, nrquads] := dist5 / dist1;
          quads[5, nrquads] := dist6 / dist1;
          quads[6, nrquads] := xt; //store mean x position
          quads[7, nrquads] := yt; //store mean y position
        end
        else
        begin //for display only
          quads[0, nrquads] := x1; //copy first star position to the quad array
          quads[1, nrquads] := y1;
          quads[2, nrquads] := x2; //copy the second star position to the quad array
          quads[3, nrquads] := y2;
          quads[4, nrquads] := x3;
          quads[5, nrquads] := y3;
          quads[6, nrquads] := x4;
          quads[7, nrquads] := y4;
        end;

        //add_to_hash, Hash table makes the routine 25% faster
        hash_x := Trunc(xt * GRID_INV);
        hash_y := Trunc(yt * GRID_INV);
        idx := Abs(hash_x * 31 + hash_y) mod hash_table_len;

        if bucket_counts[idx] >= bucket_capacity then //pre check to speed up
          if bucket_counts[idx] >= Length(hash_table[idx]) then //will overflow
          begin
            SetLength(hash_table[idx], Length(hash_table[idx]) + bucket_capacity); //increase size with bucket capacity. Should not happen. Different dimensions are implemented as arrays, and can each have their own size! https://wiki.freepascal.org/Dynamic_array
            Inc(overflow_count); // Track overflows for debugging
          end;
        hash_table[idx, bucket_counts[idx]] := nrquads;
        Inc(bucket_counts[idx]);
        if bucket_counts[idx] > max_bucket_size then max_bucket_size := bucket_counts[idx]; // record maximum bucket size
        //end of add to hash

        inc(nrquads); {new unique quad found}
      end;
    end; //found 4 stars
  end; {i}
  SetLength(quads, 8, nrquads); //adapt to the number found


  if solve_show_log then
  begin
    memo2_message('Find Quads, max bucket size: '+inttostr(max_bucket_size)+', bucket overflows: '+inttostr(overflow_count) );
  end;
  if overflow_count>0 then
    memo2_message('Warning, bucket size increased!');

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
  setlength(matchlist2,2,max(nrquads1,nrquads2));

  nr_references2:=0;
  i:=0;
  repeat
    j:=0;
    repeat //       ==database==                ==image==
      if abs(quad_star_distances1[1,i] - quad_star_distances2[1,j])<=quad_tolerance then //all length are scaled to the longest length so scale independent
      if abs(quad_star_distances1[2,i] - quad_star_distances2[2,j])<=quad_tolerance then
      if abs(quad_star_distances1[3,i] - quad_star_distances2[3,j])<=quad_tolerance then
      if abs(quad_star_distances1[4,i] - quad_star_distances2[4,j])<=quad_tolerance then
      if abs(quad_star_distances1[5,i] - quad_star_distances2[5,j])<=quad_tolerance then
      begin
        matchlist2[0,nr_references2]:=i;//store match position
        matchlist2[1,nr_references2]:=j;
        inc(nr_references2);
        if nr_references2>=length(matchlist2[0]) then setlength(matchlist2,2,nr_references2+1000);//get more space

        {memo2_message(','+
                      floattostr(quad_star_distances1[0,i])+','+
                      floattostr(quad_star_distances1[1,i])+','+
                      floattostr(quad_star_distances1[2,i])+','+
                      floattostr(quad_star_distances1[3,i])+','+
                      floattostr(quad_star_distances1[4,i])+','+
                      floattostr(quad_star_distances1[5,i])
                      +',tolerances,'+
                      floattostr(quad_star_distances1[1,i] - quad_star_distances2[1,j])+','+
                      floattostr(quad_star_distances1[2,i] - quad_star_distances2[2,j])+','+
                      floattostr(quad_star_distances1[3,i] - quad_star_distances2[3,j])+','+
                      floattostr(quad_star_distances1[4,i] - quad_star_distances2[4,j])+','+
                      floattostr(quad_star_distances1[5,i] - quad_star_distances2[5,j]));
          }
      end;
      inc(j);
    until j>=nrquads2;//j loop
    inc(i);
  until i>=nrquads1;//i loop

  if solve_show_log then memo2_message('Found '+inttostr( nr_references2)+ ' references');

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
  setlength(matchlist1,2,nr_references2);
  for k:=0 to nr_references2-1 do {throw outliers out}
  begin
    if  abs(median_ratio-ratios[k])<=quad_tolerance*median_ratio then
    begin
      matchlist1[0,nr_references]:=matchlist2[0,k];{copy match position within tolerance}
      matchlist1[1,nr_references]:=matchlist2[1,k];
      inc(nr_references);
    end
    else
    if solve_show_log then
       memo2_message('quad outlier removed due to abnormal size: '+floattostr6(100*ratios[k]/median_ratio)+'%');
  end;

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
end;


function find_fit_using_hash(minimum_count: integer; quad_tolerance: double): boolean;
const
  NEIGHBOR_BINS = 1; // Check ±1 bin to cover quad_tolerance
  MAX_QUADS_PER_BIN = 15; // Preallocate bins for max_hash_count ≈ 13–15
var
  nrquads1, nrquads2, i, j, k, bin, delta_bin, adjusted_bin, hash_bins: integer;
  median_ratio: double;
  matchlist1, matchlist2: array of array of integer;
  ratios: array of double;
  hash_table1, hash_table2: array of array of integer; // Hash tables for quads
  hash_counts1, hash_counts2: array of integer; // Counts per bin
  max_hash_count: integer; // Debug: track largest bin size

  // Local cache variables for inner loop
  idx1, idx2: integer;
  q1_d1, q1_d2, q1_d3, q1_d4, q1_d5: double;

  // Pre-calculated inverse for division
  ToleranceInv: double;

begin
  result := false; {assume failure}
  nrquads1 := Length(quad_star_distances1[0]);
  nrquads2 := Length(quad_star_distances2[0]);

  if (nrquads1 < minimum_count) or (nrquads2 < minimum_count) then
  begin
    nr_references := 0;
    exit;
  end;

  // Pre-calculate inverse for faster bin calculation
  ToleranceInv := 1.0 / quad_tolerance;

  {Set HASH_BINS to twice the maximum number of quads}
  hash_bins := 2 * Max(nrquads1, nrquads2);

  {Initialize hash tables with preallocated bins}
  SetLength(hash_table1, hash_bins, MAX_QUADS_PER_BIN);
  SetLength(hash_table2, hash_bins, MAX_QUADS_PER_BIN);
  SetLength(hash_counts1, hash_bins); //In case the length is set to a larger length than the current one, the new elements are zeroed out for a dynamic array. See https://www.freepascal.org/docs-html/rtl/system/setlength.html.
  SetLength(hash_counts2, hash_bins); //In case the length is set to a larger length than the current one, the new elements are zeroed out for a dynamic array. See https://www.freepascal.org/docs-html/rtl/system/setlength.html.
  max_hash_count := 0;

  {Populate hash tables}
  for i := 0 to nrquads1 - 1 do
  begin
    bin := Trunc(quad_star_distances1[1, i] * ToleranceInv) mod hash_bins;
    if bin < 0 then bin := bin + hash_bins; // Handle negative values

    if (hash_counts1[bin] >= MAX_QUADS_PER_BIN) and
       (hash_counts1[bin] >= Length(hash_table1[bin])) then
      SetLength(hash_table1[bin], Length(hash_table1[bin]) + MAX_QUADS_PER_BIN);
    hash_table1[bin, hash_counts1[bin]] := i;
    Inc(hash_counts1[bin]);
    if hash_counts1[bin] > max_hash_count then
      max_hash_count := hash_counts1[bin];
  end;

  for j := 0 to nrquads2 - 1 do
  begin
    bin := Trunc(quad_star_distances2[1, j] * ToleranceInv) mod hash_bins;
    if bin < 0 then bin := bin + hash_bins;

    if (hash_counts2[bin] >= MAX_QUADS_PER_BIN) and
       (hash_counts2[bin] >= Length(hash_table2[bin])) then
      SetLength(hash_table2[bin], Length(hash_table2[bin]) + MAX_QUADS_PER_BIN);
    hash_table2[bin, hash_counts2[bin]] := j;
    Inc(hash_counts2[bin]);
    if hash_counts2[bin] > max_hash_count then
      max_hash_count := hash_counts2[bin];
  end;

  {Preallocate matchlist - estimate ~10% of quads will match}
  SetLength(matchlist2, 2, max(nrquads1, nrquads2)); {Preallocate for max possible matches}
  nr_references2 := 0;

  {Find matches using hash tables, checking neighboring bins}
  for bin := 0 to hash_bins - 1 do
  begin
    if hash_counts1[bin] = 0 then continue; {Skip empty bins}

    for delta_bin := -NEIGHBOR_BINS to NEIGHBOR_BINS do
    begin
      adjusted_bin := bin + delta_bin;
      // Faster modulo using if for small adjustments
      if adjusted_bin < 0 then
        adjusted_bin := adjusted_bin + hash_bins
      else if adjusted_bin >= hash_bins then
        adjusted_bin := adjusted_bin - hash_bins;

      if hash_counts2[adjusted_bin] = 0 then continue; {Skip empty bins}

      for i := 0 to hash_counts1[bin] - 1 do
      begin
        idx1 := hash_table1[bin, i];
        // Cache quad1 values to avoid repeated array access
        q1_d1 := quad_star_distances1[1, idx1];
        q1_d2 := quad_star_distances1[2, idx1];
        q1_d3 := quad_star_distances1[3, idx1];
        q1_d4 := quad_star_distances1[4, idx1];
        q1_d5 := quad_star_distances1[5, idx1];

        for j := 0 to hash_counts2[adjusted_bin] - 1 do
        begin
          idx2 := hash_table2[adjusted_bin, j];

          // Optimized tolerance checks with early exit
          if abs(q1_d1 - quad_star_distances2[1, idx2]) > quad_tolerance then continue;
          if abs(q1_d2 - quad_star_distances2[2, idx2]) > quad_tolerance then continue;
          if abs(q1_d3 - quad_star_distances2[3, idx2]) > quad_tolerance then continue;
          if abs(q1_d4 - quad_star_distances2[4, idx2]) > quad_tolerance then continue;
          if abs(q1_d5 - quad_star_distances2[5, idx2]) > quad_tolerance then continue;

          // Match found
          matchlist2[0, nr_references2] := idx1;
          matchlist2[1, nr_references2] := idx2;
          Inc(nr_references2);
          if nr_references2 >= Length(matchlist2[0]) then {Fallback resizing if needed}
            SetLength(matchlist2, 2, nr_references2 + 1000); {Fallback resizing}

          {memo2_message(','+
                        floattostr(quad_star_distances1[0,hash_table1[bin,i]])+','+
                        floattostr(quad_star_distances1[1,hash_table1[bin,i]])+','+
                        floattostr(quad_star_distances1[2,hash_table1[bin,i]])+','+
                        floattostr(quad_star_distances1[3,hash_table1[bin,i]])+','+
                        floattostr(quad_star_distances1[4,hash_table1[bin,i]])+','+
                        floattostr(quad_star_distances1[5,hash_table1[bin,i]])
                        +',tolerances,'+
                        floattostr(quad_star_distances1[1,hash_table1[bin,i]] - quad_star_distances2[1,hash_table2[adjusted_bin,j]])+','+
                        floattostr(quad_star_distances1[2,hash_table1[bin,i]] - quad_star_distances2[2,hash_table2[adjusted_bin,j]])+','+
                        floattostr(quad_star_distances1[3,hash_table1[bin,i]] - quad_star_distances2[3,hash_table2[adjusted_bin,j]])+','+
                        floattostr(quad_star_distances1[4,hash_table1[bin,i]] - quad_star_distances2[4,hash_table2[adjusted_bin,j]])+','+
                        floattostr(quad_star_distances1[5,hash_table1[bin,i]] - quad_star_distances2[5,hash_table2[adjusted_bin,j]]));
           }



        end;
      end;
    end;
  end;

  if solve_show_log then
    memo2_message('Found ' + IntToStr(nr_references2) + ' references, max hash bin size: ' + IntToStr(max_hash_count));

  if nr_references2 < minimum_count then
  begin
    nr_references := 0;
    exit;
  end;

  {Calculate median of the longest length ratio for matching quads}
  SetLength(ratios, nr_references2);
  for k := 0 to nr_references2 - 1 do
    ratios[k] := quad_star_distances1[0, matchlist2[0, k]] / quad_star_distances2[0, matchlist2[1, k]];

  median_ratio := smedian(ratios, nr_references2);

  {Calculate median absolute deviation and filter matches}
  nr_references := 0;
  SetLength(matchlist1, 2, nr_references2);
  for k := 0 to nr_references2 - 1 do
  begin
    if abs(median_ratio - ratios[k]) <= quad_tolerance * median_ratio then
    begin
      matchlist1[0, nr_references] := matchlist2[0, k];
      matchlist1[1, nr_references] := matchlist2[1, k];
      Inc(nr_references);
    end
    else if solve_show_log then
      memo2_message('Quad outlier removed due to abnormal size: ' + FloatToStrF(100 * ratios[k] / median_ratio, ffFixed, 6, 2) + '%');
  end;

  {Outliers in largest length removed}
  if nr_references >= 3 then
  begin
    SetLength(A_XYpositions, 3, nr_references);
    SetLength(b_Xrefpositions, nr_references);
    SetLength(b_Yrefpositions, nr_references);

    for k := 0 to nr_references - 1 do
    begin
      A_XYpositions[0, k] := quad_star_distances2[6, matchlist1[1, k]];
      A_XYpositions[1, k] := quad_star_distances2[7, matchlist1[1, k]];
      A_XYpositions[2, k] := 1;

      b_Xrefpositions[k] := quad_star_distances1[6, matchlist1[0, k]];
      b_Yrefpositions[k] := quad_star_distances1[7, matchlist1[0, k]];
    end;
    result := true;
  end;
end;


procedure get_brightest_stars(nr_stars_required: integer;{500} highest_snr: double; var starlistB : Tstar_list);{ Extract the brightest star from a star list}
const
   range=199;
var
  snr_histogram : array [0..range] of integer;
  i,count,nrstars, snr_scaled: integer;
  snr_required,sqrtRange,overshoot_correction : double;
begin
  for i:=0 to high(snr_histogram) do snr_histogram[i]:=0; //clear snr histogram

  sqrtRange:= sqrt(highest_snr);
  for i:=0 to high(starlistB[0]) do
  begin
    snr_scaled:=trunc(sqrt(starlistB[2,i])*(range)/sqrtRange);//stretch the lower part with many similar stars by applying sqrt. This much faster then using the ln() function
    snr_histogram[snr_scaled]:=snr_histogram[snr_scaled]+1;//count how often this snr value is measured
  end;

  count:=0;
  i:=range;
  repeat
    dec(i);
    count:=count+snr_histogram[i];
  until ((i<=0) or (count>=nr_stars_required));

  if snr_histogram[i]<>0 then overshoot_correction:=(count-nr_stars_required)/snr_histogram[i] else overshoot_correction:=0; //linear overshoot correction
  snr_required:=sqr(sqrtRange*(i+overshoot_correction)/range);  // Convert back from sqrt space

  count:=0;
  nrstars:=length(starlistB[0]);
  for i:=0 to nrstars-1 do
    if starlistB[2,i]>=snr_required then //preserve brightest stars
    begin
      starlistB[0,count]:=starlistB[0,i];//overwrite in the same array
      starlistB[1,count]:=starlistB[1,i];
      starlistB[2,count]:=starlistB[2,i];//copy SNR
   //  For testing:
   //  memo2_message(#9+floattostr(starlistB[2,i])+#9+floattostr(starlist2[0,count])+ #9 +floattostr(starlist2[1,count]));
   //  mainform1.image1.Canvas.Pen.Mode := pmMerge;
   //  mainform1.image1.Canvas.Pen.width := round(1+head.height/mainform1.image1.height);{thickness lines}
   //  mainform1.image1.Canvas.brush.Style:=bsClear;
   //  mainform1.image1.Canvas.Pen.Color := clred;
   //  mainform1.image1.Canvas.Rectangle(round(starlistB[0,i])-15,head.height-round(starlistB[1,i])-15, round(starlistB[0,i])+15, head.height-round(starlistB[1,i])+15);{indicate hfd with rectangle}
       inc(count);
     end;
  setlength(starlistB,3,count);//reduce length to used length
end;


//procedure hfd_filter(var nrstars : integer; var hfd_list,snr_list : array of double; var starlist1 : Tstar_list);//filter out hot pixels
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


procedure get_hist2(img :Timage_array;colour, startx,stopx,starty,stopy,upperlimit : integer; out histogram : Tarray_integer);
var
  i,j,col        : integer;
begin
  setlength(histogram,upperlimit+1);
  for i:=0 to upperlimit do
    histogram[i] := 0;{clear histogram of specified colour}

  For i:=startY to stopY do
  begin
    for j:=startX to stopX do
    begin
      col:=round(img[colour,i,j]);{pixel value for this colour}
      if ((col>=1) and (col<upperlimit)) then {ignore black overlap areas and bright stars}
         inc(histogram[col],1);{calculate histogram}
    end;{j}
  end; {i}
end;


procedure SigmaClippedMeanFromHistogram(img :Timage_array; colour,startx,stopx,starty,stopy, upperlimit, maxIterations: integer; convergenceThreshold : double; out meanv,stdev : double);
var
  i, totalCount, iteration, binvalue, val: Integer;
  sum, sumSquares, variance: Double;
  previousMean, previousStdDev: Double;
  converged: Boolean;
  currentLowerLimit, currentUpperLimit: Integer;  // Added for clipping range
  sigmaLow, sigmaHigh: Double;  // Sigma clipping parameters
  histogram         : Tarray_integer;
begin
  sigmaLow := 3.0;   // Standard values for astronomy
  sigmaHigh := 2.0;
  iteration := 0;
  converged := False;
  meanv := 0;
  stdev := 0;

  // Initial range is full histogram
  currentLowerLimit := 0;
  currentUpperLimit := upperlimit;


  get_hist2(img,colour,startx,stopx,starty,stopy,upperlimit,{out} histogram);

  while (not converged) and (iteration < maxIterations) do
  begin
    previousMean := meanv;
    previousStdDev := stdev;

    // Reset accumulation variables each iteration
    sum := 0.0;
    sumSquares := 0.0;
    totalCount := 0;

    // Calculate statistics for current clipping range
    for i := currentLowerLimit to currentUpperLimit do
    begin
      if (i >= 0) and (i < Length(histogram)) then  // Bounds check
      begin
        val := histogram[i];
        if val > 0 then
        begin
          binValue := i;  // Bin index represents pixel value
          sum := sum + (binValue * val);
          sumSquares := sumSquares + (binValue * binValue * val);
          totalCount := totalCount + val;
        end;
      end;
    end;

    // Calculate mean and standard deviation
    if totalCount > 0 then
    begin
      meanv := sum / totalCount;
      if totalCount > 1 then
      begin
        variance := (sumSquares - (sum * sum) / totalCount) / (totalCount - 1);
        if variance > 0 then
          stdev := Sqrt(variance)
        else
          stdev := 0.0;
      end
      else
        stdev := 0.0;
    end
    else
    begin
      meanv := 0.0;
      stdev := 0.0;
      Break; // No data left
    end;

    //memo2_message('Iteration '+ inttostr(iteration)+'  Mean:'+floattostr(meanv)+'  Stdev:'+floattostr(stdev));

    Inc(iteration);

    //Update clipping range for next iteration
    if stdev > 0 then
    begin
      currentLowerLimit := Max(0, Round(meanv - sigmaLow * stdev));
      currentLowerLimit := 0;
      currentUpperLimit := Min(upperlimit, Round(meanv + sigmaHigh * stdev));
    end;

    // Check for convergence
    if (iteration > 1) and  // Don't check convergence on first iteration
       (Abs(meanv - previousMean) < convergenceThreshold) and
       (Abs(stdev - previousStdDev) < convergenceThreshold) then
      converged := True;

  end; // while
end;



procedure find_stars(img :Timage_array; head: theader; hfd_min:double; max_stars :integer;out starlistI: Tstar_list; out mean_hfd: double);{find stars and put them in a list}
var
   fitsX, fitsY,nrstars,radius,i,j,retries,xci,yci,sqr_radius,width2,height2,starpixels,xx,yy,startX,endX,startY,endY,stepsX,stepsY : integer;
   hfd1,star_fwhm,snr,xc,yc,highest_snr,flux, detection_level,backgr, noise_level: double;
   img_sa     : Timage_array;
   startTick2  : qword;{for timing/speed purposes}
// flip_vertical,flip_horizontal  : boolean;
// starX,starY :integer;
const
    buffersize=5000;{5000}
    rastersteps=12;

          procedure find_stars_routine(startx,endx,starty,endy : integer);
          var
             fitsX, fitsY,m,n : integer;
          begin
            for fitsY:=startY to endY do  //Search through the image. Stay one pixel away from the borders.
            begin
              for fitsX:=startX to endX  do
              begin
                if ((img_sa[0,fitsY,fitsX]<>retries){star free area for this retry} and (img[0,fitsY,fitsX]- backgr>detection_level){star}) then {new star above noise level}
                begin
                  starpixels:=0;
                  if img[0,fitsY,fitsX-1]- backgr>4*noise_level then inc(starpixels);//inspect in a cross around it.
                  if img[0,fitsY,fitsX+1]- backgr>4*noise_level then inc(starpixels);
                  if img[0,fitsY-1,fitsX]- backgr>4*noise_level then inc(starpixels);
                  if img[0,fitsY+1,fitsX]- backgr>4*noise_level then inc(starpixels);
                  if starpixels>=2 then //At least 3 illuminated pixels. Not a hot pixel
                  begin
                    HFD(img,fitsX,fitsY,14{annulus radius},99 {flux aperture restriction},0 {adu_e}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
                    if ((hfd1<=30) and (snr>10) and (hfd1>hfd_min) {0.8 is two pixels minimum} and (img_sa[0,round(yc),round(xc)]<>retries)) then
                    begin
                      {for testing}
                    //  if flip_vertical=false  then  starY:=round(height2-yc) else starY:=round(yc);
                    //  if flip_horizontal=true then starX:=round(width2-xc)  else starX:=round(xc);
                    //  size:=round(5*hfd1);
                    //  mainform1.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
                    //  mainform1.image1.Canvas.textout(starX+size,starY+size,floattostrf(hfd1, ffgeneral, 2,1));{add hfd as text}
                    //  mainform1.image1.Canvas.textout(starX+size,starY+size,floattostrf(snr, ffgeneral, 2,1));{add hfd as text}

                      mean_hfd:=mean_hfd+hfd1;//sum up to calculate the average/mean hfd later

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
                            img_sa[0,j,i]:=retries;//mark as star area. Use retries value, so that img_sa does not requires a clearing!
                        end;

                      {store values}
                      inc(nrstars);
                      if nrstars>=length(starlistI[0]) then
                      begin
                        SetLength(starlistI,3,nrstars+buffersize);{adapt array size if required}
                       end;
                      starlistI[0,nrstars-1]:=xc; {store star position}
                      starlistI[1,nrstars-1]:=yc;
                      starlistI[2,nrstars-1]:=snr;{store SNR}

                      if  snr>highest_snr then highest_snr:=snr;{find to highest snr value}
                    end;
                  end;
                end;
              end;
            end;
          end;


begin
  {for testing}
//   mainform1.image1.Canvas.Pen.Mode := pmMerge;
//   mainform1.image1.Canvas.Pen.width := round(1+hd.height/mainform1.image1.height);{thickness lines}
//   mainform1.image1.Canvas.brush.Style:=bsClear;
//   mainform1.image1.Canvas.font.color:=$FF;
//   mainform1.image1.Canvas.font.size:=10;
//   mainform1.image1.Canvas.Pen.Color := $FF;
//   flip_vertical:=mainform1.flip_vertical1.Checked;
//   flip_horizontal:=mainform1.Flip_horizontal1.Checked;

  width2:=length(img[0,0]);{width}
  height2:=length(img[0]);{height}

  solve_show_log:=stackmenu1.solve_show_log1.Checked;{show details, global variable}
  if solve_show_log then begin memo2_message('Start finding stars');   startTick2 := gettickcount64;end;

  SetLength(starlistI,3,buffersize);{set array length}

  setlength(img_sa,1,height2,width2);//In case the length is set to a larger length than the current one, the new elements are zeroed out for a dynamic array. See https://www.freepascal.org/docs-html/rtl/system/setlength.html.

  backgr:=head.backgr;
  noise_level:=head.noise_level;

  retries:=4; {try up to four times to get enough stars from the image. So for retries 4,3,2,1 }
  repeat
    mean_hfd:=0;
    highest_snr:=0;
    nrstars:=0;{set counters at zero}

    if retries=4 then
    begin
      if head.star_level >30*noise_level then
      begin
        detection_level:=head.star_level;
        find_stars_routine(1,width2-1-1,1,height2-1-1);
      end
      else
        retries:=3;{skip}
    end;//stars are dominant
    if retries=3 then
    begin
      if head.star_level2>30*noise_level then
      begin
        detection_level:=head.star_level2;
        find_stars_routine(1,width2-1-1,1,height2-1-1);
      end
      else
        retries:=2;{skip}
    end;//stars are dominant
    if retries=2 then
    begin
      detection_level:=30*noise_level;
      find_stars_routine(1,width2-1-1,1,height2-1-1);
    end;
    if retries=1 then  //last try to find faint stars, divide image in sections and for each section find background and noise level
    begin
       if height2<width2 then //calculate steps in x, y
       begin
         stepsx:=rastersteps;
         stepsY:=round(rastersteps*height2/width2);
       end
       else
       begin
         stepsY:=rastersteps;
         stepsX:=round(rastersteps*width2/height2);
       end;

       for yy:=0 to stepsY do //find stars in stepsX x stepsY sections
       for xx:=0 to stepsX do
       begin
         startX:=1+round(width2*xx/(stepsX+1));
         endX:=min(width2-1-1,round(width2*(xx+1)/(stepsX+1)));
         startY:=1+round(height2*yy/(stepsY+1));
         endY:=min(height2-1-1,round(height2*(yy+1)/(stepsY+1)));

         SigmaClippedMeanFromHistogram(img,0,startX,endX,startY,endY,max(65500,trunc(head.backgr*2)), 6,0.1,backgr,noise_level);//mean and noise of this sub section
         detection_level:= 7*noise_level;
         find_stars_routine(startX,endX,startY,endY);
       end;
    end;

    if solve_show_log then memo2_message(inttostr(nrstars)+' stars found of the requested '+inttostr(max_stars)+'. Background value is '+inttostr(round(head.backgr))+ '. Detection level used '+inttostr( round(detection_level))
                                                          +' above background. Star level is '+inttostr(round(head.star_level))+' above background. Noise level is '+floattostrF(head.noise_level,ffFixed,0,0));
    dec(retries);{Try again with lower detection level}
  until ((nrstars>=max_stars) or (retries<=0));{reduce dection level till enough stars are found. Note that faint stars have less positional accuracy}

  SetLength(starlistI,3,nrstars);{set length correct}

  if nrstars>max_stars then {reduce number of stars if too high}
  begin
    if solve_show_log then memo2_message('Selecting the '+ inttostr(max_stars)+' brightest stars only.');
    get_brightest_stars(max_stars, highest_snr , starlistI); //keep only brightest stars
  end;

  if nrstars>0 then mean_hfd:=mean_hfd/nrstars;
  if solve_show_log then memo2_message('Finding stars done in '+ inttostr(gettickcount64 - startTick2)+ ' ms. Mean HFD: '+ floattostrF(mean_hfd,ffFixed,0,1) );
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
  nrquads        : integer;
begin
  result:=false; //assume failure

  // tolerance:=min(tolerance,0.008);//prevent too high tolerances
  //profiler_start(true);

  nrquads := Length(quad_star_distances1[0]);
  {3 quads required giving 3 center quad references}
  if nrquads<180 then//use brute force method
  begin
    if find_fit(minimum_quads, tolerance)=false then
    begin
      reset_solution_vectors(0.001);{nullify}
      exit;
    end;
  end
  else
  begin //use hash based routine
    if find_fit_using_hash(minimum_quads, tolerance)=false then
    begin
      reset_solution_vectors(0.001);{nullify}
      exit;
    end;
  end;

  //profiler_log('Find_fit');

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

  //profiler_log('LSQ fit');

end;



end.

