function show_bin(main_h,region_inx,hide_plot)
get_colors;

collections = getappdata(main_h,'collections');

if exist('region_inx')
    [region_inx,left,right,left_handle] = get_region(region_inx);
else
    [region_inx,left,right,left_handle] = get_region;
end

info = getappdata(left_handle,'info');
if isempty(info)
    info = {};
    info.binning_method = 'sum';
    info.active_adj = false;
end

[left_noise,right_noise] = get_noise(main_h);
dirty = getappdata(left_handle,'dirty');
if isempty(dirty)
    dirty = true;
end
if ~dirty % Check positions    
    old_left = getappdata(left_handle,'old_left');
    old_right = getappdata(left_handle,'old_right');
    if isempty(old_left) || isempty(old_right)
        dirty = true;
    elseif old_left == left && old_right == right
        dirty = false;
    else
        dirty = true;
    end
    
    old_left_noise = getappdata(left_handle,'old_left_noise');
    old_right_noise = getappdata(left_handle,'old_right_noise');
    if isempty(old_left_noise) || isempty(old_right_noise)
        dirty = true;
        for c = 1:length(collections)
            if isfield(collections{c},'spectra')
                collections{c} = rmfield(collections{c},'spectra');
            end
        end
    elseif old_left_noise == left_noise && old_right_noise == right_noise
        dirty = false;
    else
        dirty = true;
        for c = 1:length(collections)
            if isfield(collections{c},'spectra')
                collections{c} = rmfield(collections{c},'spectra');
            end
        end
    end
end
for c = 1:length(collections)
    if ~isfield(collections{c},'spectra')
        collections = create_spectra_fields(collections,left_noise,right_noise);
        break;
    end
end
setappdata(main_h,'collections',collections);

regions = get_regions;
ave = mean(abs(diff(collections{1}.spectra{1}.xmaxs)));
padding = 2*ave; % Padding on each side of the function
new_bin_left = left;
if region_inx > 1
    new_bin_left = regions(region_inx-1,1);
end
far_left = max([new_bin_left,left+padding]);
new_bin_right = right;
nm = size(regions);
if region_inx < nm(1)
    new_bin_right = regions(region_inx+1,2);
end
far_right = min([new_bin_right,right-padding]);

if ~exist('hide_plot') || ~hide_plot
    if isempty(getappdata(gcf,'main_h'))
        fhs = getappdata(main_h,'fhs');
        fh = figure;
        fhs(end+1) = fh;
        setappdata(main_h,'fhs',fhs);
    end
    ax = get(main_h,'CurrentAxes');
    xl = get(ax,'xlim');
    yl = get(ax,'ylim');
    setappdata(gcf,'main_h',main_h);
end

% dirty = true;

%% Regular binning
if ~exist('hide_plot') || ~hide_plot
    subplot(1,3,1);
end
if dirty
    sum_saved_data = binning_sum(main_h,left,right);
    setappdata(left_handle,'sum_saved_data',sum_saved_data);
    collections = getappdata(main_h,'collections');
else
    sum_saved_data = getappdata(left_handle,'sum_saved_data');
end
if ~exist('hide_plot') || ~hide_plot
    yhs = [];
    legend_cell = {};
    for i = 1:length(collections)
        inxs = find(left >= collections{i}.x & collections{i}.x >= right);
        for j = 1:collections{i}.num_samples
            hl = line(sum_saved_data{i}.x{j},sum_saved_data{i}.Y_bin{j},'Color',colors(mod(i+offset-2,length(colors))+1,:));
            myfunc = @(hObject, eventdata, handles) (plot_line_sum(main_h,i,j,sum_saved_data,left,right));
            set(hl,'ButtonDownFcn',myfunc);
            if j == 1
                yhs(end+1) = hl;
                % Change the following line if you want to change the legend for
                % each collection
                legend_cell{end+1} = num2str(collections{i}.description);
            end
        end
    end
    legend(yhs,legend_cell);
    line([left,left],yl,'Color','r');
    line([right,right],yl,'Color','r');
    xlim([right,left]);
    set(gca,'xdir','reverse');
end

%% Individual adjustment
if ~exist('hide_plot') || ~hide_plot
    subplot(1,3,2);
end
% Set defaults
if ~isfield(info,'smart_options')
    info.smart_options = {};
    info.smart_options.fit = 'No';
end
if dirty
    smart_saved_data = binning_smart(main_h,left,right,info.smart_options);
    setappdata(left_handle,'smart_saved_data',smart_saved_data);
    collections = getappdata(main_h,'collections');
else
    smart_saved_data = getappdata(left_handle,'smart_saved_data');
end
if ~exist('hide_plot') || ~hide_plot
    yhs = [];
    legend_cell = {};
    for i = 1:length(collections)
        for j = 1:collections{i}.num_samples
            hl = line(smart_saved_data{i}.x{j},smart_saved_data{i}.Y_bin{j},'Color',colors(mod(i+offset-2,length(colors))+1,:));
            myfunc = @(hObject, eventdata, handles) (plot_line_smart(main_h,i,j,smart_saved_data,left,right));
            set(hl,'ButtonDownFcn',myfunc);
            if j == 1
                yhs(end+1) = hl;
                % Change the following line if you want to change the legend for
                % each collection
                legend_cell{end+1} = num2str(collections{i}.description);
            end
        end
    end
    legend(yhs,legend_cell);
    line([left,left],yl,'Color','r');
    line([right,right],yl,'Color','r');
    xlim([right,left]);
    set(gca,'xdir','reverse');    
end

%% Adjacent binning
if ~exist('hide_plot') || ~hide_plot
    subplot(1,3,3);
end
if dirty && isfield(info,'active_adj') && info.active_adj
    adj_saved_data = getappdata(left_handle,'adj_saved_data');
    if isempty(adj_saved_data)
        adj_saved_data = {};
    end
    adj_saved_data = binning_adjacent(main_h,left,right,far_left,far_right,adj_saved_data);
    setappdata(left_handle,'adj_saved_data',adj_saved_data);
    collections = getappdata(main_h,'collections');
else
    adj_saved_data = getappdata(left_handle,'adj_saved_data');
end
if (~exist('hide_plot') || ~hide_plot) && isfield(info,'active_adj') && info.active_adj
    yhs = [];
    legend_cell = {};
    for i = 1:length(collections)
        for j = 1:collections{i}.num_samples
            if ~adj_saved_data{i}.converged{j}
                hl = line(adj_saved_data{i}.x{j},adj_saved_data{i}.Y_bin{j},'LineStyle',':','Color',colors(mod(i+offset-2,length(colors))+1,:));
            else
                hl = line(adj_saved_data{i}.x{j},adj_saved_data{i}.Y_bin{j},'Color',colors(mod(i+offset-2,length(colors))+1,:));
            end
            myfunc = @(hObject, eventdata, handles) (plot_line_adjacent(main_h,i,j,adj_saved_data,left,right,left_handle));
            set(hl,'ButtonDownFcn',myfunc);
            if j == 1
                yhs(end+1) = hl;
                % Change the following line if you want to change the legend for
                % each collection
                legend_cell{end+1} = num2str(collections{i}.description);
            end
        end
    end
    cnt = 1;
    reference = getappdata(main_h,'reference');
    match_inxs = reference.all_match_inxs;
    for i = 1:length(collections)
        for j = 1:collections{i}.num_samples
            nm = size(match_inxs);
            mcnt = 1;
            for m = 1:nm(2)
                if sum(match_inxs(:,m) > 0) == nm(1) % Match across all samples
                    [mn,ix] = min(abs(adj_saved_data{i}.x{j} - adj_saved_data{i}.bin_X{j}(match_inxs(cnt,m))));
                    text(adj_saved_data{i}.bin_X{j}(match_inxs(cnt,m)),adj_saved_data{i}.Y_bin{j}(ix),num2str(mcnt));
                    mcnt = mcnt + 1;
                end
            end
            cnt = cnt + 1;
        end
    end

    legend(yhs,legend_cell);
    line([left,left],yl,'Color','r');
    line([right,right],yl,'Color','r');
    xlim([right,left]);
    set(gca,'xdir','reverse');
end

if ~exist('hide_plot') || ~hide_plot
    myfunc = @(hObject, eventdata, handles) (select_binning_method_sum(subplot(1,3,1),[subplot(1,3,2),subplot(1,3,3)],left_handle));
    set(subplot(1,3,1),'ButtonDownFcn',myfunc)
    myfunc = @(hObject, eventdata, handles) (select_binning_method_smart(subplot(1,3,2),[subplot(1,3,1),subplot(1,3,3)],left_handle,main_h));
    set(subplot(1,3,2),'ButtonDownFcn',myfunc)
    myfunc = @(hObject, eventdata, handles) (select_binning_method_adj(subplot(1,3,3),[subplot(1,3,1),subplot(1,3,2)],left_handle,main_h));
    set(subplot(1,3,3),'ButtonDownFcn',myfunc)

    if strcmp(info.binning_method,'sum')
        select_binning_method_sum(subplot(1,3,1),[subplot(1,3,2),subplot(1,3,3)],left_handle);
    elseif strcmp(info.binning_method,'smart')
        select_binning_method_smart(subplot(1,3,2),[subplot(1,3,1),subplot(1,3,3)],left_handle,main_h);
    elseif strcmp(info.binning_method,'adj')
        select_binning_method_adj(subplot(1,3,3),[subplot(1,3,1),subplot(1,3,2)],left_handle,main_h);
    end

    myfunc = @(hObject, eventdata, handles) (show_bin_key_press(region_inx));
    set(gcf,'KeyPressFcn',myfunc);
end

setappdata(left_handle,'info',info);
setappdata(left_handle,'dirty',false); % Done
setappdata(left_handle,'old_left',left);
setappdata(left_handle,'old_right',right);
setappdata(left_handle,'old_left_noise',left_noise);
setappdata(left_handle,'old_right_noise',right_noise);
setappdata(left_handle,'sum_saved_data',sum_saved_data);
setappdata(left_handle,'adj_saved_data',adj_saved_data);
setappdata(left_handle,'smart_saved_data',smart_saved_data);
setappdata(main_h,'collections',collections);