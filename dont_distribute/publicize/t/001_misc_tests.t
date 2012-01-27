#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;

my $public_dir = "/home/repo_publicizer/public/toolbox";
my $private_dir = "/home/repo_publicizer/public/toolbox";
my $publicizer_dir = "/home/repo_publicizer/public/toolbox/dont_distribute/publicizer";
my $public_test_branch = "branch-used-by-test-scripts";

#1 test
sub test_cd($$){
    my ($dir,$human_readable)=@_;
    ok(chdir($dir), "Change to the $human_readable directory. (If not ok, error was: $!)");
}

#1 test
sub cd_pubdir{ test_cd($public_dir,"public"); }

#1 test
sub cd_publicizer{ test_cd($publicizer_dir, "publicizer"); }

#1 test
sub cd_private{ test_cd($private_dir, "private"); }

#2 tests
sub put_public_repo_in_test_mode{
    cd_pubdir();
    ok(!system("git", "checkout", $public_test_branch),
       "Successfully checked out test branch");
}

#2 tests
sub put_public_repo_in_normal_mode{
    cd_pubdir();
    ok(!system("git", "checkout", "master"), 
       "Successfully checked out master branch");
}

#Does a git reset --hard HEAD to completely revert private repo to the
#latest revision
#
#4 tests
sub revert_private{
    cd_publicizer();
    ok(!system("git", "checkout", "public_files_toolbox.prf",
	       "public_toolbox_specific_files.prf"),
       "Checked out head revision of *.prf files");
}

#Bail if there are local changes that would be clobbered by running
#the test suite.

if(!system("git", "status", "-a")){
    BAIL_OUT("There are uncommitted local changes to the private ".
	     "repository that would be overwritten by the test suite.  ".
	     "Aborting to preserve these changes.");
}

#Set up the public repo for testing
put_public_repo_in_test_mode();

#Put the public repo in the state for normal commits
put_public_repo_in_normal_mode();


