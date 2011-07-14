function uniform_bin_helper
clear_regions_cursors
collections = getappdata(gcf,'collections');
if isempty(collections)
    msgbox('Load one or more collections');
    return
end

prompt={'Enter the width:'};
name='Uniform binning arguments';
numlines=1;
defaultanswer={'0.04'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
width = str2num(answer{1});

[x,Y,labels] = combine_collections(collections);
[bins,stats] = uniform_bin(x,Y,width);

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
