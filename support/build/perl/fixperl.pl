#!perl

# WORK IN PROGRESS

# this script is to be run after succesful compilation of Perl, to fix some problems :
# 1) we need to create the plan Perl scripts from the Batch files
# 2) The existing batch files have dodgy !# lines. We want the raw perl scripts to have a proper #! /perlpath/perl shebang.
use strict;
use warnings;

use File::Basename;
use Cwd;
use Config;
use File::Slurp;

#-------------------------------------------------------------------------------

# Get the perl directory into $dir ...
my ($file, $dir, $ext) = fileparse($^X);

# (1) copy all the *.bat in this directory to plain perl scripts...
fix_scripts($dir);

# (2) fix the shebangs...
fix_shebang($dir);
#-------------------------------------------------------------------------------


sub fix_scripts {
  # this sub creates proper perl files for all the .bat files in the bin directory so we can run in MSYS.
  # it will remove the bat files, and create raw perl.
  my ($perl_dir) = @_;
  my $orig_dir = cwd;
  chdir ($perl_dir);
  my @batfiles = glob q(*.bat);
  foreach my $target (@batfiles) {
    # read in the batch file...
    open my $handle, '<', $target or die "Cant open $target";
    my @lines = <$handle>;
    close $handle;
    # now we delete the batch file. Will be recreated later. maybe.
    unlink $target;
    $target =~ s/\.bat$//i;
    open $handle, '>', $target or die "Cant open $target";
    print $handle "#!perl\n";
    print $handle @lines[13..$#lines-2];
    close $handle;
  }
  # change directory pack to original
  chdir $orig_dir;
}

#-------------------------------------------------------------------------------

sub fix_shebang {
  # goes through scripts in perl bin dir and changes the shebang to current perl location, if '#!' and 'perl' is on that line
  # for all scripts as delivered in the package this is the case.
  my ($perl_dir) = @_;
  my $orig_dir = cwd;
  chdir ($perl_dir);
  my @allfiles = glob q(*);

  foreach my $script (@allfiles) {
    if ( not $script eq "perl.exe" ) { # trying to open the perl.exe obv fails, and gives empty $lines[0] and warning.
      my @lines = read_file($script);
      if (defined $lines[0] && $lines[0] =~ /^\s*\#\!.*perl/) {
        #we have a shebang on the first line, cool so change that line to our perl ...
        $lines[0] = "#!$Config{perlpath}\n";
        # clear read-only flag if set ...
        chmod 0777, $script;
        write_file ($script, @lines);
      }
    }
  }
}