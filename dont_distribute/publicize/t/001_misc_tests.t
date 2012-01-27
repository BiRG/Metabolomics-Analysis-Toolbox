#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;

my $public_dir = "/home/repo_publicizer/public/toolbox";
my $private_dir = "/home/repo_publicizer/public/toolbox";
my $publicizer_dir = "/home/repo_publicizer/public/toolbox/dont_distribute/publicizer";
my $public_test_branch = "branch-used-by-test-scripts";

sub cd_pubdir{
    ok(chdir($public_dir), "Change to the public directory. (If not ok, error was: $!)");
}

sub put_public_repo_in_test_mode{
    cd_pubdir();
    ok(!system("git", "checkout", $public_test_branch),
       "Successfully checked out test branch");
}

sub put_public_repo_in_normal_mode{
    cd_pubdir();
    ok(!system("git", "checkout", "master"), 
       "Successfully checked out master branch");
}


put_public_repo_in_test_mode();
put_public_repo_in_normal_mode();

