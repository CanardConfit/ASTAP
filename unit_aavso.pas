unit unit_aavso;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { Tform_aavso1 }

  Tform_aavso1 = class(TForm)
    Button1: TButton;
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
    procedure Button1Click(Sender: TObject);
    procedure Filter1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
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

procedure Tform_aavso1.Button1Click(Sender: TObject);
var
    c  : integer;
    err,err_message,snr_str,delim: string;
    use_stdev_error: boolean;
begin
  get_info;

  use_stdev_error:=(photometry_error>0.0001);
  if use_stdev_error then
  begin
    str(photometry_error:1:4,err);{standard deviation of CK or C star, highest value}
    err_message:='StDev used for MERR.';
  end
  else
  err_message:='2/SNR used for MERR.';

  delim:=delimiter1.text;
  if delim='tab' then delim:=#9;

  aavso_report:=  #13+#10+
                 '#TYPE=Extended'+#13+#10+
                 '#OBSCODE='+obscode+#13+#10+
                 '#SOFTWARE=ASTAP, photometry version ß0.0'+#13+#10+
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
       if  use_stdev_error=false then
       begin
         if snr_str<>'' then
         str(2 {1.087}/strtoint(snr_str):1:4,err){SNR method.Note SNR is in ADU but for snr above 20 error is small. For e-/adu<1 error becomes larger. Factor 2 is a practical factor}
         else
         err:='na';
       end;
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
  form_aavso1.close;   {transfer variables. Normally this form is not loaded}
  mainwindow.setfocus;
end;

procedure Tform_aavso1.Filter1Change(Sender: TObject);
begin

end;


procedure Tform_aavso1.FormClose(Sender: TObject; var CloseAction: TCloseAction );
begin
  get_info;
end;

procedure Tform_aavso1.FormCreate(Sender: TObject);
begin

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
end;

end.

