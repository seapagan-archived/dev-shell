##Windows-based MinGW/MSYS Development System.

_( Version 1.0-beta )_  

This repository contains the compiled binary program and library packages used by the [dev-shell](https://github.com/seapagan/dev-shell) project on GitHub.  

'dev-shell' is a boilerplate MinGW/MSYS development system on Windows. It is a custom setup using the standard MSYS, but using the [TDM GCC distribution](http://tdm-gcc.tdragon.net/) instead of the MinGW provided GCC binaries. It also has some other benefits including a tabbed interface, ANSI code compatibility and more.

The goal of the project is to be able to make a fully-reproducible and standard development package for MinGW under MS Windows, to reduce errors and frustration caused by contributors to a project using different development bases. It can be set as a development pre-req for project participation.

Currently it just contains the compiled packages, with all the development headers and documentation contained in a single tar.lzma file for each package. This will be augmented with the original source code and any patches required to compile under MinGW.

Note that the packages can also be used in a standard MinGW / MSYS setup, and even also under plain windows. They are in the most case compiled as shared libraries, so some of them depend on other library packages being present. In the future this will be noted in each package description.

###Current Packages.
 - [unzip version 6.0](http://sourceforge.net/projects/devshellbuilds/files/unzip-6.0/unzip-6.0-mingw32-bin.tar.lzma/download)  
 - [zip-3.0](http://sourceforge.net/projects/devshellbuilds/files/zip-3.0/zip-3.0-mingw32-bin.tar.lzma/download)  
 - [gzip-1.6](http://sourceforge.net/projects/devshellbuilds/files/gzip-1.6/gzip-1.6-mingw32-bin.tar.lzma/download)  
 - [zlib-1.2.8](http://sourceforge.net/projects/devshellbuilds/files/zlib-1.2.8/zlib-1.2.8-mingw32-full.tar.lzma/download)  
 - [lzip-1.16](http://sourceforge.net/projects/devshellbuilds/files/lzip-1.16/lzip-1.16-mingw32-full.tar.lzma/download)  
 - [libiconv-1.14](http://sourceforge.net/projects/devshellbuilds/files/libiconv-1.14/libiconv-1.14-mingw32-full.tar.lzma/download)
 - [libunistring-0.9.4](http://sourceforge.net/projects/devshellbuilds/files/libunistring-0.9.4/libunistring-0.9.4-mingw32-full.tar.lzma/download)
 - [xz-5.2.0](http://sourceforge.net/projects/devshellbuilds/files/xz-5.2.0/xz-5.2.0-mingw32-full.tar.lzma/download)
 - [libxml2-2.9.2](http://sourceforge.net/projects/devshellbuilds/files/libxml2-2.9.2/libxml2-2.9.2-mingw32-full.tar.lzma/download)
 - [expat-2.1.0](http://sourceforge.net/projects/devshellbuilds/files/expat-2.1.0/expat-2.1.0-mingw32-full.tar.lzma/download)
 - [regex-2.5.1](http://sourceforge.net/projects/devshellbuilds/files/regex-2.5.1/regex-2.5.1-mingw32-full.tar.lzma/download)
 - [openssl-1.0.1j](]http://sourceforge.net/projects/devshellbuilds/files/openssl-1.0.1j/openssl-1.0.1j-mingw32-full.tar.lzma/download)
 - [nettle-3.0](http://sourceforge.net/projects/devshellbuilds/files/nettle-3.0/nettle-3.0-mingw32-full.tar.lzma/download)
 - [lzo-2.08](http://sourceforge.net/projects/devshellbuilds/files/lzo-2.08/lzo-2.08-mingw32-full.tar.lzma/download)
 - [libarchive-3.1.2](http://sourceforge.net/projects/devshellbuilds/files/libarchive-3.1.2/libarchive-3.1.2-mingw32-full.tar.lzma/download)
 - [ncurses-5.9](http://sourceforge.net/projects/devshellbuilds/files/ncurses-5.9/ncurses-5.9-mingw32-full.tar.lzma/download)
 - [readline-6.2](http://sourceforge.net/projects/devshellbuilds/files/readline-6.2/readline-6.2-mingw32-full.tar.lzma/download)
 - [gmp-6.0.0](http://sourceforge.net/projects/devshellbuilds/files/gmp-6.0.0/gmp-6.0.0-mingw32-full-SHARED.tar.lzma/download)
 - [pcre-8.36](http://sourceforge.net/projects/devshellbuilds/files/pcre-8.36/pcre-8.36-mingw32-full.tar.lzma/download)
 - [gettext-0.19.4](http://sourceforge.net/projects/devshellbuilds/files/gettext-0.19.4/gettext-0.19.4-mingw32-full.tar.lzma/download)
 - [tcl8.6.4](http://sourceforge.net/projects/devshellbuilds/files/tcl8.6.4/tcl8.6.4-mingw32-full.tar.lzma/download)
 - [tk8.6.4](http://sourceforge.net/projects/devshellbuilds/files/tk8.6.4/tk8.6.4-mingw32-full.tar.lzma/download)
 - [libssh2-1.4.3](http://sourceforge.net/projects/devshellbuilds/files/libssh2-1.4.3/libssh2-1.4.3-mingw32-full.tar.lzma/download)
 - [curl-7.40.0](http://sourceforge.net/projects/devshellbuilds/files/curl-7.40.0/curl-7.40.0-mingw32-full.tar.lzma/download)
 - [libcroco-0.6.8](http://sourceforge.net/projects/devshellbuilds/files/libcroco-0.6.8/libcroco-0.6.8-mingw32-full.tar.lzma/download)
 - [Perl-5.20.2](http://sourceforge.net/projects/devshellbuilds/files/perl-5.20.2/perl-5.20.2-1-mingw32.tar.lzma/download)