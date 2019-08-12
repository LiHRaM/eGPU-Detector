# eGPU Detector
Disables the internal GPU when the external one is detected.

## Setup

1. Run `install.ps1` with PowerShell as admin.
2. Select your external GPU
3. After selecting your eGPU, if there is only one Plug n Play device left, the script will assume that is the iGPU. If there are more, you are required to select that one separately.
4. Voilá!

Pull requests are welcome.