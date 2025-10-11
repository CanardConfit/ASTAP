unit unit_command_line_general;
{Copyright (C) 2017, 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }



{For Android compiling
          Anyhow I have now added the patchelf --set-interpreter /system/bin/linker64 ./astap_cli command in my compile_all.sh file. So now they should be all good.

          @so999
          If you want to just test it from a terminal app, I recommend to root your device first.
          Then put the astap_cli to
          /data/local/tmp
          location, finally run it from terminal app as root (su).

          When root is not possible, you have to deploy the astap_cli renamed to "libastap_cli.so" (a stupid Android restriction) with your own app and call it from the app.

          The databases theoretically you can put to
          /sdcard/astap_db
          for example, and call astap_cli with the switch -d,
          see
          astap_cli --help
          for more information.

          Ok, it is quite tricky. But you don't need to be root or do anything special. Note it is not solution for termux but for regular app.

          1st you need to put in location it can be executed:

              You need to rename astap_cli to libastap.so or something like that (libSOMETHING.so) and put it to native libraries directory (jniLibs/PLATFORM like this https://github.com/artyom-beilis/android_live_stacker/tree/web_ols/app/src/main/jniLibs/arm64-v8a )
              You need to enable legacy packing to unpack all so: https://github.com/artyom-beilis/android_live_stacker/blob/web_ols/app/build.gradle#L26

          This way you'll get libastap.so as executable inside native lib directory and deploy it with the app.

          Than you need to find path to native library dir: https://github.com/artyom-beilis/android_live_stacker/blob/web_ols/app/src/main/java/org/openlivestacker/LiveStackerMain.java#L1006

          Then you call exe as usual (in C++ I do via fork/exec)

          https://github.com/artyom-beilis/OpenLiveStacker/blob/main/src/plate_solver.cpp#L213


          file ./astap_cli
          ./astap_cli: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /system/bin/linker, BuildID[sha1]=b2d9ae1e5745f6ba9dfb9b8b4e7913b638b325b9, stripped

}


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  math,
  FPImage,
  strutils,
  fpreadTIFF, {all part of fcl-image}
  fpreadPNG, fpreadBMP, fpreadJPEG, fpwriteTIFF, fpwritePNG, fpwriteBMP,
  fpwriteJPEG, fptiffcmn;


var {################# initialised variables #########################}
  astap_version: string='2025.10.11';
  ra1  : string='0';
  dec1 : string='0';
  search_fov1    : string='0';{search FOV}
  radius_search1 : string='180';
  max_stars: integer=500;
  quad_tolerance1: string='0.007';
  min_star_size1: string='1.5'{arcsec};
  force_oversize1       : boolean=false;
  check_pattern_filter1 : boolean=false;
  commandline_log : boolean=false;{file log request in command line}
  solve_show_log  : boolean=false;{log all progress steps}
  errorlevel      : integer=0;{report errors when shutdown}
  database_path   : string='';{to be set in main}
  downsample_for_solving1: integer=0;
  star_database1  : string='auto';
  add_sip1        : boolean=false;

type
  Timage_array = array of array of array of Single;
  Tstar_list   = array of array of double;
  Tarray_integer = array of integer;
  solution_vector   = array[0..2] of double;


  var
    memo1,memo2 :tstrings; {settings for save and loading}

    user_path    : string;{c:\users\name\appdata\local\astap   or ~/home/.config/astap}
    img_loaded,img_temp,img_dark,img_flat,img_bias,img_average,img_variance,img_buffer,img_final : Timage_array;
    filename2: string;
    nrbits,Xbinning,Ybinning    : integer;
    size_backup,index_backup    : integer;{number of backup images for ctrl-z, numbered 0,1,2,3}
    crota2,crota1                      : double; {image rotation at center in degrees}
    cd1_1,cd1_2,cd2_1,cd2_2 :double;
    ra_radians,dec_radians, pixel_size : double;
    ra_mount,dec_mount                     : double; {telescope ra,dec}

    a_order,ap_order: integer;{Simple Imaging Polynomial use by astrometry.net, if 2 then available}
    a_0_0,   a_0_1, a_0_2,  a_0_3,  a_1_0,  a_1_1,  a_1_2,  a_2_0,  a_2_1,  a_3_0 : double; {SIP, Simple Imaging Polynomial use by astrometry.net, Spitzer}
    b_0_0,   b_0_1, b_0_2,  b_0_3,  b_1_0,  b_1_1,  b_1_2,  b_2_0,  b_2_1,  b_3_0 : double; {SIP, Simple Imaging Polynomial use by astrometry.net, Spitzer}
    ap_0_0, ap_0_1,ap_0_2, ap_0_3, ap_1_0, ap_1_1, ap_1_2, ap_2_0, ap_2_1, ap_3_0 : double;{SIP, Simple Imaging Polynomial use by astrometry.net}
    bp_0_0, bp_0_1,bp_0_2, bp_0_3, bp_1_0, bp_1_1, bp_1_2, bp_2_0, bp_2_1, bp_3_0 : double;{SIP, Simple Imaging Polynomial use by astrometry.net}

    histogram : array[0..2,0..65535] of integer;{red,green,blue,count}
    r_aperture : integer; {histogram number of values}
    histo_peak_position : integer;
    his_mean : array[0..2] of integer;
    noise_level : array[0..2] of double;
    esc_pressed, fov_specified {, last_extension }: boolean;
    backgr, star_level,star_level2  : double;
    exposure,focallen,equinox : double;
    gain   :double; {from FITS}
    date_obs : string;
    instrum  :string;

    datamin_org, datamax_org :double;
    warning_str : string;{for solver}
    xpixsz,ypixsz: double;//Pixel Width in microns (after binning)
    ra0,dec0 : double; {plate center values}
    cdelt1,cdelt2: double;{deg/pixel for x}

  const
    hist_range  {range histogram 255 or 65535 or streched} : integer=255;
    fits_file: boolean=false;
    crpix1: double=0;{reference pixel}
    crpix2: double=0;
    pi_=pi;//for testing

  const   bufwide=1024*120;{buffer size in bytes}

     head1: array [0..28] of ansistring=
    (
       {0}('SIMPLE  =                    T / FITS header                                    '),
       {1}('BITPIX  =                    8 / Bits per entry                                 '),
       {2}('NAXIS   =                    2 / Number of dimensions                           '),
       {3}('NAXIS1  =                  100 / length of x axis                               '),
       {4}('NAXIS2  =                  100 / length of y axis                               '),
       {5}('NAXIS3  =                    3 / length of z axis (mostly colors)               '),
       {6}('EQUINOX =               2000.0 / Equinox of coordinates                         '),
       {7}('DATAMIN =                    0 / Minimum data value                             '),
       {8}('DATAMAX =                  255 / Maximum data value                             '),
       {9}('BZERO   =                  0.0 / Physical_value = BZERO + BSCALE * array_value  '),
      {10}('BSCALE  =                  1.0 / Physical_value = BZERO + BSCALE * array_value  '),
      {11}('CTYPE1  = '+#39+'RA---TAN'+#39+'           / first parameter RA  ,  projection TANgential   '),
      {12}('CTYPE2  = '+#39+'DEC--TAN'+#39+'           / second parameter DEC,  projection TANgential   '),
      {13}('CUNIT1  = '+#39+'deg     '+#39+'           / Unit of coordinates                            '),
      {14}('CRPIX1  =                  0.0 / X of reference pixel                           '),
      {15}('CRPIX2  =                  0.0 / Y of reference pixel                           '),
      {16}('CRVAL1  =                  0.0 / RA of reference pixel (deg)                    '),
      {17}('CRVAL2  =                  0.0 / DEC of reference pixel (deg)                   '),
      {18}('CDELT1  =                  0.0 / X pixel size (deg)                             '),
      {19}('CDELT2  =                  0.0 / Y pixel size (deg)                             '),
      {20}('CROTA1  =                  0.0 / Image twist of X axis        (deg)             '),
      {21}('CROTA2  =                  0.0 / Image twist of Y axis W of N (deg)             '),
      {22}('CD1_1   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
      {23}('CD1_2   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
      {24}('CD2_1   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
      {25}('CD2_2   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
      {26}('PLTSOLVD=                    T / ASTAP from hnsky.org                           '),
      {27}('END                                                                             '),
      {28}('                                                                                ')); {should be empthy !!}

  type  byteX3  = array[0..2] of byte;
        byteXX3 = array[0..2] of word;
        byteXXXX3 = array[0..2] of single;

  var
    Reader    : TReader;
    fitsbuffer : array[0..bufwide] of byte;{buffer for 8 bit FITS file}
    fitsbuffer2: array[0..round(bufwide/2)] of word absolute fitsbuffer;{buffer for 16 bit FITS file}
    fitsbufferRGB: array[0..trunc(bufwide/3)] of byteX3 absolute fitsbuffer;{buffer for 8 bit RGB FITS file}
    fitsbufferRGB16: array[0..trunc(bufwide/6)] of byteXX3 absolute fitsbuffer;{buffer for 16 bit RGB PPM file}
    fitsbufferRGB32: array[0..trunc(bufwide/12)] of byteXXXX3 absolute fitsbuffer;{buffer for -32 bit PFM file}
    fitsbuffer4: array[0..round(bufwide/4)] of longword absolute fitsbuffer;{buffer for floating bit ( -32) FITS file}
    fitsbuffer8: array[0..trunc(bufwide/8)] of int64 absolute fitsbuffer;{buffer for floating bit ( -64) FITS file}
    fitsbufferSINGLE: array[0..round(bufwide/4)] of single absolute fitsbuffer;{buffer for floating bit ( -32) FITS file}
    fitsbufferDouble: array[0..round(bufwide/8)] of double absolute fitsbuffer;{buffer for floating bit ( -64) FITS file}




procedure memo2_message(s: string);{message to memo2. Is also used for log to file in commandline mode}
function floattostr8(x:double):string;{float to string with 8 decimals and dot as decimal seperator}
function floattostr6(x:double):string;{float to string with 6 decimals and dot as decimal seperator}
function floattostr4(x:double):string;
function strtofloat2(s:string): double;{works with either dot or komma as decimal separator}
function floattostrF2(const x:double; width1,decimals1 :word): string;
procedure analyse_image(img : Timage_array;snr_min:double;report_type:integer;out star_counter : integer; out backgr, hfd_median : double); {find background, number of stars, median HFD}
procedure HFD(img: Timage_array;x1,y1,rs {boxsize}: integer; out hfd1,star_fwhm,snr{peak/sigma noise}, flux,xc,yc:double);{calculate star HFD and FWHM, SNR, xc and yc are center of gravity. All x,y coordinates in array[0..] positions}
procedure get_background(colour: integer; img :Timage_array;calc_hist, calc_noise_level: boolean; out background, star_level, star_level2: double); {get background and star level from peek histogram}
function prepare_ra(rax:double; sep:string):string; {radialen to text, format 24: 00 00.0 }
function prepare_dec(decx:double; sep:string):string; {radialen to text, format 90d 00 00}
procedure write_astronomy_wcs(filen: string);
procedure write_ini(filen: string;solution:boolean);{write solution to ini file}
function load_image : boolean; {load fits or PNG, BMP, TIF}
function savefits_update_header(filen2:string) : boolean;{save fits file with updated header}

function save_fits16bit(img: Timage_array;filen2:ansistring): boolean;{save to 16 fits file}

procedure update_longstr(inpt,thestr:string);{update or insert long str including single quotes}
procedure update_text(inpt,comment1:string);{update or insert text in header}
procedure add_long_comment(descrip:string);{add long text to header memo. Split description over several lines if required}
procedure update_generic(message_key,message_value,message_comment:string);{update header using text only}
procedure remove_key(inpt:string; all:boolean);{remove key word in header. If all=true then remove multiple of the same keyword}
procedure add_text(inpt,comment1:string);{add text to header memo}
procedure update_integer(inpt,comment1:string;x:integer);{update or insert variable in header}
procedure add_integer(inpt,comment1:string;x:integer);{add integer variable to header}
procedure update_float(inpt,comment1:string;x:double);{update keyword of fits header in memo}
procedure log_to_file(logf,mess : string);{for testing}

implementation

uses unit_command_line_solving, unit_command_line_star_database;


procedure log_to_file(logf,mess : string);{for testing}
var
  f   :  textfile;
begin
  assignfile(f,logf);
  try
   if fileexists(logf)=false then rewrite(f) else append(f);
   writeln(f,mess);

  finally
    closefile(f);
  end;
end;


function floattostrE(x:double):string;
begin
  str(x,result);
end;


function floattostr8(x:double):string;{float to string with 8 decimals and dot as decimal seperator}
begin
  str(x:0:8,result);
end;


function floattostr6(x:double):string;{float to string with 6 decimals}
begin
  str(x:0:6,result);
end;


function floattostr4(x:double):string;
begin
  str(x:0:4,result);
end;


function floattostrF2(const x:double; width1,decimals1 :word): string;
begin
  str(x:width1:decimals1,result);
  if formatSettings.decimalseparator<>'.' then result:=StringReplace(result,'.',formatSettings.decimalseparator,[]); {replaces dot by komma}
end;


function strtofloat2(s:string): double;{works with either dot or komma as decimal separator}
var
  error1:integer;
begin
  s:=StringReplace(s,',','.',[]); {replaces komma by dot}
  s:=trim(s); {remove spaces}
  val(s,result,error1);
  if error1<>0 then result:=0;
end;


function ansi_only(s:string): string;
begin
  result:=StringReplace(s,'Δ','offset',[rfReplaceAll]);
  result:=StringReplace(result,'α','RA',[rfReplaceAll]);
  result:=StringReplace(result,'δ','DEC',[rfReplaceAll]);
end;


procedure memo2_message(s: string);{message to memo2. Is also used for log to file in commandline mode}
begin
  {$IFDEF UNIX or ANDROID}  {linux and mac}
  writeln(s); {linux command line can write unicode}
  {$ELSE }
  writeln(ansi_only(s)); {log to console for Windows when compiler WIN32 gui is off}
  {$ENDIF}

  if commandline_log=true then {no commandline or option -log is used}
  begin
     memo2.add(TimeToStr(time)+'  '+s); {fill memo2 with log}
  end;
end;


Function LeadingZero(w : integer) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
end;


function prepare_ra(rax:double; sep:string):string; {radialen to text, format 24: 00 00.0 }
 var
   h,m,s,ds  :integer;
 begin   {make from rax [0..pi*2] a text in array bericht. Length is 8 long}
  rax:=rax+pi*0.1/(24*60*60); {add 1/10 of half second to get correct rounding and not 7:60 results as with round}
  rax:=rax*12/pi; {make hours}
  h:=trunc(rax);
  m:=trunc((rax-h)*60);
  s:=trunc((rax-h-m/60)*3600);
  ds:=trunc((rax-h-m/60-s/3600)*36000);
  prepare_ra:=leadingzero(h)+sep+leadingzero(m)+'  '+leadingzero(s)+'.'+ansichar(ds+48);
end;



function prepare_dec(decx:double; sep:string):string; {radialen to text, format 90d 00 00}
 var
   g,m,s  :integer;
   sign   : ansichar;
begin {make from rax [0..pi*2] a text in array bericht. Length is 10 long}
  if decx<0 then sign:='-' else sign:='+';
  decx:=abs(decx)+pi/(360*60*60); {add half second to get correct rounding and not 7:60 results as with round}
  decx:=decx*180/pi; {make degrees}
  g:=trunc(decx);
  m:=trunc((decx-g)*60);
  s:=trunc((decx-g-m/60)*3600);
  prepare_dec:=sign+leadingzero(g)+sep+leadingzero(m)+'  '+leadingzero(s);
end;


procedure dec_text_to_radians(inp :string; out dec : double; out errorDEC :boolean); {convert dec in text to double in radians}
var
  decd,decm,decs :double;
  position1,position2,position3,error1,error2,error3,plusmin:integer ;
begin
  inp:= stringreplace(inp, ',', '.',[rfReplaceAll]);
  inp:= stringreplace(inp, ':', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 'd', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 'm', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 's', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, '°', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, '  ', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, '  ', ' ',[rfReplaceAll]);
  inp:=trim(inp)+' ';
  if pos('-',inp)>0 then plusmin:=-1 else plusmin:=1;

  position1:=pos(' ',inp);
  val(copy(inp,1,position1-1),decd,error1);


  position2:=posex(' ',inp,position1+1);
  if position2-position1>1 then {decm available}
  begin
    val(copy(inp,position1+1,position2-position1-1),decm,error2);

    {decm found try decs}
    position3:=posex(' ',inp,position2+1);
    if position3-position2>1 then val( copy(inp,position2+1,position3-position2-1),decs,error3)
       else begin decs:=0;error3:=0;end;
  end
  else
    begin decm:=0;error2:=0;decs:=0; error3:=0; end;

  dec:=plusmin*(abs(decd)+decm/60+decs/3600)*pi/180;
  errorDEC:=((error1<>0) or (error2>1) or (error3<>0));
end;


procedure ra_text_to_radians(inp :string; out ra : double; out errorRA :boolean); {convert ra in text to double in radians}
var
  rah,ram,ras,plusmin :double;
  position1,position2,position3,error1,error2,error3:integer;
begin

  inp:= stringreplace(inp, ',', '.',[rfReplaceAll]);
  inp:= stringreplace(inp, ':', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 'h', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 'm', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 's', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, '  ', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, '  ', ' ',[rfReplaceAll]);

  inp:=trim(inp)+' ';
  if pos('-',inp)>0 then plusmin:=-1 else plusmin:=1;

  position1:=pos(' ',inp);
  val(copy(inp,1,position1-1),rah,error1);

  position2:=posex(' ',inp,position1+1);
  if position2-position1>1 then {ram available}
  begin
    val(copy(inp,position1+1,position2-position1-1),ram,error2);

    {ram found try ras}
    position3:=posex(' ',inp,position2+1);
    if position3-position2>1 then val( copy(inp,position2+1,position3-position2-1),ras,error3)
       else begin ras:=0;error3:=0;end;
  end
  else
    begin ram:=0;error2:=0; ras:=0; error3:=0; end;

  ra:=plusmin*(abs(rah)+ram/60+ras/3600)*pi/12;
  errorRA:=((error1<>0) or (error2>1) or (error3<>0) or (ra>2*pi));
end;


procedure write_astronomy_wcs(filen:string);
var
  TheFile4 : tfilestream;
  I : integer;
  line0       : ansistring;
  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}

begin
  try
   TheFile4:=tfilestream.Create(ChangeFileExt(filen,'.wcs'), fmcreate );

  {write memo1 header to file}
   for i:=0 to 79 do empthy_line[i]:=#32;{space}
   i:=0;
   repeat
      if i<memo1.count then
      begin
        line0:=memo1.strings[i];
        while length(line0)<80 do line0:=line0+' ';{guarantee length is 80}
        strpcopy(aline,(copy(line0,1,80)));{copy 80 and not more}
        thefile4.writebuffer(aline,80);{write updated header from memo1}
      end
      else
      thefile4.writebuffer(empthy_line,80);{write empthy line}
      inc(i);
   until ((i>=memo1.count) and (frac(i*80/2880)=0)); {write multiply records 36x80 or 2880 bytes}

  except
    TheFile4.free;
    exit;
  end;
  TheFile4.free;
end;


procedure write_ini(filen:string; solution:boolean);{write solution to ini file}
var
   f: text;
begin
  assignfile(f,ChangeFileExt(filen,'.ini'));
  rewrite(f);
  if solution then
  begin
    flush(output); {Required in Linux and Mac. Otherwise writeln(f,'  ') mixes with writeln('   ') in redirected output}
    writeln(f,'PLTSOLVD=T');
    writeln(f,'CRPIX1='+floattostrE(crpix1));// X of reference pixel
    writeln(f,'CRPIX2='+floattostrE(crpix2));// Y of reference pixel

    writeln(f,'CRVAL1='+floattostrE(ra0*180/pi)); // RA (j2000_1) of reference pixel [deg]
    writeln(f,'CRVAL2='+floattostrE(dec0*180/pi));// DEC (j2000_1) of reference pixel [deg]
    writeln(f,'CDELT1='+floattostrE(cdelt1));     // X pixel size [deg]
    writeln(f,'CDELT2='+floattostrE(cdelt2));     // Y pixel size [deg]
    writeln(f,'CROTA1='+floattostrE(crota1));    // Image twist of X axis [deg]
    writeln(f,'CROTA2='+floattostrE(crota2));    // Image twist of Y axis [deg]
    writeln(f,'CD1_1='+floattostrE(cd1_1));       // CD matrix to convert (x,y) to (Ra, Dec)
    writeln(f,'CD1_2='+floattostrE(cd1_2));       // CD matrix to convert (x,y) to (Ra, Dec)
    writeln(f,'CD2_1='+floattostrE(cd2_1));       // CD matrix to convert (x,y) to (Ra, Dec)
    writeln(f,'CD2_2='+floattostrE(cd2_2));       // CD matrix to convert (x,y) to (Ra, Dec)
  end
  else
  begin
    flush(output); {Required in Linux and Mac. Otherwise writeln(f,'  ') mixes with writeln('   ') in redirected output}
    writeln(f,'');
    writeln(f,'PLTSOLVD=F');
  end;
  writeln(f,'CMDLINE='+cmdline);{write the original commmand line}

  Case errorlevel of
             2: writeln(f,'ERROR=Not enough stars.');
            16: writeln(f,'ERROR=Error reading image file.');
            32: writeln(f,'ERROR=No star database found.');
            33: writeln(f,'ERROR=Error reading star database.');
  end;
  if warning_str<>'' then writeln(f,'WARNING='+warning_str);
  closefile(f);
end;


function savefits_update_header(filen2:string) : boolean;{save fits file with updated header}
var
  TheFile  : tfilestream;
  reader_position,I,readsize,bufsize : integer;
  TheFile_new : tfilestream;
  fract       : double;
  line0       : ansistring;
  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}
  header    : array[0..2880] of ansichar;
  endfound  : boolean;
  filename_tmp: string;

     procedure close_fits_files;
     begin
        Reader.free;
        TheFile.free;
        TheFile_new.free;
     end;
begin
  result:=false;{assume failure}
  filename_tmp:=changeFileExt(filen2,'.tmp');{new file will be first written to this file}
  try
    TheFile_new:=tfilestream.Create(filename_tmp, fmcreate );
    TheFile:=tfilestream.Create(filen2, fmOpenRead or fmShareDenyWrite);
    Reader := TReader.Create (TheFile,$60000);// 393216 byte buffer

    {TheFile.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}
    I:=0;
    reader_position:=0;
    repeat
      reader.read(header[i],80); {read file info, 80 bytes only}
      inc(reader_position,80);
      endfound:=((header[i]='E') and (header[i+1]='N')  and (header[i+2]='D') and (header[i+3]=' '));
    until ((endfound) or (I>=sizeof(header)-16 ));
    if endfound=false then
    begin
      close_fits_files;
      beep;
      memo2_message('Abort, error reading source FITS file!!');
      exit;
    end;

    fract:=frac(reader_position/2880);

    if fract<>0 then
    begin
      i:=round((1-fract)*2880);{left part of next 2880 bytes block}
      reader.read(header[0],i); {skip empty part and go to image data}
      inc(reader_position,i);
    end;
    {reader is now at begin of image data}

    {write updated header}
    for i:=0 to 79 do empthy_line[i]:=#32;{space}
    i:=0;
    repeat
       if i<memo1.count then
       begin
         line0:=memo1.strings[i];
         while length(line0)<80 do line0:=line0+' ';{guarantee length is 80}
         strpcopy(aline,(copy(line0,1,80)));{copy 80 and not more}
         thefile_new.writebuffer(aline,80);{write updated header from memo1.}
       end
       else
       begin
          thefile_new.writebuffer(empthy_line,80);{write empthy line}
       end;
       inc(i);
    until ((i>=memo1.count) and (frac(i*80/2880)=0)); {write multiply records 36x80 or 2880 bytes}

    bufsize:=sizeof(fitsbuffer);
    repeat
       readsize:=min(bufsize,TheFile.size-reader_position);{read flexible in buffersize and not in fixed steps of 2880 bytes. Note some file are not following the FITS standard of blocksize of 2880 bytes causing problem if fixed 2880 bytes are used}
       reader.read(fitsbuffer,readsize);
       inc(reader_position,readsize);
       thefile_new.writebuffer(fitsbuffer,readsize); {write buffer}
     until (reader_position>=TheFile.size);

    Reader.free;
    TheFile.free;
    TheFile_new.free;

    if deletefile(filen2) then
      result:=renamefile(filename_tmp,filen2);
  except
    close_fits_files;
    beep;
    exit;
  end;
end;


function save_fits16bit(img: Timage_array;filen2:ansistring): boolean;{save to 16 fits file}
var
  TheFile4 : tfilestream;
  I,j,k,bzero2, dum, remain,dimensions, naxis3_local,height5,width5 : integer;
  line0                : ansistring;
  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}
begin
  result:=false;

  {get dimensions directly from array}
  naxis3_local:=length(img);{nr colours}
  width5:=length(img[0,0]);{width}
  height5:=length(img[0]);{length}
  if naxis3_local=1 then dimensions:=2 else dimensions:=3; {number of dimensions or colours}

  filename2:=filen2;

  try
   TheFile4:=tfilestream.Create(filen2, fmcreate );
  except
   TheFile4.free;
   exit;
  end;

  {update FITs header}
  update_integer('BITPIX  =',' / Bits per entry                                 ' ,16); {16 bit}
  update_integer('NAXIS   =',' / Number of dimensions                           ' ,dimensions);{number of dimensions, 2 for mono, 3 for colour}
  update_integer('NAXIS1  =',' / length of x axis                               ' ,width5);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,height5);
  if naxis3_local<>1 then {color image}
    update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,naxis3_local)
    else
    remove_key('NAXIS3  ',false{all});{remove key word in header. Some program don't like naxis3=1}

  bzero2:=32768;
  update_integer('BZERO   =',' / Physical_value = BZERO + BSCALE * array_value  ' ,bzero2);
  update_integer('BSCALE  =',' / Physical_value = BZERO + BSCALE * array_value  ' ,1);{data is scaled to physical value in the load_fits routine}
  update_integer('DATAMIN =',' / Minimum data value                             ' ,round(datamin_org));
  update_integer('DATAMAX =',' / Maximum data value                             ' ,round(datamax_org));
  {update existing header}

  {write memo1 header to file}
  for i:=0 to 79 do empthy_line[i]:=#32;{space}
  i:=0;
  repeat
     if i<memo1.count then
     begin
       line0:=memo1.strings[i];{line0 is an ansistring. According the standard the FITS header should only contain ASCII charactors between decimal 32 and 126. However ASTAP can write UTF8 in the comments which is read correctly by DS9 and FV}
       while length(line0)<80 do line0:=line0+' ';{extend to length 80 if required}
       strpcopy(aline,(copy(line0,1,80)));{copy 80 and not more}
       thefile4.writebuffer(aline,80);{write updated header from memo1}
     end
     else
     thefile4.writebuffer(empthy_line,80);{write empthy line}
     inc(i);
  until ((i>=memo1.count) and (frac(i*80/2880)=0)); {write multiply records 36x80 or 2880 bytes}

  for k:=0 to naxis3_local-1 do {do all colors}
  for i:=0 to height5-1 do
  begin
    for j:=0 to width5-1 do
    begin
      dum:=round(img[k,i,j])-bzero2;{save all colors}
      { value  - bzero              result  shortint    word
       ($0000  - $8000) and $FFFF = $8000 (-32768       32768 )  note  $0000 - $8000 ==>  $FFFF8000. Highest bits are skipped
       ($0001  - $8000) and $FFFF = $8001 (-32767       32769 )  note  $0001 - $8000 ==>  $FFFF8001. Highest bits are skipped
       ($2000  - $8000) and $FFFF = $A000 (-24576       40960 )
       ($7FFF  - $8000) and $FFFF = $FFFF (    -1       65535 )
       ($8000  - $8000) and $FFFF = $0000 (     0           0 )
       ($8001  - $8000) and $FFFF = $0001 (     1           1 )
       ($A000  - $8000) and $FFFF = $2000 (  8192        8192 )  note $A000 - $8000 equals  $2000.
       ($FFFE  - $8000) and $FFFF = $7FFE (+32766       32766 )
       ($FFFF  - $8000) and $FFFF = $7FFF (+32767       32767 )
      }
      fitsbuffer2[j]:=swap(word(dum));{in FITS file hi en low bytes are swapped}
    end;
     thefile4.writebuffer(fitsbuffer2,width5+width5); {write as bytes}
  end;

  remain:=round(2880*(1-frac(thefile4.position/2880)));{follow standard and only write in a multi of 2880 bytes}
  if ((remain<>0) and (remain<>2880)) then
  begin
    FillChar(fitsbuffer, remain, 0);
    thefile4.writebuffer(fitsbuffer,remain);{write some bytes}
  end;

  TheFile4.free;
  result:=true;
end;


procedure precession_jnow_to_J2000(equinox : double; var ra1,dec1 : double); {simple precession correction,  new Meeus chapter precession formula 20.1}
var
  t,dra,ddec,m,n,n2  : double;
begin
  t:=(equinox-2000)/100;{time in julian centuries since j2000 }
  m:=3.07496+0.00186*t;{seconds}
  n:=1.33621-0.00057*t; {seconds}
  n2:=20.0431-0.0085*t;{arcsec}
  dra:=(m + n *sin(ra1)*tan(dec1))*pi/(3600*12);{yearly ra drift in radians}
  ddec:=n2*cos(ra1)*pi/(3600*180); {yearly dec drift in radians}
  ra1:=ra1-(dra*t*100);{multiply with number of years is t*100. Subtract because we go back to J2000}
  dec1:=dec1-(ddec*t*100);
end;


procedure reset_fits_global_variables; {reset the global variable}
begin
  ra0:=0;
  dec0:=0;
  ra_mount:=99999;
  dec_mount:=99999;
  cdelt1:=0;
  cdelt2:=0;
  xpixsz:=0;
  ypixsz:=0;
  focallen:=0;
  cd1_1:=0;{just for the case it is not available}
  cd1_2:=0;{just for the case it is not available}
  cd2_1:=0;{just for the case it is not available}
  cd2_2:=0;{just for the case it is not available}
  xbinning:=1;{normal}
  ybinning:=1;
  ra1:='';
  dec1:='';
  equinox:=2000;

//  naxis:=1;
//  naxis3:=1;
  datamin_org:=0;
  datamax_org:=$FFFF;

  date_obs:='';
  exposure:=0;
  gain:=999;{assume no data available}
end;


function load_fits(filen:string;out img_loaded2: Timage_array): boolean;{load fits file}
var
  TheFile  : tfilestream;
  header    : array[0..2880] of ansichar;
  i,j,k,error3,naxis1,width2,height2, reader_position,validate_double_error,naxis,naxis3   : integer;
  tempval                                                                                  : double;
  col_float,bscale,measured_max,scalefactor  : single;
  bzero                       : integer;{zero shift. For example used in AMT, Tricky do not use int64,  maxim DL writes BZERO value -2147483647 as +2147483648 !! }
  aline                       : ansistring;
  rgbdummy           : byteX3;

  word16             : word;   {for 16 signed integer}
  int_16             : smallint absolute word16;{for 16 signed integer}

  x_longword  : longword;
  x_single    : single absolute x_longword;{for conversion 32 bit "big-endian" data}
  int_32      : integer absolute x_longword;{for 32 bit signed integer}

  x_qword     : qword;
  x_double    : double absolute x_qword;{for conversion 64 bit "big-endian" data}
  int_64      : int64 absolute x_qword;{for 64 bit signed integer}

  simple,image,error1 : boolean;
const
  end_record : boolean=false;

     procedure close_fits_file; inline;
     begin
        Reader.free;
        TheFile.free;
     end;

     function validate_double:double;{read floating point or integer values}
     var t : string[21];
         r : integer;
     begin
       t:='';
       r:=I+10;{position 11 equals 10}
       while ((header[r]<>'/') and (r<=I+30) {pos 31}) do {'/' check is strictly not necessary but safer. Read up to position 31 so one more then fits standard since CFITSIO could write for minus values up to position 31. A violation of FITS standard 4}
       begin  {read 20 characters max, position 11 to 31 in string, position 10 to 30 in pchar}
         if header[r]<>' ' then t:=t+header[r];
         inc(r);
       end;
       val(t,result,validate_double_error);
     end;


     Function get_string:string;{read string values}
     var  r: integer;
     begin
       result:='';
       r:=I+11;{pos12, single quotes should for fix format should be at position 11 according FITS standard 4.0, chapter 4.2.1.1}
       while ((header[r]<>#39){last quote} and (r<I+79)) do {read string up to position 79 equals 78. The while instruction guarantees reading emphty strings with length zero correctly}
       begin
         result:=result+header[r];
         inc(r);
       end;
     end;

begin
  {some house keeping}
  result:=false; {assume failure}
  {house keeping done}

  try
    TheFile:=tfilestream.Create( filen, fmOpenRead or fmShareDenyWrite);
  except
    beep;
    writeln('Error, accessing the file!');
    exit;
  end;
  fits_file:=false; {assume failure}

  memo1.clear;{clear memo for new header}

  Reader := TReader.Create (TheFile,128*2880);{number of records. 128*2880 is 2% faster then 8* 2880}

  {Reset variables for case they are not specified in the file}
  reset_fits_global_variables; {reset the global variable}
  naxis:=0;//number of dimensions, normally 2, colour 3
  naxis3:=1;//number of colours

  bzero:=0;{just for the case it is not available. 0.0 is the default according https://heasarc.gsfc.nasa.gov/docs/fcg/standard_dict.html}
  bscale:=1;
  naxis1:=0;
  measured_max:=0;

  reader_position:=0;
  repeat {header, 2880 bytes loop}

    I:=0;
    try
      reader.read(header[I],2880);{read file header, 2880 bytes}
      inc(reader_position,2880);   {TheFile.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}
      if ((reader_position=2880) and (header[0]='S') and (header[1]='I')  and (header[2]='M') and (header[3]='P') and (header[4]='L') and (header[5]='E') and (header[6]=' ')) then
      begin
        simple:=true;
        image:=true;
      end;
      if simple=false then
      begin
        close_fits_file;
        beep;
        writeln('Error, accessing the file!');
        fits_file:=false;
        exit;
      end; {should start with SIMPLE  =,  MaximDL compressed files start with SIMPLE‚=”}
    except;
      close_fits_file;
      beep;
      writeln('Error, accessing the file!');
      fits_file:=false;
      exit;
    end;

    repeat  {loop for 80 bytes in 2880 block}
      SetString(aline, Pansichar(@header[i]), 80);{convert header line to string}
      memo1.add(aline); {add line to memo}
      if ((header[i]='N') and (header[i+1]='A')  and (header[i+2]='X') and (header[i+3]='I') and (header[i+4]='S')) then {naxis}
      begin
        if (header[i+5]=' ') then
            naxis:=round(validate_double)
        else    {NAXIS number of colors}
        if (header[i+5]='1') then begin naxis1:=round(validate_double);width2:=naxis1; end else {NAXIS1 pixels}
        if (header[i+5]='2') then height2:=round(validate_double) else   {NAXIS2 pixels}
        if (header[i+5]='3') then
        begin
           naxis3:=round(validate_double); {NAXIS3 number of colors}
           if ((naxis=3) and (naxis1=3)) {naxis1} then  {type NAXIS = 3 / Number of dimensions
                                     NAXIS1 = 3 / Number of Colors
                                     NAXIS2 = 382 / Row length
                                     NAXIS3 = 255 / Number of rows}
                      begin   {RGB fits with naxis1=3, treated as 24 bits coded pixels in 2 dimensions}
                        width2:=height2;
                        height2:=naxis3;
                        naxis3:=1;
                      end;
           if naxis3>3  then {panic, more then three colours. Program https://github.com/cbassa/stvid is storing the mean, st, max and argmax values of each pixel respectively from multiple files }
           begin
             naxis3:=1; {display only the first colour}
             memo2_message('Warning more then three colours. Will use only the first one.');
           end;

         end;
      end;


      if image then {image specific header}
      begin {read image header}
        if ((header[i]='B') and (header[i+1]='I')  and (header[i+2]='T') and (header[i+3]='P') and (header[i+4]='I') and (header[i+5]='X')) then
          nrbits:=round(validate_double);{BITPIX, read integer using double routine}

        if (header[i]='B') then
        begin
          if ( (header[i+1]='Z')  and (header[i+2]='E') and (header[i+3]='R') and (header[i+4]='O') ) then
          begin
            tempval:=validate_double;
            if tempval>2147483647 then
            bzero:=-2147483648
            else
            bzero:=round(tempval); {Maxim DL writes BZERO value -2147483647 as +2147483648 !! }
           {without this it would have worked also with error check off}
         end
         else
         if ( (header[i+1]='S')  and (header[i+2]='C') and (header[i+3]='A') and (header[i+4]='L') ) then
          begin
             bscale:=validate_double; {rarely used. Normally 1}
          end;
        end;

        if header[i]='C' then
        begin
          if ((header[i+1]='D')) then
          begin
             if ((header[i+2]='E') and (header[i+3]='L') and (header[i+4]='T')) then {cdelt1}
             begin
               if header[i+5]='1' then cdelt1:=validate_double else{deg/pixel for RA}
               if header[i+5]='2' then cdelt2:=validate_double;    {deg/pixel for DEC}
             end
             else
             begin
               if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='1')) then   cd1_1:=validate_double;
               if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='2')) then   cd1_2:=validate_double;
               if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='1')) then   cd2_1:=validate_double;
               if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='2')) then   cd2_2:=validate_double;
             end;
          end;
          if ((header[i+1]='R')  and (header[i+2]='V') and (header[i+3]='A') and (header[i+4]='L')) then {crval1/2}
          begin
            if (header[i+5]='1') then  ra0:=validate_double*pi/180; {ra center, read double value}
            if (header[i+5]='2') then  dec0:=validate_double*pi/180; {dec center, read double value}
          end;
        end;//C

        if ( ((header[i]='S') and (header[i+1]='E')  and (header[i+2]='C') and (header[i+3]='P') and (header[i+4]='I') and (header[i+5]='X')) or     {secpix1/2}
             ((header[i]='S') and (header[i+1]='C')  and (header[i+2]='A') and (header[i+3]='L') and (header[i+4]='E') and (header[i+5]=' ')) or     {SCALE value for SGP files}
             ((header[i]='P') and (header[i+1]='I')  and (header[i+2]='X') and (header[i+3]='S') and (header[i+4]='C') and (header[i+5]='A')) ) then {pixscale}
        begin
          if cdelt2=0 then
              begin cdelt2:=validate_double/3600; {deg/pixel for RA} cdelt1:=cdelt2; end; {no CDELT1/2 found yet, use alternative}
        end;

        if ((header[i]='E') and (header[i+1]='Q')  and (header[i+2]='U') and (header[i+3]='I') and (header[i+4]='N') and (header[i+5]='O') and (header[i+6]='X')) then
             equinox:=validate_double;


       if ((header[i]='F') and (header[i+1]='O')  and (header[i+2]='C') and (header[i+3]='A') and (header[i+4]='L') and (header[i+5]='L')) then  {focall}
            focallen:=validate_double;{Focal length of telescope in mm, maxim DL keyword}



        if ((header[i]='D') and (header[i+1]='E')  and (header[i+2]='C') and (header[i+3]=' ')) then {dec}
        begin
          tempval:=validate_double*pi/180;
          if validate_double_error=0 then //not a string value behind keyword DEC
          begin
            dec_mount:=tempval;
            if dec0=0 then dec0:=tempval; {dec telescope, read double value only if crval is not available}
          end
          else
           dec1:=get_string;
        end;

        if ((header[i]='O') and (header[i+1]='B')  and (header[i+2]='J')) then
        begin
          if  ((header[i+3]='C') and (header[i+4]='T')) then {objctra, objctdec}
          begin
            if ((header[i+5]='R') and (header[i+6]='A') and (ra_mount>=999) {ra_mount value is unfilled, preference for keyword RA}) then
            begin
              ra1:=get_string;
            end
            else
            if ((header[i+5]='D') and (header[i+6]='E') and (dec_mount>=999){dec_mount value is unfilled, preference for keyword DEC}) then
            begin
              dec1:=get_string;
            end;
          end;
        end;

        if ((header[i]='R') and (header[i+1]='A')  and (header[i+2]=' ')) then  {ra}
        begin
          tempval:=validate_double*pi/180;
          if validate_double_error=0 then //not a string value behind keyword RA
          begin
            ra_mount:=tempval;
            if ra0=0 then ra0:=tempval; {ra telescope, read double value only if crval1 is not available}
          end
          else
            ra1:=get_string;
        end;


        if header[i]='X' then
        begin
        if ((header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='S') and (header[i+5]='Z')) then {xpixsz}
               xpixsz:=validate_double;{Pixel Width in microns (after binning), maxim DL keyword}
        if ((header[i+1]='B')  and (header[i+2]='I') and (header[i+3]='N') and (header[i+4]='N') and (header[i+5]='I')) then
                 xbinning:=round(validate_double);{binning}
        end;//X

        if header[i]='Y' then
        begin
          if ((header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='S') and (header[i+5]='Z')) then {xpixsz}
               ypixsz:=validate_double;{Pixel Width in microns (after binning), maxim DL keyword}
          if ((header[i+1]='B')  and (header[i+2]='I') and (header[i+3]='N') and (header[i+4]='N') and (header[i+5]='I')) then
               ybinning:=round(validate_double);{binning}
        end;//Y

      end; {image header}

      end_record:=((header[i]='E') and (header[i+1]='N')  and (header[i+2]='D') and (header[i+3]=' '));{end of header. Note keyword ENDIAN exist, so test space behind END}
      inc(i,80);{go to next 80 bytes record}

    until ((i>=2880) or (end_record)); {loop for 80 bytes in 2880 block}
  until end_record; {header, 2880 bytes loop}


  if naxis<2 then
  begin
    result:=false; {no image}
    fits_file:=false;
    image:=false;
  end;


  if image then {read image data #########################################}
  begin
    if ((naxis=3) and (naxis1=3)) then
    begin
       nrbits:=24; {threat RGB fits as 2 dimensional with 24 bits data}
       naxis3:=3; {will be converted while reading}
    end;

    if ((ra0<>0) or (dec0<>0)) then
    begin
      if equinox<>2000 then //e.g. in SharpCap
      begin
        precession_Jnow_to_J2000(equinox,ra0,dec0); {precession, from unknown equinox to J2000}
        if dec_mount<999 then precession_Jnow_to_J2000(equinox,ra_mount,dec_mount); {precession, from unknown equinox to J2000}
      end;
      ra1:=prepare_ra(ra0,' ');
      dec1:=prepare_dec(dec0,' ');
    end
    else
    if ra1<>'' then
    begin
      ra_text_to_radians ( ra1 ,ra0,error1); {convert ra text to ra0 in radians}
      dec_text_to_radians( dec1,dec0,error1); {convert dec text to dec0 in radians}
    end;

    if cdelt2=0 then {simple code for astap-cli only}
    begin
      if cd1_1=0 then  {no scale, try to fix it}
      begin
       if ((focallen<>0) and (xpixsz<>0)) then
          cdelt2:=180/(pi*1000)*xpixsz/focallen; {use maxim DL key word. xpixsz is including binning}
      end
      else
      cdelt2:=sqrt(sqr(cd1_2)+sqr(cd2_2));
    end;

    {############################## read image}
    i:=round(bufwide/(abs(nrbits/8)));{check if buffer is wide enough for one image line}
    if width2>i then
    begin
      beep;
      writeln('Too wide FITS file !!!!!');
      close_fits_file;
      exit;
    end;

    setlength(img_loaded2,naxis3,height2,width2);

    if nrbits=16 then
    for k:=0 to naxis3-1 do {do all colors}
    begin
      For j:=0 to height2-1 do
      begin
        try reader.read(fitsbuffer,width2*2);except; end; {read file info}
        for i:=0 to width2-1 do
        begin
          word16:=swap(fitsbuffer2[i]);{move data to wo and therefore sign_int}
          col_float:=int_16*bscale + bzero; {save in col_float for measuring measured_max}
          img_loaded2[k,j,i]:=col_float;
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end {colors naxis3 times}
    else
    if nrbits=-32 then
    for k:=0 to naxis3-1 do {do all colors}
    begin
      For j:=0 to height2-1 do
      begin
        try reader.read(fitsbuffer,width2*4);except; end; {read file info}
        for i:=0 to width2-1 do
        begin
          x_longword:=swapendian(fitsbuffer4[i]);{conversion 32 bit "big-endian" data, x_single  : single absolute x_longword; }
          col_float:=x_single*bscale+bzero; {int_IEEE, swap four bytes and the read as floating point}
          if isNan(col_float) then col_float:=measured_max;{not a number prevent errors, can happen in PS1 images with very high floating point values}
          img_loaded2[k,j,i]:=col_float;{store in memory array}
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end {colors naxis3 times}
    else
    if nrbits=8 then
    for k:=0 to naxis3-1 do {do all colors}
    begin
      For j:=0 to height2-1 do
      begin
        try reader.read(fitsbuffer,width2);except; end; {read file info}
        for i:=0 to width2-1 do
        begin
          img_loaded2[k,j,i]:=(fitsbuffer[i]*bscale + bzero);
        end;
      end;
    end {colors naxis3 times}
    else
    if nrbits=24 then
    For j:=0 to height2-1 do
    begin
      try reader.read(fitsbuffer,width2*3);except; end; {read file info}
      for i:=0 to width2-1 do
      begin
        rgbdummy:=fitsbufferRGB[i];{RGB fits with naxis1=3, treated as 24 bits coded pixels in 2 dimensions}
        img_loaded2[0,j,i]:=rgbdummy[0];{store in memory array}
        img_loaded2[1,j,i]:=rgbdummy[1];{store in memory array}
        img_loaded2[2,j,i]:=rgbdummy[2];{store in memory array}
      end;
    end
    else
    if nrbits=+32 then
    for k:=0 to naxis3-1 do {do all colors}
    begin
      For j:=0 to height2-1 do
      begin
        try reader.read(fitsbuffer,width2*4);except; end; {read file info}
        for i:=0 to width2-1 do
        begin
          col_float:=int32(swapendian(fitsbuffer4[i]))*bscale+bzero;{max range  -2,147,483,648 ...2,147,483,647 or -$8000 0000 .. $7FFF FFFF.  Scale later to 0..65535}
          {Tricky do not use int64 for BZERO,  maxim DL writes BZERO value -2147483647 as +2147483648 !!}
          img_loaded2[k,j,i]:=col_float;{store in memory array}
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end {colors naxis3 times}
    else
    if nrbits=-64 then
    for k:=0 to naxis3-1 do {do all colors}
    begin
      For j:=0 to height2-1 do
      begin
        try reader.read(fitsbuffer,width2*8);except; end; {read file info}
        for i:=0 to width2-1 do
        begin
          x_qword:=swapendian(fitsbuffer8[i]);{conversion 64 bit "big-endian" data, x_double    : double absolute x_int64;}
          col_float:=x_double*bscale + bzero; {int_IEEE, swap four bytes and the read as floating point}
          img_loaded2[k,j,i]:=col_float;{store in memory array}
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end; {colors naxis3 times}

    {rescale if required}
    if ((nrbits<=-32){-32 or -64} or (nrbits=+32)) then
    begin
      scalefactor:=1;
      if ((measured_max<=1.01) or (measured_max>65535)) then scalefactor:=65535/measured_max; {rescale 0..1 range float for GIMP, Astro Pixel Processor, PI files, transfer to 0..65535 float}
                                                                                              {or if values are above 65535}
      if scalefactor<>1 then {not a 0..65535 range, rescale}
      begin
        for k:=0 to naxis3-1 do {do all colors}
          for j:=0 to height2-1 do
            for i:=0 to width2-1 do
              img_loaded2[k,j,i]:= img_loaded2[k,j,i]*scalefactor;
        datamax_org:=65535;
      end
      else  datamax_org:=measured_max;

    end
    else
    if nrbits=8 then datamax_org:=255 {not measured}
    else
    if nrbits=24 then
    begin
      datamax_org:=255;
      nrbits:=8; {already converted to array with separate colour sections}
    end
    else {16 bit}
    datamax_org:=measured_max;{most common. It set for nrbits=24 in beginning at 255}

    result:=true;
    fits_file:=true;{succes}
    reader_position:=reader_position+width2*height2*(abs(nrbits) div 8)
  end;{image block}

  close_fits_file;
end;


function fnmodulo (x,range: double):double;
begin
  {range should be 2*pi or 24 hours or 0 .. 360}
  x:=range *frac(X /range); {quick method for big numbers}
  if x<0 then x:=x+range;   {do not like negative numbers}
  fnmodulo:=x;
end;


procedure remove_key(inpt:string; all:boolean);{remove key word in header. If all=true then remove multiple of the same keyword}
var
   count1: integer;
begin
  count1:=memo1.Count-1;
  while count1>=0 do {update keyword}
  begin
    if pos(inpt,memo1.strings[count1])>0 then {found}
    begin
      memo1.delete(count1);
      if all=false then exit;
    end;
    count1:=count1-1;
  end;
end;


procedure add_text(inpt,comment1:string);{add text to header memo}
begin
  memo1.insert(memo1.Count-1,inpt+' '+copy(comment1,1,79-length(inpt)));  {add to the end. Limit to 80 char max as specified by FITS standard}
end;


procedure update_integer(inpt,comment1:string;x:integer);{update or insert variable in header}
 var
   s,aline  : string;
   count1   : integer;
begin
  str(x:20,s);

  count1:=memo1.Count-1;
  while count1>=0 do {update keyword}
  begin
    if pos(inpt,memo1.strings[count1])>0 then {found}
    begin
      aline:=memo1[count1];
      delete(aline,11,20);
      insert(s,aline,11);
      memo1.strings[count1]:=aline;
      exit;
    end;
    count1:=count1-1;
  end;
  {not found, add at the correct position or at the end}
  if inpt='NAXIS1  =' then memo1.insert(3,inpt+' '+s+comment1) else{PixInsight requires to have it on 3th place}
  if inpt='NAXIS2  =' then memo1.insert(4,inpt+' '+s+comment1) else{PixInsight requires to have it on 4th place}
  if inpt='NAXIS3  =' then memo1.insert(5,inpt+' '+s+comment1) else{PixInsight requires to have it on this place}
  memo1.insert(memo1.Count-1,inpt+' '+s+comment1);
end;


procedure add_integer(inpt,comment1:string;x:integer);{add integer variable to header}
 var
   s        : string;
begin
  str(x:20,s);
  memo1.insert(memo1.Count-1,inpt+' '+s+comment1);
end;


procedure update_generic(message_key,message_value,message_comment:string);{update header using text only}
var
   count1: integer;
begin
  if ((pos('HISTORY',message_key)=0) and (pos('COMMENT',message_key)=0)) then {allow multiple lines of hisotry and comments}
  begin
    while length(message_value)<20 do message_value:=' '+message_value;{extend length, right aligned}
    while length(message_key)<8 do message_key:=message_key+' ';{make standard lenght of 8}

   count1:=memo1.Count-1;
    while count1>=0 do {update keyword}
    begin
      if pos(message_key,memo1.strings[count1])>0 then {found}
      begin
        memo1.strings[count1]:=message_key+'= '+message_value+' / '+message_comment;
        exit;
      end;
      count1:=count1-1;
    end;
    {not found, add to the end}
    memo1.insert(memo1.Count-1,message_key+'= '+message_value+' / '+message_comment);
  end {no history of comment keyword}
  else
  memo1.insert(memo1.Count-1,message_key+' '+message_value+message_comment);
end;


procedure update_longstr(inpt,thestr:string);{update or insert long str including single quotes}
var
   count1,m,k: integer;
   ampersand : string;
begin

  count1:=memo1.Count-1;
  while count1>=0 do {delete keyword}
  begin
    if pos(inpt,memo1.strings[count1])>0 then {found, delete old keyword}
    begin
      memo1.delete(count1);
      while pos('CONTINUE=',memo1.strings[count1])>0 do
        memo1.delete(count1);
    end;
    count1:=count1-1;
  end;

  {keyword removed, add new to the end}
  m:=length(thestr);

  if m>68 then
  begin {write as multi record}
    memo1.insert(memo1.Count-1,inpt+' '+#39+copy(thestr,1,67)+'&'+#39);{text starting with char(39) should start at position 11 according FITS standard 4.0}
    k:=68;
    repeat {write in blocks of 67 char}
      if (m-k)>67 then ampersand:='&' else ampersand:='';
      memo1.insert(memo1.Count-1,'CONTINUE= '+#39+copy(thestr,k,67)+ampersand+#39);{text starting with char(39) should start at position 11 according FITS standard 4.0}
      inc(k,67);
    until k>=m;
  end
  else {write as single record}
  memo1.insert(memo1.Count-1,inpt+' '+#39+thestr+#39);

end;


procedure update_text(inpt,comment1:string);{update or insert text in header}
var
   count1: integer;
begin

  count1:=memo1.Count-1;
  while count1>=0 do {update keyword}
  begin
    if pos(inpt,memo1.strings[count1])>0 then {found}
    begin
      memo1.strings[count1]:=inpt+' '+comment1;{text starting with char(39) should start at position 11 according FITS standard 4.0}
      exit;
    end;
    count1:=count1-1;
  end;
  {not found, add to the end}
  memo1.insert(memo1.Count-1,inpt+' '+comment1);
end;


procedure update_float(inpt,comment1:string;x:double);{update keyword of fits header in memo}
 var
   s,aline  : string;
   count1: integer;
begin
  str(x:20,s);

  count1:=memo1.Count-1;
  while count1>=0 do {update keyword}
  begin
    if pos(inpt,memo1.strings[count1])>0 then {found}
    begin
      aline:=memo1.strings[count1];
      if copy(aline,32,1)='/' then
        delete(aline,11,20) {preserve comment}
      else
        delete(aline,11,80);  {delete all}

      insert(s,aline,11);
      memo1.strings[count1]:=aline;
      exit;
    end;
    count1:=count1-1;
  end;
  {not found, add to the end}
  memo1.insert(memo1.Count-1,inpt+' '+s+comment1);
end;

procedure add_long_comment(descrip:string);{add long text to header memo. Split description over several lines if required}
var
   i,j :integer;
begin
  i:=1 ;
  j:=length(descrip);
  while i<j do
  begin
    memo1.insert(memo1.Count-1,'COMMENT '+copy(descrip,I,72) );  {add to the end. Limit line length to 80}
    inc(i,72);
  end;
end;


function JdToDate(jd:double):string;{Returns Date from Julian Date,  See MEEUS 2 page 63}
var A,B,C,D,E,F,G,J,M,T,Z: double; {!!! 2016 by purpose, otherwise with timezone 8, 24:00 midnigth becomes 15:59 UTC}
    HH, MM, SS           : integer;
    year3                : STRING[6];
begin
  if (abs(jd)>1461*10000) then begin result:='Error, JD outside allowed range!' ;exit;end;

  jd:=jd+(0.5/(24*3600));{2016 one 1/2 second extra for math errors, fix problem with timezone 8, 24:00 midnight becomes 15:59 UTC}

  Z:=trunc (JD + 0.5);
  F:=Frac(JD + 0.5);
  If Z < 2299160.5 Then A:=Z // < 15.10.1582 00:00 {Note Meeus 2 takes midday 12:00}
  else
  begin
   g:= int((Z-1867216.25) / 36524.25);
   a:=z+1+g-trunc(g/4);
  end;
  B := A+1524+ {special =>} (1461*10000);{allow up to 40.000 year in past, 1461 days *100000 = 4x 10000 years}
  C := trunc((B-122.1)/365.25);
  D := trunc(365.25 * C);
  E := trunc((B-D)/30.6001);
  T := B-D-int(30.6001*E) + F; {day of the month}
  if(E<14) then
    M := E-1
  else
    M := E-13;
  if (M>2) then
      J := C-4716
  else
      J := C-4715;

   j:=J - {special= >} 4*10000;{allow up to 40.000 year in past, 1461 days *100000 = 4x 10000 years}

  F:=fnmodulo(F,1);{for negative julian days}
  HH:=trunc(F*24);
  MM:=trunc((F-HH/24)*(24*60));{not round otherwise 23:60}
  SS:=trunc((F-HH/24-MM/(24*60))*(24*3600));

  str(trunc(j):4,year3);

  result:=year3+'-' +leadingzero(trunc(m))+'-'+leadingzero(trunc(t))+'T'+leadingzero(HH)+':'+leadingzero(MM)+':'+leadingzero(SS);
end;


procedure read_keys_memo(naxis3: integer);{for tiff, header in the describtion decoding}
var
  key                                      : string;
  count1,index                             : integer;
  error1                   : boolean;

  function read_float: double;
  var
    err: integer;
  begin
    val(copy(memo1.strings[index],11,20),result,err);
  end;
  function read_integer: integer;
  var
    err: integer;
  begin
    val(copy(memo1.strings[index],11,20),result,err);
  end;
  function read_string: string;
  var
    p1,p2 :integer;
  begin
    result:=copy(memo1.strings[index],11,80-11);
    p1:=pos(char(39),result);
    p2:=posex(char(39),result,p1+1);
    if p2=0 then p2:=20;
    result:=trim(copy(result,p1+1,p2-p1-1));{remove all spaces}
  end;

begin
  {variables are already reset}
  count1:=memo1.Count-1-1;

  index:=1;
  while index<=count1 do {read keys}
  begin
    key:=copy(memo1.strings[index],1,9);

    //should in this sequence available. If not fix.
    if index=1 then if key<>'BITPIX  =' then begin memo1.insert(index,'BITPIX  =                   16 / Bits per entry                                 '); inc(count1); end;{data will be added later}
    if index=2 then if key<>'NAXIS   =' then begin memo1.insert(index,'NAXIS   =                    2 / Number of dimensions                           ');inc(count1); end;{data will be added later}
    if index=3 then if key<>'NAXIS1  =' then begin memo1.insert(index,'NAXIS1  =                  100 / length of x axis                               ');inc(count1); end;{data will be added later}
    if index=4 then if key<>'NAXIS2  =' then begin memo1.insert(index,'NAXIS2  =                  100 / length of y axis                               ');inc(count1); end;{data will be added later}
    if ((index=5) and (naxis3>1)) then if key<>'NAXIS3  =' then begin memo1.insert(index,'NAXIS3  =                    3 / length of z axis (mostly colors)               ');inc(count1); end;


    if key='CD1_1   =' then cd1_1:=read_float else
    if key='CD1_2   =' then cd1_2:=read_float else
    if key='CD2_1   =' then cd2_1:=read_float else
    if key='CD2_2   =' then cd2_2:=read_float else

    if key='CRVAL1  =' then ra0:=read_float*pi/180 {degrees -> radians}  else
    if key='CRVAL2  =' then dec0:=read_float*pi/180 else
    if key='RA      =' then
    begin
      ra_mount:=read_float*pi/180;{degrees -> radians}
      if ra0=0 then ra0:=ra_mount; {ra telescope, read double value only if crval is not available}
    end else
    if key='DEC     =' then
    begin
      dec_mount:=read_float*pi/180;
      if dec0=0 then dec0:=dec_mount; {ra telescope, read double value only if crval is not available}
    end else
    if ((key='OBJCTRA =') and (ra_mount>=999)) {ra_mount value is unfilled, preference for keyword RA} then
    begin
      ra1:=read_string;{triggers an onchange event which will convert the string to ra_radians}
      ra_mount:=ra_radians;{preference for keyword RA}
    end  else
    if ((key='OBJCTDEC=') and (dec_mount>=999)) {dec_mount value is unfilled, preference for keyword DEC} then
    begin
      dec1:=read_string;{triggers an onchange event which will convert the string to dec_radians}
      dec_mount:=dec_radians;
    end else

    if (key='XBINNING=') then xbinning:=read_integer else
    if (key='YBINNING=') then ybinning:=read_integer else

    if (key='FOCALLEN=') then focallen:=read_float else
    if (key='XPIXSZ  =') then xpixsz:=read_float else  {pixelscale in microns}
    if (key='YPIXSZ  =') then ypixsz:=read_float else
    if (key='CDELT2  =') then cdelt2:=read_float else   {deg/pixel}
    if (key='EQUINOX =') then equinox:=read_float else


    if ((key='SECPIX2 =') or
        (key='PIXSCALE=') or
        (key='SCALE   =')) then begin if cdelt2=0 then cdelt2:=read_float/3600; end {no cdelt1/2 found yet, use alternative, image scale arcseconds per pixel}
    else

    if key='DATE-OBS=' then date_obs:=read_string else

    index:=index+1;
  end;

  if ((ra0<>0) or (dec0<>0)) then
  begin
    if equinox<>2000 then //e.g. in SharpCap
    begin
      precession_Jnow_to_J2000(equinox,ra0,dec0); {precession, from unknown equinox to J2000}
      if dec_mount<999 then precession_Jnow_to_J2000(equinox,ra_mount,dec_mount); {precession, from unknown equinox to J2000}
    end;
    ra1:=prepare_ra(ra0,' ');{this will create Ra_radians for solving}
    dec1:=prepare_dec(dec0,' ');
  end
  else
  if ra1<>'' then
  begin
    ra_text_to_radians ( ra1 ,ra0,error1); {convert ra text to ra0 in radians}
    dec_text_to_radians( dec1,dec0,error1); {convert dec text to dec0 in radians}
  end;


  { condition           keyword    to
   if ra_mount>999 then objctra--->ra1.text--------------->ra_radians--->ra_mount
                             ra--->ra_mount  if ra0=0 then   ra_mount--->ra0
                         crval1--->ra0

   if ra0<>0 then           ra0--->ra1.text------------------->ra_radians}



  if cdelt2=0 then {simple code for astap-cli only}
  begin
    if cd1_1=0 then  {no scale, try to fix it}
    begin
     if ((focallen<>0) and (xpixsz<>0)) then
        cdelt2:=180/(pi*1000)*xpixsz/focallen; {use maxim DL key word. xpixsz is including binning}
    end
    else
    cdelt2:=sqrt(sqr(cd1_2)+sqr(cd2_2));
  end;
end;


function load_PPM_PGM_PFM(filen:string; out img_loaded2: Timage_array) : boolean;{load PPM (color),PGM (gray scale)file or PFM color}
var
  TheFile  : tfilestream;
  i,j, reader_position,naxis,s        : integer;
  aline,w1,h1,bits,comm,comment_line  : ansistring;
  ch                : ansichar;
  rgb32dummy        : byteXXXX3;
  rgb16dummy        : byteXX3;
  rgbdummy          : byteX3;
  width2,height2, err,err2,err3,package,naxis3      : integer;
  comment,color7,pfm,expdet,timedet,isodet,instdet,ccdtempdet  : boolean;
  range, jd2        : double;
  thecomments       : TStringList;
var
  x_longword  : longword;
  x_single    : single absolute x_longword;{for conversion 32 bit "big-endian" data}

     procedure close_fits_file; inline;
     begin
       Reader.free;
       TheFile.free;
     end;

begin
  naxis:=0; {0 dimensions}
  result:=false; {assume failure}

  try
    TheFile:=tfilestream.Create( filen, fmOpenRead or fmShareDenyWrite);
  except
     beep;
     writeln('Error, accessing the file!');
     exit;
  end;
  memo1.clear;{clear memo for new header}

  memo1.beginupdate;
  memo1.clear;{clear memo for new header}

  Reader := TReader.Create (TheFile,$60000);// 393216 byte buffer
  {TheFile.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}

  {Reset variables}
  reset_fits_global_variables; {reset the global variable}

  I:=0;
  reader_position:=0;

  aline:='';
  try
    for i:=0 to 2 do begin reader.read(ch,1); aline:=aline+ch; inc(reader_position,1);end;
    if ((aline<>'P5'+#10) and (aline<>'P6'+#10) and (aline<>'PF'+#10) and (aline<>'Pf'+#10)) then
    begin
      close_fits_file;
      beep;
      writeln('Error, unknown format!');
      fits_file:=false;
      exit;
    end ;{should start with P6}

    pfm:=false;
    if aline='P5'+#10 then color7:=false {gray scale image}
    else
    if aline='P6'+#10 then color7:=true  {colour scale image}
    else
    if aline='PF'+#10 then begin color7:=true; pfm:=true; end  {PFM colour scale image, photoshop export float 32 bit}
    else
    if aline='Pf'+#10 then begin color7:=false; pfm:=true; end;  {PFM colour scale image, photoshop export float 32 bit grayscale}

    comment_line:='';
    thecomments := TStringList.Create; // This is needed when using this class(or most classes)
    i:=0;
    repeat {read header}
      comment:=false;
      expdet:=false;
      timedet:=false;
      ccdtempdet:=false;
      aline:='';
      comm:='';
      repeat
        reader.read(ch,1);
        if ch='#' then comment:=true;{reading comment}
        if comment then {this works only for files produced by special custom DCRAW version. Code for identical Libraw modification proposed at Github}
        begin
          if ch in [';','#',' ',char($0A)]=false then comm:=comm+ch
          else
          begin
            if expdet then begin exposure:=strtofloat2(comm);expdet:=false; end;{get exposure time from comments,special dcraw 0.9.28dev1}
            if isodet then begin gain:=strtofloat2(comm);isodet:=false; end;{get iso speed as gain}
            if instdet then begin instrum:=comm;instdet:=false;end;{camera}
            if timedet then
            begin
              JD2:=2440587.5+ strtoint(comm)/(24*60*60);{convert to Julian Day by adding factor. Unix time is seconds since 1.1.1970}
              date_obs:=JdToDate(jd2);
              timedet:=false;
            end;{get date from comments}
            comment_line:=comment_line+comm+' ';//for full comment line
            comm:='';{clear for next keyword}
          end;
          if comm='EXPTIME=' then begin expdet:=true; comm:=''; end else
          if comm='TIMESTAMP=' then begin timedet:=true; comm:=''; end else
          if comm='ISOSPEED=' then begin isodet:=true; comm:=''; end else
          if comm='MODEL=' then begin instdet:=true; comm:=''; end; {camera make}
          if comm='CCD-TEMP=' then begin ccdtempdet:=true; comm:=''; end; {camera make}
        end
        else
        if ord(ch)>32 then aline:=aline+ch;; {DCRAW write space #20 between width&length, Photoshop $0a}

        if ord(ch)=$0a then
        begin
           comment:=false;{complete comment read}
           thecomments.add(comment_line);//store the comments
           comment_line:='';
        end;
        inc(reader_position,1)
      until ( ((comment=false) and (ord(ch)<=32)));
      if (length(aline)>1){no comments} then {read header info}
      begin
        inc(i);{useful header line}
        if i=1 then w1:=aline {width}
        else
        if i=2 then h1:=aline {height}
        else
        bits:=aline;
      end;
    until i>=3;

    val(w1,width2,err);
    val(h1,height2,err2);

    val(bits,range,err3);{number of bits}

    nrbits:=round(range);

    if pfm then begin nrbits:=-32; datamax_org:=$FFFF;end     {little endian PFM format. If nrbits=-1 then range 0..1. If nrbits=+1 then big endian with range 0..1 }
    else
    if nrbits=65535 then begin nrbits:=16; datamax_org:=$FFFF;end
    else
    if nrbits=255 then begin nrbits:=8;datamax_org:=$FF; end
    else
      err3:=999;

    if ((err<>0) or (err2<>0) or (err3<>0)) then
    begin
      beep;
      writeln('Error, accessing the file!');
      close_fits_file;
      fits_file:=false;
      thecomments.free; //tstringlist
      exit;
    end; {should contain 255 or 65535}

    datamin_org:=0;
    backgr:=0;{for case histogram is not called}

    if color7 then
    begin
       package:=round((abs(nrbits)*3/8));{package size, 3 or 6 bytes}
       naxis3:=3; {naxis3 number of colors}
       naxis:=3; {number of dimensions}
    end
    else
    begin {gray image without bayer matrix applied}
      package:=round((abs(nrbits)/8));{package size, 1 or 2 bytes}
      naxis3:=1; {naxis3 number of colors}
      naxis:=2;{number of dimensions}
    end;
    i:=round(bufwide/package);
    if width2>i then
    begin
      beep;
      writeln('Too large FITS file !!!!!');
      close_fits_file;
      thecomments.free; //tstringlist
      exit;
    end
    else
    begin {not too large}
      setlength(img_loaded2,naxis3,height2,width2);
      begin
        For i:=0 to height2-1 do
        begin
          try reader.read(fitsbuffer,width2*package);except; end; {read file info}

          for j:=0 to width2-1 do
          begin
            if color7=false then {gray scale without bayer matrix applied}
            begin
              if nrbits=8 then  {8 BITS, mono 1x8bits}
                img_loaded2[0,i,j]:=fitsbuffer[j]{RGB fits with naxis1=3, treated as 48 bits coded pixels}
              else
              if nrbits=16 then {big endian integer}
                img_loaded2[0,i,j]:=swap(fitsbuffer2[j])
              else {PFM 32 bits grayscale}
              if pfm then
              begin
                if range<0 then {little endian floats}
                  img_loaded2[0,i,j]:=fitsbuffersingle[j]*65535/(-range) {PFM little endian float format. if nrbits=-1 then range 0..1. If nrbits=+1 then big endian with range 0..1 }
                else
                begin {big endian floats}
                  x_longword:=swapendian(fitsbuffer4[j]);{conversion 32 bit "big-endian" data, x_single  : single absolute x_longword; }
                  img_loaded2[0,i,j]:=x_single*65535/range;
                end;
              end;
            end
            else
            begin
              if nrbits=8 then {24 BITS, colour 3x8bits}
              begin
                rgbdummy:=fitsbufferRGB[j];{RGB fits with naxis1=3, treated as 48 bits coded pixels}
                img_loaded2[0,i,j]:=rgbdummy[0];{store in memory array}
                img_loaded2[1,i,j]:=rgbdummy[1];{store in memory array}
                img_loaded2[2,i,j]:=rgbdummy[2];{store in memory array}
              end
              else
              if nrbits=16 then {48 BITS colour, 3x16 big endian}
              begin {48 bits}
                rgb16dummy:=fitsbufferRGB16[j];{RGB fits with naxis1=3, treated as 48 bits coded pixels}
                img_loaded2[0,i,j]:=swap(rgb16dummy[0]);{store in memory array}
                img_loaded2[1,i,j]:=swap(rgb16dummy[1]);{store in memory array}
                img_loaded2[2,i,j]:=swap(rgb16dummy[2]);{store in memory array}
              end
              else
              if pfm then
              begin {PFM little-endian float 3x 32 bit colour}
                if range<0 then {little endian}
                begin
                  rgb32dummy:=fitsbufferRGB32[j];{RGB fits with naxis1=3, treated as 96 bits coded pixels}
                  img_loaded2[0,i,j]:=(rgb32dummy[0])*65535/(-range);{store in memory array}
                  img_loaded2[1,i,j]:=(rgb32dummy[1])*65535/(-range);{store in memory array}
                  img_loaded2[2,i,j]:=(rgb32dummy[2])*65535/(-range);{store in memory array}
                end
                else
                begin {PFM big-endian float 32 bit colour}
                  x_longword:=swapendian(fitsbuffer4[j*3]);
                  img_loaded2[0,i,j]:=x_single*65535/(range);
                  x_longword:=swapendian(fitsbuffer4[j*3+1]);
                  img_loaded2[1,i,j]:=x_single*65535/(range);
                  x_longword:=swapendian(fitsbuffer4[j*3+2]);
                  img_loaded2[2,i,j]:=x_single*65535/(range);
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  except;
    close_fits_file;
    thecomments.free; //tstringlist
    exit;
  end;

  close_fits_file;
  result:=true;{succes}

  for j:=0 to 10 do {create an header with fixed sequence}
    if ((j<>5) or  (naxis3<>1)) then {skip naxis3 for mono images}
        memo1.add(head1[j]); {add lines to empthy memo1}
  memo1.add(head1[27]); {add end}

  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS   =',' / Number of dimensions                           ' ,naxis);{2 for mono, 3 for colour}
  update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);
  if naxis3<>1 then
    update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,naxis3);
  update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer('DATAMAX =',' / Maximum data value                           ' ,round(datamax_org));

  if exposure<>0 then   update_float('EXPTIME =',' / duration of exposure in seconds                ' ,exposure);
  if gain<>999 then     update_float('GAIN    =',' / iso speed                                      ' ,gain);

  if date_obs<>'' then add_text('DATE-OBS=',#39+date_obs+#39);
  if instrum<>''  then add_text('INSTRUME=',#39+INSTRUM+#39);

  if naxis3<>1 then
    add_text('BAYERPAT=',#39+'T'+#39+'                  / Unknown Bayer color pattern                  ');

  add_text('COMMENT 1','  Written by ASTAP, Astrometric STAcking Program. www.hnsky.org');

  for s:=0 to thecomments.count-1 do
      add_text('COMMENT',thecomments[s]);{add PGM comments to header memo}

  memo1.endupdate;
  thecomments.free; //tstringlist
end;


function FileSize1(const Filename: string): int64;
var F : file of byte;
begin
 assign (F, Filename);
 reset (F);
 result := System.FileSize(F);
 close (F);
end;


function load_TIFFPNGJPEG(filen:string; var img_loaded2: Timage_array) : boolean;{load 8 or 16 bit TIFF, PNG, JPEG, BMP image}
var
  i,j,width2,height2,naxis3,naxis   : integer;
  jd2                               : double;
  image                             : TFPCustomImage;
  reader                            : TFPCustomImageReader;
  tiff, png,jpeg,colour,saved_header  : boolean;
  ext,descrip                       : string;
begin
  naxis:=0; {0 dimensions for case failure}
  result:=false; {assume failure}
  tiff:=false;
  jpeg:=false;
  png:=false;
  saved_header:=false;
  ext:=uppercase(ExtractFileExt(filen));
  try


    if filesize1(filen)<300*1024*1024 then //less then 300 mbytes. Should fit TFPMemoryImage for colour and grayscale
      Image := TFPMemoryImage.Create(10, 10) //for colour and grayscale up to 2gbyte/3
    else
      Image := TFPCompactImgGray16Bit.Create(10, 10);//compact up to 2gbyte for grayscale images only   //See https://gitlab.com/freepascal.org/fpc/source/-/issues/41022


    if ((ext='.TIF') or (ext='.TIFF')) then
    begin
       Reader :=  TFPReaderTIFF.Create;
       tiff:=true;
    end
    else
    if ext='.PNG' then begin
      Reader :=  TFPReaderPNG.Create;
      png:=true;
    end
    else
    if ((ext='.JPG') or (ext='.JPEG')) then
    begin
      Reader :=  TFPReaderJPEG.Create;
      jpeg:=true;
    end
    else
    if ext='.BMP' then Reader :=  TFPReaderBMP.create
    else
    //  if ((ext='.PPM') or (ext='.PGM')) then
    //    Reader :=  TFPReaderPNM.Create else {not used since comment have to be read}
    exit;

    Image.LoadFromFile(filen, Reader);
  except
     beep;
     writeln('Error, accessing the file!');
     exit;
  end;

  {$IF FPC_FULLVERSION >= 30200} {FPC3.2.0}
  colour:=true;
  if ((tiff) and (Image.Extra[TiffGrayBits]<>'0')) then colour:=false; {image grayscale?}
  if ((png) and (TFPReaderPNG(reader).grayscale)) then colour:=false; {image grayscale?}
  if ((jpeg) and (TFPReaderJPEG(reader).grayscale)) then colour:=false; {image grayscale?}
  {BMP always colour}
  {$else} {for older compiler versions}
  colour:=false;
  with image do {temporary till grayscale is implemented in fcl-image}
  begin
    i:=0;
    j:=height div 2;
    while ((colour=false) and (i<width)) do {test horizontal line}
    begin
      colour:=((Colors[i,j].red<>Colors[i,j].green) or  (Colors[i,j].red<>Colors[i,j].blue));
      inc(i);
    end;
    i:=width div 2;
    j:=0;
    while ((colour=false) and (j<height)) do {test vertical line}
    begin
      colour:=((Colors[i,j].red<>Colors[i,j].green) or  (Colors[i,j].red<>Colors[i,j].blue));
      inc(j);
    end;
  end;
  {$ENDIF}

  {Reset variables}
  reset_fits_global_variables; {reset the global variable}

  if colour=false then
  begin
     naxis:=2;
     naxis3:=1;
  end
  else
  begin
    naxis:=3; {three dimensions, x,y and 3 colours}
    naxis3:=3;
  end;

  memo1.clear;{clear memo for new header}

  {set data}
  fits_file:=true;
  nrbits:=16;

  width2:=image.width;
  height2:=image.height;
  setlength(img_loaded2,naxis3,height2,width2);

  if naxis3=3 then
  begin
    For i:=0 to height2-1 do
      for j:=0 to width2-1 do
      begin
        img_loaded2[0,height2-1-i,j]:=image.Colors[j,i].red;
        img_loaded2[1,height2-1-i,j]:=image.Colors[j,i].green;
        img_loaded2[2,height2-1-i,j]:=image.Colors[j,i].blue;
      end;
  end
  else
  begin
    For i:=0 to height2-1 do
      for j:=0 to width2-1 do
        img_loaded2[0,height2-1-i,j]:=image.Colors[j,i].red;
  end;

  if tiff then
  begin
    descrip:=image.Extra['TiffImageDescription']; {restore full header in TIFF !!!}
  end;

  if copy(descrip,1,6)='SIMPLE' then {fits header included}
  begin
    memo1.text:=descrip;
    read_keys_memo(naxis3);
    saved_header:=true;
  end
  else {no fits header in tiff file available}
  begin
    for j:=0 to 10 do {create an header with fixed sequence}
      if ((j<>5) or  (naxis3<>1)) then {skip naxis3 for mono images}
       memo1.add(head1[j]); {add lines to empthy memo1}
    memo1.add(head1[27]); {add end}
    if descrip<>'' then add_long_comment(descrip);{add TIFF describtion}
  end;

  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS   =',' / Number of dimensions                           ' ,naxis);{2 for mono, 3 for colour}
  update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);

  update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);
  update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer('DATAMAX =',' / Maximum data value                             ' ,round(datamax_org));

  if saved_header=false then {saved header in tiff is not restored}
  begin
    JD2:=2415018.5+(FileDateToDateTime(fileage(filen))); {fileage ra, convert to Julian Day by adding factor. filedatatodatetime counts from 30 dec 1899.}
    date_obs:=JdToDate(jd2);
    add_text ('DATE-OBS=',#39+date_obs+#39);{give start point exposures}
  end;

  update_text   ('COMMENT 1','  Written by ASTAP, Astrometric STAcking Program. www.hnsky.org');

  { Clean up! }
  image.Free;
  reader.free;
  result:=true;{succes}
end;


function load_image: boolean; {load fits or PNG, BMP, TIF}
var
   ext1   : string;
begin
  ext1:=uppercase(ExtractFileExt(filename2));

  if ((ext1='.FIT') or (ext1='.FITS') or (ext1='.FTS') or (ext1='.NEW')) then {FITS}
    result:=load_fits(filename2,img_loaded) //fits
  else
  if ((ext1='.PPM') or (ext1='.PGM') or (ext1='.PFM') or (ext1='.PBM')) then {PPM/PGM/ PFM}
    result:=load_PPM_PGM_PFM(filename2,img_loaded) {load the simple formats ppm color or pgm grayscale, exit on failure}
  else
  if ((ext1='.TIF') or (ext1='.TIFF') or (ext1='.PNG') or (ext1='.JPG') or (ext1='.JPEG') or (ext1='.BMP')) then {tif, png, bmp, jpeg}
    result:=load_tiffpngJPEG(filename2,img_loaded) {tif, png, bmp, jpeg}
  else
  result:=false;
end;


procedure get_hist(colour:integer; img :Timage_array);
var
     i,j,col,his_total,count, width5, height5,offsetW,offsetH : integer;
     total_value                                : double;
begin
  if colour+1>length(img) then {robust detection, case binning is applied and image is mono}
    colour:=0; {used red only}

  for i:=0 to 65535 do
    histogram[colour,i] := 0;{clear histogram of specified colour}

  his_total:=0;
  total_value:=0;
  count:=1;{prevent divide by zero}
  width5:=Length(img[0,0]); {width}
  height5:=Length(img[0]); {height}

  offsetW:=trunc(width5*0.042); {if Libraw is used, ignored unused sensor areas up to 4.2%}
  offsetH:=trunc(height5*0.015); {if Libraw is used, ignored unused sensor areas up to 1.5%}


  For i:=0+offsetH to height5-1-offsetH do
  begin
    for j:=0+offsetW to width5-1-offsetW do
    begin
      col:=round(img[colour,i,j]);{red}
      if ((col>=1) and (col<65000)) then {ignore black overlap areas and bright stars}
      begin
        inc(histogram[colour,col],1);{calculate histogram}
        his_total:=his_total+1;
        total_value:=total_value+col;
        inc(count);
      end;
    end;{j}
  end; {i}

  his_mean[colour]:=round(total_value/count);
end;


procedure get_background(colour: integer; img :Timage_array;calc_hist, calc_noise_level: boolean; out background, star_level, star_level2: double); {get background and star level from peek histogram}
var
  i, pixels,max_range,above, fitsX, fitsY,counter,stepsize,width5,height5, iterations : integer;
  value,sd, sd_old,factor,factor2 : double;
begin
  if calc_hist then
             get_hist(colour,img);{get histogram of img_loaded and his_total}

  background:=img[0,0,0];{define something for images containing 0 or 65535 only}

  {find peak in histogram which should be the average background}
  pixels:=0;
  max_range:=his_mean[colour]; {mean value from histogram}
  if max_range=0 then //mean value
  begin //empthy colour
    background:=0;
  end
  else
  for i := 1 to max_range do {find peak, ignore value 0 from oversize}
    if histogram[colour,i]>pixels then {find colour peak}
    begin
      pixels:= histogram[colour,i];
      background:=i;
    end;

  {check alternative mean value}
  if his_mean[colour]>1.5*background {1.5* most common} then
  begin
    memo2_message('Will use mean value '+inttostr(round(his_mean[colour]))+' as background rather then most common value '+inttostr(round(background)));
    background:=his_mean[colour];{strange peak at low value, ignore histogram and use mean}
  end;

  if calc_noise_level then  {find star level and background noise level}
  begin
    {calculate noise level}
    width5:=Length(img[0,0]); {width}
    height5:=Length(img[0]); {height}
    stepsize:=round(height5/71);{get about 71x71=5000 samples. So use only a fraction of the pixels}
    if odd(stepsize)=false then stepsize:=stepsize+1;{prevent problems with even raw OSC images}

    sd:=99999;
    iterations:=0;
    repeat  {repeat until sd is stable or 7 iterations}
      fitsX:=15;
      counter:=0;
      sd_old:=sd;
      while fitsX<=width5-1-15 do
      begin
        fitsY:=15;
        while fitsY<=height5-1-15 do
        begin
          value:=img[colour,fitsY,fitsX];
          if ((value<background*2) and (value<>0)) then {not an outlier, noise should be symmetrical so should be less then twice background}
          begin
            if ((iterations=0) or (abs(value-background)<=3*sd_old)) then {ignore outliers after first run}
            begin
              sd:=sd+sqr(value-background); {sd}
              inc(counter);{keep record of number of pixels processed}
            end;
          end;
          inc(fitsY,stepsize);;{skip pixels for speed}
        end;
        inc(fitsX,stepsize);{skip pixels for speed}
      end;
      if counter<>0 then
        sd:=sqrt(sd/counter) {standard deviation}
      else
        sd:=0;
      inc(iterations);
    until (((sd_old-sd)<0.05*sd) or (iterations>=7));{repeat until sd is stable or 7 iterations}
    noise_level[colour]:= sd;   {this noise level is too high for long exposures and if no flat is applied. So for images where center is brighter then the corners.}


    {calculate star level}
    if ((nrbits=8) or (nrbits=24)) then max_range:= 255 else max_range:=65001 {histogram runs from 65000};{8 or 16 / -32 bit file}
    i:=max_range;
    star_level:=0;
    star_level2:=0;
    above:=0;

    factor:=6*max_stars;//emperical. Number of pixels to test. This produces about 700 stars at hfd=2.25.
    factor2:=24*max_stars;//emperical. Number of pixels to test. This produces about 700 stars at hfd=4.5.

    while ((star_level=0) and (i>background+1)) do {Find star level. 0.001 of the flux is above star level. If there a no stars this should be all pixels with a value 3.09 * sigma (SD noise) above background}
    begin
      dec(i);
      above:=above+histogram[colour,i];//sum pixels above pixel level i
      if above>=factor then star_level:=i;//level found for stars with HFD=2.25.
    end;
    while ((star_level2=0) and (i>background+1)) do {Find star level. 0.001 of the flux is above star level. If there a no stars this should be all pixels with a value 3.09 * sigma (SD noise) above background}
    begin
      dec(i);
      above:=above+histogram[colour,i];//sum pixels above pixel level i
      if above>=factor2 then star_level2:=i;//level found for stars with HFD=4.5.
    end;


    // Clip calculated star level:
    // 1) above 3.5*noise minimum, but also above background value when there is no noise so minimum is 1
    // 2) Below saturated level. So subtract 1 for saturated images. Otherwise no stars are detected}
    star_level:=max(max(3.5*sd,1 {1}), star_level-background-1 {2) below saturation});//star_level is relative to background
    star_level2:=max(max(3.5*sd,1 {1}), star_level2-background-1 {2) below saturation});//star_level is relative to background

  end;
end;


procedure HFD(img: Timage_array;x1,y1,rs {boxsize}: integer; out hfd1,star_fwhm,snr{peak/sigma noise}, flux,xc,yc:double);{calculate star HFD and FWHM, SNR, xc and yc are center of gravity. All x,y coordinates in array[0..] positions}
const
  max_ri=74; //(50*sqrt(2)+1 assuming rs<=50. Should be larger or equal then sqrt(sqr(rs+rs)+sqr(rs+rs))+1+2;
var
  width2, height2, i, j, r1_square, r2_square,r2, distance,distance_top_value,illuminated_pixels,signal_counter,counter :integer;
  SumVal, SumValX,SumValY,SumValR, Xg,Yg, r, val,star_bg,pixel_counter,valmax,mad_bg,sd_bg    : double;
  HistStart,boxed : boolean;
  distance_histogram : array [0..max_ri] of integer;
  background : array [0..1000] of double; {size =3*(2*PI()*(50+3)) assuming rs<=50}

    function value_subpixel(x1,y1:double):double; {calculate image pixel value on subpixel level}
    var
      x_trunc,y_trunc: integer;
      x_frac,y_frac  : double;
    begin
      x_trunc:=trunc(x1);
      y_trunc:=trunc(y1);
      if ((x_trunc<=0) or (x_trunc>=(width2-2)) or (y_trunc<=0) or (y_trunc>=(height2-2))) then begin result:=0; exit;end;
      x_frac :=frac(x1);
      y_frac :=frac(y1);
      try
        result:=         (img[0,y_trunc  ,x_trunc  ]) * (1-x_frac)*(1-y_frac);{pixel left top,    1}
        result:=result + (img[0,y_trunc  ,x_trunc+1]) * (  x_frac)*(1-y_frac);{pixel right top,   2}
        result:=result + (img[0,y_trunc+1,x_trunc  ]) * (1-x_frac)*(  y_frac);{pixel left bottom, 3}
        result:=result + (img[0,y_trunc+1,x_trunc+1]) * (  x_frac)*(  y_frac);{pixel right bottom,4}
      except
      end;
    end;
begin
  width2:=Length(img[0,0]); {width}
  height2:=Length(img[0]);  {height}

  {rs should be <=50 to prevent runtime errors}
  r1_square:=rs*rs;{square radius}
  r2:=rs+1;{annulus width us 1}
  r2_square:=r2*r2;

  if ((x1-r2<=0) or (x1+r2>=width2-1) or
      (y1-r2<=0) or (y1+r2>=height2-1) )
    then begin hfd1:=999; snr:=0; exit;end;

  valmax:=0;
  hfd1:=999;
  snr:=0;

  try
    counter:=0;
    for i:=-r2 to r2 do {calculate the mean outside the the detection area}
    for j:=-r2 to r2 do
    begin
      distance:=i*i+j*j; {working with sqr(distance) is faster then applying sqrt}
      if ((distance>r1_square) and (distance<=r2_square)) then {annulus, circular area outside rs, typical one pixel wide}
      begin
        background[counter]:=img[0,y1+j,x1+i];
        //for testing: mainwindow.image1.canvas.pixels[x1+i,y1+j]:=$AAAAAA;
        inc(counter);
      end;
    end;

    star_bg:=Smedian(background,counter);
    for i:=0 to counter-1 do background[i]:=abs(background[i] - star_bg);{fill background with offsets}
    mad_bg:=Smedian(background,counter); //median absolute deviation (MAD)
    sd_bg:=mad_bg*1.4826; {Conversion from mad to sd for a normal distribution. See https://en.wikipedia.org/wiki/Median_absolute_deviation}
    sd_bg:=max(sd_bg,1); {add some value for images with zero noise background. This will prevent that background is seen as a star. E.g. some jpg processed by nova.astrometry.net}
    {sd_bg and r_aperture are global variables}

    repeat {reduce square annulus radius till symmetry to remove stars}
    // Get center of gravity whithin star detection box and count signal pixels, repeat reduce annulus radius till symmetry to remove stars
      SumVal:=0;
      SumValX:=0;
      SumValY:=0;
      signal_counter:=0;

      for i:=-rs to rs do
      for j:=-rs to rs do
      begin
        val:=(img[0,y1+j,x1+i])- star_bg;
        if val>3.0*sd_bg then
        begin
          SumVal:=SumVal+val;
          SumValX:=SumValX+val*(i);
          SumValY:=SumValY+val*(j);
          inc(signal_counter); {how many pixels are illuminated}
        end;
      end;
      if sumval<= 12*sd_bg then
         exit; {no star found, too noisy, exit with hfd=999}

      Xg:=SumValX/SumVal;
      Yg:=SumValY/SumVal;
      xc:=(x1+Xg);
      yc:=(y1+Yg);
     {center of gravity found}

      if ((xc-rs<0) or (xc+rs>width2-1) or (yc-rs<0) or (yc+rs>height2-1) ) then
                                 exit;{prevent runtime errors near sides of images}
      boxed:=(signal_counter>=(2/9)*sqr(rs+rs+1));{are inside the box 2 of the 9 of the pixels illuminated? Works in general better for solving then ovality measurement as used in the past}

      if boxed=false then
      begin
        if rs>4 then dec(rs,2) else dec(rs,1); {try a smaller window to exclude nearby stars}
      end;

      {check on hot pixels}
      if signal_counter<=1  then
      exit; {one hot pixel}
    until ((boxed) or (rs<=1)) ;{loop and reduce aperture radius until star is boxed}

    inc(rs,2);{add some space}

    // Build signal histogram from center of gravity
    for i:=0 to rs do distance_histogram[i]:=0;{clear signal histogram for the range used}
    for i:=-rs to rs do begin
      for j:=-rs to rs do begin

        distance:=round(sqrt(i*i + j*j)); {distance from gravity center} {modA}
        if distance<=rs then {build histogram for circel with radius rs}
        begin
          val:=value_subpixel(xc+i,yc+j)-star_bg;
          if val>3.0*sd_bg then {3 * sd should be signal }
          begin
            distance_histogram[distance]:=distance_histogram[distance]+1;{build distance histogram up to circel with diameter rs}
            if val>valmax then valmax:=val;{record the peak value of the star}
          end;
        end;
      end;
    end;

    r_aperture:=-1;
    distance_top_value:=0;
    HistStart:=false;
    illuminated_pixels:=0;
    repeat
      inc(r_aperture);
      illuminated_pixels:=illuminated_pixels+distance_histogram[r_aperture];
      if distance_histogram[r_aperture]>0 then HistStart:=true;{continue until we found a value>0, center of defocused star image can be black having a central obstruction in the telescope}
      if distance_top_value<distance_histogram[r_aperture] then distance_top_value:=distance_histogram[r_aperture]; {this should be 2*pi*r_aperture if it is nice defocused star disk}
    until ( (r_aperture>=rs) or (HistStart and (distance_histogram[r_aperture]<=0.1*distance_top_value {drop-off detection})));{find a distance where there is no pixel illuminated, so the border of the star image of interest}
    if r_aperture>=rs then exit; {star is equal or larger then box, abort}

    if (r_aperture>2)and(illuminated_pixels<0.35*sqr(r_aperture+r_aperture-2)){35% surface} then exit;  {not a star disk but stars, abort with hfd 999}

    except
  end;

  // Get HFD
  SumVal:=0;
  SumValR:=0;
  pixel_counter:=0;

  // Get HFD using the aproximation routine assuming that HFD line divides the star in equal portions of gravity:
  for i:=-r_aperture to r_aperture do {Make steps of one pixel}
  for j:=-r_aperture to r_aperture do
  begin
    Val:=value_subpixel(xc+i,yc+j)-star_bg; {The calculated center of gravity is a floating point position and can be anyware, so calculate pixel values on sub-pixel level}
    r:=sqrt(i*i+j*j); {Distance from star gravity center}
    SumVal:=SumVal+Val;{Sumval will be star total star flux}
    SumValR:=SumValR+Val*r; {Method Kazuhisa Miyashita, see notes of HFD calculation method, note calculate HFD over square area. Works more accurate then for round area}
    if val>=valmax*0.5 then pixel_counter:=pixel_counter+1;{How many pixels are above half maximum}
  end;
  flux:=max(sumval,0.00001);{prevent dividing by zero or negative values}
  hfd1:=2*SumValR/flux;
  hfd1:=max(0.7,hfd1);

  star_fwhm:=2*sqrt(pixel_counter/pi);{calculate from surface (by counting pixels above half max) the diameter equals FWHM }

  snr:=flux/sqrt(flux +sqr(r_aperture)*pi*sqr(sd_bg));
    {For both bright stars (shot-noise limited) or skybackground limited situations
    snr := signal/noise
    snr := star_signal/sqrt(total_signal)
    snr := star_signal/sqrt(star_signal + sky_signal)
    equals
    snr:=flux/sqrt(flux + r*r*pi* sd^2).

    r is the diameter used for star flux measurement. Flux is the total star flux detected above 3* sd.

    Assuming unity gain ADU/e-=1
    See https://en.wikipedia.org/wiki/Signal-to-noise_ratio_(imaging)
    https://www1.phys.vt.edu/~jhs/phys3154/snr20040108.pdf
    http://spiff.rit.edu/classes/phys373/lectures/signal/signal_illus.html}


  {==========Notes on HFD calculation method=================
    Documented this HFD definition also in https://en.wikipedia.org/wiki/Half_flux_diameter
    References:
    https://astro-limovie.info/occultation_observation/halffluxdiameter/halffluxdiameter_en.html       by Kazuhisa Miyashita. No sub-pixel calculation
    https://www.lost-infinity.com/night-sky-image-processing-part-6-measuring-the-half-flux-diameter-hfd-of-a-star-a-simple-c-implementation/
    http://www.ccdware.com/Files/ITS%20Paper.pdf     See page 10, HFD Measurement Algorithm

    HFD, Half Flux Diameter is defined as: The diameter of circle where total flux value of pixels inside is equal to the outside pixel's.
    HFR, half flux radius:=0.5*HFD
    The pixel_flux:=pixel_value - background.

    The approximation routine assumes that the HFD line divides the star in equal portions of gravity:
        sum(pixel_flux * (distance_from_the_centroid - HFR))=0
    This can be rewritten as
       sum(pixel_flux * distance_from_the_centroid) - sum(pixel_values * (HFR))=0
       or
       HFR:=sum(pixel_flux * distance_from_the_centroid))/sum(pixel_flux)
       HFD:=2*HFR

    This is not an exact method but a very efficient routine. Numerical checking with an a highly oversampled artificial Gaussian shaped star indicates the following:

    Perfect two dimensional Gaussian shape with σ=1:   Numerical HFD=2.3548*σ                     Approximation 2.5066, an offset of +6.4%
    Homogeneous disk of a single value  :              Numerical HFD:=disk_diameter/sqrt(2)       Approximation disk_diameter/1.5, an offset of -6.1%

    The approximate routine is robust and efficient.

    Since the number of pixels illuminated is small and the calculated center of star gravity is not at the center of an pixel, above summation should be calculated on sub-pixel level (as used here)
    or the image should be re-sampled to a higher resolution.

    A sufficient signal to noise is required to have valid HFD value due to background noise.

    Note that for perfect Gaussian shape both the HFD and FWHM are at the same 2.3548 σ.
    }


   {=============Notes on FWHM:=====================
      1)	Determine the background level by the averaging the boarder pixels.
      2)	Calculate the standard deviation of the background.

          Signal is anything 3 * standard deviation above background

      3)	Determine the maximum signal level of region of interest.
      4)	Count pixels which are equal or above half maximum level.
      5)	Use the pixel count as area and calculate the diameter of that area  as diameter:=2 *sqrt(count/pi).}
end;


procedure sensor_coordinates_to_celestial(fitsx,fitsy : double; out ram,decm  : double) {fitsX, Y to ra,dec};
var
  fits_unsampledX, fits_unsampledY :double;
  u,v,u2,v2             : double;
  dRa,dDec,delta,gamma  : double;

begin
  RAM:=0;DECM:=0;{for case wrong index or cd1_1=0}

  if cd1_1<>0 then
  begin //wcs
    if a_order>=2 then {SIP, Simple Imaging Polynomial}
    begin //apply SIP correction to pixels.
      u:=fitsx-crpix1;
      v:=fitsy-crpix2;
      u2:=u + a_0_0+ a_0_1*v + a_0_2*v*v + a_0_3*v*v*v + a_1_0*u + a_1_1*u*v + a_1_2*u*v*v + a_2_0*u*u + a_2_1*u*u*v + a_3_0*u*u*u ; {SIP correction for second or third order}
      v2:=v + b_0_0+ b_0_1*v + b_0_2*v*v + b_0_3*v*v*v + b_1_0*u + b_1_1*u*v + b_1_2*u*v*v + b_2_0*u*u + b_2_1*u*u*v + b_3_0*u*u*u ; {SIP correction for second or third order}
    end
    else
    begin
      u2:=fitsx-crpix1;
      v2:=fitsy-crpix2;
    end; {mainwindow.Polynomial1.itemindex=0}


    dRa :=(cd1_1*(u2)+cd1_2*(v2))*pi/180;
    dDec:=(cd2_1*(u2)+cd2_2*(v2))*pi/180;
    delta:=cos(dec0)-dDec*sin(dec0);
    gamma:=sqrt(dRa*dRa+delta*delta);
    decm:=arctan((sin(dec0)+dDec*cos(dec0))/gamma);
    ram:=ra0+arctan2(Dra,delta); {atan2 is required for images containing celestial pole}
    if ram<0 then ram:=ram+2*pi;
    if ram>pi*2 then ram:=ram-pi*2;
  end; //WCS
end;



procedure analyse_image(img : Timage_array;snr_min:double;report_type:integer;out star_counter : integer;out backgr, hfd_median : double); {find background, number of stars, median HFD}
var
   width2,height2,fitsX,fitsY,diam,i,j,retries,m,n,xci,yci,sqr_diam,starpixels : integer;
   hfd1,star_fwhm,snr,flux,xc,yc,detection_level,ra,decl,noise_lev              : double;
   hfd_list                                                                    : array of double;
   img_sa                                                                      : Timage_array;
var
  f   :  textfile;
const
   len: integer=1000;
begin
  //report_type=0, report hfd_median
  //report_type=1, report hfd_median and write csv file
  //report_type=2, write csv file

  width2 := Length(img[0,0]); {width}
  height2 := Length(img[0]);  {height}

  SetLength(hfd_list,len);{set array length to len}

  get_background(0,img,true,true {calculate background and also star level end noise level},{var}backgr,star_level,star_level2);
  noise_lev:=noise_level[0];
  retries:=3; {try up to four times to get enough stars from the image}

  if ((backgr<60000) and (backgr>8)) then {not an abnormal file}
  begin
    repeat {try three time to find enough stars}
      if retries=3 then
        begin if star_level >30*noise_lev then detection_level:=star_level  else retries:=2;{skip} end;//stars are dominant
      if retries=2 then
        begin if star_level2>30*noise_lev then detection_level:=star_level2 else retries:=1;{skip} end;//stars are dominant
      if retries=1 then
        begin detection_level:=30*noise_lev; end;
      if retries=0 then
        begin detection_level:= 7*noise_lev; end;

      star_counter:=0;

      if report_type>0 then {write values to file}
      begin
        assignfile(f,ChangeFileExt(filename2,'.csv'));
        rewrite(f); {this could be done 3 times due to the repeat but it is the most simple code}
        writeln(f, 'x,y,hfd,snr,flux,ra[0..360],dec[0..360]');
      end;

      setlength(img_sa,1,height2,width2);{set length of image array}
      for fitsY:=0 to height2-1 do
        for fitsX:=0 to width2-1  do
          img_sa[0,fitsY,fitsX]:=0;{mark as star free urveyed area}

      for fitsY:=1 to height2-1-1 do //Search through the image. Stay one pixel away from the borders.
      begin
        for fitsX:=1 to width2-1-1  do
        begin
          if (( img_sa[0,fitsY,fitsX]<=0){star free area} and (img[0,fitsY,fitsX]-backgr>detection_level)) then {new star. For analyse used sigma is 5, so not too low.}
          begin
            starpixels:=0;
            if img[0,fitsY,fitsX-1]- backgr>4*noise_lev then inc(starpixels);//inspect in a cross around it.
            if img[0,fitsY,fitsX+1]- backgr>4*noise_lev then inc(starpixels);
            if img[0,fitsY-1,fitsX]- backgr>4*noise_lev then inc(starpixels);
            if img[0,fitsY+1,fitsX]- backgr>4*noise_lev then inc(starpixels);
            if starpixels>=2 then //At least 3 illuminated pixels. Not a hot pixel
            begin
              HFD(img,fitsX,fitsY,14{box size}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
              if ((hfd1<=30) and (snr>snr_min) and (hfd1>0.8) {two pixels minimum} ) then
              begin
                hfd_list[star_counter]:=hfd1;{store}
                inc(star_counter);
                if star_counter>=len then begin len:=len+1000; SetLength(hfd_list,len);{increase size} end;

                diam:=round(3.0*hfd1);{for marking star area. Emperical a value between 2.5*hfd and 3.5*hfd gives same performance. Note in practise a star PSF has larger wings then predicted by a Gaussian function}
                sqr_diam:=sqr(diam);
                xci:=round(xc);{star center as integer}
                yci:=round(yc);
                for n:=-diam to +diam do {mark the whole circular star area width diameter "diam" as occupied to prevent double detections}
                  for m:=-diam to +diam do
                  begin
                    j:=n+yci;
                    i:=m+xci;
                    if ((j>=0) and (i>=0) and (j<height2) and (i<width2) and ( (sqr(m)+sqr(n))<=sqr_diam)) then
                      img_sa[0,j,i]:=1;
                  end;

                if report_type>0 then
                begin
                  if cd1_1=0 then
                    writeln(f, floattostr4(xc + 1) + ',' + floattostr4(yc + 1) +  ',' + floattostr4(hfd1) + ',' + IntToStr(round(snr)) + ',' + IntToStr(round(flux))) {+1 to convert 0... to FITS 1... coordinates}
                  else
                  begin
                    sensor_coordinates_to_celestial(xc + 1,yc + 1, ra,decl);
                    writeln(f, floattostr4(xc + 1) + ',' + floattostr4(yc + 1) +  ',' + floattostr4(hfd1) + ',' + IntToStr(round(snr)) + ',' + IntToStr(round(flux))+','+floattostr8(ra*180/pi) + ',' + floattostr8(decl*180/pi) ) {+1 to convert 0... to FITS 1... coordinates}
                  end;
                end;//report
              end;
            end;
          end;
        end;
      end;

      dec(retries);{Try again with lower detection level}

      if report_type>0 then closefile(f);

    until ((star_counter>=max_stars) or (retries<0));{reduce detection level till enough stars are found. Note that faint stars have less positional accuracy}

    if ((star_counter > 0) and (report_type<=1)) then hfd_median := SMedian(hfd_List, star_counter) else  hfd_median := 99;
  end {backgr is normal}
  else
  hfd_median:=99;{Most common value image is too low. Ca'+#39+'t process this image. Check camera offset setting.}

  img_sa:=nil;{free mem}
end;


end.

