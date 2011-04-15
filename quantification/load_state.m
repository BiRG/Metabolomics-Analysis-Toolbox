function collection = load_state
[filename, pathname] = uigetfile( ...
       {'*.mat', 'MATLAB files (*.mat))'}, ...
        'Load a collection state file');
if filename == 0
    collection = [];
    return
end

old_regions = get_regions;
load([pathname,filename]); % 'bin_data','regions'
if ~isempty(old_regions)
    if sum(sum(abs(old_regions - regions))) > 0
        msgbox('Error loading state. Incompatible regions');
        collection = [];
        return
    end
end

clear_plot
if isempty(old_regions)
    Y = collection.Y;
    nm = size(regions);
    regions_cursors = zeros(nm(1),2);
    for i = 1:nm(1)
        regions_cursors(i,1) = line([regions(i,1),regions(i,1)],[min(Y(:,1)),max(Y(:,1))],'Color','g');
        regions_cursors(i,2) = line([regions(i,2),regions(i,2)],[min(Y(:,1)),max(Y(:,1))],'Color','r');
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
end

[regions,left_handles,right_handles] = get_regions;
for i = 1:length(left_handles)
    adj_saved_data = getappdata(left_handles(i),'adj_saved_data');
    if isempty(adj_saved_data)
        adj_saved_data = {};
    end
    adj_saved_data{end+1} = bin_data{i}.adj_saved_data;
    setappdata(left_handles(i),'adj_saved_data',adj_saved_data);

    smart_saved_data = getappdata(left_handles(i),'smart_saved_data');
    if isempty(smart_saved_data)
        smart_saved_data = {};
    end
    smart_saved_data{end+1} = bin_data{i}.smart_saved_data;
    setappdata(left_handles(i),'smart_saved_data',smart_saved_data);

    sum_saved_data = getappdata(left_handles(i),'sum_saved_data');
    if isempty(sum_saved_data)
        sum_saved_data = {};
    end
    sum_saved_data{end+1} = bin_data{i}.sum_saved_data;
    setappdata(left_handles(i),'sum_saved_data',sum_saved_data);
    
    setappdata(left_handles(i),'all_match_inxs',bin_data{i}.all_match_inxs);

    setappdata(left_handles(i),'info',bin_info{i});
    setappdata(left_handles(i),'dirty',bin_dirty{i});
    setappdata(left_handles(i),'old_left',bin_old_left{i});
    setappdata(left_handles(i),'old_right',bin_old_right{i});
end

if ~isnan(left_noise) && ~isnan(right_noise)
    if ~isempty(getappdata(gcf,'left_noise_cursor'))
        DeleteCursor(getappdata(gcf,'left_noise_cursor'));
    end
    if ~isempty(getappdata(gcf,'right_noise_cursor'))
        DeleteCursor(getappdata(gcf,'right_noise_cursor'));
    end   
    left_noise_cursor = CreateCursor(gcf,'k');
    SetCursorLocation(left_noise_cursor,left_noise);
    right_noise_cursor = CreateCursor(gcf,'k');
    SetCursorLocation(right_noise_cursor,right_noise);
    setappdata(gcf,'left_noise_cursor',left_noise_cursor);
    setappdata(gcf,'right_noise_cursor',right_noise_cursor);    
end

plot_all