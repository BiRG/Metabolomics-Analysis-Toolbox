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

