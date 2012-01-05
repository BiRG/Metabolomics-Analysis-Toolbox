#!/usr/bin/perl
use strict;
use warnings;

#Usage: flatten_confusion.pl < splittest_output > output_with_flattened_matrices
#
#Will give an augmented version of the original file (useful when you
#need to know what context each flattened row appeared in.
#
#If you type: flatten_confusion.pl < orig | grep "^Flattened-rep " > foo
#
#then foo will contain just the flattened repetitions in a
#space-separated form suitable for reading into another program (like
#Mathematica or excel)
#
#Reads a session that includes some waffles_learn splittest command
#output.  Mainly just echoes the input to the output.  When a
#repetition includes a confusion table, writes a line of the form:
#
#Flattened-rep rep# frac-correct ct1 ct2 ct3 ...
#
#Where:
#
#  rep#         is the number splittest gives to the trial
#
#  frac-correct is the fraction correct reported by splittest
#
#  ctxx         is one entry from the confusion table when it is 
#               rewritten in row-major order


my $cur_rep;
my $inside_confusion_matrix = 0;
my @output_values=();
while(<>){
    print;
    chomp;
    if (m/^rep (\d+)\) (\+?\-?\d*\.?\d*)$/){
	#This line starts a new trial - if the previous trial did not
	#include a complete confusion matrix it is discarded
	$cur_rep = $1;
	$inside_confusion_matrix = 0;
	@output_values = ($cur_rep, $2);
    }elsif(defined($cur_rep)){
	#We are in the middle of a trial	
	if($inside_confusion_matrix){
	    #We are reading the data rows of a confusion matrix
	    if(m/(\d+ *)+$/){
		#Match the data columns a data row and add them to the
		#end of the output
		my $cols = $&;
		$cols =~ s/(^ +)|( +$)//;
		my @vals = split /\W+/,$cols;
		push @output_values, @vals;
	    }else{
		#Otherwise we are done reading the data from a
		#confusion matrix and done with the rep, print the
		#flattened rep
		$inside_confusion_matrix = 0;
		undef $cur_rep;
		print "Flattened-rep ",join(" ", @output_values), "\n";
		undef @output_values;
	    }
	}else{
	    #We have read the trial header but not the confusion matrix header
	    if(m/Confusion matrix for /i){
		#This is a confusion matrix - ignore this line but
		#start reading the data rows of the matrix
		$inside_confusion_matrix = 1;
	    }
	}
    }
}
