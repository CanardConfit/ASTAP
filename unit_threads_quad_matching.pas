unit unit_threads_quad_matching;
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/.   }

interface

uses
  SysUtils, Classes, SyncObjs;

type
  star_list = array of array of double;
  match_list = array of array of Integer;

procedure find_matching_quads( const quad_star_distances1, quad_star_distances2: star_list;quad_tolerance: double; out matchlist2: match_list);

implementation

var
  GlobalLock: TCriticalSection;

type
  TMatchThread = class(TThread)
  private
    FQuadStarDistances1, FQuadStarDistances2: star_list;
    FQuadTolerance: double;
    FStartIdx, FEndIdx: Integer;
    FMatchList: match_list;
    FActualCount: Integer; // Stores matches count in this thread
  protected
    procedure Execute; override;
  public
    constructor Create(const QuadStarDistances1, QuadStarDistances2: star_list;
      QuadTolerance: double; StartIdx, EndIdx: Integer);
    procedure MergeResults(var GlobalMatchList: match_list; var GlobalCount: Integer);
  end;

constructor TMatchThread.Create(
  const QuadStarDistances1, QuadStarDistances2: star_list;
  QuadTolerance: double; StartIdx, EndIdx: Integer);
begin
  inherited Create(True); // Create suspended
  FQuadStarDistances1 := QuadStarDistances1;
  FQuadStarDistances2 := QuadStarDistances2;
  FQuadTolerance := QuadTolerance;
  FStartIdx := StartIdx;
  FEndIdx := EndIdx;

  FActualCount := 0;
  SetLength(FMatchList, 2);
  SetLength(FMatchList[0], 1000); // Initial allocation
  SetLength(FMatchList[1], 1000);
end;

procedure TMatchThread.Execute;
var
  i, j, AllocatedSize: Integer;
begin
  AllocatedSize := 1000; // Initial allocation

  for i := FStartIdx to FEndIdx do
  begin
    for j := 0 to High(FQuadStarDistances2[0]) do
    begin       //database                      image
      if (Abs(FQuadStarDistances1[1, i] - FQuadStarDistances2[1, j]) <= FQuadTolerance) and //all length are scaled to the longest length so scale independent
         (Abs(FQuadStarDistances1[2, i] - FQuadStarDistances2[2, j]) <= FQuadTolerance) and
         (Abs(FQuadStarDistances1[3, i] - FQuadStarDistances2[3, j]) <= FQuadTolerance) and
         (Abs(FQuadStarDistances1[4, i] - FQuadStarDistances2[4, j]) <= FQuadTolerance) and
         (Abs(FQuadStarDistances1[5, i] - FQuadStarDistances2[5, j]) <= FQuadTolerance) then
      begin
        // Expand only when necessary
        if FActualCount >= AllocatedSize then
        begin
          AllocatedSize := AllocatedSize + (AllocatedSize div 2); // Grow by 50%
          SetLength(FMatchList[0], AllocatedSize);
          SetLength(FMatchList[1], AllocatedSize);
        end;

        FMatchList[0, FActualCount] := i;
        FMatchList[1, FActualCount] := j;
        Inc(FActualCount);
      end;
    end;
  end;
end;

procedure TMatchThread.MergeResults(var GlobalMatchList: match_list; var GlobalCount: Integer);
var
  i, Offset: Integer;
begin
  // Synchronize access to global list
  GlobalLock.Acquire;
  try
    Offset := GlobalCount;

    // Expand global list if needed
    if Offset + FActualCount > Length(GlobalMatchList[0]) then
    begin
      SetLength(GlobalMatchList[0], Offset + FActualCount + 1000);
      SetLength(GlobalMatchList[1], Offset + FActualCount + 1000);
    end;

    // Copy thread results to global list
    for i := 0 to FActualCount - 1 do
    begin
      GlobalMatchList[0, Offset + i] := FMatchList[0, i];
      GlobalMatchList[1, Offset + i] := FMatchList[1, i];
    end;

    // Update global match count
    GlobalCount := Offset + FActualCount;
  finally
    GlobalLock.Release;
  end;
end;

procedure find_matching_quads(
  const quad_star_distances1, quad_star_distances2: star_list;
  quad_tolerance: double;
  out matchlist2: match_list);
var
  Threads: array of TMatchThread;
  i, StartIdx, EndIdx, NumThreads, TotalMatches: Integer;
begin
  NumThreads := System.CPUCount;
  SetLength(Threads, NumThreads);
  SetLength(matchlist2, 2);
  TotalMatches := 0;

  // Split work among threads
  for i := 0 to NumThreads - 1 do
  begin
    StartIdx := (i * Length(quad_star_distances1[0])) div NumThreads;
    EndIdx := ((i + 1) * Length(quad_star_distances1[0])) div NumThreads - 1;

    Threads[i] := TMatchThread.Create(quad_star_distances1, quad_star_distances2, quad_tolerance, StartIdx, EndIdx);
    Threads[i].Start;
  end;

  // Wait for threads to finish and merge results
  for i := 0 to NumThreads - 1 do
  begin
    Threads[i].WaitFor;
    Threads[i].MergeResults(matchlist2, TotalMatches);
    Threads[i].Free;
  end;

  // Trim matchlist2 to actual count
  SetLength(matchlist2[0], TotalMatches);
  SetLength(matchlist2[1], TotalMatches);
end;

initialization
  GlobalLock := TCriticalSection.Create;

finalization
  GlobalLock.Free;

end.
end.
