unit unit_star_align;
{Copyright (C) 2018, 2020 by Han Kleijn, www.hnsky.org
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

interface

uses Classes, SysUtils,Graphics,
     astap_main, unit_stack;
type
   star_list= array of array of double;
   solution_vector   = array[0..2] of double;


var
   starlist1, starlist2          :star_list;
   starlistquads1, starlistquads2 :star_list;{contain the three positions of the triangular quad stars}
   quad_star_distances1, quad_star_distances2: star_list;
   A_XYpositions                          : star_list;
   b_Xrefpositions,b_Yrefpositions        :  array of double;

   nr_references,nr_references2               : integer;
   solution_vectorX, solution_vectorY,solution_cblack   : solution_vector ;

   Savefile: file of solution_vector;{to save solution if required for second and third step stacking}

procedure find_stars(img :image_array;hfd_min:double;var starlist1: star_list);{find stars and put them in a list}
procedure find_quads_ref;  {find star quads for ref image}
procedure find_quads_new;  {find star quads for new image}
function find_offset_and_rotation(minimum_quads: integer;tolerance:double;save_solution:boolean) : boolean; {find difference between ref image and new image}
procedure reset_solution_vectors(factor: double); {reset the solution vectors}
procedure display_quads(starlistquads :star_list);{draw quads}
procedure save_solution_to_disk;{write to disk}

implementation

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

procedure display_quads(starlistquads :star_list);{draw quads}
var
   i, nrquads,x,y, flipx,flipy: integer;
begin
  if fits_file=false then exit; {file loaded?}
  mainwindow.image1.Canvas.Pen.Mode := pmMerge;
  mainwindow.image1.Canvas.Pen.width := round(1+height2/mainwindow.image1.height);{thickness lines}
  mainwindow.image1.Canvas.brush.Style:=bsClear;

  if mainwindow.flip_horizontal1.Checked=true then
  begin
    flipx:=-1;
    x:=width2;
  end
  else
  begin
    flipx:=1;
    x:=0;
  end;
  if mainwindow.flip_vertical1.Checked=false then
  begin
    flipy:=-1;
    y:=height2;
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

const
    debugnr:integer=0;

procedure find_quads(starlist :star_list; var starlistquads :star_list);  {build quads using closest stars, revised 2020-7-1, 25% percent faster}
var
   i,j,k,nrstars_min_one,j_used1,j_used2,j_used3,nrquads,buffersize : integer;
   distance,distance1,distance2,distance3{,dummy }                         : double;
   identical_quad : boolean;
begin
  nrstars_min_one:=Length(starlist[0])-1;
  buffersize:=nrstars_min_one;{number of quads will be lower}

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
          end
      end;
    end;{j}

//    inc(debugnr);
//    if debugnr>=29070 then
//    beep;

    starlistquads[0,nrquads]:=starlist[0,i]; {copy first star position to the quad array}
    starlistquads[1,nrquads]:=starlist[1,i];

    starlistquads[2,nrquads]:=starlist[0,j_used1]; {copy the second star position to the quad array}
    starlistquads[3,nrquads]:=starlist[1,j_used1];

    starlistquads[4,nrquads]:=starlist[0,j_used2];
    starlistquads[5,nrquads]:=starlist[1,j_used2];

    starlistquads[6,nrquads]:=starlist[0,j_used3];
    starlistquads[7,nrquads]:=starlist[1,j_used3];


    starlistquads[8,nrquads]:=(starlistquads[0,nrquads]+starlistquads[2,nrquads]+starlistquads[4,nrquads]+starlistquads[6,nrquads])/4; {center x position}
    starlistquads[9,nrquads]:=(starlistquads[1,nrquads]+starlistquads[3,nrquads]+starlistquads[5,nrquads]+starlistquads[7,nrquads])/4; {center y position}

    identical_quad:=false;
    if nrquads>=1 then {already a quad stored}
    for k:=0 to nrquads-1 do
    if ((round(starlistquads[8,nrquads])=round(starlistquads[8,k]) ) and
        (round(starlistquads[9,nrquads])=round(starlistquads[9,k]) ) ) then {same center position, found identical quad already in the list}
           identical_quad:=true;

    if identical_quad=false then  {new quad found}
    begin
      inc(nrquads); {new unique quad found}
      //will never happen:
      //if nrquads>=buffersize then setlength(starlistquads,10,length(starlistquads[0])+buffersize);{get more space}
    end;
  end;{i}

//  dummy:=starlistquads[0,nrquads-1];
  SetLength(starlistquads,10,nrquads);{reduce array length to number quads one shorter since last entry is not filled}
//  if dummy<>starlistquads[0,nrquads-1] then
 // beep;
end;


procedure calc_quad_distances(starlistquads3: star_list; var quad_star_distances: star_list);{calc and sort the six edges lengths, longest first}
var
   dist1,dist2,dist3,dist4,dist5,dist6,dummy  :double;
   nrquads, i,j: integer;
begin
  nrquads:=Length(starlistquads3[0]);{nrquads+1}
  SetLength(quad_star_distances,6,nrquads);

  try
    for i:=0 to nrquads-1 do
    begin
      dist1:=sqrt(sqr(starlistquads3[0,i]-starlistquads3[2,i])+ sqr(starlistquads3[1,i]-starlistquads3[3,i]));{distance star1-star2}
      dist2:=sqrt(sqr(starlistquads3[0,i]-starlistquads3[4,i])+ sqr(starlistquads3[1,i]-starlistquads3[5,i]));{distance star1-star3}
      dist3:=sqrt(sqr(starlistquads3[0,i]-starlistquads3[6,i])+ sqr(starlistquads3[1,i]-starlistquads3[7,i]));{distance star1-star4}
      dist4:=sqrt(sqr(starlistquads3[2,i]-starlistquads3[4,i])+ sqr(starlistquads3[3,i]-starlistquads3[5,i]));{distance star2-star3}
      dist5:=sqrt(sqr(starlistquads3[2,i]-starlistquads3[6,i])+ sqr(starlistquads3[3,i]-starlistquads3[7,i]));{distance star2-star4}
      dist6:=sqrt(sqr(starlistquads3[4,i]-starlistquads3[6,i])+ sqr(starlistquads3[5,i]-starlistquads3[7,i]));{distance star3-star4}

      {sort 6 distance on size}
      for j:=1 to 6 do {sort on distance}
      begin
        if dist6>dist5 then begin dummy:=dist5; dist5:=dist6; dist6:=dummy; end;
        if dist5>dist4 then begin dummy:=dist4; dist4:=dist5; dist5:=dummy; end;
        if dist4>dist3 then begin dummy:=dist3; dist3:=dist4; dist4:=dummy; end;
        if dist3>dist2 then begin dummy:=dist2; dist2:=dist3; dist3:=dummy; end;
        if dist2>dist1 then begin dummy:=dist1; dist1:=dist2; dist2:=dummy; end;
      end;
      quad_star_distances[0,i]:=dist1;
      quad_star_distances[1,i]:=dist2/dist1;{scale relative to largest distance}
      quad_star_distances[2,i]:=dist3/dist1;
      quad_star_distances[3,i]:=dist4/dist1;
      quad_star_distances[4,i]:=dist5/dist1;
      quad_star_distances[5,i]:=dist6/dist1;
    end;

  except
    memo2_message('Exception in procedure calc_quad_distances');{bug in fpc 3.20? Sets in once case the last elements of array to zero for file 4254816 new_image.fit'}
  end;
end;


function find_fit( minimum_count: integer; quad_tolerance: double) : boolean;
var
   nrquads1,nrquads2, i,j,k,kd4   : integer;
   mean_ratio1,  variance_ratio1,variance_factor : double;
   matchList1, matchlist2  : array of array of integer;
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

  {find outliers for largest length of the quad}
  mean_ratio1:=0;
  for k:=0 to nr_references2-1 do
  begin
    mean_ratio1:=mean_ratio1+(quad_star_distances1[0,matchlist2[0,k]]/quad_star_distances2[0,matchlist2[1,k]]); {ratio between largest length of found and reference quad}
  end;
  mean_ratio1:=mean_ratio1/nr_references2;

  variance_ratio1:=0;
  for k:=0 to nr_references2-1 do {find standard deviation orientation quads}
  begin
    variance_ratio1:=variance_ratio1+sqr(mean_ratio1-(quad_star_distances1[0,matchlist2[0,k]]/quad_star_distances2[0,matchlist2[1,k]]));
  end;
  variance_ratio1:=variance_ratio1/nr_references2;{variance or SD^2}

  nr_references:=0;
  setlength(matchlist1,2,1000);

  if nr_references2<10 then variance_factor:=sqr(2.5) {accept 99% of the data. 2.5 * standard deviation}
  else
  variance_factor:=sqr(1.5);{accept 87% of the data, to prevent false detections. 1.5 * standard deviation}

  for k:=0 to nr_references2-1 do {throw outliers out}
  begin
    if  sqr(mean_ratio1-(quad_star_distances1[0,matchlist2[0,k]]/quad_star_distances2[0,matchlist2[1,k]]))<=variance_factor*variance_ratio1 then {reference image better then 1.5 or 2.5 times standard deviation, keeping the best matches}
    begin
      matchlist1[0,nr_references]:=matchlist2[0,k];{copy match position which are <3*SD}
      matchlist1[1,nr_references]:=matchlist2[1,k];
      inc(nr_references);
      if nr_references>=length(matchlist1[0]) then setlength(matchlist1,2,nr_references+1000);{get more space if running out of space}
    end;
  end;
  {outliers in largest length removed}


  {2 quads are required giving 8 star references or 3 quads giving 3 center quad references}
  if (nr_references>=3) then {use 3 quads center position}
  begin
    {fill equations}
    setlength(A_XYpositions,nr_references,3);
    setlength(b_Xrefpositions,nr_references);
    setlength(b_Yrefpositions,nr_references);

    for k:=0 to nr_references-1 do
    begin
      A_XYpositions[k,0]:=starlistquads2[8,matchlist1[1,k]]; {average x position of quad}
      A_XYpositions[k,1]:=starlistquads2[9,matchlist1[1,k]]; {average y position of quad}
      A_XYpositions[k,2]:=1;

      b_Xrefpositions[k]:=starlistquads1[8,matchlist1[0,k]]; {x position of ref quad}
      b_Yrefpositions[k]:=starlistquads1[9,matchlist1[0,k]]; {Y position of ref quad}

      {in matrix calculations, b_refpositionX[0..nr_equations-1,0..2]:=solution_vectorX[0..2] * A_XYpositions[0..nr_equations-1,0..2]}
      {                        b_refpositionY[0..nr_equations-1,0..2]:=solution_matrixY[0..2] * A_XYpositions[0..nr_equations-1,0..2]}
      result:=true;{3 or more references}
    end;
  end
  else
  if (nr_references>=2) then {use 8 stars of 2 quads as reference. Solver requires 3 equations minimum}
  begin
    {fill equations}
    setlength(A_XYpositions,nr_references*4,3);{use 4 stars as reference instead of quads center}
    setlength(b_Xrefpositions,nr_references*4);
    setlength(b_Yrefpositions,nr_references*4);

    for k:=0 to (nr_references*4)-1 do {use 2 * 4 stars of 2 quads}
    begin
      kd4:=k div 4;
      A_XYpositions[kd4,0]:=starlistquads2[0,matchlist1[1,kd4]]; {x position of star}
      A_XYpositions[kd4,1]:=starlistquads2[1,matchlist1[1,kd4]]; {y position of star}
      A_XYpositions[kd4,2]:=1;
      A_XYpositions[kd4+1,0]:=starlistquads2[2,matchlist1[1,kd4]]; {x position of star}
      A_XYpositions[kd4+1,1]:=starlistquads2[3,matchlist1[1,kd4]]; {y position of star}
      A_XYpositions[kd4+1,2]:=1;
      A_XYpositions[kd4+2,0]:=starlistquads2[4,matchlist1[1,kd4]]; {x position of star}
      A_XYpositions[kd4+2,1]:=starlistquads2[5,matchlist1[1,kd4]]; {y position of star}
      A_XYpositions[kd4+2,2]:=1;
      A_XYpositions[kd4+3,0]:=starlistquads2[6,matchlist1[1,kd4]]; {x position of star}
      A_XYpositions[kd4+3,1]:=starlistquads2[7,matchlist1[1,kd4]]; {y position of star}
      A_XYpositions[kd4+3,2]:=1;

      b_Xrefpositions[kd4]:=starlistquads1[0,matchlist1[0,kd4]]; {x position of ref star}
      b_Yrefpositions[kd4]:=starlistquads1[1,matchlist1[0,kd4]]; {Y position of ref star}
      b_Xrefpositions[kd4+1]:=starlistquads1[2,matchlist1[0,kd4]]; {x position of ref star}
      b_Yrefpositions[kd4+1]:=starlistquads1[3,matchlist1[0,kd4]]; {Y position of ref star}
      b_Xrefpositions[kd4+2]:=starlistquads1[4,matchlist1[0,kd4]]; {x position of ref star}
      b_Yrefpositions[kd4+2]:=starlistquads1[5,matchlist1[0,kd4]]; {Y position of ref star}
      b_Xrefpositions[kd4+3]:=starlistquads1[6,matchlist1[0,kd4]]; {x position of ref star}
      b_Yrefpositions[kd4+3]:=starlistquads1[7,matchlist1[0,kd4]]; {Y position of ref star}
      result:=true;{8 star references from 2 quads}
    end;
 end;
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
  //  memo2_message(inttostr(i)+ ' , '+floattostr2(snr_list[i])) ;
    snr_scaled:=trunc(snr_list[i]*range/highest_snr);
    snr_histogram[snr_scaled]:=snr_histogram[snr_scaled]+1;{count how often this snr value is measured}
  end;
  count:=0;
  i:=range+1;
  repeat
    dec(i);
    count:=count+snr_histogram[i];
  //  memo2_message(inttostr(snr_histogram[i])+ ' , ' +inttostr(i));
  until ((i<=0) or (count>=nr_stars_required));

  snr_required:=highest_snr*i/range;

  count:=0;
  nrstars:=length(starlist1[0]);
  SetLength(starlist2,2,nrstars);{set array to maximum possible length}
  for i:=0 to nrstars-1 do
    if snr_list[i]>=snr_required then {preserve brightest stars}
    begin
      starlist2[0,count]:=starlist1[0,i];
      starlist2[1,count]:=starlist1[1,i];
      inc(count);

     //  For testing:
     //  mainwindow.image1.Canvas.Pen.Mode := pmMerge;
     //  mainwindow.image1.Canvas.Pen.width := round(1+height2/mainwindow.image1.height);{thickness lines}
     //  mainwindow.image1.Canvas.brush.Style:=bsClear;
     //  mainwindow.image1.Canvas.Pen.Color := clred;
     //  mainwindow.image1.Canvas.Rectangle(round(starlist1[0,i])-15,height2-round(starlist1[1,i])-15, round(starlist1[0,i])+15, height2-round(starlist1[1,i])+15);{indicate hfd with rectangle}
     end;
  setlength(starlist2,2,count);{reduce length to used length}
  starlist1:=starlist2;{move pointer}
end;


procedure find_stars(img :image_array;hfd_min:double;var starlist1: star_list);{find stars and put them in a list}
var
   fitsX, fitsY,nrstars,size,i,j, max_stars,retries    : integer;
   hfd1,star_fwhm,snr,xc,yc,highest_snr,flux, detection_level      : double;
   img_temp2       : image_array;
   solve_show_log  : boolean;
   snr_list        : array of double;

// flip_vertical,flip_horizontal  : boolean;
// starX,starY :integer;
   startTick2  : qword;{for timing/speed purposes}
const
    buffersize=5000;{5000}
begin
  {for testing}
//   mainwindow.image1.Canvas.Pen.Mode := pmMerge;
//   mainwindow.image1.Canvas.Pen.width := round(1+height2/mainwindow.image1.height);{thickness lines}
//   mainwindow.image1.Canvas.brush.Style:=bsClear;
//   mainwindow.image1.Canvas.font.color:=$FF;
//   mainwindow.image1.Canvas.font.size:=10;
//   mainwindow.image1.Canvas.Pen.Color := $FF;
//   flip_vertical:=mainwindow.flip_vertical1.Checked;
//   flip_horizontal:=mainwindow.Flip_horizontal1.Checked;

 // hfd_min:=4;


  max_stars:=strtoint(stackmenu1.max_stars1.text);{maximum star to process, if so filter out brightest stars later}
  solve_show_log:=stackmenu1.solve_show_log1.Checked;{show details}
  if solve_show_log then begin memo2_message('Start finding stars');   startTick2 := gettickcount64;end;


  SetLength(starlist1,2,buffersize);{set array length}
  setlength(snr_list,buffersize);{set array length}

  setlength(img_temp2,1,width2,height2);{set length of image array}

  detection_level:=star_level; {level above background. Start with a high value}
  retries:=2; {try up to three times to get enough stars from the image}
  repeat
    highest_snr:=0;
    nrstars:=0;{set counters at zero}

    for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1  do
        img_temp2[0,fitsX,fitsY]:=-1;{mark as not surveyed}

    for fitsY:=0 to height2-1-1 do
    begin
      for fitsX:=0 to width2-1-1  do
      begin
        if (( img_temp2[0,fitsX,fitsY]<=0){area not surveyed} and (img[0,fitsX,fitsY]-cblack>detection_level){star}) then {new star, at least 3.5 * sigma above noise level}
        begin
          HFD(img,fitsX,fitsY,14{box size}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if ((hfd1<=10) and (snr>10) and (hfd1>hfd_min) {0.8 is two pixels minimum} ) then
          begin
            {for testing}
          //  if flip_vertical=false  then  starY:=round(height2-yc) else starY:=round(yc);
          //  if flip_horizontal=true then starX:=round(width2-xc)  else starX:=round(xc);
          //  size:=round(5*hfd1);
          //  mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
          //  mainwindow.image1.Canvas.textout(starX+size,starY+size,floattostrf(hfd1, ffgeneral, 2,1));{add hfd as text}
          //  mainwindow.image1.Canvas.textout(starX+size,starY+size,floattostrf(snr, ffgeneral, 2,1));{add hfd as text}

            size:=round(3*hfd1);
            for j:=fitsY to fitsY+size do {mark the whole star area as surveyed}
            for i:=fitsX-size to fitsX+size do
              if ((j>=0) and (i>=0) and (j<height2) and (i<width2)) then {mark the area of the star square and prevent double detections}
                img_temp2[0,i,j]:=1;

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
    dec(retries);{try again with lower detection level}
    if retries =1 then begin if 15*noise_level[0]<star_level then detection_level:=15*noise_level[0] else retries:= 0; {skip retries 1} end; {lower  detection level}
    if retries =0 then begin if  5*noise_level[0]<star_level then detection_level:= 5*noise_level[0] else retries:=-1; {skip retries 0} end; {lowest detection level}

  until ((nrstars>=max_stars) or (retries<0));{reduce dection level till enough stars are found. Note that faint stars have less positional accuracy}

  img_temp2:=nil;{free mem}

  SetLength(starlist1,2,nrstars);{set length correct}
  setlength(snr_list,nrstars);{set length correct}

   if nrstars>max_stars then {reduce number of stars if too high}
  begin
    if solve_show_log then memo2_message('Selecting the '+ inttostr(max_stars)+' brightest stars only.');
    get_brightest_stars(max_stars, highest_snr, snr_list, starlist1);
  end;
  if solve_show_log then memo2_message('Finding stars done in '+ inttostr(gettickcount64 - startTick2)+ ' ms');
end;


procedure find_quads_ref;{find quads for reference image}
begin
  find_quads(starlist1,starlistquads1);
  calc_quad_distances(starlistquads1,quad_star_distances1);{calc the six sides, longest first}
end;


procedure find_quads_new;{find star quads for new image}
begin
  find_quads(starlist2,starlistquads2);
  calc_quad_distances(starlistquads2,quad_star_distances2);{calc the six sides, longest first}
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


procedure save_solution_to_disk;{write to disk}
begin
  solution_cblack[0]:=cblack;{store datamin in solution vector}
  {solution_cblack[1] used in blinck for flux_magn_offset}
  solution_cblack[2]:=0;{spare}

  AssignFile(savefile,ChangeFileExt(Filename2,'.astap_solution'));
  ReWrite(saveFile);
  Write(savefile, solution_vectorX);
  Write(savefile, solution_vectorY);
  Write(savefile, solution_cblack);{save background value}
  CloseFile(saveFile);
end;


function find_offset_and_rotation(minimum_quads: integer;tolerance:double;save_solution:boolean) : boolean; {find difference between ref image and new image}
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


  if ((xy_sqr_ratio<0.99) or (xy_sqr_ratio>1.01)) then {dimensions x, y are not the same, something wrong}
  begin
    result:=false;
    reset_solution_vectors(0.001);{nullify}
    exit;
  end;

  if save_solution then save_solution_to_disk;{write to disk}
end;

end.

