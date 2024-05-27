del .\*.ppu
del .\*.O
del .\astap.exe

IF EXIST astap.exe rundll32 user32.dll,MessageBeep
IF EXIST astap.exe powershell "[console]::beep(500,300)"
IF EXIST astap.exe powershell "[console]::beep(500,300)"
IF EXIST astap.exe ECHO ABORT!! astap.exe locked!!!
IF EXIST astap.exe pause
IF EXIST astap.exe exit

d:\lazarus\lazbuild  astap_w64.lpi -B

pkzip25 -add astap .\astap.exe
pkzip25 -add astap .\deep_sky.csv
pkzip25 -add astap .\unprocessed_raw.exe


copy astap.zip C:\webpage\webpage\homepage_hnsky /y

"C:\Program Files (x86)\Inno Setup 5\compil32.exe"  /cc  C:\astap.fpc\output\astap_install.iss
copy C:\astap.fpc\output\Output\mysetup.exe C:\webpage\webpage\homepage_hnsky\astap_setup.exe /y


d:\lazarus\lazbuild astap_w32.lpi  -B

pkzip25 -add astapwin32 .\astap.exe
pkzip25 -add astapwin32 .\deep_sky.csv
pkzip25 -add astapwin32 .\variable_stars.csv

copy astapwin32.zip C:\webpage\webpage\homepage_hnsky /y


pause

