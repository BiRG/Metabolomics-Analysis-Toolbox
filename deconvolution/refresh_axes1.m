function refresh_axes1(handles)
delete(findobj('Tag','hp1'));
delete(findobj('Tag','axes1_hmaxs'));
delete(findobj('Tag','axes1_hlabels'));

axes(handles.axes1);
% set(gca,'visible','off');
reference = getappdata(gcf,'reference');
hp1 = line(reference.x,reference.y,'Color','k','Tag','hp1');
set(handles.axes1,'xdir','reverse');
hmaxs = [];
hlabels = [];
min_spectrum = getappdata(gcf,'min_spectrum');
cnt = 1;
if isfield(reference,'maxs')
    for i = 1:length(reference.maxs)
        if reference.include_mask(i)
            hmaxs(end+1) = line([reference.x(reference.maxs(i)),reference.x(reference.maxs(i))],[min(min_spectrum),reference.y(reference.maxs(i))],'Color','b','Tag','axes1_hmaxs','Visible','off');
            hlabels(end+1) = text(reference.x(reference.maxs(i)),min(min_spectrum),num2str(reference.max_ids(i)),'VerticalAlignment','top','HorizontalAlignment','center','Tag','axes1_hlabels','Visible','off');
            set(hlabels(end),'ButtonDownFcn',@myfunc);
%             myfunc = @(hObject, eventdata, handles) set(hObject,'Editing','on');
%             set(hlabels(end),'ButtonDownFcn',myfunc);
            cnt = cnt + 1;
        else
            hmaxs(end+1) = line([reference.x(reference.maxs(i)),reference.x(reference.maxs(i))],[min(min_spectrum),reference.y(reference.maxs(i))],'Color',[0.8,0.8,0.8],'Tag','axes1_hmaxs');
        end
        myfunc2 = @(hObject, eventdata) (max_click_reference(i,hmaxs(end),handles));
        set(hmaxs(end),'ButtonDownFcn',myfunc2);
    end
end
set(hmaxs,'visible','on');
set(hlabels,'visible','on');

refresh_reference_peaks_listbox(handles);

function myfunc(hObject,eventdata,handles)
set(hObject,'Color','m');
set(hObject,'Editing','on');