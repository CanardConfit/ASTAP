unit unit_constellations; {version 2001-10-21}
{Copyright (C) 1997, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

Interface


type
   const_star = record
        dm    : smallint;{drawing mode, -2=start/ -1=draw}
        ra    : smallint;{ra [0..24000]}
        dec   : smallint;{dec[-9000..9000]}
        bay   : pchar; {bayer letter}
   end;

const
constellation_length=602;
Constellation : array[0..constellation_length] of const_star=
{constellation lines and bayer letter
{Format: -2=start/ -1=draw,RA [0..24000],Dec [-9000..9000], bayer letter}
((dm:-2;ra:140;dec:2909;bay:'α'),   {Alpha And} {0}
(dm:-1;ra:655;dec:3086;bay:'δ'),   {Delta And} {0}
(dm:-1;ra:1162;dec:3562;bay:'β'),  {Beta And} {0}
(dm:-1;ra:2065;dec:4233;bay:'γ'), {Gamma 1 And} {0}
(dm:-2;ra:1162;dec:3562;bay:'β'),  {Beta And} {0}
(dm:-1;ra:946;dec:3850;bay:'μ'), {Mu And} {0}
(dm:-1;ra:830;dec:4108;bay:'ν'),  {Nu And} {0}
(dm:-2;ra:10945;dec:-3714;bay:'ι'),  {Iota Ant} {1}
(dm:-1;ra:10453;dec:-3107;bay:'α'), {Alpha Ant} {1}
(dm:-1;ra:9487;dec:-3595;bay:'ε'), {Epsilon Ant} {1}
(dm:-2;ra:14798;dec:-7904;bay:'α'), {Alpha Aps} {2}
(dm:-1;ra:16558;dec:-7890;bay:'γ'), {Gamma Aps} {2}
(dm:-1;ra:16718;dec:-7752;bay:'β'),  {Beta Aps} {2}
(dm:-2;ra:22877;dec:-758;bay:'λ'),  {Lambda Aqr} {3}
(dm:-1;ra:22589;dec:-12;bay:'η'),   {Eta Aqr} {3}
(dm:-1;ra:22480;dec:-2;bay:'ζ'),  {Zeta 1 Aqr} {3}
(dm:-1;ra:22361;dec:-139;bay:'γ'), {Gamma Aqr} {3}
(dm:-1;ra:22096;dec:-32;bay:'α'), {Alpha Aqr} {3}
(dm:-1;ra:21526;dec:-557;bay:'β'),  {Beta Aqr} {3}
(dm:-1;ra:20795;dec:-950;bay:'ε'), {Epsilon Aqr} {3}
(dm:-2;ra:22361;dec:-139;bay:'γ'), {Gamma Aqr} {3}
(dm:-1;ra:22281;dec:-778;bay:'θ'), {Theta Aqr} {3}
(dm:-1;ra:22911;dec:-1582;bay:'δ'), {Delta Aqr} {3}
(dm:-2;ra:20189;dec:-82;bay:'θ'), {Theta Aql} {4}
(dm:-1;ra:19922;dec:641;bay:'β'),  {Beta Aql} {4}
(dm:-1;ra:19846;dec:887;bay:'α'), {Alpha Aql} {4}
(dm:-1;ra:19771;dec:1061;bay:'γ'), {Gamma Aql} {4}
(dm:-1;ra:19090;dec:1386;bay:'ζ'),  {Zeta Aql} {4}
(dm:-1;ra:18994;dec:1507;bay:'ε'), {Epsilon Aql} {4}
(dm:-2;ra:19846;dec:887;bay:'α'), {Alpha Aql} {4}
(dm:-1;ra:19425;dec:311;bay:'δ'), {Delta Aql} {4}
(dm:-1;ra:19104;dec:-488;bay:'λ'),  {Lambda Aql} {4}
(dm:-2;ra:18110;dec:-5009;bay:'θ'), {Theta Ara} {5}
(dm:-1;ra:17531;dec:-4988;bay:'α'), {Alpha Ara} {5}
(dm:-1;ra:17422;dec:-5553;bay:'β'),  {Beta Ara} {5}
(dm:-1;ra:17423;dec:-5638;bay:'γ'), {Gamma Ara} {5}
(dm:-1;ra:17518;dec:-6068;bay:'δ'), {Delta Ara} {5}
(dm:-2;ra:17422;dec:-5553;bay:'β'),  {Beta Ara} {5}
(dm:-1;ra:16977;dec:-5599;bay:'ζ'),  {Zeta Ara} {5}
(dm:-1;ra:16830;dec:-5904;bay:'η'),   {Eta Ara} {5}
(dm:-2;ra:2833;dec:2726;bay:'41'), {41 Ari} {6}
(dm:-1;ra:2120;dec:2346;bay:'α'),  {Alpha Ari} {6}
(dm:-1;ra:1911;dec:2081;bay:'β'), {Beta Ari} {6}
(dm:-1;ra:1892;dec:1930;bay:'γ'),  {Gamma 1 Ari B} {6}
(dm:-2;ra:5278;dec:4600;bay:'α'),  {Alpha Aur} {7}
(dm:-1;ra:5033;dec:4382;bay:'ε'),   {Epsilon Aur} {7}
(dm:-1;ra:4950;dec:3317;bay:'ι'), {Iota Aur} {7}
(dm:-1;ra:5438;dec:2861;bay:'β'), {Beta Tau} {78}
(dm:-1;ra:5995;dec:3721;bay:'θ'),  {Theta Aur} {7}
(dm:-1;ra:5992;dec:4495;bay:'β'), {Beta Aur} {7}
(dm:-1;ra:5278;dec:4600;bay:'α'),  {Alpha Aur} {7}
(dm:-2;ra:13911;dec:1840;bay:'η'),  {Eta Boo} {8}
(dm:-1;ra:14261;dec:1918;bay:'α'),  {Alpha Boo} {8}
(dm:-1;ra:14531;dec:3037;bay:'ρ'),  {Rho Boo} {new 2001-10-21} {8}
(dm:-1;ra:14535;dec:3831;bay:'γ'),  {Gamma Boo} {8}
(dm:-1;ra:15032;dec:4039;bay:'β'), {Beta Boo} {8}
(dm:-1;ra:15258;dec:3331;bay:'δ'),  {Delta Boo} {8}
(dm:-1;ra:14750;dec:2707;bay:'ε'),   {Epsilon Boo} {8}
(dm:-1;ra:14261;dec:1918;bay:'α'),  {Alpha Boo} {8}
(dm:-1;ra:14686;dec:1373;bay:'ζ'), {Zeta Boo} {8}
(dm:-2;ra:4514;dec:-4495;bay:'δ'),  {Delta Cae} {9}
(dm:-1;ra:4676;dec:-4186;bay:'1'),  {1 Cae} {9}
(dm:-1;ra:4701;dec:-3714;bay:'β'), {Beta Cae} {9}
(dm:-1;ra:5073;dec:-3548;bay:'γ'),  {Gamma Cae} {9}
(dm:-2;ra:12821;dec:8341;bay:''),  {SAO2102 Cam} {10}
(dm:-1;ra:7001;dec:7698;bay:''), {6022 Cam} {10}
(dm:-1;ra:6314;dec:6932;bay:''), {SAO13788 Cam} {10}
(dm:-1;ra:4901;dec:6634;bay:'α'),  {Alpha Cam} {10}
(dm:-1;ra:5057;dec:6044;bay:'β'), {Beta Cam} {10}
(dm:-1;ra:4955;dec:5375;bay:'7'),  {7 Cam} {10}
(dm:-2;ra:3484;dec:5994;bay:'CS'), {CS Cam} {10}
(dm:-1;ra:3825;dec:6553;bay:'BE'), {BE Cam} {10}
(dm:-1;ra:3839;dec:7133;bay:'γ'),  {Gamma Cam} {10}
(dm:-1;ra:6314;dec:6932;bay:''), {SAO13788 Cam} {10}
(dm:-2;ra:8975;dec:1186;bay:'α'),  {Alpha Cnc} {11}
(dm:-1;ra:8745;dec:1815;bay:'δ'),  {Delta Cnc} {11}
(dm:-1;ra:8721;dec:2147;bay:'γ'),  {Gamma Cnc} {11}
(dm:-1;ra:8778;dec:2876;bay:'ι'), {Iota Cnc} {11}
(dm:-2;ra:8275;dec:919;bay:'β'), {Beta Cnc} {11}
(dm:-1;ra:8745;dec:1815;bay:'δ'),  {Delta Cnc} {11}
(dm:-1;ra:8204;dec:1765;bay:'ζ'), {Zeta Cnc} {11}
(dm:-2;ra:12933;dec:3831;bay:'α'),  {Alpha 1 CVn} {12}
(dm:-1;ra:12562;dec:4136;bay:'β'), {Beta CVn} {12}
(dm:-2;ra:7402;dec:-2930;bay:'η'),  {Eta CMa} {13}
(dm:-1;ra:7140;dec:-2639;bay:'δ'),  {Delta CMa} {13}
(dm:-1;ra:6752;dec:-1672;bay:'α'),  {Alpha CMa} {13}
(dm:-1;ra:6378;dec:-1796;bay:'β'), {Beta CMa} {13}
(dm:-2;ra:7063;dec:-1563;bay:'γ'),  {Gamma CMa} {13}
(dm:-1;ra:6936;dec:-1705;bay:'ι'), {Iota CMa} {13}
(dm:-1;ra:6752;dec:-1672;bay:'α'),  {Alpha CMa} {13}
(dm:-2;ra:6977;dec:-2897;bay:'ε'),   {Epsilon CMa} {13}
(dm:-1;ra:7140;dec:-2639;bay:'δ'),  {Delta CMa} {13}
(dm:-2;ra:7655;dec:523;bay:'α'),  {Alpha CMi} {14}
(dm:-1;ra:7453;dec:829;bay:'β'), {Beta CMi} {14}
(dm:-1;ra:7469;dec:893;bay:'γ'),  {Gamma CMi} {14}
(dm:-2;ra:20294;dec:-1251;bay:'α'),  {Alpha 1 Cap} {15}
(dm:-1;ra:20301;dec:-1255;bay:'α2'),   {Alpha2 Cap} {15}
(dm:-1;ra:20350;dec:-1478;bay:'β'), {Beta 1 Cap} {15}
(dm:-1;ra:20768;dec:-2527;bay:'ψ'),  {Psi Cap} {15}
(dm:-1;ra:20864;dec:-2692;bay:'ω'),  {Omega Cap} {15}
(dm:-1;ra:21444;dec:-2241;bay:'ζ'), {Zeta Cap} {15}
(dm:-1;ra:21784;dec:-1613;bay:'δ'),  {Delta Cap} {15}
(dm:-1;ra:21668;dec:-1666;bay:'γ'),  {Gamma Cap} {15}
(dm:-1;ra:21371;dec:-1683;bay:'ι'), {Iota Cap} {15}
(dm:-1;ra:21099;dec:-1723;bay:'θ'),  {Theta Cap} {15}
(dm:-1;ra:20350;dec:-1478;bay:'β'), {Beta 1 Cap} {15}
(dm:-2;ra:6399;dec:-5270;bay:'α'),  {Alpha Car} {16}
(dm:-1;ra:7946;dec:-5298;bay:'χ'),  {Chi Car} {16}
(dm:-1;ra:8375;dec:-5951;bay:'ε'),   {Epsilon Car} {16}
(dm:-1;ra:9183;dec:-5897;bay:'a'),  {a Car} {16}
(dm:-1;ra:9285;dec:-5928;bay:'ι'), {Iota Car} {16}
(dm:-1;ra:10285;dec:-6133;bay:'q'),  {q Car} {16}
(dm:-1;ra:10716;dec:-6439;bay:'θ'),  {Theta Car} {16}
(dm:-1;ra:10229;dec:-7004;bay:'ω'),  {Omega Car} {16}
(dm:-1;ra:9220;dec:-6972;bay:'β'), {Beta Car} {16}
(dm:-1;ra:9785;dec:-6507;bay:'υ'),  {Upsilon Car} {16}
(dm:-1;ra:9285;dec:-5928;bay:'ι'), {Iota Car} {16}
(dm:-2;ra:1907;dec:6367;bay:'ε'),   {Epsilon Cas} {17}
(dm:-1;ra:1430;dec:6024;bay:'δ'),  {Delta Cas} {17}
(dm:-1;ra:945;dec:6072;bay:'γ'),  {Gamma Cas} {17}
(dm:-1;ra:675;dec:5654;bay:'α'),  {Alpha Cas} {17}
(dm:-1;ra:153;dec:5915;bay:'β'), {Beta Cas} {17}
(dm:-2;ra:14660;dec:-6084;bay:'α'),  {Alpha 1 Cen} {18}
(dm:-1;ra:14064;dec:-6037;bay:'β'), {Beta Cen} {18}
(dm:-1;ra:13665;dec:-5347;bay:'ε'),   {Epsilon Cen} {18}
(dm:-1;ra:13926;dec:-4729;bay:'ζ'), {Zeta Cen} {18}
(dm:-1;ra:14592;dec:-4216;bay:'η'),  {Eta Cen} {18}
(dm:-1;ra:14111;dec:-3637;bay:'θ'),  {Theta Cen} {18}
(dm:-1;ra:13343;dec:-3671;bay:'ι'), {Iota Cen} {18}
(dm:-1;ra:12692;dec:-4896;bay:'γ'),  {Gamma Cen} {18}
(dm:-2;ra:12139;dec:-5072;bay:'δ'),  {Delta Cen} {18}
(dm:-1;ra:12692;dec:-4896;bay:'γ'),  {Gamma Cen} {18}
(dm:-1;ra:13665;dec:-5347;bay:'ε'),   {Epsilon Cen} {18}
(dm:-2;ra:21478;dec:7056;bay:'β'), {Beta Cep} {19}
(dm:-1;ra:21310;dec:6259;bay:'α'),  {Alpha Cep} {19}
(dm:-1;ra:22486;dec:5842;bay:'δ'),  {Delta Cep} {19}
(dm:-1;ra:22828;dec:6620;bay:'ι'), {Iota Cep} {19}
(dm:-1;ra:23656;dec:7763;bay:'γ'),  {Gamma Cep} {19}
(dm:-1;ra:21478;dec:7056;bay:'β'), {Beta Cep} {19}
(dm:-1;ra:22828;dec:6620;bay:'ι'), {Iota Cep} {19}
(dm:-2;ra:3038;dec:409;bay:'α'),  {Alpha Cet} {20}
(dm:-1;ra:2722;dec:324;bay:'γ'),  {Gamma Cet} {20}
(dm:-1;ra:2658;dec:33;bay:'δ'),  {Delta Cet} {20}
(dm:-1;ra:2322;dec:-298;bay:'ο'),   {Omicron Cet} {20}
(dm:-1;ra:1858;dec:-1034;bay:'ζ'), {Zeta Cet} {20}
(dm:-1;ra:1734;dec:-1594;bay:'τ'),  {Tau Cet} {20}
(dm:-1;ra:726;dec:-1799;bay:'β'), {Beta Cet} {20}
(dm:-1;ra:324;dec:-882;bay:'ι'), {Iota Cet} {20}
(dm:-2;ra:1858;dec:-1034;bay:'ζ'), {Zeta Cet} {20}
(dm:-1;ra:1400;dec:-818;bay:'θ'),  {Theta Cet} {20}
(dm:-1;ra:1143;dec:-1018;bay:'η'),  {Eta Cet} {20}
(dm:-1;ra:726;dec:-1799;bay:'β'), {Beta Cet} {20}
(dm:-2;ra:8309;dec:-7692;bay:'α'),  {Alpha Cha} {21}
(dm:-1;ra:10591;dec:-7861;bay:'γ'),  {Gamma Cha} {21}
(dm:-1;ra:12306;dec:-7931;bay:'β'), {Beta Cha} {21}
(dm:-1;ra:10763;dec:-8054;bay:'δ2'),   {Delta2 Cha} {21}
(dm:-1;ra:8344;dec:-7748;bay:'θ'),  {Theta Cha} {21}
(dm:-1;ra:8309;dec:-7692;bay:'α'),  {Alpha Cha} {21}
(dm:-2;ra:15292;dec:-5880;bay:'β'), {Beta Cir} {22}
(dm:-1;ra:14708;dec:-6498;bay:'α'),  {Alpha Cir} {22}
(dm:-1;ra:15390;dec:-5932;bay:'γ'),  {Gamma Cir} {22}
(dm:-2;ra:6369;dec:-3344;bay:'δ'),  {Delta Col} {23}
(dm:-1;ra:5849;dec:-3577;bay:'β'), {Beta Col} {23}
(dm:-1;ra:5661;dec:-3407;bay:'α'),  {Alpha Col} {23}
(dm:-1;ra:5520;dec:-3547;bay:'ε'),   {Epsilon Col} {23}
(dm:-1;ra:5849;dec:-3577;bay:'β'), {Beta Col} {23}
(dm:-2;ra:13166;dec:1753;bay:'α'),  {Alpha Com} {24}
(dm:-1;ra:13198;dec:2788;bay:'β'), {Beta Com} {24}
(dm:-1;ra:12449;dec:2827;bay:'γ'),  {Gamma Com} {24}
(dm:-2;ra:19107;dec:-3706;bay:'γ'),  {Gamma CrA} {25}
(dm:-1;ra:19158;dec:-3790;bay:'α'),  {Alpha CrA} {25}
(dm:-1;ra:19167;dec:-3934;bay:'β'), {Beta CrA} {25}
(dm:-2;ra:15960;dec:2688;bay:'ε'),   {Epsilon CrB} {26}
(dm:-1;ra:15712;dec:2630;bay:'γ'),  {Gamma CrB} {26}
(dm:-1;ra:15578;dec:2671;bay:'α'),  {Alpha CrB} {26}
(dm:-1;ra:15464;dec:2911;bay:'β'), {Beta CrB} {26}
(dm:-1;ra:15549;dec:3136;bay:'θ'),  {Theta CrB} {26}
(dm:-2;ra:12140;dec:-2473;bay:'α'),  {Alpha Crv} {27}
(dm:-1;ra:12169;dec:-2262;bay:'ε'),   {Epsilon Crv} {27}
(dm:-1;ra:12263;dec:-1754;bay:'γ'),  {Gamma Crv} {27}
(dm:-1;ra:12498;dec:-1652;bay:'δ'),  {Delta Crv} {27}
(dm:-1;ra:12573;dec:-2340;bay:'β'), {Beta Crv} {27}
(dm:-1;ra:12169;dec:-2262;bay:'ε'),   {Epsilon Crv} {27}
(dm:-2;ra:10996;dec:-1830;bay:'α'),  {Alpha Crt} {28}
(dm:-1;ra:11194;dec:-2283;bay:'β'), {Beta Crt} {28}
(dm:-1;ra:11415;dec:-1768;bay:'γ'),  {Gamma Crt} {28}
(dm:-1;ra:11322;dec:-1478;bay:'δ'),  {Delta Crt} {28}
(dm:-1;ra:10996;dec:-1830;bay:'α'),  {Alpha Crt} {28}
(dm:-2;ra:12443;dec:-6310;bay:'α'),  {Alpha 1 Cru} {29}
(dm:-1;ra:12519;dec:-5711;bay:'γ'),  {Gamma Cru a} {29}
(dm:-2;ra:12795;dec:-5969;bay:'β'), {Beta Crux} {29}
(dm:-1;ra:12252;dec:-5875;bay:'δ'),  {Delta Cru} {29}
(dm:-2;ra:20691;dec:4528;bay:'α'),  {Alpha Cyg} {30}
(dm:-1;ra:20370;dec:4026;bay:'γ'),  {Gamma Cyg} {30}
(dm:-1;ra:19938;dec:3508;bay:'η'),  {Eta Cyg} {30}
(dm:-1;ra:19843;dec:3291;bay:'χ'),  {Chi Cyg} {30}
(dm:-1;ra:19513;dec:2797;bay:'β'), {Beta Cyg} {30}
(dm:-2;ra:21216;dec:3023;bay:'ζ'), {Zeta Cyg} {30}
(dm:-1;ra:20770;dec:3397;bay:'ε'),   {Epsilon Cyg} {30}
(dm:-1;ra:20370;dec:4026;bay:'γ'),  {Gamma Cyg} {30}
(dm:-1;ra:19750;dec:4513;bay:'δ'),  {Delta Cyg} {30}
(dm:-1;ra:19495;dec:5173;bay:'ι'), {Iota Cyg} {30}
(dm:-1;ra:19285;dec:5337;bay:'κ'),  {Kappa Cyg} {30}
(dm:-2;ra:20554;dec:1130;bay:'ε'),   {Epsilon Del} {31}
(dm:-1;ra:20588;dec:1467;bay:'ζ'), {Zeta Del} {31}
(dm:-1;ra:20661;dec:1591;bay:'α'),  {Alpha Del} {31}
(dm:-1;ra:20777;dec:1612;bay:'γ'),  {Gamma 1 Del} {31}
(dm:-1;ra:20724;dec:1507;bay:'δ'),  {Delta Del} {31}
(dm:-1;ra:20626;dec:1460;bay:'β'), {Beta Del} {31}
(dm:-1;ra:20588;dec:1467;bay:'ζ'), {Zeta Del} {31}
(dm:-2;ra:4267;dec:-5149;bay:'γ'),  {Gamma Dor} {32}
(dm:-1;ra:4567;dec:-5505;bay:'α'),  {Alpha Dor} {32}
(dm:-1;ra:5560;dec:-6249;bay:'β'), {Beta Dor} {32}
(dm:-1;ra:5746;dec:-6574;bay:'δ'),  {Delta Dor} {32}
(dm:-2;ra:12558;dec:6979;bay:'κ'),  {Kappa Dra} {33}
(dm:-1;ra:14073;dec:6438;bay:'α'),  {Alpha Dra} {33}
(dm:-1;ra:15415;dec:5897;bay:'ι'), {Iota Dra} {33}
(dm:-1;ra:16031;dec:5857;bay:'θ'),  {Theta Dra} {33}
(dm:-1;ra:16400;dec:6151;bay:'η'),  {Eta Dra} {33}
(dm:-1;ra:17146;dec:6571;bay:'ζ'), {Zeta Dra} {33}
(dm:-1;ra:19803;dec:7027;bay:'ε'),   {Epsilon Dra} {33}
(dm:-1;ra:19209;dec:6766;bay:'δ'),  {Delta Dra} {33}
(dm:-1;ra:17536;dec:5518;bay:'ν'), {Nu 1 Dra} {33}
(dm:-1;ra:17507;dec:5230;bay:'β'), {Beta Dra} {33}
(dm:-1;ra:17943;dec:5149;bay:'γ'),  {Gamma Dra} {33}
(dm:-1;ra:17536;dec:5518;bay:'ν'), {Nu 1 Dra} {33}
(dm:-2;ra:21264;dec:525;bay:'α'),  {Alpha Equ} {34}
(dm:-1;ra:21241;dec:1001;bay:'δ'),  {Delta Equ} {34}
(dm:-1;ra:21172;dec:1013;bay:'γ'),  {Gamma Equ} {34}
(dm:-1;ra:20985;dec:429;bay:'ε'),   {Epsilon Equ} {34}
(dm:-1;ra:21264;dec:525;bay:'α'),  {Alpha Equ} {34}
(dm:-2;ra:5131;dec:-509;bay:'β'), {Beta Eri} {35}
(dm:-1;ra:4605;dec:-335;bay:'ν'), {Nu Eri} {35}
(dm:-1;ra:3967;dec:-1351;bay:'γ'),  {Gamma Eri} {35}
(dm:-1;ra:3721;dec:-976;bay:'δ'),  {Delta Eri} {35}
(dm:-1;ra:3549;dec:-946;bay:'ε'),   {Epsilon Eri} {35}
(dm:-1;ra:2940;dec:-890;bay:'η'), {Eta Eri} {35}
(dm:-1;ra:4298;dec:-3380;bay:'41'), {41 Eri} {35}
(dm:-1;ra:2971;dec:-4030;bay:'θ'), {Theta 1 Eri} {35}
(dm:-1;ra:2275;dec:-5150;bay:'φ'),  {phi Eri} {35}
(dm:-1;ra:1933;dec:-5161;bay:'χ'),  {Chi Eri} {35}
(dm:-1;ra:1629;dec:-5724;bay:'α'),  {Alpha Eri} {35}
(dm:-2;ra:3704;dec:-3194;bay:'δ'),  {Delta For} {36}
(dm:-1;ra:3201;dec:-2899;bay:'α'),  {Alpha For} {36}
(dm:-1;ra:2818;dec:-3241;bay:'β'), {Beta For} {36}
(dm:-1;ra:2075;dec:-2930;bay:'ν'), {Nu For} {36}
(dm:-2;ra:6629;dec:1640;bay:'γ'),  {Gamma Gem} {37}
(dm:-1;ra:7068;dec:2057;bay:'ζ'), {Zeta Gem} {37}
(dm:-1;ra:7335;dec:2198;bay:'δ'),  {Delta Gem} {37}
(dm:-1;ra:7755;dec:2803;bay:'β'), {Beta Gem} {37}
(dm:-1;ra:7577;dec:3189;bay:'α'),  {Alpha Gem} {37}
(dm:-1;ra:6732;dec:2513;bay:'ε'),   {Epsilon Gem} {37}
(dm:-1;ra:6383;dec:2251;bay:'μ'), {Mu Gem {37}
(dm:-1;ra:6248;dec:2251;bay:'η'),  {Eta Gem} {37}
(dm:-2;ra:21899;dec:-3737;bay:'γ'),  {Gamma Gru} {38}
(dm:-1;ra:22488;dec:-4350;bay:'δ'),  {Delta 1 Gru} {38}
(dm:-1;ra:22496;dec:-4375;bay:'δ2'),   {Delta2 Gru} {38}
(dm:-1;ra:22711;dec:-4688;bay:'β'), {Beta Gru} {38}
(dm:-1;ra:22809;dec:-5132;bay:'ε'),   {Epsilon Gru} {38}
(dm:-1;ra:23015;dec:-5275;bay:'ζ'), {Zeta Gru} {38}
(dm:-2;ra:22137;dec:-4696;bay:'α'),  {Alpha Gru} {38}
(dm:-1;ra:22488;dec:-4350;bay:'δ'),  {Delta 1 Gru} {38}
(dm:-2;ra:17938;dec:3725;bay:'θ'),  {Theta Her} {39}
(dm:-1;ra:17251;dec:3681;bay:'π'), {Pi Her} {39}
(dm:-1;ra:17005;dec:3093;bay:'ε'),   {Epsilon Her} {39}
(dm:-1;ra:17251;dec:2484;bay:'δ'),  {Delta Her} {39}
(dm:-1;ra:17244;dec:1439;bay:'α'),  {Alpha 1 Her} {39}
(dm:-2;ra:17251;dec:3681;bay:'π'), {Pi Her} {39}
(dm:-1;ra:16715;dec:3892;bay:'η'),  {Eta Her} {39}
(dm:-1;ra:16688;dec:3160;bay:'ζ'), {Zeta Her} {39}
(dm:-1;ra:16504;dec:2149;bay:'β'), {Beta Her} {39}
(dm:-1;ra:16365;dec:1915;bay:'γ'),  {Gamma Her} {39}
(dm:-2;ra:17005;dec:3093;bay:'ε'),   {Epsilon Her} {39}
(dm:-1;ra:16688;dec:3160;bay:'ζ'), {Zeta Her} {39}
(dm:-2;ra:16715;dec:3892;bay:'η'),  {Eta Her} {39}
(dm:-1;ra:16568;dec:4244;bay:'σ'),  {Sigma Her} {39}
(dm:-1;ra:16329;dec:4631;bay:'τ'),  {Tau Her} {39}
(dm:-2;ra:4233;dec:-4229;bay:'α'),  {Alpha Hor} {40}
(dm:-1;ra:2623;dec:-5254;bay:'η'),  {Eta Hor} {40}
(dm:-1;ra:2980;dec:-6407;bay:'β'), {Beta Hor} {40}
(dm:-2;ra:14106;dec:-2668;bay:'π'), {Pi Hya} {41}
(dm:-1;ra:13495;dec:-2328;bay:'R'),  {R Hya} {41}
(dm:-1;ra:13315;dec:-2317;bay:'γ'),  {Gamma Hya} {41}
(dm:-1;ra:11882;dec:-3391;bay:'β'), {Beta Hya} {41}
(dm:-1;ra:11550;dec:-3186;bay:'ξ'), {Xi Hya} {41}
(dm:-1;ra:10827;dec:-1619;bay:'ν'), {Nu Hya} {41}
(dm:-1;ra:10176;dec:-1235;bay:'λ'),  {Lambda Hya} {NIEUW HAN} {41}
(dm:-1;ra:9858;dec:-1485;bay:'υ'),   {Upsilon 1 Hya} {nieuw han} {41}
(dm:-1;ra:9460;dec:-866;bay:'α'),  {Alpha Hya} {41}
(dm:-1;ra:9664;dec:-114;bay:'ι'),   {Iota Hya} {nieuw han} {41}
(dm:-1;ra:9239;dec:231;bay:'θ'),    {Theta Hya} {nieuw han} {41}
(dm:-1;ra:8923;dec:595;bay:'ζ'), {Zeta Hya} {41}
(dm:-1;ra:8780;dec:642;bay:'ε'),   {Epsilon Hya} {41}
(dm:-1;ra:8628;dec:570;bay:'δ'),  {Delta Hya} {41}
(dm:-1;ra:8720;dec:340;bay:'η'),  {Eta Hya} {41}
(dm:-1;ra:8923;dec:595;bay:'ζ'), {Zeta Hya} {41}
(dm:-2;ra:1980;dec:-6157;bay:'α'),  {Alpha Hyi} {42}
(dm:-1;ra:429;dec:-7725;bay:'β'), {Beta Hyi} {42}
(dm:-1;ra:3787;dec:-7424;bay:'γ'),  {Gamma Hyi} {42}
(dm:-1;ra:1980;dec:-6157;bay:'α'),  {Alpha Hyi} {42}
(dm:-2;ra:20626;dec:-4729;bay:'α'),  {Alpha Ind} {43}
(dm:-1;ra:21331;dec:-5345;bay:'θ'),  {Theta Ind} {43}
(dm:-1;ra:20913;dec:-5845;bay:'β'), {Beta Ind} {43}
(dm:-2;ra:21331;dec:-5345;bay:'θ'),  {Theta Ind} {43}
(dm:-1;ra:21965;dec:-5499;bay:'δ'),  {Delta Ind} {43}
(dm:-2;ra:22393;dec:5223;bay:'β'), {Beta Lac} {44}
(dm:-1;ra:22522;dec:5028;bay:'α'),  {Alpha Lac} {44}
(dm:-1;ra:22266;dec:3775;bay:'1'),  {1 Lac} {44}
(dm:-2;ra:9764;dec:2377;bay:'ε'),  {Epsilon Leo} {45}
(dm:-1;ra:10278;dec:2342;bay:'ζ'), {Zeta Leo} {45}
(dm:-1;ra:10333;dec:1984;bay:'γ'),  {Gamma Leo} {45}
(dm:-1;ra:10122;dec:1676;bay:'η'),  {Eta Leo} {45}
(dm:-1;ra:10140;dec:1197;bay:'α'),  {Alpha Leo} {45}
(dm:-1;ra:11237;dec:1543;bay:'θ'),  {Theta Leo} {45}
(dm:-1;ra:11818;dec:1457;bay:'β'), {Beta Leo} {45}
(dm:-1;ra:11235;dec:2052;bay:'δ'),  {Delta Leo} {45}
(dm:-1;ra:10333;dec:1984;bay:'γ'),  {Gamma Leo} {45}
(dm:-2;ra:10889;dec:3421;bay:'46'), {46 LMi} {46}
(dm:-1;ra:10465;dec:3671;bay:'β'), {Beta LMi} {46}
(dm:-1;ra:10124;dec:3524;bay:'21'), {21 LMi} {46}
(dm:-1;ra:9570;dec:3640;bay:'10'), {10 LMi} {46}
(dm:-2;ra:5940;dec:-1417;bay:'η'),  {Eta Lep} {47}
(dm:-1;ra:5855;dec:-2088;bay:'δ'),  {Delta Lep} {47}
(dm:-1;ra:5741;dec:-2245;bay:'γ'),  {Gamma Lep} {47}
(dm:-1;ra:5471;dec:-2076;bay:'β'), {Beta Lep} {47}
(dm:-1;ra:5091;dec:-2237;bay:'ε'),   {Epsilon Lep} {47}
(dm:-1;ra:5216;dec:-1621;bay:'μ'), {Mu Lep} {47}
(dm:-1;ra:5545;dec:-1782;bay:'α'),  {Alpha Lep} {47}
(dm:-1;ra:5855;dec:-2088;bay:'δ'),  {Delta Lep} {47}
(dm:-1;ra:5783;dec:-1482;bay:'ζ'), {Zeta Lep} {47}
(dm:-2;ra:5545;dec:-1782;bay:'α'),  {Alpha Lep} {47}
(dm:-1;ra:5471;dec:-2076;bay:'β'), {Beta Lep} {47}
(dm:-2;ra:15592;dec:-1479;bay:'γ'),  {Gamma Lib} {48}
(dm:-1;ra:15283;dec:-938;bay:'β'), {Beta Lib} {48}
(dm:-1;ra:14848;dec:-1604;bay:'α2'),   {Alpha2 Lib} {48}
(dm:-2;ra:14699;dec:-4739;bay:'α'),  {Alpha Lup} {49}
(dm:-1;ra:14976;dec:-4313;bay:'β'), {Beta Lup} {49}
(dm:-1;ra:15356;dec:-4065;bay:'δ'),  {Delta Lup} {49}
(dm:-1;ra:16002;dec:-3840;bay:'η'),  {Eta Lup} {49}
(dm:-1;ra:15586;dec:-4117;bay:'γ'),  {Gamma Lup} {49}
(dm:-1;ra:15378;dec:-4469;bay:'ε'),   {Epsilon Lup} {49}
(dm:-1;ra:15199;dec:-4874;bay:'κ'),  {Kappa 1 Lup} {49}
(dm:-1;ra:15205;dec:-5210;bay:'ζ'), {Zeta Lup} {49}
(dm:-1;ra:14699;dec:-4739;bay:'α'),  {Alpha Lup} {49}
(dm:-2;ra:9351;dec:3439;bay:'α'),  {Alpha Lyn} {50}
(dm:-1;ra:9314;dec:3680;bay:'38'), {38 Lyn} {50}
(dm:-1;ra:9011;dec:4178;bay:'10'), {10 Lyn} {50}
(dm:-1;ra:8381;dec:4319;bay:'31'), {31 Lyn} {50}
(dm:-1;ra:7445;dec:4921;bay:'21'), {21 Lyn} {50}
(dm:-2;ra:18616;dec:3878;bay:'α'),  {Alpha Lyr} {51}
(dm:-1;ra:18746;dec:3761;bay:'ζ'), {Zeta 1 Lyr} {51}
(dm:-1;ra:18835;dec:3336;bay:'β'), {Beta Lyr} {51}
(dm:-1;ra:18982;dec:3269;bay:'γ'),  {Gamma Lyr} {51}
(dm:-1;ra:18908;dec:3690;bay:'δ2'),   {Delta2 Lyr} {51}
(dm:-1;ra:18746;dec:3761;bay:'ζ'), {Zeta 1 Lyr} {51}
(dm:-2;ra:6171;dec:-7475;bay:'α'),  {Alpha Men} {52}
(dm:-1;ra:5531;dec:-7634;bay:'γ'),  {Gamma Men} {52}
(dm:-1;ra:4920;dec:-7494;bay:'η'),  {Eta Men} {52}
(dm:-1;ra:5045;dec:-7131;bay:'β'), {Beta Men} {52}
(dm:-2;ra:20833;dec:-3378;bay:'α'),  {Alpha Mic} {53}
(dm:-1;ra:21022;dec:-3226;bay:'γ'),  {Gamma Mic} {53}
(dm:-1;ra:21299;dec:-3217;bay:'ε'),   {Epsilon Mic} {53}
(dm:-2;ra:8143;dec:-298;bay:'ζ'), {Zeta Mon} {54}
(dm:-1;ra:7687;dec:-955;bay:'α'),  {Alpha Mon} {54}
(dm:-1;ra:7198;dec:-49;bay:'δ'),  {Delta Mon} {54}
(dm:-2;ra:6396;dec:459;bay:'ε'),   {Epsilon Mon} {54}
(dm:-1;ra:7198;dec:-49;bay:'δ'),  {Delta Mon} {54}
(dm:-1;ra:6480;dec:-703;bay:'β'), {Beta Mon} {54}
(dm:-1;ra:6248;dec:-627;bay:'γ'),  {Gamma Mon} {54}
(dm:-2;ra:11760;dec:-6673;bay:'λ'), {Lambda Mus} {55}
(dm:-1;ra:12293;dec:-6796;bay:'ε'),   {Epsilon Mus} {55}
(dm:-1;ra:12620;dec:-6914;bay:'α'),  {Alpha Mus} {55}
(dm:-1;ra:12771;dec:-6811;bay:'β'), {Beta Mus} {55}
(dm:-1;ra:13038;dec:-7155;bay:'δ'),  {Delta Mus} {55}
(dm:-1;ra:12541;dec:-7213;bay:'γ'),  {Gamma Mus} {55}
(dm:-1;ra:12620;dec:-6914;bay:'α'),  {Alpha Mus} {55}
(dm:-2;ra:16331;dec:-5016;bay:'γ2'),   {Gamma2 Nor} {56}
(dm:-1;ra:16054;dec:-4923;bay:'η'),  {Eta Nor} {56}
(dm:-2;ra:22768;dec:-8138;bay:'β'), {Beta Oct} {57}
(dm:-1;ra:14449;dec:-8367;bay:'δ'),  {Delta Oct} {57}
(dm:-1;ra:21691;dec:-7739;bay:'ν'), {Nu Oct} {57}
(dm:-1;ra:22768;dec:-8138;bay:'β'), {Beta Oct} {57}
(dm:-2;ra:17367;dec:-2500;bay:'θ'),  {Theta Oph} {58}
(dm:-1;ra:17173;dec:-1572;bay:'η'),  {Eta Oph} {58}
(dm:-1;ra:17725;dec:457;bay:'β'), {Beta Oph} {58}
(dm:-1;ra:17582;dec:1256;bay:'α'),  {Alpha Oph} {58}
(dm:-1;ra:16961;dec:938;bay:'κ'),  {Kappa Oph} {58}
(dm:-1;ra:16239;dec:-369;bay:'δ'),  {Delta Oph} {58}
(dm:-1;ra:16305;dec:-469;bay:'ε'),   {Epsilon Oph} {58}
(dm:-1;ra:16619;dec:-1057;bay:'ζ'), {Zeta Oph} {58}
(dm:-1;ra:17173;dec:-1572;bay:'η'),  {Eta Oph} {58}
(dm:-2;ra:5679;dec:-194;bay:'ζ'), {Zeta Ori} {59}
(dm:-1;ra:5920;dec:741;bay:'α'),  {Alpha Ori} {59}
(dm:-1;ra:5586;dec:993;bay:'λ'), {Lambda Ori} {59}
(dm:-1;ra:5419;dec:635;bay:'γ'),  {Gamma Ori} {59}
(dm:-1;ra:5533;dec:-28;bay:'δ'),  {Delta Ori} {59}
(dm:-1;ra:5604;dec:-120;bay:'ε'),   {Epsilon Ori} {59}
(dm:-1;ra:5679;dec:-194;bay:'ζ'), {Zeta Ori} {59}
(dm:-1;ra:5796;dec:-967;bay:'κ'),  {Kappa Ori} {59}
(dm:-1;ra:5242;dec:-820;bay:'β'), {Beta Ori} {59}
(dm:-1;ra:5533;dec:-28;bay:'δ'),  {Delta Ori} {59}
(dm:-2;ra:21441;dec:-6537;bay:'τ'),  {Tau Pav} {60}
(dm:-1;ra:20749;dec:-6620;bay:'β'), {Beta Pav} {60}
(dm:-1;ra:20010;dec:-7291;bay:'ε'),   {Epsilon Pav} {60}
(dm:-1;ra:18717;dec:-7143;bay:'ζ'), {Zeta Pav} {60}
(dm:-1;ra:17762;dec:-6472;bay:'η'),  {Eta Pav} {60}
(dm:-1;ra:18387;dec:-6149;bay:'ξ'), {Xi Pav} {60}
(dm:-1;ra:20145;dec:-6618;bay:'δ'),  {Delta Pav} {60}
(dm:-1;ra:20749;dec:-6620;bay:'β'), {Beta Pav} {60}
(dm:-2;ra:22717;dec:3022;bay:'η'),  {Eta Peg} {61}
(dm:-1;ra:23063;dec:2808;bay:'β'), {Beta Peg} {61}
(dm:-1;ra:140;dec:2909;bay:'α'), {Alpha And} {0}
(dm:-1;ra:221;dec:1518;bay:'γ'),  {Gamma Peg} {61}
(dm:-1;ra:23079;dec:1521;bay:'α'),  {Alpha Peg} {61}
(dm:-1;ra:22691;dec:1083;bay:'ζ'), {Zeta Peg} {61}
(dm:-1;ra:22170;dec:620;bay:'θ'),  {Theta Peg} {61}
(dm:-1;ra:21736;dec:988;bay:'ε'),   {Epsilon Peg} {61}
(dm:-2;ra:23063;dec:2808;bay:'β'), {Beta Peg} {61}
(dm:-1;ra:23079;dec:1521;bay:'α'),  {Alpha Peg} {61}
(dm:-2;ra:2845;dec:5590;bay:'η'),  {Eta Per} {62}
(dm:-1;ra:3080;dec:5351;bay:'γ'),  {Gamma Per} {62}
(dm:-1;ra:3405;dec:4986;bay:'α'),  {Alpha Per} {62}
(dm:-1;ra:3715;dec:4779;bay:'δ'),  {Delta Per} {62}
(dm:-1;ra:3964;dec:4001;bay:'ε'),   {Epsilon Per} {62}
(dm:-1;ra:3902;dec:3188;bay:'ζ'), {Zeta Per} {62}
(dm:-2;ra:3405;dec:4986;bay:'α'),  {Alpha Per} {62}
(dm:-1;ra:3136;dec:4096;bay:'β'), {Beta Per} {62}
(dm:-1;ra:3086;dec:3884;bay:'ρ'),  {Rho Per} {62}
(dm:-2;ra:157;dec:-4575;bay:'ε'),   {Epsilon Phe} {63}
(dm:-1;ra:437;dec:-4368;bay:'κ'),  {Kappa Phe} {63}
(dm:-1;ra:1101;dec:-4672;bay:'β'), {Beta Phe} {63}
(dm:-1;ra:1473;dec:-4332;bay:'γ'),  {Gamma Phe} {63}
(dm:-1;ra:1521;dec:-4907;bay:'δ'),  {Delta Phe} {63}
(dm:-1;ra:1140;dec:-5525;bay:'ζ'), {Zeta Phe} {63}
(dm:-1;ra:1101;dec:-4672;bay:'β'), {Beta Phe} {63}
(dm:-2;ra:6803;dec:-6194;bay:'α'),  {Alpha Pic} {64}
(dm:-1;ra:5830;dec:-5617;bay:'γ'),  {Gamma Pic} {64}
(dm:-1;ra:5788;dec:-5107;bay:'β'), {Beta Pic} {64}
(dm:-2;ra:1525;dec:1535;bay:'η'),  {Eta Psc} {65}
(dm:-1;ra:1757;dec:916;bay:'ο'),   {Omicron Psc} {65}
(dm:-1;ra:2034;dec:276;bay:'α'),  {Alpha Psc} {65}
(dm:-1;ra:1049;dec:789;bay:'ε'),   {Epsilon Psc} {65}
(dm:-1;ra:811;dec:759;bay:'δ'),  {Delta Psc} {65}
(dm:-1;ra:23989;dec:686;bay:'ω'),  {Omega Psc} {65}
(dm:-1;ra:23666;dec:563;bay:'ι'), {Iota Psc} {65}
(dm:-1;ra:23466;dec:638;bay:'θ'),  {Theta Psc} {65}
(dm:-1;ra:23065;dec:382;bay:'β'), {Beta Psc} {65}
(dm:-1;ra:23286;dec:328;bay:'γ'),  {Gamma Psc} {65}
(dm:-1;ra:23666;dec:563;bay:'ι'), {Iota Psc} {65}
(dm:-2;ra:21749;dec:-3303;bay:'ι'), {Iota PsA} {66}
(dm:-1;ra:22525;dec:-3235;bay:'β'), {Beta PsA} {66}
(dm:-1;ra:22875;dec:-3288;bay:'γ'),  {Gamma PsA} {66}
(dm:-1;ra:22932;dec:-3254;bay:'δ'),  {Delta PsA} {66}
(dm:-1;ra:22961;dec:-2962;bay:'α'),  {Alpha PsA} {66}
(dm:-1;ra:22678;dec:-2704;bay:'ε'),   {Epsilon PsA} {66}
(dm:-1;ra:22525;dec:-3235;bay:'β'), {Beta PsA} {66}
(dm:-2;ra:8126;dec:-2430;bay:'ρ'),  {Rho Pup} {67}
(dm:-1;ra:7822;dec:-2486;bay:'ξ'), {Xi Pup} {67}
(dm:-1;ra:8060;dec:-4000;bay:'ζ'), {Zeta Pup} {67}
(dm:-1;ra:7286;dec:-3710;bay:'π'), {Pi Pup} {67}
(dm:-1;ra:7487;dec:-4330;bay:'σ'),  {Sigma Pup} {67}
(dm:-1;ra:7226;dec:-4464;bay:'L2'),  {L2 Pup} {67}
(dm:-1;ra:6629;dec:-4320;bay:'ν'), {Nu Pup} {67}
(dm:-1;ra:6832;dec:-5061;bay:'τ'),  {Tau Pup} {67}
(dm:-1;ra:7226;dec:-4464;bay:'L2'),  {L2 Pup} {67}
(dm:-2;ra:8060;dec:-4000;bay:'ζ'), {Zeta Pup} {67}
(dm:-1;ra:7487;dec:-4330;bay:'σ'),  {Sigma Pup} {67}
(dm:-2;ra:8668;dec:-3531;bay:'β'), {Beta Pyx} {68}
(dm:-1;ra:8727;dec:-3319;bay:'α'),  {Alpha Pyx} {68}
(dm:-1;ra:8842;dec:-2771;bay:'γ'),  {Gamma Pyx} {68}
(dm:-2;ra:4240;dec:-6247;bay:'α'),  {Alpha Ret} {69}
(dm:-1;ra:3737;dec:-6481;bay:'β'), {Beta Ret} {69}
(dm:-1;ra:4015;dec:-6216;bay:'γ'),  {Gamma Ret} {69}
(dm:-1;ra:3979;dec:-6140;bay:'4'),  {4 Ret} {69}
(dm:-1;ra:4275;dec:-5930;bay:'ε'),   {Epsilon Ret} {69}
(dm:-1;ra:4240;dec:-6247;bay:'α'),  {Alpha Ret} {69}
(dm:-2;ra:19668;dec:1801;bay:'α'),  {Alpha Sge} {70}
(dm:-1;ra:19790;dec:1853;bay:'δ'),  {Delta Sge} {70}
(dm:-1;ra:19684;dec:1748;bay:'β'), {Beta Sge} {70}
(dm:-2;ra:19790;dec:1853;bay:'δ'),  {Delta Sge} {70}
(dm:-1;ra:19979;dec:1949;bay:'γ'),  {Gamma Sge} {70}
(dm:-2;ra:19387;dec:-4480;bay:'β2'), {Beta2 Sgr} {71}
(dm:-1;ra:19377;dec:-4446;bay:'β'), {Beta 1 Sgr} {71}
(dm:-1;ra:19398;dec:-4062;bay:'α'),  {Alpha Sgr} {71}
(dm:-1;ra:19044;dec:-2988;bay:'ζ'), {Zeta Sgr} {71}
(dm:-1;ra:18921;dec:-2630;bay:'σ'),  {Sigma Sgr} {71}
(dm:-1;ra:18466;dec:-2542;bay:'λ'), {Lambda Sgr} {71}
(dm:-1;ra:18350;dec:-2983;bay:'δ'),  {Delta Sgr} {71}
(dm:-1;ra:18403;dec:-3438;bay:'ε'),   {Epsilon Sgr} {71}
(dm:-1;ra:18294;dec:-3676;bay:'η'),  {Eta Sgr} {71}
(dm:-2;ra:18097;dec:-3042;bay:'γ'),  {Gamma Sgr} {71}
(dm:-1;ra:18350;dec:-2983;bay:'δ'),  {Delta Sgr} {71}
(dm:-2;ra:18229;dec:-2106;bay:'μ'), {Mu Sgr} {71}
(dm:-1;ra:18466;dec:-2542;bay:'λ'), {Lambda Sgr} {71}
(dm:-2;ra:18962;dec:-2111;bay:'ξ2'), {Xi2 Sgr} {71}
(dm:-1;ra:18921;dec:-2630;bay:'σ'),  {Sigma Sgr} {71}
(dm:-2;ra:17560;dec:-3710;bay:'λ'), {Lambda Sco} {72}
(dm:-1;ra:17708;dec:-3903;bay:'κ'),  {Kappa Sco} {72}
(dm:-1;ra:17622;dec:-4300;bay:'θ'),  {Theta Sco} {72}
(dm:-1;ra:17203;dec:-4324;bay:'η'),  {Eta Sco} {72}
(dm:-1;ra:16910;dec:-4236;bay:'ζ2'), {Zeta2 Sco} {72}
(dm:-1;ra:16864;dec:-3805;bay:'μ'), {Mu 1 Sco} {72}
(dm:-1;ra:16836;dec:-3429;bay:'ε'),   {Epsilon Sco} {72}
(dm:-1;ra:16490;dec:-2643;bay:'α'),  {Alpha Sco} {72}
(dm:-1;ra:16091;dec:-1981;bay:'β'), {Beta 1 Sco} {72}
(dm:-1;ra:16006;dec:-2262;bay:'δ'),  {Delta Sco} {72}
(dm:-1;ra:16490;dec:-2643;bay:'α'),  {Alpha Sco} {72}
(dm:-2;ra:977;dec:-2936;bay:'α'),  {Alpha Scl} {73}
(dm:-1;ra:23815;dec:-2813;bay:'δ'),  {Delta Scl} {73}
(dm:-1;ra:23314;dec:-3253;bay:'γ'),  {Gamma Scl} {73}
(dm:-1;ra:23550;dec:-3782;bay:'β'), {Beta Scl} {73}
(dm:-2;ra:18786;dec:-475;bay:'β'), {Beta Sct} {74}
(dm:-1;ra:18587;dec:-824;bay:'α'),  {Alpha Sct} {74}
(dm:-1;ra:18487;dec:-1457;bay:'γ'),  {Gamma Sct} {74}
(dm:-2;ra:15941;dec:1566;bay:'γ'),  {Gamma Ser} {76}
(dm:-1;ra:15770;dec:1542;bay:'β'), {Beta Ser} {76}
(dm:-1;ra:15580;dec:1054;bay:'δ'),  {Delta Ser} {76}
(dm:-1;ra:15738;dec:643;bay:'α'),  {Alpha Ser} {76}
(dm:-1;ra:15847;dec:448;bay:'ε'),   {Epsilon Ser} {76}
(dm:-1;ra:15827;dec:-343;bay:'μ'), {Mu Ser} {76}
(dm:-1;ra:16239;dec:-369;bay:'δ'),  {Delta Oph} {58}
(dm:-2;ra:17173;dec:-1572;bay:'η'),  {Eta Oph} {58}
(dm:-1;ra:17626;dec:-1540;bay:'ξ'), {Xi Ser} {76}
(dm:-1;ra:18355;dec:-290;bay:'η'),  {Eta Ser} {76}
(dm:-1;ra:18937;dec:420;bay:'θ'),  {Theta 1 Ser} {76}
(dm:-2;ra:10505;dec:-64;bay:'β'), {Beta Sex} {77}
(dm:-1;ra:10132;dec:-37;bay:'α'),  {Alpha Sex} {77}
(dm:-1;ra:9875;dec:-811;bay:'γ'),  {Gamma Sex} {77}
(dm:-2;ra:5627;dec:2114;bay:'ζ'), {Zeta Tau} {78}
(dm:-1;ra:4599;dec:1651;bay:'α'),  {Alpha Tau} {78}
(dm:-1;ra:5438;dec:2861;bay:'β'), {Beta Tau} {78}
(dm:-2;ra:4599;dec:1651;bay:'α'),  {Alpha Tau} {78}
(dm:-1;ra:4478;dec:1587;bay:'θ2'),   {Theta2 Tau} {78}
(dm:-1;ra:4330;dec:1563;bay:'γ'),  {Gamma Tau} {78}
(dm:-1;ra:4382;dec:1754;bay:'δ'),  {Delta 1 Tau} {78}
(dm:-1;ra:4477;dec:1918;bay:'ε'),   {Epsilon Tau} {78}
(dm:-2;ra:3791;dec:2411;bay:'η'),  {Eta Tau} {78}
(dm:-1;ra:4330;dec:1563;bay:'γ'),  {Gamma Tau} {78}
(dm:-1;ra:4011;dec:1249;bay:'λ'), {Lambda Tau} {78}
(dm:-2;ra:18187;dec:-4595;bay:'ε'),   {Epsilon Tel} {79}
(dm:-1;ra:18450;dec:-4597;bay:'α'),  {Alpha Tel} {79}
(dm:-1;ra:18481;dec:-4907;bay:'ζ'), {Zeta Tel} {79}
(dm:-2;ra:1885;dec:2958;bay:'α'),  {Alpha Tri} {80}
(dm:-1;ra:2159;dec:3499;bay:'β'), {Beta Tri} {80}
(dm:-1;ra:2289;dec:3385;bay:'γ'),  {Gamma Tri} {80}
(dm:-1;ra:1885;dec:2958;bay:'α'),  {Alpha Tri} {80}
(dm:-2;ra:16811;dec:-6903;bay:'α'),  {Alpha TrA} {81}
(dm:-1;ra:15919;dec:-6343;bay:'β'), {Beta TrA} {81}
(dm:-1;ra:15315;dec:-6868;bay:'γ'),  {Gamma TrA} {81}
(dm:-1;ra:16811;dec:-6903;bay:'α'),  {Alpha TrA} {81}
(dm:-2;ra:22308;dec:-6026;bay:'α'),  {Alpha Tuc} {82}
(dm:-1;ra:23290;dec:-5824;bay:'γ'),  {Gamma Tuc} {82}
(dm:-1;ra:526;dec:-6296;bay:'β'), {Beta 1 Tuc} {82}
(dm:-1;ra:335;dec:-6488;bay:'ζ'), {Zeta Tuc} {82}
(dm:-1;ra:22308;dec:-6026;bay:'α'),  {Alpha Tuc} {82}
(dm:-2;ra:13792;dec:4931;bay:'η'),  {Eta UMa} {83}
(dm:-1;ra:13399;dec:5493;bay:'ζ'), {Zeta UMa} {83}
(dm:-1;ra:12900;dec:5596;bay:'ε'),   {Epsilon UMa} {83}
(dm:-1;ra:12257;dec:5703;bay:'δ'),  {Delta UMa} {83}
(dm:-1;ra:11062;dec:6175;bay:'α'),  {Alpha UMa} {83}
(dm:-1;ra:11031;dec:5638;bay:'β'), {Beta UMa} {83}
(dm:-1;ra:11897;dec:5369;bay:'γ'),  {Gamma UMa} {83}
(dm:-1;ra:12257;dec:5703;bay:'δ'),  {Delta UMa} {83}
(dm:-2;ra:2531;dec:8926;bay:'α'),  {Alpha UMi} {84}
(dm:-1;ra:17537;dec:8659;bay:'δ'),  {Delta UMi} {84}
(dm:-1;ra:16766;dec:8204;bay:'ε'),   {Epsilon UMi} {84}
(dm:-1;ra:15734;dec:7779;bay:'ζ'), {Zeta UMi} {84}
(dm:-1;ra:14845;dec:7416;bay:'β'), {Beta UMi} {84}
(dm:-1;ra:15345;dec:7183;bay:'γ'),  {Gamma UMi} {84}
(dm:-1;ra:16292;dec:7576;bay:'η'),  {Eta UMi} {84}
(dm:-1;ra:15734;dec:7779;bay:'ζ'), {Zeta UMi} {84}
(dm:-2;ra:10779;dec:-4942;bay:'μ'), {Mu Vel} {85}
(dm:-1;ra:9948;dec:-5457;bay:'φ'),  {Phi Vel} {85}
(dm:-1;ra:9369;dec:-5501;bay:'κ'),  {Kappa Vel} {85}
(dm:-1;ra:8745;dec:-5471;bay:'δ'),  {Delta Vel} {85}
(dm:-1;ra:8158;dec:-4735;bay:'γ'),  {Gamma 1 Vel} {85}
(dm:-1;ra:9133;dec:-4343;bay:'λ'), {Lambda Vel} {85}
(dm:-1;ra:9512;dec:-4047;bay:'ψ'),  {Psi Vel} {85}
(dm:-2;ra:9133;dec:-4343;bay:'λ'), {Lambda Vel} {85}
(dm:-1;ra:9369;dec:-5501;bay:'κ'),  {Kappa Vel} {85}
(dm:-2;ra:14718;dec:-566;bay:'μ'), {Mu Vir} {86}
(dm:-1;ra:14267;dec:-600;bay:'ι'), {Iota Vir} {86}
(dm:-1;ra:13420;dec:-1116;bay:'α'),  {Alpha Vir} {86}
(dm:-1;ra:13166;dec:-554;bay:'θ'),  {Theta Vir} {86}
(dm:-1;ra:12694;dec:-145;bay:'γ'),  {Gamma Vir} {86}
(dm:-1;ra:12332;dec:-67;bay:'η'),  {Eta Vir} {86}
(dm:-1;ra:11845;dec:176;bay:'β'), {Beta Vir} {86}
(dm:-2;ra:12694;dec:-145;bay:'γ'),  {Gamma Vir} {86}
(dm:-1;ra:12927;dec:340;bay:'δ'),  {Delta Vir} {86}
(dm:-1;ra:13578;dec:-60;bay:'ζ'), {Zeta Vir} {86}
(dm:-1;ra:13420;dec:-1116;bay:'α'),  {Alpha Vir} {86}
(dm:-2;ra:13036;dec:1096;bay:'ε'),   {Epsilon Vir} {86}
(dm:-1;ra:12927;dec:340;bay:'δ'),  {Delta Vir} {86}
(dm:-2;ra:9041;dec:-6640;bay:'α'),  {Alpha Vol} {87}
(dm:-1;ra:8132;dec:-6862;bay:'ε'),   {Epsilon Vol} {87}
(dm:-1;ra:7281;dec:-6796;bay:'δ'),  {Delta Vol} {87}
(dm:-1;ra:7145;dec:-7050;bay:'γ'),  {Gamma 1 Vol} {87}
(dm:-1;ra:7697;dec:-7261;bay:'ζ'), {Zeta Vol} {87}
(dm:-1;ra:8132;dec:-6862;bay:'ε'),   {Epsilon Vol} {87}
(dm:-2;ra:20018;dec:2775;bay:'15'), {15 Vul} {88}
(dm:-1;ra:19891;dec:2408;bay:'13'), {13 Vul} {88}
(dm:-1;ra:19478;dec:2467;bay:'α'),  {Alpha Vul} {88}
(dm:-1;ra:19270;dec:2139;bay:'1')); {1 Vul} {88}



Constpos : array[0..88,0..1] of smallint=
{Constellation position , for name see Constname
 RA * 1000, Dec * 100}

((564,3925),       {'Andromeda',}
(10118,-3365),     {'Antlia',}
(16000,-8000),     {'Apus',}
(22697,-1053),     {'Aquarius',}
(19690,337),       {'Aquila',}
(17231,-5189),     {'Ara',}
(2676,2257),       {'Aries',}
(5500,4240),       {'Auriga',}
(14687,3233),      {'Bootes',}
(4721,-3883),      {'Caelum',}
(6151,7196),       {'Camelopardalis',}
(8497,2356),       {'Cancer',}
(13020,4235),      {'Canes_Venatici',}
(6830,-2269),      {'Canis_Major',}
(7624,676),        {'Canis_Minor',}
(21048,-1965),     {'Capricornus',}
(7761,-5717),      {'Carina',}
(870,6030),        {'Cassiopeia',}
(12950,-4400),     {'Centaurus',}
(22417,7256),      {'Cepheus',}
(1709,-664),       {'Cetus',}
(12000,-8000),     {'Chamaeleon',}
(14527,-6770),     {'Circinus',}
(5705,-3708),      {'Columba',}
(12748,2265),      {'Coma_Berenices',}
(18655,-4125),     {'Corona_Australis',}
(15880,3263),      {'Corona_Borealis',}
(12387,-1836),     {'Corvus',}
(11348,-1325),     {'Crater',}
(12600,-6070),     {'Crux',}
(20598,4958),      {'Cygnus',}
(20663,1210),      {'Delphinus',}
(5333,-6399),      {'Dorado',}
(17945,6606),      {'Draco',}
(21251,794),       {'Equuleus',}
(3876,-1701),      {'Eridanus',}
(2766,-2694),      {'Fornax',}
(7300,2600),       {'Gemini',}
(22457,-4586),     {'Grus',}
(17425,3123),      {'Hercules',}
(3212,-5200),      {'Horologium',}
(9136,-1132),      {'Hydra',}
(2589,-7208),      {'Hydrus',}
(21138,-5268),     {'Indus',}
(22514,4667),      {'Lacerta',}
(10600,1800),       {'Leo',}
(10316,3324),      {'Leo_Minor',}
(5436,-1935),      {'Lepus',}
(15187,-1545),     {'Libra',}
(15376,-4228),     {'Lupus',}
(7734,4783),       {'Lynx',}
(18908,4065),      {'Lyra',}
(5500,-7999),      {'Mensa',}
(20942,-3620),     {'Microscopium',}
(6962,-500),       {'Monoceros',}
(12460,-6987),     {'Musca',}
(16042,-5229),     {'Norma',}
(22173,-8473),     {'Octans',}
(17037,-265),      {'Ophiuchus',}
(5660,500),        {'Orion',}
(19160,-6514),     {'Pavo',}
(22617,1965),      {'Pegasus',}
(3514,4489),       {'Perseus',}
(732,-4823),       {'Phoenix',}
(5381,-5163),      {'Pictor',}
(891,1548),        {'Pisces',}
(22410,-3143),     {'Piscis_Austrinus',}
(7873,-3239),      {'Puppis',}
(8891,-2921),      {'Pyxis',}
(3899,-6049),      {'Reticulum',}
(19667,1700),      {'Sagitta',}
(19385,-2911),     {'Sagittarius',}
(16865,-3567),     {'Scorpius',}
(500,-3500),       {'Sculptor',}
(18651,-1011),     {'Scutum',}
(15731,1085),      {'Serpens_Caput',}
(17958,-1352),     {'Serpens_Cauda',}
(10102,-187),      {'Sextans',}
(4095,1734),       {'Taurus',}
(19244,-5154),     {'Telescopium',}
(2043,3234),       {'Triangulum',}
(16124,-6590),     {'Triangulum_Australe',}
(23828,-6406),     {'Tucana',}
(10263,5748),      {'Ursa_Major',}
(15000,7600),      {'Ursa_Minor',}
(9337,-4851),      {'Vela',}
(13343,-349),      {'Virgo',}
(7659,-6939),      {'Volans',}
(20367,2503));     {'Vulpecula'));}



Constshortname : array[0..88] of pchar=
(('And'),
('Ant'),
('Aps'),
('Aqr'),
('Aql'),
('Ara'),
('Ari'),
('Aur'),
('Boo'),
('Cae'),
('Cam'),
('Cnc'),
('CVn'),
('CMa'),
('CMi'),
('Cap'),
('Car'),
('Cas'),
('Cen'),
('Cep'),
('Cet'),
('Cha'),
('Cir'),
('Col'),
('Com'),
('CrA'),
('CrB'),
('Crv'),
('Crt'),
('Cru'),
('Cyg'),
('Del'),
('Dor'),
('Dra'),
('Equ'),
('Eri'),
('For'),
('Gem'),
('Gru'),
('Her'),
('Hor'),
('Hya'),
('Hyi'),
('Ind'),
('Lac'),
('Leo'),
('LMi'),
('Lep'),
('Lib'),
('Lup'),
('Lyn'),
('Lyr'),
('Men'),
('Mic'),
('Mon'),
('Mus'),
('Nor'),
('Oct'),
('Oph'),
('Ori'),
('Pav'),
('Peg'),
('Per'),
('Phe'),
('Pic'),
('Psc'),
('PsA'),
('Pup'),
('Pyx'),
('Ret'),
('Sge'),
('Sgr'),
('Sco'),
('Scl'),
('Sct'),
('Ser'),
('Ser'),
('Sex'),
('Tau'),
('Tel'),
('Tri'),
('TrA'),
('Tuc'),
('UMa'),
('UMi'),
('Vel'),
('Vir'),
('Vol'),
('Vul'));

implementation
begin
end.
