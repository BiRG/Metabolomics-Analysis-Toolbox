#!/usr/bin/perl
use strict;
use warnings;

if(@ARGV != 1){
    print STDERR "Usage: preprocess_mine_csv class_var_index\n".
	"Replaces the class names in the csv with f_number or c if they are\n".
	"the class variable.\n".
	"Outputs the new csv to stdout.\n".
	"Assumes that the header is in the first line.\n";
    exit(-1);
}

my $class_idx = $ARGV[0];
while(<STDIN>){
    if($. != 1){
	print;
    }else{
	chomp;
	my @fields = split /,/;
	for my $idx (0..$#fields){
	    if($idx > 0){ print ","; };
	    if($idx < $class_idx){
		print "f_$idx";
	    }elsif($idx > $class_idx){
		print "f_",$idx-1;
	    }else{
		print "c";
	    }
	}
	print "\n";
    }
    
}
