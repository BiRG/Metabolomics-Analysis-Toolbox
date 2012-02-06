#!/usr/bin/perl

#Check that set_source and set_dest work as expected

use strict;
use warnings;

use File::Temp qw( tempfile tempdir );
use File::Spec::Functions;
use FindBin;
use Test::Exception;
use Test::More tests => 13;


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

#Make some files and directories in source
#
# + src1
# |
# + src2
# |
# + /srcdirFull
# | |
# | + srcFullFile
# |
# + /srcdirEmpty
# 
system("touch",catfile($src_name,"src1"));
system("touch",catfile($src_name,"src2"));
system("mkdir",catfile($src_name,"srcdirEmpty"));
system("mkdir",catfile($src_name,"srcdirFull"));
system("touch",catfile($src_name,"srcdirFull","srcFullFile"));

my $src_expected_structure_before = 
{ src1=>"", src2=>"", srcdirFull=>{ srcFullFile=>"" },
  srcdirEmpty=>{} };

#Make some files and directories in dest
#
# + dest1
# |
# + dest2
# |
# + /destdirFull
# | |
# | + destFullFile1
# | |
# | + destFullFile2
# |
# + /destdirEmpty
# 
system("touch",catfile($dest_name,"dest1"));
system("touch",catfile($dest_name,"dest2"));
system("mkdir",catfile($dest_name,"destdirEmpty"));
system("mkdir",catfile($dest_name,"destdirFull"));
system("touch",catfile($dest_name,"destdirFull","destFullFile1"));
system("touch",catfile($dest_name,"destdirFull","destFullFile2"));

my $dest_expected_structure_before = 
{ dest1=>"", dest2=>"",
  destdirFull=>{ destFullFile1=>"", destFullFile2=>"" },
  destdirEmpty=>{}};


#############
# Main test #
#############

#Make the temp dirs the source and destination
set_source $src_name;
is(get_source, File::Spec->rel2abs($src_name), "source is set to expected value when the value is a directory");

set_dest $dest_name;
is(get_dest, File::Spec->rel2abs($dest_name), "dest is set to expected value when the value is a directory");

#Test to make sure that the source structure is as expected
is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src has correct initial structure");

#Test to make sure that the dest structure is as expected
is_deeply(dir_as_hash($dest_name), $dest_expected_structure_before,
   "dest has correct initial structure");

#Make sure my extant file really exists and my non-existent file
#really doesn't exist
my $extant_file = File::Spec->catfile($src_name,'src1');
my $nonexistant_file = File::Spec->catfile($src_name,'this-is-not-a-file');

ok( -e $extant_file, 'extant file exists');
ok( -f $extant_file, 'extant file is a file');
ok( ! -e $nonexistant_file, 'non-existant file does not exist');

#Make sure set_source dies when it should
dies_ok {set_source($extant_file); } 
"set_source dies when given a file rather than a directory";

dies_ok {set_source($nonexistant_file); } 
"set_source dies when given a non-existent file";

#Make sure set_dest dies when it should
dies_ok {set_dest($extant_file); } 
"set_dest dies when given a file rather than a directory";

dies_ok {set_dest($nonexistant_file); } 
"set_dest dies when given a non-existent file";

