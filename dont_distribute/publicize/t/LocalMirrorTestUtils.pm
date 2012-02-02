#!/usr/bin/perl
#Package boilerplate
package LocalMirrorTestUtils; # start new namespace; scope extends to EOF
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
#
# Return the structure of a directory as a hash.  Filenames are keys
# with empty string values.  Directory names are keys with hash values.
#
# If the name passed is not a directory, returns undef
#
# Can be called as:
#
# dir_as_hash('dirname');
#
# or
#
# dir_as_hash('dirname',with_contents=>1);
#
# when the option with_contents is defined, the the filenames become
# keys with the string values being the contents of the file.  If a
# filename points to a non-file object, the contents of that object
# are not read, and the value associated with that key is left as a
# blank.  If a file cannot be read, its contents will be undef.
#####

sub dir_as_hash{
    my $dname=shift;
    my @options_array = @_;
    my %options = @_; #Rest of arguments are treated as an options hash
    return undef unless -d $dname;
    
    my $this_dir = {};
    my $add_entry = sub {
	if(-d){
	    return if (/^\.\.?$/); #Skip . and ..
	    if( keys %options == 0){
		$$this_dir{$_}=dir_as_hash($_);
	    }else{
		$$this_dir{$_}=dir_as_hash($_,@options_array);
	    }
	    $File::Find::prune = 1;
	    return;
	}elsif(-f){
	    if ( exists $options{'with_contents'} ){
		local( $/ ) ;
		if(open( my $fh, $_ )){
		    $$this_dir{$_} = <$fh>;
		}else{
		    $$this_dir{$_}= undef;
		}
	    }else{
		$$this_dir{$_}=''; 
	    }
	    return;
	}else{ 
            #Treat non-file/non-directory objects the same as file
            #objects - just list them
	    $$this_dir{$_}=''; return;
	}
    };
    File::Find::find($add_entry, $dname);
    return $this_dir;
}


1;
