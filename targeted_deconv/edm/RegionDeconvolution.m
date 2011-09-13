classdef RegionDeconvolution
    %REGIONDECONVOLUTION Peaks found in a region through deconvolution
    %   This class holds the data describing the peaks found in a local
    %   deconvolution.  Most of the properties are a dump of the
    %   properties returned from the region_deconvolution function.  Thus
    %   there is some uncertainty about their interpretation
    
    properties (SetAccess=private)
        % An array of GaussianLorenzian objects for the peaks that were in
        % the region that was deconvolved
        peaks
        
        % The parameters of the baseline as returned by 
        % region_deconvolution.  Maybe the heights of
        % the baseline at the control points?
        baseline_BETA      

        % The indices over which the fit took place.  So you can
        % plot(x(fit_inxs), y_fitted) to get the fitted curve
        fit_indices

        % The fitted points, a 1d array of doubles of same
        % dimension as fit_inxs covering the x's in the region
        y_fitted
                   
        % The calculated baseline values for each of the fitted indices
        y_baseline         

        % A fit quality metric.  If s is the sum of squared 
        % error for the fit and v is the variance of the 
        % original function.  R2=1-s/v.  R2 of 1 is a perfect 
        % fit.  Note that R2 can conceivably be negative for a 
        % very bad fit (no such fit will likely be forthcoming 
        % from this program on normal NMR data, though.)
        R2                 
    end
    
    methods
        function obj=RegionDeconvolution(x, y, peak_xs, ...
                baseline_width, region_min, region_max, ...
                model)
        %Deconvolve a region in a spectrum
        %
        % -----------------------------------------------------------------
        % Usage
        % -----------------------------------------------------------------
        % obj = RegionDeconvolution(x, y, peak_xs, baseline_width, ...
        %    region_min, region_max, model)
        %
        % or
        % 
        % uninitialized = RegionDeconvolution();
        %
        % -----------------------------------------------------------------
        % Input Arguments
        % -----------------------------------------------------------------
        % x               The x values for the spectrum
        %
        % y               The y values for the spectrum
        %
        % peak_xs         The x values of the peaks in the spectrum
        %
        % baseline_width  The wider this is, the less control points the
        %                 baseline has in a given area, thus, the more 
        %                 rigid the baseline
        %
        % region_min      The minimum x value in the region to be
        %                 deconvolved
        %
        % region_max      The maximum x value in the region to be
        %                 deconvolved
        %
        % model           The RegionalSpectrumModel giving the assumptions
        %                 for this deconvolution
        %
        % -----------------------------------------------------------------
        % Examples:
        % -----------------------------------------------------------------
        %
        % load('collection.mat');  c=collection; m=RegionalSpectrumModel; d=RegionDeconvolution(c.x, c.Y, c.x(c.maxs{1}), 8.6-8.41, 8.41, 8.6, m)
        %
            if nargin > 0
                [BETA0,lb,ub] = compute_initial_inputs(x,y, peak_xs, ...
                    1:length(x), peak_xs);

                [unused, obj.baseline_BETA, obj.fit_indices, obj.y_fitted, ...
                    obj.y_baseline,obj.R2, unused, peak_BETA] = ...
                    region_deconvolution(x,y,BETA0,lb,ub, baseline_width, ...
                    [region_max;region_min], ...
                    model); %#ok<ASGLU>
                obj.peaks = GaussLorentzPeak(peak_BETA);
            end
        end
        
        function peaks=peak_at(obj, x)
        % Return all peak objects which have their maximum at x
        %
        % -----------------------------------------------------------------
        % Usage
        % -----------------------------------------------------------------
        % peak = rd.peak_at(x)
        %
        % -----------------------------------------------------------------
        % Input Arguments
        % -----------------------------------------------------------------
        % obj   The RegionDeconvolution in which to search for the peak.  
        %       Must be a single object not an array.
        %
        % x     The x value of the maximum of the peak.  Must be a scalar
        %
        %
        % -----------------------------------------------------------------
        % Outputs
        % -----------------------------------------------------------------
        %
        % peak  A GaussLorentzPeak object describing the peak with a 
        %       maximum at the given x or [] if there was no such peak
        %
        % -----------------------------------------------------------------
        % Examples:
        % -----------------------------------------------------------------
        %
        % p=rd.peak_at(1.5); if ~isempty(p); fprintf('We found them'); end
        
            if isempty(obj.peaks)
                peaks=[];
                return;
            elseif length(obj) > 1
                error(['RegionDeconvolution.peak_at is not ', ...
                    'implemented for operation on an array of ', ...
                    'RegionDeconvolution objects.']);
            elseif length(x) > 1
                error(['RegionDeconvolution.peak_at is not ', ...
                    'implemented for operation on an array of ', ...
                    'x objects.']);
            end
            
            exes = [obj.peaks.location];
            peaks = obj.peaks(exes == x);
        end
    end
end

