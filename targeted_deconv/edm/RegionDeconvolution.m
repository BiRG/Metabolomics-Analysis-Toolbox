classdef RegionDeconvolution
    %REGIONDECONVOLUTION Peaks found in a region through deconvolution
    %   This class holds the data describing the peaks found in a local
    %   deconvolution.  Most of the properties are a dump of the
    %   properties returned from the region_deconvolution function.  Thus
    %   there is some uncertainty about their interpretation
    
    %TODO: finish constructor
    
    properties
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
    end
    
end

