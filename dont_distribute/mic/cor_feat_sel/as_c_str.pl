#!/usr/bin/perl
use strict;
use warnings;

#Takes stdin (or a file) and performs a rough and ready translation into code ready to be included into a c program.

while(<>){
    s/\\/\\\\/g;
    s/\x0a/\\n/g;
    s/\x0d/\\r/g;
    s/\x08/\\b/g;
    s/\x0c/\\f/g;
    s/\x07/\\a/g;
    s/\x0b/\\v/g;
    s/\?/\\?/g;
    s/\x09/\\t/g;
    s/"/\\"/g;
    s/'/\\'/g;
    $_="\"$_\"";
    print "$_\n";
}
