This contains Java code that does best-first correlation-based feature
selection based on an initial input file of correlations.

---------
- JAR FILES
---------

Right now, there is an expectation that MINE.jar (in this directory)
will be the current version of Reshef's MINE software (available from
http://www.exploredata.net/)

It is ignored in the version control.

There is also a dependency on the
org.sureassert.uc.annotation-1.3.1.jar file for declarative test code
(I am using the SureAssert UC Eclipse plugin)

---------
- USE
--------


To use the correlation feature selection with mine values for original.csv
(which must have the features in the columns and the samples in the rows) do:

preprocess_mine_csv.pl zero_based_class_feature_index < original.csv > preprocessed.csv

java -jar MINE.jar preprocessed.csv -allPairs     (NOTE: it is important that preprocessed.csv have a .csv extension)

postprocess_mine_csv.pl < preprocessed.csv,allpairs,cv=0,B=n^0.6,Results.txt > postprocessed.csv

java edu.wright.cs.birg.feature_selection.correlation postprocessed.csv > features.csv


The perl scripts were written because the text processing in java was a pain.