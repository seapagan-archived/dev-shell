# Simple quick script to generate a file 'hashes' containing md5 hashes of
# all the binary packages downloaded and stored in the cache directories.
# This will be used in 2 ways :
# 1) Check integrity of downloaded files.
# 2) Check integrity of existing cached files to save downloading again.

use strict;
use Cwd 'abs_path';

# Get our base path, will be the bootstrap directory ...
my $base_directory = abs_path();

# work out the support dir path from this ...
my $support_directory = abs_path($base_directory."/..");

# Run the md5deep program to update all the checksums for the package files.
# This wil be saved as a CSV file 'hashes' in the current directory.
print "Re-calculating package hashes for all packages in current cache - ";
my %result = `$support_directory\\md5deep.exe -r -c -z -b -s -W hashes ../packages`;
if (%result == 0) {
  print "Done.\n\n";
} else {
  print "Error $? while creating hash file, please check and report if necessary."
}
