function select_binning_method_smart(ax,other_axs,left_handle,main_h,hObject, eventdata, handles)
if strcmp(get(gcf,'SelectionType'),'alt')
    info = getappdata(left_handle,'info');
    ButtonName = questdlg('Fit?', ...
                         'Smart binning options', ...
                         'No', 'Endpoints', 'Minimum',info.smart_options.fit);
    info.smart_options.fit = ButtonName;
    setappdata(left_handle,'info',info);
    setappdata(left_handle,'dirty',true);
    % Show the updated region in a new window
    figure(main_h);    
    [regions,left_handles,right_handles] = get_regions;
    region_inx = NaN;
    for i = 1:length(left_handles)
        if left_handles(i) == left_handle
            region_inx = i;
            break;
        end
    end
    if region_inx > 0
        show_bin(region_inx,main_h);
    end
else
    for i = 1:length(other_axs)
        other_ax = other_axs(i);
        set(other_ax,'Color',[0.75,0.75,0.75]);
    end
    set(ax,'Color',[1,1,1]);
    info = getappdata(left_handle,'info');
    info.binning_method = 'smart';
    setappdata(left_handle,'info',info);
end