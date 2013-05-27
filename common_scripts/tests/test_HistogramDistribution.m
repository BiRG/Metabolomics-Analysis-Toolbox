function test_suite = test_HistogramDistribution%#ok<STOUT>
%matlab_xUnit tests excercising HistogramDistribution
%
% Usage:
%   runtests test_HistogramDistribution
initTestSuite;

function id = assert_id
% Return the identifier used for assertion failures - this is different
% between different Matlab versions, so I calculate it here
try
    assert(false);
catch ME
    id = ME.identifier;
end

function testConstructor %#ok<DEFNU>
% Test the examples from the constructor documentation

% Good distribution with 2 params and 1 bin
h=HistogramDistribution([0,1],1);
assertEqual(h.bounds, [0,1]);
assertEqual(h.probs, 1);
assertEqual(h.border_is_in_upper_bin, [true, false]);
assertEqual(h.cdf, 1);

% Good distribution with 3 params and 1 bin
h=HistogramDistribution([0,1],1,[1,0]);
assertEqual(h.bounds, [0,1]);
assertEqual(h.probs, 1);
assertEqual(h.border_is_in_upper_bin, [true, false]);
assertEqual(h.cdf, 1);

% Good distribution with 3 params and 6 bins
h=HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[1,1,0,1,0,0]);
assertEqual(h.bounds, [0,1,1,2,3,5]);
assertEqual(h.probs, [1,2,1,2,2]./8);
assertEqual(h.border_is_in_upper_bin, [1,1,0,1,0,0]==1);
assertEqual(h.cdf, [0.125, 0.375, 0.5, 0.75, 1]);

% Good distribution with 3 params and 6 bins using logical for last
h=HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[true,true,false,false,false,false]);
assertEqual(h.bounds, [0,1,1,2,3,5]);
assertEqual(h.probs, [1,2,1,2,2]./8);
assertEqual(h.border_is_in_upper_bin, [1,1,0,0,0,0]==1);
assertEqual(h.cdf, [0.125, 0.375, 0.5, 0.75, 1]);


% Good distribution with 2 params and 6 bins
h=HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8);
assertEqual(h.bounds, [0,1,1,2,3,5]);
assertEqual(h.probs, [1,2,1,2,2]./8);
assertEqual(h.border_is_in_upper_bin, [1,1,0,1,1,0]==1);
assertEqual(h.cdf, [0.125, 0.375, 0.5, 0.75, 1]);

% Error: Dirac interval without its upper bound
f = @() HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[1,1,1,1,0,0]);
assertExceptionThrown(f, 'HistogramDistribution:invalid_borders');

% Error: Dirac interval without its lower bound
f = @() HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[1,0,0,1,0,0]);
assertExceptionThrown(f, 'HistogramDistribution:invalid_borders');

% Error: try to have point in bin above last
f = @() HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[1,1,0,1,0,1]);
assertExceptionThrown(f, 'HistogramDistribution:invalid_borders');

% Error: try to have point in bin below first
f = @() HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[0,1,0,1,0,0]);
assertExceptionThrown(f, 'HistogramDistribution:invalid_borders');

% Error: probs don't sum to 1
f = @() HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,3]./8);
assertExceptionThrown(f, assert_id);

% Error: more probs than bins
f = @() HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,1,1]./8);
assertExceptionThrown(f, assert_id);

% Error: fewer probs than bins
f = @() HistogramDistribution([0,1,1,2,3,5],[1,2,1,4]./8);
assertExceptionThrown(f, assert_id);

% Error: negative prob
f = @() HistogramDistribution([0,1,1,2,3,5],[-1,3,1,2,2]./8);
assertExceptionThrown(f, assert_id);

% Error: bin boundaries not sorted
f = @() HistogramDistribution([2,1,1,2,3,5],[1,2,1,2,2]./8);
assertExceptionThrown(f, assert_id);

% Error: must be at least 1 bin (two bin boundaries)
f = @() HistogramDistribution(0,[]);
assertExceptionThrown(f, assert_id);

function testChar %#ok<DEFNU>
% Test HistogramDistribution.char()

% Single element arrays
h=HistogramDistribution([0,1],1);
i=HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[true,true,false,false,false,false]);
j=HistogramDistribution([5,6,100],[0.1,0.9]);

assertEqual(h.char(), 'HistogramDistribution([0, 1], [1], [1, 0])');
assertEqual(i.char(), 'HistogramDistribution([0, 1, 1, 2, 3, 5], [0.125, 0.25, 0.125, 0.25, 0.25], [1, 1, 0, 0, 0, 0])');
assertEqual(j.char(), 'HistogramDistribution([5, 6, 100], [0.1, 0.9], [1, 1, 0])');

% Two element array
two_element = [h,j];
assertEqual(two_element.char(), '[ HistogramDistribution([0, 1], [1], [1, 0]), HistogramDistribution([5, 6, 100], [0.1, 0.9], [1, 1, 0]) ]');

% Three element array
three_element = [h, i, j];
assertEqual(three_element.char(), '[ HistogramDistribution([0, 1], [1], [1, 0]), HistogramDistribution([0, 1, 1, 2, 3, 5], [0.125, 0.25, 0.125, 0.25, 0.25], [1, 1, 0, 0, 0, 0]), HistogramDistribution([5, 6, 100], [0.1, 0.9], [1, 1, 0]) ]');

function testFromEqualProbBins %#ok<DEFNU>
% Test creating a HistogramDistribution from equal probability bins using
% examples from the function documentation

% Single bin non-dirac
o = HistogramDistribution.fromEqualProbBins(0,1);
assertEqual(o.bounds, [0 1]);
assertEqual(o.probs, 1);
assertEqual(o.cdf, 1);
assertEqual(o.border_is_in_upper_bin, 1==[1 0]);

% Single dirac bin
o = HistogramDistribution.fromEqualProbBins(1,1);
assertEqual(o.bounds, [1 1]);
assertEqual(o.probs, 1);
assertEqual(o.cdf, 1);
assertEqual(o.border_is_in_upper_bin, 1==[1 0]);

% Two identical bins non-dirac
o = HistogramDistribution.fromEqualProbBins([1,1],[5,5]);
assertEqual(o.bounds, [1 5]);
assertEqual(o.probs, 1);
assertEqual(o.cdf, 1);
assertEqual(o.border_is_in_upper_bin, 1==[1 0]);

% Two identical dirac bins
o = HistogramDistribution.fromEqualProbBins([0,0],[0,0]);
assertEqual(o.bounds, [0 0]);
assertEqual(o.probs, 1);
assertEqual(o.cdf, 1);
assertEqual(o.border_is_in_upper_bin, 1==[1 0]);

% Two different non-overlapping bins 
o = HistogramDistribution.fromEqualProbBins([1,3],[2,5]);
assertEqual(o.bounds, [1 2 3 5]);
assertEqual(o.probs, [0.5 0 0.5]);
assertEqual(o.cdf, [0.5 0.5 1]);
assertEqual(o.border_is_in_upper_bin, 1==[1 1 1 0]);

% Two different overlapping bins 
o = HistogramDistribution.fromEqualProbBins([1,2],[3,6]);
assertEqual(o.bounds, [1 2 3 6]);
assertEqual(o.probs, [0.25 0.375 0.375]);
assertEqual(o.cdf, [0.25 0.625 1]);
assertEqual(o.border_is_in_upper_bin, 1==[1 1 1 0]);

% Two different overlapping one fully contained);
o = HistogramDistribution.fromEqualProbBins([1,2],[9,3]);
assertEqual(o.bounds, [1 2 3 9]);
assertEqual(o.probs, [0.0625 0.5625 0.375]);
assertEqual(o.cdf, [0.0625 0.625 1]);
assertEqual(o.border_is_in_upper_bin, 1==[1 1 1 0]);

% Two different one dirac dirac fully contained
o = HistogramDistribution.fromEqualProbBins([1,2],[9,2]);
assertEqual(o.bounds, [1 2 2 9]);
assertEqual(o.probs, [0.0625 0.5 0.4375]);
assertEqual(o.cdf, [0.0625 0.5625 1]);
assertEqual(o.border_is_in_upper_bin, 1==[1 1 0 0]);

% Two different one dirac dirac below lower
o = HistogramDistribution.fromEqualProbBins([1,0],[9,0]);
assertEqual(o.bounds, [0 0 1 9]);
assertEqual(o.probs, [0.5 0 0.5]);
assertEqual(o.cdf, [0.5 0.5 1]);
assertEqual(o.border_is_in_upper_bin, 1==[1 0 1 0]);

% Two different one dirac dirac at lower
o = HistogramDistribution.fromEqualProbBins([1,1],[9,1]);
assertEqual(o.bounds, [1 1 9]);
assertEqual(o.probs, [0.5 0.5]);
assertEqual(o.cdf, [0.5 1]);
assertEqual(o.border_is_in_upper_bin, 1==[1 0 0]);

% Two different one dirac dirac at upper
o = HistogramDistribution.fromEqualProbBins([1,9],[9,9]);
assertEqual(o.bounds, [1 9 9]);
assertEqual(o.probs, [0.5 0.5]);
assertEqual(o.cdf, [0.5 1]);
assertEqual(o.border_is_in_upper_bin, 1==[1 1 0]);

% Two different one dirac dirac above upper
o = HistogramDistribution.fromEqualProbBins([1,10],[9,10]);
assertEqual(o.bounds, [1 9 10 10]);
assertEqual(o.probs, [0.5 0 0.5]);
assertEqual(o.cdf, [0.5 0.5 1]);
assertEqual(o.border_is_in_upper_bin, 1==[1 1 1 0]);

% Two different both dirac
o = HistogramDistribution.fromEqualProbBins([1,10],[1,10]);
assertEqual(o.bounds, [1 1 10 10]);
assertEqual(o.probs, [0.5 0 0.5]);
assertEqual(o.cdf, [0.5 0.5 1]);
assertEqual(o.border_is_in_upper_bin, 1==[1 0 1 0]);

% Four different bins first dirac
o = HistogramDistribution.fromEqualProbBins([1,1,3,5],[1,3,5,9]);
assertEqual(o.bounds, [1 1 3 5 9]);
assertEqual(o.probs, [0.25 0.25 0.25 0.25]);
assertEqual(o.cdf, [0.25 0.5 0.75 1]);
assertEqual(o.border_is_in_upper_bin, 1==[1 0 1 1 0]);

% Four different bins first two identical dirac
o = HistogramDistribution.fromEqualProbBins([1,1,1,5],[1,1,5,9]);
assertEqual(o.bounds, [1 1 5 9]);
assertEqual(o.probs, [0.5 0.25 0.25]);
assertEqual(o.cdf, [0.5 0.75 1]);
assertEqual(o.border_is_in_upper_bin, 1==[1 0 1 0]);


function test_probOfInterval %#ok<DEFNU>
% Test probOfInterval using examples from documentation

h = HistogramDistribution([0,1,1,2,3],[0.25 0.25 0.25 0.25]);
i = HistogramDistribution([0,1,1,2,3,9],[0.2 0.2 0.2 0.2 0.2]);
hi = [h,i];
%
p = h.probOfInterval(Interval(0,1.5,false,false));
assertEqual(p, 0.625);
%
p = h.probOfInterval(Interval(1,1.5,true,true));
assertEqual(p, 0.375);
%
p = h.probOfInterval(Interval(1,1.5,false,true));
assertEqual(p, 0.125);
%
p = i.probOfInterval(Interval(1,1.5,false,true));
assertEqual(p, 0.1);
%
p = hi.probOfInterval(Interval(1,1.5,false,true));
assertEqual(p, [0.125, 0.1]);
%
p = hi.probOfInterval(Interval([0 1],[1.5 1.5],[false false],[true true]));
assertEqual(p, [0.625, 0.1]);
%
p = h.probOfInterval(Interval([0 1],[1.5 1.5],[false false],[true true]));
assertEqual(p, [0.625, 0.125]);
%
f = @() hi.probOfInterval(Interval([0 1 2],[1 1.5 3],true(1,3),true(1,3)));
assertExceptionThrown(f,'HistogramDistribution_probOfInterval:input_shape');

function test_private_extendInterval %#ok<DEFNU>
% Uses the examples as test cases

h = HistogramDistribution([2,3,5,8,8],0.25*ones(1,4),[1,1,1,1,0]);
i = h.private_extendInterval(Interval(5,8,false,false),0.3);
assertEqual(i, Interval(5,8,false,true));
%
i = h.private_extendInterval(Interval(5,8,false,false),0.25);
assertEqual(i, Interval(5,8,false,true));
%
i = h.private_extendInterval(Interval(5,8,false,true),0.25);
assertEqual(i, Interval(5,8,false,true));
%
i = h.private_extendInterval(Interval(3,5,false,true),0.2); 
assertEqual(i, Interval(3,8,false,false)); 
%
i = h.private_extendInterval(Interval(3,5,false,true),0.375); 
assertEqual(i, Interval(3,6.5,false,false));
assertEqual(h.probOfInterval(i),0.375);
%
i = h.private_extendInterval(Interval(3,5,false,false),0.375); 
assertEqual(i, Interval(3,5,false,true));
%
i = h.private_extendInterval(Interval(3,5,false,true),0.6); 
assertEqual(i, Interval(3,8,false,false));


function test_rebinApproxEqualProb %#ok<DEFNU>
% Uses the examples as test cases
h = HistogramDistribution([0,1,1,2,3],[0.25 0.25 0.25 0.25]);
i = HistogramDistribution([0,1,1,2,3,5],[0.2 0.2 0.2 0.2 0.2]);
hi = [h,i];
%
n = h.rebinApproxEqualProb(4);
%
assertEqual(n, h);
%
n = h.rebinApproxEqualProb(5);
%
assertEqual(n, HistogramDistribution([0, 0.8,1,5/3,7/3,3],[0.2 0.3 1/6 1/6 1/6],[1,1,0,1,1,0]));
%
n = i.rebinApproxEqualProb(5);
%
assertEqual(n, i);
%
n = i.rebinApproxEqualProb(4);
%
assertEqual(n, HistogramDistribution([0,1,4/3,8/3,5],[3/15 4/15 4/15 4/15]));
%
n = hi.rebinApproxEqualProb(4);
%
assertEqual(n, [h, HistogramDistribution([0,1,4/3,8/3,5],[3/15 4/15 4/15 4/15])]);
%
n = hi.rebinApproxEqualProb(4,5);
%
assertEqual(n, hi);
%
