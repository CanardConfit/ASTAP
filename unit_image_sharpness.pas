unit unit_image_sharpness;
{Measurement of image sharpness for astronomical images of the Moon, Sun and stars}
{Resulting value is used for autofocus of Moon and Sun.}
{The routine applies the Root mean Square on the differences between the minimum and maximum value of each 2x2 pixel combination of the image.}
{The result is reversed and scaled such that the final result is roughly identical to the star HFD measurement.}

{Copyright (C) 2017-2026 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils, astap_main;


function image_sharpness(img: Timage_array): double;// Measure the sharpeness of an image by gradient. The result is reversed and scaled to be roughly identical to a HFD curve So value decreases with sharpness

implementation


function image_sharpness(img: Timage_array): Double;// Measure the sharpeness of an image by gradient. The result is reversed and scaled to be roughly identical to a HFD curve So value decreases with sharpness
Var
  x, y, Width, Height         : Integer;
  Sharpness, Center, Up, Right: double;

begin
  Height:=length(img[0]);
  Width:=length(img[0,0]);

  Sharpness := 0;
  for y := 2 to Height - 3 do // Loop over the image, excluding edges where step size of 2 cannot be applied
  begin
    for x := 2 to Width - 3 do
    begin
      Center := Img[0, y, x];// Center pixel value
      Up :=Img[0, y + 2, x];// Neighboring pixel values with step size of 2. So compare red sensitive with red sensitive, green sensitive with green sensitive.
      Right := Img[0, y, x + 2];
      Sharpness:=Sharpness+sqr(up-center)+sqr(right-center);
    end;//for loop
  end;//for loop

  if Sharpness>0 then
    result := 100*width*height/sqrt(Sharpness) //turn the curve upside down and scale simular as HFD values. A lower value indicates a sharper image
  else
    result:=9999;//dummy value for case sharpness is zero
end;



end.

