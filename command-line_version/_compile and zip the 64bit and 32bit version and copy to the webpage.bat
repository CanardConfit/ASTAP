d:\lazarus\lazbuild astap_command_line_w64.lpi
pkzip25 -add astap_command-line_version_win64   .\astap_cli.exe
copy astap_command-line_version_win64.zip  C:\webpage\webpage\homepage_hnsky /y

d:\lazarus\lazbuild astap_command_line_w32.lpi
pkzip25 -add astap_command-line_version_win32   .\astap_cli.exe
copy astap_command-line_version_win32.zip  C:\webpage\webpage\homepage_hnsky /y

copy  .\astap_cli.exe \astap.fpc

pause

