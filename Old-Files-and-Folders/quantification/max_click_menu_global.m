function max_click_menu_global(main_h,handle,i,j)
str = {'Delete peak','Delete peak and add to filtered list'};
[s,v] = listdlg('PromptString','Select an action',...
              'SelectionMode','single',...
              'ListString',str);

if isempty(s)
    return
end

if strcmp(str{s},'Delete peak and add to filtered list')
    filtered_list = getappdata(main_h,'filtered_list');
    if isempty(filtered_list)
        filtered_list = {};
        filtered_list.observed_peaks = {};
        filtered_list.observed_peaks_x = {};
        filtered_list.observed_peaks_min_height = [];
        filtered_list.observed_peaks_max_height = [];
        filtered_list.observed_peaks_min_width = [];
        filtered_list.observed_peaks_max_width = [];
    end
    xdata = get(handle,'xdata');
    x = xdata(1);
    collections = getappdata(main_h,'collections');
    [vs,inxs] = sort(abs(x - collections{i}.spectra{j}.xmaxs),'ascend');
    m = inxs(1);
    [vs,tinxs] = sort(abs(collections{i}.spectra{j}.xmaxs(m)-collections{i}.x));
    max_inx = tinxs(1);
    min_inxs = [];
    [vs,tinxs] = sort(abs(collections{i}.spectra{j}.xmins(m,1)-collections{i}.x));
    min_inxs(1) = tinxs(1);
    [vs,tinxs] = sort(abs(collections{i}.spectra{j}.xmins(m,2)-collections{i}.x));
    min_inxs(2) = tinxs(1);
    x = collections{i}.x;
    Y = collections{i}.Y;
    filtered_list.observed_peaks{end+1} = Y(min_inxs(1):min_inxs(end),j);
    filtered_list.observed_peaks_x{end+1} = x(min_inxs(1):min_inxs(end));
    height1 = Y(max_inx,j) - Y(min_inxs(1),j);
    height2 = Y(max_inx,j) - Y(min_inxs(end),j);
    filtered_list.observed_peaks_min_height(end+1) = min([height1,height2]);
    filtered_list.observed_peaks_max_height(end+1) = max([height1,height2]);
    tinxs = min_inxs(1):min_inxs(end);
    [vs,wixs] = sort(abs((Y(tinxs,j)-Y(min_inxs(1),j))-height1/2));
    wix = tinxs(wixs(1));
    xwidth = abs(x(1)-x(2));
    width1 = 2*xwidth*abs(max_inx-wix);
    [vs,wixs] = sort(abs((Y(tinxs,j)-Y(min_inxs(end),j))-height2/2));
    wix = tinxs(wixs(1));
    width2 = 2*xwidth*abs(max_inx-wix);
    filtered_list.observed_peaks_min_width(end+1) = min([width1,width2]);
    filtered_list.observed_peaks_max_width(end+1) = max([width1,width2]);        
    setappdata(main_h,'filtered_list',filtered_list);
end

if strcmp(str{s},'Delete peak') || strcmp(str{s},'Delete peak and add to filtered list')
    xdata = get(handle,'xdata');
    x = xdata(1);
    collections = getappdata(main_h,'collections');
    [vs,inxs] = sort(abs(x - collections{i}.spectra{j}.xmaxs),'ascend');
    collections{i}.spectra{j}.xmaxs = collections{i}.spectra{j}.xmaxs([1:(inxs(1)-1),(inxs(1)+1):end]);
    collections{i}.spectra{j}.xmins = collections{i}.spectra{j}.xmins([1:(inxs(1)-1),(inxs(1)+1):end],:);
    setappdata(main_h,'collections',collections);
    delete(handle);
    [regions,left_handles,right_handles] = get_regions(main_h);
    for i = 1:length(left_handles)
        [left,right] = regions(i,:);
        setappdata(left_handles(i),'dirty',true);
    end
end