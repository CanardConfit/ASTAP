unit unit_online_gaia;

{Copyright (C) 2017, 2023 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

{$mode delphi}
interface

uses
  Classes, SysUtils,strutils,forms,math,astap_main,unit_download,unit_star_align,unit_stack;

function read_stars_online(telescope_ra,telescope_dec,search_field, magli: double): boolean;{read star from star database}

var
  online_database : star_list;//The output. Filled with ra,dec,magn

implementation

uses
  unit_astrometric_solving;


procedure extract_stars(slist:Tstringlist); //extract stars
var
  regel,s  : string;
  p1,p2,p3,count,count2,err : integer;
  bp,ra,dec   : double;
  datalines : boolean;
//  thestars : array of array of double;
//  magn_histogram : array [0..23*40] of integer;//contains magnitude count from 0.0 to magnitude 23.0 in steps of 0.025 magnitude
begin
  //--------------- --------------- --------- ---------
  //                                  G         BP
  //RA_ICRS (deg)   DE_ICRS (deg)   mag (mag) mag (mag)
  //--------------- --------------- --------- ---------
  //086.58690478866 -10.38175731298 20.486355 20.757553
  //086.57689784801 -10.37081756215 20.496525 21.346535
  //086.57543967588 -10.36071651144 20.726021 21.413324

  datalines:=false;
  count2:=0;

  setlength(online_database,3,slist.count);
  count:=35;{skip first part}
  while count<slist.count-2 do
  begin
    regel:=slist[count];
    inc(count);

    if datalines then //Data from Vizier
    begin
      {magnitude}
      p1:=pos(' ',regel);{first column changes in width}
      p2:=posex(' ',regel,p1+1);
      p3:=posex(' ',regel,p2+1);
      if ((p3>0) and (ord(regel[1])>=48) and (ord(regel[1])<=57)) then //this is a real line of the star list. number lines between  char(48) and char(57)
      begin
        val(copy(regel,1,p1-1),ra,err);//ra
        online_database[0,count2]:=ra*pi/180;
        val(copy(regel,p1+1,p2-p1-1),dec,err);//dec
        online_database[1,count2]:=dec*pi/180;

        val(copy(regel,p3+1,99),bp,err);//bp magnitude

        if bp=0 then
          bp:=strtofloat1(copy(regel,p2+1,p3-p2-1))+0.5;//use G magnitude instead, {BP~GP+0.5}
        if bp>23 then bp:=23;//in some cases (very red stars) magnitude is above 23. Prevent runtime errors
        online_database[2,count2]:=bp;{BPmagn or G magnitude in some cases}
        inc(count2);//stars read
      end;
    end {correct line of star list}
    else
    if copy(regel,1,7)='RA_ICRS' then //data begins
    begin
      datalines:=true;
      inc(count);//skip one more line containing --------------- --------------- --------- ---------
    end;
  end;

  SetLength(online_database,3,count2);{set array length}
end;



function read_stars_online(telescope_ra,telescope_dec,search_field, magli : double): boolean;{read star from star database}
var
  ra8,dec8,sgn,window_size,field,url,mag_lim : string;
  slist: TStringList;
begin
  result:=false;
  str(abs(telescope_dec*180/pi) :3:10,dec8);
  if telescope_dec>=0 then sgn:='+'  else sgn:='-';
  if telescope_dec>=0 then sgn:='%2B'{+}  else sgn:='%2D'{-} ;
  str(abs(telescope_ra*180/pi) :3:10,ra8);
  esc_pressed:=false;

  field:=floattostr6(search_field*3600*180/pi);

  window_size:='&-c.bs='+ field+'/'+field;{square box}
  {-c.geom=b  square box, -c.bs=10 box size 10arc
  else radius}

  try
    slist := TStringList.Create;

    mag_lim:=floattostrF(magli,ffGeneral,3,1);
    memo2_message('Requesting Gaia stars from Vizier up to magnitude '+mag_lim);
    url:='http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=RA_ICRS,DE_ICRS,Gmag,BPmag&-c='+ra8+sgn+dec8+window_size+'&-out.max=200000&Gmag=<'+mag_lim;
       // url:='http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=RA_ICRS,DE_ICRS,Gmag,BPmag,RPmag&-c='+ra8+sgn+dec8+'&-c.bs=533.293551/368.996043&-out.max=1000&Gmag=%3C23
    slist.Text := get_http(url);//move info to Tstringlist
    application.processmessages;
    if esc_pressed then
    begin
      slist.Free;
      exit;
    end;
    memo2_message('Stars list received');
    extract_stars(slist );
  finally
    slist.Free;
  end;

  result:=true;{no errors}
end;

end.

