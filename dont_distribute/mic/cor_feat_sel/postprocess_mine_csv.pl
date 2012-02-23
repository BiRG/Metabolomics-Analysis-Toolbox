#!/usr/bin/perl
use strict;
use warnings;

if(@ARGV != 0){
    print STDERR "Usage: postprocess_mine_csv < mine_output.csv > input_for_cor_based_fs.csv\n".
	"Removes the header and replaces f_number with number\n".
	"\n".
	"Outputs the new csv to stdout.\n".
	"Assumes that the header is in the first line.\n";
    exit(-1);
}

while(<STDIN>){
    if($. != 1){
	chomp;	
	#Remove all fields after the third
	my @fields = split /,/;
	while(@fields > 3){ pop @fields; }
	#Remove the f prefix on field names
	$fields[0] =~ s/f_(\d+)/$1/;
	$fields[1] =~ s/f_(\d+)/$1/;
	#Sort the field names, making sure that class comes first if
	#it is present
	if($fields[1] eq 'c' or ($fields[0] ne 'c' && $fields[0] > $fields[1])){
	    my $tmp = $fields[1];
	    $fields[1] = $fields[0]; $fields[0]=$tmp;
	}
	print "$fields[0],$fields[1],$fields[2]\n";
    }else{
	#Don't print anything for the header line
    }
    
}
