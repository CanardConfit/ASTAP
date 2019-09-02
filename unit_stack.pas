unit unit_stack;
{Copyright (C) 2017,2018,2019 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This program is free software: you can redistribute it and/or modify
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

interface
uses
 {$IFDEF fpc}
 {$else} {delphi}
  {$endif}
 {$ifdef mswindows}
  Windows,
   {$IFDEF fpc}{mswindows & FPC}
   {$else} {delphi}
    system.Win.TaskbarCore, Vcl.ImgList,
 {$endif}
 {$else} {unix}
  LCLType, {for vk_...}
  unix, {for fpsystem}
 {$endif}
 {Messages, }SysUtils, Variants,Classes, Graphics,
 Controls, Forms, Dialogs, ComCtrls, StdCtrls,
 math, ExtCtrls, Menus, Buttons,
 LCLIntf,{for for getkeystate, selectobject, openURL}
 clipbrd, Types,strutils,
 astap_main;

type
  { Tstackmenu1 }
  Tstackmenu1 = class(TForm)
    actual_search_distance1: TLabel;
    add_substract1: TComboBox;
    analyseblink1: TButton;
    analysephotometry1: TButton;
    analysephotmetrymore1: TButton;
    annotated_jpg1: TCheckBox;
    add_noise1: TButton;
    astrometry_extra_options1: TComboBox;
    blink_stop2: TButton;
    blink_unaligned_multi_step1: TButton;
    clear_astrometric_solutions1: TButton;
    export_aligned_files1: TButton;
    edit_noise1: TEdit;
    GroupBox3: TGroupBox;
    Label49: TLabel;
    mark_outliers_upto1: TComboBox;
    Label19: TLabel;
    more_indication1: TLabel;
    photometry_binx2: TButton;
    help_photometry1: TLabel;
    help_blink1: TLabel;
    Label_bin_oversampled1: TLabel;
    list_to_clipboard7: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    photometry_button1: TButton;
    blink_button4: TButton;
    photometry_stop1: TButton;
    browse_photometry1: TButton;
    clear_photometry_alignment1: TButton;
    clear_photometry_list1: TButton;
    ColorDialog1: TColorDialog;
    extend_object_name_with_time_observation1: TMenuItem;
    listview7: TListView;
    MenuItem19: TMenuItem;
    list_to_clipboard6: TMenuItem;
    nr_total_photometry1: TLabel;
    osc_colour_smooth1: TCheckBox;
    gradient_filter_factor1: TEdit;
    Label40: TLabel;
    apply_vertical_gradient1: TButton;
    GroupBox_equalise_tool2: TGroupBox;
    PopupMenu7: TPopupMenu;
    removeselected7: TMenuItem;
    renametobak7: TMenuItem;
    select7: TMenuItem;
    selectall3: TMenuItem;
    selectall4: TMenuItem;
    selectall6: TMenuItem;
    selectall2: TMenuItem;
    selectall1: TMenuItem;
    noisefilter_blur1: TComboBox;
    apply_background_noise_filter1: TButton;
    GroupBox16: TGroupBox;
    help_uncheck_outliers1: TLabel;
    Label55: TLabel;
    Label64: TLabel;
    sd_factor_list1: TComboBox;
    noisefilter_sd1: TComboBox;
    selectall7: TMenuItem;
    tab_photometry1: TTabSheet;
    uncheck_outliers1: TCheckBox;
    file_to_add1: TButton;
    GroupBox6: TGroupBox;
    image_to_add1: TLabel;
    apply_file1: TButton;
    reset_factors1: TButton;
    bayer_pattern1: TComboBox;
    downsample_for_solving1: TComboBox;
    downsample_solving_label1: TLabel;
    binning_for_solving_label2: TLabel;
    auto_background_level1: TButton;
    equalise_box_size1: TComboBox;
    apply_get_background1: TButton;
    calculated_scale1: TLabel;
    smart_colour_smooth_button1: TButton;
    smart_smooth_width1: TComboBox;
    GroupBox12: TGroupBox;
    GroupBox2: TGroupBox;
    help_osc_menu1: TLabel;
    Label26: TLabel;
    list_to_clipboard1: TMenuItem;
    apply_remove_background_colour1: TButton;
    commandline_bin1: TComboBox;
    commandline_saveasfits1: TCheckBox;
    cygwin1: TComboBox;
    field1: TLabel;
    focallength1: TEdit;
    force_oversize1: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox11: TGroupBox;
    GroupBox_astrometric_solver_settings1: TGroupBox;
    GroupBox_astrometry_net1: TGroupBox;
    GroupBox_star_alignment_settings1: TGroupBox;
    help_astrometric_solving1: TLabel;
    keep_console_open1: TCheckBox;
    Label13: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label28: TLabel;
    Label36: TLabel;
    Label48: TLabel;
    Label50: TLabel;
    Label51: TLabel;
    Label53: TLabel;
    limit_area1: TCheckBox;
    limit_pixelsize1: TCheckBox;
    max_fov1: TComboBox;
    max_stars1: TComboBox;
    panel_astrometrynet1: TPanel;
    Panel_solver1: TPanel;
    Panel_star_detection1: TPanel;
    pixelsize1: TEdit;
    extract_background_box_size1: TComboBox;
    sigma_factor_remove_background_colourR1: TComboBox;
    sigma_factor_remove_background_colourG1: TComboBox;
    sigma_factor_remove_background_colourB1: TComboBox;
    tetrahedron_tolerance1: TComboBox;
    radius_search1: TEdit;
    remove_solver_files1: TCheckBox;
    search_area1: TEdit;
    search_fov1: TComboBox;
    show_console1: TCheckBox;
    show_tetrahedrons1: TBitBtn;
    solve1: TButton;
    Label4: TLabel;
    solve_show_log1: TCheckBox;
    star_database1: TEdit;
    star_level_colouring1: TComboBox;
    Button3: TButton;
    GroupBox14: TGroupBox;
    blink_button2: TButton;
    blink_stop1: TButton;
    artificial_image_gradient1: TCheckBox;
    Equalise_background1: TCheckBox;
    nr_total_bias1: TLabel;
    apply_create_gradient1: TButton;
    clear_blink_alignment1: TButton;
    create_test_image_stars1: TButton;
    GroupBox_test_images1: TGroupBox;
    hfd_simulation1: TComboBox;
    stack_button1: TBitBtn;
    filter_artificial_colouring1: TComboBox;
    RGB_filter1: TComboBox;
    Label63: TLabel;
    sd_factor_blink1: TComboBox;
    browse_blink1: TButton;
    test_pattern1: TButton;
    blink_button1: TButton;
    align_blink1: TCheckBox;
    blink_star_filter1: TCheckBox;
    clear_blink_list1: TButton;
    demosaic_method1: TComboBox;
    GroupBox8: TGroupBox;
    Label12: TLabel;
    Label38: TLabel;
    green_filter_add1: TEdit;
    blue_filter_add1: TEdit;
    Label47: TLabel;
    Label56: TLabel;
    Label57: TLabel;
    Label58: TLabel;
    Label59: TLabel;
    Label60: TLabel;
    Label61: TLabel;
    Label62: TLabel;
    listview6: TListView;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    nr_total_blink1: TLabel;
    nr_total_flats1: TLabel;
    nr_total_darks1: TLabel;
    make_osc_color1: TCheckBox;
    MenuItem15: TMenuItem;
    PopupMenu6: TPopupMenu;
    red_filter_add1: TEdit;
    removeselected6: TMenuItem;
    renametobak6: TMenuItem;
    rr1: TEdit;
    rb1: TEdit;
    gr1: TEdit;
    gb1: TEdit;
    br1: TEdit;
    bb1: TEdit;
    extra_star_supression_diameter1: TComboBox;
    select6: TMenuItem;
    tab_blink1: TTabSheet;
    undo_button10: TBitBtn;
    undo_button11: TBitBtn;
    undo_button13: TBitBtn;
    undo_button14: TBitBtn;
    undo_button15: TBitBtn;
    undo_button6: TBitBtn;
    undo_button7: TBitBtn;
    undo_button8: TBitBtn;
    undo_button9: TBitBtn;
    unselect6: TMenuItem;
    unselect7: TMenuItem;
    use_astrometry_internal1: TRadioButton;
    use_manual_alignment1: TRadioButton;
    apply_horizontal_gradient1: TButton;
    Viewimage6: TMenuItem;
    Viewimage7: TMenuItem;
    write_log1: TCheckBox;
    new_height1: TLabel;
    new_height2: TLabel;
    mosaic_box1: TGroupBox;
    Label37: TLabel;
    resize_factor1: TComboBox;
    add_valueB1: TEdit;
    add_valueG1: TEdit;
    add_valueR1: TEdit;
    Analyse1: TButton;
    analysedarksButton2: TButton;
    analyseflatsButton3: TButton;
    analyseflatdarksButton4: TButton;
    drop_size1: TComboBox;
    drizzle1: TCheckBox;
    apply_gaussian_filter1: TButton;
    auto_background1: TCheckBox;
    Bias: TTabSheet;
    blue_filter1: TEdit;
    blue_filter2: TEdit;
    bg1: TEdit;
    blur_factor1: TComboBox;
    dark_sport_filter1: TButton;
    gridlines1: TCheckBox;
    ignore_header_solution1: TCheckBox;
    Label25: TLabel;
    Label27: TLabel;
    Label52: TLabel;
    Label54: TLabel;
    listview3: TListView;
    listview4: TListView;
    help_astrometric_alignment1: TLabel;
    powerdown_enabled1: TCheckBox;
    browse1: TButton;
    browse_bias1: TButton;
    browse_darks1: TButton;
    browse_flats1: TButton;
    Button_free_resize_fits1: TButton;
    classify_dark_exposure1: TCheckBox;
    classify_dark_temperature1: TCheckBox;
    classify_flat_filter1: TCheckBox;
    clear_dark_list1: TButton;
    clear_image_list1: TButton;
    clear_selection2: TButton;
    clear_selection3: TButton;
    Darks: TTabSheet;
    ddp_filter1: TRadioButton;
    ddp_filter2: TRadioButton;
    apply_dpp_button1: TButton;
    Edit_a1: TEdit;
    edit_background1: TEdit;
    Edit_gaussian_blur1: TEdit;
    edit_k1: TEdit;
    Edit_width1: TEdit;
    equalise_gaussian_filter1: TEdit;
    filter_groupbox1: TGroupBox;
    Flats: TTabSheet;
    flat_combine_method1: TComboBox;
    apply_gaussian_blur_button1: TButton;
    green_filter1: TEdit;
    green_filter2: TEdit;
    gg1: TEdit;
    GroupBox10: TGroupBox;
    groupBox_dvp1: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox_equalise_tool1: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox9: TGroupBox;
    help_stack_menu1: TLabel;
    help_pixel_math1: TLabel;
    help_stack_menu3: TLabel;
    Images: TTabSheet;
    keyword1: TMenuItem;
    changekeyword1: TMenuItem;
    changekeyword2: TMenuItem;
    changekeyword3: TMenuItem;
    changekeyword4: TMenuItem;
    keyword2: TMenuItem;
    keyword3: TMenuItem;
    keyword4: TMenuItem;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label14: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label2: TLabel;
    remove_deepsky_label1: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label39: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label_results1: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    listview1: TListView;
    listview2: TListView;
    listview5: TListView;
    luminance_filter1: TEdit;
    luminance_filter2: TEdit;
    apply_factor1: TButton;
    apply_artificial_flat_correction1: TButton;
    MenuItem14: TMenuItem;
    help_stack_menu2: TLabel;
    MenuItem13: TMenuItem;
    copypath1: TMenuItem;
    most_common_filter_radius1: TEdit;
    most_common_filter_tool1: TButton;
    multiply_blue1: TEdit;
    multiply_green1: TEdit;
    multiply_red1: TEdit;
    nr_selected1: TLabel;
    nr_total1: TLabel;
    oversize1: TEdit;
    pagecontrol1: TPageControl;
    Pixelmath1: TTabSheet;
    PopupMenu5: TPopupMenu;
    mosaic_width1: TUpDown;
    mosaic_width2: TEdit;
    use_astrometry_net1: TRadioButton;
    use_star_alignment1: TRadioButton;
    red_filter1: TEdit;
    red_filter2: TEdit;
    rg1: TEdit;
    renametobak5: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    PopupMenu2: TPopupMenu;
    PopupMenu3: TPopupMenu;
    PopupMenu4: TPopupMenu;
    removeselected2: TMenuItem;
    removeselected3: TMenuItem;
    removeselected4: TMenuItem;
    renametobak2: TMenuItem;
    renametobak3: TMenuItem;
    renametobak4: TMenuItem;
    replace_by_master_dark1: TButton;
    replace_by_master_flat1: TButton;
    Result1: TTabSheet;
    saved1: TLabel;
    save_as_new_file1: TButton;
    save_result1: TButton;
    sd_factor1: TEdit;
    select2: TMenuItem;
    select3: TMenuItem;
    select4: TMenuItem;
    luminance_filter_factor2: TEdit;
    classify_filter1: TCheckBox;
    classify_object1: TCheckBox;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    removeselected1: TMenuItem;
    green_filter_factor2: TEdit;
    blue_filter_factor2: TEdit;
    classify_groupbox1: TGroupBox;
    ImageList_colors: TImageList;
    splitRGB1: TButton;
    stack_method1: TComboBox;
    subtract_background1: TButton;
    tab_stackmethod1: TTabSheet;
    alignment1: TTabSheet;
    test_flat_mean: TButton;
    undo_button1: TBitBtn;
    undo_button2: TBitBtn;
    undo_button3: TBitBtn;
    undo_button4: TBitBtn;
    undo_button5: TBitBtn;
    undo_button_equalise_background1: TBitBtn;
    unselect2: TMenuItem;
    unselect3: TMenuItem;
    unselect4: TMenuItem;
    unselect1: TMenuItem;
    select1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Memo2: TMemo;
    ImageList2: TImageList;
    Label16: TLabel;
    PopupMenu1: TPopupMenu;
    renametobak1: TMenuItem;
    UpDown1: TUpDown;
    Viewimage1: TMenuItem;
    Label30: TLabel;
    Viewimage2: TMenuItem;
    Viewimage3: TMenuItem;
    Viewimage4: TMenuItem;
    Viewimage5: TMenuItem;
    width_UpDown1: TUpDown;
    procedure add_noise1Click(Sender: TObject);
    procedure alignment1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure align_blink1Change(Sender: TObject);
    procedure analyseblink1Click(Sender: TObject);
    procedure analysephotometry1Click(Sender: TObject);
    procedure auto_background_level1Click(Sender: TObject);
    procedure apply_background_noise_filter1Click(Sender: TObject);
    procedure blink_star_filter1Change(Sender: TObject);
    procedure blink_stop1Click(Sender: TObject);
    procedure blink_unaligned_multi_step1Click(Sender: TObject);
    procedure browse_dark1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure clear_photometric_solutions1Click(Sender: TObject);
    procedure clear_photometry_list1Click(Sender: TObject);
    procedure cygwin1DropDown(Sender: TObject);
    procedure export_aligned_files1Click(Sender: TObject);
    procedure extend_object_name_with_time_observation1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure help_blink1Click(Sender: TObject);
    procedure help_photometry1Click(Sender: TObject);
    procedure listview7CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: Boolean);
    procedure listview7CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure more_indication1Click(Sender: TObject);
    procedure photometry_binx2Click(Sender: TObject);
    procedure photometry_button1Click(Sender: TObject);
    procedure smart_colour_smooth_button1Click(Sender: TObject);
    procedure classify_filter1Click(Sender: TObject);
    procedure apply_get_background1Click(Sender: TObject);
    procedure help_osc_menu1Click(Sender: TObject);
    procedure help_uncheck_outliers1Click(Sender: TObject);
    procedure listview5CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure list_to_clipboard1Click(Sender: TObject);
    procedure make_osc_color1Click(Sender: TObject);
    procedure selectall1Click(Sender: TObject);
    procedure apply_remove_background_colour1Click(Sender: TObject);
    procedure reset_factors1Click(Sender: TObject);
    procedure search_fov1Change(Sender: TObject);
    procedure noisefilter_sd1Change(Sender: TObject);
    procedure test_pattern1Click(Sender: TObject);
    procedure blink_button1Click(Sender: TObject);
    procedure apply_create_gradient1Click(Sender: TObject);
    procedure clear_blink_alignment1Click(Sender: TObject);
    procedure clear_blink_list1Click(Sender: TObject);
    procedure clear_blink_list2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Edit_width1Change(Sender: TObject);
    procedure extra_star_supression_diameter1Change(Sender: TObject);
    procedure help_astrometric_solving1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure listview1CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: Boolean);
    procedure listview1CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure listview2Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure listview2CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: Boolean);
    procedure listview2CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure listview3CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: Boolean);
    procedure listview3CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure listview4CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: Boolean);
    procedure listview4CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure listview6CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: Boolean);
    procedure listview6CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure luminance_filter1Change(Sender: TObject);
    procedure make_osc_color1Change(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure resize_factor1Change(Sender: TObject);
    procedure analysedarksButton2Click(Sender: TObject);
    procedure analyseflatsButton3Click(Sender: TObject);
    procedure analyseflatdarksButton4Click(Sender: TObject);
    procedure changekeyword1Click(Sender: TObject);
    procedure dark_sport_filter1Click(Sender: TObject);
    procedure free_resize_fits1Click(Sender: TObject);
    procedure copypath1Click(Sender: TObject);
    procedure gridlines1Click(Sender: TObject);
    procedure help_pixel_math1Click(Sender: TObject);
    procedure help_stack_menu2Click(Sender: TObject);
    procedure help_stack_menu3Click(Sender: TObject);
    procedure listview1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sd_factor_blink1Change(Sender: TObject);
    procedure solve1Click(Sender: TObject);
    procedure splitRGB1Click(Sender: TObject);
    procedure test_flat_meanClick(Sender: TObject);
    procedure clear_dark_list1Click(Sender: TObject);
    procedure clear_image_list1Click(Sender: TObject);
    procedure help_astrometric_alignment1Click(Sender: TObject);
    procedure help_stack_menu1Click(Sender: TObject);
    procedure help_internal_alignment1Click(Sender: TObject);
    procedure removeselected1Click(Sender: TObject);
    procedure show_tetrahedrons1Click(Sender: TObject);
    procedure subtract_background1Click(Sender: TObject);
    procedure browse1Click(Sender: TObject);
    procedure save_as_new_file1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure apply_gaussian_filter1Click(Sender: TObject);
    procedure select1Click(Sender: TObject);
    procedure stack_button1Click(Sender: TObject);
    procedure browse_blink1Click(Sender: TObject);
    procedure browse_flats1Click(Sender: TObject);
    procedure browse_bias1Click(Sender: TObject);
    procedure replace_by_master_dark1Click(Sender: TObject);
    procedure replace_by_master_flat1Click(Sender: TObject);
    procedure apply_gaussian_blur_button1Click(Sender: TObject);
    procedure Analyse1Click(Sender: TObject);
    procedure apply_factor1Click(Sender: TObject);
    procedure apply_file1Click(Sender: TObject);
    procedure file_to_add1Click(Sender: TObject);
    procedure clear_selection1Click(Sender: TObject);
    procedure clear_selection2Click(Sender: TObject);
    procedure clear_selection3Click(Sender: TObject);
    procedure renametobak1Click(Sender: TObject);
    procedure listview1DblClick(Sender: TObject);
    procedure apply_dpp_button1Click(Sender: TObject);
    procedure most_common_filter_tool1Click(Sender: TObject);
    procedure undo_button2Click(Sender: TObject);
    procedure edit_background1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure undo_button_equalise_background1Click(Sender: TObject);
    procedure unselect1Click(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure focallength1Change(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure listview1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure listview1Compare(Sender: TObject; Item1, Item2: TListItem;
       Data: Integer; var Compare: Integer);
    procedure apply_artificial_flat_correction1Click(Sender: TObject);
    procedure stack_method1Change(Sender: TObject);
    procedure use_astrometry_internal1Change(Sender: TObject);
    procedure use_astrometry_net1Change(Sender: TObject);
    procedure use_star_alignment1Change(Sender: TObject);
    procedure apply_vertical_gradient1Click(Sender: TObject);
    procedure Viewimage1Click(Sender: TObject);
  private
    { Private declarations }
     Descending: Boolean;
     SortedColumn: Integer;

  public
    { Public declarations }
  end;

var
  stackmenu1: Tstackmenu1;

type
  TfileToDo = record
    name : string;
    listviewindex : integer;
  end;

var
  calc_scale:double;
  light_count,bias_counter, flat_count, flatdark_count,  file_count, dark_count, dark_exposure, dark_temperature,
  counterR,counterG, counterB,  counterRGB,counterL,
  counterRdark,counterGdark, counterBdark,  counterRGBdark,counterLdark,
  counterRflat,counterGflat, counterBflat,  counterRGBflat,counterLflat,
  counterRbias,counterGbias, counterBbias,  counterRGBbias,counterLbias,
  temperatureL,temperatureR,temperatureG,temperatureB,temperatureRGB,
  exposureR, exposureG,exposureB,exposureRGB,exposureL            : integer;
  sum_exp                                                         : double;
  referenceX,referenceY    : double;{reference position used stacking}
  ref_X, ref_Y             : double;{reference position from FITS header, used for manual stacking of colour images, second stage}
  jd                       : double;{julian day of date-obs}
  jd_sum                   : double;{sum of julian days}
  jd_start                 : double; {start observation in julian days}
  flat_filter : string;

  file_list : array of string;
  files_to_process, files_to_process_LRGB : array of  TfileToDo;{contains names to process and index to listview1}
  memo1_text : string;
  flat_norm_value  : double;

const
  image_path: string='';
  dropsize: double=0.65; {should be between 1 and 0.5}
  filter_name_changed: boolean=false;{if changed then reanalyse}
  tetrahedrons_displayed:boolean=false;{no tetrahedrons visible, so no refresh required}
  equalise_background_step: integer=1;


procedure listview_add(s0 :string);{add items to listview}
procedure listview234567_add(tl: tlistview; s0:string);
procedure update_equalise_background_step(pos1: integer);{update equalise background menu}
procedure memo2_message(s: string);{message to memo2}

//function get_background(colour: integer; img :image_array;calc_hist, calc_noise_level: boolean):double; {get background level from peek histogram}
procedure get_background(colour: integer; img :image_array;calc_hist, calc_noise_level: boolean; var background, starlevel: double); {get background and star level from peek histogram}

procedure update_stackmenu;{update stackmenu1 menus}
procedure x2mean(colors: integer; var img: image_array);{combine values of 4 pixel}
procedure x3mean(colors: integer;var img: image_array);{combine values of 9 pixel}
function create_internal_solution : boolean; {plate solving, image should be already loaded create internal solution using the internal solver}
function create_wcs_solution(filen: string): boolean; {plate solving,  check for WCS file solution and if not available create astrometry.net WCS file solution}
function load_wcs_solution(filen: string): boolean; {plate solving, load astrometry.net solution}
procedure apply_dark_flat(filter1:string; exposure1,stemperature1,width1:integer; var dcount,fcount,fdcount: integer; var flat_factor: double) ; {inline;} {apply dark, flat if required, renew if different exposure or ccd temp}
procedure smart_colour_smooth( var img: image_array; wide : integer; measurehist:boolean);{Bright star colour smooth. Combine color values of wide x wide pixels, keep luminance intact}
procedure date_obs_to_jd;{get julian day for date_obs, so the start of the observation}
function JdToDate(jd:double):string;{Returns Date from Julian Date}

implementation


uses  unit_astrometry,unit_gaussian_blur, unit_star_align, unit_astrometric_solving,unit_stack_routines,unit_annotation,unit_hjd;
{$IFDEF fpc}
  {$R *.lfm}
{$else}  {delphi}
 {$R *.lfm}
{$endif}
const
  I_object=0; {position in listview1}
  I_filter=1;
  I_result=2;
  I_bin=3;
  I_hfd=4;
  I_stardetections=5;
  I_starlevel=6;
  I_background=7;
  I_exposure=8;
  I_temperature=9;
  I_width=10;
  I_height=11;
  I_type=12;
  I_datetime=13;
  I_position=14;
  I_solution=15;
  I_esolution=16;
  I_x=17;
  I_y=18;
  I_calibration=19;
  I_focpos=20;
  I_foctemp=21;
  I_centalt=22;
  I_centaz=23;

  D_exposure=0;
  D_temperature=1;
  D_binning=2;
  D_width=3;
  D_height=4;
  D_type=5;
  D_background=6;
  D_sigma=7;

{$ifdef mswindows}
Function ShutMeDown:string;
  var
    hToken : THandle;
    tkp,p : TTokenPrivileges;
    RetLen : DWord;
    ExReply: LongBool;
    Reply : DWord;
 begin
  if OpenProcessToken(GetCurrentProcess,TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,hToken) then
  begin
    if LookupPrivilegeValue(nil,'SeShutdownPrivilege',tkp .Privileges[0].Luid) then
    begin
      tkp.PrivilegeCount := 1;
      tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      AdjustTokenPrivileges(hToken,False,tkp,SizeOf(TTokenPrivileges),p,RetLen);
      Reply := GetLastError;
      if Reply = ERROR_SUCCESS then
      begin
        ExReply:= ExitWindowsEx(EWX_POWEROFF or EWX_FORCE, 0);
        if ExReply then Result:='Shutdown Initiated'
        else
        Result:='Shutdown failed with ' + IntToStr(GetLastError);
      end;
    end;
  end;
end;
{$else} {unix}
{$endif}

function inverse_erf(x :double):double; {Inverse of erf function. Inverse of approximation formula by Sergei Winitzki. Error in result is <0.005 for sigma [0..3] Source wikipedia https://en.wikipedia.org/wiki/Error_function}
const                                   {input part of population [0..1] within, result is the standard deviation required for the input}
   a =0.147;
begin
  result:=sqrt(sqrt(sqr( (2/(pi*a)) + ln(1-x*x)/2)-(ln(1-x*x)/a) ) - (2/(pi*a) + ln(1-x*x)/2) );
end;


procedure update_stackmenu;{update stackmenu1 menus, called onshow stackmenu1}
var
  astrometry_net :boolean;
begin
  with stackmenu1 do
  begin
    {set enable/disable}
    astrometry_net:=use_astrometry_net1.checked;

    GroupBox_astrometry_net1.enabled:=astrometry_net;
    GroupBox_star_alignment_settings1.enabled:=(astrometry_net=false);
    GroupBox_astrometric_solver_settings1.enabled:=(astrometry_net=false);

    {set bevel colours}
    Panel_solver1.bevelouter:=bvNone;
    Panel_star_detection1.bevelouter:=bvNone;
    panel_astrometrynet1.bevelouter:=bvNone;
    Panel_solver1.color:=clnone;
    Panel_star_detection1.color:=clnone;
    panel_astrometrynet1.color:=clnone;

    if use_star_alignment1.checked then
    begin
       Panel_star_detection1.bevelouter:=bvSpace; {blue corner}
       Panel_star_detection1.color:=clBtnFace;
    end
    else
    if use_astrometry_internal1.checked then
    begin
      Panel_solver1.bevelouter:=bvSpace;
      Panel_solver1.color:=clBtnFace;
      Panel_star_detection1.color:=clBtnFace;
    end
    else
    if astrometry_net then
    begin
      panel_astrometrynet1.bevelouter:=bvSpace;
      panel_astrometrynet1.color:=clBtnFace;
    end;

    osc_colour_smooth1.enabled:=make_osc_color1.checked;
    bayer_pattern1.enabled:=make_osc_color1.checked;
    test_pattern1.enabled:=make_osc_color1.checked;
    demosaic_method1.enabled:=make_osc_color1.checked;
    osc_colour_smooth1.enabled:=make_osc_color1.checked;

  end;{stack menu}
end;


function GetFileSize2(p_sFilePath : string) : Int64;
var
  oFile : file of Byte;
begin
  Result := -1;
  AssignFile(oFile, p_sFilePath);
  try
    Reset(oFile);
    Result := FileSize(oFile);
  finally
    CloseFile(oFile);
  end;
end;

procedure memo2_message(s: string);{message to memo2}
begin
  stackmenu1.memo2.lines.add(TimeToStr(time)+'  '+s);
end;

procedure listview_add(s0:string);
var
  ListItem: TListItem;
  i : integer;
begin
  with stackmenu1.ListView1 do
  begin
    Items.BeginUpdate;
      ListItem := Items.Add;
      ListItem.Caption := s0;{with checkbox}
      ListItem.SubItems.Add('');
      ListItem.SubItems.Add('');
      ListItem.SubItems.Add('');
      ListItem.SubItems.Add('?');
      ListItem.SubItems.Add('?');
      ListItem.SubItems.Add('?');
      ListItem.SubItems.Add('?');
      for i:=8 to 24 do ListItem.SubItems.Add('-');
      Items[items.Count-1].Checked:=true;
    Items.EndUpdate;
  end;
end;
procedure listview234567_add(tl: tlistview; s0:string);
var
  ListItem: TListItem;
  c,k : integer;
begin
  with tl do {stackmenu.listview2}
  begin
    Items.BeginUpdate;
      ListItem := Items.Add;
      ListItem.Caption := s0;{with checkbox}
      ListItem.SubItems.Add('');{exposure}
      ListItem.SubItems.Add('');{tem}
      ListItem.SubItems.Add('');{bin}
      ListItem.SubItems.Add('');{width}
      ListItem.SubItems.Add('');{height}
      ListItem.SubItems.Add('');{type}
      ListItem.SubItems.Add(''); {filter/date time if existing. If not existing, seems to be ignored}
      ListItem.SubItems.Add('');{solution for blink}
      ListItem.SubItems.Add('');{calibration info, If not existing, seems to be ignored}

      if name=stackmenu1.listview6.name then {blink}
      begin
        ListItem.SubItems.Add('');
      end;
      if name=stackmenu1.listview7.name then {photometry}
      begin
        ListItem.SubItems.Add('');
        ListItem.SubItems.Add('');
        ListItem.SubItems.Add('');
        ListItem.SubItems.Add('');
        ListItem.SubItems.Add('');{12, stars}
        ListItem.SubItems.Add('');{13 astrometric solution }
        ListItem.SubItems.Add('');{14 photometric solution }
        ListItem.SubItems.Add('');{15 calibration}
      end;

      Items[items.Count-1].Checked:=true;
    Items.EndUpdate;
  end;
end;
procedure listview5_add(tl: tlistview; s0,s1,s2,s3,s4,s5,s6:string);
var
  ListItem: TListItem;
begin
  with tl do {stackmenu.listview5}
  begin
    Items.BeginUpdate; {stop updating}
      ListItem := Items.Add;
      ListItem.Caption := s0;{with checkbox}
      ListItem.SubItems.Add(s1);
      ListItem.SubItems.Add(s2);
      ListItem.SubItems.Add(s3);
      ListItem.SubItems.Add(s4);
      ListItem.SubItems.Add(s5);
      ListItem.SubItems.Add(s6);
    Items.EndUpdate;{start updating}
  end;
end;

procedure count_selected; {report the number of images selected in images_selected and update menu indication}
var
  c, images_selected         : integer;
begin
  images_selected:=0;
  for c:=0 to stackmenu1.ListView1.items.count-1 do
    if stackmenu1.ListView1.Items[c].Checked then inc(images_selected,1);
  stackmenu1.nr_selected1.caption:=inttostr(images_selected);{update menu info}
end;

function get_standard_deviation(backgr: double {value background}; colour : integer; img2: image_array): double;{get the background standard deviation using 10000 pixels}
var
 fitsX, fitsY,counter,stepsize : integer;
 value : double;
begin
  result:=0;
  counter:=1; {never divide by zero}
  fitsX:=15;
  stepsize:=round(height2/102);{get about 10000 samples. Use 102 rather then 100 to prevent problems with artifical generated stars which is using repeat of 100}
  while fitsX<=width2-1 do
  begin
    fitsY:=15;
    while fitsY<=height2-1 do
    begin
      value:=img2[colour,fitsX,fitsY];
      if value<backgr*2 then {not an outlier, noise should be symmetrical so should be less then twice background}
      begin
        result:=result+sqr(value-backgr);
        inc(counter);{keep record of number of pixels processed}
      end;
      inc(fitsY,stepsize);;{skip pixels for speed}
    end;
    inc(fitsX,stepsize);{skip pixels for speed}
  end;
  result:=sqrt(result/counter); {standard deviation using 1/25 of pixels above background}
end;

//function get_background(colour: integer; img :image_array;calc_hist, calc_noise_level: boolean):double; {get background level from peek histogram}
procedure get_background(colour: integer; img :image_array;calc_hist, calc_noise_level: boolean; var background, starlevel: double); {get background and star level from peek histogram}
var
  i, pixels,max_range,above,his_total : integer;
  mean  : double;
begin
  if calc_hist then
             get_hist(colour,img);{get histogram of img_loaded and his_total}

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
  if his_mean[colour]>2*background {2* most common} then
  begin
    memo2_message('Will use mean value '+inttostr(round(his_mean[colour]))+' as background rather then most common value '+inttostr(round(background)));
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
    starlevel:=starlevel-trunc(background)-1;{star level above background. Important subtract 1 for saturated images. Otherwise no stars are detected}
    {calculate noise level}
    noise_level[colour]:= round(get_standard_deviation(background,colour,img));
  end;
end;

procedure list_remove_outliers(key:string); {do statistics}
var
  hfd_mean,hfd_sd,stars_mean,stars_sd,sd_factor : double;
  c, counts,nr_good_images : integer;
  sd : string;
begin

  with stackmenu1 do
  begin
    counts:=ListView1.items.count-1;

    ListView1.Items.BeginUpdate;
    try
    {calculate means}
      c:=0;
      hfd_mean:=0;
      stars_mean:=0;

      nr_good_images:=0;
      repeat
        if ((ListView1.Items.item[c].checked) and (key=ListView1.Items.item[c].subitems.Strings[I_result])) then
        begin {checked}
          if strtofloat(ListView1.Items.item[c].subitems.Strings[I_hfd])>90 {hfd} then ListView1.Items.item[c].checked:=false {no stars, can't process this image}
          else
          begin {normal HFD value}
            hfd_mean:=hfd_mean+ strtofloat(ListView1.Items.item[c].subitems.Strings[I_hfd]);
            stars_mean:=stars_mean+ strtofloat(ListView1.Items.item[c].subitems.Strings[I_stardetections]);
            inc(nr_good_images);
          end;
        end;
        inc(c); {go to next file}
      until c>counts;
      hfd_mean:=hfd_mean/nr_good_images;
      stars_mean:=stars_mean/nr_good_images;
      if hfd_mean>7 then memo2_message('■■■■■■■■■■■■■ Hint, average HFD is large !! Alignment could not work. In case of alignment problems bin2x2 all exposures, dark, flats using the bin2x2 tool in pulldown menu tools ! ■■■■■■■■■■■■■');

      {calculate standard deviations}

      begin
        c:=0;
        hfd_sd:=0;
        stars_sd:=0;
        repeat {check all files, remove darks, bias}
          if ((ListView1.Items.item[c].checked) and (key=ListView1.Items.item[c].subitems.Strings[I_result]))then
          begin {checked}
            hfd_sd:=hfd_sd+sqr(hfd_mean- strtofloat(ListView1.Items.item[c].subitems.Strings[I_hfd]) );
            stars_sd:=stars_sd+sqr(stars_mean - strtofloat(ListView1.Items.item[c].subitems.Strings[I_stardetections]) );

          end;
          inc(c); {go to next file}
        until c>counts;
        hfd_sd:=sqrt(hfd_sd/nr_good_images);
        stars_sd:=sqrt(stars_sd/nr_good_images);
        memo2_message('Analysing group '+key+ ' for outliers.'+#9+#9+'Average HFD='+floattostrF2(hfd_mean,3,1)+', σ='+floattostrF2(hfd_sd,3,1)+#9+' Average star detections='+floattostrF2(stars_mean,3,0)+ ', σ='+floattostrF2(stars_sd,3,1));

        {remove outliers}
        sd:=stackmenu1.sd_factor_list1.Text;
        if pos('%',sd)>0 then {specified in percentage}
        begin
          sd:=StringReplace(sd,'%','',[]);
          sd_factor:=inverse_erf(strtofloat2(sd)/100);{convert percentage to standard deviation}
        end
        else sd_factor:=strtofloat2(sd);
        c:=0;
        repeat
          if ((ListView1.Items.item[c].checked) and (key=ListView1.Items.item[c].subitems.Strings[I_result])) then
          begin {checked}
            ListView1.Items.item[c].subitems.Strings[I_result]:='';{remove key, job done}
            if (strtofloat(ListView1.Items.item[c].subitems.Strings[I_hfd]) -hfd_mean)>sd_factor*hfd_sd  then
            begin {remove high HFD outliers}
              ListView1.Items.item[c].checked:=false;
              ListView1.Items.item[c].subitems.Strings[I_result]:='↑ hfd';{mark as outlier}
              ListView1.Items.item[c].SubitemImages[0]:=99; {mark as outlier using imageindex}
              memo2_message(ListView1.Items.item[c].caption+ ' unchecked due to high outlier HFD value.' );
            end
            else
            if (stars_mean- strtofloat(ListView1.Items.item[c].subitems.Strings[0+5]))>sd_factor*stars_sd  then
            begin {remove low star count outliers}
              ListView1.Items.item[c].checked:=false;
              ListView1.Items.item[c].subitems.Strings[I_result]:='↓ stars';{mark as outlier}
              ListView1.Items.item[c].SubitemImages[0]:=99; {mark as outlier using imageindex}
              memo2_message(ListView1.Items.item[c].caption+ ' unchecked due to low number of stars detected.' );
          end;
        end;
        inc(c); {go to next file}
      until c>counts;
    end;{throw outliers out}

    finally
      ListView1.Items.EndUpdate;
    end;
  end;{with stackmenu1}
end;

procedure analyse_fits(var hfd_counter : integer; var backgr, hfd_median : double; var img : image_array); {find background, number of stars, median HFD}
var
   fitsX,fitsY,size,i, j          : integer;
   hfd1,star_fwhm,snr,flux,xc,yc  :double;
   hfd_list                       :array of double;
   img_temp2  : image_array;

begin
  hfd_counter:=0;
  SetLength(hfd_list,0);{set array length to zero}

  get_background(0,img,true,true {calculate background and also star level end noise level},{var}backgr,star_level);

  if backgr>8 then
  begin
    setlength(img_temp2,1,width2,height2);{set length of image array}
    for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1  do
        img_temp2[0,fitsX,fitsY]:=0;{mark as no surveyed area}

    for fitsY:=0 to height2-1 do
    begin
      for fitsX:=0 to width2-1  do
      begin
        if (( img_temp2[0,fitsX,fitsY]=0){area not surveyed} and (img[0,fitsX,fitsY]-backgr>star_level {5*noise_level}){star}) then {new star. For analyse used sigma is 5, so not too low.}
        begin
          HFD(img,fitsX,fitsY, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if ((hfd1>0.8) {two pixels minimum} and (hfd1<=15)) then
          begin
            inc(hfd_counter);SetLength(hfd_list,hfd_counter); hfd_list[hfd_counter-1]:=hfd1;
            size:=round(5*hfd1);

            for j:=fitsY to fitsY+size do {Mark the whole star area as surveyed}
               for i:=fitsX-size to fitsX+size do
                 if ((j>=0) and (i>=0) and (j<height2) and (i<width2)) then {mark the area of the star square and prevent double detections}
                   img_temp2[0,i,j]:=1;
          end;
        end;
      end;
    end;
    if hfd_counter>0 then hfd_median:=SMedian(hfd_List) else hfd_median:=99;
  end {backgr is normal}
  else
  hfd_median:=99;{Most common value image is too low. Can not  process this image. Check camera offset setting.}

  img_temp2:=nil;{free mem}
end;

procedure Tstackmenu1.Analyse1Click(Sender: TObject);
var
  c,hfd_counter  ,i,j,counts  : integer;
  backgr, hfd_median   : double;
  Save_Cursor          : TCursor;
  green,blue,success   : boolean;
  key,ext,filename1    : string;
  firstchar            : string;
  img                  : image_array;
begin
  counts:=ListView1.items.count-1;
  if counts<=0 then
  begin
    memo2_message('Abort, no images to analyse! Browse for images, darks and flats. They will be sorted automatically.');
    exit;
  end;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  esc_pressed:=false;

  if img_loaded<>nil then memo_backup:=mainwindow.Memo1.Text;{backup fits header for later}

  green:=false;
  blue:=false;

  c:=0;
  {convert any non FITS file}
  while c<=counts {check all} do
  begin
    if ListView1.Items.item[c].checked then
    begin
      filename1:=ListView1.items[c].caption;
      ext:=uppercase(ExtractFileExt(filename1));

      if (ext='.FZ') then {cfitsio}
      begin
        memo2_message('Unpacking '+filename1);
        Application.ProcessMessages;
        if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;

        if unpack_cfitsio(filename1) then  {success unpacking}
           ListView1.items[c].caption:=filename2 {change listview name to FITS.}
        else
        begin {conversion failure}
          ListView1.Items.item[c].checked:=false;
          ListView1.Items.item[c].subitems.Strings[I_result]:='Funpack required, install!!';
        end;
      end {cfitsio}
      else
      if (check_raw_file_extension(ext)) then {raw file, convert to PGM}
      begin
        memo2_message('Converting '+filename1+' to FITS file format');
        Application.ProcessMessages;
        if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;

        if convert_raw_to_fits(filename1) then  {success converting raw to pgm file}
           ListView1.items[c].caption:=filename2 {change listview name to FITS. The filename2 is renamed in prcedure save_16_m32..}
        else
        begin {conversion failure}
          ListView1.Items.item[c].checked:=false;
          ListView1.Items.item[c].subitems.Strings[I_result]:='Conv failure!';
        end;
      end {raw}
      else
      if ((ext='.JPG') or (ext='.JPEG') or (ext='.PNG') or (ext='.TIF') or (ext='.TIFF')) then
      begin {tif,png,jpeg}
        memo2_message('Converting '+filename1+' to FITS file format');
        Application.ProcessMessages;
        if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;

        success:=load_tiffpngJPEG(filename1,img);
        if success then
        begin
          exposure:=extract_exposure_from_filename(filename1); {try to extract exposure time from filename}
          success:=save_fits(ChangeFileExt(filename1,'.fit'),16,false);
        end;
        if success then ListView1.items[c].caption:=ChangeFileExt(filename1,'.fit') {change listview name to FITS.}
        else
        begin {conversion failure}
          ListView1.Items.item[c].checked:=false;
          ListView1.Items.item[c].subitems.Strings[I_result]:='Conv failure!';
        end;
      end;

    end;{checked}
    inc(c);
  end;

  c:=0;
  repeat {check for double entries}
     i:=c+1;
     while i<=counts do
     begin
       if ListView1.items[i].caption=ListView1.items[c].caption then {double file name}
       begin
         memo2_message('Removed second entry of same file '+ListView1.items[i].caption);
         listview1.Items.Delete(i);
         dec(counts); {compensate for delete}
       end
       else
       inc(i);
     end;
    inc(c);
  until c>counts;


  counts:=ListView1.items.count-1;
  c:=0;
  repeat {check all files, remove darks, bias}
    if ((ListView1.Items.item[c].checked) and ((length(ListView1.Items.item[c].subitems.Strings[I_hfd])<=1){hfd} or (filter_name_changed)) ) then {hfd unknown, only update blank rows}
    begin {checked}
      progress_indicator(100*c/counts,' Analysing');
      Listview1.Selected :=nil; {remove any selection}
      ListView1.ItemIndex := c;{mark where we are, set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
      Listview1.Items[c].MakeVisible(False);{scroll to selected item}

      filename2:=ListView1.items[c].caption;
      Application.ProcessMessages;
      if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;


      load_fits(filename2,false {do not update RA0..},true,true,img); {load in memory}

      if fits_file=false then {failed to load}
      begin
        ListView1.Items.item[c].checked:=false;
        ListView1.Items.item[c].subitems.Strings[I_result]:='No FITS!';
      end
      else
      begin
        if pos('DARK',uppercase(imagetype))>0 then
        begin
          memo2_message('Move file '+filename2+' to tab DARKS');
          listview234567_add(listview2,filename2);{move to darks}
          listview1.Items.Delete(c);
          dec(c);{compensate for delete}
          dec(counts); {compensate for delete}
        end
        else
        if pos('FLAT',uppercase(imagetype))>0 then
        begin
          memo2_message('Move file '+filename2+' to tab FLATS');
          listview234567_add(listview3,filename2);{move to darks}
          listview1.Items.Delete(c);
          dec(c);{compensate for delete}
          dec(counts); {compensate for delete}
        end
        else
        if pos('BIAS',uppercase(imagetype))>0 then
        begin
          memo2_message('Move file '+filename2+' to tab FLAT-DARKS / BIAS');
          listview234567_add(listview4,filename2);{move to darks}
          listview1.Items.Delete(c);
          dec(c);{compensate for delete}
          dec(counts); {compensate for delete}
        end
        else
        begin {light frame}

          analyse_fits(hfd_counter,backgr, hfd_median, img); {find background, number of stars, median HFD}

          ListView1.Items.BeginUpdate;
          try
            begin
              if hfd_median>=99 then ListView1.Items.item[c].checked:=false; {no stars, can't process this image}
              ListView1.Items.item[c].subitems.Strings[I_object]:=object_name; {object name, without spaces}
              ListView1.Items.item[c].subitems.Strings[I_filter]:=filter_name; {filter name, without spaces}
              if naxis3=3 then ListView1.Items.item[c].subitems.Strings[I_filter]:='colour'; {give RGB images filter name colour}

              if AnsiCompareText(red_filter1.text,filter_name)=0 then  ListView1.Items.item[c].SubitemImages[1]:=0 else
              if AnsiCompareText(red_filter2.text,filter_name)=0 then  ListView1.Items.item[c].SubitemImages[1]:=0 else
              if AnsiCompareText(green_filter1.text,filter_name)=0 then begin ListView1.Items.item[c].SubitemImages[1]:=1; green:=true; end else
              if AnsiCompareText(green_filter2.text,filter_name)=0 then begin ListView1.Items.item[c].SubitemImages[1]:=1; green:=true; end else
              if AnsiCompareText(blue_filter1.text,filter_name)=0 then begin ListView1.Items.item[c].SubitemImages[1]:=2; blue:=true; end else
              if AnsiCompareText(blue_filter2.text,filter_name)=0 then begin ListView1.Items.item[c].SubitemImages[1]:=2; blue:=true; end else
              if AnsiCompareText(luminance_filter1.text,filter_name)=0 then  ListView1.Items.item[c].SubitemImages[1]:=4 else
              if AnsiCompareText(luminance_filter2.text,filter_name)=0 then  ListView1.Items.item[c].SubitemImages[1]:=4 else
              if naxis3=3 then  ListView1.Items.item[c].SubitemImages[1]:=3 else {RGB color}
                if filter_name<>'' then ListView1.Items.item[c].SubitemImages[1]:=7 {question mark} else
                   ListView1.Items.item[c].SubitemImages[1]:=-1;{blank}

              ListView1.Items.item[c].subitems.Strings[I_bin]:=inttostr(Xbinning)+' x '+inttostr(Ybinning); {Binning CCD}

              ListView1.Items.item[c].subitems.Strings[I_hfd]:=floattostrF2(hfd_median,0,1);
              ListView1.Items.item[c].subitems.Strings[I_stardetections]:=inttostr5(hfd_counter); {number of stars}

              ListView1.Items.item[c].subitems.Strings[I_starlevel]:=inttostr5(round(star_level));
              ListView1.Items.item[c].subitems.Strings[I_background]:=inttostr5(round(backgr));
              ListView1.Items.item[c].subitems.Strings[I_exposure]:=inttostr(round(exposure));
              if set_temperature<>999 then ListView1.Items.item[c].subitems.Strings[I_temperature]:=inttostr(set_temperature);
              ListView1.Items.item[c].subitems.Strings[I_width]:=inttostr(width2); {width}
              ListView1.Items.item[c].subitems.Strings[I_height]:=inttostr(height2);{height}
              ListView1.Items.item[c].subitems.Strings[I_type]:=imagetype;{type}
              ListView1.Items.item[c].subitems.Strings[I_datetime]:=StringReplace(date_obs,'T',' ',[]);{date/time}
              ListView1.Items.item[c].subitems.Strings[I_position]:=prepare_ra5(ra0,'h')+', '+ prepare_dec5(dec0,'d');{give internal position}

              {is internal solution available?}
              if cd1_1<>0 then
                  ListView1.Items.item[c].subitems.Strings[I_solution]:='✓' else ListView1.Items.item[c].subitems.Strings[I_solution]:='-';

              {is external solution available?}
              if stackmenu1.use_astrometry_net1.checked=true then
                if fileexists(changeFileExt(filename2,'.wcs')) then  ListView1.Items.item[c].subitems.Strings[I_esolution]:='✓' else ListView1.Items.item[c].subitems.Strings[I_esolution]:='-';
              ListView1.Items.item[c].subitems.Strings[I_calibration]:=calstat; {status calibration}
              if focus_pos<>999 then ListView1.Items.item[c].subitems.Strings[I_focpos]:=inttostr(focus_pos);
              if focus_temp<>999 then ListView1.Items.item[c].subitems.Strings[I_foctemp]:=floattostrF2(focus_temp,0,1);
              if centalt<>999 then ListView1.Items.item[c].subitems.Strings[I_centalt]:=floattostrF2(centalt,0,1);
              if centaz<>999 then ListView1.Items.item[c].subitems.Strings[I_centaz]:=floattostrF2(centaz,0,1);

            end;
          finally
            ListView1.Items.EndUpdate;
          end;
        end;{end ligt frame}
      end;{this is a fits file}
    end;{checked and hfd unknown}
    inc(c); {go to next file}
  until c>counts;

  if ((green) and (blue) and (classify_filter1.checked=false)) then memo2_message('■■■■■■■■■■■■■ Hint, colour filters detected. For colour stack set the check-mark classify by filter! ■■■■■■■■■■■■■');

  if (stackmenu1.uncheck_outliers1.checked) then
  begin
    {give list an indentification key label based on object, filter and exposure time}
    for c:=0 to ListView1.items.count-1 do
    begin
      if ListView1.Items.item[c].SubitemImages[0]=99 then {marked at outlier}
      begin
         ListView1.Items.item[c].checked:=true;{recheck outliers from previous session}
         ListView1.Items.item[c].SubitemImages[0]:=-1;{remove mark}
      end;

       if ListView1.items[c].Checked=true then
           ListView1.Items.item[c].subitems.Strings[I_result]:=
                   ListView1.Items.item[c].subitems.Strings[I_object]+'_'+{object name}
                   ListView1.Items.item[c].subitems.Strings[I_filter]+'_'+{filter}
                   ListView1.Items.item[c].subitems.Strings[I_exposure]; {exposure}
    end;

    {do statistics on each constructed key}
    repeat
      c:=0;
      key:='';
      repeat {check all files, uncheck outliers}
        if  ListView1.Items.item[c].checked then
        begin
          key:=ListView1.Items.item[c].subitems.Strings[I_result];
          if key<>'' then
             list_remove_outliers(key);
        end;
        if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
        inc(c)
      until c>counts;
    until key='';{until all keys are used}
  end;

  count_selected; {report the number of images selected in images_selected and update menu indication}

  filter_name_changed:=false; {back to normal, filter_name is not changed, so no re-analyse required}

  img:=nil; {free mem}

  if img_loaded<>nil then {try to restore original header data for image in the viewer}
  begin
    naxis3:=length(img_loaded);{nr colours}
    height2:=length(img_loaded[0,0]);{length}
    width2:=length(img_loaded[0]);{width}
    getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
    mainwindow.Memo1.Text:=memo_backup;{restore fits header}
  end;

  Screen.Cursor :=Save_Cursor;    { back to normal }
  progress_indicator(-100,'');{progresss done}

end;

procedure Tstackmenu1.browse1Click(Sender: TObject);
var
   i: integer;
begin
  OpenDialog1.Title := 'Select images to stack';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.filename:='';
  opendialog1.Filter := 'FITS files and DSLR RAW files (*.)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                        '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                        '|FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                        '|JPEG, TIFF, PNG files (*.)|*.JPG;*.JPEG;*.TIF*;*.PNG;'+
                        '|RAW files (*.)|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef';
  fits_file:=true;
  if opendialog1.execute then
  begin
    for i:=0 to OpenDialog1.Files.count-1 do
    begin
        listview_add(OpenDialog1.Files[i]);
        if  pos('_stacked',OpenDialog1.Files[i])<>0 then {do not check mark images already stacked}
        begin
          listview1.items[ListView1.items.count-1].checked:=false;
        end;
    end;
  end;
  count_selected; {report the number of images selected in images_selected and update menu indication}
end;

procedure report_results(object_to_process,stack_info :string;object_counter,colorinfo:integer);{report on tab results}
begin
  {report result in results}
  with stackmenu1 do
  begin
    listview5_add(listview5,filename2 ,object_to_process,
                                       inttostr(object_counter)+'  ' {object counter}
                                      ,stack_info
                                      ,inttostr(width2)
                                      ,inttostr(height2)
                                      ,calstat);
    ListView5.Items.item[ ListView5.Items.count-1].SubitemImages[1]:=5;{mark 2th columns as done using a stacked icon}
    ListView5.Items.item[ ListView5.Items.count-1].SubitemImages[0]:=colorinfo; {color, gray icon}
  end;
  application.processmessages;
  {end report result in results}
end;

procedure update_equalise_background_step(pos1: integer);{update equalise background menu}
begin
  with stackmenu1 do
  begin
    if ((pos1<1) or (pos1>5)) then begin pos1:=1;saved1.caption:=''; end;

    equalise_background_step:=pos1;
    undo_button_equalise_background1.enabled:=true;


    save_result1.Enabled:=false;
    remove_deepsky_label1.enabled:=false;
    most_common_filter_tool1.enabled:=false;
    apply_gaussian_filter1.enabled:=false;
    subtract_background1.enabled:=false;
    save_result1.Enabled:=false;
    save_as_new_file1.enabled:=false;

    case pos1 of
            1: begin save_as_new_file1.Enabled:=true; save_result1.Enabled:=true; remove_deepsky_label1.enabled:=true;undo_button_equalise_background1.caption:=''; end;{step 1,6}
            2: begin most_common_filter_tool1.enabled:=true;{step 3}remove_deepsky_label1.enabled:=true; undo_button_equalise_background1.caption:='1'; end;
            3: begin apply_gaussian_filter1.enabled:=true;{step 4}undo_button_equalise_background1.caption:='3'; end;
            4: begin subtract_background1.enabled:=true;{step 5}undo_button_equalise_background1.caption:='4';end;
            5: begin save_result1.Enabled:=true;{step 5}undo_button_equalise_background1.caption:='1';end;
          end;{case}
  end;
end;

procedure Tstackmenu1.save_as_new_file1Click(Sender: TObject);  {add equalised to filename}
var
  dot_pos :integer;
begin
  if Length(img_loaded)=0 then
  begin
    memo2_message('Error, no image in viewer loaded!');
    exit;
  end;
  if pos(' equalised',filename2)=0 then
  begin
    dot_pos:=length(filename2);
    repeat
      dec(dot_pos);
    until ((filename2[dot_pos]='.') or (dot_pos<=1));
    insert(' equalised',filename2,dot_pos);
  end;
  save_fits(filename2 ,-32, false);
  if fileexists(filename2) then
  begin
     saved1.caption:='Saved';
     report_results(filename2,'',0,-1{no icon});{report result in tab results}
  end
  else saved1.caption:='';
  if sender<>save_result1 then {save, step 1}
  begin
    update_equalise_background_step(equalise_background_step+1); {update menu}
  end
  else {save result, step 6}
  begin
    undo_button_equalise_background1.enabled:=false;
    undo_button_equalise_background1.caption:='';
  end;
end;

procedure Tstackmenu1.subtract_background1Click(Sender: TObject);
var fitsX, fitsY,col :integer;
   Save_Cursor:TCursor;
begin
  if fits_file=false then exit;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  backup_img;

  if load_fits(filename2,true {light},true,false{reset var},img_temp) then {success load}
  begin
    for col:=0 to naxis3-1 do {all colors}
      for fitsY:=0 to height2-1 do
       for fitsX:=0 to width2-1 do
        begin {subtract view from file}
            img_loaded[col,fitsX,fitsY]:=img_temp[col,fitsX,fitsY]-img_loaded[col,fitsX,fitsY]+1000;
        end;
    getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
    plot_fits(mainwindow.image1,false);{plot real}
  end;
  Screen.Cursor:=Save_Cursor;

  update_equalise_background_step(5 {force 5 since equalise background is set to 1 by loading fits file} );{update menu}
  Screen.Cursor:=Save_Cursor;
end;

procedure Tstackmenu1.show_tetrahedrons1Click(Sender: TObject);
var
   Save_Cursor:TCursor;
begin
  if fits_file=false then application.messagebox( pchar('First load an image in the viewer!'), pchar('No action'),MB_OK)
  else
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    if  tetrahedrons_displayed then
      plot_fits(mainwindow.image1,false); {remove tetrahedrons}
    get_background(0,img_loaded,false{histogram already available},true {unknown, calculate also noise level} ,{var}cblack,star_level);
    find_stars(img_loaded,starlist1);{find stars and put them in a list}
    find_tetrahedrons_ref;{find tetrahedrons for reference image}
    display_tetrahedrons(starlisttetrahedrons1);
    tetrahedrons_displayed:=true;

    Screen.Cursor:=Save_Cursor;
  end;
end;

procedure Tstackmenu1.help_stack_menu1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#stack_menu');
end;

procedure Tstackmenu1.help_internal_alignment1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#internal_alignment');
end;

procedure listview_removeselect(tl :tlistview);
var index,counter: integer;
begin
  index:=0;
  counter:=tl.Items.Count;
  while index<counter do
  begin
    if tl.Items[index].Selected then
    begin
      tl.Items.Delete(Index);
      //dec(index);{next file goes down in index, compensate}
      dec(counter);{one file less}
    end
    else
    inc(index); {go to next file}
  end;
end;

procedure Tstackmenu1.removeselected1Click(Sender: TObject);
begin
  if sender=removeselected1 then listview_removeselect(listview1);{from popup menu}
  if sender=removeselected2 then listview_removeselect(listview2);{from popup menu}
  if sender=removeselected3 then listview_removeselect(listview3);{from popup menu}
  if sender=removeselected4 then listview_removeselect(listview4);{from popup menu}
  if sender=removeselected6 then listview_removeselect(listview6);{from popup menu blink}
  if sender=removeselected7 then listview_removeselect(listview7);{from popup menu photometry}
end;

procedure Tstackmenu1.help_astrometric_alignment1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#astrometric_alignment');
end;

procedure Tstackmenu1.clear_image_list1Click(Sender: TObject);
begin
  ListView1.Clear;
end;

procedure Tstackmenu1.clear_dark_list1Click(Sender: TObject);
begin
  listview2.Clear
end;

procedure Tstackmenu1.FormCreate(Sender: TObject);
begin
  {$ifdef mswindows}
  {$else} {unix}
  keep_console_open1.visible:=false; {not required in Linux}
  {$endif}
end;

procedure Tstackmenu1.FormKeyPress(Sender: TObject; var Key: char);
begin
   if key=#27 then
   begin
     esc_pressed:=true;
     if use_astrometry_net1.checked then memo2_message('ESC pressed. Execution stopped. Astrometry.net will continue till finished.')
     else  memo2_message('ESC pressed. Execution stopped.')
   end;
end;

procedure Tstackmenu1.apply_gaussian_filter1Click(Sender: TObject);
var
   Save_Cursor          : TCursor;
begin
   if fits_file=false then exit;
   Save_Cursor := Screen.Cursor;
   Screen.Cursor := crHourglass;    { Show hourglass cursor }
   backup_img;
   gaussian_blur2(img_loaded,strtofloat2(equalise_gaussian_filter1.text));
   plot_fits(mainwindow.image1,false);{plot}
   Screen.Cursor:=Save_Cursor;
   update_equalise_background_step(equalise_background_step+1);{update menu}
end;

procedure listview_select(tl:tlistview);
var index: integer;
begin
 tl.Items.BeginUpdate;
 for index:=0 to tl.Items.Count-1 do
   begin
     if tl.Items[index].Selected then
     begin
       tl.Items[index].Checked:=true;
     end;
   end;
   tl.Items.EndUpdate;
end;

procedure Tstackmenu1.select1Click(Sender: TObject);
begin
   if sender=select1 then listview_select(listview1);{from popupmenu}
   if sender=select2 then listview_select(listview2);{from popupmenu}
   if sender=select3 then listview_select(listview3);{from popupmenu}
   if sender=select4 then listview_select(listview4);{from popupmenu}
   if sender=select6 then listview_select(listview6);{from popupmenu blink}
   if sender=select7 then listview_select(listview7);{from popupmenu blink}
end;


procedure Tstackmenu1.browse_bias1Click(Sender: TObject);
var
   i: integer;
begin
  OpenDialog1.Title := 'Select flat dark images';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.filename:='';
  opendialog1.Filter := 'FITS files and DSLR RAW files (*.)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                        '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                        '|FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                        '|RAW files (*.)|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef';

  fits_file:=true;
  if opendialog1.execute then
  begin
    for i:=0 to OpenDialog1.Files.count-1 do {add}
    begin
      listview234567_add(listview4,OpenDialog1.Files[i]);
    end;
  end;
end;

procedure Tstackmenu1.browse_blink1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select images to blink';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
//  opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';
  opendialog1.Filter := 'FITS files and DSLR RAW files (*.)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                        '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                        '|FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                        '|RAW files (*.)|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef';

  fits_file:=true;
  if opendialog1.execute then
  begin
    for i:=0 to OpenDialog1.Files.count-1 do {add}
    begin
      if sender=browse_blink1 then listview234567_add(listview6,OpenDialog1.Files[i])
      else
      if sender=browse_photometry1 then listview234567_add(listview7,OpenDialog1.Files[i]);

      DeleteFile(ChangeFileExt(OpenDialog1.Files[i],'.astap_solution'));{delete solution file. These are relative to a reference file which could be different}
    end;
  end;
end;

procedure Tstackmenu1.browse_flats1Click(Sender: TObject);
var
   i: integer;
begin
  OpenDialog1.Title := 'Select flat images';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.filename:='';
  opendialog1.Filter := 'FITS files and DSLR RAW files (*.)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                        '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                        '|FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                        '|RAW files (*.)|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef';

  fits_file:=true;
  if opendialog1.execute then
  begin
    for i:=0 to OpenDialog1.Files.count-1 do {add}
    begin
      listview234567_add(listview3,OpenDialog1.Files[i]);
    end;
  end;
end;


 procedure QuickSort(var A: array of Integer; iLo, iHi: Integer) ;{idea by https://www.thoughtco.com/implementing-quicksort-sorting-algorithm-in-delphi-1058220}
 var
   Lo, Hi, Pivot, T: Integer;
 begin
   Lo := iLo;
   Hi := iHi;
   Pivot := A[(Lo + Hi) div 2];
   repeat
     while A[Lo] < Pivot do Inc(Lo) ;
     while A[Hi] > Pivot do Dec(Hi) ;
     if Lo <= Hi then
     begin
       T := A[Lo];
       A[Lo] := A[Hi];
       A[Hi] := T;
       Inc(Lo) ;
       Dec(Hi) ;
     end;
   until Lo > Hi;
   if Hi > iLo then QuickSort(A, iLo, Hi) ;
   if Lo < iHi then QuickSort(A, Lo, iHi) ;
 end;


function median_background(color,size,x,y:integer): double;{find median in 3x3 matrix of img_loaded}
var i,j,count,size2,step  : integer;
    intArray : array of integer;
begin
  if (size div 2)*2=size then size:=size+1;{requires odd 3,5,7....}
  size2:=size*size;
  SetLength(intArray,size2) ;
  step:=size div 2;
  count:=0;
  begin
    for j:=y-step to  y+step do
      for i:=x-step to x+step do
      begin
        if ((i>=0) and (i<width2) and (j>=0) and (j<height2) ) then {within the boundaries of the image array}
        begin
          intArray[count]:=round(img_loaded[color,i ,j]);
          inc(count);
        end;
      end;
  end;
   //sort
  QuickSort(intArray, Low(intArray), count-1 { normally 8 for 3*3 equals High(intArray)}) ;

  result:=intArray[count div 2];  {for 3x3 matrix the median is 5th element equals in range 0..8 equals intArray[4]}
end;


procedure median_equalise(box_size  :integer);
 var
    fitsx,fitsy,i,j,col,step : integer;
    offset                   : single;
    bg                       : double;

 begin
   memo2_message('Equalising background of '+filename2);
  {equalize background}

  if (box_size div 2)*2=box_size then box_size:=box_size+1;{requires odd 3,5,7....}
  step:=box_size div 2; {for 3*3 it is 1, for 5*5 it is 2...}

   for col:=0 to naxis3-1 do {do all colours}
   begin
     get_background(col,img_loaded,true,false{do not calculate noise_level},bg,star_level); {should be about 500 for mosaic since that is the target value}
     for fitsY:=0 to height2-1 do
       for fitsX:=0 to width2-1 do
         if ((frac(fitsX/box_size)=0) and (frac(fitsy/box_size)=0)) then
         begin
           offset:=median_background(col,box_size {3x3},fitsX,fitsY)-bg;
           if ((offset<0) {and (offset>-200)}) then
           begin
             for j:=fitsy-step to  fitsy+step do
               for i:=fitsx-step to fitsx+step do
                 if ((i>=0) and (i<width2) and (j>=0) and (j<height2) ) then {within the boundaries of the image array}
                   img_loaded[col,i,j]:=img_loaded[col,i,j]-offset;
           end;
         end;
   end;{all colors}
 end;

procedure Tstackmenu1.apply_artificial_flat_correction1Click(Sender: TObject);
var
   Save_Cursor : TCursor;
   box_size  :integer;
begin
  if fits_file=true then
  begin
     Save_Cursor := Screen.Cursor;
     Screen.Cursor := crHourglass;    { Show hourglass cursor }

     backup_img;  {store array in img_backup}

     try box_size:=strtoint(equalise_box_size1.text);except end;

     median_equalise(box_size);

  //   getfits_histogram(true);{get histogram}
     plot_fits(mainwindow.image1,true);{plot real}
     Screen.Cursor:=Save_Cursor;
  end;
end;

procedure apply_factors;{apply r,g,b factors to image}
var fitsX, fitsY :integer;
    multiply_red,multiply_green,multiply_blue,add_valueR,add_valueG,add_valueB,largest,scaleR,scaleG,scaleB,dum :single;

begin

  {do factor math behind so "subtract view from file" works in correct direction}
  add_valueR:=strtofloat2(stackmenu1.add_valueR1.Text);
  add_valueG:=strtofloat2(stackmenu1.add_valueG1.Text);
  add_valueB:=strtofloat2(stackmenu1.add_valueB1.Text);

  multiply_red:=strtofloat2(stackmenu1.multiply_red1.Text);
  multiply_green:=strtofloat2(stackmenu1.multiply_green1.Text);
  multiply_blue:=strtofloat2(stackmenu1.multiply_blue1.Text);

  {prevent clamping to 65535}
  scaleR:=(65535+add_valueR)*multiply_red/65535;{range 0..1, if above 1 then final value could be above 65535}
  scaleG:=(65535+add_valueG)*multiply_green/65535;
  scaleB:=(65535+add_valueB)*multiply_blue/65535;
  largest:=scaleR;
  if scaleG>largest then largest:=scaleG;
  if scaleB>largest then largest:=scaleB;
  {use largest to scale to maximum 65535}

  if ((multiply_red<>1) or (multiply_green<>1) or (multiply_blue<>1) or (add_valueR<>0) or (add_valueG<>0)or (add_valueB<>0)) then
  begin
    for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
    begin
      dum:=img_loaded[0,fitsX,fitsY]; if dum<>0 then {signal} begin dum:=(dum+add_valueR)*multiply_red/largest;  if dum<0 then dum:=0; img_loaded[0,fitsX,fitsY]:=dum;end;

      if naxis3>1 then {colour}
      begin
        dum:=img_loaded[1,fitsX,fitsY];   if dum<>0 then {signal} begin dum:=(dum+add_valueG)*multiply_green/largest; if dum<0 then dum:=0; img_loaded[1,fitsX,fitsY]:=dum;end;
      end;
      if naxis3>2 then {colour}
      begin
        dum:=img_loaded[2,fitsX,fitsY]; if dum<>0 then {signal} begin dum:=(dum+add_valueB)*multiply_blue/largest; if dum<0 then dum:=0; img_loaded[2,fitsX,fitsY]:=dum;end;
      end;
    end;
  end;
end;

procedure Tstackmenu1.apply_factor1Click(Sender: TObject);
var
    Save_Cursor:TCursor;
begin
 if fits_file=true then
 begin
   backup_img; {move viewer data to img_backup}

   Save_Cursor := Screen.Cursor;
   Screen.Cursor := crHourglass;    { Show hourglass cursor }

   apply_factors;
   getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
   plot_fits(mainwindow.image1,false);{plot real}
   Screen.Cursor:=Save_Cursor;
  end;
end;

procedure Tstackmenu1.apply_file1Click(Sender: TObject);
var fitsX, fitsY, col,viewer_naxis3 :integer;
   Save_Cursor:TCursor;
   flat_norm_value,flat_factor,luminance,rgb : single;
   idx,old_naxis3 : integer;
begin
  if fits_file=true then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }
    backup_img; {move viewer data to img_backup}
    old_naxis3:=naxis3;

    idx:=add_substract1.itemindex;
    {add, multiply image}
    if length(image_to_add1.Caption)>3 then {file name available}
    begin
      viewer_naxis3:=naxis3;
      if load_fits(image_to_add1.Caption,true {light},true,false{reset var},img_temp) then {succes load}
      begin
        if idx=5 then {apply file as flat}
        begin
          flat_norm_value:=0;
          for fitsY:=-2 to 3 do {do even times, 6x6}
             for fitsX:=-2 to 3 do
               flat_norm_value:=flat_norm_value+img_temp[0,fitsX+(width2 div 2),fitsY +(height2 div 2)];
          flat_norm_value:=round(flat_norm_value/36);
          for fitsY:=1 to height2 do
            for fitsX:=1 to width2 do
            begin
             for col:=0 to old_naxis3-1 do {do all colors. Viewer colours are stored in old_naxis3 by backup}
             begin
               flat_factor:=flat_norm_value/(img_temp[min(col,naxis3-1),fitsX-1,fitsY-1]+0.001); {This works both for color and mono flats. Bias should be combined in flat}
                img_loaded[col,fitsX-1,fitsY-1]:=img_loaded[col,fitsX-1,fitsY-1]*flat_factor ;
              end;
            end;
          naxis3:=old_naxis3;{could be changed by load file}
        end {apply file as flat}

        else
        for col:=0 to naxis3-1 do {all colors}
          for fitsY:=0 to height2-1 do
            for fitsX:=0 to width2-1 do
            begin
             if idx=0 then {add}
               img_loaded[col,fitsX,fitsY]:=img_temp[col,fitsX,fitsY]+img_loaded[col,fitsX,fitsY]
             else
               if idx=1 then {viewer minus file}
                 img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX,fitsY]{viewer} - img_temp[col,fitsX,fitsY]{file}
             else
             if idx=2 then {viewer minus file +1000}
               img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX,fitsY]{viewer} - img_temp[col,fitsX,fitsY]{file} +1000
             else
             if idx=3 then {file minus viewer}
               img_loaded[col,fitsX,fitsY]:=img_temp[col,fitsX,fitsY]{file} - img_loaded[col,fitsX,fitsY]{viewer}
             else
             if idx=4 then {file minus viewer}
               img_loaded[col,fitsX,fitsY]:=img_temp[col,fitsX,fitsY]{file} - img_loaded[col,fitsX,fitsY]{viewer}+1000;

            end;


      end;{file loaded}
    end;
    img_temp:=nil;
    getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
    plot_fits(mainwindow.image1,false);{plot real}
    Screen.Cursor:=Save_Cursor;
  end;
end;


procedure Tstackmenu1.undo_button2Click(Sender: TObject);
begin
  if mainwindow.Undo1.enabled then restore_img;
end;

procedure Tstackmenu1.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  auto_background1.Checked:=false;
end;


procedure Tstackmenu1.apply_dpp_button1Click(Sender: TObject);
var
   Save_Cursor : TCursor;
   fitsx,fitsy,col      : integer;
   a_factor,k_factor,bf,min,colr : single;
   bg                            : double;
begin
  if fits_file=true then
  begin
     Save_Cursor := Screen.Cursor;
     Screen.Cursor := crHourglass;    { Show hourglass cursor }
     mainwindow.stretch1.Text:='off';{switch off gamma}

     a_factor:=strtofloat2(edit_a1.Text);
     k_factor:=strtofloat2(edit_k1.Text);
      backup_img;  {store array in img_backup}
     {find background}
     if auto_background1.Checked then
     begin
       get_background(0,img_loaded,true,false{do not calculate noise_level},bg,star_level);
       min:=bg*0.9;
       edit_background1.Text:=floattostrf(min,ffgeneral, 4, 1); //floattostr2(min);

       for col:=0 to naxis3-1 do {all colors}
       for fitsY:=0 to height2-1 do
          for fitsX:=0 to width2-1 do
             img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX,fitsY]-min; {subtract background}
     end
     else
     min:=strtofloat2(edit_background1.Text);

     if ddp_filter2.Checked then gaussian_blur2(img_loaded,strtofloat2(Edit_gaussian_blur1.text));

     for col:=0 to naxis3-1 do {all colors}
     for fitsY:=0 to height2-1 do
        for fitsX:=0 to width2-1 do
        begin
           bf:=(img_loaded[0,fitsX,fitsY] +a_factor);
           if bf<0.00001 then colr:=0 else
           begin
             colr:= k_factor*a_factor*(img_backup[col,fitsX,fitsY]-min)/bf ;
             if colr>65535 then colr:=65535;
             if colr<0 then colr:=0;
           end;
           img_loaded[col,fitsX,fitsY]:=colr;
        end;
     apply_dpp_button1.Enabled:=false;
     getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
     plot_fits(mainwindow.image1,true);{plot real}

     Screen.Cursor:=Save_Cursor;
  end;
end;

procedure apply_most_common(sourc,dest: image_array; radius: integer);  {apply most common filter on first array and place result in second array}
var
   fitsX,fitsY,i,j,k,x,y,x2,y2,diameter,most_common,colors3,height3,width3 : integer;
begin
  diameter:=radius*2;
  colors3:=length(sourc);{nr colours}
  height3:=length(sourc[0,0]);{length}
  width3:=length(sourc[0]);{width}

  for k:=0 to colors3-1 do {do all colors}
  begin

   for fitsY:=0 to round((height3-1)/diameter) do
     for fitsX:=0 to round((width3-1)/diameter) do
     begin
       x:=fitsX*diameter;
       y:=fitsY*diameter;
       most_common:=get_most_common(sourc,k,x-radius,x+radius-1,y-radius,y+radius-1,32000);
       for i:=-radius to +radius-1 do
         for j:=-radius to +radius-1 do
         begin
           x2:=x+i;
           y2:=y+j;
           if ((x2>=0) and (x2<width3) and (y2>=0) and (y2<height3))  then
           dest[k,x2,y2]:=most_common;
         end;
     end;
  end;{K}
end;

procedure Tstackmenu1.most_common_filter_tool1Click(Sender: TObject);
var
   radius               : integer;
   Save_Cursor          : TCursor;

begin
  if Length(img_loaded)=0 then
  begin
    memo2_message('Error, no image in viewer loaded!');
    exit;
  end;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  backup_img; {move copy to img_backup}

  try radius:=strtoint(stackmenu1.most_common_filter_radius1.text);except end;

  apply_most_common(img_backup,img_loaded,radius); {apply most common filter on first array and place result in second array}

  plot_fits(mainwindow.image1,false);{plot real}
  Screen.Cursor:=Save_Cursor;
  update_equalise_background_step(equalise_background_step+1);{update menu}
end;


procedure Tstackmenu1.edit_background1Click(Sender: TObject);
begin
  auto_background1.checked:=false;
end;



procedure Tstackmenu1.clear_selection3Click(Sender: TObject);
begin
  listview4.Clear;
end;

procedure listview_rename_bak(tl : tlistview);
var index,counter: integer;
begin
  index:=0;
  counter:=tl.Items.Count;
  while index<counter do
  begin
    if  tl.Items[index].Selected then
    begin
      filename2:=tl.items[index].caption;
      deletefile(changeFileExt(filename2,'.bak'));{delete *.bak left over from astrometric solution}
      if RenameFile(filename2,ChangeFileExt(filename2,'.bak')) then
      begin
         tl.Items.Delete(Index);
         dec(index);{next file goes down in index, compensate}
         dec(counter);{one file less}
      end;
    end;
    inc(index); {go to next file}
  end;
end;

procedure listview_update_keyword(tl : tlistview; keyw,value :string );{update key word of multiple files}
var index,counter: integer;
begin
  index:=0;
  counter:=tl.Items.Count;
  while index<counter do
  begin
    if  tl.Items[index].Selected then
    begin
      filename2:=tl.items[index].caption;
      if load_image(true,true {plot}) then {load and center}
      begin
        while length(value)<18 do value:=value+' ';{increase length to 18, one space will be added  in front later}

        while length(keyw)<8 do keyw:=keyw+' ';{increase length to 8}
        keyw:=copy(keyw,1,8);{decrease if longer then 8}

        update_text(keyw+'=',#39+value+#39+'                                                  ');

        if nrbits=16 then
        save_fits(filename2,16,true)
         else
        save_fits(filename2,-32,true);
      end
      else
      beep;{image not found}
    end;
    inc(index); {go to next file}
  end;
end;

procedure Tstackmenu1.renametobak1Click(Sender: TObject);
begin
  if sender=renametobak1 then listview_rename_bak(listview1);{from popupmenu}
  if sender=renametobak2 then listview_rename_bak(listview2);{from popupmenu}
  if sender=renametobak3 then listview_rename_bak(listview3);{from popupmenu}
  if sender=renametobak4 then listview_rename_bak(listview4);{from popupmenu}
  if sender=renametobak5 then listview_rename_bak(listview5);{from popupmenu}
  if sender=renametobak6 then listview_rename_bak(listview6);{from popupmenu blink}
  if sender=renametobak7 then listview_rename_bak(listview7);{from popupmenu photometry}
end;

procedure Tstackmenu1.clear_selection2Click(Sender: TObject);
begin
  listview3.Clear
end;

procedure Tstackmenu1.file_to_add1Click(Sender: TObject);
begin
  OpenDialog1.Title := 'Select image';
  OpenDialog1.Options := [ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS';
  fits_file:=true;
  if opendialog1.execute then
  begin
     image_to_add1.caption:=OpenDialog1.Files[0];
  end;
end;

procedure Tstackmenu1.clear_selection1Click(Sender: TObject);
begin

end;

procedure Tstackmenu1.focallength1Change(Sender: TObject);
begin
  calc_scale:=strtofloat2(stackmenu1.pixelsize1.text)/(0.0001+strtofloat2(stackmenu1.focallength1.text))*206.3; {arcsec per pixel}
  stackmenu1.calculated_scale1.caption:=floattostrf(calc_scale, ffgeneral, 3, 2);
end;

procedure Tstackmenu1.FormResize(Sender: TObject);
begin
  pagecontrol1.height:=classify_groupbox1.top;{make it High-DPI robust}

  listview1.top:=browse1.top + browse1.height+5;

  listview2.top:=browse_darks1.top + browse_darks1.height+5;
  listview3.top:=browse_flats1.top + browse_flats1.height+5;
  listview4.top:=browse_bias1.top + browse_bias1.height+5;
  listview5.top:=Label_results1.top + Label_results1.height+5;

  memo2.top:=classify_groupbox1.top+ classify_groupbox1.height+4;{make it High-DPI robust}
  memo2.height:=stackmenu1.Height-memo2.top;{make it High-DPI robust}
end;

procedure Tstackmenu1.FormShow(Sender: TObject);

begin
  edit_background1.Text:='';
  stackmenu1.stack_method1Change(nil);{update dark pixel filter}

  stackmenu1.focallength1Change(nil); {update calculation pixel size in arc seconds}
  stackmenu1.width_UpDown1.position:=round(width2*strtofloat2(stackmenu1.resize_factor1.caption));
  stackmenu1.make_osc_color1Change(nil);{update glyph stack button}

  update_stackmenu;
end;

procedure Tstackmenu1.undo_button_equalise_background1Click(Sender: TObject);
begin
  if mainwindow.Undo1.enabled then
  begin
    if equalise_background_step=5 then
    begin {restart from step 1}
      if load_fits(filename2,true {light},true,true,img_loaded) then{succes load}
      begin
        getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
        plot_fits(mainwindow.image1,false);{plot real}
      end;
    end
    else
    begin
      restore_img;
    end;
  end;
end;

procedure listview_unselect(tl :tlistview);
var index: integer;
begin
  tl.Items.BeginUpdate;
  for index:=0 to tl.Items.Count-1 do
  begin
    if tl.Items[index].Selected then
    begin
      tl.Items[index].Checked:=false;
    end;
  end;
  tl.Items.EndUpdate;
end;

procedure Tstackmenu1.unselect1Click(Sender: TObject);
begin
  if sender=unselect1 then listview_unselect(listview1);{popupmenu}
  if sender=unselect2 then listview_unselect(listview2);{popupmenu}
  if sender=unselect3 then listview_unselect(listview3);{popupmenu}
  if sender=unselect4 then listview_unselect(listview4);{popupmenu}
  if sender=unselect6 then listview_unselect(listview6);{popupmenu blink}
  if sender=unselect7 then listview_unselect(listview7);{popupmenu blink}
end;

procedure Tstackmenu1.apply_gaussian_blur_button1Click(Sender: TObject);
var
   Save_Cursor:TCursor;
begin
   if fits_file=false then exit;
   Save_Cursor := Screen.Cursor;
   Screen.Cursor := crHourglass;    { Show hourglass cursor }
   backup_img;
   gaussian_blur2(img_loaded,strtofloat2(blur_factor1.text));
   getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
   plot_fits(mainwindow.image1,false);{plot}
   Screen.cursor:=Save_Cursor;
end;


procedure Tstackmenu1.listview1ColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  TListView(Sender).SortType := stNone;
  if Column.Index<>SortedColumn then
  begin
    SortedColumn := Column.Index;
    Descending := False;
  end
  else
  Descending := not Descending;
  TListView(Sender).SortType := stText;

  {clear alignment}
  if sender=listview6 then
              stackmenu1.clear_blink_alignment1Click(sender);{sequence change, reanalyse for alignment}
end;

procedure Tstackmenu1.listview1Compare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
begin
  if SortedColumn = 0 then Compare := CompareText(Item1.Caption, Item2.Caption)
  else
  if SortedColumn <> 0 then Compare := CompareText(Item1.SubItems[SortedColumn-1], Item2.SubItems[SortedColumn-1]);
  if Descending then Compare := -Compare;
end;

procedure listview_view(tl : tlistview);
var index : integer;
    fitsX,fitsY: double;
begin
  for index:=0 to TL.Items.Count-1 do
  begin
    if TL.Items[index].Selected then
    begin
      filename2:=TL.items[index].caption;
      if load_image(mainwindow.image1.visible=false,true {plot}) {for the first image set the width and length of image1 correct} then
      begin
        if ((tl=stackmenu1.listview1) and (stackmenu1.use_manual_alignment1.checked)) then {manual alignment}
        begin
          fitsX:=strtofloat2(tl.Items.item[index].subitems.Strings[11+5]);
          fitsY:=strtofloat2(tl.Items.item[index].subitems.Strings[11+6]);
          show_shape(true {assume good lock},fitsX,fitsY);
        end
        else mainwindow.shape_alignment_marker1.visible:=false;
      end
      else beep;{image not found}
      exit;{done, can display only one image}
    end;
  end;
end;
procedure Tstackmenu1.listview1DblClick(Sender: TObject);
begin
  listview_view(TListView(Sender));
end;

procedure analyse_listview(lv :tlistview; amode : integer);{analyse list of FITS files}
// amode=0 ==> minimum, header only, keep orginal ra0, dec0
// amode=1 ==> full, header only
// amode=2 ==> get background
// amode=3 ==> get background, HFD, stars
var
  c,counts,i : integer;
  hfd_counter : integer;
  backgr, hfd_median, ra2, dec2,hjd : double;
  filename : string;
  Save_Cursor          : TCursor;
  loaded               : boolean;
  img                  : image_array;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  esc_pressed:=false;
  if img_loaded<>nil then  memo_backup:=mainwindow.Memo1.Text;{backup fits header for later}

  if amode<=1 then  lv.Items.BeginUpdate;{stop updating to prevent flickering till finished}

  counts:=lv.items.count-1;

  c:=0;
  {convert any non FITS file}
  while c<=counts  do {check all}
  begin

    if ((lv.Items.item[c].checked) and (uppercase(ExtractFileExt(lv.items[c].caption))='.FZ')   ) then {checked raw file, convert to PGM}
    begin
      memo2_message('Unpacking '+lv.items[c].caption);
      Application.ProcessMessages;
      if esc_pressed then  begin lv.Items.EndUpdate; Screen.Cursor :=Save_Cursor;{back to normal}  exit;  end;

      if unpack_cfitsio(lv.items[c].caption) then  {success unpacking}
         lv.items[c].caption:=filename2 {change listview name to FITS.}
      else
      begin {conversion failure}
        Lv.Items.item[c].checked:=false;
        Lv.Items.item[c].subitems.Strings[2]:='Funpack required, install!!';
      end;
    end {cfitsio}
    else
    if ((lv.Items.item[c].checked) and (check_raw_file_extension(uppercase(ExtractFileExt(lv.items[c].caption))))   ) then {checked raw file, convert to PGM}
    begin
      memo2_message('Converting '+lv.items[c].caption+' to FITS file format');
      Application.ProcessMessages;
      if esc_pressed then  begin lv.Items.EndUpdate; Screen.Cursor :=Save_Cursor; {back to normal} exit;  end;

      if convert_raw_to_fits(lv.items[c].caption) then  {success converting raw to pgm file}
         lv.items[c].caption:=filename2 {change listview name to FITS. The filename2 is renamed in prcedure save_16_m32..}
      else
      begin {conversion failure}
        lv.Items.item[c].checked:=false;
        lv.Items.item[c].subitems.Strings[2]:='Conv failure!';
      end;
    end;{checked}
   inc(c);
  end;

  c:=0;
  repeat {check for double entries}
      i:=c+1;
      while i<=counts do
      begin
        if lv.items[i].caption=lv.items[c].caption then {double file name}
        begin
          memo2_message('Removed second entry of same file '+lv.items[i].caption);
          lv.Items.Delete(i);
          //dec(i); {compensate for delete}
          dec(counts); {compensate for delete}
        end
        else
        inc(i);
      end;
     inc(c);
  until c>counts;

  for c:=0 to lv.items.count-1 do
  begin
    if ((lv.Items.item[c].checked) and ((amode=3) or (length(lv.Items.item[c].subitems.Strings[7])<=1){noise or date&time}) ) then {column empthy, only update blank rows}
    begin
      progress_indicator(100*c/lv.items.count-1,' Analysing');
      lv.Selected :=nil; {remove any selection}
      lv.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
      lv.Items[c].MakeVisible(False);{scroll to selected item}


      filename:=lv.items[c].caption;
      Application.ProcessMessages; if esc_pressed then break;{leave loop}

      if amode=0 then loaded:=load_fits(filename,false{restricted header, do not update ra0....},false {header only},true {reset var},img)
      else
      if amode=1 then loaded:=load_fits(filename,true{ full header},false {header only},true {reset var},img)
      else
      if amode=2 then loaded:=load_fits(filename,false{reduced  header},true {full fits},true {reset var},img)
      else
      loaded:=load_fits(filename,true {light, so also position ra0..},true {full fits},true {reset var},img); {for background or background+hfd+star}

      if loaded then
      begin {success loading header only}
        try
          begin
            lv.Items.item[c].subitems.Strings[D_exposure]:=inttostr(round(exposure));
            lv.Items.item[c].subitems.Strings[D_temperature]:=inttostr(set_temperature);

            lv.Items.item[c].subitems.Strings[D_binning]:=inttostr(Xbinning)+' x '+inttostr(Ybinning); {Binning CCD}
            lv.Items.item[c].subitems.Strings[D_width]:=inttostr(width2); {image width}
            lv.Items.item[c].subitems.Strings[D_height]:=inttostr(height2);{image height}
            lv.Items.item[c].subitems.Strings[D_type]:=imagetype;{image type}
            if amode=2 then
            begin {analyse background and noise}
              get_background(0,img,true {update_hist},true {calculate noise level}, {var} backgr,star_level);
              lv.Items.item[c].subitems.Strings[D_background]:=inttostr5(round(backgr));
              if ((lv.name=stackmenu1.listview2.name) or (lv.name=stackmenu1.listview3.name) or (lv.name=stackmenu1.listview4.name)) then
                lv.Items.item[c].subitems.Strings[D_sigma]:=inttostr(noise_level[0]); {noise level}
            end;
            if lv.name=stackmenu1.listview3.name then
            begin
             lv.Items.item[c].subitems.Strings[8]:=filter_name; {filter name, without spaces}
            end;

            if lv.name=stackmenu1.listview6.name then {blink tab}
            begin
              lv.Items.item[c].subitems.Strings[6]:=StringReplace(date_obs,'T',' ',[]);{date/time for blink}
              lv.Items.item[c].subitems.Strings[7]:=calstat; {calibration calstat info DFB}
            end;

            if lv.name=stackmenu1.listview7.name then {photometry tab}
            begin
              lv.Items.item[c].subitems.Strings[7+1]:=StringReplace(date_obs,'T',' ',[]);{date/time for blink}
              date_obs_to_jd; {convert date to Julian day}
              jd:=jd+exposure/2; {mid exposure}
              lv.Items.item[c].subitems.Strings[8+1]:=floattostrF2(jd,0,5);{julian day}

              hjd:=JD_to_HJD(jd,RA0,DEC0);{conversion JD to HJD}
              lv.Items.item[c].subitems.Strings[9+1]:=floattostrF2(frac(Hjd),0,5);{helio julian day}

              {magn is column 9 will be added seperately}
              {solution is column 12 will be added seperately}
              lv.Items.item[c].subitems.Strings[15+1]:=calstat; {calibration calstat info DFB}
            end;
            if amode=3 then {listview7}
            begin

              analyse_fits(hfd_counter, backgr, hfd_median,img); {find background, number of stars, median HFD}
              lv.Items.item[c].subitems.Strings[6]:=inttostr5(round(backgr));
              lv.Items.item[c].subitems.Strings[7]:=filter_name;
              lv.Items.item[c].subitems.Strings[11+1]:=floattostrF2(hfd_median,0,1);
              lv.Items.item[c].subitems.Strings[12+1]:=inttostr5(hfd_counter); {number of stars}
            end;
          end;
        finally
        end;
      end
      else
      begin
        lv.Items.item[c].checked:=false; {can't analyse this one}
        memo2_message('Error reading '+filename);
      end;
    end;{hfd unknown}
  end;
 if amode<=1 then lv.Items.EndUpdate;{can update now}
  progress_indicator(-100,'');{progresss done}
  img:= nil;

  {try to restore original header data for image in the viewer}
  if img_loaded<>nil then
  begin
    naxis3:=length(img_loaded);{nr colours}
    height2:=length(img_loaded[0,0]);{length}
    width2:=length(img_loaded[0]);{width}
    getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
    mainwindow.Memo1.Text:=memo_backup;{restore fits header}
    fits_file:=true; {will be lost be reading header of other files}
  end;

  Screen.Cursor :=Save_Cursor;{back to normal }
end;


procedure average(mess:string; var img2: image_array);{combine to average or mean, make also mono from three colors if color}
var                                                   {this routine works with mono files but makes coloured files mono, so less suitable for commercial cameras producing coloured raw images}
   Save_Cursor:TCursor;
   c,fitsX, fitsY : integer;
   img_tmp1 :image_array;
begin
  bias_counter:=0;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  {average}
  for c:=0 to file_count-1 do
  begin
    memo2_message('Adding '+mess+' image '+inttostr(c+1)+ ' to '+mess+' average. '+file_list[c]);

    {load image}
    Application.ProcessMessages;
    if ((esc_pressed) or (load_fits(file_list[c],false {light},true,true {reset var},img_tmp1)=false))then  begin Screen.Cursor := Save_Cursor;  exit;end;

    if c=0 then {init}
    begin
      setlength(img2,1,width2,height2);{set length of image array mono}
      for fitsY:=0 to height2-1 do
        for fitsX:=0 to width2-1 do
         img2[0,fitsX,fitsY]:=0; {clear img}
    end;

    if naxis3=3 then  {for the rare case the darks are coloured. Should normally be not the case since it expects raw mono FITS files without bayer matrix applied !!}
    begin {color average}
      for fitsY:=0 to height2-1 do
         for fitsX:=0 to width2-1 do
           img2[0,fitsX,fitsY]:=img2[0,fitsX,fitsY]+(img_tmp1[0,fitsX,fitsY]+img_tmp1[1,fitsX,fitsY]+img_tmp1[2,fitsX,fitsY])/3;{fill with image}
    end
    else
    begin {mono average}
      for fitsY:=0 to height2-1 do
         for fitsX:=0 to width2-1 do
           img2[0,fitsX,fitsY]:=img2[0,fitsX,fitsY]+img_tmp1[0,fitsX,fitsY];{fill with image}

    end;
  end;{open files}

 if file_count>1 then {not required for single/master files}
  For fitsY:=0 to height2-1 do
     for fitsX:=0 to width2-1 do
       img2[0,fitsX,fitsY]:=img2[0,fitsX,fitsY]/file_count;{scale to one image}

  img_tmp1:=nil;{free mem}
  Screen.Cursor := Save_Cursor;  { Always restore to normal }
end;

function average_flatdarks: integer;
var
  c : integer;
begin
  analyse_listview(stackmenu1.listview4,0 {analyse reduced header only});{update the tab information, convert to FITS if required}
  setlength(file_list,stackmenu1.listview4.items.count);
  file_count:=0;
  result:=0;{just in case no flat-dark are found}
  for c:=0 to stackmenu1.listview4.items.count-1 do
    if stackmenu1.listview4.items[c].checked=true then
    begin
        file_list[file_count]:=stackmenu1.ListView4.items[c].caption;
        inc(file_count);
    end;
  if file_count<>0 then
  begin
    memo2_message('Averaging flat dark frames.');
    average('flat-darks',img_bias);{only average}
    result:=width2; {width of the flat-dark}
  end;

end;

procedure average_flats(filter :string; width1: integer);
var
  c  : integer;
begin
  analyse_listview(stackmenu1.listview3,2 {analyse background, reduced header});
  setlength(file_list,stackmenu1.listview3.items.count);
  file_count:=0;

  for c:=0 to stackmenu1.listview3.items.count-1 do
     if stackmenu1.listview3.items[c].checked=true then
       if ((stackmenu1.classify_flat_filter1.checked=false) or (filter='ignore') or (filter=stackmenu1.listview3.Items.item[c].subitems.Strings[8])) then {filter correct?}
         if ((width1=12345) or (width1=strtoint(stackmenu1.listview3.Items.item[c].subitems.Strings[3]))) then {width correct}
         begin
           file_list[file_count]:=stackmenu1.ListView3.items[c].caption;
           inc(file_count);
        end;

  if file_count<>0 then
  begin
    memo2_message('Averaging flat frames.');
    average('flat',img_flat);{only average, make color also mono}
  end;
end;

procedure x2mean(colors: integer; var img: image_array);{combine values of 4 pixel}
var fitsX,fitsY,k,x1,x2,y1,y2,col : integer;
    img_temp2 : image_array;
begin
  col:=length(img);{the real number of colours}

  setlength(img_temp2,col,width2,height2);{set length of image array}

  for k:=0 to col-1 do
  begin
    for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1 do
      begin
        x1:=fitsx;
        x2:=fitsx+1;if x2>width2-1 then x2:=width2-1;
        y1:=fitsy;
        y2:=fitsy+1;if y2>height2-1 then y2:=height2-1;

        img_temp2[k,fitsX,fitsY]:=(img[k,x1,  y1]+ img[k,x2,  y1]+
                                   img[k,x1,  y2]+ img[k,x2,  y2])/4;

      end;
  end;{k}

  if ((colors=1){request} and (col=3){actual})  then {rare, need to make mono, copy back to img}
  begin
  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
    for k:=0 to col-1 do
     img[0,fitsx,fitsy]:=(img_temp2[0,fitsx,fitsy]+img_temp2[1,fitsx,fitsy]+img_temp2[2,fitsx,fitsy])/3;
  end
  else
  img:=img_temp2;{move pointer array}
  naxis3:=colors;{the final result}
  img_temp2:=nil;
end;
procedure x3mean(colors: integer;var img: image_array);{combine values of 9 pixels}
var fitsX,fitsY,k,x1,x2,x3,y1,y2,y3,col : integer;
   img_temp2 : image_array;
begin
  col:=length(img);{the real number of colours}

  setlength(img_temp2,col,width2,height2);{set length of image array}

  for k:=0 to col-1 do
  begin
    for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1 do
      begin
        x1:=fitsx-1;if x1<0 then x1:=0;
        x2:=fitsx;
        x3:=fitsx+1;if x3>width2-1 then x3:=width2-1;
        y1:=fitsy-1;if y1<0 then y1:=0;
        y2:=fitsy;
        y3:=fitsy+1;if y3>height2-1 then y3:=height2-1;

        img_temp2[k,fitsX,fitsY]:=(img[k,x1,  y1]+ img[k,x2,  y1] + img[k,x3,  y1]+
                                   img[k,x1,  y2]+ img[k,x2,  y2] + img[k,x3,  y2]+
                                   img[k,x1,  y3]+ img[k,x2,  y3] + img[k,x3,  y3])/9;

      end;
  end;{k}

  if ((colors=1){request} and (col=3){actual})  then {rare, need to make mono, copy back to img}
  begin
  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
    for k:=0 to col-1 do
     img[0,fitsx,fitsy]:=(img_temp2[0,fitsx,fitsy]+img_temp2[1,fitsx,fitsy]+img_temp2[2,fitsx,fitsy])/3;
  end
  else
  img:=img_temp2;{move pointer array}

  naxis3:=colors;{the final result}
  img_temp2:=nil;
end;


procedure x4mean(colors: integer;var img: image_array);{combine values of 16 pixels}
var fitsX,fitsY,k,x1,x2,x3,x4,y1,y2,y3,y4,col : integer;
   img_temp2 : image_array;
begin
  col:=length(img);{the real number of colours}

  setlength(img_temp2,col,width2,height2);{set length of image array}

  for k:=0 to col-1 do
  begin
    for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1 do
      begin
        x1:=fitsx-1;if x1<0 then x1:=0;
        x2:=fitsx;
        x3:=fitsx+1;if x3>width2-1 then x3:=width2-1;
        x4:=fitsx+2;if x4>width2-1 then x4:=width2-1;
        y1:=fitsy-1;if y1<0 then y1:=0;
        y2:=fitsy;
        y3:=fitsy+1;if y3>height2-1 then y3:=height2-1;
        y4:=fitsy+2;if y4>height2-1 then y4:=height2-1;

        img_temp2[k,fitsX,fitsY]:=(img[k,x1,  y1]+ img[k,x2,  y1] + img[k,x3,  y1]+img[k,x4,  y1]+
                                   img[k,x1,  y2]+ img[k,x2,  y2] + img[k,x3,  y2]+img[k,x4,  y2]+
                                   img[k,x1,  y3]+ img[k,x2,  y3] + img[k,x3,  y3]+img[k,x4,  y3]+
                                   img[k,x1,  y4]+ img[k,x2,  y4] + img[k,x3,  y4]+img[k,x4,  y4])/16;
      end;
  end;{k}

  if ((colors=1){request} and (col=3){actual})  then {rare, need to make mono, copy back to img}
  begin
  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
    for k:=0 to col-1 do
     img[0,fitsx,fitsy]:=(img_temp2[0,fitsx,fitsy]+img_temp2[1,fitsx,fitsy]+img_temp2[2,fitsx,fitsy])/3;
  end
  else
  img:=img_temp2;{move pointer array}

  naxis3:=colors;{the final result}
  img_temp2:=nil;
end;

procedure Tstackmenu1.test_flat_meanClick(Sender: TObject);
var    Save_Cursor:TCursor;
begin
  if Length(img_loaded)=0 then
  begin
    memo2_message('Error, no image in viewer loaded!');
    exit;
  end;
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  backup_img;

  if pos('2x2',stackmenu1.flat_combine_method1.text)>0 then  x2mean(1 {nr of colors},img_loaded)
  else
  if pos('3x3',stackmenu1.flat_combine_method1.text)>0 then  x3mean(1 {nr of colors},img_loaded)
  else
  if pos('4x4',stackmenu1.flat_combine_method1.text)>0 then  x4mean(1 {nr of colors},img_loaded); {else do nothing}

  getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
  plot_fits(mainwindow.image1,false);{plot real}

  Screen.Cursor:=Save_Cursor;
end;


procedure Tstackmenu1.analyseflatsButton3Click(Sender: TObject);
begin
  analyse_listview(listview3,2 {analyse background reduced header});
end;

procedure Tstackmenu1.analyseflatdarksButton4Click(Sender: TObject);
begin
  analyse_listview(listview4,2 {analyse background reduced header});
end;

procedure Tstackmenu1.changekeyword1Click(Sender: TObject);
var
   keyw,value :string;
   lv: tlistview;
begin
  if sender=changekeyword1 then lv:=listview1;{from popup menu}
  if sender=changekeyword2 then lv:=listview2;{from popup menu}
  if sender=changekeyword3 then lv:=listview3;{from popup menu}
  if sender=changekeyword4 then lv:=listview4;{from popup menu}


  keyw:=InputBox('All selected files will be updated!! Hit cancel to abort. Type keyword:','','' );
  if length(keyw)<=2 then exit;

  value:=InputBox('New value keyword:','','' );
  if length(value)<=0 then exit;
  listview_update_keyword(lv,uppercase(keyw),value);{update key word}
end;

procedure Tstackmenu1.dark_sport_filter1Click(Sender: TObject);
var
   Save_Cursor : TCursor;
   fitsx,fitsy,i,j,k,x2,y2,radius,most_common,progress_value : integer;
   neg_noise_level,bg  : double;
begin
  if fits_file=true then
  begin
     Save_Cursor := Screen.Cursor;
     Screen.Cursor := crHourglass;    { Show hourglass cursor }

     get_background(0,img_loaded,true,false{do not calculate noise_level}, {var} bg,star_level); {should be about 500 for mosaic since that is the target value}

     backup_img;  {store array in img_backup}
     {equalize background}
     radius:=50;

     for k:=0 to naxis3-1 do {do all colors}
     begin

       for fitsY:=0 to (height2-1) {div 5} do
       begin
         if frac(fitsY/100)=0 then
         begin
           Application.ProcessMessages;
           if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
           progress_value:=round(100*(fitsY)/(((k+1)/naxis3)*(height2)));
           progress_indicator(progress_value,'');{report progress}
         end;
         for fitsX:=0 to (width2-1) {div 5} do
         begin
           if ((frac(fitsx/10)=0) and (frac(fitsY/10)=0)) then
           begin
             most_common:=get_most_common(img_backup,k,fitsX-radius,fitsX+radius-1,fitsY-radius,fitsY+radius-1,32000);
             neg_noise_level:=get_negative_noise_level(img_backup,k,fitsX-radius,fitsX+radius,fitsY-radius,fitsY+radius,most_common);{find the most common value of a local area and calculate negative noise level}
             for i:=-radius to +radius-1 do
                  for j:=-radius to +radius-1 do
                  begin
                    x2:=fitsX+i;
                    y2:=fitsY+j;
                    if ((x2>=0) and (x2<width2) and (y2>=0) and (y2<height2))  then
                      if img_loaded[k,x2,y2]<bg then {below global most common level}
                        if img_loaded[k,x2,y2]<most_common-neg_noise_level then {local dark spot}
                          img_loaded[k,x2,y2]:=most_common-neg_noise_level;
                  end;
           end;{/3}
         end;
       end;
     end;{k color}
     plot_fits(mainwindow.image1,false);{plot real}
     progress_indicator(-100,'');{back to normal}
     Screen.Cursor:=Save_Cursor;
  end;
end;


function value_sub_pixel(k2: integer;x1,y1:double):double; {calculate image pixel value on subpixel level}
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
  result:=         (img_loaded[k2,x_trunc  ,y_trunc  ]) * (1-x_frac)*(1-y_frac);{pixel left top, 1}
  result:=result + (img_loaded[k2,x_trunc+1,y_trunc  ]) * (  x_frac)*(1-y_frac);{pixel right top, 2}
  result:=result + (img_loaded[k2,x_trunc  ,y_trunc+1]) * (1-x_frac)*(  y_frac);{pixel left bottom, 3}
  result:=result + (img_loaded[k2,x_trunc+1,y_trunc+1]) * (  x_frac)*(  y_frac);{pixel right bottom, 4}
  except
  end;

end;

// Not used, makes HFD worse.
//procedure add_sub_pixel_fractions(fitsX,fitsY: integer ; x1,y1:double); {add pixel values on subpixel level}
//var
//  x_trunc,y_trunc,col: integer;
//  x_frac,y_frac,value  : double;
//begin
//  x_trunc:=trunc(x1);
//  y_trunc:=trunc(y1);
//  x_frac :=frac(x1);
//  y_frac :=frac(y1);

//  try
//    for col:=0 to naxis3-1 do {all colors}
//    begin {add the value in ration with pixel coverage}
//      value:=img_loaded[col,fitsX-1,fitsY-1]; {pixel value to spread out over 4 pixels}
//      img_average[col,x_trunc  ,y_trunc  ]  :=img_average[col,x_trunc  ,y_trunc  ] + value * (1-x_frac)*(1-y_frac);{pixel left top, 1}
//      img_average[col,x_trunc+1,y_trunc  ]  :=img_average[col,x_trunc+1,y_trunc  ] + value * (  x_frac)*(1-y_frac);{pixel right top, 2}
//      img_average[col,x_trunc  ,y_trunc+1]  :=img_average[col,x_trunc  ,y_trunc+1] + value * (1-x_frac)*(  y_frac);{pixel left bottom, 3}
//      img_average[col,x_trunc+1,y_trunc+1]  :=img_average[col,x_trunc+1,y_trunc+1] + value * (  x_frac)*(  y_frac);{pixel right bottom, 4}
//    end;
//    {keep record of the pixel part added}
//    img_temp[0,x_trunc  ,y_trunc  ] :=img_temp[0,x_trunc  ,y_trunc  ] + (1-x_frac)*(1-y_frac);{pixel left top, 1}
//    img_temp[0,x_trunc+1,y_trunc  ] :=img_temp[0,x_trunc+1,y_trunc  ] + (  x_frac)*(1-y_frac);{pixel right top, 2}
//    img_temp[0,x_trunc  ,y_trunc+1] :=img_temp[0,x_trunc  ,y_trunc+1] + (1-x_frac)*(  y_frac);{pixel left bottom, 3}
//    img_temp[0,x_trunc+1,y_trunc+1] :=img_temp[0,x_trunc+1,y_trunc+1] + (  x_frac)*(  y_frac);{pixel right bottom, 4}
//  except
//  end;
//end;

procedure Tstackmenu1.free_resize_fits1Click(Sender: TObject);{free resize FITS image}
var
   Save_Cursor:TCursor;
   img_temp2 : image_array;
   FitsX, fitsY,k,w,h,w2,h2   : integer;
   x,y,ratio          : double;
begin
  if fits_file=false then exit;
  Save_Cursor := Screen.Cursor;
  backup_img;

  w2:=width_UpDown1.position;
  ratio:=w2/width2;
  h2:=round(height2*ratio);

  repeat
    w:=max(w2,round(width2/2));  {reduce in steps of two maximum to preserve stars}
    h:=max(h2,round(height2/2));  {reduce in steps of two maximum to preserve stars}

    setlength(img_temp2,naxis3,w,h);;
    for k:=0 to naxis3-1 do
      for fitsY:=0 to h-1 do
         for fitsX:=0 to w-1  do
         begin
           X:=(fitsX*width2/w);
           Y:=(fitsY*height2/h);
           img_temp2[k,fitsX,fitsY]:=value_sub_pixel(k,x,y);
         end;
    img_loaded:=img_temp2;
    width2:=w;
    height2:=h;
  until ((w<=w2) and (h<=h2)); {continue till required size is reeached}

   img_temp2:=nil;

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

   update_float  ('XBINNING=',' / Binning factor in width                         ' ,XBINNING/ratio);
   update_float  ('YBINNING=',' / Binning factor in height                        ' ,yBINNING/ratio);


   getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
   plot_fits(mainwindow.image1,true);{plot}
   Screen.cursor:=Save_Cursor;
end;

procedure Tstackmenu1.copypath1Click(Sender: TObject);
var
   index,counter :integer;
begin
  with listview5 do
  begin
    index:=0;
    counter:=Items.Count;
    while index<counter do
    begin
      if Items[index].Selected then
      begin
        Clipboard.AsText:=extractfilepath(items[index].caption);
      end;
      inc(index); {go to next file}
    end;
  end;{with listview}
end;

procedure Tstackmenu1.gridlines1Click(Sender: TObject);
begin
  listview1.gridlines:=gridlines1.checked;
  listview2.gridlines:=gridlines1.checked;
  listview3.gridlines:=gridlines1.checked;
  listview4.gridlines:=gridlines1.checked;
  listview5.gridlines:=gridlines1.checked;
  listview6.gridlines:=gridlines1.checked;{blink}
end;

procedure Tstackmenu1.help_pixel_math1Click(Sender: TObject);
begin
    openurl('http://www.hnsky.org/astap.htm#pixel_math');
end;

procedure Tstackmenu1.help_stack_menu2Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#stack_menu2');
end;

procedure Tstackmenu1.help_stack_menu3Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#results');
end;

procedure Tstackmenu1.listview1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=vk_delete then listview_removeselect(TListView(Sender));
end;



procedure Tstackmenu1.sd_factor_blink1Change(Sender: TObject);
begin
  esc_pressed:=true; {need to remake img_backup contents for star supression}
end;

procedure Tstackmenu1.solve1Click(Sender: TObject);
begin
  if ((width2<>100) or (height2<>100)) then {is image loaded?,  assigned(img_loaded) doesn't work for jpegs}
    mainwindow.astrometric_solve_image1Click(nil)
  else
  memo2_message('Abort solve, no image in the viewer.');
end;

procedure Tstackmenu1.splitRGB1Click(Sender: TObject);
var
   fitsx, fitsY,old_Naxis3 : integer;
   filename1,memo2_text: string;
begin
  if ((fits_file=false) or (naxis3<3)) then exit;

  memo2_text:=mainwindow.Memo1.Text;{save fits header first FITS file}

  setlength(img_backup,naxis3,width2,height2);{set length of image array}
  img_backup:=img_loaded;

  filename1:=ChangeFileExt(FileName2,'.fit');{make it lowercase fit also if FTS or FIT}
  old_naxis3:=naxis3;{could be bayered, remember mono}
  naxis3:=1;

  setlength(img_loaded,1,width2,height2);{set length of image array}
  for fitsY:=0 to height2-1 do
  for fitsX:=0 to width2-1 do
         img_loaded[0,fitsX,fitsY]:=img_backup[0,fitsX,fitsY];
  filename2:=StringReplace(filename1,'.fit','_red.fit',[]);{give new file name }
  update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,1);
  update_text   ('FILTER  =',#39+'Red     '+#39+'           / Filter name                                    ');
  save_fits(filename2,-32,false);

  for fitsY:=0 to height2-1 do
  for fitsX:=0 to width2-1 do
        img_loaded[0,fitsX,fitsY]:=img_backup[1,fitsX,fitsY];
  filename2:=StringReplace(filename1,'.fit','_green.fit',[]);{give new file name }
  update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,1);
  update_text   ('FILTER  =',#39+'Green   '+#39+'           / Filter name                                    ');
  save_fits(filename2,-32,false);

  for fitsY:=0 to height2-1 do
  for fitsX:=0 to width2-1 do
      img_loaded[0,fitsX,fitsY]:=img_backup[2,fitsX,fitsY];
  filename2:=StringReplace(filename1,'.fit','_blue.fit',[]);{give new file name }
  update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,1);
  update_text   ('FILTER  =',#39+'Blue    '+#39+'           / Filter name                                    ');
  save_fits(filename2,-32,false);

  {restore}
  mainwindow.Memo1.Text:= memo2_text;{save fits header first FITS file}
  filename2:=filename1;
  naxis3:=old_naxis3;
  update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,naxis3);
  img_loaded:=img_backup;
end;

procedure Tstackmenu1.analysedarksButton2Click(Sender: TObject);
begin
  analyse_listview(listview2,2 {analyse background, reduced header});
end;

procedure Tstackmenu1.resize_factor1Change(Sender: TObject);
var
   factor: double;
begin
  factor:=strtofloat2(resize_factor1.text);
  Edit_width1.text:=inttostr(round(width2*factor));
end;


procedure Tstackmenu1.Edit_width1Change(Sender: TObject);
begin
  new_height1.caption:=inttostr(round(width_UpDown1.position*height2/width2));
end;

procedure Tstackmenu1.extra_star_supression_diameter1Change(Sender: TObject);
begin
  esc_pressed:=true; {need to remake img_backup contents for star supression}
end;

procedure Tstackmenu1.help_astrometric_solving1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#astrometric_solving');
end;

procedure Tstackmenu1.Label1Click(Sender: TObject);
begin

end;

procedure Tstackmenu1.listview1CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: Boolean);
begin
  stackmenu1.nr_total1.caption:=inttostr(ListView1.items.count);{update counting info}
end;

procedure Tstackmenu1.listview1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if stackmenu1.use_manual_alignment1.checked then
  begin
    if length(sender.Items.item[Item.Index].subitems.Strings[11+5])>1 then {manual position added, colour it}
       Sender.Canvas.Font.Color := clGreen
       else
       Sender.Canvas.Font.Color := clred;
  end
  else Sender.Canvas.Font.Color := clmenutext;{required for high contrast settings. Otherwise it is always black}
 {$ifdef mswindows}
 {$else} {unix}
 {temporary fix for CustomDraw not called}
 if Item.index=0 then  stackmenu1.nr_total1.caption:=inttostr(sender.items.count);{update counting info}
 {$endif}

end;

procedure Tstackmenu1.listview2Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin

end;



procedure Tstackmenu1.listview2CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: Boolean);
begin
  stackmenu1.nr_total_darks1.caption:=inttostr(ListView2.items.count);{update counting info}
end;

procedure Tstackmenu1.listview2CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  {$ifdef mswindows}
  {$else} {unix}
  {temporary fix for CustomDraw not called}
  if  Item.index=0 then  stackmenu1.nr_total_flats1.caption:=inttostr(ListView2.items.count);{update counting info}
  {$endif}
  Sender.Canvas.Font.Color := clmenutext;{required for high contrast settings. Otherwise it is always black}
end;

procedure Tstackmenu1.listview3CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: Boolean);
begin
  stackmenu1.nr_total_flats1.caption:=inttostr(sender.items.count);{update counting info}
end;

procedure Tstackmenu1.listview3CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  {$ifdef mswindows}
  {$else} {unix}
  {temporary fix for CustomDraw not called}
  if  Item.index=0 then  stackmenu1.nr_total_flats1.caption:=inttostr(sender.items.count);{update counting info}
  {$endif}
  Sender.Canvas.Font.Color := clmenutext;{required for high contrast settings. Otherwise it is always black}
end;

procedure Tstackmenu1.listview4CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: Boolean);
begin
  stackmenu1.nr_total_bias1.caption:=inttostr(sender.items.count);{update counting info}
end;


procedure Tstackmenu1.listview4CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  {$ifdef mswindows}
  {$else} {unix}
  {temporary fix for CustomDraw not called}
  if  Item.index=0 then  stackmenu1.nr_total_bias1.caption:=inttostr(sender.items.count);{update counting info}
  {$endif}
  Sender.Canvas.Font.Color := clmenutext;{required for high contrast settings. Otherwise it is always black}
end;

procedure Tstackmenu1.listview6CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: Boolean);
begin
  stackmenu1.nr_total_blink1.caption:=inttostr(sender.items.count);{update counting info}
end;

procedure Tstackmenu1.listview6CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  {$ifdef mswindows}
  {$else} {unix}
  {temporary fix for CustomDraw not called}
  if  Item.index=0 then  stackmenu1.nr_total_blink1.caption:=inttostr(sender.items.count);{update counting info}
  {$endif}
  Sender.Canvas.Font.Color := clmenutext;{required for high contrast settings. Otherwise it is always black}
end;


procedure Tstackmenu1.test_pattern1Click(Sender: TObject);
begin
  if fits_file then
    mainwindow.DemosaicBayermatrix1Click(nil);{including back and wait cursor}
end;

function listview_find_selection(tl : tlistview) :integer;{find the row selected}
var index,counter: integer;
begin
  result:=0;
  index:=0;
  counter:=tl.Items.Count;
  while index<counter do
  begin
    if  tl.Items[index].Selected then
    begin
      result:=index;
      break;
    end;
    inc(index); {go to next file}
  end;
end;



procedure Tstackmenu1.blink_button1Click(Sender: TObject);
var
  c,i,j: integer;
  Save_Cursor          : TCursor;
  noise_level1,back_ground1,signal_level,magn,sd,
  hfd1,star_fwhm,snr,flux,xc,yc                                              : double;
  x_new,y_new,fitsX,fitsY,col,first_image,tolerance,x,size,starX,starY,stepnr: integer;
  reference_done,backup_made, init,solut :boolean;

begin
  if listview6.items.count<=1 then exit; {no files}
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  save_settings(user_path+'astap.cfg');{too many lost selected files . so first save settings}

 if listview6.Items.item[listview6.items.count-1].subitems.Strings[0]='' {exposire last row} then
      analyse_listview(listview6, 1 {analyse minimum, load full fits header only});

//  flipvertical:=mainwindow.Flipvertical1.Checked;
//  fliphorizontal:=mainwindow.Fliphorizontal1.Checked;
  esc_pressed:=false;

  back_ground1:=-1;{not done yet indication}
  noise_level1:=-1;
  first_image:=-1;
  backup_made:=false;
  stepnr:=0;
  if sender=blink_button1 then init:=true {start at beginning}
     else init:=false;{start at selection}
  reference_done:=false;{ check if reference image is loaded. Could be after first image if abort was given}
  repeat
    stepnr:=stepnr+1; {first step is nr 1}

    if init=false then c:=listview_find_selection(listview6) {find the row selected}
    else c:=0;
    init:=true;
    repeat
      if ((esc_pressed=false) and (listview6.Items.item[c].checked) )  then
      begin
        if first_image=-1 then first_image:=c;
        listview6.Selected :=nil; {remove any selection}
        listview6.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview6.Items[c].MakeVisible(False);{scroll to selected item}

        filename2:=listview6.items[c].caption;
        mainwindow.caption:=filename2;

        Application.ProcessMessages;
        if esc_pressed then break;
        {load image}
        if load_fits(filename2,true {light},true,true {reset var},img_loaded)=false then begin esc_pressed:=true; break;end;

        getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}

        {find solution}
        if align_blink1.checked then
        begin
          if fileexists(ChangeFileExt(Filename2,'.astap_solution'))=false then
          begin
            if reference_done=false then {get reference}
            begin
              memo2_message('Working on star alignment solutions. Blink frequency will increase after completion.');
              get_background(0,img_loaded,false {no histogram already done},true {unknown, calculate also datamax}, {var} cblack,star_level);
              back_ground1:=cblack;
              noise_level1:=noise_level[0]; {remember for difference}
              find_stars(img_loaded,starlist1);{find stars and put them in a list}
              find_tetrahedrons_ref;{find tetrahedrons for reference image}

              reset_solution_vectors(1);{no influence on the first image since reference}
              save_solution_to_disk;{write solution_vectorX, solution_vectorY and solution_datamin to disk. Including solution_cblack[1]:=flux_magn_offset;}
              reference_done:=true;
              solut:=true;
            end
            else
            begin
              mainwindow.caption:=filename2+' Working on star solutions, be patient.';
              get_background(0,img_loaded,false {no histogram already done} ,true {unknown, calculate also noise_level} , {var} cblack,star_level);
              find_stars(img_loaded,starlist2);{find stars and put them in a list}
              find_tetrahedrons_new;{find triangels for new image}
              if find_offset_and_rotation(3,strtofloat2(stackmenu1.tetrahedron_tolerance1.text),true{save solution}) then {find difference between ref image and new image}
              begin
                memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' tetrahedrons selected matching within '+stackmenu1.tetrahedron_tolerance1.text+' tolerance.'
                   +'  Solution x:='+floattostr2(solution_vectorX[0])+'*x+ '+floattostr2(solution_vectorX[1])+'*y+ '+floattostr2(solution_vectorX[2])
                   +',  y:='+floattostr2(solution_vectorY[0])+'*x+ '+floattostr2(solution_vectorY[1])+'*y+ '+floattostr2(solution_vectorY[2]) );
                solut:=true;
              end
              else
              begin
                memo2_message('Not enough tetrahedron matches <3 or inconsistent solution, skipping this image.');
                reset_solution_vectors(1);{default for no solution}
                solut:=false;
              end;
            end;
          end
          {end find solution}
          else
          begin {reuse solution}
            AssignFile(savefile,ChangeFileExt(Filename2,'.astap_solution'));
            Reset(saveFile);
            read(savefile, solution_vectorX);
             read(savefile, solution_vectorY);
             CloseFile(saveFile);
             solut:=true;
          end;

          if solut then listview6.Items.item[c].subitems.Strings[8]:='✓' else  listview6.Items.item[c].subitems.Strings[8]:='';


        //13:32:05  133 of 135 tetrahedrons selected matching within 0.005 tolerance.  Solution x:=0.999799*x+ 0.000383*y+ 12.955186,  y:=0.000336*x+ 0.999466*y+ 2.896680
        //13:32:08  102 of 103 tetrahedrons selected matching within 0.005 tolerance.  Solution x:=-0.999535*x+ 0.006346*y+ 2399.382202,  y:=-0.007244*x+ -0.999204*y+ 1764.404977  <=flipped

          setlength(img_temp,naxis3,width2,height2);{new size}

          if blink_star_filter1.checked then
          begin
            if ( (c=first_image) and (back_ground1<0)) then {calculate background and noise of first image}
            begin
              get_background(0,img_loaded,false {no histogram already done},true {unknown, calculate also datamax},{var} back_ground1,star_level);
              noise_level1:=noise_level[0];
              signal_level:=back_ground1 + noise_level1*strtofloat2(sd_factor_blink1.text);{level of stars}

              backup_img; {make copy to img_backup}
              backup_made:=true;
              tolerance:=round(strtofloat2(extra_star_supression_diameter1.text));{increase star diamter of referecne image}
              for fitsY:=1 to height2 do
              for fitsX:=1 to width2  do
              begin {smear out stars}
                if ((fitsX>=tolerance) and (fitsX<=width2-1-tolerance) and (fitsY>=tolerance) and (FitsY<=height2-1-tolerance)) then
                begin
                  if img_loaded[0,fitsX,fitsY]> signal_level {star} then {increase star size}
                    for i:=-tolerance to tolerance do
                    for j:=-tolerance to tolerance do
                      img_backup[0,fitsX+i,fitsY+j]:=65535;
                end;
              end;
            end;

            if backup_made then {background calculated, img_backup created}
            begin
              for fitsY:=1 to height2 do
              for fitsX:=1 to width2  do
              begin
                x_new:=round(solution_vectorX[0]*(fitsx-1)+solution_vectorX[1]*(fitsY-1)+solution_vectorX[2]); {correction x:=aX+bY+c}
                y_new:=round(solution_vectorY[0]*(fitsx-1)+solution_vectorY[1]*(fitsY-1)+solution_vectorY[2]); {correction y:=aX+bY+c}

                if ((x_new>=0) and (x_new<=width2-1) and (y_new>=0) and (y_new<=height2-1)) then
                begin
                  if img_backup[0,x_new,y_new]< signal_level {use only red color to detect stars} then {no star}
                  for col:=0 to naxis3-1 do {all colors} img_temp[col,x_new,y_new]:=img_loaded[col,fitsX-1,fitsY-1]
                  else {star}
                  for col:=0 to naxis3-1 do {all colors} img_temp[col,x_new,y_new]:=0;
                end;
              end;
            end;{background>0}
          end{blink star filter checked}
          else {standard alligned blink}
          begin
            for fitsY:=1 to height2 do
            for fitsX:=1 to width2  do
            begin
              x_new:=round(solution_vectorX[0]*(fitsx-1)+solution_vectorX[1]*(fitsY-1)+solution_vectorX[2]); {correction x:=aX+bY+c}
              y_new:=round(solution_vectorY[0]*(fitsx-1)+solution_vectorY[1]*(fitsY-1)+solution_vectorY[2]); {correction y:=aX+bY+c}

              if ((x_new>=0) and (x_new<=width2-1) and (y_new>=0) and (y_new<=height2-1)) then
              for col:=0 to naxis3-1 do {all colors} img_temp[col,x_new,y_new]:=img_loaded[col,fitsX-1,fitsY-1] ;
            end;
          end;

          img_loaded:=img_temp;
        end{star align}
        else {un-aligned blink}
        begin
          {nothing to do}
        end;

        plot_fits(mainwindow.image1,false {re_center});
      end;
      inc(c);
    until c>=listview6.items.count;
  until ((esc_pressed) or (sender=blink_button1 {single run}));

  img_temp:=nil;{free memory}

  Screen.Cursor :=Save_Cursor;{back to normal }
end;

procedure Tstackmenu1.apply_create_gradient1Click(Sender: TObject);
begin
  if sender=create_test_image_stars1 then create_test_image(2)
                                     else create_test_image(1);
end;

procedure Tstackmenu1.clear_blink_alignment1Click(Sender: TObject);
var
  image_path: string;
  c         : integer;
begin
  if listview6.items.count>0 then
  begin
    image_path:=ExtractFilePath(ListView6.items[0].caption); {get path from first image}
    DeleteFiles(image_path,'*.astap_solution');{delete solution files}

    if (sender=listview6)=false then
      DeleteFiles(image_path,'*.astap_image_stars');{delete solution files}

    for c:=0 to listview6.items.count-1 do listview6.Items.item[c].subitems.Strings[8]:='';{clear alignment marks}
  end;
end;

procedure Tstackmenu1.clear_blink_list1Click(Sender: TObject);
begin
  esc_pressed:=true; {stop any running action}
  listview6.Clear;
end;

procedure Tstackmenu1.clear_blink_list2ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure Tstackmenu1.browse_dark1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select dark images';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.filename:='';
  opendialog1.Filter := 'FITS files and DSLR RAW files (*.)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                        '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef'+
                        '|FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                        '|RAW files (*.)|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF:*.nef;*.NRW:.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;*.NEF;*.nef';


//  fits_file:=true;
  if opendialog1.execute then
  begin
    for i:=0 to OpenDialog1.Files.count-1 do {add}
    begin
      listview234567_add(listview2,OpenDialog1.Files[i]);
    end;
  end;
end;

procedure Tstackmenu1.Button3Click(Sender: TObject);
var
   radius, fitsX,fitsY      : integer;
   value,org_value  : single;
   star_level_colouring     : double;
   Save_Cursor   : TCursor;
begin
  if Length(img_loaded)=0 then
  begin
    memo2_message('Error, no image in viewer loaded!');
    exit;
  end;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  backup_img; {move copy to img_backup}

  get_background(0,img_loaded,false {do not calculate hist},false {do not calculate noise_level}, {var} cblack,star_level);

  try radius:=strtoint(stackmenu1.filter_artificial_colouring1.text);except end;
  memo2_message('Applying most common filter with factor '+stackmenu1.filter_artificial_colouring1.text);

  setlength(img_temp,3,width2,height2);{new size}
  apply_most_common(img_backup,img_temp,radius); {apply most common filter on first array and place result in second array}

  memo2_message('Applying Gaussian blur of '+floattostrF2(radius*2,0,1));
  gaussian_blur2(img_temp,radius*2);


  setlength(img_loaded,3,width2,height2);{new size}

  memo2_message('Seperating stars and nebula. Making everthing white with value '+stackmenu1.star_level_colouring1.text+' above background.');

  star_level_colouring:=strtoint(stackmenu1.star_level_colouring1.text);

  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
      begin {subtract view from file}
           org_value:=img_backup[0,fitsX,fitsY];  {stars+nebula}
                              {smooth nebula}
           value:=org_value - img_temp[0,fitsX,fitsY];
           if  value>star_level_colouring then {star}
           begin
             img_loaded[0,fitsX,fitsY]:=org_value;
             if naxis3>1 then img_loaded[1,fitsX,fitsY]:=img_backup[1,fitsX,fitsY] else img_loaded[1,fitsX,fitsY]:=org_value;
             if naxis3>2 then img_loaded[2,fitsX,fitsY]:=img_backup[2,fitsX,fitsY] else img_loaded[2,fitsX,fitsY]:=org_value;
           end
           else {nebula}
           begin
             img_loaded[0,fitsX,fitsY]:=org_value;
             img_loaded[1,fitsX,fitsY]:=cblack+(org_value-cblack)*value/star_level_colouring;
             img_loaded[2,fitsX,fitsY]:=cblack+(org_value-cblack)*value/star_level_colouring;
           end

       end;

  naxis3:=3; {confirm colour set before}
  update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,naxis3);
  update_text   ('HISTORY 77','  Artificial colour applied.');

  getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
  plot_fits(mainwindow.image1,false);{plot real}
  Screen.Cursor:=Save_Cursor;
end;

procedure Tstackmenu1.clear_photometric_solutions1Click(Sender: TObject);
var
  image_path: string;
  c         : integer;
begin
  if (IDYES= Application.MessageBox('This will renew the astrometric solutions of all files and could take some time. Are you sure?', 'Renew astrometric solutions of  all files?', MB_ICONQUESTION + MB_YESNO) )=false then exit;
  if listview7.items.count>0 then
  begin
    image_path:=ExtractFilePath(ListView7.items[0].caption); {get path from first image}

    DeleteFiles(image_path,'*.astap_image_stars');{delete photometry files}

    for c:=0 to listview7.items.count-1 do
    begin
      listview7.Items.item[c].subitems.Strings[13+1]:='';{clear astrometry marks}
      listview7.Items.item[c].subitems.Strings[14+1]:='';{clear photometry marks}
    end;
  end;
  if sender=clear_astrometric_solutions1 then
            stackmenu1.photometry_button1Click(Sender);{refresh astrometric solutions}
end;

procedure Tstackmenu1.clear_photometry_list1Click(Sender: TObject);
begin
  esc_pressed:=true; {stop any running action}
  listview7.Clear;
end;

procedure Tstackmenu1.cygwin1DropDown(Sender: TObject);
var u_path : string;
    i   : integer;
begin
  {$ifdef mswindows}
  u_path:=GetUserDir;
  for i:=0 to cygwin1.Items.count-1 do {replace by correct user name}
    cygwin1.Items[i]:=stringreplace(cygwin1.Items[i],'C:\Users\user_name\',u_path,[rfIgnoreCase]);
  {$ELSE}{linux}
  {$endif}
end;

procedure Tstackmenu1.export_aligned_files1Click(Sender: TObject);
var
  c,fitsX,fitsY,x_new,y_new,col : integer;
  Save_Cursor          : TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  esc_pressed:=false;
  for c:=0 to listview6.items.count-1 do {this is not required but nice}
  if (listview6.Items.item[c].subitems.Strings[8]='✓') then
  begin
    filename2:=listview6.items[c].caption;
    mainwindow.caption:=filename2;
    if fileexists(ChangeFileExt(Filename2,'.astap_solution')) then {read solution}
    begin {reuse solution}

      listview6.Selected :=nil; {remove any selection}
      listview6.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
      listview6.Items[c].MakeVisible(False);{scroll to selected item}

      if load_fits(filename2,true {light},true,true {reset var},img_loaded)=false then begin esc_pressed:=true; break;end;  {load fits}

      Application.ProcessMessages;
      if esc_pressed then break;

      AssignFile(savefile,ChangeFileExt(Filename2,'.astap_solution')); {read solutions}
      Reset(saveFile);
      read(savefile, solution_vectorX);
      read(savefile, solution_vectorY);
      CloseFile(saveFile);

      setlength(img_temp,naxis3,width2,height2);{new size}

      for fitsY:=1 to height2 do
      for fitsX:=1 to width2  do
      begin
         for col:=0 to naxis3-1 do {all colors} img_temp[col,fitsX-1,fitsY-1]:=0;{clear memory}
      end;

      for fitsY:=1 to height2 do
      for fitsX:=1 to width2  do
      begin
        x_new:=round(solution_vectorX[0]*(fitsx-1)+solution_vectorX[1]*(fitsY-1)+solution_vectorX[2]); {correction x:=aX+bY+c}
        y_new:=round(solution_vectorY[0]*(fitsx-1)+solution_vectorY[1]*(fitsY-1)+solution_vectorY[2]); {correction y:=aX+bY+c}

        if ((x_new>=0) and (x_new<=width2-1) and (y_new>=0) and (y_new<=height2-1)) then
          for col:=0 to naxis3-1 do {all colors} img_temp[col,x_new,y_new]:=img_loaded[col,fitsX-1,fitsY-1] ;
      end;

      img_loaded:=img_temp;
      if pos('_aligned.fit',filename2)=0 then filename2:=ChangeFileExt(Filename2,'_aligned.fit');{rename only once}

      if nrbits=16 then
         save_fits(filename2,16,true)
        else
          save_fits(filename2,-32,true);
       memo2_message('New aligned image created: '+filename2);
      listview6.items[c].caption:=filename2;

      reset_solution_vectors(1);{aligned}
      save_solution_to_disk;{write solution_vectorX, solution_vectorY and solution_datamin to disk.}


    end;
  end;
  img_temp:=nil;

  Screen.Cursor :=Save_Cursor;{back to normal }
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

function JdToDate(jd:double):string;{Returns Date from Julian Date,  See MEEUS 2 page 63}
var A,B,C,D,E,F,G,J,M,T,Z: double; {!!! 2016 by purpose, otherwise with timezone 8, 24:00 midnigth becomes 15:59 UTC}
    HH, MM, SS           : integer;
    year3                : STRING[6];
begin
  if (abs(jd)>1461*10000) then begin result:='Error, JD outside allowed range!' ;exit;end;

  jd:=jd+(0.5/(24*3600));{2016 one 1/2 second extra for math errors, fix problem with timezone 8, 24:00 midnight becomes 15:59 UTC}

  Z:=trunc (JD + 0.5);
  F:=Frac(JD + 0.5);
  If Z < 2299160.5 Then A:=Z // < 15.10.1582 00:00 {Note Meeus 2 takes midday 12:00}
  else
  begin
   g:= int((Z-1867216.25) / 36524.25);
   a:=z+1+g-trunc(g/4);
  end;
  B := A+1524+ {special =>} (1461*10000);{allow up to 40.000 year in past, 1461 days *100000 = 4x 10000 years}
  C := trunc((B-122.1)/365.25);
  D := trunc(365.25 * C);
  E := trunc((B-D)/30.6001);
  T := B-D-int(30.6001*E) + F; {day of the month}
  if(E<14) then
    M := E-1
  else
    M := E-13;
  if (M>2) then
      J := C-4716
  else
      J := C-4715;

   j:=J - {special= >} 4*10000;{allow up to 40.000 year in past, 1461 days *100000 = 4x 10000 years}

  F:=fnmodulo(F,1);{for negative julian days}
  HH:=trunc(F*24);
  MM:=trunc((F-HH/24)*(24*60));{not round otherwise 23:60}
  SS:=trunc((F-HH/24-MM/(24*60))*(24*3600));

  str(trunc(j):4,year3);

  result:=year3+'-' +leadingzero(trunc(m))+'-'+leadingzero(trunc(t))+'T'+leadingzero(HH)+':'+leadingzero(MM)+':'+leadingzero(SS);
end;


FUNCTION julian_calc(yyyy,mm:integer;dd,hours,minutes,seconds:double):double; {##### calculate julian day, revised 2017}
var
   Y,M   : integer;
   A, B , T ,XX : double;
begin
  IF MM>2 THEN  begin Y:=YYYY; M:=MM;end
  else {MM=1 OR MM=2}
    begin Y:=YYYY-1; M:=MM+12;end;

  DD:=DD+HOURS/24+MINUTES/(24*60)+SECONDS/(24*60*60);

  if ((YYYY+MM/100+DD/10000)<1582.10149999) then B:=0 {year 1582 October, 15, 00:00 reform Gregorian to julian, 1582.10149999=1582.1015 for rounding errors}
  else                                                {test year 837 april 10, 0 hours is Jd 2026871.5}
  begin
    A:=INT(Y/100);
    B:=+ 2 - A + INT(A/4)
  end;

  if Y<0 then XX:=0.75 else xx:=0;{correction for negative years}
    result:=INT(365.25*Y-XX)+INT(30.6001*(M+1))
         + DD
         + B
         + 1720994.5;

end;

procedure date_obs_to_jd;{get julian day for date_obs, so the start of the observation}
var
   yy,mm,dd,hh,min,ss,error2 :integer;
begin
  jd:=0;
  val(copy(date_obs,18,2),ss,error2); if error2<>0 then exit;
  val(copy(date_obs,15,2),min,error2);if error2<>0 then exit;
  val(copy(date_obs,12,2),hh,error2);if error2<>0 then exit;
  val(copy(date_obs,09,2),dd,error2);if error2<>0 then exit;
  val(copy(date_obs,06,2),mm,error2);if error2<>0 then exit;
  val(copy(date_obs,01,4),yy,error2);if error2<>0 then exit;
  jd:=julian_calc(yy,mm,dd,hh,min,ss);{calculate julian date}
end;

procedure Tstackmenu1.extend_object_name_with_time_observation1Click(
  Sender: TObject);
var
   index,counter,error2: integer;
   interval: double;
   timestr,inp: string;
begin
  inp:=InputBox('Extend value keyword OBJECT with rounded Julian day','Hit cancel to abort. Type the rounding interval in seconds:','' );
  if length(inp)<=0 then exit;
  val(inp,interval,error2);
  if interval<1 then interval:=1;
  if error2<>0 then begin beep; exit; end;

  index:=0;
  counter:=listview1.Items.Count;
  while index<counter do
  begin
    if  listview1.Items[index].Selected then
    begin
      filename2:=listview1.items[index].caption;
      if load_image(false,false {plot}) then {load only}
      begin
        date_obs_to_jd;{get julian day for date_obs, so the start of the observation}

        jd:=round(jd*24*3600/interval)*interval/(24*3600); {round to time to interval }
        str(jd:1:5, timestr);
        if  pos('-JD',object_name)=0 then
          object_name:=object_name+'-JD'+timestr {add date_obs without seconds}
        else
          object_name:=copy(object_name,1,length(object_name)-16)+'-JD'+timestr;

         update_text('OBJECT  =',#39+object_name+#39); {spaces will be added/corrected later}

         filter_name_changed:=true;{allow reanalyse}

        if nrbits=16 then
        save_fits(filename2,16,true)
         else
        save_fits(filename2,-32,true);
      end
      else
      beep;{image not found}
    end;
    inc(index); {go to next file}
  end;
end;

procedure Tstackmenu1.FormPaint(Sender: TObject);
begin

 case pagecontrol1.tabindex of 7:more_indication1.visible:=stackmenu1.width<=export_aligned_files1.left+20;
                               8:more_indication1.visible:=stackmenu1.width<=Label_bin_oversampled1.left+20;
                               9:more_indication1.visible:=stackmenu1.width<=GroupBox_test_images1.left+20;
                               else more_indication1.visible:=false;

 end;
end;

procedure Tstackmenu1.help_blink1Click(Sender: TObject);
begin
   openurl('http://www.hnsky.org/astap.htm#blink');
end;

procedure Tstackmenu1.help_photometry1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#photometry');
end;

procedure Tstackmenu1.listview7CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: Boolean);
begin
  stackmenu1.nr_total_photometry1.caption:=inttostr(sender.items.count);{update counting info}
end;

procedure Tstackmenu1.listview7CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  {$ifdef mswindows}
  {$else} {unix}
  {temporary fix for CustomDraw not called}
  if  Item.index=0 then  stackmenu1.nr_total_photometry1.caption:=inttostr(sender.items.count);{update counting info}
  {$endif}
  Sender.Canvas.Font.Color := clmenutext;{required for high contrast settings. Otherwise it is always black}
end;

procedure Tstackmenu1.more_indication1Click(Sender: TObject);
begin
  case pagecontrol1.tabindex of 7:stackmenu1.Width:=export_aligned_files1.left+export_aligned_files1.width+10;{set width if clicked on arrow}
                                8:stackmenu1.Width:=Label_bin_oversampled1.left+Label_bin_oversampled1.width+10;
                                9:stackmenu1.Width:=GroupBox_test_images1.left+GroupBox_test_images1.width+10;
  end;
end;

procedure Tstackmenu1.photometry_binx2Click(Sender: TObject);
var
   c: integer;
   ext: string;
begin
  esc_pressed:=false;

  memo2_message('Binning images for better detection. Original files will not be affected.');

  for c:=0 to listview7.items.count-1 do
  begin
    if ((esc_pressed=false) and (listview7.Items.item[c].checked) )  then
    begin

      filename2:=listview7.items[c].caption;

      ext:=uppercase(ExtractFileExt(filename2));
      if ((ext='.FIT') or (ext='.FITS') or (ext='.FTS'))=false then
      begin
        memo2_message('█ █ █ █ █ █ Can not binx2. First analyse file list !! █ █ █ █ █ █');
        beep;
        exit;
      end;

      mainwindow.caption:=filename2;

      Application.ProcessMessages;
      if ((esc_pressed) or
          (binX2=false)) {converts filename2 to binx2 version}
          then exit;
      listview7.Items[c].Checked:=false;
      listview234567_add(listview7,filename2);{add binx2 file}
    end;
  end;{for loop for astrometric solving }
  {astrometric calibration}
end;


procedure save_stars_to_disk(filen : string; stars: star_list)  ;{write to disk}
type
    star = array[0..3] of double;
var
   i,count: integer;
   onestar: star;
   Savearray: file of star;{to save solution if required for second and third step stacking}
begin
  count:=length(stars[0])-1 ;
  AssignFile(savearray,ChangeFileExt(Filename2,'.astap_image_stars'));
  ReWrite(savearray);

  {special first record}
  onestar[0]:=count;
  onestar[1]:=flux_magn_offset;{store flux_magn_offset}
  onestar[2]:=width2;
  onestar[3]:=height2;
  Write(savearray, onestar); {save}

  for i:=0 to count do
  begin
    onestar[0]:=stars[0,i];
    onestar[1]:=stars[1,i];
    onestar[2]:=stars[2,i];
    onestar[3]:=stars[3,i];
    Write(savearray, onestar);
  end;
  CloseFile(savearray);
end;

procedure read_stars_from_disk(filen : string; var stars: star_list)  ;{read star info from disk}
type
    star = array[0..3] of double;
var
   i,count: integer;
   onestar: star;
   Savearray: file of star;{to save solution if required for second and third step stacking}
begin
  AssignFile(savearray,ChangeFileExt(Filename2,'.astap_image_stars'));
  Reset(savearray);
  Read(savearray,onestar);{retrieve first special record}
  count:=round(onestar[0]);{retrieve count}
  setlength(stars,4,count+1);{set size}
  flux_magn_offset:=onestar[1];{retrieve flux_magn_offset}
  width2:=round(onestar[2]);
  height2:=round(onestar[3]);

  for i:=0 to count do
  begin
    read(savearray, onestar);
    stars[0,i]:=onestar[0];
    stars[1,i]:=onestar[1];
    stars[2,i]:=onestar[2];
    stars[3,i]:=onestar[3];
  end;
  CloseFile(savearray);
end;

procedure find_star_outliers(report_upto_magn: double; var outliers : star_list) {contains the four stars with largest SD }   ;
var
  stepnr,x_new,y_new,step,c,i,j,nr_images : integer;
  stars_mean,stars_sd,stars_count : array of array of single;
  created : boolean;
  sd,xc,yc     : double;
  stars :star_list;
  m,magn:double;

const
    factor=5; {div factor to get small variations at the same location}
begin
  memo2_message('Searching for outliers');
  created:=false;
  stepnr:=0;
  nr_images:=0;


  setlength(outliers,4,4);
  for i:=0 to 3 do
   for j:=0 to 3 do
     outliers[i,j]:=0;

  repeat
    inc(stepnr);
    for c:=0 to stackmenu1.listview7.items.count-1 do {do all files}
    begin
      Application.ProcessMessages;
      if esc_pressed then begin outliers:=nil; exit; end;

      if stackmenu1.listview7.Items.item[c].checked  then
      begin {read solution}

        {load file, and convert astrometric solution to vector solution}
        filename2:=stackmenu1.listview7.items[c].caption;
        if load_fits(filename2,true {light},false {only read header},true {reset var},img_loaded)=false then begin esc_pressed:=true; exit;end;
        {calculate vectors from astrometric solution to speed up}
        sincos(dec0,SIN_dec0,COS_dec0); {do this in advance since it is for each pixel the same}
        astrometric_to_vector;{convert astrometric solution to vectors}


        read_stars_from_disk(filename2,stars)  ;{read from disk}

        if created=false then
        begin
          setlength(stars_mean,(width2 div factor)+1,(height2 div factor)+1);
          setlength(stars_sd,(width2 div factor)+1,(height2 div factor)+1);
          setlength(stars_count,(width2 div factor)+1,(height2 div factor)+1);
          for i:=0 to (width2 div factor) do
            for j:=0 to (height2 div factor) do
            begin
              stars_mean[i,j]:=0;
              stars_sd[i,j]:=0;
              stars_count[i,j]:=0;
            end;
          created:=true;
        end;

        if stepnr=1 then inc(nr_images);{keep record of number of images}
        try
          for i:=0 to min(length(stars[0])-2,5000) do {calculate mean of the found stars}
          begin
            xc:=(solution_vectorX[0]*(stars[0,i])+solution_vectorX[1]*(stars[1,i])+solution_vectorX[2]); {correction x:=aX+bY+c}
            yc:=(solution_vectorY[0]*(stars[0,i])+solution_vectorY[1]*(stars[1,i])+solution_vectorY[2]); {correction y:=aX+bY+c}
            if ((xc>=0) and (xc<=width2-1) and (yc>=0) and (yc<=height2-1)) then {image could be shifted. Prevent runtime errors}
            begin
              x_new:=round(xc/factor);
              y_new:=round(yc/factor);
              if stepnr=1 then
              begin {CALCULATE MEAN of stars}
                stars_mean[x_new,y_new]:=stars_mean[x_new,y_new]+ flux_magn_offset-ln(stars[3,i]{flux})*2.511886432/ln(10); {magnitude}
                stars_count[x_new,y_new]:=stars_count[x_new,y_new]+1;{counter}
              end
              else {CALCULATE SD of stars}
              if stepnr=2 then
              stars_sd[x_new,y_new]:= stars_sd[x_new,y_new]+sqr( (stars_mean[x_new,y_new]/stars_count[x_new,y_new])- (flux_magn_offset-ln(stars[3,i]{flux})*2.511886432/ln(10)) ); {sd calculate by sqr magnitude difference from mean}
            end;
          end;{for loop}
        except
          beep;
        end;

     end;
   end;{for c:=0 loop}
  until stepnr>2;

  {find largest outliers}
  for i:=0 to (width2 div factor) do
    for j:=0 to (height2 div factor) do
     begin
       try
       if stars_count[i,j]>=round(nr_images*0.8) then {at least in 80% of the cases star detection}
       if (stars_mean[i,j]/stars_count[i,j])<=report_upto_magn then {magnitude lower then}
       begin
         sd:=sqrt(stars_sd[i,j]/stars_count[i,j]);
         if sd>outliers[2,0] {largest sd} then
         begin
           outliers[0,3]:=outliers[0,2];{store old x}
           outliers[1,3]:=outliers[1,2];{store old y}
           outliers[2,3]:=outliers[2,2];{store OLD sd}

           outliers[0,2]:=outliers[0,1];{store old x}
           outliers[1,2]:=outliers[1,1];{store old y}
           outliers[2,2]:=outliers[2,1];{store OLD sd}

           outliers[0,1]:=outliers[0,0];{store old x}
           outliers[1,1]:=outliers[1,0];{store old y}
           outliers[2,1]:=outliers[2,0];{store OLD sd}

           outliers[0,0]:=i*factor;{store x}
           outliers[1,0]:=j*factor;{store y}
           outliers[2,0]:=SD;{store sd}
         end;
       end;

       except
         beep;
       end;
     end ;{for loop}

  if nr_images<6 then memo2_message('Warning, not enough images for reliable outlier detection');
  if outliers[2,0]<>0 then memo2_message('Found star 1 with HFD standard deviation '+ floattostr2(outliers[2,0])+' at x=' +inttostr(round(outliers[0,0]))+', y='+inttostr(round(outliers[1,0]))+' Marked with yellow circle.');
  if outliers[2,1]<>0 then memo2_message('Found star 2 with HFD standard deviation '+ floattostr2(outliers[2,1])+' at x=' +inttostr(round(outliers[0,1]))+', y='+inttostr(round(outliers[1,1]))+' Marked with yellow circle.' );
  if outliers[2,2]<>0 then memo2_message('Found star 3 with HFD standard deviation '+ floattostr2(outliers[2,2])+' at x=' +inttostr(round(outliers[0,2]))+', y='+inttostr(round(outliers[1,2]))+' Marked with yellow circle.' );
  if outliers[2,3]<>0 then memo2_message('Found star 4 with HFD standard deviation '+ floattostr2(outliers[2,3])+' at x=' +inttostr(round(outliers[0,3]))+', y='+inttostr(round(outliers[1,3]))+' Marked with yellow circle.' );


  stars:=nil;
  stars_sd:=nil;
  stars_mean:=nil;
  stars_count:=nil;

end;

procedure Tstackmenu1.photometry_button1Click(Sender: TObject);
var
  c,i,j: integer;
  Save_Cursor          : TCursor;
  magn,hfd1,star_fwhm,snr,flux,xc,yc         : double;
  x_new,y_new,fitsX,fitsY,col,first_image,size,starX,starY,stepnr: integer;
  flipvertical,fliphorizontal,init,refresh_solutions  :boolean;
  stars :star_list;
  outliers : array of array of double;
  extra_message,dd  : string;


begin
  if listview7.items.count<=1 then exit; {no files}
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  save_settings(user_path+'astap.cfg');{too many lost selected files . so first save settings}

 if listview7.Items.item[listview7.items.count-1].subitems.Strings[0]='' {exposire last row} then
      analyse_listview(listview7, 1 {analyse full header only});

  flipvertical:=mainwindow.Flipvertical1.Checked;
  fliphorizontal:=mainwindow.Fliphorizontal1.Checked;
  esc_pressed:=false;

  memo2_message('Checking for astrometric solutions in FITS header required for star flux calibration against star database.');

  refresh_solutions:=(sender=stackmenu1.clear_astrometric_solutions1); {refresh astrometric solutions}

  {solve images first to allow flux to magnitude calibration}
  for c:=0 to listview7.items.count-1 do {check for astrometric solutions}
  begin
    if listview7.Items.item[c].subitems.Strings[14+1]='' then {not check marked as done}
    if ((esc_pressed=false) and (listview7.Items.item[c].checked) )  then
    begin

      filename2:=listview7.items[c].caption;
      mainwindow.caption:=filename2;

      Application.ProcessMessages;
      if esc_pressed then break;
      {load image}
      if load_fits(filename2,true {light},true,true {reset var},img_loaded)=false then begin esc_pressed:=true; break;end;

      if ((cd1_1=0) or (refresh_solutions)) then
      begin
        listview7.Selected :=nil; {remove any selection}
        listview7.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview7.Items[c].MakeVisible(False);{scroll to selected item}
        memo2_message(filename2+ ' Adding astrometric solution to files to allow flux to magnitude calibration using the star database.');
        Application.ProcessMessages;

        if solve_image(img_loaded,true  {get hist}) then
        begin{match between loaded image and star database}
          mainwindow.SaveFITSwithupdatedheader1Click(nil);
          listview7.Items.item[c].subitems.Strings[13+1]:='✓';
        end
        else
        begin
          listview7.Items[c].Checked:=false;
          listview7.Items.item[c].subitems.Strings[13+1]:='';
          memo2_message(filename2+ 'Uncheck, no astrometric solution found for this file. Can not measure magnitude!');
        end;
      end
      else
      listview7.Items.item[c].subitems.Strings[13+1]:='✓';

    end;{check for astrometric solutions}
  end;{for loop for astrometric solving }
  {astrometric calibration}


  first_image:=-1;
  outliers:=nil;
  stepnr:=0;
  init:=false;

  memo2_message('Click on an object (pink marker) to record magnitudes in the photometry list.');

  repeat
    stepnr:=stepnr+1; {first step is nr 1}
    for c:=0 to listview7.items.count-1 do
    begin
      if ((esc_pressed=false) and (listview7.Items.item[c].checked) )  then
      begin
        if first_image=-1 then first_image:=c;
        listview7.Selected :=nil; {remove any selection}
        listview7.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview7.Items[c].MakeVisible(False);{scroll to selected item}

        filename2:=listview7.items[c].caption;
        mainwindow.caption:=filename2;

        Application.ProcessMessages;
        if esc_pressed then break;
        {load image}
        if load_fits(filename2,true {light},true,true {reset var},img_loaded)=false then begin esc_pressed:=true; break;end;

        getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}

        {check/prepare photometry}
        if fileexists(ChangeFileExt(Filename2,'.astap_image_stars'))=false then
        begin
          plot_stars(true {if true photometry only}, false {show Distortion});{measure the flux_magn_offset (flux=> magnitude factor)}
          if pos('F',calstat)=0 then
          begin
            extra_message:=' Image not calibrated with a flat field. Photometric accuracy will be lower. Calibrate images first using "calibrate only" option in stack menu.';
            listview7.Items.item[c].subitems.Strings[14+1]:='no calibration';
          end
          else
          begin
            extra_message:='';
            listview7.Items.item[c].subitems.Strings[14+1]:='✓';
          end;
          memo2_message(inttostr(counter_flux_measured)+ ' Gaia stars used for flux calibration.'+extra_message);
          measure_magnitudes(stars); {analyse}
          save_stars_to_disk(filename2, stars)  ;{write to disk including flux_magn_offset}
        end
        else
        begin
          read_stars_from_disk(filename2,stars)  ;{read from disk}
          if pos('F',calstat)=0 then  listview7.Items.item[c].subitems.Strings[14+1]:='no calibration' else listview7.Items.item[c].subitems.Strings[14+1]:='✓';
        end;

        setlength(img_temp,naxis3,width2,height2);{new size}

        {standard alligned blink}
        if init=false then {init}
        begin
          initialise1;{set variables correct for astrometric solution calculation. Use first files as reference}
          init:=true;
        end;

        {calculate vectors from astrometric solution to speed up}
        sincos(dec0,SIN_dec0,COS_dec0); {do this in advance since it is for each pixel the same}
        astrometric_to_vector;{convert astrometric solution to vectors}

        {shift, rotate to match images}
        for fitsY:=1 to height2 do
        for fitsX:=1 to width2  do
        begin
          x_new:=round(solution_vectorX[0]*(fitsx-1)+solution_vectorX[1]*(fitsY-1)+solution_vectorX[2]); {correction x:=aX+bY+c}
          y_new:=round(solution_vectorY[0]*(fitsx-1)+solution_vectorY[1]*(fitsY-1)+solution_vectorY[2]); {correction y:=aX+bY+c}
          if ((x_new>=0) and (x_new<=width2-1) and (y_new>=0) and (y_new<=height2-1)) then
             for col:=0 to naxis3-1 do {all colors} img_temp[col,x_new,y_new]:=img_loaded[col,fitsX-1,fitsY-1] ;
        end;

        img_loaded:=img_temp;
        CRPIX1:=round(solution_vectorX[0]*(CRPIX1-1)+solution_vectorX[1]*(CRPIX2-1)+solution_vectorX[2]);{correct for marker_position at ra_dec position}
        CRPIX2:=round(solution_vectorY[0]*(CRPIX1-1)+solution_vectorY[1]*(CRPIX2-1)+solution_vectorY[2]);

        plot_fits(mainwindow.image1,false {re_center});

        mainwindow.image1.Canvas.Pen.Mode := pmMerge;
        mainwindow.image1.Canvas.Pen.width :=round(1+height2/mainwindow.image1.height);{thickness lines}
        mainwindow.image1.Canvas.brush.Style:=bsClear;
        mainwindow.image1.Canvas.font.color:=clyellow;
        mainwindow.image1.Canvas.font.size:=10; //round(max(10,8*height2/image1.height));{adapt font to image dimensions}
        mainwindow.image1.Canvas.Pen.Color := clred;

        listview7.Items.item[c].subitems.Strings[10+1]:=''; {MAGN, always blank}

        {measure the single star clicked on by mouse}
        if mainwindow.shape_alignment_marker1.visible then
        begin
          HFD(img_loaded,round(shape_fitsX-1),round(shape_fitsY-1), hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if ((hfd1<15) and (hfd1>0) and (snr>10)) then {star detected in img_loaded}
          begin
            if ((img_loaded[0,round(xc),round(yc)]<60000) and
                (img_loaded[0,round(xc-1),round(yc)]<60000) and
                (img_loaded[0,round(xc+1),round(yc)]<60000) and
                (img_loaded[0,round(xc),round(yc-1)]<60000) and
                (img_loaded[0,round(xc),round(yc+1)]<60000) and

                (img_loaded[0,round(xc-1),round(yc-1)]<60000) and
                (img_loaded[0,round(xc-1),round(yc+1)]<60000) and
                (img_loaded[0,round(xc+1),round(yc-1)]<60000) and
                (img_loaded[0,round(xc+1),round(yc+1)]<60000)  ) then {not saturated}
            begin
              magn:=flux_magn_offset-ln(flux)*2.511886432/ln(10);
              listview7.Items.item[c].subitems.Strings[10+1]:=floattostrf(magn, ffgeneral, 5,0); {write measured magnitude to list}
            end;
            for i:=0 to  length(stars[0])-2 do
            begin
              size:=round(5*stars[2,i]);{5*hfd}
            end;
          end;
         end;

         {plot measured stars from procedure measure_magnitudes}
         for i:=0 to  length(stars[0])-2 do
         begin
           size:=round(5*stars[2,i]);{5*hfd}
           x_new:=round(solution_vectorX[0]*(stars[0,i])+solution_vectorX[1]*(stars[1,i])+solution_vectorX[2]); {correction x:=aX+bY+c}
           y_new:=round(solution_vectorY[0]*(stars[0,i])+solution_vectorY[1]*(stars[1,i])+solution_vectorY[2]); {correction y:=aX+bY+c}

           if Flipvertical=false then  starY:=(height2-y_new) else starY:=(y_new);
           if Fliphorizontal     then starX:=(width2-x_new)  else starX:=(x_new);

           mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
           magn:=flux_magn_offset-ln(stars[3,i]{flux})*2.511886432/ln(10);
           mainwindow.image1.Canvas.textout(starX+size,starY,floattostrf(magn*10, ffgeneral, 3,0));{add hfd as text}

           if ( (abs(shape_fitsX-x_new)<6) and (abs(shape_fitsY-y_new)<6) ) then
            listview7.Items.item[c].subitems.Strings[10+1]:=floattostrf(magn, ffgeneral, 5,0); {write measured magnitude to list}

        end;{measure single star clicked on}


        {plot outliers (variable stars)}
        if outliers<>nil then
        begin
          mainwindow.image1.Canvas.Pen.Color := clyellow;
          for i:=0 to length(outliers[0])-1 do
          begin
            if Flipvertical=false then  starY:=round(height2-(outliers[1,i])) else starY:=round(outliers[1,i]);
            if Fliphorizontal     then starX:=round(width2-outliers[0,i])  else starX:=round(outliers[0,i]);
            mainwindow.image1.Canvas.ellipse(starX-20,starY-20, starX+20, starY+20);{indicate outlier rectangle}
            mainwindow.image1.Canvas.textout(starX+20,starY+20,'σ '+floattostrf(outliers[2,i], ffgeneral, 3,0));{add hfd as text}
          end;
        end;
      end;{find star magnitudes}
    end;
    if stepnr=1 then {do it once after one cycle completed}
       find_star_outliers(strtofloat2(mark_outliers_upto1.text), outliers);
  until ((esc_pressed) or (sender=photometry_button1 {single run}));

  img_temp:=nil;{free memory}
  stars:=nil;{free memory}
  outliers:=nil;

  Screen.Cursor :=Save_Cursor;{back to normal }
end;


//procedure colour_fix_saturated_pixels(var img: image_array; level:double);{bring colour back in saturated stars}
//var
//   fitsX,fitsY: integer;
//   red,green,blue : double;
//begin
//  if naxis3<3 then exit;{prevent run time error mono images}

//  for fitsY:=0 to height2-1 do
//    for fitsX:=0 to width2-1 do
//    begin
//        red:=img_loaded[0,fitsX,fitsY];
//        green:=img_loaded[1,fitsX,fitsY];
//        blue:=img_loaded[2,fitsX,fitsY];

//        if ((red>level) or  (green>level) or (blue>level)) then {saturation, use two pixel backwards}
//        begin
//          if ((fitsX>=2) and (fitsY>=1)) then
//          begin
//            img_loaded[0,fitsX,fitsY]:=(img_loaded[0,fitsX-2,fitsY]+img_loaded[0,fitsX-1,fitsY-1])/2;
//            img_loaded[1,fitsX,fitsY]:=(img_loaded[1,fitsX-2,fitsY]+img_loaded[1,fitsX-1,fitsY-1])/2;
//            img_loaded[2,fitsX,fitsY]:=(img_loaded[2,fitsX-2,fitsY]+img_loaded[2,fitsX-1,fitsY-1])/2;
//          end;
//        end;
//     end;
//end;

{can be removed test routine}

procedure star_smooth(img: image_array;x1,y1: integer);
const
   max_ri=50; //sqrt(sqr(rs+rs)+sqr(rs+rs))+1;
  var
    x2,y2,rs,i,j,k,counter,col,drop_off                             :integer;
    val,bg_average,rgb,luminance  : double;
    color,bg,bg_standard_deviation  : array[0..2] of double;
    value_histogram : array [0..max_ri] of double;
begin
  rs:=14;{14 is test box of 28, HFD maximum is about 28}

  if ((x1-rs-4<=0) or (x1+rs+4>=width2-1) or
      (y1-rs-4<=0) or (y1+rs+4>=height2-1) )
    then begin exit;end;

  try
    for col:=0 to 2 do
    begin
      counter:=0;
      bg_average:=0;
      for i:=-rs-4 to rs+4 do {calculate mean at square boundaries of detection box}
      for j:=-rs-4 to rs+4 do
      begin
        if ( (abs(i)>rs) and (abs(j)>rs) ) then {measure only outside the box}
        begin
          val:=img[col,x1+i,y1+j];
          if val>0 then
          begin
            bg_average:=bg_average+val;
            inc(counter)
          end;

        end;
      end;
      bg_average:=bg_average/(counter+0.0001); {mean value background}
      bg[col]:=bg_average;
    end;


    for col:=0 to 2 do
    begin
      counter:=0;
      bg_standard_deviation[col]:=0;
      for i:=-rs-4 to rs+4 do {calculate standard deviation background at the square boundaries of detection box}
        for j:=-rs-4 to rs+4 do
        begin
          if ( (abs(i)>rs) and (abs(j)>rs) ) then {measure only outside the box}
          begin
            val:=img[col,x1+i,y1+j];
            if ((val<=2*bg[col]) and (val>0)) then {not an outlier}
            begin
              bg_standard_deviation[col]:=bg_standard_deviation[col]+sqr(bg[col]-val);
              inc(counter);
            end;
          end;
      end;
      bg_standard_deviation[col]:=sqrt(bg_standard_deviation[col]/(counter+0.0001)); {standard deviation in background}
    end;

    for k:=0 to max_ri do {calculate distance to average value histogram}
    begin
      val:=0;
      counter:=0;
      for i:=-k to k do {square around center}
      begin
        val:=val+img[col,x1+i,y1+k];
        val:=val+img[col,x1+i,y1-k];
        val:=val+img[col,x1+k,y1+i];
        val:=val+img[col,x1-k,y1+i];
        inc(counter,4);
      end;
      value_histogram[k]:=val/counter;{add average value for distance k from center}
    end;

    k:=0;
    repeat  {find slow down star value from center}
      inc(k);
    until ((value_histogram[k-1]<1.3*value_histogram[k]) or (k>=max_ri));
    drop_off:=k;



// Get average star colour
   for col:=0 to 2 do
   begin
      color[col]:=0;
      for i:=-rs to rs do
      for j:=-rs to rs do
      begin
        x2:=x1+i;
        y2:=y1+j;
        if  sqr(drop_off)>i*i+j*j then {within star}
        begin
          val:=img[col,x2,y2]-bg[col];
          if val<60000 {not saturated} then
            color[col] :=color[col]+   img[col,x2,y2]-bg[col];{if written in seperate term it would be 20% faster but having fixed steps}

        end;
      end;
   end;

// apply average star colour on pixels
  rgb:=color[0]+color[1]+color[2]+0.00001; {0.00001, prevent dividing by zero}

  for i:=-rs to rs do
  for j:=-rs to rs do
  begin
    x2:=x1+i;
    y2:=y1+j;
    if  sqr(drop_off)>i*i+j*j then {within star}
    begin
       luminance:=( img[0,x2,y2]-bg[0]
                    +img[1,x2,y2]-bg[1]
                    +img[2,x2,y2]-bg[2])/3;
        img[0,x2,y2]:=bg[0]+luminance*color[0]/rgb;
        img[1,x2,y2]:=bg[1]+luminance*color[1]/rgb;
        img[2,x2,y2]:=bg[2]+luminance*color[2]/rgb;

        img_temp[0,x2,y2]:=1; {mark as processed}
    end;
  end;

  except
  end;
end;

{can be removed test routine}
procedure smooth_button_test( var img: image_array; wide : integer);{combine color values of 5x5 pixels, keep luminance intact}
var fitsX,fitsY : integer;
  pixel_value : double;
begin
  if length(img)<3 then exit;{not a three colour image}


  setlength(img_temp,1,width2,height2);{set length of image array}
  for fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1 do
      begin
        img_temp[0,fitsX,fitsY]:=0;
      end;

  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
    if img_temp[0,fitsX,fitsY]=0 then {clean area}
    begin
      pixel_value:=img[0,fitsX,fitsY]+img[1,fitsX,fitsY]+img[2,fitsX,fitsY]/3;
      if pixel_value>60000 then
        star_smooth(img_loaded,fitsX,fitsY);
    end;
end;


procedure smart_colour_smooth( var img: image_array; wide : integer; measurehist:boolean);{Bright star colour smooth. Combine color values of wide x wide pixels, keep luminance intact}
var fitsX,fitsY,x,y,step,x2,y2,count,d,vcount  : integer;
    img_temp2            : image_array;
    luminance,red,green,blue,rgb,r,g,b,sqr_dist,v,sdev,lowest,highest,top,bg,r2,g2,b2,noise_level1,ratio,
    h,s,i, peak,bgR2,bgB2,bgG2,nebula_level: single;
    bgR,bgB,bgG  : double;
    copydata : boolean;
begin
  if length(img)<3 then exit;{not a three colour image}

  setlength(img_temp2,3,width2,height2);{set length of image array}

  step:= wide div 2;

  get_background(0,img_loaded,measurehist {hist},true  {noise level},{var} bgR,star_level);{calculate red background, noise_level and star_level}
  get_background(1,img_loaded,measurehist {hist},false{noise level},{var} bgG,star_level);{calculate green background}
  get_background(2,img_loaded,measurehist {hist},false {noise level},{var} bgB,star_level);

  noise_level1:=noise_level[0];{red noise}
  bg:=(bgR+bgG+bgB)/3; {average background}

  for fitsY:=0 to height2-1 do
  for fitsX:=0 to width2-1 do
  begin


    red:=0;
    green:=0;
    blue:=0;
    count:=0;
    peak:=0;
    bgR2:=65535;
    bgG2:=65535;
    bgB2:=65535;

    r2:=img[0,fitsX,fitsY]-bgR;
    g2:=img[1,fitsX,fitsY]-bgG;
    b2:=img[2,fitsX,fitsY]-bgB;

//    if luminance>3*noise_level[0] then
//    if luminance>5000 then

    if ( (r2>3*noise_level1) or (g2>3*noise_level1) or (b2>3*noise_level1) ) then {some relative flux}
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
               r:= img[0,x2,y2];
               G:= img[1,x2,y2];
               B:= img[2,x2,y2];

               {find peak value}
               if r>peak then peak:=r;
               if g>peak then peak:=g;
               if b>peak then peak:=b;
               {find lowest values. In some case background nebula}
               if r<bgR2 then bgR2:=r;
               if g<bgG2 then bgG2:=g;
               if b<bgB2 then bgB2:=b;

               if ((r<60000) and (g<60000) and (b<60000)) then  {no saturation, ignore saturated pixels}
               begin
               //  for d:=0 to round(step/sqrt(sqr_dist+1)) do {reduce influence for increased distance}
                 begin
                   if (r-bgR)>0 then
                              red  :=red+   (r-bgR); {level >0 otherwise centre of M31 get yellow circle}
                   if (g-bgG)>0 then green:=green+ (g-bgG);
                   if (b-bgB)>0 then blue:= blue + (b-bgB);
                   inc(count);
                 end;
               end;
             end;
           end;
         end;
      end;

      copydata:=true;
      rgb:=0;
      if count>=1 then
      begin
   //     if ((fitsx>=2073) and (fitsY>=1434)) then
   //     beep;

        red:=red/count;{scale using the number of data points=count}
        green:=green/count;
        blue:=blue/count;

        if peak>star_level then {star level very close}


        if ((red>3*noise_level1+4*(bgR2-bgR)) or (green>3*noise_level1+4*(bgG2-bgG)) or (blue>3*noise_level1+4*(bgB2-bgB)) ) then {enough flux, so bright flux measured. Factor +4*(bgG2-bgG) for stars in nebula}
//      if ((red>3*noise_level1) or (green>3*noise_level1) or (blue>3*noise_level1) ) then {enough flux, so bright flux measured}

        begin

          if red>blue then lowest:=blue else lowest:=red;

          if red<blue*1.06 then {>6000k} green:=0.6604*red+0.3215*blue; {prevent purple stars, purple stars are physical not possible. Emperical formula calculated from colour table http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html}

          luminance:=(r2+g2+b2)/3;
          rgb:=(red+green+blue+0.00001)/3; {0.00001, prevent dividing by zero}
          highest:=max(red,max(green,blue));
          top:=bg+luminance*highest/rgb;{calculate the highest colour value}
          if top>=65534.99 then luminance:=luminance-(top-65534.99)*rgb/highest;{prevent values above 65535}

          img_temp2[0,fitsX  ,  fitsY  ]:=bg+ luminance*red/rgb;
          img_temp2[1,fitsX  ,  fitsY  ]:=bg+ luminance*green/rgb;
          img_temp2[2,fitsX  ,  fitsY  ]:=bg+ luminance*blue/rgb;
          copydata:=false;{data is already copied}
       end;
     end;
     if copydata then {keep orginal data but adjust zero level}
     begin
       img_temp2[0,fitsX  ,  fitsY  ]:=max(0,bg+r2);{copy data, but equalise background levels}
       img_temp2[1,fitsX  ,  fitsY  ]:=max(0,bg+g2);
       img_temp2[2,fitsX  ,  fitsY  ]:=max(0,bg+b2);
     end;

  end;
  img:=img_temp2;{copy the array}
  img_temp2:=nil;
end;


procedure Tstackmenu1.smart_colour_smooth_button1Click(Sender: TObject);
var
  Save_Cursor:TCursor;
  above_level, sigma : double;
  sigmastr : string;
begin
  if Length(img_loaded)<3 then
  begin
    memo2_message('Error, no three colour image loaded!');
    exit;
  end;
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  backup_img;

  smart_colour_smooth(img_loaded, round(strtofloat2(smart_smooth_width1.text)),false);

  plot_fits(mainwindow.image1,false);{plot real}

  Screen.Cursor:=Save_Cursor;
end;

procedure Tstackmenu1.classify_filter1Click(Sender: TObject);
begin
  if ((classify_filter1.checked) and (make_osc_color1.checked)) then
  begin
    memo2_message('■■■■■■■■■■■■■ Due to check-mark "Classify by filter", un-checked "Convert OSC images to colour" ! ■■■■■■■■■■■■■');
    make_osc_color1.checked:=false;
  end;
end;




{most common filter works better
//procedure extraxt_background(box_size: integer);
// var
//    fitsx,fitsy,i,j,col,step,count : integer;
//    median,variance,sigma,value,mean  : double;

// begin
//   memo2_message('Extract background of '+filename2);

//   if (box_size div 2)*2=box_size then box_size:=box_size+1;{requires odd 3,5,7....}
//   step:=box_size div 2; {for 3*3 it is 1, for 5*5 it is 2...}

//   for col:=0 to naxis3-1 do {do all colours}
//   for fitsY:=0 to height2-1 do
//   begin
//     for fitsX:=0 to width2-1 do
//     begin
//       if ((frac(fitsX/box_size)=0) and (frac(fitsy/box_size)=0)) then
//       begin
//         median:=median_background(col,box_size,fitsX,fitsY);

         {get sigma/standard deviation}
//         variance:=0;
//         count:=0;
//       for j:=fitsy-step to  fitsy+step do
//         for i:=fitsx-step to fitsx+step do
//         begin
//           if ((i>=0) and (i<width2) and (j>=0) and (j<height2) ) then {within the boundaries of the image array}
//          begin
//               variance:= variance+sqr(img_loaded[col,i,j]-median);
//               inc(count);
//             end;
//           end;
//           variance:=variance/count;

         {remove outliers and calculate mean}
//         count:=0;
//         mean:=0;
//         for j:=fitsy-step to  fitsy+step do
//           for i:=fitsx-step to fitsx+step do
//           begin
//             if ((i>=0) and (i<width2) and (j>=0) and (j<height2) ) then {within the boundaries of the image array}
//             begin
//               value:=img_loaded[col,i,j];
//               if sqr(value-median)< variance* sqr(2.5) then
//                mean:=mean+value;
//                inc(count)
//             end;
//           end;
//        mean:=mean/count;

        {replace values by mean}
//        count:=0;
//        for j:=fitsy-step to  fitsy+step do
//          for i:=fitsx-step to fitsx+step do
//          begin
//            if ((i>=0) and (i<width2) and (j>=0) and (j<height2) ) then {within the boundaries of the image array}
//            begin
//              img_loaded[col,i,j]:=mean;
//            end;
//          end;
//
//       end;
//     end;
//   end;
// end;

procedure Tstackmenu1.apply_get_background1Click(Sender: TObject);
var
   Save_Cursor : TCursor;
   radius      : integer;
begin
  if fits_file=true then
  begin
     Save_Cursor := Screen.Cursor;
     Screen.Cursor := crHourglass;    { Show hourglass cursor }
     backup_img; {move copy to img_backup}
     try radius:=strtoint(extract_background_box_size1.text);except end;
     apply_most_common(img_backup,img_loaded,radius); {apply most common filter on first array and place result in second array}
     plot_fits(mainwindow.image1,true);{plot real}
     Screen.Cursor:=Save_Cursor;
  end;
end;



procedure Tstackmenu1.help_osc_menu1Click(Sender: TObject);
begin
   openurl('http://www.hnsky.org/astap.htm#osc_menu');
end;
procedure Tstackmenu1.help_uncheck_outliers1Click(Sender: TObject);
begin
    openurl('http://www.hnsky.org/astap.htm#uncheck_outliers');
end;


procedure Tstackmenu1.listview5CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  Sender.Canvas.Font.Color := clmenutext;{required for high contrast settings. Otherwise it is always black}
end;


procedure Tstackmenu1.list_to_clipboard1Click(Sender: TObject); {copy seleced lines to clipboard}
var
  index,c : integer;
  info : string;
  lv  : tlistview;
begin
  info:='';
  if sender=list_to_clipboard7 then lv:=listview7
  else
   lv:=listview1;

  {get column names}
  for c := 0 to lv.Items[0].SubItems.Count do
       info:=info+lv.columns[c].caption+#9;
  info:=info+slinebreak;

  {get data}
  for index:=0 to lv.items.count-1 do
  begin
    if  lv.Items[index].Selected then
    begin
      info:=info+lv.items[index].caption;
      {get sub items}
      for c := 0 to lv.Items[index].SubItems.Count - 1 do
         info:=info+#9+lv.Items.item[index].subitems.Strings[c];
      info:=info+slinebreak;
    end;
  end;
  Clipboard.AsText:=info;
end;

procedure Tstackmenu1.make_osc_color1Click(Sender: TObject);
begin
  if ((make_osc_color1.checked) and (classify_filter1.checked)) then
  begin
    memo2_message('■■■■■■■■■■■■■ Due to check-mark "Convert OSC images to colour", un-checked "Classify by filter" ! ■■■■■■■■■■■■■');
    classify_filter1.checked:=false;
  end;

  {enabe/disable related menu options}
  osc_colour_smooth1.enabled:=make_osc_color1.checked;
  bayer_pattern1.enabled:=make_osc_color1.checked;
  test_pattern1.enabled:=make_osc_color1.checked;
  demosaic_method1.enabled:=make_osc_color1.checked;
  osc_colour_smooth1.enabled:=make_osc_color1.checked;
end;

procedure select_all(tt :tlistview);
var
  i:integer;
begin
  tt.Items.BeginUpdate;
  for i := 0 to tt.Items.Count-1 do tt.Items[i].Selected:=true;
  tt.Items.EndUpdate;

  tt.setfocus;{set focus for next ctrl-C. Somehow it is lost}
end;

procedure Tstackmenu1.selectall1Click(Sender: TObject);
begin
  if sender=selectall1 then select_all(listview1);{popupmenu}
  if sender=selectall2 then select_all(listview2);{popupmenu}
  if sender=selectall3 then select_all(listview3);{popupmenu}
  if sender=selectall4 then select_all(listview4);{popupmenu}
  if sender=selectall6 then select_all(listview6);{popupmenu blink}
  if sender=selectall7 then select_all(listview7);{popupmenu photometry}
end;

procedure remove_background( var img: image_array);
var fitsX,fitsY        : integer;
    luminance,red,green,blue : double;
begin
  if length(img)<3 then exit;{not a three colour image}

  for fitsY:=2 to height2-1-2 do
    for fitsX:=2 to width2-1-2 do
    begin

      red:=img[0,fitsX,fitsY];
      green:=img[1,fitsX,fitsY];
      blue:=img[2,fitsX,fitsY];

      luminance:=red+blue+green+0.00001; {0.00001, prevent dividing by zero}

      img[0,fitsX  ,  fitsY  ]:=red/luminance;
      img[1,fitsX  ,  fitsY  ]:=green/luminance;
      img[2,fitsX  ,  fitsY  ]:=blue/luminance;
    end;

end;


procedure Tstackmenu1.apply_remove_background_colour1Click(Sender: TObject);
var
   Save_Cursor:TCursor;
   fitsX,fitsY: integer;
   background_r,background_g,background_b, red,green,blue,signal_R,signal_G,signal_B,sigmaR, sigmaG, sigmaB : double;
begin
  if naxis3<3 then exit;{prevent run time error mono images}
//  if fits_file=false then exit;
  Save_Cursor := Screen.Cursor;
  Screen.Cursor:= crHourGlass;

  backup_img;

  sigmaR:=strtofloat2(sigma_factor_remove_background_colourR1.text);{standard deviation factor used}
  sigmaG:=strtofloat2(sigma_factor_remove_background_colourG1.text);{standard deviation factor used}
  sigmaB:=strtofloat2(sigma_factor_remove_background_colourB1.text);{standard deviation factor used}


  get_background(1,img_loaded,true {hist},true {noise level},{var}background_G, star_level);{calculate background and noise_level}
  get_background(2,img_loaded,true {hist},true {noise level}, {var}background_B, star_level);{calculate background and noise_level}
  {red at last since all brigthness/contrast display is based on red}
  get_background(0,img_loaded,true {hist},true {noise level}, {var}background_R, star_level);{calculate background and noise_level}



  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
    begin
        red:=img_loaded[0,fitsX,fitsY];
        green:=img_loaded[1,fitsX,fitsY];
        blue:=img_loaded[2,fitsX,fitsY];

        if ((red-background_r<sigmaR*noise_level[0]) and (green-background_G<sigmaG*noise_level[1]) and (blue-background_B<sigmaB*noise_level[2])) then
        begin {distribute the colour to luminance}
          signal_R:=(red-background_r)/3;
          signal_G:=(green-background_G)/3;
          signal_B:=(blue-background_B)/3;
          red:=background_r+signal_R+signal_G+signal_B;
          green:=background_G+signal_R+signal_G+signal_B;
          blue:=background_B+signal_R+signal_G+signal_B;
        end;
        img_loaded[0,fitsX  ,  fitsY  ]:=red;
        img_loaded[1,fitsX  ,  fitsY  ]:=green;
        img_loaded[2,fitsX  ,  fitsY  ]:=blue;
     end;
   plot_fits(mainwindow.image1,false);{plot}
   Screen.cursor:=Save_Cursor;
end;

procedure Tstackmenu1.reset_factors1Click(Sender: TObject);
begin
  add_valueR1.Text:='0.0';
  add_valueG1.Text:='0.0';
  add_valueB1.Text:='0.0';

  edit_noise1.Text:='0.0';

  multiply_red1.Text:='1.0';
  multiply_green1.Text:='1.0';
  multiply_blue1.Text:='1.0';

end;

procedure Tstackmenu1.search_fov1Change(Sender: TObject);
begin
  fov_specified:=true;{user has entered a FOV manually}
end;

procedure Tstackmenu1.noisefilter_sd1Change(
  Sender: TObject);
begin

end;


procedure Tstackmenu1.analyseblink1Click(Sender: TObject);
var
   c: integer;
begin
  analyse_listview(listview6, 1 {header full only});

  for c:=0 to listview6.items.count-1 do {this is not required but nice}
  begin
    if fileexists(ChangeFileExt(listview6.items[c].caption,'.astap_solution')) then {read solution}
       listview6.Items.item[c].subitems.Strings[8]:='✓'
    else
    listview6.Items.item[c].subitems.Strings[8]:='';{clear alignment marks}
  end;
end;

procedure Tstackmenu1.analysephotometry1Click(Sender: TObject);
var
   c: integer;
begin
  if sender=analysephotmetrymore1 then
    analyse_listview(listview7, 3 {analyse background, HFD, stars})
  else
    analyse_listview(listview7, 1 {full header only});

  for c:=0 to listview7.items.count-1 do {this is not required but nice}
  begin
    if fileexists(ChangeFileExt(listview7.items[c].caption,'.astap_image_stars')) then {photometric solution}
       listview7.Items.item[c].subitems.Strings[14+1]:='✓'
    else
    listview7.Items.item[c].subitems.Strings[14+1]:='';
  end;
end;
procedure Tstackmenu1.auto_background_level1Click(Sender: TObject);
var
    r,g,b,star_levelR, star_levelG,star_levelB : double;
begin
  if length(img_loaded)<3 then exit;{not a three colour image}

  apply_factor1.enabled:=false;{block apply button temporary}
  application.processmessages;

  get_background(1,img_loaded,true {get hist},true {get noise},{var} G,star_levelG);
//  star_levelG:=star_level;{star is value above background}
  get_background(2,img_loaded,true {get hist},true {get noise},{var} B,star_levelB);
//  star_levelB:=star_level;{star is value above background}
  {Do red last to maintain current histogram}
  get_background(0,img_loaded,true {get hist},true {get noise},{var} R,star_levelR);
//  star_levelR:=star_level;{star is value above background}

  add_valueR1.text:=floattostrf(0, ffgeneral, 5,0);
  add_valueG1.text:=floattostrf(R*(star_levelG/star_levelR)-G, ffgeneral, 5,0);
  add_valueB1.text:=floattostrf(R*(star_levelB/star_levelR)-B, ffgeneral, 5,0);

  multiply_green1.text:=floattostrf(star_levelR/star_levelG, ffgeneral, 5,0); {make stars white}
  multiply_blue1.text:=floattostrf(star_levelR/star_levelB, ffgeneral, 5,0);
  multiply_red1.text:='1';

  apply_factor1.enabled:=true;{enable apply button}
end;

procedure background_noise_filter(img : image_array; max_deviation,blur:double);
var
  fitsX,fitsY,count,i,j,col,stepsize :integer;
  SD1, average1, SD, average, maxoffs ,val: double;
  img_outliers  : image_array;
const
   step=100;
begin
  setlength(img_outliers,naxis3,width2,height2);{set length of image array mono}

  for col:=0 to naxis3-1 do {do all colours}
  begin

    {first estimate of background mean and sd, star will be included}
    average1:=0;
    count:=0;
    For fitsY:=0 to (height2-1) div step do
      for fitsX:=0 to (width2-1) div step do
      begin
         val:=img[col,fitsX * step,fitsY * step];
         if val<32000 then average1:=average1+val;
         inc(count);
      end;
    average1:=average1/count;

    sd1:=0;
    count:=0;
    For fitsY:=0 to (height2-1) div step do
    for fitsX:=0 to (width2-1) div step do
    begin
      val:=img[col,fitsX *step,fitsY *step];
      if val<32000 then sd1:=sd1+sqr(average1-val);
      inc(count);
    end;
    sd1:=sqrt(sd1/(count)); {standard deviation}

    {second estimate of mean and sd, star will be excluded}
    average:=0;
    sd:=0;
    count:=0;
    For fitsY:=0 to height2-1  do
    for fitsX:=0 to width2-1 do
    begin
      val:=img[col,fitsX,fitsY];
      if val<average1+5*sd1 then average:=average+val;
      inc(count);
    end;

    average:=average/count;
    For fitsY:=0 to height2-1 do
      for fitsX:=0 to width2-1 do
      begin
        val:=img[col,fitsX,fitsY];
        if val<average1+5*sd1 then sd:=sd+sqr(average-val);
        inc(count);
      end;
    sd:=sqrt(sd/(count)); {standard deviation}
    maxoffs:=max_deviation*sd;{typically 3}

    for fitsY:=0 to height2-1 do  {mark signal pixel and store in img_outliers}
    for fitsX:=0 to width2-1 do
    begin
      if (img[col,fitsX, fitsY]-average)>maxoffs then {signal}
        img_outliers[col,fitsX, fitsY]:=img[col,fitsX, fitsY]    {store as signal}
       else
       begin
         count:=0;
         {find if signal nearby}
         stepsize:=round(blur*1.5);{adapt range to gaussian blur range}
         for i:=-stepsize to stepsize do
         for j:=-stepsize to stepsize do
         if ((fitsX+i>=0) and (fitsX+i<width2) and (fitsY+j>=0) and (FitsY+j<height2))  then
         begin
           if (img[col,fitsX+i, fitsY+j]-average)>maxoffs then {signal}
           begin
             inc(count);
           end;
         end;

         if count>0 then {signal}
         begin
           img_outliers[col,fitsX, fitsY]:=img[col,fitsX, fitsY];{store outlier for possible restoring}
           img[col,fitsX, fitsY]:=average;{change hot pixel to average}
         end
         else
          img_outliers[col,fitsX, fitsY]:=0;{not signal}
       end;
    end;
  end;{all colours}

  gaussian_blur2(img,blur);{apply gaussian blur }

  {restore signal}
  for col:=0 to naxis3-1 do {do all colours}
  for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
    begin
      if img_outliers[col,fitsX, fitsY]<>0 then
        img[col,fitsX, fitsY]:=img_outliers[col,fitsX, fitsY];
    end;
  img_outliers:=nil;
end;

procedure Tstackmenu1.apply_background_noise_filter1Click(Sender: TObject);
var    Save_Cursor:TCursor;
begin
  if Length(img_loaded)=0 then
  begin
    memo2_message('Error, no image in viewer loaded!');
    exit;
  end;
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  backup_img;
  background_noise_filter(img_loaded,strtofloat2(stackmenu1.noisefilter_sd1.text),strtofloat2(stackmenu1.noisefilter_blur1.text));

//  getfits_histogram(true);{get histogram}
  plot_fits(mainwindow.image1,false);{plot real}

  Screen.Cursor:=Save_Cursor;
end;

procedure Tstackmenu1.align_blink1Change(Sender: TObject);
begin
  blink_star_filter1.enabled:=align_blink1.checked;
  sd_factor_blink1.enabled:=align_blink1.checked;
  extra_star_supression_diameter1.enabled:=align_blink1.checked;
end;

procedure Tstackmenu1.alignment1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure Tstackmenu1.add_noise1Click(Sender: TObject);
var
  fitsX,fitsY,col: integer;
  noise          : single;
  Save_Cursor:TCursor;
begin
  if fits_file=true then
  begin
    backup_img; {move viewer data to img_backup}

    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    noise:=strtofloat2(stackmenu1.edit_noise1.Text);

    for fitsY:=0 to height2-1 do
    for fitsX:=0 to width2-1 do
    for col:=0 to naxis3-1 do
      img_loaded[col,fitsX,fitsY]:=max(0,img_loaded[col,fitsX,fitsY]+randg(3*noise,noise){gaussian noise});

    plot_fits(mainwindow.image1,false);{plot real}
    Screen.Cursor:=Save_Cursor;
   end;
end;

procedure Tstackmenu1.blink_star_filter1Change(Sender: TObject);
begin
  //esc_pressed:=true;{stop blinking to prevent runtime errors}
  sd_factor_blink1.enabled:=blink_star_filter1.checked;
  extra_star_supression_diameter1.enabled:=blink_star_filter1.checked;
end;

procedure Tstackmenu1.blink_stop1Click(Sender: TObject);
begin
  esc_pressed:=true;
end;

procedure Tstackmenu1.blink_unaligned_multi_step1Click(Sender: TObject);
var
  c,i,j: integer;
  Save_Cursor          : TCursor;
  first_image,stepnr: integer;
  init              : boolean;
begin
  if listview1.items.count<=1 then exit; {no files}
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  save_settings(user_path+'astap.cfg');{too many lost selected files . so first save settings}

//  flipvertical:=mainwindow.Flipvertical1.Checked;
//  fliphorizontal:=mainwindow.Fliphorizontal1.Checked;
  esc_pressed:=false;
  init:=false;


  repeat
    if init=false then c:= listview_find_selection(listview1) {find the row selected}
                  else c:=0;
    init:=true;
    repeat
      if ((esc_pressed=false) and (listview1.Items.item[c].checked) )  then
      begin
        listview1.Selected :=nil; {remove any selection}
        listview1.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview1.Items[c].MakeVisible(False);{scroll to selected item}

        filename2:=listview1.items[c].caption;
        mainwindow.caption:=filename2;

        Application.ProcessMessages;
        if esc_pressed then
                     break;
        {load image}
        if load_fits(filename2,true {light},true,true {reset var},img_loaded)=false then begin esc_pressed:=true; break;end;

        getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}

        plot_fits(mainwindow.image1,false {re_center});
      end;
      inc(c);
    until c>=listview1.items.count;
  until esc_pressed ;

  Screen.Cursor :=Save_Cursor;{back to normal }

end;


procedure Tstackmenu1.luminance_filter1Change(Sender: TObject);
begin
  filter_name_changed:=true;

  {remove duplication because they will be ignored later. Follow execution of stacking routine (for i:=0 to 4) so red, green, blue luminance}
  if  AnsiCompareText(green_filter1.text,red_filter1.text)=0 then green_filter1.text:='';
  if  AnsiCompareText(green_filter1.text,red_filter2.text)=0 then green_filter1.text:='';

  if  AnsiCompareText(green_filter2.text,red_filter1.text)=0 then green_filter2.text:='';
  if  AnsiCompareText(green_filter2.text,red_filter2.text)=0 then green_filter2.text:='';

  if  AnsiCompareText(blue_filter1.text,red_filter1.text)=0 then blue_filter1.text:='';
  if  AnsiCompareText(blue_filter1.text,red_filter2.text)=0 then blue_filter1.text:='';

  if  AnsiCompareText(blue_filter2.text,red_filter1.text)=0 then blue_filter2.text:='';
  if  AnsiCompareText(blue_filter2.text,red_filter2.text)=0 then blue_filter2.text:='';

  if  AnsiCompareText(blue_filter1.text,green_filter1.text)=0 then blue_filter1.text:='';
  if  AnsiCompareText(blue_filter1.text,green_filter2.text)=0 then blue_filter1.text:='';

  if  AnsiCompareText(blue_filter2.text,green_filter1.text)=0 then blue_filter2.text:='';
  if  AnsiCompareText(blue_filter2.text,green_filter2.text)=0 then blue_filter2.text:='';


  if  AnsiCompareText(luminance_filter1.text,red_filter1.text)=0 then luminance_filter1.text:='';
  if  AnsiCompareText(luminance_filter1.text,red_filter2.text)=0 then luminance_filter1.text:='';

  if  AnsiCompareText(luminance_filter2.text,red_filter1.text)=0 then luminance_filter2.text:='';
  if  AnsiCompareText(luminance_filter2.text,red_filter2.text)=0 then luminance_filter2.text:='';

  if  AnsiCompareText(luminance_filter1.text,green_filter1.text)=0 then luminance_filter1.text:='';
  if  AnsiCompareText(luminance_filter1.text,green_filter2.text)=0 then luminance_filter1.text:='';

  if  AnsiCompareText(luminance_filter2.text,green_filter1.text)=0 then luminance_filter2.text:='';
  if  AnsiCompareText(luminance_filter2.text,green_filter2.text)=0 then luminance_filter2.text:='';

  if  AnsiCompareText(luminance_filter1.text,blue_filter1.text)=0 then luminance_filter1.text:='';
  if  AnsiCompareText(luminance_filter1.text,blue_filter2.text)=0 then luminance_filter1.text:='';

  if  AnsiCompareText(luminance_filter2.text,blue_filter1.text)=0 then luminance_filter2.text:='';
  if  AnsiCompareText(luminance_filter2.text,blue_filter2.text)=0 then luminance_filter2.text:='';

end;

procedure Tstackmenu1.make_osc_color1Change(Sender: TObject);
var
  bmp : tbitmap;
begin
  bmp := TBitmap.Create;
  if make_osc_color1.checked then ImageList2.GetBitmap(12, bmp){colour stack} else ImageList2.GetBitmap(6, bmp);{gray stack}
  stackmenu1.stack_button1.glyph.assign(bmp);
  freeandnil(bmp);
end;


procedure Tstackmenu1.MenuItem14Click(Sender: TObject);
var
  index,counter: integer;
begin
  index:=0;
  counter:=listview5.Items.Count;
  while index<counter do
  begin
    if  listview5.Items[index].Selected then
    begin
      listview_add(listview5.items[index].caption);
    end;
    inc(index); {go to next file}
  end;
end;



procedure double_size(img: image_array; w,h : integer; var img2 : image_array);{double array size}
var
   fitsX,fitsY,i,x,y:integer;
begin
  setlength(img_backup,naxis3,w,h);{set length of image array}

  for fitsY:=0 to h do
    for fitsX:=0 to w do
    begin
      for i:=0 to naxis3-1 do
      begin
        x:=fitsX div 2;
        y:=fitsY div 2;
        if  ((x<=width2-1) and (y<=height2-1)) then {prevent problem if slightly different}
           img_backup[i,fitsX ,fitsY]  :=img[i,x,y];
      end;
    end;
  height2:=h;
  width2 :=w;

  img2:=img_backup;
end;


procedure load_master_dark(exposure,temperature,width1: integer); {average the darks selection}
var
  c : integer;

begin
  analyse_listview(stackmenu1.listview2,2 {analyse background, load reduced header only });{find dimensions, exposure and temperature}

  dark_count:=0;{assume none is found. Do this after analyse since it willl change dark_count}
  c:=0;
  while c<stackmenu1.listview2.items.count do
  begin
    if stackmenu1.listview2.items[c].checked=true then
      if ( (stackmenu1.classify_dark_exposure1.checked=false) or (exposure=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_exposure]))) then {exposure correct}
        if ( (stackmenu1.classify_dark_temperature1.checked=false) or (temperature=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_temperature]))) then {temperature correct}
          if  width1=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_width]) then {width correct}
          begin
            memo2_message('Loading master dark file '+stackmenu1.ListView2.items[c].caption);
            if load_fits(stackmenu1.ListView2.items[c].caption,false {light},true,false {reset var},img_dark)=false then begin memo2_message('Error'); dark_count:=0; exit; end;
            {load master in memory img_dark}
            if dark_count=0 then dark_count:=1; {is normally updated by load_fits}
            c:=9999999;{stop searching}
          end;
    inc(c);
  end;
  dark_exposure:=exposure;{remember}
  dark_temperature:=temperature;
  if c<9999999  then
  begin
    memo2_message('█ █ █ █ █ █ Warning, could not find a suitable dark for temperature "'+inttostr(temperature)+'"and exposure "'+inttostr(exposure)+'"! De-classify or add darks. █ █ █ █ █ █ ');
    dark_count:=0;{set back to zero}
  end;
end;

procedure load_master_flat(filter: string;width1 : integer);
var
  c : integer;
begin
  flat_count:=0;{assume none is found}

  analyse_listview(stackmenu1.listview3,0 {analyse minimum header only});{find dimensions, exposure and temperature}

  c:=0;
  while c<stackmenu1.listview3.items.count do
  begin
    if stackmenu1.listview3.items[c].checked=true then
      if ((stackmenu1.classify_flat_filter1.checked=false) or (AnsiCompareText(filter,stackmenu1.listview3.Items.item[c].subitems.Strings[8])=0)) then {filter correct?  ignoring case}
        if  width1=strtoint(stackmenu1.listview3.Items.item[c].subitems.Strings[3]) then {width correct}
        begin
          memo2_message('Loading master flat file '+stackmenu1.ListView3.items[c].caption);
          if load_fits(stackmenu1.ListView3.items[c].caption,false {light},true,false {reset var},img_flat)=false then begin memo2_message('Error'); flat_count:=0; exit; end;
          {load master in memory img_dark}
          if flat_count=0 then flat_count:=1; {is normally updated by load_fits}

          if pos('2x2',stackmenu1.flat_combine_method1.text)>0 then
          begin
            memo2_message('Applying 2x2 flat filter');
            x2mean(1 {nr of colors},img_flat);
          end
          else
          if pos('3x3',stackmenu1.flat_combine_method1.text)>0 then
          begin
            x3mean(1 {nr of colors},img_flat);
            memo2_message('Applying 3x3 flat filter');
          end
          else
          if pos('4x4',stackmenu1.flat_combine_method1.text)>0 then
          begin
            x4mean(1 {nr of colors},img_flat);
            memo2_message('Applying 4x4 flat filter');
          end;

          c:=9999999;{stop searching}
          flat_filter:=filter; {mark as loaded}
        end;
    inc(c);
  end;
  if c<9999999  then
  begin
     memo2_message('█ █ █ █ █ █ Warning, could not find a suitable flat for "'+filter+'"! De-classify or add correct flat. █ █ █ █ █ █ ');
     flat_count:=0;{set back to zero}
  end;

end;

procedure removechecked2(tl :tlistview);{remove lisview items checked}
var index,counter: integer;
begin
  index:=0;
  counter:=tl.Items.Count;
  while index<counter do
  begin
    if tl.Items[index].checked then
    begin
      tl.Items.Delete(Index);
      //dec(index);{next file goes down in index, compensate}
      dec(counter);{one file less}
    end
    else
    inc(index); {go to next file}
  end;
end;


procedure Tstackmenu1.replace_by_master_dark1Click(Sender: TObject); {this routine works with mono files but makes coloured files mono, so less suitable for commercial cameras producing coloured raw images}
var
   path1,filen :string;
   c,counter,i : integer;
   specified: boolean;
   exposure,temperature,width1: integer;
begin
  save_settings(user_path+'astap.cfg');
  analyse_listview(listview2,0 {analyse reduced header only});{update the tab information}

  setlength(file_list,stackmenu1.listview2.items.count);
  repeat
  file_count:=0;
  specified:=false;

  for c:=0 to stackmenu1.listview2.items.count-1 do
    if stackmenu1.listview2.items[c].checked=true then
    begin
      filen:=stackmenu1.ListView2.items[c].caption;
      if pos('master_dark',filen)=0 then {not a master file}
      begin {set specification master}
        if specified=false then
        begin
          exposure:=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_exposure]);
          temperature:=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_temperature]);
          width1:=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_width]);
          specified:=true;
        end;
        if ( (stackmenu1.classify_dark_exposure1.checked=false) or (exposure=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_exposure]))) then {exposure correct}
          if ( (stackmenu1.classify_dark_temperature1.checked=false) or (temperature=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_temperature]))) then {temperature correct}
            if  width1=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_width]) then {width correct}
             begin
               file_list[file_count]:=filen;
               inc(file_count);
             end;
      end;
    end;{checked}

  Application.ProcessMessages;
  if esc_pressed then exit;


  dark_count:=0;
  if file_count<>0 then
  begin
    memo2_message('Averaging darks.');
    average('dark',img_dark);  {the result will be mono so more suitable for raw images without bayer applied. Not so suitable for commercial camera's image and converted to coloured FITS}

    if esc_pressed then exit;

    Application.ProcessMessages;
    if esc_pressed then exit;

    if ((file_count<>1) or (dark_count=0)) then  dark_count:=file_count; {else use the info from the keyword dark_cnt of the master file}

    path1:=extractfilepath(file_list[0])+'master_dark_'+inttostr(dark_count)+'x'+inttostr(round(exposure))+'s_at_'+inttostr(set_temperature)+'C.fit';
    update_integer('DARK_CNT=',' / Number of dark image combined                  ' ,dark_count);
    { ASTAP keyword standard:}
    { interim files can contain keywords: EXPOSURE, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
    { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}


    update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,1);{for the rare case the darks are coloured. Should normally be not the case since it expects raw mono FITS files without bayer matrix applied !!}
    update_text   ('COMMENT 1','  Created by Astrometric Stacking Program. www.hnsky.org');
    naxis3:=1; {any color is made mono in the routine}

    img_loaded:=img_dark;
    img_dark:=nil;

    if save_fits(path1,-32,false) then {saved}
    begin
      listview2.Items.BeginUpdate;
      for i:=0 to  file_count do
      begin
        c:=0;
        counter:=listview2.Items.Count;
        while c<counter do
        begin
          if file_list[i]=stackmenu1.ListView2.items[c].caption then {processed}
          begin
            listview2.Items.Delete(c);
            dec(counter);{one file less}
          end
          else
          inc(c);
        end;
      end;
      listview234567_add(listview2,path1);{add master}
      listview2.Items.EndUpdate;

      analyse_listview(listview2, 0 {analyse readuced header only});{update the tab information}
    end;
  end;

  Application.ProcessMessages;
  if esc_pressed then exit;

  until file_count=0;{make more then one master}
  save_Settings(user_path+'astap.cfg');{store settings}
end;



procedure Tstackmenu1.replace_by_master_flat1Click(Sender: TObject);
var
   fitsX,fitsY    : integer;
   path1,filen,filter :string;
   c,counter,i : integer;
   specified: boolean;
   width1,flat_dark_width: integer;
   flatdark_used : boolean;
begin
  save_settings(user_path+'astap.cfg');
  analyse_listview(listview3,0 {analyse reduced header only});{update the tab information. Convert to FITS if required}


  flat_dark_width:=average_flatdarks;{average of bias frames. Convert to FITS if required}
  flatdark_count:=file_count;
  flatdark_used:=false;

  setlength(file_list,stackmenu1.listview3.items.count);
  repeat
  file_count:=0;
  specified:=false;

  i:=stackmenu1.listview3.items.count-1;
  for c:=0 to stackmenu1.listview3.items.count-1 do
    if stackmenu1.listview3.items[c].checked=true then
    begin
      filen:=stackmenu1.ListView3.items[c].caption;
      if pos('master_flat',filen)=0 then {not a master file}
      begin {set specification master}
        if specified=false then
        begin
          filter:=stackmenu1.listview3.Items.item[c].subitems.Strings[6];
          width1:=strtoint(stackmenu1.listview3.Items.item[c].subitems.Strings[3]);
          if flat_dark_width=0 then memo2_message('Warning no flat-dark/bias found!!')
          else
          if width1<>flat_dark_width then begin memo2_message('Abort, the width of the flat and flat-dark do not match!!');exit end;
          specified:=true;
        end;
        if ((stackmenu1.classify_flat_filter1.checked=false) or (filter=stackmenu1.listview3.Items.item[c].subitems.Strings[8])) then {filter correct?}
            if  width1=strtoint(stackmenu1.listview3.Items.item[c].subitems.Strings[3]) then {width correct}
             begin
               file_list[file_count]:=filen;
               inc(file_count);
             end;
      end;
    end;{checked}

  Application.ProcessMessages;
  if esc_pressed then exit;


  flat_count:=0;
  if file_count<>0 then
  begin
    memo2_message('Combining flats and flat-darks.');

    average_flats(filter,width1);{average of flat frames}
    flat_count:=file_count;

    Application.ProcessMessages;
    if esc_pressed then
    exit;

    if flat_count<>0 then
    begin
      if flatdark_count<>0 then
      begin
        flatdark_used:=true;
        for fitsY:=0 to height2-1 do
          for fitsX:=0 to width2-1 do
          begin
             img_flat[0,fitsX,fitsY]:=img_flat[0,fitsX,  fitsY  ] - img_bias[0,fitsX,  fitsY  ]; {flats and bias already many mono in procedure average}
          end;
      end;

      if pos('2x2',stackmenu1.flat_combine_method1.text)>0 then  x2mean(1 {nr of colors},img_flat)
      else
      if pos('3x3',stackmenu1.flat_combine_method1.text)>0 then
          x3mean(1 {nr of colors},img_flat)
      else
      if pos('4x4',stackmenu1.flat_combine_method1.text)>0 then
          x4mean(1 {nr of colors},img_flat);

    end;

    Application.ProcessMessages;
    if esc_pressed then exit;

    naxis3:=1; {any color is made mono in the routine}
    if file_count<>0 then
    begin
      path1:=extractfilepath(file_list[0]);
      path1:=extractfilepath(file_list[0])+'master_flat_corrected_with_flat_darks_'+filter_name+'_'+inttostr(flat_count)+'xF_'+inttostr(flatdark_count)+'xFD.fit';

      update_integer('FLAT_CNT=',' / Number of flat images combined.                ' ,flat_count);
      update_integer('BIAS_CNT=',' / Number of flat-dark or bias images combined.   ' ,flatdark_count);

      { ASTAP keyword standard:}
      { interim files can contain keywords: EXPOSURE, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
      { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

      update_text   ('COMMENT 1','  Created by Astrometric Stacking Program. www.hnsky.org');
      update_integer('NAXIS3  =',' / length of z axis (mostly colors)               ' ,1); {for the rare case the darks are coloured. Should normally be not the case since it expects raw mono FITS files without bayer matrix applied !!}
      naxis3:=1; {any color is made mono in the routine}

      img_loaded:=img_flat;
      img_flat:=nil;

      if save_fits(path1,-32,false) then {saved}
      begin
        listview3.Items.BeginUpdate; {remove the flats added to master}
        for i:=0 to  file_count do
        begin
          c:=0;
          counter:=listview3.Items.Count;
          while c<counter do
          begin
            if file_list[i]=stackmenu1.ListView3.items[c].caption then {prcessed}
            begin
              listview3.Items.Delete(c);
              dec(counter);{one file less}
            end
            else
            inc(c);
          end;
        end;
        listview234567_add(listview3,path1);{add master}
        listview3.Items.EndUpdate;
        analyse_listview(listview3,0 {analyse reduced header only});{update the tab information}
      end;
    end;
  end;

  Application.ProcessMessages;
  if esc_pressed then exit;

  until file_count=0;{make more then one master}

  if flatdark_used then listview4.Items.Clear;{remove bias if used}
  save_Settings(user_path+'astap.cfg');{store settings}
end;


function load_wcs_solution(filen: string): boolean; {plate solving, load astrometry.net solution}
var
   old_nrbits, old_naxis3,old_naxis:integer;
   filename_wcs : string;
begin
  filename_wcs:=changeFileExt(filen,'.wcs');
  if (fileexists(filename_wcs)=false) then
  result:=false
  else
  begin
    old_nrbits:=nrbits;
    old_naxis3:=naxis3;
    old_naxis:=naxis;{for old astrometry.net}
    result:=load_fits(filename_wcs,true {light},false,true {reset var},img_loaded); {load astrometry.net solution}
    nrbits:=old_nrbits;
    naxis3:=old_naxis3;
    naxis:=old_naxis;

  end;
end;

function create_wcs_solution(filen: string): boolean; {plate solving,  check for WCS file solution and if not available create astrometry.net WCS file solution}
begin
  if (fileexists(changeFileExt(filen,'.wcs'))=false) then
  begin
    result:=astrometry_net(filen,false {no .new file},false{no update header} ,true {remove_tmp},stackmenu1.show_console1.checked,stackmenu1.keep_console_open1.checked);
  end
  else
  result:=true;{existing solution, no action required}
end;

function create_internal_solution : boolean; {plate solving, image should be already loaded create internal solution using the internal solver}
begin
  if solve_image(img_loaded,true) then {match between loaded image and star database}
  begin
    mainwindow.SaveFITSwithupdatedheader1Click(nil);
    result:=true;{new solution}
  end
  else result:=false;
end;

procedure apply_dark_flat(filter1:string; exposure1,stemperature1,width1:integer; var dcount,fcount,fdcount: integer; var flat_factor: double) ; {inline;} {apply dark, flat if required, renew if different exposure or ccd temp}
var  {variables in the procedure are created to protect global variables as filter_name against overwriting by loading other fits files}
  fitsX,fitsY,k : integer;
  calstat_local : string;
  datamax_light : double;
begin
  calstat_local:=calstat;{Note load darks or flats will overwrite calstat}
  datamax_light:=datamax_org;

  if pos('D',calstat_local)<>0 then
             memo2_message('Skipping dark calibration, already applied. See header keyword CALSTAT')
  else
  begin
    if ((dark_exposure=987654321) {first dark required, any dark will do} or  (stackmenu1.classify_dark_exposure1.checked){suitable dark reguired}) then
    if  ((exposure1=dark_exposure) and (stemperature1=dark_temperature) )=false then {new dark required}
    begin
      load_master_dark(exposure1,stemperature1 {set_temperature},width1); {will only be renewed if different exposure or set_temperature. Note load will overwrite calstat}
      dcount:=dark_count;{protect this global dark_count in dcount for next load_master_flat}
    end;

    if dark_count>0 then
    begin
      for fitsY:=1 to height2 do  {apply the dark}
        for fitsX:=1 to width2 do
          for k:=0 to naxis3-1 do {do all colors}
             img_loaded[k,fitsX-1,fitsY-1]:=img_loaded[k,fitsX-1,fitsY-1] - img_dark[k,fitsX-1,fitsY-1];
      calstat_local:=calstat_local+'D'; {dark applied}
      datamax_light:=datamax_light - round((  img_dark[0,(width2 div 2)  ,(height2 div 2)  ]+   {correct datamax with average dark value subtracted}
                                          img_dark[0,(width2 div 2)+1,(height2 div 2)  ]+
                                          img_dark[0,(width2 div 2)  ,(height2 div 2)+1]+
                                          img_dark[0,(width2 div 2)-1,(height2 div 2)  ]+
                                          img_dark[0,(width2 div 2)  ,(height2 div 2)-1]+
                                          img_dark[0,(width2 div 2)+1,(height2 div 2)+1]+
                                          img_dark[0,(width2 div 2)-1,(height2 div 2)+1]+
                                          img_dark[0,(width2 div 2)+1 ,(height2 div 2)-1]+
                                          img_dark[0,(width2 div 2)-1 ,(height2 div 2)-1]))/9;

    end;
  end;{apply dark}

  if pos('F',calstat_local)<>0 then
           memo2_message('Skipping flat calibration, already applied. See header keyword CALSTAT')
  else
  begin
    if ((flat_filter='987654321') {first flat required, any flat will do} or  (stackmenu1.classify_flat_filter1.checked){suitable flat reguired}) then
    if AnsiCompareText(filter1,flat_filter)<>0 then {new flat required}
    begin
      load_master_flat(filter1,width2);{will only be renewed if different filter name.  Note load will overwrite calstat}
      fcount:=flat_count;{from master flat loaded}
      fdcount:=flatdark_count;
    end;

    if flat_count<>0 then
    begin
      flat_norm_value:=0;
      for fitsY:=-2 to 3 do {do even times, 6x6}
         for fitsX:=-2 to 3 do
           flat_norm_value:=flat_norm_value+img_flat[0,fitsX+(width2 div 2),fitsY +(height2 div 2)];
      flat_norm_value:=round(flat_norm_value/36);

      for fitsY:=1 to height2 do  {apply the flat}
        for fitsX:=1 to width2 do
        begin
          flat_factor:=flat_norm_value/(img_flat[0,fitsX-1,fitsY-1]+0.001); {bias is already combined in flat in combine_flat}
          for k:=0 to naxis3-1 do {do all colors}
            img_loaded[k,fitsX-1,fitsY-1]:=img_loaded[k,fitsX-1,fitsY-1]*flat_factor;
        end;
      calstat_local:=calstat_local+'FB';{mark that flat and bias have been applied}
    end;{flat correction}
  end;{do flat & flat dark}
  calstat:=calstat_local;{report calibration}
  datamax_org:=datamax_light;{restore. will be overwitten by previouse reads}
end;



procedure calibration_only; {calibrate images only}
var
  Save_Cursor:TCursor;
   c  : integer;
   flat_factor: double;
   object_to_process, stack_info : string;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  with stackmenu1 do
  begin
    memo2_message('Calibrating individual files only.');
    for c:=0 to ListView1.items.count-1 do {first get solution ignoring the header}
    if ListView1.items[c].Checked=true then
    begin
      try { Do some lengthy operation }
        ListView1.Selected :=nil; {remove any selection}
        ListView1.ItemIndex := c;{show wich file is processed}
        Listview1.Items[c].MakeVisible(False);{scroll to selected item}

        progress_indicator(100*c/ListView1.items.count-1,'');{indicate 0 to 100% for calibration}

        filename2:=ListView1.items[c].caption;

        {load image}
        Application.ProcessMessages;
        if ((esc_pressed) or (load_fits(filename2,true {light},true,true {reset var},img_loaded)=false)) then begin memo2_message('Error');{can't load} Screen.Cursor := Save_Cursor; exit;end;

        memo1_text:=mainwindow.Memo1.Text;{save fits header FITS file}
        apply_dark_flat(filter_name,round(exposure),set_temperature,width2,{var} dark_count,flat_count,flatdark_count,flat_factor);{apply dark, flat if required, renew if different exposure or ccd temp}
        {these global variables are passed-on in procedure to protect against overwriting}
        memo2_message('Calibrating file: '+inttostr(c+1)+'-'+inttostr( ListView1.items.count-1)+' "'+filename2+'"  to average. Using '+inttostr(dark_count)+' darks, '+inttostr(flat_count)+' flats, '+inttostr(flatdark_count)+' flat-darks') ;
        Application.ProcessMessages;
        if esc_pressed then exit;

        if make_osc_color1.checked then {do demosaic bayer}
            demosaic_bayer; {convert OSC image to colour}
         {naxis3 is now 3}

        mainwindow.Memo1.Text:=memo1_text;{use saved fits header}
        update_text   ('COMMENT 1','  Calibrated by Astrometric Stacking Program. www.hnsky.org');
        update_text   ('CALSTAT =',#39+calstat+#39); {calibration status}

        filename2:=StringReplace(ChangeFileExt(filename2,'.fit'),'.fit','_cal.fit',[]);{give new file name }
        memo2_message('█ █ █  Saving calibrated file as '+filename2);
        save_fits(filename2,-32, true);

        object_to_process:=uppercase(ListView1.Items.item[c].subitems.Strings[I_object]); {get a object name}
        stack_info:=' '+inttostr(flatdark_count)+'x'+'FD  '+
                        inttostr(flat_count)+'x'+'F  '+
                        inttostr(dark_count)+'x'+'D  '+
                        '1x'+filter_name;


        report_results(object_to_process,stack_info,0,-1{no icon});{report result in tab results}


      finally
      end;
    end;
  end;{with stackmenu1 do}
  Screen.Cursor:=Save_Cursor;
  memo2_message('Calibration of the individual files is complete. New files are posted in the results tab');
end;

procedure put_lowest_hfd_on_top(var files_to_process : array of TfileToDo);{find the files with the lowest hfd unless an image is larger}
var
   lowest, x  : double;
   first, best,i, width1, largest_width  : integer;
   dummy: string;
   file_to_do : Tfiletodo;
begin
  first:=-1;
  largest_width:=-1;
  best:=999999;
  lowest:=999999;
  for i:=0 to length(files_to_process)-1 do
  begin
    if length(files_to_process[i].name)>1 then {has a filename}
    begin
      width1:=strtoint(stackmenu1.ListView1.Items.item[i].subitems.Strings[I_width]);
      if first=-1 then begin first:=i; largest_width:=width1  end;

      dummy:=stackmenu1.ListView1.Items.item[i].subitems.Strings[I_hfd];{hfd}
      if length(dummy)>1 then x:=strtofloat2(dummy);{hfd available}

      if width1>largest_width then {larger image found, give this one preference}
      begin
        width1:=largest_width;
        lowest:=x;
        best:=i;
      end
      else
      if width1=largest_width then {equal size}
      begin {equal size}
        if x<lowest then
        begin
           lowest:=x;
           best:=i;
        end;
      end;
    end; {has a file name}
  end;{for loop}

  if ((best<999999) and (best<>first)) then {swap records, put lowest HFD first}
  begin
    file_to_do:=files_to_process[first];
    files_to_process[first]:=files_to_process[best];
    files_to_process[best]:=file_to_do;
  end;
end;

procedure Tstackmenu1.stack_button1Click(Sender: TObject);
var
   Save_Cursor:TCursor;
   i,c,over_size,{ counterX,}nrfiles, image_counter,object_counter, first_file,position, total_counter{,his_done }: integer;
   filter_name1, filter_name2, filename3, extra1,extra2,object_to_process,stack_info{,ff}: string;
   lrgb,solution  : boolean;
   startTick      : qword;{for timing/speed purposes}
begin
  save_settings(user_path+'astap.cfg');{too many lost selected files . so first save settings}
  esc_pressed:=false;

  memo2_message('Stack method '+stack_method1.text);
  memo2_message('Oversize '+oversize1.text);
  if make_osc_color1.checked then
              memo2_message('OSC, demosaic method '+demosaic_method1.text);
  if drizzle1.checked then memo2_message('Drizzle option selected with drop size '+drop_size1.text);

  startTick := gettickcount64;
  if ListView1.items.count<>0 then
  begin
    memo2_message('Analysing images.');
    stackmenu1.Analyse1Click(nil);{analyse any image not done yet}
    if esc_pressed then exit;
    memo2_message('Stacking ('+stack_method1.text+'), HOLD ESC key to abort.');
  end
  else
  begin
    memo2_message('Abort, no images to stack! Browse for images, darks and flats. They will be sorted automatically.');
    exit;
  end;

  if ListView2.items.count<>0 then
  begin
    memo2_message('Analysing darks.');
    stackmenu1.replace_by_master_dark1Click(nil);
    if esc_pressed then exit;
  end;
  if ListView3.items.count<>0 then
  begin
    memo2_message('Analysing flats.');
    stackmenu1.replace_by_master_flat1Click(nil);
    if esc_pressed then exit;
  end;

  dark_exposure:=987654321;{not done indication}
  dark_temperature:=987654321;
  flat_filter:='987654321';{not done indication}


  if pos('Calibration',stackmenu1.stack_method1.text)>0=true then {calibrate images only}
  begin
     calibration_only;
     exit;
  end;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  progress_indicator(0,'');

  if use_manual_alignment1.checked then {check is reference objects are marked}
  begin
    for c:=0 to ListView1.items.count-1 do
    if ListView1.items[c].Checked=true then
    begin
      try { Do some lengthy operation }
        ListView1.Selected :=nil; {remove any selection}
        ListView1.ItemIndex := c;{show wich file is processed}
        Listview1.Items[c].MakeVisible(False);{scroll to selected item}
        if length(ListView1.Items.item[c].subitems.Strings[11+5])<=1 then {no manual position added}
        begin
          memo2_message('█ █ █  Abort! █ █ █  Reference object missing for one file. Double click on all file names and mark with the mouse the reference object. The file name will then turn green.');
          Screen.Cursor := Save_Cursor;
          exit;
        end;
        Application.ProcessMessages;
      finally
      end;
    end;
  end;{check for manual stacking}


  {activate scrolling memo2}
  stackmenu1.memo2.SelStart:=Length(stackmenu1.memo2.Lines.Text);
  stackmenu1.memo2.SelLength:=0;

  dropsize:=strtofloat2(stackmenu1.drop_size1.text);

  if ((use_astrometry_internal1.checked) or (use_astrometry_net1.checked)) then {astrometric alignment}
  begin
    memo2_message('Preparing astrometric solutions');
    for c:=0 to ListView1.items.count-1 do
    if ( (ListView1.items[c].Checked=true) and ((ignore_header_solution1.Checked) or (ListView1.Items.item[c].subitems.Strings[I_solution]<>'✓')){no internal solution }  ) then
    begin
      try { Do some lengthy operation }
        ListView1.Selected :=nil; {remove any selection}
        ListView1.ItemIndex := c;{show wich file is processed}
        Listview1.Items[c].MakeVisible(False);{scroll to selected item}

        progress_indicator(10*c/ListView1.items.count-1,' solving');{indicate 0 to 10% for plate solving}

        filename2:=ListView1.items[c].caption;
        Application.ProcessMessages;
        if esc_pressed then begin Screen.Cursor := Save_Cursor; exit;end;

        if stackmenu1.use_astrometry_internal1.checked then {internal solver}
        begin
          {load file}
          if load_fits(filename2,true {light},true,true {reset var},img_loaded){important required to check CD1_1}=false then begin memo2_message('Error');{failed to load} Screen.Cursor := Save_Cursor; exit;end;
          if ((cd1_1=0) or (stackmenu1.ignore_header_solution1.checked)) then solution:= create_internal_solution else solution:=true;
        end
        else
        if stackmenu1.use_astrometry_net1.checked=true then
        begin
            solution:=create_wcs_solution(filename2);  {check for WCS file solution and if not available create astrometry.net WCS file solution}
        end;

        if solution=false then
        begin {no solution found}
          ListView1.items[c].Checked:=false;
          memo2_message('No solution for: "'+filename2+'" un-checked this file.');
        end {no solution found}
        else
        memo2_message('Astrometric solution for: "'+filename2+'"');
        if stackmenu1.use_astrometry_net1.checked=true then begin if solution then stackmenu1.ListView1.Items.item[c].subitems.Strings[I_esolution]:='✓' else stackmenu1.ListView1.Items.item[c].subitems.Strings[I_esolution]:=''; end {report external plate solve result}
                                                       else begin if solution then stackmenu1.ListView1.Items.item[c].subitems.Strings[I_solution]:='✓' else stackmenu1.ListView1.Items.item[c].subitems.Strings[I_solution]:=''; end;{report internal plate solve result}
      finally
      end;
    end;
    memo2_message('Adding astrometric solutions complete.');
  end;

  Application.ProcessMessages;
  if esc_pressed then begin Screen.Cursor := Save_Cursor;  exit;end;

  progress_indicator(10,'');

  Application.ProcessMessages;

  if esc_pressed then begin Screen.Cursor := Save_Cursor;  exit;end;

  object_counter:=0;
  total_counter:=0;

  dark_count:=0;{reset only once, but keep if dark is loaded}
  flat_count:=0;{reset only once, but keep if flat is loaded}
  flatdark_count:=0;{reset only once}

  for c:=0 to ListView1.items.count-1 do
  begin
    ListView1.Items.item[c].SubitemImages[2]:=-1;{remove any icons. Mark third columns as not done using the image index of first column}
    ListView1.Items.item[c].subitems.Strings[I_result]:='';{no stack result}
  end;

  repeat {do all objects}
    image_counter:=0;
    object_to_process:=''; {blank do this object}
    extra1:=''; {reset always for object loop}
    extra2:=''; {reset always for object loop}
    counterR:=0;
    counterG:=0;
    counterB:=0;
    counterRGB:=0;
    counterL:=0;
    light_count:=0;

    counterRdark:=0;
    counterGdark:=0;
    counterBdark:=0;
    counterRGBdark:=0;
    counterLdark:=0;

    counterRflat:=0;
    counterGflat:=0;
    counterBflat:=0;
    counterRGBflat:=0;
    counterLflat:=0;

    counterRbias:=0;
    counterGbias:=0;
    counterBbias:=0;
    counterRGBbias:=0;
    counterLbias:=0;

    exposureR:=0;
    exposureG:=0;
    exposureB:=0;
    exposureRGB:=0;
    exposureL:=0;
//    counterX:=0; {reset always for object loop}
    inc(object_counter);

//    hist_info:= TStringList.Create;

    lrgb:=classify_filter1.checked;

    if lrgb=false then
    begin
      SetLength(files_to_process, ListView1.items.count);{set array length to listview}
      nrfiles:=0;
      over_size:=round(strtofloat2(stackmenu1.oversize1.Text));{accept also commas but round later}

      for c:=0 to ListView1.items.count-1 do
      begin
        files_to_process[c].name:='';{mark empthy}
        files_to_process[c].listviewindex:=c;{use same index as listview1 except when later put lowest HFD first}
        if ((ListView1.items[c].Checked=true) and (ListView1.Items.item[c].SubitemImages[2]<0)) then {not done yet}
        begin
          //ff:=uppercase(ListView1.Items.item[c].subitems.Strings[I_object]);

          if object_to_process='' then object_to_process:=uppercase(ListView1.Items.item[c].subitems.Strings[I_object]); {get a object name to stack}
          if ( (classify_object1.checked=false) or  (pos('stich',stackmenu1.stack_method1.text)>0=true){ignore object name in mosaic} or
               ((object_to_process<>'') and (object_to_process=uppercase(ListView1.Items.item[c].subitems.Strings[I_object]))) ) then {correct object?}
          begin {correct object}
            files_to_process[c].name:=ListView1.items[c].caption;
            inc(image_counter);{one image more}
            ListView1.Items.item[c].SubitemImages[2]:=5;{mark 3th columns as done using a stacked icon}
            ListView1.Items.item[c].subitems.Strings[I_result]:=inttostr(object_counter)+'  ';{show image result number}
            inc(nrfiles);
          end;
        end;
      end;
      if nrfiles>1 then {need at least two files to sort}
      begin
        put_lowest_hfd_on_top(files_to_process);

        if pos('Sigma',stackmenu1.stack_method1.text)>0=true then
             begin
               if length(files_to_process)<=5 then memo2_message('█ █ █ █ █ █ Method Sigma Clip does not work well for a few images. Try method average. █ █ █ █ █ █ ');
               stack_sigmaclip(over_size,{var}files_to_process,counterL) {sigma clip combining}
             end
        else
        if pos('stich',stackmenu1.stack_method1.text)>0=true then stack_mosaic(over_size,{var}files_to_process,counterL) {mosaic combining}
                                                              else
                                                                stack_average(over_size,{var}files_to_process,counterL);{average}

        if counterL>0 then exposureL:=round(sum_exp/counterL); {average exposure}

        if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
      end
      else counterL:=0; {number of files processed}

    end
    else
    begin {lrgb images, classify on filter is true}
      SetLength(files_to_process_LRGB,6);{will contain [reference,r,g,b,colour,l]}
      SetLength(files_to_process, ListView1.items.count);{set array length to listview}

      for i:=0 to 4 do
      begin
        case i  of 0: begin filter_name1:=(red_filter1.text);filter_name2:=(red_filter2.text);end;
                   1: begin filter_name1:=(green_filter1.text);filter_name2:=(green_filter2.text);end;
                   2: begin filter_name1:=(blue_filter1.text);filter_name2:=(blue_filter2.text);end;
                   3: begin filter_name1:='colour';filter_name2:='Colour';end;
                 else begin filter_name1:=(luminance_filter1.text);filter_name2:=(luminance_filter2.text);end;
        end;{case}
        nrfiles:=0;

        for c:=0 to ListView1.items.count-1 do
        begin
          files_to_process[c].name:='';{mark as empthy}
          files_to_process[c].listviewindex:=c;{use same index as listview except when later put lowest HFD first}
          if ((ListView1.items[c].Checked=true) and (ListView1.Items.item[c].SubitemImages[2]<0){not yet done} and
              (length(ListView1.Items.item[c].subitems.Strings[I_filter])>0)  {skip any file without a filter name}
              ) then
          begin  {not done yet}
            if object_to_process='' then object_to_process:=uppercase(ListView1.Items.item[c].subitems.Strings[I_object]); {get a next object name to stack}

            if ((classify_object1.checked=false) or  (pos('stich',stackmenu1.stack_method1.text)>0=true) {ignore object name in mosaic} or
                ((object_to_process<>'') and (object_to_process=uppercase(ListView1.Items.item[c].subitems.Strings[I_object]))) ) {correct object?}
            then
            begin {correct object}
              if ( (AnsiCompareText(filter_name1,ListView1.Items.item[c].subitems.Strings[I_filter])=0) or (AnsiCompareText(filter_name2,ListView1.Items.item[c].subitems.Strings[I_filter])=0) ) then
              begin {correct filter}
                files_to_process[c].name:=ListView1.items[c].caption;
                inc(image_counter);{one image more}
                ListView1.Items.item[c].SubitemImages[2]:=5;{mark 3th columns as done using a stacked icon}
                ListView1.Items.item[c].subitems.Strings[I_result]:=inttostr(object_counter)+'  ';{show image result number}
                inc(nrfiles);
                first_file:=c; {remember first found for case it is the only file}
                exposure:= strtofloat2(ListView1.Items.item[c].subitems.Strings[I_exposure]);{remember exposure time in case only one file, so no stack so unknown}
              end;
            end;
          end;
        end;
        if nrfiles>0 then
        begin
          if nrfiles>1 then {more then one file}
          begin
            put_lowest_hfd_on_top(files_to_process);
            over_size:=round(strtofloat2(stackmenu1.oversize1.Text));{do oversize in 'A', 'S', 'M' routine, set repeatilly}
            if pos('Sigma',stackmenu1.stack_method1.text)>0=true then stack_sigmaclip(over_size,{var}files_to_process, counterL) {sigma clip combining}
            else
            if pos('stich',stackmenu1.stack_method1.text)>0=true then stack_mosaic(over_size,{var}files_to_process,counterL) {mosaic combining}
                                                                  else stack_average(over_size,{var}files_to_process,counterL);{average}
            over_size:=0; {do oversize only once. Not again in 'L' mode !!}
            if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;

            {kill any old plate solution since it is most likely invalid due to oversize or less accurate}
            remove_key('CD1_1   ');
            remove_key('CD1_2   ');
            remove_key('CD2_1   ');
            remove_key('CD2_2   ');
            remove_key('CROTA2  ');
            remove_key('CDELT1  ');
            remove_key('PLTSOLVD');

            update_text('COMMENT 1','  Created by Astrometric Stacking Program. www.hnsky.org');
            update_text('CALSTAT =',#39+calstat+#39);

            if pos('D',calstat)>0 then
            begin
              update_integer('DATAMAX =',' / Maximum data value                             ',round(datamax_org)); {datamax is updated in stacking process. Use the last one}
              update_integer('DATAMIN =',' / Minimum data value                             ',round(pedestal));
            end;


            if pos('Sigma',stackmenu1.stack_method1.text)>0=true then
              update_text   ('HISTORY 1','  Stacking method SIGMA CLIP AVERAGE')
              else
              update_text   ('HISTORY 1','  Stacking method AVERAGE');

            update_text   ('HISTORY 2','  Active filter: '+filter_name);{show which filter was used to combine}
            {orginal exposure is still maintained  }
            update_integer('LIGH_CNT=',' / Light frames combined.                  ' ,counterL); {for interim lum,red,blue...files.}
            update_integer('DARK_CNT=',' / Darks used for luminance.               ' ,dark_count);{for interim lum,red,blue...files. Compatible with master darks}
            update_integer('FLAT_CNT=',' / Flats used for luminance.               ' ,flat_count);{for interim lum,red,blue...files. Compatible with master flats}
            update_integer('BIAS_CNT=',' / Flat-darks used for luminance.          ' ,flatdark_count);{for interim lum,red,blue...files. Compatible with master flats}
            { ASTAP keyword standard:}
            { interim files can contain keywords: EXPOSURE, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
            { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

            if stackmenu1.use_manual_alignment1.checked then
            begin
              update_float('REF_X   =',' / Reference position for manual stacking. ' ,                      referenceX);{will be used later for alignment in mode 'L'}
              update_float('REF_Y   =',' / Referebce position for manual stacking. ' ,referenceY);
            end;

            stack_info:=' '+inttostr(flatdark_count)+'x'+'FD  '+
                            inttostr(flat_count)+'x'+'F  '+
                            inttostr(dark_count)+'x'+'D  '+
                            inttostr(counterL)+'x'+filter_name;

            filename3:=filename2;
            filename2:=StringReplace(ChangeFileExt(filename2,'.fit'),'.fit','@ '+stack_info+'_stacked.fit',[]);{give new file name for any extension, FIT, FTS, fits}
            memo2_message('█ █ █ Saving as '+filename2);
            save_fits(filename2,-32,true {override});
            files_to_process_LRGB[i+1].name:=filename2;{should contain [nil,r,g,b,l]}
            stack_info:='Interim result '+filter_name+' x '+inttostr(counterL);
            report_results(object_to_process,stack_info,object_counter,i {color icon});{report result in tab result using modified filename2}
            filename2:=filename3;{restore last filename}
          end{nrfiles>1}
          else
          begin
            files_to_process_LRGB[i+1]:=files_to_process[first_file]; {one file, no need to stack}
            over_size:=round(strtofloat2(stackmenu1.oversize1.Text));{do oversize in 'L'  routine}
            counterL:=1;
          end;

          case i  of 0: begin extra2:=extra2+'R'; end;
                     1: begin extra2:=extra2+'G';end;
                     2: begin extra2:=extra2+'B'; end;
                     3: begin extra2:=extra2+'-'; end;
                   else begin extra2:=extra2+'L'; end;
          end;{case}

          extra1:=extra1+filter_name;

        end
        else
        begin
          files_to_process_LRGB[i+1].name:='';
        end;
      end;{for loop for 4 RGBL}
      if length(extra2)>=2 then {at least two colors required}
      begin
        files_to_process_LRGB[0]:=files_to_process_LRGB[5];{use luminance as reference for alignment}  {contains, REFERENCE, R,G,B,RGB,L}
        if files_to_process_LRGB[0].name='' then  files_to_process_LRGB[0]:=files_to_process_LRGB[1]; {use red channel as reference is no luminance is available}
        if files_to_process_LRGB[0].name='' then  files_to_process_LRGB[0]:=files_to_process_LRGB[2]; {use green channel as reference is no luminance is available}


        stack_LRGB(over_size {zero if already stacked from several files},files_to_process_LRGB, counterL); {LRGB method, files_to_process_LRGB should contain [REFERENCE, R,G,B,RGB,L]}
        if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
      end
      else
      if length(extra2)=1 then
      begin
         memo2.lines.add('Error! One color only. For LRGB stacking a minimum of two colors is required. Removed the check mark classify on "image filter" or add images made with a different color filter.');
         lrgb:=false;{prevent runtime errors with naxis3=3}
      end;
      counterL:=0;{prevent a second save in next part for final file unless length(extra2)>=2}
    end;

    Screen.Cursor := Save_Cursor;  { Always restore to normal }
    if esc_pressed then begin exit;end;
    fits_file:=true;

    if ((counterL<>0){none lrgb loop} or (length(extra2)>=2){lrgb loop}) then
    begin
      if ((stackmenu1.make_osc_color1.checked) and (stackmenu1.osc_colour_smooth1.checked)) then
      begin
        memo2_message('Adjusting colour levels and applying colour-smoothing filter on stacked colour image. See pixel math tab for more manual options.');
        stackmenu1.auto_background_level1Click(nil);
        apply_factors;{histogram is after this action invalid}
        stackmenu1.reset_factors1Click(nil);{reset factors to default}
        getfits_histogram(0);{get histogram R,G,B YES, plot histogram YES, set min & max YES}
        smart_colour_smooth(img_loaded,10,false {get  hist});{histogram doesn't needs an update}
      end
      else
        getfits_histogram(0);{get histogram R,G,B YES, plot histogram YES, set min & max YES}

      CD1_1:=0;{kill any existing north arrow during plotting. Most likely wrong after stacking}
      plot_fits(mainwindow.image1,true);{plot real}
      mainwindow.Memo1.Text:=memo1_text;{use saved fits header first FITS file}

      {kill any old plate solution since it is most likely invalid due to oversize or less accurate}
      remove_key('CD1_1   ');
      remove_key('CD1_2   ');
      remove_key('CD2_1   ');
      remove_key('CD2_2   ');
      remove_key('CROTA1  ');
      remove_key('CROTA2  ');
      remove_key('CDELT1  ');
      remove_key('CDELT2  ');
      remove_key('PLTSOLVD');
      remove_key('DATE    ');{no purpose anymore for the orginal date written}
      remove_key('EXPTIME'); {remove, will be added later in the header}
      remove_key('EXPOSURE');{remove, will be replaced by LUM_EXP, RED_EXP.....}
      remove_key('CCD-TEMP');{remove, will be replaced by LUM_EXP, RED_EXP.....}
      remove_key('SET-TEMP');{remove, will be replaced by LUM_EXP, RED_EXP.....}
      remove_key('EXPOSURE');{remove, will be replaced by LUM_EXP, RED_EXP.....}
      remove_key('LIGH_CNT');{remove, will be replaced by LUM_CNT, RED_CNT.....}
      remove_key('DARK_CNT');{remove, will be replaced by LUM_DARK, RED_DARK.....}
      remove_key('FLAT_CNT');{remove, will be replaced by LUM_FLAT, RED_FLAT.....}
      remove_key('BIAS_CNT');{remove, will be replaced by LUM_BIAS, RED_BIAS.....}

      { ASTAP keyword standard:}
      { interim files can contain keywords: EXPTIME, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
      { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

      update_text   ('COMMENT 1','  Created by Astrometric Stacking Program. www.hnsky.org');
      calstat:=calstat+'S'; {status stacked}
      update_text ('CALSTAT =',#39+calstat+#39); {calibration status}
      update_text ('DATE-OBS=',#39+JdToDate(jd_start)+#39);{give start point exposures}
      if ((naxis3=1) and (counterL>0)) then {works only for mono}
      begin
        update_float('JD-AVG  =',' / Julian Day of the observation mid-point.       ', jd_sum/counterL);{give midpoint of exposures}
        update_text ('DATE-AVG=',#39+JdToDate(jd_sum/counterL)+#39);{give midpoint of exposures}
      end;

      if pos('Sigma',stackmenu1.stack_method1.text)>0=true then
        update_text   ('HISTORY 1','  Stacking method SIGMA CLIP MEAN') else
           update_text   ('HISTORY 1','  Stacking method AVERAGE');{overwrite also any existing header info}

      if naxis3>1 then
      begin
        if make_osc_color1.checked then update_text     ('HISTORY 2','  Converted to colour. Method '+ stackmenu1.demosaic_method1.text+ 'interpolation.')
        else
        if make_osc_color1.checked then update_text     ('HISTORY 2','  Combined to colour image.');
      end
      else
         update_text   ('HISTORY 2','  Processed as gray scale images.');



      if lrgb=false then {monochrome}
      begin
        update_integer('EXPTIME =',' / Total luminance exposure time in seconds.      ' ,round(sum_exp));
        update_integer('LUM_EXP =',' / Average luminance exposure time.               ' ,exposureL);
        update_integer('LUM_CNT =',' / Luminance images combined.                     ' ,counterL);
        update_integer('LUM_DARK=',' / Darks used for luminance.                      ' ,dark_count);
        update_integer('LUM_FLAT=',' / Flats used for luminance.                      ' ,flat_count);
        update_integer('LUM_BIAS=',' / Flat-darks used for luminance.                 ' ,flatdark_count);
        update_integer('LUM_TEMP=',' / Set temperature used for luminance.            ' ,set_temperature);
      end
      else {made LRGB color}
      begin
        naxis:=3;{will be written in save routine}
        naxis3:=3;{will be written in save routine, {naxis3 is update in  save_fits}
        if length(extra2)>1 then update_text('FILTER  =',#39+'        '+#39);{wipe filter info}
        update_integer('EXPTIME =',' / Total luminance exposure time in seconds.      ' ,round(exposureL*counterL)); {could be used by astroimageJ for midpoint. Download time are not included, so it is not perfect}
        update_integer('LUM_EXP =',' / Luminance exposure time.                       ' ,exposureL);
        update_integer('LUM_CNT =',' / Luminance images combined.                     ' ,counterL);
        update_integer('LUM_DARK=',' / Darks used for luminance.                      ' ,counterLdark);
        update_integer('LUM_FLAT=',' / Flats used for luminance.                      ' ,counterLflat);
        update_integer('LUM_BIAS=',' / Flat-darks used for luminance.                 ' ,counterLbias);
        update_integer('LUM_TEMP=',' / Set temperature used for luminance.            ' ,temperatureL);


        update_integer('RED_EXP =',' / Red exposure time.                             ' ,exposureR);
        update_integer('RED_CNT =',' / Red filter images combined.                    ' ,counterR);
        update_integer('RED_DARK=',' / Darks used for red.                            ' ,counterRdark);
        update_integer('RED_FLAT=',' / Flats used for red.                            ' ,counterRflat);
        update_integer('RED_BIAS=',' / Flat-darks used for red.                       ' ,counterRbias);
        update_integer('RED_TEMP=',' / Set temperature used for red.                  ' ,temperatureR);

        update_integer('GRN_EXP =',' / Green exposure time.                           ' ,exposureG);
        update_integer('GRN_CNT =',' / Green filter images combined.                  ' ,counterG);
        update_integer('GRN_DARK=',' / Darks used for green.                          ' ,counterGdark);
        update_integer('GRN_FLAT=',' / Flats used for green.                          ' ,counterGflat);
        update_integer('GRN_BIAS=',' / Flat-darks used for green.                     ' ,counterGbias);
        update_integer('GRN_TEMP=',' / Set temperature used for green.                ' ,temperatureG);

        update_integer('BLU_EXP =',' / Blue exposure time.                            ' ,exposureB);
        update_integer('BLU_CNT =',' / Blue filter images combined.                   ' ,counterB);
        update_integer('BLU_DARK=',' / Darks used for blue.                           ' ,counterBdark);
        update_integer('BLU_FLAT=',' / Flats used for blue.                           ' ,counterBflat);
        update_integer('BLU_BIAS=',' / Flat-darks used for blue.                      ' ,counterBbias);
        update_integer('BLU_TEMP=',' / Set temperature used for blue.                 ' ,temperatureB);

        update_integer('RGB_EXP =',' / OSC exposure time.                             ' ,exposureRGB);
        update_integer('RGB_CNT =',' / OSC images combined.                           ' ,counterRGB);
        update_integer('RGB_DARK=',' / Darks used for OSC.                            ' ,counterRGBdark);
        update_integer('RGB_FLAT=',' / Flats used for OSC.                            ' ,counterRGBflat);
        update_integer('RGB_BIAS=',' / Flat-darks used for OSC.                       ' ,counterRGBbias);
        update_integer('RGB_TEMP=',' / Set temperature used for OSC.                  ' ,temperatureRGB);

        update_text   ('COMMENT 2','  Total luminance exposure '+inttostr(round(counterL*exposureL)) );
        update_text   ('COMMENT 3','  Total red exposure       '+inttostr(round(counterR*exposureR)) );
        update_text   ('COMMENT 4','  Total green exposure     '+inttostr(round(counterG*exposureG)) );
        update_text   ('COMMENT 5','  Total blue exposure      '+inttostr(round(counterB*exposureB)) );


        { ASTAP keyword standard:}
        { interim files can contain keywords: EXPTIME, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
        { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}
      end;

      stack_info:=' '+inttostr(flatdark_count)+'x'+'FD  '+
                      inttostr(flat_count)+'x'+'F  '+
                      inttostr(dark_count)+'x'+'D  '+
                      inttostr(counterR)+'x'+inttostr(exposureR)+'R  '+
                      inttostr(counterG)+'x'+inttostr(exposureG)+'G  '+
                      inttostr(counterB)+'x'+inttostr(exposureB)+'B  '+
                      inttostr(counterRGB)+'x'+inttostr(exposureRGB)+'RGB  '+
                      inttostr(counterL)+'x'+inttostr(exposureL)+'L  '; {exposure}

      position:=pos('@',filename2); if position<>0 then filename2:=copy(filename2,1,position);{remove old info from the file name}
      filename2:=StringReplace(ChangeFileExt(filename2,'.fit'),'.fit',' '+stack_info+'_stacked.fit',[]);{give new file name }
      memo2_message('█ █ █  Saving result '+inttostr(image_counter)+' as '+filename2);
      save_fits(filename2,-32, true);


      if naxis3>1 then report_results(object_to_process,stack_info,object_counter,3 {color icon}) {report result in tab results}
                  else report_results(object_to_process,stack_info,object_counter,4 {gray icon}); {report result in tab results}

      DeleteFiles(image_path,'*.astap_solution');{delete solution files}

      memo2.lines.add('Finished in '+IntToStr( round((gettickcount64 - startTick)/1000)) + ' sec. The FITS header contains a detailed history.');

      {close the window}
    end; {not zero count}

    Application.ProcessMessages;{look for keyboard instructions}
    total_counter:=total_counter+counterL; {keep record of images done}

  until ((counterL=0){none lrgb loop} and (extra1=''){lrgb loop} );{do all names}

  if total_counter=0 then {somehow nothing was stacked}
  begin
    memo2.lines.add('No images to stack.');
    if classify_filter1.checked then memo2.lines.add('Hint: remove check mark from classify by "image filter" if required.');
    if classify_object1.checked then memo2.lines.add('Hint: remove check mark from classify by "image object" if required.');
    if use_astrometry_internal1.checked then memo2.lines.add('Hint: check field of view camera in tab alignment.');
  end;

  {$IFDEF fpc}
  progress_indicator(-100,'');{back to normal}
  {$else} {delphi}
  mainwindow.taskbar1.progressstate:=TTaskBarProgressState.None;
  {$endif}

  update_menu(true);

  mainwindow.shape_alignment_marker1.visible:=false;{remove shape for manual alignment}

  img_temp:=nil;{remove used memory}
  img_average:=nil;
  img_average:=nil;
  img_final:=nil;
  img_variance:=nil;

  if write_log1.checked then Memo2.Lines.SaveToFile(ChangeFileExt(Filename2,'.txt'));

  if powerdown_enabled1.checked then {power down system}
  begin
    i:=60; {60 seconds}
    repeat
      beep;
      memo2.lines.add(TimeToStr(time)+' Will shutdown system in '+inttostr(i) + ' sec!! Hit ESC or uncheck shutdown action to avoid.');
      sleep(1000);
      application.processmessages;
      if  ((powerdown_enabled1.checked=false) or (esc_pressed)) then
      begin
        memo2.lines.add(TimeToStr(time)+' Shutdown avoided.');
        exit;
      end;
      dec(i);
    until i<=0;
   {$ifdef mswindows}
     mainwindow.caption:= ShutMeDown;
   {$else} {unix}
     fpSystem('/sbin/shutdown -P now');
   {$endif}
  end;
end;

procedure Tstackmenu1.stack_method1Change(Sender: TObject);
var
   sigm, aver, mosa : boolean;
begin
  aver:=stack_method1. ItemIndex=0;{average}
  sigm:=stack_method1. ItemIndex=1;{sigma clip}
  mosa:=stack_method1. ItemIndex=2;{mosaic}

  mosaic_box1.enabled:=mosa;
  stackmenu1.drizzle1.enabled:=(mosa=false);
  sd_factor1.enabled:=sigm;

  if ((use_astrometry_internal1.checked=false) and (mosa)) then
  begin
    use_astrometry_internal1.checked:=true;
    memo2_message('Switched to INTERNAL ASTROMETRIC alignment. You could switch to astrometry.net for high accuracy. Set the oversize high enough to have enough work space.');
  end;
  if mosa then memo2_message('Astrometric image stitching mode. This will stich astrometric tiles. Prior to this stack the images to tiles and check for clean edges. If not use the crop function or negative oversize prior to stacking.');

  if ((use_star_alignment1.checked=false) and (use_manual_alignment1.checked=false)) then
    if ((aver) or (sigm)) then
    begin
      use_star_alignment1.checked:=true;
      memo2_message('Switched to INTERNAL STAR alignment. You could switch to astrometric alignment if required.');
    end;

  classify_object1.enabled:=(mosa=false); {in mosaic mode ignore object name}
  oversize1.enabled:=(mosa=false); {in mosaic mode ignore this oversize setting}
end;

procedure Tstackmenu1.use_astrometry_internal1Change(Sender: TObject);
begin
  update_stackmenu;
end;



procedure Tstackmenu1.use_astrometry_net1Change(Sender: TObject);
begin
  update_stackmenu;
end;

procedure Tstackmenu1.use_star_alignment1Change(Sender: TObject);
begin
  update_stackmenu;
end;

procedure Tstackmenu1.apply_vertical_gradient1Click(Sender: TObject);
var
   fitsX,fitsY,i,k,most_common,y1,y2,x1,x2,counter,step : integer;
   Save_Cursor:TCursor;
   mean  : double;

begin
  if fits_file=false then exit;


  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  backup_img;

  step:=round(strtofloat2(gradient_filter_factor1.text));

  mean:=0;
  counter:=0;

  {vertical}
  if sender=apply_vertical_gradient1 then
  for k:=0 to naxis3-1 do {do all colors}
  begin
   for fitsY:=0 to (height2-1) div step do
     begin
       y1:=(step+1)*fitsY-(step div 2);
       y2:=(step+1)*fitsY+(step div 2);
       most_common:=get_most_common(img_backup,k,0,width2-1,y1,y2,32000);
       mean:=mean+most_common;
       inc(counter);
       for i:=y1 to y2 do
         for fitsX:=0 to width2-1 do
         begin
           if ((i>=0) and (i<=height2-1)) then
           img_loaded[k,fitsX,i]:=most_common;{store common vertical values}
         end;
     end;
  end;{K}

  {horizontal}
  if sender=apply_horizontal_gradient1 then
  for k:=0 to naxis3-1 do {do all colors}
  begin
   for fitsX:=0 to (width2-1) div step do
     begin
       x1:=(step+1)*fitsX-(step div 2);
       x2:=(step+1)*fitsX+(step div 2);
       most_common:=get_most_common(img_backup,k,x1,x2,0,height2-1,32000);
       mean:=mean+most_common;
       inc(counter);
       for i:=x1 to x2 do
         for fitsY:=0 to height2-1 do
         begin
           if ((i>=0) and (i<=width2-1)) then
             img_loaded[k,i,fitsY]:=most_common;{store common vertical values}
         end;
     end;
  end;{K}


  mean:=mean/counter;

  gaussian_blur2(img_loaded,step*2);

  for k:=0 to naxis3-1 do {do all colors}
  begin
      for fitsY:=0 to height2-1 do
       for fitsX:=0 to width2-1 do
        begin
          img_loaded[k,fitsX,fitsY]:=mean+img_backup[k,fitsX,fitsY]-img_loaded[k,fitsX,fitsY];
        end;
  end;{k color}

  getfits_histogram(0);{get histogram YES, plot histogram YES, set min & max YES}
  plot_fits(mainwindow.image1,false);
  Screen.Cursor:=Save_Cursor;

end;

procedure Tstackmenu1.Viewimage1Click(Sender: TObject);
begin
  if sender=Viewimage1 then listview_view(listview1);{from popupmenus}
  if sender=Viewimage2 then listview_view(listview2);
  if sender=Viewimage3 then listview_view(listview3);
  if sender=Viewimage4 then listview_view(listview4);
  if sender=Viewimage5 then listview_view(listview5);
  if sender=Viewimage6 then listview_view(listview6);{popup menu blink}
  if sender=Viewimage7 then listview_view(listview7);{popup menu blink}
end;

end.
