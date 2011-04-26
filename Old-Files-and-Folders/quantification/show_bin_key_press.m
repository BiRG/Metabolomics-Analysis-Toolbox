function show_bin_key_press(region_inx)
k = get(gcf,'CurrentKey');

if strcmp(k,'rightarrow')
    clf
    show_bin(region_inx+1);
elseif strcmp(k,'leftarrow')
    clf
    show_bin(region_inx-1);
end