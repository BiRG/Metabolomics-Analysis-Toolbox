#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/..";
use Test::More tests => 1;
BEGIN { use_ok('LocalMirror'); }
