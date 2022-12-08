/home/h/fpcupdeluxe/lazarus/lazbuild ~/astap.fpc/astap_linux.lpi

cp ~/astap.fpc/astap ~/astap_install/astap_amd64/opt/astap
cd ~/astap_install
sudo rm *.rpm
sudo fakeroot dpkg-deb --build ~/astap_install/astap_amd64
sudo ~/alien/alien-8.95/alien.pl -r -c -k  ~/astap_install/astap_amd64.deb
cp *.rpm astap_amd64.rpm


sudo dpkg -i ./astap_amd64.deb
tar -czvf astap_amd64.tar.gz /opt/astap/astap  /opt/astap/astap.ico /opt/astap/astap.ico /opt/astap/copyright.txt /opt/astap/deep_sky.csv /opt/astap/variable_stars.csv /usr/share/applications/ASTAP.desktop /usr/local/bin/astap /opt/astap/dcraw-astap /opt/astap/unprocessed_raw-astap


/home/h/fpcupdeluxe/lazarus/lazbuild ~/astap.fpc/astap_linux_qt5.lpi
sudo cp ~/astap.fpc/astap /opt/astap
tar -czvf astap_amd64_qt5.tar.gz /opt/astap/astap  /opt/astap/astap.ico /opt/astap/astap.ico /opt/astap/copyright.txt /opt/astap/deep_sky.csv /opt/astap/variable_stars.csv /usr/share/applications/ASTAP.desktop /usr/local/bin/astap /opt/astap/dcraw-astap /opt/astap/unprocessed_raw-astap


/home/h/fpcupdeluxe/lazarus/lazbuild ~/astap.fpc/astap_linux_cross_compile_to_Darwin_M1.lpi
sudo cp ~/astap.fpc/astap
zip astap_mac_M1.zip ~/astap.fpc/astap

 
/home/h/fpcupdeluxe/lazarus/lazbuild ~/astap.fpc/astap_linux_cross_compile_to_Darwin_X86_64.lpi
sudo cp ~/astap.fpc/astap
zip astap_mac_X86_64.zip ~/astap.fpc/astap
