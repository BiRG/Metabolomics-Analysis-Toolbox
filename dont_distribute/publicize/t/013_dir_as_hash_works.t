#!/usr/bin/perl

#Check that set_source and set_dest work as expected

use strict;
use warnings;

use File::Temp qw( tempfile tempdir );
use File::Spec::Functions;
use FindBin;
use Test::Exception;
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
system("echo \"This is src1\" > ".catfile($src_name,"src1"));
system("echo \"This is src2\" > ".catfile($src_name,"src2"));
system('touch',catfile($src_name,"emptyFile"));
system("mkdir",catfile($src_name,"srcdirEmpty"));
system("mkdir",catfile($src_name,"srcdirFull"));
system("echo \"This is srcFullFile\" > ".catfile($src_name,"srcdirFull","srcFullFile"));
system("echo \"This is an unreadable file\" > ".catfile($src_name,"unreadable"));
system('chmod','a-r',catfile($src_name,"unreadable"));

my $src_expected_structure_no_contents = 
{ src1=>"", src2=>"", emptyFile=>'', srcdirFull=>{ srcFullFile=>"" },
  srcdirEmpty=>{}, unreadable=>'' };

my $src_expected_structure_with_contents = 
{ src1=>"This is src1\n", src2=>"This is src2\n", emptyFile=>'', 
  srcdirFull=>{ srcFullFile=>"This is srcFullFile\n" },
  srcdirEmpty=>{}, unreadable=>undef };

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
system("echo \"the rain in spain falls mainly on the plain\" > ".catfile($dest_name,"dest1"));
system("touch",catfile($dest_name,"dest2"));
system("mkdir",catfile($dest_name,"destdirEmpty"));
system("mkdir",catfile($dest_name,"destdirFull"));
system("touch",catfile($dest_name,"destdirFull","destFullFile1"));
system("touch",catfile($dest_name,"destdirFull","destFullFile2"));

my $dest_expected_structure_no_contents = 
{ dest1=>"", dest2=>"",
  destdirFull=>{ destFullFile1=>"", destFullFile2=>"" },
  destdirEmpty=>{}};

my $dest_expected_structure_with_contents = 
{ dest1=>"the rain in spain falls mainly on the plain\n", dest2=>"",
  destdirFull=>{ destFullFile1=>"", destFullFile2=>"" },
  destdirEmpty=>{}};


#############
# Main test #
#############

#Make the temp dirs the source and destination
set_source $src_name;
set_dest $dest_name;

#Test to make sure that the source structure is reported correctly
#with no contents
is_deeply(dir_as_hash($src_name), $src_expected_structure_no_contents,
   "src structure reported correctly without file contents");

is_deeply(dir_as_hash($src_name, with_contents=>1), 
	  $src_expected_structure_with_contents,
	  "src structure reported correctly with file contents");

#Test to make sure that the dest structure is reported correctly
is_deeply(dir_as_hash($dest_name), $dest_expected_structure_no_contents,
   "dest structure reported correctly without file contents");

is_deeply(dir_as_hash($dest_name, with_contents=>1), 
	  $dest_expected_structure_with_contents,
	  "dest structure reported correctly with file contents");


#Make sure my extant file really exists and my non-existent file
#really doesn't exist
my $extant_file = File::Spec->catfile($src_name,'src1');
my $nonexistant_object = File::Spec->catfile($src_name,'this-is-not-a-file');

ok( -e $extant_file, 'extant file exists');
ok( -f $extant_file, 'extant file is a file');
ok( ! -e $nonexistant_object, 'non-existant object does not exist');


#Test that dir_as_hash returns undef when passed a file
is(dir_as_hash($extant_file),undef,
   "dir_as_hash returns undef when passed a file");
is(dir_as_hash($nonexistant_object),undef,
   "dir_as_hash returns undef when passed a non-existant object");
