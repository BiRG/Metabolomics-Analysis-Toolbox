function region_click_menu(handle)
str = {'Edit bin','Delete bin','Show bin','Set dirty'};
[s,v] = listdlg('PromptString','Select an action',...
              'SelectionMode','single',...
              'ListString',str);

if isempty(s)
    return
end

[regions,left_handles,right_handles] = get_regions;
region_inx = NaN;
for i = 1:length(left_handles)
    if left_handles(i) == handle || right_handles(i) == handle
        region_inx = i;
        break;
    end
end

if strcmp(str{s},'Show bin')
    show_bin(gcf,region_inx)
elseif strcmp(str{s},'Edit bin')
    set_edit(region_inx)
elseif strcmp(str{s},'Delete bin')
    delete_region(region_inx)
elseif strcmp(str{s},'Set dirty')
    setappdata(left_handles(region_inx),'dirty',true);
end