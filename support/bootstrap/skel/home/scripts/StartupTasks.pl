#!perl
# This script will read the config.ini in /home and adapt settings as needed.
# Uses the same ConfigFile package as the bootstrap which is copied over during creation.
# It will also adjust paths and shebangs as the physical location changes for Perl and (soon) Ruby.
# (ie if we are on a USB stick and the drive changes from PC to PC)
use strict;
use warnings;
use File::Basename;
use Config;
use Cwd;
use File::Slurp;

use lib $ENV{'HOME'}.'/scripts/lib';
use My::ConfigFile;

print "Setting up Portable Environment";

# Get the perl directory into $dir ...
my ($file, $dir, $ext) = fileparse($^X);
# fix all the shebang lines in the bin directory.
fix_shebang($dir);

# If there is a configuration file then we should read it...
if (-e "$ENV{'HOME'}/config.ini") {
  # Read in the configuration file...
  my %configuration = read_config("$ENV{'HOME'}/config.ini");
  do_config(%configuration);
}
print " : Done.\n\n";

# ------------------------------------------------------------------------------
# Subroutines
# ------------------------------------------------------------------------------

sub do_config {
  # deal with the configuration settings. This will mainly just set some environment variables
  # into the '/home/extra_env' file that will be sourced by the local .bashrc
  # so we delete any existing file...
  if (-e $ENV{'HOME'}."/extra_env") {
    unlink ($ENV{'HOME'}."/extra_env");
  }
  # get parameter - %hash with configuration values...
  my (%configs) = @_;

  open (FILE, ">$ENV{'HOME'}/extra_env") or die "Cant open $ENV{'HOME'}/extra_env for writing\n";

  # Header for the file
  print FILE "# /home/extra_env\n";
  print FILE "# IMPORTANT - This file will be regenerated from scratch each time the environment\n";
  print FILE "# is started, so DO NOT put any customisations in here or they will be lost!\n";
  print FILE "\n";

  # (1) Proxy Settings.
  # For this we just set the relevant http(s)_proxy environment variables.
  if (exists $configs{"proxy"} && $configs{"proxy"} eq "on") {
    print FILE "export HTTP_PROXY=".$configs{"http_proxy"}."\n";
    print FILE "export HTTPS_PROXY=".$configs{"https_proxy"}."\n";
  }
  close FILE; # close output file
}


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
