How to compile ASTAP:

1) Install Lazurus  (this will also install Free Pascal Compiler)


2a) Start Lazarus GUI.  Load astap.lpi or astap_linux.lip or astap_mac.lpi. Menu Run, Run or Compile

2b) Command line:

  Windows: 
     lazbuild -B astap.lpi

  Linux:  
    lazbuild -B astap_linux.lpi

  Linux, PIE executable that you can run only via a terminal or a symlink:  
     lazbuild -B astap_linux_pie.lpi

  Mac:  
     lazbuild -B astap_mac.lpi

To include package Synape, just load ./synapse/laz_synapse.lpk packagein the editor of Lazarus.  The astap.lpi and compile.

-----------------------------------------------------------------------------------------------------------------------------------
Notes:

Linux QT5 widget:

Using your distros repository -

    Fedora, Mageia - sudo dnf install qt5pas<enter>
    Ubuntu, Debian - sudo apt install libqt5pas1 <enter>

    lazbuild -B astap_linux_qt5.lpi

See:
  https://wiki.lazarus.freepascal.org/Qt5_Interface


