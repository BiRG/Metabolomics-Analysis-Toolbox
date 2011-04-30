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
    sprintf "%02d",$val;
}

use Test::More;
print `pwd`;
#Count the tests
my $numEquiv=0; 
my $numNonEquiv=0;
my $numInvalid=0;
my $numValid=0;
for my $i (1..99){
    my $str = pad($i);
    ++$numEquiv if(-e "equivalent_db_pair_${str}.a.db");
    ++$numEquiv if(-e "equivalent_db_pair_${str}.b.db");
    ++$numNonEquiv if( -e "non_equivalent_db_pair_${str}.a.db");
    ++$numNonEquiv if( -e "non_equivalent_db_pair_${str}.b.db");
    ++$numInvalid if( -e "invalid_db_${str}.db");
    ++$numValid if( -e "valid_db_${str}.db");
}

plan tests=>($numEquiv+$numNonEquiv+$numInvalid+$numValid);

#Executes a test asserting that the given file is valid (but only if the file exists)
sub isValidOrNonexistant($){
    my $fn = $_[0];
    if(-e $fn){
	my $resp=`../valid_db $fn`;
	is($resp,'Valid',"$fn detected as a valid db");
    }
}

#Executes a test asserting that the given file is invalid (but only if
#the file exists
sub isInvalidOrNonexistant($){
    my $fn = $_[0];
    if(-e $fn){
	my $resp=`../valid_db $fn`;
	is($resp,'Invalid',"$fn detected as an invalid db");
    }
}


TODO:{
    local $TODO = "Have not written yet valid_db testing code yet.";
for my $i (1..99){
    my $str = pad($i);
    isValidOrNonexistant("equivalent_db_pair_${str}.a.db");
    isValidOrNonexistant("equivalent_db_pair_${str}.b.db");
    isValidOrNonexistant("non_equivalent_db_pair_${str}.a.db");
    isValidOrNonexistant("non_equivalent_db_pair_${str}.b.db");
    isValidOrNonexistant("valid_db_${str}.db");
    isInvalidOrNonexistant("invalid_db_${str}.db");
}
}


