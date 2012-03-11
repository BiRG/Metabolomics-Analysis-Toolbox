#This script makes a smaller version of the NIPS2003 GISETTE data set
#with only the first 100 samples
#
#It should be run from the raw_data directory

mkdir -p SmallNIPS2003/GISETTE
for i in gisette_train.data gisette_train.labels ; do
    head -n 100 < NIPS2003/GISETTE/$i > SmallNIPS2003/GISETTE/$i
done

for i in gisette_valid.data gisette_valid.labels ; do
    cp NIPS2003/GISETTE/$i SmallNIPS2003/GISETTE/$i
done
