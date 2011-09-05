classdef RegionalSpectrumModel
    % Assumptions constraining the deconvolution of a spectrum in a region
    %
    % The deconvolution of a spectrum into its component peaks, a baseline,
    % and noise is an underdetermined problem.  Many different combinations
    % of peaks, baselines, and noise could explain the data.  Assumptions
    % are needed to disambiguate the different options and arrive at a
    % conclusion.
    %
    % A RegionalSpectrumModel object gives assumtions that partially
    % disambiguate a regional deconvolution model, primarily in the form of
    % regularization parameters and constraints on the form of the
    % component equations.  These are set by the user of our targeted
    % deconvolution software.
    
    properties
        % Gives the functional form of the baseline
        %
        % One of
        %   'spline'    - a cubic spline from interp1
        %   'constant'  - a constant function
        %   'line_up'   - a line with a negative slope (will slope up when
        %                 viewed on a ppm-based spectrum display)
        %   'line_down' - a line with a positive slope (will slope down
        %                 when viewed on a ppm-based spectrum display)
        %   'v'         - a line down followed by a line up.
        baseline_type
        
        % Multiplied by area of the baseline and then added to the list of
        % terms whose sum of squares is to be minimized
        baseline_area_penalty
    end
    
    methods
        
    end
    
end

