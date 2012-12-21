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
        % Gives the functional form of the baseline. A string.
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
        
        % Multiplied by a measurement of the variation of the estimated
        % linewidth to penalize those solutions with a much greater
        % linewidth
        linewidth_variation_penalty
        
        % The size of the window around each peak that the rough
        % deconvolution uses. This is double holding the width in x units
        % (usually ppm)
        rough_peak_window_width
        
        % The maximum width that a peak in the rough deconvolution is
        % allowed to be. This is a double holding the width in x units
        % (usually ppm)
        max_rough_peak_width
        
        % True iff the deconvolution should stop with the rough deconv
        % step. This is a logical.
        only_do_rough_deconv
        
        % Gives the method to be used in generating the initial peak
        % parameters and constraints for the fine deconvolution. A string.
        %
        % One of
        %   'Anderson'        - Paul Anderson's original method
        %   'Short Peak 1st'  - Deconvolves one peak at a time, starting
        %                       with the shortest peaks
        rough_deconv_method

    end
    
    methods(Static)
        function cellarray=baseline_types()
        % A cell array of the acceptable baseline types for models
        %
        % -----------------------------------------------------------------
        % Usage
        % -----------------------------------------------------------------
        %
        % cellarray=baseline_types()
        % 
        % -----------------------------------------------------------------
        % Input Arguments
        % -----------------------------------------------------------------
        %
        % None
        %
        % -----------------------------------------------------------------
        % Examples:
        % -----------------------------------------------------------------
        %
        % >> c=RegionalSpectrumModel.baseline_types
        %
        %
        
            cellarray={'spline','constant','line_up','line_down','v'};
        end
        
        function cellarray=rough_deconv_methods()
        % A cell array of the acceptable values for rough_deconv_method
        %
        % -----------------------------------------------------------------
        % Usage
        % -----------------------------------------------------------------
        %
        % cellarray=rough_deconv_methods()
        % 
        % -----------------------------------------------------------------
        % Input Arguments
        % -----------------------------------------------------------------
        %
        % None
        %
        % -----------------------------------------------------------------
        % Examples:
        % -----------------------------------------------------------------
        %
        % >> c=RegionalSpectrumModel.rough_deconv_methods
        %
        %
        
            cellarray={'Anderson','Short Peak 1st'};
        end
    end
    methods
        function obj=RegionalSpectrumModel(baseline_type, ...
                baseline_area_penalty, linewidth_variation_penalty, ...
                rough_peak_window_width, max_rough_peak_width, ...
                only_do_rough_deconv, rough_deconv_method)
        % Create a RegionalSpectrumModel
        %
        % -----------------------------------------------------------------
        % Usage
        % -----------------------------------------------------------------
        %
        % obj=RegionalSpectrumModel(...
        %     baseline_type, baseline_area_penalty, ...
        %     linewidth_variation_penalty, rough_peak_window_width ...
        %     max_rough_peak_width, only_do_rough_deconv, ...
        %     rough_deconv_method)
        %
        % or
        % 
        % uninitialized = RegionalSpectrumModel();
        %
        % -----------------------------------------------------------------
        % Input Arguments
        % -----------------------------------------------------------------
        %
        % With no arguments, sets the type to spline, and the penalties to
        % 0, so the code behaves as in previous versions
        %
        % baseline_type         - string value of the baseline_type
        %                         property
        %
        % baseline_area_penalty - real numerical value of the
        %                         baseline_area_penalty property
        %
        % linewidth_variation_penalty - real numerical value of the
        %                         linewidth_variation_penalty property
        %
        % rough_peak_window_width - real numerical value of the 
        %                         rough_peak_window_width property
        %
        % max_rough_peak_width  - real numerical value of the 
        %                         max_rough_peak_width property
        %
        % only_do_rough_deconv  - logical value of the only_do_rough_deconv
        %                         property
        %
        % rough_deconv_method   - string value of the rough_deconv_method
        %                         property
        % -----------------------------------------------------------------
        % Examples:
        % -----------------------------------------------------------------
        %
        % m=RegionalSpectrumModel('line_up', 10, 1, 0.007, 0.006, false, 'Short Peak 1st');
        %
        % or
        %
        % m=RegionalSpectrumModel();
            if nargin > 0
                if ~strcmpi(baseline_type, ...
                        RegionalSpectrumModel.baseline_types) 
                    error('RegionalSpectrumModel:bad_baseline', ...
                        ['Unknown baseline type: "' baseline_type '"']);
                end
                obj.baseline_type = baseline_type;
                obj.baseline_area_penalty = baseline_area_penalty;
                obj.linewidth_variation_penalty = linewidth_variation_penalty;
                obj.rough_peak_window_width = rough_peak_window_width;
                obj.max_rough_peak_width = max_rough_peak_width;
                obj.only_do_rough_deconv = only_do_rough_deconv;
                obj.rough_deconv_method = rough_deconv_method;
            else
                obj.baseline_type = 'spline';
                obj.baseline_area_penalty = 0;
                obj.linewidth_variation_penalty = 0; 
                obj.rough_peak_window_width = 0.0052; % 12 samples in 64k sample spectra
                obj.max_rough_peak_width = 0.004; % 1 conventional bin default
                obj.only_do_rough_deconv = false; % Do the fine deconv steps by default
                obj.rough_deconv_method = 'Short Peak 1st'; % New short peak 1st method is default
            end
        end
    end
    
end

