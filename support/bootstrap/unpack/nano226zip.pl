use strict;
use warnings;
use Cwd;


# save the current working directory..
my $original_dir = cwd;
# change to the temporary directory..
chdir $ARGV[1];

# ------------------------------------------------------------------------------
# Specific to this script, do not edit anything outside this section!
# Tidy up the unpacked dmake file. Valid for 'nano-2.2.6'
my @filelist = qw(COPYING.DOC COPYING.txt faq.html nano.1.html nano.log nano.rc README.TXT);
unlink @filelist;
mkdir ('bin');
`move *.dll bin`;
`move *.exe bin`;
# ------------------------------------------------------------------------------

# change back to the original directory..
chdir $original_dir;
