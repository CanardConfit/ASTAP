program astap_command_line;

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
  file_loaded,filespecified,analysespecified,extractspecified : boolean;
  backgr, hfd_median,snr_min          : double;
  hfd_counter                         : integer;
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
    'ASTAP astrometric solver, '+version+#10+
    '(C) 2018, 2022 by Han Kleijn. License MPL 2.0, Webpage: www.hnsky.org'+#10+
    'Usage:'+#10+
    '-f  filename  {fits, tiff, png, jpg files}'+#10+
    '-f  stdin     {read raw image from stdin}'+#10+
    '-r  radius_area_to_search[degrees]'+#10+      {changed}
    '-z  downsample_factor[0,1,2,3,4] {Downsample prior to solving. 0 is auto}'+#10+
    '-fov diameter_field[degrees]'+#10+   {changed}
    '-ra  center_right ascension[hours]'+#10+
    '-spd center_south_pole_distance[degrees]'+#10+
    '-s  max_number_of_stars  {default 500}'+#10+
    '-t  tolerance  {default 0.007}'+#10+
    '-m  minimum_star_size["]  {default 1.5}'+#10+
    '-speed mode[auto/slow] {Slow is forcing small search steps to improve detection.}'+#10+
    '-o  file {Name the output files with this base path & file name}'+#10+
    '-d  path {specify a path to the star database}'+#10+
    '-analyse snr_min {Analyse only and report median HFD and number of stars used}'+#10+
    '-extract snr_min {As -analyse but additionally write a .csv file with the detected stars info}'+#10+
    '-log   {Write the solver log to file}'+#10+
    '-progress   {Log all progress steps and messages}'+#10+
    '-update  {update the FITS header with the found solution. Jpg, png, tiff will be written as fits}' +#10+
    '-wcs  {Write a .wcs file  in similar format as Astrometry.net. Else text style.}' +#10+
    'Preference will be given to the command line values.'
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
      stdin_mode:=filename2='stdin';
      if stdin_mode=false then {file mode}
        file_loaded:=load_image2 {load file first to give commandline parameters later priority}
      else
      begin
        memo1.clear;{prepare for some info wcs file}
        memo1.add(head1[0]);{add SIMPLE for case option -update is used}
        memo1.add(head1[27]);{add the END to memo1 for stdin and prevent runtime error since all data is inserted for END}
        file_loaded:=read_stdin_data;
      end;
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
    if hasoption('s') then max_stars1:=GetOptionValue('s');
    if hasoption('t') then quad_tolerance1:=GetOptionValue('t');
    if hasoption('m') then min_star_size1:=GetOptionValue('m');
    if hasoption('speed') then force_oversize1:=pos('slow',GetOptionValue('speed'))<>0;

    extractspecified:=hasoption('extract');
    analysespecified:=hasoption('analyse');
    if ((file_loaded) and ((analysespecified) or (extractspecified)) ) then {analyse fits and report HFD value in errorlevel }
    begin
      if analysespecified then snr_min:=strtofloat2(getoptionvalue('analyse'));
      if extractspecified then snr_min:=strtofloat2(getoptionvalue('extract'));
      if snr_min=0 then snr_min:=30;
      analyse_fits(img_loaded,snr_min,extractspecified, hfd_counter,backgr,hfd_median); {find background, number of stars, median HFD}
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

    if ((file_loaded) and (solve_image(img_loaded,true {get hist}) )) then {find plate solution, filename2 extension will change to .fit}
    begin
      if hasoption('o') then filename2:=GetOptionValue('o');{change file name for .ini file}
      write_ini(true);{write solution to ini file}

      add_long_comment('cmdline:'+cmdline);{log command line in wcs file}

      if hasoption('update') then
      begin
        if fits_file_name(filename2) then
           SaveFITSwithupdatedheader1
        else
        save_fits16bit(img_loaded,ChangeFileExt(filename2,'.fits'));{save original png,tiff jpg to 16 bits fits file}
      end;

      remove_key('NAXIS1  =',true{one});
      remove_key('NAXIS2  =',true{one});
      update_integer('NAXIS   =',' / Minimal header                                 ' ,0);{2 for mono, 3 for colour}
      update_integer('BITPIX  =',' /                                                ' ,8);

      if hasoption('wcs') then
        write_astronomy_wcs  {write WCS astronomy.net style}
      else
        try Memo1.SavetoFile(ChangeFileExt(filename2,'.wcs'));{save header as wcs file} except {sometimes error using APT, locked?} end;

      //histogram_done:=false;
    end {solution}
    else
    begin {no solution}
      if hasoption('o') then filename2:=GetOptionValue('o'); {change file name for .ini file}
      write_ini(false);{write solution to ini file}
      errorlevel:=1;{no solution}
    end;
    esc_pressed:=true;{kill any running activity. This for APT}

    if commandline_log then
             Memo2.SavetoFile(ChangeFileExt(filename2,'.log'));{save Memo3 log to log file}

    halt(errorlevel); {don't save only do mainwindow.destroy. Note  mainwindow.close causes a window flash briefly, so don't use}

    //  Exit status:
    //  0 no errors.
    //  1 no solution.
    //  2 not enough stars detected.

    // 16 error reading image file.

    // 32 no star database found.
    // 33 error reading star database.

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
begin
  Application:=Tastap.Create(nil);
  Application.Run;
  Application.Free;
end.

