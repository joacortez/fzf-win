@echo off
set git_list_command=rg --no-heading --color=always --with-filename --line-number ""
set all_files_command=dir /a-d /b /s
set usage_message="Usage: ff [command]"
set fzf_preview_command=bat --style=numbers --color=always --highlight-line {2} {1}
set fzf_delimiter=:

set "include_line_number=1"
set config_file=%~dp0\helpers\fl.cfg

REM call fzf command and pass all arguments
call %~dp0\helpers\fzf_command.cmd %*   
exit /b 0
