unit unit_yuv4mpeg2;{writes YUV4MPEG2 uncompressed video}

{Copyright (C) 2020 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This program is free software: you can redistribute it and/or modify
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

uses
  Classes, SysUtils,dialogs,graphics,
  LCLType, // HBitmap type
  IntfGraphics, // TLazIntfImage type
  fpImage, // TFPColor type;
  lclintf;

function write_yuv4mpeg2_header(filen: string; colour : boolean): boolean;{open/create file}
function write_yuv4mpeg2_frame(colour: boolean): boolean; {write frames in 444p style colour or mono}
procedure close_yuv4mpeg2; {close file}

implementation

uses astap_main;
var
  TheFile : tfilestream;


function write_yuv4mpeg2_header(filen: string; colour : boolean): boolean;{open/create file}
var
  header: array[0..41] of ansichar;
  value: string;
begin
  result:=false;

  value:=InputBox('Video frame rate in [frames/second]:','','3' );
  if value=''  then exit;

  try
   TheFile:=tfilestream.Create(filen, fmcreate );
  except
   TheFile.free;
   exit;
  end;
  {'YUV4MPEG2 W0384 H0288 F01:1 Ip A0:0 C444'+#10}    {See https://wiki.multimedia.cx/index.php/YUV4MPEG2}
  {width2:=mainwindow.image1.Picture.Bitmap.width; Note use external width2 since loading an image could be outstanding}
  {height2:=mainwindow.image1.Picture.Bitmap.height;}
  if colour then header:=pansichar('YUV4MPEG2 W'+inttostr(width2)+' H'+inttostr(height2)+' F'+trim(value)+':1 Ip A0:0 C444'+#10)
            else header:=pansichar('YUV4MPEG2 W'+inttostr(width2)+' H'+inttostr(height2)+' F'+trim(value)+':1 Ip A0:0 Cmono'+#10);
  { Write header }
  thefile.writebuffer ( header, strlen(Header));
end;

function write_yuv4mpeg2_frame(colour: boolean): boolean; {write frames in 444p style, colour or mono}
type
  PRGBTripleArray = ^TRGBTripleArray; {for fast pixel routine}
  {$ifdef mswindows}
  TRGBTripleArray = array[0..trunc(bufwide/3)] of TRGBTriple; {for fast pixel routine}
  {$else} {unix}
  TRGBTripleArray = array[0..trunc(bufwide/3)] of tagRGBQUAD; {for fast pixel routine}
  {$endif}
var
  k,xx,yy,steps  : integer;
  r,g,b              : byte;
  pixelrow1   : PRGBTripleArray;{for fast pixel routine}
  row         : array of byte;
  dum : double;
const
  head: array[0..5] of ansichar=(('F'),('R'),('A'),('M'),('E'),(#10));

begin
  result:=true;
  try
    thefile.writebuffer ( head, strlen(Head));
    {width2:=mainwindow.image1.Picture.Bitmap.width; Note already set}
    {height2:=mainwindow.image1.Picture.Bitmap.height;}

    setlength(row, width2);
    {for colour write Y, U, V frame else only Y}
    {444 frames:   Y0 (full frame), U0,V0 Y1 U1 V1 Y2 U2 V2                 422 frames:  Y0 (U0+U1)/2 Y1 (V0+V1)/2 Y2 (U2+U3)/2 Y3 (V2+V3)/2}

    // write full Y frame
    //YYYY
    //YYYY
    //YYYY
    //YYYY

    // write full U frame
    //UUUU
    //UUUU
    //UUUU
    //UUUU

    // write full V frame
    //VVVV
    //VVVV
    //VVVV
    //VVVV

    if colour then steps:=2 {colour} else steps:=0;{mono}

    for k:=0 to steps {0 or 2} do {do Y,U, V frame, so scan image 3 times}
    for yy := 0 to height2-1 do
    begin // scan each line
      pixelrow1:=mainwindow.image1.Picture.Bitmap.ScanLine[yy];
      for xx := 0 to width2-1 do
      begin
        R :=pixelrow1[xx].rgbtRed;
        G :=pixelrow1[xx].rgbtGreen;
        B :=pixelrow1[xx].rgbtBlue;
        if k=0 then
          row[xx]:=trunc(R*77/256 + G*150/256 + B*29/256)        {Y frame, Full swing for BT.601}
        else
        if k=1 then
           row[xx]:=trunc(R*-43/256 + G*-84/256 + B*127/256 +128) {U frame}
        else
           row[xx]:=trunc(R*127/256 + G*-106/256 + B*-21/256 +128){V frame}
      end;
      thefile.writebuffer(row[0],length(row));
    end;
  except
    result:=false;
    row:=nil;
    exit;
  end;
  row:=nil;
end;


procedure close_yuv4mpeg2;
begin
  thefile.free;
end;

end.

