unit unit_aavso;
{Copyright (C) 2021, 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, math,
  clipbrd, ExtCtrls, Menus, Buttons, CheckLst, ColorBox,strutils,
  astap_main, Types, LCLType;

type

  { Tform_aavso1 }

  Tform_aavso1 = class(TForm)
    abrv_check1: TComboBox;
    abbrv_variable1: TCheckListBox;
    baa_style1: TCheckBox;
    abrv_comp1: TCheckListBox;
    apply_transformation1: TCheckBox;
    test_button1: TButton;
    sigma_mzero1: TLabel;
    ensemble_database1: TCheckBox;
    obstype1: TComboBox;
    Label7: TLabel;
    sigma_check2: TLabel;
    sigma_check1: TLabel;
    sort_alphabetically1: TCheckBox;
    hjd1: TCheckBox;
    Image_photometry1: TImage;
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
    procedure abbrv_variable1ClickCheck(Sender: TObject);
    procedure abrv_comp1Change(Sender: TObject);
    procedure abbrv_comp1ItemClick(Sender: TObject; Index: integer);
    procedure abrv_comp1ClickCheck(Sender: TObject);
    procedure test_button1Click(Sender: TObject);
    procedure delta_bv2Change(Sender: TObject);
    procedure ensemble_database1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure hjd1Change(Sender: TObject);
    procedure Image_photometry1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MenuItem1Click(Sender: TObject);
    procedure abrv_check1Change(Sender: TObject);
    procedure abbrv_variable1Change(Sender: TObject);
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
  abbrev_check  : string='';
  abbrev_comp   : Tstring_array;
  abbrev_var    : Tstring_array;
//  abbrev_var   : string='';
  delim_pos  : integer=0;
  to_clipboard  : boolean=true;
  baa_style  : boolean=false;
  sort_alphabetically: boolean=false;
  apply_transformation: boolean=false;
  hjd_date   : boolean=false;
  aavso_filter_index: integer=0;
  ensemble_database : boolean=true;
  obstype : integer=0;
  variable_clean: string='';

var
  aavso_report : string;
  report_stars: string='';

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
  w,h,bspace{,column_var},column_check,wtext  :integer;
  column_comps,column_vars : Tinteger_array;
  test_mode : boolean;


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


procedure retrieve_vsp_stars;//very simple database system
var
  i,k,L,m,count              : integer;
  rstar,all_comp,hash : string ;
begin
  //Format:   '1180/17|000-BBN-795|AD_CMi|AM_CMi|000-BBN-792|000-BBN-793;......  First one is the check star'
  //           hashedposition|check|star1|star2|star3|star4;....

  if form_aavso1.abbrv_variable1.items.count=0 then exit;

  hash:=inttostr(round(head.ra0*2*180/pi))+'/'+inttostr(round(head.dec0*2*180/pi)); //very simple hash key. Not perfect at boundaries
  i:=pos(hash, report_stars);
  if i>0 then // restore
  begin
    with form_aavso1 do   //check mark variable

    k:=posex('|',report_stars,i+1); //: and of hash
    L:=posex(';',report_stars,k+1); //; is the end of the entry

    all_comp:=copy(report_stars,k+1,L-k-1);//all comp stars

    //split all stars
    count:=0;
    k:=0;
    with form_aavso1 do   //find the comp star in abrv_comp1
    begin
      repeat
        m:=posex('|',all_comp,k+1);
        if m<>0 then
        begin
          rstar:=copy(all_comp,k+1,m-k-1);
          k:=m;
          inc(count)
        end
        else  //last control char should be ";"
          rstar:=copy(all_comp,k+1,999);//last entry

        if count=1 then
           abrv_check1.text:=rstar
        else
        if copy(rstar,1,1)='0' then //comp star
        begin
          for i:=0 to abrv_comp1.items.count-1 do
          begin
            if pos(copy(abrv_comp1.items[i],1,11),rstar)>0 then
              abrv_comp1.checked[i]:=true;
          end;
        end
        else //variable star
        for i:=0 to abbrv_variable1.items.count-1 do
        begin
          if pos(rstar, abbrv_variable1.items[i])>0 then
            abbrv_variable1.checked[i]:=true;
        end;
      until m=0;
    end;
  end
  else
  begin
    form_aavso1.abrv_check1.text:='';
  end;
end;


procedure store_vsp_stars(other_stars  : string); //simple database in settings key report_stars
var
   i,j: integer;
   hash : string;
begin
  //Format:   '1180/17|000-BBN-795|AD_CMi|AM_CMi|000-BBN-792|000-BBN-793;......  First one is the check star'
  //           hashedposition|check|star1|star2|star3|star4;....
  if length(other_stars)=0 then exit;
  hash:=inttostr(round(head.ra0*2*180/pi))+'/'+inttostr(round(head.dec0*2*180/pi)); //very simple hash key. Not perfect at boundaries
  i:=pos(hash, report_stars);
  if i<>0 then //already available
  begin
    j:=posex(';',report_stars,i); //find end of entry
    delete(report_stars,i,j-i+1); //delete entry
  end;
  report_stars:=report_stars+ hash+'|'+other_stars+';';
  if length(report_stars)>10000 then report_stars:=copy(report_stars,200,10999);//limit size. Throw oldest part away.
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


//function remove_sigma_end(s: string): string;//remove then ', σ=' at the end
//var
//  cpos:integer;
//begin
//  cpos:=pos(',',s);
//  if cpos>0 then
//     result:=copy(s,1,cpos-1)
//  else
//    result:=s;
//end;



function clean_abbreviation(s: string; remove_underscore : boolean): string;
var
  space : integer;
begin
  space:= posex(' ',s,4);
  if space>0 then
    result:=copy(s,1,space-1)
  else
    result:=s;
  if remove_underscore then
    result:=stringreplace(result,'_',' ',[rfReplaceAll]);
end;


procedure get_info;//get settings
begin
  with form_aavso1 do
  begin
    obscode:=obscode1.text;
//    abbrev_var:=remove_sigma_end(abbrv_variable1.text);
    delim_pos:=delimiter1.itemindex;
    baa_style:=baa_style1.checked;
    sort_alphabetically:=sort_alphabetically1.checked;
    apply_transformation:=apply_transformation1.checked;

    hjd_date:=hjd1.checked;
    ensemble_database:=ensemble_database1.checked;
    obstype:=obstype1.ItemIndex;
  end;
end;


function retrieve_comp_magnitude(filter,columnr: integer; s: string): double;//retrieve comp magnitude from the abbrv string or online VSP
var
  v,e,err,b,theindex,source  : integer;
  s2 : string;
begin
  result:=-99;
  if columnr<0 then
    exit;


  if ((vsp_vsx_list=nil){should not happen})  then
    source:=0 //mode manual star selection. Extract magnitude from from annotation text
  else
  begin
    theindex:=stackmenu1.listview7.column[columnr+1].tag; //Caption position is always one position higher then data
    source:=vsp_vsx_list[theindex].source;//local, vsp,vsx
  end;

  if source=2 then //online vsp list. So a comparison star
  begin
    if ((filter=-1) or (filter=1)) then //V
      result:=strtofloat1(vsp[vsp_vsx_list[theindex].index].Vmag)
    else
    if ((filter=0) or (filter =24)) then  //R or Cousins red
      result:=strtofloat1(vsp[vsp_vsx_list[theindex].index].Rmag)
    else
    if filter=2 then  //Blue
      result:=strtofloat1(vsp[vsp_vsx_list[theindex].index].Bmag)
    else
    if filter=28 then //I magnitude
      result:=strtofloat1(vsp[vsp_vsx_list[theindex].index].Imag)
    else
    if filter=21 then  //SDSS-i
      result:=strtofloat1(vsp[vsp_vsx_list[theindex].index].SImag)
    else
    if filter=22 then //SDDS=r
      result:=strtofloat1(vsp[vsp_vsx_list[theindex].index].SRmag)
    else
    if filter=23 then //SDDS=g
      result:=strtofloat1(vsp[vsp_vsx_list[theindex].index].SGmag);

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
         begin
           s2:=copy(s,v,e-v-1); //local style  000-BJX-707 V=7.841_(0.021)_8.937_B-V=1.096(0.046)
           val(s2,result,err);
         end
         else
          err:=99;
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
           s2:=copy(s,b,e-b); //Local style  000-BJX-707 V=7.841_(0.021)_8.937_B-V=1.096(0.046)
           val(s2,result,err);
         end
         else
         err:=99;
      end;
      if ((err<>0) or (b=0)) then
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
  name_check:=form_aavso1.abrv_check1.text;
  if name_check='' then  exit;

  for i:=p_nr_norm to p_nr-1 do
    if ((frac((i-p_nr_norm)/3)=0) and (pos(name_check,stackmenu1.listview7.Column[i+1].Caption)>0)) then
    begin
      result:=i;
      exit;
    end;
end;

function get_checked(clb : Tchecklistbox) : Tinteger_array;
var
  i,j,count: integer;
  name_comp : string;
begin
  setlength(result,clb.count);
  count:=0;
  for j:=0 to clb.count-1 do
  begin
     if clb.Checked[j] then
     begin
       name_comp:=clb.items[j];

       //find the column
       for i:=p_nr_norm to p_nr-1 do
         if ( (frac((i-p_nr_norm)/3)=0) and (pos(name_comp,stackmenu1.listview7.Column[i+1].Caption)>0)) then  //captions are 1 position shifted
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



function  process_comp_stars(c : integer; calc_colour_index : boolean; out ratio_average: double; out standard_deviation, documented_comp_magn,B_V, V_R : double; out  warning : string): integer;// Get flux ratio for ensemble. Documented_comp_magn is only used for single comp star.
var
   i,invalid_comp,invalid,count,icon_nr, B_Vcounter,V_Rcounter  : integer;
   abbrv_c,comp_magn_str,flux_str,snr_str          : string;
   comp_magn, flux_documented,flux,sum_all_fluxes,magR,magV, magB,snr,sum_all_snr : double;
   ratios,fluxes                                  : array of double;
begin
  warning:='';
  sum_all_fluxes:=0;
  sum_all_snr:=0;
  ratio_average:=0;
  count:=0;
  setlength(ratios,length(column_comps));
  setlength(fluxes,length(column_comps));
  B_V:=0;
  V_R:=0;
  B_Vcounter:=0;
  V_Rcounter:=0;

  with form_aavso1 do
  for i:=0 to high(column_comps) do //go through the list of comps stars
  begin
    abbrv_c:=stackmenu1.listview7.Column[column_comps[i]+1].Caption ;
    comp_magn_str:=stackmenu1.listview7.Items.item[c].subitems.Strings[column_comps[i]];//measured comp magnitude
    comp_magn:=strtofloat3(comp_magn_str,invalid_comp);//measured comp magnitude
    if invalid_comp=0 then //valid conversion string to float. Magnitude could be marked saturated only. SNR and flux are still measured if star is saturated.
    begin
      icon_nr:=stackmenu1.listview7.Items.item[c].SubitemImages[P_filter];{filter icon nr}
      documented_comp_magn:=retrieve_comp_magnitude(icon_nr,column_comps[i], abbrv_c);//  retrieve the documented magnitude at passband used from the abbrev_comp string
      if documented_comp_magn<=0 then
      begin //COMP magnitude unknown. Most likely '?'
        warning:=warning+'Warning could not retrieve documented COMP magnitude for this filter. For Red and Sloan filters select AAVSO annotation online. For CV select in Gaia comp stars the local D50 or D80 or online Gaia BP.';
      end
      else
      begin //COMP magnitude known
        flux_documented:=power(10,(21-documented_comp_magn)/2.5);//21 is a bias
        flux_str:=(stackmenu1.listview7.Items.item[c].subitems.Strings[column_comps[i]+2]);
        flux:=strtofloat3(flux_str,invalid);
        if invalid=0 then
        begin

          snr_str:=(stackmenu1.listview7.Items.item[c].subitems.Strings[column_comps[i]+2]);
          snr:=strtofloat3(snr_str,invalid);
          if invalid=0 then
          begin
              //Now calulate ratio*flux and sum it
            ratio_average:=ratio_average + snr*flux_documented/flux; //use snr as weight factor

            ratios[count]:=flux_documented/flux;//for standard deviation calculation
            fluxes[count]:=flux_documented;//for standard deviation calculation

            sum_all_fluxes:=sum_all_fluxes+flux_documented;
            sum_all_snr:=sum_all_snr + snr;
            inc(count);

            if calc_colour_index then
            begin
              magR:=retrieve_comp_magnitude(0,column_comps[i], abbrv_c);
              magV:=retrieve_comp_magnitude(1,column_comps[i], abbrv_c);
              magB:=retrieve_comp_magnitude(2,column_comps[i], abbrv_c);
              if ((magB<>0) and (magV<>0)) then
              begin
                B_V:=B_V+snr*(magB-magV);
                inc(B_Vcounter);
              end;
              if ((magV<>0) and (magR<>0)) then
              begin
                V_R:=V_R+snr*(magV-magR);
                inc(V_Rcounter);
              end;
            end;
          end;//valid snr

        end;//valid fluxe
      end;
    end
    else
    warning:=warning+'Ignored invalid '+copy(abbrv_c,1,11)+'. ';
  end;//for loop
  if sum_all_fluxes<>0 then
  begin
    ratio_average:=ratio_average/sum_all_snr; // So the mean of all comp stars.  Magnitude_measured:= 21- ln(ratio*flux_measured)*2.5/ln(10)
    result:=0;

    if calc_colour_index then
    begin
      if B_Vcounter>0 then B_V:=B_V/sum_all_snr else B_V:=-99;//average value of all comp stars
      if V_Rcounter>0 then V_R:=V_R/sum_all_snr else V_R:=-99;;//average value of all comp stars
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
      form_aavso1.sigma_mzero1.caption:='σ='+floattostrF(mean_sd_comp/count2,FFfixed,0,4)+', weighted standard deviation between '+inttostr(length(column_comps))+' ensemble stars.'  //  Weighted noise between the comp star(s)
  end
  else
  begin
    form_aavso1.sigma_mzero1.caption:='Saturated//No documented magnitude for used filter';
  end;
end;

procedure get_b_v_var(m : integer; out b_v_var, v_r_var : double);//calculate the b-v of the variable
var
  dum: string;
  fluxB,fluxV, fluxR,varmag_B,varmag_V, varmag_R,ratio,sd_comp,
  comp_magn,B_V, V_R, ratioV,ratioB,ratioR                          : double;
  warning : string;
  c, i, j, VIndexR, RIndex, VIndex, BIndex: Integer;
  MinDiff, Diff: Double;
begin
  with form_aavso1 do
  begin
    //Find B and V image with closest Julian day
    MinDiff := 1e10; // A very large number
    VIndex := -1;
    BIndex := -1;
    // Brute-force search: compare every green with every blue
    with stackmenu1.listview7.Items do
    for i:=0 to count-1 do {retrieve data from listview}
    if item[i].checked then
      begin
      if item[i].SubitemImages[P_filter]=1 then //V filter
      begin
        for j:=0 to count-1 do {retrieve data from listview}
        if item[j].checked then
        begin
          if item[j].SubitemImages[P_filter]=2 then //blue
           begin
             Diff := Abs(strtofloat(item[i].subitems.Strings[P_jd_mid]) - strtofloat(item[j].subitems.Strings[P_jd_mid]));
             if Diff < MinDiff then
             begin
               MinDiff := Diff;
               VIndex := i;
               BIndex := j;
             end;
           end;//checked
         end;
       end;
     end;

    //Find V and R image with closest Julian day
    MinDiff := 1e10; // A very large number
    VIndexR := -1;
    RIndex := -1;

    // Brute-force search: compare every green with every blue
    with stackmenu1.listview7.Items do
    for i:=0 to count-1 do {retrieve data from listview}
    if item[i].checked then
    begin
      if item[i].SubitemImages[P_filter]=1 then //V filter
      begin
        for j:=0 to count-1 do {retrieve data from listview}
        if item[j].checked then
        begin
          if item[j].SubitemImages[P_filter] in [0,24] then //red
          begin
            Diff := Abs(strtofloat(item[i].subitems.Strings[P_jd_mid]) - strtofloat(item[j].subitems.Strings[P_jd_mid]));
            if Diff < MinDiff then
            begin
              MinDiff := Diff;
              VIndexR := i;
              RIndex := j;
            end;
          end;//checked
        end;
      end;
    end;

    with stackmenu1.listview7.Items do
    if ((BIndex>=0) and  (VIndex>=0)) then
    begin
      dum:=item[Bindex].subitems.Strings[column_vars[m]+2];{var star flux}
      fluxB:=strtofloat2(dum);
      dum:=item[Vindex].subitems.Strings[column_vars[m]+2];{var star flux}
      fluxV:=strtofloat2(dum);


      if ((fluxB>0) and (fluxV>0) and
          (process_comp_stars(BIndex,false,ratioB,sd_comp,comp_magn,B_V, V_R,warning)=0) and //get ratio from comp stars
          (process_comp_stars(VIndex,false,ratioV,sd_comp,comp_magn,B_V, V_R,warning)=0)) then //get ratio from comp stars
        begin
          varmag_B:=21- ln(ratioB*fluxB)*2.5/ln(10); //convert var flux to magnitude using
          varmag_V:=21- ln(ratioV*fluxV)*2.5/ln(10); //convert var flux to magnitude using
          b_v_var:=varmag_B-varmag_V;
         // memo2_message('b-v var is '+floattostrF(b_v_var,FFfixed,0,3) + '. Used files '+ item[Bindex].Caption+ ' & '+ item[Vindex].Caption);
        end
      else
      begin
        if warning<>'' then memo2_message(warning);
        b_v_var:= 99;
      end;
    end;

    with stackmenu1.listview7.Items do
    if ((VIndexR>=0) and  (RIndex>=0)) then
    begin
      dum:=item[Rindex].subitems.Strings[column_vars[m]+2];{var star flux}
      fluxR:=strtofloat2(dum);
      dum:=item[VindexR].subitems.Strings[column_vars[m]+2];{var star flux}
      fluxV:=strtofloat2(dum);

      if ((fluxV>0) and (fluxR>0) and
          (process_comp_stars(VIndexR,false,ratioV,sd_comp,comp_magn,B_V, V_R,warning)=0) and //get ratio from comp stars
          (process_comp_stars(RIndex,false,ratioR,sd_comp,comp_magn,B_V, V_R,warning)=0)) then //get ratio from comp stars
        begin
          varmag_V:=21- ln(ratioV*fluxV)*2.5/ln(10); //convert var flux to magnitude using
          varmag_R:=21- ln(ratioR*fluxR)*2.5/ln(10); //convert var flux to magnitude using
          v_r_var:=varmag_V-varmag_R;
          //memo2_message('v-r var is '+floattostrF(v_r_var,FFfixed,0,3) + '. Used files '+ item[VindexR].Caption+ ' & '+ item[Rindex].Caption);
        end
      else
      begin
        if warning<>'' then memo2_message(warning);
        v_r_var:= 99;
      end;
    end;

  end;//form_aavso1
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
  i,count,countV,error2,dummy        : integer;
  abrv                               : string;
  starinfo, starinfoV                : array of Tstarinfo;
  measure_any                        : boolean;
begin
  with form_aavso1 do
  begin

    abrv_comp1.clear;
    abrv_check1.clear;
    color:=cldefault;


    ensemble_database1.caption:=('Ensemble '+stackmenu1.reference_database1.text);

    setlength(starinfo,p_nr-p_nr_norm);
    setlength(starinfoV,p_nr-p_nr_norm);
    count:=0;
    countV:=0;

    measure_any:=stackmenu1.measuring_method1.itemindex=3;


    for i:=p_nr_norm to p_nr-1 do
      if frac((i-p_nr_norm)/3)=0 then //not snr column
      begin
        abrv:=stackmenu1.listview7.Column[i+1].Caption;
        val(copy(abrv,1,1),dummy,error2);//starts with a zero?
        if error2<>0 then //variables
        begin
          starinfoV[countV].str:=abrv;//store in an array
          starinfoV[countV].x:=find_mean_measured_magnitude(i);
          inc(countV);
        end;
        if ((measure_any) or (error2=0)) then //check star or iau code
        begin
          starinfo[count].str:=abrv;//store in an array
          starinfo[count].x:=find_mean_measured_magnitude(i);
          inc(count);
        end;
      end;


    if countV>0 then //sort variables
    begin
      if sort_alphabetically1.checked=false then
      begin
        QuickSort_records(starinfoV,0,countV-1) ;{ Fast quick sort. Sorts elements in the array A containing records with indices between lo and hi}
      end;
      for i:=0 to countV-1  do  //display in ascending order
        if starinfoV[i].x>0 then
        begin
          abbrv_variable1.items.add(starinfoV[i].str);
        end
        else  //not all images analysed for SD
           abbrv_variable1.items.add(starinfoV[i].str+ ' Bad!');

    end;


    if count>0 then //sort comparison stars
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
begin
  retrieve_vsp_stars;//Very simple database.
  plot_graph;
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

procedure Tform_aavso1.abbrv_variable1ClickCheck(Sender: TObject);
var
  ClickedIndex: Integer;
begin
  ClickedIndex:=(Sender as TCheckListBox).ItemIndex;
  if abbrv_variable1.checked[clickedIndex] then
    retrieve_vsp_stars;//Very simple database.
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

procedure Tform_aavso1.test_button1Click(Sender: TObject);
var
   i : integer;
begin
  if test_mode=false then
  begin
    for i:=0 to abrv_comp1.count-1 do
      abbrv_variable1.items.Add(abrv_comp1.items[i]);
    test_mode:=true;  //allow this only once.
  end;
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
  abrv_check1.autoDropDown:=false;//then only autocomplete works with more then one character

  {$ELSE}
  abrv_check1.autoDropDown:=true;
  {$ENDIF}
end;


procedure retrieve_ra_dec(columnr: integer; out ra,dec:double);//retrieve from database arrays using the .tag
var
  theindex : integer;
begin
  try
    theindex:=stackmenu1.listview7.column[columnr+1].tag;//Caption position is always one position higher then data
    ra:=vsp_vsx_list[theindex].ra;
    dec:=vsp_vsx_list[theindex].dec;
   // memo2_message('column:  '+inttostr(columnr)+',    index:  '+inttostr(theindex)+',    '+ floattostr(ra*180/pi)+',    '+floattostr(dec*180/pi)+',  '+ stackmenu1.listview7.column[columnr+1].caption);//testing
  except;
  end;
end;

procedure annotate_star_of_column(columnCheck : integer; column_V,column_comps : Tinteger_array);
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
//    if columnV>0 then //valid
//    begin
//      mainform1.GenerateShapes(indx,100,100,3 {penwidth},stEllipse, clLime,'Var');
//      inc(indx);
//      retrieve_ra_dec(columnV,fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec);
//      celestial_to_pixel(head, fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec,true, fshapes[high(fshapes)].fitsX,fshapes[high(fshapes)].fitsY); {ra,dec to shape.fitsX,shape.fitsY}
//    end;

    if columnCheck>0 then //valid
    begin
      mainform1.GenerateShapes(indx,100,100,3 {penwidth},stSquare, clLime,'Check');
      inc(indx);
      retrieve_ra_dec(columnCheck,fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec);
      celestial_to_pixel(head, fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec,true, fshapes[high(fshapes)].fitsX,fshapes[high(fshapes)].fitsY); {ra,dec to shape.fitsX,shape.fitsY}
    end;

    if ((length(column_V)>0) and (head.cd1_1<>0)) then //valid
    begin
      for i:=0 to length(column_V)-1 do
      begin
        //memo2_message(stackmenu1.listview7.Column[column_V[i]+1].Caption);  //testing
        mainform1.GenerateShapes(indx,100,100,3 {penwidth},stEllipse, clLime,'Var'+inttostr(i));
        inc(indx);
        retrieve_ra_dec(column_V[i],fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec);
        celestial_to_pixel(head, fshapes[high(fshapes)].ra,fshapes[high(fshapes)].dec,true, fshapes[high(fshapes)].fitsX,fshapes[high(fshapes)].fitsY); {ra,dec to shape.fitsX,shape.fitsY}
      end;
    end;


    if ((length(column_Comps)>0) and (head.cd1_1<>0)) then //valid
    begin
      for i:=0 to length(column_Comps)-1 do
      begin
        //memo2_message(stackmenu1.listview7.Column[column_comps[i]+1].Caption);  //testing
        mainform1.GenerateShapes(indx,100,100,3 {penwidth},stDiamond, clLime,'Comp'+inttostr(i));
        inc(indx);
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
  scale,range, mean,ratio,sd_comp,comp_magn,dummy,flux,B_V, V_R      : double;
  text1,text2, date_format,firstfilter,magn_gaia,warning,abbrv_var   : string;
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

//  column_var:=find_correct_var_column;
  column_vars:=get_checked(form_aavso1.abbrv_variable1); //file the column_comp array
  column_check:=find_correct_check_column;
  column_comps:=get_checked(form_aavso1.abrv_comp1); //fill the column_comp array

  report_sigma_and_mean_of_check;

//  if ((column_var<0) and (column_check<0)) then exit;//no var or check star specified


  if stackmenu1.measuring_method1.itemindex>0  then //<> manual mode
    annotate_star_of_column(column_check,column_vars,column_comps);

  photometry_stdev:=0;
  setlength(data,3+length(column_comps), stackmenu1.listview7.items.count);
  for i:=0 to length(data)-1 do
    for j:=0 to length(data[0])-1 do
      data[i,j]:=0;//clear
  setlength(listcheck,length(data[0]));//list with magnitudes check star
  setlength(filtercolor,length(data[0]));//list filter colors
  count:=0;
  firstFilter:='';

  if length(column_vars)>0 then
    abbrv_var:=clean_abbreviation(stackmenu1.listview7.Column[column_vars[0]+1].Caption,true) //caption are shifted one
  else
     abbrv_var:='';

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

        if  length(column_vars)>0 then
        begin
          dum:=listview7.Items.item[c].subitems.Strings[column_vars[0]];{var star}
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

          if  length(column_vars)>0 then
          begin
            magn_gaia:=listview7.Items.item[c].subitems.Strings[column_vars[0]];{Gaia based magnitude}
            dum:=listview7.Items.item[c].subitems.Strings[column_vars[0]+2];{var star flux}

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

        end //valid comp star(s)
        else
        begin
         end;

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


    bmp.canvas.brush.color:=clmenu;
    bmp.canvas.rectangle(-1,-1, w+1, h+1);{background}

    bmp.Canvas.Pen.Color := clmenutext;
    bmp.Canvas.brush.color :=clmenu;
   // bmp.Canvas.brush.color :=clgreen;
    bmp.Canvas.Font.Color := clmenutext;
    bmp.Canvas.brush.Style:=bsclear;


    bmp.canvas.moveto(w,h-bspace+5);
    bmp.canvas.lineto(wtext-5,h-bspace+5);{x line}
    bmp.canvas.lineto(wtext-5,bspace);{y line}

    bmp.canvas.font.style:=[fsbold];
    bmp.canvas.textout(5,bspace div 2,'Magn');
    bmp.canvas.textout(w-4*bspace,h-(bspace div 2),date_format{JD (mid) or HJD});
    bmp.canvas.font.style:=[];

    text1:='Var ('+abbrv_var+')';
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

  fill_comp_and_check;//fill with stars

  if abbrv_variable1.count>0 then
     retrieve_vsp_stars;


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

  test_mode:=false;
  plot_graph;
end;


procedure Tform_aavso1.sort_alphabetically1Change(Sender: TObject);
begin
//  abbrv_variable1.sorted:=sort_alphabetically1.checked;//can not do this during dropdown. This gives an error
  abbrv_variable1.sorted:=sort_alphabetically1.checked;//can not do this during dropdown. This gives an error
  abrv_comp1.sorted:=sort_alphabetically1.checked;
  abrv_check1.sorted:=sort_alphabetically1.checked;
end;


procedure Tform_aavso1.suggest_check1Change(Sender: TObject);
begin
  form_aavso1.abbrv_variable1Change(nil);
end;



procedure Tform_aavso1.report_to_clipboard1Click(Sender: TObject);
var
    c,date_column,invalid_var,invalid_check,invalid_comp,i,icon_nr,m   : integer;
    err,snr_str,airmass_str, delim,fnG,detype,baa_extra,magn_type,filter_used,settings,date_format,date_observation,
    abbrv_var_clean,abbrv_check_clean,abbrv_comp_clean,abbrv_comp_clean_report,comp_magn_info,var_magn_str,check_magn_str,comp_magn_str,comments,invalidstr,
    var_flux_str,check_flux_str,warning,transformation, transform_all_factors,transf_str  : string;
    stdev_valid,apply_transformation : boolean;
    snr_value,err_by_snr,comp_magn, var_magn,check_magn,var_flux,ratio,check_flux,sd_comp,B_V, V_R,var_Vcorrection,var_Bcorrection,var_Rcorrection,v_r_var,b_v_var : double;
    PNG: TPortableNetworkGraphic;{FPC}
    vsep : char;
begin
  get_info;//update abbrev_var and others


  abbrev_check:=abrv_check1.text;
  if ((length(abbrev_check)<1) or (column_check<0)) then
  begin
    abrv_check1.color:=clred;
    exit;
  end
  else
    abrv_check1.color:=cldefault;

  abbrv_check_clean:=clean_abbreviation(abbrev_check,false); //no underscores in COMP stars.

  variable_clean:='';
  if length(column_vars)>0 then
  begin
    abbrv_variable1.color:=cldefault;
    // column_comps,column_vars
    ; //star with check star
    for i:=0 to length(column_vars)-1 do
      variable_clean:= variable_clean+clean_abbreviation(stackmenu1.listview7.Column[column_vars[i]+1].Caption,false)+'|' //variable_clean with still underscore. Note the captions are one position shifted.
  end
  else
  begin
    abbrv_variable1.color:=clred;
    exit;
  end;


  abbrv_comp_clean:='';
  if length(column_comps)>0 then  //add comp stars
  begin
    abrv_comp1.color:=cldefault;
    // column_comps,column_vars
    for i:=0 to length(column_comps)-1 do
      abbrv_comp_clean:= abbrv_comp_clean+clean_abbreviation(stackmenu1.listview7.Column[column_comps[i]+1].Caption,false)+'|'; //variable_clean with still underscore. Note the captions are one position shifted.
  end
  else
  begin
    abrv_comp1.color:=clred;
    exit;
  end;

  delete(abbrv_comp_clean,length(variable_clean),1);//remove last "|"
  store_vsp_stars( abbrv_check_clean+'|'+variable_clean+abbrv_comp_clean); //simple database in settings key report_stars




  apply_transformation:=apply_transformation1.checked;
  stdev_valid:=(photometry_stdev>0.0001);
  if delimiter1.text=',' then vsep:=';' else vsep:=',';//valid seperator


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


  if ensemble_database1.checked then
    settings:=stackmenu1.reference_database1.text+vsep
  else
    settings:=''; //not relevant
  settings:=settings+' aperture='+stackmenu1.flux_aperture1.text+' HFD'+vsep+' annulus='+stackmenu1.annulus_radius1.text+' HFD';

  if ensemble_database1.checked then
     comments:='CMAG ensemble using transformed Gaia magnitudes.'
   else
     comments:='';

  if apply_transformation then
  begin
    transform_all_factors:=
    '#Tbv= ' + TbvSTR+#13+#10+
    '#Tb_bv= ' + Tb_bvSTR+#13+#10+
    '#Tv_bv= ' + Tv_bvSTR+#13+#10+
    '#Tvr= ' + TvrSTR+#13+#10+
    '#Tv_vr= ' + Tv_vrSTR+#13+#10+
    '#Tr_vr= ' + Tr_vrSTR+#13+#10+
    '#Transf corr B = Tb_bv * Tbv *((b-v) - (B-V))'+#13+#10
  end
  else
    transform_all_factors:='';

  if stackmenu1.annotate_mode1.itemindex<4 then //local database
    chartID:='na'; //else it comes from VSP download

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
       for m:=0 to length(column_vars)-1 do //do all variables. This is not an efficient loop scnce the comp stars are read every time but was easy to code.
       begin //var loop
         snr_str:=listview7.Items.item[c].subitems.Strings[column_vars[m]+1 {P_snr}];
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

               invalid_comp:=process_comp_stars(c,apply_transformation,ratio,sd_comp,comp_magn,B_V, V_R,warning);//Magnitude_measured:= 21- ln(ratio*flux_measured)*2.5/log(10)

               comp_magn_info:=comp_magn_info+warning;
               if invalid_comp=0 then //valid comp star(s)
               begin
                     var_flux_str:=listview7.Items.item[c].subitems.Strings[column_vars[m]+2];
                     var_flux:=strtofloat3(var_flux_str,invalid_var);

                     if invalid_var=0 then //valid conversion string to float
                       var_magn:= 21- ln(ratio*var_flux)*2.5/ln(10)
                     else
                       var_magn:=99;

                     get_b_v_var(m,{out} b_v_var, v_r_var);//calculate the b-v of the variable


                     transformation:='';
                     if apply_transformation then
                     begin
                       //transformation
                       // Tv_bv * Tbv* ((b-v)tgt – (B-V)comp)
                       transf_str:='YES';
                       icon_nr:=listview7.Items.item[c].SubitemImages[P_filter];
                       if icon_nr=2 then //B correction
                       begin
                         if ((B_V<>-99) and (b_v_var<>99)) then
                         begin
                           var_Bcorrection:= strtofloat2(Tb_bvSTR) * strtofloat2(TbvSTR) * (b_v_var - B_V{comp});
                           var_magn:=var_magn+var_Bcorrection;
                           transformation:='Transf corr. '+floattostrF(var_Bcorrection,ffFixed,0,3)+'='+Tb_bvSTR+'*'+TbvSTR+'*('+floattostrF(b_v_var,ffFixed,0,3)+'-'+floattostrF(B_V,ffFixed,0,3)+'), Filter used '+filter_used+',';
                           filter_used:='B';//change TB to B
                         end
                         else
                         begin
                           transformation:='Transf failed. Could not retrieve B-V';
                           transf_str:='NO';
                         end;
                       end
                       else
                       if icon_nr=1 then//V correction
                       begin
                         if ((B_V<>-99)  and (b_v_var<>99)) then
                         begin
                           var_Vcorrection:= strtofloat2(Tv_bvSTR) * strtofloat2(TbvSTR) *( b_v_var{var} - B_V{comp});
                           var_magn:=var_magn+var_Vcorrection;
                           transformation:='Transf corr. '+floattostrF(var_Vcorrection,ffFixed,0,3)+'='+Tv_bvSTR+'*'+TbvSTR+'*('+floattostrF(b_v_var,ffFixed,0,3)+'-'+floattostrF(B_V,ffFixed,0,3)+'), Filter used '+filter_used+',';
                           filter_used:='V';//change TG to V
                         end
                         else
                         begin
                           transformation:='Transf failed. Could not retrieve B-V';
                           transf_str:='NO';
                         end;

                       end
                       else
                       if ((icon_nr=0) or (icon_nr=24)) then//R correction
                       begin
                         if ((V_R<>-99) and  (v_r_var<>99)) then
                         begin
                           var_Rcorrection:= strtofloat2(Tr_vrSTR) * strtofloat2(TvrSTR) * (v_r_var{var} - V_R{comp});
                           var_magn:=var_magn + var_Rcorrection;
                           transformation:='Transf corr. '+floattostrF(var_Rcorrection,ffFixed,0,3)+'='+Tr_vrSTR+'*'+TvrSTR+'*('+floattostrF(v_r_var,ffFixed,0,3)+'-'+floattostrF(V_R,ffFixed,0,3)+'), Filter used '+filter_used+',';
                           filter_used:='R';//change TR to R
                         end
                         else
                         begin
                           transformation:='Transf failed. Could not retrieve V-R';
                           transf_str:='NO';
                         end;

                       end;
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
                       abbrv_comp_clean_report:=clean_abbreviation(stackmenu1.listview7.Column[column_comps[i]+1].Caption,true);//single comp star
                       comp_magn_str:=floattostrF(comp_magn,ffFixed,0,3);//from process_comp_stars
                     end;

               end ;//valid comp_str
             end //no ensemble mode
             else
             begin
               var_magn_str:=listview7.Items.item[c].subitems.Strings[column_vars[m]];
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

             abbrv_var_clean:=clean_abbreviation(stackmenu1.listview7.Column[column_vars[m]+1].Caption,true); //Note the captions are one position shifted.

            // dummy:=ListView7.Items.item[c].SubitemImages[P_calibration];
            // dummy2:=ListView7.Items.item[c].SubitemImages[P_filter];

             if ensemble_database1.Checked then //else comparison stars are used.
               if ListView7.Items.item[c].SubitemImages[P_calibration]<>ListView7.Items.item[c].SubitemImages[P_filter] then
                  comp_magn_info:=comp_magn_info+'  WARNING INCOMPATIBLE FILTER AND DATABASE PASSBAND! VALID FILTERS CV/V/TG/B/R/SI/SR/SG.';

             aavso_report:= aavso_report+ invalidstr+ abbrv_var_clean + delim +
                            StringReplace(listview7.Items.item[c].subitems.Strings[date_column],',','.',[])+delim+
                            var_magn_str+delim+
                            err+
                            delim+filter_used+delim+
                            transf_str{'NO'}+delim+
                            'STD'+delim+
                            abbrv_comp_clean_report+delim+
                            comp_magn_str+delim+
                            abbrv_check_clean+delim+
                            check_magn_str+delim+
                            airmass_str+delim+
                            'na'+delim+ {group}
                            chartID +delim+
                            transformation+comp_magn_info+' ('+settings+ ')'+#13+#10;


             date_observation:=copy(listview7.Items.item[c].subitems.Strings[P_date],1,10);
           end;// snr_str<>''
         end;// valid snr loop
       end;//var loop


     end;
   end;

  to_clipboard:=(sender=report_to_clipboard1); {report to clipboard of file}


  memo2_message(aavso_report);
  if to_clipboard then
    Clipboard.AsText:=#13+#10+aavso_report
  else
  begin
    savedialog1.filename:=stringreplace(clean_abbreviation(stackmenu1.listview7.Column[column_vars[m]+1].Caption,false),'?','',[rfReplaceAll]) +'_'+date_observation+'_report.txt';
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



end.

