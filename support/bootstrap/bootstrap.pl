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
print $base_directory;
# Build other useful directories from this...
my $msys_directory = abs_path($base_directory."/../../msys");
my $mingw_directory = abs_path($base_directory."/../../mingw32");
my $package_directory = abs_path($base_directory."/../packages");
my $support_directory = abs_path($base_directory."/../../support");

# We need a few support utilities, this will also include Console and ANSICON eventually.
print "\nStage 2 : Download and unpack assorted support utilities.\n\n";
#TODO


print "\nStage 3 : Download and MSYS packages to local cache.\n\n";
# load the MSYS URL's into an array from the file 'msys-urls'...
my $path_to_urls = $package_directory."/msys-urls";
my @msysurls = geturls($path_to_urls);

# Download these URL's ..
my $msys_cache = $package_directory."/msys";
my $url;

# create the MSYS Cache directory if it does not exist...
if (!-d $msys_cache) {
  mkdir $msys_cache or die "Cannot create Cache directory for MSYS!";
}

foreach $url (@msysurls) {
  #get the actual filename, from the last part of the URL, removing the SorceForge '/download' text...
  my $filename = basename(substr($url, 0, -9));
  my $filewithpath = $msys_cache."/".$filename;
  #if this does not exist in cache then we will download. In future versions we will compare to a checksum too...
  if (-e $filewithpath) {
    print "$filename already exists, skipping.\n";
  } else {
    my $result = `$mingw_directory/wget -q --show-progress -c --trust-server-names -c --directory-prefix=$msys_cache $url`;
  }
}

# now unpack these. We will do an unconditional over-write for all existing files, so any customisations will be overwritten.
foreach $url (@msysurls) {
  #get the actual filename, from the last part of the URL, removing the SorceForge '/download' text...
  my $filename = basename(substr($url, 0, -9));
  my $filewithpath = $msys_cache."/".$filename;
  # these come in a couple of archive types so we need to use a different utility to unpack depending on the extension
  my @exts = qw(.lzma .xz);
  my ($dir, $name, $ext) = fileparse($filename, @exts);

  for ($ext) {
    if (/lzma/) {
      #print "$filename is an LZMA file! ($ext)\n";
    }
    elsif (/xz/) {
      #print "$filename is an XZ file! ($ext)\n";
    }
  }
}




# support functions

sub geturls() {
  # when provided with a file containing URLS, will return an array containing them.
  # 1 parameter - $path_to_urls
  ($path_to_urls) = @_;
  open my $handle, '<', $path_to_urls;
  chomp(my @urls = <$handle>);
  close $handle;
  # Remove empty lines and headings then return ...
  return grep(/S/, @urls);
}
