function refresh_axes2(handles)
% Delete old plot
delete(findobj('Tag','hp2'));
delete(findobj('Tag','axes2_hmaxs'));
delete(findobj('Tag','axes2_mark_hmaxs'));
delete(findobj('Tag','hpeaks'));
delete(findobj('Tag','hbaseline'));
delete(findobj('Tag','hresidual'));
delete(findobj('Tag','hbaseline_corrected'));
delete(findobj('Tag','axes2_hlabels'));

axes(handles.axes2);
collection = getappdata(gcf,'collection');
s = getappdata(gcf,'s');
hp2 = line(collection.x,collection.Y(:,s),'Color','k','Tag','hp2');
xlabel('Chemical shift (ppm)');
set(handles.axes2,'xdir','reverse');

hmaxs = [];
mark_hmaxs = [];
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
    include_inxs = find(collection.include_mask{s} == 1);
    if ~isempty(include_inxs)
        mark_hmaxs(end+1) = line(collection.x(collection.maxs{s}(include_inxs)),...
            collection.Y(collection.maxs{s}(include_inxs),s),'Color','b','Tag','axes2_mark_hmaxs','Visible','off','Marker','o');
    end
    exclude_inxs = find(collection.include_mask{s} == 0);
    if ~isempty(exclude_inxs)
        mark_hmaxs(end+1) = line(collection.x(collection.maxs{s}(exclude_inxs)),...
            collection.Y(collection.maxs{s}(exclude_inxs),s),'Color',[0.8 0.8 0.8],'Tag','axes2_mark_hmaxs','Visible','off','Marker','o');
    end
end

hpeaks = [];
hbaseline = [];
hresidual = [];
hbaseline_corrected = [];
dirty = getappdata(gcf,'dirty');
if ~dirty && isfield(collection,'BETA') && ~isempty(find(collection.BETA{s}(1:4:end) ~= 0)) && ~collection.dirty(s)
    if ~isempty(collection.BETA{s})
        BETA = collection.BETA{s};
%         for p = 1:length(BETA)/4
%             hpeaks(end+1) = line(collection.x,one_peak_model(BETA(4*(p-1)+(1:4)),collection.x),'Color',[0.6,0.6,0.6],'Tag','hpeaks','Visible','on');
%         end
        hpeaks(end+1) = line(collection.x,global_model(BETA,collection.x,length(BETA)/4,{}),'Color',[0.5,0.5,0.5],'Tag','hpeaks','Visible','on');
        zero_inxs = find(collection.Y(:,s) == 0);
        y_baseline = collection.y_baseline{s};
        y_baseline(zero_inxs) = 0;
        hbaseline_corrected = line(collection.x,collection.Y(:,s) - y_baseline,'Color','b','Tag','hbaseline_corrected','Visible','on');
        hbaseline = line(collection.x,y_baseline,'Color',[0.7,0.1,0.8],'Tag','hbaseline','Visible','on');
        y_residual = collection.Y(:,s) - collection.y_fit{s};
        y_residual(zero_inxs) = 0;
        hresidual = line(collection.x,y_residual,'Color',[0.1,0.7,0.8],'Tag','hresidual','Visible','on');
    end
end

if ~get(handles.hide_peak_numbers_checkbox,'Value')
    set(hmaxs,'visible','on');
    set(hlabels,'visible','on');
end
set(mark_hmaxs,'linestyle','none');
set(mark_hmaxs,'visible','on');
set(hpeaks,'visible','on');
set(hbaseline,'visible','on');
set(hresidual,'visible','on');
set(hbaseline_corrected,'visible','on');

if ~dirty && isfield(collection,'BETA') && ~isempty(find(collection.BETA{s}(1:4:end) ~= 0)) && ~collection.dirty(s)
    axis2_legend = legend([hp2,hbaseline_corrected,hbaseline,hresidual],{'Original','Baseline Corrected','Baseline','Residual'});
else
    axis2_legend = legend(hp2,'Original');
end

if get(handles.hide_legend_checkbox,'Value')
    set(axis2_legend,'Visible','off');
end
setappdata(gcf,'axis2_legend',axis2_legend);

refresh_spectrum_peaks_listbox(handles);
update_match(handles);

function myfunc(hObject,eventdata,handles)
set(hObject,'Color','m');
set(hObject,'Editing','on');

