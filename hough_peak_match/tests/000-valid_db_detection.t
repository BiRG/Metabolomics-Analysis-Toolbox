#!/usr/bin/perl
use strict;
use warnings;

#######################################################################

# Exercises ../valid_db (and, more importantly, the underlying
# library) by 1st trying to load all the equivalent_pair_*.db and
# non_equivalent_pair_*.db files, and ensuring that they categorize as
# valid.  Then, tries to load all the invalid_db_*.db files, ensuring
# that they categorize as invalid.

#######################################################################

sub pad($){
    my ($val) = @_;
    sprintf "%03d",$val;
}

use Test::More;
#Count the tests
my $numEquiv=0; 
my $numNonEquiv=0;
my $numInvalid=0;
my $numValid=0;
for my $i (1..99){
    my $str = pad($i);
    ++$numEquiv if(-e "data/equivalent_db_pair_${str}.a.db");
    ++$numEquiv if(-e "data/equivalent_db_pair_${str}.b.db");
    ++$numNonEquiv if( -e "data/non_equivalent_db_pair_${str}.a.db");
    ++$numNonEquiv if( -e "data/non_equivalent_db_pair_${str}.b.db");
    ++$numInvalid if( -e "data/invalid_db_${str}.db");
    ++$numValid if( -e "data/valid_db_${str}.db");
}

plan tests=>($numEquiv+$numNonEquiv+$numInvalid+$numValid);

#Executes a test asserting that the given file is valid (but only if the file exists)
sub isValidOrNonexistant($){
    my $fn = $_[0];
    if(-e $fn){
	my $resp=`../valid_db $fn`;
	is($resp,"Valid\n","$fn detected as a valid db");
    }
}

#Executes a test asserting that the given file is invalid (but only if
#the file exists
sub isInvalidOrNonexistant($){
    my $fn = $_[0];
    if(-e $fn){
	my $resp=`../valid_db $fn`;
	is($resp,"Invalid\n","$fn detected as an invalid db");
    }
}


for my $i (1..99){
    my $str = pad($i);
    isValidOrNonexistant("data/equivalent_db_pair_${str}.a.db");
    isValidOrNonexistant("data/equivalent_db_pair_${str}.b.db");
    isValidOrNonexistant("data/non_equivalent_db_pair_${str}.a.db");
    isValidOrNonexistant("data/non_equivalent_db_pair_${str}.b.db");
    isValidOrNonexistant("data/valid_db_${str}.db");
    isInvalidOrNonexistant("data/invalid_db_${str}.db");
}



