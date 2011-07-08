function plot_line_click_menu(main_h,i,j,left_handle)
mouse = get(gca,'CurrentPoint');
x_click = mouse(1,1);

str = {'Add peak','Set as reference'};
% str = {str{:},'','Set noise regions'};
[s,v] = listdlg('PromptString','Select an action',...
              'SelectionMode','single',...
              'ListString',str);

if isempty(s)
    return
end

if strcmp(str{s},'Add peak')
    collections = getappdata(main_h,'collections');
    orig_xmaxs = collections{i}.spectra{j}.xmaxs;
    orig_xmins = collections{i}.spectra{j}.xmins;
    x = collections{i}.x;
    y = collections{i}.Y(:,j);
    new_xmaxs = [];
    new_xmins = [];
    for k = 1:length(orig_xmaxs)
        if k == 1 && x_click > orig_xmaxs(k)
            new_xmaxs(end+1) = x_click;
            new_xmaxs(end+1) = orig_xmaxs(k);
        elseif k == length(orig_xmaxs) && x_click < orig_xmaxs(k)
            new_xmaxs(end+1) = orig_xmaxs(k);
            new_xmaxs(end+1) = x_click;
        elseif k > 1 && orig_xmaxs(k-1) > x_click && x_click > orig_xmaxs(k)
            new_xmaxs(end+1) = x_click;
            new_xmaxs(end+1) = orig_xmaxs(k);
        elseif x_click == orig_xmaxs(k)
            fprintf('There is already a peak at this location\n');
            return
        else
            new_xmaxs(end+1) = orig_xmaxs(k);
        end
    end
    % Now fix xmins
    avg_diff = mean(abs(orig_xmins(:,1) - orig_xmins(:,2)));
    for k = 1:length(new_xmaxs)
        if k == 1
            new_xmins(end+1,:) = [min([max(x),new_xmaxs(k)+avg_diff]),NaN];
        else
            new_xmins(end+1,:) = [new_xmins(end,2),NaN];
        end
        mix = NaN;
        if k < length(new_xmaxs)   
            minxs = find(new_xmaxs(k) >= x & x >= new_xmaxs(k+1));
            [vs,mixs] = sort(y(minxs),'ascend');
            try
                for q = 1:length(mixs) % Look for first minimum
                    mix = mixs(q);
                    if y(minxs(mix-1)) > y(minxs(mix)) && y(minxs(mix+1)) > y(minxs(mix)) % Make sure it is a minimum
                        break;
                    end
                end
            catch ME % Ignore
                [v,mix] = min(y(minxs));
            end
            new_min_x = x(minxs(mix));
            new_xmins(end,2) = new_min_x;
        else
            new_xmins(end,2) = max([min(x),new_xmaxs(k)-avg_diff]);
        end
    end
    collections{i}.spectra{j}.xmins = new_xmins;
    collections{i}.spectra{j}.xmaxs = new_xmaxs;
    setappdata(main_h,'collections',collections);
    line([x_click,x_click],ylim,'Color','b');
    if exist('left_handle')
        setappdata(left_handle,'dirty',true);
    end
elseif strcmp(str{s},'Set as reference')
    set_reference_spectrum(main_h,i,j);
end