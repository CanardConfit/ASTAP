unit unit_raster_rotate;  //This unit applies an accurate arbitrary rotation on a raster image. It distributes the flux of each source pixel up to 4 positions.

// This unit is copyright 2021, Han Kleijn
// Based on code copyright 2012, Sudonull, https://sudonull.com/post/134233-Precise-rotation-of-the-bitmap-image-at-an-arbitrary-angle

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.


{$mode delphi}

interface

uses
  Classes, SysUtils, Math,forms {application.processmessages},astap_main;

procedure raster_rotate(angle, CX, CY: double; var img: image_array); {accurate raster rotation}
procedure rotate_arbitraryold(angle: double; var img: image_array); {no longer used. Only for testing}


implementation

type
  expoint = record
    X, Y: extended;
  end;

  el = record
    S: extended;   // the flux for this area.
    Y, X: integer; // pixel coordinates of the flux
  end;

  flux = array [1..9] of el;// total number of pieces of 9 neighbors per side of Equal 1, the order of the necks is not selected

var
  swidth, sheight, scolours: integer;
  tgAd2, tgBd2, sinB, cosB, sinBucosBd2, cosAu2, cosBu2, triS, pdx, pdy: double;


function Point2Ang(x, y, CentrX, CentrY, R: double): double; // Resultat - angle between Y-axis and slow from 12:00 hourly arrow 0 ° -360 °
var
  dx, dy: double;
begin
  if R <> 0 then
  begin
    dx := x - CentrX;
    dy := y - CentrY;
    if dx < 0 then
      if dy < 0 then
        Result := 360 + 180 * arcsin(dx / R) / pi
      else
        Result := 180 - 180 * arcsin(dx / R) / pi
    else
    if dy < 0 then
      Result := 180 * arcsin(dx / R) / pi
    else
      Result := 180 - 180 * arcsin(dx / R) / pi;
  end
  else
    Result := 0;
end;

function Ang2Point(angle, R: double): expoint;  // angle 0-360 °, counting from 12:00 hourly hand, Resultat - point at the edge with R and 0.0
var
  z: integer;
begin
  z := trunc(angle / 180);
  case z of
    0:
    begin
      Result.X := r * sin(pi * angle / 180);
      Result.Y := r * -cos(pi * angle / 180);
    end;
    1:
    begin
      angle := angle - 180 * z;
      Result.X := r * -sin(pi * angle / 180);
      Result.Y := r * cos(pi * angle / 180);
    end;
  end;
end;


function DoMax(x: double): integer;
begin
  if x < 0 then
    if frac(abs(x)) > 1e-6 then
      Result := trunc(x) - 1
    else
      Result := trunc(x)
  else if frac(x) > 1e-6 then
    Result := trunc(x) + 1
  else
    Result := trunc(x);
end;


function calculate_relevant_source_pixels(x, y: integer; CX, CY, angle: double): flux;
var
  ug, vcx, vcy, R, x1, x2, x3, x4, y1, y2, y3, y4,// Pixel Point Codes
  dx1,{ dx2,} dx3, dx4, dy1, dy2, dy3, dy4, // auxiliary variables
  s1, s2, s3, s4, s5, s6, s7, s8, s9: double;// squares
  i,{ j,} ix1, ix2, ix3, ix4, iy1, iy2, iy3, iy4: integer;
begin
  dx1 := x + 0.5 - CX; // add 0.5 to the pixel coordinate - this is the upper left corner, but we have a center
  dy1 := y + 0.5 - CY;
  R := sqrt(dx1 * dx1 + dy1 * dy1); // Radius of rotation of the center of the pixel
  if R > 0 then
  begin // copy Point2Ang + angle
    if dx1 < 0 then
      if dy1 < 0 then
        ug := angle + 360 + 180 * arcsin(dx1 / R) / pi
      else
        ug := angle + 180 - 180 * arcsin(dx1 / R) / pi
    else
    if dy1 < 0 then
      ug := angle + 180 * arcsin(dx1 / R) / pi
    else
      ug := angle + 180 - 180 * arcsin(dx1 / R) / pi;
  end
  else
    ug := angle;
  if ug >= 360 then
    ug := ug - 360 * trunc(ug / 360); // Zero 360 °

  case trunc(ug / 180) of // copy Ang2Point + CX CY
    0:
    begin
      vcx := CX + R * sin(pi * ug / 180);// Fine coordinates of the axis of the pixel after the rotation of the reference speed, in the output speed
      vcy := CY - R * cos(pi * ug / 180);
    end
    else
    begin
      ug := ug - 180 * trunc(ug / 180);
      vcx := CX - R * sin(pi * ug / 180);
      vcy := CY + R * cos(pi * ug / 180);
    end;
  end;


  if (vcx < 0) or (vcy < 0) or (vcx >= sWidth) or (vcy >= sHeight) then {outside the image}
  begin
    Result[1].s := -1; // use 1st item as indicator
    exit;
  end;

  for i := 1 to 9 do
    Result[i].s := 0; // reset all areas/fractions
  // Coordinates of pixel angles after rotation of the pixel center
  if (vcx < 3) or (vcy < 3) then
  begin
    x1 := vcx + pdx + 10; // +10 add-ons for the art of glass in a positive square
    y1 := vcy + pdy + 10;
    x2 := vcx - pdy + 10;
    y2 := vcy + pdx + 10;
    x3 := vcx - pdx + 10;
    y3 := vcy - pdy + 10;
    x4 := vcx + pdy + 10;
    y4 := vcy - pdx + 10;
  end
  else
  begin
    x1 := vcx + pdx;
    y1 := vcy + pdy;
    x2 := vcx - pdy;
    y2 := vcy + pdx;
    x3 := vcx - pdx;
    y3 := vcy - pdy;
    x4 := vcx + pdy;
    y4 := vcy - pdx;
  end;

  // index of the drive, in which the angle of the output of the drive
  ix1 := trunc(x1); // SAME RIGHT
  iy1 := trunc(y1);
  ix2 := trunc(x2); // SAME
  iy2 := trunc(y2);
  ix3 := trunc(x3); // SAME LEFT
  iy3 := trunc(y3);
  ix4 := trunc(x4); // SAME UPPER
  iy4 := trunc(y4);

  // all formulas below work only in the positive quadrant of the coordinate system!
  if iy3 = iy2 then
    if iy4 = iy1 then
      if ix4 = ix3 then
        if ix1 = ix2 then
        begin  //option 1
          //╔═══╦═══╦═══╗
          //║ 4 ║ 1 ║   ║   The corners of the source image  pixel is at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
          //╠═══╬═══╬═══╣
          //║ 3 ║ 2 ║   ║
          //╠═══╬═══╬═══╣
          //║   ║   ║   ║
          //╚═══╩═══╩═══╝
          dy2 := frac(y2);
          dx3 := 1 - frac(x3);
          dy3 := frac(y3);
          dx4 := 1 - frac(x4);
          dy4 := 1 - frac(y4);
          s3 := dx3 * dy3 + (dx3 * dx3 - dy3 * dy3) * tgAd2; // size of fragment at position 3
          s4 := dx4 * dy4 + (dy4 * dy4 - dx4 * dx4) * tgAd2; // size of fragment at position 4
          s1 := 0.5 + (dy4 - dy2) / cosAu2;
          s2 := 1 - s1 - s3;                // size of fragment at position 2
          s1 := s1 - s4;                    // size of fragment at position 1
          Result[1].s := s1;
          Result[1].X := ix1;
          Result[1].Y := iy1;
          Result[2].S := s2;
          Result[2].X := ix2;
          Result[2].Y := iy2;
          Result[3].S := s3;
          Result[3].X := ix3;
          Result[3].Y := iy3;
          Result[4].S := s4;
          Result[4].X := ix4;
          Result[4].Y := iy4;
        end
        else
        begin  // option 15
          //╔═══╦═══╦═══╗
          //║ 4 ║ 1 ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
          //╠═══╬═══╬═══╣
          //║3,2║   ║   ║
          //╠═══╬═══╬═══╣
          //║   ║   ║   ║
          //╚═══╩═══╩═══╝
          dx1 := frac(x1);
          dy2 := frac(y2);
          dy4 := 1 - frac(y4);
          s4 := dx1 / cosb + dy2 / sinB - 1;
          s4 := s4 * s4 * tris;     // size of fragment at position 4
          Result[1].S := s4;
          Result[1].X := ix1;
          Result[1].Y := iy2;
          s2 := dx1 * dx1 / sinBucosBd2 - s4;  // size of fragment at position 2
          s1 := 0.5 + (dy4 - dy2) / cosAu2;
          s3 := 1 - s1 - s4;                   // size of fragment at position 3
          s1 := s1 - s2;                       // size of fragment at position 1
          Result[2].S := s1;
          Result[2].X := ix4;
          Result[2].Y := iy4;
          Result[3].S := s2;
          Result[3].X := ix1;
          Result[3].Y := iy1;
          Result[4].S := s3;
          Result[4].X := ix2;
          Result[4].Y := iy2;
        end
      else if ix1 = ix2 then
      begin   // option 11
        //╔═══╦═══╦═══╗
        //║   ║4,1║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
        //╠═══╬═══╬═══╣
        //║ 3 ║ 2 ║   ║
        //╠═══╬═══╬═══╣
        //║   ║   ║   ║
        //╚═══╩═══╩═══╝
        dy2 := frac(y2);
        dx3 := 1 - frac(x3);
        dy4 := 1 - frac(y4);
        s1 := dx3 / cosB + dy4 / sinB - 1;
        s1 := s1 * s1 * tris;
        Result[1].S := s1;
        Result[1].X := ix3;
        Result[1].Y := iy4;
        s3 := dx3 * dx3 / sinBucosBd2 - s1;
        s2 := 0.5 + (dy4 - dy2) / cosAu2;
        s4 := 1 - s2 - s3;
        s2 := s2 - s1;
        Result[2].S := s2;
        Result[2].X := ix4;
        Result[2].Y := iy4;
        Result[3].S := s3;
        Result[3].X := ix3;
        Result[3].Y := iy3;
        Result[4].S := s4;
        Result[4].X := ix2;
        Result[4].Y := iy2;
      end
      else
      begin   // option 4
        //╔═══╦═══╦═══╗
        //║ Y ║ 4 ║ 1 ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
        //╠═══╬═══╬═══╣
        //║ 1 ║ 3 ║ Y ║
        //╠═══╬═══╬═══╣
        //║   ║   ║   ║
        //╚═══╩═══╩═══╝
        dx1 := frac(x1);
        dy2 := frac(y2);
        dx3 := 1 - frac(x3);
        dy4 := 1 - frac(y4);
        s1 := dx3 / cosB + dy4 / sinB - 1;
        if s1 > 0 then
        begin
          s1 := s1 * s1 * tris;
          Result[1].S := s1;
          Result[1].X := ix3;
          Result[1].Y := iy4;
        end
        else
          s1 := 0;
        s6 := dx1 / cosb + dy2 / sinB - 1;
        if s6 > 0 then
        begin
          s6 := s6 * s6 * tris;
          Result[2].S := s6;
          Result[2].X := ix1;
          Result[2].Y := iy2;
        end
        else
          s6 := 0;
        s4 := dx3 * dx3 / sinBucosBd2 - s1;
        s3 := dx1 * dx1 / sinBucosBd2 - s6;
        s2 := 0.5 + (dy4 - dy2) / cosAu2;
        s5 := 1 - s2 - s4 - s6;
        s2 := s2 - s1 - s3;
        Result[3].S := s2;
        Result[3].X := ix4;
        Result[3].Y := iy4;
        Result[4].S := s4;
        Result[4].X := ix3;
        Result[4].Y := iy3;
        Result[5].S := s5;
        Result[5].X := ix2;
        Result[5].Y := iy2;
        Result[6].S := s3;
        Result[6].X := ix1;
        Result[6].Y := iy1;
      end
    else if ix4 = ix2 then
      if ix4 = ix1 then
      begin // option 10
        //╔═══╦═══╦═══╗
        //║   ║ 4 ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
        //╠═══╬═══╬═══╣
        //║ 3 ║2,1║   ║
        //╠═══╬═══╬═══╣
        //║   ║   ║   ║
        //╚═══╩═══╩═══╝
        dx3 := 1 - frac(x3);
        dy4 := 1 - frac(y4);
        s1 := dx3 / cosB + dy4 / sinB - 1;
        s1 := s1 * s1 * tris;
        Result[1].S := s1;
        Result[1].X := ix3;
        Result[1].Y := iy4;
        s2 := dy4 * dy4 / sinBucosBd2 - s1;
        s3 := dx3 * dx3 / sinBucosBd2 - s1;
        s4 := 1 - s1 - s2 - s3;
        Result[2].S := s2;
        Result[2].X := ix4;
        Result[2].Y := iy4;
        Result[3].S := s3;
        Result[3].X := ix3;
        Result[3].Y := iy3;
        Result[4].S := s4;
        Result[4].X := ix4;
        Result[4].Y := iy3;
      end
      else if ix3 = ix2 then
      begin   // option 17
        dx1 := frac(x1);
        dy4 := 1 - frac(y4);
        s2 := dx1 / sinB + dy4 / cosB - 1;
        s2 := s2 * s2 * tris;
        Result[1].S := s2;
        Result[1].X := ix1;
        Result[1].Y := iy4;
        s1 := dy4 * dy4 / sinBucosBd2 - s2;
        s4 := dx1 * dx1 / sinBucosBd2 - s2;
        s3 := 1 - s1 - s2 - s4;
        Result[2].S := s1;
        Result[2].X := ix4;
        Result[2].Y := iy4;
        Result[3].S := s4;
        Result[3].X := ix1;
        Result[3].Y := iy1;
        Result[4].S := s3;
        Result[4].X := ix4;
        Result[4].Y := iy1;
      end
      else
      begin   // option 5
        //╔═══╦═══╦═══╗
        //║ Y ║ 4 ║ Y ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
        //╠═══╬═══╬═══╣
        //║ 3 ║ 2 ║ 1 ║
        //╠═══╬═══╬═══╣
        //║   ║   ║   ║
        //╚═══╩═══╩═══╝
        dx1 := frac(x1);
        dx3 := 1 - frac(x3);
        dy4 := 1 - frac(y4);
        s1 := dx3 / cosB + dy4 / sinB - 1;
        if s1 > 0 then
        begin
          s1 := s1 * s1 * tris;
          Result[1].S := s1;
          Result[1].X := ix3;
          Result[1].Y := iy4;
        end
        else
          s1 := 0;
        s3 := dx1 / sinB + dy4 / cosB - 1;
        if s3 > 0 then
        begin
          s3 := s3 * s3 * tris;
          Result[2].S := s3;
          Result[2].X := ix1;
          Result[2].Y := iy4;
        end
        else
          s3 := 0;
        s2 := dy4 * dy4 / sinBucosBd2;
        s4 := dx3 * dx3 / sinBucosBd2 - s1;
        s6 := dx1 * dx1 / sinBucosBd2 - s3;
        s5 := 1 - s2 - s4 - s6;
        s2 := s2 - s1 - s3;
        Result[3].S := s2;
        Result[3].X := ix4;
        Result[3].Y := iy4;
        Result[4].S := s4;
        Result[4].X := ix3;
        Result[4].Y := iy3;
        Result[5].S := s6;
        Result[5].X := ix1;
        Result[5].Y := iy1;
        Result[6].S := s5;
        Result[6].X := ix4;
        Result[6].Y := iy3;
      end
    else if ix4 = ix3 then
    begin   // option 16
      //╔═══╦═══╦═══╗
      //║ 4 ║   ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
      //╠═══╬═══╬═══╣
      //║ 3 ║2,1║   ║
      //╠═══╬═══╬═══╣
      //║   ║   ║   ║
      //╚═══╩═══╩═══╝
      dx1 := frac(x1);
      dx3 := 1 - frac(x3);
      dy4 := 1 - frac(y4);
      s2 := dx1 / sinB + dy4 / cosB - 1;
      s2 := s2 * s2 * tris;
      Result[1].S := s2;
      Result[1].X := ix1;
      Result[1].Y := iy4;
      s1 := dy4 * dy4 / sinBucosBd2 - s2;
      s4 := 0.5 + (dx1 - dx3) / cosAu2;
      s3 := 1 - s4 - s1;
      s4 := s4 - s2;
      Result[2].S := s1;
      Result[2].X := ix4;
      Result[2].Y := iy4;
      Result[3].S := s3;
      Result[3].X := ix3;
      Result[3].Y := iy3;
      Result[4].S := s4;
      Result[4].X := ix1;
      Result[4].Y := iy1;
    end
    else
    begin    // option 12
      //╔═══╦═══╦═══╗
      //║   ║ 4 ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
      //╠═══╬═══╬═══╣
      //║3,2║ 1 ║   ║
      //╠═══╬═══╬═══╣
      //║   ║   ║   ║
      //╚═══╩═══╩═══╝
      dx1 := frac(x1);
      dx3 := 1 - frac(x3);
      dy4 := 1 - frac(y4);
      s1 := dx3 / cosB + dy4 / sinB - 1;
      s1 := s1 * s1 * tris;
      Result[1].S := s1;
      Result[1].X := ix3;
      Result[1].Y := iy4;
      s2 := dy4 * dy4 / sinBucosBd2 - s1;
      s3 := 0.5 + (dx3 - dx1) / cosBu2;
      s4 := 1 - s3 - s2;
      s3 := s3 - s1;
      Result[2].S := s2;
      Result[2].X := ix4;
      Result[2].Y := iy4;
      Result[3].S := s3;
      Result[3].X := ix3;
      Result[3].Y := iy3;
      Result[4].S := s4;
      Result[4].X := ix1;
      Result[4].Y := iy1;
    end
  else if iy3 = iy4 then
    if ix3 = ix2 then
      if ix4 = ix1 then
        if iy2 = iy1 then
        begin// option 2
          //╔═══╦═══╦═══╗
          //║ 3 ║ 4 ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
          //╠═══╬═══╬═══╣
          //║ 2 ║ 1 ║   ║
          //╠═══╬═══╬═══╣
          //║   ║   ║   ║
          //╚═══╩═══╩═══╝
          dx4 := frac(x4);
          dy2 := frac(y2);
          dy4 := 1 - frac(y4);
          dx1 := frac(x1);
          dy1 := frac(y1);
          s4 := dx4 * dy4 + (dy4 * dy4 - dx4 * dx4) * tgBd2;
          s1 := dx1 * dy1 + (dx1 * dx1 - dy1 * dy1) * tgBd2;
          s3 := 0.5 + (dy4 - dy2) / cosBu2;
          s2 := 1 - s3 - s1;
          s3 := s3 - s4;
          Result[1].S := s1;
          Result[1].X := ix1;
          Result[1].Y := iy1;
          Result[2].S := s2;
          Result[2].X := ix2;
          Result[2].Y := iy2;
          Result[3].S := s3;
          Result[3].X := ix3;
          Result[3].Y := iy3;
          Result[4].S := s4;
          Result[4].X := ix4;
          Result[4].Y := iy4;
        end
        else
        begin                 // option 13
          //╔═══╦═══╦═══╗
          //║ 3 ║4,1║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
          //╠═══╬═══╬═══╣
          //║ 2 ║   ║   ║
          //╠═══╬═══╬═══╣
          //║   ║   ║   ║
          //╚═══╩═══╩═══╝
          dx1 := frac(x1);
          dy2 := frac(y2);
          dx3 := 1 - frac(x3);
          s4 := dx1 / cosb + dy2 / sinB - 1;
          s4 := s4 * s4 * tris;
          Result[1].S := s4;
          Result[1].X := ix1;
          Result[1].Y := iy2;
          s3 := dy2 * dy2 / sinBucosBd2 - s4;
          s1 := 0.5 + (dx3 - dx1) / cosBu2;
          s2 := 1 - s1 - s4;
          s1 := s1 - s3;
          Result[2].S := s1;
          Result[2].X := ix3;
          Result[2].Y := iy3;
          Result[3].S := s3;
          Result[3].X := ix2;
          Result[3].Y := iy2;
          Result[4].S := s2;
          Result[4].X := ix1;
          Result[4].Y := iy1;
        end
      else if iy2 = iy1 then
      begin     // option 18
        //╔═══╦═══╦═══╗
        //║3,4║   ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
        //╠═══╬═══╬═══╣
        //║ 2 ║ 1 ║   ║
        //╠═══╬═══╬═══╣
        //║   ║   ║   ║
        //╚═══╩═══╩═══╝
        dx1 := frac(x1);
        dy2 := frac(y2);
        dy4 := 1 - frac(y4);
        s2 := dx1 / sinB + dy4 / cosB - 1;
        s2 := s2 * s2 * tris;
        Result[1].S := s2;
        Result[1].X := ix1;
        Result[1].Y := iy4;
        s4 := dx1 * dx1 / sinBucosBd2 - s2;
        s1 := 0.5 + (dy4 - dy2) / cosBu2;
        s3 := 1 - s1 - s4;
        s1 := s1 - s2;
        Result[2].S := s1;
        Result[2].X := ix4;
        Result[2].Y := iy4;
        Result[3].S := s3;
        Result[3].X := ix2;
        Result[3].Y := iy2;
        Result[4].S := s4;
        Result[4].X := ix1;
        Result[4].Y := iy1;
      end
      else
      begin    // option 14
        //╔═══╦═══╦═══╗
        //║3,4║ 1 ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
        //╠═══╬═══╬═══╣
        //║ 2 ║   ║   ║
        //╠═══╬═══╬═══╣
        //║   ║   ║   ║
        //╚═══╩═══╩═══╝
        dx1 := frac(x1);
        dy2 := frac(y2);
        s4 := dx1 / cosb + dy2 / sinB - 1;
        s4 := s4 * s4 * tris;
        Result[1].S := s4;
        Result[1].X := ix1;
        Result[1].Y := iy2;
        s2 := dx1 * dx1 / sinBucosBd2 - s4;
        s3 := dy2 * dy2 / sinBucosBd2 - s4;
        s1 := 1 - s2 - s3 - s4;
        Result[2].S := s2;
        Result[2].X := ix1;
        Result[2].Y := iy1;
        Result[3].S := s3;
        Result[3].X := ix2;
        Result[3].Y := iy2;
        Result[4].S := s1;
        Result[4].X := ix2;
        Result[4].Y := iy1;
      end
    else if ix2 = ix1 then
      if ix3 = ix4 then
      begin   // option 9
        //╔═══╦═══╦═══╗
        //║3,4║ 1 ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
        //╠═══╬═══╬═══╣
        //║   ║ 2 ║   ║
        //╠═══╬═══╬═══╣
        //║   ║   ║   ║
        //╚═══╩═══╩═══╝
        dx1 := frac(x1);
        dy2 := frac(y2);
        dx3 := 1 - frac(x3);
        s3 := dx3 / sinB + dy2 / cosB - 1;
        s3 := s3 * s3 * tris;
        Result[1].S := s3;
        Result[1].X := ix3;
        Result[1].Y := iy2;
        s4 := dy2 * dy2 / sinBucosBd2 - s3;
        s2 := 0.5 + (dx1 - dx3) / cosAu2;
        s1 := 1 - s2 - s3;
        s2 := s2 - s4;
        Result[2].S := s4;
        Result[2].X := ix2;
        Result[2].Y := iy2;
        Result[3].S := s2;
        Result[3].X := ix1;
        Result[3].Y := iy1;
        Result[4].S := s1;
        Result[4].X := ix3;
        Result[4].Y := iy3;
      end
      else if iy3 = iy1 then
      begin   // option 8
        //╔═══╦═══╦═══╗
        //║ 3 ║4,1║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
        //╠═══╬═══╬═══╣
        //║   ║ 2 ║   ║
        //╠═══╬═══╬═══╣
        //║   ║   ║   ║
        //╚═══╩═══╩═══╝
        dy2 := frac(y2);
        dx3 := 1 - frac(x3);
        s3 := dx3 / sinB + dy2 / cosB - 1;
        s3 := s3 * s3 * tris;
        Result[1].S := s3;
        Result[1].X := ix3;
        Result[1].Y := iy2;
        s1 := dx3 * dx3 / sinBucosBd2 - s3;
        s4 := dy2 * dy2 / sinBucosBd2 - s3;
        s2 := 1 - s1 - s3 - s4;
        Result[2].S := s1;
        Result[2].X := ix3;
        Result[2].Y := iy3;
        Result[3].S := s4;
        Result[3].X := ix2;
        Result[3].Y := iy2;
        Result[4].S := s2;
        Result[4].X := ix2;
        Result[4].Y := iy3;
      end
      else
      begin                  // option 7
        //╔═══╦═══╦═══╗
        //║ 3 ║ 4 ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
        //╠═══╬═══╬═══╣
        //║   ║1,2║   ║
        //╠═══╬═══╬═══╣
        //║   ║   ║   ║
        //╚═══╩═══╩═══╝
        dy2 := frac(y2);
        dx3 := 1 - frac(x3);
        dy4 := 1 - frac(y4);
        s3 := dx3 / sinB + dy2 / cosB - 1;
        s3 := s3 * s3 * tris;
        Result[1].S := s3;
        Result[1].X := ix3;
        Result[1].Y := iy2;
        s1 := dx3 * dx3 / sinBucosBd2 - s3;
        s2 := 0.5 + (dy4 - dy2) / cosBu2;
        s4 := 1 - s2 - s3;
        s2 := s2 - s1;
        Result[2].S := s1;
        Result[2].X := ix3;
        Result[2].Y := iy3;
        Result[3].S := s2;
        Result[3].X := ix4;
        Result[3].Y := iy4;
        Result[4].S := s4;
        Result[4].X := ix4;
        Result[4].Y := iy2;
      end
    else if iy3 = iy1 then
    begin      // option 6
      //╔═══╦═══╦═══╗
      //║ 3 ║ 4 ║ 1 ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
      //╠═══╬═══╬═══╣
      //║ Y ║ 2 ║ Y ║
      //╠═══╬═══╬═══╣
      //║   ║   ║   ║
      //╚═══╩═══╩═══╝
      dx1 := frac(x1);
      dy2 := frac(y2);
      dx3 := 1 - frac(x3);
      s4 := dx3 / sinB + dy2 / cosB - 1;
      if s4 > 0 then
      begin
        s4 := s4 * s4 * tris;
        Result[1].S := s4;
        Result[1].X := ix3;
        Result[1].Y := iy2;
      end
      else
        s4 := 0;
      s6 := dx1 / cosb + dy2 / sinB - 1;
      if s6 > 0 then
      begin
        s6 := s6 * s6 * tris;
        Result[2].S := s6;
        Result[2].X := ix1;
        Result[2].Y := iy2;
      end
      else
        s6 := 0;
      s1 := dx3 * dx3 / sinBucosBd2 - s4;
      s3 := dx1 * dx1 / sinBucosBd2 - s6;
      s5 := dy2 * dy2 / sinBucosBd2;
      s2 := 1 - s1 - s3 - s5;
      s5 := s5 - s4 - s6;
      Result[3].S := s1;
      Result[3].X := ix3;
      Result[3].Y := iy3;
      Result[4].S := s3;
      Result[4].X := ix1;
      Result[4].Y := iy1;
      Result[5].S := s5;
      Result[5].X := ix2;
      Result[5].Y := iy2;
      Result[6].S := s2;
      Result[6].X := ix2;
      Result[6].Y := iy3;
    end
    else
    begin   // option 3
      //╔═══╦═══╦═══╗
      //║ 3 ║ 4 ║ Y ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
      //╠═══╬═══╬═══╣
      //║ Y ║ 2 ║ 1 ║
      //╠═══╬═══╬═══╣
      //║   ║   ║   ║
      //╚═══╩═══╩═══╝
      dx1 := frac(x1);
      dy2 := frac(y2);
      dx3 := 1 - frac(x3);
      dy4 := 1 - frac(y4);
      s4 := dx3 / sinB + dy2 / cosB - 1;
      if s4 > 0 then
      begin
        s4 := s4 * s4 * tris;
        Result[1].S := s4;
        Result[1].X := ix3;
        Result[1].Y := iy2;
      end
      else
        s4 := 0;
      s3 := dx1 / sinB + dy4 / cosB - 1;
      if s3 > 0 then
      begin
        s3 := s3 * s3 * tris;
        Result[2].S := s3;
        Result[2].X := ix1;
        Result[2].Y := iy4;
      end
      else
        s3 := 0;
      s1 := dx3 * dx3 / sinBucosBd2 - s4;
      s6 := dx1 * dx1 / sinBucosBd2 - s3;
      s2 := 0.5 + (dy4 - dy2) / cosBu2;
      s5 := 1 - s2 - s4 - s6;
      s2 := s2 - s1 - s3;
      Result[3].S := s6;
      Result[3].X := ix1;
      Result[3].Y := iy1;
      Result[4].S := s5;
      Result[4].X := ix2;
      Result[4].Y := iy2;
      Result[5].S := s1;
      Result[5].X := ix3;
      Result[5].Y := iy3;
      Result[6].S := s2;
      Result[6].X := ix4;
      Result[6].Y := iy4;
    end
  else if ix4 = ix2 then
    if ix3 = ix4 then
    begin // option 21
      //╔═══╦═══╦═══╗
      //║ 4 ║ Y ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
      //╠═══╬═══╬═══╣
      //║ 3 ║ 1 ║   ║
      //╠═══╬═══╬═══╣
      //║ 2 ║ Y ║   ║
      //╚═══╩═══╩═══╝
      dx1 := frac(x1);
      dy2 := frac(y2);
      dy4 := 1 - frac(y4);
      s2 := dx1 / sinB + dy4 / cosB - 1;
      if s2 > 0 then
      begin
        s2 := s2 * s2 * tris;
        Result[1].S := s2;
        Result[1].X := ix1;
        Result[1].Y := iy4;
      end
      else
        s2 := 0;
      s6 := dx1 / cosb + dy2 / sinB - 1;
      if s6 > 0 then
      begin
        s6 := s6 * s6 * tris;
        Result[2].S := s6;
        Result[2].X := ix1;
        Result[2].Y := iy2;
      end
      else
        s6 := 0;
      s1 := dy4 * dy4 / sinBucosBd2 - s2;
      s5 := dy2 * dy2 / sinBucosBd2 - s6;
      s4 := dx1 * dx1 / sinBucosBd2;
      s3 := 1 - s4 - s1 - s5;
      s4 := s4 - s2 - s6;
      Result[3].S := s1;
      Result[3].X := ix4;
      Result[3].Y := iy4;
      Result[4].S := s4;
      Result[4].X := ix1;
      Result[4].Y := iy1;
      Result[5].S := s5;
      Result[5].X := ix2;
      Result[5].Y := iy2;
      Result[6].S := s3;
      Result[6].X := ix2;
      Result[6].Y := iy1;
    end
    else if ix4 = ix1 then
    begin      // option 2
      //╔═══╦═══╦═══╗
      //║ 3 ║ 4 ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
      //╠═══╬═══╬═══╣
      //║ 2 ║ 1 ║   ║
      //╠═══╬═══╬═══╣
      //║   ║   ║   ║
      //╚═══╩═══╩═══╝
      dy2 := frac(y2);
      dx3 := 1 - frac(x3);
      dy4 := 1 - frac(y4);
      s1 := dx3 / cosB + dy4 / sinB - 1;
      if s1 > 0 then
      begin
        s1 := s1 * s1 * tris;
        Result[1].S := s1;
        Result[1].X := ix3;
        Result[1].Y := iy4;
      end
      else
        s1 := 0;
      s5 := dx3 / sinB + dy2 / cosB - 1;
      if s5 > 0 then
      begin
        s5 := s5 * s5 * tris;
        Result[2].S := s5;
        Result[2].X := ix3;
        Result[2].Y := iy2;
      end
      else
        s5 := 0;
      s2 := dy4 * dy4 / sinBucosBd2 - s1;
      s6 := dy2 * dy2 / sinBucosBd2 - s5;
      s3 := dx3 * dx3 / sinBucosBd2;
      s4 := 1 - s3 - s2 - s6;
      s3 := s3 - s1 - s5;
      Result[3].S := s2;
      Result[3].X := ix4;
      Result[3].Y := iy4;
      Result[4].S := s3;
      Result[4].X := ix3;
      Result[4].Y := iy3;
      Result[5].S := s6;
      Result[5].X := ix2;
      Result[5].Y := iy2;
      Result[6].S := s4;
      Result[6].X := ix2;
      Result[6].Y := iy3;
    end
    else
    begin  // option 23
      //╔═══╦═══╦═══╗
      //║ Y ║ 4 ║ Y ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
      //╠═══╬═══╬═══╣
      //║ 3 ║   ║ 1 ║
      //╠═══╬═══╬═══╣
      //║ Y ║ 2 ║ Y ║
      //╚═══╩═══╩═══╝
      dx1 := frac(x1);
      dy2 := frac(y2);
      dx3 := 1 - frac(x3);
      dy4 := 1 - frac(y4);
      s1 := dx3 / cosB + dy4 / sinB - 1;
      if s1 > 0 then
      begin
        s1 := s1 * s1 * tris;
        Result[1].S := s1;
        Result[1].X := ix3;
        Result[1].Y := iy4;
      end
      else
        s1 := 0;
      s3 := dx1 / sinB + dy4 / cosB - 1;
      if s3 > 0 then
      begin
        s3 := s3 * s3 * tris;
        Result[2].S := s3;
        Result[2].X := ix1;
        Result[2].Y := iy4;
      end
      else
        s3 := 0;
      s7 := dx3 / sinB + dy2 / cosB - 1;
      if s7 > 0 then
      begin
        s7 := s7 * s7 * tris;
        Result[3].S := s7;
        Result[3].X := ix3;
        Result[3].Y := iy2;
      end
      else
        s7 := 0;
      s9 := dx1 / cosb + dy2 / sinB - 1;
      if s9 > 0 then
      begin
        s9 := s9 * s9 * tris;
        Result[4].S := s9;
        Result[4].X := ix1;
        Result[4].Y := iy2;
      end
      else
        s9 := 0;
      s2 := dy4 * dy4 / sinBucosBd2 - s1 - s3;
      s8 := dy2 * dy2 / sinBucosBd2 - s7 - s9;
      s4 := dx3 * dx3 / sinBucosBd2;
      s6 := dx1 * dx1 / sinBucosBd2;
      s5 := 1 - s4 - s6 - s2 - s8;
      s4 := s4 - s1 - s7;
      s6 := s6 - s3 - s9;
      Result[5].S := s4;
      Result[5].X := ix3;
      Result[5].Y := iy3;
      Result[6].S := s2;
      Result[6].X := ix4;
      Result[6].Y := iy4;
      Result[7].S := s6;
      Result[7].X := ix1;
      Result[7].Y := iy1;
      Result[8].S := s8;
      Result[8].X := ix2;
      Result[8].Y := iy2;
      Result[9].S := s5;
      Result[9].X := ix4;
      Result[9].Y := iy3;
    end
  else if ix3 = ix4 then
  begin        // option 20
    //╔═══╦═══╦═══╗
    //║ 4 ║ Y ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
    //╠═══╬═══╬═══╣
    //║ 3 ║ 1 ║   ║
    //╠═══╬═══╬═══╣
    //║ Y ║ 2 ║   ║
    //╚═══╩═══╩═══╝
    dx1 := frac(x1);
    dy2 := frac(y2);
    dx3 := 1 - frac(x3);
    dy4 := 1 - frac(y4);
    s2 := dx1 / sinB + dy4 / cosB - 1;
    if s2 > 0 then
    begin
      s2 := s2 * s2 * tris;
      Result[1].S := s2;
      Result[1].X := ix1;
      Result[1].Y := iy4;
    end
    else
      s2 := 0;
    s5 := dx3 / sinB + dy2 / cosB - 1;
    if s5 > 0 then
    begin
      s5 := s5 * s5 * tris;
      Result[2].S := s5;
      Result[2].X := ix3;
      Result[2].Y := iy2;
    end
    else
      s5 := 0;
    s6 := dy2 * dy2 / sinBucosBd2 - s5;
    s1 := dy4 * dy4 / sinBucosBd2 - s2;
    s3 := 0.5 + (dx3 - dx1) / cosAu2;
    s4 := 1 - s3 - s2 - s6;
    s3 := s3 - s1 - s5;
    Result[3].S := s1;
    Result[3].X := ix4;
    Result[3].Y := iy4;
    Result[4].S := s3;
    Result[4].X := ix3;
    Result[4].Y := iy3;
    Result[5].S := s4;
    Result[5].X := ix1;
    Result[5].Y := iy1;
    Result[6].S := s6;
    Result[6].X := ix2;
    Result[6].Y := iy2;
  end
  else
  begin  // option 19
    //╔═══╦═══╦═══╗
    //║ Y ║ 4 ║   ║   The corners of the source image  pixel are at position 1,2,3,4 at the destination. Y=Yellow is where some flux could be missed.
    //╠═══╬═══╬═══╣
    //║ 3 ║ 1 ║   ║
    //╠═══╬═══╬═══╣
    //║ 2 ║ Y ║   ║
    //╚═══╩═══╩═══╝
    dx1 := frac(x1);
    dy2 := frac(y2);
    dx3 := 1 - frac(x3);
    dy4 := 1 - frac(y4);
    s1 := dx3 / cosB + dy4 / sinB - 1;
    if s1 > 0 then
    begin
      s1 := s1 * s1 * tris;
      Result[1].S := s1;
      Result[1].X := ix3;
      Result[1].Y := iy4;
    end
    else
      s1 := 0;
    s6 := dx1 / cosB + dy2 / sinB - 1;
    if s6 > 0 then
    begin
      s6 := s6 * s6 * tris;
      Result[2].S := s6;
      Result[2].X := ix1;
      Result[2].Y := iy2;
    end
    else
      s6 := 0;
    s2 := dy4 * dy4 / sinBucosBd2 - s1;
    s5 := dy2 * dy2 / sinBucosBd2 - s6;
    s3 := 0.5 + (dx3 - dx1) / cosBu2;
    s4 := 1 - s3 - s2 - s6;
    s3 := s3 - s1 - s5;
    Result[3].S := s2;
    Result[3].X := ix4;
    Result[3].Y := iy4;
    Result[4].S := s3;
    Result[4].X := ix3;
    Result[4].Y := iy3;
    Result[5].S := s4;
    Result[5].X := ix1;
    Result[5].Y := iy1;
    Result[6].S := s5;
    Result[6].X := ix2;
    Result[6].Y := iy2;
  end;

  if (vcx < 3) or (vcy < 3) then
    for i := 1 to 9 do
    begin
      Result[i].x := Result[i].x - 10; // after the calculations, change the coordinates of the left / upper pixels to the place
      Result[i].y := Result[i].y - 10;
    end;
end;


procedure raster_rotate(angle, CX, CY: double; var img: image_array);
var
  ug, R, red, green, blue, dx, dy                        : double;
  i, j, k, rw, rh, xd, yd, U90,progressC,progress_value  : integer;
  ep1, ep2, ep3, ep4: expoint;
  X: flux;
  temp_img: image_array;
begin
  if angle >= 360 then
    angle := angle - 360 * trunc(angle / 360); // Zero 360 °

  if angle = 0 then
  begin
    exit;
  end;
  scolours := length(img);{nr colours}
  swidth := length(img[0]);{width}
  sheight := length(img[0, 0]);{length}

  angle := angle mod 360; {make 0..360}
  if angle < 0 then
    angle := 360 - abs(angle);

  U90 := trunc(angle / 90);
  if (angle - U90 * 90) = 0 then
  begin  // on a corner, curl 90 °, repeat quickly and without loss,
    case U90 of // flip the image for multiple of 90 degrees.
      1:begin  //90°
          temp_img := nil;
          setlength(temp_img, scolours, sheight, swidth);
          for k := 0 to scolours - 1 do
            for j := 0 to sheight - 1 do
              for i := 0 to swidth - 1 do
                temp_img[k, sheight - 1 - j, i] := img[k, i, j];
        end;
      2:begin //180°
          temp_img := nil;
          setlength(temp_img, scolours, swidth, sheight);
          for k := 0 to scolours - 1 do
            for j := 0 to sheight - 1 do
              for i := 0 to swidth - 1 do
                temp_img[k, swidth - 1 - i, sheight - 1 - j] := img[k, i, j];
        end;
      3:begin   //270°
          temp_img := nil;
          setlength(temp_img, scolours, sheight, swidth);
          for k := 0 to scolours - 1 do
            for j := 0 to sheight - 1 do
              for i := 0 to swidth - 1 do
                temp_img[k, j, swidth - 1 - i] := img[k, i, j];
        end;
    end;

    img:=nil; {release memory}
    img:=temp_img;
    exit; {finished}
  end;

  R := sqrt(CX * CX + CY * CY);// for the ouput image
  ug := Point2Ang(0, 0, CX, CY, R) + angle;
  if ug >= 360 then
    ug := ug - 360 * trunc(ug / 360);
  ep1 := Ang2Point(ug, R);  // each corner is correct to repeat separately, so do not lose the pixels with domax
  ep1.X := ep1.X + CX;
  ep1.Y := ep1.Y + CY;

  dx := CX - swidth;
  dy := CY - sheight;
  R := sqrt(dx * dx + CY * CY);
  ug := Point2Ang(swidth, 0, CX, CY, R) + angle;
  if ug >= 360 then
    ug := ug - 360 * trunc(ug / 360);
  ep2 := Ang2Point(ug, R);
  ep2.X := ep2.X + CX;
  ep2.Y := ep2.Y + CY;

  R := sqrt(dx * dx + dy * dy);
  ug := Point2Ang(swidth, sheight, CX, CY, R) + angle;
  if ug >= 360 then
    ug := ug - 360 * trunc(ug / 360);
  ep3 := Ang2Point(ug, R);
  ep3.X := ep3.X + CX;
  ep3.Y := ep3.Y + CY;

  R := sqrt(CX * CX + dy * dy);
  ug := Point2Ang(0, sheight, CX, CY, R) + angle;
  if ug >= 360 then
    ug := ug - 360 * trunc(ug / 360);
  ep4 := Ang2Point(ug, R);
  ep4.X := ep4.X + CX;
  ep4.Y := ep4.Y + CY;

  case U90 of
    0:
    begin  //90°
      yd := domax(ep1.Y);
      xd := domax(ep4.X);
      rw := abs(domax(ep2.X) - xd);
      rh := abs(domax(ep3.Y) - yd);
    end;
    1:
    begin  //90°
      yd := domax(ep4.Y);
      xd := domax(ep3.X);
      rw := abs(domax(ep1.X) - xd);
      rh := abs(domax(ep2.Y) - yd);
    end;
    2:
    begin  //180°
      yd := domax(ep3.Y);
      xd := domax(ep2.X);
      rw := abs(domax(ep4.X) - xd);
      rh := abs(domax(ep1.Y) - yd);
    end
    else
    begin  //270°
      yd := domax(ep2.Y);
      xd := domax(ep1.X);
      rw := abs(domax(ep3.X) - xd);
      rh := abs(domax(ep4.Y) - yd);
    end;
  end;

  temp_img := nil;
  setlength(temp_img, scolours, rw, rh);{set length of temp img. Larger then orginal due to rotation}

  angle := 360 - angle; // Rotate backwards
  ug := angle - trunc(angle / 90) * 90;  // The angle of rotation of the point of the square of the pixel is the relative center of the pixel. Range 0 ° to 90 °
  pdx := sqrt(0.5) * sin(pi * (ug + 45) / 180);
  pdy := -sqrt(0.5) * cos(pi * (ug + 45) / 180);
  tgBd2 := tan(pi * (90 - ug) / 180) / 2; // auxiliary variables for speeding up
  tgAd2 := tan(pi * ug / 180) / 2;
  sinB := sin(pi * (90 - ug) / 180);
  cosB := cos(pi * (90 - ug) / 180);
  cosAu2 := cos(pi * ug / 180) * 2;
  cosBu2 := cos(pi * (90 - ug) / 180) * 2;
  triS := cos(pi * ug / 180) * sin(pi * ug / 180) / 2;
  sinBucosBd2 := sin(pi * (90 - ug) / 180) * cos(pi * (90 - ug) / 180) * 2;


  progressC:=0;
  for i := yd to yd + rh - 1 do
  begin
    if frac((progressC)/400)=0 then  {report every 400th line}
      begin
        progress_value:=round(progressC*100/(rh));{progress in %}
        progress_indicator(progress_value,'');{report progress}
        Application.ProcessMessages;{this could change startX, startY}
        if esc_pressed then  begin  img_temp:=nil;  exit;  end;
      end;

    inc(progressC);
    for j := xd to xd + rw - 1 do
    begin
      X := calculate_relevant_source_pixels(j, i, CX, CY, angle);  // Calculate the source flux positions and area and store in X. All coordinates are of the source image
      if x[1].S = -1 then  continue;         // use the first item as an indicator
      red := 0;
      green := 0;
      blue := 0;
      for k := 1 to 9 do
        if x[k].S > 1e-9 then
        begin
          if (x[k].Y >= 0) and (x[k].X >= 0) and (x[k].Y < sheight) and  (x[k].X < swidth) then {got through X}
          begin
            red := red + x[k].S * img[0,x[k].X,x[k].Y];// summation of the source flux
            if scolours > 2 then {colour image, do blue and green}
            begin
              green:= green + x[k].S * img[1,x[k].X,x[k].Y];// summation of the source flux
              blue := blue  + x[k].S * img[2,x[k].X,x[k].Y];// summation of the source flux
            end;
          end;
        end;
      temp_img[0, j - xd,i - yd] := red; {store flux in destination}
      if scolours > 2 then {colour image}
      begin
        temp_img[1,j - xd, i - yd] := green;
        temp_img[2,j - xd, i - yd] := blue;
      end;
    end;
  end;
  img := nil; {release memory}
  img := temp_img; {swap arrays}
end;


procedure rotate_arbitraryold(angle: double; var img: image_array); {no longer used. Only for testing}
var
  col,fitsX,fitsY,maxsize,i,j,progress_value,progressC,xx,yy,resolution                    : integer;
  cosA,sinA,factor, centerx,centery,centerxs,centerys,factX,factY,Cos_div_res,Sin_div_res  : double;
  value0,value1,value2 :single;
  img_temp : image_array;
begin
  if angle = 0 then
  begin
    exit;
  end;
  scolours := length(img);{nr colours}
  swidth := length(img[0]);{width}
  sheight := length(img[0, 0]);{length}

  if ((swidth<>sheight) or (img[0,0,0]<>0)  or (img[0,swidth-1,0]<>0) or (img[0,0,sheight-1]<>0) or (img[0,swidth-1,sheight-1]<>0))  then {fresh image}
    maxsize:=round(1+sqrt(sqr(sheight)+sqr(swidth))) {add one pixel otherwise not enough resulting in runtime errors}
  else {assume this image is already rotated. Enough space to rotate}
    maxsize:=swidth;

  centerX:=maxsize/2;
  centerY:=maxsize/2;
  centerxs:=swidth/2;
  centerys:=sheight/2;

  setlength(img_temp,scolours, maxsize,maxsize);{set length of new image}

  {clear array}
  for col:=0 to scolours-1 do {do all colours}
  begin
    For fitsY:=0 to (maxsize-1) do
      for fitsX:=0 to (maxsize-1) do
        img_temp[col,fitsX,fitsY]:=0
  end;

  sincos(angle*pi/180,sinA,cosA);
  if ((sinA=0) or (cosA=0)) then resolution:=1 else resolution:=10;{for angle 0,90,180,270 degrees no need to sub sample}
  factor:=1/sqr(resolution);{1/(number of subpixels), typical 1/(10x10)}
  //one_div_res:=1/resolution;

  Cos_div_res:=cosA/resolution;
  Sin_div_res:=sinA/resolution;


  progressC:=0;
  For fitsY:=0 to sheight-1 do
  begin
    inc(progressC);{counter}
    if frac(fitsY/100)=0 then
      begin
        Application.ProcessMessages;{this could change startX, startY}
        if esc_pressed then  begin  img_temp:=nil;  exit;  end;
        progress_value:=round(progressC*100/(head.height));{progress in %}
        progress_indicator(progress_value,'');{report progress}
      end;

    for fitsX:=0 to swidth-1 do
    begin
      value0:=img_loaded[0,fitsX,fitsY];

      if value0>=0.01 then {do only data. Use red for detection}
      begin
        if scolours>1 then value1:=img_loaded[1,fitsX,fitsY];{>=2 colour image}
        if scolours>2 then value2:=img_loaded[2,fitsX,fitsY];{>=3 colour image}
        begin
          factX:=centerX+(fitsX-centerxs-0.5)*cosA - (fitsY-centerys-0.5)*sinA;
          factY:=centerY+(fitsX-centerxs-0.5)*sinA + (fitsY-centerys-0.5)*cosA;

          for i:=0 to resolution-1 do {divide the pixel in resolution x resolution subpixels}
          for j:=0 to resolution-1 do {divide the pixel in resolution x resolution subpixels}
          begin
            {new position of subpixel}
            xx:=trunc(factX+ i*Cos_div_res - j*Sin_div_res); // xx:=trunc(centerX +(fitsX-centerxs-0.5+i/resolution)*cosA - (fitsY-centerys-0.5+j/resolution)*sinA);
            yy:=trunc(FactY +i*Sin_div_res + j*Cos_div_res); // yy:=trunc(centerY +(fitsX-centerxs-0.5+i/resolution)*sinA + (fitsY-centerys-0.5+j/resolution)*cosA);

            {do all colours}
            if ((xx>=0) and (xx<maxsize) and (yy>=0) and (yy<maxsize)) then {check required for small square images}
            begin
              img_temp[0,xx,yy ]:=img_temp[0,xx,yy] + value0*factor;{factor is typical 1/100 due to 10x10 subpixel}
              if scolours>1 then img_temp[1,xx,yy]:=img_temp[1,xx,yy] + value1*factor; {this is the fastest way rather then for col:=0 to head.naxis3-1 loop}
              if scolours>2 then img_temp[2,xx,yy]:=img_temp[2,xx,yy] + value2*factor;
            end;
          end;
        end;
      end;
    end;
  end;

  head.width:=maxsize;
  head.height:=maxsize;

  img:=nil;
  img:=img_temp;

end;


end.
