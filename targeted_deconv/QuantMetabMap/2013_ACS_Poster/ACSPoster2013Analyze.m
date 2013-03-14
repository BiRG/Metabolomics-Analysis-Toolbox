% Prints a summary of the analysis of the results from experiments of March 7 2013 originally used to verify that a bug was no longer present.

%% Set up path - add previous directory if can't find the GLBIO analysis routines
if ~exist('GLBIO2013_plot_peaks_and_starting_point','file')
    addpath([pwd,'/..']);
end

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

screen_size = get(0,'Screensize');
set(gcf, 'Position', [screen_size(1:2),screen_size(3)/2, screen_size(4)]); % Maximize figure in a dual monitor unix environment - which will be a half-width, full height window in a single monitor environment.

%% Load the combined results
load('Mar_07_2013_experiment_without_local_max.mat');

%% Defend spectrum width choices
% The spectral widths chosen give better than 99% probabilities that the
% probabilities of being free of peak merging are within 0.4% of the target
% probability.
GLBIO2013_print_prob_counts_in_range_table(0.004);

%% Calculate the parameters
pe_list = GLBIO2013_calc_param_error_list(Mar_07_2013_experiment_without_local_max);

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
picker_legend = {'Gold Standard','Noisy Gold Standard'};
picker_formats = {'r+-','bd-'};
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


%% Plot anderson error versus summit error for each parameter and collision probability
% Now we break up the results into one graph for each parameter,
% collision probability, and picker. We plot both a scatter plot and a
% a density map. This gives information about the joint distribution of the
% errors.
%
num_charts = length(param_names)*length(peak_pickers)*3;
collision_prob_indices = [1,round(length(collision_probs)/2),length(collision_probs)];
num_horiz_charts = 6; % Number of charts horizontally in the figure
num_vert_charts = ceil(num_charts/6); %Number of charts vertically in the figure

% The labeling assumes two peak-pickers and 3 collision prob indices so
% each row contains 6 entries all for the same parameter
assert(length(peak_pickers) == 2); 
assert(length(collision_prob_indices) == 3);
assert(num_horiz_charts == 6); 

for plot_type_idx = 1:2
    is_density_plot = plot_type_idx == 1;
    figure;
    screen_size = get(0,'Screensize');
    set(gcf, 'Position', [screen_size(1:2),screen_size(3)/2, screen_size(4)]); % Maximize figure in a dual monitor unix environment - which will be a half-width, full height window in a single monitor environment.
    plot_num = 0;
    for param_idx = 1:length(param_names)
        pe_has_param = strcmp({pe_list.parameter_name},param_names{param_idx});
        pes_with_param = pe_list(pe_has_param);
        andersons_in_row = [pes_with_param.mean_error_anderson];
        summits_in_row = [pes_with_param.mean_error_summit];
        anderson_limits = [0, max([andersons_in_row,summits_in_row])];
        for picker_idx = 1:length(peak_pickers)
            pe_has_picker = strcmp({pe_list.peak_picking_name},peak_pickers{picker_idx});
            ci_half_width_95_pct = std_dev_error_for_prob;
            for prob_idx_idx = 1:length(collision_prob_indices)
                prob_idx = collision_prob_indices(prob_idx_idx);

                plot_num = plot_num + 1;
                subplot(num_vert_charts, num_horiz_charts, plot_num);

                pe_has_prob = [pe_list.collision_prob] == collision_probs(prob_idx);
                selected_pes = pe_list(pe_has_prob & pe_has_picker & pe_has_param);
                selected_andersons = [selected_pes.mean_error_anderson]; 
                selected_summits = [selected_pes.mean_error_summit]; 

                plot_limits = [min([0,selected_andersons, selected_summits]), max([selected_andersons, selected_summits])];

                if is_density_plot
                    occupancy_2d_plot(selected_summits, selected_andersons, 256, 20, 20, [plot_limits, plot_limits]);
                else
                    scatter(selected_summits, selected_andersons);
                    xlim(plot_limits);
                    ylim(plot_limits);
                end

                title(sprintf('Errors in %s\nusing %s\nin density %3.1f', ...
                    param_names{param_idx}, picker_legend{picker_idx}, ...
                    collision_probs(prob_idx)));

                if  mod(plot_num, num_horiz_charts) == 1 
                    ylabel('Anderson Error');
                end
                if plot_num >= num_charts - num_horiz_charts
                    xlabel('Summit Error');
                end

            end
        end
    end
end

%% Plot histograms of the anderson and summit errors
% Using the same break-up as before, we now plot histograms of the marginal
% errors for each type of starting point: anderson and summit. This will
% let us see how badly they deviate from being normally distributed.
%
num_charts = length(param_names)*length(peak_pickers)*3;
collision_prob_indices = [1,round(length(collision_probs)/2),length(collision_probs)];
num_horiz_charts = 6; % Number of charts horizontally in the figure
num_vert_charts = ceil(num_charts/6); %Number of charts vertically in the figure

% The labeling assumes two peak-pickers and 3 collision prob indices so
% each row contains 6 entries all for the same parameter
assert(length(peak_pickers) == 2); 
assert(length(collision_prob_indices) == 3);
assert(num_horiz_charts == 6); 

for plot_type_idx = 1:2
    is_anderson_plot = plot_type_idx == 1;
    figure;
    screen_size = get(0,'Screensize');
    set(gcf, 'Position', [screen_size(1:2),screen_size(3)/2, screen_size(4)]); % Maximize figure in a dual monitor unix environment - which will be a half-width, full height window in a single monitor environment.
    plot_num = 0;
    for param_idx = 1:length(param_names)
        pe_has_param = strcmp({pe_list.parameter_name},param_names{param_idx});
        pes_with_param = pe_list(pe_has_param);
        andersons_in_row = [pes_with_param.mean_error_anderson];
        summits_in_row = [pes_with_param.mean_error_summit];
        anderson_limits = [0, max([andersons_in_row,summits_in_row])];
        for picker_idx = 1:length(peak_pickers)
            pe_has_picker = strcmp({pe_list.peak_picking_name},peak_pickers{picker_idx});
            ci_half_width_95_pct = std_dev_error_for_prob;
            for prob_idx_idx = 1:length(collision_prob_indices)
                prob_idx = collision_prob_indices(prob_idx_idx);

                plot_num = plot_num + 1;
                subplot(num_vert_charts, num_horiz_charts, plot_num);

                pe_has_prob = [pe_list.collision_prob] == collision_probs(prob_idx);
                selected_pes = pe_list(pe_has_prob & pe_has_picker & pe_has_param);
                selected_andersons = [selected_pes.mean_error_anderson]; 
                selected_summits = [selected_pes.mean_error_summit]; 

                plot_limits = [min([0,selected_andersons, selected_summits]), max([selected_andersons, selected_summits])];

                num_bins = 20;
                if is_anderson_plot
                    hist(selected_andersons, num_bins);
                    xlabel('Anderson Error');
                else
                    hist(selected_summits, num_bins);
                    xlabel('Summit Error');
                end

                title(sprintf('Errors in %s\nusing %s\nin density %3.1f', ...
                    param_names{param_idx}, picker_legend{picker_idx}, ...
                    collision_probs(prob_idx)));

            end
        end
    end
end


%% How robust is each algorithm to location errors?
% Here, I look at each peak in the noisy gold standard data, the
% distance of that peak from its corresponding initial peak, and the
% distance of the corresponding deconvolved peak parameters from the true
% values.
%
% I then plot for each peak parameter, a scatter plot of initial location
% error versus final difference for that peak parameter (ignoring the
% crowdedness of the bin)
%
% This is commented out because I couldn't get it to work within a
% reasonable time-frame

% loc_param_errs = GLBIO2013_peak_loc_vs_param_errs(Mar_07_2013_experiment_without_local_max);
% clf;
% for param_idx = 1:length(param_names)
%     subplot(2,2,param_idx);
%     title_tmp = param_names{param_idx};
%     title([upper(title_tmp(1)),title_tmp(2:end)]);
%     xlabel('Error in initial location');
%     ylabel(['Error in ', title_tmp]);
%     hold on;
%     try
%     anderson_h = scatter([loc_param_errs(:,param_idx, 1).peak_loc_error], ...
%         [loc_param_errs(:,param_idx, 1).param_error]);
%     summit_h = scatter([loc_param_errs(:,param_idx, 2).peak_loc_error], ...
%         [loc_param_errs(:,param_idx, 2).param_error]);
%     catch ME
%         %TODO: the try catch block is DEBUG code
%         fprintf('HERE:%s\n',ME.message); throw(ME);
%     end    
% end

%% Calculate the relative parameter errors
pe_rel_list = GLBIO2013_calc_param_rel_error_list(Mar_07_2013_experiment_without_local_max);

%% Precalculate some values needed for plotting relative errors by parameter
% On my home computer the large "unique" statements take a lot of time to
% compute, so I've moved them to a separate cell so they only have to be
% calculated once.
param_names = unique({pe_rel_list.parameter_name});
assert(length(param_names) == 5,'Right number of param names');
peak_pickers = unique({pe_rel_list.peak_picking_name});
picker_legend = {'Gold Standard','Noisy Gold Standard'};
picker_formats = {'r+-','bd-'};
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

