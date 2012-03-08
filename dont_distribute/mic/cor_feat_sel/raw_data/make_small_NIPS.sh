#This script makes a smaller version of the NIPS2003 GISETTE data set
#with only the first 25 samples
#
#It should be run from the raw_data directory

mkdir -p SmallNIPS2003/GISETTE
for i in gisette_train.data gisette_train.labels gisette_valid.data gisette_valid.labels; do
    head -n 25 < NIPS2003/GISETTE/$i > SmallNIPS2003/GISETTE/$i
done
