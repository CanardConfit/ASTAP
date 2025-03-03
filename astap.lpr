program astap;

{$MODE Delphi}

uses
  {$ifdef unix}
    cthreads, // https://wiki.lazarus.freepascal.org/Multithreaded_Application_Tutorial
    cmem, // the c memory manager is on some systems much faster for multi-threading
  {$endif}
  forms, Interfaces,
  astap_main in 'astap_main.pas', {mainwindow}
  unit_stack; {stackmenu1}
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
