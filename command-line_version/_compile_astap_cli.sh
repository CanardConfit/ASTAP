#!/bin/bash

rm astap_cli

/home/h/fpcupdeluxe/lazarus/lazbuild astap_command_line_linux_aarch64.lpi
zip astap_command-line_version_Linux_aarch64.zip astap_cli
if [[ ! -f ~/astap.fpc/command-line_version/astap_cli ]] ; then
    echo 'Linux_aarch64 file does not exist, aborting!!'
    exit
fi
rm astap_cli



/home/h/fpcupdeluxe/lazarus/lazbuild astap_command_line_linux_armhf.lpi
zip astap_command-line_version_Linux_armhf.zip astap_cli
if [[ ! -f ~/astap.fpc/command-line_version/astap_cli ]] ; then
    echo 'Linux_armhf file does not exist, aborting!!'
    exit
fi
rm astap_cli


/home/h/fpcupdeluxe/lazarus/lazbuild astap_command_line_darwin_M1.lpi
zip astap_command-line_version_macOS_M1.zip astap_cli
if [[ ! -f ~/astap.fpc/command-line_version/astap_cli ]] ; then
    echo 'macOS_M1 file does not exist, aborting!!'
    exit
fi
rm astap_cli


/home/h/fpcupdeluxe/lazarus/lazbuild astap_command_line_darwin_X86_64.lpi
zip astap_command-line_version_macOS_x86_64.zip astap_cli
if [[ ! -f ~/astap.fpc/command-line_version/astap_cli ]] ; then
    echo 'macOS_x86_64 file does not exist, aborting!!'
    exit
fi
rm astap_cli


/home/h/fpcupdeluxe/lazarus/lazbuild astap_command_line_android_aarch64.lpi
# patchelf --set-interpreter /system/bin/linker64 ./astap_cli
zip astap_command-line_version_Android_aarch64.zip astap_cli
if [[ ! -f ~/astap.fpc/command-line_version/astap_cli ]] ; then
    echo 'Android_aarch64 file does not exist, aborting!!'
    exit
fi
rm astap_cli



/home/h/fpcupdeluxe/lazarus/lazbuild astap_command_line_android_x86_64.lpi
# patchelf --set-interpreter /system/bin/linker64 ./astap_cli
zip astap_command-line_version_Android_x86_64.zip astap_cli
if [[ ! -f ~/astap.fpc/command-line_version/astap_cli ]] ; then
    echo 'Android_x86_64 file does not exist, aborting!!'
    exit
fi
rm astap_cli

/home/h/fpcupdeluxe/lazarus/lazbuild astap_command_line_linux.lpi
zip astap_command-line_version_Linux_amd64.zip astap_cli
if [[ ! -f ~/astap.fpc/command-line_version/astap_cli ]] ; then
    echo 'Linux_amd64 file does not exist, aborting!!'
    exit
fi
rm astap_cli


/home/h/fpcupdeluxe/lazarus/lazbuild astap_command_line_win11_aarch64.lpi
zip astap_command-line_version_win11_aarch64 astap_cli.exe
if [[ ! -f ~/astap.fpc/command-line_version/astap_cli.exe ]] ; then
    echo 'Win11_aarch64 file does not exist, aborting!!'
    exit
fi
rm astap_cli.exe

#/home/h/fpcupdeluxe/lazarus/lazbuild astap_command_line_iOS_aarch64.lpi
#zip astap_command-line_version_iOS.zip astap_cli
#if [[ ! -f ~/astap.fpc/command-line_version/astap_cli ]] ; then
#    echo 'iOS_aarch64 file does not exist, aborting!!'
#    exit
#fi
#rm astap_cli








