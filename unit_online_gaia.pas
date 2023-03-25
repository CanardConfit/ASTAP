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
procedure convert_magnitudes(filter : string); //convert gaia magnitude to a new magnitude
function transform_gaia(filter : string; magG,magBP,magRP: double):double;//transformation of Gaia magnitudes

var
  online_database : star_list;//The output. Filled with ra,dec,magn
  gaia_ra: double=0;
  gaia_dec: double=0;

implementation

uses
  unit_astrometric_solving;


function transform_gaia(filter : string; magG,magBP,magRP: double):double;//transformation of Gaia magnitudes
var
  Gflux,BPflux,RPflux,c,BminR,Bt,Vt,V : double;
begin
  if filter='BP' then result:=magBP
  else
  begin
    result:=0;//assume failure

    if ((magG<>0) and
        (magBP<>0) and
        (magRP<>0))then
    begin
      {quality check by flux ratio}

      //C:=(BPflux +RPflux)/Gflux  is normally a little above 1 so about 1.15.. So chapter 6 "Gaia Early Data Release 3 Photometric content and validation"
      //if flux is calculated from the magnitudes it is a little above 2}

      //De flux kan ik ook terugrekenen van de magnitude. Dat is gemakkelijker want de flux heb ik nog niet in de database.
      //Het blijkt als je de flux uitrekend dan is de ratio (BPflux+RPflux)/Gflux meestal iets boven circa 2. Maar loopt voor de
      //slechte waarden op tot wel 27. Het idee is nu wanneer deze ratio groter dan 4 en G>BP de G magnitude te gebruiken, anders BP.
      //De conditie G>BP is nodig voor hele rode sterren om te voorkomen dat je een infrarood magnitude neemt.
      Gflux:=power(10,(22-magG)/2.5);
      BPflux:=power(10,(22-magBP)/2.5);
      RPflux:=power(10,(22-magRP)/2.5);
      c:=(BPflux+RPflux)/Gflux;
      if ((c>4) and (magG>magBP))=false then {no straylight do not rely on BP and RP. C is normally a little above 2}
      begin
        BminR:=magBP-magRP;
        if filter='V' then //Johnson-Cousins-V
        begin
          if ((BminR>=-0.5) and (BminR<=5.0)) then {formula valid edr3, about 99% of stars}
            result:=magG + 0.02704 - 0.0124*(BminR) + 0.2156*sqr(BminR) -0.01426*sqr(BminR)*(BminR) ;  {edr3}
        end
        else
        if filter='R' then //Johnson-Cousins R
        begin
          if ((BminR>0 {remark J, could be 0.2}) and (BminR<4.0)) then
            result:=magG + 0.02275 - 0.3961*(BminR) + 0.1243*sqr(BminR)+ 0.01396*sqr(BminR)*(BminR) - 0.003775*sqr(sqr(BminR)) ;  {edr3}
        end
        else
        if filter='B' then //Johnson-B
        begin
          if ((BminR>-0.3) and (BminR<3.0)) then
          begin
            Vt:=magG + 0.01077 + 0.0682*(BminR) + 0.2387*sqr(BminR) -0.02342*sqr(BminR)*(BminR) ;
            Bt:=magG + 0.004288 + 0.8547*(BminR) -0.1244*sqr(BminR)+ 0.9085*sqr(BminR)*(BminR) - 0.4843*sqr(sqr(BminR))+ 0.06814*sqr(sqr(BminR))*BminR ;
            V:=magG + 0.02704 - 0.0124*(BminR) + 0.2156*sqr(BminR) -0.01426*sqr(BminR)*(BminR) ;

            result:=V + 0.850*(Bt-Vt); //from Tycho catalog, B - V = 0.850 * (BT - VT)
          end;
        end;
      end;
    end;
  end;
end;


procedure convert_magnitudes(filter : string); //convert gaia magnitude to a new magnitude
var
  i : integer;
begin
  if filter=gaia_type then exit;//no action. Already the correct type
  for i:=0 to length(online_database[0])-1 do
    online_database[5,i]:=transform_gaia(filter,online_database[2,i]{G},online_database[3,i]{BP},online_database[4,i]{RP});
  gaia_type:=filter;//remember last transformation
end;


procedure extract_stars(slist:Tstringlist); //extract stars
var
  regel  : string;
  p1,p2,p3,p4,count,count2,err : integer;
  g,bp,rp,ra,dec   : double;
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

  setlength(online_database,6,slist.count);//position 5 will contain later the converted magnitude
  count:=35;{skip first part}
  while count<slist.count-2 do
  begin
    regel:=slist[count];
    inc(count);

    if datalines then //Data from Vizier
    begin
      {magnitude}
      p1:=pos(' ',regel);{first column changes in width}
      p2:=posex(' ',regel,p1+3);//there could be two spaces so skip at least 3
      p3:=posex(' ',regel,p2+3);
      p4:=posex(' ',regel,p3+3);
      if ((p3>0) and (ord(regel[1])>=48) and (ord(regel[1])<=57)) then //this is a real line of the star list. number lines between  char(48) and char(57)
      begin
        val(copy(regel,1,p1-1),ra,err);//ra
        online_database[0,count2]:=ra*pi/180;
        val(copy(regel,p1+1,p2-p1-1),dec,err);//dec
        online_database[1,count2]:=dec*pi/180;
        val(copy(regel,p2+1,p3-p2-1),g,err);//G
        online_database[2,count2]:=g;

        val(copy(regel,p3+1,p4-p3-1),bp,err);//Bp
        online_database[3,count2]:=bp;
        val(copy(regel,p4+1,99),rp,err);//Rp
        online_database[4,count2]:=rp;
        online_database[5,count2]:=bp;//store default the BP magnitude here. Could be calculated V, B or R later
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

  SetLength(online_database,6,count2);{set array length}
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
    memo2_message('Downloading Gaia stars from Vizier down to magnitude '+mag_lim+'. This can take 20 seconds or more ......');
    url:='http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=RA_ICRS,DE_ICRS,Gmag,BPmag,RPmag&-c='+ra8+sgn+dec8+window_size+'&-out.max=200000&Gmag=<'+mag_lim;
       // url:='http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=RA_ICRS,DE_ICRS,Gmag,BPmag,RPmag&-c='+ra8+sgn+dec8+'&-c.bs=533.293551/368.996043&-out.max=1000&Gmag=%3C23
    slist.Text := get_http(url);//move info to Tstringlist
    application.processmessages;
    if esc_pressed then
    begin
      slist.Free;
      exit;
    end;
    memo2_message('Stars list received');
    gaia_ra:=telescope_ra; //store to test if data is still valid
    gaia_dec:=telescope_dec;

    extract_stars(slist );
  finally
    slist.Free;
  end;

  result:=true;{no errors}
end;

end.

