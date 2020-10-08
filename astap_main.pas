unit astap_main;
{Copyright (C) 2017, 2020 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

{This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

{Notes on MacOS pkg making:
   1) Modify app in applications via "show contents", add updated files.
   2) Add the app in program packages
   3) Build package. Will produce PKG file cotaining the app.

   Compiler settings for macOS:
   targetOS: Darwin
   CPU family X86_64
   LCL widegetset: cocoa
}
interface
uses
 {$ifdef mswindows}
  Windows,
  Classes, Controls, Dialogs,StdCtrls, ExtCtrls, ComCtrls, Menus,
  windirs,{for directories from windows}
 {$else} {unix}
  LCLType, {for vk_...}
  Unix,  {for console}
  Classes, Controls, Dialogs,StdCtrls, ExtCtrls, ComCtrls, Menus,process,
  BaseUnix, {for fpchmod}
 {$endif}
  LCLIntf,{for selectobject, openURL}
  LCLProc,
  FPImage,
  fpreadTIFF, {all part of fcl-image}
  fpreadPNG,fpreadBMP,fpreadJPEG,
//  fpwritePNM,  {images}
  fpwriteTIFF,fpwritePNG,fpwriteBMP,fpwriteJPEG, fptiffcmn,  {images}
  GraphType, {fastbitmap}
  LCLVersion, SysUtils, Graphics, Forms, strutils, math,
  clipbrd, {for copy to clipboard}
  Buttons, PopupNotifier, simpleipc,
  CustApp, Types ;

type
  { Tmainwindow }
  Tmainwindow = class(TForm)
    add_marker_position1: TMenuItem;
    bin3x3: TMenuItem;
    BitBtn1: TBitBtn;
    ccdinspector1: TMenuItem;
    error_label1: TLabel;
    FontDialog1: TFontDialog;
    Memo1: TMemo;
    Memo3: TMemo;
    menucopy2: TMenuItem;
    Menufind2: TMenuItem;
    menufindnext2: TMenuItem;
    MenuItem1: TMenuItem;
    bin2x2: TMenuItem;
    image_cleanup1: TMenuItem;
    localgaussian1: TMenuItem;
    localcoloursmooth1: TMenuItem;
    autocorrectcolours1: TMenuItem;
    center_lost_windows: TMenuItem;
    deepsky_annotation1: TMenuItem;
    hyperleda_annotation1: TMenuItem;
    ccd_inspector_plot1: TMenuItem;
    MenuItem10: TMenuItem;
    annotate_with_measured_magnitudes1: TMenuItem;
    compress_fpack1: TMenuItem;
    measuretotalmagnitude1: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    loadsettings1: TMenuItem;
    localbackgroundequalise1: TMenuItem;
    menufindnext1: TMenuItem;
    Menufind1: TMenuItem;
    annotate_minor_planets1: TMenuItem;
    batch_annotate1: TMenuItem;
    extract_pixel_11: TMenuItem;
    copy_paste_tool1: TMenuItem;
    MenuItem15: TMenuItem;
    annotations_visible1: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    extract_pixel_22: TMenuItem;
    batch_solve_astrometry_net: TMenuItem;
    copy_to_clipboard1: TMenuItem;
    MenuItem22: TMenuItem;
    batch_rotate_left1: TMenuItem;
    batch_rotate_right1: TMenuItem;
    gradient_removal1: TMenuItem;
    histogram_values_to_clipboard1: TMenuItem;
    local_adjustments1: TMenuItem;
    angular_distance1: TMenuItem;
    j2000_1: TMenuItem;
    galactic1: TMenuItem;
    MenuItem23: TMenuItem;
    selectfont1: TMenuItem;
    popupmenu_frame1: TPopupMenu;
    Stretchdrawmenu1: TMenuItem;
    stretch_draw_fits1: TMenuItem;
    show_statistics1: TMenuItem;
    PopupMenu_histogram1: TPopupMenu;
    remove_atmouse1: TMenuItem;
    remove_longitude_latitude1: TMenuItem;
    menupaste1: TMenuItem;
    PopupMenu_memo2: TPopupMenu;
    select_all1: TMenuItem;
    PageControl1: TPageControl;
    save_to_tiff1: TMenuItem;
    extract_pixel_12: TMenuItem;
    MenuItem7: TMenuItem;
    menupaste: TMenuItem;
    menucopy1: TMenuItem;
    PopupMenu_memo1: TPopupMenu;
    radec_copy1: TMenuItem;
    radec_paste1: TMenuItem;
    radec_search1: TMenuItem;
    PopupMenu_ra_dec1: TPopupMenu;
    save_settings1: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    enterposition2: TMenuItem;
    flipped1: TMenuItem;
    inversimage1: TMenuItem;
    Enter_rectangle_with_label1: TMenuItem;
    MenuItem18: TMenuItem;
    select_all2: TMenuItem;
    set_area1: TMenuItem;
    rotate_arbitrary1: TMenuItem;
    shape_histogram1: TShape;
    shape_paste1: TShape;
    submenurotate1: TMenuItem;
    imageflipv1: TMenuItem;
    imagefliph1: TMenuItem;
    rotateright1: TMenuItem;
    rotateleft1: TMenuItem;
    MenuItem19: TMenuItem;
    shape_marker2: TShape;
    shape_marker3: TShape;
    solvebytwopositions1: TMenuItem;
    enterposition1: TMenuItem;
    save_settings_as1: TMenuItem;
    settings_menu1: TMenuItem;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    variable_star_annotation1: TMenuItem;
    clean_up1: TMenuItem;
    preview_demosaic1: TMenuItem;
    PopupNotifier1: TPopupNotifier;
    remove_colour1: TMenuItem;
    Returntodefaultsettings1: TMenuItem;
    saturation_factor_plot1: TTrackBar;
    savesettings1: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    show_distortion1: TMenuItem;
    remove_markers1: TMenuItem;
    SimpleIPCServer1: TSimpleIPCServer;
    zoomin1: TMenuItem;
    zoomout1: TMenuItem;
    select_directory_thumb1: TMenuItem;
    add_marker1: TMenuItem;
    calibrate_photometry1: TMenuItem;
    MenuItem9: TMenuItem;
    astrometric_solve_image1: TMenuItem;
    remove_left1: TMenuItem;
    remove_right1: TMenuItem;
    remove_above1: TMenuItem;
    remove_below1: TMenuItem;
    MenuItem8: TMenuItem;
    Shape_alignment_marker1: TShape;
    shape_marker1: TShape;
    SpeedButton1: TSpeedButton;
    split_osc1: TMenuItem;
    recent7: TMenuItem;
    recent8: TMenuItem;
    recent3: TMenuItem;
    recent4: TMenuItem;
    recent5: TMenuItem;
    recent6: TMenuItem;
    MenuItem2: TMenuItem;
    helponline1: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    brighten_area1: TMenuItem;
    convert_to_fits1: TMenuItem;
    convertmono1: TMenuItem;
    MenuItem6: TMenuItem;
    recent1: TMenuItem;
    recent2: TMenuItem;
    star_annotation1: TMenuItem;
    Remove_deep_sky_object1: TMenuItem;
    MenuItem4: TMenuItem;
    ra1: TEdit;
    dec1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    MainMenu1: TMainMenu;
    Help: TMenuItem;
    Exit1: TMenuItem;
    About1: TMenuItem;
    File1: TMenuItem;
    OpenDialog1: TOpenDialog;
    N1: TMenuItem;
    N2: TMenuItem;
    ShowFITSheader1: TMenuItem;
    SaveDialog1: TSaveDialog;
    error_get_it: TLabel;
    ra_label: TLabel;
    dec_label: TLabel;
    rotation1: TLabel;
    inversemousewheel1: TCheckBox;
    LoadFITSPNGBMPJPEG1: TMenuItem;
    SaveasJPGPNGBMP1: TMenuItem;
    image_north_arrow1: TImage;
    GroupBox1: TGroupBox;
    save1: TButton;
    solve_button1: TButton;
    AddplatesolvesolutiontoselectedFITSfiles1: TMenuItem;

    tools1: TMenuItem;
    TrayIcon1: TTrayIcon;
    View1: TMenuItem;
    flip_horizontal1: TMenuItem;
    flip_vertical1: TMenuItem;
    N5: TMenuItem;
    SaveFITSwithupdatedheader1: TMenuItem;
    demosaic_bayermatrix1: TMenuItem;
    N6: TMenuItem;
    Undo1: TMenuItem;
    stretch_draw1: TMenuItem;
    data_range_groupBox1: TGroupBox;
    Label12: TLabel;
    minimum1: TScrollBar;
    Label13: TLabel;
    maximum1: TScrollBar;
    min2: TEdit;
    max2: TEdit;
    histogram1: TImage;
    Label5: TLabel;
    range1: TComboBox;
    PopupMenu1: TPopupMenu;
    Copyposition1: TMenuItem;
    Copypositioninhrs1: TMenuItem;
    Copypositioninradians1: TMenuItem;
    writeposition1: TMenuItem;
    N7: TMenuItem;
    Enterlabel1: TMenuItem;
    Saveasfits1: TMenuItem;
    Stackimages1: TMenuItem;
    Export_image1: TMenuItem;
    ImageList1: TImageList;
    N9: TMenuItem;
    CropFITSimage1: TMenuItem;
    stretch1: TComboBox;
    Polynomial1: TComboBox;
    N3: TMenuItem;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Image1: TImage;

    procedure add_marker_position1Click(Sender: TObject);
    procedure annotate_with_measured_magnitudes1Click(Sender: TObject);
    procedure annotations_visible1Click(Sender: TObject);
    procedure autocorrectcolours1Click(Sender: TObject);
    procedure batch_annotate1Click(Sender: TObject);
    procedure batch_solve_astrometry_netClick(Sender: TObject);
    procedure ccd_inspector_plot1Click(Sender: TObject);
    procedure compress_fpack1Click(Sender: TObject);
    procedure copy_to_clipboard1Click(Sender: TObject);
    procedure extract_pixel_11Click(Sender: TObject);
    procedure extract_pixel_12Click(Sender: TObject);
    procedure extract_pixel_22Click(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure histogram_range1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure histogram_values_to_clipboard1Click(Sender: TObject);
    procedure imageflipv1Click(Sender: TObject);
    procedure measuretotalmagnitude1Click(Sender: TObject);
    procedure loadsettings1Click(Sender: TObject);
    procedure localbackgroundequalise1Click(Sender: TObject);
    procedure menucopy1Click(Sender: TObject);
    procedure Menufind1Click(Sender: TObject);
    procedure menufindnext1Click(Sender: TObject);
    procedure copy_paste_tool1Click(Sender: TObject);
    procedure MenuItem21Click(Sender: TObject);
    procedure batch_rotate_left1Click(Sender: TObject);
    procedure angular_distance1Click(Sender: TObject);
    procedure j2000_1Click(Sender: TObject);
    procedure galactic1Click(Sender: TObject);
    procedure range1Change(Sender: TObject);
    procedure remove_atmouse1Click(Sender: TObject);
    procedure gradient_removal1Click(Sender: TObject);
    procedure remove_longitude_latitude1Click(Sender: TObject);
    procedure selectfont1Click(Sender: TObject);
    procedure select_all1Click(Sender: TObject);
    procedure save_to_tiff1Click(Sender: TObject);
    procedure menupasteClick(Sender: TObject);
    procedure annotate_minor_planets1Click(Sender: TObject);
    procedure radec_copy1Click(Sender: TObject);
    procedure radec_paste1Click(Sender: TObject);
    procedure radec_search1Click(Sender: TObject);
    procedure save_settings1Click(Sender: TObject);
    procedure enterposition1Click(Sender: TObject);
    procedure inversimage1Click(Sender: TObject);
    procedure set_area1Click(Sender: TObject);
    procedure rotate_arbitrary1Click(Sender: TObject);
    procedure receivemessage(Sender: TObject); {For single instance, receive paramstr(1) from second instance prior to termination}

    procedure add_marker1Click(Sender: TObject);
    procedure center_lost_windowsClick(Sender: TObject);
    procedure convertmono1Click(Sender: TObject);
    procedure deepsky_annotation1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure helponline1Click(Sender: TObject);
    procedure Image1MouseEnter(Sender: TObject);
    procedure image_cleanup1Click(Sender: TObject);
    procedure deepsky_overlay1Click(Sender: TObject);
    procedure brighten_area1Click(Sender: TObject);
    procedure convert_to_fits1click(Sender: TObject);
    procedure bin2x2Click(Sender: TObject);
    procedure max2EditingDone(Sender: TObject);
    procedure Memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure localgaussian1Click(Sender: TObject);
    procedure localcoloursmooth1Click(Sender: TObject);
    procedure hyperleda_annotation1Click(Sender: TObject);
    procedure ra1DblClick(Sender: TObject);
    procedure clean_up1Click(Sender: TObject);
    procedure remove_colour1Click(Sender: TObject);
    procedure Returntodefaultsettings1Click(Sender: TObject);
    procedure rotateleft1Click(Sender: TObject);
    procedure saturation_factor_plot1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure saturation_factor_plot1MouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure savesettings1Click(Sender: TObject);
    procedure show_distortion1Click(Sender: TObject);
    procedure Polynomial1Change(Sender: TObject);
    procedure remove_markers1Click(Sender: TObject);
    procedure Panel1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Panel1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure show_statistics1Click(Sender: TObject);
    procedure SimpleIPCServer1MessageQueued(Sender: TObject);
    procedure StatusBar1MouseEnter(Sender: TObject);
    procedure stretch_draw_fits1Click(Sender: TObject);
    procedure variable_star_annotation1Click(Sender: TObject);
    procedure zoomin1Click(Sender: TObject);
    procedure zoomout1Click(Sender: TObject);
    procedure astrometric_solve_image1Click(Sender: TObject);
    procedure min2EditingDone(Sender: TObject);
    procedure remove_above1Click(Sender: TObject);
    procedure remove_below1Click(Sender: TObject);
    procedure remove_left1Click(Sender: TObject);
    procedure remove_right1Click(Sender: TObject);
    procedure select_directory_thumb1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure OpenDialog1SelectionChange(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer );
    procedure recent1Click(Sender: TObject);
    procedure Remove_deep_sky_object1Click(Sender: TObject);
    procedure ShowFITSheader1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ra1Change(Sender: TObject);
    procedure dec1Change(Sender: TObject);
    procedure solve_button1Click(Sender: TObject);
    procedure SaveFITSwithupdatedheader1Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure SaveasJPGPNGBMP1Click(Sender: TObject);
    procedure LoadFITSPNGBMPJPEG1Click(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure AddplatesolvesolutiontoselectedFITSfiles1Click(Sender: TObject);
    procedure flip_horizontal1Click(Sender: TObject);
    procedure flip_vertical1Click(Sender: TObject);
    procedure demosaic_bayermatrix1Click(Sender: TObject);
    procedure star_annotation1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure stretch_draw1Click(Sender: TObject);
    procedure Copyposition1Click(Sender: TObject);
    procedure Copypositioninhrs1Click(Sender: TObject);
    procedure Copypositioninradians1Click(Sender: TObject);
    procedure writeposition1Click(Sender: TObject);
    procedure Enterlabel1Click(Sender: TObject);
    procedure Stackimages1Click(Sender: TObject);
    procedure Saveasfits1Click(Sender: TObject);
    procedure Export_image1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CropFITSimage1Click(Sender: TObject);
    procedure maximum1Scroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure stretch1Change(Sender: TObject);
    procedure histogram1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure maximum1Change(Sender: TObject);
    procedure minimum1Change(Sender: TObject);
    procedure CCDinspector1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure DisplayHint(Sender: TObject);

  end;

var
  mainwindow: Tmainwindow;
type
  image_array = array of array of array of Single;
  star_list   = array of array of double;

type
   timgbackup  = record
     crpix1 : double;{could be modified by crop}
     crpix2 : double;
     crval1 : double;
     crval2 : double;
     crota1 : double;{for 90 degrees rotate}
     crota2 : double;
     cdelt1 : double;
     cdelt2 : double;
     cd1_1  : double;
     cd1_2  : double;
     cd2_1  : double;
     cd2_2  : double;
     header : string;
     img    : array of array of array of single;
   end;

var
  img_backup      : array of timgbackup;{dynamic so memory can be freed}

  settingstring :tstrings; {settings for save and loading}

  user_path    : string;{c:\users\name\appdata\local\astap   or ~/home/.config/astap}
  img_loaded,img_temp,img_dark,img_flat,img_bias,img_average,img_variance,img_buffer,img_final : image_array;
  filename2: string;
  nrbits,Xbinning,Ybinning    : integer;
  size_backup,index_backup    : integer;{number of backup images for ctrl-z, numbered 0,1,2,3}
  crota2,crota1                      : double; {image rotation at center in degrees}
  cd1_1,cd1_2,cd2_1,cd2_2 :double;
  ra_radians,dec_radians, pixel_size : double;

var
  a_order: integer;{Simple Imaging Polynomial use by astrometry.net, if 2 then available}
  a_0_2, a_0_3, a_1_1, a_1_2,a_2_0, a_2_1, a_3_0 : double; {SIP, Simple Imaging Polynomial use by astrometry.net, Spitzer}
  b_0_2, b_0_3, b_1_1, b_1_2,b_2_0, b_2_1, b_3_0 : double; {SIP, Simple Imaging Polynomial use by astrometry.net, Spitzer}
  ap_0_1, ap_0_2, ap_0_3, ap_1_0, ap_1_1, ap_1_2, ap_2_0, ap_2_1, ap_3_0 : double;{SIP, Simple Imaging Polynomial use by astrometry.net}
  bp_0_1, bp_0_2, bp_0_3, bp_1_0, bp_1_1, bp_1_2, bp_2_0, bp_2_1, bp_3_0 : double;{SIP, Simple Imaging Polynomial use by astrometry.net}

var
   histogram : array[0..2,0..65535] of integer;{red,green,blue,count}
   his_total_red, his_total_green,his_total_blue,extend : integer; {histogram number of values}
   histo_peak_position : integer;
   his_mean,noise_level : array[0..2] of integer;
   stretch_c : array[0..32768] of single;{stretch curve}
   stretch_on, esc_pressed, fov_specified,unsaved_import : boolean;
   set_temperature : integer;
   star_level  : double;
   object_name, filter_name,calstat,imagetype ,sitelat, sitelong: string;
   exposure,focus_temp,centalt,centaz,cblack,cwhite,gain   :double; {from FITS}
   subsamp, focus_pos  : integer;{not always available. For normal DSS =1}
   date_obs,date_avg,ut,pltlabel,plateid,telescop,instrum,origin:string;

   datamin_org, datamax_org,
   old_crpix1,old_crpix2,old_crota1,old_crota2,old_cdelt1,old_cdelt2,old_cd1_1,old_cd1_2,old_cd2_1,old_cd2_2 : double;{for backup}

   warning_str,{for solver}
   roworder                  :string;
   copy_paste_x,
   copy_paste_y,
   copy_paste_w,
   copy_paste_h : integer;

var
  position_find: Integer; {for fits header memo1 popup menu}
const
  PatternToFind : string=''; {for fits header memo1 popup menu }
  hist_range  {range histogram 255 or 65535 or streched} : integer=255;
  width2  : integer=100;
  height2: integer=100;{do not use reserved word height}
  naxis  : integer=2;{number of dimensions}
  naxis3 : integer=1;{number of colors}
  fits_file: boolean=false;
  image_move_to_center : boolean=false;
  ra0 : double=0;
  dec0: double=0; {plate center values}
  crpix1: double=0;{reference pixel}
  crpix2: double=0;
  cdelt1: double=0;{deg/pixel for x}
  cdelt2: double=0;
  xpixsz: double=0;//Pixel Width in microns (after binning)
  ypixsz: double=0;//Pixel height in microns (after binning)
  focallen: double=0;
  down_x: integer=0;
  down_y: integer=0;
  startX: integer=0; {range 0..}
  startY: integer=0;
  stopX: integer=0; {range 0..}
  stopY: integer=0;
  width_radians : double=(140/60)*pi/180;
  height_radians: double=(100/60)*pi/180;
  mouse_enter : integer=0;{for crop function}
  application_path:string='';{to be set in main}
  database_path:string='';{to be set in main}
  bayerpat: string='';{bayer pattern}
  bayerpattern_final:integer=0;
  xbayroff: double=0;{additional bayer pattern offset to apply}
  Ybayroff: double=0;{additional bayer pattern offset to apply}
  annotated : boolean=false;{any annotation in fits file?}
  copy_paste :boolean=false;

  shape_fitsX: double=0;
  shape_fitsY: double=0;
  shape_marker1_fitsX: double=10;
  shape_marker1_fitsY: double=10;
  shape_marker2_fitsX: double=20;
  shape_marker2_fitsY: double=20;
  shape_marker3_fitsX: double=0;
  shape_marker3_fitsY: double=0;

  commandline_execution : boolean=false;{program executed in command line}
  errorlevel        : integer=0;{report errors when shutdown}

  mouse_positionRADEC1 : string='';{For manual reference solving}
  mouse_positionRADEC2 : string='';{For manual reference solving}
  flipped_img          : string='';
  bayer_pattern : array[0..3] of string=('GRBG',
                                        'BGGR',
                                        'RGGB',
                                        'GBRG');
  annotation_color: tcolor=clyellow;
  annotation_diameter : integer=20;



procedure ang_sep(ra1,dec1,ra2,dec2 : double;var sep: double);
function load_fits(filen:string;light {load as light of dark/flat},load_data :boolean;var img_loaded2: image_array): boolean;{load fits file}
procedure plot_fits(img: timage;center_image,show_header:boolean);
procedure use_histogram(img: image_array; update_hist: boolean);{get histogram}
procedure HFD(img: image_array; x1,y1,rs{box size}: integer; var hfd1,star_fwhm,snr{peak/sigma noise},flux,xc,yc:double);{calculate star HFD and FWHM, SNR, xc and yc are center of gravity. All x,y coordinates in array[0..] positions}
procedure backup_img;
procedure restore_img;
function load_image(re_center, plot:boolean) : boolean; {load fits or PNG, BMP, TIF}

procedure demosaic_bayer(var img: image_array); {convert OSC image to colour}

Function INT_IEEE4_reverse(x: double):longword;{adapt intel floating point to non-intel float}
function save_fits(img: image_array;filen2:ansistring;type1:integer;override1:boolean): boolean;{save to 8, 16 OR -32 BIT fits file}

procedure update_text(inpt,comment1:string);{update or insert text in header}
procedure add_text(inpt,comment1:string);{add text to header memo}
procedure add_long_comment(descrip:string);{add long text to header memo. Split description over several lines if required}
procedure update_generic(message_key,message_value,message_comment:string);{update header using text only}
procedure update_integer(inpt,comment1:string;x:integer);{update or insert variable in header}
procedure add_integer(inpt,comment1:string;x:integer);{add integer variable to header}
procedure update_float(inpt,comment1:string;x:double);{update keyword of fits header in memo}
procedure remove_key(inpt:string; all:boolean);{remove key word in header. If all=true then remove multiple of the same keyword}

function strtofloat2(s:string): double;{works with either dot or komma as decimal seperator}
function TextfileSize(const name: string): LongInt;
function floattostr2(x:double):string;
procedure update_menu(fits :boolean);{update menu if fits file is available in array or working from image1 canvas}
procedure get_hist(colour:integer;img :image_array);{get histogram of img_loaded}
procedure save_settings(lpath:string);
procedure progress_indicator(i:double; info:string);{0 to 100% indication of progress}
{$ifdef mswindows}
procedure ExecuteAndWait(const aCommando: string; show_console:boolean);
{$else} {unix}
procedure execute_unix(const execut:string; param: TStringList; show_output: boolean);{execute linux program and report output}
procedure execute_unix2(s:string);
{$endif}
function mode(img :image_array;colorm,xmin,xmax,ymin,ymax,max1:integer):integer;{find the most common value of a local area and assume this is the best average background value}
function get_negative_noise_level(img :image_array;colorm,xmin,xmax,ymin,ymax: integer;common_level:double): double;{find the negative noise level below most_common_level  of a local area}
function prepare_ra5(rax:double; sep:string):string; {radialen to text  format 24h 00.0}
function prepare_dec5(decx:double;sep:string):string; {radialen to text  format 90d 00 }
function prepare_dec(decx:double; sep:string):string; {radialen to text, format 90d 00 00}
function prepare_ra(rax:double; sep:string):string; {radialen to text, format 24: 00 00.0 }
function inttostr5(x:integer):string;{always 5 digit}
function SMedian(list: array of double): double;{get median of an array of double, taken from CCDciel code}
function floattostrF2(const x:double; width1,decimals1 :word): string;
procedure DeleteFiles(lpath,FileSpec: string);{delete files such  *.wcs}
procedure new_to_old_WCS;{convert new style FITsS to old style}
procedure old_to_new_WCS;{ convert old WCS to new}
procedure show_marker_shape(shape: TShape;shape_type,w,h,minimum:integer; fitsX,fitsY: double);{show manual alignment shape}
procedure create_test_image(type_test : integer);{create an artificial test image}
function check_raw_file_extension(ext: string): boolean;{check if extension is from raw file}
function convert_raw_to_fits(filename7 : string) :boolean;{convert raw file to FITS format}
function unpack_cfitsio(filename3: string): boolean; {convert .fz to .fits using funpack}
function pack_cfitsio(filename3: string): boolean; {convert .fz to .fits using funpack}

function load_TIFFPNGJPEG(filen:string; var img_loaded2: image_array) : boolean;{load 8 or 16 bit TIFF, PNG, JPEG, BMP image}
function extract_exposure_from_filename(filename8: string):integer; {try to extract exposure from filename}
function extract_temperature_from_filename(filename8: string): integer; {try to extract temperature from filename}
function extract_objectname_from_filename(filename8: string): string; {try to extract exposure from filename}

function test_star_spectrum(r,g,b: single) : single;{test star spectrum. Result of zero is perfect star spectrum}
function fnmodulo (x,range: double):double;
procedure measure_magnitudes(var stars :star_list);{find stars and return, x,y, hfd, flux}
function binX2X3_file(binfactor:integer) : boolean; {converts filename2 to binx2,binx3, binx4 version}
procedure ra_text_to_radians(inp :string; var ra : double; var errorRA :boolean); {convert ra in text to double in radians}
procedure dec_text_to_radians(inp :string; var dec : double; var errorDEC :boolean); {convert ra in text to double in radians}
function image_file_name(inp : string): boolean; {readable image name?}
procedure plot_annotations(xoffset,yoffset:integer;fill_combo: boolean); {plot annotations stored in fits header. Offsets are for blink routine}
function convert_load_raw(filename3: string;var img: image_array): boolean; {convert raw to pgm file using LibRaw}

procedure RGB2HSV(r,g,b : single; out h {0..360}, s {0..1}, v {0..1}: single);{RGB to HSVB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
procedure HSV2RGB(h {0..360}, s {0..1}, v {0..1} : single; out r,g,b: single); {HSV to RGB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
function get_demosaic_pattern : integer; {get the required de-bayer range 0..3}
procedure listview_add_xy(fitsX,fitsY: double);{add x,y position to listview}
Function LeadingZero(w : integer) : String;
procedure log_to_file(logf,mess : string);{for testing}
procedure demosaic_advanced(var img : image_array);{demosaic img_loaded}
procedure bin_X2X3X4(binfactor:integer);{bin img_loaded 2x or 3x or 4x}
procedure local_sd(x1,y1, x2,y2{regio of interest},col : integer; img : image_array; var sd,mean :double);{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}


const   bufwide=1024*120;{buffer size in bytes}

  head1: array [0..28] of ansistring=
  (
     {0}('SIMPLE  =                    T / FITS header                                    '),
     {1}('BITPIX  =                    8 / Bits per entry                                 '),
     {2}('NAXIS   =                    2 / Number of dimensions                           '),
     {3}('NAXIS1  =                  100 / length of x axis                               '),
     {4}('NAXIS2  =                  100 / length of y axis                               '),
     {5}('NAXIS3  =                    3 / length of z axis (mostly colors)               '),
     {6}('EQUINOX =               2000.0 / Equinox of coordinates                         '),
     {7}('DATAMIN =                    0 / Minimum data value                             '),
     {8}('DATAMAX =                  255 / Maximum data value                             '),
     {9}('BZERO   =                  0.0 / Scaling applied to data                        '),
    {10}('BSCALE  =                  1.0 / Offset applied to data                         '),
    {11}('CTYPE1  = '+#39+'RA---TAN'+#39+'           / first parameter RA  ,  projection TANgential   '),
    {12}('CTYPE2  = '+#39+'DEC--TAN'+#39+'           / second parameter DEC,  projection TANgential   '),
    {13}('CUNIT1  = '+#39+'deg     '+#39+'           / Unit of coordinates                            '),
    {14}('CRPIX1  =                  0.0 / X of reference pixel                           '),
    {15}('CRPIX2  =                  0.0 / Y of reference pixel                           '),
    {16}('CRVAL1  =                  0.0 / RA of reference pixel (deg)                    '),
    {17}('CRVAL2  =                  0.0 / DEC of reference pixel (deg)                   '),
    {18}('CDELT1  =                  0.0 / X pixel size (deg)                             '),
    {19}('CDELT2  =                  0.0 / Y pixel size (deg)                             '),
    {20}('CROTA1  =                  0.0 / Image twist of X axis        (deg)             '),
    {21}('CROTA2  =                  0.0 / Image twist of Y axis W of N (deg)             '),
    {22}('CD1_1   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
    {23}('CD1_2   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
    {24}('CD2_1   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
    {25}('CD2_2   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
    {26}('PLTSOLVD=                    T / ASTAP from hnsky.org                           '),
    {27}('END                                                                             '),
    {28}('                                                                                ')); {should be empthy !!}

type  byteX3  = array[0..2] of byte;
      byteXX3 = array[0..2] of word;
      byteXXXX3 = array[0..2] of single;

var
  TheFile3  : tfilestream;
  Reader    : TReader;
  fitsbuffer : array[0..bufwide] of byte;{buffer for 8 bit FITS file}
  fitsbuffer2: array[0..round(bufwide/2)] of word absolute fitsbuffer;{buffer for 16 bit FITS file}
  fitsbufferRGB: array[0..trunc(bufwide/3)] of byteX3 absolute fitsbuffer;{buffer for 8 bit RGB FITS file}
  fitsbufferRGB16: array[0..trunc(bufwide/6)] of byteXX3 absolute fitsbuffer;{buffer for 16 bit RGB PPM file}
  fitsbufferRGB32: array[0..trunc(bufwide/12)] of byteXXXX3 absolute fitsbuffer;{buffer for -32 bit PFM file}
  fitsbuffer4: array[0..round(bufwide/4)] of longword absolute fitsbuffer;{buffer for floating bit ( -32) FITS file}
  fitsbuffer8: array[0..trunc(bufwide/8)] of int64 absolute fitsbuffer;{buffer for floating bit ( -64) FITS file}
  fitsbufferSINGLE: array[0..round(bufwide/4)] of single absolute fitsbuffer;{buffer for floating bit ( -32) FITS file}
  fitsbufferDouble: array[0..round(bufwide/8)] of double absolute fitsbuffer;{buffer for floating bit ( -64) FITS file}

implementation

uses unit_dss, unit_stack, unit_tiff,unit_star_align, unit_astrometric_solving, unit_290, unit_annotation, unit_thumbnail, unit_xisf,unit_gaussian_blur,unit_inspector_plot,unit_asteroid,
 unit_astrometry_net, unit_live_stacking, unit_hjd;

{$R astap_cursor.res}   {FOR CURSORS}

{$IFDEF fpc}
  {$R *.lfm}
{$else}  {delphi}
 {$R *.dfm}
{$endif}

var
  recent_files : tstringlist;
  stop_RX, stop_RY, start_RX,start_RY                    :integer; {for rubber rectangle. These values are the same startX,.... except if image is flipped}
  object_xc,object_yc, object_raM,object_decM  : double; {near mouse auto centered object position}

const
  crMyCursor = 5;

  bandpass: double=0;{from fits file}
  equinox:double=0;{from fits file}
  SaveasTIFF1filterindex : integer=1;
  SaveasJPGPNGBMP1filterindex : integer=4;
  LoadFITSPNGBMPJPEG1filterindex: integer=1;
  marker_position : string='';
  mouse_fitsx : double=0;
  mouse_fitsy : double=0;
  coord_frame : integer=0; {J2000=0 or galactic=1}

  {$IFDEF Darwin}
  font_name: string= 'Courier';
  font_size : integer = 9;
  {$else}
  {$IFDEF mswindows}
  font_name: string= 'Monospace';
  font_size : integer= 10;
  {$ELSE}
  font_name: string= 'Courier';
  font_size : integer = 9;
  {$ENDIF}
  {$ENDIF}
  font_charset : integer=0; {Ansi_char}
  font_style :   tFontStyles=[];
  font_color : tcolor= cldefault;


function load_fits(filen:string;light {load as light of dark/flat},load_data: boolean ;var img_loaded2: image_array): boolean;{load fits file}
{if light=true then read also ra0, dec0 ....., else load as dark, flat}
{if load_data then read all else header only}
{if reset_var=true, reset variables to zero}
var
  header    : array[0..2880] of ansichar;
  i,j,k,nr,error3,naxis1, reader_position,n,p,nrchars,dsscol  : integer;
  fract,dummy,scale,exptime,ccd_temperature                   : double;
  col_float,bscale,measured_max  : single;
  s                  : string[3];
  bzero              : integer;{zero shift. For example used in AMT, Tricky do not use int64,  maxim DL writes BZERO value -2147483647 as +2147483648 !! }
  wo                 : word;   {for 16 signed integer}
  sign_int           : smallint absolute wo;{for 16 signed integer}
  aline,number,field : ansistring;
  rgbdummy           : byteX3;

  x_longword  : longword;
  x_single    : single absolute x_longword;{for conversion 32 bit "big-endian" data}
  x_int64     : int64;
  x_double    : double absolute x_int64;{for conversion 64 bit "big-endian" data}

  lw       : int64;
  fl       : double absolute lw;

  tfields{,naxisT}, naxisT1,naxisT2: integer;
  ttype,tform,tunit : array of string;
  tbcol       : array of integer;
  tform_counter: integer;
const
  end_record : boolean=false;

     procedure close_fits_file; inline;
     begin
        Reader.free;
        TheFile3.free;
     end;

     Function validate_double:double;{read floating point or integer values}
     var t :shortstring;
         r,err : integer;
     begin
       t:='';
       r:=I+10;{position 11 equals 10}
       while ((header[r]<>'/') and (r<=I+29) {pos 30}) do {'/' check is strictly not necessary but safer}
       begin  {read 20 characters max, position 11 to 30 in string, position 10 to 29 in pchar}
         if header[r]<>' ' then t:=t+header[r];
         inc(r);
       end;
       val(t,result,err);
     end;

     Function get_string:string;{read string values}
     var  r: integer;
     begin
       result:='';
       r:=I+11;{pos12, single quotes should for fix format should be at position 11 according FITS standard 4.0, chapter 4.2.1.1}
       repeat
         result:=result+header[r];
         inc(r);
       until ((header[r]=#39){last quote} or (r>=I+79));{read string up to position 80 equals 79}
     end;

     Function get_as_string:string;{read float as string values. Universal e.g. for latitude and longitude which could be either string or float}
     var  r: integer;
     begin
       result:='';
       r:=I+11;{pos12, single quotes should for fix format should be at position 11 according FITS standard 4.0, chapter 4.2.1.1}
       repeat
         result:=result+header[r];
         inc(r);
       until ((header[r]=#39){last quote} or (r>=I+30));{read string up to position 30}
     end;


begin
  {some house keeping}
  result:=false; {assume failure}
  if load_data then mainwindow.caption:=ExtractFileName(filen);
  {house keeping done}

  try
    TheFile3:=tfilestream.Create( filen, fmOpenRead or fmShareDenyWrite);
  except
     beep;
     mainwindow.statusbar1.panels[7].text:='Error accessing file!';
     mainwindow.error_label1.caption:=('Error accessing file!');
     mainwindow.error_label1.visible:=true;
     exit;
  end;
  fits_file:=false; {assume failure}

  mainwindow.memo1.visible:=false;{stop visualising memo1 for speed. Will be activated in plot routine}
  mainwindow.memo1.clear;{clear memo for new header}

  Reader := TReader.Create (theFile3,6*2880);{number of records}
  {thefile3.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}

  {Reset variables for case they are not specified in the file}
  if light  then {reset variables in case they are not available}
  begin
    crota2:=99999;{just for the case it is not available, make it later zero}
    crota1:=99999;
    ra0:=0;
    dec0:=0;
    cdelt1:=0;
    cdelt2:=0;
    scale:=0; {SGP files}
    xpixsz:=0;
    ypixsz:=0;
    focallen:=0;
    subsamp:=1;{just for the case it is not available}
    cd1_1:=0;{just for the case it is not available}
    cd1_2:=0;{just for the case it is not available}
    cd2_1:=0;{just for the case it is not available}
    cd2_2:=0;{just for the case it is not available}
    bayerpat:='';{reset bayer pattern}
    xbayroff:=0;{offset to used to correct BAYERPAT due to flipping}
    ybayroff:=0;{offset to used to correct BAYERPAT due to flipping}
    roworder:='';{'BOTTOM-UP'= lower-left corner first in the file.  or 'TOP-DOWN'= top-left corner first in the file.}

    a_order:=0;{Simple Imaging Polynomial use by astrometry.net, if 2 then available}
    a_0_2:=0; a_0_3:=0; a_1_1:=0; a_1_2:=0;a_2_0:=0; a_2_1:=0; a_3_0:=0;
    b_0_2:=0; b_0_3:=0; b_1_1:=0; b_1_2:=0;b_2_0:=0; b_2_1:=0; b_3_0:=0;
    ap_0_1:=0; ap_0_2:=0; ap_0_3:=0; ap_1_0:=0; ap_1_1:=0; ap_1_2:=0; ap_2_0:=0; ap_2_1:=0; ap_3_0:=0;
    bp_0_1:=0; bp_0_2:=0; bp_0_3:=0; bp_1_0:=0; bp_1_1:=0; bp_1_2:=0; bp_2_0:=0; bp_2_1:=0; bp_3_0:=0;

    calstat:='';{indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected, S stacked. Example value DFB}
    centalt:=999;{assume no data available}
    centaz:=999;{assume no data available}
    x_coeff[0]:=0; {reset DSS_polynomial, use for check if there is data}
    y_coeff[0]:=0;
    a_order:=0; {SIP_polynomial, use for check if there is data}

    extend:=0; {no extensions in the file}

    xbinning:=1;{normal}
    ybinning:=1;

    date_obs:=''; date_avg:='';ut:=''; pltlabel:=''; plateid:=''; telescop:=''; instrum:='';  origin:=''; object_name:='';{clear}
    sitelat:=''; sitelong:='';

    focus_temp:=999;{assume no data available}
    focus_pos:=0;{assume no data available}

    annotated:=false; {any annotation in the file}

  end;{reset variables}

  filter_name:='';
  naxis:=-1;
  naxis1:=0;
  naxis3:=1;
  bzero:=0;{just for the case it is not available}
  bscale:=1;
  datamin_org:=0;
  imagetype:='';
  exposure:=0;
  exptime:=0;
  ccd_temperature:=999;
  set_temperature:=999;
  gain:=999;{assume no data available}

  measured_max:=0;
  flux_magn_offset:=0;{factor to calculate magnitude from flux, new file so set to zero}

  mainwindow.pagecontrol1.showtabs:=false;{hide tabs assuming no tabel extension}
  mainwindow.pagecontrol1.Tabindex:=0;{show first tab}

  reader_position:=0;
  repeat {header, 2880 bytes loop}

   I:=0;
    try
      reader.read(header[I],2880);{read file header, 2880 bytes}
    except;
      close_fits_file;
      beep;
      mainwindow.statusbar1.panels[7].text:='Read exception error!!';
      mainwindow.error_label1.caption:='Read exception error!!';
      mainwindow.error_label1.visible:=true;
      fits_file:=false;
      exit;
    end;
    inc(reader_position,2880);

    repeat {loop for 80 bytes in 2880 block}
      if ((i=0) and (reader_position=2880)) then if ((header[0]='S') and (header[1]='I')  and (header[2]='M') and (header[3]='P') and (header[4]='L') and (header[5]='E') and (header[6]=' '))=false then
          begin close_fits_file;
                beep;
                mainwindow.statusbar1.panels[7].text:=('Error loading FITS file!! Keyword SIMPLE not found.');
                mainwindow.error_label1.caption:=('Error loading FITS file!! Keyword SIMPLE not found.');
                mainwindow.error_label1.visible:=true;
                fits_file:=false;
                exit;
          end; {should start with SIMPLE  =,  MaximDL compressed files start with SIMPLE‚=”}
      if load_data then
      begin
        SetString(aline, Pansichar(@header[i]), 80);{convert header line to string}
        mainwindow.memo1.lines.add(aline); {add line to memo}
      end;
      if ((header[i]='B') and (header[i+1]='I')  and (header[i+2]='T') and (header[i+3]='P') and (header[i+4]='I') and (header[i+5]='X')) then
        nrbits:=round(validate_double);{BITPIX, read integer using double routine}
      if ((header[i]='N') and (header[i+1]='A')  and (header[i+2]='X') and (header[i+3]='I') and (header[i+4]='S')) then {naxis}
         begin
           if (header[i+5]=' ') then naxis:=round(validate_double)   else    {NAXIS number of colors}
           if (header[i+5]='1') then begin naxis1:=round(validate_double);width2:=naxis1; end else {NAXIS1 pixels}
           if (header[i+5]='2') then height2:=round(validate_double) else   {NAXIS2 pixels}
           if (header[i+5]='3') then
           begin
            naxis3:=round(validate_double); {NAXIS3 number of colors}
            if ((naxis=3) and (naxis1=3)) {naxis1} then  {type NAXIS = 3 / Number of dimensions
                                       NAXIS1 = 3 / Number of Colors
                                       NAXIS2 = 382 / Row length
                                       NAXIS3 = 255 / Number of rows}
                        begin   {RGB fits with naxis1=3, treated as 24 bits coded pixels in 2 dimensions}
                          width2:=height2;
                          height2:=naxis3;
                          naxis3:=1;
                        end;
           end;
         end;

      if (header[i]='B') then
      begin
        if ( (header[i+1]='Z')  and (header[i+2]='E') and (header[i+3]='R') and (header[i+4]='O') ) then
        begin
           dummy:=validate_double;
           if dummy>2147483647 then
           bzero:=-2147483648
           else
           bzero:=round(dummy); {Maxim DL writes BZERO value -2147483647 as +2147483648 !! }
          {without this it would have worked also with error check off}
        end
        else
        if ( (header[i+1]='S')  and (header[i+2]='C') and (header[i+3]='A') and (header[i+4]='L') ) then
         begin
            bscale:=validate_double; {rarely used. Normally 1}
         end;
      end;

      if ((header[i]='E') and (header[i+1]='X')  and (header[i+2]='P') and (header[i+3]='O') and (header[i+4]='S') and (header[i+5]='U') and (header[i+6]='R')) then
            exposure:=validate_double;{read double value}
      if ((header[i]='E') and (header[i+1]='X')  and (header[i+2]='P') and (header[i+3]='T') and (header[i+4]='I') and (header[i+5]='M') and (header[i+6]='E')) then
            exptime:=validate_double;{read double value}

      if ((header[i]='C') and (header[i+1]='C')  and (header[i+2]='D') and (header[i+3]='-') and (header[i+4]='T') and (header[i+5]='E') and (header[i+6]='M')) then
             ccd_temperature:=validate_double;{read double value}
      if ((header[i]='S') and (header[i+1]='E')  and (header[i+2]='T') and (header[i+3]='-') and (header[i+4]='T') and (header[i+5]='E') and (header[i+6]='M')) then
             try set_temperature:=round(validate_double);{read double value} except; end; {some programs give huge values}


      if ((header[i]='I') and (header[i+1]='M')  and (header[i+2]='A') and (header[i+3]='G') and (header[i+4]='E') and (header[i+5]='T') and (header[i+6]='Y')) then
         imagetype:=StringReplace(get_string,' ','',[rfReplaceAll]);{remove all spaces}

      if ((header[i]='F') and (header[i+1]='I')  and (header[i+2]='L') and (header[i+3]='T') and (header[i+4]='E') and (header[i+5]='R')) then
         filter_name:=StringReplace(get_string,' ','',[rfReplaceAll]);{remove all spaces}


      {following variable are not set at zero Set at zero somewhere in the code}
      if ((header[i]='L') and (header[i+1]='I')  and (header[i+2]='G') and (header[i+3]='H') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then
           light_count:=round(validate_double);{read integer as double value}
      if ((header[i]='D') and (header[i+1]='A')  and (header[i+2]='R') and (header[i+3]='K') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then
           dark_count:=round(validate_double);{read integer as double value}
      if ((header[i]='F') and (header[i+1]='L')  and (header[i+2]='A') and (header[i+3]='T') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then
           flat_count:=round(validate_double);{read integer as double value}
      if ((header[i]='B') and (header[i+1]='I')  and (header[i+2]='A') and (header[i+3]='S') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then
           flatdark_count:=round(validate_double);{read integer as double value}

      if ((header[i]='G') and (header[i+1]='A')  and (header[i+2]='I') and (header[i+3]='N') and (header[i+4]=' ')) then
             gain:=validate_double;{gain CCD}


      if light then {read as light ##############################################################################################################################################################}
      begin
        if ((header[i]='O') and (header[i+1]='B')  and (header[i+2]='J') and (header[i+3]='E') and (header[i+4]='C') and (header[i+5]='T')) then
            object_name:=StringReplace(get_string,' ','',[rfReplaceAll]);{remove all spaces}

        if ((header[i]='E') and (header[i+1]='Q')  and (header[i+2]='U') and (header[i+3]='I') and (header[i+4]='N') and (header[i+5]='O') and (header[i+6]='X')) then
             equinox:=validate_double;

        if ((header[i]='C') and (header[i+1]='R')  and (header[i+2]='O') and (header[i+3]='T') and (header[i+4]='A')) then  {crota2}
        begin
           if (header[i+5]='2') then  crota2:=validate_double else {read double value}
           if (header[i+5]='1') then  crota1:=validate_double;{read double value}
        end;
        if ((header[i]='C') and (header[i+1]='R')  and (header[i+2]='P') and (header[i+3]='I') and (header[i+4]='X')) then {crpix1}
        begin
          if header[i+5]='1' then crpix1:=validate_double else{ref pixel for x}
          if header[i+5]='2' then crpix2:=validate_double;    {ref pixel for y}
        end;
        if ((header[i]='C') and (header[i+1]='D')  and (header[i+2]='E') and (header[i+3]='L') and (header[i+4]='T')) then {cdelt1}
           begin
            if header[i+5]='1' then cdelt1:=validate_double else{deg/pixel for RA}
            if header[i+5]='2' then cdelt2:=validate_double;    {deg/pixel for DEC}
          end;
        if ( ((header[i]='S') and (header[i+1]='E')  and (header[i+2]='C') and (header[i+3]='P') and (header[i+4]='I') and (header[i+5]='X')) or     {secpix1/2}
             ((header[i]='P') and (header[i+1]='I')  and (header[i+2]='X') and (header[i+3]='S') and (header[i+4]='C') and (header[i+5]='A')) ) then {pixscale}
        begin
          if cdelt2=0 then
              begin cdelt2:=validate_double/3600; {deg/pixel for RA} cdelt1:=cdelt2; end; {no CDELT1/2 found yet, use alternative}
        end;

        if ((header[i]='X') and (header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='S') and (header[i+5]='Z')) then {xpixsz}
               xpixsz:=validate_double;{Pixel Width in microns (after binning), maxim DL keyword}
        if ((header[i]='Y') and (header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='S') and (header[i+5]='Z')) then {xpixsz}
               ypixsz:=validate_double;{Pixel Width in microns (after binning), maxim DL keyword}

        if ((header[i]='F') and (header[i+1]='O')  and (header[i+2]='C') and (header[i+3]='A') and (header[i+4]='L') and (header[i+5]='L')) then  {focall}
                focallen:=validate_double;{Focal length of telescope in mm, maxim DL keyword}

        if ((header[i]='C') and (header[i+1]='R')  and (header[i+2]='V') and (header[i+3]='A') and (header[i+4]='L')) then {crval1/2}
        begin
          if (header[i+5]='1') then  ra0:=validate_double*pi/180; {ra center, read double value}
          if (header[i+5]='2') then  dec0:=validate_double*pi/180; {dec center, read double value}
        end;
        if ((header[i]='R') and (header[i+1]='A')  and (header[i+2]=' ')) then  {ra}
            if ra0=0 then ra0:=validate_double*pi/180; {ra telescope, read double value only if crval is not available}
        if ((header[i]='D') and (header[i+1]='E')  and (header[i+2]='C') and (header[i+3]=' ')) then {dec}
            if dec0=0 then dec0:=validate_double*pi/180; {ra telescope, read double value only if crval is not available}

        if ((header[i]='O') and (header[i+1]='B')  and (header[i+2]='J') and (header[i+3]='C') and (header[i+4]='T')) then  {objctra}
        begin
          if ((header[i+5]='R') and (header[i+6]='A')) then
          begin
            mainwindow.ra1.text:=get_string;
          end
          else
          if ((header[i+5]='D') and (header[i+6]='E')) then
          begin
            mainwindow.dec1.text:=get_string;
          end
          else
          if ((header[i+5]='A') and (header[i+6]='Z')) then centaz:=strtofloat2(get_string) {for MaximDL5}
          else
          if ((header[i+5]='A') and (header[i+6]='L')) then centalt:=strtofloat2(get_string); {for MaximDL5}
        end;

        if ((header[i]='C') and (header[i+1]='E')  and (header[i+2]='N') and (header[i+3]='T') and (header[i+4]='A')) then
        begin
          if ((header[i+5]='L') and (header[i+6]='T')) then centalt:=validate_double {read double value}
          else
          if (header[i+5]='Z') then centaz:=validate_double {read double value}
        end;

        if ((header[i]='C') and (header[i+1]='D')) then
            begin
              if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='1')) then   cd1_1:=validate_double;
              if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='2')) then   cd1_2:=validate_double;
              if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='1')) then   cd2_1:=validate_double;
              if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='2')) then   cd2_2:=validate_double;
            end;

        if ((header[i]='C') and (header[i+1]='A')  and (header[i+2]='L') and (header[i+3]='S') and (header[i+4]='T') and (header[i+5]='A')) then
           calstat:=get_string;{indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected.}


        if ((header[i]='F') and (header[i+1]='O')  and (header[i+2]='C') and
                        (( (header[i+3]='U') and (header[i+4]='S') and (header[i+5]='T') and (header[i+6]='E')) or
                         ( (header[i+3]='T') and (header[i+4]='E') and (header[i+5]='M') and (header[i+6]='P')) )  ) then
               focus_temp:=validate_double;{focus temperature}
        if ((header[i]='A') and (header[i+1]='M')  and (header[i+2]='B') and (header[i+3]='-') and (header[i+4]='T') and (header[i+5]='E') and (header[i+6]='M')) then
               focus_temp:=validate_double;{ambient temperature}


        if ((header[i]='F') and (header[i+1]='O')  and (header[i+2]='C') and
                        (( (header[i+3]='U') and (header[i+4]='S') and (header[i+5]='P') and (header[i+6]='O')) or
                         ( (header[i+3]='P') and (header[i+4]='O') and (header[i+5]='S') and (header[i+6]=' ')) )  ) then
               try focus_pos:=round(validate_double);{focus position} except;end;



        if ((header[i]='S') and (header[i+1]='C')  and (header[i+2]='A') and (header[i+3]='L') and (header[i+4]='E')) then  scale:=validate_double; {scale value for SGP files}

        if ((header[i]='R') and (header[i+1]='E')  and (header[i+2]='F') and (header[i+3]='_') and             (header[i+5]=' ')) then  {for manual alignment stacking, second phase}
            begin
              if (header[i+4]='X') then   ref_X:=validate_double {for manual alignment stacking}
              else
              if (header[i+4]='Y') then   ref_Y:=validate_double;
            end;

        if ((header[i]='B') and (header[i+1]='A')  and (header[i+2]='Y') and (header[i+3]='E') and (header[i+4]='R') and (header[i+5]='P') and (header[i+6]='A')) then
           bayerpat:=get_string;{BAYERPAT, bayer pattern such as RGGB}

       if ((header[i]='X') and (header[i+1]='B')  and (header[i+2]='A') and (header[i+3]='Y') and (header[i+4]='R') and (header[i+5]='O') and (header[i+6]='F')) then
           xbayroff:=validate_double;{offset to used to correct BAYERPAT due to flipping}

        if ((header[i]='Y') and (header[i+1]='B')  and (header[i+2]='A') and (header[i+3]='Y') and (header[i+4]='R') and (header[i+5]='O') and (header[i+6]='F')) then
           ybayroff:=validate_double;{offset to used to correct BAYERPAT due to flipping}

        if ((header[i]='R') and (header[i+1]='O')  and (header[i+2]='W') and (header[i+3]='O') and (header[i+4]='R') and (header[i+5]='D') and (header[i+6]='E')) then
                   roworder:=get_string;

        if ((header[i]='S') and (header[i+1]='I')  and (header[i+2]='T') and (header[i+3]='E') and (header[i+4]='L')) then  {site latitude, longitude}
        begin
          if ((header[i+5]='A') and (header[i+6]='T')) then
            sitelat:=get_as_string;{universal, site latitude as string}
          if ((header[i+5]='O') and (header[i+6]='N')) then
             sitelong:=get_as_string;{universal, site longitude as string}
        end;
        if ((header[i]='O') and (header[i+1]='B')  and (header[i+2]='S'))  then  {site latitude, longitude}
        begin
          if ( ((header[i+3]='L') and (header[i+4]='A') and (header[i+5]='T')) or ((header[i+3]='-') and (header[i+4]='L') and(header[i+5]='A')) ) then  {OBSLAT or OBS-LAT}
            sitelat:=get_as_string;{universal, site latitude as string}
          if ( ((header[i+3]='L') and (header[i+4]='O') and(header[i+5]='N')) or ((header[i+3]='-') and (header[i+4]='L') and(header[i+5]='O')) ) then  {OBSLONG or OBS-LONG}
             sitelong:=get_as_string;{universal, site longitude as string}

          if ((header[i+3]='G') and (header[i+4]='E') and (header[i+5]='O') and(header[i+6]='-')) then {OBSGEO-L, OBSGEO-B}
          begin
            if (header[i+7]='B') then
              sitelat:=get_as_string {universal, site latitude as string}
            else
            if (header[i+7]='L') then
              sitelong:=get_as_string;{universal, site longitude as string}
          end;
        end;

        if ((header[i]='U') and (header[i+1]='T')) then
                 UT:=get_string;
        if ((header[i]='T') and (header[i+1]='E')  and (header[i+2]='L') and (header[i+3]='E') and (header[i+4]='S') and (header[i+5]='C') and (header[i+6]='O')) then
                 TELESCOP:=get_string;
        if ((header[i]='O') and (header[i+1]='R')  and (header[i+2]='I') and (header[i+3]='G') and (header[i+4]='I') and (header[i+5]='N')) then
                 origin:=get_string;
        if ((header[i]='I') and (header[i+1]='N')  and (header[i+2]='S') and (header[i+3]='T') and (header[i+4]='R') and (header[i+5]='U') and (header[i+6]='M')) then
                 INSTRUM:=get_string;

        if ((header[i]='T') and (header[i+1]='I')  and (header[i+2]='M') and (header[i+3]='E') and (header[i+4]='-') and (header[i+5]='O') and (header[i+6]='B')) then
                if date_obs='' then date_obs:=get_string;

        if ((header[i]='D') and (header[i+1]='A')  and (header[i+2]='T') and (header[i+3]='E') and (header[i+4]='-') and (header[i+5]='O') and (header[i+6]='B')) then
                date_obs:=get_string;

        if ((header[i]='D') and (header[i+1]='A')  and (header[i+2]='T') and (header[i+3]='E') and (header[i+4]='-') and (header[i+5]='A') and (header[i+6]='V')) then
                date_avg:=get_string;

        if ((header[i]='B') and (header[i+1]='A')  and (header[i+2]='N') and (header[i+3]='D') and (header[i+4]='P') and (header[i+5]='A') and (header[i+6]='S')) then
        begin
           BANDPASS:=validate_double;{read integer as double value. Deep sky survey keyword}
           if ((bandpass=35) or (bandpass=8)) then filter_name:='red'{ 37 possII IR,  35=possII red, 18=possII blue, 8=POSSI red, 7=POSSI blue}
           else
           if ((bandpass=18) or (bandpass=7)) then filter_name:='blue'
           else
           filter_name:=floattostr(bandpass);
        end;

        if ((header[i]='X') and (header[i+1]='B')  and (header[i+2]='I') and (header[i+3]='N') and (header[i+4]='N') and (header[i+5]='I')) then
                 xbinning:=round(validate_double);{binning}
        if ((header[i]='Y') and (header[i+1]='B')  and (header[i+2]='I') and (header[i+3]='N') and (header[i+4]='N') and (header[i+5]='I')) then
                 ybinning:=round(validate_double);{binning}

        if ((header[i]='A') and (header[i+1]='N')  and (header[i+2]='N') and (header[i+3]='O') and (header[i+4]='T') and (header[i+5]='A') and (header[i+6]='T')) then
           annotated:=true; {contains annotations}

        if ((header[i]='E') and (header[i+1]='X')  and (header[i+2]='T') and (header[i+3]='E') and (header[i+4]='N') and (header[i+5]='D')) then {EXTEND}
          if pos('T',get_as_string)>0 then extend:=1; {could contain extension}


        {following is only required when using DSS polynome plate fit}
        if ((header[i]='A') and (header[i+1]='M')  and (header[i+2]='D') and (header[i+3]='X')) then
          begin
            if header[i+5]=' ' then s:=(header[i+4]) else s:=(header[i+4])+(header[i+5]);
            val(s,nr,error3);{1 to 20}
            x_coeff[nr-1]:=validate_double;
          end;
        if ((header[i]='A') and (header[i+1]='M')  and (header[i+2]='D') and (header[i+3]='Y')) then
        begin
          if header[i+5]=' ' then s:=(header[i+4]) else s:=(header[i+4])+(header[i+5]);
          val(s,nr,error3);{1 to 20}
          y_coeff[nr-1]:=validate_double;
        end;
        if ((header[i]='P') and (header[i+1]='P')  and (header[i+2]='O')) then
        begin
          if (header[i+3]='3') then   ppo_coeff[2]:=validate_double;
          if (header[i+3]='6') then   ppo_coeff[5]:=validate_double;
        end;
        if ((header[i]='A') and (header[i+1]='_')) then
        begin
          if ((header[i+2]='O') and (header[i+3]='R') and (header[i+4]='D')) then a_order:=round(validate_double);{should be 2 if TAN-SIP convention available}
          if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='2')) then a_0_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='3')) then a_0_3:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='1')) then a_1_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='2')) then a_1_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='0')) then a_2_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='1')) then a_2_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='3') and (header[i+3]='_') and (header[i+4]='0')) then a_3_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
        end;
        if ((header[i]='B') and (header[i+1]='_')) then
        begin
          if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='2')) then b_0_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='3')) then b_0_3:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='1')) then b_1_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='2')) then b_1_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='0')) then b_2_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='1')) then b_2_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+2]='3') and (header[i+3]='_') and (header[i+4]='0')) then b_3_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
        end;
        if ((header[i]='A') and (header[i+1]='P') and (header[i+2]='_')) then
        begin
          if ((header[i+3]='0') and (header[i+4]='_') and (header[i+5]='1')) then ap_0_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='0') and (header[i+4]='_') and (header[i+5]='2')) then ap_0_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='0') and (header[i+4]='_') and (header[i+5]='3')) then ap_0_3:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='1') and (header[i+4]='_') and (header[i+5]='0')) then ap_1_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='1') and (header[i+4]='_') and (header[i+5]='1')) then ap_1_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='1') and (header[i+4]='_') and (header[i+5]='2')) then ap_1_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='2') and (header[i+4]='_') and (header[i+5]='0')) then ap_2_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='2') and (header[i+4]='_') and (header[i+5]='1')) then ap_2_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='3') and (header[i+4]='_') and (header[i+5]='0')) then ap_3_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
        end;
        if ((header[i]='B') and (header[i+1]='P') and (header[i+2]='_')) then
        begin
          if ((header[i+3]='0') and (header[i+4]='_') and (header[i+5]='1')) then bp_0_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='0') and (header[i+4]='_') and (header[i+5]='2')) then bp_0_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='0') and (header[i+4]='_') and (header[i+5]='3')) then bp_0_3:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='1') and (header[i+4]='_') and (header[i+5]='0')) then bp_1_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='1') and (header[i+4]='_') and (header[i+5]='1')) then bp_1_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='1') and (header[i+4]='_') and (header[i+5]='2')) then bp_1_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='2') and (header[i+4]='_') and (header[i+5]='0')) then bp_2_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='2') and (header[i+4]='_') and (header[i+5]='1')) then bp_2_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          if ((header[i+3]='3') and (header[i+4]='_') and (header[i+5]='0')) then bp_3_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
        end;
        if ((header[i]='C') and (header[i+1]='N')  and (header[i+2]='P') and (header[i+3]='I') and (header[i+4]='X') and (header[i+5]='1')) then
                x_pixel_offset:=round(validate_double);{rotation, read double value}
        if ((header[i]='C') and (header[i+1]='N')  and (header[i+2]='P') and (header[i+3]='I') and (header[i+4]='X') and (header[i+5]='2')) then
                y_pixel_offset:=round(validate_double);{rotation, read double value}
        if ((header[i]='X') and (header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='E') and (header[i+5]='L')) then
                x_pixel_size:=validate_double;{rotation, read double value}
        if ((header[i]='Y') and (header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='E') and (header[i+5]='L')) then
                y_pixel_size:=validate_double;{rotation, read double value}
        if ((header[i]='P') and (header[i+1]='L')  and (header[i+2]='T') and (header[i+3]='R') and (header[i+4]='A')) then
        begin
          if (header[i+5]='H') then   plate_ra:=validate_double*pi/12;
          if (header[i+5]='M') then   plate_ra:=plate_ra+validate_double*pi/(60*12);
          if (header[i+5]='S') then   plate_ra:=plate_ra+validate_double*pi/(60*60*12);;
        end;
        if ((header[i]='P') and (header[i+1]='L')  and (header[i+2]='T') and (header[i+3]='D') and (header[i+4]='E')) then
        begin
          if (header[i+7]='N') then  begin if (header[i+11]='-') then  dec_sign:=-1 else dec_sign:=+1;end; {dec sign}
          if (header[i+6]='D') then   plate_dec:=validate_double*pi/180;
          if (header[i+6]='M') then   plate_dec:=plate_dec+validate_double*pi/(60*180);
          if (header[i+6]='S') then   plate_dec:=dec_sign*(plate_dec+validate_double*pi/(60*60*180));
        end;
        if ((header[i]='S') and (header[i+1]='U')  and (header[i+2]='B') and (header[i+3]='S') and (header[i+4]='A') and (header[i+5]='M')) then
                subsamp:=round(validate_double);{subsampling value}
       {end using DSS polynome plate fit}

        if ((header[i]='P') and (header[i+1]='L')  and (header[i+2]='T') and (header[i+3]='L') and (header[i+4]='A') and (header[i+5]='B') and (header[i+6]='E')) then {Deep sky survey}
                 PLTLABEL:=get_string;
        if ((header[i]='P') and (header[i+1]='L')  and (header[i+2]='A') and (header[i+3]='T') and (header[i+4]='E') and (header[i+5]='I') and (header[i+6]='D')) then
                 PLATEID:=get_string;


      end;{read as light #####################################################################################################################################3#############################}


      end_record:=((header[i]='E') and (header[i+1]='N')  and (header[i+2]='D') and (header[i+3]=' '));{end of header. Note keyword ENDIAN exist, so test space behind END}
      inc(i,80);{go to next 80 bytes record}
    until ((i>=2880) or (end_record));
  until end_record;


  if ((naxis=3) and (naxis1=3)) then
  begin
     nrbits:=24; {threat RGB fits as 2 dimensional with 24 bits data}
     naxis3:=3; {will be converted while reading}
  end;
  if ( ((cdelt1=0) or (crota2>=999)) and (cd1_1<>0)) then
  begin
    new_to_old_WCS;{ convert old WCS to new}
  end
  else
  if ((crota2<999) and (cd1_1=0) and(cdelt1<>0)) then {valid crota2 value}
  begin
    old_to_new_WCS;{ convert old WCS to new}
  end;

  if exptime>exposure then exposure:=exptime;{both keywords are used}
  if set_temperature=999 then set_temperature:=round(ccd_temperature); {temperature}

  if crota2>999 then crota2:=0;{not defined, set at 0}
  if crota1>999 then crota1:=crota2; {for case crota1 is not used}

  if ((light) and (ra0<>0) and (dec0<>0)) then
  begin
     mainwindow.ra1.text:=prepare_ra(ra0,' ');
     mainwindow.dec1.text:=prepare_dec(dec0,' ');
  end;

  if ((cd1_1=0) and (cdelt2=0)) then  {no scale, try to fix it}
  begin
     if scale<>0 then {sgp file, use scale to find image dimensions}
       cdelt2:=scale/3600 {scale is in arcsec/pixel }
     else
     if ((focallen<>0) and (xpixsz<>0)) then
       cdelt2:=180/(pi*1000)*xpixsz/focallen; {use maxim DL key word. xpixsz is including binning}
  end;
  unsaved_import:=false;{file is available for astrometry.net}

  if load_data=false then begin
     close_fits_file; result:=true; exit;
  end;{only read header for analyse or WCS file}

  if naxis<2 then
  begin
     result:=false; {no image}
     mainwindow.image1.visible:=false;
     fits_file:=false;
     if extend=0 then exit;
  end;

  {############################## read image}
  if naxis>=2 then {image in FITS}
  begin {image}
    i:=round(bufwide/(abs(nrbits/8)));{check if buffer is wide enough for one image line}
    if width2>i then
    begin
      beep;
      textout(mainwindow.image1.canvas.handle,30,30,'Too wide FITS file !!!!!',25);
      close_fits_file;
      exit;
    end;

    setlength(img_loaded2,naxis3,width2,height2);

    if nrbits=16 then
    for k:=0 to naxis3-1 do {do all colors}
    begin
      For j:=0 to height2-1 do
      begin
        try reader.read(fitsbuffer,width2*2);except; end; {read file info}
        for i:=0 to width2-1 do
        begin
          wo:=swap(fitsbuffer2[i]);{move data to wo and therefore sign_int}
          col_float:=sign_int*bscale + bzero; {save in col_float for measuring measured_max}
          img_loaded2[k,i,j]:=col_float;
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end {colors naxis3 times}
    else
    if nrbits=-32 then
    for k:=0 to naxis3-1 do {do all colors}
    begin
      For j:=0 to height2-1 do
      begin
        try reader.read(fitsbuffer,width2*4);except; end; {read file info}
        for i:=0 to width2-1 do
        begin
          x_longword:=swapendian(fitsbuffer4[i]);{conversion 32 bit "big-endian" data, x_single  : single absolute x_longword; }
          col_float:=x_single*bscale+bzero; {int_IEEE, swap four bytes and the read as floating point}
          img_loaded2[k,i,j]:=col_float;{store in memory array}
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end {colors naxis3 times}
    else
    if nrbits=8 then
    for k:=0 to naxis3-1 do {do all colors}
    begin
      For j:=0 to height2-1 do
      begin
        try reader.read(fitsbuffer,width2);except; end; {read file info}
        for i:=0 to width2-1 do
        begin
          img_loaded2[k,i,j]:=(fitsbuffer[i]*bscale + bzero);
        end;
      end;
    end {colors naxis3 times}
    else
    if nrbits=24 then
    For j:=0 to height2-1 do
    begin
      try reader.read(fitsbuffer,width2*3);except; end; {read file info}
      for i:=0 to width2-1 do
      begin
        rgbdummy:=fitsbufferRGB[i];{RGB fits with naxis1=3, treated as 24 bits coded pixels in 2 dimensions}
        img_loaded2[0,i,j]:=rgbdummy[0];{store in memory array}
        img_loaded2[1,i,j]:=rgbdummy[1];{store in memory array}
        img_loaded2[2,i,j]:=rgbdummy[2];{store in memory array}
      end;
    end
    else
    if nrbits=+32 then
    for k:=0 to naxis3-1 do {do all colors}
    begin
      For j:=0 to height2-1 do
      begin
        try reader.read(fitsbuffer,width2*4);except; end; {read file info}
        for i:=0 to width2-1 do
        begin
          col_float:=(swapendian(fitsbuffer4[i])*bscale+bzero)/(65535);{scale to 0..64535 or 0..1 float}
                         {Tricky do not use int64 for BZERO,  maxim DL writes BZERO value -2147483647 as +2147483648 !!}
          img_loaded2[k,i,j]:=col_float;{store in memory array}
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end {colors naxis3 times}
    else
    if nrbits=-64 then
    for k:=0 to naxis3-1 do {do all colors}
    begin
      For j:=0 to height2-1 do
      begin
        try reader.read(fitsbuffer,width2*8);except; end; {read file info}
        for i:=0 to width2-1 do
        begin
          x_int64:=swapendian(fitsbuffer8[i]);{conversion 64 bit "big-endian" data, x_double    : double absolute x_int64;}
          col_float:=x_double*bscale + bzero; {int_IEEE, swap four bytes and the read as floating point}
          img_loaded2[k,i,j]:=col_float;{store in memory array}
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end; {colors naxis3 times}

    {rescale if required}
    if ( ((nrbits<=-32){-32 or -64} or (nrbits=+32)) and  (measured_max<=1.01) ) then {rescale 0..1 range float for GIMP, Astro Pixel Processor, PI files, transfer to 0..64000 float}
    begin
      for k:=0 to naxis3-1 do {do all colors}
        for j:=0 to height2-1 do
          for i:=0 to width2-1 do
            img_loaded2[k,i,j]:= img_loaded2[k,i,j]*65535;
      datamax_org:=measured_max*65535;
    end
    else
    if nrbits=8 then datamax_org:=255 {not measured}
    else
    if nrbits=24 then
    begin
      datamax_org:=255;
      nrbits:=8; {already converted to array with seperate colour sections}
    end
    else {16, -32 bit}
    datamax_org:=measured_max;{most common. It set for nrbits=24 in beginning at 255}

    cblack:=datamin_org;{for case histogram is not called}
    cwhite:=datamax_org;

    result:=true;
    fits_file:=true;{succes}
  end;{read image}

  if ((extend>0) and (light)) then {table behind? Do not try to read a table as dark/flat. This will reset global extend variable}
  begin {read ASCII or binary table}
    if naxis>=2 then {image was read}
      reader_position:=reader_position + width2*height2*(abs(nrbits) div 8);
    fract:=frac(reader_position/2880);
    if fract<>0 then
    begin
      i:=round((1-fract)*2880);{left part of next 2880 bytes block}
      try reader.read(header[0],i);
      except;
        close_fits_file;
        exit;
      end; {skip empty part and go to image data}
      inc(reader_position,i);
    end;
    extend:=0;{assume no extension}

    repeat {read extension}
      i:=0;
      try
        reader.read(header[I],2880);{read file header, 2880 bytes}
      except;
        close_fits_file;
        exit;
      end;
      inc(reader_position,2880);
      repeat
        if extend=0 then {test for extension}
        begin
           if ((header[0]='X') and (header[1]='T')  and (header[2]='E') and (header[3]='N') and (header[4]='S') and (header[5]='I') and (header[6]='O')) then
           begin
             if pos('BINTABLE',get_string)>0 then extend:=2 { 'BINTABLE' or 'TABLE'}
             else
             if pos('TABLE ',get_string)>0 then extend:=1 {ascii_table identifier}
             else
             begin
               extend:=0; {second (thumbnail) image}
               mainwindow.Memo3.lines.text:='File contains a second image. Will not be processed or preserved.';
               mainwindow.pagecontrol1.showtabs:=true;{show tabs}
             end;
           end;
           if naxis<2 then
           begin
             mainwindow.error_label1.caption:=('Table only');
             mainwindow.error_label1.visible:=true;
             mainwindow.pagecontrol1.Tabindex:=1;{show Table tab}
             mainwindow.memo1.visible:=true;{show memo1 since no plotting is comming}
           end;
        end;
        if extend>0 then
        begin
          if ((header[i]='N') and (header[i+1]='A')  and (header[i+2]='X') and (header[i+3]='I') and (header[i+4]='S')) then {naxisT}
             begin
               if (header[i+5]='1') then begin naxisT1:=round(validate_double); end else {naxisT1 pixels}
               if (header[i+5]='2') then naxisT2:=round(validate_double) else   {naxisT2 pixels}
             end;
          if ((header[i]='T') and (header[i+1]='F')  and (header[i+2]='I') and (header[i+3]='E') and (header[i+4]='L') and (header[i+5]='D') and (header[i+6]='S')) then {tfields}
          begin
             tfields:=round(validate_double);
             setlength(ttype,tfields);
             setlength(tform,tfields);
             setlength(tbcol,tfields);
             setlength(tunit,tfields);
          end;
          if ((header[i]='T') and (header[i+1]='F')  and (header[i+2]='O') and (header[i+3]='R') and (header[i+4]='M')) then
          begin
            number:=trim(header[i+5]+header[i+6]+header[i+7]);
            tform_counter:=strtoint(number)-1;
            tform[tform_counter]:=get_string;
            if pos('E',tform[tform_counter])>0 then tform[tform_counter]:='E';{remove spaces}
            if pos('D',tform[tform_counter])>0 then tform[tform_counter]:='D';
            if pos('L',tform[tform_counter])>0 then tform[tform_counter]:='L';{logical}
            if pos('B',tform[tform_counter])>0 then tform[tform_counter]:='B';{byte}
            if pos('I',tform[tform_counter])>0 then tform[tform_counter]:='I';{16 bit integer}
            if pos('J',tform[tform_counter])>0 then tform[tform_counter]:='J';{32 bit integer}
            if pos('K',tform[tform_counter])>0 then tform[tform_counter]:='K';{64 bit integer}
            p:=pos('A',tform[tform_counter]);
            if p>0 then
            begin
               aline:=copy(tform[tform_counter],1,p-1);
               tform[tform_counter]:='A';{Charactor} nrchars:=strtoint(aline); if nrchars=0 then nrchars:=1; end;  {e.g. 12A for astrometry.net first index table}
          end;
          if ((header[i]='T') and (header[i+1]='B')  and (header[i+2]='C') and (header[i+3]='O') and (header[i+4]='L')) then
          begin
            number:=trim(header[i+5]+header[i+6]+header[i+7]);
            tform_counter:=strtoint(number)-1;
            tbcol[tform_counter]:=round(validate_double);
          end;

          if ((header[i]='T') and (header[i+1]='T')  and (header[i+2]='Y') and (header[i+3]='P') and (header[i+4]='E')) then {field describtion like X, Y}
          begin
             number:=trim(header[i+5]+header[i+6]+header[i+7]);
             ttype[strtoint(number)-1]:=trim(get_string);
          end;
          if ((header[i]='T') and (header[i+1]='U')  and (header[i+2]='N') and (header[i+3]='I') and (header[i+4]='T')) then {unit describtion}
          begin
             number:=trim(header[i+5]+header[i+6]+header[i+7]);
             tunit[strtoint(number)-1]:=get_string;
          end;

          end_record:=((header[i]='E') and (header[i+1]='N')  and (header[i+2]='D') and (header[i+3]=' '));{end of header}

         inc(i,80);
         end;
      until ((i>=2880) or (end_record));
   until end_record;

   if extend>0 then {try to read data table}
   begin
     aline:='';
     for k:=0 to tfields-1 do {columns}
        aline:=aline+ttype[k]+#9;
     aline:=aline+sLineBreak;
     for k:=0 to tfields-1 do {columns}
        aline:=aline+tunit[k]+#9;
     aline:=aline+sLineBreak;

 //    if ((ttype[0]='X_IMAGE') and (ttype[1]='Y_IMAGE') and (extend=2)) then {x y table of stars}
//     begin
//       extend:=3; {table usable for solving}
//       setlength(starlist2,2,naxisT2)
//     end;

     for j:=0 to naxisT2-1 do {rows}
     begin
       reader.read(fitsbuffer[0],naxisT1);{copy complete ascii row}
       if extend=1 {ascii_table} then SetString(field, Pansichar(@fitsbuffer[0]),naxisT1);{convert to string}

       for k:=0 to tfields-1 do {columns}
        {read}
       begin
         if extend=1 then {ascii table}
         begin
           if k>0 then insert(#9,field,tbcol[k]+k-1);{insert tab}
           if k=tfields-1 then aline:=aline+field;{field is ready}
         end
         else

         if tform[k]='E' then {4 byte float}
         begin
           x_longword:=swapendian(fitsbuffer4[k]);{conversion 32 bit "big-endian" data, x_single  : single absolute x_longword; }

//           if ((extend=3) and (k<=1)) then starlist2[k,j]:=x_single-1; {import a star list for solving. Subtract -1 for conversion fits coordinates 1.. to array cordinates 0..}
           aline:=aline+floattostrF(x_single,FFexponent,7,0)+ #9; {int_IEEE, swap four bytes and the read as floating point}
         end
         else
         if tform[k]='D' then {8 byte float}
         begin
           x_int64:=swapendian(fitsbuffer8[k]);{conversion 64 bit "big-endian" data, x_double    : double absolute x_int64;}
//           if ((extend=3) and (k<=1)) then starlist2[k,j]:=x_double-1; {import a star list for solving. Subtract -1 for conversion fits coordinates 1.. to array cordinates 0..}
           aline:=aline+floattostrF(x_double,FFexponent,7,0)+ #9; {int_IEEE, swap four bytes and the read as floating point}
         end
         else
         if tform[k]='I' then {16 bit}
         begin
           wo:=swap(fitsbuffer2[k]);{move data to wo and therefore sign_int}
           aline:=aline+inttostr(sign_int)+ #9; {int_IEEE, swap four bytes and the read as floating point}
         end
         else
         if tform[k]='J' then {32 bit}
         begin
           aline:=aline+inttostr(swapendian(fitsbuffer4[k]))+ #9; {int_IEEE, swap four bytes and the read as floating point}
         end
         else
         if tform[k]='K' then {64 bit}
         begin
           aline:=aline+inttostr(swapendian(fitsbuffer8[k]))+ #9; {int_IEEE, swap four bytes and the read as floating point}
         end
         else
         if ((tform[k]='L') or (Tform[k]='B')) then {logical, byte }
         begin
           aline:=aline+inttostr(fitsbuffer[k])+ #9;
         end;
         if ((Tform[k]='A')) then {chars}
         begin
           reader.read(fitsbuffer[0],nrchars);{copy complete ascii row}
           field:='';
           for n:=0 to nrchars-1 do field:=field+hexstr(fitsbuffer[n],2)+' ';
           aline:=aline+field+ #9;
         end;

       end;

       aline:=aline+sLineBreak ;
     end;
     mainwindow.Memo3.lines.text:=aline;
     mainwindow.Memo3.readonly:=(extend<=1);
     aline:=''; {release memory}
     mainwindow.pagecontrol1.showtabs:=true;{show tabs}
   end;
  end; {read table}
  close_fits_file;
end;

procedure DeleteFiles(lpath,FileSpec: string);{delete files such  *.wcs}
var
  lSearchRec:TSearchRec;
begin
  if FindFirst(lpath+FileSpec,faAnyFile,lSearchRec) = 0 then
  begin
    try
      repeat
        SysUtils.DeleteFile(lPath+lSearchRec.Name);
      until SysUtils.FindNext(lSearchRec) <> 0;
    finally
      SysUtils.FindClose(lSearchRec);  // Free resources on successful find
    end;
  end;
end;

procedure update_float(inpt,comment1:string;x:double);{update keyword of fits header in memo}
 var
   s,aline  : string;
   count1: integer;
begin
  str(x:20,s);

  count1:=mainwindow.Memo1.Lines.Count-1;
  while count1>=0 do {update keyword}
  begin
    if pos(inpt,mainwindow.Memo1.Lines[count1])>0 then {found}
    begin
      aline:=mainwindow.Memo1.Lines[count1];
      delete(aline,11,20);
      insert(s,aline,11);
      mainwindow.Memo1.Lines[count1]:=aline;
      exit;
    end;
    count1:=count1-1;
  end;
  {not found, add to the end}
  mainwindow.memo1.lines.insert(mainwindow.Memo1.Lines.Count-1,inpt+' '+s+comment1);
end;
procedure update_integer(inpt,comment1:string;x:integer);{update or insert variable in header}
 var
   s,aline  : string;
   count1   : integer;
begin
  str(x:20,s);

  count1:=mainwindow.Memo1.Lines.Count-1;
  while count1>=0 do {update keyword}
  begin
    if pos(inpt,mainwindow.Memo1.Lines[count1])>0 then {found}
    begin
      aline:=mainwindow.Memo1.Lines[count1];
      delete(aline,11,20);
      insert(s,aline,11);
      mainwindow.Memo1.Lines[count1]:=aline;
      exit;
    end;
    count1:=count1-1;
  end;
  {not found, add at the correct position or at the end}
  if inpt='NAXIS1  =' then mainwindow.memo1.lines.insert(3,inpt+' '+s+comment1) else{PixInsight requires to have it on 3th place}
  if inpt='NAXIS2  =' then mainwindow.memo1.lines.insert(4,inpt+' '+s+comment1) else{PixInsight requires to have it on 4th place}
  if inpt='NAXIS3  =' then mainwindow.memo1.lines.insert(5,inpt+' '+s+comment1) else{PixInsight requires to have it on this place}
  mainwindow.memo1.lines.insert(mainwindow.Memo1.Lines.Count-1,inpt+' '+s+comment1);
end;
procedure add_integer(inpt,comment1:string;x:integer);{add integer variable to header}
 var
   s        : string;
begin
  str(x:20,s);
  mainwindow.memo1.lines.insert(mainwindow.Memo1.Lines.Count-1,inpt+' '+s+comment1);
end;

procedure update_generic(message_key,message_value,message_comment:string);{update header using text only}
var
   count1: integer;
begin
  if ((pos('HISTORY',message_key)=0) and (pos('COMMENT',message_key)=0)) then {allow multiple lines of hisotry and comments}
  begin
    while length(message_value)<20 do message_value:=' '+message_value;{extend length, right aligned}
    while length(message_key)<8 do message_key:=message_key+' ';{make standard lenght of 8}

   count1:=mainwindow.Memo1.Lines.Count-1;
    while count1>=0 do {update keyword}
    begin
      if pos(message_key,mainwindow.Memo1.Lines[count1])>0 then {found}
      begin
        mainwindow.Memo1.Lines[count1]:=message_key+'= '+message_value+' / '+message_comment;
        exit;
      end;
      count1:=count1-1;
    end;
    {not found, add to the end}
    mainwindow.memo1.lines.insert(mainwindow.Memo1.Lines.Count-1,message_key+'= '+message_value+' / '+message_comment);
  end {no history of comment keyword}
  else
  mainwindow.memo1.lines.insert(mainwindow.Memo1.Lines.Count-1,message_key+' '+message_value+message_comment);
end;

procedure update_text(inpt,comment1:string);{update or insert text in header}
var
   count1: integer;
begin

  count1:=mainwindow.Memo1.Lines.Count-1;
  while count1>=0 do {update keyword}
  begin
    if pos(inpt,mainwindow.Memo1.Lines[count1])>0 then {found}
    begin
      mainwindow.Memo1.Lines[count1]:=inpt+' '+comment1;{text starting with char(39) should start at position 11 according FITS standard 4.0}
      exit;
    end;
    count1:=count1-1;
  end;
  {not found, add to the end}
  mainwindow.memo1.lines.insert(mainwindow.Memo1.Lines.Count-1,inpt+' '+comment1);
end;

procedure add_text(inpt,comment1:string);{add text to header memo}
begin
  mainwindow.memo1.lines.insert(mainwindow.Memo1.Lines.Count-1,inpt+' '+copy(comment1,1,79-length(inpt)));  {add to the end. Limit to 80 char max as specified by FITS standard}
end;

procedure add_long_comment(descrip:string);{add long text to header memo. Split description over several lines if required}
var
   i,j :integer;
begin
  i:=1 ;
  j:=length(descrip);
  while i<j do
  begin
    mainwindow.memo1.lines.insert(mainwindow.Memo1.Lines.Count-1,'COMMENT '+copy(descrip,I,72) );  {add to the end. Limit line length to 80}
    inc(i,72);
  end;
end;

procedure remove_key(inpt:string; all:boolean);{remove key word in header. If all=true then remove multiple of the same keyword}
var
   count1: integer;
begin

  count1:=mainwindow.Memo1.Lines.Count-1;
  while count1>=0 do {update keyword}
  begin
    if pos(inpt,mainwindow.Memo1.Lines[count1])>0 then {found}
    begin
      mainwindow.Memo1.Lines.delete(count1);
      if all=false then exit;
    end;
    count1:=count1-1;
  end;
end;

procedure create_test_image(type_test : integer);{create an artificial test image}
var
   i,j,m,n, factor,stepsize,starcounter    : integer;
   sigma,hole_radius,donut_radius,hfd_diameter : double;
   gradient                  : boolean;
begin
  naxis:=0; {0 dimensions}

  mainwindow.memo1.visible:=false;{stop visualising memo1 for speed. Will be activated in plot routine}
  mainwindow.memo1.clear;{clear memo for new header}

  {thefile3.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}
  crota2:=99999;{just for the case it is not available, make it later zero}
  crota1:=99999;
  ra0:=0;
  dec0:=0;
  cdelt1:=0;
  cdelt2:=0;
  xpixsz:=0;
  ypixsz:=0;
  focallen:=0;
  subsamp:=1;{just for the case it is not available}
  cd1_1:=0;{just for the case it is not available}
  cd1_2:=0;{just for the case it is not available}
  cd2_1:=0;{just for the case it is not available}
  cd2_2:=0;{just for the case it is not available}
  date_obs:=''; ut:=''; pltlabel:=''; plateid:=''; telescop:=''; instrum:='';  origin:=''; object_name:='';{clear}
  sitelat:=''; sitelong:='';
  naxis:=2; {succes, now 2 dimensions}
  filter_name:='';
  calstat:='';{indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected. Example value DFB}
  imagetype:='';
  xbinning:=1;{default}
  ybinning:=1;
  exposure:=0;
  set_temperature:=999;
  nrbits:=16;
  extend:=0; {no extensions in the file, 1 is ascii_table, 2 bintable}


  if width2<=100 then
  begin
    width2:=3200;{9:16}
    height2:=1800;
  end;{else use width and height of last fits file loaded}


  datamin_org:=1000;{for case histogram is not called}
  datamax_org:=65535;
  cblack:=datamin_org;{for case histogram is not called}
  cwhite:=datamax_org;


  gradient:=stackmenu1.artificial_image_gradient1.checked;

  sigma:=strtofloat2(stackmenu1.hfd_simulation1.text)/2.5;{gaussian shaped star, sigma is HFD/2.5, in perfect world it should be /2.354 but sigma 1 will be measured with current alogorithm as 2.5}

  starcounter:=0;

  if type_test=1 then {no stars just gradients}
  begin
    naxis3:=3; {NAXIS3 number of colors}
    setlength(img_loaded,naxis3,width2,height2);{set length of image array}
    factor:=round(width2/15);
    For i:=0 to height2-1 do
    for j:=0 to width2-1 do
    begin
      begin
        if i<400 then
        begin
          img_loaded[0,j,i]:=1000+factor*trunc(j/factor); {15 large steps}
          img_loaded[1,j,i]:=1000+factor*trunc(j/factor);
          img_loaded[2,j,i]:=1000+factor*trunc(j/factor);
        end
        else
        begin
          if i<1400 then img_loaded[0,j,i]:=1000+1+j {pixel value is x position + 1000} else img_loaded[0,j,i]:=1000;
          if ((i<1200) or ((i>=1400) and (i<1600)) ) then img_loaded[1,j,i]:=1000+1+j   else img_loaded[1,j,i]:=1000;
          if ((i<1200) or (i>=1600)) then img_loaded[2,j,i]:=1000+1+j                   else img_loaded[2,j,i]:=1000;
        end;
      end;
    end;
    filename2:='gradient_test_image.fit';
  end
  else
  begin {star test image}
    naxis3:=1; {NAXIS3 number of colors}
    setlength(img_loaded,naxis3,width2,height2);{set length of image array}

    For i:=0 to height2-1 do
    for j:=0 to width2-1 do
    begin
      if gradient=false then img_loaded[0,j,i]:=randg(1000,100 {noise}){default background is 1000}
      else
      img_loaded[0,j,i]:=-500*sqrt( sqr((i-height2/2)/height2) +sqr((j-width2/2)/height2) ){circular gradient}
                         + randg(1000,100 {noise}){default background is 100}


    end;

    stepsize:=round(sigma*3);
    if stepsize<8 then stepsize:=8;{minimum value}

    For i:=stepsize to height2-1-stepsize do
    for j:=stepsize to width2-1-stepsize do
    begin
      if ( (frac(i/100)=0) and (frac(j/100)=0)  )  then
      begin
        if i>height2-300 then {hot pixels} img_loaded[0,j,i]:=65535 {hot pixel}
        else {create real stars}
        begin
          inc(starcounter);
          for m:=-stepsize to stepsize do for n:=-stepsize to stepsize do
          begin
              if sigma*2.5<=5 then
              begin
                img_loaded[0,j+n,i+m]:=img_loaded[0,j+n,i+m]+(65000/power(starcounter,0.8)){Intensity} *exp(-0.5/sqr(sigma)*(m*m+n*n)); {gaussian shaped stars}
                if frac(starcounter/20)=0 then img_loaded[0,180+starcounter+n,130+starcounter+m]:=img_loaded[0,180+starcounter+n,130+starcounter+m]+(65000/power(starcounter,0.7)){Intensity} *exp(-0.5/sqr(sigma)*(m*m+n*n)) {diagonal gaussian shaped stars}
              end
              else
              begin
                hfd_diameter:=sigma*2.5;
                hole_radius:=trunc(hfd_diameter/3);
                donut_radius:=sqrt(2*sqr(hfd_diameter/2)-sqr(hole_radius));
                if ( (sqrt(n*n+m*m)<=donut_radius) and (sqrt(n*n+m*m)>=hole_radius){hole}) then img_loaded[0,j+n,i+m]:=img_loaded[0,j+n,i+m]+4000*sqr(j/width2) {DONUT SHAPED stars}
              end;
          end;

        end;
      end;

    end;
    filename2:='star_test_image.fit';
  end;


  for j:=0 to 10 do {create an header with fixed sequence}
    if (j<>5)  then {skip naxis3 for mono images}
        mainwindow.memo1.lines.add(head1[j]); {add lines to empthy memo1}
  mainwindow.memo1.lines.add(head1[27]); {add end}

  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);
  if naxis3=1 then  remove_key('NAXIS3  ',false{all});{remove key word in header. Some program don't like naxis3=1}
  update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer('DATAMAX =',' / Maximum data value                             ' ,round(datamax_org));
  update_text   ('COMMENT 1','  Written by Astrometric Stacking Program. www.hnsky.org');

  if type_test=2 then
  begin
    update_text   ('COMMENT A','  Artificial image, background has value 1000 with sigma 100 Gaussian noise');
    update_text   ('COMMENT B','  Top rows contain hotpixels with value 65535');
    update_text   ('COMMENT C','  Rows below have Gaussian stars with a sigma of '+floattostr2(sigma));
    update_text   ('COMMENT D','  Which will be measured as HFD '+stackmenu1.hfd_simulation1.text);
    update_text   ('COMMENT E','  Note that theoretical Gaussian stars with a sigma of 1 are');
    update_text   ('COMMENT F','  equivalent to a HFD of 2.354 if subsampled enough.');
  end;

  update_menu(true);{file loaded, update menu for fits. Set fits_file:=true}
  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,true,true);{plot test image}
end;

procedure progress_indicator(i:double; info:string);{0 to 100% indication of progress}
begin
//  mainwindow.caption:=inttostr(round(i))+'%'+info;
  if i<-99 then
  begin
    application.title:='ASTAP';

    mainwindow.statusbar1.SimplePanel:=false;

    mainwindow.caption:=ExtractFileName(filename2);
    stackmenu1.caption:='stack menu';
  end
  else
  begin
    application.title:=inttostr(round(i))+'%'+info;{show progress in taksbar}

    mainwindow.statusbar1.SimplePanel:=true;
    mainwindow.statusbar1.Simpletext:=inttostr(round(i))+'%'+info;{show progress in statusbar}

    stackmenu1.caption:=inttostr(round(i))+'%'+info;{show progress in stack menu}
  end;
end;

procedure ang_sep(ra1,dec1,ra2,dec2 : double;var sep: double);{calculates angular separation. according formula 9.1 old Meeus or 16.1 new Meeus, version 2018-5-23}
var sin_dec1,cos_dec1,sin_dec2,cos_dec2,cos_sep:double;
begin
  sincos(dec1,sin_dec1,cos_dec1);{use sincos function for speed}
  sincos(dec2,sin_dec2,cos_dec2);

  cos_sep:=sin_dec1*sin_dec2+ cos_dec1*cos_dec2*cos(ra1-ra2);
  sep:=arccos(cos_sep);
end;

function mode(img :image_array;colorm,xmin,xmax,ymin,ymax,max1 {maximum background expected}:integer):integer;{find the most common value of a local area and assume this is the best average background value}
var
   i,j,val,value_count,width3,height3  :integer;
   histogram : array of integer;
begin
  height3:=length(img[0,0]);{length}
  width3:=length(img[0]);{width}

  if xmin<0 then xmin:=0;
  if xmax>width3-1 then xmax:=width3-1;
  if ymin<0 then ymin:=0;
  if ymax>height3-1 then ymax:=height3-1;

  setlength(histogram,max1+1);


  for i := 0 to max1 do  histogram[i] := 0;{clear histogram}


  for i:=ymin to  ymax do
    begin
      for j:=xmin to xmax do
      begin
        val:=round(img[colorM,j,i]);{get one color value}
        if ((val>=1) and (val<max1)) then {ignore black areas and bright stars}
        inc(histogram[val],1);{calculate histogram}
      end;{j}
    end; {i}

  result:=0; {for case histogram is empthy due to black area}
  value_count:=0;
  for i := 1 to max1 do {get most common but ignore 0}
  begin
    val:=histogram[i];
    if  val>value_count then
    begin
      value_count:=val; {find most common in histogram}
      result:=i;
    end;
  end;
  histogram:=nil;{free mem}
end;

function get_negative_noise_level(img :image_array;colorm,xmin,xmax,ymin,ymax: integer;common_level:double): double;{find the negative noise level below most_common_level  of a local area}
var
   i,j,col,count_neg  :integer;
begin
   if xmin<0 then xmin:=0;
  if xmax>width2-1 then xmax:=width2-1;
  if ymin<0 then ymin:=0;
  if ymax>height2-1 then ymax:=height2-1;

  result:=0;
  count_neg:=0;
  For i:=ymin to  ymax do
  begin
    for j:=xmin to xmax do
    begin
      col:=round(img[colorM,j,i]);{get one color value}
      if ((col>=1) and (col<=common_level))  then {ignore black areas }
      begin
          inc(count_neg);
          result:=result+sqr(col-common_level);
      end;
    end;{j}
  end; {i}
  if count_neg>=1 then result:=sqrt(result/count_neg) {sd of negative values, so without stars}
    else result:=0;
end;

procedure backup_img;
begin
  if fits_file=true then
  begin
    if img_backup=nil then setlength(img_backup,size_backup+1);{create memory for size_backup backup images}
    inc(index_backup,1);
    if index_backup>size_backup then index_backup:=0;
    img_backup[index_backup].crpix1:=crpix1;{could be modified by crop}
    img_backup[index_backup].crpix2:=crpix2;{could be modified by crop}
    img_backup[index_backup].crval1:=ra0;
    img_backup[index_backup].crval2:=dec0;
    img_backup[index_backup].crota1:=crota1;{for 90 degrees rotate}
    img_backup[index_backup].crota2:=crota2;{for 90 degrees rotate}
    img_backup[index_backup].cdelt1:=cdelt1;
    img_backup[index_backup].cdelt2:=cdelt2;
    img_backup[index_backup].cd1_1:=cd1_1;
    img_backup[index_backup].cd1_2:=cd1_2;
    img_backup[index_backup].cd2_1:=cd2_1;
    img_backup[index_backup].cd2_2:=cd2_2;

    img_backup[index_backup].header:=mainwindow.Memo1.Text;{backup fits header}
    img_backup[index_backup].img:=img_loaded;
    setlength(img_backup[index_backup].img,naxis3,width2,height2);{this forces an duplication}{In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}

    mainwindow.Undo1.Enabled:=true;
  end;
end;

procedure restore_img;
var
   Save_Cursor:TCursor;
   resized :boolean;
   old_width2,old_height2 : integer;
begin

  if mainwindow.Undo1.Enabled=true then
  begin
    if img_backup=nil then exit;{for some rare cases}

    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }


    old_width2:=width2;
    old_height2:=height2;

    naxis3:=length(img_backup[index_backup].img);{nr colours}
    width2:=length(img_backup[index_backup].img[0]);{width}
    height2:=length(img_backup[index_backup].img[0,0]);{length}

    resized:=((width2<>old_width2) or ( height2<>old_height2));

    crpix1:=img_backup[index_backup].crpix1;{could be modified by crop}
    crpix2:=img_backup[index_backup].crpix2;

    ra0:=img_backup[index_backup].crval1;
    dec0:=img_backup[index_backup].crval2;

    crota1:=img_backup[index_backup].crota1;{for 90 degrees rotate}
    crota2:=img_backup[index_backup].crota2;
    cdelt1:=img_backup[index_backup].cdelt1;
    cdelt2:=img_backup[index_backup].cdelt2;
    cd1_1:=img_backup[index_backup].cd1_1;
    cd1_2:=img_backup[index_backup].cd1_2;
    cd2_1:=img_backup[index_backup].cd2_1;
    cd2_2:=img_backup[index_backup].cd2_2;


    mainwindow.Memo1.Text:=img_backup[index_backup].header;{restore fits header}

    stackmenu1.test_pattern1.Enabled:=naxis3=1;{allow debayer if mono again}


    img_loaded:=img_backup[index_backup].img; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
    setlength(img_loaded,naxis3,width2,height2);{force a duplication}

    use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
    plot_fits(mainwindow.image1,resized,true);{restore image1}

    stackmenu1.apply_dpp_button1.Enabled:=true;
    update_equalise_background_step(equalise_background_step-1);{update equalize menu}

    if fits_file=false {due to stretch draw} then update_menu(true); {update menu and set fits_file:=true;}

    dec(index_backup,1);{update index}
    if index_backup<0 then index_backup:=size_backup;

    if img_backup[index_backup].img=nil then
    begin
      mainwindow.Undo1.Enabled:=false;
      //memo2_message('No more backups');
    end
    else
    memo2_message('Restored backup index '+inttostr(index_backup));

    Screen.Cursor:=Save_Cursor;
  end;

end;


procedure Tmainwindow.About1Click(Sender: TObject);
var
    about_message, about_message4, about_message5 : string;
const
  {$IfDef Darwin}// {MacOS}
    about_title  : string= 'About ASTAP for OSX:';
  {$ELSE}
     {$IFDEF unix}
        about_title  : string= 'About ASTAP for Linux:';
     {$ELSE}
       about_title  : string= 'About ASTAP for Windows:';
     {$ENDIF}
  {$ENDIF}
begin
  if sizeof(IntPtr) = 8 then
  about_message4:='64 bit'
  else
  about_message4:='32 bit';

 {$IFDEF fpc}
 {$MACRO ON} {required for FPC_fullversion info}
  about_message5:='Build using Free Pascal compiler '+inttoStr(FPC_version)+'.'+inttoStr(FPC_RELEASE)+'.'+inttoStr(FPC_patch)+', Lazarus IDE '+lcl_version;
 {$ELSE} {delphi}
  about_message5:='';
 {$ENDIF}

  about_message:=
  'Astrometric Stacking Program, astrometric solver and FITS image viewer'+
  #13+#10+
  #13+#10+'This program can view, measure, "astrometric solve" and stack deep sky images.'+
  #13+#10+
  #13+#10+'It uses an internal star matching routine, internal astrometric solving routine or a local version of astrometry.net for alignment.'+' For RAW file conversion it uses the external program LibRaw.'+
  #13+#10+
  #13+#10+about_message5+
  #13+#10+
  #13+#10+'Send an e-mail if you like this free program. Feel free to distribute!'+
  #13+#10+
  #13+#10+'© 2018, 2020 by Han Kleijn. License GPL3+, Webpage: www.hnsky.org'+
  #13+#10+
  #13+#10+'ASTAP version ß0.9.427a, '+about_message4+', dated 2020-10-8';

   application.messagebox(
          pchar(about_message), pchar(about_title),MB_OK);
end;


procedure Tmainwindow.FormKeyPress(Sender: TObject; var Key: char);
begin {set form keypreview:=on}
   if key=#27 then
   begin
     esc_pressed:=true;
     memo2_message('ESC pressed. Stopped processing.');

     if copy_paste then
     begin
        shape_paste1.visible:=false;
        copy_paste:=false;
        screen.Cursor := crDefault;
     end;
   end;
end;


procedure Tmainwindow.helponline1Click(Sender: TObject);
begin
   openurl('http://www.hnsky.org/astap.htm');
end;


procedure update_recent_file_menu;{recent file menu update}
begin
  if recent_files.count>=1 then begin mainwindow.recent1.visible:=true;mainwindow.recent1.caption:=recent_files[0];end else mainwindow.recent1.visible:=false;
  if recent_files.count>=2 then begin mainwindow.recent2.visible:=true;mainwindow.recent2.caption:=recent_files[1];end else mainwindow.recent2.visible:=false;
  if recent_files.count>=3 then begin mainwindow.recent3.visible:=true;mainwindow.recent3.caption:=recent_files[2];end else mainwindow.recent3.visible:=false;
  if recent_files.count>=4 then begin mainwindow.recent4.visible:=true;mainwindow.recent4.caption:=recent_files[3];end else mainwindow.recent4.visible:=false;
  if recent_files.count>=5 then begin mainwindow.recent5.visible:=true;mainwindow.recent5.caption:=recent_files[4];end else mainwindow.recent5.visible:=false;
  if recent_files.count>=6 then begin mainwindow.recent6.visible:=true;mainwindow.recent6.caption:=recent_files[5];end else mainwindow.recent6.visible:=false;
  if recent_files.count>=7 then begin mainwindow.recent7.visible:=true;mainwindow.recent7.caption:=recent_files[6];end else mainwindow.recent7.visible:=false;
  if recent_files.count>=8 then begin mainwindow.recent8.visible:=true;mainwindow.recent8.caption:=recent_files[7];end else mainwindow.recent8.visible:=false;
end;


procedure add_recent_file(f: string);{add to recent file list. if existing in list then update recent files list by moving this one up to first position}
var i: integer;
begin
  i:=0;
  while i<=recent_files.count-1 do  {find if already in list}
  begin
    if f=recent_files[i] then
         begin recent_files.delete(i);i:=99; end; {delete entry and add at beginning later. So most recent first}
    inc(i)
  end;
  recent_files.insert(0,f);{latest file at beginning}
  if recent_files.count>8 then recent_files.delete(8);
  update_recent_file_menu;
end;


procedure Tmainwindow.Image1MouseEnter(Sender: TObject);
begin
  mainwindow.caption:=filename2;{restore filename in caption}
  if mouse_enter=0 then mouse_enter:=1;
end;


procedure Tmainwindow.image_cleanup1Click(Sender: TObject);
begin
  plot_fits(mainwindow.image1,false,true);
end;


procedure Tmainwindow.deepsky_overlay1Click(Sender: TObject);
begin
  load_deep;{load the deepsky database once. If loaded no action}
  plot_deepsky;
end;


procedure Tmainwindow.brighten_area1Click(Sender: TObject);
var
   fitsX,fitsY,dum,k,startX2,startY2,stopX2,stopY2,progress_value : integer;
   mode_left_bottom,mode_left_top, mode_right_top, mode_right_bottom,
   line_bottom, line_top,required_bg,{difference,}most_common : double;

   Save_Cursor:TCursor;
begin
  if fits_file=false then exit;
  if  ((abs(stopX-startX)>10)and (abs(stopY-starty)>10)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    startX2:=startX;{save for Application.ProcessMessages;this could change startX, startY}
    startY2:=startY;
    stopX2:=stopX;
    stopY2:=stopY;

    backup_img;

    if startX2>stopX2 then begin dum:=stopX2; stopX2:=startX2; startX2:=dum; end;{swap}
    if startY2>stopY2 then begin dum:=stopY2; stopY2:=startY2; startY2:=dum; end;

    for k:=0 to naxis3-1 do {do all colors}
    begin
      mode_left_bottom:=mode(img_loaded,k,startX2-10,startX2+10,startY2-10,startY2+10,32000);{for this area get most common value equals peak in histogram}
      mode_left_top:=   mode(img_loaded,k,startX2-10,startX2+10,stopY2-10,stopY2+10,32000);{for this area get most common value equals peak in histogram}

      mode_right_bottom:=mode(img_loaded,k,stopX2-10,stopX2+10,startY2-10,startY2+10,32000);{for this area get most common value equals peak in histogram}
      mode_right_top:=   mode(img_loaded,k,stopX2-10,stopX2+10,stopY2-10,stopY2+10,32000);{for this area get most common value equals peak in histogram}


      for fitsY:=startY2 to stopY2-1 do
      begin

        if frac(fitsY/50)=0 then
        begin
          Application.ProcessMessages;{this could change startX, startY}
          if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
          progress_value:=round(100*( k/naxis3 +  0.3333*(fitsY-startY2)/(stopY2-startY2)));
          progress_indicator(progress_value,'');{report progress}
        end;

        for fitsX:=startX2 to stopX2-1 do
        begin
            line_bottom:=mode_left_bottom*(stopX2-fitsx)/(stopX2-startX2)+ mode_right_bottom *(fitsx-startX2)/(stopX2-startX2);{median value at bottom line}
            line_top:=  mode_left_top *   (stopX2-fitsx)/(stopX2-startX2)+ mode_right_top*(fitsx-startX2)/(stopX2-startX2);{median value at top line}
            required_bg:=line_bottom*(stopY2-fitsY)/(stopY2-startY2)+line_top*(fitsY-startY2)/(stopY2-startY2);{median value at position FitsX, fitsY}

            most_common:=mode(img_loaded,k,fitsX,fitsX+5,fitsY,fitsY+5,32000 );
            if most_common<0.99*required_bg then
              img_loaded[k,fitsX,fitsY]:=img_loaded[k,fitsX,fitsY]-(most_common-required_bg)*0.5;
        end;
      end;
    end;{k color}
    plot_fits(mainwindow.image1,false,true);
    progress_indicator(-100,'');{back to normal}
    Screen.Cursor:=Save_Cursor;
  end {fits file}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);

end;


procedure bin_X2X3X4(binfactor:integer);{bin img_loaded 2x or 3x}
  var fitsX,fitsY,k, w,h  : integer;
      img_temp2 : image_array;
      fact      : string;

begin
  binfactor:=min(4,binfactor);{max factor is 4}

  w:=trunc(width2/binfactor);  {half size & cropped. Use trunc for image 1391 pixels wide like M27 test image. Otherwise exception error}
  h:=trunc(height2/binfactor);

  setlength(img_temp2,naxis3,w,h);

  if binfactor=2 then
  begin
    for k:=0 to naxis3-1 do
      for fitsY:=0 to h-1 do
         for fitsX:=0 to w-1  do
         begin
           img_temp2[k,fitsX,fitsY]:=(img_loaded[k,fitsx*2,fitsY*2]+
                                      img_loaded[k,fitsx*2 +1,fitsY*2]+
                                      img_loaded[k,fitsx*2   ,fitsY*2+1]+
                                      img_loaded[k,fitsx*2 +1,fitsY*2+1])/4;
           end;

  end
  else
  if binfactor=3 then
  begin {bin3x3}
    for k:=0 to naxis3-1 do
      for fitsY:=0 to h-1 do
         for fitsX:=0 to w-1  do
         begin
           img_temp2[k,fitsX,fitsY]:=(img_loaded[k,fitsX*3   ,fitsY*3  ]+
                                      img_loaded[k,fitsX*3   ,fitsY*3+1]+
                                      img_loaded[k,fitsX*3   ,fitsY*3+2]+
                                      img_loaded[k,fitsX*3 +1,fitsY*3  ]+
                                      img_loaded[k,fitsX*3 +1,fitsY*3+1]+
                                      img_loaded[k,fitsX*3 +1,fitsY*3+2]+
                                      img_loaded[k,fitsX*3 +2,fitsY*3  ]+
                                      img_loaded[k,fitsX*3 +2,fitsY*3+1]+
                                      img_loaded[k,fitsX*3 +2,fitsY*3+2])/9;
           end;
  end
  else
  begin {bin4x4}
    for k:=0 to naxis3-1 do
      for fitsY:=0 to h-1 do
         for fitsX:=0 to w-1  do
         begin
           img_temp2[k,fitsX,fitsY]:=(img_loaded[k,fitsX*4   ,fitsY*4  ]+
                                      img_loaded[k,fitsX*4   ,fitsY*4+1]+
                                      img_loaded[k,fitsX*4   ,fitsY*4+2]+
                                      img_loaded[k,fitsX*4   ,fitsY*4+3]+
                                      img_loaded[k,fitsX*4 +1,fitsY*4  ]+
                                      img_loaded[k,fitsX*4 +1,fitsY*4+1]+
                                      img_loaded[k,fitsX*4 +1,fitsY*4+2]+
                                      img_loaded[k,fitsX*4 +1,fitsY*4+3]+
                                      img_loaded[k,fitsX*4 +2,fitsY*4  ]+
                                      img_loaded[k,fitsX*4 +2,fitsY*4+1]+
                                      img_loaded[k,fitsX*4 +2,fitsY*4+2]+
                                      img_loaded[k,fitsX*4 +2,fitsY*4+3]+
                                      img_loaded[k,fitsX*4 +3,fitsY*4  ]+
                                      img_loaded[k,fitsX*4 +3,fitsY*4+1]+
                                      img_loaded[k,fitsX*4 +3,fitsY*4+2]+
                                      img_loaded[k,fitsX*4 +3,fitsY*4+3])/16;
           end;
  end;

  img_loaded:=img_temp2;
  width2:=w;
  height2:=h;
  img_temp2:=nil;

  update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);

  if crpix1<>0 then begin crpix1:=crpix1/binfactor; update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,crpix1);end;
  if crpix2<>0 then begin crpix2:=crpix2/binfactor; update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,crpix2);end;

  if cdelt1<>0 then begin cdelt1:=cdelt1*binfactor; update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,cdelt1);end;
  if cdelt2<>0 then begin cdelt2:=cdelt2*binfactor; update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,cdelt2);end;

  if cd1_1<>0 then
  begin
    cd1_1:=cd1_1*binfactor;
    cd1_2:=cd1_2*binfactor;
    cd2_1:=cd2_1*binfactor;
    cd2_2:=cd2_2*binfactor;
    update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_1);
    update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_2);
    update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_1);
    update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_2);
  end;

  update_integer('XBINNING=',' / Binning factor in width                         ' ,round(XBINNING*binfactor));
  update_integer('YBINNING=',' / Binning factor in height                        ' ,round(yBINNING*binfactor));


   if XPIXSZ<>0 then
   begin
     update_float('XPIXSZ  =',' / Pixel width in microns (after binning)          ' ,XPIXSZ*binfactor);{note: comment will be never used since it is an existing keyword}
     update_float('YPIXSZ  =',' / Pixel height in microns (after binning)         ' ,YPIXSZ*binfactor);
   end;

  fact:=inttostr(binfactor);
  fact:=fact+'x'+fact;
  add_text   ('HISTORY   ','BIN'+fact+' version of '+filename2);

end;


function binX2X3_file(binfactor:integer) : boolean; {converts filename2 to binx2 or bin3 version}
begin
  result:=false;
  if load_fits(filename2,true {light},true {load data},img_loaded)=false then exit;

  bin_X2X3X4(binfactor);{bin img_loaded 2x or 3x}

  if binfactor=2 then filename2:=ChangeFileExt(Filename2,'_bin2x2.fit')
                 else filename2:=ChangeFileExt(Filename2,'_bin3x3.fit');
  result:=save_fits(img_loaded,filename2,nrbits,true);{overwrite}
end;


procedure Tmainwindow.bin2x2Click(Sender: TObject);
var
  Save_Cursor:TCursor;
  I, binfactor   : integer;
  dobackup : boolean;
begin
  if sender=bin2x2 then
  begin
    OpenDialog1.Title := 'Select multiple  files to reduce in size (bin2x2)';
    binfactor:=2;
  end
  else
  begin
    OpenDialog1.Title := 'Select multiple  files to reduce in size (bin3x3)';
    binfactor:=3;
  end;
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.FIT*';
  //data_range_groupBox1.Enabled:=true;
  esc_pressed:=false;

  if OpenDialog1.Execute then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }
    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}

    try { Do some lengthy operation }
       with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        filename2:=Strings[I];
        {load fits}
        Application.ProcessMessages;
        if ((esc_pressed) or
            (binX2X3_file(binfactor)=false) {do the binning}) then begin Screen.Cursor := Save_Cursor;  exit;end;
      end;
      finally
      if dobackup then restore_img;{for the viewer}
      Screen.Cursor := Save_Cursor;  { Always restore to normal }
    end;
  end;
end;


procedure Tmainwindow.max2EditingDone(Sender: TObject);
var
  edit_value: integer;
  histo_update : boolean;
begin
  edit_value:=min(max(round(strtofloat2(max2.text)),0),65535);{updown in FPC has a maximum of 32767, so not usable}
  if edit_value<>maximum1.Position then {value has reallly changed}
  begin
    histo_update:=(edit_value>maximum1.max); {histogram update required}

    if histo_update then maximum1.max:=round(edit_value);{update maximum1..max to allow storing the edit value in maximum1.position}

    maximum1.Position:=edit_value;
    mainwindow.range1.itemindex:=7; {manual}

    if histo_update then {redraw histogram with new range}
       use_histogram(img_loaded,false {update}); {plot histogram, set sliders}

    plot_fits(mainwindow.image1,false,true);
  end;
end;


procedure Tmainwindow.Memo1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   mainwindow.caption:='Position '+ inttostr(tmemo(sender).CaretPos.y)+':'+inttostr(tmemo(sender).CaretPos.x);
   statusbar1.SimplePanel:=true;
   statusbar1.Simpletext:=mainwindow.caption;
end;


procedure Tmainwindow.localgaussian1Click(Sender: TObject);
var
   fitsX,fitsY,dum,k : integer;
   Save_Cursor:TCursor;
begin
  if fits_file=false then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img;

    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

    setlength(img_temp,naxis3,stopX-startX,stopY-startY);

    for k:=0 to naxis3-1 do {do all colors}
    begin
      for fitsY:=startY to stopY-1 do
      for fitsX:=startX to stopX-1 do
      begin
        begin
          img_temp[k,fitsX-startX,fitsY-startY]:=img_loaded[k,fitsX,fitsY];{copy the area of interest to img_temp}
        end;
      end;
    end;{k color}
    gaussian_blur2(img_temp,strtofloat2(stackmenu1.blur_factor1.text));

    for k:=0 to naxis3-1 do {do all colors}
    begin
      for fitsY:=startY to stopY-1 do
      for fitsX:=startX to stopX-1 do
      begin
        begin
          img_loaded[k,fitsX,fitsY]:=img_temp[k,fitsX-startX,fitsY-startY];{copy the area of interest back}
        end;
      end;
    end;{k color}

    img_temp:=nil;{clean memory}
    plot_fits(mainwindow.image1,false,true);
    Screen.Cursor:=Save_Cursor;
  end{fits file}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);
end;

procedure Tmainwindow.localcoloursmooth1Click(Sender: TObject);
var
   fitsX,fitsY,dum,k,bsize,x2,y2        : integer;
   noise_left_bottom,noise_left_top, noise_right_top, noise_right_bottom,
   center_x,center_y,a,b,angle_from_center,mean_value,old_value : double;
   line_bottom, line_top,rgb,luminance : double;
   colour,mode_left_bottom,mode_left_top, mode_right_top, mode_right_bottom,noise_level,mean_value2,new_noise  : array[0..2] of double;
   Save_Cursor:TCursor;

   function checkY(y: integer): integer;
   begin
     if y<0 then checkY:=0
     else
     if y>height2-1 then checkY:=height2-1
     else
     checkY:=y;
   end;
   function checkx(X: integer): integer;
   begin
     if x<0 then checkX:=0
     else
     if x>width2-1 then checkX:=width2-1
     else
     checkX:=x;
   end;

begin
  if fits_file=false then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img;

    bsize:=10;  // min(10,abs(stopX-startX));{5 or smaller}

    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

    {ellipse parameters}
    center_x:=(startx+stopX-1)/2;
    center_y:=(startY+stopY-1)/2;
    a:=(stopX-1-startx)/2;
    b:=(stopY-1-startY)/2;

    for k:=0 to naxis3-1 do {do all colors}
    begin

      mode_left_bottom[k]:=mode(img_loaded,k,startx-bsize,startx,starty-bsize,starty,32000);{for this area get most common value equals peak in histogram}
      mode_left_top[k]:=   mode(img_loaded,k,startx-bsize,startx,stopY,stopY+bsize,32000);{for this area get most common value equals peak in histogram}

      mode_right_bottom[k]:=mode(img_loaded,k,stopX,stopX+bsize,starty-bsize,starty,32000);{for this area get most common value equals peak in histogram}
      mode_right_top[k]:=   mode(img_loaded,k,stopX,stopX+bsize,stopY,stopY+bsize,32000);{for this area get most common value equals peak in histogram}

      noise_left_bottom:=  get_negative_noise_level(img_loaded,k,startx-bsize,startx,starty-bsize,starty, mode_left_bottom[k]);{find the negative noise level below most_common_level of a local area}
      noise_left_top:=     get_negative_noise_level(img_loaded,k,startx-bsize,startx,stopY,stopY+bsize, mode_left_top[k]);{find the negative noise level below most_common_level of a local area}
      noise_right_bottom:= get_negative_noise_level(img_loaded,k,stopX,stopX+bsize,starty-bsize,starty, mode_right_bottom[k]);{find the negative noise level below most_common_level of a local area}
      noise_right_top:=    get_negative_noise_level(img_loaded,k,stopX,stopX+bsize,stopY,stopY+bsize, mode_right_top[k]);{find the negative noise level below most_common_level of a local area}
      noise_level[k]:=(noise_left_bottom + noise_left_top + noise_right_top + noise_right_bottom)/4;
    end;{k color}


    colour[0]:=0;
    colour[1]:=0;
    colour[2]:=0;

    for fitsY:=startY to stopY-1 do
      for fitsX:=startX to stopX-1 do
      begin
        angle_from_center:=arctan(abs(fitsy-center_Y)/max(1,abs(fitsX-center_X)));
        if sqr(fitsX-center_X)+sqr(fitsY-center_Y)  <= sqr(a*cos(angle_from_center))+ sqr(b*sin(angle_from_center)) then     {within the ellipse}
        for k:=0 to naxis3-1 do {do all colors}
        begin
          begin
            line_bottom:=mode_left_bottom[k]*(stopX-fitsx)/(stopX-startx)+ mode_right_bottom[k] *(fitsx-startX)/(stopX-startx);{median value at bottom line}
            line_top:=  mode_left_top[k] *   (stopX-fitsx)/(stopX-startx)+ mode_right_top[k]*(fitsx-startX)/(stopX-startx);{median value at top line}
            mean_value:=line_bottom*(stopY-fitsY)/(stopY-startY)+line_top*(fitsY-startY)/(stopY-startY);{median value at position FitsX, fitsY}
            old_value:=img_loaded[k,fitsX,fitsY];
            if old_value-3*noise_level[k]>mean_value  then
              colour[k]:=colour[k]+old_value-mean_value;{adapt only if pixel value is 3*noise level different}
          end;
        end;{k color}
      end;
    rgb:=colour[0]+colour[1]+colour[2]+0.00001; {0.00001, prevent dividing by zero}

    {smooth all pixel to same colour}
    x2:=0;
    y2:=0;
    for fitsY:=startY to stopY-1 do
      for fitsX:=startX to stopX-1 do
      begin
        angle_from_center:=arctan(abs(fitsy-center_Y)/max(1,abs(fitsX-center_X)));
        if sqr(fitsX-center_X)+sqr(fitsY-center_Y)  <= sqr(a*cos(angle_from_center))+ sqr(b*sin(angle_from_center)) then     {within the ellipse}
        begin
          for k:=0 to naxis3-1 do {do all colors}
          begin
            line_bottom:=mode_left_bottom[k]*(stopX-fitsx)/(stopX-startx)+ mode_right_bottom[k] *(fitsx-startX)/(stopX-startx);{median value at bottom line}
            line_top:=  mode_left_top[k] *   (stopX-fitsx)/(stopX-startx)+ mode_right_top[k]*(fitsx-startX)/(stopX-startx);{median value at top line}
            mean_value2[k]:=line_bottom*(stopY-fitsY)/(stopY-startY)+line_top*(fitsY-startY)/(stopY-startY);{median value at position FitsX, fitsY}
          end;

          luminance:=( img_loaded[0,fitsX,fitsY]-mean_value2[0]
                        +img_loaded[1,fitsX,fitsY]-mean_value2[1]
                        +img_loaded[2,fitsX,fitsY]-mean_value2[2])/3;

          {walk the top and bottom boundary for noise}
          inc(x2); if x2>=stopX-startX then begin x2:=0;inc(y2);end;
          if y2>15 then y2:=0;

          for k:=0 to 2 do
          begin
            new_noise[k]:=img_loaded[k,checkX(startX+x2),checkY(startY-y2)]-mean_value2[k]; {background noise from bottom boundary}
            if new_noise[k]>3*noise_level[k] then {star in field}
            new_noise[k]:=img_loaded[k,checkX(startX+x2),checkY(stopY+y2)]-mean_value2[k]; {background noise from top boundary}
            if new_noise[k]>3*noise_level[k] then {star in field}
            new_noise[k]:=img_loaded[k,checkX(startX+x2),checkY(startY-y2-10)]-mean_value2[k]; {background noise from bottom boundary-10}
            if new_noise[k]>3*noise_level[k] then {star in field}
            new_noise[k]:=img_loaded[k,checkX(startX+x2),checkY(stopY+y2+10)]-mean_value2[k]; {background noise from top boundary+10}
          end;

          {apply average colour to pixel}
          img_loaded[0,fitsX,fitsY]:=new_noise[0]{background noise}+ mean_value2[0]+luminance*colour[0]/rgb;
          img_loaded[1,fitsX,fitsY]:=new_noise[1]{background noise}+ mean_value2[1]+luminance*colour[1]/rgb;
          img_loaded[2,fitsX,fitsY]:=new_noise[2]{background noise}+ mean_value2[2]+luminance*colour[2]/rgb;
        end;
      end;

    plot_fits(mainwindow.image1,false,true);
    Screen.Cursor:=Save_Cursor;
  end {fits file}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);

end;

function test_star_spectrum(r,g,b: single) : single;{test star spectrum. Result of zero is perfect star spectrum}
var RdivG :single;                                  {excel polynom fit based on data from http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html}
begin                                               {range 2000 till 20000k}
  if ((b<($12/$FF)*r) or (b>($FF/$AD)*r)) then {too red or too blue}
  begin
    result:=1;
    exit;
  end;
  if ((r<=1) or (g<=1) or (b<=1)) then
  begin
    result:=0;
    exit;
  end;
  RdivG:=r/g;
  result:=abs((b/g)-(0.6427*sqr(RdivG)-2.868*RdivG+3.3035));
end;

procedure Tmainwindow.hyperleda_annotation1Click(Sender: TObject);
var
  Save_Cursor:TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass; { Show hourglass cursor }
  backup_img;
  load_hyperleda;   { Load the database once. If loaded no action}
  plot_deepsky;{plot the deep sky object on the image}
  Screen.Cursor:=Save_Cursor;
end;

function extract_objectname_from_filename(filename8: string): string; {try to extract exposure from filename}
var
  i   : integer;
begin
  {try to reconstruct object name from filename}
  result:='';
  filename8:=uppercase(extractfilename(filename8));
  i:=pos('NGC',filename8); if i>0 then begin result:='NGC'; i:=i+3; end;
  if i=0 then begin i:=pos('IC',filename8); if i>0 then begin result:='IC'; i:=i+2; end; end;
  if i=0 then begin i:=pos('SH2-',filename8); if i>0 then begin result:='SH2-'; i:=i+4; end; end;
  if i=0 then begin i:=pos('PGC',filename8); if i>0 then begin result:='PGC'; i:=i+3; end; end;
  if i=0 then begin i:=pos('UGC',filename8); if i>0 then begin result:='UGC'; i:=i+3; end; end;
  if i=0 then begin i:=pos('M',filename8); if i>0 then begin result:='M'; i:=i+1; end; end;

  if i>0 then
  begin
    if filename8[i]=' ' then inc(i);{skip first space}
    while filename8[i] in ['0','1','2','3','4','5','6','7','8','9']  do
    begin
      if filename8[i]<>' ' then result:=result+filename8[i];
      inc(i);
    end
  end;
end;
procedure search_database;
var
   ra0,dec0,length0,width0,pa : double;
   objname : string;
begin
  with mainwindow do
  begin
    objname:=uppercase(inputbox('Retrieve position from deepsky database','Object name:' , extract_objectname_from_filename(filename2) ));
    load_deep;{Load the deepsky database once. If loaded, no action}
    if length(objname)>1 then {Object name length should be two or longer}
    begin
      linepos:=2;{Set pointer to the beginning. First two lines are comments}
      repeat
        read_deepsky('T' {full search},0 {ra},0 {dec},1 {cos(telescope_dec},2*pi{fov},{var} ra0,dec0,length0,width0,pa);{deepsky database search}
        if ((objname=uppercase(naam2)) or (objname=uppercase(naam3)) or (objname=uppercase(naam4))) then  {uppercase required for e.g. Sh2-105}
        begin
          ra1.text:=prepare_ra(ra0,' ');{Add object position}
          dec1.text:=prepare_dec(dec0,' ');
          linepos:=$FFFFFF; {Stop}
       end;
      until linepos>=$FFFFFF;{Found object or end of database}
    end;
  end;{with mainwindow}
end;



procedure Tmainwindow.ra1DblClick(Sender: TObject); {retrieve object position from database}
begin
//  {$IfDef Darwin}// for OS X,
//    exit; {double click is also triggered by single click.} //SEE https://bugs.freepascal.org/view.php?id=36621
//  {$ENDIF}
  search_database;
end;

procedure Tmainwindow.clean_up1Click(Sender: TObject);
begin
  plot_fits(mainwindow.image1,false,true);
  if ((annotated) and (annotations_visible1.checked)) then plot_annotations(0,0,false);
end;

procedure Tmainwindow.remove_colour1Click(Sender: TObject);{make local area monochrome}
var
   fitsX,fitsY,dum    : integer;
   val  : single;
   Save_Cursor:TCursor;
begin
  if ((naxis3<>3) or (fits_file=false)) then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img;


    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;


    for fitsY:=startY to stopY-1 do
    for fitsX:=startX to stopX-1 do
    begin
       val:=(img_loaded[0,fitsX,fitsY]+img_loaded[1,fitsX,fitsY]+img_loaded[2,fitsX,fitsY])/3;
       img_loaded[0,fitsX,fitsY]:=val;
       img_loaded[1,fitsX,fitsY]:=val;
       img_loaded[2,fitsX,fitsY]:=val;
    end;
    plot_fits(mainwindow.image1,false,true);
    Screen.Cursor:=Save_Cursor;
  end{fits file}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);
end;

procedure Tmainwindow.Returntodefaultsettings1Click(Sender: TObject);
begin
  if (IDYES= Application.MessageBox('This will set all ASTAP settings to default and close the program. Are you sure?', 'Default settings?', MB_ICONQUESTION + MB_YESNO) ) then
  begin
    if deletefile(user_path+'astap.cfg') then
    begin
      halt(0); {don't save only do mainwindow.destroy. Note  mainwindow.close will save the setting again, so don't use}
    end
    else beep;
  end;
end;

procedure plot_north;{draw arrow north. If cd1_1=0 then clear north arrow}
const xpos=25;{position arrow}
      ypos=25;
      leng=24;{half of length}

var
      dra,ddec,
      cdelt1_a, det,x,y :double;
      flipV, flipH : integer;
begin
  {clear}
  mainwindow.image_north_arrow1.canvas.brush.color:=clmenu;
  mainwindow.image_north_arrow1.canvas.rectangle(-1,-1, mainwindow.image_north_arrow1.width+1, mainwindow.image_north_arrow1.height+1);

  if cd1_1=0 then {remove rotation indication and exit}
  begin
     mainwindow.rotation1.caption:='';
     exit;
  end;

  mainwindow.rotation1.caption:=floattostrf(crota2, FFfixed, 0, 2)+'°';{show rotation}

  if ((fits_file=false) or (cd1_1=0)) then exit;

  mainwindow.image_north_arrow1.Canvas.Pen.Color := clred;

  if mainwindow.flip_horizontal1.checked then flipH:=-1 else flipH:=+1;
  if mainwindow.flip_vertical1.checked then flipV:=-1 else flipV:=+1;

  cdelt1_a:=sqrt(CD1_1*CD1_1+CD1_2*CD1_2);{length of one pixel step to the north}

  moveToex(mainwindow.image_north_arrow1.Canvas.handle,round(xpos),round(ypos),nil);
  det:=CD2_2*CD1_1-CD1_2*CD2_1;{this result can be negative !!}
  dRa:=0;
  dDec:=cdelt1_a*leng;
  x := (CD1_2*dDEC - CD2_2*dRA) / det;
  y := (CD1_1*dDEC - CD2_1*dRA) / det;
  lineTo(mainwindow.image_north_arrow1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow line}
  dRa:=cdelt1_a*-3;
  dDec:=cdelt1_a*(leng-5);
  x := (CD1_2*dDEC - CD2_2*dRA) / det;
  y := (CD1_1*dDEC - CD2_1*dRA) / det;
  lineTo(mainwindow.image_north_arrow1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}
  dRa:=cdelt1_a*+3;
  dDec:=cdelt1_a*(leng-5);
  x := (CD1_2*dDEC - CD2_2*dRA) / det;
  y := (CD1_1*dDEC - CD2_1*dRA) / det;
  lineTo(mainwindow.image_north_arrow1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}
  dRa:=0;
  dDec:=cdelt1_a*leng;
  x := (CD1_2*dDEC - CD2_2*dRA) / det;
  y := (CD1_1*dDEC - CD2_1*dRA) / det;
  lineTo(mainwindow.image_north_arrow1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}


  moveToex(mainwindow.image_north_arrow1.Canvas.handle,round(xpos),round(ypos),nil);{east pointer}
  dRa:= cdelt1_a*leng/3;
  dDec:=0;
  x := (CD1_2*dDEC - CD2_2*dRA) / det;
  y := (CD1_1*dDEC - CD2_1*dRA) / det;
  lineTo(mainwindow.image_north_arrow1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {east pointer}
end;

procedure Tmainwindow.rotateleft1Click(Sender: TObject); {rotate left or right 90 degrees}
var
  dum, col,fitsX,fitsY : integer;
  dummy                : double;
  right :boolean;
  Save_Cursor:TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  if ((sender=batch_rotate_right1) or (sender=batch_rotate_left1))=false then
    backup_img;

  right:= ((sender=rotateright1) or (sender=batch_rotate_right1)); {rotate right?}

  if flip_horizontal1.checked then right:= (right=false);{change rotation if flipped}
  if flip_vertical1.checked then   right:= (right=false);{change rotation if flipped}

  setlength(img_temp,naxis3, height2,width2);{set length of image with swapped width and height}

  for col:=0 to naxis3-1 do {do all colours}
  begin
    For fitsY:=0 to (height2-1) do
      for fitsX:=0 to (width2-1) do
      begin
        if right=false then img_temp[col,(height2-1)-fitsY,fitsX]:=img_loaded[col,fitsX,fitsY]
                       else img_temp[col, fitsY,(width2-1)-fitsX]:=img_loaded[col,fitsX,fitsY];
      end;
  end;
  {swap width and height}
  dum:=width2;
  width2:=height2;
  height2:=dum;
  update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);


  img_loaded:=img_temp;
  img_temp:=nil;
  plot_fits(mainwindow.image1,false,true);

  if cd1_1<>0 then {update solution for rotation}
  begin
    if right then {rotate right}
    begin
      dummy:=cd1_1; cd1_1:=cd1_2; cd1_2:=-dummy;
      dummy:=cd2_1; cd2_1:=cd2_2; cd2_2:=-dummy;

      dummy:=crpix1; crpix1:=crpix2; crpix2:=height2-dummy;
    end
    else
    begin {rotate left}
      dummy:=cd1_1; cd1_1:=-cd1_2; cd1_2:=dummy;
      dummy:=cd2_1; cd2_1:=-cd2_2; cd2_2:=dummy;

      dummy:=crpix1; crpix1:=width2-crpix2; crpix2:=dummy;
    end;
    new_to_old_WCS;{convert new style FITS to old style, calculate crota1,crota2,cdelt1,cdelt2}

    update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_1);
    update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_2);
    update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_1);
    update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_2);


    update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,crpix1);
    update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,crpix2);

    update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,cdelt1);
    update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,cdelt2);

    update_float  ('CROTA1  =',' / Image twist of X axis        (deg)             ' ,crota1);
    update_float  ('CROTA2  =',' / Image twist of Y axis        (deg)             ' ,crota2);

    remove_key('ROWORDER',false{all});{just remove to prevent debayer confusion}
    add_text   ('HISTORY   ','Rotated 90 degrees.');
    plot_north;
  end;
  Screen.Cursor := Save_Cursor;  { Always restore to normal }
end;

procedure Tmainwindow.saturation_factor_plot1KeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  plot_fits(mainwindow.image1,false,true);{plot real}
end;

procedure Tmainwindow.saturation_factor_plot1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    plot_fits(mainwindow.image1,false,true);{plot real}
end;



procedure Tmainwindow.savesettings1Click(Sender: TObject);
begin
  savedialog1.filename:=user_path+'astap.cfg';
  savedialog1.Filter := '(configuration file|*.cfg';
  if savedialog1.execute then
    save_settings(savedialog1.filename);
end;



procedure Tmainwindow.show_distortion1Click(Sender: TObject);
begin
 plot_stars(false,true {show Distortion});
end;

procedure Tmainwindow.Polynomial1Change(Sender: TObject);
begin
 if  (
     ((mainwindow.polynomial1.itemindex=1) and (A_ORDER=0) ) or {SIP polynomial selected but no data}
     ((mainwindow.polynomial1.itemindex=2) and (x_coeff[0]=0) and (y_coeff[0]=0)) {DSS polynomial selected but no data}
     ) then
   mainwindow.Polynomial1.color:=clred
   else
   mainwindow.Polynomial1.color:=cldefault;
end;

procedure Tmainwindow.remove_markers1Click(Sender: TObject);
begin
  plot_fits(mainwindow.image1,false,true);
  if ((annotated) and (annotations_visible1.checked)) then plot_annotations(0,0,false);
end;

procedure show_marker_shape(shape: TShape;shape_type,w,h,minimum:integer; fitsX,fitsY: double);{show manual alignment shape}
var
   xf,yf,x,y : double;
begin
  xF:=(fitsX-0.5)*(mainwindow.image1.width/width2)-0.5; //inverse of  fitsx:=0.5+(0.5+xf)/(image1.width/width2);{starts at 1}
  yF:=-(fitsY-height2-0.5)*(mainwindow.image1.height/height2)-0.5; //inverse of fitsy:=0.5+height2-(0.5+yf)/(image1.height/height2); {from bottom to top, starts at 1}

  if mainwindow.Flip_horizontal1.Checked then x:=mainwindow.image1.width-xF else x:=xF;
  if mainwindow.flip_vertical1.Checked then y:=mainwindow.image1.height-yF else y:=yF;

  if w=0 then {auto size}
  begin
  end;

  with shape do
  begin
     height:=max(minimum,round(h*mainwindow.image1.height/height2));
     width:= max(minimum,round(w*mainwindow.image1.width/width2));
     left:=round(mainwindow.image1.left + x - width/2);
     top:=round(mainwindow.image1.top   + y - height/2);

     if shape_type=0 then {rectangle}
     begin
       shape:=stRectangle;
       hint:='no lock';
     end
     else
     if shape_type=1 then {circle}
     begin {good lock on object}
       shape:=stcircle;
       hint:='locked';
     end;
     {else keep as it is}

     visible:=true;
  end;
end;

procedure zoom(mousewheelfactor:double);
var
  image_left,image_top : double;
  maxw  : double;
begin
  {$ifdef mswindows}
   maxw:=65535; {will be 1.2*65535}
  {$else}
  {$ifdef CPUARM}
   maxw:=4000;{struggeling if above}
  {$else}
   maxw:=15000;
  {$endif}
 ; {$endif}

  if ( ((mainwindow.image1.width<=maxw) or (mousewheelfactor<1){zoom out}) and {increased to 65535 for Windows only. Was above 12000 unequal stretch}
       ((mainwindow.image1.width>=100 ) or (mousewheelfactor>1){zoom in})                                                                  )

  then
  begin
    image_left:=mainwindow.image1.left; {preserve for shape position calculation}
    image_top:=mainwindow.image1.top;


    mainwindow.image1.height:=round(mainwindow.image1.height * mousewheelfactor);
    mainwindow.image1.width:= round(mainwindow.image1.width * mousewheelfactor);

    //mainwindow.caption:=inttostr(mainwindow.image1.width)+' x '+inttostr(mainwindow.image1.height);


    {scroll to compensate zoom}
    mainwindow.image1.left:=+round(mainwindow.panel1.clientwidth/2  +  (image_left - mainwindow.panel1.clientwidth/2)*mousewheelfactor);
    mainwindow.image1.top:= +round(mainwindow.panel1.clientheight/2 +  (image_top - mainwindow.panel1.clientheight/2)*mousewheelfactor);

    {marker}
    if mainwindow.shape_marker1.visible then {do this only when visible}
      show_marker_shape(mainwindow.shape_marker1,2 {no change in shape and hint},20,20,10{minimum},shape_marker1_fitsX, shape_marker1_fitsY);
    if mainwindow.shape_marker2.visible then {do this only when visible}
      show_marker_shape(mainwindow.shape_marker2,2 {no change in shape and hint},20,20,10{minimum},shape_marker2_fitsX, shape_marker2_fitsY);
    if mainwindow.shape_marker3.visible then {do this only when visible}
      show_marker_shape(mainwindow.shape_marker3,2 {no change in shape and hint},20,20,10{minimum},shape_marker3_fitsX, shape_marker3_fitsY);

     if copy_paste then show_marker_shape(mainwindow.shape_paste1,0 {rectangle},copy_paste_w,copy_paste_h,0{minimum}, mouse_fitsx, mouse_fitsy);{show the paste shape}


    {reference point manual alignment}
    if mainwindow.shape_alignment_marker1.visible then {For manual alignment. Do this only when visible}
//      show_shape(true,shape_fitsX, shape_fitsY);
     show_marker_shape(mainwindow.shape_alignment_marker1,2 {no change in shape and hint},20,20,10,shape_fitsX, shape_fitsY);
  end;

// mainwindow.image1.height:=mainwindow.image1.picture.height*3 ;
//  mainwindow.image1.width:=mainwindow.image1.picture.width*3;


end;

procedure Tmainwindow.zoomin1Click(Sender: TObject);
begin
 zoom(1.2);
end;
procedure Tmainwindow.zoomout1Click(Sender: TObject);
begin
  zoom(1/1.2);
end;

procedure Tmainwindow.Panel1MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  P: TPoint;
begin
  GetCursorPos(p);  {use this since in Lazarus the mousepos varies depending control under the mouse}
  p:=panel1.Screentoclient(p);

//  mainwindow.statusbar1.simpletext:=inttostr(p.x)+'   ' +inttostr(p.Y)+'   '+inttostr(mousepos.x)+'   '+inttostr(mousepos.y);

  if p.y<0 then exit; {not in image range}

  if mainwindow.inversemousewheel1.checked then  zoom(1.2) else zoom(1/1.2);
  Handled := True;{prevent that in win7 the combobox is moving up/down if it has focus}

//  error_label1.visible:=false;

end;

procedure Tmainwindow.Panel1MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  P: TPoint;
begin
//  P:=Panel1.Screentoclient(mousepos);
  GetCursorPos(p);  {use this since in Lazarus the mousepos varies depending control under the mouse}
  p:=panel1.Screentoclient(p);
  if p.y<0 then exit; {not in image range}

  if mainwindow.inversemousewheel1.checked then  zoom(1/1.2) else zoom(1.2);
  Handled := True;{prevent that in win7 the combobox is moving up/down if it has focus}

//  error_label1.visible:=false;

end;

procedure Tmainwindow.show_statistics1Click(Sender: TObject);
var
   fitsX,fitsY,dum,counter,col,size,counter_median,required_size, iterations : integer;
   value,stepsize,median_position, most_common,mc_1,mc_2,mc_3,mc_4,
   sd,sd_old,mean,meanx,median,minimum, maximum,max_counter, saturated : double;
   Save_Cursor              : TCursor;
   info_message             : string;
   median_array             : array of double;
const
  median_max_size=5000;

begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  if ((abs(stopX-startX)>2)and (abs(stopY-starty)>2))=false then {do statistics on whole image}
  begin
    startx:=0;stopX:=width2-1;
    starty:=0;stopY:=height2-1;
  end;

  if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
  if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

  {reset variables}
  info_message:='';

  {limit points to take median from at median_max_size}
  size:=(stopY-1-startY) * (stopX-1-startX);{number of pixels within the rectangle}
  stepsize:=median_max_size/size;
  if stepsize<1 then required_size:=median_max_size {pixels will be skippped. Limit sampling to median_max_size}
                else required_size:=size;
  setlength(median_array,required_size);

  {measure the median of the suroundings}

  for col:=0 to naxis3-1 do  {do all colours}
  begin
    local_sd(startX+1 ,startY+1, stopX-1,stopY-1{within rectangle},col,img_loaded, {var} sd,mean);{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}

    {median sampling and min , max}
    max_counter:=1;
    median:=0;
    saturated:=0;
    minimum:=999999999;
    maximum:=0;
    counter:=0;
    counter_median:=0;
    for fitsY:=startY+1 to stopY-1 do {within rectangle}
    for fitsX:=startX+1 to stopX-1 do
    begin
      value:=img_loaded[col,fitsX+1,fitsY+1];
      median_position:=counter*stepsize;
      if  trunc(median_position)>counter_median then {pixels will be skippped. Limit sampling to median_max_size}
      begin
        inc(counter_median);
        median_array[counter_median]:=value; {fill array with sampling data. Smedian will be applied later}
      end;
      inc(counter);
      if value=maximum then max_counter:=max_counter+1; {counter at max}
      if value>maximum then maximum:=value; {max}
      if value<minimum then minimum:=value; {min}
      if value>=64000 then saturated:=saturated+1;{saturation counter}
    end;{filter outliers}
    median:=smedian(median_array);


    most_common:=mode(img_loaded,col,startx,stopX,starty,stopY,32000);

    if naxis3>1 then if col=0 then info_message:=info_message+'Red:'+#10;
    if col=1 then info_message:=info_message+#10+#10+'Green:'+#10;
    if col=2 then info_message:=info_message+#10+#10+'Blue:'+#10;

    info_message:=info_message+  'x̄ :    '+floattostrf(mean,ffgeneral, 5, 5)+#10+             {mean}
                                 'x̃  :   '+floattostrf(median,ffgeneral, 5, 5)+#10+ {median}
                                 'Mo :  '+floattostrf(most_common,ffgeneral, 5, 5)+#10+
                                 'σ :   '+floattostrf(sd,ffgeneral, 4, 4)+'   (sigma-clip iterations='+inttostr(iterations)+')'+#10+               {standard deviation}
                                 'σ_2:   '+floattostrf(get_negative_noise_level(img_loaded,col,startx,stopX,starty,stopY,most_common),ffgeneral, 4, 4)+#10+
                                 'm :   '+floattostrf(minimum,ffgeneral, 5, 5)+#10+
                                 'M :   '+floattostrf(maximum,ffgeneral, 5, 5)+ '  ('+inttostr(round(max_counter))+' x)'+#10+
                                 '≥64E3 :  '+inttostr(round(saturated));
  end;
  if ((abs(stopX-startx)>=width2-1) and (most_common<>0){prevent division by zero}) then
  begin
    mc_1:=mode(img_loaded,0,          0{x1},      50{x2},           0{y1},       50{y2},32000);{for this area get most common value equals peak in histogram}
    mc_2:=mode(img_loaded,0,          0{x1},      50{x2},height2-1-50{y1},height2-1{y2},32000);
    mc_3:=mode(img_loaded,0,width2-1-50{x1},width2-1{x2},height2-1-50{y1},height2-1{y2},32000);
    mc_4:=mode(img_loaded,0,width2-1-50{x1},width2-1{x2},           0{y1},50       {y2},32000);

    info_message:=info_message+#10+#10+'Vignetting [Mo corners/Mo]: '+inttostr(round(100*(1-(mc_1+mc_2+mc_3+mc_4)/(most_common*4))))+'%';
  end;

  info_message:=info_message+#10+#10+#10+'Legend: '+#10+
                                            'x̄ = mean background | x̃  = median background | '+
                                            'Mo = mode or most common pixel value or peak histogram, so the best estimate for the background mean value | '+
                                            'σ =  standard deviation background using mean and sigma clipping| ' +
                                            'σ_2 = standard deviation background using values below Mo only | '+
                                            'm = minimum value image | M = maximum value image | ≥64E3 = number of values equal or above 64000';

  case  QuestionDlg (pchar('Statistics within rectangle '+inttostr(stopX-1-startX)+' x '+inttostr(stopY-1-startY) ),pchar(info_message),mtCustom,[mrYes,'Copy to clipboard?', mrNo, 'No', 'IsDefault'],'') of
           mrYes: Clipboard.AsText:=info_message;
  end;


  median_array:=nil;{free mem}

  Screen.Cursor:=Save_Cursor;
end;



function place_marker_radec(str1: string): boolean;{place ra,dec marker in image}
var
  dec_new,SIN_dec_new,COS_dec_new,ra_new,
  SIN_dec_ref,COS_dec_ref,det, delta_ra,SIN_delta_ra,COS_delta_ra, H, dRa,dDec,fitsx,fitsy : double;
  kommapos:integer;
  error1,error2  : boolean;

begin
  if cd1_1=0 then exit;{no solution to place marker}

  kommapos:=pos(',',str1);
  ra_text_to_radians (copy(str1,1  ,kommapos-1) ,ra_new,error1); {convert ra text to ra0 in radians}
  dec_text_to_radians(copy(str1,kommapos+1,99) ,dec_new,error2); {convert dec text to dec0 in radians}

  if ((error1=false) and (error2=false)) then
  begin
    result:=true;

   {5. Conversion (RA,DEC) -> (x,y) of reference image}
    sincos(dec_new,SIN_dec_new,COS_dec_new);{sincos is faster then seperate sin and cos functions}
    sincos(dec0,SIN_dec_ref,COS_dec_ref);{}

    delta_ra:=ra_new-ra0;
    sincos(delta_ra,SIN_delta_ra,COS_delta_ra);

    H := SIN_dec_new*sin_dec_ref + COS_dec_new*COS_dec_ref*COS_delta_ra;
    dRA := (COS_dec_new*SIN_delta_ra / H)*180/pi;
    dDEC:= ((SIN_dec_new*COS_dec_ref - COS_dec_new*SIN_dec_ref*COS_delta_ra ) / H)*180/pi;

    det:=CD2_2*CD1_1 - CD1_2*CD2_1;

    fitsX:=+CRPIX1  - (CD1_2*dDEC - CD2_2*dRA) / det;
    fitsY:=+CRPIX2  + (CD1_1*dDEC - CD2_1*dRA) / det;

    shape_marker3_fitsX:=fitsX;
    shape_marker3_fitsY:=fitsY;
    show_marker_shape(mainwindow.shape_marker3,0 {rectangle},20,20,10,shape_marker3_fitsX, shape_marker3_fitsY);

  end
  else
  begin
    mainwindow.shape_marker3.visible:=false;
    result:=false;
    beep;
    exit;
  end;
end;


procedure update_statusbar_section5;{update section 5 with image dimensions in degrees}
begin
  if cdelt2<>0 then
  begin
    mainwindow.statusbar1.panels[6].text:=floattostrF2(width2*abs(cdelt2),0,2)+' x '+floattostrF2(height2*cdelt2,0,2)+' °';{give image dimensions and bit per pixel info}
    stackmenu1.search_fov1.text:=floattostrF2(height2*abs(cdelt2),0,2); {negative cdelt2 are produced by PI}
  end
  else mainwindow.statusbar1.panels[6].text:='';
end;

function fits_file_name(inp : string): boolean; {fits file name?}
begin
  inp:=uppercase(extractfileext(inp));
  result:=((inp='.FIT') or (inp='.FITS') or (inp='.FTS'));
end;


function check_raw_file_extension(ext: string): boolean;{check if extension is from raw file}
begin
  result:=((ext='.RAW') or (ext='.CRW') or (ext='.CR2') or (ext='.CR3')or (ext='.KDC') or (ext='.DCR') or (ext='.MRW') or (ext='.ARW') or (ext='.NEF') or (ext='.NRW') or (ext='.DNG') or (ext='.ORF') or (ext='.PTX') or (ext='.PEF') or (ext='.RW2') or (ext='.SRW') or (ext='.RAF') or (ext='.KDC')); {raw format extension?}
end;


function image_file_name(inp : string): boolean; {readable image name?}
begin
  inp:=uppercase(extractfileext(inp));
  result:=( (inp='.FIT') or (inp='.FITS') or (inp='.FTS') or (inp='.JPG') or (inp='.JPEG') or (inp='.TIF') or (inp='.PNG') );
  if result=false then result:=check_raw_file_extension(inp);
end;

procedure update_menu_related_to_solver(yes :boolean); {update menu section related to solver succesfull}
begin
  if mainwindow.show_distortion1.enabled=yes then exit;{no need to update}

  mainwindow.show_distortion1.enabled:=yes;{enable menu}
  mainwindow.annotate_with_measured_magnitudes1.enabled:=yes;{enable menu}
  mainwindow.variable_star_annotation1.enabled:=yes;{enable menu}
  mainwindow.annotate_minor_planets1.enabled:=yes;{enable menu}
  mainwindow.hyperleda_annotation1.enabled:=yes;{enable menu}
  mainwindow.deepsky_annotation1.enabled:=yes;{enable menu}
  mainwindow.star_annotation1.enabled:=yes;{enable menu}
  mainwindow.hyperleda_annotation1.enabled:=yes;{enable menu}
  mainwindow.deepsky_annotation1.enabled:=yes;{enable menu}
  mainwindow.calibrate_photometry1.enabled:=yes;{enable menu}
  mainwindow.add_marker_position1.enabled:=yes;{enable popup menu}
  mainwindow.measuretotalmagnitude1.enabled:=yes;{enable popup menu}
  mainwindow.writeposition1.enabled:=yes;{enable popup menu}
  mainwindow.Copyposition1.enabled:=yes;{enable popup menu}
  mainwindow.Copypositioninhrs1.enabled:=yes;{enable popup menu}
  mainwindow.Copypositioninradians1.enabled:=yes;{enable popup menu}

  stackmenu1.focallength1Exit(nil); {update output calculator}
end;

procedure update_menu(fits :boolean);{update menu if fits file is available in array or working from image1 canvas}
begin
  mainwindow.Saveasfits1.enabled:=((fits) or (extend>=2){table});

  if fits<>mainwindow.data_range_groupBox1.Enabled then  {menu requires update}
  begin
    mainwindow.data_range_groupBox1.Enabled:=fits;
    mainwindow.Export_image1.enabled:=fits;
    mainwindow.SaveasJPGPNGBMP1.Enabled:=fits;

    mainwindow.ShowFITSheader1.enabled:=fits;
    mainwindow.demosaic_Bayermatrix1.Enabled:=fits;
    mainwindow.autocorrectcolours1.Enabled:=fits;
    mainwindow.stretch_draw1.Enabled:=fits;
    mainwindow.stretch_draw_fits1.Enabled:=fits;

    mainwindow.CropFITSimage1.Enabled:=fits;

    mainwindow.stretch1.enabled:=fits;
    mainwindow.rotateleft1.enabled:=fits;
    mainwindow.rotateright1.enabled:=fits;
    mainwindow.inversimage1.enabled:=fits;
    mainwindow.imageflipH1.enabled:=fits;
    mainwindow.imageflipV1.enabled:=fits;
    mainwindow.rotate_arbitrary1.enabled:=fits;

    mainwindow.minimum1.enabled:=fits;
    mainwindow.maximum1.enabled:=fits;
    mainwindow.range1.enabled:=fits;
    mainwindow.min2.enabled:=fits;
    mainwindow.max2.enabled:=fits;

    mainwindow.ccdinspector1.enabled:=fits;
    mainwindow.ccd_inspector_plot1.enabled:=fits;
    mainwindow.convertmono1.enabled:=fits;

    mainwindow.solve_button1.enabled:=fits;
    mainwindow.astrometric_solve_image1.enabled:=fits;

    stackmenu1.tab_Pixelmath1.enabled:=fits;
    stackmenu1.tab_Pixelmath2.enabled:=fits;

  end;{menu change}

  fits_file:=fits;{update}
  mainwindow.error_label1.visible:=(fits=false);

  mainwindow.SaveFITSwithupdatedheader1.Enabled:=((fits) and (fits_file_name(filename2)) and (fileexists(filename2)));{menu disable, no file available to update header}
  mainwindow.saturation_factor_plot1.enabled:=naxis3=3;{colour};
  mainwindow.Polynomial1Change(nil);{update color}
  update_menu_related_to_solver((fits) and (cd1_1<>0));
  stackmenu1.resize_factor1Change(nil);{update dimensions binning menu}
  stackmenu1.test_pattern1.Enabled:=naxis3=1;{mono}

  stackmenu1.focallength1.Text:=floattostrf(focallen,ffgeneral, 4, 4);
  stackmenu1.pixelsize1.text:=floattostrf(xpixsz*XBINNING,ffgeneral, 4, 4);
  stackmenu1.focallength1Exit(nil); {update calculator}
end;


procedure Tmainwindow.astrometric_solve_image1Click(Sender: TObject);
var
   OldCursor : TCursor;
begin
  if live_stacking {ongoing}  then
  begin
    stackmenu1.Memo2.lines.add('█ █ █ █ █ █  Can'+#39+'t solve while live stacking!!');
    exit;
  end;

  save_settings(user_path+'astap.cfg');

  OldCursor := Screen.Cursor;
  Screen.Cursor:= crHourGlass;

  {solve internal}
  mainwindow.caption:='Solving.......';
  save1.Enabled:=solve_image(img_loaded,false {get hist, is already available});{match between loaded image and star database}
  if cd1_1<>0 then
  begin
    mainwindow.ra1.text:=prepare_ra(ra0,' ');{show center of image}
    mainwindow.dec1.text:=prepare_dec(dec0,' ');
    {$IfDef Darwin}// {MacOS}
      //ra1change(nil);{OSX doesn't trigger an event, so ra_label is not updated}
      //mainwindow.dec1change(nil);
    {$ENDIF}
    plot_north;
    update_menu_related_to_solver(true);{update menus section}
    update_statusbar_section5;{update section 5 with image dimensions in degrees}
  end;
  {else do nothing, keep old solution visible if available}

  memo1.Visible:=true; {could be disabled by loading dark/flits due to calibrate prior to solving}
  Screen.Cursor:= OldCursor;
end;

procedure Tmainwindow.min2EditingDone(Sender: TObject);
var
   edit_value: integer;
begin
  edit_value:=min(max(round(strtofloat2(min2.text)),0),65535);{updown in FPC has a maximum of 32767, so not usable}
  if edit_value<> minimum1.Position then {something has really changed}
  begin
    minimum1.Position:=edit_value;
    mainwindow.range1.itemindex:=7; {manual}
    plot_fits(mainwindow.image1,false,true);
  end;
end;


procedure Tmainwindow.remove_above1Click(Sender: TObject);
begin
  {calculate in array coordinates}
  {startY is already defined by mousedown}
  if flip_vertical1.checked=false then stopY:=0 else stopY:=height2-1;
  startx:=0;
  stopX:=width2-1;
  mainwindow.CropFITSimage1Click(nil);
 end;


procedure Tmainwindow.remove_below1Click(Sender: TObject);
begin
  {calculate in array coordinates}
  {startY is already defined by mousedown}
  if flip_vertical1.checked then stopY:=0 else stopY:=height2-1;
  startx:=0;
  stopX:=width2-1;
  mainwindow.CropFITSimage1Click(nil);
end;

procedure Tmainwindow.remove_left1Click(Sender: TObject);
begin
  {calculate in array coordinates}
  starty:=0;{no change in y}
  stopY:=height2-1;
  {startx is already defined by mousedown}
  if flip_horizontal1.checked then stopX:=0 else stopX:=width2-1;
  mainwindow.CropFITSimage1Click(nil);
end;

procedure Tmainwindow.remove_right1Click(Sender: TObject);
begin
  {calculate in array coordinates}
  starty:=0;{no change in y}
  stopY:=height2-1;
  {startx is already defined by mousedown}
  if flip_horizontal1.checked=false then stopX:=0 else stopX:=width2-1;
  mainwindow.CropFITSimage1Click(nil);
end;

procedure Tmainwindow.select_directory_thumb1Click(Sender: TObject);
begin
  if SelectDirectory('Select a directory', ExtractFileDir(filename2){initialdir} , chosenDirectory) then
  begin
    thumbnails1:=Tthumbnails1.Create(self);
    thumbnails1.ShowModal;
    thumbnails1.Free;
  end;
end;

procedure Tmainwindow.SpeedButton1Click(Sender: TObject);
var
  oldvalue:integer;
begin
  oldvalue:=LoadFITSPNGBMPJPEG1filterindex;
  LoadFITSPNGBMPJPEG1filterindex:=4;{preview FITS files}
  LoadFITSPNGBMPJPEG1Click(nil);{open load file in preview mode}
  LoadFITSPNGBMPJPEG1filterindex:=oldvalue; {restore filterindex position}
end;

procedure split_raw(xp,yp : integer);{extract one of the Bayer matrix pixels}
var
  Save_Cursor:TCursor;
  img_temp11 : image_array;
  I, FitsX, fitsY,w,h   : integer;
  ratio                 : double;
  filtern               : string;
  dobackup : boolean;
begin
  with mainwindow do
  begin
    filtern:='P'+inttostr(xp)+inttostr(yp);

    OpenDialog1.Title := 'Select multiple RAW fits files to extract Bayer matrix position '+filtern+' from them';
    OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
    opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';
    fits_file:=true;
   // data_range_groupBox1.Enabled:=true;
    esc_pressed:=false;

    if OpenDialog1.Execute then
    begin
      Save_Cursor := Screen.Cursor;
      Screen.Cursor := crHourglass;    { Show hourglass cursor }
      dobackup:=img_loaded<>nil;
      if dobackup then backup_img;{preserve img array and fits header of the viewer}

      try { Do some lengthy operation }
          with OpenDialog1.Files do
          for I := 0 to Count - 1 do
          begin
            filename2:=Strings[I];
            {load image}
            Application.ProcessMessages;
            if ((esc_pressed) or (load_fits(filename2,true {light},true,img_loaded)=false)) then begin beep; Screen.Cursor := Save_Cursor; exit;end;

            ratio:=0.5;
            w:=trunc(width2/2);  {half size}
            h:=trunc(height2/2);

            setlength(img_temp11,1,w,h);

            for fitsY:=0 to h-1 do
              for fitsX:=0 to w-1  do
              begin
                img_temp11[0,fitsX,fitsY]:=img_loaded[0,fitsx*2+xp-1,fitsY*2+yp-1];
              end;

            width2:=w;
            height2:=h;

            update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
            update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);


            update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
            update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);

            if crpix1<>0 then begin crpix1:=crpix1*ratio; update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,crpix1);end;
            if crpix2<>0 then begin crpix2:=crpix2*ratio; update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,crpix2);end;

            if cdelt1<>0 then begin cdelt1:=cdelt1/ratio; update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,cdelt1);end;
            if cdelt2<>0 then begin cdelt2:=cdelt2/ratio; update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,cdelt2);end;

            if cd1_1<>0 then
            begin
              cd1_1:=cd1_1/ratio;
              cd1_2:=cd1_2/ratio;
              cd2_1:=cd2_1/ratio;
              cd2_2:=cd2_2/ratio;
              update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_1);
              update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_2);
              update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_1);
              update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_2);
            end;

            update_integer('XBINNING=',' / Binning factor in width                         ' ,round(XBINNING/ratio));
            update_integer('YBINNING=',' / Binning factor in height                        ' ,round(yBINNING/ratio));
            update_text   ('FILTER  =',#39+'P11'+#39+'           / Filter name                                    ');
            add_text   ('HISTORY   ','contains one pixel of 2x2 bayer matrix');

            update_text   ('FILTER  =',#39+filtern+#39+'           / Filter name                                    ');
            img_loaded:=img_temp11;
            save_fits(img_loaded,ChangeFileExt(FileName2,'_'+filtern+'.fit'),16,true);{overwrite}
            img_temp11:=nil;

         end;
        finally
        if dobackup then restore_img;{for the viewer}
        Screen.Cursor := Save_Cursor;  { Always restore to normal }
      end;
    end;

  end;
end;



procedure Tmainwindow.OpenDialog1SelectionChange(Sender: TObject);
begin
  if opendialog1.FilterIndex=4 then {preview FITS files}
  begin
    if (  (pos('.fit',opendialog1.FileName)>0) or (pos('.FIT',opendialog1.FileName)>0)  )  then
    begin
      mainwindow.caption:=opendialog1.filename;
      {load image}
      if load_fits(opendialog1.filename,true {light},true,img_loaded) then
      begin
        if ((naxis3=1) and (mainwindow.preview_demosaic1.checked)) then demosaic_advanced(img_loaded);{demosaic and set levels}
        use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
        plot_fits(mainwindow.image1,false {re_center},true);
      end;
    end;
  end;
end;


procedure Tmainwindow.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (ssright in shift)=false then mouse_enter:=0; {for crop function}
end;


procedure Tmainwindow.recent1Click(Sender: TObject);
begin
  filename2:= (Sender as Tmenuitem).caption;
  if fileexists(filename2) then load_image(true,true {plot}) {load and center, plot}
  else
  begin {file gone/deleted}
     application.messagebox(pchar('File not found:'+#13+#10+#13+#10+(Sender as Tmenuitem).caption),pchar('Error'),MB_ICONWARNING+MB_OK);
    (Sender as Tmenuitem).caption:='';
  end;
  add_recent_file(filename2);{update recent files list by moving this one up to first position}
end;


procedure Tmainwindow.Remove_deep_sky_object1Click(Sender: TObject);
var
   fitsX,fitsY,dum,k,bsize  : integer;
   mode_left_bottom,mode_left_top, mode_right_top, mode_right_bottom,
   noise_left_bottom,noise_left_top, noise_right_top, noise_right_bottom,noise_level,
   center_x,center_y,a,b,angle_from_center,new_value,old_value : double;
   line_bottom, line_top : double;

   Save_Cursor:TCursor;
begin
  if fits_file=false then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img;

    bsize:=min(10,abs(stopX-startX));{10 or smaller}

    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

    {ellipse parameters}
    center_x:=(startx+stopX-1)/2;
    center_y:=(startY+stopY-1)/2;
    a:=(stopX-1-startx)/2;
    b:=(stopY-1-startY)/2;

    for k:=0 to naxis3-1 do {do all colors}
    begin

      mode_left_bottom:=mode(img_loaded,k,startx-bsize,startx+bsize,starty-bsize,starty+bsize,32000);{for this area get most common value equals peak in histogram}
      mode_left_top:=   mode(img_loaded,k,startx-bsize,startx+bsize,stopY-bsize,stopY+bsize,32000);{for this area get most common value equals peak in histogram}

      mode_right_bottom:=mode(img_loaded,k,stopX-bsize,stopX+bsize,starty-bsize,starty+bsize,32000);{for this area get most common value equals peak in histogram}
      mode_right_top:=   mode(img_loaded,k,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize,32000);{for this area get most common value equals peak in histogram}

      noise_left_bottom:=get_negative_noise_level(img_loaded,k,startx-bsize,startx+bsize,starty-bsize,starty+bsize, mode_left_bottom);{find the negative noise level below most_common_level of a local area}
      noise_left_top:=get_negative_noise_level(img_loaded,k,startx-bsize,startx+bsize,stopY-bsize,stopY+bsize, mode_left_top);{find the negative noise level below most_common_level of a local area}
      noise_right_bottom:=get_negative_noise_level(img_loaded,k,stopX-bsize,stopX+bsize,starty-bsize,starty+bsize, mode_right_bottom);{find the negative noise level below most_common_level of a local area}
      noise_right_top:=get_negative_noise_level(img_loaded,k,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize, mode_right_top);{find the negative noise level below most_common_level of a local area}
      noise_level:=(noise_left_bottom + noise_left_top + noise_right_top + noise_right_bottom)/4;

      for fitsY:=startY to stopY-1 do
      for fitsX:=startX to stopX-1 do
      begin
        angle_from_center:=arctan(abs(fitsY-center_Y)/max(1,abs(fitsX-center_X)));
        if sqr(fitsX-center_X)+sqr(fitsY-center_Y)  <= sqr(a*cos(angle_from_center))+ sqr(b*sin(angle_from_center)) then     {within the ellipse}
        begin
          line_bottom:=mode_left_bottom*(stopX-fitsx)/(stopX-startx)+ mode_right_bottom *(fitsx-startX)/(stopX-startx);{median value at bottom line}
          line_top:=  mode_left_top *   (stopX-fitsx)/(stopX-startx)+ mode_right_top*(fitsx-startX)/(stopX-startx);{median value at top line}
          new_value:=line_bottom*(stopY-fitsY)/(stopY-startY)+line_top*(fitsY-startY)/(stopY-startY);{median value at position FitsX, fitsY}
          old_value:=img_loaded[k,fitsX,fitsY];
          if ((old_value-3*noise_level>new_value) or (old_value+3*noise_level<new_value)) then img_loaded[k,fitsX,fitsY]:=new_value;{adapt only if pixel value is 3*noise level different}
        end;
      end;
    end;{k color}
    plot_fits(mainwindow.image1,false,true);
    Screen.Cursor:=Save_Cursor;
  end {fits file}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);

end;

function floattostr2(x:double):string;
begin
  str(x:0:6,result);
end;
function floattostr3(x:double):string;
begin
  str(x,result);
end;

function floattostrF2(const x:double; width1,decimals1 :word): string;
begin
  str(x:width1:decimals1,result);
  if formatSettings.decimalseparator<>'.' then result:=StringReplace(result,'.',formatSettings.decimalseparator,[]); {replaces dot by komma}
end;

function inttostr5(x:integer):string;{always 5 digit}
begin
  str(x:5,result);
end;


function strtofloat2(s:string): double;{works with either dot or komma as decimal seperator}
var
  error1:integer;
begin
  s:=StringReplace(s,',','.',[]); {replaces komma by dot}
  s:=trim(s); {remove spaces}
  val(s,result,error1);
  if error1<>0 then result:=0;
end;


Function  deg_and_minutes_tofloat(s:string):double;
var
  x: double;
  j: integer;
begin
   j:=pos(':',s);
   if j=0 then {12.50 format}
     x:=strtofloat2(s) {12.5 format}
   else {12:30.0 format}
   begin
     x:=(strtofloat2(copy(s,1,j-1)));
     if pos('-',s)>0 then x:=x - strtofloat2(copy(s,j+1,length(s)-j))/60
                     else x:=x + strtofloat2(copy(s,j+1,length(s)-j))/60 ;
   end;
   deg_and_minutes_tofloat:=x;
end;


Function LeadingZero(w : integer) : String;
 var
   s : String;
 begin
   Str(w:0,s);
   if Length(s) = 1 then
     s := '0' + s;
   LeadingZero := s;
 end;

procedure addstring(position:integer;inp :double); {update string head1}
var
  s: ansistring;
  i:integer;
begin
  str(inp:16,s);
  for i:=11 to 30 do
  begin
    if i+length(s)<=30 then head1[position,i]:=' ' {clear old results}
    else
    head1[position,i]:=s[(i+length(s)-30)];
  end;
end;


function prepare_ra5(rax:double; sep:string):string; {radialen to text  format 24h 00.0}
  var
    B : String[2];
    h,m,dm  :integer;
begin {make from rax [0..pi*2] a text in array bericht. Length is 8 long}
  rax:=rax+pi*0.1/(24*60); {add 1/10 of half minute to get correct rounding and not 7:60 results as with round}
  rax:=rax*12/pi; {make hours}
  h:=trunc(rax);
  m:=trunc((rax-h)*60);
  dm:=trunc((rax-h-m/60)*600);
  Str(trunc(h):2,b);
  prepare_ra5:=b+sep+leadingzero(m)+'.'+ansichar(dm+48);
end;


function prepare_dec5(decx:double;sep:string):string; {radialen to text  format 90d 00 }
 var
   B : String[7];
   g,m :integer;
   sign   : ansichar;
begin {make from rax [0..pi*2] a text in array bericht. Length is 10 long}
  if decx<0 then sign:='-' else sign:='+';
  decx:=abs(decx)+pi/(360*60); {add half minute to get correct rounding and not 7:60 results as with round}
  decx:=decx*180/pi; {make degrees}
  g:=trunc(decx);
  m:=trunc((decx-g)*60);
  Str(trunc(g):0,b);
  prepare_dec5:=sign+b+sep+leadingzero(m);
end;


function prepare_ra(rax:double; sep:string):string; {radialen to text, format 24: 00 00.0 }
 var
   h,m,s,ds  :integer;
 begin   {make from rax [0..pi*2] a text in array bericht. Length is 8 long}
  rax:=rax+pi*0.1/(24*60*60); {add 1/10 of half second to get correct rounding and not 7:60 results as with round}
  rax:=rax*12/pi; {make hours}
  h:=trunc(rax);
  m:=trunc((rax-h)*60);
  s:=trunc((rax-h-m/60)*3600);
  ds:=trunc((rax-h-m/60-s/3600)*36000);
  prepare_ra:=leadingzero(h)+sep+leadingzero(m)+'  '+leadingzero(s)+'.'+ansichar(ds+48);
end;


function prepare_dec(decx:double; sep:string):string; {radialen to text, format 90d 00 00}
 var
   g,m,s  :integer;
   sign   : ansichar;
begin {make from rax [0..pi*2] a text in array bericht. Length is 10 long}
  if decx<0 then sign:='-' else sign:='+';
  decx:=abs(decx)+pi/(360*60*60); {add half second to get correct rounding and not 7:60 results as with round}
  decx:=decx*180/pi; {make degrees}
  g:=trunc(decx);
  m:=trunc((decx-g)*60);
  s:=trunc((decx-g-m/60)*3600);
  prepare_dec:=sign+leadingzero(g)+sep+leadingzero(m)+'  '+leadingzero(s);
end;


function prepare_ra2(rax:double; sep:string):string; {radialen to text, format 24: 00 00.00 }
 var
   B       : String[2];
   h,m,s,ds  :integer;
 begin   {make from rax [0..pi*2] a text in array bericht. Length is 8 long}
  rax:=rax+pi*0.01/(24*60*60); {add 1/10 of half second to get correct rounding and not 7:60 results as with round}
  rax:=rax*12/pi; {make hours}
  h:=trunc(rax);
  m:=trunc((rax-h)*60);
  s:=trunc((rax-h-m/60)*3600);
  ds:=trunc((rax-h-m/60-s/3600)*360000);
  Str(trunc(h):2,b);
  prepare_ra2:=b+sep+leadingzero(m)+'  '+leadingzero(s)+'.'+leadingzero(ds);
end;


Function prepare_dec2(decx:double; sep:string):string; {radialen to text, format 90d 00 00.1}
 var
   B,ds2 : String[5];
   g,m,s,ds :integer;
   sign   : ansichar;
begin {make from rax [0..pi*2] a text in array bericht. Length is 10 long}
//  if decX>2*pi then decX:=2*pi;
  if decx<0 then sign:='-' else sign:='+';
  decx:=abs(decx)+pi*0.1/(360*60*60); {add 1/20 second to get correct rounding and not 7:60 results as with round}
  decx:=decx*180/pi; {make degrees}
  g:=trunc(decx);
  m:=trunc((decx-g)*60);
  s:= trunc((decx-g-m/60)*3600);
  ds:=trunc((decx-g-m/60-s/3600)*36000);
  Str(trunc(g):2,b);
  Str(trunc(ds):1,ds2);
  prepare_dec2:=sign+b+sep+leadingzero(m)+'  '+leadingzero(s)+'.'+ds2;
end;


procedure old_to_new_WCS;{ convert old WCS to new}
var
   sign  : integer;
begin
  cd1_1:=cdelt1*cos(crota2*pi/180); {note 2013 should be crota1 if skewed}
  if cdelt1>=0 then sign:=+1 else sign:=-1;
  cd1_2:=abs(cdelt2)*sign*sin(crota2*pi/180);{note 2013 should be crota1 if skewed}
  if cdelt2>=0 then sign:=+1 else sign:=-1;
  cd2_1:=-abs(cdelt1)*sign*sin(crota2*pi/180);
  cd2_2:= cdelt2*cos(crota2*pi/180);
end;


procedure new_to_old_WCS;{convert new style FITsS to old style}
var
   sign  : integer;
begin
  { convert to old WCS. Based on draft 1988 , do not use conversion article Alain Klotz, give sometimes zero CROTA}
  if (cd1_1*cd2_2-cd1_2*cd2_1)>=0 then sign:=+1 else sign:=-1;

  cdelt1:=sqrt(sqr(cd1_1)+sqr(cd2_1))*sign;{if no old wcs header use cd2_2 of new WCS style for pixel size}
  cdelt2:=sqrt(sqr(cd1_2)+sqr(cd2_2));{if no old wcs header use cd2_2 of new WCS style for pixel size}

  crota1:= +arctan2(sign*cd1_2,cd2_2)*180/pi;
  crota2:= -arctan2(cd2_1,sign*cd1_1)*180/pi;  //  crota2old := (atn_2(sign*cd1_1,cd2_1)-pi/2)*180/pi;
end;


function fnmodulo (x,range: double):double;
begin
  {range should be 2*pi or 24 hours or 0 .. 360}
  x:=range *frac(X /range); {quick method for big numbers}
  if x<0 then x:=x+range;   {do not like negative numbers}
  fnmodulo:=x;
end;


function intensityRGB(x:tcolor): byteX3;
begin
  intensityRGB[0]:=getRvalue(x);{get red, green blue value as intensity}
  intensityRGB[1]:=getGvalue(x);
  intensityRGB[2]:=getBvalue(x);
end;


procedure demosaic_bilinear_interpolation(var img:image_array;pattern: integer);{make from sensor bayer pattern the three colors}
var
    X,Y,offsetx, offsety: integer;
    red,green_odd,green_even,blue : boolean;
    img_temp2 : image_array;
begin
  case pattern  of
     0: begin offsetx:=0; offsety:=0; end;
     1: begin offsetx:=0; offsety:=1; end;
     2: begin offsetx:=1; offsety:=0; end;
     3: begin offsetx:=1; offsety:=1; end;
     else exit;
  end;

  setlength(img_temp2,3,width2,height2);{set length of image array color}

  for y := 1 to height2-2 do   {-2 = -1 -1}
  begin
    for x:=1 to width2-2 do
    begin
     {http://cilab.knu.ac.kr/English/research/Color/Interpolation.htm ,  Bilinear interpolation}

      try
      green_even:= ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );{even(i) function is odd(i+1), even is here for array position not fits position}
      green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
      red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
      blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );

      if green_odd then begin
                   img_temp2[0,x,y]:=     (img[0,x  ,y-1] + img[0,x  ,y+1])/2; {red neighbor pixels };
                   img_temp2[1,x,y]:=     (img[0,x,  y  ] );
                   img_temp2[2,x,y]:=     (img[0,x-1,y  ] + img[0,x+1,y  ])/2; {blue neighbor pixels }end
      else
      if green_even then begin
                   img_temp2[0,x,y]:=     (img[0,x-1,y  ] + img[0,x+1,y  ])/2; {red neighbor pixels };
                   img_temp2[1,x,y]:=     (img[0,x,  y  ] );
                   img_temp2[2,x,y]:=     (img[0,x  ,y-1] + img[0,x  ,y+1])/2; {blue neighbor pixels }end
      else
      if red then begin
                   img_temp2[0,x,y]:=     (img[0,x,  y  ]);
                   img_temp2[1,x,y]:=     (img[0,x-1,y  ] + img[0,x+1,y  ] + img[0,x  ,y-1]+ img[0,x  ,y+1])/4;{green neighbours}
                   img_temp2[2,x,y]:=     (img[0,x-1,y-1] + img[0,x-1,y+1] + img[0,x+1,y-1]+ img[0,x+1,y+1])/4 ; end {blue neighbor pixels }
      else
      if blue then begin
                   img_temp2[0,x,y]:=     (img[0,x-1,y-1] + img[0,x-1,y+1]+ img[0,x+1,y-1]+ img[0,x+1,y+1])/4;
                   img_temp2[1,x,y]:=     (img[0,x-1,y  ] + img[0,x+1,y  ]+ img[0,x  ,y-1]+ img[0,x,  y+1])/4;
                   img_temp2[2,x,y]:=     (img[0,x,  y  ]  ); end;
      except
      end;


    end;{x loop}
  end;{y loop}


  img:=img_temp2;
  img_temp2:=nil;{free temp memory}
  naxis3:=3;{now three colors}
  naxis:=3; {from 2 to 3 dimensions}
end;


procedure demosaic_x_trans(var img:image_array);{make from Fuji X-trans three colors}
var
    X,Y,x2,y2,xpos,ypos,xpos6,ypos6: integer;
    red,blue  : single;
    img_temp2 : image_array;
begin

  setlength(img_temp2,3,width2,height2);{set length of image array color}


  for y := 2 to height2-2 do   {-2 = -1 -1}
  begin
    for x:=2 to width2-2 do
    begin
     {http://cilab.knu.ac.kr/English/research/Color/Interpolation.htm ,  Bilinear interpolation}

      try
       x2:=x-1;
       y2:=y-1;
       xpos:=1+x2-(x2 div 3)*3;{position in 3x3 matrix}
       ypos:=1+y2-(y2 div 3)*3;
       xpos6:=1+x2-(x2 div 6)*6;{position in 6x6 matrix}
       ypos6:=1+y2-(y2 div 6)*6;

      {use only one neighbour pixel with preference go right, go below, go left. Use only on neighbour pixel for maximum sharpness }

      if ((xpos=1) and (ypos=1)) then {green}begin
                   red             :=   img[0,x  ,y+1]; {near red pixel};
                   img_temp2[1,x,y]:=   img[0,x,  y  ] ;
                   blue            :=   img[0,x+1,y  ]; {near blue pixel} end else
      if ((xpos=3) and (ypos=1)) then {green}begin
                   red             :=   img[0,x  ,y+1]; {near red pixel};
                   img_temp2[1,x,y]:=   img[0,x,  y  ] ;
                   blue            :=   img[0,x-1,y  ]; {near blue pixel} end else
      if ((xpos=2) and (ypos=2)) then {green}begin
                   red             :=   img[0,x+1,y  ]; {near red pixel};
                   img_temp2[1,x,y]:=   img[0,x,  y  ] ;
                   blue:=   img[0,x  ,y+1]; {near blue pixel} end else
      if ((xpos=1) and (ypos=3)) then {green}begin
                   red             :=   img[0,x  ,y-1]; {near red pixel};
                   img_temp2[1,x,y]:=   img[0,x,  y  ] ;
                   blue:=   img[0,x+1,y  ]; {near blue pixel} end else
      if ((xpos=3) and (ypos=3)) then {green}begin
                   red             :=   img[0,x  ,y-1]; {near red pixel};
                   img_temp2[1,x,y]:=   img[0,x,  y  ] ;
                   blue            :=   img[0,x-1,y  ]; {near blue pixel} end else


      if ((xpos=2) and (ypos=1)) then {blue}begin
                   red             :=   img[0,x,y-1] ; {near red pixel};
                   img_temp2[1,x,y]:=   img[0,x+1 ,y  ]; {near green pixel};
                   blue            :=   img[0,x ,y  ]; end else
      if ((xpos=2) and (ypos=3)) then {blue}begin
                   red             :=   img[0,x ,y+1]; {near red pixel};
                   img_temp2[1,x,y]:=   img[0,x+1 ,y  ]; {near green pixel};
                   blue            :=   img[0,x ,y  ]; end else


      if ((xpos=1) and (ypos=2)) then {red}begin
                   red             :=   img[0,x  ,y  ];
                   img_temp2[1,x,y]:=   img[0,x+1 ,y ];   {near green pixel(s)};
                   blue            :=   img[0,x-1,y ]; {near blue pixel(s)} end else

      if ((xpos=3) and (ypos=2)) then {red}begin
                   red             :=   img[0,x  ,y  ];
                   img_temp2[1,x,y]:=   img[0,x  ,y+1];   {near green pixel(s)};
                   blue            :=   img[0,x+1,y  ]; {near blue pixel(s)} end;

      {fix red and green swap}
      if ((xpos6<=3) and (ypos6<=3)) then begin img_temp2[0,x,y]:=red;  img_temp2[2,x,y]:=blue;end else
      if ((xpos6> 3) and (ypos6<=3)) then begin img_temp2[0,x,y]:=blue; img_temp2[2,x,y]:=red;end else
      if ((xpos6<=3) and (ypos6> 3)) then begin img_temp2[0,x,y]:=blue; img_temp2[2,x,y]:=red;end else
      if ((xpos6> 3) and (ypos6> 3)) then begin img_temp2[0,x,y]:=red;  img_temp2[2,x,y]:=blue;end;

      except
      end;

    end;{x loop}
  end;{y loop}

  img:=img_temp2;
  img_temp2:=nil;{free temp memory}
  naxis3:=3;{now three colors}
  naxis:=3; {from 2 to 3 dimensions}
end;

procedure demosaic_astrosimple(var img:image_array;pattern: integer);{Spread each colour pixel to 2x2. Works well for astro oversampled images. Idea by Han.k}
var
    X,Y,offsetx, offsety: integer;
    red,green_odd,green_even,blue : boolean;
    img_temp2 : image_array;
    value     : single;
begin
  case pattern  of
     0: begin offsetx:=0; offsety:=0; end;
     1: begin offsetx:=0; offsety:=1; end;
     2: begin offsetx:=1; offsety:=0; end;
     3: begin offsetx:=1; offsety:=1; end;
  end;

  setlength(img_temp2,3,width2,height2);{set length of image array color}

  for y := 0 to height2-2 do   {-2 = -1 -1}
    for x:=0 to width2-2 do
  begin {clear green}
      img_temp2[1,x,y]:=0;
  end;

  for y := 0 to height2-2 do   {-2 = -1 -1}
  begin
    for x:=0 to width2-2 do
    begin
      try
      green_even:= ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );{even(i) function is odd(i+1), even is here for array position not fits position}
      green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
      red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
      blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );

      value:=img[0,x,  y  ];

      if ((green_odd) or (green_even)) then
      begin
        value:=value/2;
        img_temp2[1,x,y]:=img_temp2[1,x,y]+value;
        img_temp2[1,x,y+1]:=img_temp2[1,x,y+1]+value;
        img_temp2[1,x+1,y]:=img_temp2[1,x+1,y]+value;
        img_temp2[1,x+1,y+1]:=img_temp2[1,x+1,y+1]+value;
      end
      else
      if red then
      begin
        img_temp2[0,x,y]:=value;
        img_temp2[0,x+1,y]:=value;
        img_temp2[0,x,y+1]:=value;
        img_temp2[0,x+1,y+1]:=value;
      end
      else
      if blue then
      begin
        img_temp2[2,x,y]:=value;
        img_temp2[2,x+1,y]:=value;
        img_temp2[2,x,y+1]:=value;
        img_temp2[2,x+1,y+1]:=value;
      end;
      except
      end;

    end;{x loop}
  end;{y loop}
  img:=img_temp2;
  img_temp2:=nil;{free temp memory}
  naxis3:=3;{now three colors}
  naxis:=3; {from 2 to 3 dimensions}
end;


procedure demosaic_astroM_bilinear_interpolation(var img:image_array;pattern: integer);{make from sensor bayer pattern the three colors}
var
    X,Y,offsetx, offsety, count: integer;
    red,green_odd,green_even,blue : boolean;
    img_temp2 : image_array;
    a1,a2,a3,a4,a5,a6,a7,a8, average1,average2,average3,luminance,signal,signal2,bg : single;

begin
  case pattern  of
     0: begin offsetx:=0; offsety:=0; end;
     1: begin offsetx:=0; offsety:=1; end;
     2: begin offsetx:=1; offsety:=0; end;
     3: begin offsetx:=1; offsety:=1; end;
  end;
  setlength(img_temp2,3,width2,height2);{set length of image array color}
  {calculate mean background value}
  count:=0;
  bg:=0;
  for y:= 10 to (height2-10) div 100  do
  for x:=10 to (width2-10) div 100 do
  begin
    bg:=bg+img[0,x  ,y  ]+
    img[0,x+1,y  ]+
    img[0,x  ,y+1]+
    img[0,x+1,y+1];
    inc(count,4)
  end;
  bg:=bg/count;{average background value}

  signal:=0.5*bg;     {2 values   140,100  average is 120, delta is 20/120 is 16.7%}
  signal2:=signal/1.67; {4 values   140,100,100,100  average is 110, delta 30/110 is 27.2%, so factor 1.67 difference}

  for y := 1 to height2-2 do   {-2 = -1 -1}
  begin
    for x:=1 to width2-2 do
    begin

      try
      green_even:= ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );{even(i) function is odd(i+1), even is here for array position not fits position. Place here otherwise stars get tail}
      green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
      red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
      blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );

      if green_odd then
                 begin
                   a1:=img[0,x  ,y-1];
                   a2:=img[0,x  ,y+1];
                   average1:=(a1+a2)/2;{red neighbor pixels };

                   average2:=(img[0,x,  y  ] );

                   a3:=img[0,x-1,y  ];
                   a4:=img[0,x+1,y  ];
                   average3:=(a3+a4)/2; {blue neighbor pixels }

                   if ((a1>average1+signal) or (a2>average1+signal) or (a3>average2+signal) or (a4>average2+signal)) {severe slope} then
                   begin
                     luminance:=(average1+average2+average3)/3;
                     img_temp2[0,x,y]:=luminance;{remove color info, keep luminace}
                     img_temp2[1,x,y]:=luminance;
                     img_temp2[2,x,y]:=luminance;
                   end
                   else
                   begin
                     img_temp2[0,x,y]:=average1;
                     img_temp2[1,x,y]:=average2;
                     img_temp2[2,x,y]:=average3;

                   end;
                 end
      else
      if green_even then
                    begin
                      a1:=img[0,x-1,y  ];
                      a2:=img[0,x+1,y  ];
                      average1:=(a1+a2)/2;{red neighbor pixels };

                      average2:=     (img[0,x,  y  ] );

                      a3:=img[0,x  ,y-1];
                      a4:=img[0,x  ,y+1];
                      average3:=(a3+a4)/2; {blue neighbor pixels };

                      if ((a1>average1+signal) or (a2>average1+signal) or (a3>average2+signal) or (a4>average2+signal)) {severe slope} then
                     begin
                       luminance:=(average1+average2+average3)/3;
                       img_temp2[0,x,y]:=luminance;{remove color info, keep luminace}
                       img_temp2[1,x,y]:=luminance;
                       img_temp2[2,x,y]:=luminance;
                     end
                     else
                     begin
                       img_temp2[0,x,y]:=average1;
                       img_temp2[1,x,y]:=average2;
                       img_temp2[2,x,y]:=average3;

                     end;
                   end
      else
      if red then begin
                   average1:=(img[0,x,  y  ]);

                   a1:= img[0,x-1,y  ];
                   a2:= img[0,x+1,y  ];
                   a3:= img[0,x  ,y-1];
                   a4:= img[0,x  ,y+1];{green neighbours}
                   average2:=(a1+a2+a3+a4)/4;


                   a5:= img[0,x-1,y-1];
                   a6:= img[0,x-1,y+1];
                   a7:= img[0,x+1,y-1];
                   a8:= img[0,x+1,y+1];{blue neighbours}
                   average3:=(a5+a6+a7+a8)/4;

                   if ((a1>average2+signal2) or (a2>average2+signal2) or (a3>average2+signal2) or (a4>average2+signal2) or
                       (a5>average3+signal2) or (a6>average3+signal2) or (a7>average3+signal2) or (a8>average3+signal2) ) then {severe slope}
                   begin
                     luminance:=(average1+average2+average3)/3;
                     img_temp2[0,x,y]:=luminance;{remove color info, keep luminace}
                     img_temp2[1,x,y]:=luminance;
                     img_temp2[2,x,y]:=luminance;
                   end
                   else
                   begin
                     img_temp2[0,x,y]:=average1;
                     img_temp2[1,x,y]:=average2;
                     img_temp2[2,x,y]:=average3;
                   end;

      end

      else
      if blue then
                 begin
                   average1:=(img[0,x,  y  ]);

                   a1:= img[0,x-1,y-1];
                   a2:= img[0,x-1,y+1];
                   a3:= img[0,x+1,y-1];
                   a4:= img[0,x+1,y+1];{red neighbours}
                   average1:=(a1+a2+a3+a4)/4;

                   a5:= img[0,x-1,y  ];
                   a6:= img[0,x+1,y  ];
                   a7:= img[0,x  ,y-1];
                   a8:= img[0,x  ,y+1];{green neighbours}
                   average2:=(a5+a6+a7+a8)/4;

                   average3:=img[0,x,  y  ];

                   if ((a1>average1+signal2) or (a2>average1+signal2) or (a3>average1+signal2) or (a4>average1+signal2) or
                       (a5>average2+signal2) or (a6>average2+signal2) or (a7>average2+signal2) or (a8>average2+signal2) ) then {severe slope}
                   begin
                     luminance:=(average1+average2+average3)/3;
                     img_temp2[0,x,y]:=luminance;{remove color info, keep luminace}
                     img_temp2[1,x,y]:=luminance;
                     img_temp2[2,x,y]:=luminance;
                   end
                   else
                   begin
                     img_temp2[0,x,y]:=average1;
                     img_temp2[1,x,y]:=average2;
                     img_temp2[2,x,y]:=average3;


                   end;
                 end;
      except
      end;
    end;{x loop}
  end;{y loop}


  img:=img_temp2;
  img_temp2:=nil;{free temp memory}
  naxis3:=3;{now three colors}
  naxis:=3; {from 2 to 3 dimensions}
end;


procedure demosaic_astroC_bilinear_interpolation(var img:image_array;saturation {saturation point}, pattern: integer);{make from sensor bayer pattern the three colors}
var
    X,Y,offsetx, offsety, counter,fitsX,fitsY,x2,y2: integer;
    red,green_odd,green_even,blue : boolean;
    img_temp2 : image_array;
    a1,a2,a3,a4,a5,a6,a7,a8, average1,average2,average3,luminance, r,g,b,colred,colgreen,colblue,rgb,lowest: single;
    bg, sqr_dist   :  double;
const
  step = 5;
begin
  case pattern  of
     0: begin offsetx:=0; offsety:=0; end;
     1: begin offsetx:=0; offsety:=1; end;
     2: begin offsetx:=1; offsety:=0; end;
     3: begin offsetx:=1; offsety:=1; end;
  end;

  setlength(img_temp2,3,width2,height2);{set length of image array color}

  bg:=0;
  counter:=0;{prevent divide by zero for fully saturated images}

  for y := 1 to height2-2 do   {-2 = -1 -1}
  begin
    for x:=1 to width2-2 do
    begin

      try
      green_even:= ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );{even(i) function is odd(i+1), even is here for array position not fits position}
      green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
      red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
      blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );
      if green_odd then
                 begin
                   a1:=img[0,x  ,y-1];
                   a2:=img[0,x  ,y+1];
                   average1:=(a1+a2)/2;{red neighbor pixels };

                   average2:=(img[0,x,  y  ] );

                   a3:=img[0,x-1,y  ];
                   a4:=img[0,x+1,y  ];
                   average3:=(a3+a4)/2; {blue neighbor pixels }

                   if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation)) {saturation} then
                   begin
                     img_temp2[0,x,y]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2[1,x,y]:=$FFFFFF;{marker pixel as saturated}
                   end
                   else
                   begin
                     img_temp2[0,x,y]:=average1;
                     img_temp2[1,x,y]:=average2;
                     img_temp2[2,x,y]:=average3;
                   end;
                 end
      else
      if green_even then
                    begin
                      a1:=img[0,x-1,y  ];
                      a2:=img[0,x+1,y  ];
                      average1:=(a1+a2)/2;{red neighbor pixels };

                      average2:=     (img[0,x,  y  ] );

                      a3:=img[0,x  ,y-1];
                      a4:=img[0,x  ,y+1];
                      average3:=(a3+a4)/2; {blue neighbor pixels };

                     if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation)) {saturation} then
                     begin
                       img_temp2[0,x,y]:=(average1+average2+average3)/3;{store luminance}
                       img_temp2[1,x,y]:=$FFFFFF;{marker pixel as saturated}
                     end
                     else
                     begin
                       img_temp2[0,x,y]:=average1;
                       img_temp2[1,x,y]:=average2;
                       img_temp2[2,x,y]:=average3;

                     end;
                   end
      else
      if red then begin
                   average1:=(img[0,x,  y  ]);

                   a1:= img[0,x-1,y  ];
                   a2:= img[0,x+1,y  ];
                   a3:= img[0,x  ,y-1];
                   a4:= img[0,x  ,y+1];{green neighbours}
                   average2:=(a1+a2+a3+a4)/4;


                   a5:= img[0,x-1,y-1];
                   a6:= img[0,x-1,y+1];
                   a7:= img[0,x+1,y-1];
                   a8:= img[0,x+1,y+1];{blue neighbours}
                   average3:=(a5+a6+a7+a8)/4;

                   if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation) or
                       (a5>saturation) or (a6>saturation) or (a7>saturation) or (a8>saturation) ) then {saturation}
                   begin
                     img_temp2[0,x,y]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2[1,x,y]:=$FFFFFF;{marker pixel as saturated}

                   end
                   else
                   begin
                     img_temp2[0,x,y]:=average1;
                     img_temp2[1,x,y]:=average2;
                     img_temp2[2,x,y]:=average3;

                     {calculate background}
                     bg:=bg+average1+average2+average3;
                     inc(counter,3); {added red, green, blue values}
                   end;
      end
      else
      if blue then
                 begin
                   average1:=(img[0,x,  y  ]);

                   a1:= img[0,x-1,y-1];
                   a2:= img[0,x-1,y+1];
                   a3:= img[0,x+1,y-1];
                   a4:= img[0,x+1,y+1];{red neighbours}
                   average1:=(a1+a2+a3+a4)/4;

                   a5:= img[0,x-1,y  ];
                   a6:= img[0,x+1,y  ];
                   a7:= img[0,x  ,y-1];
                   a8:= img[0,x  ,y+1];{green neighbours}
                   average2:=(a5+a6+a7+a8)/4;

                   average3:=img[0,x,  y  ];

                   if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation) or
                       (a5>saturation) or (a6>saturation) or (a7>saturation) or (a8>saturation) ) then {saturation}
                   begin
                     img_temp2[0,x,y]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2[1,x,y]:=$FFFFFF;{marker pixel as saturated}
                   end
                   else
                   begin
                     img_temp2[0,x,y]:=average1;
                     img_temp2[1,x,y]:=average2;
                     img_temp2[2,x,y]:=average3;

                   end;
                 end;
      except
      end;

    end;{x loop}
  end;{y loop}

  img:=img_temp2;

  if counter>0 then {not fully saturated image}
  begin
  {correct colour satuated pixels }

    bg:=bg/counter; {background}
    for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
    if img_temp2[1,fitsX,fitsY]=$FFFFFF {marker saturated} then
    begin
      colred:=0;
      colgreen:=0;
      colblue:=0;
      counter:=0;
      luminance:=img_temp2[0,fitsX,fitsY];
      luminance:=luminance-bg;{luminance above background}
      begin
        for y:=-step to step do
        for x:=-step to step do
        begin
           x2:=fitsX+x;
           y2:=fitsY+y;


           if ((x2>=0) and (x2<width2) and (y2>=0) and (y2<height2) ) then {within image}
           begin
             sqr_dist:=x*x+y*y;
             if sqr_dist<=step*step then {circle only}
             begin
               g:= img_temp2[1,x2,y2];
               if g<>$FFFFFF {not saturated pixel} then
               begin
                 r:= img_temp2[0,x2,y2];
                 B:= img_temp2[2,x2,y2];
                 if (r-bg)>0 {signal} then colred  :=colred+   (r-bg); {bg=average red and will be little above the background since stars are included in the average}
                 if (g-bg)>0 then colgreen:=colgreen+ (g-bg);
                 if (b-bg)>0 then colblue:= colblue + (b-bg);
                 inc(counter);
               end;
             end;
           end;
         end;
      end;

      rgb:=0;
      if counter>=1 then
      begin
        colred:=colred/counter;{scale using the number of data points=count}
        colgreen:=colgreen/counter;
        colblue:=colblue/counter;
        if colred>colblue then lowest:=colblue else lowest:=colred;
        if colgreen<lowest {purple} then colgreen:=lowest; {prevent purple stars, purple stars are physical not possible}
        rgb:=(colred+colgreen+colblue+0.00001)/3; {0.00001, prevent dividing by zero}
        img[0,fitsX  ,  fitsY  ]:=bg+ luminance*colred/rgb;
        img[1,fitsX  ,  fitsY  ]:=bg+ luminance*colgreen/rgb;
        img[2,fitsX  ,  fitsY  ]:=bg+ luminance*colblue/rgb;
      end
      else
      begin
       img[1,fitsX  ,  fitsY  ]:=img_temp2[0,fitsX  ,  fitsY  ];
       img[2,fitsX  ,  fitsY  ]:=img_temp2[0,fitsX  ,  fitsY  ];

      end;
    end;
  end{not full saturated}
  else
  begin {fully saturated image}
    for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
    begin
      img[0,fitsX  ,  fitsY  ]:=saturation;
      img[1,fitsX  ,  fitsY  ]:=saturation;
      img[2,fitsX  ,  fitsY  ]:=saturation;
    end;
  end;


  img_temp2:=nil;{free temp memory}
  naxis3:=3;{now three colors}
  naxis:=3; {from 2 to 3 dimensions}
end;



procedure demosaic_Malvar_He_Cutler(var img:image_array;pattern: integer);{make from sensor bayer pattern the three colors. Nor very suitable for astro images}
{Based on paper HIGH-QUALITY LINEAR INTERPOLATION FOR DEMOSAICING OF BAYER-PATTERNED COLOR IMAGES
                Henrique S. Malvar, Li-wei He, and Ross Cutler, Microsoft Research}
var
    X,Y,offsetx, offsety: integer;
    red,green_odd,green_even,blue : boolean;
    img_temp2 : image_array;
begin
  case pattern  of
     0: begin offsetx:=0; offsety:=0; end;
     1: begin offsetx:=0; offsety:=1; end;
     2: begin offsetx:=1; offsety:=0; end;
     3: begin offsetx:=1; offsety:=1; end;
  end;
  setlength(img_temp2,3,width2,height2);{set length of image array color}

  for y := 2 to height2-3 do   {-3 = -1 -2, ignore borders}
  begin
    for x:=2 to width2-3 do
    begin
      try
      green_even:= ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );{even(i) function is odd(i+1), even is here for array position not fits position}
      green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
      red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
      blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );
      if green_odd then begin {red up and down, blue left and right }
                   img_temp2[0,x,y]:=(  5*img[0,x,y]
                                      + 4*img[0,x,y+1] + 4*img[0,x,y-1]
                                      -img[0,x-1,y-1] -img[0,x+1,y-1] -img[0,x-1,y+1] -img[0,x+1,y+1]
                                      -img[0,x,y-2  ] -img[0,x,y+2  ]
                                      +0.5*img[0,x-2 ,y]   +0.5*img[0,x+2,y])/8;
                   img_temp2[1,x,y]:= (img[0,x,  y  ] );
                   img_temp2[2,x,y]:=(  5*img[0,x,y]
                                      + 4*img[0,x-1,y]     +4*img[0,x+1,y]
                                         -img[0,x-1,y-1]     -img[0,x+1,y-1] -img[0,x-1,y+1] -img[0,x+1,y+1]
                                         -img[0,x-2,y  ]     -img[0,x+2,y  ]
                                     +0.5*img[0,x  ,y-2] +0.5*img[0,x  ,y+2])/8;end
      else
      if green_even then begin {red left and right, blue up and down }
                   img_temp2[0,x,y]:=(  5*img[0,x,y]
                                      + 4*img[0,x-1,y]    + 4*img[0,x+1,y]
                                         -img[0,x-1,y-1]     -img[0,x+1,y-1] -img[0,x-1,y+1] -img[0,x+1,y+1]
                                         -img[0,x-2,y  ]     -img[0,x+2,y  ]
                                     +0.5*img[0,x  ,y-2] +0.5*img[0,x  ,y+2])/8;
                   img_temp2[1,x,y]:= (img[0,x,  y  ] );
                   img_temp2[2,x,y]:=(5*img[0,x,y]
                                      + 4*img[0,x  ,y-1] +4*img[0,x  ,y+1]
                                         -img[0,x-1,y-1]   -img[0,x+1,y-1] -img[0,x-1,y+1] -img[0,x+1,y+1]
                                         -img[0,x  ,y-2]   -img[0,x  ,y+2]
                                     +0.5*img[0,x-2,y] +0.5*img[0,x+2,y])/8;end
      else
      if red then begin
                   img_temp2[0,x,y]:=  (img[0,x,  y  ]);
                   img_temp2[1,x,y]:=(4*img[0,x,y]
                                     +2*img[0,x-1,y  ]+2*img[0,x+1,y  ]+2*img[0,x  ,y-1]+2*img[0,x  ,y+1]
                                     -img[0,x-2,y  ]    -img[0,x+2,y  ]  -img[0,x  ,y-2]  -img[0,x  ,y+2])/8;
                   img_temp2[2,x,y]:=(  6*img[0,x,y]
                                       +2*img[0,x-1,y-1]  +2*img[0,x+1,y-1]   +2*img[0,x-1,y+1]+2*img[0,x+1,y+1]
                                     -1.5*img[0,x-2,y  ]-1.5*img[0,x+2,y  ]-1.5*img[0,x  ,y-2]-1.5*img[0,x  ,y+2])/8; end
      else
      if blue then begin
                   img_temp2[0,x,y]:=(  6*img[0,x,y]
                                       +2*img[0,x-1,y-1]  +2*img[0,x+1,y-1]  +2*img[0,x-1,y+1]  +2*img[0,x+1,y+1]
                                     -1.5*img[0,x-2,y  ]-1.5*img[0,x+2,y  ]-1.5*img[0,x  ,y-2]-1.5*img[0,x  ,y+2])/8;
                   img_temp2[1,x,y]:=(4*img[0,x,y]
                                     +2*img[0,x-1,y  ]+2*img[0,x+1,y  ]+2*img[0,x  ,y-1]+2*img[0,x  ,y+1]
                                       -img[0,x-2,y  ]  -img[0,x+2,y  ]  -img[0,x  ,y-2]  -img[0,x  ,y+2])/8;
                   img_temp2[2,x,y]:=  (img[0,x,  y  ]  ); end;
      except
      end;
    end;{x loop}
  end;{y loop}

  img:=img_temp2;
  img_temp2:=nil;{free temp memory}
  naxis3:=3;{now three colors}
  naxis:=3; {from 2 to 3 dimensions}
end;


procedure preserve_colour_saturated_bayer(img: image_array);{for bayer matrix}
var
    fitsX,fitsY,w,h : integer;
begin
  Application.ProcessMessages;
  if esc_pressed then begin exit;end;

  w:=trunc(width2/2);  {half size}
  h:=trunc(height2/2);

  for fitsY:=0 to h-1 do {go through all 2x2 and replace and if saturated replace with previous 2x2}
   for fitsX:=1 to w-1  do
    begin
      if ((img[0,fitsx*2  ,fitsY*2  ]>65500) or
          (img[0,fitsx*2+1,fitsY*2  ]>65500) or
          (img[0,fitsx*2  ,fitsY*2+1]>65500) or
          (img[0,fitsx*2+1,fitsY*2+1]>65500) )   then {saturation}
      begin
       img[0,fitsx*2  ,fitsY*2  ]:=img[0,(fitsx-1)*2  ,fitsY*2  ];
       img[0,fitsx*2+1,fitsY*2  ]:=img[0,(fitsx-1)*2+1,fitsY*2  ];
       img[0,fitsx*2  ,fitsY*2+1]:=img[0,(fitsx-1)*2  ,fitsY*2+1];
       img[0,fitsx*2+1,fitsY*2+1]:=img[0,(fitsx-1)*2+1,fitsY*2+1];

      end;
    end;
end;


function get_demosaic_pattern : integer; {get the required de-bayer range 0..3}
var
  pattern: string;
  automatic :boolean;
  ybayroff2 : double;

begin
  automatic:=stackmenu1.bayer_pattern1.Text='auto';
  if automatic then
    pattern:=bayerpat {from fits header or RGGB if not specified}
  else
    pattern:=stackmenu1.bayer_pattern1.text;

  if pattern=bayer_pattern[2]{'RGGB'} then begin result:=2; {offsetx:=1; offsety:=0;} end {ASI294, ASI071, most common pattern}
  else
  if pattern=bayer_pattern[0]{'GRBG'} then begin result:=0  {offsetx:=0; offsety:=0;} end {ASI1600MC}
  else
  if pattern=bayer_pattern[1]{'BGGR'} then begin result:=1  {offsetx:=0; offsety:=1;} end
  else
  if pattern=bayer_pattern[3]{'GBRG'} then begin result:=3; {offsetx:=1; offsety:=1;} end
  else
  result:=2;{empthy no bayer pattern, take default RGGB}

 {corrections for xbayroff,ybayroff, TOP-DOWN}
  ybayroff2:=ybayroff;
  if pos('BOT', roworder)>0 then
                    ybayroff2:=ybayroff2+1;{'BOTTOM-UP'= lower-left corner first in the file. or 'TOP-DOWN'= top-left corner first in the file.(default)}

  if odd(round(xbayroff)) then
  begin
    if result=2 then result:=0 else
    if result=0 then result:=2 else
    if result=1 then result:=3 else
    if result=3 then result:=1; {shifted bayer pattern due to flip or sub section}
  end;

  if odd(round(ybayroff2)) then
  begin
    if result=1 then result:=0 else
    if result=0 then result:=1 else
    if result=3 then result:=2 else
    if result=2 then result:=3; {shifted bayer pattern due to flip or sub section}
  end;

  bayerpattern_final:=result; {store for global use}
end;

procedure demosaic_bayer(var img: image_array); {convert OSC image to colour}
begin
  if stackmenu1.bayer_pattern1.Text='' then memo2_message('█ █ █ █ █ █ Update required. Please test and set Bayer pattern in tab "Stack method"! █ █ █ █ █ █ ');
  if pos('AstroC',stackmenu1.demosaic_method1.text)<>0  then
  begin
    if datamax_org>16384 then demosaic_astroC_bilinear_interpolation(img,65535 div 2,get_demosaic_pattern){16 bit image. Make from sensor bayer pattern the three colors}
    else
    if datamax_org>4096 then demosaic_astroC_bilinear_interpolation(img,16383 div 2,get_demosaic_pattern){14 bit image. Make from sensor bayer pattern the three colors}
    else
    demosaic_astroC_bilinear_interpolation(img,4095 div 2,get_demosaic_pattern){12 bit image. Make from sensor bayer pattern the three colors}
  end
  else
  if pos('Simple',stackmenu1.demosaic_method1.text)<>0  then {}
    demosaic_astrosimple(img,get_demosaic_pattern){make from sensor bayer pattern the three colors}
  else
  if pos('Bilinear',stackmenu1.demosaic_method1.text)<>0  then {use Bilinear interpolation}
    demosaic_bilinear_interpolation(img,get_demosaic_pattern){make from sensor bayer pattern the three colors}
  else
  if pos('AstroM',stackmenu1.demosaic_method1.text)<>0  then {}
    demosaic_astroM_bilinear_interpolation(img,get_demosaic_pattern){make from sensor bayer pattern the three colors}
  else
  if pos('X-',stackmenu1.bayer_pattern1.Text)<>0  then {}
     demosaic_x_trans(img){make from Fuji X-trans three colors}
  else
    demosaic_Malvar_He_Cutler(img,stackmenu1.bayer_pattern1.itemindex);{make from sensor bayer pattern the three colors}
end;

procedure demosaic_advanced(var img : image_array);{demosaic img}
begin
  demosaic_bayer(img);
  memo2_message('De-mosaic bayer pattern used '+bayer_pattern[bayerpattern_final]);

  if ({(stackmenu1.make_osc_color1.checked) and} (stackmenu1.osc_auto_level1.checked)) then
  begin
    memo2_message('Adjusting colour levels as set in tab "stack method"');
    stackmenu1.auto_background_level1Click(nil);
    apply_factors;{histogram is after this action invalid}
    stackmenu1.reset_factors1Click(nil);{reset factors to default}
    use_histogram(img,true {update}); {plot histogram in colour, set sliders}
  if stackmenu1.osc_colour_smooth1.checked then
  begin
    memo2_message('Applying colour-smoothing filter image as set in tab "stack method". Factors are set in tab "pixel math 1"');
    smart_colour_smooth(img,strtofloat2(stackmenu1.osc_smart_smooth_width1.text),strtofloat2(stackmenu1.osc_smart_colour_sd1.text),false {get  hist});{histogram doesn't needs an update}
  end;
  end
  else
  begin
    memo2_message('Adjusting colour levels and colour smooth are disabled. See tab "stack method"');
    use_histogram(img,true {update}); {plot histogram in colour, set sliders}
  end;
end;


procedure HSV2RGB(h {0..360}, s {0..1}, v {0..1} : single; out r,g,b: single); {HSV to RGB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
var
    h2,h2mod2,m,c,x: single;
begin
  if s=0 then begin r:=v; g:=v;  b:=v; end
  else
  begin
    c:=v*s;{chroma}
    h2:=h/60;
    h2mod2:=h2-2*trunc(h2/2);{h2 mod 2 for floats}
    x:=c*(1-abs((h2mod2)-1));
    if h2<1 then  begin r:=c; g:=x; b:=0; end
    else
    if h2<2 then  begin r:=x; g:=c; b:=0; end
    else
    if h2<3 then  begin r:=0; g:=c; b:=x; end
    else
    if h2<4 then  begin r:=0; g:=x; b:=c; end
    else
    if h2<5 then  begin r:=x; g:=0; b:=c; end
    else
                 begin r:=c; g:=0; b:=x; end;

    m:=v-c;

    r:=r+m;
    g:=g+m;
    b:=b+m;
  end;
end; { HSV2RGB}

procedure RGB2HSV(r,g,b : single; out h {0..360}, s {0..1}, v {0..1}: single);{RGB to HSVB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
var
   rgbmax,rgbmin :single;
begin

  rgbmax := Max(R, Max(G, B));
  rgbmin := Min(R, Min(G, B));

  if rgbmax = rgbmin then
    H := 0
  else
  begin
    if r = rgbmax then H :=60*(g - b) / (rgbmax - rgbmin)
    else
    if g = rgbmax then H :=60*(2 + (b - r) / (rgbmax - rgbmin))
    else
    H := 60*(4 + (r- g) / (rgbmax - rgbmin));

    if H<0 then h:=h+360;
  end;

  if rgbmax=0 then s:=0
  else
  s:=(rgbmax-rgbmin)/rgbmax;{saturation}

  v:=rgbmax;
end;

procedure plot_fits(img:timage; center_image,show_header:boolean);
type

  PRGBTripleArray = ^TRGBTripleArray; {for fast pixel routine}
  {$ifdef mswindows}
  TRGBTripleArray = array[0..trunc(bufwide/3)] of TRGBTriple; {for fast pixel routine}
  {$else} {unix}
  TRGBTripleArray = array[0..trunc(bufwide/3)] of tagRGBQUAD; {for fast pixel routine}
  {$endif}

var
   i,j,col,col_r,col_g,col_b :integer;
   colrr,colgg,colbb,luminance, luminance_stretched,factor, largest, sat_factor,h,s,v: single;
    pixelrow: PRGBTripleArray;{for fast pixel routine}
   Bitmap  : TBitmap;{for fast pixel routine}
   Save_Cursor:TCursor;

begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  img.visible:=true;
  mainwindow.memo1.visible:=show_header;{start updating memo1}

  Bitmap := TBitmap.Create;
  TRY
    WITH Bitmap DO
    BEGIN
      Width := width2;
      Height := height2;
        // Unclear why this must follow width/height to work correctly.
        // If PixelFormat precedes width/height, bitmap will always be black.
      Bitmap.PixelFormat := pf24bit;
    END;
    except;
  end;

  sat_factor:=1-mainwindow.saturation_factor_plot1.position/10;

  if pos('S',calstat)>0 then
                    mainwindow.shape_alignment_marker1.visible:=false; {hide shape if stacked image is plotted}

  cblack:=mainwindow.minimum1.position;
  cwhite:=mainwindow.maximum1.position;
  if cwhite<=cblack then cwhite:=cblack+1;

  for i:=0 to height2-1 do
  begin
    pixelrow := Bitmap.ScanLine[(height2-1)-i];{height2-1)-i, FITS count from bottom, windows from top}
    for j:=0 to width2-1 do
    begin

      col:=round(img_loaded[0,j,i]);
      colrr:=(col-cblack)/(cwhite-cblack);{scale to 1}

      if naxis3>=2 then {at least two colours}
      begin
        col:=round(img_loaded[1,j,i]);
        colgg:=(col-cblack)/(cwhite-cblack);{scale to 1}
      end
      else
      colgg:=colrr;

      if naxis3>=3 then {at least three colours}
      begin
        col:=round(img_loaded[2,j,i]);
        colbb:=(col-cblack)/(cwhite-cblack);{scale to 1}

        if sat_factor<>1 then {adjust saturation}
        begin  {see same routine as stretch_img}
          RGB2HSV(colrr,colgg,colbb,h,s,v);
          HSV2RGB(h,s*sat_factor,v,colrr,colgg,colbb);{increase saturation}
        end;
      end
      else
      colbb:=colrr;

      if colrr<=0.00000000001 then colrr:=0.00000000001;{after rgb2hsv}
      if colgg<=0.00000000001 then colgg:=0.00000000001;
      if colbb<=0.00000000001 then colbb:=0.00000000001;


      {find brightest colour and resize all if above 1}
      largest:=colrr;
      if colgg>largest then largest:=colgg;
      if colbb>largest then largest:=colbb;
      if largest>1 then {clamp to 1 but preserve colour, so ratio r,g,b}
      begin
        colrr:=colrr/largest;
        colgg:=colgg/largest;
        colbb:=colbb/largest;
        largest:=1;
      end;

      if stretch_on then {Stretch luminance only. Keep RGB ratio !!}
      begin
        luminance:=(colrr+colgg+colbb)/3;{luminance in range 0..1}
        luminance_stretched:=stretch_c[trunc(32768*luminance)];
        factor:=luminance_stretched/luminance;
        if factor*largest>1 then factor:=1/largest; {clamp again, could be higher then 1}
        col_r:=round(colrr*factor*255);{stretch only luminance but keep rgb ratio!}
        col_g:=round(colgg*factor*255);{stretch only luminance but keep rgb ratio!}
        col_b:=round(colbb*factor*255);{stretch only luminance but keep rgb ratio!}
      end
      else
      begin
        col_r:=round(255*colrr);
        col_g:=round(255*colgg);
        col_b:=round(255*colbb);
      end;

     {$ifdef mswindows}
        pixelrow[j].rgbtRed  := col_r;
        pixelrow[j].rgbtGreen:= col_g;
        pixelrow[j].rgbtBlue := col_b;{fast pixel write routine }
     {$endif}
     {$ifdef darwin} {MacOS}
      pixelrow[j].rgbreserved:= col_b; {different color arrangment in Macos !!!!!}
      pixelrow[j].rgbRed  := col_g;
      pixelrow[j].rgbGreen:= col_r;
     {$else}
     {$ifdef linux}
        pixelrow[j].rgbRed  := col_r;
        pixelrow[j].rgbGreen:= col_g;
        pixelrow[j].rgbBlue := col_b;
      {$endif}
      {$endif}
    end;{j}
  end; {i}

  img.picture.Graphic := Bitmap; {show image}
  Bitmap.Free;

  img.Picture.Bitmap.Transparent := True;
  img.Picture.Bitmap.TransparentColor := clblack;

  if center_image then {image new of resized}
  begin
    img.top:=0;
    img.height:=mainwindow.panel1.height;

    img.left:=0;

  end;
  img.width:=round(img.height*width2/height2); {lock image aspect always for case a image with a different is clicked on in stack menu}


  if img=mainwindow.image1 then {plotting to mainwindow?}
  begin

    {next two could be written more efficient using previous bitmap}
    if mainwindow.Flip_horizontal1.Checked then mainwindow.Flip_horizontal1Click(nil);
    if mainwindow.flip_vertical1.Checked then mainwindow.flip_vertical1Click(nil);

    plot_north; {draw arrow or clear indication position north depending on value cd1_1}
    if mainwindow.add_marker_position1.checked then
      mainwindow.add_marker_position1.checked:=place_marker_radec(marker_position);{place a marker}

    mainwindow.statusbar1.panels[5].text:=inttostr(width2)+' x '+inttostr(height2)+' x '+inttostr(naxis3)+'   '+inttostr(nrbits)+' BPP';{give image dimensions and bit per pixel info}
    update_statusbar_section5;{update section 5 with image dimensions in degrees}
    mainwindow.statusbar1.panels[7].text:=''; {2020-2-15 moved from load_fits to plot_image. Clear any outstanding error}

    update_menu(true);{2020-2-15 moved from load_fits to plot_image.  file loaded, update menu for fits}
  end;

  {do refresh at the end for smooth display, especially for blinking }
  img.refresh;{important, show update}

  quads_displayed:=false; {displaying quads doesn't require a screen refresh}

  Screen.cursor:= Save_Cursor;
end;


function load_PPM_PGM_PFM(filen:string; var img_loaded2: image_array) : boolean;{load PPM (color),PGM (gray scale)file or PFM color}
var
   i,j, reader_position  : integer;
   aline,w1,h1,bits,comm  : ansistring;
   ch                : ansichar;
   rgb32dummy        : byteXXXX3;
   rgb16dummy        : byteXX3;
   rgbdummy          : byteX3;
   err,err2,err3,package  : integer;
   comment,color7,pfm,expdet,timedet,isodet,instdet  : boolean;
   range, jd2        : double;

var
   x_longword  : longword;
   x_single    : single absolute x_longword;{for conversion 32 bit "big-endian" data}

     procedure close_fits_file; inline;
     begin
        Reader.free;
        TheFile3.free;
     end;

begin
  naxis:=0; {0 dimensions}
  result:=false; {assume failure}

  try
    TheFile3:=tfilestream.Create( filen, fmOpenRead or fmShareDenyWrite);
  except
     beep;
     mainwindow.statusbar1.panels[7].text:=('Error, accessing the file!');
     mainwindow.error_label1.caption:=('Error, accessing the file!');
     mainwindow.error_label1.visible:=true;
     exit;
  end;
  mainwindow.memo1.visible:=false;{stop visualising memo1 for speed. Will be activated in plot routine}
  mainwindow.memo1.clear;{clear memo for new header}

  Reader := TReader.Create (theFile3,$4000);{number of hnsky records}
  {thefile3.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}

  {Reset variables}
  crota2:=99999;{just for the case it is not available, make it later zero}
  crota1:=99999;
  ra0:=0;
  dec0:=0;
  cdelt1:=0;
  cdelt2:=0;
  xpixsz:=0;
  ypixsz:=0;
  focallen:=0;
  subsamp:=1;{just for the case it is not available}
  cd1_1:=0;
  cd1_2:=0;
  cd2_1:=0;
  cd2_2:=0;
  date_obs:=''; date_avg:='';date_avg:='';ut:=''; pltlabel:=''; plateid:=''; telescop:=''; instrum:='';  origin:=''; object_name:='';{clear}
  sitelat:='';{Observatory latitude}
  sitelong:='';{Observatory longitude}

  naxis:=1;
  naxis3:=1;

  filter_name:='';
  calstat:='';{indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected. Example value DFB}
  imagetype:='';
  xbinning:=1;{default}
  ybinning:=1;
  exposure:=0;
  set_temperature:=999;

  x_coeff[0]:=0; {reset DSS_polynomial, use for check if there is data}
  y_coeff[0]:=0;

  a_order:=0;{Simple Imaging Polynomial use by astrometry.net, if 2 then available}

  bayerpat:='T';{assume image is from Raw DSLR image}
  xbayroff:=0;{offset to used to correct BAYERPAT due to flipping}
  ybayroff:=0;{offset to used to correct BAYERPAT due to flipping}
  roworder:='';{'BOTTOM-UP'= lower-left corner first in the file.  or 'TOP-DOWN'= top-left corner first in the file.}

  flux_magn_offset:=0;{factor to calculate magnitude from flux, new file so set to zero}
  annotated:=false; {any annotation in the file}
  extend:=0;  {no extensions in the file, 1 is ascii_table, 2 bintable}
  gain:=999;{assume no data available}


  I:=0;
  reader_position:=0;


  aline:='';
  try
    for i:=0 to 2 do begin reader.read(ch,1); aline:=aline+ch; inc(reader_position,1);end;
    if ((aline<>'P5'+#10) and (aline<>'P6'+#10) and (aline<>'PF'+#10) and (aline<>'Pf'+#10)) then
    begin
      close_fits_file;
      beep;
      mainwindow.statusbar1.panels[7].text:=('Error loading PGM/PPM/PFM file!! Keyword P5, P6, PF, Pf not found.');
      mainwindow.error_label1.caption:=('Error loading PGM/PPM/PFM file!! Keyword P5, P6, PF. Pf not found.');
      mainwindow.error_label1.visible:=true;
      fits_file:=false;
      exit;
    end ;{should start with P6}

    pfm:=false;
    if aline='P5'+#10 then color7:=false {gray scale image}
    else
    if aline='P6'+#10 then color7:=true  {colour scale image}
    else
    if aline='PF'+#10 then begin color7:=true; pfm:=true; end  {PFM colour scale image, photoshop export float 32 bit}
    else
    if aline='Pf'+#10 then begin color7:=false; pfm:=true; end;  {PFM colour scale image, photoshop export float 32 bit grayscale}

    i:=0;
    repeat {read header}
      comment:=false;
      expdet:=false;
      timedet:=false;
      aline:='';
      comm:='';
      repeat
        reader.read(ch,1);
        if ch='#' then comment:=true;{reading comment}
        if comment then {this works only for files produced by special custom DCRAW version. Code for identical Libraw modification proposed at Github}
        begin
          if ch in [';','#',' ',char($0A)]=false then comm:=comm+ch
          else
          begin
            if expdet then begin exposure:=strtofloat2(comm);expdet:=false; end;{get exposure time from comments,special dcraw 0.9.28dev1}
            if isodet then begin gain:=strtofloat2(comm);isodet:=false; end;{get iso speed as gain}
            if instdet then begin instrum:=comm;instdet:=false;end;{camera}
            if timedet then
            begin
              JD2:=2440587.5+ strtoint(comm)/(24*60*60);{convert to Julian Day by adding factor. Unix time is seconds since 1.1.1970}
              date_obs:=JdToDate(jd2);
              timedet:=false;
            end;{get date from comments}
            comm:='';{clear for next keyword}
          end;
          if comm='EXPTIME=' then begin expdet:=true; comm:=''; end else
          if comm='TIMESTAMP=' then begin timedet:=true; comm:=''; end else
          if comm='ISOSPEED=' then begin isodet:=true; comm:=''; end else
          if comm='MODEL=' then begin instdet:=true; comm:=''; end; {camera make}
        end
        else
        if ord(ch)>32 then aline:=aline+ch;; {DCRAW write space #20 between width&length, Photoshop $0a}

        if ord(ch)=$0a then comment:=false;{complete comment read}
        inc(reader_position,1)
      until ( ((comment=false) and (ord(ch)<=32)) or (reader_position>200)) ;{ignore comments, with till text is read and escape if too long}
      if (length(aline)>1){no comments} then {read header info}
      begin
        inc(i);{useful header line}
        if i=1 then w1:=aline {width}
        else
        if i=2 then h1:=aline {height}
        else
        bits:=aline;
      end;
    until ((i>=3) or (reader_position>200)) ;

    val(w1,width2,err);
    val(h1,height2,err2);

    val(bits,range,err3);{number of bits}

    nrbits:=round(range);

    if pfm then begin nrbits:=-32; datamax_org:=$FFFF;end     {little endian PFM format. If nrbits=-1 then range 0..1. If nrbits=+1 then big endian with range 0..1 }
    else
    if nrbits=65535 then begin nrbits:=16; datamax_org:=$FFFF;end
    else
    if nrbits=255 then begin nrbits:=8;datamax_org:=$FF; end
    else
      err3:=999;

    if ((err<>0) or (err2<>0) or (err3<>0)) then
    begin
      beep;
      mainwindow.statusbar1.panels[7].text:=('Incompatible PPM/PGM/PFM file !!');
      mainwindow.error_label1.caption:=('Incompatible PPM/PGM/PFM file !!');
      mainwindow.error_label1.visible:=true;
      close_fits_file;
      fits_file:=false;
      exit;
    end; {should contain 255 or 65535}

    datamin_org:=0;
    fits_file:=true;

    cblack:=datamin_org;{for case histogram is not called}
    cwhite:=datamax_org;

    if color7 then
    begin
       package:=round((abs(nrbits)*3/8));{package size, 3 or 6 bytes}
       naxis3:=3; {NAXIS3 number of colors}
       naxis:=3; {number of dimensions}
    end
    else
    begin {gray image without bayer matrix applied}
      package:=round((abs(nrbits)/8));{package size, 1 or 2 bytes}
      naxis3:=1; {NAXIS3 number of colors}
      naxis:=2;{number of dimensions}
    end;
    i:=round(bufwide/package);
    if width2>i then
    begin
      beep;
      textout(mainwindow.image1.canvas.handle,30,30,'Too large FITS file !!!!!',25);
      close_fits_file;
      exit;
    end
    else
    begin {not too large}
      setlength(img_loaded2,naxis3,width2,height2);
      begin
        For i:=0 to height2-1 do
        begin
          try reader.read(fitsbuffer,width2*package);except; end; {read file info}

          for j:=0 to width2-1 do
          begin
            if color7=false then {gray scale without bayer matrix applied}
            begin
              if nrbits=8 then  {8 BITS, mono 1x8bits}
                img_loaded2[0,j,i]:=fitsbuffer[j]{RGB fits with naxis1=3, treated as 48 bits coded pixels}
              else
              if nrbits=16 then {big endian integer}
                img_loaded2[0,j,i]:=swap(fitsbuffer2[j])
              else {PFM 32 bits grayscale}
              if pfm then
              begin
                if range<0 then {little endian floats}
                  img_loaded2[0,j,i]:=fitsbuffersingle[j]*65535/(-range) {PFM little endian float format. if nrbits=-1 then range 0..1. If nrbits=+1 then big endian with range 0..1 }
                else
                begin {big endian floats}
                  x_longword:=swapendian(fitsbuffer4[j]);{conversion 32 bit "big-endian" data, x_single  : single absolute x_longword; }
                  img_loaded2[0,j,i]:=x_single*65535/range;
                end;
              end;
            end
            else
            begin
              if nrbits=8 then {24 BITS, colour 3x8bits}
              begin
                rgbdummy:=fitsbufferRGB[j];{RGB fits with naxis1=3, treated as 48 bits coded pixels}
                img_loaded2[0,j,i]:=rgbdummy[0];{store in memory array}
                img_loaded2[1,j,i]:=rgbdummy[1];{store in memory array}
                img_loaded2[2,j,i]:=rgbdummy[2];{store in memory array}
              end
              else
              if nrbits=16 then {48 BITS colour, 3x16 big endian}
              begin {48 bits}
                rgb16dummy:=fitsbufferRGB16[j];{RGB fits with naxis1=3, treated as 48 bits coded pixels}
                img_loaded2[0,j,i]:=swap(rgb16dummy[0]);{store in memory array}
                img_loaded2[1,j,i]:=swap(rgb16dummy[1]);{store in memory array}
                img_loaded2[2,j,i]:=swap(rgb16dummy[2]);{store in memory array}
              end
              else
              if pfm then
              begin {PFM little-endian float 3x 32 bit colour}
                if range<0 then {little endian}
                begin
                  rgb32dummy:=fitsbufferRGB32[j];{RGB fits with naxis1=3, treated as 96 bits coded pixels}
                  img_loaded2[0,j,i]:=(rgb32dummy[0])*65535/(-range);{store in memory array}
                  img_loaded2[1,j,i]:=(rgb32dummy[1])*65535/(-range);{store in memory array}
                  img_loaded2[2,j,i]:=(rgb32dummy[2])*65535/(-range);{store in memory array}
                end
                else
                begin {PFM big-endian float 32 bit colour}
                  x_longword:=swapendian(fitsbuffer4[j*3]);
                  img_loaded2[0,j,i]:=x_single*65535/(range);
                  x_longword:=swapendian(fitsbuffer4[j*3+1]);
                  img_loaded2[1,j,i]:=x_single*65535/(range);
                  x_longword:=swapendian(fitsbuffer4[j*3+2]);
                  img_loaded2[2,j,i]:=x_single*65535/(range);
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  except;
    close_fits_file;
    exit;
  end;

  update_menu(true);{file loaded, update menu for fits}

  unsaved_import:=false;{file is available for astrometry.net}

  close_fits_file;
  result:=true;{succes}

  for j:=0 to 10 do {create an header with fixed sequence}
    if ((j<>5) or  (naxis3<>1)) then {skip naxis3 for mono images}
        mainwindow.memo1.lines.add(head1[j]); {add lines to empthy memo1}
  mainwindow.memo1.lines.add(head1[27]); {add end}

  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS   =',' / Number of dimensions                           ' ,naxis);{2 for mono, 3 for colour}
  update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);
  if naxis3<>1 then
    update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,naxis3);
  update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer('DATAMAX =',' / Maximum data value                           ' ,round(datamax_org));

  if exposure<>0 then   update_float('EXPTIME =',' / duration of exposure in seconds                ' ,exposure);
  if gain<>999 then     update_float('GAIN    =',' / iso speed                                      ' ,gain);

  if date_obs<>'' then update_text   ('DATE-OBS=',#39+date_obs+#39);
  if instrum<>''  then update_text   ('INSTRUME=',#39+INSTRUM+#39);

  update_text   ('BAYERPAT=',#39+'T'+#39+'                  / Unknown Bayer color pattern                  ');

  update_text   ('COMMENT 1','  Written by ASTAP, Astrometric STAcking Program. www.hnsky.org');
end;


procedure read_keys_memo;
var
  key      : string;
  count1   : integer;
  ra2,dec2 : double;
     function read_float(aline :string): double;
     var
       err: integer;
     begin
       val(aline,result,err);
     end;
begin
  crota2:=99999;{just for the case it is not available, make it later zero}
  crota1:=99999;
  ra0:=0;
  dec0:=0;
  cdelt1:=0;
  cdelt2:=0;
  xpixsz:=0;
  ypixsz:=0;
  focallen:=0;
  subsamp:=1;{just for the case it is not available}
  cd1_1:=0;{just for the case it is not available}
  cd1_2:=0;{just for the case it is not available}
  cd2_1:=0;{just for the case it is not available}
  cd2_2:=0;{just for the case it is not available}
  date_obs:='';date_avg:=''; ut:=''; pltlabel:=''; plateid:=''; telescop:=''; instrum:='';  origin:=''; object_name:='';{clear}
  sitelat:=''; sitelong:='';
  filter_name:='';
  calstat:='';{indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected, S stacked. Example value DFB}
  imagetype:='';
  xbinning:=1;{normal}
  ybinning:=1;
  exposure:=0;
  set_temperature:=999;
  x_coeff[0]:=0; {reset DSS_polynomial, use for check if there is data}
  y_coeff[0]:=0;
  a_order:=0; {reset SIP_polynomial, use for check if there is data}


  count1:=mainwindow.Memo1.Lines.Count-1-1;
  while count1>1 do {read bare minimum keys since TIFF is not required for stacking}
  begin
    key:=copy(mainwindow.Memo1.Lines[count1],1,9);
    if key='CD1_1   =' then cd1_1:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='CD1_2   =' then cd1_2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='CD2_1   =' then cd2_1:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='CD2_2   =' then cd2_2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));

    if key='CRVAL1  =' then ra2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='CRVAL2  =' then dec2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='RA      =' then ra2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='DEC     =' then dec2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    count1:=count1-1;
  end;
  if ((ra2<>999) and (dec2<>999)) then {data available}
  begin
    ra0:=ra2*pi/180; {degrees -> radians}
    dec0:=dec2*pi/180;
    mainwindow.ra1.text:=prepare_ra(ra0,' ');{show center of image}
    mainwindow.dec1.text:=prepare_dec(dec0,' ');
  end;
  if cd1_1<>0 then new_to_old_WCS;
end;

function load_TIFFPNGJPEG(filen:string; var img_loaded2: image_array) : boolean;{load 8 or 16 bit TIFF, PNG, JPEG, BMP image}
var
  i,j   : integer;
  jd2   : double;
  image: TFPCustomImage;
  reader: TFPCustomImageReader;
  tiff, png,jpeg,colour,saved_header  : boolean;
  ext,descrip   : string;
begin
  naxis:=0; {0 dimensions}
  result:=false; {assume failure}
  tiff:=false;
  jpeg:=false;
  png:=false;
  saved_header:=false;
  ext:=uppercase(ExtractFileExt(filen));
  try
    Image := TFPMemoryImage.Create(10, 10);

    if ((ext='.TIF') or (ext='.TIFF')) then
    begin
       Reader :=  TFPReaderTIFF.Create;
       tiff:=true;
    end
    else
    if ext='.PNG' then begin
      Reader :=  TFPReaderPNG.Create;
      png:=true;
    end
    else
    if ((ext='.JPG') or (ext='.JPEG')) then
    begin
      Reader :=  TFPReaderJPEG.Create;
      jpeg:=true;
    end
    else
    if ext='.BMP' then Reader :=  TFPReaderBMP.create
    else
    //  if ((ext='.PPM') or (ext='.PGM')) then
    //    Reader :=  TFPReaderPNM.Create else {not used since comment have to be read}
    exit;

    Image.LoadFromFile(filen, Reader);
  except
     beep;
     mainwindow.statusbar1.panels[7].text:=('Error, accessing the file!');
     mainwindow.error_label1.caption:=('Error, accessing the file!');
     mainwindow.error_label1.visible:=true;
     exit;
  end;

  {$IF FPC_FULLVERSION >= 30200} {FPC3.2.0}
  colour:=true;
  if ((tiff) and (Image.Extra[TiffGrayBits]<>'0')) then colour:=false; {image grayscale?}
  if ((png) and (TFPReaderPNG(reader).grayscale)) then colour:=false; {image grayscale?}
  if ((jpeg) and (TFPReaderJPEG(reader).grayscale)) then colour:=false; {image grayscale?}
  {BMP always colour}
  {$else} {for older compiler versions}
  colour:=false;
  with image do {temporary till grayscale is implemented in fcl-image}
  begin
    i:=0;
    j:=height div 2;
    while ((colour=false) and (i<width)) do {test horizontal line}
    begin
      colour:=((Colors[i,j].red<>Colors[i,j].green) or  (Colors[i,j].red<>Colors[i,j].blue));
      inc(i);
    end;
    i:=width div 2;
    j:=0;
    while ((colour=false) and (j<height)) do {test vertical line}
    begin
      colour:=((Colors[i,j].red<>Colors[i,j].green) or  (Colors[i,j].red<>Colors[i,j].blue));
      inc(j);
    end;
  end;
  {$ENDIF}

  if colour=false then
  begin
     naxis:=2;
     naxis3:=1;
  end
  else
  begin
    naxis:=3; {three dimensions, x,y and 3 colours}
    naxis3:=3;
  end;

  mainwindow.memo1.visible:=false;{stop visualising memo1 for speed. Will be activated in plot routine}
  mainwindow.memo1.clear;{clear memo for new header}

  {Reset variables}
  crota2:=99999;{just for the case it is not available, make it later zero}
  crota1:=99999;
  ra0:=0;
  dec0:=0;
  cdelt1:=0;
  cdelt2:=0;
  xpixsz:=0;
  ypixsz:=0;
  focallen:=0;
  subsamp:=1;{just for the case it is not available}
  cd1_1:=0;
  cd1_2:=0;
  cd2_1:=0;
  cd2_2:=0;
  date_obs:=''; date_avg:='';ut:=''; pltlabel:=''; plateid:=''; telescop:=''; instrum:='';  origin:=''; object_name:='';{clear}
  sitelat:=''; sitelong:='';
  filter_name:='';
  calstat:='';{indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected. Example value DFB}
  imagetype:='';
  xbinning:=1;{default}
  ybinning:=1;
  exposure:=0;
  set_temperature:=999;

  flux_magn_offset:=0;{factor to calculate magnitude from flux, new file so set to zero}
  annotated:=false; {any annotation in the file}
  extend:=0; {no extensions in the file, 1 is ascii_table, 2 bintable}


  {set data}
  fits_file:=true;
  nrbits:=16;
  datamin_org:=0;
  datamax_org:=$FFFF;
  cblack:=datamin_org;{for case histogram is not called}
  cwhite:=datamax_org;


  width2:=image.width;
  height2:=image.height;
  setlength(img_loaded2,naxis3,width2,height2);

  if naxis3=3 then
  begin
    For i:=0 to height2-1 do
      for j:=0 to width2-1 do
      begin
        img_loaded2[0,j,height2-1-i]:=image.Colors[j,i].red;
        img_loaded2[1,j,height2-1-i]:=image.Colors[j,i].green;
        img_loaded2[2,j,height2-1-i]:=image.Colors[j,i].blue;
      end;
  end
  else
  begin
    For i:=0 to height2-1 do
      for j:=0 to width2-1 do
        img_loaded2[0,j,height2-1-i]:=image.Colors[j,i].red;
  end;

  if tiff then
  begin
    descrip:=image.Extra['TiffImageDescription']; {restore full header in TIFF !!!}
  end;
  if pos('SIMPLE  =',descrip)>0 then
  begin
    mainwindow.memo1.text:=descrip;
    read_keys_memo;
    saved_header:=true;
  end
  else {no fits header in tiff file available}
  begin
    for j:=0 to 10 do {create an header with fixed sequence}
      if ((j<>5) or  (naxis3<>1)) then {skip naxis3 for mono images}
        mainwindow.memo1.lines.add(head1[j]); {add lines to empthy memo1}
    mainwindow.memo1.lines.add(head1[27]); {add end}
    if descrip<>'' then add_long_comment(descrip);{add TIFF describtion}
  end;

  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS   =',' / Number of dimensions                           ' ,naxis);{2 for mono, 3 for colour}
  update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);
  update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer('DATAMAX =',' / Maximum data value                             ' ,round(datamax_org));

  if saved_header=false then {saved header in tiff is not restored}
  begin
    JD2:=2415018.5+(FileDateToDateTime(fileage(filen))); {fileage ra, convert to Julian Day by adding factor. filedatatodatetime counts from 30 dec 1899.}
    date_obs:=JdToDate(jd2);
    update_text ('DATE-OBS=',#39+date_obs+#39);{give start point exposures}
  end;

  update_text   ('COMMENT 1','  Written by ASTAP, Astrometric STAcking Program. www.hnsky.org');

  { Clean up! }
  image.Free;
  reader.free;
  unsaved_import:=true;{file is not available for astrometry.net}
  result:=true;{succes}

end;

procedure get_hist(colour:integer; img :image_array);
var
     i,j,col,his_total,count, width5, height5,offsetW,offsetH : integer;
     total_value                                : double;
begin
  if colour+1>length(img) then {robust detection, case binning is applied and image is mono}
    colour:=0; {used red only}

  for i:=0 to 65535 do
    histogram[colour,i] := 0;{clear histogram of specified colour}

  his_total:=0;
  total_value:=0;
  count:=1;{prevent divide by zero}
  width5:=Length(img[0]);    {width}
  height5:=Length(img[0][0]); {height}

  offsetW:=trunc(width5*0.042); {if Libraw is used, ignored unused sensor areas up to 4.2%}
  offsetH:=trunc(height5*0.015); {if Libraw is used, ignored unused sensor areas up to 1.5%}


  For i:=0+offsetH to height5-1-offsetH do
  begin
    for j:=0+offsetW to width5-1-offsetW do
    begin
      col:=round(img[colour,j,i]);{red}
      if ((col>=1) and (col<65000)) then {ignore black overlap areas and bright stars}
      begin
        inc(histogram[colour,col],1);{calculate histogram}
        his_total:=his_total+1;
        total_value:=total_value+col;
        inc(count);
      end;
    end;{j}
  end; {i}

  if colour=0 then his_total_red:=his_total
  else
  if colour=1 then his_total_green:=his_total
  else
  his_total_blue:=his_total;

  his_mean[colour]:=round(total_value/count);

end;

procedure use_histogram(img: image_array; update_hist: boolean);{calculate histogram}
var
  i, minm,maxm,max_range, value1,oldvalue1,count,countR,countG,countB,stopXpos,Xpos,steps,max_color,histo_peakR,number_colors  : integer;
  above, above_R          : double;
  Save_Cursor:TCursor;

begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  number_colors:=length(img);

  if update_hist then {get_hist}
  begin
    get_hist(0, img);
    if number_colors>1 then get_hist(1, img);{green}
    if number_colors>2 then get_hist(2, img);{blue}
  end;

  max_range:=round(min(datamax_org,65535)); {measured while loading, Prevent runtime error if datamax_org>65535}

  case mainwindow.range1.itemindex of
    -1,0,1: above_R:=0.001;{low range}
       2,3: above_R:=0.003; {medium range}
       4,5: above_R:=0.01;  {high range}
       6,7: begin minm:=round(datamin_org);maxm:=round(datamax_org)end;{6=range and 7=manual}
       8: begin minm:=round(max_range*0.95); maxm:=round(max_range);  end;{Show saturation}
       9: begin minm:=round(datamin_org); maxm:=round(datamax_org);   end;{max range, use datamin/max}
  end;

  if mainwindow.range1.itemindex<=5 then {auto detect mode}
  begin
    minm:=0;
    maxm:=0;
    above:=0;

    {calculate peak values }
    histo_peakR:=-99999999;
    for i := 1 to max_range-1{65535} do
      if histogram[0,i]>histo_peakR then begin histo_peakR:=histogram[0,i]; histo_peak_position:=i;{find most common value = background.}end;

    i:=histo_peak_position;{typical background position in histogram};
    while ((minm=0) and (i>0)) do
    begin
      dec(i);
      if histogram[0,i]<0.1*histogram[0,histo_peak_position] then minm:=i; {find position with 10% count of histo_peak_position}
    end;

    i:=max_range{65535};
    while ((maxm=0) and (i>minm+1)) do
    begin
       dec(i);
       above:=above+histogram[0,i];
       if above>above_R {0.001}*his_total_red then maxm:=i;
    end;
  end;

  hist_range:=round(min(datamax_org,2*maxm));{adapt histogram range}
  mainwindow.minimum1.max:= max(hist_range,1); {set minimum to 1 to prevent runtime failure for fully black image}
  mainwindow.maximum1.max:= max(hist_range,1);

  if mainwindow.range1.itemindex<>7 then {<> manual}
  begin
    case mainwindow.range1.itemindex of
              1,3,5: mainwindow.minimum1.position:=max(0,round(minm - (maxm-minm)*0.05));{set black at 5%}
              else mainwindow.minimum1.position:=minm;
    end;
    mainwindow.maximum1.position:=maxm;

    mainwindow.maximum1.smallchange:=1+round(maxm/100);
    mainwindow.minimum1.smallchange:=1+round(maxm/100);
    mainwindow.maximum1.largechange:=1+round(maxm/20);
    mainwindow.minimum1.largechange:=1+round(maxm/20);
  end;


  mainwindow.histogram1.canvas.brush.color:=clblack;
  mainwindow.histogram1.canvas.rectangle(-1,-1, mainwindow.histogram1.width+1, mainwindow.histogram1.height+1);
  mainwindow.histogram1.Canvas.Pen.Color := clred;

  stopXpos:=-1;
  oldvalue1:=0;
  countR:=0;
  countG:=0;
  countB:=0;
  count:=0;
  steps:=0;

  for i := 1 to hist_range-1{65535} do {create histogram graph, ignore zero value}
  begin
    countR:=countR+histogram[0,i];{integrate values till new line is drawn}
    if number_colors>1 then countG:=countG+histogram[1,i];
    if number_colors>2 then countB:=countB+histogram[2,i];
    inc(steps,number_colors);

    Xpos:=round(mainwindow.histogram1.width*i/hist_range {65535});
    if Xpos>stopXpos then {new line to be drawn}
    begin
      count:=(countR+countG+countB) div steps;{calculate value per step}

      stopXpos:=Xpos;
      if count<>0 then
      begin
        value1:=round(4*ln(count/3));
        if value1>mainwindow.histogram1.height then value1:=mainwindow.histogram1.height;

        if value1<>oldvalue1 then  {new value, new plot required}
        begin
          oldvalue1:=value1;
          max_color:=countR; if countG>max_color then max_color:=countG; if countB>max_color then max_color:=countB;
          mainwindow.histogram1.Canvas.Pen.Color := rgb(255*countR div max_color,255*countG div max_color,255*countB div max_color);

          moveToex(mainwindow.histogram1.Canvas.handle,Xpos,mainwindow.histogram1.height,nil);
          lineTo(mainwindow.histogram1.Canvas.handle,Xpos ,mainwindow.histogram1.height-value1); {line}
        end;
      end;
      countR:=0;
      countG:=0;
      countB:=0;
      steps:=0;
    end;{new Xpos}
  end;
  Screen.Cursor:=Save_Cursor;
end;


procedure savefits_update_header(filen,filen2:string);{save fits file with update header}
var
  reader_position,I,readsize  : integer;
  TheFile4  : tfilestream;
  fract     : double;
  line0       : ansistring;
  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}
  header    : array[0..2880] of ansichar;


     procedure close_fits_files;
     begin
        Reader.free;
        TheFile3.free;
        TheFile4.free;
     end;

     Function validate_double:double;{read values}
     var t :shortstring;
         r,err : integer;
         x     :double;
     begin
       t:='';
       for r:=I+10 to I+29 do
       if header[r]<>' ' then t:=t+header[r];
       val(t,x,err);
       validate_double:=x;
     end;
begin

  try
    TheFile3:=tfilestream.Create(filen, fmOpenRead or fmShareDenyWrite);
  except
    close_fits_files;
    exit;
  end;
  try
    TheFile4:=tfilestream.Create(filen2, fmcreate );
  except
    close_fits_files;
    exit;
  end;


  Reader := TReader.Create (theFile3,$4000);{number of hnsky records}
  {thefile3.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}
  I:=0;
  reader_position:=0;
  repeat
    try reader.read(header[i],80);except;close_fits_files;end; {read file info, 80 bytes only}
    inc(reader_position,80);
  until (((header[i]='E') and (header[i+1]='N')  and (header[i+2]='D')) or (I>=sizeof(header)-16 ));

  fract:=frac(reader_position/2880);

  if fract<>0 then
  begin
    i:=round((1-fract)*2880);{left part of next 2880 bytes block}
    try reader.read(header[0],i);except;close_fits_files; exit;end; {skip empty part and go to image data}
    inc(reader_position,i);
  end;
  {reader is now at begin of data}

  {write updated header}
  for i:=0 to 79 do empthy_line[i]:=#32;{space}
  i:=0;
  repeat
     if i<mainwindow.memo1.lines.count then
     begin
       line0:=mainwindow.memo1.lines[i];
       while length(line0)<80 do line0:=line0+' ';{guarantee length is 80}
       strpcopy(aline,(copy(line0,1,80)));{copy 80 and not more}
       thefile4.writebuffer(aline,80);{write updated header from memo1.}
     end
     else
     begin
        thefile4.writebuffer(empthy_line,80);{write empthy line}
     end;
     inc(i);
  until ((i>=mainwindow.memo1.lines.count) and (frac(i*80/2880)=0)); {write multiply records 36x80 or 2880 bytes}

  readsize:=2880;
  repeat
     try reader.read(fitsbuffer,readsize);except;end; {read file info IN STEPS OF 2880}
     inc(reader_position,readsize);
     thefile4.writebuffer(fitsbuffer,readsize); {write as bytes. Do not use write size last record is forgotten !!!}
   until (reader_position>=thefile3.size);

  Reader.free;
  TheFile3.free;
  TheFile4.free;
end;

{$ifdef mswindows}
procedure ExecuteAndWait(const aCommando: string;show_console:boolean);
var
  tmpStartupInfo: TStartupInfo;
  tmpProcessInformation: TProcessInformation;
  tmpProgram: String;
  console :longint;

begin
  tmpProgram := trim(aCommando);
  FillChar(tmpStartupInfo, SizeOf(tmpStartupInfo), 0);
  with tmpStartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    wShowWindow := SW_HIDE;
  end;
  if show_console then console:=CREATE_NEW_CONSOLE else console:=CREATE_NO_WINDOW;

  if CreateProcess(nil, pchar(tmpProgram), nil, nil, true, console ,
    nil, nil, tmpStartupInfo, tmpProcessInformation) then
  begin
    // loop every 50 ms
    while WaitForSingleObject(tmpProcessInformation.hProcess, 50) > 0 do
    begin
      Application.ProcessMessages;
    end;
    FileClose(tmpProcessInformation.hProcess); { *Converted from CloseHandle* }
    FileClose(tmpProcessInformation.hThread); { *Converted from CloseHandle* }
  end
  else
  begin
    RaiseLastOSError;
  end;
end;
{$else} {unix}

procedure execute_unix(const execut:string; param: TStringList; show_output: boolean);{execute linux program and report output}
var
  tmpProgram: String;
   F : Text;
   cc:string;

var
  AProcess: TProcess{UTF8};
  Astringlist  : TStringList;
begin
  stackmenu1.Memo2.lines.add('Solver command:' + execut+' '+ param.commatext);
  {activate scrolling Memo3}
  stackmenu1.memo2.SelStart:=Length(stackmenu1.memo2.Lines.Text);
  stackmenu1.memo2.SelLength:=0;

  Application.ProcessMessages;

  AStringList := TStringList.Create;

  AProcess := TProcess{UTF8}.Create(nil);
  AProcess.Executable :=execut;
  AProcess.Parameters:=param;
  AProcess.Options := [{poWaitOnExit,}poUsePipes,poStderrToOutPut]; // + [poWaitOnExit, poUsePipes];
  AProcess.Execute;
  repeat
   begin
     sleep(100);
     if (AProcess.Output<>nil) then
     begin
       if ((show_output) and (AProcess.Output.NumBytesAvailable>0)) then
       begin
         AStringList.LoadFromStream(AProcess.Output);
         stackmenu1.Memo2.lines.add(astringlist.Text);
       end;
     end;
     Application.ProcessMessages;
   end;
  until ((AProcess.Running=false) or  (esc_pressed));
  AProcess.Free;
  AStringList.Free;
end;

procedure execute_unix2(s:string);
var ex :integer;
begin
  ex:=fpsystem(s);
  if ex>3 then showmessage(pchar(wexitStatus));
end;
{$endif}


function StyleToStr(Style: TFontStyles): string;
const
  Chars: array [Boolean] of Char = ('F', 'T');
begin
  SetLength(Result, 4);
  Result[1] := Chars[fsBold in Style];
  Result[2] := Chars[fsItalic in Style];
  Result[3] := Chars[fsUnderline in Style];
  Result[4] := Chars[fsStrikeOut in Style];
end;

function StrToStyle(Str: String): TFontStyles;
begin
  Result := [];
  {T = true, S = false}
  if Str[1] = 'T' then
    Include(Result, fsBold);
  if Str[2] = 'T' then
    Include(Result, fsItalic);
  if Str[3] = 'T' then
    Include(Result, fsUnderLine);
  if Str[4] = 'T' then
    Include(Result, fsStrikeOut);
end;


function load_settings(lpath: string)  : boolean;
var
  dum : string;
  i,c                : integer;
  initstring :tstrings; {settings for save and loading}

    procedure get_float(var float: double;s1 : string);
    var
      err: integer;
      r  : double;
    begin
      val(initstring.Values[s1],r,err);
      if err=0 then float:=r;
    end;

    procedure get_int(var i: integer;s1 : string);
    var
      r, err : integer;
    begin
      val(initstring.Values[s1],r,err);
      if err=0 then i:=r;
    end;

    function get_int2(const i: integer;s1 : string): integer;
    var
      r, err : integer;
    begin
      val(initstring.Values[s1],r,err);
      if err=0 then
        result:=r
      else
        result:=i;
    end;

   function get_boolean(s1:string;the_default:boolean): boolean;
   var
     err, r:integer;
   begin
     val(initstring.Values[s1],r,err);
     if err<>0 then result:=the_default {if no data, result is the_default}
     else
     begin
       if r<=0 then result:=false
       else result:=true;
     end;
   end;

   procedure get_str(var inp : string; s1 : string);
   var
     r, err : integer;
     s2     : string;
   begin
     s2:=initstring.Values[s1];
     if s2<>'' then inp:=s2;
   end;

begin
  result:=false;{assume failure}
 initstring := Tstringlist.Create;
  with initstring do
  begin
    try
     loadfromFile(lpath); { load from file}
    except
      initstring.Free;
      exit; {no cfg file}
    end;
  end;
  result:=true;
  with mainwindow do
  begin
    mainwindow.left:=get_int2(mainwindow.left,'window_left');
    mainwindow.top:=get_int2(mainwindow.top,'window_top'); ;
    mainwindow.height:=get_int2(mainwindow.height,'window_height');
    mainwindow.width:=get_int2(mainwindow.width,'window_width');;


    stackmenu1.left:=get_int2(stackmenu1.left,'stackmenu_left');
    stackmenu1.top:=get_int2(stackmenu1.top,'stackmenu_top');
    stackmenu1.height:=get_int2(stackmenu1.height,'stackmenu_height');
    stackmenu1.width:=get_int2(stackmenu1.width,'stackmenu_width');

    get_int(font_color,'font_color');
    get_int(font_size,'font_size');
    dum:=initstring.Values['font_name'];if dum<>'' then font_name:= dum;
    dum:=initstring.Values['font_style'];if dum<>'' then font_style:= strtostyle(dum);
    get_int(font_charset,'font_charset');

    stackmenu1.mosaic_width1.position:=get_int2(stackmenu1.mosaic_width1.position,'mosaic_width');
    stackmenu1.mosaic_crop1.position:=get_int2(stackmenu1.mosaic_crop1.position,'mosaic_crop');

    minimum1.position:=get_int2(minimum1.position,'minimum_position');
    maximum1.position:=get_int2(maximum1.position,'maximum_position');
    range1.itemindex:=get_int2(range1.itemindex,'range');

    saturation_factor_plot1.position:=get_int2(saturation_factor_plot1.position,'saturation_factor');

    stackmenu1.stack_method1.itemindex:=get_int2(stackmenu1.stack_method1.itemindex,'stack_method');
    stackmenu1.flat_combine_method1.itemindex:=get_int2(stackmenu1.flat_combine_method1.itemindex,'flat_combine_method');
    stackmenu1.pagecontrol1.tabindex:=get_int2(stackmenu1.pagecontrol1.tabindex,'stack_tab');

    stackmenu1.demosaic_method1.itemindex:=get_int2(stackmenu1.demosaic_method1.itemindex,'demosaic_method2');
    stackmenu1.raw_conversion_program1.itemindex:=get_int2(stackmenu1.raw_conversion_program1.itemindex,'conversion_program');

    Polynomial1.itemindex:=get_int2(Polynomial1.itemindex,'polynomial');

    stackmenu1.rgb_filter1.itemindex:=get_int2(stackmenu1.rgb_filter1.itemindex,'rgb_filter');

    get_int(thumbnails1_width,'thumbnails_width');
    get_int(thumbnails1_height,'thumbnails_height');

    inversemousewheel1.checked:=get_boolean('inversemousewheel',false);
    flip_horizontal1.checked:=get_boolean('fliphorizontal',false);
    flip_vertical1.checked:=get_boolean('Flipvertical',false);
    add_marker_position1.checked:=get_boolean('add_marker',false);{popup marker selected?}

    stackmenu1.make_osc_color1.checked:=get_boolean('osc_color_convert',false);
    stackmenu1.osc_auto_level1.checked:=get_boolean('osc_auto_level',true);
    stackmenu1.osc_colour_smooth1.checked:=get_boolean('osc_colour_smooth',true);

    stackmenu1.ignore_header_solution1.Checked:= get_boolean('ignore_header_solution',true);
    stackmenu1.Equalise_background1.checked:= get_boolean('equalise_background',true);{for mosaic mode}
    stackmenu1.merge_overlap1.checked:= get_boolean('merge_overlap',true);{for mosaic mode}


    mainwindow.preview_demosaic1.Checked:=get_boolean('preview_demosaic',false);

    stackmenu1.classify_object1.checked:= get_boolean('classify_object',false);
    stackmenu1.classify_filter1.checked:= get_boolean('classify_filter',false);

    stackmenu1.classify_dark_temperature1.checked:= get_boolean('classify_dark_temperature',false);
    stackmenu1.classify_dark_exposure1.checked:= get_boolean('classify_dark_exposure',false);
    stackmenu1.classify_flat_filter1.checked:= get_boolean('classify_flat_filter',false);

    stackmenu1.gridlines1.checked:= get_boolean('grid_lines',false);
    stackmenu1.uncheck_outliers1.checked:= get_boolean('uncheck_outliers',false);


    marker_position :=initstring.Values['marker_position'];{ra, dec marker}
    mainwindow.shape_marker3.hint:=marker_position;

    ra1.text:= initstring.Values['ra'];
    dec1.text:= initstring.Values['dec'];

    stretch1.text:= initstring.Values['gamma'];

    stackmenu1.blur_factor1.text:= initstring.Values['blur_factor'];

    stackmenu1.use_manual_alignment1.checked:=initstring.Values['align_method']='4';
    stackmenu1.use_astrometry_internal1.checked:=initstring.Values['align_method']='3';
    stackmenu1.use_star_alignment1.checked:=initstring.Values['align_method']='2';
    stackmenu1.use_ephemeris_alignment1.checked:=initstring.Values['align_method']='1';

    stackmenu1.write_log1.Checked:=get_boolean('write_log',true);{write to log file}
    stackmenu1.align_blink1.Checked:=get_boolean('align_blink',true);{blink}
    stackmenu1.timestamp1.Checked:=get_boolean('time_stamp',true);{blink}

    stackmenu1.force_oversize1.Checked:=get_boolean('force_slow',false);
    stackmenu1.calibrate_prior_solving1.Checked:=get_boolean('calibrate_prior_solving',false);

    dum:=initstring.Values['star_database']; if dum<>'' then stackmenu1.star_database1.text:=dum;
    dum:=initstring.Values['solve_search_field']; if dum<>'' then stackmenu1.search_fov1.text:=dum;

    dum:=initstring.Values['radius_search']; if dum<>'' then stackmenu1.radius_search1.text:=dum;
    dum:=initstring.Values['quad_tolerance']; if dum<>'' then stackmenu1.quad_tolerance1.text:=dum;
    dum:=initstring.Values['maximum_stars']; if dum<>'' then stackmenu1.max_stars1.text:=dum;
    dum:=initstring.Values['min_star_size']; if dum<>'' then stackmenu1.min_star_size1.text:=dum;
    dum:=initstring.Values['min_star_size_stacking']; if dum<>'' then stackmenu1.min_star_size_stacking1.text:=dum;

    dum:=initstring.Values['manual_centering']; if dum<>'' then stackmenu1.manual_centering1.text:=dum;

    dum:=initstring.Values['downsample']; if dum<>'' then stackmenu1.downsample_for_solving1.text:=dum;
    dum:=initstring.Values['max_fov']; if ((dum<>'') and (dum<>'3')) then stackmenu1.max_fov1.text:=dum;{remove 2020-6  dum<>3}

    dum:=initstring.Values['oversize'];if dum<>'' then stackmenu1.oversize1.text:=dum;
    dum:=initstring.Values['sd_factor']; if dum<>'' then stackmenu1.sd_factor1.text:=dum;

    dum:=initstring.Values['most_common_filter_radius']; if dum<>'' then stackmenu1.most_common_filter_radius1.text:=dum;

    dum:=initstring.Values['extract_background_box_size']; if dum<>'' then stackmenu1.extract_background_box_size1.text:=dum;
    dum:=initstring.Values['dark_areas_box_size']; if dum<>'' then stackmenu1.dark_areas_box_size1.text:=dum;
    dum:=initstring.Values['ring_equalise_factor']; if dum<>'' then stackmenu1.ring_equalise_factor1.text:=dum;

    dum:=initstring.Values['gradient_filter_factor']; if dum<>'' then stackmenu1.gradient_filter_factor1.text:=dum;

    if paramcount=0 then filename2:=initstring.Values['last_file'];{if used as viewer don't override paramstr1}

    stackmenu1.ignore_hotpixels1.checked:= get_boolean('ignore_hotpixels',false);
    dum:=initstring.Values['hotpixel_sd_factor']; if dum<>'' then stackmenu1.hotpixel_sd_factor1.text:=dum;

    dum:=initstring.Values['bayer_pat']; if dum<>'' then stackmenu1.bayer_pattern1.text:=dum;

    dum:=initstring.Values['red_filter1']; if dum<>'' then stackmenu1.red_filter1.text:=dum;
    dum:=initstring.Values['red_filter2']; if dum<>'' then stackmenu1.red_filter2.text:=dum;

    dum:=initstring.Values['green_filter1']; if dum<>'' then stackmenu1.green_filter1.text:=dum;
    dum:=initstring.Values['green_filter2']; if dum<>'' then stackmenu1.green_filter2.text:=dum;
    dum:=initstring.Values['blue_filter1']; if dum<>'' then stackmenu1.blue_filter1.text:=dum;
    dum:=initstring.Values['blue_filter2']; if dum<>'' then stackmenu1.blue_filter2.text:=dum;
    dum:=initstring.Values['luminance_filter1']; if dum<>'' then stackmenu1.luminance_filter1.text:=dum;
    dum:=initstring.Values['luminance_filter2']; if dum<>'' then stackmenu1.luminance_filter2.text:=dum;

    dum:=initstring.Values['rr_factor']; if dum<>'' then stackmenu1.rr1.text:=dum;
    dum:=initstring.Values['rg_factor']; if dum<>'' then stackmenu1.rg1.text:=dum;
    dum:=initstring.Values['rb_factor']; if dum<>'' then stackmenu1.rb1.text:=dum;

    dum:=initstring.Values['gr_factor']; if dum<>'' then stackmenu1.gr1.text:=dum;
    dum:=initstring.Values['gg_factor']; if dum<>'' then stackmenu1.gg1.text:=dum;
    dum:=initstring.Values['gb_factor']; if dum<>'' then stackmenu1.gb1.text:=dum;

    dum:=initstring.Values['br_factor']; if dum<>'' then stackmenu1.br1.text:=dum;
    dum:=initstring.Values['bg_factor']; if dum<>'' then stackmenu1.bg1.text:=dum;
    dum:=initstring.Values['bb_factor']; if dum<>'' then stackmenu1.bb1.text:=dum;

    dum:=initstring.Values['red_filter_add']; if dum<>'' then stackmenu1.red_filter_add1.text:=dum;
    dum:=initstring.Values['green_filter_add']; if dum<>'' then stackmenu1.green_filter_add1.text:=dum;
    dum:=initstring.Values['blue_filter_add']; if dum<>'' then stackmenu1.blue_filter_add1.text:=dum;

   {Six colour correction factors}
    dum:=initstring.Values['add_value_R']; if dum<>'' then stackmenu1.add_valueR1.text:=dum;
    dum:=initstring.Values['add_value_G']; if dum<>'' then stackmenu1.add_valueG1.text:=dum;
    dum:=initstring.Values['add_value_B']; if dum<>'' then stackmenu1.add_valueB1.text:=dum;
    dum:=initstring.Values['multiply_R']; if dum<>'' then stackmenu1.multiply_red1.text:=dum;
    dum:=initstring.Values['multiply_G']; if dum<>'' then stackmenu1.multiply_green1.text:=dum;
    dum:=initstring.Values['multiply_B']; if dum<>'' then stackmenu1.multiply_blue1.text:=dum;

    dum:=initstring.Values['smart_smooth_width']; if dum<>'' then stackmenu1.smart_smooth_width1.text:=dum;

    dum:=initstring.Values['star_level_colouring']; if dum<>'' then stackmenu1.star_level_colouring1.text:=dum;
    dum:=initstring.Values['filter_artificial_colouring']; if dum<>'' then stackmenu1.filter_artificial_colouring1.text:=dum;
    dum:=initstring.Values['resize_factor']; if dum<>'' then stackmenu1.resize_factor1.text:=dum;
    dum:=initstring.Values['mark_outliers_upto']; if dum<>'' then stackmenu1.mark_outliers_upto1.text:=dum;
    dum:=initstring.Values['sigma_decolour']; if dum<>'' then stackmenu1.sigma_decolour1.text:=dum;
    dum:=initstring.Values['sd_factor_list']; if dum<>'' then stackmenu1.sd_factor_list1.text:=dum;

    dum:=initstring.Values['noisefilter_blur']; if dum<>'' then stackmenu1.noisefilter_blur1.text:=dum;
    dum:=initstring.Values['noisefilter_sd']; if dum<>'' then stackmenu1.noisefilter_sd1.text:=dum;

    stackmenu1.hue_fuzziness1.position:=get_int2(stackmenu1.hue_fuzziness1.position,'hue_fuzziness');
    stackmenu1.saturation_tolerance1.position:=get_int2(stackmenu1.saturation_tolerance1.position,'saturation_tolerance');
    stackmenu1.remove_luminance1.checked:= get_boolean('remove_luminance',false);

    stackmenu1.sample_size1.itemindex:=get_int2(stackmenu1.sample_size1.itemindex,'sample_size');
    stackmenu1.live_stacking_path1.caption:=initstring.Values['live_stack_dir'];

    dum:=initstring.Values['mpcorb_path'];if dum<>'' then mpcorb_path:=dum;{asteroids}
    dum:=initstring.Values['cometels_path'];if dum<>'' then cometels_path:=dum;{asteroids}

    dum:=initstring.Values['maxcount'];if dum<>'' then maxcount_asteroid:=dum;{asteroids}
    dum:=initstring.Values['maxmag'];if dum<>'' then maxmag_asteroid:=dum;{asteroids}
    showfullnames:=get_boolean('showfullnames',true);{asteroids}
    showmagnitude:=get_boolean('showmagnitude',false);{asteroids}
    add_date:=get_boolean('add_date',true);{asteroids}

    get_int(annotation_color,'annotation_color');
    get_int(annotation_diameter,'annotation_diameter');

    add_annotations:=get_boolean('add_annotations',false);{asteroids as annotations}

    dum:=initstring.Values['astrometry_extra_options']; if dum<>'' then astrometry_extra_options:=dum;
    show_console:=get_boolean('show_console',true);
    dum:=initstring.Values['cygwin_path']; if dum<>'' then cygwin_path:=dum;

    stackmenu1.write_jpeg1.Checked:=get_boolean('write_jpeg',false);{live stacking}
    stackmenu1.interim_to_clipboard1.Checked:=get_boolean('to_clipboard',false);{live stacking}

    stackmenu1.listview1.Items.BeginUpdate;
    c:=0;
    repeat {add images}
       dum:=initstring.Values['image'+inttostr(c)];
       if ((dum<>'') and (fileexists(dum))) then
       begin
         listview_add(stackmenu1.listview1,dum,26);
         stackmenu1.ListView1.items[c].Checked:=get_boolean('image'+inttostr(c)+'_check',true);
       end;
       inc(c);
    until (dum='');
    stackmenu1.listview1.Items.endUpdate;

    stackmenu1.listview2.Items.BeginUpdate;
    c:=0;
    repeat {add  darks}
       dum:=initstring.Values['dark'+inttostr(c)];
       if ((dum<>'') and (fileexists(dum))) then
       begin
         listview_add(stackmenu1.listview2,dum,9);
         stackmenu1.ListView2.items[c].Checked:=get_boolean('dark'+inttostr(c)+'_check',true);
       end;
       inc(c);
    until (dum='');
    stackmenu1.listview2.Items.endUpdate;


    stackmenu1.listview3.Items.BeginUpdate;
    c:=0;
    repeat {add  flats}
      dum:=initstring.Values['flat'+inttostr(c)];
      if ((dum<>'') and (fileexists(dum))) then
      begin
        listview_add(stackmenu1.listview3,dum,10);
        stackmenu1.ListView3.items[c].Checked:=get_boolean('flat'+inttostr(c)+'_check',true);
      end;
      inc(c);
    until (dum='');
    stackmenu1.listview3.Items.endUpdate;


    stackmenu1.listview4.Items.BeginUpdate;
    c:=0;
    repeat {add flat darks}
      dum:=initstring.Values['flat_dark'+inttostr(c)];
      if ((dum<>'') and (fileexists(dum))) then
      begin
        listview_add(stackmenu1.listview4,dum,9);
        stackmenu1.ListView4.items[c].Checked:=get_boolean('flat_dark'+inttostr(c)+'_check',true);
      end;
      inc(c);
    until (dum='');
    stackmenu1.listview4.Items.endUpdate;


    stackmenu1.listview6.Items.BeginUpdate;
    c:=0;
    repeat {add blink files}
      dum:=initstring.Values['blink'+inttostr(c)];
      if ((dum<>'') and (fileexists(dum))) then
      begin
        listview_add(stackmenu1.listview6,dum,10);
        stackmenu1.ListView6.items[c].Checked:=get_boolean('blink'+inttostr(c)+'_check',true);
      end;
      inc(c);
    until (dum='');
    stackmenu1.listview6.Items.endUpdate;


    stackmenu1.listview7.Items.BeginUpdate;
    c:=0;
    repeat {add photometry files}
      dum:=initstring.Values['photometry'+inttostr(c)];
      if ((dum<>'') and (fileexists(dum))) then
      begin
        listview_add(stackmenu1.listview7,dum,17);
        stackmenu1.ListView7.items[c].Checked:=get_boolean('photometry'+inttostr(c)+'_check',true);
      end;
      inc(c);
    until (dum='');
    stackmenu1.listview7.Items.endUpdate;


    stackmenu1.listview8.Items.BeginUpdate;
    c:=0;
    repeat {add inspector files}
      dum:=initstring.Values['inspector'+inttostr(c)];
      if ((dum<>'') and (fileexists(dum))) then
      begin
        listview_add(stackmenu1.listview8,dum,16);
        stackmenu1.ListView8.items[c].Checked:=get_boolean('inspector'+inttostr(c)+'_check',true);
      end;
      inc(c);
    until (dum='');
    stackmenu1.listview8.Items.endUpdate;


    c:=0;
    repeat {read recent files}
      dum:=initstring.Values['recent'+inttostr(c)];
      if dum<>'' then
       recent_files.add(dum);
      inc(c);
    until (dum='');
    update_recent_file_menu;

    stackmenu1.visible:=((get_boolean('stackmenu_visible',false) ) and (paramcount=0));{do this last, so stackmenu.onshow updates the setting correctly}
  end;
  initstring.free;
end;


procedure save_settings(lpath:string);
const
  BoolStr: array [boolean] of String = ('0', '1');
var
  initstring :tstrings; {settings for save and loading}
  c : integer;

begin
  with mainwindow do
  begin
    initstring := Tstringlist.Create;
    initstring.Values['window_left']:=inttostr(mainwindow.left);
    initstring.Values['window_top']:=inttostr(mainwindow.top);
    initstring.Values['window_height']:=inttostr(mainwindow.height);
    initstring.Values['window_width']:=inttostr(mainwindow.width);

    initstring.Values['stackmenu_visible']:=BoolStr[stackmenu1.visible];

    initstring.Values['stackmenu_left']:=inttostr(stackmenu1.left);
    initstring.Values['stackmenu_top']:=inttostr(stackmenu1.top);
    initstring.Values['stackmenu_height']:=inttostr(stackmenu1.height);
    initstring.Values['stackmenu_width']:=inttostr(stackmenu1.width);

    initstring.Values['font_color']:=inttostr(font_color);
    initstring.Values['font_size']:=inttostr(font_size);
    initstring.Values['font_name']:=font_name;
    initstring.Values['font_style']:=StyleToStr(font_style);
    initstring.Values['font_charset']:=inttostr(font_charset);

    initstring.Values['minimum_position']:=inttostr(MINIMUM1.position);
    initstring.Values['maximum_position']:=inttostr(maximum1.position);
    initstring.Values['range']:=inttostr(range1.itemindex);

    initstring.Values['saturation_factor']:=inttostr(saturation_factor_plot1.position);

    initstring.Values['stack_method']:=inttostr(stackmenu1.stack_method1.itemindex);

    initstring.Values['mosaic_width']:=inttostr(stackmenu1.mosaic_width1.position);
    initstring.Values['mosaic_crop']:=inttostr(stackmenu1.mosaic_crop1.position);

    initstring.Values['flat_combine_method']:=inttostr(stackmenu1.flat_combine_method1.itemindex);
    initstring.Values['stack_tab']:=inttostr(stackmenu1.pagecontrol1.tabindex);

    initstring.Values['bayer_pat']:=stackmenu1.bayer_pattern1.text;

    initstring.Values['demosaic_method2']:=inttostr(stackmenu1.demosaic_method1.itemindex);
    initstring.Values['conversion_program']:=inttostr(stackmenu1.raw_conversion_program1.itemindex);

    initstring.Values['polynomial']:=inttostr(polynomial1.itemindex);

    initstring.Values['thumbnails_width']:=inttostr(thumbnails1_width);
    initstring.Values['thumbnails_height']:=inttostr(thumbnails1_height);

    initstring.Values['rgb_filter']:=inttostr(stackmenu1.rgb_filter1.itemindex);

    initstring.Values['inversemousewheel']:=BoolStr[inversemousewheel1.checked];
    initstring.Values['fliphorizontal']:=BoolStr[flip_horizontal1.checked];
    initstring.Values['Flipvertical']:=BoolStr[flip_vertical1.checked];
    initstring.Values['add_marker']:=BoolStr[add_marker_position1.checked];

    initstring.Values['osc_color_convert']:=BoolStr[stackmenu1.make_osc_color1.checked];
    initstring.Values['osc_auto_level']:=BoolStr[stackmenu1.osc_auto_level1.checked];
    initstring.Values['osc_colour_smooth']:=BoolStr[stackmenu1.osc_colour_smooth1.checked];

    initstring.Values['ignore_header_solution']:=BoolStr[stackmenu1.ignore_header_solution1.Checked];
    initstring.Values['equalise_background']:=BoolStr[stackmenu1.Equalise_background1.Checked];
    initstring.Values['merge_overlap']:=BoolStr[stackmenu1.merge_overlap1.Checked];

    initstring.Values['preview_demosaic']:=BoolStr[mainwindow.preview_demosaic1.Checked];

    initstring.Values['classify_object']:=BoolStr[stackmenu1.classify_object1.Checked];
    initstring.Values['classify_filter']:=BoolStr[stackmenu1.classify_filter1.Checked];

    initstring.Values['classify_dark_temperature']:=BoolStr[stackmenu1.classify_dark_temperature1.Checked];
    initstring.Values['classify_dark_exposure']:=BoolStr[stackmenu1.classify_dark_exposure1.Checked];
    initstring.Values['classify_flat_filter']:=BoolStr[stackmenu1.classify_flat_filter1.Checked];

    initstring.Values['grid_lines']:=BoolStr[stackmenu1.gridlines1.Checked];
    initstring.Values['uncheck_outliers']:=BoolStr[stackmenu1.uncheck_outliers1.Checked];

    initstring.Values['write_log']:=BoolStr[stackmenu1.write_log1.checked];{write log to file}

    initstring.Values['align_blink']:=BoolStr[stackmenu1.align_blink1.checked];{blink}
    initstring.Values['time_stamp']:=BoolStr[stackmenu1.timestamp1.checked];{blink}

    initstring.Values['force_slow']:=BoolStr[stackmenu1.force_oversize1.checked];
    initstring.Values['calibrate_prior_solving']:=BoolStr[stackmenu1.calibrate_prior_solving1.checked];


    initstring.Values['ra']:=ra1.text;
    initstring.Values['dec']:=dec1.text;
    initstring.Values['gamma']:=stretch1.text;
    initstring.Values['marker_position']:=marker_position;

    if  stackmenu1.use_manual_alignment1.checked then initstring.Values['align_method']:='4'
    else
    if  stackmenu1.use_astrometry_internal1.checked then initstring.Values['align_method']:='3'
    else
    if  stackmenu1.use_star_alignment1.checked then initstring.Values['align_method']:='2'
    else
    if  stackmenu1.use_ephemeris_alignment1.checked then  initstring.Values['align_method']:='1';

    initstring.Values['star_database']:=stackmenu1.star_database1.text;
    initstring.Values['solve_search_field']:=stackmenu1.search_fov1.text;
    initstring.Values['radius_search']:=stackmenu1.radius_search1.text;
    initstring.Values['quad_tolerance']:=stackmenu1.quad_tolerance1.text;
    initstring.Values['maximum_stars']:=stackmenu1.max_stars1.text;
    initstring.Values['min_star_size']:=stackmenu1.min_star_size1.text;
    initstring.Values['min_star_size_stacking']:=stackmenu1.min_star_size_stacking1.text;


    initstring.Values['manual_centering']:=stackmenu1.manual_centering1.text;

    initstring.Values['downsample']:=stackmenu1.downsample_for_solving1.text;
    initstring.Values['max_fov']:=stackmenu1.max_fov1.text;

    initstring.Values['oversize']:=stackmenu1.oversize1.text;

    initstring.Values['sd_factor']:=stackmenu1.sd_factor1.text;
    initstring.Values['blur_factor']:=stackmenu1.blur_factor1.text;
    initstring.Values['most_common_filter_radius']:=stackmenu1.most_common_filter_radius1.text;

    initstring.Values['extract_background_box_size']:=stackmenu1.extract_background_box_size1.text;
    initstring.Values['dark_areas_box_size']:=stackmenu1.dark_areas_box_size1.text;
    initstring.Values['ring_equalise_factor']:=stackmenu1.ring_equalise_factor1.text;

    initstring.Values['gradient_filter_factor']:=stackmenu1.gradient_filter_factor1.text;

    initstring.Values['last_file']:=filename2;

    initstring.Values['ignore_hotpixels']:=BoolStr[stackmenu1.ignore_hotpixels1.Checked];
    initstring.Values['hotpixel_sd_factor']:= stackmenu1.hotpixel_sd_factor1.text;

    initstring.Values['red_filter1']:=stackmenu1.red_filter1.text;
    initstring.Values['red_filter2']:=stackmenu1.red_filter2.text;
    initstring.Values['green_filter1']:=stackmenu1.green_filter1.text;
    initstring.Values['green_filter2']:=stackmenu1.green_filter2.text;
    initstring.Values['blue_filter1']:=stackmenu1.blue_filter1.text;
    initstring.Values['blue_filter2']:=stackmenu1.blue_filter2.text;
    initstring.Values['luminance_filter1']:=stackmenu1.luminance_filter1.text;
    initstring.Values['luminance_filter2']:=stackmenu1.luminance_filter2.text;

    initstring.Values['rr_factor']:=stackmenu1.rr1.text;
    initstring.Values['rg_factor']:=stackmenu1.rg1.text;
    initstring.Values['rb_factor']:=stackmenu1.rb1.text;

    initstring.Values['gr_factor']:=stackmenu1.gr1.text;
    initstring.Values['gg_factor']:=stackmenu1.gg1.text;
    initstring.Values['gb_factor']:=stackmenu1.gb1.text;

    initstring.Values['br_factor']:=stackmenu1.br1.text;
    initstring.Values['bg_factor']:=stackmenu1.bg1.text;
    initstring.Values['bb_factor']:=stackmenu1.bb1.text;

    initstring.Values['red_filter_add']:=stackmenu1.red_filter_add1.text;
    initstring.Values['green_filter_add']:=stackmenu1.green_filter_add1.text;
    initstring.Values['blue_filter_add']:=stackmenu1.blue_filter_add1.text;

    {Colour correction factors}
    initstring.Values['add_value_R']:=stackmenu1.add_valueR1.text;
    initstring.Values['add_value_G']:=stackmenu1.add_valueG1.text;
    initstring.Values['add_value_B']:=stackmenu1.add_valueB1.text;
    initstring.Values['multiply_R']:=stackmenu1.multiply_red1.text;
    initstring.Values['multiply_G']:=stackmenu1.multiply_green1.text;
    initstring.Values['multiply_B']:=stackmenu1.multiply_blue1.text;

    initstring.Values['smart_smooth_width']:=stackmenu1.smart_smooth_width1.text;

    initstring.Values['star_level_colouring']:=stackmenu1.star_level_colouring1.text;
    initstring.Values['filter_artificial_colouring']:=stackmenu1.filter_artificial_colouring1.text;

    initstring.Values['resize_factor']:=stackmenu1.resize_factor1.text;

    initstring.Values['mark_outliers_upto']:=stackmenu1.mark_outliers_upto1.text;


    initstring.Values['sigma_decolour']:=stackmenu1.sigma_decolour1.text;

    initstring.Values['sd_factor_list']:=stackmenu1.sd_factor_list1.text;
    initstring.Values['noisefilter_blur']:=stackmenu1.noisefilter_blur1.text;
    initstring.Values['noisefilter_sd']:=stackmenu1.noisefilter_sd1.text;

    initstring.Values['hue_fuzziness']:=inttostr(stackmenu1.hue_fuzziness1.position);
    initstring.Values['saturation_tolerance']:=inttostr(stackmenu1.saturation_tolerance1.position);
    initstring.Values['remove_luminance']:=BoolStr[stackmenu1.remove_luminance1.checked];{asteroids}

    initstring.Values['sample_size']:=inttostr(stackmenu1.sample_size1.itemindex);

    initstring.Values['live_stack_dir']:=stackmenu1.live_stacking_path1.caption;


    initstring.Values['mpcorb_path']:=mpcorb_path;{asteroids}
    initstring.Values['cometels_path']:=cometels_path;{comets}

    initstring.Values['maxcount']:=maxcount_asteroid;{asteroids}
    initstring.Values['maxmag']:=maxmag_asteroid;{asteroids}
    initstring.Values['showfullnames']:=BoolStr[showfullnames];{asteroids}
    initstring.Values['showmagnitude']:=BoolStr[showmagnitude];{asteroids}
    initstring.Values['add_date']:=BoolStr[add_date];{asteroids}

    initstring.Values['annotation_color']:=inttostr(annotation_color);
    initstring.Values['annotation_diameter']:=inttostr(annotation_diameter);

    initstring.Values['add_annotations']:=BoolStr[add_annotations];{for asteroids}

    initstring.Values['cygwin_path']:=cygwin_path;
    initstring.Values['show_console']:=BoolStr[show_console];
    initstring.Values['astrometry_extra_options']:=astrometry_extra_options;

    initstring.Values['write_jpeg']:=BoolStr[stackmenu1.write_jpeg1.checked];{live stacking}
    initstring.Values['to_clipboard']:=BoolStr[stackmenu1.interim_to_clipboard1.checked];{live stacking}

    {### save listview values ###}
    for c:=0 to stackmenu1.ListView1.items.count-1 do {add light images}
    begin
      initstring.Values['image'+inttostr(c)]:=stackmenu1.ListView1.items[c].caption;
      initstring.Values['image'+inttostr(c)+'_check']:=boolstr[stackmenu1.ListView1.items[c].Checked];
    end;

    for c:=0 to stackmenu1.ListView2.items.count-1  do {add dark files}
    begin
      initstring.Values['dark'+inttostr(c)]:=stackmenu1.ListView2.items[c].caption;
      initstring.Values['dark'+inttostr(c)+'_check']:=boolstr[stackmenu1.ListView2.items[c].Checked];
    end;
    for c:=0 to stackmenu1.ListView3.items.count-1  do {add flat files}
    begin
      initstring.Values['flat'+inttostr(c)]:=stackmenu1.ListView3.items[c].caption;
      initstring.Values['flat'+inttostr(c)+'_check']:=boolstr[stackmenu1.ListView3.items[c].Checked];
    end;
    for c:=0 to stackmenu1.ListView4.items.count-1  do {add flat_dark files}
    begin
      initstring.Values['flat_dark'+inttostr(c)]:=stackmenu1.ListView4.items[c].caption;
      initstring.Values['flat_dark'+inttostr(c)+'_check']:=boolstr[stackmenu1.ListView4.items[c].Checked];
    end;
    for c:=0 to stackmenu1.ListView6.items.count-1  do {add blink files}
    begin
      initstring.Values['blink'+inttostr(c)]:=stackmenu1.ListView6.items[c].caption;
      initstring.Values['blink'+inttostr(c)+'_check']:=boolstr[stackmenu1.ListView6.items[c].Checked];
    end;
    for c:=0 to stackmenu1.ListView7.items.count-1  do {add photometry files}
    begin
      initstring.Values['photometry'+inttostr(c)]:=stackmenu1.ListView7.items[c].caption;
      initstring.Values['photometry'+inttostr(c)+'_check']:=boolstr[stackmenu1.ListView7.items[c].Checked];
    end;
    for c:=0 to stackmenu1.ListView8.items.count-1  do {add photometry files}
    begin
      initstring.Values['inspector'+inttostr(c)]:=stackmenu1.ListView8.items[c].caption;
      initstring.Values['inspector'+inttostr(c)+'_check']:=boolstr[stackmenu1.ListView8.items[c].Checked];
    end;

    for c:=0 to recent_files.count-1  do {add recent files}
      initstring.Values['recent'+inttostr(c)]:=recent_files[c];

    with initstring do
    begin
      try
      savetoFile(lpath);{ save to file.}
      except
        application.messagebox(pchar('Error writing: '+lpath),pchar('Error'),MB_ICONWARNING+MB_OK);
        exit;
      end;
    end;
    initstring.free;
  end;
end;


procedure Tmainwindow.flip_horizontal1Click(Sender: TObject);
var bmp: TBitmap;
    w, h, x, y: integer;
type
  PRGBTripleArray = ^TRGBTripleArray; {for fast pixel routine}
  {$ifdef mswindows}
  TRGBTripleArray = array[0..trunc(bufwide/3)] of TRGBTriple; {for fast pixel routine}
  {$else} {unix}
  TRGBTripleArray = array[0..trunc(bufwide/3)] of tagRGBQUAD; {for fast pixel routine}
  {$endif}
var
   pixelrow1 : PRGBTripleArray;{for fast pixel routine}
   pixelrow2 : PRGBTripleArray;{for fast pixel routine}
begin
  w:=image1.Picture.Width; h:=image1.Picture.Height;
  bmp:=TBitmap.Create;
  bmp.PixelFormat:=pf24bit;

  bmp.SetSize(w, h);
  for y := 0 to h -1 do
  begin // scan each line
    pixelrow1:=image1.Picture.Bitmap.ScanLine[y];
    pixelrow2:=bmp.ScanLine[y];
    for x := 0 to w-1 do {swap left and right}
       pixelrow2[x] := pixelrow1[w-1 -x];
  end;
  image1.Picture.Bitmap.Canvas.Draw(0,0, bmp);// move bmp to source
  bmp.Free;
  plot_north; {draw arrow or clear indication position north depending on value cd1_1}
end;


procedure Convert_to_BMP;
var
 BMP : TBitmap;
begin
  BMP := TBitmap.Create;
  try
    Bmp.Width := mainwindow.image1.Picture.Width;{2017}
    Bmp.Height := mainwindow.image1.Picture.Height;

    Bmp.Canvas.Draw(0, 0, mainwindow.image1.Picture.Graphic);
    mainwindow.image1.Picture.Bitmap := bmp; {Show the bitmap on form}

//    following assign doesn't work for Nvidia 750ti
//    BMP.assign(mainwindow.image1.Picture.Graphic);
//    mainwindow.image1.Picture.Graphic := BMP;
  finally
    BMP.Free
  end;
end;


function extract_exposure_from_filename(filename8: string):integer; {try to extract exposure from filename}
var
  exposure_str  :string;
  i,x,err      : integer;
  ch : char;
begin
  {try to reconstruct exposure time from filename}
  result:=0;
  exposure_str:='';
  filename8:=uppercase(filename8);
  i:=pos('SEC',filename8);
  if i=0 then i:=pos('S_',filename8);
  if i>2 then
  begin
    if filename8[i-1]=' ' then dec(i); {ignore first space}
    while i>=1 do
    begin
      ch:=filename8[i-1];
      x:=ord(ch);
      if ((x<=57) and (x>=48)) then {between 0..9}
        exposure_str:=ch+ exposure_str  {extra number before sec}
      else
        i:=-999; {stop}
      dec(i);
    end;
    val(exposure_str,result,err);
    if err=0 then
    begin
      update_integer('EXPOSURE=',' / exposure extracted from file name.                     ' ,result);
      memo2_message('Extracted exposure from file name');
    end
    else
    memo2_message('Failed to extract exposure time from file name. Expects ...Sec or ...S_ ');
  end;
end;
function extract_temperature_from_filename(filename8: string): integer; {try to extract temperature from filename}
var
  temp_str  :string;
  i,x,err   : integer;
  ch : char;
begin
  {try to reconstruct exposure time from filename}
  result:=999;{unknow temperature}
  temp_str:='';
  filename8:=uppercase(filename8);
  i:=pos('0C',filename8);
  if i=0 then i:=pos('1C',filename8);
  if i=0 then i:=pos('2C',filename8);
  if i=0 then i:=pos('3C',filename8);
  if i=0 then i:=pos('4C',filename8);
  if i=0 then i:=pos('5C',filename8);
  if i=0 then i:=pos('6C',filename8);
  if i=0 then i:=pos('7C',filename8);
  if i=0 then i:=pos('8C',filename8);
  if i=0 then i:=pos('9C',filename8);

  while i>=1 do
  begin
    ch:=filename8[i];
    x:=ord(ch);
    if ( ((x<=57) and (x>=48)) or (x=45)) then {between 0..9 or -}
      temp_str:=ch+ temp_str  {extra number before sec}
    else
      i:=-999; {stop}
    dec(i);
  end;
  val(temp_str,result,err);
  if err=0 then
  begin
    update_integer('CCD-TEMP=',' / Sensor temperature extracted from file name            ' ,result);
    memo2_message('Extracted temperature from file name');
  end
  else
  memo2_message('Failed to extract temperature from the file name. Expects ...C ');
end;


function unpack_cfitsio(filename3: string): boolean; {convert .fz to .fits using funpack}
var
  commando :string;
begin
  result:=false;

  commando:='-D';
  {$ifdef mswindows}
  if fileexists(application_path+'funpack.exe')=false then begin result:=false; application.messagebox(pchar('Could not find: '+application_path+'funpack.exe !!, Download and install fpack_funpack.exe' ),pchar('Error'),MB_ICONWARNING+MB_OK);exit; end;
  ExecuteAndWait(application_path+'funpack.exe '+commando+ ' "'+filename3+'"',false);{execute command and wait}
  {$endif}
  {$ifdef Darwin}{MacOS}
  if fileexists(application_path+'/funpack')=false then begin result:=false; application.messagebox(pchar('Could not find: '+application_path+'funpack' ),pchar('Error'),MB_ICONWARNING+MB_OK);exit; end;
  execute_unix2(application_path+'/funpack '+commando+' "'+filename3+'"');
  {$endif}
  {$ifdef linux}
  if fileexists('/usr/bin/funpack')=false then begin result:=false; application.messagebox(pchar('Could not find program funpack !!, Install this program. Eg: sudo apt-get install libcfitsio-bin' ),pchar('Error'),MB_ICONWARNING+MB_OK);;exit; end;
  execute_unix2('/usr/bin/funpack '+commando+' "'+filename3+'"');
  {$endif}
   filename2:=stringreplace(filename3,'.fz', '',[]); {changeFilext doesn't work for double dots .fits.fz}

   result:=true;
end;

function pack_cfitsio(filename3: string): boolean; {convert .fz to .fits using funpack}

begin
  result:=false;
  {$ifdef mswindows}
  if fileexists(application_path+'fpack.exe')=false then begin result:=false; application.messagebox(pchar('Could not find: '+application_path+'fpack.exe !!, Download and install fpack_funpack.exe' ),pchar('Error'),MB_ICONWARNING+MB_OK);exit; end;
  ExecuteAndWait(application_path+'fpack.exe '+ ' "'+filename3+'"',false);{execute command and wait}
  {$endif}
  {$ifdef Darwin}{MacOS}
  if fileexists(application_path+'/fpack')=false then begin result:=false; application.messagebox(pchar('Could not find: '+application_path+'fpack' ),pchar('Error'),MB_ICONWARNING+MB_OK);exit; end;
  execute_unix2(application_path+'/fpack '+' "'+filename3+'"');
  {$endif}
   {$ifdef linux}
  if fileexists('/usr/bin/fpack')=false then begin result:=false; application.messagebox(pchar('Could not find program fpack !!, Install this program. Eg: sudo apt-get install libcfitsio-bin' ),pchar('Error'),MB_ICONWARNING+MB_OK);;exit; end;
  execute_unix2('/usr/bin/fpack '+' "'+filename3+'"');
  {$endif}
  result:=true;
end;


function convert_load_raw(filename3: string;var img: image_array): boolean; {convert raw to pgm file using LibRaw}
var
  filename4 :string;
  JD2                               : double;
  dcraw                             : boolean;
  libraw                            : boolean;
var
  commando  :string;

begin
  result:=false; {assume failure}

  dcraw:=stackmenu1.raw_conversion_program1.itemindex=0; {DCRaw specified}
  libraw:=false;

  if dcraw then {dcraw specified}
  begin
    commando:='-D -4 -t 0';   {-t 0 disables the rotation}
    {$ifdef mswindows}
    if fileexists(application_path+'dcraw.exe')=false then
      dcraw:=false
    else
      ExecuteAndWait(application_path+'dcraw.exe '+commando+ ' "'+filename3+'"',false);{execute command and wait}

    {$endif}
    {$ifdef Linux}
    if fileexists('/usr/bin/dcraw')=false then
      dcraw:=false
    else
      execute_unix2('/usr/bin/dcraw '+commando+' "'+filename3+'"');
    {$endif}
    {$ifdef Darwin} {MacOS}
    if fileexists(application_path+'/dcraw')=false then
      dcraw:=false
    else
      execute_unix2(application_path+'/dcraw '+commando+' "'+filename3+'"');
    {$endif}
     if dcraw=false then memo2_message('DCRAW executable not found! Will try unprocessed_raw as alternative.');
  end;

  if dcraw=false then {dcraw not specified of failed, try with Libraw}
  begin
    libraw:=true; {assume success}
    {$ifdef mswindows}
    if fileexists(application_path+'unprocessed_raw.exe')=false then
      libraw:=false
    else
       ExecuteAndWait(application_path+'unprocessed_raw.exe "'+filename3+'"',false);{execute command and wait}
    {$endif}
    {$ifdef linux}
     if fileexists('/usr/lib/libraw/unprocessed_raw')=false then
     begin
       if fileexists('/usr/bin/unprocessed_raw')=false then
         libraw:=false
       else
         execute_unix2('/usr/bin/unprocessed_raw "'+filename3+'"');
     end
     else
     execute_unix2('/usr/lib/libraw/unprocessed_raw "'+filename3+'"');
   {$endif}
    {$ifdef Darwin}{MacOS}
    if fileexists(application_path+'/unprocessed_raw')=false then
      libraw:=false
    else
      execute_unix2(application_path+'/unprocessed_raw "'+filename3+'"');
     {$endif}
    filename4:=FileName3+'.pgm';
  end
  else filename4:=ChangeFileExt(FileName3,'.pgm');{for DCRaw}

  if ((dcraw=false) and (libraw=false)) then {no conversion program}
  begin
    if dcraw=false then
    begin
    {$ifdef mswindows}
     application.messagebox(pchar('Could not find: '+application_path+'dcraw.exe !!' ),pchar('Error'),MB_ICONWARNING+MB_OK);
    {$endif}
    {$ifdef Linux}
    application.messagebox(pchar('Could not find program dcdraw !!, Install this program. Eg: sudo apt-get install dcraw' ),pchar('Error'),MB_ICONWARNING+MB_OK);
    {$endif}
    {$ifdef Darwin} {MacOS}
    application.messagebox(pchar('Could not find: '+application_path+'dcraw' ),pchar('Error'),MB_ICONWARNING+MB_OK);
    {$endif}
    end;

    if libraw=false then
    begin {libraw}
      {$ifdef mswindows}
      application.messagebox(pchar('Could not find: '+application_path+'unprocessed_raw.exe !!, Download, libraw and place in program directory' ),pchar('Error'),MB_ICONWARNING+MB_OK);
      {$endif}
      {$ifdef linux}
       application.messagebox(pchar('Could not find program unprocessed_raw !!, Install libraw. Eg: sudo apt-get install libraw-bin' ),pchar('Error'),MB_ICONWARNING+MB_OK);
      {$endif}
      {$ifdef Darwin}{MacOS}
      application.messagebox(pchar('Could not find: '+application_path+'unprocessed_raw' ),pchar('Error'),MB_ICONWARNING+MB_OK);
      {$endif}
    end;

    exit;
  end;

  if load_PPM_PGM_PFM(fileName4,img) then {succesfull PGM load}
  begin
    deletefile(filename4);{delete temporary pgm file}

    if date_obs='' then {no date detected in comments}
    begin
      JD2:=2415018.5+(FileDateToDateTime(fileage(filename3))); {fileage raw, convert to Julian Day by adding factor. filedatatodatetime counts from 30 dec 1899.}
      date_obs:=JdToDate(jd2);
      update_text ('DATE-OBS=',#39+date_obs+#39);{give start point exposures}
    end;
    add_text   ('HISTORY  ','Converted from '+filename3);
    result:=true;
  end;
end;


function convert_raw_to_fits(filename7 : string) :boolean;{convert raw file to FITS format}
begin
  if convert_load_raw(filename7,img_buffer) then
  begin
    exposure:=extract_exposure_from_filename(filename7);{including update header}
    set_temperature:=extract_temperature_from_filename(filename7);{including update header}
    update_text('OBJECT  =',#39+extract_objectname_from_filename(filename7)+#39); {spaces will be added/corrected later}
    save_fits(img_buffer,ChangeFileExt(FileName7,'.fit'),16,true);{overwrite. Filename2 will be set to fits file}
    result:=true;
  end
  else
  result:=false;
  img_buffer:=nil;
end;


procedure Tmainwindow.convert_to_fits1click(Sender: TObject);
var
  I: integer;
  Save_Cursor:TCursor;
  ext : string;
  err, dobackup : boolean;
begin
  OpenDialog1.Title := 'Select multiple  files to convert';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=  'All formats |*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP;*.tif;*.tiff;*.TIF;*.new;*.ppm;*.pgm;*.pbm;*.pfm;*.xisf;*.fz;'+
                                       '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                         '|RAW files|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                         '|24 bits PNG, TIFF, JPEG, BMP(*.png,*.tif*, *.jpg,*.bmp)|*.png;*.PNG;*.tif;*.tiff;*.TIF;*.jpg;*.JPG;*.bmp;*.BMP'+
                         '|Compressed FITS files|*.fz';
  opendialog1.initialdir:=ExtractFileDir(filename2);
  fits_file:=false;
 // data_range_groupBox1.Enabled:=true;
  esc_pressed:=false;
  err:=false;
  if OpenDialog1.Execute then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}

    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        Application.ProcessMessages;
        if esc_pressed then begin Screen.Cursor := Save_Cursor;  exit;end;
        filename2:=Strings[I];
        mainwindow.caption:=filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count);;
        ext:=uppercase(ExtractFileExt(filename2));

        if check_raw_file_extension(ext) then {raw format}
        begin
          if convert_raw_to_fits(filename2)=false then begin beep; err:=true; mainwindow.caption:='Error converting '+filename2;end;
        end
        else
        if (ext='.FZ') then {CFITSIO format}
        begin
          if unpack_cfitsio(filename2)=false then begin beep; err:=true; mainwindow.caption:='Error converting '+filename2; end;
        end
        else
        {tif, png, bmp, jpeg}
        if load_tiffpngJPEG(filename2,img_loaded)=false then begin beep; err:=true; mainwindow.caption:='Error converting '+filename2 end
          else
          save_fits(img_loaded,ChangeFileExt(filename2,'.fit'),16,false);
      end;

      if err=false then mainwindow.caption:='Completed, all files converted.'
      else
      mainwindow.caption:='Finished, files converted but with errors!';

      finally
      if dobackup then restore_img;{for the viewer}
      Screen.Cursor := Save_Cursor;  { Always restore to normal }
    end;
  end;
end;


function load_image(re_center,plot: boolean): boolean; {load fits or PNG, BMP, TIF}
var
   ext1,filename_org   : string;
   afitsfile           : boolean;
begin
  if plot then
  begin
    mainwindow.caption:=filename2;
    filename_org:=filename2;
    mainwindow.shape_marker1.visible:=false;
    mainwindow.shape_marker2.visible:=false;
  end;
  ext1:=uppercase(ExtractFileExt(filename2));

  x_coeff[0]:=0; {reset DSS_polynomial, use for check if there is data}
  y_coeff[0]:=0;
  a_order:=0; {SIP_polynomial, use for check if there is data}

  result:=false;{assume failure}
  afitsfile:=false;
  {fits}
  if ((ext1='.FIT') or (ext1='.FITS') or (ext1='.FTS') or (ext1='.NEW')or (ext1='.WCS') or (ext1='.AXY') or (ext1='.XYLS') or (ext1='.GSC') or (ext1='.BAK')) then {FITS}
  begin
    result:=load_fits(filename2,true {light},true,img_loaded);
    if ((result=false) or (naxis<2))  then {{no image or failure.}
    begin
       update_menu(false);
       exit; {WCS file}
    end;
    afitsfile:=true;
  end

  else
  if (ext1='.FZ') then {CFITSIO format}
  begin
    if unpack_cfitsio(filename2)=false then begin beep; exit; end
    else{successfull conversion using funpack}
    result:=load_fits(filename2,true {light},true {load data},img_loaded); {load new fits file}

    if result=false then begin update_menu(false);exit; end
    else afitsfile:=true;
  end {fz}

  else
  if check_raw_file_extension(ext1) then {raw format}
  begin
    if convert_load_raw(filename2,img_loaded)=false then begin update_menu(false);beep; exit; end
    else
    result:=true;
    {successfull conversion using LibRaw}
    filename2:=ChangeFileExt(FileName2,'.fit');{for the case you want to save it}
  end{raw}

  else
  if ((ext1='.PPM') or (ext1='.PGM') or (ext1='.PFM') or (ext1='.PBM')) then {PPM/PGM/ PFM}
  begin
    if load_PPM_PGM_PFM(filename2,img_loaded)=false then begin update_menu(false);exit; end {load the simple formats ppm color or pgm grayscale, exit on failure}
    else
      result:=true;
  end

  else
  if ext1='.XISF' then {XISF}
  begin
    if load_xisf(filename2,img_loaded)=false then begin update_menu(false);exit; end {load XISF, exit on failure}
    else
      result:=true;
  end

  else
  {tif, png, bmp, jpeg}
  if load_tiffpngJPEG(filename2,img_loaded)=false then
        begin update_menu(false);exit; end  {load tif, exit on failure}
  else
    result:=true;

  if plot then
  begin
    if ((naxis3=1) and (mainwindow.preview_demosaic1.checked)) then demosaic_advanced(img_loaded);{demosaic and set levels}
    use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
    plot_fits(mainwindow.image1,re_center,true);     {mainwindow.image1.Visible:=true; is done in plot_fits}
    image_move_to_center:=re_center;
    if ((afitsfile) and (annotated) and (mainwindow.annotations_visible1.checked)) then  plot_annotations(0,0,false);

    update_equalise_background_step(1);{update equalise background menu}

    add_recent_file(filename_org);{As last action, add to recent file list.}
  end;

  if commandline_execution=false then
  begin
    img_backup:=nil;{release backup memory}
    index_backup:=size_backup; {initiate start index_backup:=0}
  end;
end;

//procedure Tmainwindow.flip_vertical1Click(Sender: TObject);
//var src, dest: TRect;
//    bmp: TBitmap;
//    w, h: integer;
//begin
//  w:=image1.Picture.Width; h:=image1.Picture.Height;
//
//  {$ifdef mswindows}
//  src:=rect(0, h, w, 0); // Vertical flip, works for windows but not Linux
//  dest:=rect(0, 0, w, h);
//  {$else} {unix}
//  src:=rect(0, 0, w, h);
//  dest:=rect(0,h, w, 0);//vertical flip, works for Linux but give in Windows one pixel drift
//  {$endif}

//  bmp:=TBitmap.Create;
//  bmp.PixelFormat:=pf24bit;
//  bmp.SetSize(w, h);
//  bmp.Canvas.Draw(0, 0, image1.Picture.Bitmap);
//  image1.Picture.Bitmap.Canvas.CopyRect(dest, bmp.Canvas, src);
//  bmp.Free;
//  plot_north;
//end;


procedure Tmainwindow.flip_vertical1Click(Sender: TObject);
var bmp: TBitmap;
    w, h, x, y: integer;
type
  PRGBTripleArray = ^TRGBTripleArray; {for fast pixel routine}
  {$ifdef mswindows}
  TRGBTripleArray = array[0..trunc(bufwide/3)] of TRGBTriple; {for fast pixel routine}
  {$else} {unix}
  TRGBTripleArray = array[0..trunc(bufwide/3)] of tagRGBQUAD; {for fast pixel routine}
  {$endif}
var
   pixelrow1 : PRGBTripleArray;{for fast pixel routine}
   pixelrow2 : PRGBTripleArray;{for fast pixel routine}
begin
  w:=image1.Picture.Width; h:=image1.Picture.Height;
  bmp:=TBitmap.Create;
  bmp.PixelFormat:=pf24bit;

  bmp.SetSize(w, h);
  for y := 0 to h -1 do
  begin // scan each line and swap top and bottom}
    pixelrow1:=image1.Picture.Bitmap.ScanLine[h-1-y];
    pixelrow2:=bmp.ScanLine[y];
    for x := 0 to w-1 do pixelrow2[x] := pixelrow1[x];
  end;
  image1.Picture.Bitmap.Canvas.Draw(0,0, bmp);// move bmp to source
  bmp.Free;
  plot_north; {draw arrow or clear indication position north depending on value cd1_1}
end;


procedure Tmainwindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  esc_pressed:=true;{stop processing. Required for reliable stopping by APT}
  save_settings(user_path+'astap.cfg');
end;

procedure Tmainwindow.receivemessage(Sender: TObject);{For OneInstance, called from timer (linux) or SimpleIPCServer1MessageQueued (Windows)}
begin
  if SimpleIPCServer1.PeekMessage(1,True) then
  begin
    BringToFront;
    filename2:=SimpleIPCServer1.StringMessage;
    load_image(true,true {plot});{show image of parameter1}
  end;
end;

procedure Tmainwindow.ccd_inspector_plot1Click(Sender: TObject);
var
  j: integer;
  Save_Cursor:TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  backup_img;
  CCDinspector_analyse;

  {$ifdef mswindows}
  filename2:=ExtractFileDir(filename2)+'\hfd_values.fit';
  {$ELSE}{linux}
  filename2:=ExtractFileDir(filename2)+'/hfd_values.fit';
  {$ENDIF}
  mainwindow.memo1.lines.clear;
  for j:=0 to 10 do {create an header with fixed sequence}
    if (j<>5)  then {skip naxis3 for mono images}
        mainwindow.memo1.lines.add(head1[j]); {add lines to empthy memo1}
  mainwindow.memo1.lines.add(head1[27]); {add end}

  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);
  if naxis3=1 then  remove_key('NAXIS3  ',false{all});{remove key word in header. Some program don't like naxis3=1}

  update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer('DATAMAX =',' / Maximum data value                             ' ,round(cwhite));
  update_text   ('COMMENT 1','  Written by ASTAP, Astrometric STAcking Program. www.hnsky.org');
  update_text   ('COMMENT G','  Grey values indicate HFD values * 100');
  Screen.Cursor := Save_Cursor;  { Always restore to normal }
end;

procedure Tmainwindow.compress_fpack1Click(Sender: TObject);
var
  Save_Cursor:TCursor;
  i: integer;
  filename1: string;
begin

  OpenDialog1.Title := 'Select multiple  FITS files to compress. Original files will be kept.';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := 'FITS files|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';

  esc_pressed:=false;

  if OpenDialog1.Execute then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }
    try { Do some lengthy operation }
        with OpenDialog1.Files do
        for I := 0 to Count - 1 do
        begin
          filename1:=Strings[I];
          Application.ProcessMessages;
          if ((esc_pressed) or (pack_cfitsio(filename1)=false)) then begin beep; mainwindow.caption:='Exit with error!!'; Screen.Cursor := Save_Cursor;  exit;end;
       end;
       finally

       mainwindow.caption:='Finished, all files compressed with extension .fz.';
      Screen.Cursor := Save_Cursor;  { Always restore to normal }
    end;
  end;
end;

procedure Tmainwindow.copy_to_clipboard1Click(Sender: TObject);
var
  tmpbmp: TBitmap;
  x1,x2,y1,y2,dum  : integer;
  SRect,DRect: TRect;

begin
  if abs(startX-stopX)<4 then
    Clipboard.Assign(Image1.Picture.Bitmap)
  else
  begin {selection}
    try
      TmpBmp := TBitmap.Create;
      try
        {convert array coordinates to screen coordinates}
        if flip_horizontal1.Checked then begin x1:=width2-1-startX;x2:=width2-stopX; end else begin x1:=startx;x2:=stopX;end;
        if flip_vertical1.Checked=false then begin y1:=height2-1-startY;y2:=height2-1-stopY; end else begin y1:=startY;y2:=stopY;end;

        TmpBmp.Width  := abs(x2-x1);
        TmpBmp.Height := abs(y2-y1);

        TmpBmp.Canvas.CopyMode := cmSrcCopy;
        SRect := Rect(x1,y1,x2,y2);
        DRect := Rect(0,0,TmpBmp.Width,TmpBmp.height);
        TmpBmp.Canvas.copyrect(DRect, mainwindow.Image1.canvas,SRect);
        Clipboard.Assign(TmpBmp);
      finally
         TmpBmp.Free;
      end;
      except
    end;
  end;
end;

procedure Tmainwindow.extract_pixel_11Click(Sender: TObject);
begin
  split_raw(1,1);{extract one of the Bayer matrix pixels}
end;

procedure Tmainwindow.extract_pixel_12Click(Sender: TObject);
begin
  split_raw(1,2);{extract one of the Bayer matrix pixels}
end;

procedure Tmainwindow.extract_pixel_22Click(Sender: TObject);
begin
  split_raw(2,2);{extract one of the Bayer matrix pixels}
end;

procedure Tmainwindow.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
begin
 {no check on file extension required}
  filename2:=FileNames[0];
   if load_image(true,true {plot}){load and center}=false then beep;{image not found}
end;

procedure Tmainwindow.histogram_range1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  use_histogram(img_loaded,false {update});{get histogram}
  plot_fits(mainwindow.image1,false,true);
end;

procedure Tmainwindow.histogram_values_to_clipboard1Click(Sender: TObject); {copy histogram values to clipboard}
var
  c    : integer;
  info : string;
begin
//  histogram : array[0..2,0..65535] of integer;{red,green,blue,count}
  info:='';
  for c := 0 to 65535 do
  begin
     info:=info+inttostr(c)+#9+inttostr(histogram[0,c]);
     if naxis3>1 then info:=info+#9+inttostr(histogram[1,c])+#9+inttostr(histogram[2,c]);{add green and blue if colour image}
     if c=0 then info:=info+ #9+'Value, Red count, Green count, Blue count';
     info:=info+slinebreak;
  end;
  Clipboard.AsText:=info;
end;

procedure Tmainwindow.imageflipv1Click(Sender: TObject);
var
  col,fitsX,fitsY : integer;
  vertical             :boolean;
  Save_Cursor:TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  backup_img;

  vertical:= ((sender=imageflipv1) or (sender=stackmenu1.stack_button1));

  setlength(img_temp,naxis3, width2,height2);

  for col:=0 to naxis3-1 do {do all colours}
  begin
    For fitsY:=0 to (height2-1) do
      for fitsX:=0 to (width2-1) do
      begin
        if vertical then img_temp[col, fitsX,(height2-1)-fitsY]:=img_loaded[col,fitsX,fitsY]
        else
        img_temp[col,(width2-1)-fitsX,fitsY]:=img_loaded[col,fitsX,fitsY];
      end;
  end;

  img_loaded:=img_temp;
  img_temp:=nil;
  plot_fits(mainwindow.image1,false,true);

  if cd1_1<>0 then {update solution for rotation}
  begin
    if vertical then {rotate right}
    begin
      cd1_2:=-cd1_2;
      cd2_2:=-cd2_2;
    end
    else
    begin {rotate horizontal}
      cd1_1:=-cd1_1;
      cd2_1:=-cd2_1;
    end;
    new_to_old_WCS;{convert new style FITS to old style, calculate crota1,crota2,cdelt1,cdelt2}

    update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_1);
    update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_2);
    update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_1);
    update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_2);

    update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,cdelt1);
    update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,cdelt2);

    update_float  ('CROTA1  =',' / Image twist of X axis        (deg)             ' ,crota1);
    update_float  ('CROTA2  =',' / Image twist of Y axis        (deg)             ' ,crota2);

    remove_key('ROWORDER',false{all});{just remove to be sure no debayer confusion}
    add_text     ('HISTORY   ','Flipped.                                                           ');
    plot_north;
  end;
  Screen.Cursor := Save_Cursor;  { Always restore to normal }
end;


procedure Tmainwindow.measuretotalmagnitude1Click(Sender: TObject);
var
   fitsX,fitsY,dum,font_height,counter,tx,ty,saturation_counter : integer;
   flux,bg_median,value,sd : double;
   Save_Cursor           : TCursor;
   mag_str               : string;
   bg_array              : array of double;
begin
  if ((cd1_1=0) or (fits_file=false)) then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    if flux_magn_offset=0 then {calibrate}
       plot_stars(true {if true photometry only}, false {show Distortion});
    if flux_magn_offset=0 then begin beep; exit;end;

    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img;

    tx:=stopX;
    ty:=stopY;
    if mainwindow.Flip_horizontal1.Checked then {restore based on flipped conditions}
      tx:=width2-1-tx;
    if mainwindow.flip_vertical1.Checked=false then
      ty:=height2-1-ty;


    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

    setlength(bg_array,5000);

    {measure the median of the suroundings}
    counter:=0;
    sd:=0;
    for fitsY:=startY+1-5 to stopY-1+5 do {calculate mean at square boundaries of detection box}
    for fitsX:=startX+1-5 to stopX-1+5 do
    begin
      if ( (fitsX<startX) or  (fitsX>stopX-1) or (fitsY<startY) or  (fitsY>stopY-1) ) then {measure only outside the box}
      begin
        if counter>=length(bg_array) then  SetLength(bg_array,counter+5000);{increase length}
        bg_array[counter]:=img_loaded[0,fitsX,fitsY];
        inc(counter);
      end;
    end;
    if counter>0 then
    begin
      SetLength(bg_array,counter);{set length correct}
      bg_median:=Smedian(bg_array)
    end
    else
    bg_median:=9999999;{something went wrong}

    saturation_counter:=0;
    flux:=0;
    for fitsY:=startY+1 to stopY-1 do {within rectangle}
    for fitsX:=startX+1 to stopX-1 do
    begin
      value:=img_loaded[0,fitsX+1,fitsY+1]- bg_median;
      flux:=flux+value;{add all flux. Without stars it should average zero. Detecting flux using >3*sd misses too much signal comets}
      if value>65000 then inc(saturation_counter);{keep track of number of saturated pixels}
    end;
    if flux<1 then flux:=1;
    str(flux_magn_offset-ln(flux)*2.511886432/ln(10):0:1,mag_str);
    if (saturation_counter*65500/flux)<0.01 then mag_str:='MAGN='+mag_str {allow about 1% saturation}
                                            else mag_str:='MAGN <'+mag_str+', '+inttostr(saturation_counter) +' saturated pixels !';

    image1.Canvas.brush.Style:=bsClear;
    image1.Canvas.font.color:=$00AAFF; {orange}
    image1.Canvas.font.size:=12;

    {$ifdef mswindows}
    SetTextAlign(canvas.handle, ta_left or ta_top or TA_NOUPDATECP);{always, since Linux is doing this fixed}
    setbkmode(canvas.handle,TRANSPARENT); {transparent}
    font_height:=round(canvas.Textheight('0')*1.2);{font size times ... to get underscore at the correct place. Fonts coordinates are all top/left coordinates }
    {$else} {Linux}
    font_height:=round(canvas.Textheight('0')*1.0);{font size times ... to get underscore at the correct place. Fonts coordinates are all top/left coordinates }
    {$endif}

    image1.Canvas.textout(3+tx,round(-font_height + ty), mag_str);

    bg_array:=nil;{free mem}

    Screen.Cursor:=Save_Cursor;
  end{fits file}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);
end;

procedure Tmainwindow.loadsettings1Click(Sender: TObject);
begin
  OpenDialog1.Title := 'Open settings';
  opendialog1.Filter := '(configuration file|*.cfg';
  opendialog1.initialdir:=user_path;
  if opendialog1.execute then
  begin
    with stackmenu1 do {clear exisiting lists}
    begin
      listview1.clear;
      listview2.clear;
      listview3.clear;
      listview4.clear;
      listview6.clear;
      listview7.clear;
      listview8.clear;
    end;
    load_settings(opendialog1.filename);
  end;
end;

procedure Tmainwindow.localbackgroundequalise1Click(Sender: TObject);
var
   fitsX,fitsY,dum,k,bsize,startX2,startY2,stopX2,stopY2,progress_value  : integer;
   mode_left_bottom,mode_left_top, mode_right_top, mode_right_bottom,
   center_x,center_y,a,b,angle_from_center,new_value : double;
   line_bottom, line_top : double;

   Save_Cursor:TCursor;
begin
  if fits_file=false then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img;
    bsize:=min(15,abs(stopX-startX));{15 or smaller}

    startX2:=startX;{save for Application.ProcessMessages;this could change startX, startY}
    startY2:=startY;
    stopX2:=stopX;
    stopY2:=stopY;

    if startX2>stopX2 then begin dum:=stopX2; stopX2:=startX2; startX2:=dum; end;{swap}
    if startY2>stopY2 then begin dum:=stopY2; stopY2:=startY2; startY2:=dum; end;

    {ellipse parameters}
    center_x:=(startX2+stopX2-1)/2;
    center_y:=(startY2+stopY2-1)/2;
    a:=(stopX2-1-startX2)/2;
    b:=(stopY2-1-startY2)/2;

    {prepare a smooth background image}
    setlength(img_buffer,naxis3,stopX2-startX2,stopY2-startY2);{new size}
    setlength(img_temp,naxis3,stopX2-startX2,stopY2-startY2);{new size}
    for k:=0 to naxis3-1 do
    for fitsY:=startY2 to stopY2-1 do
    for fitsX:=startX2 to stopX2-1 do img_buffer[k,fitsX-startX2,fitsY-startY2]:=img_loaded[k,fitsX,fitsY];{copy section of interest}
    apply_most_common(img_buffer,img_temp,bsize); {apply most common filter on first array and place result in second array}
    gaussian_blur2(img_temp,bsize+bsize);

    {correct image}
    for k:=0 to naxis3-1 do {do all colors}
    begin
      mode_left_bottom:=mode(img_loaded,k,startX2-bsize,startX2+bsize,startY2-bsize,startY2+bsize,32000);{for this area get most common value equals peak in histogram}
      mode_left_top:=   mode(img_loaded,k,startX2-bsize,startX2+bsize,stopY2-bsize,stopY2+bsize,32000);{for this area get most common value equals peak in histogram}

      mode_right_bottom:=mode(img_loaded,k,stopX2-bsize,stopX2+bsize,startY2-bsize,startY2+bsize,32000);{for this area get most common value equals peak in histogram}
      mode_right_top:=   mode(img_loaded,k,stopX2-bsize,stopX2+bsize,stopY2-bsize,stopY2+bsize,32000);{for this area get most common value equals peak in histogram}

      {apply correction}
      for fitsY:=startY2 to stopY2-1 do
      begin
        if frac(fitsY/50)=0 then
        begin
          Application.ProcessMessages;{this could change startX, startY}
          if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
          progress_value:=round(100*( k/naxis3 +  0.3333*(fitsY-startY2)/(stopY2-startY2)));
          progress_indicator(progress_value,'');{report progress}
        end;

        for fitsX:=startX2 to stopX2-1 do
        begin
          angle_from_center:=arctan(abs(fitsY-center_Y)/max(1,abs(fitsX-center_X)));
          if sqr(fitsX-center_X)+sqr(fitsY-center_Y)  <= sqr(a*cos(angle_from_center))+ sqr(b*sin(angle_from_center)) then     {within the ellipse}
          begin
            line_bottom:=mode_left_bottom*(stopX2-fitsx)/(stopX2-startX2)+ mode_right_bottom *(fitsx-startX2)/(stopX2-startX2);{median value at bottom line}
            line_top:=  mode_left_top *   (stopX2-fitsx)/(stopX2-startX2)+ mode_right_top*(fitsx-startX2)/(stopX2-startX2);{median value at top line}
            new_value:=line_bottom*(stopY2-fitsY)/(stopY2-startY2)+line_top*(fitsY-startY2)/(stopY2-startY2);{median value at position FitsX, fitsY}

            img_loaded[k,fitsX,fitsY]:=img_loaded[k,fitsX,fitsY] +(new_value-img_temp[k,fitsX-startX2,fitsY-startY2]);
          end;
        end;
      end;
    end;{k color}

    plot_fits(mainwindow.image1,false,true);
    progress_indicator(-100,'');{back to normal}
    Screen.Cursor:=Save_Cursor;
  end {fits file}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);
end;

procedure Tmainwindow.menucopy1Click(Sender: TObject);{for fits header memo1 popup menu}
begin
  Clipboard.AsText:=copy(Memo1.Text,Memo1.SelStart+1, Memo1.SelLength);
end;

procedure Tmainwindow.Menufind1Click(Sender: TObject); {for fits header memo1 popup menu}
begin
  PatternToFind:=uppercase(inputbox('Find','Text to find in fits header:' ,PatternToFind));
  position_find := pos(PatternToFind, uppercase( Memo1.Text));
  if position_find > 0 then
  begin
     Memo1.SelStart := position_find-1;
     Memo1.SelLength := Length(PatternToFind);
     Memo1.SetFocus; // necessary so highlight is visible
  end;
end;

procedure Tmainwindow.menufindnext1Click(Sender: TObject);{for fits header memo1 popup menu}
begin
  position_find := posex(PatternToFind, uppercase(Memo1.Text),position_find+1);
  if position_find > 0 then
  begin
     Memo1.SelStart := position_find-1;
     Memo1.SelLength := Length(PatternToFind);
     Memo1.SetFocus; // necessary so highlight is visible
  end;
end;

procedure Tmainwindow.copy_paste_tool1Click(Sender: TObject);
var
  dum,stopX2,stopY2, startX2, startY2 : integer;
begin
  if fits_file=false then exit;
  if  ((abs(stopX-startX)>1)and (abs(stopY-starty)>1)) then
  begin
    Screen.Cursor := crDrag;
    backup_img;{required in case later ctrl-z is used}

    if startX>stopX then begin dum:=stopX; stopX2:=startX; startX2:=dum; end else  begin stopX2:=stopX; startX2:=startX; end; {swap if required}
    if startY>stopY then begin dum:=stopY; stopY2:=startY; startY2:=dum; end else  begin stopY2:=stopY; startY2:=startY; end;

    copy_paste_x:=startX2+1;{take the inside of the rectangle} {save for Application.ProcessMessages in copy_paste_x; This could change startX, startY}
    copy_paste_y:=startY2+1;

    copy_paste_w:=stopX2-copy_paste_x;
    copy_paste_h:=stopY2-copy_paste_y;
    copy_paste:=true;
  end {fits file}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);
end;

procedure Tmainwindow.MenuItem21Click(Sender: TObject);
begin
  split_raw(2,1);{extract one of the Bayer matrix pixels}
end;

procedure Tmainwindow.batch_rotate_left1Click(Sender: TObject);
var
  i         : integer;
  dobackup : boolean;
begin

  OpenDialog1.Title := 'Select multiple  files to rotate 90 degrees';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.FIT*';
  //data_range_groupBox1.Enabled:=true;
  esc_pressed:=false;

  if OpenDialog1.Execute then
  begin
    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}

    try { Do some lengthy operation }
       with OpenDialog1.Files do
       for i := 0 to Count - 1 do
       begin
         filename2:=Strings[i];
         {load fits}
         Application.ProcessMessages;
         if ((esc_pressed) or (load_fits(filename2,true {light},true,img_loaded)=false)) then begin exit;end;

         rotateleft1Click(Sender);
         save_fits(img_loaded,FileName2,16,true);{overwrite}
      end;
      finally
      if dobackup then restore_img;{for the viewer}
    end;
  end;
end;

procedure Tmainwindow.angular_distance1Click(Sender: TObject);
var
   shapetype                 : integer;
   hfd1,star_fwhm,snr,flux,xc,yc,
   hfd2,star_fwhm2,snr2,flux2,xc2,yc2,angle,shape_fitsX,shape_fitsY     : double;
   info_message,info_message2 : string;
   Save_Cursor              : TCursor;
begin
  if fits_file=false then exit;

  if  ((abs(stopX-startX)>2) or (abs(stopY-starty)>2)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img;

    HFD(img_loaded,startX,startY,14{box size}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}

    if ((hfd1<15) and (hfd1>=0.8) {two pixels minimum} and (snr>10) and (flux>1){rare but happens}) then {star detected in img_loaded}
    begin
      shapetype:=1;{circle}
      shape_marker1_fitsX:=xc+1;{store fits value for zoom}
      shape_marker1_fitsY:=yc+1;
    end
    else
    begin
       info_message:='Object 1, no lock'+#10;
       shape_marker1_fitsX:=startX+1;{store fits value for zoom}
       shape_marker1_fitsY:=startY+1;
       shapetype:=0;{rectangle}
    end;
    show_marker_shape(mainwindow.shape_marker1,shapetype,20,20,10{minimum}, shape_marker1_fitsX,shape_marker1_fitsY);

    HFD(img_loaded,stopX,stopY,14{box size}, hfd2,star_fwhm2,snr2,flux2,xc2,yc2);{star HFD and FWHM}
    if ((hfd2<15) and (hfd2>=0.8) {two pixels minimum} and (snr2>10) and (flux2>1){rare but happens}) then {star detected in img_loaded}
    begin
      shapetype:=1;{circle}
      shape_marker2_fitsX:=xc2+1;{store fits value for zoom}
      shape_marker2_fitsY:=yc2+1;
    end
    else
    begin
       info_message:=info_message+'Object 2, no lock'+#10;
       shape_marker2_fitsX:=stopX+1;{store fits value for zoom}
       shape_marker2_fitsY:=stopY+1;
       shapetype:=0;{rectangle}
    end;
    show_marker_shape(mainwindow.shape_marker2,shapetype,20,20,10{minimum},shape_marker2_fitsX,shape_marker2_fitsY);

    angle:=fnmodulo (arctan2(shape_marker2_fitsX-shape_marker1_fitsX,shape_marker2_fitsY-shape_marker1_fitsY)*180/pi + crota2,360);

    info_message2:=floattostrf(sqrt(sqr(shape_marker2_fitsX-shape_marker1_fitsX)+sqr(shape_marker2_fitsY-shape_marker1_fitsY))*cdelt2*3600,ffgeneral,5,5);
    if cdelt2<>0 then  info_message2:=info_message2+'"'
                 else  info_message2:=info_message2+' pixels';

    info_message2:=info_message2+#9+'        ∠='+floattostrf(angle,ffgeneral,5,5)+'°';

    case  QuestionDlg (pchar('Angular distance '),pchar(info_message+info_message2),mtCustom,[mrYes,'Copy to clipboard?', mrNo, 'No', 'IsDefault'],'') of
             mrYes: Clipboard.AsText:=info_message2;
    end;

    Screen.Cursor:=Save_Cursor;
  end {fits file}
  else
  application.messagebox(pchar('No distance selected! Hold the right mouse button down while moving from first to second star.'),'',MB_OK);
end;


procedure Tmainwindow.j2000_1Click(Sender: TObject);
begin
   if j2000_1.checked then
   begin
     coord_frame:=0;
     galactic1.checked:=false;
   end;
end;


procedure Tmainwindow.galactic1Click(Sender: TObject);
begin
  if galactic1.checked then
  begin
    coord_frame:=1;
    j2000_1.checked:=false;
   end;
end;




procedure do_stretching;{prepare strecht table and replot image}
var
  i: integer;
  stretch,divider: single;
begin
    stretch:=strtofloat2(mainwindow.stretch1.Text);
    if stretch<=0.5 then {word "off" gives zero}
    stretch_on:=false
    else
    begin
      stretch_on:=true;
      divider:=arcsinh(stretch);
      for i:=0 to 32768 do stretch_c[i]:=arcsinh((i/32768.0)*stretch)/divider;{prepare table}
    end;

  if mainwindow.stretch1.enabled then {file loaded}
  begin
    use_histogram(img_loaded,false {update});{get histogram}
    plot_fits(mainwindow.image1,false,true);
  end;
end;


procedure Tmainwindow.range1Change(Sender: TObject);
begin
  do_stretching;
end;


procedure Tmainwindow.remove_atmouse1Click(Sender: TObject);
var
  left_dist, right_dist, top_dist, bottom_dist : double;
begin
  left_dist:=down_x/image1.width;{range 0..1}
  right_dist:=1-left_dist;{range 0..1}
  top_dist:=down_y/image1.height;{range 0..1}
  bottom_dist:=1-top_dist;{range 0..1}

  if ((left_dist<right_dist) and (left_dist<top_dist) and (left_dist<bottom_dist)) then mainwindow.remove_left1Click(nil) else
  if ((right_dist<left_dist) and (right_dist<top_dist) and (right_dist<bottom_dist)) then mainwindow.remove_right1Click(nil) else
  if ((top_dist<left_dist) and (top_dist<right_dist) and (top_dist<bottom_dist)) then mainwindow.remove_above1Click(nil) else
  if ((bottom_dist<left_dist) and (bottom_dist<right_dist) and   (bottom_dist<top_dist)) then mainwindow.remove_below1Click(nil);
end;


procedure Tmainwindow.gradient_removal1Click(Sender: TObject);
var
   colrr1,colgg1,colbb1,colrr2,colgg2,colbb2                      : single;
   a,b,c,p : double;

   fitsX,fitsY,bsize  : integer;

   Save_Cursor:TCursor;
begin
  if fits_file=false then exit;
  if  ((abs(stopX-startX)>100) OR (abs(stopY-starty)>100)) then {or function since it could be parallel to x or y axis}
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img;

    bsize:=20;
    colrr1:=mode(img_loaded,0,startX-bsize,startX+bsize,startY-bsize,startY+bsize,65535);{find most common colour of a local area}
    if naxis3>1 then colgg1:=mode(img_loaded,1,startX-bsize,startX+bsize,startY-bsize,startY+bsize,65535);{find most common colour of a local area}
    if naxis3>2 then colbb1:=mode(img_loaded,2,startX-bsize,startX+bsize,startY-bsize,startY+bsize,65535);{find most common colour of a local area}

    colrr2:=mode(img_loaded,0,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize,65535);{find most common colour of a local area}
    if naxis3>1 then colgg2:=mode(img_loaded,0,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize,65535);{find most common colour of a local area}
    if naxis3>2 then colbb2:=mode(img_loaded,0,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize,65535);{find most common colour of a local area}

    a:=sqrt(sqr(stopX-startX)+sqr(stopY-startY)); {distance between bright and dark area}

    for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1 do
      begin
        b:=sqrt(sqr(fitsX-startX)+sqr(fitsY-startY)); {distance from dark spot}
        c:=sqrt(sqr(fitsX-stopX)+sqr(fitsY-stopY)); {distance from bright spot}
        p:=-((sqr(b)-sqr(a)-sqr(c))/(2*a)); {projectiestelling scheefhoekige driehoek (Dutch), polytechnisch zakboekje 42 edition, a2/24 3.2}

        img_loaded[0,fitsX,fitsY]:=img_loaded[0,fitsX,fitsY]-(colrr2-colrr1)*(a-p)/a;
        if naxis3>1 then img_loaded[1,fitsX,fitsY]:=img_loaded[1,fitsX,fitsY]-(colgg2-colgg1)*(a-p)/a;
        if naxis3>2 then img_loaded[2,fitsX,fitsY]:=img_loaded[2,fitsX,fitsY]-(colbb2-colbb1)*(a-p)/a;
      end;

    use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
    plot_fits(mainwindow.image1,false {re_center},true);

    Screen.Cursor:=Save_Cursor;
  end {fits file}
  else
  application.messagebox(pchar('Place the mouse pointer at a dark area. Hold the right mouse button down and move the mouse pointer to a bright area.'+#10+#10+
                               'Try to select two areas without a deepsky object within 20 pixels.'+#10+#10+
                               'Moving from the dark area to the bright area should follow the direction of the gradient.'),'',MB_OK);
end;


procedure Tmainwindow.remove_longitude_latitude1Click(Sender: TObject);
var
  I: integer;
  Save_Cursor:TCursor;
  err   : boolean;
  dobackup : boolean;
begin
  OpenDialog1.Title := 'Select multiple  files to remove the observation location from';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=  'All formats except TIF|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP;*.new;*.ppm;*.pgm;*.pbm;*.pfm;*.xisf;*.fz;'+
                                      '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                         '|RAW files|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                         '|24 bits PNG, JPEG, BMP(*.png, *.jpg,*.bmp)|*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP'+
                         '|Compressed FITS files|*.fz';
  opendialog1.initialdir:=ExtractFileDir(filename2);
  fits_file:=false;
  esc_pressed:=false;
  err:=false;
  if OpenDialog1.Execute then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }
    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}

    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        Application.ProcessMessages;
        if esc_pressed then begin Screen.Cursor := Save_Cursor;  exit;end;
        filename2:=Strings[I];
        mainwindow.caption:=filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count);;
        if load_image(false {recenter},false {plot}) then
        begin
          remove_key('SITELAT =',true{all});
          remove_key('SITELONG=',true{all});
          SaveFITSwithupdatedheader1Click(nil);
        end
        else err:=true;
      end;
      if err=false then mainwindow.caption:='Completed, all files converted.'
      else
      begin
        beep;
        ShowMessage('Errors!! Files modified but with errors!!');
      end;
      finally
      if dobackup then restore_img;{for the viewer}
      Screen.Cursor := Save_Cursor;  { Always restore to normal }
    end;
  end;
end;


procedure Tmainwindow.selectfont1Click(Sender: TObject);
begin
  FontDialog1.font.size:=font_size;
  FontDialog1.font.color:=font_color;
  FontDialog1.font.name:=font_name;
  FontDialog1.font.style:= font_style;
  FontDialog1.font.charset:=font_charset;  {note Greek=161, Russian or Cyrillic =204}

  FontDialog1.Execute;

  font_color:=FontDialog1.font.color;
  font_size:=FontDialog1.font.size;
  font_name:=FontDialog1.font.name;
  font_style:=FontDialog1.font.style;
  font_charset:=FontDialog1.font.charset; {select cyrillic for RussiaN}

  memo1.font.color:=font_color;
  memo1.font.size:=font_size;
  memo1.font.name:=font_name;
  memo1.font.style:=font_style;
  memo1.font.charset:=font_charset;
end;


procedure Tmainwindow.select_all1Click(Sender: TObject);
begin
   memo1.setfocus;{required for selectall since hideselection is enabled when not having focus}
   Memo1.SelectAll;
end;

procedure Tmainwindow.menupasteClick(Sender: TObject);{for fits header memo1 popup menu}
var
  I : integer;
  S,T : string;
begin
  with Memo1 do
  begin
    I:= SelStart;
    S:= Memo1.Text;
    T:=Clipboard.AsText;
    system.insert(T, S, SelStart + 1);
    Text:= S;
    SelStart:= I + length(T);
  end;
end;


procedure Tmainwindow.annotate_minor_planets1Click(Sender: TObject);
begin
  form_asteroids1:=Tform_asteroids1.Create(self); {in project option not loaded automatic}
  form_asteroids1.ShowModal;
  form_asteroids1.release;
  save_settings(user_path+'astap.cfg');
end;


procedure Tmainwindow.radec_copy1Click(Sender: TObject);
begin
  if ra1.focused then Clipboard.AsText:=ra1.text;
  if dec1.focused then Clipboard.AsText:=dec1.text;

end;


procedure Tmainwindow.radec_paste1Click(Sender: TObject);
begin
  if ra1.focused then ra1.text:=Clipboard.AsText;
  if dec1.focused then dec1.text:=Clipboard.AsText;
end;


procedure Tmainwindow.radec_search1Click(Sender: TObject);
begin
  search_database;
end;


procedure Tmainwindow.save_settings1Click(Sender: TObject);
begin
  save_settings(user_path+'astap.cfg');
end;


procedure measure_magnitudes(var stars :star_list);{find stars and return, x,y, hfd, flux}
var
  fitsX,fitsY,size, i, j,nrstars    : integer;
  hfd1,star_fwhm,snr,flux,xc,yc : double;
begin

  SetLength(stars,4,5000);{set array length}

  setlength(img_temp,1,width2,height2);{set length of image array}

  get_background(0,img_loaded,false{histogram is already available},true {calculate noise level},{var}cblack,star_level);{calculate background level from peek histogram}

  nrstars:=0;{set counters at zero}

  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1  do
      img_temp[0,fitsX,fitsY]:=-1;{mark as not surveyed}

  for fitsY:=0 to height2-1-1 do
  begin
    for fitsX:=0 to width2-1-1  do
    begin
      if (( img_temp[0,fitsX,fitsY]<=0){area not surveyed} and (img_loaded[0,fitsX,fitsY]- cblack>star_level{ 5*noise_level[0]}){star}) then {new star}
      begin
        HFD(img_loaded,fitsX,fitsY,14{box size}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
        if ((hfd1<15) and (hfd1>=0.8) {two pixels minimum} and (snr>10) and (flux>1){rare but happens}) then {star detected in img_loaded}
        begin
          {for testing}
          //if flipvertical=false  then  starY:=round(height2-yc) else starY:=round(yc);
          //if fliphorizontal=true then starX:=round(width2-xc)  else starX:=round(xc);
          //  size:=round(5*hfd1);
          //  mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
          //  mainwindow.image1.Canvas.textout(starX+size,starY+size,floattostrf(hfd1, ffgeneral, 2,1));{add hfd as text}

          if ((img_loaded[0,round(xc),round(yc)]<65000) and
              (img_loaded[0,round(xc-1),round(yc)]<65000) and
              (img_loaded[0,round(xc+1),round(yc)]<65000) and
              (img_loaded[0,round(xc),round(yc-1)]<65000) and
              (img_loaded[0,round(xc),round(yc+1)]<65000) and

              (img_loaded[0,round(xc-1),round(yc-1)]<65000) and
              (img_loaded[0,round(xc-1),round(yc+1)]<65000) and
              (img_loaded[0,round(xc+1),round(yc-1)]<65000) and
              (img_loaded[0,round(xc+1),round(yc+1)]<65000)  ) then {not saturated}
           begin
             size:=round(3*hfd1);
             for j:=fitsY to fitsY+size do {mark the whole star area as surveyed}
               for i:=fitsX-size to fitsX+size do
                if ((j>=0) and (i>=0) and (j<height2) and (i<width2)) then {mark the area of the star square and prevent double detections}
                  img_temp[0,i,j]:=1;

            {store values}
            inc(nrstars);
            if nrstars>=length(stars[0]) then
            begin
              SetLength(stars,4,nrstars+5000);{adapt array size if required}
            end;
            stars[0,nrstars-1]:=xc; {store star position}
            stars[1,nrstars-1]:=yc;
            stars[2,nrstars-1]:=hfd1;
            stars[3,nrstars-1]:=flux;
          end;{not saturated}
        end;{HFD good}
      end;
    end;
  end;

  img_temp:=nil;{free mem}

  SetLength(stars,4,nrstars+1);{set length correct}
end;


procedure Tmainwindow.annotate_with_measured_magnitudes1Click(Sender: TObject);
var
 size, i, starX, starY         : integer;
 Save_Cursor:TCursor;
 Fliphorizontal, Flipvertical  : boolean;
 stars : star_list;

 begin
  if fits_file=false then exit; {file loaded?}
  if flux_magn_offset=0 then {calibrate}
     plot_stars(true {if true photometry only}, false {show Distortion});

  if flux_magn_offset=0 then begin
    beep;
    exit;
  end;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  Flipvertical:=mainwindow.flip_vertical1.Checked;
  Fliphorizontal:=mainwindow.Flip_horizontal1.Checked;

  image1.Canvas.Pen.Mode := pmMerge;
  image1.Canvas.Pen.width :=1; // round(1+height2/image1.height);{thickness lines}
  image1.Canvas.brush.Style:=bsClear;
  image1.Canvas.font.color:=clyellow;
  image1.Canvas.font.size:=10; //round(max(10,8*height2/image1.height));{adapt font to image dimensions}
  mainwindow.image1.Canvas.Pen.Color := clred;

  measure_magnitudes(stars);

  for i:=0 to  length(stars[0])-2 do
  begin
    size:=round(5*stars[2,i]);{5*hfd}
    if Flipvertical=false then  starY:=round(height2-stars[1,i]) else starY:=round(stars[1,i]);
    if Fliphorizontal     then starX:=round(width2-stars[0,i])  else starX:=round(stars[0,i]);

    image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
    image1.Canvas.textout(starX+size,starY,inttostr(round((flux_magn_offset-ln(stars[3,i]{flux})*2.511886432/ln(10))*10))   );{add hfd as text}
  end;
  Screen.Cursor:= Save_Cursor;
end;


procedure Tmainwindow.annotations_visible1Click(Sender: TObject);
begin
  if annotations_visible1.checked=false then  {clear screen}
    plot_fits(mainwindow.image1,false,true)
  else
  if annotated then plot_annotations(0,0,false);
end;


procedure Tmainwindow.autocorrectcolours1Click(Sender: TObject);
begin
  stackmenu1.auto_background_level1Click(nil);
  stackmenu1.apply_factor1Click(nil);
end;


procedure Tmainwindow.batch_annotate1Click(Sender: TObject);
var
  I: integer;
  Save_Cursor:TCursor;
  skipped, nrannotated :integer;
  dobackup : boolean;
begin
  OpenDialog1.Title := 'Select multiple  files to add asteroid annotation to the header';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS';
  esc_pressed:=false;

  if OpenDialog1.Execute then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    nrannotated:=0;
    skipped:=0;

    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}

    try { Do some lengthy operation }
        with OpenDialog1.Files do
        for I := 0 to Count - 1 do
        begin
          filename2:=Strings[I];
          memo2_message('Annotating: '+filename2);
          Application.ProcessMessages;
          if esc_pressed then begin Screen.Cursor := Save_Cursor;  exit;end;

          if load_fits(filename2,true {light},true,img_loaded) then {load image success}
          begin
            if cd1_1=0 then
            begin
              skipped:=skipped+1; {not astrometric solved}
              memo2_message('Skipped: '+filename2+' No solution in header found. First batch solve the images');
            end
            else
            begin
              plot_mpcorb(strtoint(maxcount_asteroid),strtofloat2(maxmag_asteroid),true {add annotations});
              mainwindow.SaveFITSwithupdatedheader1Click(nil);
              nrannotated :=nrannotated +1;
            end;
          end;
        end;
      finally
      if dobackup then restore_img;{for the viewer}
      Screen.Cursor := Save_Cursor;  { Always restore to normal }
    end;
    memo2_message(inttostr(nrannotated)+' images annotated, '+inttostr(skipped)+' images did not have an astrometric solution in the header.');
  end;
end;


procedure Tmainwindow.batch_solve_astrometry_netClick(Sender: TObject);
begin
  form_astrometry_net1:=Tform_astrometry_net1.Create(self); {in project option not loaded automatic}
  form_astrometry_net1.ShowModal;
  form_astrometry_net1.release;
end;


procedure Tmainwindow.add_marker_position1Click(Sender: TObject);
begin
  if add_marker_position1.checked then
  begin
    marker_position:=InputBox('Enter α, δ position seperated by a comma.','23 00 00.0,  89 00 00.0 ',marker_position );
    if marker_position='' then begin add_marker_position1.checked:=false; exit; end;

    add_marker_position1.checked:=place_marker_radec(marker_position);{place a marker}
    mainwindow.shape_marker3.hint:=marker_position;
  end
  else
    mainwindow.shape_marker3.visible:=false;
end;


procedure Tmainwindow.SimpleIPCServer1MessageQueued(Sender: TObject);{For OneInstance, this event only occurs in Windows}
begin
  {$ifdef mswindows}
   receivemessage(Sender);
  {$else} {unix}
  {$endif}
end;


procedure Tmainwindow.StatusBar1MouseEnter(Sender: TObject);
begin
  if fits_file then
  begin
    Statusbar1.Panels[0].text:='α, δ';
    Statusbar1.Panels[1].text:='α, δ centered';
    Statusbar1.Panels[2].text:='Local standard deviation or star values';
    Statusbar1.Panels[3].text:='X, Y = [pixel value(s)]';
    Statusbar1.Panels[4].text:='RGB values screen';
    Statusbar1.Panels[7].text:='w x h   distance[arcsec]  angle';
  end;
end;


procedure Tmainwindow.stretch_draw_fits1Click(Sender: TObject);
var
  tmpbmp: TBitmap;
  ARect: TRect;
  oldcursor: tcursor;
  x, y    : Integer;
  xLine: PByteArray;
  ratio    : double;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor:= crHourGlass;

  backup_img;
  try
    TmpBmp := TBitmap.Create;
    try
      TmpBmp.Width  := mainwindow.image1.width;
      TmpBmp.Height := mainwindow.image1.height;
      ARect := Rect(0,0, mainwindow.image1.width, mainwindow.image1.height);
      TmpBmp.Canvas.StretchDraw(ARect, mainwindow.Image1.Picture.bitmap);

//      mainwindow.Image1.Picture.bitmap.Assign(TmpBmp);
      {move to array}
      ratio:=TmpBmp.width/width2;

      width2:=TmpBmp.width;
      height2:=TmpBmp.Height;

      setlength(img_loaded,naxis3,width2,height2);

      for y := 0 to height2 -1 do begin {place in array}
        xLine := TmpBmp.ScanLine[y];
        for x := 0 to width2 -1 do
        begin
          img_loaded[0,x,y]:=xLine^[x*3];{red}
          if naxis3>1 then img_loaded[1,x,y]:=xLine^[x*3+1];{green}
          if naxis3>2 then img_loaded[2,x,y]:=xLine^[x*3+2];{blue}
        end;
      end;

      update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
      update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);
      datamax_org:=255;
      update_integer('DATAMAX =',' / Maximum data value                             ' ,255);


      if crpix1<>0 then begin crpix1:=crpix1*ratio; update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,crpix1);end;
      if crpix2<>0 then begin crpix2:=crpix2*ratio; update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,crpix2);end;

      if cdelt1<>0 then begin cdelt1:=cdelt1/ratio; update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,cdelt1);end;
      if cdelt2<>0 then begin cdelt2:=cdelt2/ratio; update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,cdelt2);end;

      if cd1_1<>0 then
      begin
        cd1_1:=cd1_1/ratio;
        cd1_2:=cd1_2/ratio;
        cd2_1:=cd2_1/ratio;
        cd2_2:=cd2_2/ratio;
        update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_1);
        update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_2);
        update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_1);
        update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_2);
      end;

      update_float  ('XBINNING=',' / Binning factor in width                         ' ,XBINNING/ratio);
      update_float  ('YBINNING=',' / Binning factor in height                        ' ,YBINNING/ratio);

      if XPIXSZ<>0 then
      begin
        update_float('XPIXSZ  =',' / Pixel width in microns (after stretching)       ' ,XPIXSZ/ratio);{note: comment will be never used since it is an existing keyword}
        update_float('YPIXSZ  =',' / Pixel height in microns (after stretching)      ' ,YPIXSZ/ratio);
      end;
      add_text   ('HISTORY   ','Image stretched with factor '+ floattostr2(ratio));

      {plot result}
      use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
      plot_fits(mainwindow.image1,true {center_image},true);{center and stretch with current settings}

    finally
       TmpBmp.Free;
    end;
    except
  end;
  Screen.Cursor:=OldCursor;
end;


procedure Tmainwindow.variable_star_annotation1Click(Sender: TObject);
var
  Save_Cursor:TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass; { Show hourglass cursor }
  backup_img;
  load_variable;  { Load the database once. If loaded no action}
  plot_deepsky;{plot the deep sky object on the image}
  Screen.Cursor:=Save_Cursor;
end;


procedure check_second_instance;{For OneInstance, check for other instance of the application. If so send paramstr(1) and quit}
var
  Client: TSimpleIPCClient;
  other_instance : boolean;
  {$ifdef mswindows}
  {$else} {unix}
   Timer : ttimer;{for OneInstance in Linux}
  {$endif}
begin
  other_instance:=false;
  Client := TSimpleIPCClient.Create(nil);
  with Client do
  begin
  try
    ServerID:=mainwindow.SimpleIPCServer1.ServerID; {copy the id from the server to the client}
    if Client.ServerRunning then {An older instance is running.}
    begin
      other_instance:=true;
      Active := True;
      SendStringMessage(paramstr(1));{send paramstr(1) to the server of the first instance}
    end;
  except
  end;
    Free; {client}
  end;
  if other_instance then
  begin
    Application.ShowMainForm := False;
    Application.Terminate;
  end
  else
  begin
    mainwindow.SimpleIPCServer1.active:=true; {activate IPCserver}
    {$ifdef mswindows}
    {$else} {unix}
    Timer := TTimer.Create(nil); {In Linux no event occurs in MessageQueued. Trigger receive message by timer}
    Timer.Interval := 300; {300 ms interval}
    Timer.OnTimer := mainwindow.receivemessage; {on timer event do receivemessage}
    {$endif}
  end;
end;


procedure Tmainwindow.FormCreate(Sender: TObject);
var
   param1: string;
begin
  {OneInstance, if one parameter specified, so if user cicks on an associated image}
  if paramcount=1 then param1:=paramstr(1) else param1:='T';
  if ((paramcount=1) and  (ord(param1[length(param1)])>57  {letter, not a platesolve command} )) then {2019-5-4, modification only unique instance if called with file as parameter(1)}
    check_second_instance;{check for and other instance of the application. If so send paramstr(1) and quit}

  application_path:= extractfilepath(application.location);{for u290, set path}


  {$IfDef Darwin}// for OS X,
    database_path:='/usr/local/opt/astap/';
  {$else}
    database_path:=application_path;

    {$ifdef mswindows}
    {$else} {unix}
    if copy(database_path,1,4)='/usr' then {for Linux distributions}
      database_path:='/usr/share/astap/data/';
    {$endif}
  {$endif}

  application.HintHidePause:=5000;{display hint 5000 ms instead standard 2500}
  {application.HintPause:=1000;}
  application.HintShortPause:=1000;
  {$ifdef mswindows}
  Screen.Cursors[crMyCursor] := LoadCursor(HInstance, 'cross_cursor');
  {$else} {unix}
  Screen.Cursors[crMyCursor] := LoadCursor(HInstance, 'cross_cursor_linux');
  {$endif}
  image1.cursor:=crMyCursor;

  Application.OnHint := DisplayHint;

  deepstring := Tstringlist.Create;{for deepsky overlay}
  recent_files:= Tstringlist.Create;
end;


procedure Tmainwindow.deepsky_annotation1Click(Sender: TObject);
var
  Save_Cursor:TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  backup_img;
  load_deep;{load the deepsky database once. If loaded no action}
  plot_deepsky;{plot the deep sky object on the image}
  Screen.Cursor:=Save_Cursor;
end;


procedure Tmainwindow.add_marker1Click(Sender: TObject);
begin
  shape_marker1_fitsX:=startX+1;
  shape_marker1_fitsY:=startY+1;
  show_marker_shape(mainwindow.shape_marker1,0 {rectangle},20,20,0 {minimum size},shape_marker1_fitsX, shape_marker1_fitsY);
  shape_marker1.hint:='Marker';
end;


procedure Tmainwindow.center_lost_windowsClick(Sender: TObject);
begin
  mainwindow.left:=0;
  mainwindow.top:=0;
  stackmenu1.left:=0;
  stackmenu1.top:=0;
end;


procedure Tmainwindow.DisplayHint(Sender: TObject);
begin
  if ((length(GetlongHint(Application.Hint))>0)) then
  begin
     //  mainwindow.Caption:=GetlongHint(Application.Hint);
    statusbar1.SimplePanel:=true;
    statusbar1.Simpletext:=GetlongHint(Application.Hint);
  end
  else
  statusbar1.SimplePanel:=false;
end;


procedure Tmainwindow.FormDestroy(Sender: TObject);
begin
  settingstring.free;
  deepstring.free;{free deepsky}
  recent_files.free;
end;


procedure plot_rectangle(x1,y1,x2,y2: integer); {accurate positioned rectangle on screen coordinates}
begin
   with mainwindow.image1.Canvas do
   begin
     moveto(x1,y1);
     lineto(x1,y2);
     lineto(x2,y2);
     lineto(x2,y1);
     lineto(x1,y1);
   end;
end;


procedure plot_the_annotation(x1,y1,x2,y2:integer; typ:double; name,magn :string);
var
  size,xcenter,ycenter,text_height,text_width  :integer;
begin
  if mainwindow.Flip_horizontal1.Checked then {restore based on flipped conditions}
  begin
    x1:=(width2-1)-x1;
    x2:=(width2-1)-x2;
  end;
  if mainwindow.flip_vertical1.Checked=false then
  begin
    y1:=(height2-1)-y1;
    y2:=(height2-1)-y2;
  end;
  mainwindow.image1.Canvas.Pen.width:=max(1,round(1*abs(typ))); ;
  mainwindow.image1.Canvas.font.size:=max(12,round(12*abs(typ)));

  if typ>0 then {single line}
  begin
    mainwindow.image1.Canvas.moveto(x1,y1);
    mainwindow.image1.Canvas.lineto(x2,y2);
  end
  else
  begin {rectangle or two indicating lines}
     size:=abs(x2-x1);
     if size>20 then plot_rectangle(x1,y1,x2,y2) {accurate positioned rectangle on screen coordinates}
     else
     begin {two lines}
       xcenter:=(x2+x1) div 2;
       ycenter:=(y2+y1) div 2;
       mainwindow.image1.canvas.moveto(xcenter-(size div 2),ycenter);
       mainwindow.image1.canvas.lineto(xcenter-(size div 4),ycenter);
       mainwindow.image1.canvas.moveto(xcenter+(size div 2),ycenter);
       mainwindow.image1.canvas.lineto(xcenter+(size div 4),ycenter);
     end;
  end;

  text_height:=round(mainwindow.image1.canvas.Textheight(name));{font size times ... to get underscore at the correct place. Fonts coordinates are all top/left coordinates }
  text_width:=round(mainwindow.image1.canvas.Textwidth(name)); {font size times ... to get underscore at the correct place. Fonts coordinates are all top/left coordinates }

  if x2>=x1 then text_width:=0;
  if y2>=y1 then text_height:=text_height div 3;
  mainwindow.image1.Canvas.textout( -text_width+x2, -text_height + y2,name{name}+magn{magnitude});
end;


procedure plot_annotations(xoffset,yoffset:integer;fill_combo: boolean); {plot annotations stored in fits header. Offsets are for blink routine}
var
  count1,x1,y1,x2,y2 : integer;
  typ     : double;
  List: TStrings;
  name,magn : string;
begin
  List := TStringList.Create;
  list.StrictDelimiter:=true;

  mainwindow.image1.Canvas.Pen.Color:= annotation_color;{clyellow}

  mainwindow.image1.Canvas.brush.Style:=bsClear;
  mainwindow.image1.Canvas.font.color:=annotation_color;

  {$ifdef mswindows}
  SetTextAlign(mainwindow.image1.canvas.handle, ta_left or ta_top or TA_NOUPDATECP);{always, since Linux is doing this fixed}
  setbkmode(mainwindow.image1.canvas.handle,TRANSPARENT); {transparent}
  {$else} {Linux}
  {$endif}

  count1:=mainwindow.Memo1.Lines.Count-1;
  try
    while count1>=0 do {plot annotations}
    begin
      if copy(mainwindow.Memo1.Lines[count1],1,8)='ANNOTATE' then {found}
      begin
        List.Clear;
        ExtractStrings([';'], [], PChar(copy(mainwindow.Memo1.Lines[count1],12,posex(#39,mainwindow.Memo1.Lines[count1],20)-12)),List);

        if list.count>=6  then {correct annotation}
        begin
          x1:=round(strtofloat2(list[0]))-1 +xoffset;{subtract 1 for conversion fits coordinates 1... to screen coordinates 0...}
          y1:=round(strtofloat2(list[1]))-1 +yoffset;
          x2:=round(strtofloat2(list[2]))-1 +xoffset;
          y2:=round(strtofloat2(list[3]))-1 +yoffset;

          typ:=strtofloat2(list[4]);
          name:=list[5];
          if list.count>6  then  magn:=list[6] else magn:='';

          plot_the_annotation(x1,y1,x2,y2,typ, name,magn);

          if fill_combo then {add asteroid annotations to combobox for ephemeris alignment}
            stackmenu1.ephemeris_centering1.Additem(name,nil);
        end;
      end;
      count1:=count1-1;
    end;

  finally
    List.Free;
  end;
end;


procedure Tmainwindow.Enterlabel1Click(Sender: TObject);
var
  value : string;
  text_height,text_width,text_x,text_y,
  startX_screen,startY_screen,text_X_screen,text_Y_screen: integer;
  boldness                               : double;
begin
  backup_img;
  value:=InputBox('Label input:','','' );
  if value=''  then exit;

  mainwindow.image1.Canvas.Pen.width:=max(1,round(1*width2/image1.width)); ;
  mainwindow.image1.Canvas.Pen.Color:= annotation_color; {clyellow default}

  image1.Canvas.brush.Style:=bsClear;
  image1.Canvas.font.color:=annotation_color;
  image1.Canvas.font.size:=max(12,round(12*width2/image1.width));

  image1.Canvas.moveto(startX,startY);
  if ((stopX<>startx) or (stopY<>startY) )=true then {rubber rectangle in action}
  begin
    text_x:=stopX;
    text_y:=stopY;
  end
  else
  begin
    text_x:=startX+image1.Canvas.font.size;
    text_y:=startY+image1.Canvas.font.size;
  end;

  {$ifdef mswindows}
  SetTextAlign(image1.canvas.handle, ta_left or ta_top or TA_NOUPDATECP);{always, since Linux is doing this fixed}
  setbkmode(image1.canvas.handle,TRANSPARENT); {transparent}
  {$else} {Linux}
  {$endif}

  text_height:=round(image1.canvas.Textheight(value));{font size times ... to get underscore at the correct place. Fonts coordinates are all top/left coordinates }
  text_width:=round(image1.canvas.Textwidth(value)); {font size times ... to get underscore at the correct place. Fonts coordinates are all top/left coordinates }

  if stopX>=startX then text_width:=0;
  if stopY>=startY then text_height:=text_height div 3;

  startX:=startX+1; {convert to fits range 1...}
  startY:=startY+1; {convert to fits range 1...}
  text_X:=text_X+1; {convert to fits range 1...}
  text_Y:=text_Y+1; {convert to fits range 1...}

  if sender<>Enter_rectangle_with_label1 then boldness:=width2/image1.width else boldness:=-width2/image1.width;

  plot_the_annotation(startX,startY,text_X,text_Y,boldness,value,'');
  add_text ('ANNOTATE=',#39+inttostr(startX)+';'+inttostr(startY)+';'+inttostr(text_X)+';'+inttostr(text_Y)+';'+floattostr2(boldness)+';'+value+';'+#39);
  annotated:=true; {header contains annotations}
end;


procedure Tmainwindow.Exit1Click(Sender: TObject);
begin
  esc_pressed:=true; {stop photometry loop}
  Application.MainForm.Close {this will call an on-close event for saving settings}
end;


procedure FITS_BMP(filen:string);{save FITS to BMP file}
var filename3:string;
begin
  if load_fits(filen,true {light},true,img_loaded) {load now normal} then
  begin
    use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
    filename3:=ChangeFileExt(Filen,'.bmp');
    mainwindow.image1.picture.SaveToFile(filename3);
  end;
end;


procedure Tmainwindow.ShowFITSheader1Click(Sender: TObject);
var bericht: array[0..512] of char;{make this one not too short !}
begin
   strpcopy(bericht,
  'Origin: '+origin+#13+#10+
  'Telescope: '+ telescop+#13+#10+
  'Instrument: '+instrum+#13+#10+
  'Date-obs: '+Date_obs+#13+#10+
  'UT-time: '+UT+#13+#10+
  'Plt-label: '+Pltlabel+#13+#10+
  'Plate-id: '+plateid+#13+#10+
  'Bandpass: '+floattostr(bandpass)+#13+#10+
  'Equinox: '+floattostr(equinox)+#13+#10+
  'Exposure-time: '+floattostr(exposure));
  messagebox(mainwindow.handle,bericht,'FITS HEADER',MB_OK);
end;


function position_to_string(sep:string; ra,dec:double):string;
var
  l, b : double;
begin
  if coord_frame=0 then
    result:=prepare_ra2(ra,': ')+sep+prepare_dec2(dec,'° ')
  else
  begin
    EQU_GAL(ra,dec,l,b);{equatorial to galactic coordinates}
    result:=floattostrF(l*180/pi, FFfixed, 0, 3)+sep+floattostrF(b*180/pi, FFfixed, 0, 3)+' ° gal';
  end;
end;


procedure Tmainwindow.writeposition1Click(Sender: TObject);
var  font_height:integer;
     x7,y7 : integer;
begin
  backup_img;
  image1.Canvas.brush.Style:=bsClear;
  image1.Canvas.font.color:=clred;
  image1.Canvas.font.size:=12;

  {$ifdef mswindows}
  SetTextAlign(canvas.handle, ta_left or ta_top or TA_NOUPDATECP);{always, since Linux is doing this fixed}
  setbkmode(canvas.handle,TRANSPARENT); {transparent}
  font_height:=round(canvas.Textheight('0')*1.2);{font size times ... to get underscore at the correct place. Fonts coordinates are all top/left coordinates }
  {$else} {Linux}
  font_height:=round(canvas.Textheight('0')*1.0);{font size times ... to get underscore at the correct place. Fonts coordinates are all top/left coordinates }
  {$endif}

  if object_xc>0 then {object sync}
  begin
    image1.Canvas.font.color:=$00AAFF;

    if mainwindow.Flip_horizontal1.Checked=true then x7:=round(width2-object_xc) else x7:=round(object_xc);
    if mainwindow.flip_vertical1.Checked=false then y7:=round(height2-object_yc) else y7:=round(object_yc);

    image1.Canvas.textout(round(3+x7),round(-font_height+ y7),'_'+position_to_string(',',object_raM,object_decM));
  end
  else
  begin {no object sync, give mouse position}
    image1.Canvas.font.color:=clred;
    image1.Canvas.textout(round(3+down_x   /(image1.width/width2)),round(-font_height +(down_y)/(image1.height/height2)),'_'+position_to_string(',',object_raM,object_decM));
  end;
end;


procedure Tmainwindow.FormPaint(Sender: TObject);
begin
   if image_move_to_center then
   begin
     mainwindow.image1.top:=0;
     mainwindow.image1.left:=0;
   end;
end;


procedure Tmainwindow.FormResize(Sender: TObject);
var
    h,w,mw: integer;
begin

{$IfDef Darwin}//{MacOS}
  PageControl1.height:=168;{height changes depending on tabs on off, keep a little more tolerance}

  minimum1.left:=histogram1.left-11;{adapt to different slider dimensions in Mac}
  maximum1.left:=histogram1.left-11;
  minimum1.width:=histogram1.width+24;
  maximum1.width:=histogram1.width+24;
{$ENDIF}

 panel1.Top:=max(PageControl1.height, data_range_groupBox1.top+data_range_groupBox1.height+5);
 panel1.left:=0;

 mw:=mainwindow.width;
 h:=StatusBar1.top-panel1.top;
 w:=round(h*width2/height2);

 panel1.width:=mw;
 panel1.height:=h;

 mainwindow.image1.height:=h;
 mainwindow.image1.width:=w;

 mainwindow.image1.top:=0;
 mainwindow.image1.left:=0;
end;

//procedure stretch_image(w,h: integer);
//var
//  tmpbmp: TBitmap;
//  ARect: TRect;
//begin
//  try
//    TmpBmp := TBitmap.Create;
//    try
//      TmpBmp.Width  := w;
//      TmpBmp.Height := h;
//      ARect := Rect(0,0, w,h);
//     TmpBmp.Canvas.StretchDraw(ARect, mainwindow.Image1.Picture.bitmap);
//      mainwindow.Image1.Picture.bitmap.Assign(TmpBmp);
//   finally
//       TmpBmp.Free;
//    end;
//    except
//  end;
//  width2:=mainwindow.Image1.Picture.width;
//  height2:=mainwindow.Image1.Picture.height;
//end;


function load_and_solve : boolean; {load image and plate solve}
begin
  progress_indicator(0,'');
  result:=load_image(false,false {plot});
  result:=((result {succesfull load?}) and (solve_image(img_loaded,true {get hist}) )); {find plate solution}
end;


procedure log_to_file(logf,mess : string);{for testing}
var
  f   :  textfile;
begin
  assignfile(f,logf);
  if fileexists(logf)=false then rewrite(f) else append(f);
  writeln(f,mess);
  closefile(f);
end;


procedure log_to_file2(logf,mess : string);{used for platesolve2}
var
  f   :  textfile;
begin
  assignfile(f,logf);
  rewrite(f);
  writeln(f,mess);
  closefile(f);
end;


//procedure Tmainwindow.Button1Click(Sender: TObject);
//var i, j,k : integer;
//begin
//  for i:=0 to 120 do
//  BEGIN
//  k:=i;
//  if k>25 then k:=k+6;
//  log_to_file('d:\temp\font.txt', '(');
//    for j:=0 to 8 do
//    begin
//    log_to_file('d:\temp\font.txt', '('+
//                                        inttostr(round(img_loaded[0,2+I*6,28-j]/65535))+
//                                    ','+inttostr(round(img_loaded[0,3+i*6,28-j]/65535))+
//                                    ','+inttostr(round(img_loaded[0,4+i*6,28-j]/65535))+
//                                    ','+inttostr(round(img_loaded[0,5+i*6,28-j]/65535))+
//                                    ','+inttostr(round(img_loaded[0,6+i*6,28-j]/65535))+
//                                    '),');
//    end;
//    log_to_file('d:\temp\font.txt', '),'+'{'+inttostr(i*6+3)+'}');
//  end;
//end;


procedure save_annotated_jpg(filename: string);{save viewer as annotated jpg}
var
   JPG: TJPEGImage;
begin
  load_deep;{load the deepsky database once. If loaded no action}
  plot_deepsky;{annotate}
  JPG := TJPEGImage.Create;
  try
    JPG.Assign(mainwindow.image1.Picture.Graphic);    //Convert data into jpg
    JPG.CompressionQuality :=90;
    JPG.SaveToFile(ChangeFileExt(filename,'_annotated.jpg'));
  finally
  JPG.Free;
  end;
end;


function read_astap_solution(filen {fits file name} : string; var ra1,dec1,crota :double): boolean; {read ASTAP solution from INI file}
var
  initstring :tstrings;
  Procedure get_float(var float: double;s1 : string);
      var s2:string; err:integer; r:double;
      begin
        s2:=initstring.Values[s1];
        val(s2,r,err);
        if err=0 then float:=r;
      end;
begin
  result:=false;
  initstring := Tstringlist.Create;
  with initstring do
  begin
    try
    loadfromFile(Changefileext(filen,'.ini'));{change extension of fits file to ini}
    except
      initstring.Free;
      exit;{no ini file}
    end;
  end;
  if pos('T',initstring.Values['PLTSOLVD'])=0 then exit;{astap reports no solution found or no ini file}
  result:=true;
  get_float(ra1,'CRVAL1');{in degrees}
  get_float(dec1,'CRVAL2');{in degrees}
  get_float(crota,'CROTA2');{in degrees}
  initstring.free;
end;


procedure write_ini(solution:boolean);{write solution to ini file}
var
   f: text;
begin
  assignfile(f,ChangeFileExt(filename2,'.ini'));
  rewrite(f);
  if solution then
  begin
    writeln(f,'PLTSOLVD=T');
    writeln(f,'CRPIX1='+floattostr3(crpix1));// X of reference pixel
    writeln(f,'CRPIX2='+floattostr3(crpix2));// Y of reference pixel

    writeln(f,'CRVAL1='+floattostr3(ra0*180/pi)); // RA (j2000_1) of reference pixel [deg]
    writeln(f,'CRVAL2='+floattostr3(dec0*180/pi));// DEC (j2000_1) of reference pixel [deg]
    writeln(f,'CDELT1='+floattostr3(cdelt1));     // X pixel size [deg]
    writeln(f,'CDELT2='+floattostr3(cdelt2));     // Y pixel size [deg]
    writeln(f,'CROTA1='+floattostr3(crota1));    // Image twist of X axis [deg]
    writeln(f,'CROTA2='+floattostr3(crota2));    // Image twist of Y axis [deg]
    writeln(f,'CD1_1='+floattostr3(cd1_1));       // CD matrix to convert (x,y) to (Ra, Dec)
    writeln(f,'CD1_2='+floattostr3(cd1_2));       // CD matrix to convert (x,y) to (Ra, Dec)
    writeln(f,'CD2_1='+floattostr3(cd2_1));       // CD matrix to convert (x,y) to (Ra, Dec)
    writeln(f,'CD2_2='+floattostr3(cd2_2));       // CD matrix to convert (x,y) to (Ra, Dec)
  end
  else
  begin
    writeln(f,'PLTSOLVD=F');
  end;
  writeln(f,'CMDLINE='+cmdline);{write the original commmand line}

  Case errorlevel of
             2: writeln(f,'ERROR=Not enough stars.');
            16: writeln(f,'ERROR=Error reading image file.');
            32: writeln(f,'ERROR=No star database found.');
            33: writeln(f,'ERROR=Error reading star database.');
  end;
  if warning_str<>'' then writeln(f,'WARNING='+warning_str);
  closefile(f);
end;


function platesolve2_command: boolean;
var
  i,error1,regions,count : integer;
  List: TStrings;
  command1 : string;
  f        : textfile;
  resultstr,rastr,decstr,cdelt,crota,flipped,confidence,resultV,line1,line2 : string;
  dummy,field_size,search_field : double;
  source_fits,solved,apt_request,file_loaded:boolean;
begin
  settingstring := Tstringlist.Create;
 {load program parameters, overriding initial settings if any}
  with mainwindow do
  if paramcount>0 then
  begin
   // Command line:
   //PlateSolve2.exe (Right ascension in radians),(Declination in radians),(x dimension in radians),(y dimension in radians),(Number of regions to search),(fits filename),(wait time at the end)
   //The wait time is optional. The 6 of 7  parameters should be separated by a comma. The values should have a decimal point not a comma. Example:  platesolve2.exe 4.516,0.75,0.0296,0.02268,999,1.fit,0
   //Example platesolve2.exe   4.516,0.75,0.0296,0.02268,999,1.fit,0

    List := TStringList.Create;
    try
      List.Clear;
      list.StrictDelimiter:=true;{accept spaces in command but reconstruct since they are split over several parameters}

      command1:=paramstr(1);
      for i:=2 to paramcount do command1:=command1+' '+paramstr(i);{accept spaces in command but reconstruct since they are split over several parameters}

      ExtractStrings([','], [], PChar(command1),List);

      if list.count>=6  then
         val(list[0],dummy,error1);{extra test, is this a platesolve2 command?}

     // application.messagebox( pchar(inttostr(error1)), pchar( 'error1'),MB_OK);
      //if logging then log_to_file(command1+'  command line'); {command line is also written to .ini file}

      if ((list.count>=6) and (error1=0)) then {this is a platesolve2 command line}
      begin
        result:=true;
        commandline_execution:=true; {later required for trayicon and popup notifier}

        filename2:=list[5];
        source_fits:=fits_file_name(filename2);{fits file extension?}
        file_loaded:=load_image(false,false {plot});{load file first to give commandline parameters later priority}

        if file_loaded=false then errorlevel:=16;{error file loading}

        ra1.Text:=floattostr2(strtofloat2(list[0])*12/pi);
        dec1.Text:=floattostr2(strtofloat2(list[1])*180/pi);
        {$IfDef Darwin}// for OS X,
          //mainwindow.ra1change(nil);{OSX doesn't trigger an event, so ra_label is not updated}
          //mainwindow.dec1change(nil);
        {$ENDIF}

        field_size:=strtofloat2(list[3])*180/pi;{field height in degrees}
        stackmenu1.search_fov1.text:=floattostr2(field_size);{field width in degrees}
        fov_specified:=true; {always for platesolve2 command}
        regions:=strtoint(list[4]);{use the number of regions in the platesolve2 command}
        if regions=3000{maximum for SGP, force a field of 90 degrees} then   search_field:=90
        else
        search_field:= min(180,sqrt(regions)*0.5*field_size);{regions 1000 is equivalent to 32x32 regions. So distance form center is 0.5*32=16 region heights}

        stackmenu1.radius_search1.text:=floattostrF2(search_field,0,1);{convert to radius of a square search field}

        {$ifdef CPUARM}
        {$else}
          trayicon1.visible:=true;{show progress in hint of trayicon}
        {$endif}

        if ((file_loaded) and (solve_image(img_loaded,true {get hist}) )) then {find plate solution, filename2 extension will change to .fit}
        begin
          resultstr:='Valid plate solution';
          confidence:='999';
          resultV:=',1';
          solved:=true;
        end
        else
        begin
         //999,999,-1
         //0,0,0,0,404
         //Maximum search limit exceeded
          ra0:=999;
          dec0:=999;
          resultV:=',-1';
          resultstr:='Maximum search limit exceeded';
          confidence:='000';
          solved:=false;
          errorlevel:=1;{no solution}
        end;
        //  0.16855631,0.71149576,1              (ra [rad],dec [rad],1 }
        //  2.69487,0.5,1.00005,-0.00017,395     {pixelsize*3600, crota2, flipped,? ,confidence}
        //  Valid plate solution

        // .1844945, .72046475, 1
        // 2.7668, 180.73,-1.0001,-.00015, 416
        // Valid plate solution

        //  0.16855631,0.71149576,0.0296,0.02268,999,c:\temp\3.fits,0   {m31}

        assignfile(f,ChangeFileExt(filename2,'.apm'));
        rewrite(f);

        str(ra0:9:7,rastr);{mimic format of PlateSolve2}
        str(dec0:9:7,decstr);
        line1:=rastr+','+decstr+resultV {,1 or ,-1};

        str(cdelt2*3600:7:5,cdelt);
        if ((cdelt2=0{prevent divide by zero}) or (cdelt1/cdelt2<0)) then
        begin
          if source_fits then flipped:='1.0000' else flipped:='-1.0000'; {PlateSolve2 sees a FITS file flipped while not flipped due to the orientation 1,1 at left bottom}
        end
        else
        begin
          if source_fits then flipped:='-1.0000' else flipped:='1.0000';{PlateSolve2 sees a FITS file flipped while not flipped due to the orientation 1,1 at left bottom}
          crota2:=180-crota2;{mimic strange Platesolve2 angle calculation.}
        end;

        crota2:=fnmodulo(crota2,360); {Platesolve2 reports in 0..360 degrees, mimic this behavior for SGP}

        str(crota2:7:2,crota);
        line2:=cdelt+','+crota+','+flipped+',0.00000,'+confidence;

        apt_request:=pos('IMAGETOSOLVE',uppercase(filename2))>0; {if call from APT then write with numeric seperator according Windows setting as for PlateSolve2 2.28}
        if ((apt_Request) and (formatSettings.decimalseparator= ',' )) then {create PlateSolve2 v2.28 format}
        begin
          line1:=stringreplace(line1, '.', ',',[rfReplaceAll]);
          line2:=stringreplace(line2, '.', ',',[rfReplaceAll]);
        end;

        writeln(f,line1);
        writeln(f,line2);
        writeln(f,resultstr);
        closefile(f);

        {note SGP uses PlateSolve2 v2.29. This version writes APM always with dot as decimal seperator}

        {extra log}
        write_ini(solved);{write solution to ini file}
//        log_to_file2(ChangeFileExt(filename2,'.txt'),'Command: '+command1+#10+
//                                                     'RA : '+mainwindow.ra1.text+#10+
//                                                     'DEC: '+mainwindow.dec1.text+#10+
//                                                     'Height: '+stackmenu1.search_fov1.text);
        count:=0;
        while  ((fileexists(ChangeFileExt(filename2,'.apm'))=false) and  (count<60)) do begin sleep(50);inc(count); end;{wait maximum 3 seconds till solution file is available before closing the program}
      end {list count}
      else
      begin {not a platesolve2 command}
        result:=false;
        filename2:=command1;{for load this file in viewer}
      end;
    finally
      List.Free;
    end;
  end
  else result:=false; {no parameters specified}
end;


procedure write_astronomy_wcs;
var
  TheFile4 : tfilestream;
  I : integer;
  line0       : ansistring;
  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}

begin
  try
   TheFile4:=tfilestream.Create(ChangeFileExt(filename2,'.wcs'), fmcreate );

  {write memo1 header to file}
   for i:=0 to 79 do empthy_line[i]:=#32;{space}
   i:=0;
   repeat
      if i<mainwindow.memo1.lines.count then
      begin
        line0:=mainwindow.memo1.lines[i];
        while length(line0)<80 do line0:=line0+' ';{guarantee length is 80}
        strpcopy(aline,(copy(line0,1,80)));{copy 80 and not more}
        thefile4.writebuffer(aline,80);{write updated header from memo1}
      end
      else
      thefile4.writebuffer(empthy_line,80);{write empthy line}
      inc(i);
   until ((i>=mainwindow.memo1.lines.count) and (frac(i*80/2880)=0)); {write multiply records 36x80 or 2880 bytes}

  except
    TheFile4.free;
    exit;
  end;
  TheFile4.free;
end;

//procedure write_astronomy_axy(stars: star_list;snr_list        : array of double );
//var
//  TheFile4 : tfilestream;
//  I,j        : integer;
//  line0,aantallen       : ansistring;
//  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}
//  data: longword;
//begin

//  remove_key('NAXIS1  =',true{one});     {this will damge the header}
//  remove_key('NAXIS2  =',true{one});
//  update_integer('NAXIS   =',' / Minimal header                                 ' ,0);{2 for mono, 3 for colour}
//  update_integer('BITPIX  =',' /                                                ' ,8    );

//  add_text ('EXTEND  =','                   T / There may be FITS extension                    ');
//  add_text ('AN_FILE =',#39+'XYLS    '+#39+' / Astrometry.net file type                                 ');

//  try
//   TheFile4:=tfilestream.Create(ChangeFileExt(filename2,'.xyls'), fmcreate );

  {write memo1 header to file}
//   for i:=0 to 79 do empthy_line[i]:=#32;{space}
//   i:=0;
//   repeat
//     if i<mainwindow.memo1.lines.count then
//      begin
//        line0:=mainwindow.memo1.lines[i];
//        while length(line0)<80 do line0:=line0+' ';{guarantee length is 80}
//        strpcopy(aline,(copy(line0,1,80)));{copy 80 and not more}
//        thefile4.writebuffer(aline,80);{write updated header from memo1}
//      end
//      else
//      thefile4.writebuffer(empthy_line,80);{write empthy line}
//     inc(i);
//   until ((i>=mainwindow.memo1.lines.count) and (frac(i*80/2880)=0)); {write multiply records 36x80 or 2880 bytes}

//   i:=0;
//   strpcopy(aline,'XTENSION= '+#39+'BINTABLE'+#39+' / FITS Binary Table Extension                              ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80); inc(i);
//   strpcopy(aline,'BITPIX  =                    8 / 8-bits character format                        ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'NAXIS   =                    2 / Tables are 2-D char. array                     ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'NAXIS1  =                   16 / Bytes in row                                   ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);

//   str(length(stars[0]):13,aantallen);

//   strpcopy(aline,'NAXIS2  =         '+aantallen+' /                                                ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'PCOUNT  =                    0 / Parameter count always 0                       ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'GCOUNT  =                    1 / Group count always 1                           ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'TFIELDS =                    4 / No. of col in table                            ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'TFORM1  = '+#39+'E       '+#39+' / Format of field                                          ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'TTYPE1  = '+#39+'X       '+#39+' / Field label                                              ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'TUNIT1  =                      / Physical unit of field                         ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'TFORM2  = '+#39+'E       '+#39+' / Single precision floating point, 4 bytes                 ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'TTYPE2  = '+#39+'Y       '+#39+' / Field label                                              ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'TUNIT2  =                      / Physical unit of field                         ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);

//   strpcopy(aline,'TFORM3  = '+#39+'E       '+#39+' / Single precision floating point, 4 bytes                 ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'TTYPE3  = '+#39+'FLUX    '+#39+' / Field label                                              ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'TUNIT3  =                      / Physical unit of field                         ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);


//   strpcopy(aline,'TFORM4  = '+#39+'E       '+#39+' / Single precision floating point, 4 bytes                 ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'TTYPE4  = '+#39+'BACKGROUND'+#39+' / Field label                                            ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'TUNIT4  =                      / Physical unit of field                         ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);


//   strpcopy(aline,'ORIGIN  = '+#39+'ASTAP'+#39+' / Written by ASTAP                                            ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//   strpcopy(aline,'END                                                                             ');{copy 80 and not more or less}
//   thefile4.writebuffer(aline,80);inc(i);
//
//   while  frac(i*80/2880)>0 do
//   begin
//     thefile4.writebuffer(empthy_line,80);{write empthy line}
//     inc(i);
//   end;

//   i:=0;
//   repeat
//      data:=INT_IEEE4_reverse(stars[0,i]+1);{adapt intel floating point to non-intel floating. Add 1 to get FITS coordinates}
//      thefile4.writebuffer(data,4);{write x value}
//      data:=INT_IEEE4_reverse(stars[1,i]+1);{adapt intel floating point to non-intel floating. Add 1 to get FITS coordinates}
//      thefile4.writebuffer(data,4);{write y value}
//      data:=INT_IEEE4_reverse(snr_list[i]);{snr}
//      thefile4.writebuffer(data,4);{write y value}
//      data:=INT_IEEE4_reverse(170);{background}
//      thefile4.writebuffer(data,4);{write y value}

//      inc(i,1);{counter of 16 bytes or 4*4 bytes}
//   until i>=length(stars[0]);
//   j:=80-round(80*frac(i*16/80));{remainder in bytes till written muliple of 80 char}
//   thefile4.writebuffer(empthy_line,j);{write till multiply of 80}
//   i:=(16*i + j*80) div 80 ;{how many 80 bytes record left till multiple of 2880}

//   while  frac(i*80/2880)>0 do {write till 2880 block is written}
//   begin
//     thefile4.writebuffer(empthy_line,80);{write empthy line}
//     inc(i);
//   end;

//  except
//    TheFile4.free;
//    exit;
//  end;

//  TheFile4.free;

//end;


procedure Tmainwindow.FormShow(Sender: TObject);
var
    s      : string;
    histogram_done,file_loaded,debug,filespecified: boolean;
    backgr, hfd_median                 : double;
    hfd_counter,binning                : integer;
begin
  user_path:=GetAppConfigDir(false);{get user path for app config}

  if load_settings(user_path+'astap.cfg')=false then
  begin
    if DirectoryExists(user_path)=false then ForceDirectories(user_path);{create c:\users\yourname\appdata\local\astap   or /users/../.config/astap
                   Force directories will make also .config if missing. Using createdir doesn't work if both a directory and subdirectory are to be made in Linux and Mac}
  end;

  fov_specified:=false;{assume no FOV specification in commandline}
  screen.Cursor:=0;
  if platesolve2_command then
  begin
    esc_pressed:=true;{kill any running activity. This for APT}
    {stop program, platesolve command already executed}
    halt(errorlevel); {don't save only do form.destroy. Note  mainwindow.close causes a window flash briefly, so don't use}
  end
  else
  if paramcount>0 then   {file as first parameter}
  begin
    {filename2 is already made in platesolve2_command}

    with application do
    begin
      if hasOption('h','help') then
      begin
        application.messagebox( pchar(
        '-f  filename'+#10+
        '-r  radius_area_to_search[degrees]'+#10+      {changed}
        '-z  downsample_factor[0,1,2,3,4] {Downsample prior to solving. 0 is auto}'+#10+
        '-fov diameter_field[degrees]'+#10+   {changed}
        '-ra  center_right ascension[hours]'+#10+
        '-spd center_south_pole_distance[degrees]'+#10+
        '-s  max_number_of_stars'+#10+
        '-t  tolerance'+#10+
        '-m  minimum_star_size["]'+#10+
        '-speed mode[auto/slow] {Slow is forcing small search steps to improve detection.}'+#10+
        '-o  file {Name the output files with this base path & file name}'+#10+
        '-analyse {Analyse only and report in the errorlevel the median HFD * 100M + number of stars used}'+#10+
        '-annotate  {Produce deepsky annotated jpg file}' +#10+
        '-debug  {Show GUI and stop prior to solving}' +#10+
        '-log   {Write the solver log to file}'+#10+
        '-tofits  binning[1,2,3,4]  {Make new fits file from PNG/JPG file input}'+#10+
        '-update  {update the FITS header with the found solution}' +#10+
        '-wcs  {Write a .wcs file  in similar format as Astrometry.net. Else text style.}' +#10+
        'Preference will be given to the command line values.'
        ), pchar('ASTAP astrometric solver usage:'),MB_OK);

        esc_pressed:=true;{kill any running activity. This for APT}
        halt(0); {don't save only do mainwindow.destroy. Note  mainwindow.close causes a window flash briefly, so don't use}
      end;

      debug:=hasoption('debug'); {The debug option allows to set some solving parameters in the GUI (graphical user interface) and to test the commandline. In debug mode all commandline parameters are set and the specified image is shown in the viewer. Only the solve command has to be given manuallydebug mode }
      filespecified:=hasoption('f');

      if ((filespecified) or (debug)) then
      begin
        commandline_execution:=true;{later required for trayicon and popup notifier and Memo3 scroll in Linux}

        if filespecified then
        begin
          filename2:=GetOptionValue('f');
          if debug=false then
            file_loaded:=load_image(false,false {plot}) {load file first to give commandline parameters later priority}
          else
            load_image(true,true {plot});{load and show image}

          if file_loaded=false then errorlevel:=16;{error file loading}
          file_loaded:=((file_loaded) or (extend>0));{axy}
        end
        else
        file_loaded:=false;

        {apply now overriding parameters}
        if hasoption('fov') then
        begin
          fov_specified:=true; {do not calculate it from header};
          stackmenu1.search_fov1.text:=GetOptionValue('fov');
        end;
        if hasoption('r') then stackmenu1.radius_search1.text:=GetOptionValue('r');
        if hasoption('ra') then
        begin
           mainwindow.ra1.text:=GetOptionValue('ra');
        end;
        if hasoption('spd') then {south pole distance. Negative values can't be passed via commandline}
        begin
          dec0:=strtofloat2(GetOptionValue('spd'))-90;{convert south pole distance to declination}
          str(dec0:0:6,s);
          mainwindow.dec1.text:=s;
        end;

        if hasoption('z') then
                 stackmenu1.downsample_for_solving1.text:=GetOptionValue('z');
        if hasoption('s') then
                 stackmenu1.max_stars1.text:=GetOptionValue('s');
        if hasoption('t') then stackmenu1.quad_tolerance1.text:=GetOptionValue('t');
        if hasoption('m') then stackmenu1.min_star_size1.text:=GetOptionValue('m');
        if hasoption('speed') then stackmenu1.force_oversize1.checked:=pos('slow',GetOptionValue('speed'))<>0;

        if debug=false then {standard solve via command line}
        begin
          if ((file_loaded) and (hasoption('analyse'))) then {analyse fits and report HFD value in errorlevel }
          begin
             analyse_fits(img_loaded,hfd_counter,backgr,hfd_median); {find background, number of stars, median HFD}
             halt(round(hfd_median*100)*1000000+hfd_counter);{report in errorlevel the hfd and the number of stars used}
          end;{analyse fits and report HFD value}

          {$ifdef CPUARM}
          {set tray icon visible gives a fatal error in old compiler for armhf}
          {$else}
            trayicon1.visible:=true;{show progress in hint of trayicon}
          {$endif}

          if ((file_loaded) and (solve_image(img_loaded,true {get hist}) )) then {find plate solution, filename2 extension will change to .fit}
          begin
            if hasoption('o') then filename2:=GetOptionValue('o');{change file name for .ini file}

            write_ini(true);{write solution to ini file}

            add_long_comment('cmdline:'+cmdline);{log command line in wcs file}
            remove_key('NAXIS1  =',true{one});
            remove_key('NAXIS2  =',true{one});
            update_integer('NAXIS   =',' / Minimal header                                 ' ,0);{2 for mono, 3 for colour}
            update_integer('BITPIX  =',' /                                                ' ,8);

            if hasoption('wcs') then
              write_astronomy_wcs  {write WCS astronomy.net style}
            else
              try mainwindow.Memo1.Lines.SavetoFile(ChangeFileExt(filename2,'.wcs'));{save header as wcs file} except {sometimes error using APT, locked?} end;

            if hasoption('update') then mainwindow.SaveFITSwithupdatedheader1Click(nil); {update the fits file header}

            histogram_done:=false;
            if hasoption('annotate') then
            begin
              use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
              histogram_done:=true;
              plot_fits(mainwindow.image1,true {center_image},true);{center and stretch with current settings}
              save_annotated_jpg(filename2);{save viewer as annotated jpg}
            end;
            if hasoption('tofits') then {still to be tested}
            begin
              if fits_file_name(filename2)=false {no fits file?} then
              begin
                binning:=round(strtofloat2(GetOptionValue('tofits')));
                if binning>1 then bin_X2X3X4(binning);{bin img_loaded 2x or 3x or 4x}
                if histogram_done=false then use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
                save_fits(img_loaded,changeFileExt(filename2,'.fit'),8,true {overwrite});
              end;
            end;

            if  ((fov_specified) and (stackmenu1.search_fov1.text='0' ) {auto}) then {preserve new found fov}
            begin
              stackmenu1.search_fov1.text:=floattostrF2(height2*abs(cdelt2),0,2);
              save_settings(user_path+'astap.cfg');{save settings with correct fov}
            end;
          end {solution}
          else
          begin {no solution}
            if hasoption('o') then filename2:=GetOptionValue('o'); {change file name for .ini file}
            write_ini(false);{write solution to ini file}
            errorlevel:=1;{no solution}
          end;
          esc_pressed:=true;{kill any running activity. This for APT}

          if hasoption('log') then stackmenu1.Memo2.Lines.SavetoFile(ChangeFileExt(filename2,'.log'));{save Memo3 log to log file}


          halt(errorlevel); {don't save only do mainwindow.destroy. Note  mainwindow.close causes a window flash briefly, so don't use}

          //  Exit status:
          //  0 no errors.
          //  1 no solution.
          //  2 not enough stars detected.

          // 16 error reading image file.

          // 32 no star database found.
          // 33 error reading star database.

          // ini file is always written. Could contain:
          // ERROR=......
          // WARNING=......

          // wcs file is written when there is a solution. Could contain:
          // WARNING =.........
        end {standard solve via command line}
        else
        begin {debug mode, so tab alignment for settings and testing}
          stackmenu1.formstyle:=fsSystemStayOnTop;
          stackmenu1.pagecontrol1.tabindex:=6; {alignment}
          stackmenu1.panel_manual1.enabled:=false;{hide for user}
          stackmenu1.panel_ephemeris1.enabled:=false;{hide for user}
          stackmenu1.ignore_header_solution1.enabled:=false;{hide for user}
          stackmenu1.classify_groupbox1.enabled:=false;{hide for user}
          stackmenu1.save_settings_extra_button1.visible:=true;
          stackmenu1.visible:=true;
          stackmenu1.setfocus;

          Mainwindow.stretch1Change(nil);{create gamma curve}
          exit;
        end;
      end;{-f option}
    end;{with application}

    {filename as parameter 1}
    Mainwindow.stretch1Change(nil);{create gamma curve}
    load_image(true,true {plot});{show image of parameter1}
  end {paramcount>0}
  else
  Mainwindow.stretch1Change(nil);{create gamma curve for image if loaded later and set gamma_on}

  {$IfDef Darwin}// for OS X,
  {$IF FPC_FULLVERSION <= 30200} {FPC3.2.0}
     application.messagebox( pchar('Warning this code requires later LAZARUS 2.1 and FPC 3.3.1 version!!!'), pchar('Warning'),MB_OK);
  {$ENDIF}
  {$ENDIF}


  memo1.font.size:=font_size;
  memo1.font.color:=font_color;
  memo1.font.name:=font_name;
  memo1.font.style:=font_style;
  memo1.font.charset:=font_charset;  {note Greek=161, Russian or Cyrillic =204}
end;


procedure Tmainwindow.AddplatesolvesolutiontoselectedFITSfiles1Click(
  Sender: TObject);
var
  I: integer;
  Save_Cursor:TCursor;
  nrskipped, nrsolved,nrfailed :integer;
  dobackup : boolean;
  failed,skipped   : string;

begin
  OpenDialog1.Title := 'Select multiple  files to add plate solution';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS';
  esc_pressed:=false;

  if OpenDialog1.Execute then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }


    nrsolved:=0;
    nrskipped:=0;
    failed:='Failed files:';
    skipped:='Skipped files:';
    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}

    try { Do some lengthy operation }
        with OpenDialog1.Files do
        for I := 0 to Count - 1 do
        begin
          filename2:=Strings[I];
          memo2_message('Solving '+inttostr(i+1)+'-'+inttostr(Count)+': '+filename2);
          progress_indicator(100*i/(count),' Solving');{show progress}

          Application.ProcessMessages;
          if esc_pressed then begin Screen.Cursor := Save_Cursor;  exit;end;

          {load image and solve image}
          if load_fits(filename2,true {light},true,img_loaded) then {load image success}
          begin
            if ((cd1_1<>0) and (stackmenu1.ignore_header_solution1.checked=false)) then
            begin
              nrskipped:=nrskipped+1; {plate solved}
              memo2_message('Skipped: '+filename2+ '  Already solution in header. Select ignore  in tab alignment to redo.');
              skipped:=skipped+#13+#10+extractfilename(filename2);
            end
            else
            if solve_image(img_loaded,true {get hist}) then {match between loaded image and star database}
            begin
              mainwindow.SaveFITSwithupdatedheader1Click(nil);
              nrsolved:=nrsolved+1;
            end
            else
            begin
              memo2_message('Solve failure: '+filename2);
              failed:=failed+#13+#10+extractfilename(filename2);
            end;
          end;
        end;


      finally
      if dobackup then restore_img;{for the viewer}
      Screen.Cursor := Save_Cursor;  { Always restore to normal }
    end;
    progress_indicator(-100,'');{progresss done}
    nrfailed:=OpenDialog1.Files.count-nrsolved-nrskipped;
    if nrfailed<>0 then memo2_message(failed);
    if nrskipped<>0 then memo2_message(skipped);
    memo2_message(inttostr(nrsolved)+' images solved, '+inttostr(nrfailed)+' solve failures, '+inttostr(nrskipped)+' images skipped. For re-solve set option "Ignore existing fits header solution".');
  end;
end;


procedure Tmainwindow.stretch1Change(Sender: TObject);
begin
  do_stretching;
end;


procedure Sort(var list: array of double);{taken from CCDciel code}
var sorted: boolean;
    tmp: double;
    j,n: integer;
begin
repeat
  sorted := True;
  n := length(list);
  for j := 1 to n-1 do
  begin
    if list[j - 1] > list[j] then
    begin
      tmp := list[j - 1];
      list[j - 1] := list[j];
      list[j] := tmp;
      sorted := False;
    end;
  end;
until sorted;
end;


function SMedian(list: array of double): double;{get median of an array of double, taken from CCDciel code}
var
  n,mid: integer;
begin
 n:=length(list);
 if n=0 then result:=nan
 else
   if n=1 then result:=list[0]
   else
   begin
     Sort(list);
     mid := (high(list) - low(list)) div 2;
     if Odd(Length(list)) then
     begin
       if n<=3 then  result:=list[mid]
       else
       begin
         result:=(list[mid-1]+list[mid]+list[mid+1])/3;
       end;
     end
     else
     result:=(list[mid]+list[mid+1])/2;
  end;
end;


procedure Tmainwindow.CCDinspector1Click(Sender: TObject);
var
 fitsX,fitsY,size, i, j,starX,starY, retries,max_stars,
 nhfd,nhfd_center,nhfd_outer_ring,nhfd_top_left,nhfd_top_right,nhfd_bottom_left,nhfd_bottom_right,x1,x2,x3,x4,y1,y2,y3,y4,fontsize : integer;

 hfd1,star_fwhm,snr,flux,xc,yc, median_worst,median_best,scale_factor, detection_level,
 hfd_median, median_center, median_outer_ring, median_bottom_left, median_bottom_right, median_top_left, median_top_right,hfd_min : double;
 hfdlist, hfdlist_top_left,hfdlist_top_right,hfdlist_bottom_left,hfdlist_bottom_right,  hfdlist_center,hfdlist_outer_ring   :array of double;
 starlistXY    :array of array of integer;
 mess1,mess2,hfd_value,hfd_arcsec      : string;
 Save_Cursor:TCursor;
 Fliphorizontal, Flipvertical: boolean;
const
   len : integer=1000;
begin
  if fits_file=false then exit; {file loaded?}
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  max_stars:=500;

  with mainwindow do
  begin
    Flipvertical:=mainwindow.flip_vertical1.Checked;
    Fliphorizontal:=mainwindow.Flip_horizontal1.Checked;


    image1.Canvas.Pen.Mode := pmMerge;
    image1.Canvas.brush.Style:=bsClear;
    image1.Canvas.font.color:=clyellow;
    image1.Canvas.Pen.Color := clred;
    image1.Canvas.Pen.width := round(1+height2/image1.height);{thickness lines}
    fontsize:=round(max(10,8*height2/image1.height));{adapt font to image dimensions}
    image1.Canvas.font.size:=fontsize;

    hfd_median:=0;
    median_center:=0;
    median_outer_ring:=0;
    median_bottom_left:=0;
    median_bottom_right:=0;
    median_top_left:=0;
    median_top_right:=0;


    SetLength(hfdlist,len*4);{set array length on a starting value}
    SetLength(starlistXY,2,len*4);{x,y positions}

    SetLength(hfdlist_center,len);
    SetLength(hfdlist_outer_ring,len*2);

    SetLength(hfdlist_top_left,len);
    SetLength(hfdlist_top_right,len);
    SetLength(hfdlist_bottom_left,len);
    SetLength(hfdlist_bottom_right,len);
    setlength(img_temp,1,width2,height2);{set length of image array}

    hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}
    get_background(0,img_loaded,{cblack=0} false{histogram is already available},true {calculate noise level},{var}cblack,star_level);{calculate background level from peek histogram}

    detection_level:=star_level; {level above background. Start with a high value}

    retries:=2; {try up to three times to get enough stars from the image}
    repeat
      nhfd:=0;{set counters at zero}
      nhfd_top_left:=0;
      nhfd_top_right:=0;
      nhfd_bottom_left:=0;
      nhfd_bottom_right:=0;
      nhfd_center:=0;
      nhfd_outer_ring:=0;


      for fitsY:=0 to height2-1 do
        for fitsX:=0 to width2-1  do
          img_temp[0,fitsX,fitsY]:=-1;{mark as not surveyed}

      for fitsY:=0 to height2-1-1  do
      begin
        for fitsX:=0 to width2-1-1 do
        begin
          if (( img_temp[0,fitsX,fitsY]<=0){area not surveyed}  and (img_loaded[0,fitsX,fitsY]- cblack>detection_level){star}) then {new star}
          begin
            HFD(img_loaded,fitsX,fitsY,14{box size}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}

            if ((hfd1<=99) and (snr>10) and (hfd1>hfd_min) ) then
            begin
  //            size:=round(5*hfd1);
              if Fliphorizontal     then starX:=round(width2-xc)   else starX:=round(xc);
              if Flipvertical=false then  starY:=round(height2-yc) else starY:=round(yc);

  //            mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
  //            mainwindow.image1.Canvas.textout(starX+size,starY+size,floattostrf(hfd1, ffgeneral, 2,1));{add hfd as text}

              size:=round(3*hfd1);
              for j:=fitsY-size to fitsY+size do {mark the whole star area as surveyed}
                for i:=fitsX-size to fitsX+size do
                  if ((j>=0) and (i>=0) and (j<height2) and (i<width2)) then {mark the area of the star square and prevent double detections}
                    img_temp[0,i,j]:=1;

              {store values}
              hfdlist[nhfd]:=hfd1;
              starlistXY[0,nhfd]:=starX; {store star position in image coordinates, not FITS coordinates}
              starlistXY[1,nhfd]:=starY;
              inc(nhfd); if nhfd>=length(hfdlist) then
              begin
                SetLength(hfdlist,nhfd+100); {adapt length if required and store hfd value}
                SetLength(starlistXY,2,nhfd+100);{adapt array size if required}
              end;

              if  sqr(starX - (width2 div 2) )+sqr(starY - (height2 div 2))<sqr(0.25)*(sqr(width2 div 2)+sqr(height2 div 2))  then begin hfdlist_center[nhfd_center]:=hfd1; inc(nhfd_center); if nhfd_center>=length( hfdlist_center) then  SetLength( hfdlist_center,nhfd_center+100);end {store center(<25% diameter) HFD values}
              else
              begin
                if  sqr(starX - (width2 div 2) )+sqr(starY - (height2 div 2))>sqr(0.75)*(sqr(width2 div 2)+sqr(height2 div 2)) then begin hfdlist_outer_ring[nhfd_outer_ring]:=hfd1; inc(nhfd_outer_ring); if nhfd_outer_ring>=length(hfdlist_outer_ring) then  SetLength(hfdlist_outer_ring,nhfd_outer_ring+100); end;{store out ring (>75% diameter) HFD values}

                if ( (starX<(width2 div 2)) and (starY<(height2 div 2)) ) then begin  hfdlist_bottom_left [nhfd_bottom_left] :=hfd1; inc(nhfd_bottom_left); if nhfd_bottom_left>=length(hfdlist_bottom_left)   then SetLength(hfdlist_bottom_left,nhfd_bottom_left+100);  end;{store corner HFD values}
                if ( (starX>(width2 div 2)) and (starY<(height2 div 2)) ) then begin  hfdlist_bottom_right[nhfd_bottom_right]:=hfd1; inc(nhfd_bottom_right);if nhfd_bottom_right>=length(hfdlist_bottom_right) then SetLength(hfdlist_bottom_right,nhfd_bottom_right+100);end;
                if ( (starX<(width2 div 2)) and (starY>(height2 div 2)) ) then begin  hfdlist_top_left[nhfd_top_left]:=hfd1;         inc(nhfd_top_left);    if nhfd_top_left>=length(hfdlist_top_left)         then SetLength(hfdlist_top_left,nhfd_top_left+100);        end;
                if ( (starX>(width2 div 2)) and (starY>(height2 div 2)) ) then begin  hfdlist_top_right[nhfd_top_right]:=hfd1;       inc(nhfd_top_right);   if nhfd_top_right>=length(hfdlist_top_right)       then SetLength(hfdlist_top_right,nhfd_top_right+100);      end;
              end;
            end;
          end;
        end;
      end;

      dec(retries);{try again with lower detection level}
      if retries =1 then begin if 15*noise_level[0]<star_level then detection_level:=15*noise_level[0] else retries:= 0; {skip retries 1} end; {lower  detection level}
      if retries =0 then begin if  5*noise_level[0]<star_level then detection_level:= 5*noise_level[0] else retries:=-1; {skip retries 0} end; {lowest detection level}

    until ((nhfd>=max_stars) or (retries<0));{reduce detection level till enough stars are found. Note that faint stars have less positional accuracy}

    if nhfd>0 then
    begin
      for i:=0 to nhfd-1 do {plot rectangles later since the routine can be run three times to find the correct detection_level and overlapping rectangle could occur}
      begin
        hfd1:=hfdlist[i];
        size:=round(5*hfd1);

        starX:=starlistXY[0,i];
        starY:=starlistXY[1,i];
        mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
        mainwindow.image1.Canvas.textout(starX+size,starY+size,floattostrf(hfd1, ffgeneral, 2,1));{add hfd as text}
      end;

      if ((nhfd_center>0) and (nhfd_outer_ring>0)) then  {enough information for curvature calculation}
      begin
        SetLength(hfdlist_center,nhfd_center); {set length correct}
        SetLength(hfdlist_outer_ring,nhfd_outer_ring);

        median_center:=SMedian(hfdlist_center);
        median_outer_ring:=SMedian(hfdlist_outer_ring);
        mess1:='  Off-axis aberration[HFD]='+floattostrF2(median_outer_ring-(median_center),0,2);{}
      end
      else
      mess1:='';

      if ((nhfd_top_left>0) and (nhfd_top_right>0) and (nhfd_bottom_left>0) and (nhfd_bottom_right>0)) then  {enough information for tilt calculation}
      begin
        SetLength(hfdlist_bottom_left,nhfd_bottom_left); {set length correct}
        SetLength(hfdlist_bottom_right,nhfd_bottom_right);
        SetLength(hfdlist_top_left,nhfd_top_left);
        SetLength(hfdlist_top_right,nhfd_top_right);

        median_top_left:=SMedian(hfdList_top_left);
        median_top_right:=SMedian(hfdList_top_right);
        median_bottom_left:=SMedian(hfdList_bottom_left);
        median_bottom_right:=SMedian(hfdList_bottom_right);
        median_best:=min(min(median_top_left, median_top_right),min(median_bottom_left,median_bottom_right));{find best corner}
        median_worst:=max(max(median_top_left, median_top_right),max(median_bottom_left,median_bottom_right));{find worst corner}

        scale_factor:=width2*0.25/median_worst;
        x1:=round(-median_bottom_left*scale_factor+width2/2);y1:=round(-median_bottom_left*scale_factor+height2/2);{calculate coordinates counter clockwise}
        x2:=round(+median_bottom_right*scale_factor+width2/2);y2:=round(-median_bottom_right*scale_factor+height2/2);
        x3:=round(+median_top_right*scale_factor+width2/2);y3:=round(+median_top_right*scale_factor+height2/2);
        x4:=round(-median_top_left*scale_factor+width2/2);y4:=round(+median_top_left*scale_factor+height2/2);

        image1.Canvas.Pen.width :=image1.Canvas.Pen.width*2;{thickness lines}

        image1.Canvas.pen.color:=clyellow;

        image1.Canvas.moveto(x1,y1);{draw trapezium}
        image1.Canvas.lineto(x2,y2);{draw trapezium}
        image1.Canvas.lineto(x3,y3);{draw trapezium}
        image1.Canvas.lineto(x4,y4);{draw trapezium}
        image1.Canvas.lineto(x1,y1);{draw trapezium}

        image1.Canvas.lineto(width2 div 2,height2 div 2);{draw diagonal}
        image1.Canvas.lineto(x2,y2);{draw diagonal}
        image1.Canvas.lineto(width2 div 2,height2 div 2);{draw diagonal}
        image1.Canvas.lineto(x3,y3);{draw diagonal}
        image1.Canvas.lineto(width2 div 2,height2 div 2);{draw diagonal}
        image1.Canvas.lineto(x4,y4);{draw diagonal}
        mess2:='  Tilt[HFD]='+floattostrF2(median_worst-median_best,0,2);{estimate tilt value}


        image1.Canvas.font.size:=fontsize*4;
        image1.Canvas.textout(x4,y4,floattostrF2(median_top_left,0,2));
        image1.Canvas.textout(x3,y3,floattostrF2(median_top_right,0,2));
        image1.Canvas.textout(x1,y1,floattostrF2(median_bottom_left,0,2));
        image1.Canvas.textout(x2,y2,floattostrF2(median_bottom_right,0,2));
        image1.Canvas.textout(width2 div 2,height2 div 2,floattostrF2(median_center,0,2));
      end
      else
      mess2:='';

      SetLength(hfdlist,nhfd);{set length correct}
      hfd_median:=SMedian(hfdList);
      str(hfd_median:0:1,hfd_value);
      if cdelt2<>0 then begin str(hfd_median*cdelt2*3600:0:1,hfd_arcsec); hfd_arcsec:=' ('+hfd_arcsec+'")'; end else hfd_arcsec:='';
      mess2:='Median HFD='+hfd_value+hfd_arcsec+ mess2+'  Stars='+ inttostr(nhfd)+mess1 ;

      fontsize:=width2 div 60;
      image1.Canvas.font.size:=fontsize;
      image1.Canvas.font.color:=clwhite;

      image1.Canvas.textout(round(fontsize*2),height2-round(2*fontsize),mess2);{median HFD and tilt indication}
    end
    else
    begin
      image1.Canvas.font.size:=round(image1.Canvas.font.size*20/12);
      image1.Canvas.textout(round(fontsize*2),height2-round(2*fontsize),'No stars detected');
    end;
  end;{with mainwindow}

  hfdlist:=nil;{release memory}

  hfdlist_center:=nil;
  hfdlist_outer_ring:=nil;

  hfdlist_top_left:=nil;
  hfdlist_top_right:=nil;
  hfdlist_bottom_left:=nil;
  hfdlist_bottom_right:=nil;

  starlistXY:=nil;

  img_temp:=nil;{free mem}

  Screen.Cursor:= Save_Cursor;
end;


procedure Tmainwindow.demosaic_bayermatrix1Click(Sender: TObject);
var
    oldcursor: tcursor;
begin
  {$IFDEF fpc}
  progress_indicator(0,'');
  {$else} {delphi}
  mainwindow.taskbar1.progressstate:=TTaskBarProgressState.Normal;
  mainwindow.taskbar1.progressvalue:=0; {show progress}
  {$endif}
  OldCursor := Screen.Cursor;
  Screen.Cursor:= crHourGlass;
  backup_img;

  demosaic_advanced(img_loaded);

  remove_key('BAYERPAT',false{all});{remove key word in header}
  remove_key('XBAYROFF',false{all});{remove key word in header}
  remove_key('YBAYROFF',false{all});{remove key word in header}

  plot_fits(mainwindow.image1,false,true);
  stackmenu1.test_pattern1.Enabled:=false;{do no longer allow debayer}

  Screen.Cursor:=OldCursor;
 {$IFDEF fpc}
  progress_indicator(-100,'');{back to normal}
 {$else} {delphi}
  mainwindow.taskbar1.progressstate:=TTaskBarProgressState.None;
 {$endif}
end;


procedure Tmainwindow.star_annotation1Click(Sender: TObject);
begin
  plot_stars(sender=calibrate_photometry1 {if true photometry only}, false {show Distortion});
  if flux_magn_offset>0 then
  begin
      mainwindow.caption:='Photometry calibration successfull';
      application.hint:=mainwindow.caption;
  end;
end;


procedure Tmainwindow.Copyposition1Click(Sender: TObject);
var
   Centroid : string;
begin
  if object_xc>0 then Centroid:=#9+'(Centroid)' else Centroid:='';
  Clipboard.AsText:=prepare_ra2(object_raM,': ')+#9+prepare_dec2(object_decM,'° ')+Centroid;
end;


procedure Tmainwindow.Copypositioninhrs1Click(Sender: TObject);
var
   Centroid : string;
begin
  if object_xc>0 then Centroid:=#9+'(Centroid)' else Centroid:='';
  Clipboard.AsText:=floattostr(object_raM*180/pi)+#9+floattostr(object_decM*180/pi)+Centroid;
end;


procedure Tmainwindow.Copypositioninradians1Click(Sender: TObject);
var
   Centroid : string;
begin
  if object_xc>0 then Centroid:=#9+'(Centroid)' else Centroid:='';
  Clipboard.AsText:=floattostr(object_raM)+#9+floattostr(object_decM)+Centroid;
end;


procedure Tmainwindow.CropFITSimage1Click(Sender: TObject);
var fitsX,fitsY,dum : integer;
   Save_Cursor:TCursor;
begin
  if ((fits_file=true) and (abs(stopX-startX)>10)and (abs(stopY-starty)>10)) then
  begin
   Save_Cursor := Screen.Cursor;
   Screen.Cursor := crHourglass;    { Show hourglass cursor }

   backup_img;

   if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
   if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

   width2:=stopX-startx+1;
   height2:=stopY-starty+1;
   setlength(img_temp,naxis3,width2,height2);{set length of image array}


   for fitsY:=startY to stopY do
     for fitsX:=startX to stopX do {crop image INCLUDING rectangle. Do this that if used near corners they are included}
      begin
        img_temp[0,fitsX-startX,fitsY-startY]:=img_loaded[0,fitsX,fitsY];
        if naxis3>1 then img_temp[1,fitsX-startX,fitsY-startY]:=img_loaded[1,fitsX,fitsY];{color}
        if naxis3>2 then img_temp[2,fitsX-startX,fitsY-startY]:=img_loaded[2,fitsX,fitsY];
      end;

   setlength(img_loaded,naxis3,width2,height2);{set length of image array}
   img_loaded[0]:=img_temp[0];
   if naxis3>1 then img_loaded[1]:=img_temp[1];
   if naxis3>2 then img_loaded[2]:=img_temp[2];

   img_temp:=nil; {free memory}

   plot_fits(mainwindow.image1,true,true);

   image_move_to_center:=true;

   update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
   update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);

   if crpix1<>0 then begin crpix1:=crpix1-startX; update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,crpix1);end;{adapt reference pixel of plate solution. Is no longer in the middle}
   if crpix2<>0 then begin crpix2:=crpix2-startY; update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,crpix2);end;

   Screen.Cursor:=Save_Cursor;
  end;
end;


procedure ra_text_to_radians(inp :string; var ra : double; var errorRA :boolean); {convert ra in text to double in radians}
var
  rah,ram,ras,plusmin :double;
  position1,position2,position3,error1,error2,error3:integer;
begin

  inp:= stringreplace(inp, ',', '.',[rfReplaceAll]);
  inp:= stringreplace(inp, ':', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 'h', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 'm', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 's', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, '  ', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, '  ', ' ',[rfReplaceAll]);

  inp:=trim(inp)+' ';
  if pos('-',inp)>0 then plusmin:=-1 else plusmin:=1;

  position1:=pos(' ',inp);
  val(copy(inp,1,position1-1),rah,error1);

  position2:=posex(' ',inp,position1+1);
  if position2-position1>1 then {ram available}
  begin
    val(copy(inp,position1+1,position2-position1-1),ram,error2);

    {ram found try ras}
    position3:=posex(' ',inp,position2+1);
    if position3-position2>1 then val( copy(inp,position2+1,position3-position2-1),ras,error3)
       else begin ras:=0;error3:=0;end;
  end
  else
    begin ram:=0;error2:=0; ras:=0; error3:=0; end;

  ra:=plusmin*(abs(rah)+ram/60+ras/3600)*pi/12;
  errorRA:=((error1<>0) or (error2>1) or (error3<>0) or (ra>2*pi));
end;


procedure Tmainwindow.ra1Change(Sender: TObject);
var
    str1   : string;
   errorRA : boolean;
begin
  ra_text_to_radians(ra1.text,ra_radians,errorRA); {convert ra in text to double in radians}

  str(ra_radians*12/pi:0:6,str1);
  ra_label.Caption:=str1;

  if errorRA then mainwindow.ra1.color:=clred else mainwindow.ra1.color:=clwindow;
end;


procedure dec_text_to_radians(inp :string; var dec : double; var errorDEC :boolean); {convert dec in text to double in radians}
var
  decd,decm,decs :double;
  position1,position2,position3,error1,error2,error3,plusmin:integer ;
begin
  inp:= stringreplace(inp, ',', '.',[rfReplaceAll]);
  inp:= stringreplace(inp, ':', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 'd', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 'm', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, 's', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, '°', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, '  ', ' ',[rfReplaceAll]);
  inp:= stringreplace(inp, '  ', ' ',[rfReplaceAll]);
  inp:=trim(inp)+' ';
  if pos('-',inp)>0 then plusmin:=-1 else plusmin:=1;

  position1:=pos(' ',inp);
  val(copy(inp,1,position1-1),decd,error1);


  position2:=posex(' ',inp,position1+1);
  if position2-position1>1 then {decm available}
  begin
    val(copy(inp,position1+1,position2-position1-1),decm,error2);

    {decm found try decs}
    position3:=posex(' ',inp,position2+1);
    if position3-position2>1 then val( copy(inp,position2+1,position3-position2-1),decs,error3)
       else begin decs:=0;error3:=0;end;
  end
  else
    begin decm:=0;error2:=0;decs:=0; error3:=0; end;

  dec:=plusmin*(abs(decd)+decm/60+decs/3600)*pi/180;
  errorDEC:=((error1<>0) or (error2>1) or (error3<>0));
end;


procedure Tmainwindow.dec1Change(Sender: TObject);
var
   str1     : string;
   errorDEC : boolean;
begin

  dec_text_to_radians(dec1.text,dec_radians,errorDEC); {convert dec in text to double in radians}

  str(dec_radians*180/pi:0:6,str1);
  dec_label.Caption:=str1;

  if (errorDEC) then mainwindow.dec1.color:=clred else mainwindow.dec1.color:=clwindow;
end;


procedure Tmainwindow.enterposition1Click(Sender: TObject);
var
  ra2,dec2,pixeldistance,distance,angle,angle2,angle3   : double;
  kommapos         : integer;
  error2,flipped   : boolean;
begin
  if sender=enterposition1 then
  begin
    shape_marker1_fitsX:=startX+1;
    shape_marker1_fitsY:=startY+1;
    show_marker_shape(mainwindow.shape_marker1,0 {rectangle},20,20,0 {minimum size},shape_marker1_fitsX, shape_marker1_fitsY);

    mouse_positionRADEC1:=InputBox('Enter α, δ of mouse position seperated by a comma:','Format 24 00 00.0, 90 00 00.0   or   24 00, 90 00',mouse_positionRADEC1);
    if mouse_positionRADEC1=''  then exit; {cancel used}
    shape_marker1.hint:='Reference 1: '+mouse_positionRADEC1
  end
  else
  if sender=enterposition2 then
  begin
    shape_marker2_fitsX:=startX+1;
    shape_marker2_fitsY:=startY+1;
    show_marker_shape(mainwindow.shape_marker2,0 {rectangle},20,20,0 {minimum size},shape_marker2_fitsX, shape_marker2_fitsY);

    mouse_positionRADEC2:=InputBox('Enter α, δ of mouse position seperated by a comma:','Format 24 00 00.0, 90 00 00.0   or   24 00, 90 00',mouse_positionRADEC2);
    if mouse_positionRADEC2=''  then exit;  {cancel used}
    shape_marker2.hint:='Reference 2: '+mouse_positionRADEC2
  end;

  if ( (mouse_positionRADEC1<>'') and (mouse_positionRADEC2<>'')) then {solve}
  begin
    flipped:=flipped1.checked; {flipped image}

    crpix1:=shape_marker1_fitsX;
    crpix2:=shape_marker1_fitsY;

    kommapos:=pos(',',mouse_positionRADEC1);
    ra_text_to_radians (copy(mouse_positionRADEC1,1  ,kommapos-1) ,ra0,error2); {convert ra text to ra_1 in radians}
    if error2 then begin beep;exit;end;
    dec_text_to_radians(copy(mouse_positionRADEC1,kommapos+1,99) ,dec0,error2); {convert dec text to dec_1 in radians}
    if error2 then begin beep;exit;end;

    kommapos:=pos(',',mouse_positionRADEC2);
    ra_text_to_radians (copy(mouse_positionRADEC2,1  ,kommapos-1) ,ra2,error2); {convert ra text to ra0 in radians}
    if error2 then begin beep;exit;end;
    dec_text_to_radians(copy(mouse_positionRADEC2,kommapos+1,99) ,dec2,error2); {convert dec text to dec0 in radians}
    if error2 then begin beep;exit;end;

    pixeldistance:=sqrt(sqr(shape_marker2_fitsX- shape_marker1_fitsX)+sqr(shape_marker2_fitsY- shape_marker1_fitsY));
    ang_sep(ra0,dec0,ra2,dec2 ,distance);{calculate distance in radians}

    cdelt2:=distance*180/(pi*pixeldistance);
    if flipped then cdelt1:=-cdelt2 else cdelt1:=cdelt2;

    {find crota2}
   {see meeus new formula 46.5, angel of moon limb}
    angle2:=arctan2(cos(dec2)*sin(ra2-ra0),sin(dec2)*cos(dec0) - cos(dec2)*sin(dec0)*cos(ra2-ra0)); {angle between line between the two stars and north}
    angle3:=arctan2(shape_marker2_fitsX- shape_marker1_fitsX,shape_marker2_fitsY- shape_marker1_fitsY); {angle between top and line between two reference pixels}

    if flipped then
      angle:=(angle2+angle3)  ELSE angle:=(-angle2+angle3);{swapped n-s or e-w image}

    angle:=fnmodulo(angle,2*pi);

    if angle< -pi then angle:=angle+2*pi;
    if angle>=+pi then angle:=angle-2*pi;

    crota2:=-angle*180/pi;{crota2 is defined north to west, so reverse}
    crota1:=crota2;

    old_to_new_WCS;{ {new WCS missing, convert old WCS to new}

    update_text ('CTYPE1  =',#39+'RA---TAN'+#39+'           / first parameter RA  ,  projection TANgential   ');
    update_text ('CTYPE2  =',#39+'DEC--TAN'+#39+'           / second parameter DEC,  projection TANgential   ');
    update_text ('CUNIT1  =',#39+'deg     '+#39+'           / Unit of coordinates                            ');

    update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,crpix1);
    update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,crpix2);

    update_float  ('CRVAL1  =',' / RA of reference pixel (deg)                    ' ,ra0*180/pi);
    update_float  ('CRVAL2  =',' / DEC of reference pixel (deg)                   ' ,dec0*180/pi);


    update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,cdelt1);
    update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,cdelt2);

    update_float  ('CROTA1  =',' / Image twist of X axis        (deg)             ' ,crota1);
    update_float  ('CROTA2  =',' / Image twist of Y axis        (deg)             ' ,crota2);

    update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_1);
    update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_2);
    update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_1);
    update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_2);
    update_text   ('PLTSOLVD=','                   T / ASTAP manual with two positions');

    update_menu_related_to_solver(true); {update menu section related to solver succesfull}

    plot_north;
  end;
end;


procedure Tmainwindow.inversimage1Click(Sender: TObject);
var
  max_range, col,fitsX,fitsY : integer;
  Save_Cursor:TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  backup_img;

  if nrbits=8 then max_range:= 255 else max_range:=65535;

  for col:=0 to naxis3-1 do {do all colours}
  begin
    For fitsY:=0 to (height2-1) do
      for fitsX:=0 to (width2-1) do
      begin
        img_loaded[col,fitsX,fitsY]:=max_range-img_loaded[col,fitsX,fitsY]
      end;
  end;

  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,false,true);

  Screen.Cursor := Save_Cursor;  { Always restore to normal }
end;


procedure Tmainwindow.set_area1Click(Sender: TObject);
var
    dum : integer;
begin
  if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
  if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;


  {selected area colour replace}
  areax1:=startX;
  areay1:=startY;
  areax2:=stopX;
  areay2:=stopY;
  stackmenu1.area_set1.caption:='✓';
end;


procedure Tmainwindow.rotate_arbitrary1Click(Sender: TObject);
var
  col,fitsX,fitsY,maxsize,i,j,progress_value,progressC,xx,yy        : integer;
  cosA,sinA,factor, centerx,centery,centerxs,centerys,angle,value   : double;
  valueI : string;
  Save_Cursor:TCursor;
const
  resolution=10;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  valueI:=InputBox('Rotation angle CW in degrees:','','' );
  if valueI=''  then exit;
  angle:=strtofloat2(valueI);

  memo2_message('Start rotation. This takes some time.');
  backup_img;

  if flip_horizontal1.checked then angle:=-angle;{change rotation if flipped}
  if flip_vertical1.checked then   angle:=-angle;{change rotation if flipped}

  if width2<>height2 then {fresh image}
    maxsize:=round(1+sqrt(sqr(height2)+sqr(width2))) {add one pixel otherwise not enough resulting in runtime errors}
  else {assume this image is already rotated. Enough space to rotate}
    maxsize:=width2;

  centerX:=maxsize/2;
  centerY:=maxsize/2;
  centerxs:=width2/2;
  centerys:=height2/2;

  setlength(img_temp,naxis3, maxsize,maxsize);{set length of new image}

  {clear array}
  for col:=0 to naxis3-1 do {do all colours}
  begin
    For fitsY:=0 to (maxsize-1) do
      for fitsX:=0 to (maxsize-1) do
        img_temp[col,fitsX,fitsY]:=0
  end;

  sincos(-angle*pi/180,sinA,cosA);
  factor:=1/sqr(resolution);{1/(number of subpixels), typical 1/(10x10)}

  progressC:=0;
  For fitsY:=0 to (height2-1) do
  begin
    inc(progressC);{counter}
    if frac(fitsY/100)=0 then
      begin
        Application.ProcessMessages;{this could change startX, startY}
        if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;

        progress_value:=round(progressC*100/(height2));{progress in %}
        progress_indicator(progress_value,'');{report progress}
      end;

    for fitsX:=0 to (width2-1) do
    begin
      value:=img_loaded[0,fitsX,fitsY];
      if value>=0.01 then {do only data. Use red for detection}
      for i:=0 to resolution-1 do {divide the pixel in resolution x resolution subpixels}
      for j:=0 to resolution-1 do {divide the pixel in resolution x resolution subpixels}
      begin
        {new position of subpixel}
        xx:=trunc(centerX +(fitsX-centerxs-0.5+i/resolution)*cosA - (fitsY-centerys-0.5+j/resolution)*sinA);
        yy:=trunc(centerY +(fitsX-centerxs-0.5+i/resolution)*sinA + (fitsY-centerys-0.5+j/resolution)*cosA);
        {do all colours}
        img_temp[0,xx,yy ]:=img_temp[0,xx,yy] + value*factor;{factor is typical 1/100 due to 10x10 subpixel}
        if naxis3>=2 then img_temp[1,xx,yy]:=img_temp[1,xx,yy] + img_loaded[1,fitsX,fitsY]*factor; {this is the fastest way rather then for col:=0 to naxis3-1 loop}
        if naxis3>=3 then img_temp[2,xx,yy]:=img_temp[2,xx,yy] + img_loaded[2,fitsX,fitsY]*factor;
      end;
    end;
  end;

  width2:=maxsize;
  height2:=maxsize;
  update_integer('NAXIS1  =',' / length of x axis                               ' ,width2);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,height2);

  img_loaded:=img_temp;
  img_temp:=nil;
  plot_fits(mainwindow.image1,false,true);

  if cd1_1<>0 then {update solution for rotation}
  begin
     if ((crpix1<>0.5+centerxs) or (crpix2<>0.5+centerys)) then {reference is not center}
     begin  {to much hassle to fix. Just remove the solution}
       remove_key('CD1_1   ',false);
       remove_key('CD1_2   ',false);
       remove_key('CD2_1   ',false);
       remove_key('CD2_2   ',false);
     end;
     crota2:=fnmodulo(crota2-angle,360);
     crota1:=fnmodulo(crota1-angle,360);
     crpix1:=centerX;
     crpix2:=centerY;
     old_to_new_WCS;{convert old style FITS to newd style}

     update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_1);
     update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd1_2);
     update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_1);
     update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,cd2_2);


     update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,crpix1);
     update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,crpix2);

     update_float  ('CROTA1  =',' / Image twist of X axis        (deg)             ' ,crota1);
     update_float  ('CROTA2  =',' / Image twist of Y axis        (deg)             ' ,crota2);

     add_text   ('HISTORY   ','Rotated by angle '+valueI);

     plot_north;
  end;

  progress_indicator(-100,'');{back to normal}
  Screen.Cursor := Save_Cursor;  { Always restore to normal }

  memo2_message('Rotation done.');
end;


procedure Tmainwindow.histogram1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
   value: string;
begin
   value:=inttostr(round(hist_range*x/histogram1.Width));
   mainwindow.CAPTION:='Histogram value: ' +value;
   application.hint:=mainwindow.caption;
   histogram1.hint:=value;
end;


procedure listview_add_xy(fitsX,fitsY: double);{add x,y position to listview}
var
    i: integer;
begin
 with stackmenu1 do
 for i:=0 to listview1.Items.Count-1 do
   if listview1.Items[i].Selected then
  begin
    ListView1.Items.item[i].subitems.Strings[I_X]:=floattostrF2(fitsX,0,2);
    ListView1.Items.item[i].subitems.Strings[I_Y]:=floattostrF2(fitsY,0,2);
  end;
end;


function RGBToH(r,g,b : single): integer;
{https://en.wikipedia.org/wiki/Hue}
{Preucil used a polar plot, which he termed a color circle.[8] Using R, G, and B, one may compute hue angle using the following scheme: determine which of the six possible orderings of R, G, and B prevail, then apply the formula given in the table below. }
var
  H, D, Cmax, Cmin: Single;
begin
  Cmax := Max(R, Max(G, B));
  Cmin := Min(R, Min(G, B));

  if Cmax = Cmin then
    h := 0
  else
  begin
    D := Cmax - Cmin;

    if R = Cmax then h := (G - B) / D
    else
    if G = Cmax then h := 2 + (B - R) / D
    else
    h := 4 + (R - G) / D;

    h := h * 60; {make range 0..360}
    if h < 0 then
       h := h + 360;
  end;
  result:=round(h)
end;


procedure find_highest_pixel_value(img: image_array;box, x1,y1: integer; var xc,yc:double);{}
var
  i,j,k,w,h  : integer;
  value, val, SumVal,SumValX,SumValY, Xg,Yg : double;

  function value_subpixel(x1,y1:double):double; {calculate image pixel value on subpixel level}
  var
    x_trunc,y_trunc: integer;
    x_frac,y_frac  : double;
  begin
    x_trunc:=trunc(x1);
    y_trunc:=trunc(y1);
    if ((x_trunc<=0) or (x_trunc>=(width2-2)) or (y_trunc<=0) or (y_trunc>=(height2-2))) then begin result:=0; exit;end;
    x_frac :=frac(x1);
    y_frac :=frac(y1);
    try
      result:=         (img[0,x_trunc  ,y_trunc  ]) * (1-x_frac)*(1-y_frac);{pixel left top, 1}
      result:=result + (img[0,x_trunc+1,y_trunc  ]) * (  x_frac)*(1-y_frac);{pixel right top, 2}
      result:=result + (img[0,x_trunc  ,y_trunc+1]) * (1-x_frac)*(  y_frac);{pixel left bottom, 3}
      result:=result + (img[0,x_trunc+1,y_trunc+1]) * (  x_frac)*(  y_frac);{pixel right bottom, 4}
    except
    end;
  end;

begin
  w:=Length(img[0]); {width}
  h:=Length(img[0,0]); {height}

  if ((x1>=box) and (x1<w-box) and (y1>=box) and (y1<h-box))=false then begin {don't try too close to boundaries} xc:=x1; yc:=y1;  exit end;

  xc:=x1;
  yc:=y1;

  for k:=1 to 2 do {repeat for maximum accuracy}
  begin

    value:=-99999;
    {find highest pixel}
    for i:=round(xc)-box to round(xc)+box do
    for j:=round(yc)-box to round(yc)+box do
    begin
        val:=img[0,i,j];
        if val>value then
        begin
          value:=val;
        end;
    end;

    {find center of gravity}
    SumVal:=0;
    SumValX:=0;
    SumValY:=0;

    for i:=-box to +box do
    for j:=-box to +box do
    begin
      val:=value_subpixel(xc+i,yc+j) - value/2;{use only the brightets parts above half max}
      if val>0 then val:=sqr(val);{sqr highest pixels}
      SumVal:=SumVal+val;
      SumValX:=SumValX+val*(i);
      SumValY:=SumValY+val*(j);
    end;
    Xg:=SumValX/SumVal;{offset}
    Yg:=SumValY/SumVal;
    xc:=(xc+Xg);
    yc:=(yc+Yg);
  end;{repeat}

 {center of gravity found}
end;


procedure Tmainwindow.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  xf,yf,k, fx,fy, shapetype                 : integer;
  hfd2,fwhm_star2,snr,flux,xc,yc : double;
begin
  if flip_horizontal1.Checked then xf:=image1.width-1-x else xf:=x;;
  if flip_vertical1.Checked then yf:=image1.height-1-y else yf:=y;

  startX:=round(-0.5+(xf+0.5)/(image1.width/width2));{starts at -0.5 and  middle pixels is 0}
  startY:=round(-0.5+height2-(yf+0.5)/(image1.height/height2)); {from bottom to top, starts at -0.5 and 0 at middle first pixel}

  stopX:=startX;{prevent random crop and other actions}
  stopY:=startY;

  {default good values}
  snr:=2;
  hfd2:=2;{just a good value}

  {for manual alignment}
  if ( ((stackmenu1.use_manual_alignment1.checked) and (pos('S',calstat)=0 {ignore stacked images unless callled from listview1. See doubleclick listview1} )) or
        (stackmenu1.pagecontrol1.tabindex=8 {photometry})){measure one object in blink routine } then
  begin
    if pos('small',stackmenu1.manual_centering1.text)<>0 then {comet}
    begin
      find_highest_pixel_value(img_loaded,10,startX,startY,xc,yc);
    end
    else
    if pos('medium',stackmenu1.manual_centering1.text)<>0 then {comet}
    begin
      find_highest_pixel_value(img_loaded,20,startX,startY,xc,yc);
    end
    else
    if pos('large',stackmenu1.manual_centering1.text)<>0 then {comet}
    begin
      find_highest_pixel_value(img_loaded,30,startX,startY,xc,yc);
    end

    else
    if pos('No',stackmenu1.manual_centering1.text)<>0 then {no centering}
    begin
      xc:=startX;{0..width2-1}
      yc:=startY;
    end
    else {star alignment}
    HFD(img_loaded,startX,startY,14{box size},hfd2,fwhm_star2,snr,flux,xc,yc); {auto center using HFD function}


    if hfd2<90 then {detected something}
    begin
      shape_fitsX:=xc+1;{calculate fits positions}
      shape_fitsY:=yc+1;
      listview_add_xy(shape_fitsX,shape_fitsY);{add to list}
      if snr>1 then shapetype:=1 {circle} else shapetype:=0;{square}
      show_marker_shape(mainwindow.shape_alignment_marker1,shapetype,20,20,10{minimum},shape_fitsX, shape_fitsY);
    end;
  end
  else
  mainwindow.shape_alignment_marker1.visible:=false;
  {end manual alignment}

  image_move_to_center:=false;{image in moved to center, why is so difficult???}

  down_x:=x;
  down_y:=y;

  if ssleft in shift then
  begin
    screen.Cursor := crhandpoint;

    if naxis3=3 then {for colour replace function}
    begin
      sample(startX,startY);
    end;

    if copy_paste then {paste copied image part}
    begin
      for k:=0 to naxis3-1 do {do all colors}
      begin
        for fy:=copy_paste_y to copy_paste_y+copy_paste_h-1 do
        for fX:=copy_paste_x to copy_paste_x+copy_paste_w-1 do
        begin
          img_loaded[k,max(0,min(width2-1,round(startX+(fx-copy_paste_x)- (copy_paste_w div 2)))),max(0,min(height2-1,round(startY+(fy-copy_paste_y) - (copy_paste_h div 2))))]:=img_backup[index_backup].img[k,fx,fy];{use backup for case overlap occurs}
        end;
      end;{k color}
      plot_fits(mainwindow.image1,false,true);
      copy_paste:=false;
      shape_paste1.visible:=false;
    end;
  end;{left button pressed}
end;


procedure HFD(img: image_array;x1,y1,rs {boxsize}: integer; var hfd1,star_fwhm,snr{peak/sigma noise}, flux,xc,yc:double);{calculate star HFD and FWHM, SNR, xc and yc are center of gravity. All x,y coordinates in array[0..] positions}
const
  max_ri=50; //should be larger or equal then sqrt(sqr(rs+rs)+sqr(rs+rs))+1;
var
  i,j, ri, distance,distance_top_value,illuminated_pixels,signal_counter,iterations,counter :integer;
  SumVal,SumValX,SumValY,SumValR, Xg,Yg, r,{xs,ys,}
  val,bg_average,bg,sd,sd_old,pixel_counter,valmax : double;
  HistStart,boxed : boolean;
  distance_histogram : array [0..max_ri] of integer;

    function value_subpixel(x1,y1:double):double; {calculate image pixel value on subpixel level}
    var
      x_trunc,y_trunc: integer;
      x_frac,y_frac  : double;
    begin
      x_trunc:=trunc(x1);
      y_trunc:=trunc(y1);
      if ((x_trunc<=0) or (x_trunc>=(width2-2)) or (y_trunc<=0) or (y_trunc>=(height2-2))) then begin result:=0; exit;end;
      x_frac :=frac(x1);
      y_frac :=frac(y1);
      try
        result:=         (img[0,x_trunc  ,y_trunc  ]) * (1-x_frac)*(1-y_frac);{pixel left top, 1}
        result:=result + (img[0,x_trunc+1,y_trunc  ]) * (  x_frac)*(1-y_frac);{pixel right top, 2}
        result:=result + (img[0,x_trunc  ,y_trunc+1]) * (1-x_frac)*(  y_frac);{pixel left bottom, 3}
        result:=result + (img[0,x_trunc+1,y_trunc+1]) * (  x_frac)*(  y_frac);{pixel right bottom, 4}
      except
      end;
    end;
begin
  if ((x1-rs-4<=0) or (x1+rs+4>=width2-1) or
      (y1-rs-4<=0) or (y1+rs+4>=height2-1) )
    then begin hfd1:=999; snr:=0; exit;end;

  valmax:=0;
  hfd1:=999;
  snr:=0;

  try
    sd:=99999999999;
    bg:=0;
    iterations:=0;

    repeat {find background by repeat and exclude values above 3*sd}
      counter:=0;
      bg_average:=0;
      for i:=-rs-4 to rs+4 do {calculate mean at square boundaries of detection box}
      for j:=-rs-4 to rs+4 do
      begin
        if ( (abs(i)>rs) and (abs(j)>rs) ) then {measure only outside the box}
        begin
          val:=img[0,x1+i,y1+j];
          if  ((iterations=0) or (abs(val-bg)<=3*sd)) then  {ignore extreme outliers after first run}
          begin
            bg_average:=bg_average+val;
            inc(counter);
          end;
        end;
      end;
      bg:=bg_average/counter; {mean value background}

      counter:=0;
      sd_old:=sd;
      sd:=0;
      for i:=-rs-4 to rs+4 do {calculate standard deviation background at the square boundaries of detection box}
        for j:=-rs-4 to rs+4 do
        begin
          if ( (abs(i)>rs) and (abs(j)>rs) ) then {measure only outside the box}
          begin
              val:=img[0,x1+i,y1+j];
              if val<=2*bg then {not an extreme outlier}
              if ((iterations=0) or (abs(val-bg)<=3*sd_old)) then {ignore extreme outliers after first run}
              begin
                sd:=sd+sqr(val-bg);
                inc(counter);
              end;
          end;
      end;
      sd:=sqrt(sd/(counter+0.0001)); {standard deviation in background}

      inc(iterations);
    until (((sd_old-sd)<0.1*sd) or (iterations>=3));{repeat until sd is stable or enough iterations}
    sd:=max(sd,1); {add some value for images with zero noise background. This will prevent that background is seen as a star. E.g. some jpg processed by nova.astrometry.net}

     repeat {reduce box size till symmetry to remove stars}
    // Get center of gravity whithin star detection box and count signal pixels
      SumVal:=0;
      SumValX:=0;
      SumValY:=0;
      signal_counter:=0;

      for i:=-rs to rs do
      for j:=-rs to rs do
      begin
        val:=(img[0,x1+i,y1+j])- bg;
        if val>3*sd then
        begin
          SumVal:=SumVal+val;
          SumValX:=SumValX+val*(i);
          SumValY:=SumValY+val*(j);
          inc(signal_counter); {how many pixels are illuminated}
        end;
      end;
      if sumval<= 12*sd then exit; {no star found, too noisy, exit with hfd=999}

      Xg:=SumValX/SumVal;
      Yg:=SumValY/SumVal;
      xc:=(x1+Xg);
      yc:=(y1+Yg);
     {center of gravity found}

      if ((xc-rs<0) or (xc+rs>width2-1) or (yc-rs<0) or (yc+rs>height2-1) ) then exit;{prevent runtime errors near sides of images}

      boxed:=(signal_counter>=(2/9)*sqr(rs+rs+1));{are inside the box 2 of the 9 of the pixels illuminated?}

      if boxed=false then
      begin
        if rs>4 then dec(rs,2) else dec(rs,1); {try a smaller window to exclude nearby stars}
      end;

      {check on hot pixels}
      if signal_counter<=1  then
      exit {one hot pixel}
      else
      if ((signal_counter=2) and (img[0,round(xc)+i,round(yc)+j]-bg<3*sd)) then exit; {two hot pixels}


    until ((boxed) or (rs<=1)) ;{loop and reduce box size until star is boxed}

    inc(rs,2);{add some space}
    // Build signal histogram from center of gravity
    for i:=0 to rs do distance_histogram[i]:=0;{clear signal histogram for the range used}
    for i:=-rs to rs do begin
      for j:=-rs to rs do begin

        distance:=round(sqrt(i*i + j*j)); {distance from gravity center} {modA}
        if distance<=rs then {build histogram for circel with radius rs}
        begin
          val:=value_subpixel(xc+i,yc+j)-bg;
          if val>3*sd then {3 * sd should be signal }
          begin
            distance_histogram[distance]:=distance_histogram[distance]+1;{build distance histogram up to circel with diameter rs}
            if val>valmax then valmax:=val;{record the peak value of the star}
          end;
        end;
      end;
    end;

    ri:=-1;
    distance_top_value:=0;
    HistStart:=false;
    illuminated_pixels:=0;
    repeat
      inc(ri);
      illuminated_pixels:=illuminated_pixels+distance_histogram[ri];
      if distance_histogram[ri]>0 then HistStart:=true;{continue until we found a value>0, center of defocused star image can be black having a central obstruction in the telescope}
      if distance_top_value<distance_histogram[ri] then distance_top_value:=distance_histogram[ri]; {this should be 2*pi*ri if it is nice defocused star disk}
    until ( (ri>=rs) or (HistStart and (distance_histogram[ri]<=0.1*distance_top_value {drop-off detection})));{find a distance where there is no pixel illuminated, so the border of the star image of interest}
    if ri>=rs then exit; {star is equal or larger then box, abort}

    if (ri>2)and(illuminated_pixels<0.35*sqr(ri+ri-2)){35% surface} then exit;  {not a star disk but stars, abort with hfd 999}

    except
  end;

  // Get HFD
  SumVal:=0;
  SumValR:=0;
  pixel_counter:=0;

  begin   // Get HFD using the aproximation routine assuming that HFD line divides the star in equal portions of gravity:
    for i:=-ri to ri do {Make steps of one pixel}
    for j:=-ri to ri do
    begin
      Val:=value_subpixel(xc+i,yc+j)-bg; {The calculated center of gravity is a floating point position and can be anyware, so calculate pixel values on sub-pixel level}
      r:=sqrt(i*i+j*j); {Distance from star gravity center}
      SumVal:=SumVal+Val; {Sumval will be star total flux value}
      SumValR:=SumValR+Val*r; {Method Kazuhisa Miyashita, see notes of HFD calculation method}
      if val>=valmax*0.5 then pixel_counter:=pixel_counter+1;{How many pixels are above half maximum}
    end;
    if Sumval<0.00001 then flux:=0.00001 else flux:=Sumval;{prevent dividing by zero or negative values}

    hfd1:=2*SumValR/flux;

    hfd1:=max(0.7,hfd1);

//    if hfd1>1 then mainwindow.image1.Canvas.textout(x1,y1,floattostrF2(hfd1,3,1)+'|'+floattostrF2(distance_histogram[0],0,0)+'.'+floattostrF2(distance_histogram[1],0,0)+'.'+floattostrF2(distance_histogram[2],0,0)+'.'+floattostrF2(distance_histogram[3],0,0)  );
//    if hfd1>1 then  mainwindow.image1.Canvas.textout(round(xc),round(yc),{floattostrF2(faintest/brightest,3,2)+'|'+ }floattostrF2(flux,5,0)+'|'+ floattostrF2(rs,2,0));

    star_fwhm:=2*sqrt(pixel_counter/pi);{calculate from surface (by counting pixels above half max) the diameter equals FWHM }

    snr:=flux/sqrt(flux +sqr(ri)*pi*sqr(sd)); {For both bright stars (shot-noise limited) or skybackground limited situations  snr:=signal/sqrt(signal + r*r*pi* SKYsignal) equals snr:=flux/sqrt(flux + r*r*pi* sd^2). }

//    log_to_file('snr_test.csv',inttostr(round(snr*1000))+','+inttostr(round(snr_old*1000)));

    {==========Notes on HFD calculation method=================
      Documented the HFD defintion also in https://en.wikipedia.org/wiki/Half_flux_diameter
      References:
      http://www005.upp.so-net.ne.jp/k_miyash/occ02/halffluxdiameter/halffluxdiameter_en.html       by Kazuhisa Miyashita. No sub-pixel calculation
      https://www.lost-infinity.com/night-sky-image-processing-part-6-measuring-the-half-flux-diameter-hfd-of-a-star-a-simple-c-implementation/
      http://www.ccdware.com/Files/ITS%20Paper.pdf     See page 10, HFD Measurement Algorithm

      HFD, Half Flux Diameter is defined as: The diameter of circle where total flux value of pixels inside is equal to the outside pixel's.
      HFR, half flux radius:=0.5*HFD
      The pixel_flux:=pixel_value - background.

      The approximation routine assumes that the HFD line divides the star in equal portions of gravity:
          sum(pixel_flux * (distance_from_the_centroid - HFR))=0
      This can be rewritten as
         sum(pixel_flux * distance_from_the_centroid) - sum(pixel_values * (HFR))=0
         or
         HFR:=sum(pixel_flux * distance_from_the_centroid))/sum(pixel_flux)
         HFD:=2*HFR

      This is not an exact method but a very efficient routine. Numerical checking with an a highly oversampled artificial Gaussian shaped star indicates the following:

      Perfect two dimensional Gaussian shape with σ=1:   Numerical HFD=2.3548*σ                     Approximation 2.5066, an offset of +6.4%
      Homogeneous disk of a single value  :              Numerical HFD:=disk_diameter/sqrt(2)       Approximation disk_diameter/1.5, an offset of -6.1%

      The approximation routine is robust and efficient.

      Since the number of pixels illuminated is small and the calculated center of star gravity is not at the center of an pixel, above summation should be calculated on sub-pixel level (as used here)
      or the image should be re-sampled to a higher resolution.

      A sufficient signal to noise is required to have valid HFD value due to background noise.

      Note that for perfect Gaussian shape both the HFD and FWHM are at the same 2.3548 σ.
      }


     {=============Notes on FWHM:=====================
        1)	Determine the background level by the averaging the boarder pixels.
        2)	Calculate the standard deviation of the background.

            Signal is anything 3 * standard deviation above background

        3)	Determine the maximum signal level of region of interest.
        4)	Count pixels which are equal or above half maximum level.
        5)	Use the pixel count as area and calculate the diameter of that area  as diameter:=2 *sqrt(count/pi).}
  end;
end;


function local_sdold(x1,y1, ri{regio of interest} : integer; img : image_array):double;{calculate standard deviation in img at position x1, y1 in a rectangle with sides 2*ri+1}
var i,j,counter : integer;
    average,sd,val: double;
begin
  if ((x1-ri<0) or (x1+ri>width2-1) or
      (y1-ri<0) or (y1+ri>height2-1) )
    then begin result:=999; exit;end;


  average:=0;
  for i:=-ri to ri do {calculate average background at the square boundaries of region of interest}
  for j:=-ri to ri do {calculate average background at the square boundaries of region of interest}
  begin
    average:=average+img[0,x1+i,y1+j];
  end;
  average:=average/sqr(ri+ri+1); {background average}

  sd:=0;
  counter:=0;

  for i:=-ri to ri do {calculate standard deviation  of region of interest}
  for j:=-ri to ri do {calculate standard deviation  of region of interest}
  begin
    val:=img[0,x1+i,y1+j];
    if val<2*average then {ignore hot pixels}
    begin
      sd:=sd+sqr(average-img[0,x1+i,y1+j]);
      inc(counter);
    end;
  end;
  if counter<>0 then result:=sqrt(sd/counter) {standard deviation in background}
                else result:=999;
end;

procedure local_sd(x1,y1, x2,y2,col : integer;{accuracy: double;} img : image_array; var sd,mean :double);{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}
var i,j,counter,iterations,w,h : integer;
    value,stepsize,median_position, most_common,mc_1,mc_2,mc_3,mc_4,
    sd_old,meanx, median,minimum, maximum,max_counter, saturated : double;

begin
  w:=Length(img[0]); {width}
  h:=Length(img[0,0]); {height}

  x1:=max(x1,0);{protect against values outside the array}
  x2:=min(x2,w-1);

  y1:=max(y1,0);
  y2:=min(y2,h-1);

  sd:=99999;
  mean:=0;
  if ((y1>y2) or (x1>x2)) then exit;

  iterations:=0;
  repeat
    {mean}
    counter:=0;
    meanx:=0;
    for j:=y1 to y2  do {calculate standard deviation  of region of interest}
    for i:=x1 to x2 do {calculate standard deviation  of region of interest}
    begin
      value:=img[col,i,j];
      if  ((iterations=0) or (abs(value-mean)<=3*sd)) then  {ignore outliers after first run}
      begin
        inc(counter);
        meanx:=meanx+value; {mean}
       end;
     end;{filter outliers}
    if counter<>0 then mean:=meanx/counter {calculate the mean};

    {sd}
    sd_old:=sd;
    counter:=0;
    for j:=y1 to y2  do {calculate standard deviation  of region of interest}
    for i:=x1 to x2 do {calculate standard deviation  of region of interest}
    begin
      value:=img[col,i,j];
      if value<2*mean then {not a large outlier}
      if ((iterations=0) or (abs(value-mean)<=3*sd_old)) then {ignore outliers after first run}
      begin
        sd:=sd+sqr(mean-value);
        inc(counter);
      end;
    end;
    if counter<>0 then sd:=sqrt(sd/counter);

    inc(iterations);
  until (((sd_old-sd)<0.03*sd) or (iterations>=7));{repeat until sd is stable or 7 iterations}
end;


function rgb_kelvin(red,blue :single):string;{range 2000-20000 kelvin}
var
   ratio,ratio2,ratio3,ratio4,ratio5, temperature :double;
begin
  if ((blue>=18) {and (blue<=250)} and (red>=18) {and (red<=250)}) then {shall not be saturated or near zero}
  begin
    ratio:=blue/red;
    if ((ratio>0.04) and (ratio<1.55)) then {between 2000 and 20000 kelvin}
    begin
      // y = 4817,4x5 - 4194,2x4 - 7126,7x3 + 12922x2 - 2082,2x + 2189,8
      {blackbody temperature, excel polynom fit based on table, http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html}
      ratio2:=ratio*ratio;
      ratio3:=ratio2*ratio;
      ratio4:=ratio3*ratio;
      ratio5:=ratio4*ratio;

      temperature:=
                    +4817.4*ratio5
                    -4194.2*ratio4
                    -7126.7*ratio3
                    +12922 *ratio2
                    -2082.2 *ratio
                    +2189.8;
      result:=inttostr(round(temperature))+'K';
    end
    else
    result:='';
  end
  else
  result:='';
end;


procedure calculate_equatorial_mouse_position(fitsx,fitsy : double; var   ram,decm  : double {mouse position});
var
   fits_unsampledX, fits_unsampledY :double;
   u,v,u2,v2             : double;
   dRa,dDec,delta,gamma  : double;

begin
 RAM:=0;DECM:=0;{for case wrong index or CD1_1=0}
 {DSS polynom solution}
 if mainwindow.polynomial1.itemindex=2 then {DSS survey}
 begin
 { Convert from image subsampled pixels position to unsampled pixel position }
   fits_unsampledX:=subsamp*(fitsX-0.5)+0.5;
   fits_unsampledY:=subsamp*(fitsY-0.5)+0.5;
                 //{fits (1,1)+subsamp of 2x =>(eqv unsampled 1,5,1,5)
                 // fits (2,2)+subsamp of 2x =>(eqv unsampled 3,5,3,5)
                 //(fits 1,1)+subsamp of 4x=>(eqv unsampled 2.5,2.5)
                 //(fits 2,2)+subsamp of 4=>(eqv unsampled 6.5,6.5)
   dsspos(fits_unsampledX , fits_unsampledY, ram, decm );
 end
 else
 begin {WCS and SIP solutions}
   if ((mainwindow.Polynomial1.itemindex=1) and (a_order>=2)) then {SIP, Simple Imaging Polynomial use by astrometry.net or spitzer}
   begin
     u:=fitsx-crpix1;
     v:=fitsy-crpix2;
     u2:=u + a_2_0*u*u + a_0_2*v*v + a_1_1*u*v + a_2_1*u*u*v+ a_1_2*u*v*v + a_3_0*u*u*u + a_0_3*v*v*v; {SIP correction for second or third order}
     v2:=v + b_2_0*u*u + b_0_2*v*v + b_1_1*u*v + b_2_1*u*u*v+ b_1_2*u*v*v + b_3_0*u*u*u + b_0_3*v*v*v; {SIP correction for second or third order}
     dRa :=(cd1_1*(u2)+cd1_2*(v2))*pi/180;
     dDec:=(cd2_1*(u2)+cd2_2*(v2))*pi/180;
     delta:=cos(dec0)-dDec*sin(dec0);
     gamma:=sqrt(dRa*dRa+delta*delta);

     ram:=ra0+arctan2(Dra,delta); {atan2 is required for images containing celestial pole}
     if ram<0 then ram:=ram+2*pi;
     if ram>pi*2 then ram:=ram-pi*2;
     decm:=arctan((sin(dec0)+dDec*cos(dec0))/gamma);
   end
   else
   if (mainwindow.Polynomial1.itemindex=0) then
   begin  {improved new WCS}
     if cd1_1<>0 then
     begin
       dRa :=(cd1_1*(fitsx-crpix1)+cd1_2*(fitsy-crpix2))*pi/180;
       dDec:=(cd2_1*(fitsx-crpix1)+cd2_2*(fitsy-crpix2))*pi/180;
       delta:=cos(dec0)-dDec*sin(dec0);
       gamma:=sqrt(dRa*dRa+delta*delta);

       ram:=ra0+arctan2(Dra,delta); {arctan2 is required for images containing celestial pole}
       if ram<0 then ram:=ram+2*pi;
       if ram>pi*2 then ram:=ram-pi*2;
       decm:=arctan((sin(dec0)+dDec*cos(dec0))/gamma);
     end;
   end;
 end;{WCS solution}
end;


procedure erase_rectangle;
begin
  begin
    mainwindow.image1.Canvas.Pen.color:=clblack;{define otherwise problems in Linux}
    mainwindow.image1.Canvas.Pen.Mode := pmNotXor;       { use XOR mode to draw/erase }
    mainwindow.image1.Canvas.Pen.width := round(1+width2/mainwindow.image1.width);{thick lines because image is stretched smaller and otherwise line can't been seen}
    mainwindow.image1.Canvas.MoveTo(start_RX , start_RY);   { move pen back to origin }

    mainwindow.image1.Canvas.LineTo(stop_RX,start_RY);        { erase the old line }
    mainwindow.image1.Canvas.LineTo(stop_RX,stop_RY);          { erase the old line }
    mainwindow.image1.Canvas.LineTo(start_RX,stop_RY);        { erase the old line }
    mainwindow.image1.Canvas.LineTo(start_RX,start_RY);      { erase the old line }
    mainwindow.image1.Canvas.Pen.Mode := pmCopy;{back to normal}
  end;
end;


procedure draw_rectangle(x_sized,y_sized:integer);
begin
  mainwindow.image1.Canvas.Pen.color:=clblack;
  mainwindow.image1.Canvas.Pen.Mode := pmNotXor;       { use XOR mode to draw/erase }
  mainwindow.image1.Canvas.Pen.width := round(1+width2/mainwindow.image1.width);{thick lines because image is stretched smaller and otherwise line can't been seen}
  mainwindow.image1.Canvas.LineTo(X_sized, start_RY);    { draw the new line }
  mainwindow.image1.Canvas.LineTo(X_sized, Y_sized);   { draw the new line }
  mainwindow.image1.Canvas.LineTo(start_RX, Y_sized);    { draw the new line }
  mainwindow.image1.Canvas.LineTo(start_RX, start_RY);     { draw the new line }
  mainwindow.image1.Canvas.Pen.Mode := pmCopy;{back to normal}
end;


procedure Tmainwindow.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);

var
  hfd2,fwhm_star2,snr,flux,xf,yf, raM,decM,pixel_distance,sd,dummy : double;
  s1,s2, hfd_str, fwhm_str,snr_str,mag_str,dist_str,angle_str      : string;
  x_sized,y_sized,factor,flipH,flipV                               :integer;
  color1:tcolor;
  r,b :single;
begin
   if ssleft in shift then {swipe effect}
   begin
     if abs(y-down_y)>2 then
     begin
       mainwindow.image1.Top:= mainwindow.image1.Top+(y-down_y);
     //   timage(sender).Top:= timage(sender).Top+(y-down_y);{could be used for second image}

       mainwindow.shape_marker1.Top:= mainwindow.shape_marker1.Top+(y-down_y);{normal marker}
       mainwindow.shape_marker2.Top:= mainwindow.shape_marker2.Top+(y-down_y);{normal marker}
       mainwindow.shape_marker3.Top:= mainwindow.shape_marker3.Top+(y-down_y);{normal marker}
     end;
     if abs(x-down_x)>2 then
     begin
       mainwindow.image1.left:= mainwindow.image1.left+(x-down_x);
      //  timage(sender).left:= timage(sender).left+(x-down_x);

       mainwindow.shape_marker1.left:= mainwindow.shape_marker1.left+(x-down_x);{normal marker}
       mainwindow.shape_marker2.left:= mainwindow.shape_marker2.left+(x-down_x);{normal marker}
       mainwindow.shape_marker3.left:= mainwindow.shape_marker3.left+(x-down_x);{normal marker}
     end;

     exit;{no more to do}
   end;

   if flip_horizontal1.Checked then flipH:=-1 else flipH:=1;
   if flip_vertical1.Checked then  flipV:=-1 else flipV:=1;

   if flipH=-1 then xf:=image1.width-1-x else xf:=x;;
   if flipV=-1 then yf:=image1.height-1-y else yf:=y;

   mouse_fitsx:=0.5+(0.5+xf)/(image1.width/width2);{starts at +0.5 and  middle pixels is 1}
   mouse_fitsy:=0.5+height2-(0.5+yf)/(image1.height/height2); {from bottom to top, starts at +0.5 and 1 at middle first pixel}


//  rubber rectangle
   x_sized:=trunc(x*width2/image1.width);
   y_sized:=trunc(y*height2/image1.height);

   if ssright in shift then {for crop function}
   begin
     if mouse_enter=1 then
     begin
       start_RX:= x_sized;
       start_RY:= y_sized;
       stop_RX:= x_sized;
       stop_RY:= y_sized;
     end;
     mouse_enter:=2;{right button pressed}
   end
   else
   mouse_enter:=0;


   factor:=round(1+width2/image1.width);
   if ((abs(stop_RX -x)>factor) and (abs(stop_RY -y)>factor))then
   begin
     if ssright in shift then {rubber rectangle}
     begin
       erase_rectangle;
       draw_rectangle(x_sized,y_sized);

       stopX:=round(-1+mouse_fitsX); {starts at -0.5 and  middle pixels is 0}
       stopY:=round(-1+mouse_fitsY); {from bottom to top, starts at -0.5 and 0 at middle first pixel}

       if cdelt2<>0 then
       begin
         pixel_distance:= 3600*sqrt (sqr((X_sized-start_RX)*cdelt1)+sqr((start_RY-Y_sized)*cdelt2));{pixel distance in arcsec}
         if pixel_distance<60 then dist_str:=inttostr(round(pixel_distance))+'"'
         else
         if pixel_distance<3600 then dist_str:=floattostrF(pixel_distance/60,ffgeneral,3,2)+#39
         else
         dist_str:=floattostrF(pixel_distance/3600,ffgeneral,3,2)+'°';
       end
       else dist_str:='';
       if cdelt2<>0 then angle_str:='∠='+inttostr(round(fnmodulo (arctan2(flipH*(X_sized-start_RX),flipV*(start_RY-Y_sized))*180/pi + crota2,360)) )+'°' else  angle_str:=''; ;
       mainwindow.statusbar1.panels[7].text:=inttostr(abs(X_sized-start_RX)-1)+' x '+inttostr(abs(start_RY-Y_sized)-1)+'    '+dist_str+'    '+angle_str;{indicate rectangl size}
     end
     else
     begin
       start_RX:=x_sized; {These values are the same startX,.... except if image is flipped}
       start_RY:=y_sized;
       mainwindow.statusbar1.panels[7].text:='';{remove crop size}
     end;
     stop_RX:=x_sized; {These values are the same startX,.... except if image is flipped}
     stop_RY:=y_sized;
   end;
  {end rubber rectangle}

   if ssright in shift then exit; {rubber rectangle with update statusbar is very slow. Does it trigger an event???}

   {give screen pixel value}
   str(mouse_fitsx:4:1,s1);  {fits images start with 1 and not with 0}
   str(mouse_fitsy:4:1,s2); {Y from bottom to top}

   {prevent some rounding errors just outside the dimensions}
   if mouse_fitsY<1 then mouse_fitsY:=1;
   if mouse_fitsX<1 then mouse_fitsX:=1;
   if mouse_fitsY>height2 then mouse_fitsY:=height2;
   if mouse_fitsX>width2 then mouse_fitsX:=width2;

   if copy_paste then
        show_marker_shape(mainwindow.shape_paste1,0 {rectangle},copy_paste_w,copy_paste_h,0{minimum}, mouse_fitsx, mouse_fitsy);{show the paste shape}
   try color1:=ColorToRGB(mainwindow.image1.canvas.pixels[trunc(x*width2/image1.width),trunc(y*height2/image1.height)]); ;except;end;  {note  getpixel(image1.canvas.handle,x,y) doesn't work well since X,Y follows zoom  factor !!!}

   if naxis3=3 then {for star temperature}
   begin
     try
       r:=img_loaded[0,round(mouse_fitsx)-1,round(mouse_fitsy)-1]-cblack;
       b:=img_loaded[2,round(mouse_fitsx)-1,round(mouse_fitsy)-1]-cblack;
     except
       {some rounding error, just outside dimensions}
     end;
   end
   else
   begin
     r:=0;
     b:=0;
   end;

   mainwindow.statusbar1.panels[4].text:=floattostrF(GetRValue(color1),ffgeneral,5,0)+'/'   {screen colors}
                                       + floattostrF(GetGValue(color1),ffgeneral,5,0)+'/'
                                       + floattostrF(GetBValue(color1),ffgeneral,5,0)+
                                       '  '+rgb_kelvin(r,b) ;
   try
     if naxis3=1 then mainwindow.statusbar1.panels[3].text:=s1+', '+s2+' = ['+floattostrF(img_loaded[0,round(mouse_fitsX)-1,round(mouse_fitsY)-1],ffgeneral,5,0)+']' else
     if naxis3=3 then mainwindow.statusbar1.panels[3].text:=s1+', '+s2+' = ['+floattostrF(img_loaded[0,round(mouse_fitsX)-1,round(mouse_fitsY)-1],ffgeneral,5,0)+'/'+ {color}
                                                                              floattostrF(img_loaded[1,round(mouse_fitsX)-1,round(mouse_fitsY)-1],ffgeneral,5,0)+'/'+
                                                                              floattostrF(img_loaded[2,round(mouse_fitsX)-1,round(mouse_fitsY)-1],ffgeneral,5,0)+' '+']'
     else mainwindow.statusbar1.panels[3].text:='';
   except

   end;

   hfd2:=999;
   HFD(img_loaded,round(mouse_fitsX-1),round(mouse_fitsY-1),14{box size},hfd2,fwhm_star2,snr,flux,object_xc,object_yc);{input coordinates in array[0..] output coordinates in array [0..]}

   //mainwindow.caption:=floattostr(mouse_fitsX)+',   '+floattostr(mouse_fitsy)+',         '+floattostr(object_xc)+',   '+floattostr(object_yc);

   if ((hfd2<99) and (hfd2>0)) then
   begin
     if hfd2>1 then str(hfd2:0:1,hfd_str) else str(hfd2:0:2,hfd_str);
     str(fwhm_star2:0:1,fwhm_str);
     str(snr:0:0,snr_str);
     if flux_magn_offset<>0 then {offset calculated in star annotation call}
     begin
        str(flux_magn_offset-ln(flux)*2.511886432/ln(10):0:2,mag_str);
        mag_str:=', MAGN='+mag_str;
     end
     else mag_str:='';

     calculate_equatorial_mouse_position(object_xc+1,object_yc+1,object_raM,object_decM);{input in FITS coordinates}
     mainwindow.statusbar1.panels[1].text:=prepare_ra2(object_raM,': ')+'   '+prepare_dec2(object_decM,'° ');
     mainwindow.statusbar1.panels[2].text:='HFD='+hfd_str+', FWHM='+FWHM_str+', SNR='+snr_str+mag_str;
   end
   else
   begin
     object_xc:=-999999;
     mainwindow.statusbar1.panels[1].text:='';

     local_sd(round(mouse_fitsX-1)-10,round(mouse_fitsY-1)-10, round(mouse_fitsX-1)+10,round(mouse_fitsY-1)+10{regio of interest},0 {col},img_loaded, sd,dummy {mean});{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}
     mainwindow.statusbar1.panels[2].text:='σ = '+ floattostrf( sd,ffFixed{ ffgeneral}, 4, 1);
   end;
  calculate_equatorial_mouse_position(mouse_fitsx,mouse_fitsy,raM,decM);

   mainwindow.statusbar1.panels[0].text:=position_to_string('   ',raM,decM);
end;


procedure Tmainwindow.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  xf, yf : integer;
begin
   if button=mbright then
   begin
     PopupMenu1.PopUp;{call popup manually if right key is released, not when clicked. Set in popupmenu autopopup off !!!}
     {$IfDef Darwin}// for OS X,
     {not required in Mac. After popup the rectangle is gone}
      {$ELSE}
      erase_rectangle;
     {$ENDIF}
   end;

  screen.Cursor := crDefault;
end;


procedure Tmainwindow.convertmono1Click(Sender: TObject);
var
   Save_Cursor:TCursor;
   fitsX,fitsY: integer;
begin
  if naxis3<3 then exit;{prevent run time error mono images}
  Save_Cursor := Screen.Cursor;
  Screen.Cursor:= crHourGlass;

  backup_img;

  setlength(img_loaded,1,width2,height2);{set length of image array mono}

  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
     img_loaded[0,fitsx,fitsy]:=(img_backup[index_backup].img[0,fitsx,fitsy]+img_backup[index_backup].img[1,fitsx,fitsy]+img_backup[index_backup].img[2,fitsx,fitsy])/3;

  naxis:=2;{mono}
  update_integer('NAXIS   =',' / Number of dimensions                           ' ,naxis);{2 for mono, 3 for colour}
  naxis3:=1;
  remove_key('NAXIS3  =',false{all});{some programs don't like NAXIS3=1 like maxim DL}

  add_text('HISTORY   ','Converted to mono');

  {colours are now mixed, redraw histogram}
  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,false,true);{plot}
  Screen.cursor:=Save_Cursor;
end;


procedure Tmainwindow.stretch_draw1Click(Sender: TObject); {stretch draw}
var
  tmpbmp: TBitmap;
  ARect: TRect;
  oldcursor: tcursor;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor:= crHourGlass;

  backup_img;
  try
    TmpBmp := TBitmap.Create;
    try
      TmpBmp.Width  := mainwindow.image1.width;
      TmpBmp.Height := mainwindow.image1.height;
      ARect := Rect(0,0, mainwindow.image1.width, mainwindow.image1.height);
      TmpBmp.Canvas.StretchDraw(ARect, mainwindow.Image1.Picture.bitmap);
      mainwindow.Image1.Picture.bitmap.Assign(TmpBmp);
    finally
       TmpBmp.Free;
    end;
    except
  end;
  Screen.Cursor:=OldCursor;
end;


procedure Tmainwindow.SaveFITSwithupdatedheader1Click(Sender: TObject);
var
  filename_bak: string;
begin
  try
    filename_bak:=changeFileExt(filename2,'.bak');
    if fileexists(filename_bak) then deletefile(filename_bak);
    if renamefile(filename2,filename_bak) then savefits_update_header(filename_bak,filename2);
    //mainwindow.caption:='File saved!';
  except
  end;
end;


procedure Tmainwindow.Memo1Change(Sender: TObject);
begin
  save1.Enabled:=true;
end;


procedure Tmainwindow.SaveasJPGPNGBMP1Click(Sender: TObject);
var filename3:ansistring;
   {$IFDEF fpc}
   PNG: TPortableNetworkGraphic;{FPC}
   {$else} {delphi}
   PNG: TPNGObject;
   {$endif}
   JPG: TJPEGImage;

begin
  filename3:=ChangeFileExt(FileName2,'');
  savedialog1.initialdir:=ExtractFilePath(filename3);
  savedialog1.filename:=filename3;
  savedialog1.Filter := 'PNG 8 bit(*.png)|*.png;|BMP 8 bit(*.bmp)|*.bmp;|JPG 100% compression quality (*.jpg)|*.jpg;|JPG 90% compression quality (*.jpg)|*.jpg;|JPG 80% compression quality (*.jpg)|*.jpg;|JPG 70% compression quality (*.jpg)|*.jpg;';
  savedialog1.filterindex:=SaveasJPGPNGBMP1filterindex; {4 or jpg 90%}
  if savedialog1.execute then
  begin
    if ((pos('.PNG',uppercase(savedialog1.filename))>0) or (savedialog1.filterindex=1) )  then
    begin
      {$IFDEF fpc}
       png:= TPortableNetworkGraphic.Create;   {FPC}
      {$else} {delphi}
      PNG := TPNGObject.Create;
      {$endif}
      try
        PNG.Assign(mainwindow.image1.Picture.Graphic);    //Convert data into png
        savedialog1.filename:=ChangeFileExt(savedialog1.filename,'.png');
        PNG.SaveToFile(savedialog1.filename);
      finally
       PNG.Free;
      end;
    end
    else
    if ((pos('.JPG',uppercase(savedialog1.filename))>0) or (savedialog1.filterindex>=3))then
    begin
      {$IFDEF fpc}
      JPG := TJPEGImage.Create;
      {$else} {delphi}
      JPG := TJPEGImage.Create;
     {$endif}
      try
        JPG.Assign(mainwindow.image1.Picture.Graphic);    //Convert data into JPG
        if savedialog1.filterindex=3 then JPG.CompressionQuality :=100;
        if savedialog1.filterindex=4 then JPG.CompressionQuality :=90;
        if savedialog1.filterindex=5 then JPG.CompressionQuality :=80;
        if savedialog1.filterindex=6 then JPG.CompressionQuality :=70;
        savedialog1.filename:=ChangeFileExt(savedialog1.filename,'.jpg');
        JPG.SaveToFile(savedialog1.filename);
      finally
       JPG.Free;
      end;
    end
    else  {(savedialog1.filterindex=2)}
    begin {bitmap}
      savedialog1.filename:=ChangeFileExt(savedialog1.filename,'.bmp');
      mainwindow.image1.picture.SaveToFile(savedialog1.filename);
    end;
    SaveasJPGPNGBMP1filterindex:=savedialog1.filterindex;{remember}
  end;
end;


function stretch_img(img1: image_array):image_array;{stretch image, three colour or mono}
var
 colrr,colgg,colbb,col_r,col_g,col_b, largest,luminance,luminance_stretched,factor,sat_factor,h,s,v : single;
 fitsX,fitsY :integer;
begin
  setlength(result,naxis3,width2,height2);
  sat_factor:=1-mainwindow.saturation_factor_plot1.position/10;

  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
    begin
      if naxis3=3 then
      begin
        col_r:=img1[0,fitsx,fitsy];
        col_g:=img1[1,fitsx,fitsy];
        col_b:=img1[2,fitsx,fitsy];

        colrr:=(col_r-cblack)/(cwhite-cblack);{scale to 0..1}
        colgg:=(col_g-cblack)/(cwhite-cblack);{scale to 0..1}
        colbb:=(col_b-cblack)/(cwhite-cblack);{scale to 0..1}

        if sat_factor<>1 then {adjust saturation}
        begin
          RGB2HSV(colrr,colgg,colbb,h,s,v);
          HSV2RGB(h,s*sat_factor,v,colrr,colgg,colbb);{increase/decrease colour saturation}
        end;

        if colrr<=0.00000000001 then colrr:=0.00000000001;
        if colgg<=0.00000000001 then colgg:=0.00000000001;
        if colbb<=0.00000000001 then colbb:=0.00000000001;

        {find brightest colour and resize all if above 1}
        largest:=colrr;
        if colgg>largest then largest:=colgg;
        if colbb>largest then largest:=colbb;
        if largest>1 then {clamp to 1 but preserve colour, so ratio r,g,b}
        begin
          colrr:=colrr/largest;
          colgg:=colgg/largest;
          colbb:=colbb/largest;
          largest:=1;
        end;

        if stretch_on then {Stretch luminance only. Keep RGB ratio !!}
        begin
          luminance:=(colrr+colgg+colbb)/3;{luminance in range 0..1}
          luminance_stretched:=stretch_c[trunc(32768*luminance)];
          factor:=luminance_stretched/luminance;
          if factor*largest>1 then factor:=1/largest; {clamp again, could be higher then 1}
          col_r:=round(colrr*factor*65535);{stretch only luminance but keep rgb ratio!}
          col_g:=round(colgg*factor*65535);{stretch only luminance but keep rgb ratio!}
          col_b:=round(colbb*factor*65535);{stretch only luminance but keep rgb ratio!}
        end
        else
        begin
          col_r:=round(65535*colrr);
          col_g:=round(65535*colgg);
          col_b:=round(65535*colbb);
        end;

        result[0,fitsx,fitsy]:=col_r;
        result[1,fitsx,fitsy]:=col_g;
        result[2,fitsx,fitsy]:=col_b;
      end {RGB fits with naxis3=3}
      else
      begin {mono, naxis3=1}
        col_r:=img1[0,fitsx,fitsy];
        colrr:=(col_r-cblack)/(cwhite-cblack);{scale to 1}
        if colrr<=0.00000000001 then colrr:=0.00000000001;
        if colrr>1 then colrr:=1;
        if stretch_on then
        begin
          col_r:=round(65535*stretch_c[trunc(32768*colrr)]);{sqrt is equivalent to gamma=0.5}
        end
        else
        begin
          col_r:=round(65535*colrr);{sqrt is equivalent to gamma=0.5}
        end;
        result[0,fitsx,fitsy] :=col_r;
      end;
    end;
end;


function save_PPM_PGM_PFM(img: image_array; wide2,height2,colourdepth:integer; filen2:ansistring;flip_H,flip_V:boolean): boolean;{save to 16 bit portable pixmap/graymap file (PPM/PGM) file }
var
  ppmbuffer32: array[0..trunc(bufwide/4)] of Dword; {bufwide is set in astap_main and is 120000}
  ppmbuffer: array[0..bufwide] of byte absolute ppmbuffer32;

  header: array[0..26] of ansichar;
  thefile : tfilestream;
  i,j,k,m : integer;
  dum: double;
  dummy : word;

  value1   : single;
  lw       : longword absolute value1;
begin
  result:=false;
  if colourdepth=48 then {colour}
    header:=pansichar('P6'+#10+inttostr(width2)+#10+inttostr(height2)+#10+'65535'+#10) {colour 48 bit}
  else
  if colourdepth=16 then {gray}
    header:=pansichar('P5'+#10+inttostr(width2)+#10+inttostr(height2)+#10+'65535'+#10) {mono 16 bit}
  else
  if colourdepth=96 then {colour}
    header:=pansichar('PF'+#10+inttostr(width2)+#10+inttostr(height2)+#10+'-1.0'+#10) {mono 32 bit}
  else
  if colourdepth=32 then {gray}
    header:=pansichar('Pf'+#10+inttostr(width2)+#10+inttostr(height2)+#10+'-1.0'+#10); {colour 32 bit, little-endian=-1, big-endian=+1}

  if fileexists(filen2)=true then
    if MessageDlg('Existing file ' +filen2+ ' Overwrite?', mtConfirmation, [mbYes, mbNo], 0) <> 6 {mbYes} then
      Exit;

  try
   thefile:=tfilestream.Create(filen2, fmcreate );
  except
   thefile.free;
   exit;
  end;

  { Write PPM/PGM Header }
  thefile.writebuffer ( header, strlen(Header));

  { Write Image Data }
  if colourdepth=48 then {colour}
  begin
    for i:=0 to Height2-1 do
    begin
      if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
      for j:=0 to wide2-1 do
      begin
        if flip_H=true then m:=wide2-1-j else m:=j;
        dum:=img[0,m,k]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
        ppmbuffer[m*6  ]  :=hi(dummy);
        ppmbuffer[m*6+1]  :=lo(dummy);
        dum:=img[1,m,k]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
        ppmbuffer[m*6+2]  :=hi(dummy);
        ppmbuffer[m*6+3]  :=lo(dummy);
        dum:=img[2,m,k]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
        ppmbuffer[m*6+4]  :=hi(dummy);
        ppmbuffer[m*6+5]  :=lo(dummy);
      end;
      thefile.writebuffer(ppmbuffer,wide2*6 {2 or 2*3}) ;{works only for byte arrays}
    end;
  end
  else
  if colourdepth=16 then
  begin  {mono/gray}
    for i:=0 to Height2-1 do
    begin
      if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
      for j:=0 to wide2-1 do
      begin
        if flip_H=true then m:=wide2-1-j else m:=j;
        dum:=img[0,m,k]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
        ppmbuffer[m*2  ]  :=hi(dummy);
        ppmbuffer[m*2+1]  :=lo(dummy);
      end;
      thefile.writebuffer(ppmbuffer,wide2*2 {}) ;{works only for byte arrays}
    end;
  end;
  if colourdepth=96 then {PFM 32 bit float colour files, little endian}
   begin
     for i:=0 to Height2-1 do
     begin
       if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
       for j:=0 to wide2-1 do
       begin
         if flip_H=true then m:=wide2-1-j else m:=j;
         value1:=img[0,m,k]/65535;
         ppmbuffer32[m*3]:=lw;
         value1:=img[1,m,k]/65535;
         ppmbuffer32[m*3+1]:=lw;
         value1:=img[2,m,k]/65535;
         ppmbuffer32[m*3+2]:=lw;
       end;
       thefile.writebuffer(ppmbuffer,wide2*4*3{}) ;{works only for byte arrays}
     end;
   end
   else
   if colourdepth=32 then  {PFM 32 bit float gray scale file, little endian}
   begin  {mono/gray}
     for i:=0 to Height2-1 do
     begin
       if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
       for j:=0 to wide2-1 do
       begin
         if flip_H=true then m:=wide2-1-j else m:=j;

         value1:=img[0,m,k]/65535;
         ppmbuffer32[m]:=lw;
       end;
       thefile.writebuffer(ppmbuffer,wide2*4 {}) ;{works only for byte arrays}
     end;
   end;

  thefile.free;
  result:=true;
end;

function save_PNG16(img: image_array; colors,wide2,height2:integer; filen2:string;flip_H,flip_V:boolean): boolean;{save to PNG file }
var
  i, j, k,m      :integer;
  image: TFPCustomImage;
  writer: TFPCustomImageWriter;
  thecolor  :Tfpcolor;
begin
  Image := TFPMemoryImage.Create(width2, height2);
  Writer := TFPWriterPNG.Create;

  with TFPWriterPNG(Writer) do
  begin
    indexed := false;
    wordsized := true;
    UseAlpha := false;
    GrayScale := (colors=1);
  end;
  For i:=0 to height2-1 do
  begin
    if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
    for j:=0 to width2-1 do
    begin
      if flip_H=true then m:=wide2-1-j else m:=j;
      thecolor.red:=min(round(img[0,m,k]), $FFFF);
      if colors>1 then thecolor.green:=min(round(img[1,m,k]), $FFFF)  else thecolor.green:=thecolor.red;
      if colors>2 then thecolor.blue:=min(round(img[2,m,k]), $FFFF)   else thecolor.blue:=thecolor.red;
      thecolor.alpha:=65535;
      image.Colors[j,i]:=thecolor;
    end;
  end;
  try
  Image.SaveToFile(filen2, Writer);
  except
    result:=false;
    exit;
  end;
  image.Free;
  writer.Free;
end;

//function save_PNM16(img: image_array; colors,wide2,height2:integer; filen2:string;flip_H,flip_V:boolean): boolean;{save to PNM file }
//var
//  i, j, k,m      :integer;
//  image: TFPCustomImage;
//  writer: TFPCustomImageWriter;
//  thecolor  :Tfpcolor;
//begin
//  Image := TFPMemoryImage.Create(width2, height2);
//  Writer := TFPWriterPNM.Create;

//  with TFPWriterPNM(Writer) do
//  begin
//    FullWidth:=true;{16 bit}
//  end;
//  For i:=0 to height2-1 do
//  begin
//    if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
//    for j:=0 to width2-1 do
//    begin
//      if flip_H=true then m:=wide2-1-j else m:=j;
//      thecolor.red:=min(round(img[0,m,k]), $FFFF);
//      if colors>1 then thecolor.green:=min(round(img[1,m,k]), $FFFF)  else thecolor.green:=thecolor.red;
//      if colors>2 then thecolor.blue:=min(round(img[2,m,k]), $FFFF)   else thecolor.blue:=thecolor.red;
//      thecolor.alpha:=65535;
//      image.Colors[j,i]:=thecolor;
//    end;
//  end;
//  try
//  Image.SaveToFile(filen2, Writer);
//  except
//    result:=false;
//    exit;
//  end;
//  image.Free;
//  writer.Free;
//end;


function save_tiff16(img: image_array; colors,wide2,height2:integer; filen2:string;flip_H,flip_V:boolean): boolean;{save to 48=3x16 color TIFF file }
var
  i, j, k,m      :integer;
  image: TFPCustomImage;
  writer: TFPCustomImageWriter;
  thecolor  :Tfpcolor;
begin
  Image := TFPMemoryImage.Create(width2, height2);
  Writer := TFPWriterTIFF.Create;


  Image.Extra[TiffAlphaBits]:='0';
  if nrbits<>8 then
  begin
    Image.Extra[TiffRedBits]:='16';
    Image.Extra[TiffGreenBits]:='16';
    Image.Extra[TiffBlueBits]:='16';
    Image.Extra[TiffGrayBits]:='16';
   end;
  {grayscale}
  if colors=1 then
  begin
    Image.Extra[TiffGrayBits]:='16';   {add unit fptiffcmn to make this work. see https://bugs.freepascal.org/view.php?id=35081}
    Image.Extra[TiffPhotoMetric]:='0'; {This is the same as Image.Extra['TiffPhotoMetricInterpretation']:='0';}
  end;

  image.Extra[TiffSoftware]:='ASTAP';
  image.Extra[TiffImageDescription]:=mainwindow.memo1.text; {store full header in TIFF !!!}
  Image.Extra[TiffCompression]:= '5'; // compression LZW

  For i:=0 to height2-1 do
  begin
    if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
    for j:=0 to width2-1 do
    begin
      if flip_H=true then m:=wide2-1-j else m:=j;
      thecolor.red:=min(round(img[0,m,k]), $FFFF);
      if colors>1 then thecolor.green:=min(round(img[1,m,k]), $FFFF)  else thecolor.green:=thecolor.red;
      if colors>2 then thecolor.blue:=min(round(img[2,m,k]), $FFFF)   else thecolor.blue:=thecolor.red;
      thecolor.alpha:=65535;
      image.Colors[j,i]:=thecolor;
    end;
  end;

  try
    Image.SaveToFile(filen2, Writer);
  except
    result:=false;
    exit;
  end;
  image.Free;
  writer.Free;
end;


procedure Tmainwindow.save_to_tiff1Click(Sender: TObject);
var
  I: integer;
  Save_Cursor:TCursor;
  err   : boolean;
  dobackup : boolean;
begin
  OpenDialog1.Title := 'Select multiple  files to convert';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=  'All formats except TIF|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP;*.new;*.ppm;*.pgm;*.pbm;*.pfm;*.xisf;*.fz;'+
                                      '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                         '|RAW files|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                         '|24 bits PNG, JPEG, BMP(*.png, *.jpg,*.bmp)|*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP'+
                         '|Compressed FITS files|*.fz';
  opendialog1.initialdir:=ExtractFileDir(filename2);
  fits_file:=false;
  esc_pressed:=false;
  err:=false;
  if OpenDialog1.Execute then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }
    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}

    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        Application.ProcessMessages;
        if esc_pressed then begin Screen.Cursor := Save_Cursor;  exit;end;
        filename2:=Strings[I];
        mainwindow.caption:=filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count);;
        if load_image(false {recenter},false {plot}) then
        begin
          filename2:=ChangeFileExt(filename2,'.tif');
          if abs(nrbits)<=16 then
          begin
            save_tiff16(img_loaded,naxis3,width2,height2,filename2,false {flip H},false {flip V});
          end
          else
          begin {32 bit files}
            if naxis3<>1 then {color}
              save_tiff_96(img_loaded,width2,height2,filename2,false {flip H},false {flip V}) {old uncompressed routine in unit_tiff}
            else
             save_tiff_32(img_loaded,width2,height2,filenamE2,false {flip H},false {flip V});{old uncompressed routine in unit_tiff}
          end;
        end
        else err:=true;
      end;
      if err=false then mainwindow.caption:='Completed, all files converted.'
      else
      mainwindow.caption:='Finished, files converted but with errors!';

      finally
      if dobackup then restore_img;{for the viewer}
      Screen.Cursor := Save_Cursor;  { Always restore to normal }
    end;
  end;
end;


procedure Tmainwindow.Export_image1Click(Sender: TObject);
var
  filename3:ansistring;
  OldCursor : TCursor;
begin
  filename3:=ChangeFileExt(FileName2,'');
  savedialog1.filename:=filename3;
  savedialog1.initialdir:=ExtractFilePath(filename3);

  if naxis3>1 then savedialog1.Filter := 'PNG 16 bit stretched|*.png|PNG 16 bit|*.png|TIFF 16 bit stretched|*.tif|TIFF 16 bit|*.tif|TIFF 32 bit float|*.tif|PPM 16 bit stretched|*.ppm;|PPM 16 bit|*.ppm|PFM 32 bit float|*.pfm'
              else savedialog1.Filter := 'PNG 16 bit stretched|*.png|PNG 16 bit|*.png|TIFF 16 bit stretched|*.tif|TIFF 16 bit|*.tif|TIFF 32 bit float|*.tif|PGM 16 bit stretched|*.pgm;|PGM 16 bit|*.pgm|PFM 32 bit float|*.pfm';
  savedialog1.filterindex:=SaveasTIFF1filterindex; {default 1}
  if savedialog1.execute then
  begin
    OldCursor := Screen.Cursor;
    Screen.Cursor:= crHourGlass;

    if naxis3>1 then {color}
    begin
      if savedialog1.filterindex=1 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_png16(img_temp,naxis3,width2,height2,savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=2 then
        save_png16(img_loaded,naxis3,width2,height2,savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=3 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_tiff16(img_temp,naxis3,width2,height2,savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=4 then
        save_tiff16(img_loaded,naxis3,width2,height2,savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=5 then
      save_tiff_96(img_loaded,width2,height2,savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked) {old uncompressed routine in unit_tiff}
      else
      if savedialog1.filterindex=6 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_PPM_PGM_PFM(img_temp,width2,height2,48 {colour depth},savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=7 then
          save_PPM_PGM_PFM(img_loaded,width2,height2,48 {colour depth},savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=8 then
          save_PPM_PGM_PFM(img_loaded,width2,height2,96 {colour depth},savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked);
    end {color}
    else
    begin {gray}
      if savedialog1.filterindex=1 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_png16(img_temp,naxis3,width2,height2,savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=2 then
        save_png16(img_loaded,naxis3,width2,height2,savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=3 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_tiff16(img_temp,naxis3,width2,height2,savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=4 then
      save_tiff16(img_loaded,naxis3,width2,height2,savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=5 then
        save_tiff_32(img_loaded,width2,height2,savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked){old uncompressed routine in unit_tiff}
      else
      if savedialog1.filterindex=6 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_PPM_PGM_PFM(img_temp,width2,height2,16{colour depth}, savedialog1.filename, flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=7 then
          save_PPM_PGM_PFM(img_loaded,width2,height2,16{colour depth},savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=8 then
          save_PPM_PGM_PFM(img_loaded,width2,height2,32 {colour depth},savedialog1.filename,flip_horizontal1.checked,flip_vertical1.checked);

    end;

    SaveasTIFF1filterindex:=savedialog1.filterindex;{remember}
    Screen.Cursor:= OldCursor;
  end;
end;


function number_of_fields(const C: char; const S: string ): integer; {count number of fields in string with C as seperator}
var
  i: Integer;
begin
  result := 0;
  for i := 1 to Length(S) do
    if S[i] = C then
      inc(result);

  if copy(s,length(s),1)<>c then inc(result,1);
end;


function retrieve_memo3_string(x,y :integer;default:string):string; {retrieve string at position x,y. Strings are seperated by #9}
var
  m,n1,n2 : integer;
  tal   : string;
begin
  result:='0';
  m:=-1;
  n2:=0;
  tal:=mainwindow.memo3.Lines[y]+#9;
  repeat
    inc(m);{counter}
    n1:=n2+1;
    n2:=posex(#9,tal,n1);
  until ((m>=x) or (n2=0));
  if ((n2<>0) and (n2>n1)) then
    result:=copy(tal,n1,n2-n1)
  else
     result:=default;
end;


Function INT_IEEE4_reverse(x: double):longword;{adapt intel floating point to non-intel float}
var
  value1   : single;
  lw       : longword absolute value1;
begin
  value1:=x;
  result:=swapendian(lw);
end;


function save_fits(img: image_array;filen2:ansistring;type1:integer;override1:boolean): boolean;{save to 8, 16 OR -32 BIT fits file}
var
  TheFile4 : tfilestream;
  I,j,k,r,bzero2, progressC,progress_value,dum, remain,minimum,maximum,dimensions, naxis3_local,height5,width5,rows : integer;
  dd : single;
  line0,tal,lab         : ansistring;
  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}
  OldCursor : TCursor;
  wo: word;
  rgb  : byteX3;{array [0..2] containing r,g,b colours}
  data      : longword;
begin
  result:=false;

  {get dimensions directly from array}
  naxis3_local:=length(img);{nr colours}
  width5:=length(img[0]);{width}
  height5:=length(img[0,0]);{length}
  if naxis3_local=1 then dimensions:=2 else dimensions:=3; {number of dimensions or colours}
  if naxis=0 then
                type1:=0;{only table}

  if ((type1=24) and (naxis3_local<3)) then
  begin
    application.messagebox(pchar('Abort, can not save monochrome image as colour image!!'),pchar('Error'),MB_OK);
    exit;
  end;

  if ((override1=false) and (fileexists(filen2)) and (pos('ImageToSolve.fit',filen2)=0)) then
    if MessageDlg('ASTAP: Existing file ' +filen2+ ' Overwrite?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then  Exit;

  if  override1=false then
  begin
    if extend>=2 then {bintable extensions in the file}
    begin
      if MessageDlg('File bintable extension will be reformatted as single floats only. Continue?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then  exit;
    end
    else
    if extend=1 then {ASCII table extensions in the file}
    begin
      if MessageDlg('ASCII table extension will be lost. Continue?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then  exit;
    end
  end;
  filename2:=filen2;
  {$IFDEF fpc}
  progress_indicator(0,'');
  {$else} {delphi}
  mainwindow.taskbar1.progressstate:=TTaskBarProgressState.Normal;
  mainwindow.taskbar1.progressvalue:=0; {show progress}

  {$endif}
  OldCursor := Screen.Cursor;
  Screen.Cursor:= crHourGlass;

  try
   TheFile4:=tfilestream.Create(filen2, fmcreate );
  except
   TheFile4.free;
   exit;
  end;

  unsaved_import:=false;{file is available for astrometry.net}

  progressC:=0;

 {update FITs header}
  if type1<>0 then {not a table}
  begin
    if type1<>24 then {standard FITS}
    begin
      update_integer('BITPIX  =',' / Bits per entry                                 ' ,type1); {16 or -32}
      update_integer('NAXIS   =',' / Number of dimensions                           ' ,dimensions);{number of dimensions, 2 for mono, 3 for colour}
      update_integer('NAXIS1  =',' / length of x axis                               ' ,width5);
      update_integer('NAXIS2  =',' / length of y axis                               ' ,height5);
      if naxis3_local<>1 then {color image}
        update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,naxis3_local)
        else
        remove_key('NAXIS3  ',false{all});{remove key word in header. Some program don't like naxis3=1}

      if type1=16 then bzero2:=32768 else bzero2:=0;
      update_integer('BZERO   =',' / Scaling applied to data                        ' ,bzero2);
      if type1<>8 then
      begin
        update_integer('DATAMIN =',' / Minimum data value                             ' ,round(datamin_org));
        update_integer('DATAMAX =',' / Maximum data value                             ' ,round(datamax_org));
        update_integer('CBLACK  =',' / Indicates the black point used when displaying the image.' ,round(cblack) ); {2019-4-9}
        update_integer('CWHITE  =',' / indicates the white point used when displaying the image.' ,round(cwhite) );
      end
      else
      begin {in most case reducing from 16 or flat to 8 bit}
        update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
        update_integer('DATAMAX =',' / Maximum data value                             ' ,255);
      end;
    end {update existing header}
    else
    begin {special 8 bit with three colors combined in 24 bit}
      {update FITs header}
      update_integer('BITPIX  =',' / Bits per entry                                 ' ,8);
      update_integer('NAXIS   =',' / Number of dimensions                           ' ,dimensions);{number dimensions, 2 for mono, 3 for color}
      update_integer('NAXIS1  =',' / length of x axis                               ' ,3);
      update_integer('NAXIS2  =',' / length of y axis                               ' ,width5);
      update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,height5);
      update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
      update_integer('DATAMAX =',' / Maximum data value                             ' ,255);
      update_integer('BZERO   =',' / Scaling applied to data                        ' ,0);
      {update existing header}
    end;
  end;
  {write memo1 header to file}
  for i:=0 to 79 do empthy_line[i]:=#32;{space}
  i:=0;
  repeat
     if i<mainwindow.memo1.lines.count then
     begin
       line0:=mainwindow.memo1.lines[i];
       while length(line0)<80 do line0:=line0+' ';{guarantee length is 80}
       strpcopy(aline,(copy(line0,1,80)));{copy 80 and not more}
       thefile4.writebuffer(aline,80);{write updated header from memo1}
     end
     else
     thefile4.writebuffer(empthy_line,80);{write empthy line}
     inc(i);
  until ((i>=mainwindow.memo1.lines.count) and (frac(i*80/2880)=0)); {write multiply records 36x80 or 2880 bytes}

  if type1=8 then
  begin
    minimum:=min(0,mainwindow.minimum1.position); {stretch later if required}
    maximum:=max(255,mainwindow.maximum1.position);
    for k:=0 to naxis3_local-1 do {do all colors}
    for i:=0 to height5-1 do
    begin
      inc(progressC);
      progress_value:=round(progressC*100/(naxis3_local*height5));{progress in %}
      {$IFDEF fpc}
      if frac(progress_value/5)=0 then progress_indicator(progress_value,'');{report increase insteps of 5%}
      {$else} {delphi}
      if frac(progress_value/5)=0 mainwindow.taskbar1.progressvalue:=progress_value;
      {$endif}

      for j:=0 to width5-1 do
      begin
        dd:=img[k,j,i];{save all colors}
        dum:=round((dd-minimum)*255/(maximum-minimum));{scale to 0..255}
        if dum<0 then dum:=0;
        if dum>255 then dum:=255;
        fitsbuffer[j]:=dum;
      end;
      thefile4.writebuffer(fitsbuffer,width5); {write as bytes}
    end;
  end
  else
  if type1=24 then
  begin
    minimum:=min(0,mainwindow.minimum1.position); {stretch later if required}
    maximum:=max(255,mainwindow.maximum1.position);

    for i:=0 to height5-1 do
    begin
      inc(progressC);
      progress_value:=round(progressC*100/(naxis3_local*height5));{progress in %}
      {$IFDEF fpc}
      if frac(progress_value/5)=0 then progress_indicator(progress_value,'');{report increase insteps of 5%}
      {$else} {delphi}
      if frac(progress_value/5)=0 mainwindow.taskbar1.progressvalue:=progress_value;
      {$endif}

      for j:=0 to width5-1 do
      begin
        for k:=0 to 2 do {do all colors}
        begin
          dd:=img[k,j,i];{save all colors}
          dum:=round((dd-minimum)*255/(maximum-minimum));{scale to 0..255}
          if dum<0 then dum:=0;
          if dum>255 then dum:=255;
          rgb[k]:=dum;
        end;
        fitsbufferRGB[j]:=rgb;
      end;
      thefile4.writebuffer(fitsbufferRGB,width5+width5+width5); {write as bytes}
    end;
  end
  else

  if type1=16 then
  begin
    for k:=0 to naxis3_local-1 do {do all colors}
    for i:=0 to height5-1 do
    begin

      inc(progressC);
      progress_value:=round(progressC*100/(naxis3_local*height5));{progress in %}
      {$IFDEF fpc}
      if frac(progress_value/5)=0 then progress_indicator(progress_value,'');{report increase insteps of 5%}
      {$else} {delphi}
      if frac(progress_value/5)=0 mainwindow.taskbar1.progressvalue:=progress_value;
      {$endif}

      for j:=0 to width5-1 do
      begin
        dum:=bzero2+round(img[k,j,i]);{save all colors}
        dum:=dum and $FFFF;{mod 2018-9-10}
        wo:=dum;
        fitsbuffer2[j]:=swap(wo) and $FFFF;{in FITS file hi en low bytes are swapped}
      end;
      thefile4.writebuffer(fitsbuffer2,width5+width5); {write as bytes}
    end;
  end
  else
  if type1=-32 then
  begin
    for k:=0 to naxis3_local-1 do {do all colors}
    for i:=0 to height5-1 do
    begin
      inc(progressC);
      progress_value:=round(progressC*100/(naxis3_local*height5));{progress in %}
      {$IFDEF fpc}
      if frac(progress_value/5)=0 then progress_indicator(progress_value,'');{report increase in steps of 5%}
      {$else} {delphi}
      if frac(progress_value/5)=0 mainwindow.taskbar1.progressvalue:=progress_value;
      {$endif}
      for j:=0 to width5-1 do
      begin
       // img[0,j,i]:=341.7177734375;  {equals non intel 3772492355}
     //  if img[k,j,i]>4100 then img[k,j,i]:=4100;

        fitsbuffer4[j]:=INT_IEEE4_reverse(img[k,j,i]);{in FITS file hi en low bytes are swapped}
      end;
      thefile4.writebuffer(fitsbuffer4,width5*4); {write as bytes}
    end;
  end;
  remain:=round(2880*(1-frac(thefile4.position/2880)));{some program like have a multi of 2880 like astrometry.net}
  if ((remain<>0) and (remain<>2880)) then
  begin
    FillChar(fitsbuffer, remain, 0);
    thefile4.writebuffer(fitsbuffer,remain);{write some bytes}
  end;

  if extend>=2 then {write bintable extension}
  begin
    rows:=number_of_fields(#9,mainwindow.memo3.lines[3]); {first lines could be blank or incomplete}

    tal:=mainwindow.memo3.lines[0];
    i:=0;

    strplcopy(aline,'XTENSION= '+#39+'BINTABLE'+#39+' / FITS Binary Table Extension                              ',80);{copy 80 and not more or less in position aline[80] should be #0 from string}
    thefile4.writebuffer(aline,80); inc(i);

    strplcopy(aline,  'BITPIX  =                    8 / 8-bits character format                                  ',80);
    thefile4.writebuffer(aline,80);inc(i);

    strplcopy(aline,  'NAXIS   =                    2 / Tables are 2-D char. array                               ',80);
    thefile4.writebuffer(aline,80);inc(i);

    str(rows*4:13,tal); {write only 4 byte floats}
    strplcopy(        aline,'NAXIS1  =        '+tal+' / Bytes in row                                             ',80);
    thefile4.writebuffer(aline,80);inc(i);

    str(mainwindow.memo3.lines.count-1-1 :13,tal);
    strplcopy(aline,      'NAXIS2  =        '+tal  +' /                                                          ',80);
    thefile4.writebuffer(aline,80);inc(i);

    strplcopy(  aline,'PCOUNT  =                    0 / Parameter count always 0                                 ',80);
    thefile4.writebuffer(aline,80);inc(i);

    strplcopy(aline,  'GCOUNT  =                    1 / Group count always 1                                     ',80);
    thefile4.writebuffer(aline,80);inc(i);

    str(rows  :3,tal);
    strplcopy(aline,'TFIELDS =                  '+tal+            ' / No. of col in table                                      ',80);
    thefile4.writebuffer(aline,80);inc(i);


    for k:=1 to rows do
    begin
      str(k:0,tal); tal:=copy(tal+'  ',1,3);
      strplcopy(aline,'TFORM'+tal+'= '+#39+'E       '+#39+'           / Format of field                                          ',80);
      thefile4.writebuffer(aline,80);inc(i);

      lab:=retrieve_memo3_string(k-1,0,'col'+inttostr(k)); {retrieve type from memo3}
      strplcopy(aline,'TTYPE'+tal+'= '+#39+lab+#39+' / Field label                                                                                                        ',80);
      thefile4.writebuffer(aline,80);inc(i);

      lab:=retrieve_memo3_string(k-1,1,'unit'+inttostr(k)); {retrieve unit from memo3}
      strplcopy(aline,'TUNIT'+tal+'= '+#39+lab+#39+' / Physical unit of field                                                                                             ',80);
      thefile4.writebuffer(aline,80);inc(i);
    end;

    strplcopy(  aline,'ORIGIN  = '    +#39+'ASTAP   '+#39+'           / Written by ASTAP                                         ',80);
    thefile4.writebuffer(aline,80);inc(i);
    strpcopy(aline,'END                                                                             ');
    thefile4.writebuffer(aline,80);inc(i);

    while  frac(i*80/2880)>0 do
    begin
      thefile4.writebuffer(empthy_line,80);{write empthy line}
      inc(i);
    end;

    {write datablock}
    i:=0;
    for r:=2 to mainwindow.memo3.lines.count-1 do {rows}
    begin
       for j:=0 to rows-1 do {columns}
       begin
         tal:=retrieve_memo3_string(j {x},r {y},'0'); {retrieve string value from memo3 at position k,m}
         fitsbuffer4[j]:=INT_IEEE4_reverse(strtofloat2(tal));{adapt intel floating point to non-intel floating. Add 1 to get FITS coordinates}
       end;
       thefile4.writebuffer(fitsbuffer[0],rows*4);{write one row}
       i:=i+rows*4; {byte counter}
    end;

    j:=80-round(80*frac(i/80));{remainder in bytes till written muliple of 80 char}
    thefile4.writebuffer(empthy_line,j);{write till multiply of 80}
    i:=(i + j*80) div 80 ;{how many 80 bytes record left till multiple of 2880}

    while  frac(i*80/2880)>0 do {write till 2880 block is written}
    begin
      thefile4.writebuffer(empthy_line,80);{write empthy line}
      inc(i);
    end;
  end;

  TheFile4.free;

  mainwindow.image1.stretch:=true;
  Screen.Cursor:= OldCursor;
  {$IFDEF fpc}
  progress_indicator(-100,'');{back to normal}
  {$else} {delphi}
  mainwindow.taskbar1.progressstate:=TTaskBarProgressState.None;
  {$endif}
  result:=true;
end;


function TextfileSize(const name: string): LongInt;
var
  SRec: TSearchRec;
begin
  if FindFirst(name, faAnyfile, SRec) = 0 then
  begin
    Result := SRec.Size;
    Sysutils.FindClose(SRec);
  end
  else
    Result := 0;
end;


procedure Tmainwindow.solve_button1Click(Sender: TObject);
begin
  astrometric_solve_image1Click(Sender);
end;


procedure Tmainwindow.Stackimages1Click(Sender: TObject);
begin
  stackmenu1.visible:=true;
  stackmenu1.setfocus;
end;


procedure Tmainwindow.Undo1Click(Sender: TObject);
begin
  restore_img;
end;


procedure Tmainwindow.Saveasfits1Click(Sender: TObject);
begin
  if pos('.fit',filename2)=0 then savedialog1.filename:=ChangeFileExt(FileName2,'.fits')
                             else savedialog1.filename:=FileName2;

  savedialog1.initialdir:=ExtractFilePath(filename2);
  savedialog1.Filter := 'IEEE Float (-32) FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS|16 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS|8 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS|8 bit FITS files (special, naxis1=3)(*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';
  if nrbits=16  then SaveDialog1.FilterIndex:=2
  else
  if nrbits=-32 then SaveDialog1.FilterIndex:=1
  else
  if nrbits=8 then SaveDialog1.FilterIndex:=3;

  if savedialog1.execute then
  begin
    if SaveDialog1.FilterIndex=1 then
    save_fits(img_loaded,savedialog1.filename,-32,false)
    else
    if SaveDialog1.FilterIndex=2 then
    save_fits(img_loaded,savedialog1.filename,16,false)
    else
    if SaveDialog1.FilterIndex=3 then
    begin
      if ((nrbits=8) or (IDYES= Application.MessageBox('8 bit will reduce image quality. Select yes to continue', 'Save as 8 bit FITS', MB_ICONQUESTION + MB_YESNO) )) then {ask queastion if nrbits is reduced}
        save_fits(img_loaded,savedialog1.filename,8,false);
    end
    else
    if SaveDialog1.FilterIndex=4 then {special naxis1=3}
    begin
      if ((nrbits=8) or (IDYES= Application.MessageBox('8 bit will reduce image quality. Select yes to continue', 'Save as 8 bit FITS', MB_ICONQUESTION + MB_YESNO) )) then {ask queastion if nrbits is reduced}
        save_fits(img_loaded,savedialog1.filename,24,false);
    end;

    add_recent_file(savedialog1.filename);{add to recent file list}
  end;
  mainwindow.SaveFITSwithupdatedheader1.Enabled:=true; {menu enable, header can be updated again}
end;


procedure Tmainwindow.LoadFITSPNGBMPJPEG1Click(Sender: TObject);
begin
  OpenDialog1.Title := 'Open in viewer';

  opendialog1.Filter :=  'All formats |*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP;*.tif;*.tiff;*.TIF;*.new;*.ppm;*.pgm;*.pbm;*.pfm;*.xisf;*.fz;'+
                                      '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                         '|8, 16, 32 and -32 bit FITS files (*.fit*,*.xisf)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.new;*.xisf;*.fz'+
                         '|24 bits PNG, TIFF, JPEG, BMP(*.png,*.tif*, *.jpg,*.bmp)|*.png;*.PNG;*.tif;*.tiff;*.TIF;*.jpg;*.JPG;*.bmp;*.BMP'+
                         '|Preview FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';
  opendialog1.filename:=filename2;
  opendialog1.initialdir:=ExtractFileDir(filename2);
  opendialog1.filterindex:=LoadFITSPNGBMPJPEG1filterindex;
  if opendialog1.execute then
  begin
     filename2:=opendialog1.filename;
     if opendialog1.FilterIndex<>4 then {<> preview FITS files, not yet loaded}
     {loadimage}
     //if
     load_image(true,true {plot});{load and center}
     //=false then beep;{image not found}
     LoadFITSPNGBMPJPEG1filterindex:=opendialog1.filterindex;{remember filterindex}
  end;
end;


procedure Tmainwindow.minimum1Change(Sender: TObject);
begin
  min2.text:=inttostr(minimum1.position);
  shape_histogram1.left:=1+(histogram1.left) + round(histogram1.width * minimum1.position/minimum1.max);
end;


procedure Tmainwindow.maximum1Change(Sender: TObject);
begin
  max2.text:=inttostr(maximum1.position);
  shape_histogram1.left:=1+histogram1.left+ round(histogram1.width * maximum1.position/maximum1.max);
end;


procedure Tmainwindow.maximum1Scroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  if fits_file then
  begin
    {$IfDef Darwin}// for OS X,
     if true then {temporary fix. scendscroll doesnt work. See bug report https://bugs.freepascal.org/view.php?id=37454}
     {$ELSE}
      if scrollcode=scEndScroll then
     {$ENDIF}
    begin
      plot_fits(mainwindow.image1,false,true);
      shape_histogram1.visible:=false;
    end
    else
      shape_histogram1.visible:=true;
  end;

  mainwindow.range1.itemindex:=7; {manual}
end;

{#######################################}
begin
  {$ifdef CPUARM}
  size_backup:= 0; {0, one backup images for ctrl-z}
  index_backup:=size_backup;
  {$else}
  size_backup:=2; {0,1,2 three backup images for ctrl-z}
  index_backup:=size_backup;
  {$endif}
end.
