% Prints a summary of the analysis of the results from the GLBIO2013 experiments

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
    model.max_rough_peak_width, window_samples, @do_nothing);
GLBIO2013_plot_peaks_and_starting_point('Summit On Separated Peaks', ...
    extended_x, simple_peaks1, 1, starting_params, lb, ub);

subplot(2,2,4);
[starting_params, lb, ub] = deconv_initial_vals_dirty ...
    (x, sum(simple_peaks2.at(x),1), min(x), max(x), [simple_peaks2.location], ...
    model.max_rough_peak_width, window_samples, @do_nothing);
[handles,element_names] = ...
    GLBIO2013_plot_peaks_and_starting_point('Summit On Separated Peaks', ...
    extended_x, simple_peaks2, 2, starting_params, lb, ub);
legend(handles, element_names, 'Location', 'NorthEast');

maximize_figure(gcf, 2);
%% Load the combined results
load('Mar_07_2013_experiment_for_GLBIO2013Analyze');

%% Defend spectrum width choices
% The spectral widths chosen give better than 99% probabilities that the
% probabilities of being free of peak merging are within 0.4% of the target
% probability.
GLBIO2013_print_prob_counts_in_range_table(0.004);

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
% These graphs seem to show that there is more error when the initial
% location is lower. However, I suspect that the high density of low
% initial location errors explains that: the distribution is more densely
% sampled at those points - so it seems to be worse. I'll do a density plot
% next
clf;
for param_idx = 1:length(pa_param_names)
    for start_pt_idx = 1:2
        subplot(4,2,(param_idx-1)*2 + start_pt_idx);
        title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
            starting_pt_names{start_pt_idx});
        title(capitalize(title_tmp));
        xlabel('Error in initial location');
        ylabel(['Error in ', capitalize(pa_param_names{param_idx})]);
        hold on;
        loc_e = [loc_param_errs(:,param_idx, start_pt_idx).peak_loc_error];
        par_e = [loc_param_errs(:,param_idx, start_pt_idx).param_error];
        scatter( loc_e , par_e );
        ylim(prctile(par_e, [2,98]));
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
% These plots support my assesment above - the super-high density of low
% error peaks 
clf;
for param_idx = 1:length(pa_param_names)
    for start_pt_idx = 1:2
        subplot(4,2,(param_idx-1)*2 + start_pt_idx);
        loc_e = [loc_param_errs(:,param_idx, start_pt_idx).peak_loc_error];
        par_e = [loc_param_errs(:,param_idx, start_pt_idx).param_error];
        occupancy_2d_plot( loc_e , par_e, 256, 32, 32, [0,max(loc_e), 0, prctile(par_e, 98)]);
        title_tmp = sprintf('%s: %s',pa_param_names{param_idx}, ...
            starting_pt_names{start_pt_idx});
        title(capitalize(title_tmp));
        xlabel('Error in initial location');
        ylabel(['Error in ', capitalize(pa_param_names{param_idx})]);
        hold on;
        ylim();
    end
end

%% How robust is each starting point to location errors (scatter plot - by congenstion)?
% Here, I again plot the the noisy gold standard data: initial location
% error versus final difference for that peak parameter
%
% This time, I plot one set of scatter plots for each of the 10 congestions
%
% Without aligned errors, these plots don't reveal any interesting patterns - except that it seems
% that beyond a certain limit initial distance doesn't seem to matter much
% and that that distance seems to grow with the congestion.
for congestion_idx = 2:4:10
    figure(congestion_idx); clf; maximize_figure(congestion_idx,2);
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
            ylim([0, prctile(par_e, 98)]);
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
% The scatter plots seem to get tighter when you divide by peak width, but
% they still look weighted toward the lower peak error. Also the linear
% structures visible in the anderson errors for location vanish.
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
        ylim(prctile(par_e, [2,98]));
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
% error versus final difference for that peak parameter. I look ar rhw
%
% I display the region that was the lowest 20% or the all-congenstions
% error region (for easy comparison).
%
% This time, I sort by location error and divide the data up into bins
% containing equal numbers of samples. I plot the mean location error
% versus the mean parameter error for each parameter. The location errors
% are width scaled. 
%
samples_per_bin = 40;
for congestion_idx = [3:3:10,10]
    figure(congestion_idx); clf; maximize_figure(congestion_idx, 2);
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
            %xlim([0,8]);
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
% noisier.
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