#!/usr/bin/perl

#Check that everything in dest is deleted (when there are no preserved
#files) but nothing in src is deleted)

use strict;
use warnings;
use File::Temp qw( tempfile tempdir );
use File::Spec::Functions;
use FindBin;
use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin";
use Test::More tests => 5;
BEGIN { use_ok('LocalMirror'); }

#####
# Given a directory name
# Return the structure of a directory as a hash.  Filenames are keys
# with empty string values.  Directory names are keys with hash values.
#
# If the name passed is not a directory, returns undef
#####

use File::Find ();
sub dir_as_hash{
    my ($dname)=@_;
    return undef unless -d $dname;
    
    my $this_dir = {};
    my $add_entry = sub {
	if(-f){
	    $$this_dir{$_}=''; return;
	}elsif(-d){
	    return if (/^\.\.?$/); #Skip . and ..
	    $$this_dir{$_}=dir_as_hash($_);
	    $File::Find::prune = 1;
	    return;
	}
    };
    File::Find::find($add_entry, $dname);
    return $this_dir;
}

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

#Do the deletion
delete_dest;

#Test to make sure that the source structure is as expected
is_deeply(dir_as_hash($src_name), $src_expected_structure_before,
   "src has correct final structure (nothing changed)");

#Test to make sure that the dest structure is as expected
is_deeply(dir_as_hash($dest_name), {},
   "dest has correct final structure (everything removed)");

