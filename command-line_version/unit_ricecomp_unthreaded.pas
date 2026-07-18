unit unit_ricecomp_unthreaded;

{==============================================================================
  Rice decompression for FITS tiled image compression (ZCMPTYPE = 'RICE_1').

  This is a Pascal conversion of the decompression routines of ricecomp.c
  from NASA's CFITSIO library (https://github.com/HEASARC/cfitsio).
  It was created by Han Kleijn, www.hnsky.org for the ASTAP program


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
{ IMPORTANT: the two directives below are essential and must not be removed.

  The Rice algorithm (both the CFITSIO-ported decoders and the encoder)
  relies on unsigned arithmetic wrapping modulo 2^32, exactly like C
  "unsigned int": expressions such as  diff + lastpix,  not(diff shr 1)
  and the branchless (un)zigzag mapping intentionally overflow and are
  then truncated.  With range or overflow checking enabled these lines
  would raise run-time errors 201/215 instead of producing the correct
  wrapped values.

  Because $R- and $Q- are LOCAL source directives, they override any
  project, IDE or command-line settings (-Cr, -Co) for all code in this
  unit.  The correctness of this unit therefore does NOT depend on the
  build configuration.

  Consequence: code copied OUT of this unit into another unit compiled
  with $R+ or $Q+ may fail at run time even though it is correct here. }
{$R-}{$Q-}   { wraparound dword arithmetic required, see conversion notes }

interface

uses
  Classes, SysUtils;  // Include necessary units


type
  Prd_byte  = PByte;     { unsigned char  * }
  Prd_word  = PWord;     { unsigned short * }
  Prd_dword = PDWord;    { unsigned int   * }

  Timage_array = array of array of array of Single;


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

type
  { All inputs required to decode + place the tiles of one compressed image.
    Filled by load_fits after it has parsed the BINTABLE header.
    Identical to the record in unit_ricecomp, so the two units are drop-in
    interchangeable. }
  Trice_decode_params = record
    { shared read-only source buffers (owned by caller) }
    table_buffer   : PByte;      { the NAXIS1*NAXIS2 table rows            }
    heap_buffer    : PByte;      { the PCOUNT-byte heap (may be nil)       }
    heap_size      : integer;    { PCOUNT                                  }
    table_rowwidth : integer;    { NAXIS1 (bytes per row)                  }
    table_rows     : integer;    { NAXIS2 (number of table rows)           }

    { tile grid + image geometry }
    tiles_x, tiles_y, tiles_z              : integer;
    total_tiles                            : integer;
    ztile1_val, ztile2_val, ztile3_val     : integer;
    znaxis1_val, znaxis2_val, znaxis3_val  : integer;
    img_width, img_height, img_naxis3      : integer;

    { column byte offsets within one table row (<0 means column absent) }
    off_comp, off_gzip, off_zscale, off_zzero, off_zblank : integer;

    { decoder + scaling parameters }
    bytepix_val, blocksize_val : integer;
    zquantiz_is_none           : boolean;   { (zquantiz_val = 'NONE')        }
    dither_active, dither_is_2 : boolean;
    zdither0_val               : integer;
    zscale_val, zzero_val      : double;
    zblank_val                 : integer;
    zblank_present             : boolean;
    img_bscale, img_bzero      : double;
    fastpath_possible          : boolean;   { precomputed loop invariant     }

    { shared read-only dither table, length 10000, or nil if not dithering }
    dither_table_ptr           : PSingle;
  end;

{ Decode and place every tile of a RICE_1 compressed image into img.

  This is the SERIAL twin of unit_ricecomp.rice_decode_tiles: identical
  signature and identical per-tile arithmetic, but it runs the tiles one after
  another on the calling thread instead of splitting them across worker threads.
  Per-tile decoding speed is the same (it calls the same rice_decode and the
  same placement code); only the multi-core parallelism is absent.

  img            : target image, already SetLength'd to [naxis3,height,width]
  p              : all parsed parameters (see Trice_decode_params)
  out_max/out_min: measured maximum / minimum stored pixel value
  err_gzip       : true if any tile actually held GZIP bytes (unsupported)
  err_decode     : true if rice_decode failed on some tile
  err_range      : true if a heap descriptor was out of range
  err_tile_index : tile index of the first decode/range problem (or -1)
  err_msg        : rice_decode's message for the first decode failure }
procedure rice_decode_tiles(var img: Timage_array;
                            const p: Trice_decode_params;
                            out out_max, out_min: single;
                            out err_gzip, err_decode, err_range: boolean;
                            out err_tile_index: integer;
                            out err_msg: string);

{ Serial Rice ENCODER for the one-row-per-tile writer in save_fits_compressed.

  Serial twin of unit_ricecomp.rice_encode_rows: identical signature, encodes
  rows [0..height-1] of colour plane 0 of img into the caller-owned
  tile_data[]/tile_len[] arrays, one Rice tile per row.  A single reused
  difference buffer is passed to rice_encode so no per-row allocation occurs,
  matching the per-row speed of the threaded encoder (minus the parallelism).

  On failure the partially-filled tile_data[] entries are left allocated; the
  caller frees all non-nil entries as it already does. }
procedure rice_encode_rows(var img: Timage_array;
                           width, height, nblock: integer;
                           var tile_data: array of PByte;
                           var tile_len: array of integer;
                           out ok: boolean;
                           out err_row: integer;
                           out err_msg: string);


implementation

uses Math;

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
function fits_rdecomp(c: PByte;              { input buffer                }
                      clen: integer;         { length of input             }
                      arr: Prd_dword;        { output array                }
                      nx: integer;           { number of output pixels     }
                      nblock: integer        { coding block size           }
                      ): integer;            { returns 0 on success or 1 on failure }
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
        //if (diff and 1) = 0 then
        //  diff := diff shr 1
        //else
        //  diff := not (diff shr 1);
        diff := (diff shr 1) xor (0 - (diff and 1));//2026.07.16. unzigzag replacement for above giving about 35% improvement in decoding speed
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
        //if (diff and 1) = 0 then
        //  diff := diff shr 1
        //else
        //  diff := not (diff shr 1);
        diff := (diff shr 1) xor (0 - (diff and 1));//2026.07.16. unzigzag replacement for above giving about 35% improvement in decoding speed
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
function fits_rdecomp_short(c: PByte;        { input buffer                }
                      clen: integer;         { length of input             }
                      arr: Prd_word;         { output array                }
                      nx: integer;           { number of output pixels     }
                      nblock: integer        { coding block size           }
                      ): integer;            { returns 0 on success or 1 on failure }
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
        //if (diff and 1) = 0 then
        //  diff := diff shr 1
        //else
        //  diff := not (diff shr 1);
        diff := (diff shr 1) xor (0 - (diff and 1));//2026.07.16. unzigzag replacement for above giving about 35% improvement in decoding speed
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
        //if (diff and 1) = 0 then
        //  diff := diff shr 1
        //else
        //  diff := not (diff shr 1);
        diff := (diff shr 1) xor (0 - (diff and 1));//2026.07.16. unzigzag replacement for above giving about 35% improvement in decoding speed
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
function fits_rdecomp_byte(c: PByte;         { input buffer                }
                      clen: integer;         { length of input             }
                      arr: Prd_byte;         { output array                }
                      nx: integer;           { number of output pixels     }
                      nblock: integer        { coding block size           }
                      ): integer;            { returns 0 on success or 1 on failure }
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
        //if (diff and 1) = 0 then
        //  diff := diff shr 1
        //else
        //  diff := not (diff shr 1);
        diff := (diff shr 1) xor (0 - (diff and 1));//2026.07.16. unzigzag replacement for above giving about 35% improvement in decoding speed
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
        //if (diff and 1) = 0 then
        //  diff := diff shr 1
        //else
        //  diff := not (diff shr 1);
        diff := (diff shr 1) xor (0 - (diff and 1));//2026.07.16. unzigzag replacement for above giving about 35% improvement in decoding speed
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
{ Compress nx 16-bit pixels from arr into buffer c (capacity clen bytes),
  coding block size nblock (normally 32).
  Returns the number of bytes written, or -1 on failure (output buffer too
  small).  As a safe upper bound allocate clen = nx*2 + nx div 16 + 32. }
function fits_rcomp_short(arr: Prd_word;      { input array of 16-bit pixels }
                         nx: integer;         { number of input pixels        }
                         c: PByte;            { output buffer                 }
                         clen: integer;       { size of output buffer         }
                         nblock: integer;     { coding block size             }
                         scratch: Prd_dword = nil { optional reused nblock-dword
                                                    difference buffer; nil = the
                                                    function allocates its own  }
                         ): integer;
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
  diffs_local             : array of dword; { owned buffer when scratch = nil }
  pdiffs                  : Prd_dword;       { active difference buffer (either) }
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

  { Use the caller's reused scratch buffer if supplied (avoids a per-call
    allocation when encoding many rows); otherwise allocate a local one. }
  if scratch <> nil then
    pdiffs := scratch
  else
  begin
    setlength(diffs_local, nblock);
    pdiffs := Prd_dword(@diffs_local[0]);
  end;

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
      pdiffs[j] := v;
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
        output_nbits(s, pdiffs[j], bbits);
    end
    else if fs = 0 then
    begin
      { fs = 0 is still a normal Rice block (code value fs+1 = 1), UNLESS every
        difference is zero, in which case emit the low-entropy marker 0.
        Emitting 0 for a non-zero block would be decoded as "all pixels equal
        the previous one" (decoder fs = value-1 = -1). }
      j := 0;
      while (j < thisblock) and (pdiffs[j] = 0) do inc(j);
      if j = thisblock then
        output_nbits(s, 0, fsbits)                { all-zero differences }
      else
      begin
        output_nbits(s, dword(fs + 1), fsbits);   { = 1 }
        { with fs = 0 there are no split bits; each diff is unary: that many
          zero bits followed by a terminating one bit }
        for j := 0 to thisblock - 1 do
        begin
          top := pdiffs[j];
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
        top := pdiffs[j] shr fs;               { unary part }
        while top > 24 do
        begin
          output_nbits(s, 0, 24);
          top := top - 24;
        end;
        output_nbits(s, 1, integer(top) + 1); { the terminating one bit }
        output_nbits(s, pdiffs[j] and dword(fsmask), fs);  { the fs split bits }
      end;
    end;

    i := i + nvals;
  end;

  result := rice_out_done(s);
end;

{ Convenience wrapper for FITS tile compression, symmetric with rice_decode.
  Only bytepix = 2 (16-bit) is supported.
  tile          : input, byte buffer of nx*2 bytes (word array, native order)
  compressed    : output buffer, must be at least nx*2 + nx div 16 + 32 bytes
  clen          : capacity of compressed on input
  out_len       : number of compressed bytes produced
  error_message : reason of failure, empty string on success }
function rice_encode(tile: pointer; bytepix, nx, nblock: integer;
                     compressed: PByte; clen: integer;
                     out out_len: integer; out error_message: string;
                     scratch: Prd_dword = nil): boolean;
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
  n := fits_rcomp_short(Prd_word(tile), nx, compressed, clen, nblock, scratch);
  if n < 0 then
  begin
    error_message := 'rice_encode: output buffer too small';
    exit(false);
  end;
  out_len := n;
  result := true;
end;


{==============================================================================
  SERIAL tile decoder + row encoder
  ---------------------------------
  Serial twins of unit_ricecomp.rice_decode_tiles / rice_encode_rows.  Same
  signatures and same per-tile / per-row arithmetic, no threads.  This is what
  makes unit_ricecomp_unthreaded a drop-in replacement for unit_ricecomp.
==============================================================================}

{ Read an 8-byte big-endian double from a byte pointer (per-tile ZSCALE/ZZERO). }
function rice_read_be_double(pp: PByte): double;
var
  qw : qword;
  d  : double absolute qw;
begin
  qw := (qword(pp[0]) shl 56) or (qword(pp[1]) shl 48) or
        (qword(pp[2]) shl 40) or (qword(pp[3]) shl 32) or
        (qword(pp[4]) shl 24) or (qword(pp[5]) shl 16) or
        (qword(pp[6]) shl 8)  or  qword(pp[7]);
  result := d;
end;

procedure rice_decode_tiles(var img: Timage_array;
                            const p: Trice_decode_params;
                            out out_max, out_min: single;
                            out err_gzip, err_decode, err_range: boolean;
                            out err_tile_index: integer;
                            out err_msg: string);
var
  scratch                 : PByte;
  max_tile_pixels, scratch_cap : integer;
  tile_index, tx, ty, tz  : integer;
  actual_tile_w, actual_tile_h, actual_tile_d : integer;
  tile_pixel_count        : integer;
  compressed_len, heap_offset, gzip_len : integer;
  row_ptr, compressed_ptr : PByte;
  tile_scale, tile_zero   : double;
  tile_blank              : integer;
  tile_has_blank          : boolean;
  tile_ok                 : boolean;
  error_msg_rice          : string;
  dither_iseed, dither_next : integer;
  px, py, pz              : integer;
  pixel_idx               : integer;
  img_x, img_y, img_z     : integer;
  raw_unsigned            : longword;
  signed_value            : int64;
  col_float_rice          : single;
  store_pixel             : boolean;
  pw_src                  : PWord;
  pdst                    : PSingle;
  vflt                    : single;
  ntiles                  : integer;
begin
  out_max := 0;  out_min := 0;
  err_gzip := false;  err_decode := false;  err_range := false;
  err_tile_index := -1;  err_msg := '';

  { number of tiles actually present (grid may slightly exceed table rows) }
  ntiles := p.total_tiles;
  if ntiles > p.table_rows then ntiles := p.table_rows;
  if ntiles <= 0 then exit;

  { own scratch buffer, sized for the largest possible tile, +16 padding }
  max_tile_pixels := p.ztile1_val * p.ztile2_val * p.ztile3_val;
  if max_tile_pixels < 1 then max_tile_pixels := 1;
  scratch_cap := max_tile_pixels * p.bytepix_val + 16;
  getmem(scratch, scratch_cap);
  try
    for tile_index := 0 to ntiles - 1 do
    begin
      { recover tx,ty,tz (row-major x,y,z) }
      tx :=  tile_index mod p.tiles_x;
      ty := (tile_index div p.tiles_x) mod p.tiles_y;
      tz :=  tile_index div (p.tiles_x * p.tiles_y);

      { descriptor: 4-byte element count, 4-byte heap offset, big-endian }
      row_ptr := p.table_buffer + tile_index * p.table_rowwidth + p.off_comp;
      compressed_len := integer((longword(row_ptr[0]) shl 24) or (longword(row_ptr[1]) shl 16) or
                                (longword(row_ptr[2]) shl 8)  or  longword(row_ptr[3]));
      heap_offset    := integer((longword(row_ptr[4]) shl 24) or (longword(row_ptr[5]) shl 16) or
                                (longword(row_ptr[6]) shl 8)  or  longword(row_ptr[7]));

      actual_tile_w := Min(p.ztile1_val, p.znaxis1_val - tx * p.ztile1_val);
      actual_tile_h := Min(p.ztile2_val, p.znaxis2_val - ty * p.ztile2_val);
      actual_tile_d := Min(p.ztile3_val, p.znaxis3_val - tz * p.ztile3_val);
      tile_pixel_count := actual_tile_w * actual_tile_h * actual_tile_d;
      if tile_pixel_count <= 0 then continue;

      if compressed_len <= 0 then
      begin
        gzip_len := 0;
        if p.off_gzip >= 0 then
        begin
          row_ptr := p.table_buffer + tile_index * p.table_rowwidth + p.off_gzip;
          gzip_len := integer((longword(row_ptr[0]) shl 24) or (longword(row_ptr[1]) shl 16) or
                              (longword(row_ptr[2]) shl 8)  or  longword(row_ptr[3]));
        end;
        if gzip_len > 0 then err_gzip := true;
        continue;
      end;

      if (heap_offset < 0) or
         (int64(heap_offset) + int64(compressed_len) > int64(p.heap_size)) then
      begin
        if not err_range then begin err_range := true; err_tile_index := tile_index; end;
        continue;
      end;
      compressed_ptr := p.heap_buffer + heap_offset;

      tile_scale := p.zscale_val;
      tile_zero  := p.zzero_val;
      tile_blank := p.zblank_val;
      tile_has_blank := p.zblank_present;
      if p.off_zscale >= 0 then
        tile_scale := rice_read_be_double(p.table_buffer + tile_index * p.table_rowwidth + p.off_zscale);
      if p.off_zzero >= 0 then
        tile_zero := rice_read_be_double(p.table_buffer + tile_index * p.table_rowwidth + p.off_zzero);
      if p.off_zblank >= 0 then
      begin
        row_ptr := p.table_buffer + tile_index * p.table_rowwidth + p.off_zblank;
        tile_blank := integer((longword(row_ptr[0]) shl 24) or (longword(row_ptr[1]) shl 16) or
                              (longword(row_ptr[2]) shl 8)  or  longword(row_ptr[3]));
        tile_has_blank := true;
      end;

      error_msg_rice := '';
      tile_ok := rice_decode(compressed_ptr, compressed_len, p.bytepix_val,
                             tile_pixel_count, p.blocksize_val, scratch, error_msg_rice);
      if not tile_ok then
      begin
        if not err_decode then
        begin
          err_decode := true; err_tile_index := tile_index; err_msg := error_msg_rice;
        end;
        continue;
      end;

      { ---- FAST PATH: 16-bit lossless full-width row tile inside the image ---- }
      if p.fastpath_possible and (actual_tile_w = p.img_width) and (ty < p.img_height) then
      begin
        pw_src := PWord(scratch);
        pdst   := @img[0, ty, 0];   { znaxis3 = 1 on fast path }
        for px := 0 to p.img_width - 1 do
        begin
          vflt := smallint(word(pw_src[px])) * p.img_bscale + p.img_bzero;
          pdst[px] := vflt;
          if vflt > out_max then out_max := vflt
          else if vflt < out_min then out_min := vflt;
        end;
        continue;
      end;

      { ---- GENERAL PATH ---- }
      if p.dither_active then
      begin
        dither_iseed := (tile_index + p.zdither0_val - 1) mod 10000;
        dither_next  := trunc(p.dither_table_ptr[dither_iseed] * 500);
      end
      else
      begin
        dither_iseed := 0;
        dither_next  := 0;
      end;

      for pz := 0 to actual_tile_d - 1 do
        for py := 0 to actual_tile_h - 1 do
          for px := 0 to actual_tile_w - 1 do
          begin
            pixel_idx := px + py * actual_tile_w + pz * actual_tile_w * actual_tile_h;
            img_x := tx * p.ztile1_val + px;
            img_y := ty * p.ztile2_val + py;
            img_z := tz * p.ztile3_val + pz;
            store_pixel := (img_z < p.img_naxis3) and (img_y < p.img_height) and (img_x < p.img_width);

            case p.bytepix_val of
              1: begin raw_unsigned := PByte(scratch)[pixel_idx];  signed_value := raw_unsigned; end;
              2: begin raw_unsigned := PWord(scratch)[pixel_idx];  signed_value := smallint(word(raw_unsigned)); end;
              4: begin raw_unsigned := PDWord(scratch)[pixel_idx]; signed_value := integer(longword(raw_unsigned)); end;
            else
              signed_value := 0;
            end;

            if not p.zquantiz_is_none then
            begin
              if signed_value = -2147483647 then
                col_float_rice := 0
              else if p.dither_is_2 and (signed_value = -2147483646) then
                col_float_rice := 0.0
              else if p.dither_active then
                col_float_rice := (signed_value - p.dither_table_ptr[dither_next] + 0.5) * tile_scale + tile_zero
              else
                col_float_rice := signed_value * tile_scale + tile_zero;
              if IsNan(col_float_rice) or IsInfinite(col_float_rice) then col_float_rice := 0;
            end
            else
            begin
              if tile_has_blank and (signed_value = tile_blank) then
                col_float_rice := 0
              else
                col_float_rice := signed_value * p.img_bscale + p.img_bzero;
            end;

            if store_pixel then
            begin
              img[img_z, img_y, img_x] := col_float_rice;
              if col_float_rice > out_max then out_max := col_float_rice
              else if col_float_rice < out_min then out_min := col_float_rice;
            end;

            if p.dither_active then
            begin
              inc(dither_next);
              if dither_next >= 10000 then
              begin
                inc(dither_iseed);
                if dither_iseed >= 10000 then dither_iseed := 0;
                dither_next := trunc(p.dither_table_ptr[dither_iseed] * 500);
              end;
            end;
          end;{px}
    end;{tile_index}
  finally
    freemem(scratch);
  end;
end;

procedure rice_encode_rows(var img: Timage_array;
                           width, height, nblock: integer;
                           var tile_data: array of PByte;
                           var tile_len: array of integer;
                           out ok: boolean;
                           out err_row: integer;
                           out err_msg: string);
var
  row16   : PWord;
  cbuf    : PByte;
  dscratch: Prd_dword;    { reused per-block difference buffer, nblock dwords }
  clen, y, x, outlen : integer;
  errmsg  : string;
  dstp    : PByte;
begin
  ok      := true;
  err_row := -1;
  err_msg := '';
  if height <= 0 then exit;

  getmem(row16, width * 2);
  clen := width * 2 + width div 16 + 64;   { safe upper bound, matches serial code }
  getmem(cbuf, clen);
  { one reused difference buffer for every row, so fits_rcomp_short performs no
    per-row allocation (same optimisation the threaded encoder uses) }
  getmem(dscratch, nblock * sizeof(dword));
  try
    for y := 0 to height - 1 do
    begin
      for x := 0 to width - 1 do
        { physical value -> BZERO/BSCALE-adjusted signed 16-bit, exactly as the
          normal 16-bit writer does }
        row16[x] := word(max(0, min(65535, round(img[0, y, x]))) - 32768);

      if not rice_encode(row16, 2, width, nblock, cbuf, clen, outlen, errmsg, dscratch) then
      begin
        if ok then          { record only the first failure }
        begin
          ok      := false;
          err_row := y;
          err_msg := errmsg;
        end;
        break;              { stop; remaining rows are abandoned }
      end;

      { exact-size destination for this row }
      getmem(dstp, outlen);
      move(cbuf^, dstp^, outlen);
      tile_data[y] := dstp;
      tile_len[y]  := outlen;
    end;
  finally
    freemem(row16);
    freemem(cbuf);
    freemem(dscratch);
  end;
end;

end.

