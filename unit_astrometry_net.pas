unit unit_astrometry_net;
{Copyright (C) 2017, 2021 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, strutils,
  astap_main, unit_stack;


type

  { Tform_astrometry_net1 }

  Tform_astrometry_net1 = class(TForm)
    astrometry_extra_options1: TComboBox;
    Button1: TButton;
    cygwin1: TComboBox;
    keep_console_open1: TCheckBox;
    failed1: TLabel;
    fileprocessed1: TLabel;
    Label1: TLabel;
    solved1: TLabel;
    Label22: TLabel;
    show_console1: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure cygwin1Change(Sender: TObject);
    procedure cygwin1DropDown(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  form_astrometry_net1: Tform_astrometry_net1;

const
  cygwin_path: string='';
  astrometry_extra_options : string='--downsample 2';
  show_console : boolean=true;
  keep_console_open : boolean=false;

function astrometry_net(filename3: string; remove_tmp, showconsole, keep_open: boolean) :boolean;{use local astrometry.net}


implementation
{$R *.lfm}
procedure DeleteFiles(lpath,FileSpec: string);{delete files such  *.wcs}
var
  lSearchRec:TSearchRec;
begin
// lPath := IncludeTrailingPathDelimiter(lPath);
  if FindFirst(lpath+FileSpec,faAnyFile,lSearchRec) = 0 then
  begin
    try
      repeat
        SysUtils.DeleteFile(lPath+lSearchRec.Name);
      until SysUtils.FindNext(lSearchRec) <> 0;
    finally
      SysUtils.FindClose(lSearchRec);  // Free resources on successful find
    end;
  end;
end;

//'C:\cygwin\bin\bash.exe'
//'--login-c" solve-field  --overwrite --scale-low 2.43250219767136 --scale-high 2.97305824159833 --scale-units  arcsecperpix  --objs 150 --downsample 4 --no-plots  --no-fits2fits ""C:/Users/H/AppData/Local/ccdciel/tmp/ccdcieltmp.fits"" "'
//'--login-c" solve-field  --overwrite --scale-low 2.43250219767136 --scale-high 2.97305824159833 --scale-units  arcsecperpix  --objs 150 --downsample 4 --no-plots  --no-fits2fits ""C:/Users/H/AppData/Local/ccdciel/tmp/ccdcieltmp.fits"" "'

//http://manpages.ubuntu.com/manpages/zesty/man1/solve-field.1.html
//       -3 RA, --ra RA
//              RA of field center for search, format: degrees or hh:mm:ss

//       -4 DEC, --dec DEC
//              DEC of field center for search, format: degrees or hh:mm:ss
//  -5 degrees, --radius degrees
//              Only search in indexes within 'radius' of the field center given
//              by --ra and --dec

//  -2, --no-fits2fits
//              Don't sanitize FITS files; assume they're already valid
//
//       -L, --scale-low scale
//              Lower bound of image scale estimate
//
//       -H, --scale-high scale
//              Upper bound of image scale estimate

//  -u, --scale-units units
//              In what units are the lower and upper bounds? Choices:
//
//              "degwidth", "degw", "dw"
//                     width of the image, in degrees (default)
//
//              "arcminwidth", "amw", "aw"
//                     width of the image, in arcminutes
//
//              "arcsecperpix", "app"
//                     arcseconds per pixel


function astrometry_net(filename3: string; remove_tmp, showconsole, keep_open: boolean) :boolean;{use local astrometry.net}
var
   filename_new,filename_linux,filename_bak,param: string;
   paramlist     : TStringList;
   fpath         : string;
begin

  result:=false;

  mainwindow.caption:='Solving: '+ExtractFileName(filename3);

  fpath:=ExtractFilePath(filename3);
  {$ifdef mswindows}
  if FileExists(form_astrometry_net1.cygwin1.text)=false then
  begin
     application.messagebox(pchar('Can'+#39+'t find local astrometry.net program. Check path or installation.'),pchar('No local astrometry.net'), 0);
     exit
  end;
  {$else} {unix}
  if FileExists(form_astrometry_net1.cygwin1.text+'/solve-field')=false then
  begin
     application.messagebox(pchar('Can'+#39+'t find local astrometry.net program solve-field. Check path or installation.'),pchar('No local astrometry.net'), 0);
     exit
  end;
  {$endif}

  filename_new:=changeFileExt(filename3,'.new');
  filename_bak:=changeFileExt(filename3,'.bak');
  filename_linux:=StringReplace(filename3,'\','/',[rfReplaceAll]);

  paramlist:= TStringList.Create;
  paramlist.QuoteChar := #0;

  paramlist.add('--overwrite'); {overwrite}
  paramlist.add('--no-plots'); {no plots}

//  if make_new=false then begin
//      paramlist.add('--new-fits');{no .new file}
//      paramlist.add('none');
//    end;

//    if stackmenu1.limit_pixelsize1.checked then
//    begin
//      paramlist.add('--scale-units');{scale-units arcsecperpix}
//      paramlist.add('arcsecperpix');
//      paramlist.add('--scale-low');{scale-low in arcsecperpix}
//      paramlist.add(floattostr6(scale*0.9));
//      paramlist.add('--scale-high');{scale-high in arcsecperpix}
//      paramlist.add(floattostr6(scale*1.1));
//    end;

//    if stackmenu1.limit_area1.checked then
//    begin
//      paramlist.add('--ra');
//      paramlist.add(floattostr6(ra_radians*180/pi));
//      paramlist.add('--dec');
//      paramlist.add(floattostr6(dec_radians*180/pi));
//      paramlist.add('--radius');{radius}
//      paramlist.add(stackmenu1.search_area1.text);
//    end;

    {get the extra parameters from the user}
     ExtractStrings([' '], [], PChar(form_astrometry_net1.astrometry_extra_options1.text),paramlist);

  {$ifdef mswindows}
  param:=stringreplace(paramlist.delimitedtext,',',' ',[rfReplaceAll]);
  param:=stringreplace(param,'"','',[rfReplaceAll]); { paramlist.QuoteChar :=#0 doesn't work always}

  if pos('System32',form_astrometry_net1.cygwin1.text)=0 then {Cygwin solver}
  begin
    if keep_open then ExecuteAndWait('cmd.exe /k '+form_astrometry_net1.cygwin1.text+' --login solve-field "'+filename_linux+'" '+param,showconsole){execute command and wait}
    else
    ExecuteAndWait(form_astrometry_net1.cygwin1.text+' --login solve-field "'+filename_linux+'" '+param,showconsole);{execute command and wait}
  end
  else
  begin {win10 Linux subsystem solver}
    //   C:\Windows\System32\bash.exe -c "solve-field /mnt/c/astap.fpc/_M95_test_image.fit --overwrite --downsample 4"
    // 'C:/astap.fpc/_M95_test_image.fit'
    filename_linux:='/mnt/'+lowercase(copy(filename_linux,1,1))+copy(filename_linux,3,255);{drive should be lowercase}

    if keep_open then ExecuteAndWait('cmd.exe /k '+form_astrometry_net1.cygwin1.text+' -c "solve-field '+#39+filename_linux+#39+' '+param+'"',showconsole){execute command and wait}
    else
                      ExecuteAndWait(              form_astrometry_net1.cygwin1.text+' -c "solve-field '+#39+filename_linux+#39+' '+param+'"',showconsole);{execute command and wait}
  end;

  {$else} {unix}

  paramlist.insert(0,filename3);
//param.Add('"--overwrite --no-plots --objs 150 --downsample 4 --ra 300.000000 --dec 40.410216 --radius 10"');
   execute_unix(form_astrometry_net1.cygwin1.text+'/solve-field',paramlist, showconsole);
  {$endif}
  paramlist.Free;

  Application.ProcessMessages;

  if fileexists(filename_new) then
  begin
    wait(500);{smart sleep}
    deletefile(filename_bak);{delete otherwise next rename is not possible}
    if renamefile(filename3,filename_bak) then
    begin
       renamefile(filename_new,filename3) ;
       result:=true;
    end;
  end;

  if remove_tmp then
  begin
     Application.ProcessMessages;
    try
      DeleteFiles(fPath,'*.wcs');
      DeleteFiles(fPath,'*.corr');{delete with wildcard all since files are sometimes not yet available and delete them next time}
      DeleteFiles(fPath,'*.match');
      DeleteFiles(fPath,'*.rdls');
      DeleteFiles(fPath,'*.solved');
      DeleteFiles(fPath,'*.axy');
      DeleteFiles(fPath,'*.xyls');
    finally
    end;
  end;

  form_astrometry_net1.close;   {normal this form is not loaded}
  mainwindow.setfocus;
end;

{ Tform_astrometry_net1 }

procedure Tform_astrometry_net1.Button1Click(Sender: TObject);
var
  I: integer;
  Save_Cursor:TCursor;
  failed, solved :integer;
begin
  show_console:=show_console1.checked;
  keep_console_open:=keep_console_open1.checked;
  cygwin_path:=cygwin1.text;
  astrometry_extra_options:=astrometry_extra_options1.text;

  save_settings2;

  mainwindow.OpenDialog1.Title := 'Select multiple  files to add astrometric solution';
  mainwindow.OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist,ofHideReadOnly];
  mainwindow.opendialog1.Filter := '8, 16 and -32 bit FITS files (*.fit*)|*.fit;*.fits;*.FIT;*.FITS';
  esc_pressed:=false;

  failed:=0;
  solved:=0;

  if mainwindow.OpenDialog1.Execute then
  begin
    Save_Cursor := Screen.Cursor;
    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    try { Do some lengthy operation }
        with mainwindow.OpenDialog1.Files do
        for I := 0 to Count - 1 do
        begin
          filename2:=Strings[I];
          fileprocessed1.caption:='Solving '+inttostr(i)+'-'+inttostr(Count-1)+': '+filename2;
          progress_indicator(100*i/(count),' Solving');{show progress}

          Application.ProcessMessages;
          if esc_pressed then
          begin
            Screen.Cursor := Save_Cursor;
            exit;
          end;
          if astrometry_net(filename2,true {remove_tmp},show_console,keep_console_open) then
             begin inc(solved); solved1.caption:= 'Solved: '+inttostr(solved); memo2_message('Solved: '+filename2);    end
          else
             begin inc(failed); failed1.caption:= 'Failed: '+inttostr(failed);memo2_message('Failed: '+filename2); end
        end;
      finally
      progress_indicator(-100,'');{progresss done}
      Screen.Cursor := Save_Cursor;  { Always restore to normal }
    end;
  end;
end;

procedure Tform_astrometry_net1.cygwin1Change(Sender: TObject);
begin
  if fileexists({$ifdef mswindows} cygwin1.text {$else} {unix} cygwin1.text+'/solve-field' {$endif} ) then
    cygwin1.color:=$AAFFAA {green} else cygwin1.color:=$AAAAFF;{red}
end;

procedure Tform_astrometry_net1.cygwin1DropDown(Sender: TObject);
var u_path : string;
    i   : integer;
begin

  {$ifdef mswindows}
  u_path:=GetUserDir;
  for i:=0 to cygwin1.Items.count-1 do {replace by correct user name}
    cygwin1.Items[i]:=stringreplace(cygwin1.Items[i],'C:\Users\user_name\',u_path,[rfIgnoreCase]);
  {$ELSE}{linux}
  {$endif}
end;

procedure Tform_astrometry_net1.FormKeyPress(Sender: TObject; var Key: char);
begin {set form keypreview:=on}
  if key=#27 then
  begin
    esc_pressed:=true;
  end;
end;

procedure Tform_astrometry_net1.FormShow(Sender: TObject);
begin
  show_console1.checked:=show_console;
  keep_console_open1.checked:= keep_console_open;
  cygwin1.text:=cygwin_path;
  astrometry_extra_options1.text:=astrometry_extra_options;
end;

end.

