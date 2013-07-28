#!/bin/bash
if [ $# -ne 0 ]; then
    echo -e "Usage: $0\n(Note lack of arguments)";
    exit;
fi

#Usage: 
unset DISPLAY
# IMPORTANT: DO NOT indent any of the below statements
matlab -nodesktop -singleCompThread  > glbio2013_add_new_dsps_mar7_terminal_output.txt <<MATLAB_ENV
% The below works like a script m-file between MATLAB_ENVs
cd('targeted_deconv/QuantMetabMap');
warning('off','MATLAB:RandStream:GetDefaultStream');
warning('off','MATLAB:RandStream:SetDefaultStream');
in_name  = 'Mar_07_2013_test_experiment_results_after_picker_removal_and_update.mat';
out_name = 'Mar_07_2013_test_experiment_results_with_new_dsps.mat';
load(in_name);
tic; 
Mar_07_2013_test_experiment_results_with_new_dsps=run_update_all(1, Mar_07_2013_results_after_picker_removal_and_update); toc
save(out_name, 'Mar_07_2013_test_experiment_results_with_new_dsps');
exit                      % don't forget to exit
MATLAB_ENV
# keep this line to ensure newline


