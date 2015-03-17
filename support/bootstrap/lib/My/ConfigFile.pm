# Configuration module for the dev-shell bootstrap
package My::ConfigFile;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(read_config);

sub read_config {
  # this sub will read in the provided configuration file and return a hash of the config values.
  # Parameter 1 : $config_file - full path to the configuration file.
  # RETURNS : hash containing each setting => value from the file.
  my ($config_file) = @_;
  # read everything into an array...
  my @config_lines = read_file($config_file);
  my %hash= ();

  foreach my $line (@config_lines) {
    my @tokens = split('=', $line);
    # remove leading and trailing spaces...
    $tokens[0] =~ s/^\s+|\s+$//g;
    $tokens[1] =~ s/^\s+|\s+$//g;
    if (not $tokens[0] =~ /^\s*\#/) { # ignore comments
      $hash{$tokens[0]} = $tokens[1];
    }
  }
  return %hash;
}

sub read_file {
  my ($text_file) = @_;
  open my $handle, '<', $text_file or die "Cant open $text_file";
  chomp(my @lines = <$handle>);
  close $handle;
  return @lines;
}
