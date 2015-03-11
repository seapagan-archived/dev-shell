use strict;
use File::Basename;
use File::Path 'rmtree';
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
my ($toolsurls, $toolsfiles) = geturls($path_to_urls);
my @util_filenames = getfiles($package_directory, @$toolsurls);
my @util_filespecs = @$toolsfiles;

# get the 'extra' files...
my $path_to_urls = $base_directory."/urls/extras-urls";
my ($extraurls, $extrafiles) = geturls($path_to_urls);
my @extra_filenames = getfiles($package_directory, @$extraurls);
my @extra_filespecs = @$extrafiles;

# ------------------------------------------------------------------------------
print "\nStage 3 : Download MSYS packages to local cache.\n\n";
# load the MSYS URL's into an array from the file 'msys-urls'...
my $path_to_urls = $base_directory."/urls/msys-urls";
my ($msysurls, $msysfiles) = geturls($path_to_urls);

# create the MSYS Cache directory if it does not exist...
if (!-d $msys_cache) {
  mkdir $msys_cache or die "Cannot create Cache directory for MSYS!";
}
# get all the MSYS packages we need...
my @msys_filenames = getfiles($msys_cache, @$msysurls);
my @msys_filespecs = @$msysfiles;


# ------------------------------------------------------------------------------
print "\nStage 4 : Download MinGW packages to local cache.\n\n";
# load the minGW URL's into an array from the file 'mingw-urls'...
my $path_to_urls = $base_directory."/urls/mingw-urls";
my ($mingwurls, $mingwfiles) = geturls($path_to_urls);

# create the MinGW Cache directory if it does not exist...
if (!-d $mingw_cache) {
  mkdir $mingw_cache or die "Cannot create Cache directory for MinGW!";
}
# get all the minGW packages we need...
my @mingw_filenames = getfiles($mingw_cache, @$mingwurls);
my @mingw_filespecs = @$mingwfiles;


# ------------------------------------------------------------------------------
print "\nStage 5 : Download TDM GCC Compiler packages to local cache.\n\n";
# load the GCC URL's into an array from the file 'tdm-gcc-urls'...
my $path_to_urls = $base_directory."/urls/tdm-gcc-urls";
my ($gccurls, $gccfiles) = geturls($path_to_urls);

# create the MinGW Cache directory if it does not exist...
if (!-d $tdm_cache) {
  mkdir $tdm_cache or die "Cannot create Cache directory for TDM GCC!";
}
# get all the GCC packages we need...
my @gcc_filenames = getfiles($tdm_cache, @$gccurls);
my @gcc_filespecs = @$gccfiles;


# ------------------------------------------------------------------------------
print "\nStage 6 : Unpack support utilities.\n";
# Unpack 7za, console, ANSICON etc.
# ------------------------------------------------
# : Source path is $package_directory
# : Destination Path will be $support_directory
# : Filenames are stored in @util_filenames
# : FileSpecs (those to be unpacked) are stored in @util_filespecs.
# ------------------------------------------------
$result = unpack_file($package_directory, $support_directory, \@util_filenames, \@util_filespecs);


# ------------------------------------------------------------------------------
print "\nStage 7 : Unpack MSYS.\n";
# Unpack MSYS distribution.
# ------------------------------------------------
# : Source path is $msys_cache
# : Destination Path will be $msys_directory
# : Filenames are stored in @msys_filenames
# : FileSpecs (those to be unpacked) are stored in @msys_filespecs.
# ------------------------------------------------
$result = unpack_file($msys_cache, $msys_directory, \@msys_filenames, \@msys_filespecs);


# ------------------------------------------------------------------------------
print "\nStage 8 : Unpack MinGW.\n";
# Unpack MinGW distribution.
# ------------------------------------------------
# : Source path is $mingw_cache
# : Destination Path will be $mingw_directory
# : Filenames are stored in @mingw_filenames
# : FileSpecs (those to be unpacked) are stored in @mingw_filespecs.
# ------------------------------------------------
$result = unpack_file($mingw_cache, $mingw_directory, \@mingw_filenames, \@mingw_filespecs);


# ------------------------------------------------------------------------------
print "\nStage 9 : Unpack GCC Packages.\n";
# Unpack GCC distribution.
# ------------------------------------------------
# : Source path is $tdm_cache
# : Destination Path will be $mingw_directory
# : Filenames are stored in @gcc_filenames
# : FileSpecs (those to be unpacked) are stored in @gcc_filespecs.
# ------------------------------------------------
$result = unpack_file($tdm_cache, $mingw_directory, \@gcc_filenames, \@gcc_filespecs);


# ------------------------------------------------------------------------------
print "\nStage 10 : Tidy up base system, removing unneeded files.\n";
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
# support functions


sub geturls() {
  # when provided with a file containing URLS, will return 2 arrays.
  # 1 parameter - $path_to_urls, filepath to text file containing the URL's
  # RETURNS : **REFERENCE TO ARRAYS**
    # 1st Array : each URL from the input file.
    # 2nd Array : the list of Files to be unpacked for this URL, if any.
  my ($path_to_urls) = @_;

  open my $handle, '<', $path_to_urls or die "Cant open $path_to_urls";
  chomp(my @url_line = <$handle>);
  close $handle;
  # At this point we have an array of full lines that may contain file spec as well as URL's
  # The $url_line as read from the file may contain a list of files at the end in a specific format.
  # We need to split this into 2 arrays if present.
  my @urls; my @unpacklist;
  my $count = 0;
  foreach my $line (@url_line) {
    # first, if this is a comment then ignore it completely...
    if (not $line =~ /^\s*\#/) {
      # locate out the unpack spec if we have one. We will use the start location to trim the URL out also.
      if ( $line =~ /\s\*[+|-]\((.*)\)/ ) {
        # there is an unpack spec so we store this in the @unpacklist array...
        $unpacklist[$count]=$1;
        $urls[$count]=substr $line, 0, $-[0];
      } else {
        # there is no unpack spec so just assign an empty string to it and take the whole line as the URL...
        $unpacklist[$count]="";
        $urls[$count]=$line;
      }
      $count++;
    }
  }
  # Return the array of URLs ...
  return (\@urls, \@unpacklist);
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
      my $result = `$base_directory/wget -q --config=$base_directory/.wgetrc --show-progress -c $dl_flag --directory-prefix=$dest_dir $url`;
    }
  }
  return @filearray;
}


sub unpack_file() {
  # will unpack the filenames in the passed array using the correct tool depending on archive type.
  # Parameter 1 : $location, directory to find the packages.
  # Parameter 2 : $destination, where to unpack these files.
  # Parameter 3 : $filenamesref, REFERENCE to an array of the actual packages to be unpacked.
  # Paramater 4 : $filespecsref, REFERENCE to an array of colon separated filenames to be unpacked.
  # RETURNS : TRUE if no errors, FALSE and break on any error.

  my ($location, $destination, $filenamesref, $filespecsref) = @_;

  my @filenames = @$filenamesref;
  my @filespecs = @$filespecsref;

  # set a variable to contain the output length so we can delete it in the next loop invocation.
  # initially set to zero.
  my $output_length  = 0;
  # variable to hold the filename of the underlying tar file.
  my $tarfile;

  # unbuffer output, otherwise we cant overwrite the previous line...
  local $| = 1;

  my $count = 0;
  foreach my $file (@filenames) {
    my @exts = qw(.lzma .xz .zip .bz2 .gz);
    my ($dir, $name, $ext) = fileparse($file, @exts);

    # get the filespec if it exists and replace colon with spaces...
    $filespecs[$count] =~ s/^\s+|\s+$//g;;
    $filespecs[$count] =~ s/:/ /g;

    for ($ext) {
      if (/lzma/ || /xz/ || /bz2/ || /gz/) {
        # Note that so far all non-zip files are tar.lzma (or whatever) so we need a 2-stage operation to unpack them properly
        # However 7za.exe does not support reading from a pipe so we need to unpack the envelope, unpack the tar, and then delete the tar.
        # we assume that all files are tar.<whatever> for the moment, checking for this will be added later in case of exceptions.
        `$support_directory/7za x -y $location/$file -o$destination`;
        $tarfile = basename(substr($file, 0, -length($ext)));
        `$support_directory/7za x -y $destination/$tarfile -o$destination`;
      }
      elsif (/zip/) {
        # this is only one stage, since I've never seen a .tar.zip! Therefore we cant use the above unpack
        # logic, even though 7za.exe can easily unpack zip fies.
        `$base_directory/unzip.exe -j -o $location/$file $filespecs[$count]  -d $destination `;
      }
      else {
        # not an extension that we are prepared to handle, so crash out with notification.
        print "$file is an UNSUPPORTED extension!! Aborting until reality is resumed.\n";
        exit 2; # error 2, Unknown archive type.
      }
    }
    # check for the last error and abort if not zero.
    if ($? == 0) {
      my $output_string = " -- Package : \"$file\" Unpacked succesfully.";
      $output_length = output_line($output_string, $output_length);
    } else {
      print "\nError when trying to unpack $file, aborting all processing\n";
      exit 1; # error 1, failure to unpack a package.
    }
    # delete any remaining tar files if needed..
    if (-e $destination."/".$tarfile) {
      unlink $destination."/".$tarfile;
    }
    $count++;
  }
  # if we get here, there must have been no errors, so return TRUE (well, we would if this was not Perl....).
  printf ("\r%s\r -- Done", " " x $output_length);
  return 1;
}

sub output_line() {
  # this will output a line to console, on the same line and overwriting the previous.
  my ($out_string, $out_length) = @_;

  if ($out_length > 0) {
    # move cursor to beginning of string and delete the previous data...
    printf ("\r%s\r$out_string", " " x $out_length);
  } else {
    print $out_string;
  }
  $out_length = length($out_string);
  # return this length so can be fed to us again in the next call...
  return $out_length;
}
