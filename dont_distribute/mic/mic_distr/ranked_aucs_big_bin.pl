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
	"correlation, spearman, pearson, and the competitive mic bin size.\n",
	"This is followed by the 16 pair-wise differences between these.\n",
	"AUCs. Finally, the last 8 entries are the same bin-name, auc pairs,\n",
	"but sorted by auc rather than bin-name.\n",
	"\n",
	"The best competitive bin size for mic is choosing the largest bin\n",
	"size that does not change its ranking with respect to the competing\n",
	"method that has an AUC lower or equal to the best AUC for any mic\n",
	"bin size. So, if an entry has scores: [1,0.55],[2,0.6],[3,1.0],\n",
	"[4,0.9],[5,0.8],[6,0.7],[7,0.6],[8,0.5]. The competitive mic size \n",
	"would be 6. The maximum is 4 (with an AUC of 0.9) but this is above\n",
	"the next highest score of 0.6 for method 2. So, we can up the mic \n",
	"to 6 without changing the ranking with respect to spearman's score,\n",
	"thus still \"winning\". That is why I call it a competitive score.\n",
	"If the highest MIC is the lowest score, then the competing score is\n",
	"taken to be 0.\n",
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
	     []];
    }

    #Find the sub-entry corresponding to the appropriate type of
    #distance measure
    my $curEntry = $best{$truncatedFilename};
    my $isMIC = 1; #True if cur is the MIC entry
    my $cur = $$curEntry[3];
    for my $i (0..2){
	if($curEntry->[$i]->[0] eq $endOfFilename){
	    $cur = $$curEntry[$i];
	    $isMIC = 0;
	}
    }

    #If not a MIC entry, update entry with the best calculated AUC, otherwise,
    #tack the 
    if($isMIC){
	push @$cur, [$endOfFilename,$auc];
    }else{
	if($$cur[1] < $auc){
	    $$cur[0]=$endOfFilename;
	    $$cur[1]=$auc;
	}
    }
    
    #Print status messages
    ++$numProcessed;
    if($numProcessed % 1000 == 0){
	print $status 
	    $pid," processed ",$numProcessed, " entries in ",
	    time-$startTime," seconds.\n";
    }
}
while(my ($key,$entry)=each(%best)){
    #Find best MIC
    my $bestMICAUC = $entry->[3]->[0]->[1];
    my $highestBin = $entry->[3]->[0]; #Bin with best mic auc
    for my $micScore (@{$$entry[3]}){
	if($$micScore[1] > $bestMICAUC){
	    $bestMICAUC = $$micScore[1];
	}
    }

    #Find competing score. Make it 0 if no lower scores
    my $competingScore = 0;
    for my $otherScore ($$entry[0],$$entry[1],$$entry[2]){
	if($$otherScore[1] <= $bestMICAUC){
	    $competingScore = $$otherScore[1];
	}
    }
    
    #Find highest bin number mic entry that has the same relationship
    #as bestMICAUC to the competing score. If competingScore ==
    #bestMICAUC then highestBin already has it, so don't do anything
    if($competingScore < $bestMICAUC){
	for my $curBin (@{$$entry[3]}){
	    if($$curBin[0] gt $$highestBin[0] &&
	       $$curBin[1] > $competingScore){
		$highestBin = $curBin;
	    }
	}
    }

    #Set the mic score entry to the highest number of bins with an
    #equally competitive score
    $$entry[3] = $highestBin;
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
