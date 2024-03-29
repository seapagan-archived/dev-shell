# Windows-based MinGW/MSYS Development System.

**NOTE: This repository is now Archived and no further work expected to be done on it. The MSys/MinGW ecosystem is now very stable with it's own package manager and no longer requires extra builds.**

__*( Version 1.0-beta.5 )*__  
A basic layout and the related support files to bootstrap a complete Windows-based MSYS / MinGW development system from the command line. This will develop into a fully portable GCC development system with Perl, Git, Ruby and similar tools.  

## Description.

This is the repository for my custom MinGW/MSYS development system on Windows. It is a custom setup using the standard MSYS, but using the [MinGW-w64 GCC distribution](http://mingw-w64.yaxm.org/doku.php) instead of the MinGW provided GCC binaries.  

__The goal of this project is to be able to make a fully-reproducible and standard development package for MinGW under MS Windows, to reduce errors and frustration caused by contributors to a project using different development bases. It can be set as a development pre-req for project participation.__

A secondary goal is to teach myself Perl programming, this being my first attempt at that language, so please excuse the bad coding, and any suggestions for improvement are more than welcome! :) Note that the '[TinyPerl](http://tinyperl.sourceforge.net/)' in use during the bootstap phase is a very cut-down version of Perl 5.8.0, so many standard modules are not available. The full Perl 5.20.2 is available to the completed system however.

The command-line environment is based around the '[Console2](http://sourceforge.net/projects/console/)' program and also includes [ANSICON](https://github.com/adoxa/ansicon) to provide ANSI escape sequences in the console.
The major bonus is that the whole system is completely portable and can be used on a USB stick on any windows system, without requiring any special prerequisite tools to be already installed on that system.

*As a major design decision this script will, __for the moment__, install the __32 BIT version__ of the MinGW compilers and libraries, Perl and Ruby.* This was to allow ultimate portability and support for the multitude of libraries already existing. Once the project is mature and stable, a 64-bit branch will be added. That being said, one of the features of this project is that all the components are taken from url lists, that also contain the unpack specs, so adding extra libraries, converting to 64-bit or even removing unwanted libraries is trivial.

## Usage.
1. From a fresh git checkout, simply run the '__bootstrap.cmd__' file in the root of the checkout which will create the full environment automatically without user intervention.  
The first time you run this, it will create a 'config.ini' file in the 'support/bootstrap' directory then exit. If you have no need to edit the settings (actually the only option at the present is to set a proxy) then you can simply run the 'bootstrap.cmd' file again and it will continue properly. If you need a proxy to access the internet then please set 'proxy=on' in this config.ini and set your proxy servers to the correct location. Once that is done, run the 'bootstrap.cmd' again to start the process.
2. Run the '__dev.cmd__' which which will now be found in the same directory to open the development environment.
3. Start coding!

In it's current stage this is designed to be used as a boilerplate for anyone wishing easier development on Windows with tools that have been designed to be run under Linux / Unix.  
This environment contains the Perl & Ruby interpreters, and will in the future include Git and more - infact the original design was to enable me to painlessly develop in Ruby on Rails under a windows environment. I have used this completed system to install and develop fully for Rails and Jekyll on Windows.

When completed, simply cloning this project and then running the bootstrap will download, install and customise the development system without user intervention.
There will be pre-compiled versions of Perl, Ruby, Git and more automatically downloaded from our [File Repository on SourceForge](https://sourceforge.net/p/devshellbuilds/) or in some cases their own developers.  
The Bootstrap is a small windows batch file, which then spawns a Perl-based system using the '[TinyPerl](http://tinyperl.sourceforge.net/)' project to create the remaining functionality. The system will re-use already-cached downloads to speed up future rebuilds.  
As the design progresses, all additional libraries and utilities that are not provided by the MinGW project will be compiled locally and then uploaded to the repository for automatic install in future versions. Many of the existing default ones will likewise be replaced by locally compiled versions. Some of these are not currently the latest versions - as the system stabilizes I will update these to the latest, and endeavour to provide further updates as they are released.

## Directory Layout
The file / folder layout is quite specific and chosen to allow the most versatility along with easy maintenance and division of standard and additional libraries etc.

There are 4 major directories, 3 of which are mapped to a specific mount point within the MSYS bash shell system. *Note that these 4 are not in the git repository, and are created automatically each time by the bootstrap scripts. As a result of this, any customizations to these directories will be __LOST__ after each run of the bootstrap script. There will be functionality to have user-created skeleton files and patches that will be applied each time the bootstrap is run (TODO)*. The final directory '*support*' is not visible within the MSYS environment.

- **home**
  - This will be the user $HOME directory, mounted under bash as **/home**. The installation directories of Ruby, Perl and Git are also located here to keep separate from MinGW and ease updating.
- **mingw32**
  - Mounted as **/mingw**. This contains the GCC compiler system and standard MinGW binaries. Will also be populated with the completed self-compiled libraries once they are deemed stable. The version of MinGW currently used is mingw-w64, 32-bit.
- **msys**
  - Contains the standard MSYS structure and bash shell. This will be the root of the filesystem as viewable within the bash shell, and the other directories above are mounted in relation to this. mounted as both **/** and **/usr** as in a standard MSYS installation.
- **support**
  - Contains support files that are not in the path and not accessible to the bash session. This includes the Console2 program, ANSICON and similar, and also the cache of downloaded binary packages. Also included in this directory are all the bootstrap scripts, and skeleton profile files, batch files etc for the complete system.

## Progress.
- [x] Populate the basic folder structure and support files.
- [x] Set up the SourceForge repository to store compiled binaries and libraries
- [x] Set up the bootstrap to create the base system.
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
    - [x] Add configuration file to tweak options - e.g. for proxy usage etc.
    - [x] Add Proxy support for bootstrap.
    - [x] Add Proxy support for Completed development environment.
- [ ] Replace and augment existing MinGW libraries and packages with locally compiled versions. __IN PROGRESS__
- [x] Add [Perl](http://www.perl.org/) 5.20.2 with fully updated CPAN and extra modules, compiled from source.
- [x] Add latest [Ruby](http://www.ruby-lang.org/) 2.2.1, compiled from source.
- [x] Add [Git](https://git-for-windows.github.io/) scm.

## TODO.
See the file [TODO.txt](TODO.txt) in the root of repository for thoughts, plans and progress.

## Caveat!
*This system as it stands on GitHub is __incomplete__ compared to my local development system*, in that some of the functionality (Git for example) is under testing. However, it is still usable in this form to compile most software that is MinGW compatible (for example the full Perl and Ruby packages were compiled using this at the current code level). Further functionality and code improvement is in progress.  

__Important :__ These versions of Perl and Ruby have been compiled for use with THIS system, and as such do not themselves contain any of the required shared dlls, so will fail to run for example from a straight cmd prompt. In addition, the batch conversions of pl and rb commands are not present. If you need standalone versions of Ruby or Perl see [Rubyinstaller](http://rubyinstaller.org) or [Strawberry Perl](http://strawberryperl.com/) respectively.

- __Perl.__
  - Please note that the existing MSYS Perl at /bin/perl is still present, as it is needed for certain of the MSYS scripts. Perl 5.20.2 is first in the search path though.
- __Ruby.__
  - This is compiled from the unpatched source, and no gem updates have been performed, nor additional gems installed. This version is compatible with Rails, Jekyll and many more. Indeed, I use this as my windows-based development system for both these.

## Links.
Below are some links to software used in this project, in addition to the ones linked above.

#### Utilities:
[A pre-compiled static version of wget 1.16.3](https://eternallybored.org/misc/wget/) - Used during the original bootstrap and copied to the completed system.  
[Unzip 6.0 from info-zip](http://www.info-zip.org/UnZip.html) - Used during bootstrap to unzip the TinyPerl and others. Self-compiled from source using this completed development system.  
[7za920.zip](http://sourceforge.net/projects/sevenzip/files/7-Zip/9.20/7za920.zip/download) - For the standalone 7-zip utility '7za.exe' which is used to unpack most of the packages that make up this development system.  
[CMake](http://www.cmake.org) - Cross-platform build system needed for the compilation of certain libraries.  
[dmake](http://search.cpan.org/dist/dmake/) - Another cross-platform build system, specifically used for building Perl and it's modules.  
[Git for Windows](https://git-for-windows.github.io/) - Their project and compilation system was used to create the Git packaged in dev-shell.

#### Perl Modules :
[File::Copy::Recursive](http://search.cpan.org/~dmuey/File-Copy-Recursive-0.38/Recursive.pm) - extended move / copy functions.  
[Portable](http://search.cpan.org/~kmx/Portable-1.22/) - used to make the Perl portable, automatically adjusting paths as needed.

#### Ruby Gems :
[rb-readline](https://github.com/ConnorAtherton/rb-readline) - Pure ruby replacement for the 'readline' functionality which is broken on Windows.
