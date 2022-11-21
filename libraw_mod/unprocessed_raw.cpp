/* -*- C++ -*-
 * File: unprocessed_raw.cpp
 * Copyright 2009-2021 LibRaw LLC (info@libraw.org)
 * Created: Fri Jan 02, 2009
 * Modified for adding meta data to PPM file and FITS export. By Han Kleijn. Version see message
 *
 * LibRaw sample
 * Generates unprocessed raw image: with masked pixels and without black
subtraction
 *

LibRaw is free software; you can redistribute it and/or modify
it under the terms of the one of two licenses as you choose:

1. GNU LESSER GENERAL PUBLIC LICENSE version 2.1
   (See file LICENSE.LGPL provided in LibRaw distribution archive for details).

2. COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0
   (See file LICENSE.CDDL provided in LibRaw distribution archive for details).

 */
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>

#include "libraw/libraw.h"

#ifndef LIBRAW_WIN32_CALLS
#include <netinet/in.h>
#else
#include <sys/utime.h>
#include <winsock2.h>
#endif

#ifdef LIBRAW_WIN32_CALLS
#define snprintf _snprintf
#endif

#if !(LIBRAW_COMPILE_CHECK_VERSION_NOTLESS(0, 14))
#error This code is for LibRaw 0.14+ only
#endif

void gamma_curve(unsigned short curve[]);


void write_ppm(char meta[],unsigned width, unsigned height, unsigned short *bitmap,
               const char *basename);
void write_fits(char fits_header[],unsigned width, unsigned height, unsigned left_margin, unsigned top_margin,unsigned  width2,unsigned height2, unsigned short *bitmap,
                const char *fname);
void write_tiff(int width, int height, unsigned short *bitmap,
                const char *basename);
void JDtoDate(double jd,  int *year, int *month, int *day, int *hours, int *minutes, double *seconds); //converts a Julian day to a calendar Date and Time according Meeus. C routine written by Han Kleijn

int main(int ac, char *av[])
{
  int i, ret,width2,height2;
  int verbose = 1, autoscale = 0, use_gamma = 0, out_tiff = 0, out_fits = 0, top_margin=0, left_margin = 0;
  char outfn[1024];
  char meta[256];
  char str[180];
  char fits_header[2880];
  double temperature;
  int year,month,day,hh,mm;//for JDtoDate
  double julianday,ss;            //for JDtoDate

  LibRaw RawProcessor;
  if (ac < 2)
  {
  usage:
    printf("unprocessed_raw - LibRaw %s %d cameras supported. With FITS file support mod 2022-11-21\n"
           "Usage: %s [-q] [-A] [-g] [-s N] raw-files....\n"
           "\t-q - be quiet\n"
           "\t-s N - select Nth image in file (default=0)\n"
           "\t-g - use gamma correction with gamma 2.2 (not precise,use for "
           "visual inspection only)\n"
           "\t-A - autoscaling (by integer factor)\n"
           "\t-T - write tiff instead of pgm\n"
           "\t-F - write fits instead of pgm, full sensor area including masked areas\n"
           "\t-f - write fits instead of pgm, active area\n"
           "\t-i - write fits instead of pgm, default cropped active area\n",
            LibRaw::version(), LibRaw::cameraCount(), av[0]);
            
    //MaskedAreas: This tag contains a list of non-overlapping rectangle coordinates of fully masked pixels, which can be optionally used by DNG readers to measure the black encoding level.
    //ActiveArea: This rectangle defines the active (non-masked) pixels of the sensor.
    //DefaultCropSize: Raw images often store extra pixels around the edges of the final image. These extra pixels help prevent interpolation artifacts near the edges of the final image. DefaultCropSize specifies the size of the final image area, in raw image coordinates (i.e., before the DefaultScale has been applied).            
            
    return 0;
  }

#define S RawProcessor.imgdata.sizes
//#define OUT RawProcessor.imgdata.params
#define OUTR RawProcessor.imgdata.rawparams
#define P1 RawProcessor.imgdata.idata
#define P2 RawProcessor.imgdata.other
#define P3 RawProcessor.imgdata.makernotes.common
#define exifLens RawProcessor.imgdata.lens
#define C RawProcessor.imgdata.color


#define OUT RawProcessor.imgdata.params

  for (i = 1; i < ac; i++)
  {
    if (av[i][0] == '-')
    {
      if (av[i][1] == 'q' && av[i][2] == 0)
        verbose = 0;
      else if (av[i][1] == 'A' && av[i][2] == 0)
        autoscale = 1;
      else if (av[i][1] == 'g' && av[i][2] == 0)
        use_gamma = 1;
      else if (av[i][1] == 'T' && av[i][2] == 0)
        out_tiff = 1;
      else if (av[i][1] == 'F' && av[i][2] == 0)  // fits in full raw size, full sensor area including masked areas 
       out_fits = 1;
      else if (av[i][1] == 'f' && av[i][2] == 0)  // fits in image size, ActiveArea 
        out_fits = 2;
      else if (av[i][1] == 'i' && av[i][2] == 0)  // fits in thumb size, cropped active area
        out_fits = 3;
      else if (av[i][1] == 's' && av[i][2] == 0)
      {
        i++;
        OUTR.shot_select = av[i] ? atoi(av[i]) : 0;
      }
      else
        goto usage;
      continue;
    }

    if (verbose)
      printf("Processing file %s\n", av[i]);
    if ((ret = RawProcessor.open_file(av[i])) != LIBRAW_SUCCESS)
    {
      fprintf(stderr, "Cannot open %s: %s\n", av[i], libraw_strerror(ret));
      continue; // no recycle b/c open file will recycle itself
    }
    if (verbose)
    {
      printf("Raw size: %dx%d\n",   S.raw_width, S.raw_height);
      printf("Active area size: %dx%d\n", S.width, S.height);
      printf("Default cropped active area: %dx%d\n", S.raw_inset_crops[0].cwidth, S.raw_inset_crops[0].cheight);
     
       printf("Margins active area: left=%d, top=%d\n", S.left_margin, S.top_margin);
      
       if (S.raw_inset_crops[0].ctop != 0xffff) // happens for .ARW
         printf("Margins cropped active area: left=%d, top=%d\n", S.raw_inset_crops[0].cleft, S.raw_inset_crops[0].ctop);
    }

    if ((ret = RawProcessor.unpack()) != LIBRAW_SUCCESS)
    {
      fprintf(stderr, "Cannot unpack %s: %s\n", av[i], libraw_strerror(ret));
      continue;
    }

    if (verbose)
      printf("Unpacked....\n");

    if (!(RawProcessor.imgdata.idata.filters ||
          RawProcessor.imgdata.idata.colors == 1))
    {
      printf("Only Bayer-pattern RAW files supported, sorry....\n");
      continue;
    }

    if (autoscale)
    {
      unsigned max = 0, scale;
      for (int j = 0; j < S.raw_height * S.raw_width; j++)
        if (max < RawProcessor.imgdata.rawdata.raw_image[j])
          max = RawProcessor.imgdata.rawdata.raw_image[j];
      if (max > 0 && max < 1 << 15)
      {
        scale = (1 << 16) / max;
        if (verbose)
          printf("Scaling with multiplier=%d (max=%d)\n", scale, max);

        for (int j = 0; j < S.raw_height * S.raw_width; j++)
          RawProcessor.imgdata.rawdata.raw_image[j] *= scale;
      }
    }
    if (use_gamma)
    {
      unsigned short curve[0x10000];
      gamma_curve(curve);
      for (int j = 0; j < S.raw_height * S.raw_width; j++)
        RawProcessor.imgdata.rawdata.raw_image[j] =
            curve[RawProcessor.imgdata.rawdata.raw_image[j]];
      if (verbose)
        printf("Gamma-corrected....\n");
    }


    if (OUTR.shot_select)
    {
      if (out_fits>0)  {snprintf(outfn, sizeof(outfn), "%s-%d.%s", av[i], OUTR.shot_select,"fits"); }
      else
      snprintf(outfn, sizeof(outfn), "%s-%d.%s", av[i], OUTR.shot_select,
               out_tiff ? "tiff" : "pgm");
    }
    else
      {
      if (out_fits>0) {snprintf(outfn, sizeof(outfn), "%s.%s", av[i], "fits");}
      else
      snprintf(outfn, sizeof(outfn), "%s.%s", av[i], out_tiff ? "tiff" : "pgm");
      }
      

//====================================================================================================================================

    if (out_fits>0)   //FITS routine written by Han Kleijn, www.hnsky.org, FITS standard at https://fits.gsfc.nasa.gov/fits_standard.html
      {
     
      if (out_fits==3)// check if there is crop data available
         {if ((S.raw_inset_crops[0].cwidth == 0) && (S.raw_inset_crops[0].cleft == 0xffff)) //thumb size is 0 or cleft is undefined, fall back to out_fits=2. Happens for .PEF format
         { printf("Cropped active area undefined! Will export full active sensor area.\n");
           out_fits=2;} 
         }       

      if (out_fits==1) //export full sensor data including masked dark areas
         {width2 = S.raw_width;    
          height2 = S.raw_height;    
          left_margin = 0;
          top_margin = 0; }
          
      if (out_fits==2) //export active area
         {width2 = S.width;    
          height2 = S.height;    
          left_margin = S.left_margin;
          top_margin = S.top_margin; }
          
      if (out_fits==3) //export default cropped active area 
         {width2 = S.raw_inset_crops[0].cwidth;
          height2 = S.raw_inset_crops[0].cheight;    
          left_margin = S.raw_inset_crops[0].cleft;
          top_margin = S.raw_inset_crops[0].ctop; }
         
   

      strcpy(fits_header,"SIMPLE  =                    T / FITS header                                      ");
      fits_header[80]='\0'; // length should be exactly 80

      strcpy(str,        "BITPIX  =                   16 / Bits per entry                                   ");
      str[80]='\0'; strcat(fits_header,str);//line 2. Length of each keyword record should be exactly 80
      strcpy(str,        "NAXIS   =                    2 / Number of dimensions                             ");
      str[80]='\0'; strcat(fits_header,str);//line 3. Length of each keyword record should be exactly 80

      sprintf(str,"NAXIS1  = %20d / Length of x axis                                                     ", (long int)width2);// long int is required for the correct formating
      str[80]='\0'; strcat(fits_header,str);//line 4. Length of each keyword record should be exactly 80

      sprintf(str,"NAXIS2  = %20d / Length of y axis                                                     ", (long int)height2);
      str[80]='\0'; strcat(fits_header,str);//line 5. Length of each keyword record should be exactly 80

      sprintf(str,"EXPTIME = %20G   / Exposure time in seconds                                             ",(double)P2.shutter);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80

      julianday= 2440587.5+ (double)P2.timestamp/(24.0*60.0*60.0);//Julian Day of begin exposure. Convert Unix (time is seconds since 1.1.1970) to Julian Day by adding a factor}
      sprintf(str,"JD      = %20.8f / [Julian Day] The start time of the exposure                           ",julianday);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80           x

      JDtoDate(julianday, &year, &month, &day,&hh,&mm,&ss);// convert to date
      sprintf(str,"DATE-OBS= '%4.4i-%2.2i-%2.2iT%2.2i:%2.2i:%06.3f' / [UTC] The start time of the exposure                                 ", year, month, day,hh,mm,ss);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80                                          x

      if (P3.SensorTemperature>-999) {temperature=P3.SensorTemperature;}
      else
      if (P3.CameraTemperature>-999) {temperature=P3.CameraTemperature;}
      else
      {temperature=999;}

      sprintf(str,"CCD-TEMP= %20G / Sensor or camera temperature                                         ",(double)temperature);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80

      sprintf(str,"GAIN    = %20d / ISO speed                                                            ",(long int)P2.iso_speed);// long int is required for the correct formating
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      
      if (C.cblack[0] != 0)
      {
      sprintf(str,"PEDESTAL= %20d / Black level                                                          ",(long int)C.cblack[0]);// long int is required for the correct formating
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      sprintf(str,"PEDESTA2= %20d                                                                        ",(long int)C.cblack[1]);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      sprintf(str,"PEDESTA3= %20d                                                                        ",(long int)C.cblack[2]);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      sprintf(str,"PEDESTA4= %20d                                                                        ",(long int)C.cblack[3]);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      }

      if (C.linear_max[0] != 0)
      {
      sprintf(str,"DATAMAX = %20d / Max value where still linear                                         ",(long int)C.linear_max[0]);// long int is required for the correct formating
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      sprintf(str,"DATAMAX2= %20d                                                                        ",(long int)C.linear_max[1]);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      sprintf(str,"DATAMAX3= %20d                                                                        ",(long int)C.linear_max[2]);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      sprintf(str,"DATAMAX4= %20d                                                                        ",(long int)C.linear_max[3]);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      }


      sprintf(str,"APERTURE= %20d / Lens aperture                                                        ",(long int)P2.aperture);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80

      sprintf(str,"FOCALLEN= %20d / Focal length lens                                                    ",(long int)P2.focal_len);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80

      sprintf(str,"CAMMAKER= '%s'                                                                        ",P1.make);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80

      sprintf(str,"INSTRUME= '%s'                                                                        ",P1.model );
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      
      sprintf(str,"TELESCOP= '%s'                                                                        ",exifLens.Lens );
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
    

      if (P1.filters)
      {
      sprintf(str,"FILT-PAT= '                '   / Filter pattern                                       ");

      	if (!P1.cdesc[3])
			P1.cdesc[3] = 'G';
		for (int i = 0; i < 16; i++)
			str[i+11]=(P1.cdesc[RawProcessor.fcol(i >> 1, i & 1)]);
        str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80


      sprintf(str,"BAYERPAT= '    '               / Bayer color pattern                                   ");
      	if (!P1.cdesc[3])
			P1.cdesc[3] = 'G';
		for (int i = 0; i < 4; i++)
			str[i+11]=(P1.cdesc[RawProcessor.fcol(i >> 1, i & 1)]);
        str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      }

      sprintf(str,"IMG_FLIP= %20d                                                                         ",(long int)S.flip);
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80

      sprintf(str,"COMMENT   Raw conversion by LibRaw-with-16-bit-FITS-support. www.hnsky.org             ");
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80
      


      strcpy(str,"END                                                                                     ");
      str[80]='\0'; strcat(fits_header,str);// Length of each keyword record should be exactly 80

      for (unsigned i = strlen(fits_header)-1; i < 2880; i += 1)  //complete to 2880
        fits_header[i]=' ';//fill with space
      fits_header[2880]='\0';//header should be a multiply of 38 records equals 2880 bytes
      
      write_fits(fits_header,S.raw_width, S.raw_height, left_margin, top_margin,width2, height2, RawProcessor.imgdata.rawdata.raw_image, outfn);
      }
//====================================================================================================================================

      else
      {
      if (out_tiff)
        {write_tiff(S.raw_width, S.raw_height,
                  RawProcessor.imgdata.rawdata.raw_image, outfn); } 
        else  //write ppm with meta data as comments
        {
        sprintf(str,"%g",P2.shutter);                          strcpy(meta,"# EXPTIME=");   strcat(meta,str);
        sprintf(str, "%d",(long int)P2.timestamp);                  strcat(meta,"# TIMESTAMP="); strcat(meta,str);
        sprintf(str, "%d",(long int)P3.SensorTemperature);          strcat(meta,"# CCD-TEMP=");  strcat(meta,str);
        sprintf(str, "%d",(long int)P3.CameraTemperature);          strcat(meta,"# CAM-TEMP=");  strcat(meta,str);
        sprintf(str, "%d",(long int)P2.iso_speed);                  strcat(meta,"# ISOSPEED=");  strcat(meta,str);
        sprintf(str, "%0.1f",P2.aperture);                     strcat(meta,"# APERTURE=");  strcat(meta,str);
        sprintf(str, "%d",(long int)P2.focal_len);                  strcat(meta,"# FOCALLEN=");  strcat(meta,str);
        sprintf(str, "%s", P1.make);                           strcat(meta,"# MAKE=");      strcat(meta,str);
        sprintf(str, "%s", P1.model);                          strcat(meta,"# MODEL=");     strcat(meta,str);
        sprintf(str, "%s", exifLens.Lens);                     strcat(meta,"# LENS=");      strcat(meta,str);

        write_ppm(meta,S.raw_width, S.raw_height,
                RawProcessor.imgdata.rawdata.raw_image, outfn);
        }          
      }

    if (verbose)
      printf("Stored to file %s\n", outfn);
  }
  return 0;
}



void write_ppm(char meta[],unsigned width, unsigned height, unsigned short *bitmap,
               const char *fname)
{
  if (!bitmap)
    return;

  FILE *f = fopen(fname, "wb");
  if (!f)
    return;
  int bits = 16;

  fprintf(f,"P5\n%s\n", meta);
  fprintf(f, "%d %d\n%d\n", width, height, (1 << bits) - 1);

  unsigned char *data = (unsigned char *)bitmap;
  unsigned data_size = width * height * 2;
#define SWAP(a, b)                                                             \
  {                                                                            \
    a ^= b;                                                                    \
    a ^= (b ^= a);                                                             \
  }
  for (unsigned i = 0; i < data_size; i += 2)
    SWAP(data[i], data[i + 1]);
#undef SWAP
  fwrite(data, data_size, 1, f);
  fclose(f);
}

/*  == gamma curve and tiff writer - simplified cut'n'paste from dcraw.c */

#define SQR(x) ((x) * (x))

void gamma_curve(unsigned short *curve)
{

  double pwr = 1.0 / 2.2;
  double ts = 0.0;
  int imax = 0xffff;
  int mode = 2;
  int i;
  double g[6], bnd[2] = {0, 0}, r;

  g[0] = pwr;
  g[1] = ts;
  g[2] = g[3] = g[4] = 0;
  bnd[g[1] >= 1] = 1;
  if (g[1] && (g[1] - 1) * (g[0] - 1) <= 0)
  {
    for (i = 0; i < 48; i++)
    {
      g[2] = (bnd[0] + bnd[1]) / 2;
      if (g[0])
        bnd[(pow(g[2] / g[1], -g[0]) - 1) / g[0] - 1 / g[2] > -1] = g[2];
      else
        bnd[g[2] / exp(1 - 1 / g[2]) < g[1]] = g[2];
    }
    g[3] = g[2] / g[1];
    if (g[0])
      g[4] = g[2] * (1 / g[0] - 1);
  }
  if (g[0])
    g[5] = 1 / (g[1] * SQR(g[3]) / 2 - g[4] * (1 - g[3]) +
                (1 - pow(g[3], 1 + g[0])) * (1 + g[4]) / (1 + g[0])) -
           1;
  else
    g[5] = 1 / (g[1] * SQR(g[3]) / 2 + 1 - g[2] - g[3] -
                g[2] * g[3] * (log(g[3]) - 1)) -
           1;
  for (i = 0; i < 0x10000; i++)
  {
    curve[i] = 0xffff;
    if ((r = (double)i / imax) < 1)
      curve[i] =
          0x10000 *
          (mode ? (r < g[3] ? r * g[1]
                            : (g[0] ? pow(r, g[0]) * (1 + g[4]) - g[4]
                                    : log(r) * g[2] + 1))
                : (r < g[2] ? r / g[1]
                            : (g[0] ? pow((r + g[4]) / (1 + g[4]), 1 / g[0])
                                    : exp((r - 1) / g[2]))));
  }
}

void tiff_set(ushort *ntag, ushort tag, ushort type, int count, int val)
{
  struct libraw_tiff_tag *tt;
  int c;

  tt = (struct libraw_tiff_tag *)(ntag + 1) + (*ntag)++;
  tt->tag = tag;
  tt->type = type;
  tt->count = count;
  if ((type < LIBRAW_EXIFTAG_TYPE_SHORT) && (count <= 4))
    for (c = 0; c < 4; c++)
      tt->val.c[c] = val >> (c << 3);
  else if (tagtypeIs(LIBRAW_EXIFTAG_TYPE_SHORT) && (count <= 2))
    for (c = 0; c < 2; c++)
      tt->val.s[c] = val >> (c << 4);
  else
    tt->val.i = val;
}
#define TOFF(ptr) ((char *)(&(ptr)) - (char *)th)

void tiff_head(int width, int height, struct tiff_hdr *th)
{
  int c;
  time_t timestamp = time(NULL);
  struct tm *t;

  memset(th, 0, sizeof *th);
  th->t_order = htonl(0x4d4d4949) >> 16;
  th->magic = 42;
  th->ifd = 10;
  tiff_set(&th->ntag, 254, 4, 1, 0);
  tiff_set(&th->ntag, 256, 4, 1, width);
  tiff_set(&th->ntag, 257, 4, 1, height);
  tiff_set(&th->ntag, 258, 3, 1, 16);
  for (c = 0; c < 4; c++)
    th->bps[c] = 16;
  tiff_set(&th->ntag, 259, 3, 1, 1);
  tiff_set(&th->ntag, 262, 3, 1, 1);
  tiff_set(&th->ntag, 273, 4, 1, sizeof *th);
  tiff_set(&th->ntag, 277, 3, 1, 1);
  tiff_set(&th->ntag, 278, 4, 1, height);
  tiff_set(&th->ntag, 279, 4, 1, height * width * 2);
  tiff_set(&th->ntag, 282, 5, 1, TOFF(th->rat[0]));
  tiff_set(&th->ntag, 283, 5, 1, TOFF(th->rat[2]));
  tiff_set(&th->ntag, 284, 3, 1, 1);
  tiff_set(&th->ntag, 296, 3, 1, 2);
  tiff_set(&th->ntag, 306, 2, 20, TOFF(th->date));
  th->rat[0] = th->rat[2] = 300;
  th->rat[1] = th->rat[3] = 1;
  t = localtime(&timestamp);
  if (t)
    sprintf(th->date, "%04d:%02d:%02d %02d:%02d:%02d", t->tm_year + 1900,
            t->tm_mon + 1, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec);
}

void write_tiff(int width, int height, unsigned short *bitmap, const char *fn)
{
  struct tiff_hdr th;

  FILE *ofp = fopen(fn, "wb");
  if (!ofp)
    return;
  tiff_head(width, height, &th);
  fwrite(&th, sizeof th, 1, ofp);
  fwrite(bitmap, 2, width * height, ofp);
  fclose(ofp);
}


void JDtoDate(double jd,  int *year, int *month, int *day, int *hours, int *minutes, double *seconds) //converts a Julian day to a calendar Date and Time according Meeus
  {
  int alpha, AA, BB, CC, DD, EE, ZZ;
  double FF,dayFloat,dayFrac;

  jd += 0.5;
  ZZ = (int)jd; // truncate
  FF = jd - ZZ;  // fractional part
  if(ZZ < 2299160.5)  //Julian calendar?
     AA = ZZ;
  else{  //Gregorian calendar
    alpha = (int)((ZZ - 1867216.25) / 36524.25);
    AA = ZZ + 1 + alpha - (int)(alpha / 4.0);
    }
  BB = AA + 1524;
  CC = (int)((BB - 122.1) /365.25);
  DD = (int)(365.25 * CC);
  EE = (int)((BB - DD) /30.6001);
  dayFloat = BB - DD - (int)(30.6001 * EE) + FF;//days including hours, minutes and seconds
  *day= (int)dayFloat;// same as trunc()

  if( EE < 14)
     *month = EE - 1;
  else
    *month = EE - 13;
  if(*month > 2)
    *year = CC - 4716;
  else
    *year = CC - 4715;

  // calculate hours, minutes and seconds from day fraction    
  dayFrac=dayFloat - *day;//calculate day fraction
  *hours=(int)(dayFrac*24);
  *minutes=(int)((dayFrac-(float)*hours/24.0)*(24*60));//not round otherwise 23:60
  *seconds=(dayFrac-(float)*hours/24.0-(float)*minutes/(24.0*60.0))*(24*3600);

    
  // 2459902.12214120
  // 2022-11-18 14:55:53
  //      18T14:55:52.999690175053
}



void write_fits(char fits_header[],unsigned width, unsigned height, unsigned left_margin, unsigned top_margin,unsigned  width2,unsigned height2, unsigned short *bitmap,
                const char *fname)
//FITS routine written by Han Kleijn, www.hnsky.org, FITS standard at https://fits.gsfc.nasa.gov/fits_standard.html
{
  double  frac;
  int remain, buff;
  long int counter;

  if (!bitmap)
    return;

  FILE *f = fopen(fname, "wb");
  if (!f)
    return;
  int bits = 16;

  fprintf(f,"%s", fits_header);//write fits header

  unsigned char *data = (unsigned char *)bitmap;
  unsigned data_size = width * height * 2;
  

  // skip unused sensor areas and convert to big endian 
  counter = 0;  
  data_size=(width2) * (height2)*2 ;// new size of cropped image
  for (unsigned y = 0; y < (height); y++) //scan through full raw data in pixel steps equals 16 bit
     for (unsigned x = 0; x < (width); x++)  
       {
       if ((x>=left_margin) && (x<(left_margin+width2))  && (y>=top_margin)  && (y<top_margin+height2)) 
       {
        buff=  data[(x+y*width)*2  ];// extract and at the same time convert to big-endian
        data[counter]=data[(x+y*width)*2+1];
        data[counter+1]=buff;
        counter = counter +2;           
       } 
       }   

  fwrite(data, data_size, 1, f);//write fits data block

  frac = (double)data_size/2880 - data_size/2880; // Calculate the fractional part of 2880 blocks
  remain=2880-(int)(0.1+frac*2880);// how much to write to reach multiply of 2880 bytes
  fwrite(data,remain , 1, f); //extend the file with something till a multiply of 2880 is reached

  fclose(f);
}



