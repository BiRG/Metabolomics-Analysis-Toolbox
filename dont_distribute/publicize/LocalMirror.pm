#!/usr/bin/perl
#Package boilerplate
package LocalMirror; # start new namespace; scope extends to EOF
use Exporter;        # load Exporter module
@ISA=qw(Exporter);   # Inherit from Exporter
@EXPORT=qw(dont_delete is_in_dont_delete mirror mirror2 
           delete_dest set_source set_dest); 

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
	for my $pres_regex (@preserve){
	    if($name =~ m/$pres_regex/ || $_ =~ m/$pres_regex/){
		if(-d){
		    #Add all contained files and directories
		    File::Find::find(sub{
#			print STDERR "Preserving $File::Find::name because of dir $name\n";
			$$preserved_paths{$File::Find::name}='';},
				     $File::Find::name);
		    #No need to look at subdirectories, since they are
		    #already within
		    $File::Find::prune = 1;
		}elsif(-f){
		    #Preserve the file
		    $$preserved_paths{$name}='';

		    #Preserve the file's parent directories
		    my ($v,$dir_string,$fn)=File::Spec->splitpath($name);
		    my @dirs = File::Spec->splitdir($dir_string);
		    for my $lastDirIdx (0..$#dirs){
			my $parent_string = 
			    File::Spec->catdir(@dirs[0..$lastDirIdx]);
			my $parent_path = 
			    File::Spec->catpath($v,$parent_string,'');
#			print STDERR "Preserving '$parent_path' because of file $name\n";
			$$preserved_paths{$parent_path}='';
		    }
		}
		last;
	    }
	}
    };
    File::Find::find($check_path, $dest);
    print Dumper($preserved_paths);
    
    #Delete unprotected paths
    my $delete_unprotected = sub {
	unless(exists($$preserved_paths{$File::Find::name})){
	    if(-d){
		File::Path::remove_tree($File::Find::name);
		$File::Find::prune = 1;
	    }elsif(-f){
		unlink($File::Find::name);
	    }
	}
    };
    File::Find::find($delete_unprotected, $dest);
}

#Sets the source path to $_[0].  The path must exist.  Dies if it
#doesn't.
sub set_source($){ 
    my ($pth)=@_;
    if(-e $pth){
	$source = File::Spec->rel2abs($pth); 
    }else{
	die "Source path \"$pth\" does not exist.";
    }
}

#Sets the destination path to $_[0].  The path must exist.  Dies if it
#doesn't.
sub set_dest($){ 
    my ($pth)=@_;
    if(-e $pth){
	$dest = File::Spec->rel2abs($pth); 
    }else{
	die "Destination path \"$pth\" does not exist.";
    }
}

1;
