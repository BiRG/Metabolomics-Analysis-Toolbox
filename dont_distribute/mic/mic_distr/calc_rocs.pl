#!/usr/bin/perl
use strict;
use warnings;

if(@ARGV == 0){
    print STDERR
	"Usage: calc_rocs.pl null_distr.ser distr1.ser distr2.ser ...\n",
	"Calculate the roc.tsv files for each file in the list\n",
	"putting them in the same directory as the original file.\n",
	"Only calculates numbers of bins that are multiples of 5 above 20 ",
	"bins. Does not calculate prime numbered bins above 4\n"
	;
}

my $nullFN = shift;

while(@ARGV){
    my $curFN = shift;
    for my $nSamplesS ("005","006","007","008","009","010",
		       "012","014","019","030","060","100"){
	my $nSamples = $nSamplesS;
	$nSamples = $nSamples + 0;
	for my $nBinsS ("001"..$nSamplesS){
	    my $nBins = $nBinsS; $nBins = $nBins+0;
	    if($nBins > 20){ next if($nBins % 5 != 0); }
	    my $nBinsIsPrime = 1;
	    for my $num (2..$nBins-1){
		$nBinsIsPrime = 0 if($nBins % $num == 0);
	    }
	    next if($nBins > 4 && $nBinsIsPrime);
	    (my $rocFN = $curFN) =~ s/\.ser$//;
	    $rocFN = $rocFN.".s$nSamplesS.b$nBinsS.roc.tsv";
	    system("java -jar distr.jar roc $nullFN $curFN $nSamples $nBins ".
		   "> $rocFN");
	}
    }
}
