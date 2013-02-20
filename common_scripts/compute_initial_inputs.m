function [BETA0,lb,ub] = compute_initial_inputs(x,y,peak_x,fit_inxs,X)
%Computes starting values for the deconvolution fitting routines
%
% These documentation comments are being put-in after the fact for code
% written by Paul Anderson.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% x        The x values of the spectrum being fit. Should be
%          sorted (decreasing?)
%
% y        The corresponding y values
%
% peak_x   The x values of the peaks. Probably should be all peaks in the 
%          spectrum; might work if just all the peaks in the bin. Should be 
%          sorted (decreasing?).
%
% fit_inxs Not sure: the indices into the x array for those coordinates 
%          that will be used in the eventual integration when called by 
%          curve fit. Looks like the code assumes they are sorted. (One
%          line refers to fit_inxs(1)
%          Seems safe to use 1:length(x)
%
% X        Not sure: The subset of the peak_x values that we want to fit.
%          Should probably be in the same order as peak_x. For most
%          purposes, this should be peak_x
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
% -------------------------------------------------------------------------
% Notes on the observations that lead me to my beliefs about the nature of 
% the input parameters
% -------------------------------------------------------------------------
%
% % compute_initial_values is called one time from Paul's code I have
% % on record: common_scripts/curve_fit.m
% %
% % The call is (including curve-fit's declaration before it:
% 
% function [y_fit,MGPX,baseline_BETA,x_baseline_BETA,converged] = curve_fit(x,y,fit_inxs,X,all_X,far_left,far_right)
% [BETA0,lb,ub] = compute_initial_inputs(x,y,all_X,fit_inxs,X);
% 
% % This is right after the curve fit declaration, so everything
% % comes from the curve fit variables. Curve_fit is called from
% % fix_spectra/normalize_to_reference as:
% 
% [y_fit,MGPX,baseline_BETA,x_baseline_BETA,converged] = curve_fit(collections{c}.x,collections{c}.Y(:,s),fit_inxs,all_X,all_X,left,right);
% 
% % Which puts the following equivalences in place: (items on the
% % left are in the called function and items on the right are in the callee)
% x = collections{c}.x;
% y = collections{c}.Y(:,s);
% fit_inxs = fit_inxs;
% X = all_X;
% all_X = all_X;
% far_left = left;
% far_right = right;
% 
% % The ones we are interested in are the ones passed to
% % compute_initial_inputs:
% x = collections{c}.x;
% y = collections{c}.Y(:,s);
% all_X = all_X;
% fit_inxs = fit_inxs;
% X = all_X;
% 
% % So, we can look for these in the original (the names have not
% % changed except for the collection items, but we know what they are
% % already, the x and y coordinates for spectrum s in collection c.
% %
% % Looking at that code: 
% %
% % all_X is a sorted list of all the peak location parameters in the
% %       spectrum area being deconvolved.
% %
% % fit_inxs is a list of the indexes of the x coordinates that fall
% %          in the range being used as the reference, that is the
% %          x coordinates over which the integration is carried out.
% %
% % X is also a list of peak location parameters - I think it should be in 
% %   the same order as all_X
% 

% Bound minimum height and width starting point
min_M = 0.00001; % Min height starting point
min_G = 0.00001; % Min width starting point

% Compute the initial values for the width/height and offset
BETA0 = [];
lb = [];
ub = [];
% For each peak ppm (or whatever unit) location, put the index of the 
% value closest to it in the x array into the cooresponding slot in
% max_inxs. That means that x(max_inxs(i)) is the closest x value to
% peak_x(i)
max_inxs = zeros(size(peak_x));
for mx_inx = 1:length(max_inxs)
    diff = abs(x - peak_x(mx_inx));
    [unused,inxs] = sort(diff); %#ok<ASGLU>
    max_inxs(mx_inx) = inxs(1);
end
for X_inx = 1:length(X)
    % Inx is the index of the peak at the current x location 
    inx = find(peak_x == X(X_inx));
    
    % ----------------
    % Compute bounds on peak location
    % ----------------
    
    % Compute the upper bound on x0 which is the minimum y value on the left
    % (remember that spectra are plotted with the x axis reversed: 
    % max->min) between the current peak's index and the peak on the left.
    % Unless there are no points to the left of this peak, cannot be this
    % peak.
	index_of_this_peak = max_inxs(inx);
    if inx-1 >= 1
        % The current peak has peaks to the left
        index_of_peak_to_left = max_inxs(inx-1);
    else
        % The current peak is the first peak
        index_of_peak_to_left = fit_inxs(1); % No peak to left, so choose fit_inxs(1)
    end
	left_neighborhood_inxs = index_of_peak_to_left:index_of_this_peak-1;
    if isempty(left_neighborhood_inxs) 
        % When there are no points in the left-side neighborhood, use the
        % peak location itself as the left neighborhood
        left_neighborhood_inxs = max_inxs(inx);
    end
    [unused,ix]=min(y(left_neighborhood_inxs)); %#ok<ASGLU>
    left_inx = left_neighborhood_inxs(ix); % left_inx is the index of the x value at which is the upper bound for peak location for this fitted peak
    ub_x0 = x(left_inx); % ub_x0 is the upper bound for peak location for this fitted peak
    
    % Compute the lower bound on x0 which is the minimum y value on the 
    % between the current peak's index and the peak on the right.
    % Unless there are no points to the right of this peak, cannot be this
    % peak.
    if inx+1 <= length(peak_x)
        % If there are peaks to the right of this peak
        index_of_peak_to_right = max_inxs(inx+1);
    else
        index_of_peak_to_right = fit_inxs(end);
    end
	right_neighborhood_inxs = index_of_this_peak+1:index_of_peak_to_right;
    if isempty(right_neighborhood_inxs)
        % When there are no points in the right-side neighborhood, use the
        % peak location itself as the right neighborhood
        right_neighborhood_inxs = max_inxs(inx);
    end
    [unused,ix]=min(y(right_neighborhood_inxs)); %#ok<ASGLU>
    right_inx = right_neighborhood_inxs(ix); % right_inx is the index of the x value at which is the lower bound for peak location for this fitted peak
    lb_x0 = x(right_inx); % lb_x0 is the lower bound for peak location for this fitted peak

    % Estimate the starting height of the peak as the size of the bump it
    % makes. Assume there is a bump between the previous peak and the next
    % one. Then the difference between the lowest height in the region
    % and the highest in the region is a good estimate for the height of
    % our peak.
    g_M = calc_height(left_inx:right_inx,y);  % Initial peak height
    
    % Finds the y value closest to half the maximum in the interval and
    % uses its x-distance from the maximum as the estimate of the peak
    % width.
    g_G = calc_width(left_inx:right_inx,x,y); % Initial peak width
    
    % Initial values for peaks cannot be wider than they are tall
    if g_G > g_M
        g_G = g_M;
    end
    
    % Initial value for Lorentzianness is 0.5
    g_P = 0.5;
    
    % When there is no range for improvement for peak location, give it 1
    % sample's worth of wiggle room
    if lb_x0 == ub_x0
        width = abs(x(1)-x(2));
        lb_x0 = lb_x0 - width/2;
        ub_x0 = ub_x0 + width/2;
    end
    
    % Initial values are height = g_M, width = g_G, Lorentzianness = 0.5,
    % x0 = the current value for this peak
    BETA0 = [BETA0;max([g_M,min_M]);max([g_G,min_G]);g_P;X(X_inx)];
    
    % Lower bounds are 0 for everything except location where it is the
    % previously computed location lower bound.
    lb = [lb;0;0;0;lb_x0];
    
    % Uper bounds are height = maximum y on the interval being fit, width =
    % width of interval being fit, lorentzianness = 1, and location = 
    % the previously computed location upper bound.
    ub = [ub;max(y(fit_inxs));...
        2*abs(x(fit_inxs(1))-x(fit_inxs(end)));1;ub_x0];
end