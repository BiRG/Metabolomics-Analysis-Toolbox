% Set up the path for running the 2013 summit-focused deconvolution experiments

currentpath = cd('..');      % cd returns the path to the current directory
parentpath = cd(currentpath);
addpath(parentpath);
clear currentpath;
clear parentpath;
fprintf('Path set up for summit-focused deconvolution experiments.\n');
