program astap;

{$MODE Delphi}

uses
  Forms, Interfaces,
  astap_main in 'astap_main.pas', {mainwindow}
  unit_stack in 'unit_stack.pas'; {stackmenu1}
  {other units are linked to this two units}

{mainwindow}

{$R *.res}
begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tmainwindow, mainwindow);
  Application.CreateForm(Tstackmenu1, stackmenu1);
  Application.Run;
 end.
