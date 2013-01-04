function param_error_list = GLBIO2013_calc_param_error_list(results)
% Takes the results (an array of GLBIO2013Datum objects) and
% extracts more-easily analyzable statistics. Assumes that the
% results from the first call are always the results.
%
% Fields of the param_error_list structure: 
%
% collision_prob - (scalar )probability that there was at least one 
%                  missing local maximum in a spectrum of this width
%
% peak_picking_name - (string) name for the peak-picking method used
%
% parameter_name - (string) the name of the peak parameter for which 
%                  the error is given - one of height, width,
%                  lorentzianness, and location
%
% datum_id - (string) the name of the datum from which this pair of
%            deconvolutions came
%
% mean_error_anderson - (scalar) the mean absolute difference in values
%                       between the values for this parameter and the
%                       values for their corresponding peak using the
%                       anderson starting point
% mean_error_summit - (scalar) the mean absolute difference in values
%                       between the values for this parameter and the
%                       values for their corresponding peak using the
%                       summit-based starting point (called
%                       shortest-peak-first and dirty deconvolution in
%                       other places in my work)
% error_diff - (scalar) mean_error_anderson - mean_error_summit
%              a positive value indicates an improvement (that the anderson
%              error is greater than the summit error so summit is an
%              improvement)

    function p = collision_prob_for_width(width)
        % Given a spectrum width from the list of widths I used for the 
        % GLBIO2013 experiment, gives the approximate probability that a
        % spectrum with seven peaks in a bin of that width will be missing
        % at least one local maximum 
        %
        % width - the width of the spectrum
        %
        % p - the approximate probability of a collision
        
        mean_peak_width = 0.00453630122481774988;
        widths =    [5.75, 26.785578117253827, 37.81403585728431, 50.275739222321697, 65.69707458955628, 86.66187912294609, 116.95643024521793, 167.91940604135232, 267.69215637895581, 563.31293102047039].*mean_peak_width;
        probs = 1 - [0,    0.1,                0.2,               0.3,                0.4,               0.5,               0.6,                0.7,                0.8,                0.9];
        matches = abs(widths-width) < 1e-4;
        if ~any(matches)
            error('GLBIO2013Analyze:collison_prob_for_width:unknown_width', ...
                'The width %.18g is not in the list known from the experiments. You likely forgot to update the list after doing a new experiment.', width);
        end
        if sum(matches) > 1
            error('GLBIO2013Analyze:collison_prob_for_width:more_than_one_match', ...
                'Some of the widths in the list of experimental widths are too close together leading %.18g to match more than one', width);
        end
        p = probs(matches);
    end

    function errs = param_errors(deconv, datum)
        % Return list of the parameter-wise errors between deconv and datum
        %
        % Aligns the peaks of deconv and datum. Then takes the parameter
        % list of those aligned peaks. Returns the absolute value of the
        % difference between the two parameter lists.
        %
        % deconv - a GLBIO2013Deconv object whose parent is datum
        %
        % datum - a GLBIO2013Datum object
        %
        % errs - errs is an array in the same order as that returned by
        %        GaussLorentzPeak.property_array. It is the absolute value
        %        of the difference between the properties of the peaks in
        %        deconv and the corresponding peaks in datum.
        assert(isa(deconv,'GLBIO2013Deconv'));
        assert(isa(datum,'GLBIO2013Datum'));
        assert(strcmp(deconv.datum_id,datum.id));
        
        pdeconv = deconv.peaks(deconv.aligned_indices(2,:));
        pdatum  = datum.spectrum_peaks(deconv.aligned_indices(1,:));
        errs = abs(pdeconv.property_array - pdatum.property_array);
    end


n = length(results);

% The names for the parameter at offset i in the peak parameters list
% returned by GaussLorentzPeak>property_array
parameter_names = {'height','half-width-at-half-height','lorentzianness','location'};

% Param error structure has 12 = 4*3 = #params*#peak_pickers per result.
% Preallocate it.
param_error_list(12*n).collision_prob = 0;
param_error_list(12*n).peak_picking_name = '';
param_error_list(12*n).parameter_name = '';
param_error_list(12*n).datum_id = '';
param_error_list(12*n).mean_error_anderson = 0;
param_error_list(12*n).mean_error_summit = 0;
param_error_list(12*n).error_diff = 0;
param_error_list_idx = 1;

% Shorter name for the list of possible peak-picking names
pp_names = GLBIO2013Deconv.peak_picking_method_names;

% Convert the list of results into a (larger) list of param_error
% structures
for results_idx = 1:n
    % Set initial shortcut variables that are constant for all param_error
    % structures generated from this result
    datum = results(results_idx);
    deconvs = datum.deconvolutions;
    collision_prob = collision_prob_for_width(datum.spectrum_width);
    datum_id = datum.id;

    % Loop through the types of peak picking method - each will get its own
    % set of 4 param_error structures, one for each parameter
    for peak_picking_name_idx = 1:length(pp_names)
        % Put the two deconvolutions with this type of peak-picking into
        % the variables anderson and summit
        assert(~exist('anderson','var')); % The variables should have been cleared last iteration
        assert(~exist('summit','var')); % The variables should have been cleared last iteration
        peak_picking_name = pp_names{peak_picking_name_idx};
        for deconv_idx = 1:length(deconvs)
            d = deconvs(deconv_idx);
            if strcmp(d.peak_picker_name, peak_picking_name)
                switch d.starting_point_name
                    case GLBIO2013Deconv.dsp_anderson
                        assert(~exist('anderson','var')); % We shouldn't ever assign twice here
                        anderson = d;
                    case GLBIO2013Deconv.dsp_smallest_peak_first
                        assert(~exist('summit','var')); % We shouldn't ever assign twice here
                        summit = d;
                    otherwise
                        error('GLBIO2013Analyze:unknown_starting_point', ...
                            'Unknown starting point "%s" found in GLBIO results at index %d', ...
                            d.starting_point, results_idx);
                end
            end
        end
        assert(isa(anderson, 'GLBIO2013Deconv'));
        assert(isa(summit, 'GLBIO2013Deconv'));

        % Calculate the errors for those two deconvolutions
        anderson_errors = param_errors(anderson, datum);
        summit_errors = param_errors(summit, datum);

        % For each parameter of the peaks in the deconvolution, fill a
        % param_error structure and add it to the list
        num_params = length(parameter_names);
        for param_idx = 1:num_params
            % Initialize pe, the new param_error entry
            pe.collision_prob = collision_prob;
            pe.peak_picking_name = peak_picking_name;
            pe.parameter_name = parameter_names{param_idx};
            pe.datum_id = datum_id;
            pe.mean_error_anderson = mean(anderson_errors(param_idx:num_params:end));
            pe.mean_error_summit = mean(summit_errors(param_idx:num_params:end));
            pe.error_diff = pe.mean_error_anderson - pe.mean_error_summit;

            % Assign it to the list of param_error_list 
            param_error_list(param_error_list_idx) = pe;
            param_error_list_idx = param_error_list_idx + 1;
        end

        clear('anderson','summit');
    end

end


end