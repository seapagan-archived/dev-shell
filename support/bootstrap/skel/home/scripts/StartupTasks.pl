#!perl
# This script will read the config.ini in /home and adapt settings as needed.
# Uses the same ConfigFile package as the bootstrap which is copied over during creation.
# In the future when we include Ruby, Perl etc properly it will also adjust paths and shebangs as the physical location changes.
# (ie if we are on a USB stick and the drive changes from PC to PC)

use strict;
use warnings;

use lib '/home/scripts/lib';
use My::ConfigFile;

# If there is a configuration file then we should read it...
if (-e "/home/config.ini") {
  print "Configuration Found : Setting up Environment";
  # Read in the configuration file...
  my %configuration = read_config("/home/config.ini");
  do_config(%configuration);
  print " : Done.\n\n";
}


sub do_config {
  # deal with the configuration settings. This will mainly just set some environment variables
  # into the '/home/extra_env' file that will be sourced by the local .bashrc
  # so we delete any existing file...
  if (-e "/home/extra_env") {
    unlink ("/home/extra_env");
  }
  # get parameter - %hash with configuration values...
  my (%configs) = @_;

  open (FILE, ">/home/extra_env") or die "Cant open /home/extra_env for writing\n";

  print FILE "# /home/extra/env\n";
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
