function append_to_log(handles,msg)
current = get(handles.log_text,'String');
if iscell(current)
    set(handles.log_text,'String',{msg,current{:}});
else
    set(handles.log_text,'String',{msg,current});
end
drawnow;