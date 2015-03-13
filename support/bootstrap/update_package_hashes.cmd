@echo off
rem This simply runs the perl script to update package file hashes and save to
rem a local file 'hashes' in the bootstrap directory.

rem Needs to be run with at least tinyperl unpacked - best to run manually after bootstrap.


%~dp0..\tinyperl\tinyperl update_package_hashes.pl

pause
