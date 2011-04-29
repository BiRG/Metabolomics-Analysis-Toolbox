#!/usr/bin/perl
use strict;
use warnings;

#######################################################################

# Exercises ../equivalent_db by comparing all the equivalent_db_pair
# and non_equivalent_db_pair databases

#######################################################################

sub pad($){
    my ($val) = @_;
    sprintf "%02d",$val;
}

use Test::More;
print `pwd`;
#Count the tests
my $numEquiv=0; 
my $numNonEquiv=0;
for my $i (1..99){
    my $str = pad($i);
    ++$numEquiv if(-e "equivalent_db_pair_${str}.a.db");
    ++$numNonEquiv if( -e "non_equivalent_db_pair_${str}.a.db");
}

plan tests=>($numEquiv+$numNonEquiv);

TODO:{
    local $TODO = "Have not written yet equivalence testing code yet.";
for my $i (1..99){
    my $str = pad($i);
    my $fn1 = "equivalent_db_pair_${str}.a.db";
    my $fn2 = "equivalent_db_pair_${str}.b.db";
    if(-e $fn1) {
	my $resp=`../equivalent_db $fn1 $fn2`;
	is($resp,"Databases ARE equivalent", 
	   "Equivalent db pair ${str} should be detected equivalent");
    }
    $fn1 = "non_".$fn1;
    $fn2 = "non_".$fn2;
    if(-e $fn1) {
	my $resp=`../equivalent_db $fn1 $fn2`;
	is($resp,"Databases ARE NOT equivalent", 
	   "Non-equivalent db pair ${str} should be detected non-equivalent");
    }
}
}


