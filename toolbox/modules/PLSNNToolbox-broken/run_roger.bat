@echo off
setlocal

echo ------------------------------------------
if "%1"=="" (
    echo Usage:
    echo    %~nx0 ^<deployedMCRroot^> args
    exit /b 1
)

echo Setting up environment variables
set MCRROOT=%1
echo ---

set "PATH=%MCRROOT%\runtime\win64;%MCRROOT%\bin\win64;%MCRROOT%\sys\os\win64;%PATH%"
echo PATH is %PATH%

shift
set args=
:parse_args
if "%1"=="" goto execute
set args=%args% "%1"
shift
goto parse_args

:execute
"%~dp0NeuralNetworkPrediction.exe" %args%
endlocal