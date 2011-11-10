function clear_all(handles)
set(handles.spectrum_listbox,'String',{});
set(handles.spectrum_listbox,'Value',1);

h = plot(0,0);
delete(h);

% Update handles structure
guidata(handles.figure1, handles);
