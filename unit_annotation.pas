unit unit_annotation; {deep sky and star annotation & photometry calibation of the image}
{$mode delphi}
{Copyright (C) 2018, 2019 by Han Kleijn, www.hnsky.org
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
along with this program.  If not, see <http://www.gnu.org/licenses/>.
}


interface
uses
   forms,Classes, SysUtils,strutils, math,graphics, Controls {for tcursor};

procedure plot_deepsky;{plot the deep sky object on the image}
procedure load_deep;{load the deepsky database once. If loaded no action}
procedure load_hyperleda;{load the HyperLeda database once. If loaded no action}
procedure load_variable;{load variable stars. If loaded no action}
procedure plot_stars(photometry_only,show_distortion: boolean);{plot stars on the image}
procedure plot_stars_used_for_solving(correctionX,correctionY: double); {plot image stars and database stars used for the solution}
procedure read_deepsky(searchmode:char; telescope_ra,telescope_dec, cos_telescope_dec {cos(telescope_dec},fov : double; var ra2,dec2,length2,width2,pa : double);{deepsky database search}


var
  deepstring       : Tstrings;
  linepos          : integer;
  naam2,naam3,naam4: string;

const
  flux_magn_offset       : double=0;{offset between star magnitude and flux. Will be calculated in stars are annotated}
  counter_flux_measured  : integer=0;{how many stars used for flux calibration}

implementation

uses
  astap_main, unit_290, unit_stack, unit_star_align;

procedure load_deep;{load the deepsky database once. If loaded no action}
begin
  if ((deepstring.count<10000) or (deepstring.count>=50000)) {empthy or variable or hyperleda loaded} then {load deepsky database}
  begin
    with deepstring do
    begin
       try
       LoadFromFile(database_path+'deep_sky.csv');{load deep sky data from file }
       except;
         clear;
         beep;
         application.messagebox(pchar('Deep sky database not found. Download and unpack in program directory'),'',0);
       end;
    end;
  end;
end;

procedure load_variable;{load the variable star database once. If loaded no action}
begin
  if ((deepstring.count<10) or (deepstring.count>=10000)) {empthy or hyperleda or deepsky loaded} then {load variable star database}
  begin
    with deepstring do
    begin
       try
       LoadFromFile(database_path+'variable_stars.csv');{load deep sky data from file }
       except;
         clear;
         beep;
         application.messagebox(pchar('Variable star database not found!'),'',0);
       end;
    end;
  end;
end;

procedure load_hyperleda;{load the HyperLeda database once. If loaded no action}
begin
  if deepstring.count<50000 then {too small for HyperLeda. Empthy or normal database loaded}
  begin
    with deepstring do
    begin
       try
       LoadFromFile(database_path+'hyperleda.csv');{load deep sky data from file }
       except;
         clear;
         beep;
         application.messagebox(pchar('HyperLeda database not found. Download and unpack in program directory'),'',0);
       end;
    end;
  end;
end;

//http://fastcode.sourceforge.net/
//function ValLong_JOH_PAS_4_c(Value: Integer): string;
function Valint32(const s; var code: Integer): Longint;{fast val function, about 4 x faster}
var
  Digit: Integer;
  Neg, Hex, Valid: Boolean;
  P: PChar;
begin
  Code := 0;
  P := Pointer(S);
  if not Assigned(P) then
    begin
      Result := 0;
      inc(Code);
      Exit;
    end;
  Neg   := False;
  Hex   := False;
  Valid := False;
  while P^ = ' ' do
    Inc(P);
  if P^ in ['+', '-'] then
    begin
      Neg := (P^ = '-');
      inc(P);
    end;
  if P^ = '$' then
    begin
      inc(P);
      Hex := True;
    end
  else
    begin
      if P^ = '0' then
        begin
          inc(P);
          Valid := True;
        end;
      if Upcase(P^) = 'X' then
        begin
          Hex := True;
          inc(P);
        end;
    end;
  Result := 0;
  if Hex then
    begin
      Valid := False;
      while True do
        begin
          case P^ of
            '0'..'9': Digit := Ord(P^) - Ord('0');
            'a'..'f': Digit := Ord(P^) - Ord('a') + 10;
            'A'..'F': Digit := Ord(P^) - Ord('A') + 10;
            else      Break;
          end;
          if (Result < 0) or (Result > $0FFFFFFF) then
            Break;
          Result := (Result shl 4) + Digit;
          Valid := True;
          inc(P);
        end;
    end
  else
    begin
      while True do
        begin
          if not (P^ in ['0'..'9']) then
            break;
          if Result > (MaxInt div 10) then
            break;
          Result := (Result * 10) + Ord(P^) - Ord('0');
          Valid := True;
          inc(P);
        end;
      if Result < 0 then {Possible Overflow}
        if (Cardinal(Result) <> $80000000) or (not neg) then
          begin {Min(LongInt) = $80000000 is a Valid Result}
            Dec(P);
            Valid := False;
          end;
    end;
  if Neg then
    Result := -Result;
  if (not Valid) or (P^ <> #0) then
    Code := P-@S+1;
end;

procedure read_deepsky(searchmode:char; telescope_ra,telescope_dec, cos_telescope_dec {cos(telescope_dec},fov : double; var ra2,dec2,length2,width2,pa : double);{deepsky database search}
var
  x,z,y      : integer;
  fout,fout2, backsl1, backsl2,length_regel : integer;
  regel, data1     :  string;
  delta_ra : double;
  p2,p1: pchar;
begin
  repeat {until fout is 0}

    if linepos>=deepstring.count then
      begin
        linepos:=$FFFFFF;{mark as finished}
        exit;
      end;
    regel:=deepstring.strings[linepos]; {using regel,is faster then deepstring.strings[linepos]}
    inc(linepos);
    x:=1; z:=0; y:=0;

    P1 := Pointer(REGEL);
    length_regel:=length(regel);

    repeat
      {fast replacement for y:=posEx(',',regel,y+1); if y=0 then} {last field?}  {y:=length(regel)+1;}   {new fast routine nov 2015, use posEx rather then pos in Delphi}
      while ((y<length_regel) and (p1^<>',')) do
             begin inc(y); inc(p1,1) end;
      inc(y); inc(p1,1);

      {fast replacement for data1:=copy(regel,x,y-x);}
      SetLength(data1, y-x);
      if y<>x then {not empthy 2018}
      begin
        P2 := Pointer(regel);
        inc(P2, X-1);
        move(P2^,data1[1], y-x);

        while ((length(data1)>1) and (data1[length(data1)]=' ')) do {remove spaces in the end since VAL( can't cope with them}
                                      delete(data1,length(data1),1);
      end;{not empthy}
      x:=y;
      inc(z); {new data field}

      case z of 1:
                     ra2:=valint32(data1,fout)*pi*2/864000;{10*60*60*24, so RA 00:00 00.1=1}
                          {valint32 takes 1 ms instead of 4ms}

                2: begin
                     dec2:=valint32(data1,fout)*pi*0.5/324000;{60*60*90, so DEC 00:00 01=1}
                     delta_ra:=abs(ra2-telescope_ra); if delta_ra>pi then delta_ra:=pi*2-delta_ra;

                     if ((searchmode<>'T') and                                                        {if searchmode is 'T' then full database search else within FOV}
                         ( sqr( delta_ra*cos_telescope_dec)  + sqr(dec2-telescope_dec)> sqr(fov)  ) ) {calculate angular distance and skip when outside FOV}
                           then  fout:=99; {if true then outside screen,go to next line}

                   end;
                3: begin
                     naam2:='';{for case data1='';}
                     naam3:='';
                     naam4:='';
                     while (data1[1]=' ') do delete(data1,1,1); {remove spaces in front of the name, in practice faster then trimleft}
                     backsl1:=pos('/',data1);
                     if backsl1=0 then naam2:=data1
                     else
                     begin
                       naam2:=copy(data1,1,backsl1-1);
                       backsl2:=posEX('/',data1,backsl1+2);     { could also use LastDelimiter}
                       if backsl2=0 then naam3:=copy(data1,backsl1+1,length(data1)-backsl1+1)
                       else
                       begin
                         naam3:=copy(data1,backsl1+1,backsl2-backsl1-1);
                         naam4:=copy(data1,backsl2+1,length(data1)-backsl2+1);
                       end;
                     end;
                   end;
                4: begin
                      val(data1,length2,fout2);{accept floating points}
                   end;{go to next object}
                5: begin
                     val(data1,width2,fout2);{accept floating points}
                   end;
                6: begin val(data1,pa,fout2);{accept floating points}
                         if fout2<>0 then pa:=999;end;
                         {orientation 0 komt ook voor daarom if not know=empthy equals 999}
       end;
       inc(x);
    until ((z>=6) or (fout<>0));
  until fout=0;  {repeat until no errors }
end;


procedure plot_glx(dc:tcanvas;x9,y9,diameter,neigung {ratio width/length},orientation:double); {draw oval or galaxy}
var   glx :array[0..127 {nr}+1] of tpoint;
      i,nr                    : integer;
      r, sin_ori,cos_ori      : double;
begin
   if diameter<10 then nr:=22
   else
     if diameter<20 then nr:=44
   else
     nr:=127;

  if abs(neigung)<0.00001 then neigung:=0.00001;{show ring always also when it is flat}
   for i:=0 to nr+1 do
   begin
     r:=sqrt(sqr(diameter*neigung)/(1.00000000000001-(1-sqr(neigung))*sqr(cos(-pi*i*2/(nr))))); {radius ellips}
     sincos(orientation + pi*i*2/nr, sin_ori, cos_ori);
     glx[i].x:=round(x9    +r * sin_ori );
     glx[i].y:=round(y9    +r * cos_ori );
   end;
   dc.polygon(glx,nr+1)
    //else dc.polyline(glx,nr+1);
end;

procedure rotate(rot,x,y :double;var  x2,y2:double);{rotate a vector point, angle seen from y-axis, counter clockwise}
var
  sin_rot, cos_rot :double;
begin
  sincos(rot, sin_rot, cos_rot);
  x2:=x * + sin_rot + y*cos_rot;{ROTATION MOON AROUND CENTER OF PLANET}
  y2:=x * - cos_rot + y*sin_rot;{SEE PRISMA WIS VADEMECUM BLZ 68}
end;


{ transformation of equatorial coordinates into CCD pixel coordinates for optical projection, rigid method}
{ ra0,dec0: right ascension and declination of the optical axis}
{ ra,dec:   right ascension and declination}
{ xx,yy :   CCD coordinates}
{ cdelt:    CCD scale in arcsec per pixel}
procedure equatorial_standard(ra0,dec0,ra,dec, cdelt : double; var xx,yy: double);
var dv,sin_dec0,cos_dec0,sin_dec ,cos_dec,sin_deltaRA,cos_deltaRA: double;
begin
  sincos(dec0  ,sin_dec0 ,cos_dec0);
  sincos(dec   ,sin_dec  ,cos_dec );
  sincos(ra-ra0, sin_deltaRA,cos_deltaRA);
  dv  := (cos_dec0 * cos_dec * cos_deltaRA + sin_dec0 * sin_dec) / (3600*180/pi)*cdelt; {/ (3600*180/pi)*cdelt, factor for onversion standard coordinates to CCD pixels}
  xx := - cos_dec *sin_deltaRA / dv;{tangent of the angle in RA}
  yy := -(sin_dec0 * cos_dec * cos_deltaRA - cos_dec0 * sin_dec) / dv;  {tangent of the angle in DEC}
end;


procedure plot_deepsky;{plot the deep sky object on the image}
type
  textarea = record
     x1,y1,x2,y2 : integer;
  end;
var
  fitsX,fitsY,dra,ddec,delta,gamma, telescope_ra,telescope_dec,cos_telescope_dec,fov,ra2,dec2,length1,width1,pa,len,flipped,
  gx_orientation, delta_ra,det,SIN_dec_ref,COS_dec_ref,SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,hh : double;
  name: string;
  flip_horizontal, flip_vertical: boolean;
  text_dimensions  : array of textarea;
  i,text_counter,th,tw,x1,y1,x2,y2,hf,x,y : integer;
  overlap  :boolean;
  Save_Cursor:TCursor;

begin
  if ((fits_file) and (cd1_1<>0)) then
  begin
     Save_Cursor := Screen.Cursor;
     Screen.Cursor := crHourglass;    { Show hourglass cursor }

    flip_vertical:=mainwindow.Flipvertical1.Checked;
    flip_horizontal:=mainwindow.Fliphorizontal1.Checked;

    {6. Passage (x,y) -> (RA,DEC) to find RA0,DEC0 for middle of the image. See http://alain.klotz.free.fr/audela/libtt/astm1-fr.htm}
    dRa :=(cd1_1*((width2/2)-crpix1)+cd1_2*((height2/2)-crpix2))*pi/180; {also valid for case crpix1,crpix2 is not in the middle}
    dDec:=(cd2_1*((width2/2)-crpix1)+cd2_2*((height2/2)-crpix2))*pi/180;
    delta:=cos(dec0)-dDec*sin(dec0);
    gamma:=sqrt(dRa*dRa+delta*delta);
    telescope_ra:=ra0+arctan(Dra/delta);
    telescope_dec:=arctan((sin(dec0)+dDec*cos(dec0))/gamma);

    cos_telescope_dec:=cos(telescope_dec);
    fov:=1.5*sqrt(sqr(0.5*width2*cdelt1)+sqr(0.5*height2*cdelt2))*pi/180; {field of view with 50% extra}
    linepos:=2;{Set pointer to the beginning. First two lines are comments}
    if cdelt1*cdelt2>0 then flipped:=-1 {n-s or e-w flipped} else flipped:=1;

    mainwindow.image1.canvas.pen.color:=clyellow;
    if  ((deepstring.count>10000) and (deepstring.count<50000)) then {deepsky.csv}
    begin {default deep sky database 30.000 objects}
       hf:=max(mainwindow.panel1.height,mainwindow.image1.height);
       mainwindow.image1.Canvas.font.size:=max(8,round(14*height2/hf));{adapt font to image dimensions}
       mainwindow.image1.Canvas.Pen.width :=max(1,round(height2/hf));{thickness lines}
    end
    else
    begin{for HyperLeda, variables}
      mainwindow.image1.Canvas.font.size:=8;
      mainwindow.image1.Canvas.Pen.width :=1;
    end;

    mainwindow.image1.Canvas.brush.Style:=bsClear;
    mainwindow.image1.Canvas.font.color:=clyellow;

    text_counter:=0;
    setlength(text_dimensions,200);

    sincos(dec0,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}

    repeat
      read_deepsky('S',telescope_ra,telescope_dec, cos_telescope_dec {cos(telescope_dec},fov,{var} ra2,dec2,length1,width1,pa);{deepsky database search}

      {5. Conversion (RA,DEC) -> (x,y). See http://alain.klotz.free.fr/audela/libtt/astm1-fr.htm}
      sincos(dec2,SIN_dec_new,COS_dec_new);{sincos is faster then seperate sin and cos functions}
      delta_ra:=ra2-ra0;
      sincos(delta_ra,SIN_delta_ra,COS_delta_ra);
      HH := SIN_dec_new*sin_dec_ref + COS_dec_new*COS_dec_ref*COS_delta_ra;
      dRA := (COS_dec_new*SIN_delta_ra / HH)*180/pi;
      dDEC:= ((SIN_dec_new*COS_dec_ref - COS_dec_new*SIN_dec_ref*COS_delta_ra ) / HH)*180/pi;
      det:=CD2_2*CD1_1 - CD1_2*CD2_1;
      fitsX:= +crpix1 - (CD1_2*dDEC - CD2_2*dRA) / det;{1..width2}
      fitsY:= +crpix2 + (CD1_1*dDEC - CD2_1*dRA) / det;{1..height2}
      x:=round(fitsX-1);{0..width2-1}
      y:=round(fitsY-1);{0..height2-1}


      if ((x>-0.25*width2) and (x<=1.25*width2) and (y>-0.25*height2) and (y<=1.25*height2)) then {within image1 with some overlap}
      begin
        gx_orientation:=pa*flipped+crota2;
        if flip_horizontal then begin x:=(width2-1)-x; gx_orientation:=-gx_orientation; end;
        if flip_vertical then gx_orientation:=-gx_orientation else y:=(height2-1)-y;

        {Plot deepsky text labels on an empthy text space.}
        { 1) If the center of the deepsky object is outside the image then don't plot text}
        { 2) If the text space is occupied, then move the text down. If the text crosses the bottom then use the original text position.}
        { 3) If the text crosses the right side of the image then move the text to the left.}
        { 4) If the text is moved in y then connect the text to the deepsky object with a vertical line.}
        if ( (x>=0) and (x<=width2-1) and (y>=0) and (y<=height2-1) ) then {plot only text if center object is visible}
        begin
          if naam3='' then name:=naam2
          else
          if naam4='' then name:=naam2+'/'+naam3
          else
          name:=naam2+'/'+naam3+'/'+naam4;

          {get text dimensions}
          th:=mainwindow.image1.Canvas.textheight(name);
          tw:=mainwindow.image1.Canvas.textwidth(name);
          x1:=x;
          y1:=y;
          x2:=x+ tw;
          y2:=y+ th ;

          if ((x1<=width2) and (x2>width2)) then begin x1:=x1-(x2-width2);x2:=width2;end; {if text is beyond right side, move left}

          if text_counter>0 then {find free space in y for text}
          begin
            repeat {find free text area}
              overlap:=false;
              i:=0;
              repeat {test overlap}
                if ( ((x1>=text_dimensions[i].x1) and (x1<=text_dimensions[i].x2) and (y1>=text_dimensions[i].y1) and (y1<=text_dimensions[i].y2)) {left top overlap} or
                     ((x2>=text_dimensions[i].x1) and (x2<=text_dimensions[i].x2) and (y1>=text_dimensions[i].y1) and (y1<=text_dimensions[i].y2)) {right top overlap} or
                     ((x1>=text_dimensions[i].x1) and (x1<=text_dimensions[i].x2) and (y2>=text_dimensions[i].y1) and (y2<=text_dimensions[i].y2)) {left bottom overlap} or
                     ((x2>=text_dimensions[i].x1) and (x2<=text_dimensions[i].x2) and (y2>=text_dimensions[i].y1) and (y2<=text_dimensions[i].y2)) {right bottom overlap} or

                     ((text_dimensions[i].x1>=x1) and (text_dimensions[i].x1<=x2) and (text_dimensions[i].y1>=y1) and (text_dimensions[i].y1<=y2)) {two corners of text_dimensions[i] within text} or
                     ((text_dimensions[i].x2>=x1) and (text_dimensions[i].x2<=x2) and (text_dimensions[i].y2>=y1) and (text_dimensions[i].y2<=y2)) {two corners of text_dimensions[i] within text}
                   ) then
                begin
                  overlap:=true; {text overlaps an existing text}
                  y1:=y1+(th div 3);{try to shift text one third of the text height down}
                  y2:=y2+(th div 3);
                  if y2>=height2 then {no space left, use original position}
                  begin
                    y1:=y;
                    y2:=y+th ;
                    overlap:=false;{stop searching}
                    i:=$FFFFFFF;{stop searching}
                  end;
               end;
               inc(i);
             until ((i>=text_counter) or (overlap) );{until all tested or found overlap}
           until overlap=false;{continue till no overlap}
         end;

         text_dimensions[text_counter].x1:=x1;{store text dimensions in array}
         text_dimensions[text_counter].y1:=y1;
         text_dimensions[text_counter].x2:=x2;
         text_dimensions[text_counter].y2:=y2;

         if y1<>y then {there was textual overlap}
         begin
           mainwindow.image1.Canvas.moveto(x,round(y+th/4));
           mainwindow.image1.Canvas.lineto(x,y1);
         end;
         mainwindow.image1.Canvas.textout(x1,y1,name);
         inc(text_counter);
         if text_counter>=length(text_dimensions) then setlength(text_dimensions,text_counter+200);{increase size dynamic array}
       end;{centre object visible}

       {plot deepsky object}
       if width1=0 then begin width1:=length1;pa:=999;end;
       len:=length1/(abs(cdelt2)*60*10*2); {Length in pixels}

       if len<=2 then {too small to plot an elipse or circle, plot just four dots}
       begin
         mainwindow.image1.canvas.pixels[x-2,y+2]:=clyellow;
         mainwindow.image1.canvas.pixels[x+2,y+2]:=clyellow;
         mainwindow.image1.canvas.pixels[x-2,y-2]:=clyellow;
         mainwindow.image1.canvas.pixels[x+2,y-2]:=clyellow;
       end
       else
       begin
         if PA<>999 then
           plot_glx(mainwindow.image1.canvas,x,y,len,width1/length1,gx_orientation*pi/180) {draw oval or galaxy}
         else
         mainwindow.image1.canvas.ellipse(round(x-len),round(y-len),round(x+1+len),round(y+1+len));{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
       end;
     end;
    until linepos>=$FFFFFF;{end of database}

    text_dimensions:=nil;{remove used memory}

    Screen.Cursor:=Save_Cursor;
  end;
end;{plot deep_sky}


function Gaia_star_color(Bp_Rp: integer):integer;
begin
  if Bp_Rp=-128  then result:=$00FF00 {unknown, green}
  else
  if Bp_Rp<=-0.25*10 then result:=$FF0000 {<-0.25 blauw}
  else
  if Bp_Rp<=-0.1*10 then result:=$FFFF00 {-0.25 tot -0.1 cyaan}
  else
  if Bp_Rp<=0.3*10 then result:=$FFFFFF {-0.1 tot 0.3 wit}
  else
  if Bp_Rp<=0.7*10 then result:=$A5FFFF {0.3 tot 0.7 geelwit}
  else
  if Bp_Rp<=1.0*10 then result:=$00FFFF {0.7 tot 1.0 geel}
  else
  if Bp_Rp<=1.5*10 then result:=$00A5FF {1.0 tot 1.5 oranje}
  else
  result:=$0000FF; {>1.5 rood}
end;

function get_best_mean(list: array of double): double;{Remove outliers from polulation using MAD. }
var  {idea from https://eurekastatistics.com/using-the-median-absolute-deviation-to-find-outliers/}
  n,i,count         : integer;
  median, mad       : double;
  list2: array of double;
begin
 n:=length(list);
 setlength(list2,n);
 for i:=0 to n-1 do list2[i]:=list[i];{copy magn offset data}
 median:=Smedian(list2);
 for i:=0 to n-1 do list2[i]:=abs(list[i] - median);{fill list2 with offsets}
 mad:=Smedian(list2); //median absolute deviation (MAD)

 count:=0;
 result:=0;

 for i:=0 to n-1 do
   if abs(list[i]-median)<1.0*1.4826*mad then {offset less the 1*sigma}
   begin
     result:=result+list[i];{Calculate snr weighted arithmetic mean. This gives a little less noise then calculating median again}
     inc(count);
   end;
 if count>0 then  result:=result/count;  {mean without using outliers}

 list2:=nil;
end;


procedure plot_stars(photometry_only,show_distortion: boolean);{plot stars on the image}
var
  fitsX,fitsY, fitsX_middle, fitsY_middle,screenX_middle,screenY_middle,
  dra,ddec,delta,gamma, telescope_ra,telescope_dec,fov,ra2,dec2,
  xx,yy,mag2,Bp_Rp,
  hfd1,star_fwhm,snr, flux,xc,yc,area_visible,ln_area_per_star,magn  :double;
  delta_ra,det,SIN_dec_ref,COS_dec_ref,SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,hh : double;

  x,y,star_counter,star_total_counter,x2,y2,len, max_nr_stars                                   : integer;
  flip_horizontal, flip_vertical: boolean;
  mag_offset_array : array of double;
  frac1,frac2,frac3,frac4  : double;
  area1,area2,area3,area4,nrstars_required2  : integer;
  Save_Cursor: TCursor;

    procedure plot_star;
    begin

     {5. Conversion (RA,DEC) -> (x,y)}
      sincos(dec2,SIN_dec_new,COS_dec_new);{sincos is faster then seperate sin and cos functions}
      delta_ra:=ra2-ra0;
      sincos(delta_ra,SIN_delta_ra,COS_delta_ra);
      HH := SIN_dec_new*sin_dec_ref + COS_dec_new*COS_dec_ref*COS_delta_ra;
      dRA := (COS_dec_new*SIN_delta_ra / HH)*180/pi;
      dDEC:= ((SIN_dec_new*COS_dec_ref - COS_dec_new*SIN_dec_ref*COS_delta_ra ) / HH)*180/pi;
      det:=CD2_2*CD1_1 - CD1_2*CD2_1;
      fitsX:= +crpix1 - (CD1_2*dDEC - CD2_2*dRA) / det; {1..width2}
      fitsY:= +crpix2 + (CD1_1*dDEC - CD2_1*dRA) / det; {1..height2}
      x:=round(fitsX-1); {0..width2-1}
      y:=round(fitsY-1); {0..height2-1}

      if ((x>-50) and (x<=width2+50) and (y>-50) and (y<=height2+50)) then {within image1 with some overlap}
      begin
        if photometry_only=false then
        begin {annotate}
          if flip_horizontal then x2:=(width2-1)-x else x2:=x;
          if flip_vertical   then y2:=y         else y2:=(height2-1)-y;

          inc(star_counter);
          inc(star_total_counter);

          if Bp_Rp<>999 then {colour version}
          begin
            mainwindow.image1.Canvas.textout(x2,y2,inttostr(round(mag2))+':'+inttostr(round(Bp_Rp)) {   +'<-'+inttostr(area290) });
            mainwindow.image1.canvas.pen.color:=Gaia_star_color(round(Bp_Rp));{color circel}
          end
          else
          if star_counter>=2 then {label some stars}
          begin
            mainwindow.image1.Canvas.textout(x2,y2,inttostr(round(mag2)) );
            star_counter:=0;
          end;
          len:=round((200-mag2)/5.02);
          mainwindow.image1.canvas.ellipse(x2-len,y2-len,x2+1+len,y2+1+len);{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
        end;

        {get mag/flux ratio}
        HFD(img_loaded,x,y,14{box size}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
        if ((hfd1<15) and (hfd1>=0.8) {two pixels minimum} and (snr>10)) then {star detected in img_loaded}
        begin
          if ((img_loaded[0,round(xc),round(yc)]<65000) and
              (img_loaded[0,round(xc-1),round(yc)]<65000) and
              (img_loaded[0,round(xc+1),round(yc)]<65000) and
              (img_loaded[0,round(xc),round(yc-1)]<65000) and
              (img_loaded[0,round(xc),round(yc+1)]<65000) and

              (img_loaded[0,round(xc-1),round(yc-1)]<65000) and
              (img_loaded[0,round(xc-1),round(yc+1)]<65000) and
              (img_loaded[0,round(xc+1),round(yc-1)]<65000) and
              (img_loaded[0,round(xc+1),round(yc+1)]<65000)  ) then {not saturated}
          begin
            magn:=(-ln(flux)*2.511886432/LN(10));
            if counter_flux_measured>=length(mag_offset_array) then  SetLength(mag_offset_array,counter_flux_measured+1000);{increase length}
            mag_offset_array[counter_flux_measured]:=mag2/10-magn;
            inc(counter_flux_measured); {increase counter of number of stars analysed}
          end;

          if show_distortion then
          begin
            mainwindow.image1.Canvas.Pen.width :=3;
            mainwindow.image1.Canvas.MoveTo(x2, y2);
            mainwindow.image1.Canvas.LineTo(round(x2+(x-xc)*50),round(y2-(y-yc)*50 ));
            mainwindow.image1.Canvas.Pen.width :=1;
            //  totalX:=totalX+(fitsX-xc);
            //  totalY:=totalY+(fitsY-yc);
          end;{show distortion}
        end;
      end;
    end;



begin

//  mainwindow.image1.canvas.pixels[0,0]:=$FFFFF;
  flux_magn_offset:=0;

  if ((fits_file) and (cd1_1<>0)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    flip_vertical:=mainwindow.Flipvertical1.Checked;
    flip_horizontal:=mainwindow.Fliphorizontal1.Checked;

    counter_flux_measured:=0;

    bp_rp:=999;{not defined in mono versions}
//    totalX:=0;
//    totalY:=0;

    fitsX_middle:=(width2+1)/2;{range 1..width, if range 1,2,3,4  then middle is 2.5=(4+1)/2 }
    fitsY_middle:=(height2+1)/2;
    screenX_middle:=(width2-1)/2;{range 0..width2-1, if range 0,1,2,3  then middle is 1.5=(4-1)/2 }
    screenY_middle:=(height2-1)/2;

    dRa :=(cd1_1*(fitsx_middle-crpix1)+cd1_2*(fitsy_middle-crpix2))*pi/180;
    dDec:=(cd2_1*(fitsx_middle-crpix1)+cd2_2*(fitsy_middle-crpix2))*pi/180;
    delta:=cos(dec0)-dDec*sin(dec0);
    gamma:=sqrt(dRa*dRa+delta*delta);
    telescope_ra:=ra0+arctan(Dra/delta);
    telescope_dec:=arctan((sin(dec0)+dDec*cos(dec0))/gamma);

    fov:= sqrt(sqr(width2*cdelt1)+sqr(height2*cdelt2))*pi/180; {field of view with 0% extra}

    fov:=min(fov,9.53*pi/180);{warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected}

    linepos:=2;{Set pointer to the beginning. First two lines are comments}

    mainwindow.image1.Canvas.Pen.width :=1; // round(1+height2/mainwindow.image1.height);{thickness lines}
    mainwindow.image1.canvas.pen.color:=$00B0FF ;{orange}
    mainwindow.image1.Canvas.font.size:=10; //round(14*height2/mainwindow.image1.height);{adapt font to image dimensions}
    mainwindow.image1.Canvas.brush.Style:=bsClear;
    mainwindow.image1.Canvas.font.color:=$00B0FF ;{orange}

    setlength(mag_offset_array,1000);

    star_counter:=999; {for labeling}
    star_total_counter:=0;{total counter}
    max_nr_stars:=round(width2*height2*(1000/(2328*1760)));{display about 1000 stars for ASI1600 in bin 2x2 where height is 1760 pixels}

    if select_star_database(stackmenu1.star_database1.text)=false then
    begin
      application.messagebox(pchar('No star database found!'+#13+'Download the g17 (or g16 or g18) and extract the files to the program directory'), pchar('No star database!'),0);
      exit;
    end;

    find_areas( telescope_ra,telescope_dec, fov,{var} area1,area2,area3,area4, frac1,frac2,frac3,frac4);{find up to four star database areas for the square image}

    sincos(dec0,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}

    {read 1th area}
    if area1<>0 then {read 1th area}
    begin
    //  area290:=area1;
      nrstars_required2:=trunc(max_nr_stars * frac1);
      while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,area1,{var} ra2,dec2, mag2,Bp_Rp)) ) do plot_star;{add star}
      close_star_database;{close reader, so next time same file is read from beginning}
    end;

    {read 2th area}
    if area2<>0 then {read 2th area}
    begin
   //  area290:=area2;
      nrstars_required2:=trunc(max_nr_stars * (frac1+frac2));
      while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,area2,{var} ra2,dec2, mag2,Bp_Rp)) ) do plot_star;{add star}
      close_star_database;{close reader, so next time same file is read from beginning}
    end;

    {read 3th area}
    if area3<>0 then {read 3th area}
    begin
   //  area290:=area3;
      nrstars_required2:=trunc(max_nr_stars * (frac1+frac2+frac3));
      while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,area3,{var} ra2,dec2, mag2,Bp_Rp)) ) do plot_star;{add star}
      close_star_database;{close reader, so next time same file is read from beginning}
    end;
    {read 4th area}
    if area4<>0 then {read 4th area}
    begin
   // area290:=area4;

      nrstars_required2:=trunc(max_nr_stars * (frac1+frac2+frac3+frac4));
      while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,area4,{var} ra2,dec2, mag2,Bp_Rp)) ) do plot_star;{add star}
      close_star_database;{close reader, so next time same file is read from beginning}
    end;


    if counter_flux_measured>0 then {use all stars}
    begin
      SetLength(mag_offset_array,counter_flux_measured);{set length correct}
      flux_magn_offset:=get_best_mean(mag_offset_array)
    end
    else
    flux_magn_offset:=0;
    mag_offset_array:=nil;

    Screen.Cursor:= Save_Cursor;

  end;{fits file}
end;{plot stars}


procedure plot_stars_used_for_solving(correctionX,correctionY: double); {plot image stars and database stars used for the solution}
var
  nrstars,i, starX, starY,size  : integer;
  flip_horizontal, flip_vertical: boolean;
  xx,yy,x,y                     :double;
begin
  flip_vertical:=mainwindow.Flipvertical1.Checked;
  flip_horizontal:=mainwindow.Fliphorizontal1.Checked;

  {do image stars}
  nrstars:=length(starlist2[0]);
  for i:=0 to nrstars-1 do
  begin
    mainwindow.image1.Canvas.Pen.Mode := pmMerge;
    mainwindow.image1.Canvas.Pen.width := round(1+height2/mainwindow.image1.height);{thickness lines}
    mainwindow.image1.Canvas.brush.Style:=bsClear;
    mainwindow.image1.Canvas.Pen.Color :=clred;

    if flip_horizontal=true then starX:=round((width2-starlist2[0,i]))  else starX:=round(starlist2[0,i]);
    if flip_vertical=false  then starY:=round((height2-starlist2[1,i])) else starY:=round(starlist2[1,i]);
    size:=15;
    mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
 end;

  {do database stars}
  nrstars:=length(starlist1[0]);
  for i:=0 to nrstars-1 do
  begin
    mainwindow.image1.Canvas.Pen.Color := clyellow;

    xx:=(starlist1[0,i]-correctionX)/(cdelt1*3600);{apply correction for database stars center and image center and convert arc seconds to pixels}
    yy:=(starlist1[1,i]-correctionY)/(cdelt2*3600);
    rotate((90-crota2)*pi/180,xx,yy,X,Y);{rotate to screen orientation}

    if flip_horizontal=false then begin starX:=round(crpix1-x); end else begin starX:=round(crpix1+x); end;
    if flip_vertical=false   then begin starY:=round(crpix2-y); end else begin starY:=round(crpix2+y); end;

    size:=20;
    mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
  end;
end;


end.

