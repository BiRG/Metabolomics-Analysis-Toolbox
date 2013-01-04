% Prints a summary of the analysis of the results from the GLBIO2013 experiments

%% Load the combined results
load('glbio2013_combined_raw_results.mat');

%% Calculate the parameters
pe_list = GLBIO2013_calc_param_error_list(glbio_combined_results);

%% Does an improvement exist independent of any other measure? The histogram suggests yes
clf;
hist([pe_list.error_diff],100);
title('Histogram of all parameter improvements for all peak picking methods and all parameters');
xlabel('Improvement in error (error_{anderson} - error_{summit})');
ylabel('Number of (deconvolution,parameter) pairs');
[~,p_value] = ttest([pe_list.mean_error_anderson],[pe_list.mean_error_summit],0.05,'right');
sig_box_handle = annotation('textbox',[0.5,0.5,0.2,0.2],'String', ...
    sprintf('mean difference is greater than 0: p=%.18g',p_value));