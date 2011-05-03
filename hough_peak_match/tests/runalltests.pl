#!/usr/bin/perl
use Test::Harness;
if(@ARGV==1){
    $verbose = 1
}else{
    $verbose = 0
}
$h=TAP::Harness->new({verbosity=>$verbose}); 
$h->runtests(glob("*.t"));
