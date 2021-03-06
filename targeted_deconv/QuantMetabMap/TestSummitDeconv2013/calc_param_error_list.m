function param_error_list = calc_param_error_list(results)
% Takes the results (an array of ExpDatum objects) and
% extracts more-easily analyzable statistics. Assumes that the
% results from the first call are always the results. Each result generates
% one element of the param_error_list for each combination of parameter
% (height, width, lorentzianness, location, and area) and peak-picking
% method.
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
%                  lorentzianness, location, and area
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
        % TestSummitDeconv2013 experiment, gives the approximate probability that a
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
            error('TestSummitDeconv2013:collison_prob_for_width:unknown_width', ...
                'The width %.18g is not in the list known from the experiments. You likely forgot to update the list after doing a new experiment.', width);
        end
        if sum(matches) > 1
            error('TestSummitDeconv2013:collison_prob_for_width:more_than_one_match', ...
                'Some of the widths in the list of experimental widths are too close together leading %.18g to match more than one', width);
        end
        p = probs(matches);
    end

    function vals = param_vals(peaks)
        % Return a list of the values of the parameters for a given set of peaks.
        %
        % These parameters are, in order: 'height','width-at-half-height',
        % 'lorentzianness','location', and area
        pvtmp = peaks.property_array;
        vals = zeros(1,round(length(pvtmp)*5/4)); 
        for i = 1:4
            vals(i:5:end) = pvtmp(i:4:end);
        end
        vals(5:5:end) = [peaks.area];
    end

    function errs = param_errors(deconv, datum)
        % Return list of the parameter-wise errors between deconv and datum
        %
        % Aligns the peaks of deconv and datum. Then takes the parameter
        % list of those aligned peaks. Returns the absolute value of the
        % difference between the two parameter lists.
        %
        % deconv - a ExpDeconv object whose parent is datum
        %
        % datum - a ExpDatum object
        %
        % errs - errs is an array in the same order as that returned by
        %        GaussLorentzPeak.property_array. It is the absolute value
        %        of the difference between the properties of the peaks in
        %        deconv and the corresponding peaks in datum.
        assert(isa(deconv,'ExpDeconv'));
        assert(isa(datum,'ExpDatum'));
        assert(strcmp(deconv.datum_id,datum.id));
        
        pdeconv = deconv.peaks(deconv.aligned_indices(2,:));
        pdatum  = datum.spectrum_peaks(deconv.aligned_indices(1,:));
        errs = abs(param_vals(pdeconv) - param_vals(pdatum));
    end


n = length(results);

% The names for the parameter at offset i in the peak parameters list
% returned by GaussLorentzPeak>property_array
parameter_names = {'height','width-at-half-height','lorentzianness','location','area'};
num_params = length(parameter_names);

% Shorter name for the list of possible peak-picking names
pp_names = ExpDeconv.peak_picking_method_names;

% Remove the peak-picking method names that are not used in the data set
name_used = false(size(pp_names));
for peak_picking_name_idx = 1:length(pp_names)
    for results_idx = 1:n
        datum = results(results_idx);
        deconvs = datum.deconvolutions;
        peak_picking_name = pp_names{peak_picking_name_idx};
        for deconv_idx = 1:length(deconvs)
            d = deconvs(deconv_idx);
            if strcmp(d.peak_picker_name, peak_picking_name)
                name_used(peak_picking_name_idx) = true;
                break;
            end
        end
        if name_used(peak_picking_name_idx)
            break;
        end
    end
end
pp_names = pp_names(name_used);

% Param error structure has 12 = 4*3 = #params*#peak_pickers per result.
% Preallocate it.
num_peak_pickers = length(pp_names);
num_error_list = num_params * num_peak_pickers * n;
param_error_list(num_error_list).collision_prob = 0;
param_error_list(num_error_list).peak_picking_name = '';
param_error_list(num_error_list).parameter_name = '';
param_error_list(num_error_list).datum_id = '';
param_error_list(num_error_list).mean_error_anderson = 0;
param_error_list(num_error_list).mean_error_summit = 0;
param_error_list(num_error_list).error_diff = 0;
param_error_list_idx = 1;

% Ignore some deconvolution starting points in the analysis (they weren't
% there when I originally wrote this code)
ignored_dsps = {ExpDeconv.dsp_summit_100_pctile, ...
    ExpDeconv.dsp_summit_100_pctile_baseline, ...
    ExpDeconv.dsp_summit_100_pctile_max_width_one_bin, ...
    ExpDeconv.dsp_summit_100_pctile_max_width_too_large, ...
    ExpDeconv.dsp_summit_max_width_one_bin, ...
    ExpDeconv.dsp_summit_max_width_too_large ...
    };


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
                    case ExpDeconv.dsp_anderson
                        assert(~exist('anderson','var')); % We shouldn't ever assign twice here
                        anderson = d;
                    case ExpDeconv.dsp_summit
                        assert(~exist('summit','var')); % We shouldn't ever assign twice here
                        summit = d;
                    case ignored_dsps
                        % Do nothing
                    otherwise
                        error('TestSummitDeconv2013:unknown_starting_point', ...
                            'Unknown starting point "%s" found in TestSummitDeconv2013 results at index %d', ...
                            d.starting_point_name, results_idx);
                end
            end
        end
        assert(isa(anderson, 'ExpDeconv'));
        assert(isa(summit, 'ExpDeconv'));

        % Calculate the errors for those two deconvolutions
        anderson_errors = param_errors(anderson, datum);
        summit_errors = param_errors(summit, datum);

        % For each parameter of the peaks in the deconvolution, fill a
        % param_error structure and add it to the list
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
