unit unit_listbox;
{ On-screen keyboard with find object data function}
{ interface via global variables.}
{ Key functionality:
      ESC   --> close form with object_found=false

      Enter --> find object, if not found show list of designations containing the input string
                 e.g. ngc2024   leave form with ngc2024 data. Object_found=true
                      ngc       list all NGC objects
                      ngc 2024  list ngc2024 in the list
                      ngc10     leave form with ngc10 data. Object_found=true
                      ngc 10    list all objects containing ngc10 as ngc100, ngc1000, ngc1001...
                      ngc10*    list all objects containing ngc10 as ngc100, ngc1000, ngc1001...

      close form -->  2024      leave form with ngc2024 data if ngc was selected. Object_found=true
                      ngc2024   leave form with ngc2024 data. Object_found=true
                      abcdef    leave form with abcdef designation. Object_found=false
}

{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  unit_annotation {for deepsky database search};

type
  {Tform_listbox1 }
  Tform_listbox1 = class(TForm)
    cancel1: TBitBtn;
    ok1: TButton;
    keyboard_question1: TLabel;
    ListBox1: TListBox;
    Edit1: TEdit;
    procedure cancel1Click(Sender: TObject);
    procedure ok1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
  private

  public

  end;

var
  form_listbox1: Tform_listbox1;

  {global variables as interface}
  keyboard_text : string;
  object_found  : boolean;
  ra_data,dec_data, length_data, width_data, pa_data  :   double;

implementation

{$R *.lfm}

{ Tform_listbox1 }


procedure Tform_listbox1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  dummy : double;
  error2: integer;
begin
  if object_found=false then {form was closed by user. Initiate find action}
  begin
    keyboard_text:=edit1.text;
    object_found:=find_object(keyboard_text ,ra_data,dec_data,length_data,width_data,pa_data);{keyboard_text with length less then 2 will be ignored}
  end;
end;

procedure Tform_listbox1.FormKeyPress(Sender: TObject; var Key: char);
begin
  if key=#27 {esc  } then form_listbox1.close; {leave form}
  if key=#13 {enter} then ok1click(Sender); {enter}
end;

procedure Tform_listbox1.FormShow(Sender: TObject);
begin
  object_found:=false;
  edit1.text:=keyboard_text;
end;


procedure Tform_listbox1.ListBox1Click(Sender: TObject);
begin
  if  (listbox1.itemindex)>=0 then {prevent error if nothing is selected}
  edit1.text:=listbox1.Items[listbox1.itemindex];{copy selection to edit }
end;

procedure Tform_listbox1.ListBox1DblClick(Sender: TObject);
begin
  if (listbox1.itemindex)>=0 then {prevent error if nothing is selected}
  begin
    keyboard_text:=listbox1.Items[listbox1.itemindex];{copy selection to edit }
    if find_object(keyboard_text ,ra_data,dec_data,length_data,width_data,pa_data) {find object in unit u_annotation} then
    begin
      object_found:=true;
      form_listbox1.close;
    end
  end;
end;


procedure fill_listbox(filterstr: string); {fill listbox with destinations containing the filterstr}
var
  ra0,dec0,length0,width0,pa    : double;  {dummies, not used}
begin
  load_deep;{Load the deepsky database once. If already loaded, no action}
  linepos:=2;{Set pointer to the beginning}
   with form_listbox1 do
  begin
    if length(filterstr)>1 then
    begin
      listbox1.Clear; { empty the list of any old values }
      repeat
        read_deepsky('T' {full database search} ,0 {ra},0 {dec},1 {cos(telescope_dec)},2*pi{fov},{var} ra0,dec0,length0,width0,pa);{Deepsky database search}
        if ((length(filterstr)=0) or (pos(filterstr,uppercase(naam2))>0)) then
          listbox1.Items.Add(naam2);
        if ((length(naam3)>0)  and (((length(filterstr)=0) or (pos(filterstr,uppercase(naam3))>0)))) then
          listbox1.Items.Add(naam3);
        if ((length(naam4)>0)  and (((length(filterstr)=0) or (pos(filterstr,uppercase(naam4))>0)))) then
          listbox1.Items.Add(naam4);
      until (linepos>=$FFFFFF);{Found object or end of database} ;
      edit1.text:='';{clear filtering}

      ActiveControl:=listbox1;{set focus on listbox1 text window}
    end;
  end;
end;


procedure Tform_listbox1.ok1Click(Sender: TObject);
var
  oldCursor : TCursor;
begin
  oldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  keyboard_text:=edit1.text;
  if find_object(keyboard_text ,ra_data,dec_data,length_data,width_data,pa_data) {find object in unit u_annotation} then
  begin
    object_found:=true;
    form_listbox1.close;
  end
  else
  begin {keyboard_text with length less then 2 or not found}
    keyboard_text:=StringReplace(uppercase(keyboard_text), ' ', '',[rfReplaceAll]);{replace all space and make upcase}
    keyboard_text:=StringReplace(keyboard_text, '*', '',[rfReplaceAll]);{remove wildchard}
    fill_listbox(keyboard_text);{fill listbox with suggestions}
  end;
  Screen.Cursor := oldCursor;
end;


procedure Tform_listbox1.cancel1Click(Sender: TObject);
begin
  object_found:=false;
  form_listbox1.close;
end;

end.

