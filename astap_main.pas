unit astap_main;
{Copyright (C) 2017, 2024 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }


{Notes on MacOS pkg making:
   1) Modify app in applications via "show contents", add updated files.
   2) Add the app in program packages
   3) Build package. Will produce PKG file containing the app.

   Compiler settings for macOS:
   targetOS: Darwin
   CPU family X86_64
   LCL widegetset: cocoa
}

{open compiler issues:

https://forum.lazarus.freepascal.org/index.php/topic,63511.0.html

MacOS
Listview smallimages are not displayed.
https://gitlab.com/freepascal.org/lazarus/lazarus/-/issues/39193

MacOS
ScrollCode=scEndScroll does not appears at the end of scroll
https://gitlab.com/freepascal.org/lazarus/lazarus/-/issues/37454

Mac
Listview event OnCustomDrawItem is never triggered/fired in Mac, widget Cocoa
https://gitlab.com/freepascal.org/lazarus/lazarus/-/issues/39500
https://gitlab.com/freepascal.org/lazarus/lazarus/-/issues/40065
}

interface
uses
 {$ifdef mswindows}
  Windows,
  Classes, Controls, Dialogs,StdCtrls, ExtCtrls, ComCtrls, Menus,
  windirs,{for directories from Windows}
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
  LCLVersion, InterfaceBase, LCLPlatformDef,
  SysUtils, Graphics, Forms, strutils, math,
  clipbrd, {for copy to clipboard}
  Buttons, PopupNotifier, PairSplitter, simpleipc,
  CustApp, Types, fileutil,
  IniFiles;{for saving and loading settings}

const
  astap_version='2024.07.25';  //  astap_version := {$I %DATE%} + ' ' + {$I %TIME%});

type
  { Tmainwindow }
  Tmainwindow = class(TForm)
    add_marker_position1: TMenuItem;
    bin3x3: TMenuItem;
    sigma_button1: TBitBtn;
    boxshape1: TShape;
    data_range_groupBox1: TGroupBox;
    dec1: TEdit;
    dec_label: TLabel;
    error_label1: TLabel;
    flip_indication1: TLabel;
    FontDialog1: TFontDialog;
    histogram1: TImage;
    Image1: TImage;
    image_north_arrow1: TImage;
    inversemousewheel1: TCheckBox;
    Label1: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    LabelCheck1: TLabel;
    LabelThree1: TLabel;
    LabelVar1: TLabel;
    max2: TEdit;
    maximum1: TScrollBar;
    Memo1: TMemo;
    Memo3: TMemo;
    menucopy2: TMenuItem;
    Menufind2: TMenuItem;
    menufindnext2: TMenuItem;
    MenuItem1: TMenuItem;
    bin2x2: TMenuItem;
    image_cleanup1: TMenuItem;
    localgaussian1: TMenuItem;
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
    grid_ra_dec1: TMenuItem;
    freetext1: TMenuItem;
    MenuItem21: TMenuItem;
    localcoloursmooth2: TMenuItem;
    fittowindow1: TMenuItem;
    flipVH1: TMenuItem;
    dust_spot_removal1: TMenuItem;
    export_star_info1: TMenuItem;
    grid_az_alt1: TMenuItem;
    az_alt1: TMenuItem;
    cal_batch1: TMenuItem;
    batch_add_tilt1: TMenuItem;
    mpcreport1: TMenuItem;
    min2: TEdit;
    minimum1: TScrollBar;
    PageControl1: TPageControl;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    Panel1: TPanel;
    Panel_top_menu1: TPanel;
    Polynomial1: TComboBox;
    ra1: TEdit;
    range1: TComboBox;
    ra_label: TLabel;
    rotation1: TLabel;
    saturation_factor_plot1: TTrackBar;
    save1: TButton;
    Separator3: TMenuItem;
    Shape_var1: TShape;
    shape_check1: TShape;
    shape_star3: TShape;
    shape_var2: TShape;
    shape_histogram1: TShape;
    shape_manual_alignment1: TShape;
    shape_marker1: TShape;
    shape_marker2: TShape;
    shape_marker3: TShape;
    shape_marker4: TShape;
    shape_paste1: TShape;
    shape_check2: TShape;
    solve_button1: TButton;
    SpeedButton1: TSpeedButton;
    star_profile1: TMenuItem;
    Separator2: TMenuItem;
    stretch1: TComboBox;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    UpDown1: TUpDown;
    vizier_gaia_annotation1: TMenuItem;
    simbad_annotation_deepsky_filtered1: TMenuItem;
    move_images1: TMenuItem;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    Separator1: TMenuItem;
    simbad_annotation_star1: TMenuItem;
    simbad_annotation_deepsky1: TMenuItem;
    online_query1: TMenuItem;
    bin_2x2menu1: TMenuItem;
    bin_3x3menu1: TMenuItem;
    imageinspection1: TMenuItem;
    inspector1: TMenuItem;
    MenuItem22: TMenuItem;
    flip_v1: TMenuItem;
    flip_H1: TMenuItem;
    maintain_date1: TMenuItem;
    batch_rotate_1801: TMenuItem;
    hyperleda_guery1: TMenuItem;
    ned_query1: TMenuItem;
    set_modified_date1: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    save_to_tiff2: TMenuItem;
    noise_in_electron1: TMenuItem;
    electron_to_adu_factors1: TMenuItem;
    MenuItem35: TMenuItem;
    rotate_arbitrary1: TMenuItem;
    roundness1: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem30: TMenuItem;
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
    N4: TMenuItem;
    MenuItem38: TMenuItem;
    simbad_query1: TMenuItem;
    positionanddate1: TMenuItem;
    removegreenpurple1: TMenuItem;
    zoomfactorone1: TMenuItem;
    extractred1: TMenuItem;
    extractblue1: TMenuItem;
    extractgreen1: TMenuItem;
    MenuItem24: TMenuItem;
    writepositionshort1: TMenuItem;
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
    Stretchdrawmenu1: TMenuItem;
    stretch_draw_fits1: TMenuItem;
    show_statistics1: TMenuItem;
    PopupMenu_histogram1: TPopupMenu;
    remove_atmouse1: TMenuItem;
    remove_longitude_latitude1: TMenuItem;
    menupaste1: TMenuItem;
    PopupMenu_memo2: TPopupMenu;
    select_all1: TMenuItem;
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
    submenurotate1: TMenuItem;
    MenuItem19: TMenuItem;
    solvebytwopositions1: TMenuItem;
    enterposition1: TMenuItem;
    save_settings_as1: TMenuItem;
    settings_menu1: TMenuItem;
    variable_star_annotation1: TMenuItem;
    clean_up1: TMenuItem;
    preview_demosaic1: TMenuItem;
    PopupNotifier1: TPopupNotifier;
    remove_colour1: TMenuItem;
    Returntodefaultsettings1: TMenuItem;
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
    convert_to_fits1: TMenuItem;
    convertmono1: TMenuItem;
    MenuItem6: TMenuItem;
    recent1: TMenuItem;
    recent2: TMenuItem;
    star_annotation1: TMenuItem;
    Remove_deep_sky_object1: TMenuItem;
    MenuItem4: TMenuItem;
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
    LoadFITSPNGBMPJPEG1: TMenuItem;
    SaveasJPGPNGBMP1: TMenuItem;
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
    N3: TMenuItem;
    StatusBar1: TStatusBar;

    procedure add_marker_position1Click(Sender: TObject);
    procedure annotate_with_measured_magnitudes1Click(Sender: TObject);
    procedure annotations_visible1Click(Sender: TObject);
    procedure autocorrectcolours1Click(Sender: TObject);
    procedure az_alt1Click(Sender: TObject);
    procedure batch_annotate1Click(Sender: TObject);
    procedure batch_solve_astrometry_netClick(Sender: TObject);
    procedure calibrate_photometry1Click(Sender: TObject);
    procedure Constellations1Click(Sender: TObject);
    procedure convert_to_ppm1Click(Sender: TObject);
    procedure export_star_info1Click(Sender: TObject);
    procedure flip_H1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure freetext1Click(Sender: TObject);
    procedure grid_az_alt1Click(Sender: TObject);
    procedure hfd_arcseconds1Click(Sender: TObject);
    procedure compress_fpack1Click(Sender: TObject);
    procedure copy_to_clipboard1Click(Sender: TObject);
    procedure extract_pixel_11Click(Sender: TObject);
    procedure extract_pixel_12Click(Sender: TObject);
    procedure extract_pixel_22Click(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure histogram_range1MouseUp(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
    procedure histogram_values_to_clipboard1Click(Sender: TObject);
    procedure Image1Paint(Sender: TObject);
    procedure annotate_unknown_stars1Click(Sender: TObject);
    procedure inspector1Click(Sender: TObject);
    procedure j2000d1Click(Sender: TObject);
    procedure measuretotalmagnitude1Click(Sender: TObject);
    procedure loadsettings1Click(Sender: TObject);
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
    procedure grid_ra_dec1Click(Sender: TObject);
    procedure bin_2x2menu1Click(Sender: TObject);
    procedure MenuItem22Click(Sender: TObject);
    procedure electron_to_adu_factors1Click(Sender: TObject);
    procedure localcoloursmooth2Click(Sender: TObject);
    procedure fittowindow1Click(Sender: TObject);
    procedure flipVH1Click(Sender: TObject);
    procedure dust_spot_removal1Click(Sender: TObject);
    procedure batch_add_tilt1Click(Sender: TObject);
    procedure mpcreport1Click(Sender: TObject);
    procedure simbad_annotation_deepsky_filtered1Click(Sender: TObject);
    procedure move_images1Click(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure set_modified_date1Click(Sender: TObject);
    procedure positionanddate1Click(Sender: TObject);
    procedure inspection1click(Sender: TObject);
    procedure removegreenpurple1Click(Sender: TObject);
    procedure roundness1Click(Sender: TObject);
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
    procedure convert_to_fits1click(Sender: TObject);
    procedure bin2x2Click(Sender: TObject);
    procedure max2EditingDone(Sender: TObject);
    procedure Memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure localgaussian1Click(Sender: TObject);
    procedure hyperleda_annotation1Click(Sender: TObject);
    procedure clean_up1Click(Sender: TObject);
    procedure remove_colour1Click(Sender: TObject);
    procedure Returntodefaultsettings1Click(Sender: TObject);
    procedure saturation_factor_plot1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure saturation_factor_plot1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure savesettings1Click(Sender: TObject);
    procedure Polynomial1Change(Sender: TObject);
    procedure remove_markers1Click(Sender: TObject);
    procedure Panel1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure Panel1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure show_statistics1Click(Sender: TObject);
    procedure SimpleIPCServer1MessageQueued(Sender: TObject);
    procedure StatusBar1MouseEnter(Sender: TObject);
    procedure stretch1Exit(Sender: TObject);
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
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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
    procedure stretch1CloseUp(Sender: TObject);
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
  image_array = array of array of array of Single;// note fasted processing is achieved if both access loop and memory storage are organised in rows. So as array[nrcolours,height,width]
  star_list   = array of array of double;

  Theader =record    {contains the most important header info}
    width  : integer;{image width}
    height : integer;{image height}
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
    xbinning      : double;//binning for noise calculations
    ybinning      : double;//binning for noise calculations
    xpixsz        : double;//Pixel Width in microns (after binning)
    ypixsz        : double;//Pixel height in microns (after binning)
    mzero         : double;//flux calibration factor for all flux
    mzero_radius    : double;//mzero diameter (aperture)
    pedestal        : double;//pedestal added during calibration or stacking
    set_temperature : integer;
    dark_count      : integer;
    light_count     : integer;
    flat_count      : integer;
    flatdark_count  : integer;
    egain      : string; {gain in e-/adu}
     gain      : string; {gain in 0.1dB or else}
    date_obs   : string;
    date_avg   : string;
    calstat    : string;
    filter_name: string;
    passband_database: string;
    airmass          : string;
    issues           : string;
  end;

type
   timgbackup  = record
     head_val: Theader;{most important header values}
     header  : string; {full header text}
     filen   : string; {filename}
     img     : image_array;
   end;

   Tbackground = record
                   backgr : double;//background value
                   star_level : double;//star level
                   star_level2: double;//star level
                   noise_level: double;///noise level background
                end;



  theauid = record
              auid: string;
              ra  : double;
              dec : double;
              Vmag: string;
              Verr: string;
              Bmag: string;
              Berr: string;
              Rmag: string;
              Rerr: string;
              SGmag: string;
              SGerr: string;
              SRmag: string;
              SRerr: string;
              SImag: string;
              SIerr: string;
            end;

  theVar = record
              name: string;
              ra  : double;
              dec : double;
              maxmag: string;
              minmag: string;
              period: string;
              epoch: string;
              category: string;
            end;


var
  vsp : array of theauid;//for comparison stars AUID
  vsx : array of thevar;//for variable stars AUID
  img_backup      : array of timgbackup;{dynamic so memory can be freed}
  img_loaded,img_dark,img_flat :  image_array;
  head,    {for lights}
  head_ref, {for reference light in stacking}
  head_flat,
  head_dark : Theader;{contains the most important header info}
  memox : tstrings;//work memo
  bck : Tbackground;

  settingstring : tstrings; {settings for save and loading}
  user_path    : string;{c:\users\name\appdata\local\astap   or ~/home/.config/astap}
  distortion_data : star_list;
  filename2: string;
  nrbits,size_backup,index_backup    : integer;{number of backup images for ctrl-z, numbered 0,1,2,3}
  ra_mount,dec_mount,{telescope ra,dec}
  equinox, bandpass,
  ra_radians,dec_radians, pixel_size     : double;

var
  a_order,ap_order: integer;{Simple Imaging Polynomial use by astrometry.net, if 2 then available}
  a_0_0,   a_0_1, a_0_2,  a_0_3,  a_1_0,  a_1_1,  a_1_2,  a_2_0,  a_2_1,  a_3_0 : double; {SIP, Simple Imaging Polynomial use by astrometry.net, Spitzer}
  b_0_0,   b_0_1, b_0_2,  b_0_3,  b_1_0,  b_1_1,  b_1_2,  b_2_0,  b_2_1,  b_3_0 : double; {SIP, Simple Imaging Polynomial use by astrometry.net, Spitzer}
  ap_0_0, ap_0_1,ap_0_2, ap_0_3, ap_1_0, ap_1_1, ap_1_2, ap_2_0, ap_2_1, ap_3_0 : double;{SIP, Simple Imaging Polynomial use by astrometry.net}
  bp_0_0, bp_0_1,bp_0_2, bp_0_3, bp_1_0, bp_1_1, bp_1_2, bp_2_0, bp_2_1, bp_3_0 : double;{SIP, Simple Imaging Polynomial use by astrometry.net}

  histogram : array[0..2,0..65535] of integer;{red,green,blue,count}
  his_total_red,extend_type,r_aperture : integer; {histogram number of values}
  his_mean             : array[0..2] of integer;
  stretch_c : array[0..32768] of single;{stretch curve}
  stretch_on, esc_pressed, fov_specified,unsaved_import, last_extension : boolean;
  {star_level,}star_bg,sd_bg, magn_limit  : double;
  object_name,
  imagetype ,sitelat, sitelong,siteelev , centalt,centaz,magn_limit_str: string;
  focus_temp,{cblack,}cwhite,sqmfloat,altitudefloat, pressure,airmass   :double; {from FITS}
  subsamp, focus_pos  : integer;{not always available. For normal DSS =1}
  telescop,instrum,origin,sqm_value   : string;

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
  image_move_to_center : boolean=false;
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
  application_path:string='';{to be set in main}
  database_path:string='';{to be set in main}
  bayerpat: string='';{bayer pattern}
  bayerpattern_final :integer=2; {ASI294, ASI071, most common pattern}
  sip               : boolean=false; {use SIP coefficients}

  xbayroff: double=0;{additional bayer pattern offset to apply}
  Ybayroff: double=0;{additional bayer pattern offset to apply}
  annotated : boolean=false;{any annotation in fits file?}
  sqm_key   :  ansistring='SQM     ';
  centaz_key   :  ansistring='CentAz  ';

  hfd_median : double=0;{median hfd, use in reporting in write_ini}
  hfd_counter: integer=0;{star counter (for hfd_median), use in reporting in write_ini}
  aperture_ratio: double=0; {ratio flux_aperture/hfd_median}
  annulus_radius  : integer=14;{inner of square where background is measured. Square has width and height twice annulus_radius}
  copy_paste :boolean=false;
  copy_paste_shape :integer=0;//rectangle

  shape_var1_fitsX: double=0;
  shape_var1_fitsY: double=0;
  shape_check1_fitsX: double=0;
  shape_check1_fitsY: double=0;
  shape_star3_fitsX: double=0;
  shape_star3_fitsY: double=0;
  shape_var1_ra : double=0;
  shape_var1_dec : double=0;
  shape_check1_ra : double=0;
  shape_check1_dec : double=0;
  shape_star3_ra : double=0;
  shape_star3_dec : double=0;


  shape_nr: integer=1;

  shape_marker1_fitsX: double=10;
  shape_marker1_fitsY: double=10;
  shape_marker2_fitsX: double=20;
  shape_marker2_fitsY: double=20;
  shape_marker3_fitsX: double=0;
  shape_marker3_fitsY: double=0;
  shape_marker4_fitsX: double=0;
  shape_marker4_fitsY: double=0;


  shape_var2_fitsX: double=0;
  shape_var2_fitsY: double=0;
  shape_check2_fitsX: double=0;
  shape_check2_fitsY: double=0;
  shape_var2_ra : double=0;
  shape_var2_dec : double=0;
  shape_check2_ra : double=0;
  shape_check2_dec : double=0;


  commandline_execution : boolean=false;{program executed in command line}
  commandline_log       : boolean=false;{file log request in command line}
  errorlevel        : integer=0;{report errors when shutdown}

  mouse_positionRADEC1 : string='';{For manual reference solving}
  mouse_positionRADEC2 : string='';{For manual reference solving}
  flipped_img          : string='';
  maintype               : string='';
  bayer_pattern : array[0..4] of string=('GRBG',
                                         'BGGR',
                                         'RGGB',
                                         'GBRG',
                                         'GGGG');// last pattern is used for Fuji X-trans GGGGBRGGGGRBGGGG'
  annotation_color: tcolor=clyellow;
  annotation_diameter : integer=20;
  pedestal            : integer=0;
  egain_extra_factor  : integer=16;
  egain_default       : double=1;
  passband_active: string=''; //Indicates current Gaia conversion active
  star_profile_plotted: boolean=false;
  minor_planet_at_cursor:string='';


procedure ang_sep(ra1,dec1,ra2,dec2 : double;out sep: double);
function load_fits(filen:string;light {load as light or dark/flat},load_data,update_memo: boolean;get_ext: integer;const memo : tstrings; out head: Theader; out img_loaded2: image_array): boolean;{load a fits or Astro-TIFF file}
procedure plot_fits(img: timage;center_image,show_header:boolean);
procedure use_histogram(img: image_array; update_hist: boolean);{get histogram}
procedure HFD(img: image_array;x1,y1,rs {boxsize}: integer;aperture_small, adu_e {unbinned}:double; out hfd1,star_fwhm,snr{peak/sigma noise}, flux,xc,yc:double);{calculate star HFD and FWHM, SNR, xc and yc are center of gravity, rs is the boxsize, aperture for the flux measurment. All x,y coordinates in array[0..] positions}
procedure backup_img;
procedure restore_img;
function load_image(filename2: string; out img: image_array; out head: theader; memo: tstrings; re_center,plot: boolean): boolean; {load fits or PNG, BMP, TIF}

procedure demosaic_bayer(var img: image_array); {convert OSC image to colour}

Function INT_IEEE4_reverse(x: double):longword;{adapt intel floating point to non-intel float}
function save_fits(img: image_array;memo:tstrings;filen2:ansistring;type1:integer;override2:boolean): boolean;{save to 8, 16 OR -32 BIT fits file}
procedure update_text(memo:tstrings;inpt,comment1:string);{update or insert text in header}
procedure add_text(memo:tstrings;inpt,comment1:string);{add text to header memo}
procedure update_longstr(memo:tstrings;inpt,thestr:string);{update or insert long str including single quotes}
procedure add_long_comment(memo:tstrings;descrip:string);{add long text to header memo. Split description over several lines if required}
procedure update_generic(memo:tstrings;message_key,message_value,message_comment:string);{update header using text only}
procedure update_integer(memo:tstrings; inpt,comment1:string;x:integer);{update or insert variable in header}
procedure add_integer(memo:tstrings;inpt,comment1:string;x:integer);{add integer variable to header}
procedure update_float(memo:tstrings; inpt,comment1:string;preserve_comment:boolean;x:double);{update keyword of fits header in memo}

procedure remove_key(memo:tstrings;inpt:string; all:boolean);{remove key word in header. If all=true then remove multiple of the same keyword}

function fnmodulo (x,range: double):double;
function strtoint2(s: string;default:integer):integer; {str to integer, fault tolerant}
function strtofloat1(s:string): double;{string to float for dot seperator, error tolerant}
function strtofloat2(s:string): double;{works with either dot or komma as decimal separator}
function TextfileSize(const name: string): LongInt;
function floattostr8(x:double):string;//always with dot decimal seperator  Eight decimals
function floattostr6(x:double):string;//always with dot decimal seperator
function floattostr4(x:double):string;//always with dot decimal seperator
function floattostr2(x:double):string;//always with dot decimal seperator.
procedure update_menu(fits :boolean);{update menu if fits file is available in array or working from image1 canvas}
procedure get_hist(colour:integer;img :image_array);{get histogram of img_loaded}
procedure save_settings2;
procedure save_settings(lpath:string); //save settings at any path
procedure progress_indicator(i:double; info:string);{0 to 100% indication of progress}
{$ifdef mswindows}
procedure ExecuteAndWait(const aCommando: string; show_console:boolean);
{$else} {unix}
procedure execute_unix(const execut:string; param: TStringList; show_output: boolean);{execute linux program and report output}
procedure execute_unix2(s:string);
{$endif}
function mode(img :image_array;ellipse:  boolean; colorm,  xmin,xmax,ymin,ymax,max1 {maximum background expected}:integer; out greylevels:integer):integer;{find the most common value of a local area and assume this is the best average background value}
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
procedure new_to_old_WCS(var head:theader);{convert new style FITS to old style}
procedure old_to_new_WCS(var head:theader);{ convert old WCS to new}
procedure show_marker_shape(shape: TShape; shape_type,w,h,minimum:integer; fitsX,fitsY: double);{show manual alignment shape}
function check_raw_file_extension(ext: string): boolean;{check if extension is from raw file}
function convert_raw(loadfile,savefile :boolean;var filename3: string;out head: Theader; out img: image_array ): boolean; {convert raw to fits file using DCRAW or LibRaw. filename3 will be update with the new file extension e.g. .CR2.fits}

function unpack_cfitsio(var filename3: string): boolean; {convert .fz to .fits using funpack}
function pack_cfitsio(filename3: string): boolean; {convert .fz to .fits using funpack}

function load_TIFFPNGJPEG(filen:string;light {load as light or dark/flat}: boolean; out head :theader; out img: image_array;memo : tstrings) : boolean;{load 8 or 16 bit TIFF, PNG, JPEG, BMP image}
procedure get_background(colour: integer; img :image_array;calc_hist, calc_noise_level: boolean; out back : Tbackground); {get background and star level from peek histogram}


function extract_exposure_from_filename(filename8: string):integer; {try to extract exposure from filename}
function extract_temperature_from_filename(filename8: string): integer; {try to extract temperature from filename}
function extract_objectname_from_filename(filename8: string): string; {try to extract exposure from filename}

function test_star_spectrum(r,g,b: single) : single;{test star spectrum. Result of zero is perfect star spectrum}
procedure measure_magnitudes(annulus_rad,x1,y1,x2,y2:integer; deep: boolean; var stars :star_list);{find stars and return, x,y, hfd, flux}

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
procedure bin_X2X3X4(var img :image_array; var head : theader;memo:tstrings; binfactor:integer);{bin img 2x,3x or 4x}
procedure local_sd(x1,y1, x2,y2{regio of interest},col : integer; img : image_array; out sd,mean :double; out iterations :integer);{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}
function extract_raw_colour_to_file(filename7,filtern: string; xp,yp : integer) : string;{extract raw colours and write to file}
function fits_file_name(inp : string): boolean; {fits file name?}
function fits_tiff_file_name(inp : string): boolean; {fits or tiff file name?}
function tiff_file_name(inp : string): boolean; {tiff file name?}
function prepare_IAU_designation(rax,decx :double):string;{radialen to text hhmmss.s+ddmmss  format}
procedure pixel_to_celestial(head : theader; fitsx,fitsy : double; formalism : integer; out ra,dec  : double) {fitsX, Y to ra,dec};
procedure celestial_to_pixel(head: theader;ra,dec: double; out fitsX,fitsY: double);{ra,dec to fitsX,fitsY}
procedure show_shape_manual_alignment(index: integer);{show the marker on the reference star}
procedure write_astronomy_wcs(filen:string);
function savefits_update_header(memo:tstrings;filen2:string) : boolean;{save fits file with updated header}
procedure plot_the_annotation(x1,y1,x2,y2:integer; typ:double; name :string);{plot annotation from header in ASTAP format}
procedure reset_fits_global_variables(light :boolean; out head:theader ); {reset the global variable}
function convert_to_fits(var filen: string): boolean; {convert to fits}
procedure QuickSort(var A: array of double; iLo, iHi: Integer) ;{ Fast quick sort. Sorts elements in the array list with indices between lo and hi}
procedure convert_mono(var img: image_array; var head: Theader);
procedure Wait(wt:single=500);  {smart sleep}
procedure update_header_for_colour; {update naxis and naxis3 keywords}
procedure flip(x1,y1 : integer; out x2,y2 :integer);{array to screen or screen to array coordinates}
function decode_string(data0: string; out ra4,dec4 : double):boolean;{convert a string to position}
function save_tiff16(img: image_array; memo: tstrings; filen2:string;flip_H,flip_V:boolean): boolean;{save to 16 bit TIFF file }
function save_tiff16_secure(img : image_array; memo: tstrings;filen2:string) : boolean;{guarantee no file is lost}
function find_reference_star(img : image_array) : boolean;{for manual alignment}
function aavso_update_required : boolean; //update of downloaded database required?
function retrieve_ADU_to_e_unbinned(head_egain :string): double; //Factor for unbinned files. Result is zero when calculating in e- is not activated in the statusbar popup menu. Then in procedure HFD the SNR is calculated using ADU's only.
function noise_to_electrons(adu_e, sd : double): string;//reports noise in ADU's (adu_e=0) or electrons
procedure calibrate_photometry(img : image_array; memo : tstrings; var head : Theader);
procedure measure_hotpixels(x1,y1, x2,y2,col : integer; sd,mean:  double; img : image_array; out hotpixel_perc, hotpixel_adu :double);{calculate the hotpixels ratio and average value}
function duplicate(img:image_array) :image_array;//fastest way to duplicate an image
procedure annotation_position(aname:string;var ra,dec : double);// calculate ra,dec position of one annotation
procedure remove_photometric_calibration;//from header
procedure remove_solution(keep_wcs:boolean);//remove all solution key words efficient
procedure local_color_smooth(startX,stopX,startY,stopY: integer);//local color smooth img_loaded
procedure place_marker_radec(shape: tshape; ra,dec:double);{place ra,dec marker in image}
procedure variable_star_annotation(plot: boolean {if false, load only});


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
    {20}('CROTA1  =                  0.0 / Image twist X axis(deg)                        '),
    {21}('CROTA2  =                  0.0 / Image twist Y axis deg) E of N if not flipped  '),
    {22}('CD1_1   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
    {23}('CD1_2   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
    {24}('CD2_1   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
    {25}('CD2_2   =                  0.0 / CD matrix to convert (x,y) to (Ra, Dec)        '),
    {26}('PLTSOLVD=                    T / ASTAP from hnsky.org                           '),
    {27}('END                                                                             '),
    {28}('                                                                                ')); {should be empthy !!}


  pi_=pi; {for evaluate in debugging}
  dialog_filter_fits_tif='FITS and TIFF files|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.tif;*.tiff;*.TIF.TIFF';


type  byteX3  = array[0..2] of byte;
      byteXX3 = array[0..2] of word;
      byteXXXX3 = array[0..2] of single;

var
  Reader    : TReader;


  fitsbuffer : array[0..bufwide] of byte;{buffer for 8 bit FITS file}
  fitsbuffer2: array[0..round(bufwide/2)] of word absolute fitsbuffer;{buffer for 16 bit FITS file}
  fitsbufferRGB: array[0..trunc(bufwide/3)] of byteX3 absolute fitsbuffer;{buffer for 8 bit RGB FITS file}
  fitsbufferRGB16: array[0..trunc(bufwide/6)] of byteXX3 absolute fitsbuffer;{buffer for 16 bit RGB PPM file}
  fitsbufferRGB32: array[0..trunc(bufwide/12)] of byteXXXX3 absolute fitsbuffer;{buffer for -32 bit PFM file}
  fitsbuffer4: array[0..round(bufwide/4)] of longword absolute fitsbuffer;{buffer for floating bit ( -32) FITS file}
  fitsbuffer8: array[0..trunc(bufwide/8)] of qword absolute fitsbuffer;{buffer for floating bit ( -64) FITS file}
  fitsbufferSINGLE: array[0..round(bufwide/4)] of single absolute fitsbuffer;{buffer for floating bit ( -32) FITS file}
  fitsbufferDouble: array[0..round(bufwide/8)] of double absolute fitsbuffer;{buffer for floating bit ( -64) FITS file}


implementation

uses unit_dss, unit_stack, unit_tiff,unit_star_align, unit_astrometric_solving, unit_star_database, unit_annotation, unit_thumbnail, unit_xisf,unit_gaussian_blur,unit_inspector_plot,unit_asteroid,
     unit_astrometry_net, unit_live_stacking, unit_hjd,unit_hyperbola, unit_aavso, unit_listbox, unit_sqm, unit_stars_wide_field,unit_constellations,unit_raster_rotate,unit_download,unit_ephemerides, unit_online_gaia,unit_contour;

{$R astap_cursor.res}   {FOR CURSORS}

{$IFDEF fpc}
  {$R *.lfm}
{$else}  {delphi}
 {$R *.dfm}
{$endif}


var
  recent_files : tstringlist;
  export_index                                 : integer;
  object_xc,object_yc, object_raM,object_decM,object_hfd  : double; {near mouse auto centered object position}

var {################# initialised variables #########################}
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
  annotation_magn: string='12';
  magn_type : string='BP';

const
  crMyCursor = 5;
  ctrlbutton: boolean=false;


procedure reset_fits_global_variables(light :boolean;out head:theader); {reset the global variable}
begin
  if light then
  begin
    head.crota2:=999;{just for the case it is not available, make it later zero}
    head.crota1:=999;
    head.ra0:=0;
    head.dec0:=0;
    ra_mount:=999;
    dec_mount:=999;
    head.cdelt1:=0;
    head.cdelt2:=0;
    head.xpixsz:=0;
    head.ypixsz:=0;
    focallen:=0;
    subsamp:=1;{just for the case it is not available}
    head.cd1_1:=0;{just for the case it is not available}
    head.cd1_2:=0;{just for the case it is not available}
    head.cd2_1:=0;{just for the case it is not available}
    head.cd2_2:=0;{just for the case it is not available}
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

    head.xbinning:=1;{normal}
    head.ybinning:=1;
    head.mzero:=0;{factor to calculate magnitude from full flux, new file so set to zero}
    head.mzero_radius:=99;{circle where flux is measured}
    head.pedestal:=0; {value added during calibration or stacking}

    telescop:=''; instrum:='';  origin:=''; object_name:='';{clear}
    sitelat:=''; sitelong:='';siteelev:='';

    focus_temp:=999;{assume no data available}
    focus_pos:=0;{assume no data available}
    pressure:=1010; {mbar/hPa}
    airmass:=0;
    annotated:=false; {any annotation in the file}
    site_lat_radians:=999;

    sqm_value:='';
    equinox:=2000;
  end;

  head.date_obs:='';
  head.date_avg:='';
  head.calstat:='';{indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected, S stacked. Example value DFB}
  head.filter_name:='CV';//none
  head.naxis:=-1;{assume failure}
  head.naxis3:=1;
  head.datamin_org:=0;
  imagetype:='';
  head.exposure:=0;
  head.set_temperature:=999;
  head.gain:='';
  head.egain:='';{assume no data available}
  head.passband_database:='';//used to measure MZERO
  bayerpat:='';{reset bayer pattern}
  head.issues:='';;
end;{reset global variables}


//procedure precession_jnow_to_J2000(equinox : double; var ra1,dec1 : double); {simple precession correction,  new Meeus chapter precession formula 20.1}
//var
//  t,dra,ddec,m,n,n2  : double;
//begin
//  t:=(equinox-2000)/100;{time in julian centuries since j2000 }
//  m:=3.07496+0.00186*t;{seconds}
//  n:=1.33621-0.00057*t; {seconds}
//  n2:=20.0431-0.0085*t;{arcsec}
//  dra:=(m + n *sin(ra1)*tan(dec1))*pi/(3600*12);{yearly ra drift in radians}
//  ddec:=n2*cos(ra1)*pi/(3600*180); {yearly dec drift in radians}
//  ra1:=ra1-(dra*t*100);{multiply with number of years is t*100. Subtract because we go back to J2000}
//  dec1:=dec1-(ddec*t*100);
//end;


function load_fits(filen:string;light {load as light or dark/flat},load_data,update_memo: boolean;get_ext: integer;const memo: tstrings;out head: Theader; out img_loaded2: image_array): boolean;{load a fits or Astro-TIFF file}
{if light=true then read also head.ra0, head.dec0 ....., else load as dark, flat}
{if load_data then read all else header only}
{if reset_var=true, reset variables to zero}
var
  TheFile  : tfilestream;
  header    : array[0..2880] of ansichar;
  i,j,k,nr,error3,naxis1, reader_position,n,file_size  : integer;
  tempval, ccd_temperature, jd2,jd_obs, PC1_1,PC1_2, PC2_1,PC2_2   : double;
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

  tfields,tform_counter,header_count,pointer,let, validate_double_error : integer;
  ttype,tform,tunit : array of string;
  tbcol,tform_nr    : array of integer;
  simple,image,bintable,asciitable    : boolean;
  abyte                               : byte;

  dummy                               : dword;
  dummystr,dummystr2: string;
  dummyfloat       : double;

var {################# initialised variables #########################}
  end_record : boolean=false;

     procedure close_fits_file; inline;
     begin
       Reader.free;
       TheFile.free;
     end;

     function validate_double:double;{read floating point or integer values}
     var t     : string[21];
         r     : integer;
     begin
       t:='';
       r:=I+10;{position 11 equals 10}
       while ((header[r]<>'/') and (r<=I+30) {pos 31}) do {'/' check is strictly not necessary but safer. Read up to position 31 so one more then fits standard since CFITSIO could write for minus values up to position 31. A violation of FITS standard 4}
       begin  {read 20 characters max, position 11 to 31 in string, position 10 to 30 in pchar}
         if header[r]<>' ' then t:=t+header[r];
         inc(r);
       end;
       val(t,result,validate_double_error);
     end;

     Function get_string:string;{read string values}
     var  r: integer;
     begin
       result:='';
       r:=I+11;{start reading at position pos12, single quotes should for fix format should be at position 11 according FITS standard 4.0, chapter 4.2.1.1}
       while ((header[r-1]<>#39) and (r<I+77)) do inc(r); {find first quote at pos 11 or later for case it is not at position 11 (free-format strings)}
       while ((header[r]<>#39){last quote} and (r<I+79)) do {read string up to position 79 equals 78. The while (rather then repeat) instruction guarantees reading emphty strings with length zero correctly}
       begin
         result:=result+header[r];
         inc(r);
       end;
       result:=trim(result);
     end;

     Function get_as_string:string;{read float as string values. Universal e.g. for latitude and longitude which could be either string or float}
     var  r: integer;
     begin
       result:=header[i+10]; //This position could be the minus sign of a number -3.000000000000E+001
       if result=#39 then result:='';//Ignore the #39 character indication a string
       r:=I+11;{pos12, single quotes should for fix format should be at position 11 according FITS standard 4.0, chapter 4.2.1.1}
       while ((header[r]<>#39){last quote} and (r<I+30)) do {read string up to position 30}
       begin
         result:=result+header[r];
         inc(r);
       end;
     end;

begin
  {some house keeping}
  result:=false; {assume failure}

  if load_data then mainwindow.caption:=ExtractFileName(filen);
  {house keeping done}

  if tiff_file_name(filen) then  {load Astro-TIFF instead of FITS}
  begin
    result:=load_TIFFPNGJPEG(filen,light, head,img_loaded2,mainwindow.memo1.lines);{load TIFF image}
    exit;
  end;

  try
    TheFile:=tfilestream.Create( filen, fmOpenRead or fmShareDenyWrite);
  except
     beep;
     mainwindow.error_label1.caption:=('Error accessing file!');
     mainwindow.error_label1.visible:=true;
     exit;
  end;
  file_size:=TheFile.size;

  memo.beginupdate;{for speed. Will be activated in plot routine}
  if update_memo then
    memo.clear;{clear memo for new header}

  Reader := TReader.Create(TheFile,128*2880);{number of records. 128*2880 is 2% faster then 8* 2880}

  {Reset GLOBAL variables for case they are not specified in the file}
  reset_fits_global_variables(light,head);

  if get_ext=0 then extend_type:=0; {always an image in main data block}
  naxis1:=0;
  bzero:=0;{just for the case it is not available. 0.0 is the default according https://heasarc.gsfc.nasa.gov/docs/fcg/standard_dict.html}
  bscale:=1;
  ccd_temperature:=999;
  measured_max:=0;
  PC1_1:=0;

  header_count:=0;
  bintable:=false;
  asciitable:=false;

  reader_position:=0;
  repeat {header, 2880 bytes loop}

  I:=0;
    repeat {loop for reaching image/table}
      try
        reader.read(header[I],2880);{read file header, 2880 bytes}
        inc(reader_position,2880);  {TheFile.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}
        if ((reader_position=2880) and (header[0]='S') and (header[1]='I')  and (header[2]='M') and (header[3]='P') and (header[4]='L') and (header[5]='E') and (header[6]=' ')) then
        begin
          simple:=true;
          image:=true;
        end;
        if simple=false then
        begin
          close_fits_file;
          beep;
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
            if 'TABLE'=get_string then extend_type:=2 {ascii_table identifier}
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
        mainwindow.error_label1.caption:='Read exception error!!';
        mainwindow.error_label1.visible:=true;
        exit;
      end;
    until ((simple) and (header_count>=get_ext)); {simple is true and correct header found}

    repeat  {loop for 80 bytes in 2880 block}
      if load_data then
      begin
        SetString(aline, Pansichar(@header[i]), 80);{convert header line to string}
        if update_memo then memo.add(aline); {add line to memo}
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
          if head.naxis3>3  then {panic more then three colours}
          begin
             head.naxis3:=1; {display only the first colour}
             memo2_message('Warning more then three colours. Displayed only the first one.');
          end;
        end;
      end;


      if image then {image specific header}
      begin {read image header}

         if (header[i]='B') then {B}
        begin
          if ((header[i+1]='A')  and (header[i+2]='Y') and (header[i+3]='E') and (header[i+4]='R') and (header[i+5]='P') and (header[i+6]='A')) then {BAYERPAT, read for flats}
             bayerpat:=get_string {BAYERPAT, bayer pattern such as RGGB}
          else
          if ((header[i+1]='I')  and (header[i+2]='T') and (header[i+3]='P') and (header[i+4]='I') and (header[i+5]='X')) then
            nrbits:=round(validate_double) {BITPIX, read integer using double routine}
          else
          if ( (header[i+1]='Z')  and (header[i+2]='E') and (header[i+3]='R') and (header[i+4]='O') ) then
          begin
             tempval:=validate_double;
             if tempval>2147483647 then
             bzero:=-2147483648
             else
             bzero:=round(tempval); {Maxim DL writes BZERO value -2147483647 as +2147483648 !! }
            {without this it would have worked also with error check off}
          end
          else
          if ( (header[i+1]='S')  and (header[i+2]='C') and (header[i+3]='A') and (header[i+4]='L') ) then
             bscale:=validate_double {rarely used. Normally 1}
          else
          if ((header[i+1]='I')  and (header[i+2]='A') and (header[i+3]='S') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then
               head.flatdark_count:=round(validate_double);{read integer as double value}
        end;{B}

        if (header[i]='C') then {C}
        begin
          if ((header[i+1]='A')  and (header[i+2]='L') and (header[i+3]='S') and (header[i+4]='T') and (header[i+5]='A')) then  {head.calstat is also for flats}
              head.calstat:=get_string {indicates calibration state of the image; B indicates bias corrected, D indicates dark corrected, F indicates flat corrected. M could indicate master}
          else
          if ((header[i+1]='C')  and (header[i+2]='D') and (header[i+3]='-') and (header[i+4]='T') and (header[i+5]='E') and (header[i+6]='M')) then
             ccd_temperature:=validate_double;{read double value}
        end;{C}

        if (header[i]='E') then
        begin
          if ((header[i+1]='G')  and (header[i+2]='A') and (header[i+3]='I') and (header[i+4]='N')) then  {egain}
          begin
            head.egain:=trim(get_as_string)//Do not crop anymore since it doesn't work for scientific notation, e-/adu gain
          end
          else
          if ((header[i+1]='X')  and (header[i+2]='P')) then
          begin
            if ((header[i+3]='O') and (header[i+4]='S') and (header[i+5]='U') and (header[i+6]='R')) then
                head.exposure:=validate_double;{read double value}
            if ((header[i+3]='T') and (header[i+4]='I') and (header[i+5]='M') and (header[i+6]='E') and (header[i+7]=' ')) then {exptime and not exptimer}
                head.exposure:=validate_double;{read double value}
          end;
        end;

        if ((header[i]='S') and (header[i+1]='E')  and (header[i+2]='T') and (header[i+3]='-') and (header[i+4]='T') and (header[i+5]='E') and (header[i+6]='M')) then
               try head.set_temperature:=round(validate_double);{read double value} except; end; {some programs give huge values}

        if header[i]='I' then
        begin
          if ((header[i+1]='M')  and (header[i+2]='A') and (header[i+3]='G') and (header[i+4]='E') and (header[i+5]='T') and (header[i+6]='Y')) then
            imagetype:=get_string;{trim is already applied}
          if ((header[i+1]='S')  and (header[i+2]='S') and (header[i+3]='U') and (header[i+4]='E')  and (header[i+5]='S')) then
            head.issues:=get_string;{trim is already applied}
        end;

        if (header[i]='F') then {F}
        begin
          if ((header[i+1]='I')  and (header[i+2]='L') and (header[i+3]='T') and (header[i+4]='E') and (header[i+5]='R') and (header[i+6]=' ')) then
             head.filter_name:=get_string {trim is already applied}
          else
          if ((header[i+1]='L')  and (header[i+2]='A') and (header[i+3]='T') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then
               head.flat_count:=round(validate_double);{read integer as double value}
        end; {F}

        if ((header[i]='X') and (header[i+1]='B')  and (header[i+2]='I') and (header[i+3]='N') and (header[i+4]='N') and (header[i+5]='I')) then
                 head.xbinning:=validate_double;{binning}
        if ((header[i]='Y') and (header[i+1]='B')  and (header[i+2]='I') and (header[i+3]='N') and (header[i+4]='N') and (header[i+5]='I')) then
                 head.ybinning:=validate_double;{binning}

        if ((header[i]='G') and (header[i+1]='A')  and (header[i+2]='I') and (header[i+3]='N') and (header[i+4]=' ')) then
             head.gain:=trim(get_as_string); {head.gain CCD}
        if ((header[i]='I') and (header[i+1]='S')  and (header[i+2]='O') and (header[i+3]='S') and (header[i+4]='P')) then
             if head.gain='' then head.gain:=trim(get_as_string);{isospeed, do not override head.gain}


        {following variable are not set at zero Set at zero somewhere in the code}
        if ((header[i]='L') and (header[i+1]='I')  and (header[i+2]='G') and (header[i+3]='H') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then
             head.light_count:=round(validate_double);{read integer as double value}

        if ((header[i]='T') and (header[i+1]='I')  and (header[i+2]='M') and (header[i+3]='E') and (header[i+4]='-') and (header[i+5]='O') and (header[i+6]='B')) then
        begin
          if length(head.date_obs)=10 then head.date_obs:=head.date_obs+'T'+get_string;
        end;

        if ((header[i]='J') and (header[i+1]='D')) then
        begin
          if ((header[i+2]=' ') and (header[i+3]=' ') and (header[i+4]=' ')) then //julian day
          begin
            if head.date_obs='' then {DATE-OBS overrules any JD value}
            begin
              jd2:=validate_double;
              head.date_obs:=JdToDate(jd2);
            end;
          end
          else
          if ((header[i+2]='-') and (header[i+3]='A') and (header[i+4]='G')) then //JD_AVG
          begin
            if head.date_avg='' then {DATE-AVG overrules any JD value}
            begin
              jd2:=validate_double;
              head.date_avg:=JdToDate(jd2);
            end;
          end
        end;

        if ((header[i]='D') and (header[i+1]='A')) then {DA}
        begin
          if ((header[i+2]='T') and (header[i+3]='E') and (header[i+4]='-')) then {DATE-}
          begin
            if ((header[i+5]='O') and (header[i+6]='B')) then head.date_obs:=get_string //date-obs
            else
            if ((header[i+5]='A') and (header[i+6]='V')) then head.date_avg:=get_string; //date-avg
          end
          else
          if ((header[i+2]='R') and (header[i+3]='K') and (header[i+4]='_') and (header[i+5]='C') and (header[i+6]='N')and (header[i+7]='T')) then {DARK_CNT}
               head.dark_count:=round(validate_double);{read integer as double value}
        end;



        if light then {read as light ##############################################################################################################################################################}
        begin
          if (header[i]='A') then {A}
          begin
            if ((header[i+1]='M')  and (header[i+2]='B') and (header[i+3]='-') and (header[i+4]='T') and (header[i+5]='E') and (header[i+6]='M')) then
                focus_temp:=validate_double {ambient temperature}
            else
            if ((header[i+1]='O')  and (header[i+2]='C')) then {AOC}
            begin {ASCOM Observatory Conditions}
              if ((header[i+3]='B') and (header[i+4]='A') and (header[i+5]='R') and (header[i+6]='O')) then { AOCBAROM}
                 pressure:=validate_double {read double value}
              else
              if ((header[i+3]='A') and (header[i+4]='M') and (header[i+5]='B') and (header[i+6]='T')) then { AOCAMBT}
                 focus_temp:=validate_double;{read double value}
            end {AOC}
            else
            if ((header[i+1]='N')  and (header[i+2]='N') and (header[i+3]='O') and (header[i+4]='T') and (header[i+5]='A') and (header[i+6]='T')) then
               annotated:=true; {contains annotations}

            if ((header[i+1]='M')  and (header[i+2]='D')) then
            begin
              if header[i+3]='X' then  {AMDX}
              begin
                if header[i+5]=' ' then s:=(header[i+4]) else s:=(header[i+4])+(header[i+5]);
                val(s,nr,error3);{1 to 20}
                x_coeff[nr-1]:=validate_double;
              end
              else
              if header[i+3]='Y' then  {AMDY}
              begin
                if header[i+5]=' ' then s:=(header[i+4]) else s:=(header[i+4])+(header[i+5]);
                val(s,nr,error3);{1 to 20}
                y_coeff[nr-1]:=validate_double;
              end;
            end //AMD
            else
            if ((header[i+1]='I')  and (header[i+2]='R') and (header[i+3]='M') and (header[i+4]='A') and (header[i+5]='S')) then
                airmass:=validate_double {airmass}
            else

            if (header[i+1]='_') then
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
            end; //A_
            if ((header[i+1]='P') and (header[i+2]='_')) then
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
            end; //AP_
          end; //A


          if (header[i]='B') then {B}
          begin
            if ((header[i+1]='A')  and (header[i+2]='N') and (header[i+3]='D') and (header[i+4]='P') and (header[i+5]='A') and (header[i+6]='S')) then
            begin
               BANDPASS:=validate_double;{read integer as double value. Deep sky survey keyword}
               if ((bandpass=35) or (bandpass=8)) then head.filter_name:='red'{ 37 possII IR,  35=possII red, 18=possII blue, 8=POSSI red, 7=POSSI blue}
               else
               if ((bandpass=18) or (bandpass=7)) then head.filter_name:='blue'
               else
               head.filter_name:=floattostr(bandpass);
            end;
            if header[i+1]='_' then
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
            end;//B_
            if ((header[i+1]='P') and (header[i+2]='_')) then
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
            end;//BP_

          end;//B


          if (header[i]='C') then {C}
          begin
            if (header[i+1]='R') then {CR}
            begin
              if ((header[i+2]='O') and (header[i+3]='T') and (header[i+4]='A')) then  {head.crota2}
              begin
                 if (header[i+5]='2') then  head.crota2:=validate_double else {read double value}
                 if (header[i+5]='1') then  head.crota1:=validate_double;{read double value}
              end
              else
              if ((header[i+2]='P') and (header[i+3]='I') and (header[i+4]='X')) then {head.crpix1}
              begin
                if header[i+5]='1' then head.crpix1:=validate_double else{ref pixel for x}
                if header[i+5]='2' then head.crpix2:=validate_double;    {ref pixel for y}
              end;
            end {CR}
            else
            if ((header[i+1]='D')  and (header[i+2]='E') and (header[i+3]='L') and (header[i+4]='T')) then {head.cdelt1}
            begin
              if header[i+5]='1' then head.cdelt1:=validate_double else{deg/pixel for RA}
              if header[i+5]='2' then head.cdelt2:=validate_double;    {deg/pixel for DEC}
            end;

            if ((header[i+1]='R')  and (header[i+2]='V') and (header[i+3]='A') and (header[i+4]='L')) then {crval1/2}
            begin
              if (header[i+5]='1') then  head.ra0:=validate_double*pi/180; {ra center, read double value}
              if (header[i+5]='2') then  head.dec0:=validate_double*pi/180; {dec center, read double value}
            end
            else
            if (header[i+1]='D') then {CD}
            begin
              if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='1')) then   head.cd1_1:=validate_double;
              if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='2')) then   head.cd1_2:=validate_double;
              if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='1')) then   head.cd2_1:=validate_double;
              if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='2')) then   head.cd2_2:=validate_double;
            end
            else
            if ((header[i+1]='E')  and (header[i+2]='N') and (header[i+3]='T')) then//CENT
            begin
              if ((header[i+4]='A') and (header[i+5]='L') and (header[i+6]='T')) then  {CENTALT, SBIG 1.0 standard}
                centalt:=get_as_string {universal for string and floats}
              else
              if ((header[i+4]='A') and (header[i+5]='Z')) then  {CENTAZ, SBIG 1.0 standard}
                centaz:=get_as_string; {universal for string and floats}
            end;//CENT
            if ((header[i+1]='N')  and (header[i+2]='P') and (header[i+3]='I') and (header[i+4]='X')) then
            begin
              if  (header[i+5]='1') then x_pixel_offset:=round(validate_double){rotation, read double value}
              else
              if  (header[i+5]='2') then y_pixel_offset:=round(validate_double);{rotation, read double value}
            end;//CNPIX
          end; {C}

          if ((header[i]='D') and (header[i+1]='E')  and (header[i+2]='C') and (header[i+3]=' ')) then {dec}
          begin
            tempval:=validate_double*pi/180;
            if validate_double_error=0 then //not a string value behind keyword DEC
            begin
              dec_mount:=tempval;
              if head.dec0=0 then head.dec0:=tempval; {dec telescope, read double value only if crval is not available}
            end;
          end;

          if header[i]='E' then
          begin
            if ((header[i+1]='Q')  and (header[i+2]='U') and (header[i+3]='I') and (header[i+4]='N') and (header[i+5]='O') and (header[i+6]='X')) then
                 equinox:=validate_double;

            if ((header[i+1]='X')  and (header[i+2]='T') and (header[i+3]='E') and (header[i+4]='N') and (header[i+5]='D')) then {EXTEND}
              if pos('T',get_as_string)>0 then last_extension:=false;{could be extensions, will be updated later }
          end;//E

          if ( ((header[i]='S') and (header[i+1]='E')  and (header[i+2]='C') and (header[i+3]='P') and (header[i+4]='I') and (header[i+5]='X')) or     {secpix1/2}
               ((header[i]='S') and (header[i+1]='C')  and (header[i+2]='A') and (header[i+3]='L') and (header[i+4]='E') and (header[i+5]=' ')) or     {SCALE value for SGP files}
               ((header[i]='P') and (header[i+1]='I')  and (header[i+2]='X') and (header[i+3]='S') and (header[i+4]='C') and (header[i+5]='A')) ) then {pixscale}
          begin
            if head.cdelt2=0 then
                begin head.cdelt2:=validate_double/3600; {deg/pixel for RA} head.cdelt1:=head.cdelt2; end; {no head.cdelt1/2 found yet, use alternative}
          end;

          if ((header[i]='F') and (header[i+1]='O')  and (header[i+2]='C')) then  {FOC}
          begin
            if ((header[i+3]='A') and (header[i+4]='L') and (header[i+5]='L')) then  {FOCALLEN}
                    focallen:=validate_double {Focal length of telescope in mm, maxim DL keyword}
            else
            if      (  ((header[i+3]='U') and (header[i+4]='S') and (header[i+5]='P') and (header[i+6]='O')) or
                       ((header[i+3]='P') and (header[i+4]='O') and (header[i+5]='S') and (header[i+6]=' '))  ) then
                 try focus_pos:=round(validate_double);{focus position} except;end
            else
            if      (  ((header[i+3]='U') and (header[i+4]='S') and (header[i+5]='T') and (header[i+6]='E')) or
                       ((header[i+3]='T') and (header[i+4]='E') and (header[i+5]='M') and (header[i+6]='P')) )  then
                   focus_temp:=validate_double;{focus temperature}
          end;//FOC

          if ((header[i]='I') and (header[i+1]='N')  and (header[i+2]='S') and (header[i+3]='T') and (header[i+4]='R') and (header[i+5]='U') and (header[i+6]='M')) then
                   INSTRUM:=get_string;

          if ((header[i]='M') and (header[i+1]='Z')  and (header[i+2]='E') and (header[i+3]='R') and (header[i+4]='O')) then
          begin
            if (header[i+5]='R') then head.mzero:=validate_double;//ZEROR photometry calibration for restricted aperture
            if (header[i+5]='A') then head.mzero_radius:=validate_double;//MZEROAPT photometry calibration
            if (header[i+5]='P') then head.passband_database:=get_string; //MZEROPAS
          end; //MZERO



          if header[i]='O' then
          begin
            if ((header[i+1]='B')  and (header[i+2]='S'))  then  {OBS    site latitude, longitude}
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
            end;//OBS
            if ((header[i+1]='R')  and (header[i+2]='I') and (header[i+3]='G') and (header[i+4]='I') and (header[i+5]='N')) then
                   origin:=get_string;
            if ((header[i+1]='B')  and (header[i+2]='J')) then {OBJ}
            begin
              if  ((header[i+3]='C') and (header[i+4]='T')) then {objctra, objctdec}
              begin {OBJCT}
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
                if ((header[i+5]='A') and (header[i+6]='L') and (centalt='')) then //OBJCTALT
                    centalt:=get_as_string {universal for string and floats}
                else {for older MaximDL5}
                if ((header[i+5]='A') and (header[i+6]='Z')and (centaz='')) then
                    centaz:=get_as_string; {universal for string and floats}
              end {OBJCT}
              else
              if ((header[i+3]='E') and (header[i+4]='C') and (header[i+5]='T')) then {OBJECT}
                object_name:=get_string;{trim is already applied}
            end;{OBJ}
          end;//O

          if (header[i]='P') then
          begin
            if ((header[i+1]='R')  and (header[i+2]='E') and (header[i+3]='S') and (header[i+4]='S') and (header[i+5]='U') and (header[i+6]='R')) then
                 pressure:=validate_double;{read double value}
            if ((header[i+1]='E')  and (header[i+2]='D') and (header[i+3]='E') and (header[i+4]='S') and (header[i+5]='T') and (header[i+6]='A') and (header[i+7]='L')) then //full keyword since it is also written by raw to fits as pedestal, pedesta1....
                 head.pedestal:=abs(validate_double);{read double value. Make value positive to make it compatible with MaximDL files which writes it negative}

            if ((header[i+1]='L')  and (header[i+2]='T')) then
            begin
              if ((header[i+3]='R') and (header[i+4]='A')) then //PLTRA
              begin
                if (header[i+5]='H') then   plate_ra:=validate_double*pi/12;
                if (header[i+5]='M') then   plate_ra:=plate_ra+validate_double*pi/(60*12);
                if (header[i+5]='S') then   plate_ra:=plate_ra+validate_double*pi/(60*60*12);;
              end
              else
              if ((header[i+3]='D') and (header[i+4]='E')) then //PLTDE
              begin
                if (header[i+7]='N') then  begin if (header[i+11]='-') then  dec_sign:=-1 else dec_sign:=+1;end; {dec sign}
                if (header[i+6]='D') then   plate_dec:=validate_double*pi/180;
                if (header[i+6]='M') then   plate_dec:=plate_dec+validate_double*pi/(60*180);
                if (header[i+6]='S') then   plate_dec:=dec_sign*(plate_dec+validate_double*pi/(60*60*180));
              end;
            end;//PLT
            if ((header[i+1]='P')  and (header[i+2]='O')) then //PPO
            begin
              if (header[i+3]='3') then   ppo_coeff[2]:=validate_double;  //DSS polynome
              if (header[i+3]='6') then   ppo_coeff[5]:=validate_double;
            end;//PPO
            if (header[i+1]='C') then //PC
            begin
              if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='1')) then   pc1_1:=validate_double;
              if ((header[i+2]='1') and (header[i+3]='_') and (header[i+4]='2')) then   pc1_2:=validate_double;
              if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='1')) then   pc2_1:=validate_double;
              if ((header[i+2]='2') and (header[i+3]='_') and (header[i+4]='2')) then   pc2_2:=validate_double;
            end;//PC
          end;//P

          if header[i]='R' then
          begin
            if ((header[i+1]='A')  and (header[i+2]=' ')) then  {ra}
            begin
              tempval:=validate_double*pi/180;
              if validate_double_error=0 then //not a string value behind keyword RA
              begin
                ra_mount:=tempval;
                if head.ra0=0 then head.ra0:=tempval; {ra telescope, read double value only if crval is not available}
              end;
            end;
            if ((header[i+1]='O')  and (header[i+2]='W') and (header[i+3]='O') and (header[i+4]='R') and (header[i+5]='D') and (header[i+6]='E')) then
              roworder:=get_string;
          end;//R

          if (header[i]='S') then
          begin
            if ((header[i+1]='I')  and (header[i+2]='T') and (header[i+3]='E') ) then  {site latitude, longitude}
            begin
              if ((header[i+4]='L') and (header[i+5]='A') and (header[i+6]='T')) then
                sitelat:=get_as_string;{universal, site latitude as string}
              if ((header[i+4]='L') and (header[i+5]='O') and (header[i+6]='N')) then
                 sitelong:=get_as_string;{universal, site longitude as string}
              if ((header[i+4]='E') and (header[i+5]='L') and (header[i+6]='E')) then
                 siteelev:=get_as_string;{universal, site elevation as string}
            end;
            if ((header[i+1]='U')  and (header[i+2]='B') and (header[i+3]='S') and (header[i+4]='A') and (header[i+5]='M')) then
                    subsamp:=round(validate_double);{subsampling value, DSS polynome plate fit}
          end;//S

          if ((header[i]='T') and (header[i+1]='E')  and (header[i+2]='L') and (header[i+3]='E') and (header[i+4]='S') and (header[i+5]='C') and (header[i+6]='O')) then
                   TELESCOP:=get_string;

          {adjustable keyword}
          if ((header[i]=sqm_key[1]{S}) and (header[i+1]=sqm_key[2]{Q}) and (header[i+2]=sqm_key[3]{M})and (header[i+3]=sqm_key[4])and (header[i+4]=sqm_key[5])and (header[i+5]=sqm_key[6])and (header[i+6]=sqm_key[7]) and (header[i+7]=sqm_key[8])) then {adjustable keyword}
          begin
            sqm_value:=trim(get_as_string); {universal for string and floats}{SQM, accept strings (standard) and floats}
          end;

          if header[i]='X' then
          begin
            if ((header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='E') and (header[i+5]='L')) then
                    x_pixel_size:=validate_double;{rotation, read double value}
            if ((header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='S') and (header[i+5]='Z')) then {Xpixsz}
                   head.xpixsz:=validate_double;{Pixel Width in microns (after binning), maxim DL keyword}
            if ((header[i+1]='B')  and (header[i+2]='A') and (header[i+3]='Y') and (header[i+4]='R') and (header[i+5]='O') and (header[i+6]='F')) then
               xbayroff:=validate_double;{offset to used to correct BAYERPAT due to flipping}
          end;

          if header[i]='Y' then
          begin
            if ((header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='E') and (header[i+5]='L')) then
                    y_pixel_size:=validate_double;{rotation, read double value}
            if ((header[i+1]='P')  and (header[i+2]='I') and (header[i+3]='X') and (header[i+4]='S') and (header[i+5]='Z')) then {Ypixsz}
                   head.ypixsz:=validate_double;{Pixel Width in microns (after binning), maxim DL keyword}
            if ((header[i+1]='B')  and (header[i+2]='A') and (header[i+3]='Y') and (header[i+4]='R') and (header[i+5]='O') and (header[i+6]='F')) then
               ybayroff:=validate_double;{offset to used to correct BAYERPAT due to flipping}
           end;//Y


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
        if ((header[i]='Z') and (header[i+1]='C')  and (header[i+2]='M') and (header[i+3]='P') and (header[i+4]='T')) then  { ZCMPTYPE, compressed image in table Rice and others format}
        begin
          last_extension:=true;{give up}
        end;

        if ((header[i]='T') and (header[i+1]='F')  and (header[i+2]='O') and (header[i+3]='R') and (header[i+4]='M')) then
        begin
          number:=trim(header[i+5]+header[i+6]+header[i+7]);
          tform_counter:=strtoint(number)-1;
          tform[tform_counter]:=get_string;
          try
          let:=pos('E',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='E';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{single e.g. E, 1E or 4E}
          let:=pos('D',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='D';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{double e.g. D, 1D or 5D (sub table 5*D) or D25.17}
          let:=pos('L',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='L';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{logical}
          let:=pos('X',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='X';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{bit}
          let:=pos('B',tform[tform_counter]);
          if let>0 then begin aline:=trim(tform[tform_counter]);
            tform[tform_counter]:='B';aline:=copy(aline,1,let-1);
            tform_nr[tform_counter]:=max(1,strtoint('0'+aline));
          end;{byte}
          let:=pos('I',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='I';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{16 bit integer}
          let:=pos('J',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='J';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{32 bit integer}
          let:=pos('K',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='K';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{64 bit integer}
          let:=pos('A',tform[tform_counter]); if let>0 then begin aline:=trim(tform[tform_counter]); tform[tform_counter]:='A';aline:=copy(aline,1,let-1); tform_nr[tform_counter]:=max(1,strtoint('0'+aline)); end;{char e.g. 12A for astrometry.net first index table}
          except
          end;
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

  memo.endupdate;{for speed}

  if head.naxis<2 then
  begin
    if head.naxis=0 then result:=true {wcs file}
               else result:=false; {no image}
    mainwindow.image1.visible:=false;
    image:=false;
  end;

  if image then {read image data #########################################}
  begin
    if ((head.naxis=3) and (naxis1=3)) then
    begin
       nrbits:=24; {threat RGB fits as 2 dimensional with 24 bits data}
       head.naxis3:=3; {will be converted while reading}
    end;

    if ((head.cd1_1<>0) and ((head.cdelt1=0) or (head.crota2>=999))) then
    begin //formalism 3
      new_to_old_WCS(head);{ convert old WCS to new}
    end
    else
    if ((head.cd1_1=0) and (head.cdelt2<>0)) then {new style missing but valid old style solution}
    begin
      if PC1_1<>0 then //formalism 2
      begin
        head.CD1_1:=PC1_1* head.cdelt1;
        head.CD1_2:=PC1_2* head.cdelt1;
        head.CD2_1:=PC2_1* head.cdelt2;
        head.CD2_2:=PC2_2* head.cdelt2;
        new_to_old_WCS(head);{ convert old WCS to new}
      end
      else
      if head.crota2<999 then {new style missing but valid old style solution}
      begin //formalism 1
        if head.crota1=999 then head.crota1:=head.crota2; {for case head.crota1 is not specified}
        old_to_new_WCS(head);{ convert old WCS to new}
       end;
    end;

    if ((head.cd1_1=0) and (head.cdelt2=0)) then  {no scale, try to fix it}
    begin
     if ((focallen<>0) and (head.xpixsz<>0)) then
        head.cdelt2:=180/(pi*1000)*head.xpixsz/focallen; {use maxim DL key word. xpixsz is including binning}
    end;

    if head.set_temperature=999 then head.set_temperature:=round(ccd_temperature); {temperature}

    if ((light) and ((head.ra0<>0) or (head.dec0<>0) or (equinox<>2000)) ) then
    begin
      if equinox<>2000 then //e.g. in SharpCap
      begin
        jd_obs:=(equinox-2000)*365.25+2451545;
        precession3(jd_obs, 2451545 {J2000},head.ra0,head.dec0); {precession, from unknown equinox to J2000}
        if dec_mount<999 then precession3(jd_obs, 2451545 {J2000},ra_mount,dec_mount); {precession, from unknown equinox to J2000}
      end;

      mainwindow.ra1.text:=prepare_ra(head.ra0,' ');{this will create Ra_radians for solving}
      mainwindow.dec1.text:=prepare_dec(head.dec0,' ');
    end;
    { condition           keyword    to
     if ra_mount>999 then objctra--->ra1.text--------------->ra_radians--->ra_mount
                               ra--->ra_mount  if head.ra0=0 then   ra_mount--->head.ra0
                           crval1--->head.ra0

     if head.ra0<>0 then           head.ra0--->ra1.text------------------->ra_radians}

    unsaved_import:=false;{file is available for astrometry.net}

    sip:=(ap_order>0);
    if sip then
      mainwindow.Polynomial1.itemindex:=1//switch to sip
    else
    if x_coeff[0]<>0 then
       mainwindow.Polynomial1.itemindex:=2//switch to DSS
    else
      mainwindow.Polynomial1.itemindex:=0;//switch to DSS

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

    setlength(img_loaded2,head.naxis3,head.height,head.width);

    if nrbits=16 then
    for k:=0 to head.naxis3-1 do {do all colors}
    begin
      For j:=0 to head.height-1 do
      begin
        try reader.read(fitsbuffer,head.width*2);except; head.naxis:=0;{failure} end; {read file info}
        for i:=0 to head.width-1 do
        begin
          word16:=swap(fitsbuffer2[i]);{move data to wo and therefore sign_int}
          col_float:=int_16*bscale + bzero; {save in col_float for measuring measured_max}
          img_loaded2[k,j,i]:=col_float;
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
        try reader.read(fitsbuffer,head.width*4);except; head.naxis:=0;{failure} end; {read file info}
        for i:=0 to head.width-1 do
        begin
          x_longword:=swapendian(fitsbuffer4[i]);{conversion 32 bit "big-endian" data, x_single  : single absolute x_longword; }
          col_float:=x_single*bscale+bzero; {int_IEEE, swap four bytes and the read as floating point}
          if isNan(col_float) then col_float:=measured_max;{not a number prevent errors, can happen in PS1 images with very high floating point values}
          img_loaded2[k,j,i]:=col_float;{store in memory array}
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
        try reader.read(fitsbuffer,head.width);except; head.naxis:=0;{failure} end; {read file info}
        for i:=0 to head.width-1 do
        begin
          img_loaded2[k,j,i]:=(fitsbuffer[i]*bscale + bzero);
        end;
      end;
    end {colors head.naxis3 times}
    else
    if nrbits=24 then
    For j:=0 to head.height-1 do
    begin
      try reader.read(fitsbuffer,head.width*3);except; head.naxis:=0;{failure} end; {read file info}
      for i:=0 to head.width-1 do
      begin
        rgbdummy:=fitsbufferRGB[i];{RGB fits with naxis1=3, treated as 24 bits coded pixels in 2 dimensions}
        img_loaded2[0,j,i]:=rgbdummy[0];{store in memory array}
        img_loaded2[1,j,i]:=rgbdummy[1];{store in memory array}
        img_loaded2[2,j,i]:=rgbdummy[2];{store in memory array}
      end;
    end
    else
    if nrbits=+32 then
    for k:=0 to head.naxis3-1 do {do all colors}
    begin
      For j:=0 to head.height-1 do
      begin
        try reader.read(fitsbuffer,head.width*4);except; head.naxis:=0;{failure} end; {read file info}
        for i:=0 to head.width-1 do
        begin
          col_float:=int32(swapendian(fitsbuffer4[i]))*bscale+bzero;{max range  -2,147,483,648 ...2,147,483,647 or -$8000 0000 .. $7FFF FFFF.  Scale later to 0..65535}
         {Tricky do not use int64 for BZERO,  maxim DL writes BZERO value -2147483647 as +2147483648 !!}
          img_loaded2[k,j,i]:=col_float;{store in memory array}
          if col_float>measured_max then
             measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}
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
          img_loaded2[k,j,i]:=col_float;{store in memory array}
          if col_float>measured_max then measured_max:=col_float;{find max value for image. For for images with 0..1 scale or for debayer}

        end;
      end;
    end; {colors head.naxis3 times}

    {rescale if required}
    if ((nrbits<=-32){-32 or -64} or (nrbits=+32)) then
    begin
      scalefactor:=1;
      if ((measured_max<=1.0*1.5) or (measured_max>65535*1.5)) then
        scalefactor:=65535/measured_max; {rescale 0..1 range float for GIMP, Astro Pixel Processor, PI files, transfer to 0..65535 float}
                                         {or if values are far above 65535. Note due to flat correction even in ASTAP pixels value can be a little 65535}
      if scalefactor<>1 then {not a 0..65535 range, rescale}
      begin
        for k:=0 to head.naxis3-1 do {do all colors}
          for j:=0 to head.height-1 do
            for i:=0 to head.width-1 do
              img_loaded2[k,j,i]:= img_loaded2[k,j,i]*scalefactor;
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

    bck.backgr:=head.datamin_org;{for case histogram is not called}
    cwhite:=head.datamax_org;

    result:=head.naxis<>0;{success};
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
   // if update_memo then
   //      mainwindow.memo1.visible:=true;{show header}
    mainwindow.pagecontrol1.showtabs:=true;{show tabs}
    reader_position:=reader_position+head.width*head.height;
  end; {read table}


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
        //mainwindow.memo1.visible:=true;{show memo1 since no plotting is coming}
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


function fnmodulo(x,range: double):double;
begin
  {range should be 2*pi or 24 hours or 0 .. 360}
  if ((x>=0) and (x<range)) then // avoid division. A very tiny amount faster
    result:=x
  else
    begin
      result:=x - range*int(x/range);// this is twice a fast as: x mod range
      if result<0 then result:=result+range;// avoid negative numbers
    end;
end;


function duplicate(img:image_array) :image_array;//fastest way to duplicate an image
var
  c,w,h,k,i: integer;
begin
  c:=length(img);
  h:=length(img[0]);
  w:=length(img[0,0]);

  setlength(result,c,h,w);
  for k:=0 to c-1 do
    for i:=0 to h-1 do
      result[k,i]:=copy(img[k,i],0,w);

//  alternative solution slower. Takes about 75% more time.
//  result:=img; {In dynamic arrays, the assignment statement duplicates only the reference to the array, while SetLength does the job of physically copying/duplicating it, leaving two separate, independent dynamic arrays.}
//  setlength(result,c,h,w);{force a duplication}
end;


function fits_file_name(inp : string): boolean; {fits file name?}
begin
  inp:=uppercase(extractfileext(inp));
  result:=((inp='.FIT') or (inp='.FITS') or (inp='.FTS') or (inp='.WCS'));{wcs for telescope tab}
end;

function fits_tiff_file_name(inp : string): boolean; {fits or tiff file name?}
begin
  inp:=uppercase(extractfileext(inp));
  result:=((inp='.FIT') or (inp='.FITS') or (inp='.FTS') or (inp='.TIF') or (inp='.TIFF') or (inp='.WCS'));{fits or tiff file name, wcs for mount analyse tab}
end;


function tiff_file_name(inp : string): boolean; {tiff file name?}
begin
  inp:=uppercase(extractfileext(inp));
  result:=((inp='.TIF') or (inp='.TIFF'));{tiff file name}
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


procedure read_keys_memo(light: boolean; var {var because it is set at default values} head : theader; memo :tstrings);{for tiff header in the describtion decoding}
var
  key                             : string;
  count1,index                    : integer;
  ccd_temperature,jd_obs : double;

  function read_float: double;
  var
    err: integer;
  begin
    val(copy(memo[index],11,20),result,err);
  end;
  function read_integer: integer;
  var
    err: integer;
  begin
    val(copy(memo[index],11,20),result,err);
  end;
  function read_string: string;
  var
    p1,p2 :integer;
  begin
    result:=copy(memo[index],11,80-11);

    p1:=pos(char(39),result);
    p2:=posex(char(39),result,p1+1);
    if p2=0 then p2:=21;{allow reading floats and integers as string}
    result:=trim(copy(result,p1+1,p2-p1-1));{remove all spaces}
  end;

begin
  {variables are already reset}
  count1:=memo.Count-1-1;
  ccd_temperature:=999;
  annotated:=false;

  index:=1;
  while index<=count1 do {read keys}
  begin
    key:=copy(memo[index],1,9);

    //should in this sequence available. If not fix.
    if index=1 then if key<>'BITPIX  =' then begin memo.insert(index,'BITPIX  =                   16 / Bits per entry                                 '); inc(count1); end;{data will be added later}
    if index=2 then if key<>'NAXIS   =' then begin memo.insert(index,'NAXIS   =                    2 / Number of dimensions                           ');inc(count1); end;{data will be added later}
    if index=3 then if key<>'NAXIS1  =' then begin memo.insert(index,'NAXIS1  =                  100 / length of x axis                               ');inc(count1); end;{data will be added later}
    if index=4 then if key<>'NAXIS2  =' then begin memo.insert(index,'NAXIS2  =                  100 / length of y axis                               ');inc(count1); end;{data will be added later}
    if ((index=5) and (head.naxis3>1)) then if key<>'NAXIS3  =' then
                                             begin memo.insert(index,'NAXIS3  =                    3 / length of z axis (mostly colors)               ');inc(count1); end;

    if key='CD1_1   =' then head.cd1_1:=read_float else
    if key='CD1_2   =' then head.cd1_2:=read_float else
    if key='CD2_1   =' then head.cd2_1:=read_float else
    if key='CD2_2   =' then head.cd2_2:=read_float else
    if key='CRPIX1  =' then head.crpix1:=read_float else
    if key='CRPIX2  =' then head.crpix2:=read_float else

    if key='CRVAL1  =' then head.ra0:=read_float*pi/180 {degrees -> radians}  else
    if key='CRVAL2  =' then head.dec0:=read_float*pi/180 else
    if key='RA      =' then
    begin
      ra_mount:=read_float*pi/180;{degrees -> radians}
      if head.ra0=0 then head.ra0:=ra_mount; {ra telescope, read double value only if crval is not available}
    end else
    if key='DEC     =' then
    begin
      dec_mount:=read_float*pi/180;
      if head.dec0=0 then head.dec0:=dec_mount; {ra telescope, read double value only if crval is not available}
    end else
    if ((key='OBJCTRA =') and (ra_mount>=999)) {ra_mount value is unfilled, preference for keyword RA} then
    begin
      mainwindow.ra1.text:=read_string;{triggers an onchange event which will convert the string to ra_radians}
      ra_mount:=ra_radians;{preference for keyword RA}
    end  else
    if ((key='OBJCTDEC=') and (dec_mount>=999)) {dec_mount value is unfilled, preference for keyword DEC} then
    begin
      mainwindow.dec1.text:=read_string;{triggers an onchange event which will convert the string to dec_radians}
      dec_mount:=dec_radians;
    end else
    if key='OBJECT  =' then object_name:=read_string else

    if ((key='EXPOSURE=') or ( key='EXPTIME =')) then head.exposure:=read_float else
    if (key='XBINNING=') then head.xbinning:=read_integer else
    if (key='YBINNING=') then head.ybinning:=read_integer else

    if (key='FOCALLEN=') then focallen:=read_float else
    if (key='XPIXSZ  =') then head.xpixsz:=read_float else  {pixelscale in microns}
    if (key='YPIXSZ  =') then head.ypixsz:=read_float else
    if (key='CDELT1  =') then head.cdelt1:=read_float else   {deg/pixel}
    if (key='CDELT2  =') then head.cdelt2:=read_float else   {deg/pixel}
    if (key='EQUINOX =') then equinox:=read_float else

    if ((key='SECPIX2 =') or
        (key='PIXSCALE=') or
        (key='SCALE   =')) then begin if head.cdelt2=0 then head.cdelt2:=read_float/3600; end {no head.cdelt1/2 found yet, use alternative, image scale arcseconds per pixel}
    else

    if key='GAIN    =' then head.gain:=copy(read_string,1,5);  {limit to 5 digits}
    if key='EGAIN   =' then head.egain:=copy(read_string,1,5) else

    if key='CCD-TEMP=' then ccd_temperature:=round(read_float) else
    if key='SET-TEMP=' then head.set_temperature:=round(read_float) else
    if key='LIGH_CNT=' then head.light_count:=read_integer else {will not be used unless there is a tiff 32 bit reader}
    if key='DARK_CNT=' then head.dark_count:=read_integer else {will not be used unless there is a tiff 32 bit reader}
    if key='FLAT_CNT=' then head.flat_count:=read_integer else {will not be used unless there is a tiff 32 bit reader}
    if key='BIAS_CNT=' then head.flatdark_count:=read_integer else {will not be used unless there is a tiff 32 bit reader}

    if key='PEDESTAL=' then head.pedestal:=round(read_float) else  {will not be used unless there is a tiff 32 bit reader}
    if key='CALSTAT =' then head.calstat:=read_string else {will not be used unless there is a tiff 32 bit reader}
    if key='FILTER  =' then head.filter_name:=read_string else
    if key='ISSUES  =' then head.issues:=read_string else

    if key='DATE-OBS=' then head.date_obs:=read_string else

    if key='BAYERPAT=' then bayerpat:=read_string;
    if key='ROWORDER=' then roworder:=read_string;
    if key='XBAYROFF=' then Xbayroff:=round(read_float) else
    if key='YBAYROFF=' then Ybayroff:=round(read_float) else


    if key='PRESSURE=' then pressure:=round(read_float) else
    if key='AIRMASS =' then airmass:=round(read_float) else
    if key='AOCBAROM=' then pressure:=round(read_float) else

    if key='FOCUSTEM=' then focus_temp:=round(read_float) else
    if key='FOCTEMP =' then focus_temp:=round(read_float) else
    if key='AMB-TEMP=' then focus_temp:=round(read_float) else
    if key='AOCAMBT =' then focus_temp:=round(read_float) else

    if key='MZEROR  =' then head.mzero:=read_float else
    if key='MZEROAPT=' then head.mzero_radius:=read_float else
    if key='MZEROPAS=' then head.passband_database:=read_string else

    if key='ANNOTATE=' then annotated:=true else
    if key='TELESCOP=' then telescop:=read_string else
    if key='INSTRUME=' then instrum:=read_string else
    if key='CENTALT =' then centalt:=read_string else
    if key='SITELAT =' then sitelat:=read_string else
    if key='SITELONG=' then sitelong:=read_string;


    {adjustable keywords}
    if key=sqm_key+'='    then sqm_value:=read_string;

    index:=index+1;
  end;

  if ((light) and ((head.ra0<>0) or (head.dec0<>0))) then
  begin
    if equinox<>2000 then //e.g. in SharpCap
    begin
      jd_obs:=(equinox-2000)*365.25+2451545;
      precession3(jd_obs, 2451545 {J2000},head.ra0,head.dec0); {precession, from unknown equinox to J2000}
      if dec_mount<999 then precession3(jd_obs, 2451545 {J2000},ra_mount,dec_mount); {precession, from unknown equinox to J2000}
    end;
    mainwindow.ra1.text:=prepare_ra(head.ra0,' ');{this will create Ra_radians for solving}
    mainwindow.dec1.text:=prepare_dec(head.dec0,' ');
  end;
  { condition           keyword    to
   if ra_mount>999 then objctra--->ra1.text--------------->  ra_radians--->ra_mount
                             ra--->ra_mount  if ra0=0 then   ra_mount--->ra0
                         crval1--->head.ra0

   if ra0<>0 then           ra0--->ra1.text------------------->ra_radians}



  if ((head.cd1_1<>0) and ((head.cdelt1=0) or (head.crota2>=999))) then {old style missing but valid new style solution}
  begin
    new_to_old_WCS(head);{ convert old WCS to new}
  end
  else
  if ((head.cd1_1=0) and (head.crota2<999) and (head.cdelt2<>0)) then {new style missing but valid old style solution}
  begin
    old_to_new_WCS(head);{ convert old WCS to new}
  end;

  if ((head.cd1_1=0) and (head.cdelt2=0)) then  {no scale, try to fix it}
  begin
   if ((focallen<>0) and (head.xpixsz<>0)) then
      head.cdelt2:=180/(pi*1000)*head.xpixsz/focallen; {use maxim DL key word. xpixsz is including binning}
  end;

  if head.crota2>999 then head.crota2:=0;{not defined, set at 0}
  if head.crota1>999 then head.crota1:=head.crota2; {for case head.crota1 is not specified}


  if head.set_temperature=999 then head.set_temperature:=round(ccd_temperature); {temperature}
end;


function load_PPM_PGM_PFM(filen:string; out head :theader; out img_loaded2: image_array; memo :Tstrings) : boolean;{load PPM (color),PGM (gray scale)file or PFM color}
var
  TheFile  : tfilestream;
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
        TheFile.free;
     end;

begin
  head.naxis:=0; {0 dimensions}
  result:=false; {assume failure}

  try
    TheFile:=tfilestream.Create( filen, fmOpenRead or fmShareDenyWrite);
  except
     beep;
     mainwindow.error_label1.caption:=('Error, accessing the file!');
     mainwindow.error_label1.visible:=true;
     exit;
  end;
  memo.beginupdate;
 // mainwindow.memo1.visible:=false;{stop visualising memo1 for speed. Will be activated in plot routine}
  memo.clear;{clear memo for new header}

  Reader := TReader.Create (TheFile,$60000);// 393216 byte buffer
  {TheFile.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}

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
      mainwindow.error_label1.caption:=('Error loading PGM/PPM/PFM file!! Keyword P5, P6, PF. Pf not found.');
      mainwindow.error_label1.visible:=true;
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
      mainwindow.error_label1.caption:=('Incompatible PPM/PGM/PFM file !!');
      mainwindow.error_label1.visible:=true;
      close_fits_file;
      head.naxis:=0;
      exit;
    end; {should contain 255 or 65535}

    head.datamin_org:=0;

    bck.backgr:=head.datamin_org;{for case histogram is not called}
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
      setlength(img_loaded2,head.naxis3,head.height,head.width);
      begin
        For i:=0 to head.height-1 do
        begin
          try reader.read(fitsbuffer,head.width*package);except; end; {read file info}

          for j:=0 to head.width-1 do
          begin
            if color7=false then {gray scale without bayer matrix applied}
            begin
              if nrbits=8 then  {8 BITS, mono 1x8bits}
                img_loaded2[0,i,j]:=fitsbuffer[j]{RGB fits with naxis1=3, treated as 48 bits coded pixels}
              else
              if nrbits=16 then {big endian integer}
                img_loaded2[0,i,j]:=swap(fitsbuffer2[j])
              else {PFM 32 bits grayscale}
              if pfm then
              begin
                if range<0 then {little endian floats}
                  img_loaded2[0,i,j]:=fitsbuffersingle[j]*65535/(-range) {PFM little endian float format. if nrbits=-1 then range 0..1. If nrbits=+1 then big endian with range 0..1 }
                else
                begin {big endian floats}
                  x_longword:=swapendian(fitsbuffer4[j]);{conversion 32 bit "big-endian" data, x_single  : single absolute x_longword; }
                  img_loaded2[0,i,j]:=x_single*65535/range;
                end;
              end;
            end
            else
            begin
              if nrbits=8 then {24 BITS, colour 3x8bits}
              begin
                rgbdummy:=fitsbufferRGB[j];{RGB fits with naxis1=3, treated as 48 bits coded pixels}
                img_loaded2[0,i,j]:=rgbdummy[0];{store in memory array}
                img_loaded2[1,i,j]:=rgbdummy[1];{store in memory array}
                img_loaded2[2,i,j]:=rgbdummy[2];{store in memory array}
              end
              else
              if nrbits=16 then {48 BITS colour, 3x16 big endian}
              begin {48 bits}
                rgb16dummy:=fitsbufferRGB16[j];{RGB fits with naxis1=3, treated as 48 bits coded pixels}
                img_loaded2[0,i,j]:=swap(rgb16dummy[0]);{store in memory array}
                img_loaded2[1,i,j]:=swap(rgb16dummy[1]);{store in memory array}
                img_loaded2[2,i,j]:=swap(rgb16dummy[2]);{store in memory array}
              end
              else
              if pfm then
              begin {PFM little-endian float 3x 32 bit colour}
                if range<0 then {little endian}
                begin
                  rgb32dummy:=fitsbufferRGB32[j];{RGB fits with naxis1=3, treated as 96 bits coded pixels}
                  img_loaded2[0,i,j]:=(rgb32dummy[0])*65535/(-range);{store in memory array}
                  img_loaded2[1,i,j]:=(rgb32dummy[1])*65535/(-range);{store in memory array}
                  img_loaded2[2,i,j]:=(rgb32dummy[2])*65535/(-range);{store in memory array}
                end
                else
                begin {PFM big-endian float 32 bit colour}
                  x_longword:=swapendian(fitsbuffer4[j*3]);
                  img_loaded2[0,i,j]:=x_single*65535/(range);
                  x_longword:=swapendian(fitsbuffer4[j*3+1]);
                  img_loaded2[1,i,j]:=x_single*65535/(range);
                  x_longword:=swapendian(fitsbuffer4[j*3+2]);
                  img_loaded2[2,i,j]:=x_single*65535/(range);
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
        memo.add(head1[j]); {add lines to empthy memo1}
  memo.add(head1[27]); {add end}

  update_integer(memo,'BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer(memo,'NAXIS   =',' / Number of dimensions                           ' ,head.naxis);{2 for mono, 3 for colour}
  update_integer(memo,'NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer(memo,'NAXIS2  =',' / length of y axis                               ' ,head.height);
  if head.naxis3<>1 then
    update_integer(memo,'NAXIS3  =',' / length of z axis (mostly colors)               ' ,head.naxis3);
  update_integer(memo,'DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer(memo,'DATAMAX =',' / Maximum data value                           ' ,round(head.datamax_org));

  if head.exposure<>0 then   update_float(memo,'EXPTIME =',' / duration of exposure in seconds                ',false ,head.exposure);
  if head.gain<>'' then    update_integer(memo,'GAIN    =',' / iso speed                                      ',strtoint(head.gain));

  if head.date_obs<>'' then update_text(memo,'DATE-OBS=',#39+head.date_obs+#39);
  if instrum<>''  then update_text(memo,'INSTRUME=',#39+INSTRUM+#39);

  update_text(memo,'BAYERPAT=',#39+'T'+#39+'                  / Unknown Bayer color pattern                  ');

  update_text(memo,'COMMENT 1','  Written by ASTAP, Astrometric STAcking Program. www.hnsky.org');
  memo.endupdate;
end;


function load_TIFFPNGJPEG(filen:string;light {load as light or dark/flat}: boolean; out head : theader;out img: image_array;memo:tstrings) : boolean;{load 8 or 16 bit TIFF, PNG, JPEG, BMP image}
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

  memo.beginupdate;
//  mainwindow.memo1.visible:=false;{stop visualising memo1 for speed. Will be activated in plot routine}
  memo.clear;{clear memo for new header}

  {set data}
  extend_type:=0;  {no extensions in the file, 1 is image, 2 is ascii_table, 3 bintable}
  nrbits:=16;
  head.datamin_org:=0;
  head.datamax_org:=$FFFF;
  bck.backgr:=head.datamin_org;{for case histogram is not called}
  cwhite:=head.datamax_org;


  head.width:=image.width;
  head.height:=image.height;
  setlength(img,head.naxis3,head.height,head.width);

  if head.naxis3=3 then
  begin
    For i:=0 to head.height-1 do
      for j:=0 to head.width-1 do
      begin
        img[0,head.height-1-i,j]:=image.Colors[j,i].red;
        img[1,head.height-1-i,j]:=image.Colors[j,i].green;
        img[2,head.height-1-i,j]:=image.Colors[j,i].blue;
      end;
  end
  else
  begin
    For i:=0 to head.height-1 do
      for j:=0 to head.width-1 do
        img[0,head.height-1-i,j]:=image.Colors[j,i].red;
  end;

  if tiff then
  begin
    descrip:=image.Extra['TiffImageDescription']; {restore full header in TIFF !!!}
  end;

  if copy(descrip,1,6)='SIMPLE' then {fits header included}
  begin
    memo.text:=descrip;
    read_keys_memo(light, head, memo);
    saved_header:=true;
  end
  else {no fits header in tiff file available}
  begin
    for j:=0 to 10 do {create an header with fixed sequence}
      if ((j<>5) or  (head.naxis3<>1)) then {skip head.naxis3 for mono images}
        memo.add(head1[j]); {add lines to empthy memo1}
    memo.add(head1[27]); {add end}
    if descrip<>'' then add_long_comment(memo,descrip);{add TIFF describtion}
  end;

  update_integer(memo,'BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer(memo,'NAXIS   =',' / Number of dimensions                           ' ,head.naxis);{2 for mono, 3 for colour}
  update_integer(memo,'NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer(memo,'NAXIS2  =',' / length of y axis                               ' ,head.height);

  update_integer(memo,'DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer(memo,'DATAMAX =',' / Maximum data value                             ' ,round(head.datamax_org));

  if saved_header=false then {saved header in tiff is not restored}
  begin
    JD2:=2415018.5+(FileDateToDateTime(fileage(filen))); {fileage ra, convert to Julian Day by adding factor. filedatatodatetime counts from 30 dec 1899.}
    head.date_obs:=JdToDate(jd2);
    update_text(memo,'DATE-OBS=',#39+head.date_obs+#39);{give start point exposures}
  end;

  update_text(memo,'COMMENT 1','  Written by ASTAP, Astrometric STAcking Program. www.hnsky.org');

  memo.endupdate;

  { Clean up! }
  image.Free;
  reader.free;
  unsaved_import:=true;{file is not available for astrometry.net}
  result:=true;{succes}

end;


procedure Tmainwindow.LoadFITSPNGBMPJPEG1Click(Sender: TObject);
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
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key application.processmessages;   { Show hourglass cursor, processmessages is for Linux }

    filename2:=opendialog1.filename;
    if opendialog1.FilterIndex<>4 then {<> preview FITS files, not yet loaded}
    {loadimage}
    load_image(filename2,img_loaded,head,mainwindow.memo1.lines,true,true {plot});{load and center}
    LoadFITSPNGBMPJPEG1filterindex:=opendialog1.filterindex;{remember filterindex}
    Screen.Cursor:=crDefault;
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


procedure get_background(colour: integer; img :image_array;calc_hist, calc_noise_level: boolean; out back : Tbackground); {get background and star level from peek histogram}
var
  i, pixels,max_range,above, fitsX, fitsY,counter,stepsize,width5,height5, iterations : integer;
  value,sd, sd_old,factor,factor2 : double;
begin
  if calc_hist then  get_hist(colour,img);{get histogram of img_loaded and his_total}

  back.backgr:=img[0,0,0];{define something for images containing 0 or 65535 only}

  {find peak in histogram which should be the average background}
  pixels:=0;
  max_range:=his_mean[colour]; {mean value from histogram}
  for i := 1 to max_range do {find peak, ignore value 0 from oversize}
    if histogram[colour,i]>pixels then {find colour peak}
    begin
      pixels:= histogram[colour,i];
      back.backgr:=i;
    end;

  {check alternative mean value}
  if his_mean[colour]>1.5*back.backgr {1.5* most common} then
  begin
    memo2_message(Filename2+', will use mean value '+inttostr(round(his_mean[colour]))+' as background rather then most common value '+inttostr(round(back.backgr)));
    back.backgr:=his_mean[colour];{strange peak at low value, ignore histogram and use mean}
  end;

  if calc_noise_level then  {find star level and background noise level}
  begin
    {calculate noise level}
    width5:=Length(img[0,0]);    {width}
    height5:=Length(img[0]); {height}
    stepsize:=round(height5/71);{get about 71x71=5000 samples. So use only a fraction of the pixels}
    if odd(stepsize)=false then stepsize:=stepsize+1;{prevent problems with even raw OSC images}


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
          value:=img[colour,fitsY,fitsX];
          if ((value<back.backgr*2) and (value<>0)) then {not an outlier, noise should be symmetrical so should be less then twice background}
          begin
            if ((iterations=0) or (abs(value-back.backgr)<=3*sd_old)) then {ignore outliers after first run}
            begin
              sd:=sd+sqr(value-back.backgr); {sd}
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
    back.noise_level:= sd;   {this noise level could be too high if no flat is applied. So for images where center is brighter then the corners.}


    {calculate star level}
    if ((nrbits=8) or (nrbits=24)) then max_range:= 255 else max_range:=65001 {histogram runs from 65000};{8 or 16 / -32 bit file}
    back.star_level:=0;
    back.star_level2:=0;
    i:=max_range;
    factor:=  6*strtoint2(stackmenu1.max_stars1.text,500);// Number of pixels to test. This produces about 700 stars at hfd=2.25
    factor2:=24*strtoint2(stackmenu1.max_stars1.text,500);// Number of pixels to test. This produces about 700 stars at hfd=4.5.
    above:=0;
    while ((back.star_level=0) and (i>back.backgr+1)) do {Assuming stars are dominant. Find star level. Level where factor pixels are above. If there a no stars this should be all pixels with a value 3.0 * sigma (SD noise) above background}
    begin
      dec(i);
      above:=above+histogram[colour,i];//sum of pixels above pixel level i
      if above>=factor then
        back.star_level:=i;//level found for stars with HFD=2.25.
    end;
    while ((back.star_level2=0) and (i>back.backgr+1)) do {Assuming stars are dominant. Find star level. Level where factor pixels are above. If there a no stars this should be all pixels with a value 3.0 * sigma (SD noise) above background}
    begin
      dec(i);
      above:=above+histogram[colour,i];//sum of pixels above pixel level i
      if above>=factor2 then
        back.star_level2:=i;//level found for stars with HFD=4.5.
    end;


    //memo2_message('Above count [pixels]'+inttostr(above));

    // Clip calculated star level:
    // 1) above 3.5*noise minimum, but also above background value when there is no noise so minimum is 1
    // 2) Below saturated level. So subtract 1 for saturated images. Otherwise no stars are detected}
    back.star_level:= max(max(3.5*sd,1 {1})  ,back.star_level-back.backgr-1 {2) below saturation}); //star_level is relative to background
    back.star_level2:=max(max(3.5*sd,1 {1})  ,back.star_level2-back.backgr-1 {2) below saturation}); //star_level is relative to background
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


procedure update_float(memo : tstrings;inpt,comment1:string;preserve_comment:boolean;x:double);{update keyword of fits header in memo}
 var
   s,aline,buf           : string;
   cnt,line_end,i,count,len   : integer;
begin
  //note this method is not used in astap_cli. There is no speed benefit there
  str(x:20,s);
  cnt:=pos(inpt,Memo.text);
  if cnt>0 then
  begin //insert;
    line_end:=posex(LineEnding,memo.text,cnt+1);//lines length could be different then 80 due to editing
    aline:=copy(memo.text,cnt,line_End - cnt );

    if ((preserve_comment) and (copy(aline,32,1)='/')) then
    begin
      delete(aline,11,20); //preserve comment
      insert(s,aline,11);
    end
    else
    begin
      delete(aline,11,120);  //delete all including above position 80
      aline:=aline+s+comment1; //line length correction will be done during saving FITS
    end;

    //replace, this is much faster then insert
    buf:=memo.text;

    for i:=0 to line_end-cnt-1 do
    begin
     if i<length(aline) then
       buf[cnt+i]:=aline[i+1]
     else
       buf[cnt+i]:=' ';
    end;
    memo.text:=buf;
    exit;
  end;
  {not found, add to the end}
  memo.insert(memo.Count-1,inpt+' '+s+comment1);
end;


procedure update_integer(memo:tstrings;inpt,comment1:string;x:integer);{update or insert variable in header}
var
  s,aline,buf           : string;
  cnt,line_end,i,count,len   : integer;
begin
  str(x:20,s);
  cnt:=pos(inpt,Memo.text);
  if cnt>0 then
  begin //insert;
    line_end:=posex(LineEnding,memo.text,cnt+1);//lines length could be different then 80 due to editing
    aline:=copy(memo.text,cnt,line_End - cnt );

    delete(aline,11,120);  //delete all including above position 80
    aline:=aline+s+comment1; //line length correction will be done during saving FITS

    //replace, this is much faster then insert
    buf:=memo.text;

    for i:=0 to line_end-cnt-1 do
    begin
     if i<length(aline) then
       buf[cnt+i]:=aline[i+1]
     else
       buf[cnt+i]:=' ';
    end;
    memo.text:=buf;
    exit;
  end;

  {not found, add at the correct position or at the end}
  if inpt='NAXIS1  =' then memo.insert(3,inpt+' '+s+comment1) else{PixInsight requires to have it on 3th place}
  if inpt='NAXIS2  =' then memo.insert(4,inpt+' '+s+comment1) else{PixInsight requires to have it on 4th place}
  if inpt='NAXIS3  =' then memo.insert(5,inpt+' '+s+comment1) else{PixInsight requires to have it on this place}
  memo.insert(memo.Count-1,inpt+' '+s+comment1);
end;


procedure add_integer(memo:tstrings;inpt,comment1:string;x:integer);{add integer variable to header}
 var
   s        : string;
begin
  str(x:20,s);
  memo.insert(memo.Count-1,inpt+' '+s+comment1);
end;


procedure update_generic(memo:tstrings;message_key,message_value,message_comment:string);{update header using text only}
var
   count1: integer;
begin
  if ((pos('HISTORY',message_key)=0) and (pos('COMMENT',message_key)=0)) then {allow multiple lines of history and comments}
  begin
    while length(message_value)<20 do message_value:=' '+message_value;{extend length, right aligned}
    while length(message_key)<8 do message_key:=message_key+' ';{make standard lenght of 8}

   count1:=memo.Count-1;
    while count1>=0 do {update keyword}
    begin
      if pos(message_key,memo[count1])>0 then {found}
      begin
        memo[count1]:=message_key+'= '+message_value+' / '+message_comment;
        exit;
      end;
      count1:=count1-1;
    end;
    {not found, add to the end}
    memo.insert(memo.Count-1,message_key+'= '+message_value+' / '+message_comment);
  end {no history of comment keyword}
  else
  memo.insert(memo.Count-1,message_key+' '+message_value+message_comment);
end;


procedure update_text(memo: tstrings;inpt,comment1:string);{update or insert text in header}
var
   count1: integer;
begin

  count1:=memo.Count-1;
  while count1>=0 do {update keyword}
  begin
    if pos(inpt,memo[count1])>0 then {found}
    begin
      memo[count1]:=inpt+' '+comment1;{text starting with char(39) should start at position 11 according FITS standard 4.0}
      //ll:=length(inpt+' '+comment1);
      exit;
    end;
    count1:=count1-1;
  end;
  {not found, add to the end}
  memo.insert(memo.Count-1,inpt+' '+comment1);
end;


procedure update_longstr(memo:tstrings; inpt,thestr:string);{update or insert long str including single quotes}
var
   count1,m,k: integer;
   ampersand : ansistring;
begin

  count1:=memo.Count-1;
  while count1>=0 do {delete keyword}
  begin
    if pos(inpt,memo[count1])>0 then {found, delete old keyword}
    begin
      memo.delete(count1);
      while pos('CONTINUE=',memo[count1])>0 do
        memo.delete(count1);
    end;
    count1:=count1-1;
  end;

  {keyword removed, add new to the end}
  m:=length(thestr);

  if m>68 then
  begin {write as multi record}
    memo.insert(memo.Count-1,inpt+' '+#39+copy(thestr,1,67)+'&'+#39);{text starting with char(39) should start at position 11 according FITS standard 4.0}
    k:=68;
    repeat {write in blocks of 67 char}
      if (m-k)>67 then ampersand:='&' else ampersand:='';
      memo.insert(memo.Count-1,'CONTINUE= '+#39+copy(thestr,k,67)+ampersand+#39);{text starting with char(39) should start at position 11 according FITS standard 4.0}
      inc(k,67);
    until k>=m;
  end
  else {write as single record}
  memo.insert(memo.Count-1,inpt+' '+#39+thestr+#39);

end;


procedure add_text(memo:tstrings;inpt,comment1:string);{add text to header memo}
begin
  memo.insert(Memo.Count-1,inpt+' '+copy(comment1,1,79-length(inpt)));  {add to the end. Limit to 80 char max as specified by FITS standard}
end;


procedure add_long_comment(memo:tstrings;descrip:string);{add long text to header memo. Split description over several lines if required}
var
   i,j :integer;
begin
  i:=1 ;
  j:=length(descrip);
  while i<j do
  begin
    memo.insert(Memo.Count-1,'COMMENT '+copy(descrip,I,72) );  {add to the end. Limit line length to 80}
    inc(i,72);
  end;
end;


procedure remove_solution(keep_wcs:boolean);//remove all solution key words efficient
var
  cnt,line_end : integer;
  buf : string;
     procedure remove(inpt : string);
     begin
       cnt:=pos(inpt,buf);
       if cnt>0 then
       begin //remove;
         line_end:=posex(LineEnding,mainwindow.Memo1.text,cnt+1);//lines length could be different then 80 due to editing
         delete(buf,cnt,line_end-cnt+length(LineEnding));//delete the line
       end;
     end;

begin

  buf:=mainwindow.Memo1.text;
  if keep_wcs=false then
  begin
    head.cd1_1:=0;//no WCS
    remove    ('CD1_1   =');
    remove    ('CD1_2   =');
    remove    ('CD2_1   =');
    remove    ('CD2_2   =');
  end;

  A_ORDER:=0;//no SIP
  remove    ('A_ORDER =');
  remove    ('A_0_0   =');
  remove    ('A_0_1   =');
  remove    ('A_0_2   =');
  remove    ('A_0_3   =');
  remove    ('A_1_0   =');
  remove    ('A_1_1   =');
  remove    ('A_1_2   =');
  remove    ('A_2_0   =');
  remove    ('A_2_1   =');
  remove    ('A_3_0   =');

  remove    ('B_ORDER =');
  remove    ('B_0_0   =');
  remove    ('B_0_1   =');
  remove    ('B_0_2   =');
  remove    ('B_0_3   =');
  remove    ('B_1_0   =');
  remove    ('B_1_1   =');
  remove    ('B_1_2   =');
  remove    ('B_2_0   =');
  remove    ('B_2_1   =');
  remove    ('B_3_0   =');

  remove    ('AP_ORDER=');
  remove    ('AP_0_0  =');
  remove    ('AP_0_1  =');
  remove    ('AP_0_2  =');
  remove    ('AP_0_3  =');
  remove    ('AP_1_0  =');
  remove    ('AP_1_1  =');
  remove    ('AP_1_2  =');
  remove    ('AP_2_0  =');
  remove    ('AP_2_1  =');
  remove    ('AP_3_0  =');

  remove    ('BP_ORDER=');
  remove    ('BP_0_0  =');
  remove    ('BP_0_1  =');
  remove    ('BP_0_2  =');
  remove    ('BP_0_3  =');
  remove    ('BP_1_0  =');
  remove    ('BP_1_1  =');
  remove    ('BP_1_2  =');
  remove    ('BP_2_0  =');
  remove    ('BP_2_1  =');
  remove    ('BP_3_0  =');

  remove    ('CROTA1  =');
  remove    ('CROTA2  =');


  mainwindow.Memo1.text:=buf;
end;

procedure remove_key(memo:tstrings;inpt:string; all:boolean);{remove key word in header. If all=true then remove multiple of the same keyword}
var
   count1: integer;
begin

  count1:=memo.Count-1;
  while count1>=0 do {update keyword}
  begin
    if pos(inpt,memo[count1])>0 then {found}
    begin
      memo.delete(count1);
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
var sin_dec1,cos_dec1,sin_dec2,cos_dec2,cos_sep,t:double;
begin
  sincos(dec1,sin_dec1,cos_dec1);{use sincos function for speed}
  sincos(dec2,sin_dec2,cos_dec2);
  cos_sep:=min(1.0,sin_dec1*sin_dec2+ cos_dec1*cos_dec2*cos(ra1-ra2));{min function to prevent run time errors for 1.000000000002.  For correct compiling use 1.0 instead of 1. See https://forum.lazarus.freepascal.org/index.php/topic,63511.0.html}
  sep:=arccos(cos_sep);
end;


function mode(img :image_array;ellipse:  boolean; colorm,  xmin,xmax,ymin,ymax,max1 {maximum background expected}:integer; out greylevels:integer):integer;{find the most common value of a local area and assume this is the best average background value}
var
   i,j,val,value_count,width3,height3  :integer;
   histogram : array of integer;
   centerX,centerY,a,b : double;
begin
  height3:=length(img[0]);{height}
  width3:=length(img[0,0]);{width}

  max1:=max1-10; //do not measure saturated pixels
  if xmin<0 then xmin:=0;
  if xmax>width3-1 then xmax:=width3-1;
  if ymin<0 then ymin:=0;
  if ymax>height3-1 then ymax:=height3-1;
  setlength(histogram,max1+1);
  for i := 0 to max1 do  histogram[i] := 0;{clear histogram}


  centerX:=(xmax+xmin)/2;
  centerY:=(ymax+ymin)/2;
  a:=(xmax-xmin-1)/2;
  b:=(ymax-ymin-1)/2;


  for i:=ymin to  ymax do
    begin
      for j:=xmin to xmax do
      begin
        if ((ellipse=false {use no ellipse}) or (sqr(j-centerX)/sqr(a) +sqr(i-centerY)/sqr(b)<1)) then // standard equation of the ellipse
        begin
          val:=round(img[colorM,i,j]);{get one color value}
          if ((val>=1) and (val<max1)) then {ignore black areas and bright stars}
          inc(histogram[val],1);{calculate histogram}
        end;
      end;{j}
    end; {i}
  result:=0; {for case histogram is empthy due to black area}


  greylevels:=0;
  value_count:=0;
  for i := 1 to max1 do {get most common but ignore 0}
  begin
    val:=histogram[i];
    if val<>0 then inc(greylevels);
    if  val>value_count then
    begin
      value_count:=val; {find most common in histogram}
      result:=i;
    end
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
      col:=round(img[colorM,i,j]);{get one color value}
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
  if head.naxis<>0 then
  begin
    if img_backup=nil then setlength(img_backup,size_backup+1);{create memory for size_backup backup images}
    inc(index_backup,1);
    if index_backup>size_backup then index_backup:=0;
    img_backup[index_backup].head_val:=head;
    img_backup[index_backup].header:=mainwindow.Memo1.Text;{backup fits header}
    img_backup[index_backup].filen:=filename2;{backup filename}

    img_backup[index_backup].img:=duplicate(img_loaded);//duplicate image fast

    mainwindow.Undo1.Enabled:=true;
  end;
end;


procedure restore_img;
var
   resized :boolean;
   old_width2,old_height2 : integer;
   fitsx,fitsy: integer;
begin
   if mainwindow.Undo1.Enabled=true then
  begin
    if img_backup=nil then exit;{for some rare cases}

    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key application.processmessages;   { Show hourglass cursor, processmessages is for Linux }

    old_width2:=head.width;
    old_height2:=head.height;

    head:=img_backup[index_backup].head_val;{restore main header values}
    resized:=((head.width<>old_width2) or ( head.height<>old_height2));
    mainwindow.Memo1.Text:=img_backup[index_backup].header;{restore fits header}
    filename2:=img_backup[index_backup].filen;{backup filename}
    mainwindow.caption:=filename2; //show old filename is case image was binned

    stackmenu1.test_pattern1.Enabled:=head.naxis3=1;{allow debayer if mono again}

    img_loaded:=duplicate(img_backup[index_backup].img);//duplicate image fast

    use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
    plot_fits(mainwindow.image1,resized,true);{restore image1}

    update_equalise_background_step(equalise_background_step-1);{update equalize menu}

    if head.naxis=0 {due to stretch draw} then update_menu(true); {update menu and set fits_file:=true;}

    dec(index_backup,1);{update index}
    if index_backup<0 then index_backup:=size_backup;

    if img_backup[index_backup].img=nil then
    begin
      mainwindow.Undo1.Enabled:=false;  //No more backups
    end
    else
    memo2_message('Restored backup index '+inttostr(index_backup));

    Screen.Cursor:=crDefault;
  end;
end;


procedure Tmainwindow.About1Click(Sender: TObject);
var
    about_message, about_message4, about_message5 : string;
var {################# initialised variables #########################}
  {$IfDef Darwin}// {MacOS}
    about_title  : string= 'About ASTAP for MacOS:';
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
  about_message5:='Build using Free Pascal compiler '+inttoStr(FPC_version)+'.'+inttoStr(FPC_RELEASE)+'.'+inttoStr(FPC_patch)+', Lazarus IDE '+lcl_version+', LCL widgetset '+ LCLPlatformDisplayNames[WidgetSet.LCLPlatform]+'.'+
  #13+#10+
  #13+#10+
  'Application path '+application_path;
 {$ELSE} {delphi}
  about_message5:='';
 {$ENDIF}
  if ord(database2[0])<>0 then
    about_message5:=about_message5+
    #13+#10+
    #13+#10+
    'Active star database:'+copy(database2,1,108)+ {primary star database. Do not display last byte (110) used for record type. Byte 109 is used for maximum magnitude}
    #13+#10;

  about_message:=
  'ASTAP version '+astap_version+', '+about_message4+
  #13+#10+
  #13+#10+
  #13+#10+
  'Astrometric Stacking Program, astrometric solver and FITS image viewer.'+
  ' This program can view, measure, "astrometric solve" and stack deep sky images.'+
  ' It uses an internal star matching routine or an internal astrometric solving routine for image alignment.'+
  ' For RAW file conversion it uses the external programs Dcraw or LibRaw.'+
  #13+#10+
  #13+#10+about_message5+
  #13+#10+
  #13+#10+'Send an e-mail if you like this free program. Feel free to distribute!'+
  #13+#10+
  #13+#10+'© 2018, 2024 by Han Kleijn. License MPL 2.0, Webpage: www.hnsky.org';

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
        Screen.Cursor:=crDefault;
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
//  if mouse_enter=0 then mouse_enter:=1;
end;


procedure Tmainwindow.image_cleanup1Click(Sender: TObject);
begin
  plot_fits(mainwindow.image1,false,true);
end;


procedure Tmainwindow.deepsky_overlay1Click(Sender: TObject);
begin
  load_deep;{load the deepsky database once. If loaded no action}
  plot_deepsky(false,8);
end;


procedure bin_X2X3X4(var img :image_array; var head : theader;memo:tstrings; binfactor:integer);{bin img_loaded 2x or 3x}
  var fitsX,fitsY,k, w,h  : integer;
      img_temp2 : image_array;
      fact      : string;

begin
  binfactor:=min(4,binfactor);{max factor is 4}
  w:=trunc(head.width/binfactor);  {half size & cropped. Use trunc for image 1391 pixels wide like M27 test image. Otherwise exception error}
  h:=trunc(head.height/binfactor);
  setlength(img_temp2,head.naxis3,h,w);
  if binfactor=2 then
  begin
    for k:=0 to head.naxis3-1 do
      for fitsY:=0 to h-1 do
         for fitsX:=0 to w-1  do
         begin
           img_temp2[k,fitsY,fitsX]:=(img[k,fitsY*2,fitsX*2]+
                                      img[k,fitsY*2 +1,fitsX*2]+
                                      img[k,fitsY*2   ,fitsX*2+1]+
                                      img[k,fitsY*2 +1,fitsX*2+1])/4;
           end;
  end
  else
  if binfactor=3 then
  begin {bin3x3}
    for k:=0 to head.naxis3-1 do
      for fitsY:=0 to h-1 do
         for fitsX:=0 to w-1  do
         begin
           img_temp2[k,fitsY,fitsX]:=(img[k,fitsY*3   ,fitsX*3  ]+
                                      img[k,fitsY*3   ,fitsX*3+1]+
                                      img[k,fitsY*3   ,fitsX*3+2]+
                                      img[k,fitsY*3 +1,fitsX*3  ]+
                                      img[k,fitsY*3 +1,fitsX*3+1]+
                                      img[k,fitsY*3 +1,fitsX*3+2]+
                                      img[k,fitsY*3 +2,fitsX*3  ]+
                                      img[k,fitsY*3 +2,fitsX*3+1]+
                                      img[k,fitsY*3 +2,fitsX*3+2])/9;
           end;
  end
  else
  begin {bin4x4}
    for k:=0 to head.naxis3-1 do
      for fitsY:=0 to h-1 do
         for fitsX:=0 to w-1  do
         begin
           img_temp2[k,fitsY,fitsX]:=(img[k,fitsY*4   ,fitsX*4  ]+
                                      img[k,fitsY*4   ,fitsX*4+1]+
                                      img[k,fitsY*4   ,fitsX*4+2]+
                                      img[k,fitsY*4   ,fitsX*4+3]+
                                      img[k,fitsY*4 +1,fitsX*4  ]+
                                      img[k,fitsY*4 +1,fitsX*4+1]+
                                      img[k,fitsY*4 +1,fitsX*4+2]+
                                      img[k,fitsY*4 +1,fitsX*4+3]+
                                      img[k,fitsY*4 +2,fitsX*4  ]+
                                      img[k,fitsY*4 +2,fitsX*4+1]+
                                      img[k,fitsY*4 +2,fitsX*4+2]+
                                      img[k,fitsY*4 +2,fitsX*4+3]+
                                      img[k,fitsY*4 +3,fitsX*4  ]+
                                      img[k,fitsY*4 +3,fitsX*4+1]+
                                      img[k,fitsY*4 +3,fitsX*4+2]+
                                      img[k,fitsY*4 +3,fitsX*4+3])/16;
           end;
  end;
  img:=img_temp2;
  head.width:=w;
  head.height:=h;
  img_temp2:=nil;

  memo.BeginUpdate;

  update_integer(memo,'NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer(memo,'NAXIS2  =',' / length of y axis                               ' ,head.height);

  if head.crpix1<>0 then begin head.crpix1:=head.crpix1/binfactor; update_float(memo,'CRPIX1  =',' / X of reference pixel                           ',false ,head.crpix1);end;
  if head.crpix2<>0 then begin head.crpix2:=head.crpix2/binfactor; update_float(memo,'CRPIX2  =',' / Y of reference pixel                           ',false ,head.crpix2);end;

  if head.cdelt1<>0 then begin head.cdelt1:=head.cdelt1*binfactor; update_float(memo,'CDELT1  =',' / X pixel size (deg)                             ',false ,head.cdelt1);end;
  if head.cdelt2<>0 then begin head.cdelt2:=head.cdelt2*binfactor; update_float(memo,'CDELT2  =',' / Y pixel size (deg)                             ',false ,head.cdelt2);end;

  if head.cd1_1<>0 then
  begin
    head.cd1_1:=head.cd1_1*binfactor;
    head.cd1_2:=head.cd1_2*binfactor;
    head.cd2_1:=head.cd2_1*binfactor;
    head.cd2_2:=head.cd2_2*binfactor;
    update_float(memo,'CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_1);
    update_float(memo,'CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_2);
    update_float(memo,'CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_1);
    update_float(memo,'CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_2);
  end;
  head.XBINNING:=head.XBINNING*binfactor;
  head.YBINNING:=head.YBINNING*binfactor;
  update_integer(memo,'XBINNING=',' / Binning factor in width                         ' ,round(head.XBINNING));
  update_integer(memo,'YBINNING=',' / Binning factor in height                        ' ,round(head.yBINNING));
  if head.XPIXSZ<>0 then
  begin
    head.XPIXSZ:=head.XPIXSZ*binfactor;
    head.YPIXSZ:=head.YPIXSZ*binfactor;
    update_float(memo,'XPIXSZ  =',' / Pixel width in microns (after binning)          ' ,false,head.XPIXSZ);
    update_float(memo,'YPIXSZ  =',' / Pixel height in microns (after binning)         ' ,false,head.YPIXSZ);
    update_float(memo,'PIXSIZE1=',' / Pixel width in microns (after binning)          ' ,false,head.XPIXSZ);
    update_float(memo,'PIXSIZE2=',' / Pixel height in microns (after binning)         ' ,false,head.YPIXSZ);
  end;
  fact:=inttostr(binfactor);
  fact:=fact+'x'+fact;
  add_text(memo,'HISTORY   ','BIN'+fact+' version of '+filename2);
  memo.EndUpdate;
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


Function INT_IEEE4_reverse(x: double):longword;{adapt intel floating point to non-intel float}
var
  value1   : single;
  lw       : longword absolute value1;
begin
  value1:=x;
  result:=swapendian(lw);
end;


function save_fits(img: image_array;memo:tstrings;filen2:ansistring;type1:integer;override2:boolean): boolean;{save to 8, 16 OR -32 BIT fits file}
var
  TheFile4 : tfilestream;
  I,j,k,bzero2, progressC,progress_value,dum, remain,minimum,maximum,dimensions, colours5,height5,width5 : integer;
  dd : single;
  line0                : ansistring;
  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}
  rgb  : byteX3;{array [0..2] containing r,g,b colours}
begin
  result:=false;
  if img=nil then
  begin
    memo2_message('Error,  no image');
    exit;
  end;
  {get dimensions directly from array}
  colours5:=length(img);{nr colours}
  width5:=length(img[0,0]);{width}
  height5:=length(img[0]);{height}
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
      memo[0]:= head1[0]; {replace XTENSION= with SIMPLE = }
    end;
  end;
  filename2:=filen2;
  {$IFDEF fpc}
  progress_indicator(0,'');
  {$else} {delphi}
  mainwindow.taskbar1.progressstate:=TTaskBarProgressState.Normal;
  mainwindow.taskbar1.progressvalue:=0; {show progress}

  {$endif}

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}{application.processmessages;}{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  try
    TheFile4:=tfilestream.Create(filen2, fmcreate );
    try
      progressC:=0;

     {update FITs header}
      if type1<>24 then {standard FITS}
      begin
        update_integer(memo,'BITPIX  =',' / Bits per entry                                 ' ,type1); {16 or -32}
        update_integer(memo,'NAXIS   =',' / Number of dimensions                           ' ,dimensions);{number of dimensions, 2 for mono, 3 for colour}
        update_integer(memo,'NAXIS1  =',' / length of x axis                               ' ,width5);
        update_integer(memo,'NAXIS2  =',' / length of y axis                               ' ,height5);
        if colours5<>1 then {color image}
          update_integer(memo,'NAXIS3  =',' / length of z axis (mostly colors)               ' ,colours5)
          else
          remove_key(memo,'NAXIS3  ',false{all});{remove key word in header. Some program don't like naxis3=1}

        if type1=16 then bzero2:=32768 else bzero2:=0;

        update_integer(memo,'BZERO   =',' / physical_value = BZERO + BSCALE * array_value  ' ,bzero2);
        update_integer(memo,'BSCALE  =',' / physical_value = BZERO + BSCALE * array_value  ' ,1);{data is scaled to physical value in the load_fits routine}
        if type1<>8 then
        begin
          update_integer(memo,'DATAMIN =',' / Minimum data value                             ' ,round(head.datamin_org));
          update_integer(memo,'DATAMAX =',' / Maximum data value                             ' ,round(head.datamax_org));
          update_integer(memo,'CBLACK  =',' / Black point used for displaying image.         ' ,round(bck.backgr) ); {2019-4-9}
          update_integer(memo,'CWHITE  =',' / White point used for displaying the image.     ' ,round(cwhite) );
        end
        else
        begin {in most case reducing from 16 or flat to 8 bit}
          update_integer(memo,'DATAMIN =',' / Minimum data value                             ' ,0);
          update_integer(memo,'DATAMAX =',' / Maximum data value                             ' ,255);
        end;
      end {update existing header}
      else
      begin {special 8 bit with three colors combined in 24 bit}
        {update FITs header}
        update_integer(memo,'BITPIX  =',' / Bits per entry                                 ' ,8);
        update_integer(memo,'NAXIS   =',' / Number of dimensions                           ' ,dimensions);{number dimensions, 2 for mono, 3 for color}
        update_integer(memo,'NAXIS1  =',' / length of x axis                               ' ,3);
        update_integer(memo,'NAXIS2  =',' / length of y axis                               ' ,width5);
        update_integer(memo,'NAXIS3  =',' / length of z axis (mostly colors)               ' ,height5);
        update_integer(memo,'DATAMIN =',' / Minimum data value                             ' ,0);
        update_integer(memo,'DATAMAX =',' / Maximum data value                             ' ,255);
        update_integer(memo,'BZERO   =',' / physical_value = BZERO + BSCALE * array_value  ' ,0);
        update_integer(memo,'BSCALE  =',' / physical_value = BZERO + BSCALE * array_value  ' ,1);{data is scaled to physical value in the load_fits routine}
        {update existing header}
      end;

      {write memo1 header to file}
      for i:=0 to 79 do empthy_line[i]:=#32;{space}
      i:=0;
      repeat
         if i<memo.count then
         begin
           line0:=memo[i];{line0 is an ansistring. According the standard the FITS header should only contain ASCII charactors between decimal 32 and 126.}
           while length(line0)<80 do line0:=line0+' ';{extend to length 80 if required}
           strpcopy(aline,(copy(line0,1,80)));{copy 80 and not more}
           thefile4.writebuffer(aline,80);{write updated header from memo1}
         end
         else
         thefile4.writebuffer(empthy_line,80);{write empthy line}
         inc(i);
      until ((i>=memo.count) and (frac(i*80/2880)=0)); {write multiply records 36x80 or 2880 bytes}

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
            dd:=img[k,i,j];{save all colors}
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
              dd:=img[k,i,j];{save all colors}
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
            dum:=max(0,min(65535,round(img[k,i,j]))) - bzero2;{limit data between 0 and 65535 and shift it to -32768.. 32767}
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
            fitsbuffer4[j]:=INT_IEEE4_reverse(img[k,i,j]);{in FITS file hi en low bytes are swapped}
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


    finally
      TheFile4.free;
    end;

  unsaved_import:=false;{file is available for astrometry.net}
  result:=true;
  except
    memo2_message('█ █ █ █ █ █ Write error!!  █ █ █ █ █ █');
  end;
  mainwindow.image1.stretch:=true;
  Screen.Cursor:=crDefault;
  {$IFDEF fpc}
  progress_indicator(-100,'');{back to normal}
  {$else} {delphi}
  mainwindow.taskbar1.progressstate:=TTaskBarProgressState.None;
  {$endif}
end;



function binX2X3_file(binfactor:integer) : boolean; {converts filename2 to binx2 or bin3 version}
var
  headX : theader;
  img_temp: image_array;
begin
  result:=false;
  if load_fits(filename2,true {light},true {load data},true {update memo for naxis1,...},0,memox,headX,img_temp)=false then exit;
  bin_X2X3X4(img_temp,headX,memox,binfactor);{bin img_loaded 2x or 3x}
  remove_key(memox,'BAYERPAT=',false{all});//do not allow debayer anymore

  if fits_file_name(filename2) then
  begin
    if binfactor=2 then filename2:=ChangeFileExt(Filename2,'_bin2x2.fit')
                   else filename2:=ChangeFileExt(Filename2,'_bin3x3.fit');
    result:=save_fits(img_temp,memox,filename2,nrbits,true)
  end
  else
  begin
    if binfactor=2 then filename2:=ChangeFileExt(Filename2,'_bin2x2.tif')
                   else filename2:=ChangeFileExt(Filename2,'_bin3x3.tif');
    result:=save_tiff16(img_temp,memox,filename2,false {flip H},false {flip V});
  end;
end;


procedure Tmainwindow.bin2x2Click(Sender: TObject);
var
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
  OpenDialog1.Options:= [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter:=dialog_filter_fits_tif;
  esc_pressed:=false;

  if OpenDialog1.Execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}
    try { Do some lengthy operation }
       with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        progress_indicator(100*i/(count),' Binning');{show progress}
        filename2:=Strings[I];
        {load fits}
        Application.ProcessMessages;
        if ((esc_pressed) or
            (binX2X3_file(binfactor)=false) {do the binning}) then break;
      end;
      finally
      if dobackup then restore_img;{for the viewer}
      progress_indicator(-100,'');{progresss done}
      Screen.Cursor:=crDefault;  { Always restore to normal }
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
   img_temp : image_array;
begin
  if head.naxis=0 then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    backup_img;
    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;
    setlength(img_temp,head.naxis3,stopY-startY,stopX-startX);
    for k:=0 to head.naxis3-1 do {do all colors}
    begin
      for fitsY:=startY to stopY-1 do
      for fitsX:=startX to stopX-1 do
      begin
        begin
          img_temp[k,fitsY-startY,fitsX-startX]:=img_loaded[k,fitsY,fitsX];{copy the area of interest to img_temp}
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
          img_loaded[k,fitsY,fitsX]:=img_temp[k,fitsY-startY,fitsX-startX];{copy the area of interest back}
        end;
      end;
    end;{k color}

    img_temp:=nil;{clean memory}
    plot_fits(mainwindow.image1,false,true);
    Screen.Cursor:=crDefault;
  end{fits file}
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
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  load_hyperleda;   { Load the database once. If loaded no action}
  plot_deepsky(false,8);{plot the deep sky object on the image}
  Screen.Cursor:=crDefault;
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
   center_x,center_y,a,b : double;

begin
  if ((head.naxis3<>3) or (head.naxis=0)) then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    backup_img;

    center_x:=(startx+stopX-1)/2;
    center_y:=(startY+stopY-1)/2;
    a:=(stopX-1-startx)/2;
    b:=(stopY-1-startY)/2;

    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

    for fitsY:=startY to stopY-1 do
    for fitsX:=startX to stopX-1 do
    begin
      if sqr(fitsX-center_X)/sqr(a) +sqr(fitsY-center_Y)/sqr(b)<1 then // standard equation of the ellipse
      begin
        val:=(img_loaded[0,fitsY,fitsX]+img_loaded[1,fitsY,fitsX]+img_loaded[2,fitsY,fitsX])/3;
        img_loaded[0,fitsY,fitsX]:=val;
        img_loaded[1,fitsY,fitsX]:=val;
        img_loaded[2,fitsY,fitsX]:=val;
      end;
    end;
    plot_fits(mainwindow.image1,false,true);
    Screen.Cursor:=crDefault;
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


procedure celestial_to_pixel(head: theader;ra,dec: double; out fitsX,fitsY: double);{ra,dec to fitsX,fitsY}
var
  SIN_dec,COS_dec,
  SIN_dec_ref,COS_dec_ref,det,SIN_delta_ra,COS_delta_ra, H, xi,eta,u0,v0 : double;
begin
  {5. Conversion (RA,DEC) -> x,y image}
  sincos(dec,SIN_dec,COS_dec);{sincos is faster then separate sin and cos functions}
  sincos(head.dec0,SIN_dec_ref,COS_dec_ref);{}

  sincos(ra-head.ra0,SIN_delta_ra,COS_delta_ra);

  H := SIN_dec*sin_dec_ref + COS_dec*COS_dec_ref*COS_delta_ra;
  xi := (COS_dec*SIN_delta_ra / H)*180/pi;
  eta:= ((SIN_dec*COS_dec_ref - COS_dec*SIN_dec_ref*COS_delta_ra ) / H)*180/pi;

  det:=head.cd2_2*head.cd1_1 - head.cd1_2*head.cd2_1;

  u0:= - (head.cd1_2*eta - head.cd2_2*xi) / det;
  v0:= + (head.cd1_1*eta - head.cd2_1*xi) / det;


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


{procedure pixel_to_celestial_astap(head : theader; fitsx,fitsy : double; out ra,dec  : double);
var
   u2,v2,xi,eta,delta, gamma, sindec0,cosdec0  : double;
begin
  u2:=fitsx-head.crpix1;
  v2:=fitsy-head.crpix2;
  xi :=(head.cd1_1*(u2)+head.cd1_2*(v2))*pi/180;
  eta:=(head.cd2_1*(u2)+head.cd2_2*(v2))*pi/180;

  sincos(head.dec0,sindec0,cosdec0);
  delta:=cosdec0-eta*sindec0;
  ra:=head.ra0+arctan2(xi,delta); //atan2 is required for images containing celestial pole
  dec:=arctan((sindec0+eta*cosdec0)/sqrt(sqr(xi)+sqr(delta)));

  if ra<0 then ra:=ra+pi*2;
  if ra>pi*2 then ra:=ra-pi*2;
end; }


{procedure pixel_to_celestial_siril(head : theader; fitsx,fitsy : double; out ra,dec  : double);
var
   u2,v2,xi,eta,delta,gamma,delta_ra,sindec0,cosdec0  : double;
begin
  u2:=fitsx-head.crpix1;
  v2:=fitsy-head.crpix2;

  xi :=(head.cd1_1*(u2)+head.cd1_2*(v2))*pi/180;
  eta:=(head.cd2_1*(u2)+head.cd2_2*(v2))*pi/180;

  sincos(head.dec0,sindec0,cosdec0);
  ra:=head.ra0 + arctan2(xi,cosdec0-eta*sindec0);
  dec:=arcSIN((sindec0 + eta * cosdec0) / SQRT( 1 + sqr(xi) + sqr(eta)));


  if ra<0 then ra:=ra+pi*2;
  if ra>pi*2 then ra:=ra-pi*2;
end; }


{procedure pixel_to_celestial_tatum(head : theader; fitsx,fitsy : double; out ra,dec  : double);
var
   u2,v2,xi,eta,delta_ra, gamma,sindec0,cosdec0  : double;
begin
  u2:=fitsx-head.crpix1;
  v2:=fitsy-head.crpix2;
  xi :=(head.cd1_1*(u2)+head.cd1_2*(v2))*pi/180;
  eta:=(head.cd2_1*(u2)+head.cd2_2*(v2))*pi/180;


  sincos(head.dec0,sindec0,cosdec0);
  delta_ra:= arctan2(xi,COSdec0-eta*SINdec0);
  ra:=head.ra0+delta_ra;
  dec:=arctan2((eta*cosdec0+cosdec0)*SIN( delta_ra),xi);

  if ra<0 then ra:=ra+pi*2;
  if ra>pi*2 then ra:=ra-pi*2;
end;
}


procedure pixel_to_celestial(head : theader; fitsx,fitsy : double; formalism : integer; out ra,dec  : double) {fitsX, Y to ra,dec};
var
   fits_unsampledX, fits_unsampledY, sindec0,cosdec0 :double;
   u,v,u2,v2             : double;
   xi,eta,delta,gamma  : double;

//   ra1,dec1,ra2,dec2,ra3,dec3 : double;
//   i : integer;

begin
  RA:=0;DEC:=0;{for case wrong index or head.cd1_1=0}
  {DSS polynom solution}
  if formalism=2 then {DSS survey}
  begin
  { Convert from image subsampled pixels position to unsampled pixel position }
    fits_unsampledX:=subsamp*(fitsX-0.5)+0.5;
    fits_unsampledY:=subsamp*(fitsY-0.5)+0.5;
                  //{fits (1,1)+subsamp of 2x =>(eqv unsampled 1,5,1,5)
                  //(fits (2,2)+subsamp of 2x =>(eqv unsampled 3,5,3,5)
                  //(fits 1,1)+subsamp of 4x=>(eqv unsampled 2.5,2.5)
                  //(fits 2,2)+subsamp of 4=>(eqv unsampled 6.5,6.5)
    dsspos(fits_unsampledX , fits_unsampledY, ra, dec );
  end
  else
  if head.cd1_1<>0 then
  begin //wcs
    if ((formalism=1) and (a_order>=2)) then {SIP, Simple Imaging Polynomial}
    begin //apply SIP correction to pixels.
      u:=fitsx-head.crpix1;
      v:=fitsy-head.crpix2;
      u2:=u + a_0_0+ a_0_1*v + a_0_2*v*v + a_0_3*v*v*v + a_1_0*u + a_1_1*u*v + a_1_2*u*v*v + a_2_0*u*u + a_2_1*u*u*v + a_3_0*u*u*u ; {SIP correction for second or third order}
      v2:=v + b_0_0+ b_0_1*v + b_0_2*v*v + b_0_3*v*v*v + b_1_0*u + b_1_1*u*v + b_1_2*u*v*v + b_2_0*u*u + b_2_1*u*u*v + b_3_0*u*u*u ; {SIP correction for second or third order}
    end
    else
    begin
      u2:=fitsx-head.crpix1;
      v2:=fitsy-head.crpix2;
    end; {mainwindow.Polynomial1.itemindex=0}

    //for formalism 0 and 1
    xi :=(head.cd1_1*(u2)+head.cd1_2*(v2))*pi/180;
    eta:=(head.cd2_1*(u2)+head.cd2_2*(v2))*pi/180;

    sincos(head.dec0,sindec0,cosdec0);
    delta:=cosdec0-eta*sindec0;
    ra:=head.ra0+arctan2(xi,delta); {atan2 is required for images containing celestial pole}
    dec:=arctan((sindec0+eta*cosdec0)/sqrt(sqr(xi)+sqr(delta)));
    if ra<0 then ra:=ra+pi*2;
    if ra>pi*2 then ra:=ra-pi*2;
  end; //WCS

{   memo2_message('start');
  for i:=0 to 180000000 do
    pixel_to_celestial_astap(head,fitsx,fitsy, ra1,dec1 );
  memo2_message('existing ready');

  for i:=0 to 180000000 do
   pixel_to_celestial_astap(head,fitsx,fitsy, ra1,dec1 );
 memo2_message('existing atan2 ready');


 for i:=0 to 180000000 do
    pixel_to_celestial_siril(head,fitsx,fitsy, ra2,dec2 );
  memo2_message('Siril method ready ');

  for i:=0 to 180000000 do
    pixel_to_celestial_tatum(head,fitsx,fitsy, ra3,dec3 );
  memo2_message('Tatum method ready ');


  beep;}
end;


function decode_string(data0: string; out ra4,dec4 : double):boolean;{convert a string to position}
var
  error1,error2,degrees   : boolean;
  data1,ra_text,dec_text  : string;
  pos1,pos2,pos3,pos4,pos5,pos6,i :integer;
begin
  {Simbad sirius    06 45 08.917 -16 42 58.02      }
  {Orion   5h 35.4m; Declination_symbol1: 5o 27′ south    }
  {http://www.rochesterastronomy.org/supernova.html#2020ue
  R.A. = 00h52m33s.814, Decl. = +80°39'37".93 }

  result:=false; {assume failure}
  data0:=uppercase(data0);
  degrees:=pos('D',data0)>0;{degrees ?}
  data0:=StringReplace(data0,'S.','.',[]); {for 00h52m33s.814}
  data0:=StringReplace(data0,'".','.',[]); {for +80°39'37".93}
  data0:=StringReplace(data0,'R.A.','',[]); {remove dots from ra}
  data0:=StringReplace(data0,'DECL.','',[]);{remove dots from decl}

  if ((data0='c') or (data0='C')) then {place marker in middle}
  begin
    pixel_to_celestial(head,(head.width+1)/2,(head.height+1)/2,mainwindow.Polynomial1.itemindex,ra4,dec4);{calculate the center position also for solutions with the reference pixel somewhere else}
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

    ra_text_to_radians ( ra_text ,ra4,error1); {convert ra text to head.ra0 in radians}
    dec_text_to_radians( dec_text ,dec4,error2); {convert dec text to head.dec0 in radians}
  end;
  result:=((error1=false) and (error2=false));
end;


procedure place_marker_radec(shape: tshape; ra,dec:double);{place marker in image based on measured ra, dec. Is used when loading an new image}
var
  fitsx,fitsy : double;
  data1,sipwcs  : string;
begin
  if ((head.naxis=0) or (head.cd1_1=0) or (shape.visible=false)) then exit;{no solution to place marker}

//  shape.visible:=true;

  celestial_to_pixel(head, ra,dec, fitsX,fitsY); {ra,dec to fitsX,fitsY}

  //shape specific. In variables for zooming
  if tshape(shape)=tshape(mainwindow.shape_var1) then
  begin
    shape_var1_fitsX:=fitsX;//store for zooming
    shape_var1_fitsY:=fitsY;
    show_marker_shape(shape,5 {circle},20,20,10,shape_var1_fitsX, shape_var1_fitsY);
  end
  else
  if tshape(shape)=tshape(mainwindow.shape_check1) then
  begin
    shape_check1_fitsX:=fitsX;//store for zooming
    shape_check1_fitsY:=fitsY;
    show_marker_shape(shape,5 {circle},20,20,10,shape_check1_fitsX, shape_check1_fitsY);
  end
  else
  if tshape(shape)=tshape(mainwindow.shape_star3) then
  begin
    shape_star3_fitsX:=fitsX;//store for zooming
    shape_star3_fitsY:=fitsY;
    show_marker_shape(shape,5 {circle},20,20,10,shape_star3_fitsX, shape_star3_fitsY);
  end
  else
  if tshape(shape)=tshape(mainwindow.shape_marker3) then
  begin
    shape_marker3_fitsX:=fitsX;//store for zooming
    shape_marker3_fitsY:=fitsY;
    show_marker_shape(mainwindow.shape_marker3,0 {rectangle},50,50,10,shape_marker3_fitsX, shape_marker3_fitsY);
  end
  else
  if tshape(shape)=tshape(mainwindow.shape_var2) then
  begin
    shape_var2_fitsX:=fitsX;//store for zooming
    shape_var2_fitsY:=fitsY;
    show_marker_shape( shape,9 {no change},50,50,10,shape_var2_fitsX, shape_var2_fitsY);
  end
  else
  if tshape(shape)=tshape(mainwindow.shape_check2) then
  begin
    shape_check2_fitsX:=fitsX;
    shape_check2_fitsY:=fitsY;
    show_marker_shape(shape,9 {no change},50,50,10,shape_check2_fitsX, shape_check2_fitsY);
  end;
  shape.pen.style:=psSolid;//for photometry, resturn from psClear;
end;

function place_marker3(data0: string): boolean;{place ra,dec marker in image}
var
  ra_new,dec_new, fitsx,fitsy : double;
  data1,sipwcs  : string;
begin
  if ((head.naxis=0) or (head.cd1_1=0) or (mainwindow.shape_marker3.visible=false)) then exit;{no solution to place marker}

  if decode_string(data0,ra_new,dec_new) then
  begin
    result:=true;
    mainwindow.shape_marker3.visible:=true;
    place_marker_radec(mainwindow.shape_marker3,ra_new,dec_new);{place ra,dec marker in image}
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
var
      dra,ddec,
      cdelt1_a, det,x,y :double;
      flipV, flipH,xpos,ypos,leng : integer;
begin
  with mainwindow.image_north_arrow1 do
  begin
    {clear}
    canvas.brush.color:=clmenu;
    Canvas.FillRect(rect(0,0,width,height));
    xpos:=width div 2;{position arrow}
    ypos:=height div 2;
    leng:=xpos-1;{half of length}

    if ((head.naxis=0) or (head.cd1_1=0)) then {No solution, remove rotation and flipped indication and exit}
    begin
      mainwindow.rotation1.caption:='';// clear rotation indication
      mainwindow.flip_indication1.Visible:=false;// remove any flipped indication
      exit;
    end;

    mainwindow.rotation1.caption:=floattostrf(head.crota2, FFfixed, 0, 2)+'°';{show rotation}
    mainwindow.flip_indication1.Visible:=head.cd1_1*head.cd2_2 - head.cd1_2*head.cd2_1 >0;// flipped image?

    Canvas.Pen.Color := clred;

    if mainwindow.flip_horizontal1.checked then flipH:=-1 else flipH:=+1;
    if mainwindow.flip_vertical1.checked then flipV:=-1 else flipV:=+1;

    cdelt1_a:=sqrt(head.cd1_1*head.cd1_1+head.cd1_2*head.cd1_2);{length of one pixel step to the north}

    moveToex(Canvas.handle,round(xpos),round(ypos),nil);
    det:=head.cd2_2*head.cd1_1-head.cd1_2*head.cd2_1;{this result can be negative !!}
    dRa:=0;
    dDec:=cdelt1_a*leng;
    x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
    y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;

    lineTo(Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow line}

    dRa:=cdelt1_a*-3;
    dDec:=cdelt1_a*(leng-8);
    x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
    y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
    lineTo(Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}
    dRa:=cdelt1_a*+3;
    dDec:=cdelt1_a*(leng-8);
    x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
    y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
    lineTo(Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}
    dRa:=0;
    dDec:=cdelt1_a*leng;
    x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
    y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
    lineTo(Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}


    moveToex(Canvas.handle,round(xpos),round(ypos),nil);{east pointer}
    dRa:= cdelt1_a*leng/3;
    dDec:=0;
    x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
    y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
    lineTo(Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {east pointer}
  end;
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
  if ((head.naxis=0) or (head.cd1_1=0) or (mainwindow.northeast1.checked=false)) then exit;

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
  dDec:=cdelt1_a*(leng-8*wd);
  x := (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y := (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}

  dRa:=cdelt1_a*+3*wd;
  dDec:=cdelt1_a*(leng-8*wd);
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
    celestial_to_pixel(head, ra_mount,dec_mount, fitsX,fitsY);{ra,dec to fitsX,fitsY}

    shape_marker4_fitsX:=FITSX;
    shape_marker4_fitsY:=FITSY;
    show_marker_shape(mainwindow.shape_marker4,2 {activate},40,40,30{minimum},shape_marker4_fitsX, shape_marker4_fitsY);
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

  if ((head.naxis=0) or (head.cd1_1=0) or (mainwindow.mountposition1.checked=false)) then
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
  dDec:=cdelt1_a*(leng-16*wd);
  x :=-1+ (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
  y :=-1+ (head.cd1_1*dDEC - head.cd2_1*dRA) / det;
  lineTo(mainwindow.image1.Canvas.handle,round(xpos-x*flipH),round(ypos-y*flipV)); {arrow pointer}

  dRa:=cdelt1_a*+6*wd;
  dDec:=cdelt1_a*(leng-16*wd);
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


procedure plot_star_profile(cX,cY : integer);
const resolution=6;
      rs=68 div 2;//half size image_north
      qrs=rs div resolution;
var
  i, j,distance,hh,diam1,diam2  : integer;
  val,valmax,valmin  : double;
  profile: array[0..1,-rs..rs] of double;
begin
  with mainwindow.image_north_arrow1 do
  begin
    {clear}
    canvas.brush.color:=clmenu;
    Canvas.FillRect(rect(0,0,width,height));
    Canvas.Pen.Color := clred;
    Canvas.Pen.style := psSolid;
    canvas.pen.mode:=pmmask;


    // Build profile
    valmax:=0;
    valmin:=65535;
    for i:=-rs to rs do
    begin
      profile[0,i]:=0;{clear profile}
      profile[1,i]:=0;{clear profile}
    end;

    for i:=-qrs to qrs do begin
      for j:=-qrs to qrs do
      begin
        distance:=round(resolution*sqrt(i*i + j*j)); {distance in resolution 1/6 pixel}
        if distance<=rs then {build histogram for circel with radius qrs}
        begin
          if ((i<0) or ((i=0) and (j<0)) ) then distance:=-distance;//split star in two equal areas.
          val:=img_loaded[0,cY+j,cX+i];
          profile[0,distance]:=profile[0,distance]+val;{sum flux at distance}
          profile[1,distance]:=profile[1,distance]+1;{calculate the number of counts}
          if val>valmax then valmax:=val;{record the peak value of the star}
          if val<valmin then valmin:=val;{record the min value of the star}
        end;
      end;
    end;

    if valmax>valmin then //prevent runtime errors
    for i:=-rs to rs do
    begin
      if profile[1,i]<>0 then
      begin
        hh:=height-round((height/(valmax-valmin))*(-valmin+profile[0,i]/profile[1,i]) );//height
        if i=-rs then
          moveToex(Canvas.handle,(width div 2)+i,hh,nil)
        else
          lineTo(Canvas.handle,(width div 2)+i,hh);
      end;
    end;

    diam1:=round((width/2 + (resolution/4) * object_hfd*strtofloat2(stackmenu1.flux_aperture1.text)));//in 1/6 pixel resolution
    diam2:=round((width/2 - (resolution/4) * object_hfd*strtofloat2(stackmenu1.flux_aperture1.text)));

    if diam2>=0 then  //show aperture
    begin
      Canvas.Pen.style := psdot;
      Canvas.Pen.Color := clGreen;
      moveToex(Canvas.handle,diam1,0,nil);
      lineto(Canvas.handle,diam1,2*rs);
      moveToex(Canvas.handle,diam2,0,nil);
      lineto(Canvas.handle,diam2,2*rs);
      Canvas.Pen.style := psSolid;
    end;

    canvas.pen.mode:=pmcopy; //back to default
  end;
end;

procedure plot_text;
var
  fontsize : double;
  letter_height,letter_width: integer;
  posanddate, freet : boolean;
begin
  posanddate:=mainwindow.positionanddate1.checked;
  freet:=mainwindow.freetext1.checked;
  if ((head.naxis=0) or ((posanddate=false) and (freet=false))) then exit;

  mainwindow.image1.Canvas.brush.Style:=bsClear;
  mainwindow.image1.Canvas.font.name:='default';
  fontsize:=max(annotation_diameter,font_size);
  mainwindow.image1.Canvas.font.size:=round(fontsize);
  letter_height:=mainwindow.image1.Canvas.textheight('M');
  letter_width:=mainwindow.image1.Canvas.textwidth('M');

  mainwindow.image1.Canvas.font.color:=annotation_color; {default clyellow}

  if posanddate then
  begin
    if head.cd1_1<>0 then  mainwindow.image1.Canvas.textout(round(0.3*letter_width),head.height-2*letter_height,'Position[α,δ]:  '+mainwindow.ra1.text+'    '+mainwindow.dec1.text);{}
    date_to_jd(head.date_obs,head.date_avg, head.exposure);{convert jd_start and jd_mid}
    mainwindow.image1.Canvas.textout(round(0.3*letter_width),head.height-letter_height,'Midpoint date: '+JdToDate(jd_mid)+', total exp: '+inttostr(round(head.exposure))+'s');{}
  end;
  if ((freet) and (freetext<>'')) then
    mainwindow.image1.Canvas.textout(head.width -round(0.3*letter_width) -mainwindow.image1.canvas.textwidth(freetext),head.height-letter_height,freetext);{right bottom corner, right aligned}
end;


procedure plot_constellations;
var
  fitsX,fitsY,overshoot, ra2,dec2,sep   : double;
  x1,y1,dia                             : integer;
  flip_horizontal, flip_vertical,outside: boolean;
begin
  if ((head.naxis=0) or (head.cd1_1=0) or (mainwindow.constellations1.checked=false)) then exit;

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

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
      celestial_to_pixel(head, ra2,dec2, fitsX,fitsY);{ra,dec to fitsX,fitsY}
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
      celestial_to_pixel(head, ra2,dec2, fitsX,fitsY);{ra,dec to fitsX,fitsY}
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

  Screen.Cursor:=crDefault;    { Restore cursor}
end;



procedure plot_grid(radec: boolean);  //plot ra,dec or az,alt grid
var
  fitsX,fitsY,step,stepA,stepRA,i,j,centra,centdec,range,ra,dcr,ra0,dec0,r1,r2,d1,d2, fX1,fY1,fX2,fY2,angle,az,alt,sep: double;
  x1,y1,x2,y2,k                                          : integer;
  flip_horizontal, flip_vertical: boolean;
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
  if ((head.naxis=0) or (head.cd1_1=0)) then exit;
  if ((radec) and (mainwindow.grid_ra_dec1.checked=false)) then exit;
  if ((radec=false) and (mainwindow.grid_az_alt1.checked=false)) then exit;

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

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
  mainwindow.image1.Canvas.Pen.width :=max(1,round(head.height/mainwindow.image1.height));

  if radec then
    mainwindow.image1.Canvas.Pen.color:= $909000
  else
    mainwindow.image1.Canvas.Pen.color:= $009090;

  mainwindow.image1.Canvas.brush.Style:=bsClear;
  mainwindow.image1.Canvas.font.color:= $909090;

  range:=head.cdelt2*sqrt(sqr(head.width/2)+sqr(head.height/2));{range in degrees, FROM CENTER}

  dec0:=head.dec0;
  ra0:=head.ra0;

  if radec=false then
  begin
    if calculate_az_alt_basic(ra0,dec0,{out} az,alt)=false then exit;{calculate azimuth, altitude and initialize wtime2actual/sidereal time}

    {angle}
    az_ra(az-0.01*pi/180,alt,site_lat_radians,0,wtime2actual,{out} r1,d1);{conversion az,alt to ra,dec} {input AZ [0..2pi], ALT [-pi/2..+pi/2],lat[-0.5*pi..0.5*pi],long[0..2pi],time[0..2*pi]}
    celestial_to_pixel(head, r1,d1, fX1,fY1);{ra,dec to fitsX,fitsY}
    az_ra(az+0.01*pi/180,alt,site_lat_radians,0,wtime2actual,{out} r2,d2);{conversion az,alt to ra,dec} {input AZ [0..2pi], ALT [-pi/2..+pi/2],lat[-0.5*pi..0.5*pi],long[0..2pi],time[0..2*pi]}
    celestial_to_pixel(head, r2,d2, fX2,fY2);{ra,dec to fitsX,fitsY}
    angle:=arctan2(fy2-fy1,fx2-fx1)*180/pi;
    mainwindow.image1.Canvas.font.size:=14;
    mainwindow.image1.Canvas.textout(10,head.height-25,'Angle: '+floattostrF(angle,FFfixed,0,2)+ '°    ('+head.date_obs+', '+sitelong+', '+sitelat+')');

    ra0:=az;//make az,alt grid
    dec0:=alt;
  end;

  mainwindow.image1.Canvas.font.size:=8;


  {calculate DEC step size}
  if range>20 then
  begin
    step:=10;{step DEC 10:00}
  end
  else
  if range>10 then
  begin
    step:=5;{step DEC 05:00}
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


  sep:=pi/2 - abs(dec0);//approximation for closed distance to celestial pole either north south. Ignore sphere rounding
  if ((radec) and (sep<range*pi/180)) then //celestial pole in the image
  begin
     stepRA:=30;
  end
  else
  begin
    {calculate RA step size}
    stepA:=min(45,step/(cos(dec0)+0.000001)); {exact value for stepRA, but not well rounded}
    k:=0;
    repeat {select nice rounded values for ra_step}
      stepRA:=ra_values[k];
      inc(k);
    until ((stepRA<=stepA) or (k>=length(ra_values)));{repeat until comparible value is found in ra_values}
  end;

  {round image centers}
  centra:=stepRA*round(ra0*180/(pi*stepRA)); {rounded image centers}
  centdec:=step*round(dec0*180/(pi*step));

  {plot DEC grid}
  i:=centRA-6*stepRA;
  repeat{dec lines}
    j:=max(centDEC-6*step,-90);
    repeat
      ra:=i*pi/180;
      dcr:=j*pi/180;
      if radec=false then
      begin
        az_ra(ra,dcr,site_lat_radians,0,wtime2actual,{out} ra,dcr);{conversion az,alt to ra,dec} {input AZ [0..2pi], ALT [-pi/2..+pi/2],lat[-0.5*pi..0.5*pi],long[0..2pi],time[0..2*pi]}
        precession3(jd_mid,2451545 {J2000},ra,dcr); {from Jnow mean to J2000, precession only. without refraction}
      end;

      celestial_to_pixel(head, ra,dcr, fitsX,fitsY);{ra,dec to fitsX,fitsY}

      if flip_horizontal then x1:=round((head.width-1)-(fitsX-1)) else x1:=round(fitsX-1);
      if flip_vertical=false then y1:=round((head.height-1)-(fitsY-1)) else y1:=round(fitsY-1);


      ra:=i*pi/180;
      dcr:=(j+step)*pi/180;
      if radec=false then
      begin
        az_ra(ra,dcr,site_lat_radians,0,wtime2actual,{out} ra,dcr);{conversion az,alt to ra,dec} {input AZ [0..2pi], ALT [-pi/2..+pi/2],lat[-0.5*pi..0.5*pi],long[0..2pi],time[0..2*pi]}
        precession3(jd_mid,2451545 {J2000},ra,dcr); {from Jnow mean to J2000, precession only. without refraction}
      end;

      celestial_to_pixel(head, ra,dcr, fitsX,fitsY);{ra,dec to fitsX,fitsY}


      if flip_horizontal then x2:=round((head.width-1)-(fitsX-1)) else x2:=round(fitsX-1);
      if flip_vertical=false then y2:=round((head.height-1)-(fitsY-1)) else y2:=round(fitsY-1);

      if (  ((x1>=0) and (y1>=0) and (x1<head.width)and (y1<head.height)) or
            ((x2>=0) and (y2>=0) and (x2<head.width)and (y2<head.height)) ) then
      begin {line is partly within image1. Strictly not necessary but more secure}
        if ((abs(i-centRA)<0.00001) or (abs(j-centDEC)<0.00001)) then
        begin
          if radec then
          begin
            ra_text:=prepare_ra6(fnmodulo(i,360)*pi/180,' '); {24 00 00}
            if copy(ra_text,7,2)='00' then delete(ra_text,6,3);{remove 00}

          end
          else ra_text:=inttostr(round(fnmodulo(i,360)));//az, alt grid

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
     ra:=i*pi/180;
     dcr:=j*pi/180;
     if radec=false then
     begin
       az_ra(ra,dcr,site_lat_radians,0,wtime2actual,{out} ra,dcr);{conversion az,alt to ra,dec} {input AZ [0..2pi], ALT [-pi/2..+pi/2],lat[-0.5*pi..0.5*pi],long[0..2pi],time[0..2*pi]}
       precession3(jd_mid,2451545 {J2000},ra,dcr); {from Jnow mean to J2000, precession only. without refraction}
     end;

      celestial_to_pixel(head, ra,dcr, fitsX,fitsY);{ra,dec to fitsX,fitsY}

      if flip_horizontal then x1:=round((head.width-1)-(fitsX-1)) else x1:=round(fitsX-1);
      if flip_vertical=false then y1:=round((head.height-1)-(fitsY-1)) else y1:=round(fitsY-1);

      ra:=(i+step)*pi/180;
      dcr:=j*pi/180;
      if radec=false then
      begin
        az_ra(ra,dcr,site_lat_radians,0,wtime2actual,{out} ra,dcr);{conversion az,alt to ra,dec} {input AZ [0..2pi], ALT [-pi/2..+pi/2],lat[-0.5*pi..0.5*pi],long[0..2pi],time[0..2*pi]}
        precession3(jd_mid,2451545 {J2000},ra,dcr); {from Jnow mean to J2000, precession only. without refraction}
      end;


      celestial_to_pixel(head, ra,dcr, fitsX,fitsY);{ra,dec to fitsX,fitsY}

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
  Screen.Cursor:=crDefault;    { Restore cursor}
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
     ((mainwindow.polynomial1.itemindex=1) and (ap_order=0)) or {SIP polynomial selected but no data}
     ((mainwindow.polynomial1.itemindex=2) and (x_coeff[0]=0)) {DSS polynomial selected but no data}
     ) then
   mainwindow.Polynomial1.color:=clred
   else
   mainwindow.Polynomial1.color:=cldefault;

  sip:=((ap_order>0) and (mainwindow.Polynomial1.itemindex=1));{use sip corrections?}

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

  if head.naxis=0 then exit;
  if shape.visible=false then exit;

  xF:=(fitsX-0.5)*(mainwindow.image1.width/head.width)-0.5; //inverse of  fitsx:=0.5+(0.5+xf)/(image1.width/head.width);{starts at 1}
  yF:=-(fitsY-head.height-0.5)*(mainwindow.image1.height/head.height)-0.5; //inverse of fitsy:=0.5+head.height-(0.5+yf)/(image1.height/head.height); {from bottom to top, starts at 1}

  if mainwindow.Flip_horizontal1.Checked then x:=mainwindow.image1.width-xF else x:=xF;
  if mainwindow.flip_vertical1.Checked then y:=mainwindow.image1.height-yF else y:=yF;

  with shape do
  begin
     hh:=max(minimum,round(h*mainwindow.image1.height/head.height));
     height:=hh;
     ww:= max(minimum,round(w*mainwindow.image1.width/head.width));
     width:=ww;
     ll:=round(mainwindow.image1.left + x - (width)/2);
     left:=ll;
     tt:=round(mainwindow.image1.top   + y - height/2);
     top:=tt;

     if shape_type=0 then {rectangle}
     begin
       shape:=stRectangle;{0}
       visible:=true;
     end
     else
     if shape_type=5 then {circle}
     begin {good lock on object}
       shape:=stcircle; {5}
       visible:=true;
     end
     else
     if shape_type=2 then {star}
     begin {good lock on object}
       visible:=true;
     end;
     {else keep as it is}
  end;
  if tshape(shape)=tshape(mainwindow.shape_var1) then
    begin mainwindow.labelVar1.left:=ll+ww; mainwindow.labelVar1.top:=tt+hh; mainwindow.labelVar1.font.size:=max(hh div 4,14);  mainwindow.labelVar1.visible:=true;end
  else
  if tshape(shape)=tshape(mainwindow.shape_check1) then
    begin mainwindow.labelCheck1.left:=ll+ww; mainwindow.labelCheck1.top:=tt+hh; mainwindow.labelCheck1.font.size:=max(hh div 4,14); mainwindow.labelCheck1.visible:=true;end
  else
  if tshape(shape)=tshape(mainwindow.shape_star3) then
    begin mainwindow.labelThree1.left:=ll+ww; mainwindow.labelThree1.top:=tt+hh; mainwindow.labelThree1.font.size:=max(hh div 4,14); mainwindow.labelThree1.visible:=true;end;

  shape.pen.style:=psSolid;//for photometry, resturn from psClear;
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

  if ( (((mainwindow.image1.width<=maxw) and (mainwindow.image1.height<=maxw)) or (mousewheelfactor<1){zoom out}) and {increased to 65535 for Windows only. Was above 12000 unequal stretch}
        ((mainwindow.image1.width>=100 ) or (mousewheelfactor>1){zoom in})                                                                  )
  then
  begin
    {limit the mouse positions to positions within the image1}
    mousepos.x:=max(MousePos.X,mainwindow.Image1.Left);
    mousepos.y:=max(MousePos.Y,mainwindow.Image1.top);
    mousepos.x:=min(MousePos.X,mainwindow.Image1.Left+mainwindow.image1.width);
    mousepos.y:=min(MousePos.Y,mainwindow.Image1.top+mainwindow.image1.height);

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
      show_marker_shape(mainwindow.shape_marker3,9 {no change in shape and hint},30,30,10{minimum},shape_marker3_fitsX, shape_marker3_fitsY);
      show_marker_shape(mainwindow.shape_marker4,9 {no change in shape and hint},60,60,10{minimum},shape_marker4_fitsX, shape_marker4_fitsY);

     if copy_paste then
     begin
       show_marker_shape(mainwindow.shape_paste1,copy_paste_shape {rectangle or ellipse},copy_paste_w,copy_paste_h,0{minimum}, mouse_fitsx, mouse_fitsy);{show the paste shape}
     end;

    {reference point manual alignment}
     if mainwindow.shape_manual_alignment1.visible then {For manual alignment. Do this only when visible}
       show_marker_shape(mainwindow.shape_manual_alignment1,9 {no change in shape and hint},20,20,10,shape_var1_fitsX, shape_var1_fitsY);

     //update shape positions using the known fitxY, fitsY position. Ra,dec position is not required
    show_marker_shape(mainwindow.shape_marker1,9 {no change in shape and hint},20,20,10{minimum},shape_marker1_fitsX, shape_marker1_fitsY);
    show_marker_shape(mainwindow.shape_marker2,9 {no change in shape and hint},20,20,10{minimum},shape_marker2_fitsX, shape_marker2_fitsY);
    show_marker_shape(mainwindow.shape_marker3,9 {no change in shape and hint},30,30,10{minimum},shape_marker3_fitsX, shape_marker3_fitsY);
    show_marker_shape(mainwindow.shape_marker4,9 {no change in shape and hint},60,60,10{minimum},shape_marker4_fitsX, shape_marker4_fitsY);

    if mainwindow.shape_var1.visible then {For manual alignment. Do this only when visible}
      show_marker_shape(mainwindow.shape_var1,9 {no change in shape and hint},20,20,10,shape_var1_fitsX, shape_var1_fitsY);
    if mainwindow.shape_check1.visible then {For manual alignment. Do this only when visible}
      show_marker_shape(mainwindow.shape_check1,9 {no change in shape and hint},20,20,10,shape_check1_fitsX, shape_check1_fitsY);
    if mainwindow.shape_star3.visible then {For manual alignment. Do this only when visible}
      show_marker_shape(mainwindow.shape_star3,9 {no change in shape and hint},20,20,10,shape_star3_fitsX, shape_star3_fitsY);

    if mainwindow.shape_var2.visible then //update the shape position based on ra,dec values
    begin
      show_marker_shape(mainwindow.shape_var2,9 {no change in shape and hint},50,50,10,shape_var2_fitsX, shape_var2_fitsY);
      show_marker_shape(mainwindow.shape_check2,9 {no change in shape and hint},50,50,10,shape_check2_fitsX, shape_check2_fitsY);
    end;

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


procedure Tmainwindow.Panel1MouseWheelUp(Sender: TObject; Shift: TShiftState; //zoom
  MousePos: TPoint; var Handled: Boolean);
var
  P: TPoint;
begin
  GetCursorPos(p);  {use this since in Lazarus the mousepos varies depending control under the mouse}
  p:=panel1.Screentoclient(p);
  if p.y<0 then
      exit; {not in image range}

  if mainwindow.inversemousewheel1.checked then  zoom(1/1.2,p) else zoom(1.2,p);
  Handled := True;{prevent that in win7 the combobox is moving up/down if it has focus}
end;


procedure Tmainwindow.show_statistics1Click(Sender: TObject);
var
   fitsX,fitsY,dum,counter,col,size,counter_median,required_size,iterations,i,band,flux_counter,greylevels,greylevels2 : integer;
   value,stepsize,median_position, most_common,mc_1,mc_2,mc_3,mc_4,
   sd,mean,median,bg_median,minimum, maximum,max_counter,saturated,mad,minstep,delta,range,total_flux,adu_e,center_x,center_y,a,b,hotpixel_adu,hotpixel_perc : double;
   info_message,shapeform,shapeform2   : string;
   median_array                        : array of double;
   full_image                          : boolean;
const
  median_max_size=5000;

begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  if ((abs(stopX-startX)>1)and (abs(stopY-starty)>1))=false then {do statistics on whole image}
  begin
    startx:=0;stopX:=head.width-1;
    starty:=0;stopY:=head.height-1;
    full_image:=true
  end
  else
  full_image:=false;

  if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
  if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

  {reset variables}
  info_message:='';

  adu_e:=retrieve_ADU_to_e_unbinned(head.egain);//Used for SNR calculation in procedure HFD. Factor for unbinned files. Result is zero when calculating in e- is not activated in the statusbar popup menu. Then in procedure HFD the SNR is calculated using ADU's only.

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
    measure_hotpixels(startX+1 ,startY+1, stopX-1,stopY-1{within rectangle},col,sd,mean,img_loaded,{out}hotpixel_perc,hotpixel_adu);{calculate the hotpixel_adu ratio and average value}

    most_common:=mode(img_loaded,CtrlButton {ellipse},col,startx,stopX,starty,stopY,65535,greylevels);

    {median sampling and min , max}
    max_counter:=1;
    median:=0;
    saturated:=0;
    minimum:=999999999;
    maximum:=0;
    counter:=0;
    flux_counter:=0;
    counter_median:=0;
    total_flux:=0;

    center_x:=(startx+stopX-1)/2;
    center_y:=(startY+stopY-1)/2;
    a:=(stopX-1-startx)/2;
    b:=(stopY-1-startY)/2;

    for fitsY:=startY+1 to stopY-1 do {within rectangle.  StartX,StopX are in 0...width-1,0..height-1 range}
    for fitsX:=startX+1 to stopX-1 do
    begin
      if ((CtrlButton=false {use no ellipse}) or (sqr(fitsX-center_X)/sqr(a) +sqr(fitsY-center_Y)/sqr(b)<1)) then // standard equation of the ellipse
      begin
        value:=img_loaded[col,fitsY,fitsX];
        median_position:=flux_counter*stepsize;
        total_flux:=total_flux+value; {total flux}
        inc(flux_counter);

        if  trunc(median_position)>=counter_median then {pixels will be skippped. Limit sampling to median_max_size}
        begin
          median_array[counter_median]:=value; {fill array with sampling data. Smedian will be applied later}
          inc(counter_median);
        end;

        if value=maximum then max_counter:=max_counter+1; {counter at max. Not an exact counter since maximum is adjusted}
        if value>maximum then
        begin
          maximum:=value; //max
          max_counter:=1;//reset
        end;
        if value<minimum then minimum:=value; {min}
        if value>=64000 then saturated:=saturated+1;{saturation counter}
        if col=0 then
        begin
          delta:=abs(value-most_common);
          if ((delta>0.00000001){not the same} and (delta<minstep)) then minstep:=delta;
        end;
      end;
    end;{filter outliers}

    median:=smedian(median_array,counter_median);

    for i:=0 to counter_median-1 do median_array[i]:=abs(median_array[i] - median);{fill median_array with offsets}
    mad:=smedian(median_array,counter_median); //median absolute deviation (MAD)

    {measure the median of the suroundings}
    median_array:=nil;{free mem}
    setlength(median_array,(5+5+1+stopY-startY)*5*2+(5+5+1+stopX-startX)*5*2);//surface used for background. Overlap not counted for simplicity
    counter:=0;
    if full_image then
      band:=+5 //measure inside box so at the boundaries of the image
    else
      band:=0;//measure only outside box
    for fitsY:=startY+ 1-5 to stopY-1+5 do {calculate mean at square boundaries of detection box.  StartX,StopX are in 0...width-1,0..height-1 range}
    for fitsX:=startX+1-5 to stopX-1+5 do
    begin
      if ( (fitsX<startX+band) or  (fitsX>stopX-band) or (fitsY<startY+band) or  (fitsY>stopY-band) ) then {measure only outside the box unless band>0 for full image}
        if ( (fitsX>=0) and  (fitsX<head.width) and (fitsY>=0) and  (fitsY<head.height) ) then {do not measure outside the image}
        begin
          if counter>=length(median_array) then
             SetLength(median_array,counter+5000);{increase length}
          median_array[counter]:=img_loaded[0,fitsY,fitsX];
          inc(counter);
        end;
      end;
    if counter>0 then
    begin
      bg_median:=Smedian(median_array,counter);
      total_flux:=total_flux-bg_median*flux_counter; {total flux above background}
    end
    else
    begin
      bg_median:=9999999;{something went wrong}
      total_flux:=0;
    end;

    if col=0 then range:=maximum-minimum;

    if head.naxis3>1 then if col=0 then info_message:=info_message+'Red:'+#10;
    if col=1 then info_message:=info_message+#10+#10+'Green:'+#10;
    if col=2 then info_message:=info_message+#10+#10+'Blue:'+#10;

    info_message:=info_message+  'x̄ :    '+floattostrf(mean,ffFixed, 0, 2)+'   (sigma-clip iterations='+inttostr(iterations)+')'+#10+             {mean}
                                  'x̃  :   '+floattostrf(median,ffFixed, 0, 2)+#10+ {median}
                                  'Mo :  '+floattostrf(most_common,ffgeneral, 5, 5)+#10+
                                  'σ :   '+noise_to_electrons(adu_e,sd)+'   (sigma-clip iterations='+inttostr(iterations)+')'+#10+               {standard deviation}
                                  'σ_2:   '+noise_to_electrons(adu_e,get_negative_noise_level(img_loaded,col,startx,stopX,starty,stopY,most_common))+#10+
                                  'mad:   '+floattostrf(mad,ffgeneral, 4, 4)+#10+
                                  'm :   '+floattostrf(minimum,ffgeneral, 5, 5)+#10+
                                  'M :   '+floattostrf(maximum,ffgeneral, 5, 5)+ '  ('+inttostr(round(max_counter))+' x)'+#10+
                                  'Flux: '+floattostrf(total_flux,ffExponent, 4, 2)+ '  (Counts '+inttostr(flux_counter)+ ', Average '+inttostr(round(total_flux/flux_counter))+'/px)'+#10+
                                  'BG :   '+floattostrf(bg_median,ffgeneral, 5, 5)+#10+ {median}
                                  'Hot pixels: '+floattostrf(100*hotpixel_perc,FFfixed, 0, 1)+'%'+#10+
                                  'Hot pixels RMS: '+noise_to_electrons(adu_e,hotpixel_adu)+#10+
                                  '≥64E3 :  '+inttostr(round(saturated));
  end;
  if ((abs(stopX-startx)>=head.width-1) and (most_common<>0){prevent division by zero}) then
  begin
    mc_1:=mode(img_loaded,false{ellipse shape},0,          0{x1},      50{x2},           0{y1},       50{y2},32000,greylevels2);{for this area get most common value equals peak in histogram}
    mc_2:=mode(img_loaded,false{ellipse shape},0,          0{x1},      50{x2},head.height-1-50{y1},head.height-1{y2},32000,greylevels2);
    mc_3:=mode(img_loaded,false{ellipse shape},0,head.width-1-50{x1},head.width-1{x2},head.height-1-50{y1},head.height-1{y2},32000,greylevels2);
    mc_4:=mode(img_loaded,false{ellipse shape},0,head.width-1-50{x1},head.width-1{x2},           0{y1},50       {y2},32000,greylevels2);

    info_message:=info_message+#10+#10+'Vignetting [Mo corners/Mo]: '+inttostr(round(100*(1-(mc_1+mc_2+mc_3+mc_4)/(most_common*4))))+'%';
  end;

  if range>0 then
  begin
    if max_counter>50 then
      info_message:=info_message+#10+#10+'Bit depth data: '+inttostr(round(ln(range/minstep)/ln(2))){bit range, calculate 2log}
    else
      info_message:=info_message+#10+#10+'Bit depth data: ??  Image is not saturated.';
  end;


  if ((nrbits=16) or (nrbits=8)) then info_message:=info_message+#10+'Greyscale levels: '+ inttostr(greylevels);

  if head.Xbinning<>1 then  info_message:=info_message+#10+'Binning: '+ floattostrf(head.Xbinning,ffgeneral,0,0)+'x'+floattostrf(head.Ybinning,ffgeneral,0,0);

  if CTRLbutton=false then begin shapeform:='Rectangle: ';shapeform2:='rectangle'; end else begin shapeform:='Ellipse: '; shapeform2:='ellipse'; end;

  info_message:=info_message+#10+shapeform+inttostr(startX+1)+', '+inttostr(startY+1)+',    '+inttostr(stopX+1)+', '+inttostr(stopY+1);
  info_message:=info_message+#10+'Filename: '+extractfilename(filename2);


  info_message:=info_message+#10+#10+#10+'Noise in electrons can be set with the popup menu of the status bar.'+
                                            #10+#10+
                                            'Legend: '+#10+
                                            'x̄ = mean background | x̃  = median background | '+
                                            'Mo = mode or most common pixel value or peak histogram, so the best estimate for the background mean value | '+
                                            'σ =  standard deviation background using mean and sigma clipping| ' +
                                            'σ_2 = standard deviation background using values below Mo only | '+
                                            'mad = median absolute deviation | '+
                                            'm = minimum value image | M = maximum value image | '+
                                            'Flux = total flux inside shape above BG | '+
                                            'BG = median background outside the shape | '+
                                            'Hot pixels = percentage of pixels with a value above 3 sigma Gaussian noise | '+
                                            'Hot pixels RMS = the root mean square value of the hotpixels | '+
                                            '≥64E3 = number of values equal or above 64000';

  case  QuestionDlg (pchar('Statistics within '+shapeform2+' '+inttostr(stopX-1-startX)+' x '+inttostr(stopY-1-startY)),pchar(info_message),mtCustom,[mrYes,'Copy to clipboard?', mrNo, 'No', 'IsDefault'],'') of
           mrYes: Clipboard.AsText:=info_message;
  end;


  median_array:=nil;{free mem}

  Screen.Cursor:=crDefault;
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
  mainwindow.writepositionshort1.enabled:=yes;{enable popup menu}
  mainwindow.Copyposition1.enabled:=yes;{enable popup menu}
  mainwindow.Copypositionindeg1.enabled:=yes;{enable popup menu}
  mainwindow.export_star_info1.enabled:=yes;{enable popup menu}
  mainwindow.online_query1.enabled:=yes;{enable popup menu}
  mainwindow.Polynomial1Change(nil);{update color for SIP}
  stackmenu1.focallength1Exit(nil); {update output calculator after a SOLVE}
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

  //mainwindow.error_label1.visible:=(fits=false);
  if fits then mainwindow.error_label1.visible:=false;;

  mainwindow.SaveFITSwithupdatedheader1.Enabled:=((fits) and (fits_file_name(filename2)) and (fileexists(filename2)));{menu disable, no file available to update header}
  mainwindow.saturation_factor_plot1.enabled:=head.naxis3=3;{colour};
  mainwindow.Polynomial1Change(nil);{update color after an image LOAD}

  update_menu_related_to_solver((fits) and (head.cd1_1<>0));
  stackmenu1.resize_factor1Change(nil);{update dimensions binning menu}
  stackmenu1.test_pattern1.Enabled:=head.naxis3=1;{mono}

  stackmenu1.focallength1.Text:=floattostrf(focallen,ffgeneral, 4, 4);
  stackmenu1.pixelsize1.text:=floattostrf(head.xpixsz{*XBINNING},ffgeneral, 4, 4);
  stackmenu1.calculator_binning1.caption:=inttostr(head.width)+' x '+inttostr(head.height)+' pixels, binned '+floattostrf(head.Xbinning,ffgeneral,0,0)+'x'+floattostrf(head.Ybinning,ffgeneral,0,0);
  stackmenu1.focallength1Exit(nil); {update calculator}
end;


procedure Tmainwindow.astrometric_solve_image1Click(Sender: TObject);
begin
  if head.naxis=0 then exit;

  if live_stacking {ongoing}  then
  begin
    stackmenu1.Memo2.lines.add('█ █ █ █ █ █  Can'+#39+'t solve while live stacking!!');
    exit;
  end;
  save_settings2;

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  memo1.lines.beginupdate;

  {solve internal}
  mainwindow.caption:='Solving.......';
  save1.Enabled:=solve_image(img_loaded,head,mainwindow.memo1.lines,false {get hist, is already available},false {check filter});{match between loaded image and star database}
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
    plot_grid(true);//ra,dec
    plot_grid(false);//az,alt
    plot_constellations;
    plot_text;

    image1.Repaint;{show north-east indicator}

    update_menu_related_to_solver(true);{update menus section}
    update_statusbar_section5;{update section 5 with image dimensions in degrees}
  end;
  {else do nothing, keep old solution visible if available}

  memo1.Visible:=true; {could be disabled by loading dark/flits due to calibrate prior to solving}
  memo1.lines.endupdate;
  Screen.Cursor:=crDefault;
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
  result:='';
  if load_fits(filename7,true {light},true,true {update memo},0,mainwindow.memo1.lines,head,img_loaded)=false then
  begin
    beep;
    exit;
  end;

  if ((pos('TR',head.filter_name)=0) and (pos('TG',head.filter_name)=0) and (pos('TB',head.filter_name)=0) and (head.naxis3=1)) then
  begin

    ratio:=0.5;
    w:=trunc(head.width/2);  {half size}
    h:=trunc(head.height/2);

    setlength(img_temp11,1,h,w);

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
        val:=img_loaded[0,fitsY*2+yp-1,fitsx*2+xp-1];
        if get_green then val:=(val+img_loaded[0,fitsY*2+yp2-1,fitsx*2+xp2-1])/2; {add second green pixel}
        img_temp11[0,fitsY,fitsX]:=val;
      end;

    head.width:=w;
    head.height:=h;

    mainwindow.Memo1.Lines.BeginUpdate;

    update_integer(mainwindow.memo1.lines,'NAXIS1  =',' / length of x axis                               ' ,head.width);
    update_integer(mainwindow.memo1.lines,'NAXIS2  =',' / length of y axis                               ' ,head.height);


    update_integer(mainwindow.memo1.lines,'NAXIS1  =',' / length of x axis                               ' ,head.width);
    update_integer(mainwindow.memo1.lines,'NAXIS2  =',' / length of y axis                               ' ,head.height);



    if head.crpix1<>0 then begin head.crpix1:=head.crpix1*ratio; update_float(mainwindow.memo1.lines,'CRPIX1  =',' / X of reference pixel                           ',false ,head.crpix1);end;
    if head.crpix2<>0 then begin head.crpix2:=head.crpix2*ratio; update_float(mainwindow.memo1.lines,'CRPIX2  =',' / Y of reference pixel                           ',false ,head.crpix2);end;

    if head.cdelt1<>0 then begin head.cdelt1:=head.cdelt1/ratio; update_float(mainwindow.memo1.lines,'CDELT1  =',' / X pixel size (deg)                             ',false ,head.cdelt1);end;
    if head.cdelt2<>0 then begin head.cdelt2:=head.cdelt2/ratio; update_float(mainwindow.memo1.lines,'CDELT2  =',' / Y pixel size (deg)                             ',false ,head.cdelt2);end;

    if head.cd1_1<>0 then
    begin
      head.cd1_1:=head.cd1_1/ratio;
      head.cd1_2:=head.cd1_2/ratio;
      head.cd2_1:=head.cd2_1/ratio;
      head.cd2_2:=head.cd2_2/ratio;
      update_float(mainwindow.memo1.lines,'CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_1);
      update_float(mainwindow.memo1.lines,'CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_2);
      update_float(mainwindow.memo1.lines,'CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_1);
      update_float(mainwindow.memo1.lines,'CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_2);
    end;

    head.XBINNING:=head.XBINNING/ratio;
    head.YBINNING:=head.YBINNING/ratio;
    update_float(mainwindow.memo1.lines,'XBINNING=',' / Binning factor in width                         ',false ,head.XBINNING);
    update_float(mainwindow.memo1.lines,'YBINNING=',' / Binning factor in height                        ',false ,head.YBINNING);


    if head.XPIXSZ<>0 then
    begin
      head.XPIXSZ:=head.XPIXSZ/ratio;
      head.YPIXSZ:=head.YPIXSZ/ratio;
      update_float(mainwindow.memo1.lines,'XPIXSZ  =',' / Pixel width in microns (after binning)          ',false ,head.XPIXSZ);{note: comment will be never used since it is an existing keyword}
      update_float(mainwindow.memo1.lines,'YPIXSZ  =',' / Pixel height in microns (after binning)         ',false ,head.YPIXSZ);
      update_float(mainwindow.memo1.lines,'PIXSIZE1=',' / Pixel width in microns (after binning)          ',false ,head.XPIXSZ);
      update_float(mainwindow.memo1.lines,'PIXSIZE2=',' / Pixel height in microns (after binning)         ',false ,head.YPIXSZ);

    end;

    add_text(mainwindow.memo1.lines,'HISTORY   ','One raw colour extracted.');

    remove_key(mainwindow.memo1.lines,'BAYERPAT=',false{all});
    update_text(mainwindow.memo1.lines,'FILTER  =',copy(#39+filtern+#39+'                   ',1,21)+'/ Filter name');

    mainwindow.Memo1.Lines.EndUpdate;

    img_loaded:=img_temp11;
    result:=ChangeFileExt(FileName7,'_'+filtern+'.fit');
    if save_fits(img_loaded,mainwindow.memo1.lines,result,16,true{overwrite}) =false then result:='';
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
  dobackup    : boolean;
  i           : integer;

begin
  with mainwindow do
  begin
    OpenDialog1.Title := 'Select multiple RAW fits files to extract Bayer matrix position '+filtern+' from them';
    OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
    opendialog1.Filter := dialog_filter_fits_tif;

//    fits_file:=true;
    esc_pressed:=false;

    if OpenDialog1.Execute then
    begin
      Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
      dobackup:=img_loaded<>nil;
      if dobackup then backup_img;{preserve img array and fits header of the viewer}

      try { Do some lengthy operation }
        with OpenDialog1.Files do
        for I := 0 to Count - 1 do
        begin
          Application.ProcessMessages;
          if esc_pressed then break;

          if extract_raw_colour_to_file(Strings[I] {filename}, filtern,xp,yp )=''{new file name} then beep;
        end;
      finally
        if dobackup then restore_img;{for the viewer}
        Screen.Cursor:=crDefault;  { Always restore to normal }
      end;
    end;
    head.naxis:=0;{not the food fits loaded}
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
      if load_fits(opendialog1.filename,true {light},true,true {update memo},0,mainwindow.memo1.lines,head,img_loaded) then
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
  Image1MouseMove(Sender,Shift, X-image1.Left, Y-image1.top);// transfer mouse move to image1
end;


procedure Tmainwindow.recent1Click(Sender: TObject);
begin
  filename2:= (Sender as Tmenuitem).caption;
  if fileexists(filename2) then load_image(filename2,img_loaded,head,mainwindow.memo1.lines,true,true {plot}) {load and center, plot}
  else
  begin {file gone/deleted}
     application.messagebox(pchar('File not found:'+#13+#10+#13+#10+(Sender as Tmenuitem).caption),pchar('Error'),MB_ICONWARNING+MB_OK);
    (Sender as Tmenuitem).caption:='';
  end;
  add_recent_file(filename2);{update recent files list by moving this one up to first position}
end;


procedure Tmainwindow.Remove_deep_sky_object1Click(Sender: TObject);
var
   fitsX,fitsY,dum,k,bsize,greylevels  : integer;
   mode_left_bottom,mode_left_top, mode_right_top, mode_right_bottom,
   noise_left_bottom,noise_left_top, noise_right_top, noise_right_bottom,
   center_x,center_y,a,b,new_value,new_value_noise      : double;
   line_bottom, line_top,line_bottom_noise, line_top_noise : double;
begin
  if head.naxis=0 then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    backup_img;

    bsize:=min(10,abs(stopX-startX));{10 or smaller}

    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

    {ellipse parameters}
    center_x:=(startx+stopX-1)/2;
    center_y:=(startY+stopY-1)/2;
    a:=(stopX-1-startx)/2;
    b:=(stopY-1-startY)/2;

    Randomize;

    for k:=0 to head.naxis3-1 do {do all colors}
    begin

      mode_left_bottom:=mode(img_loaded,false{ellipse shape},k,startx-bsize,startx+bsize,starty-bsize,starty+bsize,32000,greylevels);{for this area get most common value equals peak in histogram}
      mode_left_top:=   mode(img_loaded,false{ellipse shape},k,startx-bsize,startx+bsize,stopY-bsize,stopY+bsize,32000,greylevels);{for this area get most common value equals peak in histogram}

      mode_right_bottom:=mode(img_loaded,false{ellipse shape},k,stopX-bsize,stopX+bsize,starty-bsize,starty+bsize,32000,greylevels);{for this area get most common value equals peak in histogram}
      mode_right_top:=   mode(img_loaded,false{ellipse shape},k,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize,32000,greylevels);{for this area get most common value equals peak in histogram}

      noise_left_bottom:=get_negative_noise_level(img_loaded,k,startx-bsize,startx+bsize,starty-bsize,starty+bsize, mode_left_bottom);{find the negative noise level below most_common_level of a local area}
      noise_left_top:=get_negative_noise_level(img_loaded,k,startx-bsize,startx+bsize,stopY-bsize,stopY+bsize, mode_left_top);{find the negative noise level below most_common_level of a local area}
      noise_right_bottom:=get_negative_noise_level(img_loaded,k,stopX-bsize,stopX+bsize,starty-bsize,starty+bsize, mode_right_bottom);{find the negative noise level below most_common_level of a local area}
      noise_right_top:=get_negative_noise_level(img_loaded,k,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize, mode_right_top);{find the negative noise level below most_common_level of a local area}

      for fitsY:=startY to stopY-1 do
      for fitsX:=startX to stopX-1 do
      begin
        if sqr(fitsX-center_X)/sqr(a) +sqr(fitsY-center_Y)/sqr(b)<1 then // standard equation of the ellipse
        begin
          line_bottom:=mode_left_bottom*(stopX-fitsx)/(stopX-startx)+ mode_right_bottom *(fitsx-startX)/(stopX-startx);{median value at bottom line}
          line_top:=  mode_left_top *   (stopX-fitsx)/(stopX-startx)+ mode_right_top*(fitsx-startX)/(stopX-startx);{median value at top line}

          line_bottom_noise:=noise_left_bottom*(stopX-fitsx)/(stopX-startx)+ noise_right_bottom *(fitsx-startX)/(stopX-startx);{median noise value at bottom line}
          line_top_noise:=  noise_left_top *   (stopX-fitsx)/(stopX-startx)+ noise_right_top*(fitsx-startX)/(stopX-startx);{median noise value at top line}

          new_value:=line_bottom*(stopY-fitsY)/(stopY-startY)+line_top*(fitsY-startY)/(stopY-startY);{expected value based on the four corners measurements}
          new_value_noise:=line_bottom_noise*(stopY-fitsY)/(stopY-startY)+line_top_noise*(fitsY-startY)/(stopY-startY);{median noise value at position FitsX, fitsY}

          img_loaded[k,fitsY,fitsX]:=randg(new_value,new_value_noise);

        end;
      end;
    end;{k color}
    plot_fits(mainwindow.image1,false,true);
    Screen.Cursor:=crDefault;
  end {fits file}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);
end;


function floattostr8(x:double):string;//always with dot decimal seperator. Float to string with 8 decimals
begin
  str(x:0:8,result);
end;


function floattostr6(x:double):string;//always with dot decimal seperator. Float to string with 6 decimals
begin
  str(x:0:6,result);
end;


function floattostr4(x:double):string;//always with dot decimal seperator
begin
  str(x:0:4,result);
end;


function floattostr2(x:double):string;//always with dot decimal seperator.
begin
  str(x:0:2,result);
end;

function floattostrE(x:double):string;
begin
  str(x,result);
end;


function inttostr5(x:integer):string;{always 5 digit}
begin
  str(x:5,result);
end;


function strtoint2(s: string;default:integer):integer; {str to integer, fault tolerant}
var
  error1 : integer;
  value    : double;
begin
  val(s,value,error1);
  if error1<>0 then
    result:=default
  else
    result:=round(value);
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


function strtofloat1(s:string): double;{string to float for dot seperator, error tolerant}
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
begin {make from rax [0..pi*2] a string. Length is 10 long}
  if decx<0 then sign:='-' else sign:='+';
  decx:=abs(decx)+pi/(360*60*60); {add half second to get correct rounding and not 7:60 results as with round}
  decx:=decx*180/pi; {make degrees}
  g:=trunc(decx);
  m:=trunc((decx-g)*60);
  s:=trunc((decx-g-m/60)*3600);
  prepare_dec:=sign+leadingzero(g)+sep+leadingzero(m)+copy('  ',1,length(sep))+leadingzero(s);
end;


function prepare_ra8(rax:double; sep:string):string; {radialen to text, format 24: 00 00.00 }
 var
   B       : String[2];
   h,m,s,ds  :integer;
 begin   {make from rax [0..pi*2] a string. Length is 8 long}
  rax:=rax+pi*0.01/(24*60*60); {add 1/10 of half second to get correct rounding and not 7:60 results as with round}
  rax:=rax*12/pi; {make hours}
  h:=trunc(rax);
  m:=trunc((rax-h)*60);
  s:=trunc((rax-h-m/60)*3600);
  ds:=trunc((rax-h-m/60-s/3600)*360000);
  Str(trunc(h):2,b);
  result:=b+sep+leadingzero(m)+copy('  ',1,length(sep))+leadingzero(s)+'.'+leadingzero(ds);
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
  prepare_dec2:=sign+b+sep+leadingzero(m)+copy('  ',1,length(sep))+leadingzero(s)+'.'+ds2;
end;


procedure old_to_new_WCS(var head:theader);{ convert old WCS to new, revision 2022}
begin
  // https://www.aanda.org/articles/aa/full/2002/45/aah3860/aah3860.right.html
  // Representations of World Coordinates in FITS paper II aah3860
  // formula 189
  head.cd1_1:=+head.cdelt1 * cos(head.crota1*pi/180);{could be skewed, so use crota1}
  head.cd2_1:=+head.cdelt1 * sin(head.crota1*pi/180);

  head.cd1_2:=-head.cdelt2 * sin(head.crota2*pi/180);
  head.cd2_2:=+head.cdelt2 * cos(head.crota2*pi/180);
end;


procedure new_to_old_WCS(var head : theader);{convert new style FITS to old style, revison 2022}
var
  crota_1, crota_2 : double;
begin
  // https://www.aanda.org/articles/aa/full/2002/45/aah3860/aah3860.right.html
  // Representations of World Coordinates in FITS paper II aah3860

  // formula 191
  if head.cd2_1>0 then crota_1:=arctan2(-head.cd2_1,-head.cd1_1)
  else
  if head.cd2_1<0 then crota_1:=arctan2(+head.cd2_1,+head.cd1_1)
  else
  crota_1:=0;

  if head.cd1_2>0 then crota_2:=arctan2(-head.cd1_2,head.cd2_2)  //arctan2 returns arctangent of (y/x)
  else
  if head.cd1_2<0 then crota_2:=arctan2(head.cd1_2,-head.cd2_2)  //arctan2 returns arctangent of (y/x)
  else
  crota_2:=0;

  // https://www.aanda.org/articles/aa/full/2002/45/aah3860/aah3860.right.html
  // Representations of World Coordinates in FITS paper II aah3860
  // Formula 193 improved for crota close to or equal to +90 or -90 degrees
  // Calculate cdelt1, cdelt2 values using the longest side of the triangle
  if abs(head.cd1_1)>abs(head.cd2_1) then
  begin
    head.cdelt1:=+head.cd1_1/cos(crota_1);//Note crota_1, 2 are in radians
    head.cdelt2:=+head.cd2_2/cos(crota_2);
  end
  else
  begin
    head.cdelt1:=+head.cd2_1/sin(crota_1);//Note crota_1, 2 are in radians
    head.cdelt2:=-head.cd1_2/sin(crota_2);
  end;

  head.crota1:=crota_1*180/pi;//Note crota1, 2 are now in degrees
  head.crota2:=crota_2*180/pi;

  //Solutions for CROTA2 come in pairs separated by 180degr. The other solution is obtained by subtracting 180 from CROTA2 and negating CDELT1 and CDELT2.
  //While each solution is equally valid, if one makes CDELT1 < 0 and CDELT2 > 0 then it would normally be the one chosen.
  if head.cdelt2<0 then //CDELT2 is always kept positive and if not the solution is flipped by negating both CDELT2, CDELT2 and shifting the angle 180 degrees. So if the image is flipped the solution is reporting "flipped horizontal" and not an equivalent "flipped vertical".
  begin
    if head.crota2<0 then
    begin
      head.crota2:=head.crota2+180;
      head.crota1:=head.crota1+180;
    end
    else
    begin
      head.crota2:=head.crota2-180;
      head.crota1:=head.crota1-180;
    end;

    head.cdelt2:=-head.cdelt2;
    head.cdelt1:=-head.cdelt1;
  end;//make cdelt2 always positive
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

  setlength(img_temp2,3,head.height,head.width);{set length of image array color}

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
                   img_temp2[0,y,x]:=     (img[0,y-1,x ] + img[0  ,y+1,x])/2; {red neighbor pixels };
                   img_temp2[1,y,x]:=     (img[0,y  ,x  ] );
                   img_temp2[2,y,x]:=     (img[0,y  ,x-1  ] + img[0,y,x+1  ])/2; {blue neighbor pixels }end
      else
      if green_even then begin
                   img_temp2[0,y,x]:=     (img[0,y  ,x-1] + img[0,y,x+1  ])/2; {red neighbor pixels };
                   img_temp2[1,y,x]:=     (img[0,y  ,x  ] );
                   img_temp2[2,y,x]:=     (img[0,y-1,x  ] + img[0,y+1,x ])/2; {blue neighbor pixels }end
      else
      if red then begin
                   img_temp2[0,y,x]:=     (img[0,y  ,x  ]);
                   img_temp2[1,y,x]:=     (img[0,y  ,x-1  ] + img[0,y,x+1  ] + img[0,y-1,x  ]+ img[0,y+1,x])/4;{green neighbours}
                   img_temp2[2,y,x]:=     (img[0,y-1,x-1] + img[0,y+1,x-1] + img[0,y-1,x+1]+ img[0,y+1,x+1])/4 ; end {blue neighbor pixels }
      else
      if blue then begin
                   img_temp2[0,y,x]:=     (img[0,y-1,x-1] + img[0,y+1,x-1]+ img[0,y-1,x+1]+ img[0,y+1,x+1])/4;
                   img_temp2[1,y,x]:=     (img[0,y  ,x-1] + img[0,y  ,x+1]+ img[0,y-1,x  ]+ img[0,y+1,x])/4;
                   img_temp2[2,y,x]:=     (img[0,y  ,x  ] ); end;
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
  setlength(img_temp2,3,head.height,head.width);{set length of image array color}

  for y :=2 to  head.height-2 do   {-2 = -1 -1}
  begin
    for x:=2 to head.width-2 do
    begin
      try
       x2:=x-1;
       y2:=y-1;
       xpos:=1+x2-(x2 div 3)*3;{position in 3x3 matrix}
       ypos:=1+y2-(y2 div 3)*3;
       xpos6:=1+x2-(x2 div 6)*6;{position in 6x6 matrix}
       ypos6:=1+y2-(y2 div 6)*6;

      {use only one neighbour pixel with preference go right, go below, go left. Use only on neighbour pixel for maximum sharpness }

      if ((xpos=1) and (ypos=1)) then {green}begin
                   red             :=   img[0,y+1,x ]; {near red pixel};
                   img_temp2[1,y,x]:= img[0,y  ,x ] ;
                   blue            :=   img[0,y  ,x+1  ]; {near blue pixel} end else
      if ((xpos=3) and (ypos=1)) then {green}begin
                   red             :=   img[0,y+1,x  ]; {near red pixel};
                   img_temp2[1,y,x]:= img[0,y  ,x  ] ;
                   blue            :=   img[0,y,  x-1]; {near blue pixel} end else
      if ((xpos=2) and (ypos=2)) then {green}begin
                   red             :=   img[0,y,x+1  ]; {near red pixel};
                   img_temp2[1,y,x]:= img[0,y,x  ] ;
                   blue:=               img[0,y+1,x  ]; {near blue pixel} end else
      if ((xpos=1) and (ypos=3)) then {green}begin
                   red             :=   img[0,y-1,x  ]; {near red pixel};
                   img_temp2[1,y,x]:= img[0,y,  x  ] ;
                   blue:=               img[0,y,  x+1 ]; {near blue pixel} end else
      if ((xpos=3) and (ypos=3)) then {green}begin
                   red             :=   img[0,y-1,x  ]; {near red pixel};
                   img_temp2[1,y,x]:=  img[0,y  ,x  ] ;
                   blue              :=  img[0,y  ,x-1]; {near blue pixel} end else


      if ((xpos=2) and (ypos=1)) then {blue}begin
                   red               := img[0,y-1,x  ] ; {near red pixel};
                   img_temp2[1,y,x]:= img[0,y  ,x+1]; {near green pixel};
                   blue              := img[0,y  ,x  ]; end else
      if ((xpos=2) and (ypos=3)) then {blue}begin
                   red               := img[0,y+1,x  ]; {near red pixel};
                   img_temp2[1,y,x]:= img[0,y  ,x+1]; {near green pixel};
                   blue              := img[0,y  ,x  ]; end else


      if ((xpos=1) and (ypos=2)) then {red}begin
                   red             :=   img[0,y,x   ];
                   img_temp2[1,y,x]:=   img[0,y,x+1 ];{near green pixel(s)};
                   blue            :=   img[0,y,x-1 ]; {near blue pixel(s)} end else

      if ((xpos=3) and (ypos=2)) then {red}begin
                   red             :=   img[0,y  ,x  ];
                   img_temp2[1,y,x]:=   img[0,y+1,x  ]; {near green pixel(s)};
                   blue            :=   img[0,y  ,x+1]; {near blue pixel(s)} end;

      {fix red and green swap}
      if ((xpos6<=3) and (ypos6<=3)) then begin img_temp2[0,y,x]:=red;  img_temp2[2,y,x]:=blue;end else
      if ((xpos6> 3) and (ypos6<=3)) then begin img_temp2[0,y,x]:=blue; img_temp2[2,y,x]:=red;end else
      if ((xpos6<=3) and (ypos6> 3)) then begin img_temp2[0,y,x]:=blue; img_temp2[2,y,x]:=red;end else
      if ((xpos6> 3) and (ypos6> 3)) then begin img_temp2[0,y,x]:=red;  img_temp2[2,y,x]:=blue;end;

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

  setlength(img_temp2,3,head.height,head.width);{set length of image array color}

  for y := 0 to head.height-2 do   {-2 = -1 -1}
    for x:=0 to head.width-2 do
  begin {clear green}
      img_temp2[1,y,x]:=0;
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

      value:=img[0,y,x];

      if ((green_odd) or (green_even)) then
      begin
        value:=value/2;
        img_temp2[1,y  ,x]  :=img_temp2[1,y  ,x]+value;
        img_temp2[1,y+1,x]  :=img_temp2[1,y+1,x]+value;
        img_temp2[1,y  ,x+1]:=img_temp2[1,y  ,x+1]+value;
        img_temp2[1,y+1,x+1]:=img_temp2[1,y+1,x+1]+value;
      end
      else
      if red then
      begin
        img_temp2[0,y  ,x]:=value;
        img_temp2[0,y  ,x+1]:=value;
        img_temp2[0,y+1,x]:=value;
        img_temp2[0,y+1,x+1]:=value;
      end
      else
      if blue then
      begin
        img_temp2[2,y  ,x]:=value;
        img_temp2[2,y  ,x+1]:=value;
        img_temp2[2,y+1,x]:=value;
        img_temp2[2,y+1,x+1]:=value;
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

  setlength(img_temp2,3,head.height,head.width);{set length of image array color}

  for y := 0 to head.height-2 do   {-2 = -1 -1}
    for x:=0 to head.width-2 do
  begin {clear green}
      img_temp2[1,y,x]:=0;
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

      value:=img[0, y, x ];

      if green_even then
      begin
        value:=value/2;
        img_temp2[1,y  ,x  ]:=img_temp2[1,y,x]+value;
        img_temp2[1,y  ,x-1]:=img_temp2[1,y,x-1]+value;
        img_temp2[1,y-1,x  ]:=img_temp2[1,y-1,x]+value;
        img_temp2[1,y-1,x-1]:=img_temp2[1,y-1,x-1]+value;
      end
      else
      if green_odd then
      begin
        value:=value/2;
        img_temp2[1,y  ,x  ]:=img_temp2[1,y,x]+value;
        img_temp2[1,y  ,x+1]:=img_temp2[1,y,x+1]+value;
        img_temp2[1,y+1,x  ]:=img_temp2[1,y+1,x]+value;
        img_temp2[1,y+1,x+1]:=img_temp2[1,y+1,x+1]+value;
      end
      else

      if red then
      begin
        img_temp2[0,y  ,x  ]:=value;
        img_temp2[0,y  ,x+1]:=value;
        img_temp2[0,y-1,x  ]:=value;
        img_temp2[0,y-1,x+1]:=value;
      end
      else
      if blue then
      begin
        img_temp2[2,y  ,x  ]:=value;
        img_temp2[2,y  ,x-1]:=value;
        img_temp2[2,y+1,x  ]:=value;
        img_temp2[2,y+1,x-1]:=value;
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
  setlength(img_temp2,3,head.height,head.width);{set length of image array color}
  {calculate mean background value}
  count:=0;
  bg:=0;
  for y:= 10 to (head.height-10) div 100  do
  for x:=10 to (head.width-10) div 100 do
  begin
    bg:=bg+img[0,y,x]+
    img[0,y  ,x+1  ]+
    img[0,y+1,x  ]+
    img[0,y+1,x+1];
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
                   a1:=img[0,y-1,x  ];
                   a2:=img[0,y+1,x  ];
                   average1:=(a1+a2)/2;{red neighbor pixels };

                   average2:=(img[0,  y  ,x] );

                   a3:=img[0,y  ,x-1];
                   a4:=img[0,y  ,x+1];
                   average3:=(a3+a4)/2; {blue neighbor pixels }

                   if ((a1>average1+signal) or (a2>average1+signal) or (a3>average2+signal) or (a4>average2+signal)) {severe magnitude_slope} then
                   begin
                     luminance:=(average1+average2+average3)/3;
                     img_temp2[0,y,x]:=luminance;{remove color info, keep luminace}
                     img_temp2[1,y,x]:=luminance;
                     img_temp2[2,y,x]:=luminance;
                   end
                   else
                   begin
                     img_temp2[0,y,x]:=average1;
                     img_temp2[1,y,x]:=average2;
                     img_temp2[2,y,x]:=average3;

                   end;
                 end
      else
      if green_even then
                    begin
                      a1:=img[0,y  ,x-1];
                      a2:=img[0,y  ,x+1];
                      average1:=(a1+a2)/2;{red neighbor pixels };

                      average2:=     (img[0,  y  ,x] );

                      a3:=img[0,y-1,x  ];
                      a4:=img[0,y+1,x  ];
                      average3:=(a3+a4)/2; {blue neighbor pixels };

                      if ((a1>average1+signal) or (a2>average1+signal) or (a3>average2+signal) or (a4>average2+signal)) {severe magnitude_slope} then
                     begin
                       luminance:=(average1+average2+average3)/3;
                       img_temp2[0,y,x]:=luminance;{remove color info, keep luminace}
                       img_temp2[1,y,x]:=luminance;
                       img_temp2[2,y,x]:=luminance;
                     end
                     else
                     begin
                       img_temp2[0,y,x]:=average1;
                       img_temp2[1,y,x]:=average2;
                       img_temp2[2,y,x]:=average3;

                     end;
                   end
      else
      if red then begin
                   average1:=(img[0,  y  ,x]);

                   a1:= img[0,y  ,x-1];
                   a2:= img[0,y  ,x+1];
                   a3:= img[0,y-1,x  ];
                   a4:= img[0,y+1,x  ];{green neighbours}
                   average2:=(a1+a2+a3+a4)/4;


                   a5:= img[0,y-1,x-1];
                   a6:= img[0,y+1,x-1];
                   a7:= img[0,y-1,x+1];
                   a8:= img[0,y+1,x+1];{blue neighbours}
                   average3:=(a5+a6+a7+a8)/4;

                   if ((a1>average2+signal2) or (a2>average2+signal2) or (a3>average2+signal2) or (a4>average2+signal2) or
                       (a5>average3+signal2) or (a6>average3+signal2) or (a7>average3+signal2) or (a8>average3+signal2) ) then {severe magnitude_slope}
                   begin
                     luminance:=(average1+average2+average3)/3;
                     img_temp2[0,y,x]:=luminance;{remove color info, keep luminace}
                     img_temp2[1,y,x]:=luminance;
                     img_temp2[2,y,x]:=luminance;
                   end
                   else
                   begin
                     img_temp2[0,y,x]:=average1;
                     img_temp2[1,y,x]:=average2;
                     img_temp2[2,y,x]:=average3;
                   end;

      end

      else
      if blue then
                 begin
                   average1:=(img[0,  y  ,x]);

                   a1:= img[0,y-1,x-1];
                   a2:= img[0,y+1,x-1];
                   a3:= img[0,y-1,x+1];
                   a4:= img[0,y+1,x+1];{red neighbours}
                   average1:=(a1+a2+a3+a4)/4;

                   a5:= img[0,y  ,x-1];
                   a6:= img[0,y  ,x+1];
                   a7:= img[0,y-1,x  ];
                   a8:= img[0,y+1,x  ];{green neighbours}
                   average2:=(a5+a6+a7+a8)/4;

                   average3:=img[0,  y  ,x];

                   if ((a1>average1+signal2) or (a2>average1+signal2) or (a3>average1+signal2) or (a4>average1+signal2) or
                       (a5>average2+signal2) or (a6>average2+signal2) or (a7>average2+signal2) or (a8>average2+signal2) ) then {severe magnitude_slope}
                   begin
                     luminance:=(average1+average2+average3)/3;
                     img_temp2[0,y,x]:=luminance;{remove color info, keep luminace}
                     img_temp2[1,y,x]:=luminance;
                     img_temp2[2,y,x]:=luminance;
                   end
                   else
                   begin
                     img_temp2[0,y,x]:=average1;
                     img_temp2[1,y,x]:=average2;
                     img_temp2[2,y,x]:=average3;


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

  setlength(img_temp2,3,head.height,head.width);{set length of image array color}

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
                   a1:=img[0,y-1,x  ];
                   a2:=img[0,y+1,x  ];
                   average1:=(a1+a2)/2;{red neighbor pixels };

                   average2:=(img[0,  y  ,x] );

                   a3:=img[0,y  ,x-1];
                   a4:=img[0,y  ,x+1];
                   average3:=(a3+a4)/2; {blue neighbor pixels }

                   if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation)) {saturation} then
                   begin
                     img_temp2[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2[1,y,x]:=$FFFFFF;{marker pixel as saturated}
                   end
                   else
                   begin
                     img_temp2[0,y,x]:=average1;
                     img_temp2[1,y,x]:=average2;
                     img_temp2[2,y,x]:=average3;
                   end;
                 end
      else
      if green_even then
                    begin
                      a1:=img[0,y  ,x-1];
                      a2:=img[0,y  ,x+1];
                      average1:=(a1+a2)/2;{red neighbor pixels };

                      average2:=     (img[0,  y  ,x] );

                      a3:=img[0,y-1,x  ];
                      a4:=img[0,y+1,x  ];
                      average3:=(a3+a4)/2; {blue neighbor pixels };

                     if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation)) {saturation} then
                     begin
                       img_temp2[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                       img_temp2[1,y,x]:=$FFFFFF;{marker pixel as saturated}
                     end
                     else
                     begin
                       img_temp2[0,y,x]:=average1;
                       img_temp2[1,y,x]:=average2;
                       img_temp2[2,y,x]:=average3;

                     end;
                   end
      else
      if red then begin
                   average1:=(img[0,  y  ,x]);

                   a1:= img[0,y  ,x-1];
                   a2:= img[0,y  ,x+1];
                   a3:= img[0,y-1,x  ];
                   a4:= img[0,y+1,x  ];{green neighbours}
                   average2:=(a1+a2+a3+a4)/4;


                   a5:= img[0,y-1,x-1];
                   a6:= img[0,y+1,x-1];
                   a7:= img[0,y-1,x+1];
                   a8:= img[0,y+1,x+1];{blue neighbours}
                   average3:=(a5+a6+a7+a8)/4;

                   if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation) or
                       (a5>saturation) or (a6>saturation) or (a7>saturation) or (a8>saturation) ) then {saturation}
                   begin
                     img_temp2[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2[1,y,x]:=$FFFFFF;{marker pixel as saturated}

                   end
                   else
                   begin
                     img_temp2[0,y,x]:=average1;
                     img_temp2[1,y,x]:=average2;
                     img_temp2[2,y,x]:=average3;

                     {calculate background}
                     bg:=bg+average1+average2+average3;
                     inc(counter,3); {added red, green, blue values}
                   end;
      end
      else
      if blue then
                 begin
                   average1:=(img[0,  y  ,x]);

                   a1:= img[0,y-1,x-1];
                   a2:= img[0,y+1,x-1];
                   a3:= img[0,y-1,x+1];
                   a4:= img[0,y+1,x+1];{red neighbours}
                   average1:=(a1+a2+a3+a4)/4;

                   a5:= img[0,y  ,x-1];
                   a6:= img[0,y  ,x+1];
                   a7:= img[0,y-1,x  ];
                   a8:= img[0,y+1,x  ];{green neighbours}
                   average2:=(a5+a6+a7+a8)/4;

                   average3:=img[0,  y  ,x];

                   if ((a1>saturation) or (a2>saturation) or (a3>saturation) or (a4>saturation) or
                       (a5>saturation) or (a6>saturation) or (a7>saturation) or (a8>saturation) ) then {saturation}
                   begin
                     img_temp2[0,y,x]:=(average1+average2+average3)/3;{store luminance}
                     img_temp2[1,y,x]:=$FFFFFF;{marker pixel as saturated}
                   end
                   else
                   begin
                     img_temp2[0,y,x]:=average1;
                     img_temp2[1,y,x]:=average2;
                     img_temp2[2,y,x]:=average3;

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
    if img_temp2[1,fitsY,fitsX]=$FFFFFF {marker saturated} then
    begin
      colred:=0;
      colgreen:=0;
      colblue:=0;
      counter:=0;
      inc(sat_counter);
      luminance:=img_temp2[0,fitsY,fitsX];
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
               g:= img_temp2[1,y2,x2];
               if g<>$FFFFFF {not saturated pixel} then
               begin
                 r:= img_temp2[0,y2,x2];
                 B:= img_temp2[2,y2,x2];

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
        img[0,  fitsY  ,fitsX  ]:=bg+ luminance*colred/rgb;
        img[1,  fitsY  ,fitsX  ]:=bg+ luminance*colgreen/rgb;
        img[2,  fitsY  ,fitsX  ]:=bg+ luminance*colblue/rgb;
      end
      else
      begin
       img[1,  fitsY  ,fitsX  ]:=img_temp2[0,  fitsY  ,fitsX  ];
       img[2,  fitsY  ,fitsX  ]:=img_temp2[0,  fitsY  ,fitsX  ];

      end;
    end;
  end{not full saturated}
  else
  begin {fully saturated image}
    for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1 do
    begin
      img[0,  fitsY  ,fitsX  ]:=saturation;
      img[1,  fitsY  ,fitsX  ]:=saturation;
      img[2,  fitsY  ,fitsX  ]:=saturation;
    end;
  end;

  if sat_counter/(head.width*head.height)>0.1 then memo2_message('█ █ █ █ █ █  More than 10% of the image is saturated and will give poor results!! Try demosaic method AstroSimple and exposure shorter next time. █ █ █ █ █ █ ');
  img_temp2:=nil;{free temp memory}
  head.naxis3:=3;{now three colors. Header string will be updated by saving or calling procedure update_header_for_colour}
  head.naxis:=3; {from 2 to 3 dimensions. Header string will be updated by saving or calling procedure update_header_for_colour}
end;


procedure demosaic_superpixel(var img:image_array; pattern: integer);{make from sensor bayer pattern the three colors}
var
    x,y,x2,y2,w,h: integer;
    img_temp2 : image_array;
begin
  w:=head.width div 2;
  h:=head.height div 2;
  setlength(img_temp2,3,h,w);{set length of image array color}

  if pattern=0 then {GRBG}
  for y := 0 to h-1 do
  begin
    for x:=0 to w-1 do
    begin
      try
      x2:=x+x;
      y2:=y+y;
      img_temp2[0,y,x]:= img[0,y2  ,x2+1];
      img_temp2[1,y,x]:=(img[0,y2  ,x2  ] + img[0,y2+1  ,x2+1])/2;
      img_temp2[2,y,x]:= img[0,y2+1,x2  ];
      except
      end;
    end;{x loop}
  end {y loop}
  else
  if pattern=1 then {BGGR}
  for y := 0 to h-1 do
  begin
    for x:=0 to w-1 do
    begin
      try
      x2:=x+x;
      y2:=y+y;
      img_temp2[0,y,x]:= img[0,y2+1,x2+1];
      img_temp2[1,y,x]:=(img[0,y2  ,x2+1] + img[0,y2+1  ,x2])/2;
      img_temp2[2,y,x]:= img[0,y2  ,x2  ];
      except
      end;
    end;{x loop}
  end {y loop}
  else

  if pattern=2 then {RGGB}
  for y := 0 to h-1 do
  begin
    for x:=0 to w-1 do
    begin
      try
      x2:=x+x;
      y2:=y+y;
      img_temp2[0,y,x]:= img[0,y2  ,x2];
      img_temp2[1,y,x]:=(img[0,y2  ,x2+1] + img[0,y2+1  ,x2])/2;
      img_temp2[2,y,x]:= img[0,y2+1,x2+1];
      except
      end;
    end;{x loop}
  end {y loop}
  else

  if pattern=3 then {GBRG}
  for y := 0 to h-1 do
  begin
    for x:=0 to w-1 do
    begin
      try
      x2:=x+x;
      y2:=y+y;
      img_temp2[0,y,x]:= img[0,y2+1,x2];
      img_temp2[1,y,x]:=(img[0,y2  ,x2  ] + img[0,y2+1  ,x2+1])/2;
      img_temp2[2,y,x]:= img[0,y2  ,x2+1];
      except
      end;
    end;{x loop}
  end;{y loop}

  img:=img_temp2;
  head.width:=w;
  head.height:=h;

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
      if ((img[0,fitsY*2  ,fitsx*2  ]>65500) or
          (img[0,fitsY*2  ,fitsx*2+1]>65500) or
          (img[0,fitsY*2+1,fitsx*2  ]>65500) or
          (img[0,fitsY*2+1,fitsx*2+1]>65500) )   then {saturation}
      begin
       img[0,fitsY*2  ,fitsx*2  ]:=img[0,fitsY*2  ,(fitsx-1)*2  ];
       img[0,fitsY*2  ,fitsx*2+1]:=img[0,fitsY*2  ,(fitsx-1)*2+1];
       img[0,fitsY*2+1,fitsx*2  ]:=img[0,fitsY*2+1,(fitsx-1)*2  ];
       img[0,fitsY*2+1,fitsx*2+1]:=img[0,fitsY*2+1,(fitsx-1)*2+1];

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
  begin
    pattern:=bayerpat {from fits header}
  end
  else
    pattern:=stackmenu1.bayer_pattern1.text;

  if length(pattern)<4 then pattern:='RGGB';//not specified, prevent errors in next code


  if pattern=bayer_pattern[2]{'RGGB'} then begin result:=2; {offsetx:=1; offsety:=0;} end {ASI294, ASI071, most common pattern}
  else
  if pattern=bayer_pattern[0]{'GRBG'} then begin result:=0  {offsetx:=0; offsety:=0;} end {ASI1600MC}
  else
  if pattern=bayer_pattern[1]{'BGGR'} then begin result:=1  {offsetx:=0; offsety:=1;} end
  else
  if pattern=bayer_pattern[3]{'GBRG'} then begin result:=3; {offsetx:=1; offsety:=1;} end
  else
  if ((pattern=bayer_pattern[4]{'GGGG'}) or (pattern[1]='X')) then begin result:=4; {FILT-PAT= 'GGGGBRGGGGRBGGGG',   BAYERPAT= 'GGGG'  Fujifilm X-trans} end
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
var
   pattern : integer;
begin
  pattern:= get_demosaic_pattern;

  if pattern=4  then {Fuji film X-trans}
    demosaic_x_trans(img){make from Fuji X-trans three colors}
  else
  if pos('AstroC',stackmenu1.demosaic_method1.text)<>0  then
  begin
    if head.datamax_org>16384 then demosaic_astroC_bilinear_interpolation(img,65535 div 2,pattern){16 bit image. Make from sensor bayer pattern the three colors}
    else
    if head.datamax_org>4096 then demosaic_astroC_bilinear_interpolation(img,16383 div 2,pattern){14 bit image. Make from sensor bayer pattern the three colors}
    else
    demosaic_astroC_bilinear_interpolation(img,4095 div 2,pattern){12 bit image. Make from sensor bayer pattern the three colors}
  end
  else
  if pos('Simple',stackmenu1.demosaic_method1.text)<>0  then {}
    demosaic_astrosimple(img,pattern){make from sensor bayer pattern the three colors}
  else
  if pos('AstroM',stackmenu1.demosaic_method1.text)<>0  then {}
    demosaic_astroM_bilinear_interpolation(img,pattern){make from sensor bayer pattern the three colors}
  else
  if pos('Super',stackmenu1.demosaic_method1.text)<>0  then {}
    demosaic_superpixel(img,pattern){make from sensor bayer pattern the three colors}
  else
  demosaic_bilinear_interpolation(img,pattern);{use Bilinear interpolation. Make from sensor bayer pattern the three colors}
end;


procedure demosaic_advanced(var img : image_array);{demosaic img}
begin
  demosaic_bayer(img);
  memo2_message('De-mosaic bayer pattern used '+bayer_pattern[bayerpattern_final]);

  if stackmenu1.osc_auto_level1.checked then
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
var
   i,j,col,col_r,col_g,col_b,linenr,columnr :integer;
   colrr,colgg,colbb,luminance, luminance_stretched,factor, largest, sat_factor,h,s,v: single;
   Bitmap  : TBitmap;{for fast pixel routine}
   xLine :  PByteArray;{for fast pixel routine}
   flipv, fliph : boolean;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

//  if img.visible=false then img.visible:=true;

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


  bck.backgr:=mainwindow.minimum1.position;
  cwhite:=mainwindow.maximum1.position;
  if cwhite<=bck.backgr then cwhite:=bck.backgr+1;

  flipv:=mainwindow.flip_vertical1.Checked;
  fliph:=mainwindow.Flip_horizontal1.Checked;

  for i:=0 to head.height-1 do
  begin
    if flipv then linenr:=i else linenr:=(head.height-1)-i;{flip vertical?. Note FITS count from bottom, windows from top}
    xLine := Bitmap.ScanLine[linenr];
    for j:=0 to head.width-1 do
    begin
      if fliph then columnr:=(head.width-1)-j else columnr:=j;{flip horizontal?}
      col:=round(img_loaded[0,i,columnr]);
      colrr:=(col-bck.backgr)/(cwhite-bck.backgr);{scale to 1}

      if head.naxis3>=2 then {at least two colours}
      begin
        col:=round(img_loaded[1,i,columnr]);
        colgg:=(col-bck.backgr)/(cwhite-bck.backgr);{scale to 1}
      end
      else
      colgg:=colrr;

      if head.naxis3>=3 then {at least three colours}
      begin
        col:=round(img_loaded[2,i,columnr]);
        colbb:=(col-bck.backgr)/(cwhite-bck.backgr);{scale to 1}

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
        xLine^[j*3]  :=col_b; {3*8=24 bit}
        xLine^[j*3+1]:=col_g; {fast pixel write routine }
        xLine^[j*3+2]:=col_r;
     {$endif}
     {$ifdef darwin} {MacOS}
        xLine^[j*4+1]:=col_r; {4*8=32 bit}
        xLine^[j*4+2]:=col_g; {fast pixel write routine }
        xLine^[j*4+3]:=col_b;
     {$endif}
     {$ifdef linux}
        xLine^[j*4]  :=col_b; {4*8=32 bit}
        xLine^[j*4+1]:=col_g; {fast pixel write routine }
        xLine^[j*4+2]:=col_r;
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
    img.left:=(mainwindow.width - round(mainwindow.panel1.height*head.width/head.height)) div 2;
  end;
  img.width:=round(img.height*head.width/head.height); {lock image aspect always for case a image with a different is clicked on in stack menu}


  if img=mainwindow.image1 then {plotting to mainwindow?}
  begin
    plot_north; {draw arrow or clear indication position north depending on value head.cd1_1}
    plot_north_on_image;
    plot_large_north_indicator;
    if mainwindow.add_marker_position1.checked then
      mainwindow.add_marker_position1.checked:=place_marker3(marker_position);{place a marker}
    plot_grid(true);
    plot_grid(false);//az,alt
    plot_constellations;
    plot_text;
    if ((annotated) and (mainwindow.annotations_visible1.checked)) then plot_annotations(false {use solution vectors},false);

    //place markers based on ra, dec position. Using stored fitsX, fitsY is not reliable due to drift
    if mainwindow.shape_var1.visible then {For manual alignment. Do this only when visible}
      place_marker_radec(mainwindow.shape_var1,shape_var1_ra,shape_var1_dec);//place ra,dec marker in image based on the ra,dec position
    if mainwindow.shape_check1.visible then {For manual alignment. Do this only when visible}
      place_marker_radec(mainwindow.shape_check1,shape_check1_ra,shape_check1_dec);//place ra,dec marker in image based on the ra,dec position
    if mainwindow.shape_star3.visible then {For manual alignment. Do this only when visible}
      place_marker_radec(mainwindow.shape_star3,shape_star3_ra,shape_star3_dec);//place ra,dec marker in image based on the ra,dec position

    if mainwindow.shape_var2.visible then //update the shape position based on ra,dec values
    begin
      place_marker_radec(mainwindow.shape_var2,shape_var2_ra,shape_var2_dec);//place ra,dec marker in image
      place_marker_radec(mainwindow.shape_check2,shape_check2_ra,shape_check2_dec);//place ra,dec marker in image
    end;


    mainwindow.statusbar1.panels[5].text:=inttostr(head.width)+' x '+inttostr(head.height)+' x '+inttostr(head.naxis3)+'   '+inttostr(nrbits)+' BPP';{give image dimensions and bit per pixel info}
    update_statusbar_section5;{update section 5 with image dimensions in degrees}
    mainwindow.statusbar1.panels[7].text:=''; {2020-2-15 moved from load_fits to plot_image. Clear any outstanding error}

    update_menu(true);{2020-2-15 moved from load_fits to plot_image.  file loaded, update menu for fits}
  end;

  {do refresh at the end for smooth display, especially for blinking }
//  img.refresh;{important, show update}

  if img.visible=false then
    img.visible:=true //will also refresh. This is only done once during startup
  else
    img.invalidate;{important, show update. NoTe refresh aligns image to the left!!}


  quads_displayed:=false; {displaying quads doesn't require a screen refresh}

  Screen.Cursor:=crDefault;
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
  width5:=Length(img[0,0]);    {width}
  height5:=Length(img[0]); {height}

  offsetW:=trunc(width5*0.042); {if Libraw is used, ignored unused sensor areas up to 4.2%}
  offsetH:=trunc(height5*0.015); {if Libraw is used, ignored unused sensor areas up to 1.5%}


  For i:=0+offsetH to height5-1-offsetH do
  begin
    for j:=0+offsetW to width5-1-offsetW do
    begin
      col:=round(img[colour,i,j]);{red}
      if ((col>=1) and (col<65000)) then {ignore black overlap areas and bright stars}
      begin
        inc(histogram[colour,col],1);{calculate histogram}
        his_total:=his_total+1;
        total_value:=total_value+col;
        inc(count);
      end;
    end;{j}
  end; {i}

  if colour=0 then his_total_red:=his_total;
  his_mean[colour]:=round(total_value/count);

end;

procedure use_histogram(img: image_array; update_hist: boolean);{calculate histogram}
var
  i, minm,maxm,max_range, countR,countG,countB,stopXpos,Xpos,max_color,histo_peakR,number_colors, histo_peak_position,h,w,col : integer;
  above, above_R          : double;
  histogram2 : array of array of integer;
  histo_peak : array[0..2] of integer;

begin
//  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

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

  hist_range:=min(65535,round(min(head.datamax_org,2*maxm)));{adapt histogram range}
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

  histogram2:=nil;
  Screen.Cursor:=crDefault;
end;


function save_tiff16_secure(img : image_array; memo: tstrings;filen2:string) : boolean;{guarantee no file is lost}
var
  filename_tmp : string;
begin
  result:=false;{assume failure}
  filename_tmp:=changeFileExt(filen2,'.tmp');{new file will be first written to this file}
  if  save_tiff16(img, memo, filename_tmp,false {flip H},false {flip V}) then
  begin
    if deletefile(filen2) then
      result:=renamefile(filename_tmp,filen2);
  end;
end;



function savefits_update_header(memo: tstrings; filen2:string) : boolean;{save fits file with updated header}
var
  TheFile  : tfilestream;
  reader_position,I,readsize,bufsize : integer;
  TheFile_new : tfilestream;
  fract       : double;
  line0       : ansistring;
  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}
  header    : array[0..2880] of ansichar;
  endfound  : boolean;
  filename_tmp: string;

     procedure close_fits_files;
     begin
        Reader.free;
        TheFile.free;
        TheFile_new.free;
     end;
begin
  result:=false;{assume failure}
  filename_tmp:=changeFileExt(filen2,'.tmp');{new file will be first written to this file}
  try
    TheFile_new:=tfilestream.Create(filename_tmp, fmcreate );
    TheFile:=tfilestream.Create(filen2, fmOpenRead or fmShareDenyWrite);
    Reader := TReader.Create (TheFile,$60000);// 393216 byte buffer

   // if head.calstat<>'' then update_text(memo,'CALSTAT =',#39+old_calstat+#39); {calibration status has not change because the image is original}
    {TheFile.size-reader.position>sizeof(hnskyhdr) could also be used but slow down a factor of 2 !!!}
    I:=0;
    reader_position:=0;
    repeat
      reader.read(header[i],80); {read file info, 80 bytes only}
      inc(reader_position,80);
      endfound:=((header[i]='E') and (header[i+1]='N')  and (header[i+2]='D') and (header[i+3]=' '));
    until ((endfound) or (I>=sizeof(header)-16 ));
    if endfound=false then
    begin
      close_fits_files;
      beep;
      memo2_message('Abort, error reading source FITS file!!');
      exit;
    end;

    fract:=frac(reader_position/2880);

    if fract<>0 then
    begin
      i:=round((1-fract)*2880);{left part of next 2880 bytes block}
      reader.read(header[0],i); {skip empty part and go to image data}
      inc(reader_position,i);
    end;
    {reader is now at begin of image data}

    {write updated header}
    for i:=0 to 79 do empthy_line[i]:=#32;{space}
    i:=0;
    repeat
       if i<memo.count then
       begin
         line0:=memo[i];
         while length(line0)<80 do line0:=line0+' ';{guarantee length is 80}
         strpcopy(aline,(copy(line0,1,80)));{copy 80 and not more}
         thefile_new.writebuffer(aline,80);{write updated header from memo1.}
       end
       else
       begin
          thefile_new.writebuffer(empthy_line,80);{write empthy line}
       end;
       inc(i);
    until ((i>=memo.count) and (frac(i*80/2880)=0)); {write multiply records 36x80 or 2880 bytes}

    bufsize:=sizeof(fitsbuffer);
    repeat
       readsize:=min(bufsize,TheFile.size-reader_position);{read flexible in buffersize and not in fixed steps of 2880 bytes. Note some file are not following the FITS standard of blocksize of 2880 bytes causing problem if fixed 2880 bytes are used}
       reader.read(fitsbuffer,readsize);
       inc(reader_position,readsize);
       thefile_new.writebuffer(fitsbuffer,readsize); {write buffer}
     until (reader_position>=TheFile.size);

    Reader.free;
    TheFile.free;
    TheFile_new.free;

    if deletefile(filen2) then
      result:=renamefile(filename_tmp,filen2);
  except
    close_fits_files;
    beep;
    exit;
  end;
end;

{$ifdef mswindows}
procedure ExecuteAndWait(const aCommando: string;show_console:boolean);
var
  tmpStartupInfo: TStartupInfo;
  tmpProcessInformation: TProcessInformation;
  tmpProgram: String;

begin
  tmpProgram := trim(aCommando);
  FillChar(tmpStartupInfo, SizeOf(tmpStartupInfo), 0);
  with tmpStartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    if show_console=false then
    begin
      dwFlags := STARTF_USESHOWWINDOW;
      wShowWindow := SW_SHOWMINIMIZED;
    end
    else
    wShowWindow := SW_HIDE;
  end;
  if CreateProcess(nil, pchar(tmpProgram), nil, nil, true,CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,  nil, nil, tmpStartupInfo, tmpProcessInformation) then
  begin // loop every 100 ms
    while WaitForSingleObject(tmpProcessInformation.hProcess, 100) > 0 do
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
      stackmenu1.annotations_visible2.checked:=bool;{set both indicators}


      northeast1.checked:=Sett.ReadBool('main','north_east',false);
      star_profile1.checked:=Sett.ReadBool('main','star_profile',false);
      mountposition1.checked:=Sett.ReadBool('main','mount_position',false);
      Constellations1.checked:=Sett.ReadBool('main','constellations',false);
      grid_ra_dec1.checked:=Sett.ReadBool('main','grid',false);
      grid_az_alt1.checked:=Sett.ReadBool('main','grid_az',false);
      positionanddate1.checked:=Sett.ReadBool('main','pos_date',false);
      freetext1.checked:=Sett.ReadBool('main','freetxt',false);
      freetext:=Sett.ReadString('main','f_text','');

      noise_in_electron1.checked:=Sett.ReadBool('main','noise_e',false);{status bar menu}
      egain_default:=Sett.ReadFloat('main','egain_d',1);
      egain_extra_factor:=Sett.ReadInteger('main','egain_ext',16);


      add_marker_position1.checked:=Sett.ReadBool('main','add_marker',false);{popup marker selected?}

      mainwindow.preview_demosaic1.Checked:=Sett.ReadBool('main','preview_demosaic',false);
      mainwindow.batch_overwrite1.checked:=Sett.ReadBool('main','s_overwrite',false);
      mainwindow.maintain_date1.Checked:=Sett.ReadBool('main','maintain_date',false);


      mainwindow.add_limiting_magn_check1.Checked:=Sett.ReadBool('main','add_lim_magn',false);

      marker_position :=Sett.ReadString('main','marker_position','');{ra, dec marker}
      mainwindow.shape_marker3.hint:=marker_position;

      ra1.text:= Sett.ReadString('main','ra','0');
      dec1.text:= Sett.ReadString('main','dec','0');

      stretch1.text:= Sett.ReadString('main','gamma','');
      if paramcount=0 then filename2:=Sett.ReadString('main','last_file','');{if used as viewer don't override paramstr1}
      export_index:=Sett.ReadInteger('main','export_index',3);{tiff stretched}
      annotation_magn:=Sett.ReadString('main', 'anno_magn',annotation_magn);
      cal_batch1.Checked:=Sett.ReadBool('main','cal_batch',false);



      dum:=Sett.ReadString('ast','mpcorb_path','');if dum<>'' then mpcorb_path:=dum;{asteroids}
      dum:=Sett.ReadString('ast','cometels_path','');if dum<>'' then cometels_path:=dum;{asteroids}

      dum:=Sett.ReadString('ast','maxcount','');if dum<>'' then maxcount_asteroid:=dum;{asteroids}
      dum:=Sett.ReadString('ast','maxmag','');if dum<>'' then maxmag_asteroid:=dum;{asteroids}


      font_follows_diameter:=Sett.ReadBool('ast','font_follows',false);{asteroids}
      showfullnames:=Sett.ReadBool('ast','showfullnames',true);{asteroids}
      showmagnitude:=Sett.ReadBool('ast','showmagnitude',false);{asteroids}
      add_date:=Sett.ReadBool('ast','add_date',true);{asteroids}
      lat_default:=decrypt(Sett.ReadString('ast','p1',''));{lat default}
      long_default:=decrypt(Sett.ReadString('ast','p2',''));{longitude default}

      annotation_color:=Sett.ReadInteger('ast','annotation_color',annotation_color);
      annotation_diameter:=Sett.ReadInteger('ast','annotation_diameter',annotation_diameter);

      add_annotations:=Sett.ReadBool('ast','add_annotations',false);{asteroids as annotations}

      dum:=Sett.ReadString('anet','astrometry_extra_options',''); if dum<>'' then astrometry_extra_options:=dum;{astrometry.net options}
      show_console:=Sett.ReadBool('anet','show_console',true);
      dum:=Sett.ReadString('anet','cygwin_path',''); if dum<>'' then cygwin_path:=dum;

      sqm_applyDF:=Sett.ReadBool('sqm','apply_df',false);{sqm menu}


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
      c:=Sett.ReadInteger('stack','splitter',987654321); if c<>987654321 then stackmenu1.pairsplitter1.position:=c;


      c:=Sett.ReadInteger('stack','mosaic_crop',987654321);if c<>987654321 then stackmenu1.mosaic_crop1.position:=c;

      c:=Sett.ReadInteger('stack','stack_method',987654321); if c<>987654321 then stackmenu1.stack_method1.itemindex:=c;
      c:=Sett.ReadInteger('stack','box_blur_factor',987654321);if c<>987654321 then stackmenu1.box_blur_factor1.itemindex:=c;

      c:=Sett.ReadInteger('stack','stack_tab',987654321); if c<>987654321 then stackmenu1.pagecontrol1.tabindex:=c;

      c:=Sett.ReadInteger('stack','demosaic_method2',987654321); if c<>987654321 then stackmenu1.demosaic_method1.itemindex:=c;

      c:=Sett.ReadInteger('stack','conv_progr',987654321);if c<>987654321 then stackmenu1.raw_conversion_program1.itemindex:=c;


      stackmenu1.make_osc_color1.checked:=Sett.ReadBool('stack','osc_color_convert',false);
      stackmenu1.osc_auto_level1.checked:=Sett.ReadBool('stack','osc_al',true);
      stackmenu1.osc_colour_smooth1.checked:=Sett.ReadBool('stack','osc_cs',true);
      stackmenu1.osc_preserve_r_nebula1.checked:=Sett.ReadBool('stack','osc_pr',true);
      dum:=Sett.ReadString('stack','osc_cw','');if dum<>'' then   stackmenu1.osc_smart_smooth_width1.text:=dum;
      dum:=Sett.ReadString('stack','osc_sd','');  if dum<>'' then stackmenu1.osc_smart_colour_sd1.text:=dum;

      dum:=Sett.ReadString('stack','smooth_dia','');if dum<>'' then   stackmenu1.smooth_diameter1.text:=dum;
      dum:=Sett.ReadString('stack','smooth_stars','');  if dum<>'' then stackmenu1.smooth_stars1.text:=dum;

      dum:=Sett.ReadString('stack','sqm_key',''); if dum<>'' then sqm_key:=copy(dum,1,8);{remove * character used for protection spaces}
      dum:=Sett.ReadString('stack','centaz_key',''); if dum<>'' then centaz_key:=copy(dum,1,8);{remove * character used for protection spaces}

      stackmenu1.lrgb_auto_level1.checked:=Sett.ReadBool('stack','lrgb_al',true);
      stackmenu1.green_purple_filter1.checked:=Sett.ReadBool('stack','green_fl',false);
      stackmenu1.lrgb_colour_smooth1.checked:=Sett.ReadBool('stack','lrgb_cs',true);
      stackmenu1.lrgb_preserve_r_nebula1.checked:=Sett.ReadBool('stack','lrgb_pr',true);

      stackmenu1.lrgb_stars_smooth1.checked:=Sett.ReadBool('stack','lrgb_sm',true);
      dum:=Sett.ReadString('stack','lrgb_smd','');if dum<>'' then   stackmenu1.lrgb_smooth_diameter1.text:=dum;
      dum:=Sett.ReadString('stack','lrgb_sms','');  if dum<>'' then stackmenu1.lrgb_smooth_stars1.text:=dum;


      dum:=Sett.ReadString('stack','lrgb_sw','');if dum<>'' then stackmenu1.lrgb_smart_smooth_width1.text:=dum;
      dum:=Sett.ReadString('stack','lrgb_sd','');if dum<>'' then  stackmenu1.lrgb_smart_colour_sd1.text:=dum;

      stackmenu1.ignore_header_solution1.Checked:= Sett.ReadBool('stack','ignore_header_solution',true);
      stackmenu1.Equalise_background1.checked:= Sett.ReadBool('stack','equalise_background',true);{for mosaic mode}
      stackmenu1.merge_overlap1.checked:= Sett.ReadBool('stack','merge_overlap',true);{for mosaic mode}
      stackmenu1.limit_background_correction1.checked:= Sett.ReadBool('stack','limit_back_corr',true);{for mosaic mode}

      stackmenu1.classify_object1.checked:= Sett.ReadBool('stack','classify_object',false);
      stackmenu1.classify_filter1.checked:= Sett.ReadBool('stack','classify_filter',false);

      stackmenu1.classify_dark_temperature1.checked:= Sett.ReadBool('stack','classify_dark_temp',false);
      stackmenu1.delta_temp1.caption:=Sett.ReadString('stack','delta_temp','1');
      stackmenu1.classify_dark_gain1.checked:= Sett.ReadBool('stack','classify_dark_gain',false);
      stackmenu1.classify_dark_exposure1.checked:= Sett.ReadBool('stack','classify_dark_exposure',false);
      stackmenu1.classify_flat_filter1.checked:= Sett.ReadBool('stack','classify_flat_filter',false);
      stackmenu1.classify_dark_date1.checked:= Sett.ReadBool('stack','classify_dark_date',false);
      stackmenu1.classify_flat_date1.checked:= Sett.ReadBool('stack','classify_flat_date',false);
      stackmenu1.classify_flat_duration1.checked:= Sett.ReadBool('stack','classify_flat_duration',false);

      stackmenu1.add_time1.checked:= Sett.ReadBool('stack','add_time',false); {add a copy of the settings at image path}
      stackmenu1.save_settings_image_path1.checked:= Sett.ReadBool('stack','copy_sett',false); {add time to resulting stack file name}

      stackmenu1.uncheck_outliers1.checked:= Sett.ReadBool('stack','uncheck_outliers',false);

      stackmenu1.blur_factor1.text:= Sett.ReadString('stack','blur_factor','');

      stackmenu1.use_manual_alignment1.checked:=Sett.ReadString('stack','align_method','')='4';
      stackmenu1.use_astrometry_alignment1.checked:=Sett.ReadString('stack','align_method','')='3';
      stackmenu1.use_star_alignment1.checked:=Sett.ReadString('stack','align_method','')='2';
      stackmenu1.use_ephemeris_alignment1.checked:=Sett.ReadString('stack','align_method','')='1';

      stackmenu1.write_log1.Checked:=Sett.ReadBool('stack','write_log',true);{write to log file}
      stackmenu1.align_blink1.Checked:=Sett.ReadBool('stack','align_blink',true);{blink}
      stackmenu1.timestamp1.Checked:=Sett.ReadBool('stack','time_stamp',true);{blink}

      stackmenu1.force_oversize1.Checked:=Sett.ReadBool('stack','force_slow',false);
      stackmenu1.use_triples1.Checked:=Sett.ReadBool('stack','use_triples',false);
      stackmenu1.add_sip1.Checked:=Sett.ReadBool('stack','sip',false);

      dum:=Sett.ReadString('stack','star_database',''); if dum<>'' then stackmenu1.star_database1.text:=dum;
      dum:=Sett.ReadString('stack','solve_search_field',''); if dum<>'' then stackmenu1.search_fov1.text:=dum;

      dum:=Sett.ReadString('stack','radius_search',''); if dum<>'' then stackmenu1.radius_search1.text:=dum;
      dum:=Sett.ReadString('stack','quad_tolerance',''); if dum<>'' then stackmenu1.quad_tolerance1.text:=dum;
      dum:=Sett.ReadString('stack','maximum_stars',''); if dum<>'' then stackmenu1.max_stars1.text:=dum;
      dum:=Sett.ReadString('stack','min_star_size',''); if dum<>'' then stackmenu1.min_star_size1.text:=dum;
      dum:=Sett.ReadString('stack','min_star_size_stacking',''); if dum<>'' then stackmenu1.min_star_size_stacking1.text:=dum;


      dum:=Sett.ReadString('stack','manual_centering',''); if dum<>'' then stackmenu1.manual_centering1.text:=dum;

      dum:=Sett.ReadString('stack','downsample',''); if dum<>'' then stackmenu1.downsample_for_solving1.text:=dum;

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
      dum:=Sett.ReadString('stack','nr_stars_p',''); if dum<>'' then stackmenu1.nr_stars_to_detect1.text:=dum;
      dum:=Sett.ReadString('stack','flux_aperture',''); if dum<>'' then stackmenu1.flux_aperture1.text:=dum;
      dum:=Sett.ReadString('stack','annulus_radius',''); if dum<>'' then stackmenu1.annulus_radius1.text:=dum;
      dum:=Sett.ReadString('stack','font_size_p',''); if dum<>'' then stackmenu1.font_size_photometry1.text:=dum;

      c:=Sett.ReadInteger('stack','annotate_m',0); stackmenu1.annotate_mode1.itemindex:=c;
      c:=Sett.ReadInteger('stack','reference_d',0); stackmenu1.reference_database1.itemindex:=c;
      c:=Sett.ReadInteger('stack','measure_all',0); stackmenu1.measuring_method1.itemindex:=c;

      dum:=Sett.ReadString('stack','sigma_decolour',''); if dum<>'' then stackmenu1.sigma_decolour1.text:=dum;
      dum:=Sett.ReadString('stack','sd_factor_list',''); if dum<>'' then stackmenu1.sd_factor_list1.text:=dum;

      dum:=Sett.ReadString('stack','noisefilter_blur',''); if dum<>'' then stackmenu1.noisefilter_blur1.text:=dum;
      dum:=Sett.ReadString('stack','noisefilter_sd',''); if dum<>'' then stackmenu1.noisefilter_sd1.text:=dum;


      c:=Sett.ReadInteger('stack','hue_fuzziness',987654321); if c<>987654321 then stackmenu1.hue_fuzziness1.position:=c;
      c:=Sett.ReadInteger('stack','saturation_tolerance',987654321);  if c<>987654321 then stackmenu1.saturation_tolerance1.position:=c;
      stackmenu1.blend1.checked:= Sett.ReadBool('stack','blend',true);

      c:=Sett.ReadInteger('stack','sample_size',987654321);if c<>987654321 then stackmenu1.sample_size1.itemindex:=c;

      dum:=Sett.ReadString('stack','usm_amount',''); if dum<>'' then stackmenu1.unsharp_edit_amount1.text:=dum;
      dum:=Sett.ReadString('stack','usm_radius',''); if dum<>'' then stackmenu1.unsharp_edit_radius1.text:=dum;
      dum:=Sett.ReadString('stack','usm_thresh',''); if dum<>'' then stackmenu1.unsharp_edit_threshold1.text:=dum;



      stackmenu1.mount_write_wcs1.Checked:=Sett.ReadBool('stack','wcs',true);{use wcs files for mount}

      c:=Sett.ReadInteger('stack','video_index',987654321);if c<>987654321 then video_index:=c;{blink menu, video}
      dum:=Sett.ReadString('stack','frame_rate',''); if dum<>'' then frame_rate:=dum;

      dum:=Sett.ReadString('stack','contour_gaus',''); if dum<>'' then stackmenu1.contour_gaussian1.text:=dum;
      dum:=Sett.ReadString('stack','contour_sd',''); if dum<>'' then stackmenu1.contour_sigma1.text:=dum;
      dum:=Sett.ReadString('stack','contour_grid',''); if dum<>'' then stackmenu1.detection_grid1.text:=dum;
      groupsizeStr:=Sett.ReadString('stack','groupsize','');



      obscode:=Sett.ReadString('aavso','obscode',''); {photometry}
      delim_pos:=Sett.ReadInteger('aavso','delim_pos',0);
      baa_style:=Sett.ReadBool('aavso','baa_style',false);{aavso report}
      hjd_date:=Sett.ReadBool('aavso','hjd_date',false);{aavso report}
      aavso_filter_index:=Sett.ReadInteger('aavso','pfilter',0);
      magnitude_slope:=Sett.ReadFloat('aavso','slope',0);
      used_check_stars:=Sett.ReadString('aavso','checkstars','');

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
      three_corners:=Sett.ReadBool('insp','3corners',false);
      extra_stars:=Sett.ReadBool('insp','extra_stars',false);

      c:=Sett.ReadInteger('insp','insp_binning',987654321);if c<>987654321 then inspector_binning:=c;

      c:=Sett.ReadInteger('insp','insp_grid',987654321);if c<>987654321 then inspector_grid_size:=c;
      c:=Sett.ReadInteger('insp','insp_grad',987654321);if c<>987654321 then inspector_gradations:=c;

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
    end; //with mainwindow

  finally {also for error it end's here}
    Sett.Free;
  end;

//  mainwindow.Caption := floattostr((GetTickCount-t1)/1000);
end;


procedure save_settings(lpath:string); //save settings at any path
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
      sett.writeBool('main','star_profile',star_profile1.checked);

      sett.writeBool('main','mount_position',mountposition1.checked);
      sett.writeBool('main','constellations',constellations1.checked);
      sett.writeBool('main','grid',grid_ra_dec1.checked);
      sett.writeBool('main','grid_az',grid_az_alt1.checked);
      sett.writeBool('main','pos_date',positionanddate1.checked);
      sett.writeBool('main','freetxt',freetext1.checked);
      sett.writestring('main','f_text',freetext);

      sett.writeBool('main','noise_e',noise_in_electron1.checked);
      sett.writefloat('main','egain_d',egain_default);
      sett.writeinteger('main','egain_ext',egain_extra_factor);

      sett.writeBool('main','add_marker',add_marker_position1.checked);

      sett.writeBool('main','preview_demosaic',mainwindow.preview_demosaic1.Checked);
      sett.writeBool('main','s_overwrite',mainwindow.batch_overwrite1.checked);
      sett.writeBool('main','maintain_date',mainwindow.maintain_date1.Checked);


      sett.writeBool('main','add_lim_magn',mainwindow.add_limiting_magn_check1.Checked);

      sett.writestring('main','ra',ra1.text);
      sett.writestring('main','dec',dec1.text);
      sett.writestring('main','gamma',stretch1.text);
      sett.writestring('main','marker_position',marker_position);


      sett.writestring('main','last_file',filename2);
      sett.writeInteger('main','export_index',export_index);
      sett.writestring('main','anno_magn',annotation_magn);
      sett.writeBool('main','cal_batch',cal_batch1.checked);


      sett.writestring('ast','mpcorb_path',mpcorb_path);{asteroids}
      sett.writestring('ast','cometels_path',cometels_path);{comets}

      sett.writeString('ast','maxcount',maxcount_asteroid);{asteroids}
      sett.writeString('ast','maxmag',maxmag_asteroid);{asteroids}

      sett.writeBool('ast','font_follows',font_follows_diameter);{asteroids}
      sett.writeBool('ast','showfullnames',showfullnames);{asteroids}
      sett.writeBool('ast','showmagnitude',showmagnitude);{asteroids}
      sett.writeBool('ast','add_date',add_date);{asteroids}
      sett.writeString('ast','p1',encrypt(lat_default));{default latitude}
      sett.writeString('ast','p2',encrypt(long_default));{default longitude}

      sett.writeInteger('ast','annotation_color',annotation_color);
      sett.writeInteger('ast','annotation_diameter',annotation_diameter);

      sett.writeBool('ast','add_annotations',add_annotations);{for asteroids}

      sett.writestring('anet','cygwin_path',cygwin_path);
      sett.writeBool('anet','show_console',show_console);
      sett.writestring('anet','astrometry_extra_options',astrometry_extra_options);

      sett.writeBool('sqm','apply_df',sqm_applyDF);


      for c:=0 to recent_files.count-1  do {add recent files}
        sett.writestring('main','recent'+inttostr(c),recent_files[c]);

      {########## stackmenu settings #############}
      sett.writebool('stack','stackmenu_visible',stackmenu1.visible);

      sett.writeInteger('stack','stackmenu_left',stackmenu1.left);
      sett.writeInteger('stack','stackmenu_top',stackmenu1.top);
      sett.writeInteger('stack','stackmenu_height',stackmenu1.height);
      sett.writeInteger('stack','stackmenu_width',stackmenu1.width);
      sett.writeInteger('stack','splitter',stackmenu1.pairsplitter1.position);

      sett.writeInteger('stack','stack_method',stackmenu1.stack_method1.itemindex);

      sett.writeInteger('stack','mosaic_crop',stackmenu1.mosaic_crop1.position);

      sett.writeInteger('stack','box_blur_factor',stackmenu1.box_blur_factor1.itemindex);
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

      sett.writeString('stack','smooth_dia',stackmenu1.smooth_diameter1.text);
      sett.writestring('stack','smooth_stars',stackmenu1.smooth_stars1.text);

      sett.writestring('stack','sqm_key',sqm_key+'*' );{add a * to prevent the spaces are removed.Should be at least 8 char}

      sett.writeBool('stack','lrgb_al',stackmenu1.lrgb_auto_level1.checked);
      sett.writeBool('stack','green_fl',stackmenu1.green_purple_filter1.checked);

      sett.writeBool('stack','lrgb_cs',stackmenu1.lrgb_colour_smooth1.checked);
      sett.writeBool('stack','lrgb_pr',stackmenu1.lrgb_preserve_r_nebula1.checked);

      sett.writeBool('stack','lrgb_sm',stackmenu1.lrgb_stars_smooth1.checked);
      sett.writeString('stack','lrgb_smd',stackmenu1.lrgb_smooth_diameter1.text);
      sett.writestring('stack','lrgb_sms',stackmenu1.lrgb_smooth_stars1.text);


      sett.writestring('stack','lrgb_sw',stackmenu1.lrgb_smart_smooth_width1.text);
      sett.writestring('stack','lrgb_sd',stackmenu1.lrgb_smart_colour_sd1.text);

      sett.writeBool('stack','ignore_header_solution',stackmenu1.ignore_header_solution1.Checked);
      sett.writeBool('stack','equalise_background',stackmenu1.Equalise_background1.Checked);
      sett.writeBool('stack','merge_overlap',stackmenu1.merge_overlap1.Checked);
      sett.writeBool('stack','limit_back_corr',stackmenu1.limit_background_correction1.Checked);



      sett.writeBool('stack','classify_object',stackmenu1.classify_object1.Checked);
      sett.writeBool('stack','classify_filter',stackmenu1.classify_filter1.Checked);

      sett.writeBool('stack','classify_dark_temp',stackmenu1.classify_dark_temperature1.Checked);
      sett.writeString('stack','delta_temp',stackmenu1.delta_temp1.caption);
      sett.writeBool('stack','classify_dark_gain',stackmenu1.classify_dark_gain1.Checked);

      sett.writeBool('stack','classify_dark_exposure',stackmenu1.classify_dark_exposure1.Checked);
      sett.writeBool('stack','classify_flat_filter',stackmenu1.classify_flat_filter1.Checked);
      sett.writeBool('stack','classify_dark_date',stackmenu1.classify_dark_date1.Checked);
      sett.writeBool('stack','classify_flat_date',stackmenu1.classify_flat_date1.Checked);
      sett.writeBool('stack','classify_flat_duration',stackmenu1.classify_flat_duration1.Checked);

      sett.writeBool('stack','add_time',stackmenu1.add_time1.Checked);
      sett.writeBool('stack','copy_sett',stackmenu1.save_settings_image_path1.Checked);

      sett.writeBool('stack','uncheck_outliers',stackmenu1.uncheck_outliers1.Checked);

      sett.writeBool('stack','write_log',stackmenu1.write_log1.checked);{write log to file}

      sett.writeBool('stack','align_blink',stackmenu1.align_blink1.checked);{blink}
      sett.writeBool('stack','time_stamp',stackmenu1.timestamp1.checked);{blink}

      sett.writeBool('stack','force_slow',stackmenu1.force_oversize1.checked);
      sett.writeBool('stack','use_triples',stackmenu1.use_triples1.checked);
      sett.writeBool('stack','sip',stackmenu1.add_sip1.checked);

      if  stackmenu1.use_manual_alignment1.checked then sett.writestring('stack','align_method','4')
      else
      if  stackmenu1.use_astrometry_alignment1.checked then sett.writestring('stack','align_method','3')
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

      sett.writestring('stack','nr_stars_p',stackmenu1.nr_stars_to_detect1.text);
      sett.writestring('stack','flux_aperture',stackmenu1.flux_aperture1.text);
      sett.writestring('stack','annulus_radius',stackmenu1.annulus_radius1.text);
      sett.writestring('stack','font_size_p',stackmenu1.font_size_photometry1.text);
      sett.writeInteger('stack','annotate_m',stackmenu1.annotate_mode1.itemindex);
      sett.writeInteger('stack','reference_d',stackmenu1.reference_database1.itemindex);

      sett.writeInteger('stack','measure_all',stackmenu1.measuring_method1.itemindex);

      sett.writestring('stack','sigma_decolour',stackmenu1.sigma_decolour1.text);

      sett.writestring('stack','sd_factor_list',stackmenu1.sd_factor_list1.text);
      sett.writestring('stack','noisefilter_blur',stackmenu1.noisefilter_blur1.text);
      sett.writestring('stack','noisefilter_sd',stackmenu1.noisefilter_sd1.text);

      sett.writeInteger('stack','hue_fuzziness',stackmenu1.hue_fuzziness1.position);
      sett.writeInteger('stack','saturation_tolerance',stackmenu1.saturation_tolerance1.position);
      sett.WriteBool('stack','blend', stackmenu1.blend1.checked);

      sett.writestring('stack','usm_amount',stackmenu1.unsharp_edit_amount1.text);
      sett.writestring('stack','usm_radius',stackmenu1.unsharp_edit_radius1.text);
      sett.writestring('stack','usm_thresh',stackmenu1.unsharp_edit_threshold1.text);

      sett.writeInteger('stack','sample_size',stackmenu1.sample_size1.itemindex);
      sett.writeBool('stack','wcs',stackmenu1.mount_write_wcs1.Checked);{uses wcs file for menu mount}

      sett.writeInteger('stack','video_index',video_index);
      sett.writestring('stack','frame_rate',frame_rate);

      sett.writestring('stack','contour_gaus',stackmenu1.contour_gaussian1.text);
      sett.writestring('stack','contour_sd',stackmenu1.contour_sigma1.text);
      sett.writestring('stack','contour_grid',stackmenu1.detection_grid1.text);
      sett.writestring('stack','groupsize',groupsizeStr);//stacking in tab photmetry

      sett.writestring('aavso','obscode',obscode);
      sett.writeInteger('aavso','delim_pos',delim_pos);
      sett.writeBool('aavso','baa_style',baa_style);{AAVSO report}
      sett.writeBool('aavso','hjd_date',hjd_date);{AAVSO report}
      sett.writeInteger('aavso','pfilter',aavso_filter_index);
      sett.writeFloat('aavso','slope', magnitude_slope);
      sett.writestring('aavso','checkstars',used_check_stars);

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
      sett.writebool('insp','3corners',three_corners);
      sett.writebool('insp','extra_stars',extra_stars);

     sett.writeInteger('insp','insp_binning',inspector_binning);
     sett.writeInteger('insp','insp_grid',inspector_grid_size);
     sett.writeInteger('insp','insp_grad',inspector_gradations);



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
    w, h, x, y : integer;
type
  PRGBTripleArray = ^TRGBTripleArray; {for fast pixel routine}
  {$ifdef mswindows}
  TRGBTripleArray = array[0..trunc(bufwide/3)] of TRGBTriple; {for fast pixel routine}
  {$else} {unix}
  TRGBTripleArray = array[0..trunc(bufwide/4)] of tagRGBQUAD; {for fast pixel routine}
  {$endif}
var
  pixelrow1 : PRGBTripleArray;{for fast pixel routine}
  pixelrow2 : PRGBTripleArray;{for fast pixel routine}
begin
  w:=image1.Picture.Width;
  h:=image1.Picture.Height;
  bmp:=TBitmap.Create;
  bmp.PixelFormat:=pf24bit;

  bmp.SetSize(w, h);
  for y := 0 to h -1 do
  begin // scan each line
    pixelrow1:=image1.Picture.Bitmap.ScanLine[y];
    pixelrow2:=bmp.ScanLine[y];
      for x := 0 to w-1 do {swap left and right}
        pixelrow2[x] := pixelrow1[w-1 -x];  {faster solution then using pbytearray as in vertical flip}
  end;
  image1.Picture.Bitmap.Canvas.Draw(0,0, bmp);// move bmp to source
  bmp.Free;

  plot_north; {draw arrow or clear indication position north depending on value head.cd1_1}
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
    w, h, y  : integer;
    pixelrow1,pixelrow2 :  PByteArray;
begin
  w:=image1.Picture.Width;
  h:=image1.Picture.Height;
  bmp:=TBitmap.Create;

  bmp.PixelFormat:=pf24bit;{This must be pf24 bit both for Windows and Linux! Doesn't work in Linux with pf32?}

  bmp.SetSize(w, h);
  for y := 0 to h -1 do
  begin // scan each line and swap top and bottom}
    pixelrow1:=image1.Picture.Bitmap.ScanLine[h-1-y];
    pixelrow2:=bmp.ScanLine[y];

    {$ifdef mswindows}
    Move(pixelrow1[0], pixelrow2[0],w*3);
    {$else} {unix, Darwin}
    Move(pixelrow1[0], pixelrow2[0],w*4); {4 bytes per pixel}
    {$endif}
  end;

  image1.Picture.Bitmap.Canvas.Draw(0,0, bmp);// move bmp to source
  bmp.Free;

  plot_north; {draw arrow or clear indication position north depending on value head.cd1_1}
end;


procedure Tmainwindow.flipVH1Click(Sender: TObject);
var bmp: TBitmap;
    w, h, x, y : integer;
type
  PRGBTripleArray = ^TRGBTripleArray; {for fast pixel routine}
  {$ifdef mswindows}
  TRGBTripleArray = array[0..trunc(bufwide/3)] of TRGBTriple; {for fast pixel routine}
  {$else} {unix}
  TRGBTripleArray = array[0..trunc(bufwide/4)] of tagRGBQUAD; {for fast pixel routine}
  {$endif}
var
  pixelrow1 : PRGBTripleArray;{for fast pixel routine}
  pixelrow2 : PRGBTripleArray;{for fast pixel routine}
begin
  w:=image1.Picture.Width;
  h:=image1.Picture.Height;
  bmp:=TBitmap.Create;
  bmp.PixelFormat:=pf24bit;

  bmp.SetSize(w, h);
  for y := 0 to h -1 do
  begin // scan each line
    pixelrow1:=image1.Picture.Bitmap.ScanLine[h-1-y];
    pixelrow2:=bmp.ScanLine[y];
      for x := 0 to w-1 do {swap left and right}
        pixelrow2[x] := pixelrow1[w-1 -x];  {faster solution then using pbytearray as in vertical flip}
  end;
  image1.Picture.Bitmap.Canvas.Draw(0,0, bmp);// move bmp to source
  bmp.Free;

  flip_vertical1.checked:=flip_vertical1.checked=false;
  flip_horizontal1.checked:=flip_horizontal1.checked=false;
  plot_north; {draw arrow or clear indication position north depending on value head.cd1_1}
end;


procedure Tmainwindow.dust_spot_removal1Click(Sender: TObject);
var
  fitsX,fitsY,dum,k,w,h,greylevels : integer;
  center_X, center_Y, line_bottom,line_top,expected_value, mode_left_bottom,mode_left_top, mode_right_top, mode_right_bottom,a,b         : double;
  img_delta : image_array;

begin
  if head.naxis=0 then exit;

  if  ((abs(stopX-startX)>3)and (abs(stopY-starty)>3)) then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    Randomize; {initialise}


    backup_img;

    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

    {ellipse parameters}
    center_x:=(startx+stopX)/2;
    center_y:=(startY+stopY)/2;
    a:=(stopX-1-startx)/2;
    b:=(stopY-1-startY)/2;

    w:=stopX-startX;
    h:=StopY-startY;

    setlength(img_delta,1,h,w);

    for k:=0 to head.naxis3-1 do {do all colors}
    begin
      mode_left_bottom:=mode(img_loaded,false{ellipse shape},k,startX-20,startX,startY-20,startY,32000,greylevels);{for this area get most common value equals peak in histogram}
      mode_left_top:=mode(img_loaded,false{ellipse shape},k,startX-20,startX,stopY,stopY+20,32000,greylevels);{for this area get most common value equals peak in histogram}

      mode_right_bottom:=mode(img_loaded,false{ellipse shape},k,stopX,stopX+20,startY-20,startY,32000,greylevels);{for this area get most common value equals peak in histogram}
      mode_right_top:=mode(img_loaded,false{ellipse shape},k,stopX,stopX+20,stopY,stopY+20,32000,greylevels);{for this area get most common value equals peak in histogram}

      for fitsY:=startY to stopY-1 do
      begin
        for fitsX:=startX to stopX-1 do
        begin
          line_bottom:=mode_left_bottom*(stopX-fitsx)/(stopX-startx)+ mode_right_bottom *(fitsx-startX)/(stopX-startx);{median value at bottom line}
          line_top:=  mode_left_top *   (stopX-fitsx)/(stopX-startx)+ mode_right_top*(fitsx-startX)/(stopX-startx);{median value at top line}
          expected_value:=line_bottom*(stopY-fitsY)/(stopY-startY)+line_top*(fitsY-startY)/(stopY-startY);{expected value based on the four corners measurements}

          img_delta[0,fitsY-startY,fitsX-startX]:=max(0,expected_value-img_loaded[k,fitsY,fitsX]);//max for star ignorance
        end;
      end;{fits loop}

      gaussian_blur2(img_delta,5);

      for fitsY:=startY to stopY-1 do
      begin
        for fitsX:=startX to stopX-1 do
        begin
          if ((CtrlButton=false {use no ellipse}) or (sqr(fitsX-center_X)/sqr(a) +sqr(fitsY-center_Y)/sqr(b)<1)) then // standard equation of the ellipse
            img_loaded[k,fitsY,fitsX]:= img_loaded[k,fitsY,fitsX]+img_delta[0,fitsY-startY,fitsX-startX];
        end;
      end;{fits loop}
    end;

    plot_fits(mainwindow.image1,false,true);
    Screen.Cursor:=crDefault;
  end {usefull area}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);
end;

procedure Tmainwindow.batch_add_tilt1Click(Sender: TObject);
var
  I: integer;
  err,success   : boolean;
  dobackup : boolean;
  tilt     : double;
begin
  OpenDialog1.Title:='Select multiple  files to measure and store tilt in header using keyword TILT';
  OpenDialog1.Options:=[ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter:=dialog_filter_fits_tif;

  opendialog1.initialdir:=ExtractFileDir(filename2);
  esc_pressed:=false;
  err:=false;
  if OpenDialog1.Execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}

    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        Application.ProcessMessages;
        if esc_pressed then begin err:=true;break; end;
        filename2:=Strings[I];
        mainwindow.caption:=filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count);;
        if load_image(filename2,img_loaded,head,mainwindow.memo1.lines,false {recenter},false {plot}) then
        begin
          if extra_stars=false then
            tilt:=CCDinspector(30,false {screenplot},false{three_corners},strtofloat(measuring_angle))
          else
            tilt:=CCDinspector(10,false {screenplot},false{three_corners},strtofloat(measuring_angle));

          if tilt<100 then
          begin
            update_text(mainwindow.memo1.lines,'TILT    = ',floattostr2(tilt)+'                / Delta HFD between worst and best corner');;//two decimals only for nice reporting
            if fits_file_name(filename2) then
              success:=savefits_update_header(mainwindow.memo1.lines,filename2)
            else
              success:=save_tiff16_secure(img_loaded,mainwindow.memo1.lines,filename2);{guarantee no file is lost}
            if success=false then begin ShowMessage('Write error !!' + filename2);Screen.Cursor:=crDefault; exit;end;
          end
          else
          memo2_message('Error adding tilt measurement: '+filename2);
        end
        else err:=true;
      end;
      if err=false then
      begin
         mainwindow.caption:='Completed, all files processed.';
         memo2_message('Completed, all files processed.');
      end
      else
      begin
        beep;
        ShowMessage('Errors!! Files modified but with errors or stopped!!');
      end;
      finally
      if dobackup then restore_img;{for the viewer}
      Screen.Cursor:=crDefault;  { Always restore to normal }
    end;
  end;
end;


function Jd_To_MPCDate(jd: double): string;{Returns Date from Julian Date,  See MEEUS 2 page 63}
var
  A, B, C, D, E, F, G, J, M, T, Z: double;
  year3,day: string;
begin
  jd := jd + (0.5 / (24 * 3600));
  {2016 one 1/2 second extra for math errors, fix problem with timezone 8, 24:00 midnight becomes 15:59 UTC}

  Z := trunc(JD + 0.5);
  F := Frac(JD + 0.5);



  if Z < 2299160.5 then A := Z // < 15.10.1582 00:00 {Note Meeus 2 takes midday 12:00}
  else
  begin
    g := int((Z - 1867216.25) / 36524.25);
    a := z + 1 + g - trunc(g / 4);
  end;
  B := A + 1524;
  C := trunc((B - 122.1) / 365.25);
  D := trunc(365.25 * C);
  E := trunc((B - D) / 30.6001);
  T := B - D - int(30.6001 * E) + F; {day of the month}
  if (E < 14) then
    M := E - 1
  else
    M := E - 13;
  if (M > 2) then
    J := C - 4716
  else
    J := C - 4715;

  str(trunc(J): 4, year3);
  str(trunc(T)+F:8: 5, day);  //probably could use T only
  if day[1]=' ' then day[1]:='0';

  Result := year3 + ' ' + leadingzero(trunc(M)) + ' ' + day;
end;


procedure Tmainwindow.mpcreport1Click(Sender: TObject);
var
   line,mag_str : string;
   hfd2,fwhm_star2,snr,flux,object_xc,object_yc,object_raM,object_decM  : double;
begin
  if sip=false then
     memo2_message('Warning image not solved with SIP polynomial correction! See settings tab alignment');

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  calibrate_photometry(img_loaded,mainwindow.Memo1.lines,head);//calibrate photometry if required
  minor_planet_at_cursor:=''; //clear last found

//  plot_mpcorb(strtoint(maxcount_asteroid),strtofloat2(maxmag_asteroid),true {add annotations});
  plot_annotations(false {use solution vectors},false);

  Screen.Cursor:=crDefault;
{  https://www.minorplanetcenter.net/iau/info/OpticalObs.html
   Columns     Format   Use
    1 -  5       A5     Packed minor planet number
    6 - 12       A7     Packed provisional designation, or a temporary designation
   13            A1     Discovery asterisk
   14            A1     Note 1
   15            A1     Note 2
   16 - 32              Date of observation
   33 - 44              Observed RA (J2000.0)
   45 - 56              Observed Decl. (J2000.0)
   57 - 65       9X     Must be blank
   66 - 71    F5.2,A1   Observed magnitude and band
                           (or nuclear/total flag for comets)
   72 - 77       X      Must be blank
   78 - 80       A3     Observatory code
}
  if minor_planet_at_cursor='' then
  begin
    memo2_message('Warning minor planet designation not found! First annotate image with option "Asteroid & comet annotation" (Ctrl+R) with option "Annotation to the FITS header".');
    minor_planet_at_cursor:='     ';//no name found
  end;
  if length(minor_planet_at_cursor)<=5 then  line:=minor_planet_at_cursor {5} +'       '{7}+'  B'{3, B for CMOS}
  else
  line:='     '{5}+minor_planet_at_cursor {7}+'  B'{3};
  HFD(img_loaded,round((startX+stopX)/2-1),round((startY+stopY)/2-1),annulus_radius {annulus radius},head.mzero_radius,0 {adu_e unbinned},hfd2,fwhm_star2,snr,flux,object_xc,object_yc);{input coordinates in array[0..] output coordinates in array [0..]}
  if ((hfd2<99) and (hfd2>0)) then //star detected
  begin
    date_to_jd(head.date_obs,head.date_avg,head.exposure);{convert date-obs to jd_start, jd_mid}
    line:=line+Jd_To_MPCDate(jd_mid)+' ';


    {centered coordinates}
    pixel_to_celestial(head,object_xc+1,object_yc+1,mainwindow.Polynomial1.itemindex,object_raM,object_decM);{input in FITS coordinates}
    if ((object_raM<>0) and (object_decM<>0)) then
    begin
      line:=line+prepare_ra8(object_raM,' ')+' '+prepare_dec2(object_decM,' ');{object position in RA,DEC}
      if line[33]=' ' then line[33]:='0';// add the missing zero for ra e.g. " 7 39 33.03"
      if line[46]=' ' then line[46]:='0';// add the missing zero for dec e.g. "- 7 39 33.03"
      line:=line+'          ';
      if head.mzero<>0 then {offset calculated in star annotation call}
      begin
        str(head.mzero -ln(flux)*2.5/ln(10):5:2,mag_str);
      end
      else
      begin
        mag_str:='     ';
      end;
      line:=line+mag_str;
    end;
    line:=line+'B      XXX';

    plot_the_annotation(stopX+1,stopY+1,startX+1,startY+1,0,' 📋');{rectangle, +1 to fits coordinates}
    stackmenu1.memo2.Lines.add(line);
    clipboard.AsText:=line;//copy to the clipboard
  end
  else
  begin
    memo2_message('No object detection at this image location.');
    clipboard.AsText:=('ASTAP: No object detected!');;
  end;

//  InputBox('This line to clipboard?','Format 24 00 00.0, 90 00 00.0   or   24 00, 90 00',line);
end;


procedure Tmainwindow.simbad_annotation_deepsky_filtered1Click(Sender: TObject);
begin
  maintype:=InputBox('Simbad search by criteria.','Enter the object main type (E.g. star=*, galaxy=G, quasar=QSO):',maintype);
  gaia_star_position1Click(sender);
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
      update_integer(mainwindow.memo1.lines,'EXPOSURE=',' / exposure extracted from file name.                     ' ,result);
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
    update_integer(mainwindow.memo1.lines,'CCD-TEMP=',' / Sensor temperature extracted from file name            ' ,result);
    memo2_message('Extracted temperature from file name');
  end
  else
  memo2_message('Failed to extract temperature from the file name. Expects ...C ');
end;


function unpack_cfitsio(var filename3: string): boolean; {convert .fz to .fits using funpack}
var
  commando :string;
  newfilename : string;
begin
  result:=false;

  commando:='-D';
  if pos('(',filename3)>0 then //this character "(" is not processed by fpunpack
  begin
    newfilename:=extractfilepath(filename3)+stringreplace(extractfilename(filename3),'(','_',[rfReplaceAll]);
    if renamefile(filename3,newfilename) then
      filename3:=newfilename;
    if pos('(',newfilename)>0 then begin memo2_message('Error!. Can not process a path with the "(" character');exit;  end;
  end;

  {$ifdef mswindows}
  if fileexists(application_path+'funpack.exe')=false then
  begin
    application.messagebox(pchar('Could not find: '+application_path+'funpack.exe !!, Download and install fpack_funpack.exe' ),pchar('Error'),MB_ICONWARNING+MB_OK);
    exit;
  end;
  ExecuteAndWait(application_path+'funpack.exe '+commando+ ' "'+filename3+'"',false);{execute command and wait}
  {$endif}
  {$ifdef Darwin}{MacOS}
  if fileexists(application_path+'/funpack')=false then
  begin
    application.messagebox(pchar('Could not find: '+application_path+'funpack' ),pchar('Error'),MB_ICONWARNING+MB_OK);
    exit;
  end;
  execute_unix2(application_path+'/funpack '+commando+' "'+filename3+'"');
  {$endif}
  {$ifdef linux}
  if fileexists('/usr/bin/funpack')=false then
  begin
    application.messagebox(pchar('Could not find program funpack !!, Install this program. Eg: sudo apt-get install libcfitsio-bin' ),pchar('Error'),MB_ICONWARNING+MB_OK);
    exit;
  end;
  execute_unix2('/usr/bin/funpack '+commando+' "'+filename3+'"');
  {$endif}
  filename3:=stringreplace(filename3,'.fz', '',[]); {changeFilext doesn't work for double dots .fits.fz}

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

{$ifdef mswindows}
function GetShortPath(const LongPath: UnicodeString): UnicodeString;
var
  Len: DWORD;
begin
  Len := GetShortPathNameW(PWideChar(LongPath), nil, 0);
  SetLength(Result, Len);
  Len := GetShortPathNameW(PWideChar(LongPath), PWideChar(Result), Len);
  SetLength(Result, Len);
end;
{$endif}

function convert_raw(loadfile,savefile :boolean;var filename3: string;out head: Theader; out img: image_array ): boolean; {convert raw to fits file using DCRAW or LibRaw. filename3 will be update with the new file extension e.g. .CR2.fits}
var
  filename4 :string;
  JD2                               : double;
  conv_index                        : integer;
  commando,param,pp,ff              : string;
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
       pp:=GetShortPath(ExtractFilePath(filename3)); //For path containing japaneseスカイメモ   or  ßÔÒõÕ   or   führ
       ff:=ExtractFileName(filename3);
       ExecuteAndWait(application_path+'unprocessed_raw.exe '+param+' "'+ pp+ff {filename3}+'"',false);{execute command and wait}
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
    if load_PPM_PGM_PFM(fileName4,head,img,mainwindow.memo1.lines) then {succesfull PGM load}
    begin

      deletefile(filename4);{delete temporary pgm file}
      filename4:=ChangeFileExt(FileName4,'.fits');

      if head.date_obs='' then {no date detected in comments}
      begin
        JD2:=2415018.5+(FileDateToDateTime(fileage(filename3))); {fileage raw, convert to Julian Day by adding factor. filedatatodatetime counts from 30 dec 1899.}
        head.date_obs:=JdToDate(jd2);
        update_text(mainwindow.memo1.lines,'DATE-OBS=',#39+head.date_obs+#39);{give start point exposures}
      end;
      update_text(mainwindow.memo1.lines,'BAYERPAT=',#39+'????'+#39);{identify raw OSC image}
      add_text(mainwindow.memo1.lines,'HISTORY  ','Converted from '+filename3);
      result:=true;
    end
    else
      result:=false;

    if ((savefile) and (conv_index=2) and (result)) then {PPM interstage file, save to fits, Not required for the new unprocessed_raw-astap}
    begin
      if conv_index=2 {dcraw} then head.set_temperature:=extract_temperature_from_filename(filename4);{including update header}
      update_text(mainwindow.memo1.lines,'OBJECT  =',#39+extract_objectname_from_filename(filename4)+#39); {spaces will be added/corrected later}
      result:=save_fits(img,mainwindow.memo1.lines,filename4,16,true);{overwrite. Filename2 will be set to fits file}
    end;
    if loadfile=false then  img:=nil;{clear memory}
  end
  else
  begin {fits file created by modified unprocessed_raw}
    if loadfile then
    begin
      result:=load_fits(filename4,true {light},true {load data},true {update memo},0,mainwindow.memo1.lines,head,img); {load new fits file}
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
  img_temp : image_array;
  headX : theader;
begin
  ext:=uppercase(ExtractFileExt(filen));
  result:=false;

  if check_raw_file_extension(ext) then {raw format}
  begin
    result:=convert_raw(false{load},true{save},filen,head,img_loaded);
  end
  else
  if (ext='.FZ') then {CFITSIO format}
    result:=unpack_cfitsio(filen) {filename2 contains the new file name}
  else
  begin
    if ((ext='.PPM') or (ext='.PGM') or (ext='.PFM') or (ext='.PBM')) then {PPM/PGM/ PFM}
      result:=load_PPM_PGM_PFM(filen,headX,img_temp,memox)
    else
    if ext='.XISF' then {XISF}
      result:=load_xisf(filen,head,img_loaded,mainwindow.memo1.lines)
    else
    if ((ext='.JPG') or (ext='.JPEG') or (ext='.PNG') or (ext='.TIF') or (ext='.TIFF')) then
      result:=load_tiffpngJPEG(filen,true,headX,img_temp,memox);

    if result then
    begin
      if head.exposure=0 then {not an Astro-TIFF file with an header}
      begin
        head.exposure:=extract_exposure_from_filename(filen); {try to extract head.exposure time from filename. Will be added to the header}
        update_text(mainwindow.memo1.lines,'OBJECT  =',#39+extract_objectname_from_filename(filen)+#39); {spaces will be added/corrected later}
        head.set_temperature:=extract_temperature_from_filename(filen);
      end;

      filen:=ChangeFileExt(filen,'.fits');
      result:=save_fits(img_loaded,memox,filen,nrbits,false);
    end;
  end;
end;


procedure Tmainwindow.convert_to_fits1click(Sender: TObject);
var
  I: integer;
  err         : boolean;
begin
  OpenDialog1.Title := 'Select multiple  files to convert to FITS.';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=  'All formats |*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP;*.tif;*.tiff;*.TIF;*.new;*.ppm;*.pgm;*.pbm;*.pfm;*.xisf;*.fz;'+
                                       '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                         '|RAW files|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                         '|PNG, TIFF, JPEG, BMP(*.png,*.tif*, *.jpg,*.bmp)|*.png;*.PNG;*.tif;*.tiff;*.TIF;*.jpg;*.JPG;*.bmp;*.BMP'+
                         '|Compressed FITS files|*.fz';
  opendialog1.initialdir:=ExtractFileDir(filename2);
//  fits_file:=false;
  esc_pressed:=false;
  err:=false;
  if OpenDialog1.Execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        progress_indicator(100*i/(count),' Solving');{show progress}
        Application.ProcessMessages;
        if esc_pressed then begin err:=true; break;end;
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
      mainwindow.caption:='Finished, files converted but with errors or stopped!';

    finally
      Screen.Cursor:=crDefault;  { Always restore to normal }
      progress_indicator(-100,'');{progresss done}
    end;
  end;
end;


function load_image(filename2: string; out img: image_array; out head: theader; memo: tstrings; re_center,plot: boolean): boolean; {load fits or PNG, BMP, TIF}
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

//  x_coeff[0]:=0; {reset DSS_polynomial, use for check if there is data}
//  a_order:=0; {SIP_polynomial, use for check if there is data}
//  ap_order:=0; {SIP_polynomial, use for check if there is data}

  result:=false;{assume failure}
  {fits}
  if ((ext1='.FIT') or (ext1='.FITS') or (ext1='.FTS') or (ext1='.NEW')or (ext1='.WCS') or (ext1='.AXY') or (ext1='.XYLS') or (ext1='.GSC') or (ext1='.BAK')) then {FITS}
  begin
    result:=load_fits(filename2,true {light},true,true {update memo},0,memo,head,img);
    if head.naxis<2 then result:=false; {no image}
  end
  else
  if (ext1='.FZ') then {CFITSIO format}
  begin
    if unpack_cfitsio(filename2) then {successful conversion using funpack}
      result:=load_fits(filename2,true {light},true {load data},true {update memo},0,memo,head,img); {load new fits file}
  end {fz}
  else
  if check_raw_file_extension(ext1) then {raw format}
  begin
    result:=convert_raw(true{load},false{save},filename2,head,img);
    if result then {successful conversion using LibRaw}
      filename2:=ChangeFileExt(FileName2,'.fits');{for the case you want to save it}
  end{raw}
  else
  if ((ext1='.PPM') or (ext1='.PGM') or (ext1='.PFM') or (ext1='.PBM')) then {PPM/PGM/ PFM}
    result:=load_PPM_PGM_PFM(filename2,head,img,memo)
  else
  if ext1='.XISF' then {XISF}
    result:=load_xisf(filename2,head,img,memo)
  else
  if ((ext1='.TIF') or (ext1='.TIFF') or (ext1='.PNG') or (ext1='.JPG') or (ext1='.JPEG') or (ext1='.BMP')) then {tif, png, bmp, jpeg}
    result:=load_tiffpngJPEG(filename2,true {light},head,img,memo);

  if result=false then begin update_menu(false);exit; end;

  if plot then
  begin
    if ((head.naxis3=1) and (mainwindow.preview_demosaic1.checked)) then demosaic_advanced(img);{demosaic and set levels}
    use_histogram(img,true {update}); {plot histogram, set sliders}
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


procedure Tmainwindow.receivemessage(Sender: TObject);{For OneInstance, called from timer (linux) or SimpleIPCServer1MessageQueued (Windows)}
begin
  if SimpleIPCServer1.PeekMessage(1,True) then
  begin
    BringToFront;
    filename2:=SimpleIPCServer1.StringMessage;
    load_image(filename2,img_loaded,head,mainwindow.memo1.lines,true,true {plot});{show image of parameter1}
  end;
end;


procedure convert_mono(var img: image_array; var head: Theader);
var
   fitsX,fitsY: integer;
   img_temp : image_array;
begin
  if head.naxis3<3 then exit;{prevent run time error mono images}
  memo2_message('Converting to mono.');
  setlength(img_temp,1,head.height,head.width);{set length of image array mono}

  for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1 do
      img_temp[0,fitsY,fitsX]:=(img[0,fitsY,fitsX]+img[1,fitsY,fitsX]+img[2,fitsY,fitsX])/3;

  head.naxis:=2;{mono}
  head.naxis3:=1;
  img:=nil;
  img:=img_temp;
end;


procedure Tmainwindow.convertmono1Click(Sender: TObject);
begin
  if head.naxis3<3 then exit;{prevent run time error mono images}
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img;

  convert_mono(img_loaded,head);

  update_header_for_colour; {update header naxis and naxis3 keywords}
  add_text(mainwindow.memo1.lines,'HISTORY   ','Converted to mono');

  {colours are now mixed, redraw histogram}
  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,false,true);{plot}
  Screen.cursor:=crDefault;
end;


procedure Tmainwindow.compress_fpack1Click(Sender: TObject);
var
  i: integer;
  filename1: string;
begin

  OpenDialog1.Title := 'Select multiple  FITS files to compress. Original files will be kept.';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := 'FITS files|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';
  esc_pressed:=false;

  if OpenDialog1.Execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    try { Do some lengthy operation }
       with OpenDialog1.Files do
       for I := 0 to Count - 1 do
       begin
         progress_indicator(100*i/(count),' Converting');{show progress}
         filename1:=Strings[I];
         memo2_message(filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count));
         Application.ProcessMessages;
         if ((esc_pressed) or (pack_cfitsio(filename1)=false)) then begin beep; mainwindow.caption:='Exit with error!!'; Screen.Cursor:=crDefault; exit;end;
      end;
      finally
      mainwindow.caption:='Finished, all files compressed with extension .fz.';
      Screen.Cursor:=crDefault;  { Always restore to normal }
      progress_indicator(-100,'');{progresss done}
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


procedure Tmainwindow.grid_ra_dec1Click(Sender: TObject);
begin
  if head.naxis=0 then exit;
  if grid_ra_dec1.checked=false then  {clear screen}
  begin
    plot_fits(mainwindow.image1,false,true);
  end
  else
  plot_grid(true);
end;


procedure remove_photometric_calibration;//from header
begin
  head.mzero:=0;//clear photometric calibration
  remove_key(mainwindow.memo1.lines,'MZERO   =',false{all});
  remove_key(mainwindow.memo1.lines,'MZEROR  =',false{all});
  remove_key(mainwindow.memo1.lines,'MZEROAPT=',false{all});
end;


procedure Tmainwindow.bin_2x2menu1Click(Sender: TObject);
begin
 if head.naxis<>0 then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    backup_img; {move viewer data to img_backup}
    if sender=bin_2x2menu1 then
    begin
      bin_X2X3X4(img_loaded,head,mainwindow.memo1.lines,2);
      filename2:=ChangeFileExt(Filename2,'_bin2x2.fit');
    end
    else
    begin
      bin_X2X3X4(img_loaded,head,mainwindow.memo1.lines,3);
      filename2:=ChangeFileExt(Filename2,'_bin3x3.fit');
    end;

    remove_photometric_calibration;//from header
    plot_fits(mainwindow.image1,true,true);{plot real}
    mainwindow.caption:=Filename2;
    Screen.Cursor:=crDefault;
  end;
end;


function download_vsp(limiting_mag: double) : boolean;//AAVSO API access
var
  s,url   : string;
  val,val2 : char;
  count,i,j,k,fov    : integer;
  errorRA,errorDEC   : boolean;
begin
  result:=false;
  fov:=round(sqrt(sqr(head.width)+sqr(head.height))*abs(head.cdelt2*60)); //arcmin. cdelt2 can be negative for other solvers
  if fov>180 {arcmin} then
  begin
    if limiting_mag>12 then memo2_message('FOV is larger then 3 degrees. Downloading from AAVSO VSX, VSP is then limited to magnitude 12.');
    limiting_mag:=min(limiting_mag,12); ////Required by AAVSO
  end;

  //https://www.aavso.org/apps/vsp/api/chart/?format=json&ra=173.475392&dec=-0.032945&fov=42&maglimit=13.0000
  url:='https://www.aavso.org/apps/vsp/api/chart/?format=json&ra='+floattostr6(head.ra0*180/pi)+'&dec='+floattostr6(head.dec0*180/pi)+'&fov='+inttostr(fov)+'&maglimit='+floattostr4(limiting_mag);{+'&special=std_field'}
  s:=get_http(url);{get webpage}
  if length(s)=0 then begin beep; exit end;;
  if length(s)<256 then exit; //no data for this field

  setlength(vsp,1000);
  count:=0;
  j:=150;//skip some header stuff
  repeat
    i:=posex('"auid":"',s,j); //AUID will be always available
    if i=0 then
            break;//no more data
    i:=i+length('"auid":"');
    j:=posex('"',s,i);
    vsp[count].auid:=copy(s,i,j-i);

    i:=posex('"ra":"',s,j);//RA will be always available
    i:=i+length('"ra":"');
    j:=posex('"',s,i);
    ra_text_to_radians(copy(s,i,j-i),vsp[count].ra,errorRA); {convert ra text to double in radians}

    i:=posex('"dec":"',s,j);//dec will be always available
    i:=i+length('"dec":"');
    j:=posex('"',s,i);
    dec_text_to_radians(copy(s,i,j-i),vsp[count].dec,errorDEC); {convert dec text to double in radians}

    vsp[count].Bmag:='?';
    vsp[count].Berr:='';
    vsp[count].Vmag:='?';
    vsp[count].Verr:='';
    vsp[count].Rmag:='?';
    vsp[count].Rerr:='';
    vsp[count].SGmag:='?';
    vsp[count].SGerr:='';
    vsp[count].SRmag:='?';
    vsp[count].SRerr:='';
    vsp[count].SImag:='?';
    vsp[count].SIerr:='';
    k:=0;

    repeat //read optional "bands"
      val:=s[j];
      inc(j);
      val2:=s[j];

      if ((val='"') and (val2='B')) then //B mag found, could be missing
      begin
        i:=posex('"mag":',s,j);
        i:=i+length('"mag":');
        k:=posex(',',s,i);
        vsp[count].Bmag:=copy(s,i,k-i);

        i:=posex('error":',s,k);
        i:=i+length('error":');
        k:=posex('}',s,i);
        vsp[count].Berr:=copy(s,i,k-i);
      end
      else
      if ((val='"') and (val2='V')) then //V mag found, could be missing
      begin
        i:=posex('"mag":',s,j);
        i:=i+length('"mag":');
         k:=posex(',',s,i);
         vsp[count].Vmag:=copy(s,i,k-i);

         i:=posex('error":',s,k);
         i:=i+length('error":');
         k:=posex('}',s,i);
         vsp[count].Verr:=copy(s,i,k-i);
      end
      else
      if ((val='"') and (val2='R')) then //R mag found, could be missing
      begin
        i:=posex('"mag":',s,j);
        i:=i+length('"mag":');
        k:=posex(',',s,i);
        vsp[count].Rmag:=copy(s,i,k-i);

        i:=posex('error":',s,k);
        i:=i+length('error":');
        k:=posex('}',s,i);
        vsp[count].Rerr:=copy(s,i,k-i);
      end;
      if ((val='S') and (val2='G')) then //Sloan green
      begin
        i:=posex('"mag":',s,j);
        i:=i+length('"mag":');
        k:=posex(',',s,i);
        vsp[count].SGmag:=copy(s,i,k-i);

        i:=posex('error":',s,k);
        i:=i+length('error":');
        k:=posex('}',s,i);
        vsp[count].SGerr:=copy(s,i,k-i);
      end;
      if ((val='S') and (val2='R')) then //Sloan red
      begin
        i:=posex('"mag":',s,j);
        i:=i+length('"mag":');
        k:=posex(',',s,i);
        vsp[count].SRmag:=copy(s,i,k-i);

        i:=posex('error":',s,k);
        i:=i+length('error":');
        k:=posex('}',s,i);
        vsp[count].SRerr:=copy(s,i,k-i);
      end;
      if ((val='S') and (val2='I')) then //Sloan i
      begin
        i:=posex('"mag":',s,j);
        i:=i+length('"mag":');
        k:=posex(',',s,i);
        vsp[count].SImag:=copy(s,i,k-i);

        i:=posex('error":',s,k);
        i:=i+length('error":');
        k:=posex('}',s,i);
        vsp[count].SIerr:=copy(s,i,k-i);
      end;
      if j<k then j:=k;// for the case k is zero due to nothing found

    until ((val=']') or (j>=length(s)));

    inc(count);//number of entries/stars
  until count>=length(vsp);//normally will stop at above break
  setlength(vsp,count);
  result:=true;
end;

function download_vsx(limiting_mag: double): boolean;//AAVSO API access
var
  s,dummy,url   : string;
  count,i,j,k,errorRa,errorDec,err                : integer;
  radius,ra,dec,ProperMotionRA,ProperMotionDEC,jd,years_since_2000 : double;
begin
  result:=false;
  radius:=sqrt(sqr(head.width)+sqr(head.height))*abs(head.cdelt2/2); //radius in degrees. Some solvers produce files with neagative cdelt2

  date_to_jd(head.date_obs,'',0 {exposure});{convert date-obs to jd_start, jd_mid for proper motion}
  if jd_start>2400000 then
    years_since_2000:=(jd_start-2451545)/365.25 //years since 2000
  else
    years_since_2000:=26; //default, years since 2000

  if radius>3 {degrees} then limiting_mag:=min(12,limiting_mag); ////Required by AAVSO

  //https://www.aavso.org/vsx/index.php?view=api.list&ra=173.478667&dec=-0.033698&radius=0.350582&tomag=13.0000&format=json
  url:='https://www.aavso.org/vsx/index.php?view=api.list&ra='+floattostr6(head.ra0*180/pi)+'&dec='+floattostr6(head.dec0*180/pi)+'&radius='+floattostr6(radius)+'&tomag='+floattostr4(limiting_mag)+'&format=json';
  s:=get_http(url);
  if length(s)=0 then begin beep; exit end;//network error
  if length(s)<25 then begin exit end;//no stars in this field

  setlength(vsx,1000);
  count:=0;
  j:=25;//skip some header stuff

  repeat
    i:=posex('"Name":"',s,j); //Name will be always available
    if i=0 then
            break;//no more data
    i:=i+length('"Name":"');
    j:=posex('"',s,i);
    vsx[count].name:=stringreplace(copy(s,i,j-i),' ','_',[]);//add underscore for consistancy with local database

    //optional field
//     if s[j+3]='A' then
//     begin
//       i:=posex('"AUID":"',s,j); //AUID will NOT always available !!!
//       if i=0 then
//               break;//no more data
//       i:=i+length('"AUID":"');
//       j:=posex('"',s,i);
//       vsx[count].auid:=copy(s,i,j-i);
//     end
//     else
//     vsx[count].auid:='';

    i:=posex('"RA2000":"',s,j);//RA will be always available
    i:=i+length('"RA2000":"');
    j:=posex('"',s,i);
    dummy:=copy(s,i,j-i);
    val(dummy,ra,errorRa); {convert ra text to double in radians}
    vsx[count].ra:=ra*pi/180;

    i:=posex('"Declination2000":"',s,j);//dec will be always available
    i:=i+length('"Declination2000":"');
    j:=posex('"',s,i);
    dummy:=copy(s,i,j-i);
    val(dummy,dec,errorDec); {convert ra text to double in radians}
    vsx[count].dec:=dec*pi/180;

    vsx[count].maxmag:='?';
    vsx[count].minmag:='?';
    vsx[count].period:='?';
    vsx[count].category:='?';
    k:=0;// for case no optional fields

    repeat //read optional fields
      inc(j);
      if ((s[j]='M') and (s[j+1]='a') and (s[j+2]='x')) then //MaxMag found, could be missing
      begin
        i:=j+length('"MaxMag:"');
        k:=posex('"',s,i);
        vsx[count].maxmag:=copy(s,i,k-i);
      end
      else
      if ((s[j]='M') and (s[j+1]='i') and (s[j+2]='n')) then //MinMag found, could be missing
      begin
        i:=j+length('"MinMag:"');
        k:=posex('"',s,i);
        vsx[count].minmag:=copy(s,i,k-i);
      end
      else
      if ((s[j]='C') and (s[j+1]='a') and (s[j+2]='t')) then
      begin
        i:=j+length('"Category:"');
        k:=posex('"',s,i);
        vsx[count].category:=copy(s,i,3);
      end
      else
      if ((s[j]='P') and (s[j+1]='e') and (s[j+2]='r')) then
      begin
        i:=j+length('"Period:"');
        k:=posex('"',s,i);
        vsx[count].period:=copy(s,i,k-i);
      end
      else
      if ((s[j]='E') and (s[j+1]='p') and (s[j+2]='o')) then
      begin
        i:=j+length('"Epoch:"');
        k:=posex('"',s,i);
        vsx[count].epoch:=copy(s,i,k-i);
      end
      else
      if ((s[j]='P') and (s[j+1]='r') and (s[j+2]='o') and (s[j+3]='p') and (s[j+12]='D') and (s[j+13]='e')  ) then
      begin
        i:=j+length('"ProperMotionDec:"');
        k:=posex('"',s,i);
        val(copy(s,i,k-i),propermotionDEC,err);//Proper motions mas/yr
        if err=0 then
           vsx[count].dec:=vsx[count].dec+propermotionDec*years_since_2000/((1000*3600)*180/pi);

      end
      else
      if ((s[j]='P') and (s[j+1]='r') and (s[j+2]='o') and (s[j+3]='p') and (s[j+12]='R') and (s[j+13]='A')  ) then
      begin
        i:=j+length('"ProperMotionRA:"');
        k:=posex('"',s,i);
        val(copy(s,i,k-i),propermotionRA,err);//Proper motions mas/yr
        if err=0 then
           vsx[count].ra:=vsx[count].ra+propermotionRA*years_since_2000/(cos(vsx[count].dec)*(1000*3600)*180/pi);
      end;


      if j<k then j:=k; //k could be in very rare cases 0 resulting in an endless loop
     until ((s[j]='}') or (j=length(s)-1));
    inc(count);//number of entries/stars
  until count>=length(vsx);//normally will stop at above break
  setlength(vsx,count);
  result:=true;
end;


function aavso_update_required : boolean; //update of downloaded database required?
var sep : double;
begin
  result:=true;
  if vsx=nil then exit;
  if length(vsx)>0 then
    ang_sep(vsx[0].ra,vsx[0].dec,head.ra0,head.dec0,sep);
  if sep<head.width*head.cdelt2*2*pi/180 then result:=false;// first entry near to center position image then no update required
end;


procedure variable_star_annotation(plot: boolean {if false, load only});
var
  lim_magn            : double;
begin
//0, No annotation
//1, Annotation local DB mag 13
//2, Annotation local DB mag 15
//3, Annotation online DB mag 13
//4, Annotation online DB mag 15
//5, Annotation online DB mag 99
//6, Annotation local DB mag 13 & measure all
//7, Annotation local DB mag 15 & measure all
//8, Annotation online DB mag 13 & measure all
//9, Annotation online DB mag 15 & measure all
//10,Annotation online DB mag 99 & measure all

  case stackmenu1.annotate_mode1.itemindex of
       0,1: begin lim_magn:=-99; load_variable;{Load the local database once. If loaded no action} end;//use local database. Selection zero the viewer plot deepsky should still work
       2:   begin lim_magn:=-99; load_variable_13;{Load the local database once. If loaded no action} end;//use local database
       3:   begin lim_magn:=-99; load_variable_15;{Load the local database once. If loaded no action} end;//use local database
       4,8: lim_magn:=11;
       5,9: lim_magn:=13;
       6,19: lim_magn:=15;
       7,11:lim_magn:=99;
       else
          lim_magn:=99;
     end; //case

  if lim_magn>0 then //online version
  begin
    repeat
      if aavso_update_required then
      begin
        memo2_message('Downloading online data from AAVSO as set in tab Photometry.');
        if download_vsx(lim_magn)=false then begin memo2_message('No VSX data! Increasing the max magnitude could help.');break; end;
        if download_vsp(lim_magn)=false then begin memo2_message('No VSP data!');break; end;

      end;
      if plot then
      begin
         date_to_jd(head.date_obs,head.date_avg,head.exposure);{convert date-obs to jd_start, jd_mid}
         plot_vsx_vsp;
      end;
    until true;//allow breaks to skip and go to cursor statement
  end
  else
  begin //local version
    memo2_message('Using local variable database. Online version can be set in tab Photometry');
    plot_deepsky(plot=false {if false then extract visible to variable_list},stackmenu1.font_size_photometry_UpDown1.position); {Plot the variables on the image. }
  end;
end;



procedure Tmainwindow.variable_star_annotation1Click(Sender: TObject);
var
  lim_magn            : double;
begin
  if head.cd1_1=0 then begin memo2_message('No solution!'); exit; end;//no solution
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  variable_star_annotation(true {load and plot});
  Screen.Cursor:=crDefault;
end;



procedure Tmainwindow.positionanddate1Click(Sender: TObject);
begin
  if head.naxis=0 then exit;
  if positionanddate1.checked=false then  {clear screen}
  begin
    plot_fits(mainwindow.image1,false,true);
  end
  else
  plot_text;
end;

procedure Tmainwindow.inspection1click(Sender: TObject);
begin
  if extra_stars=false then
    CCDinspector(30,true {screenplot},three_corners,strtofloat(measuring_angle))
  else
    CCDinspector(10,true {screenplot},three_corners,strtofloat(measuring_angle));
end;


procedure Tmainwindow.removegreenpurple1Click(Sender: TObject);
begin
  green_purple_filter(img_loaded);
end;


procedure Tmainwindow.roundness1Click(Sender: TObject);
begin
  form_inspection1.roundness1Click(nil);
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
   if load_image(filename2,img_loaded,head,mainwindow.memo1.lines,true,true {plot}){load and center}=false then beep;{image not found}
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


procedure Tmainwindow.measuretotalmagnitude1Click(Sender: TObject);
var
   fitsX,fitsY,dum,font_height,counter,tx,ty,saturation_counter : integer;
   flux,bg_median,value,center_x,center_y,a,b  : double;
   mag_str               : string;
   bg_array              : array of double;
begin
  if ((head.cd1_1=0) or (head.naxis=0)) then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    if ((head.mzero=0) or (head.mzero_radius<>99){calibration was for point sources})  then {calibrate and ready for extendend sources}
    begin
      annulus_radius:=14;{calibrate for extended objects using full star flux}
      head.mzero_radius:=99;{calibrate for extended objects}

      plot_and_measure_stars(img_loaded,mainwindow.Memo1.lines,head,true {calibration},false {plot stars},false{report lim magnitude});
    end;
    if head.mzero=0 then begin beep; exit;end;

    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    backup_img;

    tx:=stopX;
    ty:=stopY;
    if mainwindow.Flip_horizontal1.Checked then {restore based on flipped conditions}
      tx:=head.width-1-tx;
    if mainwindow.flip_vertical1.Checked=false then
      ty:=head.height-1-ty;


    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

    setlength(bg_array,(5+5+1+stopY-startY)*5*2+(5+5+1+stopX-startX)*5*2);//surface used for background. Overlap not counted for simplicity

    {measure the median of the suroundings}
    counter:=0;
    for fitsY:=startY+1-5 to stopY-1+5 do {calculate mean at square boundaries of detection box. StartX,StopX are in 0...width-1,0..height-1 range}
    for fitsX:=startX+1-5 to stopX-1+5 do
    begin
      if ( (fitsX<startX) or  (fitsX>stopX) or (fitsY<startY) or  (fitsY>stopY) ) then {measure only outside the box}
      begin
        bg_array[counter]:=img_loaded[0,fitsY,fitsX];
        inc(counter);
      end;
    end;
    if counter>0 then
      bg_median:=Smedian(bg_array,counter)
    else
      bg_median:=9999999;{something went wrong}

    saturation_counter:=0;
    flux:=0;
    {ellipse parameters}
    center_x:=(startx+stopX-1)/2;
    center_y:=(startY+stopY-1)/2;
    a:=(stopX-1-startx)/2;
    b:=(stopY-1-startY)/2;

    for fitsY:=startY+1 to stopY-1 do {within rectangle.  StartX,StopX are in 0...width-1,0..height-1 range}
    for fitsX:=startX+1 to stopX-1 do
    begin
      if ((CtrlButton=false {use no ellipse}) or (sqr(fitsX-center_X)/sqr(a) +sqr(fitsY-center_Y)/sqr(b)<1)) then // standard equation of the ellipse
      begin
        value:=img_loaded[0,fitsY,fitsX];
        if value>65000 then inc(saturation_counter);{keep track of number of saturated pixels}
        flux:=flux+(value-bg_median);{add all flux. Without stars it should average zero. Detecting flux using >3*sd misses too much signal comets}
      end;
    end;

    if flux<1 then flux:=1;
    str(head.MZERO - ln(flux)*2.5/ln(10):0:1,mag_str);

    if (saturation_counter*65500/flux)<0.03 then mag_str:='MAGN='+mag_str {allow about 3% saturation}
                                            else mag_str:='MAGN <'+mag_str+', ('+inttostr(saturation_counter) +' saturated pixels !)';

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

    Screen.Cursor:=crDefault;

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
  if head.naxis=0 then exit;
  if  ((abs(stopX-startX)>1)and (abs(stopY-starty)>1)) then
  begin
    Screen.Cursor:=crDrag;
    backup_img;{required in case later ctrl-z is used}

    if startX>stopX then begin dum:=stopX; stopX2:=startX; startX2:=dum; end else  begin stopX2:=stopX; startX2:=startX; end; {swap if required}
    if startY>stopY then begin dum:=stopY; stopY2:=startY; startY2:=dum; end else  begin stopY2:=stopY; startY2:=startY; end;

    copy_paste_x:=startX2+1;{take the inside of the rectangle} {save for Application.ProcessMessages in copy_paste_x; This could change startX, startY}
    copy_paste_y:=startY2+1;

    copy_paste_w:=stopX2-copy_paste_x;
    copy_paste_h:=stopY2-copy_paste_y;
    copy_paste:=true;
    if CTRLbutton then copy_paste_shape:=1 //ellipse
                  else copy_paste_shape:=0;//rectangle
  end {fits file}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);
end;


procedure ang_sep_two_positions(fitsx1,fitsy1,fitsx2,fitsy2 : double; out seperation, pa : string);
var
  ra1,dec1,ra2,dec2,sep : double;
begin
  if head.cdelt2<>0 then
  begin
    pixel_to_celestial(head,fitsX1,fitsY1,mainwindow.Polynomial1.itemindex,ra1,dec1);{calculate the ra,dec position}
    pixel_to_celestial(head,fitsX2,fitsY2,mainwindow.Polynomial1.itemindex,ra2,dec2);{calculate the ra,dec position}
    ang_sep(ra1,dec1,ra2,dec2, sep);
    sep:=sep*180/pi; //convert to degrees
    if sep<1/60 then seperation:=inttostr(round(sep*3600))+'"'
    else
    if sep<1 then seperation:=floattostrF(sep*60,FFfixed,0,2)+#39
    else
    seperation:=floattostrF(sep,FFfixed,0,2)+'°';
    pa:=FloattostrF(position_angle(ra2,dec2,ra1,dec1)*180/pi,FFfixed,0,0)+'°';; //Position angle between a line from ra0,dec0 to ra1,dec1 and a line from ra0, dec0 to the celestial north . Rigorous method
  end
  else
  begin //no astrometric solution available
    seperation:=floattostrf(sqrt(sqr(fitsX2-fitsX1)+sqr(fitsY2-fitsY1)),ffFixed,0,2)+' pixels';
    pa:=FloattostrF(arctan2(fitsY2-fitsY1,fitsX2-fitsX1)*180/pi,FFfixed,0,0)+'°';
  end;
end;


procedure Tmainwindow.angular_distance1Click(Sender: TObject);
var
   shapetype                                 : integer;
   hfd1,star_fwhm,snr,flux,xc,yc, hfd2,
   star_fwhm2,snr2,flux2,xc2,yc2             : double;
   info_message,info_message1, info_message2 : string;
begin
  if head.naxis=0 then exit;

  if  ((abs(stopX-startX)>2) or (abs(stopY-starty)>2)) then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    backup_img;

    HFD(img_loaded,startX,startY,14{annulus radius},99 {flux aperture restriction},0 {adu_e}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}

    if ((hfd1<15) and (hfd1>=0.8) {two pixels minimum} and (snr>10)) then {star detected in img_loaded}
    begin //lock
      shapetype:=1;{circle}
      shape_marker1_fitsX:=xc+1;{store fits value for zoom}
      shape_marker1_fitsY:=yc+1;
    end
    else
    begin //no lock
       info_message:='Object 1, no lock'+#10;
       shape_marker1_fitsX:=startX+1;{store fits value for zoom}
       shape_marker1_fitsY:=startY+1;
       shapetype:=0;{rectangle}
    end;
    show_marker_shape(mainwindow.shape_marker1,shapetype,20,20,10{minimum}, shape_marker1_fitsX,shape_marker1_fitsY);

    HFD(img_loaded,stopX,stopY,14{annulus radius},99 {flux aperture restriction},0 {adu_e}, hfd2,star_fwhm2,snr2,flux2,xc2,yc2);{star HFD and FWHM}
    if ((hfd2<15) and (hfd2>=0.8) {two pixels minimum} and (snr2>10) and (flux2>1){rare but happens}) then {star detected in img_loaded}
    begin //lock
      shapetype:=1;{circle}
      shape_marker2_fitsX:=xc2+1;{store fits value for zoom}
      shape_marker2_fitsY:=yc2+1;
    end
    else
    begin //no lock
       info_message:=info_message+'Object 2, no lock'+#10;
       shape_marker2_fitsX:=stopX+1;{store fits value for zoom}
       shape_marker2_fitsY:=stopY+1;
       shapetype:=0;{rectangle}
    end;

    boxshape1.visible:=true;//show box
    show_marker_shape(mainwindow.shape_marker2,shapetype,20,20,10{minimum},shape_marker2_fitsX,shape_marker2_fitsY);


    ang_sep_two_positions(shape_marker1_fitsX,shape_marker1_fitsY, shape_marker2_fitsX,shape_marker2_fitsY,info_message2,info_message1);
    info_message2:=info_message2+#9+'        ∠ '+info_message1;

    case  QuestionDlg (pchar('Angular distance '),pchar(info_message+info_message2),mtCustom,[mrYes,'Copy to clipboard?', mrNo, 'No', 'IsDefault'],'') of
             mrYes: Clipboard.AsText:=info_message2;
    end;
    boxshape1.visible:=false; //remove info box
    Screen.Cursor:=crDefault;
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
     az_alt1.checked:=false;
   end;
end;

procedure Tmainwindow.j2000d1Click(Sender: TObject);
begin
  if j2000d1.checked then
  begin
    coord_frame:=1;
    galactic1.checked:=false;
    j2000_1.checked:=false;
    az_alt1.checked:=false;
  end;
end;


procedure Tmainwindow.galactic1Click(Sender: TObject);
begin
  if galactic1.checked then
  begin
    coord_frame:=2;
    j2000_1.checked:=false;
    j2000d1.checked:=false;
    az_alt1.checked:=false;
   end;
end;

procedure Tmainwindow.az_alt1Click(Sender: TObject);
begin
  if az_alt1.checked then
  begin
    coord_frame:=3;
    j2000_1.checked:=false;
    j2000d1.checked:=false;
    galactic1.checked:=false;
  end;
end;



procedure Tmainwindow.northeast1Click(Sender: TObject);
begin
  if head.naxis=0 then exit;
  if northeast1.checked then
  begin
    plot_north_on_image;
    image1.refresh;{important, show update}
  end
  else
    plot_fits(mainwindow.image1,false,true); {clear indicator}
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
   fitsX,fitsY,bsize,greylevels  : integer;
begin
  if head.naxis=0 then exit;
  if  ((abs(stopX-startX)>100) OR (abs(stopY-starty)>100)) then {or function since it could be parallel to x or y axis}
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    backup_img;

    bsize:=20;
    colrr1:=mode(img_loaded,false{ellipse shape},0,startX-bsize,startX+bsize,startY-bsize,startY+bsize,65535,greylevels);{find most common colour of a local area}
    if head.naxis3>1 then colgg1:=mode(img_loaded,false{ellipse shape},1,startX-bsize,startX+bsize,startY-bsize,startY+bsize,65535,greylevels);{find most common colour of a local area}
    if head.naxis3>2 then colbb1:=mode(img_loaded,false{ellipse shape},2,startX-bsize,startX+bsize,startY-bsize,startY+bsize,65535,greylevels);{find most common colour of a local area}

    colrr2:=mode(img_loaded,false{ellipse shape},0,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize,65535,greylevels);{find most common colour of a local area}
    if head.naxis3>1 then colgg2:=mode(img_loaded,false{ellipse shape},0,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize,65535,greylevels);{find most common colour of a local area}
    if head.naxis3>2 then colbb2:=mode(img_loaded,false{ellipse shape},0,stopX-bsize,stopX+bsize,stopY-bsize,stopY+bsize,65535,greylevels);{find most common colour of a local area}

    a:=sqrt(sqr(stopX-startX)+sqr(stopY-startY)); {distance between bright and dark area}

    for fitsY:=0 to head.height-1 do
      for fitsX:=0 to head.width-1 do
      begin
        b:=sqrt(sqr(fitsX-startX)+sqr(fitsY-startY)); {distance from dark spot}
        c:=sqrt(sqr(fitsX-stopX)+sqr(fitsY-stopY)); {distance from bright spot}
        p:=-((sqr(b)-sqr(a)-sqr(c))/(2*a)); {projectiestelling scheefhoekige driehoek (Dutch), polytechnisch zakboekje 42 edition, a2/24 3.2}

        img_loaded[0,fitsY,fitsX]:=img_loaded[0,fitsY,fitsX]-(colrr2-colrr1)*(a-p)/a;
        if head.naxis3>1 then img_loaded[1,fitsY,fitsX]:=img_loaded[1,fitsY,fitsX]-(colgg2-colgg1)*(a-p)/a;
        if head.naxis3>2 then img_loaded[2,fitsY,fitsX]:=img_loaded[2,fitsY,fitsX]-(colbb2-colbb1)*(a-p)/a;
      end;

    use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
    plot_fits(mainwindow.image1,false {re_center},true);

    Screen.Cursor:=crDefault;
  end {fits file}
  else
  application.messagebox(pchar('Place the mouse pointer at a dark area. Hold the right mouse button down and move the mouse pointer to a bright area.'+#10+#10+
                               'Try to select two areas without a deepsky object within 20 pixels.'+#10+#10+
                               'Moving from the dark area to the bright area should follow the direction of the gradient.'),'',MB_OK);
end;


procedure Tmainwindow.remove_longitude_latitude1Click(Sender: TObject);
var
  I: integer;
  err,success   : boolean;
  dobackup : boolean;
begin
  OpenDialog1.Title:='Select multiple  files to remove the observation location from';
  OpenDialog1.Options:=[ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter:=dialog_filter_fits_tif;

  opendialog1.initialdir:=ExtractFileDir(filename2);
  esc_pressed:=false;
  err:=false;
  if OpenDialog1.Execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}

    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        Application.ProcessMessages;
        if esc_pressed then begin err:=true;break; end;
        filename2:=Strings[I];
        mainwindow.caption:=filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count);;
        if load_image(filename2,img_loaded,head,mainwindow.memo1.lines,false {recenter},false {plot}) then
        begin
          remove_key(mainwindow.memo1.lines,'SITELAT =',true{all});
          remove_key(mainwindow.memo1.lines,'SITELONG=',true{all});
          if fits_file_name(filename2) then
            success:=savefits_update_header(mainwindow.memo1.lines,filename2)
          else
            success:=save_tiff16_secure(img_loaded,mainwindow.memo1.lines,filename2);{guarantee no file is lost}
          if success=false then begin ShowMessage('Write error !!' + filename2);Screen.Cursor:=crDefault; exit;end;
        end
        else err:=true;
      end;
      if err=false then mainwindow.caption:='Completed, all files converted.'
      else
      begin
        beep;
        ShowMessage('Errors!! Files modified but with errors or stopped!!');
      end;
      finally
      if dobackup then restore_img;{for the viewer}
      Screen.Cursor:=crDefault;  { Always restore to normal }
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

///  form_asteroids1.close;   {normal this form is not loaded}
  mainwindow.setfocus;

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


procedure measure_magnitudes(annulus_rad,x1,y1,x2,y2:integer; deep: boolean; var stars :star_list);{find stars and return, x,y, hfd, flux. x1,y1,x2,y2 are a subsection if required}
var
  fitsX,fitsY,radius, i, j,nrstars,n,m,xci,yci,sqr_radius: integer;
  hfd1,star_fwhm,snr,flux,xc,yc,detection_level,hfd_min  : double;
  img_sa : image_array;
  saturation_level : single;

begin

  SetLength(stars,5,5000);{set array length}

  setlength(img_sa,1,head.height,head.width);{set length of image array}

  get_background(0,img_loaded,false{histogram is already available},true {calculate noise level},{out}bck);{calculate background level from peek histogram}

  if deep then detection_level:=5*bck.noise_level else detection_level:=bck.star_level;
  hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}

  nrstars:=0;{set counters at zero}

  if head.calstat = '' then saturation_level := 64000
  else
    saturation_level := 60000; {could be dark subtracted changing the saturation level}
  saturation_level:=min(head.datamax_org-1,saturation_level);

  for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1  do
      img_sa[0,fitsY,fitsX]:=-1;{mark as star free area}

  for fitsY:=y1 to y2-1 do
  begin
    for fitsX:=x1 to x2-1  do
    begin
      if (( img_sa[0,fitsY,fitsX]<=0){area not occupied by a star} and (img_loaded[0,fitsY,fitsX]- bck.backgr> detection_level)) then {new star}
      begin
        HFD(img_loaded,fitsX,fitsY,annulus_rad {typical 14, annulus radius},head.mzero_radius,0 {adu_e}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
        if ((hfd1<15) and (hfd1>=hfd_min) {two pixels minimum} and (snr>10)) then {star detected in img_loaded}
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
                img_sa[0,j,i]:=1;
            end;

          if ((img_loaded[0,round(yc),round(xc)]<saturation_level) and
              (img_loaded[0,round(yc),round(xc-1)]<saturation_level) and
              (img_loaded[0,round(yc),round(xc+1)]<saturation_level) and
              (img_loaded[0,round(yc-1),round(xc)]<saturation_level) and
              (img_loaded[0,round(yc+1),round(xc)]<saturation_level) and

              (img_loaded[0,round(yc-1),round(xc-1)]<saturation_level) and
              (img_loaded[0,round(yc+1),round(xc-1)]<saturation_level) and
              (img_loaded[0,round(yc-1),round(xc+1)]<saturation_level) and
              (img_loaded[0,round(yc+1),round(xc+1)]<saturation_level)  ) then {not saturated}
          begin
            {store values}
            inc(nrstars);
            if nrstars>=length(stars[0]) then
            begin
              SetLength(stars,5,nrstars+5000);{adapt array size if required}
            end;
            stars[0,nrstars-1]:=xc; {store star position}
            stars[1,nrstars-1]:=yc;
            stars[2,nrstars-1]:=hfd1;
            stars[3,nrstars-1]:=flux;
            stars[4,nrstars-1]:=snr;
          end;{not saturated}
        end;{HFD good}
      end;
    end;
  end;

  img_sa:=nil;{free mem}

  SetLength(stars,5,nrstars);{set length correct}
end;


procedure calibrate_photometry(img : image_array; memo : tstrings; var head : Theader);
var
  apert,annul,hfd_med : double;
  hfd_counter                : integer;
begin
  if ((head.naxis=0) or (head.cd1_1=0)) then exit;

  apert:=strtofloat2(stackmenu1.flux_aperture1.text); {text "max" will generate a zero}
  if ((head.mzero=0) or (aperture_ratio<>apert){new calibration required} or (passband_active<>head.passband_database))  then
  begin
    memo2_message('Photometric calibration of the measured stellar flux.');
    annulus_radius:=14;{calibrate for extended objects}
    head.mzero_radius:=99;{calibrate for extended objects}

    aperture_ratio:=apert;{remember setting}
    if apert<>0 then {smaller aperture for photometry. Setting <> max}
    begin
      analyse_image(img,head,30,0 {report nr stars and hfd only}, hfd_counter,bck,hfd_med); {find background, number of stars, median HFD}
      if hfd_med<>0 then
      begin
        memo2_message('Median HFD is '+floattostrf(hfd_med, ffgeneral, 2,2)+'. Aperture and annulus will be adapted accordingly.');;
        head.mzero_radius:=hfd_med*apert/2;{radius}
        annul:=strtofloat2(stackmenu1.annulus_radius1.text);
        annulus_radius:=min(50,round(hfd_med*annul/2)-1);{Radius. Limit to 50 to prevent runtime errors}
      end;
    end
    else
    memo2_message('To increase the accuracy of point sources magnitudes set a smaller aperture diameter in tab "photometry".');

    plot_and_measure_stars(img,memo, head,true {calibration},false {plot stars},true{report lim magnitude});
  end;
end;


procedure Tmainwindow.annotate_unknown_stars1Click(Sender: TObject);
var
  size,radius, i,j, starX, starY,fitsX,fitsY,n,m,xci,yci,hfd_counter,search_radius,countN,countO     : integer;
  Fliphorizontal, Flipvertical,saturated : boolean;
  hfd1,star_fwhm,snr,flux,xc,yc,measured_magn,magnd,magn_database, delta_magn,magn_limit_database,
  sqr_radius, hfd_median : double;
  messg : string;
  img_temp3,img_sa :image_array;
  data_max: single;
const
   default=1000;

 begin
  if head.naxis=0 then exit; {file loaded?}
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  calibrate_photometry(img_loaded,mainwindow.Memo1.lines,head);


  if head.mzero=0 then
  begin
    beep;
    img_sa:=nil;
    img_temp3:=nil;
    Screen.Cursor:=crDefault;
    exit;
  end;

  Flipvertical:=mainwindow.flip_vertical1.Checked;
  Fliphorizontal:=mainwindow.Flip_horizontal1.Checked;

  magn_limit_database:=10*21;//magn, Online Gaia via Vizier

  image1.Canvas.Pen.Mode := pmMerge;
  image1.Canvas.Pen.width :=1;
  image1.Canvas.brush.Style:=bsClear;
  image1.Canvas.font.color:=clyellow;
  image1.Canvas.font.name:='default';
  image1.Canvas.font.size:=10;
  mainwindow.image1.Canvas.Pen.Color := clred;


  setlength(img_temp3,1,head.height,head.width);{set size of image array}
  for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1  do
      img_temp3[0,fitsY,fitsX]:=default;{clear}
  plot_artificial_stars(img_temp3,head,magn_limit {measured});{create artificial image with database stars as pixels}

//  img_loaded:=img_temp3;
//  plot_fits(mainwindow.image1,true,true);
//  exit;

//  get_background(0,img_loaded,false{histogram is already available},true {calculate noise level},{var}cblack,star_level);{calculate background level from peek histogram}

  analyse_image(img_loaded,head,10 {snr_min},0 {report nr stars and hfd only},hfd_counter,bck, hfd_median); {find background, number of stars, median HFD}
  search_radius:=max(3,round(hfd_median));

  setlength(img_sa,1,head.height,head.width);{set length of image array}
   for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1  do
      img_sa[0,fitsY,fitsX]:=-1;{mark as star free area}


  countN:=0;
  countO:=0;
  data_max:=head.datamax_org-1;

  for fitsY:=0 to head.height-1 do
  begin
    for fitsX:=0 to head.width-1  do
    begin
      if (( img_sa[0,fitsY,fitsX]<=0){area not occupied by a star} and (img_loaded[0,fitsY,fitsX]- bck.backgr>5*bck.noise_level {star_level} ){star}) then {new star}
      begin

        HFD(img_loaded,fitsX,fitsY,round(1.5* hfd_median){annulus radius},3.0*hfd_median {flux aperture restriction},0 {adu_e}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}

        //memo2_message(floattostr(xc)+',  ' +floattostr(yc));

        xci:=round(xc);{star center as integer}
        yci:=round(yc);
        if ((xci>0) and (xci<head.width-1) and (yci>0) and (yci<head.height-1)) then
        saturated:=not ((img_loaded[0,yci,xci]<data_max) and
                        (img_loaded[0,yci,xci-1]<data_max) and
                        (img_loaded[0,yci,xci+1]<data_max) and
                        (img_loaded[0,yci-1,xci]<data_max) and
                        (img_loaded[0,yci+1,xci]<data_max) and

                        (img_loaded[0,yci-1,xci-1]<data_max) and
                        (img_loaded[0,yci+1,xci-1]<data_max) and
                        (img_loaded[0,yci-1,xci+1]<data_max) and
                        (img_loaded[0,yci+1,xci+1]<data_max)  )
        else saturated:=false;

        if (((hfd1<hfd_median*1.3) or (saturated){larger then normal}) and (hfd1>=hfd_median*0.75) and (snr>10)) then {star detected in img_loaded}
        begin
                      {for testing}
              //      if flipvertical=false  then  starY:=round(head.height-yc) else starY:=round(yc);
              //      if fliphorizontal=true then starX:=round(head.width-xc)  else starX:=round(xc);
              //      size:=round(5*hfd1);
              //      mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
              //      mainwindow.image1.Canvas.textout(starX+size,starY+size,floattostrf(hfd1, ffgeneral, 2,1));{add hfd as text}
              //      if ((abs(xc-2294)<4) and  (abs(yc-274)<4)) then
              //      beep;

          radius:=round(3.0*hfd_median);{for marking star area. A value between 2.5*hfd and 3.5*hfd gives same performance. Note in practice a star PSF has larger wings then predicted by a Gaussian function}
          sqr_radius:=sqr(radius);
          for n:=-radius to +radius do {mark the whole circular star area as occupied to prevent double detection's}
            for m:=-radius to +radius do
            begin
              j:=n+yci;
              i:=m+xci;
              if ((j>=0) and (i>=0) and (j<head.height) and (i<head.width) and (sqr(m)+sqr(n)<=sqr_radius)) then
              img_sa[0,j,i]:=+1;{mark as star area}
            end;
           measured_magn:=round(10*(head.MZERO - ln(flux)*2.5/ln(10)));{magnitude x 10}
           if measured_magn<magn_limit_database-10 then {bright enough to be in the database}
           begin
             magn_database:=default;{1000}
             for i:=-search_radius to search_radius do  //search for database star within circle with a diameter of 5 pixels
               for j:=-search_radius to search_radius do
               if sqr(i)+sqr(j)<=sqr(search_radius) then //circle tolerance area
               begin {database star available?}
                 magnd:=img_temp3[0,round(yc)+j,round(xc)+i];
                 if magnd<default then {a star from the database}
                   if magn_database=default then //empthy
                      magn_database:=magnd //no star at this location
                    else
                      magn_database:=-2.5*ln(power(10,-0.4*magn_database) + power(10,-0.4*magnd))/ln(10);//combine magnitudes of the stars
               end;

             delta_magn:=measured_magn - magn_database; {delta magnitude time 10}
             if  delta_magn<-10 then {unknown star, 1 magnitude brighter then database}
             begin {mark}
               if Flipvertical=false then  starY:=round(head.height-yc) else starY:=round(yc);
               if Fliphorizontal     then starX:=round(head.width-xc)  else starX:=round(xc);
               if magn_database=1000 then
               begin
                  messg:=''; {unknown star}
                  inc(countN);
               end
               else
               begin
                 messg:=' Δ'+inttostr(round(delta_magn)); {star but wrong magnitude}
                 inc(countO);
               end;
               size:=round(5*hfd1); {for rectangle annotation}
               image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
               image1.Canvas.textout(starX+size,starY,inttostr(round(measured_magn))  +messg );{add magnitude as text}
             end;
           end;

        end;{HFD good}
      end;
    end;
  end;


  img_temp3:=nil;{free mem}
  img_sa:=nil;{free mem}

  mainwindow.image1.Canvas.font.size:=10;
  mainwindow.image1.Canvas.brush.Style:=bsClear;
  mainwindow.image1.Canvas.textout(20,head.height-20,inttostr(countN)+' unknown stars, '+inttostr(countO)+' magnitude offsets.' );

  Screen.Cursor:=crDefault;
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
  Pivot, T: double;{ pivot, T are the same type as the elements of array }
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


function SMedian(list: array of double; leng: integer): double;{get median of an array of double}
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
        if leng<=3 then result:=list[mid]
        else
        result:=(list[mid-1]+list[mid]+list[mid+1])/3;
      end
      else
      result:=(list[mid]+list[mid+1])/2;
  end;
end;


procedure Tmainwindow.annotate_with_measured_magnitudes1Click(Sender: TObject);
var
  size, i, starX, starY,magn,fontsize,text_height,text_width,dum,formalism    : integer;
  Fliphorizontal, Flipvertical  : boolean;
  magnitude,raM,decM,v,b,r,sg,sr,si,g,bp,rp : double;

  stars : star_list;
  subframe : boolean;
  report,rastr,decstr : string;
begin
  if head.naxis=0 then exit; {file loaded?}
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  subframe:=(sender=export_star_info1); //full frame or sub section
  formalism:=mainwindow.Polynomial1.itemindex;

  calibrate_photometry(img_loaded,mainwindow.Memo1.lines,head);

  if head.mzero=0 then
  begin
    beep;
    Screen.Cursor:=crDefault;
    exit;
  end;

  Flipvertical:=mainwindow.flip_vertical1.Checked;
  Fliphorizontal:=mainwindow.Flip_horizontal1.Checked;

  image1.Canvas.Pen.Mode := pmMerge;
  image1.Canvas.Pen.width :=1;
  image1.Canvas.Pen.color :=clred;
  image1.Canvas.brush.Style:=bsClear;
  image1.Canvas.font.color:=clyellow;
  image1.Canvas.font.name:='default';

  fontsize:=8;
  image1.Canvas.font.size:=fontsize;
  text_height:=mainwindow.image1.Canvas.textheight('T');{the correct text height, also for 4k with "make everything bigger"}

  mainwindow.image1.Canvas.Pen.Color := clred;
  mainwindow.image1.Canvas.Pen.mode := pmXor;


  if subframe then
  begin
    if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
    if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;
    measure_magnitudes(14,startX,startY,stopX,stopY,true {deep},stars);
    report:=magn_limit_str+#10;
    report:=report+'Passband filter used: '+head.filter_name+#10;
    report:=report+'Passband database='+head.passband_database+#10;
    report:=report+'Magnitudes are only valid if passband filter and passband database are compatible. E.g. CV=BP, G=V, R=R, B=B.'+#10;
    report:=report+'Option 1) Select in tab photometry a local database and in tab alignment the local database (standard=BP or V50=V)'+#10;
    report:=report+'Option 2) Select an online database in tab photometry.'+#10+#10;
    report:=report+'Saturated stars are excluded to avoid photometric errors. For photometry purposes ignore stars with a low SNR value (SNR<30).'+#10+#10;
    report:=report+'fitsX'+#9+'fitsY'+#9+'HFD'+#9+'α[°]'+#9+'δ[°]'+#9+'ADU'+#9+'SNR'+#9+'Magn_measured'+#9+'|'+#9+'Gaia-V'+#9+'Gaia-B'+#9+'Gaia-R'+#9+'Gaia-SG'+#9+'Gaia-SR'+#9+'Gaia-SI'+#9+'Gaia-G'+#9+'Gaia-BP'+#9+'Gaia-RP'+#10;
  end
  else
    measure_magnitudes(14,0,0,head.width-1,head.height-1,true {deep},stars);


  if length(stars[0])>0 then
  begin
    for i:=0 to  length(stars[0])-1 do
    begin
      if Flipvertical=false then  starY:=round(head.height-1-stars[1,i]) else starY:=round(stars[1,i]);
      if Fliphorizontal     then starX:=round(head.width-1-stars[0,i])  else starX:=round(stars[0,i]);

      size:=round(stars[2,i]);{5*hfd for marking stars}

      mainwindow.image1.Canvas.moveto(starX+2*size,starY);
      mainwindow.image1.Canvas.lineto(starX+size,starY);
      mainwindow.image1.Canvas.moveto(starX-2*size,starY);
      mainwindow.image1.Canvas.lineto(starX-size,starY);

      magnitude:=(head.mzero - ln(stars[3,i]{flux})*2.5/ln(10));//flux to magnitude
      magn:=round(10*magnitude);
      image1.Canvas.textout(starX,starY-text_height,inttostr(magn) );{add magnitude as text}

      if subframe then
      begin
        pixel_to_celestial(head,1+stars[0,i],1+stars[1,i],formalism,raM,decM);//+1 to get fits coordinated
        rastr:=floattostrF(raM*180/pi,FFfixed,9,6);
        decstr:=floattostrF(decM*180/pi,FFfixed,9,6);

        report_one_star_magnitudes(raM,decM, {out} b,v,r,sg,sr,si,g,bp,rp ); //report the database magnitudes for a specfic position. Not efficient but simple

        report:=report+floattostrF(1+stars[0,i],FFfixed,6,2)+#9+floattostrF(1+stars[1,i],FFfixed,6,2)+#9+floattostrF(stars[2,i],FFfixed,5,3)+#9+rastr+#9+decstr+#9+floattostrF(1+stars[3,i],FFfixed,8,0)+#9+floattostrF(stars[4,i]{SNR},FFfixed,5,0)+#9+floattostrF(magnitude,FFfixed,5,3)+#9+'|'
                      +#9+floattostrF(v,FFfixed,5,3)+#9+floattostrF(b,FFfixed,5,3)+#9+floattostrF(r,FFfixed,5,3)+#9+floattostrF(sg,FFfixed,5,3)+#9+floattostrF(sr,FFfixed,5,3)+#9+floattostrF(si,FFfixed,5,3)
                      +#9+floattostrF(g,FFfixed,5,3)+#9+floattostrF(bp,FFfixed,5,3)+#9+floattostrF(rp,FFfixed,5,3)+ #10;
      end;
    end;
  end
  else
  memo2_message('No stars found!');



  if subframe=false then
  begin
    text_width:=8*mainwindow.image1.Canvas.textwidth('1234567890');{Calculate textwidth for 80 characters. This also works for 4k with "make everything bigger"}
    fontsize:=trunc(fontsize*(head.width-2*fontsize)/text_width);{use full width for 80 characters}
    image1.Canvas.font.size:=fontsize;
    image1.Canvas.font.color:=clwhite;
    text_height:=mainwindow.image1.Canvas.textheight('T');{the correct text height, also for 4k with "make everything bigger"}
    image1.Canvas.textout(round(fontsize*2),head.height-text_height,magn_limit_str);  {magn_limit global variable calculate in plot_and_measure_stars}


  end
  else
  begin// to Clipboard
    Clipboard.AsText:=report;
  end;

  stars:=nil;

  Screen.Cursor:=crDefault;
end;


procedure Tmainwindow.annotations_visible1Click(Sender: TObject);
begin
//  annotations_visible1.checked:= annotations_visible1.checked=false;
  stackmenu1.annotations_visible2.checked:=annotations_visible1.checked; {follow in stack menu}
  if head.naxis=0 then exit;
  if annotations_visible1.checked=false then  {clear screen}
    plot_fits(mainwindow.image1,false,true)
  else
    if annotated then plot_annotations(false {use solution vectors},false);


//  stackmenu1.annotations_visible2.checked:=annotations_visible1.checked; {follow in stack menu}
//  if head.naxis=0 then exit;
//  if annotations_visible1.checked=false then  {clear screen}
//    plot_fits(mainwindow.image1,false,true)
//  else
//    if annotated then plot_annotations(false {use solution vectors},false);

end;


procedure Tmainwindow.autocorrectcolours1Click(Sender: TObject);
begin
  stackmenu1.auto_background_level1Click(nil);
  stackmenu1.apply_factor1Click(nil);
end;


procedure Tmainwindow.batch_annotate1Click(Sender: TObject);
var
  I: integer;
  skipped, nrannotated :integer;
  dobackup,success : boolean;
begin
  OpenDialog1.Title:= 'Select multiple  files to add asteroid annotation to the header';
  OpenDialog1.Options:= [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter:=dialog_filter_fits_tif;
  esc_pressed:=false;

  if OpenDialog1.Execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

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
          if esc_pressed then begin break; end;

          if load_fits(filename2,true {light},true,true {update memo},0,mainwindow.memo1.lines,head,img_loaded) then {load image success}
          begin
            if head.cd1_1=0 then
            begin
              skipped:=skipped+1; {not astrometric solved}
              memo2_message('Skipped: '+filename2+' No solution in header found. First batch solve the images');
            end
            else
            begin
              plot_mpcorb(strtoint(maxcount_asteroid),strtofloat2(maxmag_asteroid),true {add annotations},false);
              if fits_file_name(filename2) then
                success:=savefits_update_header(mainwindow.memo1.lines,filename2)
              else
                success:=save_tiff16_secure(img_loaded,mainwindow.memo1.lines,filename2);{guarantee no file is lost}
              if success=false then begin ShowMessage('Write error !!' + filename2);Screen.Cursor:=crDefault; exit;end;
              nrannotated :=nrannotated +1;
            end;
          end;
        end;
      finally
      if dobackup then restore_img;{for the viewer}
      Screen.Cursor:=crDefault;  { Always restore to normal }
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


{type
   adata = array of word;
function rice_encoding(inp : adata; k,bitdepth : integer; out  outp : adata ; out compressedSize : integer) : boolean;
var
   i,j,m,m2,s,r,r2, q,x,bitpointer,len : longword;
   res,res_sum : longword;

         procedure put_bit( value : byte);
         var
           y,rest : longint;
               val : word;
         begin
           y:=bitpointer div bitdepth;
           rest:=bitpointer - y * bitdepth;

           if y>compressedSize then
           begin
             inc(compressedSize);//compressedSize:=y
             outp[y]:=0; //clear the byte
           end;
           outp[y]:=outp[y] or (value shl rest); //store right to left. Else use shl (bitdepth-1-rest)

           inc(bitpointer);
         end;
begin
  result:=true;
  len:=length(inp);
  setlength(outp,len);//allow maximum same size as input

  m := 1 shl k;//calculate 2^k
  dec(m);//special. See remark 1

  compressedSize:=0;
  bitpointer:=0;

  for j:=0 to len-1 do
  begin
    q:= inp[j] shr k; // quotient part, equivalent as inp[j]/2^k
    r:=inp[j] and m;  // remainder part, fast way. Remark 1, Other solution would be  r:=inp[j] - q*m if dec(m) is not applied.

    for i:=1 to q do
       put_bit(1);
    put_bit(0);

    for i:=k-1 downto 0 do put_bit( (r shr i) and 1 ); // remainder part

    if compressedSize>=len-1 then
    begin
      result:=false;
      break;
    end;//compression larger then orginal
  end;//for loop
  inc(compressedSize);
end;      }

//procedure Tmainwindow.Button1Click(Sender: TObject);
//var
//   inp,outp : array of word;
//   i,j,k,bestK,compressedSize:  integer;
//   com,bestcompression : double;
//begin
//  setlength(inp,head.Width*head.height);
//  setlength(inp,head.Width);
//  for i:=0 to head.Width-1 do
//  inp[i]:=round(img_loaded[0,i,(head.height div 3)]{/16});
//  bestcompression:=999;
//  bestK:=0;
//  for k:=1 to 15 do //find best K factor for one line
//  begin
//    if rice_encoding(inp, k,16,outp,compressedSize) = true then
//       if compressedSize/head.Width<bestcompression then begin bestk:=k; bestcompression:=compressedSize/head.Width; end;
//  end;
//  if bestk=0 then exit;

//  inp:=nil;
//  setlength(inp,head.Width*head.height);
//  for i:=0 to head.Width-1 do
//  for j:=0 to head.height-1 do
//  begin
//    inp[i*j]:=round(img_loaded[0,i,j]{/16});
//    img_loaded[0,i,j]:=inp[i*j];

//  end;
//  if rice_encoding(inp, bestk,16,outp,compressedSize) = false then
//   beep;
//  com:=compressedSize/(head.Width*head.height);
//  beep;

//  inp:=nil;
//  outp:=nil;
//end;


procedure standard_equatorial2(ra0,dec0,x,y,cdelt: double; var ra,dec : double); inline;{transformation from CCD coordinates into equatorial coordinates}
var sin_dec0 ,cos_dec0 : double;
begin
  sincos(dec0  ,sin_dec0 ,cos_dec0);
  x:=x *cdelt/ (3600*180/pi);{scale CCD pixels to standard coordinates (tang angle)}
  y:=y *cdelt/ (3600*180/pi);

  ra  := ra0 + arctan2 (-x, cos_DEC0- y*sin_DEC0);{atan2 is required for images containing celestial pole}
  if ra>pi*2 then ra:=ra-pi*2; {prevent values above 2*pi which confuses the direction detection later}
  if ra<0 then ra:=ra+pi*2;
  dec := arcsin ( (sin_dec0+y*cos_dec0)/sqrt(1.0+x*x+y*y) );
end;


procedure Tmainwindow.calibrate_photometry1Click(Sender: TObject);
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  calibrate_photometry(img_loaded,mainwindow.Memo1.lines,head);
  Screen.Cursor:=crDefault;
end;

procedure Tmainwindow.Constellations1Click(Sender: TObject);
begin
  if head.naxis=0 then exit;
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

procedure Tmainwindow.grid_az_alt1Click(Sender: TObject);
begin
  if head.naxis=0 then exit;
  if grid_az_alt1.checked=false then  {clear screen}
  begin
    plot_fits(mainwindow.image1,false,true);
  end
  else
  plot_grid(false);//az,alt grid
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
    add_marker_position1.checked:=place_marker3(marker_position);{place a marker}
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
  if head.naxis<>0 then
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


procedure Tmainwindow.stretch1Exit(Sender: TObject);
begin
  do_stretching;
end;


procedure Tmainwindow.stretch_draw_fits1Click(Sender: TObject);
var
  tmpbmp: TBitmap;
  ARect: TRect;
  x, y,x2,y2 : Integer;
  xLine: PByteArray;
  ratio    : double;
  flipH,flipV : boolean;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

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

      setlength(img_loaded,head.naxis3,head.height,head.width);

      for y := 0 to head.height -1 do begin {place in array}
        xLine := TmpBmp.ScanLine[y];
        for x := 0 to head.width -1 do
        begin
          if flipH then x2:=head.width-1-x else x2:=x;
          if flipV=false then y2:=head.height-1-y else y2:=y;
          img_loaded[0,y2,x2]:=xLine^[x*3];{red}
          if head.naxis3>1 then img_loaded[1,y2,x2]:=xLine^[x*3+1];{green}
          if head.naxis3>2 then img_loaded[2,y2,x2]:=xLine^[x*3+2];{blue}
        end;
      end;

      mainwindow.Memo1.Lines.BeginUpdate;

      update_integer(mainwindow.memo1.lines,'NAXIS1  =',' / length of x axis                               ' ,head.width);
      update_integer(mainwindow.memo1.lines,'NAXIS2  =',' / length of y axis                               ' ,head.height);
      update_integer(mainwindow.memo1.lines,'DATAMAX =',' / Maximum data value                             ' ,255);


      if head.crpix1<>0 then begin head.crpix1:=head.crpix1*ratio; update_float(mainwindow.memo1.lines,'CRPIX1  =',' / X of reference pixel                           ',false ,head.crpix1);end;
      if head.crpix2<>0 then begin head.crpix2:=head.crpix2*ratio; update_float(mainwindow.memo1.lines,'CRPIX2  =',' / Y of reference pixel                           ',false ,head.crpix2);end;

      if head.cdelt1<>0 then begin head.cdelt1:=head.cdelt1/ratio; update_float(mainwindow.memo1.lines,'CDELT1  =',' / X pixel size (deg)                             ',false ,head.cdelt1);end;
      if head.cdelt2<>0 then begin head.cdelt2:=head.cdelt2/ratio; update_float(mainwindow.memo1.lines,'CDELT2  =',' / Y pixel size (deg)                             ',false ,head.cdelt2);end;

      if head.cd1_1<>0 then
      begin
        head.cd1_1:=head.cd1_1/ratio;
        head.cd1_2:=head.cd1_2/ratio;
        head.cd2_1:=head.cd2_1/ratio;
        head.cd2_2:=head.cd2_2/ratio;
        update_float(mainwindow.memo1.lines,'CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_1);
        update_float(mainwindow.memo1.lines,'CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_2);
        update_float(mainwindow.memo1.lines,'CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_1);
        update_float(mainwindow.memo1.lines,'CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_2);
      end;

      head.XBINNING:=head.XBINNING/ratio;
      head.YBINNING:=head.YBINNING/ratio;
      update_float(mainwindow.memo1.lines,'XBINNING=',' / Binning factor in width                         ',false ,head.XBINNING);
      update_float(mainwindow.memo1.lines,'YBINNING=',' / Binning factor in height                        ',false ,head.YBINNING);

      if head.XPIXSZ<>0 then
      begin
        head.XPIXSZ:=head.XPIXSZ/ratio;
        head.YPIXSZ:=head.YPIXSZ/ratio;
        update_float(mainwindow.memo1.lines,'XPIXSZ  =',' / Pixel width in microns (after stretching)       ',false ,head.XPIXSZ);
        update_float(mainwindow.memo1.lines,'YPIXSZ  =',' / Pixel height in microns (after stretching)      ',false ,head.YPIXSZ);
        update_float(mainwindow.memo1.lines,'PIXSIZE1=',' / Pixel width in microns (after stretching)       ',false ,head.XPIXSZ);
        update_float(mainwindow.memo1.lines,'PIXSIZE2=',' / Pixel height in microns (after stretching)      ',false ,head.YPIXSZ);
      end;

      add_text(mainwindow.memo1.lines,'HISTORY   ','Image stretched with factor '+ floattostr6(ratio));

      mainwindow.Memo1.Lines.EndUpdate;

      remove_photometric_calibration;//from header

      {plot result}
      use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
      plot_fits(mainwindow.image1,true {center_image},true);{center and stretch with current settings}

    finally
       TmpBmp.Free;
    end;
    except
  end;
  Screen.Cursor:=crDefault;
end;



procedure Tmainwindow.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  if ((last_extension) and (button=btNext)) then
  begin
    UpDown1.position:=UpDown1.position-1; {no more extensions}
    exit;
  end;
  if load_fits(filename2,true,true,true {update memo},updown1.position,mainwindow.memo1.lines,head,img_loaded){load fits file } then
  begin
    if head.naxis<>0 then {not a bintable, compressed}
    begin
      if ((head.naxis3=1) and (mainwindow.preview_demosaic1.checked)) then
         demosaic_advanced(img_loaded) {demosaic and set levels}
      else
        use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
      plot_fits(mainwindow.image1,false {re_center},true);
    end;
  end;
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

procedure update_mainmenu_mac;// for Mac
begin
  with mainwindow do
  begin
    with LoadFITSPNGBMPJPEG1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with select_directory_thumb1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with recent1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with recent2 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with recent3 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with recent4 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with recent5 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with recent6 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with recent7 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with recent8 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000

    with Saveasfits1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with Export_image1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with SaveasJPGPNGBMP1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with Exit1 do shortcut:=menus.ShortCut(VK_Q, [ssMeta]);      // Meta-Q

    with Stackimages1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000

    //tools
    with astrometric_solve_image1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with inversimage1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with convertmono1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with undo1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000

    with bin_2x2menu1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with bin_3x3menu1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with rotate1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with flip_v1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with rotate_arbitrary1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000

    with clean_up1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with calibrate_photometry1  do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    //sqm1 no change to avoid conflict with Exit
    with annotate_with_measured_magnitudes1 {ctrl+alt+m} do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with star_annotation1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with annotate_unknown_stars1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with variable_star_annotation1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with annotate_minor_planets1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with hyperleda_annotation1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with deepsky_annotation1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000

    //view
    with image_cleanup1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with center_lost_windows do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000

    with flip_horizontal1 do shortcut:=menus.ShortCut(VK_H,[ssMeta,ssShift]);//note Macs universally use Cmd-H for "Hide App so add shift"
    with flip_vertical1 do shortcut:=menus.ShortCut(VK_V,[ssMeta,ssShift]);


    with fittowindow1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with zoomfactorone1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with grid_ra_dec1 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000

    //headermemo
    with Menufind2 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
    with select_all2 do shortcut:=(shortcut and $BFFF) or $1000;//replace Ctrl equals $4000 by Meta equals $1000
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
      if DirectoryExists('/opt/astap')=false then
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
  memox:= Tstringlist.Create; ; // this needs to be TStringList

  head.naxis:=0; {not fits files available}

 {$IfDef Darwin}// for MacOS
  if commandline_execution=false then update_mainmenu_mac;
 {$endif}
end;



procedure Tmainwindow.deepsky_annotation1Click(Sender: TObject);
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img;
  load_deep;{load the deepsky database once. If loaded no action}
  plot_deepsky(false,8);{plot the deep sky object on the image}
  Screen.Cursor:=crDefault;
end;


procedure Tmainwindow.add_marker1Click(Sender: TObject);
begin
  if add_marker1.checked=false then
    mainwindow.shape_marker1.Visible:=false
  else
  begin
    shape_marker1_fitsX:=startX+1;
    shape_marker1_fitsY:=startY+1;
    mainwindow.shape_marker1.Visible:=true;
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
  recent_files.free;
  memox.free;//free tstrings

// arrays and string are automatic deallocated
//  wide_field_stars:=nil; {free wide_field_database}
//  vsp:=nil;
//  vsx:=nil;
//  online_database:=nil; // free mem
//  streak_lines:=nil;
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

procedure flip(x1,y1 : integer; out x2,y2 :integer);{array to screen or screen to array}
begin
  if mainwindow.Flip_horizontal1.Checked then
  begin
    x2:=(head.width-1)-x1;{flip for screen coordinates, 0...head.width-1}
  end
  else
    x2:=x1;

  if mainwindow.flip_vertical1.Checked=false then
  begin
    y2:=(head.height-1)-y1;
  end
  else
  y2:=y1;
end;


procedure plot_the_annotation(x1,y1,x2,y2:integer; typ:double; name :string);{plot annotation from header in ASTAP format}
var                                                                               {typ >0 line, value defines thickness line}
  size,xcenter,ycenter,text_height,text_width,fontsize,left,top  :integer;                          {type<=0 rectangle or two lines, value defines thickness lines}
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

  if head.height<512 then fontsize:=8 else fontsize:=12;
  mainwindow.image1.Canvas.Pen.width:=max(1,round(1*abs(typ))); ;
  mainwindow.image1.Canvas.font.size:=max(fontsize,round(fontsize*abs(typ)));

  if typ>0 then {single line}
  begin
    mainwindow.image1.Canvas.moveto(x1,y1);
    mainwindow.image1.Canvas.lineto(x2,y2);
  end
  else
  begin {rectangle or two indicating lines}
     size:=abs(x2-x1);
     if ((size>5) and (abs(y2-y1)>5)) then
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

  if x2>=x1 then left:=x2 else left:=x2-text_width;
  left:=min(left, head.width-text_width);{stay away from the right side}

  if y2>=y1 then top:=y2 - (text_height div 3) else top:=y2- text_height;
  top:=min(top, head.height-text_height);{stay away from the bottom}

  mainwindow.image1.Canvas.textout( left,top ,name{name});
end;


procedure plot_annotations(use_solution_vectors,fill_combo : boolean); {plot annotations stored in fits header. Offsets are for blink routine}
var
  count1,x1,y1,x2,y2 : integer;
  typ     : double;
  List: TStrings;
  name,magn : string;
begin
  if head.naxis=0 then exit; {file loaded?}

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

          if (  ( abs(shape_var1_fitsX-(x1+x2)/2) <30) and (abs(shape_var1_fitsY-(y1+y2)/2)<30)) then
          begin
            var_lock:=list[5];
          end;


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

          plot_the_annotation(x1,y1,x2,y2,typ, name+magn);

          if ((list.count>7) and (abs( (x1+x2)/2 - (startx+stopx)/2)<15 ) and  (abs((y1+y2)/2 - (starty+stopy)/2)<15)) then
              minor_planet_at_cursor:=list[7];//for mpc1992 report line

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


procedure annotation_position(aname:string;var ra,dec : double);// calculate ra,dec position of one annotation
var
  count1,x1,y1,x2,y2,formalism : integer;
  List: TStrings;
//  dummy : string;
begin
  if head.naxis=0 then exit; {file loaded?}
  if head.cd1_1=0 then exit;

  List := TStringList.Create;
  list.StrictDelimiter:=true;
  formalism:=mainwindow.Polynomial1.itemindex;

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
         // dummy:=list[5];
          if aname=list[5] then //object found
          begin
            x1:=round(strtofloat2(list[0]));
            y1:=round(strtofloat2(list[1]));
            x2:=round(strtofloat2(list[2]));
            y2:=round(strtofloat2(list[3]));
            pixel_to_celestial(head,(x1+x2)/2,(y1+y2)/2,formalism, ra,dec {RA, DEC position annotation});
            count1:=-1; //stop
          end;

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
     img_loaded[0,startY+round(i*deltaY/len) ,startX+round(i*deltaX/len)]:=round((cwhite+bck.backgr)/2);

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

  annotation_to_array(value, true{transparant},round((cwhite+bck.backgr)/2) {colour},fontsize,stopX+x2,stopY+y2,img_loaded);{string to image array as annotation, result is flicker free since the annotion is plotted as the rest of the image}

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

  plot_the_annotation(startX,startY,text_X,text_Y,boldness,value);
  add_text(mainwindow.memo1.lines,'ANNOTATE=',#39+copy(inttostr(startX)+';'+inttostr(startY)+';'+inttostr(text_X)+';'+inttostr(text_Y)+';'+floattostr6(boldness)+';'+value+';',1,68)+#39);
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
  if load_fits(filen,true {light},true,true {update memo},0,mainwindow.memo1.lines,head,img_loaded) {load now normal} then
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
  'Filter: '+head.filter_name+#13+#10+
  'Calibration-status: '+head.calstat+#13+#10+
  'Date-obs: '+head.date_obs+#13+#10+
  'Exposure-time: '+floattostr(head.exposure));
  messagebox(mainwindow.handle,bericht,'Basic fits header',MB_OK);
end;


function position_to_string(sep:string; ra,dec:double):string;
var
  l, b,az,alt : double;
begin
  if coord_frame=0 then
    result:=prepare_ra8(ra,': ')+sep+prepare_dec2(dec,'° ')
  else
  if coord_frame=1 then
    result:=floattostrF(ra*180/pi, FFfixed, 0, 8)+'°'+sep+floattostrF(dec*180/pi, FFfixed, 0, 8)+'°'
  else
  if coord_frame=2 then
  begin
    EQU_GAL(ra,dec,l,b);{equatorial to galactic coordinates}
    result:=floattostrF(l*180/pi, FFfixed, 0, 3)+sep+floattostrF(b*180/pi, FFfixed, 0, 3)+' ° gal';
  end
  else
  if coord_frame=3 then
  begin
    if calculate_az_alt_basic(ra,dec,{out} az,alt)=false then exit;{calculate azimuth, altitude including refraction}
    result:=floattostrF(az*180/pi, FFfixed, 0, 1)+'°'+sep+floattostrF(alt*180/pi, FFfixed, 0, 1)+'°';
  end
  else
  result:='Error';

end;


function seperation : string;
begin
  if DefaultFormatSettings.DecimalSeparator<>'.' then
    result:='  '
  else
    result:=', ';
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
        image1.Canvas.textout(round(3+x7),round(-font_height+ y7),'_'+position_to_string(seperation,object_raM,object_decM))
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
        image1.Canvas.textout(x8,y8,'_'+position_to_string(seperation,object_raM,object_decM))
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

    image_move_to_center:=false;{mark as job done}

    {update shapes to new position}
//    show_marker_shape(mainwindow.shape_marker3,9 {no change in shape and hint},30,30,10{minimum},shape_marker3_fitsX, shape_marker3_fitsY);
//    show_marker_shape(mainwindow.shape_marker4,9 {no change in shape and hint},60,60,10{minimum},shape_marker4_fitsX, shape_marker4_fitsY);

//    if mainwindow.shape_var1.visible then {For manual alignment. Do this only when visible}
  //     show_marker_shape(mainwindow.shape_var1,9 {no change in shape and hint},20,20,10,shape_var1_fitsX, shape_var1_fitsY);
//     if mainwindow.shape_check1.visible then {For manual alignment. Do this only when visible}
  //     show_marker_shape(mainwindow.shape_check1,9 {no change in shape and hint},20,20,10,shape_check1_fitsX, shape_check1_fitsY);
 //    if mainwindow.shape_star3.visible then {For manual alignment. Do this only when visible}
  //     show_marker_shape(mainwindow.shape_star3,9 {no change in shape and hint},20,20,10,shape_star3_fitsX, shape_star3_fitsY);

//    if mainwindow.shape_var2.visible then //update the shape position based on ra,dec values
  //  begin
 //     place_marker_radec(mainwindow.shape_var2,shape_var2_ra,shape_var2_dec);//place ra,dec marker in image
   //   place_marker_radec(mainwindow.shape_check2,shape_check2_ra,shape_check2_dec);//place ra,dec marker in image
//    end;


  end;
end;


procedure Tmainwindow.sqm1Click(Sender: TObject);
begin
  if head.naxis=0 then exit; {file loaded?}

  form_sqm1:=TForm_sqm1.Create(self); {in project option not loaded automatic}
  form_sqm1.ShowModal;

  {released in the close action}
 // form_sqm1.release;
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

  h:=panel1.height;
  w:=round(h*head.width/head.height);

  mainwindow.image1.height:=h;
  mainwindow.image1.width:=w;

  mainwindow.image1.top:=0;

  mw:=mainwindow.width;
  mainwindow.image1.left:=(mw-w) div 2;

  {update shape positions using the fitxY, fitsY position. Ra,dec position are not required}
  show_marker_shape(mainwindow.shape_marker1,9 {no change in shape and hint},20,20,10{minimum},shape_marker1_fitsX, shape_marker1_fitsY);
  show_marker_shape(mainwindow.shape_marker2,9 {no change in shape and hint},20,20,10{minimum},shape_marker2_fitsX, shape_marker2_fitsY);
  show_marker_shape(mainwindow.shape_marker3,9 {no change in shape and hint},30,30,10{minimum},shape_marker3_fitsX, shape_marker3_fitsY);
  show_marker_shape(mainwindow.shape_marker4,9 {no change in shape and hint},60,60,10{minimum},shape_marker4_fitsX, shape_marker4_fitsY);

  if mainwindow.shape_var1.visible then {For manual alignment. Do this only when visible}
    show_marker_shape(mainwindow.shape_var1,9 {no change in shape and hint},20,20,10,shape_var1_fitsX, shape_var1_fitsY);
  if mainwindow.shape_check1.visible then {For manual alignment. Do this only when visible}
    show_marker_shape(mainwindow.shape_check1,9 {no change in shape and hint},20,20,10,shape_check1_fitsX, shape_check1_fitsY);
  if mainwindow.shape_star3.visible then {For manual alignment. Do this only when visible}
    show_marker_shape(mainwindow.shape_star3,9 {no change in shape and hint},20,20,10,shape_star3_fitsX, shape_star3_fitsY);

  if mainwindow.shape_var2.visible then //update the shape position based on ra,dec values
  begin
    show_marker_shape(mainwindow.shape_var2,9 {no change in shape and hint},50,50,10,shape_var2_fitsX, shape_var2_fitsY);
    show_marker_shape(mainwindow.shape_check2,9 {no change in shape and hint},50,50,10,shape_check2_fitsX, shape_check2_fitsY);
  end;


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
  plot_deepsky(false,8);{annotate}
  JPG := TJPEGImage.Create;
  try
    JPG.Assign(mainwindow.image1.Picture.Graphic);    //Convert data into jpg
    JPG.CompressionQuality :=90;
    JPG.SaveToFile(ChangeFileExt(filename,'_annotated.jpg'));
  finally
  JPG.Free;
  end;
end;


procedure write_ini(filen:string; solution:boolean);{write solution to ini file}
var
   f: text;
begin
  assignfile(f,ChangeFileExt(filen,'.ini'));
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
  writeln(f,'DIMENSIONS='+inttostr(head.width)+' x '+inttostr(head.height));//write image dimensions

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
        file_loaded:=load_image(filename2,img_loaded,head,mainwindow.memo1.lines,false,false {plot});{load file first to give commandline parameters later priority}

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
        if ((file_loaded) and (solve_image(img_loaded,head,mainwindow.memo1.lines,true {get hist},false {check filter}) )) then {find plate solution, filename2 extension will change to .fit}
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
        write_ini(filename2,solved);{write solution to ini file}
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

   update_integer(mainwindow.memo1.lines,'NAXIS   =',' / Minimal header                                 ' ,0);{2 for mono, 3 for colour}
   try
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


   finally
     TheFile4.free;
   end;
  except
  end;
end;

//procedure write_astronomy_axy(stars: star_list;snr_list        : array of double );
//var
//  TheFile4 : tfilestream;
//  I,j        : integer;
//  line0,aantallen       : ansistring;
//  aline,empthy_line    : array[0..80] of ansichar;{79 required but a little more to have always room}
//  data: longword;
//begin

//  remove_key(mainwindow.memo1.lines,'NAXIS1  =',true{one});     {this will damge the header}
//  remove_key(mainwindow.memo1.lines,'NAXIS2  =',true{one});
//  update_integer(mainwindow.memo1.lines,'NAXIS   =',' / Minimal header                                 ' ,0);{2 for mono, 3 for colour}
//  update_integer(mainwindow.memo1.lines,'BITPIX  =',' /                                                ' ,8    );

//  add_text(mainwindow.memo1.lines,'EXTEND  =','                   T / There may be FITS extension                    ');
//  add_text(mainwindow.memo1.lines,'AN_FILE =',#39+'XYLS    '+#39+' / Astrometry.net file type                                 ');

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

procedure FixHiddenFormProblem(Screen: TScreen; theform: TForm ); //for users who change from two to one monitor
var
  i,left,right,top,bottom,halfwidth,halfheight : integer;
begin
  left:=0;
  right:=0;
  top:=0;
  bottom:=0;

  for i := 0 To screen.MonitorCount - 1 do
  begin
    left:=math.min(left,screen.Monitors[i].BoundsRect.left);
    right:=math.max(right, screen.Monitors[i].BoundsRect.right);
    top:=math.min(top,screen.Monitors[i].BoundsRect.top);
    bottom:=math.max(bottom,screen.Monitors[i].BoundsRect.bottom);
  end;
  halfwidth:=theform.width div 2;
  halfheight:=theform.height div 2;
  theform.Left:=max(theform.left,left-halfwidth);//prevent too left
  theform.Left:=min(theform.left,right-halfwidth);//prevent too right
  theform.top:=max(theform.top,top);//prevent too high
  theform.top:=min(theform.top,bottom-halfheight);//prevent too low
end;


procedure Tmainwindow.FormShow(Sender: TObject);
var
  s      : string;
  histogram_done,file_loaded,debug,filespecified,analysespecified,extractspecified,extractspecified2,focusrequest,checkfilter, wresult : boolean;
  snr_min                     : double;
  binning,focus_count,report  : integer;
  bck                         : Tbackground;
  filename_output             : string;
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
        'Solver command-line usage:'+#10+
        '-f  filename'+#10+
        '-r  radius_area_to_search[degrees]'+#10+      {changed}
        '-fov height_field[degrees]'+#10+
        '-ra  center_right_ascension[hours]'+#10+
        '-spd center_south_pole_distance[degrees]'+#10+
        '-s  max_number_of_stars {typical 500}'+#10+
        '-t  tolerance'+#10+
        '-m  minimum_star_size["]'+#10+
        '-z  downsample_factor[0,1,2,3,4] {Downsample prior to solving. 0 is auto}'+#10+
        #10+
        '-check  {Apply check pattern filter prior to solving. Use for raw OSC images only when binning is 1x1}' +#10+
        '-d  path {Specify a path to the star database}'+#10+
        '-D  abbreviation {Specify a star database [d80,d50,..]}'+#10+
        '-o  file {Name the output files with this base path & file name}'+#10+
        '-sip     {Add SIP (Simple Image Polynomial) coefficients}'+#10+
        '-speed mode[auto/slow] {Slow is forcing reading a larger database area for more overlap to improve initial detection}'+#10+
        '-wcs  {Write a .wcs file  in similar format as Astrometry.net. Else text style.}' +#10+
        '-log   {Write the solver log to file}'+#10+
        '-update  {update the FITS/TIFF header with the found solution.  Jpeg, png will be written as fits}' +#10+
        #10+
        'Analyse options:' +#10+
        '-analyse snr_min {Analyse only and report median HFD and number of stars used}'+#10+
        '-extract snr_min {As -analyse but additionally export info of all detectable stars to a .csv file}'+#10+
        '-extract2 snr_min {Solve and export info of all detectable stars to a .csv file including ra, dec.}'+#10+
        #10+
        'Extra options:' +#10+
        '-annotate  {Produce deepsky annotated jpg file}' +#10+
        '-debug  {Show GUI and stop prior to solving}' +#10+
        '-tofits  binning[1,2,3,4]  {Make new fits file from PNG/JPG file input}'+#10+
        '-sqm pedestal  {add measured sqm, centalt, airmass values to the solution}'+#10+
        '-focus1 file1.fit -focus2 file2.fit ....  {Find best focus using files and hyperbola curve fitting. Errorlevel is focuspos*1E4 + rem.error*1E3}'+#10+
        '-stack  path {startup with live stack tab and path selected}'+#10+
        #10+
        'Preference will be given to the command-line values. CSV files are written with a dot as decimal seperator.'+#10+
        'Solver result will be written to filename.ini and filename.wcs.'+#10+
        'Star database expected at: '+database_path), pchar('ASTAP astrometric solver usage:'),MB_OK);

        esc_pressed:=true;{kill any running activity. This for APT}
        halt(0); {don't save only do mainwindow.destroy. Note  mainwindow.close causes a window flash briefly, so don't use}
      end;

      //log_to_file('c:\temp\text.txt',cmdline);

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
          if debug=false then
            file_loaded:=load_image(filename2,img_loaded,head,mainwindow.memo1.lines,false,false {plot}) {load file first to give commandline parameters later priority}
          else
            file_loaded:=load_image(filename2,img_loaded,head,mainwindow.memo1.lines,true,true {plot});{load and show image}
          if file_loaded=false then errorlevel:=16;{error file loading}
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
        if hasoption('sip') then
            stackmenu1.add_sip1.checked:='n'<>GetOptionValue('sip');
        if hasoption('speed') then stackmenu1.force_oversize1.checked:=('slow'=GetOptionValue('speed'));
        if hasoption('check') then checkfilter:=true else checkfilter:=false;

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
          extractspecified2:=hasoption('extract2');
          if extractspecified2 then stackmenu1.add_sip1.checked:=true;//force sip for high accuracy
          analysespecified:=hasoption('analyse');

          if ((file_loaded) and ((analysespecified) or (extractspecified)) ) then {analyse fits and report HFD value in errorlevel }
          begin
            if analysespecified then
            begin
               snr_min:=strtofloat2(getoptionvalue('analyse'));
               report:=0; {report nr stars and hfd only}
            end;
            if extractspecified then
            begin
              snr_min:=strtofloat2(getoptionvalue('extract'));
              report:=2; {report nr stars and hfd and export csv file}
            end;
            if snr_min=0 then snr_min:=30;
            analyse_image(img_loaded,head,snr_min,report, hfd_counter,bck,hfd_median); {find background, number of stars, median HFD}
            if isConsole then {stdout available, compile targe option -wh used}
            begin
              writeln('HFD_MEDIAN='+floattostrF(hfd_median,ffFixed,0,1));
              writeln('STARS='+inttostr(hfd_counter));
            end;
            {$IFDEF msWindows}
            halt(round(hfd_median*100)*1000000+hfd_counter);{report in errorlevel the hfd and the number of stars used}
            {$ELSE}
            halt(errorlevel);{report hfd in errorlevel. In linux only range 0..255 possible}
            {$ENDIF}
          end;{analyse fits and report HFD value}

          if hasoption('d') then
             database_path:=GetOptionValue('d')+DirectorySeparator; {specify a different database path}
          if hasoption('D') then
             stackmenu1.star_database1.text:=GetOptionValue('D'); {specify a different database}

          if hasoption('o') then
            filename_output:=GetOptionValue('o') {for the .ini and .wcs files}
          else
            filename_output:=filename2; //use same filename for .ini and .wcs files


          if ((file_loaded) and (solve_image(img_loaded,head,mainwindow.memo1.lines,true {get hist},checkfilter) )) then {find plate solution, filename2 extension will change to .fit}
          begin
            if hasoption('sqm') then {sky quality}
            begin
              pedestal:=round(strtofloat2(GetOptionValue('sqm')));
              if calculate_sqm(false {get backgr},false{get histogr},{var} pedestal) then {sqm found}
              begin
                if centalt=''  then //no old altitude
                begin
                  centalt:=floattostr2(altitudefloat);
                  update_text(mainwindow.memo1.lines,'CENTALT =',#39+centalt+#39+'              / [deg] Nominal altitude of center of image    ');
                  update_text(mainwindow.memo1.lines,'OBJCTALT=',#39+centalt+#39+'              / [deg] Nominal altitude of center of image    ');
                end;
                update_text(mainwindow.memo1.lines,'SQM     = ',floattostr2(sqmfloat)+'               / Sky background [magn/arcsec^2]');//two decimals only for nice reporting
                update_text(mainwindow.memo1.lines,'COMMENT SQM',', used '+inttostr(pedestal)+' as pedestal value');
              end
              else
              update_text(mainwindow.memo1.lines,'SQM     =',char(39)+'Error calculating SQM value! Check in the SQM menu (ctrl+Q) first.'+char(39));
              if airmass=0 then
              begin
                airmass:=AirMass_calc(altitudefloat);
                update_generic(mainwindow.memo1.lines,'AIRMASS ',floattostr4(airmass),'Relative optical path.                        ');{update header using text only}
              end;
            end;

            write_ini(filename_output,true);{write solution to ini file}

            add_long_comment(mainwindow.memo1.lines,'cmdline:'+cmdline);{log command line in wcs file}

            if hasoption('update') then
            begin
              if fits_file_name(filename2) then wresult:=savefits_update_header(mainwindow.memo1.lines,filename2) {update the fits file header}
              else
              if tiff_file_name(filename2) then wresult:=save_tiff16_secure(img_loaded,mainwindow.memo1.lines,filename2){guarantee no file is lost}
              else
              wresult:=save_fits(img_loaded,mainwindow.memo1.lines,ChangeFileExt(filename2,'.fits'),16, true {override});{save original png,tiff jpg to 16 fits file}

              if wresult=false then //write error
              begin
                 memo2_message('█ █ █ Error updating input file !! █ █ █');//qill be reported if -log is specified in command line
                 errorlevel:=34;{Error updating input file}
              end;
            end;

            remove_key(mainwindow.memo1.lines,'NAXIS1  =',true{one});
            remove_key(mainwindow.memo1.lines,'NAXIS2  =',true{one});
            update_integer(mainwindow.memo1.lines,'NAXIS   =',' / Minimal header                                 ' ,0);{2 for mono, 3 for colour}
            if hasoption('wcs') then
              write_astronomy_wcs(ChangeFileExt(filename_output,'.wcs'))  {write WCS astronomy.net style}
            else
              try mainwindow.Memo1.Lines.SavetoFile(ChangeFileExt(filename_output,'.wcs'));{save header as wcs file} except {sometimes error using APT, locked?} end;

            histogram_done:=false;
            if hasoption('annotate') then
            begin
              use_histogram(img_loaded,false {update, already done for solving}); {plot histogram, set sliders}
              histogram_done:=true;
              plot_fits(mainwindow.image1,true {center_image},true);{center and stretch with current settings}
              save_annotated_jpg(filename_output);{save viewer as annotated jpg}
            end;
            if hasoption('tofits') then {still to be tested}
            begin
              if fits_file_name(filename2)=false {no fits file?} then
              begin
                binning:=round(strtofloat2(GetOptionValue('tofits')));
                if binning>1 then bin_X2X3X4(img_loaded,head,mainwindow.memo1.lines,binning);{bin img_loaded 2x or 3x or 4x}
                if histogram_done=false then use_histogram(img_loaded,false {update, already done for solving}); {plot histogram, set sliders}
                save_fits(img_loaded,mainwindow.memo1.lines,changeFileExt(filename_output,'.fit'),8,true {overwrite});
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
            //if hasoption('o') then filename2:=GetOptionValue('o'); {change file name for .ini file}
            write_ini(filename_output,false);{write solution to ini file}
            if errorlevel=0 then errorlevel:=1;{no solution}
          end;


          if ((file_loaded) and (extractspecified2)) then
          begin
            snr_min:=strtofloat2(getoptionvalue('extract2'));
            if snr_min=0 then snr_min:=30;
            analyse_image(img_loaded,head,snr_min,2{export CSV only}, hfd_counter,bck,hfd_median); {find background, number of stars, median HFD}
          end;


          esc_pressed:=true;{kill any running activity. This for APT}
          if commandline_log then stackmenu1.Memo2.Lines.SavetoFile(ChangeFileExt(filename_output,'.log'));{save Memo2 log to log file}

          halt(errorlevel); {don't save only, do mainwindow.destroy. Note  mainwindow.close causes a window flash briefly, so don't use}

          //  Exit status:
          //  0 no errors.
          //  1 no solution.
          //  2 not enough stars detected.

          // 16 error reading image file.

          // 32 no star database found.
          // 33 error reading star database.
          // 34 error updating input file

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

          do_stretching; ;{create gamma curve}
          exit;
        end;
      end;{-f option}
    end;{with application}


    {filename as parameter 1}
    do_stretching; ;{create gamma curve}

    if application.hasoption('stack') then //for Ekos
    begin
      stackmenu1.live_stacking_path1.caption:=application.GetOptionValue('stack');{live stacking path}
      stackmenu1.pagecontrol1.tabindex:=11; {live stack}
      mainwindow.Stackimages1Click(nil);// make stack menu visible
    end
    else
    load_image(filename2,img_loaded,head,mainwindow.memo1.lines,true,true {plot});{show image of parameter1}
  end {paramcount>0}
  else
  do_stretching; {create gamma curve for image if loaded later and set gamma_on}


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

  pairsplitter1.position:=image_north_arrow1.top+image_north_arrow1.height+8;//set correct for 4k screens with hiDPI settings. Works only in show. Not in create
                     //The thing is that the LCL scales the form on the Show method, because that any scaling produced before showing the form is not applied.

  FixHiddenFormProblem( Screen,mainwindow);//when users change from two to one monitor
  FixHiddenFormProblem( Screen,stackmenu1);

end;


procedure Tmainwindow.batch_add_solution1Click(Sender: TObject);
var
  i,nrskipped, nrsolved,nrfailed,file_age,pedestal2,oldnrbits                         : integer;
  add_lim_magn,solution_overwrite,solved,maintain_date,success,image_changed : boolean;
  failed,skipped,mess                           : string;
  startTick  : qword;{for timing/speed purposes}
  headx : theader;
  img_temp: image_array;

begin
  OpenDialog1.Title :='Select multiple files to add astrometric solution';
  OpenDialog1.Options :=[ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=dialog_filter_fits_tif;
  esc_pressed:=false;
  add_lim_magn:=add_limiting_magn_check1.Checked;
  solution_overwrite:=batch_overwrite1.checked;
  maintain_date:=maintain_date1.checked;

  if OpenDialog1.Execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    nrsolved:=0;
    nrskipped:=0;
    nrfailed:=0;
    failed:='Failed files:';
    skipped:='Skipped files:';
    startTick := GetTickCount64;
    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        filename2:=Strings[I];
        progress_indicator(100*i/(count),' Solving');{show progress}
        solved:=false;

        if fits_tiff_file_name(filename2)=false then
        begin
           memo2_message('█ █ █ █ █ █ Skipping non FITS/TIFF file '+filename2+' █ █ █ █ █ █ ');
           continue; //skip wrong file types in case somebody typed *.*
        end;

        Application.ProcessMessages;
        if esc_pressed then  break;
        {load image and solve image}
        if load_fits(filename2,true {light},true,true {update memo},0,memox,headx,img_temp) then {load image success}
        begin
          image_changed:=false;
          if ((headx.cd1_1<>0) and (solution_overwrite=false)) then
          begin
            nrskipped:=nrskipped+1; {plate solved}
            memo2_message('Skipped: '+filename2+ '  Already a solution in the header. Select option overwrite to renew.');
            skipped:=skipped+#13+#10+extractfilename(filename2);
          end
          else
          begin
            if cal_batch1.checked then
            begin
              {preserve header and some important variable}
              memo2_message('Calibrating image prior to solving.');
              analyse_listview(stackmenu1.listview2,false {light},false {full fits},false{refresh});{analyse dark tab, by loading=false the loaded img will not be effected. Calstat will not be effected}
              analyse_listview(stackmenu1.listview3,false {light},false {full fits},false{refresh});{analyse flat tab, by loading=false the loaded img will not be effected}

              if apply_dark_and_flat(img_temp,headx){apply dark, flat if required, renew if different hd.exposure or ccd temp. This will clear the header in load_fits} then
              begin //dark or flat or both applied
                update_text(memox,'CALSTAT =',#39+headx.calstat+#39); {calibration status}
                image_changed:=true;
                //get_hist:=true; {update required}
              end;
            end;


            memo2_message('Solving '+inttostr(i+1)+'-'+inttostr(Count)+': '+filename2);
            oldnrbits:=nrbits;
            solved:=solve_image(img_temp,headx,memox,true {get hist}, false {check filter});
            if solved then nrsolved:=nrsolved+1 {solve}
            else
            begin
              memo2_message('No solution: '+filename2);
              nrfailed:=nrfailed+1;
              failed:=failed+#13+#10+extractfilename(filename2);
            end;
          end;

          if ((headx.cd1_1<>0) and ((solved) or (add_lim_magn)) )  then {time to save}
          begin
            if add_lim_magn then
            begin
              calibrate_photometry(img_temp,memoX,headX);
              update_float(memox,'LIM_MAGN=',' / estimated limiting magnitude for point sources',false ,magn_limit);

              mess:='';

              if ((pedestal<>0) or (pos('D',headx.calstat)>0)) then
              begin
                //jd_start:=0; { if altitude missing then force an date to jd conversion'}
                pedestal2:=pedestal; {protect pedestal setting}
                if calculate_sqm(true {get backgr},true {get histogr},{var}pedestal2) then
                begin
                  update_text(memox,'SQM     = ',floattostr2(sqmfloat)+'               / Sky background [magn/arcsec^2]');//two decimals only for nice reporting
                  update_text(memox,'COMMENT SQM',', used '+inttostr(pedestal2)+' as pedestal value');
                  mess:=', SQM';
                  if centalt=''  then //no old altitude
                  begin
                    centalt:=floattostr2(altitudefloat);
                    update_text(memox,'CENTALT =',#39+centalt+#39+'              / [deg] Nominal altitude of center of image    ');
                    update_text(memox,'OBJCTALT=',#39+centalt+#39+'              / [deg] Nominal altitude of center of image    ');
                    mess:=mess+', CENT-ALT';
                  end;
                end
                else
                begin
                  update_text(memox,'SQM     =',char(39)+'Error calculating SQM value! Check in the SQM menu (ctrl+Q) first.'+char(39));
                  memo2_message('Error calculating SQM value! Check in the SQM menu (ctrl+Q) first.');
                end;
              end
              else
              begin
                update_text(memox,'SQM     =',char(39)+'Error! Specify first fixed pedestal value in the SQM menu (ctrl+Q).'+char(39));
                memo2_message('Can not measure SQM. Specifiy first a fixed pedestal value in the SQM menu. De pedestal value is the median dark or bias value');
              end;
              if airmass=0 then
              begin
                airmass:=AirMass_calc(altitudefloat);
                update_generic(memox,'AIRMASS ',floattostr4(airmass),'Relative optical path.                        ');{update header using text only}
                mess:=mess+', AIRMASS';
              end;
              memo2_message('Added keyword(s) LIM_MAGN'+mess);
            end;

            if maintain_date then file_age:=Fileage(filename2);
            if fits_file_name(filename2) then
            begin
              if image_changed=false then
                success:=savefits_update_header(memox,filename2)
              else
                success:=save_fits(img_temp,memox,filename2,oldnrbits,true);//image was updated by calibration.
            end
            else
              success:=save_tiff16_secure(img_temp,memox,filename2);{guarantee no file is lost}
            if success=false then begin ShowMessage('Write error !!'+#10+#10 + filename2);Screen.Cursor:=crDefault; exit;end;

            if ((maintain_date) and (file_age>-1)) then FileSetDate(filename2,file_age);
          end;
        end;
      end;{for i:=}

      finally
      memo2_message('Processed in '+ floattostr(round((GetTickCount64 - startTick)/100)/10)+' sec.');

      Screen.Cursor:=crDefault;  { Always restore to normal }
    end;
    progress_indicator(-100,'');{progresss done}
    nrfailed:=OpenDialog1.Files.count-nrsolved-nrskipped;
    if nrskipped<>0 then memo2_message(skipped);
    if nrfailed<>0 then memo2_message(failed);
    if solution_overwrite then
       memo2_message(inttostr(nrsolved)+' images solved, '+inttostr(nrfailed)+' no solution. Duration '+floattostr(round((GetTickCount64 - startTick)/100)/10)+ ' sec. For re-solve set option "overwrite solutions".')
    else
      memo2_message(inttostr(nrsolved)+' images solved, '+inttostr(nrskipped)+' existing solutions, '+inttostr(nrfailed)+' no solution. Duration '+floattostr(round((GetTickCount64 - startTick)/100)/10)+ ' sec.');
  end;
end;


procedure Tmainwindow.stretch1CloseUp(Sender: TObject);
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
  update_integer(mainwindow.memo1.lines,'NAXIS   =',' / Number of dimensions                           ' ,head.naxis);{number of dimensions, 2 for mono, 3 for colour}
  if head.naxis3<>1 then {color image}
    update_integer(mainwindow.memo1.lines,'NAXIS3  =',' / length of z axis (mostly colors)               ' ,head.naxis3)
  else
    remove_key(mainwindow.memo1.lines,'NAXIS3  ',false{all});{remove key word in header. Some program don't like naxis3=1}
end;

procedure Tmainwindow.demosaic_bayermatrix1Click(Sender: TObject);
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
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img;

  demosaic_advanced(img_loaded);

  remove_key(mainwindow.memo1.lines,'BAYERPAT',false{all});{remove key word in header}
  remove_key(mainwindow.memo1.lines,'XBAYROFF',false{all});{remove key word in header}
  remove_key(mainwindow.memo1.lines,'YBAYROFF',false{all});{remove key word in header}

  plot_fits(mainwindow.image1,false,true);
  stackmenu1.test_pattern1.Enabled:=false;{do no longer allow debayer}

  update_header_for_colour; {update naxis and naxis3 keywords}

  Screen.Cursor:=crDefault;
 {$IFDEF fpc}
  progress_indicator(-100,'');{back to normal}
 {$else} {delphi}
  mainwindow.taskbar1.progressstate:=TTaskBarProgressState.None;
  {$endif}
end;


procedure Tmainwindow.star_annotation1Click(Sender: TObject);
begin
//  annotation_magn :=inputbox('Annotate stars','Annotate up to magnitude:' ,annotation_magn);
//  annotation_magn:=StringReplace(annotation_magn,',','.',[]); {replaces komma by dot}

  calibrate_photometry(img_loaded,mainwindow.Memo1.lines,head);
  plot_and_measure_stars(img_loaded,mainwindow.Memo1.lines,head,false {calibration},true {plot stars},false {measure lim magn});{plot stars}
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


procedure Tmainwindow.CropFITSimage1Click(Sender: TObject);
var fitsX,fitsY,col,dum, formalism      : integer;
    fxc,fyc, ra_c,dec_c, ra_n,dec_n,ra_m, dec_m, delta_ra   : double;
    img_temp : image_array;
begin
  if ((head.naxis<>0) and (abs(stopX-startX)>3)and (abs(stopY-starty)>3)) then
  begin
   Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

   backup_img;

   formalism:=mainwindow.Polynomial1.itemindex;

   if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
   if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;


   inc(startX);//take only inside of rectangle
   inc(startY);
   dec(stopX);
   dec(stopY);

   startx:=max(startX,0);  // prevent runtime errors. Box can be outside image
   startY:=max(startY,0);
   stopX:=min(stopX,head.width-1);
   stopY:=min(stopY,head.height-1);

   head.width:=stopX-startx+1;
   head.height:=stopY-starty+1;
   setlength(img_temp,head.naxis3,head.height,head.width);{set length of image array}


   for col:=0 to head.naxis3-1 do
     for fitsY:=startY to stopY do
       for fitsX:=startX to stopX do {crop image EXCLUDING rectangle.}
            img_temp[col,fitsY-startY,fitsX-startX]:=img_loaded[col,fitsY,fitsX];

   img_loaded:=nil;{release memory}
   img_loaded:=img_temp;

   update_integer(mainwindow.memo1.lines,'NAXIS1  =',' / length of x axis                               ' ,head.width);
   update_integer(mainwindow.memo1.lines,'NAXIS2  =',' / length of y axis                               ' ,head.height);

   {new reference pixel}

   if head.cd1_1<>0 then
   begin
     {do the rigid method.}
     fxc:=1+(startX+stopX)/2;//position of new center
     fyc:=1+(startY+stopY)/2;
     pixel_to_celestial(head,fxc,fyc, formalism, ra_c,dec_c {new center RA, DEC position});   //make 1 step in direction head.crpix1. Do first the two steps because head.cd1_1, head.cd2_1..... are required so they have to be updated after the two steps.
     pixel_to_celestial(head,1+fxc,fyc, formalism, ra_n,dec_n {RA, DEC position, one pixel moved in head.crpix1});  //make 1 step in direction head.crpix2
     pixel_to_celestial(head,fxc,fyc+1 , formalism, ra_m,dec_m {RA, DEC position, one pixel moved in head.crpix2});

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

      new_to_old_WCS(head);

      update_float(mainwindow.memo1.lines,'CRVAL1  =',' / RA of reference pixel (deg)                    ',false ,head.ra0*180/pi);
      update_float(mainwindow.memo1.lines,'CRVAL2  =',' / DEC of reference pixel (deg)                   ',false ,head.dec0*180/pi);

      update_float(mainwindow.memo1.lines,'CRPIX1  =',' / X of reference pixel                           ',false ,head.crpix1);{adapt reference pixel of plate solution. Is no longer in the middle}
      update_float(mainwindow.memo1.lines,'CRPIX2  =',' / Y of reference pixel                           ',false ,head.crpix2);

      update_float(mainwindow.memo1.lines,'CROTA1  =',' / Image twist X axis (deg)                       ',false ,head.crota1);
      update_float(mainwindow.memo1.lines,'CROTA2  =',' / Image twist Y axis (deg) E of N if not flipped.',false ,head.crota2);

      update_float(mainwindow.memo1.lines,'CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_1);
      update_float(mainwindow.memo1.lines,'CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_2);
      update_float(mainwindow.memo1.lines,'CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_1);
      update_float(mainwindow.memo1.lines,'CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_2);

      //   Alternative method keeping the old center poistion. Images center outside the image causes problems for image selection in planetarium program
      //   if head.crpix1<>0 then begin head.crpix1:=head.crpix1-startX; update_float(mainwindow.memo1.lines,'CRPIX1  =',' / X of reference pixel                           ' ,head.crpix1);end;{adapt reference pixel of plate solution. Is no longer in the middle}
      //   if head.crpix2<>0 then begin head.crpix2:=head.crpix2-startY; update_float(mainwindow.memo1.lines,'CRPIX2  =',' / Y of reference pixel                           ' ,head.crpix2);end;
   end;

   update_text(mainwindow.memo1.lines,'COMMENT C','  Cropped image');


   plot_fits(mainwindow.image1,true,true);
   image_move_to_center:=true;

   Screen.Cursor:=crDefault;
  end;
end;


procedure ra_text_to_radians(inp :string; out ra : double; out errorRA :boolean); {convert ra in text to double in radians}
var
  rah,ram,ras,plusmin :double;
  position1,position2,position3,error1,error2,error3, i :integer;
  degrees : boolean;
  data    : string;
begin
  val(inp,ra,error1); //try easy conversion
  if error1<>0 then
  begin //do compilcated conversion
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

  end
  else
  begin
    errorRA:=false;
    ra:=ra*pi/12; //convert to radians
  end;
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
  val(inp,dec,error1);//try easy decode including scientific 6.704750E-01
  if error1<>0 then
  begin //try dificult decode such as '+53 20 52.510'
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
  end//end of difficult decode
  else
  begin
    errorDec:=false;
    dec:=dec*pi/180;//convert to radians
  end;
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


procedure find_star_center(img: image_array;box, x1,y1: integer; out xc,yc:double);{}
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
      result:=         (img[0,y_trunc  ,x_trunc  ]) * (1-x_frac)*(1-y_frac);{pixel left top, 1}
      result:=result + (img[0,y_trunc  ,x_trunc+1]) * (  x_frac)*(1-y_frac);{pixel right top, 2}
      result:=result + (img[0,y_trunc+1,x_trunc  ]) * (1-x_frac)*(  y_frac);{pixel left bottom, 3}
      result:=result + (img[0,y_trunc+1,x_trunc+1]) * (  x_frac)*(  y_frac);{pixel right bottom, 4}
    except
    end;
  end;

begin
  w:=Length(img[0,0]); {width}
  h:=Length(img[0]); {height}

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
        val:=img[0,j,i];
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
      val:=value_subpixel(xc+i,yc+j) - value/2;{use only the brightest parts above half max}
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


procedure Tmainwindow.enterposition1Click(Sender: TObject);
var
  ra2,dec2,pixeldistance,distance,angle,angle2,angle3,xc,yc   : double;
  kommapos         : integer;
  error2,flipped   : boolean;
begin
  if sender=enterposition1 then
  begin
    find_star_center(img_loaded,10,startX,startY,xc,yc);//find center of gravity
    shape_marker1_fitsX:=xc+1;//array to fits coordinates
    shape_marker1_fitsY:=yc+1;
    show_marker_shape(mainwindow.shape_marker1,0 {rectangle},20,20,0 {minimum size},shape_marker1_fitsX, shape_marker1_fitsY);

    mouse_positionRADEC1:=InputBox('Enter α, δ of mouse position separated by a comma:','Format 24 00 00.0, 90 00 00.0   or   24 00, 90 00',mouse_positionRADEC1);
    if mouse_positionRADEC1=''  then exit; {cancel used}
    shape_marker1.hint:='Reference 1: '+mouse_positionRADEC1
  end
  else
  if sender=enterposition2 then
  begin
    find_star_center(img_loaded,10,startX,startY,xc,yc);//find center of gravity
    shape_marker2_fitsX:=xc+1;//array to fits coordinates
    shape_marker2_fitsY:=yc+1;
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
    if flipped then
      head.cdelt1:=head.cdelt2
    else
      head.cdelt1:=-head.cdelt2;

    {find head.crota2}
    angle2:= position_angle(ra2,dec2,head.ra0,head.dec0);//Position angle between a line from ra0,dec0 to ra1,dec1 and a line from ra0, dec0 to the celestial north . Rigorous method
    angle3:= arctan2(shape_marker2_fitsX- shape_marker1_fitsX,shape_marker2_fitsY- shape_marker1_fitsY); {angle between top and line between two reference pixels}

    if flipped then
      angle:=(-angle2+angle3){swapped n-s or e-w image}
    else
      angle:=(-angle2-angle3);

    angle:=fnmodulo(angle,2*pi);

    if angle< -pi then angle:=angle+2*pi;
    if angle>=+pi then angle:=angle-2*pi;

    head.crota2:=angle*180/pi;
    head.crota1:=head.crota2;


    old_to_new_WCS(head);{new WCS missing, convert old WCS to new}

    mainwindow.Memo1.Lines.BeginUpdate;

    update_text(mainwindow.memo1.lines,'CTYPE1  =',#39+'RA---TAN'+#39+'           / first parameter RA  ,  projection TANgential   ');
    update_text(mainwindow.memo1.lines,'CTYPE2  =',#39+'DEC--TAN'+#39+'           / second parameter DEC,  projection TANgential   ');
    update_text(mainwindow.memo1.lines,'CUNIT1  =',#39+'deg     '+#39+'           / Unit of coordinates                            ');

    update_float(mainwindow.memo1.lines,'CRPIX1  =',' / X of reference pixel                           ',false ,head.crpix1);
    update_float(mainwindow.memo1.lines,'CRPIX2  =',' / Y of reference pixel                           ',false ,head.crpix2);

    update_float(mainwindow.memo1.lines,'CRVAL1  =',' / RA of reference pixel (deg)                    ',false ,head.ra0*180/pi);
    update_float(mainwindow.memo1.lines,'CRVAL2  =',' / DEC of reference pixel (deg)                   ',false ,head.dec0*180/pi);


    update_float(mainwindow.memo1.lines,'CDELT1  =',' / X pixel size (deg)                             ',false ,head.cdelt1);
    update_float(mainwindow.memo1.lines,'CDELT2  =',' / Y pixel size (deg)                             ',false ,head.cdelt2);

    update_float(mainwindow.memo1.lines,'CROTA1  =',' / Image twist X axis (deg)                       ',false ,head.crota1);
    update_float(mainwindow.memo1.lines,'CROTA2  =',' / Image twist Y axis (deg) E of N if not flipped.',false ,head.crota2);

    update_float(mainwindow.memo1.lines,'CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_1);
    update_float(mainwindow.memo1.lines,'CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_2);
    update_float(mainwindow.memo1.lines,'CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_1);
    update_float(mainwindow.memo1.lines,'CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_2);
    update_text(mainwindow.memo1.lines,'PLTSOLVD=','                   T / ASTAP manual with two positions');

    mainwindow.Memo1.Lines.EndUpdate;

    update_menu_related_to_solver(true); {update menu section related to solver succesfull}
    plot_fits(mainwindow.image1,false,true);
  end;
end;


procedure Tmainwindow.inversimage1Click(Sender: TObject);
var
  max_range, col,fitsX,fitsY : integer;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  backup_img;

  if nrbits=8 then max_range:= 255 else max_range:=65535;

  for col:=0 to head.naxis3-1 do {do all colours}
  begin
    For fitsY:=0 to (head.height-1) do
      for fitsX:=0 to (head.width-1) do
      begin
        img_loaded[col,fitsY,fitsX]:=max_range-img_loaded[col,fitsY,fitsX]
      end;
  end;

  head.datamax_org:=max_range;
  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,false,true);

  Screen.Cursor:=crDefault;  { Always restore to normal }
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
  set_area1.checked:=(areaX1<>areaX2);
  //stackmenu1.area_set1.caption:='✓';
  stackmenu1.area_set1.caption:='['+inttostr(areax1)+','+inttostr(areay1)+'], ['+inttostr(areax2)+','+inttostr(areay2)+']';

  stackmenu1.center_position1.caption:='Center: '+inttostr((startX+stopX) div 2)+', '+inttostr((startY+stopY) div 2);
end;

procedure rotate_arbitrary(angle,flipped_view, flipped_image: double);
var centerxs,centerys  : double;
begin
  centerxs:=head.width/2;
  centerys:=head.height/2;

  raster_rotate(flipped_view*angle,centerxs,centerys ,img_loaded);

  head.width:=length(img_loaded[0,0]);{update width}  ;
  head.height:=length(img_loaded[0]);{update length};

  update_integer(mainwindow.memo1.lines,'NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer(mainwindow.memo1.lines,'NAXIS2  =',' / length of y axis                               ' ,head.height);


  if head.cd1_1<>0 then {update solution for rotation}
  begin
    if ((head.crpix1<>0.5+centerxs) or (head.crpix2<>0.5+centerys)) then {reference is not center}
    begin  {to much hassle to fix. Just remove the solution}
      remove_solution(true {keep wcs});
    end;
    head.crota2:=fnmodulo(head.crota2+angle*flipped_image*flipped_view,360);
    head.crota1:=fnmodulo(head.crota1+angle*flipped_image*flipped_view,360);
    head.crpix1:=head.width/2;
    head.crpix2:=head.height/2;
    old_to_new_WCS(head);{convert old style FITS to newd style}

    update_float(mainwindow.memo1.lines,'CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_1);
    update_float(mainwindow.memo1.lines,'CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_2);
    update_float(mainwindow.memo1.lines,'CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_1);
    update_float(mainwindow.memo1.lines,'CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_2);


    update_float(mainwindow.memo1.lines,'CRPIX1  =',' / X of reference pixel                           ',false ,head.crpix1);
    update_float(mainwindow.memo1.lines,'CRPIX2  =',' / Y of reference pixel                           ',false ,head.crpix2);

    update_float(mainwindow.memo1.lines,'CROTA1  =',' / Image twist X axis (deg)                       ',false ,head.crota1);
    update_float(mainwindow.memo1.lines,'CROTA2  =',' / Image twist Y axis (deg) E of N if not flipped.',false ,head.crota2);
  end;
  remove_key(mainwindow.memo1.lines,'ANNOTATE',true{all});{remove annotations. They would be otherwise invalid}
  add_text(mainwindow.memo1.lines,'HISTORY   ','Rotated CCW by angle '+floattostrF(angle,fffixed, 0, 2));

end;

procedure Tmainwindow.rotate_arbitrary1Click(Sender: TObject);
var
  angle,flipped_view,flipped_image  : double;
  valueI : string;

begin
  flipped_view:=+1;//not flipped

  if head.cd1_1*head.cd2_2 - head.cd1_2*head.cd2_1 >0 then // flipped?
    flipped_image:=-1  //change rotation for flipped image,  {Flipped image. Either flipped vertical or horizontal but not both. Flipped both horizontal and vertical is equal to 180 degrees rotation and is not seen as flipped}
  else
    flipped_image:=+1;//not flipped

  valueI:=InputBox('Arbitrary rotation','Enter angle CCW in degrees:              (If solved, enter N for north up)','' );
  if valueI=''  then exit;
  if ((valueI='n') or (valueI='N')) then
  begin
    angle:=-head.crota2;
    if head.cd1_1<>0 then //solved
      angle:=angle*flipped_image
    else
    begin
      application.messagebox(pchar('Abort! Can not execute without astrometric solution. Solve image first.'),'',MB_OK);
      exit;
    end;
  end
  else
  begin
    angle:=strtofloat2(valueI);
    if mainwindow.flip_horizontal1.checked then flipped_view:=-flipped_view;{change rotation if flipped}
    if mainwindow.flip_vertical1.checked then   flipped_view:=-flipped_view;{change rotation if flipped}
  end;

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  memo2_message('Start rotation. This takes some time due to subsampling 10x10.');
  backup_img;

  rotate_arbitrary(angle,flipped_view,flipped_image);

  plot_fits(mainwindow.image1,false,true);

  progress_indicator(-100,'');{back to normal}
  Screen.Cursor:=crDefault;  { Always restore to normal }

  memo2_message('Rotation done.');
end;


procedure Tmainwindow.batch_rotate_left1Click(Sender: TObject);
var
  i                        : integer;
  dobackup,success         : boolean;
  flipped_image            : double;
begin
  OpenDialog1.Title := 'Select multiple  files to rotate 90 degrees.';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := dialog_filter_fits_tif;

  esc_pressed:=false;

  if OpenDialog1.Execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    dobackup:=img_loaded<>nil;
    if dobackup then backup_img;{preserve img array and fits header of the viewer}

    with OpenDialog1.Files do
    for i := 0 to Count - 1 do
    begin
      filename2:=Strings[i];
      {load fits}
      Application.ProcessMessages;
      if ((esc_pressed) or (load_fits(filename2,true {light},true,true {update memo},0,mainwindow.memo1.lines,head,img_loaded)=false)) then begin break;end;

      if head.cd1_1*head.cd2_2 - head.cd1_2*head.cd2_1 >0 then // Flipped image. Either flipped vertical or horizontal but not both. Flipped both horizontal and vertical is equal to 180 degrees rotation and is not seen as flipped
        flipped_image:=-1  // change rotation for flipped image
      else
        flipped_image:=+1; // not flipped


      if sender=mainwindow.batch_rotate_left1 then
         rotate_arbitrary(90,1,flipped_image) else
      if sender=mainwindow.batch_rotate_right1 then
         rotate_arbitrary(-90,1,flipped_image) else
      if sender=mainwindow.batch_rotate_1801   then
         rotate_arbitrary(180,1,flipped_image);

      if fits_file_name(filename2) then
        success:=save_fits(img_loaded,mainwindow.memo1.lines,filename2,nrbits,true)
      else
        success:=save_tiff16_secure(img_loaded,mainwindow.memo1.lines,filename2);{guarantee no file is lost}
      if success=false then begin ShowMessage('Write error !!' + filename2);break; end;
    end;
    if dobackup then restore_img;{for the viewer}
    Screen.Cursor:=crDefault; exit;
  end;
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


procedure plot_simbad(info:string);
var
  name,regel,simobject,typ,mag,colour,sizestr : string;
  err,p1,p2,p3,p4,p5,p6,p7,ra1,ra2,ra3,dec1,dec2,count,minnen1,minnen2 : integer;
  m,rah,ram,ras,decd,decm,decs,sign,size : double;
  slist: TStringList;
      procedure read_position(start,stop:integer);
      begin
        ra1:=posex(' ',regel,start+1);

        ra2:=posex(' ',regel,ra1+1);
        ra3:=posex(' ',regel,ra2+1);
        dec1:=posex(' ',regel,ra3+3);//skip some more for double spaces
        dec2:=posex(' ',regel,dec1+1);
        if stop=0 then
          stop:=posex(' ',regel,dec2+2);

        rah:=strtofloat1(copy(regel,start+1,ra1-start-1));
        ram:=strtofloat1(copy(regel,ra1+1,ra2-ra1-1));
        ras:=strtofloat1(copy(regel,ra2+1,ra3-ra2-1));

        decd:=strtofloat1(trim(copy(regel,ra3+1,dec1-ra3-1)));
        decm:=strtofloat1(copy(regel,dec1+1,dec2-dec1-1));
        decs:=strtofloat1(trim(copy(regel,dec2+1,stop-dec2-1)));
        if pos('-',copy(regel,ra3+1,3))>0 then sign:=-1 else sign:=+1;
      end;
begin
  m:=0;//default unknown magnitude;
  slist := TStringList.Create;
  deepstring.clear;
  deepstring.add('');//add two lines blank comments
  deepstring.add('');

  try
    slist.Text := info;

    count:=5;{skip first part}
    while count+1<=slist.count do
    begin
      regel:=ansistring(slist[count]);
      inc(count);

      //single object is reported by Simbad
      if copy(regel,1,6)='Object' then //single object
      begin
        minnen1:=pos('---',regel);
        minnen2:=posex('---',regel,minnen1+4);
        name:=StringReplace(trim( copy(regel,8,minnen1-2-8)), ' ', '_',[rfReplaceAll]); {name}
        typ:=trim(copy(regel,minnen1+4,minnen2-(minnen1+5)));
      end
      else
      if copy(regel,1,16)='Coordinates(ICRS' then //single object
      begin
        read_position(36,0);//read ra and dec from 36
      end
      else
      if copy(regel,1,4)='Flux' then //magnitude
      begin
        colour:=copy(regel,6,1);
        if ((colour='B') or (colour='V')) then
          val((copy(regel,10,posex(' ',regel,11)-10)),m,err);{B or V magnitude}
      end
      else
      if copy(regel,1,7)='Angular' then
      begin
        val((copy(regel,15,posex(' ',regel,11)-10)),size,err);//angular size
        if size<>0 then sizestr:=','+inttostr(round(size*10)) else sizestr:='';

        if m=0 then mag:='' {unknown magnitude, e.g ngc1988}
        else
        mag:='/'+inttostr(round(m*10));{magn}

        simobject:=inttostr(round((rah+ram/60+ras/3600)*864000/24))+','+inttostr(round(sign*(abs(decd)+decm/60+decs/3600)*324000/90))+','+name+'['+typ+mag+']'+sizestr;
        deepstring.add(simobject);
        break //ready for single object
      end;



      //Simbad report a list of objects
      if ((length(regel)>=130) and (count>=10)) then
      begin
        {magnitude}
        p1:=pos('|',regel);{first column changes in width}
        p2:=posex('|',regel,p1+1);
        p3:=posex('|',regel,p2+1);
        p4:=posex('|',regel,p3+1);
        p5:=posex('|',regel,p4+1);
        p6:=posex('|',regel,p5+1);
        p7:=posex('|',regel,p6+1);
        //there are more | but are not required
        if p7>0 then //this is a real line of the object list
        begin
          read_position(p3,p4);//read ra and dec within start and stop
          val(trim(copy(regel,p6+1,p7-p6-1)),m,err);{V magnitude}
          if m=0 then val(trim(copy(regel,p5+1,p6-p5-1)),m,err);{try B magnitude}

          if m=0 then mag:='' {unknown magnitude, e.g ngc1988}
          else
          mag:='/'+inttostr(round(m*10));{magn}

          typ:=trim(copy(regel,p2+1,p3-p2-1));
          name:=StringReplace(trim(copy(regel,p1+1,p2-p1-1)), ' ', '_',[rfReplaceAll]);{name}

          simobject:=inttostr(round((rah+ram/60+ras/3600)*864000/24))+','+inttostr(round(sign*(abs(decd)+decm/60+decs/3600)*324000/90))+','+name+'['+typ+mag+']';

          //RA[0..864000], DEC[-324000..324000], name(s), length [0.1 min], width[0.1 min], orientation[degrees]
          //659250,-49674,M16/NGC6611/Eagle_Nebula,80
          deepstring.add(simobject);
        end;
      end; {correct line of object list}
    end;

  finally
    slist.Free;
  end;

  database_nr:=6;{1 is deepsky, 2 is hyperleda, 3 is variable magn 11 loaded, 4 is variable magn 13 loaded, 5 is variable magn 15 loaded, 6=simbad}
  plot_deepsky(false,8);
end;


procedure plot_vizier(info,filter:string); //plot online info Gaia from Vizier
var
  regel,simobject           : string;
  p1,p2,p3,p4,count         : integer;
  rad,decd,G,Bp,Rp,themagn  : double;
  datalines : boolean;
  slist: TStringList;

begin
//--------------- --------------- --------- ---------
//                                  G         BP        RP
//RA_ICRS (deg)   DE_ICRS (deg)   mag (mag) mag (mag)
//--------------- --------------- --------- --------- -------
//086.58690478866 -10.38175731298 20.486355 20.757553 .......
//086.57689784801 -10.37081756215 20.496525 21.346535 .......
//086.57543967588 -10.36071651144 20.726021 21.413324 .......


  slist := TStringList.Create;
  deepstring.clear;
  deepstring.add('');//add two lines as blank comments
  deepstring.add('');
  datalines:=false;

  try
    slist.Text := info;
    count:=35;{skip first part}
    while count+1<=slist.count do
    begin
      regel:=ansistring(slist[count]);
      inc(count);

      if ((datalines) and (length(regel)>10)) then //Data from Vizier
      begin
        {magnitude}
        p1:=pos(' ',regel);{first column changes in width}
        p2:=posex(' ',regel,p1+3);//there could be two spaces instead of one
        p3:=posex(' ',regel,p2+3);
        p4:=posex(' ',regel,p3+3);
        if p3>0 then //this is a real line of the object list
        begin
          rad:=strtofloat1(copy(regel,1,p1-1));
          decd:=strtofloat1(copy(regel,p1+1,p2-p1-1));
          g:=strtofloat1(copy(regel,p2+1,p3-p2-1));
          Bp:=strtofloat1(copy(regel,p3+1,p4-p3-1));
          Rp:=strtofloat1(copy(regel,p4+1,99));

          themagn:=transform_gaia(filter,g,bp,rp);//transformation of Gaia magnitudes

          if themagn<>0 then //valid value
          begin
             simobject:=inttostr(round(rad*864000/360))+','+inttostr(round(decd*324000/90))+','+inttostr(round(10*themagn));
             //RA[0..864000], DEC[-324000..324000], name(s), length [0.1 min], width[0.1 min], orientation[degrees]
             //659250,-49674,M16/NGC6611/Eagle_Nebula,80
             deepstring.add(simobject);
          end;
        end;
      end {correct line of object list}
      else
      if copy(regel,1,7)='RA_ICRS' then //data begins
      begin
        datalines:=true;
        inc(count);//skip one more line containing --------------- --------------- --------- ---------
      end;
    end;

  finally
    slist.Free;
  end;

  database_nr:=6;{1 is deepsky, 2 is hyperleda, 3 is variable magn 11 loaded, 4 is variable magn 13 loaded, 5 is variable magn 15 loaded, 6=simbad}
  plot_deepsky(false,8);
end;



procedure Tmainwindow.gaia_star_position1Click(Sender: TObject);
var
   url,ra8,dec8,sgn,window_size,dec_degrees  : string;
   ang_h,ang_w,ra1,ra2,dec1,dec2 : double;
   radius,x1,y1,formalism                : integer;
begin
  formalism:=mainwindow.Polynomial1.itemindex;
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
      application.messagebox(pchar('No star lock or no area selected!'+#10+#10+'Place mouse on a star or hold the right mouse button down while selecting an area.'),'',MB_OK);
      exit;
    end;
  end
  else
  begin  //vizier
    ang_w:=abs((stopX-startX)*head.cdelt2*3600);{arc sec}
    ang_h:=abs((stopY-startY)*head.cdelt2*3600);{arc sec}

    window_size:='&-c.bs='+ floattostr6(ang_w)+'/'+floattostr6(ang_h);{square box}
    {-c.geom=b  square box, -c.bs=10 box size 10arc
    else radius}
    pixel_to_celestial(head,startX+1,startY+1, formalism,ra1,dec1);{first position}
    pixel_to_celestial(head,stopX+1,stopY+1,formalism,ra2,dec2);{first position}
    object_raM:=(ra1+ra2)/2; {center position}
    object_decM:=(dec1+dec2)/2;
  end;

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  image1.Canvas.Pen.Mode := pmMerge;
  image1.Canvas.Pen.width :=1;
  mainwindow.image1.Canvas.Pen.Color:= annotation_color;{clyellow}
  mainwindow.image1.Canvas.brush.Style:=bsClear;

  str(abs(object_decM*180/pi) :3:10,dec8);
  if object_decM>=0 then sgn:='+'  else sgn:='-';
  if object_decM>=0 then sgn:='%2B'{+}  else sgn:='%2D'{-} ;

  str(abs(object_raM*180/pi) :3:10,ra8);

  if sender=simbad_annotation_deepsky1 then //Simbad deepsky
  begin
    x1:=(stopX+startX) div 2;
    y1:=(stopY+startY) div 2;
    url:='http://simbad.u-strasbg.fr/simbad/sim-sam?submit=submit+query&maxObject=1000&Criteria=(maintype!=*)'+'%26+region(box,'+ra8+sgn+dec8+',+'+floattostr4(ang_w)+'s+'+floattostr4(ang_h)+'s)&OutputMode=LIST&output.format=ASCII';
//    http://simbad.u-strasbg.fr/simbad/sim-sam?submit=submit+query&maxObject=1000&Criteria=(Vmag<15+|+Bmag<15+)%26+region(box,60.2175d%2B25.5763d,+32.3592m+38.5229m)&OutputMode=LIST&output.format=ASCII'
    plot_simbad(get_http(url));
    Screen.Cursor:=crDefault;
    exit;
  end
  else
  if sender=vizier_gaia_annotation1 then //Plot Gaia stars
  begin
    annotation_magn:=inputbox('Chart request','Limiting magnitude chart:' ,annotation_magn);
    annotation_magn:=StringReplace(annotation_magn,',','.',[]); {replaces komma by dot}
    magn_type:=uppercase(inputbox('Chart request','Magnitude type [G, BP, V, B, R]:' , magn_type));

    x1:=(stopX+startX) div 2;
    y1:=(stopY+startY) div 2;
    url:='http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=RA_ICRS,DE_ICRS,Gmag,BPmag,RPmag&-c='+ra8+sgn+dec8+window_size+'&-out.max=10000&Gmag=<'+trim(annotation_magn);
//    url:='http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=RA_ICRS,DE_ICRS,Gmag,BPmag,RPmag&-c='+ra8+sgn+dec8+'&-c.bs=533.293551/368.996043&-out.max=1000&Gmag=%3C23
    plot_vizier(get_http(url),magn_type);
    Screen.Cursor:=crDefault;
    exit;
  end

  else
  if sender=simbad_annotation_deepsky_filtered1 then //Simbad deepsky with maintype filter
  begin
    x1:=(stopX+startX) div 2;
    y1:=(stopY+startY) div 2;
    url:='http://simbad.u-strasbg.fr/simbad/sim-sam?submit=submit+query&maxObject=1000&Criteria=(maintype='+maintype+')'+'%26+region(box,'+ra8+sgn+dec8+',+'+floattostr4(ang_w)+'s+'+floattostr4(ang_h)+'s)&OutputMode=LIST&output.format=ASCII';
    plot_simbad(get_http(url));
    Screen.Cursor:=crDefault;
    exit;
  end
  else

  if sender=simbad_annotation_star1 then //Simbad stars
  begin
    x1:=(stopX+startX) div 2;
    y1:=(stopY+startY) div 2;
    url:='http://simbad.u-strasbg.fr/simbad/sim-sam?submit=submit+query&maxObject=1000&Criteria=(maintype=*)'+'%26+region(box,'+ra8+sgn+dec8+',+'+floattostr4(ang_w)+'s+'+floattostr4(ang_h)+'s)&OutputMode=LIST&output.format=ASCII';
//    http://simbad.u-strasbg.fr/simbad/sim-sam?submit=submit+query&maxObject=1000&Criteria=(Vmag<15+|+Bmag<15+)%26+region(box,60.2175d%2B25.5763d,+32.3592m+38.5229m)&OutputMode=LIST&output.format=ASCII'
    plot_simbad(get_http(url));
    Screen.Cursor:=crDefault;
    exit;
  end
  else

  if sender=mainwindow.gaia_star_position1 then //Browser Gaia stars
  begin
    plot_the_annotation(stopX+1,stopY+1,startX+1,startY+1,0,'');{rectangle, +1 to fits coordinates}
    url:='http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=Source,RA_ICRS,DE_ICRS,Plx,pmRA,pmDE,Gmag,BPmag,RPmag&-c='+ra8+sgn+dec8+window_size+'&-out.max=300&Gmag=<23';
    //http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=Source,RA_ICRS,DE_ICRS,pmRA,pmDE,Gmag,BPmag,RPmag&-c=86.5812345-10.3456,bm=1x1&-out.max=1000000&BPmag=%3C21.5
    //http://vizier.u-strasbg.fr/viz-bin/asu-txt?-source=I/355/Gaiadr3&-out=Source,RA_ICRS,DE_ICRS,pmRA,pmDE,Gmag,BPmag,RPmag&-c=86.5812345-10.3456,bm=2x2&-out.max=1000000&BPmag=%3C21.5
  end
  else

  if sender=mainwindow.simbad_query1 then
  begin {sender simbad_query1}
    radius:=max(abs(stopX-startX),abs(stopY-startY)) div 2; {convert ellipse to circle}
    x1:=(stopX+startX) div 2;
    y1:=(stopY+startY) div 2;
    plot_the_circle(x1-radius,y1-radius,x1+radius,y1+radius);
    url:='http://simbad.u-strasbg.fr/simbad/sim-coo?Radius.unit=arcsec&Radius='+floattostr6(max(ang_w,ang_h)/2)+'&Coord='+ra8+'d'+sgn+dec8+'d&OutputMode=LIST&output.format=HTML';
    //  url:='http://simbad.u-strasbg.fr/simbad/sim-coo?Radius.unit=arcsec&Radius=0.4692&Coord=195.1060d28.1998d
  end
  else

  if sender=mainwindow.hyperleda_guery1 then
  begin {sender hyperleda_guery1}
    plot_the_annotation(stopX+1,stopY+1,startX+1,startY+1,0,'');{rectangle, +1 to fits coordinates}
    url:='http://atlas.obs-hp.fr/hyperleda/fG.cgi?n=a000&ob=ra&c=o&p=J'+ra8+'d%2C'+sgn+dec8+'d&f='+floattostr6(max(ang_w,ang_h)/(60));  //350.1000D%2C50.50000D    &f=50
    // http://leda.univ-lyon1.fr/fG.cgi?n=a000&c=o&p=J350.1000D%2C50.50000D&f=50&ob=ra
    // http://atlas.obs-hp.fr/hyperleda/fG.cgi?n=a000&ob=ra&c=o&p=J161.7415593981d%2C%2B11.8948545867d&f=17.877745
  end

  else
  if sender=mainwindow.ned_query1 then
  begin {sender ned_query1}
    radius:=max(abs(stopX-startX),abs(stopY-startY)) div 2; {convert ellipse to circle}
    x1:=(stopX+startX) div 2;
    y1:=(stopY+startY) div 2;
    plot_the_circle(x1-radius,y1-radius,x1+radius,y1+radius);
    url:='http://ned.ipac.caltech.edu/conesearch?in_csys=Equatorial&in_equinox=J2000&coordinates='+ra8+'d%20'+sgn+dec8+'d&radius=' +floattostr6(max(ang_w,ang_h)/(60*2))+'&corr_z=1&z_constraint=Unconstrained&z_unit=z&ot_include=ANY&nmp_op=ANY&search_type=Near%20Position%20Search&out_csys=Equatorial&out_equinox=Same%20as%20Input&obj_sort=Distance%20to%20search%20center'+'&in_objtypes1[Galaxies]=Galaxies&in_objtypes1[GPairs]=GPairs&in_objtypes1[GTriples]=GTriples&in_objtypes1[GGroups]=GGroups&in_objtypes1[GClusters]=GClusters&in_objtypes1[QSO]=QSO&in_objtypes1[QSOGroups]=QSOGroups&in_objtypes1[GravLens]=GravLens&in_objtypes1[AbsLineSys]=AbsLineSys&in_objtypes1[EmissnLine]=EmissnLine';
    //http://ned.ipac.caltech.edu/conesearch?in_csys=Equatorial&in_equinox=J2000&coordinates=12.000d%20%2B45.0000d&radius=2&corr_z=1&z_constraint=Unconstrained&z_unit=z&ot_include=ANY&nmp_op=ANY&search_type=Near%20Position%20Search&out_csys=Equatorial&out_equinox=Same%20as%20Input&obj_sort=Distance%20to%20search%20center
  end
  else


  begin {sender aavso_chart1}
    annotation_magn:=inputbox('Chart request','Limiting magnitude chart:' ,annotation_magn);
    annotation_magn:=StringReplace(annotation_magn,',','.',[]); {replaces komma by dot}

    radius:=max(abs(stopX-startX),abs(stopY-startY)) div 2; {convert ellipse to circle}
    x1:=(stopX+startX) div 2;
    y1:=(stopY+startY) div 2;
    plot_the_annotation(x1-radius+1,y1-radius+1,x1+radius+1,y1+radius+1,0,'');{square}

    ra8:=prepare_ra(object_raM,' '); {radialen to text, format 24: 00 00.0 }
    dec8:=prepare_dec(object_decM,' '); {radialen to text, format 90d 00 00}

    if dec8[1]='+' then dec_degrees:=copy(dec8,2,2) else dec_degrees:=copy(dec8,1,3);
    url:='https://app.aavso.org/vsp/chart/?ra='+copy(ra8,1,2)+'%3A'+copy(ra8,4,2)+'%3A'+copy(ra8,7,99)+'&dec='+dec_degrees+'%3A'+copy(dec8,5,2)+'%3A'+copy(dec8,8,99)+'&scale=C&orientation=visual&type=chart&fov='+inttostr(round( (ang_w+ang_w)/(60*2)))+'&maglimit='+trim(annotation_magn)+'&resolution=150&north=up&east=left'

    //  https://app.aavso.org/vsp/chart/?ra=08%3A40%3A29.63&dec=40%3A07%3A24.4&scale=C&orientation=visual&type=chart&fov=120.0&maglimit=12.0&resolution=150&north=up&east=left
  end;
  openurl(url);
  Screen.Cursor:=crDefault;
end;


procedure Tmainwindow.mountposition1Click(Sender: TObject);
begin
  if head.naxis=0 then exit;
  if mountposition1.checked then
  begin
    plot_large_north_indicator;
    image1.refresh;{important, show update}
  end
  else
    plot_fits(mainwindow.image1,false,true); {clear indiicator}
end;


function find_reference_star(img : image_array) : boolean;{for manual alignment}
var
  xc,yc,hfd2,fwhm_star2,snr,flux : double;
begin
  result:=false; {assume failure}
  if pos('small',stackmenu1.manual_centering1.text)<>0 then {comet}
  begin
    find_star_center(img,10,startX,startY,xc,yc);
  end
  else
  if pos('medium',stackmenu1.manual_centering1.text)<>0 then {comet}
  begin
    find_star_center(img,20,startX,startY,xc,yc);
  end
  else
  if pos('large',stackmenu1.manual_centering1.text)<>0 then {comet}
  begin
    find_star_center(img,30,startX,startY,xc,yc);
  end

  else
  if pos('No',stackmenu1.manual_centering1.text)<>0 then {no centering}
  begin
    xc:=startX;{0..head.width-1}
    yc:=startY;
  end
  else {star alignment}
  HFD(img,startX,startY,14{annulus radius},99 {flux aperture restriction},0 {adu_e},hfd2,fwhm_star2,snr,flux,xc,yc); {auto center using HFD function}


  if hfd2<90 then {detected something}
  begin
    shape_var1_fitsX:=xc+1;{calculate fits positions}
    shape_var1_fitsY:=yc+1;
    result:=true;
  end;
end;


procedure Tmainwindow.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  width5,height5, xf,yf,k, fx,fy, shapetype,c                  : integer;
  hfd2,fwhm_star2,snr,flux,xc,yc,xcf,ycf,center_x,center_y,a,b : double;
begin
  if head.naxis=0 then exit;
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
    if find_reference_star(img_loaded) then
    begin
      if snr>10 then shapetype:=1 {circle} else shapetype:=0;{square}
      with stackmenu1 do
        for c := 0 to listview1.Items.Count - 1 do
          if listview1.Items[c].Selected then
          begin
            listview_add_xy(c,shape_var1_fitsX,shape_var1_fitsY);{add to list of listview1}
            {$ifdef darwin} {MacOS}
            {bugfix darwin green red colouring}
            stackmenu1.ListView1.Items.item[c].Subitems.strings[L_result]:='✓ star';
            {$endif}
            break;
          end;
      show_marker_shape(mainwindow.shape_manual_alignment1,shapetype,20,20,10{minimum},shape_var1_fitsX, shape_var1_fitsY);
    end;
  end
  else
  if ((stackmenu1.pagecontrol1.tabindex=8) and   (stackmenu1.measuring_method1.itemindex=0))  then {photometry}
  begin
    {star alignment}
    HFD(img_loaded,startX,startY,14{annulus radius},99 {flux aperture restriction},0 {adu_e},hfd2,fwhm_star2,snr,flux,xc,yc); {auto center using HFD function}
    if hfd2<90 then {detected something}
    begin
      if snr>5 then shapetype:=1 {circle} else shapetype:=0;{square}
      xcf:=xc+1;{make fits coordinates}
      ycf:=yc+1;
      if shape_nr=1 then//var
      begin
        if ((abs(shape_check1_fitsX-xcf)<=3) and (abs(shape_check1_fitsY-ycf)<=3)) then
          begin
            shape_check1_fitsX:=shape_var1_fitsX;
            shape_check1_fitsY:=shape_var1_fitsY;
            shape_check1_ra:=shape_var1_ra;
            shape_check1_dec:=shape_var1_dec;
          end{swap, prevent overlapping}
        else
          if ((abs(shape_star3_fitsX-xcf)<=3) and (abs(shape_star3_fitsY-ycf)<=3)) then
          begin
            shape_star3_fitsX:=shape_var1_fitsX;
            shape_star3_fitsY:=shape_var1_fitsY;
            shape_star3_ra:=shape_var1_ra;
            shape_star3_dec:=shape_var1_dec;
          end;
        shape_var1_fitsX:=xcf; shape_var1_fitsY:=ycf;
        if head.cd1_1<>0 then
        begin
          pixel_to_celestial(head,xcf,ycf,0,shape_var1_ra,shape_var1_dec);{store shape position in ra,dec for positioning accurate at an other image}
          error_label1.visible:=false;
        end
        else
        begin
          error_label1.caption:='Variable position undefined due to missing image solution!';
          error_label1.visible:=true;
        end;
      end
      else
      if shape_nr=2 then //check
      begin
        if ((abs(shape_var1_fitsX-xcf)<=3) and (abs(shape_var1_fitsY-ycf)<=3)) then
        begin
          shape_var1_fitsX:=shape_check1_fitsX;
          shape_var1_fitsY:=shape_check1_fitsY;
          shape_var1_ra:=shape_check1_ra;
          shape_var1_dec:=shape_check1_dec;
        end{swap, prevent overlapping}
        else
          if ((abs(shape_star3_fitsX-xcf)<=3) and (abs(shape_star3_fitsY-ycf)<=3)) then
          begin
            shape_star3_fitsX:=shape_check1_fitsX;
            shape_star3_fitsY:=shape_check1_fitsY;
            shape_star3_ra:=shape_check1_ra;
            shape_star3_dec:=shape_check1_dec;
          end;
        shape_check1_fitsX:=xcf; shape_check1_fitsY:=ycf; {calculate fits positions}
        if head.cd1_1<>0 then
          pixel_to_celestial(head,xcf,ycf,0,shape_check1_ra,shape_check1_dec);{store shape position in ra,dec for positioning accurate at an other image}

      end
      else
      if shape_nr=3 then //star3
      begin
        if ((abs(shape_var1_fitsX-xcf)<=3) and (abs(shape_var1_fitsY-ycf)<=3)) then
          begin
            shape_var1_fitsX:=shape_star3_fitsX;
            shape_var1_fitsY:=shape_star3_fitsY;
            shape_var1_ra:=shape_star3_ra;
            shape_var1_dec:=shape_star3_dec;
          end{swap, prevent overlapping}
        else
          if ((abs(shape_check1_fitsX-xcf)<=3) and (abs(shape_check1_fitsY-ycf)<=3)) then
            begin
              shape_check1_fitsX:=shape_star3_fitsX;
              shape_check1_fitsY:=shape_star3_fitsY;
              shape_check1_ra:=shape_star3_ra;
              shape_check1_dec:=shape_star3_dec;
            end;
        shape_star3_fitsX:=xcf; shape_star3_fitsY:=ycf;
        if head.cd1_1<>0 then
          pixel_to_celestial(head,xcf,ycf,0,shape_star3_ra,shape_star3_dec);{store shape position in ra,dec for positioning accurate at an other image}
      end;
      Shape_var1.HINT:='?';//reset any labels
      shape_check1.HINT:='?';
      show_marker_shape(mainwindow.shape_var1,shapetype,20,20,10{minimum},shape_var1_fitsX, shape_var1_fitsY);
      show_marker_shape(mainwindow.shape_check1,7 {shapetype},20,20,10{minimum},shape_check1_fitsX, shape_check1_fitsY);
      show_marker_shape(mainwindow.shape_star3,shapetype,20,20,10{minimum},shape_star3_fitsX, shape_star3_fitsY);

      inc(shape_nr);
      if shape_nr>=4 then
      shape_nr:=1;

      //check if Var is within an annotation
      var_lock:='';//clear name
      if ((annotated) and (mainwindow.annotations_visible1.checked)) then
      begin
        plot_annotations(false {use solution vectors},false);
        if var_lock<>'' then
        begin
          memo2_message('Var locked on object: '+var_lock);
          mainwindow.shape_var1.HINT:=var_lock;
        end;
      end;

    end;

  end;
 {end photometry}

  image_move_to_center:=false;{image in moved to center, why is so difficult???}

  down_x:=x;
  down_y:=y;
  down_xy_valid := True;

  ctrlbutton :=((ssCtrl in shift) or ((ssShift in shift)));//generic variable for rectangle shape

  if ssleft in shift then
  begin
    Screen.Cursor:=crhandpoint;

    if ((head.naxis3=3) and (stackmenu1.pagecontrol1.tabindex=13) {pixelmath 1}) then {for colour replace function}
    begin
      sample(startX,startY);
    end;

    if copy_paste then {paste copied image part}
    begin
      width5:=Length(img_loaded[0,0]); {width}
      height5:=Length(img_loaded[0]); {height}

      {ellipse parameters}
      center_x:=(copy_paste_x + copy_paste_x+copy_paste_w-1)/2;
      center_y:=(copy_paste_y + copy_paste_y+copy_paste_h-1)/2;
      a:=(copy_paste_w-1)/2;
      b:=(copy_paste_h-1)/2;

      for k:=0 to head.naxis3-1 do {do all colors}
      begin
        for fy:=copy_paste_y to copy_paste_y+copy_paste_h-1 do
        for fX:=copy_paste_x to copy_paste_x+copy_paste_w-1 do
        begin
          if ((copy_paste_shape=0 {use no ellipse}) or (sqr(fx-center_X)/sqr(a) +sqr(fy-center_Y)/sqr(b)<1)) then // standard equation of the ellipse
            img_loaded[k ,max(0,min(height5-1,round(startY+(fy-copy_paste_y) - (copy_paste_h div 2)))),max(0,min(width5-1,round(startX+(fx-copy_paste_x)- (copy_paste_w div 2)))) ]:=img_backup[index_backup].img[k,fy,fx];{use backup for case overlap occurs}
        end;
      end;{k color}
      plot_fits(mainwindow.image1,false,true);
      if ((ssCtrl in shift) or (ssAlt in shift) or (ssShift in shift))=false then
      begin
        copy_paste:=false;
        shape_paste1.visible:=false;
      end;
    end;
  end;{left button pressed}
end;



{calculates star HFD and FWHM, SNR, xc and yc are center of gravity, rs is the boxsize, aperture for the flux measurment. All x,y coordinates in array[0..] positions}
{aperture_small is used for photometry of stars. Set at 99 for normal full flux mode}
{Procedure uses two global accessible variables:  r_aperture and sd_bg }
procedure HFD(img: image_array;x1,y1,rs {annulus diameter}: integer;aperture_small, adu_e {unbinned} :double; out hfd1,star_fwhm,snr{peak/sigma noise}, flux,xc,yc:double);
const
  max_ri=74; //(50*sqrt(2)+1 assuming rs<=50. Should be larger or equal then sqrt(sqr(rs+rs)+sqr(rs+rs))+1+2;
  samplepoints=5; // for photometry. emperical gives about 10% to 20 % improvment

var
  width5,height5,i,j,r1_square,r2_square,r2, distance,distance_top_value,illuminated_pixels,signal_counter,counter,annulus_width :integer;
  SumVal,Sumval_small, SumValX,SumValY,SumValR, Xg,Yg, r, val,pixel_counter,valmax,mad_bg,radius,dx,dy    : double;
  HistStart,boxed : boolean;
  distance_histogram : array [0..max_ri] of integer;
  background : array [0..1000] of double; {size =3*(2*PI()*(50+3)) assuming rs<=50}

    function value_subpixel(x1,y1:double):double; {calculate square image pixel value on subpixel level. This method is a little the method bilinear}
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
        result:=         (img[0,y_trunc  ,x_trunc  ]) * (1-x_frac)*(1-y_frac);{pixel left top,    1}
        result:=result + (img[0,y_trunc  ,x_trunc+1]) * (  x_frac)*(1-y_frac);{pixel right top,   2}
        result:=result + (img[0,y_trunc+1,x_trunc  ]) * (1-x_frac)*(  y_frac);{pixel left bottom, 3}
        result:=result + (img[0,y_trunc+1,x_trunc+1]) * (  x_frac)*(  y_frac);{pixel right bottom,4}
      except
      end;
    end;


begin
  width5:=Length(img[0,0]);{width}
  height5:=Length(img[0]); {height}


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
        background[counter]:=img[0,y1+j,x1+i];
        //for testing: mainwindow.image1.canvas.pixels[y1+j,x1+i]:=$AAAAAA;
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
        val:=(img[0,y1+j,x1+i])- star_bg;
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
    if r_aperture>=rs then
        exit; {star is equal or larger then box, abort}

    if (r_aperture>2)and(illuminated_pixels<0.35*sqr(r_aperture+r_aperture-2)){35% surface} then
       exit;  {not a star disk but stars, abort with hfd 999}

    except

  end;

  // Get HFD
  SumVal:=0;
  Sumval_small:=0;
  SumValR:=0;
  pixel_counter:=0;


  SumVal:=0;
  Sumval_small:=0;
  SumValR:=0;
  pixel_counter:=0;

  if r_aperture<aperture_small then //standard mode, full star flux use
  begin
    for i:=-r_aperture to r_aperture do //Make steps of one pixel
    for j:=-r_aperture to r_aperture do
    begin
      Val:= value_subpixel(xc+i,yc+j)-star_bg; //The calculated center of gravity is a floating point position and can be anyware, so calculate pixel values on sub-pixel level
      if val>=valmax*0.5 then pixel_counter:=pixel_counter+1;//How many pixels are above half maximum
      r:=sqrt(sqr(i)+sqr(j)); //Distance from star gravity center
      SumVal:=SumVal+Val;//Sumval will be star total star flux
      SumValR:=SumValR+Val*r; //Method Kazuhisa Miyashita, see notes of HFD calculation method, note calculate HFD over square area. Works more accurate then for round area
    end;
    flux:=max(sumval,0.00001);//prevent dividing by zero or negative values
    radius:=r_aperture;
  end
  else
  begin //photometry mode. Measure only the bright center of the star for a better SNR
    for i:=-r_aperture*SamplePoints to r_aperture*SamplePoints do //Make steps in fraction of a pixel
    for j:=-r_aperture*SamplePoints to r_aperture*SamplePoints do
    begin
      dx:=i/samplepoints;
      dy:=j/samplepoints;

      Val:= value_subpixel(xc+dx,yc+dy)-star_bg;//The calculated center of gravity is a floating point position and can be anyware, so calculate pixel values on sub-pixel level
      if val>=valmax*0.5 then pixel_counter:=pixel_counter+1/(SamplePoints*SamplePoints);{How many pixels are above half maximum}
      val:=val/(SamplePoints*SamplePoints);
      r:=sqrt(sqr(dx)+sqr(dy)); //Distance from star gravity center
      if r<=aperture_small then SumVal_small:=SumVal_small+Val; //For photometry only. Flux within aperture_small. Works more accurate for differential photometry
      SumVal:=SumVal+Val;//Sumval will be star total star flux
      SumValR:=SumValR+Val*r; //Method Kazuhisa Miyashita, see notes of HFD calculation method, note calculate HFD over square area. Works more accurate then for round area
    end;
    flux:=max(sumval_small,0.00001);//prevent dividing by zero or negative values
    radius:=aperture_small; // use smaller aperture
  end; //photometry mode

  star_fwhm:=2*sqrt(pixel_counter/pi);{calculate from surface (by counting pixels above half max) the diameter equals FWHM }
  hfd1:=2*SumValR/flux;
  hfd1:=max(0.7,hfd1);

  if adu_e<>0 then
  begin //adu to e- correction
    flux:=flux*adu_e*sqr(head.xbinning);// if an image is binned the adu's are averaged. So bin2x2 result in four times less adu. Star flux should be independend of binning
    sd_bg:=sd_bg*adu_e*head.xbinning;//noise is sqrt of signal. So electron noise reduces linear with binning value
  end;

  //noise calculation
  if flux>=1 then
    snr:=flux /sqrt(flux +sqr(radius)*pi*sqr(sd_bg))
  else
    snr:=0;//rare but happens. Prevent runtime errors  by /flux
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
    http://spiff.rit.edu/classes/phys373.s2014/lectures/signal/signal_illus.html}

//   memo2_message(#9+'######'+#9+inttostr(round(flux))+#9+ floattostr6(r_aperture)+#9+floattostr6(sd)+#9+floattostr6(snr)+#9+floattostr6(sqr(r_aperture)*pi*sqr(sd)));


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





procedure measure_hotpixels(x1,y1, x2,y2,col : integer; sd,mean:  double; img : image_array; out hotpixel_perc, hotpixel_adu :double);{calculate the hotpixels percentage and RMS value}
var i,j,counter,counter2,w,h : integer;
    value                    : double;

begin
  w:=Length(img[0,0]); {width}
  h:=Length(img[0]); {height}

  x1:=max(x1,0);{protect against values outside the array}
  x2:=min(x2,w-1);

  y1:=max(y1,0);
  y2:=min(y2,h-1);

  if ((y1>y2) or (x1>x2)) then exit;

  hotpixel_adu:=0;
  counter:=0;
  counter2:=0;
  for j:=y1 to y2  do {calculate standard deviation  of region of interest}
  for i:=x1 to x2 do {calculate standard deviation  of region of interest}
  begin
    value:=abs(img[col,j,i]-mean);
    if value<=3*sd then {ignore outliers}
      inc(counter)
    else
    begin
      hotpixel_adu:=hotpixel_adu+sqr(value);
      inc(counter2);
    end;
  end;
  if counter2>0 then
    hotpixel_adu:=sqrt(hotpixel_adu/counter2)
  else
    hotpixel_adu:=0;
    hotpixel_perc:=0.997 - counter/(counter+counter2);//percentage hot pixels. Within sigma 3.0,  99.73% remains.
end;


procedure local_sd(x1,y1, x2,y2,col : integer;{accuracy: double;} img : image_array; out sd,mean : double; out iterations :integer);{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}
var i,j,counter,w,h                 : integer;
    value, sd_old,meanx             : double;

begin
  w:=Length(img[0,0]); {width}
  h:=Length(img[0]); {height}

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
      value:=img[col,j,i];
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
      value:=img[col,j,i]-mean;
      if ((value<mean {not a large outlier}) and ((iterations=0) or (abs(value)<=3*sd_old)) )  then {ignore outliers after first run}
      begin
        sd:=sd+sqr(value);
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


function retrieve_ADU_to_e_unbinned(head_egain :string): double; //Used for SNR calculation in procedure HFD. Factor for unbinned files. Result is zero when calculating in e- is not activated in the statusbar popup menu. Then in procedure HFD the SNR is calculated using ADU's only.
var
  egain: double;

begin
  if ((egain_extra_factor<>0) and (mainwindow.noise_in_electron1.checked)) then
  begin
    egain:=strtofloat1(head_egain);//point seperator
    if egain=0 then egain:=egain_default;
    result:=egain/egain_extra_factor;{ADU to electrons, factor for unbinned images. For ASI1600 unbinned 1/16 because 0..4095 values result in 0..65535 output}
  end
  else
  result:=0;// zero is calculate snr using ADU's
end;

function noise_to_electrons(adu_e, sd : double): string;
begin
//  CMOS camera/software binning. Sky noise dominant. Software binning is sum pixels divide by four.
//
//                e- / pixel received	Gain         	ADU       	        EGAIN	                σ ADU  (noise)	                                σ e-   (noise)
//  bin 1x1       100 e-	        1 (unity gain)	100 ADU	                1  e-/ADU (bin1x1)      sqrt(100)=10 ADU	                        sqrt(100 e-)=10 e-
//  bin 2x2       400 e-	        1 (unity gain)	100 ADU                 1  e-/ADU (bin1x1)      sqrt(10ADU^2+10ADU^2+10ADU^2+10ADU^2)/4=5 ADU	sqrt(400 e-)/4=5 e-


//                 e- / pixel received	Gain         	ADU       	        EGAIN	                σ ADU  (noise)	                                σ e-   (noise)
//  bin 1x1        100 e-                2              200 ADU	                0.5  e-/ADU (bin1x1)	2*sqrt(100)=20 ADU	                        sqrt(100 e-)=10 e-
//  bin 2x2  	   400 e-                2              200 ADU=2*sqrt(400)/4	0.5  e-/ADU (bin1x1)	sqrt(20ADU^2+20ADU^2+20ADU^2+20ADU^2)/4=10 ADU	sqrt(400 e-)/4=5 e-
//
//  Ik ga er vanuit dat het ontvangen licht in de pixels totaal 100 electrons (e-) in een echte pixel vrijmaakt. De ruis (σ) ofwel shot noise is dan ongeveer de wortel van het aantal electrons.
//  Bij software binning halveert de pixelruis met een factor 2 voor zowel de ruis uitgedrukt in ADU als electrons. Ruis sommeer je als σ_tot:=sqrt(σ1^2+ σ2^2)

  result:=floattostrF(sd,FFGeneral,3,3);

  if adu_e<>0 then
    result:=result+' e-' // in electrons

end;

procedure Tmainwindow.Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  hfd2,fwhm_star2,snr,flux,xf,yf, raM,decM,sd,dummy,conv_factor, adu_e : double;
  s1,s2, hfd_str, fwhm_str,snr_str,mag_str,dist_str,pa_str             : string;
  width5,height5,box_SX,box_SY,flipH,flipV,iterations, box_LX,box_LY   : integer;
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
         //update shape positions using the known fitxY, fitsY position. Ra,dec position is not required
         if mainwindow.shape_manual_alignment1.visible then {For manual alignment. Do this only when visible}
           show_marker_shape(mainwindow.shape_manual_alignment1,9 {no change in shape and hint},20,20,10,shape_var1_fitsX, shape_var1_fitsY);

         {photometry measure all markers}
         if mainwindow.shape_var1.visible then {For manual alignment. Do this only when visible}
           show_marker_shape(mainwindow.shape_var1,9 {no change in shape and hint},20,20,10,shape_var1_fitsX, shape_var1_fitsY);
         if mainwindow.shape_check1.visible then {For manual alignment. Do this only when visible}
           show_marker_shape(mainwindow.shape_check1,9 {no change in shape and hint},20,20,10,shape_check1_fitsX, shape_check1_fitsY);
         if mainwindow.shape_star3.visible then {For manual alignment. Do this only when visible}
           show_marker_shape(mainwindow.shape_star3,9 {no change in shape and hint},20,20,10,shape_star3_fitsX, shape_star3_fitsY);

          if mainwindow.shape_var2.visible then //update the shape position based on ra,dec values
          begin
            show_marker_shape(mainwindow.shape_var2,9 {no change in shape and hint},50,50,10,shape_var2_fitsX, shape_var2_fitsY);
            show_marker_shape(mainwindow.shape_check2,9 {no change in shape and hint},50,50,10,shape_check2_fitsX, shape_check2_fitsY);
          end;
       end;
     end;

     exit;{no more to do}
   end
   else
   down_xy_valid := False; {every move without ssleft will invalidate down_xy}

   if img_loaded=nil then exit; {image load has failed, prevent runtime error}
   width5:=Length(img_loaded[0,0]);    {width}
   height5:=Length(img_loaded[0]); {height}

   if flip_horizontal1.Checked then flipH:=-1 else flipH:=1;
   if flip_vertical1.Checked then  flipV:=-1 else flipV:=1;

   if flipH=-1 then xf:=image1.width-1-x else xf:=x;;
   if flipV=-1 then yf:=image1.height-1-y else yf:=y;

   mouse_fitsx:=0.5+(0.5+xf)/(image1.width/width5);{starts at +0.5 and  middle pixels is 1}
   mouse_fitsy:=0.5+height5-(0.5+yf)/(image1.height/height5); {from bottom to top, starts at +0.5 and 1 at middle first pixel}

   //rubber rectangle
   if ssright in shift then {rubber rectangle}
   begin

     stopX:=round(-1+mouse_fitsX); {starts at -0.5 and  middle pixels is 0}
     stopY:=round(-1+mouse_fitsY); {from bottom to top, starts at -0.5 and 0 at middle first pixel}

     if flipH>0 then box_SX:=min(startX,stopX) else box_SX:=width5-1-max(startX,stopX);//box left position
     if flipV<0 then box_SY:=min(startY,stopY) else box_SY:=height5-1-max(startY,stopY);// box top position
     box_LX:=abs(startX-stopX);//box width
     box_LY:=abs(startY-stopY);// box height

     boxshape1.Left:=image1.left + trunc((image1.width/width5)*box_SX);
     boxshape1.top:= image1.top+trunc((image1.height/height5)* box_SY);
     boxshape1.width:= trunc( (image1.width/width5)* (box_LX+1)         );
     boxshape1.height:=trunc( (image1.height/height5)* (box_LY+1)        );
     boxshape1.Pen.width :=max(1,round(image1.width/width5));
     boxshape1.visible:=true;

     if ctrlbutton then boxshape1.shape:=STellipse else boxshape1.shape:=STrectangle;


     ang_sep_two_positions(startX+1,startY+1,mouse_fitsX,mouse_fitsY,dist_str,pa_str);
     mainwindow.statusbar1.panels[7].text:=inttostr(box_LX)+' x '+inttostr(box_LY)+'    '+dist_str+'  ∠ '+pa_str;{indicate rectangle size}
   end
   else
   begin
     mainwindow.statusbar1.panels[7].text:='';{remove crop size}
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
      show_marker_shape(mainwindow.shape_paste1,copy_paste_shape {rectangle or ellipse},copy_paste_w,copy_paste_h,0{minimum}, mouse_fitsx, mouse_fitsy);{show the paste shape}
   end;
   try color1:=ColorToRGB(mainwindow.image1.canvas.pixels[trunc(x*width5/image1.width),trunc(y*height5/image1.height)]); ;except;end;  {note  getpixel(image1.canvas.handle,x,y) doesn't work well since X,Y follows zoom  factor !!!}

   if head.naxis3=3 then {for star temperature}
   begin
     try
       r:=img_loaded[0,round(mouse_fitsy)-1,round(mouse_fitsx)-1]-bck.backgr;
       b:=img_loaded[2,round(mouse_fitsy)-1,round(mouse_fitsx)-1]-bck.backgr;
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
     if head.naxis3=1 then mainwindow.statusbar1.panels[3].text:=s1+', '+s2+' = ['+floattostrF(img_loaded[0,round(mouse_fitsY)-1,round(mouse_fitsX)-1],ffgeneral,5,0)+']' else
     if head.naxis3=3 then mainwindow.statusbar1.panels[3].text:=s1+', '+s2+' = ['+floattostrF(img_loaded[0,round(mouse_fitsY)-1,round(mouse_fitsX)-1],ffgeneral,5,0)+'/'+ {color}
                                                                              floattostrF(img_loaded[1,round(mouse_fitsY)-1,round(mouse_fitsX)-1],ffgeneral,5,0)+'/'+
                                                                              floattostrF(img_loaded[2,round(mouse_fitsY)-1,round(mouse_fitsX)-1],ffgeneral,5,0)+' '+']'
     else mainwindow.statusbar1.panels[3].text:='';
   except

   end;

   pixel_to_celestial(head,mouse_fitsx,mouse_fitsy,mainwindow.Polynomial1.itemindex,raM,decM);
   mainwindow.statusbar1.panels[0].text:=position_to_string('   ',raM,decM);

   adu_e:=retrieve_ADU_to_e_unbinned(head.egain);//Used for SNR calculation in procedure HFD. Factor for unbinned files. Result is zero when calculating in e- is not activated in the statusbar popup menu. Then in procedure HFD the SNR is calculated using ADU's only.

   hfd2:=999;
   HFD(img_loaded,round(mouse_fitsX-1),round(mouse_fitsY-1),annulus_radius {annulus radius},head.mzero_radius,adu_e {adu_e unbinned},hfd2,fwhm_star2,snr,flux,object_xc,object_yc);{input coordinates in array[0..] output coordinates in array [0..]}
   //mainwindow.caption:=floattostr(mouse_fitsX)+',   '+floattostr(mouse_fitsy)+',         '+floattostr(object_xc)+',   '+floattostr(object_yc);
   if ((hfd2<99) and (hfd2>0)) then //star detected
   begin
     object_hfd:=hfd2;
     if ((hfd_arcseconds) and (head.cd1_1<>0)) then conv_factor:=abs(head.cdelt2)*3600{arc seconds} else conv_factor:=1;{pixels}
     if hfd2*conv_factor>1 then str(hfd2*conv_factor:0:1,hfd_str) else str(hfd2*conv_factor:0:2,hfd_str);
     str(fwhm_star2*conv_factor:0:1,fwhm_str);
     if ((hfd_arcseconds) and (head.cd1_1<>0)) then begin hfd_str:=hfd_str+'"';fwhm_str:=fwhm_str+'"';end;

     str(snr:0:0,snr_str);
     if adu_e=0 then snr_str:='SNR='+snr_str // noise based on ADU's
       else snr_str:='SNR_e='+snr_str;// noise based on electrons. No unit

     if head.mzero<>0 then {offset calculated in star annotation call}
     begin
       str(head.mzero -ln(flux)*2.5/ln(10):0:2,mag_str);
       mag_str:=', '+head.passband_database+'='+mag_str
     end
     else mag_str:='';

     {centered coordinates}
     pixel_to_celestial(head,object_xc+1,object_yc+1,mainwindow.Polynomial1.itemindex,object_raM,object_decM);{input in FITS coordinates}
     if ((object_raM<>0) and (object_decM<>0)) then
       mainwindow.statusbar1.panels[1].text:=position_to_string('   ',object_raM,object_decM)
                                               //prepare_ra8(object_raM,': ')+'   '+prepare_dec2(object_decM,'° '){object position in RA,DEC}
     else
       mainwindow.statusbar1.panels[1].text:=floattostrF(object_xc+1,ffFixed,7,2)+',  '+floattostrF(object_yc+1,ffFixed,7,2);{object position in FITS X,Y}
     mainwindow.statusbar1.panels[2].text:='HFD='+hfd_str+', FWHM='+FWHM_str+', '+snr_str+mag_str; {+', '+floattostrF(flux,ffFixed,0,0)};

     if adu_e<>0 then
       mainwindow.statusbar1.panels[7].text:=floattostrF(flux,ffFixed,0,0)+' e-'
     else
       mainwindow.statusbar1.panels[7].text:=floattostrF(flux,ffFixed,0,0)+' ADU';

     if star_profile1.checked then
     begin
       plot_star_profile(round(object_xc),round(object_yc));
       star_profile_plotted:=true;
     end;
   end
   else
   begin
     object_xc:=-999999;{indicate object_raM is unlocked}
     object_raM:=raM; {use mouse position instead}
     object_decM:=decM; {use mouse position instead}
     mainwindow.statusbar1.panels[1].text:='';

     local_sd(round(mouse_fitsX-1)-10,round(mouse_fitsY-1)-10, round(mouse_fitsX-1)+10,round(mouse_fitsY-1)+10{regio of interest},0 {col},img_loaded, sd,dummy {mean},iterations);{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}

     mainwindow.statusbar1.panels[2].text:='σ = '+noise_to_electrons(adu_e, sd); //reports noise in ADU's (adu_e=0) or electrons

     if star_profile_plotted then plot_north;
     star_profile_plotted:=false;
   end;
end;


procedure Tmainwindow.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if button=mbright then
   begin
     if abs(stopX-startX)>2 then boxshape1.visible:=true;//extra for case it is invisible
     PopupMenu1.PopUp;{call popup manually if right key is released, not when clicked. Set in popupmenu autopopup off !!!}
     boxshape1.visible:=false;
   end;

  down_xy_valid := False;
  Screen.Cursor:=crDefault;
end;


procedure Tmainwindow.stretch_draw1Click(Sender: TObject); {stretch draw}
var
  tmpbmp: TBitmap;
  ARect: TRect;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

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
  Screen.Cursor:=crDefault;
end;


procedure Tmainwindow.SaveFITSwithupdatedheader1Click(Sender: TObject);
begin
  savefits_update_header(mainwindow.memo1.lines,filename2);
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
  filename3:=stringreplace(filename3,'_stacked','',[]);  //remove stacked mark
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
  width5:=length(img[0,0]);{width}
  height5:=length(img[0]);{height}


  setlength(result,colours5,height5,width5);
  sat_factor:=1-mainwindow.saturation_factor_plot1.position/10;

  for fitsY:=0 to height5-1 do
    for fitsX:=0 to width5-1 do
    begin
      if colours5=3 then
      begin
        col_r:=img[0,fitsY,fitsX];
        col_g:=img[1,fitsY,fitsX];
        col_b:=img[2,fitsY,fitsX];

        colrr:=(col_r-bck.backgr)/(cwhite-bck.backgr);{scale to 0..1}
        colgg:=(col_g-bck.backgr)/(cwhite-bck.backgr);{scale to 0..1}
        colbb:=(col_b-bck.backgr)/(cwhite-bck.backgr);{scale to 0..1}

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

        result[0,fitsY,fitsX]:=col_r;
        result[1,fitsY,fitsX]:=col_g;
        result[2,fitsY,fitsX]:=col_b;
      end {RGB fits with naxis3=3}
      else
      begin {mono, naxis3=1}
        col_r:=img[0,fitsY,fitsX];
        colrr:=(col_r-bck.backgr)/(cwhite-bck.backgr);{scale to 1}
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
        result[0,fitsY,fitsX] :=col_r;
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
  width2:=length(img[0,0]);{width}
  height2:=length(img[0]);{height}


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
        dum:=img[0,k,m]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
        ppmbuffer[m*6  ]  :=hi(dummy);
        ppmbuffer[m*6+1]  :=lo(dummy);
        dum:=img[1,k,m]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
        ppmbuffer[m*6+2]  :=hi(dummy);
        ppmbuffer[m*6+3]  :=lo(dummy);
        dum:=img[2,k,m]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
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
        dum:=img[0,k,m]; if dum>$FFFF then dum:=$FFFF;if dum<0 then dum:=$0;dummy:=round(dum);
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
         value1:=img[0,k,m]/65535;
         ppmbuffer32[m*3]:=lw;
         value1:=img[1,k,m]/65535;
         ppmbuffer32[m*3+1]:=lw;
         value1:=img[2,k,m]/65535;
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

         value1:=img[0,k,m]/65535;
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
  width5:=length(img[0,0]);{width}
  height5:=length(img[0]);{height}


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
      thecolor.red:=min(round(img[0,k,m]), $FFFF);
      if colours5>1 then thecolor.green:=min(round(img[1,k,m]), $FFFF)  else thecolor.green:=thecolor.red;
      if colours5>2 then thecolor.blue:=min(round(img[2,k,m]), $FFFF)   else thecolor.blue:=thecolor.red;
      thecolor.alpha:=65535;
      image.Colors[j,i]:=thecolor;
    end;
  end;

  result:=true;
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
//  result:=true;
//  try
//  Image.SaveToFile(filen2, Writer);
//  except
//    result:=false;
//    exit;
//  end;
//  image.Free;
//  writer.Free;
//end;


function save_tiff16(img: image_array; memo: tstrings; filen2:string;flip_H,flip_V:boolean): boolean;{save to 16 bit TIFF file }
var
  i, j, k,m,colours5,width5,height5      :integer;
  image: TFPCustomImage;
  writer: TFPCustomImageWriter;
  thecolor  : Tfpcolor;
  format    : string;
  factor    : single;
begin
  colours5:=length(img);{nr colours}
  width5:=length(img[0,0]);{width}
  height5:=length(img[0]);{height}

  Image := TFPMemoryImage.Create(width5, height5);
  Writer := TFPWriterTIFF.Create;


  Image.Extra[TiffAlphaBits]:='0';

  if nrbits=8 then  {8 bit fits}
  begin
    format:='8';
    factor:=256; {the tiff writer will divide by 256 again}
  end
  else
  begin
    format:='16'; {32 bit is not available}
    factor:=1;{default}
  end;

  Image.Extra[TiffRedBits]:=format;
  Image.Extra[TiffGreenBits]:=format;
  Image.Extra[TiffBlueBits]:=format;
  Image.Extra[TiffGrayBits]:=format;   {add unit fptiffcmn to make this work. see https://bugs.freepascal.org/view.php?id=35081}

  if colours5=1 then {grayscale}
    Image.Extra[TiffPhotoMetric]:='1' {PhotometricInterpretation = 0 (Min-is-White), 1 (Min-is-Black),  so for 1  black is $0000, White is $FFFF}
  else
    Image.Extra[TiffPhotoMetric]:='2';{RGB colour}

  image.Extra[TiffSoftware]:='ASTAP';

  image.Extra[TiffImageDescription]:=memo.text; {store full header in TIFF !!!}

  Image.Extra[TiffCompression]:= '8'; {FPWriteTiff only support only writing Deflate compression. Any other compression setting is silently replaced in FPWriteTiff at line 465 for Deflate. FPReadTiff that can read other compressed files including LZW.}


  For i:=0 to height5-1 do
  begin
    if flip_V=false then k:=height5-1-i else k:=i;{reverse fits down to counting}
    for j:=0 to width5-1 do
    begin
      if flip_H=true then m:=width5-1-j else m:=j;
      thecolor.red:=min(max(0,round(img[0,k,m]*factor)), $FFFF);
      if colours5>1 then thecolor.green:=min(max(0,round(img[1,k,m]*factor)), $FFFF)  else thecolor.green:=thecolor.red;
      if colours5>2 then thecolor.blue:=min(max(0,round(img[2,k,m]*factor)), $FFFF)   else thecolor.blue:=thecolor.red;
      thecolor.alpha:=65535;
      image.Colors[j,i]:=thecolor;
    end;
  end;


  result:=true;
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
  fileDate    : Integer;
  err,written   : boolean;
  dobackup : boolean;
  img_temp :image_array;
  headx : theader;
begin
  OpenDialog1.Title := 'Select multiple  files to convert to (Astro) TIFF. Date will preserved.';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=  'All formats except TIF|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP;*.new;*.ppm;*.pgm;*.pbm;*.pfm;*.xisf;*.fz;'+
                                                '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                         '|RAW files|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                         '|PNG, JPEG, BMP(*.png, *.jpg,*.bmp)|*.png;*.PNG;*.jpg;*.JPG;*.bmp;*.BMP'+
                         '|Compressed FITS files|*.fz';
  opendialog1.initialdir:=ExtractFileDir(filename2);
//  fits_file:=false;
  esc_pressed:=false;
  err:=false;
  if OpenDialog1.Execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        progress_indicator(100*i/(count),' Converting');{show progress}
        Application.ProcessMessages;
        if esc_pressed then begin err:=true; break; end;
        filename2:=Strings[I];
        memo2_message(filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count));
        if sender=save_to_tiff2 then
          fileDate := FileAge(fileName2);
        if load_image(filename2,img_temp,headx,memox,false {recenter},false {plot}) then
        begin
          filename2:=ChangeFileExt(filename2,'.tif');
          if abs(nrbits)<=16 then
          begin
            written:=save_tiff16(img_temp,memox,filename2,false {flip H},false {flip V});
          end
          else
          begin {32 bit files}
            memo2_message('This file is 32 bit. Only export to TIFF 32 bit possible. No import!!' );
            if head.naxis3<>1 then {color}
              written:=save_tiff_96(img_temp,filename2,memox.text {store full header in TIFF},false {flip H},false {flip V}) {old uncompressed routine in unit_tiff}
            else
             written:=save_tiff_32(img_temp,filename2,memox.text {store full header in TIFF},false {flip H},false {flip V});{old uncompressed routine in unit_tiff}
          end;
          if written then
          begin
            if sender=save_to_tiff2 then
               FileSetDate(filename2,filedate) {function}
          end
          else
           err:=true
        end
        else err:=true;
      end;
      if err=false then mainwindow.caption:='Completed, all files converted.'
      else
      mainwindow.caption:='Finished, files converted but with errors or stopped!';

      finally
      Screen.Cursor:=crDefault;  { Always restore to normal }
      progress_indicator(-100,'');{progresss done}
    end;
  end;
end;


procedure Tmainwindow.convert_to_ppm1Click(Sender: TObject);
var
  I: integer;
  err   : boolean;
  img_temp: image_array;
  headx : theader;
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
//  fits_file:=false;
  esc_pressed:=false;
  err:=false;
  if OpenDialog1.Execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        progress_indicator(100*i/(count),' Converting');{show progress}
        Application.ProcessMessages;
        if esc_pressed then begin err:=true; break;end;
        filename2:=Strings[I];
        mainwindow.caption:=filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count);;
        if load_image(filename2,img_temp,headx,memox,false {recenter},false {plot}) then
        begin
          if head.naxis3=1 then {monochrome}
          begin
            if abs(nrbits)<=16 then
            begin
              filename2:=ChangeFileExt(filename2,'.pgm');
              save_PPM_PGM_PFM(img_temp,16 {colour depth},filename2,false {flip H},false {flip V});
            end
            else
            begin
              filename2:=ChangeFileExt(filename2,'.pfm');
              save_PPM_PGM_PFM(img_temp,32 {colour depth},filename2,false,false);
            end;
          end
          else
          begin {colour}
            if abs(nrbits)<=16 then
            begin
              filename2:=ChangeFileExt(filename2,'.ppm');
              save_PPM_PGM_PFM(img_temp,48 {colour depth},filename2,false,false);
            end
            else
            begin
              filename2:=ChangeFileExt(filename2,'.pfm');
              save_PPM_PGM_PFM(img_temp,96 {colour depth},filename2,false,false);
            end;

          end;{colour}
        end
        else err:=true;
      end;
      if err=false then mainwindow.caption:='Completed, all files converted.'
      else
      mainwindow.caption:='Finished, files converted but with errors or stopped!';

      finally
      Screen.Cursor:=crDefault;  { Always restore to normal }
      progress_indicator(-100,'');{progresss done}

    end;
  end;
end;


procedure Tmainwindow.export_star_info1Click(Sender: TObject);
var
  dum : integer;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  //form_inspection1.undo_button1Click(nil);{undo if required}
  backup_img;

  if ((abs(stopX-startX)>1)and (abs(stopY-starty)>1))=false then {do statistics on whole image}
  begin
    startx:=0;stopX:=head.width-1;
    starty:=0;stopY:=head.height-1;
  end;

  if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
  if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;

  mainwindow.annotate_with_measured_magnitudes1Click(Sender);

  Screen.Cursor:=crDefault;  { Always restore to normal }
end;


procedure Tmainwindow.flip_H1Click(Sender: TObject);
var
  col,fitsX,fitsY : integer;
  vertical        : boolean;
  img_temp        : image_array;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  backup_img;

  vertical:= (sender=flip_V1);

  setlength(img_temp,head.naxis3,head.height,head.width);
  for col:=0 to head.naxis3-1 do {do all colours}
  begin
    For fitsY:=0 to (head.height-1) do
      for fitsX:=0 to (head.width-1) do
      begin
        if vertical then img_temp[col,(head.height-1)-fitsY, fitsX]:=img_loaded[col,fitsY,fitsX]
        else
        img_temp[col,fitsY,(head.width-1)-fitsX]:=img_loaded[col,fitsY,fitsX];
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
    new_to_old_WCS(head);{convert new style FITS to old style, calculate crota1,crota2,cdelt1,cdelt2}

    mainwindow.Memo1.Lines.BeginUpdate;
    remove_solution(true {keep wcs});
    update_float(mainwindow.memo1.lines,'CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_1);
    update_float(mainwindow.memo1.lines,'CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd1_2);
    update_float(mainwindow.memo1.lines,'CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_1);
    update_float(mainwindow.memo1.lines,'CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ',false ,head.cd2_2);

    update_float(mainwindow.memo1.lines,'CDELT1  =',' / X pixel size (deg)                             ',false ,head.cdelt1);
    update_float(mainwindow.memo1.lines,'CDELT2  =',' / Y pixel size (deg)                             ',false ,head.cdelt2);

    update_float(mainwindow.memo1.lines,'CROTA1  =',' / Image twist of X axis        (deg)             ',false ,head.crota1);
    update_float(mainwindow.memo1.lines,'CROTA2  =',' / Image twist of Y axis E of N (deg)             ',false ,head.crota2);

    remove_key(mainwindow.memo1.lines,'ROWORDER',false{all});{just remove to be sure no debayer confusion}

    mainwindow.Memo1.Lines.EndUpdate;

    add_text(mainwindow.memo1.lines,'HISTORY   ','Flipped.                                                           ');
  end;
  plot_fits(mainwindow.image1,false,true);

  Screen.Cursor:=crDefault;  { Always restore to normal }
end;


procedure Tmainwindow.MenuItem22Click(Sender: TObject);
begin
  form_inspection1.aberration_inspector1Click(nil);
end;

procedure Tmainwindow.electron_to_adu_factors1Click(Sender: TObject);
begin
  if head.egain='' then head.egain:=floattostrF(egain_default,FFgeneral,3,3);
  head.egain:=InputBox('factor e-/ADU, unbinned?',
  'At unity gain this factor shall be 1'+#10
  ,head.egain);
  egain_default:=strtofloat2(head.egain);//for next file load. Works with either dot (from header) or komma as decimal separator

  egain_extra_factor:=round(strtofloat(InputBox('Additional conversion factor for an unbinned sensor',
  'For a 12 bit sensor with an output range [0..65535] enter 16'+#10+
  'For a 12 bit sensor with an output range [0. . 4096] enter 1'+#10+
  'For a 14 bit sensor with an output range [0..65535] enter 4'+#10+
  'For a 14 bit sensor with an output range [0..16384] enter 1'+#10+
  'For a 16 bit sensor with an output range [0..65535] enter 1'+#10+
  #10+
  'The bit depth of the sensor can be measured from a light using popup menu "Show statistics"'+#10
  ,inttostr(egain_extra_factor))));
end;

procedure local_color_smooth(startX,stopX,startY,stopY: integer);//local color smooth img_loaded
var
  fitsX,fitsY,dum,k,counter    : integer;
  flux,center_x,center_y,a,b,rgb, lumr : single;
  colour,mean : array[0..2] of single;
begin
  if startX>stopX then begin dum:=stopX; stopX:=startX; startX:=dum; end;{swap}
  if startY>stopY then begin dum:=stopY; stopY:=startY; startY:=dum; end;
  startX:=max(0,startX);
  startY:=max(0,startY);
  stopX:=min(stopX,length(img_loaded[0,0])-1);
  stopY:=min(stopY,length(img_loaded[0])-1);

  center_x:=(startx+stopX)/2;
  center_y:=(startY+stopY)/2;
  a:=(stopX-1-startx)/2;
  b:=(stopY-1-startY)/2;


  colour[0]:=0;
  colour[1]:=0;
  colour[2]:=0;
  mean[0]:=0;
  mean[1]:=0;
  mean[2]:=0;

  counter:=0;

  //mean background
  for fitsY:=startY to stopY-1 do
  for fitsX:=startX to stopX-1 do
  begin
    if sqr(fitsX-center_X)/sqr(a) +sqr(fitsY-center_Y)/sqr(b)>1 then // standard equation of the ellipse, out side ellipse
    begin
      for k:=0 to head.naxis3-1 do {do all colors}
       mean[k]:=mean[k]+img_loaded[k,fitsY,fitsX];
       counter:=counter+1;
    end;
  end;
  if counter=0 then exit;
  for k:=0 to head.naxis3-1 do mean[k]:=mean[k]/counter;

  //mean colour
  for fitsY:=startY to stopY-1 do
  for fitsX:=startX to stopX-1 do
  begin
    if sqr(fitsX-center_X)/sqr(a) +sqr(fitsY-center_Y)/sqr(b)<1 then // standard equation of the ellipse, within the ellipse
    begin
      for k:=0 to head.naxis3-1 do {do all colors}
      begin
        colour[k]:=colour[k]+img_loaded[k,fitsY,fitsX]-mean[k];
      end;
    end;
  end;

  rgb:=colour[0]+colour[1]+colour[2]+0.00001; {mean pixel flux. Factor 0.00001, prevent dividing by zero}

  for fitsY:=startY to stopY-1 do
  for fitsX:=startX to stopX-1 do
  begin
    if sqr(fitsX-center_X)/sqr(a) +sqr(fitsY-center_Y)/sqr(b)<1 then // standard equation of the ellipse, within the ellipse
    begin
      flux:=(img_loaded[0,fitsY,fitsX]-mean[0]
            +img_loaded[1,fitsY,fitsX]-mean[1]
            +img_loaded[2,fitsY,fitsX]-mean[2]);//flux of one pixel


//        strongest_colour_local:=max(red,max(green,blue));
//        top:=bg + strongest_colour_local*(flux/rgb);{calculate the highest colour value}
//        if top>=65534.99 then flux:=flux-(top-65534.99)*rgb/strongest_colour_local;{prevent values above 65535}

      {apply average colour to pixel}
      lumr:=flux/rgb;
      img_loaded[0,fitsY,fitsX]:={new_noise[k]}+ mean[0]+colour[0]*lumr;
      img_loaded[1,fitsY,fitsX]:={new_noise[k]}+ mean[1]+colour[1]*lumr;
      img_loaded[2,fitsY,fitsX]:={new_noise[k]}+ mean[2]+colour[2]*lumr;

    end;
  end;
end;


procedure Tmainwindow.localcoloursmooth2Click(Sender: TObject);
begin
  if ((head.naxis3<>3) or (head.naxis=0)) then exit;
  if  ((abs(stopX-startX)>2)and (abs(stopY-starty)>2)) then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    backup_img;
    local_color_smooth(startX,stopX,startY,stopY);

    plot_fits(mainwindow.image1,false,true);
    Screen.Cursor:=crDefault;
  end{fits file}
  else
  application.messagebox(pchar('No area selected! Hold the right mouse button down while selecting an area.'),'',MB_OK);
end;

procedure Tmainwindow.fittowindow1Click(Sender: TObject);
begin
  mainwindow.FormResize(nil);
end;



procedure Tmainwindow.move_images1Click(Sender: TObject);
var
  I    : integer;
  succ,err : boolean;
  thepath:string;
  headx : theader;
  img_temp : image_array;
begin
  OpenDialog1.Title := 'Select multiple files to move';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=dialog_filter_fits_tif;
  opendialog1.initialdir:=ExtractFileDir(filename2);
  esc_pressed:=false;
  if OpenDialog1.Execute then
  begin
    SelectDirectoryDialog1.Title := 'Select destination root directory. Files will be placed in new directory .\name, date';
    SelectDirectoryDialog1.InitialDir:=opendialog1.initialdir;//image_store_path;
    esc_pressed:=false;
    err:=false;
    if SelectDirectoryDialog1.Execute then
    begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        progress_indicator(100*i/(count),' Moving');{show progress}
        Application.ProcessMessages;
        if esc_pressed then begin err:=true; break; end;
        filename2:=Strings[I];
        mainwindow.caption:=filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count);
        if load_fits(filename2,true{light},false {data},false {update memo},0,memox,headx,img_temp) then {load image success}
        begin
          date_to_jd(headx.date_obs,headx.date_avg,headx.exposure);{convert date-obs to jd_start, jd_mid}

          if jd_start>2400000 then {valid JD}
          begin
            jd_start:=jd_start-(GetLocalTimeOffset/(24*60));//convert to local time.
            jd_start:=jd_start-0.5; //move 12 hour earlier to get date beginning night
            thepath:=RemoveSpecialChars(object_name)+', '+copy(JDtoDate(jd_start),1,10)+', '+headx.filter_name;// the path without special characters

            {$ifdef mswindows}
            thepath:=SelectDirectoryDialog1.filename+'\'+thepath;
            if DirectoryExists(thepath)=false then createDir(thePath);
            succ:=renamefile(filename2,thepath+'\'+extractfilename(filename2));//rename is the same as movefile other solution would be succ:=movefile(pchar(filename2),pchar(thepath+'\'+extractfilename(filename2)));
            {$else} {Linux, Darwin}
            thepath:=SelectDirectoryDialog1.filename+'/'+thepath;
            succ:=fileutil.copyfile(filename2,thepath+'/'+extractfilename(filename2), [cffPreserveTime,cffCreateDestDirectory]); //For mulitiple partitions. Renamefile works only for one partition in Linux
            if succ then
               succ:=sysutils.deletefile(filename2);
            {$endif}
          end
          else
          begin
            memo2_message('Error decoding Julian day!');
            succ:=false;
          end;
          if succ=false then err:=true;//set error flag
        end;
      end; //for loop

      if err=false then mainwindow.caption:='Completed, all files moved.'
      else
      mainwindow.caption:='Finished, files date set but with errors or stopped!';
    except
    end;

    end;
    Screen.Cursor:=crDefault;  { Always restore to normal }
    progress_indicator(-100,'');{progresss done}
  end;
end;


procedure Tmainwindow.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1MouseDown(Sender,Button,Shift, X-image1.left, Y-image1.top);//transfer mouse down to image1
end;


procedure Tmainwindow.set_modified_date1Click(Sender: TObject);
var
  I    : integer;
  err : boolean;
  headx : theader;
  img_temp : image_array;
begin
  OpenDialog1.Title := 'Select multiple FITS files to set "modified date" to DATE-OBS';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';
  esc_pressed:=false;
  opendialog1.initialdir:=ExtractFileDir(filename2);
  esc_pressed:=false;
  err:=false;
  if OpenDialog1.Execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    try { Do some lengthy operation }
      with OpenDialog1.Files do
      for I := 0 to Count - 1 do
      begin
        progress_indicator(100*i/(count),' Solving');{show progress}
        Application.ProcessMessages;
        if esc_pressed then begin err:=true; break; end;
        filename2:=Strings[I];
        mainwindow.caption:=filename2+' file nr. '+inttostr(i+1)+'-'+inttostr(Count);
        if load_fits(filename2,true{light},false {data},false {update memo},0,memox,headx,img_temp) then {load image success}
        begin
          date_to_jd(headx.date_obs,headx.date_avg,headx.exposure);{convert date-obs to jd_start, jd_mid}
          if jd_start>2400000 then {valid JD}
          begin
            jd_start:=jd_start-(GetLocalTimeOffset/(24*60))+headx.exposure/(24*3600);//correct for timezone and exposure time
            if FileSetDate(filename2,DateTimeToFileDate(jd_start-2415018.5))<0 then  { filedatatodatetime counts from 30 dec 1899.}
              err:=true;
          end
          else
          begin
            memo2_message('Error decoding Julian day!');
            err:=true;
          end;
        end;
      end;

      if err=false then mainwindow.caption:='Completed, all files dates set.'
      else
      mainwindow.caption:='Finished, files date set but with errors or stopped!';
    except
    end;
    Screen.Cursor:=crDefault;  { Always restore to normal }
    progress_indicator(-100,'');{progresss done}
  end;
end;


procedure Tmainwindow.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  esc_pressed:=true;{stop processing. Required for reliable stopping by APT}
  save_settings2;
end;


procedure Tmainwindow.Export_image1Click(Sender: TObject);
var
  filename3:ansistring;
  img_temp : image_array;
begin
  filename3:=ChangeFileExt(FileName2,'');
  savedialog1.filename:=filename3;
  savedialog1.initialdir:=ExtractFilePath(filename3);

  if head.naxis3>1 then savedialog1.Filter := 'PNG 16 bit stretched|*.png|PNG 16 bit|*.png|TIFF 16 bit stretched|*.tif|TIFF 16 bit|*.tif|TIFF 32 bit|*.tif|PPM 16 bit stretched|*.ppm;|PPM 16 bit|*.ppm|PFM 32 bit float|*.pfm'
                   else savedialog1.Filter := 'PNG 16 bit stretched|*.png|PNG 16 bit|*.png|TIFF 16 bit stretched|*.tif|TIFF 16 bit|*.tif|TIFF 32 bit|*.tif|PGM 16 bit stretched|*.pgm;|PGM 16 bit|*.pgm|PFM 32 bit float|*.pfm';
  savedialog1.filterindex:=export_index; {default 3 tiff stretched}
  if savedialog1.execute then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

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
        save_tiff16(img_temp,mainwindow.memo1.lines,ChangeFileExt(savedialog1.filename,'.tif'),flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=4 then
        save_tiff16(img_loaded,mainwindow.memo1.lines,ChangeFileExt(savedialog1.filename,'.tif'),flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=5 then
      save_tiff_96(img_loaded,ChangeFileExt(savedialog1.filename,'.tif'),mainwindow.memo1.text {store full header in TIFF description} ,flip_horizontal1.checked,flip_vertical1.checked) {old uncompressed routine in unit_tiff}
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
        save_tiff16(img_temp,mainwindow.memo1.lines,ChangeFileExt(savedialog1.filename,'.tif'),flip_horizontal1.checked,flip_vertical1.checked);
      end
      else
      if savedialog1.filterindex=4 then
      save_tiff16(img_loaded,mainwindow.memo1.lines,ChangeFileExt(savedialog1.filename,'.tif'),flip_horizontal1.checked,flip_vertical1.checked)
      else
      if savedialog1.filterindex=5 then
        save_tiff_32(img_loaded,ChangeFileExt(savedialog1.filename,'.tif'),mainwindow.memo1.text {store full header in TIFF desciption} ,flip_horizontal1.checked,flip_vertical1.checked){old uncompressed routine in unit_tiff}
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

    export_index:=savedialog1.filterindex;{remember}
    Screen.Cursor:=crDefault;
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


procedure Tmainwindow.solve_button1Click(Sender: TObject);
begin
  astrometric_solve_image1Click(Sender);
end;


procedure Tmainwindow.Stackimages1Click(Sender: TObject);
begin
  listviews_begin_update; {speed up making stackmenu visible having a many items}

  stackmenu1.windowstate:=wsNormal;
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
    save_fits(img_loaded,mainwindow.memo1.lines,savedialog1.filename,-32,false)
    else
    if SaveDialog1.FilterIndex=2 then
    save_fits(img_loaded,mainwindow.memo1.lines,savedialog1.filename,16,false)
    else
    if SaveDialog1.FilterIndex=3 then
    begin
      if ((nrbits=8) or (IDYES= Application.MessageBox('8 bit will reduce image quality. Select yes to continue', 'Save as 8 bit FITS', MB_ICONQUESTION + MB_YESNO) )) then {ask queastion if nrbits is reduced}
        save_fits(img_loaded,mainwindow.memo1.lines,savedialog1.filename,8,false);
    end
    else
    if SaveDialog1.FilterIndex=4 then {special naxis1=3}
    begin
      if ((nrbits=8) or (IDYES= Application.MessageBox('8 bit will reduce image quality. Select yes to continue', 'Save as 8 bit FITS', MB_ICONQUESTION + MB_YESNO) )) then {ask queastion if nrbits is reduced}
        save_fits(img_loaded,mainwindow.memo1.lines,savedialog1.filename,24,false);
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
  if head.naxis<>0 then
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
