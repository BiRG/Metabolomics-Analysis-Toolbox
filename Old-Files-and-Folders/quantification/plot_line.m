function plot_line(c,j,inxs,y_fit,y_smoothed,new_bin_left,new_bin_right,xmaxs,peaks,y_baseline)
global quantification_h
main_h = quantification_h;
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

figure;
x = collection.x;
y_orig = collection.Y(:,j);
%% Just to get the limits
plot(x(inxs),y_orig(inxs))
yl = ylim;
%% Now for the real plot
plot(x,y_orig,'Color',[0.25,0.25,0.25])
hold on
if exist('y_baseline')
    plot(x(inxs),y_orig(inxs),x(inxs),y_fit,x(inxs),y_orig(inxs)-y_fit,x(inxs),y_baseline)
else
    plot(x(inxs),y_orig(inxs),x(inxs),y_fit,x(inxs),y_orig(inxs)-y_fit)
end
if exist('peaks')
    for p = 1:length(peaks)
        plot(x(inxs),peaks{p}(inxs),'Color',[0.75,0.75,0.75]);
    end
end
hold on
if exist('y_baseline')
    legend({'Outside bin',message,'Fit','Difference','Baseline'},'Location','Best')
else
    legend({'Outside bin',message,'Fit','Difference','Baseline'},'Location','Best')
end
% plot(x(inxs),y_orig(inxs),x(inxs),y_smoothed(inxs))
% legend({message,'Smooth'},'Location','Best')
line([new_bin_left,new_bin_left],ylim,'Color','r');
line([new_bin_right,new_bin_right],ylim,'Color','r');
set(gca,'xdir','reverse')
xlabel('Chemical shift, ppm')
ylabel('Intensity')

% Plot all of the maxs in black
for m = 1:length(collection.spectra{j}.xmaxs)
    line([collection.spectra{j}.xmaxs(m),collection.spectra{j}.xmaxs(m)],ylim,'Color','k');
end

% Plot the maxs
for m = 1:length(xmaxs)
    line([xmaxs(m),xmaxs(m)],ylim,'Color','b');
end

myfunc = @(hObject,v2,v3) (plot_line_click_menu(c,j));
set(gca,'ButtonDownFcn',myfunc)

set(gca,'xlim',[new_bin_right,new_bin_left])
ylim(yl)