unit unit_threaded_stacking_mean_and_variance;
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org  MPL 2.0}

interface

uses
  Classes, SysUtils, astap_main, unit_star_align, unit_mtpcpu;

// Single-pass accumulation for sigma-clip: builds the weighted sum (mean),
// the weighted sum of squares, and the weight total simultaneously.
//   meanArr   += weightf * d          (S1, -> becomes mean after /W)
//   sumsqArr  += weightf * d*d        (S2, -> variance = S2/W - mean^2)
//   weightArr += weightf              (W,  channel 0 only)
// with d = resampled_source_pixel - background
procedure stack_arrays_variance(var meanArr, source, sumsqArr, weightArr: Timage_array; solution_vectorX, solution_vectorY: Tsolution_vector; background, weightf: double);

implementation
uses math;

type
  TmeanVarThread = class(TThread)
  private
    FRowStart, FRowEnd, Fcolors, Fheight_source, Fwidth_source: Integer;
    Faa, Fbb, Fcc, Fdd, Fee, Fff, Fbackground, Fweightf: double;
    meanArr, source, sumsqArr, weightArr: ^Timage_array;
  protected
    procedure Execute; override;
  public
    constructor Create(RowStart, RowEnd: Integer; var ArrMean, ArrSource, ArrSumsq, ArrWeight: Timage_array;
      solution_vectorX, solution_vectorY: Tsolution_vector; background, weightf: double;
      colors, height_source, width_source: integer);
  end;

constructor TmeanVarThread.Create(RowStart, RowEnd: Integer; var ArrMean, ArrSource, ArrSumsq, ArrWeight: Timage_array;
  solution_vectorX, solution_vectorY: Tsolution_vector; background, weightf: double;
  colors, height_source, width_source: integer);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FRowStart := RowStart;
  FRowEnd := RowEnd;
  meanArr := @ArrMean;
  source := @ArrSource;
  sumsqArr := @ArrSumsq;
  weightArr := @ArrWeight;
  Faa := solution_vectorX[0];  Fbb := solution_vectorX[1];  Fcc := solution_vectorX[2];
  Fdd := solution_vectorY[0];  Fee := solution_vectorY[1];  Fff := solution_vectorY[2];
  Fbackground := background;
  Fweightf := weightf;
  Fcolors := colors;
  Fheight_source := height_source;
  Fwidth_source := width_source;
end;

procedure TmeanVarThread.Execute;
var
  h, w, col, x_trunc, y_trunc: Integer;
  x_frac, y_frac, x_new, y_new, w00, w10, w01, w11: double;
  val, d, dw: single;
begin
{ One-pass weighted mean and variance
  -----------------------------------
  For each output pixel, frame i contributes a background-subtracted,
  resampled value  dᵢ = valᵢ − background  with weight wᵢ (weightF, normally 1).

  Accumulate three running sums in a SINGLE pass over the frames:
      W  = Σ wᵢ           (weightArr, channel 0)
      S1 = Σ wᵢ·dᵢ        (meanArr)
      S2 = Σ wᵢ·dᵢ²       (sumsqArr)


  Weighted mean:      m = S1 / W

  The weighted variance follows without a second pass from the identity:
      σ² = Σ wᵢ·(dᵢ − m)² / W
         = (S2 − 2m·S1 + m²·W) / W        expand the square
         = (S2 − m²·W) / W                since S1 = m·W
         = S2/W − m²

  So after the pass:  m = S1/W  and  σ² = S2/W − m²

  Numerical note: σ² is the difference of two nearly equal quantities
  (S2/W and m²). In single precision this loses accuracy for bright pixels
  where m >> σ (relative error ≈ (m/σ)²·ε_single). Acceptable here because the
  value only sets a coarse sigma-clip threshold; if a bright-star stack ever
  shows drift, promote sumsqArr to double and leave the rest single.
  A near-constant pixel can give a tiny negative σ² from rounding, so clamp ≥ 0. }
  for h := FRowStart to FRowEnd do
    for w := 0 to Fwidth_source - 1 do
    begin
      x_new := Faa * w + Fbb * h + Fcc;
      y_new := Fdd * w + Fee * h + Fff;
      x_trunc := trunc(x_new);
      y_trunc := trunc(y_new);
      if ((x_trunc > 0) and (x_trunc < Fwidth_source - 1) and
          (y_trunc > 0) and (y_trunc < Fheight_source - 1)) then
      begin
        x_frac := frac(x_new);
        y_frac := frac(y_new);
        w00 := (1 - x_frac) * (1 - y_frac);  {pixel left top,    1}
        w10 := (    x_frac) * (1 - y_frac);  {pixel right top,   2}
        w01 := (1 - x_frac) * (    y_frac);  {pixel left bottom, 3}
        w11 := (    x_frac) * (    y_frac);  {pixel right bottom,4}

        for col := 0 to Fcolors - 1 do //resample the source image
        begin //Bilinearly interpolate four closest pixels of the source
          val := source^[col, y_trunc,     x_trunc]     * w00  {pixel left top,    1}
               + source^[col, y_trunc,     x_trunc + 1] * w10  {pixel right top,   2}
               + source^[col, y_trunc + 1, x_trunc]     * w01  {pixel left bottom, 3}
               + source^[col, y_trunc + 1, x_trunc + 1] * w11; {pixel right bottom,4}
          d  := val - Fbackground;
          dw := d * Fweightf;
          meanArr^[col, h, w]  := meanArr^[col, h, w]  + dw;      // S1 += w*d
          sumsqArr^[col, h, w] := sumsqArr^[col, h, w] + dw * d;  // S2 += w*d*d
        end;
        weightArr^[0, h, w] := weightArr^[0, h, w] + Fweightf;    // W += w
      end;
    end;
end;

procedure stack_arrays_variance(var meanArr, source, sumsqArr, weightArr: Timage_array;
  solution_vectorX, solution_vectorY: Tsolution_vector; background, weightf: double);
var
  THREAD_COUNT, i, RowStart, RowEnd, RowsPerThread, colors, height_source, width_source: Integer;
  Threads: array of TmeanVarThread;
begin
  colors := Length(meanArr);
  height_source := Length(source[0]);
  width_source := Length(source[0, 0]);

  {$ifdef mswindows}
  THREAD_COUNT := Min(System.CPUCount, height_source);
  {$else}
  THREAD_COUNT := Min(GetSystemThreadCount, height_source);
  {$endif}
  if THREAD_COUNT < 1 then THREAD_COUNT := 1;

  SetLength(Threads, THREAD_COUNT);
  RowsPerThread := height_source div THREAD_COUNT;

  for i := 0 to THREAD_COUNT - 1 do
  begin
    RowStart := i * RowsPerThread;
    RowEnd := (i + 1) * RowsPerThread - 1;
    if i = THREAD_COUNT - 1 then RowEnd := height_source - 1;
    Threads[i] := TmeanVarThread.Create(RowStart, RowEnd, meanArr, source, sumsqArr, weightArr,
      solution_vectorX, solution_vectorY, background, weightf, colors, height_source, width_source);
    Threads[i].Start;
  end;

  for i := 0 to THREAD_COUNT - 1 do
  begin
    Threads[i].WaitFor;
    Threads[i].Free;
  end;
end;

begin
end.
