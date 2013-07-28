#!/bin/bash
if [ $# -lt 2 ]; then
    echo -e "Usage: $0 num_reps session_num(up to 64)\n";
    exit;
fi
if [ $1 -lt 1 ]; then
    echo -e "You must include at least 1 repetition\n";
    exit;
fi
if [ $2 -gt 64 -o $2 -lt 1 ]; then
    echo -e "The session number must be 1-64\n";
    exit;
fi

#Usage: 
unset DISPLAY
# IMPORTANT: DONOT indent any of the below statements
matlab -nodesktop -singleCompThread  > test_summit_2013_run_$2_terminal_output <<MATLAB_ENV
% The below works like a script m-file between MATLAB_ENVs
cd('targeted_deconv/QuantMetabMap/TestSummitDeconv2013');
warning('off','MATLAB:RandStream:GetDefaultStream');
warning('off','MATLAB:RandStream:SetDefaultStream');
setup_path;
tic; results_$2=run_experiment($1,$2,64,false); toc
save('test_summit_2013_run_$2_results.mat', 'results_$2');
exit                      % don't forget to exit
MATLAB_ENV
# keep this line to ensure newline


