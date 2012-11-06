%% Load diluted spectra
[diluted_spectra, real_dilution_factors]=loadDilutedSpectra;

%% Put first 5 diluted spectra in ds
second_5=diluted_spectra{2};

%% Generate reference spectrum (ignoring most of the metadata)
ref=median(second_5.Y,2); %Take median of each row

%% Note min_y and max_y - they are -0.713581050990660 and 7.497300177964634e+02 respectively
min_y = min(ref);
max_y = max(ref);

%% Eliminate noise points (5 std) from reference spectrum - use first 30 pts as noise
ref_denoise=ref(ref > 5*std(ref(1:30)));

%% Eliminate noise points from the main spectra
stds=std(first_5.Y(1:30,:));
is_signal = first_5.Y > repmat(5*stds,size(first_5.Y,1),1);
ds=cell(5,1); %ds is denoised diluted spectra
for i=1:5
    ds{i}=first_5.Y(is_signal(:,i),i);
end
clear('i','is_signal','stds');

%% Note min and max y when no noise: 0.753038694822829 and 1.516414163764348e+03 - note that max is unchanged
clear('min_y','max_y');
min_y_no_noise = min(ref_denoise);
max_y_no_noise = max(ref_denoise);

%% Generate bin boundaries for log distribution (10 bins)
min_z = min(log(ref_denoise+1));
max_z = max(log(ref_denoise+1));
zbins=linspace(min_z, max_z, 11);
log_bins = exp(zbins)-1;
clear('zbins','min_z','max_z');

%% Generate bin boundaries for equi-distribution (10 bins)
sorted_ref=sort(ref_denoise);
equi_bins = zeros(1,11);
equi_bins(1)=sorted_ref(1);
equi_bins(11)=sorted_ref(end);
assert(length(sorted_ref)==6412);
bin_last_elements=[642,... 642 in first bin, so 642 is last element of first bin
    1284, ... 642 in second bin, so last element of second bin is 642+642=1284
    1284+641,... 641 in every other bin
    1284+2*641, 1284+3*641, 1284+4*641, 1284+5*641, 1284+6*641, ...
    1284+7*641, 1284+8*641];
bin_first_elements=[1,bin_last_elements(1:9)+1];
inner_bin_boundaries=(sorted_ref(bin_first_elements(2:end))+...
    sorted_ref(bin_last_elements(1:end-1)))/2;
equi_bins(2:10)=inner_bin_boundaries;
clear('inner_bin_boundaries','bin_first_elements','bin_last_elements','sorted_ref');

%% Note original search bounds for each spectrum - lower bounds were [3.275050410521820e-04,4.509839217431247e-04,4.965917048370774e-04,0.001282969179976,0.001027549984853] and upper bounds: [1.340740072772356e+03,1.699648066791515e+03,1.772289803537955e+03,3.438209518954707e+03,2.308977384106270e+03]
orig_min=cellfun(@(x) min(x),ds)';
orig_max=cellfun(@(x) max(x),ds)';
potential_extreme_multipliers=[min_y_no_noise./orig_min; ...
    max_y_no_noise./orig_min; min_y_no_noise./orig_max; ...
    max_y_no_noise./orig_max];
potential_extreme_multipliers = sort(potential_extreme_multipliers);
orig_lb=min(potential_extreme_multipliers);
orig_ub=max(potential_extreme_multipliers);

%% Note greatest integer power of 2 multiple of lower bound which is still less than upper bound - it is 21 for all of them
multiples = floor(log(orig_ub./orig_lb)/log(2));
assert(all(multiples==21)); % a little check for next time

%% Create an array of potential multipliers
max_multiple = max(multiples);
potential_multipliers=repmat(orig_lb, max_multiple+2, 1);
upper_bound_multipliers = repmat(orig_ub, max_multiple+2, 1);
powers_of_two=2.^((0:max_multiple+1)');
powers_of_two=repmat(powers_of_two,1,length(orig_lb));
potential_multipliers=potential_multipliers.*powers_of_two;
out_of_bounds=potential_multipliers > upper_bound_multipliers;
potential_multipliers(out_of_bounds)=upper_bound_multipliers(out_of_bounds);
clear('out_of_bounds','powers_of_two','upper_bound_multipliers','max_multiple');

%% Create counts for the binned reference spectrum
ref_log_binned = histc_inclusive(ref_denoise, log_bins);
ref_equi_binned = histc_inclusive(ref_denoise, equi_bins);

%% Create an array of errors for each multiplier using the log bins
log_error_for_multiplier = zeros(size(potential_multipliers));
equi_error_for_multiplier = log_error_for_multiplier;
for spec_idx = 1:5
    vals = ds{spec_idx};
    mults = potential_multipliers(:,spec_idx);
    log_error_for_multiplier(:, spec_idx) = arrayfun(...
        @(mult) multiplierErr(vals, mult, log_bins, ref_log_binned), ...
        mults);
    equi_error_for_multiplier(:, spec_idx) = arrayfun(...
        @(mult) multiplierErr(vals, mult, equi_bins, ref_equi_binned), ...
        mults);
end

%% The indices of minimum error for equi_bin are (by inspection) [12, 12, 12, 11, 11]
equi_bin_min_index = [12,12,12,11,11];

%% The indices of minimum error for log_bin are (by inspection) [12, 12, 12, 11, 11]
log_bin_min_index = [12,12,12,11,11];

%% The new equi_bin lower bounds are: [0.335365162037434,0.461807535864960,0.508509905753167,0.656880220147673,0.526105592244654]
for spec_idx = 1:5
    equi_bin_new_lb(spec_idx) = potential_multipliers(equi_bin_min_index(spec_idx)-1,spec_idx);
end

%% The new log_bin lower bounds are: [0.335365162037434,0.461807535864960,0.508509905753167,0.656880220147673,0.526105592244654]
for spec_idx = 1:5
    log_bin_new_lb(spec_idx) = potential_multipliers(log_bin_min_index(spec_idx)-1,spec_idx);
end

%% The new equi_bin upper bounds are: [1.341460648149738,1.847230143459839,2.034039623012669,2.627520880590694,2.104422368978614]
for spec_idx = 1:5
    equi_bin_new_ub(spec_idx) = potential_multipliers(equi_bin_min_index(spec_idx)+1,spec_idx);
end

%% The new log_bin upper bounds are: [1.341460648149738,1.847230143459839,2.034039623012669,2.627520880590694,2.104422368978614]
for spec_idx = 1:5
    log_bin_new_ub(spec_idx) = potential_multipliers(log_bin_min_index(spec_idx)+1,spec_idx);
end

%% Note that this procedure always makes the new lower bound half the value of multiplier that gave the minimum and the new upper bound twice its value (truncated to the original range, of course). I can use this fact to optimize the original code after I finish writing the test case

%% Now do exhaustive search accumulating the errors for the first spectrum (just to see what the curve looks like)

%% First make bin boundaries and binnings treating the second spectrum as the reference spectrum
second_spectrum = ds{2};
min_second= min(second_spectrum);
max_second = max(second_spectrum);

%% Generate bin boundaries for second log distribution (10 bins)
min_z = min(log(second_spectrum+1));
max_z = max(log(second_spectrum+1));
zbins=linspace(min_z, max_z, 11);
second_log_bins = exp(zbins)-1;
clear('zbins','min_z','max_z');
second_binned_log = histc_inclusive(second_spectrum, second_log_bins);

%% Generate bin boundaries for second equi-distribution (10 bins)
sorted_second=sort(second_spectrum);
second_equi_bins = zeros(1,11);
second_equi_bins(1)=sorted_second(1);
second_equi_bins(11)=sorted_second(end);
assert(length(sorted_second)==5777); % 7 bins of 578 and 3 of 577
bin_last_elements=[578,... 578 in first bin, so 578 is last element of first bin
    578*2, ... 578 in second bin, so last element of second bin is 578*2
    578*3, 578*4, 578*5, 578*6, 578*7, 578*7+577*1, 578*7+577*2, 578*7+577*3];
bin_first_elements=[1,bin_last_elements(1:9)+1];
inner_bin_boundaries=(sorted_second(bin_first_elements(2:end))+...
    sorted_second(bin_last_elements(1:end-1)))/2;
second_equi_bins(2:10)=inner_bin_boundaries;
clear('inner_bin_boundaries','bin_first_elements','bin_last_elements','sorted_second');
second_binned_equi = histc_inclusive(second_spectrum, second_equi_bins);

%% Now do the exhaustive search

% First make a list of the multipliers to make each value go to each bin
% boundary
values=ds{1};
exhaustive_multipliers=zeros(length(log_bins)-1, length(values));
for bin_edge_idx = 1:length(log_bins)-1
    exhaustive_multipliers(bin_edge_idx, :) = log_bins(bin_edge_idx)./values;
end
clear('bin_edge_idx');

% Now, sort the multipliers and set up space for the error storage
exhaustive_multipliers = reshape(exhaustive_multipliers,[],1);
exhaustive_multipliers = sort(exhaustive_multipliers);
exhaustive_multiplier_error_log = zeros(size(exhaustive_multipliers));
exhaustive_multiplier_error_equi = zeros(size(exhaustive_multipliers));
num_mults = length(exhaustive_multipliers);

%% Now calculate one error value for each multiplier
progress_bar=waitbar(0,sprintf('Calcd mult %d/%d %g secs remaining',0,num_mults,0));
start_time=now;
for mult_idx = 1:num_mults
    mult = exhaustive_multipliers(mult_idx);
    exhaustive_multiplier_error_log(mult_idx) = multiplierErr(values, mult, second_log_bins, second_binned_log); 
    exhaustive_multiplier_error_equi(mult_idx) = multiplierErr(values, mult, second_equi_bins, second_binned_equi);
    if mod(mult_idx, 1000)==0
        elapsed_days = now - start_time;
        elapsed_seconds = 60*60*24*elapsed_days;
        fraction_completed = (mult_idx-1)/num_mults;
        seconds_remaining = elapsed_seconds*(1-fraction_completed)/fraction_completed;
        waitbar(fraction_completed,progress_bar,sprintf(...
            'Calcd mult %d/%d %g secs remaining',...
            mult_idx, num_mults, seconds_remaining));
    end
end
delete(progress_bar);
best_multiplier_log_fminbnd = fminbnd(@(mult) multiplierErr(values, mult, second_log_bins, second_binned_log), 1/10,10);
best_multiplier_equi_fminbnd = fminbnd(@(mult) multiplierErr(values, mult, second_equi_bins, second_binned_equi), 1/10,10);

clear('progress_bar', 'num_mults', 'mult_idx', 'mult', 'elapsed_days', 'elapsed_seconds', 'fraction_completed', 'seconds_remaining');

%% Calculate sum normalization ratio
sum_1=sum(first_5.Y(:,1));
sum_2=sum(first_5.Y(:,2));
sum_n_ratio=sum_2/sum_1;

%% Plot the resulting curves with the true dilution factor
true_multiplier = real_dilution_factors{1};
true_multiplier = true_multiplier(1)/true_multiplier(2);
figure(1);

figure_min = min([exhaustive_multiplier_error_equi; exhaustive_multiplier_error_log]);
figure_max = max([exhaustive_multiplier_error_equi; exhaustive_multiplier_error_log]);

[~,best_multiplier_idx_log] = min(exhaustive_multiplier_error_log);
best_multiplier_log = exhaustive_multipliers(best_multiplier_idx_log);
[~,best_multiplier_idx_equi] = min(exhaustive_multiplier_error_equi);
best_multiplier_equi = exhaustive_multipliers(best_multiplier_idx_equi);

curve_handles=semilogx(exhaustive_multipliers, exhaustive_multiplier_error_log, 'b', exhaustive_multipliers, exhaustive_multiplier_error_equi, 'g');
title('Comparison of equi and log binned error for exhaustive multiplier search');
ylabel('Squared error from second distribution');
xlabel('Multiplier');
hold('on');
line([best_multiplier_log, best_multiplier_log], [figure_min, figure_max], 'Color','b');
line([best_multiplier_equi, best_multiplier_equi], [figure_min, figure_max], 'Color','g');
curve_handles(3)=line([true_multiplier, true_multiplier],[figure_min, figure_max], 'Color', 'r');
curve_handles(4)=line([sum_n_ratio, sum_n_ratio],[figure_min, figure_max], 'Color', 'k');

legend(curve_handles,'log binned error','equi binned error','actual ratio', 'sum normalization ratio');
%line([best_multiplier_log_fminbnd, best_multiplier_log_fminbnd],[figure_min, figure_max], 'Color', 'm');
%line([best_multiplier_equi_fminbnd, best_multiplier_equi_fminbnd],[figure_min, figure_max], 'Color', 'k');
hold('off');
