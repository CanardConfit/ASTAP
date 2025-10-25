unit unit_threaded_gaussian_blur;//Threaded Gaussian blur for image arrays
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/. }

// idea based on http://users.atw.hu/delphicikk/listaz.php?id=1213&oldal=18
// The gaussian kernel exp(-(x^2 + y^2)) is of the form f(x)*g(y), which means that you can perform a two-dimensional convolution by doing a sequence
// of one-dimensional convolutions - first you convolve each row and then each column. This is much faster (an N^2 becomes an N*2).
// Any convolution requires some temporary storage - below the BlurRow routine allocates and frees the memory, meaning that it gets allocated and
//  freed once for each row. Probably changing this would speed it up some, it's not entirely clear how much.
// The kernel "size" is limited to 200 entries. In fact if you use radius anything like that large it will take forever - you want to try this with
// a radius = 3 or 5 or something. For a kernel with that many entries a straight convolution is the thing to do, while when the kernel gets much larger
// Fourier transform techniques will be better (I couldn't say what the actual cutoff is.)
// One comment that needs to be made is that a gaussian blur has the magical property that you can blur each row one by one and then blur each
// column - this is much faster than an actual 2-d convolution.


//The gaussian kernel exp(-(x^2 + y^2)) is separable into f(x)*g(y),
// meaning a 2D convolution can be performed as two 1D convolutions:
//   - First horizontally across rows
//   - Then vertically across columns.
// This is much faster (N^2 → 2N).


interface

uses
  Classes, SysUtils, astap_main, unit_mtpcpu, math;

procedure gaussian_blur_threaded(var img: TImage_Array; radius: double); //Apply gaussian blur on array using multiple CPU threads.

implementation

const
  MaxKernelSize = 100;

type
  TKernelSize = 1..MaxKernelSize;
  TKernel = record
    Size: TKernelSize;
    Weights: array[-MaxKernelSize..MaxKernelSize] of single; {the idea is that when using a TKernel you ignore the Weights except for Weights in the range -Size..Size.}
  end;

  {Thread class for performing one horizontal or vertical blur section}
  TBlurThread = class(TThread)
  private
    FSCL, FTCL: ^TImage_Array;
    FK: TKernel;
    FStartY, FEndY, FWidth, FHeight, FColors: Integer;
    FHorizontal: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(var SCL, TCL: TImage_Array; const K: TKernel;
                       StartY, EndY, Width, Colors, Height: Integer;
                       Horizontal: Boolean);
  end;

{------------------------------------------------------------}
{ Gaussian kernel generator                                  }
{------------------------------------------------------------}
procedure MakeGaussianKernel(var K: TKernel; radius: double; MaxData, DataGranularity: double);
{Makes K into a gaussian kernel with standard deviation = radius. For the current application you set MaxData = 255 and DataGranularity = 1. Now the procedure sets the value of K.Size so
that when we use K we will ignore the Weights that are so small they can't possibly matter. Small Size is good because the execution time is going to be propertional to K.Size.}
var
  j: integer;
  temp, delta: double;
  KernelSize: TKernelSize;
begin
  for j := Low(K.Weights) to High(K.Weights) do
  begin
    temp := j / radius;
    K.Weights[j] := exp(-temp * temp / 2);
  end;
  {Normalize so sum(Weights) = 1:}
  temp := 0;
  for j := Low(K.Weights) to High(K.Weights) do
    temp := temp + K.Weights[j];
  for j := Low(K.Weights) to High(K.Weights) do
    K.Weights[j] := K.Weights[j] / temp;

  {Discard insignificant weights to reduce computation time}
  {Now discard (or rather mark as ignorable by setting Size) the entries that are too small to matter.  This is important, otherwise a blur with a small radius will take as long as with a large radius...}
  KernelSize := MaxKernelSize;
  delta := DataGranularity / (2 * MaxData);
  temp := 0;
  while (temp < delta) and (KernelSize > 1) do
  begin
    temp := temp + 2 * K.Weights[KernelSize];
    dec(KernelSize);
  end;
  K.Size := KernelSize;
  {Now just to be correct go back and jiggle again so the sum of the entries we'll be using is exactly 1}
  {Re-normalize for the truncated kernel}
  temp := 0;
  for j := -K.Size to K.Size do
    temp := temp + K.Weights[j];
  for j := -K.Size to K.Size do
    K.Weights[j] := K.Weights[j] / temp;
end;

{------------------------------------------------------------}
{ Thread constructor                                         }
{------------------------------------------------------------}
constructor TBlurThread.Create(var SCL, TCL: TImage_Array; const K: TKernel;
                               StartY, EndY, Width, Colors, Height: Integer;
                               Horizontal: Boolean);
begin
  inherited Create(True); // Suspended
  FSCL := @SCL;
  FTCL := @TCL;
  FK := K;
  FStartY := StartY;
  FEndY := EndY;
  FWidth := Width;
  FColors := Colors;
  FHeight := Height;
  FHorizontal := Horizontal;
  FreeOnTerminate := False;
end;

{------------------------------------------------------------}
{ Thread execution                                           }
{------------------------------------------------------------}
procedure TBlurThread.Execute;
var
  i, j, kx, ky, x, y: Integer;
  valr, valg, valb, weight: Single;
begin
  if FHorizontal then
  begin
    {--- Horizontal blur ---}
    for i := FStartY to FEndY do
      for j := 0 to FWidth do
      begin
        valr := 0; valg := 0; valb := 0;
        for kx := -FK.Size to FK.Size do
        begin
          x := j + kx;
          if x < 0 then x := 0;
          if x > FWidth then x := FWidth;
          weight := FK.Weights[kx];
          valr := valr + FSCL^[0, i, x] * weight;
          if FColors >= 2 then valg := valg + FSCL^[1, i, x] * weight;
          if FColors >= 3 then valb := valb + FSCL^[2, i, x] * weight;
        end;
        FTCL^[0, i, j] := valr;
        if FColors >= 2 then FTCL^[1, i, j] := valg;
        if FColors >= 3 then FTCL^[2, i, j] := valb;
      end;
  end
  else
  begin
    {--- Vertical blur ---}
    for i := FStartY to FEndY do
      for j := 0 to FWidth do
      begin
        valr := 0; valg := 0; valb := 0;
        for ky := -FK.Size to FK.Size do
        begin
          y := i + ky;
          if y < 0 then y := 0;
          if y > FHeight then y := FHeight;
          weight := FK.Weights[ky];
          valr := valr + FSCL^[0, y, j] * weight;
          if FColors >= 2 then valg := valg + FSCL^[1, y, j] * weight;
          if FColors >= 3 then valb := valb + FSCL^[2, y, j] * weight;
        end;
        FTCL^[0, i, j] := valr;
        if FColors >= 2 then FTCL^[1, i, j] := valg;
        if FColors >= 3 then FTCL^[2, i, j] := valb;
      end;
  end;
end;

{------------------------------------------------------------}
{ Main threaded blur procedure                               }
{------------------------------------------------------------}
procedure gaussian_blur_threaded(var img: TImage_Array; radius: double);//apply gaussian blur on array
var
  K: TKernel;
  img_temp: TImage_Array;
  w, h, colors: Integer;
  NumThreads, i, StartY, EndY, SectionHeight: Integer;
  Threads: array of TBlurThread;
begin
  if radius < 0.001 then Exit; // Prevent runtime error for radius 0

  MakeGaussianKernel(K, radius, 255, 1);

  colors := Length(img);        {number of color planes}
  h := Length(img[0]);          {height}
  w := Length(img[0,0]);        {width}

  SetLength(img_temp, colors, h, w); {temporary image array}

  {--- Determine number of threads ---}
  {$ifdef mswindows}
  NumThreads := Min(System.CPUCount, h);
  {$else}
  NumThreads := Min(GetSystemThreadCount, h);
  {$endif}

  if NumThreads < 1 then NumThreads := 1;
  SectionHeight := (h + 1) div NumThreads;
  SetLength(Threads, NumThreads);

  {--- Pass 1: horizontal blur ---}
  for i := 0 to NumThreads - 1 do
  begin
    StartY := i * SectionHeight;
    if i = NumThreads - 1 then
      EndY := h - 1 //adapt the last section to the image height
    else
      EndY := Min((i + 1) * SectionHeight - 1, h - 1);
    Threads[i] := TBlurThread.Create(img, img_temp, K, StartY, EndY, w - 1, colors, h - 1, True);
    Threads[i].Start;
  end;

  for i := 0 to NumThreads - 1 do
  begin
    Threads[i].WaitFor;
    Threads[i].Free;
  end;

  {--- Pass 2: vertical blur ---}
  for i := 0 to NumThreads - 1 do
  begin
    StartY := i * SectionHeight;
    if i = NumThreads - 1 then
      EndY := h - 1
    else
      EndY := Min((i + 1) * SectionHeight - 1, h - 1);
    Threads[i] := TBlurThread.Create(img_temp, img, K, StartY, EndY, w - 1, colors, h - 1, False);
    Threads[i].Start;
  end;

  for i := 0 to NumThreads - 1 do
  begin
    Threads[i].WaitFor;
    Threads[i].Free;
  end;
end;

end.

