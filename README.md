# dev-shell
A basic layout and support files for a Windows-based MSYS / MinGW development system.

## Description.
This is the development for my boilerplate MinGW/MSYS development system on Windows. It is a custom setup using the standard MSYS, but the [TDM GCC distribution](http://tdm-gcc.tdragon.net/) instead of the MinGW provided binaries.
The command-line environment is based around the '[Console2](http://sourceforge.net/projects/console/)' program and also includes [ANSICON](https://github.com/adoxa/ansicon) to provide ANSI escape sequences in the console. 
The major bonus is that the whole system is completely portable and can be used on a USB stick on any windows system, without requiring any special prerequisite tools installed on that system.

## Usage.
In it's current stage this is designed to be used as a boilerplate for anyone wishing easier development on Windows with tools that have been designed to be run under Linux / Unix. 
It allows the compilation and use of native Perl, Ruby, Git and many more - infact the original design was to enable me to painlessly develop in Ruby on Rails under a windows environment which was completely successful. 

When completed, simply cloning this project and then running the bootstrap will download, install and customise the development system without user intervention.
There will be pre-compiled versions of Perl, Ruby, Git and more automatically downloaded from our repository on SourceForge (still be be created). The bootstrap system will also be able to re-use already-cached downloads to speed up rebuilds.
The Bootstrap will initially be a windows batch file, which will move over to Perl scripts once the MSYS environment is downloaded and unpacked.
As the design progresses, all additional libraries and utilities that are not provided by the MinGW project will be compiled locally and then uploaded to the repository for automatic install in future versions.

## Progress.
1. Populate the basic folder structure and support files. | __IN PROGRESS__
2. __Bootstrap__ -> download, install and configure the base MSYS installation.
3. __Bootstrap__ -> download, install and configure the TDM GCC distribution.
4. __Bootstrap__ -> download, install and configure the base MinGW installation.

## Caveat!
*This system as it stands on GitHub is __incomplete__ compared to my local development system*, and as such is currently unusable. 
I am updating the GitHub repository as I go, and so it will soon be usable.

## Links.
Below are some links to software used in this project, other than the ones linked above.

[A precompiled static version of wget 1.16.1](https://eternallybored.org/misc/wget/) - Used originally until the system was able to compile its own.