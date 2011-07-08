function bins = perform_heuristic_bin_dynamic(x,max_spectrum,maxs,max_dist_btw_maxs,min_dist_from_boundary)

%% Grab the unique maxs
ht = java.util.Hashtable();
unique_maxs = [];
for s = 1:length(maxs)
    for i = 1:length(maxs{s})
        if ~ht.containsKey(maxs{s}(i))
            ht.put(maxs{s}(i),maxs{s}(i));
            unique_maxs(end+1) = maxs{s}(i);
        end
    end
end
unique_maxs = sort(unique_maxs,'ascend');

%% Assign each maximum to an index. This is important for future
% calculations
maxs_spectra = cell(1,length(x)); % All of the spectra that have a max at unique_maxs
for s = 1:length(maxs)
    for i = 1:length(maxs{s})
        ix = ht.get(maxs{s}(i));
        maxs_spectra{ix}(end+1) = s;
    end
end

%% Group maxs together that are less than min_dist_btw_maxs apart
grouped_maxs = [];
i = 1;
while i <= length(unique_maxs)
    grouped_maxs(end+1,:) = [unique_maxs(i),unique_maxs(i)];
    j = i+1;
    while j <= length(unique_maxs) && abs(grouped_maxs(end,2)-unique_maxs(j)) < 2*min_dist_from_boundary
        grouped_maxs(end,2) = unique_maxs(j);
        j = j + 1;
    end
    i = j;
end

nSpectra = length(maxs);
bins_inxs = optimize_bins(grouped_maxs,max_dist_btw_maxs,maxs_spectra,nSpectra);
bins = finalize_bins(x,max_spectrum,bins_inxs,max_dist_btw_maxs,min_dist_from_boundary,maxs_spectra);

function R2 = calc_R2(y1,y2)
SSreg = sum((y1-y2).^2);
SStot = sum((y2 - mean(y2)).^2);
R2 = 1 - SSreg/SStot;