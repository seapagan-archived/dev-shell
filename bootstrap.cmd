@echo off
rem *********************************************************************************
rem * dev-shell Bootstrap v0.1                                                      *
rem *                                                                               *
rem * This command script will bootstrap the checked out git source into a complete *
rem * development system for MinGW / MSYS.                                          *
rem *                                                                               *
rem * Usage : double-click or run from the command line, runs fully automatically.  *
rem *********************************************************************************

rem note that there is limited error checking or idiot-proofing in the file at this time.

SETLOCAL
echo dev-shell bootstrap v0.1 (c) seapagan 2015
echo.  
echo Downloading the 'TinyPerl' distribution ...
%~dp0mingw32\wget -q --show-progress -c --trust-server-names -c --directory-prefix=%~dp0support\packages http://sourceforge.net/projects/tinyperl/files/tinyperl/2.0/tinyperl-2.0-580-win32.zip/download
if NOT EXIST %~dp0support\packages\tinyperl-2.0-580-win32.zip (
	echo Failure to download tinyperl distribution, please check your internet connection and report as a bug otherwise!
	echo.
	pause
	exit /b 255
)
echo.
echo Unpacking TinyPerl ...
%~dp0support\unzip.exe %~dp0support\packages\tinyperl-2.0-580-win32.zip -d %~dp0support
move %~dp0support\tinyperl* %~dp0support\tinyperl
ENDLOCAL
pause

