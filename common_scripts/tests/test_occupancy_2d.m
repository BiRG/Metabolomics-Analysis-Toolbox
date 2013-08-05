function test_suite = test_occupancy_2d %#ok<STOUT>
%matlab_xUnit tests excercising occupancy_2d
%
% Usage:
%   runtests test_occupancy_2d
initTestSuite;

function test_random_input %#ok<DEFNU>
% Test with random input that the DataDensityPlot author was using for his
% tests

% Set the random number generator so we get reproducable results and save
% the current rng state so we can restore it when we're done.
old_rng = RandStream.getGlobalStream();
rng(2048);

% Generate test data
mul = 192;
x = randn(2048*mul, 1);
y = randn(2048*mul, 1);
x(1:(512*mul)) = x(1:(512*mul)) + 2.75;
x((1537:2048)*mul) = x((1537:2048)*mul) + 2.75;
y((1025:2048)*mul) = y((1025:2048)*mul) + 2.75;

% Get densities as a matrix
density_matrix = occupancy_2d(x, y, 10, 10, [-4, 6, -4, 4]);

% Verify that densities have been generated correctly
expected_density_matrix = [ ...
    0, 4, 32, 77, 72, 37, 31, 16, 7, 0; 
    3, 46, 298, 733, 822, 413, 306, 221, 75, 7; 
    21, 289, 1904, 4661, 4876, 2721, 1902, 1371, 454, 48; 
    66, 938, 6334, 15851, 16391, 9171, 6577, 4663, 1393, 181; 
    110, 1876, 11477, 29103, 29596, 16816, 12363, 8532, 2626, 345; 
    114, 1837, 11545, 29036, 29922, 16953, 12210, 8403, 2652, 351; 
    57, 1003, 6130, 15883, 16458, 9361, 6742, 4613, 1471, 166; 
    17, 262, 1879, 4693, 4899, 2834, 2056, 1377, 462, 49; 
    2, 59, 264, 809, 838, 482, 379, 270, 93, 16; 
    0, 7, 38, 108, 128, 74, 72, 58, 15, 4];

assertEqual(density_matrix, expected_density_matrix);

% Restore original random number generator
RandStream.setGlobalStream(old_rng);

function test_empty_input %#ok<DEFNU>
% Check that empty input gives matrix of 0's
 actual = occupancy_2d([],[],3,3);
 expected = zeros(3);
 assertEqual(actual, expected);
 
function test_unequal_input_lengths %#ok<DEFNU>
% Check that when x and y have different lengths an exception is thrown

a = @() occupancy_2d(1,[], 10, 5);
assertExceptionThrown(a, 'occupancy_2d:same_x_y_length');

a = @() occupancy_2d([2],[10.1,10.2], 10, 10);
assertExceptionThrown(a, 'occupancy_2d:same_x_y_length');

a = @() occupancy_2d([2,3],[10.2], 10, 10);
assertExceptionThrown(a, 'occupancy_2d:same_x_y_length');

function test_bad_width_height %#ok<DEFNU>
% Check that when x and y have different lengths an exception is thrown

a = @() occupancy_2d([2,3],[10.1,10.2], -4, 1);
assertExceptionThrown(a, 'occupancy_2d:bad_num_bins');

a = @() occupancy_2d([2,3],[10.1,10.2], 1, -4);
assertExceptionThrown(a, 'occupancy_2d:bad_num_bins');

a = @() occupancy_2d([2,3],[10.1,10.2], 0, 0);
assertExceptionThrown(a, 'occupancy_2d:bad_num_bins');

a = @() occupancy_2d([2,3],[10.1,10.2], 0, 1);
assertExceptionThrown(a, 'occupancy_2d:bad_num_bins');

a = @() occupancy_2d([2,3],[10.1,10.2], 1, 0);
assertExceptionThrown(a, 'occupancy_2d:bad_num_bins');

a = @() occupancy_2d([2,3],[10.1,10.2], 1, 1.1);
assertExceptionThrown(a, 'occupancy_2d:bad_num_bins');

a = @() occupancy_2d([2,3],[10.1,10.2], 2.2, 1);
assertExceptionThrown(a, 'occupancy_2d:bad_num_bins');

function test_small_inputs %#ok<DEFNU>
% Check for small input vectors and their limits

assertEqual(occupancy_2d(1,1,1,1),1);

assertEqual(occupancy_2d(1,1,2,1),[1,0]);

assertEqual(occupancy_2d(1,1,1,2),[1;0]);

assertEqual(occupancy_2d(1,1,2,2),[1 0;0 0]);

assertEqual(occupancy_2d(1,1,2,2,[-10 10 -10 10]),[0 0;0 1]);

assertEqual(occupancy_2d(1,1,2,2,[-10 -9 -10 -9]),[0 0;0 0]);

assertEqual(occupancy_2d(1,1,2,2,[0 10 -10 10]),[0 0;1 0]);

assertEqual(occupancy_2d(1,1,2,2,[-10 10 0 10]),[0 1;0 0]);

assertEqual(occupancy_2d(1,1,2,2,[0 10 0 10]),[1 0;0 0]);

assertEqual(occupancy_2d([1,2],[1,2],2,2,[0 10 0 10]),[2 0;0 0]);

assertEqual(occupancy_2d([1,6],[1,2],2,2,[0 10 0 10]),[1 1;0 0]);







