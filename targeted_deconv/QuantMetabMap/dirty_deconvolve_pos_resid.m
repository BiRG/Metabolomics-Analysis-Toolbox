function peaks = dirty_deconvolve_pos_resid( x, y, peak_x, num_neighbors, noise_std, progress_func )
% Does a quick and dirty deconvolution of region given by x,y if the peaks have location parameters peak_x
% 
% Usage: peaks = dirty_deconvolve_pos_resid( x, y, peak_x, num_neighbors, noise_std, iter_func )
%
% Does a greedy fit, starting with the highest peak x's of 1 peak at a
% time, looking only at the points near the x location of that peak. Now
% includes a regularization that penalizes negative residuals for the rest
% of the spectrum. Negative residuals are assigned a score by dividing by
% the noise standard deviation, subtracting 4 and then raising to the 4'th 
% power if the result is still negative. 
%
% x - the x coordinates of the spectrum segment to deconvolve 
%
% y - the y coordinates of the spectrum segment to deconvolve - correspond
% to the xs
%
% peak_x - the x coordinates of the different peaks
%
% num_neighbors - the number of samples to use for the neighbors of the
% peak that will be looked at in doing the optimization. The closest
% num_neighbors neighbors will be used (or if num_neighbors is greater than
% the number of available points in the interval, all points will be used)
%
% noise_std - the standard deviation of the noise regions in the spectrum
%
% progress_func (optional) - A function handle called every iteration.
% It is called with the parameters: 
% progres_func(frac_done, pass_num, peak_num). frac_done is the estimated
% completion fraction and will be a double in the closed interval [0..1]. 
% pass_num is the number of the peak-parameter refinement pass being
% completed. peak_num is the number of next peak whose parameters will be
% adjusted. A suggested use for progress_func is to update a waitbar. If
% omitted, no function is called.
%
% Returns an array of GaussLorentzPeak objects

function val=penalty(local_x, local_rem, global_x, global_rem, params, x0, noise_std)
    glp = GaussLorentzPeak([params, x0]);
    peak_height = glp.at(local_x);
    
    val = (local_rem - peak_height).^2/length(peak_height);
    val = sqrt(sum(val));
end

if ~exist('progress_func', 'var')
    progress_func = @do_nothing; 
end

assert(noise_std > 0);

% Sort x (and put y in the same order)
if all(size(x) ~= size(y))
    y = y';
end
assert(all(size(x) == size(y)));

[x, order] = sort(x);
y = y(order);

% Also sort peak_x
peak_x = sort(peak_x);

% Calculate the nearest neighbors each peak
peak_neighborhood_x=cell(length(peak_x),1);
peak_neighborhood_y=cell(length(peak_x),1);
for i = 1:length(peak_x)
    distances = abs(x-peak_x(i));
    [~, order] = sort(distances);
    neighbors_x = x(order);
    neighbors_y = y(order);
    if(length(neighbors_x) > num_neighbors)
        neighbors_x = neighbors_x(1:num_neighbors);
        neighbors_y = neighbors_y(1:num_neighbors);
    end
    peak_neighborhood_x{i} = neighbors_x;
    peak_neighborhood_y{i} = neighbors_y;
end
clear i;

% Start with 0 height peaks at the correct x values
initial_peak_params = repmat([0, 0.5, 0.5, 0],1,length(peak_x));
initial_peak_params(4:4:4*length(peak_x))=peak_x;
peaks = GaussLorentzPeak(initial_peak_params);

% Find out the heights at the initial peak coordinates
peak_heights = interp1(x, y, peak_x);
[~, peak_fit_order] = sort(peak_heights,'descend');

num_passes = 3;
fit_ops_total = num_passes * length(peak_x);
fit_ops_complete = 0;
for pass = 1:num_passes
    for peak_to_fit_idx = 1:length(peak_x)
        progress_func(fit_ops_complete/fit_ops_total, pass, peak_to_fit_idx);
        
        peak_idx = peak_fit_order(peak_to_fit_idx);
        [local_x,order] = sort(peak_neighborhood_x{peak_idx});
        local_y = peak_neighborhood_y{peak_idx}(order);
        local_sum = sum(peaks.at(local_x))-peaks(peak_idx).at(local_x); % Sum of all peaks but this one (really sum of all peaks - value of this peak)
        local_rem = local_y - local_sum; % Remainder in the neighborhood
        
        % Compute the non-local x and y (called global here) for use in the
        % regularization term
        [global_x, global_x_idx] = setdiff(x, local_x);
        global_y = y(global_x_idx);
        global_rem = global_y - sum(peaks.at(global_x)) + peaks(peak_idx).at(global_x); 

        % Rescale other peaks if they are completely obscuring the peak -
        % assume that all marked peaks are really at least 1 noise_std high
        p = peaks(peak_idx);
        rough_peak_height = interp1(local_x, local_rem, p.x0); 
        if rough_peak_height < 1*noise_std
            % Calculate how much to rescale by
            max_pt_sum = sum(peaks.at(p.x0));
            new_sum = max(0,interp1(local_x, local_y, p.x0)-1 * noise_std); % After scaling, the remainder at the peak will be exactly 5 noise std high - which probably underestimates the peak height
            if new_sum > 0
                multiplier = new_sum / max_pt_sum;

                % Rescale other peak heights
                this_peak = peaks(peak_idx);
                peak_property_array=peaks.property_array();
                peak_property_array(1:4:length(peak_property_array))= ...
                    peak_property_array(1:4:length(peak_property_array))* multiplier;
                peaks = GaussLorentzPeak(peak_property_array);
                peaks(peak_idx) = this_peak;

                % Recalculate the remainder
                local_sum = sum(peaks.at(local_x))-peaks(peak_idx).at(local_x);
                local_rem = local_y - local_sum;
                global_rem = global_y - sum(peaks.at(global_x)) + peaks(peak_idx).at(global_x); 
            end
            
            % Get rid of temporary variables (wish matlab had lexical scope)
            clear('max_pt', 'max_pt_select', 'max_pt_sum', 'new_sum', 'peak_property_array', 'multiplier', 'this_peak');
        end
        
        % Do the minimization
        p = peaks(peak_idx);
        if pass == 1
            M = interp1(local_x, local_rem, p.x0); %Start the peak at the peak value for its remainder
        else
            M = p.M; % After the first round, set the peak height to what it was in the last round
        end
        err_fun=@(params) penalty(local_x, local_rem, global_x, global_rem, params, p.x0, noise_std);
        new_params = fminsearch(err_fun, [M, p.G, p.P],optimset('Display','off'));
        peaks(peak_idx)=GaussLorentzPeak([new_params, p.x0]);
        
        fit_ops_complete=fit_ops_complete+1;

        % *****************************************************************
        % Uncomment the following to get nice graphical plots of debugging
        % and current point each iteration
        % *****************************************************************
%         quick_plot_bin(x, y, peaks);
%         uiwait(msgbox(sprintf('Done with peak %d pass %d. Click to continue.', peak_idx, pass)));
%         p=peaks(peak_idx);
%         fprintf('Cur [M G P x0]: %g %g %g %g\n', p.M, p.G, p.P, p.x0);
    end
end

end