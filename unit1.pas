unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,math;

type
  TForm1 = class(TForm)
  private

  public

  end;

var
  Form1: TForm1;

implementation
var x,y,z,a :double;

{$R *.lfm}
begin
x:=frac(-1.1);
y:=frac(1.1);
z:=trunc(-1.1);
a:=trunc(1.1);
beep;
end.

