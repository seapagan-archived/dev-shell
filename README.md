# Windows-based MinGW/MSYS Development System.
A basic layout and the related support files to bootstrap a complete Windows-based MSYS / MinGW development system from the command line. This will develop into a fully portable GCC development system with Perl, Git, Ruby and similar tools.

## Description.
__IMPORTANT__

__There is a current, somewhat major, bug in this project - some of the binary packages taken from the MinGW project were compiled using the DW2 version of GCC and therefore look for that dll on running. This project however uses the SJ/LJ version of GCC and so they fail to run. I have 2 options : either switch over to the DW2 version of TDM (not really my first choice) or to recompile these using the local compiler. Probably the latter will be my final choice.__

This is the development for my boilerplate MinGW/MSYS development system on Windows. It is a custom setup using the standard MSYS, but using the [TDM GCC distribution](http://tdm-gcc.tdragon.net/) instead of the MinGW provided GCC binaries.
The command-line environment is based around the '[Console2](http://sourceforge.net/projects/console/)' program and also includes [ANSICON](https://github.com/adoxa/ansicon) to provide ANSI escape sequences in the console.
The major bonus is that the whole system is completely portable and can be used on a USB stick on any windows system, without requiring any special prerequisite tools to be already installed on that system.

*As a major design decision, this will install the __32 BIT version__ of the MinGW compilers.* This was to allow ultimate portability and support for the multitude of libraries already existing. I have no plans to change to 64-bit in the foreseeable future. That being said, one of the major features of this project is that all the components are taken from url lists, that also contain the unpack specs, so adding extra libraries, converting to 64-bit or even removing unwanted libraries is trivial.

## Usage.
1. From a fresh git checkout, simply run the '__bootstrap.cmd__' file in the root of the checkout which will create the full environment automatically without user intervention.
2. Run the '__dev.cmd__' which which will now be found in the same directory to open the development environment.
3. Start coding!

In it's current stage this is designed to be used as a boilerplate for anyone wishing easier development on Windows with tools that have been designed to be run under Linux / Unix.
It will allow the compilation and use of native Perl, Ruby, Git and many more - infact the original design was to enable me to painlessly develop in Ruby on Rails under a windows environment which was completely successful.

When completed, simply cloning this project and then running the bootstrap will download, install and customise the development system without user intervention.
There will be pre-compiled versions of Perl, Ruby, Git and more automatically downloaded from our [File Repository on SourceForge](https://sourceforge.net/p/devshellbuilds/). The bootstrap system will also be able to re-use already-cached downloads to speed up rebuilds.
The Bootstrap will initially be a windows batch file, which will then spawn a Perl-based system using the '[TinyPerl](http://tinyperl.sourceforge.net/)' project to create the remaining functionality.
As the design progresses, all additional libraries and utilities that are not provided by the MinGW project will be compiled locally and then uploaded to the repository for automatic install in future versions.

## Directory Layout
The file / folder layout is quite specific and chosen to allow the most versatility along with easy maintenance and division of standard and additional libraries etc.

There are 5 major directories, each of which is mapped to a specific mount point within the MSYS bash shell system. *Note that the first 4 are not in the git repository, and are created automatically each time by the bootstrap scripts. As a result of this, any customizations to these directories will be __LOST__ after each run of the bootstrap script. There will be functionality to have user-created skeleton files and patches that will be applied each time the bootstrap is run (TODO)*

- **home**
  - This will be the user $HOME directory, mounted under bash as **/home**
- **local**
  - Mounted as **/usr/local**. This will be used to contain other user-compiled software that is not part of the main MinGW packages. Originally this will include all the user-compiled libraries etc, which will be moved to /mingw as they are deemed stable and promoted to part of the standard system.
- **mingw32**
  - Mounted as **/mingw**. This contains the GCC compiler system and standard MinGW binaries. Will also be populated with the completed self-compiled libraries once they are deemed stable.
- **msys**
  - Contains the standard MSYS structure and bash shell. This will be the root of the filesystem as viewable within the bash shell, and the other directories above are mounted in relation to this. mounted as both **/** and **/usr** as in a standard MSYS installation.
- **support**
  - Contains support files that are not in the path and not accessible to the bash session. This includes the Console2 program, ANSICON and similar, and also the cache of downloaded binary packages. Also included in this directory are all the bootstrap scripts, and skeleton profile files, batch files etc for the complete system.

## Progress.
- [x] Populate the basic folder structure and support files.
- [x] Set up the SourceForge repository to store compiled binaries and libraries
- [ ] Set up the bootstrap to create the base system.
  - **CMD File Phase.**
    - [x] Download and unpack the TinyPerl packages to enable the Perl-based bootstrap to run.
  - **Perl Script Phase**
    - [x] Download and Unpack the supporting tools.
    - [x] Download and Unpack extra files (dmake and cmake currently)
    - [x] Download and Unpack the base MSYS installation.
    - [x] Download and Unpack the TDM GCC distribution.
    - [x] Download and Unpack the base MinGW installation.
    - [x] Remove un-needed files from the above unpacked packages.
    - [x] Copy over skeleton files, tweak configuration files and finalize base development system.
    - [ ] Add configuration file to tweak certain options - eg for proxy usage etc.

## TODO.
See the file [TODO.txt](TODO.txt) in the root of repository for thoughts, plans and progress.
## Caveat!
*This system as it stands on GitHub is __incomplete__ compared to my local development system*, __however is still usable in this basic form__. This project is for the development of the automatic bootstrap system, which will in time become a fully usable development system mirroring the manual setup I have locally.

## Links.
Below are some links to software used in this project, in addition to the ones linked above.

[A precompiled static version of wget 1.16.1](https://eternallybored.org/misc/wget/) - Used during the original bootstrap until the system was able to compile its own.  
[Unzip 6.0 from info-zip](http://www.info-zip.org/UnZip.html) - Used during bootstrap to unzip the TinyPerl and others. Self-compiled from source using this completed development system.  
[7za920.zip](http://sourceforge.net/projects/sevenzip/files/7-Zip/9.20/7za920.zip/download) - For the standalone 7-zip utility '7za.exe' which was used to unpack the MSYS / MinGW and TDM distributions along with the project-specific compiles of libraries and executables.  
[CMake](http://www.cmake.org) - Cross-platform build system needed for the compilation of certain libraries.  
[dmake](http://search.cpan.org/dist/dmake/) - Another cross-platform build system, specifically used for building Perl and it's modules.
