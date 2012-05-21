#!/usr/bin/perl
use strict;
use warnings;
# Create identical spectra that will display significant PCA
# separation when the reference spectrum is generated only from the
# non-dosed spectra. This is a counter-example to using the control
# animals to generate a reference spectrum.

my $numTimePoints = 4;
my $numAnimals = 24;
my $numControl = 6;
my $binWidth = 0.02;
my $minBin = 2;
my $maxBin = 10;
my $numBins = ($maxBin-$minBin)/$binWidth;
my $numTreatment = $numAnimals-$numControl;
my $numSamples = $numTimePoints*$numAnimals;

print 
    "Collection ID\t-200\n",
    "Type\tSpectraCollection\n",
    "Processing log\tGenerated spectra\n";

print "Base sample ID";
for my $id (1..$numSamples){ print "\t$id"; };
print "\n";

print "Time";
for my $time (0..$numTimePoints-1){
    print "\t$time" for (1..$numAnimals);
}
print "\n";

print "Dose Received";
print "\t0 mg/kg" for (1..$numAnimals);
for my $time (1..$numTimePoints-1){
    print "\t0 mg/kg" for (1..$numControl);
    print "\t1 mg/kg" for (1..$numTreatment);
}
print "\n";

print "Group";
for my $time (0..$numTimePoints-1){
    print "\tControl" for (1..$numControl);
    print "\tTreatment" for (1..$numTreatment);
}
print "\n";

print "X";
print "\tY$_" for (0..$numSamples-1);
print "\n";

for my $binNum (1..$numBins){
    my $x = $minBin+($binNum-1) * $binWidth;
    print "$x";
    for my $time (0..$numTimePoints-1){
	my $base = 1+sin($time*2*(3.1415926)/$numTimePoints);
	for (1..$numAnimals){
	    my $y = $base + rand()/3;
	    print "\t$y";
	}
    }
    print "\n";
}
