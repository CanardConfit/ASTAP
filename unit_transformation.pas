unit unit_transformation;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,math;

type

  { TForm_transformation1 }

  TForm_transformation1 = class(TForm)
    Button1: TButton;
    cancel1: TButton;
    GroupBox1: TGroupBox;
    RadioButtonTbv1: TRadioButton;
    RadioButtonTb_bv1: TRadioButton;
    RadioButtonTr_vr1: TRadioButton;
    RadioButtonTi_ri1: TRadioButton;
    RadioButtonTvr1: TRadioButton;
    RadioButtonTri1: TRadioButton;
    RadioButtonTv_bv1: TRadioButton;
    RadioButtonTv_vr1: TRadioButton;
    RadioButtonTr_ri1: TRadioButton;
    sloan_checkBox1: TCheckBox;
    checkBox_auid1: TCheckBox;
    error_label2: TLabel;
    error_label3: TLabel;
    Label4: TLabel;
    save1: TButton;
    error_label1: TLabel;
    Label5: TLabel;
    sigma_transformation1: TComboBox;
    transformation_snr1: TComboBox;
    Image_transformation1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;

    procedure Button1Click(Sender: TObject);
    procedure checkBox_auid1Change(Sender: TObject);
    procedure RadioButtonTbv1Click(Sender: TObject);
    procedure save1Click(Sender: TObject);
    procedure cancel1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sigma_transformation1EditingDone(Sender: TObject);
    procedure sloan_checkBox1Change(Sender: TObject);
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
  transformation_snrSTR,
  TbvSTR,
  Tb_bvSTR,
  Tv_bvSTR,
  TvrSTR,
  Tv_vrSTR,
  Tr_vrSTR,

  TgrSTR, //sloan
  Tg_grSTR,//sloan
  Tr_grSTR,//sloan
  TriSTR, //sloan
  Tr_riSTR,//sloan
  Ti_riSTR//sloan
  : string;

  sloan : boolean=false;


implementation

uses astap_main,unit_stack, unit_contour, unit_aavso;

{$R *.lfm}

{ TForm_transformation1 }

var
  B_listBV,
  V_listBV,
  V_listVR,
  R_listVR,
  R_listRI,
  I_listRI,
  B_list_documentedBV,
  V_list_documentedBV,
  V_list_documentedVR,
  R_list_documentedVR,
  R_list_documentedRI,
  I_list_documentedRI   : array of double;
  Tbv, Tbv_intercept, Tbv_sd, Tv_bv, Tv_bv_intercept, Tv_bv_sd, Tb_bv, Tb_bv_intercept, Tb_bv_sd,
  Tvr, Tvr_intercept, Tvr_sd, Tr_vr, Tr_vr_intercept, Tr_vr_sd, Tv_vr, Tv_vr_intercept, Tv_vr_sd,
  Tri, Tri_intercept, Tri_sd, Ti_ri, Ti_ri_intercept, Ti_ri_sd, Tr_ri, Tr_ri_intercept, Tr_ri_sd   : double;
  abbreviation,abbreviationB,abbreviationR,abbreviationI : array of string;
  Tbv_labelstr,
  Tb_bv_labelstr,
  Tv_bv_labelstr,
  Tvr_labelstr,
  Tv_vr_labelstr,
  Tr_vr_labelstr,
  Tri_labelstr,
  Tr_ri_labelstr,
  Ti_ri_labelstr,




  Tbv_tempSTR,
  Tb_bv_tempSTR,
  Tv_bv_tempSTR,
  Tvr_tempSTR,
  Tv_vr_tempSTR,
  Tr_vr_tempSTR,
  Tri_tempSTR,
  Tr_ri_tempSTR,
  Ti_ri_tempSTR : string;




var
  idx : integer; //which graph is shown

  B_str:string='B';
  V_str:string='V';
  R_str:string='R';
  I_str:string='I';

const
  transf_filter_sigma :double=2; //to filter out outliers
  cancel : boolean=true;




procedure plot_transformation_graph;
var
  i,N,w,h: Integer;
  x_vals, y_vals: array of double;
  auid : array of string;
  xmin, xmax, ymin, ymax, tick_step, tick_val,slope, intercept, sd  : double;
  x_pixel, y_pixel,nticks, x1, y1,wtext,bspace  : Integer;
  x_label, y_label: string ;
  bmp: TBitmap;
  show_auid : boolean;
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
  if ((B_listBV=nil) and (V_listVR=nil) and (R_listRI=nil)) then
    exit;//no data

  show_auid:=form_transformation1.checkBox_auid1.checked;
  wtext:=mainform1.image1.Canvas.textwidth('12.3456');
  bspace:=3*mainform1.image1.Canvas.textheight('T');{border space graph. Also for 4k with "make everything bigger"}



  if idx<= 2 then
     N := Length(B_list_documentedBV) //B-V
  else
  if idx<= 5 then
     N := Length(V_list_documentedVR)//V-R
  else
     N := Length(R_list_documentedRI);//R-I

  if N=0 then Exit;

  w:=max(form_transformation1.Image_transformation1.width,n);{make graph large enough for all points}
  h:=max(form_transformation1.Image_transformation1.height,N);


  SetLength(x_vals, N);
  SetLength(y_vals, N);
  SetLength(auid, N);

  // Choose which transform we're plotting by setting y = b−v or V−v or B−b
  for i := 0 to N - 1 do
  begin
    if idx<= 2 then
    begin
       x_vals[i] := B_list_documentedBV[i] - V_list_documentedBV[i];     // (B−V)
       auid[i]:=abbreviationB[i];
    end
    else
    if idx<= 5 then
    begin
       x_vals[i] := V_list_documentedVR[i] - R_list_documentedVR[i];     // (V-R)
       auid[i]:=abbreviationR[i];
    end
    else
    begin
       x_vals[i] := R_list_documentedRI[i] - I_list_documentedRI[i];     // (R-I)
       auid[i]:=abbreviationR[i];
    end;



    case idx of
                0: begin
                     y_vals[i] := B_listBV[i] - V_listBV[i];         // Tbv (b−v)
                     slope:=1/Tbv;   // Tbv = reciprocal of slope of (b-v) plotted versus (B-V)     So inverse slope!!
                     form_transformation1.label1.caption:='1/Slope: '+ FormatFloat('0.000',Tbv);// Tbv = reciprocal of slope of (b-v) plotted versus (B-V)     So inverse slope!!
                     intercept:=Tbv_intercept;
                     sd:=Tbv_sd;
                     x_label:=B_str+'-'+V_str+' (documented - documented)';
                     y_label:=lowercase(b_str)+'-'+lowercase(v_str)+' (instrumental - instrumental)';
                   end;
                3: begin
                      y_vals[i] := V_listVR[i] - R_listVR[i];     // Tvr (v-r)
                      slope:=1/Tvr;   // Tvr = reciprocal of slope of (v-r) plotted versus (V-R)     So inverse slope!!
                      form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                      intercept:=Tvr_intercept;
                      sd:=Tvr_sd;
                      x_label:=V_str+'-'+R_str+' (documented - documented)';
                      y_label:=V_str+'-'+lowercase(R_str)+' (documented - instrumental)';
                   end;
                6: begin
                      y_vals[i] := R_listRI[i] - I_listRI[i];     // Tvr (v-r)
                      slope:=1/Tri;   // Tri = reciprocal of slope of (r-i) plotted versus (R-I)     So inverse slope!!
                      form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                      intercept:=Tri_intercept;
                      sd:=Tri_sd;
                      x_label:=R_str+'-'+I_str+' (documented - documented)';
                      y_label:=R_str+'-'+lowercase(I_str)+' (documented - instrumental)';
                   end;



                1: begin
                      y_vals[i] := B_list_documentedBV[i] - B_listBV[i];       // Tb_bv
                      slope:=Tb_bv; // Tbv = slope of (B-b) versus (B-V)
                      form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                      intercept:=Tb_bv_intercept;
                      sd:=Tb_bv_sd;
                      x_label:=B_str+'-'+V_str+' (documented - documented)';
                      y_label:=B_str+'-'+lowercase(B_str)+' (documented - instrumental)';
                   end;
                4: begin
                      y_vals[i] := V_list_documentedVR[i] - V_listVR[i];       // Tv_vr
                      slope:=Tv_vr; // Tvr = slope of (R-r) versus (V-R)
                      form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                      intercept:=Tv_vr_intercept;
                      sd:=Tv_vr_sd;
                      x_label:=V_str+'-'+R_str+' (documented - documented)';
                      y_label:=V_str+'-'+lowercase(V_str)+' (documented - instrumental)';
                   end;
                7: begin
                      y_vals[i] := R_list_documentedRI[i] - R_listRI[i];       // Tr_ri
                      slope:=Tr_ri; // Tri = slope of (I-i) versus (R-I)
                      form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                      intercept:=Tr_ri_intercept;
                      sd:=Tr_ri_sd;
                      x_label:=R_str+'-'+I_str+' (documented - documented)';
                      y_label:=R_str+'-'+lowercase(R_str)+' (documented - instrumental)';
                   end;



                2: begin
                     y_vals[i] := V_list_documentedBV[i] - V_listBV[i];       // Tv_bv
                     slope:=Tv_bv; // Tbv = slope of (V-v) versus (B-V)
                     form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                     intercept:=Tv_bv_intercept;
                     sd:=Tv_bv_sd;
                     x_label:=B_str+'-'+V_str+' (documented - documented)';
                     y_label:=V_str+'-'+lowercase(V_str)+' (documented - instrumental)';
                   end;
                5: begin
                     y_vals[i] := R_list_documentedVR[i] - R_listVR[i];       // Tr_vr
                     slope:=Tr_vr; // Tvr = slope of (R-r) versus (V-R)
                     form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                     intercept:=Tr_vr_intercept;
                     sd:=Tr_vr_sd;
                     x_label:=V_str+'-'+(R_str)+' (documented - documented)';
                     y_label:=R_str+'-'+lowercase(R_str)+' (documented - instrumental)';
                   end;
                8: begin
                     y_vals[i] := I_list_documentedRI[i] - I_listRI[i];       // Ti_ri
                     slope:=Ti_ri; // Tri = slope of (I-i) versus (R-I)
                     form_transformation1.label1.caption:='Slope: '+ FormatFloat('0.000', slope);
                     intercept:=Ti_ri_intercept;
                     sd:=Ti_ri_sd;
                     x_label:=R_str+'-'+(I_str)+' (documented - documented)';
                     y_label:=I_str+'-'+lowercase(I_str)+' (documented - instrumental)';
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
      if show_auid then
      begin
        bmp.Canvas.Brush.style := bsclear;
        bmp.Canvas.TextOut(x_pixel,y_pixel,auid[i]);//labels
      end;
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
  success : boolean;
  mess : string;
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

  mess:='';
  success:=trendline_without_outliers(xy_bv, len,transf_filter_sigma, slope, intercept, sd);
  Tbv := 1/slope; // Tbv = reciprocal of slope of (b-v) plotted versus (B-V)     So inverse slope!!
  Tbv_intercept := intercept;
  Tbv_sd := sd;
  if success=false then mess:='σ setting too low for Tbv or Tvr and ignored.';

  success:=trendline_without_outliers(xy_vbv, len, transf_filter_sigma,slope, intercept, sd);
  Tv_bv := slope;
  Tv_bv_intercept := intercept;
  Tv_bv_sd := sd;
  if success=false then mess:=mess+#10+'σ setting too low for Tv_bv or Tr_vr and ignored.';

  success:=trendline_without_outliers(xy_bbv, len,transf_filter_sigma, slope, intercept, sd);
  Tb_bv := slope;
  Tb_bv_intercept := intercept;
  Tb_bv_sd := sd;
  if success=false then mess:=mess+#10+'σ setting too low for Tb_bv or Tv_vr and ignored.';

  Form_transformation1.error_label2.caption:=mess;//display any error message
end;

procedure update_from_database;
begin
  if sloan=false then
  begin
    Tbv_tempSTR:=TbvSTR;
    Tb_bv_tempSTR:=Tb_bvSTR;
    Tv_bv_tempSTR:=Tv_bvSTR;
    Tvr_tempSTR:=TvrSTR;
    Tv_vr_tempSTR:=Tv_vrSTR;
    Tr_vr_tempSTR:=Tr_vrSTR;
  end
  else
  begin
    Tbv_tempSTR:=TgrSTR;
    Tb_bv_tempSTR:=Tg_grSTR;
    Tv_bv_tempSTR:=Tr_grSTR;
    Tvr_tempSTR:=TriSTR;
    Tv_vr_tempSTR:=Tr_riSTR;
    Tr_vr_tempSTR:=Ti_riSTR;
  end;

end;

procedure update_radiobuttons;
begin
  with Form_transformation1 do
  begin
    RadioButtontbv1.caption:=Tbv_labelstr+Tbv_tempSTR;
    RadioButtontb_bv1.caption:=Tb_bv_labelstr+Tb_bv_tempSTR;
    RadioButtontv_bv1.caption:=Tv_bv_labelstr+Tv_bv_tempSTR;
    RadioButtontvr1.caption:=Tvr_labelstr+Tvr_tempSTR;
    RadioButtontv_vr1.caption:=Tv_vr_labelstr+Tv_vr_tempSTR;
    RadioButtontr_vr1.caption:=Tr_vr_labelstr+Tr_vr_tempSTR;
    RadioButtontri1.caption:=Tri_labelstr+Tri_tempSTR;
    RadioButtontr_ri1.caption:=Tr_ri_labelstr+Tr_ri_tempSTR;
    RadioButtonti_ri1.caption:=Ti_ri_labelstr+Ti_ri_tempSTR;
  end;
end;

procedure transformation(const ic_B,ic_V,ic_R,ic_R2, ic_I : integer);
var
   col,row,
   Rcount, Vcount, Bcount, Icount,
   starnr,icon_nr,nr,j,counter,selected_rows    :integer;
   abrv,auid,julian_str,mess : string;
   iconB, iconV,iconR,iconI,
   vr_success,bv_success,ri_success  : boolean;
   R,V,B,I,
   value,snr,snrmin            : double;
   B_list,V_list, R_list, I_list,
   B_list_documented,
   V_list_documented,
   R_list_documented,
   I_list_documented: array of double;

begin
  form_transformation1.error_label1.caption:='';
  form_transformation1.error_label3.caption:='';
  julian_str:='';
  selected_rows:=0;
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
  setlength(I_list,nr);

  setlength(B_list_documented,nr);
  setlength(V_list_documented,nr);
  setlength(R_list_documented,nr);
  setlength(I_list_documented,nr);

  setlength(abbreviation,nr);
  iconB:=false;
  iconV:=false;
  iconR:=false;
  iconI:=false;

  snrmin:=strtofloat2(form_transformation1.transformation_snr1.text);

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
        I:=0;
        Rcount:=0;
        Vcount:=0;
        Bcount:=0;
        Icount:=0;

        for row := 0 to items.Count - 1 do //go through rows listview7
        begin

          if Items[row].checked then
          begin
             inc(selected_rows);
             if julian_str='' then
              julian_str:='Julian_Day;'+ Items.item[row].subitems.Strings[p_jd_mid];
             value:=strtofloat2(Items.item[row].subitems.Strings[col]);
             snr:=strtofloat2(Items.item[row].subitems.Strings[col+1]);


             if ((snr>=snrmin) and (value<>0)) then //measurement found
             try
               icon_nr:=Items.item[row].SubitemImages[P_filter];
               if ((icon_nr=ic_R) or (icon_nr=ic_R2)) then begin R:=R+value; inc(Rcount);iconR:=true; end  //red or Cousins red
               else
               if icon_nr=ic_V then begin V:=V+value; inc(Vcount);iconV:=true; end  //V or G TG
               else
               if icon_nr=ic_B then begin B:=B+value; inc(Bcount);iconB:=true; end  //B or TB
               else
               if icon_nr=ic_I then begin I:=I+value; inc(Icount);iconI:=true; end;  //I
              except
              end;
          end;
        end;
        if Bcount<>0  then begin B:=B/Bcount; B_list[starnr]:=B;      end else B_list[starnr]:=0;//simple mean of all the B measurements of this star
        if Vcount<>0  then begin V:=V/Vcount; V_list[starnr]:=V;      end else V_list[starnr]:=0;//simple mean
        if Rcount<>0  then begin R:=R/Rcount; R_list[starnr]:=R;      end else R_list[starnr]:=0;;//simple mean
        if Icount<>0  then begin I:=I/Icount; I_list[starnr]:=I;      end else I_list[starnr]:=0;;//simple mean

        B_list_documented[starnr]:=retrieve_documented_magnitude(false,ic_B,col, abrv);//  retrieve comp magnitude from the abbrv string or online VSP
        V_list_documented[starnr]:=retrieve_documented_magnitude(false,ic_V,col, abrv);//  retrieve comp magnitude from the abbrv string or online VSP
        R_list_documented[starnr]:=retrieve_documented_magnitude(false,ic_R,col, abrv);//  retrieve comp magnitude from the abbrv string or online VSP
        I_list_documented[starnr]:=retrieve_documented_magnitude(false,ic_I,col, abrv);//  retrieve comp magnitude from the abbrv string or online VSP
        abbreviation[starnr]:=auid;

        inc(starnr);

      end; // one AUID done
    end;//AUID column found
  end;//with stackmenu

  if selected_rows=0 then
  begin
    memo2_message('Abort. No comparison star magnitudes found. Press first the play button and the select rows to process! Select also the correct AAVSO annotation');
    form_transformation1.error_label1.caption:='No comparison star data!';
    beep;
    exit;
  end
  else
  begin
    mess:='';
    //B & V
    if ((iconB) and  (iconV)) then
    begin
      counter:=0;
      setlength(B_listBV,starnr);
      setlength(V_listBV,starnr);
      setlength(B_list_documentedBV,starnr);
      setlength(V_list_documentedBV,starnr);
      setlength(abbreviationB,starnr);



      for j:=0 to starnr-1 do //sanitize. Remove stars without measured or documented magnitudes
      begin
        if ((B_list[j]>0) and (V_list[j]>0) and(B_list_documented[j]>0) and (V_list_documented[j]>0)) then  //valid data only
        begin
          B_listBV[counter]:=B_list[j];
          V_listBV[counter]:=V_list[j]; //use V_listB to prevent it is modified and used in VR transformation calculation
          B_list_documentedBV[counter]:=B_list_documented[j];
          V_list_documentedBV[counter]:=V_list_documented[j];
          abbreviationB[counter]:= abbreviation[j];
          inc(counter);
        end;
      end;
      setlength(B_listBV,counter);//reduce size
      setlength(V_listBV,counter);//reduce size
      setlength(B_list_documentedBV,counter);//reduce size
      setlength(V_list_documentedBV,counter);//reduce size
      setlength(abbreviationB,counter);//reduce size

      if counter<3 then
      begin
        beep;
        mess:=mess+'Abort, not enough B and V stars found!';
        bv_success:=false;
      end
      else
      begin
        compute_transformation_coefficients(
          B_list_documentedBV, V_list_documentedBV, B_listBV, V_listBV,
          counter,
          {out} Tbv, Tbv_intercept, Tbv_sd,
              Tb_bv, Tb_bv_intercept, Tb_bv_sd,
              Tv_bv, Tv_bv_intercept, Tv_bv_sd);
        bv_success:=true;
      end;
    end
    else
       bv_success:=false;

    if bv_success=false then
    begin
      Tbv:=1;
      Tb_bv:=0;
      Tv_bv:=0;
   end;

   with Form_transformation1 do
   begin
     RadioButtonTbv1.enabled:=bv_success;
     RadioButtonTb_bv1.enabled:=bv_success;
     RadioButtonTv_bv1.enabled:=bv_success;

     Tbv_tempSTR:=floattostrF(tbv,FFfixed,0,3);
     Tb_bv_tempSTR:=floattostrF(tb_bv,FFfixed,0,3);
     Tv_bv_tempSTR:=floattostrF(tv_bv,FFfixed,0,3);
   end;


    //V & R
    form_transformation1.error_label2.caption:='';

    if ((iconV) and  (iconR))then
    begin
      setlength(V_listVR,starnr);
      setlength(V_list_documentedVR,starnr);
      setlength(R_listVR,starnr);
      setlength(R_list_documentedVR,starnr);
      setlength(abbreviationR,starnr);
      counter:=0;
      for j:=0 to starnr-1 do //sanitize. Removed stars without measured or documented magnitudes
      begin
        if ((V_list[j]>0) and (R_list[j]>0) and(V_list_documented[j]>0) and (R_list_documented[j]>0)) then  //valid data only
        begin
          V_listVR[counter]:=V_list[j];
          R_listVR[counter]:=R_list[j];
          V_list_documentedVR[counter]:=V_list_documented[j];
          R_list_documentedVR[counter]:=R_list_documented[j];
          abbreviationR[counter]:= abbreviation[j];
          inc(counter);
        end;
      end;
      setlength(V_listVR,counter);
      setlength(R_listVR,counter);
      setlength(V_list_documentedVR,counter);
      setlength(R_list_documentedVR,counter);
      setlength(abbreviationR,counter);

      if counter<3 then
      begin
        beep;
        mess:=mess+'Abort, not enough V and R stars found!';

        vr_success:=false;
      end
      else
      begin
        compute_transformation_coefficients(
          V_list_documentedVR, R_list_documentedVR, V_listVR, R_listVR,
          counter,
          {out} Tvr, Tvr_intercept, Tvr_sd,
              Tv_vr, Tv_vr_intercept, Tv_vr_sd,
              Tr_vr, Tr_vr_intercept, Tr_vr_sd);
        vr_success:=true;
      end;
    end
    else
      vr_success:=false;

    if vr_success=false then
    begin
      Tvr:=1;
      Tv_vr:=0;
      Tr_vr:=0;
    end;

    with Form_transformation1 do
    begin
      RadioButtonTvr1.enabled:=vr_success;
      RadioButtonTv_vr1.enabled:=vr_success;
      RadioButtonTr_vr1.enabled:=vr_success;

      Tvr_tempSTR:=floattostrF(tvr,FFfixed,0,3);
      Tv_vr_tempSTR:=floattostrF(tv_vr,FFfixed,0,3);
      Tr_vr_tempSTR:=floattostrF(tr_vr,FFfixed,0,3);
    end;


    //R & I
    form_transformation1.error_label2.caption:='';

    if ((iconR) and  (iconI))then
    begin
      setlength(R_listRI,starnr);
      setlength(R_list_documentedRI,starnr);
      setlength(I_listRI,starnr);
      setlength(I_list_documentedRI,starnr);
      setlength(abbreviationI,starnr);
      counter:=0;
      for j:=0 to starnr-1 do //sanitize. Removed stars without measured or documented magnitudes
      begin
        if ((R_list[j]>0) and (I_list[j]>0) and(R_list_documented[j]>0) and (I_list_documented[j]>0)) then  //valid data only
        begin
          R_listRI[counter]:=R_list[j];
          I_listRI[counter]:=I_list[j];
          R_list_documentedRI[counter]:=R_list_documented[j];
          I_list_documentedRI[counter]:=I_list_documented[j];
          abbreviationI[counter]:= abbreviation[j];
          inc(counter);
        end;
      end;
      setlength(R_listRI,counter);
      setlength(I_listRI,counter);
      setlength(R_list_documentedRI,counter);
      setlength(I_list_documentedRI,counter);
      setlength(abbreviationI,counter);

      if counter<3 then
      begin
        beep;
        mess:=mess+'Abort, not enough R and I stars found!';

        ri_success:=false;
      end
      else
      begin
        compute_transformation_coefficients(
          R_list_documentedRI, I_list_documentedRI, R_listRI, I_listRI,
          counter,
          {out} Tri, Tri_intercept, Tri_sd,
              Tr_ri, Tr_ri_intercept, Tr_ri_sd,
              Ti_ri, Ti_ri_intercept, Ti_ri_sd);
        ri_success:=true;
      end;
    end
    else
      ri_success:=false;

    if ri_success=false then
    begin
      Tri:=1;
      Tr_ri:=0;
      Ti_ri:=0;
    end;

    with Form_transformation1 do
    begin
      RadioButtonTri1.enabled:=ri_success;
      RadioButtonTr_ri1.enabled:=ri_success;
      RadioButtonTi_ri1.enabled:=ri_success;

      Tri_tempSTR:=floattostrF(tri,FFfixed,0,3);
      Tr_ri_tempSTR:=floattostrF(tr_ri,FFfixed,0,3);
      Ti_ri_tempSTR:=floattostrF(ti_ri,FFfixed,0,3);
    end;





    if ((bv_success=false) and (vr_success=false) and (ri_success=false)) then
    begin
      if iconB=false then mess:=mess+' '+B_str+' not found.';
      if iconV=false then mess:=mess+' '+V_str+' not found.';
      if iconR=false then mess:=mess+' '+R_str+' not found.';
      if iconI=false then mess:=mess+' '+I_str+' not found.';
      mess:=mess+' Check in file headers the value of keyword FILTER. Valid values B, TB, V, G, TG, R, TR, I , SG, SR, SI'+#13+#10+'Correct header values with with popup menu if required.';
      form_transformation1.error_label1.caption:=mess;
      memo2_message('Transformation failure. '+mess);
    end;

    if bv_success then
      idx:=0 //show bv graph
    else
    if vr_success then
      idx:=3 //show bv graph
    else
      idx:=6;//show vr graph if available

    if ((bv_success) or (vr_success) or (ri_success)) then
    begin
      form_transformation1.error_label1.caption:='';
      memo2_message('Transformation ready');
      plot_transformation_graph;
    end;
  end;

  update_radiobuttons;
end;


procedure TForm_transformation1.FormShow(Sender: TObject);
begin
  sigma_transformation1.text:=sigma_transformationSTR;
  transformation_snr1.text:=transformation_snrSTR;

  sloan_checkBox1.checked:=sloan;

  if pos('Local',stackmenu1.annotate_mode1.text)<>0 then //not online
    memo2_message('Warning, not many Sloan magnitudes in online VSP !');

//  update_from_database;//prevent override by wrong factors
  sloan_checkBox1Change(nil);//update radiobutton labels
//  update_radiobuttons;

  cancel:=true;
end;

procedure TForm_transformation1.sigma_transformation1EditingDone(Sender: TObject );
begin
  plot_transformation_graph;
end;

procedure TForm_transformation1.sloan_checkBox1Change(Sender: TObject);
begin

   V_listBV:=nil;//nil existing data to avoid confusion
   V_listVR:=nil;
   R_listVR:=nil;
   R_listRI:=nil;

  if sloan_checkBox1.checked=false then
  begin
    Tbv_labelstr:='Tbv=';
    Tb_bv_labelstr:='Tb_bv=';
    Tv_bv_labelstr:='Tv_bv=';
    Tvr_labelstr:='Tvr=';
    Tv_vr_labelstr:='Tv_vr=';
    Tr_vr_labelstr:='Tr_vr=';
    Tri_labelstr:='Tri=';
    Tr_ri_labelstr:='Tr_ri=';
    Ti_ri_labelstr:='Ti_ri=';


    B_str:='B';
    V_str:='V';
    R_str:='R';
    I_str:='I';
    sloan:=false;//here so it wil work directly in unit_aavso
  end
  else
  begin
    Tbv_labelstr:='Tgr=';
    Tb_bv_labelstr:='Tg_gr=';
    Tv_bv_labelstr:='Tr_gr=';
    Tvr_labelstr:='Tri=';
    Tv_vr_labelstr:='Tr_ri=';
    Tr_vr_labelstr:='Ti_ri=';
    Tri_labelstr:='';
    Tr_ri_labelstr:='';
    Ti_ri_labelstr:='';



    B_str:='SG';
    V_str:='SR';
    R_str:='SI';
    I_str:='';
    sloan:=true;
  end;

  update_from_database;//prevent override by wrong factors
  update_radiobuttons;

end;


procedure TForm_transformation1.Tbv1Click(Sender: TObject);
begin
  idx:=0;
  RadioButtonTbv1.checked:=true;
 // plot_transformation_graph;
end;


procedure TForm_transformation1.Tb_bv1Click(Sender: TObject);
begin
  idx:=1;
  RadioButtonTb_bv1.checked:=true;
 // plot_transformation_graph;
end;


procedure TForm_transformation1.Tv_bv1Click(Sender: TObject);
begin
  idx:=2;
  RadioButtonTv_bv1.checked:=true;
 // plot_transformation_graph;
end;


procedure TForm_transformation1.Tvr1Click(Sender: TObject);
begin
  idx:=3;
  RadioButtonTvr1.checked:=true;
 // plot_transformation_graph;
end;


procedure TForm_transformation1.Tv_vr1Click(Sender: TObject);
begin
  idx:=4;
  RadioButtonTv_vr1.checked:=true;
 // plot_transformation_graph;
end;


procedure TForm_transformation1.Tr_vr1Click(Sender: TObject);
begin
  idx:=5;
  RadioButtonTr_vr1.checked:=true;
 // plot_transformation_graph;
end;


procedure TForm_transformation1.FormResize(Sender: TObject);
begin
  plot_transformation_graph;
end;


procedure TForm_transformation1.Button1Click(Sender: TObject);
const
  idyes=6;
  MB_ICONQUESTION=32;
  MB_YESNO=4;

begin
  RadioButtonTbv1.checked:=true;//start with this default

  if ((pos('std', stackmenu1.annotate_mode1.text)<> 0) or (pos('Local', stackmenu1.annotate_mode1.text)<> 0) or
          (IDYES= Application.MessageBox('Warning. AAVSO annotation is not set at "std field". If no AAVSO comparison stars are available then this routine will not work.'+#10+#10+'This routine will work with any comparison stars so you could continue.'+#10+#10+'Continue?', 'Find tranformation coeficients', MB_ICONQUESTION + MB_YESNO))) then

  if sloan=false then
  begin
    transformation(2,1,0,24,28);  //B, V, R, Rc, ic
  end
  else
  begin
    if stackmenu1.annotate_mode1.itemindex>4 then
       memo2_message('Warning, online not many Sloan magnitudes available online.');
    transformation(23 {SG},22 {SR},21 {SI},21 {SI},99);//Sloan
  end;


end;

procedure TForm_transformation1.checkBox_auid1Change(Sender: TObject);
begin
  plot_transformation_graph;
end;


procedure TForm_transformation1.RadioButtonTbv1Click(Sender: TObject);
begin
  if RadioButtonTbv1.checked then idx:=0
  else
  if RadioButtonTb_bv1.checked then idx:=1
  else
  if RadioButtonTv_bv1.checked then idx:=2
  else
  if RadioButtonTvr1.checked then idx:=3
  else
  if RadioButtonTv_vr1.checked then idx:=4
  else
  if RadioButtonTr_vr1.checked then idx:=5
  else
  if RadioButtonTri1.checked then idx:=6
  else
  if RadioButtonTr_ri1.checked then idx:=7
  else
  if RadioButtonTi_ri1.checked then idx:=8;

  plot_transformation_graph;
end;


procedure TForm_transformation1.save1Click(Sender: TObject);
begin
  cancel:=false;
  Form_transformation1.close;
end;

procedure TForm_transformation1.cancel1Click(Sender: TObject);
begin
  cancel:=true;
  Form_transformation1.close;
end;

procedure TForm_transformation1.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if cancel then
    exit;
  sigma_transformationSTR:=sigma_transformation1.text;
  transformation_snrSTR:=transformation_snr1.text;

  if sloan_checkBox1.checked=false then
  begin
    TbvSTR:=Tbv_tempSTR;//store at correct string
    Tb_bvSTR:=Tb_bv_tempSTR;
    Tv_bvSTR:=Tv_bv_tempSTR;
    TvrSTR:=Tvr_tempSTR;
    Tv_vrSTR:=Tv_vr_tempSTR;
    Tr_vrSTR:=Tr_vr_tempSTR;
    sloan:=false;
  end
  else
  begin
    TgrSTR:=Tbv_tempSTR; //store at correct string
    Tg_grSTR:=Tb_bv_tempSTR;
    Tr_grSTR:=Tv_bv_tempSTR;
    TriSTR:=Tvr_tempSTR;
    Tr_riSTR:=Tv_vr_tempSTR;
    Ti_riSTR:=Tr_vr_tempSTR;
    sloan:=true;
  end;

  save_settings2;//save coefficients
end;

end.

