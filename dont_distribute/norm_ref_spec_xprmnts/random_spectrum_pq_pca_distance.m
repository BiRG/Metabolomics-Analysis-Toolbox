function [pq_norm_dist, sum_norm_dist, correct_dist] = random_spectrum_pq_pca_distance( num_controls, num_spectra, num_samples )
% Returns the distance between the centroids after pca of random spectra before and after normalization 
%
% Generates random spectra (num_samples evenly spaced measurements with 
% 1 standard deviation gaussian noise added to a 3*cos^2 wave with a 
% period of 8 samples on num_samples). They are initially assumed to be 
% normalized correctly. Also from each of these, generates a 
% sum-normalized (to 1000) and probabilistic quotient normalized version
% which uses only the control spectra to generate its reference spectra.
% Each version is transferred to pca space and divided into two groups, the
% first num_controls spectra are the controls. The other spectra are the
% treatment. The centroids of the pca projections are taken, the 
% hyper-rectangle containing all the samples in this space is scaled to 
% the 0..1 hypercube. Then, the distance between the centroids is measured. 
% This distance is returned.

if num_controls >= num_spectra
    error('random_spectrum_pq_pca_distance:num_controls',['You must have '...
        'at least one treatment animal. The number of controls must be ' ...
        'less than the number of spectra.']);
end

original{1}.processing_log='Created.';
original{1}.x = (0:(num_samples-1)).*(2*pi()/8);
base = 3*(cos(original{1}.x').^2);
original{1}.Y=repmat(base, 1, num_spectra);
original{1}.Y=original{1}.Y + randn(size(original{1}.Y));

sum_norm = sum_normalize(original, 1000);
pq_norm = pq_normalize(original, original, 1000, {[true(1,num_controls),false(1,num_spectra-num_controls)]}, true(size(original{1}.x)));

correct_dist = pca_centroid_dist(original{1}.Y(:, 1:num_controls), original{1}.Y(:, num_controls+1:end), 2);
sum_norm_dist = pca_centroid_dist(sum_norm{1}.Y(:, 1:num_controls), sum_norm{1}.Y(:, num_controls+1:end), 2);
pq_norm_dist = pca_centroid_dist(pq_norm{1}.Y(:, 1:num_controls), pq_norm{1}.Y(:, num_controls+1:end), 2);


end

