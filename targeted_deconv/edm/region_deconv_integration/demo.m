addpath('lib');

% It's a large collection, so I've saved a collection with the peaks
% identified
%
% collection = load_collection('collection_Pre-binned.txt','./');
%  
% collection = find_peaks(collection);
% 
% save('collection');

load('collection');

% Pick the first spectrum to demo
s = 1;

% Pick the region for deconvolution
region_left = 8.6;
region_right = 8.41;

% Options
x_baseline_width = 0.6;

x = collection.x;
y = interpolate_zeros(x,collection.Y(:,s));

[BETA0,lb,ub] = compute_initial_inputs(x,y,x(collection.maxs{s}),1:length(x),x(collection.maxs{s}));

[BETA,baseline_BETA,fit_inxs,y_fit,y_baseline,R2,peak_inxs,peak_BETA] = region_deconvolution(x,y,BETA0,lb,ub,x_baseline_width,[region_left;region_right]);

plot(x(fit_inxs),y(fit_inxs),x(fit_inxs),y_fit,x(fit_inxs),y_baseline);

