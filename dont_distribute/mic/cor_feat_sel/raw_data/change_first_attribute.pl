#!/usr/bin/perl
use strict;
use warnings;

if(@ARGV != 1){
    print STDERR
	"Usage: $0 new_specification < in.arff > out.arff\n",
	"Replaces the first attribute specification in in.arff with the text\n",
	"new_specification.  So, to make the first variable a nominal,\n",
	"if it had values -1 and 1, you would write:\n",
	"$0 \"my_new_name {-1,1}\" < in.arff > out.arff\n",
	"\n",
	"Note: this may not work if there are any funky characters in the \n",
	"attribute name or current list of values. The code is a quick hack,\n",
	"beware.\n"
    exit(-1);
}

my $new_spec = shift;
my $seen_attribute = 0;
while(<STDIN>){
    if($seen_attribute){
	print $_;
    }else{
	chomp;
	if(m/\@attribute/){
	    $seen_attribute = 1;
	    print "$1 $new_spec\n";
	}else{
	    print "$_\n";
	}
    }  
}
