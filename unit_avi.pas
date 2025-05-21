unit unit_avi;{writes uncompressed video to an avi file (AVI=Audio Video Interleave format). This unit writes RGB 24 bit format for colour and monochrome images. Pixels information is are taken from Timage (screen)}
{Copyright (C) 2022 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils,dialogs,graphics,
  LCLType,      // For RGBtriple
  IntfGraphics, // TLazIntfImage type
  fpImage,      // TFPColor type;
  lclintf,
  math;

function write_avi_head(filen, frame_rate: string;  nrframes, w,h: integer): boolean;{open/create file and writes head. Result is false if failure}
function write_avi_frame(x,y,w,h: integer): boolean; {reads pixels from Timage and writes YUV frames in 444p style, colour or mono. Call this procedure for each image. Result is false if failure}
procedure close_the_avi(nrframes: integer);

implementation

uses astap_main;

var
  theFile : tfilestream;
  zero_dword : dword=0; // used for up the 3 extra zeros behind each image line depending on the with of the line
  extra      : integer; // number of extra zero's behind each line

const
  nrcolors=3; // should be fixed at colour. Mono is not standarised in AVI

type
  header = record
      riff     : dword;  //'RIFF' fileSize fileType (data)
      riffsize : dword;  // fileSize is a 4-byte value giving the size of the data in the file.  (filesize -8)
                         // The value of fileSize includes the size of the fileType FOURCC plus the size of the data that follows.
      avi  : dword;      // fileType is a FOURCC that identifies the specific file type
      list : dword;      // A list has the following form:    'LIST' listSize listType listData
        lsize : dword;   // listsize
        hdrL  : dword;   //
        fcc   : dword;   // avih
        cb: dword;       // Specifies the size of the structure, not including the initial 8 bytes.
        {===================}
          dwMicroSecPerFrame: dword; // frame display rate (or 0)
          dwMaxBytesPerSec : dword;  // max. transfer rate
          dwPaddingGranularity : dword; // pad to multiples of this size
          dwFlags : dword; // Flags
          dwTotalFrames : dword; // Number frames in file
          dwInitialFrames : dword;
          dwStreams : dword;  // Number of streams in the file
          dwSuggestedBufferSize : dword;
          dwWidth : dword;
          dwHeight : dword;
          dwReserved1 : dword;
          dwReserved2 : dword;
          dwReserved3 : dword;
          dwReserved4 : dword;
     end;
var
  head : header=
            (riff     :$46464952; // 'RIFF'
             riffsize :0;
             avi  :$20495641; // AVI
             list :$5453494C; // LIST
             lsize:$000000C0; //
             hdrL :$6C726468; // hdrL
              fcc :$68697661; // avih
               cb :$00000038; // 14*4=56 Specifies the size of the structure, not including the initial 8 bytes.
             {===================}
               dwMicroSecPerFrame: $000F4240; // 1 sec, MicroSecPerFrame, frame display rate (or 0)
               dwMaxBytesPerSec : $0; // max. transfer rate
               dwPaddingGranularity :$0; // pad to multiples of this size
               dwFlags : $00000010; // flags
               dwTotalFrames : $0; // # frames in file
               dwInitialFrames : $0;
               dwStreams : 1;  // Number of streams in the file
               dwSuggestedBufferSize : $0;
               dwWidth : 16;
               dwHeight : 8;
               dwReserved1 : 0;
               dwReserved2 : 0;
               dwReserved3 : 0;
               dwReserved4 : 0);


type
  streamheader = record  // AVIStreamHeader;
      list : dword;  // A list has the following form:   'LIST' listSize listType listData
      size: dword;
      strl : dword; // length chunk
      {===================}
      strh : dword; // stream header
      hsize: dword;    // length 56

        fccType: dword;// vids
        fccHandler : dword; // codec to be used.
        dwFlags : dword;
        wPriority : word;
        wLanguage : word;
        dwInitialFrames: dword;
        dwScale: dword;
        dwRate: dword; //* dwRate / dwScale == samples/second */
        dwStart: dword;
        dwLength: dword; //* In units above... */
        dwSuggestedBufferSize: dword;
        dwQuality: dword;
        dwSampleSize: dword;
        rcframew1: word;
        rcframeh1: word;
        rcframew2: word;
        rcframeh2: word;

        strf : dword;   // stream format
        Ssize: dword;
        fsize: dword;   // length 40
          width: dword;
          height: dword;
          planes: word;   // number of planes , 1
          bitcount: word; // number of bits per pixel
          compression: dword;
          sizeimage  : dword; // uncompressed size in bytes.
          pixels_per_meterH: dword;// 0
          pixels_per_meterV: dword;// 0
          nr_colours_used: dword;  // 0 is maximum
          nr_important_colours: dword;// 0 is all
   end;
var
  streamhead : streamheader=
       (  list :$5453494C; // 'LIST'
          size :$74;
          strl :$6C727473; // 'strl'

          strh :$68727473; // 'strh'
          hsize:$00000038; // 56
            fcctype:$73646976; // 'vids'
            fccHandler: $0 ;   // codex
            dwFlags : 0;
            wPriority : 0;
            wLanguage : 0;
            dwInitialFrames: 0;
            dwScale: 1;
            dwRate:  1;  //* dwRate / dwScale == samples/second */
            dwStart: 0;
            dwLength: 0; //* In units above... */  size of stream in units as defined in dwRate and dwScale {here number of frames}
            dwSuggestedBufferSize: 0; // to be set later
            dwQuality: 0;
            dwSampleSize: 0;
            rcframew1: 0;   // rect, specified in four words
            rcframeh1: 0;
            rcframew2: 200; // width
            rcframeh2: 100; // height

            strf : $66727473; //stream format
              ssize: 40;
              fsize: 40;    // length 40

              width: 200;
              height:100;
              planes: 1;    // number of planes , 1
              bitcount: 24; // number of bits per pixel
              compression:0;
              sizeimage  : 200*100+200;// uncompressed in bytes plus extra zeros defind by extra.
              pixels_per_meterH: $0EC4;// 0
              pixels_per_meterV: $0EC4;// 0
              nr_colours_used: 0;      // 0 is maximum
              nr_important_colours: 0; // 0 is all
            );


type
  moviheader = record  // AVIStreamHeader;
      list : dword;    // A list has the following form:   'LIST' listSize listType listData
      size: dword;
      movi: dword;
  end;
var
  movihead: moviheader=
       (  list :$5453494C; //'LIST'
          size :$0;        // width x length x bitperpixel
          movi: $69766F6D);

type
   framestart =record
        db : dword;
         x : dword;
   end;
var
  frame_start:framestart=
     (db : $62643030;//'00db'
      x  : $0); // blocksize, to be set later


type
   indexstart =record
       idx1 : dword;
        size: dword; // length of index, nrrecords*$10
   end;
var
  index_start:indexstart=
     (idx1 : $31786469;//'idx1'
      size : $0); // length of index, nrrecords*$10, to be set later


type
   index =record
        db  : dword;
         x  : dword;
   position : dword;
       size : dword;
   end;
var
  indx: index=
     (db   :$62643030;//'00db'
       x   :$10;
 position  :$0;
      size :$0);




function write_avi_head(filen, frame_rate: string; nrframes, w,h: integer): boolean;{open/create file and writes head. Result is false if failure}
begin
  result:=false; // assume failure
  head.dwwidth:= w;
  head.dwheight:= h;

  extra:=(w*nrcolors mod 4);// Each written image line should be a multiple of 4 bytes. Add extra $0 bytes to achieve that. w*nrcolors is 15 => add one zero,  16 => add two zeros, 17 => add three zeros, 18 => add none. Found by reverse engineering.
  if extra<>0 then extra:=4-extra;

  head.dwTotalFrames:=nrframes;

  head.dwMicroSecPerFrame:=round(1000000/max(strtofloat(frame_rate),0.00001));

  streamhead.bitcount:=8*nrcolors;
  streamhead.width:=w;
  streamhead.height:=h;
  streamhead.rcframew2:=w;
  streamhead.rcframeh2:=h;

  streamhead.sizeimage:=w * h * (streamhead.bitcount div 8)+h*extra {zeros behind each line}; {in bytes}
  streamhead.dwLength:=head.dwTotalFrames;
  streamhead.dwSuggestedBufferSize:= streamhead.sizeimage;
  head.dwSuggestedBufferSize:= streamhead.sizeimage;


  movihead.size:= 4 {length dword movi}+(streamhead.sizeimage+sizeof(frame_start))*head.dwTotalFrames;
  head.riffsize:=sizeof(head)-8+sizeof(streamhead)+sizeof(movihead)+ ( sizeof(frame_start)+ streamhead.sizeimage+ sizeof(indx))*head.dwTotalFrames+sizeof(indexstart) ;
  frame_start.x:= streamhead.sizeimage;


  try
    TheFile:=tfilestream.Create(filen, fmcreate );
  except
    TheFile.free;
    exit;
  end;

  thefile.writebuffer(head,sizeof(head));
  thefile.writebuffer(streamhead,sizeof(streamhead));
  thefile.writebuffer(movihead,sizeof(movihead));
  result:=true;
end;


function write_avi_frame(x,y,w,h: integer): boolean; {reads pixels from Timage and writes AVI frame. Call this procedure for each image. Result is false if failure}
var
  xx,yy       : integer;
  r,g,b       : byte;
  row         : array of byte;
  xLine       :  PByteArray;
begin
  result:=true;
  try
    thefile.writebuffer(frame_start,sizeof(frame_start)); {write 00db header}
    setlength(row, nrcolors*w {width});
    for yy := y+h-1 downto y {height} do
    begin // scan each timage line
      xLine:=mainform1.image1.Picture.Bitmap.ScanLine[yy];
      for xx := x to x+w-1 {width} do
      begin
       {$ifdef mswindows}
          B:=xLine^[xx*3];   {3*8=24 bit}
          G:=xLine^[xx*3+1]; {fast pixel write routine }
          R:=xLine^[xx*3+2];
       {$endif}
       {$ifdef darwin} {MacOS}
          R:=xLine^[xx*4+1]; {4*8=32 bit}
          G:=xLine^[xx*4+2]; {fast pixel write routine }
          B:=xLine^[xx*4+3];
       {$endif}
       {$ifdef linux}
          B:=xLine^[xx*4];   {4*8=32 bit}
          G:=xLine^[xx*4+1]; {fast pixel write routine }
          R:=xLine^[xx*4+2];
        {$endif}

        row[nrcolors *(xx-x)]  :=B;
        row[nrcolors *(xx-x)+1]:=G;
        row[nrcolors *(xx-x)+2]:=R;

    //    row[(xx-x)]  :=trunc((R+G+B)/3);  // Mono seams not a valid option with .avi

      end;
      thefile.writebuffer(row[0],length(row));
      thefile.writebuffer(zero_dword,extra); // Add extra zeros 0,1,2,3 depending on width to make it a mulitiply of 4 bytes. Found by reverse engineering.
    end;
  except
    result:=false;
    row:=nil;
    exit;
  end;
  row:=nil;
end;


procedure close_the_avi(nrframes: integer);
var
   i: integer;
begin
  index_start.size:=nrframes*$10;// index length in bytes
  thefile.writebuffer(index_start,sizeof(index_start));
  indx.position:=$4;
  indx.size:=streamhead.sizeimage;
  for i:=1 to nrframes do
  begin
    thefile.writebuffer(indx,sizeof(indx));
    indx.position:=indx.position+sizeof(frame_start)+streamhead.sizeimage;
  end;

  thefile.free;
end;

end.

