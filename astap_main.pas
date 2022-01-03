unit astap_main;
{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.


{Notes on MacOS pkg making:
   1) Modify app in applications via "show contents", add updated files.
   2) Add the app in program packages
   3) Build package. Will produce PKG file containing the app.

   Compiler settings for macOS:
   targetOS: Darwin
   CPU family X86_64
   LCL widegetset: cocoa
}

{open compiler isssues:
MacOS
Listview smallimages are not displayed.
https://gitlab.com/freepascal.org/lazarus/lazarus/-/issues/39193

MacOS
ScrollCode=scEndScroll does not appears at the end of scroll
https://gitlab.com/freepascal.org/lazarus/lazarus/-/issues/37454

Mac
Listview event OnCustomDrawItem is never triggered/fired in Mac, widget Cocoa
https://gitlab.com/freepascal.org/lazarus/lazarus/-/issues/39500
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
  fpwriteTIFF,fpwritePNG,fpwriteBMP,fpwriteJPEG, fptiffcmn,  {images}
  GraphType, {fastbitmap}
  LCLVersion, SysUtils, Graphics, Forms, strutils, math,
  clipbrd, {for copy to clipboard}
  Buttons, PopupNotifier, simpleipc,
  CustApp, Types,
  iostream, {for using stdin for data}
  IniFiles;{for saving and loading settings}

type
  { Tmainwindow }
  Tmainwindow = class(TForm)
    add_marker_position1: TMenuItem;
    bin3x3: TMenuItem;
    BitBtn1: TBitBtn;
    error_label1: TLabel;
    FontDialog1: TFontDialog;
    image_north_arrow1: TImage;
    LabelThree1: TLabel;
    LabelVar1: TLabel;
    LabelCheck1: TLabel;
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
    extract_pixel_21: TMenuItem;
    extract_pixel_22: TMenuItem;
    batch_solve_astrometry_net: TMenuItem;
    copy_to_clipboard1: TMenuItem;
    grid1: TMenuItem;
    freetext1: TMenuItem;
    MenuItem21: TMenuItem;
    bin_2x2menu1: TMenuItem;
    bin_3x3menu1: TMenuItem;
    imageinspection1: TMenuItem;
    inspector1: TMenuItem;
    MenuItem22: TMenuItem;
    flip_v1: TMenuItem;
    flip_H1: TMenuItem;
    rotate_arbitrary1: TMenuItem;
    roundness1: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem30: TMenuItem;
    add_sip_check1: TMenuItem;
    add_limiting_magn_check1: TMenuItem;
    batch_overwrite1: TMenuItem;
    convert_to_ppm1: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    hfd_arcseconds1: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem34: TMenuItem;
    Constellations1: TMenuItem;
    aavso_chart1: TMenuItem;
    import_auid1: TMenuItem;
    N4: TMenuItem;
    MenuItem38: TMenuItem;
    simbad_query1: TMenuItem;
    positionanddate1: TMenuItem;
    removegreenpurple1: TMenuItem;
    Shape1: TShape;
    sip1: TMenuItem;
    zoomfactorone1: TMenuItem;
    extractred1: TMenuItem;
    extractblue1: TMenuItem;
    extractgreen1: TMenuItem;
    MenuItem24: TMenuItem;
    writepositionshort1: TMenuItem;
    Shape_alignment_marker2: TShape;
    Shape_alignment_marker3: TShape;
    shape_manual_alignment1: TShape;
    sqm1: TMenuItem;
    Rota_mainmenu1: TMenuItem;
    batch_rotate_left1: TMenuItem;
    batch_rotate_right1: TMenuItem;
    gradient_removal1: TMenuItem;
    histogram_values_to_clipboard1: TMenuItem;
    local_adjustments1: TMenuItem;
    angular_distance1: TMenuItem;
    j2000_1: TMenuItem;
    galactic1: TMenuItem;
    MenuItem23: TMenuItem;
    annotate_unknown_stars1: TMenuItem;
    gaia_star_position1: TMenuItem;
    j2000d1: TMenuItem;
    mountposition1: TMenuItem;
    northeast1: TMenuItem;
    selectfont1: TMenuItem;
    popupmenu_statusbar1: TPopupMenu;
    shape_marker4: TShape;
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
    rotate1: TMenuItem;
    shape_histogram1: TShape;
    shape_paste1: TShape;
    submenurotate1: TMenuItem;
    MenuItem19: TMenuItem;
    shape_marker2: TShape;
    shape_marker3: TShape;
    solvebytwopositions1: TMenuItem;
    enterposition1: TMenuItem;
    save_settings_as1: TMenuItem;
    settings_menu1: TMenuItem;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    UpDown1: TUpDown;
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
    GroupBox1: TGroupBox;
    save1: TButton;
    solve_button1: TButton;
    batch_add_solution1: TMenuItem;

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
    Copypositionindeg1: TMenuItem;
    writeposition1: TMenuItem;
    N7: TMenuItem;
    Enter_annotation1: TMenuItem;
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
    procedure calibrate_photometry1Click(Sender: TObject);
    procedure Constellations1Click(Sender: TObject);
    procedure convert_to_ppm1Click(Sender: TObject);
    procedure flip_H1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure freetext1Click(Sender: TObject);
    procedure hfd_arcseconds1Click(Sender: TObject);
    procedure compress_fpack1Click(Sender: TObject);
    procedure copy_to_clipboard1Click(Sender: TObject);
    procedure extract_pixel_11Click(Sender: TObject);
    procedure extract_pixel_12Click(Sender: TObject);
    procedure extract_pixel_22Click(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure histogram_range1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure histogram_values_to_clipboard1Click(Sender: TObject);
    procedure Image1Paint(Sender: TObject);
    procedure imageflipv1Click(Sender: TObject);
    procedure annotate_unknown_stars1Click(Sender: TObject);
    procedure import_auid1Click(Sender: TObject);
    procedure inspector1Click(Sender: TObject);
    procedure j2000d1Click(Sender: TObject);
    procedure measuretotalmagnitude1Click(Sender: TObject);
    procedure loadsettings1Click(Sender: TObject);
    procedure localbackgroundequalise1Click(Sender: TObject);
    procedure menucopy1Click(Sender: TObject);
    procedure Menufind1Click(Sender: TObject);
    procedure menufindnext1Click(Sender: TObject);
    procedure copy_paste_tool1Click(Sender: TObject);
    procedure extract_pixel_21Click(Sender: TObject);
    procedure batch_rotate_left1Click(Sender: TObject);
    procedure angular_distance1Click(Sender: TObject);
    procedure j2000_1Click(Sender: TObject);
    procedure galactic1Click(Sender: TObject);
    procedure gaia_star_position1Click(Sender: TObject);
    procedure extractred1Click(Sender: TObject);
    procedure extractblue1Click(Sender: TObject);
    procedure extractgreen1Click(Sender: TObject);
    procedure grid1Click(Sender: TObject);
    procedure bin_2x2menu1Click(Sender: TObject);
    procedure convert_to_png1Click(Sender: TObject);
    procedure MenuItem22Click(Sender: TObject);
    procedure positionanddate1Click(Sender: TObject);
    procedure inspection1click(Sender: TObject);
    procedure removegreenpurple1Click(Sender: TObject);
    procedure roundness1Click(Sender: TObject);
    procedure sip1Click(Sender: TObject);
    procedure split_osc1Click(Sender: TObject);
    procedure sqm1Click(Sender: TObject);
    procedure mountposition1Click(Sender: TObject);
    procedure northeast1Click(Sender: TObject);
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
    procedure clean_up1Click(Sender: TObject);
    procedure remove_colour1Click(Sender: TObject);
    procedure Returntodefaultsettings1Click(Sender: TObject);
    procedure rotateleft1Click(Sender: TObject);
    procedure saturation_factor_plot1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure saturation_factor_plot1MouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure savesettings1Click(Sender: TObject);
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
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure variable_star_annotation1Click(Sender: TObject);
    procedure zoomfactorone1Click(Sender: TObject);
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
    procedure batch_add_solution1Click(Sender: TObject);
    procedure flip_horizontal1Click(Sender: TObject);
    procedure flip_vertical1Click(Sender: TObject);
    procedure demosaic_bayermatrix1Click(Sender: TObject);
    procedure star_annotation1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure stretch_draw1Click(Sender: TObject);
    procedure Copyposition1Click(Sender: TObject);
    procedure Copypositionindeg1Click(Sender: TObject);
    procedure writeposition1Click(Sender: TObject);
    procedure Enter_annotation1Click(Sender: TObject);
    procedure Stackimages1Click(Sender: TObject);
    procedure Saveasfits1Click(Sender: TObject);
    procedure Export_image1Click(Sender: TObject);
    procedure CropFITSimage1Click(Sender: TObject);
    procedure maximum1Scroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure stretch1Change(Sender: TObject);
    procedure histogram1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure maximum1Change(Sender: TObject);
    procedure minimum1Change(Sender: TObject);
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

  Theader =record    {contains the most important header info}
    height : integer;{image height}
    width  : integer;
    naxis  : integer;{number of dimensions}
    naxis3 : integer;{number of colors}
    crpix1 : double; {reference point X}
    crpix2 : double;
    cdelt1 : double; {X pixel size (deg)}
    cdelt2 : double; {Y pixel size (deg)}
    ra0    : double; {mount position}
    dec0   : double;
    crota1 : double; {image rotation at center in degrees}
    crota2 : double; {image rotation at center in degrees}
    cd1_1  : double; {solution matrix}
    cd1_2  : double;
    cd2_1  : double;
    cd2_2         : double;
    exposure      : double;
    datamin_org   : double;
    datamax_org   : double;{for update histogram}
    set_temperature : integer;
    dark_count      : integer;
    light_count     : integer;
    flat_count      : integer;
    flatdark_count  : integer;

    egain      : string; {gain in e-/adu}
     gain      : string; {gain in 0.1dB or else}
    date_obs   : string;
    calstat    : string;
    filter_name: string;
  end;

type
   timgbackup  = record
     head_val: Theader;{most important header values}
     header  : string; {full header text}
     filen   : string; {filename}
     xbinning: double; {for binning routine. If twice binned or SQM routine}
     ybinning: double;
     XPIXSZ  : double;
     YPIXSZ  : double;
     img     : image_array;
   end;


var
  img_backup      : array of timgbackup;{dynamic so memory can be freed}
  img_loaded,img_temp,img_dark,img_flat,img_bias,img_average,img_variance,img_buffer,img_final : image_array;
  head,    {for lights}
  head_2,  {for analysing lights and dark, flats}
  head_ref {for reference light in stacking}
    : Theader;{contains the most important header info}

  settingstring :tstrings; {settings for save and loading}
  user_path    : string;{c:\users\name\appdata\local\astap   or ~/home/.config/astap}
  distortion_data : star_list;
  filename2: string;
  nrbits,size_backup,index_backup    : integer;{number of backup images for ctrl-z, numbered 0,1,2,3}
  ra_mount,dec_mount,{telescope ra,dec}
  Xbinning,Ybinning,
  ra_radians,dec_radians, pixel_size     : double;

var
  a_order,ap_order: integer;{Simple Imaging Polynomial use by astrometry.net, if 2 then available}
  a_0_0,   a_0_1, a_0_2,  a_0_3,  a_1_0,  a_1_1,  a_1_2,  a_2_0,  a_2_1,  a_3_0 : double; {SIP, Simple Imaging Polynomial use by astrometry.net, Spitzer}
  b_0_0,   b_0_1, b_0_2,  b_0_3,  b_1_0,  b_1_1,  b_1_2,  b_2_0,  b_2_1,  b_3_0 : double; {SIP, Simple Imaging Polynomial use by astrometry.net, Spitzer}
  ap_0_0, ap_0_1,ap_0_2, ap_0_3, ap_1_0, ap_1_1, ap_1_2, ap_2_0, ap_2_1, ap_3_0 : double;{SIP, Simple Imaging Polynomial use by astrometry.net}
  bp_0_0, bp_0_1,bp_0_2, bp_0_3, bp_1_0, bp_1_1, bp_1_2, bp_2_0, bp_2_1, bp_3_0 : double;{SIP, Simple Imaging Polynomial use by astrometry.net}

  histogram : array[0..2,0..65535] of integer;{red,green,blue,count}
  his_total_red, his_total_green,his_total_blue,extend_type,r_aperture : integer; {histogram number of values}
  his_mean,noise_level : array[0..2] of integer;
  stretch_c : array[0..32768] of single;{stretch curve}
  stretch_on, esc_pressed, fov_specified,unsaved_import, last_extension : boolean;
  star_level,star_bg,sd_bg, magn_limit  : double;
  object_name,
  imagetype ,sitelat, sitelong,centalt,centaz: string;
  focus_temp,cblack,cwhite,sqmfloat   :double; {from FITS}
  subsamp, focus_pos  : integer;{not always available. For normal DSS =1}
  date_avg,ut,pltlabel,plateid,telescop,instrum,origin,sqm_value   : string;

  old_crpix1,old_crpix2,old_crota1,old_crota2,old_cdelt1,old_cdelt2,old_cd1_1,old_cd1_2,old_cd2_1,old_cd2_2 : double;{for backup}

  warning_str,{for solver}
  roworder                  :string;
  copy_paste_x,
  copy_paste_y,
  copy_paste_w,
  copy_paste_h : integer;

  position_find: Integer; {for fits header memo1 popup menu}

  var {################# initialised variables #########################}
  PatternToFind : string=''; {for fits header memo1 popup menu }
  hist_range  {range histogram 255 or 65535 or streched} : integer=255;
  fits_file: boolean=false;
  image_move_to_center : boolean=false;
  xpixsz: double=0;//Pixel Width in microns (after binning)
  ypixsz: double=0;//Pixel height in microns (after binning)
  focallen: double=0;
  lat_default: string='';
  long_default: string='';
  down_x: integer=0;
  down_y: integer=0;
  down_xy_valid: boolean=false;{required for Linux GTK.}
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
  bayerpattern_final :integer=2; {ASI294, ASI071, most common pattern}
  sip                : boolean=false; {use SIP coefficients}

  xbayroff: double=0;{additional bayer pattern offset to apply}
  Ybayroff: double=0;{additional bayer pattern offset to apply}
  annotated : boolean=false;{any annotation in fits file?}
  sqm_key   :  ansistring='SQM     ';
  centaz_key   :  ansistring='CENTAZ  ';

  hfd_median : double=0;{median hfd, use in reporting in write_ini}
  hfd_counter: integer=0;{star counter (for hfd_median), use in reporting in write_ini}
  aperture_ratio: double=0; {ratio flux_aperture/hfd_median}
  flux_aperture : double=99;{circle where flux is measured}
  annulus_radius  : integer=14;{inner of square where background is measured. Square has width and height twice annulus_radius}
  copy_paste :boolean=false;
  shape_fitsX: double=0;
  shape_fitsY: double=0;
  shape_fitsX2: double=0;
  shape_fitsY2: double=0;
  shape_fitsX3: double=0;
  shape_fitsY3: double=0;
  shape_nr: integer=1;

  shape_marker1_fitsX: double=10;
  shape_marker1_fitsY: double=10;
  shape_marker2_fitsX: double=20;
  shape_marker2_fitsY: double=20;
  shape_marker3_fitsX: double=0;
  shape_marker3_fitsY: double=0;
  shape_marker4_fitsX: double=0;
  shape_marker4_fitsY: double=0;


  commandline_execution : boolean=false;{program executed in command line}
  commandline_log       : boolean=false;{file log request in command line}
  stdin_mode            : boolean=false;{file send via stdin}
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
  pedestal            : integer=0;


procedure ang_sep(ra1,dec1,ra2,dec2 : double;out sep: double);
function load_fits(filen:string;light {load as light or dark/flat},load_data,update_memo: boolean;get_ext: integer;out head: Theader; out img_loaded2: image_array): boolean;{load fits file}
procedure plot_fits(img: timage;center_image,show_header:boolean);
procedure use_histogram(img: image_array; update_hist: boolean);{get histogram}
procedure HFD(img: image_array;x1,y1,rs {boxsize}: integer;aperture_small:double; out hfd1,star_fwhm,snr{peak/sigma noise}, flux,xc,yc:double);{calculate star HFD and FWHM, SNR, xc and yc are center of gravity, rs is the boxsize, aperture for the flux measurment. All x,y coordinates in array[0..] positions}
procedure backup_img;
procedure restore_img;
function load_image(re_center, plot:boolean) : boolean; {load fits or PNG, BMP, TIF}
procedure demosaic_bayer(var img: image_array); {convert OSC image to colour}

Function INT_IEEE4_reverse(x: double):longword;{adapt intel floating point to non-intel float}
function save_fits(img: image_array;filen2:ansistring;type1:integer;override2:boolean): boolean;{save to 8, 16 OR -32 BIT fits file}
procedure update_text(inpt,comment1:string);{update or insert text in header}
procedure add_text(inpt,comment1:string);{add text to header memo}
procedure update_longstr(inpt,thestr:string);{update or insert long str including single quotes}
procedure add_long_comment(descrip:string);{add long text to header memo. Split description over several lines if required}
procedure update_generic(message_key,message_value,message_comment:string);{update header using text only}
procedure update_integer(inpt,comment1:string;x:integer);{update or insert variable in header}
procedure add_integer(inpt,comment1:string;x:integer);{add integer variable to header}
procedure update_float(inpt,comment1:string;x:double);{update keyword of fits header in memo}
procedure remove_key(inpt:string; all:boolean);{remove key word in header. If all=true then remove multiple of the same keyword}

function strtofloat1(s:string): double;{string to float, error tolerant}
function strtofloat2(s:string): double;{works with either dot or komma as decimal separator}
function TextfileSize(const name: string): LongInt;
function floattostr6(x:double):string;
function floattostr4(x:double):string;
procedure update_menu(fits :boolean);{update menu if fits file is available in array or working from image1 canvas}
procedure get_hist(colour:integer;img :image_array);{get histogram of img_loaded}
procedure save_settings2;
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
function prepare_ra6(rax:double; sep:string):string; {radialen to text  format 24h 00 00}
function prepare_dec4(decx:double;sep:string):string; {radialen to text  format 90d 00 }
function prepare_dec(decx:double; sep:string):string; {radialen to text, format 90d 00 00}
function prepare_ra(rax:double; sep:string):string; {radialen to text, format 24: 00 00.0 }
function prepare_ra8(rax:double; sep:string):string; {radialen to text, format 24: 00 00.00 }
Function prepare_dec2(decx:double; sep:string):string; {radialen to text, format 90d 00 00.1}
function inttostr5(x:integer):string;{always 5 digit}
function SMedian(list: array of double; leng: integer): double;{get median of an array of double. Taken from CCDciel code but slightly modified}
procedure mad_median(list: array of double; leng :integer;out mad,median :double);{calculate mad and median without modifying the data}
procedure DeleteFiles(lpath,FileSpec: string);{delete files such  *.wcs}
procedure new_to_old_WCS;{convert new style FITsS to old style}
procedure old_to_new_WCS;{ convert old WCS to new}
procedure show_marker_shape(shape: TShape; shape_type,w,h,minimum:integer; fitsX,fitsY: double);{show manual alignment shape}
function check_raw_file_extension(ext: string): boolean;{check if extension is from raw file}
function convert_raw(loadfile,savefile :boolean;var filename3: string; var img: image_array): boolean; {convert raw to fits file using DCRAW or LibRaw}

function unpack_cfitsio(filename3: string): boolean; {convert .fz to .fits using funpack}
function pack_cfitsio(filename3: string): boolean; {convert .fz to .fits using funpack}

function load_TIFFPNGJPEG(filen:string; var head :theader; var img_loaded2: image_array) : boolean;{load 8 or 16 bit TIFF, PNG, JPEG, BMP image}
procedure get_background(colour: integer; img :image_array;calc_hist, calc_noise_level: boolean; out background, starlevel: double); {get background and star level from peek histogram}

function extract_exposure_from_filename(filename8: string):integer; {try to extract exposure from filename}
function extract_temperature_from_filename(filename8: string): integer; {try to extract temperature from filename}
function extract_objectname_from_filename(filename8: string): string; {try to extract exposure from filename}

function test_star_spectrum(r,g,b: single) : single;{test star spectrum. Result of zero is perfect star spectrum}
procedure measure_magnitudes(annulus_rad:integer; deep: boolean; var stars :star_list);{find stars and return, x,y, hfd, flux}
function binX2X3_file(binfactor:integer) : boolean; {converts filename2 to binx2,binx3, binx4 version}
procedure ra_text_to_radians(inp :string; out ra : double; out errorRA :boolean); {convert ra in text to double in radians}
procedure dec_text_to_radians(inp :string; out dec : double; out errorDEC :boolean); {convert ra in text to double in radians}
function image_file_name(inp : string): boolean; {readable image name?}
procedure plot_annotations(use_solution_vectors,fill_combo: boolean); {plot annotations stored in fits header. Offsets are for blink routine}

procedure RGB2HSV(r,g,b : single; out h {0..360}, s {0..1}, v {0..1}: single);{RGB to HSVB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
procedure HSV2RGB(h {0..360}, s {0..1}, v {0..1} : single; out r,g,b: single); {HSV to RGB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
function get_demosaic_pattern : integer; {get the required de-bayer range 0..3}
Function LeadingZero(w : integer) : String;
procedure log_to_file(logf,mess : string);{for testing}
procedure log_to_file2(logf,mess : string);{used for platesolve2 and photometry}
procedure demosaic_advanced(var img : image_array);{demosaic img_loaded}
procedure bin_X2X3X4(binfactor:integer);{bin img_loaded 2x or 3x or 4x}
procedure local_sd(x1,y1, x2,y2{regio of interest},col : integer; img : image_array; out sd,mean :double; out iterations :integer);{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}
function extract_raw_colour_to_file(filename7,filtern: string; xp,yp : integer) : string;{extract raw colours and write to file}
function fits_file_name(inp : string): boolean; {fits file name?}
function prepare_IAU_designation(rax,decx :double):string;{radialen to text hhmmss.s+ddmmss  format}
procedure sensor_coordinates_to_celestial(fitsx,fitsy : double; out  ram,decm  : double {fitsX, Y to ra,dec});
procedure celestial_to_pixel(ra_t,dec_t: double; out fitsX,fitsY: double);{ra,dec to fitsX,fitsY}
procedure show_shape_manual_alignment(index: integer);{show the marker on the reference star}
procedure write_astronomy_wcs(filen:string);
function savefits_update_header(filen2:string) : boolean;{save fits file with updated header}
procedure plot_the_annotation(x1,y1,x2,y2:integer; typ:double; name,magn :string);{plot annotation from header in ASTAP format}
procedure reset_fits_global_variables(light :boolean; out head:theader ); {reset the global variable}
function convert_to_fits(var filen: string): boolean; {convert to fits}
procedure QuickSort(var A: array of double; iLo, iHi: Integer) ;{ Fast quick sort. Sorts elements in the array list with indices between lo and hi}
procedure convert_mono(var img: image_array);
procedure Wait(wt:single=500);  {smart sleep}
procedure update_header_for_colour; {update naxis and naxis3 keywords}


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
     {9}('BZERO   =                  0.0 / physical_value = BZERO + BSCALE * array_value  '),
    {10}('BSCALE  =                  1.0 / physical_value = BZERO + BSCALE * array_value  '),
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


    pi_=pi; {for evaluate in debugging}

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

uses unit_dss, unit_stack, unit_tiff,unit_star_align, unit_astrometric_solving, unit_star_database, unit_annotation, unit_thumbnail, unit_xisf,unit_gaussian_blur,unit_inspector_plot,unit_asteroid,
     unit_astrometry_net, unit_live_stacking, unit_hjd,unit_hyperbola, unit_aavso, unit_listbox, unit_sqm, unit_stars_wide_field,unit_constellations,unit_raster_rotate;

{$R astap_cursor.res}   {FOR CURSORS}

{$IFDEF fpc}
  {$R *.lfm}
{$else}  {delphi}
 {$R *.dfm}
{$endif}

var
  recent_files : tstringlist;
  stop_RX, stop_RY, start_RX,start_RY :integer; {for rubber rectangle. These values are the same startX,.... except if image is flipped}
  object_xc,object_yc, object_raM,object_decM  : double; {near mouse auto centered object position}

var {################# initialised variables #########################}
  bandpass: double=0;{from fits file}
  equinox:double=0;{from fits file}
  SaveasTIFF1filterindex : integer=1;
  SaveasJPGPNGBMP1filterindex : integer=4;
  LoadFITSPNGBMPJPEG1filterindex: integer=1;
  marker_position : string='';
  mouse_fitsx : double=0;
  mouse_fitsy : double=0;
  coord_frame : integer=0; {J2000=0 or galactic=1}
  hfd_arcseconds: boolean=false; {HFD in arc seconds or pixels}

  {$IFDEF Darwin}
  font_name: string= 'Courier';
  font_size : integer = 9;
  {$else}
  {$IFDEF linux}
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
  freetext : string='';

const
  crMyCursor = 5;

procedure reset_fits_global_variables(light :boolean;out head:theader); {reset the global variable}
begin
  if light then
  begin
    head.crota2:=99999;{just for the case it is not available, make it later zero}
    head.crota1:=99999;
    head.ra0:=0;
    head.dec0:=0;
    ra_mount:=99999;
    dec_mount:=99999;
    head.cdelt1:=0;
    head.cdelt2:=0;
    xpixsz:=0;
    ypixsz:=0;
    focallen:=0;
    subsamp:=1;{just for the case it is not available}
    head.cd1_1:=0;{just for the case it is not available}
    head.cd1_2:=0;{just for the case it is not available}
    head.cd2_1:=0;{just for the case it is not available}
    head.cd2_2:=0;{just for the case it is not available}
    bayerpat:='';{reset bayer pattern}
    xbayroff:=0;{offset to used to correct BAYERPAT due to flipping}
    ybayroff:=0;{offset to used to correct BAYERPAT due to flipping}
    roworder:='';{'BOTTOM-UP'= lower-left corner first in the file.  or 'TOP-DOWN'= top-left corner first in the file.}

    a_order:=0;{Simple Imaging Polynomial use by astrometry.net, if 2 then available}
    ap_order:=0;{Simple Imaging Polynomial use by astrometry.net, if 2 then available}
    a_0_0:=0; a_0_1:=0; a_0_2:=0; a_0_3:=0; a_1_0:=0; a_1_1:=0; a_1_2:=0;a_2_0:=0; a_2_1:=0; a_3_0:=0;
    b_0_0:=0; b_0_1:=0; b_0_2:=0; b_0_3:=0; b_1_0:=0; b_1_1:=0; b_1_2:=0;b_2_0:=0; b_2_1:=0; b_3_0:=0;
    ap_0_0:=0; ap_0_1:=0; ap_0_2:=0; ap_0_3:=0; ap_1_0:=0; ap_1_1:=0; ap_1_2:=0; ap_2_0:=0; ap_2_1:=0; ap_3_0:=0;
    bp_0_0:=0; bp_0_1:=0; bp_0_2:=0; bp_0_3:=0; bp_1_0:=0; bp_1_1:=0; bp_1_2:=0; bp_2_0:=0; bp_2_1:=0; bp_3_0:=0;

    centalt:='';{assume no data available}
    centaz:='';{assume no data available}
    x_coeff[0]:=0; {reset DSS_polynomial, use for check if there is data}
    y_coeff[0]:=0;
    a_order:=0; {SIP_polynomial, use for check if there is data}
    ap_order:=0; {SIP_polynomial, use for check if there is data}

    xbinning:=1;{normal}
    ybinning:=1;

    date_avg:='';ut:=''; pltlabel:=''; plateid:=''; telescop:=''; instrum:='';  origin:=''; object_name:='';{clear}
    sitelat:=''; sitelong:='';

    focus_temp:=999;{assume no data available}
    focus_pos:=0;{assume no data available}

    annotated:=false; {any annotation in the file}

    flux_magn_offset:=0;{factor to calculate magnitude from flux, new file so set to zero}
    sqm_value:='';
  end;

  head.date_obs:='';
  head.calstat:='';{indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected, S stacked. Example value DFB}
  head.filter_name:='';
  head.naxis:=-1;{assume failure}
  head.naxis3:=1;
  head.datamin_org:=0;
  imagetype:='';
  head.exposure:=0;
  head.set_temperature:=999;
  head.gain:='';
  head.egain:='';{assume no data available}
end;{reset global variables}


function load_fits(filen:string;light {load as light or dark/flat},load_data,update_memo: boolean;get_ext: integer;out head: Theader; out img_loaded2: image_array): boolean;{load fits file}
{if light=true then read also head.ra0, head.dec0 ....., else load as dark, flat}
{if load_data then read all else header only}
{if reset_var=true, reset variables to zero}
var
  header    : array[0..2880] of ansichar;
  i,j,k,nr,error3,naxis1, reader_position,n,file_size  : integer;
  dummy,scale,ccd_temperature, jd2                     : double;
  col_float,bscale,measured_max,scalefactor  : single;
  s                  : string[3];
  bzero              : integer;{zero shift. For example used in AMT, Tricky do not use int64,  maxim DL writes BZERO value -2147483647 as +2147483648 !! }
  aline,number,field : ansistring;
  rgbdummy           : byteX3;

  word16             : word;   {for 16 signed integer}
  int_16             : smallint absolute word16;{for 16 signed integer}

  x_longword  : longword;
  x_single    : single absolute x_longword;{for conversion 32 bit "big-endian" data}
  int_32      : integer absolute x_longword;{for 32 bit signed integer}

  x_qword     : qword;
  x_double    : double absolute x_qword;{for conversion 64 bit "big-endian" data}
  int_64      : int64 absolute x_qword;{for 64 bit signed integer}

  tfields,tform_counter,header_count,pointer,let  : integer;
  ttype,tform,tunit : array of string;
  tbcol,tform_nr    : array of integer;
  simple,image,bintable,asciitable    : boolean;
  abyte                               : byte;

var {################# initialised variables #########################}
  end_record : boolean=false;

     procedure close_fits_file; inline;
     begin
        Reader.free;
        TheFile3.free;
     end;

     Function validate_double:double;{read floating point or integer values}
     var t : string[20];
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
       r:=I+11;{start reading at position pos12, single quotes should for fix format should be at position 11 according FITS standard 4.0, chapter 4.2.1.1}
       while ((header[r-1]<>#39) and (r<I+77)) do inc(r); {find first quote at pos 11 or later for case it is not at position 11 (free-format strings)}
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
  fits_file:=false; {assume failure}

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
  file_size:=thefile3.size;

  if update_memo then
  begin
    mainwindow.memo1.visible:=false;{stop visualising memo1 for speed. Will be activated in plot routine}
    mainwindow.memo1.clear;{clear memo for new header}
  end;

  Reader := TReader.Create (theFile3,500*2880);{number of records. Buffer but not speed difference between 6*2880 and 1000*2880}
  {thefile3.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}

  {Reset GLOBAL variables for case they are not specified in the file}
  reset_fits_global_variables(light,head);

  if get_ext=0 then extend_type:=0; {always an image in main data block}
  scale:=0; {SGP files}
  naxis1:=0;
  bzero:=0;{just for the case it is not available. 0.0 is the default according https://heasarc.gsfc.nasa.gov/docs/fcg/standard_dict.html}
  bscale:=1;
  ccd_temperature:=999;
  measured_max:=0;

  header_count:=0;
  bintable:=false;
  asciitable:=false;

  reader_position:=0;
  repeat {header, 2880 bytes loop}

  I:=0;
    repeat {loop for reaching image/table}
      try
        reader.read(header[I],2880);{read file header, 2880 bytes}
        inc(reader_position,2880);
        if ((reader_position=2880) and (header[0]='S') and (header[1]='I')  and (header[2]='M') and (header[3]='P') and (header[4]='L') and (header[5]='E') and (header[6]=' ')) then
        begin
          simple:=true;
          image:=true;
        end;
        if simple=false then
        begin
          close_fits_file;
          beep;
          mainwindow.statusbar1.panels[7].text:=('Error loading FITS file!! Keyword SIMPLE not found.');
          mainwindow.error_label1.caption:=('Error loading FITS file!! Keyword SIMPLE not found.');
          mainwindow.error_label1.visible:=true;
          exit;
        end; {should start with SIMPLE  =,  MaximDL compressed files start with SIMPLE‚=”}
        if ((header_count<get_ext) and (header[0]='X') and (header[1]='T')  and (header[2]='E') and (header[3]='N') and (header[4]='S') and (header[5]='I') and (header[6]='O') and (header[7]='N') and (header[8]='=')) then
        begin
           header_count:=header_count+1;
           image:=   ((header[11]='I') and (header[12]='M')  and (header[13]='A') and (header[14]='G') and (header[15]='E') and (header[16]=' '));
           bintable:=((header[11]='B') and (header[12]='I')  and (header[13]='N') and (header[14]='T') and (header[15]='A') and (header[16]='B')); {BINTABLE}
           asciitable:=((header[11]='T') and (header[12]='A')  and (header[13]='B') and (header[14]='L') and (header[15]='E') and (header[16]=' ')) ;{ascii_table identifier}
          begin
            if pos('BINTABLE',get_string)>0 then extend_type:=3 { 'BINTABLE' or 'TABLE'}
            else
            if pos('TABLE ',get_string)>0 then extend_type:=2 {ascii_table identifier}
            else
            begin
              extend_type:=1; {image in the extension}
              mainwindow.Memo3.lines.text:='File contains image(s) in the extension. Can be extracted and saved as a single image.';
              mainwindow.pagecontrol1.showtabs:=true;{show tabs}
            end;
          end;
        end;
      except;
        close_fits_file;
        beep;
        mainwindow.statusbar1.panels[7].text:='Read exception error!!';
        mainwindow.error_label1.caption:='Read exception error!!';
        mainwindow.error_label1.visible:=true;
        exit;
      end;
    until ((simple) and (header_count>=get_ext)); {simple is true and correct header found}

    repeat  {loop for 80 bytes in 2880 block}
      if load_data then
      begin
        SetString(aline, Pansichar(@header[i]), 80);{convert header line to string}
        if update_memo then mainwindow.memo1.lines.add(aline); {add line to memo}
      end;
      if ((header[i]='N') and (header[i+1]='A')  and (header[i+2]='X') and (header[i+3]='I') and (header[i+4]='S')) then {head.naxis}
      begin
        if (header[i+5]=' ') then head.naxis:=round(validate_double)
        else    {head.naxis number of colors}
        if (header[i+5]='1') then begin naxis1:=round(validate_double);head.width:=naxis1; end else {NAXIS1 pixels}
        if (header[i+5]='2') then head.height:=round(validate_double) else   {NAXIS2 pixels}
        if (header[i+5]='3') then
        begin
           head.naxis3:=round(validate_double); {head.naxis3 number of colors}
           if ((head.naxis=3) and (naxis1=3)) {naxis1} then  {type head.naxis = 3 / Number of dimensions
                                     NAXIS1 = 3 / Number of Colors
                                     NAXIS2 = 382 / Row length
                                     head.naxis3 = 255 / Number of rows}
                      begin   {RGB fits with naxis1=3, treated as 24 bits coded pixels in 2 dimensions}
                        head.width:=head.height;
                        head.height:=head.naxis3;
                        head.naxis3:=1;
                      end;
         end;
      end;


      if image then {image specific header}
      begin {read image header}
        if ((header[i]='B') and (header[i+1]='I')  and (header[i+2]='T') and (header[i+3]='P') and (header[i+4]='I') and (header[i+5]='X')) then
          nrbits:=round(validate_double);{BITPIX, read integer using double routine}

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
              head.exposure:=validate_double;{read double value}
        if ((header[i]='E') and (header[i+1]='X')  and (header[i+2]='P') and (header[i+3]='T') and (header[i+4]='I') and (header[i+5]='M') and (header[i+6]='E') and (header[i+7]=' ')) then {exptime and not exptimer}
              head.exposure:=validate_double;{read double value}

        if ((header[i]='C') and (header[i+1]='C')  and (header[i+2]='D') and (header[i+3]='-') and (header[i+4]='T') and (header[i+5]='E') and (header[i+6]='M')) then
             ccd_temperature:=validate_double;{read double value}
        if ((header[i]='S') and (header[i+1]='E')  and (header[i+2]='T') and (header[i+3]='-') and (header[i+4]='T') and (header[i+5]='E') and (header[i+6]='M')) then
               try head.set_temperature:=round(validate_double);{read double value} except; end; {some programs give huge values}


        if ((header[i]='I') and (header[i+1]='M')  and (header[i+2]='A') and (header[i+3]='G') and (header[i+4]='E') and (header[i+5]='T') and (header[i+6]='Y')) then
           imagetype:=StringReplace(get_string,' ','',[rfReplaceAll]);{remove all spaces}

        if ((header[i]='F') and (header[i+1]='I')  and (header[i+2]='L') and (header[i+3]='T') and (header[i+4]='E') and (header[i+5]='R') and (header[i+6]=' ')) then
           head.filter_name:=StringReplace(get_string,' ','',[rfReplaceAll]);{remove all spaces}

        if ((header[i]='X') and (header[i+1]='B')  and (header[i+2]='I') and (header[i+3]='N') and (header[i+4]='N') and (header[i+5]='I')) then
                 xbinning:=validate_double;{binning}
        if ((header[i]='Y') and (header[i+1]='B')  and (header[i+2]='I') and (header[i+3]='N') and (header[i+4]='N') and (header[i+5]='I')) then
                 ybinning:=validate_double;{binning}

        if ((header[i]='G') and (header[i+1]='A')  and (header[i+2]='I') and (header[i+3]='N') and (header[i+4]=' ')) then
             head.gain:=trim(get_as_string); {head.gain CCD}
        if ((header[i]='I') and (header[i+1]='S')  and (header[i+2]='O') and (header[i+3]='S') and (header[i+4]='P')) then
             if head.gain='' then head.gain:=trim(get_as_string);{isospeed, do not override head.gain}
        if ((header[i]='E') and (header[i+1]='G')  and (header[i+2]='A') and (header[i+3]='I') and (header[i+4]='N')) then  {egain}
             head.egain:=trim(get_as_string);{e-/adu gain}


        {following variable are not set at zero Set at zero somewhere in the code}
        if ((header[i]='L') and (header[i+1]='I')  and (header[i+2]='G') and (header[i+3]='H') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then
             head.light_count:=round(validate_double);{read integer as double value}
        if ((header[i]='D') and (header[i+1]='A')  and (header[i+2]='R') and (header[i+3]='K') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then
             head.dark_count:=round(validate_double);{read integer as double value}
        if ((header[i]='F') and (header[i+1]='L')  and (header[i+2]='A') and (header[i+3]='T') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then
             head.flat_count:=round(validate_double);{read integer as double value}
        if ((header[i]='B') and (header[i+1]='I')  and (header[i+2]='A') and (header[i+3]='S') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then
             head.flatdark_count:=round(validate_double);{read integer as double value}

        if ((header[i]='T') and (header[i+1]='I')  and (header[i+2]='M') and (header[i+3]='E') and (header[i+4]='-') and (header[i+5]='O') and (header[i+6]='B')) then
                if head.date_obs='' then head.date_obs:=get_string;

        if ((header[i]='J') and (header[i+1]='D')  and (header[i+2]=' ') and (header[i+3]=' ') and (header[i+4]=' ')) then
        if head.date_obs='' then {DATE-OBS overrules any JD value}
        begin
          jd2:=validate_double;
          head.date_obs:=JdToDate(jd2);
        end;

        if ((header[i]='D') and (header[i+1]='A')  and (header[i+2]='T') and (header[i+3]='E') and (header[i+4]='-') and (header[i+5]='O') and (header[i+6]='B')) then
                head.date_obs:=get_string;


        if ((header[i]='D') and (header[i+1]='A')  and (header[i+2]='T') and (header[i+3]='E') and (header[i+4]='-') and (header[i+5]='A') and (header[i+6]='V')) then
                date_avg:=get_string;


        if ((header[i]='C') and (header[i+1]='A')  and (header[i+2]='L') and (header[i+3]='S') and (header[i+4]='T') and (header[i+5]='A')) then  {head.calstat is also for flats}
            head.calstat:=get_string;{indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected. M could indicate master}


        if light then {read as light ##############################################################################################################################################################}
        begin
          if ((header[i]='E') and (header[i+1]='Q')  and (header[i+2]='U') and (header[i+3]='I') and (header[i+4]='N') and (header[i+5]='O') and (header[i+6]='X')) then
               equinox:=validate_double;

          if ((header[i]='C') and (header[i+1]='R')  and (header[i+2]='O') and (header[i+3]='T') and (header[i+4]='A')) then  {head.crota2}
          begin
             if (header[i+5]='2') then  head.crota2:=validate_double else {read double value}
             if (header[i+5]='1') then  head.crota1:=validate_double;{read double value}
          end;
          if ((header[i]='C') and (header[i+1]='R')  and (header[i+2]='P') and (header[i+3]='I') and (header[i+4]='X')) then {head.crpix1}
          begin
            if header[i+5]='1' then head.crpix1:=validate_double else{ref pixel for x}
            if header[i+5]='2' then head.crpix2:=validate_double;    {ref pixel for y}
          end;
          if ((header[i]='C') and (header[i+1]='D')  and (header[i+2]='E') and (header[i+3]='L') and (header[i+4]='T')) then {head.cdelt1}
          begin
            if header[i+5]='1' then head.cdelt1:=validate_double else{deg/pixel for RA}
            if header[i+5]='2' then head.cdelt2:=validate_double;    {deg/pixel for DEC}
          end;
          if ( ((header[i]='S') and (header[i+1]='E')  and (header[i+2]='C') and (header[i+3]='P') and (header[i+4]='I') and (header[i+5]='X')) or     {secpix1/2}
               ((header[i]='P') and (header[i+1]='I')  and (header[i+2]='X') and (header[i+3]='S') and (header[i+4]='C') and (header[i+5]='A')) ) then {pixscale}
          begin
            if head.cdelt2=0 then
                begin head.cdelt2:=validate_double/3600; {deg/pixel for RA} head.cdelt1:=head.cdelt2; end; {no head.cdelt1/2 found yet, use alternative}
          end;

          if ((header[i]='X') and (header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='S') and (header[i+5]='Z')) then {Xpixsz}
                 xpixsz:=validate_double;{Pixel Width in microns (after binning), maxim DL keyword}
          if ((header[i]='Y') and (header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='S') and (header[i+5]='Z')) then {Ypixsz}
                 ypixsz:=validate_double;{Pixel Width in microns (after binning), maxim DL keyword}

          if ((header[i]='F') and (header[i+1]='O')  and (header[i+2]='C') and (header[i+3]='A') and (header[i+4]='L') and (header[i+5]='L')) then  {focall}
                  focallen:=validate_double;{Focal length of telescope in mm, maxim DL keyword}

          if ((header[i]='C') and (header[i+1]='R')  and (header[i+2]='V') and (header[i+3]='A') and (header[i+4]='L')) then {crval1/2}
          begin
            if (header[i+5]='1') then  head.ra0:=validate_double*pi/180; {ra center, read double value}
            if (header[i+5]='2') then  head.dec0:=validate_double*pi/180; {dec center, read double value}
          end;
          if ((header[i]='R') and (header[i+1]='A')  and (header[i+2]=' ')) then  {ra}
          begin
            ra_mount:=validate_double*pi/180;
            if head.ra0=0 then head.ra0:=ra_mount; {ra telescope, read double value only if crval is not available}
          end;
          if ((header[i]='D') and (header[i+1]='E')  and (header[i+2]='C') and (header[i+3]=' ')) then {dec}
          begin
            dec_mount:=validate_double*pi/180;
            if head.dec0=0 then head.dec0:=dec_mount; {ra telescope, read double value only if crval is not available}
          end;


          if ((header[i]='O') and (header[i+1]='B')  and (header[i+2]='J')) then
          begin
            if  ((header[i+3]='C') and (header[i+4]='T')) then {objctra, objctdec}
            begin
              if ((header[i+5]='R') and (header[i+6]='A') and (ra_mount>=999) {ra_mount value is unfilled, preference for keyword RA}) then
              begin
                mainwindow.ra1.text:=get_string;{triggers an onchange event which will convert the string to ra_radians}
                ra_mount:=ra_radians;{preference for keyword RA}
              end
              else
              if ((header[i+5]='D') and (header[i+6]='E') and (dec_mount>=999){dec_mount value is unfilled, preference for keyword DEC}) then
              begin
                mainwindow.dec1.text:=get_string;{triggers an onchange event which will convert the string to dec_radians}
                dec_mount:=dec_radians;
              end
              else {for older MaximDL5}
              if ((header[i+5]='A') and (header[i+6]='L') and (centalt='')) then centalt:=get_as_string {universal for string and floats}
              else {for older MaximDL5}
              if ((header[i+5]='A') and (header[i+6]='Z')and (centaz='')) then centaz:=get_as_string; {universal for string and floats}
            end;

            if ((header[i+3]='E') and (header[i+4]='C') and (header[i+5]='T')) then {OBJECT}
          //    object_name:=StringReplace(get_string,' ','',[rfReplaceAll]);{remove all spaces}
              object_name:=trim(get_string);{remove all spaces}
          end;

          if ((header[i]='C') and (header[i+1]='E')  and (header[i+2]='N') and (header[i+3]='T') and (header[i+4]='A') and (header[i+5]='L') and (header[i+6]='T')) then  {SBIG 1.0 standard}
          begin
            centalt:=get_as_string; {universal for string and floats}
          end;


          if ((header[i]='C') and (header[i+1]='D')) then
          begin
            if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='1')) then   head.cd1_1:=validate_double;
            if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='2')) then   head.cd1_2:=validate_double;
            if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='1')) then   head.cd2_1:=validate_double;
            if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='2')) then   head.cd2_2:=validate_double;
          end;

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



          if ((header[i]='S') and (header[i+1]='C')  and (header[i+2]='A') and (header[i+3]='L') and (header[i+4]='E')) then  scale:=validate_double; {SCALE value for SGP files}

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

          if ((header[i]='B') and (header[i+1]='A')  and (header[i+2]='N') and (header[i+3]='D') and (header[i+4]='P') and (header[i+5]='A') and (header[i+6]='S')) then
          begin
             BANDPASS:=validate_double;{read integer as double value. Deep sky survey keyword}
             if ((bandpass=35) or (bandpass=8)) then head.filter_name:='red'{ 37 possII IR,  35=possII red, 18=possII blue, 8=POSSI red, 7=POSSI blue}
             else
             if ((bandpass=18) or (bandpass=7)) then head.filter_name:='blue'
             else
             head.filter_name:=floattostr(bandpass);
          end;

          if ((header[i]='A') and (header[i+1]='N')  and (header[i+2]='N') and (header[i+3]='O') and (header[i+4]='T') and (header[i+5]='A') and (header[i+6]='T')) then
             annotated:=true; {contains annotations}


          if ((header[i]=sqm_key[1]{S}) and (header[i+1]=sqm_key[2]{Q}) and (header[i+2]=sqm_key[3]{M})and (header[i+3]=sqm_key[4])and (header[i+4]=sqm_key[5])and (header[i+5]=sqm_key[6])and (header[i+6]=sqm_key[7]) and (header[i+7]=sqm_key[8])) then {adjustable keyword}
          begin
            sqm_value:=get_as_string; {universal for string and floats}{SQM, accept strings (standard) and floats}
          end;

          if ((header[i]=centaz_key[1]) and (header[i+1]=centaz_key[2]) and (header[i+2]=centaz_key[3])and (header[i+3]=centaz_key[4])and (header[i+4]=centaz_key[5])and (header[i+5]=centaz_key[6])and (header[i+6]=centaz_key[7]) and (header[i+7]=centaz_key[8])) then {adjustable keyword}
          begin
            centaz:=get_as_string; {universal for string and floats} {SGP, older CCDCIEL}
          end;


          if ((header[i]='E') and (header[i+1]='X')  and (header[i+2]='T') and (header[i+3]='E') and (header[i+4]='N') and (header[i+5]='D')) then {EXTEND}
            if pos('T',get_as_string)>0 then last_extension:=false;{could be extensions, will be updated later }


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
          begin {pixel to sky coefficient}
            if ((header[i+2]='O') and (header[i+3]='R') and (header[i+4]='D')) then a_order:=round(validate_double);{should be >=2 if TAN-SIP convention available}
            if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='0')) then a_0_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='1')) then a_0_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='2')) then a_0_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='3')) then a_0_3:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='0')) then a_1_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='1')) then a_1_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='2')) then a_1_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='0')) then a_2_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='1')) then a_2_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='3') and (header[i+3]='_') and (header[i+4]='0')) then a_3_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          end;
          if ((header[i]='B') and (header[i+1]='_')) then
          begin {pixel to sky coefficient}
            if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='0')) then b_0_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='1')) then b_0_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='2')) then b_0_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='0') and (header[i+3]='_') and (header[i+4]='3')) then b_0_3:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='o')) then b_1_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='1')) then b_1_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='2')) then b_1_2:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='0')) then b_2_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='1')) then b_2_1:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
            if ((header[i+2]='3') and (header[i+3]='_') and (header[i+4]='0')) then b_3_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
          end;
          if ((header[i]='A') and (header[i+1]='P') and (header[i+2]='_')) then
          begin {sky to pixel coefficient}
            if ((header[i+3]='O') and (header[i+4]='R') and (header[i+5]='D')) then ap_order:=round(validate_double);{should be >=2 if TAN-SIP convention available}
            if ((header[i+3]='0') and (header[i+4]='_') and (header[i+5]='0')) then ap_0_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
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
          begin  {sky to pixel coefficient}
            if ((header[i+3]='0') and (header[i+4]='_') and (header[i+5]='0')) then bp_0_0:=validate_double;{TAN-SIP convention, where ’SIP’ stands for Simple Imaging Polynomial}
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

      end {image header}
      else
      begin {read table header}
        if ((header[i]='T') and (header[i+1]='F')  and (header[i+2]='I') and (header[i+3]='E') and (header[i+4]='L') and (header[i+5]='D') and (header[i+6]='S')) then {tfields}
        begin
           tfields:=round(validate_double);
           setlength(ttype,tfields);
           setlength(tform,tfields);
           setlength(tform_nr,tfields);{number of sub field. E.g.12A is 12 time a character}
           setlength(tbcol,tfields);
           setlength(tunit,tfields);
        end;
        if ((header[i]='T') and (header[i+1]='F')  and (header[i+2]='O') and (header[i+3]='R') and (header[i+4]='M')) then
        begin
          number:=trim(header[i+5]+header[i+6]+header[i+7]);
          tform_counter:=strtoint(number)-1;
          tform[tform_counter]:=get_string;
          let:=pos('E',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='E';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{single e.g. E, 1E or 4E}
          let:=pos('D',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='D';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{double e.g. D, 1D or 5D (sub table 5*D) or D25.17}
          let:=pos('L',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='L';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{logical}
          let:=pos('X',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='X';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{bit}
          let:=pos('B',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='B';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{byte}
          let:=pos('I',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='I';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{16 bit integer}
          let:=pos('J',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='J';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{32 bit integer}
          let:=pos('K',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='K';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{64 bit integer}
          let:=pos('A',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='A';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{char e.g. 12A for astrometry.net first index table}
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
           ttype[strtoint(number)-1]:=(get_string);
        end;
        if ((header[i]='T') and (header[i+1]='U')  and (header[i+2]='N') and (header[i+3]='I') and (header[i+4]='T')) then {unit describtion}
        begin
           number:=trim(header[i+5]+header[i+6]+header[i+7]);
           tunit[strtoint(number)-1]:=get_string;
        end;
      end;
      end_record:=((header[i]='E') and (header[i+1]='N')  and (header[i+2]='D') and (header[i+3]=' '));{end of header. Note keyword ENDIAN exist, so test space behind END}
      inc(i,80);{go to next 80 bytes record}

    until ((i>=2880) or (end_record)); {loop for 80 bytes in 2880 block}
  until end_record; {header, 2880 bytes loop}


  if head.naxis<2 then
  begin
    if head.naxis=0 then result:=true {wcs file}
               else result:=false; {no image}
    mainwindow.image1.visible:=false;
//    fits_file:=false;
    image:=false;
  end;

  if image then {read image data #########################################}
  begin
    if ((head.naxis=3) and (naxis1=3)) then
    begin
       nrbits:=24; {threat RGB fits as 2 dimensional with 24 bits data}
       head.naxis3:=3; {will be converted while reading}
    end;
    if ( ((head.cdelt1=0) or (head.crota2>=999)) and (head.cd1_1<>0)) then
    begin
      new_to_old_WCS;{ convert old WCS to new}
    end
    else
    if ((head.crota2<999) and (head.cd1_1=0) and(head.cdelt1<>0)) then {valid head.crota2 value}
    begin
      old_to_new_WCS;{ convert old WCS to new}
    end;

    if head.set_temperature=999 then head.set_temperature:=round(ccd_temperature); {temperature}

    if head.crota2>999 then head.crota2:=0;{not defined, set at 0}
    if head.crota1>999 then head.crota1:=head.crota2; {for case head.crota1 is not used}

    if ((light) and (head.ra0<>0) and (head.dec0<>0)) then
    begin
       mainwindow.ra1.text:=prepare_ra(head.ra0,' ');{this will create Ra_radians for solving}
       mainwindow.dec1.text:=prepare_dec(head.dec0,' ');
    end;
    { condition           keyword    to
     if ra_mount>999 then objctra--->ra1.text--------------->ra_radians--->ra_mount
                               ra--->ra_mount  if head.ra0=0 then   ra_mount--->head.ra0
                           crval1--->head.ra0

     if head.ra0<>0 then           head.ra0--->ra1.text------------------->ra_radians}



    if ((head.cd1_1=0) and (head.cdelt2=0)) then  {no scale, try to fix it}
    begin
       if scale<>0 then {sgp file, use scale to find image dimensions}
         head.cdelt2:=scale/3600 {scale is in arcsec/pixel }
       else
       if ((focallen<>0) and (xpixsz<>0)) then
         head.cdelt2:=180/(pi*1000)*xpixsz/focallen; {use maxim DL key word. xpixsz is including binning}
    end;
    unsaved_import:=false;{file is available for astrometry.net}

    if load_data=false then begin
       close_fits_file; result:=true; exit;
    end;{only read header for analyse or WCS file}


    {############################## read image}
    i:=round(bufwide/(abs(nrbits/8)));{check if buffer is wide enough for one image line}
    if head.width>i then
    begin
      beep;
      textout(mainwindow.image1.canvas.handle,30,30,'Too wide FITS file !!!!!',25);
      close_fits_file;
      exit;
    end;

    setlength(img_loaded2,head.naxis3,head.width,head.height);

    if nrbits=16 then
    for k:=0 to head.naxis3-1 do {do all colors}
    begin
      For j:=0 to head.height-1 do
      begin
        try reader.read(fitsbuffer,head.width*2);except; end; {read file info}
        for i:=0 to head.width-1 do
        begin
          word16:=swap(fitsbuffer2[i]);{move data to wo and therefore sign_int}
          col_float:=int_16*bscale + bzero; {save in col_float for measuring measured_max}
          img_loaded2[k,i,j]:=col_float;
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end {colors head.naxis3 times}
    else
    if nrbits=-32 then
    for k:=0 to head.naxis3-1 do {do all colors}
    begin
      For j:=0 to head.height-1 do
      begin
        try reader.read(fitsbuffer,head.width*4);except; end; {read file info}
        for i:=0 to head.width-1 do
        begin
          x_longword:=swapendian(fitsbuffer4[i]);{conversion 32 bit "big-endian" data, x_single  : single absolute x_longword; }
          col_float:=x_single*bscale+bzero; {int_IEEE, swap four bytes and the read as floating point}
          if isNan(col_float) then col_float:=measured_max;{not a number prevent errors, can happen in PS1 images with very high floating point values}
          img_loaded2[k,i,j]:=col_float;{store in memory array}
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end {colors head.naxis3 times}
    else
    if nrbits=8 then
    for k:=0 to head.naxis3-1 do {do all colors}
    begin
      For j:=0 to head.height-1 do
      begin
        try reader.read(fitsbuffer,head.width);except; end; {read file info}
        for i:=0 to head.width-1 do
        begin
          img_loaded2[k,i,j]:=(fitsbuffer[i]*bscale + bzero);
        end;
      end;
    end {colors head.naxis3 times}
    else
    if nrbits=24 then
    For j:=0 to head.height-1 do
    begin
      try reader.read(fitsbuffer,head.width*3);except; end; {read file info}
      for i:=0 to head.width-1 do
      begin
        rgbdummy:=fitsbufferRGB[i];{RGB fits with naxis1=3, treated as 24 bits coded pixels in 2 dimensions}
        img_loaded2[0,i,j]:=rgbdummy[0];{store in memory array}
        img_loaded2[1,i,j]:=rgbdummy[1];{store in memory array}
        img_loaded2[2,i,j]:=rgbdummy[2];{store in memory array}
      end;
    end
    else
    if nrbits=+32 then
    for k:=0 to head.naxis3-1 do {do all colors}
    begin
      For j:=0 to head.height-1 do
      begin
        try reader.read(fitsbuffer,head.width*4);except; end; {read file info}
        for i:=0 to head.width-1 do
        begin
          col_float:=(swapendian(fitsbuffer4[i])*bscale+bzero)/(65535);{scale to 0..64535 or 0..1 float}
                         {Tricky do not use int64 for BZERO,  maxim DL writes BZERO value -2147483647 as +2147483648 !!}
          img_loaded2[k,i,j]:=col_float;{store in memory array}
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end {colors head.naxis3 times}
    else
    if nrbits=-64 then
    for k:=0 to head.naxis3-1 do {do all colors}
    begin
      For j:=0 to head.height-1 do
      begin
        try reader.read(fitsbuffer,head.width*8);except; end; {read file info}
        for i:=0 to head.width-1 do
        begin
          x_qword:=swapendian(fitsbuffer8[i]);{conversion 64 bit "big-endian" data, x_double    : double absolute x_int64;}
          col_float:=x_double*bscale + bzero; {int_IEEE, swap four bytes and the read as floating point}
          img_loaded2[k,i,j]:=col_float;{store in memory array}
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
        end;
      end;
    end; {colors head.naxis3 times}

    {rescale if required}
    if ((nrbits<=-32){-32 or -64} or (nrbits=+32)) then
    begin
      scalefactor:=1;
      if ((measured_max<=2.0) or (measured_max>65535)) then scalefactor:=65535/measured_max; {rescale 0..1 range float for GIMP, Astro Pixel Processor, PI files, transfer to 0..65535 float}
                                                                                              {or if values are above 65535}
      if scalefactor<>1 then {not a 0..65535 range, rescale}
      begin
        for k:=0 to head.naxis3-1 do {do all colors}
          for j:=0 to head.height-1 do
            for i:=0 to head.width-1 do
              img_loaded2[k,i,j]:= img_loaded2[k,i,j]*scalefactor;
        head.datamax_org:=65535;
      end
      else  head.datamax_org:=measured_max;

    end
    else
    if nrbits=8 then head.datamax_org:=255 {not measured}
    else
    if nrbits=24 then
    begin
      head.datamax_org:=255;
      nrbits:=8; {already converted to array with separate colour sections}
    end
    else {16 bit}
    head.datamax_org:=measured_max;{most common. It set for nrbits=24 in beginning at 255}

    cblack:=head.datamin_org;{for case histogram is not called}
    cwhite:=head.datamax_org;

    result:=true;
    fits_file:=true;{succes}
    reader_position:=reader_position+head.width*head.height*(abs(nrbits) div 8)
  end{image block}




  else
  if  ((head.naxis=2) and ((bintable) or (asciitable)) ) then
  begin {read table ############################################}
    if bintable then extend_type:=3;
    if asciitable then extend_type:=2;

    {try to read data table}
    aline:='';
    for k:=0 to tfields-1 do {columns}
        aline:=aline+ttype[k]+#9;
    aline:=aline+sLineBreak;
    for k:=0 to tfields-1 do {columns}
       aline:=aline+tunit[k]+#9;
    aline:=aline+sLineBreak;

    for j:=0 to head.height-1 do {rows}
    begin
      try reader.read(fitsbuffer[0],head.width);{read one row} except end;

      if extend_type=2 {ascii_table} then SetString(field, Pansichar(@fitsbuffer[0]),head.width);{convert to string}

      pointer:=0;
      for k:=0 to tfields-1 do {columns}
      {read}
      begin
        if extend_type=2 then {ascii table}
        begin
          if k>0 then insert(#9,field,tbcol[k]+k-1);{insert tab}
          if k=tfields-1 then aline:=aline+field;{field is ready}
        end
        else
        begin
          if tform[k]='E' then {4 byte single float or 21 times single if 21E specified}
          begin
            for n:=0 to Tform_nr[k]-1 do
            begin
              x_longword:=(fitsbuffer[pointer] shl 24) +(fitsbuffer[pointer+1] shl 16)+(fitsbuffer[pointer+2] shl 8)+(fitsbuffer[pointer+3]);
              aline:=aline+floattostrF(x_single,FFexponent,7,0)+#9; {int_IEEE, swap four bytes and the read as floating point}
              pointer:=pointer+4;
            end;
          end
          else
          if tform[k]='D' then {8 byte float}
          begin
            for n:=0 to Tform_nr[k]-1 do
            begin
              x_qword:=(qword(fitsbuffer[pointer]) shl 56) +(qword(fitsbuffer[pointer+1]) shl 48)+(qword(fitsbuffer[pointer+2]) shl 40)+(qword(fitsbuffer[pointer+3]) shl 32) + (qword(fitsbuffer[pointer+4]) shl 24) +(qword(fitsbuffer[pointer+5]) shl 16)+(qword(fitsbuffer[pointer+6]) shl 8)+(qword(fitsbuffer[pointer+7]));
              aline:=aline+floattostrF(x_double,FFexponent,7,0)+#9; {int_IEEE, swap four bytes and the read as floating point}
              pointer:=pointer+8;
            end;
          end
          else
          if tform[k]='I' then {16 bit int}
          begin
            for n:=0 to Tform_nr[k]-1 do
            begin
              word16:=(fitsbuffer[pointer] shl 8) + (fitsbuffer[pointer+1]);
              aline:=aline+inttostr(int_16)+#9;
              pointer:=pointer+2;
            end;
          end
          else
          if tform[k]='J' then {32 bit int}
          begin
            for n:=0 to Tform_nr[k]-1 do
            begin
              x_longword:=(fitsbuffer[pointer] shl 24) +(fitsbuffer[pointer+1] shl 16)+(fitsbuffer[pointer+2] shl 8)+(fitsbuffer[pointer+3]);
              aline:=aline+inttostr(int_32)+#9;
              pointer:=pointer+4;
            end;
          end
          else
          if tform[k]='K' then {64 bit int}
          begin
            for n:=0 to Tform_nr[k]-1 do
            begin
              x_qword:=(qword(fitsbuffer[pointer]) shl 56) +(qword(fitsbuffer[pointer+1]) shl 48)+(qword(fitsbuffer[pointer+2]) shl 40)+(qword(fitsbuffer[pointer+3]) shl 32) + (qword(fitsbuffer[pointer+4]) shl 24) +(qword(fitsbuffer[pointer+5]) shl 16)+(qword(fitsbuffer[pointer+6]) shl 8)+(qword(fitsbuffer[pointer+7]));
              aline:=aline+inttostr(int_64)+#9; {int_IEEE, swap eight bytes and the read as floating point}
              pointer:=pointer+8;
            end;
          end
          else
          if ((tform[k]='L') or (Tform[k]='X') or (Tform[k]='B')) then {logical, bit or byte }
          begin
            for n:=0 to Tform_nr[k]-1 do
            begin
              aline:=aline+inttostr(fitsbuffer[pointer])+#9;
              pointer:=pointer+1;
            end;
          end
          else
          if ((Tform[k]='A')) then {chars}
          begin
            field:='';
            for n:=0 to Tform_nr[k]-1 do
            begin
              abyte:=fitsbuffer[pointer+n];
              if ((abyte>=32) and  (abyte<=127)) then field:=field+ansichar(abyte)
                else  field:=field+'?';{exotic char, prevent confusion tmemo}
            end;
            aline:=aline+field+ #9;
            pointer:=pointer+Tform_nr[k];{for 12A, plus 12}
          end
        end;
      end;
      aline:=aline+sLineBreak ;
    end;
    mainwindow.Memo3.lines.text:=aline;
    aline:=''; {release memory}
    if update_memo then mainwindow.memo1.visible:=true;{show header}
    mainwindow.pagecontrol1.showtabs:=true;{show tabs}
    reader_position:=reader_position+head.width*head.height;
  end;{read table}



  if last_extension=false then {test if extension is possible}
  begin
    if file_size-reader_position>2880 then {file size confirms extension}
    begin
      if get_ext=0 then
         mainwindow.Memo3.lines.text:='File contains extension image(s) or table(s).';
      mainwindow.pagecontrol1.showtabs:=true;{show tabs}

      last_extension:=false;
      if head.naxis<2 then
      begin
        mainwindow.error_label1.caption:=('Contains extension(s). Click on the arrows to scroll.');
        mainwindow.error_label1.visible:=true;
        mainwindow.memo1.visible:=true;{show memo1 since no plotting is coming}
      end;
    end
    else
    begin
      last_extension:=true;
    end;
  end;
  if ((last_extension=false) or (extend_type>0)) then
     mainwindow.tabsheet1.caption:='Header '+inttostr(get_ext);

  close_fits_file;
end;


procedure Wait(wt:single=500);  {smart sleep}
var endt: TDateTime;
begin
  endt:=now+wt/MSecsPerDay;
  while now<endt do begin
    Sleep(5);
    if GetCurrentThreadId=MainThreadID then Application.ProcessMessages;
  end;
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
  head.crota2:=99999;{just for the case it is not available, make it later zero}
  head.crota1:=99999;
  head.ra0:=0;
  head.dec0:=0;
  ra_mount:=99999;
  dec_mount:=99999;
  head.cdelt1:=0;
  head.cdelt2:=0;
  xpixsz:=0;
  ypixsz:=0;
  focallen:=0;
  subsamp:=1;{just for the case it is not available}
  head.cd1_1:=0;{just for the case it is not available}
  head.cd1_2:=0;{just for the case it is not available}
  head.cd2_1:=0;{just for the case it is not available}
  head.cd2_2:=0;{just for the case it is not available}
  head.date_obs:='';date_avg:=''; ut:=''; pltlabel:=''; plateid:=''; telescop:=''; instrum:='';  origin:=''; object_name:='';{clear}
  sitelat:=''; sitelong:='';
  head.filter_name:='';
  head.calstat:='';{indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected, S stacked. Example value DFB}
  imagetype:='';
  xbinning:=1;{normal}
  ybinning:=1;
  head.exposure:=0;
  head.set_temperature:=999;
  x_coeff[0]:=0; {reset DSS_polynomial, use for check if there is data}
  y_coeff[0]:=0;
  a_order:=0; {reset SIP_polynomial, use for check if there is data}
  ap_order:=0; {reset SIP_polynomial, use for check if there is data}


  count1:=mainwindow.Memo1.Lines.Count-1-1;
  while count1>1 do {read bare minimum keys since TIFF is not required for stacking}
  begin
    key:=copy(mainwindow.Memo1.Lines[count1],1,9);
    if key='CD1_1   =' then head.cd1_1:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='CD1_2   =' then head.cd1_2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='CD2_1   =' then head.cd2_1:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='CD2_2   =' then head.cd2_2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));

    if key='CRVAL1  =' then ra2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='CRVAL2  =' then dec2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='RA      =' then ra2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    if key='DEC     =' then dec2:=read_float(copy(mainwindow.Memo1.Lines[count1],11,20));
    count1:=count1-1;
  end;
  if ((ra2<>999) and (dec2<>999)) then {data available}
  begin
    head.ra0:=ra2*pi/180; {degrees -> radians}
    head.dec0:=dec2*pi/180;
    mainwindow.ra1.text:=prepare_ra(head.ra0,' ');{show center of image}
    mainwindow.dec1.text:=prepare_dec(head.dec0,' ');
  end;
  if head.cd1_1<>0 then new_to_old_WCS;
end;


function load_PPM_PGM_PFM(filen:string; var load :theader; var img_loaded2: image_array) : boolean;{load PPM (color),PGM (gray scale)file or PFM color}
var
   i,j, reader_position  : integer;
   aline,w1,h1,bits,comm  : ansistring;
   ch                : ansichar;
   rgb32dummy        : byteXXXX3;
   rgb16dummy        : byteXX3;
   rgbdummy          : byteX3;
   err,err2,err3,package  : integer;
   comment,color7,pfm,expdet,timedet,isodet,instdet,ccdtempdet  : boolean;
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
  head.naxis:=0; {0 dimensions}
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

  reset_fits_global_variables(true{light},head); {reset the global variable}

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
      ccdtempdet:=false;
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
            if expdet then begin head.exposure:=strtofloat2(comm);expdet:=false; end;{get head.exposure time from comments,special dcraw 0.9.28dev1}
            if isodet then begin head.gain:=comm;isodet:=false; end;{get iso speed as head.gain}
            if instdet then begin instrum:=comm;instdet:=false;end;{camera}
            if ccdtempdet then begin head.set_temperature:=round(strtofloat2(comm));ccdtempdet:=false;end;{sensor temperature}
            if timedet then
            begin
              JD2:=2440587.5+ strtoint(comm)/(24*60*60);{convert to Julian Day by adding factor. Unix time is seconds since 1.1.1970}
              head.date_obs:=JdToDate(jd2);
              timedet:=false;
            end;{get date from comments}
            comm:='';{clear for next keyword}
          end;
          if comm='EXPTIME=' then begin expdet:=true; comm:=''; end else
          if comm='TIMESTAMP=' then begin timedet:=true; comm:=''; end else
          if comm='ISOSPEED=' then begin isodet:=true; comm:=''; end else
          if comm='MODEL=' then begin instdet:=true; comm:=''; end; {camera make}
          if comm='CCD-TEMP=' then begin ccdtempdet:=true; comm:=''; end; {camera make}
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

    val(w1,head.width,err);
    val(h1,head.height,err2);

    val(bits,range,err3);{number of bits}

    nrbits:=round(range);

    if pfm then begin nrbits:=-32; head.datamax_org:=$FFFF;end     {little endian PFM format. If nrbits=-1 then range 0..1. If nrbits=+1 then big endian with range 0..1 }
    else
    if nrbits=65535 then begin nrbits:=16; head.datamax_org:=$FFFF;end
    else
    if nrbits=255 then begin nrbits:=8;head.datamax_org:=$FF; end
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

    head.datamin_org:=0;
    fits_file:=true;

    cblack:=head.datamin_org;{for case histogram is not called}
    cwhite:=head.datamax_org;

    if color7 then
    begin
       package:=round((abs(nrbits)*3/8));{package size, 3 or 6 bytes}
       head.naxis3:=3; {head.naxis3 number of colors}
       head.naxis:=3; {number of dimensions}
    end
    else
    begin {gray image without bayer matrix applied}
      package:=round((abs(nrbits)/8));{package size, 1 or 2 bytes}
      head.naxis3:=1; {head.naxis3 number of colors}
      head.naxis:=2;{number of dimensions}
    end;
    i:=round(bufwide/package);
    if head.width>i then
    begin
      beep;
      textout(mainwindow.image1.canvas.handle,30,30,'Too large FITS file !!!!!',25);
      close_fits_file;
      exit;
    end
    else
    begin {not too large}
      setlength(img_loaded2,head.naxis3,head.width,head.height);
      begin
        For i:=0 to head.height-1 do
        begin
          try reader.read(fitsbuffer,head.width*package);except; end; {read file info}

          for j:=0 to head.width-1 do
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
    if ((j<>5) or  (head.naxis3<>1)) then {skip head.naxis3 for mono images}
        mainwindow.memo1.lines.add(head1[j]); {add lines to empthy memo1}
  mainwindow.memo1.lines.add(head1[27]); {add end}

  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS   =',' / Number of dimensions                           ' ,head.naxis);{2 for mono, 3 for colour}
  update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);
  if head.naxis3<>1 then
    update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,head.naxis3);
  update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer('DATAMAX =',' / Maximum data value                           ' ,round(head.datamax_org));

  if head.exposure<>0 then   update_float('EXPTIME =',' / duration of exposure in seconds                ' ,head.exposure);
  if head.gain<>'' then    update_integer('GAIN    =',' / iso speed                                      ' ,strtoint(head.gain));

  if head.date_obs<>'' then update_text   ('DATE-OBS=',#39+head.date_obs+#39);
  if instrum<>''  then update_text   ('INSTRUME=',#39+INSTRUM+#39);

  update_text   ('BAYERPAT=',#39+'T'+#39+'                  / Unknown Bayer color pattern                  ');

  update_text   ('COMMENT 1','  Written by ASTAP, Astrometric STAcking Program. www.hnsky.org');
end;


function load_TIFFPNGJPEG(filen:string; var head : theader;var img_loaded2: image_array) : boolean;{load 8 or 16 bit TIFF, PNG, JPEG, BMP image}
var
  i,j   : integer;
  jd2   : double;
  image: TFPCustomImage;
  reader: TFPCustomImageReader;
  tiff, png,jpeg,colour,saved_header  : boolean;
  ext,descrip   : string;
begin
  head.naxis:=0; {0 dimensions}
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

  reset_fits_global_variables(true{light},head); {reset the global variable}

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
     head.naxis:=2;
     head.naxis3:=1;
  end
  else
  begin
    head.naxis:=3; {three dimensions, x,y and 3 colours}
    head.naxis3:=3;
  end;

  mainwindow.memo1.visible:=false;{stop visualising memo1 for speed. Will be activated in plot routine}
  mainwindow.memo1.clear;{clear memo for new header}

  {set data}
  extend_type:=0;  {no extensions in the file, 1 is image, 2 is ascii_table, 3 bintable}
  fits_file:=true;
  nrbits:=16;
  head.datamin_org:=0;
  head.datamax_org:=$FFFF;
  cblack:=head.datamin_org;{for case histogram is not called}
  cwhite:=head.datamax_org;


  head.width:=image.width;
  head.height:=image.height;
  setlength(img_loaded2,head.naxis3,head.width,head.height);

  if head.naxis3=3 then
  begin
    For i:=0 to head.height-1 do
      for j:=0 to head.width-1 do
      begin
        img_loaded2[0,j,head.height-1-i]:=image.Colors[j,i].red;
        img_loaded2[1,j,head.height-1-i]:=image.Colors[j,i].green;
        img_loaded2[2,j,head.height-1-i]:=image.Colors[j,i].blue;
      end;
  end
  else
  begin
    For i:=0 to head.height-1 do
      for j:=0 to head.width-1 do
        img_loaded2[0,j,head.height-1-i]:=image.Colors[j,i].red;
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
      if ((j<>5) or  (head.naxis3<>1)) then {skip head.naxis3 for mono images}
        mainwindow.memo1.lines.add(head1[j]); {add lines to empthy memo1}
    mainwindow.memo1.lines.add(head1[27]); {add end}
    if descrip<>'' then add_long_comment(descrip);{add TIFF describtion}
  end;

  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS   =',' / Number of dimensions                           ' ,head.naxis);{2 for mono, 3 for colour}
  update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);
  update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer('DATAMAX =',' / Maximum data value                             ' ,round(head.datamax_org));

  if saved_header=false then {saved header in tiff is not restored}
  begin
    JD2:=2415018.5+(FileDateToDateTime(fileage(filen))); {fileage ra, convert to Julian Day by adding factor. filedatatodatetime counts from 30 dec 1899.}
    head.date_obs:=JdToDate(jd2);
    update_text ('DATE-OBS=',#39+head.date_obs+#39);{give start point exposures}
  end;

  update_text   ('COMMENT 1','  Written by ASTAP, Astrometric STAcking Program. www.hnsky.org');

  { Clean up! }
  image.Free;
  reader.free;
  unsaved_import:=true;{file is not available for astrometry.net}
  result:=true;{succes}

end;


procedure Tmainwindow.LoadFITSPNGBMPJPEG1Click(Sender: TObject);
var
  Save_Cursor:TCursor;
begin
  OpenDialog1.Title := 'Open in viewer';
  opendialog1.Filter :=  'All formats |*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP;*.tif;*.tiff;*.TIF;*.new;*.ppm;*.pgm;*.pbm;*.pfm;*.xisf;*.fz;'+
                                      '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf; *.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                                      '*.axy;*.xyls'+
                                      '|FITS files (*.fit*,*.xisf)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.new;*.xisf;*.fz'+
                         '|PNG, TIFF, JPEG, BMP(*.png,*.tif*, *.jpg,*.bmp)|*.png;*.PNG;*.tif;*.tiff;*.TIF;*.jpg;*.JPG;*.bmp;*.BMP'+
                         '|Preview FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';
  opendialog1.filename:=filename2;
  opendialog1.initialdir:=ExtractFileDir(filename2);
  opendialog1.filterindex:=LoadFITSPNGBMPJPEG1filterindex;
  if opendialog1.execute then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    filename2:=opendialog1.filename;
    if opendialog1.FilterIndex<>4 then {<> preview FITS files, not yet loaded}
    {loadimage}
    load_image(true,true {plot});{load and center}
    LoadFITSPNGBMPJPEG1filterindex:=opendialog1.filterindex;{remember filterindex}
    Screen.Cursor:=Save_Cursor;
  end;
end;


function prepare_IAU_designation(rax,decx :double):string;{radialen to text hhmmss.s+ddmmss  format}
 var                         {IAU doesn't recommend rounding, however it is implemented here}
   hh,mm,ss,ds  :integer;
   g,m,s  :integer;
   sign   : char;
begin
  {RA}
  rax:=rax+pi*2*0.05/(24*60*60); {add 1/10 of half second to get correct rounding and not 7:60 results as with round}
  rax:=rax*12/pi; {make hours}
  hh:=trunc(rax);
  mm:=trunc((rax-hh)*60);
  ss:=trunc((rax-hh-mm/60)*3600);
  ds:=trunc((rax-hh-mm/60-ss/3600)*36000);

  {DEC}
  if decx<0 then sign:='-' else sign:='+';
  decx:=abs(decx)+pi*2*0.5/(360*60*60); {add half second to get correct rounding and not 7:60 results as with round}
  decx:=decx*180/pi; {make degrees}
  g:=trunc(decx);
  m:=trunc((decx-g)*60);
  s:=trunc((decx-g-m/60)*3600);
  result:=leadingzero(hh)+leadingzero(mm)+leadingzero(ss)+'.'+char(ds+48)+sign+leadingzero(g)+leadingzero(m)+leadingzero(s);
end;



procedure get_background(colour: integer; img :image_array;calc_hist, calc_noise_level: boolean; out background, starlevel: double); {get background and star level from peek histogram}
var
  i, pixels,max_range,above,his_total, fitsX, fitsY,counter,stepsize,width5,height5, iterations : integer;
  value,sd, sd_old : double;
begin
  if calc_hist then  get_hist(colour,img);{get histogram of img_loaded and his_total}

  background:=img[0,0,0];{define something for images containing 0 or 65535 only}

  {find peak in histogram which should be the average background}
  pixels:=0;
  max_range:=his_mean[colour]; {mean value from histogram}
  for i := 1 to max_range do {find peak, ignore value 0 from oversize}
    if histogram[colour,i]>pixels then {find colour peak}
    begin
      pixels:= histogram[colour,i];
      background:=i;
    end;

  {check alternative mean value}
  if his_mean[colour]>1.5*background {1.5* most common} then  {changed from 2 to 1.5 on 2021-5-29}
  begin
    memo2_message(Filename2+', will use mean value '+inttostr(round(his_mean[colour]))+' as background rather then most common value '+inttostr(round(background)));
    background:=his_mean[colour];{strange peak at low value, ignore histogram and use mean}
  end;

  if calc_noise_level then  {find star level and background noise level}
  begin
    {calculate star level}
    if ((nrbits=8) or (nrbits=24)) then max_range:= 255 else max_range:=65001 {histogram runs from 65000};{8 or 16 / -32 bit file}
    i:=max_range;
    starlevel:=0;
    above:=0;

    if colour=1 then his_total:=his_total_green
    else
    if colour=2 then his_total:=his_total_blue
    else
    his_total:=his_total_red;

    while ((starlevel=0) and (i>background+1)) do {find star level 0.003 of values}
    begin
       dec(i);
       above:=above+histogram[colour,i];
       if above>0.001*his_total then starlevel:=i;
    end;
    if starlevel<= background then starlevel:=background+1 {no or very few stars}
    else
    starlevel:=starlevel-background-1;{star level above background. Important subtract 1 for saturated images. Otherwise no stars are detected}

    {calculate noise level}
    stepsize:=round(head.height/71);{get about 71x71=5000 samples. So use only a fraction of the pixels}
    if odd(stepsize)=false then stepsize:=stepsize+1;{prevent problems with even raw OSC images}

    width5:=Length(img[0]);    {width}
    height5:=Length(img[0][0]); {height}

    sd:=99999;
    iterations:=0;
    repeat  {repeat until sd is stable or 7 iterations}
      fitsX:=15;
      counter:=1; {never divide by zero}
      sd_old:=sd;
      while fitsX<=width5-1-15 do
      begin
        fitsY:=15;
        while fitsY<=height5-1-15 do
        begin
          value:=img[colour,fitsX,fitsY];
          if ((value<background*2) and (value<>0)) then {not an outlier, noise should be symmetrical so should be less then twice background}
          begin
            if ((iterations=0) or (abs(value-background)<=3*sd_old)) then {ignore outliers after first run}
            begin
              sd:=sd+sqr(value-background); {sd}
              inc(counter);{keep record of number of pixels processed}
            end;
          end;
          inc(fitsY,stepsize);;{skip pixels for speed}
        end;
        inc(fitsX,stepsize);{skip pixels for speed}
      end;
      sd:=sqrt(sd/counter); {standard deviation}
      inc(iterations);
    until (((sd_old-sd)<0.05*sd) or (iterations>=7));{repeat until sd is stable or 7 iterations}
    noise_level[colour]:= round(sd);   {this noise level is too high for long exposures and if no flat is applied. So for images where center is brighter then the corners.}
  end;
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
      if copy(aline,32,1)='/' then
        delete(aline,11,20) {preserve comment}
      else
        delete(aline,11,80);  {delete all}

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


procedure update_longstr(inpt,thestr:string);{update or insert long str including single quotes}
var
   count1,m,k: integer;
   ampersand : string;
begin

  count1:=mainwindow.Memo1.Lines.Count-1;
  while count1>=0 do {delete keyword}
  begin
    if pos(inpt,mainwindow.Memo1.Lines[count1])>0 then {found, delete old keyword}
    begin
      mainwindow.Memo1.Lines.delete(count1);
      while pos('CONTINUE=',mainwindow.Memo1.Lines[count1])>0 do
        mainwindow.Memo1.Lines.delete(count1);
    end;
    count1:=count1-1;
  end;

  {keyword removed, add new to the end}
  m:=length(thestr);

  if m>68 then
  begin {write as multi record}
    mainwindow.memo1.lines.insert(mainwindow.Memo1.Lines.Count-1,inpt+' '+#39+copy(thestr,1,67)+'&'+#39);{text starting with char(39) should start at position 11 according FITS standard 4.0}
    k:=68;
    repeat {write in blocks of 67 char}
      if (m-k)>67 then ampersand:='&' else ampersand:='';
      mainwindow.memo1.lines.insert(mainwindow.Memo1.Lines.Count-1,'CONTINUE= '+#39+copy(thestr,k,67)+ampersand+#39);{text starting with char(39) should start at position 11 according FITS standard 4.0}
      inc(k,67);
    until k>=m;
  end
  else {write as single record}
  mainwindow.memo1.lines.insert(mainwindow.Memo1.Lines.Count-1,inpt+' '+#39+thestr+#39);

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


procedure progress_indicator(i:double; info:string);{0..100 is 0 to 100% indication of progress}
begin
  if i<=-1 then
  begin
    if i=-101 then application.title:='🗙'
    else
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


procedure ang_sep(ra1,dec1,ra2,dec2 : double;out sep: double);{calculates angular separation. according formula 9.1 old Meeus or 16.1 new Meeus, version 2018-5-23}
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
  if xmax>head.width-1 then xmax:=head.width-1;
  if ymin<0 then ymin:=0;
  if ymax>head.height-1 then ymax:=head.height-1;

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

    img_backup[index_backup].head_val:=head;

    img_backup[index_backup].xbinning:=xbinning;
    img_backup[index_backup].ybinning:=ybinning;
    img_backup[index_backup].XPIXSZ:=XPIXSZ;
    img_backup[index_backup].YPIXSZ:=YPIXSZ;

    img_backup[index_backup].header:=mainwindow.Memo1.Text;{backup fits header}
    img_backup[index_backup].filen:=filename2;{backup filename}

    img_backup[index_backup].img:=img_loaded;
    setlength(img_backup[index_backup].img,head.naxis3,head.width,head.height);{this forces an duplication}{In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}

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

    old_width2:=head.width;
    old_height2:=head.height;

    head:=img_backup[index_backup].head_val;{restore main header values}

    resized:=((head.width<>old_width2) or ( head.height<>old_height2));

    xbinning:=img_backup[index_backup].xbinning;
    ybinning:=img_backup[index_backup].ybinning;
    XPIXSZ:=img_backup[index_backup].XPIXSZ;
    YPIXSZ:=img_backup[index_backup].YPIXSZ;

    mainwindow.Memo1.Text:=img_backup[index_backup].header;{restore fits header}
    filename2:=img_backup[index_backup].filen;{backup filename}

    stackmenu1.test_pattern1.Enabled:=head.naxis3=1;{allow debayer if mono again}
    img_loaded:=img_backup[index_backup].img; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
    setlength(img_loaded,head.naxis3,head.width,head.height);{force a duplication}

    use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
    plot_fits(mainwindow.image1,resized,true);{restore image1}

    stackmenu1.apply_dpp_button1.Enabled:=true;
    update_equalise_background_step(equalise_background_step-1);{update equalize menu}

    if fits_file=false {due to stretch draw} then update_menu(true); {update menu and set fits_file:=true;}

    dec(index_backup,1);{update index}
    if index_backup<0 then index_backup:=size_backup;

    if img_backup[index_backup].img=nil then
    begin
      mainwindow.Undo1.Enabled:=false;  //No more backups
    end
    else
    memo2_message('Restored backup index '+inttostr(index_backup));

    Screen.Cursor:=Save_Cursor;
  end;
end;


procedure Tmainwindow.About1Click(Sender: TObject);
var
    about_message, about_message4, about_message5 : string;
var {################# initialised variables #########################}
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
  #13+#10+'It uses an internal star matching routine, internal astrometric solving routine or a local version of astrometry.net for alignment.'+' For RAW file conversion it uses the external programs Dcraw or LibRaw.'+
  #13+#10+
  #13+#10+about_message5+
  #13+#10+
  #13+#10+'Send an e-mail if you like this free program. Feel free to distribute!'+
  #13+#10+
  #13+#10+'© 2018, 2022 by Han Kleijn. License MPL 2.0, Webpage: www.hnsky.org'+
  #13+#10+
  #13+#10+'ASTAP version 2022.01.03, '+about_message4;

   application.messagebox(pchar(about_message), pchar(about_title),MB_OK);
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

    for k:=0 to head.naxis3-1 do {do all colors}
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
          progress_value:=round(100*( k/head.naxis3 +  0.3333*(fitsY-startY2)/(stopY2-startY2)));
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
  w:=trunc(head.width/binfactor);  {half size & cropped. Use trunc for image 1391 pixels wide like M27 test image. Otherwise exception error}
  h:=trunc(head.height/binfactor);
  setlength(img_temp2,head.naxis3,w,h);
  if binfactor=2 then
  begin
    for k:=0 to head.naxis3-1 do
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
    for k:=0 to head.naxis3-1 do
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
    for k:=0 to head.naxis3-1 do
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
  head.width:=w;
  head.height:=h;
  img_temp2:=nil;

  update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);

  if head.crpix1<>0 then begin head.crpix1:=head.crpix1/binfactor; update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,head.crpix1);end;
  if head.crpix2<>0 then begin head.crpix2:=head.crpix2/binfactor; update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,head.crpix2);end;

  if head.cdelt1<>0 then begin head.cdelt1:=head.cdelt1*binfactor; update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,head.cdelt1);end;
  if head.cdelt2<>0 then begin head.cdelt2:=head.cdelt2*binfactor; update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,head.cdelt2);end;

  if head.cd1_1<>0 then
  begin
    head.cd1_1:=head.cd1_1*binfactor;
    head.cd1_2:=head.cd1_2*binfactor;
    head.cd2_1:=head.cd2_1*binfactor;
    head.cd2_2:=head.cd2_2*binfactor;
    update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_1);
    update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_2);
    update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_1);
    update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_2);
  end;
  XBINNING:=XBINNING*binfactor;
  YBINNING:=YBINNING*binfactor;
  update_integer('XBINNING=',' / Binning factor in width                         ' ,round(XBINNING));
  update_integer('YBINNING=',' / Binning factor in height                        ' ,round(yBINNING));
  if XPIXSZ<>0 then
  begin
    XPIXSZ:=XPIXSZ*binfactor;
    YPIXSZ:=YPIXSZ*binfactor;
    update_float('XPIXSZ  =',' / Pixel width in microns (after binning)          ' ,XPIXSZ);
    update_float('YPIXSZ  =',' / Pixel height in microns (after binning)         ' ,YPIXSZ);
    update_float('PIXSIZE1=',' / Pixel width in microns (after binning)          ' ,XPIXSZ);
    update_float('PIXSIZE2=',' / Pixel height in microns (after binning)         ' ,YPIXSZ);
  end;
  fact:=inttostr(binfactor);
  fact:=fact+'x'+fact;
  add_text   ('HISTORY   ','BIN'+fact+' version of '+filename2);
end;


function binX2X3_file(binfactor:integer) : boolean; {converts filename2 to binx2 or bin3 version}
begin
  result:=false;
  if load_fits(filename2,true {light},true {load data},true {update memo},0,head,img_loaded)=false then exit;

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
  opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';

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


procedure Tmainwindow.Memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    setlength(img_temp,head.naxis3,stopX-startX,stopY-startY);
    for k:=0 to head.naxis3-1 do {do all colors}
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

    for k:=0 to head.naxis3-1 do {do all colors}
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
     if y>head.height-1 then checkY:=head.height-1
     else
     checkY:=y;
   end;
   function checkx(X: integer): integer;
   begin
     if x<0 then checkX:=0
     else
     if x>head.width-1 then checkX:=head.width-1
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

    for k:=0 to head.naxis3-1 do {do all colors}
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
        for k:=0 to head.naxis3-1 do {do all colors}
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
          for k:=0 to head.naxis3-1 do {do all colors}
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
//  backup_img;
  load_hyperleda;   { Load the database once. If loaded no action}
  plot_deepsky;{plot the deep sky object on the image}
  Screen.Cursor:=Save_Cursor;
end;


function extract_objectname_from_filename(filename8: string): string; {try to extract head.exposure from filename}
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


procedure Tmainwindow.clean_up1Click(Sender: TObject);
begin
  plot_fits(mainwindow.image1,false,true);
end;


procedure Tmainwindow.remove_colour1Click(Sender: TObject);{make local area grayscale}
var
   fitsX,fitsY,dum    : integer;
   val  : single;
   Save_Cursor:TCursor;
begin
  if ((head.naxis3<>3) or (fits_file=false)) then exit;
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

procedure Tmainwindow.rotateleft1Click(Sender: TObject);
begin

end;


procedure celestial_to_pixel(ra_t,dec_t: double; out fitsX,fitsY: double);{ra,dec to fitsX,fitsY}
var
  SIN_dec_t,COS_dec_t,
  SIN_dec_ref,COS_dec_ref,det, delta_ra,SIN_delta_ra,COS_delta_ra, H, dRa,dDec,u0,v0 : double;
begin
  {5. Conversion (RA,DEC) -> (x,y) of reference image}
  sincos(dec_t,SIN_dec_t,COS_dec_t);{sincos is faster then separate sin and cos functions}
  sincos(head.dec0,SIN_dec_ref,COS_dec_ref);{}

  delta_ra:=ra_t-head.ra0;
  sincos(delta_ra,SIN_delta_ra,COS_delta_ra);

  H := SIN_dec_t*sin_dec_ref + COS_dec_t*COS_dec_ref*COS_delta_ra;
  dRA := (COS_dec_t*SIN_delta_ra / H)*180/pi;
  dDEC:= ((SIN_dec_t*COS_dec_ref - COS_dec_t*SIN_dec_ref*COS_delta_ra ) / H)*180/pi;

  det:=head.cd2_2*head.cd1_1 - head.cd1_2*head.cd2_1;

  u0:= - (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  v0:= + (head.cd1_1*dDEC - head.cd2_1*dRA) / det;


  if sip then {apply SIP correction, sky to pixel}
  begin
    fitsX:=(head.crpix1 + u0 + ap_0_0 + ap_0_1*v0+ ap_0_2*v0*v0+ ap_0_3*v0*v0*v0 +ap_1_0*u0 + ap_1_1*u0*v0+  ap_1_2*u0*v0*v0+ ap_2_0*u0*u0 + ap_2_1*u0*u0*v0+  ap_3_0*u0*u0*u0); {3th order SIP correction, fits count from 1, image from zero therefore subtract 1}
    fitsY:=(head.crpix2 + v0 + bp_0_0 + bp_0_1*v0+ bp_0_2*v0*v0+ bp_0_3*v0*v0*v0 +bp_1_0*u0 + bp_1_1*u0*v0+  bp_1_2*u0*v0*v0+ bp_2_0*u0*u0 + bp_2_1*u0*u0*v0+  bp_3_0*u0*u0*u0); {3th order SIP correction}
  end
  else
  begin
    fitsX:=head.crpix1 + u0; {in fits range 1..width}
    fitsY:=head.crpix2 + v0;
  end;
end;


function place_marker_radec(data0: string): boolean;{place ra,dec marker in image}
var
  ra_new,dec_new, fitsx,fitsy : double;
  error1,error2,degrees   : boolean;
  data1,ra_text,dec_text,sipwcs  : string;
  pos1,pos2,pos3,pos4,pos5,pos6,i :integer;

begin
  if ((fits_file=false) or (head.cd1_1=0) or (mainwindow.shape_marker3.visible=false)) then exit;{no solution to place marker}

  {Simbad sirius    06 45 08.917 -16 42 58.02      }
  {Orion   5h 35.4m; Declination_symbol1: 5o 27′ south    }
  {http://www.rochesterastronomy.org/supernova.html#2020ue
  R.A. = 00h52m33s.814, Decl. = +80°39'37".93 }

  data0:=uppercase(data0);
  degrees:=pos('D',data0)>0;{degrees ?}
  data0:=StringReplace(data0,'S.','.',[]); {for 00h52m33s.814}
  data0:=StringReplace(data0,'".','.',[]); {for +80°39'37".93}
  data0:=StringReplace(data0,'R.A.','',[]); {remove dots from ra}
  data0:=StringReplace(data0,'DECL.','',[]);{remove dots from decl}

  if pos('C',data0)>0 then {place marker in middle}
  begin
    sensor_coordinates_to_celestial(head.width/2,head.height/2,ra_new,dec_new);{calculate the center position also for solutions with the reference pixel somewhere else}
    error1:=false;
    error2:=false;
    data1:='Center image '; {for hint}
  end
  else
  begin
    data1:='';

    for I := 1 to length(data0) do
    begin
      if (((ord(data0[i])>=48) and (ord(data0[i])<=57)) or (data0[i]='.') or (data0[i]='-')) then   data1:=data1+data0[i] else data1:=data1+' ';{replace all char by space except for numbers and dot}
    end;
    repeat  {remove all double spaces}
      i:=pos('  ',data1);
      if i>0 then delete(data1,i,1);
    until i=0;

    while ((length(data1)>=1) and (data1[1]=' ')) do {remove spaces in the front for pos1 detectie}
                                       delete(data1,1,1);
    while ((length(data1)>=1) and (data1[length(data1)]=' ')) do {remove spaces in the end since VAL( can't cope with them}
                                       delete(data1,length(data1),1);
    pos1:=pos(' ',data1);  if pos1=0 then exit;
    pos2:=posEX(' ',data1,pos1+1); if pos2=0 then pos2:=length(data1)+1;
    pos3:=posEX(' ',data1,pos2+1); if pos3=0 then pos3:=length(data1)+1;
    pos4:=posEX(' ',data1,pos3+1); if pos4=0 then pos4:=length(data1)+1;
    pos5:=posEX(' ',data1,pos4+1); if pos5=0 then pos5:=length(data1)+1;
    pos6:=posEX(' ',data1,pos5+1); if pos6=0 then pos6:=length(data1)+1;

    if pos5<>pos6  then {6 string position}
    begin
      ra_text:=copy(data1,1, pos3);
      dec_text:=copy(data1,pos3+1,99);
    end
    else
    if pos3<>pos4  then {4 string position}
    begin {4 string position}
      ra_text:=copy(data1,1, pos2);
      dec_text:=copy(data1,pos2+1,99);
    end
    else
    begin {2 string position}
      ra_text:=copy(data1,1, pos1);
      if degrees then ra_text:='D'+ra_text;{convert it as degrees}
      dec_text:=copy(data1,pos1+1,99);
    end;

    ra_text_to_radians ( ra_text ,ra_new,error1); {convert ra text to head.ra0 in radians}
    dec_text_to_radians( dec_text ,dec_new,error2); {convert dec text to head.dec0 in radians}
  end;

  if ((error1=false) and (error2=false)) then
  begin
    result:=true;
    celestial_to_pixel(ra_new,dec_new, fitsX,fitsY); {ra,dec to fitsX,fitsY}
    shape_marker3_fitsX:=fitsX;
    shape_marker3_fitsY:=fitsY;
    show_marker_shape(mainwindow.shape_marker3,0 {rectangle},20,20,10,shape_marker3_fitsX, shape_marker3_fitsY);
    if sip then sipwcs:='SIP' else sipwcs:='WCS';
    mainwindow.shape_marker3.hint:=data1+#10+sipwcs+'  x='+floattostrF(shape_marker3_fitsX,ffFixed,0,1)+'  y='+ floattostrF(shape_marker3_fitsY,ffFixed,0,1); ;

  end
  else
  begin
    mainwindow.shape_marker3.visible:=false;
    result:=false;
    beep;
    exit;
  end;
end;


procedure plot_north;{draw arrow north. If head.cd1_1=0 then clear north arrow}
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

  if ((fits_file=false) or (head.cd1_1=0)) then {remove rotation indication and exit}
  begin
     mainwindow.rotation1.caption:='';
     exit;
  end;

  mainwindow.rotation1.caption:=floattostrf(head.crota2, FFfixed, 0, 2)+'°';{show rotation}


  mainwindow.image_north_arrow1.Canvas.Pen.Color := clred;

  if mainwindow.flip_horizontal1.checked then flipH:=-1 else flipH:=+1;
  if mainwindow.flip_vertical1.checked then flipV:=-1 else flipV:=+1;

  cdelt1_a:=sqrt(head.cd1_1*head.cd1_1+head.cd1_2*head.cd1_2);{length of one pixel step to the north}

  moveToex(mainwindow.image_north_arrow1.Canvas.handle,round(xpos),round(ypos),nil);
  det:=head.cd2_2*head.cd1_1-head.cd1_2*head.cd2_1;{this result can be negative !!}
  dRa:=0;
  dDec:=cdelt1_a*leng;
  x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image_north_arrow1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow line}
  dRa:=cdelt1_a*-3;
  dDec:=cdelt1_a*(leng-5);
  x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image_north_arrow1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}
  dRa:=cdelt1_a*+3;
  dDec:=cdelt1_a*(leng-5);
  x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image_north_arrow1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}
  dRa:=0;
  dDec:=cdelt1_a*leng;
  x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image_north_arrow1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}


  moveToex(mainwindow.image_north_arrow1.Canvas.handle,round(xpos),round(ypos),nil);{east pointer}
  dRa:= cdelt1_a*leng/3;
  dDec:=0;
  x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image_north_arrow1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {east pointer}
end;

procedure plot_north_on_image;{draw arrow north. If head.cd1_1=0 then clear north arrow}
var
      dra,ddec,
      cdelt1_a, det,x,y :double;
      xpos, ypos, {position arrow}
      leng, {half of length}
      wd,
      flipV, flipH : integer;
begin
  if ((fits_file=false) or (head.cd1_1=0) or (mainwindow.northeast1.checked=false)) then exit;

  xpos:=head.height div 50;
  ypos:=head.height div 50;
  leng:=head.height div 50;
  wd:=max(1,head.height div 1000);
  mainwindow.image1.canvas.Pen.Color := clred;
  mainwindow.image1.canvas.Pen.width := wd;


  if mainwindow.flip_horizontal1.checked then flipH:=-1 else flipH:=+1;
  if mainwindow.flip_vertical1.checked then flipV:=-1 else flipV:=+1;

  cdelt1_a:=sqrt(head.cd1_1*head.cd1_1+head.cd1_2*head.cd1_2);{length of one pixel step to the north}

  moveToex(mainwindow.image1.Canvas.handle,round(xpos),round(ypos),nil);
  det:=head.cd2_2*head.cd1_1-head.cd1_2*head.cd2_1;{this result can be negative !!}
  dRa:=0;
  dDec:=cdelt1_a*leng;
  x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow line}


  dRa:=cdelt1_a*-3*wd;
  dDec:=cdelt1_a*(leng-5*wd);
  x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}

  dRa:=cdelt1_a*+3*wd;
  dDec:=cdelt1_a*(leng-5*wd);
  x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}

  dRa:=0;
  dDec:=cdelt1_a*leng;
  x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}

  moveToex(mainwindow.image1.Canvas.handle,round(xpos),round(ypos),nil);{east pointer}
  dRa:= cdelt1_a*leng/3;
  dDec:=0;
  x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {east pointer}
end;


procedure plot_mount; {plot star where mount is}
var
   fitsX,fitsY: double;
begin
  if ra_mount<99 then {ra mount was specified}
  begin
    celestial_to_pixel(ra_mount,dec_mount, fitsX,fitsY);{ra,dec to fitsX,fitsY}

    shape_marker4_fitsX:=FITSX;
    shape_marker4_fitsY:=FITSY;

    show_marker_shape(mainwindow.shape_marker4,2 {activate},60,60,30{minimum},shape_marker4_fitsX, shape_marker4_fitsY);
  end;
end;


procedure plot_large_north_indicator;{draw arrow north. If head.cd1_1=0 then clear north arrow}

var
  dra,ddec,cdelt1_a, det,x,y,
  xpos, ypos   :double;

  leng, {half of length}
  wd,i,j,
  flipV, flipH : integer;
begin
  {clear}

  if ((fits_file=false) or (head.cd1_1=0) or (mainwindow.mountposition1.checked=false)) then
  begin
    mainwindow.shape_marker4.visible:=false;{could be visible from previous image}
    exit;
  end;

  mainwindow.image1.canvas.Pen.Color := clred;

  xpos:=-1+(head.width+1)/2;{fits coordinates -1}
  ypos:=-1+(head.height+1)/2;
  leng:=head.height div 3;
  wd:=max(2,head.height div 700);

  mainwindow.image1.canvas.Pen.width := wd;


  if mainwindow.flip_horizontal1.checked then flipH:=-1 else flipH:=+1;
  if mainwindow.flip_vertical1.checked then flipV:=-1 else flipV:=+1;

  cdelt1_a:=sqrt(head.cd1_1*head.cd1_1+head.cd1_2*head.cd1_2);{length of one pixel step to the north}

  moveToex(mainwindow.image1.Canvas.handle,round(xpos),round(ypos),nil);

  det:=head.cd2_2*head.cd1_1-head.cd1_2*head.cd2_1;{this result can be negative !!}
  dRa:=0;
  dDec:=cdelt1_a*leng;
  x :=-1+(head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y :=-1+ (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow line}


  dRa:=cdelt1_a*-6*wd;
  dDec:=cdelt1_a*(leng-10*wd);
  x :=-1+ (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y :=-1+ (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}

  dRa:=cdelt1_a*+6*wd;
  dDec:=cdelt1_a*(leng-10*wd);
  x :=-1+ (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y :=-1+ (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}

  dRa:=0;
  dDec:=cdelt1_a*leng;
  x :=-1+ (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y :=-1+ (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}


  moveToex(mainwindow.image1.Canvas.handle,round(xpos),round(ypos),nil);{east pointer}

  mainwindow.histogram1.canvas.rectangle(-1,-1, mainwindow.histogram1.width+1, mainwindow.histogram1.height+1);

//  mainwindow.image1.Canvas.arc(round(xpos)-size,round(ypos)-size,round(xpos)+size,round(ypos)+size,
//       round(xpos)-size,round(ypos)-size,round(xpos)-size,round(ypos)-size);{draw empty circel without changing background . That means do not cover moon with hyades}

  dRa:= cdelt1_a*leng/3;
  dDec:=0;
  x := -1+(head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := -1+(head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {east pointer}

  for i:= trunc(xpos-1) to  round(xpos+1.00001) do
  for j:= trunc(ypos-1) to  round(ypos+1.00001) do
    mainwindow.image1.Canvas.pixels[i,j]:=cllime; {perfect center indication}
  plot_mount;
end;


procedure plot_text;
var
  fontsize: double;
  posanddate, freet : boolean;
begin
  posanddate:=mainwindow.positionanddate1.checked;
  freet:=mainwindow.freetext1.checked;
  if ((fits_file=false) or ((posanddate=false) and (freet=false))) then exit;

  mainwindow.image1.Canvas.brush.Style:=bsClear;
  mainwindow.image1.Canvas.font.name:='default';
  fontsize:=max(annotation_diameter,font_size);
  mainwindow.image1.Canvas.font.size:=round(fontsize);

  mainwindow.image1.Canvas.font.color:=annotation_color; {default clyellow}

  if posanddate then
  begin
    if head.cd1_1<>0 then  mainwindow.image1.Canvas.textout(round(0.5*fontsize),head.height-round(4*fontsize),'Position[α,δ]:  '+mainwindow.ra1.text+'    '+mainwindow.dec1.text);{}

    if date_avg<>'' then
      date_to_jd(date_avg,0 {head.exposure}){convert date-AVG to jd_mid be using head.exposure=0}
    else
      date_to_jd(head.date_obs,head.exposure);{convert date-OBS to jd_start and jd_mid}

    mainwindow.image1.Canvas.textout(round(0.5*fontsize),head.height-round(2*fontsize),'Midpoint date: '+JdToDate(jd_mid)+', total exp: '+inttostr(round(head.exposure))+'s');{}
  end;
  if ((freet) and (freetext<>'')) then
    mainwindow.image1.Canvas.textout(head.width -round(fontsize) -mainwindow.image1.canvas.textwidth(freetext),head.height-round(2*fontsize),freetext);{right bottom corner, right aligned}
end;


procedure plot_constellations;
var
  fitsX,fitsY,overshoot, ra2,dec2,sep   : double;
  x1,y1,dia                             : integer;
  flip_horizontal, flip_vertical,outside: boolean;
  Save_Cursor:TCursor;
begin
  if ((fits_file=false) or (head.cd1_1=0) or (mainwindow.constellations1.checked=false)) then exit;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  {$ifdef mswindows}
   mainwindow.image1.Canvas.Font.Name :='default';
  {$endif}
  {$ifdef linux}
  mainwindow.image1.Canvas.Font.Name :='DejaVu Sans';
  {$endif}
  {$ifdef darwin} {MacOS}
  mainwindow.image1.Canvas.Font.Name :='Helvetica';
  {$endif}

  flip_vertical:=mainwindow.flip_vertical1.Checked;
  flip_horizontal:=mainwindow.flip_horizontal1.Checked;

  mainwindow.image1.Canvas.Pen.Mode:= pmXor;
  mainwindow.image1.Canvas.Pen.width :=max(1, head.height div 1000);
  mainwindow.image1.Canvas.Pen.color:= $009000;

  mainwindow.image1.Canvas.brush.Style:=bsClear;
  mainwindow.image1.Canvas.font.color:= clgray;
  mainwindow.image1.Canvas.font.size:=max(8,head.height div 120);


  for dia:=0 to length(constpos)-1 do  {constellations abreviations}
  begin
    ra2:=constpos[dia,0]*pi/12000;
    dec2:=constpos[dia,1]*pi/18000;
    ang_sep(ra2,dec2,head.ra0,head.dec0, sep);
    if   sep<pi*0.6 then
    begin
      celestial_to_pixel(ra2,dec2, fitsX,fitsY);{ra,dec to fitsX,fitsY}
      if ((fitsx>0) and (fitsx<head.width) and (fitsy>0) and (fitsy<head.height)) then {within screen}
      begin
        if flip_horizontal then x1:=round((head.width-1)-(fitsX-1)) else x1:=round(fitsX-1);
        if flip_vertical=false then y1:=round((head.height-1)-(fitsY-1)) else y1:=round(fitsY-1);
        mainwindow.image1.Canvas.textout(x1,y1,Constshortname[dia]);
      end;
    end;
  end;

  overshoot:=head.height;
  outside:=true;
  for dia:=0 to length(constellation)-1 {602} do  {constellations}
  begin
    ra2:=constellation[dia].ra*pi/12000;
    dec2:=constellation[dia].dec*pi/18000;
    ang_sep(ra2,dec2,head.ra0,head.dec0, sep);
    if   sep<pi*0.6 then
    begin
      celestial_to_pixel(ra2,dec2, fitsX,fitsY);{ra,dec to fitsX,fitsY}
      if ((fitsx>-overshoot) and (fitsx<head.width+overshoot) and (fitsy>-overshoot) and (fitsy<head.height+overshoot)) then {within screen}
      begin
        if flip_horizontal then x1:=round((head.width-1)-(fitsX-1)) else x1:=round(fitsX-1);
        if flip_vertical=false then y1:=round((head.height-1)-(fitsY-1)) else y1:=round(fitsY-1);

        if ((constellation[dia].dm=-2) or (outside)) then
          mainwindow.image1.Canvas.moveto(x1,y1)
        else
          mainwindow.image1.Canvas.lineto(x1,y1);
        TextOut(mainwindow.image1.Canvas.handle,  x1,y1, constellation[dia].bay,length(constellation[dia].bay) );{do not use here dc.textout since it will move position}
        outside:=false;
      end
      else
      outside:=true;
    end;
  end;

  Screen.Cursor := Save_cursor;    { Restore cursor}
end;


procedure plot_grid;
var
  fitsX,fitsY,step,step2,stepRA,i,j,centra,centdec,range : double;
  x1,y1,x2,y2,k                                          : integer;
  flip_horizontal, flip_vertical: boolean;
  Save_Cursor:TCursor;
  ra_text:             string;
var ra_values  : array[0..20] of double =  {nice rounded RA steps in 24 hr system}
   ((45),{step RA 03:00}
    (30),{step RA 02:00}
    (15),{step RA 01:00}
    (10),{step RA 00:40}
     (7.5),{step RA 00:30}
     (5),{step RA 00:20}
     (3.75),{step RA 00:15}
     (2.5),{step RA 00:10}
     (1.5),{step RA 00:06}
     (1.25),{step RA 00:05}
     (1),{step RA 00:04}
     (3/4),{step RA 00:03}
     (1/2),{step RA 00:02}
     (1/4),{step RA 00:01}
     (1/6),{step RA 00:00:40}
     (1/8),{step RA 00:00:30}
     (1/12),{step RA 00:00:20}
     (1/16),{step RA 00:00:15}
     (1/24),{step RA 00:00:10}
     (1/40),{step RA 00:00:06}
     (1/48));{step RA 00:00:05}

begin
  if ((fits_file=false) or (head.cd1_1=0) or (mainwindow.grid1.checked=false)) then exit;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  {$ifdef mswindows}
   mainwindow.image1.Canvas.Font.Name :='default';
  {$endif}
  {$ifdef linux}
  mainwindow.image1.Canvas.Font.Name :='DejaVu Sans';
  {$endif}
  {$ifdef darwin} {MacOS}
  mainwindow.image1.Canvas.Font.Name :='Helvetica';
  {$endif}

  flip_vertical:=mainwindow.flip_vertical1.Checked;
  flip_horizontal:=mainwindow.flip_horizontal1.Checked;

  mainwindow.image1.Canvas.Pen.Mode:= pmXor;
  mainwindow.image1.Canvas.Pen.width :=max(1,trunc(head.height/2000));
  mainwindow.image1.Canvas.Pen.color:= $909000;

  mainwindow.image1.Canvas.brush.Style:=bsClear;
  mainwindow.image1.Canvas.font.color:= clgray;
  mainwindow.image1.Canvas.font.size:=8;

  range:=head.cdelt2*sqrt(sqr(head.width/2)+sqr(head.height/2));{range in degrees, FROM CENTER}

  {calculate DEC step size}
  if range>16 then
  begin
    step:=8;{step DEC 08:00}
  end
  else
  if range>8 then
  begin
    step:=4;{step DEC 04:00}
  end
  else
  if range>4 then {image FOV about >2*4/sqrt(2) so >5 degrees}
  begin
    step:=2;{step DEC 02:00}
  end
  else
  if range>2 then
  begin
    step:=1;{step DEC 01:00}
  end
  else
  if range>1 then
  begin
    step:=0.5;{step DEC 00:30}
  end
  else
  if range>0.5 then
  begin
    step:=0.25;{step DEC 00:15}
  end
  else
  if range>0.3 then
  begin
    step:=1/6;{ 0.166666, step DEC 00:10}
  end
  else
  begin
    step:=1/12;{step DEC 00:05  }
  end;

  {calculate RA step size}
  step2:=min(45,step/(cos(head.dec0)+0.000001)); {exact value for stepRA, but not well rounded}
  k:=0;
  repeat {select nice rounded values for ra_step}
    stepRA:=ra_values[k];
    inc(k);
  until ((stepRA<=step2) or (k>=length(ra_values)));{repeat until comparible value is found in ra_values}

  {round image centers}
  centra:=stepRA*round(head.ra0*180/(pi*stepRA)); {rounded image centers}
  centdec:=step*round(head.dec0*180/(pi*step));

  {plot DEC grid}
  i:=centRA-6*stepRA;
  repeat{dec lines}
    j:=max(centDEC-6*step,-90);
    repeat
      celestial_to_pixel(i*pi/180,j*pi/180, fitsX,fitsY);{ra,dec to fitsX,fitsY}
      if flip_horizontal then x1:=round((head.width-1)-(fitsX-1)) else x1:=round(fitsX-1);
      if flip_vertical=false then y1:=round((head.height-1)-(fitsY-1)) else y1:=round(fitsY-1);


      celestial_to_pixel(i*pi/180,(j+step)*pi/180, fitsX,fitsY);{ra,dec to fitsX,fitsY}
      if flip_horizontal then x2:=round((head.width-1)-(fitsX-1)) else x2:=round(fitsX-1);
      if flip_vertical=false then y2:=round((head.height-1)-(fitsY-1)) else y2:=round(fitsY-1);

      if (  ((x1>=0) and (y1>=0) and (x1<head.width)and (y1<head.height)) or
            ((x2>=0) and (y2>=0) and (x2<head.width)and (y2<head.height)) ) then
      begin {line is partly within image1. Strictly not necessary but more secure}
        if ((abs(i-centRA)<0.00001) or (abs(j-centDEC)<0.00001)) then
        begin
          ra_text:=prepare_ra6(fnmodulo(i,360)*pi/180,' '); {24 00 00}
          if copy(ra_text,7,2)='00' then delete(ra_text,6,3);{remove 00}
          mainwindow.image1.Canvas.textout(x1,y1,ra_text+','+prepare_dec4(j*pi/180,' '));
        end;
        mainwindow.image1.Canvas.moveto(x1,y1);
        mainwindow.image1.Canvas.lineto(x2,y2);
      end;
      j:=j+step;
    until j>=min(centDEC+6*step,90);
    i:=i+stepRA;
  until ((i>=centRa+6*stepRA) or (i>=(centRA-6*stepRA)+360));


  {plot RA grid}
  j:=max(centDEC-step*6,-90);
  repeat{ra lines}
    i:=centRA-stepRA*6;
    repeat
      celestial_to_pixel(i*pi/180,j*pi/180, fitsX,fitsY);{ra,dec to fitsX,fitsY}
      if flip_horizontal then x1:=round((head.width-1)-(fitsX-1)) else x1:=round(fitsX-1);
      if flip_vertical=false then y1:=round((head.height-1)-(fitsY-1)) else y1:=round(fitsY-1);
      celestial_to_pixel((i+step)*pi/180,j*pi/180, fitsX,fitsY);{ra,dec to fitsX,fitsY}
      if flip_horizontal then x2:=round((head.width-1)-(fitsX-1)) else x2:=round(fitsX-1);
      if flip_vertical=false then y2:=round((head.height-1)-(fitsY-1)) else y2:=round(fitsY-1);

      if (  ((x1>=0) and (y1>=0) and (x1<head.width)and (y1<head.height)) or
            ((x2>=0) and (y2>=0) and (x2<head.width)and (y2<head.height)) ) then
      begin {line is partly within image1. Strictly not necessary but more secure}
        mainwindow.image1.Canvas.moveto(x1,y1);
        mainwindow.image1.Canvas.lineto(x2,y2);
      end;
      i:=i+step;
    until ((i>=centRa+stepRA*6) or (i>=(centRA-6*stepRA)+360));
    j:=j+step;
  until j>=min(centDEC+step*6,90);
  Screen.Cursor := Save_cursor;    { Restore cursor}
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


procedure Tmainwindow.Polynomial1Change(Sender: TObject);
begin
  if  (
     ((mainwindow.polynomial1.itemindex=1) and (ap_order=0) ) or {SIP polynomial selected but no data}
     ((mainwindow.polynomial1.itemindex=2) and (x_coeff[0]=0) and (y_coeff[0]=0)) {DSS polynomial selected but no data}
     ) then
   mainwindow.Polynomial1.color:=clred
   else
   mainwindow.Polynomial1.color:=cldefault;

  sip:=((ap_order>=2) and (mainwindow.Polynomial1.itemindex=1));{use sip corrections?}

end;


procedure Tmainwindow.remove_markers1Click(Sender: TObject);
begin
  plot_fits(mainwindow.image1,false,true);
end;


procedure show_marker_shape(shape: TShape; shape_type,w,h,minimum:integer; fitsX,fitsY: double);{show manual alignment shape}
var
   xf,yf,x,y : double;
   ll,tt,hh,ww     : integer;
begin

  if fits_file=false then exit;
  if ((shape_type=9{no change})
     and
     (shape.visible=false)) then
     exit;

  xF:=(fitsX-0.5)*(mainwindow.image1.width/head.width)-0.5; //inverse of  fitsx:=0.5+(0.5+xf)/(image1.width/head.width);{starts at 1}
  yF:=-(fitsY-head.height-0.5)*(mainwindow.image1.height/head.height)-0.5; //inverse of fitsy:=0.5+head.height-(0.5+yf)/(image1.height/head.height); {from bottom to top, starts at 1}

  if mainwindow.Flip_horizontal1.Checked then x:=mainwindow.image1.width-xF else x:=xF;
  if mainwindow.flip_vertical1.Checked then y:=mainwindow.image1.height-yF else y:=yF;

  if w=0 then {auto size}
  begin
  end;

  with shape do
  begin
     hh:=max(minimum,round(h*mainwindow.image1.height/head.height));
     height:=hh;
     ww:= max(minimum,round(w*mainwindow.image1.width/head.width));
     width:=ww;
     ll:=round(mainwindow.image1.left + x - width/2);
     left:=ll;
     tt:=round(mainwindow.image1.top   + y - height/2);
     top:=tt;

     if shape_type=0 then {rectangle}
     begin
       shape:=stRectangle;
       hint:='no lock';
       visible:=true;
     end
     else
     if shape_type=1 then {circle}
     begin {good lock on object}
       shape:=stcircle;
       hint:='locked';
       visible:=true;
     end
     else
     if shape_type=2 then {star}
     begin {good lock on object}
       visible:=true;
     end;
     {else keep as it is}
  end;
  if tshape(shape)=tshape(mainwindow.shape_alignment_marker1) then
    begin mainwindow.labelVar1.left:=ll+ww; mainwindow.labelVar1.top:=tt+hh; mainwindow.labelVar1.font.size:=max(hh div 4,14);  mainwindow.labelVar1.visible:=true;end
  else
  if tshape(shape)=tshape(mainwindow.shape_alignment_marker2) then
    begin mainwindow.labelCheck1.left:=ll+ww; mainwindow.labelCheck1.top:=tt+hh; mainwindow.labelCheck1.font.size:=max(hh div 4,14); mainwindow.labelCheck1.visible:=true;end
  else
  if tshape(shape)=tshape(mainwindow.shape_alignment_marker3) then
    begin mainwindow.labelThree1.left:=ll+ww; mainwindow.labelThree1.top:=tt+hh; mainwindow.labelThree1.font.size:=max(hh div 4,14); mainwindow.labelThree1.visible:=true;end;

end;


procedure zoom(mousewheelfactor:double;MousePos: TPoint);
var
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
  {$endif}

  if ( ((mainwindow.image1.width<=maxw) or (mousewheelfactor<1){zoom out}) and {increased to 65535 for Windows only. Was above 12000 unequal stretch}
       ((mainwindow.image1.width>=100 ) or (mousewheelfactor>1){zoom in})                                                                  )
  then
  begin
    {limit the mouse positions to positions within the image1}
    mousepos.x:=max(MousePos.X,mainwindow.Image1.Left);
    mousepos.y:=max(MousePos.Y,mainwindow.Image1.top);
    mousepos.x:=min(MousePos.X,mainwindow.Image1.Left+mainwindow.image1.width);
    mousepos.y:=min(MousePos.Y,mainwindow.Image1.top++mainwindow.image1.height);

    {scroll to compensate zoom}
    mainwindow.image1.Left := Round((1 - mousewheelfactor) * MousePos.X + mousewheelfactor * mainwindow.Image1.Left);
    mainwindow.image1.Top  := Round((1 - mousewheelfactor) * MousePos.Y + mousewheelfactor * mainwindow.Image1.Top);

    {zoom}
    mainwindow.image1.height:=round(mainwindow.image1.height * mousewheelfactor);
    mainwindow.image1.width:= round(mainwindow.image1.width * mousewheelfactor);

    //mainwindow.caption:=inttostr(mainwindow.image1.width)+' x '+inttostr(mainwindow.image1.height);

    {marker}
      show_marker_shape(mainwindow.shape_marker1,9 {no change in shape and hint},20,20,10{minimum},shape_marker1_fitsX, shape_marker1_fitsY);
      show_marker_shape(mainwindow.shape_marker2,9 {no change in shape and hint},20,20,10{minimum},shape_marker2_fitsX, shape_marker2_fitsY);
      show_marker_shape(mainwindow.shape_marker3,9 {no change in shape and hint},20,20,10{minimum},shape_marker3_fitsX, shape_marker3_fitsY);
      show_marker_shape(mainwindow.shape_marker4,9 {no change in shape and hint},60,60,30{minimum},shape_marker4_fitsX, shape_marker4_fitsY);

     if copy_paste then
     begin
       show_marker_shape(mainwindow.shape_paste1,0 {rectangle},copy_paste_w,copy_paste_h,0{minimum}, mouse_fitsx, mouse_fitsy);{show the paste shape}
     end;

    {reference point manual alignment}
     if mainwindow.shape_manual_alignment1.visible then {For manual alignment. Do this only when visible}
       show_marker_shape(mainwindow.shape_manual_alignment1,9 {no change in shape and hint},20,20,10,shape_fitsX, shape_fitsY);

     {photometry}
     if mainwindow.shape_alignment_marker1.visible then {For manual alignment. Do this only when visible}
       show_marker_shape(mainwindow.shape_alignment_marker1,9 {no change in shape and hint},20,20,10,shape_fitsX, shape_fitsY);
     if mainwindow.shape_alignment_marker2.visible then {For manual alignment. Do this only when visible}
       show_marker_shape(mainwindow.shape_alignment_marker2,9 {no change in shape and hint},20,20,10,shape_fitsX2, shape_fitsY2);
     if mainwindow.shape_alignment_marker3.visible then {For manual alignment. Do this only when visible}
       show_marker_shape(mainwindow.shape_alignment_marker3,9 {no change in shape and hint},20,20,10,shape_fitsX3, shape_fitsY3);
  end;
end;


procedure Tmainwindow.zoomin1Click(Sender: TObject);
begin
  zoom(1.2, TPoint.Create(Panel1.Width div 2, Panel1.Height div 2){zoom center panel1} );
end;


procedure Tmainwindow.zoomout1Click(Sender: TObject);
begin
  zoom(1/1.2, TPoint.Create(Panel1.Width div 2, Panel1.Height div 2));
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

  if mainwindow.inversemousewheel1.checked then  zoom(1.2,p) else zoom(1/1.2,p);
  Handled := True;{prevent that in win7 the combobox is moving up/down if it has focus}
end;


procedure Tmainwindow.Panel1MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  P: TPoint;
begin
  GetCursorPos(p);  {use this since in Lazarus the mousepos varies depending control under the mouse}
  p:=panel1.Screentoclient(p);
  if p.y<0 then exit; {not in image range}

  if mainwindow.inversemousewheel1.checked then  zoom(1/1.2,p) else zoom(1.2,p);
  Handled := True;{prevent that in win7 the combobox is moving up/down if it has focus}
end;


procedure Tmainwindow.show_statistics1Click(Sender: TObject);
var
   fitsX,fitsY,dum,counter,col,size,counter_median,required_size,iterations,i : integer;
   value,stepsize,median_position, most_common,mc_1,mc_2,mc_3,mc_4,
   sd,mean,median,minimum, maximum,max_counter,saturated,mad,minstep,delta,range,total_flux  : double;
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
    startx:=0;stopX:=head.width-1;
    starty:=0;stopY:=head.height-1;
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

  minstep:=99999;
  {measure the median of the suroundings}

  for col:=0 to head.naxis3-1 do  {do all colours}
  begin
    local_sd(startX+1 ,startY+1, stopX-1,stopY-1{within rectangle},col,img_loaded, {var} sd,mean,iterations);{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}


    most_common:=mode(img_loaded,col,startx,stopX,starty,stopY,32000);

    {median sampling and min , max}
    max_counter:=1;
    median:=0;
    saturated:=0;
    minimum:=999999999;
    maximum:=0;
    counter:=0;
    counter_median:=0;
    total_flux:=0;
    for fitsY:=startY+1 to stopY-1 do {within rectangle}
    for fitsX:=startX+1 to stopX-1 do
    begin
      value:=img_loaded[col,fitsX+1,fitsY+1];
      median_position:=counter*stepsize;
      total_flux:=total_flux+value; {total flux}
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
      if col=0 then
      begin
        delta:=abs(value-most_common);
        if ((delta>0.00000001){not the same} and (delta<minstep)) then minstep:=delta;
      end;
    end;{filter outliers}
    median:=smedian(median_array,counter_median);
    total_flux:=total_flux-counter*median; {total flux above background}

    for i:=0 to counter_median do median_array[i]:=abs(median_array[i] - median);{fill median_array with offsets}
    mad:=smedian(median_array,counter_median); //median absolute deviation (MAD)


    if col=0 then range:=maximum-minimum;

    if head.naxis3>1 then if col=0 then info_message:=info_message+'Red:'+#10;
    if col=1 then info_message:=info_message+#10+#10+'Green:'+#10;
    if col=2 then info_message:=info_message+#10+#10+'Blue:'+#10;

    info_message:=info_message+  'x̄ :    '+floattostrf(mean,ffgeneral, 5, 5)+'   (sigma-clip iterations='+inttostr(iterations)+')'+#10+             {mean}
                                 'x̃  :   '+floattostrf(median,ffgeneral, 5, 5)+#10+ {median}
                                 'Mo :  '+floattostrf(most_common,ffgeneral, 5, 5)+#10+
                                 'σ :   '+floattostrf(sd,ffgeneral, 4, 4)+'   (sigma-clip iterations='+inttostr(iterations)+')'+#10+               {standard deviation}
                                 'σ_2:   '+floattostrf(get_negative_noise_level(img_loaded,col,startx,stopX,starty,stopY,most_common),ffgeneral, 4, 4)+#10+
                                 'mad:   '+floattostrf(mad,ffgeneral, 4, 4)+#10+
                                 'm :   '+floattostrf(minimum,ffgeneral, 5, 5)+#10+
                                 'M :   '+floattostrf(maximum,ffgeneral, 5, 5)+ '  ('+inttostr(round(max_counter))+' x)'+#10+
                                 'Flux: '+floattostrf(total_flux,ffExponent, 3, 2)+#10+
                                 '≥64E3 :  '+inttostr(round(saturated));
  end;
  if ((abs(stopX-startx)>=head.width-1) and (most_common<>0){prevent division by zero}) then
  begin
    mc_1:=mode(img_loaded,0,          0{x1},      50{x2},           0{y1},       50{y2},32000);{for this area get most common value equals peak in histogram}
    mc_2:=mode(img_loaded,0,          0{x1},      50{x2},head.height-1-50{y1},head.height-1{y2},32000);
    mc_3:=mode(img_loaded,0,head.width-1-50{x1},head.width-1{x2},head.height-1-50{y1},head.height-1{y2},32000);
    mc_4:=mode(img_loaded,0,head.width-1-50{x1},head.width-1{x2},           0{y1},50       {y2},32000);

    info_message:=info_message+#10+#10+'Vignetting [Mo corners/Mo]: '+inttostr(round(100*(1-(mc_1+mc_2+mc_3+mc_4)/(most_common*4))))+'%';
  end;

  info_message:=info_message+#10+#10+'Bit depth data: '+inttostr(round(ln(range/minstep)/ln(2)));{bit range}


  info_message:=info_message+#10+#10+#10+'Legend: '+#10+
                                            'x̄ = mean background | x̃  = median background | '+
                                            'Mo = mode or most common pixel value or peak histogram, so the best estimate for the background mean value | '+
                                            'σ =  standard deviation background using mean and sigma clipping| ' +
                                            'σ_2 = standard deviation background using values below Mo only | '+
                                            'mad = median absolute deviation | '+
                                            'm = minimum value image | M = maximum value image | '+
                                            'Flux = total flux above median background | '+
                                            '≥64E3 = number of values equal or above 64000';

  case  QuestionDlg (pchar('Statistics within rectangle '+inttostr(stopX-1-startX)+' x '+inttostr(stopY-1-startY) ),pchar(info_message),mtCustom,[mrYes,'Copy to clipboard?', mrNo, 'No', 'IsDefault'],'') of
           mrYes: Clipboard.AsText:=info_message;
  end;


  median_array:=nil;{free mem}

  Screen.Cursor:=Save_Cursor;
end;


procedure update_statusbar_section5;{update section 5 with image dimensions in degrees}
begin
  if head.cdelt2<>0 then
  begin
    mainwindow.statusbar1.panels[6].text:=floattostrF(head.width*abs(head.cdelt2),ffFixed,0,2)+' x '+floattostrF(head.height*abs(head.cdelt2),ffFixed,0,2)+' °';{give image dimensions and bit per pixel info}
    stackmenu1.search_fov1.text:=floattostrF(head.height*abs(head.cdelt2),ffFixed,0,2); {negative head.cdelt2 are produced by PI}
  end
  else mainwindow.statusbar1.panels[6].text:='';
end;


function fits_file_name(inp : string): boolean; {fits file name?}
begin
  inp:=uppercase(extractfileext(inp));
  result:=((inp='.FIT') or (inp='.FITS') or (inp='.FTS') or (inp='.WCS') or (inp='.WCSS'));{wcs for telescope tab}
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
  if mainwindow.deepsky_annotation1.enabled=yes then exit;{no need to update}

  mainwindow.annotate_with_measured_magnitudes1.enabled:=yes;{enable menu}
  mainwindow.annotate_unknown_stars1.enabled:=yes;{enable menu}
  mainwindow.variable_star_annotation1.enabled:=yes;{enable menu}
  mainwindow.annotate_minor_planets1.enabled:=yes;{enable menu}
  mainwindow.hyperleda_annotation1.enabled:=yes;{enable menu}
  mainwindow.deepsky_annotation1.enabled:=yes;{enable menu}
  mainwindow.star_annotation1.enabled:=yes;{enable menu}
  mainwindow.hyperleda_annotation1.enabled:=yes;{enable menu}
  mainwindow.deepsky_annotation1.enabled:=yes;{enable menu}
  mainwindow.calibrate_photometry1.enabled:=yes;{enable menu}
  mainwindow.sqm1.enabled:=yes;{enable menu}
  mainwindow.add_marker_position1.enabled:=yes;{enable popup menu}
  mainwindow.measuretotalmagnitude1.enabled:=yes;{enable popup menu}
 // mainwindow.writeposition1.enabled:=yes;{enable popup menu}
  mainwindow.writepositionshort1.enabled:=yes;{enable popup menu}
  mainwindow.Copyposition1.enabled:=yes;{enable popup menu}
  mainwindow.Copypositionindeg1.enabled:=yes;{enable popup menu}
  mainwindow.simbad_query1.enabled:=yes;{enable popup menu}
  mainwindow.aavso_chart1.enabled:=yes;{enable popup menu}
  mainwindow.gaia_star_position1.enabled:=yes;{enable popup menu}
  mainwindow.import_auid1.enabled:=yes;{enable popup menu}
  mainwindow.sip1.enabled:=yes; {allow adding sip coefficients}

  stackmenu1.focallength1Exit(nil); {update output calculator}
end;


procedure update_menu(fits :boolean);{update menu if fits file is available in array or working from image1 canvas}
begin
  mainwindow.Saveasfits1.enabled:=fits; {only allow saving images}
  mainwindow.updown1.visible:=((last_extension=false) or (extend_type>0));

  if ((last_extension=true) and (extend_type=0) and  (mainwindow.pagecontrol1.showtabs {do it only when necessary to avoid blink})) then
  begin
    mainwindow.pagecontrol1.showtabs:=false;{hide tabs assuming no tabel extension}
    mainwindow.pagecontrol1.Tabindex:=0;{show first tab}
  end;

  if fits<>mainwindow.data_range_groupBox1.Enabled then  {menu requires update}
  begin
    mainwindow.data_range_groupBox1.Enabled:=fits;
    mainwindow.Export_image1.enabled:=fits;
    mainwindow.SaveasJPGPNGBMP1.Enabled:=fits;

    mainwindow.imageinspection1.enabled:=fits;
    mainwindow.ShowFITSheader1.enabled:=fits;
    mainwindow.demosaic_Bayermatrix1.Enabled:=fits;
    mainwindow.autocorrectcolours1.Enabled:=fits;
    mainwindow.removegreenpurple1.enabled:=fits;
    mainwindow.bin_2x2menu1.Enabled:=fits;
    mainwindow.bin_3x3menu1.Enabled:=fits;
    mainwindow.stretch_draw1.Enabled:=fits;
    mainwindow.stretch_draw_fits1.Enabled:=fits;

    mainwindow.CropFITSimage1.Enabled:=fits;

    mainwindow.stretch1.enabled:=fits;
    mainwindow.inversimage1.enabled:=fits;
    mainwindow.rotate1.enabled:=fits;

    mainwindow.minimum1.enabled:=fits;
    mainwindow.maximum1.enabled:=fits;
    mainwindow.range1.enabled:=fits;
    mainwindow.min2.enabled:=fits;
    mainwindow.max2.enabled:=fits;

    mainwindow.convertmono1.enabled:=fits;

    mainwindow.solve_button1.enabled:=fits;
    mainwindow.astrometric_solve_image1.enabled:=fits;

    stackmenu1.tab_Pixelmath1.enabled:=fits;
    stackmenu1.tab_Pixelmath2.enabled:=fits;
  end;{menu change}

  fits_file:=fits;{update}
  mainwindow.error_label1.visible:=(fits=false);

  mainwindow.SaveFITSwithupdatedheader1.Enabled:=((fits) and (fits_file_name(filename2)) and (fileexists(filename2)));{menu disable, no file available to update header}
  mainwindow.saturation_factor_plot1.enabled:=head.naxis3=3;{colour};
  mainwindow.Polynomial1Change(nil);{update color}

  update_menu_related_to_solver((fits) and (head.cd1_1<>0));
  stackmenu1.resize_factor1Change(nil);{update dimensions binning menu}
  stackmenu1.test_pattern1.Enabled:=head.naxis3=1;{mono}

  stackmenu1.focallength1.Text:=floattostrf(focallen,ffgeneral, 4, 4);
  stackmenu1.pixelsize1.text:=floattostrf(xpixsz{*XBINNING},ffgeneral, 4, 4);
  stackmenu1.binning1.caption:=inttostr(head.width)+'x'+inttostr(head.height)+' pixels, binned '+floattostrf(Xbinning,ffgeneral,0,0)+'x'+floattostrf(Ybinning,ffgeneral,0,0);
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

  save_settings2;

  OldCursor := Screen.Cursor;
  Screen.Cursor:= crHourGlass;

  {solve internal}
  mainwindow.caption:='Solving.......';
  save1.Enabled:=solve_image(img_loaded,false {get hist, is already available});{match between loaded image and star database}
  if head.cd1_1<>0 then
  begin
    mainwindow.ra1.text:=prepare_ra(head.ra0,' ');{show center of image}
    mainwindow.dec1.text:=prepare_dec(head.dec0,' ');
    {$IfDef Darwin}// {MacOS}
      //ra1change(nil);{OSX doesn't trigger an event, so ra_label is not updated}
      //mainwindow.dec1change(nil);
    {$ENDIF}
    plot_north;
    plot_north_on_image;
    plot_large_north_indicator;
    plot_grid;
    plot_constellations;
    plot_text;

    image1.Repaint;{show north-east indicator}

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
  if flip_vertical1.checked=false then stopY:=0 else stopY:=head.height-1;
  startx:=0;
  stopX:=head.width-1;
  mainwindow.CropFITSimage1Click(nil);
 end;


procedure Tmainwindow.remove_below1Click(Sender: TObject);
begin
  {calculate in array coordinates}
  {startY is already defined by mousedown}
  if flip_vertical1.checked then stopY:=0 else stopY:=head.height-1;
  startx:=0;
  stopX:=head.width-1;
  mainwindow.CropFITSimage1Click(nil);
end;

procedure Tmainwindow.remove_left1Click(Sender: TObject);
begin
  {calculate in array coordinates}
  starty:=0;{no change in y}
  stopY:=head.height-1;
  {startx is already defined by mousedown}
  if flip_horizontal1.checked then stopX:=0 else stopX:=head.width-1;
  mainwindow.CropFITSimage1Click(nil);
end;

procedure Tmainwindow.remove_right1Click(Sender: TObject);
begin
  {calculate in array coordinates}
  starty:=0;{no change in y}
  stopY:=head.height-1;
  {startx is already defined by mousedown}
  if flip_horizontal1.checked=false then stopX:=0 else stopX:=head.width-1;
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

function extract_raw_colour_to_file(filename7,filtern: string; xp,yp : integer) : string;{extract raw colours and write to file}
var
  img_temp11 : image_array;
  FitsX, fitsY,w,h,xp2,yp2,pattern,pattern2  : integer;
  ratio                             : double;
  get_green                         : boolean;
  val                               : single;
begin
  if load_fits(filename7,true {light},true,true {update memo},0,head,img_loaded)=false then
  begin
    beep; result:='';
    exit;
  end;

  if ((pos('TR',head.filter_name)=0) and (pos('TG',head.filter_name)=0) and (pos('TB',head.filter_name)=0) and (head.naxis3=1)) then
  begin

    ratio:=0.5;
    w:=trunc(head.width/2);  {half size}
    h:=trunc(head.height/2);

    setlength(img_temp11,1,w,h);

    pattern:=get_demosaic_pattern; {analyse pattern}
    get_green:=false;
    if filtern='TR' then {red}
    begin
      case pattern of
         0: begin xp:=2; yp:=1; end;{'GRBG'}
         1: begin xp:=2; yp:=2; end;{'BGGR'}
         2: begin xp:=1; yp:=1; end;{'RGGB'}
         3: begin xp:=1; yp:=2; end;{'GBRG'}
      end;
    end
    else
    if filtern='TB' then {blue}
    begin
      case pattern of
         0: begin xp:=1; yp:=2; end;{'GRBG'}
         1: begin xp:=1; yp:=1; end;{'BGGR'}
         2: begin xp:=2; yp:=2; end;{'RGGB'}
         3: begin xp:=2; yp:=1; end;{'GBRG'}
      end;
    end
    else
    if filtern='TG' then {green}
    begin
      get_green:=true;
      case pattern of
         0: begin xp:=1; yp:=1; xp2:=2; yp2:=2; end;{'GRBG'}
         1: begin xp:=2; yp:=1; xp2:=1; yp2:=2; end;{'BGGR'}
         2: begin xp:=2; yp:=1; xp2:=1; yp2:=2; end;{'RGGB'}
         3: begin xp:=1; yp:=1; xp2:=2; yp2:=2; end;{'GBRG'}
      end;
    end;

    {info message}
    if pos('BOT',roworder)>0 then {'BOTTOM-UP'= lower-left corner first in the file. or 'TOP-DOWN'= top-left corner first in the file.(default)}
    begin {top-down keyword,  flip in the message the patterns upside down. So GRBG becomes BGGR}
      if pattern=0 then pattern2:=1 else
      if pattern=1 then pattern2:=0 else
      if pattern=2 then pattern2:=3 else
      if pattern=3 then pattern2:=2;
    end
    else
    begin  {normal no keyword or TOP-DOWN keyword}
      pattern2:=pattern;
    end;

    case pattern2 of
       0: begin memo2_message('GRBG => '+filtern[2]); end;{'GRBG'}
       1: begin memo2_message('BGGR => '+filtern[2]); end;{'BGGR'}
       2: begin memo2_message('RGGB => '+filtern[2]); end;{'RGGB'}
       3: begin memo2_message('GBRG => '+filtern[2]); end;{'GBRG'}
    end;

    {extract}
    for fitsY:=0 to h-1 do
      for fitsX:=0 to w-1  do
      begin
        val:=img_loaded[0,fitsx*2+xp-1,fitsY*2+yp-1];
        if get_green then val:=(val+img_loaded[0,fitsx*2+xp2-1,fitsY*2+yp2-1])/2; {add second green pixel}
        img_temp11[0,fitsX,fitsY]:=val;
      end;

    head.width:=w;
    head.height:=h;

    update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
    update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);


    update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
    update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);



    if head.crpix1<>0 then begin head.crpix1:=head.crpix1*ratio; update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,head.crpix1);end;
    if head.crpix2<>0 then begin head.crpix2:=head.crpix2*ratio; update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,head.crpix2);end;

    if head.cdelt1<>0 then begin head.cdelt1:=head.cdelt1/ratio; update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,head.cdelt1);end;
    if head.cdelt2<>0 then begin head.cdelt2:=head.cdelt2/ratio; update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,head.cdelt2);end;

    if head.cd1_1<>0 then
    begin
      head.cd1_1:=head.cd1_1/ratio;
      head.cd1_2:=head.cd1_2/ratio;
      head.cd2_1:=head.cd2_1/ratio;
      head.cd2_2:=head.cd2_2/ratio;
      update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_1);
      update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_2);
      update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_1);
      update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_2);
    end;

    XBINNING:=XBINNING/ratio;
    YBINNING:=YBINNING/ratio;
    update_float  ('XBINNING=',' / Binning factor in width                         ' ,XBINNING);
    update_float  ('YBINNING=',' / Binning factor in height                        ' ,YBINNING);


    if XPIXSZ<>0 then
    begin
      XPIXSZ:=XPIXSZ/ratio;
      YPIXSZ:=YPIXSZ/ratio;
      update_float('XPIXSZ  =',' / Pixel width in microns (after binning)          ' ,XPIXSZ);{note: comment will be never used since it is an existing keyword}
      update_float('YPIXSZ  =',' / Pixel height in microns (after binning)         ' ,YPIXSZ);
      update_float('PIXSIZE1=',' / Pixel width in microns (after binning)          ' ,XPIXSZ);
      update_float('PIXSIZE2=',' / Pixel height in microns (after binning)         ' ,YPIXSZ);

    end;

    add_text   ('HISTORY   ','One raw colour extracted.');

    update_text   ('FILTER  =',#39+filtern+#39+'           / Filter name                                    ');
    img_loaded:=img_temp11;
    result:=ChangeFileExt(FileName7,'_'+filtern+'.fit');
    if save_fits(img_loaded,result,16,true{overwrite}) =false then result:='';
    img_temp11:=nil;
  end
  else
  begin
    if head.naxis3>1 then memo2_message('Skipped COLOUR image '+ filename7+', Raw red, green or blue pixel extraction is only possible for raw images.')
    else
    memo2_message('Skipped image '+ filename7+', FILTER indicates earlier extraction!');
  end;
end;


procedure split_raw(xp,yp : integer; filtern: string);{extract one of the Bayer matrix pixels}
var
  Save_Cursor : TCursor;
  dobackup    : boolean;
  i           : integer;

begin
  with mainwindow do
  begin
    OpenDialog1.Title := 'Select multiple RAW fits files to extract Bayer matrix position '+filtern+' from them';
    OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
    opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';

    fits_file:=true;
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
          Application.ProcessMessages;
          if esc_pressed then begin Screen.Cursor := Save_Cursor;  { Always restore to normal } exit; end;

          if extract_raw_colour_to_file(Strings[I] {filename}, filtern,xp,yp )=''{new file name} then beep;
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
      application.processmessages;{show file selection}
      {load image}
      if load_fits(opendialog1.filename,true {light},true,true {update memo},0,head,img_loaded) then
      begin
        if ((head.naxis3=1) and (mainwindow.preview_demosaic1.checked)) then demosaic_advanced(img_loaded);{demosaic and set levels}
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

    for k:=0 to head.naxis3-1 do {do all colors}
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


function floattostr6(x:double):string;{float to string with 6 decimals}
begin
  str(x:0:6,result);
end;


function floattostr4(x:double):string;
begin
  str(x:0:4,result);
end;


function floattostrE(x:double):string;
begin
  str(x,result);
end;


function inttostr5(x:integer):string;{always 5 digit}
begin
  str(x:5,result);
end;


function strtofloat2(s:string): double;{works with either dot or komma as decimal separator}
var
  error1:integer;
begin
  s:=StringReplace(s,',','.',[]); {replaces komma by dot}
  s:=trim(s); {remove spaces}
  val(s,result,error1);
  if error1<>0 then result:=0;
end;


function strtofloat1(s:string): double;{string to float, error tolerant}
var
  error1:integer;
begin
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
   str(w:0,s);
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


function prepare_dec4(decx:double;sep:string):string; {radialen to text  format 90d 00 }
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
  result:=sign+b+sep+leadingzero(m);
end;


function prepare_ra6(rax:double; sep:string):string; {radialen to text, format 24: 00 00}
 var
   h,m,s  :integer;
 begin   {make from rax [0..pi*2] a text in array bericht. Length is 8 long}
  rax:=rax+pi/(24*60*60); {add half second to get correct rounding and not 7:60 results as with round}
  rax:=rax*12/pi; {make hours}
  h:=trunc(rax);
  m:=trunc((rax-h)*60);
  s:=trunc((rax-h-m/60)*3600);
  result:=leadingzero(h)+sep+leadingzero(m)+' '+leadingzero(s);
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
  prepare_ra:=leadingzero(h)+sep+leadingzero(m)+' '+leadingzero(s)+'.'+ansichar(ds+48);
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
  prepare_dec:=sign+leadingzero(g)+sep+leadingzero(m)+' '+leadingzero(s);
end;


function prepare_ra8(rax:double; sep:string):string; {radialen to text, format 24: 00 00.00 }
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
  result:=b+sep+leadingzero(m)+'  '+leadingzero(s)+'.'+leadingzero(ds);
end;


Function prepare_dec2(decx:double; sep:string):string; {radialen to text, format 90d 00 00.1}
 var
   B,ds2 : String[5];
   g,m,s,ds :integer;
   sign   : ansichar;
begin {make from decx [-pi/2..pi/2] a text in array bericht. Length is 10 long}
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
  head.cd1_1:=head.cdelt1*cos(head.crota2*pi/180); {note 2013 should be head.crota1 if skewed}
  if head.cdelt1>=0 then sign:=+1 else sign:=-1;
  head.cd1_2:=abs(head.cdelt2)*sign*sin(head.crota2*pi/180);{note 2013 should be head.crota1 if skewed}
  if head.cdelt2>=0 then sign:=+1 else sign:=-1;
  head.cd2_1:=-abs(head.cdelt1)*sign*sin(head.crota2*pi/180);
  head.cd2_2:= head.cdelt2*cos(head.crota2*pi/180);
end;


procedure new_to_old_WCS;{convert new style FITsS to old style}
var
   sign  : integer;
begin
  { convert to old WCS. Based on draft 1988 , do not use conversion article Alain Klotz, give sometimes zero CROTA}
  if (head.cd1_1*head.cd2_2-head.cd1_2*head.cd2_1)>=0 then sign:=+1 else sign:=-1;

  head.cdelt1:=sqrt(sqr(head.cd1_1)+sqr(head.cd2_1))*sign;{if no old wcs header use head.cd2_2 of new WCS style for pixel size}
  head.cdelt2:=sqrt(sqr(head.cd1_2)+sqr(head.cd2_2));{if no old wcs header use head.cd2_2 of new WCS style for pixel size}

  head.crota1:= +arctan2(sign*head.cd1_2,head.cd2_2)*180/pi;
  head.crota2:= -arctan2(head.cd2_1,sign*head.cd1_1)*180/pi;  //  crota2old := (atn_2(sign*head.cd1_1,head.cd2_1)-pi/2)*180/pi;
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
     0: begin offsetx:=0; offsety:=0; end;{'GRBG'}
     1: begin offsetx:=0; offsety:=1; end;{'BGGR'}
     2: begin offsetx:=1; offsety:=0; end;{'RGGB'}
     3: begin offsetx:=1; offsety:=1; end;{'GBRG'}
     else exit;
  end;

  setlength(img_temp2,3,head.width,head.height);{set length of image array color}

  for y := 1 to head.height-2 do   {-2 = -1 -1}
  begin
    for x:=1 to head.width-2 do
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
  head.naxis3:=3;{now three colors. Header string will be updated by saving or calling procedure update_header_for_colour}
  head.naxis:=3; {from 2 to 3 dimensions. Header string will be updated by saving or calling procedure update_header_for_colour}
end;


procedure demosaic_x_trans(var img:image_array);{make from Fuji X-trans three colors}
var
    X,Y,x2,y2,xpos,ypos,xpos6,ypos6: integer;
    red,blue  : single;
    img_temp2 : image_array;
begin

  setlength(img_temp2,3,head.width,head.height);{set length of image array color}


  for y := 2 to head.height-2 do   {-2 = -1 -1}
  begin
    for x:=2 to head.width-2 do
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
  head.naxis3:=3;{now three colors. Header string will be updated by saving or calling procedure update_header_for_colour}
  head.naxis:=3; {from 2 to 3 dimensions. Header string will be updated by saving or calling procedure update_header_for_colour}
end;

procedure demosaic_astrosimple(var img:image_array;pattern: integer);{Spread each colour pixel to 2x2. Works well for astro oversampled images. Idea by Han.k}
var
    X,Y,offsetx, offsety: integer;
    red,green_odd,green_even,blue : boolean;
    img_temp2 : image_array;
    value     : single;
begin
  case pattern  of
     0: begin offsetx:=0; offsety:=0; end;{'GRBG'}
     1: begin offsetx:=0; offsety:=1; end;{'BGGR'}
     2: begin offsetx:=1; offsety:=0; end;{'RGGB'}
     3: begin offsetx:=1; offsety:=1; end;{'GBRG'}
     else exit;
  end;

  setlength(img_temp2,3,head.width,head.height);{set length of image array color}

  for y := 0 to head.height-2 do   {-2 = -1 -1}
    for x:=0 to head.width-2 do
  begin {clear green}
      img_temp2[1,x,y]:=0;
  end;

  for y := 0 to head.height-2 do   {-2 = -1 -1}
  begin
    for x:=0 to head.width-2 do
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
  head.naxis3:=3;{now three colors. Header string will be updated by saving or calling procedure update_header_for_colour}
  head.naxis:=3; {from 2 to 3 dimensions. Header string will be updated by saving or calling procedure update_header_for_colour}
end;

{not used}
procedure demosaic_astrosimplebayercombined(var img:image_array;pattern: integer);{Spread each colour pixel to 2x2. Works well for astro oversampled images. Idea by Han.k}
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
     else exit;
  end;

  setlength(img_temp2,3,head.width,head.height);{set length of image array color}

  for y := 0 to head.height-2 do   {-2 = -1 -1}
    for x:=0 to head.width-2 do
  begin {clear green}
      img_temp2[1,x,y]:=0;
  end;

  for y := 0 to head.height-2 do   {-2 = -1 -1}
  begin
    for x:=0 to head.width-2 do
    begin
      try
      green_even:= ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );{even(i) function is odd(i+1), even is here for array position not fits position}
      green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
      red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
      blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );

      value:=img[0,x,  y  ];

      if green_even then
      begin
        value:=value/2;
        img_temp2[1,x,y]:=img_temp2[1,x,y]+value;
        img_temp2[1,x-1,y]:=img_temp2[1,x-1,y]+value;
        img_temp2[1,x,y-1]:=img_temp2[1,x,y-1]+value;
        img_temp2[1,x-1,y-1]:=img_temp2[1,x-1,y-1]+value;
      end
      else
      if green_odd then
      begin
        value:=value/2;
        img_temp2[1,x,y]:=img_temp2[1,x,y]+value;
        img_temp2[1,x+1,y]:=img_temp2[1,x+1,y]+value;
        img_temp2[1,x,y+1]:=img_temp2[1,x,y+1]+value;
        img_temp2[1,x+1,y+1]:=img_temp2[1,x+1,y+1]+value;
      end
      else

      if red then
      begin
        img_temp2[0,x,y]:=value;
        img_temp2[0,x+1,y]:=value;
        img_temp2[0,x,y-1]:=value;
        img_temp2[0,x+1,y-1]:=value;
      end
      else
      if blue then
      begin
        img_temp2[2,x,y]:=value;
        img_temp2[2,x-1,y]:=value;
        img_temp2[2,x,y+1]:=value;
        img_temp2[2,x-1,y+1]:=value;
      end;
      except
      end;

    end;{x loop}
  end;{y loop}
  img:=img_temp2;
  img_temp2:=nil;{free temp memory}
  head.naxis3:=3;{now three colors. Header string will be updated by saving or calling procedure update_header_for_colour}
  head.naxis:=3; {from 2 to 3 dimensions. Header string will be updated by saving or calling procedure update_header_for_colour}
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
     else exit;
  end;
  setlength(img_temp2,3,head.width,head.height);{set length of image array color}
  {calculate mean background value}
  count:=0;
  bg:=0;
  for y:= 10 to (head.height-10) div 100  do
  for x:=10 to (head.width-10) div 100 do
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

  for y := 1 to head.height-2 do   {-2 = -1 -1}
  begin
    for x:=1 to head.width-2 do
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
  head.naxis3:=3;{now three colors. Header string will be updated by saving or calling procedure update_header_for_colour}
  head.naxis:=3; {from 2 to 3 dimensions. Header string will be updated by saving or calling procedure update_header_for_colour}
end;


procedure demosaic_astroC_bilinear_interpolation(var img:image_array;saturation {saturation point}, pattern: integer);{make from sensor bayer pattern the three colors}
var
    X,Y,offsetx, offsety, counter,fitsX,fitsY,x2,y2,sat_counter: integer;
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
     else exit;
  end;

  setlength(img_temp2,3,head.width,head.height);{set length of image array color}

  bg:=0;
  counter:=0;{prevent divide by zero for fully saturated images}

  for y := 1 to head.height-2 do   {-2 = -1 -1}
  begin
    for x:=1 to head.width-2 do
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
  {correct colour saturated pixels }

    bg:=bg/counter; {background}
    sat_counter:=0;
    for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1 do
    if img_temp2[1,fitsX,fitsY]=$FFFFFF {marker saturated} then
    begin
      colred:=0;
      colgreen:=0;
      colblue:=0;
      counter:=0;
      inc(sat_counter);
      luminance:=img_temp2[0,fitsX,fitsY];
      luminance:=luminance-bg;{luminance above background}
      begin
        for y:=-step to step do
        for x:=-step to step do
        begin
           x2:=fitsX+x;
           y2:=fitsY+y;


           if ((x2>=0) and (x2<head.width) and (y2>=0) and (y2<head.height) ) then {within image}
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
    for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1 do
    begin
      img[0,fitsX  ,  fitsY  ]:=saturation;
      img[1,fitsX  ,  fitsY  ]:=saturation;
      img[2,fitsX  ,  fitsY  ]:=saturation;
    end;
  end;
  if sat_counter/(head.width*head.height)>0.1 then memo2_message('█ █ █ █ █ █  More than 10% of the image is saturated and will give poor results!! Try demosaic method AstroSimple and exposure shorter next time. █ █ █ █ █ █ ');
  img_temp2:=nil;{free temp memory}
  head.naxis3:=3;{now three colors. Header string will be updated by saving or calling procedure update_header_for_colour}
  head.naxis:=3; {from 2 to 3 dimensions. Header string will be updated by saving or calling procedure update_header_for_colour}
end;


procedure preserve_colour_saturated_bayer(img: image_array);{for bayer matrix}
var
    fitsX,fitsY,w,h : integer;
begin
  Application.ProcessMessages;
  if esc_pressed then begin exit;end;

  w:=trunc(head.width/2);  {half size}
  h:=trunc(head.height/2);

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
  if pos('BOT',roworder)>0 then
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
  if stackmenu1.bayer_pattern1.Text='' then memo2_message('█ █ █ █ █ █ Setting required. Please test and set Bayer pattern in tab "Stack method"! █ █ █ █ █ █ ');
  if pos('AstroC',stackmenu1.demosaic_method1.text)<>0  then
  begin
    if head.datamax_org>16384 then demosaic_astroC_bilinear_interpolation(img,65535 div 2,get_demosaic_pattern){16 bit image. Make from sensor bayer pattern the three colors}
    else
    if head.datamax_org>4096 then demosaic_astroC_bilinear_interpolation(img,16383 div 2,get_demosaic_pattern){14 bit image. Make from sensor bayer pattern the three colors}
    else
    demosaic_astroC_bilinear_interpolation(img,4095 div 2,get_demosaic_pattern){12 bit image. Make from sensor bayer pattern the three colors}
  end
  else
  if pos('Simple',stackmenu1.demosaic_method1.text)<>0  then {}
    demosaic_astrosimple(img,get_demosaic_pattern){make from sensor bayer pattern the three colors}
  else
  if pos('AstroM',stackmenu1.demosaic_method1.text)<>0  then {}
    demosaic_astroM_bilinear_interpolation(img,get_demosaic_pattern){make from sensor bayer pattern the three colors}
  else
  if pos('X-',stackmenu1.bayer_pattern1.Text)<>0  then {}
    demosaic_x_trans(img){make from Fuji X-trans three colors}
  else
  demosaic_bilinear_interpolation(img,get_demosaic_pattern);{use Bilinear interpolation. Make from sensor bayer pattern the three colors}
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
    smart_colour_smooth(img,strtofloat2(stackmenu1.osc_smart_smooth_width1.text),strtofloat2(stackmenu1.osc_smart_colour_sd1.text),stackmenu1.osc_preserve_r_nebula1.checked,false {get  hist});{histogram doesn't needs an update}
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

procedure show_shape_manual_alignment(index: integer);{show the marker on the reference star}
var
  X,Y :double;
begin
  X:=strtofloat2(stackmenu1.listview1.Items.item[index].subitems.Strings[L_X]);
  Y:=strtofloat2(stackmenu1.listview1.Items.item[index].subitems.Strings[L_Y]);
  show_marker_shape(mainwindow.shape_manual_alignment1, 1 {circle, assume a good lock},20,20,10 {minimum size},X,Y);
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

  {create bitmap}
  bitmap := TBitmap.Create;
  try
    with bitmap do
    begin
      width := head.width;
      height := head.height;
        // Unclear why this must follow width/height to work correctly.
        // If PixelFormat precedes width/height, bitmap will always be black.
      bitmap.PixelFormat := pf24bit;
    end;
    except;
  end;

  sat_factor:=1-mainwindow.saturation_factor_plot1.position/10;


  cblack:=mainwindow.minimum1.position;
  cwhite:=mainwindow.maximum1.position;
  if cwhite<=cblack then cwhite:=cblack+1;

  for i:=0 to head.height-1 do
  begin
    pixelrow := Bitmap.ScanLine[(head.height-1)-i];{head.height-1)-i, FITS count from bottom, windows from top}
    for j:=0 to head.width-1 do
    begin

      col:=round(img_loaded[0,j,i]);
      colrr:=(col-cblack)/(cwhite-cblack);{scale to 1}

      if head.naxis3>=2 then {at least two colours}
      begin
        col:=round(img_loaded[1,j,i]);
        colgg:=(col-cblack)/(cwhite-cblack);{scale to 1}
      end
      else
      colgg:=colrr;

      if head.naxis3>=3 then {at least three colours}
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
  img.width:=round(img.height*head.width/head.height); {lock image aspect always for case a image with a different is clicked on in stack menu}


  if img=mainwindow.image1 then {plotting to mainwindow?}
  begin
    {next two could be written more efficient using previous bitmap}
    if mainwindow.Flip_horizontal1.Checked then mainwindow.Flip_horizontal1Click(nil);
    if mainwindow.flip_vertical1.Checked then mainwindow.flip_vertical1Click(nil);

    plot_north; {draw arrow or clear indication position north depending on value head.cd1_1}
    plot_north_on_image;
    plot_large_north_indicator;
    if mainwindow.add_marker_position1.checked then
      mainwindow.add_marker_position1.checked:=place_marker_radec(marker_position);{place a marker}
    plot_grid;
    plot_constellations;
    plot_text;
    if ((annotated) and (mainwindow.annotations_visible1.checked)) then plot_annotations(false {use solution vectors},false);

    mainwindow.statusbar1.panels[5].text:=inttostr(head.width)+' x '+inttostr(head.height)+' x '+inttostr(head.naxis3)+'   '+inttostr(nrbits)+' BPP';{give image dimensions and bit per pixel info}
    update_statusbar_section5;{update section 5 with image dimensions in degrees}
    mainwindow.statusbar1.panels[7].text:=''; {2020-2-15 moved from load_fits to plot_image. Clear any outstanding error}

    update_menu(true);{2020-2-15 moved from load_fits to plot_image.  file loaded, update menu for fits}
  end;

  {do refresh at the end for smooth display, especially for blinking }
//  img.refresh;{important, show update}
  img.invalidate;{important, show update. NoTe refresh aligns image to the left!!}


  quads_displayed:=false; {displaying quads doesn't require a screen refresh}

  Screen.cursor:= Save_Cursor;
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
  i, minm,maxm,max_range, countR,countG,countB,stopXpos,Xpos,max_color,histo_peakR,number_colors, histo_peak_position,h,w,col : integer;
  above, above_R          : double;
  Save_Cursor:TCursor;
  histogram2 : array of array of integer;
  histo_peak : array[0..2] of integer;

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

  max_range:=round(min(head.datamax_org,65535)); {measured while loading, Prevent runtime error if head.datamax_org>65535}

  case mainwindow.range1.itemindex of
    -1,0,1: above_R:=0.001;{low range}
       2,3: above_R:=0.003; {medium range}
       4,5: above_R:=0.01;  {high range}
       6,7: begin minm:=round(head.datamin_org);maxm:=round(head.datamax_org)end;{6=range and 7=manual}
       8: begin minm:=round(max_range*0.95); maxm:=round(max_range);  end;{Show saturation}
       9: begin minm:=0; maxm:=65535;head.datamax_org:=65535; end;{max range, use datamin/max}
  end;

  {calculate peak values }

  if mainwindow.range1.itemindex<=5 then {auto detect mode}
  begin
    minm:=0;
    maxm:=0;
    above:=0;
    histo_peak_position:=0;{define something for images containing zeros only}
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

  hist_range:=round(min(head.datamax_org,2*maxm));{adapt histogram range}
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

  h:=mainwindow.histogram1.height;
  w:=mainwindow.histogram1.width;

  setlength(histogram2,number_colors,w); {w variable and dependend of windows desktop settings!}
  histo_peakR:=0;

  {zero arrays}
  for col:=0 to 2 do histo_peak[col]:=0;
  try
  for i := 0 to w-1 do  {zero}
    for col:=0 to number_colors-1 do histogram2[col,i]:=0;

  except
     beep; {histogram array size it too small adapt to mainwindow.histogram1.width;!!}
     exit;
  end;

  for col:=0 to number_colors-1 do {shrink histogram. Note many values could be zero due to 14,12 or 8 byte nature data. So take peak value}
  begin
    stopXpos:=0;
    for i := 1 to hist_range-1{65535} do
    begin
      if histogram[col,i]>histo_peak[col] then begin histo_peak[col]:=histogram[col,i]; end;
      Xpos:=round((w-1)*i/(hist_range-1));
      if Xpos>stopXpos then {new line to be drawn}
       begin
         stopXpos:=Xpos;
         histogram2[col,xpos]:=histo_peak[col];
         histo_peakR:=max(histo_peakR,histo_peak[col]);
         histo_peak[col]:=0;
       end;
    end;
  end;

  for i := 0 to w-1 do {create histogram graph}
  begin
    begin
      countR:= round(255*histogram2[0,i]/(histo_peakR+1));
      if number_colors>1 then countG:= round(255*histogram2[1,i]/(histo_peakR+1)) else countG:=0;
      if number_colors>2 then countB:= round(255*histogram2[2,i]/(histo_peakR+1)) else countB:=0;

      if ((countR>0) or (countG>0) or (countB>0)) then {something to plot}
      begin
        max_color:=max(countR,max(countG,countB));
        mainwindow.histogram1.Canvas.Pen.Color := rgb(255*countR div max_color,255*countG div max_color,255*countB div max_color);{set pen colour}

        max_color:=round(256*ln(max_color)/ln(256));{make scale logarithmic}

        moveToex(mainwindow.histogram1.Canvas.handle,i,h,nil);
        lineTo(mainwindow.histogram1.Canvas.handle,i ,h-round(h*max_color/256) ); {draw vertical line}
      end;
    end;
  end;

  histogram2:=nil;
  Screen.Cursor:=Save_Cursor;
end;


function savefits_update_header(filen2:string) : boolean;{save fits file with updated header}
var
  reader_position,I,readsize  : integer;
  TheFile4  : tfilestream;
  fract     : double;
  line0       : ansistring;
  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}
  header    : array[0..2880] of ansichar;
  endfound  : boolean;
  filename_bak: string;

     procedure close_fits_files;
     begin
        Reader.free;
        TheFile3.free;
        TheFile4.free;
     end;

     Function validate_double:double;{read values}
     var t :string[20];
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
  result:=false;
  filename_bak:=changeFileExt(filen2,'.bak');
  if fileexists(filename_bak) then deletefile(filename_bak);

  if renamefile(filen2,filename_bak) then
  begin //save with update header

    try
      TheFile3:=tfilestream.Create(filename_bak, fmOpenRead or fmShareDenyWrite);
      TheFile4:=tfilestream.Create(filen2, fmcreate );

      Reader := TReader.Create (theFile3,$4000);{number of hnsky records}
      {thefile3.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}
      I:=0;
      reader_position:=0;
      repeat
        reader.read(header[i],80); {read file info, 80 bytes only}
        inc(reader_position,80);
        endfound:=((header[i]='E') and (header[i+1]='N')  and (header[i+2]='D') and (header[i+3]=' '));
      until ((endfound) or (I>=sizeof(header)-16 ));
      if endfound=false then begin close_fits_files; exit;end;

      fract:=frac(reader_position/2880);

      if fract<>0 then
      begin
        i:=round((1-fract)*2880);{left part of next 2880 bytes block}
        reader.read(header[0],i); {skip empty part and go to image data}
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
         reader.read(fitsbuffer,readsize); {read file info IN STEPS OF 2880}
         inc(reader_position,readsize);
         thefile4.writebuffer(fitsbuffer,readsize); {write as bytes. Do not use write size last record is forgotten !!!}
       until (reader_position>=thefile3.size);

      Reader.free;
      TheFile3.free;
      TheFile4.free;

      if deletefile(filename_bak) then result:=true;
    except
      close_fits_files;
      beep;
      exit;
    end;

  end;
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
     wait(100);{smart sleep}
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
var
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


function encrypt(inp: string): string;
var
   i: integer;
begin
  result:='1';{version}
  for i:=1 to length(inp) do
     result:=result+char(ord(inp[i])+i-11);
end;


function decrypt(inp: string): string;
var
   i: integer;
begin
  result:='';
  if ((length(inp)>=2) and (inp[1]='1')) then {correct format}
  for i:=2 to length(inp) do
     result:=result+char(ord(inp[i])-i+11+1);
end;

function loadsettingsold(lpath: string)  : boolean; {old !!!!!!!!!!!!!!!!}
var
  dum : string;
  i,c                : integer;
  initstring :tstrings; {settings for save and loading}

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
     s2     : string;
   begin
     s2:=initstring.Values[s1];
     if s2<>'' then inp:=s2;
   end;

begin

  {old routine}	  result:=false;{assume failure}
  {old routine}	  initstring := Tstringlist.Create;
  {old routine}	  with initstring do
  {old routine}	  begin
  {old routine}	    try
  {old routine}	     loadfromFile(lpath); { load from file}
  {old routine}	    except
  {old routine}	      initstring.Free;
  {old routine}	      exit; {no cfg file}
  {old routine}	    end;
  {old routine}	  end;
  {old routine}
  {old routine}	 // t1:=GetTickCount;
  {old routine}
  {old routine}	  result:=true;
  {old routine}	  with mainwindow do
  {old routine}	  begin
  {old routine}	    mainwindow.left:=get_int2(mainwindow.left,'window_left');
  {old routine}	    mainwindow.top:=get_int2(mainwindow.top,'window_top'); ;
  {old routine}	    mainwindow.height:=get_int2(mainwindow.height,'window_height');
  {old routine}	    mainwindow.width:=get_int2(mainwindow.width,'window_width');;
  {old routine}
  {old routine}	    bayer_image:=get_boolean('raw_bayer',false);
  {old routine}
  {old routine}	    stackmenu1.left:=get_int2(stackmenu1.left,'stackmenu_left');
  {old routine}	    stackmenu1.top:=get_int2(stackmenu1.top,'stackmenu_top');
  {old routine}	    stackmenu1.height:=get_int2(stackmenu1.height,'stackmenu_height');
  {old routine}	    stackmenu1.width:=get_int2(stackmenu1.width,'stackmenu_width');
  {old routine}
  {old routine}	    get_int(font_color,'font_color');
  {old routine}	    get_int(font_size,'font_size');
  {old routine}	    dum:=initstring.Values['font_name2'];if dum<>'' then font_name:= dum;
  {old routine}	    dum:=initstring.Values['font_style'];if dum<>'' then font_style:= strtostyle(dum);
  {old routine}	    get_int(font_charset,'font_charset');
  {old routine}	    get_int(pedestal,'pedestal');
  {old routine}
  {old routine}
  {old routine}	    stackmenu1.mosaic_width1.position:=get_int2(stackmenu1.mosaic_width1.position,'mosaic_width');
  {old routine}	    stackmenu1.mosaic_crop1.position:=get_int2(stackmenu1.mosaic_crop1.position,'mosaic_crop');
  {old routine}
  {old routine}	    minimum1.position:=get_int2(minimum1.position,'minimum_position');
  {old routine}	    maximum1.position:=get_int2(maximum1.position,'maximum_position');
  {old routine}	    range1.itemindex:=get_int2(range1.itemindex,'range');
  {old routine}
  {old routine}	    saturation_factor_plot1.position:=get_int2(saturation_factor_plot1.position,'saturation_factor');
  {old routine}
  {old routine}	    stackmenu1.stack_method1.itemindex:=get_int2(stackmenu1.stack_method1.itemindex,'stack_method');
  {old routine}	    stackmenu1.flat_combine_method1.itemindex:=get_int2(stackmenu1.flat_combine_method1.itemindex,'flat_combine_method');
  {old routine}	    stackmenu1.pagecontrol1.tabindex:=get_int2(stackmenu1.pagecontrol1.tabindex,'stack_tab');
  {old routine}
  {old routine}	    stackmenu1.demosaic_method1.itemindex:=get_int2(stackmenu1.demosaic_method1.itemindex,'demosaic_method2');
  {old routine}	    stackmenu1.raw_conversion_program1.itemindex:=get_int2(stackmenu1.raw_conversion_program1.itemindex,'conv_program');
  {old routine}
  {old routine}	    Polynomial1.itemindex:=get_int2(Polynomial1.itemindex,'polynomial');
  {old routine}
  {old routine}	    get_int(thumbnails1_width,'thumbnails_width');
  {old routine}	    get_int(thumbnails1_height,'thumbnails_height');
  {old routine}
  {old routine}	    inversemousewheel1.checked:=get_boolean('inversemousewheel',false);
  {old routine}	    flip_horizontal1.checked:=get_boolean('fliphorizontal',false);
  {old routine}	    flip_vertical1.checked:=get_boolean('flipvertical',false);
  {old routine}
  {old routine}	    annotations_visible1.checked:=get_boolean('annotations',false);
  {old routine}	    northeast1.checked:=get_boolean('north_east',false);
  {old routine}	    mountposition1.checked:=get_boolean('mount_position',false);
  {old routine}	    grid1.checked:=get_boolean('grid',false);
  {old routine}	    positionanddate1.checked:=get_boolean('pos_date',false);
  {old routine}	    freetext1.checked:=get_boolean('freetxt',false);
  {old routine}	    freetext:=initstring.Values['f_text'];
  {old routine}
  {old routine}	    add_marker_position1.checked:=get_boolean('add_marker',false);{popup marker selected?}
  {old routine}
  {old routine}	    stackmenu1.make_osc_color1.checked:=get_boolean('osc_color_convert',false);
  {old routine}	    stackmenu1.osc_auto_level1.checked:=get_boolean('osc_al',true);
  {old routine}	    stackmenu1.osc_colour_smooth1.checked:=get_boolean('osc_cs',true);
  {old routine}	    stackmenu1.osc_preserve_r_nebula1.checked:=get_boolean('osc_pr',true);
  {old routine}	    dum:=initstring.Values['osc_cw'];if dum<>'' then stackmenu1.osc_smart_smooth_width1.text:= dum;
  {old routine}	    dum:=initstring.Values['osc_sd'];if dum<>'' then stackmenu1.osc_smart_colour_sd1.text:= dum;
  {old routine}
  {old routine}
  {old routine}	    stackmenu1.lrgb_auto_level1.checked:=get_boolean('lrgb_al',true);
  {old routine}	    stackmenu1.green_purple_filter1.checked:=get_boolean('green_fl',false);
  {old routine}	    stackmenu1.lrgb_colour_smooth1.checked:=get_boolean('lrgb_cs',true);
  {old routine}	    stackmenu1.lrgb_preserve_r_nebula1.checked:=get_boolean('lrgb_pr',true);
  {old routine}	    dum:=initstring.Values['lrgb_sw'];if dum<>'' then stackmenu1.lrgb_smart_smooth_width1.text:= dum;
  {old routine}	    dum:=initstring.Values['lrgb_sd'];if dum<>'' then stackmenu1.lrgb_smart_colour_sd1.text:= dum;
  {old routine}
  {old routine}
  {old routine}	    stackmenu1.ignore_header_solution1.Checked:= get_boolean('ignore_header_solution',true);
  {old routine}	    stackmenu1.Equalise_background1.checked:= get_boolean('equalise_background',true);{for mosaic mode}
  {old routine}	    stackmenu1.merge_overlap1.checked:= get_boolean('merge_overlap',true);{for mosaic mode}
  {old routine}
  {old routine}
  {old routine}	    mainwindow.preview_demosaic1.Checked:=get_boolean('preview_demosaic',false);
  {old routine}
  {old routine}	    stackmenu1.classify_object1.checked:= get_boolean('classify_object',false);
  {old routine}	    stackmenu1.classify_filter1.checked:= get_boolean('classify_filter',false);
  {old routine}
  {old routine}	    stackmenu1.classify_dark_temperature1.checked:= get_boolean('classify_dark_temperature',false);
  {old routine}	    stackmenu1.classify_dark_exposure1.checked:= get_boolean('classify_dark_exposure',false);
  {old routine}	    stackmenu1.classify_flat_filter1.checked:= get_boolean('classify_flat_filter',false);
  {old routine}	    stackmenu1.classify_dark_date1.checked:= get_boolean('classify_dark_date',false);
  {old routine}	    stackmenu1.classify_flat_date1.checked:= get_boolean('classify_flat_date',false);
  {old routine}	    stackmenu1.add_time1.checked:= get_boolean('add_time',false); {add time to resulting stack file name}
  {old routine}
  {old routine}	    stackmenu1.uncheck_outliers1.checked:= get_boolean('uncheck_outliers',false);
  {old routine}
  {old routine}	    marker_position :=initstring.Values['marker_position'];{ra, dec marker}
  {old routine}	    mainwindow.shape_marker3.hint:=marker_position;
  {old routine}
  {old routine}	    ra1.text:= initstring.Values['ra'];
  {old routine}	    dec1.text:= initstring.Values['dec'];
  {old routine}
  {old routine}	    stretch1.text:= initstring.Values['gamma'];
  {old routine}
  {old routine}	    stackmenu1.blur_factor1.text:= initstring.Values['blur_factor'];
  {old routine}
  {old routine}	    stackmenu1.use_manual_alignment1.checked:=initstring.Values['align_method']='4';
  {old routine}	    stackmenu1.use_astrometry_internal1.checked:=initstring.Values['align_method']='3';
  {old routine}	    stackmenu1.use_star_alignment1.checked:=initstring.Values['align_method']='2';
  {old routine}	    stackmenu1.use_ephemeris_alignment1.checked:=initstring.Values['align_method']='1';
  {old routine}
  {old routine}	    stackmenu1.write_log1.Checked:=get_boolean('write_log',true);{write to log file}
  {old routine}	    stackmenu1.align_blink1.Checked:=get_boolean('align_blink',true);{blink}
  {old routine}	    stackmenu1.timestamp1.Checked:=get_boolean('time_stamp',true);{blink}
  {old routine}
  {old routine}	    stackmenu1.force_oversize1.Checked:=get_boolean('force_slow',false);
  {old routine}	    stackmenu1.calibrate_prior_solving1.Checked:=get_boolean('calibrate_prior_solving',false);
  {old routine}
  {old routine}	    dum:=initstring.Values['star_database']; if dum<>'' then stackmenu1.star_database1.text:=dum;
  {old routine}	    dum:=initstring.Values['solve_search_field']; if dum<>'' then stackmenu1.search_fov1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['radius_search']; if dum<>'' then stackmenu1.radius_search1.text:=dum;
  {old routine}	    dum:=initstring.Values['quad_tolerance']; if dum<>'' then stackmenu1.quad_tolerance1.text:=dum;
  {old routine}	    dum:=initstring.Values['maximum_stars']; if dum<>'' then stackmenu1.max_stars1.text:=dum;
  {old routine}	    dum:=initstring.Values['min_star_size']; if dum<>'' then stackmenu1.min_star_size1.text:=dum;
  {old routine}	    dum:=initstring.Values['min_star_size_stacking']; if dum<>'' then stackmenu1.min_star_size_stacking1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['manual_centering']; if dum<>'' then stackmenu1.manual_centering1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['downsample']; if dum<>'' then stackmenu1.downsample_for_solving1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['oversize'];if dum<>'' then stackmenu1.oversize1.text:=dum;
  {old routine}	    dum:=initstring.Values['sd_factor']; if dum<>'' then stackmenu1.sd_factor1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['most_common_filter_radius']; if dum<>'' then stackmenu1.most_common_filter_radius1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['extract_background_box_size']; if dum<>'' then stackmenu1.extract_background_box_size1.text:=dum;
  {old routine}	    dum:=initstring.Values['dark_areas_box_size']; if dum<>'' then stackmenu1.dark_areas_box_size1.text:=dum;
  {old routine}	    dum:=initstring.Values['ring_equalise_factor']; if dum<>'' then stackmenu1.ring_equalise_factor1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['gradient_filter_factor']; if dum<>'' then stackmenu1.gradient_filter_factor1.text:=dum;
  {old routine}
  {old routine}	    if paramcount=0 then filename2:=initstring.Values['last_file'];{if used as viewer don't override paramstr1}
  {old routine}
  {old routine}	    dum:=initstring.Values['bayer_pat']; if dum<>'' then stackmenu1.bayer_pattern1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['red_filter1']; if dum<>'' then stackmenu1.red_filter1.text:=dum;
  {old routine}	    dum:=initstring.Values['red_filter2']; if dum<>'' then stackmenu1.red_filter2.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['green_filter1']; if dum<>'' then stackmenu1.green_filter1.text:=dum;
  {old routine}	    dum:=initstring.Values['green_filter2']; if dum<>'' then stackmenu1.green_filter2.text:=dum;
  {old routine}	    dum:=initstring.Values['blue_filter1']; if dum<>'' then stackmenu1.blue_filter1.text:=dum;
  {old routine}	    dum:=initstring.Values['blue_filter2']; if dum<>'' then stackmenu1.blue_filter2.text:=dum;
  {old routine}	    dum:=initstring.Values['luminance_filter1']; if dum<>'' then stackmenu1.luminance_filter1.text:=dum;
  {old routine}	    dum:=initstring.Values['luminance_filter2']; if dum<>'' then stackmenu1.luminance_filter2.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['rr_factor']; if dum<>'' then stackmenu1.rr1.text:=dum;
  {old routine}	    dum:=initstring.Values['rg_factor']; if dum<>'' then stackmenu1.rg1.text:=dum;
  {old routine}	    dum:=initstring.Values['rb_factor']; if dum<>'' then stackmenu1.rb1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['gr_factor']; if dum<>'' then stackmenu1.gr1.text:=dum;
  {old routine}	    dum:=initstring.Values['gg_factor']; if dum<>'' then stackmenu1.gg1.text:=dum;
  {old routine}	    dum:=initstring.Values['gb_factor']; if dum<>'' then stackmenu1.gb1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['br_factor']; if dum<>'' then stackmenu1.br1.text:=dum;
  {old routine}	    dum:=initstring.Values['bg_factor']; if dum<>'' then stackmenu1.bg1.text:=dum;
  {old routine}	    dum:=initstring.Values['bb_factor']; if dum<>'' then stackmenu1.bb1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['red_filter_add']; if dum<>'' then stackmenu1.red_filter_add1.text:=dum;
  {old routine}	    dum:=initstring.Values['green_filter_add']; if dum<>'' then stackmenu1.green_filter_add1.text:=dum;
  {old routine}	    dum:=initstring.Values['blue_filter_add']; if dum<>'' then stackmenu1.blue_filter_add1.text:=dum;
  {old routine}
  {old routine}
  {old routine}	   {Six colour correction factors}
  {old routine}	    dum:=initstring.Values['add_value_R']; if dum<>'' then stackmenu1.add_valueR1.text:=dum;
  {old routine}	    dum:=initstring.Values['add_value_G']; if dum<>'' then stackmenu1.add_valueG1.text:=dum;
  {old routine}	    dum:=initstring.Values['add_value_B']; if dum<>'' then stackmenu1.add_valueB1.text:=dum;
  {old routine}	    dum:=initstring.Values['multiply_R']; if dum<>'' then stackmenu1.multiply_red1.text:=dum;
  {old routine}	    dum:=initstring.Values['multiply_G']; if dum<>'' then stackmenu1.multiply_green1.text:=dum;
  {old routine}	    dum:=initstring.Values['multiply_B']; if dum<>'' then stackmenu1.multiply_blue1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['smart_smooth_width']; if dum<>'' then stackmenu1.smart_smooth_width1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['star_level_colouring']; if dum<>'' then stackmenu1.star_level_colouring1.text:=dum;
  {old routine}	    dum:=initstring.Values['filter_artificial_colouring']; if dum<>'' then stackmenu1.filter_artificial_colouring1.text:=dum;
  {old routine}	    dum:=initstring.Values['resize_factor']; if dum<>'' then stackmenu1.resize_factor1.text:=dum;
  {old routine}	    dum:=initstring.Values['mark_outliers_upto']; if dum<>'' then stackmenu1.mark_outliers_upto1.text:=dum;
  {old routine}	    dum:=initstring.Values['flux_aperture']; if dum<>'' then stackmenu1.flux_aperture1.text:=dum;
  {old routine}	    dum:=initstring.Values['annulus_radius']; if dum<>'' then stackmenu1.annulus_radius1.text:=dum;
  {old routine}	    stackmenu1.checkBox_annotate1.checked:= get_boolean('ph_annotate',true);
  {old routine}
  {old routine}
  {old routine}	    dum:=initstring.Values['sigma_decolour']; if dum<>'' then stackmenu1.sigma_decolour1.text:=dum;
  {old routine}	    dum:=initstring.Values['sd_factor_list']; if dum<>'' then stackmenu1.sd_factor_list1.text:=dum;
  {old routine}
  {old routine}	    dum:=initstring.Values['noisefilter_blur']; if dum<>'' then stackmenu1.noisefilter_blur1.text:=dum;
  {old routine}	    dum:=initstring.Values['noisefilter_sd']; if dum<>'' then stackmenu1.noisefilter_sd1.text:=dum;
  {old routine}
  {old routine}	    stackmenu1.hue_fuzziness1.position:=get_int2(stackmenu1.hue_fuzziness1.position,'hue_fuzziness');
  {old routine}	    stackmenu1.saturation_tolerance1.position:=get_int2(stackmenu1.saturation_tolerance1.position,'saturation_tolerance');
  {old routine}	    stackmenu1.remove_luminance1.checked:= get_boolean('remove_luminance',false);
  {old routine}
  {old routine}	    stackmenu1.sample_size1.itemindex:=get_int2(stackmenu1.sample_size1.itemindex,'sample_size');
  {old routine}	    stackmenu1.live_stacking_path1.caption:=initstring.Values['live_stack_dir'];
  {old routine}
  {old routine}	    dum:=initstring.Values['mpcorb_path'];if dum<>'' then mpcorb_path:=dum;{asteroids}
  {old routine}	    dum:=initstring.Values['cometels_path'];if dum<>'' then cometels_path:=dum;{asteroids}
  {old routine}
  {old routine}	    dum:=initstring.Values['maxcount'];if dum<>'' then maxcount_asteroid:=dum;{asteroids}
  {old routine}	    dum:=initstring.Values['maxmag'];if dum<>'' then maxmag_asteroid:=dum;{asteroids}
  {old routine}
  {old routine}	    font_follows_diameter:=get_boolean('font_follows',false);{asteroids}
  {old routine}	    showfullnames:=get_boolean('showfullnames',true);{asteroids}
  {old routine}	    showmagnitude:=get_boolean('showmagnitude',false);{asteroids}
  {old routine}	    add_date:=get_boolean('add_date',true);{asteroids}
  {old routine}	    lat_default:=decrypt(initstring.Values['p1']);{lat default}
  {old routine}	    long_default:=decrypt(initstring.Values['p2']);{longitude default}
  {old routine}
  {old routine}	    get_int(annotation_color,'annotation_color');
  {old routine}	    get_int(annotation_diameter,'annotation_diameter');
  {old routine}
  {old routine}	    add_annotations:=get_boolean('add_annotations',false);{asteroids as annotations}
  {old routine}
  {old routine}	    dum:=initstring.Values['astrometry_extra_options']; if dum<>'' then astrometry_extra_options:=dum;
  {old routine}	    show_console:=get_boolean('show_console',true);
  {old routine}	    dum:=initstring.Values['cygwin_path']; if dum<>'' then cygwin_path:=dum;
  {old routine}
  {old routine}	    stackmenu1.write_jpeg1.Checked:=get_boolean('write_jpeg',false);{live stacking}
  {old routine}	    stackmenu1.interim_to_clipboard1.Checked:=get_boolean('to_clipboard',false);{live stacking}
  {old routine}
  {old routine}
  {old routine}	    obscode:=initstring.Values['obscode']; {photometry}
  {old routine}	    delim_pos:=get_int2(0,'delim_pos');
  {old routine}
  {old routine}	    stackmenu1.equinox1.itemindex:=get_int2(stackmenu1.equinox1.itemindex,'equinox');
  {old routine}	    stackmenu1.mount_write_wcs1.Checked:=get_boolean('wcs',true);{use wcs files for mount}
  {old routine}
  {old routine}	    c:=0;
  {old routine}	    recent_files.clear;
  {old routine}	    repeat {read recent files}
  {old routine}	      dum:=initstring.Values['recent'+inttostr(c)];
  {old routine}	      if dum<>'' then
  {old routine}	       recent_files.add(dum);
  {old routine}	      inc(c);
  {old routine}	    until (dum='');
  {old routine}	    update_recent_file_menu;
  {old routine}
  {old routine}
  {old routine}
  {old routine}	    listviews_begin_update; {stop updating listviews}
  {old routine}
  {old routine}	    c:=0;
  {old routine}	    repeat {add images}
  {old routine}	       dum:=initstring.Values['image'+inttostr(c)];
  {old routine}	       if ((dum<>'') and (fileexists(dum))) then
  {old routine}	         listview_add(stackmenu1.listview1,dum,get_boolean('image'+inttostr(c)+'_check',true),L_nr);
  {old routine}	       inc(c);
  {old routine}	    until (dum='');
  {old routine}
  {old routine}	    c:=0;
  {old routine}	    repeat {add  darks}
  {old routine}	      dum:=initstring.Values['dark'+inttostr(c)];
  {old routine}	      if ((dum<>'') and (fileexists(dum))) then
  {old routine}	         listview_add(stackmenu1.listview2,dum,get_boolean('dark'+inttostr(c)+'_check',true),D_nr);
  {old routine}	      inc(c);
  {old routine}	    until (dum='');
  {old routine}
  {old routine}	    c:=0;
  {old routine}	    repeat {add  flats}
  {old routine}	      dum:=initstring.Values['flat'+inttostr(c)];
  {old routine}	      if ((dum<>'') and (fileexists(dum))) then
  {old routine}	        listview_add(stackmenu1.listview3,dum,get_boolean('flat'+inttostr(c)+'_check',true),F_nr);
  {old routine}	      inc(c);
  {old routine}	    until (dum='');
  {old routine}
  {old routine}	    c:=0;
  {old routine}	    repeat {add flat darks}
  {old routine}	      dum:=initstring.Values['flat_dark'+inttostr(c)];
  {old routine}	      if ((dum<>'') and (fileexists(dum))) then
  {old routine}	        listview_add(stackmenu1.listview4,dum,get_boolean('flat_dark'+inttostr(c)+'_check',true),D_nr);
  {old routine}	      inc(c);
  {old routine}	    until (dum='');
  {old routine}
  {old routine}	    c:=0;
  {old routine}	    repeat {add blink files}
  {old routine}	      dum:=initstring.Values['blink'+inttostr(c)];
  {old routine}	      if ((dum<>'') and (fileexists(dum))) then
  {old routine}	        listview_add(stackmenu1.listview6,dum,get_boolean('blink'+inttostr(c)+'_check',true),B_nr);
  {old routine}	      inc(c);
  {old routine}	    until (dum='');
  {old routine}
  {old routine}	    c:=0;
  {old routine}	    repeat {add photometry files}
  {old routine}	      dum:=initstring.Values['photometry'+inttostr(c)];
  {old routine}	      if ((dum<>'') and (fileexists(dum))) then
  {old routine}	        listview_add(stackmenu1.listview7,dum,get_boolean('photometry'+inttostr(c)+'_check',true),P_nr);
  {old routine}	      inc(c);
  {old routine}	    until (dum='');
  {old routine}
  {old routine}	    c:=0;
  {old routine}	    repeat {add inspector files}
  {old routine}	      dum:=initstring.Values['inspector'+inttostr(c)];
  {old routine}	      if ((dum<>'') and (fileexists(dum))) then
  {old routine}	        listview_add(stackmenu1.listview8,dum,get_boolean('inspector'+inttostr(c)+'_check',true),L_nr);
  {old routine}	      inc(c);
  {old routine}	    until (dum='');
  {old routine}
  {old routine}	    stackmenu1.visible:=((paramcount=0) and (get_boolean('stackmenu_visible',false) ) );{do this last, so stackmenu.onshow updates the setting correctly}
  {old routine}	    listviews_end_update; {start updating listviews. Do this after setting stack menus visible. This is faster.}
  {old routine}
  {old routine}	//    mainwindow.Caption := floattostr((GetTickCount-t1)/1000);
  {old routine}
  {old routine}	  end;
  {old routine}	  initstring.free;
end;


function load_settings(lpath: string)  : boolean;
var
    Sett : TmemIniFile;
    dum : string;
    c   : integer;
    bool: boolean;
begin
  result:=false;{assume failure}
//  t1:=gettickcount;
  try
    Sett := TmemIniFile.Create(lpath);
    result:=false; {assume failure}
    with mainwindow do
    begin
      c:=Sett.ReadInteger('main','window_left',987654321);
      if c<>987654321 then
      begin
        result:=true; {Important read error detection. No other read error method works for Tmeminifile. Important for creating directories for new installations}
        mainwindow.left:=c;
      end
      else
      begin
        mainwindow.top:=0;{for case the form was not set at the main screen}
        mainwindow.left:=0;

         result:=loadsettingsold(lpath);{old format}  {remove this line after 2022-5-7}

        exit;
      end;


      c:=Sett.ReadInteger('main','window_top',987654321); if c<>987654321 then mainwindow.top:=c;
      c:=Sett.ReadInteger('main','window_height',987654321);if c<>987654321 then mainwindow.height:=c;
      c:=Sett.ReadInteger('main','window_width',987654321);if c<>987654321 then mainwindow.width:=c;


      font_color:=sett.ReadInteger('main','font_color',font_color);
      font_size:=sett.ReadInteger('main','font_size',font_size);
      font_name:=Sett.ReadString('main', 'font_name2',font_name);
      dum:=Sett.ReadString('main','font_style','');if dum<>'' then font_style:= strtostyle(dum);
      font_charset:=sett.ReadInteger('main','font_charset',font_charset);
      pedestal:=sett.ReadInteger('main','pedestal',pedestal);



      c:=Sett.ReadInteger('main','minimum_position',987654321); if c<>987654321 then minimum1.position:=c;
      c:=Sett.ReadInteger('main','maximum_position',987654321);if c<>987654321 then maximum1.position:=c;
      c:=Sett.ReadInteger('main','range',987654321);if c<>987654321 then range1.itemindex:=c;

      c:=Sett.ReadInteger('main','saturation_factor',987654321); if c<>987654321 then saturation_factor_plot1.position:=c;


      c:=Sett.ReadInteger('main','polynomial',987654321); if c<>987654321 then Polynomial1.itemindex:=c;

      thumbnails1_width:=Sett.ReadInteger('main','thumbnails_width',thumbnails1_width);
      thumbnails1_height:=Sett.ReadInteger('main','thumbnails_height',thumbnails1_height);

      inversemousewheel1.checked:=Sett.ReadBool('main','inversemousewheel',false);
      flip_horizontal1.checked:=Sett.ReadBool('main','fliphorizontal',false);
      flip_vertical1.checked:=Sett.ReadBool('main','flipvertical',false);

      bool:=Sett.ReadBool('main','annotations',false);
      mainwindow.annotations_visible1.checked:=bool;{set both indicators}
      stackmenu1.annotations_visible1.enabled:=bool;{set both indicators}

      northeast1.checked:=Sett.ReadBool('main','north_east',false);
      mountposition1.checked:=Sett.ReadBool('main','mount_position',false);
      Constellations1.checked:=Sett.ReadBool('main','constellations',false);
      grid1.checked:=Sett.ReadBool('main','grid',false);
      positionanddate1.checked:=Sett.ReadBool('main','pos_date',false);
      freetext1.checked:=Sett.ReadBool('main','freetxt',false);
      freetext:=Sett.ReadString('main','f_text','');

      add_marker_position1.checked:=Sett.ReadBool('main','add_marker',false);{popup marker selected?}

      mainwindow.preview_demosaic1.Checked:=Sett.ReadBool('main','preview_demosaic',false);
      mainwindow.batch_overwrite1.checked:=Sett.ReadBool('main','s_overwrite',false);
      mainwindow.add_sip_check1.Checked:=Sett.ReadBool('main','add_sip',false);
      mainwindow.add_limiting_magn_check1.Checked:=Sett.ReadBool('main','add_lim_magn',false);

      marker_position :=Sett.ReadString('main','marker_position','');{ra, dec marker}
      mainwindow.shape_marker3.hint:=marker_position;

      ra1.text:= Sett.ReadString('main','ra','0');
      dec1.text:= Sett.ReadString('main','dec','0');

      stretch1.text:= Sett.ReadString('main','gamma','');


      if paramcount=0 then filename2:=Sett.ReadString('main','last_file','');{if used as viewer don't override paramstr1}


      dum:=Sett.ReadString('main','mpcorb_path','');if dum<>'' then mpcorb_path:=dum;{asteroids}
      dum:=Sett.ReadString('main','cometels_path','');if dum<>'' then cometels_path:=dum;{asteroids}

      dum:=Sett.ReadString('main','maxcount','');if dum<>'' then maxcount_asteroid:=dum;{asteroids}
      dum:=Sett.ReadString('main','maxmag','');if dum<>'' then maxmag_asteroid:=dum;{asteroids}

      font_follows_diameter:=Sett.ReadBool('main','font_follows',false);{asteroids}
      showfullnames:=Sett.ReadBool('main','showfullnames',true);{asteroids}
      showmagnitude:=Sett.ReadBool('main','showmagnitude',false);{asteroids}
      add_date:=Sett.ReadBool('main','add_date',true);{asteroids}
      lat_default:=decrypt(Sett.ReadString('main','p1',''));{lat default}
      long_default:=decrypt(Sett.ReadString('main','p2',''));{longitude default}

      annotation_color:=Sett.ReadInteger('main','annotation_color',annotation_color);
      annotation_diameter:=Sett.ReadInteger('main','annotation_diameter',annotation_diameter);

      add_annotations:=Sett.ReadBool('main','add_annotations',false);{asteroids as annotations}

      dum:=Sett.ReadString('main','astrometry_extra_options',''); if dum<>'' then astrometry_extra_options:=dum;
      show_console:=Sett.ReadBool('main','show_console',true);
      dum:=Sett.ReadString('main','cygwin_path',''); if dum<>'' then cygwin_path:=dum;

      dum:=Sett.ReadString('main','sqm_key',''); if dum<>'' then sqm_key:=dum;
      dum:=Sett.ReadString('main','centaz_key',''); if dum<>'' then centaz_key:=dum;

      c:=0;
      recent_files.clear;
      repeat {read recent files}
        dum:=Sett.ReadString('main','recent'+inttostr(c),'');
        if dum<>'' then  recent_files.add(dum);  inc(c);
      until (dum='');
      update_recent_file_menu;


      c:=Sett.ReadInteger('stack','stackmenu_left',987654321); if c<>987654321 then stackmenu1.left:=c;
      c:=Sett.ReadInteger('stack','stackmenu_top',987654321);  if c<>987654321 then stackmenu1.top:=c;
      c:=Sett.ReadInteger('stack','stackmenu_height',987654321); if c<>987654321 then stackmenu1.height:=c;
      c:=Sett.ReadInteger('stack','stackmenu_width',987654321); if c<>987654321 then stackmenu1.width:=c;

      c:=Sett.ReadInteger('stack','mosaic_width',987654321); if c<>987654321 then stackmenu1.mosaic_width1.position:=c;
      c:=Sett.ReadInteger('stack','mosaic_crop',987654321);if c<>987654321 then stackmenu1.mosaic_crop1.position:=c;

      c:=Sett.ReadInteger('stack','stack_method',987654321); if c<>987654321 then stackmenu1.stack_method1.itemindex:=c;
      c:=Sett.ReadInteger('stack','flat_combine_method',987654321);if c<>987654321 then stackmenu1.flat_combine_method1.itemindex:=c;
      c:=Sett.ReadInteger('stack','stack_tab',987654321); if c<>987654321 then stackmenu1.pagecontrol1.tabindex:=c;

      c:=Sett.ReadInteger('stack','demosaic_method2',987654321); if c<>987654321 then stackmenu1.demosaic_method1.itemindex:=c;

                 {remove this code in 2022-6}
                 c:=Sett.ReadInteger('stack','conv_program',987654321);if c<>987654321 then
                 begin
                   if c=1 {dcraw} then c:=2;
                   stackmenu1.raw_conversion_program1.itemindex:=c;
                 end
                 else
                 {end remove}
      c:=Sett.ReadInteger('stack','conv_progr',987654321);if c<>987654321 then stackmenu1.raw_conversion_program1.itemindex:=c;


      stackmenu1.make_osc_color1.checked:=Sett.ReadBool('stack','osc_color_convert',false);
      stackmenu1.osc_auto_level1.checked:=Sett.ReadBool('stack','osc_al',true);
      stackmenu1.osc_colour_smooth1.checked:=Sett.ReadBool('stack','osc_cs',true);
      stackmenu1.osc_preserve_r_nebula1.checked:=Sett.ReadBool('stack','osc_pr',true);
      dum:=Sett.ReadString('stack','osc_cw','');if dum<>'' then   stackmenu1.osc_smart_smooth_width1.text:=dum;
      dum:=Sett.ReadString('stack','osc_sd','');  if dum<>'' then stackmenu1.osc_smart_colour_sd1.text:=dum;

      stackmenu1.lrgb_auto_level1.checked:=Sett.ReadBool('stack','lrgb_al',true);
      stackmenu1.green_purple_filter1.checked:=Sett.ReadBool('stack','green_fl',false);
      stackmenu1.lrgb_colour_smooth1.checked:=Sett.ReadBool('stack','lrgb_cs',true);
      stackmenu1.lrgb_preserve_r_nebula1.checked:=Sett.ReadBool('stack','lrgb_pr',true);
      dum:=Sett.ReadString('stack','lrgb_sw','');if dum<>'' then stackmenu1.lrgb_smart_smooth_width1.text:=dum;
      dum:=Sett.ReadString('stack','lrgb_sd','');if dum<>'' then  stackmenu1.lrgb_smart_colour_sd1.text:=dum;

      stackmenu1.ignore_header_solution1.Checked:= Sett.ReadBool('stack','ignore_header_solution',true);
      stackmenu1.Equalise_background1.checked:= Sett.ReadBool('stack','equalise_background',true);{for mosaic mode}
      stackmenu1.merge_overlap1.checked:= Sett.ReadBool('stack','merge_overlap',true);{for mosaic mode}

      stackmenu1.classify_object1.checked:= Sett.ReadBool('stack','classify_object',false);
      stackmenu1.classify_filter1.checked:= Sett.ReadBool('stack','classify_filter',false);

      stackmenu1.classify_dark_temperature1.checked:= Sett.ReadBool('stack','classify_dark_temperature',false);
      stackmenu1.classify_dark_exposure1.checked:= Sett.ReadBool('stack','classify_dark_exposure',false);
      stackmenu1.classify_flat_filter1.checked:= Sett.ReadBool('stack','classify_flat_filter',false);
      stackmenu1.classify_dark_date1.checked:= Sett.ReadBool('stack','classify_dark_date',false);
      stackmenu1.classify_flat_date1.checked:= Sett.ReadBool('stack','classify_flat_date',false);
      stackmenu1.classify_flat_exposure1.checked:= Sett.ReadBool('stack','classify_flat_exposure',false);

      stackmenu1.add_time1.checked:= Sett.ReadBool('stack','add_time',false); {add time to resulting stack file name}

      stackmenu1.uncheck_outliers1.checked:= Sett.ReadBool('stack','uncheck_outliers',false);

      stackmenu1.blur_factor1.text:= Sett.ReadString('stack','blur_factor','');

      stackmenu1.use_manual_alignment1.checked:=Sett.ReadString('stack','align_method','')='4';
      stackmenu1.use_astrometry_internal1.checked:=Sett.ReadString('stack','align_method','')='3';
      stackmenu1.use_star_alignment1.checked:=Sett.ReadString('stack','align_method','')='2';
      stackmenu1.use_ephemeris_alignment1.checked:=Sett.ReadString('stack','align_method','')='1';

      stackmenu1.write_log1.Checked:=Sett.ReadBool('stack','write_log',true);{write to log file}
      stackmenu1.align_blink1.Checked:=Sett.ReadBool('stack','align_blink',true);{blink}
      stackmenu1.timestamp1.Checked:=Sett.ReadBool('stack','time_stamp',true);{blink}

      stackmenu1.force_oversize1.Checked:=Sett.ReadBool('stack','force_slow',false);
      stackmenu1.calibrate_prior_solving1.Checked:=Sett.ReadBool('stack','calibrate_prior_solving',false);

      dum:=Sett.ReadString('stack','star_database',''); if dum<>'' then stackmenu1.star_database1.text:=dum;
      dum:=Sett.ReadString('stack','solve_search_field',''); if dum<>'' then stackmenu1.search_fov1.text:=dum;

      dum:=Sett.ReadString('stack','radius_search',''); if dum<>'' then stackmenu1.radius_search1.text:=dum;
      dum:=Sett.ReadString('stack','quad_tolerance',''); if dum<>'' then stackmenu1.quad_tolerance1.text:=dum;
      dum:=Sett.ReadString('stack','maximum_stars',''); if dum<>'' then stackmenu1.max_stars1.text:=dum;
      dum:=Sett.ReadString('stack','min_star_size',''); if dum<>'' then stackmenu1.min_star_size1.text:=dum;
      dum:=Sett.ReadString('stack','min_star_size_stacking',''); if dum<>'' then stackmenu1.min_star_size_stacking1.text:=dum;

      dum:=Sett.ReadString('stack','manual_centering',''); if dum<>'' then stackmenu1.manual_centering1.text:=dum;

      dum:=Sett.ReadString('stack','downsample',''); if dum<>'' then stackmenu1.downsample_for_solving1.text:=dum;

      stackmenu1.apply_normalise_filter1.checked:=Sett.ReadBool('stack','normalise_f',true);{apply normalise filter on (OSC) flat prior to stacking}
      dum:=Sett.ReadString('stack','oversize','');if dum<>'' then stackmenu1.oversize1.text:=dum;
      dum:=Sett.ReadString('stack','sd_factor',''); if dum<>'' then stackmenu1.sd_factor1.text:=dum;

      dum:=Sett.ReadString('stack','most_common_filter_radius',''); if dum<>'' then stackmenu1.most_common_filter_radius1.text:=dum;

      dum:=Sett.ReadString('stack','extract_background_box_size',''); if dum<>'' then stackmenu1.extract_background_box_size1.text:=dum;
      dum:=Sett.ReadString('stack','dark_areas_box_size',''); if dum<>'' then stackmenu1.dark_areas_box_size1.text:=dum;
      dum:=Sett.ReadString('stack','ring_equalise_factor',''); if dum<>'' then stackmenu1.ring_equalise_factor1.text:=dum;

      dum:=Sett.ReadString('stack','gradient_filter_factor',''); if dum<>'' then stackmenu1.gradient_filter_factor1.text:=dum;


      dum:=Sett.ReadString('stack','bayer_pat',''); if dum<>'' then stackmenu1.bayer_pattern1.text:=dum;

      dum:=Sett.ReadString('stack','red_filter1',''); if dum<>'' then stackmenu1.red_filter1.text:=dum;
      dum:=Sett.ReadString('stack','red_filter2',''); if dum<>'' then stackmenu1.red_filter2.text:=dum;

      dum:=Sett.ReadString('stack','green_filter1',''); if dum<>'' then stackmenu1.green_filter1.text:=dum;
      dum:=Sett.ReadString('stack','green_filter2',''); if dum<>'' then stackmenu1.green_filter2.text:=dum;
      dum:=Sett.ReadString('stack','blue_filter1',''); if dum<>'' then stackmenu1.blue_filter1.text:=dum;
      dum:=Sett.ReadString('stack','blue_filter2',''); if dum<>'' then stackmenu1.blue_filter2.text:=dum;
      dum:=Sett.ReadString('stack','luminance_filter1',''); if dum<>'' then stackmenu1.luminance_filter1.text:=dum;
      dum:=Sett.ReadString('stack','luminance_filter2',''); if dum<>'' then stackmenu1.luminance_filter2.text:=dum;

      dum:=Sett.ReadString('stack','rr_factor',''); if dum<>'' then stackmenu1.rr1.text:=dum;
      dum:=Sett.ReadString('stack','rg_factor',''); if dum<>'' then stackmenu1.rg1.text:=dum;
      dum:=Sett.ReadString('stack','rb_factor',''); if dum<>'' then stackmenu1.rb1.text:=dum;

      dum:=Sett.ReadString('stack','gr_factor',''); if dum<>'' then stackmenu1.gr1.text:=dum;
      dum:=Sett.ReadString('stack','gg_factor',''); if dum<>'' then stackmenu1.gg1.text:=dum;
      dum:=Sett.ReadString('stack','gb_factor',''); if dum<>'' then stackmenu1.gb1.text:=dum;

      dum:=Sett.ReadString('stack','br_factor',''); if dum<>'' then stackmenu1.br1.text:=dum;
      dum:=Sett.ReadString('stack','bg_factor',''); if dum<>'' then stackmenu1.bg1.text:=dum;
      dum:=Sett.ReadString('stack','bb_factor',''); if dum<>'' then stackmenu1.bb1.text:=dum;

      dum:=Sett.ReadString('stack','red_filter_add',''); if dum<>'' then stackmenu1.red_filter_add1.text:=dum;
      dum:=Sett.ReadString('stack','green_filter_add',''); if dum<>'' then stackmenu1.green_filter_add1.text:=dum;
      dum:=Sett.ReadString('stack','blue_filter_add',''); if dum<>'' then stackmenu1.blue_filter_add1.text:=dum;


     {Six colour correction factors}
      dum:=Sett.ReadString('stack','add_value_R',''); if dum<>'' then stackmenu1.add_valueR1.text:=dum;
      dum:=Sett.ReadString('stack','add_value_G',''); if dum<>'' then stackmenu1.add_valueG1.text:=dum;
      dum:=Sett.ReadString('stack','add_value_B',''); if dum<>'' then stackmenu1.add_valueB1.text:=dum;
      dum:=Sett.ReadString('stack','multiply_R',''); if dum<>'' then stackmenu1.multiply_red1.text:=dum;
      dum:=Sett.ReadString('stack','multiply_G',''); if dum<>'' then stackmenu1.multiply_green1.text:=dum;
      dum:=Sett.ReadString('stack','multiply_B',''); if dum<>'' then stackmenu1.multiply_blue1.text:=dum;

      dum:=Sett.ReadString('stack','smart_smooth_width',''); if dum<>'' then stackmenu1.smart_smooth_width1.text:=dum;

      dum:=Sett.ReadString('stack','star_level_colouring',''); if dum<>'' then stackmenu1.star_level_colouring1.text:=dum;
      dum:=Sett.ReadString('stack','filter_artificial_colouring',''); if dum<>'' then stackmenu1.filter_artificial_colouring1.text:=dum;
      dum:=Sett.ReadString('stack','resize_factor',''); if dum<>'' then stackmenu1.resize_factor1.text:=dum;
      dum:=Sett.ReadString('stack','mark_outliers_upto',''); if dum<>'' then stackmenu1.mark_outliers_upto1.text:=dum;
      dum:=Sett.ReadString('stack','flux_aperture',''); if dum<>'' then stackmenu1.flux_aperture1.text:=dum;
      dum:=Sett.ReadString('stack','annulus_radius',''); if dum<>'' then stackmenu1.annulus_radius1.text:=dum;
      stackmenu1.checkBox_annotate1.checked:= Sett.ReadBool('stack','ph_annotate',true);


      dum:=Sett.ReadString('stack','sigma_decolour',''); if dum<>'' then stackmenu1.sigma_decolour1.text:=dum;
      dum:=Sett.ReadString('stack','sd_factor_list',''); if dum<>'' then stackmenu1.sd_factor_list1.text:=dum;

      dum:=Sett.ReadString('stack','noisefilter_blur',''); if dum<>'' then stackmenu1.noisefilter_blur1.text:=dum;
      dum:=Sett.ReadString('stack','noisefilter_sd',''); if dum<>'' then stackmenu1.noisefilter_sd1.text:=dum;

      c:=Sett.ReadInteger('stack','hue_fuzziness',987654321); if c<>987654321 then stackmenu1.hue_fuzziness1.position:=c;
      c:=Sett.ReadInteger('stack','saturation_tolerance',987654321);  if c<>987654321 then stackmenu1.saturation_tolerance1.position:=c;

      stackmenu1.remove_luminance1.checked:= Sett.ReadBool('stack','remove_luminance',false);

      c:=Sett.ReadInteger('stack','sample_size',987654321);if c<>987654321 then stackmenu1.sample_size1.itemindex:=c;

      stackmenu1.equinox1.itemindex:=Sett.ReadInteger('stack','equinox',987654321);if c<>987654321 then stackmenu1.equinox1.itemindex:=c;
      stackmenu1.mount_write_wcs1.Checked:=Sett.ReadBool('stack','wcs',true);{use wcs files for mount}

      obscode:=Sett.ReadString('stack','obscode',''); {photometry}
      c:=Sett.ReadInteger('stack','delim_pos',987654321);if c<>987654321 then delim_pos:=c;

      stackmenu1.live_stacking_path1.caption:=Sett.ReadString('live','live_stack_dir','');
      stackmenu1.monitoring_path1.caption:=Sett.ReadString('live','monitor_dir','');
      stackmenu1.write_jpeg1.Checked:=Sett.ReadBool('live','write_jpeg',false);{live stacking}
      stackmenu1.interim_to_clipboard1.Checked:=Sett.ReadBool('live','to_clipboard',false);{live stacking}

      c:=Sett.ReadInteger('live','live_inspect',987654321);if c<>987654321 then stackmenu1.monitor_action1.itemindex:=c;
      stackmenu1.monitor_applydarkflat1.checked:= Sett.ReadBool('live','monitor_df',false);



      c:=Sett.ReadInteger('insp','insp_left',987654321); if c<>987654321 then insp_left:=c;
      c:=Sett.ReadInteger('insp','insp_top',987654321); if c<>987654321 then insp_top:=c;
      measuring_angle:=Sett.Readstring('insp','insp_angle','0');
      contour_check:=Sett.ReadBool('insp','contour',false);
      voronoi_check:=Sett.ReadBool('insp','voronoi',false);
      values_check:=Sett.ReadBool('insp','values',true);
      vectors_check:=Sett.ReadBool('insp','vectors',true);
      normalise_mode:=Sett.ReadInteger('insp','rawbayer',0);
      three_corners:=Sett.ReadBool('insp','3corners',false);
      extra_stars:=Sett.ReadBool('insp','extra_stars',false);

      listviews_begin_update; {stop updating listviews}

      c:=0;
      repeat {add lights}
         dum:=Sett.ReadString('files','image'+inttostr(c),'');
         if ((dum<>'') and (fileexists(dum))) then listview_add(stackmenu1.listview1,dum,Sett.ReadBool('files','image'+inttostr(c)+'_check',true),L_nr);
         inc(c);
      until (dum='');

      c:=0;
      repeat {add  darks}
        dum:=Sett.ReadString('files','dark'+inttostr(c),'');
        if ((dum<>'') and (fileexists(dum))) then listview_add(stackmenu1.listview2,dum,Sett.ReadBool('files','dark'+inttostr(c)+'_check',true),D_nr);
        inc(c);
      until (dum='');

      c:=0;
      repeat {add  flats}
        dum:=Sett.ReadString('files','flat'+inttostr(c),'');
        if ((dum<>'') and (fileexists(dum))) then listview_add(stackmenu1.listview3,dum,Sett.ReadBool('files','flat'+inttostr(c)+'_check',true),F_nr);
        inc(c);
      until (dum='');

      c:=0;
      repeat {add flat darks}
        dum:=Sett.ReadString('files','flat_dark'+inttostr(c),'');
        if ((dum<>'') and (fileexists(dum))) then listview_add(stackmenu1.listview4,dum,Sett.ReadBool('files','flat_dark'+inttostr(c)+'_check',true),D_nr);
        inc(c);
      until (dum='');

      c:=0;
      repeat {add blink files}
        dum:=Sett.ReadString('files','blink'+inttostr(c),'');
        if ((dum<>'') and (fileexists(dum))) then listview_add(stackmenu1.listview6,dum,Sett.ReadBool('files','blink'+inttostr(c)+'_check',true),B_nr);
        inc(c);
      until (dum='');

      c:=0;
      repeat {add photometry files}
        dum:=Sett.ReadString('files','photometry'+inttostr(c),'');
        if ((dum<>'') and (fileexists(dum))) then listview_add(stackmenu1.listview7,dum,Sett.ReadBool('files','photometry'+inttostr(c)+'_check',true),P_nr);
        inc(c);
      until (dum='');

      c:=0;
      repeat {add inspector files}
        dum:=Sett.ReadString('files','inspector'+inttostr(c),'');
        if ((dum<>'') and (fileexists(dum))) then  listview_add(stackmenu1.listview8,dum,Sett.ReadBool('files','inspector'+inttostr(c)+'_check',true),L_nr);
        inc(c);
      until (dum='');

     stackmenu1.visible:=((paramcount=0) and (Sett.ReadBool('stack','stackmenu_visible',false) ) );{do this last, so stackmenu.onshow updates the setting correctly}
     listviews_end_update; {start updating listviews. Do this after setting stack menus visible. This is faster.}
    end;

  finally {also for error it end's here}
    Sett.Free;
  end;

//  mainwindow.Caption := floattostr((GetTickCount-t1)/1000);
end;


procedure save_settings(lpath:string);
var
    Sett : TmemIniFile;
    c    : integer;
begin
  try
    Sett := TmemIniFile.Create(lpath);
    sett.clear; {clear any section in the old ini file}
    with mainwindow do
    begin
      sett.writeInteger('main','window_left',mainwindow.left);
      sett.writeInteger('main','window_top',mainwindow.top);
      sett.writeInteger('main','window_height',mainwindow.height);
      sett.writeInteger('main','window_width',mainwindow.width);

      sett.writeInteger('main','font_color',font_color);
      sett.writeInteger('main','font_size',font_size);
      sett.writestring('main','font_name2',font_name);
      sett.writestring('main','font_style',StyleToStr(font_style));
      sett.writeInteger('main','font_charset',font_charset);
      sett.writeInteger('main','pedestal',pedestal);


      sett.writeInteger('main','minimum_position',MINIMUM1.position);
      sett.writeInteger('main','maximum_position',maximum1.position);
      sett.writeInteger('main','range',range1.itemindex);

      sett.writeInteger('main','saturation_factor',saturation_factor_plot1.position);


      sett.writeInteger('main','polynomial',polynomial1.itemindex);

      sett.writeInteger('main','thumbnails_width',thumbnails1_width);
      sett.writeInteger('main','thumbnails_height',thumbnails1_height);

      sett.writeBool('main','inversemousewheel',inversemousewheel1.checked);
      sett.writeBool('main','fliphorizontal',flip_horizontal1.checked);
      sett.writeBool('main','flipvertical',flip_vertical1.checked);
      sett.writeBool('main','annotations',annotations_visible1.checked);
      sett.writeBool('main','north_east',northeast1.checked);
      sett.writeBool('main','mount_position',mountposition1.checked);
      sett.writeBool('main','constellations',constellations1.checked);
      sett.writeBool('main','grid',grid1.checked);
      sett.writeBool('main','pos_date',positionanddate1.checked);
      sett.writeBool('main','freetxt',freetext1.checked);
      sett.writestring('main','f_text',freetext);


      sett.writeBool('main','add_marker',add_marker_position1.checked);

      sett.writeBool('main','preview_demosaic',mainwindow.preview_demosaic1.Checked);
      sett.writeBool('main','s_overwrite',mainwindow.batch_overwrite1.checked);
      sett.writeBool('main','add_sip',mainwindow.add_sip_check1.Checked);
      sett.writeBool('main','add_lim_magn',mainwindow.add_limiting_magn_check1.Checked);

      sett.writestring('main','ra',ra1.text);
      sett.writestring('main','dec',dec1.text);
      sett.writestring('main','gamma',stretch1.text);
      sett.writestring('main','marker_position',marker_position);


      sett.writestring('main','last_file',filename2);


      sett.writestring('main','mpcorb_path',mpcorb_path);{asteroids}
      sett.writestring('main','cometels_path',cometels_path);{comets}

      sett.writeString('main','maxcount',maxcount_asteroid);{asteroids}
      sett.writeString('main','maxmag',maxmag_asteroid);{asteroids}

      sett.writeBool('main','font_follows',font_follows_diameter);{asteroids}
      sett.writeBool('main','showfullnames',showfullnames);{asteroids}
      sett.writeBool('main','showmagnitude',showmagnitude);{asteroids}
      sett.writeBool('main','add_date',add_date);{asteroids}
      sett.writeString('main','p1',encrypt(lat_default));{default latitude}
      sett.writeString('main','p2',encrypt(long_default));{default longitude}


      sett.writeInteger('main','annotation_color',annotation_color);
      sett.writeInteger('main','annotation_diameter',annotation_diameter);

      sett.writeBool('main','add_annotations',add_annotations);{for asteroids}

      sett.writestring('main','cygwin_path',cygwin_path);
      sett.writeBool('main','show_console',show_console);
      sett.writestring('main','astrometry_extra_options',astrometry_extra_options);

      sett.writestring('main','sqm_key',sqm_key+'*' );{add a * to prevent the spaces are removed.Should be at least 8 char}
      sett.writestring('main','centaz_key',centaz_key+'*');{add a * to prevent the spaces are removed}

      for c:=0 to recent_files.count-1  do {add recent files}
        sett.writestring('main','recent'+inttostr(c),recent_files[c]);

      {########## stackmenu settings #############}
      sett.writebool('stack','stackmenu_visible',stackmenu1.visible);

      sett.writeInteger('stack','stackmenu_left',stackmenu1.left);
      sett.writeInteger('stack','stackmenu_top',stackmenu1.top);
      sett.writeInteger('stack','stackmenu_height',stackmenu1.height);
      sett.writeInteger('stack','stackmenu_width',stackmenu1.width);

      sett.writeInteger('stack','stack_method',stackmenu1.stack_method1.itemindex);

      sett.writeInteger('stack','mosaic_width',stackmenu1.mosaic_width1.position);
      sett.writeInteger('stack','mosaic_crop',stackmenu1.mosaic_crop1.position);

      sett.writeInteger('stack','flat_combine_method',stackmenu1.flat_combine_method1.itemindex);
      sett.writeInteger('stack','stack_tab',stackmenu1.pagecontrol1.tabindex);

      sett.writeString('stack','bayer_pat',stackmenu1.bayer_pattern1.text);

      sett.writeInteger('stack','demosaic_method2',stackmenu1.demosaic_method1.itemindex);
      sett.writeInteger('stack','conv_progr',stackmenu1.raw_conversion_program1.itemindex);

      sett.writeBool('stack','osc_color_convert',stackmenu1.make_osc_color1.checked);
      sett.writeBool('stack','osc_al',stackmenu1.osc_auto_level1.checked);
      sett.writeBool('stack','osc_cs',stackmenu1.osc_colour_smooth1.checked);
      sett.writeBool('stack','osc_pr',stackmenu1.osc_preserve_r_nebula1.checked);
      sett.writeString('stack','osc_sw',stackmenu1.osc_smart_smooth_width1.text);
      sett.writestring('stack','osc_sd',stackmenu1.osc_smart_colour_sd1.text);

      sett.writeBool('stack','lrgb_al',stackmenu1.lrgb_auto_level1.checked);
      sett.writeBool('stack','green_fl',stackmenu1.green_purple_filter1.checked);

      sett.writeBool('stack','lrgb_cs',stackmenu1.lrgb_colour_smooth1.checked);
      sett.writeBool('stack','lrgb_pr',stackmenu1.lrgb_preserve_r_nebula1.checked);
      sett.writestring('stack','lrgb_sw',stackmenu1.lrgb_smart_smooth_width1.text);
      sett.writestring('stack','lrgb_sd',stackmenu1.lrgb_smart_colour_sd1.text);

      sett.writeBool('stack','ignore_header_solution',stackmenu1.ignore_header_solution1.Checked);
      sett.writeBool('stack','equalise_background',stackmenu1.Equalise_background1.Checked);
      sett.writeBool('stack','merge_overlap',stackmenu1.merge_overlap1.Checked);


      sett.writeBool('stack','classify_object',stackmenu1.classify_object1.Checked);
      sett.writeBool('stack','classify_filter',stackmenu1.classify_filter1.Checked);

      sett.writeBool('stack','classify_dark_temperature',stackmenu1.classify_dark_temperature1.Checked);
      sett.writeBool('stack','classify_dark_exposure',stackmenu1.classify_dark_exposure1.Checked);
      sett.writeBool('stack','classify_flat_filter',stackmenu1.classify_flat_filter1.Checked);
      sett.writeBool('stack','classify_dark_date',stackmenu1.classify_dark_date1.Checked);
      sett.writeBool('stack','classify_flat_date',stackmenu1.classify_flat_date1.Checked);
      sett.writeBool('stack','classify_flat_exposure',stackmenu1.classify_flat_exposure1.Checked);

      sett.writeBool('stack','add_time',stackmenu1.add_time1.Checked);

      sett.writeBool('stack','uncheck_outliers',stackmenu1.uncheck_outliers1.Checked);

      sett.writeBool('stack','write_log',stackmenu1.write_log1.checked);{write log to file}

      sett.writeBool('stack','align_blink',stackmenu1.align_blink1.checked);{blink}
      sett.writeBool('stack','time_stamp',stackmenu1.timestamp1.checked);{blink}

      sett.writeBool('stack','force_slow',stackmenu1.force_oversize1.checked);
      sett.writeBool('stack','calibrate_prior_solving',stackmenu1.calibrate_prior_solving1.checked);


      if  stackmenu1.use_manual_alignment1.checked then sett.writestring('stack','align_method','4')
      else
      if  stackmenu1.use_astrometry_internal1.checked then sett.writestring('stack','align_method','3')
      else
      if  stackmenu1.use_star_alignment1.checked then sett.writestring('stack','align_method','2')
      else
      if  stackmenu1.use_ephemeris_alignment1.checked then  sett.writestring('stack','align_method','1');

      sett.writestring('stack','star_database',stackmenu1.star_database1.text);
      sett.writestring('stack','solve_search_field',stackmenu1.search_fov1.text);
      sett.writestring('stack','radius_search',stackmenu1.radius_search1.text);
      sett.writestring('stack','quad_tolerance',stackmenu1.quad_tolerance1.text);
      sett.writestring('stack','maximum_stars',stackmenu1.max_stars1.text);
      sett.writestring('stack','min_star_size',stackmenu1.min_star_size1.text);
      sett.writestring('stack','min_star_size_stacking',stackmenu1.min_star_size_stacking1.text);

      sett.writestring('stack','manual_centering',stackmenu1.manual_centering1.text);

      sett.writestring('stack','downsample',stackmenu1.downsample_for_solving1.text);

      sett.writestring('stack','oversize',stackmenu1.oversize1.text);
      sett.writebool('stack','normalise_f',stackmenu1.apply_normalise_filter1.checked);

      sett.writestring('stack','sd_factor',stackmenu1.sd_factor1.text);
      sett.writestring('stack','blur_factor',stackmenu1.blur_factor1.text);
      sett.writestring('stack','most_common_filter_radius',stackmenu1.most_common_filter_radius1.text);

      sett.writestring('stack','extract_background_box_size',stackmenu1.extract_background_box_size1.text);
      sett.writestring('stack','dark_areas_box_size',stackmenu1.dark_areas_box_size1.text);
      sett.writestring('stack','ring_equalise_factor',stackmenu1.ring_equalise_factor1.text);

      sett.writestring('stack','gradient_filter_factor',stackmenu1.gradient_filter_factor1.text);

      sett.writestring('stack','red_filter1',stackmenu1.red_filter1.text);
      sett.writestring('stack','red_filter2',stackmenu1.red_filter2.text);
      sett.writestring('stack','green_filter1',stackmenu1.green_filter1.text);
      sett.writestring('stack','green_filter2',stackmenu1.green_filter2.text);
      sett.writestring('stack','blue_filter1',stackmenu1.blue_filter1.text);
      sett.writestring('stack','blue_filter2',stackmenu1.blue_filter2.text);
      sett.writestring('stack','luminance_filter1',stackmenu1.luminance_filter1.text);
      sett.writestring('stack','luminance_filter2',stackmenu1.luminance_filter2.text);

      sett.writestring('stack','rr_factor',stackmenu1.rr1.text);
      sett.writestring('stack','rg_factor',stackmenu1.rg1.text);
      sett.writestring('stack','rb_factor',stackmenu1.rb1.text);

      sett.writestring('stack','gr_factor',stackmenu1.gr1.text);
      sett.writestring('stack','gg_factor',stackmenu1.gg1.text);
      sett.writestring('stack','gb_factor',stackmenu1.gb1.text);

      sett.writestring('stack','br_factor',stackmenu1.br1.text);
      sett.writestring('stack','bg_factor',stackmenu1.bg1.text);
      sett.writestring('stack','bb_factor',stackmenu1.bb1.text);

      sett.writestring('stack','red_filter_add',stackmenu1.red_filter_add1.text);
      sett.writestring('stack','green_filter_add',stackmenu1.green_filter_add1.text);
      sett.writestring('stack','blue_filter_add',stackmenu1.blue_filter_add1.text);

      {Colour correction factors}
      sett.writestring('stack','add_value_R',stackmenu1.add_valueR1.text);
      sett.writestring('stack','add_value_G',stackmenu1.add_valueG1.text);
      sett.writestring('stack','add_value_B',stackmenu1.add_valueB1.text);
      sett.writestring('stack','multiply_R',stackmenu1.multiply_red1.text);
      sett.writestring('stack','multiply_G',stackmenu1.multiply_green1.text);
      sett.writestring('stack','multiply_B',stackmenu1.multiply_blue1.text);

      sett.writestring('stack','smart_smooth_width',stackmenu1.smart_smooth_width1.text);

      sett.writestring('stack','star_level_colouring',stackmenu1.star_level_colouring1.text);
      sett.writestring('stack','filter_artificial_colouring',stackmenu1.filter_artificial_colouring1.text);

      sett.writestring('stack','resize_factor',stackmenu1.resize_factor1.text);

      sett.writestring('stack','mark_outliers_upto',stackmenu1.mark_outliers_upto1.text);
      sett.writestring('stack','flux_aperture',stackmenu1.flux_aperture1.text);
      sett.writestring('stack','annulus_radius',stackmenu1.annulus_radius1.text);

      sett.writeBool('stack','ph_annotate',stackmenu1.checkBox_annotate1.checked);


      sett.writestring('stack','sigma_decolour',stackmenu1.sigma_decolour1.text);

      sett.writestring('stack','sd_factor_list',stackmenu1.sd_factor_list1.text);
      sett.writestring('stack','noisefilter_blur',stackmenu1.noisefilter_blur1.text);
      sett.writestring('stack','noisefilter_sd',stackmenu1.noisefilter_sd1.text);

      sett.writeInteger('stack','hue_fuzziness',stackmenu1.hue_fuzziness1.position);
      sett.writeInteger('stack','saturation_tolerance',stackmenu1.saturation_tolerance1.position);
      sett.writeBool('stack','remove_luminance',stackmenu1.remove_luminance1.checked);{asteroids}

      sett.writeInteger('stack','sample_size',stackmenu1.sample_size1.itemindex);

      sett.writestring('stack','obscode',obscode);
      sett.writeInteger('stack','delim_pos',delim_pos);

      sett.writeInteger('stack','equinox',stackmenu1.equinox1.itemindex);
      sett.writeBool('stack','wcs',stackmenu1.mount_write_wcs1.Checked);{uses wcs file for menu mount}

      sett.writestring('live','live_stack_dir',stackmenu1.live_stacking_path1.caption);{live stacking}
      sett.writestring('live','monitor_dir',stackmenu1.monitoring_path1.caption);
      sett.writeBool('live','write_jpeg',stackmenu1.write_jpeg1.checked);{live stacking}
      sett.writeBool('live','to_clipboard',stackmenu1.interim_to_clipboard1.checked);{live stacking}

      sett.writeInteger('live','live_inspect',stackmenu1.monitor_action1.itemindex);
      sett.writeBool('live','monitor_df',stackmenu1.monitor_applydarkflat1.checked);{live monitoring}


      sett.writeInteger('insp','insp_left',insp_left);{position window}
      sett.writeInteger('insp','insp_top',insp_top);
      sett.writestring('insp','insp_angle',measuring_angle);
      sett.writeBool('insp','contour',contour_check);
      sett.writeBool('insp','voronoi',voronoi_check);
      sett.writeBool('insp','values',values_check);
      sett.writeBool('insp','vectors',vectors_check);
      sett.writeInteger('insp','rawbayer',normalise_mode);
      sett.writebool('insp','3corners',three_corners);
      sett.writebool('insp','extra_stars',extra_stars);

      {### save listview values ###}
      for c:=0 to stackmenu1.ListView1.items.count-1 do {add light images}
      begin
        sett.writestring('files','image'+inttostr(c),stackmenu1.ListView1.items[c].caption);
        sett.writeBool('files','image'+inttostr(c)+'_check',stackmenu1.ListView1.items[c].Checked);
      end;

      for c:=0 to stackmenu1.ListView2.items.count-1  do {add dark files}
      begin
        sett.writestring('files','dark'+inttostr(c),stackmenu1.ListView2.items[c].caption);
        sett.writeBool('files','dark'+inttostr(c)+'_check',stackmenu1.ListView2.items[c].Checked);
      end;
      for c:=0 to stackmenu1.ListView3.items.count-1  do {add flat files}
      begin
        sett.writestring('files','flat'+inttostr(c),stackmenu1.ListView3.items[c].caption);
        sett.writeBool('files','flat'+inttostr(c)+'_check',stackmenu1.ListView3.items[c].Checked);
      end;
      for c:=0 to stackmenu1.ListView4.items.count-1  do {add flat_dark files}
      begin
        sett.writestring('files','flat_dark'+inttostr(c),stackmenu1.ListView4.items[c].caption);
        sett.writeBool('files','flat_dark'+inttostr(c)+'_check',stackmenu1.ListView4.items[c].Checked);
      end;
      for c:=0 to stackmenu1.ListView6.items.count-1  do {add blink files}
      begin
        sett.writestring('files','blink'+inttostr(c),stackmenu1.ListView6.items[c].caption);
        sett.writeBool('files','blink'+inttostr(c)+'_check',stackmenu1.ListView6.items[c].Checked);
      end;
      for c:=0 to stackmenu1.ListView7.items.count-1  do {add photometry files}
      begin
        sett.writestring('files','photometry'+inttostr(c),stackmenu1.ListView7.items[c].caption);
        sett.writeBool('files','photometry'+inttostr(c)+'_check',stackmenu1.ListView7.items[c].Checked);
      end;
      for c:=0 to stackmenu1.ListView8.items.count-1  do {add inspector files}
      begin
        sett.writestring('files','inspector'+inttostr(c),stackmenu1.ListView8.items[c].caption);
        sett.writeBool('files','inspector'+inttostr(c)+'_check',stackmenu1.ListView8.items[c].Checked);
      end;

    end;{mainwindow}
  finally
    Sett.Free; {Note error detection seems not possible with tmeminifile. Tried everything}
  end;
end;


procedure save_settings2;
begin
  save_settings(user_path+'astap.cfg');
end;


procedure Tmainwindow.savesettings1Click(Sender: TObject);
begin
  savedialog1.filename:=user_path+'astap.cfg';
  savedialog1.Filter := 'configuration file|*.cfg';
  if savedialog1.execute then
    save_settings(savedialog1.filename);
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

  if sender<>nil then {not from plot_fits, redraw required}
  begin
    plot_north; {draw arrow or clear indication position north depending on value head.cd1_1}
  end;
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


function extract_exposure_from_filename(filename8: string):integer; {try to extract head.exposure from filename}
var
  exposure_str  :string;
  i,x,err      : integer;
  ch : char;
begin
  {try to reconstruct head.exposure time from filename}
  result:=0;
  exposure_str:='';
  filename8:=uppercase(extractfilename(filename8));
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
  {try to reconstruct head.exposure time from filename}
  result:=999;{unknow temperature}
  temp_str:='';
  filename8:=uppercase(extractfilename(filename8));
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




function convert_raw(loadfile,savefile :boolean;var filename3: string;var img: image_array): boolean; {convert raw to fits file using DCRAW or LibRaw. filename3 will be update with the new file extension e.g. .CR2.fits}
var
  filename4 :string;
  JD2                               : double;
  conv_index                        : integer;
  commando,param  :string;

begin
  result:=true; {assume success}
  conv_index:=stackmenu1.raw_conversion_program1.itemindex; {DCRaw or libraw}

  {conversion direct to FITS}
  if conv_index<=1 then {Libraw}
  begin
    if conv_index=1 then param:='-i' else param:='-f';
    result:=true; {assume success again}
    {$ifdef mswindows}
    if fileexists(application_path+'unprocessed_raw.exe')=false then
      result:=false {failure}
    else
    begin
       ExecuteAndWait(application_path+'unprocessed_raw.exe '+param+' "'+filename3+'"',false);{execute command and wait}
       filename4:=FileName3+'.fits';{direct to fits using modified version of unprocessed_raw}
     end;
    {$endif}
    {$ifdef linux}
    if fileexists(application_path+'unprocessed_raw-astap')=false then
    begin {try other installed executables}
      if fileexists('/usr/lib/libraw/unprocessed_raw')=false then
      begin
        if fileexists('/usr/bin/unprocessed_raw')=false then
          result:=false {failure}
        else
        begin
          execute_unix2('/usr/bin/unprocessed_raw "'+filename3+'"');
          filename4:=FileName3+'.pgm';{ filename.NEF.pgm}
        end
      end
      else
      begin
        execute_unix2('/usr/lib/libraw/unprocessed_raw "'+filename3+'"');
        filename4:=FileName3+'.pgm';{ filename.NEF.pgm}
      end
    end
    else
    begin
      execute_unix2(application_path+'unprocessed_raw-astap '+param+' "'+filename3+'"');{direct to fits using modified version of unprocessed_raw}
      filename4:=FileName3+'.fits';{ filename.NEF.pgm}
    end;
   {$endif}
    {$ifdef Darwin}{MacOS}
    if fileexists(application_path+'/unprocessed_raw')=false then
       result:=false {failure}
    else
    begin
      execute_unix2(application_path+'/unprocessed_raw '+param+' "'+filename3+'"'); {direct to fits using modified version of unprocessed_raw}
      filename4:=FileName3+'.fits';{ filename.NEF.pgm}
    end;
   {$endif}
   {############################################################################################
       Linux, compile unprocessed_raw under Linux:
       git clone https://github.com/han-k59/LibRaw-with-16-bit-FITS-support
       cd LibRaw-with-16-bit-FITS-support
       autoreconf --install
        ./configure --enable-shared=no
        make clean && make # to rebuild

        This will remove shared (.so) libraries and will build static (.a) instead

   ############################################################################################
       Windows, in Linux use mingw cross-compiler to make Windows executables:
       git clone https://github.com/han-k59/LibRaw-with-16-bit-FITS-support
       cd LibRaw-with-16-bit-FITS-support
       make clean -f Makefile.mingw # to clean up
       make  -f Makefile.mingw CXX=x86_64-w64-mingw32-g++ CC=x86_64-w64-mingw32-gcc

       for 32 bit Windows version
       make clean -f Makefile.mingw # to clean up
       make -f Makefile.mingw CXX=i686-w64-mingw32-g++ CC=i686-w64-mingw32-gcc

       To make it work edit the file Makefile.mingw and on third row change:
       CFLAGS=-O3 -I. -w -static-libgcc -static-libstdc++

       You can check the result with the linux file command:
       file unprocessed_raw.exe
       unprocessed_raw.exe: PE32+ executable (console) x86-64, for MS Windows
       file unprocessed_raw.exe
       unprocessed_raw.exe: PE32 executable (console) Intel 80386, for MS Win
       #############################################################################################
       Mac

       git clone https://github.com/han-k59/LibRaw-with-16-bit-FITS-support
       cd LibRaw-with-16-bit-FITS-support
       export LDADD=-mmacosx-version-min=10.10
       make -f Makefile.dist
       #############################################################################################}

  end;


  if conv_index=2  then {dcraw specified}
  begin
    if ExtractFileExt(filename3)='.CR3' then begin result:=false; exit; end; {dcraw can't process .CR3}
    commando:='-D -4 -t 0';   {-t 0 disables the rotation}
    {$ifdef mswindows}
    if fileexists(application_path+'dcraw.exe')=false then
      result:=false {failure, try libraw}
    else
      ExecuteAndWait(application_path+'dcraw.exe '+commando+ ' "'+filename3+'"',false);{execute command and wait}

    {$endif}
    {$ifdef Linux}
    if fileexists(application_path+'dcraw-astap')=false then
    begin
      if fileexists('/usr/bin/dcraw-astap')=false then
      begin
        if fileexists('/usr/local/bin/dcraw-astap')=false then


        begin  {try standard dcraw}
          if fileexists('/usr/bin/dcraw')=false then
          begin
            if fileexists('/usr/local/bin/dcraw')=false then
              result:=false {failure}
            else
              execute_unix2('/usr/local/bin/dcraw '+commando+' "'+filename3+'"');
          end
          else
          execute_unix2('/usr/bin/dcraw '+commando+' "'+filename3+'"');
        end {try standard dcraw}


        else
          execute_unix2('/usr/local/bin/dcraw-astap '+commando+' "'+filename3+'"');
      end
      else
      execute_unix2('/usr/bin/dcraw-astap '+commando+' "'+filename3+'"');

    end
    else
      execute_unix2(application_path+'dcraw-astap '+commando+' "'+filename3+'"');
    {$endif}
    {$ifdef Darwin} {MacOS}
    if fileexists(application_path+'/dcraw')=false then
      result:=false {failure, try libraw}
    else
      execute_unix2(application_path+'/dcraw '+commando+' "'+filename3+'"');
    {$endif}
     if result=false then memo2_message('DCRAW executable not found! Will try unprocessed_raw as alternative.')
     else
     filename4:=ChangeFileExt(FileName3,'.pgm');{for DCRaw}
  end;

  if result=false then {no conversion program}
  begin

    if conv_index=2 then
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

    if conv_index<=1 then
    begin {LibRaw}
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

  if ExtractFileExt(filename4)='.pgm' then {pgm file}
  begin
    if load_PPM_PGM_PFM(fileName4,head,img) then {succesfull PGM load}
    begin

      deletefile(filename4);{delete temporary pgm file}
      filename4:=ChangeFileExt(FileName4,'.fits');

      if head.date_obs='' then {no date detected in comments}
      begin
        JD2:=2415018.5+(FileDateToDateTime(fileage(filename3))); {fileage raw, convert to Julian Day by adding factor. filedatatodatetime counts from 30 dec 1899.}
        head.date_obs:=JdToDate(jd2);
        update_text ('DATE-OBS=',#39+head.date_obs+#39);{give start point exposures}
      end;
      update_text ('BAYERPAT=',#39+'????'+#39);{identify raw OSC image}
      add_text   ('HISTORY  ','Converted from '+filename3);
      result:=true;
    end
    else
      result:=false;

    if ((savefile) and (conv_index=2) and (result)) then {PPM interstage file, save to fits, Not required for the new unprocessed_raw-astap}
    begin
      if conv_index=2 {dcraw} then head.set_temperature:=extract_temperature_from_filename(filename4);{including update header}
      update_text('OBJECT  =',#39+extract_objectname_from_filename(filename4)+#39); {spaces will be added/corrected later}
      result:=save_fits(img_buffer,filename4,16,true);{overwrite. Filename2 will be set to fits file}
    end;
    if loadfile=false then  img:=nil;{clear memory}
  end
  else
  begin {fits file created by modified unprocessed_raw}
    if loadfile then
    begin
      result:=load_fits(filename4,true {light},true {load data},true {update memo},0,head,img); {load new fits file}
      if ((result) and (savefile=false)) then
      begin
        deletefile(filename4);{delete temporary fits file}
        filename4:=ChangeFileExt(filename3,'.fits');{rather then creating ".CR3.fits" create extension ".fits" for command line. So ".CR3" result in ".ini" and ".wcs" logs}
      end;
    end;
  end;
  if result then filename3:=filename4; {confirm conversion succes with new fits file name}
end;


function convert_to_fits(var filen: string): boolean; {convert to fits}
var
  ext : string;
begin
  ext:=uppercase(ExtractFileExt(filen));
  result:=false;

  if check_raw_file_extension(ext) then {raw format}
  begin
    result:=convert_raw(false{load},true{save},filen,img_buffer);
  end
  else
  if (ext='.FZ') then {CFITSIO format}
  begin
    result:=unpack_cfitsio(filen); {filename2 contains the new file name}
    if result then filen:=filename2;
  end
  else
  begin
    if ((ext='.PPM') or (ext='.PGM') or (ext='.PFM') or (ext='.PBM')) then {PPM/PGM/ PFM}
      result:=load_PPM_PGM_PFM(filen,head,img_loaded)
    else
    if ext='.XISF' then {XISF}
      result:=load_xisf(filen,head,img_loaded)
    else
    if ((ext='.JPG') or (ext='.JPEG') or (ext='.PNG') or (ext='.TIF') or (ext='.TIFF')) then
      result:=load_tiffpngJPEG(filen,head,img_loaded);

    if result then
    begin
      head.exposure:=extract_exposure_from_filename(filen); {try to extract head.exposure time from filename. Will be added to the header}
      head.set_temperature:=extract_temperature_from_filename(filen);
      update_text('OBJECT  =',#39+extract_objectname_from_filename(filen)+#39); {spaces will be added/corrected later}

      filen:=ChangeFileExt(filen,'.fit');
      result:=save_fits(img_loaded,filen,nrbits,false);
    end;
  end;

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
                                       '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                         '|RAW files|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                         '|PNG, TIFF, JPEG, BMP(*.png,*.tif*, *.jpg,*.bmp)|*.png;*.PNG;*.tif;*.tiff;*.TIF;*.jpg;*.JPG;*.bmp;*.BMP'+
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
        progress_indicator(100*i/(count),' Solving');{show progress}
        Application.ProcessMessages;
        if esc_pressed then begin Screen.Cursor := Save_Cursor;  exit;end;
        filename2:=Strings[I];
        mainwindow.caption:=filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count);

        if convert_to_fits(filename2)=false then
        begin
          mainwindow.caption:='Error converting '+filename2;
          err:=true;
        end;
      end;

      if err=false then mainwindow.caption:='Completed, all files converted.'
      else
      mainwindow.caption:='Finished, files converted but with errors!';

      finally
      if dobackup then restore_img;{for the viewer}
      Screen.Cursor := Save_Cursor;  { Always restore to normal }
      progress_indicator(-100,'');{progresss done}
    end;
  end;
end;


function load_image(re_center,plot: boolean): boolean; {load fits or PNG, BMP, TIF}
var
   ext1,filename_org   : string;
begin
  if plot then
  begin
    mainwindow.caption:=filename2;
    filename_org:=filename2;
    mainwindow.shape_marker1.visible:=false;
    mainwindow.shape_marker2.visible:=false;
    mainwindow.updown1.position:=0;{reset muli-extension up down}
  end;

  ext1:=uppercase(ExtractFileExt(filename2));

  x_coeff[0]:=0; {reset DSS_polynomial, use for check if there is data}
  y_coeff[0]:=0;
  a_order:=0; {SIP_polynomial, use for check if there is data}
  ap_order:=0; {SIP_polynomial, use for check if there is data}

  result:=false;{assume failure}
  {fits}
  if ((ext1='.FIT') or (ext1='.FITS') or (ext1='.FTS') or (ext1='.NEW')or (ext1='.WCS') or (ext1='.AXY') or (ext1='.XYLS') or (ext1='.GSC') or (ext1='.BAK')) then {FITS}
  begin
    result:=load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded);
    if ((result=false) or (head.naxis<2))  then {{no image or failure.}
    begin
       update_menu(false);
       exit; {WCS file}
    end;
  end

  else
  if (ext1='.FZ') then {CFITSIO format}
  begin
    if unpack_cfitsio(filename2)=false then begin beep; exit; end
    else{successful conversion using funpack}
    result:=load_fits(filename2,true {light},true {load data},true {update memo},0,head,img_loaded); {load new fits file}

    if result=false then begin update_menu(false);exit; end;
  end {fz}

  else
  if check_raw_file_extension(ext1) then {raw format}
  begin
    if convert_raw(true{load},false{save},filename2,img_loaded)=false then
      begin update_menu(false);beep; exit; end
    else
    result:=true;
    {successful conversion using LibRaw}
    filename2:=ChangeFileExt(FileName2,'.fits');{for the case you want to save it}
  end{raw}

  else
  if ((ext1='.PPM') or (ext1='.PGM') or (ext1='.PFM') or (ext1='.PBM')) then {PPM/PGM/ PFM}
  begin
    if load_PPM_PGM_PFM(filename2,head,img_loaded)=false then begin update_menu(false);exit; end {load the simple formats ppm color or pgm grayscale, exit on failure}
    else
      result:=true;
  end

  else
  if ext1='.XISF' then {XISF}
  begin
    if load_xisf(filename2,head,img_loaded)=false then begin update_menu(false);exit; end {load XISF, exit on failure}
    else
      result:=true;
  end

  else
  {tif, png, bmp, jpeg}
  if load_tiffpngJPEG(filename2,head,img_loaded)=false then
        begin update_menu(false);exit; end  {load tif, exit on failure}
  else
    result:=true;

  if plot then
  begin
    if ((head.naxis3=1) and (mainwindow.preview_demosaic1.checked)) then demosaic_advanced(img_loaded);{demosaic and set levels}
    use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
    image_move_to_center:=re_center;
    plot_fits(mainwindow.image1,re_center,true);     {mainwindow.image1.Visible:=true; is done in plot_fits}

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

  if sender<>nil then {not from plot_fits, redraw required}
  begin
    plot_north; {draw arrow or clear indication position north depending on value head.cd1_1}
  end;
end;


//procedure Tmainwindow.FormClose(Sender: TObject; var Action: TCloseAction);
//begin
//  esc_pressed:=true;{stop processing. Required for reliable stopping by APT}
//  save_settings2;
//end;


procedure Tmainwindow.receivemessage(Sender: TObject);{For OneInstance, called from timer (linux) or SimpleIPCServer1MessageQueued (Windows)}
begin
  if SimpleIPCServer1.PeekMessage(1,True) then
  begin
    BringToFront;
    filename2:=SimpleIPCServer1.StringMessage;
    load_image(true,true {plot});{show image of parameter1}
  end;
end;

procedure convert_mono(var img: image_array);
var
   fitsX,fitsY: integer;
   img_temp : image_array;
begin
  if head.naxis3<3 then exit;{prevent run time error mono images}
  memo2_message('Converting to mono.');
  setlength(img_temp,1,head.width,head.height);{set length of image array mono}

  for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1 do
      img_temp[0,fitsx,fitsy]:=(img[0,fitsx,fitsy]+img[1,fitsx,fitsy]+img[2,fitsx,fitsy])/3;

  head.naxis:=2;{mono}
  head.naxis3:=1;
  img:=nil;
  img:=img_temp;
end;


procedure Tmainwindow.convertmono1Click(Sender: TObject);
var
   Save_Cursor:TCursor;
begin
  if head.naxis3<3 then exit;{prevent run time error mono images}
  Save_Cursor := Screen.Cursor;
  Screen.Cursor:= crHourGlass;

  backup_img;

  convert_mono(img_loaded);

  update_header_for_colour; {update header naxis and naxis3 keywords}
  add_text('HISTORY   ','Converted to mono');

  {colours are now mixed, redraw histogram}
  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,false,true);{plot}
  Screen.cursor:=Save_Cursor;
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
  tmpbmp            : TBitmap;
  x1,x2,y1,y2       : integer;
  SRect,DRect       : TRect;

begin
  if abs(startX-stopX)<4 then
    Clipboard.Assign(Image1.Picture.Bitmap)
  else
  begin {selection}
    try
      TmpBmp := TBitmap.Create;
      try
        {convert array coordinates to screen coordinates}
        if flip_horizontal1.Checked then begin x1:=head.width-1-startX;x2:=head.width-stopX; end else begin x1:=startx;x2:=stopX;end;
        if flip_vertical1.Checked=false then begin y1:=head.height-1-startY;y2:=head.height-1-stopY; end else begin y1:=startY;y2:=stopY;end;

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


procedure Tmainwindow.extractred1Click(Sender: TObject);
begin
//  green_even:= ( (odd(x+1+offsetX)) and (odd(y+1+offsetY)) );{even(i) function is odd(i+1), even is here for array position not fits position}
//  green_odd := ( (odd(x+offsetX)) and  (odd(y+offsetY)) );
//  red :=( (odd(x+offsetX)) and (odd(y+1+offsetY)) );
//  blue:=( (odd(x+1+offsetX)) and (odd(y+offsetY)) );


  split_raw(1,1,'TR');{extract one of the Bayer matrix pixels}
end;


procedure Tmainwindow.extractblue1Click(Sender: TObject);
begin
  split_raw(1,1,'TB');{extract one of the Bayer matrix pixels}
end;


procedure Tmainwindow.extractgreen1Click(Sender: TObject);
begin
  split_raw(1,1,'TG');{extract one of the Bayer matrix pixels}
end;


procedure Tmainwindow.grid1Click(Sender: TObject);
begin
  if fits_file=false then exit;
  if grid1.checked=false then  {clear screen}
  begin
    plot_fits(mainwindow.image1,false,true);
  end
  else
  plot_grid;
end;


procedure Tmainwindow.bin_2x2menu1Click(Sender: TObject);
var
  Save_Cursor:TCursor;
begin
  if fits_file=true then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img; {move viewer data to img_backup}
    if sender=bin_2x2menu1 then
    begin
      bin_X2X3X4(2);
      filename2:=ChangeFileExt(Filename2,'_bin2x2.fit');
    end
    else
    begin
      bin_X2X3X4(3);
      filename2:=ChangeFileExt(Filename2,'_bin3x3.fit');
    end;

    plot_fits(mainwindow.image1,true,true);{plot real}
    Screen.Cursor:=Save_Cursor;
  end;
end;

procedure Tmainwindow.convert_to_png1Click(Sender: TObject);
begin

end;


procedure Tmainwindow.positionanddate1Click(Sender: TObject);
begin
  if fits_file=false then exit;
  if positionanddate1.checked=false then  {clear screen}
  begin
    plot_fits(mainwindow.image1,false,true);
  end
  else
  plot_text;
end;

procedure Tmainwindow.inspection1click(Sender: TObject);
begin
  CCDinspector(30,three_corners,strtofloat2(measuring_angle))
end;


procedure Tmainwindow.removegreenpurple1Click(Sender: TObject);
begin
  green_purple_filter(img_loaded);
end;



procedure Tmainwindow.roundness1Click(Sender: TObject);
begin
  form_inspection1.hfd_button1Click(nil);
end;


procedure Tmainwindow.sip1Click(Sender: TObject); {simple SIP coefficients calculation assuming symmetric radial distortion. Distortion increases with the third power of the off-center distance}
var
  stars_measured,i,countX,countY  : integer;
  xc,yc,x,y,factorX,factorY       : double;
  Save_Cursor:TCursor;
  factorsX,factorsY  : array of double;
  valid              : boolean;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  if calculate_undisturbed_image_scale then {calculate and correct the image scale as if the optical system is undisturbed. The distance between the stars in the center are measured and compared between detection and database. It is assumed that the center of the image is undisturbed optically }
  begin
    measure_distortion(false {plot and no sip correction},stars_measured);{measure distortion of all stars}

   {Standard formala for optical distortion

    Xdelta:=Xideal*(k1*r1^2 + k2*r1^4 + ....)

    simplify by taking only the first factor

    Xdelta:=Xideal* k1*r1^2

    Xdelta:=Xideal* k1*(X^2+Y^2)

    Xdelta:=k1*X^3+  k1* X*Y^2   formula (1) for the SIP correction       X^3 is AP_3_0      and X*Y^2   is AP_1_2

    k1:=Xdelta/(X^3 +  (X*Y^2)   formula (2) to find k1

    to find k1 take the median from all points using formula (2) where x or y is large enough to measure the distortion}

    valid:=false;

    if stars_measured>0 then
    begin
      countX:=0;
      countY:=0;
      setlength(factorsX,stars_measured);
      setlength(factorsY,stars_measured);

      for i:=0 to stars_measured-1 do
      begin
        x:=distortion_data[0,i]-head.crpix1;{database, x from center}
        y:=distortion_data[1,i]-head.crpix2;
        xc:=distortion_data[2,i]-head.crpix1;{measured, x from center}
        yc:=distortion_data[3,i]-head.crpix2;

        if abs(x)>0.35*head.height then valid:=true; {stars detected over 70% or range.}

        if ((abs(x-xc)>=1){some offset} and  (abs(x)>0.2*head.crpix1)) {some distance from center} then
        begin
          factorsX[countX]:=(x-xc)/(x*(sqr(x)+sqr(y))); {measure the k1 factor for every star detection}
          inc(countX,1);
        end;
        if ((abs(y-yc)>=1){some offset} and  (abs(y)>0.2*head.crpix2)) {some distance from center} then
        begin
          factorsY[countY]:=(y-yc)/(y*(sqr(x)+sqr(y))); {measure the k1 factor for every star detection}
          inc(countY,1);
        end;
      end;

      if valid then
      begin

        factorX:=smedian(factorsX,countX);{filter out outliers using median}
        factorY:=smedian(factorsY,countY);{filter out outliers using median}

        factorsX:=nil;
        factorsY:=nil;

        //                0            1           2           3           4             5            6
        //     u2:=u + A_0_0+ a_1_0*u + a_2_0*u*u + a_0_2*v*v + a_1_1*u*v + a_2_1*u*u*v+ a_1_2*u*v*v + a_3_0*u*u*u + a_0_3*v*v*v; {SIP correction for second or third order}
        //     v2:=v + B_0_0 + b_0_1*v + b_2_0*u*u + b_0_2*v*v + b_1_1*u*v + b_2_1*u*u*v+ b_1_2*u*v*v + b_3_0*u*u*u + b_0_3*v*v*v; {SIP correction for second or third order}


        {pixel to sky coefficients}
        A_ORDER:=3;{allow usage in astap}
        A_0_0:=0;
        A_0_1:=0;
        A_0_2:=0;
        A_0_3:=0;
        A_1_0:=0;
        A_1_1:=0;
        A_1_2:=factorX;
        A_2_0:=0;
        A_2_1:=0;
        A_3_0:=factorX;

        B_0_0:=0;
        B_0_1:=0;
        B_0_2:=0;
        B_0_3:=factorY;
        B_1_0:=0;
        B_2_0:=0;
        B_3_0:=0;
        B_1_1:=0;
        B_1_2:=0;
        B_2_1:=factorY;
        B_3_0:=0;

        {sky to pixel coefficients}
        AP_order:=3; {allow usage in astap}
        AP_0_0:=0; {approximation just negative the factors}
        AP_0_1:=0;
        AP_0_2:=0;
        AP_0_3:=0;
        AP_1_0:=0;
        AP_1_1:=0;
        AP_1_2:=-factorX;
        AP_2_0:=0;
        AP_2_1:=0;
        AP_3_0:=-factorX;

        BP_0_0:=0; {approximation just negative the factors}
        BP_0_1:=0;
        BP_0_2:=0;
        BP_0_3:=-factorY;
        BP_1_0:=0;
        BP_1_1:=0;
        BP_1_2:=0;
        BP_2_0:=0;
        BP_2_1:=-factorY;
        BP_3_0:=0;



        update_float  ('A_ORDER =',' / Polynomial order, axis 1. Pixel to Sky         ' ,3);
        remove_key    ('A_0_0   =',false{all});
        remove_key    ('A_0_1   =',false{all});
        remove_key    ('A_0_2   =',false{all});
        remove_key    ('A_0_3   =',false{all});
        remove_key    ('A_1_0   =',false{all});
        remove_key    ('A_1_1   =',false{all});
        update_float  ('A_1_2   =',' / SIP coefficient                                ' ,A_1_2);
        remove_key    ('A_2_0   =',false{all});
        remove_key    ('A_2_1   =',false{all});
        update_float  ('A_3_0   =',' / SIP coefficient                                ' ,A_3_0);

        update_float  ('B_ORDER =',' / Polynomial order, axis 2. Pixel to sky.        ' ,3);
        remove_key    ('B_0_0   =',false{all});
        remove_key    ('B_0_1   =',false{all});
        remove_key    ('B_0_2   =',false{all});
        update_float  ('B_0_3   =',' / SIP coefficient                                ' ,B_0_3);
        remove_key    ('B_1_0   =',false{all});
        remove_key    ('B_1_1   =',false{all});
        remove_key    ('B_1_2   =',false{all});
        remove_key    ('B_2_0   =',false{all});
        update_float  ('B_2_1   =',' / SIP coefficient                                ' ,B_2_1);
        remove_key    ('B_3_0   =',false{all});

        update_float('AP_ORDER=',' / Inv polynomial order, axis 1. Sky to pixel.      ' ,3);
        remove_key  ('AP_0_0  =',false{all});
        remove_key  ('AP_0_1  =',false{all});
        remove_key  ('AP_0_2  =',false{all});
        remove_key  ('AP_0_3  =',false{all});
        remove_key  ('AP_1_0  =',false{all});
        remove_key  ('AP_1_1  =',false{all});
        update_float('AP_1_2  =',' / SIP coefficient                                ' ,AP_1_2);
        remove_key  ('AP_2_0  =',false{all});
        remove_key  ('AP_2_1  =',false{all});
        update_float('AP_3_0  =',' / SIP coefficient                                ' ,AP_3_0);

        update_float('BP_ORDER=',' / Inv polynomial order, axis 2. Sky to pixel.    ' ,3);
        remove_key  ('BP_0_0  =',false{all});
        remove_key  ('BP_0_1  =',false{all});
        remove_key  ('BP_0_2  =',false{all});
        update_float('BP_0_3  =',' / SIP coefficient                                ' ,BP_0_3);
        remove_key  ('BP_1_0  =',false{all});
        remove_key  ('BP_1_1  =',false{all});
        remove_key  ('BP_1_2  =',false{all});
        remove_key  ('BP_2_0  =',false{all});
        update_float('BP_2_1  =',' / SIP coefficient                                ' ,BP_2_1);
        remove_key  ('BP_3_0  =',false{all});

        mainwindow.Polynomial1.color:=clform;
        mainwindow.Polynomial1.ItemIndex:=1;{set at SIP}
        sip:=true;{generic variable. Use sip corrections for plotting}

        memo2_message('Added SIP coefficients to header for a 3th order radial correction. This correction will only work for barrel distortion and pincushion distortion. You could test it with the inspector showing the distortion vectors in SIP readout mode.');
        //up to '+floattostrF(abs(factor)*max_radius*max_radius*max_radius,ffFixed,3,2)+' pixels.');{factor*radius^3}
      end
      else
      begin
        beep;
        memo2_message('Abort, not enough stars detected in outer regions!');
      end;

    end
    else
    begin
      beep;
      memo2_message('Abort, not enough stars detected!');
    end;
  end;{succesfull measure scale}
  Screen.Cursor := Save_cursor;    { Show hourglass cursor }
end;

procedure Tmainwindow.split_osc1Click(Sender: TObject);
begin

end;


procedure Tmainwindow.extract_pixel_11Click(Sender: TObject);
begin
  split_raw(1,1,'P11');{extract one of the Bayer matrix pixels}
end;


procedure Tmainwindow.extract_pixel_12Click(Sender: TObject);
begin
  split_raw(1,2,'P12');{extract one of the Bayer matrix pixels}
end;


procedure Tmainwindow.extract_pixel_21Click(Sender: TObject);
begin
  split_raw(2,1,'P21');{extract one of the Bayer matrix pixels}
end;


procedure Tmainwindow.extract_pixel_22Click(Sender: TObject);
begin
  split_raw(2,2,'P22');{extract one of the Bayer matrix pixels}
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
     if head.naxis3>1 then info:=info+#9+inttostr(histogram[1,c])+#9+inttostr(histogram[2,c]);{add green and blue if colour image}
     if c=0 then info:=info+ #9+'Value, Red count, Green count, Blue count';
     info:=info+slinebreak;
  end;
  Clipboard.AsText:=info;
end;


procedure Tmainwindow.Image1Paint(Sender: TObject);
begin
   mainwindow.statusbar1.panels[8].text:=inttostr(round(100*mainwindow.image1.width/ (mainwindow.image1.picture.width)))+'%'; {zoom factor}
end;

procedure Tmainwindow.imageflipv1Click(Sender: TObject);
begin

end;


procedure Tmainwindow.measuretotalmagnitude1Click(Sender: TObject);
var
   fitsX,fitsY,dum,font_height,counter,tx,ty,saturation_counter : integer;
   flux,bg_median,value  : double;
   Save_Cursor           : TCursor;
   mag_str               : string;
   bg_array              : array of double;
begin
  if ((head.cd1_1=0) or (fits_file=false)) then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    if ((flux_magn_offset=0) or (flux_aperture<>99){calibration was for point sources})  then {calibrate and ready for extendend sources}
    begin
      annulus_radius:=14;{calibrate for extended objects using full star flux}
      flux_aperture:=99;{calibrate for extended objects}

      plot_and_measure_stars(true {calibration},false {plot stars},false{report lim magnitude});
    end;
    if flux_magn_offset=0 then begin beep; exit;end;

    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img;

    tx:=stopX;
    ty:=stopY;
    if mainwindow.Flip_horizontal1.Checked then {restore based on flipped conditions}
      tx:=head.width-1-tx;
    if mainwindow.flip_vertical1.Checked=false then
      ty:=head.height-1-ty;


    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

    setlength(bg_array,5000);

    {measure the median of the suroundings}
    counter:=0;
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
      bg_median:=Smedian(bg_array,counter)
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

    image1.Canvas.font.name:='default';

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
    setlength(img_buffer,head.naxis3,stopX2-startX2,stopY2-startY2);{new size}
    setlength(img_temp,head.naxis3,stopX2-startX2,stopY2-startY2);{new size}
    for k:=0 to head.naxis3-1 do
    for fitsY:=startY2 to stopY2-1 do
    for fitsX:=startX2 to stopX2-1 do img_buffer[k,fitsX-startX2,fitsY-startY2]:=img_loaded[k,fitsX,fitsY];{copy section of interest}
    apply_most_common(img_buffer,img_temp,bsize); {apply most common filter on first array and place result in second array}
    gaussian_blur2(img_temp,bsize+bsize);

    {correct image}
    for k:=0 to head.naxis3-1 do {do all colors}
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
          progress_value:=round(100*( k/head.naxis3 +  0.3333*(fitsY-startY2)/(stopY2-startY2)));
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


procedure Tmainwindow.batch_rotate_left1Click(Sender: TObject);
var
  i         : integer;
  dobackup  : boolean;
begin

  OpenDialog1.Title := 'Select multiple  files to rotate 90 degrees.';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';

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
         if ((esc_pressed) or (load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded)=false)) then begin exit;end;

         rotateleft1Click(Sender);{rotate left or right will be defined by the sender in next procedure}
         save_fits(img_loaded,FileName2,16,true);{overwrite}
      end;
      finally
      if dobackup then restore_img;{for the viewer}
    end;
  end;
end;

procedure Tmainwindow.angular_distance1Click(Sender: TObject);
var
   shapetype                               : integer;
   hfd1,star_fwhm,snr,flux,xc,yc, hfd2,
   star_fwhm2,snr2,flux2,xc2,yc2,angle     : double;
   info_message,info_message2 : string;
   Save_Cursor              : TCursor;
begin
  if fits_file=false then exit;

  if  ((abs(stopX-startX)>2) or (abs(stopY-starty)>2)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img;

    HFD(img_loaded,startX,startY,14{annulus radius},99 {flux aperture restriction}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}

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

    HFD(img_loaded,stopX,stopY,14{annulus radius},99 {flux aperture restriction}, hfd2,star_fwhm2,snr2,flux2,xc2,yc2);{star HFD and FWHM}
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

    angle:=fnmodulo (arctan2(shape_marker2_fitsX-shape_marker1_fitsX,shape_marker2_fitsY-shape_marker1_fitsY)*180/pi + head.crota2,360);

    info_message2:=floattostrf(sqrt(sqr(shape_marker2_fitsX-shape_marker1_fitsX)+sqr(shape_marker2_fitsY-shape_marker1_fitsY))*head.cdelt2*3600,ffgeneral,5,5);
    if head.cdelt2<>0 then  info_message2:=info_message2+'"'
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
     j2000d1.checked:=false;
   end;
end;

procedure Tmainwindow.j2000d1Click(Sender: TObject);
begin
  if j2000d1.checked then
  begin
    coord_frame:=1;
    galactic1.checked:=false;
    j2000_1.checked:=false;
  end;
end;


procedure Tmainwindow.galactic1Click(Sender: TObject);
begin
  if galactic1.checked then
  begin
    coord_frame:=2;
    j2000_1.checked:=false;
    j2000d1.checked:=false;
   end;
end;


procedure Tmainwindow.northeast1Click(Sender: TObject);
begin
  if fits_file=false then exit;
  if northeast1.checked then
  begin
    plot_north_on_image;
    image1.refresh;{important, show update}
  end
  else
    plot_fits(mainwindow.image1,false,true); {clear indiicator}
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
    if head.naxis3>1 then colgg1:=mode(img_loaded,1,startX-bsize,startX+bsize,startY-bsize,startY+bsize,65535);{find most common colour of a local area}
    if head.naxis3>2 then colbb1:=mode(img_loaded,2,startX-bsize,startX+bsize,startY-bsize,startY+bsize,65535);{find most common colour of a local area}

    colrr2:=mode(img_loaded,0,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize,65535);{find most common colour of a local area}
    if head.naxis3>1 then colgg2:=mode(img_loaded,0,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize,65535);{find most common colour of a local area}
    if head.naxis3>2 then colbb2:=mode(img_loaded,0,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize,65535);{find most common colour of a local area}

    a:=sqrt(sqr(stopX-startX)+sqr(stopY-startY)); {distance between bright and dark area}

    for fitsY:=0 to head.height-1 do
      for fitsX:=0 to head.width-1 do
      begin
        b:=sqrt(sqr(fitsX-startX)+sqr(fitsY-startY)); {distance from dark spot}
        c:=sqrt(sqr(fitsX-stopX)+sqr(fitsY-stopY)); {distance from bright spot}
        p:=-((sqr(b)-sqr(a)-sqr(c))/(2*a)); {projectiestelling scheefhoekige driehoek (Dutch), polytechnisch zakboekje 42 edition, a2/24 3.2}

        img_loaded[0,fitsX,fitsY]:=img_loaded[0,fitsX,fitsY]-(colrr2-colrr1)*(a-p)/a;
        if head.naxis3>1 then img_loaded[1,fitsX,fitsY]:=img_loaded[1,fitsX,fitsY]-(colgg2-colgg1)*(a-p)/a;
        if head.naxis3>2 then img_loaded[2,fitsX,fitsY]:=img_loaded[2,fitsX,fitsY]-(colbb2-colbb1)*(a-p)/a;
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
                                                '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                         '|RAW files|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
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
          if savefits_update_header(filename2)=false then begin ShowMessage('Write error !!' + filename2); Screen.Cursor := Save_Cursor; exit;end;
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
  save_settings2;
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
  keyboard_text:= extract_objectname_from_filename(filename2);

  form_listbox1:=TForm_listbox1.Create(self); {in project option not loaded automatic}
  form_listbox1.ShowModal;

  if object_found then
  begin
    ra1.text:=prepare_ra(ra_data,' ');{Add object position}
    dec1.text:=prepare_dec(dec_data,' ');
  end;
  form_listbox1.release;
end;


procedure Tmainwindow.save_settings1Click(Sender: TObject);
begin
  save_settings2;
end;


procedure measure_magnitudes(annulus_rad:integer; deep: boolean; var stars :star_list);{find stars and return, x,y, hfd, flux}
var
  fitsX,fitsY,radius, i, j,nrstars,n,m,xci,yci,sqr_radius: integer;
  hfd1,star_fwhm,snr,flux,xc,yc,detection_level,hfd_min  : double;
  img_sa : image_array;

begin

  SetLength(stars,4,5000);{set array length}

  setlength(img_sa,1,head.width,head.height);{set length of image array}

  get_background(0,img_loaded,false{histogram is already available},true {calculate noise level},{var}cblack,star_level);{calculate background level from peek histogram}

  if deep then detection_level:=5*noise_level[0] else detection_level:=star_level;
  hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}

  nrstars:=0;{set counters at zero}

  for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1  do
      img_sa[0,fitsX,fitsY]:=-1;{mark as star free area}

  for fitsY:=0 to head.height-1-1 do
  begin
    for fitsX:=0 to head.width-1-1  do
    begin
      if (( img_sa[0,fitsX,fitsY]<=0){area not occupied by a star} and (img_loaded[0,fitsX,fitsY]- cblack> detection_level)) then {new star}
      begin
        HFD(img_loaded,fitsX,fitsY,annulus_rad {typical 14, annulus radius},flux_aperture, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
        if ((hfd1<15) and (hfd1>=hfd_min) {two pixels minimum} and (snr>10) and (flux>1){rare but happens}) then {star detected in img_loaded}
        begin
          {for testing}
          //if flipvertical=false  then  starY:=round(head.height-yc) else starY:=round(yc);
          //if fliphorizontal=true then starX:=round(head.width-xc)  else starX:=round(xc);
          //  size:=round(5*hfd1);
          //  mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
          //  mainwindow.image1.Canvas.textout(starX+size,starY+size,floattostrf(hfd1, ffgeneral, 2,1));{add hfd as text}

          radius:=round(3.0*hfd1);{for marking star area. A value between 2.5*hfd and 3.5*hfd gives same performance. Note in practice a star PSF has larger wings then predicted by a Gaussian function}
          sqr_radius:=sqr(radius);
          xci:=round(xc);{star center as integer}
          yci:=round(yc);
          for n:=-radius to +radius do {mark the whole circular star area as occupied to prevent double detection's}
            for m:=-radius to +radius do
            begin
              j:=n+yci;
              i:=m+xci;
              if ((j>=0) and (i>=0) and (j<head.height) and (i<head.width) and (sqr(m)+sqr(n)<=sqr_radius)) then
                img_sa[0,i,j]:=1;
            end;

          if ((img_loaded[0,round(xc),round(yc)]<head.datamax_org-1) and
              (img_loaded[0,round(xc-1),round(yc)]<head.datamax_org-1) and
              (img_loaded[0,round(xc+1),round(yc)]<head.datamax_org-1) and
              (img_loaded[0,round(xc),round(yc-1)]<head.datamax_org-1) and
              (img_loaded[0,round(xc),round(yc+1)]<head.datamax_org-1) and

              (img_loaded[0,round(xc-1),round(yc-1)]<head.datamax_org-1) and
              (img_loaded[0,round(xc-1),round(yc+1)]<head.datamax_org-1) and
              (img_loaded[0,round(xc+1),round(yc-1)]<head.datamax_org-1) and
              (img_loaded[0,round(xc+1),round(yc+1)]<head.datamax_org-1)  ) then {not saturated}
          begin
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

     //       IF ((abs(xc-1635)<10) and (abs(yc-885)<10)) then
     //       beep;
          end;{not saturated}
        end;{HFD good}
      end;
    end;
  end;

  img_sa:=nil;{free mem}

  SetLength(stars,4,nrstars);{set length correct}
end;


procedure Tmainwindow.annotate_unknown_stars1Click(Sender: TObject);
var
  size,radius, i,j, starX, starY,fitsX,fitsY,n,m,xci,yci     : integer;
  Save_Cursor:TCursor;
  Fliphorizontal, Flipvertical,astar                                                                        : boolean;
  hfd1,star_fwhm,snr,flux,xc,yc,measured_magn,magnd,magn_database, delta_magn,magn_limit,sqr_radius,hfd_min : double;
  messg : string;
  img_temp3,img_sa :image_array;
const
   default=1000;

 begin
  if fits_file=false then exit; {file loaded?}

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  mainwindow.calibrate_photometry1Click(nil);{measure hfd and calibrate for point or extended sources depending on the setting}

  if flux_magn_offset=0 then
  begin
    beep;
    img_sa:=nil;
    img_temp3:=nil;
    Screen.Cursor:= Save_Cursor;
    exit;
  end;

  Flipvertical:=mainwindow.flip_vertical1.Checked;
  Fliphorizontal:=mainwindow.Flip_horizontal1.Checked;
  magn_limit:=10*strtoint(copy(stackmenu1.star_database1.text,2,2)); {g18 => 180}
  hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}

  image1.Canvas.Pen.Mode := pmMerge;
  image1.Canvas.Pen.width :=1; // round(1+head.height/image1.height);{thickness lines}
  image1.Canvas.brush.Style:=bsClear;
  image1.Canvas.font.color:=clyellow;
  image1.Canvas.font.name:='default';
  image1.Canvas.font.size:=10; //round(max(10,8*head.height/image1.height));{adapt font to image dimensions}
  mainwindow.image1.Canvas.Pen.Color := clred;


  setlength(img_temp3,1,head.width,head.height);{set size of image array}
  for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1  do
      img_temp3[0,fitsX,fitsY]:=default;{clear}
  plot_artificial_stars(img_temp3);{create artificial image with database stars as pixels}
//  img_loaded:=img_temp3;
//  plot_fits(mainwindow.image1,true,true);
//  exit;

  get_background(0,img_loaded,false{histogram is already available},true {calculate noise level},{var}cblack,star_level);{calculate background level from peek histogram}

  setlength(img_sa,1,head.width,head.height);{set length of image array}
   for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1  do
      img_sa[0,fitsX,fitsY]:=-1;{mark as star free area}

  for fitsY:=0 to head.height-1-1 do
  begin
    for fitsX:=0 to head.width-1-1  do
    begin
      if (( img_sa[0,fitsX,fitsY]<=0){area not occupied by a star} and (img_loaded[0,fitsX,fitsY]- cblack>5*noise_level[0] {star_level} ){star}) then {new star}
      begin
        HFD(img_loaded,fitsX,fitsY,14{annulus radius},99 {flux aperture restriction}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
        if ((hfd1<10) and (hfd1>=hfd_min) and (snr>10) and (flux>1){rare but happens}) then {star detected in img_loaded}
        begin
          {for testing}
          //if flipvertical=false  then  starY:=round(head.height-yc) else starY:=round(yc);
          //if fliphorizontal=true then starX:=round(head.width-xc)  else starX:=round(xc);
          //  size:=round(5*hfd1);
          //  mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
          //  mainwindow.image1.Canvas.textout(starX+size,starY+size,floattostrf(hfd1, ffgeneral, 2,1));{add hfd as text}

          radius:=round(3.0*hfd1);{for marking star area. A value between 2.5*hfd and 3.5*hfd gives same performance. Note in practice a star PSF has larger wings then predicted by a Gaussian function}
          sqr_radius:=sqr(radius);
          xci:=round(xc);{star center as integer}
          yci:=round(yc);
          for n:=-radius to +radius do {mark the whole circular star area as occupied to prevent double detection's}
            for m:=-radius to +radius do
            begin
              j:=n+yci;
              i:=m+xci;
              if ((j>=0) and (i>=0) and (j<head.height) and (i<head.width) and (sqr(m)+sqr(n)<=sqr_radius)) then
            end;

          if ((img_loaded[0,round(xc),round(yc)]<head.datamax_org-1) and
              (img_loaded[0,round(xc-1),round(yc)]<head.datamax_org-1) and
              (img_loaded[0,round(xc+1),round(yc)]<head.datamax_org-1) and
              (img_loaded[0,round(xc),round(yc-1)]<head.datamax_org-1) and
              (img_loaded[0,round(xc),round(yc+1)]<head.datamax_org-1) and

              (img_loaded[0,round(xc-1),round(yc-1)]<head.datamax_org-1) and
              (img_loaded[0,round(xc-1),round(yc+1)]<head.datamax_org-1) and
              (img_loaded[0,round(xc+1),round(yc-1)]<head.datamax_org-1) and
              (img_loaded[0,round(xc+1),round(yc+1)]<head.datamax_org-1)  ) then {not saturated}
           begin
             measured_magn:=(flux_magn_offset-ln(flux)*2.511886432/ln(10))*10; {magnitude x 10}

             if measured_magn<magn_limit-10 then {bright enough to be in the database}
             begin
               magn_database:=default;{1000}
               for i:=-3 to 3 do
                 for j:=-3 to 3 do
                 begin {database star available?}
                   magnd:=img_temp3[0,round(xc)+i,round(yc)+j];
                   if magnd<default then {a star from the database}
                     magn_database:=min(magnd,magn_database);{take brightest}
                 end;

               delta_magn:=measured_magn - magn_database; {delta magnitude time 10}
               if  delta_magn<-10 then {unknown star, 1 magnitude brighter then database}
               begin {mark}
                 if Flipvertical=false then  starY:=round(head.height-yc) else starY:=round(yc);
                 if Fliphorizontal     then starX:=round(head.width-xc)  else starX:=round(xc);

                 if delta_magn<-500 then
                 begin
                   delta_magn:=delta_magn+1000;
                   messg:='';{unknown star in the database}
                 end
                 else
                 begin
                   messg:=' Δ'+inttostr(round(delta_magn)); {star but wrong magnitude}
                  end;
                 size:=round(5*hfd1); {for rectangle annotation}
                 image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
                 image1.Canvas.textout(starX+size,starY,inttostr(round(measured_magn))  +messg );{add magnitude as text}
               end;
             end;
          end {not saturated}
          else
          begin {saturated, cannot compare magnitudes}
            astar:=false;
            for i:=-2 to 2 do
              for j:=-2 to 2 do
              begin {database star available?}
                 if img_temp3[0,round(xc)+i,round(yc)+j]>0 then  astar:=true;
               end;
            if astar=false then
            begin
              size:=round(5*hfd1); {for rectangle annotation}
              if Flipvertical=false then  starY:=round(head.height-yc) else starY:=round(yc);
              if Fliphorizontal     then starX:=round(head.width-xc)  else starX:=round(xc);
              image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate unknown star with rectangle}
            end;
          end;

        end;{HFD good}
      end;
    end;
  end;


  img_temp3:=nil;{free mem}
  img_sa:=nil;{free mem}

  Screen.Cursor:= Save_Cursor;
end;

procedure Tmainwindow.import_auid1Click(Sender: TObject);
var
  s,name,mag,t,regel: string;
  x1,x2,n1,n2 : integer;
  rad,decd    : double;
var
  Save_Cursor:TCursor;
begin
  Save_Cursor := Screen.Cursor;
//  AUID 	RA 	Dec 	Label 	V 	B-V 	Comments
//  000-BBN-792 	07:51:41.99 [117.92495728°] 	01:46:00.7 [1.7668609599999998°] 	51 	5.140 (0.100)22 	-0.120 (0.173)
//  000-BBN-799 	07:52:11.35 [118.04729462000002°] 	01:34:38.3 [1.57730603°] 	98 	9.834 (0.069)16 	1.002 (0.137)

  database_nr:=0; {clear}
  load_variable;{load the variable star database once. If loaded no action}

  x2:=1;
  s:=Clipboard.AsText;
  repeat
    x1:=posex('000-',s,x2);

    if x1>0 then
    begin
      name:=copy(s,x1,11);
      n1:=posex('[',s,x2+1);
      n2:=posex(']',s,x2+1);
      t:=copy(s,n1+1,n2-n1-3);
      rad:=strtofloat2(t);
      n1:=posex('[',s,n2+1);
      n2:=posex(']',s,n2+1);
      t:=copy(s,n1+1,n2-n1-3);
      decd:=strtofloat2(t);

      n1:=posex(#9,s,n2+1);{skip label}
      n1:=posex(#9,s,n1+1);{star V magnitude}
      n2:=posex(#10,s,n1+1);{end line}
      if n2=0 then n2:=n1+30;{if no end line at least 30 characters}

      t:=trim(copy(s,n1+1,n2-n1));
      t:=stringreplace(t,#9,';',[rfReplaceAll]);{}

      //RA[0..864000], DEC[-324000..324000], label
      regel:=inttostr(round(rad*864000/360))+','+inttostr(round(decd*324000/90))+','+name+';'+t;
      deepstring.add(regel);
      x2:=max(n2,x2+50);{move to next line}
    end;
  until x1=0;

  deepstring.add('');
  plot_deepsky;{plot the deep sky object on the image}
  Screen.Cursor:=Save_Cursor;
end;

procedure Tmainwindow.inspector1Click(Sender: TObject);
begin
  form_inspection1:=Tform_inspection1.Create(self); {in project option not loaded automatic}

  form_inspection1.ShowModal;
  form_inspection1.release;
  save_settings2;
end;


procedure QuickSort(var A: array of double; iLo, iHi: Integer) ;{ Fast quick sort. Sorts elements in the array list with indices between lo and hi}
var
  Lo, Hi : integer;
  Pivot, T: double;{ pivot, T, T2 are the same type as the elements of array }
begin
  Lo := iLo;
  Hi := iHi;
  Pivot := A[(Lo + Hi) div 2];
  repeat
    while A[Lo] < Pivot do Inc(Lo) ;
    while A[Hi] > Pivot do Dec(Hi) ;
    if Lo <= Hi then
    begin {swap}
      T := A[Lo];
      A[Lo] := A[Hi];
      A[Hi] := T;
      Inc(Lo) ;
      Dec(Hi) ;
    end;
  until Lo > Hi;
  if Hi > iLo then QuickSort(A, iLo, Hi) ;  {executes itself recursively}
  if Lo < iHi then QuickSort(A, Lo, iHi) ;  {executes itself recursively}
end;


function SMedian(list: array of double; leng: integer): double;{get median of an array of double. Taken from CCDciel code but slightly modified}
var
  mid : integer;
begin
 if leng=0 then result:=nan
 else
   if leng=1 then result:=list[0]
   else
   begin
     quickSort(list,0,leng-1);
     mid := (leng-1) div 2; //(high(list) - low(list)) div 2;
     if Odd(leng) then
     begin
       if leng<=3 then  result:=list[mid]
       else
       begin
         result:=(list[mid-1]+list[mid]+list[mid+1])/3;
       end;
     end
     else
     result:=(list[mid]+list[mid+1])/2;
  end;
end;


procedure Tmainwindow.annotate_with_measured_magnitudes1Click(Sender: TObject);
var
 size, i, starX, starY,lim_magn,fontsize,text_height,text_width     : integer;
 Save_Cursor:TCursor;
 Fliphorizontal, Flipvertical  : boolean;
 stars  : star_list;
begin
  if fits_file=false then exit; {file loaded?}


  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  memo2_message('This will take some time');
  mainwindow.calibrate_photometry1Click(nil);{measure hfd and calibrate for point or extended sources depending on the setting}

  if flux_magn_offset=0 then
  begin
    beep;
    Screen.Cursor:= Save_Cursor;
    exit;
  end;

  Flipvertical:=mainwindow.flip_vertical1.Checked;
  Fliphorizontal:=mainwindow.Flip_horizontal1.Checked;

  image1.Canvas.Pen.Mode := pmMerge;
  image1.Canvas.Pen.width :=1; // round(1+head.height/image1.height);{thickness lines}
  image1.Canvas.Pen.color :=clred;
  image1.Canvas.brush.Style:=bsClear;
  image1.Canvas.font.color:=clyellow;
  image1.Canvas.font.name:='default';

  fontsize:=8;
  image1.Canvas.font.size:=fontsize;
  text_height:=mainwindow.image1.Canvas.textheight('T');{the correct text height, also for 4k with "make everything bigger"}

  mainwindow.image1.Canvas.Pen.Color := clred;

  measure_magnitudes(14,true {deep},stars);

  if length(stars[0])>0 then
  begin
    for i:=0 to  length(stars[0])-2 do
    begin
      if Flipvertical=false then  starY:=round(head.height-1-stars[1,i]) else starY:=round(stars[1,i]);
      if Fliphorizontal     then starX:=round(head.width-1-stars[0,i])  else starX:=round(stars[0,i]);

      size:=round(stars[2,i]);{5*hfd for marking stars}

      mainwindow.image1.Canvas.moveto(starX+2*size,starY);
      mainwindow.image1.Canvas.lineto(starX+size,starY);
      mainwindow.image1.Canvas.moveto(starX-2*size,starY);
      mainwindow.image1.Canvas.lineto(starX-size,starY);

      lim_magn:=round((flux_magn_offset-ln(stars[3,i]{flux})*2.511886432/ln(10))*10);
      image1.Canvas.textout(starX,starY-text_height,inttostr(lim_magn) );{add magnitude as text}
    end;
  end
  else
  memo2_message('No stars found!');


  text_width:=8*mainwindow.image1.Canvas.textwidth('1234567890');{Calculate textwidth for 80 characters. This also works for 4k with "make everything bigger"}
  fontsize:=trunc(fontsize*(head.width-2*fontsize)/text_width);{use full width for 80 characters}
  image1.Canvas.font.size:=fontsize;
  image1.Canvas.font.color:=clwhite;
  text_height:=mainwindow.image1.Canvas.textheight('T');{the correct text height, also for 4k with "make everything bigger"}
  image1.Canvas.textout(round(fontsize*2),head.height-text_height,'Limiting magnitude is '+ floattostrF(magn_limit,ffgeneral,3,1)+'   (7σ, aperture ⌀'+stackmenu1.flux_aperture1.text+')');{magn_limit global variable calculate in plot_and_measure_stars}


  Screen.Cursor:= Save_Cursor;
end;


procedure Tmainwindow.annotations_visible1Click(Sender: TObject);
begin
  stackmenu1.annotations_visible1.enabled:=annotations_visible1.checked; {follow in stack menu}
  if fits_file=false then exit;
  if annotations_visible1.checked=false then  {clear screen}
    plot_fits(mainwindow.image1,false,true)
  else
    if annotated then plot_annotations(false {use solution vectors},false);
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
  opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';
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

          if load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded) then {load image success}
          begin
            if head.cd1_1=0 then
            begin
              skipped:=skipped+1; {not astrometric solved}
              memo2_message('Skipped: '+filename2+' No solution in header found. First batch solve the images');
            end
            else
            begin
              plot_mpcorb(strtoint(maxcount_asteroid),strtofloat2(maxmag_asteroid),true {add annotations});
              if savefits_update_header(filename2)=false then begin ShowMessage('Write error !!' + filename2); Screen.Cursor := Save_Cursor; exit;end;
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


procedure Tmainwindow.calibrate_photometry1Click(Sender: TObject);
var
  apert,annul,backgr,hfd_med : double;
  hfd_counter                : integer;
begin
  if ((fits_file=false) or (head.cd1_1=0)) then exit;

  apert:=strtofloat2(stackmenu1.flux_aperture1.text); {text "max" will generate a zero}
  if ((flux_magn_offset=0) or (aperture_ratio<>apert){new calibration required})  then
  begin
    annulus_radius:=14;{calibrate for extended objects}
    flux_aperture:=99;{calibrate for extended objects}

    aperture_ratio:=apert;{remember setting}
    if apert<>0 then {smaller aperture for photometry. Setting <> max}
    begin
      analyse_image(img_loaded,30,false {report}, hfd_counter,backgr,hfd_med); {find background, number of stars, median HFD}
      if hfd_med<>0 then
      begin
        memo2_message('Median HFD is '+floattostrf(hfd_med, ffgeneral, 2,2)+'. Aperture and annulus will be adapted accordingly.');;
        flux_aperture:=hfd_med*apert/2;{radius}
        annul:=strtofloat2(stackmenu1.annulus_radius1.text);
        annulus_radius:=min(50,round(hfd_med*annul/2)-1);{Radius. Limit to 50 to prevent runtime errors}
      end;
    end
    else
    memo2_message('To increase the accuracy of point sources magnitudes set a smaller aperture diameter in tab "photometry".');

    plot_and_measure_stars(true {calibration},false {plot stars},true{report lim magnitude});
  end;
end;

procedure Tmainwindow.Constellations1Click(Sender: TObject);
begin
  if fits_file=false then exit;
  if Constellations1.checked=false then  {clear screen}
  begin
    plot_fits(mainwindow.image1,false,true);
  end
  else
  plot_constellations;
end;


procedure Tmainwindow.freetext1Click(Sender: TObject);
begin
  if freetext1.checked=false then  {clear screen}
  begin
    plot_fits(mainwindow.image1,false,true);
  end
  else
  begin
    freetext:=InputBox('Free text:','',freetext );
    if freetext<>'' then plot_text;
  end;
end;


procedure Tmainwindow.hfd_arcseconds1Click(Sender: TObject);
begin
  hfd_arcseconds:=hfd_arcseconds1.checked;
end;


procedure Tmainwindow.add_marker_position1Click(Sender: TObject);
begin
  if add_marker_position1.checked then
  begin
    marker_position:=InputBox('Enter α, δ position in one of the following formats: ','23 00 00.0 +89 00 00.0   or  23.99 +89.99  or  359.99d 89.99  or  C for center',marker_position );
    if marker_position='' then begin add_marker_position1.checked:=false; exit; end;

    mainwindow.shape_marker3.visible:=true;
    add_marker_position1.checked:=place_marker_radec(marker_position);{place a marker}
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
    Statusbar1.Panels[7].text:='w x h  angular_distance  angle';
    Statusbar1.Panels[8].text:='zoom factor';
  end;
end;


procedure Tmainwindow.stretch_draw_fits1Click(Sender: TObject);
var
  tmpbmp: TBitmap;
  ARect: TRect;
  oldcursor: tcursor;
  x, y,x2,y2 : Integer;
  xLine: PByteArray;
  ratio    : double;
  flipH,flipV : boolean;
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

      ratio:=TmpBmp.width/head.width;

      head.width:=TmpBmp.width;
      head.height:=TmpBmp.Height;

      flipH:=mainwindow.flip_horizontal1.checked;
      flipV:=mainwindow.flip_vertical1.checked;

      setlength(img_loaded,head.naxis3,head.width,head.height);

      for y := 0 to head.height -1 do begin {place in array}
        xLine := TmpBmp.ScanLine[y];
        for x := 0 to head.width -1 do
        begin
          if flipH then x2:=head.width-1-x else x2:=x;
          if flipV=false then y2:=head.height-1-y else y2:=y;
          img_loaded[0,x2,y2]:=xLine^[x*3];{red}
          if head.naxis3>1 then img_loaded[1,x2,y2]:=xLine^[x*3+1];{green}
          if head.naxis3>2 then img_loaded[2,x2,y2]:=xLine^[x*3+2];{blue}
        end;
      end;

      update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
      update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);
      update_integer('DATAMAX =',' / Maximum data value                             ' ,255);


      if head.crpix1<>0 then begin head.crpix1:=head.crpix1*ratio; update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,head.crpix1);end;
      if head.crpix2<>0 then begin head.crpix2:=head.crpix2*ratio; update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,head.crpix2);end;

      if head.cdelt1<>0 then begin head.cdelt1:=head.cdelt1/ratio; update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,head.cdelt1);end;
      if head.cdelt2<>0 then begin head.cdelt2:=head.cdelt2/ratio; update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,head.cdelt2);end;

      if head.cd1_1<>0 then
      begin
        head.cd1_1:=head.cd1_1/ratio;
        head.cd1_2:=head.cd1_2/ratio;
        head.cd2_1:=head.cd2_1/ratio;
        head.cd2_2:=head.cd2_2/ratio;
        update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_1);
        update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_2);
        update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_1);
        update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_2);
      end;

      XBINNING:=XBINNING/ratio;
      YBINNING:=YBINNING/ratio;
      update_float  ('XBINNING=',' / Binning factor in width                         ' ,XBINNING);
      update_float  ('YBINNING=',' / Binning factor in height                        ' ,YBINNING);

      if XPIXSZ<>0 then
      begin
        XPIXSZ:=XPIXSZ/ratio;
        YPIXSZ:=YPIXSZ/ratio;
        update_float('XPIXSZ  =',' / Pixel width in microns (after stretching)       ' ,XPIXSZ);
        update_float('YPIXSZ  =',' / Pixel height in microns (after stretching)      ' ,YPIXSZ);
        update_float('PIXSIZE1=',' / Pixel width in microns (after stretching)       ' ,XPIXSZ);
        update_float('PIXSIZE2=',' / Pixel height in microns (after stretching)      ' ,YPIXSZ);
      end;

      add_text   ('HISTORY   ','Image stretched with factor '+ floattostr6(ratio));

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


procedure Tmainwindow.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  if ((last_extension) and (button=btNext)) then
  begin
    UpDown1.position:=UpDown1.position-1; {no more extensions}
    exit;
  end;
  if load_fits(filename2,true,true,true {update memo},updown1.position,head,img_loaded){load fits file } then
  begin
    if ((head.naxis3=1) and (mainwindow.preview_demosaic1.checked)) then demosaic_advanced(img_loaded);{demosaic and set levels}
    use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
    plot_fits(mainwindow.image1,false {re_center},true);
  end;
end;


procedure Tmainwindow.variable_star_annotation1Click(Sender: TObject);
var
  Save_Cursor:TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass; { Show hourglass cursor }
//  backup_img;
  load_variable;  { Load the database once. If loaded no action}
  plot_deepsky;{plot the deep sky object on the image}
  Screen.Cursor:=Save_Cursor;
end;

procedure Tmainwindow.zoomfactorone1Click(Sender: TObject);
begin
  {zoom to 100%}
  zoom(mainwindow.image1.picture.width/mainwindow.image1.width , TPoint.Create(Panel1.Width div 2, Panel1.Height div 2){zoom center panel1} );
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
  {OneInstance of ASTAP if only one parameter is specified. So if user clicks on an associated image in explorer}
  if paramcount=1 then
  begin
    param1:=paramstr(1);
    if ord(param1[length(param1)])>57  {letter, not a platesolve command}  then {2019-5-4, modification only unique instance if called with file as parameter(1)}
      check_second_instance;{check for and other instance of the application. If so send paramstr(1) and quit}
  end
  else
  if paramcount>1 then {commandline mode}
     trayicon1.visible:=true;{Show trayicon. Do it early otherwise in Win10 it is not shown in the command line mode}

  application_path:= extractfilepath(application.location);{}


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
  if add_marker1.checked=false then
    mainwindow.shape_marker1.Visible:=false
  else
  begin
    shape_marker1_fitsX:=startX+1;
    shape_marker1_fitsY:=startY+1;
    show_marker_shape(mainwindow.shape_marker1,0 {rectangle},20,20,0 {minimum size},shape_marker1_fitsX, shape_marker1_fitsY);
    shape_marker1.hint:='Marker x='+floattostrF(shape_marker1_fitsX,ffFixed,0,1)+' y='+ floattostrF(shape_marker1_fitsY,ffFixed,0,1);
  end;
end;


procedure Tmainwindow.center_lost_windowsClick(Sender: TObject);
begin
  mainwindow.left:=0;
  mainwindow.top:=0;
  stackmenu1.left:=0;
  stackmenu1.top:=0;
  insp_left:=0;
  insp_top:=0;
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
  wide_field_stars:=nil; {free wide_field_database}
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


procedure plot_the_circle(x1,y1,x2,y2:integer);{plot circle}
var
  size,xcenter,ycenter : integer;
begin
  if mainwindow.Flip_horizontal1.Checked then {restore based on flipped conditions}
  begin
    x1:=(head.width-1)-x1;
    x2:=(head.width-1)-x2;
  end;
  if mainwindow.flip_vertical1.Checked=false then
  begin
    y1:=(head.height-1)-y1;
    y2:=(head.height-1)-y2;
  end;
  size:=abs(x2-x1);
  if abs(x2-x1)>20 then {circle}
    mainwindow.image1.canvas.ellipse(x1,y1,x2+1,y2+1) {circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
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


procedure plot_the_annotation(x1,y1,x2,y2:integer; typ:double; name,magn :string);{plot annotation from header in ASTAP format}
var                                                                               {typ >0 line, value defines thickness line}
  size,xcenter,ycenter,text_height,text_width  :integer;                          {type<=0 rectangle or two lines, value defines thickness lines}
begin
  dec(x1); {convert to screen coordinates 0..}
  dec(y1);
  dec(x2);
  dec(y2);

  if mainwindow.Flip_horizontal1.Checked then {restore based on flipped conditions}
  begin
    x1:=(head.width-1)-x1;{flip for screen coordinates, 0...head.width-1}
    x2:=(head.width-1)-x2;
  end;
  if mainwindow.flip_vertical1.Checked=false then
  begin
    y1:=(head.height-1)-y1;
    y2:=(head.height-1)-y2;
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
     if abs(x2-x1)>5 then
       plot_rectangle(x1,y1,x2,y2) {accurate positioned rectangle on screen coordinates}
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


procedure plot_annotations(use_solution_vectors,fill_combo: boolean); {plot annotations stored in fits header. Offsets are for blink routine}
var
  count1,x1,y1,x2,y2 : integer;
  typ     : double;
  List: TStrings;
  name,magn : string;
begin
  if fits_file=false then exit; {file loaded?}

  List := TStringList.Create;
  list.StrictDelimiter:=true;

  mainwindow.image1.Canvas.Pen.Color:= annotation_color;{clyellow}
  mainwindow.image1.Canvas.brush.Style:=bsClear;
  mainwindow.image1.Canvas.font.color:=annotation_color;
  // mainwindow.image1.Canvas.font.size:=round(min(20,max(10,head.height*20/4176)));


  {$ifdef mswindows}
  SetTextAlign(mainwindow.image1.canvas.handle, ta_left or ta_top or TA_NOUPDATECP);{always, since Linux is doing this fixed}
  setbkmode(mainwindow.image1.canvas.handle,TRANSPARENT); {transparent}
  {$else} {Linux}
  {$endif}

  count1:=mainwindow.Memo1.Lines.Count-1;
  try
    while count1>=0 do {plot annotations}
    begin
      name:=mainwindow.Memo1.Lines[count1];
      if copy(mainwindow.Memo1.Lines[count1],1,8)='ANNOTATE' then {found}
      begin
        List.Clear;
        ExtractStrings([';'], [], PChar(copy(mainwindow.Memo1.Lines[count1],12,posex(#39,mainwindow.Memo1.Lines[count1],20)-12)),List);

        if list.count>=6  then {correct annotation}
        begin
          x1:=round(strtofloat2(list[0]));
          y1:=round(strtofloat2(list[1]));
          x2:=round(strtofloat2(list[2]));
          y2:=round(strtofloat2(list[3]));

          if use_solution_vectors then {for blink routine, images are aligned and possible flipped making the annotation position invalid}
          begin
            x1:=round(solution_vectorX[0]*(x1)+solution_vectorX[1]*(y1)+solution_vectorX[2]); {correction x:=aX+bY+c}
            y1:=round(solution_vectorY[0]*(x1)+solution_vectorY[1]*(y1)+solution_vectorY[2]); {correction y:=aX+bY+c}
            x2:=round(solution_vectorX[0]*(x2)+solution_vectorX[1]*(y2)+solution_vectorX[2]); {correction x:=aX+bY+c}
            y2:=round(solution_vectorY[0]*(x2)+solution_vectorY[1]*(y2)+solution_vectorY[2]); {correction y:=aX+bY+c}
          end;


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


procedure plot_persistent_annotation(value : string);{writes text in the image array data}
var
  i,deltax,deltaY,len,x2,y2,fontsize   : integer;

begin
  fontsize:=0;
  while pos('@',value)>0 do
  begin
    value:=stringreplace(value, '@', '',[]);{every @ increase the font size}
    inc(fontsize); {increase font size}
  end;

  {add the connnection line using FITS coordinates}
   deltaX:=stopX-startX;
   deltaY:=stopY-startY;
   len:=round(sqrt(sqr(deltaX)+sqr(deltaY)));
   for i:=0 to len-1 do
      img_loaded[0,startX+round(i*deltaX/len),startY+round(i*deltaY/len) ]:=round((cwhite+cblack)/2);

  {convert to screen coordinates. Screen coordinates are used to have the font with the correct orientation}
  if mainwindow.flip_horizontal1.checked then begin startX:=head.width-startX; stopX:=head.width-stopX;  end;
  if mainwindow.flip_vertical1.checked then begin startY:=head.height-startY;  stopY:=head.height-stopY; end;

  deltaX:=stopX-startX;
  deltaY:=stopY-startY;
  if deltaX>=0 then
      x2:=0
  else
      x2:=3-length(value)*7*fontsize;{place the first pixel or last pixel of the text at the location}
  if deltaY>=0 then y2:=8*fontsize else y2:=0;

  annotation_to_array(value, true{transparant},round((cwhite+cblack)/2) {colour},fontsize,stopX+x2,stopY+y2,img_loaded);{string to image array as annotation, result is flicker free since the annotion is plotted as the rest of the image}

  plot_fits(mainwindow.image1,false,true);
end;


procedure Tmainwindow.Enter_annotation1Click(Sender: TObject);
var
  value : string;
  text_x,text_y   : integer;
  boldness        : double;
begin
  backup_img;
  value:=InputBox('Enter annotation text. Add one @ or more to create a persistent annotation','Text:','' );
  if value=''  then exit;

  if pos('@',value)>0 then
  begin
    plot_persistent_annotation(value);
    exit;
  end;

  mainwindow.image1.Canvas.Pen.width:=max(1,round(1*head.width/image1.width)); ;
  mainwindow.image1.Canvas.Pen.Color:= annotation_color; {clyellow default}

  image1.Canvas.brush.Style:=bsClear;
  image1.Canvas.font.color:=annotation_color;
  image1.Canvas.font.size:=max(12,round(12*head.width/image1.width));

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

  startX:=startX+1; {convert to fits range 1...}
  startY:=startY+1; {convert to fits range 1...}
  text_X:=text_X+1; {convert to fits range 1...}
  text_Y:=text_Y+1; {convert to fits range 1...}

  if sender<>Enter_rectangle_with_label1 then boldness:=head.width/image1.width else boldness:=-head.width/image1.width;

  plot_the_annotation(startX,startY,text_X,text_Y,boldness,value,'');
  add_text ('ANNOTATE=',#39+inttostr(startX)+';'+inttostr(startY)+';'+inttostr(text_X)+';'+inttostr(text_Y)+';'+floattostr6(boldness)+';'+value+';'+#39);
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
  if load_fits(filen,true {light},true,true {update memo},0,head,img_loaded) {load now normal} then
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
  'Date-obs: '+head.date_obs+#13+#10+
  'UT-time: '+UT+#13+#10+
  'Plt-label: '+Pltlabel+#13+#10+
  'Plate-id: '+plateid+#13+#10+
  'Bandpass: '+floattostr(bandpass)+#13+#10+
  'Equinox: '+floattostr(equinox)+#13+#10+
  'Exposure-time: '+floattostr(head.exposure));
  messagebox(mainwindow.handle,bericht,'FITS HEADER',MB_OK);
end;


function position_to_string(sep:string; ra,dec:double):string;
var
  l, b : double;
begin
  if coord_frame=0 then
    result:=prepare_ra8(ra,': ')+sep+prepare_dec2(dec,'° ')
  else
  if coord_frame=1 then
    result:=floattostrF(ra*180/pi, FFfixed, 0, 8)+'°, '+floattostrF(dec*180/pi, FFfixed, 0, 8)+'°'
  else
  begin
    EQU_GAL(ra,dec,l,b);{equatorial to galactic coordinates}
    result:=floattostrF(l*180/pi, FFfixed, 0, 3)+sep+floattostrF(b*180/pi, FFfixed, 0, 3)+' ° gal';
  end;
end;


procedure Tmainwindow.writeposition1Click(Sender: TObject);
var  font_height:integer;
     x7,y7,x8,y8 : integer;
begin
  backup_img;
  image1.Canvas.brush.Style:=bsClear;
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

    if mainwindow.Flip_horizontal1.Checked=true then x7:=round(head.width-object_xc) else x7:=round(object_xc);
    if mainwindow.flip_vertical1.Checked=false then y7:=round(head.height-object_yc) else y7:=round(object_yc);

    if sender<>writepositionshort1 then
    begin
      if head.cd1_1<>0 then {solved}
        image1.Canvas.textout(round(3+x7),round(-font_height+ y7),'_'+position_to_string(',',object_raM,object_decM))
      else
        image1.Canvas.textout(round(3+x7),round(-font_height+ y7),'_'+floattostrF(object_xc,ffFixed,0,2)+', '+floattostrF(object_yc,ffFixed,0,2));{write x,y position if not solved}
    end
    else
      image1.Canvas.textout(round(3+x7),round(-font_height+ y7),'_'+prepare_IAU_designation(object_raM,object_decM));
  end
  else
  begin {no object sync, give mouse position}
    image1.Canvas.font.color:=clred;

    if sender<>writepositionshort1 then
    begin
      x8:=round(3+down_x   /(image1.width/head.width));
      y8:=round(-font_height +(down_y)/(image1.height/head.height));
      if head.cd1_1<>0 then
        image1.Canvas.textout(x8,y8,'_'+position_to_string(',',object_raM,object_decM))
      else
        image1.Canvas.textout(x8,y8,'_'+floattostrF(mouse_fitsX,ffFixed,0,2)+', '+floattostrF(mouse_fitsY,ffFixed,0,2));{write x,y position if not solved}
    end;
  end;
end;


procedure Tmainwindow.FormPaint(Sender: TObject);
begin
   if image_move_to_center then
   begin
     mainwindow.image1.top:=0;
     mainwindow.image1.left:=(mainwindow.panel1.Width - mainwindow.image1.width) div 2;

     {update shapes to new position}

      show_marker_shape(mainwindow.shape_marker3,9 {no change in shape and hint},20,20,10{minimum},shape_marker3_fitsX, shape_marker3_fitsY);
      show_marker_shape(mainwindow.shape_marker4,9 {no change in shape and hint},60,60,30{minimum},shape_marker4_fitsX, shape_marker4_fitsY);
   end;
end;


procedure Tmainwindow.sqm1Click(Sender: TObject);
begin
  if fits_file=false then exit; {file loaded?}



  form_sqm1:=TForm_sqm1.Create(self); {in project option not loaded automatic}
  form_sqm1.ShowModal;
  form_sqm1.release;
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
  w:=round(h*head.width/head.height);

  panel1.width:=mw;
  panel1.height:=h;

  mainwindow.image1.height:=h;
  mainwindow.image1.width:=w;

  mainwindow.image1.top:=0;
  mainwindow.image1.left:=(mw-w) div 2;

  {update shape positions}
  show_marker_shape(mainwindow.shape_marker1,9 {no change in shape and hint},20,20,10{minimum},shape_marker1_fitsX, shape_marker1_fitsY);
  show_marker_shape(mainwindow.shape_marker2,9 {no change in shape and hint},20,20,10{minimum},shape_marker2_fitsX, shape_marker2_fitsY);
  show_marker_shape(mainwindow.shape_marker3,9 {no change in shape and hint},20,20,10{minimum},shape_marker3_fitsX, shape_marker3_fitsY);
  show_marker_shape(mainwindow.shape_marker4,9 {no change in shape and hint},60,60,30{minimum},shape_marker4_fitsX, shape_marker4_fitsY);
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
//  head.width:=mainwindow.Image1.Picture.width;
//  head.height:=mainwindow.Image1.Picture.height;
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
  try
   if fileexists(logf)=false then rewrite(f) else append(f);
   writeln(f,mess);

  finally
    closefile(f);
  end;
end;


procedure log_to_file2(logf,mess : string);{used for platesolve2 and photometry}
var
  f   :  textfile;
begin
  assignfile(f,logf);
  try
    rewrite(f);
    writeln(f,mess);
  finally
    closefile(f);
  end;
end;


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


procedure write_ini(solution:boolean);{write solution to ini file}
var
   f: text;
begin
  if stdin_mode then {raw file send via stdin}
  begin
    {$IFDEF MSWINDOWS}
     if isConsole then {console available}
       AssignFile(f,'')
     else {no console available, compiler option -WH is checked}
       assignfile(f,filename2+'.ini'); {filename2 could be long due to -o option}
    {$ELSE}
     AssignFile(f,''); {write to console, unix and Darwin}
    {$ENDIF}
  end
  else
    assignfile(f,ChangeFileExt(filename2,'.ini'));
  rewrite(f);
  if solution then
  begin
    writeln(f,'PLTSOLVD=T');
    writeln(f,'CRPIX1='+floattostrE(head.crpix1));// X of reference pixel
    writeln(f,'CRPIX2='+floattostrE(head.crpix2));// Y of reference pixel

    writeln(f,'CRVAL1='+floattostrE(head.ra0*180/pi)); // RA (j2000_1) of reference pixel [deg]
    writeln(f,'CRVAL2='+floattostrE(head.dec0*180/pi));// DEC (j2000_1) of reference pixel [deg]
    writeln(f,'CDELT1='+floattostrE(head.cdelt1));     // X pixel size [deg]
    writeln(f,'CDELT2='+floattostrE(head.cdelt2));     // Y pixel size [deg]
    writeln(f,'CROTA1='+floattostrE(head.crota1));    // Image twist of X axis [deg]
    writeln(f,'CROTA2='+floattostrE(head.crota2));    // Image twist of Y axis [deg]
    writeln(f,'CD1_1='+floattostrE(head.cd1_1));       // CD matrix to convert (x,y) to (Ra, Dec)
    writeln(f,'CD1_2='+floattostrE(head.cd1_2));       // CD matrix to convert (x,y) to (Ra, Dec)
    writeln(f,'CD2_1='+floattostrE(head.cd2_1));       // CD matrix to convert (x,y) to (Ra, Dec)
    writeln(f,'CD2_2='+floattostrE(head.cd2_2));       // CD matrix to convert (x,y) to (Ra, Dec)

    if sqmfloat>0 then writeln(f,'SQM='+floattostrE(sqmfloat));  // sky background
    if hfd_median>0 then writeln(f,'HFD='+floattostrE(hfd_median));
    if hfd_counter>0 then  writeln(f,'STARS='+floattostrE(hfd_counter));//number of stars
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

      if ((list.count>=6) and (error1=0)) then {this is a platesolve2 command line}
      begin
        result:=true;
        commandline_execution:=true; {later required for trayicon and popup notifier}

        filename2:=list[5];
        source_fits:=fits_file_name(filename2);{fits file extension?}
        file_loaded:=load_image(false,false {plot});{load file first to give commandline parameters later priority}

        if file_loaded=false then errorlevel:=16;{error file loading}

        ra1.Text:=floattostr6(strtofloat2(list[0])*12/pi);
        dec1.Text:=floattostr6(strtofloat2(list[1])*180/pi);
        field_size:=strtofloat2(list[3])*180/pi;{field height in degrees}
        stackmenu1.search_fov1.text:=floattostr6(field_size);{field width in degrees}
        fov_specified:=true; {always for platesolve2 command}
        regions:=strtoint(list[4]);{use the number of regions in the platesolve2 command}
        if regions=3000{maximum for SGP, force a field of 90 degrees} then   search_field:=90
        else
        search_field:= min(180,sqrt(regions)*0.5*field_size);{regions 1000 is equivalent to 32x32 regions. So distance form center is 0.5*32=16 region heights}

        stackmenu1.radius_search1.text:=floattostrF(search_field,ffFixed,0,1);{convert to radius of a square search field}
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
          head.ra0:=999;
          head.dec0:=999;
          resultV:=',-1';
          resultstr:='Maximum search limit exceeded';
          confidence:='000';
          solved:=false;
          errorlevel:=1;{no solution}
        end;
        //  0.16855631,0.71149576,1              (ra [rad],dec [rad],1 }
        //  2.69487,0.5,1.00005,-0.00017,395     {pixelsize*3600, head.crota2, flipped,? ,confidence}
        //  Valid plate solution

        // .1844945, .72046475, 1
        // 2.7668, 180.73,-1.0001,-.00015, 416
        // Valid plate solution

        //  0.16855631,0.71149576,0.0296,0.02268,999,c:\temp\3.fits,0   {m31}

        assignfile(f,ChangeFileExt(filename2,'.apm'));
        rewrite(f);

        str(head.ra0:9:7,rastr);{mimic format of PlateSolve2}
        str(head.dec0:9:7,decstr);
        line1:=rastr+','+decstr+resultV {,1 or ,-1};

        str(head.cdelt2*3600:7:5,cdelt);
        if ((head.cdelt2=0{prevent divide by zero}) or (head.cdelt1/head.cdelt2<0)) then
        begin
          if source_fits then flipped:='1.0000' else flipped:='-1.0000'; {PlateSolve2 sees a FITS file flipped while not flipped due to the orientation 1,1 at left bottom}
        end
        else
        begin
          if source_fits then flipped:='-1.0000' else flipped:='1.0000';{PlateSolve2 sees a FITS file flipped while not flipped due to the orientation 1,1 at left bottom}
          head.crota2:=180-head.crota2;{mimic strange Platesolve2 angle calculation.}
        end;

        head.crota2:=fnmodulo(head.crota2,360); {Platesolve2 reports in 0..360 degrees, mimic this behavior for SGP}

        str(head.crota2:7:2,crota);
        line2:=cdelt+','+crota+','+flipped+',0.00000,'+confidence;

        apt_request:=pos('IMAGETOSOLVE',uppercase(filename2))>0; {if call from APT then write with numeric separator according Windows setting as for PlateSolve2 2.28}
        if ((apt_Request) and (formatSettings.decimalseparator= ',' )) then {create PlateSolve2 v2.28 format}
        begin
          line1:=stringreplace(line1, '.', ',',[rfReplaceAll]);
          line2:=stringreplace(line2, '.', ',',[rfReplaceAll]);
        end;

        writeln(f,line1);
        writeln(f,line2);
        writeln(f,resultstr);
        closefile(f);

        {note SGP uses PlateSolve2 v2.29. This version writes APM always with dot as decimal separator}

        {extra log}
        write_ini(solved);{write solution to ini file}
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


procedure write_astronomy_wcs(filen: string);
var
  TheFile4 : tfilestream;
  I : integer;
  line0       : ansistring;
  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}

begin
  try
   TheFile4:=tfilestream.Create(filen, fmcreate );

   update_integer('NAXIS   =',' / Minimal header                                 ' ,0);{2 for mono, 3 for colour}
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

function read_stdin_data: boolean;  {reads via stdin a raw image based on the INDI standard}
var
 count,format_type,i,h,bufferlength: Integer;
  rgbdummy          : byteX3;
  x_longword  : longword;
  x_single    : single absolute x_longword;{for conversion 32 bit float}
  InputStream: TIOStream;
begin
  result:=false;{assume failure}
  head.cd1_1:=0;{no solution}

  try

    InputStream := TIOStream.Create(iosInput);
    {read header}
    Count := InputStream.Read(format_type, 4);

    head.naxis3:=1; {assume mono}
    if format_type=$32574152 then nrbits:=16 {RAW2, 16 bit mono identifier}
    else
    if format_type=$31574152 then nrbits:=8 {RAW1, 8 bit mono}
    else
    if format_type=$33574152 then begin nrbits:=24; {24bit RGB = RAW3 = 0x33574152, rgb,rgb,rgb} head.naxis3:=3;end
    else
    if format_type=$34574152 then nrbits:=32 {RAW4, 32 bit mono}
    else
    if format_type=$66574152 then nrbits:=-32 {RAWf, -32 bit float mono}
    else
    exit;

    Count := InputStream.Read(head.width, 4);
    Count := InputStream.Read(head.height, 4);

    {read image data}
    setlength(img_loaded,head.naxis3,head.width,head.height);
    h:=0;
    bufferlength:=head.width*(nrbits div 8);
    repeat
      count:=0;
      repeat {adapt reading to one image line}
         Count :=count + InputStream.Read(fitsBuffer[count],bufferlength-count );
      until count>=bufferlength;
      begin
        if nrbits=16 then
          for i:=0 to head.width-1 do {fill array} img_loaded[0,i,h]:=fitsbuffer2[i]
        else
        if nrbits=8 then
           for i:=0 to head.width-1 do {fill array} img_loaded[0,i,h]:=fitsbuffer[i]
        else
        if nrbits=24 then
        begin
           for i:=0 to head.width-1 do {fill array}
           begin
             rgbdummy:=fitsbufferRGB[i];{RGB fits with naxis1=3, treated as 24 bits coded pixels in 2 dimensions}
             img_loaded[0,i,h]:=rgbdummy[0];{store in memory array}
             img_loaded[1,i,h]:=rgbdummy[1];{store in memory array}
             img_loaded[2,i,h]:=rgbdummy[2];{store in memory array}
           end;
        end
        else
        if nrbits=-32 then {floats}
           for i:=0 to head.width-1 do {fill array}
           begin
             x_longword:=fitsbuffer4[i];
             img_loaded[0,i,h]:= x_single;{for conversion 32 bit float}
           end
        else
        if nrbits=32 then
           for i:=0 to head.width-1 do {fill array} img_loaded[0,i,h]:= fitsbuffer4[i];
      end;
      inc(h)
    until ((h>=head.height-1) or (count=0));
    result:=true;
    head.datamin_org:=0;
    head.datamax_org:=65535;
  except
  end;
end;

procedure Tmainwindow.FormShow(Sender: TObject);
var
    s      : string;
    histogram_done,file_loaded,debug,filespecified,analysespecified,analysespecified2,extractspecified,focusrequest : boolean;
    backgr,snr_min           : double;
    binning,focus_count      : integer;
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
        'Command-line usage:'+#10+
        '-f  filename'+#10+
        '-f  stdin     {read raw image from stdin}'+#10+
        '-r  radius_area_to_search[degrees]'+#10+      {changed}
        '-z  downsample_factor[0,1,2,3,4] {Downsample prior to solving. 0 is auto}'+#10+
        '-fov height_field[degrees]'+#10+
        '-ra  center_right ascension[hours]'+#10+
        '-spd center_south_pole_distance[degrees]'+#10+
        '-s  max_number_of_stars'+#10+
        '-t  tolerance'+#10+
        '-m  minimum_star_size["]'+#10+
        '-speed mode[auto/slow] {Slow is forcing small search steps to improve detection.}'+#10+
        '-o  file {Name the output files with this base path & file name}'+#10+
        '-d  path {specify a path to the star database}'+#10+
        '-analyse snr_min {Analyse only and report median HFD and number of stars used}'+#10+
        '-analyse2 snr_min {both analyse and solve}'+#10+
        '-extract snr_min {As -analyse but additionally write a .csv file with the detected stars info}'+#10+
        '-sqm pedestal  {add measured sqm value to the solution}'+#10+
        '-focus1 file1.fit -focus2 file2.fit ....  {Find best focus using files and hyperbola curve fitting. Errorlevel is focuspos*1E4 + rem.error*1E3}'+#10+
        '-annotate  {Produce deepsky annotated jpg file}' +#10+
        '-debug  {Show GUI and stop prior to solving}' +#10+
        '-log   {Write the solver log to file}'+#10+
        '-tofits  binning[1,2,3,4]  {Make new fits file from PNG/JPG file input}'+#10+
        '-update  {update the FITS header with the found solution}' +#10+
        '-wcs  {Write a .wcs file  in similar format as Astrometry.net. Else text style.}' +#10+
        #10+
        'Preference will be given to the command line values.' +#10+
        'Solver result will be written to filename.ini and filename.wcs.'+#10+
        'Star database expected at: '+database_path
        ), pchar('ASTAP astrometric solver usage:'),MB_OK);

        esc_pressed:=true;{kill any running activity. This for APT}
        halt(0); {don't save only do mainwindow.destroy. Note  mainwindow.close causes a window flash briefly, so don't use}
      end;

      debug:=hasoption('debug'); {The debug option allows to set some solving parameters in the GUI (graphical user interface) and to test the commandline. In debug mode all commandline parameters are set and the specified image is shown in the viewer. Only the solve command has to be given manuallydebug mode }
      filespecified:=hasoption('f');
      focusrequest:=hasoption('focus1');

      if ((filespecified) or (debug) or (focusrequest)) then
      begin
        commandline_execution:=true;{later required for trayicon and popup notifier and Memo3 scroll in Linux}

        commandline_log:=((debug) or (hasoption('log')));{log to file. In debug mode enable logging to memo2}
        if commandline_log then memo2_message(cmdline);{write the original commmand line}

        if filespecified then
        begin
          filename2:=GetOptionValue('f');
          stdin_mode:=filename2='stdin';
          if stdin_mode=false then {file mode}
          begin
          if debug=false then
            file_loaded:=load_image(false,false {plot}) {load file first to give commandline parameters later priority}
          else
            load_image(true,true {plot});{load and show image}
          end
          else
          begin {stdin receive file}
            memo1.clear;{prepare for some info wcs file}
            memo1.lines.add(head1[0]);{add SIMPLE for case option -update is used}
            memo1.lines.add(head1[27]);{add the END to memo1 for stdin and prevent runtime error since all data is inserted for END}
            file_loaded:=read_stdin_data;
            if debug then
            begin
              use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
              plot_fits(mainwindow.image1,true,true);{plot test image}
            end;
          end;
          if file_loaded=false then errorlevel:=16;{error file loading}
          //file_loaded:=((file_loaded) or (extend_type>0));{axy}
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
        {else ra from fits header}

        if hasoption('spd') then {south pole distance. Negative values can't be passed via commandline}
        begin
          head.dec0:=strtofloat2(GetOptionValue('spd'))-90;{convert south pole distance to declination}
          str(head.dec0:0:6,s);
          mainwindow.dec1.text:=s;
        end;
        {else dec from fits header}

        if hasoption('z') then
                 stackmenu1.downsample_for_solving1.text:=GetOptionValue('z');
        if hasoption('s') then
                 stackmenu1.max_stars1.text:=GetOptionValue('s');
        if hasoption('t') then stackmenu1.quad_tolerance1.text:=GetOptionValue('t');
        if hasoption('m') then stackmenu1.min_star_size1.text:=GetOptionValue('m');
        if hasoption('speed') then stackmenu1.force_oversize1.checked:=pos('slow',GetOptionValue('speed'))<>0;

        if focusrequest then {find best focus using curve fitting}
        begin
           stackmenu1.clear_inspector_list1Click(nil);{clear list}
           listview_add(stackmenu1.listview8,GetOptionValue('focus1'),true,L_nr);
           focus_count:=2;
           while hasoption('focus'+inttostr(focus_count)) do
           begin
             listview_add(stackmenu1.listview8,GetOptionValue('focus'+inttostr(focus_count)),true,L_nr);
             inc(focus_count);
           end;
           stackmenu1.curve_fitting1Click(nil);
           if debug=false then
           begin
             if isConsole then {stdout available, compile targe option -wh used}
             begin
               writeln('FOCUS='+floattostrF(focus_best,ffFixed,0,1));
               writeln('ERROR_MIN='+floattostrF(lowest_error,ffFixed,0,5));
             end;
            {$IFDEF msWindows}
             halt(round(focus_best)*10000 +min(9999,round(lowest_error*1000)));
            {$ELSE}
             halt(errorlevel);{report hfd in errorlevel. In linux only range 0..255 possible}
             {$ENDIF}
           end;
        end;


        if debug=false then {standard solve via command line}
        begin
          extractspecified:=hasoption('extract');
          analysespecified:=hasoption('analyse');
          analysespecified2:=hasoption('analyse2');
          if ((file_loaded) and ((analysespecified) or (analysespecified2) or (extractspecified)) ) then {analyse fits and report HFD value in errorlevel }
          begin
            if ((analysespecified) or (analysespecified2)) then snr_min:=strtofloat2(getoptionvalue('analyse'));
            if extractspecified then snr_min:=strtofloat2(getoptionvalue('extract'));
            if snr_min=0 then snr_min:=30;
            analyse_image(img_loaded,snr_min,extractspecified, hfd_counter,backgr,hfd_median); {find background, number of stars, median HFD}
            if isConsole then {stdout available, compile targe option -wh used}
            begin
              writeln('HFD_MEDIAN='+floattostrF(hfd_median,ffFixed,0,1));
              writeln('STARS='+inttostr(hfd_counter));
            end;
            update_float('HFD     =',' / Median Half Flux Diameter' ,hfd_median);
            update_float('STARS   =',' / Number of stars detected' ,hfd_counter);


            if analysespecified2=false then {-analyse -extract}
            begin
              {$IFDEF msWindows}
               halt(round(hfd_median*100)*1000000+hfd_counter);{report in errorlevel the hfd and the number of stars used}
              {$ELSE}
              halt(errorlevel);{report hfd in errorlevel. In linux only range 0..255 possible}
              {$ENDIF}
             end
            else
            begin  {-analyse2}
              {$IFDEF msWindows}
              errorlevel:=round(hfd_median*100)*1000000+hfd_counter;{report in errorlevel the hfd and the number of stars used}
              {$ELSE}
              //nothing.
              {$ENDIF}
            end;
          end;{analyse fits and report HFD value}

          if hasoption('d') then database_path:=GetOptionValue('d')+DirectorySeparator; {specify a different database path}

          if ((file_loaded) and (solve_image(img_loaded,true {get hist}) )) then {find plate solution, filename2 extension will change to .fit}
          begin
//            {$ifdef CPUARM}
//            {set tray icon visible gives a fatal error in old compiler for armhf}
//            {$else}
//            trayicon1.visible:=true;{show progress in hint of trayicon}
//            trayicon1.show;{show progress in hint of trayicon}
//            {$endif}

            if hasoption('sqm') then {sky quality}
            begin
              pedestal:=round(strtofloat2(GetOptionValue('sqm')));
              if calculate_sqm(false {get backgr},false{get histogr}) then {sqm found}
                update_float('SQM     =',' / Sky background [magn/arcsec^2]' ,sqmfloat);
            end;

            if hasoption('o') then filename2:=GetOptionValue('o');{change file name for .ini file}
            write_ini(true);{write solution to ini file}

            add_long_comment('cmdline:'+cmdline);{log command line in wcs file}

            if hasoption('update') then
            begin
              if fits_file_name(filename2) then savefits_update_header(filename2) {update the fits file header}
              else
              save_fits(img_loaded,ChangeFileExt(filename2,'.fits'),16, true {override});{save original png,tiff jpg to 16 fits file}
            end;

            remove_key('NAXIS1  =',true{one});
            remove_key('NAXIS2  =',true{one});
            update_integer('NAXIS   =',' / Minimal header                                 ' ,0);{2 for mono, 3 for colour}
            if hasoption('wcs') then
              write_astronomy_wcs(ChangeFileExt(filename2,'.wcs'))  {write WCS astronomy.net style}
            else
              try mainwindow.Memo1.Lines.SavetoFile(ChangeFileExt(filename2,'.wcs'));{save header as wcs file} except {sometimes error using APT, locked?} end;


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

            if ((fov_specified) and (stackmenu1.search_fov1.text='0' ) {auto}) then {preserve new found fov}
            begin
              stackmenu1.search_fov1.text:=floattostrF(head.height*abs(head.cdelt2),ffFixed,0,2);
              save_settings2;{save settings with correct fov}
            end;
          end {solution}
          else
          begin {no solution}
            if hasoption('o') then filename2:=GetOptionValue('o'); {change file name for .ini file}
            write_ini(false);{write solution to ini file}
            if errorlevel=0 then errorlevel:=1;{no solution}
          end;
          esc_pressed:=true;{kill any running activity. This for APT}

          if commandline_log then stackmenu1.Memo2.Lines.SavetoFile(ChangeFileExt(filename2,'.log'));{save Memo3 log to log file}

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


procedure Tmainwindow.batch_add_solution1Click(
  Sender: TObject);
var
  Save_Cursor:TCursor;
  i,nrskipped, nrsolved,nrfailed        : integer;
  dobackup,add_sip,add_lim_magn,solution_overwrite,solved : boolean;
  failed,skipped                        : string;
  startTick  : qword;{for timing/speed purposes}
begin
  OpenDialog1.Title := 'Select multiple files to add astrometric solution';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';
  esc_pressed:=false;
  add_sip:=add_sip_check1.Checked;
  add_lim_magn:=add_limiting_magn_check1.Checked;
  solution_overwrite:=batch_overwrite1.checked;

  if OpenDialog1.Execute then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    nrsolved:=0;
    nrskipped:=0;
    nrfailed:=0;
    failed:='Failed files:';
    skipped:='Skipped files:';
    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}
    startTick := GetTickCount64;
    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        filename2:=Strings[I];
        progress_indicator(100*i/(count),' Solving');{show progress}
        solved:=false;

        Application.ProcessMessages;
        if esc_pressed then begin Screen.Cursor := Save_Cursor;  exit;end;

        {load image and solve image}
        if load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded) then {load image success}
        begin
          if ((head.cd1_1<>0) and (solution_overwrite=false)) then
          begin
            nrskipped:=nrskipped+1; {plate solved}
            memo2_message('Skipped: '+filename2+ '  Already a solution in the header. Select option overwrite to renew.');
            skipped:=skipped+#13+#10+extractfilename(filename2);
          end
          else
          begin
            memo2_message('Solving '+inttostr(i+1)+'-'+inttostr(Count)+': '+filename2);
            solved:=solve_image(img_loaded,true {get hist});
            if solved then nrsolved:=nrsolved+1 {solve}
            else
            begin
              nrfailed:=nrfailed+1;
              failed:=failed+#13+#10+extractfilename(filename2);
            end;
          end;

          if ((head.cd1_1<>0) and ((solved) or (add_sip) or (add_lim_magn)) )  then {time to save}
          begin
//            if ((add_sqm) and (calculate_sqm(false {get backgr},false{get histogr}))) then
//                update_float('SQM     =',' / Sky background [magn/arcsec^2]' ,sqmfloat);
            if add_sip then
               mainwindow.sip1Click(nil);{add sip coefficients}
            if add_lim_magn then
            begin
              mainwindow.calibrate_photometry1Click(nil);{calibrate}
              update_float('LIM_MAGN=',' / estimated limiting magnitude for point sources' ,magn_limit);
            end;

            if savefits_update_header(filename2)=false then begin ShowMessage('Write error !!' + filename2);Screen.Cursor := Save_Cursor; exit;end;
          end
          else
          begin
            memo2_message('No solution: '+filename2);
            failed:=failed+#13+#10+extractfilename(filename2);
          end;
        end;
      end;{for i:=}

      finally
      memo2_message('Processed in '+ floattostr(round((GetTickCount64 - startTick)/100)/10)+' sec.');

      if dobackup then restore_img;{for the viewer}
      Screen.Cursor := Save_Cursor;  { Always restore to normal }
    end;
    progress_indicator(-100,'');{progresss done}
    nrfailed:=OpenDialog1.Files.count-nrsolved-nrskipped;
    if nrskipped<>0 then memo2_message(skipped);
    if nrfailed<>0 then memo2_message(failed);
    if solution_overwrite then
       memo2_message(inttostr(nrsolved)+' images solved, '+inttostr(nrfailed)+' no solution. Duration '+floattostr(round((GetTickCount64 - startTick)/100)/10)+ ' sec. For re-solve set option "overwrite solution.')
    else
      memo2_message(inttostr(nrsolved)+' images solved, '+inttostr(nrskipped)+' existing solutions, '+inttostr(nrfailed)+' no solution. Duration '+floattostr(round((GetTickCount64 - startTick)/100)/10)+ ' sec.');
  end;
end;


procedure Tmainwindow.stretch1Change(Sender: TObject);
begin
  do_stretching;
end;


procedure mad_median(list: array of double;leng :integer;out mad,median :double);{calculate mad and median without modifying the data}
var  {idea from https://eurekastatistics.com/using-the-median-absolute-deviation-to-find-outliers/}
  i        : integer;
  list2: array of double;
begin
  setlength(list2,leng);
  for i:=0 to leng-1 do list2[i]:=list[i];{copy magn offset data}
  median:=Smedian(list2,leng);
  for i:=0 to leng-1 do list2[i]:=abs(list[i] - median);{fill list2 with offsets}
  mad:=Smedian(list2,leng); //median absolute deviation (MAD)
  list2:=nil;
end;

procedure update_header_for_colour; {update naxis and naxis3 keywords}
begin
  update_integer('NAXIS   =',' / Number of dimensions                           ' ,head.naxis);{number of dimensions, 2 for mono, 3 for colour}
  if head.naxis3<>1 then {color image}
    update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,head.naxis3)
  else
    remove_key('NAXIS3  ',false{all});{remove key word in header. Some program don't like naxis3=1}
end;

procedure Tmainwindow.demosaic_bayermatrix1Click(Sender: TObject);
var
    oldcursor: tcursor;
begin
  if head.naxis3>1 then {colour}
  begin
    memo2_message('Image already in colour. No action.');
    exit;
  end;
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

  update_header_for_colour; {update naxis and naxis3 keywords}

  Screen.Cursor:=OldCursor;
 {$IFDEF fpc}
  progress_indicator(-100,'');{back to normal}
 {$else} {delphi}
  mainwindow.taskbar1.progressstate:=TTaskBarProgressState.None;
  {$endif}
end;


procedure Tmainwindow.star_annotation1Click(Sender: TObject);
begin
  mainwindow.calibrate_photometry1Click(nil);{measure hfd and calibrate for point or extended sources depending on the setting}

  plot_and_measure_stars(false {calibration},true {plot stars},false {measure lim magn});{plot stars}
end;


procedure Tmainwindow.Copyposition1Click(Sender: TObject);
var
   Centroid : string;
begin
  if object_xc>0 then Centroid:=#9+'(Centroid)' else Centroid:='';
  Clipboard.AsText:=prepare_ra8(object_raM,': ')+#9+prepare_dec2(object_decM,'° ')+Centroid;
end;


procedure Tmainwindow.Copypositionindeg1Click(Sender: TObject);
var
   Centroid : string;
begin
  if object_xc>0 then Centroid:=#9+'(Centroid)' else Centroid:='';
  Clipboard.AsText:=floattostr(object_raM*180/pi)+#9+floattostr(object_decM*180/pi)+Centroid;
end;


procedure sensor_coordinates_to_celestial(fitsx,fitsy : double; out ram,decm  : double {fitsX, Y to ra,dec});
var
   fits_unsampledX, fits_unsampledY :double;
   u,v,u2,v2             : double;
   dRa,dDec,delta,gamma  : double;

begin
 RAM:=0;DECM:=0;{for case wrong index or head.cd1_1=0}
 {DSS polynom solution}
 if mainwindow.polynomial1.itemindex=2 then {DSS survey}
 begin
 { Convert from image subsampled pixels position to unsampled pixel position }
   fits_unsampledX:=subsamp*(fitsX-0.5)+0.5;
   fits_unsampledY:=subsamp*(fitsY-0.5)+0.5;
                 //{fits (1,1)+subsamp of 2x =>(eqv unsampled 1,5,1,5)
                 //(fits (2,2)+subsamp of 2x =>(eqv unsampled 3,5,3,5)
                 //(fits 1,1)+subsamp of 4x=>(eqv unsampled 2.5,2.5)
                 //(fits 2,2)+subsamp of 4=>(eqv unsampled 6.5,6.5)
   dsspos(fits_unsampledX , fits_unsampledY, ram, decm );
 end
 else
 begin {WCS and SIP solutions}
   if ((mainwindow.Polynomial1.itemindex=1) and (a_order>=2)) then {SIP, Simple Imaging Polynomial use by astrometry.net or spitzer}
   begin
     u:=fitsx-head.crpix1;
     v:=fitsy-head.crpix2;
     u2:=u + a_0_0+ a_0_1*v + a_0_2*v*v + a_0_3*v*v*v + a_1_0*u + a_1_1*u*v + a_1_2*u*v*v + a_2_0*u*u + a_2_1*u*u*v + a_3_0*u*u*u ; {SIP correction for second or third order}
     v2:=v + b_0_0+ b_0_1*v + b_0_2*v*v + b_0_3*v*v*v + b_1_0*u + b_1_1*u*v + b_1_2*u*v*v + b_2_0*u*u + b_2_1*u*u*v + b_3_0*u*u*u ; {SIP correction for second or third order}

     dRa :=(head.cd1_1*(u2)+head.cd1_2*(v2))*pi/180;
     dDec:=(head.cd2_1*(u2)+head.cd2_2*(v2))*pi/180;
     delta:=cos(head.dec0)-dDec*sin(head.dec0);
     gamma:=sqrt(dRa*dRa+delta*delta);

     ram:=head.ra0+arctan2(Dra,delta); {atan2 is required for images containing celestial pole}
     if ram<0 then ram:=ram+2*pi;
     if ram>pi*2 then ram:=ram-pi*2;
     decm:=arctan((sin(head.dec0)+dDec*cos(head.dec0))/gamma);
   end
   else
   begin  {mainwindow.Polynomial1.itemindex=0}
     if head.cd1_1<>0 then
     begin
       dRa :=(head.cd1_1*(fitsx-head.crpix1)+head.cd1_2*(fitsy-head.crpix2))*pi/180;
       dDec:=(head.cd2_1*(fitsx-head.crpix1)+head.cd2_2*(fitsy-head.crpix2))*pi/180;
       delta:=cos(head.dec0)-dDec*sin(head.dec0);
       gamma:=sqrt(dRa*dRa+delta*delta);

       ram:=head.ra0+arctan2(Dra,delta); {arctan2 is required for images containing celestial pole}
       if ram<0 then ram:=ram+2*pi;
       if ram>pi*2 then ram:=ram-pi*2;
       decm:=arctan((sin(head.dec0)+dDec*cos(head.dec0))/gamma);
     end;
   end;
 end;{WCS solution}
end;


procedure Tmainwindow.CropFITSimage1Click(Sender: TObject);
var fitsX,fitsY,col,dum       : integer;
    ra_c,dec_c, ra_n,dec_n,ra_m, dec_m, delta_ra   : double;
    Save_Cursor:TCursor;
begin
  if ((fits_file=true) and (abs(stopX-startX)>10)and (abs(stopY-starty)>10)) then
  begin
   Save_Cursor := Screen.Cursor;
   Screen.Cursor := crHourglass;    { Show hourglass cursor }

   backup_img;

   if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
   if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

   head.width:=stopX-startx+1;
   head.height:=stopY-starty+1;
   setlength(img_temp,head.naxis3,head.width,head.height);{set length of image array}


   for col:=0 to head.naxis3-1 do
     for fitsY:=startY to stopY do
       for fitsX:=startX to stopX do {crop image INCLUDING rectangle. Do this that if used near corners they are included}
          img_temp[col,fitsX-startX,fitsY-startY]:=img_loaded[col,fitsX,fitsY];

   img_loaded:=nil;{release memory}
   img_loaded:=img_temp;

   update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
   update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);

   {new reference pixel}

   if head.cd1_1<>0 then
   begin
     {do the rigid method.}
     sensor_coordinates_to_celestial((startX+stopX)/2,(startY+stopY)/2 , ra_c,dec_c {new center RA, DEC position});
     //make 1 step in direction head.crpix1. Do first the two steps because head.cd1_1, head.cd2_1..... are required so they have to be updated after the two steps.
     sensor_coordinates_to_celestial(1+(startX+stopX)/2,(startY+stopY)/2 , ra_n,dec_n {RA, DEC position, one pixel moved in head.crpix1});
     //make 1 step in direction head.crpix2
     sensor_coordinates_to_celestial((startX+stopX)/2,1+(startY+stopY)/2 , ra_m,dec_m {RA, DEC position, one pixel moved in head.crpix2});

     delta_ra:=ra_n-ra_c;
     if delta_ra>+pi then delta_ra:=2*pi-delta_ra; {359-> 1,    +2:=360 - (359- 1)}
     if delta_ra<-pi then delta_ra:=delta_ra-2*pi; {1  -> 359,  -2:=(1-359) -360  }
     head.cd1_1:=(delta_ra)*cos(dec_c)*(180/pi);
     head.cd2_1:=(dec_n-dec_c)*(180/pi);

     delta_ra:=ra_m-ra_c;
     if delta_ra>+pi then delta_ra:=2*pi-delta_ra; {359-> 1,    +2:=360 - (359- 1)}
     if delta_ra<-pi then delta_ra:=delta_ra-2*pi; {1  -> 359,  -2:=(1-359) -360  }
     head.cd1_2:=(delta_ra)*cos(dec_c)*(180/pi);
     head.cd2_2:=(dec_m-dec_c)*(180/pi);

     head.ra0:=ra_c;
     head.dec0:=dec_c;
     head.crpix1:=(head.width+1)/2;
     head.crpix2:=(head.height+1)/2;

      new_to_old_WCS;

      update_float  ('CRVAL1  =',' / RA of reference pixel (deg)                    ' ,head.ra0*180/pi);
      update_float  ('CRVAL2  =',' / DEC of reference pixel (deg)                   ' ,head.dec0*180/pi);

      update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,head.crpix1);{adapt reference pixel of plate solution. Is no longer in the middle}
      update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,head.crpix2);

      update_float  ('CROTA1  =',' / Image twist of X axis        (deg)             ' ,head.crota1);
      update_float  ('CROTA2  =',' / Image twist of Y axis        (deg)             ' ,head.crota2);

      update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_1);
      update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_2);
      update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_1);
      update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_2);

      //   Alternative method keeping the old center poistion. Images center outside the image causes problems for image selection in planetarium program
      //   if head.crpix1<>0 then begin head.crpix1:=head.crpix1-startX; update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,head.crpix1);end;{adapt reference pixel of plate solution. Is no longer in the middle}
      //   if head.crpix2<>0 then begin head.crpix2:=head.crpix2-startY; update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,head.crpix2);end;
   end;

   update_text   ('COMMENT C','  Cropped image');


   plot_fits(mainwindow.image1,true,true);
   image_move_to_center:=true;


   Screen.Cursor:=Save_Cursor;
  end;
end;


procedure ra_text_to_radians(inp :string; out ra : double; out errorRA :boolean); {convert ra in text to double in radians}
var
  rah,ram,ras,plusmin :double;
  position1,position2,position3,error1,error2,error3, i :integer;
  degrees : boolean;
  data    : string;
begin
  inp:=uppercase(inp); {upcase once instead of every stringreplace using rfIgnorecase}
  degrees:=pos('D',inp)>0;{degrees ?}
  inp:= stringreplace(inp, ',', '.',[rfReplaceAll]);

  data:='';
  for i := 1 to length(inp) do
  begin
    if (((ord(inp[i])>=48) and (ord(inp[i])<=57)) or (inp[i]='.') or (inp[i]='-')) then   data:=data+inp[i] else data:=data+' ';{replace all char by space except for numbers and dot}
  end;
  repeat  {remove all double spaces}
    i:=pos('  ',data);
    if i>0 then delete(data,i,1);
  until i=0;


  data:=trim(data)+' ';
  if pos('-',data)>0 then plusmin:=-1 else plusmin:=1;

  position1:=pos(' ',data);
  val(copy(data,1,position1-1),rah,error1);
  if degrees then rah:=rah*24/360;{input was in degrees}


  position2:=posex(' ',data,position1+1);
  if position2-position1>1 then {ram available}
  begin
    val(copy(data,position1+1,position2-position1-1),ram,error2);

    {ram found try ras}
    position3:=posex(' ',data,position2+1);
    if position3-position2>1 then val( copy(data,position2+1,position3-position2-1),ras,error3)
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


procedure dec_text_to_radians(inp :string; out dec : double; out errorDEC :boolean); {convert dec in text to double in radians}
var
  decd,decm,decs :double;
  position1,position2,position3,error1,error2,error3,plusmin,i : integer ;
  data                                                       : string;
begin
  inp:= stringreplace(inp, ',', '.',[rfReplaceAll]);
  data:='';
  for i := 1 to length(inp) do
  begin
    if (((ord(inp[i])>=48) and (ord(inp[i])<=57)) or (inp[i]='.') or (inp[i]='-')) then   data:=data+inp[i] else data:=data+' ';{replace all char by space except for numbers and dot}
  end;
  repeat  {remove all double spaces}
    i:=pos('  ',data);
    if i>0 then delete(data,i,1);
  until i=0;;


  data:=trim(data)+' ';
  if pos('-',data)>0 then plusmin:=-1 else plusmin:=1;

  position1:=pos(' ',data);
  val(copy(data,1,position1-1),decd,error1);


  position2:=posex(' ',data,position1+1);
  if position2-position1>1 then {decm available}
  begin
    val(copy(data,position1+1,position2-position1-1),decm,error2);

    {decm found try decs}
    position3:=posex(' ',data,position2+1);
    if position3-position2>1 then val( copy(data,position2+1,position3-position2-1),decs,error3)
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

    mouse_positionRADEC1:=InputBox('Enter α, δ of mouse position separated by a comma:','Format 24 00 00.0, 90 00 00.0   or   24 00, 90 00',mouse_positionRADEC1);
    if mouse_positionRADEC1=''  then exit; {cancel used}
    shape_marker1.hint:='Reference 1: '+mouse_positionRADEC1
  end
  else
  if sender=enterposition2 then
  begin
    shape_marker2_fitsX:=startX+1;
    shape_marker2_fitsY:=startY+1;
    show_marker_shape(mainwindow.shape_marker2,0 {rectangle},20,20,0 {minimum size},shape_marker2_fitsX, shape_marker2_fitsY);

    mouse_positionRADEC2:=InputBox('Enter α, δ of mouse position separated by a comma:','Format 24 00 00.0, 90 00 00.0   or   24 00, 90 00',mouse_positionRADEC2);
    if mouse_positionRADEC2=''  then exit;  {cancel used}
    shape_marker2.hint:='Reference 2: '+mouse_positionRADEC2
  end;

  if ( (mouse_positionRADEC1<>'') and (mouse_positionRADEC2<>'')) then {solve}
  begin
    flipped:=flipped1.checked; {flipped image}

    head.crpix1:=shape_marker1_fitsX;
    head.crpix2:=shape_marker1_fitsY;

    kommapos:=pos(',',mouse_positionRADEC1);
    ra_text_to_radians (copy(mouse_positionRADEC1,1  ,kommapos-1) ,head.ra0,error2); {convert ra text to ra_1 in radians}
    if error2 then begin beep;exit;end;
    dec_text_to_radians(copy(mouse_positionRADEC1,kommapos+1,99) ,head.dec0,error2); {convert dec text to dec_1 in radians}
    if error2 then begin beep;exit;end;

    kommapos:=pos(',',mouse_positionRADEC2);
    ra_text_to_radians (copy(mouse_positionRADEC2,1  ,kommapos-1) ,ra2,error2); {convert ra text to head.ra0 in radians}
    if error2 then begin beep;exit;end;
    dec_text_to_radians(copy(mouse_positionRADEC2,kommapos+1,99) ,dec2,error2); {convert dec text to head.dec0 in radians}
    if error2 then begin beep;exit;end;

    pixeldistance:=sqrt(sqr(shape_marker2_fitsX- shape_marker1_fitsX)+sqr(shape_marker2_fitsY- shape_marker1_fitsY));
    ang_sep(head.ra0,head.dec0,ra2,dec2 ,distance);{calculate distance in radians}

    head.cdelt2:=distance*180/(pi*pixeldistance);
    if flipped then head.cdelt1:=-head.cdelt2 else head.cdelt1:=head.cdelt2;

    {find head.crota2}
   {see meeus new formula 46.5, angle of moon limb}
    angle2:=arctan2(cos(dec2)*sin(ra2-head.ra0),sin(dec2)*cos(head.dec0) - cos(dec2)*sin(head.dec0)*cos(ra2-head.ra0)); {angle between line between the two stars and north}
    angle3:=arctan2(shape_marker2_fitsX- shape_marker1_fitsX,shape_marker2_fitsY- shape_marker1_fitsY); {angle between top and line between two reference pixels}

    if flipped then
      angle:=(angle2+angle3)  ELSE angle:=(-angle2+angle3);{swapped n-s or e-w image}

    angle:=fnmodulo(angle,2*pi);

    if angle< -pi then angle:=angle+2*pi;
    if angle>=+pi then angle:=angle-2*pi;

    head.crota2:=-angle*180/pi;{head.crota2 is defined north to west, so reverse}
    head.crota1:=head.crota2;

    old_to_new_WCS;{new WCS missing, convert old WCS to new}

    update_text ('CTYPE1  =',#39+'RA---TAN'+#39+'           / first parameter RA  ,  projection TANgential   ');
    update_text ('CTYPE2  =',#39+'DEC--TAN'+#39+'           / second parameter DEC,  projection TANgential   ');
    update_text ('CUNIT1  =',#39+'deg     '+#39+'           / Unit of coordinates                            ');

    update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,head.crpix1);
    update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,head.crpix2);

    update_float  ('CRVAL1  =',' / RA of reference pixel (deg)                    ' ,head.ra0*180/pi);
    update_float  ('CRVAL2  =',' / DEC of reference pixel (deg)                   ' ,head.dec0*180/pi);


    update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,head.cdelt1);
    update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,head.cdelt2);

    update_float  ('CROTA1  =',' / Image twist of X axis        (deg)             ' ,head.crota1);
    update_float  ('CROTA2  =',' / Image twist of Y axis        (deg)             ' ,head.crota2);

    update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_1);
    update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_2);
    update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_1);
    update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_2);
    update_text   ('PLTSOLVD=','                   T / ASTAP manual with two positions');

    update_menu_related_to_solver(true); {update menu section related to solver succesfull}

    plot_north;
    plot_north_on_image;
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

  for col:=0 to head.naxis3-1 do {do all colours}
  begin
    For fitsY:=0 to (head.height-1) do
      for fitsX:=0 to (head.width-1) do
      begin
        img_loaded[col,fitsX,fitsY]:=max_range-img_loaded[col,fitsX,fitsY]
      end;
  end;

  head.datamax_org:=max_range;
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
  stackmenu1.center_position1.caption:='Center: '+inttostr((startX+stopX) div 2)+', '+inttostr((startY+stopY) div 2);
end;


procedure Tmainwindow.rotate_arbitrary1Click(Sender: TObject);
var
  centerxs,centerys,angle  : double;
  valueI : string;
  Save_Cursor:TCursor;

begin
  valueI:=InputBox('Arbitrary rotation','Enter angle CCW in degrees:              (If solved, enter N for north up)','' );
  if valueI=''  then exit;
  if ((valueI='n') or (valueI='N')) then
    angle:=-head.crota2
  else
    angle:=strtofloat2(valueI);

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }


  memo2_message('Start rotation. This takes some time due to subsampling 10x10.');
  backup_img;

 if flip_horizontal1.checked then angle:=-angle;{change rotation if flipped}
 if flip_vertical1.checked then   angle:=-angle;{change rotation if flipped}

 centerxs:=head.width/2;
 centerys:=head.height/2;

  raster_rotate(angle,centerxs,centerys ,img_loaded);
//  rotate_arbitraryold(angle,img_loaded);

  head.width:=length(img_loaded[0]);{update width}  ;
  head.height:=length(img_loaded[0,0]);{update length};

  update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);


  if head.cd1_1<>0 then {update solution for rotation}
  begin
     if ((head.crpix1<>0.5+centerxs) or (head.crpix2<>0.5+centerys)) then {reference is not center}
     begin  {to much hassle to fix. Just remove the solution}
       remove_key('CD1_1   ',false);
       remove_key('CD1_2   ',false);
       remove_key('CD2_1   ',false);
       remove_key('CD2_2   ',false);
     end;
     head.crota2:=fnmodulo(head.crota2+angle,360);
     head.crota1:=fnmodulo(head.crota1+angle,360);
     head.crpix1:= head.width/2;
     head.crpix2:=head.height/2;
     old_to_new_WCS;{convert old style FITS to newd style}

     update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_1);
     update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_2);
     update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_1);
     update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_2);


     update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,head.crpix1);
     update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,head.crpix2);

     update_float  ('CROTA1  =',' / Image twist of X axis        (deg)             ' ,head.crota1);
     update_float  ('CROTA2  =',' / Image twist of Y axis        (deg)             ' ,head.crota2);


     add_text   ('HISTORY   ','Rotated CCW by angle '+valueI);
  end;
  remove_key('ANNOTATE',true{all});{this all will be invalid}

  plot_fits(mainwindow.image1,false,true);

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


procedure find_highest_pixel_value(img: image_array;box, x1,y1: integer; out xc,yc:double);{}
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
    if ((x_trunc<=0) or (x_trunc>=(head.width-2)) or (y_trunc<=0) or (y_trunc>=(head.height-2))) then begin result:=0; exit;end;
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


procedure Tmainwindow.gaia_star_position1Click(Sender: TObject);
var
   url,ra8,dec8,sgn,window_size,magn,dec_degrees  : string;
   ang_h,ang_w,ra1,ra2,dec1,dec2 : double;
   radius,x1,y1                  : integer;
begin
  if ((abs(stopX-startX)<2) and (abs(stopY-startY)<2))then
  begin
    if object_xc>0 then {object sync}
    begin
      window_size:='&-c.bs=5&-out.max=100&Gmag=<23'; {circle search 5 arcsec}
      stopX:=stopX+8;{create some size for two line annotation}
      startX:=startX-8;
      ang_w:=10 {radius 5 arc seconds for Simbad}
    end
    else
    begin
      application.messagebox(pchar('No star lock or No area selected! Place mouse on a star or hold the right mouse button down while selecting an area.'),'',MB_OK);
      exit;
    end;
  end
  else
  begin
    ang_w:=abs((stopX-startX)*head.cdelt2*3600);{arc sec}
    ang_h:=abs((stopY-startY)*head.cdelt2*3600);{arc sec}

    window_size:='&-c.bs='+ floattostr6(ang_w)+'/'+floattostr6(ang_h)+'&-out.max=300&Gmag=<23';{square box}
    {-c.geom=b  square box, -c.bs=10 box size 10arc
    else radius}
    sensor_coordinates_to_celestial(startX+1,startY+1,ra1,dec1);{first position}
    sensor_coordinates_to_celestial(stopX+1,stopY+1,ra2,dec2);{first position}
    object_raM:=(ra1+ra2)/2; {center position}
    object_decM:=(dec1+dec2)/2;
  end;

  image1.Canvas.Pen.Mode := pmMerge;
  image1.Canvas.Pen.width :=1;
  mainwindow.image1.Canvas.Pen.Color:= annotation_color;{clyellow}
  mainwindow.image1.Canvas.brush.Style:=bsClear;

  str(abs(object_decM*180/pi) :3:10,dec8);
  if object_decM>=0 then sgn:='+'  else sgn:='-';
  str(abs(object_raM*180/pi) :3:10,ra8);

  if sender=mainwindow.gaia_star_position1 then
  begin
    plot_the_annotation(stopX+1,stopY+1,startX+1,startY+1,0,'','');{rectangle, +1 to fits coordinates}
    url:='http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/350/Gaiaedr3&-out=Source,RA_ICRS,DE_ICRS,Plx,pmRA,pmDE,Gmag,BPmag,RPmag&-c='+ra8+sgn+dec8+window_size;
    //http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/350/Gaiaedr3&-out=Source,RA_ICRS,DE_ICRS,pmRA,pmDE,Gmag,BPmag,RPmag&-c=86.5812345-10.3456,bm=1x1&-out.max=1000000&BPmag=%3C21.5

  end
  else
  if sender=mainwindow.simbad_query1 then
  begin {sender simbad_query1}
    radius:=max(abs(stopX-startX),abs(stopY-startY)) div 2; {convert elipse to circle}
    x1:=(stopX+startX) div 2;
    y1:=(stopY+startY) div 2;
    plot_the_circle(x1-radius,y1-radius,x1+radius,y1+radius);
    url:='http://simbad.u-strasbg.fr/simbad/sim-coo?Radius.unit=arcsec&Radius='+floattostr6(max(ang_w,ang_h)/2)+'&Coord='+ra8+'d'+sgn+dec8+'d';
    //  url:='http://simbad.u-strasbg.fr/simbad/sim-coo?Radius.unit=arcsec&Radius=0.4692&Coord=195.1060d28.1998d
  end
  else
  begin {sender aavso_chart1}
    magn:=inputbox('Chart request','Limiting magnitude chart:' ,'15');

    radius:=max(abs(stopX-startX),abs(stopY-startY)) div 2; {convert elipse to circle}
    x1:=(stopX+startX) div 2;
    y1:=(stopY+startY) div 2;
    plot_the_annotation(x1-radius+1,y1-radius+1,x1+radius+1,y1+radius+1,0,'','');{square}

    ra8:=prepare_ra(object_raM,' '); {radialen to text, format 24: 00 00.0 }
    dec8:=prepare_dec(object_decM,' '); {radialen to text, format 90d 00 00}

    if dec8[1]='+' then dec_degrees:=copy(dec8,2,2) else dec_degrees:=copy(dec8,1,3);
    url:='https://app.aavso.org/vsp/chart/?ra='+copy(ra8,1,2)+'%3A'+copy(ra8,4,2)+'%3A'+copy(ra8,7,99)+'&dec='+dec_degrees+'%3A'+copy(dec8,5,2)+'%3A'+copy(dec8,8,99)+'&scale=C&orientation=visual&type=chart&fov='+inttostr(round( (ang_w+ang_w)/(60*2)))+'&maglimit='+trim(magn)+'&resolution=150&north=up&east=left'

    //  https://app.aavso.org/vsp/chart/?ra=08%3A40%3A29.63&dec=40%3A07%3A24.4&scale=C&orientation=visual&type=chart&fov=120.0&maglimit=12.0&resolution=150&north=up&east=left
  end;
  openurl(url);
end;


procedure Tmainwindow.mountposition1Click(Sender: TObject);
begin
  if fits_file=false then exit;
  if mountposition1.checked then
  begin
    plot_large_north_indicator;
    image1.refresh;{important, show update}
  end
  else
    plot_fits(mainwindow.image1,false,true); {clear indiicator}
end;


procedure Tmainwindow.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  width5,height5, xf,yf,k, fx,fy, shapetype  : integer;
  hfd2,fwhm_star2,snr,flux,xc,yc,xcf,ycf     : double;
begin
  if flip_horizontal1.Checked then xf:=image1.width-1-x else xf:=x;;
  if flip_vertical1.Checked then yf:=image1.height-1-y else yf:=y;

  startX:=round(-0.5+(xf+0.5)/(image1.width/head.width));{starts at -0.5 and  middle pixels is 0}
  startY:=round(-0.5+head.height-(yf+0.5)/(image1.height/head.height)); {from bottom to top, starts at -0.5 and 0 at middle first pixel}

  stopX:=startX;{prevent random crop and other actions}
  stopY:=startY;

  {default good values}
  snr:=10;
  hfd2:=2;{just a good value}

  {for manual alignment and photometry}
  if  ((stackmenu1.pagecontrol1.tabindex=0) and (stackmenu1.use_manual_alignment1.checked) and (pos('S',head.calstat)=0 {ignore stacked images unless callled from listview1. See doubleclick listview1} )) then
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
      xc:=startX;{0..head.width-1}
      yc:=startY;
    end
    else {star alignment}
    HFD(img_loaded,startX,startY,14{annulus radius},99 {flux aperture restriction},hfd2,fwhm_star2,snr,flux,xc,yc); {auto center using HFD function}


    if hfd2<90 then {detected something}
    begin
      shape_fitsX:=xc+1;{calculate fits positions}
      shape_fitsY:=yc+1;
      if snr>5 then shapetype:=1 {circle} else shapetype:=0;{square}
      listview_add_xy(shape_fitsX,shape_fitsY);{add to list of listview1}
      show_marker_shape(mainwindow.shape_manual_alignment1,shapetype,20,20,10{minimum},shape_fitsX, shape_fitsY);
    end;
  end
  else
  if stackmenu1.pagecontrol1.tabindex=8 {photometry} then
  begin
    {star alignment}
    HFD(img_loaded,startX,startY,14{annulus radius},99 {flux aperture restriction},hfd2,fwhm_star2,snr,flux,xc,yc); {auto center using HFD function}
    if hfd2<90 then {detected something}
    begin
      if snr>5 then shapetype:=1 {circle} else shapetype:=0;{square}
      xcf:=xc+1;{make fits coordinates}
      ycf:=yc+1;
      if shape_nr=1 then
      begin
        if ((abs(shape_fitsX2-xcf)<=3) and (abs(shape_fitsY2-ycf)<=3)) then begin shape_fitsX2:=shape_fitsX;shape_fitsY2:=shape_fitsY;end{swap, prevent overlapping}
        else
        if ((abs(shape_fitsX3-xcf)<=3) and (abs(shape_fitsY3-ycf)<=3)) then begin shape_fitsX3:=shape_fitsX;shape_fitsY3:=shape_fitsY;end;
        shape_fitsX:=xcf; shape_fitsY:=ycf;
      end
      else
      if shape_nr=2 then
      begin
        if ((abs(shape_fitsX-xcf)<=3) and (abs(shape_fitsY-ycf)<=3)) then begin shape_fitsX:=shape_fitsX2;shape_fitsY:=shape_fitsY2;end{swap, prevent overlapping}
        else
        if ((abs(shape_fitsX3-xcf)<=3) and (abs(shape_fitsY3-ycf)<=3)) then begin shape_fitsX3:=shape_fitsX2;shape_fitsY3:=shape_fitsY2;end;
        shape_fitsX2:=xcf; shape_fitsY2:=ycf; {calculate fits positions}
      end
      else
      if shape_nr=3 then
      begin
        if ((abs(shape_fitsX-xcf)<=3) and (abs(shape_fitsY-ycf)<=3)) then begin shape_fitsX:=shape_fitsX3;shape_fitsY:=shape_fitsY3;end{swap, prevent overlapping}
        else
        if ((abs(shape_fitsX2-xcf)<=3) and (abs(shape_fitsY2-ycf)<=3)) then begin shape_fitsX2:=shape_fitsX3;shape_fitsY2:=shape_fitsY3;end;
        shape_fitsX3:=xcf; shape_fitsY3:=ycf;
      end;
      show_marker_shape(mainwindow.shape_alignment_marker1,shapetype,20,20,10{minimum},shape_fitsX, shape_fitsY);
      show_marker_shape(mainwindow.shape_alignment_marker2,shapetype,20,20,10{minimum},shape_fitsX2, shape_fitsY2);
      show_marker_shape(mainwindow.shape_alignment_marker3,shapetype,20,20,10{minimum},shape_fitsX3, shape_fitsY3);

      inc(shape_nr);
      if shape_nr>=4 then
      shape_nr:=1;
    end;
  end;
 {end photometry}

  image_move_to_center:=false;{image in moved to center, why is so difficult???}

  down_x:=x;
  down_y:=y;
  down_xy_valid := True;

  if ssleft in shift then
  begin
    screen.Cursor := crhandpoint;

    if ((head.naxis3=3) and (stackmenu1.pagecontrol1.tabindex=12) {pixelmath 1}) then {for colour replace function}
    begin
      sample(startX,startY);
    end;

    if copy_paste then {paste copied image part}
    begin
      width5:=Length(img_loaded[0]);    {width}
      height5:=Length(img_loaded[0][0]); {height}
      for k:=0 to head.naxis3-1 do {do all colors}
      begin
        for fy:=copy_paste_y to copy_paste_y+copy_paste_h-1 do
        for fX:=copy_paste_x to copy_paste_x+copy_paste_w-1 do
        begin
          img_loaded[k,max(0,min(width5-1,round(startX+(fx-copy_paste_x)- (copy_paste_w div 2)))),max(0,min(height5-1,round(startY+(fy-copy_paste_y) - (copy_paste_h div 2))))]:=img_backup[index_backup].img[k,fx,fy];{use backup for case overlap occurs}
        end;
      end;{k color}
      plot_fits(mainwindow.image1,false,true);
      copy_paste:=false;
      shape_paste1.visible:=false;
    end;
  end;{left button pressed}
end;

{calculates star HFD and FWHM, SNR, xc and yc are center of gravity, rs is the boxsize, aperture for the flux measurment. All x,y coordinates in array[0..] positions}
{aperture_small is used for photometry of stars. Set at 99 for normal full flux mode}
{Procedure uses two global accessible variables:  r_aperture and sd_bg }
procedure HFD(img: image_array;x1,y1,rs {annulus diameter}: integer;aperture_small:double; out hfd1,star_fwhm,snr{peak/sigma noise}, flux,xc,yc:double);
const
  max_ri=74; //(50*sqrt(2)+1 assuming rs<=50. Should be larger or equal then sqrt(sqr(rs+rs)+sqr(rs+rs))+1+2;

var
  width5,height5,i,j,r1_square,r2_square,r2, distance,distance_top_value,illuminated_pixels,signal_counter,counter,annulus_width :integer;
  SumVal,Sumval_small, SumValX,SumValY,SumValR, Xg,Yg, r, val,pixel_counter,valmax,mad_bg    : double;
  HistStart,boxed : boolean;
  distance_histogram : array [0..max_ri] of integer;
  background : array [0..1000] of double; {size =3*(2*PI()*(50+3)) assuming rs<=50}

    function value_subpixel(x1,y1:double):double; {calculate image pixel value on subpixel level}
    var
      x_trunc,y_trunc: integer;
      x_frac,y_frac  : double;
    begin
      x_trunc:=trunc(x1);
      y_trunc:=trunc(y1);
      if ((x_trunc<=0) or (x_trunc>=(width5-2)) or (y_trunc<=0) or (y_trunc>=(height5-2))) then begin result:=0; exit;end;
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
  width5:=Length(img[0]);    {width}
  height5:=Length(img[0][0]); {height}

  {rs should be <=50 to prevent runtime errors}
  if  aperture_small<99 then
    annulus_width:=3 {high precession}
  else
    annulus_width:=1;{normal & fast}

  r1_square:=rs*rs;{square radius}
  r2:=rs+annulus_width;
  r2_square:=r2*r2;

  if ((x1-r2<=0) or (x1+r2>=width5-1) or
      (y1-r2<=0) or (y1+r2>=height5-1) )
    then begin hfd1:=999; snr:=0; exit;end;

  valmax:=0;
  hfd1:=999;
  snr:=0;

  try
    counter:=0;
    for i:=-r2 to r2 do {calculate the mean outside the the detection area}
    for j:=-r2 to r2 do
    begin
      distance:=i*i+j*j; {working with sqr(distance) is faster then applying sqrt}
      if ((distance>r1_square) and (distance<=r2_square)) then {annulus, circular area outside rs, typical one pixel wide}
      begin
        background[counter]:=img[0,x1+i,y1+j];
        //for testing: mainwindow.image1.canvas.pixels[x1+i,y1+j]:=$AAAAAA;
        inc(counter);
      end;
    end;

    star_bg:=Smedian(background,counter);
    for i:=0 to counter-1 do background[i]:=abs(background[i] - star_bg);{fill background with offsets}
    mad_bg:=Smedian(background,counter); //median absolute deviation (MAD)
    sd_bg:=mad_bg*1.4826; {Conversion from mad to sd for a normal distribution. See https://en.wikipedia.org/wiki/Median_absolute_deviation}
    sd_bg:=max(sd_bg,1); {add some value for images with zero noise background. This will prevent that background is seen as a star. E.g. some jpg processed by nova.astrometry.net}
    {star_bg, sd_bg and r_aperture are global variables}

    repeat {reduce square annulus radius till symmetry to remove stars}
    // Get center of gravity whithin star detection box and count signal pixels, repeat reduce annulus radius till symmetry to remove stars
      SumVal:=0;
      SumValX:=0;
      SumValY:=0;
      signal_counter:=0;

      for i:=-rs to rs do
      for j:=-rs to rs do
      begin
        val:=(img[0,x1+i,y1+j])- star_bg;
        if val>3.0*sd_bg then
        begin
          SumVal:=SumVal+val;
          SumValX:=SumValX+val*(i);
          SumValY:=SumValY+val*(j);
          inc(signal_counter); {how many pixels are illuminated}
        end;
      end;
      if sumval<= 12*sd_bg then
         exit; {no star found, too noisy, exit with hfd=999}

      Xg:=SumValX/SumVal;
      Yg:=SumValY/SumVal;
      xc:=(x1+Xg);
      yc:=(y1+Yg);
     {center of gravity found}

      if ((xc-rs<0) or (xc+rs>width5-1) or (yc-rs<0) or (yc+rs>height5-1) ) then
                                 exit;{prevent runtime errors near sides of images}
      boxed:=(signal_counter>=(2/9)*sqr(rs+rs+1));{are inside the box 2 of the 9 of the pixels illuminated? Works in general better for solving then ovality measurement as used in the past}

      if boxed=false then
      begin
        if rs>4 then dec(rs,2) else dec(rs,1); {try a smaller window to exclude nearby stars}
      end;

      {check on hot pixels}
      if signal_counter<=1  then
      exit; {one hot pixel}
    until ((boxed) or (rs<=1)) ;{loop and reduce aperture radius until star is boxed}

    inc(rs,2);{add some space}

    // Build signal histogram from center of gravity
    for i:=0 to rs do distance_histogram[i]:=0;{clear signal histogram for the range used}
    for i:=-rs to rs do begin
      for j:=-rs to rs do begin

        distance:=round(sqrt(i*i + j*j)); {distance from gravity center} {modA}
        if distance<=rs then {build histogram for circel with radius rs}
        begin
          val:=value_subpixel(xc+i,yc+j)-star_bg;
          if val>3.0*sd_bg then {3 * sd should be signal }
          begin
            distance_histogram[distance]:=distance_histogram[distance]+1;{build distance histogram up to circel with diameter rs}
            if val>valmax then valmax:=val;{record the peak value of the star}
          end;
        end;
      end;
    end;

    r_aperture:=-1;
    distance_top_value:=0;
    HistStart:=false;
    illuminated_pixels:=0;
    repeat
      inc(r_aperture);
      illuminated_pixels:=illuminated_pixels+distance_histogram[r_aperture];
      if distance_histogram[r_aperture]>0 then HistStart:=true;{continue until we found a value>0, center of defocused star image can be black having a central obstruction in the telescope}
      if distance_top_value<distance_histogram[r_aperture] then distance_top_value:=distance_histogram[r_aperture]; {this should be 2*pi*r_aperture if it is nice defocused star disk}
    until ( (r_aperture>=rs) or (HistStart and (distance_histogram[r_aperture]<=0.1*distance_top_value {drop-off detection})));{find a distance where there is no pixel illuminated, so the border of the star image of interest}
    if r_aperture>=rs then exit; {star is equal or larger then box, abort}

    if (r_aperture>2)and(illuminated_pixels<0.35*sqr(r_aperture+r_aperture-2)){35% surface} then exit;  {not a star disk but stars, abort with hfd 999}

    except
  end;

  // Get HFD
  SumVal:=0;
  Sumval_small:=0;
  SumValR:=0;
  pixel_counter:=0;


  // Get HFD using the aproximation routine assuming that HFD line divides the star in equal portions of gravity:
  for i:=-r_aperture to r_aperture do {Make steps of one pixel}
  for j:=-r_aperture to r_aperture do
  begin
    Val:=value_subpixel(xc+i,yc+j)-star_bg; {The calculated center of gravity is a floating point position and can be anyware, so calculate pixel values on sub-pixel level}
    r:=sqrt(i*i+j*j); {Distance from star gravity center}
    if r<=aperture_small then SumVal_small:=SumVal_small+Val; {For photometry only. Flux within aperture_small. Works more accurate for differential photometry}
    SumVal:=SumVal+Val;{Sumval will be star total star flux}
    SumValR:=SumValR+Val*r; {Method Kazuhisa Miyashita, see notes of HFD calculation method, note calculate HFD over square area. Works more accurate then for round area}
    if val>=valmax*0.5 then pixel_counter:=pixel_counter+1;{How many pixels are above half maximum}
  end;
  flux:=max(sumval,0.00001);{prevent dividing by zero or negative values}
  hfd1:=2*SumValR/flux;
  hfd1:=max(0.7,hfd1);

  star_fwhm:=2*sqrt(pixel_counter/pi);{calculate from surface (by counting pixels above half max) the diameter equals FWHM }

  if r_aperture<aperture_small then {normal mode}
  begin
     snr:=flux/sqrt(flux +sqr(r_aperture)*pi*sqr(sd_bg));
     {For both bright stars (shot-noise limited) or skybackground limited situations
       snr := signal/noise
       snr := star_signal/sqrt(total_signal)
       snr := star_signal/sqrt(star_signal + sky_signal)
       equals
       snr:=flux/sqrt(flux + r*r*pi* sd^2).

       r is the diameter used for star flux measurement. Flux is the total star flux detected above 3* sd.

       Assuming unity head.gain ADU/e-=1
       See https://en.wikipedia.org/wiki/Signal-to-noise_ratio_(imaging)
       https://www1.phys.vt.edu/~jhs/phys3154/snr20040108.pdf
       http://spiff.rit.edu/classes/phys373/lectures/signal/signal_illus.html}

  //   memo2_message(#9+'######'+#9+inttostr(round(flux))+#9+ floattostr6(r_aperture)+#9+floattostr6(sd)+#9+floattostr6(snr)+#9+floattostr6(sqr(r_aperture)*pi*sqr(sd)));
  end
  else
  begin {photometry mode. Measure only brightest part of the stars}
    flux:=max(sumval_small,0.00001);{prevent dividing by zero or negative values}
    snr:=flux/sqrt(flux +sqr(aperture_small)*pi*sqr(sd_bg)); {For both bright stars (shot-noise limited) or skybackground limited situations  snr:=signal/sqrt(signal + r*r*pi* SKYsignal) equals snr:=flux/sqrt(flux + r*r*pi* sd^2). }
  end;

  {==========Notes on HFD calculation method=================
    Documented this HFD definition also in https://en.wikipedia.org/wiki/Half_flux_diameter
    References:
    https://astro-limovie.info/occultation_observation/halffluxdiameter/halffluxdiameter_en.html       by Kazuhisa Miyashita. No sub-pixel calculation
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

    The approximate routine is robust and efficient.

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


procedure local_sd(x1,y1, x2,y2,col : integer;{accuracy: double;} img : image_array; out sd,mean :double; out iterations :integer);{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}
var i,j,counter,w,h : integer;
    value, sd_old,meanx   : double;

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
    if ((ratio>0.04) and (ratio<1.55)) then {valid between 2000 and 20000 kelvin}
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


procedure erase_rectangle;
begin
  begin
    mainwindow.image1.Canvas.Pen.color:=clblack;{define otherwise problems in Linux}
    mainwindow.image1.Canvas.Pen.Mode := pmNotXor;       { use XOR mode to draw/erase }
    mainwindow.image1.Canvas.Pen.width := round(1+head.width/mainwindow.image1.width);{thick lines because image is stretched smaller and otherwise line can't been seen}
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
  mainwindow.image1.Canvas.Pen.width := round(1+head.width/mainwindow.image1.width);{thick lines because image is stretched smaller and otherwise line can't been seen}
  mainwindow.image1.Canvas.LineTo(X_sized, start_RY);    { draw the new line }
  mainwindow.image1.Canvas.LineTo(X_sized, Y_sized);   { draw the new line }
  mainwindow.image1.Canvas.LineTo(start_RX, Y_sized);    { draw the new line }
  mainwindow.image1.Canvas.LineTo(start_RX, start_RY);     { draw the new line }
  mainwindow.image1.Canvas.Pen.Mode := pmCopy;{back to normal}
end;


procedure Tmainwindow.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);

var
  hfd2,fwhm_star2,snr,flux,xf,yf, raM,decM,pixel_distance,sd,dummy,conv_factor : double;
  s1,s2, hfd_str, fwhm_str,snr_str,mag_str,dist_str,angle_str                  : string;
  width5,height5,x_sized,y_sized,factor,flipH,flipV,iterations                 : integer;
  color1:tcolor;
  r,b :single;
begin
   if ssleft in shift then {swipe effect}
   begin
     if down_xy_valid then
     begin
       if abs(y-down_y)>2 then
       begin
         mainwindow.image1.Top:= mainwindow.image1.Top+(y-down_y);
       //   timage(sender).Top:= timage(sender).Top+(y-down_y);{could be used for second image}

         mainwindow.shape_marker1.Top:= mainwindow.shape_marker1.Top+(y-down_y);{normal marker}
         mainwindow.shape_marker2.Top:= mainwindow.shape_marker2.Top+(y-down_y);{normal marker}
         mainwindow.shape_marker3.Top:= mainwindow.shape_marker3.Top+(y-down_y);{normal marker}
         mainwindow.shape_marker4.Top:= mainwindow.shape_marker4.Top+(y-down_y);{normal marker}
       end;
       if abs(x-down_x)>2 then
       begin
         mainwindow.image1.left:= mainwindow.image1.left+(x-down_x);
        //  timage(sender).left:= timage(sender).left+(x-down_x);

         mainwindow.shape_marker1.left:= mainwindow.shape_marker1.left+(x-down_x);{normal marker}
         mainwindow.shape_marker2.left:= mainwindow.shape_marker2.left+(x-down_x);{normal marker}
         mainwindow.shape_marker3.left:= mainwindow.shape_marker3.left+(x-down_x);{normal marker}
         mainwindow.shape_marker4.left:= mainwindow.shape_marker4.left+(x-down_x);{normal marker}
       end;
       if ((abs(y-down_y)>2) or (abs(x-down_x)>2)) then
       begin
         {three markers}
         if mainwindow.shape_manual_alignment1.visible then {For manual alignment. Do this only when visible}
           show_marker_shape(mainwindow.shape_manual_alignment1,9 {no change in shape and hint},20,20,10,shape_fitsX, shape_fitsY);

         if mainwindow.shape_alignment_marker1.visible then {For manual alignment. Do this only when visible}
           show_marker_shape(mainwindow.shape_alignment_marker1,9 {no change in shape and hint},20,20,10,shape_fitsX, shape_fitsY);
          if mainwindow.shape_alignment_marker2.visible then {For manual alignment. Do this only when visible}
            show_marker_shape(mainwindow.shape_alignment_marker2,9 {no change in shape and hint},20,20,10,shape_fitsX2, shape_fitsY2);
          if mainwindow.shape_alignment_marker3.visible then {For manual alignment. Do this only when visible}
            show_marker_shape(mainwindow.shape_alignment_marker3,9 {no change in shape and hint},20,20,10,shape_fitsX3, shape_fitsY3);
       end;
     end;

     exit;{no more to do}
   end
   else
   down_xy_valid := False; {every move without ssleft will invalidate down_xy}

   width5:=Length(img_loaded[0]);    {width}
   height5:=Length(img_loaded[0][0]); {height}

   if flip_horizontal1.Checked then flipH:=-1 else flipH:=1;
   if flip_vertical1.Checked then  flipV:=-1 else flipV:=1;

   if flipH=-1 then xf:=image1.width-1-x else xf:=x;;
   if flipV=-1 then yf:=image1.height-1-y else yf:=y;

   mouse_fitsx:=0.5+(0.5+xf)/(image1.width/width5);{starts at +0.5 and  middle pixels is 1}
   mouse_fitsy:=0.5+height5-(0.5+yf)/(image1.height/height5); {from bottom to top, starts at +0.5 and 1 at middle first pixel}


//  rubber rectangle
   x_sized:=trunc(x*width5/image1.width);
   y_sized:=trunc(y*height5/image1.height);

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


   factor:=round(1+width5/image1.width);
   if ((abs(stop_RX -x)>factor) and (abs(stop_RY -y)>factor))then
   begin
     if ssright in shift then {rubber rectangle}
     begin
       erase_rectangle;
       draw_rectangle(x_sized,y_sized);

       stopX:=round(-1+mouse_fitsX); {starts at -0.5 and  middle pixels is 0}
       stopY:=round(-1+mouse_fitsY); {from bottom to top, starts at -0.5 and 0 at middle first pixel}

       if head.cdelt2<>0 then
       begin
         pixel_distance:= 3600*sqrt (sqr((X_sized-start_RX)*head.cdelt1)+sqr((start_RY-Y_sized)*head.cdelt2));{pixel distance in arcsec}
         if pixel_distance<60 then dist_str:=inttostr(round(pixel_distance))+'"'
         else
         if pixel_distance<3600 then dist_str:=floattostrF(pixel_distance/60,ffgeneral,3,2)+#39
         else
         dist_str:=floattostrF(pixel_distance/3600,ffgeneral,3,2)+'°';
       end
       else dist_str:='';
       if head.cdelt2<>0 then angle_str:='∠='+inttostr(round(fnmodulo (arctan2(flipH*(X_sized-start_RX),flipV*(start_RY-Y_sized))*180/pi + head.crota2,360)) )+'°' else  angle_str:=''; ;
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
   if mouse_fitsY>height5 then mouse_fitsY:=height5;
   if mouse_fitsX>width5 then mouse_fitsX:=width5;

   if copy_paste then
   begin
      show_marker_shape(mainwindow.shape_paste1,0 {rectangle},copy_paste_w,copy_paste_h,0{minimum}, mouse_fitsx, mouse_fitsy);{show the paste shape}
   end;
   try color1:=ColorToRGB(mainwindow.image1.canvas.pixels[trunc(x*width5/image1.width),trunc(y*height5/image1.height)]); ;except;end;  {note  getpixel(image1.canvas.handle,x,y) doesn't work well since X,Y follows zoom  factor !!!}

   if head.naxis3=3 then {for star temperature}
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
     if head.naxis3=1 then mainwindow.statusbar1.panels[3].text:=s1+', '+s2+' = ['+floattostrF(img_loaded[0,round(mouse_fitsX)-1,round(mouse_fitsY)-1],ffgeneral,5,0)+']' else
     if head.naxis3=3 then mainwindow.statusbar1.panels[3].text:=s1+', '+s2+' = ['+floattostrF(img_loaded[0,round(mouse_fitsX)-1,round(mouse_fitsY)-1],ffgeneral,5,0)+'/'+ {color}
                                                                              floattostrF(img_loaded[1,round(mouse_fitsX)-1,round(mouse_fitsY)-1],ffgeneral,5,0)+'/'+
                                                                              floattostrF(img_loaded[2,round(mouse_fitsX)-1,round(mouse_fitsY)-1],ffgeneral,5,0)+' '+']'
     else mainwindow.statusbar1.panels[3].text:='';
   except

   end;

   sensor_coordinates_to_celestial(mouse_fitsx,mouse_fitsy,raM,decM);
   mainwindow.statusbar1.panels[0].text:=position_to_string('   ',raM,decM);

   hfd2:=999;
   HFD(img_loaded,round(mouse_fitsX-1),round(mouse_fitsY-1),annulus_radius {annulus radius},flux_aperture,hfd2,fwhm_star2,snr,flux,object_xc,object_yc);{input coordinates in array[0..] output coordinates in array [0..]}
   //mainwindow.caption:=floattostr(mouse_fitsX)+',   '+floattostr(mouse_fitsy)+',         '+floattostr(object_xc)+',   '+floattostr(object_yc);
   if ((hfd2<99) and (hfd2>0)) then
   begin
     if ((hfd_arcseconds) and (head.cd1_1<>0)) then conv_factor:=abs(head.cdelt2)*3600{arc seconds} else conv_factor:=1;{pixels}
     if hfd2*conv_factor>1 then str(hfd2*conv_factor:0:1,hfd_str) else str(hfd2*conv_factor:0:2,hfd_str);
     str(fwhm_star2*conv_factor:0:1,fwhm_str);
     if ((hfd_arcseconds) and (head.cd1_1<>0)) then begin hfd_str:=hfd_str+'"';fwhm_str:=fwhm_str+'"';end;

     str(snr:0:0,snr_str);
     if flux_magn_offset<>0 then {offset calculated in star annotation call}
     begin
        str(flux_magn_offset-ln(flux)*2.511886432/ln(10):0:2,mag_str);
        mag_str:=', MAGN='+mag_str;
     end
     else mag_str:='';

     {centered coordinates}
     sensor_coordinates_to_celestial(object_xc+1,object_yc+1,object_raM,object_decM);{input in FITS coordinates}
     if ((object_raM<>0) and (object_decM<>0)) then
       mainwindow.statusbar1.panels[1].text:=prepare_ra8(object_raM,': ')+'   '+prepare_dec2(object_decM,'° '){object position in RA,DEC}
     else
       mainwindow.statusbar1.panels[1].text:=floattostrF(object_xc+1,ffFixed,7,2)+',  '+floattostrF(object_yc+1,ffFixed,7,2);{object position in FITS X,Y}
     mainwindow.statusbar1.panels[2].text:='HFD='+hfd_str+', FWHM='+FWHM_str+', SNR='+snr_str+mag_str{+' '+floattostr4(flux)};
   end
   else
   begin
     object_xc:=-999999;{indicate object_raM is unlocked}
     object_raM:=raM; {use mouse position instead}
     object_decM:=decM; {use mouse position instead}
     mainwindow.statusbar1.panels[1].text:='';

     local_sd(round(mouse_fitsX-1)-10,round(mouse_fitsY-1)-10, round(mouse_fitsX-1)+10,round(mouse_fitsY-1)+10{regio of interest},0 {col},img_loaded, sd,dummy {mean},iterations);{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}
     mainwindow.statusbar1.panels[2].text:='σ = '+ floattostrf( sd,ffFixed{ ffgeneral}, 4, 1);
   end;
end;


procedure Tmainwindow.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
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

  down_xy_valid := False;
  screen.Cursor := crDefault;
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
begin
  savefits_update_header(filename2);
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


function stretch_img(img: image_array):image_array;{stretch image, three colour or mono}
var
 colrr,colgg,colbb,col_r,col_g,col_b, largest,luminance,luminance_stretched,factor,sat_factor,h,s,v : single;
 width5,height5,colours5,fitsX,fitsY :integer;
begin
  colours5:=length(img);{nr colours}
  width5:=length(img[0]);{width}
  height5:=length(img[0,0]);{length}


  setlength(result,colours5,width5,height5);
  sat_factor:=1-mainwindow.saturation_factor_plot1.position/10;

  for fitsY:=0 to height5-1 do
    for fitsX:=0 to width5-1 do
    begin
      if colours5=3 then
      begin
        col_r:=img[0,fitsx,fitsy];
        col_g:=img[1,fitsx,fitsy];
        col_b:=img[2,fitsx,fitsy];

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
        col_r:=img[0,fitsx,fitsy];
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


function save_PPM_PGM_PFM(img: image_array; colourdepth:integer; filen2:ansistring;flip_H,flip_V:boolean): boolean;{save to 16 bit portable pixmap/graymap file (PPM/PGM) or 32 bit PFM file}
var
  ppmbuffer32: array[0..trunc(bufwide/4)] of Dword; {bufwide is set in astap_main and is 120000}
  ppmbuffer: array[0..bufwide] of byte absolute ppmbuffer32;

  header: array[0..26] of ansichar;
  thefile : tfilestream;
  i,j,k,m,width2,height2 : integer;
  dum: double;
  dummy : word;

  value1   : single;
  lw       : longword absolute value1;
begin
  result:=false;

//  colours5:=length(img);{nr colours}
  width2:=length(img[0]);{width}
  height2:=length(img[0,0]);{length}


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
      for j:=0 to width2-1 do
      begin
        if flip_H=true then m:=width2-1-j else m:=j;
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
      thefile.writebuffer(ppmbuffer,width2*6 {2 or 2*3}) ;{works only for byte arrays}
    end;
  end
  else
  if colourdepth=16 then
  begin  {mono/gray}
    for i:=0 to Height2-1 do
    begin
      if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
      for j:=0 to width2-1 do
      begin
        if flip_H=true then m:=width2-1-j else m:=j;
        dum:=img[0,m,k]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
        ppmbuffer[m*2  ]  :=hi(dummy);
        ppmbuffer[m*2+1]  :=lo(dummy);
      end;
      thefile.writebuffer(ppmbuffer,width2*2 {}) ;{works only for byte arrays}
    end;
  end;
  if colourdepth=96 then {PFM 32 bit float colour files, little endian}
   begin
     for i:=0 to Height2-1 do
     begin
       if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
       for j:=0 to width2-1 do
       begin
         if flip_H=true then m:=width2-1-j else m:=j;
         value1:=img[0,m,k]/65535;
         ppmbuffer32[m*3]:=lw;
         value1:=img[1,m,k]/65535;
         ppmbuffer32[m*3+1]:=lw;
         value1:=img[2,m,k]/65535;
         ppmbuffer32[m*3+2]:=lw;
       end;
       thefile.writebuffer(ppmbuffer,width2*4*3{}) ;{works only for byte arrays}
     end;
   end
   else
   if colourdepth=32 then  {PFM 32 bit float gray scale file, little endian}
   begin  {mono/gray}
     for i:=0 to Height2-1 do
     begin
       if flip_V=false then k:=height2-1-i else k:=i;{reverse fits down to counting}
       for j:=0 to width2-1 do
       begin
         if flip_H=true then m:=width2-1-j else m:=j;

         value1:=img[0,m,k]/65535;
         ppmbuffer32[m]:=lw;
       end;
       thefile.writebuffer(ppmbuffer,width2*4 {}) ;{works only for byte arrays}
     end;
   end;

  thefile.free;
  result:=true;
end;

function save_PNG16(img: image_array; filen2:string;flip_H,flip_V:boolean): boolean;{save to PNG file }
var
  i, j, k,m,colours5,width5,height5      :integer;
  image: TFPCustomImage;
  writer: TFPCustomImageWriter;
  thecolor  :Tfpcolor;
begin
  colours5:=length(img);{nr colours}
  width5:=length(img[0]);{width}
  height5:=length(img[0,0]);{length}


  Image := TFPMemoryImage.Create(width5, height5);
  Writer := TFPWriterPNG.Create;

  with TFPWriterPNG(Writer) do
  begin
    indexed := false;
    wordsized := true;
    UseAlpha := false;
    GrayScale := (colours5=1);
  end;
  For i:=0 to height5-1 do
  begin
    if flip_V=false then k:=height5-1-i else k:=i;{reverse fits down to counting}
    for j:=0 to width5-1 do
    begin
      if flip_H=true then m:=width5-1-j else m:=j;
      thecolor.red:=min(round(img[0,m,k]), $FFFF);
      if colours5>1 then thecolor.green:=min(round(img[1,m,k]), $FFFF)  else thecolor.green:=thecolor.red;
      if colours5>2 then thecolor.blue:=min(round(img[2,m,k]), $FFFF)   else thecolor.blue:=thecolor.red;
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

//function save_PNM16(img: image_array; colors,wide2,head.height:integer; filen2:string;flip_H,flip_V:boolean): boolean;{save to PNM file }
//var
//  i, j, k,m      :integer;
//  image: TFPCustomImage;
//  writer: TFPCustomImageWriter;
//  thecolor  :Tfpcolor;
//begin
//  Image := TFPMemoryImage.Create(head.width, head.height);
//  Writer := TFPWriterPNM.Create;

//  with TFPWriterPNM(Writer) do
//  begin
//    FullWidth:=true;{16 bit}
//  end;
//  For i:=0 to head.height-1 do
//  begin
//    if flip_V=false then k:=head.height-1-i else k:=i;{reverse fits down to counting}
//    for j:=0 to head.width-1 do
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


function save_tiff16(img: image_array; filen2:string;flip_H,flip_V:boolean): boolean;{save to 48=3x16 color TIFF file }
var
  i, j, k,m,colours5,width5,height5      :integer;
  image: TFPCustomImage;
  writer: TFPCustomImageWriter;
  thecolor  :Tfpcolor;
begin
  colours5:=length(img);{nr colours}
  width5:=length(img[0]);{width}
  height5:=length(img[0,0]);{length}

  Image := TFPMemoryImage.Create(width5, height5);
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
  if colours5=1 then
  begin
    Image.Extra[TiffGrayBits]:='16';   {add unit fptiffcmn to make this work. see https://bugs.freepascal.org/view.php?id=35081}
    Image.Extra[TiffPhotoMetric]:='0'; {This is the same as Image.Extra['TiffPhotoMetricInterpretation']:='0';}
  end;

  image.Extra[TiffSoftware]:='ASTAP';
  image.Extra[TiffImageDescription]:=mainwindow.memo1.text; {store full header in TIFF !!!}
  Image.Extra[TiffCompression]:= '5'; // compression LZW

  For i:=0 to height5-1 do
  begin
    if flip_V=false then k:=height5-1-i else k:=i;{reverse fits down to counting}
    for j:=0 to width5-1 do
    begin
      if flip_H=true then m:=width5-1-j else m:=j;
      thecolor.red:=min(round(img[0,m,k]), $FFFF);
      if colours5>1 then thecolor.green:=min(round(img[1,m,k]), $FFFF)  else thecolor.green:=thecolor.red;
      if colours5>2 then thecolor.blue:=min(round(img[2,m,k]), $FFFF)   else thecolor.blue:=thecolor.red;
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
                                                '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                         '|RAW files|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                         '|PNG, JPEG, BMP(*.png, *.jpg,*.bmp)|*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP'+
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
        progress_indicator(100*i/(count),' Converting');{show progress}
        Application.ProcessMessages;
        if esc_pressed then begin Screen.Cursor := Save_Cursor;  exit;end;
        filename2:=Strings[I];
        mainwindow.caption:=filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count);;
        if load_image(false {recenter},false {plot}) then
        begin
          filename2:=ChangeFileExt(filename2,'.tif');
          if abs(nrbits)<=16 then
          begin
            save_tiff16(img_loaded,filename2,false {flip H},false {flip V});
          end
          else
          begin {32 bit files}
            if head.naxis3<>1 then {color}
              save_tiff_96(img_loaded,filename2,false {flip H},false {flip V}) {old uncompressed routine in unit_tiff}
            else
             save_tiff_32(img_loaded,filenamE2,false {flip H},false {flip V});{old uncompressed routine in unit_tiff}
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
      progress_indicator(-100,'');{progresss done}
    end;
  end;
end;


procedure Tmainwindow.convert_to_ppm1Click(Sender: TObject);
var
  I: integer;
  Save_Cursor:TCursor;
  err   : boolean;
  dobackup : boolean;
begin
  OpenDialog1.Title := 'Select multiple  files to convert';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=  'All formats except PPM |*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP;*.tif;*.tiff;*.TIF;*.xisf;*.fz;'+
                                       '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                         '|FITS files (*.fit*,*.xisf)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.new;*.xisf;*.fz'+
                         '|RAW files|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                         '|PNG, TIFF, JPEG, BMP(*.png,*.tif*, *.jpg,*.bmp)|*.png;*.PNG;*.tif;*.tiff;*.TIF;*.jpg;*.JPG;*.bmp;*.BMP'+
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
        progress_indicator(100*i/(count),' Converting');{show progress}
        Application.ProcessMessages;
        if esc_pressed then begin Screen.Cursor := Save_Cursor;  exit;end;
        filename2:=Strings[I];
        mainwindow.caption:=filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count);;
        if load_image(false {recenter},false {plot}) then
        begin
          if head.naxis3=1 then {monochrome}
          begin
            if abs(nrbits)<=16 then
            begin
              filename2:=ChangeFileExt(filename2,'.pgm');
              save_PPM_PGM_PFM(img_loaded,16 {colour depth},filename2,false {flip H},false {flip V});
            end
            else
            begin
              filename2:=ChangeFileExt(filename2,'.pfm');
              save_PPM_PGM_PFM(img_loaded,32 {colour depth},filename2,false,false);
            end;
          end
          else
          begin {colour}
            if abs(nrbits)<=16 then
            begin
              filename2:=ChangeFileExt(filename2,'.ppm');
              save_PPM_PGM_PFM(img_loaded,48 {colour depth},filename2,false,false);
            end
            else
            begin
              filename2:=ChangeFileExt(filename2,'.pfm');
              save_PPM_PGM_PFM(img_loaded,96 {colour depth},filename2,false,false);
            end;

          end;{colour}
        end
        else err:=true;
      end;
      if err=false then mainwindow.caption:='Completed, all files converted.'
      else
      mainwindow.caption:='Finished, files converted but with errors!';

      finally
      if dobackup then restore_img;{for the viewer}
      Screen.Cursor := Save_Cursor;  { Always restore to normal }
      progress_indicator(-100,'');{progresss done}

    end;
  end;
end;

procedure Tmainwindow.flip_H1Click(Sender: TObject);
var
  col,fitsX,fitsY : integer;
  vertical             :boolean;
  Save_Cursor:TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  backup_img;

  vertical:= (sender=flip_V1);

  setlength(img_temp,head.naxis3, head.width,head.height);

  for col:=0 to head.naxis3-1 do {do all colours}
  begin
    For fitsY:=0 to (head.height-1) do
      for fitsX:=0 to (head.width-1) do
      begin
        if vertical then img_temp[col, fitsX,(head.height-1)-fitsY]:=img_loaded[col,fitsX,fitsY]
        else
        img_temp[col,(head.width-1)-fitsX,fitsY]:=img_loaded[col,fitsX,fitsY];
      end;
  end;

  img_loaded:=nil;
  img_loaded:=img_temp;

  if head.cd1_1<>0 then {update solution for rotation}
  begin
    if vertical then {rotate right}
    begin
      head.cd1_2:=-head.cd1_2;
      head.cd2_2:=-head.cd2_2;
    end
    else
    begin {rotate horizontal}
      head.cd1_1:=-head.cd1_1;
      head.cd2_1:=-head.cd2_1;
    end;
    new_to_old_WCS;{convert new style FITS to old style, calculate crota1,crota2,cdelt1,cdelt2}

    update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_1);
    update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_2);
    update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_1);
    update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_2);

    update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,head.cdelt1);
    update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,head.cdelt2);

    update_float  ('CROTA1  =',' / Image twist of X axis        (deg)             ' ,head.crota1);
    update_float  ('CROTA2  =',' / Image twist of Y axis        (deg)             ' ,head.crota2);

    remove_key('ROWORDER',false{all});{just remove to be sure no debayer confusion}
    add_text     ('HISTORY   ','Flipped.                                                           ');
  end;
  plot_fits(mainwindow.image1,false,true);

  Screen.Cursor := Save_Cursor;  { Always restore to normal }
end;



procedure Tmainwindow.MenuItem22Click(Sender: TObject);
begin
  form_inspection1.aberration_inspector1Click(nil);
end;


procedure Tmainwindow.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  esc_pressed:=true;{stop processing. Required for reliable stopping by APT}
  save_settings2;
end;


procedure Tmainwindow.Export_image1Click(Sender: TObject);
var
  filename3:ansistring;
  OldCursor : TCursor;
begin
  filename3:=ChangeFileExt(FileName2,'');
  savedialog1.filename:=filename3;
  savedialog1.initialdir:=ExtractFilePath(filename3);

  if head.naxis3>1 then savedialog1.Filter := 'PNG 16 bit stretched|*.png|PNG 16 bit|*.png|TIFF 16 bit stretched|*.tif|TIFF 16 bit|*.tif|TIFF 32 bit|*.tif|PPM 16 bit stretched|*.ppm;|PPM 16 bit|*.ppm|PFM 32 bit float|*.pfm'
                   else savedialog1.Filter := 'PNG 16 bit stretched|*.png|PNG 16 bit|*.png|TIFF 16 bit stretched|*.tif|TIFF 16 bit|*.tif|TIFF 32 bit|*.tif|PGM 16 bit stretched|*.pgm;|PGM 16 bit|*.pgm|PFM 32 bit float|*.pfm';
  savedialog1.filterindex:=SaveasTIFF1filterindex; {default 1}
  if savedialog1.execute then
  begin
    OldCursor := Screen.Cursor;
    Screen.Cursor:= crHourGlass;

    if head.naxis3>1 then {color}
    begin
      if savedialog1.filterindex=1 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_png16(img_temp,ChangeFileExt(savedialog1.filename,'.png'),flip_horizontal1.checked,flip_vertical1.checked);  {Change extension is only required due to bug in macOS only. 2021-10-9 See https://gitlab.com/freepascal.org/lazarus/lazarus/-/issues/39423}
      end
      else
      if savedialog1.filterindex=2 then
        save_png16(img_loaded,ChangeFileExt(savedialog1.filename,'.png'),flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=3 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_tiff16(img_temp,ChangeFileExt(savedialog1.filename,'.tif'),flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=4 then
        save_tiff16(img_loaded,ChangeFileExt(savedialog1.filename,'.tif'),flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=5 then
      save_tiff_96(img_loaded,ChangeFileExt(savedialog1.filename,'.tif'),flip_horizontal1.checked,flip_vertical1.checked) {old uncompressed routine in unit_tiff}
      else
      if savedialog1.filterindex=6 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_PPM_PGM_PFM(img_temp,48 {colour depth},ChangeFileExt(savedialog1.filename,'.ppm'),flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=7 then
          save_PPM_PGM_PFM(img_loaded,48 {colour depth},ChangeFileExt(savedialog1.filename,'.ppm'),flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=8 then
          save_PPM_PGM_PFM(img_loaded,96 {colour depth},ChangeFileExt(savedialog1.filename,'.pfm'),flip_horizontal1.checked,flip_vertical1.checked);
    end {color}
    else
    begin {gray}
      if savedialog1.filterindex=1 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_png16(img_temp,ChangeFileExt(savedialog1.filename,'.png'),flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=2 then
        save_png16(img_loaded,ChangeFileExt(savedialog1.filename,'.png'),flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=3 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_tiff16(img_temp,ChangeFileExt(savedialog1.filename,'.tif'),flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=4 then
      save_tiff16(img_loaded,ChangeFileExt(savedialog1.filename,'.tif'),flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=5 then
        save_tiff_32(img_loaded,ChangeFileExt(savedialog1.filename,'.tif'),flip_horizontal1.checked,flip_vertical1.checked){old uncompressed routine in unit_tiff}
      else
      if savedialog1.filterindex=6 then
      begin
        img_temp:=stretch_img(img_loaded);
        save_PPM_PGM_PFM(img_temp,16{colour depth}, ChangeFileExt(savedialog1.filename,'.pgm'), flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=7 then
          save_PPM_PGM_PFM(img_loaded,16{colour depth},ChangeFileExt(savedialog1.filename,'.pgm'),flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=8 then
          save_PPM_PGM_PFM(img_loaded,32 {colour depth},ChangeFileExt(savedialog1.filename,'.pfm'),flip_horizontal1.checked,flip_vertical1.checked);

    end;

    SaveasTIFF1filterindex:=savedialog1.filterindex;{remember}
    Screen.Cursor:= OldCursor;
  end;
end;


function number_of_fields(const C: char; const S: string ): integer; {count number of fields in string with C as separator}
var
  i: Integer;
begin
  result := 0;
  for i := 1 to Length(S) do
    if S[i] = C then
      inc(result);

  if copy(s,length(s),1)<>c then inc(result,1);
end;


function retrieve_memo3_string(x,y :integer;default:string):string; {retrieve string at position x,y. Strings are separated by #9}
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


function save_fits(img: image_array;filen2:ansistring;type1:integer;override2:boolean): boolean;{save to 8, 16 OR -32 BIT fits file}
var
  TheFile4 : tfilestream;
  I,j,k,bzero2, progressC,progress_value,dum, remain,minimum,maximum,dimensions, colours5,height5,width5 : integer;
  dd : single;
  line0                : ansistring;
  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}
  OldCursor : TCursor;
  //wo: word;
  //int_16             : smallint absolute wo;{for 16 signed integer}
  rgb  : byteX3;{array [0..2] containing r,g,b colours}
begin
  result:=false;

  {get dimensions directly from array}
  colours5:=length(img);{nr colours}
  width5:=length(img[0]);{width}
  height5:=length(img[0,0]);{length}
  if colours5=1 then dimensions:=2 else dimensions:=3; {number of dimensions or colours}

  if ((type1=24) and (colours5<3)) then
  begin
    application.messagebox(pchar('Abort, can not save grayscale image as colour image!!'),pchar('Error'),MB_OK);
    exit;
  end;

  if  override2=false then
  begin
    if ((fileexists(filen2)) and (pos('ImageToSolve.fit',filen2)=0)) then
      if MessageDlg('ASTAP: Existing file ' +filen2+ ' Overwrite?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then  Exit;

    if extend_type=1 then {image extensions in the file. 1=image extension, 2=ascii table extension, 3=bintable extension}
    begin
      if MessageDlg('Only the current image of the multi-extension FITS will be saved. Displayed table will not be preserved. Continue?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
        exit;
      mainwindow.Memo1.Lines[0]:= head1[0]; {replace XTENSION= with SIMPLE = }
    end;
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
  if type1<>24 then {standard FITS}
  begin
    update_integer('BITPIX  =',' / Bits per entry                                 ' ,type1); {16 or -32}
    update_integer('NAXIS   =',' / Number of dimensions                           ' ,dimensions);{number of dimensions, 2 for mono, 3 for colour}
    update_integer('NAXIS1  =',' / length of x axis                               ' ,width5);
    update_integer('NAXIS2  =',' / length of y axis                               ' ,height5);
    if colours5<>1 then {color image}
      update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,colours5)
      else
      remove_key('NAXIS3  ',false{all});{remove key word in header. Some program don't like naxis3=1}

    if type1=16 then bzero2:=32768 else bzero2:=0;

    update_integer('BZERO   =',' / physical_value = BZERO + BSCALE * array_value  ' ,bzero2);
    update_integer('BSCALE  =',' / physical_value = BZERO + BSCALE * array_value  ' ,1);{data is scaled to physical value in the load_fits routine}
    if type1<>8 then
    begin
      update_integer('DATAMIN =',' / Minimum data value                             ' ,round(head.datamin_org));
      update_integer('DATAMAX =',' / Maximum data value                             ' ,round(head.datamax_org));
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
    update_integer('BZERO   =',' / physical_value = BZERO + BSCALE * array_value  ' ,0);
    update_integer('BSCALE  =',' / physical_value = BZERO + BSCALE * array_value  ' ,1);{data is scaled to physical value in the load_fits routine}
    {update existing header}
  end;

  {write memo1 header to file}
  for i:=0 to 79 do empthy_line[i]:=#32;{space}
  i:=0;
  repeat
     if i<mainwindow.memo1.lines.count then
     begin
       line0:=mainwindow.memo1.lines[i];{line0 is an ansistring. According the standard the FITS header should only contain ASCII charactors between decimal 32 and 126. However ASTAP can write UTF8 in the comments which is read correctly by DS9 and FV}
       while length(line0)<80 do line0:=line0+' ';{extend to length 80 if required}
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
    for k:=0 to colours5-1 do {do all colors}
    for i:=0 to height5-1 do
    begin
      inc(progressC);
      progress_value:=round(progressC*100/(colours5*height5));{progress in %}
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
      progress_value:=round(progressC*100/(colours5*height5));{progress in %}
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
    for k:=0 to colours5-1 do {do all colors}
    for i:=0 to height5-1 do
    begin

      inc(progressC);
      progress_value:=round(progressC*100/(colours5*height5));{progress in %}
      {$IFDEF fpc}
      if frac(progress_value/5)=0 then progress_indicator(progress_value,'');{report increase insteps of 5%}
      {$else} {delphi}
      if frac(progress_value/5)=0 mainwindow.taskbar1.progressvalue:=progress_value;
      {$endif}

      for j:=0 to width5-1 do
      begin
        dum:=max(0,min(65535,round(img[k,j,i]))) - bzero2;{limit data between 0 and 65535 and shift it to -32768.. 32767}
        { value  - bzero              result  shortint    word
         ($0000  - $8000) and $FFFF = $8000 (-32768       32768 )  note  $0000 - $8000 ==>  $FFFF8000. Highest bits are skipped
         ($0001  - $8000) and $FFFF = $8001 (-32767       32769 )  note  $0001 - $8000 ==>  $FFFF8001. Highest bits are skipped
         ($2000  - $8000) and $FFFF = $A000 (-24576       40960 )
         ($7FFF  - $8000) and $FFFF = $FFFF (    -1       65535 )
         ($8000  - $8000) and $FFFF = $0000 (     0           0 )
         ($8001  - $8000) and $FFFF = $0001 (     1           1 )
         ($A000  - $8000) and $FFFF = $2000 (  8192        8192 )  note $A000 - $8000 equals  $2000.
         ($FFFE  - $8000) and $FFFF = $7FFE (+32766       32766 )
         ($FFFF  - $8000) and $FFFF = $7FFF (+32767       32767 )
        }
        fitsbuffer2[j]:=swap(word(dum));{in FITS file hi en low bytes are swapped}
      end;
      thefile4.writebuffer(fitsbuffer2,width5+width5); {write as bytes}
    end;
  end
  else
  if type1=-32 then
  begin
    for k:=0 to colours5-1 do {do all colors}
    for i:=0 to height5-1 do
    begin
      inc(progressC);
      progress_value:=round(progressC*100/(colours5*height5));{progress in %}
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
  remain:=round(2880*(1-frac(thefile4.position/2880)));{follow standard and only write in a multi of 2880 bytes}
  if ((remain<>0) and (remain<>2880)) then
  begin
    FillChar(fitsbuffer, remain, 0);
    thefile4.writebuffer(fitsbuffer,remain);{write some bytes}
  end;

//  if extend_type>=3 then {write bintable extension}
//  begin
//    rows:=number_of_fields(#9,mainwindow.memo3.lines[3]); {first lines could be blank or incomplete}
//    tal:=mainwindow.memo3.lines[0];
//    i:=0;
//    strplcopy(aline,'XTENSION= '+#39+'BINTABLE'+#39+' / FITS Binary Table Extension                              ',80);{copy 80 and not more or less in position aline[80] should be #0 from string}
//    thefile4.writebuffer(aline,80); inc(i);
//    strplcopy(aline,  'BITPIX  =                    8 / 8-bits character format                                  ',80);
//    thefile4.writebuffer(aline,80);inc(i);
//    strplcopy(aline,  'NAXIS   =                    2 / Tables are 2-D char. array                               ',80);
//    thefile4.writebuffer(aline,80);inc(i);
//    str(rows*4:13,tal); {write only 4 byte floats}
//    strplcopy(        aline,'NAXIS1  =        '+tal+' / Bytes in row                                             ',80);
//    thefile4.writebuffer(aline,80);inc(i);

//    str(mainwindow.memo3.lines.count-1-1 :13,tal);
//    strplcopy(aline,      'NAXIS2  =        '+tal  +' /                                                          ',80);
//    thefile4.writebuffer(aline,80);inc(i);

//    strplcopy(  aline,'PCOUNT  =                    0 / Parameter count always 0                                 ',80);
//    thefile4.writebuffer(aline,80);inc(i);

//    strplcopy(aline,  'GCOUNT  =                    1 / Group count always 1                                     ',80);
//    thefile4.writebuffer(aline,80);inc(i);

//    str(rows  :3,tal);
//    strplcopy(aline,'TFIELDS =                  '+tal+            ' / No. of col in table                                      ',80);
//    thefile4.writebuffer(aline,80);inc(i);

//    for k:=1 to rows do
//    begin
//      str(k:0,tal); tal:=copy(tal+'  ',1,3);
//      strplcopy(aline,'TFORM'+tal+'= '+#39+'E       '+#39+'           / Format of field                                          ',80);
//      thefile4.writebuffer(aline,80);inc(i);

//      lab:=retrieve_memo3_string(k-1,0,'col'+inttostr(k)); {retrieve type from memo3}
//      strplcopy(aline,'TTYPE'+tal+'= '+#39+lab+#39+' / Field label                                                                                                        ',80);
//      thefile4.writebuffer(aline,80);inc(i);

//      lab:=retrieve_memo3_string(k-1,1,'unit'+inttostr(k)); {retrieve unit from memo3}
//      strplcopy(aline,'TUNIT'+tal+'= '+#39+lab+#39+' / Physical unit of field                                                                                             ',80);
//      thefile4.writebuffer(aline,80);inc(i);
//    end;

//    strplcopy(  aline,'ORIGIN  = '    +#39+'ASTAP   '+#39+'           / Written by ASTAP                                         ',80);
//    thefile4.writebuffer(aline,80);inc(i);
//    strpcopy(aline,'END                                                                             ');
//    thefile4.writebuffer(aline,80);inc(i);

//    while  frac(i*80/2880)>0 do
//    begin
//      thefile4.writebuffer(empthy_line,80);{write empthy line}
//      inc(i);
//    end;

//    {write datablock}
//    i:=0;
//    for r:=2 to mainwindow.memo3.lines.count-1 do {rows}
//    begin
//       for j:=0 to rows-1 do {columns}
//      begin
//         tal:=retrieve_memo3_string(j {x},r {y},'0'); {retrieve string value from memo3 at position k,m}
//         fitsbuffer4[j]:=INT_IEEE4_reverse(strtofloat2(tal));{adapt intel floating point to non-intel floating. Add 1 to get FITS coordinates}
//       end;
//       thefile4.writebuffer(fitsbuffer[0],rows*4);{write one row}
//       i:=i+rows*4; {byte counter}
//    end;

//    j:=80-round(80*frac(i/80));{remainder in bytes till written muliple of 80 char}
//    thefile4.writebuffer(empthy_line,j);{write till multiply of 80}
//    i:=(i + j*80) div 80 ;{how many 80 bytes record left till multiple of 2880}

//    while  frac(i*80/2880)>0 do {write till 2880 block is written}
//    begin
//      thefile4.writebuffer(empthy_line,80);{write empthy line}
//      inc(i);
//    end;
//  end;

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
  listviews_begin_update; {speed up making stackmenu visible having a many items}

  stackmenu1.visible:=true;
  stackmenu1.setfocus;

  listviews_end_update;{speed up making stackmenu visible having a many items}
end;


procedure Tmainwindow.Undo1Click(Sender: TObject);
begin
  restore_img;
end;


procedure Tmainwindow.Saveasfits1Click(Sender: TObject);
begin
  if extend_type>0 then {multi extension file}
   savedialog1.filename:=ChangeFileExt(FileName2,'.fits')+'_extract'+inttostr(mainwindow.updown1.position)+'.fits' {give it a new name}
  else
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


procedure Tmainwindow.minimum1Change(Sender: TObject);
begin
  min2.text:=inttostr(minimum1.position);
  shape_histogram1.left:=round(histogram1.left+0.5+(histogram1.width-1) * minimum1.position/minimum1.max);
end;


procedure Tmainwindow.maximum1Change(Sender: TObject);
begin
  max2.text:=inttostr(maximum1.position);
  shape_histogram1.left:=round(histogram1.left+0.5+(histogram1.width-1) * maximum1.position/maximum1.max);
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

  head.height:=100;
  head.width:=100;
//  head.naxis:=2; {numer of dimensions}
//  head.naxis3:=3;{number of colors}
  head.crpix1:=0;{reference pixel}
  head.crpix2:=0;
  head.cdelt1:=0;{deg/pixel for x}
  head.cdelt2:=0;
  head.ra0 :=0;
  head.dec0:=0; {plate center values}

 {$ifdef CPUARM}
  size_backup:= 0; {0, one backup images for ctrl-z}
  index_backup:=size_backup;
  {$else}
  size_backup:=2; {0,1,2 three backup images for ctrl-z}
  index_backup:=size_backup;
  {$endif}
end.
