unit unit_aavso;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, math;

type

  { Tform_aavso1 }

  Tform_aavso1 = class(TForm)
    report_to_clipboard1: TButton;
    report_to_file1: TButton;
    delimiter1: TComboBox;
    Comparison1: TEdit;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    name_variable1: TEdit;
    Label6: TLabel;
    Label8: TLabel;
    Label3: TLabel;
    obscode1: TEdit;
    Label1: TLabel;
    name_check1: TEdit;
    Filter1: TComboBox;
    procedure report_to_clipboard1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  form_aavso1: Tform_aavso1;

const
  obscode       : string='';
  filter_type   : string='';
  name_check : string='';
  name_var   : string='';
  delim_pos  : integer=0;
  to_clipboard  : boolean=true;

var
  aavso_report : string;


implementation
{$R *.lfm}

uses astap_main, unit_stack;

{ Tform_aavso1 }

function floattostr3(x:double):string;
begin
  str(x:0:3,result);
end;

procedure get_info;
begin
  with form_aavso1 do
  begin
    obscode:=obscode1.text;
    name_var:=name_variable1.text;
    name_check:=name_check1.text;
    filter_type:=filter1.text;
    delim_pos:=delimiter1.itemindex;
  end;
end;

procedure Tform_aavso1.report_to_clipboard1Click(Sender: TObject);
var
    c  : integer;
    err,err_message,snr_str,delim: string;
    stdev_valid : boolean;
    snr_value,err_by_snr   : double;
begin
  get_info;

  stdev_valid:=(photometry_stdev>0.0001);
  if stdev_valid then
    err_message:='max(StDev,2/SNR) used for MERR.'
  else
    err_message:='2/SNR used for MERR.';

  delim:=delimiter1.text;
  if delim='tab' then delim:=#9;

  aavso_report:= '#TYPE=Extended'+#13+#10+
                 '#OBSCODE='+obscode+#13+#10+
                 '#SOFTWARE=ASTAP, photometry version ß0.1'+#13+#10+
                 '#DELIM='+delimiter1.text+#13+#10+
                 '#DATE=JD'+#13+#10+
                 '#OBSTYPE=CCD'+#13+#10+
                 '#'+#13+#10+
                 '#NAME'+delim+'DATE'+delim+'MAG'+delim+'MERR'+delim+'FILT'+delim+'TRANS'+delim+'MTYPE'+delim+'CNAME'+delim+'CMAG'+delim+'KNAME'+delim+'KMAG'+delim+'AIRMASS'+delim+'GROUP'+delim+'CHART'+delim+'NOTES'+#13+#10;

   with stackmenu1 do
   for c:=0 to listview7.items.count-1 do
   begin
     if listview7.Items.item[c].checked then
     begin
       snr_str:=listview7.Items.item[c].subitems.Strings[P_snr];
       if snr_str<>'' then  snr_value:=strtoint(snr_str) else snr_value:=0;
       if snr_value<>0 then
         err_by_snr:=2 {1.087}/strtoint(snr_str)
       else
         err_by_snr:=0;

       if  stdev_valid=false then
       begin
         if snr_value>0 then
         str(err_by_snr:1:4,err){SNR method.Note SNR is in ADU but for snr above 20 error is small. For e-/adu<1 error becomes larger. Factor 2 is a practical factor}
         else
         err:='na';
       end
       else
       str(max(err_by_snr, photometry_stdev):1:4,err);{standard deviation of CK  star}


       if snr_str<>'' then
       aavso_report:= aavso_report+ name_var+delim+
                      StringReplace(listview7.Items.item[c].subitems.Strings[P_jd_mid],',','.',[])+delim+
                      StringReplace(listview7.Items.item[c].subitems.Strings[P_magn1],',','.',[])+delim+
                      err+
                      delim+copy(filter_type,1,2)+delim+
                     'NO'+delim+
                     'STD'+delim+
                     'ENSEMBLE'+delim+
                     'na'+delim+
                     name_check+delim+
                     stringreplace(listview7.Items.item[c].subitems.Strings[P_magn2],',','.',[])+delim+
                     'na'+delim+
                     'na'+delim+
                     'na'+delim+
                     'Ensemble of Gaia eDR3 stars '+star_database1.text+'. '+err_message+#13+#10;
     end;
   end;

  to_clipboard:=(sender=report_to_clipboard1); {report to clipboard of file}

  form_aavso1.close;   {transfer variables. Normally this form is not loaded}
  mainwindow.setfocus;
end;


procedure Tform_aavso1.FormClose(Sender: TObject; var CloseAction: TCloseAction );
begin
  get_info;
end;


procedure Tform_aavso1.FormShow(Sender: TObject);
begin
  obscode1.text:=obscode;
  if object_name<>'' then name_variable1.text:=object_name
    else
    name_variable1.text:=name_var;
  name_check1.text:=name_check;
  filter1.text:=filter_type;
  delimiter1.itemindex:=delim_pos;
  Comparison1.Text:=stackmenu1.star_database1.text;

  aavso_report:='';
end;

end.

