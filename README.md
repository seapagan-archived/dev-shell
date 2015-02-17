# dev-shell
A basic layout and support files for a Windows-based MSYS / MinGW development system.

## Description.
This is the development for my boilerplate MinGW/MSYS development system on Windows. It is a custom setup using the standard MSYS, but the [TDM GCC distribution](http://tdm-gcc.tdragon.net/) instead of the MinGW provided binaries.
The command-line environment is based around the '[Console2](http://sourceforge.net/projects/console/)' program and also includes [Ansicon](https://github.com/adoxa/ansicon) to provide ANSI escape sequences in the console. 
The major bonus is that the whole system is completely portable and can be used on a USB stick on any windows system, without requiring any special prerequisite tools installed on that system.

## Usage.
In it's current stage this is designed to be used as a boilerplate for anyone wishing easier development on Windows with tools that have been designed to be run under Linux / Unix. 
It allows the compilation and use of native Perl, Ruby, Git and many more - infact the original design was to enable me to painlessly develop in Ruby on Rails under a windows environment which was completely successful. 

When complete, simply cloning this project and then running the bootstrap will download, install and customise the development system without user intervention.
There will be recipes to compile and install Perl, Ruby, Git and more.

## Caveat!
*This system as it stands on GitHub is __incomplete__ compared to my local development system*, and is a work in progress to standardise my system to generic use.