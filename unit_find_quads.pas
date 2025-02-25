unit unit_find_quads;

interface

uses
  SysUtils, Classes, SyncObjs;

type
  star_list = array of array of double;

procedure find_quads(const starlist: star_list; out quad_star_distances: star_list);

implementation

var
  GlobalLock: TCriticalSection;

type
  TQuadThread = class(TThread)
  private
    FStarList: star_list;
    FStartIdx, FEndIdx: Integer;
    FQuads: star_list;
  protected
    procedure Execute; override;
  public
    constructor Create(const StarList: star_list; StartIdx, EndIdx: Integer);
    procedure MergeResults(var GlobalQuads: star_list);
  end;

constructor TQuadThread.Create(const StarList: star_list; StartIdx, EndIdx: Integer);
begin
  inherited Create(True);
  FStarList := StarList;
  FStartIdx := StartIdx;
  FEndIdx := EndIdx;
  SetLength(FQuads, 8, (EndIdx - StartIdx) + 100);
end;

procedure TQuadThread.Execute;
var
  i, j, k, j_index1, j_index2, j_index3, nrstars, nrquads: integer;
  distance, distance1, distance2, distance3, x1, x2, x3, x4, xt, y1, y2, y3, y4, yt,
  dist1, dist2, dist3, dist4, dist5, dist6, dummy, disty: double;
  identical_quad: boolean;
begin
  nrstars := Length(FStarList[0]);
  nrquads := 0;
  SetLength(Fquads, 8, nrstars);

  for i := FStartIdx to FEndIdx do
  begin
    distance1 := 1E99;
    distance2 := 1E99;
    distance3 := 1E99;

    j_index1 := 0;
    j_index2 := 0;
    j_index3 := 0;

    x1 := FStarList[0, i];
    y1 := FStarList[1, i];

    for j := 0 to nrstars - 1 do
    begin
      if j <> i then
      begin
        disty := sqr(FStarList[1, j] - y1);
        if disty < distance3 then
        begin
          distance := sqr(FStarList[0, j] - x1) + disty;
          if distance > 1 then
          begin
            if distance < distance1 then
            begin
              distance3 := distance2;
              j_index3 := j_index2;
              distance2 := distance1;
              j_index2 := j_index1;
              distance1 := distance;
              j_index1 := j;
            end
            else if distance < distance2 then
            begin
              distance3 := distance2;
              j_index3 := j_index2;
              distance2 := distance;
              j_index2 := j;
            end
            else if distance < distance3 then
            begin
              distance3 := distance;
              j_index3 := j;
            end;
          end;
        end;
      end;
    end;

    if distance3 < 1E99 then
    begin
      x2 := FStarList[0, j_index1];
      y2 := FStarList[1, j_index1];
      x3 := FStarList[0, j_index2];
      y3 := FStarList[1, j_index2];
      x4 := FStarList[0, j_index3];
      y4 := FStarList[1, j_index3];

      xt := (x1 + x2 + x3 + x4) / 4;
      yt := (y1 + y2 + y3 + y4) / 4;

      identical_quad := false;
      for k := 0 to nrquads - 1 do
      begin
        if (abs(xt - Fquads[6, k]) < 1) and
           (abs(yt - Fquads[7, k]) < 1) then
        begin
          identical_quad := true;
          Break;
        end;
      end;

      if not identical_quad then
      begin
        dist1 := sqrt(distance1);
        dist2 := sqrt(distance2);
        dist3 := sqrt(distance3);
        dist4 := sqrt(sqr(x2 - x3) + sqr(y2 - y3));
        dist5 := sqrt(sqr(x2 - x4) + sqr(y2 - y4));
        dist6 := sqrt(sqr(x3 - x4) + sqr(y3 - y4));

        for j := 1 to 5 do
        begin
          if dist6 > dist5 then begin dummy := dist5; dist5 := dist6; dist6 := dummy; end;
          if dist5 > dist4 then begin dummy := dist4; dist4 := dist5; dist5 := dummy; end;
          if dist4 > dist3 then begin dummy := dist3; dist3 := dist4; dist4 := dummy; end;
          if dist3 > dist2 then begin dummy := dist2; dist2 := dist3; dist3 := dummy; end;
          if dist2 > dist1 then begin dummy := dist1; dist1 := dist2; dist2 := dummy; end;
        end;

        Fquads[0, nrquads] := dist1;
        Fquads[1, nrquads] := dist2 / dist1;
        Fquads[2, nrquads] := dist3 / dist1;
        Fquads[3, nrquads] := dist4 / dist1;
        Fquads[4, nrquads] := dist5 / dist1;
        Fquads[5, nrquads] := dist6 / dist1;
        Fquads[6, nrquads] := xt;
        Fquads[7, nrquads] := yt;

        nrquads := nrquads + 1;
      end;
    end;
  end;
  SetLength(Fquads, 8, nrquads);
end;


procedure TQuadThread.MergeResults(var GlobalQuads: star_list);
var
  i, Offset: Integer;
begin
  GlobalLock.Acquire;
  try
    Offset := Length(GlobalQuads[0]);
    SetLength(GlobalQuads, 8, Offset + Length(FQuads[0]));

    for i := 0 to High(FQuads[0]) do
    begin
      GlobalQuads[0, Offset + i] := FQuads[0, i];
      GlobalQuads[1, Offset + i] := FQuads[1, i];
      GlobalQuads[2, Offset + i] := FQuads[2, i];
      GlobalQuads[3, Offset + i] := FQuads[3, i];
      GlobalQuads[4, Offset + i] := FQuads[4, i];
      GlobalQuads[5, Offset + i] := FQuads[5, i];
      GlobalQuads[6, Offset + i] := FQuads[6, i];
      GlobalQuads[7, Offset + i] := FQuads[7, i];
    end;
  finally
    GlobalLock.Release;
  end;
end;

procedure find_quads(const starlist: star_list; out quad_star_distances: star_list);
var
  Threads: array of TQuadThread;
  i, StartIdx, EndIdx, NumThreads: Integer;
begin
  NumThreads := System.CPUCount;

  //numthreads:=1;

  SetLength(Threads, NumThreads);
  SetLength(quad_star_distances, 8);

  for i := 0 to NumThreads - 1 do
  begin
    StartIdx := (i * Length(starlist[0])) div NumThreads;
    EndIdx := ((i + 1) * Length(starlist[0])) div NumThreads - 1;
    Threads[i] := TQuadThread.Create(starlist, StartIdx, EndIdx);
    Threads[i].Start;
  end;

  for i := 0 to NumThreads - 1 do
  begin
    Threads[i].WaitFor;
    Threads[i].MergeResults(quad_star_distances);
    Threads[i].Free;
  end;
end;

initialization
  GlobalLock := TCriticalSection.Create;

finalization
  GlobalLock.Free;

end.

