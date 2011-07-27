clc

addpath([pwd,'/lib']);
addpath([pwd,'/lib/extern/randorg']);
addpath([pwd,'/matlab_scripts']);
addpath([pwd,'/matlab_scripts/cursors']);
addpath([pwd,'/lib/dab']);

fprintf('Metabolomics Analysis Toolbox\n\n');
fprintf('Summary of functionality:\n');
fprintf('\topls/main - Orthogonal Projection on Latent Structures\n');
fprintf('\tpca/main - Orthogonal Projection on Latent Structures\n');
fprintf('\tfix_spectra/fix_spectra - Baseline correction, alignment to reference, and zero regions\n');
fprintf('\tbin/main - Bin based quantification designed around dynamic adaptive binning\n');
fprintf('\tdeconvolution/main - Map-reduce based deconvolution algorithm\n');
fprintf('\tvisualization/visualize_collections/main - Flexible spectral viewer\n');
