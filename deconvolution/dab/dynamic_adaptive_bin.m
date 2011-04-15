function bins = dynamic_adaptive_bin(collection,max_dist_btw_maxs_ppm,min_dist_from_boundary_ppm)
x = collection.x;
Y = collection.Y;
nm = size(Y);
num_samples = nm(2);
if num_samples < 1
    bins = [];
    return;
end

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
    maxs = {};
    for s = 1:num_samples
        tinxs = find(inxs(1) <= collection.maxs{s} & collection.maxs{s} <= inxs(end));
        maxs{s} = collection.maxs{s}(tinxs);
    end
    tbins = perform_heuristic_bin_dynamic(x,max_spectrum,maxs,max_dist_btw_maxs,min_dist_from_boundary);
    if ~isempty(tbins)
        if tbins(1,1) > x(inxs(1))
            tbins(1,1) = x(inxs(1));
        end
        if tbins(end,2) < x(inxs(end))
            tbins(end,2) = x(inxs(end));
        end
        bins = [bins;tbins];
    end
end