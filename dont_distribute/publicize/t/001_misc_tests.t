#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 18;
use File::Path qw(rmtree);
use File::Copy;

my $public_dir = "/home/repo_publicizer/public/toolbox";
my $private_dir = "/home/repo_publicizer/private/toolbox";
my $publicizer_dir = "/home/repo_publicizer/private/toolbox/dont_distribute/publicize";
my $public_test_branch = "branch-used-by-test-scripts";
my $home_dir = "/home/repo_publicizer";

#1 test
sub test_cd($$){
    my ($dir,$human_readable)=@_;
    $! = 0; #Reset to no error so no spurious messages show up
    ok(chdir($dir), "Change to the $human_readable directory. (If not ok, error was: $!)");
}

#1 test
sub cd_pubdir{ test_cd($public_dir,"public"); }

#1 test
sub cd_publicizer{ test_cd($publicizer_dir, "publicizer"); }

#1 test
sub cd_private{ test_cd($private_dir, "private"); }

#1 test
sub cd_home{ test_cd($home_dir, "home"); }

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
    ok(!system("git", "reset","--hard","HEAD"),
       "Successful reset --hard to put private repository back into shape");
}

#Copy the given file over top of the public_files_toolbox.prf - give
#the name relative to $publicizer_dir
#
#2 tests
sub copy_pub_files_prf($){
    my ($rel_name)=@_;
    cd_publicizer();
    my $dest = "public_files_toolbox.prf";
    ok(copy($rel_name, $dest), "Copy $rel_name over top of $dest");   
}

#Copy the given file over top of the public_toolbox_specific_files.prf - give
#the name relative to $publicizer_dir
#
#2 tests
sub copy_specific_files_prf($){
    my ($rel_name)=@_;
    cd_publicizer();
    my $dest = "public_toolbox_specific_files.prf";
    ok(copy($rel_name, $dest), "Copy $rel_name over top of $dest");   
}

#1 test
sub create_file($$){
    my($name,$contents)=@_;
    ok(open(my $fh,">",$name),"open call while creating file $name");
    print $fh $contents;
    close($fh);
}

#1 test
sub rm($){
    my ($name)=@_;
    if( -d $name ) {
	ok(rmtree($name), "Removing the directory $name");
    }else{
	ok(unlink($name), "Deleting the file $name");
    }
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

#Clear the private repo
revert_private();

#Create a public file
cd_private();
create_file("a_public_file","a pub contents");
copy_pub_files_prf("p001_create_public_file.prf");
cd_home();
system("publicize_toolbox.sh");
cd_private();
rm("a_public_file");

#Put private repo back in its initial state
revert_private();
#Put the public repo in the state for normal commits
put_public_repo_in_normal_mode();


