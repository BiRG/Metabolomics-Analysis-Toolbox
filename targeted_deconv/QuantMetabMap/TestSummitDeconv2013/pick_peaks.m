function peaks_per_picker = pick_peaks(spectrum, peaks, noise_std)
% Returns the peaks picked by all peak pickers on the given spectrum generated from peaks with noise_std white gaussian noise added 
% 
% Usage: peaks_per_picker = pick_peaks(spectrum, peaks, noise_std)
%
% NOTE: due to lack of "peak free" regions in the test spectra,
% "pp_smoothed_local_max" and "pp_gold_std_aligned_with_local_max" use the
% random number generator. See peak_loc_estimate_for_random_spec. They 
% will, however, use the same random estimate.
%
% -----------------------------------------
% Input Args
% -----------------------------------------
%
% spec - (struct) with fields x and Y. x is a row vector of ppm coordinates
%    and Y is a column vector of intensities. These are chosen because it
%    corresponds with the spectra returned by load_collection and because
%    it is the input to peak_loc_estimate_for_random_spec
%
% peaks - (GaussLorentzPeak array) the peaks used to generate spec
%
% noise_std - (non-negative scalar) the standard deviation of the noise
%    added to peaks.at(spec.x) when creating spec.
%
% -----------------------------------------
% Output Args
% -----------------------------------------
%
% peaks_per_picker - (cell array) peaks_per_picker{i} contains the list of
%    peaks picked by the peak picker named
%    ExpDeconv.peak_picker_names{i}
%
% -----------------------------------------
% Examples
% -----------------------------------------
%
% 
% -----------------------------------------
% Author
% -----------------------------------------
%
% Eric Moyer (March 2013)

mean_peak_width = 0.00453630122481774988; % Width of the mean peak in ppm

picker_names = ExpDeconv.peak_picking_method_names;
smoothed_local_max_locs = peak_loc_estimate_for_random_spec(spectrum, noise_std);
peaks_per_picker = picker_names;
for picker_idx = 1:length(picker_names)
    peak_picker_name = picker_names{picker_idx};
    switch(peak_picker_name)
        case ExpDeconv.pp_gold_standard
            picked_locations = [peaks.location];
        case ExpDeconv.pp_noisy_gold_standard
            picked_locations = [peaks.location];
            picked_locations = picked_locations + (mean_peak_width/16).*randn(size(picked_locations));
        case ExpDeconv.pp_smoothed_local_max
            picked_locations = smoothed_local_max_locs;
        case ExpDeconv.pp_gold_std_aligned_with_local_max
            picked_locations = smoothed_local_max_locs;
            orig_locations = [peaks.location];
            assignment = ExpDeconv.l_p_norm_assignment(picked_locations, orig_locations, 2);
            picked_locations = orig_locations(assignment(assignment > 0));
        otherwise
            % Detects additional methods having been added and no case
            % added to the switch statement
            error('GLBIO2013:unknown_pp_method', ...
                'Unknown peak picking method "%s" specified.',...
                peak_picker_name);
    end
    picked_locations = sort(picked_locations);
    peaks_per_picker{picker_idx} = picked_locations;
end
