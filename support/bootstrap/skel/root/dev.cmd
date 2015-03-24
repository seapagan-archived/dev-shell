@echo off

set HOMEPATH=%~dp0home
set HOME=%HOMEPATH%
set USERPROFILE=%HOMEPATH%

set APPDATA=%HOMEPATH%\AppData\Roaming
set LOCALAPPDATA=%HOMEPATH%\AppData\Local

set USERNAME=seapagan
set COMPUTERNAME=development
set HOSTNAME=%COMPUTERNAME%
set TMP=%~dp0msys\tmp

rem set location of SSL certificates...
set SSL_CERT_FILE=%HOME%\ca-bundle.crt

rem update the fstab to point to the correct drive, as it may have changed...
echo %~dp0mingw32 /mingw > %~dp0msys\etc\fstab
rem echo %~dp0local /usr/local >> %~dp0msys\etc\fstab
echo %~dp0home /home >> %~dp0msys\etc\fstab

cd %HOME%

start %~dp0support\console
