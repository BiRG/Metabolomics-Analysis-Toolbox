#!/usr/bin/perl
use strict;
use warnings;

if(@ARGV != 0){
    print STDERR "Usage: postprocess_mine_csv < mine_output.csv > input_for_cor_based_fs.csv\n".
	"Removes the header, replaces f_number with number, only outputs\n".
	"first three fields, adds lines x,x,1 for every pair of field\n".
	"values.\n".
	"\n".
	"Outputs the new csv to stdout.\n".
	"Assumes that the header is in the first line.\n";
    exit(-1);
}

my $maxField = 0;
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
	$maxField = $fields[1] if $maxField < $fields[1];
	print "$fields[0],$fields[1],$fields[2]\n";
    }else{
	#Don't print anything for the header line
    }
}

#Add extra lines for a field's correlation with itself.
for my $i (0..$maxField){
    print "$i,$i,1\n";
}
