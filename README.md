# ORG-signal-extraction
This repository provides demo code for extracting ORG signals.

## System Requirements
The code has been tested under the following configurations:
- **macOS Sonoma**: MATLAB R2021a
- **Red Hat Enterprise Linux 8.10**: MATLAB R2022b

No non-standard hardware or customized software is required.

## File Descriptions
1. **ORG_signal_extraction**: Extract ORG signals from an example dataset. A flash sequence of green-UV-green-UV was delivered during the OCT recording, as detailed below.
2. **example_data** (will be downloaded when running ORG_signal_extraction.m):
   - `I_reg.mat`: Registered complex-valued OCT data (200 × 512 × 4000, z × x × t). The repeated B-scans were flattened along the IS/OS band.
   - OCT recording: 4000 repeated B-scans captured at a 10 kHz frame rate.
   - Green flash: 1 ms, 340 μJ; UV flash: 1 ms, 112 μJ.
   - Timing: pre-stimulus time was 10.04 ms (~100 frames), and the interval between adjacent flashes was 100 ms.
3. **LICENSE**: License details.
4. **README**: This document.

## Instructions for Use
1. Run `ORG_signal_extraction.m` in MATLAB.
2. Performance
   - On macOS with an Apple M1 chip, the signal extraction takes ~100 seconds (excluding data download time).
3. Output
   - The ORG signal will be saved in "analysis" and "figures" folders within the dataset directory.

## Reference
https://www.biorxiv.org/content/10.1101/2025.04.02.646910v1

## Contact Information
**Huakun Li**
- Email: HUAKUN001@e.ntu.edu.sg 
