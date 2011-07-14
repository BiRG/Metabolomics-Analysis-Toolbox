left_noise_cursor = getappdata(gcf,'left_noise_cursor');
right_noise_cursor = getappdata(gcf,'right_noise_cursor');
if isempty(left_noise_cursor) || isempty(right_noise_cursor)
    msgbox('Set the noise cursors');
    return
end
left_noise = GetCursorLocation(left_noise_cursor);
right_noise = GetCursorLocation(right_noise_cursor);
if right_noise > left_noise
    t = left_noise;
    left_noise = right_noise;
    right_noise = t;
end
collections = getappdata(gcf,'collections');
if isempty(collections)
    msgbox('Load one or more collections');
    return
end

max_dist_btw_maxs_ppm = 0.04;
min_dist_from_boundary_ppm = 0.001;

[x,Y,labels] = combine_collections(collections);
[bins,stats,spectra] = dynamic_adaptive_bin(x,Y,left_noise,right_noise,max_dist_btw_maxs_ppm,min_dist_from_boundary_ppm);
i = 1;
for c = 1:length(collections)
    collections{c}.spectra_maxs = {};
    for s = 1:collections{c}.num_samples
        spectrum = spectra{i};
        spectrum = rmfield(spectrum,'mins');
        spectrum = rmfield(spectrum,'maxs');
        spectrum.xmaxs = x(spectrum.all_maxs);
        spectrum.xmins = x(spectrum.all_mins);
        spectrum = rmfield(spectrum,'all_mins');
        spectrum = rmfield(spectrum,'all_maxs');
        collections{c}.spectra{s} = spectrum;
        i = i + 1;
    end
end

setappdata(gcf,'collections',collections);