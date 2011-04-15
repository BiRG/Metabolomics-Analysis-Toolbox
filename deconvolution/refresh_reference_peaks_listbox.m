function refresh_reference_peaks_listbox(handles)
reference = getappdata(gcf,'reference');
data = {''};
if isfield(reference,'maxs')
    for i = 1:length(reference.maxs)
        if reference.include_mask(i)
            data{i+1} = num2str(reference.x(reference.maxs(i)));
        else
            data{i+1} = ['*',num2str(reference.x(reference.maxs(i)))];
        end
    end
end
set(handles.reference_peaks_listbox,'String',data);
set(handles.reference_peaks_listbox,'Value',1);