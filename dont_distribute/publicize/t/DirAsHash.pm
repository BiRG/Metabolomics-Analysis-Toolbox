#!/usr/bin/perl
#Package boilerplate
package DirAsHash; # start new namespace; scope extends to EOF
use Exporter;        # load Exporter module
@ISA=qw(Exporter);   # Inherit from Exporter
@EXPORT=qw(dir_as_hash); 

#Real package stuff begins here
use strict;
use warnings;
use File::Path;
use File::Spec;
use File::Find ();

#####
# Given a directory name
# Return the structure of a directory as a hash.  Filenames are keys
# with empty string values.  Directory names are keys with hash values.
#
# If the name passed is not a directory, returns undef
#####

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


1;
