function max_click_menu_reference(main_h,handle)
str = {'Delete peak'};
[s,v] = listdlg('PromptString','Select an action',...
              'SelectionMode','single',...
              'ListString',str);

if isempty(s)
    return
end

reference = getappdata(main_h,'reference');

if strcmp(str{s},'Delete peak')
    xdata = get(handle,'xdata');
    x = xdata(1);
    [vs,inxs] = sort(abs(x - reference.X),'ascend');
    reference.X = reference.X([1:(inxs(1)-1),(inxs(1)+1):end]);
    setappdata(main_h,'reference',reference);
    delete(handle);
end