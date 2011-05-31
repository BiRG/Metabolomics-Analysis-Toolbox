#!/usr/bin/perl
use strict;
use warnings;

#######################################################################

# Exercises hough_sample_params

#######################################################################

use Test::More tests => 10;

#################
#
# Global variables
#
################
undef $/; #Slurp mode for all files

#TAP test assertion that the given command line fails and that the error message
#output is the same as that recorded in the given file
#
#$error_condition is a string suitable for substitution in the string:
#"equivalent_db did exit(-1) when $error_condition"
sub command_line_error_message_is($$$){
    my ($command_line,$error_message_file,$error_condition)=@_;
    my $error_message = `$command_line 2>&1`;
    my $exitValue = $?;
    is($exitValue, 65280, "hough_sample_params did exit(-1) when $error_condition");
    
    open(my $fh,"<",$error_message_file) or die $!;
    my $expected_error_message = <$fh>;
    undef $fh;
    
    is($error_message, $expected_error_message, 
       "hough_sample_params  correct error when $error_condition");
}

##################
# 
# Check the error mesage and status when too few or too many arguments
#
##################

command_line_error_message_is(
    "../hough_sample_params 0.99 0.99 0.99",
    "data/hough_sample_params_usage_message_wrong_num_args.txt",
    "there are too many arguments.");

command_line_error_message_is(
    "../hough_sample_params",
    "data/hough_sample_params_usage_message_wrong_num_args.txt",
    "there are too few arguments.");


##################
# 
# Check the error mesage and status when frac_var too large or small
#
##################

command_line_error_message_is(
    "../hough_sample_params -0.9",
    "data/hough_sample_params_usage_message_-0.9_frac_var.txt",
    "fraction of variance is too small.");

command_line_error_message_is(
    "../hough_sample_params 1.1",
    "data/hough_sample_params_usage_message_1.1_frac_var.txt",
    "fraction of variance is too large.");


#########
#
# 5 peak 3 sample 1 parameter
#
#########

my $returnValue=system('../hough_sample_params 0.99 < data/data_basic_005pk_003smp_01param.initial.db > outputs/hough_sample_params-data_basic_005pk_003smp_01param.initial.actual.db');

is($returnValue,0,"hough_sample_params executed successfully on 5pk 3samp 1param");


TODO: {
    local $TODO="hough_sample_params is not finished";

    my $equivalenceResult=`../equivalent_db data/data_basic_005pk_003smp_01param.after_hough_sample_params.db outputs/hough_sample_params-data_basic_005pk_003smp_01param.initial.actual.db`;

    is($equivalenceResult,"Databases ARE equivalent","hough_sample_params produced expected db on 5pk 3samp 1param");

}





