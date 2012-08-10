Here is all the data files (or placeholders for holding the data) that
I use in the performance analysis.

To use, first go to the NIPS2003 directory and download the missing
files (see the readme there). Then, come back to the raw_data directory and run
make_all_initial_files.sh.

This will populate ../processed_data

Golf is the golf dataset from Mark Hall's dissertation. (Used for testing)

Credit-a is the weka version of the Austrailian Credit Approval UCI
dataset (since it has the categorical attributes marked as such).  The
preprocessing imputes missing values according to majority class or
mean and then turns categorical variables into sets of indicator
values.

SmallNIPS2003 is a version of NIPS2003 constructed by script in which
only the first 100 samples were retained in the training set to allow
MIC to finish in a reasonable amount of time. (With the full 3000
samples MIC does 1 variable pair every about 2 seconds ... resulting
in approximately 5000^2 seconds, which is too long).  The validation
set was left alone.



