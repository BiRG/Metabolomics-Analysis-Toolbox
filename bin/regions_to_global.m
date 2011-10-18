function [y_peaks, y_baseline, BETA, baseline_BETA, baseline_options] = regions_to_global(regions,x,y)
BETA = [];
baseline_BETA = y(1);
baseline_options = {};
baseline_options.x_all = x;
baseline_options.x_baseline_BETA = x(1);
y_peaks = 0*y;
y_baseline = 0*y;
for r = 1:length(regions)
    inxs = regions{r}.inxs;
    y_baseline(inxs) = global_model(regions{r}.baseline_BETA,x(inxs),0,regions{r}.baseline_options);
    if r == 1
        baseline_options.x_baseline_BETA(end+1) = regions{r}.baseline_options.x_baseline_BETA(1);
        baseline_BETA(end+1) = regions{r}.baseline_BETA(1);
    elseif r < length(regions)
        baseline_options.x_baseline_BETA(end+1) = (regions{r}.baseline_options.x_baseline_BETA(end) + regions{r+1}.baseline_options.x_baseline_BETA(1))/2;
        baseline_BETA(end+1) = (regions{r}.baseline_BETA(end) + regions{r+1}.baseline_BETA(1))/2;
    else
        baseline_options.x_baseline_BETA(end+1) = regions{r}.baseline_options.x_baseline_BETA(end);
        baseline_BETA(end+1) = regions{r}.baseline_BETA(end);
    end
    if regions{r}.num_maxima > 0
        BETA = [BETA;regions{r}.BETA0];
        y_peaks(inxs) = global_model(regions{r}.BETA0,x(inxs),regions{r}.num_maxima,{});
    end
end
baseline_options.x_baseline_BETA = x(end);
baseline_BETA = y(end);

