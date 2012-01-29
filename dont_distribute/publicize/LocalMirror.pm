#!/usr/bin/perl
#Package boilerplate
package LocalMirror; # start new namespace; scope extends to EOF
use Exporter;        # load Exporter module
@ISA=qw(Exporter);   # Inherit from Exporter
@EXPORT=qw(dont_delete is_in_dont_delete mirror mirror2 
           delete_dest set_source set_dest); 

use strict;
use warnings;
use File::Path;
use File::Spec;
use File::Copy;

#Path to source root
my $source;

#Path to destination root
my $dest;

#List of regexps that won't be deleted
my @preserve=();

#Add $_[1] to the list of protected regexp in dest
sub dont_delete($){ push @preserve, qr/$_[1]/; }

#Return true if $_[1] matches an expression in @preserve
sub is_in_dont_delete($){ 
    for my $regex (@preserve){
	return 1 if $_[0] =~ /$regex/;
    }
    return 0;
}


#Copy to a different location in the destination
#
#Print a warning if the source file does not exist or if the
#destination file already exists
#
#Die if the copy cannot be made.
#
#Copy the file or directory from source/$_[1] to dest/$_[2]
sub mirror2($$){
    my $sname=File::Spec->catfile($source, $_[1]);
    my $dname=File::Spec->catfile($dest, $_[2]);
    if(! -e $sname){
	print STDERR "Warning: Souce file $sname does not exist.  ",
	"Cannot copy.\n";
	return;
    }
    if(-e $dname){
	print STDERR "Warning: destination file $dname already exists.  ",
	"overwriting.\n";
    }
    #Directory in which the destination file lives - we will ensure it
    #and its predecessors exist
    my ($dvolume,$ddir,$dfile)=File::Spec->splitpath($dname);

    #Ensure parent directory exists
    unless(-e $ddir){
	eval { mkpath($ddir) };
	if ( $@ ) {
	    print STDERR "Warning: Couldn't create ${ddir}: $@";
	}
    }

    #Copy the source to the destination (only works on unix, but that
    #is all we care about right now)
    if(system("cp","-r",$sname,$dname) == 0){
	die "Could not copy \"$sname\" to \"$dname\"";
    }
}

#Copy the file to the same location in the destination
#
#An alias for mirror2($_[1],$_[1]);
sub mirror($){
    mirror2 $_[1],$_[2];
}

#Delete all files in dest that were not previously specified as dont_delete
sub delete_dest(){
    
}

#Sets the source path to $_[1].  The path must exist.  Dies if it
#doesn't.
sub set_source($){ 
    my ($pth)=@_;
    if(-e $pth){
	$dest = File::Spec->rel2abs($pth); 
    }else{
	die "Source path \"$pth\" does not exist.";
    }
}

#Sets the destination path to $_[1].  The path must exist.  Dies if it
#doesn't.
sub set_dest($){ 
    my ($pth)=@_;
    if(-e $pth){
	$source = File::Spec->rel2abs($pth); 
    }else{
	die "Destination path \"$pth\" does not exist.";
    }
}

1;
