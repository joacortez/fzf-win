@echo off
setlocal enabledelayedexpansion
set "scriptname=%~n0"
set config_file="%~dp0utils\ff.cfg"

REM call fzf command and pass all arguments
call "%~dp0utils\fzf-win.cmd" %*   
exit /b 0
