function options = get_options(h_options)
handles = guihandles(h_options);

options = {};
options.peak_finding_options.level = str2num(get(handles.level_edit,'String'));
contents = get(handles.tptr_listbox,'String');
options.peak_finding_options.tptr = contents{get(handles.tptr_listbox,'Value')};
contents = get(handles.sorh_listbox,'String');
options.peak_finding_options.sorh = contents{get(handles.sorh_listbox,'Value')};
contents = get(handles.scal_listbox,'String');
options.peak_finding_options.scal = contents{get(handles.scal_listbox,'Value')};
contents = get(handles.wavelet_listbox,'String');
options.peak_finding_options.wname = contents{get(handles.wavelet_listbox,'Value')};
options.peak_finding_options.noise_std_mult = str2num(get(handles.noise_std_edit,'String'));
options.peak_finding_options.percentile = str2num(get(handles.peak_height_percentile_edit,'String'));
