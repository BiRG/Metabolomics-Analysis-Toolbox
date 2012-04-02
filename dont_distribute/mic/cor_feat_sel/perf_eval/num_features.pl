#!/usr/bin/perl
use strict;
use warnings;
if(@ARGV == 0){
    print STDERR "Usage: $0 filename1 filename2 ...\n";
    print STDERR "Prints the number of features in each filename given on the command line\n";
    exit -1;
}
for my $fn (@ARGV){
    my $numFeat = 0;
    open my $fh,"<",$fn;
    while(<$fh>){
	chomp;
	$numFeat = $numFeat + scalar(split /,/);
    }
    close $fh;
    print "$numFeat\t$fn\n";
}
