function refresh_spectrum_peaks_listbox(handles)
collection = getappdata(gcf,'collection');
s = getappdata(gcf,'s');
data = {''};
if isfield(collection,'maxs') && s <= length(collection.maxs)
    for i = 1:length(collection.maxs{s})
        if collection.include_mask{s}(i)
            data{i+1} = num2str(collection.x(collection.maxs{s}(i)));
        else
            data{i+1} = ['*',num2str(collection.x(collection.maxs{s}(i)))];
        end
    end
end
set(handles.spectrum_peaks_listbox,'String',data);
set(handles.spectrum_peaks_listbox,'Value',1);