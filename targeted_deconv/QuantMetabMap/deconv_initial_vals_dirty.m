function [BETA0,lb,ub] = deconv_initial_vals_dirty(x,y, region_min, region_max, peak_xs, num_neighbors)
%Computes starting values for the deconvolution fitting routines using dirty_deconv
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% x        The x values of the spectrum being fit
%
% y        The corresponding y values
%
% region_min The minimum x value of the region being deconvolved
%
% region_max The maximum x value in the region being deconvolved
%
% peak_xs   The x values of the peaks
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
bx = x(x_in_region);
by = y(x_in_region);
peaks = dirty_deconvolve_pos_resid(bx, by, peak_xs, num_neighbors, noise_std);

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
    bounds = (locs(1:end-1)+locs(2:end))/2;
    bounds = [max(region_min, locs(1)-abs(locs(1)-bounds(1))) ...
        ,bounds, ...
        min(region_max, locs(end)+abs(locs(end)-bounds(end)))];
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
outlier_width = prctile(trial_widths, 75)+3*iqr(trial_widths);


for i = 1:length(peaks)
    % Set minimum and maximum x0 - the region bounds
    b = loc_for_peak(i); % The index into the bounds array corresponding to the minimum of the interval containing peak i
    lb(i*4-0) = bounds(b);
    ub(i*4-0) = bounds(b+1);
    
    
    % Minimum/Maximum height
    x_in_region = x >= bounds(b) & x <= bounds(b+1);
    lb(i*4-3) = 0; 
    ub(i*4-3) = max(y(x_in_region)); 
    
    % Minimum/Maximum half-width
    lb(i*4-2) = 0;
    ub(i*4-2) = outlier_width;
    assert(ub(i*4-2) >= 0);
    
    % Minimum/Maximum Lorentzianness
    lb(i*4-1) = 0;
    ub(i*4-1) = 1;
end

end