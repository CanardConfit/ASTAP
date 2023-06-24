unit unit_stack;

{Copyright (C) 2017, 2023 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
 {$IFDEF fpc}
 {$else}{delphi}
  {$endif}
 {$ifdef mswindows}
  Windows,
  ShlObj,{for copy file(s) to clipboard}
   {$IFDEF fpc}{mswindows & FPC}
   {$else}{delphi}
  system.Win.TaskbarCore, Vcl.ImgList,
 {$endif}
 {$else} {unix}
  LCLType, {for vk_...}
  unix, {for fpsystem}
 {$endif}
  SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ComCtrls, StdCtrls,
  Math, ExtCtrls, Menus, Buttons,
  LCLIntf,{for for getkeystate, selectobject, openURL}
  clipbrd, Types, strutils,
  unit_star_database,
  astap_main;

type
  { Tstackmenu1 }
  Tstackmenu1 = class(TForm)
    actual_search_distance1: TLabel;
    add_noise1: TButton;
    add_substract1: TComboBox;
    add_time1: TCheckBox;
    apply_gaussian_blur_button2: TButton;
    bin_image2: TButton;
    Button2: TButton;
    ClearButton1: TButton;
    contour_gaussian1: TComboBox;
    colournebula1: TButton;
    filter_artificial_colouring1: TComboBox;
    GroupBox14: TGroupBox;
    GroupBox20: TGroupBox;
    GroupBox21: TGroupBox;
    increase_nebulosity3: TEdit;
    GroupBox19: TGroupBox;
    Label16: TLabel;
    Label19: TLabel;
    label_gaussian1: TLabel;
    Label39: TLabel;
    Label4: TLabel;
    refresh_astrometric_solutions1: TMenuItem;
    photometric_calibration1: TMenuItem;
    photom_blue1: TMenuItem;
    photom_red1: TMenuItem;
    Separator2: TMenuItem;
    Separator3: TMenuItem;
    Separator4: TMenuItem;
    contour_sigma1: TComboBox;
    transformation1: TButton;
    remove_stars1: TBitBtn;
    GroupBox18: TGroupBox;
    reference_database1: TComboBox;
    Annotations_visible2: TCheckBox;
    clear_result_list1: TButton;
    column_fov1: TMenuItem;
    column_sqm1: TMenuItem;
    column_lim_magn1: TMenuItem;
    new_colour_luminance1: TTrackBar;
    increase_nebulosity1: TBitBtn;
    save_settings_image_path1: TCheckBox;
    annotate_mode1: TComboBox;
    browse1: TBitBtn;
    browse_blink1: TBitBtn;
    browse_monitoring1: TBitBtn;
    browse_mount1: TBitBtn;
    browse_live_stacking1: TBitBtn;
    Button1: TButton;
    calculated_sensor_size1: TLabel;
    donutstars1: TCheckBox;
    check_pattern_filter1: TCheckBox;
    auto_select1: TMenuItem;
    photom_stack1: TMenuItem;
    photom_calibrate1: TMenuItem;
    photom_green1: TMenuItem;
    Separator1: TMenuItem;
    star_level_colouring1: TComboBox;
    target_altitude1: TLabel;
    target_azimuth1: TLabel;
    direction_arrow1: TImage;
    label_latitude1: TLabel;
    label_longitude1: TLabel;
    monitor_latitude1: TEdit;
    monitor_longitude1: TEdit;
    test_osc_normalise_filter2: TButton;
    undo_button17: TBitBtn;
    undo_button18: TBitBtn;
    undo_button19: TBitBtn;
    undo_button20: TBitBtn;
    undo_button8: TBitBtn;
    use_triples1: TCheckBox;
    MenuItem33: TMenuItem;
    target_distance1: TLabel;
    target_group1: TGroupBox;
    delta_ra1: TLabel;
    delta_dec1: TLabel;
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
    classify_flat_date1: TCheckBox;
    classify_flat_exposure1: TCheckBox;
    hours_and_minutes1: TCheckBox;
    center_position1: TLabel;
    calculator_binning1: TLabel;
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
    changekeyword6: TMenuItem;
    changekeyword7: TMenuItem;
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
    target1: TLabel;
    undo_button6: TBitBtn;
    unselect9: TMenuItem;
    Viewimage9: TMenuItem;
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
    UpDown_nebulosity1: TUpDown;
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
    clear_blink_alignment1: TButton;
    clear_blink_list1: TButton;
    clear_inspector_list1: TButton;
    clear_dark_list1: TButton;
    clear_image_list1: TButton;
    clear_photometry_list1: TButton;
    clear_selection2: TButton;
    clear_selection3: TButton;
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
    files_live_stacked1: TLabel;
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
    Label17: TLabel;
    Label18: TLabel;
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
    //  xxxxxxx: TComboBox;
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
    memo2: TMemo;
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
    procedure alignment1Show(Sender: TObject);
    procedure align_blink1Change(Sender: TObject);
    procedure analyseblink1Click(Sender: TObject);
    procedure annotate_mode1Change(Sender: TObject);
    procedure Annotations_visible2Click(Sender: TObject);
    procedure apply_gaussian_blur_button2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ClearButton1Click(Sender: TObject);
    procedure photometric_calibration1Click(Sender: TObject);
    procedure refresh_astrometric_solutions1Click(Sender: TObject);
    procedure remove_stars1Click(Sender: TObject);
    procedure browse_monitoring1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure calibrate_prior_solving1Change(Sender: TObject);
    procedure clear_result_list1Click(Sender: TObject);
    procedure column_fov1Click(Sender: TObject);
    procedure column_lim_magn1Click(Sender: TObject);
    procedure column_sqm1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure help_monitoring1Click(Sender: TObject);
    procedure help_mount_tab1Click(Sender: TObject);
    procedure lightsShow(Sender: TObject);
    procedure listview1ItemChecked(Sender: TObject; Item: TListItem);
    procedure live_monitoring1Click(Sender: TObject);
    procedure auto_select1Click(Sender: TObject);
    procedure make_osc_color1Click(Sender: TObject);
    procedure manipulate1Click(Sender: TObject);
    procedure monitoring_stop1Click(Sender: TObject);
    procedure lrgb_auto_level1Change(Sender: TObject);
    procedure keywordchangelast1Click(Sender: TObject);
    procedure keywordchangesecondtolast1Click(Sender: TObject);
    procedure calc_polar_alignment_error1Click(Sender: TObject);
    procedure monitor_action1Change(Sender: TObject);
    procedure monitor_latitude1EditingDone(Sender: TObject);
    procedure monitor_longitude1EditingDone(Sender: TObject);
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
    procedure listview8CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
    procedure listview8CustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: integer; State: TCustomDrawState;
      var DefaultDraw: boolean);
    procedure live_stacking1Click(Sender: TObject);
    procedure copy_files_to_clipboard1Click(Sender: TObject);
    procedure most_common_mono1Click(Sender: TObject);
    procedure mount_add_solutions1Click(Sender: TObject);
    procedure new_colour_luminance1Change(Sender: TObject);
    procedure new_saturation1Change(Sender: TObject);
    procedure check_pattern_filter1Change(Sender: TObject);
    procedure pagecontrol1Change(Sender: TObject);
    procedure pagecontrol1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure photom_calibrate1Click(Sender: TObject);
    procedure photom_green1Click(Sender: TObject);
    procedure photom_stack1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure press_esc_to_abort1Click(Sender: TObject);
    procedure rainbow_Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure rainbow_Panel1Paint(Sender: TObject);
    procedure reference_database1Change(Sender: TObject);
    procedure remove_luminance1Change(Sender: TObject);
    procedure result_compress1Click(Sender: TObject);
    procedure rename_result1Click(Sender: TObject);
    procedure restore_file_ext1Click(Sender: TObject);
    procedure colournebula1Click(Sender: TObject);
    procedure clear_photometry_list1Click(Sender: TObject);
    procedure export_aligned_files1Click(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure FormPaint(Sender: TObject);
    procedure help_blink1Click(Sender: TObject);
    procedure help_photometry1Click(Sender: TObject);
    procedure listview7CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: boolean);
    procedure listview7CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
    procedure live_stacking_pause1Click(Sender: TObject);
    procedure live_stacking_restart1Click(Sender: TObject);
    procedure more_indication1Click(Sender: TObject);
    procedure photometry_binx2Click(Sender: TObject);
    procedure photometry_button1Click(Sender: TObject);
    procedure saturation_tolerance1Change(Sender: TObject);
    procedure save_result1Click(Sender: TObject);
    procedure save_settings_extra_button1Click(Sender: TObject);
    procedure smart_colour_smooth_button1Click(Sender: TObject);
    procedure classify_filter1Click(Sender: TObject);
    procedure apply_get_background1Click(Sender: TObject);
    procedure help_osc_menu1Click(Sender: TObject);
    procedure help_uncheck_outliers1Click(Sender: TObject);
    procedure listview6CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
    procedure list_to_clipboard1Click(Sender: TObject);
    procedure selectall1Click(Sender: TObject);
    procedure apply_remove_background_colour1Click(Sender: TObject);
    procedure reset_factors1Click(Sender: TObject);
    procedure search_fov1Change(Sender: TObject);
    procedure solve_and_annotate1Change(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure stack_method1DropDown(Sender: TObject);
    procedure star_database1Change(Sender: TObject);
    procedure star_database1DropDown(Sender: TObject);
    procedure apply_box_filter2Click(Sender: TObject);
    procedure tab_blink1Show(Sender: TObject);
    procedure tab_monitoring1Show(Sender: TObject);
    procedure tab_photometry1Show(Sender: TObject);
    procedure tab_Pixelmath1Show(Sender: TObject);
    procedure tab_Pixelmath2Show(Sender: TObject);
    procedure tab_stackmethod1Show(Sender: TObject);
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
      var DefaultDraw: boolean);
    procedure listview1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
    procedure listview2CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: boolean);
    procedure listview2CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
    procedure listview3CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: boolean);
    procedure listview3CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
    procedure listview4CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: boolean);
    procedure listview4CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
    procedure listview6CustomDraw(Sender: TCustomListView; const ARect: TRect;
      var DefaultDraw: boolean);
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
    procedure listview1KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
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
    procedure transformation1Click(Sender: TObject);
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
      Data: integer; var Compare: integer);
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
    SortedColumn: integer;

  public
    { Public declarations }
  end;

var
  stackmenu1: Tstackmenu1;

type
  TfileToDo = record
    Name: string;
    listviewindex: integer;
  end;

type
  tstarlistpackage = record {for photometry tab}
    Width: integer;
    Height: integer;
    mzero: double;
    starlist: star_list;
  end;

var
  starlistpack: array of tstarlistpackage;{for photometry tab}


var
  calc_scale: double;
  counterR, counterG, counterB, counterRGB, counterL, counterRdark, counterGdark,
  counterBdark, counterRGBdark, counterLdark, counterRflat, counterGflat,
  counterBflat, counterRGBflat, counterLflat, counterRbias, counterGbias,
  counterBbias, counterRGBbias, counterLbias,
  temperatureL, temperatureR, temperatureG, temperatureB, temperatureRGB,
  exposureR, exposureG, exposureB, exposureRGB, exposureL: integer;
  sum_exp, sum_temp, photometry_stdev: double;
  referenceX, referenceY: double;{reference position used stacking}
  jd_mid: double;{julian day of mid head.exposure}
  jd_sum: double;{sum of julian days}
  jd_stop: double;{end observation in julian days}
  files_to_process, files_to_process_LRGB: array of
  TfileToDo;{contains names to process and index to listview1}
  areay1, areay2: integer;
  hue1, hue2: single;{for colour disk}
  asteroidlist: array of array of array of double;
  solve_show_log: boolean;
  process_as_osc: integer;//1=auto 2=forced process as OSC image


var  {################# initialised variables #########################}
  areaX1: integer = 0; {for set area}
  areaX2: integer = 0;
  dark_exposure: integer = 987654321;{not done indication}
  dark_temperature: integer = 987654321;
  dark_gain: string = '987654321';
  flat_filter: string = '987654321';{not done indication}
  last_light_jd: integer = 987654321;
  last_flat_loaded: string = '';
  last_dark_loaded: string = '';

  new_analyse_required: boolean = False;{if changed then reanalyse tab 1}
  new_analyse_required3: boolean = False;{if changed then reanalyse tab 3}
  quads_displayed: boolean = False;{no quads visible, so no refresh required}
  equalise_background_step: integer = 1;
  ra_target: double = 999;
  dec_target: double = 999;
  jd_start: double = 0;{julian day of date-obs}


const
  dialog_filter =
    'FITS, RAW, TIFF |*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;*.tif;*.tiff;*.TIF;*.xisf;'
    +
    '*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;' + '|FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.fz;' + '|JPEG, TIFF, PNG PPM files|*.png;*.PNG;*.tif;*.tiff;*.TIF;*.jpg;*.JPG;*.ppm;*.pgm;*.pbm;*.pfm;*.xisf;' + '|RAW files|*.RAW;*.raw;*.CRW;*.crw;*.CR2;*.cr2;*.CR3;*.cr3;*.KDC;*.kdc;*.DCR;*.dcr;*.MRW;*.mrw;*.ARW;*.arw;*.NEF;*.nef;*.NRW;.nrw;*.DNG;*.dng;*.ORF;*.orf;*.PTX;*.ptx;*.PEF;*.pef;*.RW2;*.rw2;*.SRW;*.srw;*.RAF;*.raf;';

procedure listview_add(tl: tlistview; s0: string; is_checked: boolean; Count: integer);
procedure listview_add_xy(fitsX, fitsY: double);{add x,y position to listview}
procedure update_equalise_background_step(pos1: integer);{update equalise background menu}
procedure memo2_message(s: string);{message to memo2}
procedure update_tab_alignment;{update stackmenu1 menus}
procedure box_blur(colors, range: integer;  var img: image_array);{combine values of pixels, ignore zeros}
procedure check_pattern_filter(var img: image_array); {normalize bayer pattern. Colour shifts due to not using a white light source for the flat frames are avoided.}
procedure black_spot_filter(var img: image_array); {remove black spots with value zero}{execution time about 0.4 sec}

function create_internal_solution(img: image_array; hd: theader): boolean; {plate solving, image should be already loaded create internal solution using the internal solver}
function apply_dark_and_flat(var img: image_array): boolean; inline;{apply dark and flat if required, renew if different head.exposure or ccd temp}

procedure smart_colour_smooth(var img: image_array; wide, sd: double; preserve_r_nebula, measurehist: boolean);{Bright star colour smooth. Combine color values of wide x wide pixels, keep luminance intact}
procedure green_purple_filter(var img: image_array);{Balances RGB to remove green and purple. For e.g. Hubble palette}
procedure date_to_jd(date_time: string; exp: double); {convert date_obs string and exposure time to global variables jd_start (julian day start exposure) and jd_mid (julian day middle of the exposure)}
function JdToDate(jd: double): string;{Returns Date from Julian Date}
procedure resize_img_loaded(ratio: double); {resize img_loaded in free ratio}
function median_background(var img: image_array; color, sizeX, sizeY, x, y: integer): double; {find median value of an area at position x,y with sizeX,sizeY}
procedure analyse_image(img: image_array; head: Theader; snr_min: double; report: boolean;  out star_counter: integer; out bck :Tbackground;out hfd_median: double);{find background, number of stars, median HFD}

procedure sample(sx, sy: integer);{sampe local colour and fill shape with colour}
procedure apply_most_common(sourc, dest: image_array; radius: integer); {apply most common filter on first array and place result in second array}

procedure report_results(object_to_process, stack_info: string; object_counter, colorinfo: integer);{report on tab results}
procedure apply_factors;{apply r,g,b factors to image}
procedure listviews_begin_update; {speed up making stackmenu visible having a many items}
procedure listviews_end_update;{speed up making stackmenu visible having a many items}
procedure analyse_listview(lv: tlistview; light, full, refresh: boolean);{analyse list of FITS files}
function julian_calc(yyyy, mm: integer; dd, hours, minutes, seconds: double): double;{##### calculate julian day, revised 2017}
function RemoveSpecialChars(const STR: string): string; {remove ['.','\','/','*','"',':','|','<','>']}
procedure trendline_without_outliers(xylist: star_list; len{length xylist} : integer; out  slope, intercept,sd: double);//find linear trendline Y = magnitude_slope*X + intercept. Remove outliers in step 2



const
  L_object = 0; {lights, position in listview1}
  L_filter = 1;
  L_result = 2;
  L_bin = 3;
  L_hfd = 4;
  L_quality = 5;
  L_background = 6;
  L_nrstars = 7;
  L_sharpness = 8;
  L_exposure = 9;
  L_temperature = 10;
  L_width = 11;
  L_height = 12;
  L_type = 13;
  L_datetime = 14;
  L_position = 15;

  L_gain = 16;
  L_solution = 17;
  L_x = 18;
  L_y = 19;
  L_calibration = 20;
  L_focpos = 21;
  L_foctemp = 22;

  L_centalt = 23;
  L_centaz = 24;
  L_sqm = 25;
  L_nr = 26;{number of fields}

  D_exposure = 0;
  D_temperature = 1;
  D_binning = 2;
  D_width = 3;
  D_height = 4;
  D_type = 5;
  D_date = 6;
  D_background = 7;
  D_sigma = 8;
  D_gain = 9;
  D_jd = 10;
  D_nr = 11;{number of fields}

  F_exposure = 0;  {flats}
  F_filter = 10;
  F_jd = 11;
  F_calibration = 12;
  F_nr = 13;{number of fields}

  FD_exposure = 0;  {flat_darks}
  FD_nr = 10;{flat darks}

  B_exposure = 0;  {blink}
  B_temperature = 1;
  B_binning = 2;
  B_width = 3;
  B_height = 4;
  B_type = 5;
  B_date = 6;
  B_calibration = 7;
  B_solution = 8;
  B_annotated = 9;
  B_nr = 10;{number of fields}

  P_exposure = 0;       {photometry tab}
  P_temperature = 1;
  P_binning = 2;
  P_width = 3;
  P_height = 4;
  P_type = 5;
  P_background = 6;
  P_filter = 7;
  P_date = 8;
  P_jd_mid = 9;
  P_jd_helio = 10;
  P_magn1 = 11;
  P_snr = 12;
  P_magn2 = 13;
  P_magn3 = 14;
  P_hfd = 15;
  P_stars = 16;
  P_astrometric = 17;
  P_photometric = 18;
  P_calibration = 19;
  P_centalt = 20;
  P_airmass = 21;
  P_limmagn = 22;
  P_nr = 23;{number of fields}

  I_date = 6;//inspector tab
  I_nr_stars = 7;
  I_focus_pos = 8;


  M_exposure = 0;  {mount analyse}
  M_temperature = 1;
  M_binning = 2;
  M_width = 3;
  M_height = 4;
  M_type = 5;
  M_date = 6;
  M_jd_mid = 7;

  M_ra = 8;
  M_dec = 9;

  M_ra_m = 10;
  M_dec_m = 11;

  M_ra_e = 12;
  M_dec_e = 13;

  M_ra_jnow = 14;
  M_dec_jnow = 15;

  M_ra_m_jnow = 16;
  M_dec_m_jnow = 17;

  M_centalt = 18;
  M_centaz = 19;
  M_crota_jnow = 20;
  M_foctemp = 21;
  M_pressure = 22;
  M_nr = 23;{number of fields}


  icon_thumb_down = 8; {image index for outlier}
  icon_king = 9 {16};{image index for best image}


  video_index: integer = 1;
  frame_rate: string = '1';


implementation

uses
  unit_image_sharpness, unit_gaussian_blur, unit_star_align,
  unit_astrometric_solving, unit_stack_routines, unit_annotation, unit_hjd,
  unit_live_stacking, unit_monitoring, unit_hyperbola, unit_asteroid, unit_yuv4mpeg2,
  unit_avi, unit_aavso, unit_raster_rotate, unit_listbox, unit_aberration, unit_online_gaia, unit_disk,
  unit_contour;

type
  blink_solution = record
    solution_vectorX: solution_vector {array[0..2] of double};
    solution_vectorY: solution_vector;
  end;

var
  bsolutions: array of blink_solution;


{$IFDEF fpc}
  {$R *.lfm}
{$else}{delphi}
 {$R *.lfm}
{$endif}

{$ifdef mswindows}
function ShutMeDown: string;
var
  hToken: THandle;
  tkp, memo2: TTokenPrivileges;
  RetLen: DWord;
  ExReply: longbool;
  Reply: DWord;
begin
  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, hToken) then
  begin
    if LookupPrivilegeValue(nil, 'SeShutdownPrivilege', tkp.Privileges[0].Luid) then
    begin
      tkp.PrivilegeCount := 1;
      tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      AdjustTokenPrivileges(hToken, False, tkp, SizeOf(TTokenPrivileges), memo2, RetLen);
      Reply := GetLastError;
      if Reply = ERROR_SUCCESS then
      begin
        ExReply := ExitWindowsEx(EWX_POWEROFF or EWX_FORCE, 0);
        if ExReply then Result := 'Shutdown Initiated'
        else
          Result := 'Shutdown failed with ' + IntToStr(GetLastError);
      end;
    end;
  end;
end;

{$else} {unix}
{$endif}


function inverse_erf(x: double): double;  {Inverse of erf function. Inverse of approximation formula by Sergei Winitzki. Error in result is <0.005 for sigma [0..3] Source wikipedia https://en.wikipedia.org/wiki/Error_function}
const                                     {input part of population [0..1] within, result is the standard deviation required for the input}
  a = 0.147;
begin
  if x < 0.99999 then
    Result := sqrt(sqrt(sqr((2 / (pi * a)) + ln(1 - x * x) / 2) - (ln(1 - x * x) / a)) - (2 / (pi * a) + ln(1 - x * x) / 2))
  else
    Result := 99.99;
end;


procedure update_tab_alignment;{update stackmenu1 menus, called onshow stackmenu1}
begin
  with stackmenu1 do
  begin {set bevel colours}
    Panel_solver1.bevelouter := bvNone;
    Panel_star_detection1.bevelouter := bvNone;
    Panel_solver1.color := clForm;
    Panel_star_detection1.color := clForm;

    panel_manual1.color := clForm;
    panel_ephemeris1.color := clForm;

    min_star_size_stacking1.Enabled := False;

    if use_star_alignment1.Checked then
    begin
      Panel_star_detection1.bevelouter := bvSpace; {blue corner}
      Panel_star_detection1.color := CLWindow;
      min_star_size_stacking1.Enabled := True;
    end
    else
    if use_astrometry_internal1.Checked then
    begin
      Panel_solver1.bevelouter := bvSpace;
      Panel_solver1.color := CLWindow;
      Panel_star_detection1.color := CLWindow;
    end
    else
    if use_manual_alignment1.Checked then
    begin
      panel_manual1.bevelouter := bvSpace;
      panel_manual1.color := CLWindow;
    end
    else
    if use_ephemeris_alignment1.Checked then
    begin
      panel_ephemeris1.bevelouter := bvSpace;
      panel_ephemeris1.color := CLWindow;
    end;
  end;{stack menu}
end;


function ansi_only(s: string): string;
begin
  Result := StringReplace(s, 'Δ', 'offset', [rfReplaceAll]);
  Result := StringReplace(Result, 'α', 'RA', [rfReplaceAll]);
  Result := StringReplace(Result, 'δ', 'DEC', [rfReplaceAll]);
end;


procedure memo2_message(s: string);
{message to memo2. Is also used for log to file in commandline mode}
begin
  {$IFDEF unix}  {linux and mac}
  if commandline_execution then
    writeln(s); {linux command line can write unicode}
  {$ELSE }
  if ((commandline_execution) and (isConsole)) then
    {isconsole, is console available, prevent run time error if compiler option -WH is checked}
    writeln(ansi_only(s)); {log to console for Windows when compiler WIN32 gui is off}
  {$ENDIF}

  if ((commandline_execution = False) or (commandline_log = True)) then
    {no commandline or option -log is used}
  begin
    stackmenu1.memo2.Lines.add(TimeToStr(time) + '  ' + s); {fill memo2 with log}

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


procedure listview_add(tl: tlistview; s0: string; is_checked: boolean; Count: integer);
var
  ListItem: TListItem;
  i: integer;
begin
  with tl do {stackmenu.listview2}
  begin
    {Items.BeginUpdate; is set before calling this procedure}
    ListItem := Items.Add;
    ListItem.Caption := s0;{with checkbox}
    ListItem.Checked := is_checked;
    for i := 1 to Count do
      ListItem.SubItems.Add('');
    //    Items[items.Count-1].Checked:=true;
    {Items.EndUpdate; is set after calling this procedure}
  end;
end;


procedure listview_add_xy(fitsX, fitsY: double);{add x,y position to listview}
var
  i: integer;
begin
  with stackmenu1 do
    for i := 0 to listview1.Items.Count - 1 do
      if listview1.Items[i].Selected then
      begin
        ListView1.Items.item[i].subitems.Strings[L_X] := floattostrF(fitsX, ffFixed, 0, 2);
        ListView1.Items.item[i].subitems.Strings[L_Y] := floattostrF(fitsY, ffFixed, 0, 2);

    {$ifdef darwin} {MacOS}
    {bugfix darwin green red colouring}
    stackmenu1.ListView1.Items.item[i].Subitems.strings[L_result]:='✓ star';
    {$endif}
      end;
end;


procedure listview5_add(tl: tlistview; s0, s1, s2, s3, s4, s5, s6: string);
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

procedure count_selected;
{report the number of lights selected in images_selected and update menu indication}
var
  c, images_selected: integer;
begin
  images_selected := 0;
  for c := 0 to stackmenu1.ListView1.items.Count - 1 do
    if stackmenu1.ListView1.Items[c].Checked then Inc(images_selected, 1);
  stackmenu1.nr_selected1.Caption := IntToStr(images_selected);{update menu info}

  {temporary fix for CustomDraw not called}
  {$ifdef darwin} {MacOS}
  stackmenu1.nr_total1.caption:=inttostr(stackmenu1.listview1.items.count);{update counting info}
  {$endif}


end;


function add_unicode(u, tekst: string): string;
begin
  Result := stringreplace(tekst, '♛', '', [rfReplaceAll]);//remove crown
  Result := stringreplace(Result, '👎', '', [rfReplaceAll]);//remove thumb down
  Result := u + Result;
end;

procedure list_remove_outliers(key: string); {do statistics}
var
  quality_mean, quality_sd, sd_factor: double;
  c, counts, nr_good_images, quality, best, best_index: integer;
  sd: string;
begin
  best := 0;
  with stackmenu1 do
  begin
    counts := ListView1.items.Count - 1;

    ListView1.Items.BeginUpdate;
    try
      {calculate means}
      c := 0;
      quality_mean := 0;
      nr_good_images := 0;
      repeat
        if ((ListView1.Items.item[c].Checked) and
          (key = ListView1.Items.item[c].subitems.Strings[L_result])) then
        begin {checked}
          if strtofloat(ListView1.Items.item[c].subitems.Strings[L_hfd]) > 90 {hfd} then
            ListView1.Items.item[c].Checked := False {no quality, can't process this image}
          else
          begin {normal HFD value}



            {$ifdef darwin} {MacOS}
            quality:=strtoint(add_unicode('',stackmenu1.ListView1.Items.item[c].Subitems.strings[L_quality]));//remove all crowns
            {$else}
            quality := StrToInt(ListView1.Items.item[c].subitems.Strings[L_quality]);
            {$endif}

            quality_mean := quality_mean + quality;
            Inc(nr_good_images);

            if quality > best then
            begin
              best := quality;
              best_index := c;
            end;
          end;
        end;
        Inc(c); {go to next file}
      until c > counts;
      if nr_good_images > 0 then quality_mean := quality_mean / nr_good_images
      else
        exit; //quality_mean:=0;

      {calculate standard deviations}
      begin
        c := 0;
        quality_sd := 0;
        repeat {check all files, remove darks, bias}
          if ((ListView1.Items.item[c].Checked) and
            (key = ListView1.Items.item[c].subitems.Strings[L_result])) then
          begin {checked}
            {$ifdef darwin} {MacOS}
            quality:=strtoint(add_unicode('',ListView1.Items.item[c].Subitems.strings[L_quality]));//remove crown
            {$else}
            quality := StrToInt(ListView1.Items.item[c].subitems.Strings[L_quality]);
           {$endif}

            quality_sd := quality_sd + sqr(quality_mean - quality);
          end;
          Inc(c); {go to next file}
        until c > counts;
        quality_sd := sqrt(quality_sd / nr_good_images);
        memo2_message('Analysing group ' + key + ' for outliers.' + #9 +
          #9 + ' Average image quality (nrstars/sqr(hfd*binning))=' + floattostrF(quality_mean, ffFixed, 0, 0) +
          ', σ=' + floattostrF(quality_sd, ffFixed, 0, 1));

        {remove outliers}
        sd := stackmenu1.sd_factor_list1.Text;
        if pos('%', sd) > 0 then {specified in percentage}
        begin
          sd := StringReplace(sd, '%', '', []);
          sd_factor := inverse_erf(strtofloat2(sd) / 100);
          {convert percentage to standard deviation}
        end
        else
          sd_factor := strtofloat2(sd);
        c := 0;
        repeat
          if ((ListView1.Items.item[c].Checked) and
            (key = ListView1.Items.item[c].subitems.Strings[L_result])) then
          begin {checked}
            ListView1.Items.item[c].subitems.Strings[L_result] := '';{remove key, job done}
            {$ifdef darwin} {MacOS}
            quality:=strtoint(add_unicode('',ListView1.Items.item[c].Subitems.strings[L_quality]));//remove all crowns
            {$else}
            quality := StrToInt(ListView1.Items.item[c].subitems.Strings[L_quality]);
           {$endif}

            if (quality_mean - quality) > sd_factor * quality_sd then
            begin {remove low quality outliers}
              ListView1.Items.item[c].Checked := False;
              ListView1.Items.item[c].SubitemImages[L_quality] := icon_thumb_down;
              {mark as outlier using imageindex}
             {$ifdef darwin} {MacOS}
              ListView1.Items.item[c].Subitems.strings[L_quality]:=add_unicode('👎',ListView1.Items.item[c].Subitems.strings[L_quality]);//thumb down
             {$endif}
              memo2_message(ListView1.Items.item[c].Caption +
                ' unchecked due to low quality = nr stars detected / hfd.');
            end;
          end;
          Inc(c); {go to next file}
        until c > counts;
      end;{throw outliers out}

      if best <> 0 then
      begin
        ListView1.Items.item[best_index].SubitemImages[L_quality] := icon_king;
        {mark best index. Not nessesary but just nice}
        {$ifdef darwin} {MacOS}
        ListView1.Items.item[best_index].Subitems.strings[L_quality]:=add_unicode('♛',ListView1.Items.item[best_index].Subitems.strings[L_quality]);//add crown
        {$endif}
      end;

    finally
      ListView1.Items.EndUpdate;
    end;
  end;{with stackmenu1}
end;


procedure analyse_image(img: image_array; head: Theader; snr_min: double; report: boolean; out star_counter: integer; out bck:Tbackground; out hfd_median: double);//find background, number of stars, median HFD
var
  width5, height5, fitsX, fitsY, size, radius, i, j, retries, max_stars, n, memo2,
  xci, yci, sqr_radius: integer;
  hfd1, star_fwhm, snr, flux, xc, yc, detection_level, hfd_min, min_background: double;
  hfd_list:
  array of double;
  img_sa: image_array;
var
  f: textfile;
var   {################# initialised variables #########################}
  len: integer = 1000;
begin
  width5 := Length(img[0]);    {width}
  height5 := Length(img[0][0]); {height}

  max_stars := 500;
  SetLength(hfd_list, len);{set array length to len}

  get_background(0, img, True, True {calculate background and also star level end noise level},{out}bck);
  detection_level:=bck.star_level; {level above background. Start with a potential high value but with a minimum of 3.5 times noise as defined in procedure get_background}

  retries := 2; {try up to three times to get enough stars from the image}

  hfd_min := max(0.8 {two pixels}, strtofloat2(
  stackmenu1.min_star_size_stacking1.Caption){hfd});  {to ignore hot pixels which are too small}

  if ((nrbits = 8) or (head.datamax_org <= 255)) then min_background := 0
  else
    min_background := 8;
  if ((bck.backgr < 60000) and (bck.backgr > min_background)) then {not an abnormal file}
  begin
    repeat {try three time to find enough stars}
      star_counter := 0;

      if report then {write values to file}
      begin
        assignfile(f, ChangeFileExt(filename2, '.csv'));
        rewrite(f); //this could be done 3 times due to the repeat but it is the most simple code
        writeln(f, 'x,y,hfd,snr,flux');
      end;

      setlength(img_sa, 1, width5, height5);{set length of image array}
      for fitsY := 0 to height5 - 1 do
        for fitsX := 0 to width5 - 1 do
          img_sa[0, fitsX, fitsY] := -1;{mark as star free area}

      for fitsY := 0 to height5 - 1 do
      begin
        for fitsX := 0 to width5 - 1 do
        begin
          if ((img_sa[0, fitsX, fitsY] <= 0){area not occupied by a star} and
            (img[0, fitsX, fitsY] - bck.backgr > detection_level)) then
            {new star. For analyse used sigma is 5, so not too low.}
          begin
            HFD(img, fitsX, fitsY, 14{annulus radius}, 99 {flux aperture restriction}, 0
              {adu_e}, hfd1, star_fwhm, snr, flux, xc, yc);{star HFD and FWHM}
            if ((hfd1 <= 30) and (snr > snr_min) and
              (hfd1 > hfd_min) {two pixels minimum}) then
            begin
              hfd_list[star_counter] := hfd1;{store}
              Inc(star_counter);
              if star_counter >= len then
              begin
                len := len + 1000;
                SetLength(hfd_list, len);{increase size}
              end;

              radius := round(3.0 * hfd1); {for marking star area. A value between 2.5*hfd and 3.5*hfd gives same performance. Note in practice a star PSF has larger wings then predicted by a Gaussian function}
              sqr_radius := sqr(radius);
              xci := round(xc);{star center as integer}
              yci := round(yc);
              for n := -radius to +radius do {mark the whole circular star area as occupied to prevent double detection's}
                for memo2 := -radius to +radius do
                begin
                  j := n + yci;
                  i := memo2 + xci;
                  if ((j >= 0) and (i >= 0) and (j < height5) and (i < width5) and
                    (sqr(memo2) + sqr(n) <= sqr_radius)) then
                    img_sa[0, i, j] := 1;
                end;

              if report then
                writeln(f, floattostr4(xc + 1) + ',' + floattostr4(yc + 1) +  ',' + floattostr4(hfd1) + ',' + IntToStr(round(snr)) + ',' + IntToStr(round(flux))); {+1 to convert 0... to FITS 1... coordinates}
            end;
          end;
        end;
      end;

      Dec(retries);{In principle not required. Try again with lower detection level}
      if detection_level <= 7 * bck.noise_level then
        retries := -1 {stop}
      else
        detection_level := max(6.999 * bck.noise_level, min(30 * bck.noise_level, detection_level * 6.999 / 30)); {very high -> 30 -> 7 -> stop.  Or  60 -> 14 -> 7.0. Or for very short exposures 3.5 -> stop}

      if report then closefile(f);

    until ((star_counter >= max_stars) or (retries < 0)); {reduce detection level till enough stars are found. Note that faint stars have less positional accuracy}

    if star_counter > 0 then hfd_median := SMedian(hfd_List, star_counter) else  hfd_median := 99;
  end {backgr is normal}
  else
    hfd_median := 99; {Most common value image is too low. Ca'+#39+'t process this image. Check camera offset setting.}

  img_sa := nil;{free memo2}
end;


procedure analyse_image_extended(img: image_array; head: Theader; out nr_stars, hfd_median, median_outer_ring, median_11, median_21, median_31,  median_12, median_22, median_32, median_13, median_23, median_33: double);{analyse several areas}
var
  fitsX, fitsY, radius, i, j,
  retries, max_stars, n, memo2, xci, yci, sqr_radius, nhfd, nhfd_outer_ring,
  nhfd_11, nhfd_21, nhfd_31, nhfd_12, nhfd_22, nhfd_32,
  nhfd_13, nhfd_23, nhfd_33: integer;
  hfd1, star_fwhm, snr, flux, xc, yc, detection_level: double;
  img_sa: image_array;
  hfdlist, hfdlist_11, hfdlist_21, hfdlist_31, hfdlist_12, hfdlist_22, hfdlist_32,
  hfdlist_13, hfdlist_23, hfdlist_33, hfdlist_outer_ring: array of double;
  starlistXY: array of array of integer;
  len, starX, starY: integer;
  bck : tbackground;

begin
  if head.naxis3 > 1 then {colour image}
  begin
    convert_mono(img, head);
    get_hist(0, img);    {get histogram of img_loaded and his_total. Required to get correct background value}
  end
  else
  if (bayerpat <> '') then {raw Bayer image}
  begin
    check_pattern_filter(img);
    get_hist(0, img);    {get histogram of img_loaded and his_total. Required to get correct background value}
  end;

  max_stars := 500; //fixed value
  len := max_stars * 4; {should be enough. If not increase size arrays}

  SetLength(hfdlist, len * 4);{set array length on a starting value}
  SetLength(starlistXY, 2, len * 4);{x,y positions}

  setlength(img_sa, 1, head.Width, head.Height);{set length of image array}

  get_background(0, img, True, True {calculate background and also star level end noise level},{out}bck);

  detection_level:=bck.star_level; {level above background. Start with a potential high value but with a minimum of 3.5 times noise as defined in procedure get_background}

  retries := 2; {try three times to get enough stars from the image}
  repeat
    nhfd := 0;{set counter at zero}

    if bck.backgr > 8 then
    begin
      for fitsY := 0 to head.Height - 1 do
        for fitsX := 0 to head.Width - 1 do
          img_sa[0, fitsX, fitsY] := -1;{mark as star free area}

      //the nine areas:
      //13     23   33
      //12     22   32
      //11     21   31

      for fitsY := 0 to head.Height - 1 do
      begin
        for fitsX := 0 to head.Width - 1 do
        begin
          if ((img_sa[0, fitsX, fitsY] <= 0){area not occupied by a star} and
            (img[0, fitsX, fitsY] - bck.backgr > detection_level){star}) then   {new star. For analyse used sigma is 5, so not too low.}
          begin
            HFD(img, fitsX, fitsY, 25 {LARGE annulus radius}, 99  {flux aperture restriction}, 0 {adu_e}, hfd1, star_fwhm, snr, flux, xc, yc);
            {star HFD and FWHM}
            if ((hfd1 <= 35) and (snr > 30) and (hfd1 > 0.8) {two pixels minimum}) then
            begin    {store values}
              radius := round(3.0 * hfd1);  {for marking star area. A value between 2.5*hfd and 3.5*hfd gives same performance. Note in practice a star PSF has larger wings then predicted by a Gaussian function}
              sqr_radius := sqr(radius);
              xci := round(xc);{star center as integer}
              yci := round(yc);
              for n := -radius to +radius do  {mark the whole circular star area as occupied to prevent double detection's}
                for memo2 := -radius to +radius do
                begin
                  j := n + yci;
                  i := memo2 + xci;
                  if ((j >= 0) and (i >= 0) and (j < head.Height) and
                    (i < head.Width) and (sqr(memo2) + sqr(n) <= sqr_radius)) then
                    img_sa[0, i, j] := 1;
                end;

              if ((img[0, xci, yci] < head.datamax_org - 1) and
                (img[0, xci - 1, yci] < head.datamax_org - 1) and
                (img[0, xci + 1, yci] < head.datamax_org - 1) and
                (img[0, xci, yci - 1] < head.datamax_org - 1) and
                (img[0, xci, yci + 1] < head.datamax_org - 1) and
                (img[0, xci - 1, yci - 1] < head.datamax_org - 1) and
                (img[0, xci - 1, yci + 1] < head.datamax_org - 1) and
                (img[0, xci + 1, yci - 1] < head.datamax_org - 1) and
                (img[0, xci + 1, yci + 1] < head.datamax_org - 1)) then {not saturated}
              begin  {store values}
                hfdlist[nhfd] := hfd1;

                starlistXY[0, nhfd] := xci;  {store star position in image coordinates, not FITS coordinates}
                starlistXY[1, nhfd] := yci;
                Inc(nhfd);
                if nhfd >= length(hfdlist) then
                begin
                  SetLength(hfdlist, nhfd + max_stars); {adapt length if required and store hfd value}
                  SetLength(starlistXY, 2, nhfd + max_stars);{adapt array size if required}
                end;

              end;
            end;
          end;
        end;
      end;

    end;

    Dec(retries);{In principle not required. Try again with lower detection level}
    if detection_level <= 7 * bck.noise_level then retries := -1 {stop}
    else
      detection_level := max(6.999 * bck.noise_level, min(30 * bck.noise_level, detection_level * 6.999 / 30)); {very high -> 30 -> 7 -> stop.  Or  60 -> 14 -> 7.0. Or for very short exposures 3.5 -> stop}

  until ((nhfd >= max_stars) or (retries < 0)); {reduce dection level till enough stars are found. Note that faint stars have less positional accuracy}

  nhfd_11 := 0;
  nhfd_21 := 0;
  nhfd_31 := 0;
  nhfd_12 := 0;
  nhfd_22 := 0;
  nhfd_32 := 0;
  nhfd_13 := 0;
  nhfd_23 := 0;
  nhfd_33 := 0;
  nhfd_outer_ring := 0;

  if nhfd > 0 then {count the stars for each area}
  begin
    SetLength(hfdlist_outer_ring, nhfd);{space for all stars}
    SetLength(hfdlist_11, nhfd);{space for all stars}
    SetLength(hfdlist_21, nhfd);{space for all stars}
    SetLength(hfdlist_31, nhfd);

    SetLength(hfdlist_12, nhfd);
    SetLength(hfdlist_22, nhfd);
    SetLength(hfdlist_32, nhfd);

    SetLength(hfdlist_13, nhfd);
    SetLength(hfdlist_23, nhfd);
    SetLength(hfdlist_33, nhfd);

    {sort the stars}
    for i := 0 to nhfd - 1 do
    begin
      hfd1 := hfdlist[i];
      starX := starlistXY[0, i];
      starY := starlistXY[1, i];

      //the nine areas. FITS 1,1 is left bottom:
      //13   23   33
      //12   22   32
      //11   21   31

      if sqr(starX - (head.width div 2)) + sqr(starY - (head.height div 2)) > sqr(0.75) *  (sqr(head.width div 2) + sqr(head.height div 2)) then
      begin
        hfdlist_outer_ring[nhfd_outer_ring] := hfd1;
        Inc(nhfd_outer_ring);
      end;{store out ring (>75% diameter) HFD values}

      if ((starX < (head.Width * 1 / 3)) and (starY < (head.Height * 1 / 3))) then
      begin
        hfdlist_11[nhfd_11] := hfd1;
        Inc(nhfd_11);
      end;{store corner HFD values}
      if ((starX > (head.Width * 2 / 3)) and (starY < (head.Height * 1 / 3))) then
      begin
        hfdlist_31[nhfd_31] := hfd1;
        Inc(nhfd_31);
        if nhfd_31 >= length(hfdlist_31) then SetLength(hfdlist_31, nhfd_31 + 500);
      end;
      if ((starX > (head.Width * 2 / 3)) and (starY > (head.Height * 2 / 3))) then
      begin
        hfdlist_33[nhfd_33] := hfd1;
        Inc(nhfd_33);
        if nhfd_33 >= length(hfdlist_33) then SetLength(hfdlist_33, nhfd_33 + 500);
      end;
      if ((starX < (head.Width * 1 / 3)) and (starY > (head.Height * 2 / 3))) then
      begin
        hfdlist_13[nhfd_13] := hfd1;
        Inc(nhfd_13);
        if nhfd_13 >= length(hfdlist_13) then SetLength(hfdlist_13, nhfd_13 + 500);
      end;

      if ((starX > (head.Width * 1 / 3)) and (starX < (head.Width * 2 / 3)) and (starY > (head.Height * 2 / 3))) then
      begin
        hfdlist_23[nhfd_23] := hfd1;
        Inc(nhfd_23);
      end;{store corner HFD values}
      if ((starX < (head.Width * 1 / 3)) and (starY > (head.Height * 1 / 3)) and (starY < (head.Height * 2 / 3))) then
      begin
        hfdlist_12[nhfd_12] := hfd1;
        Inc(nhfd_12);
      end;{store corner HFD values}
      if ((starX > (head.Width * 1 / 3)) and (starX < (head.Width * 2 / 3)) and (starY > (head.Height * 1 / 3)) and (starY < (head.Height * 2 / 3))) then
      begin
        hfdlist_22[nhfd_22] := hfd1;
        Inc(nhfd_22);
      end;{square center}
      if ((starX > (head.Width * 2 / 3)) and (starY > (head.Height * 1 / 3)) and (starY < (head.Height * 2 / 3))) then
      begin
        hfdlist_32[nhfd_32] := hfd1;
        Inc(nhfd_32);
      end;{store corner HFD values}
      if ((starX > (head.Width * 1 / 3)) and (starX < (head.Width * 2 / 3)) and (starY < (head.Height * 1 / 3))) then
      begin
        hfdlist_21[nhfd_21] := hfd1;
        Inc(nhfd_21);
      end;{store corner HFD values}

    end;
  end;

  nr_stars := nhfd;
  if nhfd > 0 then  hfd_median := SMedian(hfdList, nhfd) else  hfd_median := 99;
  if nhfd_outer_ring > 0 then  median_outer_ring := SMedian(hfdlist_outer_ring, nhfd_outer_ring) else median_outer_ring := 99;
  if nhfd_11 > 0 then median_11 := SMedian(hfdlist_11, nhfd_11) else median_11 := 99;
  if nhfd_21 > 0 then median_21 := SMedian(hfdlist_21, nhfd_21) else median_21 := 99;
  if nhfd_31 > 0 then median_31 := SMedian(hfdlist_31, nhfd_31) else median_31 := 99;

  if nhfd_12 > 0 then median_12 := SMedian(hfdlist_12, nhfd_12) else median_12 := 99;
  if nhfd_22 > 0 then median_22 := SMedian(hfdlist_22, nhfd_22) else median_22 := 99;
  if nhfd_32 > 0 then median_32 := SMedian(hfdlist_32, nhfd_32) else median_32 := 99;

  if nhfd_13 > 0 then median_13 := SMedian(hfdlist_13, nhfd_13) else median_13 := 99;
  if nhfd_23 > 0 then median_23 := SMedian(hfdlist_23, nhfd_23) else median_23 := 99;
  if nhfd_33 > 0 then median_33 := SMedian(hfdlist_33, nhfd_33) else median_33 := 99;

  hfdlist := nil;{release memory}
  hfdlist_outer_ring := nil;
  hfdlist_11 := nil;
  hfdlist_21 := nil;
  hfdlist_31 := nil;
  hfdlist_12 := nil;
  hfdlist_22 := nil;
  hfdlist_32 := nil;
  hfdlist_13 := nil;
  hfdlist_23 := nil;
  hfdlist_33 := nil;

  img_sa := nil;{free memo2}
end;



procedure get_annotation_position;
{find the position of the specified asteroid annotation}
var
  count1: integer;
  x1, y1, x2, y2: double;
  Name: string;
  List: TStrings;
begin
  List := TStringList.Create;
  list.StrictDelimiter := True;
  Name := stackmenu1.ephemeris_centering1.Text;{asteroid to center on}
  count1 := mainwindow.Memo1.Lines.Count - 1;
  try
    while count1 >= 0 do {plot annotations}
    begin
      if copy(mainwindow.Memo1.Lines[count1], 1, 8) = 'ANNOTATE' then {found}
      begin
        List.Clear;
        ExtractStrings([';'], [],
          PChar(copy(mainwindow.Memo1.Lines[count1], 12, 80 - 12)), List);

        if list.Count >= 6 then {correct annotation}
        begin
          if list[5] = Name then {correct name}
          begin
            x1 := strtofloat2(list[0]);{fits coordinates}
            y1 := strtofloat2(list[1]);
            x2 := strtofloat2(list[2]);
            y2 := strtofloat2(list[3]);
            listview_add_xy((x1 + x2) / 2, (y1 + y2) / 2); {add center annotation to x,y for stacking}
          end;
        end;
      end;
      count1 := count1 - 1;
    end;
  finally
    List.Free;
  end;
end;


procedure analyse_tab_lights(full: boolean);
var
  c, star_counter, i, counts: integer;
  hfd_median, alt, az, sharpness: double;
  red, green, blue, planetary: boolean;
  key, filename1, rawstr: string;
  img: image_array;
  bck :Tbackground;
begin
  with stackmenu1 do
  begin
    counts := ListView1.items.Count - 1;
    if counts < 0 then {zero files}
    begin
      memo2_message('Abort, no images to analyse! Browse for images, darks and flats. They will be sorted automatically.');
      exit;
    end;

    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    esc_pressed := False;

    if ((process_as_osc=2) and (make_osc_color1.Checked=false)) then process_as_osc:=0
    else
    if ((process_as_osc=0) and (make_osc_color1.Checked)) then process_as_osc:=2;
    //else it is set automatically below during analysing.

    jd_sum := 0;{for sigma clip advanced average}
    planetary := planetary_image1.Checked;
    red := False;
    green := False;
    blue := False;
    c := 0;
    {convert any non FITS file}
    while c <= counts {check all} do
    begin
      if ListView1.Items.item[c].Checked then
      begin
        filename1 := ListView1.items[c].Caption;

        if fits_tiff_file_name(filename1) = False  {fits or tiff file name?} then
        begin
          memo2_message('Converting ' + filename1 + ' to FITS file format');
          Application.ProcessMessages;
          if esc_pressed then
          begin
            Screen.Cursor := crDefault;
            { back to normal }  exit;
          end;
          if convert_to_fits(filename1) {convert to fits} then
            ListView1.items[c].Caption := filename1 {change listview name to FITS.}
          else
          begin {failure}
            ListView1.Items.item[c].Checked := False;
            ListView1.Items.item[c].subitems.Strings[L_result] := 'Conv failure!';
          end;
        end;
      end;{checked}
      Inc(c);
    end;
    c := 0;
    repeat {check for double entries}
      i := c + 1;
      while i <= counts do
      begin
        if ListView1.items[i].Caption = ListView1.items[c].Caption then {double file name}
        begin
          memo2_message('Removed second entry of same file ' +
          ListView1.items[i].Caption);
          listview1.Items.Delete(i);
          Dec(counts); {compensate for delete}
        end
        else
          Inc(i);
      end;
      Inc(c);
    until c > counts;

    counts := ListView1.items.Count - 1;
    c := 0;
    repeat {check all files, remove darks, bias}
      if ((ListView1.Items.item[c].Checked) and
        ((length(ListView1.Items.item[c].subitems.Strings[L_hfd]) <= 1){hfd} or
        (new_analyse_required))) then {hfd unknown, only update blank rows}
      begin {checked}

        if counts <> 0 then progress_indicator(100 * c / counts, ' Analysing');
        Listview1.Selected := nil; {remove any selection}
        ListView1.ItemIndex := c;
        {mark where we are, set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        Listview1.Items[c].MakeVisible(False);{scroll to selected item}

        filename2 := ListView1.items[c].Caption;
        Application.ProcessMessages;
        if esc_pressed then
        begin
          Screen.Cursor := crDefault;
          { back to normal }  exit;
        end;


        if load_fits(filename2, True { update head_2.ra0..}, True, False  {update memo}, 0, head_2, img) = False then {oad in memory. Use head_2 to protect head against overwriting head}
        begin {failed to load}
          ListView1.Items.item[c].Checked := False;
          ListView1.Items.item[c].subitems.Strings[L_result] := 'No FITS!';
        end
        else
        begin
          if pos('DARK', uppercase(imagetype)) > 0 then
          begin
            memo2_message('Move file ' + filename2 + ' to tab DARKS');
            listview2.Items.beginupdate;
            listview_add(listview2, filename2, True, D_nr);{move to darks}
            listview2.Items.endupdate;
            listview1.Items.Delete(c);
            Dec(c);{compensate for delete}
            Dec(counts); {compensate for delete}
          end
          else
          if pos('FLAT', uppercase(imagetype)) > 0 then
          begin
            memo2_message('Move file ' + filename2 + ' to tab FLATS');
            listview3.Items.beginupdate;
            listview_add(listview3, filename2, True, F_nr);
            listview3.Items.endupdate;
            listview1.Items.Delete(c);
            Dec(c);{compensate for delete}
            Dec(counts); {compensate for delete}
          end
          else
          if pos('BIAS', uppercase(imagetype)) > 0 then
          begin
            memo2_message('Move file ' + filename2 + ' to tab FLAT-DARKS / BIAS');
            listview4.Items.beginupdate;
            listview_add(listview4, filename2, True, FD_nr);
            listview4.Items.endupdate;
            listview1.Items.Delete(c);
            Dec(c);{compensate for delete}
            Dec(counts); {compensate for delete}
          end
          else
          begin {light frame}

            if ((planetary = False) and (full = True)) then
              analyse_image(img, head_2, 10 {snr_min}, False, star_counter, bck, hfd_median) {find background, number of stars, median HFD}
            else
            begin
              star_counter := 0;
              bck.backgr := 0;
              bck.star_level:= 0;
              hfd_median := -1;
            end;

            ListView1.Items.BeginUpdate;
            try
              begin
                ListView1.Items.item[c].subitems.Strings[L_object] := object_name;
                {object name, without spaces}

                ListView1.Items.item[c].subitems.Strings[L_filter] := head_2.filter_name;
                {filter name, without spaces}
                if head_2.naxis3 = 3 then
                  ListView1.Items.item[c].subitems.Strings[L_filter] := 'colour';
                {give RGB lights filter name colour}

                if AnsiCompareText(red_filter1.Text, head_2.filter_name) = 0 then
                begin
                  ListView1.Items.item[c].SubitemImages[L_filter] := 0;
                  red := True;
                end
                else
                if AnsiCompareText(red_filter2.Text, head_2.filter_name) = 0 then
                begin
                  ListView1.Items.item[c].SubitemImages[L_filter] := 0;
                  red := True;
                end
                else
                if AnsiCompareText(green_filter1.Text, head_2.filter_name) = 0 then
                begin
                  ListView1.Items.item[c].SubitemImages[L_filter] := 1;
                  green := True;
                end
                else
                if AnsiCompareText(green_filter2.Text, head_2.filter_name) = 0 then
                begin
                  ListView1.Items.item[c].SubitemImages[L_filter] := 1;
                  green := True;
                end
                else
                if AnsiCompareText(blue_filter1.Text, head_2.filter_name) = 0 then
                begin
                  ListView1.Items.item[c].SubitemImages[L_filter] := 2;
                  blue := True;
                end
                else
                if AnsiCompareText(blue_filter2.Text, head_2.filter_name) = 0 then
                begin
                  ListView1.Items.item[c].SubitemImages[L_filter] := 2;
                  blue := True;
                end
                else
                if AnsiCompareText(luminance_filter1.Text, head_2.filter_name) = 0 then
                  ListView1.Items.item[c].SubitemImages[L_filter] := 4
                else
                if AnsiCompareText(luminance_filter2.Text, head_2.filter_name) = 0 then
                  ListView1.Items.item[c].SubitemImages[L_filter] := 4
                else
                if head_2.naxis3 = 3 then
                  ListView1.Items.item[c].SubitemImages[L_filter] := 3
                else {RGB color}
                if head_2.filter_name <> '' then
                  ListView1.Items.item[c].SubitemImages[L_filter] := 7 {question mark}
                else
                  ListView1.Items.item[c].SubitemImages[L_filter] := -1;{blank}

                ListView1.Items.item[c].subitems.Strings[L_bin] :=
                  floattostrf(head_2.Xbinning, ffgeneral, 0, 0) + ' x ' + floattostrf(
                  head_2.Ybinning, ffgeneral, 0, 0);
                {Binning CCD}

                ListView1.Items.item[c].subitems.Strings[L_hfd] :=
                  floattostrF(hfd_median, ffFixed, 0, 1);
                ListView1.Items.item[c].subitems.Strings[L_quality] :=
                  inttostr5(round(star_counter / sqr(hfd_median*head_2.Xbinning))); {quality number of stars divided by hfd, binning neutral}

                if hfd_median >= 99 then
                  ListView1.Items.item[c].Checked := False {no stars, can't process this image}
                else
                begin {image can be futher analysed}
                  ListView1.Items.item[c].subitems.Strings[L_nrstars] :=
                    inttostr5(round(star_counter {star_level}));//nr of stars
                  ListView1.Items.item[c].subitems.Strings[L_background] :=
                    inttostr5(round(bck.backgr));
                  if full then sharpness := image_sharpness(img)
                  else
                    sharpness := 0;
                  ListView1.Items.item[c].subitems.Strings[L_sharpness] :=
                    floattostrF(sharpness, ffFixed, 0, 3); {sharpness test}
                end;

                if head_2.exposure >= 10 then
                  ListView1.Items.item[c].subitems.Strings[L_exposure] := IntToStr(round(head_2.exposure))
                {round values above 10 seconds}
                else
                  ListView1.Items.item[c].subitems.Strings[L_exposure] :=
                    floattostrf(head_2.exposure, ffgeneral, 6, 6);

                if head_2.set_temperature <> 999 then
                  ListView1.Items.item[c].subitems.Strings[L_temperature] :=
                    IntToStr(head_2.set_temperature);
                ListView1.Items.item[c].subitems.Strings[L_width] :=
                  IntToStr(head_2.Width); {width}
                ListView1.Items.item[c].subitems.Strings[L_height] :=
                  IntToStr(head_2.Height);{height}

                if stackmenu1.make_osc_color1.Checked then
                  process_as_osc := 2//forced process as OSC images
                else
                if ((head_2.naxis3 = 1) and (head_2.Xbinning = 1) and (bayerpat <> '')) then
                  //auto process as OSC images
                  process_as_osc := 1
                else
                  process_as_osc := 0;//disable demosaicing

                if ((head_2.naxis3 = 1) and (head_2.Xbinning = 1) and (bayerpat <> '')) then
                  rawstr := ' raw'
                else
                  rawstr := '';

                ListView1.Items.item[c].subitems.Strings[L_type] :=
                  copy(imagetype, 1, 5) + IntToStr(nrbits) + rawstr;{type}

                {$ifdef darwin} {MacOS, fix missing icons by coloured unicode. Place in column "type" to avoid problems with textual filter selection}
                 if red then ListView1.Items.item[c].subitems.Strings[L_type]:='🔴' +ListView1.Items.item[c].subitems.Strings[L_type]
                 else
                 if green then ListView1.Items.item[c].subitems.Strings[L_type]:='🟢' +ListView1.Items.item[c].subitems.Strings[L_type]
                 else
                 if blue then ListView1.Items.item[c].subitems.Strings[L_type]:='🔵' +ListView1.Items.item[c].subitems.Strings[L_type];
                {$endif}


                ListView1.Items.item[c].subitems.Strings[L_datetime] := copy(StringReplace(head_2.date_obs, 'T', ' ', []), 1, 23);{date/time up to ms}
                ListView1.Items.item[c].subitems.Strings[L_position] := prepare_ra5(head_2.ra0, ': ') + ', ' + prepare_dec4(head_2.dec0, '° ');
                {give internal position}

                {is internal solution available?}
                if head_2.cd1_1 <> 0 then
                  ListView1.Items.item[c].subitems.Strings[L_solution] := '✓'
                else
                  ListView1.Items.item[c].subitems.Strings[L_solution] := '-';

                ListView1.Items.item[c].subitems.Strings[L_calibration] := head_2.calstat;
                {status calibration}
                if focus_pos <> 0 then
                  ListView1.Items.item[c].subitems.Strings[L_focpos] := IntToStr(focus_pos);
                if focus_temp <> 999 then
                  ListView1.Items.item[c].subitems.Strings[L_foctemp] :=
                    floattostrF(focus_temp, ffFixed, 0, 1);

                if head_2.egain <> '' then
                  ListView1.Items.item[c].subitems.Strings[L_gain] := head_2.egain {e-/adu}
                else
                if head_2.gain <> '' then
                  ListView1.Items.item[c].subitems.Strings[L_gain] := head_2.gain;

                if centalt = '' then
                begin
                  calculate_az_alt(0 {try to use header values}, head_2,{out}az, alt);
                  if alt <> 0 then
                  begin
                    centalt := floattostrf(alt, ffgeneral, 3, 1); {altitude}
                    centaz := floattostrf(az, ffgeneral, 3, 1); {azimuth}
                  end;
                end;

                ListView1.Items.item[c].subitems.Strings[L_centalt] := centalt;
                ListView1.Items.item[c].subitems.Strings[L_centaz] := centaz;


                if SQM_key='FOV     ' then
                begin
                  if head_2.cdelt2<>0 then
                  begin
                    ListView1.Items.item[c].subitems.Strings[L_sqm]:=floattostrF(head_2.height*abs(head_2.cdelt2),ffFixed,0,2);
                  end
                  else ListView1.Items.item[c].subitems.Strings[L_sqm]:='';
                end
                else
                ListView1.Items.item[c].subitems.Strings[L_sqm] := sqm_value;

                if use_ephemeris_alignment1.Checked then {ephemeride based stacking}
                  get_annotation_position;{fill the x,y with annotation position}
              end;
            finally
              ListView1.Items.EndUpdate;
            end;
          end;{end light frame}
        end;{this is a fits file}
      end;{checked and hfd unknown}
      Inc(c); {go to next file}
    until c > counts;

    if ((green) and (blue) and (classify_filter1.Checked = False)) then
      memo2_message( '■■■■■■■■■■■■■ Hint, colour filters detected in light. For colour stack set the check-mark classify by Image filter! ■■■■■■■■■■■■■');

    if (stackmenu1.uncheck_outliers1.Checked) then
    begin
      {give list an indentification key label based on object, filter and head_2.exposure time}
      for c := 0 to ListView1.items.Count - 1 do
      begin
        if ListView1.Items.item[c].SubitemImages[L_quality] = icon_thumb_down then  {marked at outlier}
        begin
          ListView1.Items.item[c].Checked := True;{recheck outliers from previous session}
        end;
        ListView1.Items.item[c].SubitemImages[L_quality] := -1;{remove any icon mark}
        {$ifdef darwin} {MacOS}
        ListView1.Items.item[c].subitems.Strings[L_quality]:=add_unicode('', ListView1.Items.item[c].subitems.Strings[L_quality]);//remove all crowns and thumbs
        {$endif}

        if ListView1.items[c].Checked = True then
          ListView1.Items.item[c].subitems.Strings[L_result] :=
            ListView1.Items.item[c].subitems.Strings[L_object] + '_' +{object name}
            ListView1.Items.item[c].subitems.Strings[L_filter] + '_' +{filter}
            ListView1.Items.item[c].subitems.Strings[L_exposure];
        {head_2.exposure}
      end;
      {do statistics on each constructed key}
      repeat
        c := 0;
        key := '';
        repeat {check all files, uncheck outliers}
          if ListView1.Items.item[c].Checked then
          begin
            key := ListView1.Items.item[c].subitems.Strings[L_result];
            if key <> '' then
              list_remove_outliers(key);
          end;
          if esc_pressed then
          begin
            Screen.Cursor := crDefault;
            { back to normal }  exit;
          end;
          Inc(c)
        until c > counts;
      until key = '';{until all keys are used}
    end;

    count_selected;
    {report the number of lights selected in images_selected and update menu indication}
    new_analyse_required := False;
    {back to normal, head_2.filter_name is not changed, so no re-analyse required}
    img := nil; {free memo2}

    //    if ((minbackgr<>0) and (pos('Sigma',stackmenu1.stack_method1.text)>0)) then
    //     if maxbackgr/(minbackgr)>1.3 then memo2_message('█ █ █ █ █ █ Warning, some images have a significant higher background value. Method sigma clip average will not be effective in removing satellite tracks. Suggest to unselect/remove images with a high background value!! █ █ █ █ █ █ ');


//    stackmenu1.cursor:=crDefault;//required for some MacOS versions?
    Screen.Cursor := crDefault;    { back to normal }
    progress_indicator(-100, '');{progresss done}
  end;
end;


procedure Tstackmenu1.Analyse1Click(Sender: TObject);
begin
  analyse_tab_lights(True {full});
  {temporary fix for CustomDraw not called}
  {$ifdef darwin} {MacOS}
  stackmenu1.nr_total1.caption:=inttostr(listview1.items.count);{update counting info}
  {$endif}

end;


procedure Tstackmenu1.browse1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select lights to stack';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist, ofHideReadOnly];
  opendialog1.filename := '';
  opendialog1.Filter := dialog_filter;
  if opendialog1.Execute then
  begin
    listview1.Items.beginUpdate;
    for i := 0 to OpenDialog1.Files.Count - 1 do
    begin
      listview_add(listview1, OpenDialog1.Files[i],
        pos('_stacked', OpenDialog1.Files[i]) = 0 {do not check mark lights already stacked}
        , L_nr);
    end;
    listview1.Items.EndUpdate;
  end;
  count_selected;
  {report the number of lights selected in images_selected and update menu indication}
end;


procedure report_results(object_to_process, stack_info: string;
  object_counter, colorinfo: integer);{report on tab results}
begin
  {report result in results}
  with stackmenu1 do
  begin
    listview5_add(listview5, filename2, object_to_process,
      IntToStr(object_counter) + '  ' {object counter}
      , stack_info
      , IntToStr(head.Width)
      , IntToStr(head.Height)
      , head.calstat);
    ListView5.Items.item[ListView5.Items.Count - 1].SubitemImages[1] := 5;
    {mark 2th columns as done using a stacked icon}
    ListView5.Items.item[ListView5.Items.Count - 1].SubitemImages[0] := colorinfo;
    {color, gray icon}
  end;
  application.ProcessMessages;
  {end report result in results}
end;


procedure update_equalise_background_step(pos1: integer);
{update equalise background menu}
begin
  with stackmenu1 do
  begin
    if ((pos1 < 1) or (pos1 > 5)) then
    begin
      pos1 := 1;
      saved1.Caption := '';
    end;

    if pos1 > 1 then go_step_two1.Enabled := True;
    equalise_background_step := pos1;
    undo_button_equalise_background1.Enabled := True;



    save_result1.Enabled := False;
    remove_deepsky_label1.Enabled := False;
    most_common_filter_tool1.Enabled := False;
    most_common_mono1.Enabled := False;
    correct_gradient_label1.Enabled := False;
    apply_gaussian_filter1.Enabled := False;
    subtract_background1.Enabled := False;
    save_result1.Enabled := False;
    save_as_new_file1.Enabled := False;

    case pos1 of
       1: begin
            save_as_new_file1.Enabled := True;
            save_result1.Enabled := True;
            remove_deepsky_label1.Enabled := True;
            undo_button_equalise_background1.Caption := '';
          end;{step 1,6}
       2: begin
            most_common_filter_tool1.Enabled := True; {step 3}
            most_common_mono1.Enabled := head.naxis3 > 1;{colour}
            remove_deepsky_label1.Enabled := True;
            undo_button_equalise_background1.Caption := '1';
         end;
       3: begin
            apply_gaussian_filter1.Enabled := True; {step 4}
            correct_gradient_label1.Enabled := True;
            undo_button_equalise_background1.Caption := '3';
          end;
       4: begin
            subtract_background1.Enabled := True; {step 5}
            undo_button_equalise_background1.Caption := '4';
          end;
       5: begin
            save_result1.Enabled := True; {step 5}
            undo_button_equalise_background1.Caption := '1';
          end;
     end;{case}
  end;
end;


procedure Tstackmenu1.save_as_new_file1Click(Sender: TObject);
{add equalised to filename}
var
  dot_pos: integer;
begin
  if Length(img_loaded) = 0 then
  begin
    memo2_message('Error, no image in viewer loaded!');
    exit;
  end;
  if pos('.fit', filename2) = 0 then filename2 := changeFileExt(filename2, '.fits');
  {rename png, XISF file to fits}

  dot_pos := length(filename2);
  repeat
    Dec(dot_pos);
  until ((filename2[dot_pos] = '.') or (dot_pos <= 1));
  insert(' original', filename2, dot_pos);

  save_fits(img_loaded, filename2, -32, True);
  if fileexists(filename2) then
  begin
    saved1.Caption := 'Saved';
    report_results(object_name, '', 0, -1{no icon});{report result in tab results}
  end
  else
    saved1.Caption := '';

  update_equalise_background_step(equalise_background_step + 1); {update menu}
end;


procedure Tstackmenu1.subtract_background1Click(Sender: TObject);
var
  fitsX, fitsY, col, col2, nrcolours: integer;
begin
  if head.naxis = 0 then exit;
  Screen.Cursor := crHourglass;
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  backup_img;


  if load_fits(filename2, True {light}, True, True {update memo}, 0, head, img_temp) then
    {success load}
  begin
    nrcolours := length(img_loaded) - 1;{nr colours - 1}
    for col := 0 to head.naxis3 - 1 do {all colors}
    begin {subtract view from file}
      col2 := min(nrcolours, col); {allow subtracting mono lights from colour}
      for fitsY := 0 to head.Height - 1 do
        for fitsX := 0 to head.Width - 1 do
          img_temp[col, fitsX, fitsY] := img_temp[col, fitsX, fitsY] -
            img_loaded[col2, fitsX, fitsY] + 1000;
      {use temp as temporary rather then img_loaded since img_loaded could be mono}
    end;

    img_loaded := img_temp; {use result}

    use_histogram(img_loaded, True);
    plot_fits(mainwindow.image1, False, True);{plot real}
  end;
  update_equalise_background_step(
    5 {force 5 since equalise background is set to 1 by loading fits file});{update menu}
  Screen.Cursor := crDefault;
end;


procedure Tstackmenu1.show_quads1Click(Sender: TObject);
var
  hfd_min: double;
  max_stars, binning,x: integer;
  starlistquads: star_list;
  warning_downsample: string;
begin
  if head.naxis = 0 then application.messagebox(
      PChar('First load an image in the viewer!'), PChar('No action'), MB_OK)
  else
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    max_stars := strtoint2(stackmenu1.max_stars1.Text);
    {maximum star to process, if so filter out brightest stars later}
    if max_stars = 0 then max_stars := 500;{0 is auto for solving. No auto for stacking}

    if quads_displayed then
      plot_fits(mainwindow.image1, False, True); {remove quads}

    binning := report_binning(head.Height{*cropping});
    {select binning on dimensions of cropped image}
    if use_astrometry_internal1.Checked then
    begin
      if head.cdelt2 = 0 {jpeg} then
        head.cdelt2 := binning * strtofloat2(search_fov1.Text) / head.Height;
      hfd_min := max(0.8 {two pixels}, strtofloat2(stackmenu1.min_star_size1.Text){arc sec} /
        (head.cdelt2 * 3600));{to ignore hot pixels which are too small}
    end
    else
      hfd_min := max(0.8 {two pixels}, strtofloat2(
        stackmenu1.min_star_size_stacking1.Caption){hfd});
    {to ignore hot pixels which are too small}

    bin_and_find_stars(img_loaded, binning, 1 {cropping}, hfd_min, max_stars, False{update hist}, starlist1, warning_downsample);{bin, measure background}
    find_quads_xy(starlist1, starlistquads);{find quads}

    display_quads(starlistquads);
    quads_displayed := True;
    starlistquads := nil;{release memory}

    Screen.Cursor := crDefault;
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


procedure listview_removeselect(tl: tlistview);
var
  index: integer;
begin
  index := tl.Items.Count - 1;
  while index >= 0 do
  begin
    if tl.Items[index].Selected then
      tl.Items.Delete(Index);
    Dec(index); {go to next file}
  end;
end;


procedure Tstackmenu1.removeselected1Click(Sender: TObject);
begin
  if Sender = removeselected1 then
  begin
     listview_removeselect(listview1);{from popup menu}
         //temporary till MACOS customdraw is fixed
       {$ifdef darwin} {MacOS}
        count_selected;
       {$endif}
  end;
  if Sender = removeselected2 then listview_removeselect(listview2);{from popup menu}
  if Sender = removeselected3 then listview_removeselect(listview3);{from popup menu}
  if Sender = removeselected4 then listview_removeselect(listview4);{from popup menu}
  if Sender = removeselected5 then listview_removeselect(listview5);{from popup menu}
  if Sender = removeselected6 then listview_removeselect(listview6);{from popup menu blink}
  if Sender = removeselected7 then listview_removeselect(listview7);{from popup menu photometry}
  if Sender = removeselected8 then listview_removeselect(listview8);{inspector}
  if Sender = removeselected9 then listview_removeselect(listview9);{mount analyse}
end;


procedure Tstackmenu1.help_astrometric_alignment1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#astrometric_alignment');
end;


procedure Tstackmenu1.clear_image_list1Click(Sender: TObject);
begin
  esc_pressed:=true; //stop any scrolling and prevent run time errors
  ListView1.Clear;
  stackmenu1.ephemeris_centering1.Clear;

  //temporary till MACOS customdraw is fixed
  {$ifdef darwin} {MacOS}
  count_selected;
  {$endif}
end;


procedure Tstackmenu1.clear_dark_list1Click(Sender: TObject);
begin
  listview2.Clear;
end;


procedure update_stackmenu_mac;//Update menu shortcuts for Mac
begin
  with stackmenu1 do
  begin
    with selectall1 do shortcut := (shortcut and $BFFF) or $1000;    //replace Ctrl equals $4000 by Meta equals $1000
    with list_to_clipboard1 do shortcut := (shortcut and $BFFF) or $1000; //replace Ctrl equals $4000 by Meta equals $1000
    with selectall2 do shortcut := (shortcut and $BFFF) or $1000;    //replace Ctrl equals $4000 by Meta equals $1000
    with selectall3 do shortcut := (shortcut and $BFFF) or $1000;    //replace Ctrl equals $4000 by Meta equals $1000
    with selectall4 do shortcut := (shortcut and $BFFF) or $1000;    //replace Ctrl equals $4000 by Meta equals $1000
    with selectall5 do shortcut := (shortcut and $BFFF) or $1000;    //replace Ctrl equals $4000 by Meta equals $1000
    with selectall6 do shortcut := (shortcut and $BFFF) or $1000;    //replace Ctrl equals $4000 by Meta equals $1000
    with list_to_clipboard6 do shortcut := (shortcut and $BFFF) or $1000;  //replace Ctrl equals $4000 by Meta equals $1000
    with selectall7 do shortcut := (shortcut and $BFFF) or $1000;          //replace Ctrl equals $4000 by Meta equals $1000
    with list_to_clipboard7 do shortcut := (shortcut and $BFFF) or $1000;  //replace Ctrl equals $4000 by Meta equals $1000
    with selectall8 do shortcut := (shortcut and $BFFF) or $1000;          //replace Ctrl equals $4000 by Meta equals $1000
    with list_to_clipboard8 do shortcut := (shortcut and $BFFF) or $1000;  //replace Ctrl equals $4000 by Meta equals $1000
    with selectall9 do shortcut := (shortcut and $BFFF) or $1000;          //replace Ctrl equals $4000 by Meta equals $1000
    with list_to_clipboard9 do shortcut := (shortcut and $BFFF) or $1000;  //replace Ctrl equals $4000 by Meta equals $1000
  end;
end;


procedure Tstackmenu1.FormCreate(Sender: TObject);
var
  RealFontSize: integer;
begin
  RealFontSize := abs(Round((GetFontData(stackmenu1.Font.Handle).Height *
    72 / stackmenu1.Font.PixelsPerInch)));
  if realfontsize > 11 then stackmenu1.font.size := 11;{limit fontsize}

  {$ifdef mswindows}
  {$else} {unix}
    copy_files_to_clipboard1.visible:=false;  {works only in Windows}
    copy_files_to_clipboard1.enabled:=false;
  {$endif}

  {$IfDef Darwin}// for MacOS
  if commandline_execution=false then update_stackmenu_mac;
  {$endif}

end;

procedure Tstackmenu1.FormKeyPress(Sender: TObject; var Key: char);
begin
  if key = #27 then
  begin
    esc_pressed := True;
    memo2_message('ESC pressed. Execution stopped.');
  end;
end;


procedure Tstackmenu1.apply_gaussian_filter1Click(Sender: TObject);
begin
  if head.naxis = 0 then exit;

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img;
  gaussian_blur2(img_loaded, 4 * strtofloat2(most_common_filter_radius1.Text));
  plot_fits(mainwindow.image1, False, True);{plot}
  Screen.Cursor := crDefault;
  update_equalise_background_step(equalise_background_step + 1);{update menu}
end;


procedure listview_select(tl: tlistview);
var
  index: integer;
begin
  tl.Items.BeginUpdate;
  for index := 0 to tl.Items.Count - 1 do
  begin
    if tl.Items[index].Selected then
      tl.Items[index].Checked := True;
  end;
  tl.Items.EndUpdate;
end;


procedure Tstackmenu1.select1Click(Sender: TObject);
begin
  if Sender = select1 then listview_select(listview1);{from popupmenu}
  if Sender = select2 then listview_select(listview2);{from popupmenu}
  if Sender = select3 then listview_select(listview3);{from popupmenu}
  if Sender = select4 then listview_select(listview4);{from popupmenu}
  if Sender = select6 then listview_select(listview6);{from popupmenu blink}
  if Sender = select7 then listview_select(listview7);{from popupmenu blink}
  if Sender = select8 then listview_select(listview8);
  if Sender = select9 then listview_select(listview9);
end;


procedure Tstackmenu1.browse_bias1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select flat dark (bias) images';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist, ofHideReadOnly];
  opendialog1.filename := '';
  opendialog1.Filter := dialog_filter;
  //fits_file:=true;
  if opendialog1.Execute then
  begin
    listview4.Items.beginupdate;
    for i := 0 to OpenDialog1.Files.Count - 1 do {add}
    begin
      listview_add(listview4, OpenDialog1.Files[i], True, FD_nr);
    end;
    listview4.Items.endupdate;
  end;
end;


procedure Tstackmenu1.browse_blink1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select images to add';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist, ofHideReadOnly];
  opendialog1.Filter := dialog_filter;
  //fits_file:=true;
  if opendialog1.Execute then
  begin
    listview6.items.beginupdate;
    for i := 0 to OpenDialog1.Files.Count - 1 do {add}
      listview_add(listview6, OpenDialog1.Files[i], True, B_nr);
    listview6.items.endupdate;
  end;
end;


procedure Tstackmenu1.browse_flats1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select flat images';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist, ofHideReadOnly];
  opendialog1.filename := '';
  opendialog1.Filter := dialog_filter;
  //fits_file:=true;
  if opendialog1.Execute then
  begin
    listview3.items.beginupdate;
    for i := 0 to OpenDialog1.Files.Count - 1 do {add}
    begin
      listview_add(listview3, OpenDialog1.Files[i], True, F_nr);
    end;
    listview3.items.endupdate;

  end;
end;


function median_background(var img: image_array; color, sizeX, sizeY, x, y: integer): double;
  {find median value of an area at position x,y with sizeX,sizeY}
var
  i, j, Count, size2, stepX, stepY: integer;
  Value: double;
  pixArray: array of double;
  w, h: integer;
begin
  if (sizeX div 2) * 2 = sizeX then sizeX := sizeX + 1;{requires odd 3,5,7....}
  if (sizeY div 2) * 2 = sizeY then sizeY := sizeY + 1;{requires odd 3,5,7....}
  size2 := sizeX * sizeY;
  SetLength(pixArray, size2);
  stepX := sizeX div 2;
  stepY := sizeY div 2;
  Count := 0;
  w := Length(img[0]); {width}
  h := Length(img[0, 0]); {height}

  begin
    for j := y - stepY to y + stepY do
      for i := x - stepX to x + stepX do
      begin
        if ((i >= 0) and (i < w) and (j >= 0) and (j < h)) then
          {within the boundaries of the image array}
        begin
          Value := img[color, i, j];
          if Value <> 0 then {ignore zero}
          begin
            pixArray[Count] := Value;
            Inc(Count);
          end;
        end;
      end;
  end;

  //sort
  QuickSort(pixArray, Low(pixArray),
    Count - 1 { normally 8 for 3*3 equals High(intArray)});
  Result := pixArray[Count div 2];
  {for 3x3 matrix the median is 5th element equals in range 0..8 equals intArray[4]}
  pixArray := nil;
end;


procedure artificial_flatV1(var img: image_array; box_size: integer);
var
  fitsx, fitsy, i, j, col, step, colors, w, h: integer;
  offset: single;
  bg: double;
  img_temp2: image_array;
begin
  colors := Length(img); {colors}
  w := Length(img[0]); {width}
  h := Length(img[0, 0]); {height}

  {prepare img_temp2}
  setlength(img_temp2, colors, w, h);
  for col := 0 to colors - 1 do {do all colours}
    for fitsY := 0 to h - 1 do
      for fitsX := 0 to w - 1 do
        img_temp2[col, fitsX, fitsY] := 0;

  if (box_size div 2) * 2 = box_size then box_size := box_size + 1;{requires odd 3,5,7....}
  step := box_size div 2; {for 3*3 it is 1, for 5*5 it is 2...}

  {create artificial flat}
  for col := 0 to colors - 1 do {do all colours}
  begin
    bg := mode(img_loaded,true{ellipse shape}, col, round(0.2 * head.Width), round(0.8 * head.Width), round(0.2 * head.Height), round(0.8 * head.Height), 32000) - bg;
    {mode finds most common value for the 60% center }
    for fitsY := 0 to h - 1 do
      for fitsX := 0 to w - 1 do
      begin
        img_temp2[col, fitsX, fitsY] := 0;

        if ((frac(fitsX / box_size) = 0) and (frac(fitsy / box_size) = 0)) then
        begin
          offset := mode(img_loaded,false{ellipse shape}, col, fitsX - step, fitsX + step, fitsY - step, fitsY + step, 32000) - bg; {mode finds most common value}
          if ((offset < 0) {and (offset>-200)}) then
          begin
            for j := fitsy - step to fitsy + step do
              for i := fitsx - step to fitsx + step do
                if ((i >= 0) and (i < w) and (j >= 0) and (j < h)) then {within the boundaries of the image array}
                  img_temp2[col, i, j] := -offset;
          end;
        end;
      end;
  end;{all colors}

  {smooth flat}
  gaussian_blur2(img_temp2, box_size * 2);

  //   img_loaded:=img_temp2;
  //   exit;

  {apply artificial flat}
  for col := 0 to colors - 1 do {do all colours}
    for fitsY := 0 to h - 1 do
      for fitsX := 0 to w - 1 do
        img[col, fitsX, fitsY] := img[col, fitsX, fitsY] + img_temp2[col, fitsX, fitsY];

  img_temp2 := nil;
end;


procedure artificial_flatV2(var img: image_array; centrum_diameter: integer);
var
  fitsx, fitsy, dist, col, centerX, centerY, colors, w, h, leng, angle,
  Count, largest_distX, largest_distY: integer;
  offset, oldoffset: single;
  sn, cs: double;
  median, test: array of double;
  bck : Tbackground;
begin
  colors := Length(img); {colors}
  w := Length(img[0]); {width}
  h := Length(img[0, 0]); {height}

  areax1 := startX;
  areay1 := startY;
  areax2 := stopX;
  areay2 := stopY;

  if pos('de', stackmenu1.center_position1.Caption) > 0 then {contains word default}
  begin
    centerX := w div 2;
    centerY := h div 2;
  end
  else
  begin
    centerX := (areax1 + areax2) div 2;
    centerY := (areay1 + areay2) div 2;
  end;

  centrum_diameter := round(h * centrum_diameter / 100);{transfer percentage to pixels}

  largest_distX := max(centerX, w - centerX);
  largest_distY := max(centerY, h - centerY);

  leng := round(sqrt(sqr(largest_distX) + sqr(largest_distY)));
  setlength(median, leng + 1);

  for col := 0 to colors - 1 do {do all colours}
  begin
    get_background(col, img, True, False{do not calculate noise_level}, bck);
    {should be about 500 for mosaic since that is the target value}
    oldoffset := 0;
    for dist := leng downto 0 do
    begin
      if dist > centrum_diameter then
      begin{outside centrum}
        setlength(test, 360 * 3);
        Count := 0;
        for angle := 0 to (356 * 3) - 1 do
        begin
          sincos(angle * pi / (180 * 3), sn, cs);
          fitsy := round(sn * dist) + (centerY);
          fitsx := round(cs * dist) + (centerX);
          if ((fitsX < w) and (fitsX >= 0) and (fitsY < h) and (fitsY >= 0)) then
            {within the image}
          begin
            //memo2_message(inttostr(angle)+'    ' +floattostr(fitsX)+'     '+floattostr(fitsY) );
            offset := img[col, fitsX, fitsY] - bck.backgr;

            if oldoffset <> 0 then offset := 0.1 * offset + 0.9 * oldoffset;{smoothing}
            oldoffset := offset;

            test[Count] := img[col, fitsX, fitsY] - bck.backgr;
            Inc(Count, 1);
          end;
        end;
        if Count > 5 then {at least five points}
        begin
          median[dist] := smedian(test, Count);
        end
        else
          median[dist] := 0;

        //       memo2_message(#9+ floattostr(dist)+#9+ floattostr(median[dist]) +#9+ inttostr(count));
      end {outside centrum}
      else
        median[dist] := median[dist + 1];
    end;


    for fitsY := 0 to h - 1 do
      for fitsX := 0 to w - 1 do
      begin
        dist := round(sqrt(sqr(fitsX - (centerX)) + sqr(fitsY - (centerY))));
        {distance from centre}
        if median[dist] <> 0 then
        begin
          offset := median[dist];
          img[col, fitsX, fitsY] := img[col, fitsX, fitsY] - offset;
        end;

      end;
  end;{all colors}
  test := nil;
  median := nil;
end;


procedure Tstackmenu1.apply_artificial_flat_correction1Click(Sender: TObject);
var
  box_size: integer;
begin
  if head.naxis <> 0 then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    backup_img;  {store array in img_backup}

    try
      box_size := StrToInt(dark_areas_box_size1.Text);
    except
    end;

    memo2_message('Equalising background of ' + filename2);
    {equalize background}

    if Sender <> apply_artificial_flat_correctionV2 then
      artificial_flatV1(img_loaded, box_size)
    else
      artificial_flatV2(img_loaded,
        StrToInt(StringReplace(ring_equalise_factor1.Text, '%', '', [])));

    plot_fits(mainwindow.image1, False, True);{plot real}
    Screen.Cursor := crDefault;
  end;
end;


procedure apply_factors;{apply r,g,b factors to image}
var
  fitsX, fitsY: integer;
  multiply_red, multiply_green, multiply_blue, add_valueR, add_valueG,
  add_valueB, largest, scaleR, scaleG, scaleB, dum: single;
  acceptzero: boolean;
begin
  acceptzero := stackmenu1.ignorezero1.Checked = False;

  {do factor math behind so "subtract view from file" works in correct direction}
  add_valueR := strtofloat2(stackmenu1.add_valueR1.Text);
  add_valueG := strtofloat2(stackmenu1.add_valueG1.Text);
  add_valueB := strtofloat2(stackmenu1.add_valueB1.Text);

  multiply_red := strtofloat2(stackmenu1.multiply_red1.Text);
  multiply_green := strtofloat2(stackmenu1.multiply_green1.Text);
  multiply_blue := strtofloat2(stackmenu1.multiply_blue1.Text);

  {prevent clamping to 65535}
  scaleR := (65535 + add_valueR) * multiply_red / 65535;
  {range 0..1, if above 1 then final value could be above 65535}
  scaleG := (65535 + add_valueG) * multiply_green / 65535;
  scaleB := (65535 + add_valueB) * multiply_blue / 65535;
  largest := scaleR;
  if scaleG > largest then largest := scaleG;
  if scaleB > largest then largest := scaleB;
  if largest = 0 then largest := 1; {prevent division by zero}
  {use largest to scale to maximum 65535}

  if ((multiply_red <> 1) or (multiply_green <> 1) or (multiply_blue <> 1) or
    (add_valueR <> 0) or (add_valueG <> 0) or (add_valueB <> 0)) then
  begin
    for fitsY := 0 to head.Height - 1 do
      for fitsX := 0 to head.Width - 1 do
      begin
        dum := img_loaded[0, fitsX, fitsY];
        if ((acceptzero) or (dum > 0)) then {signal}
        begin
          dum := (dum + add_valueR) * multiply_red / largest;
          if dum < 0 then dum := 0;
          img_loaded[0, fitsX, fitsY] := dum;
        end;

        if head.naxis3 > 1 then {colour}
        begin
          dum := img_loaded[1, fitsX, fitsY];
          if ((acceptzero) or (dum > 0)) then {signal}
          begin
            dum := (dum + add_valueG) * multiply_green / largest;
            if dum < 0 then dum := 0;
            img_loaded[1, fitsX, fitsY] := dum;
          end;
        end;
        if head.naxis3 > 2 then {colour}
        begin
          dum := img_loaded[2, fitsX, fitsY];
          if ((acceptzero) or (dum > 0)) then {signal}
          begin
            dum := (dum + add_valueB) * multiply_blue / largest;
            if dum < 0 then dum := 0;
            img_loaded[2, fitsX, fitsY] := dum;
          end;
        end;
      end;
  end;
end;


procedure Tstackmenu1.apply_factor1Click(Sender: TObject);
begin
  if head.naxis <> 0 then
  begin
    backup_img; {move viewer data to img_backup}
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    apply_factors;
    use_histogram(img_loaded, True);
    plot_fits(mainwindow.image1, False, True);{plot real}
    Screen.Cursor := crDefault;
  end;
end;


procedure Tstackmenu1.apply_file1Click(Sender: TObject);
var
  fitsX, fitsY, col: integer;
  flat_norm_value, flat_factor: single;
  idx, old_naxis3: integer;
begin
  if head.naxis <> 0 then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    backup_img; {move viewer data to img_backup}
    old_naxis3 := head.naxis3;

    idx := add_substract1.ItemIndex;
    {add, multiply image}
    if length(image_to_add1.Caption) > 3 then {file name available}
    begin
      if load_fits(image_to_add1.Caption, False {dark/flat}, True
        {load data}, True {update memo}, 0, head, img_temp) then {succes load}
      begin
        if ((idx = 5) or (idx = 6)) then {apply file as flat or multiply}
        begin

          flat_norm_value := 0;
          for fitsY := -14 to 15 do {do even times, 30x30}
            for fitsX := -14 to 15 do
              flat_norm_value :=
                flat_norm_value + img_temp[0, fitsX + (head.Width div 2), fitsY + (head.Height div 2)];
          flat_norm_value := round(flat_norm_value / (30 * 30));

          for fitsY := 1 to head.Height do
            for fitsX := 1 to head.Width do
            begin
              for col := 0 to old_naxis3 - 1 do
                {do all colors. Viewer colours are stored in old_naxis3 by backup}
              begin
                if idx = 5 then {as flat=divide}
                begin
                  flat_factor :=
                    flat_norm_value / (img_temp[min(col, head.naxis3 - 1), fitsX - 1, fitsY - 1] + 0.0001);
                  {This works both for color and mono flats. Bias should be combined in flat}
                end
                else
                begin {multiply}
                  flat_factor :=
                    img_temp[min(col, head.naxis3 - 1), fitsX - 1, fitsY - 1] / flat_norm_value;
                  {This works both for color and mono flats. Bias should be combined in flat}
                end;
                img_loaded[col, fitsX - 1, fitsY - 1] :=
                  img_loaded[col, fitsX - 1, fitsY - 1] * flat_factor;
              end;
            end;
          head.naxis3 := old_naxis3;{could be changed by load file}
        end {apply file as flat}

        else
          for col := 0 to head.naxis3 - 1 do {all colors}
            for fitsY := 0 to head.Height - 1 do
              for fitsX := 0 to head.Width - 1 do
              begin
                if idx = 0 then {add}
                  img_loaded[col, fitsX, fitsY] :=
                    img_temp[col, fitsX, fitsY] + img_loaded[col, fitsX, fitsY]
                else
                if idx = 1 then {viewer minus file}
                  img_loaded[col, fitsX, fitsY] :=
                    img_loaded[col, fitsX, fitsY]{viewer} - img_temp[col, fitsX, fitsY]{file}
                else
                if idx = 2 then {viewer minus file +1000}
                  img_loaded[col, fitsX, fitsY] :=
                    img_loaded[col, fitsX, fitsY]{viewer} - img_temp[col, fitsX, fitsY]{file} + 1000
                else
                if idx = 3 then {file minus viewer}
                  img_loaded[col, fitsX, fitsY] :=
                    img_temp[col, fitsX, fitsY]{file} - img_loaded[col, fitsX, fitsY]{viewer}
                else
                if idx = 4 then {file minus viewer}
                  img_loaded[col, fitsX, fitsY] :=
                    img_temp[col, fitsX, fitsY]{file} - img_loaded[col, fitsX, fitsY]{viewer} + 1000;

              end;
      end;{file loaded}
    end;
    img_temp := nil;
    use_histogram(img_loaded, True);
    plot_fits(mainwindow.image1, False, True);{plot real}
    Screen.Cursor := crDefault;
  end;
end;


procedure Tstackmenu1.undo_button2Click(Sender: TObject);
begin
  if mainwindow.Undo1.Enabled then restore_img;
end;


procedure Tstackmenu1.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  auto_background1.Checked := False;
end;


procedure Tstackmenu1.apply_dpp_button1Click(Sender: TObject);
var
  Save_Cursor: TCursor;
  fitsx, fitsy, col: integer;
  a_factor, k_factor, bf, min, colr: single;
  bck : tbackground;
begin
  if head.naxis <> 0 then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    mainwindow.stretch1.Text := 'off';{switch off gamma}

    a_factor := strtofloat2(edit_a1.Text);
    k_factor := strtofloat2(edit_k1.Text);
    backup_img;  {store array in img_backup}
    {find background}
    if auto_background1.Checked then
    begin
      get_background(0, img_loaded, True, False{do not calculate noise_level}, bck);
      min := bck.backgr * 0.9;
      edit_background1.Text := floattostrf(min, ffgeneral, 4, 1); //floattostr6(min);

      for col := 0 to head.naxis3 - 1 do {all colors}
        for fitsY := 0 to head.Height - 1 do
          for fitsX := 0 to head.Width - 1 do
            img_loaded[col, fitsX, fitsY] := img_loaded[col, fitsX, fitsY] - min;
      {subtract background}
    end
    else
      min := strtofloat2(edit_background1.Text);

    if ddp_filter2.Checked then
      gaussian_blur2(img_loaded, strtofloat2(Edit_gaussian_blur1.Text));

    for col := 0 to head.naxis3 - 1 do {all colors}
      for fitsY := 0 to head.Height - 1 do
        for fitsX := 0 to head.Width - 1 do
        begin
          bf := (img_loaded[0, fitsX, fitsY] + a_factor);
          if bf < 0.00001 then colr := 0
          else
          begin
            colr := k_factor * a_factor *
              (img_backup[index_backup].img[col, fitsX, fitsY] - min) / bf;
            if colr > 65535 then colr := 65535;
            if colr < 0 then colr := 0;
          end;
          img_loaded[col, fitsX, fitsY] := colr;
        end;
    //apply_dpp_button1.Enabled := False;
    use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
    plot_fits(mainwindow.image1, True, True);{plot real}

    Screen.Cursor := crDefault;
  end;
end;


procedure apply_most_common(sourc, dest: image_array; radius: integer);
{apply most common filter on first array and place result in second array}
var
  fitsX, fitsY, i, j, k, x, y, x2, y2, diameter, most_common, colors3, height3, width3: integer;
begin
  diameter := radius * 2;
  colors3 := length(sourc);{nr colours}
  height3 := length(sourc[0, 0]);{height}
  width3 := length(sourc[0]);{width}

  for k := 0 to colors3 - 1 do {do all colors}
  begin

    for fitsY := 0 to round((height3 - 1) / diameter) do
      for fitsX := 0 to round((width3 - 1) / diameter) do
      begin
        x := fitsX * diameter;
        y := fitsY * diameter;
        most_common := mode(sourc,false{ellipse shape}, k, x - radius, x + radius - 1, y - radius, y + radius - 1, 32000);
        for i := -radius to +radius - 1 do
          for j := -radius to +radius - 1 do
          begin
            x2 := x + i;
            y2 := y + j;
            if ((x2 >= 0) and (x2 < width3) and (y2 >= 0) and (y2 < height3)) then  dest[k, x2, y2] := most_common;
          end;
      end;
  end;{K}
end;


procedure Tstackmenu1.most_common_filter_tool1Click(Sender: TObject);
var
  radius: integer;
begin
  if Length(img_loaded) = 0 then
  begin
    memo2_message('Error, no image in viewer loaded!');
    exit;
  end;

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img; {move copy to backup_img}

  try
    radius := StrToInt(stackmenu1.most_common_filter_radius1.Text);
  except
  end;

  apply_most_common(img_backup[index_backup].img, img_loaded, radius);
  {apply most common filter on first array and place result in second array}

  plot_fits(mainwindow.image1, False, True);{plot real}
  Screen.Cursor := crDefault;
  update_equalise_background_step(equalise_background_step + 1);{update menu}
end;


procedure trendline(xylist: star_list; len{length xylist} : integer; out  slope, intercept:double); //find linear trendline Y = magnitude_slope*X + intercept
var                                                                   //idea from https://stackoverflow.com/questions/43224/how-do-i-calculate-a-trendline-for-a-graph
  sumX,sumX2,sumY, sumXY,median,mad  : double;
  count, i                           : integer;

  median_array                  : array of double;

begin
  count:=0;
  sumX:=0;
  sumX2:=0;
  sumY:=0;
  sumXY:=0;

  for i:=0 to  len-1 do
  begin
    inc(count);
    //memo2_message(#9+floattostr(xylist[0,i])+#9+floattostr(xylist[1,i]));
    sumX:=sumX+xylist[0,i]; //sum X= sum B_V values = sum star colours;
    sumX2:=sumx2+sqr(xylist[0,i]);
    sumY:=sumY+xylist[1,i]; //sum Y, sum delta magnitudes;
    sumXY:=sumXY+xylist[0,i]*xylist[1,i];
  end;

  Slope:=(count*sumXY - sumX*sumY) / (count*sumX2 - sqr(sumX));   // b = (n*Σ(xy) - ΣxΣy) / (n*Σ(x^2) - (Σx)^2)
  Intercept:= (sumY - Slope * sumX)/count;                        // a = (Σy - bΣx)/n
end;

procedure trendline_without_outliers(xylist: star_list; len{length xylist} : integer; out  slope, intercept,sd: double);//find linear trendline Y = magnitude_slope*X + intercept. Remove outliers in step 2
var
  e        : double;
  xylist2  : star_list;
  counter,i  : integer;
begin
  trendline(xylist, len{length xylist}, {out}  slope, intercept);

  // find standard deviation
  sd:=0;
  setlength(xylist2,2,len);
  for i:=0 to len-1 do
  begin
    sd:=sd+ sqr(xylist[1,i]{y original} - (slope * xylist[0,i]+intercept){y mean});
  end;
  sd:=sqrt(sd/len); //sd

  //calculate the trendline but ignore outliers in Y (b-v)
  setlength(xylist2,2,len);
  counter:=0;
  for i:=0 to len-1 do
  begin
    e:=abs(xylist[1,i]{y original} - (slope * xylist[0,i]+intercept{y mean}));  //calculate absolute error
    if e<1.5 *sd then //not an outlier keep 86.64%
    begin
      xylist2[0,counter]:=xylist[0,i];// xy list without outliers
      xylist2[1,counter]:=xylist[1,i];
      inc(counter)
    end;
  end;

  trendline(xylist2, counter{length xylist2}, {out}  slope, intercept);
  xylist2:=nil;
end;


procedure Tstackmenu1.transformation1Click(Sender: TObject);
var
  i, countxy     : integer;
  magnitude,raM,decM,v,b,r,sg,sr,si,g,bp,rp : double;

  stars,xylist  : star_list;
  slope, intercept, sd : double;


begin
  if head.naxis=0 then
  begin
    memo2_message('Abort, no image in the viewer! Load an image first by double clicking on one of the files in the list.');
    exit; {file loaded?}
  end;

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  calibrate_photometry;

  if head.passband_database='V'=false then
  begin
    memo2_message('Abort, transformation is only possible using online Gaia database=V (filter V of TG). Select "Online Gaia -> auto" or  "Online Gaia -> V"');
    Screen.Cursor:=crDefault;
    exit;
  end;


  if head.mzero=0 then
  begin
    beep;
    Screen.Cursor:=crDefault;
    exit;
  end;

  measure_magnitudes(14,0,0,head.width-1,head.height-1,true {deep},stars);

  setlength(xylist,2, length(stars[0]));
  countxy:=0;

  if length(stars[0])>9 then
  begin
    for i:=0 to  length(stars[0])-1 do
    begin
      if stars[4,i]{SNR}>40 then
      begin
        magnitude:=(head.mzero - ln(stars[3,i]{flux})*2.5/ln(10));//flux to magnitude
        sensor_coordinates_to_celestial(1+stars[0,i],1+stars[1,i],raM,decM);//+1 to get fits coordinated
        report_one_star_magnitudes(raM,decM, {out} b,v,r,sg,sr,si,g,bp,rp ); //report the database magnitudes for a specfic position. Not efficient but simple routine

        if ((v>0) and (b>0)) then
        begin
          xylist[0,countxy]:=b-v; //gaiaB-gaiaV, star colour
          xylist[1,countxy]:=magnitude-v; //V- gaiaV, delta magnitude
          inc(countXY);

         // memo2_message(#9+floattostr(b-v)+#9+floattostr(magnitude-v));
        end;

      end;
    end;

      {Test for y=1.75*x+ 67.5
       setlength(xylist,2, 189);
       for countxy:=0 to 188 do
       begin
         xylist[0,countxy]:=countxy-10; //V- gaiaV
         xylist[1,countxy]:=50+countxy*1.75; //gaiaB-gaiaV
       end;
       // x     y         slope 1.75, intercept=67.5
       //-10    50
       // -9    51.75
       // -8    53.50

      //  xylist[0,1]:=100; //outlier y=100 instead of 51.75}


     memo2_message('Using '+inttostr(countXY)+' detected stars.');
     trendline_without_outliers(xylist,countXY,slope, intercept,sd);
     memo2_message('Slope is '+floattostrF(slope,FFfixed,5,3)+ '. Calculated required absolute transformation correction  ∆ V = '+floattostrF(intercept,FFfixed,5,3)+' + '+floattostrF(slope,FFfixed,5,3)+'*(B-V). Standard deviation of measured magnitude vs Gaia transformed for stars with SNR>40 and without B-V correction is '+floattostrF(sd,FFfixed,5,3)+ #10);

  end
  else
  memo2_message('Not enough stars found!');

  stars:=nil;
  xylist:=nil;
  Screen.Cursor:=crDefault;
end;



procedure Tstackmenu1.edit_background1Click(Sender: TObject);
begin
  auto_background1.Checked := False;
end;



procedure Tstackmenu1.clear_selection3Click(Sender: TObject);
begin
  listview4.Clear;
end;


procedure listview_rename_bak(tl: tlistview);
var
  index: integer;
begin
  index := tl.Items.Count - 1;
  while index >= 0 do
  begin
    if tl.Items[index].Selected then
    begin
      filename2 := tl.items[index].Caption;
      deletefile(changeFileExt(filename2, '.bak'));
      {delete *.bak left over from astrometric solution}
      if RenameFile(filename2, ChangeFileExt(filename2, '.bak')) then
        tl.Items.Delete(Index);
    end;
    Dec(index); {go to next file}
  end;
end;


procedure listview_update_keyword(tl: tlistview; keyw, Value: string);
{update key word of multiple files}
var
  index, counter, error2: integer;
  waarde: double;
  filename_old: string;
  success: boolean;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  index := 0;
  esc_pressed := False;
  counter := tl.Items.Count;
  while index < counter do
  begin
    if tl.Items[index].Selected then
    begin
      filename2 := tl.items[index].Caption;
      filename_old := filename2;

      if load_image(False, False {plot}) then {load}
      begin
        while length(keyw) < 8 do keyw := keyw + ' ';{increase length to 8}
        keyw := copy(keyw, 1, 8);{decrease if longer then 8}

        if uppercase(Value) = 'DELETE' then
          remove_key(keyw, True {all})
        {remove key word in header. If all=true then remove multiple of the same keyword}
        else
        begin
          val(Value, waarde, error2); {test for number or text}
          if error2 <> 0 then {text, not a number}
          begin
            while length(Value) < 8 do
              Value := Value + ' ';
            {increase length to minimum 8, one space will be added  in front later. See FITS standard 4.2.1.1 Single-record string keywords}
            update_text(keyw + '=', #39 + Value + #39);//spaces will be added later
          end
          else
            update_float(keyw + '=', ' /                                                ',true
              , waarde);

          {update listview}
          if keyw = 'OBJECT  ' then
            if tl = stackmenu1.listview1 then
              tl.Items.item[index].subitems.Strings[L_object] := Value;
          if keyw = 'FILTER  ' then
          begin
            if tl = stackmenu1.listview1 then
              tl.Items.item[index].subitems.Strings[L_filter] := Value;{light}
            if tl = stackmenu1.listview3 then
              tl.Items.item[index].subitems.Strings[F_filter] := Value;{flat}
          end;

        end;

        if fits_file_name(filename_old) then
          success := savefits_update_header(filename2)
        else
        if tiff_file_name(filename_old) then
          success := save_tiff16_secure(img_loaded, filename2){guarantee no file is lost}
        else
        begin
          filename2 := changefileExt(filename_old, '.fits');//xisf and raw files
          tl.items[index].Caption := filename2;
          {converted cr2 or other format when loaded. Update list with correct filename}
          success := save_fits(img_loaded, filename2, nrbits, True); //save as fits file
        end;
        if success = False then
        begin
          ShowMessage('Write error !!' + filename2);
          break;
        end;


        tl.ItemIndex := index;
        {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        tl.Items[index].MakeVisible(False);{scroll to selected item}
        application.ProcessMessages;
        if esc_pressed then break;
      end
      else
        beep;{image not found}
    end;
    Inc(index); {go to next file}
  end;
  Screen.Cursor := crDefault;
end;


procedure Tstackmenu1.renametobak1Click(Sender: TObject);
begin
  if Sender = renametobak1 then listview_rename_bak(listview1);{from popupmenu}
  if Sender = renametobak2 then listview_rename_bak(listview2);{from popupmenu}
  if Sender = renametobak3 then listview_rename_bak(listview3);{from popupmenu}
  if Sender = renametobak4 then listview_rename_bak(listview4);{from popupmenu}
  if Sender = renametobak5 then listview_rename_bak(listview5);{from popupmenu}
  if Sender = renametobak6 then listview_rename_bak(listview6);{from popupmenu blink}
  if Sender = renametobak7 then listview_rename_bak(listview7);{from popupmenu photometry}
  if Sender = renametobak8 then listview_rename_bak(listview8);{from popupmenu inspector}
  if Sender = renametobak9 then listview_rename_bak(listview9);
  {from popupmenu mount analyse}
end;


procedure Tstackmenu1.clear_selection2Click(Sender: TObject);
begin
  listview3.Clear;
end;


procedure Tstackmenu1.file_to_add1Click(Sender: TObject);
begin
  OpenDialog1.Title := 'Select image';
  OpenDialog1.Options := [ofFileMustExist, ofHideReadOnly];
  opendialog1.Filter :=
    'FITS or TIFF files|*.fit;*.fits;*.FIT;*.FITS;*.fts;*.FTS;*.tif;*.tiff;*.TIF';
  if opendialog1.Execute then
  begin
    image_to_add1.Caption := OpenDialog1.Files[0];
  end;
end;


procedure Tstackmenu1.FormResize(Sender: TObject);
var
  newtop: integer;
begin
  pagecontrol1.Height := classify_groupbox1.top;{make it High-DPI robust}

  newtop := browse1.top + browse1.Height + 5;
  ;

  listview1.top := newtop;
  listview2.top := newtop;
  listview3.top := newtop;
  listview4.top := newtop;
  listview5.top := newtop;
  listview6.top := newtop;
  listview7.top := newtop;
  listview8.top := newtop;

  memo2.top := classify_groupbox1.top + classify_groupbox1.Height + 4;
  {make it High-DPI robust}
  memo2.Height := stackmenu1.Height - memo2.top;{make it High-DPI robust}
end;


procedure set_icon_stackbutton(col: boolean);
//update glyph stack button to colour or gray
var
  bmp: tbitmap;
begin
  bmp := TBitmap.Create;
  if col then stackmenu1.ImageList2.GetBitmap(12, bmp){colour stack}
  else
    stackmenu1.ImageList2.GetBitmap(6, bmp);{gray stack}
  stackmenu1.stack_button1.glyph.Assign(bmp);
  FreeAndNil(bmp);
end;


procedure Tstackmenu1.FormShow(Sender: TObject);
begin
  set_icon_stackbutton(classify_filter1.Checked);//update glyph stack button

  stackmenu1.pagecontrol1Change(Sender);//update stackbutton1.enabled
end;


procedure Tstackmenu1.undo_button_equalise_background1Click(Sender: TObject);
begin
  if mainwindow.Undo1.Enabled then
  begin
    if equalise_background_step = 5 then
    begin {restart from step 1}
      if load_fits(filename2, True {light}, True, True {update memo}, 0, head, img_loaded) then
        {succes load}
      begin
        use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
        plot_fits(mainwindow.image1, False, True);{plot real}
        update_equalise_background_step(0); {go to step 0}
      end;
    end
    else
    begin
      restore_img;
    end;
  end;
end;


procedure listview_unselect(tl: tlistview);
var
  index: integer;
begin
  tl.Items.BeginUpdate;
  for index := 0 to tl.Items.Count - 1 do
  begin
    if tl.Items[index].Selected then
      tl.Items[index].Checked := False;
  end;
  tl.Items.EndUpdate;
end;


procedure Tstackmenu1.unselect1Click(Sender: TObject);
begin
  if Sender = unselect1 then listview_unselect(listview1);{popupmenu}
  if Sender = unselect2 then listview_unselect(listview2);{popupmenu}
  if Sender = unselect3 then listview_unselect(listview3);{popupmenu}
  if Sender = unselect4 then listview_unselect(listview4);{popupmenu}
  if Sender = unselect6 then listview_unselect(listview6);{popupmenu blink}
  if Sender = unselect7 then listview_unselect(listview7);
  if Sender = unselect8 then listview_unselect(listview8);{inspector}
  if Sender = unselect9 then listview_unselect(listview9);{inspector}
end;


procedure Tstackmenu1.unselect_area1Click(Sender: TObject);
begin
  area_set1.Caption := '⍻';
end;


procedure Tstackmenu1.apply_gaussian_blur_button1Click(Sender: TObject);
begin
  if head.naxis = 0 then exit;
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img;
  gaussian_blur2(img_loaded, strtofloat2(blur_factor1.Text));
  use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1, False, True);{plot}
  Screen.cursor := crDefault;
end;


procedure Tstackmenu1.listview1ColumnClick(Sender: TObject; Column: TListColumn);
begin
  SortedColumn := Column.Index;
end;


function CompareAnything(const s1, s2: string): integer;
var
  a, b: double;
  s: string;
  error1: integer;
begin
  s := StringReplace(s1, ',', '.', []); {replaces komma by dot}
  s := trim(s); {remove spaces}
  val(s, a, error1);
  if error1 = 0 then
  begin
    s := StringReplace(s2, ',', '.', []); {replaces komma by dot}
    s := trim(s); {remove spaces}
    val(s, b, error1);
  end;

  if error1 = 0 then {process as numerical values}
  begin
    if a > b then Result := +1
    else
    if a < b then Result := -1
    else
      Result := 0;
  end
  else
    Result := CompareText(s1, s2);{compare as text}
end;


procedure Tstackmenu1.listview1Compare(Sender: TObject; Item1, Item2: TListItem;
  Data: integer; var Compare: integer);

var
  tem: boolean;
begin
  if SortedColumn = 0 then Compare := CompareText(Item1.Caption, Item2.Caption)
  else
  if SortedColumn <> 0 then Compare :=
      CompareAnything(Item1.SubItems[SortedColumn - 1], Item2.SubItems[SortedColumn - 1]);
  if TListView(Sender).SortDirection = sdDescending then
    Compare := -Compare;
end;


procedure listview_view(tl: tlistview); {show image double clicked on}
var
  index: integer;
  fitsX, fitsY: double;
  theext: string;
begin
  for index := 0 to TL.Items.Count - 1 do
  begin
    if TL.Items[index].Selected then
    begin
      filename2 := TL.items[index].Caption;
      theext := ExtractFileExt(filename2);
      if theext = '.y4m' then
      begin
        memo2_message('Can not run videos');
        exit;
      end;{video}
      if theext = '.wcs' then filename2 := changefileext(filename2, '.fit');{for tab mount}
      if theext = '.wcss' then filename2 := changefileext(filename2, '.fits');{for tab mount}

      if load_image(mainwindow.image1.Visible = False, True {plot})
      {for the first image set the width and length of image1 correct} then
      begin
        if ((tl = stackmenu1.listview1) and
          (stackmenu1.use_manual_alignment1.Checked)) then
          {manual alignment}
          show_shape_manual_alignment(index){show the marker on the reference star}
        else
          mainwindow.shape_manual_alignment1.Visible := False;
        if ((tl = stackmenu1.listview7) and (stackmenu1.annotate_mode1.ItemIndex > 0)) then
          {show variable stars}
        begin
          application.ProcessMessages;
          mainwindow.variable_star_annotation1Click(nil);
          //show variable star annotations
        end;
      end
      else
        beep;{image not found}
      exit;{done, can display only one image}
    end;
  end;
  Screen.Cursor:=crDefault;//required sometimes for MacOS
end;


procedure Tstackmenu1.listview1DblClick(Sender: TObject);
begin
  listview_view(TListView(Sender));
  if ((pagecontrol1.tabindex = 8) {photometry} and (annotate_mode1.ItemIndex > 0)) then
    mainwindow.variable_star_annotation1Click(nil); //plot variable stars and comp star annotations
  Screen.Cursor := crDefault;;//just to be sure for Mac.
end;


function date_obs_regional(thedate: string): string;
  {fits date but remote T and replace . by comma if that is the regional separator}
begin
  Result := StringReplace(thedate, 'T', ' ', []);{date/time}
  if formatSettings.decimalseparator <> '.' then
    Result := StringReplace(Result, '.', formatSettings.decimalseparator, []);
  {replaces dot by komma}
end;


procedure analyse_listview(lv: tlistview; light, full, refresh: boolean);
{analyse list of FITS files}
var
  c, counts, i, iterations, hfd_counter, tabnr: integer;
  hfd_median, hjd, sd, dummy, alt, az, ra_jnow, dec_jnow, ra_mount_jnow,
  dec_mount_jnow, ram, decm, rax, decx, adu_e: double;
  filename1,filterstr,filterstrUP: string;
  Save_Cursor: TCursor;
  loaded, red, green, blue: boolean;
  img: image_array;
  nr_stars, hfd_outer_ring, median_11, median_21, median_31,
  median_12, median_22, median_32, median_13, median_23, median_33: double;
  bck : Tbackground;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  esc_pressed := False;

  if full = False then  lv.Items.BeginUpdate;
  {stop updating to prevent flickering till finished}

  counts := lv.items.Count - 1;
  red := False;
  green := False;
  blue := False;

  loaded := False;
  c := 0;

  {convert any non FITS file}
  while c <= counts {check all} do
  begin
    if lv.Items.item[c].Checked then
    begin
      filename1 := lv.items[c].Caption;
      if fits_tiff_file_name(filename1) = False  {fits file name?} then
        {not fits or tiff file}
      begin
        memo2_message('Converting ' + filename1 + ' to FITS file format');
        Application.ProcessMessages;
        if esc_pressed then
        begin
          Screen.Cursor := crDefault;
          { back to normal }  exit;
        end;
        if convert_to_fits(filename1) {convert to fits} then
          lv.items[c].Caption := filename1 {change listview name to FITS.}
        else
        begin {failure}
          lv.Items.item[c].Checked := False;
          lv.Items.item[c].subitems.Strings[L_result] := 'Conv failure!';

        end;
      end;
    end;{checked}
    Inc(c);
  end;

  if lv.Name = stackmenu1.listview2.Name then tabnr := 2 {dark tab}
  else
  if lv.Name = stackmenu1.listview3.Name then tabnr := 3 {flat tab}
  else
  if lv.Name = stackmenu1.listview4.Name then tabnr := 4 {dark-flat tab}
  else
  if lv.Name = stackmenu1.listview6.Name then tabnr := 6 {blink tab}
  else
  if lv.Name = stackmenu1.listview7.Name then tabnr := 7 {photometry tab}
  else
  if lv.Name = stackmenu1.listview8.Name then tabnr := 8 {inspector tab}
  else
  if lv.Name = stackmenu1.listview9.Name then tabnr := 9 {mount analyse tab}
  else
    tabnr := 0;


  c := 0;
  repeat {check for double entries}
    i := c + 1;
    while i <= counts do
    begin
      if lv.items[i].Caption = lv.items[c].Caption then {double file name}
      begin
        memo2_message('Removed second entry of same file ' + lv.items[i].Caption);
        lv.Items.Delete(i);
        //dec(i); {compensate for delete}
        Dec(counts); {compensate for delete}
      end
      else
        Inc(i);
    end;
    Inc(c);
  until c > counts;

  for c := 0 to lv.items.Count - 1 do
  begin
    if ((lv.Items.item[c].Checked) and ((refresh) or
      (length(lv.Items.item[c].subitems.Strings[4]) <= 1){height}) or
      ((full) and (tabnr <= 4 {darks, flat,flat-darks}) and
      (length(lv.Items.item[c].subitems.Strings[D_background]) <= 1))) then
      {column empthy, only update blank rows}
    begin
      progress_indicator(100 * c / lv.items.Count - 1, ' Analysing');
      lv.Selected := nil; {remove any selection}
      lv.ItemIndex := c;
      {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
      lv.Items[c].MakeVisible(False);{scroll to selected item}


      filename1 := lv.items[c].Caption;
      Application.ProcessMessages;
      if esc_pressed then
      begin
        break;{leave loop}
      end;

      loaded := load_fits(filename1, light {light or dark/flat}, full
        {full fits}, False {update memo}, 0, head_2, img); {for background or background+hfd+star}
      if loaded then
      begin {success loading header only}
        try
          begin
            if head_2.exposure >= 10 then
              lv.Items.item[c].subitems.Strings[D_exposure] :=
                IntToStr(round(head_2.exposure))
            else
              lv.Items.item[c].subitems.Strings[D_exposure] :=
                floattostrf(head_2.exposure, ffgeneral, 6, 6);

            lv.Items.item[c].subitems.Strings[D_temperature] :=
              IntToStr(head_2.set_temperature);
            lv.Items.item[c].subitems.Strings[D_binning] :=
              floattostrf(head_2.Xbinning, ffgeneral, 0, 0) + ' x ' + floattostrf(
              head_2.Ybinning, ffgeneral, 0, 0);
            {Binning CCD}
            lv.Items.item[c].subitems.Strings[D_width] := IntToStr(head_2.Width);
            {image width}
            lv.Items.item[c].subitems.Strings[D_height] := IntToStr(head_2.Height);
            {image height}
            lv.Items.item[c].subitems.Strings[D_type] := imagetype;{image type}


            if light = False then
            begin
              if head_2.egain <> '' then
                lv.Items.item[c].subitems.Strings[D_gain] := head_2.egain {e-/adu}
              else
              if head_2.gain <> '' then
                lv.Items.item[c].subitems.Strings[D_gain] := head_2.gain;

              if ((full = True) and (tabnr in [2, 3, 4, 7])) then
                {get background for dark, flats, flat-darks, photometry}
              begin {analyse background and noise}
                get_background(0, img, True {update_hist}, False {calculate noise level}, {var} bck);

                lv.Items.item[c].subitems.Strings[D_background] := inttostr5(round(bck.backgr));
                if tabnr <= 4 then
                begin //noise
                  {analyse centre only. Suitable for flats and dark with amp glow}
                  local_sd((head_2.Width div 2) - 50, (head_2.Height div 2) - 50,
                    (head_2.Width div 2) + 50, (head_2.Height div 2) + 50{regio of interest}, 0, img, sd, dummy {mean}, iterations);
                  {calculate mean and standard deviation in a rectangle between point x1,y1, x2,y2}

                  adu_e := retrieve_ADU_to_e_unbinned(head_2.egain);
                  //Factor for unbinned files. Result is zero when calculating in e- is not activated in the statusbar popup menu. Then in procedure HFD the SNR is calculated using ADU's only.
                  lv.Items.item[c].subitems.Strings[D_sigma] := noise_to_electrons(adu_e, head_2.Xbinning, sd);
                  //reports noise in ADU's (adu_e=0) or electrons
                end;
              end;
            end;

            if tabnr = 2 then {dark tab}
            begin
              lv.Items.item[c].subitems.Strings[D_date] := copy(head_2.date_obs, 1, 10);
              date_to_jd(head_2.date_obs, head_2.exposure);
              {convert head_2.date_obs string and head_2.exposure time to global variables jd_start (julian day start head_2.exposure) and jd_mid (julian day middle of the head_2.exposure)}
              lv.Items.item[c].subitems.Strings[D_jd] := floattostrF(jd_start, ffFixed, 0, 1);
              {julian day, 1/10 day accuracy}
            end
            else
            if tabnr = 3 then {flat tab}
            begin
              lv.Items.item[c].subitems.Strings[F_filter] := head_2.filter_name;
              {filter name, without spaces}
              if AnsiCompareText(stackmenu1.red_filter1.Text, head_2.filter_name) = 0 then
              begin
                Lv.Items.item[c].SubitemImages[F_filter] := 0;
                red := True;
              end
              else
              if AnsiCompareText(stackmenu1.red_filter2.Text, head_2.filter_name) = 0 then
              begin
                Lv.Items.item[c].SubitemImages[F_filter] := 0;
                red := True;
              end
              else
              if AnsiCompareText(stackmenu1.green_filter1.Text, head_2.filter_name) = 0 then
              begin
                lv.Items.item[c].SubitemImages[F_filter] := 1;
                green := True;
              end
              else
              if AnsiCompareText(stackmenu1.green_filter2.Text, head_2.filter_name) = 0 then
              begin
                lv.Items.item[c].SubitemImages[F_filter] := 1;
                green := True;
              end
              else
              if AnsiCompareText(stackmenu1.blue_filter1.Text, head_2.filter_name) = 0 then
              begin
                lv.Items.item[c].SubitemImages[F_filter] := 2;
                blue := True;
              end
              else
              if AnsiCompareText(stackmenu1.blue_filter2.Text, head_2.filter_name) = 0 then
              begin
                lv.Items.item[c].SubitemImages[F_filter] := 2;
                blue := True;
              end
              else
              if AnsiCompareText(stackmenu1.luminance_filter1.Text,
                head_2.filter_name) = 0 then
                lv.Items.item[c].SubitemImages[F_filter] := 4
              else
              if AnsiCompareText(stackmenu1.luminance_filter2.Text,
                head_2.filter_name) = 0 then
                lv.Items.item[c].SubitemImages[F_filter] := 4
              else
              if head_2.naxis3 = 3 then  lv.Items.item[c].SubitemImages[F_filter] := 3
              else {RGB color}
              if head_2.filter_name <> '' then
                lv.Items.item[c].SubitemImages[F_filter] := 7 {question mark}
              else
                lv.Items.item[c].SubitemImages[F_filter] := -1;{blank}

              {$ifdef darwin} {MacOS, fix missing icons by coloured unicode. Place in column "type" to avoid problems with textual filter selection}
              if red then Lv.Items.item[c].subitems.Strings[D_type]:='🔴' +Lv.Items.item[c].subitems.Strings[D_type]
              else
              if green then Lv.Items.item[c].subitems.Strings[D_type]:='🟢' +Lv.Items.item[c].subitems.Strings[D_type]
              else
              if blue then Lv.Items.item[c].subitems.Strings[D_type]:='🔵' +Lv.Items.item[c].subitems.Strings[D_type];
              {$endif}

              lv.Items.item[c].subitems.Strings[D_date] := copy(head_2.date_obs, 1, 10);
              date_to_jd(head_2.date_obs, head_2.exposure);
              {convert head_2.date_obs string and head_2.exposure time to global variables jd_start (julian day start head_2.exposure) and jd_mid (julian day middle of the head_2.exposure)}
              lv.Items.item[c].subitems.Strings[F_jd] := floattostrF(jd_start, ffFixed, 0, 1);
              {julian day, 1/10 day accuracy}
              lv.Items.item[c].subitems.Strings[F_calibration] := head_2.calstat;
            end
            else
            if tabnr = 4 then {flat darks tab}
            begin
              lv.Items.item[c].subitems.Strings[D_date] := copy(head_2.date_obs, 1, 10);
            end
            else
            if tabnr = 6 then {blink tab}
            begin
              lv.Items.item[c].subitems.Strings[B_date] :=
                StringReplace(copy(head_2.date_obs, 1, 19), 'T', ' ', []);
              {date/time for blink. Remove fractions of seconds}
              lv.Items.item[c].subitems.Strings[B_calibration] := head_2.calstat;
              {calibration head_2.calstat info DFB}
              if annotated then lv.Items.item[c].subitems.Strings[B_annotated] := '✓'
              else
                lv.Items.item[c].subitems.Strings[B_annotated] := '';
            end
            else

            if tabnr = 7 then {photometry tab}
            begin
              lv.Items.item[c].subitems.Strings[P_date] :=
                StringReplace(copy(head_2.date_obs, 1, 19), 'T', ' ', []);
              {date/time for blink. Remove fractions of seconds}
              lv.Items.item[c].subitems.Strings[P_filter] := head_2.filter_name;


              filterstr:=head_2.filter_name;// R, G or V, B or TG
              filterstrUP:=uppercase(filterstr);
              if ((length(filterstr)=0) or (pos('CV',filterstrUP)>0))  then lv.Items.item[c].SubitemImages[P_filter]:=-1 //unknown
              else
              if pos('S',filterstrUP)>0 then //sloan
              begin
                if pos('I',filterstrUP)>0  then lv.Items.item[c].SubitemImages[P_filter]:=21 //SDSS-i
                else
                if pos('R',filterstrUP)>0  then lv.Items.item[c].SubitemImages[P_filter]:=22 //SDSS-r
                else
                if pos('G',filterstrUP)>0  then lv.Items.item[c].SubitemImages[P_filter]:=23 //SDSS-g
                else
                lv.Items.item[c].SubitemImages[P_filter]:=-1; //unknown
              end
              else //Johnson-Cousins
              if pos('TR',filterstrUP)>0  then lv.Items.item[c].SubitemImages[P_filter]:=0 //Red
              else
              if pos('R',filterstrUP)>0  then lv.Items.item[c].SubitemImages[P_filter]:=24 //Cousins-red
              else
              if pos('V',filterstrUP)>0  then lv.Items.item[c].SubitemImages[P_filter]:=1 //green
              else
              if pos('G',filterstrUP)>0  then lv.Items.item[c].SubitemImages[P_filter]:=1 //green
              else
              if pos('B',filterstrUP)>0  then lv.Items.item[c].SubitemImages[P_filter]:=2 //blue
              else
              lv.Items.item[c].SubitemImages[P_filter]:=-1; //unknown

              date_to_jd(head_2.date_obs, head_2.exposure);
              {convert head_2.date_obs string and head_2.exposure time to global variables jd_start (julian day start head_2.exposure) and jd_mid (julian day middle of the head_2.exposure)}
              lv.Items.item[c].subitems.Strings[P_jd_mid] :=
                floattostrF(jd_mid, ffFixed, 0, 5);{julian day}

              hjd := JD_to_HJD(jd_mid, head_2.ra0, head_2.dec0);{conversion JD to HJD}
              lv.Items.item[c].subitems.Strings[P_jd_helio] :=
                floattostrF(Hjd, ffFixed, 0, 5);{helio julian day}


              calculate_az_alt(0 {try to use header values}, head_2,{out}az, alt);  {try to get  a value for alt}
              if ((centalt = '') and (alt <> 0)) then  centalt := floattostrf(alt, ffGeneral, 3, 1); {altitude}

              lv.Items.item[c].subitems.Strings[P_centalt] := centalt; {altitude}
              if alt <> 0 then lv.Items.item[c].subitems.Strings[P_airmass] :=
                  floattostrf(AirMass_calc(alt), ffFixed, 0, 3); {airmass}

              {magn is column 9 will be added separately}
              {solution is column 12 will be added separately}
              if head_2.calstat <> '' then
                lv.Items.item[c].subitems.Strings[P_calibration] := head_2.calstat
              else
                lv.Items.item[c].subitems.Strings[P_calibration] := 'None';
              {calibration head_2.calstat info DFB}

              if head_2.cd1_1 = 0 then lv.Items.item[c].subitems.Strings[P_astrometric] := ''
              else
                lv.Items.item[c].subitems.Strings[P_astrometric] := '✓';

              if full {amode=3} then {listview7 photometry plus mode}
              begin

                analyse_image(img, head_2, 10 {snr_min}, False, hfd_counter, bck, hfd_median);
                {find background, number of stars, median HFD}
                lv.Items.item[c].subitems.Strings[P_background]:= inttostr5(round(bck.backgr));
                lv.Items.item[c].subitems.Strings[P_hfd] := floattostrF(hfd_median, ffFixed, 0, 1);
                lv.Items.item[c].subitems.Strings[P_stars] := inttostr5(hfd_counter);
                {number of stars}
              end;
            end
            else

            if tabnr = 8 then {listview8 inspector tab}
            begin
              lv.Items.item[c].subitems.Strings[I_date] := StringReplace(copy(head_2.date_obs, 1, 19), 'T', ' ', []);
              {date/time for blink. Remove fractions of seconds}

              lv.Items.item[c].subitems.Strings[I_focus_pos] := IntToStr(focus_pos);

              analyse_image_extended(img, head_2, nr_stars, hfd_median, hfd_outer_ring, median_11, median_21, median_31, median_12, median_22, median_32, median_13, median_23, median_33); {analyse several areas}

              if ((hfd_median > 25) or (median_22 > 25) or (hfd_outer_ring > 25) or (median_11 > 25) or (median_31 > 25) or (median_13 > 25) or (median_33 > 25)) then
              begin
                lv.Items.item[c].Checked := False; {uncheck}
                lv.Items.item[c].subitems.Strings[I_nr_stars] := '❌';
              end
              else
                lv.Items.item[c].subitems.Strings[I_nr_stars] :=
                  floattostrF(nr_stars, ffFixed, 0, 0);

              lv.Items.item[c].subitems.Strings[I_nr_stars + 2] := floattostrF(hfd_median, ffFixed, 0, 3);
              lv.Items.item[c].subitems.Strings[I_nr_stars + 3] := floattostrF(median_22, ffFixed, 0, 3);
              lv.Items.item[c].subitems.Strings[I_nr_stars + 4] := floattostrF(hfd_outer_ring, ffFixed, 0, 3);
              lv.Items.item[c].subitems.Strings[I_nr_stars + 5] := floattostrF(median_11, ffFixed, 0, 3);
              lv.Items.item[c].subitems.Strings[I_nr_stars + 6] := floattostrF(median_21, ffFixed, 0, 3);
              lv.Items.item[c].subitems.Strings[I_nr_stars + 7] := floattostrF(median_31, ffFixed, 0, 3);

              lv.Items.item[c].subitems.Strings[I_nr_stars + 8] := floattostrF(median_12, ffFixed, 0, 3);

              lv.Items.item[c].subitems.Strings[I_nr_stars + 9] := floattostrF(median_32, ffFixed, 0, 3);

              lv.Items.item[c].subitems.Strings[I_nr_stars + 10] := floattostrF(median_13, ffFixed, 0, 3);
              lv.Items.item[c].subitems.Strings[I_nr_stars + 11] := floattostrF(median_23, ffFixed, 0, 3);
              lv.Items.item[c].subitems.Strings[I_nr_stars + 12] := floattostrF(median_33, ffFixed, 0, 3);
            end
            else

            if tabnr = 9 then {mount analyse tab}
            begin

              lv.Items.item[c].subitems.Strings[M_date] := date_obs_regional(head_2.date_obs);
              date_to_jd(head_2.date_obs, head_2.exposure);
              {convert head_2.date_obs string and head_2.exposure time to global variables jd_start (julian day start head_2.exposure) and jd_mid (julian day middle of the head_2.exposure)}

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


              lv.Items.item[c].subitems.Strings[M_jd_mid] :=floattostrF(jd_mid, ffFixed, 0, 7);{julian day}

              if ra_mount < 99 then {mount position known and specified}
              begin
                if stackmenu1.hours_and_minutes1.Checked then
                begin
                  lv.Items.item[c].subitems.Strings[M_ra_m]:=prepare_ra8(ra_mount, ':');
                  {radialen to text, format 24: 00 00.00 }
                  lv.Items.item[c].subitems.Strings[M_dec_m]:=prepare_dec2(dec_mount, ':');{radialen to text, format 90d 00 00.1}
                end
                else
                begin
                  lv.Items.item[c].subitems.Strings[M_ra_m]:=floattostrf(ra_mount * 180 / pi, ffFixed, 9, 6);
                  lv.Items.item[c].subitems.Strings[M_dec_m]:=floattostrf(dec_mount * 180 / pi, ffFixed, 9, 6);
                end;

                if jd_mid > 2400000 then {valid JD}
                begin
                  ra_mount_jnow := ra_mount;
                  dec_mount_jnow := dec_mount;
                  J2000_to_apparent(jd_mid, ra_mount_jnow, dec_mount_jnow);
                  {without refraction}
                  lv.Items.item[c].subitems.Strings[M_ra_m_jnow] := floattostrf(ra_mount_jnow * 180 / pi, ffFixed, 9, 6);
                  lv.Items.item[c].subitems.Strings[M_dec_m_jnow] := floattostrf(dec_mount_jnow * 180 / pi, ffFixed, 9, 6);
                end;
              end;

              if head_2.cd1_1 <> 0 then
              begin

                if stackmenu1.hours_and_minutes1.Checked then
                begin
                  lv.Items.item[c].subitems.Strings[M_ra] := prepare_ra8(head_2.ra0, ':');
                  {radialen to text, format 24: 00 00.00 }
                  lv.Items.item[c].subitems.Strings[M_dec] := prepare_dec2(head_2.dec0, ':');{radialen to text, format 90d 00 00.1}
                end
                else
                begin
                  lv.Items.item[c].subitems.Strings[M_ra] :=
                    floattostrf(head_2.ra0 * 180 / pi, ffFixed, 9, 6);
                  lv.Items.item[c].subitems.Strings[M_dec] := floattostrf(head_2.dec0 * 180 / pi, ffFixed, 9, 6);
                end;


                if ra_mount < 99 then {mount position known and specified}
                begin
                  lv.Items.item[c].subitems.Strings[M_ra_e] := floattostrf((head_2.ra0 - ra_mount) * cos(head_2.dec0) * 3600 * 180 / pi, ffFixed, 6, 1);
                  lv.Items.item[c].subitems.Strings[M_dec_e] := floattostrf((head_2.dec0 - dec_mount) * 3600 * 180 / pi, ffFixed, 6, 1);
                end
                else
                begin
                  lv.Items.item[c].subitems.Strings[M_ra_e] := '?';
                  lv.Items.item[c].subitems.Strings[M_dec_e] := '?';
                end;

                ra_jnow := head_2.ra0;{J2000 apparent from image solution}
                dec_jnow := head_2.dec0;
                if jd_mid > 2400000 then {valid JD}
                begin
                  J2000_to_apparent(jd_mid, ra_jnow, dec_jnow);{without refraction}

                  //   rax:=ra_jnow;
                  //   decx:=dec_jnow;
                  //   nutation_aberration_correction_equatorial_classic(jd_mid,ra_jnow,dec_jnow);{Input mean equinox.  M&memo2 page 208}
                  //   memo2_message(#9+filename2+#9+floattostr(jd_mid)+#9+floattostr((ra_jnow-rax)*180/pi)+#9+floattostr((dec_jnow-decx)*180/pi));

                  lv.Items.item[c].subitems.Strings[M_ra_jnow] := floattostrf(ra_jnow * 180 / pi, ffFixed, 9, 6);
                  lv.Items.item[c].subitems.Strings[M_dec_jnow]:=floattostrf(dec_jnow * 180 / pi, ffFixed, 9, 6);

                  calculate_az_alt(2 {force accurate calculation from ra, dec},
                    head_2,{out}az, alt); {call it with J2000 values. Precession will be applied in the routine}
                  if alt <> 0 then
                  begin
                    centalt := floattostrf(alt, ffFixed, 9, 6); {altitude}
                    centaz := floattostrf(az, ffFixed, 9, 6); {azimuth}
                  end;
                  lv.Items.item[c].subitems.Strings[M_centalt] := centalt;
                  lv.Items.item[c].subitems.Strings[M_centaz] := centaz;
                end;

                {calculate crota_jnow}
                coordinates_to_celestial(head_2.crpix1, head_2.crpix2 + 1,
                  head_2, ram, decm);
                {fitsX, Y to ra,dec}{Step one pixel in Y}
                J2000_to_apparent(jd_mid, ram, decm);{without refraction}
                lv.Items.item[c].subitems.Strings[M_crota_jnow] := floattostrf(arctan2((ram - ra_jnow) * cos(dec_jnow), decm - dec_jnow) * 180 / pi, ffFixed, 7, 4);
              end;
              if focus_temp <> 999 then
                Lv.Items.item[c].subitems.Strings[M_foctemp] := floattostrF(focus_temp, ffFixed, 0, 1);
              Lv.Items.item[c].subitems.Strings[M_pressure] :=  floattostrF(pressure, ffFixed, 0, 1);

            end;
          end;
        finally
        end;
      end
      else
      begin
        lv.Items.item[c].Checked := False; {can't analyse this one}
        memo2_message('Error reading ' + filename1);
      end;
    end;{hfd unknown}
  end;

  if ((green) and (blue) and (stackmenu1.classify_flat_filter1.Checked = False)) then
    memo2_message( '■■■■■■■■■■■■■ Hint, colour filters detected in the flat. For colour stacking set the check-mark classify by Flat Filter! ■■■■■■■■■■■■■');

  if full = False then lv.Items.EndUpdate;{can update now}
  progress_indicator(-100, '');{progresss done}
  img := nil;

  Screen.Cursor := crDefault;{back to normal }
end;


procedure average(mess: string; file_list: array of string; file_count: integer;
  var img2: image_array);
{combine to average or mean, make also mono from three colors if color}
var
  {this routine works with mono files but makes coloured files mono, so less suitable for commercial cameras producing coloured raw lights}
  c, fitsX, fitsY: integer;
  img_tmp1: image_array;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  {average}
  for c := 0 to file_count - 1 do
  begin
    memo2_message('Adding ' + mess + ' image ' + IntToStr(c + 1) +
      ' to ' + mess + ' average. ' + file_list[c]);

    {load image}
    Application.ProcessMessages;
    if ((esc_pressed) or (load_fits(file_list[c], False {light}, True,
      True {update memo}, 0, head, img_tmp1) = False)) then
    begin
      Screen.Cursor := crDefault;
      exit;
    end;

    if c = 0 then {init}
    begin
      setlength(img2, 1, head.Width, head.Height);{set length of image array mono}
      for fitsY := 0 to head.Height - 1 do
        for fitsX := 0 to head.Width - 1 do
          img2[0, fitsX, fitsY] := 0; {clear img}
    end;

    if head.naxis3 = 3 then
      {for the rare case the darks are coloured. Should normally be not the case since it expects raw mono FITS files without bayer matrix applied !!}
    begin {color average}
      for fitsY := 0 to head.Height - 1 do
        for fitsX := 0 to head.Width - 1 do
          img2[0, fitsX, fitsY] :=
            img2[0, fitsX, fitsY] + (img_tmp1[0, fitsX, fitsY] + img_tmp1[1, fitsX, fitsY] +
            img_tmp1[2, fitsX, fitsY]) / 3;{fill with image}
    end
    else
    begin {mono average}
      for fitsY := 0 to head.Height - 1 do
        for fitsX := 0 to head.Width - 1 do
          img2[0, fitsX, fitsY] := img2[0, fitsX, fitsY] + img_tmp1[0, fitsX, fitsY];
      {fill with image}

    end;
  end;{open files}

  if file_count > 1 then {not required for single/master files}
    for fitsY := 0 to head.Height - 1 do
      for fitsX := 0 to head.Width - 1 do
        img2[0, fitsX, fitsY] := img2[0, fitsX, fitsY] / file_count;{scale to one image}

  img_tmp1 := nil;{free memo2}
  Screen.Cursor := crDefault;  { Always restore to normal }
end;


function average_flatdarks(exposure: double): integer;
var
  c, file_count: integer;
  file_list: array of string;
begin
  analyse_listview(stackmenu1.listview4, False {light}, False {full fits}, False{refesh});
  {update the flat-dark tab information. Convert to FITS if required}
  setlength(file_list, stackmenu1.listview4.items.Count);
  file_count := 0;
  Result := 0;{just in case no flat-dark are found}
  for c := 0 to stackmenu1.listview4.items.Count - 1 do
    if stackmenu1.listview4.items[c].Checked = True then
    begin
      if ((exposure < 0){disabled} or
        (abs(strtofloat(stackmenu1.listview4.Items.item[c].subitems.Strings[FD_exposure]) -
        exposure) < 0.01)) then
      begin
        file_list[file_count] := stackmenu1.ListView4.items[c].Caption;
        Inc(file_count);
      end;
    end;
  if file_count <> 0 then
  begin
    memo2_message('Averaging flat dark frames.');
    average('flat-dark', file_list, file_count, img_bias);{only average}
    Result := head.Width; {width of the flat-dark}
  end;
  head.flatdark_count := file_count;
  file_list := nil;
end;



procedure box_blur(colors, range: integer;
  var img: image_array);{combine values of pixels, ignore zeros}
var
  fitsX, fitsY, k, x1, y1, col, w, h, i, j, counter, minimum, maximum: integer;
  img_temp2: image_array;
  Value, value2: single;
begin
  col := length(img);{the real number of colours}
  h := length(img[0, 0]);{height}
  w := length(img[0]);{width}

  if range = 2 then
  begin
    minimum := 0;
    maximum := +1;
  end {combine values of 4 pixels}
  else
  if range = 3 then
  begin
    minimum := -1;
    maximum := +1;
  end {combine values of 9 pixels}
  else
  if range = 4 then
  begin
    minimum := -1;
    maximum := +2;
  end {combine values of 16 pixels}
  else
  begin
    minimum := -2;
    maximum := +2;
  end; {combine values of 25 pixels}

  setlength(img_temp2, col, w, h);{set length of image array}
  for k := 0 to col - 1 do
  begin
    for fitsY := 0 to h - 1 do
      for fitsX := 0 to w - 1 do
      begin
        Value := 0;
        counter := 0;
        for i := minimum to maximum do
          for j := minimum to maximum do
          begin
            x1 := fitsX + i;
            y1 := fitsY + j;
            if ((x1 >= 0) and (x1 <= w - 1) and (y1 >= 0) and (y1 <= h - 1)) then
            begin
              value2 := img[k, x1, y1];
              if value2 <> 0 then
              begin
                Value := Value + value2;
                Inc(counter);
              end;{ignore zeros}
            end;
          end;
        if counter <> 0 then img_temp2[k, fitsX, fitsY] := Value / counter
        else
          img_temp2[k, fitsX, fitsY] := 0;
      end;
  end;{k}

  if ((colors = 1){request} and (col = 3){actual}) then
    {rare, need to make mono, copy back to img}
  begin
    for fitsY := 0 to h - 1 do
      for fitsX := 0 to w - 1 do
        for k := 0 to col - 1 do
          img[0, fitsx, fitsy] := (img_temp2[0, fitsx, fitsy] + img_temp2[1, fitsx, fitsy] +
            img_temp2[2, fitsx, fitsy]) / 3;
  end
  else
    img := img_temp2;{move pointer array}

  head.naxis3 := colors;{the final result}
  img_temp2 := nil;
end;


procedure check_pattern_filter(var img: image_array);
{normalize bayer pattern. Colour shifts due to not using a white light source for the flat frames are avoided.}
var
  fitsX, fitsY, col, h, w, counter1, counter2, counter3, counter4: integer;
  value1, value2, value3, value4, maxval: double;
  oddx, oddy: boolean;
begin
  col := length(img);{the real number of colours}
  h := length(img[0, 0]);{height}
  w := length(img[0]);{width}

  if col > 1 then
  begin
    memo2_message('Skipping normalise filter. This filter works only for raw OSC images!');
    exit;
  end
  else
    memo2_message('Normalise raw OSC image by applying check pattern filter.');

  value1 := 0;
  value2 := 0;
  value3 := 0;
  value4 := 0;
  counter1 := 0;
  counter2 := 0;
  counter3 := 0;
  counter4 := 0;

  for fitsY := (h div 4) to (h * 3) div 4 do
    {use one quarter of the image to find factors. Works also a little better if no dark-flat is subtracted. It also works better if boarder is black}
    for fitsX := (w div 4) to (w * 3) div 4 do
    begin
      oddX := odd(fitsX);
      oddY := odd(fitsY);
      if ((oddX = False) and (oddY = False)) then
      begin
        value1 := value1 + img[0, fitsX, fitsY];
        Inc(counter1);
      end
      else {separate counters for case odd() dimensions are used}
      if ((oddX = True) and (oddY = False)) then
      begin
        value2 := value2 + img[0, fitsX, fitsY];
        Inc(counter2);
      end
      else
      if ((oddX = False) and (oddY = True)) then
      begin
        value3 := value3 + img[0, fitsX, fitsY];
        Inc(counter3);
      end
      else
      if ((oddX = True) and (oddY = True)) then
      begin
        value4 := value4 + img[0, fitsX, fitsY];
        Inc(counter4);
      end;
    end;

  {now normalise the bayer pattern pixels}
  value1 := value1 / counter1;
  value2 := value2 / counter2;
  value3 := value3 / counter3;
  value4 := value4 / counter4;
  maxval := max(max(value1, value2), max(value3, value4));
  value1 := maxval / value1;
  value2 := maxval / value2;
  value3 := maxval / value3;
  value4 := maxval / value4;

  for fitsY := 0 to h - 1 do
    for fitsX := 0 to w - 1 do
    begin
      oddX := odd(fitsX);
      oddY := odd(fitsY);
      if ((value1 <> 1) and (oddX = False) and (oddY = False)) then
        img[0, fitsX, fitsY] := round(img[0, fitsX, fitsY] * value1)
      else
      if ((value2 <> 1) and (oddX = True) and (oddY = False)) then
        img[0, fitsX, fitsY] := round(img[0, fitsX, fitsY] * value2)
      else
      if ((value3 <> 1) and (oddX = False) and (oddY = True)) then
        img[0, fitsX, fitsY] := round(img[0, fitsX, fitsY] * value3)
      else
      if ((value4 <> 1) and (oddX = True) and (oddY = True)) then
        img[0, fitsX, fitsY] := round(img[0, fitsX, fitsY] * value4);
    end;
end;


procedure black_spot_filter(var img: image_array);
{remove black spots with value zero}{execution time about 0.4 sec}
var
  fitsX, fitsY, k, x1, y1, col, w, h, i, j, counter, range, left, right, bottom, top: integer;
  img_temp2: image_array;
  Value, value2: single;
  black: boolean;
begin
  col := length(img);{the real number of colours}
  h := length(img[0, 0]);{height}
  w := length(img[0]);{width}

  range := 1;
  setlength(img_temp2, col, w, h);{set length of image array}

  for k := 0 to col - 1 do
  begin
    {find the black borders for each colour}
    left := -1;
    repeat
      Inc(left);
      black := img[k, left, h div 2] = 0;
    until ((black = False) or (left >= w - 1));

    right := w;
    repeat
      Dec(right);
      black := img[k, right, h div 2] = 0;
    until ((black = False) or (right <= 0));

    bottom := -1;
    repeat
      Inc(bottom);
      black := img[k, w div 2, bottom] = 0;
    until ((black = False) or (bottom >= h - 1));

    top := h;
    repeat
      Dec(top);
      black := img[k, w div 2, top] = 0;
    until ((black = False) or (top <= 0));



    for fitsY := 0 to h - 1 do
      for fitsX := 0 to w - 1 do
      begin
        Value := img[k, fitsX, fitsY];
        if Value = 0 then {black spot or saturation marker}
          if ((fitsX >= left) and (fitsX <= right) and (fitsY >= bottom) and (fitsY <= top)) then
            {not the incomplete borders}
          begin
            range := 1;
            repeat
              counter := 0;
              for i := -range to range do
                for j := -range to range do
                begin
                  if ((abs(i) = range) or (abs(j) = range)) then {square search range}
                  begin
                    x1 := fitsX + i;
                    y1 := fitsY + j;
                    if ((x1 >= left) and (x1 <= right) and (Y1 >= bottom) and (y1 <= top)) then
                      {not the incomplete borders}
                    begin
                      value2 := img[k, x1, y1];
                      if value2 <> 0 then {ignore zeros due to black spot or saturation}
                      begin
                        Value := Value + value2;
                        Inc(counter);
                      end;
                    end;
                  end;
                end;
              if counter <> 0 then
                Value := Value / counter
              else
                Inc(range);
            until ((counter <> 0) or (range >= 10));{try till 10 pixels away}
          end;
        img_temp2[k, fitsX, fitsY] := Value;
      end;
  end;{k}

  img := img_temp2;{move pointer array}
  img_temp2 := nil;
end;


procedure Tstackmenu1.analyseflatsButton3Click(Sender: TObject);
begin
  analyse_listview(listview3, False {light}, True
    {full fits, include background and noise}, new_analyse_required3{refresh});
  new_analyse_required3 := False;{analyse done}

  {temporary fix for CustomDraw not called}
  {$ifdef darwin} {MacOS}
   stackmenu1.nr_total_bias1.caption:=inttostr(listview3.items.count);{update counting info}
  {$endif}
end;

procedure Tstackmenu1.analyseflatdarksButton1Click(Sender: TObject);
begin
  analyse_listview(listview4, False {light}, True
    {full fits, include background and noise}, False{refresh});

  {temporary fix for CustomDraw not called}
  {$ifdef darwin} {MacOS}
   stackmenu1.nr_total_flats1.caption:=inttostr(listview4.items.count);{update counting info}
  {$endif}

end;


procedure Tstackmenu1.changekeyword1Click(Sender: TObject);
var
  keyw, Value: string;
  lv: tlistview;
begin
  if Sender = changekeyword1 then
  begin
    lv := listview1;
    {from popup menu} new_analyse_required := True;
  end;
  if Sender = changekeyword2 then lv := listview2;{from popup menu}
  if Sender = changekeyword3 then
  begin
    lv := listview3;
    {from popup menu} new_analyse_required3 := True;{tab 3 flats}
  end;
  if Sender = changekeyword4 then lv := listview4;{from popup menu}
  if Sender = changekeyword6 then lv := listview6;{from popup menu}
  if Sender = changekeyword7 then lv := listview7;{from popup menu}
  if Sender = changekeyword8 then lv := listview8;{from popup menu}
  if Sender = changekeyword9 then lv := listview9;{from popup menu}

  keyw := InputBox('All selected files will be updated!! Hit cancel to abort. Type keyword:',
    '', '');
  if length(keyw) < 2 then exit;

  Value := InputBox('New value header keyword (Type DELETE to remove keyword):', '', '');
  if length(Value) <= 0 then exit;
  listview_update_keyword(lv, uppercase(keyw), Value);{update key word}
end;


procedure Tstackmenu1.dark_spot_filter1Click(Sender: TObject);
var
  fitsx, fitsy, i, j, k, x2, y2, radius, most_common, progress_value: integer;
  neg_noise_level: double;
  bck : tbackground;
begin
  if head.naxis <> 0 then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    get_background(0, img_loaded, True, False{do not calculate noise_level}, bck); {should be about 500 for mosaic since that is the target value}

    backup_img;  {store array in img_backup}
    {equalize background}
    radius := 50;

    for k := 0 to head.naxis3 - 1 do {do all colors}
    begin

      for fitsY := 0 to (head.Height - 1) {div 5} do
      begin
        if frac(fitsY / 100) = 0 then
        begin
          Application.ProcessMessages;
          if esc_pressed then
          begin
            Screen.Cursor := crDefault;
            { back to normal }  exit;
          end;
          progress_value := round(100 * (fitsY) / (((k + 1) / head.naxis3) * (head.Height)));
          progress_indicator(progress_value, '');{report progress}
        end;
        for fitsX := 0 to (head.Width - 1) {div 5} do
        begin
          if ((frac(fitsx / 10) = 0) and (frac(fitsY / 10) = 0)) then
          begin
            most_common := mode(img_backup[index_backup].img,false{ellipse shape}, k, fitsX - radius, fitsX + radius - 1, fitsY - radius, fitsY + radius - 1, 32000);
            neg_noise_level := get_negative_noise_level(img_backup[index_backup].img, k, fitsX - radius, fitsX + radius, fitsY - radius, fitsY + radius, most_common);
            {find the most common value of a local area and calculate negative noise level}
            for i := -radius to +radius - 1 do
              for j := -radius to +radius - 1 do
              begin
                x2 := fitsX + i;
                y2 := fitsY + j;
                if ((x2 >= 0) and (x2 < head.Width) and (y2 >= 0) and
                  (y2 < head.Height)) then
                  if img_loaded[k, x2, y2] < bck.backgr then {below global most common level}
                    if img_loaded[k, x2, y2] < most_common - neg_noise_level then
                      {local dark spot}
                      img_loaded[k, x2, y2] := most_common - neg_noise_level;
              end;
          end;{/3}
        end;
      end;
    end;{k color}
    plot_fits(mainwindow.image1, False, True);{plot real}
    progress_indicator(-100, '');{back to normal}
    Screen.Cursor := crDefault;
  end;
end;


function value_sub_pixel(k2: integer; x1, y1: double): double;
  {calculate image pixel value on subpixel level}
var
  x_trunc, y_trunc: integer;
  x_frac, y_frac: double;
begin
  x_trunc := trunc(x1);
  y_trunc := trunc(y1);
  if ((x_trunc < 0) or (x_trunc > (head.Width - 2)) or (y_trunc < 0) or
    (y_trunc > (head.Height - 2))) then
  begin
    Result := 0;
    exit;
  end;
  x_frac := frac(x1);
  y_frac := frac(y1);

  try
    Result := (img_loaded[k2, x_trunc, y_trunc]) * (1 - x_frac) * (1 - y_frac);
    {pixel left top, 1}
    Result := Result + (img_loaded[k2, x_trunc + 1, y_trunc]) * (x_frac) * (1 - y_frac);
    {pixel right top, 2}
    Result := Result + (img_loaded[k2, x_trunc, y_trunc + 1]) * (1 - x_frac) * (y_frac);
    {pixel left bottom, 3}
    Result := Result + (img_loaded[k2, x_trunc + 1, y_trunc + 1]) * (x_frac) * (y_frac);
    {pixel right bottom, 4}
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

procedure resize_img_loaded(ratio: double); {resize img_loaded in free ratio}
var
  img_temp2: image_array;
  FitsX, fitsY, k, w, h, w2, h2: integer;
  x, y: double;

begin
  w2 := round(ratio * head.Width);
  h2 := round(ratio * head.Height);

  repeat
    w := max(w2, round(head.Width / 2));  {reduce in steps of two maximum to preserve stars}
    h := max(h2, round(head.Height / 2));  {reduce in steps of two maximum to preserve stars}

    setlength(img_temp2, head.naxis3, w, h);
    ;
    for k := 0 to head.naxis3 - 1 do
      for fitsY := 0 to h - 1 do
        for fitsX := 0 to w - 1 do
        begin
          X := (fitsX * head.Width / w);
          Y := (fitsY * head.Height / h);
          img_temp2[k, fitsX, fitsY] := value_sub_pixel(k, x, y);
        end;
    img_loaded := img_temp2;
    head.Width := w;
    head.Height := h;
  until ((w <= w2) and (h <= h2)); {continue till required size is reeached}

  img_temp2 := nil;

  update_integer('NAXIS1  =', ' / length of x axis                               '
    , head.Width);
  update_integer('NAXIS2  =', ' / length of y axis                               '
    , head.Height);


  if head.cdelt1 <> 0 then
  begin
    head.cdelt1 := head.cdelt1 / ratio;
    update_float('CDELT1  =', ' / X pixel size (deg)                             ',false
      , head.cdelt1);
  end;
  if head.cdelt2 <> 0 then
  begin
    head.cdelt2 := head.cdelt2 / ratio;
    update_float('CDELT2  =', ' / Y pixel size (deg)                             ',false
      , head.cdelt2);
  end;

  if head.cd1_1 <> 0 then
  begin
    head.crpix1 := head.crpix1 * ratio;
    update_float('CRPIX1  =', ' / X of reference pixel                           ',false
      , head.crpix1);
    head.crpix2 := head.crpix2 * ratio;
    update_float('CRPIX2  =', ' / Y of reference pixel                           ',false
      , head.crpix2);
    head.cd1_1 := head.cd1_1 / ratio;
    head.cd1_2 := head.cd1_2 / ratio;
    head.cd2_1 := head.cd2_1 / ratio;
    head.cd2_2 := head.cd2_2 / ratio;
    update_float('CD1_1   =', ' / CD matrix to convert (x,y) to (Ra, Dec)        ',false
      , head.cd1_1);
    update_float('CD1_2   =', ' / CD matrix to convert (x,y) to (Ra, Dec)        ',false
      , head.cd1_2);
    update_float('CD2_1   =', ' / CD matrix to convert (x,y) to (Ra, Dec)        ',false
      , head.cd2_1);
    update_float('CD2_2   =', ' / CD matrix to convert (x,y) to (Ra, Dec)        ',false
      , head.cd2_2);
  end;

  head.XBINNING := head.XBINNING / ratio;
  head.YBINNING := head.YBINNING / ratio;
  update_float('XBINNING=', ' / Binning factor in width                         ',false
    , head.XBINNING);
  update_float('YBINNING=', ' / Binning factor in height                        ',false
    , head.YBINNING);

  if head.XPIXSZ <> 0 then
  begin
    head.XPIXSZ := head.XPIXSZ / ratio;
    head.YPIXSZ := head.YPIXSZ / ratio;
    update_float('XPIXSZ  =', ' / Pixel width in microns (after stretching)       ',false
      , head.XPIXSZ);
    update_float('YPIXSZ  =', ' / Pixel height in microns (after stretching)      ',false
      , head.YPIXSZ);
    update_float('PIXSIZE1=', ' / Pixel width in microns (after stretching)       ',false
      , head.XPIXSZ);
    update_float('PIXSIZE2=', ' / Pixel height in microns (after stretching)      ',false
      , head.YPIXSZ);
  end;
  add_text('HISTORY   ', 'Image resized with factor ' + floattostr6(ratio));
end;


procedure Tstackmenu1.free_resize_fits1Click(Sender: TObject);{free resize FITS image}
begin
  if head.naxis = 0 then exit;
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img;
  resize_img_loaded(width_UpDown1.position / head.Width {ratio});

  use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1, True, True);{plot}
  Screen.cursor := crDefault;
end;


procedure Tstackmenu1.copypath1Click(Sender: TObject);
var
  index, counter: integer;
begin
  with listview5 do
  begin
    index := 0;
    counter := Items.Count;
    while index < counter do
    begin
      if Items[index].Selected then
      begin
        Clipboard.AsText := extractfilepath(items[index].Caption);
      end;
      Inc(index); {go to next file}
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


function listview_find_selection(tl: tlistview): integer;{find the row selected}
var
  index, counter: integer;
begin
  Result := 0;
  index := 0;
  counter := tl.Items.Count;
  while index < counter do
  begin
    if tl.Items[index].Selected then
    begin
      Result := index;
      break;
    end;
    Inc(index); {go to next file}
  end;
end;


procedure scroll_up_down(lv:tlistview; up: boolean);
var
  c, step,watchdog: integer;
  checkf : boolean;
begin
  watchdog:=0;
  if lv.items.Count <= 1 then exit; {no files}

  if up=False then step := -1  else   step := 1;{forward/ backwards}

  c := listview_find_selection(lv); {find the row selected}

  repeat // find checked file
    Inc(c, step);
    if c >= lv.items.Count then c := 0;
    if c < 0 then c := lv.items.Count - 1;

    checkf:=lv.Items.item[c].Checked;
    if checkf then
    begin
      lv.Selected := nil;//remove any selection
      lv.ItemIndex := c;// mark where we are.
      lv.ItemIndex := c;
      {mark where we are. Important set in object inspector    lv.HideSelection := false; lv.Rowselect := true}
      lv.Items[c].MakeVisible(False);{scroll to selected item}
      filename2 := lv.items[c].Caption;
      mainwindow.Caption := filename2;

      {load image}
      if load_fits(filename2, True {light}, True, True {update memo}, 0, head,
        img_loaded) = False then
      begin
        memo2_message('repeat exit');

        Screen.Cursor:=crDefault;
        exit;
      end;
     use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
     plot_fits(mainwindow.image1, False {re_center}, True);

     {show alignment marker}
      if (stackmenu1.use_manual_alignment1.Checked) then
        show_shape_manual_alignment(c) {show the marker on the reference star}
      else
        mainwindow.shape_manual_alignment1.Visible := False;

    end; //checkf=true
    inc(watchdog);
  until ((checkf) or (esc_pressed) or (watchdog>300));
end;


procedure Tstackmenu1.listview1KeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);  // for all listviexX
begin
  if key = vk_delete then listview_removeselect(TListView(Sender));
  if key = vk_left then scroll_up_down(tlistview(sender), false);
  if key = vk_right then scroll_up_down(tlistview(sender), true );
end;


procedure Tstackmenu1.sd_factor_blink1Change(Sender: TObject);
begin
  esc_pressed := True; {need to remake img_backup contents for star supression}
end;


procedure Tstackmenu1.solve1Click(Sender: TObject);
begin
  if ((head.Width <> 100) or (head.Height <> 100)) then
    {is image loaded?,  assigned(img_loaded) doesn't work for jpegs}
    mainwindow.astrometric_solve_image1Click(nil)
  else
    memo2_message('Abort solve, no image in the viewer.');
end;


procedure Tstackmenu1.splitRGB1Click(Sender: TObject);
var
  fitsx, fitsY: integer;
  filename1, memo2_text: string;
begin
  if ((head.naxis = 0) or (head.naxis3 <> 3)) then
  begin
    memo2_message('Not a three colour image!');
    exit;
  end;

  memo2_text := mainwindow.Memo1.Text;{save fits header first FITS file}

  filename1 := ChangeFileExt(FileName2, '.fit');{make it lowercase fit also if FTS or FIT}

  setlength(img_buffer, 1, head.Width, head.Height);{create a new mono image}

  for fitsY := 0 to head.Height - 1 do
    for fitsX := 0 to head.Width - 1 do
      img_buffer[0, fitsX, fitsY] := img_loaded[0, fitsX, fitsY];
  filename2 := StringReplace(filename1, '.fit', '_red.fit', []);{give new file name }
  update_text('FILTER  =',copy(#39+'Red     '+#39+'                   ',1,21)+'/ Filter name');


  save_fits(img_buffer, filename2, -32, False);{fits header will be updated in save routine}

  for fitsY := 0 to head.Height - 1 do
    for fitsX := 0 to head.Width - 1 do
      img_buffer[0, fitsX, fitsY] := img_loaded[1, fitsX, fitsY];
  filename2 := StringReplace(filename1, '.fit', '_green.fit', []);{give new file name }
  update_text('FILTER  =',copy(#39+'Green   '+#39+'                   ',1,21)+'/ Filter name');

  save_fits(img_buffer, filename2, -32, False);{fits header will be updated in save routine}

  for fitsY := 0 to head.Height - 1 do
    for fitsX := 0 to head.Width - 1 do
      img_buffer[0, fitsX, fitsY] := img_loaded[2, fitsX, fitsY];
  filename2 := StringReplace(filename1, '.fit', '_blue.fit', []);{give new file name }
  update_text('FILTER  =',copy(#39+'Blue    '+#39+'                   ',1,21)+'/ Filter name');

  save_fits(img_buffer, filename2, -32, False);{fits header will be updated in save routine}

  img_buffer := nil;{release memory}

  {restore old situation}
  mainwindow.Memo1.Text := memo2_text;{restore fits header}
  filename2 := filename1;
end;


procedure Tstackmenu1.analysedarksButton2Click(Sender: TObject);
begin
  analyse_listview(listview2, False {light}, True {full fits, include background and SD},  False{refresh}); {img_loaded array and memo1 will not be modified}

  {temporary fix for CustomDraw not called}
  {$ifdef darwin} {MacOS}
   stackmenu1.nr_total_darks1.caption:=inttostr(listview2.items.count);{update counting info}
  {$endif}

end;


procedure Tstackmenu1.resize_factor1Change(Sender: TObject);
var
  factor: double;
begin
  factor := strtofloat2(resize_factor1.Text);
  Edit_width1.Text := IntToStr(round(head.Width * factor));
end;


procedure Tstackmenu1.Edit_width1Change(Sender: TObject);
begin
  new_height1.Caption := IntToStr(round(width_UpDown1.position * head.Height / head.Width));
end;


procedure Tstackmenu1.flux_aperture1change(Sender: TObject);
begin
  annulus_radius1.Enabled := flux_aperture1.ItemIndex <> 0;
  {disable annulus_radius1 if mode max flux}

  {recalibrate}
  if head.mzero <> 0 then
  begin
    memo2_message('Flux calibration cleared. For magnitude measurements in viewer recalibrate by ctrl-U. See viewer tool menu. ');
    head.mzero := 0;
  end;
end;


procedure Tstackmenu1.help_astrometric_solving1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#alignment_menu');
end;


procedure Tstackmenu1.listview1CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: boolean);
begin
  stackmenu1.nr_total1.Caption := IntToStr(ListView1.items.Count);{update counting info}
end;


procedure Tstackmenu1.listview1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
begin
  if stackmenu1.use_manual_alignment1.Checked then
  begin
    if length(Sender.Items.item[Item.Index].subitems.Strings[L_X]) > 1 then
      {manual position added, colour it}
      Sender.Canvas.Font.Color := clGreen
    else
      Sender.Canvas.Font.Color := clred;
  end
  else
  begin
    Sender.Canvas.Font.Color := clmenutext;
    {required for high contrast settings. Otherwise it is always black}
  end;
end;


procedure Tstackmenu1.listview2CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: boolean);
begin
  stackmenu1.nr_total_darks1.Caption := IntToStr(ListView2.items.Count);
  {update counting info}
end;

procedure Tstackmenu1.listview2CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
begin
  Sender.Canvas.Font.Color := clmenutext;
  {required for high contrast settings. Otherwise it is always black}
end;

procedure Tstackmenu1.listview3CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: boolean);
begin
  stackmenu1.nr_total_flats1.Caption := IntToStr(Sender.items.Count);{update counting info}
end;

procedure Tstackmenu1.listview3CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
begin
  Sender.Canvas.Font.Color := clmenutext;
  {required for high contrast settings. Otherwise it is always black}
end;

procedure Tstackmenu1.listview4CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: boolean);
begin
  stackmenu1.nr_total_bias1.Caption := IntToStr(Sender.items.Count);{update counting info}
end;


procedure Tstackmenu1.listview4CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
begin
  {$ifdef mswindows}
  {$else} {unix}
  {temporary fix for CustomDraw not called}
  if  Item.index=0 then  stackmenu1.nr_total_bias1.caption:=inttostr(sender.items.count);{update counting info}
  {$endif}
  Sender.Canvas.Font.Color := clmenutext;
  {required for high contrast settings. Otherwise it is always black}
end;

procedure Tstackmenu1.listview6CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: boolean);
begin
  stackmenu1.nr_total_blink1.Caption := IntToStr(Sender.items.Count);{update counting info}
end;

procedure Tstackmenu1.listview6CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
begin
  Sender.Canvas.Font.Color := clmenutext;
  {required for high contrast settings. Otherwise it is always black}
end;


procedure Tstackmenu1.test_pattern1Click(Sender: TObject);
begin
  if head.naxis <> 0 then
    mainwindow.demosaic_bayermatrix1Click(nil);{including back and wait cursor}
end;


procedure Tstackmenu1.blink_button1Click(Sender: TObject);
var
  Save_Cursor: TCursor;
  hfd_min: double;
  c, x_new, y_new, fitsX, fitsY, col, first_image, stepnr, nrrows,
  cycle, step, ps, bottom, top, left, w, h, max_stars: integer;
  reference_done, init{,solut}, astro_solved, store_annotated, success, res: boolean;
  st: string;
begin
  if listview6.items.Count <= 1 then exit; {no files}
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  save_settings2;{too many lost selected files . so first save settings}

  if listview6.Items.item[listview6.items.Count - 1].subitems.Strings[B_width] =
    '' {width} then
    stackmenu1.analyseblink1Click(nil);

  hfd_min := max(0.8 {two pixels}, strtofloat2(
    stackmenu1.min_star_size_stacking1.Caption){hfd});
  {to ignore hot pixels which are too small}
  max_stars := strtoint2(stackmenu1.max_stars1.Text);
  {maximum star to process, if so filter out brightest stars later}
  if max_stars = 0 then max_stars := 500;{0 is auto for solving. No auto for stacking}

  mainwindow.image1.Canvas.brush.Style := bsClear;
  mainwindow.image1.canvas.font.color := $00B0FF;{orange}

  esc_pressed := False;
  first_image := -1;
  cycle := 0;
  if Sender = blink_button_contB1 then step := -1
  else
    step := 1;{forward/ backwards}


  nrrows := listview6.items.Count;
  setlength(bsolutions, nrrows);
  {for the solutions in memory. bsolutions is destroyed in formdestroy}

  stepnr := 0;
  if ((Sender = blink_button1) or (solve_and_annotate1.Checked) or
    (Sender = write_video1) or (Sender = nil){export aligned}) then
    init := True {start at beginning for video}
  else
    init := False;{start at selection}
  reference_done := False;
  { check if reference image is loaded. Could be after first image if abort was given}
  repeat
    stepnr := stepnr + 1; {first step is nr 1}

    if init = False then c := listview_find_selection(listview6) {find the row selected}
    else
    begin
      if step > 0 then c := 0 {forward}
      else
        c := nrrows - 1;{backwards}

    end;
    init := True;
    repeat
      if ((esc_pressed = False) and (listview6.Items.item[c].Checked)) then
      begin
        if first_image = -1 then first_image := c;
        listview6.Selected := nil; {remove any selection}
        listview6.ItemIndex := c;
        {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview6.Items[c].MakeVisible(False);{scroll to selected item}

        filename2 := listview6.items[c].Caption;
        mainwindow.Caption := filename2;

        Application.ProcessMessages;
        if esc_pressed then break;
        {load image}
        if load_fits(filename2, True {light}, True, True {update memo},
          0, head, img_loaded) = False then
        begin
          esc_pressed := True;
          break;
        end;

        use_histogram(img_loaded, True {update}); {plot histogram, set sliders}

        if first_image = c then Inc(cycle);
        if cycle >= 2 then stackmenu1.update_annotation1.Checked := False;
        {reset any request to update fits header annotations}

        if solve_and_annotate1.Checked then
        begin
          astro_solved := False;{assume failure}
          if head.cd1_1 = 0 then {get astrometric solution}
          begin
            listview6.Selected := nil; {remove any selection}
            listview6.ItemIndex := c;
            {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
            listview6.Items[c].MakeVisible(False);{scroll to selected item}
            memo2_message(filename2 + ' Adding astrometric solution to files.');

            if solve_image(img_loaded, head, True  {get hist}) then
            begin{match between loaded image and star database}
              astro_solved := True;{saving will be done later}
              memo2_message(filename2 + ' astrometric solved.');
            end
            else
              memo2_message(filename2 + 'No astrometric solution found for this file.');
          end;

          if head.cd1_1 <> 0 then
          begin
            if ((annotated = False) or (stackmenu1.update_annotation1.Checked)) then
            begin
              plot_mpcorb(StrToInt(maxcount_asteroid), strtofloat2(
                maxmag_asteroid), True {add annotations});
              listview6.Items.item[c].subitems.Strings[B_annotated] := '✓';
            end;
            if ((astro_solved) or (stackmenu1.update_annotation1.Checked)) then
              {save solution}
            begin
              if fits_file_name(filename2) then
                success := savefits_update_header(filename2)
              else
                success := save_tiff16_secure(img_loaded, filename2);
              {guarantee no file is lost}
              if success = False then
              begin
                ShowMessage('Write error !!' + filename2);
                Screen.Cursor := crDefault;
                exit;
              end;
            end;
          end;
        end;{astrometric solve and annotate}

        {find align solution}
        if align_blink1.Checked then
        begin
          st := listview6.Items.item[c].subitems.Strings[B_solution];
          if st = '' then {no solution yet}
          begin
            if reference_done = False then {get reference}
            begin
              memo2_message(
                'Working on star alignment solutions. Blink frequency will increase after completion.');
              get_background(0, img_loaded, False {no histogram already done},
                True {unknown, calculate also datamax}, {out} bck);
              find_stars(img_loaded, hfd_min, max_stars, starlist1);
              {find stars and put them in a list}
              find_quads(starlist1, 0, quad_smallest, quad_star_distances1);
              {find quads for reference image}

              reset_solution_vectors(1);{no influence on the first image since reference}

              {store solutions in memory}
              bsolutions[c].solution_vectorX := solution_vectorX;
              bsolutions[c].solution_vectorY := solution_vectorY;
              listview6.Items.item[c].subitems.Strings[B_solution] := '✓ ' + IntToStr(c);
              {store location in listview for case list is sorted/modified}
              ListView6.Items.item[c].SubitemImages[B_solution] := icon_king;
              {mark as best quality image}
              reference_done := True;
            end
            else
            begin
              mainwindow.Caption := filename2 + ' Working on star solutions........';
              get_background(0, img_loaded, False {no histogram already done}, True {unknown, calculate also noise_level}, {out} bck);
              find_stars(img_loaded, hfd_min, max_stars, starlist2);
              {find stars and put them in a list}
              find_quads(starlist2, 0, quad_smallest, quad_star_distances2);
              {find star quads for new image}
              if find_offset_and_rotation(3, strtofloat2(stackmenu1.quad_tolerance1.Text))
              then {find difference between ref image and new image}
              begin
                bsolutions[c].solution_vectorX := solution_vectorX;
                bsolutions[c].solution_vectorY := solution_vectorY;
                listview6.Items.item[c].subitems.Strings[B_solution] := '✓ ' + IntToStr(c);
                {store location in listview for case list is sorted/modified}
                ListView6.Items.item[c].SubitemImages[B_solution] := -1;
                {remove any older icon_king}

                memo2_message(IntToStr(nr_references) + ' of ' +
                  IntToStr(nr_references2) + ' quads selected matching within ' +
                  stackmenu1.quad_tolerance1.Text + ' tolerance.' +
                  '  Solution x:=' + floattostr6(solution_vectorX[0]) + '*x+ ' + floattostr6(
                  solution_vectorX[1]) + '*y+ ' + floattostr6(solution_vectorX[2]) +
                  ',  y:=' + floattostr6(solution_vectorY[0]) + '*x+ ' + floattostr6(
                  solution_vectorY[1]) + '*y+ ' + floattostr6(solution_vectorY[2]));
              end
              else
              begin
                memo2_message(
                  'Not enough quad matches <3 or inconsistent solution, skipping this image.');
                reset_solution_vectors(1);{default for no solution}
              end;
            end;
          end
          {end find solution}
          else
          begin {reuse solution}
            ps := StrToInt(copy(st, 4, 10));
            solution_vectorX := bsolutions[ps].solution_vectorX; {restore solution}
            solution_vectorY := bsolutions[ps].solution_vectorY;
          end;

          if ((head.naxis3 = 1) and (mainwindow.preview_demosaic1.Checked)) then
          begin
            demosaic_advanced(img_loaded);{demosaic and set levels}
          end;

          setlength(img_temp, head.naxis3, 0, 0);
          {set to zero to clear old values (at the edges}
          setlength(img_temp, head.naxis3, head.Width, head.Height);{new size}


          for fitsY := 0 to head.Height - 1 do
            for fitsX := 0 to head.Width - 1 do
            begin
              x_new := round(solution_vectorX[0] * (fitsx) + solution_vectorX[1] *
                (fitsY) + solution_vectorX[2]); {correction x:=aX+bY+c}
              y_new := round(solution_vectorY[0] * (fitsx) + solution_vectorY[1] *
                (fitsY) + solution_vectorY[2]); {correction y:=aX+bY+c}

              if ((x_new >= 0) and (x_new <= head.Width - 1) and (y_new >= 0) and
                (y_new <= head.Height - 1)) then
                for col := 0 to head.naxis3 - 1 do {all colors}
                  img_temp[col, x_new, y_new] := img_loaded[col, fitsX, fitsY];

            end;

          img_loaded := img_temp;
        end{star align}
        else {un-aligned blink}
        begin
          {nothing to do}
        end;

        left := 0;
        bottom := 0;
        if ((Sender = write_video1) and (areax1 <> areaX2)) then {cropped video}
        begin {crop video, convert array coordinates to screen coordinates}
          if mainwindow.flip_horizontal1.Checked then left := head.Width - 1 - areaX2 {left}
          else
            left := areaX1;{left}
          if mainwindow.flip_vertical1.Checked then
            bottom := head.Height - 1 - areaY2 {bottom}
          else
            bottom := areaY1;{bottom}
        end;

        if timestamp1.Checked then
        begin
          if date_avg = '' then
            annotation_to_array('date_obs: ' + head.date_obs, False,
              65535, 1{size}, left + 1, bottom + 10, img_loaded)
          {head.date_obs to image array as font. Flicker free method}
          else
            annotation_to_array('date_avg: ' + date_avg, False, 65535,
              1{size}, left + 1, bottom + 10, img_loaded);{head.date_obs to image array as font}
        end;


        store_annotated := annotated;{store temporary annotated}
        annotated := False;{prevent annotations are plotted in plot_fits}
        plot_fits(mainwindow.image1, False {re_center}, True);
        annotated := store_annotated;{restore anotated value}
        if ((annotated) and (mainwindow.annotations_visible1.Checked)) then
          plot_annotations(True {use solution vectors!!!!}, False);
        {corrected annotations in case a part of the lights are flipped in the alignment routien}

        if Sender = write_video1 then {write video frame}
        begin
          w := head.Width;
          h := head.Height;
          top := 0;
          {left is already calculated}
          if areax1 <> areaX2 then {crop active, convert array screen coordinates}
          begin
            if mainwindow.flip_vertical1.Checked = False then
              top := head.Height - 1 - areaY2 {top}
            else
              top := areaY1;{top}
            w := areaX2 - areaX1 + 1;
            h := areaY2 - areaY1 + 1; {convert to screen coordinates}
          end;

          if video_index = 2 then
            res := write_avi_frame(left, top, w, h)
          else
            res := write_yuv4mpeg2_frame(head.naxis3 > 1, left, top, w, h);

          if res = False then
          begin
            memo2_message('Error writing video');
            ;
            c := 999999; {stop}
          end;
        end;
      end;
      Inc(c, step);
    until ((c >= nrrows) or (c < 0));

  until ((esc_pressed) or (Sender = blink_button1 {single run}) or
      (Sender = write_video1) or (Sender = nil){export aligned});

  img_temp := nil;{free memory}
  Screen.Cursor := crDefault;{back to normal }
end;


procedure Tstackmenu1.create_test_image_stars1Click(Sender: TObject);
var
  i, j, memo2, n, stepsize, stepsize2, starcounter, subsampling: integer;
  sigma, hole_radius, donut_radius, hfd_diameter, shiftX, shiftY, flux,
  flux_star, diam, intensity: double;
  gradient, diagn_star: boolean;
begin

  mainwindow.memo1.Visible := False;
  {stop visualising memo1 for speed. Will be activated in plot routine}
  mainwindow.memo1.Clear;{clear memo for new header}

  reset_fits_global_variables(True, head);

  nrbits := 16;
  extend_type := 0; {no extensions in the file, 1 is ascii_table, 2 bintable}

  head.Height := 1800;//1800;
  head.Width := head.Height * 3 div 2;{aspect ratio 3:2}

  Randomize; {initialise}

  head.datamin_org := 1000;{for case histogram is not called}
  head.datamax_org := 65535;
  bck.backgr := head.datamin_org;{for case histogram is not called}
  cwhite := head.datamax_org;

  gradient := stackmenu1.artificial_image_gradient1.Checked;

  sigma := strtofloat2(stackmenu1.hfd_simulation1.Text) / 2.5;
  {gaussian shaped star, sigma is HFD/2.5, in perfect world it should be /2.354 but sigma 1 will be measured with current alogorithm as 2.5}

  starcounter := 0;

  {star test image}
  head.naxis3 := 1; {head.naxis3 number of colors}
  filename2 := 'star_test_image.fit';
  for j := 0 to 10 do {create an header with fixed sequence}
    if (j <> 5) then {skip head.naxis3 for mono images}
      mainwindow.memo1.Lines.add(head1[j]); {add lines to empthy memo1}
  mainwindow.memo1.Lines.add(head1[27]); {add end}

  update_integer('BITPIX  =', ' / Bits per entry                                 '
    , nrbits);
  update_integer('NAXIS1  =', ' / length of x axis                               '
    , head.Width);
  update_integer('NAXIS2  =', ' / length of y axis                               '
    , head.Height);
  if head.naxis3 = 1 then  remove_key('NAXIS3  ', False{all});
  {remove key word in header. Some program don't like naxis3=1}
  update_integer('DATAMIN =', ' / Minimum data value                             ', 0);
  update_integer('DATAMAX =', ' / Maximum data value                             ',
    round(head.datamax_org));
  add_text('COMMENT 1', '  Written by Astrometric Stacking Program. www.hnsky.org');

  add_text('COMMENT A',
    '  Artificial image, background has value 1000 with sigma 100 Gaussian noise');
  add_text('COMMENT B', '  Top rows contain hotpixels with value 65535');
  add_text('COMMENT C', '  Rows below have Gaussian stars with a sigma of ' +
    floattostr6(sigma));
  add_text('COMMENT D', '  Which will be measured as HFD ' +
    stackmenu1.hfd_simulation1.Text);
  add_text('COMMENT E', '  Note that theoretical Gaussian stars with a sigma of 1 are');
  add_text('COMMENT F', '  equivalent to a HFD of 2.354 if subsampled enough.');
  add_text('COMMENT  ', ' ,Star_nr, X, Y, Flux                               ');


  setlength(img_loaded, head.naxis3, head.Width, head.Height);{set length of image array}

  for i := 0 to head.Height - 1 do
    for j := 0 to head.Width - 1 do
    begin
      if gradient = False then img_loaded[0, j, i] :=
          randg(1000, 100 {noise}){default background is 1000}
      else
        img_loaded[0, j, i] := -500 * sqrt(sqr((i - head.Height / 2) / head.Height) + sqr(
          (j - head.Width / 2) / head.Height)){circular gradient} +
          randg(1000, 100 {noise});{default background is 100}
    end;

  stepsize := round(sigma * 3);
  if stepsize < 8 then stepsize := 8;{minimum value}
  subsampling := 5;
  for i := stepsize to head.Height - 1 - stepsize do
    for j := stepsize to head.Width - 1 - stepsize do
    begin
      if ((frac(i / 100) = 0) and (frac(j / 100) = 0)) then
        {reduce star density if HFD increases}
      begin
        if i > head.Height - 300 then {hot pixels} img_loaded[0, j, i] := 65535 {hot pixel}
        else {create real stars}
        begin
          shiftX := -0.5 + random(1000) / 1000; {result between -0.5 and +0.5}
          shiftY := -0.5 + random(1000) / 1000; {result between -0.5 and +0.5}
          flux_star := 0;
          diagn_star := False;
          Inc(starcounter);
          intensity := (65000 / power(starcounter * 2700 * 1800 / (head.Height * head.Width), 0.85));
          {Intensity}

          //        if sigma*2.5<=5 then {gaussian stars}
          if donutstars1.Checked = False then {gaussian stars}
          begin
            stepsize2 := stepsize * subsampling;
            for memo2 := -stepsize2 to stepsize2 do for n := -stepsize2 to stepsize2 do
              begin
                //    flux:=(65000/power(starcounter,0.85)){Intensity}*(1/sqr(subsampling)* exp(-0.5/sqr(sigma)*(sqr(memo2/subsampling)+sqr(n/subsampling))));
                flux := Intensity * (1 / sqr(
                  subsampling * sigma){keep flux independent of HFD and subsmapling} *
                  exp(-0.5 * (sqr(memo2 / subsampling) + sqr(n / subsampling)) / sqr(sigma)));
                flux_star := flux_star + flux;
                img_loaded[0, j + round(shiftX + n / subsampling), i + round(shiftY + memo2 / subsampling)] :=
                  img_loaded[0, j + round(shiftX + n / subsampling), i + round(shiftY + memo2 / subsampling)] + flux;
                {gaussian shaped stars}
                if frac(starcounter / 20) = 0 then
                begin
                  img_loaded[0, 180 + starcounter + round(shiftX + n / subsampling),
                    130 + starcounter + round(shiftY + memo2 / subsampling)] :=
                    img_loaded[0, 180 + starcounter + round(shiftX + n / subsampling), 130 + starcounter +
                    round(shiftY + memo2 / subsampling)] + flux; {diagonal gaussian shaped stars}
                  diagn_star := True;
                end;
              end;
          end
          else
          begin  {donut stars}
            for memo2 := -stepsize to stepsize do for n := -stepsize to stepsize do
              begin
                hfd_diameter := sigma * 2.5;
                hole_radius := trunc(hfd_diameter / 3);{Half outer donut diameter}
                donut_radius := sqrt(2 * sqr(hfd_diameter / 2) - sqr(hole_radius));
                diam := sqrt(n * n + memo2 * memo2);
                if ((diam <= donut_radius) and (diam >= hole_radius {hole})) then
                begin
                  flux := 1000 * sqr(j / head.Width);
                  flux_star := flux_star + flux;
                  img_loaded[0, j + n, i + memo2] := img_loaded[0, j + n, i + memo2] + flux;{DONUT SHAPED stars}
                end;
              end;
          end;
          add_text('COMMENT  ', ' ,star' + IntToStr(starcounter) + ', ' +
            floattostr4(j + shiftX + 1) + ', ' + floattostr4(i + shiftY + 1) + ', ' + floattostr4(flux_star));
          {add the star coordinates to the header}
          if diagn_star then
            add_text('COMMENT  ', ' ,star' + IntToStr(starcounter) + 'D, ' +
              floattostr4(j + shiftX + 1 + 180 + starcounter) + ', ' + floattostr4(
              i + shiftY + 1 + 130 + starcounter) + ', ' + floattostr4(flux_star)); {diagonal stars}

        end;
      end;

    end;

  update_menu(True);{file loaded, update menu for fits. Set fits_file:=true}
  use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1, True, True);{plot test image}
end;



procedure Tstackmenu1.clear_blink_alignment1Click(Sender: TObject);
var
  c: integer;
begin
  for c := 0 to listview6.items.Count - 1 do
  begin
    bsolutions := nil;
    listview6.Items.item[c].subitems.Strings[B_solution] := '';{clear alignment marks}
  end;
end;


procedure Tstackmenu1.clear_blink_list1Click(Sender: TObject);
begin
  esc_pressed := True; {stop any running action}
  listview6.Clear;
end;


procedure Tstackmenu1.browse_dark1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select dark images';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist, ofHideReadOnly];
  opendialog1.filename := '';
  opendialog1.Filter := dialog_filter;
  if opendialog1.Execute then
  begin
    listview2.items.beginupdate;
    for i := 0 to OpenDialog1.Files.Count - 1 do {add}
    begin
      listview_add(listview2, OpenDialog1.Files[i], True, D_nr);
    end;
    listview2.items.endupdate;
  end;
end;


procedure Tstackmenu1.browse_inspector1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select images to add';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist, ofHideReadOnly];
  opendialog1.Filter := dialog_filter;
  //fits_file:=true;
  if opendialog1.Execute then
  begin
    listview8.items.beginupdate;
    for i := 0 to OpenDialog1.Files.Count - 1 do {add}
    begin
      listview_add(listview8, OpenDialog1.Files[i], True, L_nr);
    end;
    listview8.items.endupdate;
  end;
end;


procedure Tstackmenu1.browse_live_stacking1Click(Sender: TObject);
var
  live_stack_directory: string;
begin
  if SelectDirectory('Select directory containing the files to stack live',
    live_stacking_path1.Caption, live_stack_directory) then
  begin
    live_stacking_path1.Caption := live_stack_directory;{show path}
  end;
end;


procedure Tstackmenu1.analyse_objects_visibles1Click(Sender: TObject);
begin
  if ListView1.items.Count = 0 then
  begin
    memo2_message('Abort, No files in tab IMAGES.');
    exit;
  end;{no files in list, exit}
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  if listview1.selected = nil then
    ListView1.ItemIndex := 0;{show wich file is processed}
  filename2 := Listview1.selected.Caption;

  if load_fits(filename2, True {light}, True, True {update memo}, 0, head,
    img_loaded) = False then
  begin
    memo2_message('Abort, can' + #39 + 't load ' + filename2);
    Screen.Cursor := crDefault;    { back to normal }
    exit;
  end;
  if ((head.cd1_1 = 0) or (stackmenu1.ignore_header_solution1.Checked)) then
    {no solution or ignore solution}
  begin
    memo2_message('Solving file: ' + filename2);
    if create_internal_solution(img_loaded, head) = False then
    begin
      memo2_message('Abort, can' + #39 + 't solve ' + filename2);
      Screen.Cursor := crDefault;    { back to normal }
      exit;
    end;
  end;

  memo2_message('Annotating file: ' + filename2 + ' and extracting objects.');
  plot_mpcorb(StrToInt(maxcount_asteroid), strtofloat2(maxmag_asteroid), True
    {add annotations});
  if annotated then
  begin
    mainwindow.annotations_visible1.Checked := True;
    plot_annotations(False {use solution vectors}, True {fill combobox});
    stackmenu1.ephemeris_centering1.ItemIndex :=
      stackmenu1.ephemeris_centering1.items.Count - 1;{show first found in the list}
  end
  else
    memo2_message(
      'No object locations found in image. Modify limiting count and limiting magnitude in Asteroid & Comet annotation menu, CTRL+R');
  memo2_message('Ready. Select the object to align on.');
  Screen.Cursor := crDefault;    { back to normal }
end;


procedure Tstackmenu1.browse_photometry1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select images to add';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist, ofHideReadOnly];
  opendialog1.Filter := dialog_filter;
  //fits_file:=true;
  if opendialog1.Execute then
  begin
    listview7.items.beginupdate;
    for i := 0 to OpenDialog1.Files.Count - 1 do {add}
      listview_add(listview7, OpenDialog1.Files[i], True, P_nr);
    listview7.items.endupdate;
  end;
end;


procedure Tstackmenu1.aavso_button1Click(Sender: TObject);
begin
  if form_aavso1 = nil then
    form_aavso1 := Tform_aavso1.Create(self); {in project option not loaded automatic}
  form_aavso1.Show{Modal};
end;


procedure Tstackmenu1.clear_mount_list1Click(Sender: TObject);
begin
  esc_pressed := True; {stop any running action}
  listview9.Clear;
end;



procedure Tstackmenu1.clear_inspector_list1Click(Sender: TObject);
begin
  esc_pressed := True; {stop any running action}
  listview8.Clear;
end;

procedure Tstackmenu1.copy_to_blink1Click(Sender: TObject);
var
  index, counter: integer;
begin
  index := 0;
  listview6.Items.beginUpdate;
  counter := listview5.Items.Count;
  while index < counter do
  begin
    if listview5.Items[index].Selected then
    begin
      listview_add(listview6, listview5.items[index].Caption, True, L_nr);
    end;
    Inc(index); {go to next file}
  end;
  listview6.Items.endUpdate;
end;

procedure Tstackmenu1.copy_to_photometry1Click(Sender: TObject);
var
  index, counter: integer;
begin
  index := 0;
  listview7.Items.beginUpdate;
  counter := listview5.Items.Count;
  while index < counter do
  begin
    if listview5.Items[index].Selected then
    begin
      listview_add(listview7, listview5.items[index].Caption, True, L_nr);
    end;
    Inc(index); {go to next file}
  end;
  listview7.Items.endUpdate;
end;


procedure Tstackmenu1.curve_fitting1Click(Sender: TObject);
var
  memo2, a, b, posit, center, hfd: double;
  c, img_counter, i, fields: integer;
  array_hfd: array of tdouble2;
  center_str : string;
var {################# initialised variables #########################}
  len: integer = 200;
begin
  memo2_message('Finding the best focus position for each area using hyperbola curve fitting');
  memo2_message(
    'Positions are for an image with pixel position 1,1 at left bottom. Area 1,1 is bottom left, area 3,3 is top right. Center area is area 2,2');
  memo2_message('Offset in focuser steps relative to center area (area 2,2).');
  {do first or second time}
  analyse_listview(listview8, True{light}, True{full fits}, False{refresh});

  setlength(array_hfd, len);
  if Sender <> nil then fields := 11
  else
    fields := 1;
  for i := 1 to fields do {do all hfd areas}
  begin
    img_counter := 0;
    with listview8 do
      for c := 0 to listview8.items.Count - 1 do
      begin
        if Items.item[c].Checked then
        begin

          posit := strtofloat2(Items.item[c].subitems.Strings[I_focus_pos]);
          {inefficient but simple code to convert string back to float}
          if posit > 0 then
          begin
            hfd := strtofloat(Items.item[c].subitems.Strings[I_focus_pos + i]);
            if hfd < 15 then {valid data}
            begin
              array_hfd[img_counter, 1] := posit;
              array_hfd[img_counter, 2] := hfd;
              Inc(img_counter);
              if img_counter >= len then
              begin
                len := len + 200;
                setlength(array_hfd, len); {adapt size}
              end;
            end;
          end
          else if i = 1 then memo2_message(
              '█ █ █ █ █ █  Error, no focus position in fits header! █ █ █ █ █ █ ');
        end;
      end;
    if img_counter >= 4 then
    begin
      find_best_hyperbola_fit(array_hfd, img_counter, memo2, a, b);
      {input data[n,1]=position,data[n,2]=hfd, output: bestfocusposition=memo2, a, b of hyperbola}

      if i = 1 then  memo2_message(#9+'full image              ' + #9 +
          'Focus=' + floattostrf(memo2, ffFixed, 0, 0) + #9 + 'a=' + floattostrf(a, ffFixed, 0, 5) + #9 +
          ' b=' + floattostrf(b, ffFixed, 9, 5) + #9 + '            ' + #9 +
          #9 + 'error=' + floattostrf(lowest_error, ffFixed, 0, 5) + #9 + ' iteration cycles=' +
          floattostrf(iteration_cycles, ffFixed, 0, 0));
      if i = 2 then
      begin
        memo2_message(#9+'area 2,2 (center)       ' + #9 + 'Focus=' + floattostrf(memo2, ffFixed, 0, 0) +
          #9 + 'a=' + floattostrf(a, ffFixed, 0, 5) + #9 + ' b=' + floattostrf(b, ffFixed, 9, 5) + #9 +
          '           ' + #9 + #9 + 'error=' + floattostrf(lowest_error, ffFixed, 0, 5) +
          #9 + ' iteration cycles=' + floattostrf(iteration_cycles, ffFixed, 0, 0));
        center := memo2;
      end;
      if i = 3 then  memo2_message(#9+'outer ring              ' + #9 +
          'Focus=' + floattostrf(memo2, ffFixed, 0, 0) + #9 + 'a=' + floattostrf(a, ffFixed, 0, 5) + #9 +
          ' b=' + floattostrf(b, ffFixed, 9, 5) + #9 + 'offset=' + floattostrf(
          memo2 - center, ffFixed, 0, 0) + #9 + #9 + 'error=' + floattostrf(lowest_error, ffFixed, 5, 5) +
          #9 + ' iteration cycles=' + floattostrf(iteration_cycles, ffFixed, 0, 0));
      if i = 4 then  memo2_message(#9+'area 1,1 (Bottom Left)  ' + #9 +
          'Focus=' + floattostrf(memo2, ffFixed, 0, 0) + #9 + 'a=' + floattostrf(a, ffFixed, 0, 5) + #9 +
          ' b=' + floattostrf(b, ffFixed, 9, 5) + #9 + 'offset=' + floattostrf(
          memo2 - center, ffFixed, 0, 0) + #9 + #9 + 'error=' + floattostrf(lowest_error, ffFixed, 5, 5) +
          #9 + ' iteration cycles=' + floattostrf(iteration_cycles, ffFixed, 0, 0));
      if i = 5 then  memo2_message(#9+'area 2,1 (Bottom Middle)' + #9 +
          'Focus=' + floattostrf(memo2, ffFixed, 0, 0) + #9 + 'a=' + floattostrf(a, ffFixed, 0, 5) + #9 +
          ' b=' + floattostrf(b, ffFixed, 9, 5) + #9 + 'offset=' + floattostrf(
          memo2 - center, ffFixed, 0, 0) + #9 + #9 + 'error=' + floattostrf(lowest_error, ffFixed, 5, 5) +
          #9 + ' iteration cycles=' + floattostrf(iteration_cycles, ffFixed, 0, 0));
      if i = 6 then  memo2_message(#9+'area 3,1 (Bottom Right) ' + #9 +
          'Focus=' + floattostrf(memo2, ffFixed, 0, 0) + #9 + 'a=' + floattostrf(a, ffFixed, 0, 5) + #9 +
          ' b=' + floattostrf(b, ffFixed, 9, 5) + #9 + 'offset=' + floattostrf(
          memo2 - center, ffFixed, 0, 0) + #9 + #9 + 'error=' + floattostrf(lowest_error, ffFixed, 5, 5) +
          #9 + ' iteration cycles=' + floattostrf(iteration_cycles, ffFixed, 0, 0));
      if i = 7 then  memo2_message(#9+'area 1,2 (Middle left)  ' + #9 +
          'Focus=' + floattostrf(memo2, ffFixed, 0, 0) + #9 + 'a=' + floattostrf(a, ffFixed, 0, 5) + #9 +
          ' b=' + floattostrf(b, ffFixed, 9, 5) + #9 + 'offset=' + floattostrf(
          memo2 - center, ffFixed, 0, 0) + #9 + #9 + 'error=' + floattostrf(lowest_error, ffFixed, 5, 5) +
          #9 + ' iteration cycles=' + floattostrf(iteration_cycles, ffFixed, 0, 0));
      if i = 8 then  memo2_message(#9+'area 3,2 (Middle Right) ' + #9 +
          'Focus=' + floattostrf(memo2, ffFixed, 0, 0) + #9 + 'a=' + floattostrf(a, ffFixed, 0, 5) + #9 +
          ' b=' + floattostrf(b, ffFixed, 9, 5) + #9 + 'offset=' + floattostrf(
          memo2 - center, ffFixed, 0, 0) + #9 + #9 + 'error=' + floattostrf(lowest_error, ffFixed, 5, 5) +
          #9 + ' iteration cycles=' + floattostrf(iteration_cycles, ffFixed, 0, 0));
      if i = 9 then  memo2_message(#9+'area 1,3 (Top left)     ' + #9 +
          'Focus=' + floattostrf(memo2, ffFixed, 0, 0) + #9 + 'a=' + floattostrf(a, ffFixed, 0, 5) + #9 +
          ' b=' + floattostrf(b, ffFixed, 9, 5) + #9 + 'offset=' + floattostrf(
          memo2 - center, ffFixed, 0, 0) + #9 + #9 + 'error=' + floattostrf(lowest_error, ffFixed, 5, 5) +
          #9 + ' iteration cycles=' + floattostrf(iteration_cycles, ffFixed, 0, 0));
      if i = 10 then  memo2_message(#9+'area 2,3 (Top Middle)   ' + #9 +
          'Focus=' + floattostrf(memo2, ffFixed, 0, 0) + #9 + 'a=' + floattostrf(a, ffFixed, 0, 5) + #9 +
          ' b=' + floattostrf(b, ffFixed, 9, 5) + #9 + 'offset=' + floattostrf(
          memo2 - center, ffFixed, 0, 0) + #9 + #9 + 'error=' + floattostrf(lowest_error, ffFixed, 5, 5) +
          #9 + ' iteration cycles=' + floattostrf(iteration_cycles, ffFixed, 0, 0));
      if i = 11 then  memo2_message(#9+'area 3,3 (Top Right)    ' + #9 +
          'Focus=' + floattostrf(memo2, ffFixed, 0, 0) + #9 + 'a=' + floattostrf(a, ffFixed, 0, 5) + #9 +
          ' b=' + floattostrf(b, ffFixed, 9, 5) + #9 + 'offset=' + floattostrf(
          memo2 - center, ffFixed, 0, 0) + #9 + #9 + 'error=' + floattostrf(lowest_error, ffFixed, 5, 5) +
          #9 + ' iteration cycles=' + floattostrf(iteration_cycles, ffFixed, 0, 0));
    end
    else
    if i = 1 then memo2_message(
        '█ █ █ █ █ █  Error, four or more images are required at different focus positions! █ █ █ █ █ █ ');
  end;
end;


procedure Tstackmenu1.ephemeris_centering1Change(Sender: TObject);
begin
  new_analyse_required := True;{force a new analyse for new x, y position asteroids}
end;


procedure Tstackmenu1.focallength1Exit(Sender: TObject);
begin
  if Sender = focallength1 then {manual entered}
    focallen := strtofloat2(stackmenu1.focallength1.Text);
  {manual entered focal length, update focallen}

  if Sender = pixelsize1 then {manual entered}
    head.xpixsz := strtofloat2(stackmenu1.pixelsize1.Text);
  {manual entered micrometer, update xpixsz}

  if ((head.cd1_1 <> 0) and (head.cdelt2 <> 0)) then {solved image}
  begin
    calc_scale := 3600 * abs(head.cdelt2);
    if Sender = focallength1 then
      {calculate pixelsize from head.cdelt2 and manual entered focallen}
    begin
      head.xpixsz := calc_scale * focallen / ((180 * 3600 / 1000) / pi);
      stackmenu1.pixelsize1.Text := floattostrf(head.xpixsz, ffgeneral, 4, 4);
    end
    else
    begin  {calculate focal length from head.cdelt2 and pixelsize1}
      focallen := (head.xpixsz / calc_scale) * (180 * 3600 / 1000) / pi; {arcsec per pixel}
      stackmenu1.focallength1.Text := floattostrf(focallen, ffgeneral, 4, 4);
    end;
  end
  else
  begin {not a solved image}
    if focallen <> 0 then calc_scale :=
        (head.xpixsz / focallen) * (180 * 3600 / 1000) / pi {arcsec per pixel}
    else
      calc_scale := 0;
  end;

  if calc_scale <> 0 then calculated_scale1.Caption :=
      floattostrf(calc_scale, ffgeneral, 3, 3) + ' "/pixel'
  else
    calculated_scale1.Caption := '- - -';

  if head.xpixsz <> 0 then calculated_sensor_size1.Caption :=
      floattostrf(head.Width * head.xpixsz * 1E-3, fffixed, 3, 1) + ' x' + floattostrf(
      head.Height * head.xpixsz * 1E-3, fffixed, 3, 1) + ' mm'
  else
    calculated_sensor_size1.Caption := '- - -';

  if ((head.xpixsz <> 0) and (focallen <> 0)) then
    scale_calc1.Caption := floattostrf((head.Width * head.xpixsz / focallen) *
      (180 / 1000) / pi, ffgeneral, 3, 3) + '° x ' + floattostrf(
      (head.Height * head.xpixsz / focallen) * (180 / 1000) / pi, ffgeneral, 3, 3) + '°'
  else
    scale_calc1.Caption := '- - -';
end;


procedure Tstackmenu1.go_step_two1Click(Sender: TObject);
begin
  load_image(mainwindow.image1.Visible = False, True {plot});
  update_equalise_background_step(2); {go to step 3}
end;


procedure Tstackmenu1.luminance_filter1exit(Sender: TObject);
var
  err, mess, mess2: boolean;
  red1, red2, green1, green2, blue1, blue2, lum1, lum2: string;
begin
  new_analyse_required := True;
  new_analyse_required3 := True;{tab 3 flats}
  err := False;
  mess := False;
  mess2 := False;
  red1 := trim(red_filter1.Text); {remove spaces before and after}
  red2 := trim(red_filter2.Text);
  green1 := trim(green_filter1.Text);
  green2 := trim(green_filter2.Text);
  blue1 := trim(blue_filter1.Text);
  blue2 := trim(blue_filter2.Text);
  lum1 := trim(luminance_filter1.Text);
  lum2 := trim(luminance_filter2.Text);


  {remove duplication because they will be ignored later. Follow execution of stacking routine (for i:=0 to 4) so red, green, blue luminance}
  if AnsiCompareText(green1, red1) = 0 then
  begin
    err := True;
    green1 := '';
  end;
  if AnsiCompareText(green1, red2) = 0 then
  begin
    err := True;
    green1 := '';
  end;

  if AnsiCompareText(green2, red1) = 0 then
  begin
    err := True;
    green2 := '';
  end;
  if AnsiCompareText(green2, red2) = 0 then
  begin
    err := True;
    green2 := '';
  end;

  if AnsiCompareText(blue1, red1) = 0 then
  begin
    err := True;
    blue1 := '';
  end;
  if AnsiCompareText(blue1, red2) = 0 then
  begin
    err := True;
    blue1 := '';
  end;

  if AnsiCompareText(blue2, red1) = 0 then
  begin
    err := True;
    blue2 := '';
  end;
  if AnsiCompareText(blue2, red2) = 0 then
  begin
    err := True;
    blue2 := '';
  end;

  if AnsiCompareText(blue1, green1) = 0 then
  begin
    err := True;
    blue1 := '';
  end;
  if AnsiCompareText(blue1, green2) = 0 then
  begin
    err := True;
    blue1 := '';
  end;

  if AnsiCompareText(blue2, green1) = 0 then
  begin
    err := True;
    blue2 := '';
  end;
  if AnsiCompareText(blue2, green2) = 0 then
  begin
    err := True;
    blue2 := '';
  end;


  if AnsiCompareText(lum1, red1) = 0 then
  begin
    mess := True;
  end;
  if AnsiCompareText(lum1, red2) = 0 then
  begin
    mess := True;
  end;

  if AnsiCompareText(lum2, red1) = 0 then
  begin
    mess2 := True;
  end;
  if AnsiCompareText(lum2, red2) = 0 then
  begin
    mess2 := True;
  end;

  if AnsiCompareText(lum1, green1) = 0 then
  begin
    mess := True;
  end;
  if AnsiCompareText(lum1, green2) = 0 then
  begin
    mess := True;
  end;

  if AnsiCompareText(lum2, green1) = 0 then
  begin
    mess2 := True;
  end;
  if AnsiCompareText(lum2, green2) = 0 then
  begin
    mess2 := True;
  end;

  if AnsiCompareText(lum1, blue1) = 0 then
  begin
    mess := True;
  end;
  if AnsiCompareText(lum1, blue2) = 0 then
  begin
    mess := True;
  end;

  if AnsiCompareText(lum2, blue1) = 0 then
  begin
    mess2 := True;
  end;
  if AnsiCompareText(lum2, blue2) = 0 then
  begin
    mess2 := True;
  end;

  red_filter1.Text := red1;
  red_filter2.Text := red2;
  green_filter1.Text := green1;
  green_filter2.Text := green2;
  blue_filter1.Text := blue1;
  blue_filter2.Text := blue2;
  luminance_filter1.Text := lum1;
  luminance_filter2.Text := lum2;

  if err then
    memo2_message('Filter name can be used only once  for RGB! Use matrix to use a filter more than once.');

  if mess then luminance_filter1.font.Style := [fsbold]
  else
    luminance_filter1.font.Style := [];
  if mess2 then luminance_filter2.font.Style := [fsbold]
  else
    luminance_filter2.font.Style := [];
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
  r, g, b, h, s, v: single;
  colour: tcolor;
  saturation: double;
begin
  colour := stackmenu1.colourShape2.brush.color;
  RGB2HSV(getRvalue(colour), getGvalue(colour), getBvalue(colour), h, s, v);

  saturation := stackmenu1.new_saturation1.position / 100;
  v:=v * stackmenu1.new_colour_luminance1.position/100;// adjust luminance
  HSV2RGB(h, s * saturation {s 0..1}, v {v 0..1}, r, g, b);
  {HSV to RGB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
  stackmenu1.colourshape3.brush.color := rgb(trunc(r), trunc(g), trunc(b));
end;



procedure sample(sx, sy: integer);{sampe local colour and fill shape with colour}
var
  halfboxsize, i, j, counter, fx, fy, col_r, col_g, col_b: integer;
  r, g, b, h, s, v, colrr, colgg, colbb, luminance, luminance_stretched, factor,
  largest: single;
  dummy1, radiobutton2: boolean;
begin
  dummy1 := stackmenu1.HueRadioButton1.Checked;
  radiobutton2 := stackmenu1.HueRadioButton2.Checked;

  if ((dummy1 = False) and (radiobutton2 = False)) then exit;
  halfboxsize := max(0, (stackmenu1.sample_size1.ItemIndex));
  counter := 0;
  colrr := 0;
  colgg := 0;
  colbb := 0;
  for i := -halfboxsize to halfboxsize do
    for j := -halfboxsize to halfboxsize do {average local colour}
    begin
      fx := i + sX;
      fy := j + sY;
      if ((fx >= 0) and (fx < head.Width) and (fy >= 0) and (fy < head.Height)) then
      begin
        Inc(counter);
        colrr := colrr + img_loaded[0, sX, sY];
        colgg := colgg + img_loaded[1, sX, sY];
        colbb := colbb + img_loaded[2, sX, sY];
      end;
    end;
  if counter = 0 then exit;
  colrr := ((colrr / counter) - bck.backgr) / (cwhite - bck.backgr);{scale to 0..1}
  colgg := ((colgg / counter) - bck.backgr) / (cwhite - bck.backgr);{scale to 0..1}
  colbb := ((colbb / counter) - bck.backgr) / (cwhite - bck.backgr);{scale to 0..1}

  if colrr <= 0.00000000001 then colrr := 0.00000000001;
  if colgg <= 0.00000000001 then colgg := 0.00000000001;
  if colbb <= 0.00000000001 then colbb := 0.00000000001;

  {find brightest colour and resize all if above 1}
  largest := colrr;
  if colgg > largest then largest := colgg;
  if colbb > largest then largest := colbb;
  if largest > 1 then {clamp to 1 but preserve colour, so ratio r,g,b}
  begin
    colrr := colrr / largest;
    colgg := colgg / largest;
    colbb := colbb / largest;
    largest := 1;
  end;

  if stretch_on then {Stretch luminance only. Keep RGB ratio !!}
  begin
    luminance := (colrr + colgg + colbb) / 3;{luminance in range 0..1}
    luminance_stretched := stretch_c[trunc(32768 * luminance)];
    factor := luminance_stretched / luminance;
    if factor * largest > 1 then factor := 1 / largest; {clamp again, could be higher then 1}
    col_r := round(colrr * factor * 255);{stretch only luminance but keep rgb ratio!}
    col_g := round(colgg * factor * 255);{stretch only luminance but keep rgb ratio!}
    col_b := round(colbb * factor * 255);{stretch only luminance but keep rgb ratio!}
  end
  else
  begin
    col_r := round(255 * colrr);
    col_g := round(255 * colgg);
    col_b := round(255 * colbb);
  end;

  RGB2HSV(col_r, col_g, col_b, h, s, v);
  {RGB to HSVB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}

  if dummy1 then
  begin
    HSV2RGB(h, s {s 0..1}, v {v 0..1}, r, g, b);
    {HSV to RGB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
    stackmenu1.colourshape1.brush.color := rgb(trunc(r), trunc(g), trunc(b));
    stackmenu1.hue_fuzziness1Change(nil);
  end
  else
  if RadioButton2 then
  begin
    HSV2RGB(h, s {s 0..1}, v {v 0..1}, r, g, b);
    {HSV to RGB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
    stackmenu1.colourshape2.brush.color := rgb(trunc(r), trunc(g), trunc(b));
    update_replacement_colour;
  end;

end;

procedure Tstackmenu1.hue_fuzziness1Change(Sender: TObject);
var
  colour: tcolor;
  oldhue, s, v, dhue: single;
begin
  dhue := hue_fuzziness1.position;
  colour := colourShape1.brush.color;
  RGB2HSV(getRvalue(colour), getGvalue(colour), getBvalue(colour), oldhue, s, v);

  hue1 := oldhue - dhue / 2;
  if hue1 > 360 then hue1 := hue1 - 360;
  if hue1 < 0 then hue1 := hue1 + 360;

  hue2 := oldhue + dhue / 2;
  if hue2 > 360 then hue2 := hue2 - 360;
  if hue2 < 0 then hue2 := hue2 + 360;

  stackmenu1.rainbow_panel1.refresh;
  {plot colour disk in on paint event. Onpaint is required for MacOS}
end;


procedure Tstackmenu1.listview8CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
begin
  stackmenu1.nr_total_inspector1.Caption := IntToStr(Sender.items.Count);
  {update counting info}
end;

procedure Tstackmenu1.listview8CustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: integer; State: TCustomDrawState; var DefaultDraw: boolean);
begin
  if Sender.Items.item[Item.Index].subitems.Strings[I_nr_stars] = '❌' then
    Sender.Canvas.Font.Color := clred
  else
    Sender.Canvas.Font.Color := clmenutext;
  {required for high contrast settings. Otherwise it is always black}

  {$ifdef mswindows}
   {$else} {unix}
   {temporary fix for CustomDraw not called}
   if  Item.index=0 then  stackmenu1.nr_total_inspector1.caption:=inttostr(sender.items.count);{update counting info}
   {$endif}
end;


procedure Tstackmenu1.live_stacking1Click(Sender: TObject);
begin
  save_settings2;{too many lost selected files . so first save settings}
  esc_pressed := False;
  live_stacking_pause1.font.style := [];
  live_stacking1.font.style := [fsbold, fsunderline];
  Application.ProcessMessages; {process font changes}
  if pause_pressed = False then {restart}
    stack_live(round(strtofloat2(stackmenu1.oversize1.Text)),
      live_stacking_path1.Caption){stack live average}
  else
    pause_pressed := False;
end;


{$ifdef mswindows}
procedure CopyFilesToClipboard(FileList: string);
{See https://forum.lazarus.freepascal.org/index.php?topic=18637.0}
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
    SetClipboardData(CF_HDROP, hGlobal);
    CloseClipboard;
  end;
end;

{$else} {unix}
{$endif}


procedure Tstackmenu1.copy_files_to_clipboard1Click(Sender: TObject);
var
  index: integer;
  info: string;
begin
 {$ifdef mswindows}
  {get file name selected}
  info := '';
  for index := 0 to listview5.items.Count - 1 do
  begin
    if listview5.Items[index].Selected then
    begin
      info := info + listview5.items[index].Caption + #0; {Separate the files with a #0.}
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
  refresh_solutions, success: boolean;
  thefile, filename1: string;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  esc_pressed := False;
  refresh_solutions := mount_ignore_solutions1.Checked; {refresh astrometric solutions}

  {solve lights first to allow flux to magnitude calibration}
  with stackmenu1 do
    for c := 0 to listview9.items.Count - 1 do {check for astrometric solutions}
    begin
      if ((esc_pressed = False) and (listview9.Items.item[c].Checked) and
        (listview9.Items.item[c].subitems.Strings[M_ra] = '')) then
      begin
        filename1 := listview9.items[c].Caption;
        mainwindow.Caption := filename1;

        Application.ProcessMessages;

        {load image}
        if ((esc_pressed) or (load_fits(filename1, True {light}, True,
          True {update memo}, 0, head_2, img_temp) = False)) then
        begin
          Screen.Cursor := crDefault;{back to normal }
          exit;
        end;
        if ((head.cd1_1 = 0) or (refresh_solutions)) then
        begin
          listview9.Selected := nil; {remove any selection}
          listview9.ItemIndex := c;
          {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
          listview9.Items[c].MakeVisible(False);{scroll to selected item}
          memo2_message(filename1 + ' Adding astrometric solution to file.');
          Application.ProcessMessages;

          if solve_image(img_temp, head_2, True  {get hist}) then
          begin{match between loaded image and star database}
            if mount_write_wcs1.Checked then
            begin
              thefile := ChangeFileExt(filename1, '.wcs');{change file extension to .wcs file}
              write_astronomy_wcs(thefile);
              listview9.items[c].Caption := thefile;
            end
            else
            begin
              if fits_file_name(filename1) then
                success := savefits_update_header(filename1)
              else
                success := save_tiff16_secure(img_temp, filename1);{guarantee no file is lost}
              if success = False then
              begin
                ShowMessage('Write error !!' + filename1);
                Screen.Cursor := crDefault;
                exit;
              end;
            end;
          end
          else
          begin
            listview9.Items[c].Checked := False;
            listview9.Items.item[c].subitems.Strings[M_ra] := '?';
            listview9.Items.item[c].subitems.Strings[M_dec] := '?';
            memo2_message(filename1 + 'No astrometric solution found for this file!!');
          end;
        end;
      end;
    end;

  Screen.Cursor := crDefault;{back to normal }

  update_menu(False);
  //do not allow to save fits. img_load is still valid but memo1 is cleared. Could be recovered but is not done
  stackmenu1.mount_analyse1Click(nil);
  {update. Since it are WCS files with naxis,2 then image1 will be cleared in load_fits}
end;

procedure Tstackmenu1.new_colour_luminance1Change(Sender: TObject);
begin
  update_replacement_colour;
end;


procedure Tstackmenu1.new_saturation1Change(Sender: TObject);
begin
  update_replacement_colour;
end;

procedure Tstackmenu1.check_pattern_filter1Change(Sender: TObject);
begin
  if check_pattern_filter1.Checked then calibrate_prior_solving1.Checked := False;
end;


procedure Tstackmenu1.pagecontrol1Change(Sender: TObject);
var
  theindex: integer;
begin
  theindex := stackmenu1.pagecontrol1.tabindex;
  mainwindow.shape_alignment_marker1.Visible := (theindex = 8);
  {hide shape if stacked image is plotted}
  mainwindow.shape_alignment_marker2.Visible := (theindex = 8);
  {hide shape if stacked image is plotted}
  mainwindow.shape_alignment_marker3.Visible := (theindex = 8);
  {hide shape if stacked image is plotted}
  mainwindow.labelVar1.Visible := (theindex = 8);
  mainwindow.labelCheck1.Visible := (theindex = 8);
  mainwindow.labelThree1.Visible := (theindex = 8);
  stack_button1.Enabled := ((theindex <= 6) or (theindex >= 13));

  if theindex=9 then
    stackmenu1.Memo2.Font.name :='Courier New'
  else
    stackmenu1.Memo2.Font.name :='default'

end;


var
  FLastHintTabIndex: integer;

procedure Tstackmenu1.pagecontrol1MouseMove(Sender: TObject;
  {Show hints of each tab when mouse hovers above it}
  Shift: TShiftState; X, Y: integer);
var
  TabIndex: integer;
begin
  TabIndex := PageControl1.IndexOfTabAt(X, Y);
  if FLastHintTabIndex <> TabIndex then
    Application.CancelHint;
  if TabIndex <> -1 then
    PageControl1.Hint := PageControl1.Pages[TabIndex].Hint;
  FLastHintTabIndex := TabIndex;
end;

procedure Tstackmenu1.photom_calibrate1Click(Sender: TObject);
var
  index, counter, oldindex, position, i: integer;
  ListItem: TListItem;
begin
  position := -1;
  index := 0;
  listview1.Items.beginUpdate;
  listview1.Clear;//lights

  counter := listview7.Items.Count;
  while index < counter do
  begin
    if listview7.Items[index].Selected then
    begin
      if position < 0 then position := index;//store first position
      listview_add(listview1, listview7.items[index].Caption, True, L_nr);
    end;
    Inc(index); {go to next file}
  end;

  listview1.Items.endUpdate;

  oldindex := stack_method1.ItemIndex;
  stack_method1.ItemIndex := 5; //calibration only, no de-mosaic
  stack_button1Click(Sender);

  // move calibrated files back form results as *_cal.fits
  listview_removeselect(listview7);
  listview7.Items.BeginUpdate;
  index := listview1.Items.Count - 1;
  while index >= 0 do
  begin
    with listview7 do
    begin
      ListItem := Items.insert(position);
      //             ListView1.Items.item[c].subitems.Strings[L_calibration]
      ListItem.Caption := listview1.items[index].Caption;
      ListItem.Checked := True;
      for i := 1 to P_nr do
        ListItem.SubItems.Add(''); // add the other columns
      ListItem.subitems.Strings[P_calibration] := ListView1.Items.item[index].subitems.Strings[L_calibration];//copy calibration status
      Dec(index); {go to next file}
    end;
  end;
  listview7.Items.EndUpdate;

  listview1.Clear;

  stack_method1.ItemIndex := oldindex;//return old setting
  save_settings2;

  analyse_listview(listview7, True {light}, False {full fits}, True{refresh});
  {refresh list}
end;

procedure Tstackmenu1.photom_green1Click(Sender: TObject);
var
  c: integer;
  fn, ff: string;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  esc_pressed := False;

  if listview7.items.Count > 0 then
  begin
    for c := 0 to listview7.items.Count - 1 do
      if listview7.Items[c].Selected then
      begin
        {scroll}
        //       listview7.Selected :=nil; {remove any selection}
        listview7.ItemIndex := c;
        {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview7.Items[c].MakeVisible(False);{scroll to selected item}

        application.ProcessMessages;
        if esc_pressed then
        begin
          Screen.Cursor := crDefault;
          exit;
        end;

        ff := ListView7.items[c].Caption;
        if fits_tiff_file_name(ff) = False then
        begin
          memo2_message('█ █ █ █ █ █ Can' + #39 +
            't extract. First analyse file list to convert to FITS !! █ █ █ █ █ █');
          beep;
          exit;
        end;


        if sender=photom_blue1 then
          fn := extract_raw_colour_to_file(ff, 'TB', 1, 1) {extract green red or blue channel}
        else
        if sender=photom_red1 then
          fn := extract_raw_colour_to_file(ff, 'TR', 1, 1) {extract green red or blue channel}
        else
          fn := extract_raw_colour_to_file(ff, 'TG', 1, 1); {extract green red or blue channel}

        if fn <> '' then
        begin
          ListView7.items[c].Caption := fn;
        end;

      end;
  end;
  analyse_listview(listview7, True {light}, False {full fits}, True{refresh});
  {refresh list}
  Screen.Cursor := crDefault;  { Always restore to normal }

end;

procedure Tstackmenu1.photom_stack1Click(Sender: TObject);
var
  index, counter, oldindex, position, i: integer;
  ListItem: TListItem;
begin

  position := -1;
  index := 0;
  listview1.Items.beginUpdate;
  listview1.Clear;
  counter := listview7.Items.Count;
  while index < counter do
  begin
    if listview7.Items[index].Selected then
    begin
      if position < 0 then position := index;//store first position
      listview_add(listview1, listview7.items[index].Caption, True, L_nr);
      // add to tab light
    end;
    Inc(index); {go to next file}
  end;
  listview1.Items.endUpdate;

  analyse_tab_lights(False {full});//update also process_as_osc
  if process_as_osc > 0 then
  begin
    memo2_message(
      '█ █ █ █ █ █ Abort !! For photometry you can not stack OSC images. First extract the green channel. █ █ █ █ █ █');
    beep;
    exit;
  end;

  oldindex := stack_method1.ItemIndex;
  stack_method1.ItemIndex := 0; //average

  stack_button1Click(Sender);// stack the files in tab lights

  // move calibrated files back
  listview_removeselect(listview7);
  listview7.Items.BeginUpdate;
  with listview7 do
  begin
    ListItem := Items.insert(position);
    ListItem.Caption := filename2; // contains the stack file name
    ListItem.Checked := True;
    for i := 1 to P_nr do
      ListItem.SubItems.Add(''); // add the other columns
    Dec(index); {go to next file}
  end;
  listview7.Items.EndUpdate;

  listview1.Clear;

  stack_method1.ItemIndex := oldindex;//return old setting
  save_settings2;

  analyse_listview(listview7, True {light}, False {full fits}, True{refresh});
  {refresh list}
end;

procedure Tstackmenu1.PopupMenu1Popup(Sender: TObject);
begin
  auto_select1.Enabled := stackmenu1.use_manual_alignment1.Checked;
end;


procedure Tstackmenu1.press_esc_to_abort1Click(Sender: TObject);
begin
  esc_pressed := True;
end;


procedure Tstackmenu1.rainbow_Panel1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  w2, h2: integer;
  hue, dhue, oldhue, s, v, r, g, b: single;
  colour: tcolor;
begin
  with rainbow_Panel1 do
  begin
    w2 := Width div 2;
    h2 := Height div 2;

    hue := 180 + Arctan2(x - w2, y - h2) * 180 / pi;

    dhue := hue_fuzziness1.position;
    hue1 := hue - dhue / 2;
    hue2 := hue + dhue / 2;
    stackmenu1.rainbow_panel1.refresh;
    {plot colour disk on an OnPaint event. Required for MacOS}
  end;

  {adapt shape colours}
  if HueRadioButton1.Checked then
  begin
    colour := colourShape1.brush.color;
    RGB2HSV(getRvalue(colour), getGvalue(colour), getBvalue(colour), oldhue, s, v);
    HSV2RGB(hue, s {s 0..1}, v {v 0..1}, r, g, b);
    colourShape1.brush.color := rgb(trunc(r), trunc(g), trunc(b));
  end;
  if HueRadioButton2.Checked then
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

procedure Tstackmenu1.rainbow_Panel1Paint(Sender: TObject);
{pixel draw on paint required for MacOS}
var
  i, j, w2, h2, diameter: integer;
  r, g, b, h, x, y, radius, s, v: single;
  colour: tcolor;
begin
  with stackmenu1.rainbow_panel1 do
  begin
    w2 := Width div 2;
    h2 := Height div 2;

    for i := -w2 to w2 do
      for j := -h2 to h2 do
      begin
        if sqr(i) + sqr(j) < sqr(w2) then {plot only in a circel}
        begin
          h := 180 + Arctan2(i, j) * 180 / pi;
          radius := (i * i + j * j) / (w2 * h2);
          HSV2RGB(h, radius {s 0..1}, 255 {v 0..1}, r, g, b);
          canvas.pixels[i + w2, j + h2] := rgb(trunc(r), trunc(g), trunc(b));
        end;
      end;

    Canvas.Pen.Width := 2;{thickness lines}
    Canvas.pen.color := clblack;
    sincos(hue1 * pi / 180, x, y);
    canvas.moveto(w2, h2);
    canvas.lineto(w2 - round(x * (w2 - 3)), h2 - round(y * (w2 - 3)));

    sincos(hue2 * pi / 180, x, y);
    canvas.moveto(w2, h2);
    canvas.lineto(w2 - round(x * (w2 - 3)), h2 - round(y * (w2 - 3)));

    colour := colourShape1.brush.color;
    RGB2HSV(getRvalue(colour), getGvalue(colour), getBvalue(colour), h, s, v);

    canvas.Brush.Style := bsClear;{transparent style}
    diameter := max(0, round(w2 * s - w2 * saturation_tolerance1.position / 100));
    canvas.Ellipse(w2 - diameter, h2 - diameter, w2 + diameter, h2 + diameter);

    diameter := min(w2, round(w2 * s + w2 * saturation_tolerance1.position / 100));
    canvas.Ellipse(w2 - diameter, h2 - diameter, w2 + diameter, h2 + diameter);

  end;
end;

procedure Tstackmenu1.reference_database1Change(Sender: TObject);
begin
  if head.mzero <> 0 then
  begin
    memo2_message('Flux calibration cleared. For magnitude measurements in viewer recalibrate by ctrl-U. See viewer tool menu. ');
    head.mzero := 0;
  end;
end;


procedure Tstackmenu1.remove_luminance1Change(Sender: TObject);
begin
  update_replacement_colour;
end;


procedure Tstackmenu1.result_compress1Click(Sender: TObject);
var
  index, counter: integer;
  filen: string;
begin
  index := 0;
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  counter := listview5.Items.Count;
  esc_pressed := False;
  while index < counter do
  begin
    if listview5.Items[index].Selected then
    begin
      filen := listview5.items[index].Caption;
      Application.ProcessMessages;
      if ((esc_pressed) or (pack_cfitsio(filen) = False)) then
      begin
        beep;
        mainwindow.Caption := 'Exit with error!!';
        Screen.Cursor := crDefault;
        exit;
      end;
    end;
    Inc(index); {go to next file}
  end;
  stackmenu1.Caption := 'Finished, all files compressed with extension .fz.';
  Screen.Cursor := crDefault;  { Always restore to normal }
end;


procedure Tstackmenu1.rename_result1Click(Sender: TObject);
var
  index, counter: integer;
  thepath, newfilen: string;
begin
  index := 0;
  counter := listview5.Items.Count;
  while index < counter do
  begin
    if listview5.Items[index].Selected then
    begin
      filename2 := listview5.items[index].Caption;
      thepath := extractfilepath(filename2);
      newfilen := thepath + InputBox('New name:', '', extractfilename(filename2));
      if ((newfilen = '') or (newfilen = filename2)) then exit;
      if RenameFile(filename2, newfilen) then
        listview5.items[index].Caption := newfilen
      else
        beep;
    end;
    Inc(index); {go to next file}
  end;

end;

procedure Tstackmenu1.restore_file_ext1Click(Sender: TObject);
var
  searchResult: TSearchRec;
  filen: string;
  counter: integer;
begin
  counter := 0;
  esc_pressed := True; {stop all stacking}
  if SysUtils.FindFirst(live_stacking_path1.Caption + PathDelim + '*.*_',
    faAnyFile, searchResult) = 0 then
  begin
    repeat
      with searchResult do
      begin
        filen := live_stacking_path1.Caption + PathDelim + searchResult.Name;
        if copy(filen, length(filen), 1) = '_' then
        begin
          if RenameFile(filen, copy(filen, 1, length(filen) - 1)) = False then {remove *.*_}
            beep
          else
            Inc(counter);
        end;
      end;
    until SysUtils.FindNext(searchResult) <> 0;
    SysUtils.FindClose(searchResult);
  end;


  live_stacking_pause1.font.style := [];
  live_stacking1.font.style := [];

  memo2_message('Live stacking stopped and ' + IntToStr(counter) +
    ' files renamed to original file name.');
end;



procedure Tstackmenu1.colournebula1Click(Sender: TObject);
var
  radius, fitsX, fitsY: integer;
  Value, org_value: single;
  star_level_colouring: double;
begin
  if Length(img_loaded) = 0 then
  begin
    memo2_message('Error, no image in viewer loaded!');
    exit;
  end;

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img; {move copy to img_backup}

  get_background(0, img_loaded, False {do not calculate hist}, False {do not calculate noise_level}, {out} bck);

  try
    radius := StrToInt(stackmenu1.filter_artificial_colouring1.Text);
  except
  end;
  memo2_message('Applying most common filter with factor ' +
    stackmenu1.filter_artificial_colouring1.Text);

  setlength(img_temp, 3, head.Width, head.Height);{new size}
  apply_most_common(img_backup[index_backup].img, img_temp, radius);
  {apply most common filter on first array and place result in second array}

  memo2_message('Applying Gaussian blur of ' + floattostrF(radius * 2, ffFixed, 0, 1));
  gaussian_blur2(img_temp, radius * 2);


  setlength(img_loaded, 3, head.Width, head.Height);{new size}

  memo2_message('Separating stars and nebula. Making everything white with value ' +
    stackmenu1.star_level_colouring1.Text + ' above background.');

  star_level_colouring := StrToInt(stackmenu1.star_level_colouring1.Text);

  for fitsY := 0 to head.Height - 1 do
    for fitsX := 0 to head.Width - 1 do
    begin {subtract view from file}
      org_value := img_backup[index_backup].img[0, fitsX, fitsY];  {stars+nebula}
      {smooth nebula}
      Value := org_value - img_temp[0, fitsX, fitsY];
      if Value > star_level_colouring then {star}
      begin
        img_loaded[0, fitsX, fitsY] := org_value;
        if head.naxis3 > 1 then
          img_loaded[1, fitsX, fitsY] := img_backup[index_backup].img[1, fitsX, fitsY]
        else
          img_loaded[1, fitsX, fitsY] := org_value;
        if head.naxis3 > 2 then
          img_loaded[2, fitsX, fitsY] := img_backup[index_backup].img[2, fitsX, fitsY]
        else
          img_loaded[2, fitsX, fitsY] := org_value;
      end
      else {nebula}
      begin
        img_loaded[0, fitsX, fitsY] := org_value;
        img_loaded[1, fitsX, fitsY] :=
          bck.backgr + (org_value - bck.backgr) * Value / star_level_colouring;
        img_loaded[2, fitsX, fitsY] :=
          bck.backgr + (org_value - bck.backgr) * Value / star_level_colouring;
      end;

    end;

  head.naxis3 := 3;
  head.naxis := 3;
  update_header_for_colour; {update header naxis and naxis3 keywords}
  update_text('HISTORY 77', '  Artificial colour applied.');

  use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1, False, True);{plot real}
  Screen.Cursor := crDefault;
end;


procedure Tstackmenu1.clear_photometry_list1Click(Sender: TObject);
begin
  esc_pressed := True; {stop any running action}
  listview7.Clear;
end;

procedure Tstackmenu1.export_aligned_files1Click(Sender: TObject);
var
  c, fitsX, fitsY, x_new, y_new, col, ps: integer;
  st: string;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  esc_pressed := False;

  align_blink1.Checked := True;
  for c := 0 to listview6.items.Count - 1 do {check alignement and if not align}
  begin
    st := listview6.Items.item[c].subitems.Strings[B_solution];
    if st = '' then
    begin
      memo2_message('Doing the alignment first');
      stackmenu1.clear_blink_alignment1Click(nil);
      stackmenu1.blink_button1Click(nil);
      break;
    end;
  end;


  for c := 0 to listview6.items.Count - 1 do {this is not required but nice}
  begin
    st := listview6.Items.item[c].subitems.Strings[B_solution];
    if st <> '' then {Solution available}
    begin
      filename2 := listview6.items[c].Caption;
      mainwindow.Caption := filename2;

      listview6.Selected := nil; {remove any selection}
      listview6.ItemIndex := c;
      {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
      listview6.Items[c].MakeVisible(False);{scroll to selected item}

      if load_fits(filename2, True {light}, True, True {update memo}, 0,
        head, img_loaded) = False then
      begin
        esc_pressed := True;
        break;
      end;  {load fits}

      Application.ProcessMessages;
      if esc_pressed then break;

      {reuse solution}
      ps := StrToInt(copy(st, 4, 10));
      solution_vectorX := bsolutions[ps].solution_vectorX; {use stored solution}
      solution_vectorY := bsolutions[ps].solution_vectorY;


      setlength(img_temp, head.naxis3, head.Width, head.Height);{new size}

      for fitsY := 0 to head.Height - 1 do
        for fitsX := 0 to head.Width - 1 do
        begin
          for col := 0 to head.naxis3 - 1 do
            {all colors} img_temp[col, fitsX, fitsY] := 0;{clear memory}
        end;

      {align}
      for fitsY := 0 to head.Height - 1 do
        for fitsX := 0 to head.Width - 1 do
        begin
          x_new := round(solution_vectorX[0] * (fitsx) + solution_vectorX[1] *
            (fitsY) + solution_vectorX[2]); {correction x:=aX+bY+c}
          y_new := round(solution_vectorY[0] * (fitsx) + solution_vectorY[1] *
            (fitsY) + solution_vectorY[2]); {correction y:=aX+bY+c}

          if ((x_new >= 0) and (x_new <= head.Width - 1) and (y_new >= 0) and
            (y_new <= head.Height - 1)) then
            for col := 0 to head.naxis3 - 1 do
              {all colors} img_temp[col, x_new, y_new] := img_loaded[col, fitsX, fitsY];
        end;

      {fix black holes}
      img_loaded := img_temp;
      black_spot_filter(img_loaded);

      if pos('_aligned.fit', filename2) = 0 then
        filename2 := ChangeFileExt(Filename2, '_aligned.fit');{rename only once}

      if timestamp1.Checked then
      begin
        if date_avg = '' then
          annotation_to_array('date_obs: ' + head.date_obs, False, 65535,
            1{size}, 1, 10, img_loaded) {head.date_obs to image array as annotation}
        else
          annotation_to_array('date_avg: ' + date_avg, False, 65535,
            1{size}, 1, 10, img_loaded);
        {head.date_obs to image array as annotation}
      end;
      add_text('COMMENT ',
        ' Image aligned with other images.                                    ');

      if nrbits = 16 then
        save_fits(img_loaded, filename2, 16, True)
      else
        save_fits(img_loaded, filename2, -32, True);
      memo2_message('New aligned image created: ' + filename2);
      listview6.items[c].Caption := filename2;
    end;

  end;
  img_temp := nil;

  if head.naxis <> 0 then
    plot_fits(mainwindow.image1, False {re_center}, True);
  {the last displayed image doesn't match with header. Just plot last image to fix}
  Screen.Cursor := crDefault;{back to normal }
end;



function JdToDate(jd: double): string;{Returns Date from Julian Date,  See MEEUS 2 page 63}
var
  A, B, C, D, E, F, G, J, memo2, T, Z: double;
  {!!! 2016 by purpose, otherwise with timezone 8, 24:00 midnigth becomes 15:59 UTC}
  HH, MM, SS: integer;
  year3: string[6];
begin
  if (abs(jd) > 1461 * 10000) then
  begin
    Result := 'Error, JD outside allowed range!';
    exit;
  end;

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
  B := A + 1524 + {special =>} (1461 * 10000);
  {allow up to 40.000 year in past, 1461 days *100000 = 4x 10000 years}
  C := trunc((B - 122.1) / 365.25);
  D := trunc(365.25 * C);
  E := trunc((B - D) / 30.6001);
  T := B - D - int(30.6001 * E) + F; {day of the month}
  if (E < 14) then
    memo2 := E - 1
  else
    memo2 := E - 13;
  if (memo2 > 2) then
    J := C - 4716
  else
    J := C - 4715;

  j := J - {special= >} 4 * 10000;
  {allow up to 40.000 year in past, 1461 days *100000 = 4x 10000 years}

  F := fnmodulo(F, 1);{for negative julian days}
  HH := trunc(F * 24);
  MM := trunc((F - HH / 24) * (24 * 60));{not round otherwise 23:60}
  SS := trunc((F - HH / 24 - MM / (24 * 60)) * (24 * 3600));

  str(trunc(j): 4, year3);

  Result := year3 + '-' + leadingzero(trunc(memo2)) + '-' + leadingzero(trunc(t)) +
    'T' + leadingzero(HH) + ':' + leadingzero(MM) + ':' + leadingzero(SS);
end;


function julian_calc(yyyy, mm: integer; dd, hours, minutes, seconds: double): double;
  {##### calculate julian day, revised 2017}
var
  Y, memo2: integer;
  A, B, XX: double;
begin
  if MM > 2 then
  begin
    Y := YYYY;
    memo2 := MM;
  end
  else {MM=1 OR MM=2}
  begin
    Y := YYYY - 1;
    memo2 := MM + 12;
  end;

  DD := DD + HOURS / 24 + MINUTES / (24 * 60) + SECONDS / (24 * 60 * 60);

  if ((YYYY + MM / 100 + DD / 10000) < 1582.10149999) then
    B := 0 {year 1582 October, 15, 00:00 reform Gregorian to julian, 1582.10149999=1582.1015 for rounding errors}
  else
    {test year 837 april 10, 0 hours is Jd 2026871.5}
  begin
    A := INT(Y / 100);
    B := +2 - A + INT(A / 4);
  end;

  if Y < 0 then XX := 0.75
  else
    xx := 0;{correction for negative years}
  Result := INT(365.25 * Y - XX) + INT(30.6001 * (memo2 + 1)) + DD +
    B + 1720994.5;
end;


//function UTdecimal(date : string): string; {UT date in decimal notation}
//var dayfract : string;
//begin
//  {'2021-03-08T17:55:23'}
//  str(strtoint(copy(date,12,2))/24 +strtoint(copy(date,15,2))/(24*60) + strtoint(copy(date,18,2))/(24*60*60):0:4,dayfract);{convert time to fraction of a day}
//  result:=copy(date,1,4)+copy(date,6,2)+copy(date,9,2)+copy(dayfract,2,5);
//end;


procedure date_to_jd(date_time: string; exp: double);
{convert head.date_obs string and head.exposure time to global variables jd_start (julian day start head.exposure) and jd_mid (julian day middle of the head.exposure)}
var
  yy, mm, dd, hh, min, error2: integer;
  ss: double;
begin
  jd_start := 0;
  val(copy(date_time, 18, 7), ss, error2);
  if error2 <> 0 then exit; {read also milliseconds}

  val(copy(date_time, 15, 2), min, error2);
  if error2 <> 0 then exit;
  val(copy(date_time, 12, 2), hh, error2);
  if error2 <> 0 then exit;
  val(copy(date_time, 09, 2), dd, error2);
  if error2 <> 0 then exit;
  val(copy(date_time, 06, 2), mm, error2);
  if error2 <> 0 then exit;
  val(copy(date_time, 01, 4), yy, error2);
  if error2 <> 0 then exit;
  jd_start := julian_calc(yy, mm, dd, hh, min, ss);{calculate julian date}
  jd_mid := jd_start + exp / (2 * 24 * 3600);{Add half head.exposure in days to get midpoint}
end;


procedure Tstackmenu1.FormDropFiles(Sender: TObject; const FileNames: array of string);
var
  i, pageindex: integer;
begin
  pageindex := pagecontrol1.pageindex;

  case pageindex of
    1: listview2.Items.beginUpdate;{darks}
    2: listview3.Items.beginUpdate;{flats}
    3: listview4.Items.beginUpdate;{flat darks}
    7: listview6.Items.beginUpdate;{blink}
    8: listview7.Items.beginUpdate;{photometry}
    9: listview8.Items.beginUpdate;{inspector}
    10: listview9.Items.beginUpdate;{mount}
    else
      listview1.Items.beginUpdate; {lights}

  end;

  for i := Low(FileNames) to High(FileNames) do
  begin
    if image_file_name(FileNames[i]) = True then {readable image file}
    begin
      case pagecontrol1.pageindex of
        1: listview_add(listview2, FileNames[i], True, D_nr);{darks}
        2: listview_add(
            listview3, FileNames[i], True, F_nr);{flats}
        3: listview_add(
            listview4, FileNames[i], True, FD_nr);{flat darks}
        7: listview_add(
            listview6, FileNames[i], True, B_nr);{blink}
        8: listview_add(
            listview7, FileNames[i], True, P_nr);
        {photometry}
        9: listview_add(
            listview8, FileNames[i], True, P_nr);
        {inspector}
        10: listview_add(
            listview9, FileNames[i], True, P_nr);{mount}
        else
        begin {lights}
          listview_add(listview1, FileNames[i], True, L_nr);
          if pos('_stacked', FileNames[i]) <> 0 then
            {do not check mark lights already stacked}
            listview1.items[
              ListView1.items.Count - 1].Checked := False;
        end;
      end;
    end;
  end;

  case pageindex of
    1: listview2.Items.EndUpdate;{darks}
    2: listview3.Items.EndUpdate;{flats}
    3: listview4.Items.EndUpdate;{flat darks}
    7: listview6.Items.EndUpdate;{blink}
    8: listview7.Items.EndUpdate;{photometry}
    9: listview8.Items.EndUpdate;{inspector}
    10: listview9.Items.EndUpdate;{mount}
    else
    begin {lights}
      listview1.Items.EndUpdate;
      count_selected;
      {report the number of lights selected in images_selected and update menu indication}
    end;
  end;

end;


procedure Tstackmenu1.FormPaint(Sender: TObject);
begin
  case pagecontrol1.tabindex of
    7: more_indication1.Visible := stackmenu1.Width <= export_aligned_files1.left + 20;
    8: more_indication1.Visible :=
        stackmenu1.Width <= mark_outliers_upto1.left + 20;
    9: more_indication1.Visible :=
        stackmenu1.Width <= GroupBox_test_images1.left + 20;
    else
      more_indication1.Visible := False;

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
  const ARect: TRect; var DefaultDraw: boolean);
begin
  stackmenu1.nr_total_photometry1.Caption := IntToStr(Sender.items.Count);
  {update counting info}
end;


procedure Tstackmenu1.listview7CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: boolean);
begin
  Sender.Canvas.Font.Color := clmenutext;
  {required for high contrast settings. Otherwise it is always black}
end;


procedure Tstackmenu1.live_stacking_pause1Click(Sender: TObject);
begin
  pause_pressed := True;
  live_stacking_pause1.font.style := [fsbold, fsunderline];
  live_stacking1.font.style := [];
  Application.ProcessMessages; {process font changes}
end;


procedure Tstackmenu1.live_stacking_restart1Click(Sender: TObject);
begin
  esc_pressed := True;
  live_stacking_pause1.font.style := [];
  live_stacking1.font.style := [];
  Application.ProcessMessages; {process font changes}
end;


procedure Tstackmenu1.more_indication1Click(Sender: TObject);
begin
  case pagecontrol1.tabindex of
    7: stackmenu1.Width := export_aligned_files1.left + export_aligned_files1.Width + 10;
    {set width if clicked on arrow}
    8: stackmenu1.Width :=
        mark_outliers_upto1.left + mark_outliers_upto1.Width + 10;
    9: stackmenu1.Width :=
        GroupBox_test_images1.left + GroupBox_test_images1.Width + 10;
  end;
end;


procedure Tstackmenu1.photometry_binx2Click(Sender: TObject);
var
  c: integer;
begin
  esc_pressed := False;
  if (idYes = Application.MessageBox(
    'Binning images 2x2 for better detection. Original files will be preserved. Continue?',
    'Bin 2x2', MB_ICONQUESTION + MB_YESNO)) = False then exit;

  listview7.Items.beginUpdate;
  for c := 0 to listview7.items.Count - 1 do
  begin
    if ((esc_pressed = False) and (listview7.Items.item[c].Checked)) then
    begin

      filename2 := listview7.items[c].Caption;

      if fits_file_name(filename2) = False then
      begin
        memo2_message('█ █ █ █ █ █ Can' + #39 +
          't bin x 2. First analyse file list to convert to FITS !! █ █ █ █ █ █');
        beep;
        exit;
      end;
      mainwindow.Caption := filename2;
      Application.ProcessMessages;
      if ((esc_pressed) or (binX2X3_file(2) = False))
      {converts filename2 to binx2 version} then exit;
      listview7.Items[c].Checked := False;
      listview_add(listview7, filename2, True, P_nr);{add binx2 file}
    end;
  end;{for loop}
  listview7.Items.endUpdate;
end;


procedure find_star_outliers(report_upto_magn: double;
  var outliers: star_list) {contains the four stars with largest SD };
var
  stepnr, x_new, y_new, c, i, j, nr_images, smallest, w, h, w2, h2: integer;
  stars_mean, stars_sd, stars_count: array of array of single;
  created: boolean;
  sd, xc, yc      : double;
const
  factor = 10; {div factor to get small variations at the same location}
begin
  memo2_message('Searching for outliers');
  created := False;
  stepnr := 0;
  nr_images := 0;
  w2 := 999999;
  h2 := 999999;
  outliers := nil;{wil be used for detection later}

  repeat
    Inc(stepnr);
    for c := 0 to stackmenu1.listview7.items.Count - 1 do {do all files}
    begin
      Application.ProcessMessages;
      if esc_pressed then
      begin
        exit;
      end;

      if stackmenu1.listview7.Items.item[c].Checked then
      begin {read solution}
        {load file, and convert astrometric solution to vector solution}
        filename2 := stackmenu1.listview7.items[c].Caption;
        if load_fits(filename2, True {light}, False {only read header},
          False {update memo}, 0, head_2, img_temp) = False then
        begin
          esc_pressed := True;
          exit;
        end;
        {calculate vectors from astrometric solution to speed up}
        sincos(head_2.dec0, SIN_dec0, COS_dec0);
        {do this in advance since it is for each pixel the same}
        astrometric_to_vector;{convert astrometric solution to vectors}

        w := (starlistpack[c].Width div factor);
        h := (starlistpack[c].Height div factor);
        if w2 > w then w2 := w;{find smallest dimensions used}
        if h2 > h then h2 := h;
        if created = False then
        begin
          setlength(stars_mean, w + 1, h + 1);
          setlength(stars_sd, w + 1, h + 1);
          setlength(stars_count, w + 1, h + 1);
          for i := 0 to w do
            for j := 0 to h do
            begin
              stars_mean[i, j] := 0;
              stars_sd[i, j] := 0;
              stars_count[i, j] := 0;
            end;
          created := True;
        end;

        if starlistpack[c].Height <> 0 then {filled with data}
        begin
          if stepnr = 1 then Inc(nr_images);{keep record of number of lights}
          try
            for i := 0 to min(length(starlistpack[c].starlist[0]) - 2, 5000) do
              {calculate mean of the found stars}
            begin
              xc := (solution_vectorX[0] * (starlistpack[c].starlist[0, i]) +
                solution_vectorX[1] * (starlistpack[c].starlist[1, i]) + solution_vectorX[2]);
              {correction x:=aX+bY+c}
              yc := (solution_vectorY[0] * (starlistpack[c].starlist[0, i]) +
                solution_vectorY[1] * (starlistpack[c].starlist[1, i]) + solution_vectorY[2]);
              {correction y:=aX+bY+c}
              if ((xc >= factor) and (xc <= starlistpack[c].Width - 1 - factor) and
                (yc >= factor) and (yc <= starlistpack[c].Height - 1 - factor)) then
                {image could be shifted and very close to the boundaries. Prevent runtime errors}
              begin
                x_new := round(xc / factor);
                y_new := round(yc / factor);

                if stepnr = 1 then
                begin {CALCULATE MEAN magnitude of the stars}
                  stars_mean[x_new, y_new] := stars_mean[x_new, y_new] +
                  (head.MZERO - ln(starlistpack[c].starlist[3, i]{flux})*2.5/ln(10));{magnitude}
                  //ln(starlistpack[c].flux_ratio/starlistpack[c].starlist[3, i]{flux})/ln(2.511886432); {magnitude}


                  stars_count[x_new, y_new] := stars_count[x_new, y_new] + 1;{counter}
                end
                else {CALCULATE SD of stars}
                if stepnr = 2 then
                begin
                  stars_sd[x_new, y_new] :=
                    stars_sd[x_new, y_new] + sqr((stars_mean[x_new, y_new] / stars_count[x_new, y_new]) -
                    (head.MZERO - ln(starlistpack[c].starlist[3, i]{flux})*2.5/ln(10)) );{sd calculate by sqr magnitude difference from mean}
//                    ln( starlistpack[c].flux_ratio/starlistpack[c].starlist[3, i]{flux})/ln(2.511886432) ); {sd calculate by sqr magnitude difference from mean}
                end;


              end;
            end;{for loop}
          except
            beep;
          end;
        end;{valid image}

      end;
    end;{for c:=0 loop}
  until stepnr > 2;

  if created then
  begin

    setlength(outliers, 4, 4);
    for i := 0 to 3 do
      for j := 0 to 3 do
        outliers[i, j] := 0;

    {find largest outliers}
    for i := 0 to w2 do
      for j := 0 to h2 do
      begin
        try
          if stars_count[i, j] >= round(nr_images * 0.8) then
            {at least in 80% of the cases star detection}
            if (stars_mean[i, j] / stars_count[i, j]) <= report_upto_magn then
              {magnitude lower then}
            begin
              sd := sqrt(stars_sd[i, j] / stars_count[i, j]);


              if ((sd > outliers[2, 0]) or (sd > outliers[2, 1]) or (sd > outliers[2, 2]) or
                (sd > outliers[2, 3])) then
              begin
                if ((outliers[2, 0] <= outliers[2, 1]) and (outliers[2, 0] <= outliers[2, 2]) and
                  (outliers[2, 0] <= outliers[2, 3])) then smallest := 0
                else
                if ((outliers[2, 1] <= outliers[2, 0]) and (outliers[2, 1] <= outliers[2, 2]) and
                  (outliers[2, 1] <= outliers[2, 3])) then smallest := 1
                else
                if ((outliers[2, 2] <= outliers[2, 0]) and (outliers[2, 2] <= outliers[2, 1]) and
                  (outliers[2, 2] <= outliers[2, 3])) then smallest := 2
                else
                if ((outliers[2, 3] <= outliers[2, 0]) and (outliers[2, 3] <= outliers[2, 1]) and
                  (outliers[2, 3] <= outliers[2, 2])) then smallest := 3;


                {replace the smallest sd}
                outliers[0, smallest] := i * factor;{store x}
                outliers[1, smallest] := j * factor;{store y}
                outliers[2, smallest] := SD;{store sd}
              end;
            end;

        except
          beep;
        end;
      end;{for loop}

    if nr_images < 6 then memo2_message(
        'Warning, not enough images for reliable outlier detection');
    if outliers[2, 0] <> 0 then
      memo2_message('Found star 1 with magnitude variation. σ = ' +
        floattostr6(outliers[2, 0]) + ' at x=' + IntToStr(round(outliers[0, 0])) +
        ', y=' + IntToStr(round(outliers[1, 0])) + '. Marked with yellow circle.');
    if outliers[2, 1] <> 0 then
      memo2_message('Found star 2 with magnitude variation. σ = ' +
        floattostr6(outliers[2, 1]) + ' at x=' + IntToStr(round(outliers[0, 1])) +
        ', y=' + IntToStr(round(outliers[1, 1])) + '. Marked with yellow circle.');
    if outliers[2, 2] <> 0 then
      memo2_message('Found star 3 with magnitude variation. σ = ' +
        floattostr6(outliers[2, 2]) + ' at x=' + IntToStr(round(outliers[0, 2])) +
        ', y=' + IntToStr(round(outliers[1, 2])) + '. Marked with yellow circle.');
    if outliers[2, 3] <> 0 then
      memo2_message('Found star 4 with magnitude variation. σ = ' +
        floattostr6(outliers[2, 3]) + ' at x=' + IntToStr(round(outliers[0, 3])) +
        ', y=' + IntToStr(round(outliers[1, 3])) + '. Marked with yellow circle.');
  end;

  //  stars:=nil;
  stars_sd := nil;
  stars_mean := nil;
  stars_count := nil;
end;


procedure Tstackmenu1.photometry_button1Click(Sender: TObject);
var
  magn, hfd1, star_fwhm, snr, flux, xc, yc, madVar, madCheck, madThree, medianVar,
  medianCheck, medianThree, hfd_med, apert, annul,
  rax1, decx1, rax2, decx2, rax3, decx3, xn, yn, adu_e : double;
  saturation_level:  single;
  c, i, x_new, y_new, fitsX, fitsY, col,{first_image,}size, starX, starY, stepnr, countVar,
  countCheck, countThree, database_col : integer;
  flipvertical, fliphorizontal, init, refresh_solutions, analysedP, store_annotated,
  warned, success: boolean;
  starlistx: star_list;
  starVar, starCheck, starThree: array of double;
  outliers: array of array of double;
  astr, memo2_text, filename1,dummy : string;
  bck :tbackground;

  function measure_star(deX, deY: double): string;{measure position and flux}
  begin
    HFD(img_loaded, round(deX - 1), round(deY - 1), annulus_radius
      {14, annulus radius}, head.mzero_radius, adu_e, hfd1, star_fwhm, snr, flux, xc, yc);
    {star HFD and FWHM}
    if ((hfd1 < 50) and (hfd1 > 0) and (snr > 6)) then {star detected in img_loaded}
    begin
      if head.calstat = '' then saturation_level := 64000
      else
        saturation_level := 60000; {could be dark subtracted changing the saturation level}
      if ((img_loaded[0, round(xc), round(yc)] < saturation_level) and
        (img_loaded[0, round(xc - 1), round(yc)] < saturation_level) and
        (img_loaded[0, round(xc + 1), round(yc)] < saturation_level) and
        (img_loaded[0, round(xc), round(yc - 1)] < saturation_level) and
        (img_loaded[0, round(xc), round(yc + 1)] < saturation_level) and
        (img_loaded[0, round(xc - 1), round(yc - 1)] < saturation_level) and
        (img_loaded[0, round(xc - 1), round(yc + 1)] < saturation_level) and
        (img_loaded[0, round(xc + 1), round(yc - 1)] < saturation_level) and
        (img_loaded[0, round(xc + 1), round(yc + 1)] < saturation_level)) then
        {not saturated star}
      begin
        magn:=starlistpack[c].MZERO - ln(flux)*2.5/ln(10);


        Result := floattostrf(magn, ffFixed, 5, 3);
        {write measured magnitude to list}
        //        mainwindow.image1.Canvas.textout(round(dex)+40,round(dey)+20,'hhhhhhhhhhhhhhh'+floattostrf(magn, ffgeneral, 3,3) );
        //        mainwindow.image1.Canvas.textout(round(dex)+20,round(dey)+20,'decX,Y '+floattostrf(deX, ffgeneral, 3,3)+','+floattostrf(deY, ffgeneral, 3,3)+'  Xc,Yc '+floattostrf(xc, ffgeneral, 3,3)+','+floattostrf(yc, ffgeneral, 3,3));
        //        memo2_message(filename2+'decX,Y '+floattostrf(deX, ffgeneral, 4,4)+', '+floattostrf(deY, ffgeneral, 4,4)+'  Xc,Yc '+floattostrf(xc, ffgeneral, 4,4)+', '+floattostrf(yc, ffgeneral, 4,4)+'    '+result+  '  deltas:'  + floattostrf(deX-xc, ffgeneral, 4,4)+',' + floattostrf(deY-yc, ffgeneral, 4,4)+'offset '+floattostrf(starlistpack[c].flux_ratio, ffgeneral, 6,6)+'fluxlog '+floattostrf(ln(flux)*2.511886432/ln(10), ffgeneral, 6,6) );

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
      else
        Result := 'Saturated';
    end
    else
      Result := '?';
  end;

  procedure plot_annulus(x, y: integer); {plot the aperture and annulus}
  begin
    if Flipvertical = False then  starY := (head.Height - y)
    else
      starY := (y);
    if Fliphorizontal then starX := (head.Width - x)
    else
      starX := (x);
    if head.mzero_radius < 99 {<>max setting} then
      mainwindow.image1.canvas.ellipse(
        round(starX - head.mzero_radius - 1), round(starY - head.mzero_radius - 1), round(
        starX + head.mzero_radius + 1), round(starY + head.mzero_radius + 1));
    {circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
    mainwindow.image1.canvas.ellipse(round(starX - annulus_radius),
      round(starY - annulus_radius), round(starX + annulus_radius), round(starY + annulus_radius));
    {three pixels, 1,2,3}
    mainwindow.image1.canvas.ellipse(round(starX - annulus_radius - 4),
      round(starY - annulus_radius - 4), round(starX + annulus_radius + 4), round(
      starY + annulus_radius + 4));
  end;

  procedure plot_outliers;{plot up to 4 yellow circles around the outliers}
  var
    k: integer;
  begin
    mainwindow.image1.Canvas.Pen.Color := clyellow;
    for k := 0 to length(outliers[0]) - 1 do
    begin
      if flipvertical = False then  starY := round(head.Height - (outliers[1, k]))
      else
        starY := round(outliers[1, k]);
      if Fliphorizontal then starX := round(head.Width - outliers[0, k])
      else
        starX := round(outliers[0, k]);
      mainwindow.image1.Canvas.ellipse(starX - 20, starY - 20, starX + 20, starY + 20);
      {indicate outlier rectangle}
      mainwindow.image1.Canvas.textout(starX + 20, starY + 20,
        'σ ' + floattostrf(outliers[2, k], ffgeneral, 3, 0));{add hfd as text}
    end;
  end;


  procedure nil_all;
  begin
    //img_temp:=nil;{free memory}
    starlistx := nil;{free memory}
    starlistpack := nil; {release memory}
    outliers := nil;
    starCheck := nil;
    starThree := nil;
    Screen.Cursor := crDefault;{back to normal }
  end;

begin
  if listview7.items.Count <= 0 then exit; {no files}

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  save_settings2;{too many lost selected files . so first save settings}

  if pos('V', uppercase(star_database1.Text)) = 0 then
    memo2_message(star_database1.Text +
      ' used  █ █ █ █ █ █ Warning, select a V database for accurate Johnson-V magnitudes !!! See tab alignment. █ █ █ █ █ █ ');


  {check is analyse is done}
  analysedP := True;
  for c := 0 to listview7.items.Count - 1 do
  begin
    if ((listview7.Items.item[c].Checked) and
      (listview7.Items.item[c].subitems.Strings[B_width] = '' {width})) then analysedP := False;
  end;
  if analysedP = False then stackmenu1.analysephotometry1Click(nil);
  application.ProcessMessages;{show result}

  flipvertical := mainwindow.flip_vertical1.Checked;
  fliphorizontal := mainwindow.flip_horizontal1.Checked;
  apert := strtofloat2(flux_aperture1.Text);
  aperture_ratio := apert;{remember apert setting}
  annul := strtofloat2(annulus_radius1.Text);

  esc_pressed := False;
  warned := False;

  memo2_message( 'Checking for astrometric solutions in FITS header required for star flux calibration against star database.');

  refresh_solutions := (Sender = stackmenu1.refresh_astrometric_solutions1);
  {refresh astrometric solutions}


  {solve lights first to allow flux to magnitude calibration}
  memo2_text := mainwindow.Memo1.Text;{backup fits header}
  for c := 0 to listview7.items.Count - 1 do {check for astrometric solutions}
  begin
    if ((esc_pressed = False) and (listview7.Items.item[c].Checked) and
      (listview7.Items.item[c].subitems.Strings[P_astrometric] = '')) then
    begin
      filename1 := listview7.items[c].Caption;
      mainwindow.Caption := filename1;

      Application.ProcessMessages;

      {load image}
      if ((esc_pressed) or (load_fits(filename1, True {light}, True,
        True {update memo}, 0, head_2, img_temp) = False)) then
      begin
        nil_all;{nil all arrays and restore cursor}
        exit;
      end;

      if ((head_2.cd1_1 = 0) or (refresh_solutions)) then
      begin
        listview7.Selected := nil; {remove any selection}
        listview7.ItemIndex := c;
        {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview7.Items[c].MakeVisible(False);{scroll to selected item}
        memo2_message(filename1 + ' Adding astrometric solution to files to allow flux to magnitude calibration using the star database.');
        Application.ProcessMessages;

        if solve_image(img_temp, head_2, True  {get hist}) then
        begin{match between loaded image and star database}
          if fits_file_name(filename1) then
            success := savefits_update_header(filename1)
          else
            success := save_tiff16_secure(img_temp, filename1);{guarantee no file is lost}
          if success = False then
          begin
            ShowMessage('Write error !!' + filename2);
            Screen.Cursor := crDefault;
            exit;
          end;
          listview7.Items.item[c].subitems.Strings[P_astrometric] := '✓';
        end
        else
        begin
          listview7.Items[c].Checked := False;
          listview7.Items.item[c].subitems.Strings[P_astrometric] := '';
          memo2_message(filename1 +
            'Uncheck, no astrometric solution found for this file. Can' + #39 + 't measure magnitude!');
        end;
      end
      else
      begin
        listview7.Items.item[c].subitems.Strings[P_astrometric] := '✓';
      end;
    end;{check for astrometric solutions}
  end;{for loop for astrometric solving }
  {astrometric calibration}

  if ((refresh_solutions) or (esc_pressed{stop})) then
  begin
    mainwindow.Memo1.Text := memo2_text;{restore fits header}
    mainwindow.memo1.Visible := True;{Show old header again}
    Screen.Cursor := crDefault;{back to normal }
    if refresh_solutions then memo2_message('Ready')
    else
      memo2_message('Stopped, ESC pressed.');
    exit;
  end;

  outliers := nil;
  stepnr := 0;
  init := False;

  setlength(starlistpack, listview7.items.Count);
  {to store found stars for each image. Used for finding outliers}
  for c := 0 to listview7.items.Count - 1 do starlistpack[c].Height := 0;
  {use as marker for filled}

  memo2_message('Click on variable, Check and 3 stars(pink marker) to record magnitudes in the photometry list.');
  repeat
    setlength(starVar, listview7.items.Count);
    setlength(starCheck, listview7.items.Count);
    {number of stars could fluctuate so set maximum space each loop}
    setlength(starThree, listview7.items.Count);
    countVar := 0;
    countCheck := 0;
    countThree := 0;
    stepnr := stepnr + 1; {first step is nr 1}
    for c := 0 to listview7.items.Count - 1 do
    begin
      if ((esc_pressed = False) and (listview7.Items.item[c].Checked)) then
      begin
        listview7.Selected := nil; {remove any selection}
        listview7.ItemIndex := c;
        {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview7.Items[c].MakeVisible(False);{scroll to selected item}

        filename2 := listview7.items[c].Caption;
        mainwindow.Caption := filename2;

        Application.ProcessMessages;

        if starlistpack = nil then
        begin
          nil_all;
          exit;
        end;

        {load image}
        if ((esc_pressed) or (load_fits(filename2, True {light}, True,
          True {update memo}, 0, head, img_loaded) = False)) then
        begin
          esc_pressed := True;
          nil_all;
          exit;
        end;

        use_histogram(img_loaded, True {update}); {plot histogram, set sliders}

        if ((stepnr = 1) and ((pos('F', head.calstat) = 0) or (head.naxis3 > 1))) then
        begin
          if warned = False then
          begin
            if pos('F', head.calstat) = 0 then
              memo2_message(
                '█ █ █ █ █ █ Warning: Image not calibrated with a flat field (keyword CALSTAT). Absolute photometric accuracy will be lower. Calibrate images first using "calibrate only" option in stack menu. █ █ █ █ █ █');
            if head.naxis3 > 1 then
              memo2_message(
                '█ █ █ █ █ █ Warning: Colour image!! Absolute photometric accuracy will be lower. Process only raw images. Set bayer pattern correctly in tab "Stack method" and extract the green pixels in tab photometry. █ █ █ █ █ █');
          end;
          warned := True;{only one message}
          listview7.Items.item[c].subitems.Strings[P_photometric] := 'Poor';
        end
        else
        begin
          listview7.Items.item[c].subitems.Strings[P_photometric] := '✓';
        end;

        if starlistpack = nil then  {should not happen but it happens?}
        begin
          nil_all;
          exit;
        end;
        if starlistpack[c].Height = 0 then {not filled with data}
        begin
          if apert <> 0 then {aperture<>auto}
          begin
            analyse_image(img_loaded, head, 30, False {report}, hfd_counter, bck, hfd_med);
            {find background, number of stars, median HFD}
            if hfd_med <> 0 then
            begin
              head.mzero_radius := hfd_med * apert / 2;{radius}
              annulus_radius := min(50, round(hfd_med * annul / 2) - 1);
              {radius   -rs ..0..+rs, Limit to 50 to prevent runtime errors}
            end
            else
              head.mzero_radius := 99;{radius for measuring aperture}
          end
          else{auto}
          begin
            head.mzero_radius := 99;{radius for measuring using a small aperture}
            annulus_radius := 14;{annulus radius}
          end;

          {calibrate using POINT SOURCE calibration using hfd_med found earlier!!!}
          plot_and_measure_stars(True {calibration}, False {plot stars},True{report lim magnitude}); {calibrate. Downloaded database will be reused if in same area}

          //icon for used database passband. Database selection could be in auto mode so do this after calibration
          if head.passband_database='BP' then database_col:=4 //gray
          else
          if head.passband_database='R' then database_col:=24 //Cousins-R
          else
          if head.passband_database='V' then database_col:=1 //green
          else
          if head.passband_database='B' then database_col:=2 //blue icon
          else
          if head.passband_database='SI' then database_col:=21 //SDSS-i red/infrared
          else
          if head.passband_database='SR' then database_col:=22 //SDSS-r red/orange
          else
          if head.passband_database='SG' then database_col:=23 //SDSS-g blue/green
          else
          database_col:=-1; // unknown. Should not happen
          ListView7.Items.item[c].SubitemImages[P_magn1]:= database_col ; //show selected database passband

          listview7.Items.item[c].subitems.Strings[p_limmagn]:= floattostrF(magn_limit, FFgeneral, 4, 2);

          if head.mzero <> 0 then
          begin
            measure_magnitudes(annulus_radius,0,0,head.width-1,head.height-1, False {deep}, starlistx); {analyse}
            starlistpack[c].starlist := starlistX;
            {store found stars in memory for finding outlier later}
            starlistpack[c].Width :=head.Width;
            starlistpack[c].Height:=head.Height;
            starlistpack[c].mzero :=head.mzero;
          end
          else
            starlistpack[c].Height := 0; {mark as not valid measurement}
        end;


        setlength(img_temp, head.naxis3, head.Width, head.Height);{new size}

        {standard aligned blink}
        if init = False then {init}
        begin
          initialise_var1;
          {set variables correct for astrometric solution calculation. Use first file as reference and header "head"}

          head_ref := head;{backup solution for deepsky annotation}

          sensor_coordinates_to_celestial(shape_fitsX, shape_fitsY,
            rax1, decx1 {fitsX, Y to ra,dec});
          abbreviation_var_IAU := prepare_IAU_designation(rax1, decx1);

          sensor_coordinates_to_celestial(shape_fitsX2, shape_fitsY2,
            {var}   rax2, decx2 {position});
          name_check_iau := prepare_IAU_designation(rax2, decx2);

          sensor_coordinates_to_celestial(shape_fitsX3, shape_fitsY3,
            rax3, decx3 {fitsX, Y to ra,dec});

          init := True;
        end;

        mainwindow.image1.Canvas.Pen.Mode := pmMerge;
        mainwindow.image1.Canvas.Pen.Width := 1;{thickness lines}
        mainwindow.image1.Canvas.Pen.Color := clRed;
        mainwindow.image1.Canvas.Pen.Cosmetic := False; {gives better dotted lines}

        mainwindow.image1.Canvas.brush.Style := bsClear;
        mainwindow.image1.Canvas.font.color := clyellow;
        mainwindow.image1.Canvas.font.size := 10;
        //round(max(10,8*head.height/image1.height));{adapt font to image dimensions}

        {measure the three stars selected by the mouse in the ORIGINAL IMAGE}
        listview7.Items.item[c].subitems.Strings[P_magn1] := ''; {MAGN, always blank}
        listview7.Items.item[c].subitems.Strings[P_magn2] := ''; {MAGN, always blank}
        listview7.Items.item[c].subitems.Strings[P_magn3] := ''; {MAGN, always blank}

        if starlistpack[c].mzero <> 0 then {valid flux calibration}
        begin // do var star
          if mainwindow.shape_alignment_marker1.Visible then
          begin
            adu_e := retrieve_ADU_to_e_unbinned(head.egain);
            //Used for SNR calculation in procedure HFD. Factor for unbinned files. Result is zero when calculating in e- is not activated in the statusbar popup menu. Then in procedure HFD the SNR is calculated using ADU's only.
            mainwindow.image1.Canvas.Pen.Color := clRed;
            celestial_to_pixel(rax1, decx1, xn, yn); {ra,dec to fitsX,fitsY}
            astr := measure_star(xn, yn); {var star}
            listview7.Items.item[c].subitems.Strings[P_magn1] := astr;
            listview7.Items.item[c].subitems.Strings[P_snr] := IntToStr(round(snr));
            if ((astr <> '?') and (copy(astr, 1, 1) <> 'S')) then {Good star detected}
            begin
              starVar[countVar] := strtofloat2(astr);
              Inc(countVar);
            end;
          end;

          if mainwindow.shape_alignment_marker2.Visible then
          begin //do check star
            mainwindow.image1.Canvas.Pen.Color := clGreen;

            celestial_to_pixel(rax2, decx2, xn, yn); {ra,dec to fitsX,fitsY}
            astr := measure_star(xn, yn); {chk}
            listview7.Items.item[c].subitems.Strings[P_magn2] := astr;
            if ((astr <> '?') and (copy(astr, 1, 1) <> 'S')) then {Good star detected}
            begin
              starCheck[countCheck] := strtofloat2(astr);
              Inc(countCheck);
            end;
          end;

          if mainwindow.shape_alignment_marker3.Visible then
          begin //do star 3
            mainwindow.image1.Canvas.Pen.Color := clAqua; {star 3}

            celestial_to_pixel(rax3, decx3, xn, yn); {ra,dec to fitsX,fitsY}
            astr := measure_star(xn, yn); {star3}
            listview7.Items.item[c].subitems.Strings[P_magn3] := astr;
            if ((astr <> '?') and (copy(astr, 1, 1) <> 'S')) then {Good star detected}
            begin
              starThree[countThree] := strtofloat2(astr);
              Inc(countThree);
            end;
          end;
        end;


        {calculate vectors from astrometric solution to speed up}
        sincos(head.dec0, SIN_dec0, COS_dec0);
        {do this in advance since it is for each pixel the same}
        astrometric_to_vector;{convert astrometric solution to vectors}

        {shift, rotate to match lights}
        for fitsY := 1 to head.Height do
          for fitsX := 1 to head.Width do
          begin
            x_new := round(solution_vectorX[0] * (fitsx - 1) + solution_vectorX[1] *
              (fitsY - 1) + solution_vectorX[2]); {correction x:=aX+bY+c}
            y_new := round(solution_vectorY[0] * (fitsx - 1) + solution_vectorY[1] *
              (fitsY - 1) + solution_vectorY[2]); {correction y:=aX+bY+c}

            if ((x_new >= 0) and (x_new <= head.Width - 1) and (y_new >= 0) and
              (y_new <= head.Height - 1)) then
              for col := 0 to head.naxis3 - 1 do
                {all colors} img_temp[col, x_new, y_new] := img_loaded[col, fitsX - 1, fitsY - 1];
          end;

        img_loaded := nil;
        img_loaded := img_temp;


        {quick and dirty method to correct annotations for aligned lights}
        head.crpix1 := solution_vectorX[0] * (head.crpix1 - 1) + solution_vectorX[1] *
          (head.crpix2 - 1) + solution_vectorX[2];{correct for marker_position at ra_dec position}
        head.crpix2 := solution_vectorY[0] * (head.crpix1 - 1) + solution_vectorY[1] *
          (head.crpix2 - 1) + solution_vectorY[2];

        head.cd1_1 := abs(head.cd1_1) * sign(head_ref.CD1_1);
        head.cd1_2 := abs(head.cd1_2) * sign(head_ref.CD1_2);
        head.cd2_1 := abs(head.cd2_1) * sign(head_ref.CD2_1);
        head.cd2_2 := abs(head.cd2_2) * sign(head_ref.CD2_2);

        store_annotated := annotated;{store temporary annotated}
        annotated := False;{prevent annotations are plotted in plot_fits}
        plot_fits(mainwindow.image1, False {re_center}, True);
        annotated := store_annotated;{restore anotated value}
        if ((annotated) and (mainwindow.annotations_visible1.Checked)) then
          //header annotations
          plot_annotations(True {use solution vectors!!!!}, False);
        {corrected annotations in case a part of the lights are flipped in the alignment routien}

        mainwindow.image1.Canvas.Pen.Width := 1;{thickness lines}
        mainwindow.image1.Canvas.Pen.Cosmetic := False; {gives better dotted lines}
        mainwindow.image1.Canvas.Pen.style := psSolid;

        mainwindow.image1.Canvas.brush.Style := bsClear;
        mainwindow.image1.Canvas.font.color := clyellow;
        mainwindow.image1.Canvas.font.size := 10;
        //round(max(10,8*head.height/image1.height));{adapt font to image dimensions}


        {plot the aperture and annulus}
        if starlistpack[c].mzero <> 0 then {valid flux calibration}
        begin
          mainwindow.image1.Canvas.Pen.mode := pmCopy;

          if mainwindow.shape_alignment_marker1.Visible then
          begin
            mainwindow.image1.Canvas.Pen.Color := clRed;
            plot_annulus(round(shape_fitsX), round(shape_fitsY));
          end;

          if mainwindow.shape_alignment_marker2.Visible then
          begin
            mainwindow.image1.Canvas.Pen.Color := clGreen;
            plot_annulus(round(shape_fitsX2), round(shape_fitsY2));
          end;
          if mainwindow.shape_alignment_marker3.Visible then
          begin
            mainwindow.image1.Canvas.Pen.Color := clAqua; {star 3}
            plot_annulus(round(shape_fitsX3), round(shape_fitsY3));
          end;
        end;

        mainwindow.image1.Canvas.Pen.Mode := pmMerge;
        mainwindow.image1.Canvas.Pen.Width :=
          round(1 + head.Height / mainwindow.image1.Height);{thickness lines}
        mainwindow.image1.Canvas.Pen.style := psSolid;
        mainwindow.image1.Canvas.Pen.Color := $000050; {dark red}
        if starlistpack[c].Height <> 0 then {valid measurement}
          for i := 0 to length(starlistpack[c].starlist[0]) - 2 do
          begin
            size := round(5 * starlistpack[c].starlist[2, i]);{5*hfd}
            x_new := round(solution_vectorX[0] * (starlistpack[c].starlist[0, i]) +
              solution_vectorX[1] * (starlistpack[c].starlist[1, i]) + solution_vectorX[2]);
            {correction x:=aX+bY+c}
            y_new := round(solution_vectorY[0] * (starlistpack[c].starlist[0, i]) +
              solution_vectorY[1] * (starlistpack[c].starlist[1, i]) + solution_vectorY[2]);
            {correction y:=aX+bY+c}

            if flipvertical = False then  starY := (head.Height - y_new)
            else
              starY := (y_new);
            if Fliphorizontal then starX := (head.Width - x_new)
            else
              starX := (x_new);

            mainwindow.image1.Canvas.Rectangle(starX - size, starY - size,
            starX + size, starY + size);{indicate hfd with rectangle}
            magn:=starlistpack[c].MZERO - ln(starlistpack[c].starlist[3, i]{flux})*2.5/ln(10);

            mainwindow.image1.Canvas.textout(starX + size, starY - size,inttostr(round(magn * 10)) );{add magnitude as text}
          end;{measure marked stars}


        {plot outliers (variable stars)}
        if outliers <> nil then plot_outliers;

        if annotate_mode1.ItemIndex > 0 then
          mainwindow.variable_star_annotation1Click(nil);
      end;{find star magnitudes}
    end;
    if ((stepnr = 1) and (countvar > 4)) then {do it once after one cycle finished}
    begin
      if mainwindow.noise_in_electron1.Checked then
        //report SNR info based on the last checked file.
        memo2_message('SNR reporting based on EGAIN= ' +
          head.egain + '. Additional factor for unbinned images ' + IntToStr(egain_extra_factor))
      else
        memo2_message(
          'SNR reporting based on ADUs. Can be changed to electrons and factors can be set using the popup menu of the viewer statusbar');

      find_star_outliers(strtofloat2(mark_outliers_upto1.Text), outliers);
      if outliers <> nil then plot_outliers;
    end;

    {do statistics}
    if countVar >= 4 then
    begin
      mad_median(starVar, countVar{length},{var}madVar, medianVar);
      {calculate mad and median without modifying the data}
      memo2_message('Var star, median: ' + floattostrf(medianVar,
        ffgeneral, 4, 4) + ', σ: ' + floattostrf(1.4826 * madVar  {1.0*sigma}, ffgeneral, 4, 4));
    end
    else
      madVar := 0;

    if countCheck >= 4 then
    begin
      mad_median(starCheck, countCheck{counter},{var}madCheck, medianCheck);
      {calculate mad and median without modifying the data}
      memo2_message('Check star, median: ' + floattostrf(medianCheck,
        ffgeneral, 4, 4) + ', σ: ' + floattostrf(1.4826 * madCheck  {1.0*sigma}, ffgeneral, 4, 4));
    end
    else
      madCheck := 0;
    if countThree > 4 then
    begin
      mad_median(starThree, countThree{counter},{var}madThree, medianThree);
      {calculate mad and median without modifying the data}
      memo2_message('3 star, median: ' + floattostrf(medianThree,
        ffgeneral, 4, 4) + ', σ: ' + floattostrf(1.4826 * madThree  {1.0*sigma}, ffgeneral, 4, 4));
    end
    else
      madThree := 0;

    photometry_stdev := madCheck * 1.4826;{mad to standard deviation}

    plot_graph; {aavso report}
  until ((esc_pressed) or (Sender <> photometry_repeat1 {single run}));


  nil_all;{nil all arrays and restore cursor}
end;


procedure Tstackmenu1.saturation_tolerance1Change(Sender: TObject);
begin
  stackmenu1.rainbow_panel1.refresh;
  {plot colour disk in on paint event. Onpaint is required for MacOS}
end;

procedure Tstackmenu1.save_result1Click(Sender: TObject);
var
  dot_pos: integer;
begin
  //  if pos(' original',filename2)=0 then
  begin
    dot_pos := length(filename2);
    repeat
      Dec(dot_pos);
    until ((filename2[dot_pos] = '.') or (dot_pos <= 1));
    insert(' equalised', filename2, dot_pos);
  end;
  save_fits(img_loaded, filename2, -32, False);
  if fileexists(filename2) then
  begin
    saved1.Caption := 'Saved';
    report_results(object_name, '', 0, -1{no icon});{report result in tab results}
  end
  else
    saved1.Caption := '';

  {save result, step 6}
  undo_button_equalise_background1.Enabled := False;
  undo_button_equalise_background1.Caption := '';
  go_step_two1.Enabled := False;
end;


procedure Tstackmenu1.save_settings_extra_button1Click(Sender: TObject);
begin
  save_settings2;{too many lost selected files . so first save settings}
end;


procedure star_smooth(img: image_array; x1, y1: integer);
const
  max_ri = 50; //sqrt(sqr(rs+rs)+sqr(rs+rs))+1;
var
  x2, y2, rs, i, j, k, counter, col, drop_off: integer;
  val, bg_average, rgb, luminance: double;
  color, bg, bg_standard_deviation: array[0..2] of double;
  value_histogram: array [0..max_ri] of double;
begin
  rs := 14;{14 is test box of 28, HFD maximum is about 28}

  if ((x1 - rs - 4 <= 0) or (x1 + rs + 4 >= head.Width - 1) or (y1 - rs - 4 <= 0) or
    (y1 + rs + 4 >= head.Height - 1)) then
  begin
    exit;
  end;

  try
    for col := 0 to 2 do
    begin
      counter := 0;
      bg_average := 0;
      for i := -rs - 4 to rs + 4 do {calculate mean at square boundaries of detection box}
        for j := -rs - 4 to rs + 4 do
        begin
          if ((abs(i) > rs) and (abs(j) > rs)) then {measure only outside the box}
          begin
            val := img[col, x1 + i, y1 + j];
            if val > 0 then
            begin
              bg_average := bg_average + val;
              Inc(counter);
            end;
          end;
        end;
      bg_average := bg_average / (counter + 0.0001); {mean value background}
      bg[col] := bg_average;
    end;

    for col := 0 to 2 do
    begin
      counter := 0;
      bg_standard_deviation[col] := 0;
      for i := -rs - 4 to rs + 4 do
        {calculate standard deviation background at the square boundaries of detection box}
        for j := -rs - 4 to rs + 4 do
        begin
          if ((abs(i) > rs) and (abs(j) > rs)) then {measure only outside the box}
          begin
            val := img[col, x1 + i, y1 + j];
            if ((val <= 2 * bg[col]) and (val > 0)) then {not an outlier}
            begin
              bg_standard_deviation[col] := bg_standard_deviation[col] + sqr(bg[col] - val);
              Inc(counter);
            end;
          end;
        end;
      bg_standard_deviation[col] := sqrt(bg_standard_deviation[col] / (counter + 0.0001));
      {standard deviation in background}
    end;

    for k := 0 to max_ri do {calculate distance to average value histogram}
    begin
      val := 0;
      counter := 0;
      for i := -k to k do {square around center}
      begin
        val := val + img[col, x1 + i, y1 + k];
        val := val + img[col, x1 + i, y1 - k];
        val := val + img[col, x1 + k, y1 + i];
        val := val + img[col, x1 - k, y1 + i];
        Inc(counter, 4);
      end;
      value_histogram[k] := val / counter;{add average value for distance k from center}
    end;

    k := 0;
    repeat  {find slow down star value from center}
      Inc(k);
    until ((value_histogram[k - 1] < 1.3 * value_histogram[k]) or (k >= max_ri));
    drop_off := k;

    // Get average star colour
    for col := 0 to 2 do
    begin
      color[col] := 0;
      for i := -rs to rs do
        for j := -rs to rs do
        begin
          x2 := x1 + i;
          y2 := y1 + j;
          if sqr(drop_off) > i * i + j * j then {within star}
          begin
            val := img[col, x2, y2] - bg[col];
            if val < 60000 {not saturated} then
              color[col] := color[col] + img[col, x2, y2] - bg[col];
            {if written in separate term it would be 20% faster but having fixed steps}

          end;
        end;
    end;

    // apply average star colour on pixels
    rgb := color[0] + color[1] + color[2] + 0.00001; {0.00001, prevent dividing by zero}

    for i := -rs to rs do
      for j := -rs to rs do
      begin
        x2 := x1 + i;
        y2 := y1 + j;
        if sqr(drop_off) > i * i + j * j then {within star}
        begin
          luminance := (img[0, x2, y2] - bg[0] + img[1, x2, y2] -
            bg[1] + img[2, x2, y2] - bg[2]) / 3;
          img[0, x2, y2] := bg[0] + luminance * color[0] / rgb;
          img[1, x2, y2] := bg[1] + luminance * color[1] / rgb;
          img[2, x2, y2] := bg[2] + luminance * color[2] / rgb;

          img_temp[0, x2, y2] := 1; {mark as processed}
        end;
      end;
  except
  end;
end;


procedure smart_colour_smooth(var img: image_array; wide, sd: double;  preserve_r_nebula, measurehist: boolean);
{Bright star colour smooth. Combine color values of wide x wide pixels, keep luminance intact}
var
  fitsX, fitsY, x, y, step, x2, y2, Count, width5, height5: integer;
  img_temp2: image_array;
  flux, red, green, blue, rgb, r, g, b, sqr_dist, strongest_colour_local,
  top, bg, r2, g2, b2, {noise_level1,} peak, bgR2, bgB2, bgG2, highest_colour, lumr: single;
  bgR, bgB, bgG, star_level: double;
  copydata, red_nebula: boolean;
  bckR,bckG,bckB : Tbackground;
begin
  if length(img) < 3 then exit;{not a three colour image}

  width5 := Length(img[0]);    {width}
  height5 := Length(img[0][0]); {height}

  setlength(img_temp2, 3, width5, height5);{set length of image array}

  step := round(wide) div 2;

  get_background(0, img, measurehist {hist}, True  {noise level},bckR);{calculate red background, noise_level and star_level}
  bgR:=bckR.backgr;

  get_background(1, img, measurehist {hist}, True{noise level},bckG);{calculate green background, noise_level and star_level}
  bgG:=bckG.backgr;

  get_background(2, img, measurehist {hist}, True {noise level},bckB);{calculate blue background, noise_level and star_level}
  bgB:=bckB.backgr;





  star_level:=max(bckR.star_level,max(bckG.star_level,bckB.star_level));

  bg := (bgR + bgG + bgB) / 3; {average background}

  for fitsY := 0 to height5 - 1 do
    for fitsX := 0 to width5 - 1 do
    begin
      red := 0;
      green := 0;
      blue := 0;
      Count := 0;
      peak := 0;
      bgR2 := 65535;
      bgG2 := 65535;
      bgB2 := 65535;

      r2 := img[0, fitsX, fitsY] - bgR;
      g2 := img[1, fitsX, fitsY] - bgG;
      b2 := img[2, fitsX, fitsY] - bgB;


      if ((r2 > sd * bckR.noise_level) or (g2 > sd * bckG.noise_level) or (b2 > sd * bckB.noise_level)) then
        {some relative flux}
      begin
        for y := -step to step do
          for x := -step to step do
          begin
            x2 := fitsX + x;
            y2 := fitsY + y;

            if ((x2 >= 0) and (x2 < width5) and (y2 >= 0) and (y2 < height5)) then {within image}
            begin
              sqr_dist := x * x + y * y;
              if sqr_dist <= step * step then {circle only}
              begin
                r := img[0, x2, y2];
                G := img[1, x2, y2];
                B := img[2, x2, y2];

                {find peak value}
                if r > peak then peak := r;
                if g > peak then peak := g;
                if b > peak then peak := b;
                {find lowest values. In some cases the background nebula}
                if r < bgR2 then bgR2 := r;
                if g < bgG2 then bgG2 := g;
                if b < bgB2 then bgB2 := b;

                if ((r < 60000) and (g < 60000) and (b < 60000)) then
                  {no saturation, ignore saturated pixels}
                begin
                  begin
                    if (r - bgR) > 0 then
                      red := red + (r - bgR);
                    {level >0 otherwise centre of M31 get yellow circle}
                    if (g - bgG) > 0 then green := green + (g - bgG);
                    if (b - bgB) > 0 then blue := blue + (b - bgB);
                    Inc(Count);
                  end;
                end;
              end;
            end;
          end;
      end;

      copydata := True;
      rgb := 0;
      if Count >= 1 then
      begin

        red := red / Count;{scale using the number of data points=count}
        green := green / Count;
        blue := blue / Count;

        if peak > star_level then {star level very close}
        begin
          highest_colour := max(r2, max(g2, b2));
          if preserve_r_nebula then
            red_nebula := ((highest_colour = r2) and (r2 - (bgR2 - bgR) < 150){not the star} and
              (bgR2 - bgR > 3 * bckR.noise_level))
          else
            red_nebula := False;

          if red_nebula = False then
          begin
            if red < blue * 1.06 then{>6000k}
              green := max(green, 0.6604 * red + 0.3215 * blue);
            {prevent purple stars, purple stars are physical not possible. Emperical formula calculated from colour table http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html}

            flux := r2 + g2 + b2;//pixel flux
            rgb := red + green + blue + 0.00001;
            {average pixel flux, 0.00001, prevent dividing by zero}

            strongest_colour_local := max(red, max(green, blue));
            top := bg + strongest_colour_local * (flux / rgb);
            {calculate the highest colour value}
            if top >= 65534.99 then
              flux := flux - (top - 65534.99) * rgb / strongest_colour_local;{prevent values above 65535}

            lumr := flux / rgb;
            img_temp2[0, fitsX, fitsY] := bg + red * lumr;
            //usg average bg and not bgR. See "if copydata" below.
            img_temp2[1, fitsX, fitsY] := bg + green * lumr;
            img_temp2[2, fitsX, fitsY] := bg + blue * lumr;

            copydata := False;{data is already copied}

          end;
        end;
      end;
      if copydata then {keep original data but adjust zero level}
      begin
        img_temp2[0, fitsX, fitsY] := max(0, bg + r2);
        {copy data, but equalise background levels by using the same background value}
        img_temp2[1, fitsX, fitsY] := max(0, bg + g2);
        img_temp2[2, fitsX, fitsY] := max(0, bg + b2);
      end;

    end;
  img := img_temp2;{copy the array}
  img_temp2 := nil;
end;


procedure green_purple_filter(var img: image_array);
{Balances RGB to remove green and purple. For e.g. Hubble palette}
var
  fitsX, fitsY: integer;
  r2, g2, b2, lum, ratio: double;
begin
  if length(img) < 3 then exit;{not a three colour image}

  for fitsY := 0 to head.Height - 1 do
    for fitsX := 0 to head.Width - 1 do
    begin
      r2 := img[0, fitsX, fitsY];
      g2 := img[1, fitsX, fitsY];
      b2 := img[2, fitsX, fitsY];


      if ((g2 > r2) and (g2 > b2)) then
      begin
        lum := r2 + g2 + b2;
        if r2 >= b2 then {red stronger then blue}
        begin
          ratio := min(r2 / max(b2, 0.001), 30);
          r2 := lum * ratio / (ratio + ratio + 1);
          g2 := r2;
          b2 := lum * 1 / (ratio + ratio + 1);
        end
        else
        begin {blue stronger then red}
          ratio := min(b2 / max(r2, 0.001), 30);
          b2 := lum * ratio / (ratio + ratio + 1);
          g2 := b2;
          r2 := lum * 1 / (ratio + ratio + 1);
        end;
        img[0, fitsX, fitsY] := r2;
        img[1, fitsX, fitsY] := g2;
        img[2, fitsX, fitsY] := b2;
      end;


      if ((g2 < r2) and (g2 < b2)) then  {to weak green, purple background}
      begin
        lum := r2 + g2 + b2;
        if r2 >= b2 then {red stronger then blue}
        begin
          ratio := min(r2 / max(b2, 0.001), 30);
          r2 := lum / (1 + 1 + ratio);
          g2 := r2;
          b2 := lum * ratio / (1 + 1 + ratio);
        end
        else
        begin {blue stronger then red}
          ratio := min(b2 / max(r2, 0.001), 30);
          b2 := lum / (1 + 1 + ratio);
          g2 := b2;
          r2 := lum * ratio / (1 + 1 + ratio);
        end;
        img[0, fitsX, fitsY] := r2;
        img[1, fitsX, fitsY] := g2;
        img[2, fitsX, fitsY] := b2;
      end;
    end;
end;


procedure Tstackmenu1.smart_colour_smooth_button1Click(Sender: TObject);
begin
  if Length(img_loaded) < 3 then
  begin
    memo2_message('Error, no three colour image loaded!');
    exit;
  end;
  memo2_message('Start colour smooth.');
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img;

  smart_colour_smooth(img_loaded, strtofloat2(smart_smooth_width1.Text), strtofloat2(smart_colour_sd1.Text), preserve_red_nebula1.Checked, False);

  plot_fits(mainwindow.image1, False, True);{plot real}

  Screen.Cursor := crDefault;
  memo2_message('Ready colour smooth.');
end;


procedure Tstackmenu1.classify_filter1Click(Sender: TObject);
begin
  stackmenu1.stack_method1Change(nil); {update several things including raw_box1.enabled:=((mosa=false) and filter_groupbox1.enabled}
end;


procedure Tstackmenu1.apply_get_background1Click(Sender: TObject);
var
  radius: integer;
begin
  if head.naxis <> 0 then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    backup_img; {move copy to img_backup}
    try
      radius := StrToInt(extract_background_box_size1.Text);
    except
    end;
    apply_most_common(img_backup[index_backup].img, img_loaded, radius);  {apply most common filter on first array and place result in second array}
    plot_fits(mainwindow.image1, True, True);{plot real}
    Screen.Cursor := crDefault;
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


procedure Tstackmenu1.list_to_clipboard1Click(Sender: TObject);
{copy seleced lines to clipboard}
var
  index, c: integer;
  info: string;
  lv: tlistview;
begin
  info := '';
  if Sender = list_to_clipboard9 then lv := listview9
  else
  if Sender = list_to_clipboard8 then lv := listview8
  else
  if Sender = list_to_clipboard7 then lv := listview7
  else
  if Sender = list_to_clipboard6 then lv := listview6
  else
  if Sender = list_to_clipboard1 then lv := listview1
  else
  begin
    beep;
    exit;
  end;

  {get column names}
  for c := 0 to lv.Items[0].SubItems.Count - 1 do
    try
      info := info + lv.columns[c].Caption + #9;
    except
      info := info + 'Error' + #9;
    end;
  info := info + slinebreak;

  {get data}
  for index := 0 to lv.items.Count - 1 do
  begin
    if lv.Items[index].Selected then
    begin
      info := info + lv.items[index].Caption;
      {get sub items}
      for c := 0 to lv.Items[index].SubItems.Count - 1 do
        try
          info := info + #9 + lv.Items.item[index].subitems.Strings[c];
        except
          info := info + #9 + 'Error';
        end;
      info := info + slinebreak;
    end;
  end;
  Clipboard.AsText := info;
end;


procedure Tstackmenu1.selectall1Click(Sender: TObject);
begin
  if Sender = selectall1 then
  begin
    listview1.selectall;
    listview1.SetFocus;{set focus for next ctrl-C. Somehow it is lost}
  end;
  if Sender = selectall2 then
  begin
    listview2.selectall;
    listview2.SetFocus;
  end;
  if Sender = selectall3 then
  begin
    listview3.selectall;
    listview3.SetFocus;
  end;
  if Sender = selectall4 then
  begin
    listview4.selectall;
    listview4.SetFocus;
  end;
  if Sender = selectall5 then
  begin
    listview5.selectall;
    listview5.SetFocus;
  end;

  if Sender = selectall6 then
  begin
    listview6.selectall;
    listview6.SetFocus;
  end;
  if Sender = selectall7 then
  begin
    listview7.selectall;
    listview7.SetFocus;
  end;
  if Sender = selectall8 then
  begin
    listview8.selectall;
    listview8.SetFocus;
  end;
  if Sender = selectall9 then
  begin
    listview9.selectall;
    listview9.SetFocus;
  end;
end;

procedure remove_background(var img: image_array);
var
  fitsX, fitsY: integer;
  luminance, red, green, blue: double;
begin
  if length(img) < 3 then exit;{not a three colour image}

  for fitsY := 2 to head.Height - 1 - 2 do
    for fitsX := 2 to head.Width - 1 - 2 do
    begin

      red := img[0, fitsX, fitsY];
      green := img[1, fitsX, fitsY];
      blue := img[2, fitsX, fitsY];

      luminance := red + blue + green + 0.00001; {0.00001, prevent dividing by zero}

      img[0, fitsX, fitsY] := red / luminance;
      img[1, fitsX, fitsY] := green / luminance;
      img[2, fitsX, fitsY] := blue / luminance;
    end;

end;


procedure Tstackmenu1.apply_remove_background_colour1Click(Sender: TObject);
var
  fitsX, fitsY: integer;
  red, green, blue, signal_R,
  signal_G, signal_B, sigma, lumn: double;
  bckR,bckG,bckB : Tbackground;
begin
  if head.naxis3 < 3 then exit;{prevent run time error mono lights}

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  backup_img;
  sigma := strtofloat2(sigma_decolour1.Text);{standard deviation factor used}

  get_background(1, img_loaded, True {hist}, True {noise level},bckG);{calculate background and noise_level}
  get_background(2, img_loaded, True {hist}, True {noise level},bckB);{calculate background and noise_level}
  {red at last since all brigthness/contrast display is based on red}
  get_background(0, img_loaded, True {hist}, True {noise level}, bckR);{calculate background and noise_level}



  for fitsY := 0 to head.Height - 1 do
    for fitsX := 0 to head.Width - 1 do
    begin
      red := img_loaded[0, fitsX, fitsY];
      green := img_loaded[1, fitsX, fitsY];
      blue := img_loaded[2, fitsX, fitsY];

      if ((red - bckR.backgr < sigma * bckR.noise_level) and (green - bckG.backgr < sigma * bckG.noise_level) and (blue - bckB.backgr < sigma * bckB.noise_level)) then {low luminance signal}
      begin {distribute the colour to luminance}
        signal_R := red - bckR.backgr;
        signal_G := green - bckG.backgr;
        signal_B := blue - bckB.backgr;
        lumn := (signal_R + signal_G + signal_B) / 3;{make mono}
        red := bckR.backgr + lumn;
        green := bckG.backgr + lumn;
        blue := bckB.backgr + lumn;
      end;
      img_loaded[0, fitsX, fitsY] := red;
      img_loaded[1, fitsX, fitsY] := green;
      img_loaded[2, fitsX, fitsY] := blue;
    end;
  plot_fits(mainwindow.image1, False, True);{plot}
  Screen.cursor := crDefault;
end;

procedure Tstackmenu1.reset_factors1Click(Sender: TObject);
begin
  add_valueR1.Text := '0.0';
  add_valueG1.Text := '0.0';
  add_valueB1.Text := '0.0';

  edit_noise1.Text := '0.0';

  multiply_red1.Text := '1.0';
  multiply_green1.Text := '1.0';
  multiply_blue1.Text := '1.0';

end;


procedure Tstackmenu1.search_fov1Change(Sender: TObject);
begin
  fov_specified := True;{user has entered a FOV manually}
end;


procedure Tstackmenu1.solve_and_annotate1Change(Sender: TObject);
begin
  update_annotation1.Enabled := solve_and_annotate1.Checked;{update menu}
end;


procedure Tstackmenu1.SpeedButton2Click(Sender: TObject);
begin
  lat_default := InputBox('Default observer location:','Enter the default observer latitude in degrees [DD.DDD or DD MM]', lat_default);
  long_default := InputBox('Default observer location:','Enter the default observer longitude in degrees. East is positive, West is negative [DDD.DDD or DD MM]',long_default);
  if length(long_default) > 0 then save_settings2;
end;


procedure Tstackmenu1.stack_method1DropDown(Sender: TObject);
begin
  tcombobox(sender).ItemWidth:=round(stack_method1.width*1.5);
end;


procedure Tstackmenu1.star_database1Change(Sender: TObject);
begin
  close_star_database;{Close the tfilestream. Otherwise the first search doesn't work always for D databasee. 2023}
end;


procedure Tstackmenu1.star_database1DropDown(Sender: TObject);
var
  SearchRec: TSearchRec;
  s: string;
begin
  with stackmenu1 do
  begin
    star_database1.items.Clear;
    if SysUtils.FindFirst(database_path + '*0101.*', faAnyFile, SearchRec) = 0 then
    begin
      repeat
        s := uppercase(copy(searchrec.Name, 1, 3));
        star_database1.items.add(s);
      until SysUtils.FindNext(SearchRec) <> 0;
    end;
    SysUtils.FindClose(SearchRec);
    star_database1.items.add('auto');
  end;
  head.mzero := 0;{reset flux calibration. Required if V50 is selected instead of D50}
end;



procedure Tstackmenu1.apply_box_filter2Click(Sender: TObject);
begin
  if Length(img_loaded) = 0 then
  begin
    memo2_message('Error, no image in viewer loaded!');
    exit;
  end;
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img;

  box_blur(1 {nr of colors}, 2, img_loaded);

  use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1, False, True);{plot real}

  Screen.Cursor := crDefault;
end;


procedure Tstackmenu1.tab_blink1Show(Sender: TObject);
begin
  stackmenu1.annotations_visible2.checked:=mainwindow.annotations_visible1.checked; {follow in stack menu}
end;


procedure Tstackmenu1.tab_monitoring1Show(Sender: TObject);
begin
  target_group1.Enabled := stackmenu1.monitor_action1.ItemIndex = 4;

  {latitude, longitude}
  stackmenu1.monitor_latitude1.Text := lat_default;
  stackmenu1.monitor_longitude1.Text := long_default;
end;


procedure Tstackmenu1.tab_photometry1Show(Sender: TObject);
begin
  stackmenu1.flux_aperture1change(nil);{photometry, disable annulus_radius1 if mode max flux}
end;


procedure Tstackmenu1.tab_Pixelmath1Show(Sender: TObject);
begin
  hue_fuzziness1Change(nil);{pixelmath 1, show position}
end;

procedure Tstackmenu1.tab_Pixelmath2Show(Sender: TObject);
begin
  stackmenu1.width_UpDown1.position :=
    round(head.Width * strtofloat2(stackmenu1.resize_factor1.Caption));
end;

procedure Tstackmenu1.tab_stackmethod1Show(Sender: TObject);
begin
  stackmenu1.stack_method1Change(nil);
   {update several things including raw_box1.enabled:=((mosa=false) and filter_groupbox1.enabled}
end;


procedure Tstackmenu1.test_osc_normalise_filter1Click(Sender: TObject);
begin
  if Length(img_loaded) = 0 then
  begin
    memo2_message('Error, no image in viewer loaded!');
    exit;
  end;
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img;

  check_pattern_filter(img_loaded);

  use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1, False, True);{plot real}

  Screen.Cursor := crDefault;
end;


procedure Tstackmenu1.analyseblink1Click(Sender: TObject);
begin
  analyse_listview(listview6, True {light}, False {full fits}, False{refresh});
  listview6.alphasort; {sort on time}

  {$ifdef mswindows}
  {$else} {unix}
  {temporary fix for CustomDraw not called}
   stackmenu1.nr_total_blink1.Caption := IntToStr(listview6.items.Count);
  {$endif}
  {update counting info}

end;


procedure Tstackmenu1.annotate_mode1Change(Sender: TObject);
begin
  vsx := nil;//clear downloaded database
  vsp := nil;
end;


procedure Tstackmenu1.Annotations_visible2Click(Sender: TObject);
begin
  mainwindow.annotations_visible1.checked:=annotations_visible2.checked; {follow in main menu viewer}
  if head.naxis=0 then exit;
  if annotations_visible2.checked=false then  {clear screen}
    plot_fits(mainwindow.image1,false,true)
  else
    if annotated then plot_annotations(false {use solution vectors},false);
end;

procedure Tstackmenu1.apply_gaussian_blur_button2Click(Sender: TObject);
begin
  plot_fits(mainwindow.image1,false,true);//clear
  contour(img_loaded,head,strtofloat2(contour_gaussian1.text),strtofloat2(contour_sigma1.text));
end;

procedure Tstackmenu1.Button2Click(Sender: TObject);
begin
  wipe_streaks(img_loaded);
  plot_fits(mainwindow.image1,false,true);
end;

procedure Tstackmenu1.ClearButton1Click(Sender: TObject);
begin
  plot_fits(mainwindow.image1,false,true);
end;



procedure Tstackmenu1.photometric_calibration1Click(Sender: TObject);
var
  c: integer;
  fn, ff: string;
  success: boolean;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  esc_pressed := False;

  if listview7.items.Count > 0 then
  begin
    for c := 0 to listview7.items.Count - 1 do
      if listview7.Items[c].Selected then
      begin
        {scroll}
        //       listview7.Selected :=nil; {remove any selection}
        listview7.ItemIndex := c;
        {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview7.Items[c].MakeVisible(False);{scroll to selected item}
        application.ProcessMessages;
        if esc_pressed then
        begin
          Screen.Cursor := crDefault;
          exit;
        end;

        ff := ListView7.items[c].Caption;
        if fits_tiff_file_name(ff) = False then
        begin
          memo2_message('█ █ █ █ █ █ Can' + #39 +'t process this file type. First analyse file list to convert to FITS !! █ █ █ █ █ █');
          beep;
          exit;
        end;

        filename2:=ff;
        if load_fits(filename2,true {light},true,true {update memo},0,head,img_loaded) then {load a fits or Astro-TIFF file}

         // load_image(mainwindow.image1.Visible = False {recenter}, True {plot})       then
        begin
          head.mzero:=0; //force a new calibration
          if head.cd1_1<>0 then
          begin
            calibrate_photometry;
            if fits_file_name(filename2) then
              success := savefits_update_header(filename2)
            else
              success := save_tiff16_secure(img_loaded, filename2);{guarantee no file is lost}
            if success = False then
            begin
              ShowMessage('Write error !!' + filename2);
              Screen.Cursor := crDefault;
              exit;
            end;
          end
          else
          memo2_message('Can not calibrate '+filename2+'. Add first an astrometrical solution.');
        end;

      end;
  end;
  analyse_listview(listview7, True {light}, False {full fits}, True{refresh});
  {refresh list}
  Screen.Cursor := crDefault;  { Always restore to normal }
end;


procedure Tstackmenu1.refresh_astrometric_solutions1Click(Sender: TObject);
var
  c: integer;
  fn, ff: string;
  success: boolean;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  esc_pressed := False;

  if listview7.items.Count > 0 then
  begin
    for c := 0 to listview7.items.Count - 1 do
      if listview7.Items[c].Selected then
      begin
        {scroll}
        //       listview7.Selected :=nil; {remove any selection}
        listview7.ItemIndex := c;
        {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview7.Items[c].MakeVisible(False);{scroll to selected item}
        application.ProcessMessages;
        if esc_pressed then
        begin
          Screen.Cursor := crDefault;
          exit;
        end;

        listview7.Items.item[c].subitems.Strings[P_astrometric] := '';
        {clear astrometry marks}
        listview7.Items.item[c].subitems.Strings[P_photometric] := '';
        {clear photometry marks}
      end;
  end;
  Screen.Cursor := crDefault;  { Always restore to normal }
  stackmenu1.photometry_button1Click(Sender);{refresh astrometric solutions}
end;


procedure remove_stars;
var
  fitsX,fitsY,hfd_counter,position,x,y,x1,y1  : integer;
  star_fwhm,snr,flux,magnd, hfd_median,max_radius,
  backgrR,backgrG,backgrB,delta                           : double;
  img_temp3 :image_array;
  old_aperture : string;

const
   default=1000;


   procedure star_background(rs {radius},x1,y1 :integer);
   var
     backgroundR,backgroundG,backgroundB : array [0..1000] of double; {size =3*(2*PI()*(50+3)) assuming rs<=50}
     r1_square,r2_square,distance : double;
     r2,i,j,counter : integer;
   begin
     r1_square:=rs*rs;{square radius}
     r2:=rs+3 {annulus_width};
     r2_square:=r2*r2;
     try
       counter:=0;
       for i:=-r2 to r2 do {calculate the mean outside the the detection area}
       for j:=-r2 to r2 do
       begin
         if ((x1-r2>=0) and (x1+r2<=head.width-1) and
          (y1-r2>=0) and (y1+r2<=head.height-1) ) then

           distance:=i*i+j*j; {working with sqr(distance) is faster then applying sqrt}
           if ((distance>r1_square) and (distance<=r2_square)) then {annulus, circular area outside rs, typical one pixel wide}
           begin
             backgroundR[counter]:=img_loaded[0,x1+i,y1+j];
             if head.naxis3>1 then backgroundG[counter]:=img_loaded[1,x1+i,y1+j];
             if head.naxis3>2 then backgroundB[counter]:=img_loaded[2,x1+i,y1+j];
             inc(counter);
           end;
        end;
        if counter>2 then
        begin
          backgrR:=Smedian(backgroundR,counter);
          if head.naxis3>1 then backgrG:=Smedian(backgroundG,counter);
          if head.naxis3>2 then backgrB:=Smedian(backgroundB,counter);
        end;
     finally
     end;

   end;

begin
  old_aperture:=stackmenu1.flux_aperture1.text;
  stackmenu1.flux_aperture1.text:='max';//full flux is here required

  calibrate_photometry;

  stackmenu1.flux_aperture1.text:=old_aperture;


  if head.mzero=0 then
  begin
    beep;
    img_temp3:=nil;
    Screen.Cursor:=crDefault;
    exit;
  end;

  memo2_message('Passband setting: '+stackmenu1.reference_database1.text);


//  image1.Canvas.Pen.Mode := pmMerge;
//  image1.Canvas.Pen.width :=1;
//  image1.Canvas.brush.Style:=bsClear;
//  image1.Canvas.font.color:=clyellow;
//  image1.Canvas.font.name:='default';
//  image1.Canvas.font.size:=10;
//  mainwindow.image1.Canvas.Pen.Color := clred;


  setlength(img_temp3,1,head.width,head.height);{set size of image array}
  for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1  do
      img_temp3[0,fitsX,fitsY]:=default;{clear}
  plot_artificial_stars(img_temp3,head,magn_limit {measured});{create artificial image with database stars as pixels}

   analyse_image(img_loaded,head,10 {snr_min},false,hfd_counter,bck, hfd_median); {find background, number of stars, median HFD}

   backgrR:=bck.backgr;//defaults
   backgrG:=bck.backgr;
   backgrB:=bck.backgr;

   for fitsY:=0 to head.height-1 do
    for fitsX:=0 to head.width-1  do
    begin
      magnd:=img_temp3[0,fitsX,fitsY];
      if magnd<default then {a star from the database}
      begin
          star_background(round(4*hfd_median) {radius},fitsX,fitsY);//calculate background(s)
          flux:=power(10,0.4*(head.mzero-magnd/10));

          flux:=flux*1.1;//compensate for flux errors
          max_radius:=99999;

          for position:=0 to length(disk)-1 do //remove star flux
          begin
            begin
              x1:=disk[position,0]; // disk, disk positions starting from center moving outwards
              y1:=disk[position,1];
              x:=fitsX+x1; // disk, disk positions starting from center moving outwards
              y:=fitsY+y1;
              if ((x>=0) and (x<head.width) and (y>=0) and (y<head.height)) then //within image
              begin
                if max_radius>100 then
                begin
                  if img_loaded[0,x,y]-backgrR<=0 then //reached outside of star
                    max_radius:=1+sqrt(sqr(x1)+sqr(y1));//allow to continue for one pixel ring max
                end
                else
                if sqrt(sqr(x1)+sqr(y1))>=max_radius then
                  break;

                delta:=min(flux,(img_loaded[0,x,y]-backgrR));//all photometry is only done in the red channel
                img_loaded[0,x,y]:=img_loaded[0,x,y]-delta;
                flux:=flux-delta;

                if delta>0 then //follow the red channel
                begin
                  if head.naxis3>1 then img_loaded[1,x,y]:=img_loaded[0,x,y]*backgrG/backgrR;
                  if head.naxis3>2 then img_loaded[2,x,y]:=img_loaded[0,x,y]*backgrB/backgrR;
                end;
              end;

            end;
          end;
      end;
    end;

  img_temp3:=nil;{free memo2}
end;


procedure Tstackmenu1.remove_stars1Click(Sender: TObject);
var
  gain: single;
  fitsX,fitsY,col   : integer;
begin
  if head.naxis=0 then exit; {file loaded?}
  if head.cd1_1=0 then begin memo2_message('Abort, solve the image first!');exit; end;
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  backup_img;{preserve img array and fits header of the viewer}
  bck.backgr:=0;

  remove_stars;
  memo2_message('Stars removed.');
  gain:=UpDown_nebulosity1.position;

  if sender=increase_nebulosity1 then
  begin
    for col:=0 to head.naxis3-1 do //all colour
      for fitsX:=0 to head.width-1 do
        for fitsY:=0 to head.height-1 do
          img_loaded[col, fitsX, fitsY]:=img_backup[index_backup].img[col, fitsX, fitsY] + (img_loaded[col, fitsX, fitsY]-bck.backgr {reduce background})*gain;

    memo2_message('Nebulosity signal increased.');
  end;

  mainwindow.image1.Canvas.font.size:=10;
  mainwindow.image1.Canvas.brush.Style:=bsClear;
  mainwindow.image1.Canvas.textout(20,head.height-20,stackmenu1.reference_database1.text);//show which database was used

  plot_fits(mainwindow.image1,false,true);//refresh screen

  Screen.Cursor:=crDefault;
end;


procedure Tstackmenu1.browse_monitoring1Click(Sender: TObject);
var
  live_monitor_directory: string;
begin
  if SelectDirectory('Select directory to monitor', monitoring_path1.Caption,
    live_monitor_directory) then
  begin
    monitoring_path1.Caption := live_monitor_directory;{show path}
  end;
end;

procedure Tstackmenu1.Button1Click(Sender: TObject);
begin
  form_listbox1 := TForm_listbox1.Create(self); {in project option not loaded automatic}
  form_listbox1.ShowModal;

  if object_found then
  begin
    target1.Caption := keyboard_text;
    ra_target := ra_data;{target for manual mount}
    dec_target := dec_data;
  end;
  form_listbox1.Release;
  report_delta;{update delta position of target}
end;


procedure Tstackmenu1.calibrate_prior_solving1Change(Sender: TObject);
begin
  if calibrate_prior_solving1.Checked then check_pattern_filter1.Checked := False;
end;


procedure Tstackmenu1.clear_result_list1Click(Sender: TObject);
begin
  ListView5.Clear;
end;


procedure Tstackmenu1.column_fov1Click(Sender: TObject);
begin
  stackmenu1.listview1.columns.Items[l_sqm + 1].Caption := 'FOV';
  sqm_key:='FOV     ';//does not exist, but will be calculated

end;

procedure Tstackmenu1.column_lim_magn1Click(Sender: TObject);
begin
  stackmenu1.listview1.columns.Items[l_sqm + 1].Caption := 'LIM_MAGN';
  sqm_key:='LIM_MAGN';

end;

procedure Tstackmenu1.column_sqm1Click(Sender: TObject);
begin
  stackmenu1.listview1.columns.Items[l_sqm + 1].Caption := 'SQM';
  sqm_key:='SQM     ';
end;



procedure Tstackmenu1.FormDestroy(Sender: TObject);
begin
  bsolutions := nil;{just to be sure to clean up}
end;

procedure Tstackmenu1.help_monitoring1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#monitoring');
end;


procedure Tstackmenu1.help_mount_tab1Click(Sender: TObject);
begin
  openurl('http://www.hnsky.org/astap.htm#mount_tab');
end;

procedure Tstackmenu1.lightsShow(Sender: TObject);
begin
  stackmenu1.listview1.columns.Items[l_centaz + 1].Caption := centaz_key; {lv.items[l_sqm].caption:=sqm_key; doesn't work}
  stackmenu1.listview1.columns.Items[l_sqm + 1].Caption := sqm_key;  {lv.items[l_sqm].caption:=sqm_key; doesn't work}
end;


procedure Tstackmenu1.listview1ItemChecked(Sender: TObject; Item: TListItem);
begin
  if item.Checked = False then
  begin
    item.SubitemImages[L_quality] := -1;  {no marker. Required for autoselect to remove this item permanent from statistics}
    {$ifdef darwin} {MacOS}
    item.subitems.Strings[L_quality]:=add_unicode('', item.subitems.Strings[L_quality]);//remove crown or thumb down
    {$endif}
  end;
end;


procedure Tstackmenu1.live_monitoring1Click(Sender: TObject);
begin
  save_settings2;{too many lost selected files . so first save settings}
  esc_pressed := False;
  live_monitoring1.font.style := [fsbold, fsunderline];
  Application.ProcessMessages; {process font changes}

  monitoring(monitoring_path1.Caption);{monitor a directory}
end;

procedure Tstackmenu1.auto_select1Click(Sender: TObject);
var
  index, total: integer;
  psx, psy: string;
  someresult: boolean;
begin
  total := listview1.Items.Count - 1;
  esc_pressed := False;
  someresult := False;
  index := 0;
  shape_fitsX := -99;
  while index <= total do
  begin
    if listview1.Items[index].Selected then
    begin
      filename2 := listview1.items[index].Caption;

      psx := ListView1.Items.item[index].subitems.Strings[L_X];
      if psx <> '' then
      begin
        shape_fitsX := -1 + strtofloat2(psx);{keep updating each image}
        psy := ListView1.Items.item[index].subitems.Strings[L_Y];
        shape_fitsY := -1 + round(strtofloat2(psy));{keep updating each image}
      end
      else
      if shape_fitsX > 0 {at least one reference found} then
        if load_image(True, False {plot}) then {load}
        begin
          if find_reference_star(img_loaded) then
          begin
            ListView1.Items.item[index].subitems.Strings[L_X] := floattostrF(shape_fitsX, ffFixed, 0, 2);
            ListView1.Items.item[index].subitems.Strings[L_Y] := floattostrF(shape_fitsY, ffFixed, 0, 2);
            {$ifdef darwin} {MacOS}
            {bugfix darwin green red colouring}
            stackmenu1.ListView1.Items.item[index].Subitems.strings[L_result]:='✓ star';
            {$endif}
            memo2_message(filename2 + ' lock');{for manual alignment}
            someresult := True;

            startX := round(shape_fitsx - 1);{follow star movement for next image}
            startY := round(shape_fitsY - 1);
          end;
          application.ProcessMessages;
          if esc_pressed then break;
        end;
    end;
    Inc(index); {go to next file}
  end;
  if someresult = False then memo2_message('Select first one star in the first image for alignment. Then select all images for automatic selection the same star.');
end;

procedure Tstackmenu1.make_osc_color1Click(Sender: TObject);
begin
  stackmenu1.stack_method1Change(nil); {update several things including raw_box1.enabled:=((mosa=false) and filter_groupbox1.enabled}
end;

procedure Tstackmenu1.manipulate1Click(Sender: TObject);
begin

end;


procedure Tstackmenu1.monitoring_stop1Click(Sender: TObject);
begin
  esc_pressed := True;
  live_monitoring1.font.style := [];
  Application.ProcessMessages; {process font changes}
end;


procedure Tstackmenu1.lrgb_auto_level1Change(Sender: TObject);
var
  au: boolean;
begin
  au := lrgb_auto_level1.Checked;
  lrgb_colour_smooth1.Enabled := au;
  lrgb_preserve_r_nebula1.Enabled := au;
  lrgb_smart_smooth_width1.Enabled := au;
  lrgb_smart_colour_sd1.Enabled := au;
end;


procedure Tstackmenu1.keywordchangelast1Click(Sender: TObject);
begin
  sqm_key := uppercase(InputBox('Type header keyword to display in the last column:',
    '', sqm_key));
  new_analyse_required := True;
  stackmenu1.listview1.columns.Items[l_sqm + 1].Caption := sqm_key;
  {lv.items[l_sqm].caption:=sqm_key; doesn't work}
  while length(sqm_key) < 8 do sqm_key := sqm_key + ' ';
end;

procedure Tstackmenu1.keywordchangesecondtolast1Click(Sender: TObject);
begin

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
procedure polar_error_to_position_error(delta_alt, delta_az,
  ra1_mount, dec1_mount, jd1, ra2_mount, dec2_mount, jd2, latitude, longitude: double;
  out delta_ra, delta_dec: double);
const
  siderealtime2000 = (280.46061837) * pi / 180; {[radians], sidereal time at 2000 jan 1.5 UT (12 hours) =Jd 2451545 at meridian greenwich, see new Meeus 11.4}
  earth_angular_velocity = pi * 2 * 1.00273790935;  {about(365.25+1)/365.25) or better (365.2421874+1)/365.2421874 velocity daily. See new Meeus page 83}
var
  sidereal_time1, sidereal_time2, h_1, h_2: double;
begin
  sidereal_time1 := fnmodulo(+longitude + siderealtime2000 + (jd1 - 2451545) * earth_angular_velocity, 2 * pi); {As in the FITS header in ASTAP the site longitude is positive if east and has to be added to the time}
  sidereal_time2 := fnmodulo(+longitude + siderealtime2000 + (jd2 - 2451545) * earth_angular_velocity, 2 * pi);{As in the FITS header in ASTAP the site longitude is positive if east and has to be added to the time}

  h_1 := ra1_mount - sidereal_time1;
  h_2 := ra2_mount - sidereal_time2;

  delta_Ra := delta_alt * (TAN(dec2_mount) * SIN(h_2) - TAN(dec1_mount) * SIN(h_1)) +  delta_az * COS(latitude) * (TAN(dec1_mount) * COS(h_1) - TAN(dec2_mount) * COS(h_2));
  delta_Dec := delta_alt * (COS(h_2) - COS(h_1)) + delta_az * COS(latitude) * (SIN(h_2) - SIN(h_1));
end;


{Polar error calculation based on two celestial reference points and the error of the telescope mount at these point(s).
 Based on formulas from Ralph Pass documented at https://rppass.com/align.pdf.
 They are based on the book “Telescope Control’ by Trueblood and Genet, memo2.111
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
procedure polar_error_calc(ra1, dec1, ra1_mount, dec1_mount, jd1, ra2, dec2, ra2_mount, dec2_mount, jd2, latitude, longitude: double;  out delta_Elv, delta_az: double);{calculate polar error based on two images. All values in radians}
const
  siderealtime2000 = (280.46061837) * pi / 180; {[radians], sidereal time at 2000 jan 1.5 UT (12 hours) =Jd 2451545 at meridian greenwich, see new Meeus 11.4}
  earth_angular_velocity = pi * 2 * 1.00273790935; {about(365.25+1)/365.25) or better (365.2421874+1)/365.2421874 velocity daily. See new Meeus page 83}
var
  determinant, delta_ra, delta_dec, sidereal_time1, sidereal_time2, h_1, h_2: double;
  A, B, C, C_inv: array[0..1, 0..1] of double;
begin
  sidereal_time1 := fnmodulo(+longitude + siderealtime2000 + (jd1 - 2451545) * earth_angular_velocity, 2 * pi);  {As in the FITS header in ASTAP the site longitude is positive if east and has to be added to the time}
  sidereal_time2 := fnmodulo(+longitude + siderealtime2000 + (jd2 - 2451545) * earth_angular_velocity, 2 * pi);  {As in the FITS header in ASTAP the site longitude is positive if east and has to be added to the time}

  memo2_message('Local sidereal time image 1:     ' + prepare_ra6(sidereal_time1, ' '));  {24 00 00}
  memo2_message('Local sidereal time image 2:     ' + prepare_ra6(sidereal_time2, ' '));  {24 00 00}

  delta_ra := (ra2_mount - ra2) - (ra1_mount - ra1);
  delta_dec := (dec2_mount - dec2) - (dec1_mount - dec1);

  h_1 := ra1_mount - sidereal_time1;
  h_2 := ra2_mount - sidereal_time2;

  // [delta_Ra;delta_Dec]= A * [delta_Elv;delta_Azm]
  // Fill matrix image 1 with data.
  A[0, 0] := TAN(dec1_mount) * SIN(h_1);
  A[1, 0] :={SIN(LAT_rad)} -COS(latitude) * TAN(dec1_mount) * COS(h_1); //sin(lat_rad) will be nulified anyhow when B-A is calculated}

  A[0, 1] := COS(h_1);
  A[1, 1] := COS(latitude) * SIN(h_1);

  // Fill matrix image 2 with data.
  B[0, 0] := TAN(dec2_mount) * SIN(h_2);//  B[1,0]:=COS(latitude)*({SIN(LAT_rad)}-TAN(dec2_mount)*COS(h_2));  //sin(lat_rad) will be nulified anyhow when B-A is calculated}
  B[1, 0] :={SIN(LAT_rad)} -COS(latitude) * TAN(dec2_mount) * COS(h_2); //sin(lat_rad) will be nulified anyhow when B-A is calculated}
  B[0, 1] := COS(h_2);
  B[1, 1] := COS(latitude) * SIN(h_2);

  //difference,  image 2 - image 1
  C[0, 0] := B[0, 0] - A[0, 0];
  C[1, 0] := B[1, 0] - A[1, 0];
  C[0, 1] := B[0, 1] - A[0, 1];
  C[1, 1] := B[1, 1] - A[1, 1];

  // Calculate the inverse matrix inv(C)
  determinant := C[0, 0] * C[1, 1] - C[0, 1] * C[1, 0];
  C_inv[0, 0] := +C[1, 1] / determinant;
  C_inv[1, 1] := +C[0, 0] / determinant;
  C_inv[1, 0] := -C[1, 0] / determinant;
  C_inv[0, 1] := -C[0, 1] / determinant;

  // [delta_Elv;delta_Az] = inv(A)*[delta_Ra;delta_Dec]
  // Use the inverse matrix to calculate the polar axis elevation and azimuth error from the delta_dec and delta_ra between the two image positions.
  delta_Elv := C_inv[0, 0] * delta_ra + C_inv[1, 0] * delta_Dec;
  delta_Az := C_inv[0, 1] * delta_ra + C_inv[1, 1] * delta_Dec;

  if abs(determinant) < 0.1 then memo2_message('█ █ █ █ █ █ Warning the calculation determinant is close to zero! Select other celestial locations. Avoid locations with similar hour angles, locations close to the celestial equator and locations whose declinations are close to negatives of each other. █ █ █ █ █ █ ');
end;


procedure Tstackmenu1.calc_polar_alignment_error1Click(Sender: TObject);
var
  c: integer;
  errordecode: boolean;
  ra1, dec1, ra1_mount, dec1_mount, jd1, ra2, dec2, ra2_mount, dec2_mount, jd2,
  delta_alt, delta_az, sep, site_long_radians, site_lat_radians
  : double;
  counter: integer;
  ns, ew: string;
begin
  memo2_message('Instructions:');
  memo2_message('   1: Synchronise the mount and take one image.');
  memo2_message('   2: Slew the mount to a second point in the sky and take a second image without synchronising the mount.');
  memo2_message('Conditions: The image header should contain the correct time, observer location and mount position. Images should be solvable.');
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  esc_pressed := False;

  stackmenu1.mount_add_solutions1Click(nil);
  {add any missing solutions and analyse after that}

  counter := 0;
  {solve lights first to allow flux to magnitude calibration}
  with stackmenu1 do
    for c := 0 to listview9.items.Count - 1 do {check for astrometric solutions}
    begin
      if ((esc_pressed = False) and (listview9.Items.item[c].Checked) and
        (listview9.Items.item[c].subitems.Strings[M_ra_jnow] <> '')) then
      begin
        filename2 := listview9.items[c].Caption;

        Application.ProcessMessages;

        {load image}
        if esc_pressed then
        begin
          Screen.Cursor := crDefault;{back to normal }
          exit;
        end;

        if counter = 0 then
        begin
          ra1 := strtofloat(listview9.Items.item[c].subitems.Strings[M_ra_jnow]) * pi / 180;
          dec1 := strtofloat(listview9.Items.item[c].subitems.Strings[M_dec_jnow]) * pi / 180;
          ra1_mount := strtofloat(listview9.Items.item[c].subitems.Strings[M_ra_m_jnow]) * pi / 180;
          dec1_mount := strtofloat(listview9.Items.item[c].subitems.Strings[M_dec_m_jnow]) * pi / 180;
          jd1 := strtofloat(listview9.Items.item[c].subitems.Strings[M_jd_mid]);
          memo2_message('Image 1: ' + filename2);
          Inc(counter);
        end
        else
        begin
          ra2 := strtofloat(listview9.Items.item[c].subitems.Strings[M_ra_jnow]) * pi / 180;
          dec2 := strtofloat(listview9.Items.item[c].subitems.Strings[M_dec_jnow]) * pi / 180;
          ra2_mount := strtofloat(listview9.Items.item[c].subitems.Strings[M_ra_m_jnow]) * pi / 180;
          dec2_mount := strtofloat(listview9.Items.item[c].subitems.Strings[M_dec_m_jnow]) * pi / 180;
          jd2 := strtofloat(listview9.Items.item[c].subitems.Strings[M_jd_mid]);
          ang_sep(ra1, dec1, ra2, dec2, {out}sep); {calculates angular separation. according formula 9.1 old Meeus or 16.1 new Meeus, version 2018-5-23}
          if sep > 5 * pi / 180 then
          begin
            dec_text_to_radians(sitelat, site_lat_radians, errordecode);
            if errordecode then
            begin
              memo2_message('Warning observatory latitude not found in the fits header');
              exit;
            end;

            dec_text_to_radians(sitelong, site_long_radians, errordecode);
            {longitude is in degrees, not in hours. East is positive according ESA standard and diffractionlimited}
            {see https://indico.esa.int/event/124/attachments/711/771/06_ESA-SSA-NEO-RS-0003_1_6_FITS_keyword_requirements_2014-08-01.pdf}
            if errordecode then
            begin
              memo2_message('Warning observatory longitude not found in the fits header');
              exit;
            end;

            memo2_message('Image 2: ' + filename2);
            if site_long_radians > 0 then ew := ' E'
            else
              ew := ' W';
            if site_lat_radians > 0 then ns := ' N'
            else
              ns := ' S';
            memo2_message('Location (rounded) ' + IntToStr(round(site_lat_radians * 180 / pi)) + ns + '  ' + IntToStr(round(site_long_radians * 180 / pi)) + ew + '. Angular seperation between the images is ' + floattostrF(sep * 180 / pi, ffFixed, 0, 1) + '°');

            polar_error_calc(ra1, dec1, ra1_mount, dec1_mount, jd1, ra2, dec2, ra2_mount, dec2_mount, jd2, site_lat_radians, site_long_radians, {out} delta_alt, delta_az);
            {calculate polar error based on the solves}
            if delta_alt > 0 then ns := ' above the celestial pole'
            else
              ns := ' below the celestial pole';
            if delta_az > 0 then ew := ' east of the celestial pole.'
            else
              ew := ' west of the celestial pole.';
            memo2_message('Polar axis is ' + floattostrF( abs(delta_alt) * 60 * 180 / pi, ffFixed, 0, 1) + #39 + ns + ' and ' + floattostrF(abs(delta_az) * 60 * 180 / pi, ffFixed, 0, 1) + #39 + ew);
            counter := 0;{restart for next images}
          end
          else
            memo2_message('Skipped image ' + filename2 + '. The angular distance between the two images is ' + floattostrF( sep * 180 / pi, ffFixed, 0, 1) + '°' + ' and too small!');
        end;
      end;
    end;
  Screen.Cursor := crDefault;{back to normal }

  stackmenu1.mount_analyse1Click(nil);{update}
end;


procedure Tstackmenu1.monitor_action1Change(Sender: TObject);
begin
  target_group1.Enabled := stackmenu1.monitor_action1.ItemIndex = 4;
end;


procedure Tstackmenu1.monitor_latitude1EditingDone(Sender: TObject);
begin
  lat_default := monitor_latitude1.Text;
  report_delta; {report delta error}
end;


procedure Tstackmenu1.monitor_longitude1EditingDone(Sender: TObject);
begin
  long_default := monitor_longitude1.Text;
  report_delta; {report delta error}
end;



procedure Tstackmenu1.mount_analyse1Click(Sender: TObject);
begin
  save_settings2;{too many lost selected files . so first save settings}
  analyse_listview(listview9, True {light}, False {full fits}, True{refresh});
end;


procedure Tstackmenu1.analysephotometry1Click(Sender: TObject);
begin
  if Sender = analysephotometrymore1 then
    analyse_listview(listview7, True {light}, True {full fits}, True{refresh})
  else
    analyse_listview(listview7, True {light}, False {full fits}, True{refresh});

  listview7.items.beginupdate;
  listview7.alphasort;{sort on time}
  listview7.items.endupdate;

  {$ifdef mswindows}
  {$else} {unix}
  {temporary fix for CustomDraw not called}
   stackmenu1.nr_total_photometry1.Caption := IntToStr(listview7.items.Count);
  {$endif}
  {update counting info}

end;


procedure Tstackmenu1.analyse_inspector1Click(Sender: TObject);
begin
  stackmenu1.memo2.Lines.add('Inspector routine using multiple images at different focus positions. This routine will calculate the best focus position of several areas by extrapolation. Usage:');
  stackmenu1.memo2.Lines.add('- Browse for a number of short exposure images made at different focuser positions around best focus. Use a fixed focuser step size and avoid backlash by going one way through the focuser positions.');
  stackmenu1.memo2.Lines.add('- Press analyse to measure the area hfd values of each image.');
  stackmenu1.memo2.Lines.add('- Press curve fitting. The curve fit routine will calculate the best focuser position for each area using the hfd values. The focuser differences from center will indicate tilt & curvature of the image.');
  stackmenu1.memo2.Lines.add('');
  stackmenu1.memo2.Lines.add('Remarks:');
  stackmenu1.memo2.Lines.add('It is possible to make more than one exposure per focuser position, but this number should be the same for each focuser point.');
  stackmenu1.memo2.Lines.add('Note that hfd values above about 20 will give  erroneous results. Un-check these files prior to curve fitting. Values will be slightly different from viewer figure which can measure only up to HFD 10.');
  stackmenu1.memo2.Lines.add('');
  memo2_message('Start analysing images');
  analyse_listview(listview8, True {light}, True {full fits}, False{refresh});

  if listview8.items.Count > 1 then {prevent run time error if no files are available}
  begin
    listview8.Selected := nil; {remove any selection}
    listview8.ItemIndex := 0;{mark where we are. }
    listview8.Items[0].MakeVisible(False); {scroll to selected item and fix last red colouring}
    memo2_message('Ready analysing. To copy result, select the rows with ctrl-A and copy the rows with ctrl-C. They can be pasted into a spreadsheet. Press now "Hyperbola curve fitting" to measure tilt and curvature expressed in focuser steps.');
  end;
end;


procedure Tstackmenu1.apply_hue1Click(Sender: TObject);
var
  fitsX, fitsY, fuzziness : integer;
  r, g, b, h, s, s_new, v, oldhue, newhue, dhue, saturation_factor, s_old, saturation_tol, v_adjust: single;
  colour: tcolor;
begin
  if ((head.naxis = 0) or (head.naxis3 <> 3)) then exit;
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img;

  fuzziness := hue_fuzziness1.position;
  saturation_tol := saturation_tolerance1.position / 100;
  saturation_factor := new_saturation1.position / 100;

  colour := colourShape1.brush.color;
  RGB2HSV(getRvalue(colour), getGvalue(colour), getBvalue(colour), oldhue, s_old, v);
  colour := colourShape3.brush.color;
  RGB2HSV(getRvalue(colour), getGvalue(colour), getBvalue(colour), newhue, s_new, v);

  if length(stackmenu1.area_set1.Caption)<=3  then {no area selected}
  begin
    areax1 := 0;
    areay1 := 0;
    areax2 := head.Width - 1;
    areaY2 := head.Height - 1;
  end;
  {else set in astap_main}

  v_adjust:=stackmenu1.new_colour_luminance1.position/100;

  for fitsY := areay1 to areay2 do
    for fitsX := areax1 to areax2 do
    begin
      RGB2HSV(max(0, img_loaded[0, fitsX, fitsY] - bck.backgr), max(0, img_loaded[1, fitsX, fitsY] - bck.backgr), max(0, img_loaded[2, fitsX, fitsY] - bck.backgr), h, s, v);  {RGB to HSVB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}
      dhue := abs(oldhue - h);
      if (((dhue <= fuzziness) or (dhue >= 360 - fuzziness)) and  (abs(s - s_old) < saturation_tol {saturation speed_tolerance1})) then {colour close enough, replace colour}
      begin
        HSV2RGB(newhue, min(1, s_new * saturation_factor) {s 0..1}, v * v_adjust{v 0..1}, r, g, b);   {HSV to RGB using hexcone model, https://en.wikipedia.org/wiki/HSL_and_HSV}

        img_loaded[0, fitsX, fitsY] := r + bck.backgr;
        img_loaded[1, fitsX, fitsY] := g + bck.backgr;
        img_loaded[2, fitsX, fitsY] := b + bck.backgr;
      end;
    end;
  plot_fits(mainwindow.image1, False, True);{plot real}

  HueRadioButton1.Checked := False;
  HueRadioButton2.Checked := False;
  Screen.Cursor := crDefault;
end;


procedure Tstackmenu1.auto_background_level1Click(Sender: TObject);
var
  bckR,bckG,bckB : tbackground;
begin
  if length(img_loaded) < 3 then exit;{not a three colour image}

  apply_factor1.Enabled := False;{block apply button temporary}
  application.ProcessMessages;

  get_background(1, img_loaded, True {get hist}, True {get noise},{var} bckG);
  get_background(2, img_loaded, True {get hist}, True {get noise},{var} bckB);
  get_background(0, img_loaded, True {get hist}, True {get noise},{var} bckR); {Do red last to maintain current histogram}

  add_valueR1.Text := floattostrf(0, ffgeneral, 5, 0);
  add_valueG1.Text := floattostrf(bckR.backgr * (bckG.star_level / bckR.star_level) - bckG.backgr, ffgeneral, 5, 0);
  add_valueB1.Text := floattostrf(bckR.backgr * (bckB.star_level / bckR.star_level) - bckB.backgr, ffgeneral, 5, 0);

  multiply_green1.Text := floattostrf(bckR.star_level / bckG.star_level, ffgeneral, 5, 0);  {make stars white}
  multiply_blue1.Text := floattostrf(bckR.star_level / bckB.star_level, ffgeneral, 5, 0);
  multiply_red1.Text := '1';

  apply_factor1.Enabled := True;{enable apply button}
end;


procedure background_noise_filter(img: image_array; max_deviation, blur: double);
var
  fitsX, fitsY, Count, i, j, col, stepsize: integer;
  SD1, average1, SD, average, maxoffs, val: double;
  img_outliers: image_array;
const
  step = 100;
begin
  setlength(img_outliers, head.naxis3, head.Width, head.Height); {set length of image array mono}

  for col := 0 to head.naxis3 - 1 do {do all colours}
  begin

    {first estimate of background mean and sd, star will be included}
    average1 := 0;
    Count := 0;
    for fitsY := 0 to (head.Height - 1) div step do
      for fitsX := 0 to (head.Width - 1) div step do
      begin
        val := img[col, fitsX * step, fitsY * step];
        if val < 32000 then average1 := average1 + val;
        Inc(Count);
      end;
    average1 := average1 / Count;

    sd1 := 0;
    Count := 0;
    for fitsY := 0 to (head.Height - 1) div step do
      for fitsX := 0 to (head.Width - 1) div step do
      begin
        val := img[col, fitsX * step, fitsY * step];
        if val < 32000 then sd1 := sd1 + sqr(average1 - val);
        Inc(Count);
      end;
    sd1 := sqrt(sd1 / (Count)); {standard deviation}

    {second estimate of mean and sd, star will be excluded}
    average := 0;
    sd := 0;
    Count := 0;
    for fitsY := 0 to head.Height - 1 do
      for fitsX := 0 to head.Width - 1 do
      begin
        val := img[col, fitsX, fitsY];
        if val < average1 + 5 * sd1 then average := average + val;
        Inc(Count);
      end;

    average := average / Count;
    for fitsY := 0 to head.Height - 1 do
      for fitsX := 0 to head.Width - 1 do
      begin
        val := img[col, fitsX, fitsY];
        if val < average1 + 5 * sd1 then sd := sd + sqr(average - val);
        Inc(Count);
      end;
    sd := sqrt(sd / (Count)); {standard deviation}
    maxoffs := max_deviation * sd;{typically 3}

    for fitsY := 0 to head.Height - 1 do  {mark signal pixel and store in img_outliers}
      for fitsX := 0 to head.Width - 1 do
      begin
        if (img[col, fitsX, fitsY] - average) > maxoffs then {signal}
          img_outliers[col, fitsX, fitsY] := img[col, fitsX, fitsY] {store as signal}
        else
        begin
          Count := 0; {find if signal nearby}
          stepsize := round(blur * 1.5);{adapt range to gaussian blur range}
          for i := -stepsize to stepsize do
            for j := -stepsize to stepsize do
              if ((fitsX + i >= 0) and (fitsX + i < head.Width) and (fitsY + j >= 0) and
                (FitsY + j < head.Height)) then
              begin
                if (img[col, fitsX + i, fitsY + j] - average) > maxoffs then {signal}
                begin
                  Inc(Count);
                end;
              end;

          if Count > 0 then {signal}
          begin
            img_outliers[col, fitsX, fitsY] := img[col, fitsX, fitsY]; {store outlier for possible restoring}
            img[col, fitsX, fitsY] := average;{change hot pixel to average}
          end
          else
            img_outliers[col, fitsX, fitsY] := 0;{not signal}
        end;
      end;
  end;{all colours}

  gaussian_blur2(img, blur);{apply gaussian blur }

  {restore signal}
  for col := 0 to head.naxis3 - 1 do {do all colours}
    for fitsY := 0 to head.Height - 1 do
      for fitsX := 0 to head.Width - 1 do
      begin
        if img_outliers[col, fitsX, fitsY] <> 0 then
          img[col, fitsX, fitsY] := img_outliers[col, fitsX, fitsY];
      end;
  img_outliers := nil;
end;

procedure Tstackmenu1.apply_background_noise_filter1Click(Sender: TObject);
begin
  if Length(img_loaded) = 0 then
  begin
    memo2_message('Error, no image in viewer loaded!');
    exit;
  end;
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  backup_img;
  background_noise_filter(img_loaded, strtofloat2(stackmenu1.noisefilter_sd1.Text),
    strtofloat2(stackmenu1.noisefilter_blur1.Text));

  //  use_histogram(true);{get histogram}
  plot_fits(mainwindow.image1, False, True);{plot real}

  Screen.Cursor := crDefault;
end;


procedure Tstackmenu1.bayer_pattern1Select(Sender: TObject);
begin
  demosaic_method1.Enabled := pos('X-Trans', bayer_pattern1.Text) = 0;
  {disable method is X-trans is selected}
end;


procedure Tstackmenu1.bin_image1Click(Sender: TObject);
begin
  if head.naxis <> 0 then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    backup_img; {move viewer data to img_backup}
    if bin_factor1.ItemIndex = 0 then bin_X2X3X4(2)
    else
      bin_X2X3X4(3);

    plot_fits(mainwindow.image1, True, True);{plot real}
    Screen.Cursor := crDefault;
  end;
end;


procedure Tstackmenu1.align_blink1Change(Sender: TObject);
begin
  solve_and_annotate1.Enabled := align_blink1.Checked;
end;


procedure Tstackmenu1.add_noise1Click(Sender: TObject);
var
  fitsX, fitsY, col: integer;
  noise, mean: double;
begin
  if head.naxis <> 0 then
  begin
    backup_img; {move viewer data to img_backup}
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    noise := strtofloat2(stackmenu1.edit_noise1.Text);
    if add_bias1.Checked then mean := 3 * noise
    else
      mean := 0;

    for fitsY := 0 to head.Height - 1 do
      for fitsX := 0 to head.Width - 1 do
        for col := 0 to head.naxis3 - 1 do
          img_loaded[col, fitsX, fitsY] :=
            max(0, img_loaded[col, fitsX, fitsY] + randg(mean, noise){gaussian noise});

    plot_fits(mainwindow.image1, False, True);{plot real}
    Screen.Cursor := crDefault;
  end;
  use_histogram(img_loaded, True {update}); {update for the noise, plot histogram, set sliders}
end;

procedure Tstackmenu1.alignment1Show(Sender: TObject);
begin
  update_tab_alignment;
end;

procedure Tstackmenu1.blink_stop1Click(Sender: TObject);
begin
  esc_pressed := True;
end;


procedure Tstackmenu1.blink_unaligned_multi_step1Click(Sender: TObject);
var
  c, step: integer;
  init    : boolean;
begin
  if listview1.items.Count <= 1 then exit; {no files}
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  save_settings2;{too many lost selected files . so first save settings}
  esc_pressed := False;
  init := False;
  if Sender = blink_unaligned_multi_step_backwards1 then step := -1
  else
    step := 1;{forward/ backwards}

  repeat
    if init = False then c := listview_find_selection(listview1) {find the row selected}
    else
    begin
      if step > 0 then c := 0 {forward}
      else
        c := listview1.items.Count - 1;{backwards}
    end;
    init := True;
    repeat
      if ((esc_pressed = False) and (listview1.Items.item[c].Checked)) then
      begin
        listview1.Selected := nil; {remove any selection}
        listview1.ItemIndex := c;  {mark where we are. Important set in object inspector    Listview1.HideSelection := false; Listview1.Rowselect := true}
        listview1.Items[c].MakeVisible(False);{scroll to selected item}

        filename2 := listview1.items[c].Caption;
        mainwindow.Caption := filename2;

        Application.ProcessMessages;
        if esc_pressed then
          break;
        {load image}
        if load_fits(filename2, True {light}, True, True {update memo},
          0, head, img_loaded) = False then
        begin
          esc_pressed := True;
          break;
        end;

        use_histogram(img_loaded, True {update}); {plot histogram, set sliders}

        plot_fits(mainwindow.image1, False {re_center}, True);

        {show alignment marker}
        if (stackmenu1.use_manual_alignment1.Checked) then
          show_shape_manual_alignment(c) {show the marker on the reference star}
        else
          mainwindow.shape_manual_alignment1.Visible := False;

      end;
      Inc(c, step);
    until ((c >= listview1.items.Count) or (c < 0));
  until esc_pressed;

  Screen.Cursor := crDefault;{back to normal }
end;

procedure Tstackmenu1.browse_mount1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.Title := 'Select images to analyse';    {including WCS files !!!}
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist, ofHideReadOnly];
  opendialog1.Filter := dialog_filter; //fits_file:=true;
  if opendialog1.Execute then
  begin
    listview9.items.beginupdate;
    for i := 0 to OpenDialog1.Files.Count - 1 do {add}
    begin
      listview_add(listview9, OpenDialog1.Files[i], True, M_nr);
    end;
    listview9.items.endupdate;
  end;
end;




procedure Tstackmenu1.copy_to_images1Click(Sender: TObject);
var
  index, counter: integer;
begin
  index := 0;
  listview1.Items.beginUpdate;
  counter := listview5.Items.Count;
  while index < counter do
  begin
    if listview5.Items[index].Selected then
    begin
      listview_add(listview1, listview5.items[index].Caption, True, L_nr);
    end;
    Inc(index); {go to next file}
  end;
  listview1.Items.endUpdate;
end;


procedure double_size(img: image_array; w, h: integer; var img2: image_array);{double array size}
var
  fitsX, fitsY, i, x, y: integer;
begin
  setlength(img_buffer, head.naxis3, w, h);{set length of image array}

  for fitsY := 0 to h do
    for fitsX := 0 to w do
    begin
      for i := 0 to head.naxis3 - 1 do
      begin
        x := fitsX div 2;
        y := fitsY div 2;
        if ((x <= head.Width - 1) and (y <= head.Height - 1)) then {prevent problem if slightly different} img_buffer[i, fitsX, fitsY] := img[i, x, y];
      end;
    end;
  head.Height := h;
  head.Width := w;

  img2 := img_buffer;
end;


procedure load_master_dark(jd_int: integer);
var
  c: integer;
  d, day_offset: double;
  filen: string;

begin
  //  analyse_listview(stackmenu1.listview2,false {light},false {full fits},false{refresh});{find dimensions, head_2.exposure and temperature}
  c := 0;
  day_offset := 99999999;
  filen := '';

  dark_exposure := round(head.exposure);{remember the requested head.exposure time}
  dark_temperature := head.set_temperature;
  if head.egain <> '' then  dark_gain := head.egain  else dark_gain := head.gain;


  while c < stackmenu1.listview2.items.Count do
  begin
    if stackmenu1.listview2.items[c].Checked = True then
      if ((stackmenu1.classify_dark_exposure1.Checked = False) or (dark_exposure = round(strtofloat2(stackmenu1.listview2.Items.item[c].subitems.Strings[D_exposure])))) then {head_2.exposure correct}
        if ((stackmenu1.classify_dark_temperature1.Checked = False) or (abs(dark_temperature - StrToInt(stackmenu1.listview2.Items.item[c].subitems.Strings[D_temperature])) <= 1)) then {temperature correct within one degree}
          if ((stackmenu1.classify_dark_temperature1.Checked = False) or (dark_gain = stackmenu1.listview2.Items.item[c].subitems.Strings[D_gain])) then {gain correct}
            if head.Width = StrToInt(stackmenu1.listview2.Items.item[c].subitems.Strings[D_width]) then {width correct}
            begin
              d := strtofloat(stackmenu1.listview2.Items.item[c].subitems.Strings[D_jd]);
              if abs(d - jd_int) < day_offset then {find flat with closest date}
              begin
                filen := stackmenu1.ListView2.items[c].Caption;
                day_offset := abs(d - jd_int);
              end;
            end;
    Inc(c);
  end;


  if (filen <> '') then {new file}
  begin
    if ((head_ref.dark_count = 0){restart} or (filen <> last_dark_loaded)) then
    begin
      memo2_message('Loading master dark file ' + filen);
      if load_fits(filen, False {light}, True, False {update memo}, 0, head_2, img_dark) = False then
      begin
        memo2_message('Error');
        head_ref.dark_count := 0;
        exit;
      end; {load master in memory img_dark}

      {test compatibility}
      if ((round(head_2.exposure) <> 0 {dark exposure is measured}) and (round(head.exposure){request} <> round(head_2.exposure))) then memo2_message('█ █ █ █ █ █ Warning above dark exposure time (' + floattostrF(head_2.exposure, ffFixed, 0, 0) + ') is different then the light exposure time (' + floattostrF(head.exposure, ffFixed, 0, 0) + ')! █ █ █ █ █ █ ');
      if ((head_2.set_temperature <> 999 {dark temperature is measured}) and (head.set_temperature{request} <> head_2.set_temperature)) then  memo2_message('█ █ █ █ █ █ Warning above dark sensor temperature (' + floattostrF(head_2.set_temperature, ffFixed, 0, 0) +') is different then the light sensor temperature (' + floattostrF(head.set_temperature, ffFixed, 0, 0) + ')! █ █ █ █ █ █ ');
      if ((head_2.gain <> '' {gain in header}) and (head.gain{request} <> head_2.gain)) then memo2_message('█ █ █ █ █ █ Warning above dark gain (' + head_2.gain + ') is different then the light gain (' + head.gain +')! █ █ █ █ █ █ ');

      last_dark_loaded := filen; {required for for change in light_jd}
      if head_2.dark_count = 0 then head_2.dark_count := 1; {store in head of reference file}
    end;
  end
  else
  begin
    memo2_message('█ █ █ █ █ █ Warning, could not find a suitable dark for exposure "' + IntToStr(round(head.exposure)) + ' and temperature ' + IntToStr( head.set_temperature) + ' and gain ' + head.gain+'"! De-classify temperature or exposure time or add correct darks. █ █ █ █ █ █ ');
    head_2.dark_count := 0;{set back to zero}
  end;
end;


procedure load_master_flat({filter: string;width1,}jd_int: integer);
var
  c: integer;
  d, day_offset: double;
  filen: string;
begin
  c := 0;
  day_offset := 99999999;
  filen := '';
  while c < stackmenu1.listview3.items.Count do
  begin
    if stackmenu1.listview3.items[c].Checked = True then
    begin
      if ((stackmenu1.classify_flat_filter1.Checked = False) or
        (AnsiCompareText(head.filter_name, stackmenu1.listview3.Items.item[
        c].subitems.Strings[F_filter]) = 0)) then {filter correct?  ignoring case}
        if head.Width = StrToInt( stackmenu1.listview3.Items.item[c].subitems.Strings[D_width]) then {width correct, matches with the light width}
        begin
          d := strtofloat(stackmenu1.listview3.Items.item[c].subitems.Strings[F_jd]);
          if abs(d - jd_int) < day_offset then {find flat with closest date}
          begin
            filen := stackmenu1.ListView3.items[c].Caption;
            day_offset := abs(d - jd_int);
          end;
        end;
    end;
    Inc(c);
  end;

  if filen <> '' then
  begin
    if ((head_ref.flat_count = 0){restart} or (filen <> last_flat_loaded)) then {new file}
    begin
      memo2_message('Loading master flat file ' + filen);
      if load_fits(filen, False {light}, True, False {update memo}, 0, head_2, img_flat) = False then
      begin
        memo2_message('Error');
        head_2.flat_count := 0;
        exit;
      end;
      {load master in memory img_flat}
      last_flat_loaded := filen; {required for for change in light_jd}
      flat_filter := head.filter_name; {mark as loaded}

      if pos('B', head_2.calstat) = 0 then
      begin
        if head_2.flatdark_count = 0 then {not an older flat}
          memo2_message('█ █ █ █ █ █ Warning: Flat not calibrated with a flat-dark/bias (keywords CALSTAT or BIAS_CNT). █ █ █ █ █ █')
        else
          head_2.calstat := head_2.calstat + 'B'; {older flat temporary till 2022-12 till all flats have "B" in in calstat. Remove 2022-12}
      end;

      if head_2.flat_count = 0 then head_2.flat_count := 1; {not required for astap master}
    end;
  end
  else
  begin
    memo2_message('█ █ █ █ █ █ Warning, could not find a suitable flat for "' + head.filter_name + '"! De-classify flat filter or add correct flat. █ █ █ █ █ █ ');
    head_2.flat_count := 0;{set back to zero}
  end;
end;


procedure replace_by_master_dark(full_analyse: boolean);
var
  path1, filen, gain: string;
  c, counter, i, file_count: integer;
  specified: boolean;
  exposure, temperature, width1: integer;
  day: double;
  file_list: array of string;
begin
  save_settings2;
  with stackmenu1 do
  begin
    analyse_listview(listview2, False {light}, False {full fits}, False{refresh}); {update the tab information}
    if esc_pressed then exit;{esc could by pressed while analysing}

    setlength(file_list, stackmenu1.listview2.items.Count);
    repeat
      file_count := 0;
      specified := False;

      for c := 0 to stackmenu1.listview2.items.Count - 1 do
        if stackmenu1.listview2.items[c].Checked = True then
        begin
          filen := stackmenu1.ListView2.items[c].Caption;
          if pos('master_dark', ExtractFileName(filen)) = 0 then {not a master file}
          begin {set specification master}
            if specified = False then
            begin
              exposure := round(strtofloat2(stackmenu1.listview2.Items.item[c].subitems.Strings[D_exposure]));
              temperature := StrToInt(stackmenu1.listview2.Items.item[c].subitems.Strings[D_temperature]);
              gain := stackmenu1.listview2.Items.item[c].subitems.Strings[D_gain];
              width1 := StrToInt(stackmenu1.listview2.Items.item[c].subitems.Strings[D_width]);
              day := strtofloat(stackmenu1.listview2.Items.item[c].subitems.Strings[D_jd]);
              specified := True;
            end;
            if ((stackmenu1.classify_dark_exposure1.Checked = False) or
              (exposure = round(strtofloat2(stackmenu1.listview2.Items.item[
              c].subitems.Strings[D_exposure])))) then {exposure correct}
              if ((stackmenu1.classify_dark_temperature1.Checked = False) or
                (temperature = StrToInt(stackmenu1.listview2.Items.item[c].subitems.Strings[
                D_temperature])))
              then {temperature correct}
                if ((stackmenu1.classify_dark_temperature1.Checked = False) or
                  (gain = stackmenu1.listview2.Items.item[c].subitems.Strings[D_gain])) then {gain correct}
                  if width1 = StrToInt(
                    stackmenu1.listview2.Items.item[c].subitems.Strings[D_width]) then {width correct}
                    if ((classify_dark_date1.Checked = False) or
                      (abs(day - strtofloat(stackmenu1.listview2.Items.item[c].subitems.Strings[D_jd])) <= 0.5))
                    then {within 12 hours made}
                    begin
                      file_list[file_count] := filen;
                      Inc(file_count);
                    end;
          end;
        end;{checked}

      Application.ProcessMessages;
      if esc_pressed then exit;

      head.dark_count := 0;
      if file_count <> 0 then
      begin
        memo2_message('Averaging darks.');
        average('dark', file_list, file_count, img_dark); {the result will be mono so more suitable for raw lights without bayer applied. Not so suitable for commercial camera's image and converted to coloured FITS}
        if esc_pressed then exit;

        Application.ProcessMessages;
        if esc_pressed then exit;

        if ((file_count <> 1) or (head.dark_count = 0)) then  head.dark_count := file_count; {else use the info from the keyword dark_cnt of the master file}

        path1 := extractfilepath(file_list[0]) + 'master_dark_' + IntToStr(head.dark_count) + 'x' + IntToStr(round(exposure)) + 's_at_' + IntToStr( head.set_temperature) + 'C_' + copy(head.date_obs, 1, 10) + '.fit';
        update_integer('DARK_CNT=', ' / Number of dark image combined                  ' , head.dark_count);
        { ASTAP keyword standard:}
        { interim files can contain keywords: EXPOSURE, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
        { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

        head.naxis3:= 1;{any color is made mono in the routine. Keywords are updated in the save routine}
        head.naxis := 2; {any color is made mono in the routine. Keywords are updated in the save routine}

        update_text('COMMENT 1', '  Written by ASTAP. www.hnsky.org');
        head.naxis3 := 1; {any color is made mono in the routine}

        if save_fits(img_dark, path1, -32, False) then {saved}
        begin
          listview2.Items.BeginUpdate;
          for i := 0 to file_count - 1 do
          begin
            c := 0;
            counter := listview2.Items.Count;
            while c < counter do
            begin
              if file_list[i] = stackmenu1.ListView2.items[c].Caption then {processed}
              begin
                listview2.Items.Delete(c);
                Dec(counter);{one file less}
              end
              else
                Inc(c);
            end;
          end;
          listview_add(listview2, path1, True, D_nr);{add master}
          listview2.Items.EndUpdate;

          analyse_listview(listview2, False {light}, full_analyse
            {full fits}, False{refresh});
          {update the tab information}
        end;
        img_dark := nil;
      end;

      Application.ProcessMessages;
      if esc_pressed then exit;

    until file_count = 0;{make more than one master}
    save_settings2;{store settings}
    file_list := nil;

    memo2_message('Master darks(s) ready.');
  end;{with stackmenu1}
end;


function extract_letters_only(inp: string): string;
var
  i: integer;
  ch: char;
begin
  Result := '';
  for i := 1 to length(inp) do
  begin
    ch := inp[i];
    case ch of // valid char
      'A'..'Z', 'a'..'z', '-': Result := Result + ch;
    end;{case}
  end;
end;



procedure Tstackmenu1.replace_by_master_dark1Click(Sender: TObject);
{this routine works with mono files but makes coloured files mono, so less suitable for commercial cameras producing coloured raw lights}
begin
  if img_loaded <> nil then {button was used, backup img array and header and restore later}
  begin
    img_backup := nil;{clear to save memory}
    backup_img;
  end;{backup fits for later}
  replace_by_master_dark(True {include background and SD});
  if img_loaded <> nil then restore_img; {button was used, restore original image array and header}
end;


procedure replace_by_master_flat(full_analyse: boolean);
var
  fitsX, fitsY, flat_count: integer;
  path1, filen, flat_filter, expos: string;
  day, flatdark_exposure, flat_exposure: double;
  c, counter, i: integer;
  specified, classify_exposure: boolean;
  flat_width, flat_dark_width: integer;
  flatdark_used: boolean;
  file_list: array of string;
begin
  with stackmenu1 do
  begin
    save_settings2;
    memo2_message('Analysing flats');
    analyse_listview(listview3, False {light}, False {full fits},
      new_analyse_required3{refresh});{update the tab information. Convert to FITS if required}
    if esc_pressed then exit;{esc could be pressed in analyse}
    new_analyse_required3 := False;
    flatdark_exposure := -99;
    classify_exposure := classify_flat_exposure1.Checked;

    setlength(file_list, stackmenu1.listview3.items.Count);
    repeat
      flat_count := 0;
      specified := False;

      i := stackmenu1.listview3.items.Count - 1;
      for c := 0 to stackmenu1.listview3.items.Count - 1 do
        if stackmenu1.listview3.items[c].Checked = True then
        begin
          filen := stackmenu1.ListView3.items[c].Caption;
          if pos('master_flat', ExtractFileName(filen)) = 0 then {not a master file}
          begin {set specification master}
            if specified = False then
            begin
              flat_filter := stackmenu1.listview3.Items.item[c].subitems.Strings[F_filter];
              flat_width := StrToInt(stackmenu1.listview3.Items.item[c].subitems.Strings[D_width]);
              day := strtofloat(stackmenu1.listview3.Items.item[c].subitems.Strings[F_jd]);
              flat_exposure := strtofloat(stackmenu1.listview3.Items.item[c].subitems.Strings[F_exposure]);
              specified := True;
            end;

            if ((stackmenu1.classify_flat_filter1.Checked = False) or(flat_filter = stackmenu1.listview3.Items.item[c].subitems.Strings[F_filter])) then {filter correct?}
              if flat_width = StrToInt(
                stackmenu1.listview3.Items.item[c].subitems.Strings[D_width]) then {width correct}
                if ((classify_flat_date1.Checked = False) or (abs(day - strtofloat(stackmenu1.listview3.Items.item[c].subitems.Strings[F_jd])) <= 0.5)) then {within 12 hours made}
                  if ((classify_exposure = False) or (abs(flat_exposure - strtofloat(stackmenu1.listview3.Items.item[c].subitems.Strings[F_exposure])) < 0.01)) then  {head.exposure correct?}
                  begin
                    file_list[flat_count] := filen;
                    Inc(flat_count);
                  end;
          end;
        end;{checked}


      Application.ProcessMessages;
      if esc_pressed then exit;

      if flat_count <> 0 then
      begin

        Application.ProcessMessages;
        if esc_pressed then exit;

        if abs(flat_exposure - flatdark_exposure) > 0.01 then  {already a dark loaded?}
        begin
          if classify_exposure = False then
          begin
            flat_exposure := -99; {do not classify on flat dark head.exposure time}
          end
          else
          begin
            analyseflatdarksButton1Click(nil); {head.exposure lengths are required for selection}
            memo2_message('Selecting flat darks with exposure time ' +  floattostrF(flat_exposure, FFgeneral, 0, 2) + 'sec');
          end;
          flat_dark_width := average_flatdarks(flat_exposure);  {average of bias frames. Convert to FITS if required}
          flatdark_exposure := flat_exposure;{store this head.exposure for next time}
          if flat_dark_width = 0 then  memo2_message('█ █ █ █ █ █ Warning no flat-dark/bias found!! █ █ █ █ █ █ ')
          else
          if flat_width <> flat_dark_width then
          begin
            memo2_message('Abort, the width of the flat and flat-dark do not match!!');
            exit;
          end;
          flatdark_used := False;
        end;

        memo2_message('Combining flats.');
        Application.ProcessMessages;
        if esc_pressed then exit;
        average('flat', file_list, flat_count, img_flat); {only average, make color also mono}

        memo2_message('Combining flats and flat-darks.');
        Application.ProcessMessages;
        if esc_pressed then
          exit;

        if flat_count <> 0 then
        begin
          if head.flatdark_count <> 0 then
          begin
            memo2_message('Applying the combined flat-dark on the combined flat.');
            flatdark_used := True;
            for fitsY := 0 to head.Height - 1 do
              for fitsX := 0 to head.Width - 1 do
              begin
                img_flat[0, fitsX, fitsY] := img_flat[0, fitsX, fitsY] - img_bias[0, fitsX, fitsY]; {flats and bias already made mono in procedure average}
              end;
          end;
        end;

        Application.ProcessMessages;
        if esc_pressed then exit;

        head.naxis3 := 1; {any color is made mono in the routine}
        if flat_count <> 0 then
        begin
          flat_filter := extract_letters_only(flat_filter);
          {extract_letter is added for filter='N/A' for SIPS software}
          if flat_filter = '' then  head.filter_name := copy(extractfilename(file_list[0]), 1, 10);{for DSLR images}
          if classify_exposure then
          begin
            str(flat_exposure: 0: 2, expos);
            flat_filter := flat_filter + '_' + expos + 'sec';
          end;
          path1 := extractfilepath(file_list[0]) + 'master_flat_corrected_with_flat_darks_' + flat_filter + '_' + IntToStr(flat_count) + 'xF_' + IntToStr(head.flatdark_count) + 'xFD_' + copy(head.date_obs, 1, 10) + '.fit';
          ;
          update_integer('FLAT_CNT=', ' / Number of flat images combined.                ' , flat_count);
          update_integer('BIAS_CNT=', ' / Number of flat-dark or bias images combined.   ' , head.flatdark_count);
          if head.flatdark_count <> 0 then head.calstat := head.calstat + 'B';
          update_text('CALSTAT =', #39 + head.calstat + #39); {calibration status}

          { ASTAP keyword standard:}
          { interim files can contain keywords: head.exposure, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
          { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

          update_text('COMMENT 1', '  Created by ASTAP www.hnsky.org');
          head.naxis3 := 1; {any color is made mono in the routine. Keywords are updated in the save routine}
          head.naxis := 2;  {any color is made mono in the routine. Keywords are updated in the save routine}

          if save_fits(img_flat, path1, -32, False) then {saved}
          begin
            listview3.Items.BeginUpdate; {remove the flats added to master}
            for i := 0 to flat_count do
            begin
              c := 0;
              counter := listview3.Items.Count;
              while c < counter do
              begin
                if file_list[i] = stackmenu1.ListView3.items[c].Caption then {processed}
                begin
                  listview3.Items.Delete(c);
                  Dec(counter);{one file less}
                end
                else
                  Inc(c);
              end;
            end;
            listview_add(listview3, path1, True, F_nr);{add master}
            listview3.Items.EndUpdate;
            analyse_listview(listview3, False {light}, full_analyse {full fits (for standard deviation)}, False{refresh});{update the tab information}
          end;
          img_flat := nil;
        end;
      end;

      Application.ProcessMessages;
      if esc_pressed then exit;

    until flat_count = 0;{make more than one master}

    if flatdark_used then listview4.Items.Clear;{remove bias if used}
    save_settings2;{store settings}
    file_list := nil;

    memo2_message('Master flat(s) ready.');
  end;{with stackmenu1}
end;


procedure Tstackmenu1.replace_by_master_flat1Click(Sender: TObject);
begin
  if img_loaded <> nil then  {button was used, backup img array and header and restore later}
  begin
    img_backup := nil; {clear to save memory}
    backup_img;
  end;{backup fits for later}
  replace_by_master_flat(True {include measuring background and SD});
  if img_loaded <> nil then restore_img;  {button was used, restore original image array and header}
end;


function create_internal_solution(img: image_array; hd: theader): boolean;  {plate solving, image should be already loaded create internal solution using the internal solver}
begin
  if solve_image(img, hd, True) then {match between loaded image and star database}
  begin
    if fits_file_name(filename2) then
    begin
      Result := savefits_update_header(filename2);
    end
    else
      Result := save_tiff16(img, filename2, False {flip H}, False {flip V});

    if Result = False then ShowMessage('Write error !!' + filename2);
  end
  else
    Result := False;
end;


function apply_dark_and_flat(var img: image_array): boolean; inline; {apply dark and flat if required, renew if different head.exposure or ccd temp}
var
  fitsX, fitsY, k: integer;
  Value, flat_factor, dark_norm_value, flatNorm11, flatNorm12, flatNorm21, flatNorm22, flat_norm_value: double;

begin
  Result := False;
  date_to_jd(head.date_obs, head.exposure {light}); {convert date-obs to global variables jd_start, jd_mid. Use this to find the dark with the best match for the light}

  if pos('D', head.calstat) <> 0 then {is the light already calibrated}
    memo2_message('Skipping dark calibration, already applied. See header keyword CALSTAT')
  else
  begin
    load_master_dark(round(jd_start)); {will only be renewed if different head.exposure or head.set_temperature.}

    if head_2.dark_count > 0 then  {dark and flat use head_2 for status}
    begin
      dark_norm_value := 0;
      for fitsY := (head.Width div 2)-7 to (head.Width div 2)+8 do {do even times, 16x16 for bayer matrix}
        for fitsX := (head.Height div 2)-7 to (head.Height div 2)+8 do
          dark_norm_value := dark_norm_value + img_dark[0, fitsX,fitsY];
      dark_norm_value := dark_norm_value /(16*16);  {scale factor to apply flat. The norm value will result in a factor one for the center.}

      for fitsY := 0 to head.Height - 1 do  {apply the dark}
        for fitsX := 0 to head.Width - 1 do
        begin
          Value := img_dark[0, fitsX, fitsY];{Darks are always made mono when making master dark}
          for k := 0 to head.naxis3 - 1 do {do all colors}
            img[k, fitsX, fitsY] := img[k, fitsX, fitsY] - Value;
        end;

      {for stacking}
      head_ref.calstat := 'D';
      {dark applied, store in header of reference file since it not modified while stacking}
      head_ref.dark_count := head_2.dark_count;
      head_ref.datamax_org := head.datamax_org - dark_norm_value;{adapt light datamax_org}

      {for SQM measurement, live stacking}
      head.calstat := 'D'; {dark applied, store in header of reference file}
      head.dark_count := head_2.dark_count;
      head.datamax_org := head.datamax_org - dark_norm_value;{adapt light datamax_org}
      Result := True;
    end;
  end;{apply dark}

  if pos('F', head.calstat) <> 0 then memo2_message('Skipping flat calibration, already applied. See header keyword CALSTAT')
  else
  begin
    load_master_flat({head.filter_name,head.width,}round(jd_start));
    {will only be renewed if different filter name.  Note load will overwrite head.calstat}
    last_light_jd := round(jd_start);

    if head_2.flat_count <> 0 then
    begin
      flat_norm_value := 0;
      flatNorm11 := 0;
      flatNorm12 := 0;
      flatNorm21 := 0;
      flatNorm22 := 0;

      for fitsY:=(head_2.Width div 2)-7 to (head_2.Width div 2)+8 do {do even times, 16x16 for Bay matrix. For OSC 8x8 pixels for each colour}
        for fitsX:=(head_2.Height div 2)-7 to (head_2.Height div 2)+8 do
        begin
          Value := img_flat[0,fitsX, fitsY];
          flat_norm_value := flat_norm_value + Value;
          if odd(fitsX) then
          begin
            if odd(fitsY) then
              flatNorm11 := flatNorm11 + Value
            else
              flatNorm12 := flatNorm12 + Value
          end
          else
          begin
            if odd(fitsY) then
              flatNorm21 := flatNorm21 + Value
            else
              flatNorm22 := flatNorm22 + Value
          end;
        end;

      flat_norm_value := flat_norm_value/(16*16); {scale factor to apply flat. The norm value will result in a factor one for the center.}

      if process_as_osc > 0 then
      begin  {give only warning when converting to colour. Not when calibrating for green channel and used for photometry}
        if max(max(flatNorm11, flatNorm12), max(flatNorm21, flatNorm22)) / min( min(flatNorm11, flatNorm12), min(flatNorm21, flatNorm22)) > 2.0 then
          memo2_message('█ █ █ █ █ █ Warning flat pixel colour values differ too much. Use white light for OSC flats!!. Will compensate accordingly." █ █ █ █ █ █ ');

        flatNorm11 :={flat_norm_value/ }(flatNorm11 /(8*8));//calculate average norm factor for each colour.
        flatNorm12 :={flat_norm_value/} (flatNorm12 /(8*8));
        flatNorm21 :={flat_norm_value/} (flatNorm21 /(8*8));
        flatNorm22 :={flat_norm_value/} (flatNorm22 /(8*8));

        for fitsY := 1 to head.Height do  {apply the OSC flat}
          for fitsX := 1 to head.Width do
          begin //thread the red, green and blue pixels seperately


            //bias is already combined in flat in combine_flat
            if odd(fitsX) then
            begin
              if odd(fitsY) then
                flat_factor :=  flatNorm11 / (img_flat[0, fitsX - 1, fitsY - 1] + 0.001)  //normalise flat for colour 11
              else
                flat_factor :=  flatNorm12 / (img_flat[0, fitsX - 1, fitsY - 1] + 0.001)  //normalise flat for colour 11  //normalise flat for colour 12
            end
            else
            begin
              if odd(fitsY) then
                flat_factor :=  flatNorm21 / (img_flat[0, fitsX - 1, fitsY - 1] + 0.001)  //normalise flat for colour 11  //normalise flat for colour 21
              else
                flat_factor :=  flatNorm22 / (img_flat[0, fitsX - 1, fitsY - 1] + 0.001)  //normalise flat for colour 11  //normalise flat for colour 22
            end;

            flat_factor:=min(4,max(flat_factor,-4)); {un-used sensor area? Prevent huge gain of areas only containing noise and no flat-light value resulting in very strong disturbing noise or high value if dark is missing. Typical problem for converted RAW's by Libraw}

            img[k, fitsX - 1, fitsY - 1] := img[k, fitsX - 1, fitsY - 1] * flat_factor;
          end;
      end
      else //monochrome images (or weird images already in colour)
      begin
        for k := 0 to head.naxis3 - 1 do {do all colors}
        for fitsY := 1 to head.Height do  {apply the flat}
          for fitsX := 1 to head.Width do
          begin
            flat_factor := flat_norm_value / (img_flat[0, fitsX - 1, fitsY - 1] + 0.001);  {bias is already combined in flat in combine_flat}
            flat_factor:=min(4,max(flat_factor,-4)); {un-used sensor area? Prevent huge gain of areas only containing noise and no flat-light value resulting in very strong disturbing noise or high value if dark is missing. Typical problem for converted RAW's by Libraw}

            img[k, fitsX - 1, fitsY - 1] := img[k, fitsX - 1, fitsY - 1] * flat_factor;
          end;
      end;
      {for stacking}
      head_ref.calstat := head_ref.calstat + 'F' + head_2.calstat{B from flat};
      {mark that flat and bias have been applied. Store in the header of the reference file since it is not modified while stacking}
      head_ref.flat_count := head_2.flat_count;
      head_ref.flatdark_count := head_2.flatdark_count;

      {for SQM measurement, live stacking}
      head.calstat := head.calstat + 'F' + head_2.calstat{B from flat};
      {mark that flat and bias have been applied. Store in the header of the reference file}
      head.flat_count := head_2.flat_count;
      head.flatdark_count := head_2.flatdark_count;
      Result := True;
    end;{flat correction}
  end;{do flat & flat dark}
end;


procedure calibration_only; {calibrate lights only}
var
  c, x, y, col: integer;
  object_to_process, stack_info: string;
begin
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  with stackmenu1 do
  begin
    memo2_message('Calibrating individual files only.');
    for c := 0 to ListView1.items.Count - 1 do {first get solution ignoring the header}
      if ListView1.items[c].Checked = True then
      begin
        try { Do some lengthy operation }
          ListView1.Selected := nil; {remove any selection}
          ListView1.ItemIndex := c;{show wich file is processed}
          Listview1.Items[c].MakeVisible(False);{scroll to selected item}

          progress_indicator(100 * c / ListView1.items.Count - 1, ''); {indicate 0 to 100% for calibration}

          filename2 := ListView1.items[c].Caption;

          {load image}
          Application.ProcessMessages;
          if ((esc_pressed) or (load_fits(filename2, True {light}, True,
            True {update memo, required for updates}, 0, head, img_loaded) = False)) then
          begin
            memo2_message('Error loading file ' + filename2);
            Screen.Cursor := crDefault;
            exit;
          end;

          if apply_dark_and_flat(img_loaded) {apply dark, flat if required, renew if different head.exposure or ccd temp} then
          begin //success added dark or flat
            memo2_message('Calibrating file: ' + IntToStr(c + 1) + '-' + IntToStr(
              ListView1.items.Count - 1) + ' "' + filename2 + '"  to average. Using ' +
              IntToStr(head.dark_count) + ' darks, ' + IntToStr(head.flat_count) +
              ' flats, ' + IntToStr(head.flatdark_count) + ' flat-darks');
            Application.ProcessMessages;

            for Y := 0 to head.Height - 1 do
              for X := 0 to head.Width - 1 do
                for col := 0 to head.naxis3 - 1 do
                begin
                  img_loaded[col, X, Y] := img_loaded[col, X, Y] + 500; {add pedestal to prevent values around zero for very dark skies}
                end;

            head.pedestal:=500;

            if esc_pressed then exit;

            if process_as_osc > 0 then {do demosaic bayer}
              demosaic_bayer(img_loaded); {convert OSC image to colour}
            {head.naxis3 is now 3}

            update_text('COMMENT 1', '  Calibrated by ASTAP. www.hnsky.org');
            update_float('PEDESTAL=',' / Value added during calibration or stacking     ',false ,head.pedestal);//pedestal value added during calibration or stacking
            update_text('CALSTAT =', #39 + head.calstat+#39); {calibration status.}
            add_integer('DARK_CNT=', ' / Darks used for luminance.               '
              , head.dark_count);{for interim lum,red,blue...files. Compatible with master darks}
            add_integer('FLAT_CNT=', ' / Flats used for luminance.               '
              , head.flat_count);{for interim lum,red,blue...files. Compatible with master flats}
            add_integer('BIAS_CNT=', ' / Flat-darks used for luminance.          '
              , head.flatdark_count);{for interim lum,red,blue...files. Compatible with master flats}
            { ASTAP keyword standard:}
            { interim files can contain keywords: head.exposure, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
            { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}


            ListView1.Items.item[c].subitems.Strings[L_calibration] := head.calstat;
            ListView1.Items.item[c].subitems.Strings[L_result] := head.calstat;

            filename2 := StringReplace(ChangeFileExt(filename2, '.fit'), '.fit', '_cal.fit', []); {give new file name }
            memo2_message('█ █ █  Saving calibrated file as ' + filename2);
            save_fits(img_loaded, filename2, -32, True);
            ListView1.items[c].Caption := filename2;//update list. Also used for photometry

            object_to_process := uppercase(ListView1.Items.item[c].subitems.Strings[L_object]); {get a object name}
            stack_info := ' ' + IntToStr(head.flatdark_count) + 'x' + 'FD  ' +
              IntToStr(head.flat_count) + 'x' + 'F  ' +
              IntToStr(head.dark_count) + 'x' + 'D  ' + '1x' + head.filter_name;

            report_results(object_to_process, stack_info, 0, -1{no icon});
            {report result in tab results}

          end //calibration
          else //no change
          begin
            Application.ProcessMessages;
            memo2_message(filename2 + ' No dark of flat found or is already calibrated!!!!');
            if esc_pressed then exit;
          end;
        finally
        end;
      end;
  end;{with stackmenu1 do}

  plot_fits(mainwindow.image1, True, True);{update to last image, activate memo1}

  Screen.Cursor := crDefault;
  memo2_message('Calibration of the individual files is complete. New files are posted in the results tab');
end;


procedure put_best_quality_on_top(var files_to_process: array of TfileToDo);{find the files with the lowest hfd unless an image is larger}
var
  best_quality, quality: double;
  First, best_index, i, width1, largest_width: integer;
  quality_str: string;
  file_to_do: Tfiletodo;
begin
  First := -1;
  largest_width := -1;
  best_index := 999999;
  best_quality := 0;
  for i := 0 to length(files_to_process) - 1 do
  begin
    if length(files_to_process[i].Name) > 1 then {has a filename}
    begin
      stackmenu1.ListView1.Items.item[i].SubitemImages[L_quality] := -1; {remove any older icon_king}

      width1 := StrToInt(stackmenu1.ListView1.Items.item[i].subitems.Strings[L_width]);
      if First = -1 then
      begin
        First := i;
        largest_width := width1;
      end;

      quality_str := stackmenu1.ListView1.Items.item[i].subitems.Strings[L_quality]; {number of stars detected}
      {$ifdef darwin} {MacOS}
      quality_str:=add_unicode('',quality_str);//remove all crowns and thumbs
      {$endif}

      if length(quality_str) > 1 then quality := StrToInt(quality_str)
      else
        quality := 0;{quality equals nr stars /sqr(hfd)}

      if width1 > largest_width then {larger image found, give this one preference}
      begin
        width1 := largest_width;
        best_quality := quality;
        best_index := i;
      end
      else
      if width1 = largest_width then {equal size}
      begin {equal size}
        if quality > best_quality then
        begin
          best_quality := quality;
          best_index := i;
        end;
      end;
    end; {has a file name}
  end;{for loop}

  if best_index < 999999 then {selection worked}
  begin
    if best_index <> First then {swap records, put best quality first}
    begin
      file_to_do := files_to_process[First];
      files_to_process[First] := files_to_process[best_index];
      files_to_process[best_index] := file_to_do;
    end;
    stackmenu1.ListView1.Items.item[best_index].SubitemImages[L_quality] := icon_king;{mark as best quality image}
   {$ifdef darwin} {MacOS}
    {bugfix darwin icons}
    stackmenu1.ListView1.Items.item[best_index].Subitems.strings[L_quality]:=add_unicode('♛',stackmenu1.ListView1.Items.item[best_index].Subitems.strings[L_quality]);//add crown
   {$endif}


    memo2_message('Reference image selected based on quality (star_detections/sqr(hfd)) is: ' + files_to_process[best_index].Name);
  end;
end;



function RemoveSpecialChars(const str: string): string;
  {remove ['.','\','/','*','"',':','|','<','>']}
var {################# initialised variables #########################}
  InvalidChars: set of char = ['.', '\', '/', '*', '"', ':', '|', '<', '>'];
var
  I: integer;
begin
  Result := '';
  for i := 1 to length(str) do
    if not (str[i] in InvalidChars) then Result := Result + str[i];
end;


function propose_file_name(mosaic_mode, add_time: boolean;
  object_to_process, filters_used: string): string; {propose a file name}
var
  hh, mm, ss, ms: word;
begin
  if object_to_process <> '' then Result := object_to_process
  else
    Result := 'no_object';
  if head.date_obs <> '' then Result := Result + ', ' + copy(head.date_obs, 1, 10);
  Result := Result + ', ';
  if mosaic_mode then Result := Result + 'mosaic ';
  if counterR <> 0 then Result := Result + IntToStr(counterR) + 'x' + IntToStr(exposureR) + 'R ';
  if counterG <> 0 then Result := Result + IntToStr(counterG) + 'x' + IntToStr(exposureG) + 'G ';
  if counterB <> 0 then Result := Result + IntToStr(counterB) + 'x' + IntToStr(exposureB) + 'B ';
  if counterRGB <> 0 then Result := Result + IntToStr(counterRGB) + 'x' + IntToStr(exposureRGB) + 'RGB ';
  if counterL <> 0 then Result := Result + IntToStr(counterL) + 'x' + IntToStr(exposureL) + 'L ';
  {head.exposure}
  Result := StringReplace(trim(Result), ' ,', ',', [rfReplaceAll]);
  {remove all spaces in front of comma's}
  telescop := trim(telescop);
  if trim(telescop) <> '' then Result := Result + ', ' + telescop;

  if length(filters_used) > 0 then Result := Result + ', (' + filters_used + ')';
  instrum := trim(instrum);
  if instrum <> '' then Result := Result + ', ' + instrum;
  Result := RemoveSpecialChars(Result);  {slash could be in date but also telescope name like eqmod HEQ5/6}
  if add_time then
  begin
    decodetime(time, hh, mm, ss, ms);
    Result := Result + '_' + leadingzero(hh) + leadingzero(mm) + leadingzero(ss);
  end;
  if pos('Aver', stackmenu1.stack_method1.Text) > 0 then Result := Result + '_average';
  Result := Result + '_stacked.fits';
end;


procedure Tstackmenu1.stack_button1Click(Sender: TObject);
var

  i, c, over_size, over_sizeL, nrfiles, image_counter, object_counter,
  first_file, total_counter, counter_colours: integer;
  filter_name1, filter_name2, defilter, filename3,
  extra1, extra2, object_to_process, stack_info, thefilters                : string;
  lrgb, solution, monofile, ignore, cal_and_align,
  mosaic_mode, sigma_clip, calibration_mode, calibration_mode2, skip_combine,
  success, classify_filter, classify_object, sender_photometry             : boolean;
  startTick: qword;{for timing/speed purposes}
  min_background, max_background,back_gr    : double;
  filters_used: array [0..4] of string;
begin
  save_settings2;{too many lost selected files, so first save settings}
  esc_pressed := False;

  memo2_message('Stack method ' + stack_method1.Text);
  memo2_message('Oversize ' + oversize1.Text + ' pixels');
  mosaic_mode := pos('stich', stackmenu1.stack_method1.Text) > 0;
  sigma_clip := pos('Sigma', stackmenu1.stack_method1.Text) > 0;
  skip_combine := pos('skip', stackmenu1.stack_method1.Text) > 0;
  cal_and_align := pos('alignment', stackmenu1.stack_method1.Text) > 0;  {calibration and alignment only}
  sender_photometry := (Sender = photom_stack1);//stack instruction from photometry tab?
  classify_filter := ((classify_filter1.Checked) and (sender_photometry = False));  //disable classify filter if sender is photom_stack1
  classify_object := ((classify_object1.Checked) and (sender_photometry = False));  //disable classify object if sender is photom_stack1

  if ((stackmenu1.use_manual_alignment1.Checked) and (sigma_clip) and (pos('Comet', stackmenu1.manual_centering1.Text) <> 0)) then memo2_message('█ █ █ █ █ █ Warning, use for comet stacking the stack method "Average"!. █ █ █ █ █ █ ');

  if stackmenu1.use_ephemeris_alignment1.Checked then
  begin
    if length(ephemeris_centering1.Text) <= 1 then
    begin
      memo2_message('█ █ █ █ █ █ Abort, no object selected for ephemeris alignment. At tab alignment, press analyse and select object to align on! █ █ █ █ █ █');
      exit;
    end
    else
      memo2_message('Ephemeris alignment on object ' + ephemeris_centering1.Text);
  end;
  startTick := gettickcount64;

  if img_loaded <> nil then
  begin
    img_backup := nil;  {clear to save memory}
    backup_img;
  end;{backup image array and header for case esc pressed.}

  calibration_mode := pos('Calibration only', stackmenu1.stack_method1.Text) > 0;  //"Calibration only"
  calibration_mode2 := pos('de-mosaic', stackmenu1.stack_method1.Text) > 0;  //"Calibration only. No de-mosaic"


  if ListView1.items.Count <> 0 then
  begin
    memo2_message('Analysing lights.');
    analyse_tab_lights(calibration_mode = False); {analyse any image not done yet. For calibration mode skip hfd and background measurements}
    if esc_pressed then exit;

    if ((calibration_mode2) or (sender_photometry)) then process_as_osc := 0;// do not process as OSC

    if process_as_osc > 0 then
    begin
      if process_as_osc = 2 then
        memo2_message('Colour stack. Forced processing as OSC images. Demosaic method ' +   demosaic_method1.Text)
      else
        memo2_message('Colour stack. OSC images detected. Demosaic method ' +  demosaic_method1.Text);

      if classify_filter{1.checked} then
      begin
        //     memo2_message('■■■■■■■■■■■■■ OSC images. Will uncheck "Classify by filter" ! ■■■■■■■■■■■■■');
        classify_filter{1.checked} := False;
      end;
    end
    else
    if classify_filter{1.checked} then
      memo2_message('LRGB colour stack (classify by light filter checked)')
    else
      memo2_message('Grayscale stack (classify by light filter unchecked)');

    set_icon_stackbutton((process_as_osc > 0) or (classify_filter{1.checked}));  //update glyph stack button to colour or gray
    memo2_message('Stacking (' + stack_method1.Text + '), HOLD ESC key to abort.');
  end
  else
  begin
    memo2_message('Abort, no images to stack! Browse for images, darks and flats.');
    exit;
  end;

  if ListView2.items.Count <> 0 then
  begin
    memo2_message('Analysing darks.');
    replace_by_master_dark(False {include background and SD});
    if esc_pressed then
    begin
      restore_img;
      exit;
    end;
  end;
  if ListView3.items.Count <> 0 then
  begin
    memo2_message('Analysing flats.');
    replace_by_master_flat(False {include background and SD});
    if esc_pressed then
    begin
      restore_img;
      exit;
    end;
  end;

  dark_exposure := 987654321;{not done indication}
  dark_temperature := 987654321;
  dark_gain := '987654321';
  flat_filter := '987654321';{not done indication}

  min_background := 65535;
  max_background := 0;

  if ((calibration_mode) or (calibration_mode2)) then {calibrate lights only}
  begin
    calibration_only;
    if process_as_osc > 0 then Memo2_message('OSC images are converted to colour.');
    Memo2_message('Ready. Resulting files are available in tab Results and can be copied to the Blink, Photometry  or Lights tab.');
    exit;
  end;

  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
  progress_indicator(0, '');

  if use_manual_alignment1.Checked then {check is reference objects are marked}
  begin
    for c := 0 to ListView1.items.Count - 1 do
      if ListView1.items[c].Checked = True then
      begin
        try { Do some lengthy operation }
          ListView1.Selected := nil; {remove any selection}
          ListView1.ItemIndex := c;{show wich file is processed}
          Listview1.Items[c].MakeVisible(False);{scroll to selected item}
          if length(ListView1.Items.item[c].subitems.Strings[L_X]) <= 1 then  {no manual position added}
          begin
            memo2_message( '█ █ █  Abort! █ █ █  Reference object missing for one or more files. Double click on all file names and mark with the mouse the reference object. The file name will then turn green.');
            Screen.Cursor := crDefault;
            exit;
          end;
          Application.ProcessMessages;
        finally
        end;
      end;
  end;{check for manual stacking}

  {activate scrolling memo2}
  stackmenu1.memo2.SelStart := Length(stackmenu1.memo2.Lines.Text);
  stackmenu1.memo2.SelLength := 0;

  if ((use_astrometry_internal1.Checked) or (use_ephemeris_alignment1.Checked)) then
    {astrometric alignment}
  begin
    memo2_message('Checking astrometric solutions');
    if use_ephemeris_alignment1.Checked then
      ignore := stackmenu1.update_solution1.Checked {ephemeris}
    else
      ignore := stackmenu1.ignore_header_solution1.Checked; {stacking}

    for c := 0 to ListView1.items.Count - 1 do
      if ((ListView1.items[c].Checked = True) and
        ((ignore) or (ListView1.Items.item[c].subitems.Strings[L_solution] <>
        '✓')){no internal solution }) then
      begin
        try { Do some lengthy operation }
          ListView1.Selected := nil; {remove any selection}
          ListView1.ItemIndex := c;{show wich file is processed}
          Listview1.Items[c].MakeVisible(False);{scroll to selected item}

          progress_indicator(10 * c / ListView1.items.Count - 1, ' solving');  {indicate 0 to 10% for plate solving}

          filename2 := ListView1.items[c].Caption;
          Application.ProcessMessages;
          if esc_pressed then
          begin
            restore_img;
            Screen.Cursor := crDefault;
            exit;
          end;

          {load file}
          if load_fits(filename2, True {light}, True, True {update memo}, 0, head, img_loaded){important required to check head.cd1_1} = False then
          begin
            memo2_message('Error loading file ' + filename2); {failed to load}
            Screen.Cursor := crDefault;
            exit;
          end;
          if ((head.cd1_1 = 0) or (ignore)) then
            solution := create_internal_solution(img_loaded, head)
          else
            solution := True;

          if solution = False then
          begin {no solution found}
            ListView1.items[c].Checked := False;
            memo2_message('No solution for: "' + filename2 + '" un-checked this file.');
          end {no solution found}
          else
            memo2_message('Astrometric solution for: "' + filename2 + '"');
          if solution then
          begin
            stackmenu1.ListView1.Items.item[c].subitems.Strings[L_solution]:='✓';
            stackmenu1.ListView1.Items.item[c].subitems.Strings[L_position]:= prepare_ra5(head.ra0, ': ') + ', ' + prepare_dec4(head.dec0, '° ');{give internal position}
          end
          else
            stackmenu1.ListView1.Items.item[c].subitems.Strings[L_solution] := ''; {report internal plate solve result}
        finally
        end;
      end;
    memo2_message('Astrometric solutions complete.');

    if mosaic_mode then
    begin
      SortedColumn := L_position + 1;
      listview1.sort;
      memo2_message('Sorted list on RA, DEC position to place tiles in the correct sequence.');
    end;
  end;

  if stackmenu1.auto_rotate1.Checked then {fix rotationss}
  begin
    memo2_message('Checking orientations');
    for c := 0 to ListView1.items.Count - 1 do
      if ((ListView1.items[c].Checked = True) and (stackmenu1.ListView1.Items.item[c].subitems.Strings[L_solution]='✓' {solution})) then
      begin
        try { Do some lengthy operation }
          ListView1.Selected := nil; {remove any selection}
          ListView1.ItemIndex := c;{show wich file is processed}
          Listview1.Items[c].MakeVisible(False);{scroll to selected item}

          progress_indicator(10 * c / ListView1.items.Count - 1, ' rotating'); {indicate 0 to 10% for plate solving}

          filename2 := ListView1.items[c].Caption;

          Application.ProcessMessages;
          if esc_pressed then
          begin
            restore_img;
            Screen.Cursor := crDefault;
            exit;
          end;

          {load file}
          if load_fits(filename2, True {light}, True, True {update memo}, 0, head, img_loaded){important required to check head.cd1_1} = False then
          begin
            memo2_message('Error loading file ' + filename2);{failed to load}
            Screen.Cursor := crDefault;
            exit;
          end;

          head.crota2 := fnmodulo(head.crota2, 360);
          if ((head.crota2 >= 90) and (head.crota2 < 270)) then
          begin
            memo2_message('Rotating ' + filename2 + ' 180°');
            raster_rotate(180, head.Width / 2, head.Height / 2, img_loaded); {fast rotation 180 degrees}
            if nrbits = 16 then save_fits(img_loaded, filename2, 16, True) else save_fits(img_loaded, filename2, -32, True);
          end;

        finally
        end;
      end;
    memo2_message('Orientation task complete.');
  end;

  if use_ephemeris_alignment1.Checked then {add annotations}
  begin
    memo2_message('Checking annotations');
    for c := 0 to ListView1.items.Count - 1 do
      //   and (stackmenu1.ListView1.Items.item[c].subitems.Strings[I_solution]:='✓')and ( length(stackmenu1.ListView1.Items.item[c].subitems.Strings[I_X])<=1){no annotation yet}
      if ((ListView1.items[c].Checked = True) and (stackmenu1.ListView1.Items.item[c].subitems.Strings[L_solution] = '✓' {solution}) and
         ((stackmenu1.update_annotations1.Checked) or (stackmenu1.auto_rotate1.Checked) or (length(stackmenu1.ListView1.Items.item[c].subitems.Strings[L_X]) <= 1)){no annotation yet}) then
      begin
        try { Do some lengthy operation }
          ListView1.Selected := nil; {remove any selection}
          ListView1.ItemIndex := c;{show wich file is processed}
          Listview1.Items[c].MakeVisible(False);{scroll to selected item}

          progress_indicator(10 * c / ListView1.items.Count - 1, ' annotations'); {indicate 0 to 10% for plate solving}

          filename2 := ListView1.items[c].Caption;
          memo2_message('Adding annotations to FITS header and X,Y positions of selected object to list for ' + filename2);

          Application.ProcessMessages;
          if esc_pressed then
          begin
            restore_img;
            Screen.Cursor := crDefault;
            exit;
          end;

          {load file}
          if load_fits(filename2, True {light}, True, True {update memo}, 0, head, img_loaded){important required to check head.cd1_1} = False then
          begin
            memo2_message('Error loading file ' + filename2); {failed to load}
            Screen.Cursor := crDefault;
            exit;
          end;
          plot_mpcorb(StrToInt(maxcount_asteroid), strtofloat2(maxmag_asteroid), True {add_annotations});

          if fits_file_name(filename2) then
            success := savefits_update_header(filename2)
          else
            success := save_tiff16_secure(img_loaded, filename2);{guarantee no file is lost}
          if success = False then
          begin
            ShowMessage('Write error !!' + filename2);
            Screen.Cursor := crDefault;
            exit;
          end;

          get_annotation_position;{fill the x,y with annotation position}
        finally
        end;
      end;
    memo2_message('Annotations complete.');
  end;

  progress_indicator(10, '');
  Application.ProcessMessages;
  if esc_pressed then
  begin
    restore_img;
    Screen.Cursor := crDefault;
    exit;
  end;

  object_counter := 0;
  total_counter := 0;

  head.dark_count := 0;{reset only once, but keep if dark is loaded}
  head.flat_count := 0;{reset only once, but keep if flat is loaded}
  head.flatdark_count := 0;{reset only once}

  for c := 0 to ListView1.items.Count - 1 do
  begin
    ListView1.Items.item[c].SubitemImages[L_result] := -1;{remove any icons. Mark third columns as not done using the image index of first column}
    ListView1.Items.item[c].subitems.Strings[L_result] := '';{no stack result}
  end;

  repeat {do all objects}
    image_counter := 0;
    object_to_process := ''; {blank do this object}
    extra1 := ''; {reset always for object loop}
    extra2 := ''; {reset always for object loop}
    counterR := 0;
    counterG := 0;
    counterB := 0;
    counterRGB := 0;
    counterL := 0;
    monofile := False;{mono file success}
    head.light_count := 0;
    counter_colours := 0;{number of lrgb colours added}

    counterRdark := 0;
    counterGdark := 0;
    counterBdark := 0;
    counterRGBdark := 0;
    counterLdark := 0;

    counterRflat := 0;
    counterGflat := 0;
    counterBflat := 0;
    counterRGBflat := 0;
    counterLflat := 0;

    counterRbias := 0;
    counterGbias := 0;
    counterBbias := 0;
    counterRGBbias := 0;
    counterLbias := 0;

    exposureR := 0;
    exposureG := 0;
    exposureB := 0;
    exposureRGB := 0;
    exposureL := 0;
    for i := 0 to 4 do filters_used[i] := '';
    Inc(object_counter);

    lrgb := ((classify_filter{1.checked}) and (cal_and_align = False)); {ignore lrgb for calibration and alignment is true}
    over_size := round(strtofloat2(stackmenu1.oversize1.Text));{accept also commas but round later}
    if lrgb = False then
    begin
      SetLength(files_to_process, ListView1.items.Count);{set array length to listview}
      nrfiles := 0;

      for c := 0 to ListView1.items.Count - 1 do
      begin
        files_to_process[c].Name := '';{mark empthy}
        files_to_process[c].listviewindex := c; {use same index as listview1 except when later put lowest HFD first}
        if ((ListView1.items[c].Checked = True) and (ListView1.Items.item[c].SubitemImages[L_result] < 0)) then {not done yet}
        begin
          if object_to_process = '' then object_to_process := uppercase(ListView1.Items.item[c].subitems.Strings[L_object]); {get a object name to stack}
          if ((classify_object{1.checked} = False) or (mosaic_mode){ignore object name in mosaic} or ((object_to_process <> '') and (object_to_process = uppercase(ListView1.Items.item[c].subitems.Strings[L_object]))))
          then
            {correct object?}
          begin {correct object}
            files_to_process[c].Name := ListView1.items[c].Caption;
            Inc(image_counter);{one image more}

            ListView1.Items.item[c].SubitemImages[L_result] := 5; {mark 3th columns as done using a stacked icon}
            ListView1.Items.item[c].subitems.Strings[L_result] := IntToStr(object_counter) + '  ';{show image result number}


            {$ifdef darwin} {MacOS}
            {bugfix darwin green red colouring}
            if length(ListView1.Items.item[c].subitems.Strings[L_X])>1 then {manual position added, colour it}
              ListView1.Items.item[c].subitems.Strings[L_result]:='✓ star'+ListView1.Items.item[c].subitems.Strings[L_result];
            {$endif}

            Inc(nrfiles);
            if mosaic_mode then
            begin
              back_gr := strtofloat2(ListView1.Items.item[c].subitems.Strings[L_background]);
              min_background := min(back_gr, min_background);
              max_background := max(back_gr, max_background);
            end;
          end;
        end;
      end;
      if nrfiles > 1 then {need at least two files to sort}
      begin
        if mosaic_mode = False then put_best_quality_on_top(files_to_process);
        {else already sorted on position to be able to test overlapping of background difference in unit_stack_routines. The tiles have to be plotted such that they overlap for measurement difference}

        if sigma_clip then
        begin
          if length(files_to_process) <= 5 then memo2_message('█ █ █ █ █ █ Method "Sigma Clip average" does not work well for a few images. Try method "Average". █ █ █ █ █ █ ');
          stack_sigmaclip(over_size, process_as_osc,{var}files_to_process, counterL);
          {sigma clip combining}
        end
        else
        if mosaic_mode then
          stack_mosaic(over_size,{var}files_to_process, abs(max_background - min_background), counterL){mosaic combining}
        else
        if cal_and_align then {calibration & alignment only}
        begin
          memo2_message('---------- Calibration & alignment for object: ' + object_to_process + ' -----------');
          calibration_and_alignment(over_size, process_as_osc, {var}files_to_process, counterL);{saturation clip average}
        end
        else
          stack_average(over_size, process_as_osc,{var}files_to_process, counterL);
        {average}

        if counterL > 0 then
        begin
          exposureL := round(sum_exp / counterL); {average head.exposure}
          temperatureL := round(sum_temp / counterL); {average head.exposure}
          monofile := True;{success}
        end;

        if esc_pressed then
        begin
          progress_indicator(-2, 'ESC');
          restore_img;
          Screen.Cursor := crDefault;
          { back to normal }  exit;
        end;

      end
      else
      begin
        counterL := 0; {number of files processed}
        monofile := False;{stack failure}
      end;
    end
    else
    begin {lrgb lights, classify on filter is true}
      SetLength(files_to_process_LRGB, 6);{will contain [reference,r,g,b,colour,l]}
      for i := 0 to 5 do files_to_process_LRGB[i].Name := '';{clear}

      SetLength(files_to_process, ListView1.items.Count);{set array length to listview}

      for i := 0 to 4 do
      begin
        case i of
          0: begin
            filter_name1 := (red_filter1.Text);
            filter_name2 := (red_filter2.Text);
          end;
          1: begin
            filter_name1 := (green_filter1.Text);
            filter_name2 := (green_filter2.Text);
          end;
          2: begin
            filter_name1 := (blue_filter1.Text);
            filter_name2 := (blue_filter2.Text);
          end;
          3: begin
            filter_name1 := 'colour';
            filter_name2 := 'Colour';
          end;
          else
          begin
            filter_name1 := (luminance_filter1.Text);
            filter_name2 := (luminance_filter2.Text);
          end;
        end;{case}
        nrfiles := 0;

        for c := 0 to ListView1.items.Count - 1 do
        begin
          files_to_process[c].Name := '';{mark as empthy}
          files_to_process[c].listviewindex := c; {use same index as listview except when later put lowest HFD first}
          if ((ListView1.items[c].Checked = True) and (ListView1.Items.item[c].SubitemImages[L_result]<0){not yet done} and (length(ListView1.Items.item[c].subitems.Strings[L_filter])>0) {skip any file without a filter name}) then
          begin  {not done yet}
            if object_to_process = '' then object_to_process := uppercase(ListView1.Items.item[c].subitems.Strings[L_object]); {get a next object name to stack}

            if ((classify_object{1.checked} = False) or (mosaic_mode) {ignore object name in mosaic} or ((object_to_process <> '') and (object_to_process = uppercase(ListView1.Items.item[c].subitems.Strings[L_object])))) {correct object?} then
            begin {correct object}
              defilter := ListView1.Items.item[c].subitems.Strings[L_filter];
              if ((AnsiCompareText(filter_name1, defilter) = 0) or
                (AnsiCompareText(filter_name2, defilter) = 0)) then
              begin {correct filter}
                filters_used[i] := defilter;
                files_to_process[c].Name := ListView1.items[c].Caption;
                Inc(image_counter);{one image more}
                ListView1.Items.item[c].SubitemImages[L_result] := 5;
                {mark 3th columns as done using a stacked icon}
                ListView1.Items.item[c].subitems.Strings[L_result] := IntToStr(object_counter) + '  ';{show image result number}
                Inc(nrfiles);
                first_file := c; {remember first found for case it is the only file}
                head.exposure := strtofloat2(ListView1.Items.item[c].subitems.Strings[L_exposure]); {remember head.exposure time in case only one file, so no stack so unknown}
                if mosaic_mode then
                begin
                  back_gr := strtofloat2( ListView1.Items.item[c].subitems.Strings[L_background]);
                  min_background := min(back_gr, min_background);
                  max_background := max(back_gr, max_background);
                end;
              end;
            end;
          end;
        end;
        if nrfiles > 0 then
        begin
          if nrfiles > 1 then {more than one file}
          begin
            if mosaic_mode = False then put_best_quality_on_top(files_to_process); {else already sorted on position to be able to test overlapping of background difference in unit_stack_routines. The tiles have to be plotted such that they overlap for measurement difference}

            if sigma_clip then
              stack_sigmaclip(over_size, process_as_osc,{var}files_to_process, counterL) {sigma clip combining}
            else
            if mosaic_mode then
              stack_mosaic(over_size,{var}files_to_process, abs(max_background - min_background), counterL){mosaic combining}
            else
              stack_average(over_size, process_as_osc,{var}files_to_process, counterL);{average}
            over_sizeL := 0; {do oversize only once. Not again in 'L' mode !!}
            if esc_pressed then
            begin
              progress_indicator(-2, 'ESC');
              restore_img;
              Screen.Cursor := crDefault;{ back to normal }
              exit;
            end;

            if ((over_size <> 0) and (head.cd1_1 <> 0){solution}) then {adapt astrometric solution for intermediate file}
            begin {adapt reference pixels of plate solution due to oversize}
              head.crpix1 := head.crpix1 + over_size;
              if over_size > 0 then
                head.crpix2 := head.crpix2 + over_size
              else
                head.crpix2 := head.crpix2 + round(over_size * head.Height / head.Width);  {if oversize is negative then shrinking is done in ratio. Y shrinkage is done with factor round(oversize*height/width. Adapt head.crpix2 accordingly.}
              update_float('CRPIX1  =', ' / X of reference pixel                           ',false, head.crpix1);
              update_float('CRPIX2  =', ' / Y of reference pixel                           ',false, head.crpix2);
            end;

            update_text('COMMENT 1', '  Written by ASTAP. www.hnsky.org');
            update_text('CALSTAT =', #39 + head.calstat + #39);

            if pos('D', head.calstat) > 0 then
            begin
              update_integer('DATAMAX =', ' / Maximum data value                             ', round(head.datamax_org)); {datamax is updated in stacking process. Use the last one}
              update_integer('DATAMIN =', ' / Minimum data value                             ', round(pedestal_s));
              add_text('COMMENT ', ' D=' + ExtractFileName(last_dark_loaded));
            end;
            if pos('F', head.calstat) > 0 then
              add_text('COMMENT ', ' F=' + ExtractFileName(last_flat_loaded));

            if sigma_clip then
              update_text('HISTORY 1', '  Stacking method SIGMA CLIP AVERAGE')
            else
              update_text('HISTORY 1', '  Stacking method AVERAGE');

            update_text('HISTORY 2', '  Active filter: ' + head.filter_name);  {show which filter was used to combine}   {original head.exposure is still maintained  }
            add_integer('LIGH_CNT=', ' / Light frames combined.                  ', counterL);       {for interim lum,red,blue...files.}
            add_integer('DARK_CNT=', ' / Darks used for luminance.               ', head.dark_count);{for interim lum,red,blue...files. Compatible with master darks}
            add_integer('FLAT_CNT=', ' / Flats used for luminance.               ', head.flat_count);{for interim lum,red,blue...files. Compatible with master flats}
            add_integer('BIAS_CNT=', ' / Flat-darks used for luminance.          ', head.flatdark_count);{for interim lum,red,blue...files. Compatible with master flats}
            { ASTAP keyword standard:}
            { interim files can contain keywords: head.exposure, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
            { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

            stack_info := ' ' + IntToStr(head.flatdark_count) + 'x' + 'FD  ' + IntToStr(head.flat_count) + 'x' + 'F  ' + IntToStr(head.dark_count) + 'x' + 'D  ' +  IntToStr(counterL) + 'x' + RemoveSpecialChars(head.filter_name);//filter filter_name for e.g. G/Oiii

            filename3 := filename2;
            filename2 := StringReplace(ChangeFileExt(filename2, '.fit'),'.fit', '@ ' + stack_info + '_stacked.fit', []); {give new file name for any extension, FIT, FTS, fits}
            memo2_message('█ █ █ Saving as ' + filename2);
            save_fits(img_loaded, filename2, -32, True {override});
            files_to_process_LRGB[i + 1].Name := filename2;{should contain [nil,r,g,b,l]}

            if ((AnsiCompareText(luminance_filter1.Text, filters_used[i]) = 0) or (AnsiCompareText(luminance_filter2.Text, filters_used[i]) = 0)) then
            begin
              files_to_process_LRGB[5].Name := filename2;
              {use this colour also for luminance!!}
              filters_used[4] := filters_used[i];{store luminance filter}
              memo2_message('Filter ' + filters_used[i] + ' will also be used for luminance.');
            end;

            stack_info := 'Interim result ' + head.filter_name + ' x ' + IntToStr(counterL);
            report_results(object_to_process, stack_info, object_counter, i {color icon}); {report result in tab result using modified filename2}
            filename2 := filename3;{restore last filename}
            extra1 := extra1 + head.filter_name;
          end{nrfiles>1}
          else
          begin
            files_to_process_LRGB[i + 1] := files_to_process[first_file];
            {one file, no need to stack}

            if ((AnsiCompareText(luminance_filter1.Text, filters_used[i]) = 0) or (AnsiCompareText(luminance_filter2.Text, filters_used[i]) = 0)) then
            begin
              files_to_process_LRGB[5] := files_to_process[first_file]; {use this colour also for luminance!!}
              filters_used[4] := filters_used[i];{store luminance filter}
              memo2_message('Filter ' + filters_used[i] + ' will also be used for luminance.');
            end;
            over_sizeL := over_size;{do oversize in 'L'  routine}
            counterL := 1;
          end;

          case i of
            0: begin extra2 := extra2 + 'R'; end;
            1: begin extra2 := extra2 + 'G'; end;
            2: begin extra2 := extra2 + 'B'; end;
            3: begin extra2 := extra2 + '-'; end;
            else
            begin extra2 := extra2 + 'L'; end;
          end;{case}

          //   extra1:=extra1+head.filter_name;
        end;
      end;{for loop for 4 RGBL}

      if skip_combine = False then
      begin {combine colours}
        if length(extra2) >= 2 then {at least two colors required}
        begin
          files_to_process_LRGB[0] := files_to_process_LRGB[5]; {use luminance as reference for alignment}{contains, REFERENCE, R,G,B,RGB,L}
          if files_to_process_LRGB[0].Name = '' then files_to_process_LRGB[0] := files_to_process_LRGB[1]; {use red channel as reference if no luminance is available}
          if files_to_process_LRGB[0].Name = '' then files_to_process_LRGB[0] := files_to_process_LRGB[2]; {use green channel as reference if no luminance is available}
          counterL := 0; //reset counter for case no Luminance files are available, so RGB stacking.
          stack_LRGB(over_sizeL {zero if already stacked from several files}, files_to_process_LRGB, counter_colours); {LRGB method, files_to_process_LRGB should contain [REFERENCE, R,G,B,RGB,L]}
          if esc_pressed then
          begin
            progress_indicator(-2, 'ESC');
            restore_img;
            Screen.Cursor := crDefault;
            { back to normal }  exit;
          end;
        end
        else
        if length(extra2) = 1 then
        begin
          memo2.Lines.add('Error! One colour only. For LRGB stacking a minimum of two colours is required. Remove the check mark for classify on "Light filter" or add images made with a different optical filter.');
          lrgb := False;{prevent runtime errors with head.naxis3=3}
        end;
      end;
    end;

    Screen.Cursor := crDefault;  { Always restore to normal }
    if esc_pressed then
    begin
      progress_indicator(-2, 'ESC');
      restore_img;
      exit;
    end;


    if ((cal_and_align = False) and (skip_combine = False)) then
      {do not do this for calibration and alignment only, and skip combine}
    begin  //fits_file:=true;
      nrbits := -32;  {by definition. Required for stacking 8 bit files. Otherwise in the histogram calculation stacked data could be all above data_max=255}

      if ((monofile){success none lrgb loop} or (counter_colours <> 0{length(extra2)>=2} {lrgb loop})) then
      begin
        if counter_colours <> 0{length(extra2)>=2} {lrgb loop} then
        begin
          if stackmenu1.lrgb_auto_level1.Checked then
          begin
            memo2_message('Adjusting colour levels as set in tab "stack method"');
            stackmenu1.auto_background_level1Click(nil);
            apply_factors;{histogram is after this action invalid}
            stackmenu1.reset_factors1Click(nil);{reset factors to default}

            if stackmenu1.green_purple_filter1.Checked then
            begin
              memo2_message('Applying "remove green and purple" filter');
              green_purple_filter(img_loaded);
            end;

            use_histogram(img_loaded, True {update}); {plot histogram, set sliders}

            if stackmenu1.lrgb_colour_smooth1.Checked then
            begin
              memo2_message('Applying colour-smoothing filter image as set in tab "stack method"');
              smart_colour_smooth(img_loaded, strtofloat2(
                lrgb_smart_smooth_width1.Text), strtofloat2(lrgb_smart_colour_sd1.Text),
                lrgb_preserve_r_nebula1.Checked, False {get  hist});{histogram doesn't needs an update}
            end;
          end
          else
          begin
            memo2_message('Adjusting colour levels and colour smooth are disabled. See tab "stack method"');
            use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
          end;
        end
        else
        begin
          if process_as_osc > 0 then
          begin
            if stackmenu1.osc_auto_level1.Checked then
            begin
              memo2_message('Adjusting colour levels as set in tab "stack method"');
              stackmenu1.auto_background_level1Click(nil);
              apply_factors;{histogram is after this action invalid}
              stackmenu1.reset_factors1Click(nil);{reset factors to default}
              use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
              if stackmenu1.osc_colour_smooth1.Checked then
              begin
                memo2_message( 'Applying colour-smoothing filter image as set in tab "stack method".');
                smart_colour_smooth(img_loaded, strtofloat2(osc_smart_smooth_width1.Text), strtofloat2(osc_smart_colour_sd1.Text), osc_preserve_r_nebula1.Checked, False {get  hist});{histogram doesn't needs an update}
              end;
            end
            else
            begin
              memo2_message('Adjusting colour levels and colour smooth are disabled. See tab "stack method"');
              use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
            end;
          end
          else {mono files}
            use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
        end;

        plot_fits(mainwindow.image1, True, True);{plot real}

        remove_key('DATE    ', False{all});{no purpose anymore for the original date written}
        remove_key('EXPTIME', False{all}); {remove, will be added later in the header}
        remove_key('EXPOSURE', False{all});{remove, will be replaced by LUM_EXP, RED_EXP.....}
        remove_key('CCD-TEMP', False{all});{remove, will be replaced by SET-TEMP.....}
        remove_key('SET-TEMP', False{all});{remove, will be added later in mono or for colour as LUM_TEMP, RED_TEMP.....}
        remove_key('LIGH_CNT', False{all});{remove, will be replaced by LUM_CNT, RED_CNT.....}
        remove_key('DARK_CNT', False{all});{remove, will be replaced by LUM_DARK, RED_DARK.....}
        remove_key('FLAT_CNT', False{all});{remove, will be replaced by LUM_FLAT, RED_FLAT.....}
        remove_key('BIAS_CNT', False{all});{remove, will be replaced by LUM_BIAS, RED_BIAS.....}

        { ASTAP keyword standard:}
        { interim files can contain keywords: EXPTIME, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
        { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}

        update_text('COMMENT 1', '  Written by ASTAP. www.hnsky.org');

        head.calstat := head.calstat + 'S'; {status stacked}
        update_float  ('PEDESTAL=',' / Value added during calibration or stacking     ',false ,head.pedestal);//pedestal value added during calibration or stacking
        update_text('CALSTAT =', #39 + head.calstat + #39); {calibration status}

        if use_manual_alignment1.Checked = False then
          {don't do this for manual stacking and moving object. Keep the date of the reference image for correct annotation of asteroids}
        begin
          head.date_obs := jdToDate(jd_stop);
          update_text('DATE-OBS=', #39 + head.date_obs + #39);{give start point exposures}
          if ((head.naxis3 = 1) and (counterL > 0)) then {works only for mono}
          begin
            update_float('JD-AVG  =',' / Julian Day of the observation mid-point.       ',false, jd_sum / counterL);{give midpoint of exposures}
            date_avg := JdToDate(jd_sum / counterL);  {update date_avg for asteroid annotation}
            update_text('DATE-AVG=', #39 + date_avg + #39);{give midpoint of exposures}
            head.date_obs := JdToDate((jd_sum / counterL) - head.exposure / (2 * 24 * 60 * 60));{Estimate for date obs for stack. Accuracy could vary due to lost time between exposures};
            update_text('DATE-OBS=', #39 + head.date_obs + #39 + '/ Calculated for stack JD_AVG - EXPTIME/(2*86400)'); //add_text   ('COMMENT ',' UT midpoint in decimal notation: '+ UTdecimal(date_avg));
          end;
        end
        else;{keep head.date_obs from reference image for accurate asteroid annotation}

        if pos('D', head.calstat) > 0 then
          add_text('COMMENT ', '   D=' + ExtractFileName(last_dark_loaded));
        if pos('F', head.calstat) > 0 then
          add_text('COMMENT ', '   F=' + ExtractFileName(last_flat_loaded));

        if sigma_clip then
          update_text('HISTORY 1', '  Stacking method SIGMA CLIP AVERAGE')
        else
          update_text('HISTORY 1', '  Stacking method AVERAGE');{overwrite also any existing header info}

        if head.naxis3 > 1 then
        begin
          if process_as_osc > 0 then
          begin
            remove_key('BAYERPAT', False{all});{remove key word in header}
            remove_key('XBAYROFF', False{all});{remove key word in header}
            remove_key('YBAYROFF', False{all});{remove key word in header}
            update_text('HISTORY 2', '  De-mosaic bayer pattern used ' + bayer_pattern[bayerpattern_final]);
            update_text('HISTORY 3', '  Colour conversion: ' + stackmenu1.demosaic_method1.Text + ' interpolation.');
          end
          else
            update_text('HISTORY 2', '  Combined to colour image.');
        end
        else
          update_text('HISTORY 2', '  Processed as gray scale images.');

        if lrgb = False then {monochrome}
        begin {adapt astrometric solution. For colour this is already done during luminance stacking}
          if ((over_size <> 0) and (head.cd1_1 <> 0){solution}) then
            {adapt astrometric solution for intermediate file}
          begin {adapt reference pixels of plate solution due to oversize}
            head.crpix1 := head.crpix1 + over_size;
            if over_size > 0 then
              head.crpix2 := head.crpix2 + over_size
            else
              head.crpix2 := head.crpix2 + round(over_size * head.Height / head.Width); {if oversize is negative then shrinking is done in ratio. Y shrinkage is done with factor round(oversize*height/width. Adapt head.crpix2 accordingly.}
            update_float('CRPIX1  =', ' / X of reference pixel                           ',false, head.crpix1);
            update_float('CRPIX2  =', ' / Y of reference pixel                           ',false, head.crpix2);
          end;

          head.exposure := sum_exp;{for annotation asteroid}
          update_integer('EXPTIME =', ' / Total luminance exposure time in seconds.      ', round(head.exposure));
          update_integer('SET-TEMP=', ' / Average set temperature used for luminance.    ', temperatureL);
          add_integer('LUM_EXP =', ' / Average luminance exposure time.               ', exposureL);
          add_integer('LUM_CNT =', ' / Luminance images combined.                     ', counterL);
          add_integer('LUM_DARK=', ' / Darks used for luminance.                      ', head.dark_count);
          add_integer('LUM_FLAT=', ' / Flats used for luminance.                      ', head.flat_count);
          add_integer('LUM_BIAS=', ' / Flat-darks used for luminance.                 ', head.flatdark_count);

          thefilters := head.filter_name; {used later for file name}
          stack_info := ' ' + IntToStr(head.flatdark_count) + 'x' + 'FD  ' + IntToStr(head.flat_count) + 'x' + 'F  ' + IntToStr(head.dark_count) + 'x' + 'D  ' + IntToStr(counterL) + 'x' + IntToStr(exposureL) +  'L  (' + thefilters + ')';
          {head.exposure}
        end
        else {made LRGB color}
        begin
          head.naxis := 3; {will be written in save routine}
          head.naxis3 := 3;{will be written in save routine, head.naxis3 is updated in  save_fits}
          if length(extra2) > 1 then update_text('FILTER  =', #39 + '        ' + #39); {wipe filter info}
          head.exposure := exposureL * counterL;{for annotation asteroid}
          update_integer('EXPTIME =', ' / Total luminance exposure time in seconds.      ' , round(head.exposure)); {could be used for midpoint. Download time are not included, so it is not perfect}

          if counterL > 0 then  //counter number of luminance used in LRGB stacking
          begin
            add_integer('LUM_EXP =', ' / Luminance exposure time.                       ' , exposureL);
            add_integer('LUM_CNT =', ' / Luminance images combined.                     ' , counterL);
            add_integer('LUM_DARK=', ' / Darks used for luminance.                      ' , counterLdark);
            add_integer('LUM_FLAT=', ' / Flats used for luminance.                      ' , counterLflat);
            add_integer('LUM_BIAS=', ' / Flat-darks used for luminance.                 ' , counterLbias);
            add_integer('LUM_TEMP=', ' / Average set temperature used for luminance.    ' , temperatureL);
          end;
          if counterR > 0 then
          begin
            add_integer('RED_EXP =', ' / Red exposure time.                             ', exposureR);
            add_integer('RED_CNT =', ' / Red filter images combined.                    ', counterR);
            add_integer('RED_DARK=', ' / Darks used for red.                            ', counterRdark);
            add_integer('RED_FLAT=', ' / Flats used for red.                            ', counterRflat);
            add_integer('RED_BIAS=', ' / Flat-darks used for red.                       ', counterRbias);
            add_integer('RED_TEMP=', ' / Set temperature used for red.                  ', temperatureR);
          end;
          if counterG > 0 then
          begin
            add_integer('GRN_EXP =', ' / Green exposure time.                           ' , exposureG);
            add_integer('GRN_CNT =', ' / Green filter images combined.                  ' , counterG);
            add_integer('GRN_DARK=', ' / Darks used for green.                          ' , counterGdark);
            add_integer('GRN_FLAT=', ' / Flats used for green.                          ' , counterGflat);
            add_integer('GRN_BIAS=', ' / Flat-darks used for green.                     ' , counterGbias);
            add_integer('GRN_TEMP=', ' / Set temperature used for green.                ' , temperatureG);
          end;
          if counterB > 0 then
          begin
            add_integer('BLU_EXP =', ' / Blue exposure time.                            ' , exposureB);
            add_integer('BLU_CNT =', ' / Blue filter images combined.                   ' , counterB);
            add_integer('BLU_DARK=', ' / Darks used for blue.                           ' , counterBdark);
            add_integer('BLU_FLAT=', ' / Flats used for blue.                           ' , counterBflat);
            add_integer('BLU_BIAS=', ' / Flat-darks used for blue.                      ' , counterBbias);
            add_integer('BLU_TEMP=', ' / Set temperature used for blue.                 ' , temperatureB);
          end;
          if counterRGB > 0 then
          begin
            add_integer('RGB_EXP =', ' / OSC exposure time.                             ' , exposureRGB);
            add_integer('RGB_CNT =', ' / OSC images combined.                           ' , counterRGB);
            add_integer('RGB_DARK=', ' / Darks used for OSC.                            ' , counterRGBdark);
            add_integer('RGB_FLAT=', ' / Flats used for OSC.                            ' , counterRGBflat);
            add_integer('RGB_BIAS=', ' / Flat-darks used for OSC.                       ' , counterRGBbias);
            add_integer('RGB_TEMP=', ' / Set temperature used for OSC.                  ' , temperatureRGB);
          end;

          if counterL > 0 then add_text('COMMENT 2', '  Total luminance exposure ' + IntToStr( round(counterL * exposureL)) + ', filter ' + filters_used[4]);
          if counterR > 0 then add_text('COMMENT 3', '  Total red exposure       ' + IntToStr( round(counterR * exposureR)) + ', filter ' + filters_used[0]);
          if counterG > 0 then add_text('COMMENT 4', '  Total green exposure     ' + IntToStr( round(counterG * exposureG)) + ', filter ' + filters_used[1]);
          if counterB > 0 then add_text('COMMENT 5', '  Total blue exposure      ' + IntToStr( round(counterB * exposureB)) + ', filter ' + filters_used[2]);
          if counterRGB > 0 then add_text('COMMENT 6', '  Total RGB exposure      ' + IntToStr(round(counterRGB * exposureRGB)) + ', filter ' + filters_used[3]);
          { ASTAP keyword standard:}
          { interim files can contain keywords: EXPTIME, FILTER, LIGHT_CNT,DARK_CNT,FLAT_CNT, BIAS_CNT, SET_TEMP.  These values are written and read. Removed from final stacked file.}
          { final files contains, LUM_EXP,LUM_CNT,LUM_DARK, LUM_FLAT, LUM_BIAS, RED_EXP,RED_CNT,RED_DARK, RED_FLAT, RED_BIAS.......These values are not read}


          thefilters := '';
          for i := 0 to 4 do if length(filters_used[i]) > 0 then thefilters := thefilters + ' ' + filters_used[i];
          thefilters := trim(thefilters);

          stack_info := ' ' + IntToStr(head.flatdark_count) + 'x' + 'FD  ' +
            IntToStr(head.flat_count) + 'x' + 'F  ' +
            IntToStr(head.dark_count) + 'x' + 'D  ' +
            IntToStr(counterR) + 'x' + IntToStr(exposureR) + 'R  ' +
            IntToStr(counterG) + 'x' + IntToStr(exposureG) + 'G  ' +
            IntToStr(counterB) + 'x' + IntToStr(exposureB) + 'B  ' +
            IntToStr(counterRGB) + 'x' + IntToStr(exposureRGB) + 'RGB  ' +
            IntToStr(counterL) + 'x' + IntToStr(exposureL) + 'L  (' + thefilters + ')';
          {head.exposure}
        end;

        filename2 := extractfilepath(filename2) + propose_file_name(mosaic_mode, stackmenu1.add_time1.Checked {tab results} or sender_photometry, object_to_process, thefilters);{give it a nice file name}

        if head.cd1_1 <> 0 then memo2_message('Astrometric solution reference file preserved for stack.');
        memo2_message('█ █ █  Saving result ' + IntToStr(image_counter) + ' as ' + filename2);

        if save_fits(img_loaded, filename2, -32, True) = False then exit;
        if save_settings_image_path1.Checked then save_settings(changefileext(filename2, '.cfg'));


        if head.naxis3 > 1 then report_results(object_to_process, stack_info, object_counter, 3 {color icon}) {report result in tab results}
        else
          report_results(object_to_process, stack_info, object_counter, 4 {gray icon});{report result in tab results}

        {close the window}
      end; {not zero count}
    end; {not calibration and alignment}
    Application.ProcessMessages;{look for keyboard instructions}
    total_counter := total_counter + counterL; {keep record of lights done}

  until ((counterL = 0){none lrgb loop} and (extra1 = ''){lrgb loop});{do all names}


  if ((total_counter = 0) and (image_counter = 0)) then {somehow nothing was stacked}
  begin
    memo2.Lines.add('No images in tab lights to stack.');
    if classify_filter{1.checked} then memo2.Lines.add('Hint: remove check mark from classify by "light filter" if required.');
    if classify_object{1.checked} then memo2.Lines.add('Hint: remove check mark from classify by "light object" if required.');
    if use_astrometry_internal1.Checked then memo2.Lines.add('Hint: check field of view camera in tab alignment.');
  end
  else
    memo2.Lines.add('Finished in ' + IntToStr(round((gettickcount64 - startTick) / 1000)) +' sec. The FITS header contains a detailed history.');


  {$IFDEF fpc}
  progress_indicator(-100,'');{back to normal}
  {$else}{delphi}
  mainwindow.taskbar1.progressstate := TTaskBarProgressState.None;
  {$endif}

  update_menu(True);

  img_temp := nil;{remove used memory}
  img_average := nil;
  img_final := nil;
  img_variance := nil;

  if write_log1.Checked then memo2.Lines.SaveToFile(ChangeFileExt(Filename2, '.txt'));

  if powerdown_enabled1.Checked then {power down system}
  begin
    i := 60; {60 seconds}
    repeat
      beep;
      memo2.Lines.add(TimeToStr(time) + ' Will shutdown system in ' + IntToStr(i) +
        ' sec!! Hit ESC or uncheck shutdown action to avoid.');
      wait(1000);  {smart sleep}
      //      application.processmessages;
      if ((powerdown_enabled1.Checked = False) or (esc_pressed)) then
      begin
        memo2.Lines.add(TimeToStr(time) + ' Shutdown avoided.');
        exit;
      end;
      Dec(i);
    until i <= 0;
   {$ifdef mswindows}
    mainwindow.Caption := ShutMeDown;
   {$else} {unix}
     fpSystem('/sbin/shutdown -P now');
   {$endif}
  end;
end;


procedure Tstackmenu1.stack_method1Change(Sender: TObject);
var
  method: integer;
  sigm, mosa, cal_and_align, cal_only: boolean;
  mode: string;
begin
  method := stack_method1.ItemIndex;
  sigm := (method in [1, 7]);{sigma clip}
  mosa := (method = 2);{mosaic}
  cal_and_align := (method = 3);
  cal_only := (method in [4, 5]);

  //Average
  //Sigma clip average
  //Image stiching mode
  //Calibration and alignment only
  //Calibration only
  //Calibration only. No de-mosaic
  //Average, skip LRGB  combine
  //Sigma clip, skip LRGB combine

  mosaic_box1.Enabled := mosa;
  raw_box1.Enabled := ((mosa = False) and (classify_filter1.Checked = False));
  if mosa then  raw_box1.Caption :='RAW one shot colour images   (Disabled by stack method)'
  else
  if classify_filter1.Checked then
    raw_box1.Caption := 'RAW one shot colour images   (Disabled by ☑ Light filter)'
  else
    raw_box1.Caption := 'RAW one shot colour images';


  filter_groupbox1.Enabled := ((mosa = False) and (classify_filter1.Checked));
  if mosa then filter_groupbox1.Caption := 'LRGB stacking   (Disabled by stack method)'
  else
  if classify_filter1.Checked = False then
    filter_groupbox1.Caption := 'LRGB stacking   (Disabled by ☐ Light filter)'
  else
    filter_groupbox1.Caption := 'LRGB stacking';

  sd_factor1.Enabled := sigm;

  if ((use_astrometry_internal1.Checked = False) and (mosa)) then
  begin
    use_astrometry_internal1.Checked := True;
    memo2_message('Switched to INTERNAL ASTROMETRIC alignment. Set in tab aligment the mosaic width and height high enough to have enough work space.');
  end;
  if mosa then memo2_message('Astrometric image stitching mode. This will stitch astrometric tiles. Prior to this stack the images to tiles and check for clean edges. If not use the "Crop each image function". For flat background apply artificial flat in tab pixel math1 in advance if required.');

  classify_object1.Enabled := (mosa = False); {in mosaic mode ignore object name}
  oversize1.Enabled := (mosa = False); {in mosaic mode ignore this oversize setting}

  classify_filter1.Enabled := ((cal_and_align = False) and (cal_only = False) and (mosa = False));
  classify_object1.Enabled := ((cal_only = False) and (mosa = False));

  if classify_filter1.Checked then mode := 'LRGB ' else mode := '';
  stack_button1.Caption := 'STACK ' + mode + '(' + stack_method1.Text + ')';

  if ((method >= 6 {Skip average or sigma clip LRGB combine}) and
    (classify_filter1.Checked = False)) then
    memo2_message( '█ █ █ █ █ █ Warning, classify on Light Filter is not check marked !!! █ █ █ █ █ █ ');

  set_icon_stackbutton((classify_filter1.Checked) or (make_osc_color1.Checked));  //update glyph stack button to colour or gray
end;


procedure Tstackmenu1.use_astrometry_internal1Change(Sender: TObject);
begin
  update_tab_alignment;
end;


procedure Tstackmenu1.use_ephemeris_alignment1Change(Sender: TObject);
begin
  update_tab_alignment;
end;


procedure Tstackmenu1.use_manual_alignment1Change(Sender: TObject);
begin
  update_tab_alignment;
end;


procedure Tstackmenu1.use_star_alignment1Change(Sender: TObject);
begin
  update_tab_alignment;
end;


procedure Tstackmenu1.apply_vertical_gradient1Click(Sender: TObject);
var
  fitsX, fitsY, i, k, most_common, y1, y2, x1, x2, counter, step: integer;
  mean: double;
begin
  if head.naxis = 0 then exit;

  memo2_message('Remove gradient started.');
  Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

  backup_img;

  step := round(strtofloat2(gradient_filter_factor1.Text));

  mean := 0;
  counter := 0;

  {vertical}
  if Sender = apply_vertical_gradient1 then
    for k := 0 to head.naxis3 - 1 do {do all colors}
    begin
      for fitsY := 0 to (head.Height - 1) div step do
      begin
        y1 := (step + 1) * fitsY - (step div 2);
        y2 := (step + 1) * fitsY + (step div 2);
        most_common := mode(img_backup[index_backup].img,false{ellipse shape}, k, 0, head.Width - 1, y1, y2, 32000);
        mean := mean + most_common;
        Inc(counter);
        for i := y1 to y2 do
          for fitsX := 0 to head.Width - 1 do
          begin
            if ((i >= 0) and (i <= head.Height - 1)) then
              img_loaded[k, fitsX, i] := most_common;{store common vertical values}
          end;
      end;
    end;{K}

  {horizontal}
  if Sender = apply_horizontal_gradient1 then
    for k := 0 to head.naxis3 - 1 do {do all colors}
    begin
      for fitsX := 0 to (head.Width - 1) div step do
      begin
        x1 := (step + 1) * fitsX - (step div 2);
        x2 := (step + 1) * fitsX + (step div 2);
        most_common := mode(img_backup[index_backup].img,false{ellipse shape}, k, x1, x2, 0, head.Height - 1, 32000);
        mean := mean + most_common;
        Inc(counter);
        for i := x1 to x2 do
          for fitsY := 0 to head.Height - 1 do
          begin
            if ((i >= 0) and (i <= head.Width - 1)) then
              img_loaded[k, i, fitsY] := most_common;{store common vertical values}
          end;
      end;
    end;{K}

  mean := mean / counter;
  gaussian_blur2(img_loaded, step * 2);

  for k := 0 to head.naxis3 - 1 do {do all colors}
  begin
    for fitsY := 0 to head.Height - 1 do
      for fitsX := 0 to head.Width - 1 do
      begin
        img_loaded[k, fitsX, fitsY] := mean + img_backup[index_backup].img[k, fitsX, fitsY] - img_loaded[k, fitsX, fitsY];
      end;
  end;{k color}

  use_histogram(img_loaded, True {update}); {plot histogram, set sliders}
  plot_fits(mainwindow.image1, False, True);

  memo2_message('Remove gradient done.');

  Screen.Cursor := crDefault;
end;


procedure Tstackmenu1.Viewimage1Click(Sender: TObject);
begin
  if Sender = Viewimage1 then listview_view(listview1);//from popupmenus
  if Sender = Viewimage2 then listview_view(listview2);
  if Sender = Viewimage3 then listview_view(listview3);
  if Sender = Viewimage4 then listview_view(listview4);
  if Sender = Viewimage5 then listview_view(listview5);
  if Sender = Viewimage6 then listview_view(listview6);//popup menu blink
  if Sender = Viewimage7 then listview_view(listview7);//photometry
  if Sender = Viewimage8 then listview_view(listview8);//inspector
  if Sender = Viewimage9 then listview_view(listview9);//mount
end;


procedure Tstackmenu1.write_video1click(Sender: TObject);
var
  filen: string;
  crop, res: boolean;
  nrframes, c: integer;
begin
  crop := False;
  case QuestionDlg('Crop', 'Crop of full size video?', mtCustom, [20, 'Crop', 21, 'Cancel', 22, 'Full size', 'IsDefault'], '') of
    20: crop := True;
    21: exit;
  end;

  if InputQuery('Set video frame rate menu',
    'Video can be saved as uncompressed in Y4M or AVI container.' + #10 +
    'For monochrome images Y4M video files will be smaller.' + #10 +
    'To crop set the area first with the right mouse button.' + #10 +
    #10 + #10 + 'Enter video frame rate in [frames/second]:',
    frame_rate) = False then exit;

  mainwindow.savedialog1.initialdir := ExtractFilePath(filename2);
  mainwindow.savedialog1.Filter :=
    ' Currently selected Y4M|*.y4m|AVI uncompressed| *.avi';
  if video_index = 2 then
  begin
    mainwindow.savedialog1.filename := ChangeFileExt(FileName2, '.avi');
    mainwindow.savedialog1.filterindex := 2; {avi}
  end
  else
  begin
    mainwindow.savedialog1.filename := ChangeFileExt(FileName2, '.y4m');
    mainwindow.savedialog1.filterindex := 1;
  end;

  if mainwindow.savedialog1.Execute then
  begin
    filen := mainwindow.savedialog1.filename;
    if pos('.avi', filen) > 0 then video_index := 2 {avi}
    else
      video_index := 1; {y4m}

    stackmenu1.analyseblink1Click(nil); {analyse and secure the dimension values head_2.width, head_2.height from lights}
    if video_index = 2 then {AVI, count frames}
    begin
      nrframes := 0;
      for c := 0 to listview6.items.Count - 1 do {count frames}
      begin
        if listview6.Items.item[c].Checked then Inc(nrframes);
      end;
    end;

    if crop = False then
    begin
      areax1 := 0;{for crop activation areaX1<>areaX2}
      areax2 := 0;
      if video_index = 2 then
        res := write_avi_head(filen, frame_rate, nrframes, head_2.Width, head_2.Height) {open/create file. Result is false if failure}
      else
        res := write_YUV4MPEG2_header(filen, frame_rate,((head_2.naxis3 > 1) or (mainwindow.preview_demosaic1.Checked)), head_2.Width, head_2.Height);
    end
    else {crop is set by the mouse}
    begin
      if areaX1 = areaX2 then
      begin
        application.messagebox(PChar('Set first the area with the mouse and mouse popup menu "Set area" !'), PChar('Missing crop area'), MB_OK);
        exit;
      end;
      if video_index = 2 then
        res := write_avi_head(filen, frame_rate, nrframes, areax2 - areax1 + 1, areay2 - areay1 + 1) {open/create file. Result is false if failure}
      else
        res := write_YUV4MPEG2_header(filen, frame_rate, ((head.naxis3 > 1) or (mainwindow.preview_demosaic1.Checked)), areax2 - areax1 + 1, areay2 - areay1 + 1);
    end;

    if res = False then
    begin
      memo2_message('Video file creation error!');
      exit;
    end;

    stackmenu1.blink_button1Click(Sender);{blink and write video frames}
    if video_index = 2 then
      close_the_avi(nrframes)
    else
      close_YUV4MPEG2;
    memo2_message('Ready!. See tab results. The video written as ' +
      mainwindow.savedialog1.filename);

    filename2 := mainwindow.savedialog1.filename;
    report_results('Video file', '', 0, 15 {video icon});{report result in tab results}
  end;
end;

end.
