#!/usr/bin/perl

#Check that mirror2 prints warnings and errors under the correct
#conditions.  Also does some testing that copying works as expected

use strict;
use warnings;

use File::Temp qw( tempfile tempdir );
use File::Spec::Functions;
use FindBin;
use Test::Output;
use Test::Exception;
use Test::More tests => 27;


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
# + .gitignore
# |
# + /.git
# | |
# | + conf
# |
# + /destdirFull
# | |
# | + destFullFile1
# | |
# | + destFullFile2
# |
# + /read_only_dir (read only)
# |
# + /destdirEmpty
# 
system("touch",catfile($dest_name,"dest1"));
system("touch",catfile($dest_name,"dest2"));
system("touch",catfile($dest_name,".gitignore"));
system("mkdir",catfile($dest_name,".git"));
system("touch",catfile($dest_name,".git","conf"));
system("mkdir",catfile($dest_name,"read_only_dir"));
system("chmod","a-w",catfile($dest_name,"read_only_dir"));
system("mkdir",catfile($dest_name,"destdirEmpty"));
system("mkdir",catfile($dest_name,"destdirFull"));
system("touch",catfile($dest_name,"destdirFull","destFullFile1"));
system("touch",catfile($dest_name,"destdirFull","destFullFile2"));

my $dest_expected_structure_before = 
{ dest1=>"", dest2=>"", '.gitignore'=>'', '.git'=>{conf=>''},
  destdirFull=>{ destFullFile1=>"", destFullFile2=>"" },
  destdirEmpty=>{}, read_only_dir=>{} };


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
dont_delete qr(\.git);
dont_delete qr(read_only_dir);
delete_dest;

#Ensure that the deletion went off ok
is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src is unchanged");

is_deeply(dir_as_hash($dest_name), 
	  {'.gitignore'=>'', '.git'=>{ conf=>'' }, read_only_dir=>{}},
	  "dest has only read_only_dir, .gitignore file and .git directory");

#Copy a root directory file
stderr_is {mirror2 "src1","src1";} '', 'Normal mirror shouldn\'t output anything';

is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src is unchanged");

is_deeply(dir_as_hash($dest_name), 
	  {'.gitignore'=>'', '.git'=>{ conf=>'' }, src1=>'', 
	   read_only_dir=>{}},
	  "dest has src1 as well as .git* files");


#Try to copy another file over it
stderr_is {mirror2 'src2','src1'} 'Warning: destination file '.
    File::Spec->catfile(get_dest(), 'src1').
    " already exists.  Overwriting.\n", 
    'Mirror should detect copying over extant file';

is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src is unchanged");

is_deeply(dir_as_hash($dest_name), 
	  {'.gitignore'=>'', '.git'=>{ conf=>'' }, src1=>'', 
	   read_only_dir=>{}},
	  "dest has src1 as well as .git* files");

#Try to copy a non-existent file - should print a warning
stderr_is {mirror2 'non-existent-file','non-ex'} 'Warning: Source file '.
    File::Spec->catfile(get_source(), 'non-existent-file').
    " does not exist.  Cannot copy.\n", 
    'Mirror should detect copying non-existent file';

is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src is unchanged");

is_deeply(dir_as_hash($dest_name), 
	  {'.gitignore'=>'', '.git'=>{ conf=>'' }, src1=>'',
	  read_only_dir=>{}},
	  "dest has src1 as well as .git* files");

#Try to copy into a directory normally
stderr_is {mirror2 'src2','dest_dir/src2'} '', 
    'Mirror2 should allow copying into a subdirectory';

is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src is unchanged");

is_deeply(dir_as_hash($dest_name), 
	  {'.gitignore'=>'', '.git'=>{ conf=>'' }, src1=>'',
	  read_only_dir=>{}, dest_dir=>{src2=>''}},
	  "dest has src1 dest_dir/src2 read_only_dir as well as .git* files");

#Try to copy a directory 
stderr_is {mirror2 'srcdirFull','srcdirFull';} '', 
    'Mirror2 should allow copying a directory';

is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src is unchanged");

is_deeply(dir_as_hash($dest_name), 
	  {'.gitignore'=>'', '.git'=>{ conf=>'' }, src1=>'',
	   read_only_dir=>{}, dest_dir=>{src2=>''}, 
	   srcdirFull=>{srcFullFile=>''}},
	  "dest has srcdirFull and srcdirFull/srcFullFile as well as older contents");


#Try to copy a file into a read-only directory
diag("\nThe error from cp -r is expected.  Change mirror2 from cp -r to using custom perl to get rid of it if it bothers you.");
dies_ok {mirror2 'src1','read_only_dir/src1';}  
    'Mirror2 should die when the copy cannot succeed';

is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src is unchanged");

is_deeply(dir_as_hash($dest_name), 
	  {'.gitignore'=>'', '.git'=>{ conf=>'' }, src1=>'',
	   read_only_dir=>{}, dest_dir=>{src2=>''}, 
	   srcdirFull=>{srcFullFile=>''}},
	  "dest unchanged from last command");

#Tries to copy file into subdirectory of read only directory
stderr_like {mirror2 'src1','read_only_dir/wontbecreated/src1';}  
qr(Error: Can't mirror .* because couldn't create ),
    'Mirror2 should die when the copy cannot succeed';

is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src is unchanged");

is_deeply(dir_as_hash($dest_name), 
	  {'.gitignore'=>'', '.git'=>{ conf=>'' }, src1=>'',
	   read_only_dir=>{}, dest_dir=>{src2=>''}, 
	   srcdirFull=>{srcFullFile=>''}},
	  "dest unchanged from last command");

