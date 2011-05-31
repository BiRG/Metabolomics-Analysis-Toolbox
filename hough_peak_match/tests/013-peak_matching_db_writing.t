#!/usr/bin/perl
use strict;
use warnings;

#######################################################################

# Exercises ../duplicate_peak_match_db (and, more importantly, the
# underlying library) by 1st trying to load all the
# equivalent_pair_*.db and non_equivalent_pair_*.db files and writing
# them to duplicate files (in output), and ensuring that the two files
# are equivalent.

#######################################################################

sub pad($){
    my ($val) = @_;
    sprintf "%03d",$val;
}

use Test::More;
#Count the tests
my @input_filenames;

#Add the input file to the list of input filenames if it exists
sub potentiallyAddInputFile($){
    my ($fn) = @_;
    if(-e $fn){
	push @input_filenames, $fn;
    }
}

for my $i (1..99){
    my $str = pad($i);
    potentiallyAddInputFile("data/equivalent_db_pair_${str}.a.db");
    potentiallyAddInputFile("data/equivalent_db_pair_${str}.b.db");
    potentiallyAddInputFile("data/non_equivalent_db_pair_${str}.a.db");
    potentiallyAddInputFile("data/non_equivalent_db_pair_${str}.b.db");
    potentiallyAddInputFile("data/valid_db_${str}.db");
}

plan tests=>scalar(@input_filenames);


TODO:{
    local $TODO="Have not written duplicate_peak_match_db yet";

for my $fn (@input_filenames){
#Commented code is used to slow down so I can find out where null
#pointer errors are being generated.
#    print "Will copy $fn\n";
#    my $foo = <STDIN>;
    my $dup_fn = $fn;
    $dup_fn =~ s/data/outputs/;
    $dup_fn =~ s/\.db$/.dup.db/;
    system("../duplicate_peak_match_db < $fn > $dup_fn");
    my $resp = `../equivalent_db $fn $dup_fn`;
    is($resp, "Databases ARE equivalent\n",
	"$fn is correctly copied to $dup_fn by duplicate_peak_match_db");
}

}


