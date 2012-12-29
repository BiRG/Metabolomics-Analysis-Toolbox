function [width,final_count_for_width,reps_for_width] = bin_width_for_complete_separation_probability( target_probability, num_peaks, min_width, max_width, tolerance, num_reps, num_intensities)
% Return the bin width that will ensure (approximately) that there is the target probability of having num_peaks local maxima in a spectrum generated with num_peaks peaks from the nssd data.
% 
% Usage: width = bin_width_for_complete_separation_probability( target_probability, num_peaks, min_width, max_width, tolerance, num_reps, num_intensities)
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
% max_width - the maximum widht of bin to consider
%
% tolerance - the first bin width that lies within tolerance of the target
%    probability will be returned
%
% num_reps - the number of repetitions - the number of spectra generated to
%    estimate the probability for a given width
%
% num_intensities - the number of intensities to use in the generated
%    spectra
%
% Output parameters:
%
% width - the bin width that should give the chosen probability

% Note: because I am estimating a proportion, the credible and confidence
% intervals approximately coincide - the proportion is a mean which is a 
% location parameter and I am starting with a uniform prior. I lose a
% little by not updating my prior each time, but I gain that in procedural 
% simplicity.

    function c = count_for_width(w)
        % Returns the number of occurrences of complete separation for a bin of width w when num_reps samples were taken
        s = probability_of_peak_merging_in_random_spec(num_peaks, w, num_reps, num_intensities, false);
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
results(1).width = min_width;
results(1).count = count_for_width(min_width);
results(1).reps = num_reps;
results(1).prob = results(1).count/num_reps;
print_result(results(1));

results(2).width = max_width;
results(2).count = count_for_width(max_width);
results(2).reps = num_reps;
results(2).prob = results(2).count/num_reps;
print_result(results(2));

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
    result_widths = [results.width];
    are_same_as_new = result_widths == new_width;
    if any(are_same_as_new)
        result_idx = find(are_same_as_new);
        assert(length(result_idx) == 1);
    else
        result_idx = length(results)+1;
        
        results(result_idx).width = new_width; %#ok<AGROW>
        results(result_idx).count = 0; %#ok<AGROW>
        results(result_idx).reps = 0; %#ok<AGROW>
        results(result_idx).prob = 0; %#ok<AGROW>
    end
    
    % Add new counts to the selected width
    results(result_idx).count = results(result_idx).count + count_for_width(new_width);%#ok<AGROW>
    results(result_idx).reps = results(result_idx).reps + num_reps;                    %#ok<AGROW>
    results(result_idx).prob = results(result_idx).count/results(result_idx).reps;     %#ok<AGROW>
    print_result(results(result_idx));
    
    % Find the index of the closest point to the target
    dists = [abs([results.prob] - target_probability); ...
             1:length(results)];
    dists = sortrows(dists',1);
    closest_idx = dists(1,2);
    
    % Add counts to the closest point
    results(closest_idx).count = results(closest_idx).count + count_for_width(new_width);%#ok<AGROW>
    results(closest_idx).reps = results(closest_idx).reps + num_reps;                    %#ok<AGROW>
    results(closest_idx).prob = results(closest_idx).count/results(closest_idx).reps;    %#ok<AGROW>
    print_result(results(closest_idx));
    
    % Check for termination
    if half_interval(results(closest_idx)) < tolerance && abs(target_probability - results(closest_idx).prob) < tolerance
        width = results(closest_idx).width;
        final_count_for_width = results(closest_idx).count;
        reps_for_width = results(closest_idx).reps;
        return;
    end
end

end

