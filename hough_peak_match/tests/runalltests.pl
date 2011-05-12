#!/usr/bin/perl
use Test::Harness;
if(@ARGV==1){
    $verbose = 1
}else{
    $verbose = 0
}
sub howToExec($$){
    my ( $harness, $test_file ) = @_;
    # Run compiled tests directly
    return [ $test_file ] if $test_file =~ /compiled[.]t$/;
    # Let Perl tests run through the default process.
    return undef if $test_file =~ /[.]t$/;
}


$h=TAP::Harness->new({verbosity=>$verbose, exec=>\&howToExec}); 
$h->runtests(glob("./*.t"));
