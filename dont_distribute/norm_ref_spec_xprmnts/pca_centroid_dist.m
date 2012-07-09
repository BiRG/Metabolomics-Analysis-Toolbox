function dist = pca_centroid_dist( v1, v2, dims )
% Calculates the projection of v1 and v2 onto dims principal components and returns the distance between their centroids.
%
% The rows of v1 and v2 are variables and the columns are samples.
% v1 and v2 are first combined into one array and the projection is taken.
% The first dim dimensions are taken these dimensions are translated and 
% scaled to the [0..1] hyper-rectangle. Then, the distance between the 
% centroids is measured. This distance is returned.
[unused, scores] = princomp([v1 v2]'); %#ok<ASGLU>

scores = scores(:, 1:dims);

% Scale scores to 0..1
mins = min(scores, [], 1);
scores = scores - repmat(mins, size(scores,1), 1);
maxes = max(scores, [], 1);
scores = scores ./ repmat(maxes, size(scores,1), 1);
scores(isnan(scores)) = 0; %Take care of the case where all were identical

% Separate out scores into original groups
v1 = scores(1:size(v1,2), :);
v2 = scores(size(v1,1):end, :);

% Calculate centroids
centroid1=mean(v1,1);
centroid2=mean(v2,1);

% Find the distance
dist = sum((centroid1-centroid2).^2).^0.5;

end

