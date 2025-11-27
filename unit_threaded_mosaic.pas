unit unit_threaded_mosaic;//Threaded mosaic/image stitching
{Copyright (C) 2025 by Han Kleijn, www.hnsky.org
 email: han.k.. at...hnsky.org
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at https://mozilla.org/MPL/2.0/. }
interface
uses
  Classes, SysUtils, astap_main, unit_mtpcpu, math, StdCtrls,
  forms;

procedure mosaic_loops_threaded(head, head_ref: theader;
                                var  img_loaded, img_average, img_temp: timage_array;
                                crop,counter,nrframes: integer;
                                max_dev_backgr: double;
                                init, vector_based,equalise_background, merge_overlap: boolean);//In procedure mosaic_loops_threaded the img_loaded is placed on the large canvas img_average using the astrometric solution.
                                                                                                //So img_loaded x,y -> ra,dec and then ra,dec -> x,y of img_average using calc_newx_newy. Img_average is distortion free so SIP ap_order is set to zero.
                                                                                                //This procedure mosaic_loops_threaded is called for each img_loaded till all images are stitched on img_average.

implementation
uses unit_stack_routines, unit_stack;

type
  {Thread class for performing mosaic section}
  TMosaicThread = class(TThread)
  private
    FHead, FHeadRef: theader;
    Fimgloaded:^TImage_Array;
    FImgAverage, FImgTemp: ^TImage_Array;
    FStartY, FEndY: Integer;
    FCrop: integer;
    Fcounter,Fnrframes: integer;
    FMaxDevBackgr: double;
    FInit, Fvectorbased,FEqualiseBackground, FMergeOverlap: Boolean;
    FBackgroundCorrection, FBackgroundCorrectionCenter: array[0..2] of double;
    FCropW, FCropH: Integer;
    FWidthMax, FHeightMax: Integer;
    FProcessedRows: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(head, head_ref: theader;
                      var img_loaded,img_average, img_temp: TImage_Array;
                      StartY, EndY: Integer;
                      crop{,counter,nrframes} : integer;
                      max_dev_backgr: double;
                      init, vector_based,equalise_background, merge_overlap: boolean;
                      const background_correction, background_correction_center: array of double;
                      cropW, cropH, widthMax, heightMax: Integer);
    property ProcessedRows: Integer read FProcessedRows;
  end;

function minimum_distance_borders(fitsX, fitsY, w, h: integer): integer;
begin
  result := min(fitsX, w - fitsX);
  result := min(fitsY, result);
  result := min(h - fitsY, result);
end;

{------------------------------------------------------------}
{ Thread constructor                                         }
{------------------------------------------------------------}
constructor TMosaicThread.Create(head, head_ref: theader;
                                var img_loaded, img_average, img_temp: TImage_Array;
                                StartY, EndY: Integer;
                                crop{,counter,nrframes}   : integer;
                                max_dev_backgr: double;
                                init, vector_based,equalise_background, merge_overlap: boolean;
                                const background_correction, background_correction_center: array of double;
                                cropW, cropH, widthMax, heightMax: Integer);
var
  i: Integer;
begin
  inherited Create(True); // Suspended
  FHead := head;
  FHeadRef := head_ref;
  Fimgloaded := @img_loaded;
  FImgAverage := @img_average;
  FImgTemp := @img_temp;
  FStartY := StartY;
  FEndY := EndY;
  FCrop := crop;
  FMaxDevBackgr := max_dev_backgr;
  FInit := init;
  Fvectorbased:=vector_based;
  FEqualiseBackground := equalise_background;
  FMergeOverlap := merge_overlap;
  FProcessedRows := 0;

  // Copy background correction arrays
  for i := 0 to 2 do
  begin
    FBackgroundCorrection[i] := background_correction[i];
    FBackgroundCorrectionCenter[i] := background_correction_center[i];
  end;

  FCropW := cropW;
  FCropH := cropH;
  FWidthMax := widthMax;
  FHeightMax := heightMax;
  FreeOnTerminate := False;
end;

{------------------------------------------------------------}
{ Thread execution                                           }
{------------------------------------------------------------}
procedure TMosaicThread.Execute;
var
  fitsX, fitsY, c, x_new, y_new, col, iterations, greylevels: integer;
  value, dummy, median, median2, delta_median, maxlevel, mean, noise: double;
  x_new_float, y_new_float: double;
begin
  FProcessedRows := 0;

  for fitsY := FStartY to FEndY do
  begin
    // Check if stop was requested
    if esc_pressed then
      Exit;

    for fitsX := 1 + FCropW to FHead.width - (1 + 1 + FCropW) do
    begin
      calc_newx_newy(FHead, FHeadRef, Fvectorbased, fitsX, fitsY, x_new_float, y_new_float);
      x_new := round(x_new_float);
      y_new := round(y_new_float);

      if ((x_new >= 0) and (x_new <= FWidthMax - 1) and
          (y_new >= 0) and (y_new <= FHeightMax - 1)) then
      begin
        if Fimgloaded^[0, fitsY, fitsX] > 0.0001 then
        begin
          dummy := 1 + minimum_distance_borders(fitsX, fitsY, FHead.width, FHead.height);

          if FImgTemp^[0, y_new, x_new] = 0 then
          begin
            // Blank pixel
            for col := 0 to FHead.naxis3 - 1 do
              FImgAverage^[col, y_new, x_new] := Fimgloaded^[col, fitsY, fitsX] +
                                                 FBackgroundCorrectionCenter[col] +
                                                 FBackgroundCorrection[col];
            FImgTemp^[0, y_new, x_new] := dummy;
          end
          else
          begin
            // Pixel already filled, make average
            for col := 0 to FHead.naxis3 - 1 do
            begin
              median := FBackgroundCorrectionCenter[col] + FBackgroundCorrection[col] +
                       median_background(Fimgloaded^, col, 15, 15, fitsX, fitsY);

              if not FMergeOverlap then
              begin
                // Method 2
                median2 := median_background(FImgAverage^, col, 15, 15, x_new, y_new);
                delta_median := median - median2;
                FImgAverage^[col, y_new, x_new] := FImgAverage^[col, y_new, x_new] +
                  delta_median * (1 - FImgTemp^[0, y_new, x_new] /
                  (dummy + FImgTemp^[0, y_new, x_new]));
              end
              else
              begin
                // Method 1
                value := Fimgloaded^[col, fitsY, fitsX] + FBackgroundCorrectionCenter[col];
                local_sigma_clip_mean_and_sd(fitsX - 15, fitsY - 15, fitsX + 15, fitsY + 15,
                                            col, Fimgloaded^, noise, mean, iterations);
                maxlevel := median + noise * 5;

                if ((value < maxlevel) and
                   (Fimgloaded^[col, fitsY, fitsX - 1] < maxlevel) and
                   (Fimgloaded^[col, fitsY, fitsX + 1] < maxlevel) and
                   (Fimgloaded^[col, fitsY - 1, fitsX] < maxlevel) and
                   (Fimgloaded^[col, fitsY + 1, fitsX] < maxlevel)) then
                begin
                  FImgAverage^[col, y_new, x_new] :=
                    FImgAverage^[col, y_new, x_new] * FImgTemp^[0, y_new, x_new] /
                    (dummy + FImgTemp^[0, y_new, x_new]) +
                    (value + FBackgroundCorrection[col]) * dummy /
                    (dummy + FImgTemp^[0, y_new, x_new]);
                end;
              end;
            end;
            FImgTemp^[0, y_new, x_new] := dummy;
          end;
        end;
      end;
    end;

    Inc(FProcessedRows);
  end;
end;

{------------------------------------------------------------}
{ Main threaded mosaic procedure                             }
{------------------------------------------------------------}
procedure mosaic_loops_threaded(head, head_ref: theader;
                               var img_loaded, img_average, img_temp: timage_array;
                               crop,counter,nrframes: integer;
                               max_dev_backgr: double;
                               init, vector_based,equalise_background, merge_overlap: boolean);
var
  fitsX, fitsY, c, width_max, height_max, col, cropW, cropH,
  iterations, greylevels: integer;
  value, dummy, median, median2, delta_median, correction, maxlevel, mean, noise,
  x_min, x_max, y_min, y_max, x_new, y_new: double;
  background_correction_from_overlap, background_correction_basis, background: array[0..2] of double;
  counter_overlap: array[0..2] of integer;
  bck: array[0..3] of double;
  NumThreads, i, StartY, EndY, SectionHeight, TotalRows, ProcessedRows: Integer;
  Threads: array of TMosaicThread;
  LastProgress, CurrentProgress: Integer;
begin
  width_max := length(img_average[0, 0]);
  height_max := length(img_average[0]);

  // Calculate background if required
  for col := 0 to head.naxis3 - 1 do
  begin
    if equalise_background then
    begin
      bck[0] := trimmed_median_background(img_loaded, false, col, 0, round(0.2 * head.width), 0, round(0.2 * head.height), 32000, greylevels);
      bck[1] := trimmed_median_background(img_loaded, false, col, 0, round(0.2 * head.width), round(0.8 * head.height), head.height - 1, 32000, greylevels);
      bck[2] := trimmed_median_background(img_loaded, false, col, round(0.8 * head.width), head.width - 1, 0, round(0.2 * head.height), 32000, greylevels);
      bck[3] := trimmed_median_background(img_loaded, false, col, round(0.8 * head.width), head.width - 1, round(0.8 * head.height), head.height - 1, 32000, greylevels);
      background[col] := smedian(bck, 4);
      background_correction_basis[col] := 1000 - background[col]; //this will be used to make background of all frames around 1000. Any other is corrected by overlapping measurement
    end
    else
    begin
      background[col] := 0;
      background_correction_basis[col] := 0;
    end;
  end;

  cropW := trunc(crop * head.width / 200);
  cropH := trunc(crop * head.height / 200);

  background_correction_from_overlap[0] := 0;
  background_correction_from_overlap[1] := 0;
  background_correction_from_overlap[2] := 0;

  // Initialization phase (check overlap)
  if init then
  begin
    counter_overlap[0] := 0;
    counter_overlap[1] := 0;
    counter_overlap[2] := 0;

    TotalRows := head.height - (1 + 1 + cropH) - (1 + cropH) + 1;

    for fitsY := (1 + cropH) to head.height - (1 + 1 + cropH) do  //measure an additional correction by measuring overlapping areas
    begin
      if esc_pressed then Exit;

      for fitsX := (1 + cropW) to head.width - (1 + 1 + cropW) do
      begin
        calc_newx_newy(head, head_ref, vector_based, fitsX, fitsY, x_new, y_new);

        if ((round(x_new) >= 0) and (round(x_new) <= width_max - 1) and
            (round(y_new) >= 0) and (round(y_new) <= height_max - 1)) then
        begin
          if img_loaded[0, fitsY, fitsX] > 0.0001 then
          begin
            if img_average[0, round(y_new), round(x_new)] <> 0 then
            begin
              for col := 0 to head.naxis3 - 1 do
              begin
                correction := round(img_average[col, round(y_new), round(x_new)] -
                             (img_loaded[col, fitsY, fitsX] + background_correction_basis[col]));
                if abs(correction) < max_dev_backgr * 1.5 then
                begin
                  background_correction_from_overlap[col] := background_correction_from_overlap[col] + correction;
                  counter_overlap[col] := counter_overlap[col] + 1;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    if counter_overlap[0] > 0 then background_correction_from_overlap[0] := background_correction_from_overlap[0] / counter_overlap[0];
    if counter_overlap[1] > 0 then background_correction_from_overlap[1] := background_correction_from_overlap[1] / counter_overlap[1];
    if counter_overlap[2] > 0 then background_correction_from_overlap[2] := background_correction_from_overlap[2] / counter_overlap[2];
  end;

  // Limit threads to available CPU logical cores or height
  {$ifdef mswindows}
  NumThreads := Min(System.CPUCount, head.height);
  {$else}
  NumThreads := Min(GetSystemThreadCount, head.height);
  {$endif}
  if NumThreads < 1 then NumThreads := 1;

   TotalRows := head.height - (1 + 1 + cropH) - (1 + cropH) + 1;
  SectionHeight := TotalRows div NumThreads;

  SetLength(Threads, NumThreads);

  // Create and start threads
  for i := 0 to NumThreads - 1 do
  begin
    StartY := (1 + cropH) + i * SectionHeight;
    if i = NumThreads - 1 then
      EndY := head.height - (1 + 1 + cropH)
    else
      EndY := Min((1 + cropH) + (i + 1) * SectionHeight - 1, head.height - (1 + 1 + cropH));

    Threads[i] := TMosaicThread.Create(head, head_ref,
                                      img_loaded,
                                      img_average, img_temp,
                                      StartY, EndY, crop, max_dev_backgr,
                                      init, vector_based,equalise_background, merge_overlap,
                                      background_correction_from_overlap, background_correction_basis,
                                      cropW, cropH, width_max, height_max);
    Threads[i].Start;
  end;

  // Wait for all threads and update progress
  ProcessedRows := 0;
  LastProgress := -1;

  for i := 0 to NumThreads - 1 do
  begin
    while not Threads[i].Finished do
    begin
      Sleep(100);
      // Calculate total progress from all threads
      ProcessedRows := 0;
      for c := 0 to NumThreads - 1 do
        ProcessedRows := ProcessedRows + Threads[c].ProcessedRows;

      CurrentProgress := trunc(  100*(     (counter/nrframes) +     ProcessedRows/(nrframes*TotalRows)));
      if (CurrentProgress >= LastProgress + 5) or (CurrentProgress >= 100) then
      begin
        LastProgress := CurrentProgress;
        Application.Title := Format('%d%%', [CurrentProgress]);
        Application.ProcessMessages;
      end;
    end;

    Threads[i].WaitFor;
    Threads[i].Free;
  end;

  Application.Title:='ASTAP';
  Application.ProcessMessages;
end;

end.
