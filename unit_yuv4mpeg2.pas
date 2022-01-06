unit unit_yuv4mpeg2;{writes YUV4MPEG2 uncompressed video file. Pixels are taken from Timage}
{$MODE Delphi}
{Copyright (C) 2017, 2022 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils,dialogs,graphics,
  LCLType, // for RGBtriple
  IntfGraphics, // TLazIntfImage type
  fpImage, // TFPColor type;
  lclintf;

function write_yuv4mpeg2_header(filen, framerate: string; colour : boolean; w,h: integer): boolean;{open/create file. Result is false if failure}
function write_yuv4mpeg2_frame(colour: boolean; x,y,w,h: integer): boolean; {reads pixels from Timage and writes YUV frames in 444p style, colour or mono. Call this procedure for each image. Result is false if failure}
procedure close_yuv4mpeg2; {close file}

implementation

uses astap_main;
var
  theFile : tfilestream;

function write_yuv4mpeg2_header(filen, framerate: string; colour : boolean; w, h {size}: integer): boolean;{open/create file. Result is false if failure}
var
  header: array[0..41] of ansichar;
begin
  result:=false;

  try
   TheFile:=tfilestream.Create(filen, fmcreate );
  except
   TheFile.free;
   exit;
  end;
  {'YUV4MPEG2 W0384 H0288 F01:1 Ip A0:0 C444'+#10}    {See https://wiki.multimedia.cx/index.php/YUV4MPEG2}
  if colour then header:=pansichar('YUV4MPEG2 W'+inttostr(w)+' H'+inttostr(h)+' F'+trim(framerate)+':1 Ip A0:0 C444'+#10)
            else header:=pansichar('YUV4MPEG2 W'+inttostr(w)+' H'+inttostr(h)+' F'+trim(framerate)+':1 Ip A0:0 Cmono'+#10);{width, height,frame rate, interlace progressive, unknown aspect, color space}
  { Write header }
  thefile.writebuffer ( header, strlen(Header));
end;

function write_yuv4mpeg2_frame(colour: boolean;x,y,w,h: integer): boolean; {reads pixels from Timage and writes YUV frames in 444p style, colour or mono. Call this procedure for each image}
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
const
  header: array[0..5] of ansichar=(('F'),('R'),('A'),('M'),('E'),(#10));

begin
  result:=true;
  try
    thefile.writebuffer ( header, strlen(header)); {write FRAME+#10}

    setlength(row, w {width});

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

    if colour then steps:=2 {colour} else steps:=0;{mono}    {for colour write Y, U, V frame else only Y}

    for k:=0 to steps {0 or 2} do {do Y,U, V frame, so scan image line 3 times}
    for yy := y to y+h-1 {height} do
    begin // scan each timage line
      pixelrow1:=mainwindow.image1.Picture.Bitmap.ScanLine[yy];
      for xx := x to x+w-1 {width} do
      begin
       {$ifdef mswindows}
        R :=pixelrow1[xx].rgbtRed;
        G :=pixelrow1[xx].rgbtGreen;
        B :=pixelrow1[xx].rgbtBlue;
       {$endif}
       {$ifdef linux}
        R :=pixelrow1[xx].rgbRed;
        G :=pixelrow1[xx].rgbGreen;
        B :=pixelrow1[xx].rgbBlue;

       {$endif}
       {$ifdef darwin} {MacOS}
        R :=pixelrow1[xx].rgbGreen; {different color arrangment in Macos !!!!!}
        G :=pixelrow1[xx].rgbRed;
        B :=pixelrow1[xx].rgbreserved;
       {$endif}

        if k=0 then
          row[xx-x]:=trunc(R*77/256 + G*150/256 + B*29/256)        {Y frame, Full swing for BT.601}
        else
        if k=1 then
           row[xx-x]:=trunc(R*-43/256 + G*-84/256 + B*127/256 +128) {U frame}
        else
        row[xx-x]:=trunc(R*127/256 + G*-106/256 + B*-21/256 +128){V frame}
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


procedure close_yuv4mpeg2; {close file}
begin
  thefile.free;
end;

end.

