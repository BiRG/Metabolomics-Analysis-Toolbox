#!/usr/bin/perl

#Check that delete_dest preserves non-file, non-directory objects with
#a warning when they are not protected and just preserves them when
#they are protected by dont_delete

use strict;
use warnings;

use File::Temp qw( tempfile tempdir );
use File::Spec::Functions;
use FindBin;
use Test::Output;
use Test::More tests => 10;


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
# | |
# | + destFullFifo
# |
# + /destdirEmpty
system("touch",catfile($dest_name,"dest1"));
system("touch",catfile($dest_name,"dest2"));
system("mkdir",catfile($dest_name,"destdirEmpty"));
system("mkdir",catfile($dest_name,"destdirFull"));
system("touch",catfile($dest_name,"destdirFull","destFullFile1"));
system("touch",catfile($dest_name,"destdirFull","destFullFile2"));
system("mkfifo",catfile($dest_name,"destdirFull","destFullFifo"));

my $dest_expected_structure_before = 
{ dest1=>"", dest2=>"", 
  destdirFull=>{ destFullFile1=>"", destFullFile2=>"", destFullFifo=>'' },
  destdirEmpty=>{} };


#############
# Main test #
#############

#Make the temp dirs the source and destination
set_source $src_name;
set_dest $dest_name;

#Test to make sure that the source structure is as expected
is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src has correct initial structure");

#Test to make sure that the dest structure is as expected
is_deeply(dir_as_hash($dest_name), $dest_expected_structure_before,
   "dest has correct initial structure");

#Do the preservation and deletion
dont_delete qr(destdirFull/destFullFile1$);
stderr_like {delete_dest;} qr/Warning: .* is not a file or a directory and so cannot be deleted.*/,"delete_dest prints a warning message when it encounters an unprotected non-file object.";

#Test to make sure that the source structure is as expected
is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src has correct final structure (nothing changed)");

#Test to make sure that the dest structure is as expected
is_deeply(dir_as_hash($dest_name), 
	  {destdirFull=>{ destFullFile1=>"", destFullFifo=>'' }},
	  "dest has everything but destFullFile1 and destFullFifo removed");

#Do the preservation and deletion with an explicit protection for the fifo
dont_delete qr(destdirFull/destFullFifo$);
stderr_is {delete_dest;} '','delete_dest prints no warning message for protected non-file object.';

#Test to make sure that the source structure is as expected
is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   'src has correct final structure (nothing changed)');

#Test to make sure that the dest structure is as expected
is_deeply(dir_as_hash($dest_name), 
	  {destdirFull=>{ destFullFile1=>"", destFullFifo=>'' }},
	  'dest has everything but destFullFile1 and destFullFifo removed');


