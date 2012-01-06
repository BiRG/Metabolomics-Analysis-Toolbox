This is code for approximating the probability distributions needed
for my Bayesian filtering and peak-finding programs.

The first thing that must be chosen is the discretizations.  The peak
sample locations are discretized by the input data.  The normal input
data has 32K samples.  For my trial I will only have 128 samples
(approximately the width of 1 bin) to make it easy to try different
sets of parameters.

The amplitude discretizations are different for each x coordinate.  I
draw 100,000 samples from the prior distribution.  In fact, since my
model always works in pairs of amplitudes and since amplitudes are
highly correlated (usually almost exactly equal), I work on the pairs
a_x + a_x+1 and a_x - a_x+1.  This rotation by 45 degrees decorrelates
greatly the amplitudes and enables a richer discretization.  Then, I
choose the bins for the sum and difference that give maximum entropy
over their joint using a dynamic programming formulation.  If I wanted
to be really clever, I wouldn't use rectangular bins at all, I'd make
my bins be the areas closest to some seed points and the locations of
the points would be determined to make the bins have maximum entropy.
If I did that, I wouldn't need to decorrelate the data.  But other
things would be more complicated.

Next, I need to generate the main tables I will work from: counts of
a_x + a_x+1, a_x - a_x+1,l_x == t,u,v.  A box with a_x + a_x+1 == t
gets indexed if the discretized value of a_x + a_x+1 is t.  l_x is
true if one of the peak modes underlying the sample was closer to l_x
than to any other discrete x value.  I keep one extra count which is
the number of samples it took to do this so I can turn counts into
probabilities yet still merge tables produced by different machines or
processors losslessly.  Note that I could get away with two smaller
tables: a_x + a_x+1, a_x - a_x+1 and a_x,l_x but this would
necessitate some sort of translation due to the discretization.

The table generating program writes out its data every so many minutes
so I can stop it at any time and have its data, and it reads in the
data from the table on start-up.




