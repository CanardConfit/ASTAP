unit unit_gaussian_blur;

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



interface
uses
  astap_main;

procedure gaussian_blur2(img :image_array; radius: double);{apply gaussian blur on array}


implementation

uses
  SysUtils;

const
  MaxKernelSize = 100;

type
  TKernelSize = 1..MaxKernelSize;
  TKernel = record
    Size: TKernelSize;
    Weights: array[-MaxKernelSize..MaxKernelSize] of single;
  end;
  {the idea is that when using a TKernel you ignore the Weights except
  for Weights in the range -Size..Size.}



procedure MakeGaussianKernel(var K: TKernel; radius: double; MaxData, DataGranularity: double);
{makes K into a gaussian kernel with standard deviation = radius. For the current application
you set MaxData = 255 and DataGranularity = 1. Now the procedure sets the value of K.Size so
that when we use K we will ignore the Weights that are so small they can't possibly matter. (Small
Size is good because the execution time is going to be propertional to K.Size.)}
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
  {now divide by constant so sum(Weights) = 1:}
  temp := 0;
  for j := Low(K.Weights) to High(K.Weights) do
    temp := temp + K.Weights[j];
  for j := Low(K.Weights) to High(K.Weights) do
    K.Weights[j] := K.Weights[j] / temp;
  {now discard (or rather mark as ignorable by setting Size) the entries that are too small to matter.
  This is important, otherwise a blur with a small radius will take as long as with a large radius...}
  KernelSize := MaxKernelSize;
  delta := DataGranularity / (2 * MaxData);
  temp := 0;
  while (temp < delta) and (KernelSize > 1) do
  begin
    temp := temp + 2 * K.Weights[KernelSize];
    dec(KernelSize);
  end;
  K.Size := KernelSize;
  {now just to be correct go back and jiggle again so the sum of the entries we'll be using is exactly 1}
  temp := 0;
  for j := -K.Size to K.Size do
    temp := temp + K.Weights[j];
  for j := -K.Size to K.Size do
    K.Weights[j] := K.Weights[j] / temp;
end;


procedure BlurH (scl, tcl :image_array; K: TKernel; w, h,colors : integer);
var i,j,jx, x : integer;
    valr,valg,valb,weight  : single;
begin
  for i := 0 to h do
     for j := 0 to w do
      begin
        valr:=0;
        valg:=0;
        valb:=0;
        for jx:=-K.Size to K.Size do
        begin
          x:=j+jx;
          if x<0 then x:=0;
          if x>w then x:=w;

          weight := K.Weights[jx];
          valr:=valr + scl[0,x,i]*weight;
          if colors>=2 then valg:=valg + scl[1,x,i]*weight;
          if colors>=3 then valb:=valb + scl[2,x,i]*weight;
        end;
         tcl[0,j,i] := valr;
         if colors>=2 then tcl[1,j,i] := valg;
         if colors>=3 then tcl[2,j,i] := valb;
     end;
end;

procedure BlurV (scl, tcl :image_array; K: TKernel; w, h,colors : integer);
var i,j,iy, y :integer;
    valr,valg,valb,weight  : single;

begin
  for i := 0 to h do
     for j := 0 to w do
      begin
        valr:=0;
        valg:=0;
        valb:=0;
        for iy:=-K.Size to K.Size do
        begin
          y:=i+iy;
          if y<0 then y:=0;
          if y>h then y:=h;
          weight := K.Weights[iy];
          valr:=valr + scl[0,j,y]*weight;
          if colors>=2 then valg:=valg + scl[1,j,y]*weight;
          if colors>=3 then valb:=valb + scl[2,j,y]*weight;
        end;
        tcl[0,j,i] := valr;
        if colors>=2 then tcl[1,j,i] := valg;
        if colors>=3 then tcl[2,j,i] := valb;
     end;
end;


procedure gaussian_blur2(img :image_array; radius: double);{apply gaussian blur on array}
var
  K: TKernel;
  img_temp2 : image_array;
  w,h,colors  :integer;

begin

  MakeGaussianKernel(K, radius, 255, 1);

  colors:=Length(img); {colors}
  w:=Length(img[0]); {width}
  h:=Length(img[0][0]); {height}

  setlength(img_temp2,colors,w,h);{set length of image array}

  BlurH(img, img_temp2,k, w-1, h-1,colors);
  BlurV(img_temp2, img,k, w-1, h-1,colors);

  img_temp2:=nil;
end;


end.

