function [ peak_ppm, peak_idx ] = peak_loc_estimate_for_random_spec( spec, noise_std )
% Return estimated peak locations for a randomly generated spectrum with a specific noise level 
%
% Usage: [peak_ppm, peak_idx] = PEAK_LOC_ESTIMATE_FOR_RANDOM_SPEC(spec, noise_std)
%
% NOTE: uses the random number generator
%
% All peak picking algorithms depend in some way on estimating the noise
% content of the spectrum from the data. Paul's algorithm uses 30 points
% from a peak-free region at the end of the spectrum to estimate that
% noise.
%
% Unlike normal spectra the randomly generated spectra don't have a
% specific peak free region that can be sampled to get a noise estimate. So
% this routine first generates 30 points of Gaussian noise, then estimates
% their standard deviation. Then finds the locations of peaks using that
% number of standard deviations. Obviously this method is only good for the
% randomly generated spectra.
%
% Input Parameters:
%
% spec - (struct) with fields x and Y. x is a row vector of ppm coordinates
%        and Y is a column vector of intensities. These are chosen because
%        it corresponds with the spectra returned by load_collection
% 
% noise_std - (scalar) gives the standard deviation of the Gaussian noise
%        that will be generated to estimate the noise standard deviation of
%        the spectrum
%
% Output parameters:
%
% peak_ppm - (vector) the ppm values at which peaks were found
%
% peak_idx - (vector) parallel vector giving the indices in the x and Y
%            vectors at which the peaks lie.

noise = randn(30,1).*noise_std;
est_std = std(noise);

peak_idx = wavelet_find_maxes_and_mins(spec.Y, est_std);
peak_ppm = spec.x(peak_idx);

end

