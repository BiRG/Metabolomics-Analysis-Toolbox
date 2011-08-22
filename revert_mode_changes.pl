#!/usr/bin/perl
##############
# Parse output of 'git show sha1blabla' to revert changes to executable mode
#
# usage: revert_mode_changes.pl git_show_output
#
# Must be run in the root directory of the repository
##############
use strict;
use warnings;
my @last3=();
while(<>){
    chomp;
    push @last3,$_;
    if(@last3 > 3){
	shift @last3;
    }
    if(@last3 == 3){
	if($last3[2] eq 'new mode 100755'){
	    $last3[0] =~ m(a/(.*) b/);
	    my $file = $1;
	    if(open(my $fh, "<", $file)){
		my $perm = (stat $fh)[2] & 07777;
		chmod($perm & 0666, $fh); 
		close($fh);
	    }else{
		print STDERR "Skipping '$file' because $!\n";
	    }
	}
    }
}
