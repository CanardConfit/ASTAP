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
  clipbrd, ExtCtrls, Menus;

type

  { Tform_aavso1 }

  Tform_aavso1 = class(TForm)
    baa_style1: TCheckBox;
    delta_bv1: TEdit;
    Image_photometry1: TImage;
    Label10: TLabel;
    Label11: TLabel;
    Label9: TLabel;
    name_variable1: TComboBox;
    name_variable2: TEdit;
    magnitude_slope1: TEdit;
    report_error1: TLabel;
    MenuItem1: TMenuItem;
    name_check1: TComboBox;
    PopupMenu1: TPopupMenu;
    report_to_clipboard1: TButton;
    report_to_file1: TButton;
    delimiter1: TComboBox;
    Comparison1: TEdit;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label3: TLabel;
    obscode1: TEdit;
    Label1: TLabel;
    Filter1: TComboBox;
    procedure FormResize(Sender: TObject);
    procedure Image_photometry1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure MenuItem1Click(Sender: TObject);
    procedure name_check1Change(Sender: TObject);
    procedure name_check1DropDown(Sender: TObject);
    procedure name_variable1Change(Sender: TObject);
    procedure name_variable1DropDown(Sender: TObject);
    procedure report_to_clipboard1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  form_aavso1: Tform_aavso1;

var
  obscode       : string='';
  abbreviation_check : string='';
  name_check_IAU : string='';
  abbreviation_var_IAU   : string='';
  name_var   : string='';
  delim_pos  : integer=0;
  to_clipboard  : boolean=true;
  baa_style  : boolean=true;
  aavso_filter_index: integer=0;
  delta_bv : double=0;
  magnitude_slope    : double=0;

var
  aavso_report : string;

procedure plot_graph; {plot curve}

implementation
{$R *.lfm}

uses astap_main,
     unit_stack,
     unit_star_database;{for name_database only}


var
  jd_min,jd_max,magn_min,magn_max : double;
  w,h,bspace,column_var,column_check  :integer;



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
    abbreviation_check:=name_check1.text;
    delim_pos:=delimiter1.itemindex;
    baa_style:=baa_style1.checked;
    aavso_filter_index:=filter1.itemindex;
    delta_bv:=strtofloat2(form_aavso1.delta_bv1.text);
    magnitude_slope:=strtofloat2(form_aavso1.magnitude_slope1.text);
  end;
end;


procedure Tform_aavso1.report_to_clipboard1Click(Sender: TObject);
var
    c  : integer;
    err,err_message,snr_str,airmass_str, delim,fn,fnG,detype,baa_extra,magn_type,filter_used: string;
    stdev_valid : boolean;
    snr_value,err_by_snr  : double;
    PNG: TPortableNetworkGraphic;{FPC}


    function transform_magn(mag: string):string;
    var
       m : double;
    begin
      m:=strtofloat2(mag);
      str(m+delta_bv*magnitude_slope:5:3,result);
    end;

begin
  get_info;

  stdev_valid:=(photometry_stdev>0.0001);
  if stdev_valid then
    err_message:='max(StDev:2/SNR) used for MERR.'
  else
    err_message:='2/SNR used for MERR.';

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
  aavso_report:= '#TYPE='+detype+#13+#10+
                 '#OBSCODE='+obscode+#13+#10+
                 '#SOFTWARE=ASTAP, photometry version 1.1.0'+#13+#10+
                 '#DELIM='+delimiter1.text+#13+#10+
                 '#DATE=JD'+#13+#10+
                 '#OBSTYPE=CCD'+#13+#10+
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

       airmass_str:=listview7.Items.item[c].subitems.Strings[P_airmass];
       if airmass_str='' then  airmass_str:='na' else airmass_str:=stringreplace(airmass_str,',','.',[]);

       if reference_database1.itemindex=0 then //local database
         if pos('v',name_database)>0 then magn_type:=', transformed to Johnson-V. ' else magn_type:=' using BM magnitude. '
       else  //online database
         magn_type:=', transformed '+stackmenu1.reference_database1.text;

       if snr_str<>'' then
       begin
         if filter1.itemindex=0 then
           filter_used:=listview7.Items.item[c].subitems.Strings[P_filter] //take from header
         else
           filter_used:=copy(filter1.text,1,2);//manual input
         aavso_report:= aavso_report+ name_var+delim+
                        StringReplace(listview7.Items.item[c].subitems.Strings[P_jd_mid],',','.',[])+delim+
//                        StringReplace(listview7.Items.item[c].subitems.Strings[P_magn1],',','.',[])+delim+
                        transform_magn(listview7.Items.item[c].subitems.Strings[column_var{P_magn1}])+delim+
                        err+
                        delim+filter_used+delim+
                       'NO'+delim+
                       'STD'+delim+
                       'ENSEMBLE'+delim+
                       'na'+delim+
                       abbreviation_check+delim+
                       stringreplace(listview7.Items.item[c].subitems.Strings[column_check{P_magn2}],',','.',[])+delim+
                       airmass_str+delim+
                       'na'+delim+ {group}
                       abbreviation_var_IAU+delim+
                       'Ensemble of Gaia DR3 stars'+magn_type+' '+err_message+#13+#10;

       end;
     end;
   end;

  to_clipboard:=(sender=report_to_clipboard1); {report to clipboard of file}


  memo2_message(aavso_report);
  if to_clipboard then
    Clipboard.AsText:=aavso_report
  else
  begin
    fn:=ChangeFileExt(filename2,'_report.txt');
    log_to_file2(fn, aavso_report);

    png:= TPortableNetworkGraphic.Create;   {FPC}
    try
      PNG.Assign(Image_photometry1.Picture.Graphic);    //Convert data into png
      fnG:=ChangeFileExt(filename2,'_graph.png');
      PNG.SaveToFile(fnG);
      finally
       PNG.Free;
    end;

    memo2_message('AAVSO report written to: '+fn +' and '+fnG );
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

procedure Tform_aavso1.name_check1Change(Sender: TObject);
begin
  plot_graph;
end;

procedure Tform_aavso1.name_check1DropDown(Sender: TObject);
var
  i: integer;
begin
  name_check1.items.clear;

  name_check1.items.add(mainwindow.Shape_alignment_marker2.HINT);
  name_check1.items.add(abbreviation_check);//the last name
  name_check1.items.add(name_check_IAU);// created from position


  for i:=p_nr_varmax+1 to p_nr do
    if odd(i-p_nr_varmax) then
      name_check1.items.add(stackmenu1.listview7.Column[i].Caption);
end;


procedure Tform_aavso1.name_variable1Change(Sender: TObject);
begin
  plot_graph;
end;


procedure Tform_aavso1.name_variable1DropDown(Sender: TObject);
var
  i: integer;
begin
  name_variable1.items.clear;

  name_variable1.items.add(mainwindow.Shape_alignment_marker1.HINT);
  name_variable1.items.add(object_name);//from header
  name_variable1.items.add(name_var);

  for i:=p_nr_norm+1 to p_nr do
    if odd(i-p_nr_norm) then
      name_variable1.items.add(stackmenu1.listview7.Column[i].Caption);
end;

function find_correct_var_column : integer;
var
  i: integer;
//  s1,s2: string;
begin
  for i:=p_nr_norm+1 to p_nr_varmax do
  begin
  //  s1:=form_aavso1.name_variable1.text;
  //  s2:=stackmenu1.listview7.Column[i].Caption;
    if ((odd(i-p_nr_norm)) and (form_aavso1.name_variable1.text=stackmenu1.listview7.Column[i].Caption)) then
    begin
      result:=i-1;
      exit;
    end;
  end;
  result:=P_magn1;
end;

function find_correct_check_column : integer;
var
  i: integer;
begin
  for i:=p_nr_varmax+1 to p_nr do
    if ((odd(i-p_nr_varmax)) and (form_aavso1.name_check1.text=stackmenu1.listview7.Column[i].Caption)) then
    begin
      result:=i-1;
      exit;
    end;
  result:=P_magn2;
end;


procedure Tform_aavso1.FormResize(Sender: TObject);
begin
  plot_graph;
end;


procedure plot_graph; {plot curve}
var
  x1,y1,c,textp1,textp2,textp3,nrmarkX, nrmarkY,wtext : integer;
  scale,range         : double;
  text1,text2   : string;
  bmp: TBitmap;
  dum:string;
  data : array of array of double;
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

  w:=max(form_aavso1.Image_photometry1.width,(len*2)*stackmenu1.listview7.items.count);{make graph large enough for all points}
  h:=max(100,form_aavso1.Image_photometry1.height);
  bspace:=2*mainwindow.image1.Canvas.textheight('T');{{border space graph. Also for 4k with "make everything bigger"}
  wtext:=mainwindow.image1.Canvas.textwidth('12.3456');

  column_var:= find_correct_var_column;
  column_check:=find_correct_check_column;
  setlength(data,4, stackmenu1.listview7.items.count);
  with stackmenu1 do
  for c:=0 to listview7.items.count-1 do {retrieve data from listview}
  begin
    if listview7.Items.item[c].checked then
    begin
      dum:=(listview7.Items.item[c].subitems.Strings[P_jd_mid]);
      if dum<>'' then  data[0,c]:=strtofloat(dum) else data[0,c]:=0;
      if data[0,c]<>0 then
      begin
        jd_max:=max(jd_max,data[0,c]);
        jd_min:=min(jd_min,data[0,c]);
      end;

      dum:=(listview7.Items.item[c].subitems.Strings[column_var]);{var star}
      if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then  data[1,c]:=strtofloat(dum) else data[1,c]:=0;
      if data[1,c]<>0 then
      begin
        magn_max:=max(magn_max,data[1,c]);
        magn_min:=min(magn_min,data[1,c]);
      end;

      dum:=(listview7.Items.item[c].subitems.Strings[column_check]);{chk star}
      if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then  data[2,c]:=strtofloat(dum) else data[2,c]:=0;
      if data[2,c]<>0 then
      begin
        magn_max:=max(magn_max,data[2,c]);
        magn_min:=min(magn_min,data[2,c]);
      end;

      dum:=(listview7.Items.item[c].subitems.Strings[P_magn3]); {3}
      try
      if ((length(dum)>1 {not a ?}) and (dum[1]<>'S'{saturated})) then  data[3,c]:=strtofloat(dum) else data[3,c]:=0;

      except
        data[3,c]:=0;
      end;
      if data[3,c]<>0 then
      begin
        magn_max:=max(magn_max,data[3,c]);
        magn_min:=min(magn_min,data[3,c]);
      end;
    end;

  end;

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
    bmp.canvas.textout(w-4*bspace,h-(bspace div 2),'JD (mid)');
    bmp.canvas.font.style:=[];

    text1:='Var ('+form_aavso1.name_variable1.text+')';
    textp1:=10+wtext;
    bmp.canvas.textout(textp1,len*3,text1);

    textp2:=textp1+40+bmp.canvas.textwidth(text1);
    text2:='Chk ('+form_aavso1.name_check1.text+')';
    bmp.canvas.textout(textp2,len*3,text2);

    textp3:=textp2+40+bmp.canvas.textwidth(text2);
    bmp.canvas.textout(textp3,len*3,'3');

    if object_name<>'' then
      bmp.canvas.textout(w div 2,len*3,object_name)
    else
      bmp.canvas.textout(w div 2,len*3,ExtractFilePath(filename2));

    nrmarkX:=trunc(w*5/1000);
    for c:=0 to nrmarkX do {markers x line}
    begin
      x1:=wtext+round((w-bspace*2)*c/nrmarkX); {x scale has bspace pixels left and right space}
      y1:=h-bspace+5;
      bmp.canvas.moveto(x1,y1);
      bmp.canvas.lineto(x1,y1+5);
      bmp.canvas.textout(x1,y1+5,floattostrf(jd_min+(jd_max-jd_min)*c/nrmarkX,ffFixed,12,5));
    end;

    nrmarkY:=trunc(h*5/400);
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
    begin
      plot_point(wtext+round((w-bspace*2)*(data[0,c]-jd_min)/(jd_max-jd_min)), round(bspace+(h-bspace*2)*(data[2,c]-magn_min)/(magn_max-magn_min)   ),round(scale*photometry_stdev*2.5)); {chk}
    end;

    bmp.Canvas.Pen.Color := clBlue;
    bmp.Canvas.brush.color :=clBlue;
    plot_point(textp3,len*3,0);
    for c:=0 to length(data[0])-1 do
    begin
      plot_point(wtext+round((w-bspace*2)*(data[0,c]-jd_min)/(jd_max-jd_min)), round(bspace+(h-bspace*2)*(data[3,c]-magn_min)/(magn_max-magn_min)   ),0); {3}
    end;

    bmp.Canvas.Pen.Color := clRed;
    bmp.Canvas.brush.color :=clRed;
    plot_point(textp1,len*3,0);
    for c:=0 to length(data[0])-1 do
    begin
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
end;


procedure Tform_aavso1.FormShow(Sender: TObject);
begin
  obscode1.text:=obscode;
  if length(mainwindow.Shape_alignment_marker1.HINT)>2 then name_variable1.text:=mainwindow.Shape_alignment_marker1.HINT
  else
  if object_name<>'' then name_variable1.text:=object_name
  else
  name_variable1.text:=name_var;


  if length(mainwindow.Shape_alignment_marker2.HINT)>2 then name_check1.text:=mainwindow.Shape_alignment_marker2.HINT
  else
  name_check1.text:=abbreviation_check;

  delimiter1.itemindex:=delim_pos;
  baa_style1.checked:=baa_style;
  if stackmenu1.reference_database1.itemindex=0 then
    Comparison1.Text:=name_database
  else
  Comparison1.Text:=stackmenu1.reference_database1.text;

  filter1.itemindex:=aavso_filter_index;

  form_aavso1.delta_bv1.text:=floattostrF(delta_bv,ffFixed,5,3);
  form_aavso1.magnitude_slope1.text:=floattostrF(magnitude_slope,ffFixed,5,3);


  aavso_report:='';
  plot_graph;

end;

end.

