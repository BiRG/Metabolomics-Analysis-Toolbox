function plot_line_reference_menu(main_h)
mouse = get(gca,'CurrentPoint');
x_click = mouse(1,1);

str = {'Add peak'};
% str = {str{:},'','Set noise regions'};
[s,v] = listdlg('PromptString','Select an action',...
              'SelectionMode','single',...
              'ListString',str);

if isempty(s)
    return
end

reference = getappdata(main_h,'reference');

if strcmp(str{s},'Add peak')
    orig_X = reference.X;
    new_X = [];
    for k = 1:length(orig_X)
        if k == 1 && x_click > orig_X(k)
            new_X(end+1) = x_click;
            new_X(end+1) = orig_X(k);
        elseif k == length(orig_X) && x_click < orig_X(k)
            new_X(end+1) = orig_X(k);
            new_X(end+1) = x_click;
        elseif k > 1 && orig_X(k-1) > x_click && x_click > orig_X(k)
            new_X(end+1) = x_click;
            new_X(end+1) = orig_X(k);
        elseif x_click == orig_X(k)
            fprintf('There is already a peak at this location\n');
            return
        else
            new_X(end+1) = orig_X(k);
        end
    end
    reference.X = new_X;
    setappdata(main_h,'reference',reference);
    line([x_click,x_click],ylim,'Color','b');
end