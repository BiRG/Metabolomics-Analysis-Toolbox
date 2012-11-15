#!/usr/bin/perl
use strict;
use warnings;

# Reads in a signal map (format: a1,a2;b1,b2 - where each variable
# stands for a number and my example has 2 bins) from stdin and writes
# out a quick and dirty metabmap on stdout. The metadata is almost completely made up and the IDs are also made up - so the resulting metab
#
# Usage: signal_regions_to_dirty_bin_map.pl metabolite_name metabolite_hmdb_no < regions_file > metabmap_file
#
# Example:
#
# signal_regions_to_dirty_bin_map.pl Tyrosine 158 < 158.regions > 158.csv

if(@ARGV != 2){
    print STDERR "Usage: $0 metabolite_name metabolite_hmdb_no < regions_file > metabmap_file\n";
    exit(-1);
}

my($metab_name, $metab_hmdb) = @ARGV;

my $line = <STDIN>;
chomp $line;
my @bins = split(/;/,$line);
print qq{"Bin ID","Deleted","Compound ID","Compound Name","Known Compound","Bin (Lt)","Bin (Rt)","Multiplicity","Peaks to Select","J (Hz)","Nucleus Assignment","HMDB ID","Sample-types that may contain compound","Chenomx","Literature","NMR Isotope","Notes"\n};
my $id = 1000;
for my $bin (@bins){
    print qq{$id,"",$id,"$metab_name","X",$bin,"s",1,"","",$metab_hmdb,"urine","","None","1H","Quick and dirty entry from a signal map - most metadata is wrong"\n};
    ++$id;
}
