#!/usr/bin/perl
use strict;
use warnings;

#######################################################################

# Renames the test databases to use 3-digit names

#######################################################################

sub pad($){
    my ($val) = @_;
    sprintf "%02d",$val;
}

sub pad3($){
    my ($val) = @_;
    sprintf "%03d",$val;
}

sub do_rename($$$){
    my ($prefix,$num,$suffix)=@_;
    my $origname = $prefix.pad($num).$suffix;
    my $newname = $prefix.pad3($num).$suffix;
    if(-e $origname){
	system("git mv $origname $newname");
    }
}

for my $i (1..99){
    do_rename("data/equivalent_db_pair_",$i,".a.db");
    do_rename("data/equivalent_db_pair_",$i,".b.db");
    do_rename("data/non_equivalent_db_pair_",$i,".a.db");
    do_rename("data/non_equivalent_db_pair_",$i,".b.db");
    do_rename("data/invalid_db_",$i,".db");
    do_rename("data/valid_db_",$i,".db");
}

