function test_suite = test_histogram_normalize%#ok<STOUT>
%matlab_xUnit tests excercising histogram_normalize
%
% Usage:
%   runtests test_histogram_normalize
initTestSuite;

% ######################################
%
% Utility functions
%
% ######################################

function h=func_handles
% Returns a cell array of the function handles from histogram_normalize
h=histogram_normalize('return subfunction handles for testing');

function expurgated = remove_values(values, baseline_pts, n_std_dev)
% Utility function allowing calling of histogram_normalize/remove_values
% from test code
h = func_handles(); h=h{1};
expurgated = h(values, baseline_pts, n_std_dev);

function err_v = err(mult, values, y_bins, ref_histogram)
% Utility function allowing calling of histogram_normalize/err
% from test code
h = func_handles(); h=h{2};
err_v = h(mult, values, y_bins, ref_histogram);

function mult = best_mult_for(values, y_bins, ref_histogram, min_y, max_y)
% Utility function allowing calling of histogram_normalize/best_mult_for
% from test code
h = func_handles(); h=h{3};
mult = h(values, y_bins, ref_histogram, min_y, max_y);

function mult = mult_search_bounds_for(values, y_bins, ref_histogram, min_y, max_y)
% Utility function allowing calling of histogram_normalize/mult_search_bounds_for
% from test code
h = func_handles(); h=h{4};
mult = h(values, y_bins, ref_histogram, min_y, max_y);

function specs=loadTestSpectraYValues(set_number)
% Utility function returning the y-values of the test spectra in test set
% set_number
s = load('hist_norm_test_spectra.mat');
specs = s.diluted_spectra{set_number}.Y;


% ######################################
%
% Actual tests
%
% ######################################


function testFunctionHandleList %#ok<DEFNU>
% Check that the list of function handles is in the order we were expecting
names = cellfun(@func2str, func_handles, 'UniformOutput', false);
assertEqual(names, {'histogram_normalize/remove_values', ...
    'histogram_normalize/err','histogram_normalize/best_mult_for', ...
    'histogram_normalize/mult_search_bounds_for'});


function testRemoveV_0ValuesNoBaseline %#ok<DEFNU>
% Check that remove_values does nothing when given a list of no values but
% no points are to be used for baseline
f = @() remove_values([], 0, 1);
assertEqual(f(), []);

function testRemoveV_0Values1Baseline %#ok<DEFNU>
% Check that remove_values throws an exception when using 1 baseline point
% from an empty array of values
f = @() remove_values([], 1, 1);
assertExceptionThrown(f, 'remove_values:enough_baseline');

function testRemoveV_5Values1BaselinePosVal %#ok<DEFNU>
% Check that remove_values returns the positive values when given 1
% baseline point that is positive (so std is always 0).
f = @() remove_values([5,-1,2,-5,9], 1, 1);
assertEqual(f(), [5,2,9]);

function testRemoveV_5Values1BaselineNegVal %#ok<DEFNU>
% Check that remove_values returns the positive values when given 1
% baseline point that is negative (so std is always 0).
f = @() remove_values([-15,-1,2,-5,9], 1, 1);
assertEqual(f(), [2,9]);

function testRemoveV_5Values2BaselineOneAbove %#ok<DEFNU>
% Check that remove_values returns the values greater than the standard
% deviation when there are no values above.
f = @() remove_values([-15,-1,2,-5,10], 2, 1);
assertEqual(f(), 10);

function testRemoveV_5Values2BaselineAllAbove %#ok<DEFNU>
% Check that remove_values returns the values greater than the standard
% deviation when a value above.
f = @() remove_values([15,10,4,5,9], 2, 1);
assertEqual(f(),[15,10,4,5,9]);

function testRemoveV_5Values2BaselineNoneAbove %#ok<DEFNU>
% Check that remove_values returns the values greater than the standard
% deviation no values are above.
f = @() remove_values([-15,-10,2,1,0], 2, 1);
assertTrue(isempty(f()));

function testRemoveV_5Values2BaselineSomeEqual %#ok<DEFNU>
% Check that remove_values returns empty set even when some values are
% equal to std
f = @() remove_values([-15,-10,std([-15,-10]),1,0], 2, 1);
assertTrue(isempty(f()));

function testRemoveV_5Values2BaselineStdDev %#ok<DEFNU>
% Check that remove_values correctly responds to changes to the
% standard deviation parameter
f = @() remove_values([15,10,4,5,9], 2, 2);
assertEqual(f(),[15,10,9]);

function testRemoveV_5Values3BaselineStdDev %#ok<DEFNU>
% Check that remove_values calculates correctly with 3 baseline points
f = @() remove_values([15,10,4,5,9], 3, 2);
assertEqual(f(),15);


