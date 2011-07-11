#!/usr/bin/perl
use strict;
use warnings;

#######################################################################

# Exercises remove_sample_params_from by reading source databases and
# writing them after the sample_params have been removed.  The written
# results are compared to expected results

#######################################################################

sub pad($){
    my ($val) = @_;
    sprintf "%03d",$val;
}

use Test::More;
#Count the tests
my @input_filenames = glob "data/remove_sample_params_???.input.db";

plan tests=>scalar(@input_filenames);


for my $fn (@input_filenames){
    my $actual_fn = $fn;
    $actual_fn =~ s/data/outputs/;
    $actual_fn =~ s/\.input\.db$/.actual.db/;
    system("../duplicate_peak_match_db --remove-sample-params < $fn > $actual_fn");
    my $expected_fn = $fn;
    $expected_fn =~ s/\.input\.db$/.expected.db/;
    my $resp = `../equivalent_db $expected_fn $actual_fn`;
    is($resp, "Databases ARE equivalent\n",
	"$fn has sample_params correctly removed by duplicate_peak_match_db (output is in $actual_fn)");
}



