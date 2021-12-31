unit unit_annotation; {deep sky and star annotation & photometry calibation of the image}
{$mode delphi}
{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface
uses
   forms,Classes, SysUtils,strutils, math,graphics, Controls {for tcursor},astap_main,  unit_stars_wide_field;

procedure plot_deepsky;{plot the deep sky object on the image}
procedure load_deep;{load the deepsky database once. If loaded no action}
procedure load_hyperleda;{load the HyperLeda database once. If loaded no action}
procedure load_variable;{load variable stars. If loaded no action}
procedure plot_and_measure_stars(flux_calibration,plot_stars, report_lim_magn: boolean);{flux calibration,  annotate, report limiting magnitude}
procedure measure_distortion(plot: boolean; out stars_measured: integer);{measure or plot distortion}
procedure plot_artificial_stars(img: image_array);{plot stars as single pixel with a value as the mangitude. For super nova search}
procedure plot_stars_used_for_solving(correctionX,correctionY: double); {plot image stars and database stars used for the solution}
procedure read_deepsky(searchmode:char; telescope_ra,telescope_dec, cos_telescope_dec {cos(telescope_dec},fov : double; out ra2,dec2,length2,width2,pa : double);{deepsky database search}
procedure annotation_to_array(thestring : ansistring;transparant:boolean;colour,size, x,y {screen coord}: integer; var img: image_array);{string to image array as annotation, result is flicker free since the annotion is plotted as the rest of the image}
function find_object(var objname : string; var ra0,dec0,length0,width0,pa : double): boolean; {find object in database}
function calculate_undisturbed_image_scale : boolean;{calculate and correct the image scale as if the optical system is undisturbed. The distance between the stars in the center are measured and compared between detection and database. It is assumed that the center of the image is undisturbed optically }


var
  deepstring       : Tstrings;
  linepos          : integer;
  naam2,naam3,naam4: string;

var  {################# initialised variables #########################}
  flux_magn_offset       : double=0;{offset between star magnitude and flux. Will be calculated in stars are annotated}
  limiting_magnitude     : double=0;{magnitude where snr is 5}
  counter_flux_measured  : integer=0;{how many stars used for flux calibration}
  database_nr            : integer=0; {1 is deepsky, 2 is hyperleda, 3 is variable loaded}

implementation

uses
  unit_star_database, unit_stack, unit_star_align;

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

procedure annotation_to_array(thestring : ansistring;transparant:boolean;colour,size, x,y {screen coord}: integer; var img: image_array);{string to image array as annotation, result is flicker free since the annotion is plotted as the rest of the image}
var                                                                                       {Screen coordinates are used to have the font with the correct orientation}
 w,h,i,j,k,value,flipV, flipH,len,x2,y2: integer;
 ch : pansichar;
begin
  w:=Length(img[0]); {width}
  h:=Length(img[0,0]); {height}

  if mainwindow.Flip_horizontal1.Checked then {restore based on flipped conditions}
  begin
    x:=(w-1)-x;
    flipH:=-1;
  end
  else flipH:=1;

  if mainwindow.flip_vertical1.Checked then
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
        if (((transparant=false)) or (font_5x9[value,j div size ,i div size]<>0)) then img[0,x2,y2]:=font_5x9[value,j div size,i div size]*colour;{write the font to the array}
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
       database_nr:=1;{1 is deepsky, 2 is hyperleda, 3 is variable loaded}
       except;
         clear;
         beep;
         application.messagebox(pchar('Deep sky database not found. Download and unpack in program directory'),'',0);
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
       database_nr:=3;{1 is deepsky, 2 is hyperleda, 3 is variable loaded}
       except;
         clear;
         beep;
         application.messagebox(pchar('Variable star database not found!'),'',0);
       end;
    end;
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
       database_nr:=2;{1 is deepsky, 2 is hyperleda, 3 is variable loaded}
       except;
         clear;
         beep;
         application.messagebox(pchar('HyperLeda database not found. Download and unpack in program directory'),'',0);
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

procedure read_deepsky(searchmode:char; telescope_ra,telescope_dec, cos_telescope_dec {cos(telescope_dec},fov : double; out ra2,dec2,length2,width2,pa : double);{deepsky database search}
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
        linepos:=$FFFFFF;{mark as finished}
        exit;
      end;
    regel:=deepstring.strings[linepos]; {using regel,is faster then deepstring.strings[linepos]}
    inc(linepos);
    x:=1; z:=0; y:=0;

    P1 := Pointer(REGEL);
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

procedure rotate(rot,x,y :double;var  x2,y2:double);{rotate a vector point, angle seen from y-axis, counter clockwise}
var
  sin_rot, cos_rot :double;
begin
  sincos(rot, sin_rot, cos_rot);
  x2:=x * + sin_rot + y*cos_rot;{ROTATION MOON AROUND CENTER OF PLANET}
  y2:=x * - cos_rot + y*sin_rot;{SEE PRISMA WIS VADEMECUM BLZ 68}
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


procedure plot_deepsky;{plot the deep sky object on the image}
type
  textarea = record
     x1,y1,x2,y2 : integer;
  end;
var
  {fitsX,fitsY,}dra,ddec,delta,gamma, telescope_ra,telescope_dec,cos_telescope_dec,fov,ra2,dec2,length1,width1,pa,len,flipped,
  gx_orientation, delta_ra,det,SIN_dec_ref,COS_dec_ref,SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,hh,u0,v0 : double;
  name: string;
  flip_horizontal, flip_vertical: boolean;
  text_dimensions  : array of textarea;
  i,text_counter,th,tw,x1,y1,x2,y2,hf,x,y,fontsi : integer;
  overlap,sip  :boolean;
  Save_Cursor:TCursor;

begin
  if ((fits_file) and (head.cd1_1<>0)) then
  begin
     Save_Cursor := Screen.Cursor;
     Screen.Cursor := crHourglass;    { Show hourglass cursor }

    flip_vertical:=mainwindow.flip_vertical1.Checked;
    flip_horizontal:=mainwindow.flip_horizontal1.Checked;


    {6. Passage (x,y) -> (RA,DEC) to find head.ra0,head.dec0 for middle of the image. See http://alain.klotz.free.fr/audela/libtt/astm1-fr.htm}
    dRa :=(head.cd1_1*((head.width/2)-head.crpix1)+head.cd1_2*((head.height/2)-head.crpix2))*pi/180; {also valid for case head.crpix1,head.crpix2 is not in the middle}
    dDec:=(head.cd2_1*((head.width/2)-head.crpix1)+head.cd2_2*((head.height/2)-head.crpix2))*pi/180;
    delta:=cos(head.dec0)-dDec*sin(head.dec0);
    gamma:=sqrt(dRa*dRa+delta*delta);
    telescope_ra:=head.ra0+arctan(Dra/delta);
    telescope_dec:=arctan((sin(head.dec0)+dDec*cos(head.dec0))/gamma);

    cos_telescope_dec:=cos(telescope_dec);
    fov:=1.5*sqrt(sqr(0.5*head.width*head.cdelt1)+sqr(0.5*head.height*head.cdelt2))*pi/180; {field of view with 50% extra}
    linepos:=2;{Set pointer to the beginning. First two lines are comments}
    if head.cdelt1*head.cdelt2>0 then flipped:=-1 {n-s or e-w flipped} else flipped:=1;

    {$ifdef mswindows}
     mainwindow.image1.Canvas.Font.Name :='default';
    {$endif}
    {$ifdef linux}
    mainwindow.image1.Canvas.Font.Name :='DejaVu Sans';
    {$endif}
    {$ifdef darwin} {MacOS}
    mainwindow.image1.Canvas.Font.Name :='Helvetica';
    {$endif}


    mainwindow.image1.canvas.pen.color:=annotation_color;
    mainwindow.image1.Canvas.brush.Style:=bsClear;
    mainwindow.image1.Canvas.font.color:=annotation_color;

    text_counter:=0;
    setlength(text_dimensions,200);

    sincos(head.dec0,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}

    repeat
      read_deepsky('S',telescope_ra,telescope_dec, cos_telescope_dec {cos(telescope_dec},fov,{var} ra2,dec2,length1,width1,pa);{deepsky database search}

      {5. Conversion (RA,DEC) -> (x,y). See http://alain.klotz.free.fr/audela/libtt/astm1-fr.htm}
      sincos(dec2,SIN_dec_new,COS_dec_new);{sincos is faster then separate sin and cos functions}
      delta_ra:=ra2-head.ra0;
      sincos(delta_ra,SIN_delta_ra,COS_delta_ra);
      HH := SIN_dec_new*sin_dec_ref + COS_dec_new*COS_dec_ref*COS_delta_ra;
      dRA := (COS_dec_new*SIN_delta_ra / HH)*180/pi;
      dDEC:= ((SIN_dec_new*COS_dec_ref - COS_dec_new*SIN_dec_ref*COS_delta_ra ) / HH)*180/pi;
      det:=head.cd2_2*head.cd1_1 - head.cd1_2*head.cd2_1;

      u0:= - (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
      v0:= + (head.cd1_1*dDEC - head.cd2_1*dRA) / det;

      if sip then {apply SIP correction}
      begin
         x:=round(head.crpix1 + u0 + ap_0_0 + ap_0_1*v0+ ap_0_2*v0*v0+ ap_0_3*v0*v0*v0 +ap_1_0*u0 + ap_1_1*u0*v0+  ap_1_2*u0*v0*v0+ ap_2_0*u0*u0 + ap_2_1*u0*u0*v0+  ap_3_0*u0*u0*u0)-1; {3th order SIP correction, fits count from 1, image from zero therefore subtract 1}
         y:=round(head.crpix2 + v0 + bp_0_0 + bp_0_1*v0+ bp_0_2*v0*v0+ bp_0_3*v0*v0*v0 +bp_1_0*u0 + bp_1_1*u0*v0+  bp_1_2*u0*v0*v0+ bp_2_0*u0*u0 + bp_2_1*u0*u0*v0+  bp_3_0*u0*u0*u0)-1; {3th order SIP correction}
      end
      else
      begin
        x:=round(head.crpix1 + u0)-1; {in image array range 0..width-1}
        y:=round(head.crpix2 + v0)-1;
      end;

      if ((x>-0.25*head.width) and (x<=1.25*head.width) and (y>-0.25*head.height) and (y<=1.25*head.height)) then {within image1 with some overlap}
      begin
        gx_orientation:=pa*flipped+head.crota2;
        if flip_horizontal then begin x:=(head.width-1)-x; gx_orientation:=-gx_orientation; end;
        if flip_vertical then gx_orientation:=-gx_orientation else y:=(head.height-1)-y;
        len:=length1/(abs(head.cdelt2)*60*10*2); {Length in pixels}

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

          mainwindow.image1.Canvas.font.size:=round(min(20,max(8,len /2)));

          if copy(naam2,1,1)='0' then  mainwindow.image1.Canvas.font.color:=cllime;{AAVSO reference star}

          {get text dimensions}
          th:=mainwindow.image1.Canvas.textheight(name);
          tw:=mainwindow.image1.Canvas.textwidth(name);
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
           mainwindow.image1.Canvas.moveto(x,round(y+th/4));
           mainwindow.image1.Canvas.lineto(x,y1);
         end;
         mainwindow.image1.Canvas.textout(x1,y1,name);
         inc(text_counter);
         if text_counter>=length(text_dimensions) then setlength(text_dimensions,text_counter+200);{increase size dynamic array}
       end;{centre object visible}

       {plot deepsky object}
       if width1=0 then begin width1:=length1;pa:=999;end;
       mainwindow.image1.Canvas.Pen.width :=min(4,max(1,round(len/70)));

       {len is already calculated earlier for the font size}
       if len<=2 then {too small to plot an elipse or circle, plot just four dots}
       begin
         mainwindow.image1.canvas.pixels[x-2,y+2]:=annotation_color;
         mainwindow.image1.canvas.pixels[x+2,y+2]:=annotation_color;
         mainwindow.image1.canvas.pixels[x-2,y-2]:=annotation_color;
         mainwindow.image1.canvas.pixels[x+2,y-2]:=annotation_color;
       end
       else
       begin
         if PA<>999 then
           plot_glx(mainwindow.image1.canvas,x,y,len,width1/length1,gx_orientation*pi/180) {draw oval or galaxy}
         else
         mainwindow.image1.canvas.ellipse(round(x-len),round(y-len),round(x+1+len),round(y+1+len));{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
       end;
     end;
    until linepos>=$FFFFFF;{end of database}

    text_dimensions:=nil;{remove used memory}

    Screen.Cursor:=Save_Cursor;
  end;

end;{plot deep_sky}


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


procedure get_best_mean(list: array of double; leng : integer; out mean,cv : double);{Remove outliers from polulation using MAD. }
var  {idea from https://eurekastatistics.com/using-the-median-absolute-deviation-to-find-outliers/}
  i,count         : integer;
  median, mad     : double;

begin
 mad_median(list,leng,mad,median);{{calculate mad and median without modifying the data}
 if median>0 then cv:=mad*1.4826/median else cv:=0;  {Coefficient of variation,  defined as the ratio of the standard deviation to the mean}

 count:=0;
 mean:=0;

 for i:=0 to leng-1 do
   if abs(list[i]-median)<1.50*1.4826*mad then {offset less the 1.5*sigma.}
   begin
     mean:=mean+list[i];{Calculate mean. This gives a little less noise then calculating median again. Note weighted mean gives poorer result and is not applied.}
     inc(count);
   end;
 if count>0 then  mean:=mean/count;  {mean without using outliers}
end;


procedure plot_and_measure_stars(flux_calibration,plot_stars, report_lim_magn: boolean);{flux calibration,  annotate, report limiting magnitude}
var
  fitsX_middle, fitsY_middle, dra,ddec,delta,gamma, telescope_ra,telescope_dec,fov,ra2,dec2,
  mag2,Bp_Rp, hfd1,star_fwhm,snr, flux, xc,yc,magn, delta_ra,delta_dec,sep,det,SIN_dec_ref,COS_dec_ref,cv,fov_org,
  SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,hh,frac1,frac2,frac3,frac4,u0,v0,x,y,x2,y2,flux_snr_7,apert,xx,yy : double;
  star_total_counter,len, max_nr_stars, area1,area2,area3,area4,nrstars_required2,count                          : integer;
  flip_horizontal, flip_vertical        : boolean;
  mag_offset_array,hfd_x_sd             : array of double;
  Save_Cursor                           : TCursor;
  mess                                  : string;

    procedure plot_star;
    begin
      if ((flux_calibration) and ( bp_rp>12) and (bp_rp<>999){mono colour database})then exit;{too red star for flux calibration. Bp-Rp>1.2 for about 30% of the stars}

     {5. Conversion (RA,DEC) -> (x,y)}
      sincos(dec2,SIN_dec_new,COS_dec_new);{sincos is faster then separate sin and cos functions}
      delta_ra:=ra2-head.ra0;
      sincos(delta_ra,SIN_delta_ra,COS_delta_ra);
      HH := SIN_dec_new*sin_dec_ref + COS_dec_new*COS_dec_ref*COS_delta_ra;
      dRA := (COS_dec_new*SIN_delta_ra / HH)*180/pi;
      dDEC:= ((SIN_dec_new*COS_dec_ref - COS_dec_new*SIN_dec_ref*COS_delta_ra ) / HH)*180/pi;
      det:=head.cd2_2*head.cd1_1 - head.cd1_2*head.cd2_1;

      u0:= - (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
      v0:= + (head.cd1_1*dDEC - head.cd2_1*dRA) / det;

      if sip then {apply SIP correction, sky to pixel}
      begin
         x:=(head.crpix1 + u0 + ap_0_0 + ap_0_1*v0+ ap_0_2*v0*v0+ ap_0_3*v0*v0*v0 +ap_1_0*u0 + ap_1_1*u0*v0+  ap_1_2*u0*v0*v0+ ap_2_0*u0*u0 + ap_2_1*u0*u0*v0+  ap_3_0*u0*u0*u0)-1; {3th order SIP correction, fits count from 1, image from zero therefore subtract 1}
         y:=(head.crpix2 + v0 + bp_0_0 + bp_0_1*v0+ bp_0_2*v0*v0+ bp_0_3*v0*v0*v0 +bp_1_0*u0 + bp_1_1*u0*v0+  bp_1_2*u0*v0*v0+ bp_2_0*u0*u0 + bp_2_1*u0*u0*v0+  bp_3_0*u0*u0*u0)-1; {3th order SIP correction}
      end
      else
      begin
        x:=(head.crpix1 + u0)-1; {in image array range 0..width-1}
        y:=(head.crpix2 + v0)-1;
      end;


      if ((x>-50) and (x<=head.width+50) and (y>-50) and (y<=head.height+50)) then {within image1 with some overlap}
      begin
        inc(star_total_counter);

        if flip_horizontal then x2:=(head.width-1)-x else x2:=x;
        if flip_vertical   then y2:=y            else y2:=(head.height-1)-y;

        if plot_stars then
        begin {annotate}
          if Bp_Rp<>999 then {colour version}
          begin
            mainwindow.image1.Canvas.textout(round(x2),round(y2),inttostr(round(mag2))+':'+inttostr(round(Bp_Rp)) {   +'<-'+inttostr(area290) });

            mainwindow.image1.canvas.pen.color:=Gaia_star_color(round(Bp_Rp));{color circel}
          end
          else
            mainwindow.image1.Canvas.textout(round(x2),round(y2),inttostr(round(mag2)) );

          len:=round((200-mag2)/5.02);
          mainwindow.image1.canvas.ellipse(round(x2-len),round(y2-len),round(x2+1+len),round(y2+1+len));{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
        end;

        if flux_calibration then
        begin
          HFD(img_loaded,round(x),round(y), annulus_radius{14,annulus radius},flux_aperture, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
          if ((hfd1<15) and (hfd1>=0.8) {two pixels minimum}) then
          if snr>30 then {star detected in img_loaded. 30 is found emperical}
          begin
            if ((flux_calibration){calibrate flux} and
                (img_loaded[0,round(xc),round(yc)]<head.datamax_org-1) and
                (img_loaded[0,round(xc-1),round(yc)]<head.datamax_org-1) and
                (img_loaded[0,round(xc+1),round(yc)]<head.datamax_org-1) and
                (img_loaded[0,round(xc),round(yc-1)]<head.datamax_org-1) and
                (img_loaded[0,round(xc),round(yc+1)]<head.datamax_org-1) and

                (img_loaded[0,round(xc-1),round(yc-1)]<head.datamax_org-1) and
                (img_loaded[0,round(xc-1),round(yc+1)]<head.datamax_org-1) and
                (img_loaded[0,round(xc+1),round(yc-1)]<head.datamax_org-1) and
                (img_loaded[0,round(xc+1),round(yc+1)]<head.datamax_org-1)  ) then {not saturated}
            begin
              magn:=(-ln(flux)*2.511886432/LN(10));
              if counter_flux_measured>=length(mag_offset_array) then
              begin
               SetLength(mag_offset_array,counter_flux_measured+500);{increase length array}
               if report_lim_magn then  SetLength(hfd_x_sd,counter_flux_measured+500);{increase length array}
              end;
              mag_offset_array[counter_flux_measured]:=mag2/10-magn;

              if report_lim_magn then
              begin
                hfd_x_sd[counter_flux_measured]:=hfd1*sd_bg;{calculate hfd*SD. sd_bg  is a global variable from procedure hfd. The minimum diameter for star detection is 4}
              end;

//              memo2_message(#9+floattostr4(snr)+#9+floattostr4(hfd1)+#9+floattostr4(R_aperture)+#9+floattostr4(sd_bg) );

              inc(counter_flux_measured); {increase counter of number of stars analysed}
            end;

          end; {snr>30}
        end;{flux calibration}
      end;
    end;
begin
  if ((fits_file) and (head.cd1_1<>0)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    flip_vertical:=mainwindow.flip_vertical1.Checked;
    flip_horizontal:=mainwindow.flip_horizontal1.Checked;

//    sip:=((ap_order>=2) and (mainwindow.Polynomial1.itemindex=1));{use sip corrections?}  Already set


    bp_rp:=999;{not defined in mono versions of the database}

    fitsX_middle:=(head.width+1)/2;{range 1..width, if range 1,2,3,4  then middle is 2.5=(4+1)/2 }
    fitsY_middle:=(head.height+1)/2;

    dRa :=(head.cd1_1*(fitsx_middle-head.crpix1)+head.cd1_2*(fitsy_middle-head.crpix2))*pi/180;
    dDec:=(head.cd2_1*(fitsx_middle-head.crpix1)+head.cd2_2*(fitsy_middle-head.crpix2))*pi/180;
    delta:=cos(head.dec0)-dDec*sin(head.dec0);
    gamma:=sqrt(dRa*dRa+delta*delta);
    telescope_ra:=head.ra0+arctan(Dra/delta);
    telescope_dec:=arctan((sin(head.dec0)+dDec*cos(head.dec0))/gamma);

    mainwindow.image1.Canvas.Pen.width :=1; // round(1+head.height/mainwindow.image1.height);{thickness lines}
    mainwindow.image1.canvas.pen.color:=$00B0FF ;{orange}


    {$ifdef mswindows}
    mainwindow.image1.Canvas.Font.Name :='default';
    {$endif}
    {$ifdef linux}
    mainwindow.image1.Canvas.Font.Name :='DejaVu Sans';
    {$endif}
    {$ifdef darwin} {MacOS}
    mainwindow.image1.Canvas.Font.Name :='Helvetica';
    {$endif}

    mainwindow.image1.Canvas.font.size:=8; //round(14*head.height/mainwindow.image1.height);{adapt font to image dimensions}
    mainwindow.image1.Canvas.brush.Style:=bsClear;

    mainwindow.image1.Canvas.font.color:=$00B0FF ;{orange}


    star_total_counter:=0;{total counter}
    counter_flux_measured:=0;


    max_nr_stars:=round(head.width*head.height*(1216/(2328*1760))); {Check 1216 stars in a circle resulting in about 1000 stars in a rectangle for image 2328 x1760 pixels}

    if flux_calibration then
    begin
       max_nr_stars:=round(max_nr_stars*0.6); {limit to the brightest stars. Fainter stars have more noise}
       setlength(mag_offset_array,max_nr_stars);
       if report_lim_magn then setlength(hfd_x_sd,max_nr_stars);
    end;

    {sets file290 so do before fov selection}
    if select_star_database(stackmenu1.star_database1.text,15 {neutral})=false then
    begin
      application.messagebox(pchar('No star database found!'+#13+'Download the h18 (or h17 or v17) and extract the files to the program directory'), pchar('No star database!'),0);
      exit;
    end;

    fov_org:= sqrt(sqr(head.width*head.cdelt1)+sqr(head.height*head.cdelt2))*pi/180; {field of view circle covering all corners with 0% extra}

    sincos(head.dec0,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}

    if database_type<>001 then {1476 or 290 files}
    begin
      if database_type=1476 then {.1476 files}
      fov:=min(fov_org,5.142857143*pi/180) {warning FOV should be less the database tiles dimensions, so <=5.142857143 degrees. Otherwise a tile beyond next tile could be selected}
      else {.290 files}
      fov:=min(fov_org,9.53*pi/180); {warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected}


      if fov_org>fov then max_nr_stars:=round(max_nr_stars*fov/fov_org);{reduce number of stars for very large FOV}

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
        while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp))
        and (bp_rp>12) ) do plot_star;{add star}
      end;

      close_star_database;
    end
    else
    begin {001 database}
      if wide_database<>name_database then
                              read_stars_wide_field;{load wide field stars array}
      count:=0;
      cos_telescope_dec:=cos(telescope_dec);
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

    if flux_calibration then {flux calibration}
    begin
      if counter_flux_measured>=3 then {at least three stars}
      begin
        get_best_mean(mag_offset_array,counter_flux_measured {length},flux_magn_offset,cv );

        if flux_aperture=99 then

          memo2_message('Photometry calibration for EXTENDED OBJECTS successful. '+inttostr(counter_flux_measured)+
                        ' Gaia stars used for flux calibration.  Flux aperture diameter: measured star diameter.'+
                        ' Coefficient of variation: '+floattostrF(cv*100,ffgeneral,2,1)+
                        '%. Annulus inner diameter: '+inttostr(1+(annulus_radius)*2){background is measured 2 pixels outside rs}+' pixels. Stars with pixel values of '+inttostr(round(head.datamax_org))+' or higher are ignored.')

        else
          memo2_message('Photometry calibration for POINT SOURCES successful. '+inttostr(counter_flux_measured)+
                        ' Gaia stars used for flux calibration.  Flux aperture diameter: '+floattostrf(flux_aperture*2, ffgeneral, 2,2)+' pixels.'+
                        ' Coefficient of variation: '+floattostrF(cv*100,ffgeneral,2,1)+
                        '%. Annulus inner diameter: '+inttostr(1+(annulus_radius)*2){background is measured 2 pixels outside rs}+' pixels. Stars with pixel values of '+inttostr(round(head.datamax_org))+' or higher are ignored.');

        if report_lim_magn then
        begin
         {snr formula      snr:=flux/sqrt(flux + r*r*pi* sd^2).
          for faint stars  snr ≈flux/sqrt( 0 + r*r*pi* sd^2)
                           flux≈snr*sqrt( 0 + r*r*pi* sd^2)
                           flux≈snr*r*sqrt(pi)*sd
                           flux≈snr*(hfd*0.8)*sqrt(pi)*sd   assuming star diameter is 2*hfd, so radius is hfd
                           flux≈snr*sqrt(pi)*sd*hfd*0.8  }
          flux_snr_7:=7*sqrt(pi)*Smedian(hfd_x_sd,counter_flux_measured {length}){*0.8{fiddle factor} ;{Assuming minimum SNR is 10 and the aperture is reduced to about hfd for the faintest stars.}
          apert:=strtofloat2(stackmenu1.flux_aperture1.text);{aperture diamater expressed in HFD's. If aperture diameter is HFD, half of the star flux is lost}
          if apert=0 then apert:=10; {aperture is zero if is set at max text. Set very high}

          //encircled flux =1-EXP(-0.5*(radial_distance/sigma)^2)
          //encircled flux =1-EXP(-0.5*((apert*HFD/2)/(HFD/2.3548))^2)
          //encircled flux =1-EXP(-0.5*(apert*2.3548/2))^2)
          flux_snr_7:=flux_snr_7*(1-EXP(-0.5*sqr(apert*2.3548/2 {sigma}))); {Correction for reduced aparture.}
          magn_limit:=flux_magn_offset-ln(flux_snr_7)*2.511886432/ln(10); {global variable}
          mess:='Limiting magnitude is about '+ floattostrF(magn_limit,ffgeneral,3,1)+'   (7σ, aperture ⌀'+stackmenu1.flux_aperture1.text+')';

          memo2_message(mess);
          mainwindow.caption:='Photometry calibration successful. '+mess;
        end;


      end
      else
      begin
        flux_magn_offset:=0;
        mess:='Calibration failure!';
        mainwindow.caption:=mess;
        memo2_message(mess);
      end;

      mag_offset_array:=nil;
      hfd_x_sd:=nil;
    end;

    Screen.Cursor:= Save_Cursor;
  end;{fits file}
end;{plot stars}


function calculate_undisturbed_image_scale : boolean;{calculate and correct the image scale as if the optical system is undisturbed. The distance between the stars in the center are measured and compared between detection and database. It is assumed that the center of the image is undisturbed optically }
var
  i,j,count,stars_measured,count2       : integer;
  x1,y1,x2,y2,xc1,yc1,xc2,yc2,factor,r1,r2,d1,d2,range   : double;
  factors      : array of double;

begin
  measure_distortion(false {plot and no sip correction},stars_measured);{measure stars against the database}

  setlength(factors,stars_measured);

  range:=0.05; {start with 0.05+0.05 is 0.1 range}

  if stars_measured>0 then
  repeat
    count:=0;
    range:=range+0.05; {increase range of center for finding stars}
    begin
      for i:=0 to stars_measured-1 do
      begin
        x1:=distortion_data[0,i]-head.crpix1;{database, x from center}
        y1:=distortion_data[1,i]-head.crpix2;
        r1:=sqr(x1)+sqr(y1);{distance from centre image}

        if  r1<sqr(range{0.1}*head.height) then {short distance 10% of image scale, distortion low}
        begin
          count2:=0;
          for j:=0 to stars_measured-1 do {second loop}
          if ((i<>j) and (count2<6)) then {compare against a few other stars in center}
          begin

            x2:=distortion_data[0,j]-head.crpix1;{database, x from center}
            y2:=distortion_data[1,j]-head.crpix2;
            r2:=sqr(x2)+sqr(y2);{distance from centre image}

            if  r2<sqr(range{0.1}*head.height) then {short distance 10% of image scale, distortion low}
            begin
              xc1:=distortion_data[2,i]-head.crpix1;{database, x from center}
              yc1:=distortion_data[3,i]-head.crpix2;
              xc2:=distortion_data[2,j]-head.crpix1;{database, x from center}
              yc2:=distortion_data[3,j]-head.crpix2;

              d1:=sqr(x1-x2)+sqr(y1-y2);
              if d1>sqr(0.5*range{0.1}*head.height) then {some distance}
              begin
                d2:=sqr(xc1-xc2)+sqr(yc1-yc2);
                factors[count]:=sqrt(d1/d2) ; //Ratio between close distance stars of database and image stars for center of the image. It is assumed that the center of the image is undisturbed optically
                inc(count,1);
                inc(count2,1);
                if count>length(factors) then
                          setlength(factors,count+stars_measured);
              end;
            end;
          end;

        end;
      end;
      factor:=smedian(factors,count);{filter out outliers using median}
    end;
  until ((count>50 {about 50/6 stars}) or (range>=0.3));
  if count>50  then
  begin
    head.cd1_1:=head.cd1_1*factor;
    head.cd1_2:=head.cd1_2*factor;
    head.cd2_1:=head.cd2_1*factor;
    head.cd2_2:=head.cd2_2*factor;
    head.cdelt1:=head.cdelt1*factor;
    head.cdelt2:=head.cdelt2*factor;

    update_float  ('CD1_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_1);
    update_float  ('CD1_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd1_2);
    update_float  ('CD2_1   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_1);
    update_float  ('CD2_2   =',' / CD matrix to convert (x,y) to (Ra, Dec)        ' ,head.cd2_2);
    update_float  ('CDELT1  =',' / X pixel size (deg)                             ' ,head.cdelt1);
    update_float  ('CDELT2  =',' / Y pixel size (deg)                             ' ,head.cdelt2);

    if factor<1 then memo2_message('Assuming barrel distortion.') else memo2_message('Assuming pincushion distortion.');
    memo2_message('Measured the undisturbed image scale in center and corrected image scale with factor '+floattostr6(factor)+'. Used '+inttostr(round(range*100))+'% of image');
    result:=true;
  end
  else
  begin
    memo2_message('Failed to measure undisturbed image scale');
    factor:=1;
    result:=false;
  end;
  factors:=nil;{release memory}
end;

procedure measure_distortion(plot: boolean; out stars_measured : integer);{measure or plot distortion}
var
  fitsX_middle, fitsY_middle, dra,ddec,delta,gamma, telescope_ra,telescope_dec,fov,fov_org,ra2,dec2,
  mag2,Bp_Rp, hfd1,star_fwhm,snr, flux, xc,yc,magn, delta_ra,det,SIN_dec_ref,COS_dec_ref,
  SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,hh,frac1,frac2,frac3,frac4,u0,v0,snr_min,x,y,x2,y2,astrometric_error,sep   : double;
  star_total_counter,len, max_nr_stars, area1,area2,area3,area4,nrstars_required2,i,sub_counter,scale,count    : integer;
  flip_horizontal, flip_vertical,sip   : boolean;
  error_array                          : array of double;
  Save_Cursor                          : TCursor;

    procedure plot_star;
    begin

     {5. Conversion (RA,DEC) -> (x,y)}
      sincos(dec2,SIN_dec_new,COS_dec_new);{sincos is faster then separate sin and cos functions}
      delta_ra:=ra2-head.ra0;
      sincos(delta_ra,SIN_delta_ra,COS_delta_ra);
      HH := SIN_dec_new*sin_dec_ref + COS_dec_new*COS_dec_ref*COS_delta_ra;
      dRA := (COS_dec_new*SIN_delta_ra / HH)*180/pi;
      dDEC:= ((SIN_dec_new*COS_dec_ref - COS_dec_new*SIN_dec_ref*COS_delta_ra ) / HH)*180/pi;
      det:=head.cd2_2*head.cd1_1 - head.cd1_2*head.cd2_1;

      u0:= - (head.cd1_2*dDEC - head.cd2_2*dRA) / det;
      v0:= + (head.cd1_1*dDEC - head.cd2_1*dRA) / det;

      if ((plot) and (sip)) then {apply SIP correction, sky to pixel. Do not apply correction for measurement if plotting is false !!!!}
      begin
        x:=(head.crpix1 + u0 + ap_0_0 + ap_0_1*v0+ ap_0_2*v0*v0+ ap_0_3*v0*v0*v0 +ap_1_0*u0 + ap_1_1*u0*v0+  ap_1_2*u0*v0*v0+ ap_2_0*u0*u0 + ap_2_1*u0*u0*v0+  ap_3_0*u0*u0*u0)-1; {3th order SIP correction, fits count from 1, image from zero therefore subtract 1}
        y:=(head.crpix2 + v0 + bp_0_0 + bp_0_1*v0+ bp_0_2*v0*v0+ bp_0_3*v0*v0*v0 +bp_1_0*u0 + bp_1_1*u0*v0+  bp_1_2*u0*v0*v0+ bp_2_0*u0*u0 + bp_2_1*u0*u0*v0+  bp_3_0*u0*u0*u0)-1; {3th order SIP correction}
      end
      else
      begin
        x:=(head.crpix1 + u0)-1; {in image array range 0..width-1}
        y:=(head.crpix2 + v0)-1;
      end;

      if ((x>-50) and (x<=head.width+50) and (y>-50) and (y<=head.height+50)) then {within image1 with some overlap}
      begin
        inc(star_total_counter);

        if flip_horizontal then x2:=(head.width-1)-x else x2:=x;
        if flip_vertical   then y2:=y            else y2:=(head.height-1)-y;

        HFD(img_loaded,round(x),round(y), 14 {annulus_radius},99 {flux_aperture}, hfd1,star_fwhm,snr,flux,xc,yc);{star HFD and FWHM}
        if ((hfd1<15) and (hfd1>=0.8) {two pixels minimum} and (snr>10)) then {star detected in img_loaded}
        begin
          if plot then {show distortion}
          begin
            mainwindow.image1.Canvas.Pen.width :=3;
            mainwindow.image1.Canvas.MoveTo(round(x2), round(y2));
            mainwindow.image1.Canvas.LineTo(round(x2+(x-xc)*50),round(y2-(y-yc)*50 ));
            mainwindow.image1.Canvas.Pen.width :=1;

            {for median errror}
            if  ( (x>0.25*head.height) and  (x< 0.75*head.height) and (y> 0.25*head.height) and  (y< 0.75*head.height) and (sub_counter<length(error_array))) then
            begin
              error_array[sub_counter]:=sqrt(sqr(X-xc)+sqr(Y-yc));{add errors to array}
              inc(sub_counter);
            end;
          end {show distortion}
          else
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
  if ((fits_file) and (head.cd1_1<>0)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    flip_vertical:=mainwindow.flip_vertical1.Checked;
    flip_horizontal:=mainwindow.flip_horizontal1.Checked;

    bp_rp:=999;{not defined in mono versions of the database}

    fitsX_middle:=(head.width+1)/2;{range 1..width, if range 1,2,3,4  then middle is 2.5=(4+1)/2 }
    fitsY_middle:=(head.height+1)/2;

    dRa :=(head.cd1_1*(fitsx_middle-head.crpix1)+head.cd1_2*(fitsy_middle-head.crpix2))*pi/180;
    dDec:=(head.cd2_1*(fitsx_middle-head.crpix1)+head.cd2_2*(fitsy_middle-head.crpix2))*pi/180;
    delta:=cos(head.dec0)-dDec*sin(head.dec0);
    gamma:=sqrt(dRa*dRa+delta*delta);
    telescope_ra:=head.ra0+arctan(Dra/delta);
    telescope_dec:=arctan((sin(head.dec0)+dDec*cos(head.dec0))/gamma);

    mainwindow.image1.Canvas.Pen.width :=1; // round(1+head.height/mainwindow.image1.height);{thickness lines}
    if sip=false then mainwindow.image1.canvas.pen.color:=$00B0FF {orange}
                 else mainwindow.image1.canvas.pen.color:=$00FF00; {green}

    star_total_counter:=0;{total counter}
    sub_counter:=0;

    max_nr_stars:=round(head.width*head.height*(1216/(2328*1760))); {Check 1216 stars in a circle resulting in about 1000 stars in a rectangle for image 2328 x1760 pixels}
    setlength(error_array,max_nr_stars);

    {sets file290 so do before fov selection}
    if select_star_database(stackmenu1.star_database1.text,15 {neutral})=false then
    begin
      application.messagebox(pchar('No star database found!'+#13+'Download the h18 (or h17 or v17) and extract the files to the program directory'), pchar('No star database!'),0);
      exit;
    end;

    if plot=false then setlength(distortion_data,4,max_nr_stars);
    stars_measured:=0;{star number}

    fov_org:= sqrt(sqr(head.width*head.cdelt1)+sqr(head.height*head.cdelt2))*pi/180; {field of view circle covering all corners with 0% extra}


    sincos(head.dec0,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}

    if database_type<>001 then {1476 or 290 files}
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
        while ((star_total_counter<nrstars_required2) and (readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp))
        and (bp_rp>12) ) do plot_star;{add star}
      end;

      close_star_database;
    end
    else
    begin {001 database}
      if wide_database<>name_database then
                              read_stars_wide_field;{load wide field stars array}
      count:=0;
      cos_telescope_dec:=cos(telescope_dec);
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
     mainwindow.image1.Canvas.Font.Name :='default';
    {$endif}
    {$ifdef linux}
    mainwindow.image1.Canvas.Font.Name :='DejaVu Sans';
    {$endif}
    {$ifdef darwin} {MacOS}
    mainwindow.image1.Canvas.Font.Name :='Helvetica';
    {$endif}

    if plot then
    begin
      astrometric_error:=smedian(error_array,sub_counter);
      memo2_message('The center median astrometric error is '+floattostr4(astrometric_error*head.cdelt2*3600)+'" or ' +floattostr4(astrometric_error)+' pixel using '+inttostr(sub_counter)+ ' stars.');


      mainwindow.image1.canvas.pen.color:=annotation_color;
      mainwindow.image1.Canvas.brush.Style:=bsClear;
      mainwindow.image1.Canvas.font.color:=annotation_color;
      mainwindow.image1.Canvas.font.size:=8;

      mainwindow.image1.Canvas.Pen.width :=3;

      {scale in pixels}
      mainwindow.image1.Canvas.MoveTo(20, head.height-30);
      mainwindow.image1.Canvas.LineTo(20+50*3,head.height-30);
      for i:=0 to 3 do
      begin
        mainwindow.image1.Canvas.MoveTo(20+50*i,head.height-25);
        mainwindow.image1.Canvas.LineTo(20+50*i,head.height-35);
        mainwindow.image1.Canvas.textout(17+50*i,head.height-25,inttostr(i));
      end;
      mainwindow.image1.Canvas.textout(20,head.height-60,'Scale in pixels');


      {scale in arc seconds}
      scale:=round(50/(head.cdelt2*3600));
      mainwindow.image1.Canvas.MoveTo(220, head.height-30);
      mainwindow.image1.Canvas.LineTo(220+scale*3,head.height-30);


      for i:=0 to 3 do
      begin
        mainwindow.image1.Canvas.MoveTo(220+scale*i,head.height-25);
        mainwindow.image1.Canvas.LineTo(220+scale*i,head.height-35);
        mainwindow.image1.Canvas.textout(217+scale*i,head.height-25,inttostr(i)+'"');
      end;
      mainwindow.image1.Canvas.textout(220,head.height-60,'Scale in arcsecs');

      mainwindow.image1.Canvas.font.size:=12;

      if sip then
      begin
        mainwindow.image1.Canvas.textout(700,head.height-25,'SIP corrections are applied. Median error for 50% of image '+floattostr4(astrometric_error*head.cdelt2*3600)+'"');
      end
      else
      mainwindow.image1.Canvas.textout(350,head.height-25,'Median error for 50% of image '+floattostr4(astrometric_error*head.cdelt2*3600)+'"');


      error_array:=nil;
    end;


    Screen.Cursor:= Save_Cursor;
  end;{fits file}
end;{measure distortion}


procedure plot_artificial_stars(img: image_array);{plot stars as single pixel with a value as the magnitude. For super nova and minor planet search}
var
  fitsX,fitsY, fitsX_middle, fitsY_middle, dra,ddec,delta,gamma, telescope_ra,telescope_dec,fov,fov_org,ra2,dec2,
  mag2,Bp_Rp, delta_ra,det,SIN_dec_ref,COS_dec_ref,
  SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,hh,frac1,frac2,frac3,frac4,sep      : double;
  x,y, max_nr_stars, area1,area2,area3,area4,count                                  : integer;
  Save_Cursor                      : TCursor;

    procedure plot_star;
    begin
     {5. Conversion (RA,DEC) -> (x,y)}
      sincos(dec2,SIN_dec_new,COS_dec_new);{sincos is faster then separate sin and cos functions}
      delta_ra:=ra2-head.ra0;
      sincos(delta_ra,SIN_delta_ra,COS_delta_ra);
      HH := SIN_dec_new*sin_dec_ref + COS_dec_new*COS_dec_ref*COS_delta_ra;
      dRA := (COS_dec_new*SIN_delta_ra / HH)*180/pi;
      dDEC:= ((SIN_dec_new*COS_dec_ref - COS_dec_new*SIN_dec_ref*COS_delta_ra ) / HH)*180/pi;
      det:=head.cd2_2*head.cd1_1 - head.cd1_2*head.cd2_1;
      fitsX:= +head.crpix1 - (head.cd1_2*dDEC - head.cd2_2*dRA) / det; {1..head.width}
      fitsY:= +head.crpix2 + (head.cd1_1*dDEC - head.cd2_1*dRA) / det; {1..head.height}
      x:=round(fitsX-1); {0..head.width-1}
      y:=round(fitsY-1); {0..head.height-1}

      if ((x>=0) and (x<=head.width-1) and (y>=0) and (y<=head.height-1)) then {within image1}
      begin
        img[0,x,y]:=min(img[0,x,y],mag2);{take brightest star}
      end;
    end;


begin
  if ((fits_file) and (head.cd1_1<>0)) then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    counter_flux_measured:=0;

    bp_rp:=999;{not defined in mono versions}

    fitsX_middle:=(head.width+1)/2;{range 1..width, if range 1,2,3,4  then middle is 2.5=(4+1)/2 }
    fitsY_middle:=(head.height+1)/2;

    dRa :=(head.cd1_1*(fitsx_middle-head.crpix1)+head.cd1_2*(fitsy_middle-head.crpix2))*pi/180;
    dDec:=(head.cd2_1*(fitsx_middle-head.crpix1)+head.cd2_2*(fitsy_middle-head.crpix2))*pi/180;
    delta:=cos(head.dec0)-dDec*sin(head.dec0);
    gamma:=sqrt(dRa*dRa+delta*delta);
    telescope_ra:=head.ra0+arctan(Dra/delta);
    telescope_dec:=arctan((sin(head.dec0)+dDec*cos(head.dec0))/gamma);

    if select_star_database(stackmenu1.star_database1.text,15 {neutral})=false then {sets file290 so do before fov selection}
    begin
      application.messagebox(pchar('No star database found!'+#13+'Download the h18 (or h17 or v17) and extract the files to the program directory'), pchar('No star database!'),0);
      exit;
    end;

    fov_org:= sqrt(sqr(head.width*head.cdelt1)+sqr(head.height*head.cdelt2))*pi/180; {field of view with 0% extra}

    linepos:=2;{Set pointer to the beginning. First two lines are comments}

    sincos(head.dec0,SIN_dec_ref,COS_dec_ref);{do this in advance since it is for each pixel the same}

    if database_type<>001 then {1476 or 290 files}
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
        while readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp) do plot_star;{add star}
      end;

      {read 2th area}
      if area2<>0 then {read 2th area}
      begin
        if open_database(telescope_dec,area2)=false then begin exit; end; {open database file or reset buffer}
        while readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp) do plot_star;{add star}
      end;

      {read 3th area}
      if area3<>0 then {read 3th area}
      begin
        if open_database(telescope_dec,area3)=false then begin exit; end; {open database file or reset buffer}
        while readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp) do plot_star;{add star}
      end;
      {read 4th area}
      if area4<>0 then {read 4th area}
      begin
        if open_database(telescope_dec,area4)=false then begin exit; end; {open database file or reset buffer}
        while readdatabase290(telescope_ra,telescope_dec, fov,{var} ra2,dec2, mag2,Bp_Rp) do plot_star;{add star}
      end;

      close_star_database;

    end
    else
    begin {001 database}
      if wide_database<>name_database then
                              read_stars_wide_field;{load wide field stars array}
      count:=0;
      cos_telescope_dec:=cos(telescope_dec);
      while  (count<length(wide_field_stars) div 3)  do {star 001 database read.}
      begin
        mag2:=wide_field_stars[count*3];{contains: mag1, ra1,dec1, mag2,ra2,dec2,mag3........}
        ra2:=wide_field_stars[count*3+1];
        dec2:=wide_field_stars[count*3+2];
        ang_sep(ra2,dec2,telescope_ra,telescope_dec, sep);{angular seperation}
        if ((sep<fov_org*0.5*0.9*(2/sqrt(pi))) and  (sep<pi/2)) then  {factor 2/sqrt(pi) is to adapt circle search field to surface square. Factor 0.9 is a fiddle factor for trees, house and dark corners. Factor <pi/2 is the limit for procedure equatorial_standard}
        begin
          plot_star;{add star}
        end;
        inc(count);
      end;
    end;

    Screen.Cursor:= Save_Cursor;

  end;{fits file}
end;{plot stars}


procedure plot_stars_used_for_solving(correctionX,correctionY: double); {plot image stars and database stars used for the solution}
var
  nrstars,i, starX, starY,size  : integer;
  flip_horizontal, flip_vertical: boolean;
  xx,yy,x,y                     :double;
begin
  flip_vertical:=mainwindow.flip_vertical1.Checked;
  flip_horizontal:=mainwindow.flip_horizontal1.Checked;

  {do image stars}
  nrstars:=length(starlist2[0]);
  mainwindow.image1.Canvas.Pen.Mode := pmMerge;
  mainwindow.image1.Canvas.Pen.width := round(1+head.height/mainwindow.image1.height);{thickness lines}
  mainwindow.image1.Canvas.brush.Style:=bsClear;
  mainwindow.image1.Canvas.Pen.Color :=clred;

  for i:=0 to nrstars-1 do
  begin

    if flip_horizontal=true then starX:=round((head.width-starlist2[0,i]))  else starX:=round(starlist2[0,i]);
    if flip_vertical=false  then starY:=round((head.height-starlist2[1,i])) else starY:=round(starlist2[1,i]);
    size:=15;
    mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
 end;

  {do database stars}
  nrstars:=length(starlist1[0]);
  mainwindow.image1.Canvas.Pen.Color := annotation_color;
  for i:=0 to nrstars-1 do
  begin
    xx:=(starlist1[0,i]-correctionX)/(head.cdelt1*3600);{apply correction for database stars center and image center and convert arc seconds to pixels}
    yy:=(starlist1[1,i]-correctionY)/(head.cdelt2*3600);
    rotate((90-head.crota2)*pi/180,xx,yy,X,Y);{rotate to screen orientation}

    if flip_horizontal=false then begin starX:=round(head.crpix1-x); end else begin starX:=round(head.crpix1+x); end;
    if flip_vertical=false   then begin starY:=round(head.crpix2-y); end else begin starY:=round(head.crpix2+y); end;

    size:=20;
    mainwindow.image1.Canvas.Rectangle(starX-size,starY-size, starX+size, starY+size);{indicate hfd with rectangle}
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
    repeat
      read_deepsky('T' {full database search} ,0 {ra},0 {dec},1 {cos(telescope_dec)},2*pi{fov},{var} ra0,dec0,length0,width0,pa);{Deepsky database search}
      if ((objname=uppercase(naam2)) or (objname=uppercase(naam3)) or (objname=uppercase(naam4))) then
      begin
        result:=true;
        if naam3='' then objname:=naam2 {Add one object name only}
         else
         objname:=naam2+'_'+naam3;{Add two object names}
        linepos:=$FFFFFF; {Stop searching}
     end;
    until linepos>=$FFFFFF;{Found object or end of database}
  end;
end;

end.

