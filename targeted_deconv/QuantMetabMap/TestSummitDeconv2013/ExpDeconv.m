classdef ExpDeconv
% Represents a deconvolution of a particular spectrum from my experiment for the TestSummitDeconv2013 paper
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
        % ExpDatum object. original_peaks(aligned_indices(1,i)
        % is the best match to peaks(aligned_indices(2,i) in the sense
        % that the matches in aligned indices minimize the sum of the
        % squared distances of each peak's mode location to its
        % corresponding peak's mode location.
        aligned_indices
        
        % The ID string of the ExpDatum object of which this
        % is a part.
        datum_id
    end
    
    properties (Dependent)

    end
    
    methods (Static)
        function best = best_alignment(peaks, original_peaks, criterion)
        % Calculate the best alignment between two sets of peaks using the hungarian algorithm for linear assignment problems (munkres)
        %
        % peaks - (vector of GaussLorentzPeak objects) the peaks returned by
        %      the deconvolution routine
        %
        % original_peaks - (vector of GaussLorentzPeak objects) the
        %      spectrum_peaks from the parent ExpDatum object
        %
        % criterion - (string) A string describing what criterion is used
        %      for creating the alignment. Can be one of:
        %
        %      'l2' - minimizes the L_2 norm of the distances (minimum sum
        %           of squares)
        %
        %      'l1' - minimizes the L_1 norm of the distances (minimum sum
        %           of absolute values)
        %
        %      'l0.5' - minimizes the L_0.5 norm of the distances (minimum
        %           of square root of absolute values)
        %
        %      'unambiguous' - only aligns a pair a,b when a is the nearest
        %           neighbor of b and b is the nearest neighbor of a.
        %           (Though it repeats the procedure after removing each
        %           group of matches until there are no unambiguous matches
        %           left.)
        %
        % best - a peak alignment matching the description of the
        %        aligned_indices member
            if strcmp(criterion, 'l2')
                assignment = ExpDeconv.l_p_norm_assignment([peaks.location], [original_peaks.location], 2);
            elseif strcmp(criterion,'l1')
                assignment = ExpDeconv.l_p_norm_assignment([peaks.location], [original_peaks.location], 1);
            elseif strcmp(criterion,'l0.5')
                assignment = ExpDeconv.l_p_norm_assignment([peaks.location], [original_peaks.location], 0.5);
            elseif strcmp(criterion,'unambiguous')
                error('best_alignment:not_implemented',...
                    'Unambiguous matching criterion not implemented yet');
            else
                error('best_alignment:unknown_criterion', ...
                    ['"' criterion '"is not a known alignment criterion ' ...
                    'string.']);
            end
            
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
        
        function [assign, cost] = l_p_norm_assignment(locs1, locs2, exponent)
        % Calculate the assignment from locs1 to locs2 that minimzes l_p norm betwen assigned elements
        %
        % locs1 - (vector of double) first list of locations
        %
        % locs2 - (vector of double) second list of locations
        %
        % Return values are the same as those returned by the munkres
        % routine.
        %
        % assign - (row vector) assign(i) is index of the column in locs2 assigned to locs1(i). 
        %    If no column is assigned to row i, then assign(i) is 0.
        %    locs2(assign) gives the locations in the same positions as
        %    their corresponding entries in locs(1)
        %
        % cost - (scalar) the sum of the costs of the assignments for the minimum
        %    cost set of assignments: will be sum(abs(locs1(assign > 0)-locs2(assign(assign > 0)))^exponent)
            costs = inf(length(locs1), length(locs2));
            for i = 1:length(locs1)
                i_loc = locs1(i);
                for j = 1:length(locs2)
                    j_loc = locs2(j);
                    costs(i,j) = abs(j_loc - i_loc)^exponent;
                end
            end
        
            [assign, cost] = munkres(costs);
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
        
        function str = pp_gold_std_aligned_with_local_max
        % Constant used to signify the peak picking method that chooses the
        % subset of gold-standard peaks that when placed in a 1-to-1
        % correspondence with the local maxima minimize the sum of squared
        % distances to their corresponding local maximum.
            str = 'pp_gold_std_aligned_with_local_max';
        end
        
        function strs = peak_picking_method_names
        % Usage: strs = ExpDeconv.peak_picking_method_names
        %
        % Lists the strings that can be used to identify a
        % peak-picking method applied preceeding the deconvolution. Returns
        % a cell array of strings.
            strs = {ExpDeconv.pp_gold_standard() ...
                    ExpDeconv.pp_noisy_gold_standard() ...
                    ExpDeconv.pp_smoothed_local_max() ...
                    ExpDeconv.pp_gold_std_aligned_with_local_max() ...
                    };
        end

        
        
        
        
        function str = dsp_anderson
        % Constant used to signify Paul Anderson's deconvolution starting point (DSP) method
            str = 'dsp_anderson';
        end
        
        function str = dsp_summit
        % Constant used to signify the summit deconvolution 
        % starting point (DSP) method which bases final max width on 75th
        % percentile of estimated widths
            str = 'dsp_summit';
        end
        
        function str = dsp_summit_max_width_one_bin
        % Constant used to signify the summit deconvolution
        % starting point (DSP) method using a maximum peak width that is
        % one standard bin and bases final max width on 75th
        % percentile of estimated widths
            str = 'dsp_summit_max_width_one_bin';
        end
        
        function str = dsp_summit_max_width_too_large
        % Constant used to signify the summit deconvolution
        % starting point (DSP) method using a maximum peak width that is
        % slightly too large and bases final max width on 75th
        % percentile of estimated widths
            str = 'dsp_summit_max_width_too_large';
        end
        
        function str = dsp_summit_100_pctile
        % Constant used to signify the summit deconvolution 
        % starting point (DSP) method which bases final max width on the 
        % maximum of estimated widths
            str = 'dsp_summit_100_pctile';
        end
        
        function str = dsp_summit_100_pctile_max_width_one_bin
        % Constant used to signify the summit deconvolution
        % starting point (DSP) method using a maximum peak width that is
        % slightly too large and bases final max width on the maximum of 
        % estimated widths
            str = 'dsp_summit_100_pctile_max_width_one_bin';
        end
        
        function str = dsp_summit_100_pctile_max_width_too_large
        % Constant used to signify the summit deconvolution
        % starting point (DSP) method using a maximum peak width that is
        % slightly too large and bases final max width on the maximum of 
        % estimated widths
            str = 'dsp_summit_100_pctile_max_width_too_large';
        end
        
        function str = dsp_summit_100_pctile_baseline
        % Constant used to signify the summit deconvolution
        % starting point (DSP) that bases final max width on the maximum of 
        % estimated widths and corrects for a constant baseline variation
        % while creating the starting point.
            str = 'dsp_summit_100_pctile_baseline';
        end
        
        function strs = deconvolution_starting_point_method_names
        % Lists the strings that can be used to identify a
        % method giving a starting point in the deconvolution
        % search space
            strs = {...
                ExpDeconv.dsp_anderson(), ...
                ExpDeconv.dsp_summit(), ...
                ExpDeconv.dsp_summit_max_width_one_bin(), ...
                ExpDeconv.dsp_summit_max_width_too_large(), ...
                ExpDeconv.dsp_summit_100_pctile(), ...
                ExpDeconv.dsp_summit_100_pctile_max_width_one_bin(), ...
                ExpDeconv.dsp_summit_100_pctile_max_width_too_large(), ...
                ExpDeconv.dsp_summit_100_pctile_baseline() ...
                }; 
        end
        
        function obj = dangerous_constructor(peak_picker_name, ...
            picked_locations, starting_point_name, starting_point, ...
            starting_point_lb, starting_point_ub, peaks, aligned_indices, ...
            datum_id)
        % Return a ExpDeconv with the properties set to the values passed in.
        %
        % NO ERROR CHECKING IS DONE. This method is intended for use in
        % testing. Don't use it unless you are testing. 
        %
        % self should be a single object not an object array
        %
        % Example:
        %
        % >> g = ExpDeconv.dangerous_constructor([],2,3,4,5,6,7,8,'my id')
        %
        % Produces a completely unusable ExpDeconv object
            obj = ExpDeconv;
            obj.peak_picker_name = peak_picker_name;
            obj.picked_locations = picked_locations;
            obj.starting_point_name = starting_point_name;
            obj.starting_point = starting_point;
            obj.starting_point_lb = starting_point_lb;
            obj.starting_point_ub = starting_point_ub;
            obj.peaks = peaks;
            obj.aligned_indices = aligned_indices;
            obj.datum_id = datum_id;
        end
    end
    
    methods
        function obj=ExpDeconv(datum_id, spectrum, peaks, peak_picker_name, picked_locations, starting_point_name)
        % Generate the deconvolution of a spectrum 
        %
        % Usage: obj=ExpDeconv(datum_id, spectrum, peaks, peak_picker_name, picked_locations, starting_point_name)
        %
        % datum_id - (string) the string id of the ExpDatum that
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
        % peak_picker_name - (string) one of the list returned from
        %                    peak_picking_method_names. Tells which
        %                    peak picking method to use in generating
        %                    the deconvolution.
        %
        % picked_locations - (sorted vector of double) list of the
        %                    locations generated by the peak picker named
        %                    in peak_picker_name
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
        % >> g = ExpDeconv('baby aardvark tree', my_spectrum,...
        %        some_peaks, 'pp_gold_standard', sort([some_peaks.location]), 'dsp_anderson')
        %
        % Creates a deconvolution with parent 'baby aardvark tree' by
        % deconvolving my_spectrum and aligning with some_peaks. the
        % pp_gold_standard peak picking method is used to select peaks
        % that are then passed to the dsp_anderson method to generate
        % a starting point for the deconvolution search.
            if nargin > 0
                assert(nargin == 6);

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
                                  ExpDeconv ...
                                  .peak_picking_method_names)));
                assert(issorted(picked_locations));
                assert(any(strcmp(starting_point_name, ...
                                  ExpDeconv ...
                                  .deconvolution_starting_point_method_names)));
                              
                % Set general values
                obj.datum_id = datum_id;
                obj.peak_picker_name = peak_picker_name;
                obj.starting_point_name = starting_point_name;
                obj.picked_locations = picked_locations;

                % Set starting point
                summit_methods = {...
                    ExpDeconv.dsp_summit(), ...
                    ExpDeconv.dsp_summit_max_width_one_bin(), ...
                    ExpDeconv.dsp_summit_max_width_too_large(), ...
                    ExpDeconv.dsp_summit_100_pctile(), ...
                    ExpDeconv.dsp_summit_100_pctile_max_width_one_bin(), ...
                    ExpDeconv.dsp_summit_100_pctile_max_width_too_large(), ...
                    ExpDeconv.dsp_summit_100_pctile_baseline() ...
                };

                x = spectrum.x;
                model = RegionalSpectrumModel; % Use default model
                if ~isempty(obj.picked_locations)
                    switch(starting_point_name)
                        case ExpDeconv.dsp_anderson
                            [obj.starting_point, obj.starting_point_lb, ...
                                obj.starting_point_ub] = ...
                                ...
                                compute_initial_inputs(x,spectrum.Y, ...
                                obj.picked_locations, ...
                                1:length(x), obj.picked_locations);

                        case summit_methods
                            switch( starting_point_name )
                                case ExpDeconv.dsp_summit()
                                    final_max_width_pctile = 75;
                                    model.max_rough_peak_width = 0.00842666594274386373;
                                    fit_baseline = false;
                                case ExpDeconv.dsp_summit_max_width_one_bin()
                                    final_max_width_pctile = 75;
                                    model.max_rough_peak_width = 0.04;
                                    fit_baseline = false;
                                case ExpDeconv.dsp_summit_max_width_too_large()
                                    final_max_width_pctile = 75;
                                    model.max_rough_peak_width = 0.05;
                                    fit_baseline = false;
                                case ExpDeconv.dsp_summit_100_pctile()
                                    final_max_width_pctile = 100;
                                    model.max_rough_peak_width = 0.00842666594274386373;
                                    fit_baseline = false;
                                case ExpDeconv.dsp_summit_100_pctile_max_width_one_bin()
                                    final_max_width_pctile = 100;
                                    model.max_rough_peak_width = 0.04;
                                    fit_baseline = false;
                                case ExpDeconv.dsp_summit_100_pctile_max_width_too_large()
                                    final_max_width_pctile = 100;
                                    model.max_rough_peak_width = 0.05;
                                    fit_baseline = false;
                                case ExpDeconv.dsp_summit_100_pctile_baseline()
                                    final_max_width_pctile = 100;
                                    model.max_rough_peak_width = 0.00842666594274386373;
                                    fit_baseline = true;
                                otherwise
                                    error('TestSummitDeconv2013:unknown_dsp_method', ...
                                        'Unknown summit starting point method method "%s" specified.',...
                                        starting_point_name);
                            end
                            samples_per_ppm = length(x)/(max(x)-min(x));
                            window_samples = ceil(model.rough_peak_window_width * samples_per_ppm);
                            assert(window_samples >= 4);
                            picked_x = obj.picked_locations;
                            [obj.starting_point, obj.starting_point_lb, ...
                                obj.starting_point_ub] = ...
                                ...
                                deconv_initial_vals_summit ...
                                    (x, spectrum.Y, min(x), ...
                                    max(x), picked_x, ...
                                    model.max_rough_peak_width, ...
                                    window_samples, final_max_width_pctile,...
                                    fit_baseline, @do_nothing);
                            if length(obj.starting_point) ~= length(picked_x)*4
                                save('tmp_exception.mat', ...
                                    'samples_per_ppm', 'x', 'model', ...
                                    'window_samples', 'picked_x', 'obj', ...
                                    'spectrum');
                                error('TestSummitDeconv2013:diff_num_peaks_after_deconv', ...
                                    ['Summit-focused deconv produced a ' ...
                                    'different number of peaks output ' ...
                                    'than input. Variables written to ' ...
                                    'tmp_exception.mat']);
                            end
                        otherwise
                            % Should be impossible to reach due to the assert
                            % at the beginning - this is defensive programming
                            error('TestSummitDeconv2013:unknown_dsp_method', ...
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
                
                obj.aligned_indices = ExpDeconv.best_alignment(obj.peaks, peaks, 'l2');
                
                % Defensive programming checking for a bug that cropped up
                % earlier where the number of peaks in deconvolved noisy
                % gold standard was different than the input number of
                % peaks
                mismatched_num_peaks = false;
                if strcmp(obj.peak_picker_name, ExpDeconv.pp_noisy_gold_standard) || ...
                        strcmp(obj.peak_picker_name, ExpDeconv.pp_gold_standard)
                    mismatched_num_peaks = mismatched_num_peaks | ...
                        length(peaks) ~= length(obj.peaks) | ...
                        length(peaks) ~= size(obj.aligned_indices,2) | ...
                        length(peaks) ~= length(obj.picked_locations) | ...
                        length(peaks)*4 ~= length(obj.starting_point) | ...
                        length(peaks)*4 ~= length(obj.starting_point_lb) | ...
                        length(peaks)*4 ~= length(obj.starting_point_ub);
                end
                if mismatched_num_peaks
                    datum_id_with_uscore = regexprep(datum_id,' ','_');
                    filename = sprintf('tmp_%s_exception.mat', ...
                        datum_id_with_uscore);
                    save(filename, ...
                        'model', 'obj', 'spectrum', 'datum_id', ...
                        'peaks', 'peak_picker_name', 'picked_locations', ...
                        'starting_point_name');
                    error('TestSummitDeconv2013:diff_num_peaks_after_deconv', ...
                        ['Summit-focused deconv produced a ' ...
                        'different number of peaks output ' ...
                        'than input. Variables written to ' ...
                        '%s'], filename);
                end
           end
        end
        
        function plot(objs, parent)
        % Plot this deconvolution along with its parent on the current
        % figure
        %
        % objs - the ExpDeconv object to plot. If an array, loops
        %        through each item and prints it on a new figure
        %
        % parent - the ExpDatum object that contains this
        %        ExpDeconv object as one of its deconvolutions            
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
                strs{i} =sprintf([separator,'ExpDeconv(%s, %s, %s)'],...
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

