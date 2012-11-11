#!/usr/bin/perl
use strict;
use warnings;

#
# Reads in a "normal_urine.txt" file and adds an extra trailing field
# to each line containing the HMDB file with the same name - assuming 
# you have a directory with HMDB peak list files named HMDB*.txt according to.
#
# Set the variable $peaklist_db to the location of your
# peaklist. Sorry for hard-coding things, but you shouldn't need to do
# any of this more than once. (And since I have the result in the repo
# with hand annotations for those ids I couldn't get automatically,
# you probably won't need to do it at all.)
#
# Usage (on my system - you'll have to modify the path to the input file):
#
# ./add_hmdb_to_urine_file.pl < ~/SW/MetAssimulo/MetAssimulo-1.2/Input/normal_urine.txt > output_with_HMDB_id_numbers
#
# 


my $peaklist_db="~/SW/Clean-HMDB-Peaklist/NMR_Peaklist";

while(<>){
    chomp;
    my $line = $_;
    if(m/NMR STANDARDS\tMEAN\tST DEV/){
	print "$line\tHMDB ID\n";
    }else{
	my ($name) = split /\t/;
	$name =~ tr/"//d;
	my $fn = `grep -li "($name)" ${peaklist_db}/HMDB*`;
	chomp($fn);
	if($fn =~ /\n/){
	    print STDERR "More than one match for compound $name\n"
	}

	my $hmdb_id;
	if($fn =~ /^$/){
	    print STDERR "No match for compound $name\n";
	    $hmdb_id = "No match found";
        }else{
	    # Grab the id from the filename
	    $fn =~ /(HMDB[0-9]{5})/;
	    $hmdb_id = $1;
	}
	print "$line\t$hmdb_id\n";
    }
}
