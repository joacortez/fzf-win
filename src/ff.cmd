@echo off
set git_list_command=git ls-files --cached --others --exclude-standard
set all_files_command=dir /a-d /b /s
set usage_message="Usage: ff [command]"
set fzf_preview_command=bat --style=numbers --color=always {}

set config_file=%~dp0\helpers\ff.cfg

REM call fzf command and pass all arguments
call %~dp0\helpers\fzf_command.cmd %*   
exit /b 0