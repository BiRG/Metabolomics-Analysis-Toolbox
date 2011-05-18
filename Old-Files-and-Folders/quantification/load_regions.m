function load_regions
collections = getappdata(gcf,'collections');
c = 1;
s = 1;
Y = collections{c}.Y;
x = collections{c}.x;

[filename,pathname] = uigetfile('*.txt', 'Load regions');
file = fopen([pathname,filename],'r');
myline = fgetl(file);
regions = split(myline,';');
lefts = [];
rights = [];
for i = 1:length(regions)
    region = regions{i};
    fields = split(region,',');
    lefts(end+1) = str2num(fields{1});
    rights(end+1) = str2num(fields{2});
end
regions = zeros(length(lefts),2);
regions(:,1) = lefts';
regions(:,2) = rights';

clear_plot
regions_cursors = zeros(length(lefts),2);
for i = 1:length(lefts)
    regions_cursors(i,1) = line([regions(i,1),regions(i,1)],[min(Y(:,s)),max(Y(:,s))],'Color','g');
    regions_cursors(i,2) = line([regions(i,2),regions(i,2)],[min(Y(:,s)),max(Y(:,s))],'Color','r');
    setappdata(gcf,'regions_cursors',regions_cursors);
    [region_inx,left,right,left_handle,right_handle] = get_region(i);
    myfunc = @(hObject, eventdata, handles) (region_click_menu(left_handle));
    menu = uicontextmenu('Callback',myfunc);
    set(left_handle,'UIContextMenu',menu);
    myfunc = @(hObject, eventdata, handles) (region_click_menu(right_handle));
    menu = uicontextmenu('Callback',myfunc);
    set(right_handle,'UIContextMenu',menu);
end

setappdata(gcf,'regions_cursors',regions_cursors);

% Get binning methods
myline = fgetl(file);
if myline ~= -1
    binning_methods = split(myline,';');
    [regions,left_handles,right_handles] = get_regions;
    for i = 1:length(left_handles)
        info = {};
        info.binning_method = binning_methods{i};
        if strcmp(info.binning_method,'adj')
            info.active_adj = true;
        end
        setappdata(left_handles(i),'info',info);
    end
end

plot_all