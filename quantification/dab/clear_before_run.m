function clear_before_run(hObject,handles)
set(handles.summary_text,'String',{''});
try
    rmfield(handles,'xlim');
catch ME
end
axes(handles.spectra_axes);
h = plot(0,0);
delete(h);
