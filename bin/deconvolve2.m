function results = deconvolve2(x,y,maxs,mins,bins,deconvolve_mask,min_percent_change,max_generations,regions)
% x (d x 1) and y (d x 1)

y = interpolate_zeros(x,y);

regions = determine_regions(x,y,maxs,mins,bins,regions);
done_mask = zeros(1,length(regions));
regions = determine_initial_baseline(regions);

% Run twice to begin with
[y_peaks, y_baseline] = regions_to_global(regions,x,y);
prev_regions = fit_regions(regions,deconvolve_mask,done_mask,y_peaks);

generation = 1;
while (generation <= max_generations)
    [y_peaks, y_baseline] = regions_to_global(prev_regions,x,y);
    regions = fit_regions(prev_regions,deconvolve_mask,done_mask,y_peaks);
    
    % Check to see how each region has changed
    for r = 1:length(regions)
        if deconvolve_mask(r) && done_mask(r) == 0
            percent_change = 100*abs((sum(regions{r}.y_fit) - sum(prev_regions{r}.y_fit))/sum(prev_regions{r}.y_fit));
            if percent_change <= min_percent_change
                done_mask(r) = 1;
            end
        end
    end
    
    % Compare regions
    if false
        rs = [1,2,3];
        figure;
        subplot(1,2,1)
        for r = rs
            hold on
            h = plot(regions{r}.x,regions{r}.y,prev_regions{r}.x,prev_regions{r}.y_fit);
            if r == rs(1)
                legend(h,'y','prev y fit');
            end
            hold off
        end
        subplot(1,2,2)
        for r = rs
            hold on
            h = plot(regions{r}.x,regions{r}.y,regions{r}.x,regions{r}.y_fit);
            if r == rs(1)
                legend(h,'y','y fit');
            end
            hold off
        end
    end
    
    prev_regions = regions;    
    
    if isempty(find(done_mask == 0))
        break;
    end
    
    generation = generation + 1;
end

[y_peaks, y_baseline] = regions_to_global(regions,x,y);
r2 = 1 - sum((y_peaks+y_baseline - y).^2)/sum((mean(y) - y).^2);
fprintf('r2: %f\n',r2);

results = {};
% results.BETA = BETA;
% results.baseline_BETA = NaN;%baseline_BETA;
% results.x_baseline_BETA = NaN;%x_baseline_BETA;
results.regions = regions;
results.y_baseline = y_baseline;
results.y_fit = y_peaks + y_baseline;
results.y_peaks = y_peaks;
results.r2 = r2;
fprintf('Finished deconvolution\n');

function regions = determine_initial_baseline(regions)
for r = 1:length(regions)
    regions{r}.baseline_lb = [min(regions{r}.y);min(regions{r}.y)];
    regions{r}.baseline_ub = [max(regions{r}.y);max(regions{r}.y)];
    if r == 1
        x_baseline_BETA = [regions{r}.x(1);regions{r}.x(end)];
    else
        x_baseline_BETA = [regions{r-1}.x(1);regions{r}.x(end)];
    end
    regions{r}.baseline_BETA = [regions{r}.y(1);regions{r}.y(end)];
    regions{r}.baseline_options = {};
    regions{r}.baseline_options.x_baseline_BETA = x_baseline_BETA;
    regions{r}.baseline_options.x_all = regions{r}.x;
end

function regions = determine_regions(x,y,maxs,all_mins,bins,regions)
% Divide the problem up into regions
[num_bins,junk] = size(bins);
for b = 1:num_bins
    xwidth = x(1) - x(2);
    i = round((x(1)-bins(b,1))/xwidth) + 1;
    last = round((x(1)-bins(b,2))/xwidth) + 1;
    ixs = find(i <= maxs & maxs < last);
    sub_mins = all_mins(ixs,:);
    i = min([i,min(sub_mins)]); % Adjust the start to make sure we include the max
    last = max([last,max(sub_mins)]);
    sub_inxs = i:(last-1);
    xsub = x(i:last-1);
    ysub = y(i:last-1);
    % Now adjust sub_mins
    sub_maxs = maxs(ixs) - i  + 1;
    sub_mins = all_mins(ixs,:) - i  + 1;            
    if ~isempty(sub_maxs)
        [BETA0,lb,ub] = compute_initial_inputs(xsub,ysub,sub_maxs,sub_mins,1:length(xsub));
    else
        BETA0 = [];
        lb = [];
        ub = [];
    end
    regions{b}.x = xsub;
    regions{b}.y = ysub;
    regions{b}.BETA0 = BETA0;
    regions{b}.lb = lb;
    regions{b}.ub = ub;
    regions{b}.inxs = sub_inxs;
    regions{b}.maxs = maxs(ixs);
    regions{b}.sub_maxs = sub_maxs;
    regions{b}.num_maxima = length(BETA0)/4;
end