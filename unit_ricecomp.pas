unit unit_ricecomp;

{==============================================================================
  Rice decompression for FITS tiled image compression (ZCMPTYPE = 'RICE_1').

  This is a Pascal conversion of the decompression routines of ricecomp.c
  from NASA's CFITSIO library (https://github.com/HEASARC/cfitsio).

  Original copyright / attribution from ricecomp.c:

    The following code was written by Richard White at STScI and made
    available for use in CFITSIO in July 1999.  These routines were
    originally contained in 2 source files: rcomp.c and rdecomp.c,
    and the 'include' file now called ricecomp.h was originally called
    buffer.h.

  CFITSIO license (applies to this derived work):

    Copyright (Unpublished--all rights reserved under the copyright laws of
    the United States), U.S. Government as represented by the Administrator
    of the National Aeronautics and Space Administration.  No copyright is
    claimed in the United States under Title 17, U.S. Code.

    Permission to freely use, copy, modify, and distribute this software
    and its documentation without fee is hereby granted, provided that this
    copyright notice and disclaimer of warranty appears in all copies.

    DISCLAIMER: THE SOFTWARE IS PROVIDED 'AS IS' WITHOUT ANY WARRANTY OF
    ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING, BUT NOT
    LIMITED TO, ANY WARRANTY THAT THE SOFTWARE WILL CONFORM TO
    SPECIFICATIONS, ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
    A PARTICULAR PURPOSE, AND FREEDOM FROM INFRINGEMENT, AND ANY WARRANTY
    THAT THE DOCUMENTATION WILL CONFORM TO THE SOFTWARE, OR ANY WARRANTY
    THAT THE SOFTWARE WILL BE ERROR FREE.  IN NO EVENT SHALL NASA BE LIABLE
    FOR ANY DAMAGES, INCLUDING, BUT NOT LIMITED TO, DIRECT, INDIRECT,
    SPECIAL OR CONSEQUENTIAL DAMAGES, ARISING OUT OF, RESULTING FROM, OR IN
    ANY WAY CONNECTED WITH THIS SOFTWARE, WHETHER OR NOT BASED UPON
    WARRANTY, CONTRACT, TORT , OR OTHERWISE, WHETHER OR NOT INJURY WAS
    SUSTAINED BY PERSONS OR PROPERTY OR OTHERWISE, AND WHETHER OR NOT LOSS
    WAS SUSTAINED FROM, OR AROSE OUT OF THE RESULTS OF, OR USE OF, THE
    SOFTWARE OR SERVICES PROVIDED HEREUNDER.

  Conversion notes (Pascal version):
  - Only the three decompression routines are converted here:
      fits_rdecomp        for BYTEPIX=4  (ZBITPIX  32, unsigned int  output)
      fits_rdecomp_short  for BYTEPIX=2  (ZBITPIX  16, unsigned short output)
      fits_rdecomp_byte   for BYTEPIX=1  (ZBITPIX   8, unsigned char output)
    The compression routines (rcomp.c part) can be added later.
  - The C code relies on unsigned 32-bit wraparound in "diff+lastpix" and on
    "~(diff>>1)". This unit therefore switches range and overflow checks off
    locally (directives $R- and $Q-); dword arithmetic then wraps modulo
    2^32 exactly like C unsigned int.
  - Note that beginning with CFITSIO v3.08, end-of-buffer (EOB) checking was
    removed from the C code to improve speed, keeping only one check per
    coding block. This conversion keeps the original per-block check, so as
    in C the input buffer should be allocated somewhat larger (rule of
    thumb: 1% larger than the uncompressed pixel array) to guarantee that a
    corrupt stream cannot read past the end before the block check triggers.
    When decompressing a FITS tile, simply pass the heap array with a few
    spare bytes after the tile, or copy the tile to a padded buffer.
  - ffpmsg() error reporting is replaced by an error string returned in the
    optional out parameter of the wrapper function rice_decode() and by the
    integer results (0 = success, 1 = failure) of the low-level routines,
    identical to the C convention.
==============================================================================}

{$mode objfpc}{$H+}
{$R-}{$Q-}   { wraparound dword arithmetic required, see conversion notes }

interface

type
  Prd_byte  = PByte;     { unsigned char  * }
  Prd_word  = PWord;     { unsigned short * }
  Prd_dword = PDWord;    { unsigned int   * }

{ this routine used to be called 'rdecomp'  (WDP) }
function fits_rdecomp(c: PByte;              { input buffer                }
                      clen: integer;         { length of input             }
                      arr: Prd_dword;        { output array                }
                      nx: integer;           { number of output pixels     }
                      nblock: integer        { coding block size           }
                      ): integer;            { returns 0 on success or 1 on failure }

function fits_rdecomp_short(c: PByte;        { input buffer                }
                      clen: integer;         { length of input             }
                      arr: Prd_word;         { output array                }
                      nx: integer;           { number of output pixels     }
                      nblock: integer        { coding block size           }
                      ): integer;            { returns 0 on success or 1 on failure }

function fits_rdecomp_byte(c: PByte;         { input buffer                }
                      clen: integer;         { length of input             }
                      arr: Prd_byte;         { output array                }
                      nx: integer;           { number of output pixels     }
                      nblock: integer        { coding block size           }
                      ): integer;            { returns 0 on success or 1 on failure }

{ Convenience wrapper for FITS tile decompression.
  compressed  : one tile from the COMPRESSED_DATA heap
  bytepix     : BYTEPIX keyword, 1, 2 or 4 (bytes per original pixel)
  nx          : number of pixels in the tile (ZTILE1 * ZTILE2 * ...)
  nblock      : BLOCKSIZE keyword, normally 32
  tile        : output, byte buffer of nx*bytepix bytes, filled with the
                decoded pixels in native byte order (dword/word/byte array)
  error_message : reason of failure, empty string on success }
function rice_decode(compressed: PByte; clen: integer; bytepix, nx, nblock: integer;
                     tile: pointer; out error_message: string): boolean;

{==============================================================================
  Rice COMPRESSION (encoder).

  Converted from the rcomp.c part of CFITSIO's ricecomp.c (same copyright /
  attribution as the decoder above).  Only the 16-bit routine is converted,
  because ASTAP compresses only 16-bit integer FITS images (BITPIX = 16),
  which is the only case Rice can compress losslessly and is the intended
  use (many short exposures stored as .fz).

  fits_rcomp_short mirrors fits_rdecomp_short exactly:
    fsbits = 4, fsmax = 14, bbits = 16, first pixel stored raw big-endian.

  The output is a self-contained compressed tile, byte-for-byte identical to
  what CFITSIO's fpack produces, so funpack / CFITSIO / astropy can read it and
  this unit's own fits_rdecomp_short round-trips it exactly.
==============================================================================}

{ Compress nx 16-bit pixels from arr into buffer c (capacity clen bytes),
  coding block size nblock (normally 32).
  Returns the number of bytes written, or -1 on failure (output buffer too
  small).  As a safe upper bound allocate clen = nx*2 + nx div 16 + 32. }
function fits_rcomp_short(arr: Prd_word;      { input array of 16-bit pixels }
                         nx: integer;         { number of input pixels        }
                         c: PByte;            { output buffer                 }
                         clen: integer;       { size of output buffer         }
                         nblock: integer      { coding block size             }
                         ): integer;

{ Convenience wrapper for FITS tile compression, symmetric with rice_decode.
  Only bytepix = 2 (16-bit) is supported.
  tile          : input, byte buffer of nx*2 bytes (word array, native order)
  compressed    : output buffer, must be at least nx*2 + nx div 16 + 32 bytes
  clen          : capacity of compressed on input
  out_len       : number of compressed bytes produced
  error_message : reason of failure, empty string on success }
function rice_encode(tile: pointer; bytepix, nx, nblock: integer;
                     compressed: PByte; clen: integer;
                     out out_len: integer; out error_message: string): boolean;

implementation

{ nonzero_count is lookup table giving number of bits in 8-bit values not
  including leading zeros, used in fits_rdecomp, fits_rdecomp_short and
  fits_rdecomp_byte }
const
  nonzero_count: array[0..255] of integer = (
    0,
    1,
    2, 2,
    3, 3, 3, 3,
    4, 4, 4, 4, 4, 4, 4, 4,
    5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8);

{------------------------------------------------------------------------------
  rdecomp.c    Decompress image line using
               (1) Difference of adjacent pixels
               (2) Rice algorithm coding

  Returns 0 on success or 1 on failure
------------------------------------------------------------------------------}

{ this routine used to be called 'rdecomp'  (WDP) }
function fits_rdecomp(c: PByte; clen: integer; arr: Prd_dword; nx: integer;
                      nblock: integer): integer;
var
  i, k, imax        : integer;
  nbits, nzero, fs  : integer;
  cend              : PByte;
  b, diff, lastpix  : dword;
  fsmax, fsbits, bbits : integer;
begin
  result := 1; {assume failure}

  { Original size of each pixel is 4 bytes (bsize), coding block size is
    nblock pixels.
    From bsize derive:
    FSBITS = # bits required to store FS
    FSMAX  = maximum value for FS
    BBITS  = bits/pixel for direct coding }
  fsbits := 5;
  fsmax := 25;
  bbits := 1 shl fsbits; {32}

  { Decode in blocks of nblock pixels }

  { first 4 bytes of input buffer contain the value of the first
    4 byte integer value, without any encoding }
  if clen < 4 then
  begin
    //ffpmsg('decompression error: input buffer not properly allocated');
    exit(1);
  end;
  lastpix := (dword(c[0]) shl 24) or (dword(c[1]) shl 16) or
             (dword(c[2]) shl 8) or dword(c[3]);

  inc(c, 4);
  cend := c + clen - 4;

  b := c^;              { bit buffer                    }
  inc(c);
  nbits := 8;           { number of bits remaining in b }
  i := 0;
  while i < nx do
  begin
    { get the FS value from first fsbits }
    nbits := nbits - fsbits;
    while nbits < 0 do
    begin
      b := (b shl 8) or c^; inc(c);
      nbits := nbits + 8;
    end;
    fs := integer(b shr nbits) - 1;

    b := b and ((1 shl nbits) - 1);
    { loop over the next block }
    imax := i + nblock;
    if imax > nx then imax := nx;
    if fs < 0 then
    begin
      { low-entropy case, all zero differences }
      while i < imax do begin arr[i] := lastpix; inc(i); end;
    end
    else if fs = fsmax then
    begin
      { high-entropy case, directly coded pixel values }
      while i < imax do
      begin
        k := bbits - nbits;
        diff := b shl k;
        k := k - 8;
        while k >= 0 do
        begin
          b := c^; inc(c);
          diff := diff or (b shl k);
          k := k - 8;
        end;
        if nbits > 0 then
        begin
          b := c^; inc(c);
          diff := diff or (b shr (-k));
          b := b and ((1 shl nbits) - 1);
        end
        else
          b := 0;

        { undo mapping and differencing.
          Note that some of these operations will overflow the
          unsigned int arithmetic -- that's OK, it all works
          out to give the right answers in the output file. }
        if (diff and 1) = 0 then
          diff := diff shr 1
        else
          diff := not (diff shr 1);
        arr[i] := diff + lastpix;
        lastpix := arr[i];
        inc(i);
      end;
    end
    else
    begin
      { normal case, Rice coding }
      while i < imax do
      begin
        { count number of leading zeros }
        while b = 0 do
        begin
          nbits := nbits + 8;
          b := c^; inc(c);
        end;
        nzero := nbits - nonzero_count[b];
        nbits := nbits - (nzero + 1);
        { flip the leading one-bit }
        b := b xor (dword(1) shl nbits);
        { get the FS trailing bits }
        nbits := nbits - fs;
        while nbits < 0 do
        begin
          b := (b shl 8) or c^; inc(c);
          nbits := nbits + 8;
        end;
        diff := (dword(nzero) shl fs) or (b shr nbits);
        b := b and ((1 shl nbits) - 1);

        { undo mapping and differencing }
        if (diff and 1) = 0 then
          diff := diff shr 1
        else
          diff := not (diff shr 1);
        arr[i] := diff + lastpix;
        lastpix := arr[i];
        inc(i);
      end;
    end;
    if c > cend then
    begin
      //ffpmsg('decompression error: hit end of compressed byte stream');
      exit(1);
    end;
  end;
  //if c < cend then
  //  ffpmsg('decompression warning: unused bytes at end of compressed buffer');
  result := 0;
end;

{------------------------------------------------------------------------------}
{ this routine used to be called 'rdecomp'  (WDP) }
function fits_rdecomp_short(c: PByte; clen: integer; arr: Prd_word; nx: integer;
                            nblock: integer): integer;
var
  i, k, imax        : integer;
  nbits, nzero, fs  : integer;
  cend              : PByte;
  b, diff, lastpix  : dword;
  fsmax, fsbits, bbits : integer;
begin
  result := 1; {assume failure}

  { Original size of each pixel is 2 bytes (bsize), coding block size is
    nblock pixels. See fits_rdecomp for the FSBITS/FSMAX/BBITS derivation. }
  fsbits := 4;
  fsmax := 14;
  bbits := 1 shl fsbits; {16}

  { Decode in blocks of nblock pixels }

  { first 2 bytes of input buffer contain the value of the first
    2 byte integer value, without any encoding }
  if clen < 2 then  {check added in Pascal conversion, analogue to 4 byte version}
  begin
    //ffpmsg('decompression error: input buffer not properly allocated');
    exit(1);
  end;
  lastpix := (dword(c[0]) shl 8) or dword(c[1]);

  inc(c, 2);
  cend := c + clen - 2;

  b := c^;              { bit buffer                    }
  inc(c);
  nbits := 8;           { number of bits remaining in b }
  i := 0;
  while i < nx do
  begin
    { get the FS value from first fsbits }
    nbits := nbits - fsbits;
    while nbits < 0 do
    begin
      b := (b shl 8) or c^; inc(c);
      nbits := nbits + 8;
    end;
    fs := integer(b shr nbits) - 1;

    b := b and ((1 shl nbits) - 1);
    { loop over the next block }
    imax := i + nblock;
    if imax > nx then imax := nx;
    if fs < 0 then
    begin
      { low-entropy case, all zero differences }
      while i < imax do begin arr[i] := word(lastpix); inc(i); end;
    end
    else if fs = fsmax then
    begin
      { high-entropy case, directly coded pixel values }
      while i < imax do
      begin
        k := bbits - nbits;
        diff := b shl k;
        k := k - 8;
        while k >= 0 do
        begin
          b := c^; inc(c);
          diff := diff or (b shl k);
          k := k - 8;
        end;
        if nbits > 0 then
        begin
          b := c^; inc(c);
          diff := diff or (b shr (-k));
          b := b and ((1 shl nbits) - 1);
        end
        else
          b := 0;

        { undo mapping and differencing.
          Note that some of these operations will overflow the
          unsigned int arithmetic -- that's OK, it all works
          out to give the right answers in the output file. }
        if (diff and 1) = 0 then
          diff := diff shr 1
        else
          diff := not (diff shr 1);
        { like in C, the output array element truncates the sum to 16 bit
          and lastpix continues with the truncated value }
        arr[i] := word(diff + lastpix);
        lastpix := arr[i];
        inc(i);
      end;
    end
    else
    begin
      { normal case, Rice coding }
      while i < imax do
      begin
        { count number of leading zeros }
        while b = 0 do
        begin
          nbits := nbits + 8;
          b := c^; inc(c);
        end;
        nzero := nbits - nonzero_count[b];
        nbits := nbits - (nzero + 1);
        { flip the leading one-bit }
        b := b xor (dword(1) shl nbits);
        { get the FS trailing bits }
        nbits := nbits - fs;
        while nbits < 0 do
        begin
          b := (b shl 8) or c^; inc(c);
          nbits := nbits + 8;
        end;
        diff := (dword(nzero) shl fs) or (b shr nbits);
        b := b and ((1 shl nbits) - 1);

        { undo mapping and differencing }
        if (diff and 1) = 0 then
          diff := diff shr 1
        else
          diff := not (diff shr 1);
        arr[i] := word(diff + lastpix);
        lastpix := arr[i];
        inc(i);
      end;
    end;
    if c > cend then
    begin
      //ffpmsg('decompression error: hit end of compressed byte stream');
      exit(1);
    end;
  end;
  //if c < cend then
  //  ffpmsg('decompression warning: unused bytes at end of compressed buffer');
  result := 0;
end;

{------------------------------------------------------------------------------}
{ this routine used to be called 'rdecomp'  (WDP) }
function fits_rdecomp_byte(c: PByte; clen: integer; arr: Prd_byte; nx: integer;
                           nblock: integer): integer;
var
  i, k, imax        : integer;
  nbits, nzero, fs  : integer;
  cend              : PByte;
  b, diff, lastpix  : dword;
  fsmax, fsbits, bbits : integer;
begin
  result := 1; {assume failure}

  { Original size of each pixel is 1 byte (bsize), coding block size is
    nblock pixels. See fits_rdecomp for the FSBITS/FSMAX/BBITS derivation. }
  fsbits := 3;
  fsmax := 6;
  bbits := 1 shl fsbits; {8}

  { Decode in blocks of nblock pixels }

  { first byte of input buffer contains the value of the first
    byte integer value, without any encoding }
  if clen < 1 then  {check added in Pascal conversion, analogue to 4 byte version}
  begin
    //ffpmsg('decompression error: input buffer not properly allocated');
    exit(1);
  end;
  lastpix := c[0];
  inc(c, 1);
  cend := c + clen - 1;

  b := c^;              { bit buffer                    }
  inc(c);
  nbits := 8;           { number of bits remaining in b }
  i := 0;
  while i < nx do
  begin
    { get the FS value from first fsbits }
    nbits := nbits - fsbits;
    while nbits < 0 do
    begin
      b := (b shl 8) or c^; inc(c);
      nbits := nbits + 8;
    end;
    fs := integer(b shr nbits) - 1;

    b := b and ((1 shl nbits) - 1);
    { loop over the next block }
    imax := i + nblock;
    if imax > nx then imax := nx;
    if fs < 0 then
    begin
      { low-entropy case, all zero differences }
      while i < imax do begin arr[i] := byte(lastpix); inc(i); end;
    end
    else if fs = fsmax then
    begin
      { high-entropy case, directly coded pixel values }
      while i < imax do
      begin
        k := bbits - nbits;
        diff := b shl k;
        k := k - 8;
        while k >= 0 do
        begin
          b := c^; inc(c);
          diff := diff or (b shl k);
          k := k - 8;
        end;
        if nbits > 0 then
        begin
          b := c^; inc(c);
          diff := diff or (b shr (-k));
          b := b and ((1 shl nbits) - 1);
        end
        else
          b := 0;

        { undo mapping and differencing.
          Note that some of these operations will overflow the
          unsigned int arithmetic -- that's OK, it all works
          out to give the right answers in the output file. }
        if (diff and 1) = 0 then
          diff := diff shr 1
        else
          diff := not (diff shr 1);
        { like in C, the output array element truncates the sum to 8 bit
          and lastpix continues with the truncated value }
        arr[i] := byte(diff + lastpix);
        lastpix := arr[i];
        inc(i);
      end;
    end
    else
    begin
      { normal case, Rice coding }
      while i < imax do
      begin
        { count number of leading zeros }
        while b = 0 do
        begin
          nbits := nbits + 8;
          b := c^; inc(c);
        end;
        nzero := nbits - nonzero_count[b];
        nbits := nbits - (nzero + 1);
        { flip the leading one-bit }
        b := b xor (dword(1) shl nbits);
        { get the FS trailing bits }
        nbits := nbits - fs;
        while nbits < 0 do
        begin
          b := (b shl 8) or c^; inc(c);
          nbits := nbits + 8;
        end;
        diff := (dword(nzero) shl fs) or (b shr nbits);
        b := b and ((1 shl nbits) - 1);

        { undo mapping and differencing }
        if (diff and 1) = 0 then
          diff := diff shr 1
        else
          diff := not (diff shr 1);
        arr[i] := byte(diff + lastpix);
        lastpix := arr[i];
        inc(i);
      end;
    end;
    if c > cend then
    begin
      //ffpmsg('decompression error: hit end of compressed byte stream');
      exit(1);
    end;
  end;
  //if c < cend then
  //  ffpmsg('decompression warning: unused bytes at end of compressed buffer');
  result := 0;
end;

{------------------------------------------------------------------------------
  Convenience wrapper selecting the correct routine from BYTEPIX.
------------------------------------------------------------------------------}
function rice_decode(compressed: PByte; clen: integer; bytepix, nx, nblock: integer;
                     tile: pointer; out error_message: string): boolean;
var
  status: integer;
begin
  error_message := '';
  case bytepix of
    1: status := fits_rdecomp_byte (compressed, clen, Prd_byte(tile),  nx, nblock);
    2: status := fits_rdecomp_short(compressed, clen, Prd_word(tile),  nx, nblock);
    4: status := fits_rdecomp      (compressed, clen, Prd_dword(tile), nx, nblock);
    else
    begin
      error_message := 'rice_decode: BYTEPIX must be 1, 2 or 4 bytes';
      exit(false);
    end;
  end;
  if status <> 0 then
    error_message := 'rice_decode: decompression error, corrupt or truncated compressed byte stream';
  result := (status = 0);
end;

{------------------------------------------------------------------------------
  rcomp.c    Compress image line using
             (1) Difference of adjacent pixels
             (2) Rice algorithm coding

  Bit output buffer, converted from the Buffer struct + output_nbits() /
  output_nybble()-style helpers of ricecomp.c.  Bits are packed MSB-first,
  identical to the C encoder, so the decoder above reads them back correctly.
------------------------------------------------------------------------------}
type
  TRiceOutBuffer = record
    buf        : PByte;    { start of output buffer         }
    p          : PByte;    { current write position         }
    bufend     : PByte;    { one past the last usable byte   }
    bitbuffer  : dword;    { partial byte being assembled    }
    bits_to_go : integer;  { free bits remaining in bitbuffer }
    overflow   : boolean;  { set if we ran past bufend       }
  end;

procedure rice_out_init(var s: TRiceOutBuffer; c: PByte; clen: integer);
begin
  s.buf        := c;
  s.p          := c;
  s.bufend     := c + clen;
  s.bitbuffer  := 0;
  s.bits_to_go := 8;
  s.overflow   := false;
end;

{ Append one raw byte to the output, guarding against overrun. }
procedure rice_put_byte(var s: TRiceOutBuffer; value: byte); inline;
begin
  if s.p < s.bufend then
  begin
    s.p^ := value;
    inc(s.p);
  end
  else
    s.overflow := true;
end;

{ Output n bits (0 <= n <= 32) of "bits", most-significant bit first.
  Direct port of CFITSIO output_nbits(): the top bits of the current byte are
  filled, whole bytes are emitted, and a partial remainder is retained. }
procedure output_nbits(var s: TRiceOutBuffer; bits: dword; n: integer);
var
  lbitbuffer  : dword;
  lbits_to_go : integer;
begin
  if n = 0 then exit;

  { mask "bits" to the low n bits so callers need not pre-mask;
    guard shl 32 which is undefined for a 32-bit operand on x86 }
  if n < 32 then
    bits := bits and ((dword(1) shl n) - 1);

  lbitbuffer  := s.bitbuffer;
  lbits_to_go := s.bits_to_go;

  if n > lbits_to_go then
  begin
    { fill the rest of the current byte with the top (lbits_to_go) bits }
    lbitbuffer := lbitbuffer or (bits shr (n - lbits_to_go));
    rice_put_byte(s, byte(lbitbuffer));
    n := n - lbits_to_go;
    { emit whole bytes }
    while n > 8 do
    begin
      n := n - 8;
      rice_put_byte(s, byte(bits shr n));
    end;
    lbits_to_go := 8 - n;
    if n > 0 then
      lbitbuffer := (bits shl lbits_to_go) and $FF
    else
      lbitbuffer := 0;
  end
  else
  begin
    lbits_to_go := lbits_to_go - n;
    lbitbuffer  := lbitbuffer or ((bits shl lbits_to_go) and $FF);
  end;

  if lbits_to_go = 0 then
  begin
    rice_put_byte(s, byte(lbitbuffer));
    lbits_to_go := 8;
    lbitbuffer  := 0;
  end;

  s.bitbuffer  := lbitbuffer;
  s.bits_to_go := lbits_to_go;
end;

{ Flush any partial byte still in the bit buffer.  Returns total bytes written. }
function rice_out_done(var s: TRiceOutBuffer): integer;
begin
  if s.bits_to_go < 8 then
  begin
    rice_put_byte(s, byte(s.bitbuffer));
    s.bits_to_go := 8;
    s.bitbuffer  := 0;
  end;
  if s.overflow then
    result := -1
  else
    result := s.p - s.buf;
end;

{------------------------------------------------------------------------------
  fits_rcomp_short : compress nx 16-bit pixels.  Mirrors CFITSIO fits_rcomp_short.
------------------------------------------------------------------------------}
function fits_rcomp_short(arr: Prd_word; nx: integer; c: PByte; clen: integer;
                          nblock: integer): integer;
var
  s                       : TRiceOutBuffer;
  fsbits, fsmax, bbits    : integer;
  i, j, thisblock, nvals  : integer;
  fs, fsmask              : integer;
  lastpix, nextpix        : integer;   { current pixels as signed ints }
  pdiff                   : integer;
  dsum                    : int64;      { sum of mapped differences (can be large) }
  psum                    : integer;
  dpsum                   : double;
  v, top                  : dword;
  diffs                   : array of dword;
begin
  { bsize = 2 -> these three constants must match fits_rdecomp_short }
  fsbits := 4;
  fsmax  := 14;
  bbits  := 16;              { = bsize*8, bits per raw pixel }

  if nx <= 0 then exit(-1);

  rice_out_init(s, c, clen);

  { the first pixel is stored raw, 16 bits, big-endian }
  lastpix := word(arr[0]);
  rice_put_byte(s, byte(lastpix shr 8));
  rice_put_byte(s, byte(lastpix and $FF));

  setlength(diffs, nblock);

  i := 0;
  while i < nx do
  begin
    { number of pixels in this block (last block may be short) }
    nvals := nblock;
    if i + nvals > nx then nvals := nx - i;

    { form mapped differences and their sum }
    dsum := 0;
    for j := 0 to nvals - 1 do
    begin
      nextpix := word(arr[i + j]);
      pdiff   := nextpix - lastpix;
      { fold the 16-bit difference into the range that survives round-trip:
        CFITSIO relies on the difference being taken modulo 2^16.  Sign-extend
        a 16-bit wrap so e.g. 65535 is treated as -1 (a small difference). }
      pdiff := smallint(pdiff);
      { map signed pdiff to unsigned: negative -> odd, non-negative -> even }
      if pdiff < 0 then
        v := dword(not (dword(pdiff) shl 1))
      else
        v := dword(pdiff) shl 1;
      v := v and $FFFF;      { differences of 16-bit data fit in 16 bits }
      diffs[j] := v;
      dsum := dsum + v;
      lastpix := nextpix;
    end;

    { choose fs = number of bits to split off, from the mean difference }
    dpsum := (dsum - (nvals div 2) - 1) / nvals;
    if dpsum < 0 then dpsum := 0.0;
    psum := integer(trunc(dpsum)) shr 1;
    fs := 0;
    while psum > 0 do
    begin
      psum := psum shr 1;
      inc(fs);
    end;

    thisblock := nvals;

    if fs >= fsmax then
    begin
      { high-entropy block: send the marker then each difference raw (bbits) }
      output_nbits(s, dword(fsmax + 1), fsbits);
      for j := 0 to thisblock - 1 do
        output_nbits(s, diffs[j], bbits);
    end
    else if fs = 0 then
    begin
      { fs = 0 is still a normal Rice block (code value fs+1 = 1), UNLESS every
        difference is zero, in which case emit the low-entropy marker 0.
        Emitting 0 for a non-zero block would be decoded as "all pixels equal
        the previous one" (decoder fs = value-1 = -1). }
      j := 0;
      while (j < thisblock) and (diffs[j] = 0) do inc(j);
      if j = thisblock then
        output_nbits(s, 0, fsbits)                { all-zero differences }
      else
      begin
        output_nbits(s, dword(fs + 1), fsbits);   { = 1 }
        { with fs = 0 there are no split bits; each diff is unary: that many
          zero bits followed by a terminating one bit }
        for j := 0 to thisblock - 1 do
        begin
          top := diffs[j];
          while top > 24 do
          begin
            output_nbits(s, 0, 24);
            top := top - 24;
          end;
          output_nbits(s, 1, integer(top) + 1);
        end;
      end;
    end
    else
    begin
      { normal Rice block }
      output_nbits(s, dword(fs + 1), fsbits);
      fsmask := (1 shl fs) - 1;
      for j := 0 to thisblock - 1 do
      begin
        top := diffs[j] shr fs;               { unary part }
        while top > 24 do
        begin
          output_nbits(s, 0, 24);
          top := top - 24;
        end;
        output_nbits(s, 1, integer(top) + 1); { the terminating one bit }
        output_nbits(s, diffs[j] and dword(fsmask), fs);  { the fs split bits }
      end;
    end;

    i := i + nvals;
  end;

  result := rice_out_done(s);
end;

{------------------------------------------------------------------------------
  Convenience wrapper symmetric with rice_decode.  Only 16-bit is supported.
------------------------------------------------------------------------------}
function rice_encode(tile: pointer; bytepix, nx, nblock: integer;
                     compressed: PByte; clen: integer;
                     out out_len: integer; out error_message: string): boolean;
var
  n: integer;
begin
  error_message := '';
  out_len := 0;
  if bytepix <> 2 then
  begin
    error_message := 'rice_encode: only BYTEPIX = 2 (16-bit) is supported';
    exit(false);
  end;
  if nx <= 0 then
  begin
    error_message := 'rice_encode: nx must be positive';
    exit(false);
  end;
  n := fits_rcomp_short(Prd_word(tile), nx, compressed, clen, nblock);
  if n < 0 then
  begin
    error_message := 'rice_encode: output buffer too small';
    exit(false);
  end;
  out_len := n;
  result := true;
end;

end.
