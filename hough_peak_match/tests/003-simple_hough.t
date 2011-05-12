#!/usr/bin/perl
use strict;
use warnings;

#######################################################################

# Exercises simple_hough

#######################################################################

use Test::More tests => 2;

#########
#
# 5 peak 3 sample 1 parameter
#
#########

my $returnValue=system('../simple_hough 10000 100 2 3 < data/data_basic_005pk_003smp_01param.after_hough_sample_params.db > outputs/simple_hough-data_basic_005pk_003smp_01param.after_hough_sample_params.actual.db');

is($returnValue,0,"simple_hough executed successfully on 5pk 3samp 1param");


TODO: {
    local $TODO="simple_hough is not finished";

    my $equivalenceResult=`../equivalent_db data/data_basic_005pk_003smp_01param.after_simple_hough.db outputs/simple_hough-data_basic_005pk_003smp_01param.after_hough_sample_params.actual.db`;

    is($equivalenceResult,"Databases ARE equivalent","simple_hough produced expected db on 5pk 3samp 1param");

}





