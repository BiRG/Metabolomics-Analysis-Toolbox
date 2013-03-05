classdef GLBIO2013Deconv
% Represents a deconvolution of a particular spectrum from my experiment for the GLBIO 2013 paper
% 

    properties (SetAccess=private)
        % The name of the method used for generating the peaks -
        % one of the values returned from peak_picking_method_names (string)
        peak_picker_name
        
        % The locations returned by the peak picker in ppm (vector of double)
        picked_locations
        
        % The name of the method used for choosing the starting point for the
        % deconvolution search. One of the values returned by
        % deconvolution_starting_point_method_names (string)
        starting_point_name
        
        % The starting point generated by the starting point method
        % A multiple of 4. Each group of 4 represents a peak as
        % defined by the input to the GaussLorentzPeak
        % constructor. (vector of double)
        starting_point
        
        % The lower bounds for the corresponding variables in
        % starting_point - lb as defined in lsqnonlin (vector of double)
        starting_point_lb
        
        % The upper bounds for the corresponding variables in
        % starting_point - ub as defined in lsqnonlin (vector of double)
        starting_point_ub
        
        % The GaussLorentzPeak objects returned by the
        % deconvolution routine (vector of GaussLorentzPeak objects)
        peaks
        
        % Aligned indices is a 2xn matrix where n is the smaller of
        % length(peaks) and length(original_peaks) where
        % original_peaks is the list of peaks in the parent
        % GLBIO2013Datum object. original_peaks(aligned_indices(1,i)
        % is the best match to peaks(aligned_indices(2,i) in the sense
        % that the matches in aligned indices minimize the sum of the
        % squared distances of each peak's mode location to its
        % corresponding peak's mode location.
        aligned_indices
        
        % The ID string of the GLBIO2013Datum object of which this
        % is a part.
        datum_id
    end
    
    properties (Dependent)

    end
    
    methods (Static)
        function best = best_alignment(peaks, original_peaks)
        % Calculate the best alignment between two sets of peaks using the hungarian algorithm for linear assignment problems (munkres)
        %
        % best - a peak alignment matching the description of the
        %        aligned_indices member
            costs = inf(length(peaks), length(original_peaks));
            for i = 1:length(peaks)
                i_loc = peaks(i).location;
                for j = 1:length(original_peaks)
                    j_loc = original_peaks(j).location;
                    costs(i,j) = (j_loc - i_loc)^2;
                end
            end
            assignment = munkres(costs);
            best = zeros(2,sum(assignment ~= 0));
            dest_idx = 1;
            for src_idx = 1:length(assignment)
               if assignment(src_idx) ~= 0
                   best(1, dest_idx) = assignment(src_idx);
                   best(2, dest_idx) = src_idx;
                   dest_idx = dest_idx + 1;
               end
            end
        end
        
        function str = pp_gold_standard
        % Constant used to signify the gold-standard peak picking method
            str = 'pp_gold_standard';
        end
        
        function str = pp_noisy_gold_standard
        % Constant used to signify the gold-standard peak picking
        % method with added noise (simulating a human expert)
            str = 'pp_noisy_gold_standard';
        end
        
        function str = pp_smoothed_local_max
        % Constant used to signify the smoothed local maximum peak-picking method
            str = 'pp_smoothed_local_max';
        end
        
        function strs = peak_picking_method_names
        % Lists the strings that can be used to identify a
        % peak-picking method applied preceeding the deconvolution
            strs = {GLBIO2013Deconv.pp_gold_standard(), ...
                    GLBIO2013Deconv.pp_noisy_gold_standard(), ...
                    GLBIO2013Deconv.pp_smoothed_local_max()};
        end

        
        
        
        
        function str = dsp_anderson
        % Constant used to signify Paul Anderson's deconvolution starting point (DSP) method
            str = 'dsp_anderson';
        end
        
        function str = dsp_smallest_peak_first
        % Constant used to signify the smallest peak first deconvolution starting point (DSP) method
            str = 'dsp_smallest_peak_first';
        end
        

        function strs = deconvolution_starting_point_method_names
        % Lists the strings that can be used to identify a
        % method giving a starting point in the deconvolution
        % search space
            strs = {...
                GLBIO2013Deconv.dsp_anderson(), ...
                GLBIO2013Deconv.dsp_smallest_peak_first()}; 
        end
    end
    
    methods
        function obj=GLBIO2013Deconv(datum_id, spectrum, peaks, noise_std, peak_picker_name, starting_point_name)
        % Generate the deconvolution of a spectrum 
        %
        % Usage: GLBIO2013Deconv(datum_id, spectrum, peaks, noise_std, peak_picker_name, starting_point_name
        %
        % datum_id - (string) the string id of the GLBIO2013Datum that
        %            is the parent of this object
        %
        % spectrum - (struct) the spectrum which the deconvolution
        %            algorithm will be deconvolving (see
        %            load_collection for format)
        %
        % peaks - (vector of GaussLorentzPeak objects) the original
        %         peaks from which the spectrum was generated. Not
        %         used directly for the deconvolution, but used for
        %         generating the alignment with the original and
        %         for some peak-picking methods.
        %
        % noise_std - (scalar) the standard deviation of the noise added to
        %             the generated peaks when generating the simulated
        %             spectrum. Needed to properly simulate some
        %             peak-picking methods since they depend on having a
        %             clean area from which to estimate spectral noise.
        %             When those methods are used, a such a clean area is
        %             generated for their benefit.
        %
        % peak_picker_name - (string) one of the list returned from
        %                    peak_picking_method_names. Tells which
        %                    peak picking method to use in generating
        %                    the deconvolution.
        %
        % starting_point_name - (string) one of the list returned from
        %                       deconvolution_starting_point_method_names. Tells
        %                       which starting point generation method
        %                       to use in generating the
        %                       deconvolution.
        % 
        % ----------------------------------------------------------------
        % Examples 
        % ---------------------------------------------------------------
        %
        % >> g = GLBIO2013Deconv('baby aardvark tree', my_spectrum,...
        %        some_peaks, 'pp_gold_standard', 'dsp_anderson')
        %
        % Creates a deconvolution with parent 'baby aardvark tree' by
        % deconvolving my_spectrum and aligning with some_peaks. the
        % pp_gold_standard peak picking method is used to select peaks
        % that are then passed to the dsp_anderson method to generate
        % a starting point for the deconvolution search.
            if nargin > 0
                assert(nargin == 6);
                % datum_id, spectrum, peaks, peak_picker_name, starting_point_name)
                assert(ischar(datum_id));
                assert(isstruct(spectrum));
                assert(isfield(spectrum, 'x'));
                assert(isfield(spectrum, 'Y'));
                assert(length(spectrum.x) == length(spectrum.Y));
                assert(size(spectrum.Y,2) == 1);
                assert(isa(peaks, 'GaussLorentzPeak'));
                assert(ischar(peak_picker_name));
                assert(ischar(starting_point_name));
                assert(any(strcmp(peak_picker_name, ...
                                  GLBIO2013Deconv ...
                                  .peak_picking_method_names)));
                assert(any(strcmp(starting_point_name, ...
                                  GLBIO2013Deconv ...
                                  .deconvolution_starting_point_method_names)));
                              
                % Set general values
                obj.datum_id = datum_id;
                obj.peak_picker_name = peak_picker_name;
                obj.starting_point_name = starting_point_name;
                
                % Pick peaks
                mean_peak_width = 0.00453630122481774988; % Width of the mean peak in ppm
                switch(peak_picker_name)
                    case GLBIO2013Deconv.pp_gold_standard
                        obj.picked_locations = [peaks.location];
                    case GLBIO2013Deconv.pp_noisy_gold_standard
                        obj.picked_locations = [peaks.location];
                        obj.picked_locations = obj.picked_locations + (mean_peak_width/16).*randn(size(obj.picked_locations));
                    case GLBIO2013Deconv.pp_smoothed_local_max
                        obj.picked_locations = peak_loc_estimate_for_random_spec(spectrum, noise_std);
                    otherwise
                        % Should be impossible to reach due to the assert
                        % at the beginning - this is defensive programming
                        error('GLBIO2013:unknown_pp_method', ...
                            'Unknown peak picking method "%s" specified.',...
                            peak_picker_name);
                end
                obj.picked_locations = sort(obj.picked_locations);
                
                % Set starting point
                x = spectrum.x;
                model = RegionalSpectrumModel; % Use default model
                if ~isempty(obj.picked_locations)
                    switch(starting_point_name)
                        case GLBIO2013Deconv.dsp_anderson
                            [obj.starting_point, obj.starting_point_lb, ...
                                obj.starting_point_ub] = ...
                                ...
                                compute_initial_inputs(x,spectrum.Y, ...
                                obj.picked_locations, ...
                                1:length(x), obj.picked_locations);

                        case GLBIO2013Deconv.dsp_smallest_peak_first
                            samples_per_ppm = length(x)/(max(x)-min(x));
                            window_samples = ceil(model.rough_peak_window_width * samples_per_ppm);
                            assert(window_samples >= 4);
                            picked_x = obj.picked_locations;
                            [obj.starting_point, obj.starting_point_lb, ...
                                obj.starting_point_ub] = ...
                                ...
                                deconv_initial_vals_dirty ...
                                    (x, spectrum.Y, min(x,picked_x), ...
                                    max(x, picked_x), picked_x, ...
                                    model.max_rough_peak_width, ...
                                    window_samples, @do_nothing);
                            if length(obj.starting_point) ~= length(picked_x)*4
                                save('tmp_exception.mat', ...
                                    'samples_per_ppm', 'x', 'model', ...
                                    'window_samples', 'picked_x', 'obj', ...
                                    'spectrum');
                                error('GLBIO2013:diff_num_peaks_after_deconv', ...
                                    ['Summit-focused deconv produced a ' ...
                                    'different number of peaks output ' ...
                                    'than input. Variables written to ' ...
                                    'tmp_exception.mat']);
                            end
                        otherwise
                            % Should be impossible to reach due to the assert
                            % at the beginning - this is defensive programming
                            error('GLBIO2013:unknown_dsp_method', ...
                                'Unknown starting point method method "%s" specified.',...
                                starting_point_name);
                    end
                else
                    obj.starting_point = []; 
                    obj.starting_point_lb = [];
                    obj.starting_point_ub = [];
                end
                
                % Do deconvolution
                if ~isempty(obj.starting_point)
                    [~, ~, ~, ~, ~,~, ~, peak_params] = ...
                        region_deconvolution(x, spectrum.Y, obj.starting_point, ...
                            obj.starting_point_lb, obj.starting_point_ub, ...
                            2*(max(x)-min(x)), ... % This baseline width is the value given in targeted_identify line 1794
                            [max(x);min(x)], ...
                            model); 
                    obj.peaks = GaussLorentzPeak(peak_params);
                else
                    obj.peaks = GaussLorentzPeak([]);
                end
                
                obj.aligned_indices = GLBIO2013Deconv.best_alignment(obj.peaks, peaks);
            end
        end
        
        function plot(objs, parent)
        % Plot this deconvolution along with its parent on the current
        % figure
        %
        % objs - the GLBIO2013Deconv object to plot. If an array, loops
        %        through each item and prints it on a new figure
        %
        % parent - the GLBIO2013Datum object that contains this
        %        GLBIO2013Deconv object as one of its deconvolutions            
            function s = escaped(str)
                num_underscore = sum(bsxfun(@eq,str,'_'));
                s = char(length(str)+num_underscore);
                j = 1;
                for ii = 1:length(str)
                    if str(ii) == '_'
                        s(j) = '\'; j=j+1;
                    end
                    s(j) = str(ii);
                    j = j+1;
                end
            end
            
            if length(objs) > 1
                for i = 1:length(objs)
                    figure;
                    objs(i).plot(parent);
                end
            elseif length(objs) == 1
                hold_was_on = ishold;
                s = parent.spectrum;
                x = s.x;
                spectrum_h = plot(x, s.Y,'b--');
                hold on;
                if isempty(objs.peaks)
                    peak_h = plot(x, zeros(size(x)),'m-');
                else
                    for i = 1:length(objs.peaks)
                        peak_h = plot(x, objs.peaks(i).at(x),'m-');
                        from_x = objs.peaks(i).location;
                        from_y = objs.peaks(i).height;
                        % original peaks indices in 1st row of aligned
                        alignment_idx = objs.aligned_indices(2,:) == i;
                        parent_idx = objs.aligned_indices(1,alignment_idx);
                        if isscalar(parent_idx)
                            to_x = parent.spectrum_peaks(parent_idx).location;
                            to_y = parent.spectrum_peaks(parent_idx).height;
                            old_warn_state = warning('off','arrow:axis_limits_changed');
                                arrow([from_x, from_y], [to_x, to_y]);
                            warning(old_warn_state);
                        end
                    end
                end
                title(escaped(objs.char));
                legend([spectrum_h, peak_h],'Spectrum','Peaks');
                if ~hold_was_on
                    hold off
                end
            end
        end
        
        
        function str=char(objs)
        % Return a human-readable string representation of this
        % object. (Matlab's version of toString, however, Matlab
        % doesn't call it automatically)
            strs = cell(length(objs),1);
            separator = '';
            for i = 1:length(objs)
                strs{i} =sprintf([separator,'GLBIO2013Deconv(%s, %s, %s)'],...
                    objs(i).datum_id, objs(i).peak_picker_name, ...
                    objs(i).starting_point_name);
                separator = '\n';
            end
            str = sprintf('%s',strs{:});
        end
        
        function display(objs)
        % Display this object to a console. (Called by Matlab
        % whenever an object of this class is assigned to a
        % variable without a semicolon to suppress the display).
            fprintf('%s\n',objs.char);
        end
    end
    
end

