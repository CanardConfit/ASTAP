unit unit_online_gaia;
{Copyright (C) 2017, 2023 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }


interface

uses
  Classes, SysUtils,strutils,math,astap_main,unit_download,unit_star_align,unit_stack;

function read_stars_online(telescope_ra,telescope_dec,search_field, magli: double; nrstars_required: integer; out nrstars: integer; out magmax:double): boolean;{read star from star database}

var
  online_database : star_list;//The output. Filled with ra,dec,magn

implementation

uses
  unit_astrometric_solving;


procedure extract_stars(slist:Tstringlist;telescope_ra,telescope_dec: double;maxstars,nrstars_required: integer; out nrstars: integer; out magn_limit: double); //extract stars
var
  regel  : string;
  p1,p2,p3,count,count2,count3,count4,i,magn,index,err  : integer;
  g,bp,magf   : double;
  datalines : boolean;
  thestars : array of array of double;
  magn_histogram : array [0..23*40] of integer;//contains magnitude count from 0.0 to magnitude 23.0 in steps of 0.025 magnitude
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
  nrstars:=0;
  for i:=0 to 23*40 do magn_histogram[i]:=0;//clear magnitude histogram
  setlength(thestars,3,maxstars);

  count:=35;{skip first part}
  while count+1<=slist.count do
  begin
    regel:=ansistring(slist[count]);
    inc(count);
    if datalines then //Data from Vizier
    begin
      {magnitude}
      p1:=pos(' ',regel);{first column changes in width}
      p2:=posex(' ',regel,p1+1);
      p3:=posex(' ',regel,p2+1);
      if ((p3>0) and (ord(regel[1])>=48) and (ord(regel[1])<=57)) then //this is a real line of the star list. number lines between  char(48) and char(57)
      begin
        val(copy(regel,1,p1-1),thestars[0,count2],err);//ra
        val(copy(regel,p1+1,p2-p1-1),thestars[1,count2],err);//dec
        val(copy(regel,p3+1,99),bp,err);//bp magnitude

        if bp=0 then
          bp:=strtofloat1(copy(regel,p2+1,p3-p2-1));//G magnitude
        thestars[2,count2]:=bp;{BPmagn or G magnitude in some cases}
        if bp>23 then bp:=23;//in some cases (very red stars) magnitude is above 23. Prevent runtime errors
        index:=round(bp*40);
        magn_histogram[index]:=magn_histogram[index]+1; //build histogram by rounding magnitudes to integers equals 0.025 magnitude
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


//  if nrstars_required<count then //filtering required
  begin
    //find the required magnitude to retrieve the nr_stars_required using a histogram
    count3:=0;
    magn:=0;
    repeat
      inc(magn,1);//steps of 0.025 magnitude
      count3:=count3+magn_histogram[magn];
    until ((count3>=nrstars_required) or (magn>=23*40));
    magn_limit:=magn/40;// limiting magnitude required to retrieve the requested stars
  end;;
//  else
//  magn_limit:=99;

  //retrieve the brightest stars using the histogram
  SetLength(online_database,3,nrstars_required);{set array length}
  count4:=0;
  nrstars:=0;
  repeat
    if thestars[2,count4]<=magn_limit then //correct magnitude
    begin
      online_database[0,nrstars]:=thestars[0,count4]*pi/180;//ra
      online_database[1,nrstars]:=thestars[1,count4]*pi/180;//dec
      online_database[2,nrstars]:=thestars[2,count4];//magn
      inc(nrstars);
      if nrstars>=nrstars_required then
         break;
    end;
    inc(count4)
  until count4>=count2;


  thestars:=nil;
  magn_limit:= magn_limit*10; //report limiting magnitude in 0.1 magnitudes
end;



function read_stars_online(telescope_ra,telescope_dec,search_field, magli : double; nrstars_required: integer; out nrstars: integer; out magmax:double): boolean;{read star from star database}
var
  ra8,dec8,sgn,window_size,field,url,mag_lim, s : string;
  x, databaselimit: double;
  maxstars : integer=50000;
  slist: TStringList;
begin
  str(abs(telescope_dec*180/pi) :3:10,dec8);
  if telescope_dec>=0 then sgn:='+'  else sgn:='-';
  if telescope_dec>=0 then sgn:='%2B'{+}  else sgn:='%2D'{-} ;
  str(abs(telescope_ra*180/pi) :3:10,ra8);

  field:=floattostr6(search_field*3600*180/pi);

  window_size:='&-c.bs='+ field+'/'+field;{square box}
  {-c.geom=b  square box, -c.bs=10 box size 10arc
  else radius}

  try
    slist := TStringList.Create;

    if (nrstars_required<50000) then //Increase slowly the limiting magnitude till sufficient stars are retreived from Vizier
    begin // limited by number of stars.
      magli:=12 - ln(sqr(search_field*180/pi))/ln(2.51);//to get the same amount of stars the limiting magnitude should decrease with the surface area (sqr function). ln()/ln(2.51) is the conversion to magnitude
      databaselimit:=21;
    end
    else //limited by magnitude
      databaselimit:=0;// stop after first cycle

    repeat //adapt to the varying star density. Update mag_lim and placing new reqeust work faster then sorting later. sorting is pretty cpu intensive for 10000 or more stars
      mag_lim:=floattostrF(magli,ffGeneral,3,1);
      memo2_message('Requesting Gaia stars from Vizier up to magnitude '+mag_lim);
      url:='http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=RA_ICRS,DE_ICRS,Gmag,BPmag&-c='+ra8+sgn+dec8+window_size+'&-out.max='+inttostr(maxstars)+'&Gmag=<'+mag_lim;
         // url:='http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=RA_ICRS,DE_ICRS,Gmag,BPmag,RPmag&-c='+ra8+sgn+dec8+'&-c.bs=533.293551/368.996043&-out.max=1000&Gmag=%3C23
      slist.Text := get_http(url);//move info to Tstringlist
      x:=slist.count-40;//number of stars received from Vizier
      magli:=magli+1.0;//increase magnitude to avoid floading by Milky Way stars
    until ((x>nrstars_required) or (magli>=databaselimit+1));//40 is number of lines used by the header and end. Is not used for star data.

    memo2_message('Extracting Gaia stars');
    extract_stars(slist ,telescope_ra,telescope_dec,maxstars,nrstars_required,{out} nrstars,magmax);
    memo2_message('Extracting brightest '+inttostr(nrstars)+' stars completed.');
  finally
    slist.Free;
  end;

  result:=true;{no errors}
end;

end.

