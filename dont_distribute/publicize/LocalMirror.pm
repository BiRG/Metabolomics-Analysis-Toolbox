#!/usr/bin/perl
#Package boilerplate
package LocalMirror; # start new namespace; scope extends to EOF
use Exporter;        # load Exporter module
@ISA=qw(Exporter);   # Inherit from Exporter
@EXPORT=qw(dont_delete is_in_dont_delete mirror mirror2 
           delete_dest set_source set_dest get_source get_dest); 

#Real package stuff begins here
use strict;
use warnings;
use File::Path;
use File::Spec;
use File::Copy;
use File::Find;
use Data::Dumper;

#Path to source root
my $source;

#Path to destination root
my $dest;

#List of regexps that won't be deleted
my @preserve=();

#Add $_[0] to the list of protected regexp in dest
sub dont_delete($){ push @preserve, qr/$_[0]/; }

#Return true if $_[0] matches an expression in @preserve
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
#Copy the file or directory from source/$_[0] to dest/$_[1]
sub mirror2($$){
    my $sname=File::Spec->catfile($source, $_[0]);
    my $dname=File::Spec->catfile($dest, $_[1]);
    if(! -e $sname){
	print STDERR "Warning: Source file $sname does not exist.  ",
	"Cannot copy.\n";
	return;
    }
    if(-e $dname){
	print STDERR "Warning: destination file $dname already exists.  ",
	"Overwriting.\n";
    }
    #Directory in which the destination file lives - we will ensure it
    #and its predecessors exist
    my ($dvolume,$ddir,$dfile)=File::Spec->splitpath($dname);

    #Ensure parent directory exists
    unless(-e $ddir){
	eval { mkpath($ddir) };
	if ( $@ ) {
	    print STDERR "Error: Can't mirror ${dname} because couldn't create ${ddir}: $@";
	    return;
	}
    }

    #Copy the source to the destination (only works on unix, but that
    #is all we care about right now).  File::Find along with
    #File::Copy could be used to implement this portably.
    if(system("cp","-r",$sname,$dname) != 0){
	die "Could not copy \"$sname\" to \"$dname\"";
    }
}

#Copy the file to the same location in the destination
#
#An alias for mirror2($_[0],$_[1]);
sub mirror($){
    mirror2 $_[0],$_[1];
}

#Delete all files in dest that were not previously specified as dont_delete
sub delete_dest(){
    #These are the actual paths that matched or had contents that
    #matched a regex in @preserve
    my $preserved_paths={$dest=>''};
    
    #Fill the list of preserved paths
    my $check_path = sub {
	my $name =$File::Find::name;
	if(is_in_dont_delete($name) || is_in_dont_delete($_)){
	    if(-d){
		#Add all contained files and directories
		File::Find::find(sub{
		    $$preserved_paths{$File::Find::name}='';},
				 $File::Find::name);
		#No need to look at subdirectories, since they are
		#already within
		$File::Find::prune = 1;
	    }else{
		#Preserve the file (or other object)
		$$preserved_paths{$name}='';
		
		#Preserve its parent directories
		my ($v,$dir_string,$fn)=File::Spec->splitpath($name);
		my @dirs = File::Spec->splitdir($dir_string);
		for my $lastDirIdx (0..$#dirs){
		    my $parent_string = 
			File::Spec->catdir(@dirs[0..$lastDirIdx]);
		    my $parent_path = 
			File::Spec->catpath($v,$parent_string,'');
		    $$preserved_paths{$parent_path}='';
		}
	    }
	}
    };
    File::Find::find($check_path, $dest);
    
    #Delete unprotected paths
    my $delete_unprotected = sub {
	unless(exists($$preserved_paths{$File::Find::name})){
	    if(-d){
		File::Path::remove_tree($File::Find::name);
		$File::Find::prune = 1;
	    }elsif(-f){
		unlink($File::Find::name);
	    }else{ #Not a file or a directory
		print STDERR "Warning: $File::Find::name is not a file or a ".
		    "directory and so cannot be deleted.  However it is not ".
		    "in the list of things not to delete with delete_dest.  ".
		    "Add the line dont_delete(\"$File::Find::name\"); to ".
		    "the mirror script before delete_dest to get rid of ".
		    "this warning.\n";
	    }
	}
    };
    File::Find::find($delete_unprotected, $dest);
}

#Sets the source path to $_[0].  The path must exist and be a
#directory.  Dies if it doesn't/isn't.
sub set_source($){ 
    my ($pth)=@_;
    if(-d $pth){
	$source = File::Spec->rel2abs($pth); 
    }else{
	die "Source path \"$pth\" is not a directory.";
    }
}

#Sets the destination path to $_[0].  The path must exist and be a
#directory.  Dies if it doesn't/isnt.
sub set_dest($){ 
    my ($pth)=@_;
    if(-d $pth){
	$dest = File::Spec->rel2abs($pth); 
    }else{
	die "Destination path \"$pth\" is not a directory.";
    }
}

#Return the current destination path
sub get_dest(){
    return $dest;
}	     

#Return the current source path
sub get_source(){
    return $source;
}

1;
