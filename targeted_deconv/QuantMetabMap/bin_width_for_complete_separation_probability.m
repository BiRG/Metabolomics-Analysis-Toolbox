function [width, exp] = bin_width_for_complete_separation_probability( target_probability, num_peaks, min_width, max_width, tolerance, num_reps)
% Return the bin width that will ensure (approximately) that there is the target probability of having num_peaks local maxima in a spectrum generated with num_peaks peaks from the nssd data.
% 
% Usage: width = bin_width_for_complete_separation_probability( target_probability, num_peaks, min_width, max_width, tolerance, num_reps)
%
% IMPORTANT NOTE: to aid debugging & plotting this function uses the global variable
% 'results' to store its intermediate results. This allows me to stop the
% program and immediately recover the current state. It also allows me to
% bootstrap the program using results from previous runs.
%
% The generated spectra are made with 25 intensities per sample width.
%
% Input parameters:
%
% target_probability - the probability of there being num_peaks local
%    maxima in a bin with the returned width
%
% num_peaks - the number of peaks generated in the bin
%
% min_width - the minimum width of bin to consider
%
% max_width - the maximum width of bin to consider must be strictly greater
%             than min_width
%
% tolerance - the first bin width that lies within tolerance of the target
%    probability will be returned
%
% num_reps - the number of repetitions - the number of spectra generated to
%    estimate the probability for a given width
%
% Output parameters:
%
% width - the bin width that should give the chosen probability
%
% exp - the BinomialExperiment object detailing the experimental evidence
%       at that width

intensities_per_width = 25;
acceptance_threshold = 0.95; % Accept a width if there is more than acceptance_threshold probability that it is within range
rejection_threshold = 0.01;  % Reject (and stop intensively exploring) a width if there is less than a rejection_threshold probability that it is within range


global results;

    function c = count_for_width(w)
        % Returns the number of occurrences of complete separation for a bin of width w when num_reps samples were taken
        s = probability_of_peak_merging_in_random_spec(num_peaks, w, num_reps, ceil(intensities_per_width*w), false);
        c = s.counts(num_peaks);
    end

    function print_result(r)
        % Prints a result to a single line of standard output
        interval = r.exp.shortestCredibleInterval(0.95);
        fprintf('%.18g\t%.6g\t%.3f %%\t[ %0.5g - %0.5g ] = %8d\t%8d\n', ...
            r.width, r.exp.prob, 100*r.exp.probThatParamInRange(target_probability-tolerance, target_probability+tolerance), interval.min, interval.max, r.exp.successes, r.exp.trials);
    end

    function idx = index_for_result_with_width(w)
        % Gives the index for a result with width w - creates an empty
        % result if no such result exists
        if isstruct(results)
            result_widths = [results.width];
            are_same_as_new = result_widths == w;
            if any(are_same_as_new)
                idx = find(are_same_as_new);
                assert(length(idx) == 1);
            else
                idx = length(results)+1;

                results(idx).width = w; 
                results(idx).exp = BinomialExperiment(0,0,0.5,0.5); 
            end
        else % Not a struct - so make it one
            results = struct('width',w, 'exp', BinomialExperiment(0,0,0.5,0.5));
            idx = 1;
        end
    end

    function add_reps_to_result(idx)
        % Adds num_reps repetitions to the result at index idx and prints
        % the result to standard output
        results(idx).exp = results(idx).exp.withMoreTrials(count_for_width(results(idx).width), num_reps);
        print_result(results(idx));
    end

    function add_reps_to_result_until_unambiguous(idx)
        % Adds num_reps repetitions to the result at index idx and then 
        % continues adding until its status as a candidate is unambiguous, 
        % that is, until it is 99% certain that the current width is not
        % within tolerance of the target probability. (And prints a comment 
        % line before staring ambiguity removal)
        is_first = true;
        add_reps_to_result(idx);
        chance_in_range = results(idx).exp.probThatParamInRange(target_probability-tolerance, target_probability+tolerance);
        while acceptance_threshold > chance_in_range && chance_in_range > rejection_threshold % Consider it ambiguous if it is between the two thresholds
            if is_first
                fprintf('# Starting deep search to remove ambiguity\n');
                is_first = false;
            end
            add_reps_to_result(idx);
            chance_in_range = results(idx).exp.probThatParamInRange(target_probability-tolerance, target_probability+tolerance);
        end
        if ~is_first
            fprintf('# Ambiguity removed\n');
        end
    end

if ~isempty(results)
    warning('bin_width:results_not_empty', ...
        'The results global variable was not empty on starting the search - skipping initialization to continue previous run');
else
    assert(min_width < max_width);
    add_reps_to_result_until_unambiguous(index_for_result_with_width(min_width));
    add_reps_to_result_until_unambiguous(index_for_result_with_width(max_width));
end

% Algorithm: 
% Take the closest 10 points (or fewer if there are not 10 points yet).
%
% Choose the one of this set that has the least repetitions and add
% repetitons to it, improving its estimate. This lowers the risk of getting
% stuck in a loop because the points from which the new point is derived
% will always be changing, and their estimates will always be improving.
% Additionally, this will happen in a way that tends to make the variance
% of their estimators the same - ensuring better performance from the
% linear fit.
% 
% Now, calculate the best fit line. Calculate the point on that line where 
% the target should lie. Add that point to the list of results, counting 
% the successes in num_reps samples.
%
% Each time repetitons are added to a width, see if it is a candidate for a
% solution (if there is a more than a 1% chance that the value for its 
% parameter is within tolerance units of the target). While it remains a 
% candidate keep adding points. 
%
% Now, check for termination: If there is a 99% chance that the closest
% point is within tolerance units of the target, we're done. Otherwise do 
% another iteration.
%
% A better way to do things would be to look at the point with the highest
% chance that it is within tolerance units of the target rather than the
% closest point. But the closest point is easier to calculate, so I'm doing
% that right now.
should_continue= true;
while(should_continue)
    % Get the closest 10 points
    max_pts_to_get = 10;
    num_pts_to_get = min(max_pts_to_get, length(results));
    experiments = [results.exp];
    dists = [abs([experiments.prob] - target_probability); ...
             1:length(results)];
    dists = sortrows(dists',1);
    indices = dists(1:num_pts_to_get,2);
    selected = results(indices);
    selected_experiments = [selected.exp];
    
    % Find the selected result with the lowest number of reps
    [~, min_rep_sel_idx] = min([selected_experiments.trials]);
    min_rep_orig_idx = indices(min_rep_sel_idx); % Original index of the selected result with the minimum number of repetitions
    
    % Add counts to that result 
    add_reps_to_result_until_unambiguous(min_rep_orig_idx);
    
    % Calculate the best fit line for the closest 10 points (note that the 
    % line fits the function from probabilities to widths) and the new 
    % best width estimate based on that fit
    widths = [selected.width];
    probs = [selected_experiments.prob];
    poly = polyfit(probs, widths, 1);
    new_width = polyval(poly, target_probability);
    
    
    % Add the width to the results list (or just set the index variable if
    % it is already present)
    result_idx = index_for_result_with_width(new_width);
    
    % Add new counts to the selected width
    add_reps_to_result_until_unambiguous(result_idx);
    
    % Find the closest index
    experiments = [results.exp];
    unsorted_dists = [abs([experiments.prob] - target_probability)];
    [~,closest_idx] = min(unsorted_dists);
    
    % Check for termination
    if results(closest_idx).exp.probThatParamInRange(target_probability-tolerance, target_probability+tolerance) > acceptance_threshold
        width = results(closest_idx).width;
        exp = results(closest_idx).exp;
        return;
    end
end

end

