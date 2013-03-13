%
%
%
%  Test the data density plot
%
%
old_rng = RandStream.getGlobalStream();
rng(2048);

% Generate test data
mul = 384;
x = randn(2048*mul, 1);
y = randn(2048*mul, 1);
x(1:(512*mul)) = x(1:(512*mul)) + 2.75;
x((1537:2048)*mul) = x((1537:2048)*mul) + 2.75;
y((1025:2048)*mul) = y((1025:2048)*mul) + 2.75;

% Get densities as a matrix
density_matrix = dataDensity(x, y, 10, 10, [-4, 6, -4, 4]);
expected_density_matrix = [ ...
    0, 11, 46, 138, 116, 78, 65, 39, 21, 0; 
    7, 98, 610, 1505, 1557, 866, 636, 464, 141, 17; 
    40, 560, 3828, 9361, 9742, 5604, 3956, 2770, 857, 108; 
    131, 1914, 12642, 31603, 32814, 18394, 13351, 9064, 2832, 350; 
    251, 3573, 23028, 58289, 59938, 33706, 24580, 17060, 5212, 647; 
    210, 3654, 22959, 57489, 59984, 33638, 24715, 16996, 5364, 691; 
    141, 1968, 12712, 31769, 32901, 18369, 13467, 9283, 2823, 372; 
    32, 571, 3786, 9450, 9782, 5539, 4070, 2760, 888, 105; 
    8, 97, 624, 1536, 1621, 978, 725, 505, 189, 15; 
    0, 13, 70, 172, 198, 111, 69, 77, 23, 4];
assertEqual(density_matrix, expected_density_matrix);


% On scatter plot you probably can't see the data density
figure;
scatter(x, y);
% On data density plot the structure should be visible
figure;
DataDensityPlot(x, y, 256, 80, 80,[-4,6,-4,4]);

RandStream.setGlobalStream(old_rng);
