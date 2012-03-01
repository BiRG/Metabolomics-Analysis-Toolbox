#!/bin/bash
if [ "$#" != 3 ]; then
    echo "Usage: $0 directory basefilename options"
    echo "directory must end with a slash. Files to be combined etc must be"
    echo "basefilename_valid.data basefilename_valid.labels"
    echo "and"
    echo "basefilename_train.data basefilename_train.labels"
    echo "and must reside in directory. Labels will become the first column."
    echo ""
    echo "options will be expanded and passed to waffles_transform import"
    echo "just pass an empty string if no options are needed"
    echo ""
    echo "The output files will be placed in ../processed_data/directory"
    echo ""
    echo "This script makes use of known temporary filenames in the /tmp"
    echo "directory.  Dont run 2 copies at once"
    exit
fi

tmpname = "/tmp/make_initial_files.sh.tmp"

if [ -e $tmpname ]; then
    echo "Error temporary file $tmpname already exists.  Please delete it."
    echo "Remember not to run two copies of this script at the same time."
    exit
fi

touch $tmpname


dir = $1
base = $2
opts = $3

destdir = "../processed_data/$dir"
if [ ! -e "$destdir" ]; then
    mkdir -p $destdir
fi

#Original files
valid_labels = "$dir$base_valid.labels"
valid_data = "$dir$base_valid.data"
train_labels = "$dir$base_train.labels"
train_data = "$dir$base_train.data"

#Temporary files
valid_labels_arff = "${tmpname}.$base_valid.labels"
valid_data_arff = "${tmpname}.$base_valid.data"
train_labels_arff = "${tmpname}.$base_train.labels"
train_data_arff = "${tmpname}.$base_train.data"

#Destination files
valid_arff = "${destdir}$base_valid.arff"
train_arff = "${destdir}$base_train.arff"
valid_csv = "${destdir}$base_valid.csv"
train_csv = "${destdir}$base_train.csv"


waffles_transform import $valid_labels $options > $valid_labels_arff
waffles_transform import $valid_data $options > $valid_data_arff
waffles_transform mergehoriz $valid_labels $valid_data > $valid_arff
waffles_transform export $valid_arff > $valid_csv

waffles_transform import $train_labels $options > $train_labels_arff
waffles_transform import $train_data $options > $train_data_arff
waffles_transform mergehoriz $train_labels $train_data > $train_arff
waffles_transform export $train_arff > $train_csv


#Remove temporary files
rm $tmpname
rm valid_labels_arff
rm valid_data_arff
rm train_labels_arff
rm train_data_arff
