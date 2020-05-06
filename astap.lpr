program astap;

{$MODE Delphi}

uses
  Forms, Interfaces,
  astap_main in 'astap_main.pas' {mainwindow},
  unit_stack in 'unit_stack.pas' {stackmenu1},
  unit_tiff in 'unit_tiff.pas',
  unit_gaussian_blur in 'unit_gaussian_blur.pas',
  unit_thumbnail in 'unit_thumbnail.pas';
//  unit_astrometry_net in 'unit_astrometry_net';

{mainwindow}

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tmainwindow, mainwindow);
  Application.CreateForm(Tstackmenu1, stackmenu1);
  Application.Run;
 end.
