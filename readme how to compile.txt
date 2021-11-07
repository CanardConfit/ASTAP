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


