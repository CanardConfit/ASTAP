unit unit_interpolate;
{Copyright (C) 2024 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils, math,astap_main;

type
   pixel = array[0..2] of double;

   function bilinear_interpolation(const img :Timage_array; x,y:double; out colour: pixel): boolean; {calculate image pixel value on subpixel level}
   function BicubicInterpolate(const Img: Timage_array; X, Y: Double; out colour: pixel): boolean;


implementation

//the following function is not used since calculating the rectangle areas covered by an imaginary square pixel works a little better. See function hfd()
function bilinear_interpolation(const img :Timage_array; x,y:double; out colour: pixel): boolean; //calculate image pixel value on subpixel level
var
  X0, Y0, X1, Y1,width5,height5,col,nrcolours: Integer;
  Q11, Q12, Q21, Q22: Double;
  R1, R2: Double;
begin
  result:=true;
  width5:=Length(img[0,0]);{width}
  height5:=Length(img[0]); {height}
  nrcolours:=Length(img);

  X0 := Floor(X);
  Y0 := Floor(Y);
  X1 := X0 + 1;
  Y1 := Y0 + 1;

  if ((X0 <=0) or (X1 >= width5-1) or (Y0 <= 0) or (Y1 >= height5-1)) then
  begin
    for col:=0 to nrcolours do colour[col]:=0;
    result:=false;
    exit;
  end;

  for col:=0 to nrcolours-1 do
  begin
    Q11 := img[col,y0,x0];
    Q12 := img[col,y0,x1];
    Q21 := img[col,y1,x0];
    Q22 := img[col,y1,x1];
    colour[col]:= (Y1 - Y) * (X1 - X) * Q11 + (Y1 - Y) * (X - X0) * Q21 + (Y - Y0) * (X1 - X) * Q12 + (Y - Y0) * (X - X0) * Q22;
  end;
end;


function CatmullRom(p0, p1, p2, p3, t: Double): Double;
// A Catmull-Rom spline is a type of cubic Hermite spline that passes through a set of control points.
// It is C1 continuous, meaning that it has continuous first derivatives.
// The spline is not C2 continuous.  The second derivative is linearly interpolated within each segment, causing the curvature to vary linearly over the length of the segment.
// The factor 0.5 is called tention and typically provides a good balance between smoothness and sharpness.
//
//
//                                   [ -1   3  -3   1  ]   | P0 |
//                                   [  2  -5   4  -1  ]   | P1 |
//    P(t):= 0.5*[t^3, t^2, t, 1] *  [ -1   0   1   0  ] * | P2 |
//                                   [  0   2   0   0  ]   | P3 |
//
//    This becomes:
//
//    P(t) = 0.5 * ((-p0 + 3*p1 -3*p2 + p3)*t*t*t
//                + (2*p0 -5*p1 + 4*p2 - p3)*t*t
//                + (-p0+p2)*t
//                + 2*p1)
//
//        The interpolated value represents a point on the curve defined by the four control points p0,p1,p2 and p3.
//        This curve segment is influenced by the surrounding points, providing a smooth transition that maintains the shape defined by these points.
//
//        The function takes four control points: p0, p1, p2, and p3.
//        p1 and p2 are the primary points between which the interpolation occurs.
//        p0 and p3 influence the shape of the curve but are not directly interpolated between.
//        The output of the Catmull-rom is the estimated value between p1 and p2.
//
//        t is the interpolation parameter that determines the position along the curve between two control points p1 and p2.
//        When t=0, the interpolation result corresponds exactly to the position of the first control point p1.
//        At t=0.5, the point is halfway along the curve between p1 and p2.
//        When t=1, the result corresponds exactly to the position of the second control point p2.

var
  t2, t3: Double;
  a0, a1, a2, a3: Double;
begin
  t2 := t * t;
  t3 := t2 * t;

  // Coefficients for the cubic polynomial with tension parameter
  a0 := 0.5 * (-p0 + 3.0 * p1 - 3.0 * p2 + p3);
  a1 := 0.5 * (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3);
  a2 := 0.5 * (-p0 + p2);
  a3 := 0.5 * 2.0 * p1;

  Result := a0 * t3 + a1 * t2 + a2 * t + a3;
end;


function BicubicInterpolate(const Img: Timage_array; X, Y: Double; out colour: pixel): boolean;
var
  i, j, width5,height5,nrcolours,col: Integer;
  Row: array[0..3] of Double;
  IntX, IntY: Integer;
  DX, DY: Double;
begin
  result:=true;
  width5:=Length(img[0,0]);{width}
  height5:=Length(img[0]); {height}
  nrcolours:=Length(img);

  // Determine integer coordinates
  IntX := Floor(X);
  IntY := Floor(Y);

  // Calculate fractional part of the coordinates
  DX := X - IntX;
  DY := Y - IntY;

  // Boundary checks (ensure we have a 4x4 grid to interpolate within)
  if (IntX <= 1) or (IntX >= width5 - 2) or (IntY <= 1) or (IntY >=height5 - 2) then
  begin
    for i:=0 to 2 do colour[i]:=0;
    Exit(false);
  end;


  for col:=0 to nrcolours-1 do
  begin
    // Interpolate along the rows
    for i := -1 to 2 do
      Row[i + 1] := CatmullRom( Img[col,IntY + i,IntX - 1],
                                   Img[col,IntY + i,IntX],
                                   Img[col,IntY + i,(IntX + 1)],
                                   Img[col,IntY + i,(IntX + 2)],
                                   DX   );

    // Interpolate the result along the column
    colour[col] := CatmullRom(Row[0], Row[1], Row[2], Row[3], DY);
  end;
end;

//test data
{ img[0,0,0] :=  5; img[0,1,0] :=  6; img[0,2,0] :=  7; img[0,3,0] :=  8; img[0,4,0] :=  9;
  img[0,0,1] := 10; img[0,1,1] := 11; img[0,2,1] := 12; img[0,3,1] := 13; img[0,4,1] := 14;
  img[0,0,2] := 15; img[0,1,2] := 16; img[0,2,2] := 17; img[0,3,2] := 18; img[0,4,2] := 19;
  img[0,0,3] := 20; img[0,1,3] := 21; img[0,2,3] := 22; img[0,3,3] := 23; img[0,4,3] := 24;
  img[0,0,4] := 25; img[0,1,4] := 26; img[0,2,4] := 27; img[0,3,4] := 28; img[0,4,4] := 29;
  img[0,0,4] := 30; img[0,1,4] := 31; img[0,2,4] := 32; img[0,3,4] := 33; img[0,4,4] := 34;

  val:=value_bilinear(2.5,2.5);//20
  val:=BicubicInterpolate(2.5,2.5);
}


begin
end.

