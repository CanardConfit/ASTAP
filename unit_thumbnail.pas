unit unit_thumbnail; {FPC unit, shows FITS images as thumbnails (3*X)in a form using Timages. Form is fully resizable and thumbnails (Timage) will follow using the Timage stretch function}
{$mode delphi}
{Copyright (C) 2018 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Menus;

type

  { Tthumbnails1 }

  Tthumbnails1 = class(TForm)
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    renameimage1: TMenuItem;
    changedirectory1: TMenuItem;
    MenuItem5: TMenuItem;
    copyto1: TMenuItem;
    moveto1: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    procedure copyto1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure moveto1Click(Sender: TObject);
    procedure renameimage1Click(Sender: TObject);
    procedure changedirectory1Click(Sender: TObject);
  private
    procedure imageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);{generic for all Timages}
    procedure imageMouseMove(Sender: TObject; Shift: TShiftState; X,  Y: Integer);{generic for all Timages}
  public
  end;

var
  thumbnails1: Tthumbnails1;
  chosenDirectory : string;
const
   thumbnails1_width: integer=1500;{default}
   thumbnails1_height: integer=700;


procedure plot_thumbnails; {plot images in new created timage}
 {plot images in new created timage}

implementation

uses astap_main;

var
  imageindex: integer;
  image_sender: tobject;
  Myimages : Array of Timage;
{$R *.lfm}

procedure plot_thumbnails; {plot images in new created timage}
var
    newimage : timage;
    x,y,max_height:integer;
    searchResult : TSearchRec;
const
    nrimages: integer =100;
begin
  esc_pressed:=false;
  imageindex:=0;
  x:=0;
  y:=0;
  setlength(Myimages,nrimages);
  thumbnails1.panel1.width:=thumbnails1.width-25;
  thumbnails1.panel1.height:=thumbnails1.height*2;
  max_height:=0;
  if findfirst(chosenDirectory+PathDelim+'*.fit*', faAnyFile, searchResult) = 0 then
  begin
    repeat
      newImage := TImage.Create(thumbnails1.panel1);
      Inc(imageIndex);
      if imageindex>=nrimages then
      begin
        nrimages:=nrimages+30;
        setlength(Myimages,nrimages);
     end;
      with thumbnails1.panel1 do
      begin
        newimage.parent:=thumbnails1.panel1;
        newImage.Tag := imageIndex;
        newImage.Name := 'Thumb_Image' + IntToStr(imageIndex);
        newImage.Visible := True;

        filename2:= chosenDirectory+PathDelim+searchResult.Name;
        thumbnails1.caption:=filename2;{show whats happening}
        load_fits(filename2,false {light},true,true {update memo},0,head,img_loaded);
        if head.naxis<2 then exit; {WCS file}
        use_histogram(img_loaded,true {update}); {plot histogram, set sliders}
        plot_fits(newimage,false,true);     {mainwindow.image1.Visible:=true; is done in plot_fits}

        newImage.Width := round((thumbnails1.panel1.width-2)/3);
        newImage.height := round(newImage.Width* newImage.picture.Bitmap.height/newImage.picture.Bitmap.width);
        if newImage.height>max_height then max_height:=newImage.height;{find largest heigth}

        thumbnails1.VertScrollBar.Increment:=max_height;

        newImage.left :=x;
        newImage.top := y;
        inc(x,newImage.Width+1);
        if x+1>=thumbnails1.panel1.width then {new row}
        begin
          x:=0;
          y:=y+max_height+1;
          max_height:=0;
        end;
        newImage.hint := filename2; //inttostr(imageindex);
        newimage.OnMouseDown:= thumbnails1.imageMouseDown;
        newimage.onMouseMove:=thumbnails1.imageMouseMove;
        newImage.showhint := true;
        newImage.stretch := true;
        myimages[imageIndex-1]:=newimage;{store the timage}
        application.processmessages;
      end;
    until ((FindNext(searchResult) <> 0) or (esc_pressed));

    // Must free up resources used by these successful finds
    FindClose(searchResult);
  end;
  thumbnails1.panel1.height:=y+max_height; {causes a repaint}

end;

procedure Tthumbnails1.FormShow(Sender: TObject);
begin
  thumbnails1.width:=thumbnails1_width;
  thumbnails1.height:=thumbnails1_height;
end;

procedure Tthumbnails1.MenuItem1Click(Sender: TObject);
begin
  {filename2 is set in Tthumbnails1.ImageMouseDown}
  thumbnails1.close;
  load_image(true,true {plot});
end;

procedure Tthumbnails1.ImageMouseDown(Sender: TObject; Button: TMouseButton;{generic for all Timages}
  Shift: TShiftState; X, Y: Integer);
var
   hint : string;
begin
  hint:=TControl(Sender).hint;
  filename2:=hint;

  image_sender:=sender;

  if button=mbright then
   {$ifdef fpc}
   PopupMenu1.PopUp;{call popup manually if right key is released, not when clicked. Set in popupmenu autopopup off !!!}
   {$else} {delphi}
   PopupMenu1.PopUp(x,y);{call popup manually if right key is released, not when clicked. Set in popupmenu autopopup off !!!}
   {$endif}

   if button=mbleft then
   begin
     thumbnails1.close;
     load_image(true,true {plot});
   end;

end;

procedure Tthumbnails1.MenuItem2Click(Sender: TObject);
var
  filename_new: string;
begin
  {filename2 is set in Tthumbnails1.ImageMouseDown}
  deletefile(changeFileExt(filename2,'.bak'));{delete *.bak left over from astrometric solution}
  filename_new:=ChangeFileExt(filename2,'.bak');
  RenameFile(filename2,filename_new);
  TControl(image_sender).width:=20;{make very small indicating renamed}
  TControl(image_sender).height:=20;
  TControl(image_sender).hint:=filename_new;
end;

procedure Tthumbnails1.moveto1Click(Sender: TObject);
begin

end;



procedure Tthumbnails1.renameimage1Click(Sender: TObject);
var
   value: string;
begin

  value:=InputBox('New name:','',filename2);
  if value=''  then exit;
  RenameFile(filename2,value);
end;

procedure Tthumbnails1.changedirectory1Click(Sender: TObject);
var i: integer;
begin
  if SelectDirectory('Select a directory', ExtractFileDir(filename2){initialdir} , chosenDirectory) then
  begin
    for i:=0 to imageindex-1 do  {resize images}
      begin
        with Myimages[i] do  {contains the Timages}
        begin
          free;
        end;

      end;
    plot_thumbnails;{load new thumnails}
  end;
end;

procedure Tthumbnails1.imageMouseMove(Sender: TObject; Shift: TShiftState; X,  Y: Integer);{generic for all Timages}
begin
  thumbnails1.caption:=TControl(Sender).hint;;{copy hint}
end;

procedure Tthumbnails1.FormPaint(Sender: TObject);
begin
  if imageindex=0 then  plot_thumbnails;
end;

procedure Tthumbnails1.FormKeyPress(Sender: TObject; var Key: char);
begin
   if key=#27 then
   begin
     esc_pressed:=true;
     thumbnails1.caption:='ESC pressed, stopped reading images.';
   end;
end;

procedure Tthumbnails1.FormCreate(Sender: TObject);
begin
  imageindex:=0;
end;

procedure Tthumbnails1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  thumbnails1_width:=thumbnails1.width; {remember}
  thumbnails1_height:=thumbnails1.height;
end;

procedure Tthumbnails1.copyto1Click(Sender: TObject);
var
  path2,destname : string;
  OK: Boolean;
begin
   {filename2 is set in Tthumbnails1.ImageMouseDown}
   if SelectDirectory('Select a directory', ExtractFileDir(filename2){initialdir} , path2) then
   begin
      destname:= path2+PathDelim+ExtractFilename(filename2);
      if destname=filename2 then
        ShowMessage('Abort!, source and destination are the same.')
      else
      begin
        if not FileExists(DestName) or  //only copy if the file does not exists yet, or the user accepts overwriting the existig one
        (MessageDlg('File exists: overwrite?',mtConfirmation,[mbYes,mbNo],0) = mrYes) then
        begin
          //try to copy/move the file
          if sender=copyto1 then OK := CopyFile(filename2,destname , [cffPreserveTime, cffOverwriteFile])
          else
          if sender=moveto1 then OK := renameFile(filename2,destname) {move the file to a diffent location by renaming}
          else
          ok:=false;{should never happen, programmers failure}

          if not OK then ShowMessage('Write error!!');
        end;
      end;
   end;
end;

procedure Tthumbnails1.FormResize(Sender: TObject);
var
   x,y,max_height,i,ww: integer;
begin
  if imageindex=0 then exit;
  thumbnails1.panel1.width:=thumbnails1.width-25;
  x:=0;
  y:=0;
  max_height:=0;

  for i:=0 to imageindex-1 do  {resize images}
  begin
    with Myimages[i] do  {contains the Timages}
    begin
       Width := round((thumbnails1.panel1.width-2)/3);
       height := round(Width* picture.Bitmap.height/picture.Bitmap.width);
       if height>max_height then max_height:=height;{find largest heigth}
       thumbnails1.VertScrollBar.Increment:=max_height;

       left :=x;
       top := y;
       inc(x,Width+1);
       if x+1>=thumbnails1.panel1.width then {new row}
       begin
         x:=0;
         y:=y+max_height+1;
         max_height:=0;
       end;
      thumbnails1.panel1.height:=y+max_height;
    end;
  end;
end;

end.


