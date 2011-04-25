function dynamic_adaptive_bin_helper
clear_regions_cursors
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

prompt={'Enter the maximum distance between peaks in a single bin:',...
    'Enter minimum distance from peak to nearest boundary:','Percentile:',...
    'Multiplet R2 cutoff:','Enter the maximum distance between peaks in multiplet:'};
name='Dynamic adaptive binning arguments';
numlines=1;
defaultanswer={'0.1','0.001','100','0.7','0.02'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
max_dist_btw_maxs_ppm = str2num(answer{1});
min_dist_from_boundary_ppm = str2num(answer{2});
percentile = str2num(answer{3});
multiplet_R2_cutoff = str2num(answer{4});
max_dist_btw_multiplet_peaks = str2num(answer{5});

[x,Y,labels] = combine_collections(collections);
[bins,stats,spectra] = dynamic_adaptive_bin(x,Y,left_noise,right_noise,max_dist_btw_maxs_ppm,min_dist_from_boundary_ppm,percentile,multiplet_R2_cutoff,max_dist_btw_multiplet_peaks);
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

regions_cursors = [];
nm = size(bins);
ylim = get(gca,'ylim');
for i = 1:nm(1)
    regions_cursors(i,1) = line([bins(i,1),bins(i,1)],ylim,'Color','g');
    regions_cursors(i,2) = line([bins(i,2),bins(i,2)],ylim,'Color','r');
    setappdata(gcf,'regions_cursors',regions_cursors);
    [region_inx,left,right,left_handle,right_handle] = get_region(i);
    callback = @(hObject, eventdata, handles) (region_click_menu(left_handle));
    menu = uicontextmenu('Callback',callback);
    set(left_handle,'UIContextMenu',menu);
    callback = @(hObject, eventdata, handles) (region_click_menu(right_handle));
    menu = uicontextmenu('Callback',callback);
    set(right_handle,'UIContextMenu',menu);
end

setappdata(gcf,'regions_cursors',regions_cursors);
setappdata(gcf,'region_inx',1); % Reset
setappdata(gcf,'collections',collections);
