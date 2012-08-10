function results = pq_centroid_dist_experiment( num_experiments, num_controls, num_spectra, num_samples )
% results is a num_experiments x 3 array where the columns are
% pq_norm_dist, sum_norm_dist, correct_dist for each experiment

wait_h = waitbar(0, 'Initializing');
results = zeros(num_experiments, 3);
for i = 1:num_experiments
    waitbar((i-1)/num_experiments, wait_h, sprintf('Experiment %d of %d',...
        i, num_experiments));
    [pq_norm_dist, sum_norm_dist, correct_dist] = random_spectrum_pq_pca_distance( num_controls, num_spectra, num_samples );
    results(i,:) = [pq_norm_dist, sum_norm_dist, correct_dist];
end

delete(wait_h);

end

