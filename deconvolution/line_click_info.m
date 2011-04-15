function line_click_info(c,j,hObject, eventdata, handles)
collection = c;
message = '';
selection_type = get(gcf,'SelectionType');
s = sprintf('Index: %d\n',j);
message = [message,s];
for i = 1:length(collection.input_names)
    name = regexprep(collection.input_names{i},' ','_');
    field_name = lower(name);
    if strcmp(selection_type,'alt') && strcmp(field_name,'processing_log')
        continue
    end
    if i > 1
        s = sprintf('\n');
        message = [message,s];
    end
    s = sprintf('%s: ',collection.input_names{i});    
    message = [message,s];
    if iscell(collection.(field_name))
        if ischar(collection.(field_name){j})
            s = sprintf('%s',collection.(field_name){j});
            message = [message,s];
        elseif int8(collection.(field_name){j}) == collection.(field_name){j} % Integer
            s = sprintf('%d',collection.(field_name){j});
            message = [message,s];
        else
            s = sprintf('%f',collection.(field_name){j});
            message = [message,s];
        end
    elseif ischar(collection.(field_name))
        s = sprintf('%s',collection.(field_name));
        message = [message,s];
    elseif length(collection.(field_name)) > 1 % Array
        if ischar(collection.(field_name)(j))
            s = sprintf('%s',collection.(field_name)(j));
            message = [message,s];
        elseif int32(collection.(field_name)(j)) == collection.(field_name)(j) % Integer
            s = sprintf('%d',collection.(field_name)(j));
            message = [message,s];
        else
            s = sprintf('%f',collection.(field_name)(j));
            message = [message,s];
        end
    elseif int32(collection.(field_name)) == collection.(field_name) % Integer
        s = sprintf('%d',collection.(field_name));
        message = [message,s];
    else
        s = sprintf('%f',collection.(field_name));
        message = [message,s];
    end
end

if strcmp(selection_type,'normal')
    msgbox(message);
else
    calling_gcf = gcf;
    ax = get(calling_gcf,'CurrentAxes');
    xl = get(ax,'xlim');
    yl = get(ax,'ylim');
    figure;
    line(collection.x,collection.Y(:,j),'Color','k');
    legend(message,'Location','Best');
    set(gca,'xdir','reverse')
    set(gca,'xlim',xl);
    set(gca,'ylim',yl);
    xlabel('Chemical shift, ppm')
    ylabel('Intensity')


    reference_peak_inx = getappdata(calling_gcf,'reference_peak_inx');
    if ~isempty(reference_peak_inx)
        s = j;
        inx = find(collection.match_ids{s} == reference_peak_inx);
        if ~isempty(inx)
            BETA = collection.BETA{s}(4*(inx-1)+(1:4));
            line(collection.x,one_peak_model(BETA,collection.x),'Color','r','Tag','hpeaks');
        end
    end
end    
