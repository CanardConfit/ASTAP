How to compile ASTAP:

1) Install Lazarus from https://sourceforge.net/projects/lazarus/       (this will also install Free Pascal Compiler)


2a) Start Lazarus GUI.  Load astap.lpi or astap_linux.lip or astap_mac.lpi. Menu Run, Run or Compile

2b) Command line:

  Windows: 
     lazbuild -B astap_command_line.lpi

  Linux:  
    lazbuild -B astap_command_line.lpi

  Linux, PIE executable that you can run only via a terminal or a symlink:  
     lazbuild -B astap_command_line_linux_pie.lpi

  Mac:  
     lazbuild -B astap_command_line.lpi


