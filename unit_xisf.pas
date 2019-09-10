unit unit_xisf;
{Basic XISF read routine for uncompressed files. Reads included image for 8,16 32, -32 and -64 bit format}
{The XISF frmat is described by standard reference: http://pixinsight.com/doc/docs/XISF-1.0-spec/XISF-1.0-spec.html}

{Copyright (C) 2019 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

{This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.}

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
  unit_dss {only to reset some variables};

function load_xisf(filen:string;var img_loaded2: image_array) : boolean;{load uncompressed xisf file, add basic FITS header and retrieve included FITS keywords if available}


implementation

function load_xisf(filen:string;var img_loaded2: image_array) : boolean;{load uncompressed xisf file, add basic FITS header and retrieve included FITS keywords if available}
var
   i,j,k, reader_position,a,b,c,d,e : integer;
   scale,exptime,ccd_temperature : double;
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
         result:=copy(aline,b,c-b); {keyword value}
       end;
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

  {Reset variables for case they are not specified in the file}
  Reader := TReader.Create (theFile3,$4000);{number of hnsky records}
  {thefile3.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}
  crota2:=99999;{just for the case it is not available, make it later zero}
  crota1:=99999;
  ra0:=0;
  dec0:=0;
  cdelt1:=0;
  cdelt2:=0;
  xpixsz:=0;
  focallen:=0;
  subsamp:=1;{just for the case it is not available}
  cd1_1:=0;{just for the case it is not available}
  cd1_2:=0;{just for the case it is not available}
  cd2_1:=0;{just for the case it is not available}
  cd2_2:=0;{just for the case it is not available}
  date_obs:=''; ut:=''; pltlabel:=''; plateid:=''; telescop:=''; instrum:='';  origin:=''; object_name:='';{clear}
  naxis:=1;
  naxis3:=1;
  scale:=0;
  a_order:=0;{Simple Imaging Polynomial use by astrometry.net, if 2 then available}
  filter_name:='';
  calstat:='';{indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected, S stacked. Example value DFB}
  imagetype:='';
  xbinning:=1;{normal}
  ybinning:=1;
  exposure:=0;
  exptime:=0;
  ccd_temperature:=999;
  set_temperature:=999;

  x_coeff[0]:=0; {reset DSS_polynomial, use for check if there is data}
  y_coeff[0]:=0;

  a_order:=0; {reset SIP_polynomial, use for check if there is data}


  setlength(header2,16);
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
    width2:=strtoint(message1);
    b:=c+1;                {find begin};
    c:=posex(':',aline,b); {find end};
    message1:=trim(copy(aline,b,c-b)); {remove spaces and crlf}
    height2:=strtoint(message1);
    b:=c+1;                {find begin};
    c:=posex('"',aline,b); {find end};
    message1:=trim(copy(aline,b,c-b)); {remove spaces and crlf}
    naxis3:=strtoint(message1);;
  end;

  for j:=0 to 10 do {create an header with fixed sequence}
    if ((j<>5) or  (naxis3<>1)) then {skip naxis3 for mono images}
        mainwindow.memo1.lines.add(head1[j]); {add lines to empthy memo1}
  mainwindow.memo1.lines.add(head1[27]); {add end}
  if naxis3>1 then
  begin
    naxis:=3; {3 dimensions, one is colours}
    update_integer('NAXIS   =',' / Number of dimensions                           ' ,3);{2 for mono, 3 for color}
  end
  else naxis:=2;{mono}

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
    if message1='Float32' then nrbits:=-32 {sometimes there is an other Uintf8 behind stop _image, so test first only}  else
    if message1='UInt16' then nrbits:=16 else
    if message1='UInt8' then nrbits:=8 else
    if message1='Float64' then nrbits:=-64 else
    if message1='UInt32' then nrbits:=32 else
    error2:=1;
  end;
  if ((a=0) or (error2<>0)) then begin close_fits_file;mainwindow.error_label1.enabled:=true;
     mainwindow.statusbar1.panels[7].text:=('Can not read this format.'); mainwindow.Memo1.visible:=true;  fits_file:=false; exit; end;

  if nrbits=8 then  begin datamin_org:=0;datamax_org:=255; {8 bits files} end
    else {16, -32 files} begin datamin_org:=0;datamax_org:=$FFFF;end;{not always specified. For example in skyview. So refresh here for case brightness is adjusted}

  {update memo keywords}
  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);
  if naxis3=1 then  remove_key('NAXIS3  ');{remove key word in header. Some program don't like naxis3=1}



//  Not required since XISF is not used for stacking}
//    time_obs:=extract_string_keyword('TIME-OBS');
//    time_obs:=extract_string_keyword('DATE-OBS');
//    time_obs:=extract_string_keyword('DATE');
//    filter_name:=extract_string_keyword('FILTER');

  {update memo keywords and variables for floats}
  extract_double_keyword('CD1_1',cd1_1);{extract float value from XML header and add keyword to FITS memo header, ignoring comments.}
  extract_double_keyword('CD1_2',cd1_2);
  extract_double_keyword('CD2_1',cd2_1);
  extract_double_keyword('CD2_2',cd2_2);

//  Not required since XISF is not used for stacking}
//  extract_double_keyword('CCD-TEMP',ccd_temperature);
//  extract_double_keyword('SET-TEMP',ccd_temperature);
//  extract_double_keyword('EXPTIME',exptime);
//  extract_double_keyword('EXPOSURE',exposure);

  extract_double_keyword('CROTA1',crota1);
  extract_double_keyword('CROTA2',crota2);
  extract_double_keyword('CDELT1',cdelt1);
  extract_double_keyword('CDELT2',cdelt2);
  if cdelt1=0 then begin extract_double_keyword('SECPIX1',cdelt1);cdelt1:=cdelt1/3600;end;
  if cdelt2=0 then begin extract_double_keyword('SECPIX2',cdelt2);cdelt2:=cdelt2/3600;end;
  extract_double_keyword('CRVAL1',ra0);
  extract_double_keyword('CRVAL2',dec0);
  if ra0=0 then extract_double_keyword('RA',ra0);
  if dec0=0 then extract_double_keyword('DEC',dec0);

  ra0:=ra0*pi/180; {degrees -> radians}
  dec0:=dec0*pi/180;

  cblack:=datamin_org;{for case histogram is not called}
  cwhite:=datamax_org;


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

  if ( ((cdelt1=0) or (crota2>=999)) and (cd1_1<>0)) then
  begin
    new_to_old_WCS;{ convert old WCS to new}
  end
  else
  if ((crota2<999) and (cd1_1=0) and(cdelt1<>0)) then {valid crota2 value}
  begin
    old_to_new_WCS;{ convert old WCS to new}
  end;

  if exptime>exposure then exposure:=exptime;{both keywords are used}
  if set_temperature=999 then set_temperature:=round(ccd_temperature); {temperature}

  if crota2>999 then crota2:=0;{not defined, set at 0}
  if crota1>999 then crota1:=crota2; {for case crota1 is not used}

  if ra0<>0 then
  begin
    mainwindow.ra1.text:=prepare_ra(ra0,' ');
    mainwindow.dec1.text:=prepare_dec(dec0,' ');
   {$IfDef Darwin}// {MacOS}
    mainwindow.ra1change(nil);{OSX doesn't trigger an event}
    mainwindow.dec1change(nil);
   {$ENDIF}
  end;
  if ((cd1_1=0) and (cdelt2=0)) then  {no scale, try to fix it}
  begin
    if scale<>0 then {sgp file, use scale to find image dimensions}
     cdelt2:=scale/3600 {scale is in arcsec/pixel }
     else
     if ((focallen<>0) and (xpixsz<>0)) then
       cdelt2:=180/(3.141*1000)*xpixsz/focallen; {use maxim DL key word}
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
  if width2>i then
  begin
    sysutils.beep;
     mainwindow.statusbar1.panels[7].text:='Too wide XISF file !!!!!';
    mainwindow.error_label1.visible:=true;
    close_fits_file;
    exit;
  end
  else
  begin {buffer wide enough, read image data block}
    setlength(img_loaded2,naxis3,width2,height2);
    for k:=1 to naxis3 do {do all colors}
    begin
      For i:=0 to height2-1 do
      begin
        try reader.read(fitsbuffer,width2*round(abs(nrbits/8)));except; end; {read file info}

        for j:=0 to width2-1 do
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
            img_loaded2[k-1,j,i]:=fitsbuffer4[j]/65535;{scale to 0..64000 float}
        end;
      end;
    end; {colors naxis3 times}
  end;

  update_menu(true);{file loaded, update menu for fits}
  close_fits_file;
  unsaved_import:=true;{file is not available for astrometry.net}
  result:=true;
  fits_file:=true;{succes}
end;


end.

