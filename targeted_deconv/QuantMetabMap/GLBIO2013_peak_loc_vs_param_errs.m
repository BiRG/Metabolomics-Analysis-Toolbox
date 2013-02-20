function loc_param_errs = GLBIO2013_peak_loc_vs_param_errs(results)
% From pp_noisy_gold_standard extracts 
%
% results - an array of GLBIO2013Datum
%
% loc_param_errs - (3d struct array) loc_param_errs(i,j,k) holds results for
%                  the i'th collision probability (that is, i/10 - the
%                  approximate probability that there was at least one
%                  missing local maximum in a spectrum of this width) and
%                  the j'th parameter (which are in the order from the peak
%                  parameters array input to GaussLorentzPeak - {'height',...
%                  'width-at-half-height','lorentzianness', and 
%                  'location'}) and the k'th starting point method. 1 if
%                  the anderson starting point, 2 if the summit starting
%                  point.
%
%                  Each cell contains a structure array whose
%                  parameters are given below:
%
% Fields of the loc_param_errs structure: 
%
% peak_loc_error - (row vector) the list of absolute differences in values
%                  between the values for the peak location picked by the
%                  peak picker and the actual location for this peak for
%                  each peak, parameter pair meeting the criteria of the
%                  indices into the array.
%
% param_error - (row vector) the list of errors for each peak,parameter 
%               pair meeting the criteria of the indices into the array

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

    function errs = picker_loc_errors(deconv, datum)
        % Return list of the errors between deconv and datum
        %
        % Returns the differences in the peak-picked locations and the
        % actual locations in for each peak the same order as that returned
        % by param_errors. If not all the picked peaks made it through the
        % rest of the deconvolution process, only those matching peaks that
        % did make it through are used to generate an error vector. The
        % rest are ignored.
        %
        % deconv - a GLBIO2013Deconv object whose parent is datum and whose
        %          peak picking method is pp_noisy_gold_standard
        %
        % datum - a GLBIO2013Datum object
        %
        % errs - Absolute value of the difference between the value picked
        %        for the peak and the actual location for the peak.
        assert(isa(deconv,'GLBIO2013Deconv'));
        assert(isa(datum,'GLBIO2013Datum'));
        assert(strcmp(deconv.datum_id,datum.id));
        assert(strcmp(deconv.peak_picker_name, GLBIO2013Deconv.pp_noisy_gold_standard));
        
        datum_peaks  = datum.spectrum_peaks(deconv.aligned_indices(1,:));
        datum_locs = [datum_peaks.location];
        picked_locs = deconv.picked_locations(deconv.aligned_indices(1,:));
        try
            errs = abs(datum_locs - picked_locs);
        catch ME
            %TODO: the try catch block is DEBUG code
            fprintf('%s\n',ME.message);
        end
end


num_results = length(results);
num_params = 4;
num_probs = 10;
num_starting_pt = 2;


% The names for the parameter at offset i in the peak parameters list
% returned by GaussLorentzPeak>property_array
parameter_names = {'height','width-at-half-height','lorentzianness','location'};
assert(num_params == length(parameter_names));

% Param error structure has 12 = 4*3 = #params*#peak_pickers per result.
% Preallocate it with contents being empty arrays
loc_param_errs(num_probs, num_params, num_starting_pt)=...
    struct('peak_loc_error',[],'param_error',[]);


% Convert the list of results into a (larger) list of param_error
% structures
for results_idx = 1:num_results
    % Set initial shortcut variables that are constant for all param_error
    % structures generated from this result
    datum = results(results_idx);
    deconvs = datum.deconvolutions;
    collision_prob = collision_prob_for_width(datum.spectrum_width);
    collision_prob_idx = round(collision_prob * 10);

       
    % Put the two deconvolutions with this type of peak-picking into
    % the variables anderson and summit
    assert(~exist('anderson','var')); % The variables should have been cleared last iteration
    assert(~exist('summit','var')); % The variables should have been cleared last iteration
    for deconv_idx = 1:length(deconvs)
        d = deconvs(deconv_idx);
        if strcmp(d.peak_picker_name, GLBIO2013Deconv.pp_noisy_gold_standard)
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
    anderson_picker_errors = picker_loc_errors(anderson, datum);
    if length(anderson_errors) ~= 4*length(anderson_picker_errors)        
        fprintf('Unequal anderson lengths.\n');
    end
    summit_errors = param_errors(summit, datum);
    summit_picker_errors = picker_loc_errors(anderson,datum);
    if length(summit_errors) ~= 4*length(summit_picker_errors)        
        fprintf('Unequal summit lengths.\n');
    end
    
    % For each parameter of the peaks in the deconvolution, add to the
    % lists of error pairs for the the appropriate entry for that 
    num_params = length(parameter_names);
    for param_idx = 1:num_params
        pe = loc_param_errs(collision_prob_idx, param_idx, 1);
        pe.peak_loc_error = [pe.peak_loc_error, anderson_picker_errors];
        pe.param_error = [pe.param_error, anderson_errors(param_idx:4:end)];
        loc_param_errs(collision_prob_idx, param_idx, 1) = pe;

        pe = loc_param_errs(collision_prob_idx, param_idx, 2);
        pe.peak_loc_error = [pe.peak_loc_error, summit_picker_errors];
        pe.param_error = [pe.param_error, summit_errors(param_idx:4:end)];
        loc_param_errs(collision_prob_idx, param_idx, 2) = pe;
    end

    clear('anderson','summit');

end


end