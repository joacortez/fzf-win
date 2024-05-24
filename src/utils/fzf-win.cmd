@echo off
setlocal enabledelayedexpansion

set CALLER_CWD="%CD%"
set CURRENT_DIR="%~dp0"

for /F "usebackq tokens=1,2 delims=," %%i in ("%~dp0fzf-win.cfg") do (
    set "%%i=%%j"
)

set LOGGER="%~dp0logger.cmd"
set LOG=call %LOGGER%

:: get the cli command from the first argument ::
:get_action
%LOG% getting action
set "command=%1"

set "file_prefix="

set "action_prefix="

REM TODO add support for multiple arguments in a loop
REM TODO set custom comands 
REM TODO set custom paths
REM TODO add start command

:: Read the configuration file and populate the command mappings
for /f "usebackq tokens=1,2 delims==" %%A in (%config_file%) do (
    if "%%B" == "" (
        set "command_mapping[%%B]=%%A"
        %LOG% mapping %%A to %%B
    ) else (
    set "command_mapping[%%A]=%%B"
        %LOG% mapping %%B to %%A
    )

)

:: Get the action prefix and suffix from the command mappings
if defined command_mapping[%command%] (
    for /f "tokens=1,2 delims=," %%B in ("!command_mapping[%command%]!") do (
        set "action_prefix=%%B"
        set "action_suffix=%%C"
    )
) else (
    echo %usage_message%
    exit /b
)

if "%action_prefix%" == "cd" (
    set "file_suffix=\.."
)


:: check whether the current directory is a git repository or not and set the according variables ::
:check_git_repo
set is_git_repo=false

for /f "delims=" %%i in ('git rev-parse --is-inside-work-tree 2^> NUL') do (
    if "%%i" == "true" (
        %LOG% is a repo
        set get_files_command=!git_list_command!
        set is_git_repo=true
        %LOG% get files command: !get_files_command!
        goto fzf_step
    ) else (
        %LOG% is not a git repository
        %LOG% get files command: !get_files_command!
        set is_git_repo=false
        set get_files_command=!all_files_command!
        goto fzf_step
    )
    endlocal
    @REM TODO log error
    exit /b -1
)
%LOG% is not a git repository
%LOG% get files command: %get_files_command%
set is_git_repo=false
set get_files_command=%all_files_command%
goto fzf_step

:: parses the full command from the set variables and executes it ::
:fzf_step
%LOG% fuzzy step

set full_command=
set fzf_command=

if "%fzf_path%" == "" (
    %LOG% fzf not defined using default
    set fzf_command=fzf
) else (
    set fzf_command=%fzf_path%
)

if not "%fzf_delimiter%" == "" (
    %LOG% adding fzf delimiter arg to "%fzf_delimiter%"
    set fzf_command=%fzf_command% --delimiter %fzf_delimiter%
)

if not "%fzf_disable_ansi%" == "1" (
    %LOG% enabling fzf ansi color parsing
    set fzf_command=%fzf_command% --ansi
)

if not "%fzf_preview_command%" == "" (
    %LOG% adding preview arg
    set fzf_command=%fzf_command% --preview "!fzf_preview_command!"
)

set "full_command=!get_files_command! ^| !fzf_command!"

%LOG% get files command: "!get_files_command!"
%LOG% fzf command: "!fzf_command!"
%LOG% full_command: "!full_command!"
%LOG% action_prefix: %action_prefix%

if "!full_command!" == "" (
    @REM TODO log error
    %LOG% full command is empty

    endlocal
    exit /b -1
)


REM TODO show relative paths in fzf

if "%DEBUG_MODE%" == "1" (
    %LOG% executing full command: "!full_command!"

    goto :EOF
)

for /f "delims=" %%i in ('!full_command!') do (
    set "result=%%i"

    if "%include_line_number%" == "1" (
        goto :process_with_line
    ) else (
        goto :process_without_line
    )

    endlocal
    exit /b -1
)

    :process_with_line
    %LOG% processing with line !result!
    :: Extract filename, line number, and content
    for /f "tokens=1-3 delims=:" %%A in ("!result!") do (
        set "filename=%%A"
        set "line_number=%%B"
        set "content=%%C"

    :: Display the extracted variables (optional)
    %LOG% Filename: !filename!
    %LOG% Line number: !line_number!
    %LOG% Content: !content!

    if not "!line_number!" == "" (
        %LOG% including line number
        set "line_number=:!line_number!"
    ) else (
        set "line_number="
    )

    set "file=!file_prefix!!filename!!file_suffix!!line_number!"
    %LOG% Full filename: "!file!"

    goto :process_action

    goto :EOF
    )

:process_without_line
    %LOG% processing without line
    set "file=!file_prefix!!result!!file_suffix!"
    goto :process_action
    exit /b 


:process_action
set full_action=!action_prefix! "!file!" !action_suffix!
%LOG% Excuting action "!full_action!"

endlocal & set "action=%full_action%"
%action%

:EOF
endlocal
exit /b

