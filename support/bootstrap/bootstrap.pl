use strict;
use File::Basename;
use Cwd 'abs_path';

# NOTE : We need to get the base path of the system, but in TinyPerl $0 does not work so it is difficult
# to get the proper script location as the usual standard methods will fail.
# To get past this when we run this from the standard bootstrap.cmd, first we CD to the bootstrap directory.
# This allows us to run the script from its own directory directly for testing.

# Script currently messy, will be rebased once functional.

# Get our base path...
my $base_directory = abs_path();
my $root_directory = abs_path($base_directory."/../..");

# create the MSYS & MinGW directories if they do not exist...
if (!-d $root_directory."/msys") {
  mkdir $root_directory."/msys" or die "Cannot create MSYS directory!";
}
if (!-d $root_directory."/mingw32") {
  mkdir $root_directory."/mingw32" or die "Cannot create MinGW directory!";
}

# Build other useful directories from this...
my $msys_directory = abs_path($root_directory."/msys");
my $mingw_directory = abs_path($root_directory."/mingw32");
my $package_directory = abs_path($root_directory."/support/packages");
my $support_directory = abs_path($root_directory."/support");

# Cache directories to store MSYS / MinGW packages...
my $msys_cache = $package_directory."/msys";
my $mingw_cache = $package_directory."/mingw";
my $tdm_cache = $package_directory."/tdm";

# Generic result variable
my $result;

# ------------------------------------------------------------------------------
# We need a few support utilities, this will also include Console and ANSICON.
print "\nStage 2 : Download assorted support utilities.\n\n";
# load the Support tools URL's into an array from the file 'msys-urls'...
my $path_to_urls = $base_directory."/urls/support-urls";
my @toolsurls = geturls($path_to_urls);

my @util_filenames = getfiles($package_directory, @toolsurls);

# ------------------------------------------------------------------------------
print "\nStage 3 : Download MSYS packages to local cache.\n\n";
# load the MSYS URL's into an array from the file 'msys-urls'...
my $path_to_urls = $base_directory."/urls/msys-urls";
my @msysurls = geturls($path_to_urls);

# create the MSYS Cache directory if it does not exist...
if (!-d $msys_cache) {
  mkdir $msys_cache or die "Cannot create Cache directory for MSYS!";
}
# get all the MSYS packages we need...
my @msys_filenames = getfiles($msys_cache, @msysurls);

# ------------------------------------------------------------------------------
print "\nStage 4 : Download MinGW packages to local cache.\n\n";
# load the minGW URL's into an array from the file 'mingw-urls'...
my $path_to_urls = $base_directory."/urls/mingw-urls";
my @mingwurls = geturls($path_to_urls);

# create the MinGW Cache directory if it does not exist...
if (!-d $msys_cache) {
  mkdir $msys_cache or die "Cannot create Cache directory for MinGW!";
}
# get all the minGW packages we need...
my @mingw_filenames = getfiles($mingw_cache, @mingwurls);

print "\nStage 4 : Download TDM GCC Compiler packages to local cache.\n\n";
# load the GCC URL's into an array from the file 'tdm-gcc-urls'...
my $path_to_urls = $base_directory."/urls/tdm-gcc-urls";
my @gccurls = geturls($path_to_urls);

# create the MinGW Cache directory if it does not exist...
if (!-d $tdm_cache) {
  mkdir $tdm_cache or die "Cannot create Cache directory for TDM GCC!";
}
# get all the GCC packages we need...
my @gcc_filenames = getfiles($tdm_cache, @gccurls);

# ------------------------------------------------------------------------------
print "\nStage 5 : Unpack support utilities.\n\n";
# Unpack 7za, console, ANSICON etc.
# ------------------------------------------------
# : Source path is $package_directory
# : Destination Path will be $support_directory
# : Filenames are stored in @util_filenames
# ------------------------------------------------
$result = unpack_file($package_directory, $support_directory, @util_filenames);
# TODO - remove all unneeded files, or use a specific unpack routine to only unpack what we need #


# ------------------------------------------------------------------------------
print "\nStage 6 : Unpack MSYS.\n\n";
# Unpack MSYS distribution.
# ------------------------------------------------
# : Source path is $msys_cache
# : Destination Path will be $msys_directory
# : Filenames are stored in @msys_filenames
# ------------------------------------------------
$result = unpack_file($msys_cache, $msys_directory, @msys_filenames);

# ------------------------------------------------------------------------------
print "\nStage 7 : Unpack MinGW.\n\n";
# Unpack MinGW distribution.
# ------------------------------------------------
# : Source path is $mingw_cache
# : Destination Path will be $mingw_directory
# : Filenames are stored in @mingw_filenames
# ------------------------------------------------
$result = unpack_file($mingw_cache, $mingw_directory, @mingw_filenames);

print "\nStage 8 : Unpack GCC Packages.\n\n";
# Unpack GCC distribution.
# ------------------------------------------------
# : Source path is $mingw_cache
# : Destination Path will be $mingw_directory
# : Filenames are stored in @mingw_filenames
# ------------------------------------------------
$result = unpack_file($tdm_cache, $mingw_directory, @gcc_filenames);

# ------------------------------------------------------------------------------
# support functions

sub geturls() {
  # when provided with a file containing URLS, will return an array containing them.
  # 1 parameter - $path_to_urls, filepath to text file containing the URL's
  my ($path_to_urls) = @_;

  open my $handle, '<', $path_to_urls or die "Cant open $path_to_urls";
  chomp(my @urls = <$handle>);
  close $handle;
  # Return the array of URLs ...
  return @urls;
}

sub getfiles() {
  # will take an array of URL's and a destination folder and proceed to download them all using wget...
  # Parameter 1 : $dest_dir, directory to store them in.
  # Parameter 2 : @url_list, an array of URL's
  # RETURNS : Array containing all the sanitized filenames
  # ERROR CHECKING STILL TO BE ADDED!
  my ($dest_dir, @url_list) = @_;

  my @filearray;

  foreach my $url (@url_list) {
    # get the actual filename from the last part of the URL, removing the SorceForge '/download' text if it exists ...
    # we also need a different flag for sorceforge, which would probably confuse other sites (certainly github anyway)

    # pre-define the variables otherwise not valid outside the if statement..
    my $filename="";
    my $dl_flag ="";

    # Trim spaces from start and end of URL...
    $url =~  s/^\s+|\s+$//g;
    # break out if $url is blank...
    if ($url eq "") {
      next;
    }

    # different wget flags depending on source of package, also remove '/download' from end of SourceForge URL.
    if ( $url =~ /\/download$/) {
      $filename = basename(substr($url, 0, -9));
      $dl_flag= "--trust-server-names";
    } else {
      $filename = basename($url);
      $dl_flag= "--no-check-certificate";
    }

    # Add the filename to the array we will return...
    push(@filearray, $filename);

    my $filewithpath = $dest_dir."/".$filename;
    #if this does not exist in cache then we will download. In future versions we will compare to a checksum too...
    if (-e $filewithpath) {
      print "$filename already exists, skipping.\n";
    } else {
      my $result = `$base_directory/wget -q --show-progress -c $dl_flag --directory-prefix=$dest_dir $url`;
    }
  }
  return @filearray;
}

sub unpack_file() {
  # will unpack the filenames in the passed array using the correct tool depending on archive type.
  # Parameter 1 : $location, directory to find the packages.
  # Parameter 2 : $destination, where to unpack these files.
  # Parameter 3 : @filenames, array of the actual filenames to be unpacked.
  # RETURNS : TRUE if no errors, FALSE and break on any error.

  my ($location, $destination, @filenames) = @_;

  foreach my $file (@filenames) {
    my @exts = qw(.lzma .xz .zip);
    my ($dir, $name, $ext) = fileparse($file, @exts);
    for ($ext) {
      if (/lzma/) {
        # Note that so far all non-zip files are tar.lzma (or whatever) so we need a 2-stage operation to unpack them properly
        # However 7za.exe does not support reading from a pipe so we need to unpack the envelope, unpack the tar, and then delete the tar.

        `$support_directory/7za x -y $location/$file -o$destination`;
        my $tarfile = basename(substr($file, 0, -5));
        `$support_directory/7za x -y $destination/$tarfile -o$destination`;
        if ($? == 0) {
          print "Package : \"$file\" Unpacked succesfully\n";
          # now delete the tar file...
          unlink $destination."/".$tarfile;
        } else {
          print "\nError when trying to unpack $file, aborting all processing\n";
          exit 1; # error 1, failure to unpack a package.
        }
      }
      elsif (/xz/) {
        #Basically a direct copy of the lzma part...
        `$support_directory/7za x -y $location/$file -o$destination`;
        my $tarfile = basename(substr($file, 0, -3));
        `$support_directory/7za x -y $destination/$tarfile -o$destination`;
        if ($? == 0) {
          print "Package : \"$file\" Unpacked succesfully\n";
          # now delete the tar file...
          unlink $destination."/".$tarfile;
        } else {
          print "\nError when trying to unpack $file, aborting all processing\n";
          exit 1; # error 1, failure to unpack a package.
        }
      }
      elsif (/zip/) {
        #print "$file is a Zip file! ($ext)\n";
        `$base_directory/unzip.exe -o $location/$file -d $destination `;
        if ($? == 0) {
          print "Package : \"$file\" Unpacked succesfully\n";
        } else {
          print "\nError when trying to unpack $file, aborting all processing\n";
          exit 1; # error 1, failure to unpack a package.
        }
      }
      else {
        print "$file is an UNSUPPORTED extension!! Aborting until reality is resumed.\n";
        exit 2; # error 2, Unknown archive type.
      }
    }
  }
  # if we get here, there must have been no errors, so return TRUE (well, we would if this was not Perl....).
  return 1;
}
