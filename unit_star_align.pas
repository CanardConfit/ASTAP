unit unit_star_align;
{Copyright (C) 2018,2019 by Han Kleijn, www.hnsky.org
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

uses Classes, SysUtils,Graphics,math,
     astap_main, unit_stack;
type
   star_list= array of array of double;
   solution_vector   = array[0..2] of double;


var
   starlist1, starlist2          :star_list;
   starlisttetrahedrons1, starlisttetrahedrons2 :star_list;{contain the three positions of the triangular tetrahedron stars}
   star_tetrahedron_lengths1, star_tetrahedron_lengths2: star_list;
   A_XYpositions                          : star_list;
   b_Xrefpositions,b_Yrefpositions        :  array of double;


   nr_references,nr_references2               : integer;
   solution_vectorX, solution_vectorY,solution_cblack   : solution_vector ;

   Savefile: file of solution_vector;{to save solution if required for second and third step stacking}

procedure find_stars(img :image_array;var starlist1: star_list);{find stars and put them in a list}
procedure find_tetrahedrons_ref;  {find star tetrahedrons for ref image}
procedure find_tetrahedrons_new;  {find star tetrahedrons for new image}
function find_offset_and_rotation(minimum_tetrahedrons: integer;tolerance:double;save_solution:boolean) : boolean; {find difference between ref image and new image}
procedure reset_solution_vectors(factor: double); {reset the solution vectors}
procedure display_tetrahedrons(starlisttetrahedrons :star_list);{draw tetrahedrons}
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


procedure display_tetrahedrons(starlisttetrahedrons :star_list);{draw tetrahedrons}
var
   i, nrtetrahedrons,x,y, flipx,flipy: integer;
begin
  if fits_file=false then exit; {file loaded?}
  mainwindow.image1.Canvas.Pen.Mode := pmMerge;
  mainwindow.image1.Canvas.Pen.width := round(1+height2/mainwindow.image1.height);{thickness lines}
  mainwindow.image1.Canvas.brush.Style:=bsClear;


  if mainwindow.Fliphorizontal1.Checked=true then
  begin
    flipx:=-1;
    x:=width2;
  end
  else
  begin
    flipx:=1;
    x:=0;
  end;
  if mainwindow.flipvertical1.Checked=false then
  begin
    flipy:=-1;
    y:=height2;
  end
  else
  begin
    flipy:=1;
    y:=0;
  end;

  nrtetrahedrons:=Length(starlisttetrahedrons[0])-1;

  for i:=0 to  nrtetrahedrons do
  begin
    mainwindow.image1.Canvas.Pen.Color :=$606060 +random($9F9F9F);
    if odd(i) then mainwindow.image1.Canvas.Pen.Style := pssolid
       else  mainwindow.image1.Canvas.Pen.Style := psdot;
    mainwindow.image1.Canvas.moveto(x+flipx*round(starlisttetrahedrons[0,i]),y+flipy*round(starlisttetrahedrons[1,i]));{move to star 1}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlisttetrahedrons[2,i]),y+flipy*round(starlisttetrahedrons[3,i]));{draw line star1-star2}

    mainwindow.image1.Canvas.lineto(x+flipx*round(starlisttetrahedrons[4,i]),y+flipy*round(starlisttetrahedrons[5,i]));{draw line star2-star3}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlisttetrahedrons[0,i]),y+flipy*round(starlisttetrahedrons[1,i]));{draw line star3-star1}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlisttetrahedrons[6,i]),y+flipy*round(starlisttetrahedrons[7,i]));{draw line star1-star4}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlisttetrahedrons[4,i]),y+flipy*round(starlisttetrahedrons[5,i]));{draw line star4-star3}
    mainwindow.image1.Canvas.moveto(x+flipx*round(starlisttetrahedrons[6,i]),y+flipy*round(starlisttetrahedrons[7,i]));{move to star4}
    mainwindow.image1.Canvas.lineto(x+flipx*round(starlisttetrahedrons[2,i]),y+flipy*round(starlisttetrahedrons[3,i]));{draw line star4-star2}
  end;
end;

procedure find_tetrahedrons(starlist :star_list; var starlisttetrahedrons :star_list);  {find closest stars}
var
   i,j,k,nrstars_min_one,j_used1,j_used2,nrtetrahedrons : integer;
   shortest_distance,distance,shortest,shortest2    : double;
   identical_tetrahedron : boolean;
const
   buffersize=1000;{1000}
begin
  nrstars_min_one:=Length(starlist[0])-1;

  if nrstars_min_one<3 then
  begin {not enough stars for tetrahedrons}
    SetLength(starlisttetrahedrons,10,0);
    exit;
  end;

  nrtetrahedrons:=0;

  SetLength(starlisttetrahedrons,10,buffersize);{set array length to 100}

  for i:=0 to nrstars_min_one do
  begin
      shortest_distance:=1E99;
      starlisttetrahedrons[0,nrtetrahedrons]:=starlist[0,i];
      starlisttetrahedrons[1,nrtetrahedrons]:=starlist[1,i];
      j_used1:=-1;
      for j:=0 to nrstars_min_one do {find closest star}
      begin
        if j<>i{not used} then
        begin
            distance:=sqr(starlist[0,j]-starlist[0,i])+ sqr(starlist[1,j]-starlist[1,i]);
            if distance<shortest_distance then
            begin
              shortest_distance:=distance;
              starlisttetrahedrons[2,nrtetrahedrons]:=starlist[0,j];
              starlisttetrahedrons[3,nrtetrahedrons]:=starlist[1,j];
              j_used1:=j;{mark later as used}
           end;
        end;
      end;{j}


      shortest:=shortest_distance;{store shortest distance}
      shortest_distance:=1E99;
      j_used2:=-1;
      for j:=0 to nrstars_min_one do{find second closest star}
        begin
          if ((J<>I) and (J<>j_used1)) {not used} then
          begin
            distance:=sqr(starlist[0,j]-starlist[0,i])+ sqr(starlist[1,j]-starlist[1,i]);
            if ((distance<shortest_distance) and (distance>shortest)) then
            begin
              shortest_distance:=distance;
              starlisttetrahedrons[4,nrtetrahedrons]:=starlist[0,j];
             starlisttetrahedrons[5,nrtetrahedrons]:=starlist[1,j];
              j_used2:=j;{mark later as used}
            end;
          end;
        end;{j}

      shortest2:=shortest_distance;{store shortest distance}
      shortest_distance:=1E99;
      for j:=0 to nrstars_min_one do{find third closest star}
      begin
        if ((J<>I) and (J<>j_used1) and (J<>j_used2)) {not used} then
        begin
          distance:=sqr(starlist[0,j]-starlist[0,i])+ sqr(starlist[1,j]-starlist[1,i]);
          if ((distance<shortest_distance) and (distance>shortest2)) then
          begin
            shortest_distance:=distance;
            starlisttetrahedrons[6,nrtetrahedrons]:=starlist[0,j];
            starlisttetrahedrons[7,nrtetrahedrons]:=starlist[1,j];
          end;
        end;
      end;{j}
      starlisttetrahedrons[8,nrtetrahedrons]:=(starlisttetrahedrons[0,nrtetrahedrons]+starlisttetrahedrons[2,nrtetrahedrons]+starlisttetrahedrons[4,nrtetrahedrons]+starlisttetrahedrons[6,nrtetrahedrons])/4; {center x position}
      starlisttetrahedrons[9,nrtetrahedrons]:=(starlisttetrahedrons[1,nrtetrahedrons]+starlisttetrahedrons[3,nrtetrahedrons]+starlisttetrahedrons[5,nrtetrahedrons]+starlisttetrahedrons[7,nrtetrahedrons])/4; {center y position}

      identical_tetrahedron:=false;
      if nrtetrahedrons>=1 then {already a tetrahedron stored}
      for k:=0 to nrtetrahedrons-1 do
      if ((round(starlisttetrahedrons[8,nrtetrahedrons])=round(starlisttetrahedrons[8,k]) ) and
          (round(starlisttetrahedrons[9,nrtetrahedrons])=round(starlisttetrahedrons[9,k]) ) ) then {found identical tetrahedron already in the list}
             identical_tetrahedron:=true;

      if identical_tetrahedron=false then  {new tetrahedron found}
      begin
        inc(nrtetrahedrons); {new unique tetrahedron found}
        if nrtetrahedrons>=buffersize then setlength(starlisttetrahedrons,10,length(starlisttetrahedrons[0])+buffersize);{get more space}
      end;
  end;{i}

  SetLength(starlisttetrahedrons,10,nrtetrahedrons);{set array length to tetrahedrons one shorter since last entry is not filled}
end;

procedure calc_tetrahedron_lengths(starlisttetrahedrons3: star_list; var star_tetrahedron_lengths: star_list);{calc and sort the six edges lengths, longest first}
var
   leng1,leng2,leng3,leng4,leng5,leng6,dummy  :double;
   nrtetrahedrons, i,j: integer;
begin
  nrtetrahedrons:=Length(starlisttetrahedrons3[0]);{nrtetrahedrons+1}
  SetLength(star_tetrahedron_lengths,6,nrtetrahedrons);

  for i:=0 to nrtetrahedrons-1 do
  begin
    leng1:=sqrt(sqr(starlisttetrahedrons3[0,i]-starlisttetrahedrons3[2,i])+ sqr(starlisttetrahedrons3[1,i]-starlisttetrahedrons3[3,i]));{distance star1-star2}
    leng2:=sqrt(sqr(starlisttetrahedrons3[0,i]-starlisttetrahedrons3[4,i])+ sqr(starlisttetrahedrons3[1,i]-starlisttetrahedrons3[5,i]));{distance star1-star3}
    leng3:=sqrt(sqr(starlisttetrahedrons3[0,i]-starlisttetrahedrons3[6,i])+ sqr(starlisttetrahedrons3[1,i]-starlisttetrahedrons3[7,i]));{distance star1-star4}
    leng4:=sqrt(sqr(starlisttetrahedrons3[2,i]-starlisttetrahedrons3[4,i])+ sqr(starlisttetrahedrons3[3,i]-starlisttetrahedrons3[5,i]));{distance star2-star3}
    leng5:=sqrt(sqr(starlisttetrahedrons3[2,i]-starlisttetrahedrons3[6,i])+ sqr(starlisttetrahedrons3[3,i]-starlisttetrahedrons3[7,i]));{distance star2-star4}
    leng6:=sqrt(sqr(starlisttetrahedrons3[4,i]-starlisttetrahedrons3[6,i])+ sqr(starlisttetrahedrons3[5,i]-starlisttetrahedrons3[7,i]));{distance star3-star4}

    {sort edges length of triangular tetrahedrons}
    for j:=1 to 6 do {sort on length}
    begin
      if leng6>leng5 then begin dummy:=leng5; leng5:=leng6; leng6:=dummy; end;
      if leng5>leng4 then begin dummy:=leng4; leng4:=leng5; leng5:=dummy; end;
      if leng4>leng3 then begin dummy:=leng3; leng3:=leng4; leng4:=dummy; end;
      if leng3>leng2 then begin dummy:=leng2; leng2:=leng3; leng3:=dummy; end;
      if leng2>leng1 then begin dummy:=leng1; leng1:=leng2; leng2:=dummy; end;
    end;
    star_tetrahedron_lengths[0,i]:=leng1;
    star_tetrahedron_lengths[1,i]:=leng2/leng1;{scale relative to largest edge length}
    star_tetrahedron_lengths[2,i]:=leng3/leng1;
    star_tetrahedron_lengths[3,i]:=leng4/leng1;
    star_tetrahedron_lengths[4,i]:=leng5/leng1;
    star_tetrahedron_lengths[5,i]:=leng6/leng1;
  end;
end;


procedure find_fit( minimum_count: integer; tetrahedron_tolerance: double);
var
   nrtetrahedrons1,nrtetrahedrons2, i,j,k   : integer;
   mean_ratio1,  variance_ratio1,variance_factor : double;
   matchList1, matchlist2  : array of array of integer;
begin
  nrtetrahedrons1:=Length(star_tetrahedron_lengths1[0]);
  nrtetrahedrons2:=Length(star_tetrahedron_lengths2[0]);

  {minimum_count required, 6 for stacking, 3 for plate solving}
  if ((nrtetrahedrons1<minimum_count) or (nrtetrahedrons2< minimum_count)) then begin nr_references:=0; exit; end;{no solution abort before run time errors}

  {Find a tolerance resulting in 6 or more of the best matching tetrahedrons}
  setlength(matchlist2,2,1000);
  nr_references2:=0;
  i:=0;
  repeat
    j:=0;
    repeat
      if abs(star_tetrahedron_lengths1[1,i] - star_tetrahedron_lengths2[1,j])<=tetrahedron_tolerance then {all length are scaled to the longest length so scale independent}
      if abs(star_tetrahedron_lengths1[2,i] - star_tetrahedron_lengths2[2,j])<=tetrahedron_tolerance then
      if abs(star_tetrahedron_lengths1[3,i] - star_tetrahedron_lengths2[3,j])<=tetrahedron_tolerance then
      if abs(star_tetrahedron_lengths1[4,i] - star_tetrahedron_lengths2[4,j])<=tetrahedron_tolerance then
      if abs(star_tetrahedron_lengths1[5,i] - star_tetrahedron_lengths2[5,j])<=tetrahedron_tolerance then
      begin
        matchlist2[0,nr_references2]:=i;{store match position}
        matchlist2[1,nr_references2]:=j;
        inc(nr_references2);
        if nr_references2>=length(matchlist2[0]) then setlength(matchlist2,2,nr_references2+1000);{get more space}
      end;
      inc(j);
    until j>=nrtetrahedrons2;{j loop}
    inc(i);
  until i>=nrtetrahedrons1;{i loop}

 //memo2_message('Found '+inttostr( nr_references2)+ ' references');

  if nr_references2< minimum_count then begin nr_references:=0; exit; end;{no solution abort before run time errors}

  {find outliers for largest length of the tetrahedron}
  mean_ratio1:=0;
  for k:=0 to nr_references2-1 do
  begin
    mean_ratio1:=mean_ratio1+(star_tetrahedron_lengths1[0,matchlist2[0,k]]/star_tetrahedron_lengths2[0,matchlist2[1,k]]); {ratio between largest length of found and reference tetrahedron}
  end;
  mean_ratio1:=mean_ratio1/nr_references2;

  variance_ratio1:=0;
  for k:=0 to nr_references2-1 do {find standard deviation orientation tetrahedrons}
  begin
    variance_ratio1:=variance_ratio1+sqr(mean_ratio1-(star_tetrahedron_lengths1[0,matchlist2[0,k]]/star_tetrahedron_lengths2[0,matchlist2[1,k]]));
  end;
  variance_ratio1:=variance_ratio1/nr_references2;{variance or SD^2}

  nr_references:=0;
  setlength(matchlist1,2,1000);

  if nr_references2<10 then variance_factor:=sqr(2.5) {accept 99% of the data. 2.5 * standard deviation}
  else
  variance_factor:=sqr(1.5);{accept 87% of the data, to prevent false detections. 1.5 * standard deviation}

  for k:=0 to nr_references2-1 do {throw outliers out}
  begin
    if  sqr(mean_ratio1-(star_tetrahedron_lengths1[0,matchlist2[0,k]]/star_tetrahedron_lengths2[0,matchlist2[1,k]]))<=variance_factor*variance_ratio1 then {reference image better then 1.5 or 2.5 times standard deviation, keeping the best matches}
    begin
      matchlist1[0,nr_references]:=matchlist2[0,k];{copy match position which are <3*SD}
      matchlist1[1,nr_references]:=matchlist2[1,k];
      inc(nr_references);
      if nr_references>=length(matchlist1[0]) then setlength(matchlist1,2,nr_references+1000);{get more space if running out of space}
    end;
  end;
  {outliers in largest length removed}
 if (nr_references<3) then begin exit; end;{no solution abort before run time errors. Requires 3 equations minimum}

  {fill equations}
  setlength(A_XYpositions,nr_references,3);
  setlength(b_Xrefpositions,nr_references);
  setlength(b_Yrefpositions,nr_references);


  for k:=0 to nr_references-1 do
  begin
    A_XYpositions[k,0]:=starlisttetrahedrons2[8,matchlist1[1,k]]; {average x position of tetrahedron}
    A_XYpositions[k,1]:=starlisttetrahedrons2[9,matchlist1[1,k]]; {average y position of tetrahedron}
    A_XYpositions[k,2]:=1;

    b_Xrefpositions[k]:=starlisttetrahedrons1[8,matchlist1[0,k]]; {x position of ref tetrahedron}
    b_Yrefpositions[k]:=starlisttetrahedrons1[9,matchlist1[0,k]]; {Y position of ref tetrahedron}

    {in matrix calculations, b_refpositionX[0..nr_equations-1,0..2]:=solution_vectorX[0..2] * A_XYpositions[0..nr_equations-1,0..2]}
    {                        b_refpositionY[0..nr_equations-1,0..2]:=solution_matrixY[0..2] * A_XYpositions[0..nr_equations-1,0..2]}

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
//    if snr_scaled<=range then  {2019-11-30, this line is not required}
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

procedure find_stars(img :image_array;var starlist1: star_list);{find stars and put them in a list}
var
   fitsX, fitsY,nrstars,size,i,j, max_stars,retries    : integer;
   hfd1,star_fwhm,snr,xc,yc,highest_snr,flux, detection_level      : double;
   img_temp2       : image_array;
   snr_list        : array of double;
   solve_show_log  : boolean;
// flip_vertical,flip_horizontal  : boolean;
// starX,starY :integer;
   startTick2  : qword;{for timing/speed purposes}
const
    buffersize=5000;{5000}
begin

  if fits_file=false then exit; {file loaded?}

  {for testing}
//   mainwindow.image1.Canvas.Pen.Mode := pmMerge;
//   mainwindow.image1.Canvas.Pen.width := round(1+height2/mainwindow.image1.height);{thickness lines}
//   mainwindow.image1.Canvas.brush.Style:=bsClear;
//   mainwindow.image1.Canvas.font.color:=$FF;
//   mainwindow.image1.Canvas.font.size:=10;
//   mainwindow.image1.Canvas.Pen.Color := $FF;
//   flip_vertical:=mainwindow.Flipvertical1.Checked;
//   flip_horizontal:=mainwindow.Fliphorizontal1.Checked;

  solve_show_log:=stackmenu1.solve_show_log1.Checked;{show details}
  if solve_show_log then begin memo2_message('Start finding stars');   startTick2 := gettickcount64;end;


  SetLength(starlist1,2,buffersize);{set array length}
  setlength(snr_list,buffersize);{set array length}

  setlength(img_temp2,1,width2,height2);{set length of image array}
  max_stars:=strtoint(stackmenu1.max_stars1.text);{maximum star to process, if so filter out brightest stars later}


  retries:=2; {try three times to get enough stars from the image}
  repeat
    if retries=2 then detection_level:=star_level {level above background. Start with a high value}
    else
    if retries=1 then begin detection_level:=min(star_level,15*noise_level[0]); end {lower detection level}
    else
    detection_level:=min(star_level,5*noise_level[0]);{lower detection level}

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
          HFD(img,fitsX,fitsY, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if ((hfd1<=10) and (snr>10) and (hfd1>0.8) {two pixels minimum} ) then
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
    dec(retries);{try again with lower level}

  until ((nrstars>=max_stars) or (retries<0));{reduce dection level till enough stars are found. Note that faint stars have less positional accuracy}

  img_temp2:=nil;{free mem}

  SetLength(starlist1,2,nrstars);{set length correct}
  setlength(snr_list,nrstars);{set length correct}

  if nrstars>max_stars then {reduce number of stars if too high}
  begin
     if solve_show_log then memo2_message('Selecting the '+ inttostr(max_stars)+' brightest stars only.');
    get_brightest_stars(max_stars, highest_snr, snr_list, starlist1);
  end;
  if solve_show_log then memo2_message('Finding stars completed in '+ inttostr(gettickcount64 - startTick2)+ ' ms');
end;

procedure find_tetrahedrons_ref;{find tetrahedrons for reference image}
begin
  find_tetrahedrons(starlist1,starlisttetrahedrons1);
  calc_tetrahedron_lengths(starlisttetrahedrons1,star_tetrahedron_lengths1);{calc the three sides, longest first}
end;
procedure find_tetrahedrons_new;{find star tetrahedrons for new image}
begin
  find_tetrahedrons(starlist2,starlisttetrahedrons2);
  calc_tetrahedron_lengths(starlisttetrahedrons2,star_tetrahedron_lengths2);{calc the three sides, longest first}
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

function find_offset_and_rotation(minimum_tetrahedrons: integer;tolerance:double;save_solution:boolean) : boolean; {find difference between ref image and new image}
var
  xy_sqr_ratio   : double;
begin

  find_fit(minimum_tetrahedrons, tolerance);

  if nr_references<3 then
  begin
    result:=false;
    reset_solution_vectors(0.001);{nullify}
    exit;
  end;
  result:=true;

  {in matrix calculations, b_refpositionX[0..nr_equations-1,0..2]:=solution_vectorX[0..2] * A_XYpositions[0..nr_equations-1,0..2]}
  {                        b_refpositionY[0..nr_equations-1,0..2]:=solution_vectorY[0..2] * A_XYpositions[0..nr_equations-1,0..2]}

  {find solution vector for X:=ax+by+c  / b_Xref:=solution[0]x+solution[1]y+solution[2]}
   lsq_fit( A_XYpositions {[0..nr_equations-1, 0..2]},b_Xrefpositions, solution_vectorX {[0..2]} );

  {find solution vector for Y:=ax+by+c  / b_Yref:=solution[0]x+solution[1]y+solution[2]}
  lsq_fit( A_XYpositions {[0..nr_equations-1, 0..2]},b_Yrefpositions, solution_vectorY {[0..2]} );


  xy_sqr_ratio:=(sqr(solution_vectorX[0])+sqr(solution_vectorX[1]) ) / (0.00000001+ sqr(solution_vectorY[0])+sqr(solution_vectorY[1]) );
  if ((xy_sqr_ratio<0.9) or (xy_sqr_ratio>1.1)) then {dimensions x, y are not the same, something wrong}
  begin
    result:=false;
    reset_solution_vectors(0.001);{nullify}
    exit;
  end;

  if save_solution then save_solution_to_disk;{write to disk}
end;

end.

