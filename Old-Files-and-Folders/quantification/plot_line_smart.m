function plot_line_smart(main_h,c,j,smart_saved_data,left,right,new_figure)
if ~exist('new_figure')
    new_figure = true;
end
collections = getappdata(main_h,'collections');
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
end
%% Just to get the limits
plot(smart_saved_data{c}.x{j},smart_saved_data{c}.Y_bin{j}+smart_saved_data{c}.Y_fit{j},'Color',[0.75,0.75,0.75])
yl = ylim;
%% Now for the real plot
hold on
plot(smart_saved_data{c}.x{j},smart_saved_data{c}.Y_bin{j},'k')
plot(smart_saved_data{c}.x{j},smart_saved_data{c}.Y_fit{j},'b')
legend({message,'Bin','Baseline'},'Location','BestOutside')
line([left,left],ylim,'Color','r');
line([right,right],ylim,'Color','r');
set(gca,'xdir','reverse')
xlabel('Chemical shift, ppm')
ylabel('Intensity')
set(gca,'xlim',[right,left])
ylim(yl)
hold off

plot_func = @(c,j) (plot_line_smart(main_h,c,j,smart_saved_data,left,right,false));
setappdata(gcf,'plot_func',plot_func); % Save for later