#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;

if(@ARGV != 1){
    print STDERR 
	"Usage: $0 status_output_file < output_of_allAUCs.pl > out.tsv",
	"Reads a file consisting of roc filenames and the AUC for that roc\n",
	"curve, tab-separated with one record per line.\n",
	"Writes a file consisting of tab-separated entries with the bin\n",
	"field of the filenames from the input removed and the best auc\n",
	"and the bin portion separated by tabs\n",
	"\n",
	"Note that this is a hack that depends on the ROC files having a \n",
	"specific filename format. It is designed so Mathematica can quickly\n",
	"stitch the two parts together to get the metadata back out of the\n",
	"filename."
	;
    exit(-1);
}


open(my $status, ">>", $ARGV[0]);
$status->autoflush;

my $startTime = time;
my $numProcessed = 0;
my $pid = $$;
my %best=();
while(<STDIN>){
    chomp;
    my ($filename, $auc) = split;
    (my $truncatedFilename=$filename) =~ s/(\.b\d\d\d.roc.tsv)//;
    my $endOfFilename = $1;
    if(exists($best{$truncatedFilename})){
	my $cur = $best{$truncatedFilename};
	if($$cur[1] < $auc){
	    $best{$truncatedFilename}=[$endOfFilename,$auc];
	}
    }else{
	$best{$truncatedFilename}=[$endOfFilename,$auc];
    }
    ++$numProcessed;
    if($numProcessed % 1000 == 0){
	print $status 
	    $pid," processed ",$numProcessed, " entries in ",
	    time-$startTime," seconds.\n";
    }
}

for my $key (sort keys %best){
    my $cur=$best{$key};
    my $bin = $$cur[0];
    my $auc = $$cur[1];
    print STDOUT
	$key,"\t",$bin,"\t",$auc,"\n";
}

print $status 
    $pid," finished processing ",$numProcessed, " entries in ",
    time-$startTime," seconds.\n";
close $status;
