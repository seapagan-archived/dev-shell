use strict;
use warnings;
use Cwd;
use File::Path 'rmtree';
use File::Copy 'mv';

# save the current working directory..
my $original_dir = cwd;
# change to the temporary directory..
chdir $ARGV[1];

# ------------------------------------------------------------------------------
# Specific to this script, do not edit anything outside this section!
# Tidy up the unpacked Ruby file. Valid for 'ruby-2.2.1-i386-mingw32.7z'
# All thats really needed is to rename the directory to 'ruby', easy.

mv ("ruby-2.2.1-i386-mingw32", "ruby");
# ------------------------------------------------------------------------------

# change back to the original directory..
chdir $original_dir;
