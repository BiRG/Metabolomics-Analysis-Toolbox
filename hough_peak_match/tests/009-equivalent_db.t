#!/usr/bin/perl
use strict;
use warnings;

#######################
#
# Test basic functionality of equivalent_db executable (its ability to
# distinguish valid and invalid databases is checked in
# equivalent_db_detection.t)
#
######################

use Test::More tests => 12;

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
    is($exitValue, 65280, "equivalent_db did exit(-1) when $error_condition");
    
    open(my $fh,"<",$error_message_file) or die $!;
    my $expected_error_message = <$fh>;
    undef $fh;
    
    is($error_message, $expected_error_message, 
       "equivalent_db correct error when $error_condition");
}

##################
# 
# Check the error mesage and status when too few or too many arguments
#
##################

command_line_error_message_is(
    "../equivalent_db data/valid_db_001.db",
    "data/equivalent_db_usage_message_wrong_num_args.txt",
    "there are too few arguments");

command_line_error_message_is(
    "../equivalent_db data/valid_db_001.db data/valid_db_001.db ".
    "data/valid_db_001.db",
    "data/equivalent_db_usage_message_wrong_num_args.txt",
    "there are too many arguments");


##################
# 
# Check the error mesage and status when opening non-existant file
#
##################

command_line_error_message_is(
    "../equivalent_db non_existent_file_yes non_existent_file_yes",
    "data/equivalent_db_usage_message_non_existant_first_file.txt",
    "the first file doesn't exist");

command_line_error_message_is(
    "../equivalent_db data/valid_db_001.db non_existent_file_yes",
    "data/equivalent_db_usage_message_non_existant_second_file.txt",
    "the second file doesn't exist");

##################
# 
# Check the error mesage and status when opening invalid file
#
##################

command_line_error_message_is(
    "../equivalent_db data/invalid_db_001.db non_existent_file_yes",
    "data/equivalent_db_usage_message_invalid_first_file.txt",
    "the first file is an invalid database");

command_line_error_message_is(
    "../equivalent_db data/valid_db_001.db data/invalid_db_001.db",
    "data/equivalent_db_usage_message_invalid_second_file.txt",
    "the second file is an invalid database");


