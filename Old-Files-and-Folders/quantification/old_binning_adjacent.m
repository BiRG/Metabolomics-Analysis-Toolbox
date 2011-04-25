function adj_saved_data = binning_adjacent(main_h)
% if dirty
%     adj_saved_data = {};
%     for i = 1:length(collections)
%         adj_saved_data{i} = {};
%     end
% else
%     adj_saved_data = getappdata(left_handle,'adj_saved_data');
% end
% 
% if isfield(info,'active_adj') && info.active_adj

collections = getappdata(main_h,'collections');

    for i = 1:length(collections)
        if ~isfield(collections{i},'spectra')
            collections = create_spectra_fields(collections,left_noise,right_noise);
        end        
        % Small adjustments to boundaries
        xmins = [collections{i}.spectra{1}.xmins(:,1);collections{i}.spectra{1}.xmins(:,2)];
        diffs = xmins - far_left;
        tinxs = find(diffs >= 0);
        diffs = diffs(tinxs);
        if ~isempty(diffs)
            [vs,ixs] = sort(diffs,'ascend');
            far_left_min = xmins(tinxs(ixs(1)));
        else
            far_left_min = far_left;
        end
        diffs = far_right - xmins;
        tinxs = find(diffs >= 0);
        diffs = diffs(tinxs);
        if ~isempty(diffs)
            [vs,ixs] = sort(diffs,'ascend');
            far_right_min = xmins(tinxs(ixs(1)));
        else
            far_right_min = far_right;
        end
        inxs = find(far_left_min >= collections{i}.x & collections{i}.x >= far_right_min);
        
        if dirty
            [y_fit,fit_inxs,MGPX,baseline_BETA,x_baseline_BETA,xmaxs] = curve_fit_helper(collections,i,1,left,right,far_left_min,far_right_min);
            collections{i}.spectra{1}.xmaxs = xmaxs;
            setappdata(calling_gcf,'collections',collections);
            X = MGPX(4:4:end);
            xinxs = [find(X >= left),find(X <= right)];
            MGPX_o = [];
            for k = 1:length(xinxs)
                MGPX_o = [MGPX_o,MGPX(4*(xinxs(k)-1)+(1:4))];
            end
            model = @(PARAMS,x_) (global_model(PARAMS,x_,length(xinxs),x_baseline_BETA));
            y_fit = model([MGPX_o,baseline_BETA],collections{i}.x');
            y_bin = collections{i}.Y(:,1) - y_fit;

            % Individual peaks
            peaks = {};
            for k = 1:length(X)
                MGPX_o = MGPX(4*(k-1)+(1:4));
                model = @(PARAMS,x_) (global_model(PARAMS,x_,1,x_baseline_BETA)); 
                peaks{k} = model([MGPX_o,0*x_baseline_BETA],collections{i}.x');
            end
            
            % Baseline
            model = @(PARAMS,x_) (global_model(PARAMS,x_,0,x_baseline_BETA)); 
            y_baseline = model(baseline_BETA,collections{i}.x');

            adj_saved_data{i}.Y_bin = {};
            adj_saved_data{i}.Y_bin{1} = y_bin(inxs);
            adj_saved_data{i}.Y_fit = {};
            adj_saved_data{i}.Y_fit{1} = y_fit(inxs);
            adj_saved_data{i}.Y_baseline = {};
            adj_saved_data{i}.Y_baseline{1} = y_baseline(inxs);            
            adj_saved_data{i}.peaks = {};
            adj_saved_data{i}.peaks{1} = peaks;
            adj_saved_data{i}.X = {};
            adj_saved_data{i}.X{1} = X;            
        end
     
        if ~exist('hide_plot') || ~hide_plot
            hl = line(collections{i}.x(inxs),adj_saved_data{i}.Y_bin{1},'Color',colors(mod(i+offset-2,length(colors))+1,:));
            myfunc = @(hObject, eventdata, handles) (plot_line(i,1,inxs,adj_saved_data{i}.Y_fit{1},...
                collections{i}.spectra{1}.y_smoothed,left_min,right_min,adj_saved_data{i}.X{1},adj_saved_data{i}.peaks{1},adj_saved_data{i}.Y_baseline{1}));
            set(hl,'ButtonDownFcn',myfunc);
            yhs(end+1) = hl;
            % Change the following line if you want to change the legend for
            % each collection
            legend_cell{end+1} = num2str(collections{i}.description);
        end
    end
    if ~exist('hide_plot') || ~hide_plot
        lh = legend(legend_cell);
        line([left,left],yl,'Color','r');
        line([right,right],yl,'Color','r');
    end
    for i = 1:length(collections)
        for j = 2:collections{i}.num_samples
            % Small adjustments to boundaries
            xmins = [collections{i}.spectra{j}.xmins(:,1);collections{i}.spectra{j}.xmins(:,2)];
            diffs = xmins - far_left;
            tinxs = find(diffs >= 0);
            diffs = diffs(tinxs);
            if ~isempty(diffs)
                [vs,ixs] = sort(diffs,'ascend');
                far_left_min = xmins(tinxs(ixs(1)));
            else
                far_left_min = far_left;
            end
            diffs = far_right - xmins;
            tinxs = find(diffs >= 0);
            diffs = diffs(tinxs);
            if ~isempty(diffs)
                [vs,ixs] = sort(diffs,'ascend');
                far_right_min = xmins(tinxs(ixs(1)));
            else
                far_right_min = far_right;
            end            
            inxs = find(far_left_min >= collections{i}.x & collections{i}.x >= far_right_min);
            
            if dirty
                [y_fit,fit_inxs,MGPX,baseline_BETA,x_baseline_BETA,xmaxs] = curve_fit_helper(collections,i,j,left,right,far_left_min,far_right_min);
                collections{i}.spectra{j}.xmaxs = xmaxs;
                setappdata(calling_gcf,'collections',collections);
                X = MGPX(4:4:end);
                xinxs = [find(X >= left),find(X <= right)];
                MGPX_o = [];
                for k = 1:length(xinxs)
                    MGPX_o = [MGPX_o,MGPX(4*(xinxs(k)-1)+(1:4))];
                end
                model = @(PARAMS,x_) (global_model(PARAMS,x_,length(xinxs),x_baseline_BETA));
                y_fit = model([MGPX_o,baseline_BETA],collections{i}.x');
                y_bin = collections{i}.Y(:,j) - y_fit;

                % Individual peaks
                peaks = {};
                for k = 1:length(X)
                    MGPX_o = MGPX(4*(k-1)+(1:4));
                    model = @(PARAMS,x_) (global_model(PARAMS,x_,1,x_baseline_BETA)); 
                    peaks{k} = model([MGPX_o,0*x_baseline_BETA],collections{i}.x');
                end

                % Just the baseline
                model = @(PARAMS,x_) (global_model(PARAMS,x_,0,x_baseline_BETA));
                y_baseline = model(baseline_BETA,collections{i}.x');

                adj_saved_data{i}.Y_baseline{j} = y_baseline(inxs);
                adj_saved_data{i}.peaks{j} = peaks;
                adj_saved_data{i}.Y_bin{j} = y_bin(inxs);
                adj_saved_data{i}.Y_fit{j} = y_fit(inxs);
                adj_saved_data{i}.X{j} = X;
            end

            if ~exist('hide_plot') || ~hide_plot
                hl = line(collections{i}.x(inxs),adj_saved_data{i}.Y_bin{j},'Color',colors(mod(i+offset-2,length(colors))+1,:));
                myfunc = @(hObject, eventdata, handles) (plot_line(i,j,inxs,adj_saved_data{i}.Y_fit{j},collections{i}.spectra{j}.y_smoothed,...
                    left_min,right_min,adj_saved_data{i}.X{j},adj_saved_data{i}.peaks{j},adj_saved_data{i}.Y_baseline{j}));
                set(hl,'ButtonDownFcn',myfunc);
                yhs(end+1) = hl;
            end
        end
    end
    if ~exist('hide_plot') || ~hide_plot
        setappdata(gcf,'yhs',yhs);
        setappdata(gcf,'lh',lh);
        set(gca,'xdir','reverse')
        xlabel('Chemical shift, ppm')
        ylabel('Intensity')
        ylim auto
        xlim auto
        title({'Adjacent deconvolution'})
    end
end