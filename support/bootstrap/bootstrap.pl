use strict;
use warnings;
use File::Path 'rmtree';
use File::Copy;
use File::Copy::Recursive qw(dircopy fcopy);

use My::Bootstrap;
use My::ConfigFile;

# Script currently messy, will be rebased once functional.

# Generic result variable
my $result;

# see if we have a configuration file, otherwise copy a neutral skel over then stop..
if (!-e $dirs{"base"}."/config.ini") {
  copy ($dirs{"base"}."/skel/config.ini.skel", $dirs{"base"}."/config.ini") or die "cant copy config template.";
  print "\n----------------------------------------------------------------------------------------\n";
  print "No 'config.ini' found, so I have copied over a basic blank configuration file for you.\n";
  print "This can be found at \'".$dirs{"base"}."/config.ini\'\n";
  print "Once you have edited this if needed, please re-run this script.\n";
  print "----------------------------------------------------------------------------------------\n\n";
  exit;
}

# Read in the configuration file...
our %configuration = read_config($dirs{"base"}."/config.ini");
do_config(%configuration);

# Cache directories to store MSYS / MinGW packages...
my $msys_cache = $dirs{"package"}."/msys";
my $mingw_cache = $dirs{"package"}."/mingw";
my $tdm_cache = $dirs{"package"}."/tdm";
my $local_cache = $dirs{"package"}."/local";

my $path_to_urls;

# create the msys and mingw directories ...
create_dir($dirs{"root"}."/msys");
create_dir($dirs{"root"}."/mingw32");

# counter variable for the stages, make adding new ones easier ;)
my $stage_counter = 2;

# ------------------------------------------------------------------------------
# We need a few support utilities, this will also include Console and ANSICON.
print "Stage $stage_counter : Download assorted support utilities.\n";
# load the Support tools URL's into an array from the file 'msys-urls'...
$path_to_urls = $dirs{"base"}."/urls/support-urls";
my ($toolsurls, $toolsfiles) = geturls($path_to_urls);
my @util_filenames = getfiles($dirs{"package"}, @$toolsurls);
my @util_filespecs = @$toolsfiles;
$stage_counter++;


# ------------------------------------------------------------------------------
# get the 'extra' files...
print "\nStage $stage_counter : Download extra utilities to MinGW directory.\n";
$path_to_urls = $dirs{"base"}."/urls/extras-urls";
my ($extraurls, $extrafiles) = geturls($path_to_urls);
my @extra_filenames = getfiles($dirs{"package"}, @$extraurls);
my @extra_filespecs = @$extrafiles;
$stage_counter++;


# ------------------------------------------------------------------------------
print "\nStage $stage_counter : Download MSYS packages to local cache.\n";
# load the MSYS URL's into an array from the file 'msys-urls'...
$path_to_urls = $dirs{"base"}."/urls/msys-urls";
my ($msysurls, $msysfiles) = geturls($path_to_urls);

# create the MSYS Cache directory if it does not exist...
create_dir($msys_cache);
# get all the MSYS packages we need...
my @msys_filenames = getfiles($msys_cache, @$msysurls);
my @msys_filespecs = @$msysfiles;
$stage_counter++;


# ------------------------------------------------------------------------------
print "\nStage $stage_counter : Download MinGW packages to local cache.\n";
# load the minGW URL's into an array from the file 'mingw-urls'...
$path_to_urls = $dirs{"base"}."/urls/mingw-urls";
my ($mingwurls, $mingwfiles) = geturls($path_to_urls);

# create the MinGW Cache directory if it does not exist...
create_dir($mingw_cache);
# get all the minGW packages we need...
my @mingw_filenames = getfiles($mingw_cache, @$mingwurls);
my @mingw_filespecs = @$mingwfiles;
$stage_counter++;


# ------------------------------------------------------------------------------
print "\nStage $stage_counter : Download TDM GCC Compiler packages to local cache.\n";
# load the GCC URL's into an array from the file 'tdm-gcc-urls'...
$path_to_urls = $dirs{"base"}."/urls/tdm-gcc-urls";
my ($gccurls, $gccfiles) = geturls($path_to_urls);

# create the MinGW Cache directory if it does not exist...
create_dir($tdm_cache);
# get all the GCC packages we need...
my @gcc_filenames = getfiles($tdm_cache, @$gccurls);
my @gcc_filespecs = @$gccfiles;
$stage_counter++;


# ------------------------------------------------------------------------------
print "\nStage $stage_counter : Download Updated packages to local cache.\n";
# load the URL's into an array from the file 'local-urls'...
$path_to_urls = $dirs{"base"}."/urls/local-urls";
my ($localurls, $localfiles) = geturls($path_to_urls);

# create the Local Cache directory if it does not exist...
create_dir($local_cache);
# get all the packages we need...
my @local_filenames = getfiles($local_cache, @$localurls);
my @local_filespecs = @$localfiles;
$stage_counter++;


# ------------------------------------------------------------------------------
print "\nStage $stage_counter : Unpack support utilities.\n";
# Unpack 7za, console, ANSICON etc.
# ------------------------------------------------
# : Source path is $dirs{"package"}
# : Destination Path will be $dirs{"support"}
# : Filenames are stored in @util_filenames
# : FileSpecs (those to be unpacked) are stored in @util_filespecs.
# ------------------------------------------------
$result = unpack_file($dirs{"package"}, $dirs{"support"}, \@util_filenames, \@util_filespecs);
$stage_counter++;


# ------------------------------------------------------------------------------
print "\nStage $stage_counter : Unpack Extra packages into MinGW.\n";
# Unpack cmake, dmake and others than need to be in MinGW.
# ------------------------------------------------
# : Source path is $dirs{"package"}
# : Destination Path will be $dirs{"mingw"}
# : Filenames are stored in @extra_filenames
# : FileSpecs (those to be unpacked) are stored in @extra_filespecs.
# ------------------------------------------------
$result = unpack_file($dirs{"package"}, $dirs{"mingw"}, \@extra_filenames, \@extra_filespecs);
$stage_counter++;


# ------------------------------------------------------------------------------
print "\nStage $stage_counter : Unpack MSYS.\n";
# Unpack MSYS distribution.
# ------------------------------------------------
# : Source path is $msys_cache
# : Destination Path will be $dirs{"msys"}
# : Filenames are stored in @msys_filenames
# : FileSpecs (those to be unpacked) are stored in @msys_filespecs.
# ------------------------------------------------
$result = unpack_file($msys_cache, $dirs{"msys"}, \@msys_filenames, \@msys_filespecs);
$stage_counter++;


# ------------------------------------------------------------------------------
print "\nStage $stage_counter : Unpack MinGW.\n";
# Unpack MinGW distribution.
# ------------------------------------------------
# : Source path is $mingw_cache
# : Destination Path will be $dirs{"mingw"}
# : Filenames are stored in @mingw_filenames
# : FileSpecs (those to be unpacked) are stored in @mingw_filespecs.
# ------------------------------------------------
$result = unpack_file($mingw_cache, $dirs{"mingw"}, \@mingw_filenames, \@mingw_filespecs);
$stage_counter++;


# ------------------------------------------------------------------------------
print "\nStage $stage_counter : Unpack GCC Packages.\n";
# Unpack GCC distribution.
# ------------------------------------------------
# : Source path is $tdm_cache
# : Destination Path will be $dirs{"mingw"}
# : Filenames are stored in @gcc_filenames
# : FileSpecs (those to be unpacked) are stored in @gcc_filespecs.
# ------------------------------------------------
$result = unpack_file($tdm_cache, $dirs{"mingw"}, \@gcc_filenames, \@gcc_filespecs);
$stage_counter++;


# ------------------------------------------------------------------------------
print "\nStage $stage_counter : Unpack Updated Packages.\n";
# Unpack GCC distribution.
# ------------------------------------------------
# : Source path is $local_cache
# : Destination Path will be $dirs{"mingw"}
# : Filenames are stored in @local_filenames
# : FileSpecs (those to be unpacked) are stored in @local_filespecs.
# ------------------------------------------------
$result = unpack_file($local_cache, $dirs{"mingw"}, \@local_filenames, \@local_filespecs);
$stage_counter++;


# ------------------------------------------------------------------------------
print "\nStage $stage_counter : Tidy up base system, removing unneeded files.\n";
# There are a few files in the standard MSYS distro that are not needed in this particular system...
# note that as of now there is no error checking ...
my @unwanted_msys = qw(m.ico msys.bat msys.ico etc/fstab.sample etc/profile);
# now delete these...
foreach my $unwanted (@unwanted_msys) {
  unlink $dirs{"msys"}."/".$unwanted;
}
# also remove the postinstall directory as we will do this manually ourselves...
rmtree($dirs{"msys"}."/postinstall");
print " -- Done\n";
$stage_counter++;


# ------------------------------------------------------------------------------
print "Stage $stage_counter : Finalize Environment - Copy final files.\n";
# Give us a working system by copying the needed skeleton files and startup batch ...

# # create the home and local directories if not already there and the tmp ..
create_dir($dirs{"home"});
#create_dir($dirs{"local"});
create_dir($dirs{"msys"}."/tmp");

# create some blank dirs that will be overmounted -
# otherwise bash shell completion does not work for these dirs.
create_dir($dirs{"msys"}."/home");
create_dir($dirs{"msys"}."/usr");
#create_dir($dirs{"msys"}."/local");

# copy over assorted skeleton or configuration files to various places...
my @skel_dirs = qw(root support home etc);
foreach my $skel (@skel_dirs) {
  dircopy ($dirs{"base"}."/skel/$skel/.", $dirs{$skel}) or die "Failed to copy skeleton files: $!";
}

# copy the Perl configuration library...
fcopy ($dirs{"base"}."/lib/My/ConfigFile.pm", $dirs{"home"}."/scripts/lib/My/ConfigFile.pm") or die "Failed to copy skeleton files: $!";

# copy over wget (for now) to the mingw32 directory
fcopy ($dirs{"base"}."/wget.exe", $dirs{"mingw"}."/bin") or die "Failed to copy skeleton files: $!";
if (!-e $dirs{"base"}."/.wgetrc") {
  fcopy ($dirs{"base"}."/.wgetrc", $dirs{"home"}) or die "Failed to copy skeleton files: $!";
}

# copy the configuration file over to our new home directory...
copy ($dirs{"base"}."/config.ini", $dirs{"home"})or die "Failed to copy skeleton files: $!";
print " -- Done\n";
$stage_counter++;
