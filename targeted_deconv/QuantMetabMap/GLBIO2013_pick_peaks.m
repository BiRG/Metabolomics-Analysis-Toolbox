function peaks_per_picker = GLBIO2013_pick_peaks(spectrum, peaks, noise_std)
% Returns the peaks picked by all peak pickers on the given spectrum generated from peaks with noise_std white gaussian noise added 
% 
% Usage: peaks_per_picker = GLBIO2013_pick_peaks(spectrum, peaks, noise_std)
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
%    GLBIO2013Deconv.peak_picker_names{i}
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

%TODO: stub
peaks_per_picker = cell(size(GLBIO2013Deconv.peak_picking_method_names));
end