unit unit_stack;
{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface
uses
 {$IFDEF fpc}
 {$else} {delphi}
  {$endif}
 {$ifdef mswindows}
  Windows,
  ShlObj,{for copy file(s) to clipboard}
   {$IFDEF fpc}{mswindows & FPC}
   {$else} {delphi}
    system.Win.TaskbarCore, Vcl.ImgList,
 {$endif}
 {$else} {unix}
  LCLType, {for vk_...}
  unix, {for fpsystem}
 {$endif}
 SysUtils, Variants,Classes, Graphics,
 Controls, Forms, Dialogs, ComCtrls, StdCtrls,
 math, ExtCtrls, Menus, Buttons,
 LCLIntf,{for for getkeystate, selectobject, openURL}
 clipbrd, Types,strutils,
 astap_main;


type
  { Tstackmenu1 }
  Tstackmenu1 = class(TForm)
    actual_search_distance1: TLabel;
    add_noise1: TButton;
    add_substract1: TComboBox;
    add_time1: TCheckBox;
    apply_normalise_filter1: TCheckBox;
    browse1: TBitBtn;
    browse_blink1: TBitBtn;
    browse_monitoring1: TBitBtn;
    browse_mount1: TBitBtn;
    browse_live_stacking1: TBitBtn;
    RAposition1: TLabel;
    monitor_applydarkflat1: TCheckBox;
    help_monitoring1: TLabel;
    monitor_date1: TLabel;
    file_to_add1: TBitBtn;
    browse_photometry1: TBitBtn;
    browse_dark1: TBitBtn;
    browse_bias1: TBitBtn;
    browse_flats1: TBitBtn;
    browse_inspector1: TBitBtn;
    annotations_visible1: TLabel;
    classify_flat_date1: TCheckBox;
    classify_flat_exposure1: TCheckBox;
    hours_and_minutes1: TCheckBox;
    center_position1: TLabel;
    binning1: TLabel;
    Label3: TLabel;
    Label43: TLabel;
    live_monitoring1: TButton;
    monitoring_path1: TLabel;
    monitoring_stop1: TButton;
    DECposition1: TLabel;
    removeselected5: TMenuItem;
    menukeywordchange1: TMenuItem;
    MenuItem32: TMenuItem;
    keywordchangelast1: TMenuItem;
    keywordchangesecondtolast1: TMenuItem;
    calc_polar_alignment_error1: TButton;
    planetary_image1: TCheckBox;
    classify_dark_date1: TCheckBox;
    flat_combine_method1: TComboBox;
    GroupBox8: TGroupBox;
    green_purple_filter1: TCheckBox;
    help_mount_tab1: TLabel;
    osc_preserve_r_nebula1: TCheckBox;
    lrgb_auto_level1: TCheckBox;
    lrgb_colour_smooth1: TCheckBox;
    lrgb_smart_colour_sd1: TComboBox;
    lrgb_smart_smooth_width1: TComboBox;
    lrgb_preserve_r_nebula1: TCheckBox;
    preserve_red_nebula1: TCheckBox;
    equinox1: TComboBox;
    add_valueB1: TEdit;
    add_valueG1: TEdit;
    add_valueR1: TEdit;
    alignment1: TTabSheet;
    align_blink1: TCheckBox;
    aavso_button1: TButton;
    mount_analyse1: TButton;
    analysephotometrymore1: TButton;
    blink_button_contB1: TButton;
    blink_unaligned_multi_step_backwards1: TButton;
    changekeyword9: TMenuItem;
    clear_mount_list1: TButton;
    keyword9: TMenuItem;
    list_to_clipboard9: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    mount_ignore_solutions1: TCheckBox;
    extract_green1: TButton;
    changekeyword6: TMenuItem;
    changekeyword7: TMenuItem;
    checkBox_annotate1: TCheckBox;
    annulus_radius1: TComboBox;
    keyword8: TMenuItem;
    changekeyword8: TMenuItem;
    keyword6: TMenuItem;
    keyword7: TMenuItem;
    copy_to_photometry1: TMenuItem;
    copy_to_blink1: TMenuItem;
    Label26: TLabel;
    flux_aperture1: TComboBox;
    Label27: TLabel;
    listview9: TListView;
    MenuItem28: TMenuItem;
    mount_add_solutions1: TButton;
    mount_write_wcs1: TCheckBox;
    PopupMenu9: TPopupMenu;
    removeselected9: TMenuItem;
    renametobak9: TMenuItem;
    monitor_action1: TComboBox;
    select9: TMenuItem;
    selectall5: TMenuItem;
    selectall9: TMenuItem;
    SpeedButton2: TSpeedButton;
    mount1: TTabSheet;
    apply_box_filter2: TButton;
    tab_monitoring1: TTabSheet;
    test_osc_normalise_filter1: TButton;
    undo_button6: TBitBtn;
    unselect9: TMenuItem;
    Viewimage9: TMenuItem;
    yyyyyy: TMenuItem;
    xxxxxx: TMenuItem;
    merge_overlap1: TCheckBox;
    timestamp1: TCheckBox;
    Analyse1: TButton;
    analyseblink1: TButton;
    analysedarksButton2: TButton;
    analyseflatdarksButton1: TButton;
    analyseflatsButton3: TButton;
    analysephotometry1: TButton;
    analyse_inspector1: TButton;
    add_bias1: TCheckBox;
    binning_for_solving_label3: TLabel;
    analyse_objects_visibles1: TButton;
    binning_for_solving_label4: TLabel;
    bin_image1: TButton;
    ignorezero1: TCheckBox;
    Equalise_background1: TCheckBox;
    GroupBox17: TGroupBox;
    bin_factor1: TComboBox;
    undo_button12: TBitBtn;
    write_video1: TButton;
    Label36: TLabel;
    Label49: TLabel;
    Label54: TLabel;
    Label62: TLabel;
    most_common_mono1: TButton;
    correct_gradient_label1: TLabel;
    save_settings_extra_button1: TButton;
    calculated_scale1: TLabel;
    osc_colour_smooth1: TCheckBox;
    smart_colour_sd1: TComboBox;
    raw_conversion_program1: TComboBox;
    GroupBox15: TGroupBox;
    focallength1: TEdit;
    GroupBox13: TGroupBox;
    help_stack_menu3: TLabel;
    ignore_header_solution1: TCheckBox;
    copy_files_to_clipboard1: TMenuItem;
    interim_to_clipboard1: TCheckBox;
    Label13: TLabel;
    Label22: TLabel;
    Label25: TLabel;
    min_star_size_stacking1: TComboBox;
    go_step_two1: TBitBtn;
    osc_smart_colour_sd1: TComboBox;
    osc_smart_smooth_width1: TComboBox;
    update_annotation1: TCheckBox;
    update_solution1: TCheckBox;
    update_annotations1: TCheckBox;
    Label23: TLabel;
    Label24: TLabel;
    Label28: TLabel;
    ephemeris_centering1: TComboBox;
    panel_ephemeris1: TPanel;
    pixelsize1: TEdit;
    saturation_tolerance1: TTrackBar;
    remove_luminance1: TCheckBox;
    curve_fitting1: TButton;
    apply_artificial_flat_correction1: TButton;
    apply_artificial_flat_correctionV2: TButton;
    apply_background_noise_filter1: TButton;
    apply_dpp_button1: TButton;
    apply_factor1: TButton;
    apply_file1: TButton;
    apply_gaussian_blur_button1: TButton;
    apply_gaussian_filter1: TButton;
    apply_get_background1: TButton;
    apply_horizontal_gradient1: TButton;
    apply_hue1: TButton;
    apply_remove_background_colour1: TButton;
    apply_vertical_gradient1: TButton;
    area_selected1: TLabel;
    area_set1: TLabel;
    artificial_image_gradient1: TCheckBox;
    auto_background1: TCheckBox;
    auto_background_level1: TButton;
    bayer_pattern1: TComboBox;
    bb1: TEdit;
    bg1: TEdit;
    Bias: TTabSheet;
    blink_button1: TButton;
    blink_button_contF1: TButton;
    photometry_repeat1: TButton;
    solve_and_annotate1: TCheckBox;
    blink_stop1: TButton;
    lights_blink_pause1: TButton;
    blink_unaligned_multi_step1: TButton;
    blue_filter1: TEdit;
    blue_filter2: TEdit;
    blue_filter_add1: TEdit;
    blur_factor1: TComboBox;
    br1: TEdit;
    Button_free_resize_fits1: TButton;
    calibrate_prior_solving1: TCheckBox;
    refresh_astrometric_solutions1: TButton;
    clear_blink_alignment1: TButton;
    clear_blink_list1: TButton;
    clear_inspector_list1: TButton;
    clear_dark_list1: TButton;
    clear_image_list1: TButton;
    clear_photometry_list1: TButton;
    clear_selection2: TButton;
    clear_selection3: TButton;
    colournebula1: TButton;
    colourShape1: TShape;
    colourShape2: TShape;
    colourShape3: TShape;
    create_test_image_stars1: TButton;
    Darks: TTabSheet;
    dark_areas_box_size1: TComboBox;
    dark_spot_filter1: TButton;
    ddp_filter1: TRadioButton;
    ddp_filter2: TRadioButton;
    demosaic_method1: TComboBox;
    downsample_for_solving1: TComboBox;
    downsample_solving_label1: TLabel;
    Edit_a1: TEdit;
    edit_background1: TEdit;
    Edit_gaussian_blur1: TEdit;
    edit_k1: TEdit;
    edit_noise1: TEdit;
    Edit_width1: TEdit;
    export_aligned_files1: TButton;
    extract_background_box_size1: TComboBox;
    field1: TLabel;
    files_live_stacked1: TLabel;
    filter_artificial_colouring1: TComboBox;
    filter_groupbox1: TGroupBox;
    Flats: TTabSheet;
    force_oversize1: TCheckBox;
    gb1: TEdit;
    gg1: TEdit;
    gr1: TEdit;
    gradient_filter_factor1: TEdit;
    green_filter1: TEdit;
    green_filter2: TEdit;
    green_filter_add1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox10: TGroupBox;
    GroupBox11: TGroupBox;
    GroupBox12: TGroupBox;
    GroupBox14: TGroupBox;
    GroupBox16: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    raw_box1: TGroupBox;
    GroupBox9: TGroupBox;
    GroupBox_astrometric_solver_settings1: TGroupBox;
    groupBox_dvp1: TGroupBox;
    GroupBox_equalise_tool1: TGroupBox;
    GroupBox_equalise_tool2: TGroupBox;
    GroupBox_star_alignment_settings1: TGroupBox;
    GroupBox_test_images1: TGroupBox;
    help_astrometric_alignment1: TLabel;
    help_astrometric_solving1: TLabel;
    help_blink1: TLabel;
    help_live_stacking1: TLabel;
    help_osc_menu1: TLabel;
    help_photometry1: TLabel;
    help_inspector_tab1: TLabel;
    help_pixel_math1: TLabel;
    help_pixel_math2: TLabel;
    help_stack_menu1: TLabel;
    help_uncheck_outliers1: TLabel;
    hfd_simulation1: TComboBox;
    HueRadioButton1: TRadioButton;
    HueRadioButton2: TRadioButton;
    hue_fuzziness1: TTrackBar;
    lights: TTabSheet;
    image_to_add1: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label4: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label5: TLabel;
    Label50: TLabel;
    Label51: TLabel;
    Label52: TLabel;
    Label53: TLabel;
    Label55: TLabel;
    Label56: TLabel;
    Label57: TLabel;
    Label58: TLabel;
    Label59: TLabel;
    Label6: TLabel;
    Label60: TLabel;
    Label61: TLabel;
    Label64: TLabel;
    Label65: TLabel;
    Label67: TLabel;
    Label68: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label_results1: TLabel;
    listview1: TListView;
    listview2: TListView;
    listview3: TListView;
    listview4: TListView;
    listview5: TListView;
    listview6: TListView;
    listview7: TListView;
    listview8: TListView;
    list_to_clipboard8: TMenuItem;
    live_stacking1: TButton;
    live_stacking_path1: TLabel;
    live_stacking_pause1: TButton;
    live_stacking_restart1: TButton;
    luminance_filter1: TEdit;
    luminance_filter2: TEdit;
    make_osc_color1: TCheckBox;
    manual_centering1: TComboBox;
    mark_outliers_upto1: TComboBox;
    min_star_size1: TComboBox;
    max_stars1: TComboBox;
    MenuItem23: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    mosaic_box1: TGroupBox;
    mosaic_crop1: TUpDown;
    mosaic_crop2: TEdit;
    mosaic_width1: TUpDown;
    mosaic_width2: TEdit;
    most_common_filter_radius1: TEdit;
    most_common_filter_tool1: TButton;
    multiply_blue1: TEdit;
    multiply_green1: TEdit;
    multiply_red1: TEdit;
    new_height1: TLabel;
    new_height2: TLabel;
    new_saturation1: TTrackBar;
    noisefilter_blur1: TComboBox;
    noisefilter_sd1: TComboBox;
    nr_selected1: TLabel;
    nr_total1: TLabel;
    nr_total_bias1: TLabel;
    nr_total_blink1: TLabel;
    nr_total_inspector1: TLabel;
    nr_total_darks1: TLabel;
    nr_total_flats1: TLabel;
    nr_total_photometry1: TLabel;
    osc_auto_level1: TCheckBox;
    oversize1: TComboBox;
    pagecontrol1: TPageControl;
    panel_manual1: TPanel;
    Panel_solver1: TPanel;
    Panel_star_detection1: TPanel;
    photometry_binx2: TButton;
    photometry_button1: TButton;
    photometry_stop1: TButton;
    PopupMenu8: TPopupMenu;
    radius_search1: TComboBox;
    scale_calc1: TLabel;
    auto_rotate1: TCheckBox;
    use_ephemeris_alignment1: TRadioButton;
    write_jpeg1: TCheckBox;
    xxxxxxx: TComboBox;
    rainbow_Panel1: TPanel;
    rb1: TEdit;
    red_filter1: TEdit;
    red_filter2: TEdit;
    red_filter_add1: TEdit;
    removeselected8: TMenuItem;
    remove_deepsky_label1: TLabel;
    renametobak8: TMenuItem;
    replace_by_master_dark1: TButton;
    replace_by_master_flat1: TButton;
    reset_factors1: TButton;
    resize_factor1: TComboBox;
    restore_file_ext1: TButton;
    Result1: TTabSheet;
    result_compress1: TMenuItem;
    MenuItem25: TMenuItem;
    rename_result1: TMenuItem;
    MenuItem24: TMenuItem;
    more_indication1: TLabel;
    list_to_clipboard7: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    ColorDialog1: TColorDialog;
    extend_object_name_with_time_observation1: TMenuItem;
    MenuItem19: TMenuItem;
    list_to_clipboard6: TMenuItem;
    PopupMenu7: TPopupMenu;
    removeselected7: TMenuItem;
    renametobak7: TMenuItem;
    rg1: TEdit;
    ring_equalise_factor1: TComboBox;
    rr1: TEdit;
    sample_size1: TComboBox;
    saved1: TLabel;
    save_as_new_file1: TButton;
    save_result1: TButton;
    sd_factor1: TComboBox;
    sd_factor_list1: TComboBox;
    search_fov1: TComboBox;
    select7: TMenuItem;
    select8: TMenuItem;
    selectall3: TMenuItem;
    selectall4: TMenuItem;
    selectall6: TMenuItem;
    selectall2: TMenuItem;
    selectall1: TMenuItem;
    selectall7: TMenuItem;
    list_to_clipboard1: TMenuItem;
    selectall8: TMenuItem;
    show_quads1: TBitBtn;
    sigma_decolour1: TComboBox;
    smart_colour_smooth_button1: TButton;
    smart_smooth_width1: TComboBox;
    solve1: TButton;
    solve_show_log1: TCheckBox;
    SpeedButton1: TSpeedButton;
    splitRGB1: TButton;
    stack_button1: TBitBtn;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem15: TMenuItem;
    PopupMenu6: TPopupMenu;
    removeselected6: TMenuItem;
    renametobak6: TMenuItem;
    select6: TMenuItem;
    stack_method1: TComboBox;
    star_database1: TComboBox;
    star_level_colouring1: TComboBox;
    subtract_background1: TButton;
    TabSheet1: TTabSheet;
    tab_blink1: TTabSheet;
    tab_live_stacking1: TTabSheet;
    tab_photometry1: TTabSheet;
    tab_Pixelmath1: TTabSheet;
    tab_Pixelmath2: TTabSheet;
    tab_stackmethod1: TTabSheet;
    test_pattern1: TButton;
    quad_tolerance1: TComboBox;
    uncheck_outliers1: TCheckBox;
    undo_button1: TBitBtn;
    undo_button10: TBitBtn;
    undo_button11: TBitBtn;
    undo_button13: TBitBtn;
    undo_button14: TBitBtn;
    undo_button15: TBitBtn;
    undo_button16: TBitBtn;
    undo_button2: TBitBtn;
    undo_button3: TBitBtn;
    undo_button4: TBitBtn;
    undo_button5: TBitBtn;
    undo_button7: TBitBtn;
    undo_button8: TBitBtn;
    undo_button9: TBitBtn;
    undo_button_equalise_background1: TBitBtn;
    unselect6: TMenuItem;
    unselect7: TMenuItem;
    unselect8: TMenuItem;
    unselect_area1: TButton;
    UpDown1: TUpDown;
    use_astrometry_internal1: TRadioButton;
    use_manual_alignment1: TRadioButton;
    use_star_alignment1: TRadioButton;
    Viewimage6: TMenuItem;
    Viewimage7: TMenuItem;
    Viewimage8: TMenuItem;
    width_UpDown1: TUpDown;
    write_log1: TCheckBox;
    powerdown_enabled1: TCheckBox;
    classify_dark_exposure1: TCheckBox;
    classify_dark_temperature1: TCheckBox;
    classify_flat_filter1: TCheckBox;
    keyword1: TMenuItem;
    changekeyword1: TMenuItem;
    changekeyword2: TMenuItem;
    changekeyword3: TMenuItem;
    changekeyword4: TMenuItem;
    keyword2: TMenuItem;
    keyword3: TMenuItem;
    keyword4: TMenuItem;
    copy_to_images1: TMenuItem;
    help_stack_menu2: TLabel;
    MenuItem13: TMenuItem;
    copypath1: TMenuItem;
    PopupMenu5: TPopupMenu;
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
    unselect2: TMenuItem;
    unselect3: TMenuItem;
    unselect4: TMenuItem;
    unselect1: TMenuItem;
    select1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Memo2: TMemo;
    ImageList2: TImageList;
    PopupMenu1: TPopupMenu;
    renametobak1: TMenuItem;
    Viewimage1: TMenuItem;
    press_esc_to_abort1: TLabel;
    Viewimage2: TMenuItem;
    Viewimage3: TMenuItem;
    Viewimage4: TMenuItem;
    Viewimage5: TMenuItem;
    procedure add_noise1Click(Sender: TObject);
    procedure align_blink1Change(Sender: TObject);
    procedure analyseblink1Click(Sender: TObject);
    procedure browse_monitoring1Click(Sender: TObject);
    procedure equinox1Change(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure help_monitoring1Click(Sender: TObject);
    procedure help_mount_tab1Click(Sender: TObject);
    procedure live_monitoring1Click(Sender: TObject);
    procedure monitoring_stop1Click(Sender: TObject);
    procedure lrgb_auto_level1Change(Sender: TObject);
    procedure keywordchangelast1Click(Sender: TObject);
    procedure keywordchangesecondtolast1Click(Sender: TObject);
    procedure calc_polar_alignment_error1Click(Sender: TObject);
    procedure mount_analyse1Click(Sender: TObject);
    procedure analysephotometry1Click(Sender: TObject);
    procedure analyse_inspector1Click(Sender: TObject);
    procedure apply_hue1Click(Sender: TObject);
    procedure auto_background_level1Click(Sender: TObject);
    procedure apply_background_noise_filter1Click(Sender: TObject);
    procedure bayer_pattern1Select(Sender: TObject);
    procedure bin_image1Click(Sender: TObject);
    procedure blink_stop1Click(Sender: TObject);
    procedure blink_unaligned_multi_step1Click(Sender: TObject);
    procedure browse_mount1Click(Sender: TObject);
    procedure browse_dark1Click(Sender: TObject);
    procedure browse_inspector1Click(Sender: TObject);
    procedure browse_live_stacking1Click(Sender: TObject);
    procedure analyse_objects_visibles1Click(Sender: TObject);
    procedure browse_photometry1Click(Sender: TObject);
    procedure aavso_button1Click(Sender: TObject);
    procedure clear_mount_list1Click(Sender: TObject);
    procedure extract_green1Click(Sender: TObject);
    procedure clear_inspector_list1Click(Sender: TObject);
    procedure copy_to_blink1Click(Sender: TObject);
    procedure copy_to_photometry1Click(Sender: TObject);
    procedure curve_fitting1Click(Sender: TObject);
    procedure ephemeris_centering1Change(Sender: TObject);
    procedure focallength1Exit(Sender: TObject);
    procedure go_step_two1Click(Sender: TObject);
    procedure luminance_filter1exit(Sender: TObject);
    procedure help_inspector_tab1Click(Sender: TObject);
    procedure help_live_stacking1Click(Sender: TObject);
    procedure help_pixel_math2Click(Sender: TObject);
    procedure hue_fuzziness1Change(Sender: TObject);
    procedure listview8CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure listview8CustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure live_stacking1Click(Sender: TObject);
    procedure copy_files_to_clipboard1Click(Sender: TObject);
    procedure most_common_mono1Click(Sender: TObject);
    procedure mount_add_solutions1Click(Sender: TObject);
    procedure new_saturation1Change(Sender: TObject);
    procedure pagecontrol1Change(Sender: TObject);
    procedure pagecontrol1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure press_esc_to_abort1Click(Sender: TObject);
    procedure rainbow_Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rainbow_Panel1Paint(Sender: TObject);
    procedure remove_luminance1Change(Sender: TObject);
    procedure result_compress1Click(Sender: TObject);
    procedure rename_result1Click(Sender: TObject);
    procedure restore_file_ext1Click(Sender: TObject);
    procedure colournebula1Click(Sender: TObject);
    procedure refresh_astrometric_solutions1click(Sender: TObject);
    procedure clear_photometry_list1Click(Sender: TObject);
    procedure export_aligned_files1Click(Sender: TObject);
    procedure extend_object_name_with_time_observation1Click(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormPaint(Sender: TObject);
    procedure help_blink1Click(Sender: TObject);
    procedure help_photometry1Click(Sender: TObject);
    procedure listview7CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: Boolean);
    procedure listview7CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure live_stacking_pause1Click(Sender: TObject);
    procedure live_stacking_restart1Click(Sender: TObject);
    procedure more_indication1Click(Sender: TObject);
    procedure photometry_binx2Click(Sender: TObject);
    procedure photometry_button1Click(Sender: TObject);
    procedure saturation_tolerance1Change(Sender: TObject);
    procedure save_settings_extra_button1Click(Sender: TObject);
    procedure smart_colour_smooth_button1Click(Sender: TObject);
    procedure classify_filter1Click(Sender: TObject);
    procedure apply_get_background1Click(Sender: TObject);
    procedure help_osc_menu1Click(Sender: TObject);
    procedure help_uncheck_outliers1Click(Sender: TObject);
    procedure listview6CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure list_to_clipboard1Click(Sender: TObject);
    procedure make_osc_color1Click(Sender: TObject);
    procedure selectall1Click(Sender: TObject);
    procedure apply_remove_background_colour1Click(Sender: TObject);
    procedure reset_factors1Click(Sender: TObject);
    procedure search_fov1Change(Sender: TObject);
    procedure solve_and_annotate1Change(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure star_database1DropDown(Sender: TObject);
    procedure apply_box_filter2Click(Sender: TObject);
    procedure test_osc_normalise_filter1Click(Sender: TObject);

    procedure test_pattern1Click(Sender: TObject);
    procedure blink_button1Click(Sender: TObject);
    procedure create_test_image_stars1Click(Sender: TObject);
    procedure clear_blink_alignment1Click(Sender: TObject);
    procedure clear_blink_list1Click(Sender: TObject);
    procedure Edit_width1Change(Sender: TObject);
    procedure flux_aperture1change(Sender: TObject);
    procedure help_astrometric_solving1Click(Sender: TObject);
    procedure listview1CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: Boolean);
    procedure listview1CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
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
    procedure make_osc_color1Change(Sender: TObject);
    procedure copy_to_images1Click(Sender: TObject);
    procedure resize_factor1Change(Sender: TObject);
    procedure analysedarksButton2Click(Sender: TObject);
    procedure analyseflatsButton3Click(Sender: TObject);
    procedure analyseflatdarksButton1Click(Sender: TObject);
    procedure changekeyword1Click(Sender: TObject);
    procedure dark_spot_filter1Click(Sender: TObject);
    procedure free_resize_fits1Click(Sender: TObject);
    procedure copypath1Click(Sender: TObject);
    procedure help_pixel_math1Click(Sender: TObject);
    procedure help_stack_menu2Click(Sender: TObject);
    procedure help_stack_menu3Click(Sender: TObject);
    procedure listview1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sd_factor_blink1Change(Sender: TObject);
    procedure solve1Click(Sender: TObject);
    procedure splitRGB1Click(Sender: TObject);
    procedure clear_dark_list1Click(Sender: TObject);
    procedure clear_image_list1Click(Sender: TObject);
    procedure help_astrometric_alignment1Click(Sender: TObject);
    procedure help_stack_menu1Click(Sender: TObject);
    procedure help_internal_alignment1Click(Sender: TObject);
    procedure removeselected1Click(Sender: TObject);
    procedure show_quads1Click(Sender: TObject);
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
    procedure unselect_area1Click(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure FormResize(Sender: TObject);
    procedure listview1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure listview1Compare(Sender: TObject; Item1, Item2: TListItem;
       Data: Integer; var Compare: Integer);
    procedure apply_artificial_flat_correction1Click(Sender: TObject);
    procedure stack_method1Change(Sender: TObject);
    procedure use_astrometry_internal1Change(Sender: TObject);
    procedure use_ephemeris_alignment1Change(Sender: TObject);
    procedure use_manual_alignment1Change(Sender: TObject);
    procedure use_star_alignment1Change(Sender: TObject);
    procedure apply_vertical_gradient1Click(Sender: TObject);
    procedure Viewimage1Click(Sender: TObject);
    procedure write_video1Click(Sender: TObject);
  private
    { Private declarations }
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
type
   tstarlistpackage  = record {for photometry tab}
     width: integer;
     height: integer;
     flux_magn_offset : double;
     starlist : star_list;
   end;
var
  starlistpack     : array of tstarlistpackage;{for photometry tab}


var
  calc_scale:double;
  counterR,counterG, counterB,  counterRGB,counterL,
  counterRdark,counterGdark, counterBdark,  counterRGBdark,counterLdark,
  counterRflat,counterGflat, counterBflat,  counterRGBflat,counterLflat,
  counterRbias,counterGbias, counterBbias,  counterRGBbias,counterLbias,
  temperatureL,temperatureR,temperatureG,temperatureB,temperatureRGB,
  exposureR, exposureG,exposureB,exposureRGB,exposureL            : integer;
  sum_exp,photometry_stdev                                        : double;
  referenceX,referenceY    : double;{reference position used stacking}
  ref_X, ref_Y             : double;{reference position from FITS header, used for manual stacking of colour lights, second stage}
  jd_start                 : double;{julian day of date-obs}
  jd_mid                   : double;{julian day of mid head.exposure}
  jd_sum                   : double;{sum of julian days}
  jd_stop                  : double;{end observation in julian days}
  files_to_process, files_to_process_LRGB : array of  TfileToDo;{contains names to process and index to listview1}
  flat_norm_value{,dark_average,dark_sigma } : double;
  areax1,areax2,areay1,areay2 : integer;
  hue1,hue2: single;{for colour disk}
  asteroidlist : array of array of array of double;
  solve_show_log  : boolean;


var  {################# initialised variables #########################}
  dark_exposure : integer=987654321;{not done indication}
  dark_temperature: integer=987654321;
  flat_filter : string='987654321';{not done indication}
  last_light_jd: integer=987654321;
  last_flat_loaded : string='';
  last_dark_loaded : string='';

  new_analyse_required: boolean=false;{if changed then reanalyse tab 1}
  new_analyse_required3: boolean=false;{if changed then reanalyse tab 3}
  quads_displayed:boolean=false;{no quads visible, so no refresh required}
  equalise_background_step: integer=1;
const
  dialog_filter='FITS files and DSLR RAW files |*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;'+
                '|FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;'+
                '|JPEG, TIFF, PNG PPM files|*.png;*.PNG;*.tif;*.tiff;*.TIF;*.jpg;*.JPG;*.ppm;*.pgm;*.pbm;*.pfm;*.xisf;'+
                '|RAW files|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;';

procedure listview_add(tl: tlistview; s0:string; is_checked:boolean; count:integer);
procedure listview_add_xy(fitsX,fitsY: double);{add x,y position to listview}
procedure update_equalise_background_step(pos1: integer);{update equalise background menu}
procedure memo2_message(s: string);{message to memo2}
procedure update_stackmenu;{update stackmenu1 menus}
procedure box_blur(colors,range: integer;var img: image_array);{combine values of pixels, ignore zeros}
procedure normalize_OSC_flat(var img: image_array); {normalize bayer pattern. Colour shifts due to not using a white light source for the flat frames are avoided.}
procedure black_spot_filter(var img: image_array);{remove black spots with value zero}

function create_internal_solution(img :image_array) : boolean; {plate solving, image should be already loaded create internal solution using the internal solver}
procedure apply_dark_and_flat(var img : image_array) ; inline; {apply dark and flat if required, renew if different head.exposure or ccd temp}

procedure smart_colour_smooth( var img: image_array; wide, sd:double; preserve_r_nebula,measurehist:boolean);{Bright star colour smooth. Combine color values of wide x wide pixels, keep luminance intact}
procedure green_purple_filter( var img: image_array);{Balances RGB to remove green and purple. For e.g. Hubble palette}
procedure date_to_jd(date_time:string;exp :double);{convert date_obs string and exposure time to global variables jd_start (julian day start exposure) and jd_mid (julian day middle of the exposure)}
function JdToDate(jd:double):string;{Returns Date from Julian Date}
procedure resize_img_loaded(ratio :double); {resize img_loaded in free ratio}
function median_background(var img :image_array;color,sizeX,sizeY,x,y:integer): double;{find median value of an area at position x,y with sizeX,sizeY}
procedure analyse_image(img : image_array;snr_min:double;report:boolean;out star_counter : integer; out backgr, hfd_median : double); {find background, number of stars, median HFD}
procedure sample(sx,sy : integer);{sampe local colour and fill shape with colour}
procedure apply_most_common(sourc,dest: image_array; radius: integer);  {apply most common filter on first array and place result in second array}

//function  restore_solution(clear :boolean): boolean;{restore solution}
procedure report_results(object_to_process,stack_info :string;object_counter,colorinfo:integer);{report on tab results}
procedure apply_factors;{apply r,g,b factors to image}
procedure listviews_begin_update; {speed up making stackmenu visible having a many items}
procedure listviews_end_update;{speed up making stackmenu visible having a many items}
procedure analyse_listview(lv :tlistview; light,full, refresh: boolean);{analyse list of FITS files}
function julian_calc(yyyy,mm:integer;dd,hours,minutes,seconds:double):double; {##### calculate julian day, revised 2017}


const
  L_object=0; {lights, position in listview1}
  L_filter=1;
  L_result=2;
  L_bin=3;
  L_hfd=4;
  L_quality=5;
  L_background=6;
  L_starlevel=7;
  L_sharpness=8;
  L_exposure=9;
  L_temperature=10;
  L_width=11;
  L_height=12;
  L_type=13;
  L_datetime=14;
  L_position=15;
  L_solution=16;
  L_x=17;
  L_y=18;
  L_calibration=19;
  L_focpos=20;
  L_foctemp=21;
  L_gain=22;
  L_centalt=23;
  L_centaz=24;
  L_sqm=25;
  L_nr=26;{number of fields}

  D_exposure=0;
  D_temperature=1;
  D_binning=2;
  D_width=3;
  D_height=4;
  D_type=5;
  D_date=6;
  D_background=7;
  D_sigma=8;
  D_gain=9;
  D_jd=10;
  D_nr=11;{number of fields}

  F_exposure=0;  {flats}
  F_filter=10;
  F_jd=11;
  F_calibration=12;
  F_nr=13;{number of fields}

  FD_exposure=0;  {flat_darks}
  FD_nr=10;{flat darks}

  B_exposure=0;  {blink}
  B_temperature=1;
  B_binning=2;
  B_width=3;
  B_height=4;
  B_type=5;
  B_date=6;
  B_calibration=7;
  B_solution=8;
  B_annotated=9;
  B_nr=10;{number of fields}

  P_exposure=0;       {photometry tab}
  P_temperature=1;
  P_binning=2;
  P_width=3;
  P_height=4;
  P_type=5;
  P_background=6;
  P_filter=7;
  P_date=8;
  P_jd_mid=9;
  P_jd_helio=10;
  P_magn1=11;
  P_snr=12;
  P_magn2=13;
  P_magn3=14;
  P_hfd=15;
  P_stars=16;
  P_astrometric=17;
  P_photometric=18;
  P_calibration=19;
  P_centalt=20;
  P_airmass=21;
  P_nr=22;{number of fields}

  M_exposure=0;  {blink}
  M_temperature=1;
  M_binning=2;
  M_width=3;
  M_height=4;
  M_type=5;
  M_date=6;
  M_jd_mid=7;
  M_ra=8;
  M_dec=9;
  M_ra_m=10;
  M_dec_m=11;
  M_ra_e=12;
  M_dec_e=13;
  M_centalt=14;
  M_foctemp=15;
  M_nr=16;{number of fields}


  icon_thumb_down=8; {image index for outlier}
  icon_king=16;{image index for best image}

  insp_focus_pos=8;
  insp_nr_stars=7;

implementation

uses
  unit_image_sharpness, unit_ephemerides, unit_gaussian_blur, unit_star_align, unit_astrometric_solving,unit_stack_routines,unit_annotation,unit_hjd,
  unit_live_stacking, unit_monitoring, unit_hyperbola, unit_asteroid,unit_yuv4mpeg2, unit_aavso,unit_raster_rotate;


type
   theaderbackup  = record
//     head.naxis   : integer;
//     naxis1  : integer;
//     naxis2  : integer;
//     head.naxis3  : integer;
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
     date_obs: string; {for accurate asteroid plotting after manual stack}
//     header : string;
   end;
var
   header_backup : array of theaderbackup;{dynamic so memory can be freed}

type
  blink_solution  = record
    solution_vectorX : solution_vector {array[0..2] of double};
    solution_vectorY : solution_vector;
  end;

var
    bsolutions      : array of blink_solution;


{$IFDEF fpc}
  {$R *.lfm}
{$else}  {delphi}
 {$R *.lfm}
{$endif}

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
 if x<0.99999 then
    result:=sqrt(sqrt(sqr( (2/(pi*a)) + ln(1-x*x)/2)-(ln(1-x*x)/a) ) - (2/(pi*a) + ln(1-x*x)/2) )
 else
    result:=99.99;
end;

procedure update_stackmenu;{update stackmenu1 menus, called onshow stackmenu1}
begin
  with stackmenu1 do
  begin
    {set bevel colours}
    Panel_solver1.bevelouter:=bvNone;
    Panel_star_detection1.bevelouter:=bvNone;
    Panel_solver1.color:=clForm;
    Panel_star_detection1.color:=clForm;

    panel_manual1.color:=clForm;
    panel_ephemeris1.color:=clForm;

    min_star_size_stacking1.enabled:=false;

    if use_star_alignment1.checked then
    begin
       Panel_star_detection1.bevelouter:=bvSpace; {blue corner}
       Panel_star_detection1.color:=CLWindow;
       min_star_size_stacking1.enabled:=true;
    end
    else
    if use_astrometry_internal1.checked then
    begin
      Panel_solver1.bevelouter:=bvSpace;
      Panel_solver1.color:=CLWindow;
      Panel_star_detection1.color:=CLWindow;
    end
    else
    if use_manual_alignment1.checked then
    begin
      panel_manual1.bevelouter:=bvSpace;
      panel_manual1.color:=CLWindow;
    end
    else
    if use_ephemeris_alignment1.checked then
    begin
      panel_ephemeris1.bevelouter:=bvSpace;
      panel_ephemeris1.color:=CLWindow;
    end;
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


function ansi_only(s:string): string;
begin
  result:=StringReplace(s,'Δ','offset',[rfReplaceAll]);
  result:=StringReplace(result,'α','RA',[rfReplaceAll]);
  result:=StringReplace(result,'δ','DEC',[rfReplaceAll]);
end;


procedure memo2_message(s: string);{message to memo2. Is also used for log to file in commandline mode}
begin
  {$IFDEF unix}  {linux and mac}
  if commandline_execution then
  begin
    if filename2='stdin' then s:='COMMENT='+s;
    writeln(s); {linux command line can write unicode}
  end;
  {$ELSE }
  if ((commandline_execution) and (isConsole)){isconsole, is console available, prevent run time error if compiler option -WH is checked}
  then
  begin
    if stdin_mode then s:='COMMENT='+s;
    writeln(ansi_only(s)); {log to console for Windows when compiler WIN32 gui is off}
  end;
  {$ENDIF}


  if ((commandline_execution=false) or (commandline_log=true)) then {no commandline or option -log is used}
  begin
     stackmenu1.memo2.lines.add(TimeToStr(time)+'  '+s); {fill memo2 with log}

     {$IFDEF unix}
     if ((commandline_execution=false){save some time and run time error in command line} and (stackmenu1.Memo2.HandleAllocated){prevent run time errors}) then
     begin  // scroll down:
       stackmenu1.Memo2.SelStart:=Length(stackmenu1.Memo2.lines.Text)-1;
       stackmenu1.Memo2.VertScrollBar.Position:=65000;
     end;
    {$ELSE }
    {$ENDIF}
  end;
end;


procedure listviews_begin_update;{speed up making stackmenu visible having a many items}
begin
  stackmenu1.listview1.Items.beginUpdate;
  stackmenu1.listview2.Items.beginUpdate;
  stackmenu1.listview3.Items.beginUpdate;
  stackmenu1.listview4.Items.beginUpdate;
  stackmenu1.listview5.Items.beginUpdate;
  stackmenu1.listview6.Items.beginUpdate;
  stackmenu1.listview7.Items.beginUpdate;
  stackmenu1.listview8.Items.beginUpdate;
//  stackmenu1.listview9.Items.beginUpdate;{not stored}
end;


procedure listviews_end_update; {speed up making stackmenu visible having a many items}
begin
  stackmenu1.listview1.Items.EndUpdate;
  stackmenu1.listview2.Items.EndUpdate;
  stackmenu1.listview3.Items.EndUpdate;
  stackmenu1.listview4.Items.EndUpdate;
  stackmenu1.listview5.Items.EndUpdate;
  stackmenu1.listview6.Items.EndUpdate;
  stackmenu1.listview7.Items.EndUpdate;
  stackmenu1.listview8.Items.EndUpdate;
//  stackmenu1.listview9.Items.EndUpdate;
end;


procedure listview_add(tl: tlistview; s0:string; is_checked: boolean; count:integer);
var
  ListItem: TListItem;
  i : integer;
begin
  with tl do {stackmenu.listview2}
  begin
    {Items.BeginUpdate; is set before calling this procedure}
    ListItem := Items.Add;
    ListItem.Caption := s0;{with checkbox}
    ListItem.checked:=is_checked;
    for i:=1 to count do
        ListItem.SubItems.Add('');
//    Items[items.Count-1].Checked:=true;
    {Items.EndUpdate; is set after calling this procedure}
  end;
end;


procedure listview_add_xy(fitsX,fitsY: double);{add x,y position to listview}
var
    i: integer;
begin
 with stackmenu1 do
 for i:=0 to listview1.Items.Count-1 do
   if listview1.Items[i].Selected then
  begin
    ListView1.Items.item[i].subitems.Strings[L_X]:=floattostrF(fitsX,ffFixed,0,2);
    ListView1.Items.item[i].subitems.Strings[L_Y]:=floattostrF(fitsY,ffFixed,0,2);

    {$ifdef darwin} {MacOS}
    {bugfix darwin green red colouring}
    stackmenu1.ListView1.Items.item[i].Subitems.strings[L_result]:='✓ star';
    {$endif}
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

procedure count_selected; {report the number of lights selected in images_selected and update menu indication}
var
  c, images_selected         : integer;
begin
  images_selected:=0;
  for c:=0 to stackmenu1.ListView1.items.count-1 do
    if stackmenu1.ListView1.Items[c].Checked then inc(images_selected,1);
  stackmenu1.nr_selected1.caption:=inttostr(images_selected);{update menu info}
end;


procedure list_remove_outliers(key:string); {do statistics}
var
  quality_mean,quality_sd,sd_factor : double;
  c, counts,nr_good_images,quality, best, best_index : integer;
  sd : string;
begin
  best:=0;
  with stackmenu1 do
  begin
    counts:=ListView1.items.count-1;

    ListView1.Items.BeginUpdate;
    try
    {calculate means}
      c:=0;
      quality_mean:=0;
      nr_good_images:=0;
      repeat
        if ((ListView1.Items.item[c].checked) and (key=ListView1.Items.item[c].subitems.Strings[L_result])) then
        begin {checked}
          if strtofloat(ListView1.Items.item[c].subitems.Strings[L_hfd])>90 {hfd} then ListView1.Items.item[c].checked:=false {no quality, can't process this image}
          else
          begin {normal HFD value}
            quality:=strtoint(ListView1.Items.item[c].subitems.Strings[L_quality]);
            quality_mean:=quality_mean+quality;
            inc(nr_good_images);

            if quality>best then
            begin
              best:=quality;
              best_index:=c;
            end;
          end;
        end;
        inc(c); {go to next file}
      until c>counts;
      if nr_good_images>0 then quality_mean:=quality_mean/nr_good_images else quality_mean:=0;

      {calculate standard deviations}
      begin
        c:=0;
        quality_sd:=0;
        repeat {check all files, remove darks, bias}
          if ((ListView1.Items.item[c].checked) and (key=ListView1.Items.item[c].subitems.Strings[L_result]))then
          begin {checked}
            quality_sd:=quality_sd+sqr(quality_mean - strtoint(ListView1.Items.item[c].subitems.Strings[L_quality]) );
          end;
          inc(c); {go to next file}
        until c>counts;
        quality_sd:=sqrt(quality_sd/nr_good_images);
        memo2_message('Analysing group '+key+ ' for outliers.'+#9+#9+' Average image quality (nr stars/hfd)='+floattostrF(quality_mean,ffFixed,0,0)+ ', σ='+floattostrF(quality_sd,ffFixed,0,1));

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
          if ((ListView1.Items.item[c].checked) and (key=ListView1.Items.item[c].subitems.Strings[L_result])) then
          begin {checked}
            ListView1.Items.item[c].subitems.Strings[L_result]:='';{remove key, job done}
            if (quality_mean- strtoint(ListView1.Items.item[c].subitems.Strings[L_quality]))>sd_factor*quality_sd  then
            begin {remove low quality outliers}
              ListView1.Items.item[c].checked:=false;
              ListView1.Items.item[c].SubitemImages[L_quality]:=icon_thumb_down; {mark as outlier using imageindex}
              memo2_message(ListView1.Items.item[c].caption+ ' unchecked due to low quality = nr stars detected / hfd.' );
          end;
        end;
        inc(c); {go to next file}
      until c>counts;
    end;{throw outliers out}

    if best<>0 then
    begin
      ListView1.Items.item[best_index].SubitemImages[L_quality]:=icon_king; {mark best index. Not nessesary but just nice}
    end;

    finally
      ListView1.Items.EndUpdate;
    end;
  end;{with stackmenu1}
end;


procedure analyse_image(img : image_array;snr_min:double;report:boolean;out star_counter : integer; out backgr, hfd_median : double); {find background, number of stars, median HFD}
var
   width5,height5,fitsX,fitsY,size,radius,i,j,retries,max_stars,n,m,xci,yci,sqr_radius         : integer;
   hfd1,star_fwhm,snr,flux,xc,yc,detection_level,hfd_min, min_background                       : double;
   hfd_list                                                                                    : array of double;
   img_sa  : image_array;
var
  f   :  textfile;
var   {################# initialised variables #########################}
  len: integer=1000;
begin
  width5:=Length(img[0]);    {width}
  height5:=Length(img[0][0]); {height}

  max_stars:=500;
  SetLength(hfd_list,len);{set array length to len}

  get_background(0,img,true,true {calculate background and also star level end noise level},{var}backgr,star_level);
  detection_level:=max(3.5*noise_level[0],star_level); {level above background. Start with a high value}

  retries:=2; {try up to three times to get enough stars from the image}

  hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}

  if nrbits=8 then min_background:=0 else min_background:=8;
  if ((backgr<60000) and (backgr>min_background) ) then {not an abnormal file}
  begin
    repeat {try three time to find enough stars}
      star_counter:=0;

      if report then {write values to file}
      begin
        assignfile(f,ChangeFileExt(filename2,'.csv'));
        rewrite(f); {this could be done 3 times due to the repeat but it is the most simple code}
        writeln(f,'x,y,hfd,snr,flux');
      end;

      setlength(img_sa,1,width5,height5);{set length of image array}
      for fitsY:=0 to height5-1 do
        for fitsX:=0 to width5-1  do
          img_sa[0,fitsX,fitsY]:=-1;{mark as star free area}

      for fitsY:=0 to height5-1 do
      begin
        for fitsX:=0 to width5-1  do
        begin
          if (( img_sa[0,fitsX,fitsY]<=0){area not occupied by a star} and (img[0,fitsX,fitsY]-backgr>detection_level)) then {new star. For analyse used sigma is 5, so not too low.}
          begin
            HFD(img,fitsX,fitsY,14{annulus radius},99 {flux aperture restriction}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
            if ((hfd1<=30) and (snr>snr_min) and (hfd1>hfd_min) {two pixels minimum} ) then
            begin
              hfd_list[star_counter]:=hfd1;{store}
              inc(star_counter);
              if star_counter>=len then begin len:=len+1000; SetLength(hfd_list,len);{increase size} end;

              radius:=round(3.0*hfd1);{for marking star area. A value between 2.5*hfd and 3.5*hfd gives same performance. Note in practice a star PSF has larger wings then predicted by a Gaussian function}
              sqr_radius:=sqr(radius);
              xci:=round(xc);{star center as integer}
              yci:=round(yc);
              for n:=-radius to +radius do {mark the whole circular star area as occupied to prevent double detection's}
                for m:=-radius to +radius do
                begin
                  j:=n+yci;
                  i:=m+xci;
                  if ((j>=0) and (i>=0) and (j<height5) and (i<width5) and (sqr(m)+sqr(n)<=sqr_radius)) then
                    img_sa[0,i,j]:=1;
                end;

              if report then
              begin
                writeln(f,floattostr4(xc+1)+','+floattostr4(yc+1)+','+floattostr4(hfd1)+','+inttostr(round(snr))+','+inttostr(round(flux)) ); {+1 to convert 0... to FITS 1... coordinates}
              end;

            end;
          end;
        end;
      end;

      dec(retries);{In principle not required. Try again with lower detection level}
      if detection_level<=7*noise_level[0] then retries:= -1 {stop}
      else
      detection_level:=max(6.999*noise_level[0],min(30*noise_level[0],detection_level*6.999/30)); {very high -> 30 -> 7 -> stop.  Or  60 -> 14 -> 7.0. Or for very short exposures 3.5 -> stop}

      if report then closefile(f);

    until ((star_counter>=max_stars) or (retries<0));{reduce detection level till enough stars are found. Note that faint stars have less positional accuracy}

    if star_counter>0 then
      hfd_median:=SMedian(hfd_List,star_counter)
    else
      hfd_median:=99;
  end {backgr is normal}
  else
  hfd_median:=99;{Most common value image is too low. Ca'+#39+'t process this image. Check camera offset setting.}

  img_sa:=nil;{free mem}
end;

procedure analyse_image_extended(img : image_array;var nr_stars, hfd_median,median_center, median_outer_ring, median_bottom_left,median_bottom_right,median_top_left,median_top_right : double); {analyse several areas}
var
   width5,height5,fitsX,fitsY,radius,i, j, retries,max_stars,n,m,xci,yci,sqr_radius,
   nhfd,nhfd_center,nhfd_outer_ring,nhfd_top_left,nhfd_top_right,nhfd_bottom_left,nhfd_bottom_right : integer;
   hfd1,star_fwhm,snr,flux,xc,yc,backgr,detection_level                                             : double;
   img_sa                                                                                           : image_array;
   hfdlist, hfdlist_top_left,hfdlist_top_right,hfdlist_bottom_left,hfdlist_bottom_right,  hfdlist_center,hfdlist_outer_ring   :array of double;
var  {################# initialised variables #########################}
   len: integer=1000;

begin
  width5:=Length(img[0]);    {width}
  height5:=Length(img[0][0]); {height}

  max_stars:=500; //strtoint(stackmenu1.max_stars1.text);{maximum star to process, if so filter out brightest stars later}
  SetLength(hfdlist,len*4);{set array length on a starting value}

  SetLength(hfdlist_center,len);
  SetLength(hfdlist_outer_ring,len*2);

  SetLength(hfdlist_top_left,len);
  SetLength(hfdlist_top_right,len);
  SetLength(hfdlist_bottom_left,len);
  SetLength(hfdlist_bottom_right,len);

  setlength(img_sa,1,width5,height5);{set length of image array}

  get_background(0,img,true,true {calculate background and also star level end noise level},{var}backgr,star_level);

  detection_level:=max(3.5*noise_level[0],star_level); {level above background. Start with a high value}
  retries:=2; {try three times to get enough stars from the image}
  repeat
    nhfd:=0;{set counters at zero}
    nhfd_top_left:=0;
    nhfd_top_right:=0;
    nhfd_bottom_left:=0;
    nhfd_bottom_right:=0;
    nhfd_center:=0;
    nhfd_outer_ring:=0;

    if backgr>8 then
    begin
      for fitsY:=0 to height5-1 do
        for fitsX:=0 to width5-1  do
          img_sa[0,fitsX,fitsY]:=-1;{mark as star free area}

      for fitsY:=0 to height5-1 do
      begin
        for fitsX:=0 to width5-1  do
        begin
          if (( img_sa[0,fitsX,fitsY]<=0){area not occupied by a star} and (img[0,fitsX,fitsY]-backgr>detection_level){star}) then {new star. For analyse used sigma is 5, so not too low.}
          begin
            HFD(img,fitsX,fitsY,25 {LARGE annulus radius},99 {flux aperture restriction}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
            if ((hfd1<=35) and (snr>30) and (hfd1>0.8) {two pixels minimum} ) then
            begin
              {store values}
              hfdlist[nhfd]:=hfd1; inc(nhfd); if nhfd>=length(hfdlist) then SetLength(hfdlist,nhfd+500); {adapt length if required and store hfd value}

              if  sqr(xc - (width5 div 2) )+sqr(yc - (height5 div 2))<sqr(0.25)*(sqr(width5 div 2)+sqr(height5 div 2))  then begin hfdlist_center[nhfd_center]:=hfd1; inc(nhfd_center); if nhfd_center>=length( hfdlist_center) then  SetLength( hfdlist_center,nhfd_center+100);end {store center(<25% diameter) HFD values}
              else
              begin
                if  sqr(xc - (width5 div 2) )+sqr(yc - (height5 div 2))>sqr(0.75)*(sqr(width5 div 2)+sqr(height5 div 2)) then begin hfdlist_outer_ring[nhfd_outer_ring]:=hfd1; inc(nhfd_outer_ring); if nhfd_outer_ring>=length(hfdlist_outer_ring) then  SetLength(hfdlist_outer_ring,nhfd_outer_ring+100); end;{store out ring (>75% diameter) HFD values}

                if ( (xc<(width5 div 2)) and (yc<(height5 div 2)) ) then begin  hfdlist_bottom_left [nhfd_bottom_left] :=hfd1; inc(nhfd_bottom_left); if nhfd_bottom_left>=length(hfdlist_bottom_left)   then SetLength(hfdlist_bottom_left,nhfd_bottom_left+500);  end;{store corner HFD values}
                if ( (xc>(width5 div 2)) and (yc<(height5 div 2)) ) then begin  hfdlist_bottom_right[nhfd_bottom_right]:=hfd1; inc(nhfd_bottom_right);if nhfd_bottom_right>=length(hfdlist_bottom_right) then SetLength(hfdlist_bottom_right,nhfd_bottom_right+500);end;
                if ( (xc<(width5 div 2)) and (yc>(height5 div 2)) ) then begin  hfdlist_top_left[nhfd_top_left]:=hfd1;         inc(nhfd_top_left);    if nhfd_top_left>=length(hfdlist_top_left)         then SetLength(hfdlist_top_left,nhfd_top_left+500);        end;
                if ( (xc>(width5 div 2)) and (yc>(height5 div 2)) ) then begin  hfdlist_top_right[nhfd_top_right]:=hfd1;       inc(nhfd_top_right);   if nhfd_top_right>=length(hfdlist_top_right)       then SetLength(hfdlist_top_right,nhfd_top_right+500);      end;
              end;

              radius:=round(3.0*hfd1);{for marking star area. A value between 2.5*hfd and 3.5*hfd gives same performance. Note in practice a star PSF has larger wings then predicted by a Gaussian function}
              sqr_radius:=sqr(radius);
              xci:=round(xc);{star center as integer}
              yci:=round(yc);
              for n:=-radius to +radius do {mark the whole circular star area as occupied to prevent double detection's}
                for m:=-radius to +radius do
                begin
                  j:=n+yci;
                  i:=m+xci;
                  if ((j>=0) and (i>=0) and (j<height5) and (i<width5) and (sqr(m)+sqr(n)<=sqr_radius)) then
                    img_sa[0,i,j]:=1;
                end;

            end;
          end;
        end;
      end;

    end;

    dec(retries);{In principle not required. Try again with lower detection level}
    if detection_level<=7*noise_level[0] then retries:= -1 {stop}
    else
    detection_level:=max(6.999*noise_level[0],min(30*noise_level[0],detection_level*6.999/30)); {very high -> 30 -> 7 -> stop.  Or  60 -> 14 -> 7.0. Or for very short exposures 3.5 -> stop}

  until ((nhfd>=max_stars) or (retries<0));{reduce dection level till enough stars are found. Note that faint stars have less positional accuracy}

  nr_stars:=nhfd;
  if nhfd>0 then  hfd_median:=SMedian(hfdList,nhfd) else  hfd_median:=99;
  if nhfd_center>0 then median_center:=SMedian(hfdlist_center,nhfd_center) else median_center:=99;
  if nhfd_outer_ring>0 then  median_outer_ring:=SMedian(hfdlist_outer_ring,nhfd_outer_ring) else median_outer_ring:=99;
  if nhfd_bottom_left>0 then median_bottom_left:=SMedian(hfdlist_bottom_left,nhfd_bottom_left) else median_bottom_left:=99;
  if nhfd_bottom_right>0 then   median_bottom_right:=SMedian(hfdList_bottom_right,nhfd_bottom_right) else median_bottom_right:=99;
  if nhfd_top_left>0 then  median_top_left:=SMedian(hfdList_top_left,nhfd_top_left) else median_top_left:=99;
  if nhfd_top_right>0 then median_top_right:=SMedian(hfdList_top_right,nhfd_top_right) else median_top_right:=99;

  hfdlist:=nil;{release memory}
  hfdlist_center:=nil;
  hfdlist_outer_ring:=nil;
  hfdlist_top_left:=nil;
  hfdlist_top_right:=nil;
  hfdlist_bottom_left:=nil;
  hfdlist_bottom_right:=nil;

  img_sa:=nil;{free mem}
end;


procedure get_annotation_position;{find the position of the specified asteroid annotation}
var
  count1       : integer;
  x1,y1,x2,y2  : double;
  name    : string;
  List: TStrings;
begin
  List := TStringList.Create;
  list.StrictDelimiter:=true;
  name:=stackmenu1.ephemeris_centering1.text;{asteroid to center on}
  count1:=mainwindow.Memo1.Lines.Count-1;
  try
    while count1>=0 do {plot annotations}
    begin
      if copy(mainwindow.Memo1.Lines[count1],1,8)='ANNOTATE' then {found}
      begin
        List.Clear;
        ExtractStrings([';'], [], PChar(copy(mainwindow.Memo1.Lines[count1],12,80-12)),List);

        if list.count>=6  then {correct annotation}
        begin
          if list[5]=name then {correct name}
          begin
            x1:=strtofloat2(list[0]);{fits coordinates}
            y1:=strtofloat2(list[1]);
            x2:=strtofloat2(list[2]);
            y2:=strtofloat2(list[3]);
            listview_add_xy( (x1+x2)/2,(y1+y2)/2);{add center annotation to x,y for stacking}
          end;
        end;
      end;
      count1:=count1-1;
    end;
  finally
     List.Free;
  end;
end;


procedure analyse_tab_lights(full : boolean);
var
  c,hfd_counter  ,i,counts          : integer;
  backgr, hfd_median,alt            : double;
  Save_Cursor                       : TCursor;
  green,blue,success,planetary      : boolean;
  key,filename1,rawstr              : string;
  img                               : image_array;
begin
  with stackmenu1 do
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

    jd_sum:=0;{for sigma clip advanced average}
    planetary:=planetary_image1.checked;

    green:=false;
    blue:=false;

    c:=0;
    {convert any non FITS file}
    while c<=counts {check all} do
    begin
      if ListView1.Items.item[c].checked then
      begin
        filename1:=ListView1.items[c].caption;

        if fits_file_name(filename1)=false  {fits file name?}    then
        begin
          memo2_message('Converting '+filename1+' to FITS file format');
          Application.ProcessMessages;
          if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
          if convert_to_fits(filename1) {convert to fits} then
            ListView1.items[c].caption:=filename1 {change listview name to FITS.}
          else
          begin {failure}
            ListView1.Items.item[c].checked:=false;
            ListView1.Items.item[c].subitems.Strings[L_result]:='Conv failure!';
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
      if ((ListView1.Items.item[c].checked) and ((length(ListView1.Items.item[c].subitems.Strings[L_hfd])<=1){hfd} or (new_analyse_required)) ) then {hfd unknown, only update blank rows}
      begin {checked}
        if counts<>0 then progress_indicator(100*c/counts,' Analysing');
        Listview1.Selected :=nil; {remove any selection}
        ListView1.ItemIndex := c;{mark where we are, set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        Listview1.Items[c].MakeVisible(False);{scroll to selected item}

        filename2:=ListView1.items[c].caption;
        Application.ProcessMessages;
        if esc_pressed then begin Screen.Cursor :=Save_Cursor;  { back to normal }  exit;  end;


        if load_fits(filename2,true { update head_2.ra0..},true,false {update memo},0,head_2,img)=false then  {load in memory. Use head_2 to protect head against overwriting head}
        begin {failed to load}
          ListView1.Items.item[c].checked:=false;
          ListView1.Items.item[c].subitems.Strings[L_result]:='No FITS!';
        end
        else
        begin
          if pos('DARK',uppercase(imagetype))>0 then
          begin
            memo2_message('Move file '+filename2+' to tab DARKS');
            listview2.Items.beginupdate;
            listview_add(listview2,filename2,true,D_nr);{move to darks}
            listview2.Items.endupdate;
            listview1.Items.Delete(c);
            dec(c);{compensate for delete}
            dec(counts); {compensate for delete}
          end
          else
          if pos('FLAT',uppercase(imagetype))>0 then
          begin
            memo2_message('Move file '+filename2+' to tab FLATS');
            listview3.Items.beginupdate;
            listview_add(listview3,filename2,true,F_nr);
            listview3.Items.endupdate;
            listview1.Items.Delete(c);
            dec(c);{compensate for delete}
            dec(counts); {compensate for delete}
          end
          else
          if pos('BIAS',uppercase(imagetype))>0 then
          begin
            memo2_message('Move file '+filename2+' to tab FLAT-DARKS / BIAS');
            listview4.Items.beginupdate;
            listview_add(listview4,filename2,true,FD_nr);
            listview4.Items.endupdate;
            listview1.Items.Delete(c);
            dec(c);{compensate for delete}
            dec(counts); {compensate for delete}
          end
          else
          begin {light frame}
            if ((planetary=false) and (full=true))  then
              analyse_image(img,10 {snr_min},false,hfd_counter,backgr, hfd_median) {find background, number of stars, median HFD}
            else
              begin hfd_counter:=0; backgr:=0;star_level:=0; backgr:=0; hfd_median:=-1; end;

            ListView1.Items.BeginUpdate;
            try
              begin
                ListView1.Items.item[c].subitems.Strings[L_object]:=object_name; {object name, without spaces}


                ListView1.Items.item[c].subitems.Strings[L_filter]:=head_2.filter_name; {filter name, without spaces}
                if head_2.naxis3=3 then ListView1.Items.item[c].subitems.Strings[L_filter]:='colour'; {give RGB lights filter name colour}

                if AnsiCompareText(red_filter1.text,head_2.filter_name)=0 then  ListView1.Items.item[c].SubitemImages[L_filter]:=0 else
                if AnsiCompareText(red_filter2.text,head_2.filter_name)=0 then  ListView1.Items.item[c].SubitemImages[L_filter]:=0 else
                if AnsiCompareText(green_filter1.text,head_2.filter_name)=0 then begin ListView1.Items.item[c].SubitemImages[L_filter]:=1; green:=true; end else
                if AnsiCompareText(green_filter2.text,head_2.filter_name)=0 then begin ListView1.Items.item[c].SubitemImages[L_filter]:=1; green:=true; end else
                if AnsiCompareText(blue_filter1.text,head_2.filter_name)=0 then begin ListView1.Items.item[c].SubitemImages[L_filter]:=2; blue:=true; end else
                if AnsiCompareText(blue_filter2.text,head_2.filter_name)=0 then begin ListView1.Items.item[c].SubitemImages[L_filter]:=2; blue:=true; end else
                if AnsiCompareText(luminance_filter1.text,head_2.filter_name)=0 then  ListView1.Items.item[c].SubitemImages[L_filter]:=4 else
                if AnsiCompareText(luminance_filter2.text,head_2.filter_name)=0 then  ListView1.Items.item[c].SubitemImages[L_filter]:=4 else
                if head_2.naxis3=3 then  ListView1.Items.item[c].SubitemImages[L_filter]:=3 else {RGB color}
                  if head_2.filter_name<>'' then ListView1.Items.item[c].SubitemImages[L_filter]:=7 {question mark} else
                     ListView1.Items.item[c].SubitemImages[L_filter]:=-1;{blank}

                ListView1.Items.item[c].subitems.Strings[L_bin]:=floattostrf(Xbinning,ffgeneral,0,0)+' x '+floattostrf(Ybinning,ffgeneral,0,0); {Binning CCD}

                ListView1.Items.item[c].subitems.Strings[L_hfd]:=floattostrF(hfd_median,ffFixed,0,1);
                ListView1.Items.item[c].subitems.Strings[L_quality]:=inttostr5(round(hfd_counter/hfd_median)); {quality number of stars divided by hfd}

                if hfd_median>=99 then ListView1.Items.item[c].checked:=false {no stars, can't process this image}
                else
                begin {image can be futher analysed}
                  ListView1.Items.item[c].subitems.Strings[L_starlevel]:=inttostr5(round(star_level));
                  ListView1.Items.item[c].subitems.Strings[L_background]:=inttostr5(round(backgr));
                  ListView1.Items.item[c].subitems.Strings[L_sharpness]:=floattostrF(image_sharpness(img),ffFixed,0,3); {sharpness test}
                end;

                if head_2.exposure>=10 then  ListView1.Items.item[c].subitems.Strings[L_exposure]:=inttostr(round(head_2.exposure)) {round values above 10 seconds}
                                else  ListView1.Items.item[c].subitems.Strings[L_exposure]:=floattostrf(head_2.exposure,ffgeneral, 6, 6);

                if head_2.set_temperature<>999 then ListView1.Items.item[c].subitems.Strings[L_temperature]:=inttostr(head_2.set_temperature);
                ListView1.Items.item[c].subitems.Strings[L_width]:=inttostr(head_2.width); {width}
                ListView1.Items.item[c].subitems.Strings[L_height]:=inttostr(head_2.height);{height}

                if ((head_2.naxis3=1) and (Xbinning=1) and (bayerpat<>'')) then rawstr:=' raw' else rawstr:='';
                ListView1.Items.item[c].subitems.Strings[L_type]:=copy(imagetype,1,5)+inttostr(nrbits)+rawstr;{type}
                ListView1.Items.item[c].subitems.Strings[L_datetime]:=copy(StringReplace(head_2.date_obs,'T',' ',[]),1,23);{date/time up to ms}
                ListView1.Items.item[c].subitems.Strings[L_position]:=prepare_ra5(head_2.ra0,': ')+', '+ prepare_dec4(head_2.dec0,'° ');{give internal position}

                {is internal solution available?}
                if head_2.cd1_1<>0 then
                    ListView1.Items.item[c].subitems.Strings[L_solution]:='✓' else ListView1.Items.item[c].subitems.Strings[L_solution]:='-';

                ListView1.Items.item[c].subitems.Strings[L_calibration]:=head_2.calstat; {status calibration}
                if focus_pos<>0 then ListView1.Items.item[c].subitems.Strings[L_focpos]:=inttostr(focus_pos);
                if focus_temp<>999 then ListView1.Items.item[c].subitems.Strings[L_foctemp]:=floattostrF(focus_temp,ffFixed,0,1);

                if head_2.egain<>'' then ListView1.Items.item[c].subitems.Strings[L_gain]:=copy(head_2.egain,1,5) {e-/adu}
                else
                if head_2.gain<>'' then ListView1.Items.item[c].subitems.Strings[L_gain]:=head_2.gain;

                alt:=calculate_altitude(0 {can use header. Astrometric_to_apparent},head_2.ra0,head_2.dec0);{convert centalt string to double or calculate altitude from observer location}

                if alt<>0 then
                           ListView1.Items.item[c].subitems.Strings[L_centalt]:=floattostrf(alt,ffgeneral, 3, 1); {altitude}

                ListView1.Items.item[c].subitems.Strings[L_centaz]:=centaz;
                ListView1.Items.item[c].subitems.Strings[L_sqm]:=sqm_value;

                if use_ephemeris_alignment1.Checked then {ephemeride based stacking}
                   get_annotation_position;{fill the x,y with annotation position}
              end;
            finally
              ListView1.Items.EndUpdate;
            end;
          end;{end light frame}
        end;{this is a fits file}
      end;{checked and hfd unknown}
      inc(c); {go to next file}
    until c>counts;

    if ((green) and (blue) and (classify_filter1.checked=false)) then memo2_message('■■■■■■■■■■■■■ Hint, colour filters detected in light. For colour stack set the check-mark classify by Image filter! ■■■■■■■■■■■■■');

    if (stackmenu1.uncheck_outliers1.checked) then
    begin
      {give list an indentification key label based on object, filter and head_2.exposure time}
      for c:=0 to ListView1.items.count-1 do
      begin
        if ListView1.Items.item[c].SubitemImages[L_quality]=icon_thumb_down then {marked at outlier}
        begin
           ListView1.Items.item[c].checked:=true;{recheck outliers from previous session}
           ListView1.Items.item[c].SubitemImages[L_quality]:=-1;{remove mark}
        end;

         if ListView1.items[c].Checked=true then
             ListView1.Items.item[c].subitems.Strings[L_result]:=
                     ListView1.Items.item[c].subitems.Strings[L_object]+'_'+{object name}
                     ListView1.Items.item[c].subitems.Strings[L_filter]+'_'+{filter}
                     ListView1.Items.item[c].subitems.Strings[L_exposure]; {head_2.exposure}
      end;
      {do statistics on each constructed key}
      repeat
        c:=0;
        key:='';
        repeat {check all files, uncheck outliers}
          if  ListView1.Items.item[c].checked then
          begin
            key:=ListView1.Items.item[c].subitems.Strings[L_result];
            if key<>'' then
               list_remove_outliers(key);
          end;
          if esc_pressed then begin Screen.Cursor :=Save_Cursor;  { back to normal }  exit; end;
          inc(c)
        until c>counts;
      until key='';{until all keys are used}
    end;

    count_selected; {report the number of lights selected in images_selected and update menu indication}
    new_analyse_required:=false; {back to normal, head_2.filter_name is not changed, so no re-analyse required}
    img:=nil; {free mem}
    Screen.Cursor :=Save_Cursor;    { back to normal }
    progress_indicator(-100,'');{progresss done}
  end;
end;


procedure Tstackmenu1.Analyse1Click(Sender: TObject);
begin
  analyse_tab_lights(true {full});
end;


procedure Tstackmenu1.browse1Click(Sender: TObject);
var
   i: integer;
begin
  OpenDialog1.Title := 'Select lights to stack';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.filename:='';
  opendialog1.Filter :=dialog_filter;
  if opendialog1.execute then
  begin
    listview1.Items.beginUpdate;
    for i:=0 to OpenDialog1.Files.count-1 do
    begin
        listview_add(listview1,OpenDialog1.Files[i],   pos('_stacked',OpenDialog1.Files[i])=0 {do not check mark lights already stacked}   ,L_nr);
    end;
    listview1.Items.EndUpdate;
  end;
  count_selected; {report the number of lights selected in images_selected and update menu indication}
end;


procedure report_results(object_to_process,stack_info :string;object_counter,colorinfo:integer);{report on tab results}
begin
  {report result in results}
  with stackmenu1 do
  begin
    listview5_add(listview5,filename2 ,object_to_process,
                                       inttostr(object_counter)+'  ' {object counter}
                                      ,stack_info
                                      ,inttostr(head.width)
                                      ,inttostr(head.height)
                                      ,head.calstat);
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

    if pos1>1 then go_step_two1.enabled:=true;
    equalise_background_step:=pos1;
    undo_button_equalise_background1.enabled:=true;



    save_result1.Enabled:=false;
    remove_deepsky_label1.enabled:=false;
    most_common_filter_tool1.enabled:=false;
    most_common_mono1.enabled:=false;
    correct_gradient_label1.enabled:=false;
    apply_gaussian_filter1.enabled:=false;
    subtract_background1.enabled:=false;
    save_result1.Enabled:=false;
    save_as_new_file1.enabled:=false;

    case pos1 of
            1: begin save_as_new_file1.Enabled:=true; save_result1.Enabled:=true; remove_deepsky_label1.enabled:=true;undo_button_equalise_background1.caption:=''; end;{step 1,6}
            2: begin most_common_filter_tool1.enabled:=true;{step 3}most_common_mono1.enabled:=head.naxis3>1;{colour}remove_deepsky_label1.enabled:=true; undo_button_equalise_background1.caption:='1'; end;
            3: begin apply_gaussian_filter1.enabled:=true;{step 4}correct_gradient_label1.enabled:=true;undo_button_equalise_background1.caption:='3'; end;
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
  if pos('.fit',filename2)=0 then filename2:=changeFileExt(filename2,'.fits'); {rename png, XISF file to fits}
  if pos(' equalised',filename2)=0 then
  begin
    dot_pos:=length(filename2);
    repeat
      dec(dot_pos);
    until ((filename2[dot_pos]='.') or (dot_pos<=1));
    insert(' equalised',filename2,dot_pos);
  end;
  save_fits(img_loaded,filename2 ,-32, false);
  if fileexists(filename2) then
  begin
     saved1.caption:='Saved';
     report_results(object_name,'',0,-1{no icon});{report result in tab results}
  end
  else saved1.caption:='';
  if sender<>save_result1 then {<> step 6, save, step 1}
  begin
    update_equalise_background_step(equalise_background_step+1); {update menu}
  end
  else {save result, step 6}
  begin
    undo_button_equalise_background1.enabled:=false;
    undo_button_equalise_background1.caption:='';
    go_step_two1.enabled:=false;
  end;
end;


procedure Tstackmenu1.subtract_background1Click(Sender: TObject);
var fitsX, fitsY,col,col2,nrcolours :integer;
   Save_Cursor:TCursor;
begin
  if fits_file=false then exit;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  backup_img;


  if load_fits(filename2,true {light},true,true {update memo},0,head,img_temp) then {success load}
  begin
    nrcolours:=length(img_loaded)-1;{nr colours - 1}
    for col:=0 to head.naxis3-1 do {all colors}
    begin {subtract view from file}
      col2:=min(nrcolours,col); {allow subtracting mono lights from colour}
      for fitsY:=0 to head.height-1 do
        for fitsX:=0 to head.width-1 do
          img_temp[col,fitsX,fitsY]:=img_temp[col,fitsX,fitsY] - img_loaded[col2,fitsX,fitsY]+1000;  {use temp as temporary rather then img_loaded since img_loaded could be mono}
    end;

    img_loaded:=img_temp; {use result}

    use_histogram(img_loaded,true);
    plot_fits(mainwindow.image1,false,true);{plot real}
  end;
  update_equalise_background_step(5 {force 5 since equalise background is set to 1 by loading fits file} );{update menu}
  Screen.Cursor:=Save_Cursor;
end;


procedure Tstackmenu1.show_quads1Click(Sender: TObject);
var
   Save_Cursor:TCursor;
   hfd_min   : double;
   starlistquads : star_list;
begin
  if fits_file=false then application.messagebox( pchar('First load an image in the viewer!'), pchar('No action'),MB_OK)
  else
  begin
    Save_Cursor := Screen.Cursor;
    screen.Cursor := crHourglass;    { Show hourglass cursor }

    if  quads_displayed then
      plot_fits(mainwindow.image1,false,true); {remove quads}
    get_background(0,img_loaded,false{histogram already available},true {unknown, calculate also noise level} ,{var}cblack,star_level);

    if use_astrometry_internal1.checked then
    begin
      if head.cdelt2=0 {jpeg} then   head.cdelt2:=strtofloat2(search_fov1.text)/head.height;
      hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size1.text){arc sec}/(head.cdelt2 *3600) );{to ignore hot pixels which are too small}
    end
    else hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}

    find_stars(img_loaded,hfd_min,starlist1);{find stars and put them in a list}
    find_quads_xy(starlist1,starlistquads);{find quads}
    display_quads(starlistquads);
    quads_displayed:=true;
    starlistquads:=nil;{release memory}

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
var index: integer;
begin
  index:=tl.Items.Count-1;
  while index>=0 do
  begin
    if tl.Items[index].Selected then
      tl.Items.Delete(Index);
    dec(index); {go to next file}
  end;
end;


procedure Tstackmenu1.removeselected1Click(Sender: TObject);
begin
  if sender=removeselected1 then listview_removeselect(listview1);{from popup menu}
  if sender=removeselected2 then listview_removeselect(listview2);{from popup menu}
  if sender=removeselected3 then listview_removeselect(listview3);{from popup menu}
  if sender=removeselected4 then listview_removeselect(listview4);{from popup menu}
  if sender=removeselected5 then listview_removeselect(listview5);{from popup menu}
  if sender=removeselected6 then listview_removeselect(listview6);{from popup menu blink}
  if sender=removeselected7 then listview_removeselect(listview7);{from popup menu photometry}
  if sender=removeselected8 then listview_removeselect(listview8);{inspector}
  if sender=removeselected9 then listview_removeselect(listview9);{mount analyse}
end;


procedure Tstackmenu1.help_astrometric_alignment1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#astrometric_alignment');
end;


procedure Tstackmenu1.clear_image_list1Click(Sender: TObject);
begin
  ListView1.Clear;
  stackmenu1.ephemeris_centering1.clear;
end;


procedure Tstackmenu1.clear_dark_list1Click(Sender: TObject);
begin
  listview2.Clear
end;


procedure Tstackmenu1.FormCreate(Sender: TObject);
var
  RealFontSize : integer;
begin
  RealFontSize := abs(Round((GetFontData(stackmenu1.Font.Handle).Height * 72 / stackmenu1.Font.PixelsPerInch)));
  if realfontsize>11 then stackmenu1.font.size:=11;{limit fontsize}

{$ifdef mswindows}
{$else} {unix}
  copy_files_to_clipboard1.visible:=false;  {works only in Windows}
  copy_files_to_clipboard1.enabled:=false;
{$endif}
end;

procedure Tstackmenu1.FormKeyPress(Sender: TObject; var Key: char);
begin
   if key=#27 then
   begin
     esc_pressed:=true;
     memo2_message('ESC pressed. Execution stopped.');
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
   gaussian_blur2(img_loaded,2*strtofloat2(most_common_filter_radius1.text));
   plot_fits(mainwindow.image1,false,true);{plot}
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
      tl.Items[index].Checked:=true;
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
   if sender=select8 then listview_select(listview8);
   if sender=select9 then listview_select(listview9);
end;


procedure Tstackmenu1.browse_bias1Click(Sender: TObject);
var
   i: integer;
begin
  OpenDialog1.Title := 'Select flat dark (bias) images';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.filename:='';
  opendialog1.Filter :=dialog_filter;
  fits_file:=true;
  if opendialog1.execute then
  begin
    listview4.Items.beginupdate;
    for i:=0 to OpenDialog1.Files.count-1 do {add}
    begin
      listview_add(listview4,OpenDialog1.Files[i],true,FD_nr);
    end;
    listview4.Items.endupdate;
  end;
end;


procedure Tstackmenu1.browse_blink1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select images to add';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=dialog_filter;
  fits_file:=true;
  if opendialog1.execute then
  begin
    listview6.items.beginupdate;
    for i:=0 to OpenDialog1.Files.count-1 do {add}
      listview_add(listview6,OpenDialog1.Files[i],true,B_nr);
    listview6.items.endupdate;
  end;
end;


procedure Tstackmenu1.browse_flats1Click(Sender: TObject);
var
   i: integer;
begin
  OpenDialog1.Title := 'Select flat images';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.filename:='';
  opendialog1.Filter :=dialog_filter;
  fits_file:=true;
  if opendialog1.execute then
  begin
    listview3.items.beginupdate;
    for i:=0 to OpenDialog1.Files.count-1 do {add}
    begin
       listview_add(listview3,OpenDialog1.Files[i],true,F_nr);
    end;
    listview3.items.endupdate;

  end;
end;


function median_background(var img :image_array;color,sizeX,sizeY,x,y:integer): double;{find median value of an area at position x,y with sizeX,sizeY}
var i,j,count,size2,stepX,stepY  : integer;
    value                        : double;
    pixArray : array of double;
    w,h      : integer;
begin
  if (sizeX div 2)*2=sizeX then sizeX:=sizeX+1;{requires odd 3,5,7....}
  if (sizeY div 2)*2=sizeY then sizeY:=sizeY+1;{requires odd 3,5,7....}
  size2:=sizeX*sizeY;
  SetLength(pixArray,size2) ;
  stepX:=sizeX div 2;
  stepY:=sizeY div 2;
  count:=0;
  w:=Length(img[0]); {width}
  h:=Length(img[0,0]); {height}

  begin
    for j:=y-stepY to  y+stepY do
      for i:=x-stepX to x+stepX do
      begin
        if ((i>=0) and (i<w) and (j>=0) and (j<h) ) then {within the boundaries of the image array}
        begin
          value:=img[color,i ,j];
          if value<>0 then {ignore zero}
          begin
            pixArray[count]:=value;
            inc(count);
          end;
        end;
      end;
  end;

  //sort
  QuickSort(pixArray, Low(pixArray), count-1 { normally 8 for 3*3 equals High(intArray)}) ;
  result:=pixArray[count div 2];  {for 3x3 matrix the median is 5th element equals in range 0..8 equals intArray[4]}
  pixArray:=nil;
end;


procedure artificial_flatV1(var img :image_array; box_size  :integer);
 var
    fitsx,fitsy,i,j,col,step,
    colors,w,h                :integer;
    offset                   : single;
    bg                       : double;
    img_temp2                : image_array;
begin
  colors:=Length(img); {colors}
  w:=Length(img[0]); {width}
  h:=Length(img[0,0]); {height}

  {prepare img_temp2}
  setlength(img_temp2,colors,w,h);
  for col:=0 to colors-1 do {do all colours}
    for fitsY:=0 to h-1 do
      for fitsX:=0 to w-1 do
        img_temp2[col,fitsX,fitsY]:=0;

  if (box_size div 2)*2=box_size then box_size:=box_size+1;{requires odd 3,5,7....}
  step:=box_size div 2; {for 3*3 it is 1, for 5*5 it is 2...}

  {create artificial flat}
   for col:=0 to colors-1 do {do all colours}
   begin
     bg:=mode(img_loaded,col,round(0.2*head.width),round(0.8*head.width),round(0.2*head.height),round(0.8*head.height),32000) -bg; {mode finds most common value for the 60% center }
     for fitsY:=0 to h-1 do
       for fitsX:=0 to w-1 do
       begin
         img_temp2[col,fitsX,fitsY]:=0;

         if ((frac(fitsX/box_size)=0) and (frac(fitsy/box_size)=0)) then
         begin
           offset:=mode(img_loaded,col,fitsX-step,fitsX+step,fitsY-step,fitsY+step,32000) -bg; {mode finds most common value}
           if ((offset<0) {and (offset>-200)}) then
           begin
             for j:=fitsy-step to  fitsy+step do
               for i:=fitsx-step to fitsx+step do
                 if ((i>=0) and (i<w) and (j>=0) and (j<h) ) then {within the boundaries of the image array}
                   img_temp2[col,i,j]:=-offset;
           end;
         end;
       end;
   end;{all colors}

   {smooth flat}
   gaussian_blur2(img_temp2,box_size*2);

//   img_loaded:=img_temp2;
//   exit;

   {apply artificial flat}
   for col:=0 to colors-1 do {do all colours}
     for fitsY:=0 to h-1 do
       for fitsX:=0 to w-1 do
         img[col,fitsX,fitsY]:=img[col,fitsX,fitsY]+img_temp2[col,fitsX,fitsY];

   img_temp2:=nil;
 end;


procedure artificial_flatV2(var img :image_array; centrum_diameter:integer);
 var
    fitsx,fitsy,dist,col,centerX,centerY,
    colors,w,h,leng,angle,count,largest_distX,largest_distY   :integer;
    offset,oldoffset         : single;
    bg,sn,cs                 : double;
    median,test              : array of double;
begin
  colors:=Length(img); {colors}
  w:=Length(img[0]); {width}
  h:=Length(img[0,0]); {height}

    areax1:=startX;
  areay1:=startY;
  areax2:=stopX;
  areay2:=stopY;

  if pos('de',stackmenu1.center_position1.caption)>0 then {contains word default}
  begin
    centerX:=w div 2;
    centerY:=h div 2;
  end
  else
  begin
    centerX:=(areax1+areax2) div 2;
    centerY:=(areay1+areay2) div 2;
  end;


  centrum_diameter:=round(h*centrum_diameter/100);{transfer percentage to pixels}

  largest_distX:=max(centerX, w-centerX);
  largest_distY:=max(centerY, h-centerY);

  leng:=round(sqrt(sqr(largest_distX)+sqr(largest_distY)));
  setlength(median,leng+1);

  for col:=0 to colors-1 do {do all colours}
  begin
    get_background(col,img,true,false{do not calculate noise_level},bg,star_level); {should be about 500 for mosaic since that is the target value}
    oldoffset:=0;
    for dist:=leng downto 0 do
    begin
      if dist>centrum_diameter  then
      begin{outside centrum}
        setlength(test,360*3);
        count:=0;
        for angle:=0 to (356*3)-1 do
        begin
          sincos(angle*pi/(180*3),sn,cs);
          fitsy:=round(sn*dist) + (centerY);
          fitsx:=round(cs*dist) + (centerX);
          if ((fitsX<w) and (fitsX>=0) and (fitsY<h) and (fitsY>=0)) then {within the image}
          begin
            //memo2_message(inttostr(angle)+'    ' +floattostr(fitsX)+'     '+floattostr(fitsY) );
            offset:=img[col,fitsX,fitsY]-bg;

            if oldoffset<>0 then offset:=0.1*offset+0.9*oldoffset;{smoothing}
            oldoffset:=offset;

            test[count]:=img[col,fitsX,fitsY]-bg;
            inc(count,1);
          end;
        end;
        if count>5 then {at least five points}
        begin
          median[dist]:=smedian(test,count);
        end
        else
        median[dist]:=0;

 //       memo2_message(#9+ floattostr(dist)+#9+ floattostr(median[dist]) +#9+ inttostr(count));
      end {outside centrum}
      else
        median[dist]:=median[dist+1];
    end;


    for fitsY:=0 to h-1 do
    for fitsX:=0 to w-1 do
    begin
      dist:=round(sqrt(sqr(fitsX -  (centerX))+sqr(fitsY -  (centerY))));{distance from centre}
      if median[dist]<>0 then
      begin
        offset:=median[dist];
        img[col,fitsX,fitsY]:=img[col,fitsX,fitsY]-offset;
      end;

    end;
  end;{all colors}
  test:=nil;
  median:=nil;
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

     try box_size:=strtoint(dark_areas_box_size1.text);except end;

     memo2_message('Equalising background of '+filename2);
    {equalize background}

    if sender<>apply_artificial_flat_correctionV2 then
      artificial_flatV1(img_loaded, box_size)
    else
      artificial_flatV2(img_loaded, strtoint(StringReplace(ring_equalise_factor1.text,'%','',[])));

     plot_fits(mainwindow.image1,false,true);{plot real}
     Screen.Cursor:=Save_Cursor;
  end;
end;


procedure apply_factors;{apply r,g,b factors to image}
var fitsX, fitsY :integer;
    multiply_red,multiply_green,multiply_blue,add_valueR,add_valueG,add_valueB,largest,scaleR,scaleG,scaleB,dum :single;
    acceptzero :boolean;
begin
  acceptzero:=stackmenu1.ignorezero1.checked=false;

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
  if largest=0 then largest:=1; {prevent division by zero}
  {use largest to scale to maximum 65535}

  if ((multiply_red<>1) or (multiply_green<>1) or (multiply_blue<>1) or (add_valueR<>0) or (add_valueG<>0)or (add_valueB<>0)) then
  begin
    for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1 do
    begin
      dum:=img_loaded[0,fitsX,fitsY];
      if ((acceptzero) or (dum>0)) then {signal}
      begin
        dum:=(dum+add_valueR)*multiply_red/largest;
        if dum<0 then dum:=0; img_loaded[0,fitsX,fitsY]:=dum;
      end;

      if head.naxis3>1 then {colour}
      begin
        dum:=img_loaded[1,fitsX,fitsY];
        if ((acceptzero) or (dum>0)) then {signal}
        begin
          dum:=(dum+add_valueG)*multiply_green/largest;
          if dum<0 then dum:=0; img_loaded[1,fitsX,fitsY]:=dum;
        end;
      end;
      if head.naxis3>2 then {colour}
      begin
        dum:=img_loaded[2,fitsX,fitsY];
        if ((acceptzero) or (dum>0)) then {signal}
        begin
          dum:=(dum+add_valueB)*multiply_blue/largest;
          if dum<0 then dum:=0; img_loaded[2,fitsX,fitsY]:=dum;
        end;
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
   use_histogram(img_loaded,true);
   plot_fits(mainwindow.image1,false,true);{plot real}
   Screen.Cursor:=Save_Cursor;
  end;
end;


procedure Tstackmenu1.apply_file1Click(Sender: TObject);
var fitsX, fitsY, col               : integer;
   flat_norm_value,flat_factor      : single;
   idx,old_naxis3 : integer;
   Save_Cursor:TCursor;
begin
  if fits_file=true then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }
    backup_img; {move viewer data to img_backup}
    old_naxis3:=head.naxis3;

    idx:=add_substract1.itemindex;
    {add, multiply image}
    if length(image_to_add1.Caption)>3 then {file name available}
    begin
      if load_fits(image_to_add1.Caption,false {dark/flat},true {load data},true {update memo},0,head,img_temp) then {succes load}
      begin
        if ((idx=5) or (idx=6)) then {apply file as flat or multiply}
        begin

          flat_norm_value:=0;
          for fitsY:=-14 to 15 do {do even times, 30x30}
             for fitsX:=-14 to 15 do
               flat_norm_value:=flat_norm_value+img_temp[0,fitsX+(head.width div 2),fitsY +(head.height div 2)];
          flat_norm_value:=round(flat_norm_value/(30*30));

          for fitsY:=1 to head.height do
            for fitsX:=1 to head.width do
            begin
              for col:=0 to old_naxis3-1 do {do all colors. Viewer colours are stored in old_naxis3 by backup}
              begin
                if idx=5 then {as flat=divide}
                begin
                  flat_factor:=flat_norm_value/(img_temp[min(col,head.naxis3-1),fitsX-1,fitsY-1]+0.0001); {This works both for color and mono flats. Bias should be combined in flat}
                end
                else
                begin {multiply}
                  flat_factor:=img_temp[min(col,head.naxis3-1),fitsX-1,fitsY-1]/flat_norm_value; {This works both for color and mono flats. Bias should be combined in flat}
                end;
                img_loaded[col,fitsX-1,fitsY-1]:=img_loaded[col,fitsX-1,fitsY-1]*flat_factor ;
              end;
            end;
          head.naxis3:=old_naxis3;{could be changed by load file}
        end {apply file as flat}

        else
        for col:=0 to head.naxis3-1 do {all colors}
          for fitsY:=0 to head.height-1 do
            for fitsX:=0 to head.width-1 do
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
    use_histogram(img_loaded,true);
    plot_fits(mainwindow.image1,false,true);{plot real}
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
       edit_background1.Text:=floattostrf(min,ffgeneral, 4, 1); //floattostr6(min);

       for col:=0 to head.naxis3-1 do {all colors}
       for fitsY:=0 to head.height-1 do
          for fitsX:=0 to head.width-1 do
             img_loaded[col,fitsX,fitsY]:=img_loaded[col,fitsX,fitsY]-min; {subtract background}
     end
     else
     min:=strtofloat2(edit_background1.Text);

     if ddp_filter2.Checked then gaussian_blur2(img_loaded,strtofloat2(Edit_gaussian_blur1.text));

     for col:=0 to head.naxis3-1 do {all colors}
     for fitsY:=0 to head.height-1 do
        for fitsX:=0 to head.width-1 do
        begin
           bf:=(img_loaded[0,fitsX,fitsY] +a_factor);
           if bf<0.00001 then colr:=0 else
           begin
             colr:= k_factor*a_factor*(img_backup[index_backup].img[col,fitsX,fitsY]-min)/bf ;
             if colr>65535 then colr:=65535;
             if colr<0 then colr:=0;
           end;
           img_loaded[col,fitsX,fitsY]:=colr;
        end;
     apply_dpp_button1.Enabled:=false;
     use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
     plot_fits(mainwindow.image1,true,true);{plot real}

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
       most_common:=mode(sourc,k,x-radius,x+radius-1,y-radius,y+radius-1,32000);
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
  backup_img; {move copy to backup_img}

  try radius:=strtoint(stackmenu1.most_common_filter_radius1.text);except end;

  apply_most_common(img_backup[index_backup].img,img_loaded,radius); {apply most common filter on first array and place result in second array}

  plot_fits(mainwindow.image1,false,true);{plot real}
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
var index : integer;
begin
  index:=tl.Items.Count-1;
  while index>=0 do
  begin
    if  tl.Items[index].Selected then
    begin
      filename2:=tl.items[index].caption;
      deletefile(changeFileExt(filename2,'.bak'));{delete *.bak left over from astrometric solution}
      if RenameFile(filename2,ChangeFileExt(filename2,'.bak')) then
         tl.Items.Delete(Index);
    end;
    dec(index); {go to next file}
  end;
end;


procedure listview_update_keyword(tl : tlistview; keyw,value :string );{update key word of multiple files}
var index,counter,error2: integer;
    waarde              : double;
    filename_old        : string;
begin
  index:=0;
  esc_pressed:=false;
  counter:=tl.Items.Count;
  while index<counter do
  begin
    if  tl.Items[index].Selected then
    begin
      filename2:=tl.items[index].caption;
      filename_old:=filename2;
      if load_image(false,false {plot}) then {load}
      begin
        if filename_old<>filename2 then tl.items[index].caption:=filename2; {converted cr2 or other format when loaded. Update list with correct filename}
        while length(keyw)<8 do keyw:=keyw+' ';{increase length to 8}
        keyw:=copy(keyw,1,8);{decrease if longer then 8}

        if uppercase(value)='DELETE' then
          remove_key(keyw, true {all}){remove key word in header. If all=true then remove multiple of the same keyword}
        else
        begin
          val(value,waarde,error2); {test for number or text}
          if error2<>0 then {text, not a number}
          begin
            while length(value)<18 do value:=value+' ';{increase length to 18, one space will be added  in front later}
            update_text(keyw+'=',#39+value+#39+'                                                  ');
          end
          else
          update_float  (keyw+'=',' /                                                ' ,waarde);

          {update listview}
          if keyw='OBJECT  ' then
            if tl=stackmenu1.listview1 then tl.Items.item[index].subitems.Strings[L_object]:=value;
          if keyw='FILTER  ' then
          begin
            if tl=stackmenu1.listview1 then tl.Items.item[index].subitems.Strings[L_filter]:=value;{light}
            if tl=stackmenu1.listview3 then tl.Items.item[index].subitems.Strings[F_filter]:=value;{flat}
          end;

        end;

        if nrbits=16 then
        save_fits(img_loaded,filename2,16,true)
         else
        save_fits(img_loaded,filename2,-32,true);

        tl.ItemIndex := index;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        tl.Items[index].MakeVisible(False);{scroll to selected item}
        application.processmessages;
        if esc_pressed then exit;
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
  if sender=renametobak8 then listview_rename_bak(listview8);{from popupmenu inspector}
  if sender=renametobak9 then listview_rename_bak(listview9);{from popupmenu mount analyse}
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
//  fits_file:=true;
  if opendialog1.execute then
  begin
     image_to_add1.caption:=OpenDialog1.Files[0];
  end;
end;


procedure Tstackmenu1.FormResize(Sender: TObject);
var
   newtop : integer;
begin
  pagecontrol1.height:=classify_groupbox1.top;{make it High-DPI robust}

  newtop:=browse1.top + browse1.height+5;;

  listview1.top:=newtop;
  listview2.top:=newtop;
  listview3.top:=newtop;
  listview4.top:=newtop;
  listview5.top:=newtop;
  listview6.top:=newtop;
  listview7.top:=newtop;
  listview8.top:=newtop;

  memo2.top:=classify_groupbox1.top+ classify_groupbox1.height+4;{make it High-DPI robust}
  memo2.height:=stackmenu1.Height-memo2.top;{make it High-DPI robust}
end;


procedure Tstackmenu1.FormShow(Sender: TObject);
begin
  edit_background1.Text:='';
  stackmenu1.stack_method1Change(nil);{update dark pixel filter}

  stackmenu1.width_UpDown1.position:=round(head.width*strtofloat2(stackmenu1.resize_factor1.caption));
  stackmenu1.make_osc_color1Change(nil);{update glyph stack button}

  stackmenu1.listview1.columns.Items[l_centaz+1].caption:=centaz_key;   {lv.items[l_sqm].caption:=sqm_key; doesn't work}
  stackmenu1.listview1.columns.Items[l_sqm+1].caption:=sqm_key;   {lv.items[l_sqm].caption:=sqm_key; doesn't work}

  stackmenu1.flux_aperture1change(nil);{disable annulus_radius1 if mode max flux}

  hue_fuzziness1Change(nil);{show position}

  annotations_visible1.enabled:= mainwindow.annotations_visible1.checked;

  update_stackmenu;
end;


procedure Tstackmenu1.undo_button_equalise_background1Click(Sender: TObject);
begin
  if mainwindow.Undo1.enabled then
  begin
    if equalise_background_step=5 then
    begin {restart from step 1}
      if load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded) then{succes load}
      begin
        use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
        plot_fits(mainwindow.image1,false,true);{plot real}
        update_equalise_background_step(0); {go to step 0}
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
      tl.Items[index].Checked:=false;
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
  if sender=unselect7 then listview_unselect(listview7);
  if sender=unselect8 then listview_unselect(listview8);{inspector}
  if sender=unselect9 then listview_unselect(listview9);{inspector}
end;


procedure Tstackmenu1.unselect_area1Click(Sender: TObject);
begin
  area_set1.caption:='⍻'
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
   use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
   plot_fits(mainwindow.image1,false,true);{plot}
   Screen.cursor:=Save_Cursor;
end;


procedure Tstackmenu1.listview1ColumnClick(Sender: TObject; Column: TListColumn);
var c,thecount: integer;
    lc : array of boolean;

begin
  SortedColumn:= Column.Index;
end;


function CompareAnything(const s1, s2: string): Integer;
var a,b : double;
    s   : string;
    error1:integer;
begin
  s:=StringReplace(s1,',','.',[]); {replaces komma by dot}
  s:=trim(s); {remove spaces}
  val(s,a,error1);
  if error1=0 then
  begin
    s:=StringReplace(s2,',','.',[]); {replaces komma by dot}
    s:=trim(s); {remove spaces}
    val(s,b,error1);
  end;

  if error1=0 then {process as numerical values}
  begin
    if  a>b then result:=+1
    else
    if  a<b then result:=-1
    else
    result:=0;
  end
  else
    result:=CompareText(s1,s2);{compare as text}
end;


procedure Tstackmenu1.listview1Compare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);

var
   tem : boolean;
begin
  if SortedColumn = 0 then Compare := CompareText(Item1.Caption, Item2.Caption)
  else
  if SortedColumn <> 0 then Compare := CompareAnything(Item1.SubItems[SortedColumn-1], Item2.SubItems[SortedColumn-1]);
  if TListView(Sender).SortDirection = sdDescending then
       Compare := -Compare;

end;


procedure listview_view(tl : tlistview); {show image double clicked on}
var index      : integer;
    fitsX,fitsY: double;
    theext     : string;
begin
  for index:=0 to TL.Items.Count-1 do
  begin
    if TL.Items[index].Selected then
    begin
      filename2:=TL.items[index].caption;
      theext:=ExtractFileExt(filename2);
      if theext='.y4m' then begin memo2_message('Can not run videos'); exit; end;{video}
      if theext='.wcs' then filename2:=changefileext(filename2,'.fit');{for tab mount}
      if theext='.wcss' then filename2:=changefileext(filename2,'.fits');{for tab mount}

      if load_image(mainwindow.image1.visible=false,true {plot}) {for the first image set the width and length of image1 correct} then
      begin
        if ((tl=stackmenu1.listview1) and (stackmenu1.use_manual_alignment1.checked)) then {manual alignment}
          show_shape_manual_alignment(index){show the marker on the reference star}
        else
        mainwindow.shape_manual_alignment1.visible:=false;
      end
      else beep;{image not found}
      exit;{done, can display only one image}
    end;
  end;
end;


procedure Tstackmenu1.listview1DblClick(Sender: TObject);
begin
  listview_view(TListView(Sender));
  if ((checkBox_annotate1.checked) and (pagecontrol1.tabindex=8 {photometry} )) then
  begin
    load_variable; {Load the database once. If loaded no action}
    plot_deepsky;  {plot the variable annotations image}
  end;
end;


function date_obs_regional(thedate : string):string;{fits date but remote T and replace . by comma if that is the regional separator}
begin
  result:=StringReplace(thedate,'T',' ',[]);{date/time}
  if formatSettings.decimalseparator<>'.' then result:=StringReplace(result,'.',formatSettings.decimalseparator,[]); {replaces dot by komma}
end;


procedure analyse_listview(lv :tlistview; light,full, refresh: boolean);{analyse list of FITS files}
// amode=0 ==> reduced header only, keep original head.ra0, dec0 (for dark and flats
// amode=1 ==> full header only
// amode=2 ==> reduced header. load image, get background
// amode=3 ==> full header. load image  force reanalyse
// amode=4 ==> full header. load image
var
  c,counts,i,iterations, hfd_counter,theindex : integer;
  backgr, hfd_median, hjd,sd, dummy,alt,ra_image,dec_image : double;
  filename1                        : string;
  Save_Cursor                      : TCursor;
  loaded, green,blue               : boolean;
  img                              : image_array;

  nr_stars, hfd_center, hfd_outer_ring, hfd_bottom_left,hfd_bottom_right,hfd_top_left,hfd_top_right : double;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  esc_pressed:=false;

  if full=false then  lv.Items.BeginUpdate;{stop updating to prevent flickering till finished}

  counts:=lv.items.count-1;
  green:=false;
  blue:=false;

  loaded:=false;
  c:=0;

  {convert any non FITS file}
  while c<=counts {check all} do
  begin
    if lv.Items.item[c].checked then
    begin
      filename1:=lv.items[c].caption;
      if fits_file_name(filename1)=false  {fits file name?}    then
      begin
        memo2_message('Converting '+filename1+' to FITS file format');
        Application.ProcessMessages;
        if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
        if convert_to_fits(filename1) {convert to fits} then
          lv.items[c].caption:=filename1 {change listview name to FITS.}
        else
        begin {failure}
          lv.Items.item[c].checked:=false;
          lv.Items.item[c].subitems.Strings[L_result]:='Conv failure!';

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
    if ((lv.Items.item[c].checked) and ((refresh) or (length(lv.Items.item[c].subitems.Strings[4])<=1){height}) ) then {column empthy, only update blank rows}
    begin
      progress_indicator(100*c/lv.items.count-1,' Analysing');
      lv.Selected :=nil; {remove any selection}
      lv.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
      lv.Items[c].MakeVisible(False);{scroll to selected item}


      filename1:=lv.items[c].caption;
      Application.ProcessMessages; if esc_pressed then begin break;{leave loop}end;

      loaded:=load_fits(filename1,light {light or dark/flat},full {full fits},false {update memo},0,head_2,img); {for background or background+hfd+star}

      if loaded then
      begin {success loading header only}
        try
          begin
            if head_2.exposure>=10 then lv.Items.item[c].subitems.Strings[D_exposure]:=inttostr(round(head_2.exposure))
              else lv.Items.item[c].subitems.Strings[D_exposure]:=floattostrf(head_2.exposure,ffgeneral, 6, 6);

            lv.Items.item[c].subitems.Strings[D_temperature]:=inttostr(head_2.set_temperature);
            lv.Items.item[c].subitems.Strings[D_binning]:=floattostrf(Xbinning,ffgeneral,0,0)+' x '+floattostrf(Ybinning,ffgeneral,0,0); {Binning CCD}
            lv.Items.item[c].subitems.Strings[D_width]:=inttostr(head_2.width); {image width}
            lv.Items.item[c].subitems.Strings[D_height]:=inttostr(head_2.height);{image height}
            lv.Items.item[c].subitems.Strings[D_type]:=imagetype;{image type}

            if ((light=false) and (full=true)) {amode=2} then {dark/flats}
            begin {analyse background and noise}
              get_background(0,img,true {update_hist},false {calculate noise level}, {var} backgr,star_level);

              {analyse centre only. Suitable for flats and dark with amp glow}
              local_sd((head_2.width div 2)-50,(head_2.height div 2)-50, (head_2.width div 2)+50,(head_2.height div 2)+50{regio of interest},0,img, sd,dummy {mean},iterations);{calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}
               noise_level[0]:=round(sd);

              lv.Items.item[c].subitems.Strings[D_background]:=inttostr5(round(backgr));
              if ((lv.name=stackmenu1.listview2.name) or (lv.name=stackmenu1.listview3.name) or (lv.name=stackmenu1.listview4.name)) then
                     lv.Items.item[c].subitems.Strings[D_sigma]:=inttostr(noise_level[0]); {noise level}

              if head_2.egain<>'' then lv.Items.item[c].subitems.Strings[D_gain]:=copy(head_2.egain,1,5) {e-/adu}
              else
              if head_2.gain<>'' then lv.Items.item[c].subitems.Strings[D_gain]:=head_2.gain;
            end;

            if lv.name=stackmenu1.listview2.name then {dark tab}
            begin
              lv.Items.item[c].subitems.Strings[D_date]:=copy(head_2.date_obs,1,10);
              date_to_jd(head_2.date_obs,head_2.exposure);{convert head_2.date_obs string and head_2.exposure time to global variables jd_start (julian day start head_2.exposure) and jd_mid (julian day middle of the head_2.exposure)}
              lv.Items.item[c].subitems.Strings[D_jd]:=floattostrF(jd_start,ffFixed,0,1); {julian day, 1/10 day accuracy}
            end
            else
            if lv.name=stackmenu1.listview3.name then {flat tab}
            begin
              lv.Items.item[c].subitems.Strings[F_filter]:=head_2.filter_name; {filter name, without spaces}
              if AnsiCompareText(stackmenu1.red_filter1.text,head_2.filter_name)=0 then  Lv.Items.item[c].SubitemImages[F_filter]:=0 else
              if AnsiCompareText(stackmenu1.red_filter2.text,head_2.filter_name)=0 then  Lv.Items.item[c].SubitemImages[F_filter]:=0 else
              if AnsiCompareText(stackmenu1.green_filter1.text,head_2.filter_name)=0 then begin lv.Items.item[c].SubitemImages[F_filter]:=1; green:=true; end else
              if AnsiCompareText(stackmenu1.green_filter2.text,head_2.filter_name)=0 then begin lv.Items.item[c].SubitemImages[F_filter]:=1; green:=true; end else
              if AnsiCompareText(stackmenu1.blue_filter1.text,head_2.filter_name)=0 then begin lv.Items.item[c].SubitemImages[F_filter]:=2; blue:=true; end else
              if AnsiCompareText(stackmenu1.blue_filter2.text,head_2.filter_name)=0 then begin lv.Items.item[c].SubitemImages[F_filter]:=2; blue:=true; end else
              if AnsiCompareText(stackmenu1.luminance_filter1.text,head_2.filter_name)=0 then  lv.Items.item[c].SubitemImages[F_filter]:=4 else
              if AnsiCompareText(stackmenu1.luminance_filter2.text,head_2.filter_name)=0 then  lv.Items.item[c].SubitemImages[F_filter]:=4 else
              if head_2.naxis3=3 then  lv.Items.item[c].SubitemImages[F_filter]:=3 else {RGB color}
                 if head_2.filter_name<>'' then lv.Items.item[c].SubitemImages[F_filter]:=7 {question mark} else
                    lv.Items.item[c].SubitemImages[F_filter]:=-1;{blank}

              lv.Items.item[c].subitems.Strings[D_date]:=copy(head_2.date_obs,1,10);
              date_to_jd(head_2.date_obs,head_2.exposure);{convert head_2.date_obs string and head_2.exposure time to global variables jd_start (julian day start head_2.exposure) and jd_mid (julian day middle of the head_2.exposure)}
              lv.Items.item[c].subitems.Strings[F_jd]:=floattostrF(jd_start,ffFixed,0,1); {julian day, 1/10 day accuracy}
              lv.Items.item[c].subitems.Strings[F_calibration]:=head_2.calstat;
            end
            else
            if lv.name=stackmenu1.listview4.name then {flat darks tab}
            begin
              lv.Items.item[c].subitems.Strings[D_date]:=copy(head_2.date_obs,1,10);
            end
            else
            if lv.name=stackmenu1.listview6.name then {blink tab}
            begin
              lv.Items.item[c].subitems.Strings[B_date]:=StringReplace(copy(head_2.date_obs,1,19),'T',' ',[]);{date/time for blink. Remove fractions of seconds}
              lv.Items.item[c].subitems.Strings[B_calibration]:=head_2.calstat; {calibration head_2.calstat info DFB}
              if annotated then lv.Items.item[c].subitems.Strings[B_annotated ]:='✓' else  lv.Items.item[c].subitems.Strings[B_annotated ]:='';
            end
            else

            if lv.name=stackmenu1.listview7.name then {photometry tab}
            begin
              lv.Items.item[c].subitems.Strings[P_date]:=StringReplace(copy(head_2.date_obs,1,19),'T',' ',[]);{date/time for blink. Remove fractions of seconds}
              lv.Items.item[c].subitems.Strings[P_filter]:=head_2.filter_name;
              date_to_jd(head_2.date_obs,head_2.exposure);{convert head_2.date_obs string and head_2.exposure time to global variables jd_start (julian day start head_2.exposure) and jd_mid (julian day middle of the head_2.exposure)}
              lv.Items.item[c].subitems.Strings[P_jd_mid]:=floattostrF(jd_mid,ffFixed,0,5);{julian day}

              hjd:=JD_to_HJD(jd_mid,head_2.ra0,head_2.dec0);{conversion JD to HJD}
              lv.Items.item[c].subitems.Strings[P_jd_helio]:=floattostrF(Hjd,ffFixed,0,5);{helio julian day}

              alt:=calculate_altitude(0 {can use header CENT_ALT. Astrometric_to_apparent},head_2.ra0,head_2.dec0);{convert centalt string to double or calculate altitude from observer location}
              if alt<>0 then
              begin
                lv.Items.item[c].subitems.Strings[P_centalt]:=floattostrf(alt,ffFixed, 0, 1); {altitude}
                lv.Items.item[c].subitems.Strings[P_airmass]:=floattostrf(AirMass_calc(alt),ffFixed, 0,3); {airmass}
              end;

              {magn is column 9 will be added separately}
              {solution is column 12 will be added separately}
              if head_2.calstat<>'' then lv.Items.item[c].subitems.Strings[P_calibration]:=head_2.calstat
                 else lv.Items.item[c].subitems.Strings[P_calibration]:='None'; {calibration head_2.calstat info DFB}

              if head_2.cd1_1=0 then lv.Items.item[c].subitems.Strings[P_astrometric]:=''
                 else lv.Items.item[c].subitems.Strings[P_astrometric]:='✓';

              if full {amode=3} then {listview7 photometry plus mode}
              begin

                analyse_image(img,10 {snr_min},false,hfd_counter,backgr, hfd_median); {find background, number of stars, median HFD}
                lv.Items.item[c].subitems.Strings[P_background]:=inttostr5(round(backgr));
                lv.Items.item[c].subitems.Strings[P_hfd]:=floattostrF(hfd_median,ffFixed,0,1);
                lv.Items.item[c].subitems.Strings[P_stars]:=inttostr5(hfd_counter); {number of stars}
              end;
            end
            else

            if lv.name=stackmenu1.listview8.name  then {listview8 inspector tab}
            begin
              lv.Items.item[c].subitems.Strings[insp_focus_pos]:=inttostr(focus_pos);

              analyse_image_extended(img, nr_stars, hfd_median,hfd_center, hfd_outer_ring, hfd_bottom_left,hfd_bottom_right,hfd_top_left,hfd_top_right); {analyse several areas}

              if ((hfd_median>25) or (hfd_center>25) or (hfd_outer_ring>25) or (hfd_bottom_left>25) or (hfd_bottom_right>25) or (hfd_top_left>25) or (hfd_top_right>25)) then
              begin
                lv.Items.item[c].checked:=false; {uncheck}
                lv.Items.item[c].subitems.Strings[insp_nr_stars]:='❌'    ;
              end
              else
              lv.Items.item[c].subitems.Strings[insp_nr_stars]:=floattostrF(nr_stars,ffFixed,0,0);

              lv.Items.item[c].subitems.Strings[insp_nr_stars+2]:=floattostrF(hfd_median,ffFixed,0,3);
              lv.Items.item[c].subitems.Strings[insp_nr_stars+3]:=floattostrF(hfd_center,ffFixed,0,3);
              lv.Items.item[c].subitems.Strings[insp_nr_stars+4]:=floattostrF(hfd_outer_ring,ffFixed,0,3);
              lv.Items.item[c].subitems.Strings[insp_nr_stars+5]:=floattostrF(hfd_bottom_left,ffFixed,0,3);
              lv.Items.item[c].subitems.Strings[insp_nr_stars+6]:=floattostrF(hfd_bottom_right,ffFixed,0,3);
              lv.Items.item[c].subitems.Strings[insp_nr_stars+7]:=floattostrF(hfd_top_left,ffFixed,0,3);
              lv.Items.item[c].subitems.Strings[insp_nr_stars+8]:=floattostrF(hfd_top_right,ffFixed,0,3);
            end
            else

            if lv.name=stackmenu1.listview9.name then {mount analyse tab}
            begin
              lv.Items.item[c].subitems.Strings[M_date]:=date_obs_regional(head_2.date_obs);
              date_to_jd(head_2.date_obs,head_2.exposure);{convert head_2.date_obs string and head_2.exposure time to global variables jd_start (julian day start head_2.exposure) and jd_mid (julian day middle of the head_2.exposure)}

              //http://www.bbastrodesigns.com/coordErrors.html  Gives same value within a fraction of arcsec.
              //2020-1-1, JD=2458850.50000, RA,DEC position 12:00:00, 40:00:00, precession +00:01:01.45, -00:06:40.8, Nutation -00:00:01.1,  +00:00:06.6, Annual aberration +00:00:00.29, -00:00:14.3
              //2020-1-1, JD=2458850.50000  RA,DEC position 06:00:00, 40:00:00, precession +00:01:23.92, -00:00:01.2, Nutation -00:00:01.38, -00:00:01.7, Annual aberration +00:00:01.79, +00:00:01.0
              //2030-6-1, JD=2462654.50000  RA,DEC position 06:00:00, 40:00:00, precession +00:02:07.63, -00°00'02.8",Nutation +00:00:01.32, -0°00'02.5", Annual aberration -00:00:01.65, +00°00'01.10"

              //jd:=2458850.5000;
              //head_2.ra0:=pi;
              //head_2.dec0:=40*pi/180;

              //head_2.ra0:=41.054063*pi/180;
              //head_2.dec0:=49.22775*pi/180;
              //jd:=2462088.69;

              //head_2.ra0:=353.22987757000*pi/180;
              //head_2.dec0:=+52.27730247000*pi/180;
              //jd:=2452877.026888400;

              //head_2.ra0:=(14+34/60+16.4960283/3600)*pi/12;  {sofa example}
              //head_2.dec0:=-(12+31/60+02.523786/3600)*pi/180;
              //jd:=2456385.46875;


              lv.Items.item[c].subitems.Strings[M_jd_mid]:=floattostrF(jd_mid,ffFixed,0,7);{julian day}

              theindex:=stackmenu1.equinox1.itemindex;
              if ra_mount<99 then {mount position known and specified}
              begin
                if theindex>=1 then
                  precession3(2451545 {J2000}, jd_mid,ra_mount,dec_mount); {precession}
                if stackmenu1.hours_and_minutes1.checked then
                begin
                  lv.Items.item[c].subitems.Strings[M_ra_m]:=prepare_ra8(ra_mount,':'); {radialen to text, format 24: 00 00.00 }
                  lv.Items.item[c].subitems.Strings[M_dec_m]:=prepare_dec2(dec_mount,':');{radialen to text, format 90d 00 00.1}
                end
                else
                begin
                  lv.Items.item[c].subitems.Strings[M_ra_m]:=floattostrf(ra_mount*180/pi,ffFixed, 9, 6);
                  lv.Items.item[c].subitems.Strings[M_dec_m]:=floattostrf(dec_mount*180/pi,ffFixed, 9, 6);
                  end;
              end;

              if head_2.cd1_1<>0 then
              begin
                ra_image:=head_2.ra0;{J2000 apparent from image solution}
                dec_image:=head_2.dec0;
                if theindex=1 then
                begin
                  alt:=calculate_altitude(3 {no refraction correction},head_2.ra0,head_2.dec0);{convert centalt string to double or calculate altitude from observer location}
                  ra_image:=ra_mean;{precession was applied by calculate altitude routine}
                  dec_image:=dec_mean;
                end;
                if theindex=2 then
                begin
                  alt:=calculate_altitude(4 {apparent to astrometric !!!!},head_2.ra0,head_2.dec0);{convert centalt string to double or calculate altitude from observer location}
                  ra_image:=ra_mean;{precession was applied by calculate altitude routine}
                  dec_image:=dec_mean;
                end;
                if alt<>0 then
                  lv.Items.item[c].subitems.Strings[M_centalt]:=floattostrf(alt,ffFixed, 3, 1); {altitude}

                if stackmenu1.hours_and_minutes1.checked then
                begin
                  lv.Items.item[c].subitems.Strings[M_ra]:=prepare_ra8(ra_image,':'); {radialen to text, format 24: 00 00.00 }
                  lv.Items.item[c].subitems.Strings[M_dec]:=prepare_dec2(dec_image,':');{radialen to text, format 90d 00 00.1}
                end
                else
                begin
                  lv.Items.item[c].subitems.Strings[M_ra]:=floattostrf(ra_image*180/pi,ffFixed, 9, 6);
                  lv.Items.item[c].subitems.Strings[M_dec]:=floattostrf(dec_image*180/pi,ffFixed, 9, 6);
                end;

                if ra_mount<99 then {mount position known and specified}
                begin
                  lv.Items.item[c].subitems.Strings[M_ra_e]:=floattostrf((ra_image-ra_mount)*cos(dec_image)*3600*180/pi,ffFixed, 6,1);
                  lv.Items.item[c].subitems.Strings[M_dec_e]:=floattostrf((dec_image-dec_mount)*3600*180/pi,ffFixed, 6,1);
                end
                else
                begin
                 lv.Items.item[c].subitems.Strings[M_ra_e]:='?';
                 lv.Items.item[c].subitems.Strings[M_dec_e]:='?';
                end;

                if focus_temp<>999 then Lv.Items.item[c].subitems.Strings[M_foctemp]:=floattostrF(focus_temp,ffFixed,0,1);

              end;

            end;
          end;
        finally
        end;
      end
      else
      begin
        lv.Items.item[c].checked:=false; {can't analyse this one}
        memo2_message('Error reading '+filename1);
      end;
    end;{hfd unknown}
  end;

  if ((green) and (blue) and (stackmenu1.classify_flat_filter1.checked=false)) then memo2_message('■■■■■■■■■■■■■ Hint, colour filters detected in the flat. For colour stacking set the check-mark classify by Flat Filter! ■■■■■■■■■■■■■');

  if full=false then lv.Items.EndUpdate;{can update now}
  progress_indicator(-100,'');{progresss done}
  img:= nil;

  Screen.Cursor :=Save_Cursor;{back to normal }
end;


procedure average(mess:string; file_list : array of string; file_count:integer; var img2: image_array);{combine to average or mean, make also mono from three colors if color}
var                                                   {this routine works with mono files but makes coloured files mono, so less suitable for commercial cameras producing coloured raw lights}
   Save_Cursor:TCursor;
   c,fitsX, fitsY : integer;
   img_tmp1 :image_array;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  {average}
  for c:=0 to file_count-1 do
  begin
    memo2_message('Adding '+mess+' image '+inttostr(c+1)+ ' to '+mess+' average. '+file_list[c]);

    {load image}
    Application.ProcessMessages;
    if ((esc_pressed) or (load_fits(file_list[c],false {light},true,true {update memo},0,head,img_tmp1)=false))then  begin Screen.Cursor := Save_Cursor;  exit;end;

    if c=0 then {init}
    begin
      setlength(img2,1,head.width,head.height);{set length of image array mono}
      for fitsY:=0 to head.height-1 do
        for fitsX:=0 to head.width-1 do
         img2[0,fitsX,fitsY]:=0; {clear img}
    end;

    if head.naxis3=3 then  {for the rare case the darks are coloured. Should normally be not the case since it expects raw mono FITS files without bayer matrix applied !!}
    begin {color average}
      for fitsY:=0 to head.height-1 do
         for fitsX:=0 to head.width-1 do
           img2[0,fitsX,fitsY]:=img2[0,fitsX,fitsY]+(img_tmp1[0,fitsX,fitsY]+img_tmp1[1,fitsX,fitsY]+img_tmp1[2,fitsX,fitsY])/3;{fill with image}
    end
    else
    begin {mono average}
      for fitsY:=0 to head.height-1 do
         for fitsX:=0 to head.width-1 do
           img2[0,fitsX,fitsY]:=img2[0,fitsX,fitsY]+img_tmp1[0,fitsX,fitsY];{fill with image}

    end;
  end;{open files}

 if file_count>1 then {not required for single/master files}
  For fitsY:=0 to head.height-1 do
     for fitsX:=0 to head.width-1 do
       img2[0,fitsX,fitsY]:=img2[0,fitsX,fitsY]/file_count;{scale to one image}

  img_tmp1:=nil;{free mem}
  Screen.Cursor := Save_Cursor;  { Always restore to normal }
end;


function average_flatdarks(exposure:double): integer;
var
  c,file_count : integer;
  file_list    : array of string;
begin
  analyse_listview(stackmenu1.listview4,false {light},false {full fits},false{refesh});{update the tab information, convert to FITS if required}
  setlength(file_list,stackmenu1.listview4.items.count);
  file_count:=0;
  result:=0;{just in case no flat-dark are found}
  for c:=0 to stackmenu1.listview4.items.count-1 do
    if stackmenu1.listview4.items[c].checked=true then
    begin
      if ((exposure<0){disabled} or (abs(strtofloat(stackmenu1.listview4.Items.item[c].subitems.Strings[FD_exposure])-exposure)<0.01)) then
      begin
        file_list[file_count]:=stackmenu1.ListView4.items[c].caption;
        inc(file_count);
      end;
    end;
  if file_count<>0 then
  begin
    memo2_message('Averaging flat dark frames.');
    average('flat-dark',file_list,file_count,img_bias);{only average}
    result:=head.width; {width of the flat-dark}
  end;
  head.flatdark_count:=file_count;
  file_list:=nil;
end;



procedure box_blur(colors,range: integer;var img: image_array);{combine values of pixels, ignore zeros}
var fitsX,fitsY,k,x1,y1,col,w,h,i,j,counter,minimum,maximum : integer;
   img_temp2 : image_array;
   value, value2 : single;
begin
  col:=length(img);{the real number of colours}
  h:=length(img[0,0]);{height}
  w:=length(img[0]);{width}

  if range=2 then begin minimum:=0 ; maximum:=+1; end {combine values of 4 pixels}
  else
  if range=3 then begin minimum:=-1; maximum:=+1; end {combine values of 9 pixels}
  else
  if range=4 then begin minimum:=-1; maximum:=+2; end {combine values of 16 pixels}
  else
                  begin minimum:=-2; maximum:=+2; end; {combine values of 25 pixels}

  setlength(img_temp2,col,w,h);{set length of image array}
  for k:=0 to col-1 do
  begin
    for fitsY:=0 to h-1 do
      for fitsX:=0 to w-1 do
      begin
        value:=0;
        counter:=0;
        for i:=minimum to maximum do
        for j:=minimum to maximum do
        begin
          x1:=fitsX+i;
          y1:=fitsY+j;
          if ((x1>=0) and (x1<=w-1) and (y1>=0) and (y1<=h-1)) then
          begin
            value2:=img[k,x1,  y1];
            if value2<>0 then begin value:=value+value2; inc(counter);end;{ignore zeros}
          end;
        end;
        if counter<>0 then img_temp2[k,fitsX,fitsY]:=value/counter else img_temp2[k,fitsX,fitsY]:=0;
      end;
  end;{k}

  if ((colors=1){request} and (col=3){actual})  then {rare, need to make mono, copy back to img}
  begin
  for fitsY:=0 to h-1 do
    for fitsX:=0 to w-1 do
    for k:=0 to col-1 do
     img[0,fitsx,fitsy]:=(img_temp2[0,fitsx,fitsy]+img_temp2[1,fitsx,fitsy]+img_temp2[2,fitsx,fitsy])/3;
  end
  else
  img:=img_temp2;{move pointer array}

  head.naxis3:=colors;{the final result}
  img_temp2:=nil;
end;


procedure normalize_OSC_flat(var img: image_array); {normalize bayer pattern. Colour shifts due to not using a white light source for the flat frames are avoided.}
var
  fitsX,fitsY,col,h,w,counter1,counter2, counter3,counter4 : integer;
  value1,value2,value3,value4,maxval : double;
  oddx, oddy :boolean;
begin
  col:=length(img);{the real number of colours}
  h:=length(img[0,0]);{height}
  w:=length(img[0]);{width}

  if col>1 then
  begin
    memo2_message('Skipping normalise filter. This filter works only for raw OSC images!');
    exit;
  end
  else
    memo2_message('Normalising '+filename2);


  value1:=0; value2:=0; value3:=0; value4:=0;
  counter1:=0; counter2:=0; counter3:=0; counter4:=0;

  for fitsY:=(h div 4) to (h*3) div 4 do {use one quarter of the image to find factors. Works also a little better if no dark-flat is subtracted. It also wokrs better if boarder is black}
    for fitsX:=(w div 4) to (w*3) div 4 do
    begin
      oddX:=odd(fitsX);
      oddY:=odd(fitsY);
      if ((oddX=false) and (oddY=false)) then begin value1:=value1+img[0,fitsX,fitsY]; inc(counter1) end else {separate counters for case odd() dimensions are used}
      if ((oddX=true)  and (oddY=false)) then begin value2:=value2+img[0,fitsX,fitsY]; inc(counter2) end else
      if ((oddX=false) and (oddY=true))  then begin value3:=value3+img[0,fitsX,fitsY]; inc(counter3) end else
      if ((oddX=true)  and (oddY=true))  then begin value4:=value4+img[0,fitsX,fitsY]; inc(counter4) end;
    end;

  {now normalise the bayer pattern pixels}
  value1:=value1/counter1;
  value2:=value2/counter2;
  value3:=value3/counter3;
  value4:=value4/counter4;
  maxval:=max(max(value1,value2),max(value3,value4));
  value1:=maxval/value1;
  value2:=maxval/value2;
  value3:=maxval/value3;
  value4:=maxval/value4;

  for fitsY:=0 to h-1 do
    for fitsX:=0 to w-1 do
    begin
      oddX:=odd(fitsX);
      oddY:=odd(fitsY);
      if ((value1<>1) and (oddX=false) and (oddY=false)) then img[0,fitsX,fitsY]:=round(img[0,fitsX,fitsY]*value1) else
      if ((value2<>1) and (oddX=true)  and (oddY=false)) then img[0,fitsX,fitsY]:=round(img[0,fitsX,fitsY]*value2) else
      if ((value3<>1) and (oddX=false) and (oddY=true))  then img[0,fitsX,fitsY]:=round(img[0,fitsX,fitsY]*value3) else
      if ((value4<>1) and (oddX=true)  and (oddY=true))  then img[0,fitsX,fitsY]:=round(img[0,fitsX,fitsY]*value4);
    end;
end;


procedure black_spot_filter(var img: image_array);{remove black spots with value zero} {execution time about 0.4 sec}
var fitsX,fitsY,k,x1,y1,col,w,h,i,j,counter,range,left,right,bottom,top : integer;
   img_temp2 : image_array;
   value, value2 : single;
   black : boolean;
begin
  col:=length(img);{the real number of colours}
  h:=length(img[0,0]);{height}
  w:=length(img[0]);{width}

  {find the black borders.}
  left:=-1;
  repeat
    inc(left);
    black:=( (img[0,left, h div 2]=0) or ((col>=1) and (img[1,left, h div 2]=0)) or  ((col>=2) and (img[2,left, h div 2]=0)))
  until ((black=false) or (left>=w-1));

  right:=w;
  repeat
    dec(right);
    black:=( (img[0,right, h div 2]=0) or ((col>=1) and (img[1,right, h div 2]=0)) or  ((col>=2) and (img[2,right, h div 2]=0)))
  until ((black=false) or (right<=0));

  bottom:=-1;
  repeat
    inc(bottom);
    black:=( (img[0,w div 2, bottom]=0) or ((col>=1) and (img[1,w div 2,bottom]=0)) or  ((col>=2) and (img[2,w div 2,bottom]=0)))
  until ((black=false) or (bottom>=h-1));

  top:=h;
  repeat
    dec(top);
    black:=( (img[0,w div 2,top]=0) or ((col>=1) and (img[1,w div 2,top]=0)) or  ((col>=2) and (img[2,w div 2,top]=0)))
  until ((black=false) or (top<=0));


  range:=1;
  setlength(img_temp2,col,w,h);{set length of image array}
  for k:=0 to col-1 do
  begin
    for fitsY:=0 to h-1 do
      for fitsX:=0 to w-1 do
      begin
        value:=img[k,fitsX, fitsY];
        if value<=0 then {black spot or or -99999 saturation marker}
        if ((fitsX>=left) and (fitsX<=right) and (fitsY>=bottom) and (fitsY<=top)) then {not the incomplete borders}
        begin
          range:=1;
          repeat
            counter:=0;
            for i:=-range to range do
            for j:=-range to range do
            begin
              if ((abs(i)=range) or (abs(j)=range)) then {square search range}
              begin
                x1:=fitsX+i;
                y1:=fitsY+j;
                if ((fitsX>=left) and (fitsX<=right) and (fitsY>=bottom) and (fitsY<=top)) then {not the incomplete borders}
                begin
                  value2:=img[k,x1,  y1];
                  if value2>0 then begin value:=value+value2; inc(counter);end;{ignore zeros or -99999 saturation markers}
                end;
              end;
            end;
            if counter<>0 then
                        value:=value/counter
            else
            inc(range);
          until ((counter<>0) or (range>=100));{try till 100 pixels away}
        end;
        img_temp2[k,fitsX,fitsY]:=value;
      end;
  end;{k}

  img:=img_temp2;{move pointer array}
  img_temp2:=nil;
end;


procedure Tstackmenu1.analyseflatsButton3Click(Sender: TObject);
begin
  analyse_listview(listview3,false {light},true {full fits},new_analyse_required3{refresh});
  new_analyse_required3:=false;{analyse done}
end;

procedure Tstackmenu1.analyseflatdarksButton1Click(Sender: TObject);
begin
  analyse_listview(listview4,false {light},sender<>nil {true=full fits},false{refresh});
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
  if sender=changekeyword6 then lv:=listview6;{from popup menu}
  if sender=changekeyword7 then lv:=listview7;{from popup menu}
  if sender=changekeyword8 then lv:=listview8;{from popup menu}
  if sender=changekeyword9 then lv:=listview9;{from popup menu}

  keyw:=InputBox('All selected files will be updated!! Hit cancel to abort. Type keyword:','','' );
  if length(keyw)<2 then exit;

  value:=InputBox('New value keyword (Type DELETE to remove keyword):','','' );
  if length(value)<=0 then exit;
    listview_update_keyword(lv,uppercase(keyw),value);{update key word}
end;


procedure Tstackmenu1.dark_spot_filter1Click(Sender: TObject);
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

     for k:=0 to head.naxis3-1 do {do all colors}
     begin

       for fitsY:=0 to (head.height-1) {div 5} do
       begin
         if frac(fitsY/100)=0 then
         begin
           Application.ProcessMessages;
           if esc_pressed then  begin  Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
           progress_value:=round(100*(fitsY)/(((k+1)/head.naxis3)*(head.height)));
           progress_indicator(progress_value,'');{report progress}
         end;
         for fitsX:=0 to (head.width-1) {div 5} do
         begin
           if ((frac(fitsx/10)=0) and (frac(fitsY/10)=0)) then
           begin
             most_common:=mode(img_backup[index_backup].img,k,fitsX-radius,fitsX+radius-1,fitsY-radius,fitsY+radius-1,32000);
             neg_noise_level:=get_negative_noise_level(img_backup[index_backup].img,k,fitsX-radius,fitsX+radius,fitsY-radius,fitsY+radius,most_common);{find the most common value of a local area and calculate negative noise level}
             for i:=-radius to +radius-1 do
                  for j:=-radius to +radius-1 do
                  begin
                    x2:=fitsX+i;
                    y2:=fitsY+j;
                    if ((x2>=0) and (x2<head.width) and (y2>=0) and (y2<head.height))  then
                      if img_loaded[k,x2,y2]<bg then {below global most common level}
                        if img_loaded[k,x2,y2]<most_common-neg_noise_level then {local dark spot}
                          img_loaded[k,x2,y2]:=most_common-neg_noise_level;
                  end;
           end;{/3}
         end;
       end;
     end;{k color}
     plot_fits(mainwindow.image1,false,true);{plot real}
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
  if ((x_trunc<0) or (x_trunc>(head.width-2)) or (y_trunc<0) or (y_trunc>(head.height-2))) then begin result:=0; exit;end;
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
//    for col:=0 to head.naxis3-1 do {all colors}
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

procedure resize_img_loaded(ratio :double); {resize img_loaded in free ratio}
var
  img_temp2                : image_array;
  FitsX, fitsY,k,w,h,w2,h2 : integer;
  x,y                      : double;

begin
  w2:=round(ratio*head.width);
  h2:=round(ratio*head.height);

  repeat
    w:=max(w2,round(head.width/2));  {reduce in steps of two maximum to preserve stars}
    h:=max(h2,round(head.height/2));  {reduce in steps of two maximum to preserve stars}

    setlength(img_temp2,head.naxis3,w,h);;
    for k:=0 to head.naxis3-1 do
      for fitsY:=0 to h-1 do
        for fitsX:=0 to w-1  do
        begin
          X:=(fitsX*head.width/w);
          Y:=(fitsY*head.height/h);
          img_temp2[k,fitsX,fitsY]:=value_sub_pixel(k,x,y);
        end;
    img_loaded:=img_temp2;
    head.width:=w;
    head.height:=h;
  until ((w<=w2) and (h<=h2)); {continue till required size is reeached}

  img_temp2:=nil;

  update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);


  if head.cdelt1<>0 then begin head.cdelt1:=head.cdelt1/ratio; update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,head.cdelt1);end;
  if head.cdelt2<>0 then begin head.cdelt2:=head.cdelt2/ratio; update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,head.cdelt2);end;

  if head.cd1_1<>0 then
  begin
    head.crpix1:=head.crpix1*ratio; update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,head.crpix1);
    head.crpix2:=head.crpix2*ratio; update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,head.crpix2);
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
  add_text   ('HISTORY   ','Image resized with factor '+ floattostr6(ratio));
end;


procedure Tstackmenu1.free_resize_fits1Click(Sender: TObject);{free resize FITS image}
var
  Save_Cursor:TCursor;
begin
  if fits_file=false then exit;
  Save_Cursor := Screen.Cursor;
  backup_img;
  resize_img_loaded(width_UpDown1.position/head.width {ratio});

  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,true,true);{plot}
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
  if ((head.width<>100) or (head.height<>100)) then {is image loaded?,  assigned(img_loaded) doesn't work for jpegs}
    mainwindow.astrometric_solve_image1Click(nil)
  else
  memo2_message('Abort solve, no image in the viewer.');
end;


procedure Tstackmenu1.splitRGB1Click(Sender: TObject);
var
   fitsx, fitsY : integer;
   filename1,memo2_text: string;
begin
  if ((fits_file=false) or (head.naxis3<>3)) then begin memo2_message('Not a three colour image!');  exit;end;

  memo2_text:=mainwindow.Memo1.Text;{save fits header first FITS file}

  filename1:=ChangeFileExt(FileName2,'.fit');{make it lowercase fit also if FTS or FIT}

  setlength(img_buffer,1,head.width,head.height);{create a new mono image}

  for fitsY:=0 to head.height-1 do
  for fitsX:=0 to head.width-1 do
         img_buffer[0,fitsX,fitsY]:=img_loaded[0,fitsX,fitsY];
  filename2:=StringReplace(filename1,'.fit','_red.fit',[]);{give new file name }
  update_text   ('FILTER  =',#39+'Red     '+#39+'           / Filter name                                    ');
  save_fits(img_buffer,filename2,-32,false);{fits header will be updated in save routine}

  for fitsY:=0 to head.height-1 do
  for fitsX:=0 to head.width-1 do
  img_buffer[0,fitsX,fitsY]:=img_loaded[1,fitsX,fitsY];
  filename2:=StringReplace(filename1,'.fit','_green.fit',[]);{give new file name }
  update_text   ('FILTER  =',#39+'Green   '+#39+'           / Filter name                                    ');
  save_fits(img_buffer,filename2,-32,false);{fits header will be updated in save routine}

  for fitsY:=0 to head.height-1 do
  for fitsX:=0 to head.width-1 do
  img_buffer[0,fitsX,fitsY]:=img_loaded[2,fitsX,fitsY];
  filename2:=StringReplace(filename1,'.fit','_blue.fit',[]);{give new file name }
  update_text   ('FILTER  =',#39+'Blue    '+#39+'           / Filter name                                    ');
  save_fits(img_buffer,filename2,-32,false);{fits header will be updated in save routine}

  img_buffer:=nil;{release memory}

  {restore old situation}
  mainwindow.Memo1.Text:= memo2_text;{restore fits header}
  filename2:=filename1;
end;


procedure Tstackmenu1.analysedarksButton2Click(Sender: TObject);
begin
  analyse_listview(listview2,false {light},true {full fits},false{refresh}); {img_loaded array and memo1 will not be modified}
end;


procedure Tstackmenu1.resize_factor1Change(Sender: TObject);
var
   factor: double;
begin
  factor:=strtofloat2(resize_factor1.text);
  Edit_width1.text:=inttostr(round(head.width*factor));
end;


procedure Tstackmenu1.Edit_width1Change(Sender: TObject);
begin
  new_height1.caption:=inttostr(round(width_UpDown1.position*head.height/head.width));
end;


procedure Tstackmenu1.flux_aperture1change(Sender: TObject);
begin
  annulus_radius1.enabled:=flux_aperture1.itemindex<>0;{disable annulus_radius1 if mode max flux}

  {recalibrate}
  if flux_magn_offset<>0 then
  begin
    memo2_message('Flux calibration cleared. Recalibrate by ctrl-U. See viewer tool menu');
    flux_magn_offset:=0;
  end;
end;


procedure Tstackmenu1.help_astrometric_solving1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#alignment_menu');
end;


procedure Tstackmenu1.listview1CustomDraw(Sender: TCustomListView; const ARect: TRect; var DefaultDraw: Boolean);
begin
  stackmenu1.nr_total1.caption:=inttostr(ListView1.items.count);{update counting info}
end;


procedure Tstackmenu1.listview1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if stackmenu1.use_manual_alignment1.checked then
  begin
    if length(sender.Items.item[Item.Index].subitems.Strings[L_X])>1 then {manual position added, colour it}
       Sender.Canvas.Font.Color := clGreen
       else
       Sender.Canvas.Font.Color := clred;
  end
  else
  begin
    Sender.Canvas.Font.Color := clmenutext;{required for high contrast settings. Otherwise it is always black}
  end;
 {$ifdef mswindows}
 {$else} {unix}
 {temporary fix for CustomDraw not called}
 if Item.index=0 then  stackmenu1.nr_total1.caption:=inttostr(sender.items.count);{update counting info}
 {$endif}
end;


procedure Tstackmenu1.listview2CustomDraw(Sender: TCustomListView; const ARect: TRect; var DefaultDraw: Boolean);
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

procedure Tstackmenu1.listview3CustomDraw(Sender: TCustomListView; const ARect: TRect; var DefaultDraw: Boolean);
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

procedure Tstackmenu1.listview4CustomDraw(Sender: TCustomListView; const ARect: TRect; var DefaultDraw: Boolean);
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

procedure Tstackmenu1.listview6CustomDraw(Sender: TCustomListView; const ARect: TRect; var DefaultDraw: Boolean);
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
    mainwindow.demosaic_bayermatrix1Click(nil);{including back and wait cursor}
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
  Save_Cursor          : TCursor;
  hfd_min              : double;
  c, x_new,y_new,fitsX,fitsY,col,first_image,stepnr,nrrows, cycle,step,ps: integer;
  reference_done, init{,solut},astro_solved,store_annotated           : boolean;
  st                                                                  : string;
begin
  if listview6.items.count<=1 then exit; {no files}
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  save_settings2;{too many lost selected files . so first save settings}

  if listview6.Items.item[listview6.items.count-1].subitems.Strings[B_width]='' {width} then
    stackmenu1.analyseblink1Click(nil);

  hfd_min:=max(0.8 {two pixels},strtofloat2(stackmenu1.min_star_size_stacking1.caption){hfd});{to ignore hot pixels which are too small}

  mainwindow.image1.Canvas.brush.Style:=bsClear;
  mainwindow.image1.canvas.font.color:=$00B0FF ;{orange}

  esc_pressed:=false;
  first_image:=-1;
  cycle:=0;
  if sender=blink_button_contB1 then step:=-1 else step:=1;{forward/ backwards}

  nrrows:=listview6.items.count;
  setlength(bsolutions,nrrows);{for the solutions in memory. bsolutions is destroyed in formdestroy}

  stepnr:=0;
  if ((sender=blink_button1) or (solve_and_annotate1.checked) or (sender=write_video1) or (sender=nil){export aligned}) then init:=true {start at beginning for video}
    else init:=false;{start at selection}
  reference_done:=false;{ check if reference image is loaded. Could be after first image if abort was given}
  repeat
    stepnr:=stepnr+1; {first step is nr 1}

    if init=false then c:=listview_find_selection(listview6) {find the row selected}
    else
    begin
      if step>0 then c:=0 {forward}
      else
      c:=nrrows-1;{backwards}

    end;
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
        if load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded)=false then begin esc_pressed:=true; break;end;

        use_histogram(img_loaded,true {update}); {plot histogram, set sliders}

        if first_image=c then inc(cycle);
        if cycle>=2 then stackmenu1.update_annotation1.checked:=false;{reset any request to update fits header annotations}

        if solve_and_annotate1.checked then
        begin
          astro_solved:=false;{assume failure}
          if head.cd1_1=0 then {get astrometric solution}
          begin
            listview6.Selected :=nil; {remove any selection}
            listview6.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
            listview6.Items[c].MakeVisible(False);{scroll to selected item}
            memo2_message(filename2+ ' Adding astrometric solution to files.');

            if solve_image(img_loaded,true  {get hist}) then
            begin{match between loaded image and star database}
              astro_solved:=true;{saving will be done later}
              memo2_message(filename2+ ' astrometric solved.');
            end
            else
              memo2_message(filename2+ 'No astrometric solution found for this file.');
          end;

          if head.cd1_1<>0 then
          begin
            if ((annotated=false) or (stackmenu1.update_annotation1.checked)) then
            begin
               plot_mpcorb(strtoint(maxcount_asteroid),strtofloat2(maxmag_asteroid),true {add annotations});
               listview6.Items.item[c].subitems.Strings[B_annotated ]:='✓';
            end;
            if ((astro_solved) or (stackmenu1.update_annotation1.checked)) then
               if savefits_update_header(filename2)=false then begin ShowMessage('Write error !!' + filename2);Screen.Cursor := Save_Cursor; exit;end;{save solution and annotation}
          end;
        end;{astrometric solve and annotate}

        {find align solution}
        if align_blink1.checked then
        begin
          st:=listview6.Items.item[c].subitems.Strings[B_solution];
          if st='' then {no solution yet}
          begin
            if reference_done=false then {get reference}
            begin
              memo2_message('Working on star alignment solutions. Blink frequency will increase after completion.');
              get_background(0,img_loaded,false {no histogram already done},true {unknown, calculate also datamax}, {var} cblack,star_level);
              find_stars(img_loaded,hfd_min,starlist1);{find stars and put them in a list}
              find_quads(starlist1,0,quad_smallest,quad_star_distances1);{find quads for reference image}

              reset_solution_vectors(1);{no influence on the first image since reference}

              {store solutions in memory}
              bsolutions[c].solution_vectorX:=solution_vectorX;
              bsolutions[c].solution_vectorY:=solution_vectorY;
              listview6.Items.item[c].subitems.Strings[B_solution]:='✓ '+inttostr(c);{store location in listview for case list is sorted/modified}
              ListView6.Items.item[c].SubitemImages[B_solution]:=icon_king; {mark as best quality image}
              reference_done:=true;
            end
            else
            begin
              mainwindow.caption:=filename2+' Working on star solutions, be patient.';
              get_background(0,img_loaded,false {no histogram already done} ,true {unknown, calculate also noise_level} , {var} cblack,star_level);
              find_stars(img_loaded,hfd_min,starlist2);{find stars and put them in a list}
              find_quads(starlist2,0,quad_smallest,quad_star_distances2);{find star quads for new image}
              if find_offset_and_rotation(3,strtofloat2(stackmenu1.quad_tolerance1.text)) then {find difference between ref image and new image}
              begin
                bsolutions[c].solution_vectorX:=solution_vectorX;
                bsolutions[c].solution_vectorY:=solution_vectorY;
                listview6.Items.item[c].subitems.Strings[B_solution]:='✓ '+inttostr(c);{store location in listview for case list is sorted/modified}
                ListView6.Items.item[c].SubitemImages[B_solution]:=-1; {{remove any older icon_king}

                memo2_message(inttostr(nr_references)+' of '+ inttostr(nr_references2)+' quads selected matching within '+stackmenu1.quad_tolerance1.text+' tolerance.'
                   +'  Solution x:='+floattostr6(solution_vectorX[0])+'*x+ '+floattostr6(solution_vectorX[1])+'*y+ '+floattostr6(solution_vectorX[2])
                   +',  y:='+floattostr6(solution_vectorY[0])+'*x+ '+floattostr6(solution_vectorY[1])+'*y+ '+floattostr6(solution_vectorY[2]) );
              end
              else
              begin
                memo2_message('Not enough quad matches <3 or inconsistent solution, skipping this image.');
                reset_solution_vectors(1);{default for no solution}
              end;
            end;
          end
          {end find solution}
          else
          begin {reuse solution}
                ps:=strtoint(copy(st,4,10));
                solution_vectorX:=bsolutions[ps].solution_vectorX; {restore solution}
                solution_vectorY:=bsolutions[ps].solution_vectorY;
          end;

          if ((head.naxis3=1) and (mainwindow.preview_demosaic1.checked)) then
          begin
            demosaic_advanced(img_loaded);{demosaic and set levels}
          end;

          setlength(img_temp,head.naxis3,0,0);{set to zero to clear old values (at the edges}
          setlength(img_temp,head.naxis3,head.width,head.height);{new size}


          for fitsY:=0 to head.height-1 do
          for fitsX:=0 to head.width-1  do
          begin
            x_new:=round(solution_vectorX[0]*(fitsx)+solution_vectorX[1]*(fitsY)+solution_vectorX[2]); {correction x:=aX+bY+c}
            y_new:=round(solution_vectorY[0]*(fitsx)+solution_vectorY[1]*(fitsY)+solution_vectorY[2]); {correction y:=aX+bY+c}

            if ((x_new>=0) and (x_new<=head.width-1) and (y_new>=0) and (y_new<=head.height-1)) then
            for col:=0 to head.naxis3-1 do {all colors}
                                img_temp[col,x_new,y_new]:=img_loaded[col,fitsX,fitsY] ;

          end;

          img_loaded:=img_temp;
        end{star align}
        else {un-aligned blink}
        begin
          {nothing to do}
        end;

        if timestamp1.checked then
        begin
          if date_avg='' then
            annotation_to_array('date_obs: '+head.date_obs,false,65535,1{size},1,10,img_loaded) {head.date_obs to image array as font. Flicker free method}
          else
          annotation_to_array('date_avg: '+date_avg,false,65535,1{size},1,10,img_loaded);{head.date_obs to image array as font}
        end;

        store_annotated:=annotated;{store temporary annotated}
        annotated:=false;{prevent annotations are plotted in plot_fits}
        plot_fits(mainwindow.image1,false {re_center},true);
        annotated:=store_annotated;{restore anotated value}
        if ((annotated) and (mainwindow.annotations_visible1.checked)) then
        plot_annotations(true {use solution vectors!!!!},false); {corrected annotations in case a part of the lights are flipped in the alignment routien}

        if sender=write_video1 then {write video frame}
        begin
          if write_yuv4mpeg2_frame(head.naxis3>1)=false then
          begin
             memo2_message('Error writing video'); ;
             c:=999999; {stop}
          end;
        end;
      end;
      inc(c,step);
    until ((c>=nrrows) or (c<0));

  until ((esc_pressed) or (sender=blink_button1 {single run}) or (sender=write_video1) or (sender=nil){export aligned});

  img_temp:=nil;{free memory}
  Screen.Cursor :=Save_Cursor;{back to normal }
end;


procedure Tstackmenu1.create_test_image_stars1Click(Sender: TObject);
var
   i,j,m,n, stepsize,stepsize2, starcounter,subsampling  : integer;
   sigma,hole_radius,donut_radius,hfd_diameter,shiftX,shiftY,flux,flux_star,diam    : double;
   gradient,diagn_star           : boolean;
begin

  mainwindow.memo1.visible:=false;{stop visualising memo1 for speed. Will be activated in plot routine}
  mainwindow.memo1.clear;{clear memo for new header}

  reset_fits_global_variables(true,head);

  nrbits:=16;
  extend_type:=0; {no extensions in the file, 1 is ascii_table, 2 bintable}

  head.height:=1800;
  head.width:=1800*3 div 2;{aspect ratio 3:2}

  Randomize; {initialise}

  head.datamin_org:=1000;{for case histogram is not called}
  head.datamax_org:=65535;
  cblack:=head.datamin_org;{for case histogram is not called}
  cwhite:=head.datamax_org;

  gradient:=stackmenu1.artificial_image_gradient1.checked;

  sigma:=strtofloat2(stackmenu1.hfd_simulation1.text)/2.5;{gaussian shaped star, sigma is HFD/2.5, in perfect world it should be /2.354 but sigma 1 will be measured with current alogorithm as 2.5}

  starcounter:=0;

  {star test image}
  head.naxis3:=1; {head.naxis3 number of colors}
  filename2:='star_test_image.fit';
  for j:=0 to 10 do {create an header with fixed sequence}
    if (j<>5)  then {skip head.naxis3 for mono images}
        mainwindow.memo1.lines.add(head1[j]); {add lines to empthy memo1}
  mainwindow.memo1.lines.add(head1[27]); {add end}

  update_integer('BITPIX  =',' / Bits per entry                                 ' ,nrbits);
  update_integer('NAXIS1  =',' / length of x axis                               ' ,head.width);
  update_integer('NAXIS2  =',' / length of y axis                               ' ,head.height);
  if head.naxis3=1 then  remove_key('NAXIS3  ',false{all});{remove key word in header. Some program don't like naxis3=1}
  update_integer('DATAMIN =',' / Minimum data value                             ' ,0);
  update_integer('DATAMAX =',' / Maximum data value                             ' ,round(head.datamax_org));
  add_text   ('COMMENT 1','  Written by Astrometric Stacking Program. www.hnsky.org');

  add_text   ('COMMENT A','  Artificial image, background has value 1000 with sigma 100 Gaussian noise');
  add_text   ('COMMENT B','  Top rows contain hotpixels with value 65535');
  add_text   ('COMMENT C','  Rows below have Gaussian stars with a sigma of '+floattostr6(sigma));
  add_text   ('COMMENT D','  Which will be measured as HFD '+stackmenu1.hfd_simulation1.text);
  add_text   ('COMMENT E','  Note that theoretical Gaussian stars with a sigma of 1 are');
  add_text   ('COMMENT F','  equivalent to a HFD of 2.354 if subsampled enough.');
  add_text   ('COMMENT  ',' ,Star_nr, X, Y, Flux                               ');


  setlength(img_loaded,head.naxis3,head.width,head.height);{set length of image array}

  For i:=0 to head.height-1 do
  for j:=0 to head.width-1 do
  begin
    if gradient=false then img_loaded[0,j,i]:=randg(1000,100 {noise}){default background is 1000}
    else
    img_loaded[0,j,i]:=-500*sqrt( sqr((i-head.height/2)/head.height) +sqr((j-head.width/2)/head.height) ){circular gradient}
                       + randg(1000,100 {noise}){default background is 100}
  end;

  stepsize:=round(sigma*3);
  if stepsize<8 then stepsize:=8;{minimum value}
  subsampling:=5;
  For i:=stepsize to head.height-1-stepsize do
  for j:=stepsize to head.width-1-stepsize do
  begin
     if ( (frac(i/100)=0) and (frac(j/100)=0) )  then {reduce star density if HFD increases}
    begin
      if i>head.height-300 then {hot pixels} img_loaded[0,j,i]:=65535 {hot pixel}
      else {create real stars}
      begin
        shiftX:=-0.5+random(1000)/1000; {result between -0.5 and +0.5}
        shiftY:=-0.5+random(1000)/1000; {result between -0.5 and +0.5}
        flux_star:=0;
        diagn_star:=false;
        inc(starcounter);
        if sigma*2.5<=5 then {gaussian stars}
        begin
          stepsize2:=stepsize*subsampling;
          for m:=-stepsize2 to stepsize2 do for n:=-stepsize2 to stepsize2 do
          begin
            flux:=(65000/power(starcounter,0.85)){Intensity}*(1/sqr(subsampling)* exp(-0.5/sqr(sigma)*(sqr(m/subsampling)+sqr(n/subsampling))));
            flux_star:=flux_star+flux;
            img_loaded[0,j+round(shiftX+n/subsampling),i+round(shiftY+m/subsampling)]:= img_loaded[0,j+round(shiftX+n/subsampling),i+round(shiftY+m/subsampling)]+flux ; {gaussian shaped stars}
            if frac(starcounter/20)=0 then
            begin
               img_loaded[0,180+starcounter+round(shiftX+n/subsampling),130+starcounter+round(shiftY+m/subsampling)]:=img_loaded[0,180+starcounter+round(shiftX+n/subsampling),130+starcounter+round(shiftY+m/subsampling)]+flux; {diagonal gaussian shaped stars}
               diagn_star:=true;
            end;
          end;
        end
        else
        begin  {donut stars}
          for m:=-stepsize to stepsize do for n:=-stepsize to stepsize do
          begin
            hfd_diameter:=sigma*2.5;
            hole_radius:=trunc(hfd_diameter/3);{Half outer donut diameter}
            donut_radius:=sqrt(2*sqr(hfd_diameter/2)-sqr(hole_radius));
            diam:=sqrt(n*n+m*m);
            if ((diam<=donut_radius) and ( diam>=hole_radius {hole})) then
            begin
              flux:=1000*sqr(j/head.width);
              flux_star:=flux_star+flux;
              img_loaded[0,j+n,i+m]:=img_loaded[0,j+n,i+m]+flux;{DONUT SHAPED stars}
            end;
          end;
        end;
        add_text('COMMENT  ',' ,star'+inttostr(starcounter)+', '+floattostr4(j+shiftX+1)+', '+floattostr4(i+shiftY+1)+', '+floattostr4(flux_star) ); {add the star coordinates to the header}
        if diagn_star then
          add_text('COMMENT  ',' ,star'+inttostr(starcounter)+'D, '+floattostr4(j+shiftX+1+180+starcounter)+', '+floattostr4(i+shiftY+1+130+starcounter)+', '+floattostr4(flux_star) ); {diagonal stars}

      end;
    end;

  end;

  update_menu(true);{file loaded, update menu for fits. Set fits_file:=true}
  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,true,true);{plot test image}
end;



procedure Tstackmenu1.clear_blink_alignment1Click(Sender: TObject);
var
  c         : integer;
begin
  for c:=0 to listview6.items.count-1 do
  begin
    bsolutions:=nil;
    listview6.Items.item[c].subitems.Strings[B_solution]:='';{clear alignment marks}
  end;
end;


procedure Tstackmenu1.clear_blink_list1Click(Sender: TObject);
begin
  esc_pressed:=true; {stop any running action}
  listview6.Clear;
end;


procedure Tstackmenu1.browse_dark1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select dark images';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.filename:='';
  opendialog1.Filter :=dialog_filter;
  if opendialog1.execute then
  begin
    listview2.items.beginupdate;
    for i:=0 to OpenDialog1.Files.count-1 do {add}
    begin
      listview_add(listview2,OpenDialog1.Files[i],true,D_nr);
    end;
    listview2.items.endupdate;
  end;
end;


procedure Tstackmenu1.browse_inspector1Click(Sender: TObject);
var i: integer;
begin
  OpenDialog1.Title := 'Select images to add';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=dialog_filter;
  fits_file:=true;
  if opendialog1.execute then
  begin
    listview8.items.beginupdate;
    for i:=0 to OpenDialog1.Files.count-1 do {add}
    begin
      listview_add(listview8,OpenDialog1.Files[i],true,L_nr);
    end;
    listview8.items.endupdate;
  end;
end;


procedure Tstackmenu1.browse_live_stacking1Click(Sender: TObject);
var
  live_stack_directory : string;
begin
  if SelectDirectory('Select directory containing the files to stack live', live_stacking_path1.caption , live_stack_directory) then
  begin
    live_stacking_path1.caption:=live_stack_directory;{show path}
  end;
end;


procedure Tstackmenu1.analyse_objects_visibles1Click(Sender: TObject);
var
  Save_Cursor          : TCursor;
begin
  if ListView1.items.count=0 then begin memo2_message('Abort, No files in tab IMAGES.' ); exit;end;{no files in list, exit}

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  if listview1.selected=nil then
                 ListView1.ItemIndex := 0;{show wich file is processed}
  filename2:=Listview1.selected.caption;

  if load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded)=false then
  begin
    memo2_message('Abort, can'+#39+'t load '+ filename2);
    Screen.Cursor :=Save_Cursor;    { back to normal }
    exit;
  end;
  if ((head.cd1_1=0) or (stackmenu1.ignore_header_solution1.checked)) then {no solution or ignore solution}
  begin
    memo2_message('Solving file: '+ filename2);
    if create_internal_solution(img_loaded)= false then
    begin
      memo2_message('Abort, can'+#39+'t solve '+ filename2);
      Screen.Cursor :=Save_Cursor;    { back to normal }
      exit;
    end;
  end;

  memo2_message('Annotating file: '+ filename2+ ' and extracting objects.');
  plot_mpcorb(strtoint(maxcount_asteroid),strtofloat2(maxmag_asteroid),true {add annotations});
  if annotated then
  begin
    mainwindow.annotations_visible1.checked:=true;
    plot_annotations(false {use solution vectors},true {fill combobox});
    stackmenu1.ephemeris_centering1.itemindex:=stackmenu1.ephemeris_centering1.items.count-1;{show first found in the list}
  end
  else
  memo2_message('No object locations found in image. Modify limiting count and limiting magnitude in annotation menu CTRL+Q');
  memo2_message('Ready. Select the object to align on.');
  Screen.Cursor :=Save_Cursor;    { back to normal }
end;


procedure Tstackmenu1.browse_photometry1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select images to add';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=dialog_filter;
  fits_file:=true;
  if opendialog1.execute then
  begin
    listview7.items.beginupdate;
    for i:=0 to OpenDialog1.Files.count-1 do {add}
      listview_add(listview7,OpenDialog1.Files[i],true,P_nr);
    listview7.items.endupdate;
  end;
end;


procedure Tstackmenu1.aavso_button1Click(Sender: TObject);
begin
  if form_aavso1=nil then
      form_aavso1:=Tform_aavso1.Create(self); {in project option not loaded automatic}
  form_aavso1.Show{Modal};
end;


procedure Tstackmenu1.clear_mount_list1Click(Sender: TObject);
begin
  esc_pressed:=true; {stop any running action}
  listview9.Clear;
end;


procedure Tstackmenu1.extract_green1Click(Sender: TObject);
var
  c           : integer;
  Save_Cursor : TCursor;
  fn,col        : string;
begin
  case  QuestionDlg (pchar('Raw colour separation'),pchar('This will extract the green, blue or red pixels from the (calibrated) raw files and write to result to new files. Select colour:'),mtCustom
                                                          ,[20,'Red pixels', 21, 'Green pixels', 'IsDefault', 22, 'Blue pixels', 23, 'Cancel'],'') of
       20: col:='TR';
       21: col:='TG';
       22: col:='TB';
       else exit;
  end;{case}

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  esc_pressed:=false;

  if listview7.items.count>0 then
  begin
    for c:=0 to listview7.items.count-1 do
     if  listview7.Items.item[c].checked then
     begin
       if fits_file_name(filename2)=false then
       begin
         memo2_message('█ █ █ █ █ █ Can'+#39+'t extract. First analyse file list !! █ █ █ █ █ █');
         beep;
         exit;
       end;
       fn:=extract_raw_colour_to_file(ListView7.items[c].caption,col{'TG' or 'TB'},1,1); {extract green red or blue channel}
       if fn<>'' then
       begin
           ListView7.items[c].caption:=fn;
           listview7.Items.item[c].subitems.Strings[B_exposure]:='';{clear head.exposure, indicate a new analyse is required}
       end;

       {scroll}
       listview7.Selected :=nil; {remove any selection}
       listview7.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
       listview7.Items[c].MakeVisible(False);{scroll to selected item}

       application.processmessages;
       if esc_pressed then begin Screen.Cursor:=Save_Cursor; exit; end;
     end;
  end;
  analyse_listview(listview7,true {light},false {full fits},false{refresh}); {refresh list}
  Screen.Cursor := Save_Cursor;  { Always restore to normal }

end;


procedure Tstackmenu1.clear_inspector_list1Click(Sender: TObject);
begin
  esc_pressed:=true; {stop any running action}
  listview8.Clear;
end;

procedure Tstackmenu1.copy_to_blink1Click(Sender: TObject);
var
  index,counter: integer;
begin
  index:=0;
  listview6.Items.beginUpdate;
  counter:=listview5.Items.Count;
  while index<counter do
  begin
    if  listview5.Items[index].Selected then
    begin
      listview_add(listview6,listview5.items[index].caption,true,L_nr);
    end;
    inc(index); {go to next file}
  end;
  listview6.Items.endUpdate;
end;

procedure Tstackmenu1.copy_to_photometry1Click(Sender: TObject);
var
  index,counter: integer;
begin
  index:=0;
  listview7.Items.beginUpdate;
  counter:=listview5.Items.Count;
  while index<counter do
  begin
    if  listview5.Items[index].Selected then
    begin
      listview_add(listview7,listview5.items[index].caption,true,L_nr);
    end;
    inc(index); {go to next file}
  end;
  listview7.Items.endUpdate;
end;

procedure Tstackmenu1.curve_fitting1Click(Sender: TObject);
var
  p,a,b,posit, center,hfd : double;
  c,img_counter,i,fields     : integer;
  array_hfd : array of tdouble2;
var {################# initialised variables #########################}
  len: integer= 200;
begin
  memo2_message('Finding the best focus position for each area using hyperbola curve fitting');
  memo2_message('Positions are for an image with pixel position 1,1 at left bottom. So bl=bottom left is at corner of pixel position 1,1.');
  {do first or second time}
  analyse_listview(listview8,true{light},true{full fits},false{refresh});

  setlength(array_hfd,len);
  if sender<>nil then fields:=7 else fields:=1;
  for i:=1 to fields do {do all hfd areas}
  begin
    img_counter:=0;
    with listview8 do
    for c:=0 to listview8.items.count-1 do
    begin
      if Items.item[c].checked then
      begin

        posit:=strtofloat2(Items.item[c].subitems.Strings[insp_focus_pos]);{inefficient but simple code to convert string back to float}
        if posit>0 then
        begin
          hfd:=strtofloat(Items.item[c].subitems.Strings[insp_focus_pos+i]);
          if hfd<15 then {valid data}
          begin
            array_hfd[img_counter,1]:=posit;
            array_hfd[img_counter,2]:=hfd;
            inc(img_counter);
            if img_counter>=len then begin len:=len+200; setlength(array_hfd,len); {adapt size} end;
          end;
        end
        else memo2_message('█ █ █ █ █ █  Error, no focus position in fits header! █ █ █ █ █ █ ');
      end;
    end;
    if img_counter>=4 then
    begin
      find_best_hyperbola_fit(array_hfd, img_counter, p,a,b); {input data[n,1]=position,data[n,2]=hfd, output: bestfocusposition=p, a, b of hyperbola}

      if i=1 then       memo2_message('full image'+#9+#9+ 'Focus='+floattostrf(p,ffFixed,0,0)+#9+'a='+floattostrf(a,ffFixed,0,5)+#9+' b='+floattostrf(b,ffFixed,9,5) +#9+'_____________'            +#9+#9+'error='+floattostrf(lowest_error,ffFixed,0,5)+#9+' iteration cycles='+floattostrf(iteration_cycles,ffFixed,0,0));
      if i=2 then begin memo2_message('center'+#9+#9+     'Focus='+floattostrf(p,ffFixed,0,0)+#9+'a='+floattostrf(a,ffFixed,0,5)+#9+' b='+floattostrf(b,ffFixed,9,5) +#9+'_____________'            +#9+#9+'error='+floattostrf(lowest_error,ffFixed,0,5)+#9+' iteration cycles='+floattostrf(iteration_cycles,ffFixed,0,0));center:=p;end;
      if i=3 then       memo2_message('outer ring'+#9+#9+ 'Focus='+floattostrf(p,ffFixed,0,0)+#9+'a='+floattostrf(a,ffFixed,0,5)+#9+' b='+floattostrf(b,ffFixed,9,5) +#9+'offset='+floattostrf(p-center,ffFixed,5,0)+#9+#9+'error='+floattostrf(lowest_error,ffFixed,0,5)+#9+' iteration cycles='+floattostrf(iteration_cycles,ffFixed,0,0));
      if i=4 then       memo2_message('bottom left'+#9+#9+'Focus='+floattostrf(p,ffFixed,0,0)+#9+'a='+floattostrf(a,ffFixed,0,5)+#9+' b='+floattostrf(b,ffFixed,9,5) +#9+'offset='+floattostrf(p-center,ffFixed,5,0)+#9+#9+'error='+floattostrf(lowest_error,ffFixed,0,5)+#9+' iteration cycles='+floattostrf(iteration_cycles,ffFixed,0,0));
      if i=5 then       memo2_message('bottom right'+#9+  'Focus='+floattostrf(p,ffFixed,0,0)+#9+'a='+floattostrf(a,ffFixed,0,5)+#9+' b='+floattostrf(b,ffFixed,9,5) +#9+'offset='+floattostrf(p-center,ffFixed,5,0)+#9+#9+'error='+floattostrf(lowest_error,ffFixed,0,5)+#9+' iteration cycles='+floattostrf(iteration_cycles,ffFixed,0,0));
      if i=6 then       memo2_message('top left'+#9+#9+   'Focus='+floattostrf(p,ffFixed,0,0)+#9+'a='+floattostrf(a,ffFixed,0,5)+#9+' b='+floattostrf(b,ffFixed,9,5) +#9+'offset='+floattostrf(p-center,ffFixed,5,0)+#9+#9+'error='+floattostrf(lowest_error,ffFixed,0,5)+#9+' iteration cycles='+floattostrf(iteration_cycles,ffFixed,0,0));
      if i=7 then       memo2_message('top right'+#9+#9+  'Focus='+floattostrf(p,ffFixed,0,0)+#9+'a='+floattostrf(a,ffFixed,0,5)+#9+' b='+floattostrf(b,ffFixed,9,5) +#9+'offset='+floattostrf(p-center,ffFixed,5,0)+#9+#9+'error='+floattostrf(lowest_error,ffFixed,0,5)+#9+' iteration cycles='+floattostrf(iteration_cycles,ffFixed,0,0));
    end
    else
    if i=1 then memo2_message('█ █ █ █ █ █  Error, four or more images are required at different focus positions! █ █ █ █ █ █ ');
  end;
end;


procedure Tstackmenu1.ephemeris_centering1Change(Sender: TObject);
begin
  new_analyse_required:=true;{force a new analyse for new x, y position asteroids}
end;


procedure Tstackmenu1.focallength1Exit(Sender: TObject);
begin
 if sender=focallength1 then {manual entered}
     focallen:=strtofloat2(stackmenu1.focallength1.text);{manual entered focal length, update focallen}

 if sender=pixelsize1 then {manual entered}
      xpixsz:=strtofloat2(stackmenu1.pixelsize1.text);{manual entered micrometer, update xpixsz}

  if head.cd1_1<>0 then {solved image}
  begin
    calc_scale:=3600*abs(head.cdelt2);
    if sender=focallength1 then {calculate pixelsize from head.cdelt2 and manual entered focallen}
    begin
      xpixsz:=calc_scale*focallen/((180*3600/1000)/pi);
      stackmenu1.pixelsize1.text:=floattostrf(xpixsz,ffgeneral, 4, 4);
    end
    else
    begin  {calculate focal length from head.cdelt2 and pixelsize1}
      focallen:=(xpixsz/calc_scale)*(180*3600/1000)/pi; {arcsec per pixel}
      stackmenu1.focallength1.text:=floattostrf(focallen,ffgeneral, 4, 4);
    end;
  end
  else
  begin {not a solved image}
    if focallen<>0 then calc_scale:=(xpixsz/focallen)*(180*3600/1000)/pi {arcsec per pixel}
                   else calc_scale:=0;
  end;

  if calc_scale<> 0 then calculated_scale1.caption:=floattostrf(calc_scale, ffgeneral, 3, 3)+' "/pixel'
                    else calculated_scale1.caption:='- - -';

  if ((xpixsz<>0) and (focallen<>0)) then
    scale_calc1.Caption:=floattostrf((head.width*xpixsz/focallen)*(180/1000)/pi,ffgeneral, 3, 3)+'° x '+floattostrf((head.height*xpixsz/focallen)*(180/1000)/pi, ffgeneral, 3, 3)+'°'
  else
    scale_calc1.Caption:='- - -';
end;


procedure Tstackmenu1.go_step_two1Click(Sender: TObject);
begin
  load_image(mainwindow.image1.visible=false,true {plot});
  update_equalise_background_step(2); {go to step 3}
end;


procedure Tstackmenu1.luminance_filter1exit(Sender: TObject);
var
  err,mess,mess2 :boolean;
  red1,red2,green1,green2,blue1,blue2,lum1,lum2 : string;
begin
  new_analyse_required:=true;
  new_analyse_required3:=true;{tab 3 flats}
  err:=false;
  mess:=false;
  mess2:=false;
  red1:=trim(red_filter1.text); {remove spaces before and after}
  red2:=trim(red_filter2.text);
  green1:=trim(green_filter1.text);
  green2:=trim(green_filter2.text);
  blue1:=trim(blue_filter1.text);
  blue2:=trim(blue_filter2.text);
  lum1:=trim(luminance_filter1.text);
  lum2:=trim(luminance_filter2.text);


  {remove duplication because they will be ignored later. Follow execution of stacking routine (for i:=0 to 4) so red, green, blue luminance}
  if  AnsiCompareText(green1,red1)=0 then begin err:=true;green1:=''; end;
  if  AnsiCompareText(green1,red2)=0 then begin err:=true;green1:=''; end;

  if  AnsiCompareText(green2,red1)=0 then begin err:=true;green2:=''; end;
  if  AnsiCompareText(green2,red2)=0 then begin err:=true;green2:=''; end;

  if  AnsiCompareText(blue1,red1)=0 then begin err:=true;blue1:=''; end;
  if  AnsiCompareText(blue1,red2)=0 then begin err:=true;blue1:=''; end;

  if  AnsiCompareText(blue2,red1)=0 then begin err:=true;blue2:=''; end;
  if  AnsiCompareText(blue2,red2)=0 then begin err:=true;blue2:=''; end;

  if  AnsiCompareText(blue1,green1)=0 then begin err:=true;blue1:=''; end;
  if  AnsiCompareText(blue1,green2)=0 then begin err:=true;blue1:=''; end;

  if  AnsiCompareText(blue2,green1)=0 then begin err:=true;blue2:=''; end;
  if  AnsiCompareText(blue2,green2)=0 then begin err:=true;blue2:=''; end;


  if  AnsiCompareText(lum1,red1)=0 then begin mess:=true; end;
  if  AnsiCompareText(lum1,red2)=0 then begin mess:=true; end;

  if  AnsiCompareText(lum2,red1)=0 then begin mess2:=true; end;
  if  AnsiCompareText(lum2,red2)=0 then begin mess2:=true; end;

  if  AnsiCompareText(lum1,green1)=0 then begin mess:=true; end;
  if  AnsiCompareText(lum1,green2)=0 then begin mess:=true; end;

  if  AnsiCompareText(lum2,green1)=0 then begin mess2:=true; end;
  if  AnsiCompareText(lum2,green2)=0 then begin mess2:=true; end;

  if  AnsiCompareText(lum1,blue1)=0 then begin mess:=true; end;
  if  AnsiCompareText(lum1,blue2)=0 then begin mess:=true; end;

  if  AnsiCompareText(lum2,blue1)=0 then begin mess2:=true; end;
  if  AnsiCompareText(lum2,blue2)=0 then begin mess2:=true; end;

  red_filter1.text:=red1;
  red_filter2.text:=red2;
  green_filter1.text:=green1;
  green_filter2.text:=green2;
  blue_filter1.text:=blue1;
  blue_filter2.text:=blue2;
  luminance_filter1.text:=lum1;
  luminance_filter2.text:=lum2;

  if err then
    memo2_message('Filter name can be used only once  for RGB! Use matrix to use a filter more than once.');

  if mess then luminance_filter1.font.Style:=[fsbold] else luminance_filter1.font.Style:=[];
  if mess2 then luminance_filter2.font.Style:=[fsbold] else luminance_filter2.font.Style:=[];
end;


procedure Tstackmenu1.help_inspector_tab1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#inspector_tab');
end;


procedure Tstackmenu1.help_live_stacking1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#live_stacking');
end;

procedure Tstackmenu1.help_pixel_math2Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#pixel_math2');
end;

procedure update_replacement_colour;
var
  r,g,b,h,s,v : single;
  colour : tcolor;
  saturation : double;
begin
  colour:=stackmenu1.colourShape2.brush.color;
  RGB2HSV(getRvalue(colour),getGvalue(colour),getBvalue(colour),h,s,v);

  if stackmenu1.remove_luminance1.checked=false then
    saturation:=stackmenu1.new_saturation1.position /100
  else
    saturation:=0;
  HSV2RGB(h , s * saturation {s 0..1}, v {v 0..1},r,g,b); {HSV to RGB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
  stackmenu1.colourshape3.brush.color:=rgb(trunc(r),trunc(g),trunc(b));
end;



procedure sample(sx,sy : integer);{sampe local colour and fill shape with colour}
var
    halfboxsize,i,j,counter,fx,fy,col_r,col_g,col_b  :integer;
    r,g,b,h,s,v,colrr,colgg,colbb,luminance, luminance_stretched,factor, largest : single;
    dummy1,radiobutton2: boolean;
begin
  dummy1:=stackmenu1.HueRadioButton1.checked;
  radiobutton2:=stackmenu1.HueRadioButton2.checked;

  if ((dummy1=false) and (radiobutton2=false)) then exit;
  halfboxsize:=max(0,(stackmenu1.sample_size1.itemindex));
  counter:=0;
  colrr:=0;
  colgg:=0;
  colbb:=0;
  for i:=-halfboxsize to halfboxsize do
  for j:=-halfboxsize to halfboxsize do {average local colour}
  begin
    fx:=i+sX;
    fy:=j+sY;
    if ((fx>=0) and (fx<head.width) and (fy>=0) and (fy<head.height) ) then
    begin
      inc(counter);
      colrr:=colrr+img_loaded[0,sX,sY];
      colgg:=colgg+img_loaded[1,sX,sY];
      colbb:=colbb+img_loaded[2,sX,sY];
   end;
  end;
  if counter=0 then exit;
  colrr:=((colrr/counter)-cblack)/(cwhite-cblack);{scale to 0..1}
  colgg:=((colgg/counter)-cblack)/(cwhite-cblack);{scale to 0..1}
  colbb:=((colbb/counter)-cblack)/(cwhite-cblack);{scale to 0..1}

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

  RGB2HSV(col_r,col_g,col_b,h,s,v); {RGB to HSVB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}

  if dummy1 then
  begin
    HSV2RGB(h , s {s 0..1}, v {v 0..1},r,g,b); {HSV to RGB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
    stackmenu1.colourshape1.brush.color:=rgb(trunc(r),trunc(g),trunc(b));
    stackmenu1.hue_fuzziness1Change(nil);
  end
  else
  if RadioButton2 then
  begin
    HSV2RGB(h , s {s 0..1}, v {v 0..1},r,g,b); {HSV to RGB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
    stackmenu1.colourshape2.brush.color:=rgb(trunc(r),trunc(g),trunc(b));
    update_replacement_colour;
  end;

end;

procedure Tstackmenu1.hue_fuzziness1Change(Sender: TObject);
var
  colour :tcolor;
  oldhue,s,v,dhue   : single;
begin
  dhue:=hue_fuzziness1.position;
  colour:=colourShape1.brush.color;
  RGB2HSV(getRvalue(colour),getGvalue(colour),getBvalue(colour),oldhue,s,v);

  hue1:=oldhue - dhue/2;
  if hue1>360 then hue1:=hue1-360;
  if hue1<0 then hue1:=hue1+360;

  hue2:=oldhue + dhue/2;
  if hue2>360 then hue2:=hue2-360;
  if hue2<0 then hue2:=hue2+360;

  stackmenu1.rainbow_panel1.refresh;{plot colour disk in on paint event. Onpaint is required for MacOS}
end;


procedure Tstackmenu1.listview8CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  stackmenu1.nr_total_inspector1.caption:=inttostr(sender.items.count);{update counting info}
end;

procedure Tstackmenu1.listview8CustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if sender.Items.item[Item.Index].subitems.Strings[insp_nr_stars]='❌'  then
    Sender.Canvas.Font.Color := clred
  else
    Sender.Canvas.Font.Color := clmenutext;{required for high contrast settings. Otherwise it is always black}

  {$ifdef mswindows}
   {$else} {unix}
   {temporary fix for CustomDraw not called}
   if  Item.index=0 then  stackmenu1.nr_total_inspector1.caption:=inttostr(sender.items.count);{update counting info}
   {$endif}
end;

procedure Tstackmenu1.live_stacking1Click(Sender: TObject);
begin
  save_settings2;{too many lost selected files . so first save settings}
  esc_pressed:=false;
  live_stacking_pause1.font.style:=[];
  live_stacking1.font.style:=[fsbold,fsunderline];
  Application.ProcessMessages; {process font changes}
  if pause_pressed=false then {restart}
      stack_live(round(strtofloat2(stackmenu1.oversize1.Text)), live_stacking_path1.caption){stack live average}
  else
     pause_pressed:=false;
end;



{$ifdef mswindows}
procedure CopyFilesToClipboard(FileList: string); {See https://forum.lazarus.freepascal.org/index.php?topic=18637.0}
var
  DropFiles: PDropFiles;
  hGlobal: THandle;
  iLen: integer;
begin
  iLen := Length(FileList) + 2;
  FileList := FileList + #0#0;   // <-- Important to make it work
  hGlobal := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT,
    SizeOf(TDropFiles) + iLen);
  if (hGlobal = 0) then
    raise Exception.Create('Could not allocate memory.');
  begin
    DropFiles := GlobalLock(hGlobal);
    DropFiles^.pFiles := SizeOf(TDropFiles);
    Move(FileList[1], (PChar(DropFiles) + SizeOf(TDropFiles))^, iLen);
    GlobalUnlock(hGlobal);
    OpenClipboard(mainwindow.Handle);
    EmptyClipboard;
    SetClipboardData(CF_HDROP,hGlobal);
    CloseClipboard;
   end;
end;
{$else} {unix}
{$endif}


procedure Tstackmenu1.copy_files_to_clipboard1Click(Sender: TObject);
var
  index : integer;
  info  : string;
begin
 {$ifdef mswindows}
  {get file name selected}
  info:='';
  for index:=0 to listview5.items.count-1 do
  begin
    if  listview5.Items[index].Selected then
    begin
      info:=info+listview5.items[index].caption+#0; {Separate the files with a #0.}
    end;
  end;
  CopyFilesToClipboard(info);
{$else} {unix}
{$endif}
end;


procedure Tstackmenu1.most_common_mono1Click(Sender: TObject);
begin
  mainwindow.convertmono1Click(nil); {back is made in mono procedure}
end;


procedure Tstackmenu1.mount_add_solutions1Click(Sender: TObject);
var
   c: integer;
   Save_Cursor          : TCursor;
   refresh_solutions    : boolean;
   thefile              : string;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  esc_pressed:=false;
  refresh_solutions:=mount_ignore_solutions1.checked; {refresh astrometric solutions}

  {solve lights first to allow flux to magnitude calibration}
  with stackmenu1 do
  for c:=0 to listview9.items.count-1 do {check for astrometric solutions}
  begin
    if ((esc_pressed=false) and (listview9.Items.item[c].checked) and (listview9.Items.item[c].subitems.Strings[M_ra]=''))  then
    begin
      filename2:=listview9.items[c].caption;
      mainwindow.caption:=filename2;

      Application.ProcessMessages;

      {load image}
      if ((esc_pressed) or (load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded)=false)) then
      begin
        Screen.Cursor :=Save_Cursor;{back to normal }
        exit;
      end;
      if ((head.cd1_1=0) or (refresh_solutions)) then
      begin
        listview9.Selected :=nil; {remove any selection}
        listview9.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview9.Items[c].MakeVisible(False);{scroll to selected item}
        memo2_message(filename2+ ' Adding astrometric solution to file.');
        Application.ProcessMessages;

        if solve_image(img_loaded,true  {get hist}) then
        begin{match between loaded image and star database}
          if mount_write_wcs1.checked then
          begin
            thefile:=StringReplace(filename2,'.fit','.wcs',[]);{.fit to .wcs, .fits to .wcss}
            write_astronomy_wcs(thefile);
            listview9.items[c].caption:=thefile;
          end
          else
          begin
            if savefits_update_header(filename2)=false then begin ShowMessage('Write error !!' + filename2);Screen.Cursor := Save_Cursor;exit;end;
          end
        end
        else
        begin
          listview9.Items[c].Checked:=false;
          listview9.Items.item[c].subitems.Strings[M_ra]:='?';
          listview9.Items.item[c].subitems.Strings[M_dec]:='?';
          memo2_message(filename2+ 'No astrometric solution found for this file!!');
        end;
      end
    end;
  end;
  Screen.Cursor :=Save_Cursor;{back to normal }

  stackmenu1.mount_analyse1Click(nil);{update}
end;


procedure Tstackmenu1.new_saturation1Change(Sender: TObject);
begin
  update_replacement_colour;
end;


procedure Tstackmenu1.pagecontrol1Change(Sender: TObject);
var
  theindex :integer;
begin
  theindex:=stackmenu1.pagecontrol1.tabindex;
  mainwindow.shape_alignment_marker1.visible:=(theindex=8); {hide shape if stacked image is plotted}
  mainwindow.shape_alignment_marker2.visible:=(theindex=8); {hide shape if stacked image is plotted}
  mainwindow.shape_alignment_marker3.visible:=(theindex=8); {hide shape if stacked image is plotted}
  mainwindow.labelVar1.visible:=(theindex=8);
  mainwindow.labelCheck1.visible:=(theindex=8);
  mainwindow.labelThree1.visible:=(theindex=8);
end;


var FLastHintTabIndex : integer;
procedure Tstackmenu1.pagecontrol1MouseMove(Sender: TObject; {Show hints of each tab when mouse hovers above it}
  Shift: TShiftState; X, Y: Integer);
var
  TabIndex: Integer;
begin
  TabIndex := PageControl1.IndexOfTabAt(X, Y);
  if FLastHintTabIndex <> TabIndex then
      Application.CancelHint;
  if TabIndex <> -1 then
     PageControl1.Hint:= PageControl1.Pages[TabIndex].Hint;
  FLastHintTabIndex := TabIndex;
end;

procedure Tstackmenu1.press_esc_to_abort1Click(Sender: TObject);
begin
  esc_pressed:=true;
end;


procedure Tstackmenu1.rainbow_Panel1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  w2,h2 : integer;
  hue,dhue,oldhue,s,v,r,g,b   : single;
  colour : tcolor;
begin
  with rainbow_Panel1 do
  begin
    w2:= width div 2;
    h2:= height div 2;

    hue:=180+Arctan2(x-w2,y-h2)*180/pi;

    dhue:=hue_fuzziness1.position;
    hue1:=hue - dhue/2;
    hue2:=hue + dhue/2;
    stackmenu1.rainbow_panel1.refresh;{plot colour disk on an OnPaint event. Required for MacOS}
  end;

  {adapt shape colours}
  if HueRadioButton1.checked then
  begin
    colour:=colourShape1.brush.color;
    RGB2HSV(getRvalue(colour),getGvalue(colour),getBvalue(colour),oldhue,s,v);
    HSV2RGB(hue , s {s 0..1}, v {v 0..1},r,g,b);
    colourShape1.brush.color:=rgb(trunc(r),trunc(g),trunc(b));
  end;
  if HueRadioButton2.checked then
  begin
    update_replacement_colour;

//    colour:=colourShape2.brush.color;
//    RGB2HSV(getRvalue(colour),getGvalue(colour),getBvalue(colour),oldhue,s,v);
//    HSV2RGB(hue , s {s 0..1}, v {v 0..1},r,g,b);
//    colourShape2.brush.color:=rgb(trunc(r),trunc(g),trunc(b));
//    HSV2RGB(hue , s*new_saturation1.position /100 {s 0..1}, v {v 0..1},r,g,b);
//    colourShape3.brush.color:=rgb(trunc(r),trunc(g),trunc(b));
  end;
end;

procedure Tstackmenu1.rainbow_Panel1Paint(Sender: TObject); {pixel draw on paint required for MacOS}
  var
  i,j,w2,h2,diameter :integer;
  r,g,b,h,x,y,radius,s,v : single;
  colour             : tcolor;
begin
  with stackmenu1.rainbow_panel1 do
  begin
    w2:= width div 2;
    h2:= height div 2;

    for i:=-w2 to w2  do
    for j:=-h2 to h2 do
    begin
      if sqr(i)+sqr(j)<sqr(w2) then {plot only in a circel}
      begin
        h:=180+Arctan2(i,j)*180/pi;
        radius:=(i*i+j*j)/(w2*h2);
        HSV2RGB(h, radius {s 0..1}, 255 {v 0..1},r,g,b);
        canvas.pixels[i+w2,j+h2]:=rgb(trunc(r),trunc(g),trunc(b));
        end;
    end;

    Canvas.Pen.width :=2;{thickness lines}
    Canvas.pen.color:=clblack;
    sincos(hue1*pi/180,x,y);
    canvas.moveto(w2,h2);
    canvas.lineto(w2-round(x*(w2-3)),h2-round(y*(w2-3)));

    sincos(hue2*pi/180,x,y);
    canvas.moveto(w2,h2);
    canvas.lineto(w2-round(x*(w2-3)),h2-round(y*(w2-3)));

    colour:=colourShape1.brush.color;
    RGB2HSV(getRvalue(colour),getGvalue(colour),getBvalue(colour),h,s,v);

    canvas.Brush.Style:=bsClear;{transparent style}
    diameter:=max(0,round(w2*s - w2*saturation_tolerance1.position/100));
    canvas.Ellipse(w2-diameter, h2-diameter, w2+diameter, h2+diameter);

    diameter:=min(w2,round(w2*s + w2*saturation_tolerance1.position/100));
    canvas.Ellipse(w2-diameter, h2-diameter, w2+diameter, h2+diameter);


  end;
end;


procedure Tstackmenu1.remove_luminance1Change(Sender: TObject);
begin
  update_replacement_colour;
end;


procedure Tstackmenu1.result_compress1Click(Sender: TObject);
var index,counter: integer;
    filen  : string;
  Save_Cursor:TCursor;
begin
  index:=0;
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  counter:=listview5.Items.Count;
  esc_pressed:=false;
  while index<counter do
  begin
    if  listview5.Items[index].Selected then
    begin
      filen:=listview5.items[index].caption;
      Application.ProcessMessages;
      if ((esc_pressed) or (pack_cfitsio(filen)=false)) then begin beep; mainwindow.caption:='Exit with error!!'; Screen.Cursor := Save_Cursor;  exit;end;
    end;
    inc(index); {go to next file}
  end;
  stackmenu1.caption:='Finished, all files compressed with extension .fz.';
  Screen.Cursor := Save_Cursor;  { Always restore to normal }
end;


procedure Tstackmenu1.rename_result1Click(Sender: TObject);
var index,counter: integer;
    thepath, newfilen  : string;
begin
  index:=0;
  counter:=listview5.Items.Count;
  while index<counter do
  begin
    if  listview5.Items[index].Selected then
    begin
      filename2:=listview5.items[index].caption;
      thepath:=extractfilepath(filename2);
      newfilen:=thepath+InputBox('New name:','',extractfilename(filename2)) ;
      if ((newfilen='') or (newfilen=filename2)) then exit;
      if RenameFile(filename2,newfilen) then
        listview5.items[index].caption:=newfilen
      else
        beep;
    end;
    inc(index); {go to next file}
  end;

end;

procedure Tstackmenu1.restore_file_ext1Click(Sender: TObject);
var
  searchResult : TSearchRec;
  filen        : string;
  counter      : integer;
begin
  counter:=0;
  esc_pressed:=true; {stop all stacking}
  If FindFirst (live_stacking_path1.caption+PathDelim+'*.*_',faAnyFile,searchResult)=0 then
    begin
    Repeat
      With searchResult do
        begin
          filen:=live_stacking_path1.caption+PathDelim+searchResult.Name;
          if copy(filen,length(filen),1)='_' then
          begin
            if RenameFile(filen,copy(filen,1,length(filen)-1))=false then {remove *.*_}
            beep
            else
            inc(counter);
          end;
        end;
    Until FindNext(searchResult)<>0;
    end;
  FindClose(searchResult);

  live_stacking_pause1.font.style:=[];
  live_stacking1.font.style:=[];

  memo2_message('Live stacking stopped and '+inttostr(counter)+' files renamed to original file name.');
end;



procedure Tstackmenu1.colournebula1Click(Sender: TObject);
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

  setlength(img_temp,3,head.width,head.height);{new size}
  apply_most_common(img_backup[index_backup].img,img_temp,radius); {apply most common filter on first array and place result in second array}

  memo2_message('Applying Gaussian blur of '+floattostrF(radius*2,ffFixed,0,1));
  gaussian_blur2(img_temp,radius*2);


  setlength(img_loaded,3,head.width,head.height);{new size}

  memo2_message('Separating stars and nebula. Making everything white with value '+stackmenu1.star_level_colouring1.text+' above background.');

  star_level_colouring:=strtoint(stackmenu1.star_level_colouring1.text);

  for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1 do
      begin {subtract view from file}
           org_value:=img_backup[index_backup].img[0,fitsX,fitsY];  {stars+nebula}
                              {smooth nebula}
           value:=org_value - img_temp[0,fitsX,fitsY];
           if  value>star_level_colouring then {star}
           begin
             img_loaded[0,fitsX,fitsY]:=org_value;
             if head.naxis3>1 then img_loaded[1,fitsX,fitsY]:=img_backup[index_backup].img[1,fitsX,fitsY] else img_loaded[1,fitsX,fitsY]:=org_value;
             if head.naxis3>2 then img_loaded[2,fitsX,fitsY]:=img_backup[index_backup].img[2,fitsX,fitsY] else img_loaded[2,fitsX,fitsY]:=org_value;
           end
           else {nebula}
           begin
             img_loaded[0,fitsX,fitsY]:=org_value;
             img_loaded[1,fitsX,fitsY]:=cblack+(org_value-cblack)*value/star_level_colouring;
             img_loaded[2,fitsX,fitsY]:=cblack+(org_value-cblack)*value/star_level_colouring;
           end

       end;

  head.naxis3:=3;
  head.naxis:=3;
  update_header_for_colour; {update header naxis and naxis3 keywords}
  update_text   ('HISTORY 77','  Artificial colour applied.');

  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,false,true);{plot real}
  Screen.Cursor:=Save_Cursor;
end;

procedure Tstackmenu1.refresh_astrometric_solutions1click(Sender: TObject);
var
  c         : integer;
begin
  if (IDYES= Application.MessageBox('This will renew the astrometric solutions of all files and could take some time. Are you sure?', 'Renew astrometric solutions of  all files?', MB_ICONQUESTION + MB_YESNO) )=false then exit;
  if listview7.items.count>0 then
  begin
    for c:=0 to listview7.items.count-1 do
    begin
      listview7.Items.item[c].subitems.Strings[P_astrometric]:='';{clear astrometry marks}
      listview7.Items.item[c].subitems.Strings[P_photometric]:='';{clear photometry marks}
    end;
  end;
  stackmenu1.photometry_button1Click(Sender);{refresh astrometric solutions}
end;

procedure Tstackmenu1.clear_photometry_list1Click(Sender: TObject);
begin
  esc_pressed:=true; {stop any running action}
  listview7.Clear;
end;

procedure Tstackmenu1.export_aligned_files1Click(Sender: TObject);
var
  c,fitsX,fitsY,x_new,y_new,col,ps : integer;
  Save_Cursor          : TCursor;
  st                   : string;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  esc_pressed:=false;

  align_blink1.checked:=true;
  for c:=0 to listview6.items.count-1 do {check alignement and if not align}
  begin
    st:=listview6.Items.item[c].subitems.Strings[B_solution];
    if st='' then
    begin
      memo2_message('Doing the alignment first');
      stackmenu1.clear_blink_alignment1Click(nil);
      stackmenu1.blink_button1Click(nil);
      break;
    end;
  end;


  for c:=0 to listview6.items.count-1 do {this is not required but nice}
  begin
    st:=listview6.Items.item[c].subitems.Strings[B_solution];
    if st<>'' then {Solution available}
    begin
      filename2:=listview6.items[c].caption;
      mainwindow.caption:=filename2;

      listview6.Selected :=nil; {remove any selection}
      listview6.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
      listview6.Items[c].MakeVisible(False);{scroll to selected item}

      if load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded)=false then begin esc_pressed:=true; break;end;  {load fits}

      Application.ProcessMessages;
      if esc_pressed then break;

      {reuse solution}
      ps:=strtoint(copy(st,4,10));
      solution_vectorX:=bsolutions[ps].solution_vectorX; {use stored solution}
      solution_vectorY:=bsolutions[ps].solution_vectorY;


      setlength(img_temp,head.naxis3,head.width,head.height);{new size}

      for fitsY:=0 to head.height-1 do
      for fitsX:=0 to head.width-1  do
      begin
         for col:=0 to head.naxis3-1 do {all colors} img_temp[col,fitsX,fitsY]:=0;{clear memory}
      end;

      {align}
      for fitsY:=0 to head.height-1 do
      for fitsX:=0 to head.width-1  do
      begin
        x_new:=round(solution_vectorX[0]*(fitsx)+solution_vectorX[1]*(fitsY)+solution_vectorX[2]); {correction x:=aX+bY+c}
        y_new:=round(solution_vectorY[0]*(fitsx)+solution_vectorY[1]*(fitsY)+solution_vectorY[2]); {correction y:=aX+bY+c}

        if ((x_new>=0) and (x_new<=head.width-1) and (y_new>=0) and (y_new<=head.height-1)) then
          for col:=0 to head.naxis3-1 do {all colors} img_temp[col,x_new,y_new]:=img_loaded[col,fitsX,fitsY] ;
      end;

      {fix black holes}
      img_loaded:=img_temp;
      black_spot_filter(img_loaded);

      if pos('_aligned.fit',filename2)=0 then filename2:=ChangeFileExt(Filename2,'_aligned.fit');{rename only once}

      if timestamp1.checked then
      begin
         if date_avg='' then
           annotation_to_array('date_obs: '+head.date_obs,false,65535,1{size},1,10,img_loaded) {head.date_obs to image array as annotation}
           else
           annotation_to_array('date_avg: '+date_avg,false,65535,1{size},1,10,img_loaded);{head.date_obs to image array as annotation}
      end;
      add_text   ('COMMENT ',' Image aligned with other images.                                    ');

      if nrbits=16 then
         save_fits(img_loaded,filename2,16,true)
        else
          save_fits(img_loaded,filename2,-32,true);
       memo2_message('New aligned image created: '+filename2);
      listview6.items[c].caption:=filename2;
    end


  end;
  img_temp:=nil;

  if fits_file=true then
    plot_fits(mainwindow.image1,false {re_center},true);{the last displayed image doesn't match with header. Just plot last image to fix}
  Screen.Cursor :=Save_Cursor;{back to normal }
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


function julian_calc(yyyy,mm:integer;dd,hours,minutes,seconds:double):double; {##### calculate julian day, revised 2017}
var
   Y,M   : integer;
   A, B , XX : double;
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


function UTdecimal(date : string): string; {UT date in decimal notation}
var dayfract : string;
begin
  {'2021-03-08T17:55:23'}
  str(strtoint(copy(date,12,2))/24 +strtoint(copy(date,15,2))/(24*60) + strtoint(copy(date,18,2))/(24*60*60):0:4,dayfract);{convert time to fraction of a day}
  result:=copy(date,1,4)+copy(date,6,2)+copy(date,9,2)+copy(dayfract,2,5);
end;


procedure date_to_jd(date_time:string; exp: double);{convert head.date_obs string and head.exposure time to global variables jd_start (julian day start head.exposure) and jd_mid (julian day middle of the head.exposure)}
var
   yy,mm,dd,hh,min,error2 : integer;
   ss                     : double;
begin
  jd_start:=0;
  val(copy(date_time,18,7),ss,error2); if error2<>0 then exit; {read also milliseconds}
//  val(copy(date_time,18,2),ss,error2); if error2<>0 then exit; {read also milliseconds}


  val(copy(date_time,15,2),min,error2);if error2<>0 then exit;
  val(copy(date_time,12,2),hh,error2);if error2<>0 then exit;
  val(copy(date_time,09,2),dd,error2);if error2<>0 then exit;
  val(copy(date_time,06,2),mm,error2);if error2<>0 then exit;
  val(copy(date_time,01,4),yy,error2);if error2<>0 then exit;
  jd_start:=julian_calc(yy,mm,dd,hh,min,ss);{calculate julian date}
  jd_mid:=jd_start+exp/(2*24*3600);{Add half head.exposure in days to get midpoint}
end;


procedure Tstackmenu1.extend_object_name_with_time_observation1Click(
  Sender: TObject);
var
   index,counter,error2: integer;
   interval,jd: double;
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
        date_to_jd(head.date_obs,head.exposure);{convert head.date_obs string and head.exposure time to global variables jd_start (julian day start head.exposure) and jd_mid (julian day middle of the head.exposure)}
        jd:=round(jd_start*24*3600/interval)*interval/(24*3600); {round to time to interval }
        str(jd:1:5, timestr);
        if  pos('-JD',object_name)=0 then
          object_name:=object_name+'-JD'+timestr {add head.date_obs without seconds}
        else
          object_name:=copy(object_name,1,length(object_name)-16)+'-JD'+timestr;

         update_text('OBJECT  =',#39+object_name+#39); {spaces will be added/corrected later}

         new_analyse_required:=true;{allow reanalyse}

        if nrbits=16 then
        save_fits(img_loaded,filename2,16,true)
         else
        save_fits(img_loaded,filename2,-32,true);
      end
      else
      beep;{image not found}
    end;
    inc(index); {go to next file}
  end;
end;

procedure Tstackmenu1.FormDropFiles(Sender: TObject; const FileNames: array of String);
var
   i,pageindex : integer;
begin
  pageindex:=pagecontrol1.pageindex;

  case pageindex of  1: listview2.Items.beginUpdate;{darks}
                     2: listview3.Items.beginUpdate;{flats}
                     3: listview4.Items.beginUpdate;{flat darks}
                     7: listview6.Items.beginUpdate;{blink}
                     8: listview7.Items.beginUpdate;{photometry}
                     9: listview8.Items.beginUpdate;{inspector}
                    10: listview9.Items.beginUpdate;{mount}
                     else listview1.Items.beginUpdate; {lights}

  end;

  for i := Low(FileNames) to High(FileNames) do
  begin
    if image_file_name(FileNames[i])=true then {readable image file}
    begin
      case pagecontrol1.pageindex of   1:   listview_add(listview2,FileNames[i],true,D_nr);{darks}
                                       2:   listview_add(listview3,FileNames[i],true,F_nr);{flats}
                                       3:   listview_add(listview4,FileNames[i],true,FD_nr);{flat darks}
                                       7:   listview_add(listview6,FileNames[i],true,B_nr);{blink}
                                       8:   listview_add(listview7,FileNames[i],true,P_nr);{photometry}
                                       9:   listview_add(listview8,FileNames[i],true,P_nr);{inspector}
                                      10:   listview_add(listview9,FileNames[i],true,P_nr);{mount}
                                       else
                                       begin {lights}
                                         listview_add(listview1,FileNames[i],true,L_nr);
                                         if  pos('_stacked',FileNames[i])<>0 then {do not check mark lights already stacked}
                                               listview1.items[ListView1.items.count-1].checked:=false;
                                       end;
      end;
    end;
  end;

  case pageindex of    1: listview2.Items.EndUpdate;{darks}
                       2: listview3.Items.EndUpdate;{flats}
                       3: listview4.Items.EndUpdate;{flat darks}
                       7: listview6.Items.EndUpdate;{blink}
                       8: listview7.Items.EndUpdate;{photometry}
                       9: listview8.Items.EndUpdate;{inspector}
                      10: listview9.Items.EndUpdate;{mount}
                       else
                       begin {lights}
                         listview1.Items.EndUpdate;
                         count_selected; {report the number of lights selected in images_selected and update menu indication}
                       end;
  end;

end;


procedure Tstackmenu1.FormPaint(Sender: TObject);
begin
  case pagecontrol1.tabindex of 7:more_indication1.visible:=stackmenu1.width<=export_aligned_files1.left+20;
                                8:more_indication1.visible:=stackmenu1.width<=mark_outliers_upto1.left+20;
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


procedure Tstackmenu1.listview7CustomDraw(Sender: TCustomListView; const ARect: TRect; var DefaultDraw: Boolean);
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


procedure Tstackmenu1.live_stacking_pause1Click(Sender: TObject);
begin
  pause_pressed:=true;
  live_stacking_pause1.font.style:=[fsbold,fsunderline];
  live_stacking1.font.style:=[];
  Application.ProcessMessages; {process font changes}
end;


procedure Tstackmenu1.live_stacking_restart1Click(Sender: TObject);
begin
  esc_pressed:=true;
  live_stacking_pause1.font.style:=[];
  live_stacking1.font.style:=[];
  Application.ProcessMessages; {process font changes}
end;


procedure Tstackmenu1.more_indication1Click(Sender: TObject);
begin
  case pagecontrol1.tabindex of 7:stackmenu1.Width:=export_aligned_files1.left+export_aligned_files1.width+10;{set width if clicked on arrow}
                                8:stackmenu1.Width:=mark_outliers_upto1.left+mark_outliers_upto1.width+10;
                                9:stackmenu1.Width:=GroupBox_test_images1.left+GroupBox_test_images1.width+10;
  end;
end;


procedure Tstackmenu1.photometry_binx2Click(Sender: TObject);
var
   c: integer;
begin
  esc_pressed:=false;
  if (IDYES= Application.MessageBox('Binning images 2x2 for better detection. Original files will be preserved. Continue?', 'Bin 2x2', MB_ICONQUESTION + MB_YESNO) )=false then exit;

  listview7.Items.beginUpdate;
  for c:=0 to listview7.items.count-1 do
  begin
    if ((esc_pressed=false) and (listview7.Items.item[c].checked) )  then
    begin

      filename2:=listview7.items[c].caption;

      if fits_file_name(filename2)=false then
      begin
        memo2_message('█ █ █ █ █ █ Can'+#39+'t bin x 2. First analyse file list to convert to FITS !! █ █ █ █ █ █');
        beep;
        exit;
      end;
      mainwindow.caption:=filename2;
      Application.ProcessMessages;
      if ((esc_pressed) or
          (binX2X3_file(2)=false)) {converts filename2 to binx2 version}
          then exit;
      listview7.Items[c].Checked:=false;
      listview_add(listview7,filename2,true,P_nr);{add binx2 file}
    end;
  end;{for loop}
  listview7.Items.endUpdate;
end;


procedure find_star_outliers(report_upto_magn: double; var outliers : star_list) {contains the four stars with largest SD }   ;
var
  stepnr,x_new,y_new,c,i,j,nr_images,smallest,w,h,w2,h2 : integer;
  stars_mean,stars_sd,stars_count : array of array of single;
  created : boolean;
  sd,xc,yc     : double;
const
    factor=10; {div factor to get small variations at the same location}
begin
  memo2_message('Searching for outliers');
  created:=false;
  stepnr:=0;
  nr_images:=0;
  w2:=999999;
  h2:=999999;
  outliers:=nil;{wil be used for detection later}

  repeat
    inc(stepnr);
    for c:=0 to stackmenu1.listview7.items.count-1 do {do all files}
    begin
      Application.ProcessMessages;
      if esc_pressed then begin exit; end;

      if stackmenu1.listview7.Items.item[c].checked  then
      begin {read solution}
        {load file, and convert astrometric solution to vector solution}
        filename2:=stackmenu1.listview7.items[c].caption;
        if load_fits(filename2,true {light},false {only read header},false {update memo},0,head,img_loaded)=false then begin esc_pressed:=true; exit;end;
        {calculate vectors from astrometric solution to speed up}
        sincos(head.dec0,SIN_dec0,COS_dec0); {do this in advance since it is for each pixel the same}
        astrometric_to_vector;{convert astrometric solution to vectors}

        w:=(starlistpack[c].width div factor);
        h:=(starlistpack[c].height div factor);
        if w2>w then w2:=w;{find smallest dimensions used}
        if h2>h then h2:=h;
        if created=false then
        begin
          setlength(stars_mean,w+1,h+1);
          setlength(stars_sd,w+1,h+1);
          setlength(stars_count,w+1,h+1);
          for i:=0 to w do
            for j:=0 to h do
            begin
              stars_mean[i,j]:=0;
              stars_sd[i,j]:=0;
              stars_count[i,j]:=0;
            end;
          created:=true;
        end;

        if  starlistpack[c].height<>0 then {filled with data}
        begin
          if stepnr=1 then inc(nr_images);{keep record of number of lights}
          try
            for i:=0 to min(length(starlistpack[c].starlist[0])-2,5000) do {calculate mean of the found stars}
            begin
              xc:=(solution_vectorX[0]*(starlistpack[c].starlist[0,i])+solution_vectorX[1]*(starlistpack[c].starlist[1,i])+solution_vectorX[2]); {correction x:=aX+bY+c}
              yc:=(solution_vectorY[0]*(starlistpack[c].starlist[0,i])+solution_vectorY[1]*(starlistpack[c].starlist[1,i])+solution_vectorY[2]); {correction y:=aX+bY+c}
              if ((xc>=factor) and (xc<=starlistpack[c].width-1-factor) and (yc>=factor) and (yc<=starlistpack[c].height-1-factor)) then {image could be shifted and very close to the boundaries. Prevent runtime errors}
              begin
                x_new:=round(xc/factor);
                y_new:=round(yc/factor);

                if stepnr=1 then
                begin {CALCULATE MEAN of stars}
                  stars_mean[x_new,y_new]:=stars_mean[x_new,y_new]+ starlistpack[c].flux_magn_offset-ln(starlistpack[c].starlist[3,i]{flux})*2.511886432/ln(10); {magnitude}
                  stars_count[x_new,y_new]:=stars_count[x_new,y_new]+1;{counter}
                end
                else {CALCULATE SD of stars}
                if stepnr=2 then
                stars_sd[x_new,y_new]:= stars_sd[x_new,y_new]+sqr( (stars_mean[x_new,y_new]/stars_count[x_new,y_new])- (starlistpack[c].flux_magn_offset-ln(starlistpack[c].starlist[3,i]{flux})*2.511886432/ln(10)) ); {sd calculate by sqr magnitude difference from mean}
              end;
            end;{for loop}
          except
            beep;
          end;
        end;{valid image}

     end;
   end;{for c:=0 loop}
  until stepnr>2;

  if created then
  begin

    setlength(outliers,4,4);
    for i:=0 to 3 do
      for j:=0 to 3 do
        outliers[i,j]:=0;

    {find largest outliers}
    for i:=0 to w2 do
      for j:=0 to h2 do
      begin
       try
         if stars_count[i,j]>=round(nr_images*0.8) then {at least in 80% of the cases star detection}
       if (stars_mean[i,j]/stars_count[i,j])<=report_upto_magn then {magnitude lower then}
       begin
         sd:=sqrt(stars_sd[i,j]/stars_count[i,j]);


         if ((sd>outliers[2,0]) or (sd>outliers[2,1]) or (sd>outliers[2,2]) or (sd>outliers[2,3])) then
         begin
           if  ((outliers[2,0]<=outliers[2,1]) and (outliers[2,0]<=outliers[2,2]) and (outliers[2,0]<=outliers[2,3])) then smallest:=0
           else
           if  ((outliers[2,1]<=outliers[2,0]) and (outliers[2,1]<=outliers[2,2]) and (outliers[2,1]<=outliers[2,3])) then smallest:=1
           else
           if  ((outliers[2,2]<=outliers[2,0]) and (outliers[2,2]<=outliers[2,1]) and (outliers[2,2]<=outliers[2,3])) then smallest:=2
           else
           if  ((outliers[2,3]<=outliers[2,0]) and (outliers[2,3]<=outliers[2,1]) and (outliers[2,3]<=outliers[2,2])) then smallest:=3;


           {replace the smallest sd}
           outliers[0,smallest]:=i*factor;{store x}
           outliers[1,smallest]:=j*factor;{store y}
           outliers[2,smallest]:=SD;{store sd}
         end;
       end;

       except
         beep;
       end;
     end ;{for loop}

    if nr_images<6 then memo2_message('Warning, not enough images for reliable outlier detection');
    if outliers[2,0]<>0 then memo2_message('Found star 1 with magnitude variation. σ = '+ floattostr6(outliers[2,0])+' at x=' +inttostr(round(outliers[0,0]))+', y='+inttostr(round(outliers[1,0]))+'. Marked with yellow circle.');
    if outliers[2,1]<>0 then memo2_message('Found star 2 with magnitude variation. σ = '+ floattostr6(outliers[2,1])+' at x=' +inttostr(round(outliers[0,1]))+', y='+inttostr(round(outliers[1,1]))+'. Marked with yellow circle.' );
    if outliers[2,2]<>0 then memo2_message('Found star 3 with magnitude variation. σ = '+ floattostr6(outliers[2,2])+' at x=' +inttostr(round(outliers[0,2]))+', y='+inttostr(round(outliers[1,2]))+'. Marked with yellow circle.' );
    if outliers[2,3]<>0 then memo2_message('Found star 4 with magnitude variation. σ = '+ floattostr6(outliers[2,3])+' at x=' +inttostr(round(outliers[0,3]))+', y='+inttostr(round(outliers[1,3]))+'. Marked with yellow circle.' );
  end;

//  stars:=nil;
  stars_sd:=nil;
  stars_mean:=nil;
  stars_count:=nil;
end;


procedure Tstackmenu1.photometry_button1Click(Sender: TObject);
var
  Save_Cursor          : TCursor;
  magn,hfd1,star_fwhm,snr,flux,xc,yc,madVar,madCheck,madThree,medianVar,medianCheck,medianThree,backgr,hfd_med,apert,annul,
  rax1,decx1,rax2,decx2,rax3,decx3,xn,yn                                                     : double;
  saturation_level                                                                           : single;
  c,i,x_new,y_new,fitsX,fitsY,col,first_image,size,starX,starY,stepnr,countVar, countCheck,countThree : integer;
  flipvertical,fliphorizontal,init,refresh_solutions,analysedP,store_annotated, warned  :boolean;
  starlistx : star_list;
  starVar, starCheck,starThree : array of double;
  outliers : array of array of double;
  astr  : string;

  function measure_star(deX,deY :double): string;{measure position and flux}
  var
    starX,starY :double;
  begin
    HFD(img_loaded,round(deX-1),round(deY-1),annulus_radius {14, annulus radius},flux_aperture, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
    if ((hfd1<50) and (hfd1>0) and (snr>6)) then {star detected in img_loaded}
    begin
      if head.calstat='' then saturation_level:=64000 else saturation_level:=60000; {could be dark subtracted changing the saturation level}
      if ((img_loaded[0,round(xc),round(yc)]<saturation_level) and
          (img_loaded[0,round(xc-1),round(yc)]<saturation_level) and
          (img_loaded[0,round(xc+1),round(yc)]<saturation_level) and
          (img_loaded[0,round(xc),round(yc-1)]<saturation_level) and
          (img_loaded[0,round(xc),round(yc+1)]<saturation_level) and

          (img_loaded[0,round(xc-1),round(yc-1)]<saturation_level) and
          (img_loaded[0,round(xc-1),round(yc+1)]<saturation_level) and
          (img_loaded[0,round(xc+1),round(yc-1)]<saturation_level) and
          (img_loaded[0,round(xc+1),round(yc+1)]<saturation_level)  ) then {not saturated star}
      begin
        magn:=starlistpack[c].flux_magn_offset - ln(flux)*2.511886432/ln(10);
        result:=floattostrf(magn, ffFixed, 5,3); {write measured magnitude to list}
//        mainwindow.image1.Canvas.textout(round(dex)+40,round(dey)+20,'hhhhhhhhhhhhhhh'+floattostrf(magn, ffgeneral, 3,3) );
//        mainwindow.image1.Canvas.textout(round(dex)+20,round(dey)+20,'decX,Y '+floattostrf(deX, ffgeneral, 3,3)+','+floattostrf(deY, ffgeneral, 3,3)+'  Xc,Yc '+floattostrf(xc, ffgeneral, 3,3)+','+floattostrf(yc, ffgeneral, 3,3));
//        memo2_message(filename2+'decX,Y '+floattostrf(deX, ffgeneral, 4,4)+', '+floattostrf(deY, ffgeneral, 4,4)+'  Xc,Yc '+floattostrf(xc, ffgeneral, 4,4)+', '+floattostrf(yc, ffgeneral, 4,4)+'    '+result+  '  deltas:'  + floattostrf(deX-xc, ffgeneral, 4,4)+',' + floattostrf(deY-yc, ffgeneral, 4,4)+'offset '+floattostrf(starlistpack[c].flux_magn_offset, ffgeneral, 6,6)+'fluxlog '+floattostrf(ln(flux)*2.511886432/ln(10), ffgeneral, 6,6) );

//        if Flipvertical=false then  starY:=(head.height-yc) else starY:=(yc);
//        if Fliphorizontal     then starX:=(head.width-xc)  else starX:=(xc);
//        if flux_aperture<99 {<>max setting}then
//        begin
//          mainwindow.image1.Canvas.Pen.style:=psSolid;
//          mainwindow.image1.canvas.ellipse(round(starX-flux_aperture-1),round(starY-flux_aperture-1),round(starX+flux_aperture+1),round(starY+flux_aperture+1));{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
//        end;
//        mainwindow.image1.canvas.ellipse(round(starX-annulus_radius),round(starY-annulus_radius),round(starX+annulus_radius),round(starY+annulus_radius));{three pixels, 1,2,3}
//        mainwindow.image1.canvas.ellipse(round(starX-annulus_radius-4),round(starY-annulus_radius-4),round(starX+annulus_radius+4),round(starY+annulus_radius+4));
      end
      else result:='Saturated';
     end
    else
    result:='?';
  end;

  procedure plot_annulus(x,y: integer); {plot the aperture and annulus}
  begin
    if Flipvertical=false then  starY:=(head.height-y) else starY:=(y);
    if Fliphorizontal     then starX:=(head.width-x)  else starX:=(x);
    if flux_aperture<99 {<>max setting}then
    begin
      mainwindow.image1.Canvas.Pen.style:=psSolid;
      mainwindow.image1.canvas.ellipse(round(starX-flux_aperture-1),round(starY-flux_aperture-1),round(starX+flux_aperture+1),round(starY+flux_aperture+1));{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
    end;
    mainwindow.image1.canvas.ellipse(round(starX-annulus_radius),round(starY-annulus_radius),round(starX+annulus_radius),round(starY+annulus_radius));{three pixels, 1,2,3}
    mainwindow.image1.canvas.ellipse(round(starX-annulus_radius-4),round(starY-annulus_radius-4),round(starX+annulus_radius+4),round(starY+annulus_radius+4));
  end;

  procedure plot_outliers;{plot up to 4 yellow circles around the outliers}
  var k: integer;
  begin
    mainwindow.image1.Canvas.Pen.Color := clyellow;
    for k:=0 to length(outliers[0])-1 do
    begin
      if flipvertical=false then  starY:=round(head.height-(outliers[1,k])) else starY:=round(outliers[1,k]);
      if Fliphorizontal     then starX:=round(head.width-outliers[0,k])  else starX:=round(outliers[0,k]);
      mainwindow.image1.Canvas.ellipse(starX-20,starY-20, starX+20, starY+20);{indicate outlier rectangle}
      mainwindow.image1.Canvas.textout(starX+20,starY+20,'σ '+floattostrf(outliers[2,i], ffgeneral, 3,0));{add hfd as text}
    end;
  end;


  procedure nil_all;
  begin
    img_temp:=nil;{free memory}
    starlistx:=nil;{free memory}
    starlistpack:=nil; {release memory}
    outliers:=nil;
    starCheck:=nil;
    starThree:=nil;
    header_backup:=nil;
    Screen.Cursor :=Save_Cursor;{back to normal }
  end;

begin
  if listview7.items.count<=0 then exit; {no files}
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  save_settings2;{too many lost selected files . so first save settings}

  if ((pos('V',star_database1.text)=0) and (pos('v',star_database1.text)=0)) then
  memo2_message(star_database1.text +' used  █ █ █ █ █ █ Warning, select a V database for accurate Johnson-V magnitudes !!! See tab alignment. █ █ █ █ █ █ ');

  {check is analyse is done}
  analysedP:=true;
  for c:=0 to listview7.items.count-1 do
  begin
   if ((listview7.Items.item[c].checked) and (listview7.Items.item[c].subitems.Strings[B_width]='' {width})) then analysedP:=false;
  end;
  if analysedP=false then stackmenu1.analysephotometry1Click(nil);
  application.processmessages;{show result}

  flipvertical:=mainwindow.flip_vertical1.Checked;
  fliphorizontal:=mainwindow.flip_horizontal1.Checked;
  apert:=strtofloat2(flux_aperture1.text);
  aperture_ratio:=apert;{remember apert setting}
  annul:=strtofloat2(annulus_radius1.text);


  esc_pressed:=false;
  warned:=false;

  memo2_message('Checking for astrometric solutions in FITS header required for star flux calibration against star database.');

  refresh_solutions:=(sender=stackmenu1.refresh_astrometric_solutions1); {refresh astrometric solutions}

  {solve lights first to allow flux to magnitude calibration}
  for c:=0 to listview7.items.count-1 do {check for astrometric solutions}
  begin
    if ((esc_pressed=false) and (listview7.Items.item[c].checked) and (listview7.Items.item[c].subitems.Strings[P_astrometric]=''))  then
    begin
      filename2:=listview7.items[c].caption;
      mainwindow.caption:=filename2;

      Application.ProcessMessages;

      {load image}
      if ((esc_pressed) or (load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded)=false)) then
      begin
        nil_all;{nil all arrays and restore cursor}
        exit;
      end;
      if ((head.cd1_1=0) or (refresh_solutions)) then
      begin
        listview7.Selected :=nil; {remove any selection}
        listview7.ItemIndex := c;{mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview7.Items[c].MakeVisible(False);{scroll to selected item}
        memo2_message(filename2+ ' Adding astrometric solution to files to allow flux to magnitude calibration using the star database.');
        Application.ProcessMessages;

        if solve_image(img_loaded,true  {get hist}) then
        begin{match between loaded image and star database}
          if savefits_update_header(filename2)=false then begin ShowMessage('Write error !!' + filename2); Screen.Cursor := Save_Cursor; exit;end;
          listview7.Items.item[c].subitems.Strings[P_astrometric]:='✓';
        end
        else
        begin
          listview7.Items[c].Checked:=false;
          listview7.Items.item[c].subitems.Strings[P_astrometric]:='';
          memo2_message(filename2+ 'Uncheck, no astrometric solution found for this file. Can'+#39+'t measure magnitude!');
        end;
      end
      else
      begin
        listview7.Items.item[c].subitems.Strings[P_astrometric]:='✓';
      end;
    end;{check for astrometric solutions}
  end;{for loop for astrometric solving }
  {astrometric calibration}

  if ((refresh_solutions) or (esc_pressed{stop} )) then
  begin
    Screen.Cursor :=Save_Cursor;{back to normal }
    if refresh_solutions then memo2_message('Ready') else
      memo2_message('Stopped, ESC pressed.');
    exit;
  end;

  first_image:=-1;
  outliers:=nil;
  stepnr:=0;
  init:=false;

  setlength(starlistpack ,listview7.items.count);{to store found stars for each image. Used for finding outliers}
  for c:=0 to listview7.items.count-1 do starlistpack[c].height:=0;{use as marker for filled}

  memo2_message('Click on variable, Check and 3 stars(pink marker) to record magnitudes in the photometry list.');
  repeat
    setlength(starVar,listview7.items.count);
    setlength(starCheck,listview7.items.count);{number of stars could fluctuate so set maximum space each loop}
    setlength(starThree,listview7.items.count);
    countVar:=0;
    countCheck:=0;
    countThree:=0;
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

        if starlistpack=nil then
        begin
          nil_all;
          exit;
        end;

        {load image}
        if ((esc_pressed) or (load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded)=false)) then
        begin
           esc_pressed:=true;
           nil_all;
           exit;
        end;

        use_histogram(img_loaded,true {update}); {plot histogram, set sliders}

        if ((stepnr=1) and ((pos('F',head.calstat)=0) or (head.naxis3>1)) ) then
        begin
          if warned=false then
          begin
            if pos('F',head.calstat)=0 then memo2_message('█ █ █ █ █ █ Warning: Image not calibrated with a flat field (keyword CALSTAT). Absolute photometric accuracy will be lower. Calibrate images first using "calibrate only" option in stack menu. █ █ █ █ █ █');
            if head.naxis3>1 then memo2_message('█ █ █ █ █ █ Warning: Colour image!! Absolute photometric accuracy will be lower. Process only raw images. Set bayer pattern correctly in tab "Stack method" and extract the green pixels in tab photometry. █ █ █ █ █ █')
          end;
          warned:=true;{only one message}
          listview7.Items.item[c].subitems.Strings[P_photometric]:='Poor';
        end
        else
        begin
          listview7.Items.item[c].subitems.Strings[P_photometric]:='✓';
        end;

        if starlistpack=nil then  {should not happen but it happens?}
        begin
          nil_all;
          exit;
        end;
        if  starlistpack[c].height=0 then {not filled with data}
        begin
          if apert<>0 then {aperture<>auto}
          begin
            analyse_image(img_loaded,30,false {report}, hfd_counter,backgr,hfd_med); {find background, number of stars, median HFD}
            if hfd_med<>0 then
            begin
              flux_aperture:=hfd_med*apert/2;{radius}
              annulus_radius:=min(50,round(hfd_med*annul/2)-1);{radius   -rs ..0..+rs, Limit to 50 to prevent runtime errors}
            end
            else flux_aperture:=99;{radius for measuring aperture}
          end
          else{auto}
          begin
            flux_aperture:=99;{radius for measuring using a small aperture}
            annulus_radius:=14;{annulus radius}
          end;

          {calibrate using POINT SOURCE calibration using hfd_med found earlier!!!}
          plot_and_measure_stars(true {calibration},false {plot stars},false{report lim magnitude}); {get flux_magn_offset}

          if flux_magn_offset<>0 then
          begin
            measure_magnitudes(annulus_radius,false {deep},starlistx); {analyse}
            starlistpack[c].starlist:=starlistX;{store found stars in memory for finding outlier later}
            starlistpack[c].width:=head.width;
            starlistpack[c].height:=head.height;
            starlistpack[c].flux_magn_offset:=flux_magn_offset;
          end
          else
          starlistpack[c].height:=0; {mark as not valid measurement}
        end;


        setlength(img_temp,head.naxis3,head.width,head.height);{new size}

        {standard alligned blink}
        if init=false then {init}
        begin
          initialise_var1;{set variables correct for astrometric solution calculation. Use first files as reference}
          init:=true;
        end;

        if first_image=c then
        begin
          head_ref:=head;{backup solution for deepsky annotation}
          sensor_coordinates_to_celestial(shape_fitsX2,shape_fitsY2,{var}   rax2,decx2 {position});
          name_check_iau:=prepare_IAU_designation(rax2,decx2);

          sensor_coordinates_to_celestial(shape_fitsX,shape_fitsY,rax1,decx1 {fitsX, Y to ra,dec});
          sensor_coordinates_to_celestial(shape_fitsX3,shape_fitsY3,rax3,decx3 {fitsX, Y to ra,dec});
        end;



        mainwindow.image1.Canvas.Pen.Mode := pmMerge;
        mainwindow.image1.Canvas.Pen.width :=1;{thickness lines}
        mainwindow.image1.Canvas.Pen.Color := clRed;
        mainwindow.image1.Canvas.Pen.Cosmetic:= false; {gives better dotted lines}

        mainwindow.image1.Canvas.brush.Style:=bsClear;
        mainwindow.image1.Canvas.font.color:=clyellow;
        mainwindow.image1.Canvas.font.size:=10; //round(max(10,8*head.height/image1.height));{adapt font to image dimensions}

        {measure the three stars selected by the mouse in the ORIGINAL IMAGE}
         listview7.Items.item[c].subitems.Strings[P_magn1]:=''; {MAGN, always blank}
        listview7.Items.item[c].subitems.Strings[P_magn2]:=''; {MAGN, always blank}
        listview7.Items.item[c].subitems.Strings[P_magn3]:=''; {MAGN, always blank}

        if starlistpack[c].flux_magn_offset<>0 then {valid flux calibration}
        begin
          if mainwindow.shape_alignment_marker1.visible then
          begin
            mainwindow.image1.Canvas.Pen.Color := clRed;
            celestial_to_pixel(rax1,decx1, xn,yn); {ra,dec to fitsX,fitsY}
            astr:=measure_star(xn,yn); {var star}
            listview7.Items.item[c].subitems.Strings[P_magn1]:=astr;
            listview7.Items.item[c].subitems.Strings[P_snr]:=inttostr(round(snr));
            if ((astr<>'?') and (copy(astr,1,1)<>'S')) then {Good star detected}
            begin
              starVar[countVar]:=strtofloat2(astr);
              inc(countVar);
            end;
          end;

          if mainwindow.shape_alignment_marker2.visible then
          begin
            mainwindow.image1.Canvas.Pen.Color := clGreen;

            celestial_to_pixel(rax2,decx2, xn,yn); {ra,dec to fitsX,fitsY}
            astr:=measure_star(xn,yn); {chk}
            listview7.Items.item[c].subitems.Strings[P_magn2]:=astr;
            if ((astr<>'?') and (copy(astr,1,1)<>'S')) then {Good star detected}
            begin
              starCheck[countCheck]:=strtofloat2(astr);
              inc(countCheck);
            end;

          end;
          if mainwindow.shape_alignment_marker3.visible then
          begin
            mainwindow.image1.Canvas.Pen.Color := clAqua; {star 3}

            celestial_to_pixel(rax3,decx3, xn,yn); {ra,dec to fitsX,fitsY}
            astr:=measure_star(xn,yn); {star3}
            listview7.Items.item[c].subitems.Strings[P_magn3]:=astr;
            if ((astr<>'?') and (copy(astr,1,1)<>'S')) then {Good star detected}
            begin
              starThree[countThree]:=strtofloat2(astr);
              inc(countThree);
            end;
          end;
        end;


        {calculate vectors from astrometric solution to speed up}
        sincos(head.dec0,SIN_dec0,COS_dec0); {do this in advance since it is for each pixel the same}
        astrometric_to_vector;{convert astrometric solution to vectors}

        {shift, rotate to match lights}
        for fitsY:=1 to head.height do
        for fitsX:=1 to head.width  do
        begin
          x_new:=round(solution_vectorX[0]*(fitsx-1)+solution_vectorX[1]*(fitsY-1)+solution_vectorX[2]); {correction x:=aX+bY+c}
          y_new:=round(solution_vectorY[0]*(fitsx-1)+solution_vectorY[1]*(fitsY-1)+solution_vectorY[2]); {correction y:=aX+bY+c}

          if ((x_new>=0) and (x_new<=head.width-1) and (y_new>=0) and (y_new<=head.height-1)) then
             for col:=0 to head.naxis3-1 do {all colors} img_temp[col,x_new,y_new]:=img_loaded[col,fitsX-1,fitsY-1] ;
        end;

        img_loaded:=img_temp;


        {quick and dirty method to correct annotations for aligned lights}
        head.crpix1:=solution_vectorX[0]*(head.crpix1-1)+solution_vectorX[1]*(head.crpix2-1)+solution_vectorX[2];{correct for marker_position at ra_dec position}
        head.crpix2:=solution_vectorY[0]*(head.crpix1-1)+solution_vectorY[1]*(head.crpix2-1)+solution_vectorY[2];

        head.cd1_1:=abs(head.cd1_1)*sign(head_ref.CD1_1);
        head.cd1_2:=abs(head.cd1_2)*sign(head_ref.CD1_2);
        head.cd2_1:=abs(head.cd2_1)*sign(head_ref.CD2_1);
        head.cd2_2:=abs(head.cd2_2)*sign(head_ref.CD2_2);

        store_annotated:=annotated;{store temporary annotated}
        annotated:=false;{prevent annotations are plotted in plot_fits}
        plot_fits(mainwindow.image1,false {re_center},true);
        annotated:=store_annotated;{restore anotated value}
        if ((annotated) and (mainwindow.annotations_visible1.checked)) then
          plot_annotations(true {use solution vectors!!!!},false); {corrected annotations in case a part of the lights are flipped in the alignment routien}

        mainwindow.image1.Canvas.Pen.Mode := pmMerge;
        mainwindow.image1.Canvas.Pen.width :=1;{thickness lines}
        mainwindow.image1.Canvas.Pen.Cosmetic:= false; {gives better dotted lines}

        mainwindow.image1.Canvas.brush.Style:=bsClear;
        mainwindow.image1.Canvas.font.color:=clyellow;
        mainwindow.image1.Canvas.font.size:=10; //round(max(10,8*head.height/image1.height));{adapt font to image dimensions}


        {plot the aperture and annulus}
        if starlistpack[c].flux_magn_offset<>0 then {valid flux calibration}
        begin
          if mainwindow.shape_alignment_marker1.visible then
          begin
            mainwindow.image1.Canvas.Pen.Color := clRed;
            plot_annulus(round(shape_fitsX),round(shape_fitsY));
          end;

          if mainwindow.shape_alignment_marker2.visible then
          begin
            mainwindow.image1.Canvas.Pen.Color := clGreen;
            plot_annulus(round(shape_fitsX2),round(shape_fitsY2));
          end;
          if mainwindow.shape_alignment_marker3.visible then
          begin
            mainwindow.image1.Canvas.Pen.Color := clAqua; {star 3}
            plot_annulus(round(shape_fitsX3),round(shape_fitsY3));
          end;
        end;


        mainwindow.image1.Canvas.Pen.width :=round(1+head.height/mainwindow.image1.height);{thickness lines}
        mainwindow.image1.Canvas.Pen.style:=psSolid;
        mainwindow.image1.Canvas.Pen.Color := $000050; {dark red}
        if starlistpack[c].height<>0 then {valid measurement}
        for i:=0 to  length(starlistpack[c].starlist[0])-2 do
        begin
          size:=round(5*starlistpack[c].starlist[2,i]);{5*hfd}
          x_new:=round(solution_vectorX[0]*(starlistpack[c].starlist[0,i])+solution_vectorX[1]*(starlistpack[c].starlist[1,i])+solution_vectorX[2]); {correction x:=aX+bY+c}
          y_new:=round(solution_vectorY[0]*(starlistpack[c].starlist[0,i])+solution_vectorY[1]*(starlistpack[c].starlist[1,i])+solution_vectorY[2]); {correction y:=aX+bY+c}

          if flipvertical=false then  starY:=(head.height-y_new) else starY:=(y_new);
          if Fliphorizontal     then starX:=(head.width-x_new)  else starX:=(x_new);

          mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
          magn:=starlistpack[c].flux_magn_offset-ln(starlistpack[c].starlist[3,i]{flux})*2.511886432/ln(10);
          mainwindow.image1.Canvas.textout(starX+size,starY-size,floattostrf(magn*10, ffgeneral, 3,0));{add magnitude as text}
        end;{measure marked stars}


        {plot outliers (variable stars)}
        if outliers<>nil then plot_outliers;

        if checkBox_annotate1.checked then
        begin
          load_variable; { Load the database once. If loaded no action}
          head:=head_ref;{restore solution from reference image}
         // restore_solution(false {keep solution});{restore solution from reference image}
          plot_deepsky;  {plot the deep sky object on the image}
        end;
      end;{find star magnitudes}
    end;
    if ((stepnr=1) and (countvar>4)) then {do it once after one cycle finished}
    begin
      find_star_outliers(strtofloat2(mark_outliers_upto1.text), outliers);
      fits_file:=true;{Previous instruction will set fits:=false while it only loads header. Set back to true to allow to set the three measure markers. The displayed image array and header will be compatible}
      if outliers<>nil then plot_outliers;
    end;

    {do statistics}
    if countVar>=4 then
    begin
      mad_median(starVar,countVar{length},{var}madVar,medianVar);{calculate mad and median without modifying the data}
      memo2_message('Var star, median: '+floattostrf(medianVar, ffgeneral, 4,4)+', σ: '+floattostrf(1.4826*madVar  {1.0*sigma}, ffgeneral, 4,4));
    end
    else
    madVar:=0;

    if countCheck>=4 then
    begin
      mad_median(starCheck,countCheck{counter},{var}madCheck,medianCheck);{calculate mad and median without modifying the data}
      memo2_message('Check star, median: '+floattostrf(medianCheck, ffgeneral, 4,4)+', σ: '+floattostrf(1.4826*madCheck  {1.0*sigma}, ffgeneral, 4,4));
    end
    else
    madCheck:=0;
    if countThree>4 then
    begin
      mad_median(starThree,countThree{counter},{var}madThree,medianThree);{calculate mad and median without modifying the data}
      memo2_message('3 star, median: '+floattostrf(medianThree, ffgeneral, 4,4)+', σ: '+floattostrf(1.4826*madThree  {1.0*sigma}, ffgeneral, 4,4));
    end
    else madThree:=0;

    photometry_stdev:=madCheck*1.4826;{mad to standard deviation}

    plot_graph; {aavso report}
  until ((esc_pressed) or (sender<>photometry_repeat1 {single run}));

  nil_all;{nil all arrays and restore cursor}
end;


procedure Tstackmenu1.saturation_tolerance1Change(Sender: TObject);
begin
  stackmenu1.rainbow_panel1.refresh;{plot colour disk in on paint event. Onpaint is required for MacOS}
end;


procedure Tstackmenu1.save_settings_extra_button1Click(Sender: TObject);
begin
  save_settings2;{too many lost selected files . so first save settings}
end;




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

  if ((x1-rs-4<=0) or (x1+rs+4>=head.width-1) or
      (y1-rs-4<=0) or (y1+rs+4>=head.height-1) )
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
            color[col] :=color[col]+   img[col,x2,y2]-bg[col];{if written in separate term it would be 20% faster but having fixed steps}

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


procedure smart_colour_smooth( var img: image_array; wide, sd:double; preserve_r_nebula,measurehist:boolean);{Bright star colour smooth. Combine color values of wide x wide pixels, keep luminance intact}
var fitsX,fitsY,x,y,step,x2,y2,count,width5,height5  : integer;
    img_temp2            : image_array;
    luminance,red,green,blue,rgb,r,g,b,sqr_dist,strongest_colour_local,top,bg,r2,g2,b2,noise_level1, peak,bgR2,bgB2,bgG2,highest_colour  : single;
    bgR,bgB,bgG         : double;
    copydata,red_nebula : boolean;
begin
  if length(img)<3 then exit;{not a three colour image}

  width5:=Length(img[0]);    {width}
  height5:=Length(img[0][0]); {height}

  setlength(img_temp2,3,width5,height5);{set length of image array}

  step:= round(wide) div 2;

  get_background(0,img,measurehist {hist},true  {noise level},{var} bgR,star_level);{calculate red background, noise_level and star_level}
  get_background(1,img,measurehist {hist},false{noise level},{var} bgG,star_level);{calculate green background}
  get_background(2,img,measurehist {hist},false {noise level},{var} bgB,star_level);

  noise_level1:=noise_level[0];{red noise}
  bg:=(bgR+bgG+bgB)/3; {average background}

  for fitsY:=0 to height5-1 do
  for fitsX:=0 to width5-1 do
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


    if ( (r2>sd*noise_level1) or (g2>sd*noise_level1) or (b2>sd*noise_level1) ) then {some relative flux}
    begin
      for y:=-step to step do
        for x:=-step to step do
        begin
           x2:=fitsX+x;
           y2:=fitsY+y;

          if ((x2>=0) and (x2<width5) and (y2>=0) and (y2<height5) ) then {within image}
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

        red:=red/count;{scale using the number of data points=count}
        green:=green/count;
        blue:=blue/count;

        if peak>star_level then {star level very close}
        begin
          highest_colour:=max(r2,max(g2,b2));
          if preserve_r_nebula then
             red_nebula:=((highest_colour=r2) and (r2-(bgR2-bgR)<150){not the star} and (bgR2-bgR>3*noise_level1))
          else
             red_nebula:=false;

          if red_nebula=false then
          begin
            if red<blue*1.06 then{>6000k}
              green:=max(green,0.6604*red+0.3215*blue); {prevent purple stars, purple stars are physical not possible. Emperical formula calculated from colour table http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html}

            luminance:=(r2+g2+b2)/3;
            rgb:=(red+green+blue+0.00001)/3; {0.00001, prevent dividing by zero}
            strongest_colour_local:=max(red,max(green,blue));
            top:=bg+luminance*strongest_colour_local/rgb;{calculate the highest colour value}
            if top>=65534.99 then luminance:=luminance-(top-65534.99)*rgb/strongest_colour_local;{prevent values above 65535}

            img_temp2[0,fitsX  ,  fitsY  ]:=bg+ luminance*red/rgb;
            img_temp2[1,fitsX  ,  fitsY  ]:=bg+ luminance*green/rgb;
            img_temp2[2,fitsX  ,  fitsY  ]:=bg+ luminance*blue/rgb;
            copydata:=false;{data is already copied}

          end;
       end;
     end;
     if copydata then {keep original data but adjust zero level}
     begin
       img_temp2[0,fitsX  ,  fitsY  ]:=max(0,bg+r2);{copy data, but equalise background levels}
       img_temp2[1,fitsX  ,  fitsY  ]:=max(0,bg+g2);
       img_temp2[2,fitsX  ,  fitsY  ]:=max(0,bg+b2);
     end;

  end;
  img:=img_temp2;{copy the array}
  img_temp2:=nil;
end;


procedure green_purple_filter( var img: image_array);{Balances RGB to remove green and purple. For e.g. Hubble palette}
var fitsX,fitsY                : integer;
    r2,g2,b2, lum,ratio        : double;
begin
  if length(img)<3 then exit;{not a three colour image}

  for fitsY:=0 to head.height-1 do
  for fitsX:=0 to head.width-1 do
  begin
    r2:=img[0,fitsX,fitsY];
    g2:=img[1,fitsX,fitsY];
    b2:=img[2,fitsX,fitsY];


    if ((g2>r2) and (g2>b2)) then
    begin
      lum:=r2+g2+b2;
      if r2>=b2 then {red stronger then blue}
      begin
        ratio:=min(r2/max(b2,0.001),30);
        r2:=lum*ratio/(ratio+ratio+1);
        g2:=r2;
        b2:=lum*1/(ratio+ratio+1)
      end
      else
      begin {blue stronger then red}
        ratio:=min(b2/max(r2,0.001),30);
        b2:=lum*ratio/(ratio+ratio+1);
        g2:=b2;
        r2:=lum*1/(ratio+ratio+1)
      end;
      img[0,fitsX,fitsY]:=r2;
      img[1,fitsX,fitsY]:=g2;
      img[2,fitsX,fitsY]:=b2;
    end;


    if ((g2<r2) and (g2<b2)) then  {to weak green, purple background}
    begin
      lum:=r2+g2+b2;
      if r2>=b2 then {red stronger then blue}
      begin
        ratio:=min(r2/max(b2,0.001),30);
        r2:=lum/(1+1+ratio);
        g2:=r2;
        b2:=lum*ratio/(1+1+ratio);
      end
      else
      begin {blue stronger then red}
       ratio:=min(b2/max(r2,0.001),30);
        b2:=lum/(1+1+ratio);
        g2:=b2;
        r2:=lum*ratio/(1+1+ratio);
      end;
      img[0,fitsX,fitsY]:=r2;
      img[1,fitsX,fitsY]:=g2;
      img[2,fitsX,fitsY]:=b2;
    end;
  end;
end;


procedure Tstackmenu1.smart_colour_smooth_button1Click(Sender: TObject);
var
  Save_Cursor:TCursor;
begin
  if Length(img_loaded)<3 then
  begin
    memo2_message('Error, no three colour image loaded!');
    exit;
  end;
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  backup_img;

  smart_colour_smooth(img_loaded, strtofloat2(smart_smooth_width1.text),strtofloat2(smart_colour_sd1.text),preserve_red_nebula1.checked,false);

  plot_fits(mainwindow.image1,false,true);{plot real}

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
     apply_most_common(img_backup[index_backup].img,img_loaded,radius); {apply most common filter on first array and place result in second array}
     plot_fits(mainwindow.image1,true,true);{plot real}
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


procedure Tstackmenu1.list_to_clipboard1Click(Sender: TObject); {copy seleced lines to clipboard}
var
  index,c : integer;
  info : string;
  lv  : tlistview;
begin
  info:='';
  if sender=list_to_clipboard9 then lv:=listview9
  else
  if sender=list_to_clipboard8 then lv:=listview8
  else
  if sender=list_to_clipboard7 then lv:=listview7
  else
  if sender=list_to_clipboard6 then lv:=listview6
  else
  if sender=list_to_clipboard1 then lv:=listview1
  else
  begin
    beep;
    exit;
  end;

  {get column names}
  for c := 0 to lv.Items[0].SubItems.Count-1 do
  try
    info:=info+lv.columns[c].caption+#9;
  except
    info:=info+'Error'+#9;
  end;
  info:=info+slinebreak;

  {get data}
  for index:=0 to lv.items.count-1 do
  begin
    if  lv.Items[index].Selected then
    begin
      info:=info+lv.items[index].caption;
      {get sub items}
      for c := 0 to lv.Items[index].SubItems.Count - 1 do
      try
        info:=info+#9+lv.Items.item[index].subitems.Strings[c];
      except
        info:=info+#9+'Error';
      end;
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
end;

procedure Tstackmenu1.selectall1Click(Sender: TObject);
begin
  if sender=selectall1 then begin listview1.selectall; listview1.setfocus;{set focus for next ctrl-C. Somehow it is lost}  end;
  if sender=selectall2 then begin listview2.selectall; listview2.setfocus; end;
  if sender=selectall3 then begin listview3.selectall; listview3.setfocus; end;
  if sender=selectall4 then begin listview4.selectall; listview4.setfocus; end;
  if sender=selectall5 then begin listview5.selectall; listview5.setfocus; end;

  if sender=selectall6 then begin listview6.selectall; listview6.setfocus; end;
  if sender=selectall7 then begin listview7.selectall; listview7.setfocus; end;
  if sender=selectall8 then begin listview8.selectall; listview8.setfocus; end;
  if sender=selectall9 then begin listview9.selectall; listview9.setfocus; end;
end;

procedure remove_background( var img: image_array);
var fitsX,fitsY        : integer;
    luminance,red,green,blue : double;
begin
  if length(img)<3 then exit;{not a three colour image}

  for fitsY:=2 to head.height-1-2 do
    for fitsX:=2 to head.width-1-2 do
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
   background_r,background_g,background_b, red,green,blue,signal_R,signal_G,signal_B,sigma,lumn : double;
begin
  if head.naxis3<3 then exit;{prevent run time error mono lights}
//  if fits_file=false then exit;
  Save_Cursor := Screen.Cursor;
  Screen.Cursor:= crHourGlass;

  backup_img;

  sigma:=strtofloat2(sigma_decolour1.text);{standard deviation factor used}

  get_background(1,img_loaded,true {hist},true {noise level},{var}background_G, star_level);{calculate background and noise_level}
  get_background(2,img_loaded,true {hist},true {noise level}, {var}background_B, star_level);{calculate background and noise_level}
  {red at last since all brigthness/contrast display is based on red}
  get_background(0,img_loaded,true {hist},true {noise level}, {var}background_R, star_level);{calculate background and noise_level}



  for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1 do
    begin
        red:=img_loaded[0,fitsX,fitsY];
        green:=img_loaded[1,fitsX,fitsY];
        blue:=img_loaded[2,fitsX,fitsY];

        if ((red-background_r<sigma*noise_level[0]) and (green-background_G<sigma*noise_level[1]) and (blue-background_B<sigma*noise_level[2])) then {low luminance signal}
        begin {distribute the colour to luminance}
          signal_R:=red-background_R;
          signal_G:=green-background_G;
          signal_B:=blue-background_B;
          lumn:=(signal_R+signal_G+signal_B)/3;{make mono}
          red:=background_r+lumn;
          green:=background_G+lumn;
          blue:=background_B+lumn;
        end;
        img_loaded[0,fitsX  ,  fitsY  ]:=red;
        img_loaded[1,fitsX  ,  fitsY  ]:=green;
        img_loaded[2,fitsX  ,  fitsY  ]:=blue;
     end;
   plot_fits(mainwindow.image1,false,true);{plot}
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


procedure Tstackmenu1.solve_and_annotate1Change(Sender: TObject);
begin
 update_annotation1.enabled:=solve_and_annotate1.checked;{update menu}
end;

procedure Tstackmenu1.SpeedButton2Click(Sender: TObject);
begin
  lat_default:=InputBox('Default observer location:','Enter the default observer latitude in degrees [DD.DDD or DD MM]',lat_default );
  long_default:=InputBox('Default observer location:','Enter the default observer longitude in degrees. East is positive, West is negative [DDD.DDD or DD MM]',long_default );
  if length(long_default)>0 then save_settings2;
end;


procedure Tstackmenu1.star_database1DropDown(Sender: TObject);
var
  SearchRec: TSearchRec;
  s        : string;
begin
  with stackmenu1 do
  begin
    star_database1.items.clear;
    if FindFirst(database_path+'*0101.*', faAnyFile, SearchRec)=0 then
    begin
      repeat
        s:=uppercase(copy(searchrec.name,1,3));
        star_database1.items.add(s);
      until FindNext(SearchRec) <> 0;
    end;
    FindClose(SearchRec);
    star_database1.items.add('auto');
  end;
  flux_magn_offset:=0;{reset flux calibration. Required if V17 is selected instead of H17}
end;



procedure Tstackmenu1.apply_box_filter2Click(Sender: TObject);
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

  box_blur(1 {nr of colors},2,img_loaded);

  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,false,true);{plot real}

  Screen.Cursor:=Save_Cursor;
end;


procedure Tstackmenu1.test_osc_normalise_filter1Click(Sender: TObject);
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

  normalize_OSC_flat(img_loaded);

  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,false,true);{plot real}

  Screen.Cursor:=Save_Cursor;
end;


procedure Tstackmenu1.analyseblink1Click(Sender: TObject);
begin
  analyse_listview(listview6,true {light},false {full fits},false{refresh});
  listview6.alphasort; {sort on time}
end;

procedure Tstackmenu1.browse_monitoring1Click(Sender: TObject);
var
  live_monitor_directory : string;
begin
  if SelectDirectory('Select directory to monitor', monitoring_path1.caption , live_monitor_directory) then
  begin
    monitoring_path1.caption:=live_monitor_directory;{show path}
  end;
end;


procedure Tstackmenu1.equinox1Change(Sender: TObject);
begin
  case equinox1.itemindex of
    0 : listview9.column[9].caption:='α [°] J2000';
    1 : listview9.column[9].caption:='α [°] mean';
  end;
end;


procedure Tstackmenu1.FormDestroy(Sender: TObject);
begin
  bsolutions:=nil;{just to be sure to clean up}
end;

procedure Tstackmenu1.help_monitoring1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#monitoring');
end;


procedure Tstackmenu1.help_mount_tab1Click(Sender: TObject);
begin
   openurl('http://www.hnsky.org/astap.htm#mount_tab');
end;

procedure Tstackmenu1.live_monitoring1Click(Sender: TObject);
begin
  save_settings2;{too many lost selected files . so first save settings}
  esc_pressed:=false;
  live_monitoring1.font.style:=[fsbold,fsunderline];
  Application.ProcessMessages; {process font changes}

  monitoring(monitoring_path1.caption){monitor a directory}
end;

procedure Tstackmenu1.monitoring_stop1Click(Sender: TObject);
begin
  esc_pressed:=true;
  live_monitoring1.font.style:=[];
  Application.ProcessMessages; {process font changes}
end;


procedure Tstackmenu1.lrgb_auto_level1Change(Sender: TObject);
var
   au : boolean;
begin
  au:=lrgb_auto_level1.checked;
  lrgb_colour_smooth1.enabled:=au;
  lrgb_preserve_r_nebula1.enabled:=au;
  lrgb_smart_smooth_width1.enabled:=au;
  lrgb_smart_colour_sd1.enabled:=au;
end;


procedure Tstackmenu1.keywordchangelast1Click(Sender: TObject);
begin
  sqm_key:=uppercase(InputBox('Type header keyword to display in the last column:','',sqm_key ));
  new_analyse_required:=true;
  stackmenu1.listview1.columns.Items[l_sqm+1].caption:=sqm_key;   {lv.items[l_sqm].caption:=sqm_key; doesn't work}
  while length(sqm_key)<8 do sqm_key:=sqm_key+' ';
end;



procedure Tstackmenu1.keywordchangesecondtolast1Click(Sender: TObject);
begin
  centaz_key:=uppercase(InputBox('Type header keyword to display in the second to last column:','',centaz_key ));
  new_analyse_required:=true;
  stackmenu1.listview1.columns.Items[l_centaz+1].caption:=centaz_key;   {lv.items[l_sqm].caption:=sqm_key; doesn't work}
  while length(centaz_key)<8 do centaz_key:=centaz_key+' ';
end;


{ Calculate the offset in ra, dec from polar error
  input     delta_altitude: elevation error pole
            delta_azimuth : azimuth error pole
            ra1_mount     : ra position mount 1
            dec1_mount    : dec position mount 1
            jd1           : Julian day measurement 1
            ra2_mount     : ra position mount 2
            dec2_mount    : dec position mount 2
            jd2           : Julian day measurement 2
            latitude
            longitude

  output    delta_ra
            delta_dec                             }
procedure polar_error_to_position_error(delta_alt ,delta_az, ra1_mount,dec1_mount,jd1,ra2_mount,dec2_mount,jd2,latitude,longitude: double; out delta_ra,delta_dec : double);
const
  siderealtime2000=(280.46061837)*pi/180;{[radians], sidereal time at 2000 jan 1.5 UT (12 hours) =Jd 2451545 at meridian greenwich, see new Meeus 11.4}
  earth_angular_velocity = pi*2*1.00273790935; {about(365.25+1)/365.25) or better (365.2421874+1)/365.2421874 velocity daily. See new Meeus page 83}
var
  sidereal_time1,sidereal_time2,h_1,h_2 : double;
begin
  sidereal_time1:=fnmodulo(+longitude+siderealtime2000 +(jd1-2451545 )* earth_angular_velocity,2*pi); {As in the FITS header in ASTAP the site longitude is positive if east and has to be added to the time}
  sidereal_time2:=fnmodulo(+longitude+siderealtime2000 +(jd2-2451545 )* earth_angular_velocity,2*pi); {As in the FITS header in ASTAP the site longitude is positive if east and has to be added to the time}

  h_1:=ra1_mount-sidereal_time1;
  h_2:=ra2_mount-sidereal_time2;

  delta_Ra:=delta_alt*(TAN(dec2_mount)*SIN(h_2)-TAN(dec1_mount)*SIN(h_1))  +delta_az*COS(latitude)*(TAN(dec1_mount)*COS(h_1)-TAN(dec2_mount)*COS(h_2));
  delta_Dec:=delta_alt*(COS(h_2)-COS(h_1))  +delta_az*COS(latitude)*(SIN(h_2)-SIN(h_1));
end;


{Polar error calculation based on two celestial reference points and the error of the telescope mount at these point(s).
 Based on formulas from Ralph Pass documented at https://rppass.com/align.pdf.
 They are based on the book “Telescope Control’ by Trueblood and Genet, p.111
 Ralph added sin(latitude) term in the equation for the error in RA.


 For one reference image the difference in RA and DEC caused by the misalignment of the polar axis, formula (3):
   delta_ra:= de * TAN(dec)*SIN(h)  + da * (sin(lat)- COS(lat)*(TAN(dec1)*COS(h_1))
   delta_dec:=de * COS(h)  + da * COS(lat)*SIN(h))

   where de is the polar error in elevation (altitude)
   where da is the polar error in azimuth
   where h is the hour angle of the reference point equal ra - local_sidereal_time

 Using the above formula calculate the difference in RA and DEC by subtracting the first image postion from the second reference image. The common term sin(lat) will be nulified. Formula (4)

 Writing the above formulas in matrix notation:
   [delta_Ra;delta_Dec]= A * [delta_Elv;delta_Azm]
   then
   [delta_Elv;delta_Az] = inv(A)*[delta_Ra;delta_Dec]

 Mount is assumed to be ideal. Mount fabrication error & cone errors are assumed to be zero. Meridian crossing between the two images should be avoided}
procedure polar_error_calc(ra1,dec1,ra1_mount,dec1_mount,jd1,ra2,dec2,ra2_mount,dec2_mount,jd2,latitude,longitude: double; out delta_Elv,delta_az : double);{calculate polar error based on two images. All values in radians}
const
  siderealtime2000=(280.46061837)*pi/180;{[radians], sidereal time at 2000 jan 1.5 UT (12 hours) =Jd 2451545 at meridian greenwich, see new Meeus 11.4}
  earth_angular_velocity = pi*2*1.00273790935; {about(365.25+1)/365.25) or better (365.2421874+1)/365.2421874 velocity daily. See new Meeus page 83}
var
   determinant,delta_ra, delta_dec,sidereal_time1,sidereal_time2,h_1,h_2 : double;
   A,B, C, C_inv : array[0..1,0..1] of double;
begin
  sidereal_time1:=fnmodulo(+longitude+siderealtime2000 +(jd1-2451545 )* earth_angular_velocity,2*pi); {As in the FITS header in ASTAP the site longitude is positive if east and has to be added to the time}
  sidereal_time2:=fnmodulo(+longitude+siderealtime2000 +(jd2-2451545 )* earth_angular_velocity,2*pi); {As in the FITS header in ASTAP the site longitude is positive if east and has to be added to the time}

  memo2_message('Local sidereal time image 1:     '+prepare_ra6(sidereal_time1,' ')); {24 00 00}
  memo2_message('Local sidereal time image 2:     '+prepare_ra6(sidereal_time2,' ')); {24 00 00}

  delta_ra:=(ra2_mount-ra2)- (ra1_mount-ra1);
  delta_dec:=(dec2_mount-dec2)- (dec1_mount-dec1);

  h_1:=ra1_mount-sidereal_time1;
  h_2:=ra2_mount-sidereal_time2;

  // [delta_Ra;delta_Dec]= A * [delta_Elv;delta_Azm]
  // Fill matrix image 1 with data.
  A[0,0]:=TAN(dec1_mount)*SIN(h_1);
//  A[1,0]:=COS(latitude)* ({SIN(LAT_rad)}-TAN(dec1_mount)*COS(h_1)); //sin(lat_rad) will be nulified anyhow when B-A is calculated}
  A[1,0]:={SIN(LAT_rad)}-COS(latitude)*TAN(dec1_mount)*COS(h_1); //sin(lat_rad) will be nulified anyhow when B-A is calculated}

  A[0,1]:=COS(h_1);
  A[1,1]:=COS(latitude)*SIN(h_1);

  // Fill matrix image 2 with data.
  B[0,0]:=TAN(dec2_mount)*SIN(h_2);
//  B[1,0]:=COS(latitude)*({SIN(LAT_rad)}-TAN(dec2_mount)*COS(h_2));  //sin(lat_rad) will be nulified anyhow when B-A is calculated}
  B[1,0]:={SIN(LAT_rad)}-COS(latitude)*TAN(dec2_mount)*COS(h_2); //sin(lat_rad) will be nulified anyhow when B-A is calculated}
  B[0,1]:=COS(h_2);
  B[1,1]:=COS(latitude)*SIN(h_2);

  //difference,  image 2 - image 1
  C[0,0]:=B[0,0]-A[0,0];
  C[1,0]:=B[1,0]-A[1,0];
  C[0,1]:=B[0,1]-A[0,1];
  C[1,1]:=B[1,1]-A[1,1];

  // Calculate the inverse matrix inv(C)
  determinant:=C[0,0]*C[1,1]-C[0,1]*C[1,0];
  C_inv[0,0]:=+C[1,1]/determinant;
  C_inv[1,1]:=+C[0,0]/determinant;
  C_inv[1,0]:=-C[1,0]/determinant;
  C_inv[0,1]:=-C[0,1]/determinant;

  // [delta_Elv;delta_Az] = inv(A)*[delta_Ra;delta_Dec]
  // Use the inverse matrix to calculate the polar axis elevation and azimuth error from the delta_dec and delta_ra between the two image positions.
  delta_Elv:=C_inv[0,0]*delta_ra+C_inv[1,0]*delta_Dec;
  delta_Az:=C_inv[0,1]*delta_ra+C_inv[1,1]*delta_Dec;

  if abs(determinant)<0.1 then
      memo2_message('█ █ █ █ █ █ Warning the calculation determinant is close to zero! Select other celestial locations. Avoid locations with similar hour angles, locations close to the celestial equator and locations whose declinations are close to negatives of each other. █ █ █ █ █ █ ');
end;


procedure Tstackmenu1.calc_polar_alignment_error1Click(Sender: TObject);
var
   c: integer;
   Save_Cursor          : TCursor;
   errordecode          : boolean;
   ra1,dec1,ra1_mount,dec1_mount,jd1,ra2,dec2,ra2_mount,dec2_mount,jd2, delta_alt,delta_az,sep,
   site_long_radians,site_lat_radians                              : double;
   counter                                                         : integer;
   ns,ew                                                           : string;
begin
  memo2_message('Instructions:');
  memo2_message('   1: Synchronise the mount and take one image.');
  memo2_message('   2: Slew the mount to a second point in the sky and take a second image without synchronising the mount.');
  memo2_message('Conditions: The image header should contain the correct time, observer location and mount position. Images should be solvable.');
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  esc_pressed:=false;

  if stackmenu1.equinox1.itemindex=0 then
  begin
    stackmenu1.equinox1.itemindex:=1;{jnow}
    memo2_message('Switched to "Mean equinox of date (in air)" mode. You could switch to "Mean equinox of date (in vacuum)"');
  end;
  stackmenu1.mount_add_solutions1Click(nil);{add any missing solutions and analyse after that}

  counter:=0;
  {solve lights first to allow flux to magnitude calibration}
  with stackmenu1 do
  for c:=0 to listview9.items.count-1 do {check for astrometric solutions}
  begin
    if ((esc_pressed=false) and (listview9.Items.item[c].checked) and (listview9.Items.item[c].subitems.Strings[M_ra]<>''))  then
    begin
      filename2:=listview9.items[c].caption;

      Application.ProcessMessages;

      {load image}
      if esc_pressed then
      begin
        Screen.Cursor :=Save_Cursor;{back to normal }
        exit;
      end;

      if counter=0 then
      begin
        ra1:=strtofloat(listview9.Items.item[c].subitems.Strings[M_ra])*pi/180;
        dec1:=strtofloat(listview9.Items.item[c].subitems.Strings[M_dec])*pi/180;
        ra1_mount:=strtofloat(listview9.Items.item[c].subitems.Strings[M_ra_m])*pi/180;
        dec1_mount:=strtofloat(listview9.Items.item[c].subitems.Strings[M_dec_m])*pi/180;
        jd1:=strtofloat(listview9.Items.item[c].subitems.Strings[M_jd_mid]);
        memo2_message('Image 1: '+filename2);
        inc(counter);
      end
      else
      begin
        ra2:=strtofloat(listview9.Items.item[c].subitems.Strings[M_ra])*pi/180;
        dec2:=strtofloat(listview9.Items.item[c].subitems.Strings[M_dec])*pi/180;
        ra2_mount:=strtofloat(listview9.Items.item[c].subitems.Strings[M_ra_m])*pi/180;
        dec2_mount:=strtofloat(listview9.Items.item[c].subitems.Strings[M_dec_m])*pi/180;
        jd2:=strtofloat(listview9.Items.item[c].subitems.Strings[M_jd_mid]);
        ang_sep(ra1,dec1,ra2,dec2, {out}sep);{calculates angular separation. according formula 9.1 old Meeus or 16.1 new Meeus, version 2018-5-23}
        if sep>5*pi/180 then
        begin
          dec_text_to_radians(sitelat,site_lat_radians,errordecode);
          if errordecode then
          begin
            memo2_message('Warning observatory latitude not found in the fits header');
            exit;
          end;

          dec_text_to_radians(sitelong,site_long_radians,errordecode); {longitude is in degrees, not in hours. East is positive according ESA standard and diffractionlimited}
                                                                       {see https://indico.esa.int/event/124/attachments/711/771/06_ESA-SSA-NEO-RS-0003_1_6_FITS_keyword_requirements_2014-08-01.pdf}
          if errordecode then
          begin
            memo2_message('Warning observatory longitude not found in the fits header');
            exit;
          end;

          memo2_message('Image 2: '+filename2);
          if site_long_radians>0 then ew:=' E' else  ew:=' W';
          if site_lat_radians>0  then ns:=' N' else  ns:=' S';
          memo2_message('Location (rounded) '+inttostr(round(site_lat_radians*180/pi))+ns+'  '+inttostr(round(site_long_radians*180/pi))+ew+'. Angular seperation between the images is '+floattostrF(sep*180/pi,ffFixed,0,1)+'°' );

          polar_error_calc(ra1,dec1,ra1_mount,dec1_mount,jd1,ra2,dec2,ra2_mount,dec2_mount,jd2,site_lat_radians,site_long_radians, {out} delta_alt,delta_az);{calculate polar error based on the solves}
          if delta_alt>0 then ns:=' above the celestial pole' else ns:=' below the celestial pole';
          if delta_az>0 then ew:=' east of the celestial pole.' else ew:=' west of the celestial pole.';
          memo2_message('Polar axis is '+floattostrF(abs(delta_alt)*60*180/pi,ffFixed,0,1)+#39+ns+' and '+floattostrF(abs(delta_az)*60*180/pi,ffFixed,0,1)+#39+ew);
          counter:=0;{restart for next images}
        end
        else
        memo2_message('Skipped image ' +filename2+'. The angular distance between the two images is '+floattostrF(sep*180/pi,ffFixed,0,1)+'°'+' and too small!');
      end;
    end;
  end;
  Screen.Cursor :=Save_Cursor;{back to normal }

  stackmenu1.mount_analyse1Click(nil);{update}
end;


procedure Tstackmenu1.mount_analyse1Click(Sender: TObject);
begin
  save_settings2;{too many lost selected files . so first save settings}
  analyse_listview(listview9,true {light},false {full fits},true{refresh});
  stackmenu1.equinox1Change(nil);{update column}
end;


procedure Tstackmenu1.analysephotometry1Click(Sender: TObject);
begin
  if sender=analysephotometrymore1 then
    analyse_listview(listview7,true {light},true {full fits},true{refresh})
  else
    analyse_listview(listview7,true {light},false {full fits},false{refresh});

  listview7.items.beginupdate;
  listview7.alphasort;{sort on time}
  listview7.items.endupdate;
end;


procedure Tstackmenu1.analyse_inspector1Click(Sender: TObject);
begin
  stackmenu1.memo2.lines.add('Inspector routine using multiple images at different focus positions. This routine will calculate the best focus position of several areas by extrapolation. Usage:');
  stackmenu1.memo2.lines.add('- Browse for a number of short exposure images made at different focuser positions around focus. Use a fixed focuser step size and avoid backlash.');
  stackmenu1.memo2.lines.add('- Press analyse to measure the area hfd values of each image.');
  stackmenu1.memo2.lines.add('- Press curve fitting. The curve fit routine will calculate the best focuser position for each area using the hfd values. The focuser differences from center will indicate tilt & curvature of the image.');
  stackmenu1.memo2.lines.add('');
  stackmenu1.memo2.lines.add('Remarks:');
  stackmenu1.memo2.lines.add('It is possible to make more than one exposure per focuser position, but this number should be the same for each focuser point.');
  stackmenu1.memo2.lines.add('Note that hfd values above about 20 will give  erroneous results. Un-check these files prior to curve fitting. ');
  stackmenu1.memo2.lines.add('');
  memo2_message('Start analysing images');
  analyse_listview(listview8, true {light},true {full fits},false{refresh});

  if listview8.items.count>1 then {prevent run time error if no files are available}
  begin
    listview8.Selected :=nil; {remove any selection}
    listview8.ItemIndex := 0;{mark where we are. }
    listview8.Items[0].MakeVisible(False);{scroll to selected item and fix last red colouring}
    memo2_message('Ready analysing. To copy result, select the rows with ctrl-A and copy the rows with ctrl-C. They can be pasted into a spreadsheet. Press now "curve fitting" to measure tilt and curvature in focuser positions.');
  end;
end;


procedure Tstackmenu1.apply_hue1Click(Sender: TObject);
var fitsX, fitsY,fuzziness :integer;
    r,g,b,h,s,s_new,v,oldhue,newhue,dhue,saturation_factor,v_old1,v_old2,v_old3,s_old,saturation_tol : single;
    Save_Cursor:TCursor;
    colour: tcolor;
    remove_lum : boolean;
begin
  if ((fits_file=false) and (head.naxis3<>3)) then exit;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  backup_img;

  fuzziness:=hue_fuzziness1.position;
  saturation_tol:=saturation_tolerance1.position/100;
  saturation_factor:=new_saturation1.position /100;
  remove_lum:=remove_luminance1.checked;

  colour:=colourShape1.brush.color;
  RGB2HSV(getRvalue(colour),getGvalue(colour),getBvalue(colour),oldhue,s_old,v);
  colour:=colourShape3.brush.color;
  RGB2HSV(getRvalue(colour),getGvalue(colour),getBvalue(colour),newhue,s_new,v);


  if stackmenu1.area_set1.caption<>'✓'  then {no area selected}
  begin
    areax1:=0;
    areay1:=0;
    areax2:=head.width-1;
    areaY2:=head.height-1;
  end;
  {else set in astap_main}

  v_old1:=0;
  v_old2:=0;
  v_old3:=0;
  for fitsY:=areay1 to areay2 do
    for fitsX:=areax1 to areax2 do
    begin {subtract view from file}
      RGB2HSV(max(0,img_loaded[0,fitsX,fitsY]-cblack),
              max(0,img_loaded[1,fitsX,fitsY]-cblack),
              max(0,img_loaded[2,fitsX,fitsY]-cblack), h,s,v); {RGB to HSVB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}

      dhue:=abs(oldhue - h);
      if (((dhue<=fuzziness) or (dhue>=360-fuzziness))and (abs(s-s_old)<saturation_tol {saturation speed_tolerance1} )) then {colour close enough, replace colour}
      begin
          if remove_lum then v:=min(min(v_old1,v_old2),v_old3);{take the lowest value}
          HSV2RGB(newhue , min(1,s_new*saturation_factor) {s 0..1}, v {v 0..1},r,g,b); {HSV to RGB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}

          img_loaded[0,fitsX,fitsY]:=r +cblack;
          img_loaded[1,fitsX,fitsY]:=g +cblack;
          img_loaded[2,fitsX,fitsY]:=b +cblack;
      end
      else
      begin
        v_old3:=v_old2;
        v_old2:=v_old1;
        v_old1:=v;
      end;
    end;
  //use_histogram(0);
  plot_fits(mainwindow.image1,false,true);{plot real}

  HueRadioButton1.checked:=false;
  HueRadioButton2.checked:=false;
  Screen.Cursor:=Save_Cursor;
end;


procedure Tstackmenu1.auto_background_level1Click(Sender: TObject);
var
    r,g,b,star_levelR, star_levelG,star_levelB : double;
begin
  if length(img_loaded)<3 then exit;{not a three colour image}

  apply_factor1.enabled:=false;{block apply button temporary}
  application.processmessages;

  get_background(1,img_loaded,true {get hist},true {get noise},{var} G,star_levelG);
  get_background(2,img_loaded,true {get hist},true {get noise},{var} B,star_levelB);
  {Do red last to maintain current histogram}
  get_background(0,img_loaded,true {get hist},true {get noise},{var} R,star_levelR);

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
  setlength(img_outliers,head.naxis3,head.width,head.height);{set length of image array mono}

  for col:=0 to head.naxis3-1 do {do all colours}
  begin

    {first estimate of background mean and sd, star will be included}
    average1:=0;
    count:=0;
    For fitsY:=0 to (head.height-1) div step do
      for fitsX:=0 to (head.width-1) div step do
      begin
         val:=img[col,fitsX * step,fitsY * step];
         if val<32000 then average1:=average1+val;
         inc(count);
      end;
    average1:=average1/count;

    sd1:=0;
    count:=0;
    For fitsY:=0 to (head.height-1) div step do
    for fitsX:=0 to (head.width-1) div step do
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
    For fitsY:=0 to head.height-1  do
    for fitsX:=0 to head.width-1 do
    begin
      val:=img[col,fitsX,fitsY];
      if val<average1+5*sd1 then average:=average+val;
      inc(count);
    end;

    average:=average/count;
    For fitsY:=0 to head.height-1 do
      for fitsX:=0 to head.width-1 do
      begin
        val:=img[col,fitsX,fitsY];
        if val<average1+5*sd1 then sd:=sd+sqr(average-val);
        inc(count);
      end;
    sd:=sqrt(sd/(count)); {standard deviation}
    maxoffs:=max_deviation*sd;{typically 3}

    for fitsY:=0 to head.height-1 do  {mark signal pixel and store in img_outliers}
    for fitsX:=0 to head.width-1 do
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
         if ((fitsX+i>=0) and (fitsX+i<head.width) and (fitsY+j>=0) and (FitsY+j<head.height))  then
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
  for col:=0 to head.naxis3-1 do {do all colours}
  for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1 do
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

//  use_histogram(true);{get histogram}
  plot_fits(mainwindow.image1,false,true);{plot real}

  Screen.Cursor:=Save_Cursor;
end;


procedure Tstackmenu1.bayer_pattern1Select(Sender: TObject);
begin
  demosaic_method1.enabled:=pos('X-Trans',bayer_pattern1.text )=0; {disable method is X-trans is selected}
end;


procedure Tstackmenu1.bin_image1Click(Sender: TObject);
var
  Save_Cursor:TCursor;
begin
  if fits_file=true then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    backup_img; {move viewer data to img_backup}
    if bin_factor1.itemindex=0 then bin_X2X3X4(2)
                               else bin_X2X3X4(3);

    plot_fits(mainwindow.image1,true,true);{plot real}
    Screen.Cursor:=Save_Cursor;
  end;
end;


procedure Tstackmenu1.align_blink1Change(Sender: TObject);
begin
  solve_and_annotate1.enabled:=align_blink1.checked;
end;


procedure Tstackmenu1.add_noise1Click(Sender: TObject);
var
  fitsX,fitsY,col: integer;
  noise,mean     : double;
  Save_Cursor:TCursor;
begin
  if fits_file=true then
  begin
    backup_img; {move viewer data to img_backup}

    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    noise:=strtofloat2(stackmenu1.edit_noise1.Text);
    if add_bias1.checked then mean:=3*noise else mean:=0;

    for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1 do
    for col:=0 to head.naxis3-1 do
    img_loaded[col,fitsX,fitsY]:=max(0,img_loaded[col,fitsX,fitsY]+randg(mean,noise){gaussian noise});

    plot_fits(mainwindow.image1,false,true);{plot real}
    Screen.Cursor:=Save_Cursor;
   end;
   use_histogram(img_loaded,true {update}); {update for the noise, plot histogram, set sliders}
end;

procedure Tstackmenu1.blink_stop1Click(Sender: TObject);
begin
  esc_pressed:=true;
end;


procedure Tstackmenu1.blink_unaligned_multi_step1Click(Sender: TObject);
var
  c,step            : integer;
  Save_Cursor       : TCursor;
  init              : boolean;
begin
  if listview1.items.count<=1 then exit; {no files}
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  save_settings2;{too many lost selected files . so first save settings}
  esc_pressed:=false;
  init:=false;
  if sender=blink_unaligned_multi_step_backwards1 then step:=-1 else step:=1;{forward/ backwards}

  repeat
    if init=false then c:= listview_find_selection(listview1) {find the row selected}
                  else
                  begin
                    if step>0 then c:=0 {forward}
                    else
                    c:=listview1.items.count-1;{backwards}
                  end;
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
        if load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded)=false then begin esc_pressed:=true; break;end;

        use_histogram(img_loaded,true {update}); {plot histogram, set sliders}

        plot_fits(mainwindow.image1,false {re_center},true);

        {show alignment marker}
        if (stackmenu1.use_manual_alignment1.checked) then
          show_shape_manual_alignment(c) {show the marker on the reference star}
        else
        mainwindow.shape_manual_alignment1.visible:=false;

      end;
      inc(c,step);
    until ((c>=listview1.items.count) or (c<0));
  until esc_pressed ;
  Screen.Cursor :=Save_Cursor;{back to normal }
end;

procedure Tstackmenu1.browse_mount1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select images to analyse';    {including WCS files !!!}
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  opendialog1.Filter :=dialog_filter;
  fits_file:=true;
  if opendialog1.execute then
  begin
    listview9.items.beginupdate;
    for i:=0 to OpenDialog1.Files.count-1 do {add}
    begin
      listview_add(listview9,OpenDialog1.Files[i],true,M_nr);
    end;
    listview9.items.endupdate;
  end;
end;


procedure Tstackmenu1.make_osc_color1Change(Sender: TObject);
var
  bmp : tbitmap;
  osc_color : boolean;
begin
  {enabe/disable related menu options}
  osc_color:=make_osc_color1.checked;
  osc_auto_level1.enabled:=osc_color;
  bayer_pattern1.enabled:=osc_color;
  test_pattern1.enabled:=osc_color;
  demosaic_method1.enabled:=osc_color;
  osc_colour_smooth1.enabled:=((osc_color) and (osc_auto_level1.checked));
  apply_normalise_filter1.enabled:=osc_color;
  osc_smart_colour_sd1.enabled:=osc_color;
  osc_smart_smooth_width1.enabled:=osc_color;

  bmp := TBitmap.Create;
  if make_osc_color1.checked then ImageList2.GetBitmap(12, bmp){colour stack} else ImageList2.GetBitmap(6, bmp);{gray stack}
  stackmenu1.stack_button1.glyph.assign(bmp);
  freeandnil(bmp);
end;


procedure Tstackmenu1.copy_to_images1Click(Sender: TObject);
var
  index,counter: integer;
begin
  index:=0;
  listview1.Items.beginUpdate;
  counter:=listview5.Items.Count;
  while index<counter do
  begin
    if  listview5.Items[index].Selected then
    begin
      listview_add(listview1,listview5.items[index].caption,true,L_nr);
    end;
    inc(index); {go to next file}
  end;
  listview1.Items.endUpdate;
end;


procedure double_size(img: image_array; w,h : integer; var img2 : image_array);{double array size}
var
   fitsX,fitsY,i,x,y:integer;
begin
  setlength(img_buffer,head.naxis3,w,h);{set length of image array}

  for fitsY:=0 to h do
    for fitsX:=0 to w do
    begin
      for i:=0 to head.naxis3-1 do
      begin
        x:=fitsX div 2;
        y:=fitsY div 2;
        if  ((x<=head.width-1) and (y<=head.height-1)) then {prevent problem if slightly different}
           img_buffer[i,fitsX ,fitsY]  :=img[i,x,y];
      end;
    end;
  head.height:=h;
  head.width :=w;

  img2:=img_buffer;
end;


procedure load_master_dark({exposure2,temperature2,width1,}jd_int: integer);
var
  c,{roundexposure,}dummy            : integer;
  d,day_offset               : double;
  filen                      : string;

begin
//  analyse_listview(stackmenu1.listview2,false {light},false {full fits},false{refresh});{find dimensions, head_2.exposure and temperature}
  c:=0;
  day_offset:=99999999;
  filen:='';

  while c<stackmenu1.listview2.items.count do
  begin
    if stackmenu1.listview2.items[c].checked=true then
      if ( (stackmenu1.classify_dark_exposure1.checked=false) or (round(head.exposure)=round(strtofloat2(stackmenu1.listview2.Items.item[c].subitems.Strings[D_exposure])))) then {head_2.exposure correct}
        if ( (stackmenu1.classify_dark_temperature1.checked=false) or (abs(head.set_temperature-strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_temperature]))<=1 )) then {temperature correct within one degree}
          if  head.width=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_width]) then {width correct}
          begin
            d:=strtofloat(stackmenu1.listview2.Items.item[c].subitems.Strings[D_jd]);
            if abs(d-jd_int)<day_offset then {find flat with closest date}
            begin
              filen:=stackmenu1.ListView2.items[c].caption;
              day_offset:=abs(d-jd_int);
            //  roundexposure:=round(head.exposure);
            end;
          end;
    inc(c);
  end;

  dark_exposure:=round(head.exposure);{remember the requested head_2.exposure time}
  dark_temperature:=head.set_temperature;

  if (filen<>'') then {new file}
  begin
    if ((head_ref.dark_count=0){restart} or (filen<>last_dark_loaded)) then
    begin

      memo2_message('Loading master dark file '+filen);
 //     head_ref.dark_count:=0;{set back to zero, store in header of reference}
      if load_fits(filen,false {light},true,false {update memo},0,head_2,img_dark)=false then begin memo2_message('Error'); head_ref.dark_count:=0; exit; end;
      {load master in memory img_dark}

      {test compatibility}
      if ((round(head_2.exposure)<>0 {dark exposure is measured}) and (round(head.exposure){request}<>round(head_2.exposure))) then
         memo2_message('█ █ █ █ █ █ Warning above dark exposure time ('+floattostrF(head_2.exposure,ffFixed,0,0)+') is different then the light exposure time ('+floattostrF(head.exposure,ffFixed,0,0) +')! █ █ █ █ █ █ ');
      if ((head_2.set_temperature<>999 {dark temperature is measured}) and (head.set_temperature{request}<>head_2.set_temperature)) then
         memo2_message('█ █ █ █ █ █ Warning above dark sensor temperature ('+floattostrF(head_2.set_temperature,ffFixed,0,0)+') is different then the light sensor temperature ('+floattostrF(head.set_temperature,ffFixed,0,0) +')! █ █ █ █ █ █ ');


      last_dark_loaded:=filen; {required for for change in light_jd}
      if head_2.dark_count=0 then head_2.dark_count:=1; {store in head of reference file}
    end;
  end
  else
  begin
    memo2_message('█ █ █ █ █ █ Warning, could not find a suitable dark for temperature "'+inttostr(head.set_temperature)+'"and exposure "'+inttostr(round(head.exposure))+'"! De-classify temperature or exposure time or add correct darks. █ █ █ █ █ █ ');
    head_2.dark_count:=0;{set back to zero}
  end;
end;


procedure load_master_flat({filter: string;width1,}jd_int :integer );
var
  c              : integer;
  d,day_offset   : double;
  filen          : string;
begin
//  analyse_listview(stackmenu1.listview3,false {light},false {full fits},false{refresh});{find dimensions, head_2.exposure and temperature}
  c:=0;
  day_offset:=99999999;
  filen:='';
  while c<stackmenu1.listview3.items.count do
  begin
    if stackmenu1.listview3.items[c].checked=true then
    begin
      if ((stackmenu1.classify_flat_filter1.checked=false) or (AnsiCompareText(head.filter_name,stackmenu1.listview3.Items.item[c].subitems.Strings[F_filter])=0)) then {filter correct?  ignoring case}
        if  head.width=strtoint(stackmenu1.listview3.Items.item[c].subitems.Strings[D_width]) then {width correct, matches with the light width}
        begin
          d:=strtofloat(stackmenu1.listview3.Items.item[c].subitems.Strings[F_jd]);
          if abs(d-jd_int)<day_offset then {find flat with closest date}
          begin
            filen:=stackmenu1.ListView3.items[c].caption;
            day_offset:=abs(d-jd_int);
          end;
        end;
    end;
    inc(c);
  end;

  if filen<>'' then
  begin
    if ((head_ref.flat_count=0){restart} or (filen<>last_flat_loaded)) then {new file}
    begin
      memo2_message('Loading master flat file '+filen);
      //head_ref.flat_count:=0;{set back to zero}
      if load_fits(filen,false {light},true,false {update memo},0,head_2,img_flat)=false then begin memo2_message('Error'); head_2.flat_count:=0; exit; end;
      {load master in memory img_flat}
      last_flat_loaded:=filen; {required for for change in light_jd}
      flat_filter:=head.filter_name; {mark as loaded}
     // head_ref.calstat:=head_2.calstat; {store flat numbers in head_ref.calstat of reference image}

      if pos('B',head_2.calstat)=0 then
      begin
        if head_2.flatdark_count=0 then {not an older flat}
           memo2_message('█ █ █ █ █ █ Warning: Flat not calibrated with a flat-dark/bias (keywords CALSTAT or BIAS_CNT). █ █ █ █ █ █')
        else
          head_2.calstat:=head_2.calstat+'B'; {older flat temporary till 2022-12 till all flats have "B" in in calstat. Remove 2022-12}
      end;

      if head_2.flat_count=0 then head_2.flat_count:=1; {not required for astap master}

      if  ((stackmenu1.make_osc_color1.checked) and (stackmenu1.apply_normalise_filter1.checked)) then
      begin
        memo2_message('Applying normalise filter on master (OSC) flat.');
        normalize_OSC_flat(img_flat);
      end

    end;
  end
  else
  begin
     memo2_message('█ █ █ █ █ █ Warning, could not find a suitable flat for "'+head.filter_name+'"! De-classify flat filter or add correct flat. █ █ █ █ █ █ ');
     head_2.flat_count:=0;{set back to zero}
//     head_ref.flat_count:=0;{set back to zero}
  end;
end;


procedure replace_by_master_dark;
var
   path1,filen :string;
   c,counter,i,file_count : integer;
   specified: boolean;
   exposure,temperature,width1: integer;
   day                        : double;
   file_list : array of string;
begin
  save_settings2;
  with stackmenu1 do
  begin
    analyse_listview(listview2,false {light},false {full fits},false{refresh});{update the tab information}
    if esc_pressed then exit;{esc could by pressed while analysing}

    setlength(file_list,stackmenu1.listview2.items.count);
    repeat
    file_count:=0;
    specified:=false;

    for c:=0 to stackmenu1.listview2.items.count-1 do
      if stackmenu1.listview2.items[c].checked=true then
      begin
        filen:=stackmenu1.ListView2.items[c].caption;
        if pos('master_dark',ExtractFileName(filen))=0 then {not a master file}
        begin {set specification master}
          if specified=false then
          begin
            exposure:=round(strtofloat2(stackmenu1.listview2.Items.item[c].subitems.Strings[D_exposure]));
            temperature:=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_temperature]);
            width1:=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_width]);
            day:=strtofloat(stackmenu1.listview2.Items.item[c].subitems.Strings[D_jd]);
            specified:=true;
          end;
          if ( (stackmenu1.classify_dark_exposure1.checked=false) or (exposure=round(strtofloat2(stackmenu1.listview2.Items.item[c].subitems.Strings[D_exposure])))) then {exposure correct}
            if ( (stackmenu1.classify_dark_temperature1.checked=false) or (temperature=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_temperature]))) then {temperature correct}
              if  width1=strtoint(stackmenu1.listview2.Items.item[c].subitems.Strings[D_width]) then {width correct}
                if ((classify_dark_date1.Checked=false) or (abs(day-strtofloat(stackmenu1.listview2.Items.item[c].subitems.Strings[D_jd]))<=0.5)) then {within 12 hours made}
                begin
                  file_list[file_count]:=filen;
                  inc(file_count);
                end;
        end;
      end;{checked}

    Application.ProcessMessages;
    if esc_pressed then exit;

    head.dark_count:=0;
    if file_count<>0 then
    begin
      memo2_message('Averaging darks.');
      average('dark',file_list,file_count,img_dark);  {the result will be mono so more suitable for raw lights without bayer applied. Not so suitable for commercial camera's image and converted to coloured FITS}
      if esc_pressed then exit;

      Application.ProcessMessages;
      if esc_pressed then exit;

      if ((file_count<>1) or (head.dark_count=0)) then  head.dark_count:=file_count; {else use the info from the keyword dark_cnt of the master file}

      path1:=extractfilepath(file_list[0])+'master_dark_'+inttostr(head.dark_count)+'x'+inttostr(round(exposure))+'s_at_'+inttostr(head.set_temperature)+'C_'+copy(head.date_obs,1,10)+'.fit';
      update_integer('DARK_CNT=',' / Number of dark image combined                  ' ,head.dark_count);
      { ASTAP keyword standard:}
      { interim files can contain keywords: EXPOSURE, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
      { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

      head.naxis3:=1; {any color is made mono in the routine. Keywords are updated in the save routine}
      head.naxis:=2;  {any color is made mono in the routine. Keywords are updated in the save routine}

      update_text   ('COMMENT 1','  Written by ASTAP. www.hnsky.org');
      head.naxis3:=1; {any color is made mono in the routine}

      if save_fits(img_dark,path1,-32,false) then {saved}
      begin
        listview2.Items.BeginUpdate;
        for i:=0 to  file_count-1 do
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
        listview_add(listview2,path1,true,D_nr);{add master}
        listview2.Items.EndUpdate;

        analyse_listview(listview2,false {light},true {full fits},false{refresh});{update the tab information}
      end;
      img_dark:=nil;
    end;

    Application.ProcessMessages;
    if esc_pressed then exit;

    until file_count=0;{make more than one master}
    save_settings2;{store settings}
    file_list:=nil;

    memo2_message('Master darks(s) ready.');
  end;{with stackmenu1}
end;


function extract_letters_only(inp : string): string;
var
  i : integer;
  ch: char;
begin
  result:='';
  for i:=1 to length(inp) do
  begin
    ch:=inp[i];
    case ch of // valid char
     'A'..'Z','a'..'z','-' : result := result + ch;
    end;{case}
  end;
end;



procedure Tstackmenu1.replace_by_master_dark1Click(Sender: TObject); {this routine works with mono files but makes coloured files mono, so less suitable for commercial cameras producing coloured raw lights}
begin
  if img_loaded<>nil then {button was used, backup img array and header and restore later}  begin  img_backup:=nil;{clear to save memory}  backup_img;  end;{backup fits for later}
  replace_by_master_dark;
  if img_loaded<>nil then restore_img; {button was used, restore original image array and header}
end;


procedure replace_by_master_flat;
var
   fitsX,fitsY,flat_count                        : integer;
   path1,filen,flat_filter,expos                 : string;
   day,flatdark_exposure,flat_exposure     : double;
   c,counter,i : integer;
   specified,classify_exposure: boolean;
   flat_width,flat_dark_width: integer;
   flatdark_used : boolean;
   file_list : array of string;
begin
  with stackmenu1 do
  begin
    save_settings2;

    analyse_listview(listview3,false {light},false {full fits},new_analyse_required3{refresh});{update the tab information. Convert to FITS if required}
    if esc_pressed then exit;{esc could be pressed in analyse}
    new_analyse_required3:=false;
    flatdark_exposure:=-99;
    classify_exposure:=classify_flat_exposure1.checked;

    setlength(file_list,stackmenu1.listview3.items.count);
    repeat
      flat_count:=0;
      specified:=false;

      i:=stackmenu1.listview3.items.count-1;
      for c:=0 to stackmenu1.listview3.items.count-1 do
        if stackmenu1.listview3.items[c].checked=true then
        begin
          filen:=stackmenu1.ListView3.items[c].caption;
          if pos('master_flat',ExtractFileName(filen))=0 then {not a master file}
          begin {set specification master}
            if specified=false then
            begin
              flat_filter:=stackmenu1.listview3.Items.item[c].subitems.Strings[F_filter];
              flat_width:=strtoint(stackmenu1.listview3.Items.item[c].subitems.Strings[D_width]);
              day:=strtofloat(stackmenu1.listview3.Items.item[c].subitems.Strings[F_jd]);
              flat_exposure:=strtofloat(stackmenu1.listview3.Items.item[c].subitems.Strings[F_exposure]);
              specified:=true;
            end;

            if ((stackmenu1.classify_flat_filter1.checked=false) or (flat_filter=stackmenu1.listview3.Items.item[c].subitems.Strings[F_filter])) then {filter correct?}
              if  flat_width=strtoint(stackmenu1.listview3.Items.item[c].subitems.Strings[D_width]) then {width correct}
                if ((classify_flat_date1.Checked=false) or  (abs(day-strtofloat(stackmenu1.listview3.Items.item[c].subitems.Strings[F_jd]))<=0.5)) then {within 12 hours made}
                  if ((classify_exposure=false) or (abs(flat_exposure-strtofloat(stackmenu1.listview3.Items.item[c].subitems.Strings[F_exposure]))<0.01 )) then {head.exposure correct?}
                  begin
                    file_list[flat_count]:=filen;
                    inc(flat_count);
                  end;
          end;
        end;{checked}


      Application.ProcessMessages;
      if esc_pressed then exit;

      if flat_count<>0 then
      begin

        Application.ProcessMessages;
        if esc_pressed then exit;

        if  abs(flat_exposure-flatdark_exposure)>0.01 then  {already a dark loaded?}
        begin
          if classify_exposure=false then
          begin
             flat_exposure:=-99; {do not classify on flat dark head.exposure time}
          end
          else
          begin
            analyseflatdarksButton1Click(nil); {head.exposure lengths are required for selection}
            memo2_message('Selecting flat darks with exposure time '+floattostrF(flat_exposure,FFgeneral,0,2)+ 'sec');
          end;
          flat_dark_width:=average_flatdarks(flat_exposure);{average of bias frames. Convert to FITS if required}
          flatdark_exposure:=flat_exposure;{store this head.exposure for next time}
          if flat_dark_width=0 then memo2_message('█ █ █ █ █ █ Warning no flat-dark/bias found!! █ █ █ █ █ █ ')
          else
          if flat_width<>flat_dark_width then begin memo2_message('Abort, the width of the flat and flat-dark do not match!!');exit end;
          flatdark_used:=false;
        end;

        memo2_message('Combining flats.');
        Application.ProcessMessages;
        if esc_pressed then exit;
        average('flat',file_list,flat_count,img_flat);{only average, make color also mono}

        memo2_message('Combining flats and flat-darks.');
        Application.ProcessMessages;
        if esc_pressed then
        exit;

        if flat_count<>0 then
        begin
          if head.flatdark_count<>0 then
          begin
            memo2_message('Applying the combined flat-dark on the combined flat.');
            flatdark_used:=true;
            for fitsY:=0 to head.height-1 do
              for fitsX:=0 to head.width-1 do
              begin
                 img_flat[0,fitsX,fitsY]:=img_flat[0,fitsX,  fitsY  ] - img_bias[0,fitsX,  fitsY  ]; {flats and bias already made mono in procedure average}
              end;
          end;
        end;

        Application.ProcessMessages;
        if esc_pressed then exit;

        head.naxis3:=1; {any color is made mono in the routine}
        if flat_count<>0 then
        begin
          flat_filter:=extract_letters_only(flat_filter); {extract_letter is added for filter='N/A' for SIPS software}
          if flat_filter='' then head.filter_name:=copy(extractfilename(file_list[0]),1,10);{for DSLR images}
          if classify_exposure then begin str(flat_exposure:0:2,expos);flat_filter:=flat_filter+'_'+expos+'sec'; end;
          path1:=extractfilepath(file_list[0])+'master_flat_corrected_with_flat_darks_'+flat_filter+'_'+inttostr(flat_count)+'xF_'+inttostr(head.flatdark_count)+'xFD_'+copy(head.date_obs,1,10)+'.fit';;
          update_integer('FLAT_CNT=',' / Number of flat images combined.                ' ,flat_count);
          update_integer('BIAS_CNT=',' / Number of flat-dark or bias images combined.   ' ,head.flatdark_count);
          if head.flatdark_count<>0 then head.calstat:=head.calstat+'B';
          update_text ('CALSTAT =',#39+head.calstat+#39); {calibration status}

          { ASTAP keyword standard:}
          { interim files can contain keywords: head.exposure, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
          { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

          update_text   ('COMMENT 1','  Created by ASTAP www.hnsky.org');
          head.naxis3:=1; {any color is made mono in the routine. Keywords are updated in the save routine}
          head.naxis:=2;  {any color is made mono in the routine. Keywords are updated in the save routine}

          if save_fits(img_flat,path1,-32,false) then {saved}
          begin
            listview3.Items.BeginUpdate; {remove the flats added to master}
            for i:=0 to  flat_count do
            begin
              c:=0;
              counter:=listview3.Items.Count;
              while c<counter do
              begin
                if file_list[i]=stackmenu1.ListView3.items[c].caption then {processed}
                begin
                  listview3.Items.Delete(c);
                  dec(counter);{one file less}
                end
                else
                inc(c);
              end;
            end;
            listview_add(listview3,path1,true,F_nr);{add master}
            listview3.Items.EndUpdate;
            analyse_listview(listview3,false {light},true {full fits (for standard deviation)},false{refresh});{update the tab information}
          end;
          img_flat:=nil;
        end;
      end;

      Application.ProcessMessages;
      if esc_pressed then exit;

    until flat_count=0;{make more than one master}

    if flatdark_used then listview4.Items.Clear;{remove bias if used}
    save_settings2;{store settings}
    file_list:=nil;

    memo2_message('Master flat(s) ready.');
  end;{with stackmenu1}
end;


procedure Tstackmenu1.replace_by_master_flat1Click(Sender: TObject);
begin
  if img_loaded<>nil then {button was used, backup img array and header and restore later}  begin img_backup:=nil;{clear to save memory} backup_img; end;{backup fits for later}
  replace_by_master_flat;
  if img_loaded<>nil then restore_img; {button was used, restore original image array and header}
end;


function create_internal_solution(img: image_array) : boolean; {plate solving, image should be already loaded create internal solution using the internal solver}
begin
  if solve_image(img,true) then {match between loaded image and star database}
  begin
    if savefits_update_header(filename2)=false then begin ShowMessage('Write error !!' + filename2); exit;end;
    result:=true;{new solution}
  end
  else result:=false;
end;


procedure apply_dark_and_flat(var img : image_array) ; inline; {apply dark and flat if required, renew if different head.exposure or ccd temp}
var
  fitsX,fitsY,k    : integer;
  value,flat_factor,dark_norm_value,flat11,flat12,flat21,flat22 : double;

begin
  date_to_jd(head.date_obs,head.exposure {light}); {convert date-obs to global variables jd_start, jd_mid. Use this to find the dark with the best match for the light}

  if pos('D',head.calstat)<>0 then {is the light already calibrated}
             memo2_message('Skipping dark calibration, already applied. See header keyword CALSTAT')
  else
  begin
    load_master_dark({round(head.exposure),round(head.set_temperature),head.width,} round(jd_start)); {will only be renewed if different head.exposure or head.set_temperature.}

    if head_2.dark_count>0 then   {dark and flat use head_2 for status}
    begin
      dark_norm_value:=0;
      for fitsY:=-4 to 5 do {do even times, 10x10 for bayer matrix}
         for fitsX:=-4 to 5 do
           dark_norm_value:=dark_norm_value+img_dark[0,fitsX+(head.width div 2),fitsY +(head.height div 2)];
      dark_norm_value:=round(dark_norm_value/100);{scale factor to apply flat. The norm value will result in a factor one for the center.}

      for fitsY:=0 to head.height-1 do  {apply the dark}
        for fitsX:=0 to head.width-1  do
        begin
          value:=img_dark[0,fitsX,fitsY]; {Darks are always made mono when making master dark}
          for k:=0 to head.naxis3-1 do {do all colors}
                      img[k,fitsX,fitsY]:=img[k,fitsX,fitsY] - value;

        end;

      {for stacking}
      head_ref.calstat:='D'; {dark applied, store in header of reference file since it not modified while stacking}
      head_ref.dark_count:=head_2.dark_count;
      head_ref.datamax_org:=head.datamax_org-dark_norm_value;{adapt light datamax_org}

     {for SQM measurement, live stacking}
      head.calstat:='D'; {dark applied, store in header of reference file}
      head.dark_count:=head_2.dark_count;
      head.datamax_org:=head.datamax_org-dark_norm_value;{adapt light datamax_org}
    end;
  end;{apply dark}

  if pos('F',head.calstat)<>0 then
           memo2_message('Skipping flat calibration, already applied. See header keyword CALSTAT')
  else
  begin
    load_master_flat({head.filter_name,head.width,}round(jd_start));{will only be renewed if different filter name.  Note load will overwrite head.calstat}
    last_light_jd:=round(jd_start);

    if head_2.flat_count<>0 then
    begin
      flat_norm_value:=0;
      flat11:=0;
      flat12:=0;
      flat21:=0;
      flat22:=0;

      for fitsY:=-4 to 5 do {do even times, 10x10 for Bay matrix}
         for fitsX:=-4 to 5 do
         begin
           value:=img_flat[0,fitsX+(head_2.width div 2),fitsY +(head_2.height div 2)];
           flat_norm_value:=flat_norm_value+value;
           if ((odd(fitsX)) and (odd(fitsY)) ) then
                                 flat11:=flat11+value;
           if ((odd(fitsX)=false) and (odd(fitsY)) ) then
           flat12:=flat12+value;
           if ((odd(fitsX)) and (odd(fitsY)=false) ) then
           flat21:=flat21+value;
           if ((odd(fitsX)=false) and (odd(fitsY)=false) ) then
           flat22:=flat22+value;
         end;
      flat_norm_value:=round(flat_norm_value/100);{scale factor to apply flat. The norm value will result in a factor one for the center.}

      if max(max(flat11,flat12),max(flat21,flat22))/min(min(flat11,flat12),min(flat21,flat22))>2.0 then memo2_message('█ █ █ █ █ █ Warning flat pixels differ too much. Use white light for OSC flats or consider using option "Normalise OSC flat" █ █ █ █ █ █ ');

      for fitsY:=1 to head.height do  {apply the flat}
        for fitsX:=1 to head.width do
        begin
          flat_factor:=flat_norm_value/(img_flat[0,fitsX-1,fitsY-1]+0.001); {bias is already combined in flat in combine_flat}
          if abs(flat_factor)>3 then flat_factor:=1;{un-used sensor area? Prevent huge gain of areas only containing noise and no flat-light value resulting in very strong disturbing noise or high value if dark is missing. Typical problem for converted RAW's by Libraw}
          for k:=0 to head.naxis3-1 do {do all colors}
            img[k,fitsX-1,fitsY-1]:=img[k,fitsX-1,fitsY-1]*flat_factor;
        end;
      {for stacking}
      head_ref.calstat:=head_ref.calstat+'F'+head_2.calstat{B from flat};{mark that flat and bias have been applied. Store in the header of the reference file since it is not modified while stacking}
      head_ref.flat_count:=head_2.flat_count;
      head_ref.flatdark_count:=head_2.flatdark_count;

      {for SQM measurement, live stacking}
      head.calstat:=head.calstat+'F'+head_2.calstat{B from flat};{mark that flat and bias have been applied. Store in the header of the reference file}
      head.flat_count:=head_2.flat_count;
      head.flatdark_count:=head_2.flatdark_count;

    end;{flat correction}
  end;{do flat & flat dark}
end;


procedure calibration_only; {calibrate lights only}
var
  Save_Cursor:TCursor;
   c,x,y,col  : integer;
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
        if ((esc_pressed) or (load_fits(filename2,true {light},true,true {update memo, required for updates},0,head,img_loaded)=false)) then begin memo2_message('Error');{can't load} Screen.Cursor := Save_Cursor; exit;end;

        apply_dark_and_flat(img_loaded);{apply dark, flat if required, renew if different head.exposure or ccd temp}

        memo2_message('Calibrating file: '+inttostr(c+1)+'-'+inttostr( ListView1.items.count-1)+' "'+filename2+'"  to average. Using '+inttostr(head.dark_count)+' darks, '+inttostr(head.flat_count)+' flats, '+inttostr(head.flatdark_count)+' flat-darks') ;
        Application.ProcessMessages;

        for Y:=0 to head.height-1 do
         for X:=0 to head.width-1 do
           for col:=0 to head.naxis3-1 do
           begin
             img_loaded[col,X,Y]:= img_loaded[col,X,Y]+500; {add pedestal}
           end;


        if esc_pressed then exit;

        if make_osc_color1.checked then {do demosaic bayer}
            demosaic_bayer(img_loaded); {convert OSC image to colour}
         {head.naxis3 is now 3}

        update_text   ('COMMENT 1','  Calibrated by ASTAP. www.hnsky.org');
        update_text   ('CALSTAT =',#39+head.calstat+#39); {calibration status}
        add_integer('DARK_CNT=',' / Darks used for luminance.               ' ,head.dark_count);{for interim lum,red,blue...files. Compatible with master darks}
        add_integer('FLAT_CNT=',' / Flats used for luminance.               ' ,head.flat_count);{for interim lum,red,blue...files. Compatible with master flats}
        add_integer('BIAS_CNT=',' / Flat-darks used for luminance.          ' ,head.flatdark_count);{for interim lum,red,blue...files. Compatible with master flats}
         { ASTAP keyword standard:}
         { interim files can contain keywords: head.exposure, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
         { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}


        filename2:=StringReplace(ChangeFileExt(filename2,'.fit'),'.fit','_cal.fit',[]);{give new file name }
        memo2_message('█ █ █  Saving calibrated file as '+filename2);
        save_fits(img_loaded,filename2,-32, true);

        object_to_process:=uppercase(ListView1.Items.item[c].subitems.Strings[L_object]); {get a object name}
        stack_info:=' '+inttostr(head.flatdark_count)+'x'+'FD  '+
                        inttostr(head.flat_count)+'x'+'F  '+
                        inttostr(head.dark_count)+'x'+'D  '+
                        '1x'+head.filter_name;

        report_results(object_to_process,stack_info,0,-1{no icon});{report result in tab results}
      finally
      end;
    end;
  end;{with stackmenu1 do}

  plot_fits(mainwindow.image1,true,true);{update to last image, activate memo1}

  Screen.Cursor:=Save_Cursor;
  memo2_message('Calibration of the individual files is complete. New files are posted in the results tab');
end;


procedure put_best_quality_on_top(var files_to_process : array of TfileToDo);{find the files with the lowest hfd unless an image is larger}
var
   best_quality,quality  : double;
   first, best_index,i, width1, largest_width  : integer;
   quality_str: string;
   file_to_do : Tfiletodo;
begin
  first:=-1;
  largest_width:=-1;
  best_index:=999999;
  best_quality:=0;
  for i:=0 to length(files_to_process)-1 do
  begin
    if length(files_to_process[i].name)>1 then {has a filename}
    begin
      stackmenu1.ListView1.Items.item[i].SubitemImages[L_quality]:=-1;{remove any older icon_king}

      {$ifdef darwin} {MacOS}
      {bugfix darwin icons}
       stackmenu1.ListView1.Items.item[i].Subitems.strings[L_quality]:=stringreplace(stackmenu1.ListView1.Items.item[i].Subitems.strings[L_quality],'♛','',[]);
      {$endif}


      width1:=strtoint(stackmenu1.ListView1.Items.item[i].subitems.Strings[L_width]);
      if first=-1 then begin first:=i; largest_width:=width1  end;

      quality_str:=stackmenu1.ListView1.Items.item[i].subitems.Strings[L_quality];{number of stars detected}
      if length(quality_str)>1 then quality:=strtofloat2(quality_str) else quality:=0;{quality equals nr stars /hfd}

      if width1>largest_width then {larger image found, give this one preference}
      begin
        width1:=largest_width;
        best_quality:=quality;
        best_index:=i;
      end
      else
      if width1=largest_width then {equal size}
      begin {equal size}
        if quality>best_quality then
        begin
           best_quality:=quality;
           best_index:=i;
        end;
      end;
    end; {has a file name}
  end;{for loop}

  if best_index<999999 then {selection worked}
  begin
    if best_index<>first then {swap records, put best quality first}
    begin
      file_to_do:=files_to_process[first];
      files_to_process[first]:=files_to_process[best_index];
      files_to_process[best_index]:=file_to_do;
    end;
    stackmenu1.ListView1.Items.item[best_index].SubitemImages[L_quality]:=icon_king; {mark as best quality image}
   {$ifdef darwin} {MacOS}
    {bugfix darwin icons}
    stackmenu1.ListView1.Items.item[best_index].Subitems.strings[L_quality]:='♛'+ stackmenu1.ListView1.Items.item[best_index].Subitems.strings[L_quality];
   {$endif}


    memo2_message('Reference image selected based on quality (star_detections/hfd) is: '+files_to_process[best_index].name);
  end;
end;



function RemoveSpecialChars(const STR : string) : string;
var {################# initialised variables #########################}
  InvalidChars : set of char = ['.','\','/','*','"',':','|','<','>'];
var
  I : integer;
begin
  Result:='';
  for i:=1 to length(str) do
    if not(str[i] in InvalidChars) then result:=result+str[i]
end;


function propose_file_name(mosaic_mode: boolean;object_to_process,filters_used:string) : string; {propose a file name}
var
  hh,mm,ss,ms : word;
begin
  if object_to_process<>'' then result:=object_to_process else result:='no_object';
  if head.date_obs<>'' then result:=result+', '+copy(head.date_obs,1,10);
  result:=result+', ';
  if mosaic_mode then result:=result+'mosaic ';
  if counterR<>0 then  result:=result+inttostr(counterR)+'x'+inttostr(exposureR)+'R ';
  if counterG<>0 then result:=result+inttostr(counterG)+'x'+inttostr(exposureG)+'G ';
  if counterB<>0 then result:=result+inttostr(counterB)+'x'+inttostr(exposureB)+'B ';
  if counterRGB<>0 then result:=result+inttostr(counterRGB)+'x'+inttostr(exposureRGB)+'RGB ';
  if counterL<>0 then result:=result+inttostr(counterL)+'x'+inttostr(exposureL)+'L '; {head.exposure}
  result:=StringReplace(trim(result),' ,',',',[rfReplaceAll]);{remove all spaces in front of comma's}
  telescop:=trim(telescop);
  if trim(telescop)<>'' then result:=result+', '+telescop;

  if length(filters_used)>0 then result:=result+', ('+filters_used+')';
  instrum:=trim(instrum);
  if instrum<>'' then result:=result+', '+instrum;
  result:=RemoveSpecialChars(result);{slash could be in date but also telescope name like eqmod HEQ5/6}
  if stackmenu1.add_time1.checked then
  begin
    decodetime(time,hh,mm,ss,ms);
    result:=result+'_'+leadingzero(hh)+leadingzero(mm)+leadingzero(ss);
  end;
  if pos('Aver',stackmenu1.stack_method1.text)>0 then result:=result+'_average';
  result:=result+'_stacked.fits';
end;


procedure Tstackmenu1.stack_button1Click(Sender: TObject);
var
   Save_Cursor:TCursor;
   i,c,over_size,over_sizeL,nrfiles, image_counter,object_counter, first_file, total_counter,counter_colours: integer;
   filter_name1, filter_name2,defilter, filename3, extra1,extra2,object_to_process,stack_info,thefilters    : string;
   lrgb,solution,monofile,ignore,cal_and_align, mosaic_mode,sigma_mode,calibration_mode,skip_combine  : boolean;
   startTick      : qword;{for timing/speed purposes}
   min_background,max_background,backgr   : double;
   filters_used : array [0..4] of string;
begin
  save_settings2;{too many lost selected files, so first save settings}
  esc_pressed:=false;

  if make_osc_color1.checked then
              memo2_message('OSC, demosaic method '+demosaic_method1.text)
              else
              if classify_filter1.checked then memo2_message('LRGB colour stack (classify by image filter checked)')
              else memo2_message('Grayscale stack (classify by image filter unchecked)');
  memo2_message('Stack method '+stack_method1.text);
  memo2_message('Oversize '+oversize1.text+ ' pixels');
  mosaic_mode:=pos('stich',stackmenu1.stack_method1.text)>0;
  sigma_mode:=pos('Sigma',stackmenu1.stack_method1.text)>0;
  skip_combine:=pos('skip',stackmenu1.stack_method1.text)>0;
  cal_and_align:=pos('alignment',stackmenu1.stack_method1.text)>0; {calibration and alignment only}

  if  ((stackmenu1.use_manual_alignment1.checked) and (sigma_mode) and (pos('Comet',stackmenu1.manual_centering1.text)<>0)) then memo2_message('█ █ █ █ █ █ Warning, use for comet stacking the stack method "Average"!. █ █ █ █ █ █ ');

  if  stackmenu1.use_ephemeris_alignment1.checked then
  begin
    if length(ephemeris_centering1.text)<=1 then begin memo2_message('█ █ █ █ █ █ Abort, no object selected for ephemeris alignment. At tab alignment, press analyse and select object to align on! █ █ █ █ █ █'); exit; end
    else memo2_message('Ephemeris alignment on object '+ephemeris_centering1.text);
  end;
  startTick := gettickcount64;

  if img_loaded<>nil then begin img_backup:=nil;{clear to save memory} backup_img;    end; ;{backup image array and header for case esc pressed.}

  calibration_mode:=pos('Calibration only',stackmenu1.stack_method1.text)>0;

  if ListView1.items.count<>0 then
  begin
    memo2_message('Analysing images.');
    analyse_tab_lights(calibration_mode=false); {analyse any image not done yet. For calibration mode skip hfd and background measurments}
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
    replace_by_master_dark;
    if esc_pressed then begin restore_img;exit;end;
  end;
  if ListView3.items.count<>0 then
  begin
    memo2_message('Analysing flats.');
    replace_by_master_flat;
    if esc_pressed then begin restore_img;exit;end;
  end;

  dark_exposure:=987654321;{not done indication}
  dark_temperature:=987654321;
  flat_filter:='987654321';{not done indication}

  min_background:=65535;
  max_background:=0;

  if calibration_mode then {calibrate lights only}
  begin
     calibration_only;
     Memo2_message('Ready. Resulting files are available in tab Results and can be copied to the Blink, Photometry or Lights tab.');
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
        if length(ListView1.Items.item[c].subitems.Strings[L_X])<=1 then {no manual position added}
        begin
          memo2_message('█ █ █  Abort! █ █ █  Reference object missing for one or more files. Double click on all file names and mark with the mouse the reference object. The file name will then turn green.');
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

  if ((use_astrometry_internal1.checked) or (use_ephemeris_alignment1.checked)) then {astrometric alignment}
  begin
    memo2_message('Checking astrometric solutions');
    if use_ephemeris_alignment1.checked then ignore:=stackmenu1.update_solution1.checked {ephemeris}
    else ignore:=stackmenu1.ignore_header_solution1.Checked; {stacking}

    for c:=0 to ListView1.items.count-1 do
    if ( (ListView1.items[c].Checked=true) and ((ignore) or (ListView1.Items.item[c].subitems.Strings[L_solution]<>'✓') ){no internal solution } ) then
    begin
      try { Do some lengthy operation }
        ListView1.Selected :=nil; {remove any selection}
        ListView1.ItemIndex := c;{show wich file is processed}
        Listview1.Items[c].MakeVisible(False);{scroll to selected item}

        progress_indicator(10*c/ListView1.items.count-1,' solving');{indicate 0 to 10% for plate solving}

        filename2:=ListView1.items[c].caption;
        Application.ProcessMessages;
        if esc_pressed then begin restore_img; Screen.Cursor := Save_Cursor; exit;end;

        {load file}
        if load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded){important required to check head.cd1_1}=false then begin memo2_message('Error');{failed to load} Screen.Cursor := Save_Cursor; exit;end;
        if ((head.cd1_1=0) or (ignore)) then
                                  solution:= create_internal_solution(img_loaded) else solution:=true;

        if solution=false then
        begin {no solution found}
          ListView1.items[c].Checked:=false;
          memo2_message('No solution for: "'+filename2+'" un-checked this file.');
        end {no solution found}
        else
        memo2_message('Astrometric solution for: "'+filename2+'"');
        if solution then
        begin
          stackmenu1.ListView1.Items.item[c].subitems.Strings[L_solution]:='✓';
          stackmenu1.ListView1.Items.item[c].subitems.Strings[L_position]:=prepare_ra5(head.ra0,': ')+', '+ prepare_dec4(head.dec0,'° ');{give internal position}
        end
        else stackmenu1.ListView1.Items.item[c].subitems.Strings[L_solution]:=''; {report internal plate solve result}
       finally
      end;
    end;
    memo2_message('Astrometric solutions complete.');

    if mosaic_mode then
    begin
      SortedColumn:= L_position+1;
      listview1.sort;
      memo2_message('Sorted list on RA, DEC position to place tiles in the correct sequence.')
    end;
  end;

  if stackmenu1.auto_rotate1.checked  then {fix rotationss}
  begin
    memo2_message('Checking orientations');
    for c:=0 to ListView1.items.count-1 do
    if ( (ListView1.items[c].Checked=true) and (stackmenu1.ListView1.Items.item[c].subitems.Strings[L_solution]='✓' {solution} ) ) then
    begin
      try { Do some lengthy operation }
        ListView1.Selected :=nil; {remove any selection}
        ListView1.ItemIndex := c;{show wich file is processed}
        Listview1.Items[c].MakeVisible(False);{scroll to selected item}

        progress_indicator(10*c/ListView1.items.count-1,' rotating');{indicate 0 to 10% for plate solving}

        filename2:=ListView1.items[c].caption;

        Application.ProcessMessages;
        if esc_pressed then begin restore_img; Screen.Cursor := Save_Cursor; exit;end;

        {load file}
        if load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded){important required to check head.cd1_1}=false then begin memo2_message('Error');{failed to load} Screen.Cursor := Save_Cursor; exit;end;

        head.crota2:=fnmodulo(head.crota2,360);
        if ((head.crota2>=90) and (head.crota2<270)) then
        begin
          memo2_message('Rotating '+filename2+' 180°');
          //mainwindow.imageflipv1Click(nil);      {horizontal flip}
          //mainwindow.imageflipv1Click(sender);{vertical flip}
           raster_rotate(180,head.width/2,head.height/2 ,img_loaded);{fast rotation 180 degrees}
          if nrbits=16 then
          save_fits(img_loaded,filename2,16,true)
           else
          save_fits(img_loaded,filename2,-32,true);
        end;

      finally
      end;
    end;
    memo2_message('Orientation task complete.');
  end;

  if use_ephemeris_alignment1.checked then {add annotations}
  begin
    memo2_message('Checking annotations');
    for c:=0 to ListView1.items.count-1 do                         //   and (stackmenu1.ListView1.Items.item[c].subitems.Strings[I_solution]:='✓')and ( length(stackmenu1.ListView1.Items.item[c].subitems.Strings[I_X])<=1){no annotation yet}
    if ( (ListView1.items[c].Checked=true) and (stackmenu1.ListView1.Items.item[c].subitems.Strings[L_solution]='✓' {solution} ) and ((stackmenu1.update_annotations1.checked) or (stackmenu1.auto_rotate1.checked ) or ( length(stackmenu1.ListView1.Items.item[c].subitems.Strings[L_X])<=1)){no annotation yet} ) then
    begin
      try { Do some lengthy operation }
        ListView1.Selected :=nil; {remove any selection}
        ListView1.ItemIndex := c;{show wich file is processed}
        Listview1.Items[c].MakeVisible(False);{scroll to selected item}

        progress_indicator(10*c/ListView1.items.count-1,' annotations');{indicate 0 to 10% for plate solving}

        filename2:=ListView1.items[c].caption;
        memo2_message('Adding annotations to FITS header and X,Y positions of selected object to list for '+filename2);

        Application.ProcessMessages;
        if esc_pressed then begin restore_img; Screen.Cursor := Save_Cursor; exit;end;

        {load file}
        if load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded){important required to check head.cd1_1}=false then begin memo2_message('Error');{failed to load} Screen.Cursor := Save_Cursor; exit;end;
        plot_mpcorb(strtoint(maxcount_asteroid),strtofloat2(maxmag_asteroid),true {add_annotations});
        if savefits_update_header(filename2)=false then begin ShowMessage('Write error !!' + filename2); Screen.Cursor := Save_Cursor; exit;end;
        get_annotation_position;{fill the x,y with annotation position}
      finally
      end;
    end;
    memo2_message('Annotations complete.');
  end;

  progress_indicator(10,'');
  Application.ProcessMessages;
  if esc_pressed then begin restore_img;Screen.Cursor := Save_Cursor;  exit;end;

  object_counter:=0;
  total_counter:=0;

  head.dark_count:=0;{reset only once, but keep if dark is loaded}
  head.flat_count:=0;{reset only once, but keep if flat is loaded}
  head.flatdark_count:=0;{reset only once}

  for c:=0 to ListView1.items.count-1 do
  begin
    ListView1.Items.item[c].SubitemImages[L_result]:=-1;{remove any icons. Mark third columns as not done using the image index of first column}
    ListView1.Items.item[c].subitems.Strings[L_result]:='';{no stack result}
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
    monofile:=false;{mono file success}
    head.light_count:=0;
    counter_colours:=0;{number of lrgb colours added}

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
    for i:=0 to 4 do filters_used[i]:='';
    inc(object_counter);

    lrgb:=((classify_filter1.checked) and (cal_and_align=false));{ignore lrgb for calibration and alignmentis true}
    over_size:=round(strtofloat2(stackmenu1.oversize1.Text));{accept also commas but round later}
    if lrgb=false then
    begin
      SetLength(files_to_process, ListView1.items.count);{set array length to listview}
      nrfiles:=0;

      for c:=0 to ListView1.items.count-1 do
      begin
        files_to_process[c].name:='';{mark empthy}
        files_to_process[c].listviewindex:=c;{use same index as listview1 except when later put lowest HFD first}
        if ((ListView1.items[c].Checked=true) and (ListView1.Items.item[c].SubitemImages[L_result]<0)) then {not done yet}
        begin
          if object_to_process='' then object_to_process:=uppercase(ListView1.Items.item[c].subitems.Strings[L_object]); {get a object name to stack}
          if ( (classify_object1.checked=false) or  (mosaic_mode){ignore object name in mosaic} or
               ((object_to_process<>'') and (object_to_process=uppercase(ListView1.Items.item[c].subitems.Strings[L_object]))) ) then {correct object?}
          begin {correct object}
            files_to_process[c].name:=ListView1.items[c].caption;
            inc(image_counter);{one image more}

            ListView1.Items.item[c].SubitemImages[L_result]:=5;{mark 3th columns as done using a stacked icon}
            ListView1.Items.item[c].subitems.Strings[L_result]:=inttostr(object_counter)+'  ';{show image result number}


            {$ifdef darwin} {MacOS}
            {bugfix darwin green red colouring}
            if length(ListView1.Items.item[c].subitems.Strings[L_X])>1 then {manual position added, colour it}
              ListView1.Items.item[c].subitems.Strings[L_result]:='✓ star'+ListView1.Items.item[c].subitems.Strings[L_result];
            {$endif}

            inc(nrfiles);
            if mosaic_mode then
            begin
              backgr:=strtofloat2(ListView1.Items.item[c].subitems.Strings[L_background]);
              min_background:=min(backgr,min_background);
              max_background:=max(backgr,max_background);
            end;
          end;
        end;
      end;
      if nrfiles>1 then {need at least two files to sort}
      begin
        if mosaic_mode=false then put_best_quality_on_top(files_to_process);
         {else already sorted on position to be able to test overlapping of background difference in unit_stack_routines. The tiles have to be plotted such that they overlap for measurement difference}

        if sigma_mode then
        begin
          if length(files_to_process)<=5 then memo2_message('█ █ █ █ █ █ Method "Sigma Clip average" does not work well for a few images. Try method "Average". █ █ █ █ █ █ ');
          stack_sigmaclip(over_size,{var}files_to_process,counterL) {sigma clip combining}
        end
        else

        if mosaic_mode then stack_mosaic(over_size,{var}files_to_process,abs(max_background-min_background),counterL) {mosaic combining}
        else
        if cal_and_align then {calibration & alignment only}
        begin
          memo2_message('---------- Calibration & alignment for object: '+object_to_process+' -----------');
          calibration_and_alignment(over_size,{var}files_to_process,counterL){saturation clip average}
        end
        else
          stack_average(over_size,{var}files_to_process,counterL);{average}

        if counterL>0 then
        begin
          exposureL:=round(sum_exp/counterL); {average head.exposure}
          monofile:=true;{success}
        end;

        if esc_pressed then  begin progress_indicator(-2,'ESC'); restore_img;Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;

      end
      else
      begin
        counterL:=0; {number of files processed}
        monofile:=false;{stack failure}
      end;
    end
    else
    begin {lrgb lights, classify on filter is true}
      SetLength(files_to_process_LRGB,6);{will contain [reference,r,g,b,colour,l]}
      for i:=0 to 5 do files_to_process_LRGB[i].name:='';{clear}

      SetLength(files_to_process, ListView1.items.count);{set array length to listview}

      for i:=0 to 4 do
      begin
        case i  of 0: begin filter_name1:=(red_filter1.text);filter_name2:=(red_filter2.text); end;
                   1: begin filter_name1:=(green_filter1.text);filter_name2:=(green_filter2.text);end;
                   2: begin filter_name1:=(blue_filter1.text);filter_name2:=(blue_filter2.text);end;
                   3: begin filter_name1:='colour';filter_name2:='Colour';end;
                 else
                 begin filter_name1:=(luminance_filter1.text);filter_name2:=(luminance_filter2.text);end;
        end;{case}
        nrfiles:=0;

        for c:=0 to ListView1.items.count-1 do
        begin
          files_to_process[c].name:='';{mark as empthy}
          files_to_process[c].listviewindex:=c;{use same index as listview except when later put lowest HFD first}
          if ((ListView1.items[c].Checked=true) and (ListView1.Items.item[c].SubitemImages[L_result]<0){not yet done} and
              (length(ListView1.Items.item[c].subitems.Strings[L_filter])>0)  {skip any file without a filter name}
              ) then
          begin  {not done yet}
            if object_to_process='' then object_to_process:=uppercase(ListView1.Items.item[c].subitems.Strings[L_object]); {get a next object name to stack}

            if ((classify_object1.checked=false) or  (mosaic_mode) {ignore object name in mosaic} or
                ((object_to_process<>'') and (object_to_process=uppercase(ListView1.Items.item[c].subitems.Strings[L_object]))) ) {correct object?}
            then
            begin {correct object}
              defilter:=ListView1.Items.item[c].subitems.Strings[L_filter];
              if ( (AnsiCompareText(filter_name1,defilter)=0) or (AnsiCompareText(filter_name2,defilter)=0) ) then
              begin {correct filter}
                filters_used[i]:=defilter;
                files_to_process[c].name:=ListView1.items[c].caption;
                inc(image_counter);{one image more}
                ListView1.Items.item[c].SubitemImages[L_result]:=5;{mark 3th columns as done using a stacked icon}
                ListView1.Items.item[c].subitems.Strings[L_result]:=inttostr(object_counter)+'  ';{show image result number}
                inc(nrfiles);
                first_file:=c; {remember first found for case it is the only file}
                head.exposure:= strtofloat2(ListView1.Items.item[c].subitems.Strings[L_exposure]);{remember head.exposure time in case only one file, so no stack so unknown}
                if mosaic_mode then
                begin
                  backgr:=strtofloat2(ListView1.Items.item[c].subitems.Strings[L_background]);
                  min_background:=min(backgr,min_background);
                  max_background:=max(backgr,max_background);
                end;
              end;
            end;
          end;
        end;
        if nrfiles>0 then
        begin
          if nrfiles>1 then {more than one file}
          begin
            if mosaic_mode=false then put_best_quality_on_top(files_to_process);
            {else already sorted on position to be able to test overlapping of background difference in unit_stack_routines. The tiles have to be plotted such that they overlap for measurement difference}

            if sigma_mode then stack_sigmaclip(over_size,{var}files_to_process, counterL) {sigma clip combining}
            else
            if mosaic_mode then stack_mosaic(over_size,{var}files_to_process,abs(max_background-min_background),counterL) {mosaic combining}
                                                                  else stack_average(over_size,{var}files_to_process,counterL);{average}
            over_sizeL:=0; {do oversize only once. Not again in 'L' mode !!}
            if esc_pressed then  begin progress_indicator(-2,'ESC'); restore_img; Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;

            if ((over_size<>0) and ( head.cd1_1<>0){solution}) then {adapt astrometric solution for intermediate file}
            begin {adapt reference pixels of plate solution due to oversize}
              head.crpix1:=head.crpix1+over_size;
              if over_size>0 then
                head.crpix2:=head.crpix2+over_size
              else
                head.crpix2:=head.crpix2+round(over_size*head.height/head.width); {if oversize is negative then shrinking is done in ratio. Y shrinkage is done with factor round(oversize*height/width. Adapt head.crpix2 accordingly.}
              update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,head.crpix1);
              update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,head.crpix2);
            end;

            update_text('COMMENT 1','  Written by ASTAP. www.hnsky.org');
            update_text('CALSTAT =',#39+head.calstat+#39);

            if pos('D',head.calstat)>0 then
            begin
              update_integer('DATAMAX =',' / Maximum data value                             ',round(head.datamax_org)); {datamax is updated in stacking process. Use the last one}
              update_integer('DATAMIN =',' / Minimum data value                             ',round(pedestal_s));
              add_text   ('COMMENT ',' D='+ExtractFileName( last_dark_loaded ));
            end;
            if pos('F',head.calstat)>0 then add_text   ('COMMENT ',' F='+ExtractFileName( last_flat_loaded ));

            if sigma_mode then
              update_text   ('HISTORY 1','  Stacking method SIGMA CLIP AVERAGE')
              else
              update_text   ('HISTORY 1','  Stacking method AVERAGE');

            update_text   ('HISTORY 2','  Active filter: '+head.filter_name);{show which filter was used to combine}
            {original head.exposure is still maintained  }
            add_integer('LIGH_CNT=',' / Light frames combined.                  ' ,counterL); {for interim lum,red,blue...files.}
            add_integer('DARK_CNT=',' / Darks used for luminance.               ' ,head.dark_count);{for interim lum,red,blue...files. Compatible with master darks}
            add_integer('FLAT_CNT=',' / Flats used for luminance.               ' ,head.flat_count);{for interim lum,red,blue...files. Compatible with master flats}
            add_integer('BIAS_CNT=',' / Flat-darks used for luminance.          ' ,head.flatdark_count);{for interim lum,red,blue...files. Compatible with master flats}
            { ASTAP keyword standard:}
            { interim files can contain keywords: head.exposure, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
            { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

            if stackmenu1.use_manual_alignment1.checked then
            begin
              update_float('REF_X   =',' / Reference position for manual stacking. ' ,                      referenceX);{will be used later for alignment in mode 'L'}
              update_float('REF_Y   =',' / Reference position for manual stacking. ' ,referenceY);
            end;

            stack_info:=' '+inttostr(head.flatdark_count)+'x'+'FD  '+
                            inttostr(head.flat_count)+'x'+'F  '+
                            inttostr(head.dark_count)+'x'+'D  '+
                            inttostr(counterL)+'x'+head.filter_name;

            filename3:=filename2;
            filename2:=StringReplace(ChangeFileExt(filename2,'.fit'),'.fit','@ '+stack_info+'_stacked.fit',[]);{give new file name for any extension, FIT, FTS, fits}
            memo2_message('█ █ █ Saving as '+filename2);
            save_fits(img_loaded,filename2,-32,true {override});
            files_to_process_LRGB[i+1].name:=filename2;{should contain [nil,r,g,b,l]}

            if  ( (AnsiCompareText(luminance_filter1.text,filters_used[i])=0) or (AnsiCompareText(luminance_filter2.text,filters_used[i])=0) ) then
            begin
              files_to_process_LRGB[5].name:=filename2; {use this colour also for luminance!!}
              filters_used[4]:=filters_used[i];{store luminance filter}
              memo2_message('Filter '+filters_used[i]+' will also be used for luminance.');
            end;

            stack_info:='Interim result '+head.filter_name+' x '+inttostr(counterL);
            report_results(object_to_process,stack_info,object_counter,i {color icon});{report result in tab result using modified filename2}
            filename2:=filename3;{restore last filename}
          end{nrfiles>1}
          else
          begin
            files_to_process_LRGB[i+1]:=files_to_process[first_file]; {one file, no need to stack}

            if  ( (AnsiCompareText(luminance_filter1.text,filters_used[i])=0) or (AnsiCompareText(luminance_filter2.text,filters_used[i])=0) ) then
            begin
               files_to_process_LRGB[5]:=files_to_process[first_file]; {use this colour also for luminance!!}
               filters_used[4]:=filters_used[i];{store luminance filter}
               memo2_message('Filter '+filters_used[i]+' will also be used for luminance.');
            end;
            over_sizeL:=over_size;{do oversize in 'L'  routine}
            counterL:=1;
          end;

          case i  of 0: begin extra2:=extra2+'R'; end;
                     1: begin extra2:=extra2+'G';end;
                     2: begin extra2:=extra2+'B'; end;
                     3: begin extra2:=extra2+'-'; end;
                   else begin extra2:=extra2+'L'; end;
          end;{case}

          extra1:=extra1+head.filter_name;
        end;
      end;{for loop for 4 RGBL}

      if skip_combine=false then
      begin {combine colours}
        if length(extra2)>=2 then {at least two colors required}
        begin
          files_to_process_LRGB[0]:=files_to_process_LRGB[5];{use luminance as reference for alignment}  {contains, REFERENCE, R,G,B,RGB,L}
          if files_to_process_LRGB[0].name='' then  files_to_process_LRGB[0]:=files_to_process_LRGB[1]; {use red channel as reference is no luminance is available}
          if files_to_process_LRGB[0].name='' then  files_to_process_LRGB[0]:=files_to_process_LRGB[2]; {use green channel as reference is no luminance is available}


          stack_LRGB(over_sizeL {zero if already stacked from several files},files_to_process_LRGB, counter_colours); {LRGB method, files_to_process_LRGB should contain [REFERENCE, R,G,B,RGB,L]}
          if esc_pressed then  begin progress_indicator(-2,'ESC'); restore_img;Screen.Cursor :=Save_Cursor;    { back to normal }  exit;  end;
        end
        else
        if length(extra2)=1 then
        begin
           memo2.lines.add('Error! One color only. For LRGB stacking a minimum of two colors is required. Removed the check mark classify on "image filter" or add images made with a different color filter.');
           //filters_used[5]:=filters_used[i];
           lrgb:=false;{prevent runtime errors with head.naxis3=3}
        end;
      end;
    end;

    Screen.Cursor := Save_Cursor;  { Always restore to normal }
    if esc_pressed then begin progress_indicator(-2,'ESC'); restore_img;exit;end;


    if ((cal_and_align=false) and (skip_combine=false)) then {do not do this for calibration and alignment only, and skip combine}
    begin
      fits_file:=true;
      nrbits:=-32; {by definition. Required for stacking 8 bit files. Otherwise in the histogram calculation stacked data could be all above data_max=255}

      if ((monofile){success none lrgb loop} or (counter_colours<>0{length(extra2)>=2} {lrgb loop})) then
      begin
        if  counter_colours<>0{length(extra2)>=2} {lrgb loop} then
        begin
          if  stackmenu1.lrgb_auto_level1.checked then
          begin
            memo2_message('Adjusting colour levels as set in tab "stack method"');
            stackmenu1.auto_background_level1Click(nil);
            apply_factors;{histogram is after this action invalid}
            stackmenu1.reset_factors1Click(nil);{reset factors to default}

            if stackmenu1.green_purple_filter1.checked then
            begin
              memo2_message('Applying "remove green and purple" filter');
              green_purple_filter(img_loaded);
            end;

            use_histogram(img_loaded,true {update}); {plot histogram, set sliders}

            if stackmenu1.lrgb_colour_smooth1.checked then
            begin
              memo2_message('Applying colour-smoothing filter image as set in tab "stack method"');
              smart_colour_smooth(img_loaded,strtofloat2(lrgb_smart_smooth_width1.text),strtofloat2(lrgb_smart_colour_sd1.text),lrgb_preserve_r_nebula1.checked,false {get  hist});{histogram doesn't needs an update}
            end
          end
          else
          begin
            memo2_message('Adjusting colour levels and colour smooth are disabled. See tab "stack method"');
            use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
          end;
        end
        else
        begin
          if stackmenu1.make_osc_color1.checked then
          begin
            if  stackmenu1.osc_auto_level1.checked then
            begin
              memo2_message('Adjusting colour levels as set in tab "stack method"');
              stackmenu1.auto_background_level1Click(nil);
              apply_factors;{histogram is after this action invalid}
              stackmenu1.reset_factors1Click(nil);{reset factors to default}
              use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
              if stackmenu1.osc_colour_smooth1.checked then
              begin
                memo2_message('Applying colour-smoothing filter image as set in tab "stack method". Factors are set in tab pixel math 1');
                smart_colour_smooth(img_loaded,strtofloat2(osc_smart_smooth_width1.text),strtofloat2(osc_smart_colour_sd1.text),osc_preserve_r_nebula1.checked,false {get  hist});{histogram doesn't needs an update}
              end
            end
            else
            begin
              memo2_message('Adjusting colour levels and colour smooth are disabled. See tab "stack method"');
              use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
            end;
          end
          else {mono files}
          use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
        end;

        plot_fits(mainwindow.image1,true,true);{plot real}

        remove_key('DATE    ',false{all});{no purpose anymore for the original date written}
        remove_key('EXPTIME',false{all}); {remove, will be added later in the header}
        remove_key('EXPOSURE',false{all});{remove, will be replaced by LUM_EXP, RED_EXP.....}
        remove_key('CCD-TEMP',false{all});{remove, will be replaced by LUM_EXP, RED_EXP.....}
        remove_key('SET-TEMP',false{all});{remove, will be replaced by LUM_EXP, RED_EXP.....}
        remove_key('LIGH_CNT',false{all});{remove, will be replaced by LUM_CNT, RED_CNT.....}
        remove_key('DARK_CNT',false{all});{remove, will be replaced by LUM_DARK, RED_DARK.....}
        remove_key('FLAT_CNT',false{all});{remove, will be replaced by LUM_FLAT, RED_FLAT.....}
        remove_key('BIAS_CNT',false{all});{remove, will be replaced by LUM_BIAS, RED_BIAS.....}

        { ASTAP keyword standard:}
        { interim files can contain keywords: EXPTIME, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
        { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

        update_text   ('COMMENT 1','  Written by ASTAP. www.hnsky.org');

        head.calstat:=head.calstat+'S'; {status stacked}
        update_text ('CALSTAT =',#39+head.calstat+#39); {calibration status}

        if use_manual_alignment1.checked=false then {don't do this for manual stacking and moving object. Keep the date of the reference image for correct annotation of asteroids}
        begin
          remove_key('EXPOSURE',false{all});{remove, will be replaced by LUM_EXP, RED_EXP.....}
          head.date_obs:=jdToDate(jd_stop);
          update_text ('DATE-OBS=',#39+head.date_obs+#39);{give start point exposures}
          if ((head.naxis3=1) and (counterL>0)) then {works only for mono}
          begin
            update_float('JD-AVG  =',' / Julian Day of the observation mid-point.       ', jd_sum/counterL);{give midpoint of exposures}
            date_avg:=JdToDate(jd_sum/counterL); {update date_avg for asteroid annotation}
            update_text ('DATE-AVG=',#39+date_avg+#39);{give midpoint of exposures}
            add_text   ('COMMENT ',' UT midpoint in decimal notation: '+ UTdecimal(date_avg));
          end;
        end
        else;{keep head.exposure and head.date_obs from reference image for accurate asteroid annotation}

        if pos('D',head.calstat)>0 then add_text   ('COMMENT ','   D='+ExtractFileName( last_dark_loaded ));
        if pos('F',head.calstat)>0 then add_text   ('COMMENT ','   F='+ExtractFileName( last_flat_loaded ));

        if sigma_mode then
          update_text   ('HISTORY 1','  Stacking method SIGMA CLIP AVERAGE') else
             update_text   ('HISTORY 1','  Stacking method AVERAGE');{overwrite also any existing header info}

        if head.naxis3>1 then
        begin
          if make_osc_color1.checked then
          begin
            remove_key('BAYERPAT',false{all});{remove key word in header}
            remove_key('XBAYROFF',false{all});{remove key word in header}
            remove_key('YBAYROFF',false{all});{remove key word in header}
            update_text('HISTORY 2','  De-mosaic bayer pattern used '+bayer_pattern[bayerpattern_final]);
            update_text('HISTORY 3','  Colour conversion: '+ stackmenu1.demosaic_method1.text+ ' interpolation.')
          end
          else
          update_text('HISTORY 2','  Combined to colour image.');
        end
        else
           update_text('HISTORY 2','  Processed as gray scale images.');

        if lrgb=false then {monochrome}
        begin
          {adapt astrometric solution. For colour this is already done during luminance stacking}
          if ((over_size<>0) and ( head.cd1_1<>0){solution}) then {adapt astrometric solution for intermediate file}
          begin {adapt reference pixels of plate solution due to oversize}
            head.crpix1:=head.crpix1+over_size;
            if over_size>0 then
              head.crpix2:=head.crpix2+over_size
            else
            head.crpix2:=head.crpix2+round(over_size*head.height/head.width); {if oversize is negative then shrinking is done in ratio. Y shrinkage is done with factor round(oversize*height/width. Adapt head.crpix2 accordingly.}
            update_float  ('CRPIX1  =',' / X of reference pixel                           ' ,head.crpix1);
            update_float  ('CRPIX2  =',' / Y of reference pixel                           ' ,head.crpix2);
          end;

          head.exposure:=sum_exp;{for annotation asteroid}
          update_integer('EXPTIME =',' / Total luminance exposure time in seconds.      ' ,round(head.exposure));
          add_integer('LUM_EXP =',' / Average luminance exposure time.               ' ,exposureL);
          add_integer('LUM_CNT =',' / Luminance images combined.                     ' ,counterL);
          add_integer('LUM_DARK=',' / Darks used for luminance.                      ' ,head.dark_count);
          add_integer('LUM_FLAT=',' / Flats used for luminance.                      ' ,head.flat_count);
          add_integer('LUM_BIAS=',' / Flat-darks used for luminance.                 ' ,head.flatdark_count);
          add_integer('LUM_TEMP=',' / Set temperature used for luminance.            ' ,head.set_temperature);

          thefilters:=head.filter_name; {used later for file name}
          stack_info:=' '+inttostr(head.flatdark_count)+'x'+'FD  '+
                          inttostr(head.flat_count)+'x'+'F  '+
                          inttostr(head.dark_count)+'x'+'D  '+
                          inttostr(counterL)+'x'+inttostr(exposureL)+'L  ('+thefilters+')'; {head.exposure}
        end
        else {made LRGB color}
        begin
          head.naxis:=3;{will be written in save routine}
          head.naxis3:=3;{will be written in save routine, head.naxis3 is updated in  save_fits}
          if length(extra2)>1 then update_text('FILTER  =',#39+'        '+#39);{wipe filter info}
          head.exposure:=exposureL*counterL;{for annotation asteroid}
          update_integer('EXPTIME =',' / Total luminance exposure time in seconds.      ' ,round(head.exposure)); {could be used for midpoint. Download time are not included, so it is not perfect}

          if counterL>0 then
          begin
            add_integer('LUM_EXP =',' / Luminance exposure time.                       ' ,exposureL);
            add_integer('LUM_CNT =',' / Luminance images combined.                     ' ,counterL);
            add_integer('LUM_DARK=',' / Darks used for luminance.                      ' ,counterLdark);
            add_integer('LUM_FLAT=',' / Flats used for luminance.                      ' ,counterLflat);
            add_integer('LUM_BIAS=',' / Flat-darks used for luminance.                 ' ,counterLbias);
            add_integer('LUM_TEMP=',' / Set temperature used for luminance.            ' ,temperatureL);
          end;
          if counterR>0 then
          begin
            add_integer('RED_EXP =',' / Red exposure time.                             ' ,exposureR);
            add_integer('RED_CNT =',' / Red filter images combined.                    ' ,counterR);
            add_integer('RED_DARK=',' / Darks used for red.                            ' ,counterRdark);
            add_integer('RED_FLAT=',' / Flats used for red.                            ' ,counterRflat);
            add_integer('RED_BIAS=',' / Flat-darks used for red.                       ' ,counterRbias);
            add_integer('RED_TEMP=',' / Set temperature used for red.                  ' ,temperatureR);
          end;
          if counterG>0 then
          begin
            add_integer('GRN_EXP =',' / Green exposure time.                           ' ,exposureG);
            add_integer('GRN_CNT =',' / Green filter images combined.                  ' ,counterG);
            add_integer('GRN_DARK=',' / Darks used for green.                          ' ,counterGdark);
            add_integer('GRN_FLAT=',' / Flats used for green.                          ' ,counterGflat);
            add_integer('GRN_BIAS=',' / Flat-darks used for green.                     ' ,counterGbias);
            add_integer('GRN_TEMP=',' / Set temperature used for green.                ' ,temperatureG);
          end;
          if counterB>0 then
          begin
            add_integer('BLU_EXP =',' / Blue exposure time.                            ' ,exposureB);
            add_integer('BLU_CNT =',' / Blue filter images combined.                   ' ,counterB);
            add_integer('BLU_DARK=',' / Darks used for blue.                           ' ,counterBdark);
            add_integer('BLU_FLAT=',' / Flats used for blue.                           ' ,counterBflat);
            add_integer('BLU_BIAS=',' / Flat-darks used for blue.                      ' ,counterBbias);
            add_integer('BLU_TEMP=',' / Set temperature used for blue.                 ' ,temperatureB);
          end;
          if counterRGB>0 then
          begin
            add_integer('RGB_EXP =',' / OSC exposure time.                             ' ,exposureRGB);
            add_integer('RGB_CNT =',' / OSC images combined.                           ' ,counterRGB);
            add_integer('RGB_DARK=',' / Darks used for OSC.                            ' ,counterRGBdark);
            add_integer('RGB_FLAT=',' / Flats used for OSC.                            ' ,counterRGBflat);
            add_integer('RGB_BIAS=',' / Flat-darks used for OSC.                       ' ,counterRGBbias);
            add_integer('RGB_TEMP=',' / Set temperature used for OSC.                  ' ,temperatureRGB);
          end;

          if counterL>0 then add_text   ('COMMENT 2','  Total luminance exposure '+inttostr(round(counterL*exposureL))+', filter '+filters_used[4]);
          if counterR>0 then add_text   ('COMMENT 3','  Total red exposure       '+inttostr(round(counterR*exposureR))+', filter '+filters_used[0] );
          if counterG>0 then add_text   ('COMMENT 4','  Total green exposure     '+inttostr(round(counterG*exposureG))+', filter '+filters_used[1] );
          if counterB>0 then add_text   ('COMMENT 5','  Total blue exposure      '+inttostr(round(counterB*exposureB))+', filter '+filters_used[2] );
          if counterRGB>0 then add_text   ('COMMENT 6','  Total RGB exposure      '+inttostr(round(counterRGB*exposureRGB))+', filter '+filters_used[3] );
          { ASTAP keyword standard:}
          { interim files can contain keywords: EXPTIME, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
          { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}



          thefilters:='';
          for i:=0 to 4 do if length(filters_used[i])>0 then thefilters:=thefilters+' '+filters_used[i];
          thefilters:=trim(thefilters);

  //        thefilters:=filters_used[0]+' '+filters_used[1]+' '+filters_used[2]+' '+filters_used[3]; {for filename info}
          stack_info:=' '+inttostr(head.flatdark_count)+'x'+'FD  '+
                          inttostr(head.flat_count)+'x'+'F  '+
                          inttostr(head.dark_count)+'x'+'D  '+
                          inttostr(counterR)+'x'+inttostr(exposureR)+'R  '+
                          inttostr(counterG)+'x'+inttostr(exposureG)+'G  '+
                          inttostr(counterB)+'x'+inttostr(exposureB)+'B  '+
                          inttostr(counterRGB)+'x'+inttostr(exposureRGB)+'RGB  '+
                          inttostr(counterL)+'x'+inttostr(exposureL)+'L  ('+thefilters+')'; {head.exposure}
        end;

        filename2:=extractfilepath(filename2)+propose_file_name(mosaic_mode,object_to_process,thefilters);{give it a nice file name}

        if head.cd1_1<>0 then memo2_message('Astrometric solution reference file preserved for stack.');
        memo2_message('█ █ █  Saving result '+inttostr(image_counter)+' as '+filename2);
        save_fits(img_loaded,filename2,-32, true);


        if head.naxis3>1 then report_results(object_to_process,stack_info,object_counter,3 {color icon}) {report result in tab results}
                    else report_results(object_to_process,stack_info,object_counter,4 {gray icon}); {report result in tab results}

        {close the window}
      end; {not zero count}
    end; {not calibration and alignment}
    Application.ProcessMessages;{look for keyboard instructions}
    total_counter:=total_counter+counterL; {keep record of lights done}

  until ((counterL=0){none lrgb loop} and (extra1=''){lrgb loop} );{do all names}


  if total_counter=0 then {somehow nothing was stacked}
  begin
    memo2.lines.add('No images to stack.');
    if classify_filter1.checked then memo2.lines.add('Hint: remove check mark from classify by "image filter" if required.');
    if classify_object1.checked then memo2.lines.add('Hint: remove check mark from classify by "image object" if required.');
    if use_astrometry_internal1.checked then memo2.lines.add('Hint: check field of view camera in tab alignment.');
  end
  else
  memo2.lines.add('Finished in '+IntToStr( round((gettickcount64 - startTick)/1000)) + ' sec. The FITS header contains a detailed history.');


  {$IFDEF fpc}
  progress_indicator(-100,'');{back to normal}
  {$else} {delphi}
  mainwindow.taskbar1.progressstate:=TTaskBarProgressState.None;
  {$endif}

  update_menu(true);

  img_temp:=nil;{remove used memory}
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
      wait(1000);  {smart sleep}
//      application.processmessages;
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
   method : integer;
   sigm, mosa,cal_and_align,cal_only : boolean;
begin
  method:=stack_method1.ItemIndex;
  sigm:=(method in [1,6]);{sigma clip}
  mosa:=(method=2);{mosaic}
  cal_and_align:=(method=3);{}
  cal_only:=(method=4);{}

  mosaic_box1.enabled:=mosa;
  raw_box1.enabled:=(mosa=false);
  filter_groupbox1.enabled:=(mosa=false);
  sd_factor1.enabled:=sigm;

  if ((use_astrometry_internal1.checked=false) and (mosa)) then
  begin
    use_astrometry_internal1.checked:=true;
    memo2_message('Switched to INTERNAL ASTROMETRIC alignment. Set in tab aligment the mosaic width and height high enough to have enough work space.');
  end;
  if mosa then memo2_message('Astrometric image stitching mode. This will stitch astrometric tiles. Prior to this stack the images to tiles and check for clean edges. If not use the "Crop each image function". For flat background apply artificial flat in tab pixel math1 in advance if required.');

  classify_object1.enabled:=(mosa=false); {in mosaic mode ignore object name}
  oversize1.enabled:=(mosa=false); {in mosaic mode ignore this oversize setting}

  classify_filter1.enabled:=((cal_and_align=false) and (cal_only=false));
  classify_object1.enabled:=(cal_only=false);

  stack_button1.caption:='STACK  ('+stack_method1.text+')';

  if ((method>=5) and (classify_filter1.Checked=false)) then  memo2_message('█ █ █ █ █ █ Warning, classify on Image Filter is not check marked !!! █ █ █ █ █ █ ')
end;


procedure Tstackmenu1.use_astrometry_internal1Change(Sender: TObject);
begin
  update_stackmenu;
end;


procedure Tstackmenu1.use_ephemeris_alignment1Change(Sender: TObject);
begin
  update_stackmenu;
end;


procedure Tstackmenu1.use_manual_alignment1Change(Sender: TObject);
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

  memo2_message('Remove gradient started.');
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }

  backup_img;

  step:=round(strtofloat2(gradient_filter_factor1.text));

  mean:=0;
  counter:=0;

  {vertical}
  if sender=apply_vertical_gradient1 then
  for k:=0 to head.naxis3-1 do {do all colors}
  begin
   for fitsY:=0 to (head.height-1) div step do
     begin
       y1:=(step+1)*fitsY-(step div 2);
       y2:=(step+1)*fitsY+(step div 2);
       most_common:=mode(img_backup[index_backup].img,k,0,head.width-1,y1,y2,32000);
       mean:=mean+most_common;
       inc(counter);
       for i:=y1 to y2 do
         for fitsX:=0 to head.width-1 do
         begin
           if ((i>=0) and (i<=head.height-1)) then
           img_loaded[k,fitsX,i]:=most_common;{store common vertical values}
         end;
     end;
  end;{K}

  {horizontal}
  if sender=apply_horizontal_gradient1 then
  for k:=0 to head.naxis3-1 do {do all colors}
  begin
   for fitsX:=0 to (head.width-1) div step do
     begin
       x1:=(step+1)*fitsX-(step div 2);
       x2:=(step+1)*fitsX+(step div 2);
       most_common:=mode(img_backup[index_backup].img,k,x1,x2,0,head.height-1,32000);
       mean:=mean+most_common;
       inc(counter);
       for i:=x1 to x2 do
         for fitsY:=0 to head.height-1 do
         begin
           if ((i>=0) and (i<=head.width-1)) then
             img_loaded[k,i,fitsY]:=most_common;{store common vertical values}
         end;
     end;
  end;{K}

  mean:=mean/counter;
  gaussian_blur2(img_loaded,step*2);

  for k:=0 to head.naxis3-1 do {do all colors}
  begin
      for fitsY:=0 to head.height-1 do
       for fitsX:=0 to head.width-1 do
        begin
          img_loaded[k,fitsX,fitsY]:=mean+img_backup[index_backup].img[k,fitsX,fitsY]-img_loaded[k,fitsX,fitsY];
        end;
  end;{k color}

  use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1,false,true);

  memo2_message('Remove gradient done.');

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
  if sender=Viewimage7 then
  begin
     listview_view(listview7);
    if ((checkBox_annotate1.checked) and (pagecontrol1.tabindex=8 {photometry} )) then
     begin
       load_variable; { Load the database once. If loaded no action}
       plot_deepsky;  {plot the variable annotations image}
     end;

  end;
  if sender=Viewimage8 then listview_view(listview8);{inspector}
  if sender=Viewimage9 then listview_view(listview9);{mount}
end;


procedure Tstackmenu1.write_video1click(Sender: TObject);
var
  framerate: string;
begin
  mainwindow.savedialog1.filename:=ChangeFileExt(FileName2,'.y4m');
  mainwindow.savedialog1.initialdir:=ExtractFilePath(filename2);

  mainwindow.savedialog1.Filter := ' *.y4m|*.y4m';
  if mainwindow.savedialog1.execute then
  begin

    framerate:=InputBox('Video frame rate in [frames/second]:','','6' );
    if framerate=''  then exit;

    if listview6.Items.item[listview6.items.count-1].subitems.Strings[B_exposure]='' {head.exposure} then
      stackmenu1.analyseblink1Click(nil);  {analyse and secure the dimension values head.width, head.height from lights}

    write_YUV4MPEG2_header(mainwindow.savedialog1.filename,framerate,((head.naxis3>1) or (mainwindow.preview_demosaic1.checked)) );
    stackmenu1.blink_button1Click(Sender);{blink and write video frames}
    close_YUV4MPEG2;
    memo2_message('Ready!. See tab results. The video written as '+mainwindow.savedialog1.filename);

    filename2:=mainwindow.savedialog1.filename;
    report_results('Video file','',0,15 {video icon});{report result in tab results}
  end;
end;

end.
