function plot_line_adjacent(main_h,c,j,adj_saved_data,left,right,left_handle)
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

figure;
%% Just to get the limits
plot(adj_saved_data{c}.x{j},adj_saved_data{c}.Y_bin{j})
yl = ylim;
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
hs = [hs;plot(adj_saved_data{c}.x{j},adj_saved_data{c}.Y_bin{j}+adj_saved_data{c}.Y_fit{j},...
    adj_saved_data{c}.x{j},adj_saved_data{c}.Y_bin{j},...
    adj_saved_data{c}.x{j},adj_saved_data{c}.Y_fit{j},...
    adj_saved_data{c}.x{j},adj_saved_data{c}.Y_baseline{j},...
    adj_saved_data{c}.x{j},all_peaks)];
hold off
legend(hs,{'Outside bin',message,'Bin','Fit (Adjacent)','Baseline (Peaks)','Fit (Peaks)'},'Location','BestOutside')
line([left,left],ylim,'Color','r');
line([right,right],ylim,'Color','r');
set(gca,'xdir','reverse')
xlabel('Chemical shift, ppm')
ylabel('Intensity')

% Plot all of the maxs in black
for m = 1:length(collection.spectra{j}.xmaxs)
    in = false;
    for n = 1:length(adj_saved_data{c}.X{j})
        if adj_saved_data{c}.X{j}(n) == collection.spectra{j}.xmaxs(m)
            in = true;
        end
    end
    if ~in
        line([collection.spectra{j}.xmaxs(m),collection.spectra{j}.xmaxs(m)],ylim,'Color','k');
    end
end

% Plot the maxs
for m = 1:length(adj_saved_data{c}.X{j})
    h = line([adj_saved_data{c}.X{j}(m),adj_saved_data{c}.X{j}(m)],ylim,'Color','b');
    myfunc = @(hObject, eventdata, handles) (max_click_menu(main_h,h,c,j,left_handle));
    menu = uicontextmenu('Callback',myfunc);
    set(h,'UIContextMenu',menu);
end

myfunc = @(hObject,v2,v3) (plot_line_click_menu(main_h,c,j,left_handle));
set(gca,'ButtonDownFcn',myfunc)

cnt = 1;
match_inxs = reference.all_match_inxs;
for i = 1:length(collections)
    for k = 1:collections{i}.num_samples
        if i == c && k == j
            nm = size(match_inxs);
            mcnt = 1;
            for m = 1:nm(2)
                if sum(match_inxs(:,m) > 0) == nm(1) % Match across all samples
                    [mn,ix] = min(abs(adj_saved_data{i}.x{j} - adj_saved_data{i}.bin_X{j}(match_inxs(cnt,m))));
                    text(adj_saved_data{i}.bin_X{j}(match_inxs(cnt,m)),adj_saved_data{i}.Y_bin{j}(ix),num2str(mcnt));
                    mcnt = mcnt + 1;
                end
            end
        end
        cnt = cnt + 1;
    end
end

set(gca,'xlim',[right,left])
ylim(yl)
