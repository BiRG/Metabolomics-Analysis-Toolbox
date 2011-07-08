function plot_line_adjacent(main_h,c,j,left,right,left_handle,new_figure)
adj_saved_data = getappdata(left_handle,'adj_saved_data');
if ~exist('new_figure')
    new_figure = true;
end
collections = getappdata(main_h,'collections');
reference = getappdata(main_h,'reference');
collection = collections{c};

message = '';
for i = 1:length(collection.input_names)
    name = regexprep(collection.input_names{i},' ','_');
    field_name = lower(name);
    if strcmp(field_name,'processing_log')
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

if new_figure
    figure;
else
    yl = ylim;
end
%% Just to get the limits
plot(adj_saved_data{c}.x{j},adj_saved_data{c}.Y_residual{j}+adj_saved_data{c}.Y_fit{j})
if ~exist('yl')
    yl = ylim;
end
%% Now for the real plot
hs = plot(collection.x,collection.Y(:,j),'Color',[0.5,0.5,0.5]);
hold on
all_peaks = [];
for p = 1:length(adj_saved_data{c}.peaks{j})
    if p == 1
        all_peaks = adj_saved_data{c}.peaks{j}{p};
    else
        all_peaks = all_peaks + adj_saved_data{c}.peaks{j}{p};
    end
    plot(adj_saved_data{c}.x{j},adj_saved_data{c}.peaks{j}{p},'Color',[0.75,0.75,0.75]);
end
reference = getappdata(main_h,'reference');
hs = [hs;plot(adj_saved_data{c}.x{j},adj_saved_data{c}.Y_fit{j},...
    adj_saved_data{c}.x{j},adj_saved_data{c}.Y_baseline{j},...
    adj_saved_data{c}.x{j},all_peaks,...
    adj_saved_data{c}.x{j},adj_saved_data{c}.Y_residual{j}...
    )];
hold off
legend(hs,{message,'Fit','Baseline','Peaks','Residual'},'Location','BestOutside')
line([left,left],ylim,'Color','r');
line([right,right],ylim,'Color','r');
set(gca,'xdir','reverse')
xlabel('Chemical shift, ppm')
ylabel('Intensity')

% Plot the maxs
inxs = find(left >= collections{c}.spectra{j}.xmaxs & collections{c}.spectra{j}.xmaxs >= right);
for n = 1:length(inxs)
    m = inxs(n);
    h = line([collections{c}.spectra{j}.xmaxs(m),collections{c}.spectra{j}.xmaxs(m)],ylim,'Color','b');
    myfunc = @(hObject, eventdata, handles) (max_click_menu(main_h,h,c,j,left_handle));
    menu = uicontextmenu('Callback',myfunc);
    set(h,'UIContextMenu',menu);
end

myfunc = @(hObject,v2,v3) (plot_line_click_menu(main_h,c,j,left_handle));
set(gca,'ButtonDownFcn',myfunc)

myfunc = @(hObject, eventdata, handles) (line_click_info_key_press(c,j,main_h));
set(gcf,'KeyPressFcn',myfunc);

cnt = 1;
match_inxs = getappdata(left_handle,'all_match_inxs');
for i = 1:length(collections)
    for k = 1:collections{i}.num_samples
        if i == c && k == j
            nm = size(match_inxs);
            mcnt = 1;
            for m = 1:nm(2)
                if sum(match_inxs(:,m) > 0) == nm(1) % Match across all samples
                    [mn,ix] = min(abs(adj_saved_data{i}.x{j} - adj_saved_data{i}.bin_X{j}(match_inxs(cnt,m))));
                    text(adj_saved_data{i}.bin_X{j}(match_inxs(cnt,m)),adj_saved_data{i}.Y_fit{j}(ix)+adj_saved_data{i}.Y_residual{j}(ix),num2str(mcnt));
                    mcnt = mcnt + 1;
                end
            end
        end
        cnt = cnt + 1;
    end
end

plot_func = @(c,j) (plot_line_adjacent(main_h,c,j,left,right,left_handle,false));
setappdata(gcf,'plot_func',plot_func); % Save for later

set(gca,'xlim',[right,left]);
ylim(yl);
