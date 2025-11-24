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
procedure convert_magnitudes(passband : string); //convert gaia magnitude to a new magnitude
function transform_gaia(filter : string; magG,magBP,magRP: double):double;//transformation of Gaia magnitudes
procedure report_one_star_magnitudes(ra,dec : double; out b,v,r,i,sg,sr,si,g,bp,rp :double); //report the database magnitudes for a specfic position. Not efficient but simple

var
  online_database : Tstar_list;//The output. Filled with ra,dec,magn
  gaia_ra: double=0;
  gaia_dec: double=0;
  gaia_magn_limit : double=0;

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
        if filter='V' then //Johnson-Cousins-V. See https://gea.esac.esa.int/archive/documentation/GDR3/Data_processing/chap_cu5pho/cu5pho_sec_photSystem/cu5pho_ssec_photRelations.html
        begin
          if ((BminR>=-0.5) and (BminR<=5.0)) then {formula valid edr3, about 99% of stars}
            result:=magG + 0.02704 - 0.01424*(BminR) + 0.2156*sqr(BminR) -0.01426*sqr(BminR)*(BminR) ;  {edr3}
        end
        else
        if filter='R' then //Johnson-Cousins R
        begin
          if ((BminR>0 {remark J, could be 0.2}) and (BminR<4.0)) then
            result:=magG + 0.02275 - 0.3961*(BminR) + 0.1243*sqr(BminR)+ 0.01396*sqr(BminR)*(BminR) - 0.003775*sqr(sqr(BminR)) ;  {dr3}
        end
        else
        if filter='I' then //Johnson-Cousins I
        begin
          if ((BminR>-0.5) and (BminR<4.5)) then
            result:=magG - 0.01753 - 0.76*(BminR) + 0.0991*sqr(BminR);  {dr3, https://gea.esac.esa.int/archive/documentation/GDR3/Data_processing/chap_cu5pho/cu5pho_sec_photSystem/cu5pho_ssec_photRelations.html}
        end
        else
        if filter='B' then //Johnson-B
        begin
          if ((BminR>-0.3) and (BminR<3.0)) then
          begin
            Vt:=magG + 0.01077 + 0.0682*(BminR) + 0.2387*sqr(BminR) -0.02342*sqr(BminR)*(BminR) ;
            Bt:=magG + 0.004288 + 0.8547*(BminR) -0.1244*sqr(BminR)+ 0.9085*sqr(BminR)*(BminR) - 0.4843*sqr(sqr(BminR))+ 0.06814*sqr(sqr(BminR))*BminR ;
            V:=magG + 0.02704 - 0.01424*(BminR) + 0.2156*sqr(BminR) -0.01426*sqr(BminR)*(BminR) ;

            result:=V + 0.850*(Bt-Vt); //from Tycho catalog, B - V = 0.850 * (BT - VT)
          end;
        end
        else
        if ((filter='SR') or (filter='RP'){Las Cumbres files}) then //SDSS-r
        begin
          if ((BminR>0.0) and (BminR<3.0)) then
            result:=magG + 0.09837 - 0.08592*(BminR) - 0.1907*sqr(BminR) + 0.1701*sqr(BminR)*(BminR) - 0.02263*sqr(sqr(BminR)) ;  {dr3}
        end
        else
        if ((filter='SI') or (filter='IP')) then //SDSS-i
        begin
          if ((BminR>0.5) and (BminR<2.0)) then
            result:=magG + 0.293 - 0.6404*(BminR) + 0.09609*sqr(BminR) + 0.002104*sqr(BminR)*(BminR);  {dr3}
        end
        else
        if ((filter='SG') or (filter='GP')) then //SDSS-g
        begin
          if ((BminR>0.3) and (BminR<3.0)) then
            result:=magG - 0.2199 + 0.6365*(BminR) + 0.1548*sqr(BminR) - 0.0064*sqr(BminR)*(BminR);  {dr3}
        end;
      end;
    end;
  end;
end;


procedure convert_magnitudes(passband : string); //convert gaia magnitude to a new magnitude
var
  i : integer;
begin
  if passband=passband_active then exit;//no action. Already the correct type
  for i:=0 to length(online_database[0])-1 do
    online_database[5,i]:=transform_gaia(passband,online_database[2,i]{G},online_database[3,i]{BP},online_database[4,i]{RP});
  passband_active:=passband;//remember last transformation
end;


procedure report_one_star_magnitudes(ra,dec : double; out b,v,r,i,sg,sr,si,g,bp,rp :double); //report the database magnitudes for a specfic position. Not efficient but simple
var
  j : integer;
  sep : double;
begin
  b:=0;
  v:=0;
  r:=0;
  i:=0;
  sg:=0;
  sr:=0;
  si:=0;
  g:=0;
  bp:=0;
  rp:=0;
  if online_database=nil then
  begin
    exit;
  end;
  for j:=0 to length(online_database[0])-1 do
  begin
    ang_sep(ra,dec,online_database[0,j],online_database[1,j],sep);
    if sep<5*pi/(180*60*60) then //within 5 arcsec
    begin
      b:=transform_gaia('B',online_database[2,j]{G},online_database[3,j]{BP},online_database[4,j]{RP});//BVR Johnson-Cousins
      v:=transform_gaia('V',online_database[2,j]{G},online_database[3,j]{BP},online_database[4,j]{RP});
      r:=transform_gaia('R',online_database[2,j]{G},online_database[3,j]{BP},online_database[4,j]{RP});
      i:=transform_gaia('I',online_database[2,j]{G},online_database[3,j]{BP},online_database[4,j]{RP});
      sg:=transform_gaia('SG',online_database[2,j]{G},online_database[3,j]{BP},online_database[4,j]{RP});//sloan mangitudes
      sr:=transform_gaia('SR',online_database[2,j]{G},online_database[3,j]{BP},online_database[4,j]{RP});
      si:=transform_gaia('SI',online_database[2,j]{G},online_database[3,j]{BP},online_database[4,j]{RP});
      g:=online_database[2,j]{G};
      bp:=online_database[3,j]{BP};
      rp:=online_database[4,j]{RP};
      break;
    end;
  end;
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
  passband_active:=''; //By definition since new stars are loaded. So the procedure convert_magnitudes should convert the magnitudes again.

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
 // memo2_message(inttostr(count2)+' Gaia stars available');
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

    mag_lim:=floattostrF(magli,ffFixed,0,2); {BP~GP+0.5}
    memo2_message('Downloading Gaia stars from Vizier down to magnitude '+mag_lim+'. This can take 60 seconds or more ......');

    if search_field*180/pi>=3.5 then
      memo2_message('Warning, for this large FOV the star retrieval from Vizier will likely take minutes or fail!!!');

    url:='http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=RA_ICRS,DE_ICRS,Gmag,BPmag,RPmag&-c='+ra8+sgn+dec8+window_size+'&-out.max=200000&BPmag=<'+mag_lim;
       // http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=RA_ICRS,DE_ICRS,Gmag,BPmag,RPmag&-c=41.9723905228%2B15.5128350596&-c.bs=9968.171892/9968.171892&-out.max=200000&BPmag=<16.90

    // see also https://vizier.cds.unistra.fr/doc/asu-summary.htx
    slist.Text := get_http(url);//move info to Tstringlist
    application.processmessages;
    if esc_pressed then
    begin
      exit;//jump to finally and slist.free there
    end;
    if slist.count<=31 then
      memo2_message('List received is empthy! url: '+url)
    else
    begin
      memo2_message('About '+inttostr(slist.count-31)+' stars downloaded.');
      gaia_ra:=telescope_ra; //store to test if data is still valid
      gaia_dec:=telescope_dec;//store to test if data is still valid
      gaia_magn_limit:=magli;//store limiting magnitude
      extract_stars(slist );
      result:=true;{no errors}
    end;
  finally
    slist.Free;
  end;
end;

end.

