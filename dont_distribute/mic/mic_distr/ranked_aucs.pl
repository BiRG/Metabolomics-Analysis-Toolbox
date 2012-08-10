#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;

if(@ARGV != 1){
    print STDERR 
	"Usage: $0 status_output_file < output_of_allAUCs.pl > out.tsv",
	"Reads a file consisting of roc filenames and the AUC for that roc\n",
	"curve, tab-separated with one record per line.\n",
	"Writes a file consisting of tab-separated fields each record on its\n",
	"own line. A record starts with the filename sans its bin field.\n",
	"Then there are 4 bin-name, auc pairs. One each for distance\n",
	"correlation, spearman, pearson, and the best mic bin size.\n",
	"This is followed by the 16 pair-wise differences between these.\n",
	"AUCs. Finally, the last 8 entries are the same bin-name, auc pairs,\n",
	"but sorted by auc rather than bin-name.\n",
	"\n",
	"The best bin size is chosen breaking ties for the same AUC by\n",
	"giving preference to the smaller number of bins.\n",
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

    #Ensure that the entry exists. Each entry consists of 4 fields
    #for the 4 types of distance measure. AUC is always non-negative,
    #so can start it at 0 without affecting the maximum.
    unless(exists($best{$truncatedFilename})){
	$best{$truncatedFilename}=
	    [[".b001.roc.tsv",0],
	     [".b002.roc.tsv",0],
	     [".b003.roc.tsv",0],
	     [undef,0]];
    }

    #Find the sub-entry corresponding to the appropriate type of
    #distance measure
    my $curEntry = $best{$truncatedFilename};
    my $cur = $$curEntry[3];
    for my $i (0..2){
	$cur = $$curEntry[$i] if($curEntry->[$i]->[0] eq $endOfFilename);
    }

    #Update entry with the best calculated AUC
    if($$cur[1] < $auc){
	$$cur[0]=$endOfFilename;
	$$cur[1]=$auc;
    }elsif($$cur[1] == $auc && (!defined $$cur[0] || $endOfFilename lt $$cur[0] )){
	#Take care of ties among mic entries by choosing the one with 
	#fewer bins
	$$cur[0]=$endOfFilename;	
    }
    
    #Print status messages
    ++$numProcessed;
    if($numProcessed % 1000 == 0){
	print $status 
	    $pid," processed ",$numProcessed, " entries in ",
	    time-$startTime," seconds.\n";
    }
}

#Print output
for my $key (sort keys %best){
    print STDOUT $key;

    #Print the values for the different measures
    my $curEntry=$best{$key};
    foreach my $cur (@$curEntry){
	my $bin = $$cur[0];
	my $auc = $$cur[1];
	print STDOUT
	    "\t",$bin,"\t",$auc;
    }

    #Print the pairwise differences
    for my $cur1 (@$curEntry){
	my $auc1 = $$cur1[1];
	for my $cur2 (@$curEntry){
	    my $auc2 = $$cur2[1];
	    print STDOUT "\t",($auc1-$auc2);
	}
    }
    
    #Print the sorted bins and aucs
    my @sorted = sort {$$a[1] <=> $$b[1]} @$curEntry;
    for my $cur (@sorted){
	my $bin = $$cur[0];
	my $auc = $$cur[1];
	print STDOUT
	    "\t",$bin,"\t",$auc;	
    }

    #End the line
    print STDOUT "\n";
}

print $status 
    $pid," finished processing ",$numProcessed, " entries in ",
    time-$startTime," seconds.\n";
close $status;
