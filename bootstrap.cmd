@echo off
rem *********************************************************************************
rem * dev-shell Bootstrap v1.0-beta.4                                                      *
rem *                                                                               *
rem * This command script will bootstrap the checked out git source into a complete *
rem * development system for MinGW / MSYS.                                          *
rem *                                                                               *
rem * Usage : double-click or run from the command line, runs fully automatically.  *
rem *********************************************************************************

rem note that there is limited error checking or idiot-proofing in the file at this time.

echo dev-shell bootstrap v1.0-beta.3 (c) seapagan 2015
echo.
echo Stage 1 : Download and unpack some required packages ...
rem tinyperl ...
if NOT EXIST %~dp0support\packages\tinyperl-2.0-580-win32.zip (
  %~dp0support\bootstrap\wget -q --show-progress -c --trust-server-names --directory-prefix=%~dp0support\packages http://sourceforge.net/projects/tinyperl/files/tinyperl/2.0/tinyperl-2.0-580-win32.zip/download
) ELSE (
	ECHO TinyPerl package already exists, skipping download.
)
rem md5deep ...
if NOT EXIST %~dp0support\packages\md5deep-4.4.zip (
  %~dp0support\bootstrap\wget -q --show-progress -c --directory-prefix=%~dp0support\packages https://github.com/jessek/hashdeep/releases/download/release-4.4/md5deep-4.4.zip
) ELSE (
	ECHO MD5Deep package already exists, skipping download.
)

echo.
rem erase TinyPerl directory first if exists ...
if EXIST "%~dp0support\tinyperl\" (
RD /S /Q %~dp0support\tinyperl
)
%~dp0support\bootstrap\unzip.exe -q %~dp0support\packages\tinyperl-2.0-580-win32.zip -d %~dp0support
move %~dp0support\tinyperl* %~dp0support\tinyperl > NUL
if NOT EXIST "%~dp0support\tinyperl\" (
	echo Failure to unpack the TinyPerl distribution, please report any error messages, thanks.
	pause
	exit /b 254
)

rem unpack the md5deep.exe ...
%~dp0support\bootstrap\unzip.exe -j -q -o %~dp0support\packages\md5deep-4.4.zip "md5deep-4.4\md5deep.exe" -d %~dp0support
if NOT EXIST "%~dp0support\md5deep.exe" (
	echo Failure to unpack the MD5Deep distribution, please report any error messages, thanks.
	pause
	exit /b 253
)

rem now run the perl script to continue...
cd %~dp0support\bootstrap
%~dp0support\tinyperl\tinyperl bootstrap.pl

pause
