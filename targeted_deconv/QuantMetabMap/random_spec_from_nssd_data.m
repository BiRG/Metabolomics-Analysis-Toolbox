function [spec,peaks] = random_spec_from_nssd_data(num_peaks,min_ppm, max_ppm, num_intensities, noise_std)
% Usage: spec = RANDOM_SPEC_FROM_NSSD_DATA(num_peaks,min_ppm, max_ppm, num_intensities, noise_std)
%
% Uses data derived from the NSSD deconvolution as the distribution from
% which to draw parameters in the peaks in a random spectrum. The heights
% will be scaled so that the highest point in the noiseless spectrum has 
% height 1 - the only exception to this is when there are no peaks - at 
% which point, all heights in the noiseless spectrum will be 0.
% 
% With params:
%
% num_peaks       - (scalar) number of peaks to generate - must be 0 or 
%                   more.
% min_ppm         - (scalar) the minimum ppm to generate. The generated
%                   ppms will be chosen uniformly on the closed interval
%                   [min_ppm,max_ppm]
% max_ppm         - (scalar) the maximum ppm to generate. The generated
%                   ppms will be chosen uniformly on the closed interval
%                   [min_ppm,max_ppm]
% num_intensities - (scalar) number of intensities to generate in the
%                   interval must be at least 1.
% noise_std       - (scalar) the standard deviation of the Gaussian noise.
%                   Since the highest peak will have height 1, 1/noise_std
%                   will be the SNR of the generated spectrum. Must be 
%                   non-negative.
%
% Return:
%
% spec - a spectral collection struct like that returned from
%        load_collection. See there for format.
%
% peaks - a row vector of GaussLorentzPeak objects containing the peaks 
%         used to generate the spectrum. There will be exactly num_peaks 
%         entries in the vector.
%
% Note: the mean half height width is 0.00453630122481774988


% The distributions are described in terms of uniform bins. To sample from
% one of these distributions, first choose a bin (uniformly) then choose 
% uniformly within the interval. I have already introduced duplicate
% bins to take care of duplicate values in the original data.
%
% width_dist is the distribution of width at half-height values for
%            all the peaks for the spectra in which they were measured
%
% height_dist is the distribution of the peak heights that were not the
%             maximum in their spectrum. Since these spectra were of single
%             compounds this is not the best height distribution to use
%             Most of the heights would be significantly lower than the
%             maximum - unlike a real spectrum in which many heights would
%             be similar. I will just use the heights directly from this
%             distribution. Imperfect as it is, it is still likely more
%             realistic than choosing from a Gaussian
%
% lor_dist is the distribution of the lorentzianness parameter for those 
%            spectra for which I measured it. There are a lot of high and 
%            a lot of low and then a relatively uniform distribution 
%            between the extremes. It looks almost like a beta
%            distribution. 
%
% ppm_dist is the distribution from which the ppms will be drawn - it
%            consists of only a single bin. Because the distribution is
%            uniform, it happens to be represented exactly.

assert(isscalar(num_peaks));
assert(num_peaks >= 0);
assert(isscalar(min_ppm));
assert(isscalar(max_ppm));
assert(isscalar(num_intensities));
assert(num_intensities >= 1);
assert(isscalar(noise_std));
assert(noise_std >= 0);

width_dist  = nssd_data_dist('width');
height_dist = nssd_data_dist('height');
lor_dist    = nssd_data_dist('lorentzianness');
ppm_dist.min = min_ppm;
ppm_dist.max = max_ppm;

    function vals = bin_approx_sample(dist, num_samples)
        % Return iid samples from the distribution dist in a row vector. 
        %
        % The name comes from being a sample from a bin approximation to a
        % continuous distribution.
        %
        % dist - a struct array with scalar fields min and max. Dist
        %        approximates a continuous distribution as a mixture of 
        %        uniforms. Assumed to be a row vector
        % num_samples - the number of samples to take from the distribution
        %
        % First choose a bin (one index in dist) then choose uniformly on
        % the closed interval represented by dist(i). Due to the random 
        % number generator in Matlab, I actually will be choosing on the 
        % open interval with those two points as the endpoints.
        vals = rand(1, num_samples);
        bins = randi(length(dist), 1, num_samples);
        mins  = [dist(bins).min];
        widths = [dist(bins).max]-mins;
        vals = vals.*widths + mins;
    end

spec.x = fliplr(linspace(min_ppm, max_ppm, num_intensities));

if num_peaks > 0
    peak_params = zeros(1,4*num_peaks);
    peak_params(1:4:end) = bin_approx_sample(height_dist, num_peaks);
    peak_params(2:4:end) = bin_approx_sample(width_dist, num_peaks);
    peak_params(3:4:end) = bin_approx_sample(lor_dist, num_peaks);
    peak_params(4:4:end) = bin_approx_sample(ppm_dist, num_peaks);

    % Find out how much we need to scale by producing a spectrum
    peaks = GaussLorentzPeak(peak_params);
    spec.Y = sum(peaks.at(spec.x),1)';
    scale_factor = 1 / max(spec.Y);
    
    % Scale the peaks
    peak_params(1:4:end) = peak_params(1:4:end) .* scale_factor;
    peaks = GaussLorentzPeak(peak_params);
    
    % Produce the spectrum again with the scaled peaks
    spec.Y = sum(peaks.at(spec.x),1)';
else
    peaks = GaussLorentzPeak([]);
    spec.Y = zeros(num_intensities,1);
end

spec.Y = spec.Y + (randn(size(spec.Y))*noise_std);

spec.input_names = {'Collection ID', 'Type', 'Description', 'Processing log', 'Base sample ID', 'Time', 'Classification', 'Sample ID', 'Subject ID', 'Sample Description', 'Weight', 'Units of weight', 'Species'};
spec.formatted_input_names = {'collection_id', 'type', 'description', 'processing_log', 'base_sample_id', 'time', 'classification', 'sample_id', 'subject_id', 'sample_description', 'weight', 'units_of_weight', 'species'};
spec.collection_id=sprintf('%d',-randi(200)-1500);
spec.type='SpectraCollection';
spec.description=sprintf(['Random spectrum for evaluating '...
    'deconvolution']);
spec.processing_log='Created by random_spec_From_nssd_data.';
spec.num_samples=1; 
spec.time=0;
spec.classification={'Random spectrum'};
spec.sample_id=1;
spec.subject_id=1;
spec.sample_description=spec.classification;
spec.weight=1;
spec.units_of_weight=arrayfun(@(x) 'No weight unit',1:1,'UniformOutput',false);
spec.species=arrayfun(@(x) 'No species',1:1,'UniformOutput',false);
spec.base_sample_id=1;


end

