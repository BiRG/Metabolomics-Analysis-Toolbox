%% Load diluted spectra
[diluted_spectra, real_dilution_factors]=loadDilutedSpectra;

%% Put first 5 diluted spectra in ds
first_5=diluted_spectra{1};

%% Generate reference spectrum (ignoring most of the metadata)
ref=median(first_5.Y,2); %Take median of each row

%% Note min_y and max_y - they are -1.237992488132203 and 1.516414163764348e+03 respectively
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

%% Note original search bounds for each spectrum - lower bounds were [4.918967333140244e-04;5.343214309518081e-04;5.642418062800664e-04;7.514228970822125e-04;8.961564136557860e-04] and upper bounds [2.032947023784370e+03;1.871532643223125e+03;1.772289803537955e+03;1.330808528570285e+03;1.115876631313270e+03]
orig_min=cellfun(@(x) min(x),ds)';
orig_max=cellfun(@(x) max(x),ds)';
potential_extreme_multipliers=[min_y_no_noise./orig_min; ...
    max_y_no_noise./orig_min; min_y_no_noise./orig_max; ...
    max_y_no_noise./orig_max];
potential_extreme_multipliers = sort(potential_extreme_multipliers);
orig_lb=min(potential_extreme_multipliers);
orig_ub=max(potential_extreme_multipliers);

