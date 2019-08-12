# eGPU Detector
Disables the internal GPU when the external one is detected.

## Setup
1. Run PowerShell as admin.
2. Run `install.ps1`
3. Select your external GPU
4. After selecting your eGPU, if there is only one Plug n Play device left, the script will assume that is the iGPU. If there are more, you are required to select that one separately.
5. Voilá!

Pull requests are welcome.