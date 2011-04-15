function select_binning_method_adj(ax,other_axs,left_handle,main_h,hObject, eventdata, handles)
for i = 1:length(other_axs)
    other_ax = other_axs(i);
    set(other_ax,'Color',[0.75,0.75,0.75]);
end
set(ax,'Color',[1,1,1]);
info = getappdata(left_handle,'info');
info.binning_method = 'adj';
if ~isfield(info,'active_adj')
    info.active_adj = false;
end
old_active_adj = info.active_adj;
info.active_adj = true;
setappdata(left_handle,'info',info);
if ~old_active_adj
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
    setappdata(left_handle,'dirty',true);
    if region_inx > 0
        show_bin(main_h,region_inx);
    end
end