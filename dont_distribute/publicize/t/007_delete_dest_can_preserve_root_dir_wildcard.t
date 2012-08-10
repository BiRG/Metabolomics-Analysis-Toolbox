#!/usr/bin/perl

#Check that dont_delete pattern_for_dir_in_root_dir; will preserve
#matching directories from deletion by delete_dest

use strict;
use warnings;

use File::Temp qw( tempfile tempdir );
use File::Spec::Functions;
use FindBin;
use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin";
use Test::More tests => 6;
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
# | + destFullFile
# |
# + /destdirEmpty
# 
system("touch",catfile($dest_name,"dest1"));
system("touch",catfile($dest_name,"dest2"));
system("mkdir",catfile($dest_name,"destdirEmpty"));
system("mkdir",catfile($dest_name,"destdirFull"));
system("touch",catfile($dest_name,"destdirFull","destFullFile"));

my $dest_expected_structure_before = 
{ dest1=>"", dest2=>"", destdirFull=>{ destFullFile=>"" },
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

#Do the preservation and  deletion
dont_delete qr/^destdir(Full|Empty)$/;

delete_dest;

#Test to make sure that the source structure is as expected
is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src has correct final structure (nothing changed)");

#Test to make sure that the dest structure is as expected
is_deeply(dir_as_hash($dest_name), {destdirEmpty=>{},
				    destdirFull=>{ destFullFile=>"" }},
   "dest has everything but destdir* and their contents removed");

