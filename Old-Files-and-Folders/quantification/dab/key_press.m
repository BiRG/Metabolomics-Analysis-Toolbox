function key_press(handles)
k = get(handles.figure1,'CurrentKey');

if strcmp(k,'uparrow')
    ylim1 = ylim;
    diff = ylim1(2)-ylim1(1);
    ylim([ylim1(1)+diff*0.1,ylim1(2)+diff*0.1]);
elseif strcmp(k,'downarrow')
    ylim1 = ylim;
    diff = ylim1(2)-ylim1(1);
    ylim([ylim1(1)-diff*0.1,ylim1(2)-diff*0.1]);
elseif strcmp(k,'rightarrow')
    xlim1 = xlim;
    xdist = str2num(get(handles.x_zoom_edit,'String'));
    xlim([xlim1(1)-xdist,xlim1(2)-xdist]);        
elseif strcmp(k,'leftarrow')
    xlim1 = xlim;
    xdist = str2num(get(handles.x_zoom_edit,'String'));
    xlim([xlim1(1)+xdist,xlim1(2)+xdist]);        
elseif strcmp(k,'r')
    xlim auto
    ylim auto
end