program astap;

{$mode objfpc}{$H+}
uses
  {$ifdef unix}
  cthreads, // https://wiki.lazarus.freepascal.org/Multithreaded_Application_Tutorial
  {$endif}
  forms, Interfaces,
  astap_main in 'astap_main.pas', {mainform1}
  unit_stack; {stackmenu1}
  {other units are linked to this two units}

{mainform1}

{$R *.res}
begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tmainform1, mainform1);
  Application.CreateForm(Tstackmenu1, stackmenu1);
  Application.Run;
 end.
