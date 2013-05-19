function test_suite = test_GLBIO2013Deconv_alignment %#ok<STOUT>
% matlab_xUnit tests excercising the alignment functions in GLBIO2013Deconv 
%
% Usage:
%   runtests test_GLBIO2013Deconv_alignment 
initTestSuite;

function assertSingleLPAssignment(l1, l2, exponent, correct)
% Assert that l2(correct) is the calculated minimum assignment from l1 to l2 with the given lp norm exponent
[a,c]=GLBIO2013Deconv.l_p_norm_assignment(l1,l2, exponent);
assertEqual(a, correct);
assertEqual(c, sum(abs(l1(a > 0)-l2(a(a > 0))).^exponent));

function assertUnambiguousAssignment(l1, l2, correct)
% Assert that l2(correct) is the calculated unambiguous assignment from l1 to l2 
a=GLBIO2013Deconv.unambiguous_assignment(l1,l2);
assertEqual(a, correct);



function test_lp_location_alignment %#ok<DEFNU>
% Check that lists of locations are aligned correctly and with the correct costs.

exponent = 2;
assertSingleLPAssignment([1,2,3], [3.2,0.2  ,3.1], exponent, [2,3,1]);
assertSingleLPAssignment([1,2,3], [3.1,2.8  ,1.8], exponent, [3,2,1]);
assertSingleLPAssignment([1,2,3], [3.1,2.99 ,1.8], exponent, [3,2,1]);
assertSingleLPAssignment([1,2,3], [3.1,3.101,1.8], exponent, [3,1,2]);
assertSingleLPAssignment([1,2,3,4],[3.1,3.101,1.8], exponent, [0,3,1,2]);
assertSingleLPAssignment([1,2,3,4],[1,2,3], exponent, [1,2,3,0]);
assertSingleLPAssignment([],[1,2,3], exponent, zeros(1,0));
assertSingleLPAssignment([1,2,3,4],[], exponent, [0,0,0,0]);
assertSingleLPAssignment([1,2,3,4],2, exponent, [0,1,0,0]);
assertSingleLPAssignment(3, 2, exponent, 1);
assertSingleLPAssignment(3, [1,4,7], exponent, 2);
assertSingleLPAssignment(3, [1,4], exponent, 2);
assertSingleLPAssignment(2, [1,4], exponent, 1);
assertSingleLPAssignment([1,2,3], [1,2,3], exponent, [1,2,3]);
assertSingleLPAssignment([2,1,3], [1,2,3], exponent, [2,1,3]);
assertSingleLPAssignment([2,3,1], [1,2,3], exponent, [2,3,1]);
assertSingleLPAssignment([3,2,1], [1,2,3], exponent, [3,2,1]);
assertSingleLPAssignment([3,1,2], [1,2,3], exponent, [3,1,2]);
assertSingleLPAssignment([1,3,2], [1,2,3], exponent, [1,3,2]);

exponent = 1;
assertSingleLPAssignment([1,2,3], [3.8,2.3  ,2.1], exponent, [3,2,1]); % 2,3,1 gives the same cost
assertSingleLPAssignment([1,2,3], [3.2,0.2  ,3.1], exponent, [2,1,3]);
assertSingleLPAssignment([1,2,3], [3.1,2.8  ,1.8], exponent, [3,2,1]);
assertSingleLPAssignment([1,2,3], [3.1,2.99 ,1.8], exponent, [3,2,1]);
assertSingleLPAssignment([1,2,3], [3.1,3.101,1.8], exponent, [3,1,2]);
assertSingleLPAssignment([1,2,3,4],[3.1,3.101,1.8], exponent, [0,3,1,2]);
assertSingleLPAssignment([1,2,3,4],[1,2,3], exponent, [1,2,3,0]);
assertSingleLPAssignment([],[1,2,3], exponent, zeros(1,0));
assertSingleLPAssignment([1,2,3,4],[], exponent, [0,0,0,0]);
assertSingleLPAssignment([1,2,3,4],2, exponent, [0,1,0,0]);
assertSingleLPAssignment(3, 2, exponent, 1);
assertSingleLPAssignment(3, [1,4,7], exponent, 2);
assertSingleLPAssignment(3, [1,4], exponent, 2);
assertSingleLPAssignment(2, [1,4], exponent, 1);
assertSingleLPAssignment([1,2,3], [1,2,3], exponent, [1,2,3]);
assertSingleLPAssignment([2,1,3], [1,2,3], exponent, [2,1,3]);
assertSingleLPAssignment([2,3,1], [1,2,3], exponent, [2,3,1]);
assertSingleLPAssignment([3,2,1], [1,2,3], exponent, [3,2,1]);
assertSingleLPAssignment([3,1,2], [1,2,3], exponent, [3,1,2]);
assertSingleLPAssignment([1,3,2], [1,2,3], exponent, [1,3,2]);

exponent = 0.5;
assertSingleLPAssignment([1,2,3], [3.8,2.3  ,2.1], exponent, [2,3,1]);
assertSingleLPAssignment([1,2,3], [3.2,0.2  ,3.1], exponent, [2,1,3]);
assertSingleLPAssignment([1,2,3], [3.1,2.8  ,1.8], exponent, [3,2,1]);
assertSingleLPAssignment([1,2,3], [3.1,2.99 ,1.8], exponent, [1,3,2]);
assertSingleLPAssignment([1,2,3], [3.1,3.101,1.8], exponent, [2,3,1]);
assertSingleLPAssignment([1,2,3,4],[3.1,3.101,1.8], exponent, [0,3,1,2]);
assertSingleLPAssignment([1,2,3,4],[1,2,3], exponent, [1,2,3,0]);
assertSingleLPAssignment([],[1,2,3], exponent, zeros(1,0));
assertSingleLPAssignment([1,2,3,4],[], exponent, [0,0,0,0]);
assertSingleLPAssignment([1,2,3,4],2, exponent, [0,1,0,0]);
assertSingleLPAssignment(3, 2, exponent, 1);
assertSingleLPAssignment(3, [1,4,7], exponent, 2);
assertSingleLPAssignment(3, [1,4], exponent, 2);
assertSingleLPAssignment(2, [1,4], exponent, 1);
assertSingleLPAssignment([1,2,3], [1,2,3], exponent, [1,2,3]);
assertSingleLPAssignment([2,1,3], [1,2,3], exponent, [2,1,3]);
assertSingleLPAssignment([2,3,1], [1,2,3], exponent, [2,3,1]);
assertSingleLPAssignment([3,2,1], [1,2,3], exponent, [3,2,1]);
assertSingleLPAssignment([3,1,2], [1,2,3], exponent, [3,1,2]);
assertSingleLPAssignment([1,3,2], [1,2,3], exponent, [1,3,2]);


function peaks = randomPeaksAtLocations(locations)
% Produces peaks that have random parameters except for the given locations
peaks = rand(length(locations)*4,1);
peaks(4:4:end) = locations;
peaks = GaussLorentzPeak(peaks);

function assertPeakAlignment(l1, l2, criterion, correct)
% Check that sets of peaks with the locations given in l1 and l2 aligned
% with best_alignment(..., criterion) give the alignment listed in correct
%
% Uses the random number generator to fill in the rest of the peak
% parameters
p1 = randomPeaksAtLocations(l1);
p2 = randomPeaksAtLocations(l2);
a = GLBIO2013Deconv.best_alignment(p1,p2,criterion);
assertEqual(a, correct);


function test_peak_alignment %#ok<DEFNU>
% Check that sets of peaks are aligned correctly

old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',212959804));


assertPeakAlignment([1,2,3], [3.2,0.2  ,3.1], 'l2', [2,3,1;1,2,3]);
assertPeakAlignment([1,2,3], [3.1,2.8  ,1.8], 'l2', [3,2,1;1,2,3]);
assertPeakAlignment([1,2,3], [3.1,2.99 ,1.8], 'l2', [3,2,1;1,2,3]);
assertPeakAlignment([1,2,3], [3.1,3.101,1.8], 'l2', [3,1,2;1,2,3]);
assertPeakAlignment([1,2,3,4],[3.1,3.101,1.8], 'l2', [3,1,2;2,3,4]);
assertPeakAlignment([1,2,3,4],[1,2,3], 'l2', [1,2,3;1,2,3]);
assertPeakAlignment([],[1,2,3], 'l2', zeros(2,0));
assertPeakAlignment([1,2,3,4],[], 'l2', zeros(2,0));
assertPeakAlignment([1,2,3,4],2, 'l2', [1;2]);
assertPeakAlignment(3, 2, 'l2', [1;1]);
assertPeakAlignment(3, [1,4,7], 'l2', [2;1]);
assertPeakAlignment(3, [1,4], 'l2', [2;1]);
assertPeakAlignment(2, [1,4], 'l2', [1;1]);
assertPeakAlignment([1,2,3], [1,2,3], 'l2', [1,2,3;1,2,3]);
assertPeakAlignment([2,1,3], [1,2,3], 'l2', [2,1,3;1,2,3]);
assertPeakAlignment([2,3,1], [1,2,3], 'l2', [2,3,1;1,2,3]);
assertPeakAlignment([3,2,1], [1,2,3], 'l2', [3,2,1;1,2,3]);
assertPeakAlignment([3,1,2], [1,2,3], 'l2', [3,1,2;1,2,3]);
assertPeakAlignment([1,3,2], [1,2,3], 'l2', [1,3,2;1,2,3]);


RandStream.setGlobalStream(old_rng);
