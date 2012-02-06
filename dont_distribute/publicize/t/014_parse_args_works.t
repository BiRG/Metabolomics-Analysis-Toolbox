#!/usr/bin/perl

#Check that set_source and set_dest work as expected

use strict;
use warnings;

use File::Temp qw( tempfile tempdir );
use File::Spec::Functions;
use FindBin;
use Test::Output;
use Test::More tests => 11;


use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin";
BEGIN { use_ok('LocalMirror'); }
BEGIN { use_ok('LocalMirrorTestUtils'); }

#########
# Setup #
#########

#Make two empty temporary directories that will be deleted on exit
my $src_dir = File::Temp->newdir("LocalMirrorTestSrc_XXXXXXXX");
my $dest_dir = File::Temp->newdir("LocalMirrorTestDest_XXXXXXXX");

my $src_name = $src_dir->dirname;
my $dest_name = $dest_dir->dirname;


#############
# Main test #
#############

#Two arguments
combined_is {parse_args $src_name, $dest_name;} '',
    'parse_args has no output when given correct input.';

#No arguments
combined_like{ parse_args; } qr/Usage: /,
    "Usage message printed when parse_args has no arguments";

like($@,qr/two command line arguments/,
     "$@ set to correct error message when parse_args has no arguments");

#One argument
combined_like{ parse_args $src_name; } qr/Usage: /,
    "Usage message printed when parse_args has one argument";

like($@,qr/two command line arguments/,
     "$@ set to correct error message when parse_args has one argument");

#Two arguments but source is not a directory
combined_like {parse_args(File::Spec->catfile($src_name,'not a file'), 
	     $dest_name);} qr/Usage: /,
    'parse_args prints usage when not given a source directory';

like($@,qr/source .* not a directory/,
     "\$@ set to correct error message when parse_args has non-directory source");

#Two arguments but dest is not a directory
combined_like {parse_args($src_name, 
	       File::Spec->catfile($dest_name,'not a file'));} qr/Usage: /,
    'parse_args prints usage when not given a dest directory';

like($@,qr/destination .* not a directory/,
     "\$@ set to correct error message when parse_args has non-directory dest");


