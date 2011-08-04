function collection = find_peaks(collection)
min_width = 30; % For noise calculation only
[num_variables,num_spectra] = size(collection.Y);
collection.maxs = {};
collection.mins = {};
collection.include_mask = {};
collection.BETA = {};
collection.match_ids = {};
collection.Y_smooth = [];
for s = 1:num_spectra
    noise_std = std(collection.Y(1:min_width,s));
    % Find the minimums so we can divide the spectra appropriately
    [maxs,mins,y_smooth] = wavelet_find_maxes_and_mins(collection.Y(:,s),noise_std); % Find the peak locations
    collection.maxs{s} = maxs;
    collection.mins{s} = mins;
    collection.include_mask{s} = 0*maxs+1; % Include all by default
    collection.BETA{s} = zeros(4*length(maxs),1);
    collection.BETA{s}(4:4:end) = collection.x(maxs);
    collection.Y_smooth(:,s) = y_smooth;
    collection.match_ids{s} = [];
end