@echo off
setlocal

:: log function for debugging purposes ::
if "%LOG_LEVEL%"=="1" (
    echo %*
)
exit /b