
rm ~/astap.fpc/astap
/home/h/fpcupdeluxe/lazarus/lazbuild /home/h/astap.fpc/astap_linux.lpi
if [[ ! -f ~/astap.fpc/astap ]] ; then
    echo 'AMD64 file does not exist, aborting!!'
    exit
fi

cp /home/h/astap.fpc/astap /home/h/astap_install/astap_amd64/opt/astap
cd /home/h/astap_install
sudo rm *.rpm
sudo fakeroot dpkg-deb -Zxz --build /home/h/astap_install/astap_amd64
sudo /home/h/alien/alien-8.95/alien.pl -r -c -k  /home/h/astap_install/astap_amd64.deb
cp *.rpm astap_amd64.rpm

#unpack
sudo dpkg -i ./astap_amd64.deb
tar -czvf astap_amd64.tar.gz /opt/astap/astap  /opt/astap/astap.ico /opt/astap/astap.ico /opt/astap/copyright.txt /opt/astap/deep_sky.csv /opt/astap/variable_stars.csv /usr/share/applications/ASTAP.desktop /usr/local/bin/astap /opt/astap/dcraw-astap /opt/astap/unprocessed_raw-astap

#build amd64 qt5 using stable version!!
rm ~/astap.fpc/astap
/home/h/fpcupdeluxe_stable/lazarus/lazbuild /home/h/astap.fpc/astap_linux_qt5.lpi
if [[ ! -f ~/astap.fpc/astap ]] ; then
    echo 'AMD64 QT5 file does not exist, aborting!!'
    exit
fi
sudo cp /home/h/astap.fpc/astap /opt/astap
tar -czvf astap_amd64_qt5.tar.gz /opt/astap/astap  /opt/astap/astap.ico /opt/astap/astap.ico /opt/astap/copyright.txt /opt/astap/deep_sky.csv /opt/astap/variable_stars.csv /usr/share/applications/ASTAP.desktop /opt/astap/dcraw-astap /opt/astap/unprocessed_raw-astap

#Build i386    
rm ~/astap.fpc/astap                                
/home/h/fpcupdeluxe/lazarus/lazbuild /home/h/astap.fpc/astap_linux_gkt2_i386.lpi                  
if [[ ! -f ~/astap.fpc/astap ]] ; then
    echo 'I386 file does not exist, aborting!!'
    exit
fi
cp /home/h/astap.fpc/astap /home/h/astap_install/astap_i386/opt/astap
cd /home/h/astap_install
sudo fakeroot dpkg-deb -Zxz --build /home/h/astap_install/astap_i386



#build aarch64
rm ~/astap.fpc/astap 
/home/h/fpcupdeluxe/lazarus/lazbuild /home/h/astap.fpc/astap_linux_aarch64.lpi                  
if [[ ! -f ~/astap.fpc/astap ]] ; then
    echo 'aarch64 file does not exist, aborting!!'
    exit
fi
cp /home/h/astap.fpc/astap /home/h/astap_install/astap_aarch64/opt/astap
cd /home/h/astap_install
sudo fakeroot dpkg-deb -Zxz --build /home/h/astap_install/astap_aarch64
sudo cp /home/h/astap.fpc/astap /opt/astap
sudo cp /home/h/astap_install/astap_aarch64/opt/astap/unprocessed_raw-astap /opt/astap
tar -czvf astap_aarch64.tar.gz /opt/astap/astap   /opt/astap/astap.ico /opt/astap/*.txt /opt/astap/deep_sky.csv /opt/astap/variable_stars.csv /usr/share/applications/ASTAP.desktop  /opt/astap/unprocessed_raw-astap
#build aarch64 qt5
rm ~/astap.fpc/astap 
/home/h/fpcupdeluxe/lazarus/lazbuild /home/h/astap.fpc/astap_linux_aarch64_qt5.lpi
if [[ ! -f ~/astap.fpc/astap ]] ; then
    echo 'aarch64 qt5 file does not exist, aborting!!'
    exit
fi
sudo cp /home/h/astap.fpc/astap /opt/astap
tar -czvf astap_aarch64_qt5.tar.gz /opt/astap/astap   /opt/astap/astap.ico /opt/astap/*.txt /opt/astap/deep_sky.csv /opt/astap/variable_stars.csv /usr/share/applications/ASTAP.desktop  /opt/astap/unprocessed_raw-astap


# read -p "Press any key to resume ..."

#build armhf
#use old compiler. New one has problems with triplets routine
rm ~/astap.fpc/astap 
/home/h/fpcupdeluxe_stable/lazarus/lazbuild /home/h/astap.fpc/astap_linux_armhf.lpi 
if [[ ! -f ~/astap.fpc/astap ]] ; then
    echo 'armhf file does not exist, aborting!!'
    exit
fi 
               
cp /home/h/astap.fpc/astap /home/h/astap_install/astap_armhf/opt/astap
cd /home/h/astap_install
sudo fakeroot dpkg-deb -Zxz --build /home/h/astap_install/astap_armhf
sudo cp /home/h/astap.fpc/astap /opt/astap
sudo cp /home/h/astap_install/astap_armhf/opt/astap/unprocessed_raw-astap /opt/astap
# not dcraw-astap
tar -czvf astap_armhf.tar.gz /opt/astap/astap   /opt/astap/astap.ico /opt/astap/*.txt /opt/astap/deep_sky.csv /opt/astap/variable_stars.csv /usr/share/applications/ASTAP.desktop  /opt/astap/unprocessed_raw-astap
#build armhf qt5
#use old compiler. New one has problems with triplets routine
rm ~/astap.fpc/astap 
/home/h/fpcupdeluxe_stable/lazarus/lazbuild /home/h/astap.fpc/astap_linux_armhf_qt5.lpi 
if [[ ! -f ~/astap.fpc/astap ]] ; then
    echo 'armhf qt5 file does not exist, aborting!!'
    exit
fi 
sudo cp /home/h/astap.fpc/astap /opt/astap
tar -czvf astap_armhf_qt5.tar.gz /opt/astap/astap   /opt/astap/astap.ico /opt/astap/*.txt /opt/astap/deep_sky.csv /opt/astap/variable_stars.csv /usr/share/applications/ASTAP.desktop  /opt/astap/unprocessed_raw-astap


rm ~/astap.fpc/astap                                     
/home/h/fpcupdeluxe/lazarus/lazbuild /home/h/astap.fpc/astap_linux_cross_compile_to_Darwin_M1.lpi
if [[ ! -f ~/astap.fpc/astap ]] ; then
    echo 'macos M1 file does not exist, aborting!!'
    exit
fi 
zip astap_mac_M1.zip /home/h/astap.fpc/astap

rm ~/astap.fpc/astap  
/home/h/fpcupdeluxe/lazarus/lazbuild /home/h/astap.fpc/astap_linux_cross_compile_to_Darwin_X86_64.lpi

zip astap_mac_X86_64.zip /home/h/astap.fpc/astap
if [[ ! -f ~/astap.fpc/astap ]] ; then
    echo 'macos file does not exist, aborting!!'
    exit
fi 
#restore amd64 installation
sudo dpkg -i ./astap_amd64.deb

