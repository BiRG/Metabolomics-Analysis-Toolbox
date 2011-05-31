#!/usr/bin/perl
use strict;
use warnings;

#######################################################################

# Exercises duplicate_peak_match_db

#######################################################################

use Test::More tests => 4;

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
    is($exitValue, 65280, "duplicate_peak_match_db did exit(-1) when $error_condition");
    
    open(my $fh,"<",$error_message_file) or die $!;
    my $expected_error_message = <$fh>;
    undef $fh;
    
    is($error_message, $expected_error_message, 
       "duplicate_peak_match_db correct error when $error_condition");
}

##################
# 
# Check the error mesage and status when too few or too many arguments
#
##################

command_line_error_message_is(
    "../duplicate_peak_match_db 0.99 < data/valid_db_001.db",
    "data/duplicate_peak_match_db_usage_message_wrong_num_args.txt",
    "there are too many arguments.");



##################
# 
# Check the error mesage and status when there's a bad input database
#
##################

command_line_error_message_is(
    "../duplicate_peak_match_db < data/invalid_db_001.db",
    "data/duplicate_peak_match_db_usage_message_invalid_input_db.txt",
    "input database is invalid.");



