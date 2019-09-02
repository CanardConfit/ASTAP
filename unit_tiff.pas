unit unit_tiff;
{Based on 8 bit routines from bit2tiff.pas,  BMP to TIFF, Freeware version 3.0 - Sep 10, 2000 by Wolfgang Krug}
{Modified to 16bit & 32bit grayscale & RGB48 RGB96  colour in 2018 by Han Kleijn}
{freeware}

interface

uses
{$ifdef mswindows}
 Windows,
   {$IFDEF fpc}{mswindows & FPC}
   {$else} {delphi}

   {$endif}
{$else} {unix}

 {$endif}



{Messages,} SysUtils, Classes,dialogs,
      astap_main {for img_array type}
      ;

//function save_tiff_48(img: image_array; wide2,height2:integer; filen2:ansistring;flip_H,flip_V:boolean): boolean;{save to 48=3x16 color TIFF file }
function save_tiff_96(img: image_array; wide2,height2:integer; filen2:ansistring;flip_H,flip_V:boolean): boolean;{save to 96=3x32 color TIFF file }

//function save_tiff_16(img: image_array; wide2,height2:integer; filen2:ansistring;flip_H,flip_V:boolean): boolean;{save to 16 bit gray scale TIFF file }
function save_tiff_32(img: image_array; wide2,height2:integer; filen2:ansistring;flip_H,flip_V:boolean): boolean;{save to 32 bit gray scale TIFF file }

implementation
type
  PDirEntry = ^TDirEntry;
  TDirEntry = record
    _Tag    : Word;
    _Type   : Word;
    _Count  : LongInt;
    _Value  : LongInt;
  end;


var     tiffbuffer32: array[0..trunc(bufwide/4)] of Dword; {bufwide is set in astap_main and is 120000}
        tiffbuffer: array[0..bufwide] of byte absolute tiffbuffer32;

const
    { TIFF File Header: }
	TifHeader : array[0..7] of Byte = (
            $49, $49,                 { Intel byte order }
            $2a, $00,                 { TIFF version (42) }
            $08, $00, $00, $00 );     { Pointer to the first directory }


//   NoOfDirsBW16 : array[0..1] of Byte = ( $0E, $00 );	{ Number of tags within the directory }

//  	DirectoryBW16 : array[0..13] of TDirEntry = (
// ( _Tag: $00FE; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { NewSubFile: Image with full solution (0) }
// ( _Tag: $0100; _Type: $0003; _Count: $00000001; _Value: $00000000 ),  { ImageWidth:      Value will be set later }
// ( _Tag: $0101; _Type: $0003; _Count: $00000001; _Value: $00000000 ),  { ImageLength:     Value will be set later }
// ( _Tag: $0102; _Type: $0003; _Count: $00000001; _Value: $00000010 ),  { BitsPerSample $10=16 ,no address         }
// ( _Tag: $0103; _Type: $0003; _Count: $00000001; _Value: $00000001 ),  { Compression:     No compression          }
// ( _Tag: $0106; _Type: $0003; _Count: $00000001; _Value: $00000001 ),  { PhotometricInterpretation:   0, 1        }

// ( _Tag: $0111; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { StripOffsets: Ptr to the adress of the image data }
// ( _Tag: $0115; _Type: $0003; _Count: $00000001; _Value: $00000001 ),  { SamplesPerPixels: 1                      }
// ( _Tag: $0116; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { RowsPerStrip: Value will be set later    }
// ( _Tag: $0117; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { StripByteCounts: xs*ys bytes pro strip   }
// ( _Tag: $011A; _Type: $0005; _Count: $00000001; _Value: $00000000 ),  { X-Resolution: Adresse                    }
// ( _Tag: $011B; _Type: $0005; _Count: $00000001; _Value: $00000000 ),  { Y-Resolution: (Adresse)                  }
// ( _Tag: $0128; _Type: $0003; _Count: $00000001; _Value: $00000002 ),  { Resolution Unit: (2)= Unit ZOLL          }
// ( _Tag: $0131; _Type: $0002; _Count: $0000000A; _Value: $00000000 )); { Software:                                }


    NoOfDirsBW32 : array[0..1] of Byte = ( $0E, $00 );	{ Number of tags within the directory }

  	DirectoryBW32 : array[0..13] of TDirEntry = (
 ( _Tag: $00FE; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { NewSubFile: Image with full solution (0) }
 ( _Tag: $0100; _Type: $0003; _Count: $00000001; _Value: $00000000 ),  { ImageWidth:      Value will be set later }
 ( _Tag: $0101; _Type: $0003; _Count: $00000001; _Value: $00000000 ),  { ImageLength:     Value will be set later }
 ( _Tag: $0102; _Type: $0003; _Count: $00000001; _Value: $00000020 ),  { BitsPerSample $10=16 ,no address         }
 ( _Tag: $0103; _Type: $0003; _Count: $00000001; _Value: $00000001 ),  { Compression:     No compression          }
 ( _Tag: $0106; _Type: $0003; _Count: $00000001; _Value: $00000001 ),  { PhotometricInterpretation:   0, 1        }

 ( _Tag: $0111; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { StripOffsets: Ptr to the adress of the image data }
 ( _Tag: $0115; _Type: $0003; _Count: $00000001; _Value: $00000001 ),  { SamplesPerPixels: 1                      }
 ( _Tag: $0116; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { RowsPerStrip: Value will be set later    }
 ( _Tag: $0117; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { StripByteCounts: xs*ys bytes pro strip   }
 ( _Tag: $011A; _Type: $0005; _Count: $00000001; _Value: $00000000 ),  { X-Resolution: Adresse                    }
 ( _Tag: $011B; _Type: $0005; _Count: $00000001; _Value: $00000000 ),  { Y-Resolution: (Adresse)                  }
 ( _Tag: $0128; _Type: $0003; _Count: $00000001; _Value: $00000002 ),  { Resolution Unit: (2)= Unit ZOLL          }
 ( _Tag: $0131; _Type: $0002; _Count: $0000000A; _Value: $00000000 )); { Software:                                }



//  NoOfDirsRGB48 : array[0..1] of Byte = ( $0F, $00 );	{ Number of tags within the directory }

//	DirectoryRGB48 : array[0..14] of TDirEntry = (
// ( _Tag: $00FE; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { NewSubFile:      Image with full solution (0) }
// ( _Tag: $0100; _Type: $0003; _Count: $00000001; _Value: $00000000 ),  { ImageWidth:      Value will be set later      }
// ( _Tag: $0101; _Type: $0003; _Count: $00000001; _Value: $00000000 ),  { ImageLength:     Value will be set later      }
// ( _Tag: $0102; _Type: $0003; _Count: $00000003; _Value: $00000000 ),  { BitsPerSample address will be written later   }
// ( _Tag: $0103; _Type: $0003; _Count: $00000001; _Value: $00000001 ),  { Compression:     No compression               }
// ( _Tag: $0106; _Type: $0003; _Count: $00000001; _Value: $00000002 ),  { PhotometricInterpretation:
//                                                                          0=black, 2 power BitsPerSample -1 =white }
// ( _Tag: $0111; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { StripOffsets: Ptr to the adress of the image data }
// ( _Tag: $0115; _Type: $0003; _Count: $00000001; _Value: $00000003 ),  { SamplesPerPixels: 3                         }
// ( _Tag: $0116; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { RowsPerStrip: Value will be set later         }
// ( _Tag: $0117; _Type: $0004; _Count: $00000001; _Value: $00000000 ),	 { StripByteCounts: xs*ys bytes pro strip        }
// ( _Tag: $011A; _Type: $0005; _Count: $00000001; _Value: $00000000 ),	 { X-Resolution: Adresse                         }
// ( _Tag: $011B; _Type: $0005; _Count: $00000001; _Value: $00000000 ),	 { Y-Resolution: (Adresse)                       }
// ( _Tag: $011C; _Type: $0003; _Count: $00000001; _Value: $00000001 ),	 { PlanarConfiguration:
//                                                                           Pixel data will be stored continous         }
// ( _Tag: $0128; _Type: $0003; _Count: $00000001; _Value: $00000002 ),	 { Resolution Unit: (2)= Unit ZOLL               }
// ( _Tag: $0131; _Type: $0002; _Count: $0000000A; _Value: $00000000 )); { Software:                                     }


  NoOfDirsRGB96 : array[0..1] of Byte = ( $0F, $00 );	{ Number of tags within the directory }

	DirectoryRGB96 : array[0..14] of TDirEntry = (
 ( _Tag: $00FE; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { NewSubFile:      Image with full solution (0) }
 ( _Tag: $0100; _Type: $0003; _Count: $00000001; _Value: $00000000 ),  { ImageWidth:      Value will be set later      }
 ( _Tag: $0101; _Type: $0003; _Count: $00000001; _Value: $00000000 ),  { ImageLength:     Value will be set later      }
 ( _Tag: $0102; _Type: $0003; _Count: $00000003; _Value: $00000000 ),  { BitsPerSample address will be written later   }
 ( _Tag: $0103; _Type: $0003; _Count: $00000001; _Value: $00000001 ),  { Compression:     No compression               }
 ( _Tag: $0106; _Type: $0003; _Count: $00000001; _Value: $00000002 ),  { PhotometricInterpretation:
                                                                          0=black, 2 power BitsPerSample -1 =white }
 ( _Tag: $0111; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { StripOffsets: Ptr to the adress of the image data }
 ( _Tag: $0115; _Type: $0003; _Count: $00000001; _Value: $00000003 ),  { SamplesPerPixels: 3                         }
 ( _Tag: $0116; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { RowsPerStrip: Value will be set later         }
 ( _Tag: $0117; _Type: $0004; _Count: $00000001; _Value: $00000000 ),  { StripByteCounts: xs*ys bytes pro strip        }
 ( _Tag: $011A; _Type: $0005; _Count: $00000001; _Value: $00000000 ),  { X-Resolution: Adresse                         }
 ( _Tag: $011B; _Type: $0005; _Count: $00000001; _Value: $00000000 ),  { Y-Resolution: (Adresse)                       }
 ( _Tag: $011C; _Type: $0003; _Count: $00000001; _Value: $00000001 ),  { PlanarConfiguration:
                                                                          Pixel data will be stored continous          }
 ( _Tag: $0128; _Type: $0003; _Count: $00000001; _Value: $00000002 ),  { Resolution Unit: (2)= Unit ZOLL               }
 ( _Tag: $0131; _Type: $0002; _Count: $0000000A; _Value: $00000000 )); { Software:                                     }

  NullString      : array[0..3] of Byte     = ( $00, $00, $00, $00 );
  X_Res_Value     : array[0..7] of Byte     = ( $6D,$03,$00,$00,  $0A,$00,$00,$00 );  { Value for X-Resolution:
                                                                                  87,7 Pixel/Zoll (SONY SCREEN) }
  Y_Res_Value     : array[0..7] of Byte     = ( $6D,$03,$00,$00,  $0A,$00,$00,$00 );  { Value for Y-Resolution: 87,7 Pixel/Zoll }
  Software        : array[0..9] of ansiChar = ( 'h', 'n', 's', 'k', 'y', '.', 'o', 'r', 'g', #0);
//BitsPerSample48 : array[0..2] of Word = ($0010,$0010,$0010 );{8 or 16=$10}
  BitsPerSample96 : array[0..2] of Word = ($0020,$0020,$0020 );{8 or 16=$10}


 {following routine is no longer used}
//function save_tiff_48(img: image_array; wide2,height2:integer; filen2:ansistring;flip_H,flip_V:boolean): boolean;{save to 48=3x16 color TIFF file

//var
//  OffsetXRes     : LongInt;
//  OffsetYRes     : LongInt;
//  OffsetSoftware : LongInt;
//  OffsetStrip    : LongInt;
//  OffsetDir      : LongInt;
//  OffsetBitsPerSample : LongInt;

//var
//  thefile : tfilestream;
//  i,j,k,m : integer;
//  dum: double;
//  dummy : word;
//begin
//  result:=false;
//  filen2:=ChangeFileExt(Filen2,'.tif');
//  if fileexists(filen2)=true then
//    if MessageDlg('Existing file ' +filen2+ ' Overwrite?', mtConfirmation, [mbYes, mbNo], 0) <> 6 {mbYes} then
//      Exit;

//  try
//   thefile:=tfilestream.Create(filen2, fmcreate );
//  except
//   thefile.free;
//   exit;
//  end;


// Directoryrgb48[1]._Value := LongInt(Wide2);        { Image Width }
// Directoryrgb48[2]._Value := LongInt(Height2);      { Image Height }
// Directoryrgb48[8]._Value := LongInt(Height2);      { Image Height }
// Directoryrgb48[9]._Value := LongInt(2*3*Wide2*Height2);{ Strip Byte Counts }


 { Write TIFF - File for Image with RGB-Values }
 { ------------------------------------------- }
 { Write Header }
//  thefile.writebuffer ( TifHeader, sizeof(TifHeader));

//  OffsetXRes := thefile.Position ;
//  thefile.writebuffer ( X_Res_Value, sizeof(X_Res_Value));

//  OffsetYRes := thefile.Position ;
//  thefile.writebuffer ( Y_Res_Value, sizeof(Y_Res_Value));

//  OffsetBitsPerSample := Thefile.Position ; {where is sample located}
//  Thefile.writebuffer ( BitsPerSample48,  sizeof(BitsPerSample48));

//  OffsetSoftware := thefile.Position ;
//  thefile.writebuffer ( Software, sizeof(Software));

//  OffsetStrip := thefile.Position ;

  { Write Image Data }
//  for i:=0 to Height2-1 do
//  begin
//    if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
//    for j:=0 to wide2-1 do
//      begin
//       if flip_H=true then m:=wide2-1-j else m:=j;
//       dum:=img[0,m,k]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
//       tiffbuffer[m*6  ]  :=lo(dummy);
//       tiffbuffer[m*6+1]  :=hi(dummy);
//       dum:=img[1,m,k]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
//       tiffbuffer[m*6+2]  :=lo(dummy);
//       tiffbuffer[m*6+3]  :=hi(dummy);
//       dum:=img[2,m,k]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
//       tiffbuffer[m*6+4]  :=lo(dummy);
//       tiffbuffer[m*6+5]  :=hi(dummy);
//     end;
//     thefile.writebuffer(tiffbuffer,wide2*6{size 2x6}) ;{works only for byte arrays}
//   end;

	{ Set Offset - Adresses into Directory }
//  DirectoryRGB48[ 3]._Value := OffsetBitsPerSample; 	{ BitsPerSample location containing 1000 1000 1000  (16,16,16)}
//  Directoryrgb48[ 6]._Value := OffsetStrip; 	      { StripOffset, location of start image data}
//  Directoryrgb48[10]._Value := OffsetXRes; 		      { X-Resolution  }
//  Directoryrgb48[11]._Value := OffsetYRes; 		      { Y-Resolution  }
//  Directoryrgb48[14]._Value := OffsetSoftware; 	    { Software      }

	{ Write Directory }
//  OffsetDir := thefile.Position ;{where is the IFD directory}
//	thefile.writebuffer ( NoOfDirsRGB48, sizeof(NoOfDirsRGB48));{number of directory entries}
//	thefile.writebuffer ( Directoryrgb48, sizeof(Directoryrgb48));
//	thefile.writebuffer ( NullString, sizeof(NullString));

	{ Update Start of IFD Directory }
  {all programs write IFD after image data, could be written before image data}
//  thefile.Seek ( 4, soFromBeginning ) ;
//  thefile.writebuffer ( OffsetDir, sizeof(OffsetDir));
//  thefile.free;
//  result:=true;
//end;

function save_tiff_96(img: image_array; wide2,height2:integer; filen2:ansistring;flip_H,flip_V:boolean): boolean;{save to 96=3x32 color TIFF file }

var
  OffsetXRes     : LongInt;
  OffsetYRes     : LongInt;
  OffsetSoftware : LongInt;
  OffsetStrip    : LongInt;
  OffsetDir      : LongInt;
  OffsetBitsPerSample : LongInt;

var
  thefile : tfilestream;
  i,j,k,m : integer;
  dum: double;

  buf32: dword;
  buffer : array[0..3] of byte absolute buf32;
begin
  result:=false;
  filen2:=ChangeFileExt(Filen2,'.tif');
  if fileexists(filen2)=true then
    if MessageDlg('Existing file ' +filen2+ ' Overwrite?', mtConfirmation, [mbYes, mbNo], 0) <> 6 {mbYes} then
      Exit;

  try
   thefile:=tfilestream.Create(filen2, fmcreate );
  except
   thefile.free;
   exit;
  end;

 Directoryrgb96[1]._Value := LongInt(Wide2);        { Image Width }
 Directoryrgb96[2]._Value := LongInt(Height2);      { Image Height }
 Directoryrgb96[8]._Value := LongInt(Height2);      { Image Height }
 Directoryrgb96[9]._Value := LongInt(4*3*Wide2*Height2);{ Strip Byte Counts }


 { Write TIFF - File for Image with RGB-Values }
 { ------------------------------------------- }
 { Write Header }
  thefile.writebuffer ( TifHeader, sizeof(TifHeader));

  OffsetXRes := thefile.Position ;
  thefile.writebuffer ( X_Res_Value, sizeof(X_Res_Value));

  OffsetYRes := thefile.Position ;
  thefile.writebuffer ( Y_Res_Value, sizeof(Y_Res_Value));

  OffsetBitsPerSample := Thefile.Position ; {where is sample located}
  Thefile.writebuffer ( BitsPerSample96,  sizeof(BitsPerSample96));

  OffsetSoftware := thefile.Position ;
  thefile.writebuffer ( Software, sizeof(Software));

  OffsetStrip := thefile.Position ;

  { Write Image Data }
  for i:=0 to Height2-1 do
  begin
    if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
    for j:=0 to wide2-1 do
      begin
       if flip_H=true then m:=wide2-1-j else m:=j;
       dum:=$FFFF*img[0,m,k];{increase level with 65535 to maximum, fractions will be preserved }  if dum>$FFFFFFFF then dum:=$FFFFFFFF;if dum<0 then dum:=$0;
       buf32:=round(dum); {has absolute link to buffer}
       tiffbuffer[m*12 ]  :=buffer[0];
       tiffbuffer[m*12+1] :=buffer[1];
       tiffbuffer[m*12+2] :=buffer[2];
       tiffbuffer[m*12+3] :=buffer[3];
       dum:=$FFFF*img[1,m,k]; if dum>$FFFFFFFF then dum:=$FFFFFFFF;if dum<0 then dum:=$0;
       buf32:=round(dum);
       tiffbuffer[m*12+4]  :=buffer[0];
       tiffbuffer[m*12+5] :=buffer[1];
       tiffbuffer[m*12+6] :=buffer[2];
       tiffbuffer[m*12+7] :=buffer[3];
       dum:=$FFFF*img[2,m,k]; if dum>$FFFFFFFF then dum:=$FFFFFFFF;if dum<0 then dum:=$0;
       buf32:=round(dum);
       tiffbuffer[m*12+8]  :=buffer[0];
       tiffbuffer[m*12+9] :=buffer[1];
       tiffbuffer[m*12+10] :=buffer[2];
       tiffbuffer[m*12+11] :=buffer[3];

     end;
     thefile.writebuffer(tiffbuffer,wide2*12) ;{works only for byte arrays}
   end;

	{ Set Offset - Adresses into Directory }
  DirectoryRGB96[ 3]._Value := OffsetBitsPerSample; 	{ BitsPerSample location containing 1000 1000 1000  (16,16,16)}
  Directoryrgb96[ 6]._Value := OffsetStrip; 	      { StripOffset, location of start image data}
  Directoryrgb96[10]._Value := OffsetXRes; 		      { X-Resolution  }
  Directoryrgb96[11]._Value := OffsetYRes; 		      { Y-Resolution  }
  Directoryrgb96[14]._Value := OffsetSoftware; 	    { Software      }

	{ Write Directory }
  OffsetDir := thefile.Position ;{where is the IFD directory}
	thefile.writebuffer ( NoOfDirsRGB96, sizeof(NoOfDirsRGB96));{number of directory entries}
	thefile.writebuffer ( Directoryrgb96, sizeof(Directoryrgb96));
	thefile.writebuffer ( NullString, sizeof(NullString));

	{ Update Start of IFD Directory }
  {all programs write IFD after image data, could be written before image data}
  thefile.Seek ( 4, soFromBeginning ) ;
  thefile.writebuffer ( OffsetDir, sizeof(OffsetDir));
  thefile.free;
  result:=true;
end;


{following routine is no longer used}
//function save_tiff_16(img: image_array; wide2,height2:integer; filen2:ansistring;flip_H,flip_V:boolean): boolean;{save to 16 bit grascale TIFF file }

//var
//  OffsetXRes     : LongInt;
//  OffsetYRes     : LongInt;
//  OffsetSoftware : LongInt;
//  OffsetStrip    : LongInt;
//  OffsetDir      : LongInt;
//var
//  thefile : tfilestream;
//  i,j,k,m : integer;
//  dum: double;
//  dummy : word;
//begin
//  result:=false;
//  filen2:=ChangeFileExt(Filen2,'.tif');
//  if fileexists(filen2)=true then
//    if MessageDlg('Existing file ' +filen2+ ' Overwrite?', mtConfirmation, [mbYes, mbNo], 0) <> 6 {mbYes} then
//      Exit;

//  try
//   thefile:=tfilestream.Create(filen2, fmcreate );
//  except
//   thefile.free;
//   exit;
//  end;


// Directorybw16[1]._Value := LongInt(Wide2);        { Image Width }
// Directorybw16[2]._Value := LongInt(Height2);      { Image Height }

// Directorybw16[8]._Value := LongInt(Height2);      { Image Height }
// Directorybw16[9]._Value := LongInt(2*Wide2*Height2);{ Strip Byte Counts }

 { Write TIFF - File for Image with RGB-Values }
 { ------------------------------------------- }
 { Write Header }
//  thefile.writebuffer ( TifHeader, sizeof(TifHeader));

//  OffsetXRes := thefile.Position ;
//  thefile.writebuffer ( X_Res_Value, sizeof(X_Res_Value));

//  OffsetYRes := thefile.Position ;
//  thefile.writebuffer ( Y_Res_Value, sizeof(Y_Res_Value));

//  OffsetSoftware := thefile.Position ;
//  thefile.writebuffer ( Software, sizeof(Software));

//  OffsetStrip := thefile.Position ;

  { Write Image Data }
//  for i:=0 to Height2-1 do
//  begin
//    if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
//    for j:=0 to wide2-1 do
//      begin
//        if flip_H=true then m:=wide2-1-j else m:=j;
//        dum:=img[0,m,k]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
//         tiffbuffer[m+m]  :=lo(dummy);
//         tiffbuffer[m+m+1]:=hi(dummy);
//      end;
//     thefile.writebuffer( tiffbuffer,wide2*2{size 2x8}) ;{works only for byte arrays}
//   end;

	{ Set Offset - Adresses into Directory }
//  Directorybw16[ 6]._Value := OffsetStrip; 	      { StripOffset, location of start image data}
//  Directorybw16[10]._Value := OffsetXRes; 		      { X-Resolution  }
//  Directorybw16[11]._Value := OffsetYRes; 		      { Y-Resolution  }
//  Directorybw16[13]._Value := OffsetSoftware; 	    { Software      }


	{ Write Directory }
//  OffsetDir := thefile.Position ;{where is the IFD directory}
//	thefile.writebuffer ( NoOfDirsBW16, sizeof(NoOfDirsBW16));{number of directory entries}
//	thefile.writebuffer ( Directorybw16, sizeof(Directorybw16));
//	thefile.writebuffer ( NullString, sizeof(NullString));

	{ Update Start of IFD Directory }
  {all programs write IFD after image data, could be written before image data}
//  thefile.Seek ( 4, soFromBeginning ) ;
//  thefile.writebuffer ( OffsetDir, sizeof(OffsetDir));
//  thefile.free;
//  result:=true;
//end;

function save_tiff_32(img: image_array; wide2,height2:integer; filen2:ansistring;flip_H,flip_V:boolean): boolean;{save to 32 bit gray scale TIFF file }

var
  OffsetXRes     : LongInt;
  OffsetYRes     : LongInt;
  OffsetSoftware : LongInt;
  OffsetStrip    : LongInt;
  OffsetDir      : LongInt;
var
  thefile : tfilestream;
  i,j,k,m : integer;
  dum: double;
  buf32 : Dword;
begin
  result:=false;
  filen2:=ChangeFileExt(Filen2,'.tif');
  if fileexists(filen2)=true then
    if MessageDlg('Existing file ' +filen2+ ' Overwrite?', mtConfirmation, [mbYes, mbNo], 0) <> 6 {mbYes} then
      Exit;

  try
   thefile:=tfilestream.Create(filen2, fmcreate );
  except
   thefile.free;
   exit;
  end;


 Directorybw32[1]._Value := LongInt(Wide2);        { Image Width }
 Directorybw32[2]._Value := LongInt(Height2);      { Image Height }

//irectoryCOL[3]._Value := LongInt($10); 	  { BitsPerSample }

 Directorybw32[8]._Value := LongInt(Height2);      { Image Height }
 Directorybw32[9]._Value := LongInt(4*Wide2*Height2);{ Strip Byte Counts }

 { Write TIFF - File for Image with RGB-Values }
 { ------------------------------------------- }
 { Write Header }
  thefile.writebuffer ( TifHeader, sizeof(TifHeader));

  OffsetXRes := thefile.Position ;
  thefile.writebuffer ( X_Res_Value, sizeof(X_Res_Value));

  OffsetYRes := thefile.Position ;
  thefile.writebuffer ( Y_Res_Value, sizeof(Y_Res_Value));

  OffsetSoftware := thefile.Position ;
  thefile.writebuffer ( Software, sizeof(Software));

  OffsetStrip := thefile.Position ;

  { Write Image Data }
  for i:=0 to Height2-1 do
  begin
    if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
    for j:=0 to wide2-1 do
      begin
        if flip_H=true then m:=wide2-1-j else m:=j;
        dum:=$FFFF*img[0,m,k];{increase level with 65535 to maximum, fractions will be preserved }
        if dum>$FFFFFFFF then dum:=$FFFFFFFF;if dum<0 then dum:=$0;buf32:=round(dum);
        tiffbuffer32[m]:=buf32;
      end;
     thefile.writebuffer(tiffbuffer,wide2*4{size 2x8}) ;{works only for byte arrays}
   end;



	{ Set Offset - Adresses into Directory }
  Directorybw32[ 6]._Value := OffsetStrip; 	      { StripOffset, location of start image data}
  Directorybw32[10]._Value := OffsetXRes; 		      { X-Resolution  }
  Directorybw32[11]._Value := OffsetYRes; 		      { Y-Resolution  }
  Directorybw32[13]._Value := OffsetSoftware; 	    { Software      }


	{ Write Directory }
  OffsetDir := thefile.Position ;{where is the IFD directory}
	thefile.writebuffer ( NoOfDirsBW32, sizeof(NoOfDirsBW32));{number of directory entries}
	thefile.writebuffer ( Directorybw32, sizeof(Directorybw32));
	thefile.writebuffer ( NullString, sizeof(NullString));

	{ Update Start of IFD Directory }
  {all programs write IFD after image data, could be written before image data}
  thefile.Seek ( 4, soFromBeginning ) ;
  thefile.writebuffer ( OffsetDir, sizeof(OffsetDir));
  thefile.free;
  result:=true;

end;


end.

