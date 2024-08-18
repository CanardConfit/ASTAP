unit unit_aavso;
{Copyright (C) 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }
{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, math,
  clipbrd, ExtCtrls, Menus, Buttons, FileCtrl, ComboEx,strutils;

type

  { Tform_aavso1 }

  Tform_aavso1 = class(TForm)
    baa_style1: TCheckBox;
    abrv_comp1: TComboBox;
    suggest_check1: TButton;
    hjd1: TCheckBox;
    delta_bv1: TEdit;
    Image_photometry1: TImage;
    Label10: TLabel;
    Label11: TLabel;
    measure_all_mode1: TLabel;
    Label9: TLabel;
    abrv_variable1: TComboBox;
    name_variable2: TEdit;
    magnitude_slope1: TEdit;
    report_error1: TLabel;
    MenuItem1: TMenuItem;
    abrv_check1: TComboBox;
    PopupMenu1: TPopupMenu;
    report_to_clipboard1: TButton;
    report_to_file1: TButton;
    delimiter1: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label3: TLabel;
    obscode1: TEdit;
    Label1: TLabel;
    Filter1: TComboBox;
    SaveDialog1: TSaveDialog;
    suggest_comp1: TButton;
    procedure delta_bv2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure hjd1Change(Sender: TObject);
    procedure Image_photometry1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure MenuItem1Click(Sender: TObject);
    procedure abrv_check1Change(Sender: TObject);
    procedure abrv_check1DropDown(Sender: TObject);
    procedure abrv_variable1Change(Sender: TObject);
    procedure abrv_variable1DropDown(Sender: TObject);
    procedure report_to_clipboard1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure suggest_check1Change(Sender: TObject);
    procedure suggest_check1Click(Sender: TObject);
    procedure suggest_comp1Click(Sender: TObject);
  private

  public

  end;

var
  form_aavso1: Tform_aavso1;


var
  obscode       : string='';
  abbrev_check : string='';
  abbrev_comp : string='';
  name_check_IAU : string='';
  name_comp_IAU : string='';
  abbreviation_var_IAU   : string='';
  abbrev_var   : string='';
  delim_pos  : integer=0;
  to_clipboard  : boolean=true;
  baa_style  : boolean=false;
  hjd_date   : boolean=false;
  aavso_filter_index: integer=0;
  delta_bv : double=0;
  magnitude_slope    : double=0;

var
  aavso_report : string;
  used_vsp_stars: string='';

procedure plot_graph; {plot curve}


implementation


{$R *.lfm}
uses astap_main,
     unit_stack,
     unit_star_database,{for name_database only}
     unit_annotation;//for variable_list


type
    Tstarinfo = record
                   x   : double;
                   str : string;
                 end;
var
  jd_min,jd_max,magn_min,magn_max : double;
  w,h,bspace,column_var,column_check,column_comp  :integer;

function floattostr3(x:double):string;
begin
  str(x:0:3,result);
end;

procedure retrieve_vsp_stars(variablestar: string);
var
  i,j,k,L : integer;
begin
  i:=pos(variablestar, used_vsp_stars);
  if i<>0 then //already available
  begin
    j:=posex(':',used_vsp_stars,i+1);
    k:=posex(':',used_vsp_stars,j+1);
    L:=posex(';',used_vsp_stars,j+1);
    form_aavso1.abrv_check1.text:=copy(used_vsp_stars,j+1,k-j-1);
    form_aavso1.abrv_comp1.text:=copy(used_vsp_stars,k+1,L-k-1);
  end
  else
  begin
    form_aavso1.abrv_check1.text:='';
    form_aavso1.abrv_comp1.text:='';
  end;
end;

procedure store_vsp_stars(variablestar,checkstar, compstar: string);
var
   i,j: integer;
begin
  if length(variablestar)=0 then exit;
  i:=pos(variablestar, used_vsp_stars);
  if i<>0 then //already available
  begin
    j:=posex(';',used_vsp_stars,i); //find end of entry
    delete(used_vsp_stars,i,j-i+1); //delete entry
  end;
  used_vsp_stars:=used_vsp_stars+  variablestar+':'+checkstar+':'+compstar+';';
  if length(used_vsp_stars)>10000 then used_vsp_stars:=copy(used_vsp_stars,20,10100);//limit size. Throw oldest part away.
end;


procedure QuickSort_records(var A: array of Tstarinfo; iLo, iHi: Integer) ;{ Fast quick sort. Sorts elements in the array A containing records with indices between lo and hi}
var
  Lo, Hi : integer;
  Pivot : double;
  T: Tstarinfo;
begin
  Lo := iLo;
  Hi := iHi;
  Pivot := A[(Lo + Hi) div 2].x;
  repeat
    while A[Lo].x < Pivot do Inc(Lo) ;
    while A[Hi].x > Pivot do Dec(Hi) ;
    if Lo <= Hi then
    begin {swap}
      T := A[Lo];
      A[Lo] := A[Hi];
      A[Hi] := T;
      Inc(Lo) ;
      Dec(Hi) ;
    end;
  until Lo > Hi;
  if Hi > iLo then QuickSort_records(A, iLo, Hi) ;  {executes itself recursively}
  if Lo < iHi then QuickSort_records(A, Lo, iHi) ;  {executes itself recursively}
end;


function remove_sigma_end(s: string): string;//remove then ', σ=' at the end
var
  cpos:integer;
begin
  cpos:=pos(',',s);
  if cpos>0 then
     result:=copy(s,1,cpos-1)
  else
    result:=s;
end;


procedure get_info;
begin
  with form_aavso1 do
  begin
    obscode:=obscode1.text;
    abbrev_var:=remove_sigma_end(abrv_variable1.text);
    abbrev_check:=abrv_check1.text;
    abbrev_comp:=abrv_comp1.text;
    delim_pos:=delimiter1.itemindex;
    baa_style:=baa_style1.checked;
    hjd_date:=hjd1.checked;
    aavso_filter_index:=filter1.itemindex;
    delta_bv:=strtofloat2(form_aavso1.delta_bv1.text);
    magnitude_slope:=strtofloat2(form_aavso1.magnitude_slope1.text);
  end;
end;


function clean_abbreviation(s: string): string;
var
  space : integer;
begin
  space:= posex(' ',s,4);
  if space>0 then
  s:=copy(s,1,space-1);
  result:=stringreplace(s,'_',' ',[rfReplaceAll]);
end;


function get_comp_magnitude(filter,columnr: integer; s: string): double;//get comp magnitude from the abbrv string
var
  v,e,err : integer;
  s2 : string;
begin
  result:=0;

  if stackmenu1.listview7.column[columnr+1].tag=2 then //online vsp list
  begin
    if ((filter=-1) or (filter=1)) then //V
     result:=strtofloat(vsp[stackmenu1.listview7.column[columnr].tag].Vmag)
    else
    if ((filter=0) or (filter =24)) then  //R or Cousins red
      result:=strtofloat(vsp[stackmenu1.listview7.column[columnr].tag].Rmag)
    else
    if filter=2 then  //Blue
      result:=strtofloat(vsp[stackmenu1.listview7.column[columnr].tag].Bmag)
    else
    if filter=21 then  //SDSS-i
      result:=strtofloat(vsp[stackmenu1.listview7.column[columnr].tag].SImag)
    else
    if filter=22 then //SDDS=r
      result:=strtofloat(vsp[stackmenu1.listview7.column[columnr].tag].SRmag)
    else
    if filter=23 then //SDDS=g
      result:=strtofloat(vsp[stackmenu1.listview7.column[columnr].tag].SGmag);
  end
  else
  if ((stackmenu1.listview7.column[columnr+1].tag=0) and ((filter=-1) or (filter=1))) then //local variable list, only usefull for V magnitudes
  begin
    v:= posex('V=',uppercase(s),4);
    if v>0 then
    begin
       v:=v+2;
       e:= posex('(',s,4);
       if s[e-1]='_' then
         s2:=copy(s,v,e-v-1) //local style
       else
         s2:=copy(s,v,e-v);//online style as:  000-BCP-198 V=9.794(0.071)_B=10.162(0.08)_R=9.601(0.071)

       val(s2,result,err);
    end;
    if ((err<>0) or (v=0)) then
      memo2_message('Error reading comparison star magnitude. Could not find V= in ' +s);
  end;
end;


procedure Tform_aavso1.report_to_clipboard1Click(Sender: TObject);
var
    c,date_column  : integer;
    err,snr_str,airmass_str, delim,fnG,detype,baa_extra,magn_type,filter_used,settings,date_format,date_observation,
    abbrev_var_clean,abbrev_check_clean,abbrev_comp_clean,ensemble_str1,ensemble_str2,ensemble_str3,var_magn_str: string;
    stdev_valid,use_instr_magnitude : boolean;
    snr_value,err_by_snr,comp_magnitude, instr_mag_correction,var_magn  : double;
    PNG: TPortableNetworkGraphic;{FPC}

begin
  get_info;//update abbrev_var and others

  abbrev_var_clean:=clean_abbreviation(abbrev_var);
  abbrev_check_clean:=clean_abbreviation(abbrev_check);
  abbrev_comp_clean:=clean_abbreviation(abbrev_comp);
  store_vsp_stars(clean_abbreviation(abbrev_var_clean {short}),remove_sigma_end(abbrev_check),remove_sigma_end(abbrev_comp));


  if ((length(abbrev_var_clean)<1) or (column_var<0)) then
  begin
    abrv_variable1.color:=clred;
    exit;
  end
  else
    abrv_variable1.color:=cldefault;

  if ((length(abbrev_check)<1) or (column_check<0)) then
  begin
    abrv_check1.color:=clred;
    exit;
  end
  else
    abrv_check1.color:=cldefault;

  if ((abrv_comp1.enabled) and (length(abbrev_check)<1)) then
  begin
    abrv_comp1.color:=clred;
    exit;
  end
  else
    abrv_comp1.color:=cldefault;


  stdev_valid:=(photometry_stdev>0.0001);

  use_instr_magnitude:=pos('=',abbrev_comp)=0; //no additional correction with single comparison star

  delta_bv:=strtofloat2(form_aavso1.delta_bv1.text);
  magnitude_slope:=strtofloat2(form_aavso1.magnitude_slope1.text);


  delim:=delimiter1.text;
  if delim='tab' then delim:=#9;

  if baa_style1.checked then
  begin
    detype:='AAVSO EXT BAA V1.00';
    baa_extra:='#LOCATION='+sitelat+' '+sitelong+' '+siteelev+#13+#10+
               '#TELESCOPE='+TELESCOP+#13+#10+
               '#CAMERA='+instrum+#13+#10;
  end
  else
  begin
    detype:='Extended';
    baa_extra:='';
  end;
  if hjd1.Checked then
  begin
    date_format:='HJD';
    date_column:=P_jd_helio;
  end
  else
  begin
    date_format:='JD';
    date_column:=P_jd_mid;
  end;

  if stackmenu1.reference_database1.ItemIndex=0 then settings:=stackmenu1.reference_database1.text+' '+uppercase(name_database)
  else
    settings:=stackmenu1.reference_database1.text;
  settings:=settings+', aperture='+stackmenu1.flux_aperture1.text+' HFD, annulus='+stackmenu1.annulus_radius1.text+' HFD';

  aavso_report:= '#TYPE='+detype+#13+#10+
                 '#OBSCODE='+obscode+#13+#10+
                 '#SOFTWARE=ASTAP, v'+astap_version+' ('+settings+ ')'+#13+#10+
                 '#DELIM='+delimiter1.text+#13+#10+
                 '#DATE='+date_format+#13+#10+
                 '#OBSTYPE=CCD'+#13+#10+
                 '#COMMENTS=The CMAG and KMAG instrumental magnitudes are calibrated using an ensemble of transformed Gaia magnitudes. If the CMAG star is specified then the var magnitude is corrected using the difference between CMAG instrumental magnitude and documented magnitude.'+#13+#10+
                  baa_extra+
                 '#'+#13+#10+
                 '#NAME'+delim+'DATE'+delim+'MAG'+delim+'MERR'+delim+'FILT'+delim+'TRANS'+delim+'MTYPE'+delim+'CNAME'+delim+'CMAG'+delim+'KNAME'+delim+'KMAG'+delim+'AIRMASS'+delim+'GROUP'+delim+'CHART'+delim+'NOTES'+#13+#10;

   with stackmenu1 do
   for c:=0 to listview7.items.count-1 do
   begin
     if listview7.Items.item[c].checked then
     begin
       snr_str:=listview7.Items.item[c].subitems.Strings[column_var+1 {P_snr}];
       if snr_str<>'' then  snr_value:=strtoint(snr_str) else snr_value:=0;

       if snr_value>0 then
       begin
         err_by_snr:=2 {1.087}/snr_value;

         if  stdev_valid=false then
           str(err_by_snr:1:4,err){SNR method.Note SNR is in ADU but for snr above 20 error is small. For e-/adu<1 error becomes larger. Factor 2 is a practical factor}
         else
           str(math.max(err_by_snr, photometry_stdev):1:4,err);{standard deviation of Check  star. Use math.min in case the different passbands are used and magnitude chekc stars swings heavilly}

         airmass_str:=listview7.Items.item[c].subitems.Strings[P_airmass];
         if airmass_str='' then  airmass_str:='na' else airmass_str:=stringreplace(airmass_str,',','.',[]);

         if snr_str<>'' then
         begin
           if filter1.itemindex=0 then
             filter_used:=listview7.Items.item[c].subitems.Strings[P_filter] //take from header
           else
             filter_used:=copy(filter1.text,1,2);//manual input

           var_magn:=strtofloat2(listview7.Items.item[c].subitems.Strings[column_var{P_magn1}]);

           ensemble_str2:='na';
           ensemble_str1:='ENSEMBLE';
           if stackmenu1.reference_database1.itemindex=0 then //local database
           if pos('v',name_database)>0 then magn_type:=' transformed to Johnson-V. ' else magn_type:=' using BM magnitude. '
           else  //online database
             magn_type:=' transformed '+stackmenu1.reference_database1.text;

           ensemble_str3:='Ensemble of Gaia DR3 stars ('+ magn_type+')';

           if use_instr_magnitude=false then //Mode magnitude relative to comp star
           begin
             comp_magnitude:=get_comp_magnitude(listview7.Items.item[c].SubitemImages[P_filter]{filter icon nr},column_comp, abbrev_comp);//  retrieve the correct magnitude at passband used from the abbrev_comp string
             if  comp_magnitude<>0 then
             begin
                 ensemble_str1:=abbrev_comp_clean;
                 instr_mag_correction:=comp_magnitude-strtofloat2(stackmenu1.listview7.Items.item[c].subitems.Strings[column_comp{P_magn3}]);
                 var_magn:=var_magn +instr_mag_correction;
                 ensemble_str2:=stringreplace(listview7.Items.item[c].subitems.Strings[column_comp{P_magn3}],',','.',[]);
                 ensemble_str3:='Instr magn correction using CMAG is '+ floattostr4(instr_mag_correction);
             end;
           end;



           var_magn:=var_magn + delta_bv*magnitude_slope; //apply slope correction;//use magnitude of comparison star if specified and apply slope correctio
           str(var_magn:0:3,var_magn_str);

           if ListView7.Items.item[c].SubitemImages[P_calibration]<>ListView7.Items.item[c].SubitemImages[P_filter] then ensemble_str3:=ensemble_str3+'  WARNING INCOMPATIBLE FILTER AND DATABASE PASSBAND!';

           aavso_report:= aavso_report+ abbrev_var_clean + delim +
                          StringReplace(listview7.Items.item[c].subitems.Strings[date_column],',','.',[])+delim+
                          var_magn_str+delim+
                          err+
                          delim+filter_used+delim+
                          'NO'+delim+
                          'STD'+delim+
                          ensemble_str1+delim+
                          ensemble_str2+delim+
                          abbrev_check_clean+delim+
                          stringreplace(listview7.Items.item[c].subitems.Strings[column_check{P_magn2}],',','.',[])+delim+
                          airmass_str+delim+
                          'na'+delim+ {group}
                          'na'+delim+
                          ensemble_str3+#13+#10;

           date_observation:=copy(listview7.Items.item[c].subitems.Strings[P_date],1,10);
         end;

       end;
     end;
   end;

  to_clipboard:=(sender=report_to_clipboard1); {report to clipboard of file}


  memo2_message(aavso_report);
  if to_clipboard then
    Clipboard.AsText:=aavso_report
  else
  begin
    savedialog1.filename:=abrv_variable1.text+'_'+date_observation+'_report.txt';
    savedialog1.initialdir:=ExtractFilePath(filename2);
    savedialog1.Filter := '(*.txt)|*.txt';
    if savedialog1.execute then
    begin
      log_to_file2(savedialog1.filename, aavso_report);
      png:= TPortableNetworkGraphic.Create;   {FPC}
      try
        PNG.Assign(Image_photometry1.Picture.Graphic);    //Convert data into png
        fnG:=ChangeFileExt(savedialog1.filename,'_graph.png');
        PNG.SaveToFile(fnG);
        finally
         PNG.Free;
      end;
      memo2_message('AAVSO report written to: '+savedialog1.filename + '   and   '+fnG);
    end;
  end;
  save_settings2; {for aavso settings}

  form_aavso1.close;   {transfer variables. Normally this form is not loaded}
  mainwindow.setfocus;
end;


procedure Tform_aavso1.Image_photometry1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  w2,h2 :integer;
begin
  if jd_min=0 then exit;
  w2:=image_photometry1.width;
  h2:=image_photometry1.height;
  form_aavso1.caption:= floattostrF(jd_min+(jd_max-jd_min)*((x*w/w2)-bspace)/(w-bspace*2),ffFixed,12,5)+', '+floattostrf(magn_min+(magn_max-magn_min)*(((y*h/h2))-bspace)/(h-bspace*2),ffFixed,5,3);
end;

procedure Tform_aavso1.MenuItem1Click(Sender: TObject);
begin
    Clipboard.Assign(Image_photometry1.Picture.Bitmap);
end;

procedure Tform_aavso1.abrv_check1Change(Sender: TObject);
begin
  plot_graph;
end;


function find_sd_star(column: integer) : double;//calculate the standard deviation of a variable
var
   count, c,count_checked: integer;
   magn,madCheck, medianCheck : double;
   dum: string;
   listMagnitudes : array of double;
begin
  count:=0;
  count_checked:=0;
  setlength(listMagnitudes,stackmenu1.listview7.items.count);//list with magnitudes check star

  with stackmenu1 do
  for c:=0 to listview7.items.count-1 do {retrieve data from listview}
  begin
    if listview7.Items.item[c].checked then
    begin
      dum:=(listview7.Items.item[c].subitems.Strings[column]);{var star}
      if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then magn:=strtofloat(dum) else magn:=0;
      if magn<>0 then
      begin
        listMagnitudes[count]:= magn;
        inc(count);
      end;
      inc(count_checked);
    end;
  end;
  if count>count_checked/2 then //at least 50% valid measurements Not 50% because it will not report if two filter are in the list
  begin
    mad_median(listMagnitudes, count{counter},{var}madCheck, medianCheck);
    result:=1.4826 * madCheck;
  end
  else
    result:=0;
end;



procedure Tform_aavso1.abrv_check1DropDown(Sender: TObject);
var
  i,j,count: integer;
  abrv,old,filter,sdstr    : string;
  starinfo : array of Tstarinfo;
   measure_any : boolean;
begin

  with tcombobox(sender) do
  begin

    items.clear;
    color:=cldefault;

    if stackmenu1.measuring_method1.itemindex=0 then //maual star selection
    begin
      if tcombobox(sender)=abrv_check1 then
      begin
        items.add(mainwindow.shape_check1.HINT);
        //items.add(abbrev_check);//the last name
        items.add(name_check_IAU);// created from position
      end
      else
     // if gaia_comparison1.checked=false then
      if tcombobox(sender)=abrv_comp1 then
      begin
        items.add(stackmenu1.reference_database1.text);
        items.add(mainwindow.shape_comp1.HINT);
        //items.add(abbrev_comp);//the last name
        items.add(name_comp_IAU);// created from position
      end;
    end
    else
    begin //measure all method
      if tcombobox(sender)=abrv_comp1 then
        items.add(stackmenu1.reference_database1.text); //add the database as comparison
    end;

    setlength(starinfo,p_nr-p_nr_norm);
    count:=0;

    measure_any:=stackmenu1.measuring_method1.itemindex=2;


    for i:=p_nr_norm+1+1 to p_nr do
      if odd(i) then //not snr column
      begin
        abrv:=stackmenu1.listview7.Column[i].Caption;
        if ((measure_any) or (copy(abrv,1,4)='000-')) then //check star
          if ((filter='') or (pos(filter,abrv)>0)) then
          begin
            with tcombobox(sender) do
            begin
              {$ifdef mswindows}
              {begin adjust width automatically}
              if (Canvas.TextWidth(abrv)> ItemWidth) then
              ItemWidth:=2*Canvas.TextWidth((abrv));{adjust dropdown with if required}
              Perform(352{windows,CB_SETDROPPEDWIDTH}, ItemWidth, 0);
              {end adjust width automatically}
              {$else} {unix}
              ItemWidth:=form_aavso1.Canvas.TextWidth((abrv));{works only second time};
              {$endif}
              starinfo[count].str:=abrv;//store in an array
              starinfo[count].x:=find_sd_star(i-1);
              inc(count);
            end;
          end;
      end;

      if count>0 then
      begin
        QuickSort_records(starinfo,0,count-1) ;{ Fast quick sort. Sorts elements in the array A containing records with indices between lo and hi}
        for i:=0 to count-1  do  //display in ascending order
          if starinfo[i].x<>0 then items.add(starinfo[i].str+ ', σ='+floattostrF(starinfo[i].x,ffFixed,5,3));//add including standard deviation
      end;
  end;

end;



function find_correct_check_column : integer;
var
  i: integer;
  name_check : string;
begin
  if stackmenu1.measuring_method1.itemindex=0  then //manual mode
  begin
    result:=P_magn2;
    exit
  end;

  result:=-99;//assume failure
  name_check:=remove_sigma_end(form_aavso1.abrv_check1.text); //remove ', σ=' at the end
  if name_check='' then  exit;

  for i:=p_nr_norm+1 to p_nr do
    if ((odd(i)) and (pos(name_check,stackmenu1.listview7.Column[i].Caption)>0)) then
    begin
      result:=i-1;
      exit;
    end;
end;

function find_correct_comp_column : integer;
var
  i: integer;
  name_comp : string;
begin
  if stackmenu1.measuring_method1.itemindex=0  then //manual mode
  begin
    result:=P_magn3;
    exit
  end;

  result:=-99;//assume failure
  name_comp:=remove_sigma_end(form_aavso1.abrv_comp1.text);
  if name_comp='' then  exit;

  for i:=p_nr_norm+1 to p_nr do
    if ((odd(i)) and (pos(name_comp,stackmenu1.listview7.Column[i].Caption)>0)) then
    begin
      result:=i-1;
      exit;
    end;
end;



function find_correct_var_column : integer;
var
  i,cc     : integer;
  name_var : string;
begin
  if stackmenu1.measuring_method1.itemindex=0  then //manual mode
  begin
    result:=P_magn1;
    exit
  end;

  result:=-99;//assume failure
  name_var:=remove_sigma_end(form_aavso1.abrv_variable1.text);
  if name_var='' then  exit;

  for i:=p_nr_norm+1 to p_nr do
  begin
    if ((odd(i)) and (pos(name_var,stackmenu1.listview7.Column[i].Caption)>0)) then
    begin
      result:=i-1;
      exit;
    end;
  end;
end;


procedure find_best_check_star(combobox : tcombobox; do_not_use : string);
var
  magn,magn_avgV,magn_minV,mag_var,magC,diff,delt,magn_avgC : double;
  c,i,counterV,counter: integer;
  abrv, abrv_selected,dum: string;
begin
  magn_avgV:=0;
  magn_minV:=99;
  column_var:=find_correct_var_column;
  if column_var<0 then exit; //no var specified yet
  counterV:=0;

  //find average  magnitude Variable
  with stackmenu1 do
  begin
  for c:=0 to listview7.items.count-1 do {retrieve data from listview}
    begin
      if listview7.Items.item[c].checked then
      begin
        dum:=(listview7.Items.item[c].subitems.Strings[column_var]);{var star}
        if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then
        begin
          magn:=strtofloat(dum);
          magn_avgV:=magn_avgV+magn;
          counterV:=counterV+1;
          magn_minV:=min(magn_minV,magn);
        end;
      end;
    end;
    if counterV=0 then exit;
    magn_avgV:=magn_avgV/counterV;

    abrv_selected:='';
    diff:=99;
    for i:=p_nr_norm+1+1 to p_nr do
    begin
      if odd(i) then //not snr column
      begin
         abrv:=stackmenu1.listview7.Column[i].Caption;
         if ((pos('000',abrv)>0) and (abrv<>do_not_use)) then //check star and not is use already
         begin
           magn_avgC:=0;
           counter:=0;
           for c:=0 to listview7.items.count-1 do {retrieve data from listview}
           begin
             if listview7.Items.item[c].checked then
             begin
               dum:=(listview7.Items.item[c].subitems.Strings[i-1]);{check star}
               if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then
               begin
                 magC:=strtofloat(dum);
                 magn_avgC:=magn_avgC+magC;
                 counter:=counter+1;
               end;
             end;
           end;
           if counter<counterV then magn_avgC:=-10 //skip value. Not enough measurements
           else
           magn_avgC:=magn_avgC/counter; //average magnitude check star

           delt:=abs(magn_avgV- magn_avgC);
           if ((magC+1.0>=magn_minV) and (delt<diff)) then //max magn 1.0 brighter
           begin
             abrv_selected:=abrv;
             diff:=delt; //new check star found with close magnitude
           end;
         end;//is a check star
      end;//odd column
    end;//check star loop
  end;//with stackmenu1

  combobox.text:=abrv_selected;

end;


procedure Tform_aavso1.abrv_variable1Change(Sender: TObject);
begin
   if stackmenu1.measuring_method1.itemindex>0  then
   retrieve_vsp_stars(clean_abbreviation(abrv_variable1.text));
   plot_graph;
end;


procedure Tform_aavso1.abrv_variable1DropDown(Sender: TObject);
var
  i,j,count          : integer;
  abrv,sdstr         : string;
  starinfo : array of Tstarinfo;

begin
//  for filtering dropdown set
//    AutoComplete := true;
//    AutoDropDown := true;
  abrv_variable1.items.clear;
  if stackmenu1.measuring_method1.itemindex=0  then
  begin
    abrv_variable1.items.add(mainwindow.shape_var1.HINT);
    abrv_variable1.items.add(object_name);//from header
    abrv_variable1.items.add(abbreviation_var_IAU);
    abrv_variable1.items.add(abbrev_var);
  end;


  setlength(starinfo,p_nr-p_nr_norm);
  count:=0;

  with tcombobox(sender) do
  begin
  for i:=p_nr_norm+1 to p_nr do
    if odd(i) then // not a snr column
    begin
      abrv:=stackmenu1.listview7.Column[i].Caption;
      if copy(abrv,1,4)<>'000-' then //Not a check star
      begin
        {$ifdef mswindows}
        {begin adjust width automatically}
        if (Canvas.TextWidth(abrv)> ItemWidth) then
        ItemWidth:=2*Canvas.TextWidth((abrv));{adjust dropdown with if required}
        Perform(352{windows,CB_SETDROPPEDWIDTH}, ItemWidth, 0);
        {end adjust width automatically}
        {$else} {unix}
        ItemWidth:=form_aavso1.Canvas.TextWidth((abrv));{works only second time};
        {$endif}
        starinfo[count].str:=abrv;//store in an array
        starinfo[count].x:=find_sd_star(i-1);
        inc(count);
      end;
    end;

    if count>0 then
    begin
      QuickSort_records(starinfo,0,count-1) ;{ Fast quick sort. Sorts elements in the array A containing records with indices between lo and hi}
      for i:= count-1 downto 0 do  //display in decending order
        if starinfo[i].x<>0 then items.add(starinfo[i].str+ ', σ='+floattostrF(starinfo[i].x,ffFixed,5,3));//add including standard deviation

      memo2_message('Variables are sorted on standard deviation in descending order. The standard deviation is added to the variable abbreviation');
    end;
  end;
end;



procedure Tform_aavso1.FormResize(Sender: TObject);
begin
  plot_graph;
end;

procedure Tform_aavso1.hjd1Change(Sender: TObject);
begin
  plot_graph;
end;

procedure Tform_aavso1.delta_bv2Change(Sender: TObject);
begin
  plot_graph;
end;


procedure Tform_aavso1.FormCreate(Sender: TObject);
begin
  measure_all_mode1.visible:=p_nr>p_nr_norm;
end;


procedure retrieve_ra_dec(columnr: integer; out ra,dec:double);//retrieve from database arrays using the .tag
begin
  try
  if stackmenu1.listview7.column[columnr+1].tag=0 then
  begin
    ra:=variable_list[stackmenu1.listview7.column[columnr].tag].ra;
    dec:=variable_list[stackmenu1.listview7.column[columnr].tag].dec;
  end
  else
  if stackmenu1.listview7.column[columnr+1].tag=1 then
  begin
    ra:=vsx[stackmenu1.listview7.column[columnr].tag].ra;
    dec:=vsx[stackmenu1.listview7.column[columnr].tag].dec;
  end
  else
  if stackmenu1.listview7.column[columnr+1].tag=2 then
  begin
    ra:=vsp[stackmenu1.listview7.column[columnr].tag].ra;
    dec:=vsp[stackmenu1.listview7.column[columnr].tag].dec
  end;
  except;
  end;
end;

procedure annotate_star_of_column(columnV,columnCheck,columnComp: integer);
var
  ra,dec : double;
begin
  // RA, DEC position is stored as integers in tag   [0..864000], DEC[-324000..324000]

  try
  if columnV>0 then //valid
  begin
    retrieve_ra_dec(columnV,shape_var2_ra,shape_var2_dec);
    mainwindow.shape_var2.visible:=true;
    place_marker_radec(mainwindow.shape_var2,shape_var2_ra,shape_var2_dec);{place ra,dec marker in image}
  end;

  if columnCheck>0 then //valid
  begin
   retrieve_ra_dec(columnCheck,shape_check2_ra,shape_check2_dec);
    mainwindow.shape_check2.visible:=true;
    place_marker_radec(mainwindow.shape_check2,shape_check2_ra,shape_check2_dec);{place ra,dec marker in image}
  end;

  if columnComp>0 then //valid
  begin
    retrieve_ra_dec(columnComp,shape_comp2_ra,shape_comp2_dec);
    mainwindow.shape_comp2.visible:=true;
    place_marker_radec(mainwindow.shape_comp2,shape_comp2_ra,shape_comp2_dec);{place ra,dec marker in image}
  end;

  except
  end;

end;


procedure plot_graph; {plot curve}
var
  x1,y1,c,textp1,textp2,textp3,textp4, nrmarkX, nrmarkY,wtext,date_column,count : integer;
  scale,range,madCheck, medianCheck     : double;
  text1,text2, date_format,firstfilter  : string;
  bmp: TBitmap;
  dum:string;
  data : array of array of double;
  listcheck : array of double;
const
  len=3;

  procedure plot_point(x,y,tolerance:integer);
  begin
    with form_aavso1.Image_photometry1 do
     begin
       if ((x>0) and (y>0) and (x<=w) and( y<=h)) then
       begin
         bmp.canvas.Ellipse(x-len,y-len,x+1+len,y+1+len);{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}

         if tolerance>0 then
         begin
           bmp.canvas.moveto(x,y-tolerance);
           bmp.canvas.lineto(x,y+tolerance);

           bmp.canvas.moveto(x-len+1,y-tolerance);
           bmp.canvas.lineto(x+len,y-tolerance);

           bmp.canvas.moveto(x-len+1,y+tolerance);
           bmp.canvas.lineto(x+len,y+tolerance);
         end;
       end;
     end;
  end;
begin
  if ((head.naxis=0) or (form_aavso1=nil))  then exit;

  jd_min:=+9999999;
  jd_max:=-9999999 ;
  magn_min:=99;
  magn_max:=0;

  if form_aavso1.hjd1.Checked then
  begin
    date_format:='HJD';
    date_column:=P_jd_helio;
  end
  else
  begin
    date_format:='JD (mid)';
    date_column:=P_jd_mid;
  end;

  w:=max(form_aavso1.Image_photometry1.width,(len*2)*stackmenu1.listview7.items.count);{make graph large enough for all points}
  h:=max(100,form_aavso1.Image_photometry1.height);
  bspace:=2*mainwindow.image1.Canvas.textheight('T');{{border space graph. Also for 4k with "make everything bigger"}
  wtext:=mainwindow.image1.Canvas.textwidth('12.3456');

  column_var:=find_correct_var_column;
  column_check:=find_correct_check_column;
  column_comp:=find_correct_comp_column;

  if ((column_var<0) and (column_check<0)) then exit;//no var or check star specified


  annotate_star_of_column(column_var,column_check,column_comp);

  photometry_stdev:=0;
  setlength(data,4, stackmenu1.listview7.items.count);
  setlength(listcheck,length(data[0]));//list with magnitudes check star
  count:=0;
  firstFilter:='';
  with stackmenu1 do
  for c:=0 to listview7.items.count-1 do {retrieve data from listview}
  begin
    if listview7.Items.item[c].checked then
    begin
      dum:=(listview7.Items.item[c].subitems.Strings[date_column]);
      if dum<>'' then  data[0,c]:=strtofloat(dum) else data[0,c]:=0;
      if data[0,c]<>0 then
      begin
        jd_max:=max(jd_max,data[0,c]);
        jd_min:=min(jd_min,data[0,c]);
      end;

      if  column_var>0 then
      begin
        dum:=listview7.Items.item[c].subitems.Strings[column_var];{var star}
        if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then  data[1,c]:=strtofloat(dum) else data[1,c]:=0;
        if data[1,c]<>0 then
        begin
          magn_max:=max(magn_max,data[1,c]);
          magn_min:=min(magn_min,data[1,c]);
        end;
      end;

      if column_check>0 then
      begin
        dum:=(listview7.Items.item[c].subitems.Strings[column_check]);{chk star}
        if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then data[2,c]:=strtofloat(dum) else data[2,c]:=0;
        if data[2,c]<>0 then
        begin
          magn_max:=max(magn_max,data[2,c]);
          magn_min:=min(magn_min,data[2,c]);
          if firstfilter='' then firstfilter:=listview7.Items.item[c].subitems.Strings[P_filter];
          if firstfilter=listview7.Items.item[c].subitems.Strings[P_filter] then //calculate standard deviation for one colour only. Otherwise big jump spoils the measurement
          begin
            listcheck[count]:= data[2,c];
            inc(count);
          end;
        end;
      end;

      if column_comp>0 then
      begin
        dum:=(listview7.Items.item[c].subitems.Strings[column_comp]);{comparison star}
        if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then data[3,c]:=strtofloat(dum) else data[3,c]:=0;
        if data[3,c]<>0 then
        begin
          magn_max:=max(magn_max,data[3,c]);
          magn_min:=min(magn_min,data[3,c]);
        end;
      end;
    end;

  end;

  if magn_min>magn_max then exit; //no info

  magn_min:=trunc(magn_min*100)/100; {add some rounding}
  magn_max:=trunc(magn_max*100)/100;
  if magn_max-magn_min<0.3 then begin magn_max:=0.15+(magn_max+magn_min)/2; magn_min:=-0.15+(magn_max+magn_min)/2;;end;//minimum range

  if count>0 then
  begin
    mad_median(listcheck, count{counter},{var}madCheck, medianCheck);
    photometry_stdev:=1.4826 * madCheck;
  end
  else
    photometry_stdev:=0;


  range:=magn_max-magn_min;
  if range<-98 then
  begin
    form_aavso1.report_error1.visible:=true;
    exit;
  end
  else
  form_aavso1.report_error1.visible:=false;

  magn_max:=magn_max + range*0.05;  {faint star, bottom}
  magn_min:=magn_min - range*0.05; {bright star, top}

  with form_aavso1.Image_photometry1 do
  begin
    bmp:=TBitmap.Create;
    bmp.PixelFormat:=pf24bit;

    bmp.SetSize(w,h);

    bmp.Canvas.brush.Style:=bsclear;

    bmp.canvas.brush.color:=clmenu;
    bmp.canvas.rectangle(-1,-1, w+1, h+1);{background}

    bmp.Canvas.Pen.Color := clmenutext;
    bmp.Canvas.brush.color :=clmenu;
    bmp.Canvas.Font.Color := clmenutext;

    bmp.canvas.moveto(w,h-bspace+5);
    bmp.canvas.lineto(wtext-5,h-bspace+5);{x line}
    bmp.canvas.lineto(wtext-5,bspace);{y line}

    bmp.canvas.font.style:=[fsbold];
    bmp.canvas.textout(5,bspace div 2,'Magn');
    bmp.canvas.textout(w-4*bspace,h-(bspace div 2),date_format{JD (mid) or HJD});
    bmp.canvas.font.style:=[];

    text1:='Var ('+form_aavso1.abrv_variable1.text+')';
    textp1:=10+wtext;
    bmp.canvas.textout(textp1,len*3,text1);

    textp2:=textp1+40+bmp.canvas.textwidth(text1);
    text2:='Chk ('+form_aavso1.abrv_check1.text+')';
    bmp.canvas.textout(textp2,len*3,text2);

    textp3:=textp2+40+bmp.canvas.textwidth(text2);
    bmp.canvas.textout(textp3,len*3,'Comp');

    textp4:=textp3+100;

    if object_name<>'' then
      bmp.canvas.textout(textp4,len*3,object_name)
    else
      bmp.canvas.textout(textp4,len*3,ExtractFilePath(filename2));

    nrmarkX:=trunc(w*5/1000);
    if nrmarkX>0 then
    for c:=0 to nrmarkX do {markers x line}
    begin
      x1:=wtext+round((w-bspace*2)*c/nrmarkX); {x scale has bspace pixels left and right space}
      y1:=h-bspace+5;
      bmp.canvas.moveto(x1,y1);
      bmp.canvas.lineto(x1,y1+5);
      bmp.canvas.textout(x1,y1+5,floattostrf(jd_min+(jd_max-jd_min)*c/nrmarkX,ffFixed,12,5));
    end;

    nrmarkY:=trunc(h*5/400);
    if nrmarkY>0 then
    for c:=0 to nrmarkY do {markers y line}
    begin
      x1:=wtext-5;
      y1:= round(bspace+(h-bspace*2)*c/nrmarkY); {y scale has bspace pixels below and above space}
      bmp.canvas.moveto(x1,y1);
      bmp.canvas.lineto(x1-5,y1);
      bmp.canvas.textout(5,y1,floattostrF(magn_min+(magn_max-magn_min)*c/nrmarkY,ffFixed,5,3));
    end;


    if magn_max>98 then exit;

    scale:=(h-(bspace*2))/(magn_max-magn_min);{pixel per magnitudes}

    bmp.Canvas.Pen.Color := clGreen;
    bmp.Canvas.brush.color :=clGreen;
    plot_point(textp2,len*3,0);

    if jd_max=jd_min then jd_min:=jd_min-1; {prevent run time errors for one image where jd_max-jd_min}

    for c:=0 to length(data[0])-1 do
      if data[0,c]<>0 then //valid JD
        plot_point(wtext+round((w-bspace*2)*(data[0,c]-jd_min)/(jd_max-jd_min)), round(bspace+(h-bspace*2)*(data[2,c]-magn_min)/(magn_max-magn_min)   ),round(scale*photometry_stdev*2.5)); {chk}

    bmp.Canvas.Pen.Color := clBlue;
    bmp.Canvas.brush.color :=clBlue;
    plot_point(textp3,len*3,0);
    for c:=0 to length(data[0])-1 do
      if data[0,c]<>0 then //valid JD
        plot_point(wtext+round((w-bspace*2)*(data[0,c]-jd_min)/(jd_max-jd_min)), round(bspace+(h-bspace*2)*(data[3,c]-magn_min)/(magn_max-magn_min)   ),0); {3}

    bmp.Canvas.Pen.Color := clRed;
    bmp.Canvas.brush.color :=clRed;
    plot_point(textp1,len*3,0);

    for c:=0 to length(data[0])-1 do
      if data[0,c]<>0 then //valid JD
        plot_point( wtext+round((w-bspace*2)*(data[0,c]-jd_min)/(jd_max-jd_min)), round(bspace+(h-bspace*2)*(data[1,c]-magn_min)/(magn_max-magn_min)   ),round(scale*photometry_stdev*2.5)); {var}


    Picture.Bitmap.SetSize(w,h);
    Picture.Bitmap.Canvas.Draw(0,0, bmp);// move bmp to image picture
    bmp.Free;
  end;
  data:=nil;
end;


procedure Tform_aavso1.FormClose(Sender: TObject; var CloseAction: TCloseAction );
begin
  get_info; {form_aavso1.release will be done in the routine calling the form}

  closeaction:=caFree; {delete form}
  form_aavso1:=nil;
  mainwindow.shape_marker3.visible:=false;
  mainwindow.shape_marker4.visible:=false;

end;


procedure Tform_aavso1.FormShow(Sender: TObject);
var
  dum,object_name2,abrv : string;
  i : integer;
begin
  obscode1.text:=obscode;

  if stackmenu1.measuring_method1.itemindex=0 then
  begin
    abrv_variable1.text:=mainwindow.Shape_var1.HINT;
    abrv_check1.text:=mainwindow.shape_check1.HINT ;
    abrv_comp1.text:=mainwindow.shape_comp1.HINT ;

  end
  else
  begin //find the variable of interest for header object
    object_name2:=stringreplace(object_name,' ','_',[]);//object_name from fits header
    for i:=p_nr_norm+1 to p_nr do
      if odd(i) then // not a snr column
      begin
        abrv:=stackmenu1.listview7.Column[i].Caption;
        if  Comparetext(object_name2,copy(abrv,1,length(object_name2)))=0 then
        begin
         abrv_variable1.text:=abrv;
         break;
        end;
      end;
  end;

  delimiter1.itemindex:=delim_pos;
  baa_style1.checked:=baa_style;
  hjd1.checked:=hjd_date;
//  if stackmenu1.reference_database1.itemindex=0 then
//    abrv_comp1.Text:=name_database
//  else
//  abrv_comp1.Text:=stackmenu1.reference_database1.text;

  filter1.itemindex:=aavso_filter_index;

  form_aavso1.delta_bv1.text:=floattostrF(delta_bv,ffFixed,5,3);
  form_aavso1.magnitude_slope1.text:=floattostrF(magnitude_slope,ffFixed,5,3);

  aavso_report:='';

  suggest_check1.Enabled:=stackmenu1.measuring_method1.itemindex>0;
  suggest_comp1.Enabled:=stackmenu1.measuring_method1.itemindex>0;
  plot_graph;
end;

procedure Tform_aavso1.suggest_check1Change(Sender: TObject);
begin
  form_aavso1.abrv_variable1Change(nil);
end;

procedure Tform_aavso1.suggest_check1Click(Sender: TObject);
begin
  find_best_check_star(abrv_check1,abrv_comp1.text);
  plot_graph;
end;

procedure Tform_aavso1.suggest_comp1Click(Sender: TObject);
begin
  find_best_check_star(abrv_comp1,abrv_check1.text);
  plot_graph;

end;


end.

