#!/usr/bin/perl
use strict;
use warnings;

#######################################################################

# Exercises hough_sample_params

#######################################################################

use Test::More tests => 2;

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





