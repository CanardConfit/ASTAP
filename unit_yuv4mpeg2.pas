unit unit_yuv4mpeg2;{writes YUV4MPEG2 uncompressed video file. Pixels are taken from Timage}
{$MODE Delphi}
{Copyright (C) 2017-2023 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

//  This source code is available at:
// Master:
//   https://sourceforge.net/p/astap-program/
// Irregularly updated:
//   https://github.com/han-k59/astap

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
function yuv4mpeg2_write_error: boolean;{true if anything went wrong between the header and close_yuv4mpeg2}

implementation

uses astap_main;
var
  theFile : tfilestream=nil; {nil when no file is open. Never leave a dangling pointer in here}
  yuv_failure : boolean=false;{sticky error flag for the whole header..frames..close sequence}


procedure close_yuv_file;{close the file if one is open. Safe to call at any time, also twice}
begin
  FreeAndNil(TheFile);{Free on nil is allowed. Setting to nil afterwards prevents a double free on the next export}
end;


function yuv4mpeg2_write_error: boolean;{true if anything went wrong between the header and close_yuv4mpeg2}
begin
  result:=yuv_failure;
end;

function write_yuv4mpeg2_header(filen, framerate: string; colour : boolean; w, h {size}: integer): boolean;{open/create file. Result is false if failure}
var
  header: ansistring;{was a fixed array[0..41] which is too small for a Cmono header or a wide image}
begin
  result:=false;
  yuv_failure:=false;{start of a new video}
  close_yuv_file;{in case an earlier export was aborted without reaching close_yuv4mpeg2}

  {'YUV4MPEG2 W0384 H0288 F01:1 Ip A0:0 C444'+#10}    {See https://wiki.multimedia.cx/index.php/YUV4MPEG2}
  if colour then header:='YUV4MPEG2 W'+inttostr(w)+' H'+inttostr(h)+' F'+trim(framerate)+':1 Ip A0:0 C444'+#10
            else header:='YUV4MPEG2 W'+inttostr(w)+' H'+inttostr(h)+' F'+trim(framerate)+':1 Ip A0:0 Cmono'+#10;{width, height,frame rate, interlace progressive, unknown aspect, color space}

  try
   TheFile:=tfilestream.Create(filen, fmcreate );
  except
   TheFile:=nil;{the assignment above never happened. Do NOT call Free on it}
   yuv_failure:=true;
   exit;
  end;

  { Write header }
  try
    thefile.writebuffer(header[1],length(header));{length in bytes, no #0 terminator involved}
  except
    yuv_failure:=true;
    close_yuv_file;{disk full or write protected. Do not leave the handle open}
    exit;
  end;
  result:=true;
end;

function write_yuv4mpeg2_frame(colour: boolean;x,y,w,h: integer): boolean; {reads pixels from Timage and writes YUV frames in 444p style, colour or mono. Call this procedure for each image}
var
  k,xx,yy,steps  : integer;
  r,g,b              : byte;
  row         : array of byte;
  xLine       :  PByteArray;
const
  header: array[0..5] of ansichar=(('F'),('R'),('A'),('M'),('E'),(#10));

begin
  result:=false;
  if TheFile=nil then exit;{no file open. write_yuv4mpeg2_header failed, or was never called}

  try
    thefile.writebuffer(header,sizeof(header)); {write FRAME+#10. sizeof, not strlen: the const has no #0 terminator}

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
      xLine:=mainform1.image1.Picture.Bitmap.ScanLine[yy];
      for xx := x to x+w-1 {width} do
      begin
       {$ifdef mswindows}
          B:=xLine^[xx*3]; {3*8=24 bit}
          G:=xLine^[xx*3+1]; {fast pixel write routine }
          R:=xLine^[xx*3+2];
       {$endif}
       {$ifdef darwin} {MacOS}
          R:=xLine^[xx*4+1]; {4*8=32 bit}
          G:=xLine^[xx*4+2]; {fast pixel write routine }
          B:=xLine^[xx*4+3];
       {$endif}
       {$ifdef linux}
          B:=xLine^[xx*4]; {4*8=32 bit}
          G:=xLine^[xx*4+1]; {fast pixel write routine }
          R:=xLine^[xx*4+2];
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
    result:=true;
  except
    yuv_failure:=true;
    close_yuv_file;{the video is beyond repair, stop writing. close_yuv4mpeg2 will do nothing}
  end;
  row:=nil;
end;


procedure close_yuv4mpeg2; {close file}
begin
  close_yuv_file;{safe when already closed after an earlier error, or never opened}
end;

end.
