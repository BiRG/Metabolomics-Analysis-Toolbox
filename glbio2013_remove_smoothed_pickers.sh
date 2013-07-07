#!/bin/bash
if [ $# -lt 1 ]; then
    echo -e "Usage: $0 session_num(up to 64)\n";
    exit;
fi
if [ $1 -gt 64 -o $1 -lt 1 ]; then
    echo -e "The session number must be 1-64\n";
    exit;
fi

#Usage: 
unset DISPLAY
# IMPORTANT: DONOT indent any of the below statements
matlab -nodesktop -singleCompThread  > glbio2013_run_$1_max_picker_removal_terminal_output <<MATLAB_ENV
% The below works like a script m-file between MATLAB_ENVs
cd('targeted_deconv/QuantMetabMap');
warning('off','MATLAB:RandStream:GetDefaultStream');
warning('off','MATLAB:RandStream:SetDefaultStream');
in_name = 'glbio2013_run_$1_results.mat';
load(in_name);
out_name = 'glbio2013_run_$1_results_without_local_max_pickers.mat';
tic; results_$1=GLBIO2013_remove_peak_pickers_from_data({GLBIO2013Deconv.pp_smoothed_local_max, GLBIO2013Deconv.pp_gold_std_aligned_with_local_max},results_$1); toc
save(out_name, 'results_$1');
exit                      % don't forget to exit
MATLAB_ENV
# keep this line to ensure newline


