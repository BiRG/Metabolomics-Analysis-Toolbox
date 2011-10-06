function sorted=sort_metabmap(metab_map)
% Returns the metab_map sorted alphabetically by compound name then by
% left bin boundary ppm.  metab_map is an array of CompoundBin objects.
if isempty(metab_map) 
    sorted = metab_map;
    return;
end
bins = [metab_map.bin];
lefts = [bins.left];
[unused,indexes] = sort(lefts, 'descend'); %#ok<ASGLU>
sorted = metab_map(indexes);
names = lower({sorted.compound_name});
[unused, indexes] = sort(names); %#ok<ASGLU>
sorted = sorted(indexes);