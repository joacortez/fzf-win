@echo off
setlocal enabledelayedexpansion

:: Set common variables
set "version=v0.0.2"
set "platform=Windows"
set "installerdir=installer\"
set "builddir=build\"

:: Loop over each architecture
for %%A in (x64 x86) do (
    :: Set architecture specific variables
    set "arc=%%A"
    set "outdir=!builddir!!arc!\"

    echo.
    echo ========================================
    echo Building for architecture: !arc!
    echo ========================================

    :: Display the output directory
    echo Output directory: !outdir!

    :: Delete everything in the outdir
    echo Deleting old files in !outdir!
    del /q !outdir!*
    echo.

    :: Set WiX Toolset specific variables
    set "wix_files=!installerdir!LicenseAgreementDlg_HK.wxs !installerdir!WixUI_HK.wxs !installerdir!product.wxs"
    set "wix_output=!outdir!fzf-win_!version!_!arc!_!platform!.msi"
    set "wix_objects=!outdir!LicenseAgreementDlg_HK.wixobj !outdir!WixUI_HK.wixobj !outdir!product.wixobj"

    :: Build using WiX Toolset
    echo Building with WiX Toolset for !arc!
    echo.
    echo Running candle...
    candle -arch !arc! !wix_files! -out !outdir! -nologo
    echo.
    echo Running light...
    light -ext WixUIExtension -ext WixUtilExtension -sacl -spdb  -out !wix_output! !wix_objects! -nologo
    echo.
    echo Saved output to: !wix_output!
    echo ========================================



)

endlocal