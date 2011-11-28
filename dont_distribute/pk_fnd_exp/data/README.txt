Peak Finding Data README
========================
:Author: Eric Moyer 
:Email:  eric_moyer@yahoo.com

:toc:

This file describes the data files located in this directory.  I used
these files in my peak finding experiments.

== Files:

=== two_spectra_window_33.arff

I used the first two spectra from Paul Anderson's synthetic data and
broke them into 33 sample wide windows. No window that would have
overlapped the edge of the spectrum (for which there was no data) was
kept.

==== Input Fields

The first element in each window is given as a full intensity.  The
rest of the elements are given as the difference between their value
and the first value.  There is also a field giving the estimated
noise standard deviation for the spectrum from which the individual
window was drawn.  

==== Output Fields

There are 3 class or label fields.  The first is just a continuous
attribute giving the number of peaks closer to the center sample than
to any other sample.  The second is that same attribute but expressed
as a nominal value.  The third is a binary nominal value giving
whether there was at least one peak or zero peaks closer to the center
of the window than to any other sample.

==== Class Equalization

There are an overabundance of windows not containing peaks.  94.7% of
the windows do not have a peak.  Let the number of peaks-containing
windows in the spectrum be S (3412).  To even the class prior
probabilities, only a random subset of S non-peak-containing windows
was chosen to accompany those windows that did have a peak.  (There is
a minor bug in the program that resulted in there being only 3411
windows that do not contain a peak).

=== two_spectra_window_65.arff

Exactly like two_spectra_window_33.arff except that the window was 65
samples wide.

== Directories:

None

NOTE: This file is compatible with asciidoc
