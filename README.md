# Ishikawa-Type Deblurring Framework for Image and Signal Processing

This repository contains MATLAB implementations of an Ishikawa-type iterative framework for image and signal deblurring. The framework is designed to handle both two-dimensional image restoration and one-dimensional signal enhancement tasks.

## 🚀 Methods Implemented

The following restoration methods are implemented and compared:

* Proposed Ishikawa-type iterative method
* Wiener deconvolution
* Lucy–Richardson deconvolution
* TV-ADMM deblurring
* FISTA-based deblurring

## 🧩 Project Structure

The project has been modularized into multiple helper functions:

* Core algorithm implementations are separated into individual `.m` files
* A total of **multiple helper functions (13+ files)** are used
* Main execution script:
  `ishikawa_main_selected_clean.m`

Signal-related experiments are located in:

* `signal_processing/`

## ⚙️ Features

* Motion blur + Gaussian noise simulation
* Image and signal restoration
* PSNR & SSIM evaluation
* High-resolution (300 DPI) figure generation
* Excel-based result reporting
* Sensitivity analysis experiments

## 🖥️ Requirements

* MATLAB
* Image Processing Toolbox

## ▶️ How to Run

1. Clone or download the repository

2. Ensure all `.m` files are in the same directory (or keep the provided structure)

3. Open MATLAB

4. Set input/output paths in:

   `ishikawa_main_selected_clean.m`

5. Run:

   ```matlab
   ishikawa_main_selected_clean
   ```

## 📂 Input Data

### Image Dataset

The following test images are expected:

* `04.png` (Starfish)
* `06.png` (Plane)
* `09.png` (Woman)
* `10.png` (Boats)
* `11.png` (Pirate)
* `12.png` (Couple)

### Signal Data

Signal experiments are implemented in:

* `signal_processing/`

Users can define custom signals or use synthetic data.

## 📊 Output

The framework produces:

* Comparison figures (300 DPI)
* PSNR & SSIM tables (Excel format)
* Bar charts
* Sensitivity analysis results

## 🔁 Reproducibility

* Fixed random seed: `rng(0)`
* Input normalization: `[0,1]`
* All parameters defined in the main script

## 🔬 Signal Processing Extension

The Ishikawa-type framework is extended to one-dimensional signals, demonstrating its flexibility across different data modalities.

## 📝 Notes

Parts of the development process were supported by AI-assisted tools (ChatGPT) for debugging and code refinement. The author is responsible for the final implementation.

## 📌 Citation

If you use this code, please cite:

Esra Yolaçan,
*A two-step iterative framework for signal and image deblurring using G-I-Nonexpansive Mappings*,
PLOS ONE (under review)

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.
