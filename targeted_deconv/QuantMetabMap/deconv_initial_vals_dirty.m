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
peaks = dirty_deconvolve(x, y, peak_xs, num_neighbors);

BETA0 = peaks.property_array';

% Preallocate lower and upper bound arrays
lb = zeros(size(BETA0));
ub = lb;

% Set the location bounds to half-way to the nearest neighbor (and equal
% distance on the other side for the peaks without neighbors on one side
locs = [peaks.x0];
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
    
for i = 1:length(peaks)
    % Set minimum and maximum x0 - the region bounds
    lb(i*4-0) = bounds(i);
    ub(i*4-0) = bounds(i+1);
    
    
    % Minimum/Maximum height
    x_in_region = x >= bounds(i) & x <= bounds(i+1);
    lb(i*4-3) = 0; 
    ub(i*4-3) = max(y(x_in_region)); 
    
    % Minimum/Maximum half-width
    lb(i*4-2) = 0;
    ub(i*4-2) = 2*(bounds(i+1)-bounds(i)); %Half width at most twice distance between peaks
    assert(ub(i*4-2) == 0);
    
    % Minimum/Maximum Lorentzianness
    lb(i*4-1) = 0;
    ub(i*4-1) = 1;
end

end