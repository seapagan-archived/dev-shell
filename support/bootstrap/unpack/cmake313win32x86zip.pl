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
# Tidy up the unpacked cmake file. Valid for 'cmake-3.1.3-win32-x86'
chdir ($ARGV[1]."/cmake-3.1.3-win32-x86");
# note - this package comes with its own 'libeay32.dll' and 'ssleay32.dll' -
# these will be left in for the moment, but removed once we add our own openssl package to avoid conflicts.
my @filelist = qw(cmake.org.html);
unlink @filelist;
rmtree (['man', 'doc']);
dirmove("bin", $ARGV[1]."/bin") or die $!;
dirmove("share", $ARGV[1]."/share") or die $!;
chdir ($ARGV[1]);
rmtree('cmake-3.1.3-win32-x86');
# ------------------------------------------------------------------------------

# change back to the original directory..
chdir $original_dir;
