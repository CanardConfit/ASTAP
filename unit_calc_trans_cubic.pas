unit unit_calc_trans_cubic;
{ This unit is based on some C language routines from the package Match. See describtion below. Conversion and modification for the ASTAP program by Han Kleijn
The original Match version was suitable for 2th order only but extend to the 3th order by Cecile for the Siril program.

DESCRIPTION:
  //  This unit calculated the 3th order transfer function between two set of matching quads or star positions.
  //  The output are ten transfer coefficients for X axis and ten coefficients for the Y-axis.


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


//original describtion for the Match program.
{ *  match: a package to match lists of stars (or other items)
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
             a, b, c, d, e, f, g, h, i, j: Double;
             k, l, m, n, o, p, q, r, s, t: Double;
           end;

function Calc_Trans_Cubic(starsA: TStarArray; // First array of s_star structure we match the output TRANS takes their coords into those of array B
                          starsB: TStarArray; // Second array of s_star structure we match
                          var trans: TTrans   // Place solved coefficients into this  existing structure's fields
                         ): Integer;


implementation

type
  Tsolutionvector = array[0..9] of Double;

const
    SH_SUCCESS=1;
    SH_GENERIC_ERROR=0;
    MATRIX_TOL=1E-10;


procedure memo2_message(s: string);
begin
  beep;
end;


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
function GaussPivot(var matrix: TMatrix;          // I/O: a square 2-D matrix we are inverting
                    num: Integer;                 // I: number of rows and cols in matrix
                    var vector: TSolutionVector;  // I/O: vector which holds "b" values in input
                    var biggest_val: TVector;     // I: largest value in each row of matrix
                    row: Integer                  // I: want to pivot around this row
                   ): Integer;
var
  i, col, pivot_row  : Integer;
  big, other_big,temp: Double;

begin
  result:=0;

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

  Result := SH_SUCCESS; // Assuming SH_SUCCESS is a predefined constant for success
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
                      var vector: Tsolutionvector  // I/O: vector which holds "b" values in input and the solution vector "x" on output
                      ): Integer;

var
  i,
  j,
  k               : integer;
  biggest_val: TVector;
  solution_vector: TVector;
  factor,
  sum             : Double;
begin
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
      memo2_message('Gauss_matrix: biggest val in row is zero');
      exit;
    end;
  end;
   // Step 2: Use Gaussian elimination to convert the "matrix"
   // into a triangular matrix, in which the values of all
   // elements below the diagonal are zero.
  for i := 0 to num - 2 do
  begin
    // Pivot this row (if necessary)
    if GaussPivot(matrix, num, vector, biggest_val, i) = SH_GENERIC_ERROR then
    begin
      // Handle error: "gauss_matrix: singular matrix"
      // Error handling code should go here. In Pascal, you might raise an exception
      Exit(SH_GENERIC_ERROR); // Assuming SH_GENERIC_ERROR is an error code
    end;

    if Abs(matrix[i][i] / biggest_val[i]) < MATRIX_TOL then
    begin
      // Handle error: "gauss_matrix: row has tiny value"
      Exit(SH_GENERIC_ERROR); // Replace with appropriate error handling
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
    // Handle error: "gauss_matrix: last row has tiny value"
    // In Pascal, you might raise an exception or handle the error in a way that's
    // appropriate for your application.
    Exit(SH_GENERIC_ERROR); // Replace with appropriate error handling
  end;

  // * Step 3: We can now calculate the solution_vector values
  // *         via back-substitution; we start at the last value in the
  // *         vector (at the "bottom" of the vector) and work
  // *         upwards towards the top.
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
  Result := SH_SUCCESS;
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


function Calc_Trans_Cubic(starsA: TStarArray; // First array of s_star structure we match the output TRANS takes their coords into those of array B
                          starsB: TStarArray; // Second array of s_star structure we match
                          var trans: TTrans // Place solved coefficients into this  existing structure's fields
                         ): Integer;

var
  i           : integer;
  matrix      : Tmatrix;
  vector      : Tsolutionvector;//array[0..9] of Double;
  solved_a,
  solved_b,
  solved_c,
  solved_d,
  solved_e,
  solved_f,
  solved_g,
  solved_h,
  solved_i,
  solved_j,
  solved_k,
  solved_l,
  solved_m,
  solved_n,
  solved_o,
  solved_p,
  solved_q,
  solved_r,
  solved_s,
  solved_t    : Double;
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
  r,c,wa,wb    : integer;
begin
   //* in variable names below, a '1' refers to coordinate of star s1
   //*   (which appear on both sides of the matrix equation)
   //*                      and a '2' refers to coordinate of star s2
   //*   (which appears only on left hand side of matrix equation)    o

   if length(starsA) <10 {AT_MATCH_REQUIRE_CUBIC} then begin result:=0; exit; end;

   //  if_assert(trans.order = AT_TRANS_CUBIC)=false then begin result:=0; exit; end;
   //* allocate a matrix we'll need for this function

  SetLength(matrix, 10, 10); // Assuming a 10x10 matrix

  // * first, we consider the coefficients A, B, C, D, E, F, G, H, I, J in the trans.
  // * we form the sums that make up the elements of matrix M
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
  for i := 0 to length(starsA)-1 do begin
    { sanity checks }

    wa:=i;  //note removed winner_index_A and winner_index_B from the code
    wb:=min(i,length(starsB)-1);//should not be required but just in case.
//    if winner_index_A[i] < length(starsA) then begin result:=0;exit;end;;
//    s1 := @star_array_A[winner_index_A[i]];
//    if winner_index_B[i] < length(starsB) then begin result:=0;exit;end;;
//    s2 := @(star_array_B[winner_index_B[i]]);
    sumx2        := sumx2       + starsB[wb].x;
    sumx2x1      := sumx2x1     + (starsB[wb].x * starsA[wa].x);
    sumx2y1      := sumx2y1     + (starsB[wb].x * starsA[wa].y);
    sumx2x1sq    := sumx2x1sq   + (starsB[wb].x * starsA[wa].x * starsA[wa].x);
    sumx2x1y1    := sumx2x1y1   + (starsB[wb].x * starsA[wa].x * starsA[wa].y);
    sumx2y1sq    := sumx2y1sq   + (starsB[wb].x * starsA[wa].y * starsA[wa].y);
    sumx2x1cu    := sumx2x1cu   + (starsB[wb].x * starsA[wa].x * starsA[wa].x * starsA[wa].x);
    sumx2x1sqy1  := sumx2x1sqy1 + (starsB[wb].x * starsA[wa].x * starsA[wa].x * starsA[wa].y);
    sumx2x1y1sq  := sumx2x1y1sq + (starsB[wb].x * starsA[wa].x * starsA[wa].y * starsA[wa].y);
    sumx2y1cu    := sumx2y1cu   + (starsB[wb].x * starsA[wa].y * starsA[wa].y * starsA[wa].y);
    sumy2        := sumy2       + starsB[wb].y;
    sumy2x1      := sumy2x1     + (starsB[wb].y * starsA[wa].x);
    sumy2y1      := sumy2y1     + (starsB[wb].y * starsA[wa].y);
    sumy2x1sq    := sumy2x1sq   + (starsB[wb].y * starsA[wa].x * starsA[wa].x);
    sumy2x1y1    := sumy2x1y1   + (starsB[wb].y * starsA[wa].x * starsA[wa].y);
    sumy2y1sq    := sumy2y1sq   + (starsB[wb].y * starsA[wa].y * starsA[wa].y);
    sumy2x1cu    := sumy2x1cu   + (starsB[wb].y * starsA[wa].x * starsA[wa].x * starsA[wa].x);
    sumy2x1sqy1  := sumy2x1sqy1 + (starsB[wb].y * starsA[wa].x * starsA[wa].x * starsA[wa].y);
    sumy2x1y1sq  := sumy2x1y1sq + (starsB[wb].y * starsA[wa].x * starsA[wa].y * starsA[wa].y);
    sumy2y1cu    := sumy2y1cu   + (starsB[wb].y * starsA[wa].y * starsA[wa].y * starsA[wa].y);
    { elements of the matrix }
    sum    := sum   + 1.0;
    sumx1  := sumx1 + starsA[wa].x;
    sumy1  := sumy1 + starsA[wa].y;
    sumx1sq  := sumx1sq + (starsA[wa].x * starsA[wa].x);
    sumx1y1  := sumx1y1 + (starsA[wa].x * starsA[wa].y);
    sumy1sq  := sumy1sq + (starsA[wa].y * starsA[wa].y);
    sumx1cu    := sumx1cu   + (starsA[wa].x * starsA[wa].x * starsA[wa].x);
    sumx1sqy1  := sumx1sqy1 + (starsA[wa].x * starsA[wa].x * starsA[wa].y);
    sumx1y1sq  := sumx1y1sq + (starsA[wa].x * starsA[wa].y * starsA[wa].y);
    sumy1cu    := sumy1cu   + (starsA[wa].y * starsA[wa].y * starsA[wa].y);
    sumx1qu      := sumx1qu     + (starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].x);
    sumx1cuy1    := sumx1cuy1   + (starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].y);
    sumx1sqy1sq  := sumx1sqy1sq + (starsA[wa].x * starsA[wa].x * starsA[wa].y * starsA[wa].y);
    sumx1y1cu    := sumx1y1cu   + (starsA[wa].x * starsA[wa].y * starsA[wa].y * starsA[wa].y);
    sumy1qu      := sumy1qu     + (starsA[wa].y * starsA[wa].y * starsA[wa].y * starsA[wa].y);
    sumx1pe      := sumx1pe     + (starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].x);
    sumx1quy1    := sumx1quy1   + (starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].y);
    sumx1cuy1sq  := sumx1cuy1sq + (starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].y * starsA[wa].y);
    sumx1sqy1cu  := sumx1sqy1cu + (starsA[wa].x * starsA[wa].x * starsA[wa].y * starsA[wa].y * starsA[wa].y);
    sumx1y1qu    := sumx1y1qu   + (starsA[wa].x * starsA[wa].y * starsA[wa].y * starsA[wa].y * starsA[wa].y);
    sumy1pe      := sumy1pe     + (starsA[wa].y * starsA[wa].y * starsA[wa].y * starsA[wa].y * starsA[wa].y);
    sumx1he      := sumx1he     + (starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].x);
    sumx1pey1    := sumx1pey1   + (starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].y);
    sumx1quy1sq  := sumx1quy1sq + (starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].y * starsA[wa].y);
    sumx1cuy1cu  := sumx1cuy1cu + (starsA[wa].x * starsA[wa].x * starsA[wa].x * starsA[wa].y * starsA[wa].y * starsA[wa].y);
    sumx1sqy1qu  := sumx1sqy1qu + (starsA[wa].x * starsA[wa].x * starsA[wa].y * starsA[wa].y * starsA[wa].y * starsA[wa].y);
    sumx1y1pe    := sumx1y1pe   + (starsA[wa].x * starsA[wa].y * starsA[wa].y * starsA[wa].y * starsA[wa].y * starsA[wa].y);
    sumy1he      := sumy1he     + (starsA[wa].y * starsA[wa].y * starsA[wa].y * starsA[wa].y * starsA[wa].y * starsA[wa].y);
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

  // * and now call the Gaussian-elimination routines to solve the matrix.
  // * The solution for TRANS coefficients A, B, C, D, E, F, I, J will be placed
  // * into the elements on 'vector" after "gauss_matrix' finishes.
  if gauss_matrix(matrix, 10, vector) <> SH_SUCCESS then
  begin
    memo2_message('calc_trans_cubic: can not solve for coeffs A,B,C,D,E,F,G,H,I,J');
    //free_matrix(matrix, 10);
    exit(SH_GENERIC_ERROR);
  end;
  //Writeln('after calling solution routines, here's matrix');
  solved_a := vector[0];
  solved_b := vector[1];
  solved_c := vector[2];
  solved_d := vector[3];
  solved_e := vector[4];
  solved_f := vector[5];
  solved_g := vector[6];
  solved_h := vector[7];
  solved_i := vector[8];
  solved_j := vector[9];

  //* Okay, now we solve for TRANS coefficients K, L, M, N, O, P, Q, R, S, T
  //* using the * set of equations that relates y' to (x,y)

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

  //  Writeln('before calling solution routines for KLMNOPQRST, here's matrix');

  //* and now call the Gaussian-elimination routines to solve the matrix.
  // * The solution for TRANS coefficients K, L, M, N, O, P, Q, R, S, T will be placed
  // * into the elements on 'vector" after "gauss_matrix' finishes.
  if gauss_matrix(matrix, 10, vector)<> SH_SUCCESS then
  begin
    memo2_message('Calc_trans_cubic: can not solve for coeffs K,L,M,N,O,P,Q,R,S,T');
    //free_matrix(matrix, 10);
    exit(SH_GENERIC_ERROR);
  end;
  //Writeln('after  calling solution routines, here's matrix');
  solved_k := vector[0];
  solved_l := vector[1];
  solved_m := vector[2];
  solved_n := vector[3];
  solved_o := vector[4];
  solved_p := vector[5];
  solved_q := vector[6];
  solved_r := vector[7];
  solved_s := vector[8];
  solved_t := vector[9];

  //* assign the coefficients we've just calculated to the output TRANS structure.
  trans.a := solved_a;
  trans.b := solved_b;
  trans.c := solved_c;
  trans.d := solved_d;
  trans.e := solved_e;
  trans.f := solved_f;
  trans.g := solved_g;
  trans.h := solved_h;
  trans.i := solved_i;
  trans.j := solved_j;
  trans.k := solved_k;
  trans.l := solved_l;
  trans.m := solved_m;
  trans.n := solved_n;
  trans.o := solved_o;
  trans.p := solved_p;
  trans.q := solved_q;
  trans.r := solved_r;
  trans.s := solved_s;
  trans.t := solved_t;
  //free_matrix(matrix, 10);
  Result := (SH_SUCCESS);
end;

{ TEST PROGRAM FOR DEVELOPMENT ONLY

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
  x,y,x2,y2,testx,testy, maxerrorX,maxerrorY,maxcorrectionX,maxcorrectionY,correction,errorposX,errorposY: Double;

  asw,bb:  TStarArray;
  trans:  TTrans;
  AP_0_0,  AP_0_1,AP_0_2, AP_0_3, AP_1_0, AP_1_1,AP_1_2, AP_2_0, AP_2_1, AP_3_0, BP_0_0, BP_0_1, BP_0_2, BP_0_3, BP_1_0, BP_1_1, BP_1_2, BP_2_0, BP_2_1, BP_3_0 : double;

begin
  count:=0;
  setlength(asw,10000);
  setlength(bb,10000);

  for i:=-10 to +10 do
  for j:=-10 to +10 do
  if ((j<>0) and (i<>0) ) then
  begin
    x:=j*100;//image 2000x2000
    y:=i*100;

    bb[count].x:=x+1000;//reference X
    bb[count].y:=x+500;//reference X

    rotate(pi*30/180,x,y, x2,y2);
    x:=x2;
    y:=y2;


    AP_0_0  :=      0.0124162099556 ;
    AP_0_1  :=   -9.16796068412E-08 ;
    AP_0_2  :=   -1.96540746616E-07 ;
    AP_0_3  :=    1.74034956318E-11 ;
    AP_1_0  :=    -0.00011307711845 ;
    AP_1_1  :=    1.20978402726E-07 ;
    AP_1_2  :=    1.24676031751E-09 ;
    AP_2_0  :=   -1.97047860146E-07 ;
    AP_2_1  :=    -1.5397306046E-11 ;
    AP_3_0  :=    1.20355457881E-09 ;

    BP_0_0  :=    -0.00397170042445 ;
    BP_0_1  :=   -7.87791261302E-05 ;
    BP_0_2  :=    1.54860395975E-07 ;
    BP_0_3  :=    1.14464806315E-09 ;
    BP_1_0  :=   -2.98529389782E-07 ;
    BP_1_1  :=   -1.39126756734E-08 ;
    BP_1_2  :=    8.63437642927E-12 ;
    BP_2_0  :=    1.67478963016E-08 ;
    BP_2_1  :=    1.21665781135E-09 ;
    BP_3_0  :=     1.5793454372E-12 ;


    x:=x+AP_0_0+ AP_0_1*y +AP_0_2*y*y + AP_0_3*y*y*y +AP_1_0*x +AP_1_1*x*y + AP_1_2*x*y*y + AP_2_0*x*x + AP_2_1*x*x*y+ AP_3_0*x*x*x;//process, image with significant optical distortion
    y:=y+BP_0_0+ BP_0_1*y +BP_0_2*y*y + BP_0_3*y*y*y +BP_1_0*x +BP_1_1*x*y + BP_1_2*x*y*y + BP_2_0*x*x + BP_2_1*x*x*y+ BP_3_0*x*x*x;//process

    asw[count].x:=x;
    asw[count].y:=y;
    inc(count);
  end;
  setlength(asw,count);
  setlength(b,count);

  if Calc_Trans_Cubic(asw, // First array of s_star structure we match the output TRANS takes their coords into those of array B
                      bb, // Second array of s_star structure we match
                     trans // Place solved coefficients into this  existing structure's fields
                      )=0
  then
    beep  //failure
  else
  //succes

 //TESTING ============
  maxerrorX:=0;
  maxerrorY:=0;
  maxcorrectionX:=0;
  maxcorrectionY:=0;

// const   A,K
//  x;      B,L
//  y;      C,M
//  x*x;    D,N
//  x*y;    E,O
//  y*y;    F,P
//  x*x*x;  G,Q
//  x*x*y;  H,R
//  x*y*y;  J,S
//  y*y*y;  K,T


  for i:=0 to count-1 do
  begin
  x:=asw[i].x;
  y:=asw[i].y;
  correction:=
      trans.a   +
      trans.b*x +
      trans.c*y +
      trans.d*x*x +
      trans.e*x*y +
      trans.f*y*y +
      trans.g*x*x*x +
      trans.h*x*x*y +
      trans.i*x*y*y +
      trans.j*y*y*y;
      testX:=correction-bb[i].x;

   if abs(testX)>maxerrorX then
   begin
     maxerrorX:=abs(testX);
     errorposY:=i;
   end;


   correction:=
        trans.k   +
        trans.l*x +
        trans.m*y +
        trans.n*x*x +
        trans.o*x*y +
        trans.p*y*y +
        trans.q*x*x*x +
        trans.r*x*x*y +
        trans.s*x*y*y +
        trans.t*y*y*y;
        testY:=correction-bb[i].y;

     if abs(testY)>maxerrorY then
     begin
       maxerrorY:=abs(testY);
       errorposY:=i;
     end;
   end;
   beep;
 }

end.

