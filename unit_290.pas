unit unit_290;
{HNSKY reads star databases type .290}
{Copyright (C) 2017,2018 by Han Kleijn, www.hnsky.org
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

{$mode delphi}

interface

uses
  Classes, SysUtils, math;

var
//  area290:integer;           {290 files, should be set at 290+1 for before any read series}
  cos_telescope_dec : double;{store here the cos(telescope_dec) value before and read series}
  database2         : array[0..(11*10)] of ansichar;{info star database, length 110 char equals 10x11 bytes}

// telescope_ra, telescope_dec [radians], contains to center position of the field of interest
// field_diameter [radians], FOV diameter of field of interest. This is ignored in searchmode=T}
// ra, dec [radians],   reported star position
// mag2 [magnitude*10]  reported star magnitude
// result [true/false]  if reported true more stars available. If false no more stars available
// extra outputs:
//          naam2,  string containing the star Tycho/UCAC4 designation for record size above 7
//          database2  : array[0..(11*10)] of ansichar;{text info star database used}
// preconditions:
//   cos_telescope_dec, double variable should contains the cos(telescope_dec) to detect if star read is within the FOV diameter}

function select_star_database(database:string): boolean; {select a star database, report false if none is found}
procedure find_areas(ra1,dec1,fov :double; var area1,area2,area3,area4 :integer; var frac1,frac2,frac3,frac4:double);{find up to four star database areas for the square image. Maximum size image about 20x20 degrees or 4 fields}
function readdatabase290(telescope_ra,telescope_dec, field_diameter:double; area290: integer; var ra2,dec2, mag2,Bp_Rp : double): boolean;{star 290 file database search}
procedure close_star_database;{Close the reader.}

// The format of the 290 star databases is described in the HNSKY help file
//
// The sky is divided in 290 areas of equal surface except for the poles which are half of that size.
// The stars are stored in these 290 separate files and sorted from bright to faint. Each file starts with a header of 110 bytes of which the first part contains
// a textual description and the last byte contains the record size 5, 6, 7, 10 or 11 bytes.  The source of the utility program to make star databases is provided.
//
// The 290 area's:
// The areas are based on an mathematical method described in a paper of the PHILLIPS LABORATORY called "THE DIVISION OF A CIRCLE OR SPHERICAL SURFACE INTO EQUAL-AREA CELLS OR PIXELS"
// by Irving I. Gringorten Penelope J. Yepez on 30 June 1992
// First circles of constant declination are assumed. The first sphere segment defined by circle with number 1 has a height h1 from the pole and a surface of 2*pi*h1.
// If the second circle of constant declination has a sphere segment with a height of 9*h1 then the surface area of the second sphere segment is nine times higher equal 2*pi*9*h1.
// If the area between circle 1 en 2 is divided in 8 segments then these eight have the same area as the area of the first segment.
// The same is possible for the third circle by diving it in 16 segments, then in 24, 32, 40, 48, 56, 64 segments.
// The area of the third segment is 2*pi*25*h1, where 25 equals 1+8+16. So the sphere segments have a height of h1, 9*h1, 25*h1, 49*h1.
// The height of h1=1-sin(declination). All areas are equal area but rectangle.
// In HNSKY all area's are a combination of two except for the polar areas to have a more square shape especially around the equator.
// The south pole is stored in file 0101.290 Area A2 and A3 are stored in file 02_01.290, area A4 and A5 are stored in file 0202.290.
// The distances between the circles is pretty constant and around 10 to 12 degrees. The distance between the area centres is around 15 degrees maximum.
// The declinations are calculated by arcsin (1-1/289), arcsin(1-(1+8)/289), arcsin (1-(1+8+16)/289), arcsin(1-(1+8+16+24)/289)...
//
//     	Ring 	declination 	declination     Areas 	HNSKY
//              minimum         maximum         equal   area's
//                                              size
//   	0-1 	-90 	        -85.23224404 	1 	1          {arcsin(1-1/289)}
//     	1-2 	-85.23224404 	-75.66348756 	8 	4          {arcsin(1-(1+8)/289)}
//	2-3 	-75.66348756 	-65.99286637 	16 	8          {arcsin (1-(1+8+16)/289)}
//	4-5 	-65.99286637 	-56.14497387 	24 	12
//	6-7 	-56.14497387 	-46.03163067 	32 	16
//	7-8 	-46.03163067 	-35.54307745 	40 	20
//	8-9 	-35.54307745 	-24.53348115 	48 	24
//	7-8 	-24.53348115 	-12.79440589 	56 	28
//	8-9 	-12.79440589 	0 	        64 	32
//	9-10 	0 	        12.79440589 	64 	32
//	10-11 	12.79440589 	24.53348115 	56 	28
//	11-12 	24.53348115 	35.54307745 	48 	24
//	12-13 	35.54307745 	46.03163067 	40 	20
//	13-14 	46.03163067 	56.14497387 	32 	16
//	14-15 	56.14497387 	65.99286637 	24 	12
//	15-16 	65.99286637 	75.66348756 	16 	8
//	16-17 	75.66348756 	85.23224404 	8 	4
//	17-18 	85.23224404 	90 	        1 	1
//    ----------------------------------------------------
//                              Total   	578 	290


{Magnitude: The stars are sorted with an accuracy of 0.1 magnitude. Prior to each group a special record is written where RA is $FFFFFF and DEC contains the magnitude}

type
  hnskyhdr290_6 = packed record  {G16 for storing Rp-Bp. This format is the same as 290_5 but Gaia color information added in an extra shortint}
             ra7 : byte; {The RA is stored as a 3 bytes word. The DEC position is stored as a two's complement (=standard), three bytes integer. The resolution of this three byte storage will be for RA: 360*60*60/((256*256*256)-1) = 0.077 arc seconds. For the DEC value it will be: 90*60*60/((128*256*256)-1) = 0.039 arc seconds.}
             ra8 : byte;
             ra9 : byte;
             dec7: byte;
             dec8: byte;
             B_R: shortint;{Gaia Bp-Rp}
   end;
  hnskyhdr290_5 = packed record  {Most compact format, used for Gaia}
              ra7 : byte;
              ra8 : byte;
              ra9 : byte;
              dec7: byte;
              dec8: byte;
  end;


var
  nr_records             : integer;
  files_available        : boolean;
  name_star              : string;{name star database}

const
  file_open: integer=0;
  area2    : double=1*pi/180; {search area}

implementation

uses astap_main;



Const

filenames290 : array[1..290] of string= {}
(('0101.290'),

 ('0201.290'),  {combined cells from 8}
 ('0202.290'),
 ('0203.290'),
 ('0204.290'),

 ('0301.290'),
 ('0302.290'),
 ('0303.290'),
 ('0304.290'),
 ('0305.290'),
 ('0306.290'),
 ('0307.290'),
 ('0308.290'),

 ('0401.290'),
 ('0402.290'),
 ('0403.290'),
 ('0404.290'),
 ('0405.290'),
 ('0406.290'),
 ('0407.290'),
 ('0408.290'),
 ('0409.290'),
 ('0410.290'),
 ('0411.290'),
 ('0412.290'),

 ('0501.290'),
 ('0502.290'),
 ('0503.290'),
 ('0504.290'),
 ('0505.290'),
 ('0506.290'),
 ('0507.290'),
 ('0508.290'),
 ('0509.290'),
 ('0510.290'),
 ('0511.290'),
 ('0512.290'),
 ('0513.290'),
 ('0514.290'),
 ('0515.290'),
 ('0516.290'),

 ('0601.290'),
 ('0602.290'),
 ('0603.290'),
 ('0604.290'),
 ('0605.290'),
 ('0606.290'),
 ('0607.290'),
 ('0608.290'),
 ('0609.290'),
 ('0610.290'),
 ('0611.290'),
 ('0612.290'),
 ('0613.290'),
 ('0614.290'),
 ('0615.290'),
 ('0616.290'),
 ('0617.290'),
 ('0618.290'),
 ('0619.290'),
 ('0620.290'),

 ('0701.290'),
 ('0702.290'),
 ('0703.290'),
 ('0704.290'),
 ('0705.290'),
 ('0706.290'),
 ('0707.290'),
 ('0708.290'),
 ('0709.290'),
 ('0710.290'),
 ('0711.290'),
 ('0712.290'),
 ('0713.290'),
 ('0714.290'),
 ('0715.290'),
 ('0716.290'),
 ('0717.290'),
 ('0718.290'),
 ('0719.290'),
 ('0720.290'),
 ('0721.290'),
 ('0722.290'),
 ('0723.290'),
 ('0724.290'),

 ('0801.290'),
 ('0802.290'),
 ('0803.290'),
 ('0804.290'),
 ('0805.290'),
 ('0806.290'),
 ('0807.290'),
 ('0808.290'),
 ('0809.290'),
 ('0810.290'),
 ('0811.290'),
 ('0812.290'),
 ('0813.290'),
 ('0814.290'),
 ('0815.290'),
 ('0816.290'),
 ('0817.290'),
 ('0818.290'),
 ('0819.290'),
 ('0820.290'),
 ('0821.290'),
 ('0822.290'),
 ('0823.290'),
 ('0824.290'),
 ('0825.290'),
 ('0826.290'),
 ('0827.290'),
 ('0828.290'),

 ('0901.290'),
 ('0902.290'),
 ('0903.290'),
 ('0904.290'),
 ('0905.290'),
 ('0906.290'),
 ('0907.290'),
 ('0908.290'),
 ('0909.290'),
 ('0910.290'),
 ('0911.290'),
 ('0912.290'),
 ('0913.290'),
 ('0914.290'),
 ('0915.290'),
 ('0916.290'),
 ('0917.290'),
 ('0918.290'),
 ('0919.290'),
 ('0920.290'),
 ('0921.290'),
 ('0922.290'),
 ('0923.290'),
 ('0924.290'),
 ('0925.290'),
 ('0926.290'),
 ('0927.290'),
 ('0928.290'),
 ('0929.290'),
 ('0930.290'),
 ('0931.290'),
 ('0932.290'),

 ('1001.290'),
 ('1002.290'),
 ('1003.290'),
 ('1004.290'),
 ('1005.290'),
 ('1006.290'),
 ('1007.290'),
 ('1008.290'),
 ('1009.290'),
 ('1010.290'),
 ('1011.290'),
 ('1012.290'),
 ('1013.290'),
 ('1014.290'),
 ('1015.290'),
 ('1016.290'),
 ('1017.290'),
 ('1018.290'),
 ('1019.290'),
 ('1020.290'),
 ('1021.290'),
 ('1022.290'),
 ('1023.290'),
 ('1024.290'),
 ('1025.290'),
 ('1026.290'),
 ('1027.290'),
 ('1028.290'),
 ('1029.290'),
 ('1030.290'),
 ('1031.290'),
 ('1032.290'),

 ('1101.290'),
 ('1102.290'),
 ('1103.290'),
 ('1104.290'),
 ('1105.290'),
 ('1106.290'),
 ('1107.290'),
 ('1108.290'),
 ('1109.290'),
 ('1110.290'),
 ('1111.290'),
 ('1112.290'),
 ('1113.290'),
 ('1114.290'),
 ('1115.290'),
 ('1116.290'),
 ('1117.290'),
 ('1118.290'),
 ('1119.290'),
 ('1120.290'),
 ('1121.290'),
 ('1122.290'),
 ('1123.290'),
 ('1124.290'),
 ('1125.290'),
 ('1126.290'),
 ('1127.290'),
 ('1128.290'),

 ('1201.290'),
 ('1202.290'),
 ('1203.290'),
 ('1204.290'),
 ('1205.290'),
 ('1206.290'),
 ('1207.290'),
 ('1208.290'),
 ('1209.290'),
 ('1210.290'),
 ('1211.290'),
 ('1212.290'),
 ('1213.290'),
 ('1214.290'),
 ('1215.290'),
 ('1216.290'),
 ('1217.290'),
 ('1218.290'),
 ('1219.290'),
 ('1220.290'),
 ('1221.290'),
 ('1222.290'),
 ('1223.290'),
 ('1224.290'),

 ('1301.290'),
 ('1302.290'),
 ('1303.290'),
 ('1304.290'),
 ('1305.290'),
 ('1306.290'),
 ('1307.290'),
 ('1308.290'),
 ('1309.290'),
 ('1310.290'),
 ('1311.290'),
 ('1312.290'),
 ('1313.290'),
 ('1314.290'),
 ('1315.290'),
 ('1316.290'),
 ('1317.290'),
 ('1318.290'),
 ('1319.290'),
 ('1320.290'),

 ('1401.290'),
 ('1402.290'),
 ('1403.290'),
 ('1404.290'),
 ('1405.290'),
 ('1406.290'),
 ('1407.290'),
 ('1408.290'),
 ('1409.290'),
 ('1410.290'),
 ('1411.290'),
 ('1412.290'),
 ('1413.290'),
 ('1414.290'),
 ('1415.290'),
 ('1416.290'),

 ('1501.290'),
 ('1502.290'),
 ('1503.290'),
 ('1504.290'),
 ('1505.290'),
 ('1506.290'),
 ('1507.290'),
 ('1508.290'),
 ('1509.290'),
 ('1510.290'),
 ('1511.290'),
 ('1512.290'),

 ('1601.290'),
 ('1602.290'),
 ('1603.290'),
 ('1604.290'),
 ('1605.290'),
 ('1606.290'),
 ('1607.290'),
 ('1608.290'),


 ('1701.290'),
 ('1702.290'),
 ('1703.290'),
 ('1704.290'),

 ('1801.290'));

 const dec_boundaries : array[0..18] of double=
    ((-90         * pi/180),
     (-85.23224404* pi/180), {arcsin(1-1/289)}
     (-75.66348756* pi/180), {arcsin(1-(1+8)/289)}
     (-65.99286637* pi/180), {arcsin(1-(1+8+16)/289)}
     (-56.14497387* pi/180), {arcsin(1-(1+8+16+24)/289)}
     (-46.03163067* pi/180),
     (-35.54307745* pi/180),
     (-24.53348115* pi/180),
     (-12.79440589* pi/180),
     (0),
     (12.79440589* pi/180),
     (24.53348115* pi/180),
     (35.54307745* pi/180),
     (46.03163067* pi/180),
     (56.14497387* pi/180),
     (65.99286637* pi/180),
     (75.66348756* pi/180),
     (85.23224404* pi/180),
     (90         * pi/180) );


const
   record_size:integer=11;{default}
var
  p6        : ^hnskyhdr290_6;       { pointer to hns0kyrecord }
  p5        : ^hnskyhdr290_5;       { pointer to hns0kyrecord }
  dec9_storage: shortint;

  buf2: array[1..11] of byte;  {read buffer stars}
  thefile_stars      : tfilestream;
  Reader_stars       : TReader;



procedure area_and_boundaries(ra1,dec1 :double; var area_nr: integer; var spaceE,spaceW,spaceN,spaceS: double); {For a ra, dec position find the star database area number and the corresponding boundary distances N, E, W, S}
var
  rot,cos_dec1 :double;
begin
  cos_dec1:=cos(dec1);
  if dec1>dec_boundaries[17] then
  begin
   area_nr:=290;   {celestial north pole area}
   spaceS:=dec1-dec_boundaries[17];
   spaceN:=dec_boundaries[18]{90}-dec_boundaries[17];{minimum, could go beyond the celestical pole so above +90 degrees}
   spaceW:=pi*2;
   spaceE:=pi*2;
  end
  else
  if dec1>dec_boundaries[16] then {4x RA}
  begin
    rot:=ra1*4/(2*pi);
    area_nr:=1+4+8+12+16+20+24+28+32+32+28+24+20+16+12+8+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[16];
    spaceN:=dec_boundaries[17]-dec1;
    cos_dec1:=cos(dec1);
    spaceW:=(pi*2/4) * frac(rot)*cos_dec1; {ra decrease in direction west}
    spaceE:=(pi*2/4) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[15] then {8x RA}
  begin
    rot:=ra1*8/(2*pi);
    area_nr:=1+4+8+12+16+20+24+28+32+32+28+24+20+16+12+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[15];
    spaceN:=dec_boundaries[16]-dec1;
    cos_dec1:=cos(dec1);
    spaceW:=(pi*2/8) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/8) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[14] then {12x RA}
  begin
    rot:=ra1*12/(2*pi);
    area_nr:=1+4+8+12+16+20+24+28+32+32+28+24+20+16+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[14];
    spaceN:=dec_boundaries[15]-dec1;
    spaceW:=(pi*2/12) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/12) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[13] then {16x RA}
  begin
   rot:=ra1*16/(2*pi);
    area_nr:=1+4+8+12+16+20+24+28+32+32+28+24+20+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[13];
    spaceN:=dec_boundaries[14]-dec1;
    spaceW:=(pi*2/16) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/16) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[12] then {20x RA}
  begin
    rot:=ra1*20/(2*pi);
    area_nr:=1+4+8+12+16+20+24+28+32+32+28+24+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[12];
    spaceN:=dec_boundaries[13]-dec1;
    spaceW:=(pi*2/20) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/20) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[11] then {24x RA}
  begin
    rot:=ra1*24/(2*pi);
    area_nr:=1+4+8+12+16+20+24+28+32+32+28+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[11];
    spaceN:=dec_boundaries[12]-dec1;
    spaceW:=(pi*2/24) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/24) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[10] then {28x RA}
  begin
    rot:=ra1*28/(2*pi);
    area_nr:=1+4+8+12+16+20+24+28+32+32+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[10];
    spaceN:=dec_boundaries[11]-dec1;
    spaceW:=(pi*2/28) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/28) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[9] then {32x RA}
  begin
    rot:=ra1*32/(2*pi);
    area_nr:=1+4+8+12+16+20+24+28+32+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[9];
    spaceN:=dec_boundaries[10]-dec1;
    spaceW:=(pi*2/32) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/32) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[8] then {32x RA}
  begin
    rot:=ra1*32/(2*pi);
    area_nr:=1+4+8+12+16+20+24+28+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[8];
    spaceN:=dec_boundaries[9]-dec1;
    spaceW:=(pi*2/32) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/32) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[7] then {28x RA}
  begin
    rot:=ra1*28/(2*pi);
    area_nr:=1+4+8+12+16+20+24+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[7];
    spaceN:=dec_boundaries[8]-dec1;
    spaceW:=(pi*2/28) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/28) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[6] then {24x RA}
  begin
    rot:=ra1*24/(2*pi);
    area_nr:=1+4+8+12+16+20+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[6];
    spaceN:=dec_boundaries[7]-dec1;
    spaceW:=(pi*2/24) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/24) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[5] then {20x RA}
  begin
     rot:=ra1*20/(2*pi);
     area_nr:=1+4+8+12+16+1+trunc(rot);
     spaceS:=dec1-dec_boundaries[5];
     spaceN:=dec_boundaries[6]-dec1;
     spaceW:=(pi*2/20) * frac(rot)*cos_dec1;
     spaceE:=(pi*2/20) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[4] then  {16x RA}
  begin
     rot:=ra1*16/(2*pi);
     area_nr:=1+4+8+12+1+trunc(rot);
     spaceS:=dec1-dec_boundaries[4];
     spaceN:=dec_boundaries[5]-dec1;
     spaceW:=(pi*2/16) * frac(rot)*cos_dec1;
     spaceE:=(pi*2/16) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[3] then  {12*RA}
  begin
    rot:=ra1*12/(2*pi);
    area_nr:=1+4+8+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[3];
    spaceN:=dec_boundaries[4]-dec1;
    spaceW:=(pi*2/12) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/12) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[2] then  {8x RA}
  begin
    rot:=ra1*8/(2*pi);
    area_nr:=1+4+1+trunc(rot);
    spaceS:=dec1-dec_boundaries[2];
    spaceN:=dec_boundaries[3]-dec1;
    spaceW:=(pi*2/8) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/8) * (1-frac(rot))*cos_dec1;
  end
  else
  if dec1>dec_boundaries[1] then  {4x RA}
  begin
    rot:=ra1*4/(2*pi);
    area_nr:=1+ 1+trunc(rot);
    spaceS:=dec1-dec_boundaries[1];
    spaceN:=dec_boundaries[2]-dec1;
    spaceW:=(pi*2/4) * frac(rot)*cos_dec1;
    spaceE:=(pi*2/4) * (1-frac(rot))*cos_dec1;
  end
  else
  begin
    area_nr:=1;   {celestial south pole area}
    spaceS:=dec_boundaries[1]-dec_boundaries[0];{minimum, could go beyond the celestical pole so below -90 degrees}
    spaceN:=dec_boundaries[1]-dec1;
    spaceW:=pi*2;
    spaceE:=pi*2;

  end;
end;

procedure find_areas(ra1,dec1,fov :double; var area1,area2,area3,area4 :integer; var frac1,frac2,frac3,frac4:double);{find up to four star database areas for the square image. Maximum size is a little lesse the one database field 9.5x9.5 degrees}
var
  ra_cornerWN,ra_cornerEN,ra_cornerWS,ra_cornerES,
  dec_cornerN,dec_cornerS,fov_half,
  spaceE,spaceW,spaceN,spaceS                                           : double;
begin
  fov_half:=fov/2; {warning FOV should be less the database tiles dimensions, so <=9.53 degrees. Otherwise a tile beyond next tile could be selected}

  dec_cornerN:=dec1+fov_half; {above +pi/2 doesn't matter since it is all area 290}
  dec_cornerS:=dec1-fov_half; {above -pi/2 doesn't matter since it is all area 1}
  ra_cornerWN:=ra1-fov_half/cos(dec_cornerN); if ra_cornerWN<0     then ra_cornerWN:=ra_cornerWN+2*pi;{For direction west the RA decreases}
  ra_cornerEN:=ra1+fov_half/cos(dec_cornerN); if ra_cornerEN>=2*pi then ra_cornerEN:=ra_cornerEN-2*pi;
  ra_cornerWS:=ra1-fov_half/cos(dec_cornerS); if ra_cornerWS<0     then ra_cornerWS:=ra_cornerWS+2*pi;
  ra_cornerES:=ra1+fov_half/cos(dec_cornerS); if ra_cornerES>=2*pi then ra_cornerES:=ra_cornerES-2*pi;

  {corner 1}
  area_and_boundaries(ra_cornerEN,dec_cornerN, area1, spaceE,spaceW,spaceN,spaceS);
  frac1:=min(spaceW,fov)*min(spaceS,fov)/(fov*fov);{fraction of the image requiring this database area}

  {corner 2}
  area_and_boundaries(ra_cornerWN,dec_cornerN, area2, spaceE,spaceW,spaceN,spaceS);
  frac2:=min(spaceE,fov)*min(spaceS,fov)/(fov*fov);{fraction of the image requiring this database area}

  {corner 3}
  area_and_boundaries(ra_cornerES,dec_cornerS, area3, spaceE,spaceW,spaceN,spaceS);
  frac3:=min(spaceW,fov)*min(spaceN,fov)/(fov*fov);{fraction of the image requiring this database area}

  {corner 4}
  area_and_boundaries(ra_cornerWS,dec_cornerS, area4, spaceE,spaceW,spaceN,spaceS);
  frac4:=min(spaceE,fov)*min(spaceN,fov)/(fov*fov);{fraction of the image requiring this database area}


  if area2=area1 then begin area2:=0;frac2:=0;end; {area2 and area1 equivalent}
  if area3=area1 then begin area3:=0;frac3:=0;end; {area3 and area1 equivalent}
  if area4=area1 then begin area4:=0;frac4:=0;end; {area4 and area1 equivalent}

  if area3=area2 then begin area3:=0;frac3:=0;end; {area3 and area2 equivalent}
  if area4=area2 then begin area4:=0;frac4:=0;end;

  if area4=area3 then begin area4:=0;frac4:=0;end;

  if frac1<0.01 then begin area1:=0;frac1:=0;end;{too small, ignore}
  if frac2<0.01 then begin area2:=0;frac2:=0;end;{too small, ignore}
  if frac3<0.01 then begin area3:=0;frac3:=0;end;{too small, ignore}
  if frac4<0.01 then begin area4:=0;frac4:=0;end;{too small, ignore}

end;


function select_star_database(database:string): boolean; {select a star database, report false if none is found}
begin
  result:=true;
  if fileexists( database_path+database+'_0101.290') then name_star:=database {try preference}
  else
  if fileexists( database_path+'g17_0101.290') then name_star:='g17' {database required}
  else
  if fileexists( database_path+'v17_0101.290') then name_star:='v17' {database required}
  else
  if fileexists( database_path+'g18_0101.290') then name_star:='g18' {database required}
  else
  if fileexists( database_path+'g16_0101.290') then name_star:='g16' {database required}
  else
  if fileexists( database_path+'v16_0101.290') then name_star:='v16' {database required}
  else
  if fileexists( database_path+'u16_0101.290') then name_star:='u16' {database required}
  else
  result:=false;
end;

procedure close_star_database;{Close the reader.}
begin
  if file_open=2 then
  begin
    Reader_stars.free;
    thefile_stars.free;
    end;
  file_open:=0;
end;

// This readdatabase is a stripped version for record sizes 5 and 6 only. See HNSKY source files for reading other record size files.
//
// telescope_ra, telescope_dec [radians], contains to center position of the field of interest
// field_diameter [radians], FOV diameter of field of interest. This is ignored in searchmode=T}
// ra, dec [radians],   reported star position
// mag2 [magnitude*10]  reported star magnitude
// Bp-Rp, Gaia color information, not used in ASTAP for solving}
// result [true/false]  if reported true then more stars are available. If false no more stars available.
// extra outputs:
//          database2  : array[0..(11*10)] of ansichar;{text info star database used}
// preconditions:
//   area290 should be set at 290+1 before any read series
//   cos_telescope_dec, double variable should contains the cos(telescope_dec) to detect if star read is within the FOV diameter}
//
function readdatabase290(telescope_ra,telescope_dec, field_diameter:double; area290: integer; var ra2,dec2, mag2,Bp_Rp : double): boolean;{star 290 file database search}
            {searchmode=S screen update }
            {searchmode=M mouse click  search}
            {searchmode=T text search}
  var
    ra_raw,i                       : integer;
    delta_ra, sep, required_range  : double;
    nearbyarea,header_record: boolean;
    label      einde;


var
  ar : integer;
  spaceE,spaceW,spaceN,spaceS : double;
  area_nr:integer;
   area1,area2,area3,area4 :integer;
   frac1,frac2,frac3,frac4,offs:double;
begin
   {$I-}

//   offs:=5/cos(-85.232*pi/180);
//   find_areas((90+offs)*pi/180,-82.232*pi/180,1*pi/180, area1,area2,area3,area4, frac1,frac2,frac3,frac4);{find up to 4 database areas in the image}


//   for i:=1 to 290 do
 //  begin
 //     find_areas(centers290[i,1],centers290[i,2],1*pi/180, area1,area2,area3,area4, frac1,frac2,frac3,frac4);{find up to 4 database areas in the image}
 //     beep;
 //  end;

//   for i:=1 to 290 do
//   begin
//      area(centers290[i,1],centers290[i,2],ar,spaceE,spaceW,spaceN,spaceS);

//     if ar-i<>0 then
//         beep;

//     if spaceE>9*pi/180 then
//     beep;
//     if spaceE>9*pi/180 then
//     beep;
//     if spaceN>7*pi/180 then
//     beep;
//     if spaceS>7*pi/180 then
//     beep;

//   end;

  readdatabase290:=true;
  repeat
    if  ( (file_open=0) or
          (nr_records<=0)
          )  then    {file_open otherwise sometimes the file routine gets stucked}
      begin
         if ((file_open<>0) and (nr_records<=0)) then
         begin
           close_star_database;
           readdatabase290:=false; {no more data in this file}
           exit;
         end;

         if file_open<>0 then close_star_database;{close the reader}

         cos_telescope_dec:=cos(telescope_dec);{here to save CPU time}

         name_star:=copy(name_star,1,3)+'_'+filenames290[area290];{tyc0101.290}
         try
           thefile_stars:=tfilestream.Create( database_path+name_star, fmOpenRead );
           Reader_stars := TReader.Create (thefile_stars, 5*6*9*11);{number of hnsky records, multiply off all posible record sizes}
           {thefile_stars.size-reader.position>sizeof(hkyhdr) could also be used but slow down a factor of 2 !!!}
           files_available:=true;
         except
            readdatabase290:=false;
            files_available:=false;
            exit;
         end;
         file_open:=2; {buffer size is .. x 1024}
         reader_stars.read(database2,110); {read header info, 10x11 is 110 bytes}
         if database2[109]=' ' then record_size:=11 {default}
         else
         record_size:=ord(database2[109]);{5,6,7,9,10 or 11 bytes record}
         nr_records:= trunc((thefile_stars.size-110)/record_size);{110 header size, correct for above read}
      end;{einde}
    reader_stars.read(buf2,record_size);
    header_record:=false;

    case record_size of
    5: begin {record size 5}
         with p5^ do
         begin
           ra_raw:=(ra7 + ra8 shl 8 +ra9 shl 16);{always required, fasted method}
           if ra_raw=$FFFFFF  then  {special magnitude record is found}
           begin
             mag2:=dec8-16;{new magn shifted 16 to make sirius and other positive}
             {magnitude is stored in mag2 till new magnitude record is found}
             dec9_storage:=dec7-128;{recover dec9 shortint and put it in storage}
            header_record:=true;
           end
           else
           begin {normal record without magnitude}
             ra2:= ra_raw*(pi*2  /((256*256*256)-1));
             dec2:=((dec9_storage shl 16)+(dec8 shl 8)+dec7)*(pi*0.5/((128*256*256)-1));// dec2:=(dec7+(dec8 shl 8)+(dec9 shl 16))*(pi*0.5/((128*256*256)-1)); {FPC compiler makes mistake, but dec7 behind}
             {The RA is stored as a 3 bytes word. The DEC position is stored as a two's complement (=standard), three bytes integer. The resolution of this three byte storage will be for RA: 360*60*60/((256*256*256)-1) = 0.077 arc seconds. For the DEC value it will be: 90*60*60/((128*256*256)-1) = 0.039 arc seconds.}
           end;
         end;
       end;{record size 5}
    6: begin {record size 6}
          with p6^ do
          begin
            ra_raw:=(ra7 + ra8 shl 8 +ra9 shl 16);{always required, fasted method}
            if ra_raw=$FFFFFF  then  {special magnitude record is found}
            begin
              mag2:=dec8-16;{new magn shifted 16 to make sirius and other positive}
              {magnitude is stored in mag2 till new magnitude record is found}
              dec9_storage:=dec7-128;{recover dec9 shortint and put it in storage}
             header_record:=true;
            end
            else
            begin {normal record without magnitude}
              ra2:= ra_raw*(pi*2  /((256*256*256)-1));
              dec2:=((dec9_storage shl 16)+(dec8 shl 8)+dec7)*(pi*0.5/((128*256*256)-1));// dec2:=(dec7+(dec8 shl 8)+(dec9 shl 16))*(pi*0.5/((128*256*256)-1)); {FPC compiler makes mistake, but dec7 behind}
            end;
            Bp_Rp:=b_r;{gaia (Bp-Rp)*10}    {color information not used in ASTAP}
          end;
        end;{record size 6}
    end;{case}

    delta_ra:=abs(ra2-telescope_ra); if delta_ra>pi then delta_ra:=pi*2-delta_ra;
    dec(nr_records); {faster then  (thefile_stars.size-thefile_stars.position<sizeofhnskyhdr) !!!)}
  until
    (header_record=false) and
    (  (abs(delta_ra*cos_telescope_dec)<field_diameter/2) and (abs(dec2-telescope_dec)<field_diameter/2)  );
                           {calculate distance and skip when to far from centre screen, {if false then outside screen,go quick to next line}
end;

begin
  p6:= @buf2[1];	{ set pointer }
  p5:= @buf2[1];	{ set pointer }
end.

