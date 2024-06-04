@echo off
setlocal enabledelayedexpansion

set CALLER_CWD="%CD%"
set CURRENT_DIR="%~dp0"
set LOGGER="%~dp0logger.cmd"
set LOG=call %LOGGER%
set main_config_file="%~dp0fzf-win.cfg"

for /F "usebackq tokens=1,2 delims=," %%i in (!main_config_file!) do (
    set "%%i=%%j"
)

:: get the cli command from the first argument ::
:get_action
%LOG% getting action
set "command=%1"

set "file_prefix="
set "action_prefix="
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

    %LOG% %command% found in command mapping: !action_prefix! ^<filename^> !action_suffix!
) else if defined option_mapping[%command%] (
    set "label=!option_mapping[%command%]!"

    %LOG% %command% found in option mapping: jumping to !label!
    goto :!label!
) else (
    echo command not found
    goto :help
)


if "!action_prefix!" == "cd /D" (
    if not "!scriptname!" == "fd" (
        %LOG% Setting file_suffix to \..
        set "file_suffix=\.."
    )
)

:main_routine

:: build list command ::
:build_list_command
set "list_command="

if "!IS_DIR!" == "1" (

    if "%DISABLE_GIT" == "1" (
        set "list_command=dir /ad /b /s"
    ) else (
        set "list_command=!dependency_mapping[git]! ls-tree -d -r --name-only HEAD"
    )

) else (
    set "list_command=!dependency_mapping[rg]!"

    if "!DISABLE_GIT!" == "1" (
        set "list_command=!list_command! --no-ignore"
    ) else (
        set "list_command=!list_command! --ignore"
    )

    if "!DISABLE_COLOR!" == "1" (
        set "list_command=!list_command! --color=never"
    ) else (
        set "list_command=!list_command! --color=always"
    )

    if not "!DELIMITER!" == "" (
        set "list_command=!list_command! --field-match-separator !DELIMITER!"
    )

    if "!include_line_number!" == "1" (
        set "list_command=!list_command! --line-number --no-heading ^"^""
    ) else (
        set "list_command=!list_command! --files"
    )
)

goto build_preview_command

:: build preview command ::
:build_preview_command
set "preview_command="

if "!IS_DIR!" == "1" (
    set "preview_command=tree {}"
) else (
    set "preview_command=!dependency_mapping[bat]! --style=numbers"

    if "!DISABLE_COLOR!" == "1" (
        set "preview_command=!preview_command! --color=never"
    ) else (
        set "preview_command=!preview_command! --color=always"
    )

    if "!include_line_number!" == "1" (
        set "preview_command=!preview_command! --highlight-line {2} {1}"
    ) else (
        set "preview_command=!preview_command! {} "
    )


)

goto build_fzf_command

:: parses the full command from the set variables and executes it ::
:build_fzf_command

set full_command=
set fzf_command=!dependency_mapping[fzf]!

if "!fzf_command!" == "" (
    %LOG% fzf not defined using default
    set fzf_command=fzf
)

if not "!IS_DIR!" == "1" (
    if not "!DELIMITER!" == "" (
        %LOG% adding fzf delimiter arg to "!DELIMITER!"
        set fzf_command=!fzf_command! --delimiter !DELIMITER!
    )
)

if "!USE_ANSI!" == "1" (
    %LOG% enabling fzf ansi color parsing
    set fzf_command=!fzf_command! --ansi
)

if not "!preview_command!" == "" (
    %LOG% adding preview arg
    set fzf_command=!fzf_command! --preview "!preview_command!"
)

set "full_command=!list_command! ^| !fzf_command!"

%LOG% get files command: "!list_command!"
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
    goto :EOF
)

%LOG% executing full command: "!full_command!"
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
%LOG% no file selected
goto :EOF

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


:process_action
set full_action=!action_prefix! "!file!" !action_suffix!
%LOG% Excuting action "!full_action!"

endlocal & set "action=%full_action%"
%action%

goto :EOF

:: prints the help message ::
:help
echo fzf-win -- an awesome fzf wrapper for Windows
echo.
echo Usage: !scriptname! ^<command^> [option] [argument]
echo.
echo Options:
echo   -v, --version    Show version
echo   -h, --help       Show this help message
echo   -c, --command    Execute one-time command. Usage: !scriptname! -c ARG1 ARG2
echo   -l, --list       List all configured Commands
echo   -a, --add        Add new command to the config file: Usage !scriptname! -a NAME ARG1 ARG2
echo       --health     Checks if all the dependencies are accessible from the current environment
echo.
echo If you have any questions, please visit !main_page_url!
echo Please report bugs at !issues_url!

goto :EOF

:: print the current version ::
:version
echo fzf-win version: 1.0.0
goto :EOF

:: Run custom one-time command ::
:custom_command
if "%~2" == "" (
    echo No arguments given
    echo. 
    goto custom_command_help
) else if "%~2" == "--help" (
    goto custom_command_help
) else if "%~2" == "-h" (
    goto custom_command_help
)

set "action_prefix=%~2"

if not "%~3" == "" (
    set "action_suffix=%~3"
)

goto main_routine

:: Help message for --command/-c
:custom_command_help
echo Usage: !scriptname! -c ARG1 ARG2
echo.
echo The executed command is then build like this:
echo ^<ARG1^> ^<filename^> ^<ARG2^> 

goto :EOF


:: list all commands in the command_mapping
:list_commands

set "maxKeyLength=15"
echo Command:         Action:
echo ------------------------------------------------
for /f "tokens=1,2 delims==" %%A in ('set command_mapping[') do (
    set "fullkey=%%A"
    set "key=!fullkey:*[=!"
    set "key=!key:~0,-1!"

    REM get key length
    set "len=0"
    for /l %%A in (0,1,31) do (
        if not "!key:~%%A,1!"=="" set /a "len+=1"
    )

    set /a spaces=!maxKeyLength! - !len! + 1
    set "padding="
    for /l %%A in (1,1,!spaces!) do (
        set "padding=!padding! "
    )

    echo !key!:!padding!%%B
)
goto :EOF


:: Check whether the dependencies fzf rp and bat are in the env path ::
:health
set returnCode=0

for %%x in (fzf rg bat git) do (
    where /q %%x
    if errorlevel 1 (
        echo [31m%%x not found in PATH.
        echo If it is not installed, check out %%x at !dependecy_help_mapping[%%x]! for more information
        echo Please add it to your PATH or update the set path in !main_config_file!.[0m
        set returnCode=1
    ) else (
        echo [32m%%x found in PATH.[0m
    )
)

echo.
echo.
if %returnCode% == 0 (
    echo [32mAll dependencies are installed.[0m
) else (
    echo [31mSome dependencies are missing.[0m
)

echo If you want to use specific paths or are having issues you can update the paths here: !main_config_file!

endlocal 
exit /b %returnCode%

:: Add new command to the command_mapping ::
:add_command
if "%~2" == "" (
    echo No arguments given
    echo. 
    goto add_command_help
) else if "%~2" == "--help" (
    goto add_command_help
) else if "%~2" == "-h" (
    goto add_command_help
)
set "action_name=%2"

if "%3" == "" (
    echo Not enough arguments given
    echo.
    goto add_command_help
)

set "action_prefix=%3"

if not "%4" == "" (
    set "action_suffix=%4"
)

echo !action_name!=!action_prefix!,!action_suffix! >> !config_file!

goto :EOF


:: Help message for --command/-c
:add_command_help
echo Usage: !scriptname! -a NAME ARG1 ARG2
echo.
echo You can call the new command using !scriptname! NAME
echo The executed command is then build like this:
echo ^<ARG1^> ^<filename^> ^<ARG2^> 
echo The added command is saved in !config_file!

goto :EOF

:EOF
endlocal
exit /b


