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
        % x               The x values for the spectrum (row vector)
        %                 (we use the entire thing)
        %
        % y               The y values for the spectrum (column vector)
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
                gcftmp = gcf; %Waitbar can mess with the current figure, save it
                
                % Calculate the number of samples needed for the
                % rough deconvolution - assumes samples equally spaced
                samples_per_ppm = length(x)/max(x)-min(x);
                rough_window_samples = ceil(model.rough_peak_window_width * samples_per_ppm);
                
                % Ensure there are at least 2 samples
                if rough_window_samples < 2
                    msgbox(sprintf(['Rough peak window width is too ' ...
                        'small. A width of %g ppm yields %d '...
                        'samples. At least 2 samples are needed '...
                        'to do a deconvolution (though they will ' ...
                        'give very poor results).'], ...
                        model.rough_peak_window_width, ...
                        rough_window_samples), ...
                        'Peak window too small','Error');
                else
                    % Warn if there are less than 4 samples - less than 4
                    % will probably produce very poor results due to
                    % insufficient variables
                    if rough_window_samples < 4
                        warning('RegionDeconvolution:rough_ppm_too_small', ...
                            ['Rough peak window is only %g ppm wide, '...
                            'giving %d samples. This is likely to produce '...
                            'bad results. At least 4 samples should be ' ...
                            'used to derive the 4 variables for each peak '...
                            ], model.rough_peak_window_width, ...
                            rough_window_samples);
                    end
                    
                    
                    % Do rough deconvolution
                    wait_h = waitbar(0, sprintf('Rough deconvolution pass %d peak %d',10000,10000));
                    [BETA0,lb,ub] = deconv_initial_vals_dirty(x,y, ...
                        region_min, region_max, peak_xs, ...
                        model.max_rough_peak_width, rough_window_samples, ...
                        @(f,ps,pk) waitbar(f/2, wait_h, ...
                        sprintf('Rough deconvolution pass %d peak %d',ps,pk)));

                    if model.only_do_rough_deconv
                        % Return the results of the rough deconvolution
                        obj.fit_indices = find(region_max >= x & x >= region_min);
                        obj.y_baseline = zeros(size(obj.fit_indices))';
                        obj.peaks = GaussLorentzPeak(BETA0);
                        obj.y_fitted = sum(obj.peaks.at(x(obj.fit_indices)),1)';
                        y_region = y(obj.fit_indices);
                        obj.R2 = 1 - sum((obj.y_fitted - y_region).^2)/sum((mean(y_region) - y_region).^2);
                        obj.baseline_BETA = [];
                    else
                        % Do fine deconvolution
                        waitbar(0.5, wait_h, 'Performing fine deconvolution');

                        [unused, obj.baseline_BETA, obj.fit_indices, obj.y_fitted, ...
                            obj.y_baseline,obj.R2, unused, peak_BETA] = ...
                            region_deconvolution(x,y,BETA0,lb,ub,baseline_width, ...
                            [region_max;region_min], ...
                            model, @(f) waitbar(0.5+f/2, wait_h)); %#ok<ASGLU>
                        obj.peaks = GaussLorentzPeak(peak_BETA);
                    end

                    close(wait_h);
                    figure(gcftmp); %Restore the current figure
                end
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
        
        function obj=set_from_peaks(obj, peaks, x, fit_indices, y)
        % Return a copy of this object with the fields set as if peaks were a deconvolution of (x,y)
        %
        % -----------------------------------------------------------------
        % Usage
        % -----------------------------------------------------------------
        % rd_copy = rd.set_from_peaks(peaks, x, fit_indices, y)
        %
        % -----------------------------------------------------------------
        % Input Arguments
        % -----------------------------------------------------------------
        % obj   The RegionDeconvolution whose values will be set
        %       Must be a single object not an array.
        %
        % peaks An array of GaussLorentzPeak objects
        %
        % x           the array of ppm values where the deconvolution 
        %             took place
        %
        % fit_indices if XX is the x values for the whole spectrum,
        %             XX(fit_indices) == x
        %
        % y           y(i) is the sample intensity at ppm x(i). Must be the
        %             same shape as x
        %
        % -----------------------------------------------------------------
        % Outputs
        % -----------------------------------------------------------------
        %
        % obj   The RegionDeconvolutionObject with its private variables
        %       set as if peaks were the output of its internal
        %       deconvolution routines.
        %
        % -----------------------------------------------------------------
        % Examples:
        % -----------------------------------------------------------------
        %
        % p=GaussLorentzPeak([1,2,3,4]); rd = rd.set_from_peaks(p, [1,2], [1024,1025], [5.7,6.12]);
        
            assert(all(size(x) == size(y)));
            
            obj.peaks = peaks;
            obj.fit_indices = fit_indices;
            y_fits = [peaks.at(x)]; %#ok<NBRAK>
            obj.y_fitted = sum(y_fits,1);
            
            % Make the baseline a moving window median of the residual spectrum
            residual = y - obj.y_fitted;
            baseline = residual;
            window_width = 64;
            assert(mod(window_width, 2) == 0);
            for i=1:length(residual)
                i_start = max(1, i-window_width/2);
                i_end = min(length(residual), i+window_width/2);
                baseline(i) = median(residual(i_start:i_end));
            end
            obj.y_baseline = baseline;
            obj.baseline_BETA = baseline;
            
            % Calculate the goodness of fit parameter
            orig_var = var(y);
            ssqe = sum(residual.^2)/length(residual);
            obj.R2=1-ssqe/orig_var;
        end
        
    end
end

