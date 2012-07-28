function is_under_threshold = samples_under_noise_threshold(collections, num_baseline_pts, num_std_dev)
%SAMPLES_UNDER_NOISE_THRESHOLD stub
% Remember to check for only_one_x
% Returns column vector - 1 entry per sample

is_under_threshold = true(size(collections{1}.Y(:,1));
for c = 1:length(collections)
    threshold = num_std_dev .* std(collections{c}.Y(1:num_baseline_pts, :), 0, 1);
    under_threshold = collections{c}.Y <= threshold;
    all_under_threshold = all(under_threshold, 2); % All items in row are under threshold
    is_under_threshold = is_under_threshold & all_under_threshold;
end

end

