unit unit_aavso;
{Copyright (C) 2021, 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }
{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, math,
  clipbrd, ExtCtrls, Menus, Buttons, CheckLst,strutils,
  astap_main;

type

  { Tform_aavso1 }

  Tform_aavso1 = class(TForm)
    abrv_check1: TComboBox;
    baa_style1: TCheckBox;
    abrv_comp1: TCheckListBox;
    b_v_variable1: TEdit;
    apply_transformation1: TCheckBox;
    test_mode1: TCheckBox;
    label13: TLabel;
    sigma_mzero1: TLabel;
    v_r_variable1: TEdit;
    ensemble_database1: TCheckBox;
    label14: TLabel;
    obstype1: TComboBox;
    Label7: TLabel;
    sigma_check2: TLabel;
    sigma_check1: TLabel;
    sort_alphabetically1: TCheckBox;
    hjd1: TCheckBox;
    Image_photometry1: TImage;
    abbrv_variable1: TComboBox;
    name_variable2: TEdit;
    report_error1: TLabel;
    MenuItem1: TMenuItem;
    PopupMenu1: TPopupMenu;
    report_to_clipboard1: TButton;
    report_to_file1: TButton;
    delimiter1: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    Label8: TLabel;
    obscode1: TEdit;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    procedure abrv_comp1Change(Sender: TObject);
    procedure abbrv_comp1ItemClick(Sender: TObject; Index: integer);
    procedure abrv_comp1ClickCheck(Sender: TObject);
    procedure delta_bv2Change(Sender: TObject);
    procedure ensemble_database1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure hjd1Change(Sender: TObject);
    procedure Image_photometry1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure MenuItem1Click(Sender: TObject);
    procedure abrv_check1Change(Sender: TObject);
    procedure abbrv_variable1Change(Sender: TObject);
    procedure abbrv_variable1DropDown(Sender: TObject);
    procedure report_to_clipboard1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure sort_alphabetically1Change(Sender: TObject);
    procedure suggest_check1Change(Sender: TObject);
  private

  public

  end;

var
  form_aavso1: Tform_aavso1;

var
  obscode       : string='';
  abbrev_check : string='';
  abbrev_comp : Tstring_array;
  abbrev_var   : string='';
  delim_pos  : integer=0;
  to_clipboard  : boolean=true;
  baa_style  : boolean=false;
  sort_alphabetically: boolean=false;
  apply_transformation: boolean=false;
  hjd_date   : boolean=false;
  aavso_filter_index: integer=0;
  ensemble_database : boolean=true;
  obstype : integer=0;
  variable_selected: string='';

var
  aavso_report : string;
  used_vsp_stars: string='';

procedure plot_graph; {plot curve}
function find_sd_star(column: integer) : double;//calculate the standard deviation of a variable
function retrieve_comp_magnitude(filter,columnr: integer; s: string): double;//retrieve comp magnitude from the abbrv string or online VSP


implementation


{$R *.lfm}
uses //astap_main,
     unit_stack,
     unit_star_database,{for name_database only}
     unit_annotation,
     unit_transformation;//for variable_list


type
    Tstarinfo = record
                   x   : double;
                   str : string;
                 end;



var
  jd_min,jd_max,magn_min,magn_max : double;
  w,h,bspace,column_var,column_check,wtext  :integer;
  column_comps : Tinteger_array;


function floattostr3(x:double):string;
begin
  str(x:0:3,result);
end;


procedure calc_sd_and_mean(list: array of double; leng : integer; out sd,mean: double);// calculate sd and mean of an array of doubles}
var
  i : integer;
begin
  mean:=0;
  for i:=0 to leng-1 do
    mean:=mean+list[i];
  mean:=mean/leng;

  sd:=0;
  for i:=0 to leng-1 do
    sd:=sd+sqr(list[i]-mean);
  sd:=sqrt(sd/leng);
end;


procedure retrieve_vsp_stars(variablestar: string);//very simple database system
var
  i,j,k,L,m                    : integer;
  check_star,comp_star,all_comp : string ;
begin
  //Format:   'SS Cyg:000-BCP-306:000-BCP-142 000-BCP-174 000-BCP-183 000-BCP-261 ;SS And:000-BCP-206:000-BCP-242 000-BCP-274 000-BCP-283 000-BCP-161 ;......'
  //Var1:Check: Comp1 Comp2 Comp3 ;Var2:Check: Comp1 Comp2 ;....
  i:=pos(variablestar, used_vsp_stars);
  if i<>0 then //already available
  begin
    j:=posex('|',used_vsp_stars,i+1); //: between var and check
    k:=posex('|',used_vsp_stars,j+1); //: between check  and comp stars
    L:=posex(';',used_vsp_stars,j+1); //; is the end of the entry


    check_star:=copy(used_vsp_stars,j+1,k-j-1);
    all_comp:=copy(used_vsp_stars,k+1,L-k-1);//all comp stars

    with form_aavso1 do   //find the check star in abrv_check1
      for i:=0 to abrv_check1.items.count-1 do
      begin
        if pos(copy(abrv_check1.items[i],1,11),check_star)>0 then
        begin
          abrv_check1.itemindex:=i;
          break;
        end;
      end;

    //split all_comp stars
    k:=0;
    with form_aavso1 do   //find the comp star in abrv_comp1
    begin
      repeat
        m:=posex('|',all_comp,k+1);
        if m<>0 then
        begin
          comp_star:=copy(all_comp,k+1,m-k-1);
          k:=m;
        end
        else  //last control char should be ";"
          comp_star:=copy(all_comp,k+1,999);//last entry

        for i:=0 to abrv_comp1.items.count-1 do
        begin
          if pos(copy(abrv_comp1.items[i],1,11),comp_star)>0 then
          begin
            abrv_comp1.checked[i]:=true;
          end;
        end;
      until m=0;
    end;
  end
  else
  begin
    form_aavso1.abrv_check1.text:='';
  end;
end;


procedure store_vsp_stars(variablestar, checkstar, compstars : string); //simple database in settings key used_vsp_stars
var
   i,j: integer;
begin
  //Format:   'SS Cyg:000-BCP-306:000-BCP-142;SS And:000-BCP-206:000-BCP-242;......'
  //           Var1:Check1:Comp1;Var2:Check2:Comp2A:Comp2B;....
  if length(variablestar)=0 then exit;
  i:=pos(variablestar, used_vsp_stars);
  if i<>0 then //already available
  begin
    j:=posex(';',used_vsp_stars,i); //find end of entry
    delete(used_vsp_stars,i,j-i+1); //delete entry
  end;
  used_vsp_stars:=used_vsp_stars+  variablestar+'|'+checkstar+'|'+compstars+';';
  if length(used_vsp_stars)>10000 then used_vsp_stars:=copy(used_vsp_stars,100,10999);//limit size. Throw oldest part away.
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
    abbrev_var:=remove_sigma_end(abbrv_variable1.text);
    abbrev_check:=abrv_check1.text;
    delim_pos:=delimiter1.itemindex;
    baa_style:=baa_style1.checked;
    sort_alphabetically:=sort_alphabetically1.checked;
    apply_transformation:=apply_transformation1.checked;

    hjd_date:=hjd1.checked;
    ensemble_database:=ensemble_database1.checked;
    obstype:=obstype1.ItemIndex;
    variable_selected:=abbrv_variable1.text;
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


function retrieve_comp_magnitude(filter,columnr: integer; s: string): double;//retrieve comp magnitude from the abbrv string or online VSP
var
  v,e,err,b,theindex,source  : integer;
  s2 : string;
  Bmagnitude : double;
begin
  result:=-99;
  if columnr<0 then
    exit;


  if ((stackmenu1.measuring_method1.itemindex=0) {manual star selection} or (variable_list=nil){should not happen})  then
    source:=0 //mode manual star selection. Extract magnitude from from annotation text
  else
  begin

    theindex:=stackmenu1.listview7.column[columnr+1].tag; //Caption position is always one position higher then data
    source:=variable_list[theindex].source;//local, vsp,vsx
  end;

  if source=2 then //online vsp list
  begin
    if ((filter=-1) or (filter=1)) then //V
      result:=strtofloat1(vsp[variable_list[theindex].index].Vmag)
    else
    if ((filter=0) or (filter =24)) then  //R or Cousins red
      result:=strtofloat1(vsp[variable_list[theindex].index].Rmag)
    else
    if filter=2 then  //Blue
      result:=strtofloat1(vsp[variable_list[theindex].index].Bmag)
    else
    if filter=28 then //I magnitude
      result:=strtofloat1(vsp[variable_list[theindex].index].Imag)
    else
    if filter=21 then  //SDSS-i
      result:=strtofloat1(vsp[variable_list[theindex].index].SImag)
    else
    if filter=22 then //SDDS=r
      result:=strtofloat1(vsp[variable_list[theindex].index].SRmag)
    else
    if filter=23 then //SDDS=g
      result:=strtofloat1(vsp[variable_list[theindex].index].SGmag);

  end
  else
  if source=0 then //extract from annotation, local database or manual
  begin
    if ((filter=-1) or (filter=1)) then //local variable
    begin //V magnitude
      v:= posex('V=',uppercase(s),4);
      if v>0 then
      begin
         v:=v+2;
         e:= posex('(',s,v);
         if s[e-1]='_' then
           s2:=copy(s,v,e-v-1) //local style
         else
           s2:=copy(s,v,e-v);//online style as:  000-BCP-198 V=9.794(0.071)_B=10.162(0.08)_R=9.601(0.071)

         val(s2,result,err);
      end;
      if ((err<>0) or (v=0)) then
        memo2_message('Error reading comparison star magnitude. Could not find V= in ' +s)
    end
    else
    if filter=2 then  //get B magnitude
    begin
      b:= posex(')_',uppercase(s),4);
      if b>0 then
      begin
         b:=b+2;
         e:= posex('_',s,b);
         if e<>0 then
         begin
           s2:=copy(s,b,e-b-1); //local style
           val(s2,Bmagnitude,err);
           result:=Bmagnitude;
         end;
      end;
      if ((err<>0) or (v=0)) then
           memo2_message('Error reading B magnitude in ' +s);
    end;//filter=2
  end;
end;


function find_correct_check_column : integer;
var
  i: integer;
  name_check : string;
begin
  result:=-99;//assume failure
  name_check:=remove_sigma_end(form_aavso1.abrv_check1.text); //remove ', σ=' at the end
  if name_check='' then  exit;

  for i:=p_nr_norm to p_nr-1 do
    if ((frac((i-p_nr_norm)/3)=0) and (pos(name_check,stackmenu1.listview7.Column[i+1].Caption)>0)) then
    begin
      result:=i;
      exit;
    end;
end;

function fill_comp_columns : Tinteger_array;
var
  i,j,count: integer;
  name_comp : string;
begin
  setlength(result,form_aavso1.abrv_comp1.count);
  count:=0;
  for j:=0 to form_aavso1.abrv_comp1.count-1 do
  begin
     if form_aavso1.abrv_comp1.Checked[j] then
     begin
       name_comp:=remove_sigma_end(form_aavso1.abrv_comp1.items[j]);

       //find the column
       for i:=p_nr_norm to p_nr-1 do
         if ( (frac((i-p_nr_norm)/3)=0) and (pos(name_comp,stackmenu1.listview7.Column[i+1].Caption)>0)) then
         begin
           result[count]:=i;
           inc(count);
           break;
         end;

       if count>=length(result) then
         break;
     end;
  end;
  setlength(result,count);
end;


function find_correct_var_column : integer;
var
  i          : integer;
  name_var   : string;
begin
  result:=-99;//assume failure
  name_var:=remove_sigma_end(form_aavso1.abbrv_variable1.text);
  if name_var='' then  exit;

  for i:=p_nr_norm to p_nr-1 do
  begin
    if ((frac((i-p_nr_norm)/3)=0) and (pos(name_var,stackmenu1.listview7.Column[i+1].Caption)>0)) then
    begin
      result:=i;
      exit;
    end;
  end;
end;


function  process_comp_stars(c : integer; calc_colour_index : boolean; out ratio_average: double; out standard_deviation, documented_comp_magn,B_V, V_R : double; out  warning : string): integer;// Get flux ratio for ensemble. Documented_comp_magn is only used for single comp star.
var
   i,invalid_comp,invalid,count,icon_nr, B_Vcounter,V_Rcounter  : integer;
   abbrv_c,comp_magn_str,flux_str                 : string;
   comp_magn, flux_documented,flux,sum_all_fluxes,magR,magV, magB : double;
   ratios,fluxes                                  : array of double;
begin
  warning:='';
  sum_all_fluxes:=0;
  ratio_average:=0;
  count:=0;
  setlength(ratios,length(column_comps));
  setlength(fluxes,length(column_comps));
  B_V:=0;
  V_R:=0;
  B_Vcounter:=0;
  V_Rcounter:=0;


  with form_aavso1 do
  for i:=0 to high(column_comps) do
  begin
    abbrv_c:=stackmenu1.listview7.Column[column_comps[i]+1].Caption ;
    comp_magn_str:=stackmenu1.listview7.Items.item[c].subitems.Strings[column_comps[i]];//measured comp magnitude
    comp_magn:=strtofloat3(comp_magn_str,invalid_comp);//measured comp magnitude
    if invalid_comp=0 then //valid conversion string to float
    begin
      icon_nr:=stackmenu1.listview7.Items.item[c].SubitemImages[P_filter];{filter icon nr}
      documented_comp_magn:=retrieve_comp_magnitude(icon_nr,column_comps[i], abbrv_c);//  retrieve the documented magnitude at passband used from the abbrev_comp string
      if documented_comp_magn<=0 then
      begin //COMP magnitude unknown. Most likely '?'
        warning:=warning+'Warning could not retrieve documented COMP magnitude for this filter. For Red and Sloan filters select AAVSO annotation online. For CV select in Gaia comp stars the local D50 or D80 or online Gaia BP.';
      end
      else
      begin //COMP magnitude known
        if calc_colour_index then
        begin
          magR:=retrieve_comp_magnitude(0,column_comps[i], abbrv_c);
          magV:=retrieve_comp_magnitude(1,column_comps[i], abbrv_c);
          magB:=retrieve_comp_magnitude(2,column_comps[i], abbrv_c);
          if ((magB<>0) and (magV<>0)) then
          begin
            B_V:=B_V+(magB-magV);
            inc(B_Vcounter);
          end;
          if ((magV<>0) and (magR<>0)) then
          begin
            V_R:=magV-magR;
            inc(V_Rcounter);
          end;
        end;


        flux_documented:=power(10,(21-documented_comp_magn)/2.5);//21 is a bias
        flux_str:=(stackmenu1.listview7.Items.item[c].subitems.Strings[column_comps[i]+2]);
        flux:=strtofloat3(flux_str,invalid);
        sum_all_fluxes:=sum_all_fluxes+flux_documented;
        //Now calulate ratio*flux and sum it
        ratio_average:=ratio_average + sqr(flux_documented)/flux;

        ratios[count]:=flux_documented/flux;//for standard deviation calculation
        fluxes[count]:=flux_documented;//for standard deviation calculation
        inc(count);
      end;
    end
    else
    warning:=warning+'Ignored invalid '+copy(abbrv_c,1,11)+'. ';
  end;//for loop
  if sum_all_fluxes<>0 then
  begin
    ratio_average:=ratio_average/sum_all_fluxes; // So the mean of all comp stars.  Magnitude_measured:= 21- ln(ratio*flux_measured)*2.5/ln(10)
    result:=0;

    if calc_colour_index then
    begin
      if B_Vcounter>0 then B_V:=B_V/B_Vcounter;//average value of all comp stars
      if V_Rcounter>0 then V_R:=V_R/V_Rcounter;//average value of all comp stars

      if  B_Vcounter<>count then warning:=warning+'B-V not accurate!';
      if  V_Rcounter<>count then warning:=warning+'V-R not accurate!';
    end;

    //now calculate the standard deviation. So the weighted difference between the COMP stars in one image
    //Standard deviation so noise has to combine the uncertainties quadratically. The reason that a star ensemble has a lower standard deviation then a single comparison star is that
    //the signal is averaged. So the total noise of an ensemble of four equal star would be
    //σ_total= ( (0.25σ)^2 + (0.25σ)^2+ (0.25σ)^2+ (0.25^σ)^2 )^0.5  equals  σ/2.
    //This doesn't happen when you use the ensemble mzero value for measuring the check star.
    //For a standard deviation so noise calculation either subtraction or addition you have to combine the uncertainties quadratically.
    //The standard deviation of the check measurement result is higher and equal to σ_total= (σ_check^2 + σ_ensemble^2)^0.5

    standard_deviation:=0;
    for i:=0 to count-1 do
       standard_deviation:=standard_deviation+ sqr((fluxes[i]/sum_all_fluxes)*(ratio_average-ratios[i]));//fluxes[i] is the weight factor base on flux

    standard_deviation:=2.5/ln(10)*sqrt(standard_deviation);
  end
  else
  begin
    ratio_average:=999;
    result:=-99;
  end;
end;



procedure report_sigma_and_mean_of_check ;
var
  c, invalid_comp,count, count2,invalid_check,icon_nr             : integer;
  check_magnitudes                                                : array of double;
  comp_magn,ratio,check_flux, sd, mean,sd_comp, mean_sd_comp,B_V, V_R      : double;
  warning,check_flux_str                                          : string;
  go_boolean                                                      : boolean;

begin
  count:=0;
  count2:=0;
  mean_sd_comp:=0;

  go_boolean:=true;
  //column_check is found in plot_graph
  if column_check<0 then
  begin
    form_aavso1.sigma_check2.caption:='No check star selected.';
     go_boolean:=false;
  end
  else
  form_aavso1.sigma_check2.caption:='';
  if length(column_comps)=0 then
  begin
    form_aavso1.sigma_mzero1.caption:='No comparison star selected.';
    go_boolean:=false;
  end
  else
  form_aavso1.sigma_mzero1.caption:='';

  if go_boolean=false then exit;


  with stackmenu1 do
  begin
    setlength(check_magnitudes,listview7.items.count);
    for c:=0 to listview7.items.count-1 do
    begin
      icon_nr:=stackmenu1.listview7.Items.item[c].SubitemImages[P_filter];{filter icon nr}
      if ((icon_nr=1) or (icon_nr=4)) then //for filter V or TG or CV only
      if listview7.Items.item[c].checked then
      begin
        invalid_comp:=process_comp_stars(c,false,ratio,sd_comp,comp_magn,B_V, V_R ,warning);//Magnitude_measured:= 21- ln(ratio*flux_measured)*2.5/ln(10)
        if invalid_comp=0 then //valid
        begin
          check_flux_str:=listview7.Items.item[c].subitems.Strings[column_check+2];
          check_flux:=strtofloat3(check_flux_str,invalid_check );
          if invalid_check=0 then //valid conversion string to float
          begin
            check_magnitudes[count]:=21-ln(ratio* check_flux)*2.5/ln(10);//21 is just a bias
            inc(count);
          end;

          mean_sd_comp:=mean_sd_comp+sd_comp;//sum the sd_comp (weighted standard deviation of the comp stars between them) of each image to calculate an average
          inc(count2);
        end;
      end;
    end;
  end;
  if count>0 then
  begin
    calc_sd_and_mean(check_magnitudes, count,{out} sd, mean);// calculate sd and mean of an array of doubles}
    if length(column_comps)=1 then
      form_aavso1.sigma_check2.caption:='Check σ='+floattostrF(sd,ffFixed,0,3)+', mean='+floattostrF(mean,ffFixed,0,3)+' using a single comparison star' //report sigma check
    else
      form_aavso1.sigma_check2.caption:='Check σ='+floattostrF(sd,ffFixed,0,3)+', mean='+floattostrF(mean,ffFixed,0,3)+' using '+inttostr(length(column_comps))+' ensemble stars';//report sigma check
  end
  else
  begin
//    if form_aavso1.abrv_check1.text='' then
//     form_aavso1.sigma_check2.caption:='No star selected'
//    else
      form_aavso1.sigma_check2.caption:='Saturated/No documented magnitude for used filter';
  end;

  if count2>0 then
  begin
    if length(column_comps)=1 then
      form_aavso1.sigma_mzero1.caption:='Single comparison star.'
    else
      form_aavso1.sigma_mzero1.caption:='σ='+floattostrF(mean_sd_comp/count,FFfixed,0,4)+', weighted standard deviation between '+inttostr(length(column_comps))+' ensemble stars.'  //  Weighted noise between the comp star(s)
  end
  else
  begin
    form_aavso1.sigma_mzero1.caption:='Saturated//No documented magnitude for used filter';
  end;
end;


procedure Tform_aavso1.report_to_clipboard1Click(Sender: TObject);
var
    c,date_column,invalid_var,invalid_check,invalid_comp,i,icon_nr   : integer;
    err,snr_str,airmass_str, delim,fnG,detype,baa_extra,magn_type,filter_used,settings,date_format,date_observation,
    abbrv_var_clean,abbrv_check_clean,abbrv_comp_clean,abbrv_comp_clean_report,comp_magn_info,var_magn_str,check_magn_str,comp_magn_str,comments,invalidstr,
    var_flux_str,check_flux_str,warning,transformation, transform_all_factors,transf_str  : string;
    stdev_valid : boolean;
    snr_value,err_by_snr,comp_magn, var_magn,check_magn,var_flux,ratio,check_flux,sd_comp,B_V, V_R,var_Vcorrection,var_Bcorrection,var_Rcorrection : double;
    PNG: TPortableNetworkGraphic;{FPC}
    vsep : char;
begin
  get_info;//update abbrev_var and others
  if delimiter1.text=',' then vsep:=';' else vsep:=',';//valid seperator

  abbrv_var_clean:=clean_abbreviation(abbrev_var);
  abbrv_check_clean:=clean_abbreviation(abbrev_check);

  abbrv_comp_clean:='';
  for i:=0 to abrv_comp1.items.count-1 do
  begin
     if abrv_comp1.checked[i] then
     begin
       abbrv_comp_clean:=abbrv_comp_clean+clean_abbreviation(abrv_comp1.items[i])+'|';
     end;
  end;
  if abbrv_comp_clean<>'' then
  begin
    delete(abbrv_comp_clean,length(abbrv_comp_clean),1);//remove last "|"
    store_vsp_stars(abbrv_var_clean,abbrv_check_clean,abbrv_comp_clean); //simple database in settings key used_vsp_stars
  end;


  if ((length(abbrv_var_clean)<1) or (column_var<0)) then
  begin
    abbrv_variable1.color:=clred;
    exit;
  end
  else
    abbrv_variable1.color:=cldefault;

  if ((length(abbrev_check)<1) or (column_check<0)) then
  begin
    abrv_check1.color:=clred;
    exit;
  end
  else
    abrv_check1.color:=cldefault;


  if ((abrv_comp1.enabled) and (abbrv_comp_clean='')) then
  begin
    abrv_comp1.color:=clred;
    exit;
  end
  else
    abrv_comp1.color:=cldefault;

  stdev_valid:=(photometry_stdev>0.0001);

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
  transf_str:='NO'; //No is no transformation, YES is transformation.



  if stackmenu1.reference_database1.ItemIndex=0 then settings:=stackmenu1.reference_database1.text
  else
    settings:=stackmenu1.reference_database1.text;
  settings:=settings+vsep+' aperture='+stackmenu1.flux_aperture1.text+' HFD'+vsep+' annulus='+stackmenu1.annulus_radius1.text+' HFD';

  if ensemble_database1.checked then
     comments:='CMAG ensemble using transformed Gaia magnitudes.'
   else
     comments:='';

  if apply_transformation1.checked then
  begin
    transform_all_factors:=
    '#Tbv= ' + TbvSTR+#13+#10+
    '#Tb_bv= ' + Tb_bvSTR+#13+#10+
    '#Tv_bv= ' + Tv_bvSTR+#13+#10+
    '#Tvr= ' + TvrSTR+#13+#10+
    '#Tv_vr= ' + Tv_vrSTR+#13+#10+
    '#Tr_vr= ' + Tr_vrSTR+#13+#10
  end
  else
    transform_all_factors:='';


  aavso_report:= '#TYPE='+detype+#13+#10+
                 '#OBSCODE='+obscode+#13+#10+
                 '#SOFTWARE=ASTAP, v'+astap_version+#13+#10+
                 '#DELIM='+delimiter1.text+#13+#10+
                 '#DATE='+date_format+#13+#10+
                 '#OBSTYPE='+obstype1.text+#13+#10+
                 '#COMMENTS='+comments+#13+#10+
                  baa_extra+
                  transform_all_factors+
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
           filter_used:=listview7.Items.item[c].subitems.Strings[P_filter]; //take from header

           comp_magn_info:='';//clear summation of messages;

           if stackmenu1.reference_database1.itemindex=0 then //local database
           if pos('v',name_database)>0 then magn_type:=' transformed to Johnson-V. ' else magn_type:=' using BM magnitude. '
           else  //online database
             magn_type:=' transformed '+stackmenu1.reference_database1.text;

           if ensemble_database1.checked=false then //Mode magnitude relative to comp star
           begin
             if length(column_comps)=0 then exit;

             invalid_comp:=process_comp_stars(c,true,ratio,sd_comp,comp_magn,B_V, V_R,warning);//Magnitude_measured:= 21- ln(ratio*flux_measured)*2.5/log(10)

             comp_magn_info:=comp_magn_info+warning;
             if invalid_comp=0 then //valid comp star(s)
             begin
                   var_flux_str:=listview7.Items.item[c].subitems.Strings[column_var+2];
                   var_flux:=strtofloat3(var_flux_str,invalid_var);

                   if invalid_var=0 then //valid conversion string to float
                     var_magn:= 21- ln(ratio*var_flux)*2.5/ln(10)
                   else
                     var_magn:=99;


                   transformation:='';
                   if apply_transformation1.checked then
                   begin
                     //transformation
                     // Tv_bv * Tbv* ((b-v)tgt – (B-V)comp)
                     transf_str:='YES';
                     icon_nr:=listview7.Items.item[c].SubitemImages[P_filter];
                     if icon_nr=2 then //B correction
                     begin
                       var_Bcorrection:= strtofloat2(Tb_bvSTR) * strtofloat2(TbvSTR) * (strtofloat2(b_v_variable1.text){var} - (B_V){comp});
                       var_magn:=var_magn+var_Bcorrection;
                       transformation:='Transf corr. '+floattostrF(var_Bcorrection,ffFixed,0,3)+'='+Tb_bvSTR+'*'+TbvSTR+'*('+b_v_variable1.text+'-'+floattostrF(B_V,ffFixed,0,3)+') ';
                     end
                     else
                     if icon_nr=1 then//V correction
                     begin
                       var_Vcorrection:= strtofloat2(Tv_bvSTR) * strtofloat2(TbvSTR) * (strtofloat2(b_v_variable1.text){var} - (B_V){comp});
                       var_magn:=var_magn+var_Vcorrection;
                       transformation:='Transf corr. '+floattostrF(var_Vcorrection,ffFixed,0,3)+'='+Tv_bvSTR+'*'+TbvSTR+'*('+b_v_variable1.text+'-'+floattostrF(B_V,ffFixed,0,3)+') ';
                     end
                     else
                     if ((icon_nr=0) or (icon_nr=24)) then//R correction
                     begin
                       var_Rcorrection:= strtofloat2(Tr_vrSTR) * strtofloat2(TvrSTR) * (strtofloat2(v_r_variable1.text){var} - (V_R){comp});
                       var_magn:=var_magn + var_Rcorrection;
                       transformation:='Transf corr. '+floattostrF(var_Rcorrection,ffFixed,0,3)+'='+Tr_vrSTR+'*'+TvrSTR+'*('+v_r_variable1.text+'-'+floattostrF(V_R,ffFixed,0,3)+') ';
                     end
                     else
                       transf_str:='NO';//for other filters
                   end;



                   check_flux_str:=listview7.Items.item[c].subitems.Strings[column_check+2];
                   check_flux:=strtofloat3(check_flux_str,invalid_check );
                   if invalid_check=0 then //valid conversion string to float
                   begin
                     check_magn:=21- ln(ratio*check_flux)*2.5/ln(10);
                     str(check_magn:0:3,check_magn_str);
                   end
                   else
                     check_magn_str:='invalid';

                   if length(column_comps)>1 then //ensemble, else single comp star
                   begin
                     comp_magn_info:=comp_magn_info+'Ensemble: '+ abbrv_comp_clean;
                     abbrv_comp_clean_report:='ENSEMBLE';
                     comp_magn_str:='na';
                   end
                   else
                   begin
                     abbrv_comp_clean_report:=abbrv_comp_clean;//single comp star
                     comp_magn_str:=floattostrF(comp_magn,ffFixed,0,3);//from process_comp_stars
                   end;

             end ;//valid comp_str
           end //no ensemble mode
           else
           begin
             var_magn_str:=listview7.Items.item[c].subitems.Strings[column_var];
             var_magn:=strtofloat3(var_magn_str,invalid_var);
             check_magn_str:=listview7.Items.item[c].subitems.Strings[column_check];
             check_magn:=strtofloat3(check_magn_str,invalid_check );

             invalid_comp:=0; //ensemble mode, no conversion error because comp is not used
             abbrv_comp_clean_report:='ENSEMBLE';
             comp_magn_str:='na';
             comp_magn_info:='Ensemble of Gaia DR3 stars ('+ magn_type+')';
           end;


           if invalid_var=0 then //valid conversion string to float
           begin
             str(var_magn:0:3,var_magn_str);
           end;

           if ((invalid_var<>0) or (invalid_comp<>0) or (invalid_check<>0)) then invalidstr:='# ' else invalidstr:='';


          // dummy:=ListView7.Items.item[c].SubitemImages[P_calibration];
          // dummy2:=ListView7.Items.item[c].SubitemImages[P_filter];

           if ListView7.Items.item[c].SubitemImages[P_calibration]<>ListView7.Items.item[c].SubitemImages[P_filter] then
              comp_magn_info:=comp_magn_info+'  WARNING INCOMPATIBLE FILTER AND DATABASE PASSBAND! VALID FILTERS CV/V/TG/B/R/SI/SR/SG.';

           aavso_report:= aavso_report+ invalidstr+ abbrv_var_clean + delim +
                          StringReplace(listview7.Items.item[c].subitems.Strings[date_column],',','.',[])+delim+
                          var_magn_str+delim+
                          err+
                          delim+filter_used+delim+
                          Transf_str{'NO'}+delim+
                          'STD'+delim+
                          abbrv_comp_clean_report+delim+
                          comp_magn_str+delim+
                          abbrv_check_clean+delim+
                          check_magn_str+delim+
                          airmass_str+delim+
                          'na'+delim+ {group}
                          'na'+delim+
                          transformation+comp_magn_info+' ('+settings+ ')'+#13+#10;


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
    savedialog1.filename:=stringreplace(abbrv_variable1.text,'?','',[rfReplaceAll]) +'_'+date_observation+'_report.txt';
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
  mainform1.setfocus;
end;


procedure Tform_aavso1.Image_photometry1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  w2,h2 :integer;
  jd_mouse: double;

begin
  if jd_min=0 then exit;
  w2:=image_photometry1.width;
  h2:=image_photometry1.height;
 // x zero at x=wtext
 // x range is (w-bspace*2)
 jd_mouse:=jd_min+(jd_max-jd_min)*((x*w/w2)-wtext)/(w-bspace*2);
 form_aavso1.caption:= 'JDmid='+floattostrF(jd_mouse,ffFixed,12,5)+', TimeMid='+prepare_ra6((frac(jd_mouse)+0.5)*2*pi,':')+', Magnitude='+floattostrf(magn_min+(magn_max-magn_min)*(((y*h/h2))-bspace)/(h-bspace*2),ffFixed,5,3);
end;

procedure Tform_aavso1.MenuItem1Click(Sender: TObject);
begin
    Clipboard.Assign(Image_photometry1.Picture.Bitmap);
end;

procedure Tform_aavso1.abrv_check1Change(Sender: TObject);
var
   i         : integer;
begin
  for i:=0 to abrv_check1.items.count-1 do
  begin
    if form_aavso1.abrv_check1.text=form_aavso1.abrv_comp1.items[i] then
    begin
      form_aavso1.abrv_comp1.checked[i]:=false; // a star can not be both COMP and CHECK at the same time
      break;
    end;
  end;
  plot_graph;

end;


function find_sd_star(column: integer) : double;//calculate the standard deviation of a variable
var
   count, c,count_checked, icon_nr  : integer;
   magn, mean                       : double;
   dum: string;
   listMagnitudes : array of double;
begin
  count:=0;
  count_checked:=0;
  setlength(listMagnitudes,stackmenu1.listview7.items.count);//list with magnitudes check star

  with stackmenu1 do
  for c:=0 to listview7.items.count-1 do {retrieve data from listview}
  begin
    icon_nr:=listview7.Items.item[c].SubitemImages[P_filter];
    if ((icon_nr=1) or (icon_nr=4)) then //for filter V or TG or CV only
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
     //calc standard deviation using the classic method. This will show the effect of outliers
    calc_sd_and_mean(listMagnitudes, count{counter},{out}result, mean);// calculate sd and mean of an array of doubles}
  end
  else
    result:=-99;//unknown
end;




function find_mean_measured_magnitude(column: integer) : double;//calculate the mean measured magnitude
var
   count, c         : integer;
   magn, mean_magn  : double;
   dum: string;
begin
  count:=0;
  mean_magn:=0;

  with stackmenu1 do
  for c:=0 to listview7.items.count-1 do {retrieve data from listview}
  begin
    if listview7.Items.item[c].checked then
    begin
      dum:=(listview7.Items.item[c].subitems.Strings[column]);{var star}
      if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then magn:=strtofloat(dum) else magn:=0;
      if magn<>0 then
      begin
        mean_magn:=mean_magn+magn;
        inc(count);
      end;
    end;
  end;
  if count>0 then
  begin
    //calc standard deviation using the classic method. This will show the effect of outliers
    result:=mean_magn/count;
  end
  else
    result:=-99;//unknown
end;


procedure fill_comp_and_check;
var
  i,count,error2,dummy        : integer;
  abrv,filter,object_name2    : string;
  starinfo                        : array of Tstarinfo;
  measure_any,varfound,checkfound  : boolean;
begin
  with form_aavso1 do
  begin

    abrv_comp1.clear;
    abrv_check1.clear;
    color:=cldefault;


    ensemble_database1.caption:=('Ensemble '+stackmenu1.reference_database1.text);

    if stackmenu1.measuring_method1.itemindex=0 then //manual star selection
    begin
      varfound:=false;
      checkfound:=false;
      for i:=0 to high(mainform1.Fshapes) do
      begin
        if mainform1.Fshapes[i].shape<> nil then
        begin
          abrv:=mainform1.Fshapes[i].shape.HINT;
          if pos('000-',abrv)>0 then // labeled with an AUID
          begin
             abrv_check1.text:=abrv;
             checkfound:=true;
          end
          else
          begin
            abbrv_variable1.text:=abrv;
            varfound:=true;
          end;
          if ((checkfound) and (varfound)) then break;
        end;
      end;
    end
    else
    begin //find the variable of interest for header object
      object_name2:=stringreplace(object_name,' ','_',[]);//object_name from fits header
      for i:=p_nr_norm to p_nr-1 do
        if frac((i-p_nr_norm)/3)=0 then // not a snr column
        begin
          abrv:=stackmenu1.listview7.Column[i+1].Caption;
          if  Comparetext(object_name2,copy(abrv,1,length(object_name2)))=0 then
          begin
           abbrv_variable1.text:=abrv;
           break;
          end;
        end;
     end;

    setlength(starinfo,p_nr-p_nr_norm);
    count:=0;

    measure_any:=stackmenu1.measuring_method1.itemindex=3;


    for i:=p_nr_norm to p_nr-1 do
      if frac((i-p_nr_norm)/3)=0 then //not snr column
      begin
        abrv:=stackmenu1.listview7.Column[i+1].Caption;
        val(copy(abrv,1,1),dummy,error2);
        if ((measure_any) or (error2=0)) then //check star or iau code
        begin
          starinfo[count].str:=abrv;//store in an array
          starinfo[count].x:=find_mean_measured_magnitude(i);
          inc(count);
        end;
      end;

    if count>0 then
    begin
      if sort_alphabetically1.checked=false then
      begin
        QuickSort_records(starinfo,0,count-1) ;{ Fast quick sort. Sorts elements in the array A containing records with indices between lo and hi}
        //memo2_message('Variables are sorted on standard deviation in descending order. The standard deviation is added to the variable abbreviation');
      end;
      for i:=0 to count-1  do  //display in ascending order
        if starinfo[i].x>0 then //not saturated and sd found
          abrv_comp1.items.add(starinfo[i].str) //+ ', σ='+floattostrF(starinfo[i].x,ffFixed,5,3))//add including standard deviation
        else  //not all images analysed for SD
           abrv_comp1.items.add(starinfo[i].str+ ' Bad!');

        abrv_check1.items:=abrv_comp1.items;//duplicate
    end;
  end;
end;



procedure Tform_aavso1.abbrv_variable1Change(Sender: TObject);
type
  TmagnAndTime  = record
                   time: double;
                 R,V,B : double
              end;
var
  thevar, dum: string;
  c,Rcount,Vcount,Bcount,icon_nr,count   : integer;
  value, varmag_B,varmag_V, varmag_R : double;

begin
  thevar:=clean_abbreviation(abbrv_variable1.text);
  retrieve_vsp_stars(thevar);
  plot_graph;

  //find B-V of var
  column_var:=find_correct_var_column;
  varmag_B:=0;
  varmag_V:=0;
  varmag_R:=0;

  Rcount:=0;
  Vcount:=0;
  Bcount:=0;

  with stackmenu1 do
  for c:=0 to listview7.items.count-1 do {retrieve data from listview}
  begin
    if listview7.Items.item[c].checked then
    begin
       if column_var>0 then
       begin
         dum:=listview7.Items.item[c].subitems.Strings[column_var];{var star flux}
         value:=strtofloat2(dum);
         icon_nr:=listview7.Items.item[c].SubitemImages[P_filter];
         case icon_nr of
           0,24 : begin varmag_R:=varmag_R+value; inc(Rcount);end;  //red or Cousins red
           1 :    begin varmag_V:=varmag_V+value; inc(Vcount);end;  //V or G TG
           2 :    begin varmag_B:=varmag_B+value; inc(Bcount);end;  //B or TB
        end;
      end;
    end;

  end;
  if Rcount>0 then varmag_R:=varmag_R/Rcount;
  if Vcount>0 then varmag_V:=varmag_V/Vcount;
  if Bcount>0 then varmag_B:=varmag_B/Bcount;
  if ((Bcount>0) and (Vcount>0)) then
    b_v_variable1.text:=floattostrF(varmag_B-varmag_V,ffFixed, 0,3)
  else
    b_v_variable1.text:='?';

  if ((Vcount>0) and (Rcount>0)) then
    v_r_variable1.text:=floattostrF(varmag_V-varmag_R,ffFixed, 0,3)
  else
    v_r_variable1.text:='?';

end;


procedure Tform_aavso1.abbrv_variable1DropDown(Sender: TObject);
var
  i,count            : integer;
  abrv               : string;
  starinfo : array of Tstarinfo;

begin
//  for filtering dropdown set
//    AutoComplete := true;
//    AutoDropDown := true;
  abbrv_variable1.items.clear;

  setlength(starinfo,p_nr-p_nr_norm);
  count:=0;

  with tcombobox(sender) do
  begin
    for i:=p_nr_norm to p_nr-1 do
    if frac((i-p_nr_norm)/3)=0 then // not a snr column
    begin
      abrv:=stackmenu1.listview7.Column[i+1].Caption;
      if ((copy(abrv,1,4)<>'000-') or (test_mode1.checked)) then //Not a check star
      begin
        starinfo[count].str:=abrv;//store in an array
        starinfo[count].x:=find_mean_measured_magnitude(i);
        inc(count);
      end;
    end;

    if count>0 then
    begin
      if sort_alphabetically1.checked=false then
      begin
        QuickSort_records(starinfo,0,count-1) ;{ Fast quick sort. Sorts elements in the array A containing records with indices between lo and hi}
        //memo2_message('Variables are sorted on standard deviation in descending order. The standard deviation is added to the variable abbreviation');
      end;


      for i:= count-1 downto 0 do  //display in decending order
        if starinfo[i].x<>0 then
        begin
          abrv:=starinfo[i].str; //+ ', σ='+floattostrF(starinfo[i].x,ffFixed,5,3);
          items.add(abrv);//add including standard deviation
          {$ifdef mswindows}
          {begin adjust width automatically}
          if (Canvas.TextWidth(abrv)> ItemWidth) then
          begin
             ItemWidth:=10+Canvas.TextWidth(abrv);{adjust dropdown with if required}
             Perform(352{windows,CB_SETDROPPEDWIDTH}, ItemWidth, 0);
           end; {end adjust width automatically}
          {$else} {unix}
          ItemWidth:=form_aavso1.Canvas.TextWidth((abrv));{works only second time};
          {$endif}
        end;
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

procedure Tform_aavso1.abrv_comp1Change(Sender: TObject);
begin
  plot_graph;
end;


procedure Tform_aavso1.abbrv_comp1ItemClick(Sender: TObject; Index: integer);
begin
  if copy(form_aavso1.abrv_comp1.items[index],1,11)=copy(form_aavso1.abrv_check1.text,1,11) then  // a star can not be both COMP and CHECK at the same time
    form_aavso1.abrv_check1.text:='';
end;


procedure Tform_aavso1.abrv_comp1ClickCheck(Sender: TObject);
begin
  plot_graph;
end;


procedure Tform_aavso1.ensemble_database1Click(Sender: TObject);
begin
  ensemble_database:=ensemble_database1.checked;
  abrv_comp1.enabled:=ensemble_database=false;
  sigma_check1.enabled:=ensemble_database;
  sigma_check2.enabled:=ensemble_database=false;
  sigma_mzero1.enabled:=ensemble_database=false;
  apply_transformation1.enabled:=ensemble_database=false;
  plot_graph;
end;



procedure Tform_aavso1.FormCreate(Sender: TObject);
begin
  {$IFDEF linux}
  abbrv_variable1.autoDropDown:=false;//then only autocomplete works with more then one character  https://forum.lazarus.freepascal.org/index.php?topic=68250.new;topicseen#new
  abrv_check1.autoDropDown:=false;//then only autocomplete works with more then one character

  {$ELSE}
  abbrv_variable1.autoDropDown:=true;
  abrv_check1.autoDropDown:=true;
  {$ENDIF}
end;


procedure retrieve_ra_dec(columnr: integer; out ra,dec:double);//retrieve from database arrays using the .tag
var
  theindex : integer;
begin
  try
    theindex:=stackmenu1.listview7.column[columnr+1].tag;//Caption position is always one position higher then data
    ra:=variable_list[theindex].ra;
    dec:=variable_list[theindex].dec;
   // memo2_message('column:  '+inttostr(columnr)+',    index:  '+inttostr(theindex)+',    '+ floattostr(ra*180/pi)+',    '+floattostr(dec*180/pi)+',  '+ stackmenu1.listview7.column[columnr+1].caption);//testing
  except;
  end;
end;

procedure annotate_star_of_column(columnV,columnCheck : integer; column_comps : Tinteger_array);
var
  i,indx      : integer;
begin
  if head.cd1_1=0 then exit;

  indx:=0;
  with mainform1 do
  begin
    for i:=high(fshapes) downto 0 do //remove markers
        freeandnil(fshapes[i]);//essential
    setlength(fshapes,0);

    try
    if columnV>0 then //valid
    begin
      mainform1.GenerateShapes(indx,100,100,3 {penwidth},stEllipse, clLime,'Var');
      inc(indx);
      retrieve_ra_dec(columnV,fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec);
      celestial_to_pixel(head, fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec,true, fshapes[high(fshapes)].fitsX,fshapes[high(fshapes)].fitsY); {ra,dec to shape.fitsX,shape.fitsY}
    end;

    if columnCheck>0 then //valid
    begin
      mainform1.GenerateShapes(indx,100,100,3 {penwidth},stSquare, clLime,'Check');
      inc(indx);
      retrieve_ra_dec(columnCheck,fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec);
      celestial_to_pixel(head, fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec,true, fshapes[high(fshapes)].fitsX,fshapes[high(fshapes)].fitsY); {ra,dec to shape.fitsX,shape.fitsY}
    end;

    if ((length(column_Comps)>0) and (head.cd1_1<>0)) then //valid
    begin
      for i:=0 to length(column_Comps)-1 do
      begin
        //memo2_message(stackmenu1.listview7.Column[column_comps[i]+1].Caption);  //testing
        mainform1.GenerateShapes(indx+i,100,100,3 {penwidth},stDiamond, clLime,'Comp'+inttostr(i));
        retrieve_ra_dec(column_Comps[i],fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec);
        celestial_to_pixel(head, fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec,true, fshapes[high(fshapes)].fitsX,fshapes[high(fshapes)].fitsY); {ra,dec to shape.fitsX,shape.fitsY}
      end;
    end;

    for i:=0 to high(fshapes) do
      show_marker_shape(FShapes[i].shape,9 {no change},40,40,10,FShapes[i].fitsX, FShapes[i].fitsY);

    except
    end;
  end;

end;


procedure plot_graph; {plot curve}
var
  x1,y1,c,textp1,textp2,textp3,textp4, nrmarkX, nrmarkY,date_column,count,k,invalid_comp,icon_nr,i,j : integer;
  scale,range, mean,ratio,sd_comp,comp_magn,dummy,flux,B_V, V_R   : double;
  text1,text2, date_format,firstfilter,magn_gaia,warning   : string;
  bmp: TBitmap;
  dum:string;
  data : array of array of double;
  listcheck : array of double;
  filtercolor : array of tcolor;
  gaia_based  : boolean;
const
  len=3;

  procedure plot_point(x,y,tolerance:integer);
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

  procedure plot_square(x,y,tolerance:integer);
  begin
     if ((x>0) and (y>0) and (x<=w) and( y<=h)) then
     begin
       bmp.canvas.Rectangle(x-len,y-len,x+1+len,y+1+len);{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}

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
  procedure plot_Xsign(x,y,tolerance:integer);
  begin
     if ((x>0) and (y>0) and (x<=w) and( y<=h)) then
     begin
       bmp.canvas.moveto(x-len,y-len);
       bmp.canvas.lineto(x+len,y+len);
       bmp.canvas.moveto(x-len,y+len);
       bmp.canvas.lineto(x+len,y-len);

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
  bspace:=3*mainform1.image1.Canvas.textheight('T');{{border space graph. Also for 4k with "make everything bigger"}
  wtext:=mainform1.image1.Canvas.textwidth('12.3456');

  column_var:=find_correct_var_column;
  column_check:=find_correct_check_column;
  column_comps:=fill_comp_columns; //file the column_comp array

  report_sigma_and_mean_of_check;

//  if ((column_var<0) and (column_check<0)) then exit;//no var or check star specified


  if ((stackmenu1.measuring_method1.itemindex>0) and (length(column_comps)>0))  then //<> manual mode
    annotate_star_of_column(column_var,column_check,column_comps);

  photometry_stdev:=0;
  setlength(data,3+length(column_comps), stackmenu1.listview7.items.count);
  for i:=0 to length(data)-1 do
    for j:=0 to length(data[0])-1 do
      data[i,j]:=0;//clear
  setlength(listcheck,length(data[0]));//list with magnitudes check star
  setlength(filtercolor,length(data[0]));//list filter colors
  count:=0;
  firstFilter:='';

  with stackmenu1 do
  if ((form_aavso1.ensemble_database1.Checked) or (length(column_comps)=0))  then
  begin
    gaia_based:=true;
    for c:=0 to listview7.items.count-1 do {retrieve data from listview}
    begin
      if listview7.Items.item[c].checked then
      begin
        dum:=(listview7.Items.item[c].subitems.Strings[date_column]);
        if dum<>'' then
        begin
          dummy:=strtofloat(dum);
          if dummy<>0 then
          begin
            data[0,c]:=dummy;
            jd_max:=max(jd_max,data[0,c]);
            jd_min:=min(jd_min,data[0,c]);
          end;
        end;

        if  column_var>0 then
        begin
          dum:=listview7.Items.item[c].subitems.Strings[column_var];{var star}
          if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then
          begin
            dummy:=strtofloat(dum);
            if dummy<>0 then
            begin
              data[1,c]:=dummy;
              magn_max:=max(magn_max,data[1,c]);
              magn_min:=min(magn_min,data[1,c]);
            end;
          end;
        end;

        if column_check>0 then
        begin
          dum:=(listview7.Items.item[c].subitems.Strings[column_check]);{chk star}
          if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then
          begin
            dummy:=strtofloat(dum);
            if dummy<>0 then
            begin
              data[2,c]:=dummy;
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
        end;

        for k:=0 to length(column_comps)-1 do //add comp star(s)
        begin
          dum:=(listview7.Items.item[c].subitems.Strings[column_comps[k]]);{comparison star}
          if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then
          begin
            dummy:=strtofloat(dum);
            if dummy<>0 then
            begin
              data[3+k,c]:=dummy;
              magn_max:=max(magn_max,data[3+k,c]);
              magn_min:=min(magn_min,data[3+k,c]);
            end;
          end;
        end;
      end;
      icon_nr:=listview7.Items.item[c].SubitemImages[P_filter];
    end;
  end
  else
  begin //use comp stars, and convert flux to magnitudes
    gaia_based:=false;
    for c:=0 to listview7.items.count-1 do {retrieve data from listview}
    begin
      if listview7.Items.item[c].checked then
      begin
        invalid_comp:=process_comp_stars(c,false,ratio,sd_comp,comp_magn,B_V, V_R,warning);//Magnitude_measured:= 21- ln(ratio*flux_measured)*2.5/log(10)
     //   comp_magn_info:=comp_magn_info+warning;
        if invalid_comp=0 then //valid comp star(s)
        begin
          dum:=(listview7.Items.item[c].subitems.Strings[date_column]);
          if dum<>'' then
          begin
            dummy:=strtofloat(dum);
            if dummy<>0 then
            begin
              data[0,c]:=dummy;
              jd_max:=max(jd_max,data[0,c]);
              jd_min:=min(jd_min,data[0,c]);
            end;
          end;

          if  column_var>0 then
          begin
            magn_gaia:=listview7.Items.item[c].subitems.Strings[column_var];{Gaia based magnitude}
            dum:=listview7.Items.item[c].subitems.Strings[column_var+2];{var star flux}

            if ((length(magn_gaia)>1 {not a ?}) and (magn_gaia[1]<>'S'{saturated})) then
            begin
              flux:=strtofloat(dum);
              if flux<>0 then //valid conversion string to float
              begin
                data[1,c]:= 21- ln(ratio*flux)*2.5/ln(10); //convert flux to magnitude
                magn_max:=max(magn_max,data[1,c]);
                magn_min:=min(magn_min,data[1,c]);
              end;
            end;
          end;

          if column_check>0 then
          begin
            magn_gaia:=listview7.Items.item[c].subitems.Strings[column_check];{Gaia based magnitude}
            dum:=(listview7.Items.item[c].subitems.Strings[column_check+2]);{chk star flux}
            if ((length(magn_gaia)>1 {not a ?}) and (magn_gaia[1]<>'S'{saturated})) then
            begin
               flux:=strtofloat(dum);
               if flux<>0 then
               begin
                 data[2,c]:= 21- ln(ratio*flux)*2.5/ln(10); //convert flux to magnitude
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

          end;

          for k:=0 to length(column_comps)-1 do //add comp star(s)
          begin
            magn_gaia:=listview7.Items.item[c].subitems.Strings[column_comps[k]];{Gaia based magnitude}
            dum:=(listview7.Items.item[c].subitems.Strings[column_comps[k]+2]);{comparison star}
            if ((length(magn_gaia)>1 {not a ?}) and (magn_gaia[1]<>'S'{saturated})) then
            begin
              flux:=strtofloat(dum);
              if flux<>0 then
              begin
                data[3+k,c]:= 21- ln(ratio*flux)*2.5/ln(10); //convert flux to magnitude
                magn_max:=max(magn_max,data[3+k,c]);
                magn_min:=min(magn_min,data[3+k,c]);
             end;
            end;
          end;

        end;//valid comp star(s)
      end;
    end;
  end; //use comp stars, and convert flux to magnitudes

  if count>0 then
  begin
    calc_sd_and_mean(listcheck, count{counter},{var}photometry_stdev, mean);// calculate sd and mean of an array of doubles}
    form_aavso1.sigma_check1.caption:='Check σ='+floattostrF(photometry_stdev,ffFixed,0,3)+', mean='+floattostrF(mean,ffFixed,0,3)+' using database ensemble.';//report sigma check
  end
  else
    form_aavso1.sigma_check1.caption:='No check star selected.';

  if magn_min>magn_max then
         exit; //no info

  magn_min:=trunc(magn_min*100)/100; {add some rounding}
  magn_max:=trunc(magn_max*100)/100;
  if magn_max-magn_min<0.3 then begin magn_max:=0.15+(magn_max+magn_min)/2; magn_min:=-0.15+(magn_max+magn_min)/2;;end;//minimum range



  range:=magn_max-magn_min;
  if range<-98 then
  begin
    form_aavso1.report_error1.visible:=true;
    exit;
  end
  else
  form_aavso1.report_error1.visible:=false;

  with stackmenu1 do
  for c:=0 to listview7.items.count-1 do {retrieve colour data from listview}
  begin
    icon_nr:=listview7.Items.item[c].SubitemImages[P_filter];
    case icon_nr of
              0,24: filtercolor[c]:=clred;
              1: filtercolor[c]:=clgreen;
              2: filtercolor[c]:=clblue;
              28:filtercolor[c]:=clMaroon; //I FILTER
              21 :filtercolor[c]:=clMaroon;//SDSS-i
              22 :filtercolor[c]:=$008CFF {orange};//SDSS-r
              23 :filtercolor[c]:=clgreen;//SDSS-g

    end;
  end;


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

    text1:='Var ('+form_aavso1.abbrv_variable1.text+')';
    textp1:=10+wtext;
    bmp.canvas.textout(textp1,len*3,text1);

    textp2:=textp1+40+bmp.canvas.textwidth(text1);
    text2:='Chk ('+remove_sigma_end(form_aavso1.abrv_check1.text)+')';
    bmp.canvas.textout(textp2,len*3,text2);

    textp3:=textp2+40+bmp.canvas.textwidth(text2);
    bmp.canvas.textout(textp3,len*3,'Comp');

    textp4:=textp3+100;

    if object_name<>'' then
      bmp.canvas.textout(textp4,len*3,object_name)
    else
      bmp.canvas.textout(textp4,len*3,ExtractFilePath(filename2));

    if gaia_based then
      bmp.canvas.textout(textp4,len*8,'Graph values are based on Gaia ensemble')
    else
      bmp.canvas.textout(textp4,len*8,'Graph values are based on COMP star(s)');

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

    bmp.Canvas.Pen.Color := clgray;
    bmp.Canvas.brush.color :=clgray;
    plot_square(textp2,len*3,0);

    if jd_max=jd_min then jd_min:=jd_min-1; {prevent run time errors for one image where jd_max-jd_min}

    for c:=0 to length(data[0])-1 do
    begin
      bmp.Canvas.Pen.Color := filtercolor[c];
      bmp.Canvas.brush.color :=filtercolor[c];
      if ((data[0,c]<>0) and (data[2,c]<>0)) then //valid JD
        plot_square(wtext+round((w-bspace*2)*(data[0,c]-jd_min)/(jd_max-jd_min)), round(bspace+(h-bspace*2)*(data[2,c]-magn_min)/(magn_max-magn_min)   ),round(scale*photometry_stdev*2.5)); {chk}
    end;


    bmp.Canvas.Pen.width:=2;
    bmp.Canvas.Pen.Color := clgray;
    bmp.Canvas.brush.color :=clgray;
    plot_Xsign(textp3,len*3,0);
    for k:=3 to length(data)-1 do // plot all comp stars
    for c:=0 to length(data[0])-1 do
    begin
      bmp.Canvas.Pen.Color := filtercolor[c];
      bmp.Canvas.brush.color :=filtercolor[c];
      if ((data[0,c]<>0) and (data[k,c]<>0)) then //valid JD
      begin
        plot_Xsign(wtext+round((w-bspace*2)*(data[0,c]-jd_min)/(jd_max-jd_min)), round(bspace+(h-bspace*2)*(data[k,c]-magn_min)/(magn_max-magn_min)   ),0); {comp}
        //bmp.canvas.textout(wtext+round((w-bspace*2)*(data[0,c]-jd_min)/(jd_max-jd_min)), round(bspace+(h-bspace*2)*(data[k,c]-magn_min)/(magn_max-magn_min)   ),floattostr(data[k,c])  );
      end;
    end;
    bmp.Canvas.Pen.width:=1;


    bmp.Canvas.Pen.Color := clgray;
    bmp.Canvas.brush.color :=clgray;
    plot_point(textp1,len*3,0);
    for c:=0 to length(data[0])-1 do
    begin
      bmp.Canvas.Pen.Color := filtercolor[c];
      bmp.Canvas.brush.color :=filtercolor[c];
      if ((data[0,c]<>0) and (data[1,c]<>0)) then //valid JD
        plot_point( wtext+round((w-bspace*2)*(data[0,c]-jd_min)/(jd_max-jd_min)), round(bspace+(h-bspace*2)*(data[1,c]-magn_min)/(magn_max-magn_min)   ),round(scale*photometry_stdev*2.5)); {var}
    end;


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
  mainform1.shape_marker3.visible:=false;
  mainform1.shape_marker4.visible:=false;

end;



procedure Tform_aavso1.FormShow(Sender: TObject);
begin
  obscode1.text:=obscode;
  ensemble_database1.checked:=ensemble_database;
  abrv_comp1.enabled:=ensemble_database=false;

  sigma_check1.enabled:=ensemble_database;
  sigma_check2.enabled:=ensemble_database=false;
  sigma_mzero1.enabled:=ensemble_database=false;

  fill_comp_and_check;//fill with VSP stars
  abbrv_variable1.text:=variable_selected;//restore last variable
  if variable_selected<>'' then
       form_aavso1.abbrv_variable1Change(nil); //restore the rest

  delimiter1.itemindex:=delim_pos;
  baa_style1.checked:=baa_style;
  sort_alphabetically1.checked:=sort_alphabetically;//if true this will trigger a change and set the combobox.sorted
  apply_transformation1.checked:=apply_transformation;

  hjd1.checked:=hjd_date;
  obstype1.ItemIndex:=obstype;

  aavso_report:='';

  form_aavso1.height:=report_to_clipboard1.top+report_to_clipboard1.height+5;//autosize in height. note form_aavso1.autosize:=true doesn't work welll for the timage

  if p_nr=p_nr_norm then
  begin
     report_error1.visible:=true;
     exit;
  end;
  plot_graph;
end;


procedure Tform_aavso1.sort_alphabetically1Change(Sender: TObject);
begin
  abbrv_variable1.sorted:=sort_alphabetically1.checked;//can not do this during dropdown. This gives an error
  abrv_comp1.sorted:=sort_alphabetically1.checked;
  abrv_check1.sorted:=sort_alphabetically1.checked;
end;


procedure Tform_aavso1.suggest_check1Change(Sender: TObject);
begin
  form_aavso1.abbrv_variable1Change(nil);
end;

end.

