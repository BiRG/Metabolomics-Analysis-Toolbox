function smart_saved_data = binning_smart(main_h,left,right,smart_options)
collections = getappdata(main_h,'collections');

for i = 1:length(collections)
    for j = 1:collections{i}.num_samples
        xmaxs = collections{i}.spectra{j}.xmaxs;
        max_inxs = find(left >= xmaxs & xmaxs >= right);
        xmins = collections{i}.spectra{j}.xmins(max_inxs,:);
        if isempty(xmins)
            left_min = left;
            right_min = right;
        else
            left_min = max(xmins(:,1));
            right_min = min(xmins(:,2));
        end
        inxs = find(left_min >= collections{i}.x & collections{i}.x >= right_min);
        if isempty(inxs)
            error(sprintf('Problem with bin [%f,%f]\n',left_min,right_min));
        end
        
        x_baseline_BETA = [collections{i}.x(inxs(1)),collections{i}.x(inxs(end))];
        baseline_BETA = collections{i}.Y([inxs(1),inxs(end)],j);
        if strcmp(smart_options.fit,'No')
            y_fit = 0*collections{i}.Y(:,j);
        elseif strcmp(smart_options.fit,'Endpoints')
            y_fit = interp1(x_baseline_BETA,baseline_BETA,collections{i}.x,'linear',NaN)';
        elseif strcmp(smart_options.fit,'Minimum')
            y_fit = 0*collections{i}.Y(:,j)+min(collections{i}.Y([inxs(1),inxs(end)],j));
        end
        y_bin = collections{i}.Y(:,j) - y_fit;

        if j == 1
            smart_saved_data{i}.Y_bin = {};
            smart_saved_data{i}.Y_fit = {};
            smart_saved_data{i}.x = {};
            smart_saved_data{i}.bin_values = {};
            smart_saved_data{i}.bin_locations = {};
        end
        smart_saved_data{i}.Y_bin{j} = y_bin(inxs);
        smart_saved_data{i}.Y_fit{j} = y_fit(inxs);
        smart_saved_data{i}.x{j} = collections{i}.x(inxs);
        smart_saved_data{i}.bin_values{j} = sum(y_bin(inxs));
        smart_saved_data{i}.bin_locations{j} = (left_min+right_min)/2;        
    end
end

setappdata(main_h,'collections',collections);

% 
% dirty = true;
% if dirty
%     smart_saved_data = {};
%     for i = 1:length(collections)
%         smart_saved_data{i} = {};
%     end
% else
%     smart_saved_data = getappdata(left_handle,'smart_saved_data');
% end
% 
% yhs = [];
% legend_cell = {};
% for i = 1:length(collections)
%     if ~isfield(collections{i},'spectra')
%         collections = create_spectra_fields(collections,left_noise,right_noise);
%     end
%     xmaxs = collections{i}.spectra{1}.xmaxs;
%     max_inxs = find(left >= xmaxs & xmaxs >= right);
%     xmins = collections{i}.spectra{1}.xmins(max_inxs,:);
%     if isempty(xmins)
%         left_min = left;
%         right_min = right;
%     else
%         left_min = max(xmins(:,1));
%         right_min = min(xmins(:,2));
%     end
%     inxs = find(left_min >= collections{i}.x & collections{i}.x >= right_min);
%     
%     if dirty
%         x_baseline_BETA = [collections{i}.x(inxs(1)),collections{i}.x(inxs(end))];
%         baseline_BETA = collections{i}.Y([inxs(1),inxs(end)],1);
%         if strcmp(info.smart_options.fit,'No')
%             y_fit = 0*collections{i}.Y(:,1);
%         elseif strcmp(info.smart_options.fit,'Endpoints')
%             y_fit = interp1(x_baseline_BETA,baseline_BETA,collections{i}.x,'linear',NaN)';
%         elseif strcmp(info.smart_options.fit,'Minimum')
%             y_fit = 0*collections{i}.Y(:,1)+min(collections{i}.Y([inxs(1),inxs(end)],1));
%         end
%         y_bin = collections{i}.Y(:,1) - y_fit;
% 
%         smart_saved_data{i}.Y_bin = {};
%         smart_saved_data{i}.Y_bin{1} = y_bin(inxs);
%         smart_saved_data{i}.Y_fit = {};
%         smart_saved_data{i}.Y_fit{1} = y_fit(inxs);
%     end
% 
%     if ~exist('hide_plot') || ~hide_plot
%         hl = line(collections{i}.x(inxs),smart_saved_data{i}.Y_bin{1},'Color',colors(mod(i+offset-2,length(colors))+1,:));
%         myfunc = @(hObject, eventdata, handles) (plot_line(i,1,inxs,smart_saved_data{i}.Y_fit{1},collections{i}.spectra{1}.y_smoothed,left_min,right_min,xmaxs(max_inxs)));
%         set(hl,'ButtonDownFcn',myfunc);
%         yhs(end+1) = hl;
%         % Change the following line if you want to change the legend for
%         % each collection
%         legend_cell{end+1} = num2str(collections{i}.description);
%     end
% end
% if ~exist('hide_plot') || ~hide_plot
%     lh = legend(legend_cell);
%     line([left,left],yl,'Color','r');
%     line([right,right],yl,'Color','r');
% end
% for i = 1:length(collections)
%     for j = 2:collections{i}.num_samples
%         xmaxs = collections{i}.spectra{j}.xmaxs;
%         max_inxs = find(left >= xmaxs & xmaxs >= right);
%         xmins = collections{i}.spectra{j}.xmins(max_inxs,:);
%         if isempty(xmins)
%             left_min = left;
%             right_min = right;
%         else
%             left_min = max(xmins(:,1));
%             right_min = min(xmins(:,2));
%         end
%         inxs = find(left_min >= collections{i}.x & collections{i}.x >= right_min);
%         
%         if dirty
%             x_baseline_BETA = [collections{i}.x(inxs(1)),collections{i}.x(inxs(end))];
%             baseline_BETA = collections{i}.Y([inxs(1),inxs(end)],j);
%             if strcmp(info.smart_options.fit,'No')
%                 y_fit = 0*collections{i}.Y(:,j);
%             elseif strcmp(info.smart_options.fit,'Endpoints')
%                 y_fit = interp1(x_baseline_BETA,baseline_BETA,collections{i}.x,'linear',NaN)';
%             elseif strcmp(info.smart_options.fit,'Minimum')
%                 y_fit = 0*collections{i}.Y(:,j)+min(collections{i}.Y([inxs(1),inxs(end)],j));
%             end
%             y_bin = collections{i}.Y(:,j) - y_fit;
%             
%             smart_saved_data{i}.Y_bin{j} = y_bin(inxs);
%             smart_saved_data{i}.Y_fit{j} = y_fit(inxs);
%         end
% 
%         if ~exist('hide_plot') || ~hide_plot
%             hl = line(collections{i}.x(inxs),smart_saved_data{i}.Y_bin{j},'Color',colors(mod(i+offset-2,length(colors))+1,:));
%             myfunc = @(hObject, eventdata, handles) (plot_line(i,j,inxs,smart_saved_data{i}.Y_fit{j},collections{i}.spectra{j}.y_smoothed,left_min,right_min,xmaxs(max_inxs)));
%             set(hl,'ButtonDownFcn',myfunc);
%             yhs(end+1) = hl;
%         end
%     end
% end
% if ~exist('hide_plot') || ~hide_plot
%     setappdata(gcf,'yhs',yhs);
%     setappdata(gcf,'lh',lh);
% 
%     set(gcf,'CloseRequestFcn',@closing_child_window);
%     setappdata(gcf,'yhs',yhs);
%     setappdata(gcf,'main_h',main_h);
%     set(gca,'xdir','reverse')
%     % set(gca,'xlim',[right,left]);
%     ylim auto
%     xlim auto
%     xlabel('Chemical shift, ppm')
%     ylabel('Intensity')
%     title({'Smart binning',['Fit: ',info.smart_options.fit]})
% end