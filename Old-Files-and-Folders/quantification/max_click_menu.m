function max_click_menu(main_h,handle,i,j,left_handle)
str = {'Delete peak'};
[s,v] = listdlg('PromptString','Select an action',...
              'SelectionMode','single',...
              'ListString',str);

if isempty(s)
    return
end

if strcmp(str{s},'Delete peak')
    xdata = get(handle,'xdata');
    x = xdata(1);
    collections = getappdata(main_h,'collections');
    [vs,inxs] = sort(abs(x - collections{i}.spectra{j}.xmaxs),'ascend');
    collections{i}.spectra{j}.xmaxs = collections{i}.spectra{j}.xmaxs([1:(inxs(1)-1),(inxs(1)+1):end]);
    collections{i}.spectra{j}.xmins = collections{i}.spectra{j}.xmins([1:(inxs(1)-1),(inxs(1)+1):end],:);
    setappdata(main_h,'collections',collections);
    delete(handle);
    setappdata(left_handle,'dirty',true);
end