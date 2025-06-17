unit unit_transformation;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,math;

type

  { TForm_transformation1 }

  TForm_transformation1 = class(TForm)
    Button1: TButton;
    Label10: TLabel;
    Label11: TLabel;
    error_label1: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label5: TLabel;
    sigma_transformation1: TComboBox;
    Tbv1: TEdit;
    Tb_bv1: TEdit;
    Tvr1: TEdit;
    Tv_vr1: TEdit;
    Tv_bv1: TEdit;
    Tr_vr1: TEdit;
    Image_transformation1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;

    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sigma_transformation1EditingDone(Sender: TObject);
    procedure Tbv1Click(Sender: TObject);
    procedure Tb_bv1Click(Sender: TObject);
    procedure Tr_vr1Click(Sender: TObject);
    procedure Tvr1Click(Sender: TObject);
    procedure Tv_bv1Click(Sender: TObject);
    procedure Tv_vr1Click(Sender: TObject);
  private

  public

  end;

var
  Form_transformation1: TForm_transformation1;

  sigma_transformationSTR,
  TbvSTR,
  Tb_bvSTR,
  TvrSTR,
  Tv_vrSTR,
  Tv_bvSTR,
  Tr_vrSTR : string;


implementation

uses astap_main,unit_stack, unit_contour, unit_aavso;

{$R *.lfm}

{ TForm_transformation1 }

var
  B_list,V_listB,V_listR,R_list,I_list,SG_list,SR_list,SI_list, B_list_documented,V_list_documentedB,V_list_documentedR, R_list_documented  : array of double;
  Tbv, Tbv_intercept, Tbv_sd, Tv_bv, Tv_bv_intercept, Tv_bv_sd, Tb_bv, Tb_bv_intercept, Tb_bv_sd,
  Tvr, Tvr_intercept, Tvr_sd, Tr_vr, Tr_vr_intercept, Tr_vr_sd, Tv_vr, Tv_vr_intercept, Tv_vr_sd : double;


const
  idx : integer=0; //which graph is shown
  transf_filter_sigma :double=2; //to filter out outliers

procedure plot_transformation_graph;
var
  i,N,w,h: Integer;
  x_vals, y_vals: array of double;
  xmin, xmax, ymin, ymax, tick_step, tick_val,slope, intercept, sd  : double;
  x_pixel, y_pixel,nticks, x1, y1,wtext,bspace  : Integer;
  x_label, y_label: string ;
  bmp: TBitmap;
const
  len=3;

      procedure plot_point(x, y: Integer);
      begin
        if ((x > 0) and (y > 0) and (x <= w) and (y <= h)) then
          bmp.canvas.Ellipse(x - len, y - len, x + 1 + len, y + 1 + len);
      end;

      function scale_x_value(x: double): Integer;
      begin
        Result := round(wtext + ((w - bspace * 2) * (x - xmin) / (xmax - xmin)));
      end;

      function scale_y_value(y: double): Integer;
      begin
        Result := Round(bspace + (h - bspace * 2) * (ymax - y) / (ymax - ymin));
      end;
begin
  if ((V_listB=nil) and (V_listB=nil)) then
  begin
//    form_transformation1.error_label1.caption:='No comparison star data!. Select standard field.';
    exit;//no data
  end;

  wtext:=mainform1.image1.Canvas.textwidth('12.3456');
  bspace:=3*mainform1.image1.Canvas.textheight('T');{border space graph. Also for 4k with "make everything bigger"}

  if idx<= 2 then
     N := Length(B_list_documented) //B-V
  else
     N := Length(V_list_documentedR);//V-R

  if N=0 then Exit;

  w:=max(form_transformation1.Image_transformation1.width,n);{make graph large enough for all points}
  h:=max(form_transformation1.Image_transformation1.height,N);


  SetLength(x_vals, N);
  SetLength(y_vals, N);

  // Choose which transform we're plotting by setting y = b−v or V−v or B−b
  for i := 0 to N - 1 do
  begin
    if idx<= 2 then
       x_vals[i] := B_list_documented[i] - V_list_documentedB[i]     // (B−V)
    else
       x_vals[i] := V_list_documentedR[i] - R_list_documented[i];     // (V-R)



    case idx of
                0: begin
                     y_vals[i] := B_list[i] - V_listB[i];         // Tbv (b−v)
                     slope:=1/Tbv;   // Tbv = reciprocal of slope of (b-v) plotted versus (B-V)     So inverse slope!!
                     form_transformation1.label1.caption:='1/Slope: '+ FormatFloat('0.000',Tbv);// Tbv = reciprocal of slope of (b-v) plotted versus (B-V)     So inverse slope!!
                     intercept:=Tbv_intercept;
                     sd:=Tbv_sd;
                     x_label:='B-V (documented - documented)';
                     y_label:='b-v (instrumental - instrumental)';
                   end;
                3: begin
                      y_vals[i] := V_listR[i] - R_list[i];     // Tbv (v-r)
                      slope:=1/Tvr;   // Tvr = reciprocal of slope of (v-r) plotted versus (V-R)     So inverse slope!!
                      form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                      intercept:=Tvr_intercept;
                      sd:=Tvr_sd;
                      x_label:='V-R (documented - documented)';
                      y_label:='V-r (documented - instrumental)';

                   end;


                1: begin
                      y_vals[i] := B_list_documented[i] - B_list[i];       // Tb_bv
                      slope:=Tb_bv; // Tbv = slope of (B-b) versus (B-V)
                      form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                      intercept:=Tb_bv_intercept;
                      sd:=Tb_bv_sd;
                      x_label:='B-V (documented - documented)';
                      y_label:='B-b (documented - instrumental)';
                   end;
                4: begin
                      y_vals[i] := V_list_documentedR[i] - V_listR[i];       // Tv_vr
                      slope:=Tv_vr; // Tvr = slope of (R-r) versus (V-R)
                      form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                      intercept:=Tv_vr_intercept;
                      sd:=Tv_vr_sd;
                      x_label:='V-R (documented - documented)';
                      y_label:='V-v (documented - instrumental)';
                   end;


                2: begin
                     y_vals[i] := V_list_documentedB[i] - V_listB[i];       // Tv_bv
                     slope:=Tv_bv; // Tbv = slope of (V-v) versus (B-V)
                     form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                     intercept:=Tv_bv_intercept;
                     sd:=Tv_bv_sd;
                     x_label:='B-V (documented - documented)';
                     y_label:='V-v (documented - instrumental)';
                   end;
                5: begin
                     y_vals[i] := R_list_documented[i] - R_list[i];       // Tr_vr
                     slope:=Tr_vr; // Tvr = slope of (R-r) versus (V-R)
                     form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                     intercept:=Tr_vr_intercept;
                     sd:=Tr_vr_sd;
                     x_label:='V-R (documented - documented)';
                     y_label:='R-r (documented - instrumental)';
                   end;


                end;//case
  end;

  form_transformation1.label2.caption:='intercept: '+ FormatFloat('0.000', intercept);
  form_transformation1.label3.caption:= 'σ: '+ FormatFloat('0.000', sd);


  // Determine min/max for axis scaling
  xmin := x_vals[0]; xmax := x_vals[0];
  ymin := y_vals[0]; ymax := y_vals[0];
  for i := 1 to N - 1 do
  begin
    if x_vals[i] < xmin then xmin := x_vals[i];
    if x_vals[i] > xmax then xmax := x_vals[i];
    if y_vals[i] < ymin then ymin := y_vals[i];
    if y_vals[i] > ymax then ymax := y_vals[i];
  end;

  // Add padding
  xmin := xmin - 0.1; xmax := xmax + 0.1;
  ymin := ymin - transf_filter_sigma * sd; ymax := ymax + transf_filter_sigma * sd;

  // Set up canvas
  with form_transformation1.Image_transformation1 do
  begin
    bmp:=TBitmap.Create;
    bmp.PixelFormat:=pf24bit;
    bmp.SetSize(w,h);
    bmp.Canvas.Brush.Style := bsClear;
    bmp.Canvas.Brush.Color := clMenu;
    bmp.Canvas.Rectangle(-1, -1, w + 1, h + 1); // clear background

    // Axes
    bmp.Canvas.Pen.Color := clGray;
    bmp.Canvas.MoveTo(scale_x_value(xmin), scale_y_value(ymin));
    bmp.Canvas.LineTo(scale_x_value(xmax), scale_y_value(ymin));
    bmp.Canvas.MoveTo(scale_x_value(xmin), scale_y_value(ymin));
    bmp.Canvas.LineTo(scale_x_value(xmin), scale_y_value(ymax));

    // Labels
    bmp.Canvas.Font.Color := clBlue;
    bmp.Canvas.Font.size := 12;
    bmp.Canvas.Brush.Style := bsClear;
    bmp.Canvas.TextOut(w div 2, h - bspace div 2, x_label);
    bmp.Canvas.TextOut(0, 0, y_label);


  // Tick marks X
    nticks := 5;
    tick_step := (xmax - xmin) / nticks;
    for i := 0 to nticks do
    begin
      tick_val := round(10*(xmin + i * tick_step))/10;
      x1 := scale_x_value(tick_val);
      y1 := scale_y_value(ymin);
      bmp.Canvas.MoveTo(x1, y1 - 3);
      bmp.Canvas.LineTo(x1, y1 + 3);
      bmp.Canvas.TextOut(x1 - 10, y1 + 5, FormatFloat('0.00', tick_val));
    end;

    // Tick marks Y
    tick_step := (ymax - ymin) / nticks;
    for i := 0 to nticks do
    begin
      tick_val := round(10*(ymin + i * tick_step))/10;
      x1 := scale_x_value(xmin);
      y1 := scale_y_value(tick_val);
      bmp.Canvas.MoveTo(x1 - 3, y1);
      bmp.Canvas.LineTo(x1 + 3, y1);
      bmp.Canvas.TextOut(x1 - 30, y1 - 5, FormatFloat('0.00', tick_val));
    end;

    // Plot data points
    for i := 0 to N - 1 do
    begin
      x_pixel := scale_x_value(x_vals[i]);
      y_pixel := scale_y_value(y_vals[i]);

      if abs(y_vals[i]- (slope * x_vals[i] + intercept)) > transf_filter_sigma * sd then
      begin //outliers
        bmp.Canvas.Pen.Color := clRed;
        bmp.Canvas.Brush.Color := clRed;

      end
      else
      begin
        bmp.Canvas.Pen.Color := clGreen;
        bmp.Canvas.Brush.Color := clGreen;
      end;

      plot_point(x_pixel, y_pixel);
    end;

    // Plot best-fit line
    bmp.Canvas.Pen.Color := clGreen;
    x1 := scale_x_value(xmin);
    y1 := scale_y_value(slope * xmin + intercept);
    bmp.Canvas.MoveTo(x1, y1);
    x1 := scale_x_value(xmax);
    y1 := scale_y_value(slope * xmax + intercept);
    bmp.Canvas.LineTo(x1, y1);


    // Plot transf_filter_sigma(±1.5) * SD lines
    bmp.Canvas.Pen.Style := psDash;
    bmp.Canvas.Pen.Color := clFuchsia;

    // Upper bound
    x1 := scale_x_value(xmin);
    y1 := scale_y_value(slope * xmin + intercept + transf_filter_sigma * sd);
    bmp.Canvas.MoveTo(x1, y1);
    x1 := scale_x_value(xmax);
    y1 := scale_y_value(slope * xmax + intercept + transf_filter_sigma * sd);
    bmp.Canvas.LineTo(x1, y1);

    // Lower bound
    x1 := scale_x_value(xmin);
    y1 := scale_y_value(slope * xmin + intercept - transf_filter_sigma * sd);
    bmp.Canvas.MoveTo(x1, y1);
    x1 := scale_x_value(xmax);
    y1 := scale_y_value(slope * xmax + intercept - transf_filter_sigma * sd);
    bmp.Canvas.LineTo(x1, y1);

    bmp.Canvas.Pen.Style := psSolid;

    Picture.Bitmap.SetSize(w,h);
    Picture.Bitmap.Canvas.Draw(0,0, bmp);// move bmp to image picture
    bmp.Free;

  end;
end;



procedure compute_transformation_coefficients(
                                standardB, standardV, instrumentalB, instrumentalV : array of double; // real mags
                                len  : integer;
                                out Tbv, Tbv_intercept, Tbv_sd,
                                    Tb_bv, Tb_bv_intercept, Tb_bv_sd,
                                    Tv_bv, Tv_bv_intercept, Tv_bv_sd   : double
                                );
var
  i   : integer;
  xy_bv, xy_vbv, xy_bbv: Tstar_list;
  slope, intercept, sd: double;
begin
  setlength(xy_bv, 2, len);
  setlength(xy_vbv, 2, len);
  setlength(xy_bbv, 2, len);


  for i := 0 to len - 1 do
  begin
    // Color index
    xy_bv[0, i] := standardB[i] - standardV[i];        // B − V
    xy_bv[1, i] := instrumentalB[i] - instrumentalV[i]; // b − v

    xy_vbv[0,i] := standardB[i] - standardV[i];        // B − V
    xy_vbv[1,i] := standardV[i] - instrumentalV[i];    // V − v

    xy_bbv[0,i] := standardB[i] - standardV[i];        // B − V
    xy_bbv[1,i] := standardB[i] - instrumentalB[i];    // B − b
  end;

  transf_filter_sigma:=strtofloat2(form_transformation1.sigma_transformation1.text);

  trendline_without_outliers(xy_bv, len,transf_filter_sigma, slope, intercept, sd);
  Tbv := 1/slope; // Tbv = reciprocal of slope of (b-v) plotted versus (B-V)     So inverse slope!!
  Tbv_intercept := intercept;
  Tbv_sd := sd;

  trendline_without_outliers(xy_vbv, len, transf_filter_sigma,slope, intercept, sd);
  Tv_bv := slope;
  Tv_bv_intercept := intercept;
  Tv_bv_sd := sd;

  trendline_without_outliers(xy_bbv, len,transf_filter_sigma, slope, intercept, sd);
  Tb_bv := slope;
  Tb_bv_intercept := intercept;
  Tb_bv_sd := sd;
end;



procedure transformation;
var
   col,row,Rcount, Vcount, Bcount, Icount,SGcount,SRcount,SIcount,starnr,icon_nr,nr,j,counter    :integer;
   abrv,auid,julian_str : string;
   selected_rows,iconB, iconV,iconR : boolean;
   R,V,B, value            : double;
   V_list, V_list_documented: array of double;

begin
  Form_transformation1.error_label1.caption:='';
  julian_str:='';
  selected_rows:=false;
  nr:=(p_nr-p_nr_norm) div 3;
  if nr<2 then
  begin
    stackmenu1.photometry_button1Click(nil);
    nr:=1+(p_nr-p_nr_norm) div 3;
    if nr<2 then
    begin
      memo2_message('Abort. Not enough magnitude value found in the list. Press first the play button to measure!');
      beep;
      exit;
    end;
  end;

  starnr:=0;
  setlength(B_list,nr);
  setlength(V_list,nr);
  setlength(R_list,nr);

  setlength(B_list_documented,nr);
  setlength(V_list_documented,nr);
  setlength(R_list_documented,nr);
  iconB:=false;
  iconV:=false;
  iconR:=false;

  with stackmenu1.listview7 do
  begin

  for col:=p_nr_norm to p_nr-1 do
    if frac((col-p_nr_norm)/3)=0 then //not snr col
    begin
      abrv:=Columns[col+1].Caption;

      if pos('000-',abrv)>0 then  //check star or iau code
      begin
        auid:=copy(abrv,1,11);
        R:=0;
        V:=0;
        B:=0;
        Rcount:=0;
        Vcount:=0;
        Bcount:=0;

        for row := 0 to items.Count - 1 do //go through rows listview7
        begin

          if Items[row].checked then
          begin
             selected_rows:=true;
             if julian_str='' then
              julian_str:='Julian_Day;'+ Items.item[row].subitems.Strings[p_jd_mid];
             value:=strtofloat2(Items.item[row].subitems.Strings[col]);
             if value<>0 then //measurement found
             try
               icon_nr:=Items.item[row].SubitemImages[P_filter];
               case icon_nr of
                         0,24 : begin R:=R+value; inc(Rcount);iconR:=true; end;  //red or Cousins red
                         1 :    begin V:=V+value; inc(Vcount);iconV:=true; end;  //V or G TG
                         2 :    begin B:=B+value; inc(Bcount);iconB:=true; end;  //B or TB
//                       28:    begin I:=I+value; inc(Icount);end;  //I FILTER
//                       21 :   begin SI:=SI+value; inc(SIcount);end;//SDSS-i
//                       22 :   begin SR:=SR+value; inc(SRcount);end;//SDSS-r
//                       23 :   begin SG:=SG+value; inc(SGcount);end;//SDSS-g
               end;
              except
              end;
          end;
        end;
        if Bcount<>0  then begin B:=B/Bcount; B_list[starnr]:=B;      end else B_list[starnr]:=0;//simple mean
        if Vcount<>0  then begin V:=V/Vcount; V_list[starnr]:=V;      end else V_list[starnr]:=0;//simple mean
        if Rcount<>0  then begin R:=R/Rcount; R_list[starnr]:=R;      end else R_list[starnr]:=0;;//simple mean
//      if Icount<>0  then begin I:=I/Icount; I_list[starnr]:=I;      end else I_list[starnr]:=0;;//simple mean
//      if SGcount<>0 then begin SG:=SG/SGcount; SG_list[starnr]:=SG; end else SG_list[starnr]:=0;;//simple mean
//      if SRcount<>0 then begin SR:=SR/SRcount; SR_list[starnr]:=SR; end else SR_list[starnr]:=0;//simple mean
//      if SIcount<>0 then begin SI:=SI/SIcount; SI_list[starnr]:=SI; end else SI_list[starnr]:=0;//simple mean

        B_list_documented[starnr]:=retrieve_comp_magnitude(2,col, abrv);//  retrieve comp magnitude from the abbrv string or online VSP
        V_list_documented[starnr]:=retrieve_comp_magnitude(1,col, abrv);//  retrieve comp magnitude from the abbrv string or online VSP
        R_list_documented[starnr]:=retrieve_comp_magnitude(0,col, abrv);//  retrieve comp magnitude from the abbrv string or online VSP


        inc(starnr);


      end; // one AUID done
    end;//AUID column found
  end;//with stackmenu

  if selected_rows=false then
  begin
    memo2_message('Abort. No comparison star magnitudes found. Press first the play button and the select rows to process! Select also the correct AAVSO annotation');
    form_transformation1.error_label1.caption:='No comparison star data!';
    beep;
    exit;
  end
  else
  begin
    //B & V
    if ((iconB) and  (iconV)) then
    begin
      counter:=0;
      setlength(V_listB,length(V_list));
      setlength(V_list_documentedB,length(V_list_documented));
      for j:=0 to starnr-1 do //sanitize. Remove stars without measured or documented magnitudes
      begin
        if ((B_list[j]>0) and (V_list[j]>0) and(B_list_documented[j]>0) and (V_list_documented[j]>0)) then  //valid data only
        begin
          B_list[counter]:=B_list[j];
          V_listB[counter]:=V_list[j]; //use V_listB to prevent it is modified and used in VR transformation calculation
          B_list_documented[counter]:=B_list_documented[j];
          V_list_documentedB[counter]:=V_list_documented[j];
          inc(counter);
        end;
      end;
      setlength(B_list,counter);//reduce size
      setlength(V_listB,counter);//reduce size
      setlength(B_list_documented,counter);//reduce size
      setlength(V_list_documentedB,counter);//reduce size

      if counter<2 then
      begin
        beep;
        Form_transformation1.error_label1.caption:='Error, not enough stars!';
        exit;
      end;

      compute_transformation_coefficients(
        B_list_documented, V_list_documentedB, B_list, V_listB,
        counter,
        {out} Tbv, Tbv_intercept, Tbv_sd,
            Tb_bv, Tb_bv_intercept, Tb_bv_sd,
            Tv_bv, Tv_bv_intercept, Tv_bv_sd);

      with Form_transformation1 do
      begin
        Tbv1.enabled:=true;
        Tb_bv1.enabled:=true;
        Tv_bv1.enabled:=true;
      end;
    end
    else
    begin
      Tbv:=1;
      Tb_bv:=0;
      Tv_bv:=0;
      with Form_transformation1 do
      begin
        Tbv1.enabled:=false;
        Tb_bv1.enabled:=false;
        Tv_bv1.enabled:=false;
      end;
    end;



    with Form_transformation1 do
    begin
      tbv1.Text:=floattostrF(tbv,FFfixed,0,3);
      tb_bv1.Text:=floattostrF(tb_bv,FFfixed,0,3);
      tv_bv1.Text:=floattostrF(tv_bv,FFfixed,0,3);
    end;

    //V & R
    if ((iconV) and  (iconR))then
    begin
      setlength(V_listR,length(V_list));
      setlength(V_list_documentedR,length(V_list_documented));
      counter:=0;
      for j:=0 to starnr-1 do //sanitize. Removed stars without measured or documented magnitudes
      begin
        if ((V_list[j]>0) and (R_list[j]>0) and(V_list_documented[j]>0) and (R_list_documented[j]>0)) then  //valid data only
        begin
          V_listR[counter]:=V_list[j];
          R_list[counter]:=R_list[j];
          V_list_documentedR[counter]:=V_list_documented[j];
          R_list_documented[counter]:=R_list_documented[j];
          inc(counter);
        end;
      end;
      setlength(V_listR,counter);
      setlength(R_list,counter);
      setlength(V_list_documentedR,counter);
      setlength(R_list_documented,counter);

      if counter<2 then
      begin
        beep;
        Form_transformation1.error_label1.caption:='Error, not enough stars!';
        exit;
      end;

      compute_transformation_coefficients(
        V_list_documentedR, R_list_documented, V_listR, R_list,
        counter,
        {out} Tvr, Tvr_intercept, Tvr_sd,
            Tv_vr, Tv_vr_intercept, Tv_vr_sd,
            Tr_vr, Tr_vr_intercept, Tr_vr_sd);

      with Form_transformation1 do
      begin
        Tvr1.enabled:=true;
        Tv_vr1.enabled:=true;
        Tr_vr1.enabled:=true;
      end;

    end
    else
    begin
      Tvr:=1;
      Tv_vr:=0;
      Tr_vr:=0;
      with Form_transformation1 do
      begin
        Tvr1.enabled:=false;
        Tv_vr1.enabled:=false;
        Tr_vr1.enabled:=false;
      end;
    end;

    with Form_transformation1 do
    begin
      tvr1.Text:=floattostrF(tvr,FFfixed,0,3);
      tv_vr1.Text:=floattostrF(tv_vr,FFfixed,0,3);
      tr_vr1.Text:=floattostrF(tr_vr,FFfixed,0,3);
    end;

    memo2_message('Transformation ready');

    Form_transformation1.FormResize(nil); //plot  graph
  end;
end;


procedure TForm_transformation1.FormShow(Sender: TObject);
begin
  sigma_transformation1.text:=sigma_transformationSTR;
  Tbv1.text:=TbvSTR;
  Tb_bv1.text:=Tb_bvSTR;
  Tv_bv1.text:=Tv_bvSTR;
  Tvr1.text:=TvrSTR;
  Tv_vr1.text:=Tv_vrSTR;
  Tr_vr1.text:=Tr_vrSTR;
end;

procedure TForm_transformation1.sigma_transformation1EditingDone(Sender: TObject );
begin
  plot_transformation_graph;
end;

procedure TForm_transformation1.Tbv1Click(Sender: TObject);
begin
  idx:=0;
  plot_transformation_graph;
end;


procedure TForm_transformation1.Tb_bv1Click(Sender: TObject);
begin
  idx:=1;
  plot_transformation_graph;
end;

procedure TForm_transformation1.Tr_vr1Click(Sender: TObject);
begin
  idx:=5;
  plot_transformation_graph;
end;

procedure TForm_transformation1.Tvr1Click(Sender: TObject);
begin
  idx:=3;
  plot_transformation_graph;
end;

procedure TForm_transformation1.Tv_bv1Click(Sender: TObject);
begin
  idx:=2;
  plot_transformation_graph;
end;

procedure TForm_transformation1.Tv_vr1Click(Sender: TObject);
begin
  idx:=4;
  plot_transformation_graph;
end;

procedure TForm_transformation1.FormResize(Sender: TObject);
begin
  plot_transformation_graph;
end;

procedure TForm_transformation1.Button1Click(Sender: TObject);
begin
//  if ((pos('std', stackmenu1.annotate_mode1.text)<> 0) or
//               (IDYES= Application.MessageBox('Warning. AAVSO annotation is not set at "std field". If no AAVSO comparison star are available then this routine will not work.'+#10+#10+'This routine will work with any comparison stars so you could continue.'+#10+#10+'Continue?', 'Find tranformation coeficients', MB_ICONQUESTION + MB_YESNO))) then
  transformation;
end;

procedure TForm_transformation1.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  sigma_transformationSTR:=sigma_transformation1.text;
  TbvSTR:=Tbv1.text;
  Tb_bvSTR:=Tb_bv1.text;
  Tv_bvSTR:=Tv_bv1.text;
  TvrSTR:=Tvr1.text;
  Tv_vrSTR:=Tv_vr1.text;
  Tr_vrSTR:=Tr_vr1.text;
end;

end.

