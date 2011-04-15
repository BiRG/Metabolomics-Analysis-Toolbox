function spectra = create_spectra(x,Y,left_noise,right_noise,all_options,percentile)
xwidth = abs(x(1)-x(2));

% This will be set to the optimal from the previous experiment
options = all_options.peak_finding_options;

spectra = {};
inxs = find(left_noise >= x & x >= right_noise);
nm = size(Y);
num_samples = nm(2);
num_filtered = 0;
max_heights = [];
if ~exist('percentile')
    percentile = all_options.peak_finding_options.percentile;
end
for s = 1:num_samples
    spectra{s}.noise_std = std(Y(inxs,s));
    spectra{s}.mean = mean(Y(inxs,s));
    [spectra{s}.y_smoothed,spectra{s}.all_maxs,spectra{s}.all_mins] = smooth(Y(:,s),spectra{s}.noise_std*options.noise_std_mult,options);
    if percentile > 0
        % Record the maximum heights
        for m = 1:length(spectra{s}.all_maxs)
            max_inx = spectra{s}.all_maxs(m);
            min_inxs = spectra{s}.all_mins(m,:);
            observed_peak = Y(min_inxs(1):min_inxs(end),s);
            observed_peak_x = x(min_inxs(1):min_inxs(end));
            height1 = Y(max_inx,s) - Y(min_inxs(1),s);
            height2 = Y(max_inx,s) - Y(min_inxs(end),s);
            observed_peak_min_height = min([height1,height2]);
            observed_peak_max_height = max([height1,height2]);
            tinxs = min_inxs(1):min_inxs(end);
            [vs,wixs] = sort(abs((Y(tinxs,s)-Y(min_inxs(1),s))-height1/2));
            wix = tinxs(wixs(1));
            width1 = 2*xwidth*abs(max_inx-wix);
            [vs,wixs] = sort(abs((Y(tinxs,s)-Y(min_inxs(end),s))-height2/2));
            wix = tinxs(wixs(1));
            width2 = 2*xwidth*abs(max_inx-wix);
            observed_peak_min_width = min([width1,width2]);
            observed_peak_max_width = max([width1,width2]);

            max_heights(end+1) = observed_peak_max_height;
        end
    end
end
if percentile > 0
    sorted_heights = sort(max_heights,'ascend');
    inx = round(length(sorted_heights)*(1-percentile/100));
    cutoff_height = NaN;
    if inx < 1
        cutoff_height = 0;
    else
        cutoff_height = sorted_heights(inx);
    end
    for s = 1:num_samples
        new_all_maxs = [];
        new_all_mins = [];
        for m = 1:length(spectra{s}.all_maxs)
            max_inx = spectra{s}.all_maxs(m);
            min_inxs = spectra{s}.all_mins(m,:);
            observed_peak = Y(min_inxs(1):min_inxs(end),s);
            observed_peak_x = x(min_inxs(1):min_inxs(end));
            height1 = Y(max_inx,s) - Y(min_inxs(1),s);
            height2 = Y(max_inx,s) - Y(min_inxs(end),s);
            observed_peak_min_height = min([height1,height2]);
            observed_peak_max_height = max([height1,height2]);
            if observed_peak_max_height >= cutoff_height
                new_all_maxs(end+1) = spectra{s}.all_maxs(m);
                new_all_mins(end+1,:) = spectra{s}.all_mins(m,:);            
            else
                num_filtered = num_filtered + 1;
            end
        end
        spectra{s}.all_maxs = new_all_maxs;
        spectra{s}.all_mins = new_all_mins;
    end
    fprintf('Number of filtered peaks: %d\n',num_filtered);
end