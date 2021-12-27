unit unit_image_sharpness;
{Measurement of image sharpness for astronomical images of the Moon, Sun and stars}
{Resulting value is used for autofocus of Moon and Sun.}
{The routine applies the Root mean Square on the differences between the minimum and maximum value of each 2x2 pixel combination of the image.}
{The result is reversed and scaled such that the final result is roughly identical to the star HFD measurement.}

{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils, astap_main;


function image_sharpness(img: image_array): double;{measure the sharpeness of an image. Result is reversed and scaled to be roughly identical to a HFD measurement. So value decreases with sharpness}

implementation


function image_sharpness(img: image_array): double;{measure the sharpeness of an image. Result is reversed and scaled to be roughly identical to a HFD measurement. So value decreases with sharpness}
var
  w,h, i,j:integer;
  maxA,maxB,minA,minB,v1,v2,minimum,maximum,average : double;
begin
//  nrcolor:=length(img);{nr colours}
  h:=length(img[0,0]);{length}
  w:=length(img[0]);{width}

  result:=0;
  average:=0;

 {for OSC and mono images}
  for i:=0 to (w-4) div 4 do  {step in width}
  for j:=0 to (h-4) div 4 do  {step 4 pixels in height}
  begin {process 16 pixels. Test 2x2x(R+G+G+B) pixels}
    v1:=(img[0,i*4   ,j*4]+
         img[0,i*4+1 ,j*4]+
         img[0,i*4   ,j*4+1]+
         img[0,i*4+1 ,j*4+1]);{Sum of R+G+G+B}
    v2:=(img[0,i*4+2  ,j*4]+
         img[0,i*4+1+2,j*4]+
         img[0,i*4+2  ,j*4+1]+
         img[0,i*4+1+2,j*4+1]);{Sum of R+G+G+B}

    if v1>v2 then begin maxA:=v1; minA:=v2; end else begin maxA:=v2; minA:=v1; end;{find the minimum and maximum values of the two bottom (R+G+G+B) combinations}

    v1:=(img[0,i*4   ,j*4+2]+
         img[0,i*4+1 ,j*4+2]+
         img[0,i*4   ,j*4+1+2]+
         img[0,i*4+1 ,j*4+1+2]);{Sum of R+G+G+B}
    v2:=(img[0,i*4+2  ,j*4+2]+
         img[0,i*4+1+2,j*4+2]+
         img[0,i*4+2  ,j*4+1+2]+
         img[0,i*4+1+2,j*4+1+2]);{Sum of R+G+G+B}
    if v1>v2 then begin maxB:=v1; minB:=v2; end else begin maxB:=v2; minB:=v1; end; ;{find the minimum and maximum values of the two top (R+G+G+B)combinations}

    if minA<minB then minimum:=minA else minimum:=minB;
    if maxA>maxB then maximum:=maxA else maximum:=maxB;

    result:=result+sqr(maximum-minimum);{square the local slope in the 2x2x(R+G+G+B) test area and add to the total}
    average:=average+(maximum+minimum);
  end;

  result:=sqrt(result/(w*h));{slope value, highest value is the sharpest image}
  average:=average/(w*h);{calculate average pixel value}
  result:=4*average/(result+0.000000000000000001);{turn the curve upside down and scale simular as HFD values. A lower value indicates a sharper image. Prevent error for full fully saturated images by adding 0.00000000000001}
end;



end.

