function peaks = auto_summit_deconvolve_pos_resid( x, y, num_neighbors, smallest_peak_height, noise_std, progress_func )
% Does a summit-focused deconvolution of region given by x,y
%
% Usage: peaks = auto_summit_deconvolve_pos_resid( x, y, num_neighbors, smallest_peak_height, noise_std, progress_func )
% 
% Does a greedy fit, starting with the highest peak x's of 1 peak at a
% time, looking only at the points near the x location of that peak. Stops
% when the largest residual is less than the snr (calculated as a fraction
% of the height of the largest point in the spectrum.
%
% x - the x coordinates of the spectrum segment to deconvolve 
%
% y - the y coordinates of the spectrum segment to deconvolve - correspond
% to the xs
%
% num_neighbors - the number of samples to use for the neighbors of the
% peak that will be looked at in doing the optimization. The closest
% num_neighbors neighbors will be used (or if num_neighbors is greater than
% the number of available points in the interval, all points will be used)
%
% smallest_peak_height - the height of the smallest peak to fit - will stop
% adding peaks when the peak would be smaller than this height. 5 or 6 
% noise_std seems a good value for this
%
% noise_std - the standard deviation of the noise regions in the spectrum
%
% progress_func (optional) - A function handle called every iteration.
% It is called with the parameters: 
% progress_func(frac_done, pass_num, peak_num, num_peaks). frac_done is the 
% estimated completion fraction and will be a double in the closed interval
% [0..1]. pass_num is the number of the peak-parameter refinement pass 
% being completed. peak_num is the number of next peak whose parameters 
% will be adjusted. num_peaks is the number of peaks in the current fit. A 
% suggested use for progress_func is to update a waitbar. If omitted, no 
% function is called.
%
% Returns an array of GaussLorentzPeak objects

function val=penalty(local_x, local_rem, global_x, global_rem, params, x0, noise_std)
    glp = GaussLorentzPeak([params, x0]);
    
    % Calculate the regularization - penalize negative values more than
    % num_std noise standard deviations below 0
    num_std = 4;
    val = (global_rem - glp.at(global_x)) + num_std*noise_std;
    val(val > 0) = 0;
    val = sum((val/noise_std).^4);
    
    % Add the penalty for misfit in the local neighborhood: the local 
    % remainder at that point minus the current peak's value at that point
    val = val + sum(abs(local_rem-(glp.at(local_x))).^2);
end

% Take care of optional arguments
if ~exist('progress_func', 'var')
    progress_func = @do_nothing; 
end


% Sort x (and put y in the same order)
if all(size(x) ~= size(y))
    y = y';
end
assert(all(size(x) == size(y)));

[x, order] = sort(x);
y = y(order);

highest_peak = max(y);
residuals = y; % With no peaks, the residual is just the original values
pass = 1;
finishing_passes_to_make = 2; % Do this many finishing passes to fine-tune the peaks after all peaks have been added
remaining_finishing_passes=finishing_passes_to_make;
while(remaining_finishing_passes > 0)
    if max(residuals) >= smallest_peak_height 
        if pass > 1
            new_idx = length(peak_x)+1; % Index of the new peak
        else
            new_idx = 1; % First pass, there is no peak_x array to take the length of
        end
 
        remaining_finishing_passes=finishing_passes_to_make;
        % Add a new peak at the current residual maximum
        peak_x(new_idx) = x(residuals == max(residuals)); %#ok<AGROW>
        peaks(new_idx) = GaussLorentzPeak([0,0.5,0.5,peak_x(end)]); %#ok<AGROW>

        % Calculate the neighborhood of that peak (which is now the last peak)
        distances = abs(x-peak_x(end));
        [~, order] = sort(distances);
        peak_neighborhood_x{new_idx} = x(order); %#ok<AGROW>
        peak_neighborhood_y{new_idx} = y(order); %#ok<AGROW>
        if(length(peak_neighborhood_x{new_idx}) > num_neighbors) 
            peak_neighborhood_x{new_idx} = peak_neighborhood_x{new_idx}(1:num_neighbors); %#ok<AGROW>
            peak_neighborhood_y{new_idx} = peak_neighborhood_y{new_idx}(1:num_neighbors); %#ok<AGROW>
        end
        [peak_neighborhood_x{new_idx},order] = sort(peak_neighborhood_x{new_idx}); %#ok<AGROW>
        peak_neighborhood_y{new_idx} = peak_neighborhood_y{new_idx}(order); %#ok<AGROW>
    else
        remaining_finishing_passes = remaining_finishing_passes - 1;
        new_idx = -1;
    end
    
    % Refit all the peaks, starting and ending with the newly added one
    for peak_idx = [length(peak_x):-1:1,length(peak_x)]
        max_residuals = max(residuals);
        progress = max(0,highest_peak - max_residuals)/max(0,highest_peak - smallest_peak_height);
        expected_passes = pass+remaining_finishing_passes;
        if remaining_finishing_passes < finishing_passes_to_make
            expected_passes = expected_passes + 1;
        end
        progress = progress*pass/expected_passes;
        progress_func(progress, pass, peak_idx, length(peak_x));

        local_x = peak_neighborhood_x{peak_idx};
        local_y = peak_neighborhood_y{peak_idx};
        local_sum = sum(peaks.at(local_x),1)-peaks(peak_idx).at(local_x); % Sum of all peaks but this one (really sum of all peaks - value of this peak)
        local_rem = local_y - local_sum; % Remainder in the neighborhood
         
        % Compute the non-local x and y (called global here) for use in the
        % regularization term
        [global_x, global_x_idx] = setdiff(x, local_x);
        global_y = y(global_x_idx);
        global_rem = global_y - sum(peaks.at(global_x)) + peaks(peak_idx).at(global_x); 

        % Do the minimization
        p = peaks(peak_idx);
        x0 = local_x(local_rem == max(local_rem));
        M = interp1(local_x, local_rem, x0); %Start the peak at the peak value for its remainder
        if peak_idx == new_idx
            % First pass, don't let the peak x move
            err_fun=@(params) penalty(local_x, local_rem, global_x, global_rem, params, p.x0, noise_std);
            new_params = fminsearch(err_fun, [M, p.G, p.P],optimset('Display','off'));
            peaks(peak_idx)=GaussLorentzPeak([new_params, p.x0]); %#ok<AGROW>
            new_idx = -1; % No longer new - it has now been fit
        else
            % Subsequently, let it move
            err_fun=@(params) penalty(local_x, local_rem, global_x, global_rem, params(1:3), params(4), noise_std);
            new_params = fminsearch(err_fun, [M, p.G, p.P, x0],optimset('Display','off'));
            peaks(peak_idx)=GaussLorentzPeak(new_params); %#ok<AGROW>
        end

        % *****************************************************************
        % Uncomment the following to get nice graphical plots of debugging
        % and current point each iteration
        % *****************************************************************
%         quick_plot_bin(x, y, peaks);
%         % hold on; plot(local_x, local_rem, 'm'); hold off;
%         uiwait(msgbox(sprintf('Done with peak %d pass %d. Click to continue.', peak_idx, pass)));
%         p=peaks(peak_idx);
%         fprintf('Cur [M G P x0]: %g %g %g %g\n', p.M, p.G, p.P, p.x0);
    end
    residuals = y-sum(peaks.at(x),1);
    pass = pass + 1;
end

end
