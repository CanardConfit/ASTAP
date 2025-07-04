program astap_command_line;
{Copyright (C) 2017, 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

//For the Android version the interpreter could be wrong set at libdl. It should be /system/bin/linker64. Test in Linux by entering "file ./astap_cli"
// To correct use patchelf as follows:
// 64 bit
// patchelf --set-interpreter /system/bin/linker64 ./astap_cli
//
// 32 bit
// patchelf --set-interpreter /system/bin/linker ./astap_cli
// See: https://github.com/han-k59/astap/issues/1
// See: https://forum.lazarus.freepascal.org/index.php/topic,67692.0.html

{$mode objfpc}{$H+}
uses
  {$IFDEF UNIX or ANDROID}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  unit_command_line_solving, unit_command_line_general;

type

  {Tastap}
  Tastap = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;
 {Tastap}


function fits_file_name(inp : string): boolean; {fits file name?}
begin
  inp:=uppercase(extractfileext(inp));
  result:=((inp='.FIT') or (inp='.FITS') or (inp='.FTS'));
end;


procedure Tastap.DoRun;
var
  file_loaded,filespecified,analysespecified, extractspecified, extractspecified2,wresult : boolean;
  backgr, hfd_median,snr_min          : double;
  hfd_counter,report                  : integer;
  filename_output                     : string;
begin
  {$IfDef Darwin}// for OS X,
    database_path:='/usr/local/opt/astap/';
  {$else}

  database_path:=extractfilepath(paramstr(0));{}

    {$ifdef mswindows}
    {$else} {UNIX or ANDROID}
    if copy(database_path,1,4)='/usr' then {for Linux distributions}
      database_path:='/usr/share/astap/data/';
    {$endif}
  {$endif}


  fov_specified:=false;{assume no FOV specification in commandline}

  if ((paramcount=0) or (hasOption('h','help'))) then
  begin
    writeln(
    'ASTAP astrometric solver version CLI-'+astap_version+#10+
    '(C) 2018, 2025 by Han Kleijn. License MPL 2.0, Webpage: www.hnsky.org'+#10+
    'Usage:'+#10+
    '-f  filename  {fits, tiff, png, jpg files}'+#10+
    '-r  radius_area_to_search[degrees]'+#10+      {changed}
    '-fov diameter_field[degrees] {enter zero for auto}'+#10+   {changed}
    '-ra  right_ascension[hours]'+#10+
    '-spd south_pole_distance[degrees]'+#10+
    '-s  max_number_of_stars  {default 500}'+#10+
    '-t  tolerance  {default 0.007}'+#10+
    '-m  minimum_star_size["]  {default 1.5}'+#10+
    '-z  downsample_factor[0,1,2,3,4,..] {Downsample prior to solving. Specify 0 for auto selection}'+#10+

    '-check apply[y/n] {Apply check pattern filter prior to solving. Use for raw OSC images only when binning is 1x1}' +#10+
    '-d  path {specify a path to the star database}'+#10+
    '-D  abbreviation {Specify a star database [d80,d50,..]}'+#10+
    '-o  file {Name the output files with this base path & file name.}'+#10+
    '-sip     {Add SIP (Simple Image Polynomial) coefficients}'+#10+
    '-speed mode[auto/slow] {Slow is forcing more area overlap while searching to improve detection}'+#10+
    '-wcs  {Write a .wcs file  in similar format as Astrometry.net. Else text style}' +#10+
    '-log  {Write the solver log to a .log text file.}'+#10+
    '-update  {Add the solution to the input fits/tiff file header. Jpeg, png, tiff will be written as fits}' +#10+
    '-progress   {Log all progress steps and messages}'+#10+
    #10+
    'Analyse options:' +#10+
    '-analyse snr_min {Analyse only and report median HFD and number of stars used}'+#10+
    '-extract snr_min {As -analyse but additionally export info of all detectable stars to a .csv file}'+#10+
    '-extract2 snr_min {Solve and export info of all detectable stars to a .csv file including ra, dec}'+#10+
    #10+
    'Preference will be given to the command-line values. CSV files are written with a dot as decimal seperator.'+#10+
    'Solver result will be written to filename.ini and filename.wcs.'

    );

    esc_pressed:=true;{kill any running activity. This for APT}
    terminate;
    exit;
  end;

  filespecified:=hasoption('f');

  if filespecified then
  begin
    commandline_log:=hasoption('log');{log to file. In debug mode enable logging to memo2}
    solve_show_log:=hasoption('progress');{log all progress}
    if commandline_log then memo2_message(cmdline);{write the original commmand line}


    if filespecified then
    begin
      filename2:=GetOptionValue('f');
      file_loaded:=load_image; {load file first to give commandline parameters later priority}
      if file_loaded=false then errorlevel:=16;{error file loading}
    end
    else
    file_loaded:=false;

    {apply now overriding parameters}
    if hasoption('fov') then
    begin
      fov_specified:=true; {do not calculate it from header};
      search_fov1:=GetOptionValue('fov');
    end;
    if hasoption('r') then radius_search1:=GetOptionValue('r');
    if hasoption('ra') then
    begin
      ra0:=strtofloat2(GetOptionValue('ra'))*pi/12;
    end;
    {else ra from fits header}

    if hasoption('spd') then {south pole distance. Negative values can't be passed via commandline}
    begin
      dec0:=(strtofloat2(GetOptionValue('spd'))-90)*pi/180;{convert south pole distance to declination}
    end;
    {else dec from fits header}

    if hasoption('z') then downsample_for_solving1:=strtoint(GetOptionValue('z'));
    if hasoption('s') then max_stars:=strtoint(GetOptionValue('s'));
    if hasoption('t') then quad_tolerance1:=GetOptionValue('t');
    if hasoption('m') then min_star_size1:=GetOptionValue('m');
    if hasoption('sip') then add_sip1:='n'<>GetOptionValue('sip');
    if hasoption('speed') then force_oversize1:=pos('slow',GetOptionValue('speed'))<>0;
    if hasoption('check') then check_pattern_filter1:=('y'=GetOptionValue('check'));

    extractspecified:=hasoption('extract');
    analysespecified:=hasoption('analyse');

    if ((file_loaded) and ((analysespecified) or (extractspecified)) ) then {analyse fits and report HFD value in errorlevel }
    begin
      if analysespecified then
      begin
         snr_min:=strtofloat2(getoptionvalue('analyse'));
         report:=0; {report nr stars and hfd only}
      end;
      if extractspecified then
      begin
        snr_min:=strtofloat2(getoptionvalue('extract'));
        report:=2; {report nr stars and hfd and export csv file}
      end;
      if snr_min=0 then snr_min:=30;
      analyse_image(img_loaded,snr_min,report, hfd_counter,backgr,hfd_median); {find background, number of stars, median HFD}
      if isConsole then {stdout available, compile targe option -wh used}
      begin
        writeln('HFD_MEDIAN='+floattostrF2(hfd_median,0,1));
        writeln('STARS='+inttostr(hfd_counter));
      end;

      {$IFDEF msWindows}
      halt(round(hfd_median*100)*1000000+hfd_counter);{report in errorlevel the hfd and the number of stars used}
      {$ELSE}
      halt(errorlevel);{report hfd in errorlevel. In linux only range 0..255 possible}
      {$ENDIF}
    end;{analyse fits and report HFD value}

    if hasoption('d') then
      database_path:=GetOptionValue('d')+DirectorySeparator; {specify a different database path}
    if hasoption('D') then
      star_database1:=GetOptionValue('D'); {specify a different database}

    if hasoption('o') then
      filename_output:=GetOptionValue('o') {for the .ini and .wcs files}
    else
      filename_output:=filename2; //use same filename for .ini and .wcs files

    extractspecified2:=hasoption('extract2');//this option will happen after solving
    if extractspecified2 then add_sip1:=true;//force sip for high accuracy solving

    if ((file_loaded) and (solve_image(img_loaded ))) then {find plate solution}
    begin
      write_ini(filename_output,true);{write solution to ini file}

      add_long_comment('cmdline:'+cmdline);{log command line in wcs file}

      if hasoption('update') then  //write error
      begin
        if fits_file_name(filename2) then
          wresult:=savefits_update_header(filename2)
        else
          wresult:=save_fits16bit(img_loaded,ChangeFileExt(filename2,'.fits'));{save original png,tiff jpg to 16 bits fits file}

        if wresult=false then
        begin
           memo2_message('█ █ █ Error updating input file !! █ █ █');
           errorlevel:=34;{Error updating input file}
        end;
      end;

      remove_key('NAXIS1  =',true{one});
      remove_key('NAXIS2  =',true{one});
      update_integer('NAXIS   =',' / Minimal header                                 ' ,0);{2 for mono, 3 for colour}
      update_integer('BITPIX  =',' /                                                ' ,8);

      if hasoption('wcs') then
        write_astronomy_wcs(filename_output)  {write WCS astronomy.net style}
      else
        try memo1.SavetoFile(ChangeFileExt(filename_output,'.wcs'));{save header as wcs file} except {sometimes error using APT, locked?} end;

    end {solution}
    else
    begin {no solution}
      write_ini(filename_output,false);{write solution to ini file}
      errorlevel:=1;{no solution}
    end;

    if ((file_loaded) and (extractspecified2)) then
    begin
      snr_min:=strtofloat2(getoptionvalue('extract2'));
      if snr_min=0 then snr_min:=30;
      analyse_image(img_loaded,snr_min,2 {report, export CSV only}, hfd_counter,backgr,hfd_median); {find background, number of stars, median HFD}
    end;

    esc_pressed:=true;{kill any running activity. This for APT}
    if commandline_log then
             memo2.SavetoFile(ChangeFileExt(filename_output,'.log'));{save memo2 log to log file}

    halt(errorlevel);

    //  Exit status:
    //  0 no errors.
    //  1 no solution.
    //  2 not enough stars detected.

    // 16 error reading image file.

    // 32 no star database found.
    // 33 error reading star database.
    // 34 error updating input file

    // ini file is always written. Could contain:
    // ERROR=......
    // WARNING=......

    // wcs file is written when there is a solution. Could contain:
    // WARNING =.........
  end;{-f option}

  {$IfDef Darwin}// for OS X,
  {$IF FPC_FULLVERSION <= 30200} {FPC3.2.0}
     application.messagebox( pchar('Warning this code requires later LAZARUS 2.1 and FPC 3.3.1 version!!!'), pchar('Warning'),MB_OK);
  {$ENDIF}
  {$ENDIF}
  terminate;
end;



constructor Tastap.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  memo1:=Tstringlist.Create;
  memo2:=Tstringlist.Create;
  StopOnException:=True;
end;

destructor Tastap.Destroy;
begin
  memo2.free;
  memo1.free;
  inherited Destroy;
end;


var
  Application: Tastap;

//{$R *.res}

{$R *.res}

begin
  Application:=Tastap.Create(nil);
  Application.Run;
  Application.Free;
end.

