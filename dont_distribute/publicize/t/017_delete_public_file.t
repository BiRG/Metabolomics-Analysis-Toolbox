#!/usr/bin/perl

#Check that renaming a public file syncs correctly

use strict;
use warnings;

use File::Temp qw( tempfile tempdir );
use File::Spec::Functions;
use FindBin;
use Test::Output;
use Test::Exception;
use Test::More tests => 7;


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

# Make initial files in source directory
#
# |
# + /.git
# | |
# | + config
# |
# + public_file_1
# |
# + public_file_2
# |
# + private_file_1
# |
# + private_file_2
# |
# + /pubd_full_1
# | |
# | + pubd_full_1_file_1
# | |
# | + pubd_full_1_file_2
# |
# + /pubd_empty
# |
# + /privd_full_1
# | |
# | + privd_full_1_file_1
# | |
# | + privd_full_1_file_2
# |
# + /privd_empty
# 
#

#This is the same for all of the full system tests
 
system('mkdir',catfile($src_name,'.git'));
system('echo -e -n "[core]\n\trepositoryformatversion = 0\n\tfilemode = true\n\tbare = false\n\tlogallrefupdates = true\n" > '.catfile($src_name,'.git','config'));
system('echo "Txt: public_file_1" > '.catfile($src_name,'public_file_1'));
system('echo "Txt: public_file_2" > '.catfile($src_name,'public_file_2'));
system('echo "Txt: private_file_1" > '.catfile($src_name,'private_file_1'));
system('echo "Txt: private_file_2" > '.catfile($src_name,'private_file_2'));
system('mkdir',catfile($src_name,'pubd_full_1'));
system('echo "Txt: pubd_full_1_file_1" > '.
       catfile($src_name,'pubd_full_1','pubd_full_1_file_1'));
system('echo "Txt: pubd_full_1_file_2" > '.
       catfile($src_name,'pubd_full_1','pubd_full_1_file_2'));
system("mkdir",catfile($src_name,"pubd_empty"));
system('mkdir',catfile($src_name,'privd_full_1'));
system('echo "Txt: privd_full_1_file_1" > '.
       catfile($src_name,'privd_full_1','privd_full_1_file_1'));
system('echo "Txt: privd_full_1_file_2" > '.
       catfile($src_name,'privd_full_1','privd_full_1_file_2'));
system("mkdir",catfile($src_name,"privd_empty"));

#Changes for this particular test
system('rm',
       catfile($src_name,'public_file_1'));
       


my $src_expected_structure_before = 
{ 
    ".git"=>{
	config=>"[core]\n\trepositoryformatversion = 0\n".
	    "\tfilemode = true\n\tbare = false\n\tlogallrefupdates = true\n"},
    public_file_2=>"Txt: public_file_2\n", 
    private_file_1=>"Txt: private_file_1\n", 
    private_file_2=>"Txt: private_file_2\n", 
    pubd_full_1=>{
	pubd_full_1_file_1=>"Txt: pubd_full_1_file_1\n",
	pubd_full_1_file_2=>"Txt: pubd_full_1_file_2\n"},
    pubd_empty=>{},
    privd_full_1=>{
	privd_full_1_file_1=>"Txt: privd_full_1_file_1\n",
	privd_full_1_file_2=>"Txt: privd_full_1_file_2\n"},
    privd_empty=>{},
};


# Make initial files in destination directory
#
# |
# + /.git
# | |
# | + config
# |
# + public_file_1
# |
# + public_file_2
# |
# + /pubd_full_1
# | |
# | + pubd_full_1_file_1
# | |
# | + pubd_full_1_file_2
# |
# + /pubd_empty
# 
system('mkdir',catfile($dest_name,'.git'));
system('echo -e -n "[core]\n\trepositoryformatversion = 0\n\tfilemode = true\n\tbare = false\n\tlogallrefupdates = true\n[remote \"origin\"]\n\tfetch = +refs/heads/*:refs/remotes/origin/*\n\turl = git@github.com:BiRG/Metabolomics-Analysis-Toolbox.git\n" > '.catfile($dest_name,'.git','config'));
system('echo "Txt: public_file_1" > '.catfile($dest_name,'public_file_1'));
system('echo "Txt: public_file_2" > '.catfile($dest_name,'public_file_2'));
system('mkdir',catfile($dest_name,'pubd_full_1'));
system('echo "Txt: pubd_full_1_file_1" > '.
       catfile($dest_name,'pubd_full_1','pubd_full_1_file_1'));
system('echo "Txt: pubd_full_1_file_2" > '.
       catfile($dest_name,'pubd_full_1','pubd_full_1_file_2'));
system("mkdir",catfile($dest_name,"pubd_empty"));
my $dest_expected_structure_before = 
{ 
    ".git"=>{
	config=>"[core]\n\trepositoryformatversion = 0\n".
	    "\tfilemode = true\n\tbare = false\n\tlogallrefupdates = true\n".
	    "[remote \"origin\"]\n\tfetch = +refs/heads/\*:".
	    "refs/remotes/origin/\*\n\turl = ".
	    "git\@github.com:BiRG/Metabolomics-Analysis-Toolbox.git\n"},
    public_file_1=>"Txt: public_file_1\n", 
    public_file_2=>"Txt: public_file_2\n", 
    pubd_full_1=>{
	pubd_full_1_file_1=>"Txt: pubd_full_1_file_1\n",
	pubd_full_1_file_2=>"Txt: pubd_full_1_file_2\n"},
    pubd_empty=>{},
};


#############
# Main test #
#############

#Test to make sure that the src directory is as expected
is_deeply(dir_as_hash($src_name, with_contents=>1), 
	  $src_expected_structure_before,
	  "src directory correct before mirror");

#Test to make sure that the dest directory is as expected
is_deeply(dir_as_hash($dest_name, with_contents=>1), 
	  $dest_expected_structure_before,
	  "dest directory correct before mirror");

#Do the mirror (the mirror script includes the new file and has a name
#that is the same as this script but with a .syncscript extention
#instead of a .t extention)
my $mirror_script_name=$0;
$mirror_script_name =~ s/\.t$/.syncscript/;

combined_is {system($mirror_script_name, $src_name, $dest_name);} '', 'Mirror script executes without complaining';

#Test to make sure that the src directory hasn't changed
is_deeply(dir_as_hash($src_name, with_contents=>1), 
	  $src_expected_structure_before,
	  "src directory hasn't changed after mirror");

#Test to make sure that the destination directory is correct
is_deeply(dir_as_hash($dest_name, with_contents=>1), 
	  { 
	      ".git"=>{
		  config=>"[core]\n\trepositoryformatversion = 0\n".
		      "\tfilemode = true\n\tbare = false\n".
		      "\tlogallrefupdates = true\n".
		      "[remote \"origin\"]\n\tfetch = +refs/heads/\*:".
		      "refs/remotes/origin/\*\n\turl = git\@github.com:".
		      "BiRG/Metabolomics-Analysis-Toolbox.git\n" },
		      public_file_2=>"Txt: public_file_2\n", 
		      pubd_full_1=>{
			  pubd_full_1_file_1=>"Txt: pubd_full_1_file_1\n",
			  pubd_full_1_file_2=>"Txt: pubd_full_1_file_2\n" },
	      pubd_empty=>{},
	  },
	  "dest directory is correct after mirror");

