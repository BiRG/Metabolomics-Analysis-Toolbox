#!/bin/bash

#Run this only in the raw_data directory - it contains the commands to
#convert the raw data into the data that will be used in the
#performance tests
echo "Converting golf"
./make_initial_files.sh golf/ golf "class_labels {-1,1}" -columnnames

echo "Converting GISETTE"
./make_initial_files.sh NIPS2003/GISETTE/ gisette "class_labels {-1,1}" -whitespace

echo "Making SmallNIPS2003 data"
./make_small_NIPS.sh

echo "Converting SmallNIPS2003/GISETTE"
./make_initial_files.sh SmallNIPS2003/GISETTE/ gisette "class_labels {-1,1}" -whitespace

