#!/usr/bin/perl
use strict;
use warnings;

#######################
#
# Test basic functionality of valid_db executable (its ability to
# distinguish valid and invalid databases is checked in
# valid_db_detection.t)
#
######################

use Test::More tests => 6;

#################
#
# Global variables
#
################
my ($pid, $error_message, $expected_error_message, $fh, $exitValue);
undef $/; #Slurp mode for all files

##################
# 
# Check the error mesage and status when too few or too many arguments
#
##################

# Too few arguments:

$error_message = `../valid_db 2>&1`;
$exitValue = $?;
is($exitValue, 65280, "valid_db did exit(-1) when too few args");

open($fh,"<",'data/valid_db_usage_message_wrong_num_args.txt');
$expected_error_message = <$fh>;
undef $fh;

is($error_message, $expected_error_message, "valid_db correct error when too few arguments");



# Too many arguments:

$error_message = `../valid_db non_existant_file_yes another_arg 2>&1`;
$exitValue = $?;
is($exitValue, 65280, "valid_db did exit(-1) when too many args");

open($fh,"<",'data/valid_db_usage_message_wrong_num_args.txt');
$expected_error_message = <$fh>;
undef $fh;

is($error_message, $expected_error_message, "valid_db correct error when too few arguments");


##################
# 
# Check the error mesage and status when opening non-existant file
#
##################

$error_message = `../valid_db non_existant_file_yes 2>&1`;
$exitValue = $?;
is($exitValue, 65280, "valid_db did exit(-1) when opening non-existant file");

open($fh,"<",'data/valid_db_usage_message_non_existant_file.txt');
$expected_error_message = <$fh>;
undef $fh;

is($error_message, $expected_error_message, "valid_db correct error when opening non-existant file");
