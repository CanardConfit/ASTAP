unit unit_xisf;
{Basic XISF read routine for uncompressed files. Reads included image for 8,16 32, -32 and -64 bit format}
{The XISF format is described by standard reference: http://pixinsight.com/doc/docs/XISF-1.0-spec/XISF-1.0-spec.html}

{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

{$mode delphi}

interface

uses
  {$ifdef mswindows}
   Windows,
  {$endif}
  {$ifdef unix}
     math, {for min function}
  {$endif}
  Classes, SysUtils, strutils,
  astap_main,
  unit_dss, {only to reset some variables}
  unit_annotation {only to reset some variables};

function load_xisf(filen:string;var head : theader ; var img_loaded2: image_array) : boolean;{load uncompressed xisf file, add basic FITS header and retrieve included FITS keywords if available}


implementation


function load_xisf(filen:string;var head : theader; var img_loaded2: image_array) : boolean;{load uncompressed xisf file, add basic FITS header and retrieve included FITS keywords if available}
var
   i,j,k, reader_position,a,b,c,d,e : integer;
   aline,message1,message_key,message_value,message_comment    : ansistring;
   attachment,start_image  : integer;
   error2                  : integer;
   header_length           : longword;
   header2                 :     array of ansichar;
     procedure close_fits_file; inline;
     begin
        Reader.free;
        TheFile3.free;
        result:=false;
     end;

     function extract_string_keyword(keyword:string):string;{extract string value from XML header}
     begin {I don't like xml, apply simple & primitive method}
       b:=pos(keyword+'" value="',aline); {find begin}
       if b>0 then {found}
       begin
         inc(b,length(keyword)+length('" value="'));
         c:=posex('"',aline,b); {find end, ignore comment};
         while aline[b]=#39 do inc(b);{remove any apostrophe}
         while aline[c-1]=#39 do dec(c);{remove any apostrophe}
         result:=copy(aline,b,c-b); {keyword value}
       end
       else result:='';
     end;

     procedure extract_double_keyword(keyword:string; var value: double);{extract float from XML header}
     var
       keyvalue: string;
     begin {I don't like xml, apply simple & primitive method}
       b:=pos(keyword+'" value="',aline); {find begin}
       if b>0 then {found}
       begin
         inc(b,length(keyword)+length('" value="'));
         c:=posex('"',aline,b); {find end, ignore comment};
         keyvalue:=copy(aline,b,c-b);
         val(keyvalue,value,error2); {try to decode number if any}
       end;
     end;

begin
  result:=false;{assume failure}
  mainwindow.caption:=ExtractFileName(filen);

  {add header data to memo}
  mainwindow.memo1.visible:=false;{stop visualising memo1 for speed. Will be activated in plot routine}
  mainwindow.memo1.clear;{clear memo for new header}

  try
    TheFile3:=tfilestream.Create( filen, fmOpenRead );
  except
    sysutils.beep;
    mainwindow.statusbar1.panels[5].text:=('Error loading file!');
    mainwindow.error_label1.visible:=true;
    exit;
  end;
  mainwindow.error_label1.visible:=false;

  reset_fits_global_variables(true{light},head);  {Reset variables for case they are not specified in the file}

//  ccd_temperature:=999;
  extend_type:=0;  {no extensions in the file, 1 is image, 2 is ascii_table, 3 bintable}

  setlength(header2,16);
  Reader := TReader.Create (theFile3,$4000);{number of hnsky records}
  {thefile3.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}

  reader_position:=0;
  try
    reader.read(header2[0],16);{read XISF signature}
  except;
    close_fits_file;
    mainwindow.error_label1.caption:='Error';
    mainwindow.statusbar1.panels[5].text:='Error';
    mainwindow.error_label1.visible:=true;
    fits_file:=false;
    exit;
  end;
  mainwindow.error_label1.visible:=false;
  inc(reader_position,16);
  if ((header2[0]='X') and (header2[1]='I')  and (header2[2]='S') and (header2[3]='F') and (header2[4]='0') and (header2[5]='1') and (header2[6]='0') and (header2[7]='0'))=false then
        begin close_fits_file;mainwindow.error_label1.visible:=true; mainwindow.statusbar1.panels[5].text:=('Error loading XISF file!! Keyword XSIF100 not found.');fits_file:=false; exit; end;
  header_length:=ord(header2[8])+(ord(header2[9]) shl 8) + (ord(header2[10]) shl 16)+(ord(header2[11]) shl 24); {signature length}

  setlength(header2,header_length);{could be very large}
  reader.read(header2[0],header_length);{read XISF header}
  inc(reader_position,header_length);

  {some sample image defintions from the XISF header}
  //<Image geometry="185:272:3" sampleFormat="UInt8" colorSpace="RGB" location="attachment:4096:150960"><Resolution horizontal="1" vertical="1"
  //<Image id="integration" geometry="4656:3520:1" sampleFormat="Float32" bounds="0:1" colorSpace="Gray" location="attachment:16384:65556480">
  //<Image geometry="228:199:1" sampleFormat="UInt8" colorSpace="Gray" location="attachment:4096:45372"><Resolution horizontal="72" vertical="72" unit="inch"/>
  //<Image geometry="185:272:3" sampleFormat="UInt8" colorSpace="RGB" location="attachment:4096:150960"><Resolution horizontal="1" vertical="1"
  //<Image geometry="2328:1760:1" sampleFormat="UInt32" colorSpace="Gray" location="attachment:4096:16389120"><Resolution horizontal="72" vertical="72" unit="inch"/>


  SetString(aline, Pansichar(@header2[0]),header_length);{convert header to string starting <Image}
  start_image:=pos('<Image ',aline);{find range <image..../image>}

  if posex('compression=',aline,start_image)>0 then begin close_fits_file;mainwindow.error_label1.caption:='Error, can not read compressed XISF files!!'; mainwindow.error_label1.visible:=true; fits_file:=false; exit; end;

  a:=posex('geometry=',aline,start_image);
  if a>0 then
  begin
    b:=posex('"',aline,a);inc(b,1); {find begin};
    c:=posex(':',aline,b); {find end};
    message1:=trim(copy(aline,b,c-b)); {remove spaces and crlf}
    head.width:=strtoint(message1);
    b:=c+1;                {find begin};
    c:=posex(':',aline,b); {find end};
    message1:=trim(copy(aline,b,c-b)); {remove spaces and crlf}
    head.height:=strtoint(message1);
    b:=c+1;                {find begin};
    c:=posex('"',aline,b); {find end};
    message1:=trim(copy(aline,b,c-b)); {remove spaces and crlf}
    head.naxis3:=strtoint(message1);;
  end;

  for j:=0 to 10 do {create an header with fixed sequence}
    if ((j<>5) or  (head.naxis3<>1)) then {skip head.naxis3 for mono images}
        mainwindow.memo1.lines.add(head1[j]); {add lines to empthy memo1}
  mainwindow.memo1.lines.add(head1[27]); {add end}
  if head.naxis3>1 then
  begin
    head.naxis:=3; {3 dimensions, one is colours}
    update_integer('NAXIS   =',' / Number of dimensions                           ' ,3);{2 for mono, 3 for color}
  end
  else head.naxis:=2;{mono}

  a:=posex('location="attachment',aline,start_image);{find begin included data block}
  if a>0 then
  begin
    b:=posex(':',aline,a);inc(b,1); {find begin};
    c:=posex(':',aline,b); {find end};
    message1:=trim(copy(aline,b,c-b)); {remove spaces and crlf}
    val(message1,attachment,error2);{get data block}
  end;
  if ((a=0) or (error2<>0)) then begin close_fits_file; mainwindow.error_label1.caption:='Error'; mainwindow.error_label1.visible:=true;
     mainwindow.statusbar1.panels[7].text:='Can not read this format, no attachment'; fits_file:=false; exit; end;

  a:=posex('sampleFormat=',aline,start_image);
  if a>0 then
  begin
    error2:=0;
    b:=posex('"',aline,a);inc(b,1); {find begin};
    c:=posex('"',aline,b); {find end};
    message1:=trim(copy(aline,b,c-b)); {remove spaces and crlf}
    if message1='Float32' then nrbits:=-32 {sometimes there is another Uintf8 behind stop _image, so test first only}  else
    if message1='UInt16' then nrbits:=16 else
    if message1='UInt8' then nrbits:=8 else
    if message1='Float64' then nrbits:=-64 else
    if message1='UInt32' then nrbits:=32 else
    error2:=1;
  end;
  if ((a=0) or (error2<>0)) then begin close_fits_file;mainwindow.error_label1.enabled:=true;
     mainwindow.statusbar1.panels[7].text:=('Can not read this format.'); mainwindow.Memo1.visible:=true;  fits_file:=false; exit; end;

  if nrbits=8 then  begin head.datamin_org:=0;head.datamax_org:=255; {8 bits files} end
    else {16, -32 files} begin head.datamin_org:=0;head.datamax_org:=$FFFF;end;{not always specified. For example in skyview. So refresh here for case brightness is adjusted}

  {update memo keywords}
  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);
  if head.naxis3=1 then  remove_key('NAXIS3  ',false{all});{remove key word in header. Some program don't like naxis3=1}



  head.date_obs:=extract_string_keyword('DATE-OBS');
  if head.date_obs='' then head.date_obs:=extract_string_keyword('DATE');

  head.filter_name:=extract_string_keyword('FILTER');
  bayerpat:=extract_string_keyword('BAYERPAT');

  sitelong:=extract_string_keyword('SITELONG');
  if sitelong='' then
    sitelong:=extract_string_keyword('LONG-OBS');

  sitelat:=extract_string_keyword('SITELAT');
  if sitelat='' then
    sitelat:=extract_string_keyword('LAT-OBS');



  extract_double_keyword('XBAYROFF',Xbayroff);;{offset to used to correct BAYERPAT due to flipping}
  extract_double_keyword('YBAYROFF',Ybayroff);;{offset to used to correct BAYERPAT due to flipping}
  roworder:=extract_string_keyword('ROWORDER');

  {update memo keywords and variables for floats}
  extract_double_keyword('CD1_1',head.cd1_1);{extract float value from XML header and add keyword to FITS memo header, ignoring comments.}
  extract_double_keyword('CD1_2',head.cd1_2);
  extract_double_keyword('CD2_1',head.cd2_1);
  extract_double_keyword('CD2_2',head.cd2_2);

//  Not required since XISF is not used for stacking}
//  extract_double_keyword('CCD-TEMP',ccd_temperature);
//  extract_double_keyword('SET-TEMP',ccd_temperature);
//  extract_double_keyword('EXPTIME ',head.exposure);
//  extract_double_keyword('EXPOSURE',head.exposure);

  extract_double_keyword('CROTA1',head.crota1);
  extract_double_keyword('CROTA2',head.crota2);
  extract_double_keyword('CDELT1',head.cdelt1);
  extract_double_keyword('CDELT2',head.cdelt2);

  extract_double_keyword('FOCALLEN',focallen);
  extract_double_keyword('XPIXSZ',xpixsz);

  if head.cd1_1=0  then {try to retrieve pixel scale head.cdelt2. Else will be calculated in new_to_old_WCS procedure from the CD matrix}
  begin
    if ((focallen<>0) and (xpixsz<>0)) then head.cdelt2:=180/(pi*1000)*xpixsz/focallen; {use maxim DL key word}

    if head.cdelt2=0 then begin extract_double_keyword('SCALE',head.cdelt2); head.cdelt2:=head.cdelt2/3600 {scale is in arcsec/pixel }  end;{use sgp file keyword}

    if head.cdelt2=0 then begin extract_double_keyword('SECPIX1',head.cdelt1);head.cdelt1:=head.cdelt1/3600;end;
    if head.cdelt2=0 then begin extract_double_keyword('SECPIX2',head.cdelt2);head.cdelt2:=head.cdelt2/3600; end;
  end;

  extract_double_keyword('CRVAL1',head.ra0);
  extract_double_keyword('CRVAL2',head.dec0);
  extract_double_keyword('RA',ra_mount);
  extract_double_keyword('DEC',dec_mount);
  if ra_mount<999 then
  begin
    if head.ra0=0 then head.ra0:=ra_mount;
    if head.dec0=0 then head.dec0:=dec_mount;
  end;

  head.ra0:=head.ra0*pi/180; {degrees -> radians}
  head.dec0:=head.dec0*pi/180;

  cblack:=head.datamin_org;{for case histogram is not called}
  cwhite:=head.datamax_org;


  //Samples of keywords stored in header:
  //<FITSKeyword name="NAXIS2" value="1760" comment="length of data axis 2"/>
  //<FITSKeyword name="OBJECT" value="'M16'" comment="Observed object name"/>
  //<FITSKeyword name="CCD-TEMP" value="-15.1" comment="CCD temperature (Celsius)"/>
  //<FITSKeyword name="HISTORY" value="" comment="For more details, see http://astrometry.net ."/>
  //<FITSKeyword name="COMMENT" value="" comment="-- blind solver parameters: --"/>

  {Extract all other FITS keywords and add to memo1 as header}
  d:=start_image;
  repeat
    a:=posex('<FITSKeyword name=',aline,d);
    if a>0 then
    begin
      e:=posex('/>',aline,a+1); {find end of <FITSKeyword};

      b:=posex('"',aline,a+1);inc(b,1); {find begin};
      c:=posex('"',aline,b); {find end};
      message_key:=trim(copy(aline,b,c-b)); {remove spaces and crlf}
      a:=posex('value=',aline,c);
      if ((a>0) and (a<=e)) then {within range FITSKeyword}
      begin
        error2:=0;
        b:=posex('"',aline,a+1);inc(b,+1); {find begin};
        c:=posex('"',aline,b); {find end};
        message_value:=trim(copy(aline,b,c-b)); {remove spaces and crlf}
      end;
      a:=posex('comment=',aline,c);
      if ((a>0) and (a<=e)) then {within range FITSKeyword}
      begin
        error2:=0;
        b:=posex('"',aline,a);inc(b,1); {find begin};
        c:=posex('"',aline,b); {find end};
        message_comment:=trim(copy(aline,b,c-b)); {remove spaces and crlf}
      end;
      {if message_key<>'HISTORY' then}
      update_generic(message_key,message_value,message_comment);{update header using text only}
      d:=c;
    end;
  until a=0;{repeat until all FIT keywords are recovered}

  {add own history}
  add_text   ('HISTORY ','Imported from XISF file by the ASTAP program');{update memo}

  if ( ((head.cdelt1=0) or (head.crota2>=999)) and (head.cd1_1<>0)) then
  begin
    new_to_old_WCS;{ convert old WCS to new}
  end
  else
  if ((head.crota2<999) and (head.cd1_1=0) and(head.cdelt1<>0)) then {valid head.crota2 value}
  begin
    old_to_new_WCS;{ convert old WCS to new}
  end;

// not required since xisf are not used for stacking
//  if head.set_temperature=999 then head.set_temperature:=round(ccd_temperature); {temperature}

  if head.crota2>999 then head.crota2:=0;{not defined, set at 0}
  if head.crota1>999 then head.crota1:=head.crota2; {for case head.crota1 is not used}

  if head.ra0<>0 then
  begin
    mainwindow.ra1.text:=prepare_ra(head.ra0,' ');
    mainwindow.dec1.text:=prepare_dec(head.dec0,' ');
   {$IfDef Darwin}// {MacOS}
    //mainwindow.ra1change(nil);{OSX doesn't trigger an event}
    //mainwindow.dec1change(nil);
   {$ENDIF}
  end;

 {read rest of header containing zero's}
  if attachment-reader_position>0 then {header contains zero's}
  repeat
    i:=min(attachment-reader_position,length(header2));
    try reader.read(header2[0],i);except;close_fits_file; exit;end; {skip empty part and go to image data}
    inc(reader_position,i);
  until reader_position>=attachment;

  header2:=nil;{free memory}

  mainwindow.memo1.visible:=true;{start updating}


  {check if buffer is wide enough for one image line}
  i:=round(bufwide/(abs(nrbits/8)));
  if head.width>i then
  begin
    sysutils.beep;
     mainwindow.statusbar1.panels[7].text:='Too wide XISF file !!!!!';
    mainwindow.error_label1.visible:=true;
    close_fits_file;
    exit;
  end
  else
  begin {buffer wide enough, read image data block}
    setlength(img_loaded2,head.naxis3,head.width,head.height);
    for k:=1 to head.naxis3 do {do all colors}
    begin
      For i:=0 to head.height-1 do
      begin
        try reader.read(fitsbuffer,head.width*round(abs(nrbits/8)));except; end; {read file info}

        for j:=0 to head.width-1 do
        begin
          if nrbits=16 then {16 bit FITS}
           img_loaded2[k-1,j,i]:=fitsbuffer2[j]
          else
          if nrbits=-32 then {4 byte floating point  FITS image}
            img_loaded2[k-1,j,i]:=65535*fitsbufferSINGLE[j]{store in memory array, scale from 0..1 to 0..65535}
          else
          if nrbits=8  then
            img_loaded2[k-1,j,i]:=(fitsbuffer[j])
          else
          if nrbits=-64 then {8 byte, floating point bit FITS image}
            img_loaded2[k-1,j,i]:=65535*fitsbufferDouble[j]{store in memory array, scale from 0..1 to 0..65535}
          else
          if nrbits=+32 then {4 byte, +32 bit FITS image}
            img_loaded2[k-1,j,i]:=fitsbuffer4[j]/65535;{scale to 0..64535 float}
        end;
      end;
    end; {colors head.naxis3 times}
  end;
  close_fits_file;
  unsaved_import:=true;{file is not available for astrometry.net}
  result:=true;
end;


end.

