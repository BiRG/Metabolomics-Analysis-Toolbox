function adaptive_intelligent_bin_helper
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

prompt={'R:'};
name='Adaptive intelligent binning arguments';
numlines=1;
defaultanswer={'0.25'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
R = str2num(answer{1});

[x,Y,labels] = combine_collections(collections);
[bins,stats] = adaptive_intelligent_bin(x,Y,R,left_noise,right_noise);

regions_cursors = [];
nm = size(bins);
ylim = get(gca,'ylim');
for i = 1:nm(1)
    regions_cursors(i,1) = line([bins(i,1),bins(i,1)],ylim,'Color','g');
    regions_cursors(i,2) = line([bins(i,2),bins(i,2)],ylim,'Color','r');
end

setappdata(gcf,'regions_cursors',regions_cursors);
setappdata(gcf,'region_inx',1); % Reset
