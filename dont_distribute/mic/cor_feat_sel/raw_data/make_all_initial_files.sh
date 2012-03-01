#!/bin/bash

#Run this only in the raw_data directory - it contains the commands to
#convert the raw data into the data that will be used in the
#performance tests
echo "Converting golf"
./make_initial_files.sh golf/ golf -columnnames

echo "Converting GISETTE"
./make_initial_files.sh NIPS2003/GISETTE/ gisette -whitespace
