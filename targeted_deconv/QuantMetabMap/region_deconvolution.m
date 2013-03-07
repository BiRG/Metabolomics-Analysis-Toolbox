function [BETA,baseline_BETA,fit_inxs,y_fit,y_baseline,R2,peak_inxs,peak_BETA] = region_deconvolution(x,y,BETA0,lb,ub,x_baseline_width,region,model,progress_func)
% Deconvolves a region of a spectrum
%
% Usage: [BETA,baseline_BETA,fit_inxs,y_fit,y_baseline,R2,peak_inxs,peak_BETA] = region_deconvolution(x,y,BETA0,lb,ub,x_baseline_width,region,model,progress_func)
%
% This is code modified from Paul Anderson.  These comments 
% were first added as part of exploring the code.
%
% ------------------------------------------------------------------------
% Input Arguments
% ------------------------------------------------------------------------
%
% x                  The x values for the input spectrum (frequently ppm)
%
% y                  The y values for the input spectrum
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
%
% ub                 The upper bound on the corresponding entry in BETA0
%
% x_baseline_width   Not sure about this, probably the interval between the
%                    points that can be adjusted on the baseline
%
% region             The region to deconvolve - given as a pair:
%                    [max x, min x]
%
% model              A RegionalSpectrumModel giving the assumptions for
%                    this deconvolution
%
% progress_func      (optional) Called every iteration of the optimization 
%                    engine with a single parameter. progress_func(frac) 
%                    where frac is the estimated fraction of completion.
%
% ------------------------------------------------------------------------
% Output Parameters
% ------------------------------------------------------------------------
%
% BETA               The parameters of the peaks (see BETA0).  Will have
%                    the same dimensions as BETA0
%
% baseline_BETA      The parameters of the baseline.  Maybe the heights of
%                    the baseline at the control points?
%
% fit_inxs           The indices over which the fit took place.  So you can
%                    plot(x(fit_inxs), y_fit) to get the fitted curve
%
% y_fit              The fitted points, a 1d array of doubles of same
%                    dimension as fit_inxs covering the x's in the region
%
% y_baseline         The calculated baseline values for each of the fitted
%                    indices
%
% R2                 A fit quality metric.  If s is the sum of squared 
%                    error for the fit and v is the variance of the 
%                    original function.  R2=1-s/v.  R2 of 1 is a perfect 
%                    fit.  Note that R2 can conceivably be negative for a 
%                    very bad fit (no such fit will likely be forthcoming 
%                    from this program on normal NMR data, though.)
%
% peak_inxs          The peak numbers that were in the region.  You should
%                    be able to do BETA(4*(peak_inxs)+variable) to get a
%                    slice of that sub-variable for all the peaks in the
%                    region.  (M is -3, G is -2, etc)
%
% peak_BETA          The values of the deconvolved peaks
%
% ------------------------------------------------------------------------
% Example Code:
% ------------------------------------------------------------------------
% TODO: update example to include RegionalSpectrumModel
% 
% region_left = 8.6;
% region_right = 8.41;
% x_baseline_width = 0.6;
%
% [BETA0,lb,ub] = compute_initial_inputs(x,y,maxes_x,1:length(x),maxes_x);
%
% [BETA,baseline_BETA,fit_inxs,y_fit,y_baseline,R2,peak_inxs,peak_BETA] =...
%   region_deconvolution(x, y, BETA0, lb, ub, x_baseline_width,...
%                        [region_left;region_right] );
%
% %Plot original, fitted, and baseline
% plot(x(fit_inxs),y(fit_inxs),x(fit_inxs),y_fit,x(fit_inxs),y_baseline);
BETA = BETA0;

fit_inxs = find(region(1) >= x & x >= region(2)); % To do: this should adapt to the location of the maxima
y_region = y(fit_inxs);
x_region = x(fit_inxs);

% TODO: remove all references to inxs by simplifying the code to just use all entries
%
% inxs is a hold-over from an earlier version in which not all input peaks
% were used. If the peaks are given one spot each in an array, inxs is the
% list of the indices of the used peaks. Since all peaks are now used, inxs
% is just a list of 1:num_peaks. Eventually, this should be removed because
% it adds extra complexity to the code. But I will not do it now.
inxs = 1:(length(BETA0)/4);
assert(length(inxs)*4 == length(BETA0)); % Make sure round-off error hasn't happened

% Construct parameter values that include baseline parameters for fitting region

% Start with the raw initial parameter values
lb_region = lb;
ub_region = ub;
BETA0_region = BETA0;

% Set up the lists of parameters and bounds for the baseline
region_width = region(1)-region(2);
switch model.baseline_type
    case 'spline'
        number_baseline_points_to_insert = round(region_width/x_baseline_width);
        x_baseline_BETA = linspace(region(1),region(2),number_baseline_points_to_insert+2)';
        xwidth = x(1)-x(2);
        baseline_BETA = (y(round((x(1)-x_baseline_BETA)/xwidth)+1) + 0*x_baseline_BETA)/2; % Initialize
        lb_baseline = 0*baseline_BETA + min([y_region;0]);
        ub_baseline = 0*baseline_BETA + max(y_region);
    case 'v'
        baseline_BETA = [0;0;0];
        x_baseline_BETA = [region(1), (region(1)+region(2))/2, region(2)];
        lb_baseline = [0;0;1];
        ymax = max(y_region);
        ub_baseline = [ymax;1;inf];
    case 'line_up'
        baseline_BETA = [0;0];
        x_baseline_BETA = baseline_BETA; %Will not be used
        lb_baseline = [0;-inf];
        ymax = max(y_region);
        ub_baseline = [ymax;0];
    case 'line_down'
        baseline_BETA = [0;0];
        x_baseline_BETA = baseline_BETA; %Will not be used
        lb_baseline = [0;0];
        ymax = max(y_region);
        ub_baseline = [ymax;inf];
    case 'constant'
        baseline_BETA = 0;
        x_baseline_BETA = baseline_BETA; %Will not be used
        lb_baseline = 0;
        ymax = max(y_region);
        ub_baseline = ymax;
    otherwise
        error('region_deconvolution:unknown_baseline',...
            ['Unknown baseline type "' model.baseline_type ...
            '" in model passed to region_deconvolution']);
end

% Attach the baseline parameters and their bounds to the end of the region
% parameter/bound lists
BETA0_region = [BETA0_region;baseline_BETA];
lb_region = [lb_region;lb_baseline];
ub_region = [ub_region;ub_baseline];
num_maxima = length(inxs);

% Do the fit
if num_maxima > 0
    if exist('progress_func', 'var')
        [BETA_region,EXITFLAG] = ...
            perform_deconvolution(x_region',y_region,BETA0_region, ...
            lb_region,ub_region,x_baseline_BETA, model, progress_func);
    else
        [BETA_region,EXITFLAG] = ...
            perform_deconvolution(x_region',y_region,BETA0_region, ...
            lb_region,ub_region,x_baseline_BETA, model);
    end
    BETA(4*(inxs-1)+1) = BETA_region(1:4:4*num_maxima);
    BETA(4*(inxs-1)+2) = BETA_region(2:4:4*num_maxima);
    BETA(4*(inxs-1)+3) = BETA_region(3:4:4*num_maxima);
    BETA(4*(inxs-1)+4) = BETA_region(4:4:4*num_maxima);
else
    BETA_region=[];
end

% Calculate auxiliary output parameters
[y_errs,y_baseline] = regularized_model(BETA_region,x_region',num_maxima,x_baseline_BETA, y_region, model);
y_fit = y_errs(1:end-2) + y_region;

R2 = 1 - sum((y_fit - y_region).^2)/sum((mean(y_region) - y_region).^2);

peak_inxs = inxs;
peak_BETA = BETA_region(1:4*num_maxima);