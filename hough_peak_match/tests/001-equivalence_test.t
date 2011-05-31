#!/usr/bin/perl
use strict;
use warnings;

#######################################################################

# Exercises ../equivalent_db by comparing all the equivalent_db_pair
# and non_equivalent_db_pair databases

#######################################################################

sub pad($){
    my ($val) = @_;
    sprintf "%03d",$val;
}

use Test::More;
#Count the tests
my $numEquiv=0; 
my $numNonEquiv=0;
for my $i (1..99){
    my $str = pad($i);
    ++$numEquiv if(-e "data/equivalent_db_pair_${str}.a.db");
    ++$numNonEquiv if( -e "data/non_equivalent_db_pair_${str}.a.db");
}

plan tests=>2*($numEquiv+$numNonEquiv);

for my $i (1..99){
    my $str = pad($i);
    my $fn1 = "data/equivalent_db_pair_${str}.a.db";
    my $fn2 = "data/equivalent_db_pair_${str}.b.db";
    if(-e $fn1) {
	my $resp=`../equivalent_db $fn1 $fn2`;
	is($resp,"Databases ARE equivalent\n", 
	   "Equivalent db pair ${str} should be detected equivalent");
	$resp=`../equivalent_db $fn2 $fn1`;
	is($resp,"Databases ARE equivalent\n", 
	   "Equivalent db pair ${str} should be equivalent when reversed");
    }
    $fn1 = "data/non_equivalent_db_pair_${str}.a.db";
    $fn2 = "data/non_equivalent_db_pair_${str}.b.db";
    if(-e $fn1) {
	my $resp=`../equivalent_db $fn1 $fn2`;
	is($resp,"Databases ARE NOT equivalent\n", 
	   "Non-equivalent db pair ${str} should be detected non-equivalent");
	$resp=`../equivalent_db $fn2 $fn1`;
	is($resp,"Databases ARE NOT equivalent\n", 
	   "Non-equivalent db pair ${str} should be non-equivalent when reversed");
    }
}



