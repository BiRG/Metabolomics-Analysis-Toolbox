clc

addpath([pwd,'/lib/bonf_holm']);                   % Bonferroni-Holm correction for multiple comparisons
addpath([pwd,'/lib/munkres']);                     % Linear assignment problem
addpath([pwd,'/lib/rand_org']);                    % True random numbers
addpath([pwd,'/lib/matlab_xunit/xunit']);          % Unit testing framework
addpath([pwd,'/lib/arrow']);                       % Code for drawing arrows on plots
addpath([pwd,'/lib/data_space_to_figure_space']);  % Matlab code from example for converting a point from data coordinates to figure coordinates
addpath([pwd,'/lib/hartigan_dip/']);               % Statistical test for multimodality (i.e. reject unimodality with alpha=xyz)
addpath([pwd,'/lib/mtit/']);                       % Code to add title to plot where subplots also have titles
addpath([pwd,'/common_scripts']);
addpath([pwd,'/common_scripts/cursors']);
addpath([pwd,'/common_scripts/dab']);
addpath([pwd,'/common_scripts/occupancy_2d']);     % Plot num points in rectangular subregions of parameter space

fprintf('Metabolomics Analysis Toolbox\n\n');
fprintf('Summary of functionality:\n');
fprintf('\topls/main - Orthogonal Projection on Latent Structures\n');
fprintf('\tpca/main - Orthogonal Projection on Latent Structures\n');
fprintf('\tfix_spectra/fix_spectra - Baseline correction, alignment to reference, and zero regions\n');
fprintf('\tbin/main - Bin based quantification/deconvolution designed around dynamic adaptive binning\n');
fprintf('\tvisualization/visualize_collections/main - Flexible spectral viewer\n');
