#!/usr/bin/perl
##############
# Parse output of 'git show sha1_commit_hash_here' to revert changes to
# executable mode made in the commit specified by the hash
#
# usage: revert_mode_changes.pl git_show_output
#
# Must be run in the root directory of the repository
##############
use strict;
use warnings;
my @last3=(); #Holds the last 3 lines from the git show file
while(<>){
    chomp;
    push @last3,$_;
    if(@last3 > 3){
	shift @last3;
    }
    #If we've read at least 3 lines
    if(@last3 == 3){
	my $make_executable = 0;
	my $make_non_executable = 0;
	if($last3[2] eq 'new mode 100755'){
	    #Remember to change a newly-executable to non-executable
	    $make_non_executable = 1;
	}elsif ($last3[2] eq 'new mode 100644'){
	    #Change a newly-non-executable to executable
	    $make_executable = 1;
	}
	
	#If need to change the executable bit
	if($make_executable || $make_non_executable){
	    #Extract the filename
	    $last3[0] =~ m(a/(.*) b/);
	    my $file = $1;


	    #Open the file, change it and close it
	    if(open(my $fh, "<", $file)){
		my $perm = (stat $fh)[2] & 07777;
		
		if($make_executable){
		    print STDERR "Making $file executable\n";
		    chmod($perm | 0111, $fh);
		}else{
		    print STDERR "Making $file non-executable\n";
		    chmod($perm & 0666, $fh); 
		}

		close($fh);
	    }else{
		#Could not open the file
		print STDERR "Skipping '$file' because $!\n";
	    }
	}
    }
}
