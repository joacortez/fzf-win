@echo off
setlocal enabledelayedexpansion
set "scriptname=%~n0"
set config_file="%~dp0utils\fd.cfg"

set "IS_DIR=1"

REM call fzf command and pass all arguments
call "%~dp0utils\fzf-win.cmd" %*   
exit /b 0
