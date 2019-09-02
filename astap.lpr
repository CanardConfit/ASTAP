program astap;

{$MODE Delphi}

uses
  Forms, Interfaces,
  astap_main in 'astap_main.pas' {mainwindow},
  unit_stack in 'unit_stack.pas' {stackmenu1},
  unit_tiff in 'unit_tiff.pas',
  unit_astrometry in 'unit_astrometry.pas',
  unit_gaussian_blur in 'unit_gaussian_blur.pas',
  unit_thumbnail in 'unit_thumbnail.pas';

{mainwindow}

{$R *.res}
begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tmainwindow, mainwindow);
  Application.CreateForm(Tstackmenu1, stackmenu1);
  Application.Run;
 end.
