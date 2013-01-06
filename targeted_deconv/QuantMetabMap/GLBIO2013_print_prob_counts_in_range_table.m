function GLBIO2013_print_prob_counts_in_range_table( interval_half_width )
% Prints the table of probabilities that the spectrum widths give the correct peak merging probabilities
%
% Usage: GLBIO2013_print_prob_counts_in_range_table( interval_half_width )
%
% interval_half_width - half of the width of the acceptable interval around
%                       the center
%
% Loads the combined peak merging counts file and prints its contents as a
% table giving the probability that each entry has the correct value in the
% correct range around the center.
%
% NOTE: assumes 'probability_of_max_counts_in_random_spec.mat' contains a
% variable called merging_probs_combined that contains a struct that could 
% be obtained from the probability_of_peak_merging_in_random_spec function
% with 10 entries. The i'th entry has a desired target of (i-1)/10

% Load the output from its saved location in the .mat file and do some
% quick sanity checks.
load('probability_of_max_counts_in_random_spec.mat');
assert(exist('merging_probs_combined','var')==1);
assert(length(merging_probs_combined) == 10);


% Convert the experimental output to BinomialExperiment objects
exps(10)=BinomialExperiment; 
for i = 1:10; 
    mp = merging_probs_combined(i);
    exps(i)=BinomialExperiment(mp.counts(7), mp.num_reps-mp.counts(7), ...
        0.5,0.5); 
end

% Print the table
w = interval_half_width;
fprintf('Index Target Prob Lower Bound Upper Bound Prob In Bounds\n');
for i = 1:10; 
    center=(i-1)/10; 
    lb=max(0,center-w); 
    ub=min(1,center+w); 
    fprintf('%5d %11.1f %11.9f %11.9f %12.2f %% \n', ...
        i,center,lb, ub, 100*exps(i).probThatParamInRange(lb,ub)); 
end

end

