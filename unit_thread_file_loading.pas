unit unit_thread_file_loading;
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  Classes, SysUtils, astap_main;  // Include necessary units


type
  TLoadThread = class(TThread)
  private
    FFileName: string;
    FLight, FLoadData, FUpdateMemo: Boolean;
    FGetExt: Integer;
    FMemo: TStrings;
    FHead: ^Theader;
    FTargetArray: ^Timage_array;
    FSuccess: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(const FileName: string; Light, LoadData, UpdateMemo: Boolean;
      GetExt: Integer; const Memo: TStrings; var Head: Theader; var TargetArray: Timage_array);
    function WasSuccessful: Boolean;
  end;


implementation
uses
   math;

var
  THREAD_COUNT: Integer;

constructor TLoadThread.Create(const FileName: string; Light, LoadData, UpdateMemo: Boolean; GetExt: Integer; const Memo: TStrings; var Head: Theader; var TargetArray: Timage_array);
begin
  inherited Create(False);  // Start immediately
  FreeOnTerminate := False;
  FFileName := FileName;
  FLight := Light;
  FLoadData := LoadData;
  FUpdateMemo := UpdateMemo;
  FGetExt := GetExt;
  FMemo := Memo;
  FHead := @Head;
  FTargetArray := @TargetArray;
  FSuccess := False; // Default to failure until proven otherwise
end;

procedure TLoadThread.Execute;
begin
  // Call the function and store the success result
  FSuccess := load_fits(FFileName, FLight, FLoadData, FUpdateMemo, FGetExt, FMemo, FHead^, FTargetArray^);
end;

function TLoadThread.WasSuccessful: Boolean;
begin
  Result := FSuccess;
end;

begin
end.

