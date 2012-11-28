function [BETA0,lb,ub] = deconv_initial_vals_dirty(x,y, region_min, region_max, peak_xs, num_neighbors, progress_func)
%Computes starting values for the deconvolution fitting routines using dirty_deconv
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% x        The x values of the spectrum being fit (must be non-empty)
%
% y        The corresponding y values
%
% region_min The minimum x value of the region being deconvolved
%
% region_max The maximum x value in the region being deconvolved
%
% peak_xs   The x values of the peaks
%
% progress_func (optional) A function handle. It is called with parameters: 
% progres_func(frac_done, pass_num, peak_num). frac_done is the estimated
% completion fraction and will be a double in the closed interval [0..1]. 
% pass_num is the number of the peak-parameter refinement pass being
% completed. peak_num is the number of next peak whose parameters will be
% adjusted. A suggested use for progress_func is to update a waitbar. If
% omitted, no function is called.
%
% num_neighbors The number of neighbor pixels used in the dirty
% deconvolution
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% BETA0              A 1 dimensional array of doubles.
%
%                    Every 4 items are the starting parameters for one peak
%                    in the order M, G, P, x0.
%
%                    M  is the height parameter
%                    G  is the width parameter,
%                    P  is the proportion of Lorenzianness (1=lorenzian,
%                       0=gaussian)
%                    x0 is the location parameter, the location of the 
%                       peak.
%
% lb                 The lower bound on the corresponding entry in BETA0
%                    -- used in constraining the optimization
%
% ub                 The upper bound on the corresponding entry in BETA0
%                    -- used in constraining the optimization
%

% Deal with optional arguments
if ~exist('progress_func', 'var')
    progress_func = @do_nothing; 
end

% Calculate initial peak parameters
peak_xs = peak_xs(peak_xs <= region_max & peak_xs >= region_min);
noise_std_pts = min(100, length(x)/10);
if ~issorted(-x)
    [x, order] = sort(x,'descend');
    y = y(order);
    clear('order');
end
noise_std = std(y(1:noise_std_pts));
x_in_region = x <= region_max & x >= region_min;
bx = x(x_in_region); % x values in bin, thus bx
by = y(x_in_region); % y values in bin
peaks = dirty_deconvolve_pos_resid(bx, by, peak_xs, num_neighbors, ...
    noise_std, progress_func);

BETA0 = peaks.property_array';

% Preallocate lower and upper bound arrays
lb = zeros(size(BETA0));
ub = lb;

% Set the location bounds to half-way to the nearest neighbor (and equal
% distance on the other side for the peaks without neighbors on one side
[locs, peak_for_loc] = sort([peaks.x0]);
[~, loc_for_peak] = sort(peak_for_loc);

assert(issorted(locs));

if length(locs) > 1
    % Most bounds are the midpoints
    bounds = (locs(1:end-1)+locs(2:end))/2;
    % Now set up the non-end-point bounds
    % First, find the median length of an inter-peak interval
    interval_widths = abs(locs(2:end)-(locs(1:end-1)));
    median_i_width = median(reshape(interval_widths,[],1));
    % Then make a buffer of half that on either side of the end peaks
    bounds = [max(region_min, locs(1)-median_i_width/2) ...
        ,bounds, ...
        min(region_max, locs(end)+median_i_width/2)];
elseif length(locs) == 1
    bounds = [region_min, region_max];
else 
    error('deconv_initial_vals_dirty:at_least_one_peak', ...
        'You must have at least one peak to deconvolve.');
end
assert(length(bounds) == length(locs)+1);

% Outlier half-height width is the extreme outlier bound for quartiles:
% 75th percentile + 3 IQR. No peak should be wider than this unless the
% initial estimates were surpassingly bad.
trial_widths = [peaks.half_height_width];
if length(trial_widths) > 1
    outlier_width = prctile(trial_widths, 75)+3*iqr(trial_widths);
elseif length(trial_widths) == 1
    outlier_width = 2*trial_widths(1); % If there is only one peak, let the main optimization routine grow it twice as wide, if necessary
else
    error('deconv_initial_vals_dirty:at_least_one_peak',['There must be '...
        'at least one peak in the interval passed to ' ...
        'deconv_initial_vals_dirty']);
end


for i = 1:length(peaks)
    % Find the boundaries around the current peak - taking care of the
    % possible but degenerate situation where adjacent peaks have the same 
    % x coordinate
    b = loc_for_peak(i); % The index into the bounds array corresponding to the minimum of the interval containing peak i
    cur_bound = bounds(b);
    next_bound_idx = b+1;
    next_bound = bounds(next_bound_idx);
    
    while next_bound == cur_bound
        if  next_bound_idx + 1 <= length(bounds)
            next_bound_idx = next_bound_idx + 1;
            next_bound = bounds(next_bound_idx);
        end
    end
    while next_bound == cur_bound
        if  b - 1 >= 1
            b = b - 1;
            cur_bound = bounds(b);
        end
    end
    
    % Set minimum and maximum x0 - the region bounds
    lb(i*4-0) = cur_bound;
    ub(i*4-0) = next_bound;
    
    
    % Minimum/Maximum height
    x_in_region = x >= cur_bound & x <= next_bound;
    if isempty(x_in_region)
        x_in_region = x;
    end
    ub(i*4-3) = max(y(x_in_region)); 
    if length(trial_widths) > 1
        lb(i*4-3) = 0; 
    else
        % For a single peak, the local deconvolution will be quite
        % accurate, set it as a lower bound
        lb(i*4-3) = max(0, peaks(1).height);
    end
    
    % Minimum/Maximum half-width
    lb(i*4-2) = 0;
    ub(i*4-2) = outlier_width;
    assert(ub(i*4-2) >= 0);
    
    % Minimum/Maximum Lorentzianness
    lb(i*4-1) = 0;
    ub(i*4-1) = 1;
end

end