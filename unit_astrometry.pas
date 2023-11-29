unit unit_astrometry;
{Copyright (C) 2017,2018 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/. }


interface
uses
  Forms,SysUtils,strutils,Classes, {tstringlist}astap_main,unit_stack;


function astrometry_net(filename3: string;make_new,update_header, remove_tmp, show_console, keep_open: boolean) :boolean;{use local astrometry.net}

implementation

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


function astrometry_net(filename3: string;make_new,update_header, remove_tmp, show_console, keep_open: boolean) :boolean;{use local astrometry.net}
var
   filename_wcs, filename_new,param: string;
   scale         : double;
   paramlist     : TStringList;
   fpath         : string;
begin

  result:=false;

  mainwindow.caption:='Solving: '+ExtractFileName(filename3);

  fpath:=ExtractFilePath(filename3);
  {$ifdef mswindows}
  if FileExists(stackmenu1.cygwin1.text)=false then
  begin
     application.messagebox(pchar('Can'+#39+'t find local astrometry.net program. Check path or installation.'),pchar('No local astrometry.net'), 0);
     exit
  end;
  {$else} {unix}
  if FileExists(stackmenu1.cygwin1.text+'/solve-field')=false then
  begin
     application.messagebox(pchar('Can'+#39+'t find local astrometry.net program solve-field. Check path or installation.'),pchar('No local astrometry.net'), 0);
     exit
  end;
  {$endif}

  if cdelt2<>0 then scale:=cdelt2*3600 {arcsec per pixel}
    else
    if cdelt1<>0 then scale:=cdelt1*3600 {from scale in header}
    else
    scale:=calc_scale; {from focal length and sensor pixel size in arcsec per pixel}

    filename_wcs:=changeFileExt(filename3,'.wcs');
    filename_new:=changeFileExt(filename3,'.new');
    filename3:=StringReplace(filename3,'\','/',[rfReplaceAll]);

    paramlist:= TStringList.Create;
    paramlist.QuoteChar := #0;

    paramlist.add('--overwrite'); {overwrite}
    paramlist.add('--no-plots'); {no plots}
  //  paramlist.add('--no-fits2fits'); {no fits check}{this option moved to adjustable parameters since no longer available in newer astrometry.net versions like 0.73}

  if make_new=false then begin
      paramlist.add('--new-fits');{no .new file}
      paramlist.add('none');
    end;

    if stackmenu1.limit_pixelsize1.checked then
    begin
      paramlist.add('--scale-units');{scale-units arcsecperpix}
      paramlist.add('arcsecperpix');
      paramlist.add('--scale-low');{scale-low in arcsecperpix}
      paramlist.add(floattostr2(scale*0.9));
      paramlist.add('--scale-high');{scale-high in arcsecperpix}
      paramlist.add(floattostr2(scale*1.1));
    end;

    if stackmenu1.limit_area1.checked then
    begin
      paramlist.add('--ra');
      paramlist.add(floattostr2(ra_radians*180/pi));
      paramlist.add('--dec');
      paramlist.add(floattostr2(dec_radians*180/pi));
      paramlist.add('--radius');{radius}
      paramlist.add(stackmenu1.search_area1.text);
    end;
    deletefile(filename_wcs);{remove any existing file}

    {get the extra parameters from the user}
     ExtractStrings([' '], [], PChar(stackmenu1.astrometry_extra_options1.text),paramlist);

  {$ifdef mswindows}
  param:=stringreplace(paramlist.delimitedtext,',',' ',[rfReplaceAll]);
  param:=stringreplace(param,'"','',[rfReplaceAll]); { paramlist.QuoteChar :=#0 doesn't work always}

  if pos('System32',stackmenu1.cygwin1.text)=0 then {Cygwin solver}
  begin
    if keep_open then ExecuteAndWait('cmd.exe /k '+stackmenu1.cygwin1.text+' --login solve-field "'+filename3+'" '+param,show_console){execute command and wait}
    else
    ExecuteAndWait(stackmenu1.cygwin1.text+' --login solve-field "'+filename3+'" '+param,show_console);{execute command and wait}
  end
  else
  begin {win10 Linux subsystem solver}
    //   C:\Windows\System32\bash.exe -c "solve-field /mnt/c/astap.fpc/_M95_test_image.fit --overwrite --downsample 4"
    // 'C:/astap.fpc/_M95_test_image.fit'
    filename3:='/mnt/'+lowercase(copy(filename3,1,1))+copy(filename3,3,255);{drive should be lowercase}

    if keep_open then ExecuteAndWait('cmd.exe /k '+stackmenu1.cygwin1.text+' -c "solve-field '+#39+filename3+#39+' '+param+'"',show_console){execute command and wait}
    else
                      ExecuteAndWait(              stackmenu1.cygwin1.text+' -c "solve-field '+#39+filename3+#39+' '+param+'"',show_console);{execute command and wait}
  end;

  {$else} {unix}

  paramlist.insert(0,filename3);
//param.Add('"--overwrite --no-plots --objs 150 --downsample 4 --ra 300.000000 --dec 40.410216 --radius 10"');
   execute_unix(stackmenu1.cygwin1.text+'/solve-field',paramlist, show_console);
  {$endif}
  paramlist.Free;

  Application.ProcessMessages;
  if ( (fileexists(filename_wcs)=false) and (fileexists(filename_new)=false)   ) then
  begin
     application.messagebox(pchar(  'No astrometric solution found for: '+'"'+filename3+'"'),pchar('No solution'), 0);
  end
  else
  result:=true;

  if update_header then
  begin
    wait(500);{smart sleep}
    deletefile(changeFileExt(filename3,'.bak'));{delete otherwise next rename is not possible}
    if renamefile(filename3,changeFileExt(filename3,'.bak')) then  renamefile(changeFileExt(filename3,'.new'),filename3) ;
  end;

  if remove_tmp then
  begin
     Application.ProcessMessages;
    try
      DeleteFiles(fPath,'*.corr');{delete with wildcard all since files are sometimes not yet available and dlete them next time}
      DeleteFiles(fPath,'*.match');
      DeleteFiles(fPath,'*.rdls');
      DeleteFiles(fPath,'*.solved');
      DeleteFiles(fPath,'*.axy');
      DeleteFiles(fPath,'*.xyls');
    finally
    end;
  end;
end;


end.
