% Run occupancy_2d_* finctions for human evaluation
%
% Does a quick & dirty test of occupancy_2d and then displays a plot. Read
% the comments to understand what the output should be. 
%
% To run: 
%
% >> exercise_occupancy_2d_plot
%

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

if exist('assertEqual','file') % use matlab xunit if available
    assertEqual(density_matrix, expected_density_matrix);
else
    assert(all(all(density_matrix == expected_density_matrix)), ...
	   'occupancy_2d generates incorrect density matrix');
end

% Plot a nice graphic (which should be two adjacent blobs, with the one on
% the right much less dense than the one on the right)
figure;
occupancy_2d_plot(x, y, 256, 80, 80,[-4,6,-4,4]);

% Restore original random number generator
RandStream.setGlobalStream(old_rng);
