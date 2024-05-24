@echo off
set git_list_command=git ls-tree -d -r --name-only HEAD
set all_files_command=dir /ad /b /s
set usage_message="Usage: fd [command]"
set fzf_preview_command=tree {}

set config_file="%~dp0\utils\fd.cfg"

REM call fzf command and pass all arguments
call "%~dp0\utils\fzf-win.cmd" %*   
exit /b 0
