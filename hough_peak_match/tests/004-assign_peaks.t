#!/usr/bin/perl
use strict;
use warnings;

#######################################################################

# Exercises assign_peaks

#######################################################################

use Test::More tests => 4;

#########
#
# 5 peak 3 sample 1 parameter -- keep_original
#
#########

my $returnValue=system('../assign_peaks keep_original_groups .04 0.12 < data/data_basic_005pk_003smp_01param.after_simple_hough.db > outputs/assign_peaks-keep_original-data_basic_005pk_003smp_01param.after_simple_hough.actual.db');

is($returnValue,0,"assign_peaks keep_original executed successfully on 5pk 3samp 1param");


TODO: {
    local $TODO="assign_peaks is not finished";

    my $equivalenceResult=`../equivalent_db data/data_basic_005pk_003smp_01param.after_assign_peaks_keep_original.db  outputs/assign_peaks-keep_original-data_basic_005pk_003smp_01param.after_simple_hough.actual.db`;

    is($equivalenceResult,"Databases ARE equivalent","assign_peaks keep_original produced expected db on 5pk 3samp 1param");

}


#########
#
# 5 peak 3 sample 1 parameter -- keep_new
#
#########

$returnValue=system('../assign_peaks keep_new_groups .04 0.12 < data/data_basic_005pk_003smp_01param.after_simple_hough.db > outputs/assign_peaks-keep_new-data_basic_005pk_003smp_01param.after_simple_hough.actual.db');

is($returnValue,0,"assign_peaks keep_new executed successfully on 5pk 3samp 1param");


TODO: {
    local $TODO="assign_peaks is not finished";

    my $equivalenceResult=`../equivalent_db data/data_basic_005pk_003smp_01param.after_assign_peaks_keep_new.db  outputs/assign_peaks-keep_new-data_basic_005pk_003smp_01param.after_simple_hough.actual.db`;

    is($equivalenceResult,"Databases ARE equivalent","assign_peaks keep_new produced expected db on 5pk 3samp 1param");

}





