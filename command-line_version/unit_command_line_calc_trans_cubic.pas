unit unit_command_line_calc_trans_cubic;
//  DESCRIPTION:
//  This unit calculates the 3th order transfer function between two set of matching quads or star positions.
//  The output are ten transfer coefficients for X axis and ten coefficients for the Y-axis.

{This unit is based on some C language routines from the package Match. See describtion below. Conversion and modification for the ASTAP program by Han Kleijn.
The original Match version was suitable for 2th order only but extended to the 3th order by Cecile Melis for the Siril program.

Copyright (C) 2024 by Han Kleijn www.hnsky.org

This program is free software: you can redistribute it and/or modify
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
//==============================================================================
//Original description for the Match program.
//http://spiff.rit.edu/match/
{*  match: a package to match lists of stars (or other items)
 *  Copyright (C) 2000  Michael William Richmond
 *
 *  Contact: Michael William Richmond
 *           Physics Department
 *           Rochester Institute of Technology
 *           85 Lomb Memorial Drive
 *           Rochester, NY  14623-5603
 *           E-mail: mwrsps@rit.edu
 *
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version 2
 *  of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */
 }


interface

uses
  Classes, SysUtils,math;

type
  TMatrix = array of array of Double;
  TVector = array of Double;
  s_star = record
             x, y: Double;
           end;
  TStarArray = array of s_star;
  TTrans = record
             x00,x10,x01,x20,x11,x02,x30,x21,x12,x03 : double;  //was orginally a, b, c, d, e, f, g, h
             y00,y10,y01,y20,y11,y02,y30,y21,y12,y03 : double;  //              i, j, k, l, m, n, o, p
           end;

function Calc_Trans_Cubic(stars_reference: TStarArray; // First array of s_star structure we match the output TRANS takes their coords into those of array B
                          stars_distorted: TStarArray; // Second array of s_star structure we match
                          out trans: TTrans;  // Transfer coefficients for starsA positions to starsB positions
                          out err_mess : string // any error message
                          ): boolean; //succes


implementation

type
  Tsolutionvector = array[0..9] of Double;

const
  MATRIX_TOL=1E-100;


{/***************************************************************************
 * PROCEDURE: gauss_pivot
 *
 * DESCRIPTION:
 * This routine is called by "gauss_matrix".  Given a square "matrix"
 * of "num"-by-"num" elements, and given a "vector" of "num" elements,
 * and given a particular "row" value, this routine finds the largest
 * value in the matrix at/below the given "row" position.  If that
 * largest value isn't in the given "row", this routine switches
 * rows in the matrix (and in the vector) so that the largest value
 * will now be in "row".
 *
 * RETURN:
 *    SH_SUCCESS          if all goes well
 *    SH_GENERIC_ERROR    if not -- if matrix is singular
 *
 * </AUTO>
 */}
procedure Gauss_Pivot(var matrix: TMatrix;          // I/O: a square 2-D matrix we are inverting
                      num: Integer;                 // I: number of rows and cols in matrix
                      var vector: TSolutionVector;  // I/O: vector which holds "b" values in input
                      var biggest_val: TVector;     // I: largest value in each row of matrix
                      row: Integer                  // I: want to pivot around this row
                     );
var
  i, col, pivot_row  : Integer;
  big, other_big,temp: Double;

begin
  pivot_row := row;
  big := Abs(matrix[row][row] / biggest_val[row]);

  // Finding the row with the largest value for pivoting
  for i := row + 1 to num - 1 do
  begin
    other_big := Abs(matrix[i][row] / biggest_val[i]);
    if other_big > big then
    begin
      big := other_big;
      pivot_row := i;
    end;
  end;
  // If another row is better for pivoting, switch it with 'row'
  // and switch the corresponding elements in 'vector'
  // and switch the corresponding elements in 'biggest_val'
  // If another row is better for pivoting, switch it with 'row'
  if pivot_row <> row then
  begin
    for col := row to num - 1 do
    begin
      // Manual swapping of matrix elements
      temp := matrix[pivot_row][col];
      matrix[pivot_row][col] := matrix[row][col];
      matrix[row][col] := temp;
    end;

    // Manual swapping of vector elements
    temp := vector[pivot_row];
    vector[pivot_row] := vector[row];
    vector[row] := temp;

    // Manual swapping of biggest_val elements
    temp := biggest_val[pivot_row];
    biggest_val[pivot_row] := biggest_val[row];
    biggest_val[row] := temp;
  end;
end;


{***************************************************************************
 * PROCEDURE: gauss_matrix
 *
 * DESCRIPTION:
 * Given a square 2-D 'num'-by-'num' matrix, called "matrix", and given
 * a 1-D vector "vector" of 'num' elements, find the 1-D vector
 * called "solution_vector" which satisfies the equation
 *
 *      matrix * solution_vector  =  vector
 *
 * where the * above represents matrix multiplication.
 *
 * What we do is to use Gaussian elimination (with partial pivoting)
 * and back-substitution to find the solution_vector.
 * We do not pivot in place, but physically move values -- it
 * doesn't take much time in this application.  After we have found the
 * "solution_vector", we replace the contents of "vector" with the
 * "solution_vector".
 *
 * This is a common algorithm.  See any book on linear algebra or
 * numerical solutions; for example, "Numerical Methods for Engineers,"
 * by Steven C. Chapra and Raymond P. Canale, McGraw-Hill, 1998,
 * Chapter 9.
 *
 * If an error occurs (if the matrix is singular), this prints an error
 * message and returns with error code.
 *
 * RETURN:
 *    SH_SUCCESS          if all goes well
 *    SH_GENERIC_ERROR    if not -- if matrix is singular
 *
 * </AUTO>
 */}

function Gauss_Matrix(var matrix: TMatrix;        // I/O: the square 2-D matrix we'll invert will hold inverse matrix on output
                      num: Integer;                // I: number of rows and cols in matrix
                      var vector: Tsolutionvector;  // I/O: vector which holds "b" values in input and the solution vector "x" on output
                      out err_mess : string         // O: Any error message

                      ): boolean;

var
  i,
  j,
  k               : integer;
  biggest_val: TVector;
  solution_vector: TVector;
  factor,
  sum             : Double;
begin
  err_mess:=''; //clear message;
  SetLength(biggest_val, num);
  SetLength(solution_vector, num);
  // Step 1: Find the largest value in each row of matrix,
  //         and store those values in 'biggest_val' array.
  //         We use this information to pivot the matrix.
  for i := 0 to num - 1 do
  begin
    biggest_val[i] := Abs(matrix[i][0]);
    for j := 1 to num - 1 do
    begin
      if Abs(matrix[i][j]) > biggest_val[i] then
        biggest_val[i] := Abs(matrix[i][j]);
    end;

    if biggest_val[i] = 0.0 then
    begin
      // Handle the error: "gauss_matrix: biggest val in row is zero"
      // Error handling code should go here. In Pascal, you might raise an exception
      // or handle the error in a way that's appropriate for your application.
      err_mess:='Gauss_matrix: biggest val in row is zero';
      exit(false);
    end;
  end;

   // Step 2: Use Gaussian elimination to convert the "matrix"
   // into a triangular matrix, in which the values of all
   // elements below the diagonal are zero.
  for i := 0 to num - 2 do
  begin
    // Pivot this row (if necessary)
    Gauss_Pivot(matrix, num, vector, biggest_val, i);

//    Remark: Gauss_Pivot give never an error in the code.
//    if Gauss_Pivot(matrix, num, vector, biggest_val, i) =false then
//    begin
//      err_mess:='Gauss_matrix error: singular matrix.';
//      Exit(false);
//    end;

    if Abs(matrix[i][i] / biggest_val[i]) < MATRIX_TOL then
    begin
      err_mess:='Gauss_matrix error: row has a too tiny value';
      Exit(false);
    end;

    // Eliminate this variable in all rows below the current one
    for j := i + 1 to num - 1 do
    begin
      factor := matrix[j][i] / matrix[i][i];
      for k := i + 1 to num - 1 do
      begin
        matrix[j][k] := matrix[j][k] - factor * matrix[i][k];
      end;
      // And in the vector, too
      vector[j] := vector[j] - factor * vector[i];
    end;
  end;

  // Make sure that the last row's single remaining element isn't too tiny
  if Abs(matrix[num - 1][num - 1] / biggest_val[num - 1]) < MATRIX_TOL then
  begin
    err_mess:='Gauss_matrix error: last row has a too tiny value';
    Exit(false);
  end;

  //  Step 3: We can now calculate the solution_vector values
  //          via back-substitution; we start at the last value in the
  //          vector (at the "bottom" of the vector) and work
  //          upwards towards the top.
  solution_vector[num - 1] := vector[num - 1] / matrix[num - 1][num - 1];
  for i := num - 2 downto 0 do
  begin
      sum := 0.0;
      for j := i + 1 to num - 1 do
      begin
          sum := sum + matrix[i][j] * solution_vector[j];
      end;
      solution_vector[i] := (vector[i] - sum) / matrix[i][i];
  end;

  // step 4: okay, we've found the values in the solution vector!
  //         We now replace the input values in 'vector' with these
  //         solution_vector values, and we're done.
  for i := 0 to num-1 do begin
    vector[i] := solution_vector[i];
  end;
  Result:=true;
end;



  // /************************************************************************
  //  *
  //  *
  //  * ROUTINE: calc_trans_cubic
  //  *
  //  * DESCRIPTION:
  //  * Given a set of "nbright" matched pairs of stars, which we can
  //  * extract from the "winner_index" and "star_array" arrays,
  //  * figure out a TRANS structure which takes coordinates of
  //  * objects in set A and transforms then into coords for set B.
  //  * In this case, a TRANS contains the sixteen coefficients in the equations
  //  *
  //  *      x' =  A + Bx + Cy + Dxx + Exy + Fyy + Gx(xx+yy) + Hy(xx+yy)
  //  *      y' =  I + Jx + Ky + Lxx + Mxy + Nyy + Ox(xx+yy) + Py(xx+yy)
  //  *
  //  * where (x,y) are coords in set A and (x',y') are corresponding
  //  * coords in set B.
  //  *
  //  *
  //  * What we do is to treat each of the two equations above
  //  * separately.  We can write down 8 equations relating quantities
  //  * in the two sets of points (there are more than 8 such equations,
  //  * but we don't seek an exhaustive list).  For example,
  //  *
  //  *   x'    =  A    + Bx   + Cy    + Dxx   + Exy   +  Fyy   + GxR   + HyR
  //  *   x'x   =  Ax   + Bxx  + Cxy   + Dxxx  + Exxy  +  Fxyy  + GxxR  + HxyR
  //  *   x'y   =  Ay   + Bxy  + Cyy   + Dxxy  + Exyy  +  Fyyy  + GxyR  + HyyR
  //  *   x'xx  =  Axx  + Bxxx + Cxxy  + Dxxxx + Exxxy +  Fxxyy + GxxxR + HxxyR
  //  *   x'xy  =  Axy  + Bxxy + Cxyy  + Dxxxy + Exxyy +  Fxyyy + GxxyR + HxyyR
  //  *   x'yy  =  Ayy  + Bxyy + Cyyy  + Dxxyy + Exyyy +  Fyyyy + GxyyR + HyyyR
  //  *   x'xR  =  AxR  + BxxR + CxyR  + DxxxR + ExxyR +  FxyyR + GxxRR + HxyRR
  //  *   x'yR  =  AyR  + BxyR + CyyR  + DxxyR + ExyyR +  FyyyR + GxyRR + HyyRR
  //  *
  //  * (where we have used 'R' as an abbreviation for (xx + yy))
  //  *
  //  * Now, since we have "nbright" matched pairs, we can take each of
  //  * the above 8 equations and form the sums on both sides, over
  //  * all "nbright" points.  So, if S(x) represents the sum of the quantity
  //  * "x" over all nbright points, and if we let N=nbright, then
  //  *
  //  *  S(x')   =  AN     + BS(x)   + CS(y)   + DS(xx)   + ES(xy)   +  FS(yy)
  //  *                                                + GS(xR)   +  HS(yR)
  //  *  S(x'x)  =  AS(x)  + BS(xx)  + CS(xy)  + DS(xxx)  + ES(xxy)  +  FS(xyy)
  //  *                                                + GS(xxR)  +  HS(xyR)
  //  *  S(x'y)  =  AS(y)  + BS(xy)  + CS(yy)  + DS(xxy)  + ES(xyy)  +  FS(yyy)
  //  *                                                + GS(xyR)  +  HS(yyR)
  //  *  S(x'xx) =  AS(xx) + BS(xxx) + CS(xxy) + DS(xxxx) + ES(xxxy) +  FS(xxyy)
  //  *                                                + GS(xxxR) +  HS(xxyR)
  //  *  S(x'xy) =  AS(xy) + BS(xxy) + CS(xyy) + DS(xxxy) + ES(xxyy) +  FS(xyyy)
  //  *                                                + GS(xxyR) +  HS(xyyR)
  //  *  S(x'yy) =  AS(yy) + BS(xyy) + CS(yyy) + DS(xxyy) + ES(xyyy) +  FS(yyyy)
  //  *                                                + GS(xyyR) +  HS(yyyR)
  //  *  S(x'xR) =  AS(xR) + BS(xxR) + CS(xyR) + DS(xxxR) + ES(xxyR) +  FS(xyyR)
  //  *                                                + GS(xxRR) +  HS(xyRR)
  //  *  S(x'yR) =  AS(yR) + BS(xyR) + CS(yyR) + DS(xxyR) + ES(xyyR) +  FS(yyyR)
  //  *                                                + GS(xyRR) +  HS(yyRR)
  //  *
  //  * At this point, we have a set of 8 equations, and 8 unknowns:
  //  *        A, B, C, D, E, F, G, H
  //  *
  //  * We can write this set of equations as a matrix equation
  //  *
  //  *               b       = M * v
  //  *
  //  * where we KNOW the quantities
  //  *
  //  *  b = ( S(x'), S(x'x), S(x'y), S(x'xx), S(x'xy), S(x'yy), S(x'xR), S(x'rR) )
  //  *
  //  * matr M = [ N      S(x)    S(y)   S(xx)   S(xy)   S(yy)   S(xR)   S(yR)   ]
  //  *          [ S(x)   S(xx)   S(xy)  S(xxx)  S(xxy)  S(xyy)  S(xxR)  S(xyR)  ]
  //  *          [ S(y)   S(xy)   S(yy)  S(xxy)  S(xyy)  S(yyy)  S(xyR)  S(yyR)  ]
  //  *          [ S(xx)  S(xxx)  S(xxy) S(xxxx) S(xxxy) S(xxyy) S(xxxR) S(xxyR) ]
  //  *          [ S(xy)  S(xxy)  S(xyy) S(xxxy) S(xxyy) S(xyyy) S(xxyR) S(xyyR) ]
  //  *          [ S(yy)  S(xyy)  S(yyy) S(xxyy) S(xyyy) S(yyyy) S(xyyR) S(yyyR) ]
  //  *          [ S(xR)  S(xxR)  S(xyR) S(xxxR) S(xxyR) S(xyyR) S(xxRR) S(xyRR) ]
  //  *          [ S(yR)  S(xyR)  S(yyR) S(xxyR) S(xyyR) S(yyyR) S(xyRR) S(yyRR) ]
  //  *
  //  * and we want to FIND the unknown
  //  *
  //  *        vector v = ( A,     B,      C,     D,      E,      F,     G,     H )
  //  *
  //  * So, how to solve this matrix equation?  We use a Gaussian-elimination
  //  * method (see notes in 'gauss_matrix' function).   We solve
  //  * for A, B, C, D, E, F, G, H (and equivalently for I, J, K, L, M, N, O, P),
  //  * then fill in the fields
  //  * of the given TRANS structure argument.
  //  *
  //  * It's possible that the matrix will be singular, and we can't find
  //  * a solution.  In that case, we print an error message and don't touch
  //  * the TRANS' fields.
  //  *
  //  *    [should explain how we make an iterative solution here,
  //  *     but will put in comments later.  MWR ]
  //  *
  //  * RETURN:
  //  *    SH_SUCCESS           if all goes well
  //  *    SH_GENERIC_ERROR     if we can't find a solution
  //  *
  //  * </AUTO>
  //  */


function Calc_Trans_Cubic(stars_reference: TStarArray; // First array of s_star structure we match the output TRANS takes their coords into those of array B
                          stars_distorted: TStarArray; // Second array of s_star structure we match
                          out trans: TTrans; // Transfer coefficients for starsA positions to starsB positions
                          out err_mess : string   // any error message
                           ): boolean; //succes

var
  matrix      : Tmatrix;
  vector      : Tsolutionvector;//array[0..9] of Double;
  s1,
  s2          : s_star;
  sumx2,
  sumx2x1,
  sumx2y1,
  sumx2x1sq,
  sumx2x1y1,
  sumx2y1sq,
  sumx2x1cu,
  sumx2x1sqy1,
  sumx2x1y1sq,
  sumx2y1cu,
  sumy2,
  sumy2x1,
  sumy2y1,
  sumy2x1sq,
  sumy2x1y1,
  sumy2y1sq,
  sumy2x1cu,
  sumy2x1sqy1,
  sumy2x1y1sq,
  sumy2y1cu,
  sum,
  sumx1,
  sumy1,
  sumx1sq,
  sumx1y1,
  sumy1sq,
  sumx1cu,
  sumx1sqy1,
  sumx1y1sq,
  sumy1cu,
  sumx1qu,
  sumx1cuy1,
  sumx1sqy1sq,
  sumx1y1cu,
  sumy1qu,
  sumx1pe,
  sumx1quy1,
  sumx1cuy1sq,
  sumx1sqy1cu,
  sumx1y1qu,
  sumy1pe,
  sumx1he,
  sumx1pey1,
  sumx1quy1sq,
  sumx1cuy1cu,
  sumx1sqy1qu,
  sumx1y1pe,
  sumy1he     : Double;
  r,c,i       : integer;
begin
   // in variable names below, a '1' refers to coordinate of star s1 (which appear on both sides of the matrix equation)
   //                      and a '2' refers to coordinate of star s2 (which appears only on left hand side of matrix equation)

   err_mess:=''; //clear message;
   if length(stars_reference) <10 {AT_MATCH_REQUIRE_CUBIC} then begin err_mess:='Calc_Trans_Cubic: Not enough equations.'; exit(false); end;

   // if_assert(trans.order = AT_TRANS_CUBIC)=false then begin result:=0; exit; end;
   // allocate a matrix we'll need for this function

  SetLength(matrix, 10, 10); // Assuming a 10x10 matrix

  // First, we consider the coefficients x00,x10,x01,x20,x11,x02,x30,x21,x12,x03 in the trans.
  // We form the sums that make up the elements of matrix M
  sum := 0.0;
  sumx1 := 0.0;
  sumy1 := 0.0;
  sumx1sq := 0.0;
  sumx1y1 := 0.0;
  sumy1sq := 0.0;
  sumx1cu := 0.0;
  sumx1sqy1 := 0.0;
  sumx1y1sq := 0.0;
  sumy1cu := 0.0;
  sumx1qu := 0.0;
  sumx1cuy1 := 0.0;
  sumx1sqy1sq := 0.0;
  sumx1y1cu := 0.0;
  sumy1qu := 0.0;
  sumx1pe := 0.0;
  sumx1quy1 := 0.0;
  sumx1cuy1sq := 0.0;
  sumx1sqy1cu := 0.0;
  sumx1y1qu := 0.0;
  sumy1pe := 0.0;
  sumx1he := 0.0;
  sumx1pey1 := 0.0;
  sumx1quy1sq := 0.0;
  sumx1cuy1cu := 0.0;
  sumx1sqy1qu := 0.0;
  sumx1y1pe := 0.0;
  sumy1he := 0.0;
  sumx2 := 0.0;
  sumx2x1 := 0.0;
  sumx2y1 := 0.0;
  sumx2x1sq := 0.0;
  sumx2x1y1 := 0.0;
  sumx2y1sq := 0.0;
  sumx2x1cu := 0.0;
  sumx2x1sqy1 := 0.0;
  sumx2x1y1sq := 0.0;
  sumx2y1cu := 0.0;
  sumy2 := 0.0;
  sumy2x1 := 0.0;
  sumy2y1 := 0.0;
  sumy2x1sq := 0.0;
  sumy2x1y1 := 0.0;
  sumy2y1sq := 0.0;
  sumy2x1cu := 0.0;
  sumy2x1sqy1 := 0.0;
  sumy2x1y1sq := 0.0;
  sumy2y1cu := 0.0;
  for i := 0 to min(length(stars_reference)-1,length(stars_distorted)-1) do //take the minimum of the two array for the case one list is longer. Should not happen normally.
  begin
    sumx2        := sumx2       + stars_distorted[i].x;
    sumx2x1      := sumx2x1     + (stars_distorted[i].x * stars_reference[i].x);
    sumx2y1      := sumx2y1     + (stars_distorted[i].x * stars_reference[i].y);
    sumx2x1sq    := sumx2x1sq   + (stars_distorted[i].x * stars_reference[i].x * stars_reference[i].x);
    sumx2x1y1    := sumx2x1y1   + (stars_distorted[i].x * stars_reference[i].x * stars_reference[i].y);
    sumx2y1sq    := sumx2y1sq   + (stars_distorted[i].x * stars_reference[i].y * stars_reference[i].y);
    sumx2x1cu    := sumx2x1cu   + (stars_distorted[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x);
    sumx2x1sqy1  := sumx2x1sqy1 + (stars_distorted[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].y);
    sumx2x1y1sq  := sumx2x1y1sq + (stars_distorted[i].x * stars_reference[i].x * stars_reference[i].y * stars_reference[i].y);
    sumx2y1cu    := sumx2y1cu   + (stars_distorted[i].x * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
    sumy2        := sumy2       + stars_distorted[i].y;
    sumy2x1      := sumy2x1     + (stars_distorted[i].y * stars_reference[i].x);
    sumy2y1      := sumy2y1     + (stars_distorted[i].y * stars_reference[i].y);
    sumy2x1sq    := sumy2x1sq   + (stars_distorted[i].y * stars_reference[i].x * stars_reference[i].x);
    sumy2x1y1    := sumy2x1y1   + (stars_distorted[i].y * stars_reference[i].x * stars_reference[i].y);
    sumy2y1sq    := sumy2y1sq   + (stars_distorted[i].y * stars_reference[i].y * stars_reference[i].y);
    sumy2x1cu    := sumy2x1cu   + (stars_distorted[i].y * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x);
    sumy2x1sqy1  := sumy2x1sqy1 + (stars_distorted[i].y * stars_reference[i].x * stars_reference[i].x * stars_reference[i].y);
    sumy2x1y1sq  := sumy2x1y1sq + (stars_distorted[i].y * stars_reference[i].x * stars_reference[i].y * stars_reference[i].y);
    sumy2y1cu    := sumy2y1cu   + (stars_distorted[i].y * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
    { elements of the matrix }
    sum    := sum   + 1.0;
    sumx1  := sumx1 + stars_reference[i].x;
    sumy1  := sumy1 + stars_reference[i].y;
    sumx1sq  := sumx1sq + (stars_reference[i].x * stars_reference[i].x);
    sumx1y1  := sumx1y1 + (stars_reference[i].x * stars_reference[i].y);
    sumy1sq  := sumy1sq + (stars_reference[i].y * stars_reference[i].y);
    sumx1cu    := sumx1cu   + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].x);
    sumx1sqy1  := sumx1sqy1 + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].y);
    sumx1y1sq  := sumx1y1sq + (stars_reference[i].x * stars_reference[i].y * stars_reference[i].y);
    sumy1cu    := sumy1cu   + (stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
    sumx1qu      := sumx1qu     + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x);
    sumx1cuy1    := sumx1cuy1   + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].y);
    sumx1sqy1sq  := sumx1sqy1sq + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].y * stars_reference[i].y);
    sumx1y1cu    := sumx1y1cu   + (stars_reference[i].x * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
    sumy1qu      := sumy1qu     + (stars_reference[i].y * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
    sumx1pe      := sumx1pe     + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x);
    sumx1quy1    := sumx1quy1   + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].y);
    sumx1cuy1sq  := sumx1cuy1sq + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].y * stars_reference[i].y);
    sumx1sqy1cu  := sumx1sqy1cu + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
    sumx1y1qu    := sumx1y1qu   + (stars_reference[i].x * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
    sumy1pe      := sumy1pe     + (stars_reference[i].y * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
    sumx1he      := sumx1he     + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x);
    sumx1pey1    := sumx1pey1   + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].y);
    sumx1quy1sq  := sumx1quy1sq + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].y * stars_reference[i].y);
    sumx1cuy1cu  := sumx1cuy1cu + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].x * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
    sumx1sqy1qu  := sumx1sqy1qu + (stars_reference[i].x * stars_reference[i].x * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
    sumx1y1pe    := sumx1y1pe   + (stars_reference[i].x * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
    sumy1he      := sumy1he     + (stars_reference[i].y * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y * stars_reference[i].y);
  end;

  // Now turn these sums into a matrix and a vector
  // For the matrix, we fill the lower triangle and then transpose for the upper one rows 0-9 - column 0
  matrix[0][0] := sum;
  matrix[1][0] := sumx1;
  matrix[2][0] := sumy1;
  matrix[3][0] := sumx1sq;
  matrix[4][0] := sumx1y1;
  matrix[5][0] := sumy1sq;
  matrix[6][0] := sumx1cu;
  matrix[7][0] := sumx1sqy1;
  matrix[8][0] := sumx1y1sq;
  matrix[9][0] := sumy1cu;
  //rows 1-9 - column 1
  matrix[1][1] := sumx1sq;
  matrix[2][1] := sumx1y1;
  matrix[3][1] := sumx1cu;
  matrix[4][1] := sumx1sqy1;
  matrix[5][1] := sumx1y1sq;
  matrix[6][1] := sumx1qu;
  matrix[7][1] := sumx1cuy1;
  matrix[8][1] := sumx1sqy1sq;
  matrix[9][1] := sumx1y1cu;
  //rows 2-9 - column 2
  matrix[2][2] := sumy1sq;
  matrix[3][2] := sumx1sqy1;
  matrix[4][2] := sumx1y1sq;
  matrix[5][2] := sumy1cu;
  matrix[6][2] := sumx1cuy1;
  matrix[7][2] := sumx1sqy1sq;
  matrix[8][2] := sumx1y1cu;
  matrix[9][2] := sumy1qu;
  //rows 3-9 - column 3
  matrix[3][3] := sumx1qu;
  matrix[4][3] := sumx1cuy1;
  matrix[5][3] := sumx1sqy1sq;
  matrix[6][3] := sumx1pe;
  matrix[7][3] := sumx1quy1;
  matrix[8][3] := sumx1cuy1sq;
  matrix[9][3] := sumx1sqy1cu;
  //rows 4-9 - column 4
  matrix[4][4] := sumx1sqy1sq;
  matrix[5][4] := sumx1y1cu;
  matrix[6][4] := sumx1quy1;
  matrix[7][4] := sumx1cuy1sq;
  matrix[8][4] := sumx1sqy1cu;
  matrix[9][4] := sumx1y1qu;
  //rows 5-9 - column 5
  matrix[5][5] := sumy1qu;
  matrix[6][5] := sumx1cuy1sq;
  matrix[7][5] := sumx1sqy1cu;
  matrix[8][5] := sumx1y1qu;
  matrix[9][5] := sumy1pe;
  //rows 6-9 - column 6
  matrix[6][6] := sumx1he;
  matrix[7][6] := sumx1pey1;
  matrix[8][6] := sumx1quy1sq;
  matrix[9][6] := sumx1cuy1cu;
  //rows 7-9 - column 7
  matrix[7][7] := sumx1quy1sq;
  matrix[8][7] := sumx1cuy1cu;
  matrix[9][7] := sumx1sqy1qu;
  //rows 8-9 - column 8
  matrix[8][8] := sumx1sqy1qu;
  matrix[9][8] := sumx1y1pe;
  //rows 9 - column 9
  matrix[9][9] := sumy1he;
  // and we transpose
  for r := 0 to 8 do begin
    for c := r + 1 to 9 do begin
      matrix[r][c] := matrix[c][r];
    end;
  end;
  vector[0] := sumx2;
  vector[1] := sumx2x1;
  vector[2] := sumx2y1;
  vector[3] := sumx2x1sq;
  vector[4] := sumx2x1y1;
  vector[5] := sumx2y1sq;
  vector[6] := sumx2x1cu;
  vector[7] := sumx2x1sqy1;
  vector[8] := sumx2x1y1sq;
  vector[9] := sumx2y1cu;
  //Writeln('before calling solution routines for ABCDEFGHIJ, here's matrix');

  // and now call the Gaussian-elimination routines to solve the matrix.
  // The solution for TRANS coefficients A, B, C, D, E, F, I, J will be placed
  // into the elements on 'vector" after "gauss_matrix' finishes.
  if gauss_matrix(matrix, 10, vector,err_mess)=false then
  begin
    err_mess:=err_mess+', Calc_trans_cubic: can not solve for coeffs A,B,C,D,E,F,G,H,I,J';
    exit(false);
  end;
  //Writeln('after calling solution routines, here's matrix');

  trans.x00 := vector[0];
  trans.x10 := vector[1];
  trans.x01 := vector[2];
  trans.x20 := vector[3];
  trans.x11 := vector[4];
  trans.x02 := vector[5];
  trans.x30 := vector[6];
  trans.x21 := vector[7];
  trans.x12 := vector[8];
  trans.x03 := vector[9];

  // Okay, now we solve for TRANS coefficients y00,y10,y01,y20,y11,y02,y30,y21,y12,y03
  // using the * set of equations that relates y' to (x,y)

  //rows 0-9 - column 0
  matrix[0][0] := sum;
  matrix[1][0] := sumx1;
  matrix[2][0] := sumy1;
  matrix[3][0] := sumx1sq;
  matrix[4][0] := sumx1y1;
  matrix[5][0] := sumy1sq;
  matrix[6][0] := sumx1cu;
  matrix[7][0] := sumx1sqy1;
  matrix[8][0] := sumx1y1sq;
  matrix[9][0] := sumy1cu;
  //rows 1-9 - column 1
  matrix[1][1] := sumx1sq;
  matrix[2][1] := sumx1y1;
  matrix[3][1] := sumx1cu;
  matrix[4][1] := sumx1sqy1;
  matrix[5][1] := sumx1y1sq;
  matrix[6][1] := sumx1qu;
  matrix[7][1] := sumx1cuy1;
  matrix[8][1] := sumx1sqy1sq;
  matrix[9][1] := sumx1y1cu;
  //rows 2-9 - column 2
  matrix[2][2] := sumy1sq;
  matrix[3][2] := sumx1sqy1;
  matrix[4][2] := sumx1y1sq;
  matrix[5][2] := sumy1cu;
  matrix[6][2] := sumx1cuy1;
  matrix[7][2] := sumx1sqy1sq;
  matrix[8][2] := sumx1y1cu;
  matrix[9][2] := sumy1qu;
  //rows 3-9 - column 3
  matrix[3][3] := sumx1qu;
  matrix[4][3] := sumx1cuy1;
  matrix[5][3] := sumx1sqy1sq;
  matrix[6][3] := sumx1pe;
  matrix[7][3] := sumx1quy1;
  matrix[8][3] := sumx1cuy1sq;
  matrix[9][3] := sumx1sqy1cu;
  //rows 4-9 - column 4
  matrix[4][4] := sumx1sqy1sq;
  matrix[5][4] := sumx1y1cu;
  matrix[6][4] := sumx1quy1;
  matrix[7][4] := sumx1cuy1sq;
  matrix[8][4] := sumx1sqy1cu;
  matrix[9][4] := sumx1y1qu;
  //rows 5-9 - column 5
  matrix[5][5] := sumy1qu;
  matrix[6][5] := sumx1cuy1sq;
  matrix[7][5] := sumx1sqy1cu;
  matrix[8][5] := sumx1y1qu;
  matrix[9][5] := sumy1pe;
  //rows 6-9 - column 6
  matrix[6][6] := sumx1he;
  matrix[7][6] := sumx1pey1;
  matrix[8][6] := sumx1quy1sq;
  matrix[9][6] := sumx1cuy1cu;
  //rows 7-9 - column 7
  matrix[7][7] := sumx1quy1sq;
  matrix[8][7] := sumx1cuy1cu;
  matrix[9][7] := sumx1sqy1qu;
  //rows 8-9 - column 8
  matrix[8][8] := sumx1sqy1qu;
  matrix[9][8] := sumx1y1pe;
  //rows 9 - column 9
  matrix[9][9] := sumy1he;
  // and we transpose
  for r := 0 to 8 do begin
    for c := r + 1 to 9 do begin
      matrix[r][c] := matrix[c][r];
    end;
  end;
  vector[0] := sumy2;
  vector[1] := sumy2x1;
  vector[2] := sumy2y1;
  vector[3] := sumy2x1sq;
  vector[4] := sumy2x1y1;
  vector[5] := sumy2y1sq;
  vector[6] := sumy2x1cu;
  vector[7] := sumy2x1sqy1;
  vector[8] := sumy2x1y1sq;
  vector[9] := sumy2y1cu;

  //  And now call the Gaussian-elimination routines to solve the matrix.
  if gauss_matrix(matrix, 10, vector,err_mess)=false then
  begin
    err_mess:=err_mess+', Calc_trans_cubic: Can not solve for coeffs y00,y10,y01,y20,y11,y02,y30,y21,y12,y03';
    exit(false);
  end;
  //Writeln('after  calling solution routines, here's matrix');
  //  const   A,K  00
  //  x;      B,L  10
  //  y;      C,M  01
  //  x*x;    D,N  20
  //  x*y;    E,O  11
  //  y*y;    F,P  02
  //  x*x*x;  G,Q  30
  //  x*x*y;  H,R  21
  //  x*y*y;  I,S  12
  //  y*y*y;  J,T  03

  trans.y00 := vector[0];
  trans.y10 := vector[1];
  trans.y01 := vector[2];
  trans.y20 := vector[3];
  trans.y11 := vector[4];
  trans.y02 := vector[5];
  trans.y30 := vector[6];
  trans.y21 := vector[7];
  trans.y12 := vector[8];
  trans.y03 := vector[9];
  //free_matrix(matrix, 10);//Not required in FPC
  Result :=true;
end;



   // TEST PROGRAM FOR DEVELOPMENT ONLY ==================================================================================
{
procedure rotate(rot,x,y :double;var  x2,y2:double);//rotate a vector point, angle seen from y-axis, counter clockwise
var
  sin_rot, cos_rot :double;
begin
  sincos(rot, sin_rot, cos_rot);
  x2:=x * + sin_rot + y*cos_rot;//ROTATION MOON AROUND CENTER OF PLANET
  y2:=x * - cos_rot + y*sin_rot;//SEE PRISMA WIS VADEMECUM BLZ 68
end;

var
  b : TVector;
  i,j,k, count                                 : Integer;
  x,y,x2,y2,testx,testy, maxerrorX,maxerrorY,correction,errorposX,errorposY: Double;

  distorted,reference,ideal:  TStarArray;
  trans:  TTrans;
  sss : string;
  f: textfile;


begin
  count:=0;
  setlength(distorted,50);
  setlength(reference,50);
//  setlength(ideal,10000);
  for j:=1 to +10 do
  begin
    for i:=1 to +10 do
    begin
      //x:=j*150;//image 3000x3000
      //y:=i*150;

      reference[count].x:=i;//reference X
      reference[count].y:=j;//reference X

      distorted[count].x:=i+1000+i*i*0.00001+i*j*0.00002+j*j*0.00003+i*i*i*0.00004+i*i*j*0.00005+i*j*j*0.00006+j*j*j*0.00007;
      distorted[count].y:=j+1000+i*i*0.00008+i*j*0.00009+j*j*0.00010+i*i*i*0.00011+i*i*j*0.00012+i*j*j*0.00013+j*j*j*0.00014;
      inc(count);
      if count>=length(distorted) then break;
    end;
    if count>=length(distorted) then break;
  end;
  setlength(distorted,count);
  setlength(reference,count);



 //TESTING ============


   if Calc_Trans_Cubic(reference, // First array of s_star structure we match the output TRANS takes their coords into those of array B
                       distorted, // Second array of s_star structure we match
                      trans, // Place solved coefficients into this  existing structure's fields
                      sss
                       )=false

   then
     beep  //failure
   else
   //succes

    beep;
// const   A,K
//  x;      B,L
//  y;      C,M
//  x*x;    D,N
//  x*y;    E,O
//  y*y;    F,P
//  x*x*x;  G,Q
//  x*x*y;  H,R
//  x*y*y;  I,S
//  y*y*y;  J,T

    // log_to_file( 'c:\temp\test.txt',floattostr(reference[i].x)+#9+floattostr(reference[i].y)+#9+floattostr(testX)+#9+floattostr(testY));
   beep;
   }
end.

