function select_binning_method_sum(ax,other_axs,left_handle,hObject, eventdata, handles)
for i = 1:length(other_axs)
    other_ax = other_axs(i);
    set(other_ax,'Color',[0.75,0.75,0.75]);
end
set(ax,'Color',[1,1,1]);
info = getappdata(left_handle,'info');
info.binning_method = 'sum';
setappdata(left_handle,'info',info);