function [bins,stats,spectra] = dynamic_adaptive_bin(x,Y,left_noise,right_noise,max_dist_btw_maxs_ppm,min_dist_from_boundary_ppm,percentile,multiplet_R2_cutoff,max_dist_btw_multiplet_peaks)
global nSpectra
nm = size(Y);
num_samples = nm(2);
if num_samples < 1
    bins = [];
    stats = {};
    return;
end
nSpectra = num_samples;

main_h = gcf;
h = options;
all_options = get_options(h);
set(h,'Visible','off');
figure(main_h);
spectra = create_spectra(x,Y,left_noise,right_noise,all_options,percentile);

max_spectrum = Y(:,1)';
for s = 1:num_samples
    if s > 1
        max_spectrum = max([max_spectrum;Y(:,s)']);
    end
end

xwidth = abs(x(1)-x(2));
max_dist_btw_maxs = round(max_dist_btw_maxs_ppm/xwidth);
min_dist_from_boundary = round(min_dist_from_boundary_ppm/xwidth);

nm = size(Y);
if nm(2) == 1 % Only 1 sample
    y_sum = Y';
else
    y_sum = sum(abs(Y'));    
end
nonzero_inxs = find(y_sum ~= 0);
i = 1;
all_inxs = {};
while i <= length(nonzero_inxs)
    inxs = [];
    new_inxs = nonzero_inxs(i);
    while (length(new_inxs)-length(inxs)) == 1
        inxs = new_inxs;
        i = i + 1;
        if i > length(nonzero_inxs)
            break;
        end
        new_inxs = inxs(1):nonzero_inxs(i);
    end
    if ~isempty(inxs)
        all_inxs{end+1} = inxs;
    end
end

bins = [];
total_score = 0;
for i = 1:length(all_inxs)
    inxs = all_inxs{i};
    for s = 1:num_samples
        tinxs = find(inxs(1) <= spectra{s}.all_maxs & spectra{s}.all_maxs <= inxs(end));
        spectra{s}.maxs = spectra{s}.all_maxs(tinxs);
        spectra{s}.mins = spectra{s}.all_mins(tinxs,:);
    end
    [tbins,stats,score] = perform_heuristic_bin_dynamic(x,max_spectrum,spectra,max_dist_btw_maxs,min_dist_from_boundary,multiplet_R2_cutoff,max_dist_btw_multiplet_peaks);
    total_score = total_score + score;
    if tbins(1,1) > x(inxs(1))
        tbins(1,1) = x(inxs(1));
    end
    if tbins(end,2) < x(inxs(end))
        tbins(end,2) = x(inxs(end));
    end
    bins = [bins;tbins];
end

%bins = [10,8;8,7;6,5];
%stats = {};

fprintf('# bins: %d\n',length(bins));
fprintf('Total score: %f\n',total_score/length(bins));