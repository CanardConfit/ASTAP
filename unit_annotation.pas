unit unit_annotation; {deep sky and star annotation & photometry calibation of the image}
{$mode delphi}
{Copyright (C) 2017, 2024 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface
uses
   forms,Classes, SysUtils,strutils, math,graphics, Controls {for tcursor},astap_main,  unit_stars_wide_field;

procedure plot_deepsky(extract_visible: boolean;font_size: integer);{plot the deep sky object on the image. If extract is true then extract visible to variable_list}
procedure plot_vsx_vsp(extract_visible: boolean);{plot downloaded variable and comp stars}
procedure load_deep;{load the deepsky database once. If loaded no action}
procedure load_hyperleda;{load the HyperLeda database once. If loaded no action}
procedure load_variable;{load variable stars. If loaded no action}
procedure load_variable_13;{load variable stars. If loaded no action}
procedure load_variable_15;{load variable stars. If loaded no action}
procedure plot_and_measure_stars(img : Timage_array; memo: tstrings; var head : Theader; flux_calibration,plot_stars, report_lim_magn: boolean);{flux calibration,  annotate, report limiting magnitude}
procedure measure_distortion(out stars_measured: integer);{measure or plot distortion}
function plot_artificial_stars(img: Timage_array;head:theader) : boolean;{plot stars as single pixel with a value as the mangitude. For super nova search}
procedure plot_stars_used_for_solving(starlist1,starlist2: Tstar_list; hd: Theader;correctionX,correctionY: double); {plot image stars and database stars used for the solution}
function read_deepsky(searchmode:char; telescope_ra,telescope_dec, cos_telescope_dec {cos(telescope_dec},fov : double; out ra2,dec2,length2,width2,pa : double): boolean;{deepsky database search}
procedure annotation_to_array(thestring : ansistring;transparant:boolean;colour,size, x,y {screen coord}: integer; var img: Timage_array);{string to image array as annotation, result is flicker free since the annotion is plotted as the rest of the image}
function find_object(var objname : string; var ra0,dec0,length0,width0,pa : double): boolean; {find object in database}
procedure rotate(rot: double; x,y :double; out x2, y2 : double);{rotate a vector point, angle seen from y-axis, counter clockwise}


var
  deepstring       : Tstrings;
  linepos          : integer;
  naam2,naam3,naam4: string;

var  {################# initialised variables #########################}
  limiting_magnitude     : double=0;{magnitude where snr is 5}
  counter_flux_measured  : integer=0;{how many stars used for flux calibration}
  database_nr            : integer=0; {1 is deepsky, 2 is hyperleda, 3 is variable magn 11 loaded, 4 is variable magn 13 loaded, 5 is variable magn 15 loaded, 6=simbad}

type
  tvariable_list = record {for photometry tab}
    ra  : double;
    dec  : double;
    abbr : string;
    Source : integer; //0 local, 1=VSX, 2=VSP, 3=not in AAVSO
    index  : integer; //source index
  end;

var
  variable_list: array of tvariable_list;{for photometry tab}
  variable_list_length : integer=0;



implementation

uses
  unit_star_database, unit_stack, unit_star_align, unit_online_gaia, unit_astrometric_solving;

const font_5x9 : packed array[33..126,0..8,0..4] of byte=  {ASTAP native font for part of code page 437}
((
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,0,0,0),
(0,0,1,0,0)),{!}
(
(0,1,0,1,0),
(0,1,0,1,0),
(0,1,0,1,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0)),{"}
(
(0,1,0,1,0),
(0,1,0,1,0),
(0,1,0,1,0),
(1,1,1,1,1),
(0,1,0,1,0),
(1,1,1,1,1),
(0,1,0,1,0),
(0,1,0,1,0),
(0,1,0,1,0)),{#}
(
(0,0,1,0,0),
(0,0,1,0,0),
(0,1,1,1,1),
(1,0,1,0,0),
(0,1,1,1,0),
(0,0,1,0,1),
(1,1,1,1,0),
(0,0,1,0,0),
(0,0,1,0,0)),{dollar sign}
(
(1,1,1,0,0),
(1,0,1,0,0),
(1,1,1,0,1),
(0,0,0,1,0),
(0,0,1,0,0),
(0,1,0,0,0),
(1,0,1,1,1),
(0,0,1,0,1),
(0,0,1,1,1)),{%}
(
(0,0,0,0,0),
(0,1,1,0,0),
(1,0,0,1,0),
(1,0,0,1,0),
(0,1,1,0,0),
(1,0,1,0,0),
(1,0,0,1,0),
(1,0,0,1,1),
(0,1,1,0,0)),{&}
(
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0)),{'}
(
(0,0,0,1,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,1,0,0,0),
(0,1,0,0,0),
(0,1,0,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,0,1,0)),{(}
(
(0,1,0,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,0,1,0),
(0,0,0,1,0),
(0,0,0,1,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,1,0,0,0)),{)}
(
(0,0,0,0,0),
(0,0,1,0,0),
(1,0,1,0,1),
(1,1,1,1,1),
(0,1,1,1,0),
(1,1,1,1,1),
(1,0,1,0,1),
(0,0,1,0,0),
(0,0,0,0,0)),{*}
(
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(1,1,1,1,1),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,0,0,0),
(0,0,0,0,0)),{+}
(
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,1,0,0,0)),{,}
(
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(1,1,1,1,1),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0)),{-}
(
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,1,1,0,0),
(0,1,1,0,0)),{.}
(
(0,0,0,0,0),
(0,0,0,1,0),
(0,0,0,1,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,1,0,0,0),
(0,1,0,0,0),
(1,0,0,0,0),
(1,0,0,0,0)),{/}
(
(0,1,1,1,0),{0}
(1,0,0,0,1),
(1,0,0,0,1),
(1,0,0,0,1),
(1,0,0,0,1),
(1,0,0,0,1),
(1,0,0,0,1),
(1,0,0,0,1),
(0,1,1,1,0)),
(
(0,0,1,0,0),{1}
(0,1,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,1,1,1,0)),
(
(0,1,1,1,0),{2}
(1,0,0,0,1),
(0,0,0,0,1),
(0,0,0,0,1),
(0,0,0,1,0),
(0,0,1,0,0),
(0,1,0,0,0),
(1,0,0,0,0),
(1,1,1,1,1)),
(
(1,1,1,1,0),{3}
(0,0,0,0,1),
(0,0,0,0,1),
(0,0,0,0,1),
(0,1,1,1,1),
(0,0,0,0,1),
(0,0,0,0,1),
(0,0,0,0,1),
(1,1,1,1,0)),
(
(1,0,0,0,1),{4}
(1,0,0,0,1),
(1,0,0,0,1),
(1,0,0,0,1),
(1,1,1,1,1),
(0,0,0,0,1),
(0,0,0,0,1),
(0,0,0,0,1),
(0,0,0,0,1)),
(
(1,1,1,1,1),{5}
(1,0,0,0,0),
(1,0,0,0,0),
(1,0,0,0,0),
(1,1,1,1,0),
(0,0,0,0,1),
(0,0,0,0,1),
(1,0,0,0,1),
(0,1,1,1,0)),
(
(0,1,1,1,0),{6}
(1,0,0,0,0),
(1,0,0,0,0),
(1,0,0,0,0),
(0,1,1,1,0),
(1,0,0,0,1),
(1,0,0,0,1),
(1,0,0,0,1),
(0,1,1,1,0)),
(
(1,1,1,1,1),{7}
(0,0,0,0,1),
(0,0,0,0,1),
(0,0,0,1,0),
(0,0,0,1,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0)),
(
(0,1,1,1,0),{8}
(1,0,0,0,1),
(1,0,0,0,1),
(1,0,0,0,1),
(0,1,1,1,0),
(1,0,0,0,1),
(1,0,0,0,1),
(1,0,0,0,1),
(0,1,1,1,0)),
(
(0,1,1,1,0),{9}
(1,0,0,0,1),
(1,0,0,0,1),
(1,0,0,0,1),
(0,1,1,1,1),
(0,0,0,0,1),
(0,0,0,0,1),
(0,0,0,1,0),
(0,1,1,0,0)),
(
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,1,1,0),
(0,0,1,1,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,1,1,0),
(0,0,1,1,0)),{:}
(
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,1,1,0),
(0,0,1,1,0),
(0,0,0,0,0),
(0,0,1,1,0),
(0,0,1,1,0),
(0,0,0,1,0),
(0,1,1,1,0)),{;}
(
(0,0,0,0,1),
(0,0,0,1,0),
(0,0,1,0,0),
(0,1,0,0,0),
(1,0,0,0,0),
(0,1,0,0,0),
(0,0,1,0,0),
(0,0,0,1,0),
(0,0,0,0,1)),{<}
(
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(1,1,1,1,1),
(0,0,0,0,0),
(0,0,0,0,0),
(1,1,1,1,1),
(0,0,0,0,0),
(0,0,0,0,0)),{=}
(
(1,0,0,0,0),
(0,1,0,0,0),
(0,0,1,0,0),
(0,0,0,1,0),
(0,0,0,0,1),
(0,0,0,1,0),
(0,0,1,0,0),
(0,1,0,0,0),
(1,0,0,0,0)),{>}

(
(1,1,1,1,0),
(1,0,0,0,1),
(0,0,0,0,1),
(0,0,0,1,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,0,0,0),
(0,0,1,0,0),
(0,0,1,0,0)),{?}
(
(0,1,1,1,0),
(1,0,0,0,1),
(1,0,0,0,1),
(1,0,1,1,1),
(1,0,1,0,1),
(1,0,1,1,1),
(1,0,0,0,0),
(1,0,0,0,1),
(0,1,1,1,0)),{@}
(
(0,0,1,0,0),{A}
(0,1,0,1,0),{A}
(0,1,0,1,0),{A}
(1,0,0,0,1),{A}
(1,0,0,0,1),{A}
(1,1,1,1,1),{A}
(1,0,0,0,1),{A}
(1,0,0,0,1),{A}
(1,0,0,0,1)),{A}
(
(1,1,1,1,0),{B}
(0,1,0,0,1),{B}
(0,1,0,0,1),{B}
(0,1,0,0,1),{B}
(0,1,1,1,0),{B}
(0,1,0,0,1),{B}
(0,1,0,0,1),{B}
(0,1,0,0,1),{B}
(1,1,1,1,0)),{B}
(
(0,1,1,1,0),{C}
(1,0,0,0,1),{C}
(1,0,0,0,0),{C}
(1,0,0,0,0),{C}
(1,0,0,0,0),{C}
(1,0,0,0,0),{C}
(1,0,0,0,0),{C}
(1,0,0,0,1),{C}
(0,1,1,1,0)),{C}
(
(1,1,1,1,0),{D}
(0,1,0,0,1),{D}
(0,1,0,0,1),{D}
(0,1,0,0,1),{D}
(0,1,0,0,1),{D}
(0,1,0,0,1),{D}
(0,1,0,0,1),{D}
(0,1,0,0,1),{D}
(1,1,1,1,0)),{D}
(
(1,1,1,1,1),{E}
(1,0,0,0,0),{E}
(1,0,0,0,0),{E}
(1,0,0,0,0),{E}
(1,1,1,1,0),{E}
(1,0,0,0,0),{E}
(1,0,0,0,0),{E}
(1,0,0,0,0),{E}
(1,1,1,1,1)),{E}
(
(1,1,1,1,1),{F}
(1,0,0,0,0),{F}
(1,0,0,0,0),{F}
(1,0,0,0,0),{F}
(1,1,1,1,0),{F}
(1,0,0,0,0),{F}
(1,0,0,0,0),{F}
(1,0,0,0,0),{F}
(1,0,0,0,0)),{F}
(
(0,1,1,1,0),{G}
(1,0,0,0,1),{G}
(1,0,0,0,0),{G}
(1,0,0,0,0),{G}
(1,0,0,1,1),{G}
(1,0,0,0,1),{G}
(1,0,0,0,1),{G}
(1,0,0,1,1),{G}
(0,1,1,0,1)),{G}
(
(1,0,0,0,1),{H}
(1,0,0,0,1),{H}
(1,0,0,0,1),{H}
(1,0,0,0,1),{H}
(1,1,1,1,1),{H}
(1,0,0,0,1),{H}
(1,0,0,0,1),{H}
(1,0,0,0,1),{H}
(1,0,0,0,1)),{H}
(
(1,1,1,1,1),{I}
(0,0,1,0,0),{I}
(0,0,1,0,0),{I}
(0,0,1,0,0),{I}
(0,0,1,0,0),{I}
(0,0,1,0,0),{I}
(0,0,1,0,0),{I}
(0,0,1,0,0),{I}
(1,1,1,1,1)),{I}
(
(0,0,0,1,1),{J}
(0,0,0,0,1),{J}
(0,0,0,0,1),{J}
(0,0,0,0,1),{J}
(0,0,0,0,1),{J}
(0,0,0,0,1),{J}
(0,0,0,0,1),{J}
(1,0,0,0,1),{J}
(0,1,1,1,0)),{J}
(
(1,0,0,0,1),{K}
(1,0,0,0,1),{K}
(1,0,0,1,0),{K}
(1,0,1,0,0),{K}
(1,1,0,0,0),{K}
(1,0,1,0,0),{K}
(1,0,0,1,0),{K}
(1,0,0,0,1),{K}
(1,0,0,0,1)),{K}
(
(1,0,0,0,0),{L}
(1,0,0,0,0),{L}
(1,0,0,0,0),{L}
(1,0,0,0,0),{L}
(1,0,0,0,0),{L}
(1,0,0,0,0),{L}
(1,0,0,0,0),{L}
(1,0,0,0,0),{L}
(1,1,1,1,1)),{L}
(
(1,0,0,0,1),{M}
(1,1,0,1,1),{M}
(1,1,0,1,1),{M}
(1,0,1,0,1),{M}
(1,0,1,0,1),{M}
(1,0,0,0,1),{M}
(1,0,0,0,1),{M}
(1,0,0,0,1),{M}
(1,0,0,0,1)),{M}
(
(1,0,0,0,1),{N}
(1,1,0,0,1),{N}
(1,1,0,0,1),{N}
(1,0,1,0,1),{N}
(1,0,1,0,1),{N}
(1,0,0,1,1),{N}
(1,0,0,1,1),{N}
(1,0,0,0,1),{N}
(1,0,0,0,1)),{N}
(
(0,1,1,1,0),{O}
(1,0,0,0,1),{O}
(1,0,0,0,1),{O}
(1,0,0,0,1),{O}
(1,0,0,0,1),{O}
(1,0,0,0,1),{O}
(1,0,0,0,1),{O}
(1,0,0,0,1),{O}
(0,1,1,1,0)),{O}
(
(1,1,1,1,0),{P}
(1,0,0,0,1),{P}
(1,0,0,0,1),{P}
(1,0,0,0,1),{P}
(1,1,1,1,0),{P}
(1,0,0,0,0),{P}
(1,0,0,0,0),{P}
(1,0,0,0,0),{P}
(1,0,0,0,0)),{P}
(
(0,1,1,1,0),{Q}
(1,0,0,0,1),{Q}
(1,0,0,0,1),{Q}
(1,0,0,0,1),{Q}
(1,0,0,0,1),{Q}
(1,0,1,0,1),{Q}
(0,1,1,1,0),{Q}
(0,0,0,1,0),{Q}
(0,0,0,0,1)),{Q}
(
(1,1,1,1,0),{R}
(1,0,0,0,1),{R}
(1,0,0,0,1),{R}
(1,0,0,0,1),{R}
(1,1,1,1,0),{R}
(1,1,0,0,0),{R}
(1,0,1,0,0),{R}
(1,0,0,1,0),{R}
(1,0,0,0,1)),{R}
(
(0,1,1,1,0),{S}
(1,0,0,0,1),{S}
(1,0,0,0,0),{S}
(0,1,0,0,0),{S}
(0,0,1,0,0),{S}
(0,0,0,1,0),{S}
(0,0,0,0,1),{S}
(1,0,0,0,1),{S}
(0,1,1,1,0)),{S}
(
(1,1,1,1,1),{T}
(1,0,1,0,1),{T}
(0,0,1,0,0),{T}
(0,0,1,0,0),{T}
(0,0,1,0,0),{T}
(0,0,1,0,0),{T}
(0,0,1,0,0),{T}
(0,0,1,0,0),{T}
(0,1,1,1,0)),{T}
(
(1,0,0,0,1),{U}
(1,0,0,0,1),{U}
(1,0,0,0,1),{U}
(1,0,0,0,1),{U}
(1,0,0,0,1),{U}
(1,0,0,0,1),{U}
(1,0,0,0,1),{U}
(1,0,0,0,1),{U}
(0,1,1,1,0)),{U}
(
(1,0,0,0,1),{V}
(1,0,0,0,1),{V}
(1,0,0,0,1),{V}
(1,0,0,0,1),{V}
(1,0,0,0,1),{V}
(1,0,0,0,1),{V}
(0,1,0,1,0),{V}
(0,1,0,1,0),{V}
(0,0,1,0,0)),{V}
(
(1,0,0,0,1),{W}
(1,0,0,0,1),{W}
(1,0,0,0,1),{W}
(1,0,0,0,1),{W}
(1,0,1,0,1),{W}
(1,0,1,0,1),{W}
(1,1,0,1,1),{W}
(1,1,0,1,1),{W}
(1,0,0,0,1)),{W}
(
(1,0,0,0,1),{X}
(1,0,0,0,1),{X}
(0,1,0,1,0),{X}
(0,1,0,1,0),{X}
(0,0,1,0,0),{X}
(0,1,0,1,0),{X}
(0,1,0,1,0),{X}
(1,0,0,0,1),{X}
(1,0,0,0,1)),{X}
(
(1,0,0,0,1),{Y}
(1,0,0,0,1),{Y}
(1,0,0,0,1),{Y}
(0,1,0,1,0),{Y}
(0,0,1,0,0),{Y}
(0,0,1,0,0),{Y}
(0,0,1,0,0),{Y}
(0,0,1,0,0),{Y}
(0,0,1,0,0)),{Y}
(
(1,1,1,1,1),{Z}
(0,0,0,0,1),{Z}
(0,0,0,0,1),{Z}
(0,0,0,1,0),{Z}
(0,0,1,0,0),{Z}
(0,1,0,0,0),{Z}
(1,0,0,0,0),{Z}
(1,0,0,0,0),{Z}
(1,1,1,1,1)),{Z}
(
(0,1,1,1,1),
(0,1,0,0,0),
(0,1,0,0,0),
(0,1,0,0,0),
(0,1,0,0,0),
(0,1,0,0,0),
(0,1,0,0,0),
(0,1,0,0,0),
(0,1,1,1,1)),{[}
(
(0,0,0,0,0),
(1,0,0,0,0),
(1,0,0,0,0),
(0,1,0,0,0),
(0,1,0,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,0,1,0),
(0,0,0,1,0)),{\}
(
(1,1,1,1,0),
(0,0,0,1,0),
(0,0,0,1,0),
(0,0,0,1,0),
(0,0,0,1,0),
(0,0,0,1,0),
(0,0,0,1,0),
(0,0,0,1,0),
(1,1,1,1,0)),{]}
(
(0,0,1,0,0),
(0,1,0,1,0),
(1,0,0,0,1),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0)),{^}
(
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(1,1,1,1,1)),{_}
(
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,0,1,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0)),{`}
(
(0,0,0,0,0),{a}
(0,0,0,0,0),{a}
(0,0,0,0,0),{a}
(0,1,1,1,0),{a}
(0,0,0,0,1),{a}
(0,1,1,1,1),{a}
(1,0,0,0,1),{a}
(1,0,0,1,1),{a}
(0,1,1,0,1)),{a}
(
(0,0,0,0,0),{b}
(1,0,0,0,0),{b}
(1,0,0,0,0),{b}
(1,0,0,0,0),{b}
(1,0,1,1,0),{b}
(1,1,0,0,1),{b}
(1,0,0,0,1),{b}
(1,0,0,0,1),{b}
(1,1,1,1,0)),{b}
(
(0,0,0,0,0),{c}
(0,0,0,0,0),{c}
(0,0,0,0,0),{c}
(0,1,1,1,0),{c}
(1,0,0,0,0),{c}
(1,0,0,0,0),{c}
(1,0,0,0,0),{c}
(1,0,0,0,1),{c}
(0,1,1,1,0)),{c}
(
(0,0,0,0,0),{d}
(0,0,0,0,1),{d}
(0,0,0,0,1),{d}
(0,0,0,0,1),{d}
(1,1,1,1,1),{d}
(1,0,0,0,1),{d}
(1,0,0,0,1),{d}
(1,0,0,1,1),{d}
(0,1,1,0,1)),{d}
(
(0,0,0,0,0),{e}
(0,0,0,0,0),{e}
(0,0,0,0,0),{e}
(0,1,1,1,0),{e}
(1,0,0,0,1),{e}
(1,0,0,0,1),{e}
(1,1,1,1,0),{e}
(1,0,0,0,0),{e}
(0,1,1,1,1)),{e}
(
(0,0,1,1,0),{f}
(0,1,0,0,1),{f}
(0,1,0,0,0),{f}
(0,1,0,0,0),{f}
(1,1,1,1,0),{f}
(0,1,0,0,0),{f}
(0,1,0,0,0),{f}
(0,1,0,0,0),{f}
(0,1,0,0,0)),{f}
(
(0,0,0,0,0),{g}
(0,0,0,0,0),{g}
(0,0,0,0,0),{g}
(0,1,1,1,1),{g}
(1,0,0,0,1),{g}
(1,0,0,1,1),{g}
(0,1,1,0,1),{g}
(0,0,0,0,1),{g}
(1,1,1,1,0)),{g}
(
(0,0,0,0,0),{h}
(1,0,0,0,0),{h}
(1,0,0,0,0),{h}
(1,0,0,0,0),{h}
(1,0,1,1,0),{h}
(1,1,0,0,1),{h}
(1,0,0,0,1),{h}
(1,0,0,0,1),{h}
(1,0,0,0,1)),{h}
(
(0,0,0,0,0),{i}
(0,1,1,0,0),{i}
(0,0,0,0,0),{i}
(0,1,1,0,0),{i}
(0,0,1,0,0),{i}
(0,0,1,0,0),{i}
(0,0,1,0,0),{i}
(0,0,1,0,0),{i}
(1,1,1,1,1)),{i}
(
(0,0,0,0,0),{j}
(0,0,0,1,1),{j}
(0,0,0,0,0),{j}
(0,0,0,1,1),{j}
(0,0,0,0,1),{j}
(0,0,0,0,1),{j}
(0,0,0,0,1),{j}
(1,0,0,0,1),{j}
(0,1,1,1,0)),{j}
(
(0,0,0,0,0),{k}
(1,0,0,0,0),{k}
(1,0,0,0,0),{k}
(1,0,0,0,1),{k}
(1,0,0,1,0),{k}
(1,1,1,0,0),{k}
(1,0,1,0,0),{k}
(1,0,0,1,0),{k}
(1,0,0,0,1)),{k}
(
(0,0,0,0,0),{l}
(0,0,1,0,0),{l}
(0,0,1,0,0),{l}
(0,0,1,0,0),{l}
(0,0,1,0,0),{l}
(0,0,1,0,0),{l}
(0,0,1,0,0),{l}
(0,0,1,0,0),{l}
(0,0,1,1,1)),{l}
(
(0,0,0,0,0),{m}
(0,0,0,0,0),{m}
(0,0,0,0,0),{m}
(1,1,0,1,0),{m}
(1,0,1,0,1),{m}
(1,0,1,0,1),{m}
(1,0,1,0,1),{m}
(1,0,0,0,1),{m}
(1,0,0,0,1)),{m}
(
(0,0,0,0,0),{n}
(0,0,0,0,0),{n}
(0,0,0,0,0),{n}
(1,0,1,1,0),{n}
(1,1,0,0,1),{n}
(1,0,0,0,1),{n}
(1,0,0,0,1),{n}
(1,0,0,0,1),{n}
(1,0,0,0,1)),{n}
(
(0,0,0,0,0),{o}
(0,0,0,0,0),{o}
(0,0,0,0,0),{o}
(0,1,1,1,0),{o}
(1,0,0,0,1),{o}
(1,0,0,0,1),{o}
(1,0,0,0,1),{o}
(1,0,0,0,1),{o}
(0,1,1,1,0)),{o}
(
(0,0,0,0,0),{p}
(0,0,0,0,0),{p}
(0,0,0,0,0),{p}
(1,0,1,1,0),{p}
(1,1,0,0,1),{p}
(1,0,0,0,1),{p}
(1,1,1,1,0),{p}
(1,0,0,0,0),{p}
(1,0,0,0,0)),{p}
(
(0,0,0,0,0),{q}
(0,0,0,0,0),{q}
(0,0,0,0,0),{q}
(0,1,1,1,1),{q}
(1,0,0,0,1),{q}
(1,0,0,1,1),{q}
(0,1,1,0,1),{q}
(0,0,0,0,1),{q}
(0,0,0,0,1)),{q}
(
(0,0,0,0,0),{r}
(0,0,0,0,0),{r}
(0,0,0,0,0),{r}
(1,1,0,1,1),{r}
(0,1,1,0,1),{r}
(0,1,0,0,1),{r}
(0,1,0,0,0),{r}
(0,1,0,0,0),{r}
(1,1,1,0,0)),{r}
(
(0,0,0,0,0),{s}
(0,0,0,0,0),{s}
(0,0,0,0,0),{s}
(0,1,1,1,1),{s}
(1,0,0,0,0),{s}
(0,1,1,1,0),{s}
(0,0,0,0,1),{s}
(0,0,0,0,1),{s}
(1,1,1,1,0)),{s}
(
(0,0,0,0,0),{t}
(0,1,0,0,0),{t}
(0,1,0,0,0),{t}
(1,1,1,1,0),{t}
(0,1,0,0,0),{t}
(0,1,0,0,0),{t}
(0,1,0,0,0),{t}
(0,1,0,0,1),{t}
(0,0,1,1,0)),{t}
(
(0,0,0,0,0),{u}
(0,0,0,0,0),{u}
(0,0,0,0,0),{u}
(1,0,0,0,1),{u}
(1,0,0,0,1),{u}
(1,0,0,0,1),{u}
(1,0,0,0,1),{u}
(1,0,0,1,1),{u}
(0,1,1,0,1)),{u}
(
(0,0,0,0,0),{v}
(0,0,0,0,0),{v}
(0,0,0,0,0),{v}
(1,0,0,0,1),{v}
(1,0,0,0,1),{v}
(1,0,0,0,1),{v}
(0,1,0,1,0),{v}
(0,1,0,1,0),{v}
(0,0,1,0,0)),{v}
(
(0,0,0,0,0),{w}
(0,0,0,0,0),{w}
(0,0,0,0,0),{w}
(1,0,0,0,1),{w}
(1,0,0,0,1),{w}
(1,0,1,0,1),{w}
(1,0,1,0,1),{w}
(1,1,0,1,1),{w}
(1,0,0,0,1)),{w}

(
(0,0,0,0,0),{x}
(0,0,0,0,0),{x}
(0,0,0,0,0),{x}
(1,0,0,0,1),{x}
(0,1,0,1,0),{x}
(0,0,1,0,0),{x}
(0,1,0,1,0),{x}
(1,0,0,0,1),{x}
(1,0,0,0,1)),{x}
(
(0,0,0,0,0),{y}
(0,0,0,0,0),{y}
(0,0,0,0,0),{y}
(1,0,0,0,1),{y}
(1,0,0,0,1),{y}
(1,0,0,1,1),{y}
(0,1,1,0,1),{y}
(0,0,0,0,1),{y}
(1,1,1,1,0)),{y}
(
(0,0,0,0,0),{z}
(0,0,0,0,0),{z}
(0,0,0,0,0),{z}
(1,1,1,1,1),{z}
(0,0,0,1,0),{z}
(0,0,1,0,0),{z}
(0,1,0,0,0),{z}
(1,0,0,0,0),{z}
(1,1,1,1,1)),{z}
(
(0,0,1,1,0),
(0,1,0,0,0),
(0,1,0,0,0),
(0,0,1,0,0),
(1,1,1,0,0),
(0,0,1,0,0),
(0,1,0,0,0),
(0,1,0,0,0),
(0,0,1,1,0)),//{  Open curly bracket or open brace
(
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0),
(0,0,1,0,0)),{|}
(
(0,1,1,0,0),
(0,0,0,1,0),
(0,0,0,1,0),
(0,0,1,0,0),
(0,0,1,1,1),
(0,0,1,0,0),
(0,0,0,1,0),
(0,0,0,1,0),
(0,1,1,0,0)),//}  Close curly bracket or close brace
(
(0,0,0,0,0),
(0,0,0,0,0),
(0,1,0,0,1),
(1,0,1,0,1),
(1,0,1,0,1),
(1,0,0,1,0),
(0,0,0,0,0),
(0,0,0,0,0),
(0,0,0,0,0)){~}
);

procedure annotation_to_array(thestring : ansistring;transparant:boolean;colour,size, x,y {screen coord}: integer; var img: Timage_array);{string to image array as annotation, result is flicker free since the annotion is plotted as the rest of the image}
var                                                                                       {Screen coordinates are used to have the font with the correct orientation}
 w,h,i,j,k,value,flipV, flipH,len,x2,y2: integer;
 ch : pansichar;
begin
  w:=Length(img[0,0]); {width}
  h:=Length(img[0]); {height}

  if mainform1.Flip_horizontal1.Checked then {restore based on flipped conditions}
  begin
    x:=(w-1)-x;
    flipH:=-1;
  end
  else flipH:=1;

  if mainform1.flip_vertical1.Checked then
  begin
    y:=(h-1)-y;
    flipV:=-1;
  end
  else flipV:=1;


  len:=length(thestring);
  for k:=1 to len do
  begin
    ch:=Pansichar(copy(thestring,k,1));
    value:=ord(ch[0]);
    if ((value>=33) and (value<=126)) then
    for j:=(9*size)-1 downto 0 do
      for i:=0 to (5*size)-1 do
      begin
        x2:=x+(i+(k-1)*7*size)*flipH;
        y2:=y-(j*flipV);
        if ((x2>=0) and (x2<w) and (y2>=0) and (y2<h)) then {within image}
        if (((transparant=false)) or (font_5x9[value,j div size ,i div size]<>0)) then img[0,y2,x2]:=font_5x9[value,j div size,i div size]*colour;{write the font to the array}
      end;
  end;
end;


procedure load_deep;{load the deepsky database once. If loaded no action}
begin
  if database_nr<>1 then {load deepsky database}
  begin
    with deepstring do
    begin
       try
       LoadFromFile(database_path+'deep_sky.csv');{load deep sky data from file }
       database_nr:=1;{1 is deepsky, 2 is hyperleda, 3 is variable magn 11 loaded, 4 is variable magn 13 loaded, 5 is variable magn 15 loaded, 6=simbad}
       except;
         clear;
         beep;
         application.messagebox(pchar('The deep sky database was not found. Download and unpack in program directory'),'',0);
       end;
    end;
  end;
end;

procedure load_variable;{load the variable star database once. If loaded no action}
begin
  if database_nr<>3 then {load variable database}
  begin
    with deepstring do
    begin
       try
       LoadFromFile(database_path+'variable_stars.csv');{load deep sky data from file }
       database_nr:=3;{1 is deepsky, 2 is hyperleda, 3 is variable magn 11 loaded, 4 is variable magn 13 loaded, 5 is variable magn 15 loaded, 6=simbad}
       except;
         clear;
         beep;
         application.messagebox(pchar('The variable star database not found!'),'',0);
         esc_pressed:=true;

       end;
    end;
  end;
end;

procedure load_variable_13;{load the variable star database once. If loaded no action}
begin
  if database_nr<>4 then {load variable database}
  begin
    with deepstring do
    begin
       try
       LoadFromFile(database_path+'variable_stars_13.csv');{load deep sky data from file }
       database_nr:=4;{1 is deepsky, 2 is hyperleda, 3 is variable magn 11 loaded, 4 is variable magn 13 loaded, 5 is variable magn 15 loaded, 6=simbad}
       except;
         clear;
         beep;
         application.messagebox(pchar('The additional variable star database was not found!  Download from the ASTAP webpage and install.'),'',0);
         esc_pressed:=true;
         exit;
       end;
    end;
    if copy(deepstring.strings[0],1,4)<>'V003' then
      application.messagebox(pchar('Please download and install a new version of the "Variable_stars" database!'),'',0{MB_OK});
  end;
end;


procedure load_variable_15;{load the variable star database once. If loaded no action}
begin
  if database_nr<>5 then {load variable database}
  begin
    with deepstring do
    begin
       try
       LoadFromFile(database_path+'variable_stars_15.csv');{load deep sky data from file }
       database_nr:=5;{1 is deepsky, 2 is hyperleda, 3 is variable magn 11 loaded, 4 is variable magn 13 loaded, 5 is variable magn 15 loaded, 6=simbad}
       except;
         clear;
         beep;
         application.messagebox(pchar('The additional variable star database was not found!  Download from the ASTAP webpage and install.'),'',0);
         esc_pressed:=true;
         exit;
       end;
    end;
    if copy(deepstring.strings[0],1,4)<>'V003' then
      application.messagebox(pchar('Please download and install a new version of the "Variable_stars" database!'),'',0{MB_OK});
  end;

end;


procedure load_hyperleda;{load the HyperLeda database once. If loaded no action}
begin
  if database_nr<>2 then {load HyperLeda}
  begin
    with deepstring do
    begin
       try
       LoadFromFile(database_path+'hyperleda.csv');{load deep sky data from file }
       database_nr:=2;{1 is deepsky, 2 is hyperleda, 3 is variable magn 11 loaded, 4 is variable magn 13 loaded, 5 is variable magn 15 loaded, 6=simbad}
       except;
         clear;
         beep;
         application.messagebox(pchar('HyperLeda database not found! Download from the ASTAP webpage and install.'),'',0);
       end;
    end;
  end;
end;

//http://fastcode.sourceforge.net/
//function ValLong_JOH_PAS_4_c(Value: Integer): string;
function Valint32(const s; var code: Integer): Longint;{fast val function, about 4 x faster}
var
  Digit: Integer;
  Neg, Hex, Valid: Boolean;
  P: PChar;
begin
  Code := 0;
  P := Pointer(S);
  if not Assigned(P) then
    begin
      Result := 0;
      inc(Code);
      Exit;
    end;
  Neg   := False;
  Hex   := False;
  Valid := False;
  while P^ = ' ' do
    Inc(P);
  if P^ in ['+', '-'] then
    begin
      Neg := (P^ = '-');
      inc(P);
    end;
  if P^ = '$' then
    begin
      inc(P);
      Hex := True;
    end
  else
    begin
      if P^ = '0' then
        begin
          inc(P);
          Valid := True;
        end;
      if Upcase(P^) = 'X' then
        begin
          Hex := True;
          inc(P);
        end;
    end;
  Result := 0;
  if Hex then
    begin
      Valid := False;
      while True do
        begin
          case P^ of
            '0'..'9': Digit := Ord(P^) - Ord('0');
            'a'..'f': Digit := Ord(P^) - Ord('a') + 10;
            'A'..'F': Digit := Ord(P^) - Ord('A') + 10;
            else      Break;
          end;
          if (Result < 0) or (Result > $0FFFFFFF) then
            Break;
          Result := (Result shl 4) + Digit;
          Valid := True;
          inc(P);
        end;
    end
  else
    begin
      while True do
        begin
          if not (P^ in ['0'..'9']) then
            break;
          if Result > (MaxInt div 10) then
            break;
          Result := (Result * 10) + Ord(P^) - Ord('0');
          Valid := True;
          inc(P);
        end;
      if Result < 0 then {Possible Overflow}
        if (Cardinal(Result) <> $80000000) or (not neg) then
          begin {Min(LongInt) = $80000000 is a Valid Result}
            Dec(P);
            Valid := False;
          end;
    end;
  if Neg then
    Result := -Result;
  if (not Valid) or (P^ <> #0) then
    Code := P-@S+1;
end;

function read_deepsky(searchmode:char; telescope_ra,telescope_dec, cos_telescope_dec {cos(telescope_dec},fov : double; out ra2,dec2,length2,width2,pa : double): boolean;{deepsky database search}
var
  x,z,y      : integer;
  fout,fout2, backsl1, backsl2,length_regel : integer;
  regel, data1     :  string;
  delta_ra : double;
  p2,p1: pchar;
begin
  repeat {until fout is 0}
    if linepos>=deepstring.count then
    begin
      result:=false;
      exit;
    end;
    regel:=deepstring.strings[linepos]; {using regel,is faster then deepstring.strings[linepos]}
    inc(linepos);
    x:=1; z:=0; y:=0;

    P1 := Pointer(regel);
    length_regel:=length(regel);

    repeat
      {fast replacement for y:=posEx(',',regel,y+1); if y=0 then} {last field?}  {y:=length(regel)+1;}
      while ((y<length_regel) and (p1^<>',')) do
             begin inc(y); inc(p1,1) end;
      inc(y); inc(p1,1);

      {fast replacement for data1:=copy(regel,x,y-x);}
      SetLength(data1, y-x);
      if y<>x then {not empthy 2018}
      begin
        P2 := Pointer(regel);
        inc(P2, X-1);
        move(P2^,data1[1], y-x);

        while ((length(data1)>1) and (data1[length(data1)]=' ')) do {remove spaces in the end since VAL( can't cope with them}
                                      delete(data1,length(data1),1);
      end;{not empthy}
      x:=y;
      inc(z); {new data field}

      case z of 1:
                     ra2:=valint32(data1,fout)*pi*2/864000;{10*60*60*24, so RA 00:00 00.1=1}
                          {valint32 takes 1 ms instead of 4ms}

                2: begin
                     dec2:=valint32(data1,fout)*pi*0.5/324000;{60*60*90, so DEC 00:00 01=1}
                     delta_ra:=abs(ra2-telescope_ra); if delta_ra>pi then delta_ra:=pi*2-delta_ra;

                     if ((searchmode<>'T') and                                                        {if searchmode is 'T' then full database search else within FOV}
                         ( sqr( delta_ra*cos_telescope_dec)  + sqr(dec2-telescope_dec)> sqr(fov)  ) ) {calculate angular distance and skip when outside FOV}
                           then  fout:=99; {if true then outside screen,go to next line}

                   end;
                3: begin
                     naam2:='';{for case data1='';}
                     naam3:='';
                     naam4:='';
                     if length(data1)>0 then
                     begin
                       while (data1[1]=' ') do delete(data1,1,1); {remove spaces in front of the name, in practice faster then trimleft}
                       backsl1:=pos('/',data1);
                       if backsl1=0 then naam2:=data1
                       else
                       begin
                         naam2:=copy(data1,1,backsl1-1);
                         backsl2:=posEX('/',data1,backsl1+2);     { could also use LastDelimiter}
                         if backsl2=0 then naam3:=copy(data1,backsl1+1,length(data1)-backsl1+1)
                         else
                         begin
                           naam3:=copy(data1,backsl1+1,backsl2-backsl1-1);
                           naam4:=copy(data1,backsl2+1,length(data1)-backsl2+1);
                         end;
                       end;
                     end;
                   end;
                4: begin
                      val(data1,length2,fout2);{accept floating points}
                   end;{go to next object}
                5: begin
                     val(data1,width2,fout2);{accept floating points}
                   end;
                6: begin val(data1,pa,fout2);{accept floating points}
                         if fout2<>0 then pa:=999;end;
                         {orientation 0 komt ook voor daarom if not know=empthy equals 999}
       end;
       inc(x);
    until ((z>=6) or (fout<>0));
  until fout=0;  {repeat until no errors }
  result:=true;
end;


procedure plot_glx(dc:tcanvas;x9,y9,diameter,neigung {ratio width/length},orientation:double); {draw oval or galaxy}
var   glx :array[0..127 {nr}+1] of tpoint;
      i,nr                    : integer;
      r, sin_ori,cos_ori      : double;
begin
   if diameter<10 then nr:=22
   else
     if diameter<20 then nr:=44
   else
     nr:=127;

  if abs(neigung)<0.00001 then neigung:=0.00001;{show ring always also when it is flat}
   for i:=0 to nr+1 do
   begin
     r:=sqrt(sqr(diameter*neigung)/(1.00000000000001-(1-sqr(neigung))*sqr(cos(-pi*i*2/(nr))))); {radius ellips}
     sincos(orientation + pi*i*2/nr, sin_ori, cos_ori);
     glx[i].x:=round(x9    +r * sin_ori );
     glx[i].y:=round(y9    +r * cos_ori );
   end;
   dc.polygon(glx,nr+1)
    //else dc.polyline(glx,nr+1);
end;


procedure rotate(rot,x,y :double; out x2, y2: double);{rotate a vector point}
var
  sin_rot, cos_rot :double;
begin
  sincos(rot, sin_rot, cos_rot);
  x2:=x * + cos_rot + y*sin_rot;
  y2:=x * - sin_rot + y*cos_rot;{SEE PRISMA WIS VADEMECUM BLZ 68}
end;


{ transformation of equatorial coordinates into CCD pixel coordinates for optical projection, rigid method}
{ head.ra0,head.dec0: right ascension and declination of the optical axis}
{ ra,dec:   right ascension and declination}
{ xx,yy :   CCD coordinates}
{ cdelt:    CCD scale in arcsec per pixel}
procedure equatorial_standard(ra0,dec0,ra,dec, cdelt : double; var xx,yy: double);
var dv,sin_dec0,cos_dec0,sin_dec ,cos_dec,sin_deltaRA,cos_deltaRA: double;
begin
  sincos(dec0  ,sin_dec0 ,cos_dec0);
  sincos(dec   ,sin_dec  ,cos_dec );
  sincos(ra-ra0, sin_deltaRA,cos_deltaRA);
  dv  := (cos_dec0 * cos_dec * cos_deltaRA + sin_dec0 * sin_dec) / (3600*180/pi)*cdelt; {/ (3600*180/pi)*cdelt, factor for onversion standard coordinates to CCD pixels}
  xx := - cos_dec *sin_deltaRA / dv;{tangent of the angle in RA}
  yy := -(sin_dec0 * cos_dec * cos_deltaRA - cos_dec0 * sin_dec) / dv;  {tangent of the angle in DEC}
end;


procedure plot_deepsky(extract_visible: boolean;font_size: integer);{plot the deep sky object on the image. If extract is true then extract visible to variable_list}
type
  textarea = record
     x1,y1,x2,y2 : integer;
  end;
var
  dra,ddec, telescope_ra,telescope_dec,cos_telescope_dec,fov,ra2,dec2,length1,width1,pa,len,flipped,fitsX,fitsY,
  gx_orientation, delta_ra,det,SIN_dec_ref,COS_dec_ref,SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,hh,u0,v0 : double;
  name: string;
  flip_horizontal, flip_vertical                   : boolean;
  text_dimensions  : array of textarea;
  i,text_counter,th,tw,x1,y1,x2,y2,x,y : integer;
  overlap          : boolean;
  annotation_color2 : tcolor;
begin
  if ((head.naxis<>0) and (head.cd1_1<>0)) then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key
    flip_vertical:=mainform1.flip_vertical1.Checked;
    flip_horizontal:=mainform1.flip_horizontal1.Checked;

    if extract_visible then //for photometry
    begin
      variable_list:=nil;
      variable_list_length:=0;//declare empthy
      setlength(variable_list,1000);//make space
    end;

    {6. Passage (x,y) -> (RA,DEC) to find head.ra0,head.dec0 for middle of the image. See http://alain.klotz.free.fr/audela/libtt/astm1-fr.htm}
    {find RA, DEC position of the middle of the image}
    {FITS range 1..width, if range 1,2,3,4  then middle is 2.5=(4+1)/2 }
    pixel_to_celestial(head,(head.width+1)/2,(head.height+1)/2,mainform1.Polynomial1.itemindex,telescope_ra,telescope_dec); {fitsX, Y to ra,dec} {RA,DEC position of the middle of the image. Works also for case head.crpix1,head.crpix2 are not in the middle}

    cos_telescope_dec:=cos(telescope_dec);
    fov:=1.5*sqrt(sqr(0.5*head.width*head.cdelt1)+sqr(0.5*head.height*head.cdelt2))*pi/180; {field of view with 50% extra}
    linepos:=2;{Set pointer to the beginning. First two lines are comments}
    if head.cd1_1*head.cd2_2 - head.cd1_2*head.cd2_1>0 then flipped:=-1 {n-s or e-w flipped} else flipped:=1;  {Flipped image. Either flipped vertical or horizontal but not both. Flipped both horizontal and vertical is equal to 180 degrees rotation and is not seen as flipped}
    {$ifdef mswindows}
    if font_size<6 then
       mainform1.image1.Canvas.Font.Name:='Small fonts'
    else
       mainform1.image1.Canvas.Font.Name:='Default';

    {$endif}
    {$ifdef linux}
    mainform1.image1.Canvas.Font.Name:='DejaVu Sans';
    {$endif}
    {$ifdef darwin} {MacOS}
    mainform1.image1.Canvas.Font.Name:='Helvetica';
    {$endif}


    mainform1.image1.canvas.pen.Mode:=pmXor;
    mainform1.image1.Canvas.brush.Style:=bsClear;

    text_counter:=0;
    setlength(text_dimensions,200);

    sincos(head.dec0,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}

    while read_deepsky('S',telescope_ra,telescope_dec, cos_telescope_dec {cos(telescope_dec},fov,{var} ra2,dec2,length1,width1,pa) {deepsky database search} do
    begin
      celestial_to_pixel(head,ra2,dec2,true, fitsX,fitsY);{ra,dec to fitsX,fitsY}
      x:=round(fitsX-1);//In image array range 0..width-1, fits count from 1, image from zero therefore subtract 1
      y:=round(fitsY-1);


      if ((x>-0.25*head.width) and (x<=1.25*head.width) and (y>-0.25*head.height) and (y<=1.25*head.height)) then {within image1 with some overlap}
      begin
        len:=length1/(abs(head.cdelt2)*60*10*2); {Length in pixels}
        if ((head.cdelt2<0.25*1/60) or (len>=1) or (database_nr>=3)) then//avoid too many object on images with a large FOV
        begin
          if ((database_nr>=3) and (database_nr<=5)) then //variables
          begin
            with mainform1 do
            for i:=0 to high(Fshapes) do
            if ((Fshapes[i].shape<>nil) and (abs(x-Fshapes[i].fitsX)<5) and  (abs(y-Fshapes[i].fitsY)<5)) then  // note shape_fitsX/Y are in sensor coordinates
                     Fshapes[i].shape.HINT:=naam2;//copy(naam2,1,posex(' ',naam2,4)-1);

          end;

          gx_orientation:=(pa+head.crota2)*flipped;

          if flip_horizontal then begin x:=(head.width-1)-x; gx_orientation:=-gx_orientation; end;
          if flip_vertical then gx_orientation:=-gx_orientation else y:=(head.height-1)-y;

          {Plot deepsky text labels on an empthy text space.}
          { 1) If the center of the deepsky object is outside the image then don't plot text}
          { 2) If the text space is occupied, then move the text down. If the text crosses the bottom then use the original text position.}
          { 3) If the text crosses the right side of the image then move the text to the left.}
          { 4) If the text is moved in y then connect the text to the deepsky object with a vertical line.}

          if ( (x>=0) and (x<=head.width-1) and (y>=0) and (y<=head.height-1) and (naam2<>'') ) then {plot only text if center object is visible and has a name}
          begin
            if naam3='' then name:=naam2
            else
            if naam4='' then name:=naam2+'/'+naam3
            else
            name:=naam2+'/'+naam3+'/'+naam4;

            mainform1.image1.Canvas.font.size:=round(min(20,max(max(6,font_size),len /2)));

            if copy(naam2,1,1)='0' then
            begin
              annotation_color2:=cllime;
               if font_size<=3 then
                  name:=copy(name,5,7) //remove 000-
               else
               if font_size<=4 then
                 name:=copy(name,1,11); //remove all after abbreviation
            end
            else
              annotation_color2:=annotation_color;

            mainform1.image1.Canvas.font.color:=annotation_color2;
            mainform1.image1.canvas.pen.color:=annotation_color2;


            {get text dimensions}
            th:=mainform1.image1.Canvas.textheight(name);
            tw:=mainform1.image1.Canvas.textwidth(name);
            x1:=x;
            y1:=y;
            x2:=x+ tw;
            y2:=y+ th ;

            if ((x1<=head.width) and (x2>head.width)) then begin x1:=x1-(x2-head.width);x2:=head.width;end; {if text is beyond right side, move left}

            if text_counter>0 then {find free space in y for text}
            begin
              repeat {find free text area}
                overlap:=false;
                i:=0;
                repeat {test overlap}
                  if ( ((x1>=text_dimensions[i].x1) and (x1<=text_dimensions[i].x2) and (y1>=text_dimensions[i].y1) and (y1<=text_dimensions[i].y2)) {left top overlap} or
                       ((x2>=text_dimensions[i].x1) and (x2<=text_dimensions[i].x2) and (y1>=text_dimensions[i].y1) and (y1<=text_dimensions[i].y2)) {right top overlap} or
                       ((x1>=text_dimensions[i].x1) and (x1<=text_dimensions[i].x2) and (y2>=text_dimensions[i].y1) and (y2<=text_dimensions[i].y2)) {left bottom overlap} or
                       ((x2>=text_dimensions[i].x1) and (x2<=text_dimensions[i].x2) and (y2>=text_dimensions[i].y1) and (y2<=text_dimensions[i].y2)) {right bottom overlap} or

                       ((text_dimensions[i].x1>=x1) and (text_dimensions[i].x1<=x2) and (text_dimensions[i].y1>=y1) and (text_dimensions[i].y1<=y2)) {two corners of text_dimensions[i] within text} or
                       ((text_dimensions[i].x2>=x1) and (text_dimensions[i].x2<=x2) and (text_dimensions[i].y2>=y1) and (text_dimensions[i].y2<=y2)) {two corners of text_dimensions[i] within text}
                     ) then
                  begin
                    overlap:=true; {text overlaps an existing text}
                    y1:=y1+(th div 3);{try to shift text one third of the text height down}
                    y2:=y2+(th div 3);
                    if y2>=head.height then {no space left, use original position}
                    begin
                      y1:=y;
                      y2:=y+th ;
                      overlap:=false;{stop searching}
                      i:=$FFFFFFF;{stop searching}
                    end;
                 end;
                 inc(i);
               until ((i>=text_counter) or (overlap) );{until all tested or found overlap}
             until overlap=false;{continue till no overlap}
           end;

           text_dimensions[text_counter].x1:=x1;{store text dimensions in array}
           text_dimensions[text_counter].y1:=y1;
           text_dimensions[text_counter].x2:=x2;
           text_dimensions[text_counter].y2:=y2;

           if y1<>y then {there was textual overlap}
           begin
             mainform1.image1.Canvas.moveto(x,round(y+th/4));
             mainform1.image1.Canvas.lineto(x,y1);
           end;
           mainform1.image1.Canvas.textout(x1,y1,name);

           if ((extract_visible) and (text_counter<length(variable_list))) then //special option to add objects to list for photometry
           begin
             variable_list[text_counter].ra:=ra2;
             variable_list[text_counter].dec:=dec2;
             variable_list[text_counter].abbr:=naam2;
             variable_list[text_counter].source:=0; //local

             variable_list_length:=text_counter;
           end;
           inc(text_counter);
           if text_counter>=length(text_dimensions) then setlength(text_dimensions,text_counter+200);{increase size dynamic array}
         end;{centre object visible}

         {plot deepsky object}
         if width1=0 then begin width1:=length1;pa:=999;end;
         mainform1.image1.Canvas.Pen.width :=min(4,max(1,round(len/70)));

         {len is already calculated earlier for the font size}
         if len<=2 then {too small to plot an elipse or circle, plot just four dots}
         begin
           mainform1.image1.canvas.pixels[x-2,y+2]:=annotation_color2;
           mainform1.image1.canvas.pixels[x+2,y+2]:=annotation_color2;
           mainform1.image1.canvas.pixels[x-2,y-2]:=annotation_color2;
           mainform1.image1.canvas.pixels[x+2,y-2]:=annotation_color2;
         end
         else
         begin
           if PA<>999 then
             plot_glx(mainform1.image1.canvas,x,y,len,width1/length1,gx_orientation*pi/180) {draw oval or galaxy}
           else
           mainform1.image1.canvas.ellipse(round(x-len),round(y-len),round(x+1+len),round(y+1+len));{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
         end;
       end;//min size for large FOV
     end;
    end; {while loop};

    text_dimensions:=nil;{remove used memory}

    memo2_message('Added '+inttostr(text_counter)+ ' annotations.');

    Screen.Cursor:=crDefault;
  end;

end;{plot deep_sky}


procedure plot_vsx_vsp(extract_visible: boolean);{plot downloaded variable and comp stars}
type
  textarea = record
     x1,y1,x2,y2 : integer;
  end;

var
  dra,ddec, telescope_ra,telescope_dec, delta_ra,det,SIN_dec_ref,COS_dec_ref,SIN_dec_new,
  COS_dec_new,SIN_delta_ra,COS_delta_ra,hh,u0,v0,ra,dec,fitsX,fitsY,var_epoch,var_period,delta : double;
  abbreviation: string;
  flip_horizontal, flip_vertical: boolean;
  text_dimensions  : array of textarea;
  i,text_counter,th,tw,x1,y1,x2,y2,x,y,count,counts,mode,nrcount, font_size  : integer;
  overlap      : boolean;
begin
  if ((head.naxis<>0) and (head.cd1_1<>0)) then
  begin
    flip_vertical:=mainform1.flip_vertical1.Checked;
    flip_horizontal:=mainform1.flip_horizontal1.Checked;

    {6. Passage (x,y) -> (RA,DEC) to find head.ra0,head.dec0 for middle of the image. See http://alain.klotz.free.fr/audela/libtt/astm1-fr.htm}
    {find RA, DEC position of the middle of the image}
    {FITS range 1..width, if range 1,2,3,4  then middle is 2.5=(4+1)/2 }
    pixel_to_celestial(head,(head.width+1)/2,(head.height+1)/2,mainform1.Polynomial1.itemindex,telescope_ra,telescope_dec); {fitsX, Y to ra,dec} {RA,DEC position of the middle of the image. Works also for case head.crpix1,head.crpix2 are not in the middle}

    cos_telescope_dec:=cos(telescope_dec);

    font_size:=stackmenu1.font_size_photometry_UpDown1.position;
    {$ifdef mswindows}
     if font_size<6 then
        mainform1.image1.Canvas.Font.Name:='Small fonts'
     else
        mainform1.image1.Canvas.Font.Name:='Default';
    {$endif}
    {$ifdef linux}
    mainform1.image1.Canvas.Font.Name:='DejaVu Sans';
    {$endif}
    {$ifdef darwin} {MacOS}
    mainform1.image1.Canvas.Font.Name:='Helvetica';
    {$endif}


    mainform1.image1.canvas.pen.color:=annotation_color;
    mainform1.image1.canvas.pen.mode:=pmXor;
    mainform1.image1.Canvas.brush.Style:=bsClear;

    mainform1.image1.Canvas.font.size:=max(6,font_size);




   if extract_visible then //for photometry
   begin
     variable_list:=nil;
     variable_list_length:=0;//declare empthy
     setlength(variable_list,1000);//make space
     nrcount:=0;
   end;

    text_counter:=0;
    setlength(text_dimensions,200);

    sincos(head.dec0,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}

    for mode:=1 to 2 do //do both vsx and vsp
    begin
      if mode=1 then
        mainform1.image1.Canvas.font.color:=annotation_color{variable}
      else
        mainform1.image1.Canvas.font.color:=cllime;{AAVSO reference star}

      if mode=1 then
        counts:=length(vsx)
      else
        counts:=length(vsp);
      count:=0;

      while count<counts do //go through data
      begin
        if mode=1 then
        begin
          ra:=vsx[count].ra;
          dec:=vsx[count].dec;
        end
        else
        begin
          ra:=vsp[count].ra;
          dec:=vsp[count].dec;
        end;
        celestial_to_pixel(head,ra,dec,true, fitsX,fitsY);{ra,dec to fitsX,fitsY}
        x:=round(fitsX-1);//In image array range 0..width-1, fits count from 1, image from zero therefore subtract 1
        y:=round(fitsY-1);

        if ((x>0) and (x<head.width-1) and (y>0) and (y<head.height-1)) then {within image1}
        begin
          {Plot deepsky text labels on an empthy text space.}
          { 1) If the center of the deepsky object is outside the image then don't plot text}
          { 2) If the text space is occupied, then move the text down. If the text crosses the bottom then use the original text position.}
          { 3) If the text crosses the right side of the image then move the text to the left.}
          { 4) If the text is moved in y then connect the text to the deepsky object with a vertical line.}

          if mode=1 then //plot variable
          begin
            if font_size<5 then
              abbreviation:=vsx[count].name
            else
              abbreviation:=vsx[count].name+' '+vsx[count].maxmag+'-'+vsx[count].minmag+'_'+vsx[count].category+'_Period_'+vsx[count].period;

            with mainform1 do
            for i:=0 to high(Fshapes) do
              if ((Fshapes[i].shape<>nil) and (abs(x-Fshapes[i].fitsX)<5) and  (abs(y-Fshapes[i].fitsY)<5)) then  // note shape_fitsX/Y are in sensor coordinates
                Fshapes[i].shape.HINT:=vsx[count].name;


            var_epoch:=strtofloat1(vsx[count].epoch);
            var_period:=strtofloat1(vsx[count].period);
            if ((var_epoch<>0) and (var_period<>0)) then
            begin
              delta:=frac((jd_mid-var_epoch)/var_period);//in periods. Should jd_helio but that takes more computing
              if ((delta>0.95) or (delta<0.05)) then
                 abbreviation:=abbreviation+ '[AT MAX]';

                 //  if pos('AD CMi',abbreviation)>0 then
                 //  memo2_message(filename2+',  '+floattostr(jd_mid)+ ',   '+floattostr(delta));
            end;

            if ((extract_visible) and (nrcount<length(variable_list))) then //special option to add objects to list for photometry
            begin
              variable_list[nrcount].ra:=vsx[count].ra;
              variable_list[nrcount].dec:=vsx[count].dec;
              variable_list[nrcount].abbr:=abbreviation;
              variable_list[nrcount].source:=1;//vsx
              variable_list[nrcount].index:=count;//to retrieve all mangitudes
              variable_list_length:=nrcount;
              inc(nrcount);
            end;


          end
          else
          begin //plot check stars
            abbreviation:=vsp[count].auid;

            if font_size>=5 then
            begin
              abbreviation:=abbreviation+' V='+vsp[count].Vmag+'('+vsp[count].Verr+')';//display V always

              if ((pos('S',head.passband_database)>0) or (stackmenu1.reference_database1.itemindex>5)) then   //check passband_active in case auto selection is used.
              begin //Sloan filters used
                if vsp[count].SGmag<>'?' then abbreviation:=abbreviation+'_SG='+vsp[count].Vmag+'('+vsp[count].Verr+')';
                if vsp[count].SRmag<>'?' then abbreviation:=abbreviation+'_SR='+vsp[count].Bmag+'('+vsp[count].Berr+')';
                if vsp[count].SImag<>'?' then abbreviation:=abbreviation+'_SI='+vsp[count].Rmag+'('+vsp[count].Rerr+')';
              end
              else
              begin //UBVR
                if vsp[count].Bmag<>'?' then abbreviation:=abbreviation+'_B='+vsp[count].Bmag+'('+vsp[count].Berr+')';
                if vsp[count].Rmag<>'?' then abbreviation:=abbreviation+'_R='+vsp[count].Rmag+'('+vsp[count].Rerr+')';
              end;
            end
            else
            if font_size=3 then
            begin
               if copy(abbreviation,1,2)='00' then
               delete(abbreviation,1,4);//remove 000-
            end;

            with mainform1 do
            for i:=0 to high(Fshapes) do
            if ((Fshapes[i].shape<>nil) and (abs(x-Fshapes[i].fitsX)<5) and  (abs(y-Fshapes[i].fitsY)<5)) then  // note shape_fitsX/Y are in sensor coordinates
                     Fshapes[i].shape.HINT:=abbreviation;//copy(naam2,1,posex(' ',naam2,4)-1);


            if ((extract_visible) and (nrcount<length(variable_list))) then //special option to add objects to list for photometry
            begin
              variable_list[nrcount].ra:=vsp[count].ra;
              variable_list[nrcount].dec:=vsp[count].dec;
              variable_list[nrcount].abbr:=abbreviation;
              variable_list[nrcount].source:=2;//vsp
              variable_list[nrcount].index:=count;//to retrieve all mangitudes
              variable_list_length:=nrcount;
              inc(nrcount);
            end;
          end;

          if abbreviation<>'' then
          begin
            if flip_horizontal then begin x:=(head.width-1)-x;  end;
            if flip_vertical then  else y:=(head.height-1)-y;


            {get text dimensions}
            th:=mainform1.image1.Canvas.textheight(abbreviation);
            tw:=mainform1.image1.Canvas.textwidth(abbreviation);
            x1:=x;
            y1:=y;
            x2:=x+ tw;
            y2:=y+ th ;

            if ((x1<=head.width) and (x2>head.width)) then begin x1:=x1-(x2-head.width);x2:=head.width;end; {if text is beyond right side, move left}

            if text_counter>0 then {find free space in y for text}
            begin
              repeat {find free text area}
                overlap:=false;
                i:=0;
                repeat {test overlap}
                  if ( ((x1>=text_dimensions[i].x1) and (x1<=text_dimensions[i].x2) and (y1>=text_dimensions[i].y1) and (y1<=text_dimensions[i].y2)) {left top overlap} or
                       ((x2>=text_dimensions[i].x1) and (x2<=text_dimensions[i].x2) and (y1>=text_dimensions[i].y1) and (y1<=text_dimensions[i].y2)) {right top overlap} or
                       ((x1>=text_dimensions[i].x1) and (x1<=text_dimensions[i].x2) and (y2>=text_dimensions[i].y1) and (y2<=text_dimensions[i].y2)) {left bottom overlap} or
                       ((x2>=text_dimensions[i].x1) and (x2<=text_dimensions[i].x2) and (y2>=text_dimensions[i].y1) and (y2<=text_dimensions[i].y2)) {right bottom overlap} or

                       ((text_dimensions[i].x1>=x1) and (text_dimensions[i].x1<=x2) and (text_dimensions[i].y1>=y1) and (text_dimensions[i].y1<=y2)) {two corners of text_dimensions[i] within text} or
                       ((text_dimensions[i].x2>=x1) and (text_dimensions[i].x2<=x2) and (text_dimensions[i].y2>=y1) and (text_dimensions[i].y2<=y2)) {two corners of text_dimensions[i] within text}
                     ) then
                  begin
                    overlap:=true; {text overlaps an existing text}
                    y1:=y1+(th div 3);{try to shift text one third of the text height down}
                    y2:=y2+(th div 3);
                    if y2>=head.height then {no space left, use original position}
                    begin
                      y1:=y;
                      y2:=y+th ;
                      overlap:=false;{stop searching}
                      i:=$FFFFFFF;{stop searching}
                    end;
                  end;
                  inc(i);
                until ((i>=text_counter) or (overlap) );{until all tested or found overlap}
              until overlap=false;{continue till no overlap}
            end;

            text_dimensions[text_counter].x1:=x1;{store text dimensions in array}
            text_dimensions[text_counter].y1:=y1;
            text_dimensions[text_counter].x2:=x2;
            text_dimensions[text_counter].y2:=y2;

            if y1<>y then {there was textual overlap}
            begin
              mainform1.image1.Canvas.moveto(x,round(y+th/4));
              mainform1.image1.Canvas.lineto(x,y1);
            end;


              mainform1.image1.Canvas.textout(x1,y1,abbreviation);
            inc(text_counter);
            if text_counter>=length(text_dimensions) then setlength(text_dimensions,text_counter+200);{increase size dynamic array}

            {plot deepsky object}
            mainform1.image1.Canvas.Pen.width :=1;//min(4,max(1,round(len/70)));




            mainform1.image1.canvas.pixels[x-2,y+2]:=annotation_color;
            mainform1.image1.canvas.pixels[x+2,y+2]:=annotation_color;
            mainform1.image1.canvas.pixels[x-2,y-2]:=annotation_color;
            mainform1.image1.canvas.pixels[x+2,y-2]:=annotation_color;

          end;//abbreviation<>''

        end;
        inc(count);
      end;//while loop
    end;//plot vsx and vsp

    text_dimensions:=nil;{remove used memory}

    //memo2_message('Added '+inttostr(text_counter)+ ' annotations.');
  end;

end;{plot vsp stars}



function Gaia_star_color(Bp_Rp: integer):integer;
begin
  if Bp_Rp=-128  then result:=$00FF00 {unknown, green}
  else
  if Bp_Rp<=-0.25*10 then result:=$FF0000 {<-0.25 blauw}
  else
  if Bp_Rp<=-0.1*10 then result:=$FFFF00 {-0.25 tot -0.1 cyaan}
  else
  if Bp_Rp<=0.3*10 then result:=$FFFFFF {-0.1 tot 0.3 wit}
  else
  if Bp_Rp<=0.7*10 then result:=$A5FFFF {0.3 tot 0.7 geelwit}
  else
  if Bp_Rp<=1.0*10 then result:=$00FFFF {0.7 tot 1.0 geel}
  else
  if Bp_Rp<=1.5*10 then result:=$00A5FF {1.0 tot 1.5 oranje}
  else
  result:=$0000FF; {>1.5 rood}
end;


procedure get_best_mean(list,snr_list: array of double; leng : integer; out mean,standard_error_mean: double);{Remove outliers from population using MAD. }
var  {idea from https://eurekastatistics.com/using-the-median-absolute-deviation-to-find-outliers/}
  i                     : integer;
  median, mad,sd,count,noise  : double;

begin
  if leng=1 then begin mean:=list[0];exit end
  else
  if leng=2 then begin mean:=(list[0]+list[1])/2;exit end;

  mad_median(list,leng,mad,median);{calculate mad and median without modifying the data}

  sd:=mad*1.4826;//standard deviation calculated from mad

  count:=0;
  mean:=0;
  standard_error_mean:=0;

  for i:=0 to leng-1 do
  begin
    noise:=abs(list[i]-median);
    if noise<1.50*sd then {offset less the 1.5*sigma.}
//     if noise<2*sd then {offset less the 1.5*sigma.}
    begin
      mean:=mean+list[i]*snr_list[i];//Calculate weighted mean. This gives a little less noise then calculating median again.
      count:=count+snr_list[i];
      standard_error_mean:=standard_error_mean+sqr(noise*snr_list[i]);//for weighted standard error
    end;
  end;
  if count>0 then
  begin
    mean:=mean/count;  {mean without using outliers}
    standard_error_mean:=sqrt(standard_error_mean/sqr(count));
  end;

end;


procedure get_database_passband(filterstr: string; out passband :string);//report local or online database and the database passband
var
  datab,filterstrUP :string;
begin
  datab:=stackmenu1.reference_database1.text;
  if ((pos('auto',datab)>0) or (pos('Local',datab)>0)) then //local or auto
  begin  //auto
    filterstrUP:=uppercase(filterstr);
    if ((length(filterstrUP)=0) or (pos('CV',filterstrUP)>0))  then passband:='BP'  //Johnson-V, online
    else
    if pos('S',filterstrUP)>0 then //sloan
    begin
      if pos('G',filterstrUP)>0  then passband:='SG'  //SDSS-g
      else
      if pos('R',filterstrUP)>0  then passband:='SR'  //SDSS-r
      else
      if pos('I',filterstrUP)>0  then passband:='SI'  //SDSS-i
      else
      passband:='BP'  //online ; //unknown
    end
    else //Johnson-Cousins
    if pos('G',filterstrUP)>0  then passband:='V'  //TG, Johnson-V, online
    else
    if pos('V',filterstrUP)>0  then passband:='V'  //Johnson-V, online
    else
    if pos('B',filterstrUP)>0  then passband:='B'  //Johnson-V, online Blue
    else
    if pos('R',filterstrUP)>0  then passband:='R'  //Johnson-V, online red
    else
    passband:='BP';  //online take clear view

    memo2_message('Auto selected transformation as set in tab Photometry. Filter='+filterstr+'. Online Gaia ->'+passband);

  end
  else  //manual
  begin
    if pos('BP',datab)>0 then passband:='BP' //Gaia blue=CV=Gray, online
    else
    if pos('V',datab)>0 then passband:='V'  //Johnson-V, online
    else
    if pos('B',datab)>0 then  passband:='B'  //Johnson-B, online
    else
    if pos('R',datab)>0 then passband:='R'  //Cousins-R, online
    else
    if pos('SG',datab)>0 then passband:='SG' //Gaia blue=CV=Gray, online
    else
    if pos('SR',datab)>0 then passband:='SR'  //Johnson-V, online
    else
    if pos('SI',datab)>0 then  passband:='SI'  //Johnson-B, online
    else
      passband:='??';

    memo2_message('Manual selected transformation as set in tab Photometry. Filter='+filterstr+'. Online Gaia ->'+passband);
  end;
end;


procedure plot_and_measure_stars(img : Timage_array; memo: tstrings; var head : Theader; flux_calibration,plot_stars, report_lim_magn: boolean);{flux calibration,  annotate, report limiting magnitude}
var
  telescope_ra,telescope_dec,fov,ra2,dec2, magn,Bp_Rp, hfd1,star_fwhm,snr, flux, xc,yc, sep,SIN_dec_ref,COS_dec_ref,
  standard_error_mean,fov_org,fitsX,fitsY, frac1,frac2,frac3,frac4,x,y,x2,y2,flux_snr_7,apert,avg_flux_ratio,adu_e,mag_saturation,correction,val  : double;
  star_total_counter,len, max_nr_stars, area1,area2,area3,area4,nrstars_required2,count                                                       : integer;
  flip_horizontal, flip_vertical                        : boolean;
  flux_ratio_array,hfd_x_sd, flux_peak_ratio,snr_list   : array of double;
  selected_passband : string;
  data_max          : single;
  starlist1         : Tstar_list;

    procedure plot_star;
    begin
      if ((flux_calibration) and ( bp_rp>12) and (bp_rp<>999){mono colour database})then exit;{too red star for flux calibration. Bp-Rp>1.2 for about 30% of the stars}
      celestial_to_pixel(head,ra2,dec2,true, fitsX,fitsY);{ra,dec to fitsX,fitsY}
      x:=(fitsX-1);//In image array range 0..width-1, fits count from 1, image from zero therefore subtract 1
      y:=(fitsY-1);

      if ((x>-50) and (x<=head.width+50) and (y>-50) and (y<=head.height+50)) then {within image1 with some overlap}
      begin
        inc(star_total_counter);

        if plot_stars then
        begin {annotate}
          if flip_horizontal then x2:=(head.width-1)-x else x2:=x;
          if flip_vertical   then y2:=y            else y2:=(head.height-1)-y;

          if Bp_Rp<>999 then {colour version}
          begin
            mainform1.image1.Canvas.textout(round(x2),round(y2),inttostr(round(magn))+':'+inttostr(round(Bp_Rp)) {   +'<-'+inttostr(area290) });
            mainform1.image1.canvas.pen.color:=Gaia_star_color(round(Bp_Rp));{color circel}
          end
          else
            mainform1.image1.Canvas.textout(round(x2),round(y2),inttostr(round(magn)) );

          len:=round((200-magn)/5.02);
          mainform1.image1.canvas.ellipse(round(x2-len),round(y2-len),round(x2+1+len),round(y2+1+len));{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
        end;

        if ((flux_calibration) and (Bp_Rp<>-128 {if -128 then unreliable Johnson-V magnitude, either Bp or Rp is missing in Gaia})) then
        begin
          HFD(img,round(x),round(y), annulus_radius{14,annulus radius},head.mzero_radius,adu_e {adu_e. SNR only in ADU for consistency}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if ((hfd1<15) and (hfd1>=0.8) {two pixels minimum}) then
           if snr>30 then {star detected in img. 30 is found emperical}
          begin
            if ((img[0,round(yc),round(xc)]<data_max-1000) and
                (img[0,round(yc-1),round(xc)]<data_max-1000) and
                (img[0,round(yc+1),round(xc)]<data_max-1000) and
                (img[0,round(yc),round(xc-1)]<data_max-1000) and
                (img[0,round(yc),round(xc+1)]<data_max-1000) and

                (img[0,round(yc-1),round(xc-1)]<data_max-1000) and
                (img[0,round(yc-1),round(xc+1)]<data_max-1000) and
                (img[0,round(yc+1),round(xc-1)]<data_max-1000) and
                (img[0,round(yc+1),round(xc+1)]<data_max-1000)  ) then {not saturated}
            begin
              if counter_flux_measured>=length(flux_ratio_array) then //increase array sizes
              begin
                SetLength(flux_ratio_array,counter_flux_measured+500);
                SetLength(snr_list,counter_flux_measured+500);
                if report_lim_magn then
                begin
                  SetLength(hfd_x_sd,counter_flux_measured+500);
                  SetLength(flux_peak_ratio,counter_flux_measured+500);
                end;
              end;
              flux_ratio_array[counter_flux_measured]:=flux/(power(10,(21 {bias}-magn/10)/2.5)); //Linear flux ratio,  should be constant for all stars.
              snr_list[counter_flux_measured]:=snr;

             // memo2_message(#9+floattostr4(magn/10)+#9+floattostr4(2.5 * ln(flux)/ln(10) ));
              if report_lim_magn then
              begin
                hfd_x_sd[counter_flux_measured]:=hfd1*sd_bg;//calculate hfd*SD. sd_bg  is a global variable from procedure hfd. The minimum diameter for star detection is 4
                flux_peak_ratio[counter_flux_measured]:=flux/img[0,round(yc),round(xc)];
              end;

              //  memo2_message(#9+floattostr4(snr)+#9+floattostr4(hfd1)+#9+floattostr4(R_aperture)+#9+floattostr4(sd_bg) );
              inc(counter_flux_measured); {increase counter of number of stars analysed}
            end;

          end; {snr>30}
        end;{flux calibration}
      end;
    end;
begin
  if ((head.naxis<>0) and (head.cd1_1<>0)) then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    flip_vertical:=mainform1.flip_vertical1.Checked;
    flip_horizontal:=mainform1.flip_horizontal1.Checked;

//    sip:=((ap_order>=2) and (mainform1.Polynomial1.itemindex=1));{use sip corrections?}  Already set

//  if ((usethesip) and (ap_order<>0)) then {apply SIP correction, sky to pixel}

    bp_rp:=999;{not defined in mono versions of the database}

    {Fits range 1..width, if range 1,2,3,4  then middle is 2.5=(4+1)/2 }
    pixel_to_celestial(head,(head.width+1)/2,(head.height+1)/2,1{wcs and sip if available},telescope_ra,telescope_dec); {RA,DEC position of the middle of the image. Works also for case head.crpix1,head.crpix2 are not in the middle}

    mainform1.image1.Canvas.Pen.width :=1; // round(1+head.height/mainform1.image1.height);{thickness lines}
    mainform1.image1.Canvas.Pen.mode:=pmCopy;
    mainform1.image1.canvas.pen.color:=$00B0FF ;{orange}


    {$ifdef mswindows}
    mainform1.image1.Canvas.Font.Name:='Default';
    {$endif}
    {$ifdef linux}
    mainform1.image1.Canvas.Font.Name:='DejaVu Sans';
    {$endif}
    {$ifdef darwin} {MacOS}
    mainform1.image1.Canvas.Font.Name:='Helvetica';
    {$endif}

    mainform1.image1.Canvas.font.size:=8; //round(14*head.height/mainform1.image1.height);{adapt font to image dimensions}
    mainform1.image1.Canvas.brush.Style:=bsClear;

    mainform1.image1.Canvas.font.color:=$00B0FF ;{orange}

    star_total_counter:=0;{total counter}
    counter_flux_measured:=0;
    data_max:=head.datamax_org-1;

    max_nr_stars:=round(head.width*head.height*(1216/(2328*1760))); {Check 1216 stars in a circle resulting in about 1000 stars in a rectangle for image 2328 x1760 pixels}
    fov_org:= sqrt(sqr(head.width*head.cdelt1)+sqr(head.height*head.cdelt2))*pi/180; {field of view circle covering all corners with 0% extra}

    if flux_calibration then
    begin
      max_nr_stars:=round(head.width*head.height*(730/(2328*1760))); {limit to the brightest stars. Fainter stars have more noise}
      setlength(flux_ratio_array,max_nr_stars);
      setlength(snr_list,max_nr_stars);
      if report_lim_magn then
      begin
        setlength(hfd_x_sd,max_nr_stars);
        setlength(flux_peak_ratio,max_nr_stars);
      end;
      adu_e := retrieve_ADU_to_e_unbinned(head.egain);
    end;

    {sets file290 so do before fov selection}
    if stackmenu1.reference_database1.itemindex=0 then  //local database
      begin
        if select_star_database(stackmenu1.star_database1.text,head.height*abs(head.cdelt2) {fov})=false then exit;
        memo2_message('Using star database '+uppercase(name_database));
        if uppercase(copy(name_database,1,1))='V' then passband_active:='V' else passband_active:='BP';// for reporting
    end
    else
    begin  //Reading online database. Update if required
      get_database_passband(head.filter_name,{out} selected_passband);//report selected Gaia passband

      if gaia_magn_limit+0.01<mag2/10 then sep:=999 //update required based on magnitude
      else
      ang_sep(telescope_ra,telescope_dec,gaia_ra,gaia_dec,sep);//update required based on position

      if ((sep>0.15*fov_org) or (online_database=nil)) then  //other sky area, update Gaia database online
      begin
        if select_star_database(stackmenu1.star_database1.text,fov_org {fov})=false then exit;

       if read_stars(telescope_ra,telescope_dec,fov_org, database_type, max_nr_stars,{out} starlist1) then {read star from local star database to find the maximum magnitude required for this. Max magnitude is stored in mag2}
        begin //maximum magnitude mag2 is known for the amount of stars for calibration using online stars
          memo2_message('Requires stars down to magnitude '+floattostrF(mag2/10,FFFixed,0,2)+ ' for '+inttostr( max_nr_stars)+' stars')  ;
          if read_stars_online(telescope_ra,telescope_dec,fov_org, mag2/10 {max_magnitude})= false then
          begin
            memo2_message('Error. failure accessing Vizier for Gaia star database!');
            Screen.Cursor:=crDefault;
            exit;
          end;
        end
        else
        begin
          memo2_message('Error 1476');
          Screen.Cursor:=crDefault;
          exit;
        end;
      end;
      database_type:=0;//online

      convert_magnitudes(selected_passband {set in call to get_database_passband}) //convert Gaia magnitude to a new magnitude. If the type is already correct, no action will follow
                        //database_passband will be stored in passband_active
    end; //online


    sincos(head.dec0,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}

    if database_type>1 then {1476 or 290 files}
    begin
      if database_type=1476 then {.1476 files}
        fov:=min(fov_org,5.142857143*pi/180) {warning FOV should be less the database tiles dimensions, so <=5.142857143 degrees. Otherwise a tile beyond next tile could be selected}
      else {.290 files}
        fov:=min(fov_org,9.53*pi/180); {warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected}

      if fov_org>fov then max_nr_stars:=round(max_nr_stars*sqr(fov)/sqr(fov_org));{reduce number of stars for very large FOV}

      find_areas( telescope_ra,telescope_dec, fov,{var} area1,area2,area3,area4, frac1,frac2,frac3,frac4);{find up to four star database areas for the square image}

      {read 1th area}
      if area1<>0 then {read 1th area}
      begin
        if open_database(telescope_dec,area1)=false then begin exit; end; {open database file or reset buffer}
        nrstars_required2:=trunc(max_nr_stars * frac1);
        while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, magn,Bp_Rp)) ) do plot_star;{add star}
      end;

      {read 2th area}
      if area2<>0 then {read 2th area}
      begin
        if open_database(telescope_dec,area2)=false then begin exit; end; {open database file or reset buffer}
        nrstars_required2:=trunc(max_nr_stars * (frac1+frac2));
        while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, magn,Bp_Rp)) ) do plot_star;{add star}
      end;

      {read 3th area}
      if area3<>0 then {read 3th area}
      begin
        if open_database(telescope_dec,area3)=false then begin exit; end; {open database file or reset buffer}
        nrstars_required2:=trunc(max_nr_stars * (frac1+frac2+frac3));
        while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, magn,Bp_Rp)) ) do plot_star;{add star}
      end;
      {read 4th area}
      if area4<>0 then {read 4th area}
      begin
        if open_database(telescope_dec,area4)=false then begin exit; end; {open database file or reset buffer}
        nrstars_required2:=trunc(max_nr_stars * (frac1+frac2+frac3+frac4));
        while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, magn,Bp_Rp)) ) do plot_star;{add star}
      end;
      close_star_database;
    end
    else
    if database_type=1 then
    begin {W08 single file wide field database}
      if wide_database<>name_database then
                              read_stars_wide_field;{load wide field stars array}
      count:=0;
      while ((star_total_counter<max_nr_stars) and  (count<length(wide_field_stars) div 3) ) do {star file 001 database read. Read up to nrstars_required}
      begin
        magn:=wide_field_stars[count*3];{contains: mag1, ra1,dec1, magn,ra2,dec2,mag3........}
        ra2:=wide_field_stars[count*3+1];
        dec2:=wide_field_stars[count*3+2];
        ang_sep(ra2,dec2,telescope_ra,telescope_dec, sep);{angular seperation}
        if ((sep<fov_org*0.5*0.9*(2/sqrt(pi))) and  (sep<pi/2)) then  {factor 2/sqrt(pi) is to adapt circle search field to surface square. Factor 0.9 is a fiddle factor for trees, house and dark corners. Factor <pi/2 is the limit for procedure equatorial_standard}
        begin
          plot_star;{add star}
          inc(star_total_counter);

        end;
        inc(count);
      end;
    end
    else
    begin //Database_type=0, Vizier online, Gaia
       count:=0;
       //database should all ready been filled
       while (count<length(online_database[0])) do {read stars}
       begin
         ra2:=online_database[0,count];
         dec2:=online_database[1,count];
         magn:=online_database[5,count]*10;//magnitude
         if magn<>0 then
           plot_star;{add star}
         inc(count);
       end;
     end;

    if flux_calibration then {flux calibration}
    begin
      if counter_flux_measured>=3 then {at least three stars}
      begin
        get_best_mean(flux_ratio_array,snr_list,counter_flux_measured {length},avg_flux_ratio,standard_error_mean );//calculate average of flux ratio. Can't do that on mzero. Should be a linear scale
        head.mzero:=21{bias} + ln(avg_flux_ratio)*2.5/ln(10);//from flux ratio to mzero
        standard_error_mean:=ln((avg_flux_ratio+standard_error_mean)/avg_flux_ratio)*2.5/ln(10);//Convert ratio error to error in magnitudes. Note that log(a)−log(b)=log(a/b) and log():=ln()/ln(10)


        head.passband_database:=passband_active; //passband_active is global variable. Now store in the header. head.passband_database can also be retrieved using keyword MZEROPAS

        if copy(stackmenu1.flux_aperture1.text,1,1)='m' then //=Max, calibration for extended objects
          update_float(memo,'MZERO   =',' / Magnitude Zero Point. '+head.passband_database+'=-2.5*log(flux_e)+MZERO',false,head.mzero)
        else
          update_text(memo,'MZERO   =','                   0 / Unknown. Set aperture to MAX for ext. objects  ');//use update_text to also clear any old comment

        update_float(memo,'MZEROR  =',' / '+head.passband_database+'=-2.5*log(flux_e)+MZEROR using MZEROAPT',false,head.mzero);//mzero for aperture diameter MZEROAPT
        update_float(memo,'MZEROAPT=',' / Aperture radius used for MZEROR in pixels',false,head.mzero_radius);
        update_text(memo,'MZEROPAS=',copy(char(39)+passband_active+char(39)+'                    ',1,21)+'/ Passband database used.');


         // The magnitude measured is
         // fluxratio:=flux * 2.511886432^magn   Should be the same for all stars
         // fluxratio/flux:=2.511886432^magn
         // magn:=ln(flux_ratio/flux)/ln(2.511886432)
         // str(ln(flux_ratio/flux)/ln(2.511886432):0:1,mag_str);
         // equals  str(log(flux_ratio/flux)/log(2.511886432):0:1,mag_str);  ln() can be replaced by log() in a division
         // Note log(2.511886432)=0.4 equals 1/2.5
         // equals str(2.5*log(flux_ratio) - 2.5*log(flux)):0:1,mag_str);
         // equals 2.5*log(flux_ratio) is MZERO
         // so MZERO=2.5*ln(flux_ratio)/ln(10);
         // backward:
         // str(MZERO - 2.5*log(flux)):0:1,mag_str);
         // str(MZERO - 2.5*ln(flux)/ln(10)):0:1,mag_str);
         //
         // test proves it:
         // mag:=ln(flux_ratio/flux)/ln(2.511886432);
         // mag:=MZERO - 2.5*ln(flux)/ln(10);

         //flux_ratio:=exp(mzero*ln(10)/2.5);

        if head.mzero_radius=99 then
          memo2_message('Photometry calibration for EXTENDED OBJECTS successful. '+inttostr(counter_flux_measured)+
                        ' Gaia stars used for flux calibration.  Flux aperture diameter: measured star diameter.'+
                        ' Standard error MZERO [magn]: '+floattostrF(standard_error_mean,ffFixed,0,3)+
                        '%. Annulus inner diameter: '+inttostr(1+(annulus_radius)*2){background is measured 2 pixels outside rs}+' pixels. Stars with pixel values close to '+inttostr(round(head.datamax_org))+' are ignored.')

        else
          memo2_message('Photometry calibration for POINT SOURCES successful. '+inttostr(counter_flux_measured)+
                        ' Gaia stars used for flux calibration.  Flux aperture diameter: '+floattostrf(head.mzero_radius*2, ffFixed, 0,2)+' pixels.'+
                        ' Standard error MZERO [magn]: '+floattostrF(standard_error_mean,ffFixed,0,3)+
                        '%. Annulus inner diameter: '+inttostr(1+(annulus_radius)*2){background is measured 2 pixels outside rs}+' pixels. Stars with pixel values close to '+inttostr(round(head.datamax_org))+' are ignored.');

        memo2_message('Photometric calibration is only valid if the filter passband ('+head.filter_name+') is compatible with the passband reference database ('+head.passband_database+'). This is indicated by the coloured square icons in tab photometry.');

        if report_lim_magn then
        begin
         {snr formula      snr:=flux/sqrt(flux + r*r*pi* sd^2).
          for faint stars  snr ≈flux/sqrt( 0 + r*r*pi* sd^2)
                           flux≈snr*sqrt( 0 + r*r*pi* sd^2)
                           flux≈snr*r*sqrt(pi)*sd
                           flux≈snr*(hfd*1.0)*sqrt(pi)*sd   assuming star diameter for the faintest stars is reduced to 2 * hfd average, so radius is 1*hfd
                             }
          flux_snr_7:=7*sqrt(pi)*Smedian(hfd_x_sd,counter_flux_measured {length});{Assuming minimum SNR is 7 and the aperture is reduced to about 2 * hfd for the faintest stars. So r=HFD}
          apert:=strtofloat2(stackmenu1.flux_aperture1.text);{aperture diameter expressed in HFD's. If aperture diameter is HFD, half of the star flux is lost}
          if apert=0 then apert:=10; {aperture is zero if is set at max text. Set very high}

          //encircled flux =1-EXP(-0.5*(radial_distance/sigma)^2)
          //encircled flux =1-EXP(-0.5*((apert*HFD/2)/(HFD/2.3548))^2)
          //encircled flux =1-EXP(-0.5*(apert*2.3548/2))^2)
          correction:=(1-EXP(-0.5*sqr(apert*2.3548/2 {sigma})));
          flux_snr_7:=flux_snr_7*correction; {Correction for reduced aparture.}

          head.magn_limit:=head.mzero-ln(flux_snr_7)*2.5/ln(10); //global variable.  same as:  mzero-ln(flux)*2.5/ln(10)

          //mag:=MZERO - 2.5*ln(flux)/ln(10);
          mag_saturation:=head.mzero-ln( 0.95*data_max*Smedian(flux_peak_ratio,counter_flux_measured {length} ) )*2.5/ln(10);

          magn_limit_str:='Limiting magnitude is '+ floattostrF(head.magn_limit,ffFixed,0,2)+' ( σ='+floattostrF(standard_error_mean,ffgeneral,2,0)+', SNR=7, aperture ⌀'+stackmenu1.flux_aperture1.text+') Saturation at ≈ '+floattostrF(mag_saturation,ffFixed,0,1);

          update_float(memo,'LIM_MAGN=',' / Limiting magnitude (SNR=7, aperture '+floattostr2(head.mzero_radius)+' px)',false ,head.magn_limit);

          memo2_message(magn_limit_str);
          mainform1.caption:='Photometry calibration successful. '+magn_limit_str;
        end;
      end
      else
      begin
        magn_limit_str:='Calibration failure! Less then three usable stars found.';
        mainform1.caption:=magn_limit_str;
        memo2_message(magn_limit_str);
      end;
    end;

    Screen.Cursor:=crDefault;
  end;{fits file}
end;{plot stars}




procedure measure_distortion(out stars_measured : integer);{measure or plot distortion}
var
  telescope_ra,telescope_dec,fov,fov_org,ra2,dec2, mag2,Bp_Rp, hfd1,star_fwhm,snr, flux, xc,yc,
  frac1,frac2,frac3,frac4,u0,v0,x,y,x2,y2,astrometric_error_innner, astrometric_error_outer,sep,
  ra3,dec3,astrometric_error_innnerPS,astrometric_error_outerPS                                 : double;
  star_total_counter, max_nr_stars, area1,area2,area3,area4,nrstars_required2,i,sub_counter,
  sub_counter2,sub_counter3,sub_counter4,scale,count, formalism                                 : integer;
  flip_horizontal, flip_vertical                                                                : boolean;
  errors_sky_pixel1, errors_sky_pixel2,errors_pixel_sky1,errors_pixel_sky2   : array of double;

    procedure plot_star;
    var
      fitsX,fitsY : double;
    begin
      celestial_to_pixel(head,ra2,dec2,false, fitsX,fitsY);{ra,dec to fitsX,fitsY}
      x:=fitsX-1;//fits count from 1, image from zero therefore subtract 1
      y:=fitsY-1;

      if ((x>-50) and (x<=head.width+50) and (y>-50) and (y<=head.height+50)) then {within image1 with some overlap}
      begin
        inc(star_total_counter);

        if flip_horizontal then x2:=(head.width-1)-x else x2:=x;
        if flip_vertical   then y2:=y            else y2:=(head.height-1)-y;

        HFD(img_loaded,round(x),round(y), 14 {annulus_radius},99 {flux_aperture},0 {adu_e}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
        if ((hfd1<15) and (hfd1>=0.8) {two pixels minimum} and (snr>10)) then {star detected in img_loaded}
        begin
          mainform1.image1.Canvas.Pen.width :=3;
          mainform1.image1.Canvas.MoveTo(round(x2), round(y2));
          mainform1.image1.Canvas.LineTo(round(x2+(x-xc)*50),round(y2-(y-yc)*50 ));
          mainform1.image1.Canvas.Pen.width :=1;

          {for median errror}
          if  ( (sqr(x-head.crpix1)+sqr(y-head.crpix2)<sqr(0.25*head.height)) and (sub_counter<length(errors_sky_pixel1))) then
          begin
            errors_sky_pixel1[sub_counter]:=sqrt(sqr(X-xc)+sqr(Y-yc));{add errors to array}
            inc(sub_counter);

            //check sky to pixel errors:
            if sub_counter3<length(errors_pixel_sky1) then
            begin
              pixel_to_celestial(head,xc+1,yc+1,formalism,ra3,dec3);{calculate the ra,dec position}
              ang_sep(ra3,dec3,ra2,dec2,errors_pixel_sky1[sub_counter3] );//angular seperation
              inc(sub_counter3);
            end;
          end;
         if  ( (sqr(x-head.crpix1)+sqr(y-head.crpix2)>sqr(0.5*head.height)) and (sub_counter2<length(errors_sky_pixel2))) then
          begin
            errors_sky_pixel2[sub_counter2]:=sqrt(sqr(X-xc)+sqr(Y-yc));{add errors to array}
            inc(sub_counter2);

            //check sky to pixel errors:
            if sub_counter4<length(errors_pixel_sky2) then
            begin
              pixel_to_celestial(head,xc+1,yc+1,formalism,ra3,dec3);{calculate the ra,dec position}
              ang_sep(ra3,dec3,ra2,dec2,errors_pixel_sky2[sub_counter4] );//angular seperation
              inc(sub_counter4);
            end;
          end;
          if stars_measured<max_nr_stars then {store distortion data}
          begin
            distortion_data[0,stars_measured]:=x;{database}
            distortion_data[1,stars_measured]:=y;
            distortion_data[2,stars_measured]:=xc;{measured}
            distortion_data[3,stars_measured]:=yc;
            inc(stars_measured);
          end;
        end;
      end;
    end;{sub procedure}
begin
  if ((head.naxis<>0) and (head.cd1_1<>0)) then
  begin
    Screen.Cursor:=crHourglass;{$IfDef Darwin}{$else}application.processmessages;{$endif}// Show hourglass cursor, processmessages is for Linux. Note in MacOS processmessages disturbs events keypress for lv_left, lv_right key

    flip_vertical:=mainform1.flip_vertical1.Checked;
    flip_horizontal:=mainform1.flip_horizontal1.Checked;

    bp_rp:=999;{not defined in mono versions of the database}

    {Fits range 1..width, if range 1,2,3,4  then middle is 2.5=(4+1)/2 }
    pixel_to_celestial(head,(head.width+1)/2,(head.height+1)/2,0{wcs only},telescope_ra,telescope_dec); {RA,DEC position of the middle of the image. Works also for case head.crpix1,head.crpix2 are not in the middle}

    mainform1.image1.Canvas.Pen.mode:=pmCopy;
    mainform1.image1.Canvas.Pen.width :=1; // round(1+head.height/mainform1.image1.height);{thickness lines}
    mainform1.image1.canvas.pen.color:=$00B0FF; {orange}

    star_total_counter:=0;{total counter}
    sub_counter:=0;
    sub_counter2:=0;
    sub_counter3:=0;
    sub_counter4:=0;

    max_nr_stars:=round(head.width*head.height*(1216/(2328*1760))); {Check 1216 stars in a circle resulting in about 1000 stars in a rectangle for image 2328 x1760 pixels}
    setlength(errors_sky_pixel1,max_nr_stars);
    setlength(errors_sky_pixel2,max_nr_stars);
    setlength(errors_pixel_sky1,max_nr_stars);
    setlength(errors_pixel_sky2,max_nr_stars);


    {sets file290 so do before fov selection}
    if select_star_database(stackmenu1.star_database1.text,15 {neutral})=false then exit;

    setlength(distortion_data,4,max_nr_stars);
    stars_measured:=0;{star number}

    fov_org:= sqrt(sqr(head.width*head.cdelt1)+sqr(head.height*head.cdelt2))*pi/180; {field of view circle covering all corners with 0% extra}
    formalism:=mainform1.Polynomial1.itemindex;

    if database_type>1 then {1476 or 290 files}
    begin
      if  database_type=1476 then {.1476 files}
        fov:=min(fov_org,5.142857143*pi/180) {warning FOV should be less the database tiles dimensions, so <=5.142857143 degrees. Otherwise a tile beyond next tile could be selected}
      else
      if  database_type=290 then {.290 files}
        fov:=min(fov_org,9.53*pi/180); {warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected}


      find_areas( telescope_ra,telescope_dec, fov,{var} area1,area2,area3,area4, frac1,frac2,frac3,frac4);{find up to four star database areas for the square image}

      {read 1th area}
      if area1<>0 then {read 1th area}
      begin
        if open_database(telescope_dec,area1)=false then begin exit; end; {open database file or reset buffer}
        nrstars_required2:=trunc(max_nr_stars * frac1);
        while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp)) ) do plot_star;{add star}
      end;

      {read 2th area}
      if area2<>0 then {read 2th area}
      begin
        if open_database(telescope_dec,area2)=false then begin exit; end; {open database file or reset buffer}
        nrstars_required2:=trunc(max_nr_stars * (frac1+frac2));
        while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp)) ) do plot_star;{add star}
      end;

      {read 3th area}
      if area3<>0 then {read 3th area}
      begin
        if open_database(telescope_dec,area3)=false then begin exit; end; {open database file or reset buffer}
        nrstars_required2:=trunc(max_nr_stars * (frac1+frac2+frac3));
        while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp)) ) do plot_star;{add star}
      end;
      {read 4th area}
      if area4<>0 then {read 4th area}
      begin
        if open_database(telescope_dec,area4)=false then begin exit; end; {open database file or reset buffer}
        nrstars_required2:=trunc(max_nr_stars * (frac1+frac2+frac3+frac4));
        while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp)) ) do plot_star;{add star}
      end;

      close_star_database;
    end
    else
    begin {W08 database}
      if wide_database<>name_database then
                              read_stars_wide_field;{load wide field stars array}
      count:=0;
      while ((star_total_counter<max_nr_stars) and  (count<length(wide_field_stars) div 3) ) do {star file 001 database read. Read up to nrstars_required}
      begin
        mag2:=wide_field_stars[count*3];{contains: mag1, ra1,dec1, mag2,ra2,dec2,mag3........}
        ra2:=wide_field_stars[count*3+1];
        dec2:=wide_field_stars[count*3+2];
        ang_sep(ra2,dec2,telescope_ra,telescope_dec, sep);{angular seperation}
        if ((sep<fov_org*0.5*0.9*(2/sqrt(pi))) and  (sep<pi/2)) then  {factor 2/sqrt(pi) is to adapt circle search field to surface square. Factor 0.9 is a fiddle factor for trees, house and dark corners. Factor <pi/2 is the limit for procedure equatorial_standard}
        begin
          plot_star;{add star}
          inc(star_total_counter);

        end;
        inc(count);
      end;
    end;

    {$ifdef mswindows}
     mainform1.image1.Canvas.Font.Name:='Default';
    {$endif}
    {$ifdef linux}
    mainform1.image1.Canvas.Font.Name:='DejaVu Sans';
    {$endif}
    {$ifdef darwin} {MacOS}
    mainform1.image1.Canvas.Font.Name:='Helvetica';
    {$endif}

    astrometric_error_innner:=smedian(errors_sky_pixel1,sub_counter); //pixels
    astrometric_error_outer:=smedian(errors_sky_pixel2,sub_counter2);
    astrometric_error_innnerPS:=smedian(errors_pixel_sky1,sub_counter)*180/pi;//median value degrees
    astrometric_error_outerPS:=smedian(errors_pixel_sky2,sub_counter2)*180/pi;


    memo2_message('Pixel->Sky error inside '+floattostr4(astrometric_error_innnerPS*3600)+'" or ' +floattostr4(astrometric_error_innnerPS/head.cdelt2)+' pixel using '+inttostr(sub_counter3)+ ' stars.'+
                                  ' Outside '+floattostr4(astrometric_error_outerPS*3600)+'" or ' +floattostr4(astrometric_error_outerPS/head.cdelt2)+' pixel using '+inttostr(sub_counter4)+ ' stars.');
    memo2_message('Sky->Pixel error inside '+floattostr4(astrometric_error_innner*head.cdelt2*3600)+'" or ' +floattostr4(astrometric_error_innner)+' pixel using '+inttostr(sub_counter)+ ' stars.'+
                                   ' Outside '+floattostr4(astrometric_error_outer*head.cdelt2*3600)+'" or ' +floattostr4(astrometric_error_outer)+' pixel using '+inttostr(sub_counter2)+ ' stars.');




    mainform1.image1.Canvas.Pen.mode:=pmXor;
    mainform1.image1.canvas.pen.color:=annotation_color;
    mainform1.image1.Canvas.brush.Style:=bsClear;
    mainform1.image1.Canvas.font.color:=annotation_color;
    mainform1.image1.Canvas.font.size:=8;

    mainform1.image1.Canvas.Pen.width :=3;

    {scale in pixels}
    mainform1.image1.Canvas.MoveTo(20, head.height-30);
    mainform1.image1.Canvas.LineTo(20+50*3,head.height-30);
    for i:=0 to 3 do
    begin
      mainform1.image1.Canvas.MoveTo(20+50*i,head.height-25);
      mainform1.image1.Canvas.LineTo(20+50*i,head.height-35);
      mainform1.image1.Canvas.textout(17+50*i,head.height-25,inttostr(i));
    end;
    mainform1.image1.Canvas.textout(20,head.height-60,'Scale in pixels');


    {scale in arc seconds}
    scale:=round(50/(head.cdelt2*3600));
    mainform1.image1.Canvas.MoveTo(220, head.height-30);
    mainform1.image1.Canvas.LineTo(220+scale*3,head.height-30);


    for i:=0 to 3 do
    begin
      mainform1.image1.Canvas.MoveTo(220+scale*i,head.height-25);
      mainform1.image1.Canvas.LineTo(220+scale*i,head.height-35);
      mainform1.image1.Canvas.textout(217+scale*i,head.height-25,inttostr(i)+'"');
    end;
    mainform1.image1.Canvas.textout(220,head.height-60,'Scale in arcsecs');

    mainform1.image1.Canvas.font.size:=12;

    mainform1.image1.Canvas.textout(500,head.height-50,'Pixel->Sky error inside '+floattostr4(astrometric_error_innnerPS*3600)+'", outside '+floattostr4(astrometric_error_outerPS*3600)+'"');
    mainform1.image1.Canvas.textout(500,head.height-25,'Sky->Pixel error inside '+floattostr4(astrometric_error_innner*head.cdelt2*3600)+'", outside '+floattostr4(astrometric_error_outer*head.cdelt2*3600)+'"');

    //  errors_sky_pixel1 :=nil;  not required auto deallocated
    //  errors_sky_pixel2:=nil;

    Screen.Cursor:=crDefault;
  end;{fits file}
end;{measure distortion}


function plot_artificial_stars(img: Timage_array;head: theader): boolean;{plot stars as single pixel with a value as the magnitude. For super nova and minor planet search}
var
  fitsX,fitsY, telescope_ra,telescope_dec,fov_org,ra2,dec2,
  mag2, m_limit,sep : double;
  x,y,count                                                        : integer;
  passband                                                         : string;

    procedure plot_star;
    begin
      celestial_to_pixel(head, ra2,dec2,true, fitsX,fitsY);{ra,dec to fitsX,fitsY}
      x:=round(fitsX-1); {0..head.width-1}
      y:=round(fitsY-1); {0..head.height-1}

      if ((x>=0) and (x<=head.width-1) and (y>=0) and (y<=head.height-1)) then {within image1}
      begin
        if img[0,y,x]>=1000 then //empthy
          img[0,y,x]:=mag2 //no star at this location
        else
          img[0,y,x]:=-2.5*ln(power(10,-0.4*img[0,y,x]) + power(10,-0.4*mag2))/ln(10);//combine magnitudes
      end;
    end;


begin
  result:=false;//assume failure
  if ((head.naxis<>0) and (head.cd1_1<>0)) then
  begin
    counter_flux_measured:=0;

    {find middle of the image}
    {Fits range 1..width, if range 1,2,3,4  then middle is 2.5=(4+1)/2 }
    pixel_to_celestial(head,(head.width+1)/2,(head.height+1)/2,0 {wcs is sufficient},telescope_ra,telescope_dec); {RA,DEC position of the middle of the image. Works also for case head.crpix1,head.crpix2 are not in the middle}

    if select_star_database(stackmenu1.star_database1.text,15 {neutral})=false then exit; {sets file290 so do before fov selection}

    fov_org:= sqrt(sqr(head.width*head.cdelt1)+sqr(head.height*head.cdelt2))*pi/180; {field of view with 0% extra}

    m_limit:=head.magn_limit+1;//go one magnitude fainter


    //not longer used. Use now BP xxxxxxxxxxxxxxx since G magnitude is used to retrieve which about 0.5 magnitude fainter then mag limit. {BP~GP+0.5}


    linepos:=2;{Set pointer to the beginning. First two lines are comments}

//    if database_type>001 then //1476 or 290 files
//    begin
//      if  database_type=1476 then //.1476 files
//        fov:=min(fov_org,5.142857143*pi/180) //warning FOV should be less the database tiles dimensions, so <=5.142857143 degrees. Otherwise a tile beyond next tile could be selected
//      else
//      if  database_type=290 then //.290 files
//        fov:=min(fov_org,9.53*pi/180); //warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected


//      find_areas( telescope_ra,telescope_dec, fov,{var} area1,area2,area3,area4, frac1,frac2,frac3,frac4);{find up to four star database areas for the square image}

      {read 1th area}
//      if area1<>0 then {read 1th area}
//      begin
//        if open_database(telescope_dec,area1)=false then begin exit; end; {open database file or reset buffer}
//        while ((readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp)) and (mag2<=m_limit*10)) do plot_star;{add star}
//      end;

      {read 2th area}
//      if area2<>0 then {read 2th area}
//      begin
//        if open_database(telescope_dec,area2)=false then begin exit; end; {open database file or reset buffer}
//        while ((readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp)) and (mag2<=m_limit*10)) do plot_star;{add star}
//      end;

      {read 3th area}
      //      if area3<>0 then {read 3th area}
      //      begin
      //        if open_database(telescope_dec,area3)=false then begin exit; end; {open database file or reset buffer}
      //        while ((readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp)) and (mag2<=m_limit*10)) do plot_star;{add star}
      //      end;
      //      {read 4th area}
      //      if area4<>0 then {read 4th area}
      //      begin
      //        if open_database(telescope_dec,area4)=false then begin exit; end; {open database file or reset buffer}
      //        while ((readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp)) and (mag2<=m_limit*10)) do plot_star;{add star}
      //      end;

      //      close_star_database;

      //    end
      //    else
      //    if database_type=1 then {W08 database}
      //    begin {W08, 001 database}
      //      if wide_database<>name_database then
      //                              read_stars_wide_field;{load wide field stars array}
      //      count:=0;
      //      while  (count<length(wide_field_stars) div 3)  do {star 001 database read.}
      //      begin
      //        mag2:=wide_field_stars[count*3];{contains: mag1, ra1,dec1, mag2,ra2,dec2,mag3........}
      //        ra2:=wide_field_stars[count*3+1];
      //        dec2:=wide_field_stars[count*3+2];
      //        ang_sep(ra2,dec2,telescope_ra,telescope_dec, sep);{angular seperation}
      //        if ((sep<fov_org*0.5*0.9*(2/sqrt(pi))) and  (sep<pi/2)) then  {factor 2/sqrt(pi) is to adapt circle search field to surface square. Factor 0.9 is a fiddle factor for trees, house and dark corners. Factor <pi/2 is the limit for procedure equatorial_standard}
      //        begin
      //          plot_star;{add star}
      //        end;
      //        inc(count);
      //      end;
      //    end
      //    else
    begin //Database_type=0, Vizier online, Gaia

       if gaia_magn_limit+0.1<m_limit then sep:=999 //update required based on magnitude
       else
       ang_sep(telescope_ra,telescope_dec,gaia_ra,gaia_dec,sep);//update required based on position

       if ((sep>0.15*fov_org) or (online_database=nil)) then  //other sky area, update Gaia database online
       begin
         if read_stars_online(telescope_ra,telescope_dec,fov_org,m_limit {max_magnitude}) then
         begin
           get_database_passband(head.filter_name,passband);//report local or online database and the database passband
           convert_magnitudes(passband) //convert gaia magnitude to a new magnitude. If the type is already correct, no action will follow
         end;
       end;
       count:=0;

       while count<length(online_database[0]) do {read stars}
       begin
         ra2:=online_database[0,count];
         dec2:=online_database[1,count];
         mag2:=online_database[5,count]*10; // transformed magnitude
         if mag2=0 then
           mag2:=online_database[3,count]*10; // use BP magnitude
         if mag2=0 then
            mag2:=(online_database[2,count]+0.5)*10; //use G magnitude instead, {BP~GP+0.5}
         plot_star;{add star}
         inc(count);
       end;
     end;
     if count>0 then
       result:=true
     else
       memo2_message('Online database empthy!');
  end;{solved fits file}
end;{plot stars}


procedure plot_stars_used_for_solving(starlist1,starlist2: Tstar_list; hd: Theader;correctionX,correctionY: double); {plot image stars and database stars used for the solution}
var
  nrstars,i, starX, starY,size,flipped  : integer;
  flip_horizontal, flip_vertical        : boolean;
  xx,yy,x,y                             : double;
begin
  flip_vertical:=mainform1.flip_vertical1.Checked;
  flip_horizontal:=mainform1.flip_horizontal1.Checked;

  {do image stars}
  nrstars:=length(starlist2[0]);
  mainform1.image1.Canvas.Pen.Mode := pmCopy;
  mainform1.image1.Canvas.Pen.width := round(1+hd.height/mainform1.image1.height);{thickness lines}
  mainform1.image1.Canvas.brush.Style:=bsClear;
  mainform1.image1.Canvas.Pen.Color :=clred;

  for i:=0 to nrstars-1 do
  begin

    if flip_horizontal=true then starX:=round((hd.width-starlist2[0,i]))  else starX:=round(starlist2[0,i]);
    if flip_vertical=false  then starY:=round((hd.height-starlist2[1,i])) else starY:=round(starlist2[1,i]);
    size:=15;
    mainform1.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
 end;

  {do database stars}

  if hd.cd1_1*hd.cd2_2 - hd.cd1_2*hd.cd2_1>0 then {Flipped image. Either flipped vertical or horizontal but not both. Flipped both horizontal and vertical is equal to 180 degrees rotation and is not seen as flipped}
    flipped:=-1  //change rotation for flipped image
  else
    flipped:=+1;

  nrstars:=length(starlist1[0]);
  mainform1.image1.Canvas.Pen.Color := annotation_color;
  for i:=0 to nrstars-1 do
  begin
    xx:=(starlist1[0,i]-correctionX)/(hd.cdelt1*3600);{apply correction for database stars center and image center and convert arc seconds to pixels}
    yy:=(starlist1[1,i]-correctionY)/(hd.cdelt2*3600);
    rotate((flipped*hd.crota2)*pi/180,xx,yy,x,y);{rotate to screen orientation}

    if flip_horizontal=false then begin starX:=round(hd.crpix1-x); end else begin starX:=round(hd.crpix1+x); end;
    if flip_vertical=false   then begin starY:=round(hd.crpix2-y); end else begin starY:=round(hd.crpix2+y); end;

    size:=20;
    mainform1.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
  end;
end;


function find_object(var objname : string; var ra0,dec0,length0,width0,pa : double): boolean; {find object in database}
begin
  result:=false;
  if length(objname)>1 then {Object name length should be two or longer}
  begin
    objname:=uppercase(objname);
    load_deep;{Load the deepsky database once. If already loaded, no action}
    linepos:=2;{Set pointer to the beginning}
    while  read_deepsky('T' {full database search} ,0 {ra},0 {dec},1 {cos(telescope_dec)},2*pi{fov},{var} ra0,dec0,length0,width0,pa) {Deepsky database search} do
    begin
      if ((objname=uppercase(naam2)) or (objname=uppercase(naam3)) or (objname=uppercase(naam4))) then
      begin
        result:=true;
        if naam3='' then objname:=naam2 {Add one object name only}
        else
          objname:=naam2+'_'+naam3;{Add two object names}
        break; {Stop searching}
     end;
    end;{while loop}
  end;
end;

end.

