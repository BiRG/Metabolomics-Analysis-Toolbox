#!/usr/bin/perl
use strict;
use warnings;
use File::Temp;

#Print the usage to stderr follwed by the given message and exit
sub usage($){
    my $msg=shift;
    print STDERR
	"Usage: $0 raw_train.arff raw_test.arff features1 features2 ...\n",
	"For each file in the list features*, prints lines to stdout\n",
	"giving the performance of a classifier trained on raw_train\n",
	"(with only the file's features) on raw_test (with those same \n",
	"features. Labels are assumed to be in attribute 0.\n",
	"\n",
	"The order of the fields is: feature_filename,algorithm,\n",
	"num_features_selected,list_of_features_selected,\n",
	"autotune_parameters,confusion_matrix_entry_1,\n",
	"confusion_matrix_entry_2...\n",
	"\n",
	"The first line will be a header describing the fields.",
	"\n",
	"$msg\n";
    exit -1;
}

if(@ARGV < 2){
    usage("Too few arguments.");
}

my $raw_train_file = shift;
my $raw_test_file = shift;
my $have_printed_header = 0; #To ensure that only print header once
for my $feature_file_index (0..$#ARGV){
    my $feature_file = $ARGV[$feature_file_index];
    print STDERR 
	"Working on $feature_file (",$feature_file_index+1,
	" of ",scalar(@ARGV),"\n";

    #Read in and count the selected features 
    my $numFeatures = `./num_features $feature_file`;
    $numFeatures =~ s/(\d+)\D.*/$1/; #Cut off everything after digits end
    $numFeatures = $numFeatures + 0; #Force to number
    my $featuresSelected = `cat $feature_file`;
    chomp $featuresSelected;

    print STDERR "Creating training and test sets\n";

    #Create temporary input files with only the selected features
    my ($reduced_test_fh, $reduced_test_file) = 
	tempfile("rltestXXXXXX",SUFFIX=>".arff");
    system("waffles_transform keeponlycolumns $raw_test_file $featuresSelected > $reduced_test_file");
    my ($reduced_train_fh, $reduced_train_file) = 
	tempfile("rltrainXXXXXX",SUFFIX=>".arff");
    system("waffles_transform keeponlycolumns $raw_train_file $featuresSelected > $reduced_train_file");

    my $seedval=237960763708426;
    for my $algo ("knn","decisiontree","naivebayes"){
	print STDERR "Autotuning $algo\n";
	my $autotune_output = `waffles_learn autotune $reduced_train_file -labels 0 $algo`;
	chomp $autotune_output;
	print STDERR "Training $algo\n";
	my ($model_fh, $model_file) = tempfile("rlmodel${algo}XXXXXX");
	system("waffles_learn train -seed $seedval $reduced_train_file -labels 0 $autotune_output > $model_file");
	print STDERR "Testing $algo\n";
	my $test_out=`waffles_learn test -seed $seedval -confusioncsv $model_file $reduced_test_file -labels 0`;
	my ($accuracy,$confusion_head,$confusion_data)=split /\n/,$test_out;

	unless($have_printed_header){
	    $have_printed_header=1;
	    print qq("Feature File","Machine Learning Algorithm","Number of features selected","Features selected","Autotune parameters",$confusion_head);
	}
	print qq("$feature_file","$algo",$numFeatures,"$featuresSelected","$autotune_output",$confusion_data\n);
	
    }
}
    
