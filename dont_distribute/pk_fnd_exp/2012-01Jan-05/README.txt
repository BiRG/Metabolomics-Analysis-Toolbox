This is code for approximating the probability distributions needed
for my Bayesian filtering and peak-finding programs.

Requires: boost-serialization and waffles machine learning libraries

The first thing that must be chosen is the discretizations.  The peak
sample locations are discretized by the input data.  The normal input
data has 32K samples.  For my trial I will only have 128 samples
(approximately the width of 1 bin) to make it easy to try different
sets of parameters.

The amplitude discretizations are different for each x coordinate.  I
draw 100,000 samples from the prior distribution.  I discretize each
amplutude independently.  It would be nice if I could discretize them
jointly (so u<a0<v AND w<a1<x is one bin given one number) because
they are hightly correlated.  In the same light, it would be nice to
transform the variables (for the purpose of discretization) to
a0+a1,a0-a1 (which would decorrelate them).  But I can't see a good
way to sum over the variables for the messages I will need to pass in
the sum-product algorithm.  Maybe everything will become clear once I
have actually implemented the sum-product algorithm.  For right now, I
just take the max and min of observed values for each variable, divide
the range into 256 equal parts and go.  The top and bottom entries of
each range will get anything outside of the max and min.

It might be profitable to later on, redo the bins for each variable so
they have equal numbers of samples in them or so that they are
V-optimal or Max-diff binnings.  

Another binning that could be very useful is a minimum entropy binning
- where we want to minimize the entropy of the "there is a peak at
this sample" variable that will be predicted using the bins.  That
minimum entropy could be selected on the bin-sets for all variables
that will be involved (thus, though bin ranges must only depend on one
variable, the entropy for a binning of e.g. a0 would be calculated the
minimum entropy of the predicted variable over all binnings of a1 when
the binning of a0 is used.)

All of the non-uniform binnings have the problem that to discretize a
value, one needs to do a binary search, which could take significantly
longer than just subtracting and dividing.  This could increase the
time required to accumulate the tables of samples.

Next, I need to generate the main tables I will work from: counts of
a_x, a_x+1=t,u and a_x,l_x == t,v.  A box with a_x == t
gets indexed if the discretized value of a_x is t.  l_x is
true if one of the peak modes underlying the sample was closer to l_x
than to any other discrete x value.  I keep one extra count which is
the number of samples it took to do this so I can turn counts into
probabilities yet still merge tables produced by different machines or
processors losslessly.

The table generating program writes out its data every so many minutes
so I can stop it at any time and have its data, and it reads in the
data from the table on start-up.
