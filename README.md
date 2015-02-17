# Windows-based MinGW/MSYS Development System.
A basic layout and the related support files to bootstrap a complete Windows-based MSYS / MinGW development system from the command line. This will develop into a fully portable GCC development system with Perl, Git, Ruby and similar tools.

## Description.
This is the development for my boilerplate MinGW/MSYS development system on Windows. It is a custom setup using the standard MSYS, but the [TDM GCC distribution](http://tdm-gcc.tdragon.net/) instead of the MinGW provided binaries.
The command-line environment is based around the '[Console2](http://sourceforge.net/projects/console/)' program and also includes [ANSICON](https://github.com/adoxa/ansicon) to provide ANSI escape sequences in the console. 
The major bonus is that the whole system is completely portable and can be used on a USB stick on any windows system, without requiring any special prerequisite tools to be already installed on that system.

*As a major design decision, this will install the __32 BIT version__ of the MinGW compilers.* This was to allow ultimate portability and support for the multitude of libraries already existing. I have no plans to change to 64-bit in the foreseeable future. That being said, it would be trivial to change the download links and make this a 64-bit development system, however all the pre-compiled libraries and similar would need to be recompiled from scratch.


## Usage.
In it's current stage this is designed to be used as a boilerplate for anyone wishing easier development on Windows with tools that have been designed to be run under Linux / Unix. 
It will allow the compilation and use of native Perl, Ruby, Git and many more - infact the original design was to enable me to painlessly develop in Ruby on Rails under a windows environment which was completely successful. 

When completed, simply cloning this project and then running the bootstrap will download, install and customise the development system without user intervention.
There will be pre-compiled versions of Perl, Ruby, Git and more automatically downloaded from our [File Repository on SourceForge](https://sourceforge.net/p/devshellbuilds/). The bootstrap system will also be able to re-use already-cached downloads to speed up rebuilds.
The Bootstrap will initially be a windows batch file, which will then spawn a Perl-based system using the '[TinyPerl](http://tinyperl.sourceforge.net/)' project to create the remaining functionality.
As the design progresses, all additional libraries and utilities that are not provided by the MinGW project will be compiled locally and then uploaded to the repository for automatic install in future versions.

## Progress.
1. Populate the basic folder structure and support files. | __IN PROGRESS__
2. Set up the SourceForge repository to store compiled binaries and libraries | __DONE__
3. __Bootstrap__ -> download, install and configure the base MSYS installation.
4. __Bootstrap__ -> download, install and configure the TDM GCC distribution.
5. __Bootstrap__ -> download, install and configure the base MinGW installation.

## Caveat!
*This system as it stands on GitHub is __incomplete__ compared to my local development system*, and as such is currently unusable. 
I am updating the GitHub repository as I go, and so it will soon be usable.

## Links.
Below are some links to software used in this project, other than the ones linked above.

[A precompiled static version of wget 1.16.1](https://eternallybored.org/misc/wget/) - Used during the original bootstrap until the system was able to compile its own.