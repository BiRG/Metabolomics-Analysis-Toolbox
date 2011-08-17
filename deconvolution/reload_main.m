addpath('../common_scripts');
addpath('../common_scripts/cursors');
addpath('dab');
addpath('visualize_deconvolution');

[filename,pathname] = uigetfile('*.fig','Select saved figure');

open([pathname,filename]);