{ ******************************************************************
  Polynomial regression : Y = B(0) + B(1) * X + B(2) * X^2 + ...
  Unweighted polynomial regression for X,Y values
  ****************************************************************** }

{This unit was created by Han Kleijn in 2021 based on routines from

# TPMATH, MATHEMATICAL LIBRARY FOR PASCAL COMPILERS
# Version 0.81 (January 2011),
# AUTHOR : Dr Jean Debord
# Source code:  https://sourceforge.net/projects/tpmath/

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


{       Example values for test

        terms:=3;
        points:=10;
        setlength(xy,2,points+1);
        setlength(coefs,terms+1);

        xy[0,0]:=0;  //x values
        xy[0,1]:=1;
        xy[0,2]:=2;
        xy[0,3]:=3;
        xy[0,4]:=4;
        xy[0,5]:=5;
        xy[0,6]:=6;
        xy[0,7]:=7;
        xy[0,8]:=8;
        xy[0,9]:=9;
        xy[0,10]:=10;

        y[1,0]:=1;  //y values
        y[1,1]:=6;
        y[1,2]:=17;
        y[1,3]:=34;
        y[1,4]:=57;
        y[1,5]:=86;
        y[1,6]:=121;
        y[1,7]:=162;
        y[1,8]:=209;
        y[1,9]:=262;
        y[1,10]:=321;


        PolyFit( xy,  0,points,terms,coefs);

        the results:
          coefs[0]:=1
          coefs[1]:=2
          coefs[2]:=3
          coefs[3]:=0

        So the approximation polynomial will be 1 + 2*x + 3*x*x + 0*x*x*x
}



unit unit_polynomial_regression;

interface

type
    matrix  = array of array of double;

function PolyFit(XY          : matrix;    {X, Y the data}
                 Lb, Ub, Deg : Integer;            {minimum and max position of the array to use. Deg is the number of terms of the polynomial}
                 out  B      : array of double  ) : integer; {approximation polynomial Y = B(0) + B(1) * X + B(2) * X^2 + ..}
{ ------------------------------------------------------------------
  Unweighted polynomial regression
  ------------------------------------------------------------------
  Input parameters:  XY     = X, Y point coordinates
                     Lb, Ub = array bounds
                     Deg    = degree of polynomial
  Output parameters: B      = regression parameters
  ------------------------------------------------------------------ }



implementation


procedure FSwap(var X, Y : double);
var
  Temp : double;
begin
  Temp := X;
  X := Y;
  Y := Temp;
end;

{ ------------------------------------------------------------------
  Solves a linear system according to the Gauss-Jordan method
  ------------------------------------------------------------------
  Input parameters  : A      = system matrix
                      B      = constant vector
                      Lb, Ub = lower and upper array bounds
  ------------------------------------------------------------------
  Output parameters : B   = solution vector
                      Det = determinant of A
  ------------------------------------------------------------------
  Possible results  : result=0   : No error
                      result=1   : Quasi-singular matrix
  ------------------------------------------------------------------ }

function LinEq( A       : Matrix;
                var B   : array of double;
                Lb, Ub  : Integer ): integer;
var
  Pvt        : double;            { Pivot }
  Ik, Jk     : Integer;           { Pivot's row and column }
  I, J, K    : Integer;           { Loop variables }
  T          : double;            { Temporary variable }
  PRow, PCol : array of integer;  { Stores pivot's row and column }
  MCol       : array of double;   { Stores a column of matrix A }
  Det        : double;            { determinant of A}

const
  MachEp = 2.220446049250313E-16; { 2^(-52) }

  procedure Terminate; {deallocate arrays }
  begin
    prow:=nil;
    pcol:=nil;
    Mcol:=nil;
  end;

begin
  result:=0;{assume succes}
  setlength(Prow,Ub+1);
  setlength(Pcol,Ub+1);
  setlength(MCol,Ub+1);

  Det := 1.0;

  K := Lb;
  while K <= Ub do
    begin
      { Search for largest pivot in submatrix
        A[K..Ub, K..Ub] }
      Pvt := A[K,K];
      Ik := K;
      Jk := K;
      for I := K to Ub do
        for J := K to Ub do
          if Abs(A[I,J]) > Abs(Pvt) then
            begin
              Pvt := A[I,J];
              Ik := I;
              Jk := J;
            end;

      { Store pivot's position }
      PRow[K] := Ik;
      PCol[K] := Jk;

      { Update determinant }
      Det := Det * Pvt;
      if Ik <> K then Det := - Det;
      if Jk <> K then Det := - Det;

      { Too weak pivot ==> quasi-singular matrix }
      if Abs(Pvt) < MachEp then
         begin
           Terminate;
           result:=1;
           Exit
         end;

      { Exchange current row (K) with pivot row (Ik) }
      if Ik <> K then
        begin
          for J := Lb to Ub do
            FSwap(A[Ik,J], A[K,J]);
          FSwap(B[Ik], B[K]);
        end;

      { Exchange current column (K) with pivot column (Jk) }
      if Jk <> K then
        for I := Lb to Ub do
          FSwap(A[I,Jk], A[I,K]);

      { Store column K of matrix A into MCol
        and set this column to zero }
      for I := Lb to Ub do
        if I <> K then
          begin
            MCol[I] := A[I,K];
            A[I,K] := 0.0;
          end
        else
          begin
            MCol[I] := 0.0;
            A[K,I] := 1.0;
          end;

      { Transform pivot row }
      T := 1.0 / Pvt;
      for J := Lb to Ub do
        A[K,J] := T * A[K,J];
      B[K] := T * B[K];

      { Transform other rows }
      for I := Lb to Ub do
        if I <> K then
          begin
            T := MCol[I];
            for J := Lb to Ub do
              A[I,J] := A[I,J] - T * A[K,J];
            B[I] := B[I] - T * B[K];
          end;

      Inc(K);
    end;

  { Exchange lines of inverse matrix and solution vector }
  for I := Ub downto Lb do
    begin
      Ik := PCol[I];
      if Ik <> I then
        for J := Lb to Ub do
          FSwap(A[I,J], A[Ik,J]);
      FSwap(B[I], B[Ik]);
    end;

  { Exchange columns of inverse matrix }
  for J := Ub downto Lb do
    begin
      Jk := PRow[J];
      if Jk <> J then
        for I := Lb to Ub do
          FSwap(A[I,J], A[I,Jk]);
    end;
  Terminate;{procedure}
end;


function PolyFit(XY          : matrix;
                 Lb, Ub, Deg : Integer;
                 out  B      : array of double) : integer;
var
  I, I1, J, K, D1 : Integer;
  XI, Det         : double;
  V               : Matrix;
begin
  result:=99;{assume failure}
  if Ub - Lb < Deg then Exit;

  { Initialize }
  setlength(V,Deg+1,Deg+1);
  for I := 0 to Deg do
    begin
      for J := 0 to Deg do
        V[I,J] := 0.0;
      B[I] := 0.0;
    end;

  V[0,0] := Ub - Lb + 1;

  for K := Lb to Ub do
  begin
    XI := XY[0,K];                 { x^i }
    B[0] := B[0] + XY[1,K];
    V[0,1] := V[0,1] + XI;
    B[1] := B[1] + XI * XY[1,K];

    for I := 2 to Deg do
    begin
      XI := XI * XY[0,K];
      V[0,I] := V[0,I] + XI;   { First line of matrix: 1 --> x^d }
      B[I] := B[I] + XI * XY[1,K];   { Constant vector: y --> x^d.y  }
    end;

    for I := 1 to Deg do
    begin
      XI := XI * XY[0,K];
      V[I,Deg] := V[I,Deg] + XI;  { Last col. of matrix: x^d --> x^2d }
    end;
  end;

  { Fill lower matrix }
  D1 := Deg - 1;
  for I := 1 to Deg do
  begin
    I1 := I - 1;
    for J := 0 to D1 do
      V[I,J] := V[I1,J+1];
  end;

  { Solve system }
  result:=LinEq(V, B, 0, Deg);
  V:=nil;

end;



end.
