addpath('../matlab_scripts');
addpath('../matlab_scripts/cursors');
addpath('dab');
addpath('visualize_deconvolution');
addpath('../lib');

[filename,pathname] = uigetfile('*.fig','Select saved figure');

open([pathname,filename]);