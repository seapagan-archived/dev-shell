use strict;
use warnings;
use File::Basename;
use File::Path 'rmtree';
use File::Copy 'cp';
use File::Copy::Recursive 'dircopy';
use Cwd 'abs_path';

use My::Bootstrap;

# NOTE : We need to get the base path of the system, but in TinyPerl $0 does not work so it is difficult
# to get the proper script location as the usual standard methods will fail.
# To get past this when we run this from the standard bootstrap.cmd, first we CD to the bootstrap directory.
# This allows us to run the script from its own directory directly for testing.

# Script currently messy, will be rebased once functional.

# Generic result variable
my $result;

# Cache directories to store MSYS / MinGW packages...
my $msys_cache = $package_directory."/msys";
my $mingw_cache = $package_directory."/mingw";
my $tdm_cache = $package_directory."/tdm";
my $local_cache = $package_directory."/local";

my $path_to_urls;



# ------------------------------------------------------------------------------
# We need a few support utilities, this will also include Console and ANSICON.
print "Stage 2 : Download assorted support utilities.\n\n";
# load the Support tools URL's into an array from the file 'msys-urls'...
$path_to_urls = $base_directory."/urls/support-urls";
my ($toolsurls, $toolsfiles) = geturls($path_to_urls);
my @util_filenames = getfiles($package_directory, @$toolsurls);
my @util_filespecs = @$toolsfiles;

# get the 'extra' files...
$path_to_urls = $base_directory."/urls/extras-urls";
my ($extraurls, $extrafiles) = geturls($path_to_urls);
my @extra_filenames = getfiles($package_directory, @$extraurls);
my @extra_filespecs = @$extrafiles;

# ------------------------------------------------------------------------------
print "\nStage 3 : Download MSYS packages to local cache.\n\n";
# load the MSYS URL's into an array from the file 'msys-urls'...
$path_to_urls = $base_directory."/urls/msys-urls";
my ($msysurls, $msysfiles) = geturls($path_to_urls);

# create the MSYS Cache directory if it does not exist...
create_dir($msys_cache);
# get all the MSYS packages we need...
my @msys_filenames = getfiles($msys_cache, @$msysurls);
my @msys_filespecs = @$msysfiles;


# ------------------------------------------------------------------------------
print "\nStage 4 : Download MinGW packages to local cache.\n\n";
# load the minGW URL's into an array from the file 'mingw-urls'...
$path_to_urls = $base_directory."/urls/mingw-urls";
my ($mingwurls, $mingwfiles) = geturls($path_to_urls);

# create the MinGW Cache directory if it does not exist...
create_dir($mingw_cache);
# get all the minGW packages we need...
my @mingw_filenames = getfiles($mingw_cache, @$mingwurls);
my @mingw_filespecs = @$mingwfiles;


# ------------------------------------------------------------------------------
print "\nStage 5 : Download TDM GCC Compiler packages to local cache.\n\n";
# load the GCC URL's into an array from the file 'tdm-gcc-urls'...
$path_to_urls = $base_directory."/urls/tdm-gcc-urls";
my ($gccurls, $gccfiles) = geturls($path_to_urls);

# create the MinGW Cache directory if it does not exist...
create_dir($tdm_cache);
# get all the GCC packages we need...
my @gcc_filenames = getfiles($tdm_cache, @$gccurls);
my @gcc_filespecs = @$gccfiles;


# ------------------------------------------------------------------------------
print "\nStage 6 : Download Updated packages to local cache.\n\n";
# load the URL's into an array from the file 'local-urls'...
$path_to_urls = $base_directory."/urls/local-urls";
my ($localurls, $localfiles) = geturls($path_to_urls);

# create the Local Cache directory if it does not exist...
create_dir($local_cache);
# get all the packages we need...
my @local_filenames = getfiles($local_cache, @$localurls);
my @local_filespecs = @$localfiles;


# ------------------------------------------------------------------------------
print "\nStage 7 : Unpack support utilities.\n";
# Unpack 7za, console, ANSICON etc.
# ------------------------------------------------
# : Source path is $package_directory
# : Destination Path will be $support_directory
# : Filenames are stored in @util_filenames
# : FileSpecs (those to be unpacked) are stored in @util_filespecs.
# ------------------------------------------------
$result = unpack_file($package_directory, $support_directory, \@util_filenames, \@util_filespecs);


# ------------------------------------------------------------------------------
print "\nStage 8 : Unpack Extra packages into MinGW.\n";
# Unpack cmake, dmake and others than need to be in MinGW.
# ------------------------------------------------
# : Source path is $package_directory
# : Destination Path will be $mingw_directory
# : Filenames are stored in @extra_filenames
# : FileSpecs (those to be unpacked) are stored in @extra_filespecs.
# ------------------------------------------------
$result = unpack_file($package_directory, $mingw_directory, \@extra_filenames, \@extra_filespecs);


# ------------------------------------------------------------------------------
print "\nStage 9 : Unpack MSYS.\n";
# Unpack MSYS distribution.
# ------------------------------------------------
# : Source path is $msys_cache
# : Destination Path will be $msys_directory
# : Filenames are stored in @msys_filenames
# : FileSpecs (those to be unpacked) are stored in @msys_filespecs.
# ------------------------------------------------
$result = unpack_file($msys_cache, $msys_directory, \@msys_filenames, \@msys_filespecs);


# ------------------------------------------------------------------------------
print "\nStage 10 : Unpack MinGW.\n";
# Unpack MinGW distribution.
# ------------------------------------------------
# : Source path is $mingw_cache
# : Destination Path will be $mingw_directory
# : Filenames are stored in @mingw_filenames
# : FileSpecs (those to be unpacked) are stored in @mingw_filespecs.
# ------------------------------------------------
$result = unpack_file($mingw_cache, $mingw_directory, \@mingw_filenames, \@mingw_filespecs);


# ------------------------------------------------------------------------------
print "\nStage 11 : Unpack GCC Packages.\n";
# Unpack GCC distribution.
# ------------------------------------------------
# : Source path is $tdm_cache
# : Destination Path will be $mingw_directory
# : Filenames are stored in @gcc_filenames
# : FileSpecs (those to be unpacked) are stored in @gcc_filespecs.
# ------------------------------------------------
$result = unpack_file($tdm_cache, $mingw_directory, \@gcc_filenames, \@gcc_filespecs);


# ------------------------------------------------------------------------------
print "\nStage 12 : Unpack Updated Packages.\n";
# Unpack GCC distribution.
# ------------------------------------------------
# : Source path is $local_cache
# : Destination Path will be $mingw_directory
# : Filenames are stored in @local_filenames
# : FileSpecs (those to be unpacked) are stored in @local_filespecs.
# ------------------------------------------------
$result = unpack_file($local_cache, $mingw_directory, \@local_filenames, \@local_filespecs);


# ------------------------------------------------------------------------------
print "\nStage 13 : Tidy up base system, removing unneeded files.\n";
# There are a few files in the standard MSYS distro that are not needed in this particular system...
# note that as of now there is no error checking ...

#print " -- MSYS : ";
my @unwanted_msys = qw(m.ico msys.bat msys.ico etc/fstab.sample etc/profile);
# now delete these...
foreach my $unwanted (@unwanted_msys) {
  unlink $msys_directory."/".$unwanted;
}
# also remove the postinstall directory as we will do this manually ourselves...
rmtree($msys_directory."/postinstall");
print " -- Done\n";


# ------------------------------------------------------------------------------
print "Stage 14 : Finalize Environment - Copy final files.\n";
# Give us a working system by copying the needed skeleton files and startup batch ...

# # create the home and local directories if not already there and the tmp ..
create_dir($root_directory."/home");
create_dir($root_directory."/local");
create_dir($msys_directory."/tmp");

# create some blank dirs that will be overmounted -
# otherwise bash shell completion does not work for these dirs.
create_dir($msys_directory."/home");
create_dir($msys_directory."/usr");
create_dir($msys_directory."/local");

# copy over assorted skeleton or configuration files to various places...
dircopy($base_directory."/skel/root/.", $root_directory) or die "Failed to copy skeleton files: $!";
dircopy($base_directory."/skel/support/.", $support_directory) or die "Failed to copy skeleton files: $!";
dircopy($base_directory."/skel/home/.", $root_directory."/home") or die "Failed to copy skeleton files: $!";
dircopy($base_directory."/skel/etc/.", $msys_directory."/etc") or die "Failed to copy skeleton files: $!";
print " -- Done\n";
