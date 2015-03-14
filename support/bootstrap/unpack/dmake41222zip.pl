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
# Tidy up the unpacked dmake file. Valid for 'dmake-4.12.2.2'
chdir ($ARGV[1]."/dmake");
my @filelist = qw(ChangeLog COPYING META.yml NEWS PATCH.TXT README.TXT);
unlink @filelist;
rmtree (['man', 'readme']);
chdir ($ARGV[1]);
mv ("dmake", "bin");
# ------------------------------------------------------------------------------

# change back to the original directory..
chdir $original_dir;
