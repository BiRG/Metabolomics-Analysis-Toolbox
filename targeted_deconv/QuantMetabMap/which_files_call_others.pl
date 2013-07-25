#!/usr/bin/perl
use autodie;

# Usage:
# which_files_call_others.pl > file_list
#
# Lists all pairs of matlab files in this directory where the first
# calls the second. The pairs are tab-separated, so if there are three
# files f1.m, f2.m, and f3.m and f1 calls f2 and f3 and f3 calls f2,
# the result will be:
# f1.m\tf2.m
# f1.m\tf3.m
# f3.m\tf2.m

# Read matlab files in directory
my @files = glob("*.m");

# Change them to function names
my @funcs = @files;
@funcs = map { s/\.m$//; $_ } @funcs;

# For each file see which function names it contains
foreach my $file (@files){
    foreach my $func (@funcs){
	system("grep","-q", $func, $file);
	if ($?==0) { # If there was a match grep's return value is 0
	    my $funcfile = "${func}.m";
	    print "$file\t$funcfile\n" if ($file ne $funcfile);
	}
    }
}
