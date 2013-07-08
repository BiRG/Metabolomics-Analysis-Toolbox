#!/bin/bash
if [ $# -ne 0 ]; then
    echo -e "Usage: $0\n(Note lack of arguments)";
    exit;
fi

#Usage: 
unset DISPLAY
# IMPORTANT: DO NOT indent any of the below statements
matlab -nodesktop -singleCompThread  > glbio2013_run_update_mar7_terminal_output.txt <<MATLAB_ENV
% The below works like a script m-file between MATLAB_ENVs
cd('targeted_deconv/QuantMetabMap');
warning('off','MATLAB:RandStream:GetDefaultStream');
warning('off','MATLAB:RandStream:SetDefaultStream');
in_name  = 'Mar_07_2013_test_experiment_results.mat';
load(in_name);
out_name = 'Mar_07_2013_test_experiment_results_after_picker_removal_and_update.mat';
tic; 
tmp = GLBIO2013_remove_peak_pickers_from_data({GLBIO2013Deconv.pp_smoothed_local_max, GLBIO2013Deconv.pp_gold_std_aligned_with_local_max}, Mar_07_2013_test_experiment_results);
Mar_07_2013_results_after_picker_removal_and_update=GLBIO2013_run_update_all(1, tmp); toc
save(out_name, 'Mar_07_2013_results_after_picker_removal_and_update');
exit                      % don't forget to exit
MATLAB_ENV
# keep this line to ensure newline


