#Library module for the dev-shell bootstrap
package My::Bootstrap;
use strict;
use warnings;

use File::Basename;
use File::Path 'rmtree';
use File::Copy::Recursive 'dircopy';
use Cwd 'abs_path';

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(geturls getfiles unpack_file create_dir do_config read_file %dirs);

# Generic result variable
my $result;

# get all the needed directories into a hash, this is exported to the main:: script too ...
our %dirs = get_paths();
# read in the file hashes to a perl hash...
my %hashes = read_hashes();

# ------------------------------------------------------------------------------
# support functions
# ------------------------------------------------------------------------------
sub do_config {
  # modify files as required by the config settings.
  my (%configs) = @_;
  # individual setup depending on config settings..

  # proxy settings...
  if (exists $configs{"proxy"}) {
    # we have been requested to configure a proxy (on or off).
    # There is probably a much more elegant way to write this whole routine, but that can wait until the refactoring.
    my $wgetrc_loc = $dirs{"base"}."/.wgetrc";
    # FIXME : If .wgetrc exists, but does not contain these variables, they are not written so proxy will not be set.
    if ($configs{"proxy"} eq "on") {
      # turn on the proxy settings, removing any # before the line too, just in case.
      if (-e $wgetrc_loc) {
        # .wgetrc exists ..
        open (FILE, "<$wgetrc_loc") or die "Cant open $wgetrc_loc";
        my @wgetrc=<FILE>;
        close FILE; # close input file

        open (FILE, ">$wgetrc_loc") or die "Cant open $wgetrc_loc for writing";
        foreach my $line (@wgetrc) {
          $line =~ s/^\s*\#*\s*http_proxy\s*=.*/http_proxy=$configs{"http_proxy"}/;
          $line =~ s/^\s*\#*\s*https_proxy\s*=.*/https_proxy=$configs{"https_proxy"}/;
          print FILE $line;
        }
        close FILE; # close output file
      } else {
        # .wgetrc file does not exist so just write out our values to a new file...
        open (FILE, ">$wgetrc_loc") or die "Cant create $wgetrc_loc";
        print FILE "http_proxy=".$configs{"http_proxy"}."\n";
        print FILE "https_proxy=".$configs{"https_proxy"}."\n";
        close FILE; # close output file
      }
    } elsif ($configs{"proxy"} eq "off") {
      # turn off the proxy settings, simply by commenting them out...
      # slightly changed regex, to avoid double comments if already commented.
      if (-e $wgetrc_loc) {
        open (FILE, "<$wgetrc_loc") or die "Cant open $wgetrc_loc";
        my @wgetrc=<FILE>;
        close FILE; # close input file

        open (FILE, ">$wgetrc_loc") or die "Cant open $wgetrc_loc for writing";
        foreach my $line (@wgetrc) {
          $line =~ s/^(\s*http_proxy\s*=.*)/\#$1/;
          $line =~ s/^(\s*https_proxy\s*=.*)/\#$1/;
          print FILE $line;
        }
        close FILE; # close output file
      } # dont do anything if the file does not exist, as it will then not affect the proxy settings.
    }
  }
}

sub read_file {
  my ($text_file) = @_;
  open my $handle, '<', $text_file or die "Cant open $text_file";
  chomp(my @lines = <$handle>);
  close $handle;
  return @lines;
}

sub get_paths {
  # this will get all the paths to various points of the system and return in a hash...
  my %dir_hash = ();
  # NOTE : We need to get the base path of the system, but in TinyPerl $0 does not work so it is difficult
  # to get the proper script location as the usual standard methods will fail.
  # To get past this when we run this from the standard bootstrap.cmd, first we CD to the bootstrap directory.
  # This allows us to run the script from its own directory directly for testing.
  $dir_hash{"base"} = abs_path();
  $dir_hash{"root"} = abs_path($dir_hash{"base"}."/../..");
  $dir_hash{"msys"} =  $dir_hash{"root"}."/msys";
  $dir_hash{"mingw"} = $dir_hash{"root"}."/mingw32";
  $dir_hash{"package"} = $dir_hash{"root"}."/support/packages";
  $dir_hash{"support"} = $dir_hash{"root"}."/support";
  $dir_hash{"home"} = $dir_hash{"root"}."/home";
  $dir_hash{"etc"} = $dir_hash{"msys"}."/etc";
  $dir_hash{"local"} = $dir_hash{"root"}."/local";
  return %dir_hash;
}

sub geturls {
  # when provided with a file containing URLS, will return 2 arrays.
  # 1 parameter - $path_to_urls, filepath to text file containing the URL's
  # RETURNS : **REFERENCE TO ARRAYS**
    # 1st Array : each URL from the input file.
    # 2nd Array : the list of Files to be unpacked for this URL, if any.
    #   Note : if the filespec is "^script^" it will get special processing when unpacked.
  my ($path_to_urls) = @_;

  open my $handle, '<', $path_to_urls or die "Cant open $path_to_urls";
  chomp(my @url_line = <$handle>);
  close $handle;
  # At this point we have an array of full lines that may contain file spec as well as URL's
  # The $url_line as read from the file may contain a list of files at the end in a specific format.
  # We need to split this into 2 arrays if present.
  my @urls; my @unpacklist;
  my $count = 0;
  foreach my $line (@url_line) {
    # first, if this is a comment then ignore it completely...
    if (not $line =~ /^\s*\#/) {
      # locate out the unpack spec if we have one. We will use the start location to trim the URL out also.
      if ( $line =~ /\s\*\+(f*)\((.*)\)/ ) {
        # there is an unpack spec so we store this in the @unpacklist array and add a flag to show if we flatten directories...
        if ($1 eq "f") {
          $unpacklist[$count]="f|".$2;
        } else {
          $unpacklist[$count]=$2;
        }
        $urls[$count]=substr $line, 0, $-[0];
      } else {
        # there is no unpack spec so just assign an empty string to it and take the whole line as the URL...
        $unpacklist[$count]="";
        $urls[$count]=$line;
      }
      $count++;
    }
  }
  # Return the array of URLs ...
  return (\@urls, \@unpacklist);
}


sub getfiles {
  # will take an array of URL's and a destination folder and proceed to download them all using wget...
  # Parameter 1 : $dest_dir, directory to store them in.
  # Parameter 2 : @url_list, an array of URL's
  # RETURNS : Array containing all the sanitized filenames
  # ERROR CHECKING STILL TO BE ADDED!
  my ($dest_dir, @url_list) = @_;

  my @filearray;
  my $output_length = 0;
  my $output_string = "";

  foreach my $url (@url_list) {
    # get the actual filename from the last part of the URL, removing the SorceForge '/download' text if it exists ...
    # we also need a different flag for sorceforge, which would probably confuse other sites (certainly github anyway)

    # pre-define the variables otherwise not valid outside the if statement..
    my $filename="";
    my $dl_flag ="";

    # Trim spaces from start and end of URL...
    $url =~  s/^\s+|\s+$//g;
    # break out if $url is blank...
    if ($url eq "") {
      next;
    }

    # different wget flags depending on source of package, also remove '/download' from end of SourceForge URL.
    if ( $url =~ /\/download$/) {
      # FIXME : This assumes that all url's with '/download' on the end are SourceForge, which may not always be the case.
      $filename = basename(substr($url, 0, -9));
      $dl_flag= "--trust-server-names";
    } else {
      $filename = basename($url);
      $dl_flag= "--no-check-certificate";
    }
    # add a further flag if the .wgetrc exists ..
    my $wgetrc =  $dirs{base}."/.wgetrc";
    if (-e $wgetrc) {
      $wgetrc = "--config=$wgetrc";
    } else {
      $wgetrc = "";
    }


    # Add the filename to the array we will return...
    push(@filearray, $filename);

    my $filewithpath = $dest_dir."/".$filename;
    #if this does not exist in cache (or has a bad checksum) then we will download.
    if (-e $filewithpath) {
      # compare the md5 for this file...
      if (exists $hashes{$filename}) {
        $result = `$dirs{"support"}\\md5deep.exe -s -A $hashes{$filename} $filewithpath`;
        if ($? == 0) {
          $output_string = "$filename already exists (MD5 OK), skipping.";
          $output_length = output_line($output_string, $output_length);
        } else {
          # delete the corrupt file
          unlink ($filewithpath);
          # and re-download
          $result = `$dirs{"base"}/wget -q $wgetrc --proxy --show-progress -c $dl_flag --directory-prefix=$dest_dir $url`;
        }
      } else {
        output_line("$filename already exists, however there is no hash value.\n -> Please run \'update_package_hashes.cmd\' from the bootstrap directory. Skipping.\n", $output_length);
        $output_length= 0 ;
      }
    } else {
      # file does not exist, so download it.
      $result = `$dirs{"base"}/wget -q $wgetrc --show-progress -c $dl_flag --directory-prefix=$dest_dir $url`;
      # we really should check the MD5 again with this new file, and bomb out if it is wrong, since something is really messed up somewhere..
      # first check that the checksum exists - may be a new download not yet in the database, so note this visibly...
      if (exists $hashes{$filename}) {
        $result = `$dirs{"support"}\\md5deep.exe -s -A $hashes{$filename} $filewithpath`;
        if (not $? == 0) {
          print "Download of $filename fails the Hash check, aborting.\n\n";
          exit;
        }
      } else {
          output_line("There is no hash value for package \'$filename\'.\n -> Please run \'update_package_hashes.cmd\' from the bootstrap directory.\n", $output_length);
          $output_length= 0 ;
      }
    }
  }
  output_line(" -- Done", $output_length);
  return @filearray;
}


sub unpack_file {
  # will unpack the filenames in the passed array using the correct tool depending on archive type.
  # Parameter 1 : $location, directory to find the packages.
  # Parameter 2 : $destination, where to unpack these files.
  # Parameter 3 : $filenamesref, REFERENCE to an array of the actual packages to be unpacked.
  # Paramater 4 : $filespecsref, REFERENCE to an array of colon separated filenames to be unpacked.
  # RETURNS : TRUE if no errors, FALSE and break on any error.

  my ($location, $destination, $filenamesref, $filespecsref) = @_;

  my @filenames = @$filenamesref;
  my @filespecs = @$filespecsref;

  # set a variable to contain the output length so we can delete it in the next loop invocation.
  # initially set to zero.
  my $output_length  = 0;
  # variable to hold the filename of the underlying tar file.
  my $tarfile= "";

  # unbuffer output, otherwise we cant overwrite the previous line...
  local $| = 1;

  my $count = 0;
  foreach my $file (@filenames) {
    my @exts = qw(.lzma .xz .zip .bz2 .gz .7z .exe);
    my ($dir, $name, $ext) = fileparse($file, @exts);

    # get the filespec if it exists and replace colon with spaces...
    $filespecs[$count] =~ s/^\s+|\s+$//g;
    $filespecs[$count] =~ s/:/ /g;

    # sometimes we may not want to unpack a package, during development for example,
    # just donwload it and ignore for now...
    if ($filespecs[$count] eq "^ignore^") {
      # leave this loop, dont try to unpack at this time.
      next;
    }

    my $extra_switches = "";

    # give an indication that we are working on a file.
    # otherwise, for long unpacks, especially the scripted ones, it seems we have hung...
    my $output_string = " -> Unpacking package : \"$file\" ";
    $output_length = output_line($output_string, $output_length);

    my $unpackfile = "";

    # FIXME : There should be a way to combine both the below choices, and then use 7za for both (latter part is easy)
    for ($ext) {
      if (/lzma/ || /xz/ || /bz2/ || /gz/ || /7z/ || /exe/) {
        # Note that so far all non-zip files are tar.lzma (or whatever) so we need a 2-stage operation to unpack them properly
        # However 7za.exe does not support reading from a pipe so we need to unpack the envelope, unpack the tar, and then delete the tar.
        # we assume that all files are tar.<whatever> for the moment, checking for this will be added later in case of exceptions.
        if ( $file =~ /\.tar\./ ) {
          `$dirs{"support"}/7za x -y $location/$file -o$destination`;
          $tarfile = basename(substr($file, 0, -length($ext)));
          $unpackfile = $destination."/".$tarfile;
        } else {
          $unpackfile = $location."/".$file;
        }
        if ($filespecs[$count] eq "^script^") {
          do_scripted($file, $location, $destination);
        } else {
          # no script related unpack cleanup, just unpack into the correct directory as normal...
          # get the 'f|' flag from unpack specs if existing and set flag accordingly. Remove this from filespec.
          if ($filespecs[$count] =~ s/^f\|//) {
            $extra_switches = "e";
          } else {
            $extra_switches = "x";
          }
          `$dirs{"support"}/7za $extra_switches -y $unpackfile $filespecs[$count] -o$destination`;
        }
      }
      elsif (/zip/) {
        # this is only one stage, since I've never seen a .tar.zip! Therefore we cant use the above unpack
        # logic, even though 7za.exe can easily unpack zip fies.
        if ($filespecs[$count] eq "^script^") {
          # this package has specified extra unpack clean up, so we need to :
          do_scripted($file, $location, $destination);
        } else {
          # no script related unpack cleanup, just unpack into the correct directory as normal...
          # get the 'f|' flag from unpack specs if existing and set flag accordingly. Remove this from filespec.
          if ($filespecs[$count] =~ s/^f\|//) {
            $extra_switches = "-j";
          } else {
            $extra_switches = "";
          }
          my $unpack_cmd = $dirs{"base"}."/unzip.exe $extra_switches -o $location/$file $filespecs[$count]  -d $destination";
          `$unpack_cmd`;
        }
      }
      else {
        # not an extension that we are prepared to handle, so crash out with notification.
        print "$file is an UNSUPPORTED extension!! Aborting until reality is resumed.\n";
        exit 2; # error 2, Unknown archive type.
      }
    }
    # check for the last error and abort if not zero.
    if ($? == 0) {
      my $output_string = " -- Package : \"$file\" Unpacked succesfully.";
      $output_length = output_line($output_string, $output_length);
    } else {
      my $error = $? >>8;
      print "\nError $error when trying to unpack $file, aborting all processing\n";
      exit 1; # error 1, failure to unpack a package.
    }
    # delete any remaining tar files if needed..
    if (-e $destination."/".$tarfile) {
      unlink $destination."/".$tarfile;
    }
    $count++;
  }
  # if we get here, there must have been no errors, so return TRUE (well, we would if this was not Perl....).
  output_line(" -- Done", $output_length);
  return 1;
}

sub do_scripted {
  # this sub will perform the scripted unpacking.
  # Parameter 1 : The filename
  # Parameter 2 : Location of package
  # Parameter 3 : Destination for unpacked files
  my ($file, $location, $destination) = @_;

  my $temp_dir = unpack_to_temp($file, $location);
  # 2) Call the script to deal with the files, script filename determined by the package filename
  scripted_unpack($file, $temp_dir);
  # 3) Copy the remaining files in the temp dir to the required directory
  dircopy($temp_dir, $destination);
  # 4) Delete the temp directory.
  if (-d $temp_dir) {
    rmtree $temp_dir or die "Cannot delete temporary unpack directory!";
  }
}

sub unpack_to_temp {
  # unpack the provided filename into a temp directory.
  # Parameter 1 : filename of package to unpack
  # Parameter 2 : location of this package.
  # Returns : name of tmp directory.
  my ($file, $location) = @_;
  my $temp_dir = $dirs{"package"}."/tmp-$file";
  create_dir($temp_dir);
  `$dirs{"support"}/7za.exe x -y $location/$file -o$temp_dir`;
  if ($? ==0) {
    return $temp_dir;
  } else {
    my $error = $? >> 8;
    die "Cannot unpack $file to tmp directory $temp_dir, Exiting (Error $error).";
  }
}

sub scripted_unpack {
  # this sub runs an unpack script for the specified filename, script name determined from this.
  my ($file, $temp_dir) = @_;
  local @ARGV = ($file, $temp_dir);
  my $function_name = $file;
  $function_name =~ s/[.|-]//g;
  $function_name = 'unpack/'.$function_name.'.pl';
  if (-e $function_name) {
    do $function_name;
  } else {
    die "Error : Cannot find unpack script $function_name\n\n";
  }
}

sub output_line {
  # this will output a line to console, on the same line and overwriting the previous.
  my ($out_string, $out_length) = @_;

  if ($out_length > 0) {
    # move cursor to beginning of string and delete the previous data...
    printf ("\r%s\r$out_string", " " x $out_length);
  } else {
    print $out_string;
  }
  $out_length = length($out_string);
  # return this length so can be fed to us again in the next call...
  return $out_length;
}


sub read_hashes {
  # subroutine that will read the hash values from the 'hashes' file and populate a perl hash containing filename and MD5 hash.
  # 'hashes' file is CSV, with MD5 followed by bare filename (no paths). Note this fact will be annoying if we ever have files with
  # identical filenames but in different cache subdirs - lets not do that!
  my $hash_file = $dirs{"base"}."/hashes";
  # temp storage hash to be returned to main program
  my %hash = ();

  # read in the file ...
  open my $handle, '<', $hash_file or die "Cant open hashes file! Please ensure this has been created.\n\n";
  chomp(my @hash_lines = <$handle>);
  close $handle;
  # iterate over all these lines, split on the comma and save as a hash pair...
  foreach my $line (@hash_lines) {
    my @values = split(',', $line);
    $hash{$values[1]} = $values[0];
  }
  return %hash;
}

sub create_dir {
  # creates a directory if it does not already exist, bomb with error if cant create.
  # Parameter 1 : $new_dir, directory to create.
  my ($new_dir) = @_;
  if (!-d $new_dir) {
    mkdir $new_dir or die "Cannot create directory $new_dir, exiting.";
  }
}
