%
%
%
%  Test the data density plot
%
%
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
density_matrix = dataDensity(x, y, 10, 10, [-4, 6, -4, 4]);
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


% On scatter plot you probably can't see the data density
%figure;
%scatter(x, y);
% On data density plot the structure should be visible
figure;
DataDensityPlot(x, y, 256, 80, 80,[-4,6,-4,4]);

RandStream.setGlobalStream(old_rng);
