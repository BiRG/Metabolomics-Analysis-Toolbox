function collections = histogram_normalize(collections, baseline_pts, n_std_dev, num_bins, use_waitbar)
% Applies Torgrip's histogram normalization to the spectra 
%
% collections = HISTOGRAM_NORMALIZE(collections, baseline_pts, std_dev, num_bins, use_waitbar)
%
% Uses the algorithm from "A note on normalization of biofluid 1D 1H-NMR
% data" by R. J. O. Torgrip, K. M. Aberg, E. Alm, I. Schuppe-Koistinen and
% J. Lindberg published in Metabolomics (2008) 4:114–121, 
% DOI 10.1007/s11306-007-0102-2
%
% To normalize nmr spectra.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% collections  - a cell array of spectral collections. Each spectral
%                collection is a struct. This is the format
%                of the return value of load_collections.m in
%                common_scripts. All collections must use the same set of x
%                values. Check with only_one_x_in.m
%
% baseline_pts - the number of points to use at the beginning of each
%                spectrum to estimate the mean of the baseline and the
%                standard deviation of the noise
%
% n_std_dev    - all samples less than n_std_dev * noise_standard_deviation
%                are ignored in creating the histogram.
%
% num_bins     - the number of bins to use in the histogram
%
% use_waitbar  - if true then a waitbar is displayed during processing
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% collections - the collections after normalization. The processing log is
%               updated and the histograms are all multiplied by their
%               respective dilution factors.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> collections = histogram_normalize(collections, 30, 5, 60, true)
%
% uses histogram normalization on the spectra in collections, using the
% first 30 points for a baseline estimate and excluding all points in a
% spectrum that fall below 5 standard deviations above the mean of that
% estimate. It bins the intensities into 60 bins uses a waitbar to report 
% progress to the user.
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (May 2012) eric_moyer@yahoo.com
%

if use_waitbar; wait_h = waitbar(0,'Initializing histogram normalization'); end

baseline_samples = cellfun(@(in) in.Y(1:baseline_pts,:), collections, 'UniformOutput', false);
baseline_mean = cellfun(@(in) mean(in,1), baseline_samples, 'UniformOutput', false);
baseline_std  = cellfun(@(in) std(in,1), baseline_samples, 'UniformOutput', false);

msgbox('Histogram normalization not yet implemented.','Not implemented', 'Error');

if use_waitbar; delete(wait_h); end;

end

