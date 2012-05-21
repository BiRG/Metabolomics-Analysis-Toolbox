#!/usr/bin/perl
use strict;
use warnings;

if(@ARGV != 1){
    print STDERR 
	"Usage: $0 status_output_file < list_of_input_roc_files > out.tsv",
	"Calculate AUC for each filename (assumed to contain point pairs on\n",
	"an ROC curve) that comes in on stdin and print the filename, a tab,\n",
	"the AUC and a newline to stdout. AUC is calculated using the \n",
	"trapezoidal rule.\n",
	"\n",
	"Filenames are separated by newlines on stdin\n",
	"\n",
	"Status messages are appended to status_output_file\n"
	;
    exit(-1);
}

open(my $status, ">>", $ARGV[0]);

my $startTime = time;
my $numProcessed = 0;
my $pid = $$;
while(<STDIN>){
    chomp;
    my $filename = $_;
    open(my $roc, "<", $filename);
    my $prevPoint = undef;
    my $total = 0;
    while(<$roc>){
	chomp;
	my @curPoint = split; 
	if($prevPoint){
	    my $width = abs($$prevPoint[0]-$curPoint[0]);
	    my $height = ($$prevPoint[1]+$curPoint[1])/2;
	    $total += $width * $height;
	}
	$prevPoint = \@curPoint;
    }
    print STDOUT $filename,"\t",$total,"\n";
    ++$numProcessed;
    if($numProcessed % 100 == 0){
	print $status 
	    $pid,"processed ",$numProcessed, " files in ",
	    time-$startTime," seconds.\n";
    }
}
