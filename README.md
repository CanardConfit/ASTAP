# ASTAP - A Free Stacking and Astrometric Solver

[![License](https://img.shields.io/badge/license-MPL%202.0-blue.svg)](https://opensource.org/licenses/MPL-2.0)
[![Mirror](https://img.shields.io/badge/Mirror-SourceForge-blue?color=red)](https://sourceforge.net/p/astap-program/code/)
![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/m/CanardConfit/ASTAP)

> **Important Note** : This repository is a mirror of the original SourceForge project. Visit the SourceForge project page [here](https://sourceforge.net/p/astap-program/code/).

**ASTAP** is a free stacking and astrometric solver program for deep sky images. It is written in Object Pascal and compiled with the Free Pascal Compiler using Lazarus, the open-source cross-platform IDE.

## ASTAP Introduction

ASTAP is designed to work with astronomical images in the FITS format but can also import RAW DSLR images, XISF, PGM, PPM, TIF, PNG, and JPG images. Its native astrometric solver can be integrated with imaging programs like CCDCiel, NINA, APT, Voyager, or SGP for mount synchronization.

### Features

- Native astrometric solver, command-line compatible with PlateSolve2.
- Stacking astronomical images with dark frame and flat field correction.
- Filtering of deep sky images based on HFD value and average value.
- Alignment using an internal star match routine and internal astrometric solver.
- Mosaic building covering large areas using the astrometric linear solution WCS or WCS+SIP polynomial.
- Background equalizing.
- FITS viewer with swipe functionality, deep sky, and star annotation, photometry, and CCD inspector.
- FITS thumbnail viewer.
- Export to JPEG, PNG, TIFF (ASTRO-TIFF), PFM, PPM, PGM files.
- FITS header edit.
- FITS crop function.
- Automatic photometry calibration against Gaia database, Johnson -V, or Gaia Bm.
- CCD inspector.
- Deepsky and Hyperleda annotation.
- Solar object annotation using MPC ephemerides.
- Read/writes FITS binary and reads ASCII tables.
- Pixel math functions and digital development process.
- Display images and tables from a multi-extension FITS.
- Blink routine.
- Photometry routine.

For more informations, follow the author's website: https://www.hnsky.org/astap

### Installation

Follow the author's instructions [Here](https://www.hnsky.org/astap#installation).
