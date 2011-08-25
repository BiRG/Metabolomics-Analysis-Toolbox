function [ errors_were_found ] = errors_found_in_region_deconvolution( num_spectra, noise_amplitude, print_details )
% Return true if significant errors were found in region deconvolution routines
%
% Generate a spectral collection with 
% compute_test_collection(num_spectra, noise_amplitude)  Then evaluate the
% success of region_deconvolution in deconvolving those peaks according to
% hard-coded standards.  If the deconvolution is not acceptable
% errors_were_found is set to true.  Otherwise, it is set to false.
%
% If print_details is present and true then details on the performance are
% output using fprintf
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% num_spectra      The number of spectra generated
%
% noise_amplitude  The amplitude of the Gaussian white noise added to the
%                  signal after generation
%
% print_details    (optional) If present and true, details on the
%                  performance are output using fprintf.  Otherwise the run
%                  is silent
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% errors_were_found  True if the deconvolutions were not up to standard.
%                    False otherwise
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% errs=errors_found_in_region_deconvolution(5, 0.3)
%
% Will evaluate the deconvolutions for 5 spectra with additive noise of
% 0.3.  No results will be printed but errs will be true if there is a
% problem.
%
% errs=errors_found_in_region_deconvolution(5, 0.3, 1)
%
% Same as above, but this time, detailed statistics on the performance of
% the deconvolution routine on each peak will be printed

if nargin < 3
    print_details = 0;
end

[collection, bin_map, correct_deconvolved, correct_deconv_peak_obj, peak_obj] = ...
         compute_test_collection(num_spectra, noise_amplitude);
num_bins = length(bin_map);
     
% Create the list of peaks
pristine_peak_xs = cell(1,num_spectra);
for spec_idx =1:num_spectra
    objs = peak_obj(:, spec_idx);
    if isempty(objs)
        xs = [];
    else
        xs = [objs.location];
    end
    pristine_peak_xs{spec_idx} = xs;
end

% Do the deconvolution
wait_handle = waitbar(0,...
    sprintf('Deconvolving (bin, peak) = (0,0) of (%d,%d)', ...
        num_bins, num_spectra));
    
decs(num_bins, num_spectra) = RegionDeconvolution;
total_deconvs = num_bins*num_spectra;
completed_deconvs = 0;
for bin_idx = 1:num_bins
	bin = bin_map(bin_idx);
    for spec_idx = 1:num_spectra
        waitbar((completed_deconvs + 1) / total_deconvs, wait_handle, ...
        	sprintf('Deconvolving (bin, peak) = (%d,%d) of (%d,%d)', ...
            bin_idx, spec_idx, num_bins, num_spectra));
        
        decs(bin_idx, spec_idx) = RegionDeconvolution(collection.x, ...
            collection.Y(:, spec_idx), pristine_peak_xs{spec_idx}, ...
            2*(bin.bin.left - bin.bin.right), bin.bin.right, bin.bin.left);
        
        completed_deconvs = completed_deconvs + 1;
    end
end
delete(wait_handle);

% Find the target peaks in the deconvolution

% This would be filled in with code to do the matching and then output
% appropriate statistics, however, I think it might be better to have a
% human in the loop.  So, I'm going to save this and partially start over.

errors_were_found = 0; % TODO: stub output line

end

