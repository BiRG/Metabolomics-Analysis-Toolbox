function [width,final_count_for_width,reps_for_width] = bin_width_for_complete_separation_probability( target_probability, num_peaks, min_width, max_width, tolerance, num_reps)
% Return the bin width that will ensure (approximately) that there is the target probability of having num_peaks local maxima in a spectrum generated with num_peaks peaks from the nssd data.
% 
% Usage: width = bin_width_for_complete_separation_probability( target_probability, num_peaks, min_width, max_width, tolerance, num_reps)
%
% IMPORTANT NOTE: to aid debugging & plotting this function uses the global variable
% results to store its intermediate results. This allows me to stop the
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

% Note: because I am estimating a proportion, the credible and confidence
% intervals approximately coincide - the proportion is a mean which is a 
% location parameter and I am starting with a uniform prior. I lose a
% little by not updating my prior each time, but I gain that in procedural 
% simplicity.

intensities_per_width = 25;

global results;

    function c = count_for_width(w)
        % Returns the number of occurrences of complete separation for a bin of width w when num_reps samples were taken
        s = probability_of_peak_merging_in_random_spec(num_peaks, w, num_reps, ceil(intensities_per_width*w), false);
        c = s.counts(num_peaks);
    end

    function w = half_interval(r)
        % Takes a results entry and returns the distance from the probability to either end of the 95% credible interval
        w = 1.959963984540054*sqrt(r.prob*(1-r.prob)/r.reps);
    end

    function print_result(r)
        % Prints a result to a single line of standard output
        fprintf('%.18g\t%.18g\t+/- %0.5g = %8d\t%8d\n', ...
            r.width, r.prob, half_interval(r), r.count, r.reps);
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
                results(idx).count = 0; 
                results(idx).reps = 0; 
                results(idx).prob = 0; 
            end
        else % Not a struct - so make it one
            results = struct('width',w,'count',0,'reps',0,'prob',0);
            idx = 1;
        end
    end

    function add_reps_to_result(idx)
        % Adds num_reps repetitions to the result at index idx and prints
        % the result to standard output
        results(idx).count = results(idx).count + count_for_width(results(idx).width);
        results(idx).reps = results(idx).reps + num_reps;
        results(idx).prob = results(idx).count/results(idx).reps;
        print_result(results(idx));
    end

    function add_reps_to_result_until_unambiguous(idx)
        % Adds num_reps repetitions to the result at index idx and then 
        % continues adding until its status as a candidate is unambiguous, 
        % that is, until it is either a solution or until its 95% 
        % confidence interval does not contain the target value. (And 
        % prints a comment line first)
        is_first = true;
        add_reps_to_result(idx);
        while abs(results(idx).prob-target_probability) < half_interval(results(idx)) && ... %CI includes target probability
                tolerance < half_interval(results(idx))                                      %CI is larger than tolerance
            if is_first
                fprintf('# Starting deep search to remove ambiguity\n');
                is_first = false;
            end
            add_reps_to_result(idx);
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
% Take the closest 10 points (or fewer if there are not 10 points yet) and
% calculate the best fit line. Calculate the point on that line where the
% target should lie. Add that point to the list of results, counting the
% successes in num_reps samples.
%
% Look through the list for the width which is closest to the target. Shrink 
% the credible interval by running another num_reps samples (do this no 
% matter what because the closest point is guaranteed to be in the list of
% points we use in the next iteration - this makes it a more accurate
% estimate the random variation in the closest point should also help to 
% keep the algorithm from getting stuck in a loop). If its credible 
% interval contains the target and if the distance from the end of the 
% credible interval to the proportion estimate is less than tolerance, 
% we're done. Otherwise do another iteration.
%
% Stop when the closest point credible interval both contains the target
% probability AND half that interval is smaller than tolerance.
should_continue= true;
while(should_continue)
    % Get the closest 10 points
    max_pts_to_get = 10;
    num_pts_to_get = min(max_pts_to_get, length(results));
    dists = [abs([results.prob] - target_probability); ...
             1:length(results)];
    dists = sortrows(dists',1);
    indices = dists(1:num_pts_to_get,2);
    selected = results(indices);
    
    % Calculate the best fit line (note that it is for the function from
    % probabilities to widths) and the new best width estimate based on
    % that fit
    widths = [selected.width];
    probs = [selected.prob];
    poly = polyfit(probs, widths, 1);
    new_width = polyval(poly, target_probability);
    
    
    % Add the width to the results list (or just set the index variable if
    % it is already present)
    result_idx = index_for_result_with_width(new_width);
    
    % Add new counts to the selected width
    add_reps_to_result_until_unambiguous(result_idx);
    
    % Find the index of the closest point to the target
    dists = [abs([results.prob] - target_probability); ...
             1:length(results)];
    dists = sortrows(dists',1);
    closest_idx = dists(1,2);
    
    % Add counts to the closest point
    add_reps_to_result_until_unambiguous(closest_idx);
    
    % Check for termination
    if half_interval(results(closest_idx)) < tolerance && abs(target_probability - results(closest_idx).prob) < tolerance
        width = results(closest_idx).width;
        final_count_for_width = results(closest_idx).count;
        reps_for_width = results(closest_idx).reps;
        return;
    end
end

end

