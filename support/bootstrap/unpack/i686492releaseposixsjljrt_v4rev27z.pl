use strict;
use warnings;
use Cwd;
use File::Path 'rmtree';
use File::Copy 'mv';
use File::Copy::Recursive qw(dircopy dirmove);

# save the current working directory..
my $original_dir = cwd;
# change to the temporary directory..
chdir $ARGV[1];

# ------------------------------------------------------------------------------
# Specific to this script, do not edit anything outside this section!
# Tidy up the unpacked Ruby file. Valid for 'i686-4.9.2-release-posix-sjlj-rt_v4-rev2.7z'
chdir ($ARGV[1]."/mingw32");
my @filelist = qw(build-info.txt);
unlink @filelist;
rmtree ("opt");
dirmove (".", $ARGV[1]);
# ------------------------------------------------------------------------------

# change back to the original directory..
chdir $original_dir;
