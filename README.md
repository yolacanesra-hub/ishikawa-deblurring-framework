# Ishikawa-Type Deblurring Framework for Image and Signal Processing

This repository contains MATLAB code for deblurring and restoration experiments based on a proposed Ishikawa-type iterative framework. The method is applied to both image and one-dimensional signal processing tasks and is compared with several classical and optimization-based approaches.

## Methods

The following methods are implemented and compared:

* Proposed Ishikawa-type restoration
* Wiener deconvolution
* Lucy–Richardson deconvolution
* TV-ADMM deblurring
* FISTA-based deblurring

## Features

* Motion blur + Gaussian noise simulation (for images)
* Signal enhancement and restoration (for 1D signals)
* PSNR and SSIM evaluation
* Visual comparison figures
* Excel result tables
* Sensitivity analysis

## Requirements

* MATLAB
* Image Processing Toolbox

## How to Run

1. Place all `.m` files in the same folder (or maintain the provided folder structure).
2. Set input/output paths in:
   ishikawa_main_selected_clean.m
3. Run:
   ishikawa_main_selected_clean

## Input Data

### Image Data

The script expects the following images:

* 04.png (Starfish)
* 06.png (Plane)
* 09.png (Woman)
* 10.png (Boats)
* 11.png (Pirate)
* 12.png (Couple)

### Signal Data

Signal processing experiments are implemented in the `signal_processing` folder. Synthetic or user-defined signals can be used as input.

## Output

* Comparison figures (300 DPI)
* PSNR & SSIM tables (Excel)
* Bar graphs
* Sensitivity analysis results

## Reproducibility

* Random seed is fixed (rng(0))
* Data are normalized to [0,1] when applicable
* All parameters are defined in the main script

## Signal Processing Extension

The proposed Ishikawa-type iterative framework is also implemented for one-dimensional signal enhancement and restoration. This extension demonstrates the flexibility and general applicability of the method across different data modalities.

## Notes

AI-assisted tools (ChatGPT) were used to support debugging and code refinement. The author takes full responsibility for the correctness and integrity of the implementation.

## Citation

If you use this code, please cite:

Esra Yolaçan, "A two-step iterative framework for signal and image deblurring using G-I-Nonexpansive Mappings", PLOS ONE (under review).

## License

This project is licensed under the MIT License. See the LICENSE file for details.
