This contains Java code that does best-first correlation-based feature
selection based on mic and possibly some other measures.

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

Compile and export to a runnable jar (you can choose the name you wish, I'll call it cbfs.jar)

java -jar cbfs.jar -genfeatures < original.csv > features.csv

