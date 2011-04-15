function refresh_axes2(handles)
% Delete old plot
delete(findobj('Tag','hp2'));
delete(findobj('Tag','axes2_hmaxs'));
delete(findobj('Tag','hpeaks'));
delete(findobj('Tag','hbaseline'));
delete(findobj('Tag','hresidual'));
delete(findobj('Tag','axes2_hlabels'));

axes(handles.axes2);
collection = getappdata(gcf,'collection');
s = getappdata(gcf,'s');
hp2 = line(collection.x,collection.Y(:,s),'Color','k','Tag','hp2');
xlabel('Chemical shift (ppm)');
set(handles.axes2,'xdir','reverse');

hmaxs = [];
hlabels = [];
min_spectrum = getappdata(gcf,'min_spectrum');
if isfield(collection,'maxs')
    for i = 1:length(collection.maxs{s})
        if collection.include_mask{s}(i)
            hmaxs(end+1) = line([collection.x(collection.maxs{s}(i)),collection.x(collection.maxs{s}(i))],...
                [min(min_spectrum),collection.Y(collection.maxs{s}(i),s)],'Color','b','Tag','axes2_hmaxs','Visible','off');            
            if isfield(collection,'match_ids') && length(collection.match_ids) >= s && length(collection.match_ids{s}) >= i % Check to see if there is a match
                hlabels(end+1) = text(collection.x(collection.maxs{s}(i)),min(min_spectrum),num2str(collection.match_ids{s}(i)),'VerticalAlignment','top','HorizontalAlignment','center','Tag','axes2_hlabels','Visible','off');
                if collection.match_ids{s}(i) == 0 % Draw their attention to this
                    set(hlabels(end),'Color','g');
                end
                set(hlabels(end),'ButtonDownFcn',@myfunc);
            end
        else
            hmaxs(end+1) = line([collection.x(collection.maxs{s}(i)),collection.x(collection.maxs{s}(i))],...
                [min(min_spectrum),collection.Y(collection.maxs{s}(i),s)],'Color',[0.8 0.8 0.8],'Tag','axes2_hmaxs','Visible','off');
        end
        myfunc = @(hObject, eventdata) (max_click_spectrum(i,hmaxs(end),handles));
        set(hmaxs(end),'ButtonDownFcn',myfunc);
    end
end

hpeaks = [];
hbaseline = [];
hresidual = [];
dirty = getappdata(gcf,'dirty');
if ~dirty && isfield(collection,'BETA') && ~isempty(find(collection.BETA{s}(1:4:end) ~= 0)) && ~collection.dirty(s)
    if ~isempty(collection.BETA{s})
        BETA = collection.BETA{s};
        for p = 1:length(BETA)/4
            hpeaks(end+1) = line(collection.x,one_peak_model(BETA(4*(p-1)+(1:4)),collection.x),'Color',[0.6,0.6,0.6],'Tag','hpeaks','Visible','off');
        end
        zero_inxs = find(collection.Y(:,s) == 0);
        y_baseline = collection.y_baseline{s};
        y_baseline(zero_inxs) = 0;
        hbaseline = line(collection.x,y_baseline,'Color',[0.7,0.1,0.8],'Tag','hbaseline','Visible','off');
        y_residual = collection.y_fit{s}-collection.Y(:,s);
        y_residual(zero_inxs) = 0;
        hresidual = line(collection.x,y_residual,'Color',[0.1,0.7,0.8],'Tag','hresidual','Visible','off');
    end
end

set(hmaxs,'visible','on');
set(hlabels,'visible','on');
set(hpeaks,'visible','on');
set(hbaseline,'visible','on');
set(hresidual,'visible','on');

if ~dirty && isfield(collection,'BETA') && ~isempty(find(collection.BETA{s}(1:4:end) ~= 0)) && ~collection.dirty(s)
    legend([hp2,hbaseline,hresidual],{get_legend(collection,s),'Baseline','Residual'});
else
    legend([hp2],{get_legend(collection,s)});
end

refresh_spectrum_peaks_listbox(handles);
update_match(handles);

function myfunc(hObject,eventdata,handles)
set(hObject,'Color','m');
set(hObject,'Editing','on');

