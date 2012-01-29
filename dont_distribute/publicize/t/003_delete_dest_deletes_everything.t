#!/usr/bin/perl
use strict;
use warnings;
use File::Temp qw( tempfile tempdir );
use File::Spec;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More tests => 2;
BEGIN { use_ok('LocalMirror'); }

my $src_dir = File::Temp->newdir();
my $dest_dir = File::Temp->newdir();



