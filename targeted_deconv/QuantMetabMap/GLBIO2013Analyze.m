% Prints a summary of the analysis of the results from the GLBIO2013 experiments

% Number of monitors being used for output. If more than 1, tries to
% maximize the figures to fit on only one monitor under Linux - I have no
% idea what happens under Windows or iOS.
num_monitors = 2; 

%% Draw starting point figures
% These figures give two different simple spectra and show the different
% starting points arrived at by Anderson's algorithm and the summit
% algorithm.
simple_peaks1 = GaussLorentzPeak([0.003,0.002,0,0.002,   0.004,0.002,0,0.006]);
simple_peaks2 = GaussLorentzPeak([0.003,0.003,0,0.001,   0.004,0.003,0,0.004,  0.005,0.003,0,0.007]);

clf;
x = 0:0.00015:.008;
extended_x = -0.014:0.00015:0.02; % Needed to make the plots look right because of the wide widths given by Anderson

model = RegionalSpectrumModel; % Use default model
samples_per_ppm = length(x)/(max(x)-min(x));
window_samples = ceil(model.rough_peak_window_width * samples_per_ppm);
assert(window_samples >= 4);


subplot(2,2,1);
[starting_params, lb, ub] = compute_initial_inputs(x, ...
    sum(simple_peaks1.at(x),1), [simple_peaks1.location], ...
    1:length(x), [simple_peaks1.location]);
GLBIO2013_plot_peaks_and_starting_point('Anderson On Separated Peaks', ...
    extended_x, simple_peaks1, 1, starting_params, lb, ub);

subplot(2,2,2);
[starting_params, lb, ub] = compute_initial_inputs(x, ...
    sum(simple_peaks2.at(x),1), [simple_peaks2.location], ...
    1:length(x), [simple_peaks2.location]);
GLBIO2013_plot_peaks_and_starting_point('Anderson On Congested Peaks', ...
    extended_x, simple_peaks2, 2, starting_params, lb, ub);

subplot(2,2,3);
[starting_params, lb, ub] = deconv_initial_vals_dirty ...
    (x, sum(simple_peaks1.at(x),1), min(x), max(x), [simple_peaks1.location], ...
    model.max_rough_peak_width, window_samples, 100, @do_nothing);
GLBIO2013_plot_peaks_and_starting_point('Summit On Separated Peaks', ...
    extended_x, simple_peaks1, 1, starting_params, lb, ub);

subplot(2,2,4);
[starting_params, lb, ub] = deconv_initial_vals_dirty ...
    (x, sum(simple_peaks2.at(x),1), min(x), max(x), [simple_peaks2.location], ...
    model.max_rough_peak_width, window_samples, 100, @do_nothing);
[handles,element_names] = ...
    GLBIO2013_plot_peaks_and_starting_point('Summit On Separated Peaks', ...
    extended_x, simple_peaks2, 2, starting_params, lb, ub);
legend(handles, element_names, 'Location', 'NorthEast');

maximize_figure(gcf, num_monitors);

%% Calculate HistogramDistribution objects for the original parameter distributions
%% Calculate simplified versions of the original parameter distributions with 7 bins
% We don't have enough data to calculate a more detailed observed
% distribution with good accuracy (though, if the variance on the 7 bins is
% too large, I might see if increasing the number of bins will decrease the
% variance on the K-L error distribution.)
dist_cache_filename = 'GLBIO2013Analyze_cached_distributions.mat';
if exist(dist_cache_filename,'file')
    load(dist_cache_filename,'-mat');
else
    tic;
    raw_orig_width = nssd_data_dist('width');
    raw_orig_height = nssd_data_dist('height');
    raw_orig_lorentzianness = nssd_data_dist('lorentzianness');
    orig_width_dist = HistogramDistribution.fromEqualProbBins(...
        [raw_orig_width.min],[raw_orig_width.max]);
    orig_height_dist = HistogramDistribution.fromEqualProbBins(...
        [raw_orig_height.min],[raw_orig_height.max]);
    orig_lorentzianness_dist = HistogramDistribution.fromEqualProbBins(...
        [raw_orig_lorentzianness.min],[raw_orig_lorentzianness.max]);
    orig_width_7bin = orig_width_dist.rebinApproxEqualProb(7);
    orig_height_7bin = orig_height_dist.rebinApproxEqualProb(7);
    orig_lorentzianness_7bin = orig_lorentzianness_dist.rebinApproxEqualProb(7);
    toc
    save(dist_cache_filename, 'orig_width_7bin', 'orig_height_7bin', ...
        'orig_lorentzianness_7bin','orig_width_dist', ...
        'orig_height_dist','orig_lorentzianness_dist')
    clear('raw_orig_width','raw_orig_height','raw_orig_lorentzianness');
end
clear('dist_cache_filename');

%% Calculate equal width versions of the original parameter distributions with 7 bins
% The equal probability bins consider the two distributions to be equal if
% the equivalent quantiles map to one another - if the largest 10% of the
% widths map to the largest 10%. Thus, it bounds an error related to the
% quantile-quantile mapping. Equal width binning is more related to the
% absolute error. The smallest smallest 10% of widths must map to one
% another - no matter how infrequent they are
orig_width_7_hist_bin = orig_width_dist.rebinEqualWidth(7);
orig_height_7_hist_bin = orig_height_dist.rebinEqualWidth(7);
orig_lorentzianness_7_hist_bin = orig_lorentzianness_dist.rebinEqualWidth(7);


%% Plot simplified versus original parameter distributions
clf;
subplot(2,2,1);
hold off;
raw_handle = orig_height_dist.plot('b');
hold on;
simp_handle = orig_height_7bin.plot('r--');
legend([raw_handle,simp_handle],'Raw original','Simplified');
ylim([0,100]);
subplot(2,2,2);
hold off;
orig_width_dist.plot('b');
hold on;
orig_width_7bin.plot('r--');
ylim([0,100]);
subplot(2,2,3);
hold off;
orig_lorentzianness_dist.plot('b');
hold on;
orig_lorentzianness_7bin.plot('r--');
ylim([0,100]);
hold off;

%% Plot equal width versus original parameter distributions
clf;
subplot(2,2,1);
hold off;
raw_handle = orig_height_dist.plot('b');
hold on;
simp_handle = orig_height_7_hist_bin.plot('r--');
legend([raw_handle,simp_handle],'Raw original','Simplified');
ylim([0,100]);
subplot(2,2,2);
hold off;
orig_width_dist.plot('b');
hold on;
orig_width_7_hist_bin.plot('r--');
ylim([0,100]);
subplot(2,2,3);
hold off;
orig_lorentzianness_dist.plot('b');
hold on;
orig_lorentzianness_7_hist_bin.plot('r--');
ylim([0,100]);
hold off;

%% Load the combined results
load('Mar_07_2013_experiment_for_GLBIO2013Analyze');

%% Calc distribution for scaled maximum height
% If we were not sampling the spectrum, dividing all the heights by the
% maximum spectrum intenstity would produce a number at most 1. However,
% because we are sampling, the maximum sample can be substantially less
% than the actual maximum of the spectrum.
%
% Here I plot the distributions of the maximum height parameter after
% scaling.
%
% Each time this cell is run, it adds 1000 samples onto the cached set of
% heights, so the histogram will continue to improve.
max_scaled_heights_file = 'GLBIO2013Analyze_cached_max_scaled_heights.mat';
if exist(max_scaled_heights_file ,'file')
    load(max_scaled_heights_file ,'-mat');
else
    sampled_max_scaled_heights = [];
end
tic; 
numsamp=1000; 
maxh=nan(1,numsamp); 
waith=waitbar(0,'sampling'); 
for i=1:numsamp; 
    waitbar((i-1)/numsamp,waith); 
    [s,p]=random_spec_from_nssd_data(7,1, ...
        1+GLBIO2013_width_for_collision_prob(0.1), ...
        GLBIO2013_width_for_collision_prob(0.1)*...
        25/0.00453630122481774988,0); 
    pp=p.property_array; 
    h=pp(1:4:end); 
    maxh(i) = max(h); 
end; 
delete(waith); 
fprintf('Added %d samples to max height distribution. ',numsamp);
toc; 
sampled_max_scaled_heights = [sampled_max_scaled_heights, maxh];
save('GLBIO2013Analyze_cached_max_scaled_heights.mat','-mat','sampled_max_scaled_heights');

clear('h','p','i','pp','s','waith','numsamp','maxh', ...
    'max_scaled_heights_file');

%% Show distribution for scaled maximum height
hist(sampled_max_scaled_heights,200);
title(sprintf(['Distribution of maximum height after scaling\n'...
    'Max max height: %g in %d samples'],max(sampled_max_scaled_heights),...
    length(sampled_max_scaled_heights)));
xlabel('Maximum height in interval after scaling');
ylabel('Count');


%% Calculate bins for area, width, and height
%
% The height distribution is not independently sampled from the raw heights
% because the peaks are scaled within each spectrum so that the highest
% point has height 1. The area distribution depends on the height
% distribution (and is also a complicated function of the known
% distributions). Both of these could, in principle be calculated exactly.
% However, that would be a dissertation in itself. 
%
% To save time, I will sample: 
% First, I will generate lots of spectra and record the values of width,
% height, etc for the peaks in those spectra. From these, I will make
% categorical bins. Then, I will again generate lots of spectra. These will
% be the counts that go into the bins for a Dirichlet distribution giving 
% my beliefs about the possible categorical distributions.
%
% I am including a width distribution so I can see how far things get from
% the real distribution. I will use the second set of values to also create
% a set of bins to see how much of the original data ends up in a different
% bin with two different runs.
%
% On the machine at work, 10 congestions and 1000 spectra requires 400
% seconds (that is, a bit under 7 minutes).
%
% The sampled distributions only estimate the maximum and minimum using the
% maximum and minimum of the sample - not the best estimator. Since I know
% the original distributions and the method for calculating the height and
% area, I can calculate the actual maximum and minimum for the
% distributions. Here I replace the distributions with ones having the
% correct maximum and minimum. This will keep peak parameters from falling
% outside the range.
%
% The correct height range is: [ 0.00001604482555427710777509984241, 1.0445079319188184286 ]
% The correct area range is:  
% [2.93792276627387990798835084182e-8, 0.073758168890726301241]
% The correct width range is just the original range of the known width
% distribution.
%
% These come from the maximizing_peak_area.nb Mathematica notebook, where
% there are many more details as to how they were derived.
num_congestions = 10;
num_spectra_for_bins = 5000;
num_sampd_params = 3;
sampled_param_names = {'area','height','width'};
sampd_area_idx = find(strcmp('area',sampled_param_names));
sampd_height_idx = find(strcmp('height',sampled_param_names));
sampd_width_idx = find(strcmp('width',sampled_param_names));

samp_dist_cache_filename = 'GLBIO2013Analyze_cached_sampled_distributions.mat';
if exist(samp_dist_cache_filename,'file')
    load(samp_dist_cache_filename,'-mat');
    assert(exist('orig_sampd_counts_7bin_pass_2','var'),'Delete %s, it is an old version',samp_dist_cache_filename);
else
    tic;
    wait_h = waitbar(0,'Calculating bins');
    orig_sampd_dist = cell(num_sampd_params,num_congestions);
    orig_sampd_7bin = cell(num_sampd_params,num_congestions);
    orig_sampd_7bin_pass_2 = cell(num_sampd_params,num_congestions);
    orig_sampd_counts_7bin = cell(num_sampd_params,num_congestions);
    orig_sampd_counts_7bin_pass_2 = cell(num_sampd_params,num_congestions);
    orig_sampd_7_hist_bin = cell(num_sampd_params,num_congestions);
    orig_sampd_7_hist_bin_pass_2 = cell(num_sampd_params,num_congestions);

    % Put the correct bounds in an array to make it easy to access in a loop.
    correct_bounds=nan(num_sampd_params,2); % correct_bounds(param_idx, :} is [minimum, maximum]
    correct_bounds(sampd_area_idx,:)=[ 2.93792276627387990798835084182e-8, 0.073758168890726301241 ];
    correct_bounds(sampd_height_idx,:)=[ 0.00001604482555427710777509984241, 1.0445079319188184286 ];
    correct_bounds(sampd_width_idx,:)=[min(orig_width_dist.bounds),max(orig_width_dist.bounds)];
    
    % Define shortcut functions to use in replacing bounds and replacing
    % probabilities from counts
    newBnds=@(orig,bnd) HistogramDistribution(...
        [bnd(1),orig.bounds(2:end-1),bnd(2)],...
        orig.probs, orig.border_is_in_upper_bin);
    newProbs=@(orig,cnts) HistogramDistribution(...
        orig.bounds, cnts./sum(cnts), orig.border_is_in_upper_bin);
    
    stps = 11; % Number of steps to be done per congestion
    for congestion = 1:num_congestions
        waitbar((0+stps*(congestion-1))/(stps*num_congestions), wait_h, sprintf('Generating spectra for congestion %d',congestion));
        param=cell(3); % area, height, width
        [param{1},param{2},param{3}]=GLBIO2013_sample_peak_params(congestion/10, num_spectra_for_bins);

        for param_idx = 1:num_sampd_params
            waitbar((param_idx+stps*(congestion-1))/(stps*num_congestions), wait_h, sprintf('Binning params for congestion %d',congestion));
            orig_sampd_dist{param_idx, congestion} = HistogramDistribution.fromPoints(param{param_idx});
            orig_sampd_dist{param_idx, congestion} = newBnds( ...
                orig_sampd_dist{param_idx, congestion}, ...
                correct_bounds(param_idx,:));
            orig_sampd_7bin{param_idx, congestion} = orig_sampd_dist{param_idx, congestion}.rebinEqualProb(7);
            orig_sampd_7_hist_bin{param_idx, congestion} = orig_sampd_dist{param_idx, congestion}.rebinEqualWidth(7);
        end

        waitbar((4+stps*(congestion-1))/(stps*num_congestions), wait_h, sprintf('Generating count spectra for congestion %d',congestion));
        [param{1},param{2},param{3}]=GLBIO2013_sample_peak_params(congestion/10, num_spectra_for_bins);

        for param_idx = 1:num_sampd_params
            waitbar((4+param_idx+stps*(congestion-1))/(stps*num_congestions), wait_h, sprintf('Binning pass 2 params for congestion %d',congestion));
            temp_dist = HistogramDistribution.fromPoints(param{param_idx});
            temp_dist = newBnds( temp_dist, correct_bounds(param_idx,:) );
            orig_sampd_7bin_pass_2{param_idx, congestion} = temp_dist.rebinEqualProb(7);
            orig_sampd_7_hist_bin_pass_2{param_idx, congestion} = temp_dist.rebinEqualWidth(7);            
        end

        waitbar((8+stps*(congestion-1))/(stps*num_congestions), wait_h, sprintf('Generating pass 2 count spectra for congestion %d',congestion));
        [param{1},param{2},param{3}]=GLBIO2013_sample_peak_params(congestion/10, num_spectra_for_bins);
        
        for param_idx = 1:num_sampd_params
            waitbar((8+param_idx+stps*(congestion-1))/(stps*num_congestions), wait_h, sprintf('Counting pass 2 params for congestion %d',congestion));
            orig_sampd_counts_7bin{param_idx, congestion} = orig_sampd_7bin{param_idx, congestion}.binCounts(param{param_idx});
            assert(length(param{param_idx}) == sum(orig_sampd_counts_7bin{param_idx, congestion})); % No out-of-range parameters
            orig_sampd_7bin{param_idx, congestion} = newProbs(...
                orig_sampd_7bin{param_idx, congestion}, ...
                orig_sampd_counts_7bin{param_idx, congestion});

            orig_sampd_counts_7bin_pass_2{param_idx, congestion} = orig_sampd_7bin_pass_2{param_idx, congestion}.binCounts(param{param_idx});
            assert(length(param{param_idx}) == sum(orig_sampd_counts_7bin_pass_2{param_idx, congestion})); % No out-of-range parameters
            orig_sampd_7bin_pass_2{param_idx, congestion} = newProbs(...
                orig_sampd_7bin_pass_2{param_idx, congestion}, ...
                orig_sampd_counts_7bin_pass_2{param_idx, congestion});
        end
    end
    fprintf('Done generating bins for area,height, and width. '); toc

    delete(wait_h);

    save(samp_dist_cache_filename, 'orig_sampd_dist', 'orig_sampd_7bin', 'orig_sampd_7bin_pass_2', 'orig_sampd_counts_7bin', 'orig_sampd_counts_7bin_pass_2', 'orig_sampd_7_hist_bin', 'orig_sampd_7_hist_bin_pass_2');
    clear('wait_h','congestion','param','param_idx','temp_dist','correct_bounds','newBnds','newProbs');
end
clear('samp_dist_cache_filename');

%% How many bins differ significantly between pass 1 and pass 2
% I tried 100, 1000, and 5000 spectra for setting the bins of the sampled
% distribution. As validation for whether that number of samples produced
% good bins, I generated three sets of spectra. I used each of the first
% two sets of spectra to generate parameter bins. Then I used the third set
% of spectra to generate the probabilities of each bin.
%
% I considered a sample size unacceptable if it had more than three bins
% (out of 210) where the % of elements in that bin differed by at least 1%
% of the total from the number of elements from the corresponding bin
% generated by the other pass.
%
% I stopped trying at new sample sizes at 5000 samples because it gave me 0
% bins that differed by 1% or more.
%
% Below is the code I used for displaying the bins that differed by 1% or
% more.
diffs = cell(num_sampd_params, num_congestions);
for param_idx=1:num_sampd_params 
    for congestion=1:num_congestions
        diffs{param_idx,congestion}=orig_sampd_counts_7bin{param_idx,congestion}-orig_sampd_counts_7bin_pass_2{param_idx,congestion}; 
        diffs{param_idx,congestion}=diffs{param_idx,congestion}./sum(orig_sampd_counts_7bin{param_idx,congestion}); 
    end; 
end;
fprintf('Parameter, congestion, and whether a given bin differed by 1%% or more\n');
for param_idx=1:num_sampd_params
    for congestion=1:num_congestions
        fprintf('%d %d %s\n',param_idx, congestion, to_str(diffs{param_idx,congestion}>=0.01)); 
    end; 
end;
fprintf('\n');
clear('diffs','congestion','param_idx');


%% Defend spectrum width choices
% The spectral widths chosen give better than 99% probabilities that the
% probabilities of being free of peak merging are within 0.4% of the target
% probability.
GLBIO2013_print_prob_counts_in_range_table(0.004);

%% Calculate counts of different parameters in simplified distribution
% Summarize the distribution of the peak parameters by counting how many
% peaks fall in each bin in the simplified original distribution. I do this
% for the equal width and equal probability bins.
%
% I also set up the location distributions since they are different for
% each congestion due to the congestion being controled by the interval.
%
% Originally, I did this for the basic parameters taking their original
% independently sampled distributions. Now, I've added categories for the
% bins generated from the first and second sample in the sampled
% distribution.
%
% 
pp_names = GLBIO2013Deconv.peak_picking_method_names();
dsp_names = GLBIO2013Deconv.deconvolution_starting_point_method_names();
%                        1       2                    3                4         5           6           7             8              9            10 
param_names =          {'width','height-independent','lorentzianness','location','area-bin1','area-bin2','height-bin1','height-bin2','width-bin1','width-bin2'};
param_has_known_orig = [   true,                true,            true,      true,      false,      false,        false,        false,       false,      false];
num_congestions = 10;
orig_location_dist(num_congestions) = HistogramDistribution; % preallocate array
param_vals = cell(length(pp_names),length(dsp_names),num_congestions, length(param_names));
for result = glbio_combined_results
    cong_idx = round(10*GLBIO2013_collision_prob_for_width(result.spectrum_width));
    orig_location_dist(cong_idx) = HistogramDistribution(...
        [result.spectrum_interval.min,result.spectrum_interval.max],1);
    for deconv = result.deconvolutions
        pp_idx = find(strcmp(deconv.peak_picker_name, pp_names));
        dsp_idx = find(strcmp(deconv.starting_point_name, dsp_names));
        peaks = deconv.peaks;
        v = param_vals(pp_idx, dsp_idx, cong_idx,:);
        v{1} = [v{1} [peaks.half_height_width]];
        v{2} = [v{2} [peaks.height]];
        v{3} = [v{3} [peaks.lorentzianness]];
        v{4} = [v{4} [peaks.location]];
        v{5} = [v{5} [peaks.area]];
        v{6} = v{5};
        v{7} = v{2};
        v{8} = v{2};
        v{9} = v{1};
        v{10}= v{1};
        param_vals(pp_idx, dsp_idx, cong_idx,:) = v;
    end
end

orig_location_7bin = orig_location_dist;
orig_location_7_hist_bin = orig_location_dist;
for cong_idx = 1:num_congestions
    orig_location_7bin(cong_idx) = ...
        orig_location_dist(cong_idx).rebinApproxEqualProb(7);
    orig_location_7_hist_bin(cong_idx) = ...
        orig_location_dist(cong_idx).rebinEqualWidth(7);
end

param_counts_7bin = param_vals;
param_counts_7_hist_bin = param_vals;
param_counts_orig_7bin = cell(num_congestions, length(param_names));
param_counts_orig_7_hist_bin = cell(num_congestions, length(param_names));
for cong_idx = 1:num_congestions
    for pp_idx = 1:length(pp_names)
        for dsp_idx = 1:length(dsp_names)
            v = param_vals(pp_idx, dsp_idx, cong_idx,:);
            v{1} = orig_width_7bin.binCounts(v{1});
            v{2} = orig_height_7bin.binCounts(v{2});
            v{3} = orig_lorentzianness_7bin.binCounts(v{3});
            v{4} = orig_location_7bin(cong_idx).binCounts(v{4});
            
            v{5} = orig_sampd_7bin{sampd_area_idx, cong_idx}.binCounts(v{5});
            v{6} = orig_sampd_7bin_pass_2{sampd_area_idx, cong_idx}.binCounts(v{6});
            v{7} = orig_sampd_7bin{sampd_height_idx, cong_idx}.binCounts(v{7});
            v{8} = orig_sampd_7bin_pass_2{sampd_height_idx, cong_idx}.binCounts(v{8});
            v{9} = orig_sampd_7bin{sampd_width_idx, cong_idx}.binCounts(v{9});
            v{10}= orig_sampd_7bin_pass_2{sampd_width_idx, cong_idx}.binCounts(v{10});
            param_counts_7bin(pp_idx, dsp_idx, cong_idx,:) = v;
            
            v = param_vals(pp_idx, dsp_idx, cong_idx,:);
            v{1} = orig_width_7_hist_bin.binCounts(v{1});
            v{2} = orig_height_7_hist_bin.binCounts(v{2});
            v{3} = orig_lorentzianness_7_hist_bin.binCounts(v{3});
            v{4} = orig_location_7_hist_bin(cong_idx).binCounts(v{4});

            v{5} = orig_sampd_7_hist_bin{sampd_area_idx, cong_idx}.binCounts(v{5});
            v{6} = orig_sampd_7_hist_bin_pass_2{sampd_area_idx, cong_idx}.binCounts(v{6});
            v{7} = orig_sampd_7_hist_bin{sampd_height_idx, cong_idx}.binCounts(v{7});
            v{8} = orig_sampd_7_hist_bin_pass_2{sampd_height_idx, cong_idx}.binCounts(v{8});
            v{9} = orig_sampd_7_hist_bin{sampd_width_idx, cong_idx}.binCounts(v{9});
            v{10}= orig_sampd_7_hist_bin_pass_2{sampd_width_idx, cong_idx}.binCounts(v{10});
            param_counts_7_hist_bin(pp_idx, dsp_idx, cong_idx,:) = v;
        end
    end
    v = param_counts_orig_7bin(cong_idx,:);
    % Leave 1-4 unset because there are no counts for the bins - they are
    % not observed but known a-priori
    v{5} = orig_sampd_counts_7bin{sampd_area_idx, cong_idx};
    v{6} = orig_sampd_counts_7bin_pass_2{sampd_area_idx, cong_idx};
    v{7} = orig_sampd_counts_7bin{sampd_height_idx, cong_idx};
    v{8} = orig_sampd_counts_7bin_pass_2{sampd_height_idx, cong_idx};
    v{9} = orig_sampd_counts_7bin{sampd_width_idx, cong_idx};
    v{10}= orig_sampd_counts_7bin_pass_2{sampd_width_idx, cong_idx};
    param_counts_orig_7bin(cong_idx,:) = v;
    
    v = param_counts_orig_7_hist_bin(cong_idx,:);
    % Leave 1-4 unset because there are no counts for the bins - they are
    % not observed but known a-priori
    v{5} = orig_sampd_counts_7bin{sampd_area_idx, cong_idx};
    v{6} = orig_sampd_counts_7bin_pass_2{sampd_area_idx, cong_idx};
    v{7} = orig_sampd_counts_7bin{sampd_height_idx, cong_idx};
    v{8} = orig_sampd_counts_7bin_pass_2{sampd_height_idx, cong_idx};
    v{9} = orig_sampd_counts_7bin{sampd_width_idx, cong_idx};
    v{10}= orig_sampd_counts_7bin_pass_2{sampd_width_idx, cong_idx};
    param_counts_orig_7_hist_bin(cong_idx,:) = v;
end

%% Sample from KL distribution for each set of counts comparing it to the original
% Each set of observed counts creates a posterior dirichlet distribution 
% as to the actual probabilities of a peak parameter falling in a
% particular bin. We sample from that posterior to and calculate the KL
% divergence of each sample from the desired distribution of that
% parameter. These are samples from the posterior distribution of errors
% for a given method and congestion. I use 1,000 samples to give a good
% approximation to the distribution.
%
% I use two different prior distributions. One is just the original
% probabilities and reflects a weak (effective sample size = 1) belief that
% a given method works and produces the same distribution as it was fed.
% The other, more skeptical prior, represents an equally weak belief 
% (effective sample size = 1) that we don't know what parameter values 
% will come out of a particular method until we see it - this one is 
% uniform over interval of possible input parameter values. Given actual 
% sample sizes, both should be completely overwhelmed by the data.
%
% When I am sampling to derive the correct distribution, I use a skeptical
% prior for the original distribution and the MLE from that sample as my
% (non-skeptical) prior for the algorithm's distribution.
%
% It takes 5 minutes: maybe it should be cached?
%
% NOTE: what am I doing about output values that fall outside the range of
% input parameter values? It could happen.
tic

% For the distributions known a-priori param_probs contains the
% probabilities of those parameters. Otherwise, it contains the MLE
% estimate of those probabilities. These are used as non-skeptical priors
% for the distribution of the parameters produced by each algorithm. And
% for the a-priori distributions, these are the distributions against which
% the KL divergence is taken.
%
% NOTE: param_probs is used in other calculation cells in this file.
param_probs = cell(num_congestions, length(param_names));
skeptical_prior = param_probs;
param_probs_7hist = cell(num_congestions, length(param_names));
skeptical_prior_7hist = param_probs;
for cong_idx = 1:num_congestions
    param_probs(cong_idx,:) = {orig_width_7bin.probs, orig_height_7bin.probs, ...
        orig_lorentzianness_7bin.probs, orig_location_7bin(cong_idx).probs, ...
        orig_sampd_7bin{sampd_area_idx,cong_idx}.probs, ...
        orig_sampd_7bin_pass_2{sampd_area_idx, cong_idx}.probs, ...
        orig_sampd_7bin{sampd_height_idx,cong_idx}.probs, ...
        orig_sampd_7bin_pass_2{sampd_height_idx, cong_idx}.probs, ...
        orig_sampd_7bin{sampd_width_idx,cong_idx}.probs, ...
        orig_sampd_7bin_pass_2{sampd_width_idx, cong_idx}.probs ...
        };
    skeptical_prior(cong_idx,:) = {orig_width_7bin.bins, orig_height_7bin.bins, ...
        orig_lorentzianness_7bin.bins, orig_location_7bin(cong_idx).bins, ...
        orig_sampd_7bin{sampd_area_idx,cong_idx}.bins, ...
        orig_sampd_7bin_pass_2{sampd_area_idx, cong_idx}.bins, ...
        orig_sampd_7bin{sampd_height_idx,cong_idx}.bins, ...
        orig_sampd_7bin_pass_2{sampd_height_idx, cong_idx}.bins, ...
        orig_sampd_7bin{sampd_width_idx,cong_idx}.bins, ...
        orig_sampd_7bin_pass_2{sampd_width_idx, cong_idx}.bins ...
        };
    param_probs_7hist(cong_idx,:) = {orig_width_7_hist_bin.probs, orig_height_7_hist_bin.probs, ...
        orig_lorentzianness_7_hist_bin.probs, orig_location_7_hist_bin(cong_idx).probs, ...
        orig_sampd_7_hist_bin{sampd_area_idx,cong_idx}.probs, ...
        orig_sampd_7_hist_bin_pass_2{sampd_area_idx, cong_idx}.probs, ...
        orig_sampd_7_hist_bin{sampd_height_idx,cong_idx}.probs, ...
        orig_sampd_7_hist_bin_pass_2{sampd_height_idx, cong_idx}.probs, ...
        orig_sampd_7_hist_bin{sampd_width_idx,cong_idx}.probs, ...
        orig_sampd_7_hist_bin_pass_2{sampd_width_idx, cong_idx}.probs ...
        };
    skeptical_prior_7hist(cong_idx,:) = {orig_width_7_hist_bin.bins, orig_height_7_hist_bin.bins, ...
        orig_lorentzianness_7_hist_bin.bins, orig_location_7_hist_bin(cong_idx).bins, ...
        orig_sampd_7_hist_bin{sampd_area_idx,cong_idx}.bins, ...
        orig_sampd_7_hist_bin_pass_2{sampd_area_idx, cong_idx}.bins, ...
        orig_sampd_7_hist_bin{sampd_height_idx,cong_idx}.bins, ...
        orig_sampd_7_hist_bin_pass_2{sampd_height_idx, cong_idx}.bins, ...
        orig_sampd_7_hist_bin{sampd_width_idx,cong_idx}.bins, ...
        orig_sampd_7_hist_bin_pass_2{sampd_width_idx, cong_idx}.bins ...
        };
end
method_works_prior = param_probs;
method_works_prior_7hist = param_probs_7hist;

for cong_idx = 1:num_congestions
    for i = 1:size(skeptical_prior,2)
        b=skeptical_prior{cong_idx, i};
        skeptical_prior{cong_idx,i} = [b.length]/(b(end).max - b(1).min);
        b=skeptical_prior_7hist{cong_idx, i};
        skeptical_prior_7hist{cong_idx,i} = [b.length]/(b(end).max - b(1).min);
    end
end

num_samples = 1000;
kl_method_works = param_counts_7bin;
kl_skeptical = param_counts_7bin;
kl_method_works_7hist = param_counts_7_hist_bin;
kl_skeptical_7hist = param_counts_7_hist_bin;
for cong_idx = 1:num_congestions
    for pp_idx = 1:length(pp_names)
        for dsp_idx = 1:length(dsp_names)
            w = param_counts_7bin(pp_idx, dsp_idx, cong_idx,:);
            s = param_counts_7bin(pp_idx, dsp_idx, cong_idx,:);
            for param_idx = 1:length(param_names)
                if param_has_known_orig(param_idx)
                    w{param_idx} = GLBIO2013_sample_from_kl_divergence_of_dirichlet_belief( ...
                        param_probs{cong_idx, param_idx}, ...
                        method_works_prior{cong_idx, param_idx} + w{param_idx}, ...
                        num_samples,'nothing')';
                    s{param_idx} = GLBIO2013_sample_from_kl_divergence_of_dirichlet_belief( ...
                        param_probs{cong_idx, param_idx}, ...
                        skeptical_prior{cong_idx, param_idx} + s{param_idx}, ...
                        num_samples,'zero=epsilon')';
                else
                    w{param_idx} = GLBIO2013_sample_from_kl_divergence_of_2_dirichlet_belief( ...
                        skeptical_prior{cong_idx, param_idx} + param_counts_orig_7bin{cong_idx,param_idx}, ...
                        method_works_prior{cong_idx, param_idx} + w{param_idx}, ...
                        num_samples,'nothing')';
                    s{param_idx} = GLBIO2013_sample_from_kl_divergence_of_2_dirichlet_belief( ...
                        skeptical_prior{cong_idx, param_idx} + param_counts_orig_7bin{cong_idx,param_idx}, ...
                        skeptical_prior{cong_idx, param_idx} + s{param_idx}, ...
                        num_samples,'zero=epsilon')';
                end
                kl_method_works(pp_idx, dsp_idx, cong_idx,:) = w;
                kl_skeptical(pp_idx, dsp_idx, cong_idx,:) = s;
            end
            
            w = param_counts_7_hist_bin(pp_idx, dsp_idx, cong_idx,:);
            s = param_counts_7_hist_bin(pp_idx, dsp_idx, cong_idx,:);
            for param_idx = 1:length(param_names)
                if param_has_known_orig(param_idx)
                    w{param_idx} = GLBIO2013_sample_from_kl_divergence_of_dirichlet_belief( ...
                        param_probs_7hist{cong_idx, param_idx}, ...
                        method_works_prior_7hist{cong_idx, param_idx} + w{param_idx}, ...
                        num_samples,'zero=epsilon')'; % Not choosing according to probability can leave very low prob bins. Call that prob epsilon
                    s{param_idx} = GLBIO2013_sample_from_kl_divergence_of_dirichlet_belief( ...
                        param_probs_7hist{cong_idx, param_idx}, ...
                        skeptical_prior_7hist{cong_idx, param_idx} + s{param_idx}, ...
                        num_samples,'zero=epsilon')';
                else
                    w{param_idx} = GLBIO2013_sample_from_kl_divergence_of_2_dirichlet_belief( ...
                        skeptical_prior{cong_idx, param_idx} + param_counts_orig_7_hist_bin{cong_idx,param_idx}, ...
                        method_works_prior{cong_idx, param_idx} + w{param_idx}, ...
                        num_samples,'nothing')';
                    s{param_idx} = GLBIO2013_sample_from_kl_divergence_of_2_dirichlet_belief( ...
                        skeptical_prior{cong_idx, param_idx} + param_counts_orig_7_hist_bin{cong_idx,param_idx}, ...
                        skeptical_prior{cong_idx, param_idx} + s{param_idx}, ...
                        num_samples,'zero=epsilon')';
                end
                kl_method_works_7hist(pp_idx, dsp_idx, cong_idx,:) = w;
                kl_skeptical_7hist(pp_idx, dsp_idx, cong_idx,:) = s;
            end
        end
    end
end
fprintf('In calculating the single-parameter KL samples: ');
toc

%% Plot the KL error distributions for the method works prior
clear('w');
figure_num = 0;
dsp_color = {'b:','g-'};
for param_idx = 1:length(param_names)
	for pp_idx = 1:length(pp_names)
        figure_num = figure_num + 1;
        figure(figure_num);
        clf;
        for cong_idx = 1:num_congestions
            assert(num_congestions == 10);
            subplot(2,5,cong_idx);
            h = zeros(1,2);
            for dsp_idx = 1:length(dsp_names)
                w = kl_method_works{pp_idx, dsp_idx, cong_idx, param_idx};
                hist = HistogramDistribution.fromPoints(w);
                if dsp_idx == 1
                    hold off;
                else
                    hold on;
                end
                h(dsp_idx) = hist.plot(dsp_color{dsp_idx});
            end
            if cong_idx == 1
                dn = dsp_names;
                dn{1}(dn{1} == '_') = ' ';
                dn{2}(dn{2} == '_') = ' ';
                legend(h, dn);
                title([underscore_2_space(param_names{param_idx}) ...
                    ' ' underscore_2_space(pp_names{pp_idx})]);
            else
                title(sprintf('%d',cong_idx));
            end
        end
	end
end

%% Prob that summit focused is has better KL error under method works prior
fprintf('Under Method Works prior');
fprintf('P(summit better) Parameter      Peak picker                        Congestion\n');
for param_idx = 1:length(param_names)
	for pp_idx = 1:length(pp_names)
        for cong_idx = 1:num_congestions
            assert(length(dsp_names) == 2);
            assert(strcmp(dsp_names{1},GLBIO2013Deconv.dsp_anderson));
            w_anderson = kl_method_works{pp_idx, 1, cong_idx, param_idx};
            w_summit = kl_method_works{pp_idx, 2, cong_idx, param_idx};
            num_as_good_or_better = sum(w_summit <= w_anderson);
            num_worse = sum(w_summit > w_anderson);
            b = BinomialExperiment(num_as_good_or_better, num_worse, 0.5, 0.5);
            sci = b.shortestCredibleInterval(0.95);
            fprintf('%3d%% [%3d %3d]   %14s %34s %2d   \n',...
                round(b.prob*100), round(100*sci.min), round(100*sci.max), param_names{param_idx}, ...
                pp_names{pp_idx}, cong_idx);
        end
	end
end

%% Plot the distributions over the 7 bins for the different methods and the original
% I use MLE distributions. Maybe I'll modifiy this in the future to give
% some idea as to the uncertainty.
parameters_to_plot = [1:4,5:2:10];
assert(length(dsp_names) == 2);
assert(strcmp(dsp_names{1},GLBIO2013Deconv.dsp_anderson));
anderson_idx = 1;
summit_idx = 2;
newProbs=@(orig,cnts) HistogramDistribution(...
    orig.bounds, cnts./sum(cnts), orig.border_is_in_upper_bin);
for pp_idx = 1:length(pp_names)
    figure(pp_idx);
    subplot_num = 0;
    for param_idx = parameters_to_plot
        for cong_idx = 1:num_congestions
            subplot_num = subplot_num + 1;
            subplot(length(parameters_to_plot),num_congestions,subplot_num);
            
            % Plot bin probabilities
            po = param_probs{cong_idx, param_idx};
            pa = param_counts_7bin{pp_idx, anderson_idx, cong_idx, param_idx};
            if sum(pa) <= 0; continue; end;
            pa = pa ./ sum(pa);
            ps = param_counts_7bin{pp_idx, summit_idx, cong_idx, param_idx};
            ps = ps ./ sum(ps);
            
            h = [HistogramDistribution((0:7)/1,po), ...
                 HistogramDistribution((0:7)/1,pa), ...
                 HistogramDistribution((0:7)/1,ps)];
            linespecs = {'k','r--','g--'};
            handle = zeros(3,1);
            hold off;
            for i = 1:3
                handle(i) = h(i).plot(linespecs{i});
                hold on;
            end

            % Calculate prob anderson or summit is better
            w_anderson = kl_method_works{pp_idx, 1, cong_idx, param_idx};
            w_summit = kl_method_works{pp_idx, 2, cong_idx, param_idx};
            num_as_good_or_better = sum(w_summit <= w_anderson);
            num_worse = sum(w_summit > w_anderson);
            b = BinomialExperiment(num_as_good_or_better, num_worse, 0.5, 0.5);
            sci = b.shortestCredibleInterval(0.95);
            
            % Compute suffix indicating which is better
            if b.prob > 0.75
                suffix = ' (s)';
            elseif b.prob < 0.25
                suffix = ' (a)';
            else
                suffix = ' (?)';
            end
            title([param_names{param_idx} suffix]);
            
            xlim([0,7]);
            ylim([0,0.45]);
            hold off;
        end
    end
end
clear('parameters_to_plot','anderson_idx','summit_idx', 'subplot_num','newProbs','h','handle');


%% Plot probability that summit is better - method works prior equal prob
% I only plot the first pass sampling results. When I plotted both, they
% looked almost identical.
subplot_num = 0;
parameters_to_plot = [1:4,5:2:10];
for param_idx = parameters_to_plot
	for pp_idx = 1:length(pp_names)
        subplot_num = subplot_num + 1;
        subplot(length(parameters_to_plot),length(pp_names),subplot_num);
        prob = zeros(1,num_congestions);
        low_bar = zeros(1,num_congestions);
        up_bar = zeros(1,num_congestions);
        for cong_idx = 1:num_congestions
            assert(length(dsp_names) == 2);
            assert(strcmp(dsp_names{1},GLBIO2013Deconv.dsp_anderson));
            w_anderson = kl_method_works{pp_idx, 1, cong_idx, param_idx};
            w_summit = kl_method_works{pp_idx, 2, cong_idx, param_idx};
            num_as_good_or_better = sum(w_summit <= w_anderson);
            num_worse = sum(w_summit > w_anderson);
            b = BinomialExperiment(num_as_good_or_better, num_worse, 0.5, 0.5);
            sci = b.shortestCredibleInterval(0.95);
            prob(cong_idx) = b.prob;
            low_bar(cong_idx) = b.prob - sci.min;
            up_bar(cong_idx) = sci.max - b.prob;
        end
        errorbar(1:num_congestions, prob, low_bar, up_bar);
        ylim([0,1]);
        xlim([1,10]);
        xlabel('Congestion');
        ylabel('P(summit is better)');
        title(sprintf('%s\n%s',...
            underscore_2_space(param_names{param_idx}), ...
            underscore_2_space(pp_names{pp_idx})));       
	end
end
clear('parameters_to_plot');

%% Plot probability that summit is better - method works prior equal width
% Surprisingly big difference here from the conclusions of the equal
% probability distribution.
%
% Very strangely, the "sampling from the prior" version puts summit being
% better. I don't know what is going on.
subplot_num = 0;
parameters_to_plot = [1:4,5:2:10];
for param_idx = parameters_to_plot
	for pp_idx = 1:length(pp_names)
        subplot_num = subplot_num + 1;
        subplot(length(parameters_to_plot),length(pp_names),subplot_num);
        prob = zeros(1,num_congestions);
        low_bar = zeros(1,num_congestions);
        up_bar = zeros(1,num_congestions);
        for cong_idx = 1:num_congestions
            assert(length(dsp_names) == 2);
            assert(strcmp(dsp_names{1},GLBIO2013Deconv.dsp_anderson));
            w_anderson = kl_method_works_7hist{pp_idx, 1, cong_idx, param_idx};
            w_summit = kl_method_works_7hist{pp_idx, 2, cong_idx, param_idx};
            num_as_good_or_better = sum(w_summit <= w_anderson);
            num_worse = sum(w_summit > w_anderson);
            b = BinomialExperiment(num_as_good_or_better, num_worse, 0.5, 0.5);
            sci = b.shortestCredibleInterval(0.95);
            prob(cong_idx) = b.prob;
            low_bar(cong_idx) = b.prob - sci.min;
            up_bar(cong_idx) = sci.max - b.prob;
        end
        errorbar(1:num_congestions, prob, low_bar, up_bar);
        ylim([0,1]);
        xlim([1,10]);
        xlabel('Congestion');
        ylabel('P(summit is better)');
        title(sprintf('%s\n%s',...
            underscore_2_space(param_names{param_idx}), ...
            underscore_2_space(pp_names{pp_idx})));       
	end
end
clear('parameters_to_plot');

%% Plot probability that summit is better - skeptical prior
% Almost the same as the method_works prior except in the case where we're
% sampling from the prior in because the max-aligned data has not been
% calculated. In that case (probably because of the zero behavior handling
% and the high probability of getting a zero due to the shape of the lor
% prob curve) they come out equal.
subplot_num = 0;
parameters_to_plot = [1:4,5:2:10];
for param_idx = parameters_to_plot
	for pp_idx = 1:length(pp_names)
        subplot_num = subplot_num + 1;
        subplot(length(parameters_to_plot),length(pp_names),subplot_num);
        prob = zeros(1,num_congestions);
        low_bar = zeros(1,num_congestions);
        up_bar = zeros(1,num_congestions);
        for cong_idx = 1:num_congestions
            assert(length(dsp_names) == 2);
            assert(strcmp(dsp_names{1},GLBIO2013Deconv.dsp_anderson));
            s_anderson = kl_skeptical{pp_idx, 1, cong_idx, param_idx};
            s_summit = kl_skeptical{pp_idx, 2, cong_idx, param_idx};
            num_as_good_or_better = sum(s_summit <= s_anderson);
            num_worse = sum(s_summit > s_anderson);
            b = BinomialExperiment(num_as_good_or_better, num_worse, 0.5, 0.5);
            sci = b.shortestCredibleInterval(0.95);
            prob(cong_idx) = b.prob;
            low_bar(cong_idx) = b.prob - sci.min;
            up_bar(cong_idx) = sci.max - b.prob;
        end
        errorbar(1:num_congestions, prob, low_bar, up_bar);
        ylim([0,1]);
        xlim([1,10]);
        xlabel('Congestion');
        ylabel('P(summit is better)');
        title(sprintf('%s\n%s',...
            underscore_2_space(param_names{param_idx}), ...
            underscore_2_space(pp_names{pp_idx})));       
	end
end
clear('parameters_to_plot');


%% For which values is there a difference? - method works prior
% I do multiple t-tests using a holm-bonferroni correction to see which
% values there is evidence of a significant improvement and a second set 
% of tests to see where there is evidence of a significant detriment. I
% use a 0.05 as a significance threshold.
%
improvement_p_vals = zeros(length(param_names),length(pp_names),num_congestions);
detriment_p_vals = improvement_p_vals;
is_non_normal = improvement_p_vals;
sample_sizes_vary_greatly = improvement_p_vals;
for param_idx = 1:length(param_names)
    for pp_idx = 1:length(pp_names)
        for cong_idx = 1:num_congestions
            assert(length(dsp_names) == 2);
            assert(strcmp(dsp_names{1},GLBIO2013Deconv.dsp_anderson));
            w_anderson = kl_method_works{pp_idx, 1, cong_idx, param_idx};
            w_summit = kl_method_works{pp_idx, 2, cong_idx, param_idx};
            is_non_normal(param_idx, pp_idx, cong_idx) = ...
                lillietest(w_anderson) || lillietest(w_summit);
            sample_sizes_vary_greatly(param_idx, pp_idx, cong_idx) = ...
                exp(abs(log(length(w_anderson)/length(w_summit)))) > 1.5;
            [~, improvement_p_vals(param_idx, pp_idx, cong_idx)] = ttest2(w_summit, w_anderson,0.05,'left');
            [~, detriment_p_vals(param_idx, pp_idx, cong_idx)] = ttest2(w_summit, w_anderson,0.05,'right');
        end
    end
end

% Correct the p-values
improvement_p_vals_corrected = improvement_p_vals;
improvement_p_vals_corrected(:) = bonf_holm(improvement_p_vals(:),0.05);
detriment_p_vals_corrected = detriment_p_vals;
detriment_p_vals_corrected (:) = bonf_holm(detriment_p_vals(:),0.05);

%% Print table of values for which there was a difference
fprintf('Peak Property            |Peak Picking Method   |Congestion     |Sig. Improved?     |Sig. Worsened?     \n');
for param_idx = 1:length(param_names)
    for pp_idx = 1:length(pp_names)
        for cong_idx = 1:num_congestions
            i = improvement_p_vals_corrected(param_idx, pp_idx, cong_idx);
            if i >= 0.05
                istr = '?  ??  ?';
            else
                istr = 'Improved';
            end
            d = detriment_p_vals_corrected(param_idx, pp_idx, cong_idx);
            if d >= 0.05
                dstr = '?  ??  ?';
            else
                dstr = 'Worsened';
            end
            
            short_pp_name = pp_names{pp_idx};
            short_pp_name = short_pp_name(1:min(22,length(short_pp_name)));
            fprintf('%25s %22s %15.1f %8s p=%8.3g %8s p=%8.3g\n', ...
                param_names{param_idx},short_pp_name, ...
                cong_idx, istr, i, dstr, d);
        end
    end
end


%% Clean up temp variables
clear('result','cont_idx','deconv','pp_idx','dsp_idx','cong_idx','param_idx','peaks','v','w','s','figure_num','dsp_color','h');

%% Calculate the parameters
pe_list = GLBIO2013_calc_param_error_list(glbio_combined_results);

%% Does an improvement exist independent of where we look? 
% The histogram suggests yes. And a paired t-test gives an unbelieveably
% low p-value (an actual 0 in double precision).
clf;
hist([pe_list.error_diff],100);
title('Histogram of all parameter improvements for all peak picking methods and all parameters');
xlabel('Improvement in error (error_{anderson} - error_{summit})');
ylabel('Number of (deconvolution,parameter) pairs');
[~,p_value] = ttest([pe_list.mean_error_anderson],[pe_list.mean_error_summit],0.05,'right');
sig_box_handle = annotation('textbox',[0.5,0.5,0.2,0.2],'String', ...
    sprintf('mean difference is greater than 0: p=%.18g',p_value));

%% Precalculate some values needed for plotting by parameter
% On my home computer the large "unique" statements take a lot of time to
% compute, so I've moved them to a separate cell so they only have to be
% calculated once.
param_names = unique({pe_list.parameter_name});
assert(length(param_names) == 5,'Right number of param names');
peak_pickers = unique({pe_list.peak_picking_name});
picker_legend = {'Gold Standard','Noisy Gold Standard', 'Smoothed Local Max'};
picker_formats = {'r+-','bd-','*k-'};
assert(length(picker_legend) == length(peak_pickers),'Right # picker legend entries');
assert(length(picker_formats) == length(peak_pickers),'Right # picker formats');
collision_probs = unique([pe_list.collision_prob]);

%% Plot by parameter
% Now we break up the results into one graph for each parameter. Each
% graph has 3 lines - one per peak-picking method and gives the improvement
% as a function of spectrum crowding.
%
% The graphs show that the improvement decreases as the crowding increases.
% They also show that the smoothed local max peak picking algorithm has
% lower improvement - probably because the algorithms are trying to fit an
% incorrect model with too few peaks and the error due to the incorrect 
% model is greater on average than the error due to the improper starting
% point.
%
% _The code below also calculates an matrix of the improvement values
% ordered by the properties of interest (parameter, picker, and
% crowdedness).
clf;
pe_values_per_triple = length(pe_list)/length(param_names)/length(peak_pickers)/length(collision_probs);
improvements = zeros(length(param_names),length(peak_pickers),length(collision_probs),pe_values_per_triple);
for param_idx = 1:length(param_names)
    subplot(2,3,param_idx);
    title_tmp = param_names{param_idx};
    title([upper(title_tmp(1)),title_tmp(2:end)]);
    xlabel('Probability of peak collision');
    ylabel('Mean improvement');
    hold on;
    pe_has_param = strcmp({pe_list.parameter_name},param_names{param_idx});
    handle_for_picker = zeros(1,length(peak_pickers));
    for picker_idx = 1:length(peak_pickers)
        pe_has_picker = strcmp({pe_list.peak_picking_name},peak_pickers{picker_idx});
        mean_error_for_prob = zeros(1,length(collision_probs));
        std_dev_error_for_prob = mean_error_for_prob;
        ci_half_width_95_pct = std_dev_error_for_prob;
        for prob_idx = 1:length(collision_probs)
            pe_has_prob = [pe_list.collision_prob] == collision_probs(prob_idx);
            selected_pes = pe_list(pe_has_prob & pe_has_picker & pe_has_param);
            selected_diffs = [selected_pes.error_diff];
            improvements(param_idx, picker_idx, prob_idx,:) = selected_diffs;
            mean_error_for_prob(prob_idx) = mean(selected_diffs);
            std_dev_error_for_prob(prob_idx) = std(selected_diffs);
            num_diffs = length(selected_diffs);
            if num_diffs > 1
                t_value = tinv(1-0.025, num_diffs - 1);
            else
                t_value = inf;
            end
            ci_half_width_95_pct(prob_idx) = t_value * std_dev_error_for_prob(prob_idx)/sqrt(num_diffs); % half the width of a 95% confidence interval for the mean
        end
%         handle_for_picker(picker_idx) = plot(collision_probs, ...
%             mean_error_for_prob, picker_formats{picker_idx});
        handle_for_picker(picker_idx) = errorbar(collision_probs, ...
            mean_error_for_prob, ci_half_width_95_pct, ...
            picker_formats{picker_idx});
    end
    if param_idx == 3
        legend(handle_for_picker, picker_legend, 'location','NorthEast');
    end
end

%% For which values is there a difference?
% I do multiple t-tests using a holm-bonferroni correction to see which
% values there is evidence of a significant improvement and a second set 
% of tests to see where there is evidence of a significant detriment. I
% use a 0.05 as a significance threshold.
%
% There was significant improvement in all cases except for some of the 
% smoothed local maximum peak-picking. There was no significant worsening 
% for any combination of parameters.
%
% For the smoothed local maximum peak picking, the test did not detect
% improvement for all but the least crowded bin of the lorentzianness,
% for all but the second most crowded of the location parameter, and for
% 0.6,0.7, and 1.0 collision probabilities of the height parameter.

improvement_p_vals = zeros(length(param_names),length(peak_pickers),length(collision_probs));
detriment_p_vals = improvement_p_vals;
for param_idx = 1:length(param_names)
    for picker_idx = 1:length(peak_pickers)
        for prob_idx = 1:length(collision_probs)
            diffs = improvements(param_idx, picker_idx, prob_idx,:);
            [~, improvement_p_vals(param_idx, picker_idx, prob_idx)] = ttest(diffs,0,0.05,'right');
            [~, detriment_p_vals(param_idx, picker_idx, prob_idx)] = ttest(diffs,0,0.05,'left');
        end
    end
end

% Correct the p-values
improvement_p_vals_corrected = improvement_p_vals;
improvement_p_vals_corrected(:) = bonf_holm(improvement_p_vals(:),0.05);
detriment_p_vals_corrected = detriment_p_vals;
detriment_p_vals_corrected (:) = bonf_holm(detriment_p_vals(:),0.05);

fprintf('Peak Property            |Peak Picking Method   |Prob. Collision|Sig. Improved?     |Sig. Worsened?     \n');
for param_idx = 1:length(param_names)
    for picker_idx = 1:length(peak_pickers)
        for prob_idx = 1:length(collision_probs)
            i = improvement_p_vals_corrected(param_idx, picker_idx, prob_idx);
            if i >= 0.05
                istr = '?  ??  ?';
            else
                istr = 'Improved';
            end
            d = detriment_p_vals_corrected(param_idx, picker_idx, prob_idx);
            if d >= 0.05
                dstr = '?  ??  ?';
            else
                dstr = 'Worsened';
            end
            
            fprintf('%25s %22s %15.1f %8s p=%8.3g %8s p=%8.3g\n', ...
                param_names{param_idx}, peak_pickers{picker_idx}, ...
                collision_probs(prob_idx), istr, i, dstr, d);
        end
    end
end

%% For what values might there be a difference if we didn't have the multiple test correction?
% Here I plot the same table, but without the multiple values correction.
% The results are similar, but there are several changes for the smoothed
% local maximum peak picking. Now, the lorentzianness parameter worsens 
% in two additional cases (0.5 and 0.7), but improves in one additional 
% case (0.2).  The location parameter improves in three additional cases
% (0.1, 0.3, and 0.5).
%
% To me, this suggests that we might be able to tease significance out of
% these results by doing more trials.
%
% If I do more trials, I'd like to also include a few more
% noisy-gold-standard peaks with larger standard deviations to see how
% robust the algoritms are to that. I think my current noisy gold-standard
% is likely too nice.
fprintf('Peak Property            |Peak Picking Method   |Prob. Collision|Sig. Improved?     |Sig. Worsened?     \n');
for param_idx = 1:length(param_names)
    for picker_idx = 1:length(peak_pickers)
        for prob_idx = 1:length(collision_probs)
            i = improvement_p_vals(param_idx, picker_idx, prob_idx);
            if i >= 0.05
                istr = '?  ??  ?';
            else
                istr = 'Improved';
            end
            d = detriment_p_vals(param_idx, picker_idx, prob_idx);
            if d >= 0.05
                dstr = '?  ??  ?';
            else
                dstr = 'Worsened';
            end
            
            fprintf('%25s %22s %15.1f %8s p=%8.3g %8s p=%8.3g\n', ...
                param_names{param_idx}, peak_pickers{picker_idx}, ...
                collision_probs(prob_idx), istr, i, dstr, d);
        end
    end
end

%% Precalculate loc_param_errors
% This takes a while on my home computer so I put it in a separate cell
loc_param_errs = GLBIO2013_peak_loc_vs_param_errs(glbio_combined_results);
starting_pt_names = {'Anderson','Summit'};
pa_param_names = {'height', 'width','lorentzianness', 'location'}; % Param names for the successive elements returned by the GaussLorentzPeak.property_array function

%% What is the distribution of initial location errors
% The initial location errors are not Gaussian anymore due to alignment
% (and they weren't before I aligned because they are sorted before they
% get out of the peak-picking routine - but I initially thought they were).
% Histogram of initial location errors in all congestions.
%
% Note that I use starting point 1 and parameter 1 because the initial
% error will be the same independent of those factors.
%
% Still looks like half a Gaussian (but with some distortion in the low 
% values).
%
% My note from the commit: Explored distribution of initial location 
% errors. It looks very similar to a reflected Gaussian (reflected at 0 
% since negative values are not allowed) however, there seems to be a bit 
% of a spike in the small peaks. However, I haven't been able to come up 
% with something to show this departure clearly.
clf;
loc_e = [loc_param_errs(:, 1, 1).peak_loc_error];
hist(loc_e, length(loc_e)/40);
title('Initial location errors under noisy-gold-standard peak picker');
xlabel('Error in initial location (in ppm)');
ylabel('Number of peaks with that error');

%% What is the distribution of width-scaled initial location errors
% Histogram of initial location errors in all congestions scaling each 
% error by the width of the peak for which it is a mis-estimate.
%
% Looks even more gaussian, but now definitely too high in the middle. - it
% looks like there is a specific peak there.
clf;
loc_e = [loc_param_errs(:, 1, 1).peak_loc_error];
widths = [loc_param_errs(:, 1, 1).peak_width];
loc_e = loc_e ./ widths;
hist(loc_e, length(loc_e)/40);
title('Width-scaled initial location errors under noisy-gold-standard peak picker');
xlabel('Error in initial location (in peak width)');
ylabel('Number of peaks with that error');

%% What is the distribution of width-scaled initial location errors at different congestions
% Histogram of initial location errors in all congestions scaling each 
% error by the width of the peak for which it is a mis-estimate, separating
% plots by congestion.
%
% There does look to be a difference at each congestion. I've verified that
% the numbers of peaks are the same in each case. So, the graphs become
% much more slanted toward the lower initial errors as congestion
% increases.
%
clf;
for congestion_idx = 1:10
    subplot(2,5,congestion_idx);
    loc_e = [loc_param_errs(congestion_idx, 1, 1).peak_loc_error];
    widths = [loc_param_errs(congestion_idx, 1, 1).peak_width];
    loc_e = loc_e ./ widths;
    hist(loc_e, length(loc_e)/25);
    title(sprintf('Congestion=%3.1f', congestion_idx / 10));
    xlabel('Error in initial location (in peak width)');
    ylabel('Number of peaks with that error');
    ylim([0,150]);
    xlim([0,0.5]);
    fprintf('Congestion %3.1f : %d peaks\n',congestion_idx /10, length(loc_e));
end

%% What is the distribution of ppm initial location errors at different congestions
% Histogram of initial location errors in all congestions, separating
% plots by congestion.
%
%
% Here the distributions look much more similarly shaped, however, there is
% a gradual increase of left-leaning-ness as you go from 0.1 to 0.6, but it
% drops off suddenly at 0.7 and doesn't seem to change thereafter.
clf;
for congestion_idx = 1:10
    subplot(2,5,congestion_idx);
    loc_e = [loc_param_errs(congestion_idx, 1, 1).peak_loc_error];
    hist(loc_e, length(loc_e)/25);
    title(sprintf('Congestion=%3.1f', congestion_idx / 10));
    xlabel('Error in initial location (in peak width)');
    ylabel('Number of peaks with that error');
    ylim([0,90]);
    xlim([0,1.5e-3]);
end

%% What are the mean/median/skewness width-scaled initial location errors at different congestions
% Plot of the mean, median, and skewness of the width-scaled initial 
% location errors as congestion increases. I also print the Spearman 
% correlations between these and error and whether they are significant.
%
% The correlations seem there to the eye, but by a conservative estimate
% (Spearman) they are not significant. (Pearson finds a barely significant
% correlation (p = 0.0487171) for the median)
%
% So, I'd say that there is no certain effect of congestion on the initial
% location errors and that they are very nearly Gaussian
clf;
mean_e = zeros(1,10);
median_e = zeros(1,10);
skewness_e = zeros(1,10);
for congestion_idx = 1:10
    loc_e = [loc_param_errs(congestion_idx, 1, 1).peak_loc_error];
    widths = [loc_param_errs(congestion_idx, 1, 1).peak_width];
    loc_e = loc_e ./ widths;
    mean_e(congestion_idx) = mean(loc_e);
    median_e(congestion_idx) = median(loc_e);
    skewness_e(congestion_idx) = skewness(loc_e);
end

% Main plot
[ax, h1, h2] = plotyy([(1:10)./10;(1:10)./10]', [mean_e; median_e]', (1:10)./10, skewness_e,@plot);
set(get(ax(2), 'YLabel'),'String', 'Skewness');
legend([h1;h2], 'Mean of errors', 'Median of errors', 'Skewness of errors');
title(sprintf('Congestion=%3.1f', congestion_idx / 10));
xlabel('Congestion');
ylabel('Error (in peak widths)');

% Correlations
[cor_mean, cor_mean_p_val] = corr((1:10)'./10, mean_e', 'type','spearman');
if cor_mean_p_val <= 0.05
    cor_mean_sig = sprintf('Signficant (p = %g) ', cor_mean_p_val);
else
    cor_mean_sig = sprintf('Not signficant (p = %g) ', cor_mean_p_val);
end
fprintf('%s Spearman correlation (%g) between width-scaled mean and congestion\n', cor_mean_sig, cor_mean);

[cor_median, cor_median_p_val] = corr((1:10)'./10, median_e', 'type','spearman');
if cor_median_p_val <= 0.05
    cor_median_sig = sprintf('Signficant (p = %g) ', cor_median_p_val);
else
    cor_median_sig = sprintf('Not signficant (p = %g) ', cor_median_p_val);
end
fprintf('%s Spearman correlation (%g) between width-scaled median and congestion\n', cor_median_sig, cor_median);

[cor_skewness, cor_skewness_p_val] = corr((1:10)'./10, skewness_e', 'type','spearman');
if cor_skewness_p_val <= 0.05
    cor_skewness_sig = sprintf('Signficant (p = %g) ', cor_skewness_p_val);
else
    cor_skewness_sig = sprintf('Not signficant (p = %g) ', cor_skewness_p_val);
end
fprintf('%s Spearman correlation (%g) between width-scaled skewness and congestion\n', cor_skewness_sig, cor_skewness);

%% What are the mean/median initial location errors at different congestions
% Plot of the mean and median of the initial location errors
% as congestion increases. I also print the Spearman correlations between 
% these and error and whether they are significant.
%
% No correlation visible to the eye, but I repeated correlation 
% calculations just because it was a mere copy-and-paste
clf;
mean_e = zeros(1,10);
median_e = zeros(1,10);
for congestion_idx = 1:10
    loc_e = [loc_param_errs(congestion_idx, 1, 1).peak_loc_error];
    mean_e(congestion_idx) = mean(loc_e);
    median_e(congestion_idx) = median(loc_e);
end

% Main plot
legend(plot((1:10)./10, mean_e, (1:10)./10, median_e), 'Mean error', 'Median error');
title(sprintf('Congestion=%3.1f', congestion_idx / 10));
xlabel('Congestion');
ylabel('Error (in ppm)');

% Correlations
[cor_mean, cor_mean_p_val] = corr((1:10)'./10, mean_e', 'type','spearman');
if cor_mean_p_val <= 0.05
    cor_mean_sig = sprintf('Signficant (p = %g) ', cor_mean_p_val);
else
    cor_mean_sig = sprintf('Not signficant (p = %g) ', cor_mean_p_val);
end
fprintf('%s Spearman correlation (%g) between ppm mean and congestion\n', cor_mean_sig, cor_mean);

[cor_median, cor_median_p_val] = corr((1:10)'./10, median_e', 'type','spearman');
if cor_median_p_val <= 0.05
    cor_median_sig = sprintf('Signficant (p = %g) ', cor_median_p_val);
else
    cor_median_sig = sprintf('Not signficant (p = %g) ', cor_median_p_val);
end
fprintf('%s Spearman correlation (%g) between ppm median and congestion\n', cor_median_sig, cor_median);



%% How robust is each starting point to location errors?
% Here, I look at each peak in the noisy gold standard data, the
% distance of that peak from its corresponding initial peak, and the
% distance of the corresponding deconvolved peak parameters from the true
% values.
%
% I then plot for each peak parameter, a scatter plot of initial location
% error versus final difference for that peak parameter (ignoring the
% crowdedness of the bin)
%
% The initial location errors are all quite small. By eye it is hard to
% tell if there is a relationship between the initial location and the
% final peak parameter errors. There may be a slight negative correlation,
% but probably there is no relation. The differing density as you go from 
% left to right comes from the initial location distribution explored 
% above.
%
% I initially did this plot without aligning the initial errors. The result
% was much wider and had a definite downward slope. Here is what I wrote
% then:
%
% These graphs seem to show that there is more error when the initial
% location is lower. However, I suspect that the high density of low
% initial location errors explains that: the distribution is more densely
% sampled at those points - so it seems to be worse. I'll do a density plot
% next
%
% Note: upper bound on parameter error is the 98th percentile to exclude
% some big outliers
clf;
for param_idx = 1:length(pa_param_names)
    for start_pt_idx = 1:2
        subplot(4,2,(param_idx-1)*2 + start_pt_idx);
        title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
            starting_pt_names{start_pt_idx});
        title(capitalize(title_tmp));
        xlabel('PPM error in initial location');
        ylabel(['Error in ', capitalize(pa_param_names{param_idx})]);
        hold on;
        loc_e = [loc_param_errs(:,param_idx, start_pt_idx).peak_loc_error];
        par_e = [loc_param_errs(:,param_idx, start_pt_idx).param_error];
        scatter( loc_e , par_e );
        ylim(prctile(par_e, [0,98]));
    end
end

%% How robust is each starting point to location errors (density plot)?
% Here, I again plot the the noisy gold standard data: initial location
% error versus final difference for that peak parameter (ignoring the
% crowdedness of the bin)
%
% This time, I plot the histogram density rather than a scatter plot, to
% see if things are more interpretable
%
% Almost all of the points fall into the low parameter error bins - the
% first row of bins. The horizontal distribution for these bins seems very
% close to the expected distribution shown by the error values alone. The
% color distinctions above are not very helpful (it might be a better plot
% if each column was scaled to have the same sum or each row was scaled to
% have the same sum). However, even here, the first row seems to display no
% relation between the two types of error.
%
% I initially did this plot without aligning the initial errors. For all
% parameters, the result consisted of a single red dot in the 0,0 location 
% surounded by a very hard to distinguish haze of dark blue. Essentially 
% almost every pair fell into the very low error on both counts. Here is 
% what I wrote then:
%
% These plots support my assesment above - the super-high density of low
% error peaks 
%
% Note: upper bound on parameter error is the 98th percentile to exclude
% some big outliers
clf;
for param_idx = 1:length(pa_param_names)
    for start_pt_idx = 1:2
        subplot(4,2,(param_idx-1)*2 + start_pt_idx);
        loc_e = [loc_param_errs(:,param_idx, start_pt_idx).peak_loc_error];
        par_e = [loc_param_errs(:,param_idx, start_pt_idx).param_error];
        occupancy_2d_plot( loc_e , par_e, 256, 32, 32, [0,max(loc_e), 0, prctile(par_e, 98)],hot(256));
        title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
            starting_pt_names{start_pt_idx});
        title(capitalize(title_tmp));
        xlabel('PPM error in initial location');
        ylabel(['Error in ', capitalize(pa_param_names{param_idx})]);
    end
end

%% How robust is each starting point to location errors (column-scaled density plot)?
% Here, I again plot the the noisy gold standard data: initial location
% error versus final difference for that peak parameter (ignoring the
% crowdedness of the bin)
%
% This time, I plot the histogram density rather than a scatter plot, to
% see if things are more interpretable and I scale each column in the
% density to sum to 1.
%
% When scaled by column, there seems to be an increase in the height of the
% lit-up area as ppm error increases. Is the variance increasing with
% increasing error? If so, why don't the chi-squared plots show any
% relationship?
%
% Note: upper bound on parameter error is the 98th percentile to exclude
% some big outliers
%
% This plot was only ever done with the aligned initial errors.
clf;
for param_idx = 1:length(pa_param_names)
    for start_pt_idx = 1:2
        subplot(4,2,(param_idx-1)*2 + start_pt_idx);
        loc_e = [loc_param_errs(:,param_idx, start_pt_idx).peak_loc_error];
        par_e = [loc_param_errs(:,param_idx, start_pt_idx).param_error];
        
        % Scale the occupancy matrix so all columns sum to 1
        plot_limits = [0,max(loc_e), 0, prctile(par_e, 98)];
        occ = occupancy_2d( loc_e , par_e, 32, 32, plot_limits);
        col_sums = sum(occ,1);
        scaled_occ = occ./repmat(col_sums, size(occ,2), 1);
        
        imagesc(plot_limits([1 2]), plot_limits([3 4]), scaled_occ, prctile(reshape(scaled_occ,1,[]),[0,100]));
        set(gca,'YDir','normal');
        
        title_tmp = sprintf('%s: %s (column sums are equal)',pa_param_names{param_idx}, ...
            starting_pt_names{start_pt_idx});
        title(capitalize(title_tmp));
        xlabel('PPM error in initial location');
        ylabel(['Error in ', capitalize(pa_param_names{param_idx})]);
    end
end

%% How robust is each starting point to location errors (scatter plot - by congenstion)?
% Here, I again plot the the noisy gold standard data: initial location
% error versus final difference for that peak parameter
%
% This time, I plot one set of scatter plots for each of the 10 congestions
%
% The variables seem unrelated. However, the Anderson location for
% congestion = 1.0 has a clear linear relation. It is conceivable that the
% others could have such a relation hiding in the data at low param errors.
%
% I initially did this plot without aligning the initial errors. Without 
% aligned errors, these plots don't reveal any interesting patterns - 
% except that it seems that beyond a certain limit initial distance doesn't 
% seem to matter much and that that distance seems to grow with the 
% congestion.
for congestion_idx = 2:4:10
    figure(congestion_idx); clf; maximize_figure(congestion_idx, num_monitors);
    for param_idx = 1:length(pa_param_names)
        for start_pt_idx = 1:2
            subplot(4,2,(param_idx-1)*2 + start_pt_idx);
            title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
                starting_pt_names{start_pt_idx});
            title(capitalize(title_tmp));
            xlabel('Error in initial location');
            ylabel(['Error in ', capitalize(pa_param_names{param_idx})]);
            hold on;
            loc_e = [loc_param_errs(congestion_idx, param_idx, start_pt_idx).peak_loc_error];
            par_e = [loc_param_errs(congestion_idx, param_idx, start_pt_idx).param_error];
            scatter( loc_e , par_e );
        end
    end
end
%% How robust is each starting point to location errors (scatter plot, low param errors - by congenstion)?
% Here, I again plot the the noisy gold standard data: initial location
% error versus final difference for that peak parameter
%
% This time, I plot one set of scatter plots for each of the 10 congestions
% I plot only the lower 75% of the parameter errors to see if there are
% linear relationships hiding in the lower part of the graph.
%
% Except for the aforementioned Anderson relationship for location at the
% highest congestion, I saw no relationship between the variables.
%
% I only did this graph after aligning the initial locations.
for congestion_idx = 2:4:10
    figure(congestion_idx); clf; maximize_figure(congestion_idx, num_monitors);
    for param_idx = 1:length(pa_param_names)
        for start_pt_idx = 1:2
            subplot(4,2,(param_idx-1)*2 + start_pt_idx);
            title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
                starting_pt_names{start_pt_idx});
            title(capitalize(title_tmp));
            xlabel('Error in initial location');
            ylabel(['Error in ', capitalize(pa_param_names{param_idx})]);
            hold on;
            loc_e = [loc_param_errs(congestion_idx, param_idx, start_pt_idx).peak_loc_error];
            par_e = [loc_param_errs(congestion_idx, param_idx, start_pt_idx).param_error];
            scatter( loc_e , par_e );
            ylim([0, prctile(par_e, 75)]);
        end
    end
end

%% How robust is each starting point to location errors?  (scatter plot: width scaled)
% Here, I again plot the the noisy gold standard data: initial location
% error versus final difference for that peak parameter (ignoring the
% crowdedness of the bin)
%
% For each peak parameter, I plot a scatter plot of initial location
% error versus final difference for that peak parameter. In this plot, the
% initial location errors are divided by the width of the peak.
%
% Width scaling makes the plots tighter on the x direction. However, this
% change in tightness exactly reflects the change from the initial error
% histograms. In fact, my imaginitive eye seems to see the shapes of the
% histograms in the scatter plots. This plot provides no evidence for a
% relationship between the two variables.
% 
% I initially did this plot without aligning the initial errors. The result
% was much wider and had a definite downward slope. Here is what I wrote
% then:
%
% The scatter plots seem to get tighter when you divide by peak width, but
% they still look weighted toward the lower peak error. Also the linear
% structures visible in the anderson errors for location vanish.
%
% Note: upper bound on parameter error is the 98th percentile to exclude
% some big outliers
clf;
for param_idx = 1:length(pa_param_names)
    for start_pt_idx = 1:2
        subplot(4,2,(param_idx-1)*2 + start_pt_idx);
        title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
            starting_pt_names{start_pt_idx});
        title(capitalize(title_tmp));
        xlabel('Width-scaled error in initial location');
        ylabel(['Error in ', capitalize(pa_param_names{param_idx})]);
        hold on;
        loc_e = [loc_param_errs(:,param_idx, start_pt_idx).peak_loc_error];
        loc_e = loc_e ./ [loc_param_errs(:,param_idx, start_pt_idx).peak_width];
        par_e = [loc_param_errs(:,param_idx, start_pt_idx).param_error];
        scatter( loc_e , par_e );
        ylim(prctile(par_e, [0,98]));
    end
end


%% How robust is each starting point to location errors?  (mean plot bins with equal # samples - width scaled)
% Here, I again plot the the noisy gold standard data: initial location
% error versus final difference for that peak parameter (ignoring the
% crowdedness of the bin)
%
% This time, I sort by location error and divide the data up into bins
% containing equal numbers of samples. I plot the mean location error
% versus the mean parameter error for each parameter. The location errors
% are width scaled. 
%
% I write my observations in the next one
%
% Note: upper bound on parameter error is the 98th percentile to exclude
% some big outliers
clf;
samples_per_bin = 40;
for param_idx = 1:length(pa_param_names)
    for start_pt_idx = 1:2
        subplot(4,2,(param_idx-1)*2 + start_pt_idx);
        title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
            starting_pt_names{start_pt_idx});
        title(capitalize(title_tmp));
        xlabel(sprintf('Mean (of %d) width-scaled error in initial location',samples_per_bin));
        ylabel(['Mean error in ', capitalize(pa_param_names{param_idx})]);
        hold on;
        
        % Get the error pairs
        loc_e = [loc_param_errs(:,param_idx, start_pt_idx).peak_loc_error];
        loc_e = loc_e ./ [loc_param_errs(:,param_idx, start_pt_idx).peak_width];
        par_e = [loc_param_errs(:,param_idx, start_pt_idx).param_error];
        
        % Sort them
        [sorted_loc_e, loc_order] = sort(loc_e);
        sorted_par_e = par_e(loc_order);
        
        % Calculate which bin each sample goes into
        bin_idx = floor((0:length(loc_e)-1)/samples_per_bin)+1;
        
        % Calculate the binned values
        num_bins = ceil(length(loc_e)/samples_per_bin);
        bins = struct('num',zeros(1,num_bins),'loc_e',zeros(1,num_bins), ...
            'par_e', zeros(1, num_bins));
        for i=1:length(loc_e)
            bi = bin_idx(i);
            bins.num(bi) = bins.num(bi)+1;
            bins.loc_e(bi) = bins.loc_e(bi) + sorted_loc_e(i);
            bins.par_e(bi) = bins.par_e(bi) + sorted_par_e(i);
        end
        assert(all(bins.num > 0));
        
        % Plot
        plot( bins.loc_e./bins.num, bins.par_e./bins.num,'+-' );
        xlim(prctile(bins.loc_e./bins.num,[0,100]));
    end
end


%% How robust is each starting point to location errors?  (lowest 20% mean plot bins with equal # samples - width scaled)
% Here, I again plot the the noisy gold standard data: initial location
% error versus final difference for that peak parameter (ignoring the
% crowdedness of the bin)
%
% I only display the lowest 20% of the peak errors since they are the most
% interesting.
%
% This time, I sort by location error and divide the data up into bins
% containing equal numbers of samples. I plot the mean location error
% versus the mean parameter error for each parameter. The location errors
% are width scaled. 
% 
% The previous result looks quite flat (with a few deviations at the high
% end for some summit errors). When zoomed in to the lowest 20% of errors,
% everything is completely flat modulo a bit of noise.
%
% I initially did this plot without aligning the initial errors. The result
% was much wider and had a definite downward slope the previous result
% quickly decayed to 0. Here is what I wrote then:
%
% These are hard to interpret. The general trend seems to be wildly varying
% errors with a vaguely decreasing mean as the location error increases. I
% now have a theory as to why we are seeing the decrease - once the initial
% location is far enough from the desired peak, it fastens onto another
% peak. I wonder if (for the summit focused) this is related to the width
% of the summit examined. There may also be an effect of the alignment: as
% the fitted peak location gets farther from the real one, it may not be
% the closest anymore when the alignment is done - that is not the right
% way to say it. 
clf;
samples_per_bin = 40;
for param_idx = 1:length(pa_param_names)
    for start_pt_idx = 1:2
        subplot(4,2,(param_idx-1)*2 + start_pt_idx);
        title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
            starting_pt_names{start_pt_idx});
        title(capitalize(title_tmp));
        xlabel(sprintf('Mean (of %d) width-scaled error in initial location',samples_per_bin));
        ylabel(['Mean error in ', capitalize(pa_param_names{param_idx})]);
        hold on;
        
        % Get the error pairs
        loc_e = [loc_param_errs(:,param_idx, start_pt_idx).peak_loc_error];
        loc_e = loc_e ./ [loc_param_errs(:,param_idx, start_pt_idx).peak_width];
        par_e = [loc_param_errs(:,param_idx, start_pt_idx).param_error];
        
        % Sort them
        [sorted_loc_e, loc_order] = sort(loc_e);
        sorted_par_e = par_e(loc_order);
        
        % Calculate which bin each sample goes into
        bin_idx = floor((0:length(loc_e)-1)/samples_per_bin)+1;
        
        % Calculate the binned values
        num_bins = ceil(length(loc_e)/samples_per_bin);
        bins = struct('num',zeros(1,num_bins),'loc_e',zeros(1,num_bins), ...
            'par_e', zeros(1, num_bins));
        for i=1:length(loc_e)
            bi = bin_idx(i);
            bins.num(bi) = bins.num(bi)+1;
            bins.loc_e(bi) = bins.loc_e(bi) + sorted_loc_e(i);
            bins.par_e(bi) = bins.par_e(bi) + sorted_par_e(i);
        end
        assert(all(bins.num > 0));
        
        % Plot
        plot( bins.loc_e./bins.num, bins.par_e./bins.num,'+-' );
        xlim(prctile(bins.loc_e./bins.num,[0,20]));
    end
end


%% How robust is each starting point to location errors?  (by congestion mean plot bins with equal # samples - width scaled)
% Here, I again plot the the noisy gold standard data: initial location
% error versus final difference for that peak parameter. I split by
% congestion.
%
% I sort by location error and divide the data up into bins
% containing equal numbers of samples. I plot the mean location error
% versus the mean parameter error for each parameter. The location errors
% are width scaled. 
%
% No relation is apparent even separated by congestion.
samples_per_bin = 40;
for congestion_idx = [3:3:10,10]
    figure(congestion_idx); clf; maximize_figure(congestion_idx, num_monitors);
    for param_idx = 1:length(pa_param_names)
        for start_pt_idx = 1:2
            subplot(4,2,(param_idx-1)*2 + start_pt_idx);
            title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
                starting_pt_names{start_pt_idx});
            title(capitalize(title_tmp));
            xlabel(sprintf('Mean (of %d) width-scaled error in initial location congestion %3.1f',samples_per_bin, congestion_idx/10));
            ylabel(['Mean error in ', capitalize(pa_param_names{param_idx})]);
            hold on;

            % Get the error pairs
            loc_e = [loc_param_errs(congestion_idx,param_idx, start_pt_idx).peak_loc_error];
            loc_e = loc_e ./ [loc_param_errs(congestion_idx,param_idx, start_pt_idx).peak_width];
            par_e = [loc_param_errs(congestion_idx,param_idx, start_pt_idx).param_error];

            % Sort them
            [sorted_loc_e, loc_order] = sort(loc_e);
            sorted_par_e = par_e(loc_order);

            % Calculate which bin each sample goes into
            bin_idx = floor((0:length(loc_e)-1)/samples_per_bin)+1;

            % Calculate the binned values
            num_bins = ceil(length(loc_e)/samples_per_bin);
            bins = struct('num',zeros(1,num_bins),'loc_e',zeros(1,num_bins), ...
                'par_e', zeros(1, num_bins));
            for i=1:length(loc_e)
                bi = bin_idx(i);
                bins.num(bi) = bins.num(bi)+1;
                bins.loc_e(bi) = bins.loc_e(bi) + sorted_loc_e(i);
                bins.par_e(bi) = bins.par_e(bi) + sorted_par_e(i);
            end
            assert(all(bins.num > 0));

            % Plot
            plot( bins.loc_e./bins.num, bins.par_e./bins.num,'+-' );
        end
    end
end

%% How robust is each starting point to location errors?  (mean plot bins with equal # samples - raw loc)
% Here, I again plot the the noisy gold standard data: initial location
% error versus final difference for that peak parameter (ignoring the
% crowdedness of the bin)
%
% I only display the lowest 20% of the peak errors since they are the most
% interesting.
%
% This time, I sort by location error and divide the data up into bins
% containing equal numbers of samples. I plot the mean location error
% versus the mean parameter error for each parameter. 
%
% The raw results look similar to the scaled results - but maybe a bit
% noisier. (This is the same in both the aligned initial location errors
% and in the non-aligned.)
clf;
samples_per_bin = 40;
for param_idx = 1:length(pa_param_names)
    for start_pt_idx = 1:2
        subplot(4,2,(param_idx-1)*2 + start_pt_idx);
        title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
            starting_pt_names{start_pt_idx});
        title(capitalize(title_tmp));
        xlabel(sprintf('Mean (of %d) raw error in initial location',samples_per_bin));
        ylabel(['Mean error in ', capitalize(pa_param_names{param_idx})]);
        hold on;
        
        % Get the error pairs
        loc_e = [loc_param_errs(:,param_idx, start_pt_idx).peak_loc_error];
        par_e = [loc_param_errs(:,param_idx, start_pt_idx).param_error];
        
        % Sort them
        [sorted_loc_e, loc_order] = sort(loc_e);
        sorted_par_e = par_e(loc_order);
        
        % Calculate which bin each sample goes into
        bin_idx = floor((0:length(loc_e)-1)/samples_per_bin)+1;
        
        % Calculate the binned values
        num_bins = ceil(length(loc_e)/samples_per_bin);
        bins = struct('num',zeros(1,num_bins),'loc_e',zeros(1,num_bins), ...
            'par_e', zeros(1, num_bins));
        for i=1:length(loc_e)
            bi = bin_idx(i);
            bins.num(bi) = bins.num(bi)+1;
            bins.loc_e(bi) = bins.loc_e(bi) + sorted_loc_e(i);
            bins.par_e(bi) = bins.par_e(bi) + sorted_par_e(i);
        end
        assert(all(bins.num > 0));
        
        % Plot
        plot( bins.loc_e./bins.num, bins.par_e./bins.num,'+-' );
        xlim(prctile(bins.loc_e./bins.num,[0,20]));
    end
end

%% Is there a relationship between input error rank and param error rank
% I divide the input errors and the param errors up into 5%-ile bins, then
% use a chi-squared test to evaluate whether there is a relationship
% between input error bins and param error bins - which would imply a
% relationship between input error and percentile.
% 
% I do each test twice - once for width-scaled input errors and once for
% ppm-scaled
%
% I use a bonferroni-holm correction since I am doing 8 hypothesis tests at
% once.
%
% For the ppm inputs, amazingly, there is a relationship for anderson under 
% all parameters and none for summit. Since I couldn't see it by eye, I 
% need to replot in a way that may make it more obvious. A rank-rank 
% plot will probably help. I can also just plot the %-ile table I 
% calculated as an image.
%
% For the width-scaled inputs, estimated width and lorentzianness become 
% related for summit and lorentzianness becomes unrelated for Anderson. My
% first instinct is that estimated width and estimated lorentzianness are 
% related to actual width and so dividing by the actual width introduces a
% spurious relationship. However, if that is so, why does the
% Lorentzianness lose its relationship?
input_scaling_name = {'PPM','Width'};
p=zeros(length(pa_param_names), 2, length(input_scaling_name)); % p(param_idx, start_pt_idx, input_scaling_idx) is the p value for relationship between param/starting point and the appropriately scaled input
assert(length(input_scaling_name) == 2);
for input_scale_idx = 1:2
    for param_idx = 1:length(pa_param_names)
        for start_pt_idx = 1:2
            % Get the error pairs
            loc_e = [loc_param_errs(:,param_idx, start_pt_idx).peak_loc_error];
            assert(length(input_scaling_name) == 2);
            if input_scale_idx == 2 % Do width scaling
                loc_e = loc_e ./ [loc_param_errs(: ,param_idx, start_pt_idx).peak_width];
            end
            par_e = [loc_param_errs(:,param_idx, start_pt_idx).param_error];

            % Bin the error pairs into percentile bins
            percentile_bounds = 0:5:100;
            [~, loc_e_bin] = histc(loc_e, prctile(loc_e, percentile_bounds));
            loc_e_bin(loc_e_bin == max(loc_e_bin)) = loc_e_bin(loc_e_bin == max(loc_e_bin)) - 1; % Last bin includes its upper bound
            [~, par_e_bin] = histc(par_e, prctile(par_e, percentile_bounds));
            par_e_bin(par_e_bin == max(par_e_bin)) = par_e_bin(par_e_bin == max(par_e_bin)) - 1; % Last bin includes its upper bound

            % Calculate the prob of such a table if there was no relationship
            [~,~,p(param_idx, start_pt_idx, input_scale_idx)] = crosstab(loc_e_bin, par_e_bin);

        end
    end
end

[adjusted_p, is_significant] = bonf_holm(p, 0.05);
fprintf('Relationship between parameter and ppm input location error 5%%-ile bins.\n');
fprintf('(p-values bonf-holm adjusted from chi-squared test, alpha=0.05)\n\n');
fprintf('%14s%15s%15s%13s%13s\n','Input scaling','Param name', 'Start Pt Name','Significant?', 'P-value');
for input_scale_idx = 1:2
    for start_pt_idx = 1:2
        for param_idx = 1:length(pa_param_names)

            % Print significance
            if is_significant(param_idx, start_pt_idx, input_scale_idx)
                significant_str = 'Significant';
            else                   
                significant_str = '???????????';
            end
            fprintf('%14s%15s%15s%13s%13.5g\n', ...
                input_scaling_name{input_scale_idx}, ...
                pa_param_names{param_idx}, starting_pt_names{start_pt_idx}, ...
                significant_str, adjusted_p(param_idx, start_pt_idx, input_scale_idx));
        end
    end
end


%% Is there a relationship between input error rank and param error rank (plot 5%-ile bins as occupancy plot)
% Here I plot the 5%-ile bins calculated above as occupancy maps. Colors
% are set to the matlab hot colormap (black through shades of red, orange, 
% and yellow, to white).
%
% The relationships for Anderson height, width and location values all
% clear. The Anderson location error is extremely well definied and both
% the height and width show a bright linear up-sloping ridge with a dark
% area in the lower right hand corner.
%
% However, Anderson Lorentzianness is not clear even when it has a
% significant relation (though there, there seems to be a bit of a ridge in
% the lower left-hand corner).
%
% For the width-scaled summit values, I cannot see the relationship (though
% there seem to be a few of downward sloping ridges for the width parameter
% and maybe a few upward sloping valleys for the lorentzianness parameter.
%
% The most interesting thing is a phase-transition at the 70th percentile
% of location error for the Anderson location error. Above that, there is
% no relation between input and output error.
%
% It is also interesting that width-scaling doesn't make the Anderson 
% error tighter for any parameter. In fact, it seems to make it looser.
%
% The anderson location error could be interpreted as saying that you
% either get into a specific error range or you end up far away.
for input_scale_idx = 1:2
    figure(input_scale_idx); maximize_figure(input_scale_idx, num_monitors);
    for param_idx = 1:length(pa_param_names)
        for start_pt_idx = 1:2
            subplot(length(pa_param_names), 2, (param_idx-1) * 2 + start_pt_idx);
            
            % Get the error pairs
            loc_e = [loc_param_errs(:,param_idx, start_pt_idx).peak_loc_error];
            assert(length(input_scaling_name) == 2);
            if input_scale_idx == 2 % Do width scaling
                loc_e = loc_e ./ [loc_param_errs(: ,param_idx, start_pt_idx).peak_width];
            end
            par_e = [loc_param_errs(:,param_idx, start_pt_idx).param_error];

            % Bin the error pairs into percentile bins
            percentile_bounds = 0:5:100;
            [~, loc_e_bin] = histc(loc_e, prctile(loc_e, percentile_bounds));
            loc_e_bin(loc_e_bin == max(loc_e_bin)) = loc_e_bin(loc_e_bin == max(loc_e_bin)) - 1; % Last bin includes its upper bound
            [~, par_e_bin] = histc(par_e, prctile(par_e, percentile_bounds));
            par_e_bin(par_e_bin == max(par_e_bin)) = par_e_bin(par_e_bin == max(par_e_bin)) - 1; % Last bin includes its upper bound

            % Do the occupancy plot
            occupancy_2d_plot( loc_e_bin, par_e_bin, 256, 20, 20, [], hot(256));

            title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
                starting_pt_names{start_pt_idx});
            title(capitalize(title_tmp));
            xlabel(sprintf('5%%-ile bin of %s-scaled error in initial location',input_scaling_name{input_scale_idx}));
            ylabel(['5%-ile bin of ', capitalize(pa_param_names{param_idx}), ' error']);
        end
    end
end

%% What is anderson location error phase-transition
% In the last, there was a phase transition at the 14th bin (70%-ile), so
% what is that value? 0.00285805 ppm.
%
% A more detailed plot gives the value as 35 out of 100 bin. So 65th %ile
% is supremum on that bin. I print that too. It is 0.000713798 ppm
% but nothing about that number jumps out at me.
figure(3); maximize_figure(3, num_monitors);
par_e = [loc_param_errs(:,4, 1).param_error];
fprintf('70%%-ile of Anderson location error is: %g ppm\n', prctile(par_e, 70));
fprintf('65%%-ile of Anderson location error is: %g ppm\n', prctile(par_e, 65));
loc_e = [loc_param_errs(:, 4, 1).peak_loc_error];
percentile_bounds = 0:1:100;
[~, loc_e_bin] = histc(loc_e, prctile(loc_e, percentile_bounds));
loc_e_bin(loc_e_bin == max(loc_e_bin)) = loc_e_bin(loc_e_bin == max(loc_e_bin)) - 1; % Last bin includes its upper bound
[~, par_e_bin] = histc(par_e, prctile(par_e, percentile_bounds));
par_e_bin(par_e_bin == max(par_e_bin)) = par_e_bin(par_e_bin == max(par_e_bin)) - 1; % Last bin includes its upper bound

% Do the occupancy plot
occupancy_2d_plot( loc_e_bin, par_e_bin, 256, 100, 100, [], hot(256));
title('Anderson location error vs ppm-scaled initial location error');
xlabel('1%-ile bin of ppm-scaled initial location error');
ylabel('1%-ile bin of Anderson location error');


%% Is there a relationship between input error rank and param error rank sep'd by congestion
% I divide the input errors and the param errors up into 5%-ile bins, then
% use a chi-squared test to evaluate whether there is a relationship
% between input error bins and param error bins - which would imply a
% relationship between input error and percentile.
%
% I only look at the input errors for a given congestion.
% 
% I do each test twice - once for width-scaled input errors and once for
% ppm-scaled
%
% I use a bonferroni-holm correction since I am doing 160 hypothesis tests at
% once.
%
% Most relationships come up as insignificant. More than likely, this is
% due to insufficient data and too many simultaneous tests.
input_scaling_name = {'PPM','Width'};
num_congestions = size(loc_param_errs, 1);
p=zeros(length(pa_param_names), 2, length(input_scaling_name), num_congestions); % p(param_idx, start_pt_idx, input_scaling_idx, congestion_idx) is the p value for relationship between param/starting point and the appropriately scaled input
assert(length(input_scaling_name) == 2);
for input_scale_idx = 1:2
    for congestion_idx = 1:num_congestions
        for param_idx = 1:length(pa_param_names)
            for start_pt_idx = 1:2
                % Get the error pairs
                loc_e = [loc_param_errs(congestion_idx,param_idx, start_pt_idx).peak_loc_error];
                assert(length(input_scaling_name) == 2);
                if input_scale_idx == 2 % Do width scaling
                    loc_e = loc_e ./ [loc_param_errs(congestion_idx ,param_idx, start_pt_idx).peak_width];
                end
                par_e = [loc_param_errs(congestion_idx, param_idx, start_pt_idx).param_error];

                % Bin the error pairs into percentile bins
                percentile_bounds = 0:5:100;
                [~, loc_e_bin] = histc(loc_e, prctile(loc_e, percentile_bounds));
                loc_e_bin(loc_e_bin == max(loc_e_bin)) = loc_e_bin(loc_e_bin == max(loc_e_bin)) - 1; % Last bin includes its upper bound
                [~, par_e_bin] = histc(par_e, prctile(par_e, percentile_bounds));
                par_e_bin(par_e_bin == max(par_e_bin)) = par_e_bin(par_e_bin == max(par_e_bin)) - 1; % Last bin includes its upper bound

                % Calculate the prob of such a table if there was no relationship
                [~,~,p(param_idx, start_pt_idx, input_scale_idx, congestion_idx)] = crosstab(loc_e_bin, par_e_bin);

            end
        end
    end
end

[adjusted_p, is_significant] = bonf_holm(p, 0.05);

fprintf('Relationship between parameter and ppm input location error 5%%-ile bins.\n');
fprintf('(p-values bonf-holm adjusted from chi-squared test, alpha=0.05)\n\n');
fprintf('%14s%11s%15s%15s%13s%13s\n','Input scaling','Congestion','Param name', 'Start Pt Name','Significant?', 'P-value');
for input_scale_idx = 1:2
    for congestion_idx = 1:num_congestions
        for start_pt_idx = 1:2
            for param_idx = 1:length(pa_param_names)

                % Print significance
                if is_significant(param_idx, start_pt_idx, input_scale_idx, congestion_idx)
                    significant_str = 'Significant';
                else                   
                    significant_str = '???????????';
                end
                fprintf('%14s%11d%15s%15s%13s%13.5g\n', ...
                    input_scaling_name{input_scale_idx}, ...
                    congestion_idx, pa_param_names{param_idx}, ...
                    starting_pt_names{start_pt_idx}, significant_str, ...
                    adjusted_p(param_idx, start_pt_idx, input_scale_idx, congestion_idx));
            end
        end
    end
end


%% Is there a relationship between input error rank and param error rank sep'd by congestion (plot 5%-ile bins as occupancy plot)
% Here I plot the 5%-ile bins calculated above as occupancy maps. Colors
% are set to the matlab hot colormap (black through shades of red, orange, 
% and yellow, to white).
%
% I make separate plots for each congestion and input-scale type.
%
% Looking at the plots. It does not seem like congestion was hiding any
% patterns. Any patterns I see in these smaller plots was also in the
% original combined plot (and clearer there). More data may help this, but
% for now, no evidence of different relationships.
%
% Having seen all these plots, I think the chances are slim that rank-rank
% scatter-plots are going to be very informative. So, I won't be doing
% them.
for congestion_idx = 1:3:10
    for input_scale_idx = 1:2
        figure(congestion_idx+input_scale_idx); maximize_figure(congestion_idx+input_scale_idx, num_monitors);
        for param_idx = 1:length(pa_param_names)
            for start_pt_idx = 1:2
                subplot(length(pa_param_names), 2, (param_idx-1) * 2 + start_pt_idx);

                % Get the error pairs
                loc_e = [loc_param_errs(congestion_idx,param_idx, start_pt_idx).peak_loc_error];
                assert(length(input_scaling_name) == 2);
                if input_scale_idx == 2 % Do width scaling
                    loc_e = loc_e ./ [loc_param_errs(congestion_idx ,param_idx, start_pt_idx).peak_width];
                end
                par_e = [loc_param_errs(congestion_idx,param_idx, start_pt_idx).param_error];

                % Bin the error pairs into percentile bins
                percentile_bounds = 0:5:100;
                [~, loc_e_bin] = histc(loc_e, prctile(loc_e, percentile_bounds));
                loc_e_bin(loc_e_bin == max(loc_e_bin)) = loc_e_bin(loc_e_bin == max(loc_e_bin)) - 1; % Last bin includes its upper bound
                [~, par_e_bin] = histc(par_e, prctile(par_e, percentile_bounds));
                par_e_bin(par_e_bin == max(par_e_bin)) = par_e_bin(par_e_bin == max(par_e_bin)) - 1; % Last bin includes its upper bound

                % Do the occupancy plot
                occupancy_2d_plot( loc_e_bin, par_e_bin, 256, 20, 20, [], hot(256));

                title_tmp = sprintf('%s: %s cong=%d',pa_param_names{param_idx}, ...
                    starting_pt_names{start_pt_idx}, congestion_idx);
                title(capitalize(title_tmp));
                xlabel(sprintf('5%%-ile bin of %s-scaled error in initial location',input_scaling_name{input_scale_idx}));
                ylabel(['5%-ile bin of ', capitalize(pa_param_names{param_idx}), ' error']);
            end
        end
    end
end

%% What do the peaks/spectra with extreme error values look like
% 
% Is there any obvious characteristic of the peaks with extreme error
% values? I had to choose a small subset of the potential extreme value
% plots because of limitations on the number of figures my home computer
% has memory to display (and because I didn't want to manually examine 240
% plots -- that would take too long). Changing the crowding and parameter
% name fastest gives me the best opportunity to compare among starting
% points should I want to, so I chose that reduction method. I chose 3
% crowdings to represent low, medium, and high crowding.
%
% Figure 1: Top loc, min param Anderson height crowding: 1 ... Result 691 Deconv 3 Peak 4
% Not a good fit, but not the fault of the alignment. Too wide and a bit
% too short, but on-the-money location-wise.
%
% Figure 2: Top loc, max param Anderson height crowding: 1 ... Result 861 Deconv 3 Peak 2
% Could be bad alignment. Anderson is fitting a completely different peak
% from the original (and does a good job of it). I need to look at the
% other peaks in the spectrum to see why the alignment was as it is.
%
% Figure 3: Bot loc, max param Anderson height crowding: 1 ... Result 1081 Deconv 3 Peak 7
% One of Anderson's famous fit something really wide and low local minima.
% I have don't know why these happen except for badly set bounds. I'm sure
% if I examined the path, I could see where the tradeoffs create a local
% minimum.
%
% Figure 4: Top loc, min param Anderson width crowding: 5 ... Result 1015 Deconv 3 Peak 1
% Such a good fit, you can't tell there was any location error to begin
% with.
%
% Figure 5: Top loc, max param Anderson width crowding: 5 ... Result 415 Deconv 3 Peak 7
% This peak is just a BAD fit. It is SO much larger than the maximum of the
% spectrum in the area. Its size must be covering up for another mistake
% elsewhere in the spectrum.
%
% Figure 6: Bot loc, max param Anderson width crowding: 5 ... Result 35 Deconv 3 Peak 6
% Very small peak under a much larger peak. Fitted an extremely wide peak.
% I've seen anderson starting points do this before.
%
% Figure 7: Top loc, min param Anderson lorentzianness crowding: 9 ... Result 249 Deconv 3 Peak 7
% This is a peak on the edge. The correct lorentzianness is probably an
% accident. The fitted peak doesn't line up very well with the original.
%
% Figure 8: Top loc, max param Anderson lorentzianness crowding: 9 ... Result 1059 Deconv 3 Peak 2
% Could be a bad alignment. We fitted the peak next door from the one we
% were supposed to.
%
% Figure 9: Bot loc, max param Anderson lorentzianness crowding: 9 ... Result 39 Deconv 3 Peak 3
% Overestimated peak greatly overlapped by another larger peak
%
% Figure 10: Top loc, min param Summit location crowding: 1 ... Result 641 Deconv 4 Peak 6
% A pretty good fit. It looks like the main error is actually
% lorentzianness and/or width. There is essentially no location error.
%
% Figure 11: Top loc, max param Summit location crowding: 1 ... Result 581 Deconv 4 Peak 3
% The initial location error caused summit to fit a component of a larger
% peak rather than the actual peak (which is very small - only a few noise
% standard deviations high)
%
% Figure 12: Bot loc, max param Summit location crowding: 1 ... Result 951 Deconv 4 Peak 3
% Try as I might, I can't find the mode of the deconvolved peak - it is
% completely flat.
%
% Figure 13: Top loc, min param Summit height crowding: 5 ... Result 585 Deconv 4 Peak 5
% Very slight error (as min param might suggest) even location error is 
% only slight.
%
% Figure 14: Top loc, max param Summit height crowding: 5 ... Result 425 Deconv 4 Peak 5
% Underestimated a small peak overlapped by a much larger one.
%
% Figure 15: Bot loc, max param Summit height crowding: 5 ... Result 185 Deconv 4 Peak 3
% Very slight overestimate. Since this is the maximum height error, heights
% were very accurate at crowding 5 when the initial location was close
%
% Figure 16: Top loc, min param Summit width crowding: 9 ... Result 229 Deconv 4 Peak 7
% Decent fit of a very large peak on the edge of a spectrum.
%
% Figure 17: Top loc, max param Summit width crowding: 9 ... Result 459 Deconv 4 Peak 1
% Summit underestimated width in large peak with several side-peaks -
% displacement of the main peak and the side peaks could account very
% reasonably for this sinc the side peaks might be made larger to
% compensate.
%
% Figure 18: Bot loc, max param Summit width crowding: 9 ... Result 489 Deconv 4 Peak 4
% Summit slightly underestimated height and width for a very small peak
% overshadowed by a much larger peak
%
old_pause_state = pause('on'); % Pausing to allow all the figures to be created

figure_number = 1;
param_idx = 0;
for starting_pt_idx = 1:length(starting_pt_names)
    for congestion_idx = [1,5,9]
        assert(all(congestion_idx <= size(loc_param_errs,1)));
        param_idx = param_idx + 1; 
        if param_idx > length(pa_param_names); param_idx = 1; end
        extreme = GLBIO2013_extreme_loc_param_pairs(...
            glbio_combined_results, ...
            loc_param_errs(congestion_idx,param_idx,starting_pt_idx));
        extreme_names = {'Top loc, min param','Top loc, max param','Bot loc, max param'};
        for val=1:length(extreme)
            e = extreme(val);
            pause(3);
            figure(figure_number);

            GLBIO2013_plot_peak_estimate(e.datum, e.deconv_idx, ...
                e.deconv_peak_idx, false);
            title(sprintf('%s %s %s crowding: %d\nResult %d Deconv %d Peak %d', extreme_names{val}, ...
                starting_pt_names{starting_pt_idx}, ...
                pa_param_names{param_idx}, congestion_idx, ...
                e.result_idx, e.deconv_idx, e.deconv_peak_idx ...
                ));
            figure_number = figure_number + 1;
        end
    end
end

pause(old_pause_state);

%% Print the figure number - what was plotted key
% For the analysis in the previous section, I needed to print the title of
% each plot with its corresponding figure number as a comment. This code did it.
figure_number = 1;
param_idx = 0;
for starting_pt_idx = 1:length(starting_pt_names)
    for congestion_idx = [1,5,9]
        assert(all(congestion_idx <= size(loc_param_errs,1)));
        param_idx = param_idx + 1; 
        if param_idx > length(pa_param_names); param_idx = 1; end
        extreme = GLBIO2013_extreme_loc_param_pairs(...
            glbio_combined_results, ...
            loc_param_errs(congestion_idx,param_idx,starting_pt_idx));
        extreme_names = {'Top loc, min param','Top loc, max param','Bot loc, max param'};
        for val=1:length(extreme)
            e = extreme(val);
            fprintf('%% Figure %d: %s %s %s crowding: %d ... Result %d Deconv %d Peak %d\n%%\n%%\n', ...
                figure_number, extreme_names{val}, ...
                starting_pt_names{starting_pt_idx}, ...
                pa_param_names{param_idx}, congestion_idx, ...
                e.result_idx, e.deconv_idx, e.deconv_peak_idx ...
                );
            figure_number = figure_number + 1;
        end
    end
end

%% Double-check figures 2 and 8
% Figures 2 and 8 of the extreme values might be results of a misalignment.
% Here I plot the corresponding peaks for those figures so I can visually
% verify the alignment

%% Double-check figure 2
% Figure 2 was Result 861 Deconv 3 Peak 2
%
% This is just a case of a very bad peak location estimate the locations of
% the deconvolved peaks are:
%
%  2.3204    2.2178    2.3205    3.4209    3.4669    3.4816    3.4914
%
% Their cooresponding original peaks are at:
%
%  2.2176    1.4974    2.3204    3.4209    3.4665    3.4814    3.4914
%
% You can see that the deconvolved spectrum has two peaks near 2.3204
% whereas the original has one and no peaks near 1.4974. Thus the alignment
% must make sacrifices and it chooses to sacrifice the peak at 2.2178.
for i = 1:7
    figure(i);
    clf;
    GLBIO2013_plot_peak_estimate(glbio_combined_results(861), 3, ...
                i, false);
end

fprintf('Aligned indices: %s\n', to_str(glbio_combined_results(861).deconvolutions(3).aligned_indices));
fprintf('Deconvolved locations: %s\n',to_str([glbio_combined_results(861).deconvolutions(3).peaks(1:7).location]));
fprintf('Original locations   : %s\n',to_str([glbio_combined_results(861).spectrum_peaks([4 3 7 6 2 1 5]).location]));

%% Double-check figure 8
% Figure 8 was Result 1059 Deconv 3 Peak 2
%
% I didn't bother to plot things this time. The numbers are clearer.
%
% This is another case of a very bad peak location estimate.

% The locations of the deconvolved peaks are:
%
%  1.0649    1.0259    1.0491    1.0649    1.0789    1.0909    1.1159
%
% Their cooresponding original peaks are at:
%
%  1.0490    1.0182    1.0259    1.0648    1.0785    1.0909    1.1159
%
% The same error happened here - the deconvolution put two peaks where the
% original had one. Then one of those had to be mismatched and that
% mismatching threw off other parts of the alignment - in particular peak
% 2.
%
% The best alignment would have been
% Deconv: 1.0649    1.0259    1.0491    nothing   1.0649    1.0789    1.0909    1.1159
%
% Orig:   nothing   1.0259    1.0490    1.0182    1.0648    1.0785    1.0909    1.1159
%
% But the algorithm I'm using can't detect this. The algorithm works
% correctly, but the alignment comes out a bit screwy.
%
% An improved alignment that would give finite error etc is:
% Deconv: 1.0649    1.0259    1.0491    1.0649    1.0789    1.0909    1.1159
%
% Orig:   1.0182    1.0259    1.0490    1.0648    1.0785    1.0909    1.1159
%
% A robustified error measure would generate this kind of alignment. (For
% example, linear cost up to a distance of 0.01 ppm then charge everything
% over that at 0.01 ppm.)
%
% From this brief survey it seems that the Anderson starting point makes
% this kind of error more than the Summit starting point and will thus 
% generate worse alignments.
%
% In an ideal world, I would use a robustified alignment algorithm (the
% cut-off is easy to incorporate into my cost matrix calculations) but I
% don't know how to choose the cut-off, and that might take some time.
% Instead, I will just note this problem in the paper if size constraints 
% permit it.
fprintf('Aligned indices: %s\n', to_str(glbio_combined_results(1059).deconvolutions(3).aligned_indices));
fprintf('Deconvolved locations: %s\n',to_str([glbio_combined_results(1059).deconvolutions(3).peaks(1:7).location]));
fprintf('Original locations   : %s\n',to_str([glbio_combined_results(1059).spectrum_peaks([1, 7, 4, 2, 5, 6, 3]).location]));

%% Does abs vs squared cost function fix alignment problem for figures 2 and 8?
%
%
% No, it doesn't. It fixes figure 8 but not 2.
%
% The new alignment for figure 2 is:
%
% Deconv: 3.4816    3.4669    2.2178    2.3204    3.4914    3.4209    2.3205
% Orig:   3.4814    3.4665    1.4974    2.2176    3.4914    3.4209    2.3204
%
% And figure 8 is:
%
% Deconv: 1.0491    1.0649    1.1159    1.0259    1.0789    1.0909    1.0649
% Orig:   1.0490    1.0648    1.1159    1.0259    1.0785    1.0909    1.0182
%
% As an experiment, I did a quick and dirty replacement of abs with
% sqrt(abs
%
% The new alignment worked! The square root biases the result in favor of
% packing all the error into a smaller number of big mistakes. I still need
% to write the new routine and then re-run things.


fig_2_deconv_loc = [glbio_combined_results(861).deconvolutions(3).peaks(1:7).location];
fig_2_orig_loc = [glbio_combined_results(861).spectrum_peaks(1:7).location];
[assignment,cost] = GLBIO2013Deconv.l_p_norm_assignment(fig_2_orig_loc, fig_2_deconv_loc,1);
fprintf('Figure 2 alignment using abs\n');
[fig_2_deconv_loc(assignment); fig_2_orig_loc] %#ok<NOPTS>
fprintf('The cost of the original alignment is: %g\n', cost);
fprintf('Figure 2 manual alignment\n');
manual_alignment = assignment([1:2,4,3,5:7]);
fig_2_man_matrix = [fig_2_deconv_loc(manual_alignment); fig_2_orig_loc] %#ok<NOPTS>
manual_cost = sum(abs(fig_2_man_matrix(1,:) - fig_2_man_matrix(2,:)));
fprintf('The abs cost of the manual alignment is: %g\n', manual_cost);

fig_8_deconv_loc = [glbio_combined_results(1059).deconvolutions(3).peaks(1:7).location];
fig_8_orig_loc = [glbio_combined_results(1059).spectrum_peaks(1:7).location];
assignment = GLBIO2013Deconv.l_p_norm_assignment(fig_8_orig_loc, fig_8_deconv_loc,1);
fprintf('Figure 8 alignment using abs');
[fig_8_deconv_loc(assignment); fig_8_orig_loc] %#ok<NOPTS>

%% How many alignments would change using L0.5 norm rather than L2 norm?
% I have another alignment method (my "unambiguous" alignment) but I'd like
% to look at how ambiguous the situation is so I can better motivate (or
% not) the use of my other method.
%
% Changing the exponent affects 2450 out of 7200 deconvolutions in my
% preliminary test set - 34%.
%
% The deconvolution methods produce ambiguous deconvolutions at different
% rates. For my test set, I got the following table (there were 1200
% instances of each deconvolution method)
%
% Deconv:             1     2     3     4     5     6
% Times affected:   766     0   753    18   468   445
%
% The methods corresponding to each deconvolution number are:
%
% 1. gold_standard, Anderson
% 2. gold_standard, Summit
% 3. noisy_gold_standard, Anderson
% 4. noisy_gold_standard, Summit
% 5. smoothed_local_max, Anderson
% 6. smoothed_local_max, Summit
%
% So, for gold standard and noisy gold standard, 63-64% of the Anderson
% deconvolutions had an ambiguous alignment, whereas very few of the summit
% deconvolutions did (0% and 1.5%). For smoothed local max, they were
% equivalent, both producing around 40% ambiguous deconvolutions.

affected_deconvs=struct('result_idx', [], 'deconv_idx', []);
num_deconvs = 0;
for result_idx=1:length(glbio_combined_results)
    datum = glbio_combined_results(result_idx);
    orig_peaks = datum.spectrum_peaks;
    num_deconvs = num_deconvs + length(datum.deconvolutions);
    for deconv_idx = 1:length(datum.deconvolutions)
        deconv = datum.deconvolutions(deconv_idx);
        l_2_align = GLBIO2013Deconv.best_alignment(deconv.peaks,orig_peaks,'l2');
        l_half_align = GLBIO2013Deconv.best_alignment(deconv.peaks,orig_peaks,'l0.5');
        if any(any(l_2_align ~= l_half_align))
            affected_deconvs.result_idx(end+1)=result_idx;
            affected_deconvs.deconv_idx(end+1)=deconv_idx;
        end
    end
end

fprintf('Num affected: %d out of %d \n', ...
    length(affected_deconvs.result_idx), num_deconvs);
deconv_affected = histc(affected_deconvs.deconv_idx, 1:max(affected_deconvs.deconv_idx));
fprintf('\nDeconv:        '); fprintf(' %5d', 1:max(deconv_idx));
fprintf('\nTimes affected:'); fprintf(' %5d', deconv_affected);
fprintf('\n');

%% Thinking about alignment
%
% Before I go and completely reform the way I do the alignment, I'd like to
% write a bit to record my thoughts on the issue.
%
% Alignment issues come about because of an ill-posedness in speaking about
% errors per peak. What we really have as gold-standard data is a set of
% peaks and our deconvolution gives us another set of peaks. If they're
% identical, then very good. However, they will seldom be identical. So,
% the proper error measure is a function defined on peak-set pairs
% (peak-set x peak-set -> R). 
%
% Once you've thought of this, the obvious idea is to use a set-set
% distance metric for the error. There are a number of them. From Theodoris
% and Koutroumbas p. 511, treat each peak as a 4 d point. We can use the
% mahalanobis distance for the peak-peak distance.
%
% 1. Distance between closest pair of peaks one from each set
%
% 2. Mean distance between all pairs of peaks
%
% 3. Distance between centroids of each set (this is obvious nonsense in
%    our domain)
%
% From wikipedia:
%
% 4. Hausdorff distance - the maximum distance from a point in 1 set to its
%    closest neighbor in the other set
%
%
% Since we are looking for error measures, method 1 would give the minimum
% possible error - score the test on the best answer. This doesn't seem a
% good evaluation method.
%
% Mean distance between all pairs (method 2) doesn't seem useful either.
% [1,2] [1,2] (mean distance = 0+0+1+1/4 = 1/2) shouldn't be worse than
% [1000,2000] [1000,2000] (mean distance = 0+0+1000+1000/4 = 500).
% 
% The Hausdorff distance (method 4) shows more promise. The nearest
% neighbor seems a non-biased way of choosing an alignment and the maximum
% error between a peak and its aligned neighbor seems an OK way of dealing
% with misalignment or summarizing the error. It is conservative in that it
% gives one species of the maximum peak alignment error for the spectrum.
%
% Eiter & Mannila (p. 112 or 4) mention that the Hausdorff distance is
% sensitive to extreme points. In fact, Hausdorff throws out all
% point-pairs but one. They want measures that reflect the rest of the
% points in the set. They want the set where all matches are good but one 
% is bad to degree b to have a lower error than a set where all matches
% are bad to degree b.
%
% The distance functions they consider are:
%
% a. d_md - the sum of the minimum distances. For each peak in s1 find
%      the distance to its nearest neighbor in s2. Sum these to sum1. Then
%      for each peak in s2, find the distance to its nearest neighbor in
%      s1. Sum these to sum2. Take the mean of sum1 and sum2.
%
% b. d_s  - the surjection distance. Without loss of generality, let s1
%      be at least as large as s2. Then for each mapping from s1 onto s2,
%      (each surjection) sum the distances to the corresponding points.
%      Take the surjection distance to be the minimum of these sums. Note
%      that in a surjection, each element of s1 must have an out-degree of
%      exactly 1 and each element of s2 must have an in-degree of at least
%      1.
%
% c. d_sf - the fair surjection distance. Like the surjection distance, but
%      limit the surjections to those in which the number of peaks
%      from s1 mapping onto a given peak in s2 differs by at most 1. So if
%      s1 had peaks [a,b,c] and s2 had peaks [x,y] then
%      [{a,b,c}->x,{}->y] would be an acceptable surjection for d_s but not
%      for d_sf. [{a,b}->x,{c}->y] and [{b}->x,{a,c}->y] would be
%      acceptable surjections under both measures. Note that
%      [{a,b,c}->x,{a}->y] is not a surjection because a has an out-degree
%      of 2.
%
% d. d_l - the minimum link distance. Like the surjection distance except
%      instead of minimizing over surjections it minimizes over "linkings".
%      A linking is an undirected bipartite graph where each peak has
%      degree of at least 1. Each edge is assigned the distance for its two
%      end points and the score of a linking is the sum of its edges'
%      distance. Finally, the distance is the minimum score over all
%      linkings.
%
% Before I evaluate Eiter & Mannila's distances, I want to consider some
% criteria for a good distance taken from the assumptions underlying our
% problem.
%
% Criteria for a good distance:
%
% I take these criteria from my experience matching peak sets by hand.
%
% A. Each peak in either set should map to at most 1 peak in the other set.
%
%    This criterion arises from our desired goal - one peak in the output
%    for each peak in the input. It is true that a given input peak can
%    produce multiple output peaks in the deconvolution due to bad
%    deconvolution. However, this is not the ideal. It is reasonable to
%    penalize this situation.
%
% B. An unmatched peak should be an error greater than any matched pair of
%    peaks
%
%    This makes it always advantageous to produce peaks in the right area
%    even if the match is not very good.
%
%    It also makes the following two situations assign an equal error to Y
%
%    A   B                     C
%    X Y Z
%
%    and
%
%    A   B
%    X Y Z
%
%    Y is not a match for C
%
% C. Each input peak can match only to adjacent peaks on the output (see
%    after the ascii art for a revised statement C')
%
%    This keeps peaks from skipping undesirable peaks and matching others.
%    This makes mismatches more local and makes sense in matching.
%
%    A      B     C    D
%             X  Y  Z
%
%    This rule would mean Z can only match C & D, Y can only match C (X is
%    in the way for B), and X can only match B.
%
%    This rule ensures that the matched peaks are in the same order as
%    their original peaks.
%
%    One place I wonder about this rule is under a big "peak" that was
%    really the result of two overlapping smaller peaks.
%
%    Another thing to consider is changing the above to
%
%    A      B     C    D
%             X    YZ
%
%    Z hasn't changed, but because Y moved, Z is no longer a candidate for
%    C? That doesn't completely sit with me. I can imagine the following
%    situation:
%      ____
%     /    \
%    /   C  \
%
%           ____
%        _ /    \
%       /Y\   Z  \
%
%    It would be reasonable to match Z with C since they are much more
%    similar overall despite the fact that Y is closer on the ppm axis.
%
% C'.Probably this principle should be "Each deconvolved peak can only
%    match adjacent original peaks" This allows Z to match C,D and X to
%    match B,C and Y to match B,C.
%
% D. Matches are undirected. If A matches X then X matches A. 
%
%    This rule comes out of the model of a single peak producing at most 1
%    peak in the output.
%
% E. The error should be a function of the matches and matched peaks
%
% F. Over all legal matchings, maximize the number of edges
%
%    If you can match two peaks, you should match them.
%
% G. If A is closest neighbor to B and B is closest to A then A and B
%    should be matched
%
%    This says that a recipriocal closest neighbor relationship is a match.
%
% H. Only closest neighbors should be matched.
%
%    This is a slightly stronger version of C. Under this, D cannot match Z
%    in the example under principle C because it is a farther away than C.
%
%    I think this is too strong. (B-X, C-Y, D-Z) and (B-X,C-Z) should both
%    be permissable matchings in general. 
%
% I. If a peak more than 1 legal matching, it should be left unmatched.
%
%    This is a conservative principle.
%
%    Note, if using A, C', D, G, E, F, I in the first C example, once 
%    (B-X, C-Y) are forced by G then D cannot match Y because of principle
%    A, so D has only one legal matching and F comes into effect
%
% J. Let P be a deconvolved peak. Let uadj(P) be the zero, one or two 
%    original peaks adjacent to P and still unmatched. Let unm(O) be the 
%    set of unmatched peaks P' for which O (an original peak) is an 
%    element of uadj(P'). If P is in unm(O) and O's nearest neighbor in
%    unm(O) is P and P's nearest neighbor in uadj(P) is O, then match O and
%    P. 
%
%    In other words if (when you consider only unmatched elligible peaks) 
%    A's closest neighbor is B and B's is A, match A and B.
%
% K. Unless forced by J, peaks remain unmatched
%
%    This is another conservative principle.
%
% The rules that I feel the most sure about are A, D & E. Unfortunately A
% is sufficient to eliminate all of Eiter & Mannila's distance functions.
%
% One issue to consider is what the error should be. I'd like to make the
% matching error based on location error. Then, the distance error will be 
% one of the other parameters (or some combination thereof to give an
% overall error measure.)
%
% Are A, D, and E sufficient to create a matching measure?
%
% No, there are many possible undirected bipartite graphs with at most
% degree 1 at each node.
%
% Adding F reduces the number of graphs but is still ambiguous. For example
% there are 4*3! graphs satisfying these rules for the example under
% principle C.
%
% Adding G reduces the number of graphs in the C example to 2 (A-Z,B-X,C-Y)
% or (D-Z,B-X,C-Y)
%
% Adding C' makes the matching unique
%
% For a different example, we can consider:
%
% A       BC
%  Q R  S  T
%
% (A,Q) and (C,T) are forced by G. B's closest neighbor is T, but the
% relationship is not recipriocal. Since S and R can both match B, they are
% left unmatched due to the conservative principle. 
%
% If we remove R then S is unambiguous and matches B.
%
% We can get slightly less conservative matching that does the reasonable
% thing and matches S with B by replacing C' and G with J. This essentially
% forces multiple rounds of matching.
%
% First round (A-Q, C-T)
% Second round S's closest unmatched neighbor is B and B's is S. (R's
% closest unmatched neighbor is also B, but the closeness is not
% recipriocated). So, match (B-S). R has no potential matches, so left
% unmatched.
%
% A, D, E, J, and K form a sufficient set of rules to match what I think of
% as conservative intuitive matches. It would, however, match Y with C
% rather than Z with C in the ascii art deconvolution example just before
% C'. Any "recipriocal nearest neighbor" rule will match Y rather than Z
% unless you also include other dimensions in the matching. Then
% sufficiently good matches on the other dimensions become nearest
% neighbors. However, this gets rid of the "between" concept I've been
% relying on.
%
% We could deal with this problem by setting up the potential matches based
% only on location and betweenness. Then we do the nearest neighbors (which
% force matches) using the full set of attributes (probably a Mahalanobis
% distance).
%
% Mahalanobis distances - figured using the peaks for a given
% congestion since the range of locations available will be different for
% different congestions. Since the covariance matrix is diagonal
% (independently chosen parameters) this is just the scaled Euclidean
% distance.
%
% Using the Mahalanobis distances is a bit of a problem because, on the
% surface, it appears to make the alignment impossible to do during the 
% data generation stage. You need to know the standard deviations for each
% variable. Fortunately, we know the distributions from which the variables
% are drawn, so we can calculate the standard deviations a-priori if we
% know the congestion. However, it does require passing the congestion to
% the alignment routine.
%
% I'll want to write a routine "scale_peaks" that takes a list of peaks and
% congestions and scales them to the Mahalanobis distance. This will be
% relatively easy to test since I can generate a lot of samples, scale
% them, and their means and standard deviations should be 0 and 1
% respectively.
%
% A final option is to do an L2 and an L0.5 alignment and any points which
% differ are taken as ambiguous. I don't like this because observationally,
% in the cases I hand examined above, some of the points which changed
% weren't ambiguous in my opinion. They were clearly closest to a
% particular original peak, but the tradeoffs involved in L2 forced them
% into another alginment. Maybe an L1.01 vs an L0.99 might better show
% which are genuinely ambiguous (examining alignments generated using the 
% L1 norm I frequently found two equivalent optima that would have
% varied depending on the exponent.)
%
% Yet one more option is to ignore the individual values entirely. If I
% look at the deconvolved spectra, their distribution should match the
% original spectra. The K-L divergence of the distributions will give me a
% measure of the number of bits of information lost in using each
% deconvolution method to approximate the original. Looking at the joint
% distribution will find spurious correlations introduced by the
% deconvolution methods. I'm not sure what to do about missing peaks, 
% though. But this is a very promising approach.
%
% A final peak-wise method is to: calculate the distribution of the
% differences of the closest peak. (That is, for each original peak,
% find the closest deconvolved peak and give the distribution of the
% parameter differences contingent on method and/or congestion and/or
% input peak picking error.) Using a better alignment would give a better
% definition for "closest peak". One could do - for each peak with a match,
% give the error distribution.



%% Calculate the relative parameter errors
pe_rel_list = GLBIO2013_calc_param_rel_error_list(glbio_combined_results);

%% Precalculate some values needed for plotting relative errors by parameter
% On my home computer the large "unique" statements take a lot of time to
% compute, so I've moved them to a separate cell so they only have to be
% calculated once.
param_names = unique({pe_rel_list.parameter_name});
assert(length(param_names) == 5,'Right number of param names');
peak_pickers = unique({pe_rel_list.peak_picking_name});
picker_legend = {'Gold Standard','Noisy Gold Standard', 'Smoothed Local Max'};
picker_formats = {'r+-','bd-','*k-'};
assert(length(picker_legend) == length(peak_pickers),'Right # picker legend entries');
assert(length(picker_formats) == length(peak_pickers),'Right # picker formats');
collision_probs = unique([pe_rel_list.collision_prob]);

%% Plot relative errors by parameter
% Now we break up the results into one graph for each parameter. Each
% graph has 3 lines - one per peak-picking method and gives the improvement
% as a function of spectrum crowding.
%
% The graphs show that the improvement decreases as the crowding increases.
% They also show that the smoothed local max peak picking algorithm has
% lower improvement - probably because the algorithms are trying to fit an
% incorrect model with too few peaks and the error due to the incorrect 
% model is greater on average than the error due to the improper starting
% point.
%
% Note: relative errors are (actual-correct)/abs(correct) modified to make
% correct 1e-100 whenever it is smaller (and so avoid divide by 0 errors).
% Mean relative improvement is the mean difference in mean relative error: 
% anderson - summit.
%
% _The code below also calculates an matrix of the improvement values
% ordered by the properties of interest (parameter, picker, and
% crowdedness).
clf;
pe_values_per_triple = length(pe_rel_list)/length(param_names)/length(peak_pickers)/length(collision_probs);
improvements = zeros(length(param_names),length(peak_pickers),length(collision_probs),pe_values_per_triple);
for param_idx = 1:length(param_names)
    subplot(2,3,param_idx);
    title_tmp = param_names{param_idx};
    title([upper(title_tmp(1)),title_tmp(2:end)]);
    xlabel('Probability of peak collision');
    ylabel('Mean Relative Improvement %');
    hold on;
    pe_has_param = strcmp({pe_rel_list.parameter_name},param_names{param_idx});
    handle_for_picker = zeros(1,length(peak_pickers));
    for picker_idx = 1:length(peak_pickers)
        pe_has_picker = strcmp({pe_rel_list.peak_picking_name},peak_pickers{picker_idx});
        mean_error_for_prob = zeros(1,length(collision_probs));
        std_dev_error_for_prob = mean_error_for_prob;
        ci_half_width_95_pct = std_dev_error_for_prob;
        for prob_idx = 1:length(collision_probs)
            pe_has_prob = [pe_rel_list.collision_prob] == collision_probs(prob_idx);
            selected_pes = pe_rel_list(pe_has_prob & pe_has_picker & pe_has_param);
            selected_diffs = [selected_pes.error_diff];
            improvements(param_idx, picker_idx, prob_idx,:) = selected_diffs;
            mean_error_for_prob(prob_idx) = mean(selected_diffs);
            std_dev_error_for_prob(prob_idx) = std(selected_diffs);
            num_diffs = length(selected_diffs);
            if num_diffs > 1
                t_value = tinv(1-0.025, num_diffs - 1);
            else
                t_value = inf;
            end
            ci_half_width_95_pct(prob_idx) = t_value * std_dev_error_for_prob(prob_idx)/sqrt(num_diffs); % half the width of a 95% confidence interval for the mean
        end
%         handle_for_picker(picker_idx) = plot(collision_probs, ...
%             mean_error_for_prob, picker_formats{picker_idx});
        handle_for_picker(picker_idx) = errorbar(collision_probs, ...
            mean_error_for_prob, ci_half_width_95_pct, ...
            picker_formats{picker_idx});
    end
    if param_idx == 3
        legend(handle_for_picker, picker_legend, 'location','NorthEast');
    end
end

%% For which values is there a difference in the relative errors?
% I do multiple t-tests using a holm-bonferroni correction to see which
% values there is evidence of a significant improvement and a second set 
% of tests to see where there is evidence of a significant detriment. I
% use a 0.05 as a significance threshold.
%
% There was significant improvement in all cases except for some of the 
% smoothed local maximum peak-picking. There was no significant worsening 
% for any combination of parameters.
%
% For the smoothed local maximum peak picking, the test did not detect
% improvement for all but the least crowded bin of the lorentzianness,
% for all but the second most crowded of the location parameter, and for
% 0.6,0.7, and 1.0 collision probabilities of the height parameter.

improvement_p_vals = zeros(length(param_names),length(peak_pickers),length(collision_probs));
detriment_p_vals = improvement_p_vals;
for param_idx = 1:length(param_names)
    for picker_idx = 1:length(peak_pickers)
        for prob_idx = 1:length(collision_probs)
            diffs = improvements(param_idx, picker_idx, prob_idx,:);
            [~, improvement_p_vals(param_idx, picker_idx, prob_idx)] = ttest(diffs,0,0.05,'right');
            [~, detriment_p_vals(param_idx, picker_idx, prob_idx)] = ttest(diffs,0,0.05,'left');
        end
    end
end

% Correct the p-values
improvement_p_vals_corrected = improvement_p_vals;
improvement_p_vals_corrected(:) = bonf_holm(improvement_p_vals(:),0.05);
detriment_p_vals_corrected = detriment_p_vals;
detriment_p_vals_corrected (:) = bonf_holm(detriment_p_vals(:),0.05);

fprintf('Relative error improvement?\n');
fprintf('Peak Property            |Peak Picking Method   |Prob. Collision|Rel. Improved?     |Rel. Worsened?     \n');
for param_idx = 1:length(param_names)
    for picker_idx = 1:length(peak_pickers)
        for prob_idx = 1:length(collision_probs)
            i = improvement_p_vals_corrected(param_idx, picker_idx, prob_idx);
            if i >= 0.05
                istr = '?  ??  ?';
            else
                istr = 'Improved';
            end
            d = detriment_p_vals_corrected(param_idx, picker_idx, prob_idx);
            if d >= 0.05
                dstr = '?  ??  ?';
            else
                dstr = 'Worsened';
            end
            
            fprintf('%25s %22s %15.1f %8s p=%8.3g %8s p=%8.3g\n', ...
                param_names{param_idx}, peak_pickers{picker_idx}, ...
                collision_probs(prob_idx), istr, i, dstr, d);
        end
    end
end