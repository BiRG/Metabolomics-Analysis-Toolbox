function loc_param_errs = GLBIO2013_peak_loc_vs_param_errs(results)
% From pp_noisy_gold_standard extracts 
%
% results - an array of GLBIO2013Datum
%
%
% loc_param_errs - (3d struct array) loc_param_errs(i,j,k) holds
%     results for the i'th collision probability (that is, i/10 - the
%     approximate probability that there was at least one missing
%     local maximum in a spectrum of this width) and the j'th
%     parameter (which are in the order from the peak parameters array
%     input to GaussLorentzPeak - {'height',...
%     'width-at-half-height','lorentzianness', and 'location'}) and
%     the k'th starting point method. 1 if the anderson starting
%     point, 2 if the summit starting point.
%
%     Each cell contains a structure array whose parameters are given
%     below:
%
% Fields of the loc_param_errs structure: 
%
% peak_loc_error - (row vector) the list of absolute differences in
%     values between the values for the peak location picked by the
%     peak picker and the actual location for this peak for each peak,
%     parameter pair meeting the criteria of the indices into the
%     array.
%
% peak_width - (row vector) the list of the actual peak widths for
%     each peak,parameter pair meeting the criteria of the indices
%     into the array
%
% param_error - (row vector) the list of errors for each
%     peak,parameter pair meeting the criteria of the indices into the
%     array
%
% result_idx - (row vector) the index (in results) of the result from
%     which the peak,parameter pair came
%
% deconv_idx - (row vector) the index of the deconvolution in
%     results(result_idx).deconvolutions from which the peak,parameter pair
%     came
%
% orig_pk_idx - (row vector) the index in 
%     results(result_idx).spectrum_peaks from which the original peak came.
%
% deconv_pk_idx - (row vector) the index in
%     results(result_idx).deconvolutions(deconv_idx).peaks which holds the
%     estimated peak from which the peak,parameter pair came
%
% picked_loc - (row vector) original location picked by the peak-picker for
%     this peak,parameter pair


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

    function [errs,picked_locs] = picker_loc_errors(deconv, datum)
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
        %     peak picking method is pp_noisy_gold_standard
        %
        % datum - a GLBIO2013Datum object
        %
        % errs - Absolute value of the difference between the value picked
        %     for the peak and the actual location for the peak.
        %
        % picked_locs - the original location picked by the peak picker 
        %     from which the error was measured.
        assert(isa(deconv,'GLBIO2013Deconv'));
        assert(isa(datum,'GLBIO2013Datum'));
        assert(strcmp(deconv.datum_id,datum.id));
        assert(strcmp(deconv.peak_picker_name, GLBIO2013Deconv.pp_noisy_gold_standard));
        
        % Take original peaks in their order aligned with the output
        datum_peaks = datum.spectrum_peaks(deconv.aligned_indices(1,:));
        datum_locs = [datum_peaks.location];
        
        % Take the peak picker output and align it to the reordered
        % original peaks
        picked_locs = deconv.picked_locations;
        assignment = GLBIO2013Deconv.least_squares_assignment(datum_locs, picked_locs);
        picked_locs = picked_locs(assignment(assignment > 0));
        
        % Subtract
        errs = abs(datum_locs - picked_locs);
    end


num_results = length(results);
num_params = 4;
num_probs = 10;
num_starting_pt = 2;
anderson_idx = 1;
summit_idx = 2;

% The names for the parameter at offset i in the peak parameters list
% returned by GaussLorentzPeak>property_array
parameter_names = {'height','width-at-half-height','lorentzianness','location'};
assert(num_params == length(parameter_names));

% Preallocate results with contents being empty arrays
loc_param_errs(num_probs, num_params, num_starting_pt)=...
    struct('peak_loc_error',[],'peak_width',[],'param_error',[], ...
        'result_idx', [], 'deconv_idx', [], 'orig_pk_idx', [], ...
        'deconv_pk_idx', [], 'picked_loc', []);

% Convert the list of results into a (larger) list of loc_param_error
% structures
for results_idx = 1:num_results
    % Set initial shortcut variables that are constant for all
    % loc_param_error structures generated from this result
    datum = results(results_idx);
    deconvs = datum.deconvolutions;
    collision_prob = collision_prob_for_width(datum.spectrum_width);
    collision_prob_idx = round(collision_prob * 10);


    % Put the two deconvolutions with noisy gold standard peak picking into
    % ngs. ngs(anderson_idx) holds the anderson deconvolution and
    % ngs(summit_idx) holds the summit-focused deconvolution. ngs is
    % cleared each iteration
    ngs = cell(1, num_starting_pt); % Preallocate ngs
    ngs_deconv_idx = zeros(1, num_starting_pt);
    for deconv_idx = 1:length(deconvs)
        d = deconvs(deconv_idx);
        if strcmp(d.peak_picker_name, GLBIO2013Deconv.pp_noisy_gold_standard)
            switch d.starting_point_name
                case GLBIO2013Deconv.dsp_anderson
                    assert(isempty(ngs{anderson_idx})); % We shouldn't ever assign twice here
                    ngs{anderson_idx} = d;
                    ngs_deconv_idx(anderson_idx) = deconv_idx;
                case GLBIO2013Deconv.dsp_smallest_peak_first
                    assert(isempty(ngs{summit_idx})); % We shouldn't ever assign twice here
                    ngs{summit_idx} = d;
                    ngs_deconv_idx(summit_idx) = deconv_idx;
                otherwise
                    error('GLBIO2013Analyze:unknown_starting_point', ...
                        'Unknown starting point "%s" found in GLBIO results at index %d', ...
                        d.starting_point_name, results_idx);
            end
        end
    end
    ngs = [ngs{:}];

    % Calculate the errors for those two deconvolutions
    %
    % ngs(1, start_pt_idx) is the current deconvolution - the
    % noisy-gold-standard deconvolution for the current starting point.
    for start_pt_idx = 1:num_starting_pt
        cur_deconv = ngs(1, start_pt_idx);
        cur_deconv_idx = ngs_deconv_idx(1, start_pt_idx);
        param_e = param_errors(cur_deconv, datum);
        [picker_e, picker_locs] = picker_loc_errors(cur_deconv, datum);
        peak_widths = [datum.spectrum_peaks.half_height_width];
        assert(length(param_e) == 4*length(picker_e));

        % For each parameter of the peaks in the deconvolution, add to the
        % lists of error pairs 
        for param_idx = 1:num_params
            % Copy the current value out of the array
            pe = loc_param_errs(collision_prob_idx, param_idx, start_pt_idx);
            
            % Add the errors
            pe.peak_loc_error = [pe.peak_loc_error picker_e];
            pe.peak_width = [pe.peak_width peak_widths];
            pe.param_error = [pe.param_error param_e(param_idx:4:end)];
            
            % Add the metadata for reconstructing which peaks etc.
            %  generated the errors
            pe.result_idx = [pe.result_idx repmat(results_idx, size(picker_e))];
            pe.deconv_idx = [pe.deconv_idx repmat(cur_deconv_idx, size(picker_e))];
            pe.orig_pk_idx = [pe.orig_pk_idx cur_deconv.aligned_indices(1,:)];
            pe.deconv_pk_idx = [pe.deconv_pk_idx cur_deconv.aligned_indices(2,:)];
            pe.picked_loc = [pe.picked_loc picker_locs];
            
            % Put that value back in the array
            loc_param_errs(collision_prob_idx, param_idx, start_pt_idx) = pe;
        end
    end
    
    clear('ngs');

end


end
